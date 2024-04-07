require("core/lib/setups/CoreLoadingSetup")
require("lib/utils/LevelLoadingScreenGuiScript")
require("lib/managers/menu/MenuBackdropGUI")
require("core/lib/managers/CoreGuiDataManager")
require("core/lib/utils/CoreMath")
require("core/lib/utils/CoreEvent")

LevelLoadingSetup = LevelLoadingSetup or class(CoreLoadingSetup)

function LevelLoadingSetup:init()
	return
end

function LevelLoadingSetup:update(t, dt)
	return
end

function LevelLoadingSetup:destroy()
	LevelLoadingSetup.super.destroy(self)
end

setup = setup or LevelLoadingSetup:new()

setup:make_entrypoint()
