RaidGUIControlScrollbar = RaidGUIControlScrollbar or class(RaidGUIControl)
RaidGUIControlScrollbar.SCROLLBAR_WIDTH = 5

-- Lines 5-14
function RaidGUIControlScrollbar:init(parent, params)
	RaidGUIControlScrollbar.super.init(self, parent, params)

	self._object = self._parent:panel(params)
	self._scrollbar_rect = self._object:rect({
		color = tweak_data.gui.colors.raid_dark_grey
	})
end

-- Lines 16-19
function RaidGUIControlScrollbar:close()
	RaidGUIControlScrollbar.super.close()

	self._dragging = false
end

-- Lines 21-23
function RaidGUIControlScrollbar:set_y(y)
	self._object:set_y(y)
end

-- Lines 25-29
function RaidGUIControlScrollbar:set_scroller_path_height()
	self._scroller_path_height = self._params.scroll_outer_panel:h() - self._object:bottom()
	self._scroller_path_start = self._object:bottom()
end

-- Lines 34-38
function RaidGUIControlScrollbar:mouse_moved(o, x, y)
	RaidGUIControlScrollbar.super.mouse_moved(self, o, x, y)
end

-- Lines 40-60
function RaidGUIControlScrollbar:on_mouse_moved(o, x, y)
	if not self._dragging then
		return
	end

	if not self._last_y then
		self._last_y = y
	end

	local dy = y - self._last_y
	self._last_y = self._last_y + dy

	self:set_bottom_by_y_coord(math.floor(dy))
end

-- Lines 62-67
function RaidGUIControlScrollbar:on_mouse_out()
	self._pointer_type = "link"
	self._dragging = false
end

-- Lines 70-75
function RaidGUIControlScrollbar:on_mouse_pressed()
	self._old_active_control = managers.raid_menu:get_active_control()

	managers.raid_menu:set_active_control(self)

	self._dragging = true
end

-- Lines 78-84
function RaidGUIControlScrollbar:on_mouse_released()
	managers.raid_menu:set_active_control(self._old_active_control)

	self._dragging = false

	return true
end

-- Lines 86-104
function RaidGUIControlScrollbar:set_bottom_by_y_coord(dy)
	self._object:set_y(self._object:y() + dy)

	if self._params.scroll_outer_panel:h() < self._object:bottom() then
		self._object:set_bottom(self._params.scroll_outer_panel:h())
	end

	if self._object:top() < 0 then
		self._object:set_top(0)
	end

	local scroller_bottom_position = self._object:bottom()
	local scroller_current_path_percentage = (scroller_bottom_position - self._scroller_path_start) / self._scroller_path_height

	self._params.scroll_inner_panel:set_y((self._params.scroll_outer_panel:h() - self._params.scroll_inner_panel:h()) * scroller_current_path_percentage)
end
