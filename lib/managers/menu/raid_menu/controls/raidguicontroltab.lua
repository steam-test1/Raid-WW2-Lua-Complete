RaidGUIControlTab = RaidGUIControlTab or class(RaidGUIControl)
RaidGUIControlTab.PADDING = 16
RaidGUIControlTab.INACTIVE_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlTab.ACTIVE_LINE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlTab.ACTIVE_TEXT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlTab.BOTTOM_LINE_NORMAL_HEIGHT = 2
RaidGUIControlTab.BOTTOM_LINE_ACTIVE_HEIGHT = 5
RaidGUIControlTab.BOTTOM_LINE_INACTIVE_ALPHA = 0.25
RaidGUIControlTab.BOTTOM_LINE_ACTIVE_ALPHA = 1

-- Lines 12-47
function RaidGUIControlTab:init(parent, params)
	RaidGUIControlTab.super.init(self, parent, params)

	self._object = parent:panel({
		name = "tab_panel_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h,
		layer = parent:layer() + 1
	})
	local label_coord_x = 0
	local label_width = params.w

	if params.icon then
		self._tab_icon = self._object:image({
			vertical = "center",
			y = 0,
			name = "tab_control_icon_" .. self._name,
			x = RaidGUIControlTab.PADDING,
			w = params.icon.texture_rect[3],
			h = params.icon.texture_rect[4],
			texture = params.icon.texture,
			texture_rect = params.icon.texture_rect,
			color = RaidGUIControlTab.INACTIVE_COLOR,
			layer = self._object:layer() + 1
		})
		label_coord_x = self._tab_icon:x() + self._tab_icon:w() + RaidGUIControlTab.PADDING
		label_width = label_width - self._tab_icon:w() - 2 * RaidGUIControlTab.PADDING
	end

	self._tab_label = self._object:label({
		vertical = "center",
		y = 0,
		name = "tab_control_label_" .. self._name,
		x = label_coord_x,
		w = label_width,
		h = params.h,
		text = params.text,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = self._params.tab_font_size or tweak_data.gui.font_sizes.large,
		color = RaidGUIControlTab.INACTIVE_COLOR,
		layer = self._object:layer() + 1
	})

	if params.tab_align then
		self._tab_label:set_align(params.tab_align)
	end

	self._callback_param = params.callback_param
	self._tab_select_callback = params.tab_select_callback
	self._bottom_line = self._object:rect({
		name = "tab_control_bottom_line",
		x = 0,
		y = params.h - RaidGUIControlTab.BOTTOM_LINE_NORMAL_HEIGHT,
		w = params.w,
		h = RaidGUIControlTab.BOTTOM_LINE_NORMAL_HEIGHT,
		color = RaidGUIControlTab.INACTIVE_COLOR
	})

	self._bottom_line:set_alpha(RaidGUIControlTab.BOTTOM_LINE_INACTIVE_ALPHA)

	self._selected = false
	self._highlight_t = 0
	self._select_t = 0

	if params.breadcrumb then
		self:_layout_breadcrumb()
	end
end

-- Lines 49-54
function RaidGUIControlTab:_layout_breadcrumb()
	self._params.breadcrumb.padding = 0
	self._breadcrumb = self._object:breadcrumb(self._params.breadcrumb)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

-- Lines 56-58
function RaidGUIControlTab:needs_divider()
	return false
end

-- Lines 60-62
function RaidGUIControlTab:needs_bottom_line()
	return true
end

-- Lines 64-66
function RaidGUIControlTab:get_callback_param()
	return self._callback_param
end

-- Lines 68-74
function RaidGUIControlTab:highlight_on()
	self._bottom_line:stop()
	self._bottom_line:animate(callback(self, self, "_animate_highlight_on"))
end

-- Lines 76-84
function RaidGUIControlTab:highlight_off()
	if not self._selected then
		self._bottom_line:stop()
		self._bottom_line:animate(callback(self, self, "_animate_highlight_off"))
	end
end

-- Lines 86-104
function RaidGUIControlTab:select()
	self._tab_label._object:stop()
	self._tab_label._object:animate(callback(self, self, "_animate_select"))
	self._bottom_line:set_color(RaidGUIControlTab.ACTIVE_LINE_COLOR)
	self._bottom_line:set_alpha(RaidGUIControlTab.BOTTOM_LINE_ACTIVE_ALPHA)

	self._selected = true
end

-- Lines 106-124
function RaidGUIControlTab:unselect()
	self._tab_label._object:stop()
	self._tab_label._object:animate(callback(self, self, "_animate_deselect"))
	self._bottom_line:set_color(RaidGUIControlTab.INACTIVE_COLOR)
	self._bottom_line:set_alpha(RaidGUIControlTab.BOTTOM_LINE_INACTIVE_ALPHA)

	self._selected = false
end

-- Lines 126-129
function RaidGUIControlTab:mouse_released(o, button, x, y)
	self:on_mouse_released(button, x, y)

	return true
end

-- Lines 131-138
function RaidGUIControlTab:on_mouse_released(button, x, y)
	if self._params.tab_select_callback then
		self._params.tab_select_callback(self._params.tab_idx, self._callback_param)
	end

	return true
end

