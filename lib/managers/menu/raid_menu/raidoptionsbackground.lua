RaidOptionsBackground = RaidOptionsBackground or class(RaidGuiBase)

-- Lines 4-7
function RaidOptionsBackground:init(ws, fullscreen_ws, node, component_name)
	RaidOptionsBackground.super.init(self, ws, fullscreen_ws, node, component_name)
	Application:debug("[RaidOptionsBackground:init]  ", inspect(self._background))
end
