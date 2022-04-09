# neet
neet is neet net library for Garry's Mod

It allows easy usage of the network library used in Garry's Mod (net).

This library could compress your messages automatically, so you will never need to think again, "What `net.somethingsomething` I should use now? And in what order..."

REMEMBER: This library is under heavy W.I.P. It contains many comments and shitcode, and also I probably will change the way you will use it, so be careful with pulling changes ;)

## Advantages
It can automatically create Network Strings, so you will not bother yourself with that unneeded stuff.

Also it will automatically determine the best way to send numbers (int/uint/float/double).

Other than that, it will automatically compress/decompress strings, if compressed string will be shorter that uncompressed.

## Usage
Usage of this library is very simple and clean: only three lines is enough.
### Sending from server to all clients (broadcast)
```lua
local tosend = {} -- Table of your contents
local nparams = neet.ConstructParams( NEET_Broadcast )
neet.Start( "MyNetworkString", tosend, nparams )
```

### Sending from server to specific client
```lua
local tosend = {} -- Table of your contents
local nparams = neet.ConstructParams( NEET_Send, player.GetAll()[1] )
neet.Start( "MyNetworkString", tosend, nparams )
```

### Sending from client to server
```lua
local tosend = {} -- Table of your contents
local nparams = neet.ConstructParams( NEET_SendToServer )
neet.Start( "MyNetworkString", tosend, nparams )
```

## TODO
I'm going to add SendOmit, SendPAS and SendPVS sometime later
