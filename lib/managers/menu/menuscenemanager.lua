MenuSceneManager = MenuSceneManager or class()

-- Lines 3-5
function MenuSceneManager:init()
	self._fullscreen_workspace = managers.gui_data:create_fullscreen_workspace()
end
