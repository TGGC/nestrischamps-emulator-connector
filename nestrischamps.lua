-- find out which emu we're doing
-- this isn't optimal but I couldn't find a way to properly figure out the emu

local currentEmulator
if client then
    currentEmulator = "bizhawk"
elseif memory then
    currentEmulator = "fceux"
else
    currentEmulator = "mesen"
end

-- emulator specific GUI and tunnel stuff, all of them provide onLoad()
require("nestrischamps.emus." .. currentEmulator)
print("Detected " .. currentEmulator .. " emulator.")


require "nestrischamps.variables"
require "nestrischamps.lib.websocket"
require "nestrischamps.getters"
require "nestrischamps.util"
local frameManager = require "nestrischamps.frameManager"
local playfield = require "nestrischamps.playfield"
local socket = require "socket.core"

-- try to activate easy connect
pcall(function()
    require "easyconnect"
	EASYCONNECT = true -- show simplified connection dialog
	print("easyconnect activated")
	print("Delete easyconnect.lua to disable easyconnect")
end)


local conn
local lastURL
local lastSecret
function connect(url, secret) -- called by the emu plugin file
    if not url or not secret then
        print("Settings not found. You need to set up an environment.lua for Mesen and Bizhawk, see environment.lua.example")
        error()
    end
	
	lastURL = url;

    url = url .. "/" .. secret

    local err
    conn, err = wsopen(url)
    if not conn then
        print("Connection failed: " .. err)
        error()
    else
        print("Connected successfully!")
		
		lastSecret = secret

        if emu.registerexit then
            emu.registerexit(function()
                -- try our best to disconnect the socket on exit
                wsclose(conn)
            end)
        end
    end
end

function reconnect()
	-- was there any sucessful connection before?
    if not lastURL or not lastSecret then
		return
	end
	
	print("connection problem detected, trying reconnect...")
	connect(lastURL, lastSecret)
end

function connectImproved(url, secret, easy) -- called by the emu plugin file for easy login

	local easyData = {}
    for k, v in string.gmatch(easy, "(%w+)=(%w+)") do
		easyData[k] = v
    end
	
	if (easyData["v"] ~= nil) then
		local version = easyData["v"]
		print("Use URL Version " .. version)
		local urls = 		
			{	["1"] = "ws://nestrischamps.io/ws/room/producer", 
				["2"] = "ws://nestrischamps.io/ws/room/u/{host}/producer",}
		if (urls[version] ~= nil) then
			local urlBase = urls[version]
			url = string.gsub(urlBase, "%{(%w+)%}", easyData)
			print("using URL: " .. url)
		else
			print("URL Version unknown")
		end
	end
	
	if (easyData["s"] ~= nil) then
		secret = easyData["s"]
		print("using secret: " .. secret)
	end
	 
    return connect(url, secret)
end

local startTime = socket.gettime()*1000 -- questionable use of socket
local lastFrame = startTime
local gameNo = 0
local state = {}

function newGameStarted()
    gameNo = gameNo + 1
    print("Started game #" .. gameNo)

    state = {
        pieceX = -1,
        pieceY = -1,
        pieceID = -1,
    }

    playfield.initialize()
end


local previousPieceState = -1
local previousGameState = -1

playfield.initialize()
frameManager.update(0, 0)

function loop()
    local gameState = getGameState()
    local pieceState = getPieceState()
    local time = socket.gettime()*1000

    local newFrame = false
    local resendFrame = false

    if gameState == 4 then --ingame, rocket, highscoreentry
        if previousGameState ~= 4 then -- just started a game!
            newGameStarted()
        end

        if pieceState == 1 then -- piece active
            local stateChanged = false

            if previousPieceState == 8 then -- line clear done
                playfield.invalidate()
                stateChanged = true
            end

            -- check if the state changed!
            -- ways the state can change in pieceState 1:
            --     pieceX or pieceY changed (movement)
            --     currentPiece changes (rotation, piece entry)

            local pieceX, pieceY = getCurrentPosition()
            local pieceID = getCurrentPiece()

            if pieceX ~= state.pieceX or pieceY ~= state.pieceY or pieceID ~= state.pieceID then
                stateChanged = true
            end

            if stateChanged then
                newFrame = true
                playfield.invalidate()
                playfield.update()

                -- update state cache
                state.pieceX = pieceX
                state.pieceY = pieceY
                state.pieceID = pieceID
            end

        elseif pieceState == 4 or pieceState == 6 then -- line clear
            if pieceState == 4 and previousPieceState ~= 4 then -- line clear go brrr
                playfield.lineClearAnimation(getLinesBeingCleared())
            end

            if playfield.lineClearUpdate() then
                newFrame = true
            end

        elseif pieceState == 5 then -- dummy frame, but we're abusing it for score update.
            newFrame = true

        elseif pieceState  == 10 then -- curtain + rocket
            if previousPieceState ~= 10 then
                playfield.curtainNum = 0
            end

            if playfield.curtainUpdate() then
                playfield.invalidate()
                playfield.update()
                newFrame = true
            end

        end
    end



    -- send a frame every 5 seconds no matter what, to stop the connection from dying
    if time - lastFrame >= 5000 then -- 5 seconds
        resendFrame = true
    end
	local tryReconnect = false

    if (newFrame or resendFrame) then
		if conn then
			local ms = math.floor(time - startTime)

			if newFrame then
				frameManager.update(ms, gameNo)
				log("Sending new frame (" .. ms .. ")")
			elseif resendFrame then
				log("Resending an old frame.")
			end

			local success = wssend(conn, 2, frameManager.frame)
			--todo: something if not success (reconnect? hcf?)
			
			if not success then
				print("could not send frame data")
				tryReconnect = true
			end

			lastFrame = time
		else
			tryReconnect = true
		end
    end
	
	if tryReconnect then
		reconnect()
	end
	
    previousPieceState = pieceState
    previousGameState = gameState
end

onLoad()
