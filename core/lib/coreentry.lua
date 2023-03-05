_G.IS_XB360 = SystemInfo:platform() == Idstring("X360")
_G.IS_XB1 = SystemInfo:platform() == Idstring("XB1")
_G.IS_PS3 = SystemInfo:platform() == Idstring("PS3")
_G.IS_PS4 = SystemInfo:platform() == Idstring("PS4")
_G.IS_CONSOLE = _G.IS_XB360 or _G.IS_XB1 or _G.IS_PS3 or _G.IS_PS4
_G.IS_PC = not _G.IS_CONSOLE
_G.IS_WIN32 = _G.IS_PC

require("core/lib/system/CoreSystem")

if table.contains(Application:argv(), "-slave") then
	require("core/lib/setups/CoreSlaveSetup")
else
	require("lib/Entry")
end
