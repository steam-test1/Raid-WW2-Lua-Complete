RaidGUIControlButtonToggle = RaidGUIControlButtonToggle or class(RaidGUIControl)
RaidGUIControlButtonToggle.HEIGHT = 32
RaidGUIControlButtonToggle.TEXT_PADDING = 16
RaidGUIControlButtonToggle.TEXT_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlButtonToggle.TEXT_COLOR_DISABLED = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlButtonToggle.SIDELINE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlButtonToggle.SIDELINE_W = 3
RaidGUIControlButtonToggle.BORDER_ICON = "checkbox_base"
RaidGUIControlButtonToggle.W = tweak_data.gui.icons[RaidGUIControlButtonToggle.BORDER_ICON].texture_rect[3]
RaidGUIControlButtonToggle.H = tweak_data.gui.icons[RaidGUIControlButtonToggle.BORDER_ICON].texture_rect[4]
RaidGUIControlButtonToggle.BORDER_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlButtonToggle.BORDER_HOVER_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlButtonToggle.CHECK_ICON = "checkbox_check_base"
RaidGUIControlButtonToggle.CHECK_W = tweak_data.gui.icons[RaidGUIControlButtonToggle.CHECK_ICON].texture_rect[3]
RaidGUIControlButtonToggle.CHECK_H = tweak_data.gui.icons[RaidGUIControlButtonToggle.CHECK_ICON].texture_rect[4]

-- Lines 22-90
function RaidGUIControlButtonToggle:init(parent, params)
	RaidGUIControlButtonToggle.super.init(self, parent, params)

	self._params.w = self._params.w or self._panel:w()
	self._params.h = RaidGUIControlButtonToggle.H
	self._object = self._panel:panel(self._params)
	local sideline_params = {
		alpha = 0,
		y = 0,
		x = 0,
		w = RaidGUIControlButtonToggle.SIDELINE_W,
		h = self._object:h(),
		color = RaidGUIControlButtonToggle.SIDELINE_COLOR
	}
	self._sideline = self._object:rect(sideline_params)
	self._description = self._object:text({
		vertical = "center",
		align = "left",
		y = 0,
		x = RaidGUIControlButtonToggle.SIDELINE_W + RaidGUIControlButtonToggle.TEXT_PADDING,
		w = self._object:w() - RaidGUIControlButtonToggle.SIDELINE_W - RaidGUIControlButtonToggle.TEXT_PADDING * 2,
		h = self._object:h(),
		color = RaidGUIControlButtonToggle.TEXT_COLOR,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		text = params.description,
		layer = self._object:layer() + 1
	})
	local checkbox_panel_params = {
		x = self._object:w() - RaidGUIControlButtonToggle.W,
		y = self._object:h() / 2 - RaidGUIControlButtonToggle.H / 2,
		w = RaidGUIControlButtonToggle.W,
		h = RaidGUIControlButtonToggle.H
	}
	self._checkbox_panel = self._object:panel(checkbox_panel_params)
	local checkbox_border_params = {
		halign = "scale",
		valign = "scale",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlButtonToggle.BORDER_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlButtonToggle.BORDER_ICON].texture_rect,
		w = RaidGUIControlButtonToggle.W,
		h = RaidGUIControlButtonToggle.H,
		layer = self._object:layer(),
		color = RaidGUIControlButtonToggle.BORDER_COLOR
	}
	self._border = self._checkbox_panel:bitmap(checkbox_border_params)
	local checkbox_params = {
		halign = "scale",
		valign = "scale",
		texture = tweak_data.gui.icons[RaidGUIControlButtonToggle.CHECK_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlButtonToggle.CHECK_ICON].texture_rect,
		x = self._checkbox_panel:w() / 2 - RaidGUIControlButtonToggle.CHECK_W / 2,
		y = self._checkbox_panel:h() / 2 - RaidGUIControlButtonToggle.CHECK_H / 2,
		w = RaidGUIControlButtonToggle.CHECK_W,
		h = RaidGUIControlButtonToggle.CHECK_H,
		layer = self._object:layer() + 1
	}
	self._check = self._checkbox_panel:bitmap(checkbox_params)
	self._value = self._params.value or false
	self._play_mouse_over_sound = true
	self._on_click_callback = params.on_click_callback
	self._visible = self._params.visible

	self:_render_images()
