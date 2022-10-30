function onLoad()
    if EASYCONNECT then
		connectImproved(
			DEFAULTURL or "",
			DEFAULTSECRET or "",
			DEFAULTEASYCONNECT or "")
	else
		connect(DEFAULTURL, DEFAULTSECRET)
	end

    while true do -- main loop
        loop()
	    emu.frameadvance()
    end
end
