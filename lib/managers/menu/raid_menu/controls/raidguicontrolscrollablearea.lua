RaidGUIControlScrollableArea = RaidGUIControlScrollableArea or class(RaidGUIControl)
RaidGUIControlScrollableArea.SCROLLBAR_WIDTH = 5

-- Lines 5-38
function RaidGUIControlScrollableArea:init(parent, params)
	RaidGUIControlScrollableArea.super.init(self, parent, params)

	self._scroll_step = params.scroll_step
	local outer_panel_params = clone(self._params)
	outer_panel_params.name = outer_panel_params.name .. "_outer"
	self._object = self._panel:panel(outer_panel_params)
	local scrollbar_x_offset = self._params.scrollbar_offset or 0
	local inner_panel_params = clone(self._params)
	inner_panel_params.name = inner_panel_params.name .. "_inner"
	inner_panel_params.w = self._object:w() - RaidGUIControlScrollableArea.SCROLLBAR_WIDTH - scrollbar_x_offset
	inner_panel_params.scrollable = nil
	inner_panel_params.scroll_step = nil
	inner_panel_params.x = 0
	inner_panel_params.y = 0
	self._inner_panel = self._object:panel(inner_panel_params)
	local scrollbar_params = clone(self._params)
	scrollbar_params.x = inner_panel_params.w + scrollbar_x_offset
	scrollbar_params.y = 0
	scrollbar_params.w = self._params.scrollbar_width or RaidGUIControlScrollableArea.SCROLLBAR_WIDTH
	scrollbar_params.color = tweak_data.gui.colors.raid_dark_grey
	scrollbar_params.scrollable = nil
	scrollbar_params.scroll_step = nil
	scrollbar_params.name = inner_panel_params.name .. "_scrollbar"
	scrollbar_params.scroll_outer_panel = self._object
	scrollbar_params.scroll_inner_panel = self._inner_panel
	self._scrollbar = self._object:scrollbar(scrollbar_params)
end

-- Lines 40-42
function RaidGUIControlScrollableArea:get_panel()
	return self._inner_panel
end

-- Lines 44-69
function RaidGUIControlScrollableArea:setup_scroll_area()
	self._inner_panel:set_y(0)
	self._inner_panel:fit_content_height()

	if self._object:h() < self._inner_panel:h() then
		self._scrolling_enabled = true

		self._scrollbar:show()
		self._scrollbar:set_y(0)

		local scrollbar_h = self._object:h() * self._object:h() / self._inner_panel:h()

		self._scrollbar:set_h(scrollbar_h)
		self._scrollbar:set_scroller_path_height()
	else
		self._scrolling_enabled = false

		self._scrollbar:hide()
	end

	if self._inner_panel._controls then
		for control_index, control in pairs(self._inner_panel._controls) do
			control:scrollable_area_post_setup()
		end
	end
end

-- Lines 72-79
function RaidGUIControlScrollableArea:move_scrollbar_manually()
	local new_y = self._inner_panel:y()
	local ep_h = self._inner_panel:h()

	self._inner_panel:set_y(new_y)

	local scroll_y = self._object:h() * -new_y / ep_h

	self._scrollbar:set_y(scroll_y)
end

-- Lines 81-95
function RaidGUIControlScrollableArea:mouse_scroll_up(o, button, x, y)
	if self._scrolling_enabled then
		local ep_h = self._inner_panel:h()
		local top_clip_y = -self._inner_panel:y()
		local scroll_move = math.clamp(top_clip_y, 0, self._scroll_step)
		local new_y = self._inner_panel:y() + scroll_move

		self._inner_panel:set_y(new_y)

		local scroll_y = self._object:h() * -new_y / ep_h

		self._scrollbar:set_y(scroll_y)

		return
	end

	return self._inner_panel:mouse_scroll_up(o, button, x, y)
end

-- Lines 97-113
function RaidGUIControlScrollableArea:mouse_scroll_down(o, button, x, y)
	if self._scrolling_enabled then
		local ep_y = self._inner_panel:y()
		local ep_h = self._inner_panel:h()
		local s_h = self._object:h()
		local bottom_clip_y = self._inner_panel:y() + self._inner_panel:h() - self._object:h()
		local scroll_move = math.clamp(bottom_clip_y, 0, self._scroll_step)
		local new_y = self._inner_panel:y() - scroll_move

		self._inner_panel:set_y(new_y)

		local scroll_y = self._object:h() * -new_y / ep_h

		self._scrollbar:set_y(scroll_y)

		return
	end

	return self._inner_panel:mouse_scroll_down(o, button, x, y)
end

-- Lines 115-129
function RaidGUIControlScrollableArea:scroll_up()
	if self._scrolling_enabled then
		local ep_h = self._inner_panel:h()
		local top_clip_y = -self._inner_panel:y()
		local scroll_move = math.clamp(top_clip_y, 0, self._scroll_step)
		local new_y = self._inner_panel:y() + scroll_move

		self._inner_panel:set_y(new_y)

		local scroll_y = self._object:h() * -new_y / ep_h

		self._scrollbar:set_y(scroll_y)

		return
	end
end

-- Lines 131-147
function RaidGUIControlScrollableArea:scroll_down()
	if self._scrolling_enabled then
		local ep_y = self._inner_panel:y()
		local ep_h = self._inner_panel:h()
		local s_h = self._object:h()
		local bottom_clip_y = self._inner_panel:y() + self._inner_panel:h() - self._object:h()
		local scroll_move = math.clamp(bottom_clip_y, 0, self._scroll_step)
		local new_y = self._inner_panel:y() - scroll_move

		self._inner_panel:set_y(new_y)

		local scroll_y = self._object:h() * -new_y / ep_h

		self._scrollbar:set_y(scroll_y)

		return
	end
end

-- Lines 150-151
function RaidGUIControlScrollableArea:highlight_on()
end

-- Lines 153-154
function RaidGUIControlScrollableArea:highlight_off()
end
