--neet = {}
module( "neet", package.seeall )

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

if SERVER then NEET_Broadcast = 1 end
NEET_Send = 2
if SERVER then NEET_SendOmit = 3 end
if SERVER then NEET_SendPAS = 4 end
if SERVER then NEET_SendPVS = 5 end
if CLIENT then NEET_SendToServer = 6 end

--[[ Old values
NEET_BITS_Float = 0
NEET_BITS_Double = 1
NEET_BITS_UInt = 2
NEET_BITS_Integer = 3
]]
NEET_BITS_Int = -1
NEET_BITS_UInt = -2
NEET_BITS_Float = -3
NEET_BITS_Double = -4



neet.Config = {}

--neet.Config.DelaySendingMessageIfNetNameNotExists = 3
local bits_ReplicatedArchived = FCVAR_NONE
bits_ReplicatedArchived = bit.bor( bits_ReplicatedArchived, FCVAR_REPLICATED, FCVAR_ARCHIVE )
neet.Config.SendDelay = CreateConVar( "neet_senddelay", 3, bits_ReplicatedArchived, "Delay of sending a message if network string doesn't exist", 1 )

neet.Config.StringCompressedLengthBits = 16 -- Do not change! Amount of bits that are used to store the string length in netmessages

function neet.ConstructParams( msgtype, extra, unreliable )
	local params = {}
	params.msg = {}
	params.msg.msgtype = msgtype

	if msgtype == NEET_Send and extra != nil then params.msg.extra = extra end
	if unreliable != nil then params.unreliable = unreliable end

	return params
end

-- Helpers
-- TODO: Maybe, we need to include neet.Start here for even more simplicity?
function neet.Broadcast() return neet.ConstructParams( NEET_Broadcast ) end
function neet.SendToServer() return neet.ConstructParams( NEET_SendToServer ) end
function neet.Send( extra ) return neet.ConstructParams( NEET_Send, extra ) end
function neet.SendOmit( extra ) return neet.ConstructParams( NEET_SendOmit, extra ) end
function neet.SendPAS( extra ) return neet.ConstructParams( NEET_SendPAS, extra ) end
function neet.SendPVS( extra ) return neet.ConstructParams( NEET_SendPVS, extra ) end

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
	print( "neetMakeDelay:", delay )
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
local function neetChooseIntBits( number )
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

-- FIXME: This is really bad
local function neetChooseUIntBits( number )
	-- number should be always >= 0
	if number < 0 then error("neet: UInt number is unexpectedly below zero!") end

--	We could return "neetChooseIntBits( number ) - 1", but it could be 0

	if number <= 1 then
		return 1
	end
	if number <= 3 then
		return 2
	end
	if number <= 7 then
		return 3
	end
	if number <= 15 then
		return 4
	end
	if number <= 31 then
		return 5
	end
	if number <= 63 then
		return 6
	end
	if number <= 127 then
		return 7
	end
	if number <= 255 then
		return 8
	end
	if number <= 511 then
		return 9
	end
	if number <= 1023 then
		return 10
	end
	if number <= 2047 then
		return 11
	end
	if number <= 4095 then
		return 12
	end
	if number <= 8191 then
		return 13
	end
	if number <= 16383 then
		return 14
	end
	if number <= 32767 then
		return 15
	end
	if number <= 65535 then
		return 16
	end
	if number <= 131071 then
		return 17
	end
	if number <= 262143 then
		return 18
	end
	if number <= 524287 then
		return 19
	end
	if number <= 1048575 then
		return 20
	end
	if number <= 2097151 then
		return 21
	end
	if number <= 4194303 then
		return 22
	end
	if number <= 8388607 then
		return 23
	end
	if number <= 16777215 then
		return 24
	end
	if number <= 33554431 then
		return 25
	end
	if number <= 67108863 then
		return 26
	end
	if number <= 134217727 then
		return 27
	end
	if number <= 268435455 then
		return 28
	end
	if number <= 536870911 then
		return 29
	end
	if number <= 1073741823 then
		return 30
	end
	if number <= 2147483647 then
		return 31
	end
	if number <= 4294967295 then
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
			-- TODO: Detect if we should use UInt or not. Should decrease size of a netmessage by 1 bit
