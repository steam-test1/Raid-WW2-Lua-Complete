require("core/lib/setups/CoreLoadingSetup")
require("lib/utils/LevelLoadingScreenGuiScript")
require("lib/managers/menu/MenuBackdropGUI")
require("core/lib/managers/CoreGuiDataManager")
require("core/lib/utils/CoreMath")
require("core/lib/utils/CoreEvent")

LevelLoadingSetup = LevelLoadingSetup or class(CoreLoadingSetup)

-- Lines 10-11
function LevelLoadingSetup:init()
end

-- Lines 13-14
function LevelLoadingSetup:update(t, dt)
end

-- Lines 16-18
function LevelLoadingSetup:destroy()
	LevelLoadingSetup.super.destroy(self)
end

setup = setup or LevelLoadingSetup:new()

setup:make_entrypoint()
