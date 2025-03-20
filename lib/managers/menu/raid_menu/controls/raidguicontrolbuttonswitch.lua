RaidGUIControlButtonSwitch = RaidGUIControlButtonSwitch or class(RaidGUIControl)
RaidGUIControlButtonSwitch.HEIGHT = 66
RaidGUIControlButtonSwitch.TEXT_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlButtonSwitch.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_16
RaidGUIControlButtonSwitch.TEXT_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlButtonSwitch.SWITCH_Y = 30
RaidGUIControlButtonSwitch.SWITCH_BORDER_ICON = "switch_bg"
RaidGUIControlButtonSwitch.SWITCH_BORDER_W = tweak_data.gui.icons[RaidGUIControlButtonSwitch.SWITCH_BORDER_ICON].texture_rect[3]
RaidGUIControlButtonSwitch.SWITCH_BORDER_H = tweak_data.gui.icons[RaidGUIControlButtonSwitch.SWITCH_BORDER_ICON].texture_rect[4]
RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlButtonSwitch.THUMB_ICON = "switch_thumb"
RaidGUIControlButtonSwitch.THUMB_W = tweak_data.gui.icons[RaidGUIControlButtonSwitch.THUMB_ICON].texture_rect[3]
RaidGUIControlButtonSwitch.THUMB_H = tweak_data.gui.icons[RaidGUIControlButtonSwitch.THUMB_ICON].texture_rect[4]
RaidGUIControlButtonSwitch.THUMB_COLOR_OFF = tweak_data.gui.colors.raid_grey
RaidGUIControlButtonSwitch.THUMB_COLOR_ON = tweak_data.gui.colors.raid_red
RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT = tweak_data.gui.colors.raid_red

function RaidGUIControlButtonSwitch:init(parent, params)
	RaidGUIControlButtonSwitch.super.init(self, parent, params)

	self._params.w = self._params.w or self._panel:w()
	self._params.h = RaidGUIControlButtonSwitch.HEIGHT
	self._object = self._panel:panel(self._params)
	self._description = self._object:text({
		vertical = "top",
		y = 0,
		x = 0,
		w = self._object:w(),
		h = self._object:h(),
		align = params.text_align or "center",
		color = RaidGUIControlButtonSwitch.TEXT_COLOR,
		font = RaidGUIControlButtonSwitch.TEXT_FONT,
		font_size = RaidGUIControlButtonSwitch.TEXT_FONT_SIZE,
		text = params.description,
		layer = self._object:layer() + 1
	})
	local switch_panel_params = {
		x = self._object:w() - RaidGUIControlButtonSwitch.SWITCH_BORDER_W,
		y = RaidGUIControlButtonSwitch.SWITCH_Y,
		w = RaidGUIControlButtonSwitch.SWITCH_BORDER_W,
		h = RaidGUIControlButtonSwitch.SWITCH_BORDER_H
	}
	self._switch_panel = self._object:panel(switch_panel_params)
	local switch_border_params = {
		halign = "scale",
		valign = "scale",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlButtonSwitch.SWITCH_BORDER_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlButtonSwitch.SWITCH_BORDER_ICON].texture_rect,
		w = RaidGUIControlButtonSwitch.SWITCH_BORDER_W,
		h = RaidGUIControlButtonSwitch.SWITCH_BORDER_H,
		layer = self._object:layer(),
		color = RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR
	}
	self._border = self._switch_panel:bitmap(switch_border_params)
	local switch_params = {
		halign = "scale",
		valign = "scale",
		y = 0,
		x = 1,
		texture = tweak_data.gui.icons[RaidGUIControlButtonSwitch.THUMB_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlButtonSwitch.THUMB_ICON].texture_rect,
		w = RaidGUIControlButtonSwitch.THUMB_W,
		h = RaidGUIControlButtonSwitch.THUMB_H,
		color = RaidGUIControlButtonSwitch.THUMB_COLOR_OFF,
		layer = self._object:layer() + 1
	}
	self._thumb = self._switch_panel:bitmap(switch_params)
	self._value = self._params.value or false
	self._play_mouse_over_sound = true
	self._on_click_callback = params.on_click_callback
	self._visible = self._params.visible

	self:_render_images()
end

function RaidGUIControlButtonSwitch:highlight_on()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_on"))

	if self._play_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._play_mouse_over_sound = false
	end
end

function RaidGUIControlButtonSwitch:highlight_off()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_off"))

	self._play_mouse_over_sound = true
end

function RaidGUIControlButtonSwitch:mouse_pressed(o, button, x, y)
	if self:inside(x, y) then
		self._switch_panel:stop()
		self._switch_panel:animate(callback(self, self, "_animate_switch_press"))
	end
end

function RaidGUIControlButtonSwitch:mouse_released(o, button, x, y)
	if self:inside(x, y) then
		if self._value then
			self._value = false
		else
			self._value = true
		end

		self._switch_panel:stop()
		self._switch_panel:animate(callback(self, self, "_animate_switch_release"))
		self:_render_images()

		if self._on_click_callback then
			self._on_click_callback(button, self, self._value)
		end

		return true
	else
		return false
	end
end

function RaidGUIControlButtonSwitch:set_value(value)
	self._value = value
end

function RaidGUIControlButtonSwitch:get_value()
	return self._value
end

function RaidGUIControlButtonSwitch:set_value_and_render(value)
	self:set_value(value)
	self:_render_images()
	self:highlight_off()
end