end

-- Lines 92-105
function RaidGUIControlButtonToggle:highlight_on()
	self._highlighted = true

	if not self._enabled then
		return
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_on"))

	if self._play_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._play_mouse_over_sound = false
	end
end

-- Lines 108-118
function RaidGUIControlButtonToggle:highlight_off()
	self._highlighted = false

	if not self._enabled then
		return
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_off"))

	self._play_mouse_over_sound = true
end

-- Lines 120-129
function RaidGUIControlButtonToggle:mouse_pressed(o, button, x, y)
	if not self._enabled then
		return
	end

	if self:inside(x, y) then
		self._checkbox_panel:stop()
		self._checkbox_panel:animate(callback(self, self, "_animate_checkbox_press"))
	end
end

-- Lines 131-154
function RaidGUIControlButtonToggle:mouse_released(o, button, x, y)
	if not self._enabled then
		return
	end

	if self:inside(x, y) then
		if self._value then
			self._value = false
		else
			self._value = true
		end

		self._checkbox_panel:stop()
		self._checkbox_panel:animate(callback(self, self, "_animate_checkbox_release"))
		self:_render_images()

		if self._on_click_callback then
			self._on_click_callback(button, self, self._value)
		end

		return true
	else
		return false
	end
end

-- Lines 156-158
function RaidGUIControlButtonToggle:set_value(value)
	self._value = value
end

-- Lines 160-162
function RaidGUIControlButtonToggle:get_value()
	return self._value
end

-- Lines 164-167
function RaidGUIControlButtonToggle:set_value_and_render(value)
	self:set_value(value)
	self:_render_images()
end

-- Lines 169-180
function RaidGUIControlButtonToggle:_render_images()
	if self._visible == false then
		self:hide()

		return
	elseif self._value then
		self._check:set_visible(true)
	else
		self._check:set_visible(false)
	end
end

-- Lines 182-184
function RaidGUIControlButtonToggle:show()
	self._object:show()
end

-- Lines 186-188
function RaidGUIControlButtonToggle:hide()
	self._object:hide()
end

-- Lines 190-193
function RaidGUIControlButtonToggle:set_visible(flag)
	self._visible = flag

	self:_render_images()
end

-- Lines 195-214
function RaidGUIControlButtonToggle:confirm_pressed()
	if not self._enabled then
		return
	end

	if self._selected then
		if self._value then
			self._value = false
		else
			self._value = true
		end

		self:_render_images()

		if self._on_click_callback then
			self:_on_click_callback(self, self._value)
		end

		return true
	end

	return false
end

-- Lines 216-237
function RaidGUIControlButtonToggle:set_enabled(enabled)
	RaidGUIControlButtonToggle.super.set_enabled(self, enabled)

	if enabled then
		if self._highlighted then
			self._description:set_color(RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR)
			self._border:set_color(RaidGUIControlButtonToggle.BORDER_HOVER_COLOR)
			self._check:set_color(Color.white)
			self._sideline:set_alpha(1)
		else
			self._description:set_color(RaidGUIControlButtonToggle.TEXT_COLOR)
			self._border:set_color(RaidGUIControlButtonToggle.BORDER_COLOR)
			self._check:set_color(Color.white)
			self._sideline:set_alpha(0)
		end
	else
		self._description:set_color(RaidGUIControlButtonToggle.TEXT_COLOR_DISABLED)
		self._border:set_color(RaidGUIControlButtonToggle.TEXT_COLOR_DISABLED)
		self._check:set_color(RaidGUIControlButtonToggle.TEXT_COLOR_DISABLED)
		self._sideline:set_alpha(0)
	end
end

