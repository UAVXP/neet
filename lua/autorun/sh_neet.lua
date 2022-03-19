neet = {}

-- FIXME: Split in future into SERVER and CLIENT
NEET_Broadcast = 1
NEET_Send = 2
NEET_SendOmit = 3
NEET_SendPAS = 4
NEET_SendPVS = 5
NEET_SendToServer = 6

neet.Config.DelaySendingMessageIfNetNameNotExists = 3

neet.msgs = {
	[1] = {
		NetName = "MyNetworkString"
	}
}

function neet.MakeDelay( messageName, delay )
	timer.Simple( delay, function()
		neet.Start( messageName )
	end )
end

-- messageName = string
-- params = { any }
-- neetparams = { msg = { msgtype = NEET_Broadcast/NEET_Send/.../NEET_SendToServer[, extra = Player/{}/CRecipientFilter/Vector]}, unreliable = true/false }
function neet.Start( messageName, params, neetparams )
	-- if not found netstring in neet.msgs - create one
	-- Then make the message to run in few seconds later
	local bIsNetNameFound = false
	for k,v in pairs( neet.msgs ) do
		if v.NetName == messageName then
			bIsNetNameFound = true
			break
		end
	end

	if not bIsNetNameFound then
		-- create net netmsg
		util.AddNetworkString( messageName )
		local tblNewNetMsg = {
			NetName = messageName,
			t_delay = neet.Config.DelaySendingMessageIfNetNameNotExists,
			isfine = false -- Means that the netname is going to be created, but the message itself not being sent for now
		}
		table.insert( neet.msgs, tblNewNetMsg )

		-- TODO: delay
		neet.MakeDelay( messageName, tblNewNetMsg.t_delay )

		-- return false? even if the message is being created
		return false
	end

	local bIsStarted = net.Start( messageName, neetparams.unreliable )
	for k,v in pairs( params ) do
		local typeid = TypeID( v )
		if typeid == TYPE_NUMBER then
			-- FIXME: If WriteInt - use less/determined bits in future
			-- FIXME: Autodetermine what is better to use: WriteInt( autobits ), WriteDouble or WriteFloat
			net.WriteDouble( v )
		elseif typeid == TYPE_STRING then
			net.WriteString( v )
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

	return bIsStarted
end

-- TODO: net.ReadVars[typeid] for neet.Receive

function neet.ConstructParams( msgtype, extra, unreliable )
	local params = {}
	params.msg = {}
	params.msg.msgtype = msgtype

	if msgtype == NEET_Send and extra != nil then params.msg.extra = extra end
	if unreliable != nil then params.unreliable = unreliable end

	return params
end


-- Tests
concommand.Add( "send_msg", function( ply, cmd, args, str )
	local tosend = {"I'm a man.", 43}
--	local nparams = { msg = {msgtype = NEET_Broadcast}, unreliable = false } -- TODO: Make common params into a separate neet-vars
	local nparams = neet.ConstructParams( NEET_Broadcast )
	nparams = neet.ConstructParams( NEET_Send, player.GetAll()[1] )
	neet.Start( "MyNetworkString", tosend, nparams )
end )