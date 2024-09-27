RaidGUIControlScrollbar = RaidGUIControlScrollbar or class(RaidGUIControl)
RaidGUIControlScrollbar.SCROLLBAR_WIDTH = 10
RaidGUIControlScrollbar.SCROLLBAR_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlScrollbar.SCROLLBAR_HIGHLIGHT_COLOR = Color.white
RaidGUIControlScrollbar.SCROLLBAR_BACKGROUND_COLOR = tweak_data.gui.colors.progress_bar_dot
RaidGUIControlScrollbar.SCROLLBAR_BACKGROUND_ALPHA = 0.8

function RaidGUIControlScrollbar:init(parent, params)
	RaidGUIControlScrollbar.super.init(self, parent, params)

	self._object = self._parent:panel(params)
	self._scrollbar_rect = self._object:rect({
		color = nil,
		color = RaidGUIControlScrollbar.SCROLLBAR_COLOR
	})
	self._scrollbar_bg = self._parent:rect({
		alpha = nil,
		w = nil,
		color = nil,
		name = "scrollbar_bg",
		w = self._scrollbar_rect:w() * 0.6,
		color = RaidGUIControlScrollbar.SCROLLBAR_BACKGROUND_COLOR,
		alpha = RaidGUIControlScrollbar.SCROLLBAR_BACKGROUND_ALPHA
	})

	self._scrollbar_bg:set_center_x(self._object:center_x())
end

function RaidGUIControlScrollbar:show()
	self._scrollbar_bg:show()
	RaidGUIControlScrollbar.super.show(self)
end

function RaidGUIControlScrollbar:hide()
	self._scrollbar_bg:hide()
	RaidGUIControlScrollbar.super.hide(self)
end

function RaidGUIControlScrollbar:close()
	RaidGUIControlScrollbar.super.close()

	self._dragging = false
end

function RaidGUIControlScrollbar:set_y(y)
	self._object:set_y(y)
end

function RaidGUIControlScrollbar:set_scroller_path_height()
	self._scroller_path_height = self._params.scroll_outer_panel:h() - self._object:bottom()
	self._scroller_path_start = self._object:bottom()
end

function RaidGUIControlScrollbar:mouse_moved(o, x, y)
	RaidGUIControlScrollbar.super.mouse_moved(self, o, x, y)
end

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

function RaidGUIControlScrollbar:highlight_on()
	self._highlighted = true

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight"))
end

function RaidGUIControlScrollbar:highlight_off()
	self._highlighted = false

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight"))
end

function RaidGUIControlScrollbar:on_mouse_over(x, y)
	self._mouse_inside = true

	self:highlight_on()
end

function RaidGUIControlScrollbar:on_mouse_out()
	self._mouse_inside = false

	self:highlight_off()

	self._pointer_type = "link"
	self._dragging = false
end

function RaidGUIControlScrollbar:on_mouse_pressed(o, x, y)
	self._old_active_control = managers.raid_menu:get_active_control()

	managers.raid_menu:set_active_control(self)

	self._last_y = y
	self._dragging = true
end

function RaidGUIControlScrollbar:on_mouse_released()
	managers.raid_menu:set_active_control(self._old_active_control)

	self._dragging = false

	return true
end

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
	local new_y = (self._params.scroll_outer_panel:h() - self._params.scroll_inner_panel:h()) * scroller_current_path_percentage

	self._params.scroll_inner_panel:set_y(math.round(new_y))
end

function RaidGUIControlScrollbar:_animate_highlight()
	local color_start = self._highlighted and RaidGUIControlScrollbar.SCROLLBAR_COLOR or RaidGUIControlScrollbar.SCROLLBAR_HIGHLIGHT_COLOR
	local color_end = self._highlighted and RaidGUIControlScrollbar.SCROLLBAR_HIGHLIGHT_COLOR or RaidGUIControlScrollbar.SCROLLBAR_COLOR
	local t = 0
	local duration = 0.15

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in_out(t, 0, 1, duration)
		local current_color = math.lerp(color_start, color_end, progress)

		self._scrollbar_rect:set_color(current_color)
	end

	self._scrollbar_rect:set_color(color_end)
end
