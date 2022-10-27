require("iuplua")
local dialog

function createDialog()
    local defaultUrl = DEFAULTURL or "ws://nestrischamps.io/ws/room/producer"
    local defaultSecret = DEFAULTSECRET or ""

    local urlInput = iup.text{size="400x",value=defaultUrl}
    local secretInput = iup.text{size="400x",value=defaultSecret}

	local defaultEasyConnect = "v=1"
	if (defaultSecret == "") then
		defaultEasyConnect = ""
	end
	
    if EASYCONNECT then
		defaultEasyConnect = DEFAULTEASYCONNECT
	end
	local easyInput = iup.text{size="400x",value=defaultEasyConnect}

    local function closeDialog()
        if dialog then
            dialog:destroy()
            dialog = nil
        end
    end

    local function onConnect()
        local url = urlInput.value
        local secret = secretInput.value

        closeDialog()

        connect(url, secret)
    end

    local function onEasyConnect()
        local url = urlInput.value
        local secret = secretInput.value
		local easy = easyInput.value

        closeDialog()

        connectImproved(url, secret, easy)
    end
	
    -- close the dialog when the script ends
    emu.registerexit(closeDialog)

    if EASYCONNECT then
		dialog =
			iup.dialog{
				title="NestrisChamps config",
				iup.vbox{
					iup.hbox{
						iup.vbox{
							iup.label{title="Easy Connect Info"},
							easyInput,
							iup.button{
								title="Use EasyConnect",
								action = function (self)
									onEasyConnect()
								end
							}
						}
					},
					gap="5",
					alignment="ARIGHT",
					margin="5x5"
				} -- /vbox
			}
	else
		dialog =
			iup.dialog{
				title="NestrisChamps config",
				iup.vbox{
					iup.hbox{
						iup.vbox{
							iup.label{title="Websocket URL (no ssl)"},
							urlInput,
							iup.label{title="Secret"},
							secretInput,
							iup.button{
								title="Connect!",
								action = function (self)
									onConnect()
								end
							},
							iup.fill{size="20x20"},
							iup.label{title="Easy Connect Info"},
							easyInput,
							iup.button{
								title="Use EasyConnect",
								action = function (self)
									onEasyConnect()
								end
							}
						}
					},
					gap="5",
					alignment="ARIGHT",
					margin="5x5"
				} -- /vbox
			}	
	end

    dialog:show()
end

function onLoad()
    if AUTOCONNECT then
        connect(DEFAULTURL, DEFAULTSECRET)
    else
        createDialog()
    end

    while true do -- main loop
        loop()
	    emu.frameadvance()
    end
end
