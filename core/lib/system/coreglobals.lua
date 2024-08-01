-- Lines 8-10
local function GLOBAL(key, value)
	core:_add_to_pristine_and_global(key, value)
end

-- Lines 12-16
local function GLOBAL_PLATFORM(key, platform)
	local value = PLATFORM == Idstring(platform)

	GLOBAL(key, value)
end

if not __globals_declared then
	GLOBAL("IDS_UNIT", Idstring("unit"))
	GLOBAL("IDS_MATERIAL", Idstring("material"))
	GLOBAL("PLATFORM", SystemInfo:platform())
	GLOBAL_PLATFORM("IS_WIN32", "WIN32")
	GLOBAL_PLATFORM("IS_XB1", "XB1")
	GLOBAL_PLATFORM("IS_PS4", "PS4")
	GLOBAL("IS_PC", IS_WIN32)
	GLOBAL("IS_CONSOLE", IS_PS4 or IS_XB1)
	GLOBAL("DISTRIBUTION", SystemInfo:distribution())
	GLOBAL("IS_STEAM", DISTRIBUTION == Idstring("STEAM"))

	__globals_declared = true
end