function RaidGUIControlButtonSwitch:_render_images()
	if self._visible == false then
		self:hide()

		return
	else
		self:show()

		if self._value then
			self._thumb:set_right(self._switch_panel:w())
		else
			self._thumb:set_left(0)
		end
	end
end

function RaidGUIControlButtonSwitch:set_visible(flag)
	self._visible = flag

	self:_render_images()
end

function RaidGUIControlButtonSwitch:confirm_pressed()
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

function RaidGUIControlButtonSwitch:_animate_highlight_on()
	local duration = 0.2
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local description_r = Easing.quartic_out(t, RaidGUIControlButtonSwitch.TEXT_COLOR.r, RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.r - RaidGUIControlButtonSwitch.TEXT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlButtonSwitch.TEXT_COLOR.g, RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.g - RaidGUIControlButtonSwitch.TEXT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlButtonSwitch.TEXT_COLOR.b, RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.b - RaidGUIControlButtonSwitch.TEXT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))

		local border_r = Easing.quartic_out(t, RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.r, RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.r - RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.r, duration)
		local border_g = Easing.quartic_out(t, RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.g, RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.g - RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.g, duration)
		local border_b = Easing.quartic_out(t, RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.b, RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.b - RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.b, duration)

		self._border:set_color(Color(border_r, border_g, border_b))

		local thumb_color = self._value and RaidGUIControlButtonSwitch.THUMB_COLOR_ON or RaidGUIControlButtonSwitch.THUMB_COLOR_OFF
		local thumb_r = Easing.quartic_out(t, thumb_color.r, RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.r - thumb_color.r, duration)
		local thumb_g = Easing.quartic_out(t, thumb_color.g, RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.g - thumb_color.g, duration)
		local thumb_b = Easing.quartic_out(t, thumb_color.b, RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.b - thumb_color.b, duration)

		self._thumb:set_color(Color(thumb_r, thumb_g, thumb_b))
	end

	self._description:set_color(RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR)
	self._border:set_color(RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR)
end

function RaidGUIControlButtonSwitch:_animate_highlight_off()
	local duration = 0.2
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local description_r = Easing.quartic_out(t, RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.r, RaidGUIControlButtonSwitch.TEXT_COLOR.r - RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.g, RaidGUIControlButtonSwitch.TEXT_COLOR.g - RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.b, RaidGUIControlButtonSwitch.TEXT_COLOR.b - RaidGUIControlButtonSwitch.TEXT_HIGHLIGHT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))

		local border_r = Easing.quartic_out(t, RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.r, RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.r - RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.r, duration)
		local border_g = Easing.quartic_out(t, RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.g, RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.g - RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.g, duration)
		local border_b = Easing.quartic_out(t, RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.b, RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR.b - RaidGUIControlButtonSwitch.SWITCH_BORDER_HIGHLIGHT_COLOR.b, duration)

		self._border:set_color(Color(border_r, border_g, border_b))

		local thumb_color = self._value and RaidGUIControlButtonSwitch.THUMB_COLOR_ON or RaidGUIControlButtonSwitch.THUMB_COLOR_OFF
		local thumb_r = Easing.quartic_out(t, RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.r, thumb_color.r - RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.r, duration)
		local thumb_g = Easing.quartic_out(t, RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.g, thumb_color.g - RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.g, duration)
		local thumb_b = Easing.quartic_out(t, RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.b, thumb_color.b - RaidGUIControlButtonSwitch.THUMB_COLOR_HIGHLIGHT.b, duration)

		self._thumb:set_color(Color(thumb_r, thumb_g, thumb_b))
	end

	self._description:set_color(RaidGUIControlButtonSwitch.TEXT_COLOR)
	self._border:set_color(RaidGUIControlButtonSwitch.SWITCH_BORDER_COLOR)
end

function RaidGUIControlButtonSwitch:_animate_switch_press()
	local t = 0
	local original_w = RaidGUIControlButtonSwitch.SWITCH_BORDER_W
	local original_h = RaidGUIControlButtonSwitch.SWITCH_BORDER_H
	local starting_scale = self._switch_panel:w() / original_w
	local duration = 0.25 * (starting_scale - 0.9) / 0.1
	local center_x, center_y = self._switch_panel:center()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, starting_scale, 0.9 - starting_scale, duration)

		self._switch_panel:set_w(original_w * scale)
		self._switch_panel:set_h(original_h * scale)
		self._switch_panel:set_center(center_x, center_y)
	end

	self._switch_panel:set_w(original_w * 0.9)
	self._switch_panel:set_h(original_h * 0.9)
	self._switch_panel:set_center(center_x, center_y)
end

function RaidGUIControlButtonSwitch:_animate_switch_release()
	local t = 0
	local duration = 0.25
	local target_w = RaidGUIControlButtonSwitch.SWITCH_BORDER_W
	local target_h = RaidGUIControlButtonSwitch.SWITCH_BORDER_H
	local center_x, center_y = self._switch_panel:center()

	self._switch_panel:set_w(target_w * 0.9)
	self._switch_panel:set_h(target_h * 0.9)
	self._switch_panel:set_center(center_x, center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, 0.9, 0.1, duration)

		self._switch_panel:set_w(target_w * scale)
		self._switch_panel:set_h(target_h * scale)
		self._switch_panel:set_center(center_x, center_y)
	end

	self._switch_panel:set_w(target_w)
	self._switch_panel:set_h(target_h)
	self._switch_panel:set_center(center_x, center_y)
end
