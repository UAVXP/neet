# neet
neet is neet net library for Garry's Mod

It allows easy usage of the network library used in Garry's Mod (net).

This library could compress your messages automatically, so you will never need to think again, "What `net.somethingsomething` I should use now? And in what order..."

REMEMBER: This library is under heavy W.I.P. It contains many comments and shitcode, and also I probably will change the way you will use it, so be careful with pulling changes ;)

## Advantages
It can automatically create Network Strings, so you will not bother yourself with that unneeded stuff.

The message will delay a bit because server should process `util.AddNetworkString` (as I've been told at Gmod Wiki). You can control this delay via convar (see Configuration section below)

Also it will automatically determine the best way to send numbers (int/uint/float/double).

Other than that, it will automatically compress/decompress strings, if compressed string will be shorter that uncompressed.

## Configuration
`neet_senddelay` (seconds) - Delay of sending a message if network string doesn't exist (1-∞, default: 3)

## Usage
Usage of this library is very simple and clean: only three lines is enough.
### Sending from server to all clients (broadcast)
```lua
local tosend = {} -- Table of your contents
neet.Start( "MyNetworkString", tosend, neet.Broadcast() )
```

### Sending from server to specific client
```lua
local tosend = {} -- Table of your contents
neet.Start( "MyNetworkString", tosend, neet.Send( player.GetAll()[1] ) )
```

### Sending from client to server
```lua
local tosend = {} -- Table of your contents
neet.Start( "MyNetworkString", tosend, neet.SendToServer() )
```

### Receiving on server
```lua
neet.Receive( "MyNetworkString", function( buf, len, ply )
	PrintTable( buf )
end )
```

### Receiving on client
```lua
neet.Receive( "MyNetworkString", function( buf, len )
	PrintTable( buf )
end )
```

## TODO
Support for message chunking is also would be cool (65533 bytes, remember, right? You nasty big message fanboy)