--[[
		--	net.WriteDouble( v )
			local maximumBitsRequired = NEET_BITS_Integer
		--	local isNumberIsInt = v < 0 or not ( v > 2147483647 and v < math.huge )
			local isNumberIsInt = v < 0 or not ( v > 2147483645 and v < math.huge )
			if isNumberIsInt then -- This is usual int
				maximumBitsRequired = neetChooseIntBits( v )
			else
				maximumBitsRequired = neetChooseUIntBits( v )
			end
			print("Sending", v, "as", isNumberIsInt and "int" or "uint", ", and number of bits to send is", maximumBitsRequired, v)

			net.WriteBool( isNumberIsInt ) -- Is number is signed (either integer, float or double)

			-- TODO: Do support for double
			-- Double should be the exception case for... extra large signed numbers???
			if v == math.floor( v ) then -- This number is really integer
				net.WriteUInt( maximumBitsRequired, 6 )
				if isNumberIsInt then
					net.WriteInt( v, maximumBitsRequired )
				else
					net.WriteUInt( v, maximumBitsRequired )
				end
			else -- Float
				-- -54.8 is more precise on double, than on float,
				-- but double is more demanding to a network
				net.WriteUInt( NEET_BITS_Float, 6 ) -- TODO: Define these bits explicitly
				net.WriteFloat( v )
			--	net.WriteFloat( -54.8 )-- 2147483647 )-- 4294967300 )-- 4294967296 )

			--	net.WriteUInt( NEET_BITS_Double, 6 )
			--	net.WriteDouble( -54.8 )
			end
]]
			-- int		4-byte (32-bit) signed (-2147483648 - 2147483647)
			-- uint		4-byte (32-bit) unsigned (0 - 4294967295)
			-- float	4-byte (32-bit) float signed (-2147483648 - 2147483647) -- FIXME: gets more unprecised near the borders
			-- double	8-byte? (64-bit?) float signed (~~ -/+(1.79 * math.pow(10,308)))
--[[
			net.WriteBool( false )
		--	net.WriteUInt( NEET_BITS_Float, 6 )
		--	net.WriteFloat( -2147483649 )
			net.WriteUInt( NEET_BITS_Double, 6 )
		--	net.WriteDouble( (math.pow(2, 1024) / 2) - 10 )
		
			local hugenum = math.pow(2, 1023)
			print(hugenum)
			for i=1022, 971, -1 do
				hugenum = hugenum + math.pow(2, i)
			end
			hugenum = hugenum + 1
		
			local hugenum = 1.79 * math.pow(10,308)
			print(hugenum < math.huge)
			net.WriteDouble( -hugenum )
]]
			local isFloatingPoint = ( v != math.floor( v ) )
			local isSigned = v < 0
		--	print("floating point? ", isFloatingPoint, "; signed? ", isSigned)

			if math.abs( v ) <= 2147483648 then -- int/uint/float routine
				if not isFloatingPoint then -- int
					if isSigned then -- signed int
					--	print("Writing signed int", v)
						net.WriteBool( true ) -- Is signed int
						local bits = neetChooseIntBits( v )
						net.WriteInt( bits, 7 ) -- NEET_BITS_Int
						net.WriteInt( v, bits )
					else -- unsigned int
					--	print("Writing unsigned int", v)
						net.WriteBool( false )
						local bits = neetChooseUIntBits( v )
						net.WriteInt( bits, 7 ) -- NEET_BITS_UInt
						net.WriteUInt( v, bits )
					end
				else -- float
				--	print("Writing float", v)
					net.WriteBool( false )
					net.WriteInt( NEET_BITS_Float, 7 )
					net.WriteFloat( v )
				end
			else -- double routine
			--	print("Writing double", v)
				net.WriteBool( false )
				net.WriteInt( NEET_BITS_Double, 7 )
				net.WriteDouble( v )
			end
			

		elseif typeid == TYPE_STRING then
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
			-- In the case when compressed>uncompressed - just send it via usual WriteString
			if isStringSmallerThanCompressedString then
				net.WriteString( v )
			else
				net.WriteUInt( writelen, neet.Config.StringCompressedLengthBits )
				net.WriteData( towrite )
			end
		elseif typeid == TYPE_COLOR then -- TODO: Determine whether or not we should write alpha?
			net.WriteColor( v, true )
		elseif typeid == TYPE_VECTOR then -- TODO: Determine sending vector or normal?
			net.WriteVector( v )
		elseif typeid == TYPE_BOOL then
			net.WriteBool( v )
		elseif typeid == TYPE_TABLE then
			net.WriteTable( v )
		elseif typeid == TYPE_ANGLE then
			net.WriteAngle( v )
		elseif typeid == TYPE_ENTITY then
			net.WriteEntity( v )
		elseif typeid == TYPE_MATRIX then
			net.WriteMatrix( v )
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
			t_delay = netmsgNotAdded and neet.Config.SendDelay:GetInt() or 0,
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
--[[
			local isNumberIsInt = net.ReadBool()
			local maximumBitsRequired = net.ReadUInt( 6 )
			if maximumBitsRequired >= NEET_BITS_Integer then
				if isNumberIsInt then
					table.insert( buf, net.ReadInt( maximumBitsRequired ) )
				else
					table.insert( buf, net.ReadUInt( maximumBitsRequired ) )
				end
			elseif maximumBitsRequired == NEET_BITS_Float then
				table.insert( buf, net.ReadFloat() )
			elseif maximumBitsRequired == NEET_BITS_Double then
				table.insert( buf, net.ReadDouble() )
			end
]]
			local isSignedInt = net.ReadBool()
			local bits = net.ReadInt( 7 )
			if bits == NEET_BITS_Float then
				table.insert( buf, net.ReadFloat() )
			elseif bits == NEET_BITS_Double then
				table.insert( buf, net.ReadDouble() )
			else -- signed/unsigned int
				if isSignedInt then -- signed int
					table.insert( buf, net.ReadInt( bits ) )
				else -- unsigned int
					table.insert( buf, net.ReadUInt( bits ) )
				end
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
		elseif typeid == TYPE_COLOR then
			table.insert( buf, net.ReadColor( true ) )
		elseif typeid == TYPE_VECTOR then
			table.insert( buf, net.ReadVector() )
		elseif typeid == TYPE_BOOL then
			table.insert( buf, net.ReadBool() )
		elseif typeid == TYPE_TABLE then
			table.insert( buf, net.ReadTable() )
		elseif typeid == TYPE_ANGLE then
			table.insert( buf, net.ReadAngle() )
		elseif typeid == TYPE_ENTITY then
			table.insert( buf, net.ReadEntity() )
		elseif typeid == TYPE_MATRIX then
			table.insert( buf, net.ReadMatrix() )
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


