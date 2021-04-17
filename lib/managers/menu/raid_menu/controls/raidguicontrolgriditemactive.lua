RaidGUIControlGridItemActive = RaidGUIControlGridItemActive or class(RaidGUIControlGridItem)

-- Lines 3-5
function RaidGUIControlGridItemActive:init(parent, params, item_data, grid_params)
	RaidGUIControlGridItemActive.super.init(self, parent, params, item_data, grid_params)
end

-- Lines 7-9
function RaidGUIControlGridItemActive:active()
	return self._active
end

-- Lines 11-16
function RaidGUIControlGridItemActive:activate()
	self._active = true

	self._triangle_markers_panel:show()
end

-- Lines 18-23
function RaidGUIControlGridItemActive:deactivate()
	self._active = false

	self._triangle_markers_panel:hide()
end

-- Lines 25-28
function RaidGUIControlGridItemActive:select_on()
	self._select_background_panel:show()
end

-- Lines 30-33
function RaidGUIControlGridItemActive:select_off()
	self._select_background_panel:hide()
end
