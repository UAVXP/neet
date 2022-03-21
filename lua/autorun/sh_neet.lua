neet = {}

if SERVER then
util.AddNetworkString( "neet:SyncMsgs" )
util.AddNetworkString( "neet:AddNetworkString" )

--[[
--local n = (128 + 1) / 2
local n = (3) + 1
local frac, exp = math.frexp(n)
local result = exp + math.ceil(frac - 1.5)
result = math.ceil(math.log10(n) / math.log10(2))
print(n, result)
print("---- ", (math.pow(2, result) - 1))

print(#math.IntToBin(126 / 2))
print(math.ceil(tonumber( string.rep( "1", 3), 2 )/2) - 1)
print(math.pow(2, 3))

print()
]]
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

NEET_BITS_Integer = 3 -- Not used
NEET_BITS_Float = 0

neet.Config = {}
neet.Config.DelaySendingMessageIfNetNameNotExists = 3
neet.Config.StringCompressedLengthBits = 16

--[[
hook.Remove( "NetworkIDValidated", "neet:NetworkIDValidated" )
hook.Add( "NetworkIDValidated", "neet:NetworkIDValidated", function( name, steamID )
	print("NetworkIDValidated", name, steamID)
end )
]]

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

-- FIXME: This is really bad
local function neetChooseNumberBits( number )
	--[[
		000
		001
		010
		011
		100
		101
		110
		111
	]]
	if number >= -4 and number <= 3 then
		return 3
	end
	if number >= -8 and number <= 7 then
		return 4
	end
	if number >= -16 and number <= 15 then
		return 5
	end
	if number >= -32 and number <= 31 then
		return 6
	end
	if number >= -64 and number <= 63 then
		return 7
	end
	if number >= -128 and number <= 127 then
		return 8
	end
	if number >= -256 and number <= 255 then
		return 9
	end
	if number >= -512 and number <= 511 then
		return 10
	end
	if number >= -1024 and number <= 1023 then
		return 11
	end
	if number >= -2048 and number <= 2047 then
		return 12
	end
	if number >= -4096 and number <= 4095 then
		return 13
	end
	if number >= -8192 and number <= 8191 then
		return 14
	end
	if number >= -16384 and number <= 16383 then
		return 15
	end
	if number >= -32768 and number <= 32767 then
		return 16
	end
	if number >= -65536 and number <= 65535 then
		return 17
	end
	if number >= -131072 and number <= 131071 then
		return 18
	end
	if number >= -262144 and number <= 262143 then
		return 19
	end
	if number >= -524288 and number <= 524287 then
		return 20
	end
	if number >= -1048576 and number <= 1048575 then
		return 21
	end
	if number >= -2097152 and number <= 2097151 then
		return 22
	end
	if number >= -4194304 and number <= 4194303 then
		return 23
	end
	if number >= -8388608 and number <= 8388607 then
		return 24
	end
	if number >= -16777216 and number <= 16777215 then
		return 25
	end
	if number >= -33554432 and number <= 33554431 then
		return 26
	end
	if number >= -67108864 and number <= 67108863 then
		return 27
	end
	if number >= -134217728 and number <= 134217727 then
		return 28
	end
	if number >= -268435456 and number <= 268435455 then
		return 29
	end
	if number >= -536870912 and number <= 536870911 then
		return 30
	end
	if number >= -1073741824 and number <= 1073741823 then
		return 31
	end
	if number >= -2147483648 and number <= 2147483647 then
		return 32
	end

	return 32
end

local function neetStartInternal( messageName, params, neetparams )

	local bufsize = neetEstimateSize( params )

	local isStarted = net.Start( messageName, neetparams.unreliable )
--	PrintTable(params)
	for k,v in pairs( params ) do
		local typeid = TypeID( v )
		if typeid == TYPE_NUMBER then
			-- FIXME: Autodetermine what is better to use: WriteInt( autobits ), WriteDouble or WriteFloat
		--	net.WriteDouble( v )
			local maximumBitsRequired = neetChooseNumberBits( v )
			print("Choosing this number of bits (", maximumBitsRequired, ") to send", v)

			if v == math.floor( v ) then -- This number is really integer
				net.WriteInt( maximumBitsRequired, 7 )
				net.WriteInt( v, maximumBitsRequired )
			else
				-- TODO: Do support for double
				net.WriteInt( NEET_BITS_Float, 7 ) -- TODO: Define those explicitly
				net.WriteFloat( v )
			end
		elseif typeid == TYPE_STRING then

			-- TODO: Make sure the compressed string is smaller than the string itself
			-- In the case when compressed>uncompressed - just send it via usual WriteString

		--	print("prewritelen", #v)
			local towrite = util.Compress( v )
			if towrite == nil then error("neet: Cannot compress the string", v) continue end
			local writelen = #towrite

			-- Is string is smaller than compressed string + UInt string length in bytes
			local isStringSmallerThanCompressedString = (#v < (writelen+(neet.Config.StringCompressedLengthBits/8)))
			net.WriteBool( isStringSmallerThanCompressedString ) -- false if sending usual string

		--	print("writelen:", writelen)
		--	print("Compressed: ", towrite)
		--	net.WriteString( towrite )
			if isStringSmallerThanCompressedString then
				net.WriteString( v )
			else
				net.WriteUInt( writelen, neet.Config.StringCompressedLengthBits )
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
		--	table.insert( buf, net.ReadDouble() )
			local maximumBitsRequired = net.ReadInt( 7 )
			if maximumBitsRequired >= NEET_BITS_Integer then
				table.insert( buf, net.ReadInt( maximumBitsRequired ) )
			elseif maximumBitsRequired == NEET_BITS_Float then
				table.insert( buf, net.ReadFloat() )
			end
		elseif typeid == TYPE_STRING then
		--	local predecomp = net.ReadString()
			local readstr = ""
			local isStringSmallerThanCompressedString = net.ReadBool()
			if isStringSmallerThanCompressedString then
				readstr = net.ReadString()
			else
				local readlen = net.ReadUInt( neet.Config.StringCompressedLengthBits )
			--	print("readlen", readlen)
				local predecomp = net.ReadData( readlen )
			--	print(predecomp)
				readstr = util.Decompress( predecomp )
			--	print("Decompressed: ", readstr)
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
	local tosend = {"I'm a man.", 43, 69.5}
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