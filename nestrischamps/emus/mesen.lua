memory = {}

function memory.readbyte(address)
    return emu.read(address, emu.memType.cpuDebug)
end

function memory.readbyterange(address, bytes)
    local str = ""
    for i = 0, bytes - 1 do
        local chr = string.char(memory.readbyte(address + i))
        str = str .. chr
    end
    return str
end

function print(...)
    emu.log(...)
end

function onLoad()
    if EASYCONNECT then
		connectImproved(
			DEFAULTURL or "",
			DEFAULTSECRET or "",
			DEFAULTEASYCONNECT or "")
	else
		connect(DEFAULTURL, DEFAULTSECRET)
	end

    emu.addEventCallback(loop, emu.eventType.endFrame) -- main loop
end
