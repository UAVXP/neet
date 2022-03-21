neet = {}

if SERVER then
util.AddNetworkString( "neet:SyncMsgs" )
util.AddNetworkString( "neet:AddNetworkString" )
end

--[[
local table = table
local oldTableInsert = table.insert
table.insert = function( tbl, position, value )
	oldTableInsert( tbl, position, value )
	neetSyncMsgs()
end
]]

-- FIXME: Split in future into SERVER and CLIENT
NEET_Broadcast = 1
NEET_Send = 2
NEET_SendOmit = 3
NEET_SendPAS = 4
NEET_SendPVS = 5
NEET_SendToServer = 6

neet.Config = {}
neet.Config.DelaySendingMessageIfNetNameNotExists = 3

hook.Remove( "NetworkIDValidated", "neet:NetworkIDValidated" )
hook.Add( "NetworkIDValidated", "neet:NetworkIDValidated", function( name, steamID )
	print("NetworkIDValidated", name, steamID)
end )

--[[
	[1] = {
		NetName = "MyNetworkString"
	}
]]
neet.msgs = {}

local function neetSyncMsgs()
	net.Start( "neet:SyncMsgs" )
		net.WriteTable( neet.msgs ) -- FIXME: Do not use WriteTable
if SERVER then
	net.Broadcast()
else
	net.SendToServer()
end
end

if SERVER then
net.Receive( "neet:SyncMsgs", function( len, ply )
	neet.msgs = net.ReadTable()
end )
else
net.Receive( "neet:SyncMsgs", function( len )
	neet.msgs = net.ReadTable()
end )
end

local function neetMakeDelay( messageName, delay )
	print( "neetMakeDelay" )
	timer.Simple( delay, function()
		neet.Start( messageName )
	end )
end

local function neetFindByMessageName( messageName )
	local found = false
	local kFound = 0
--	PrintTable(neet.msgs)
	for k,v in pairs( neet.msgs ) do
	--	print( v.NetName, messageName )
		if v.NetName == messageName then
		--	print("found!")
			found = true
			kFound = k
			break
		end
	end

	print(found, kFound)
	return found, kFound
end

-- TODO
local function neetEstimateSize( params )
	for k,v in pairs( params ) do

	end
end

local function neetStartInternal( messageName, params, neetparams )

	local bufsize = neetEstimateSize( params )

	local isStarted = net.Start( messageName, neetparams.unreliable )
