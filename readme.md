## What
A lua script for FCEUX, Mesen, and Bizhawk that grabs frame data directly from the emulator using memory readouts and then sends it to https://github.com/timotheeg/nestrischamps for cool rendering stuff.

Can easily be ported to other emulators that support Lua scripting.

## Why
Because OCR is slow and unnecessary for emulators.

## How
### FCEUX
- Extract to FCEUX/luaScripts
- Run FCEUX, run Tetris
- Go to File -> Lua -> New Lua Script Window
- Browse to nestrischamps.lua
- Hit run
- Enter the websocket URL and your secret

### Mesen
- **On Windows:** Extract to Mesen/lua, creating the folder if it doesn't exist
- **On Linux:** Extract to Mesen
- Copy nestrischamps/environment.lua.example to Mesen/lua/nestrischamps/environment.lua
- Edit the file you just copied, putting your secret into the DEFAULTSECRET string
- Run Mesen, run Tetris
- Go to Debug -> Script Window
- Go to File -> Open and browse to nestrischamps.lua

### Bizhawk
- Extract to Bizhawk/Lua
- Copy nestrischamps/environment.lua.example to nestrischamps/environment.lua
- Edit the file you just copied, putting your secret into the DEFAULTSECRET string
- Run Bizhawk, run Tetris
- Go to Tools -> Lua Console
- Go to Script -> Open Script and browse to nestrischamps.lua

If it worked, it should say "Connected successfully!". You can then go to your renderer (go to https://nestrischamps.io/renderers and select Simple 1p) and it should display any game you start.

You can find your secret on the NestrisChamps settings page, https://nestrischamps.io/settings

## Easy Connect Info
The "Easy Connect Info" is meant to encapsulate all necessary information to connect to the websocket at nestetrischamps.io. It can contain a number of "key=value" pairs which are seperated by a "&". It usually looks something like "v=2&host=XXX&s=YYY", but can also be shortened. E.g. "v=1" sends to the players private room, if his DEFAULTSECRET is set up correctly.

### "v" -> URL Version
- "v=1" -> ws://nestrischamps.io/ws/room/producer
- "v=2" -> ws://nestrischamps.io/ws/room/u/{host}/producer

### "host" -> Twitch Username of the Host
Can be left out when not URL Version 2 is used.

### "s" -> Secret
The player needs to use his private secret to identify himself, can be found on https://nestrischamps.io/settings