-- Lines 142-164
function RaidGUIControlTab:_animate_highlight_on()
	local duration = 0.3
	local t = duration - (1 - self._highlight_t) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local color_r = Easing.quartic_out(t, RaidGUIControlTab.INACTIVE_COLOR.r, RaidGUIControlTab.ACTIVE_LINE_COLOR.r - RaidGUIControlTab.INACTIVE_COLOR.r, duration)
		local color_g = Easing.quartic_out(t, RaidGUIControlTab.INACTIVE_COLOR.g, RaidGUIControlTab.ACTIVE_LINE_COLOR.g - RaidGUIControlTab.INACTIVE_COLOR.g, duration)
		local color_b = Easing.quartic_out(t, RaidGUIControlTab.INACTIVE_COLOR.b, RaidGUIControlTab.ACTIVE_LINE_COLOR.b - RaidGUIControlTab.INACTIVE_COLOR.b, duration)
		local current_alpha = Easing.quartic_out(t, RaidGUIControlTab.BOTTOM_LINE_INACTIVE_ALPHA, RaidGUIControlTab.BOTTOM_LINE_ACTIVE_ALPHA - RaidGUIControlTab.BOTTOM_LINE_INACTIVE_ALPHA, duration)

		self._bottom_line:set_color(Color(color_r, color_g, color_b))
		self._bottom_line:set_alpha(current_alpha)

		self._highlight_t = t / duration
	end

	self._bottom_line:set_color(RaidGUIControlTab.ACTIVE_LINE_COLOR)
	self._bottom_line:set_alpha(RaidGUIControlTab.BOTTOM_LINE_ACTIVE_ALPHA)

	self._highlight_t = 1
end

-- Lines 166-188
function RaidGUIControlTab:_animate_highlight_off()
	local duration = 0.2
	local t = duration - self._highlight_t * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local color_r = Easing.quartic_in(t, RaidGUIControlTab.ACTIVE_LINE_COLOR.r, RaidGUIControlTab.INACTIVE_COLOR.r - RaidGUIControlTab.ACTIVE_LINE_COLOR.r, duration)
		local color_g = Easing.quartic_in(t, RaidGUIControlTab.ACTIVE_LINE_COLOR.g, RaidGUIControlTab.INACTIVE_COLOR.g - RaidGUIControlTab.ACTIVE_LINE_COLOR.g, duration)
		local color_b = Easing.quartic_in(t, RaidGUIControlTab.ACTIVE_LINE_COLOR.b, RaidGUIControlTab.INACTIVE_COLOR.b - RaidGUIControlTab.ACTIVE_LINE_COLOR.b, duration)
		local current_alpha = Easing.quartic_in(t, RaidGUIControlTab.BOTTOM_LINE_ACTIVE_ALPHA, RaidGUIControlTab.BOTTOM_LINE_INACTIVE_ALPHA - RaidGUIControlTab.BOTTOM_LINE_ACTIVE_ALPHA, duration)

		self._bottom_line:set_color(Color(color_r, color_g, color_b))
		self._bottom_line:set_alpha(current_alpha)

		self._highlight_t = 1 - t / duration
	end

	self._bottom_line:set_color(RaidGUIControlTab.INACTIVE_COLOR)
	self._bottom_line:set_alpha(RaidGUIControlTab.BOTTOM_LINE_INACTIVE_ALPHA)

	self._highlight_t = 0
end

-- Lines 190-215
function RaidGUIControlTab:_animate_select()
	local duration = 0.3
	local t = duration - (1 - self._select_t) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local color_r = Easing.quartic_out(t, RaidGUIControlTab.INACTIVE_COLOR.r, RaidGUIControlTab.ACTIVE_TEXT_COLOR.r - RaidGUIControlTab.INACTIVE_COLOR.r, duration)
		local color_g = Easing.quartic_out(t, RaidGUIControlTab.INACTIVE_COLOR.g, RaidGUIControlTab.ACTIVE_TEXT_COLOR.g - RaidGUIControlTab.INACTIVE_COLOR.g, duration)
		local color_b = Easing.quartic_out(t, RaidGUIControlTab.INACTIVE_COLOR.b, RaidGUIControlTab.ACTIVE_TEXT_COLOR.b - RaidGUIControlTab.INACTIVE_COLOR.b, duration)

		if self._tab_icon then
			self._tab_icon:set_color(Color(color_r, color_g, color_b))
		end

		self._tab_label:set_color(Color(color_r, color_g, color_b))

		self._select_t = t / duration
	end

	if self._tab_icon then
		self._tab_icon:set_color(RaidGUIControlTab.ACTIVE_TEXT_COLOR)
	end

	self._tab_label:set_color(RaidGUIControlTab.ACTIVE_TEXT_COLOR)

	self._select_t = 1
end

-- Lines 217-242
function RaidGUIControlTab:_animate_deselect()
	local duration = 0.3
	local t = duration - self._select_t * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local color_r = Easing.quartic_out(t, RaidGUIControlTab.ACTIVE_TEXT_COLOR.r, RaidGUIControlTab.INACTIVE_COLOR.r - RaidGUIControlTab.ACTIVE_TEXT_COLOR.r, duration)
		local color_g = Easing.quartic_out(t, RaidGUIControlTab.ACTIVE_TEXT_COLOR.g, RaidGUIControlTab.INACTIVE_COLOR.g - RaidGUIControlTab.ACTIVE_TEXT_COLOR.g, duration)
		local color_b = Easing.quartic_out(t, RaidGUIControlTab.ACTIVE_TEXT_COLOR.b, RaidGUIControlTab.INACTIVE_COLOR.b - RaidGUIControlTab.ACTIVE_TEXT_COLOR.b, duration)

		if self._tab_icon then
			self._tab_icon:set_color(Color(color_r, color_g, color_b))
		end

		self._tab_label:set_color(Color(color_r, color_g, color_b))

		self._select_t = 1 - t / duration
	end

	if self._tab_icon then
		self._tab_icon:set_color(RaidGUIControlTab.INACTIVE_COLOR)
	end

	self._tab_label:set_color(RaidGUIControlTab.INACTIVE_COLOR)

	self._select_t = 0
end