--	PrintTable(params)
	for k,v in pairs( params ) do
		local typeid = TypeID( v )
		if typeid == TYPE_NUMBER then
			-- FIXME: If WriteInt - use less/determined bits in future
			-- FIXME: Autodetermine what is better to use: WriteInt( autobits ), WriteDouble or WriteFloat
			net.WriteDouble( v )
		elseif typeid == TYPE_STRING then

			-- TODO: Make sure the compressed string is smaller than the string itself
			-- In the case when compressed>uncompressed - just send it via usual WriteString

		--	print("prewritelen", #v)
			local towrite = util.Compress( v )
			if towrite == nil then error("neet: Cannot compress the string", v) continue end
			local writelen = #towrite
			if writelen > #v then writelen = 0 end
		--	print("writelen:", writelen)
		--	print("Compressed: ", towrite)
		--	net.WriteString( towrite )
			net.WriteUInt( writelen, 16 ) -- We need that anyway so we can determine should we uncompress it or not
			if writelen == 0 then
				net.WriteString( v )
			else
				net.WriteData( towrite )
			end
		end
	end

	-- TODO: Make a key-value pair table for easier reading
	if SERVER and neetparams.msg.msgtype == NEET_Broadcast then
		net.Broadcast()
	elseif SERVER and neetparams.msg.msgtype == NEET_Send then
		net.Send( neetparams.msg.extra )
	elseif SERVER and neetparams.msg.msgtype == NEET_SendOmit then
		net.SendOmit( neetparams.msg.extra )
	elseif SERVER and neetparams.msg.msgtype == NEET_SendPAS then
		net.SendPAS( neetparams.msg.extra )
	elseif SERVER and neetparams.msg.msgtype == NEET_SendPVS then
		net.SendPVS( neetparams.msg.extra )
	elseif CLIENT and neetparams.msg.msgtype == NEET_SendToServer then
		net.SendToServer()
	end

	return isStarted
end

local function neetAddNetworkString( messageName )
	if util.NetworkStringToID( messageName ) != 0 then return false end

	if SERVER then
		util.AddNetworkString( messageName )
		return true
	else
		local started = net.Start( "neet:AddNetworkString" )
		net.WriteString( messageName )
		net.SendToServer()

		return started
	end
end

if SERVER then
	net.Receive( "neet:AddNetworkString", function( len, ply )
		util.AddNetworkString( net.ReadString() )
	end )
end
-- messageName = string
-- params = { any }
-- neetparams = { msg = { msgtype = NEET_Broadcast/NEET_Send/.../NEET_SendToServer[, extra = Player/{}/CRecipientFilter/Vector]}, unreliable = true/false }
function neet.Start( messageName, params, neetparams )
	-- if not found netstring in neet.msgs - create one
	-- Then make the message to run in few seconds later
	local bIsNetNameFound, kFound = neetFindByMessageName( messageName )

	local netmsgNotAdded = neetAddNetworkString( messageName )

	if not bIsNetNameFound then
		-- create net netmsg
		

		local tblNewNetMsg = {
			NetName = messageName,
			t_delay = netmsgNotAdded and neet.Config.DelaySendingMessageIfNetNameNotExists or 0,
			isfine = netmsgIsAlreadyExist, -- Means that the netname is going to be created, but the message itself not being sent for now
			params = params,
			neetparams = neetparams
		}

		local newk = table.insert( neet.msgs, tblNewNetMsg )
		neetSyncMsgs()

		neetMakeDelay( messageName, tblNewNetMsg.t_delay )

		-- return false? even if the message is being created
		return false
	end

	local intParams = neet.msgs[kFound].params --or params
	local intNeetparams = neet.msgs[kFound].neetparams --or neetparams
	local bIsStarted = neetStartInternal( messageName, intParams, intNeetparams )

	neet.msgs[kFound].isfine = bIsStarted
	return bIsStarted
end

local function neetReceiveInternal()
end

local function neetReceiveInternal( messageName )
	local bIsNetNameFound, kFound = neetFindByMessageName( messageName )
	if not bIsNetNameFound then error("neet: Something bad happened at receiving msg") end
	local params = neet.msgs[kFound].params

	local buf = {}

	for k,v in pairs( params ) do
		local typeid = TypeID( v )
		if typeid == TYPE_NUMBER then
			table.insert( buf, net.ReadDouble() )
		elseif typeid == TYPE_STRING then
		--	local predecomp = net.ReadString()
			local readlen = net.ReadUInt( 16 )
			local readstr = ""
			if readlen == 0 then
				readstr = net.ReadString()
			else
			--	print("readlen", readlen)
				local predecomp = net.ReadData( readlen )
			--	print(predecomp)
				local readstr = util.Decompress( predecomp )
				print("Decompressed: ", readstr)
				if readstr == "" then error("neet: Cannot decompress the string") end
			end
			table.insert( buf, readstr )
		end
	end

	return buf
end

-- Sets up the callback and decompresses the strings
-- TODO: net.ReadVars[typeid] for neet.Receive
function neet.Receive( messageName, callback )
if SERVER then
	net.Receive( messageName, function( len, ply )
		local buf = neetReceiveInternal( messageName )
		callback( buf, len, ply )
	end )
end
if CLIENT then
	net.Receive( messageName, function( len )
		local buf = neetReceiveInternal( messageName )
		callback( buf, len )
	end )
end
end

function neet.ConstructParams( msgtype, extra, unreliable )
	local params = {}
	params.msg = {}
	params.msg.msgtype = msgtype

	if msgtype == NEET_Send and extra != nil then params.msg.extra = extra end
	if unreliable != nil then params.unreliable = unreliable end

	return params
end


--------- Tests ---------
-- neet
if SERVER then
concommand.Add( "send_msg", function( ply, cmd, args, str )
	local tosend = {"I'm a man.", 43}
--	local nparams = { msg = {msgtype = NEET_Broadcast}, unreliable = false } -- TODO: Make common params into a separate neet-vars
	local nparams = neet.ConstructParams( NEET_Broadcast )
--	nparams = neet.ConstructParams( NEET_Send, player.GetAll()[1] )
	neet.Start( "MyNetworkString", tosend, nparams )
end )

neet.Receive("MyNewNetworkString", function( buf, len, ply )
	print("neet len:", len, "msg on server from client:")
	PrintTable( buf )
end )
end

if CLIENT then
neet.Receive( "MyNetworkString", function( buf, len )
	print("neet len:", len, "msg on client from server:")
	PrintTable( buf )

	local tosend = {6845, "Cool! Nice to meet you!"}
	local nparams = neet.ConstructParams( NEET_SendToServer )
	neet.Start( "MyNewNetworkString", tosend, nparams )
end )
end



-- net
if SERVER then
util.AddNetworkString("MyNetworkString2")
util.AddNetworkString("MyNewNetworkString2")
concommand.Add( "send_msg2", function( ply, cmd, args, str )
	net.Start( "MyNetworkString2" )
		net.WriteString("I'm a man.")
		net.WriteDouble(43)
	net.Broadcast()
end )

net.Receive("MyNewNetworkString2", function( len, ply )
	print("net len:", len, "msg on server from client:")
	
end )
end

if CLIENT then
	net.Receive( "MyNetworkString2", function( len )
		print("net len:", len, "msg on client from server:")
		net.Start("MyNewNetworkString2")
			net.WriteDouble(6845)
			net.WriteString("Cool! Nice to meet you!")
		net.SendToServer()
	end )
end