--------- Tests ---------
-- neet
if SERVER then
concommand.Add( "send_msg", function( ply, cmd, args, str )
	local tosend = {	"I'm a man.",
						43,
						69.5,
						(1.79 * math.pow(10,308)),
						-(1.79 * math.pow(10,308)),
						Vector(356, 0, 120),
						Color(255, 0, 255, 127),
						math.random( 1, 400 ) > 200 and true or false,
						{"Test val 1", "Test val 2"},
						{["key"] = "value", [50] = Color(255, 255, 255, 255)},
						game.GetWorld()}
--	local nparams = { msg = {msgtype = NEET_Broadcast}, unreliable = false } -- TODO: Make common params into a separate neet-vars
--	local nparams = neet.ConstructParams( NEET_Broadcast )
--	nparams = neet.ConstructParams( NEET_Send, player.GetAll()[1] )
	neet.Start( "MyNetworkString", tosend, neet.Broadcast() )
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
	neet.Start( "MyNewNetworkString", tosend, neet.SendToServer() )
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
		net.WriteFloat(69.5)
		net.WriteDouble(1.79 * math.pow(10,308))
		net.WriteDouble(-(1.79 * math.pow(10,308)))
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







--[[
if SERVER then
util.AddNetworkString( "MsgSendToAllClients" )
net.Start( "MsgSendToAllClients" )
	net.WriteInt( 9999, 16 )
	net.WriteString( "Hello! This is message from a server to all clients." )
net.Broadcast()
end

if CLIENT then
net.Receive( "MsgSendToAllClients", function( len )
	print( net.ReadInt( 16 ) )
	print( net.ReadString() )
end )
end
]]

















--[[
if SERVER then
neet.Start( "neet:MsgSendToAllClients", {9999, "Hello! This is message from a server to all clients."}, neet.Broadcast )
end

if CLIENT then
neet.Receive( "neet:MsgSendToAllClients", function( buf )
	print( buf[1] )
	print( buf[2] )
end )
end
]]














































--PrintTable(neet)