-- Lines 244-275
function RaidGUIControlButtonToggle:_animate_highlight_on()
	local starting_alpha = self._sideline:alpha()
	local duration = 0.2
	local t = duration - (1 - starting_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 0, 1, duration)

		self._sideline:set_alpha(alpha)

		local description_r = Easing.quartic_out(t, RaidGUIControlButtonToggle.TEXT_COLOR.r, RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.r - RaidGUIControlButtonToggle.TEXT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlButtonToggle.TEXT_COLOR.g, RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.g - RaidGUIControlButtonToggle.TEXT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlButtonToggle.TEXT_COLOR.b, RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.b - RaidGUIControlButtonToggle.TEXT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))

		local border_r = Easing.quartic_out(t, RaidGUIControlButtonToggle.BORDER_COLOR.r, RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.r - RaidGUIControlButtonToggle.BORDER_COLOR.r, duration)
		local border_g = Easing.quartic_out(t, RaidGUIControlButtonToggle.BORDER_COLOR.g, RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.g - RaidGUIControlButtonToggle.BORDER_COLOR.g, duration)
		local border_b = Easing.quartic_out(t, RaidGUIControlButtonToggle.BORDER_COLOR.b, RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.b - RaidGUIControlButtonToggle.BORDER_COLOR.b, duration)

		self._border:set_color(Color(border_r, border_g, border_b))
	end

	self._sideline:set_alpha(1)
	self._description:set_color(RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR)
	self._border:set_color(RaidGUIControlButtonToggle.BORDER_HOVER_COLOR)
end

-- Lines 277-308
function RaidGUIControlButtonToggle:_animate_highlight_off()
	local starting_alpha = self._sideline:alpha()
	local duration = 0.2
	local t = duration - starting_alpha * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 1, -1, duration)

		self._sideline:set_alpha(alpha)

		local description_r = Easing.quartic_out(t, RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.r, RaidGUIControlButtonToggle.TEXT_COLOR.r - RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.g, RaidGUIControlButtonToggle.TEXT_COLOR.g - RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.b, RaidGUIControlButtonToggle.TEXT_COLOR.b - RaidGUIControlButtonToggle.TEXT_HIGHLIGHT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))

		local border_r = Easing.quartic_out(t, RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.r, RaidGUIControlButtonToggle.BORDER_COLOR.r - RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.r, duration)
		local border_g = Easing.quartic_out(t, RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.g, RaidGUIControlButtonToggle.BORDER_COLOR.g - RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.g, duration)
		local border_b = Easing.quartic_out(t, RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.b, RaidGUIControlButtonToggle.BORDER_COLOR.b - RaidGUIControlButtonToggle.BORDER_HOVER_COLOR.b, duration)

		self._border:set_color(Color(border_r, border_g, border_b))
	end

	self._sideline:set_alpha(0)
	self._description:set_color(RaidGUIControlButtonToggle.TEXT_COLOR)
	self._border:set_color(RaidGUIControlButtonToggle.BORDER_COLOR)
end

-- Lines 310-332
function RaidGUIControlButtonToggle:_animate_checkbox_press()
	local t = 0
	local original_w = RaidGUIControlButtonToggle.W
	local original_h = RaidGUIControlButtonToggle.H
	local starting_scale = self._checkbox_panel:w() / original_w
	local duration = 0.25 * (starting_scale - 0.9) / 0.1
	local center_x, center_y = self._checkbox_panel:center()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, starting_scale, 0.9 - starting_scale, duration)

		self._checkbox_panel:set_w(original_w * scale)
		self._checkbox_panel:set_h(original_h * scale)
		self._checkbox_panel:set_center(center_x, center_y)
	end

	self._checkbox_panel:set_w(original_w * 0.9)
	self._checkbox_panel:set_h(original_h * 0.9)
	self._checkbox_panel:set_center(center_x, center_y)
end

-- Lines 334-359
function RaidGUIControlButtonToggle:_animate_checkbox_release()
	local t = 0
	local duration = 0.25
	local target_w = RaidGUIControlButtonToggle.W
	local target_h = RaidGUIControlButtonToggle.H
	local center_x, center_y = self._checkbox_panel:center()

	self._checkbox_panel:set_w(target_w * 0.9)
	self._checkbox_panel:set_h(target_h * 0.9)
	self._checkbox_panel:set_center(center_x, center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, 0.9, 0.1, duration)

		self._checkbox_panel:set_w(target_w * scale)
		self._checkbox_panel:set_h(target_h * scale)
		self._checkbox_panel:set_center(center_x, center_y)
	end

	self._checkbox_panel:set_w(target_w)
	self._checkbox_panel:set_h(target_h)
	self._checkbox_panel:set_center(center_x, center_y)
end
