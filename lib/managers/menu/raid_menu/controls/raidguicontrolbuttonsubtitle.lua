RaidGUIControlButtonSubtitle = RaidGUIControlButtonSubtitle or class(RaidGUIControl)
RaidGUIControlButtonSubtitle.DEFAULT_WIDTH = 80
RaidGUIControlButtonSubtitle.DEFAULT_HEIGHT = 80
RaidGUIControlButtonSubtitle.TEXT_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlButtonSubtitle.TEXT_SIZE = tweak_data.gui.font_sizes.extra_small
RaidGUIControlButtonSubtitle.COLOR = tweak_data.gui.colors.raid_black
RaidGUIControlButtonSubtitle.ACTIVE_COLOR = tweak_data.gui.colors.raid_light_red
RaidGUIControlButtonSubtitle.DISABLED_ALPHA = 0.4
RaidGUIControlButtonSubtitle.ICON_PADDING_DOWN = 5
RaidGUIControlButtonSubtitle.ICON_W = 32
RaidGUIControlButtonSubtitle.ICON_H = 32
RaidGUIControlButtonSubtitle.PRESSED_SIZE = 0.9
RaidGUIControlButtonSubtitle.SELECTOR_TOP_LEFT = "ico_sel_rect_small_top_left"
RaidGUIControlButtonSubtitle.SELECTOR_BOTTOM_RIGHT = "ico_sel_rect_small_bottom_right"

function RaidGUIControlButtonSubtitle:init(parent, params)
	RaidGUIControlButtonSubtitle.super.init(self, parent, params)

	if not params.icon then
		Application:error("[RaidGUIControlButtonSubtitle:init] No icon set for subtitle button " .. tostring(self._name))

		return
	end

	if not params.text then
		Application:error("[RaidGUIControlButtonSubtitle:init] No text set for subtitle button " .. tostring(self._name))

		return
	end

	if not params.on_click_callback then
		Application:error("[RaidGUIControlButtonSubtitle:init] No callback set for subtitle button " .. tostring(self._name))

		return
	end

	self:_init_panel()
	self:_create_selectors()

	self._on_click_callback = params.on_click_callback
	local icon_params = {
		texture_rect = nil,
		name = "subtitle_icon",
		color = nil,
		texture = nil,
		layer = nil,
		y = 0,
		x = 0,
		layer = self._object:layer() + 1,
		texture = tweak_data.gui.icons[self._params.icon].texture,
		texture_rect = tweak_data.gui.icons[self._params.icon].texture_rect,
		color = RaidGUIControlButtonSubtitle.COLOR
	}
	self._icon = self._object:bitmap(icon_params)
	self._icon_w = self._icon:w()
	self._icon_h = self._icon:h()
	local text_params = {
		wrap = false,
		text = nil,
		vertical = "top",
		font = nil,
		align = "center",
		font_size = nil,
		y = 0,
		x = 0,
		layer = nil,
		name = "subtitle_text",
		color = nil,
		font = RaidGUIControlButtonSubtitle.TEXT_FONT,
		font_size = RaidGUIControlButtonSubtitle.TEXT_SIZE,
		text = params.text,
		color = RaidGUIControlButtonSubtitle.COLOR,
		layer = self._object:layer() + 1
	}
	self._text = self._object:text(text_params)
	self._align = params.align or "left"

	self:_fit_size()

	self._color_t = 0

	if params.active then
		self:highlight_on(true)
	else
		self:highlight_off(true)
	end

	if params.disabled then
		self:disable()
	end

	self._auto_deactivate = params.auto_deactivate
end

function RaidGUIControlButtonSubtitle:_init_panel()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_subtitle_button"
	panel_params.layer = self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or RaidGUIControlButtonSubtitle.DEFAULT_WIDTH
	panel_params.h = RaidGUIControlButtonSubtitle.DEFAULT_HEIGHT
	self._object = self._panel:panel(panel_params)
end

function RaidGUIControlButtonSubtitle:_create_selectors()
	local selector_panel_params = {
		valign = "scale",
		name = "selector_panel",
		halign = "scale",
		alpha = 0
	}
	self._selector_panel = self._object:panel(selector_panel_params)
	local selector_top_left_params = {
		texture_rect = nil,
		name = "selector_top_left",
		texture = nil,
		texture = tweak_data.gui.icons[RaidGUIControlButtonSubtitle.SELECTOR_TOP_LEFT].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlButtonSubtitle.SELECTOR_TOP_LEFT].texture_rect
	}
	local selector_top_left = self._selector_panel:bitmap(selector_top_left_params)
	local selector_bottom_right_params = {
		texture_rect = nil,
		name = "selector_bottom_right",
		halign = "right",
		texture = nil,
		valign = "bottom",
		texture = tweak_data.gui.icons[RaidGUIControlButtonSubtitle.SELECTOR_BOTTOM_RIGHT].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlButtonSubtitle.SELECTOR_BOTTOM_RIGHT].texture_rect
	}
	local selector_bottom_right = self._selector_panel:bitmap(selector_bottom_right_params)

	selector_bottom_right:set_right(self._selector_panel:w())
	selector_bottom_right:set_bottom(self._selector_panel:h())
end

function RaidGUIControlButtonSubtitle:_fit_size()
	local _, _, w, h = self._text:text_rect()

	self._text:set_w(w)
	self._text:set_h(h)

	local h = self._icon:h() + RaidGUIControlButtonSubtitle.ICON_PADDING_DOWN + self._text:h()
	local object_center_x = self._object:center_x()
	local object_w = math.max(self._icon:w(), w)
	object_w = math.max(object_w, RaidGUIControlButtonSubtitle.DEFAULT_WIDTH)

	self._object:set_w(object_w)
	self._object:set_center_x(object_center_x)
	self._icon:set_center_x(self._object:w() / 2)
	self._icon:set_y(self._object:h() / 2 - h / 2)

	self._icon_center_x = self._icon:x() + self._icon:w() / 2
	self._icon_center_y = self._icon:y() + self._icon:h() / 2

	self._text:set_center_x(self._object:w() / 2)
	self._text:set_bottom(self._object:h() / 2 + h / 2)
end

function RaidGUIControlButtonSubtitle:set_x(x)
	self._object:set_x(x)

	self._align = "left"
end

function RaidGUIControlButtonSubtitle:set_center_x(x)
	self._object:set_center_x(x)

	self._align = "center"
end

function RaidGUIControlButtonSubtitle:set_center_y(y)
	self._object:set_center_y(y)
end

function RaidGUIControlButtonSubtitle:set_right(x)
	self._object:set_right(x)

	self._align = "right"
end

function RaidGUIControlButtonSubtitle:set_y(y)
	self._object:set_y(y)
end

function RaidGUIControlButtonSubtitle:set_bottom(bottom)
	self._object:set_bottom(bottom)
end

function RaidGUIControlButtonSubtitle:highlight_on(skip_animation)
	if self._params.no_highlight then
		return
	end

	if skip_animation then
		self._icon:set_color(RaidGUIControlButtonSubtitle.ACTIVE_COLOR)
		self._text:set_color(RaidGUIControlButtonSubtitle.ACTIVE_COLOR)
	else
		self._text:stop()
		self._text:animate(callback(self, self, "_animate_highlight_on"))
	end

	if self._play_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._play_mouse_over_sound = false
	end
end

function RaidGUIControlButtonSubtitle:highlight_off(skip_animation)
	if self._params.no_highlight or self._active then
		return
	end

	if skip_animation then
		self._icon:set_color(RaidGUIControlButtonSubtitle.COLOR)
		self._text:set_color(RaidGUIControlButtonSubtitle.COLOR)
	else
		self._text:stop()
		self._text:animate(callback(self, self, "_animate_highlight_off"))
	end

	self._play_mouse_over_sound = true
end

function RaidGUIControlButtonSubtitle:mouse_released(o, button, x, y)
	self:on_mouse_released(button)

	return true
end

function RaidGUIControlButtonSubtitle:on_mouse_pressed(button)
	if self._params.no_click then
		return
	end

	self._icon:stop()
	self._icon:animate(callback(self, self, "_animate_press"))
end

function RaidGUIControlButtonSubtitle:on_mouse_released(button)
	if self._params.no_click then
		return
	end

	self._icon:stop()
	self._icon:animate(callback(self, self, "_animate_release"))

	if self._on_click_callback then
		self._on_click_callback(button, self, self._data)
	end
end

function RaidGUIControlButtonSubtitle:on_double_click(button)
	if self.on_double_click_callback then
		self.on_double_click_callback(button, self, self._data)
	end
end

function RaidGUIControlButtonSubtitle:set_alpha(alpha)
	self._object:set_alpha(alpha)
end

function RaidGUIControlButtonSubtitle:set_selected(value)
	self._selected = value

	if self._selected then
		self._selector_panel:set_alpha(1)
	else
		self._selector_panel:set_alpha(0)
	end
end

function RaidGUIControlButtonSubtitle:selected()
	return self._selected
end

function RaidGUIControlButtonSubtitle:set_active(value)
	self._active = value

	if self._active then
		self:highlight_on()
	else
		self:highlight_off()
	end
end

function RaidGUIControlButtonSubtitle:active()
	return self._active
end

function RaidGUIControlButtonSubtitle:show()
	self._object:set_visible(true)
end

function RaidGUIControlButtonSubtitle:hide()
	self._object:stop()
	self._object:set_visible(false)
end

function RaidGUIControlButtonSubtitle:enable(active_texture_color)
	self._icon:set_alpha(1)
	self._text:set_alpha(1)
	self:set_param_value("no_highlight", false)
	self:set_param_value("no_click", false)

	self._enabled = true
end

function RaidGUIControlButtonSubtitle:disable(inactive_texture_color)
	self._icon:set_alpha(RaidGUIControlButtonSubtitle.DISABLED_ALPHA)
	self._text:set_alpha(RaidGUIControlButtonSubtitle.DISABLED_ALPHA)
	self:set_param_value("no_highlight", true)
	self:set_param_value("no_click", true)

	self._enabled = false
end

function RaidGUIControlButtonSubtitle:confirm_pressed()
	if self._selected then
		self:on_mouse_released(Idstring("0"))
	end
end

function RaidGUIControlButtonSubtitle:_animate_highlight_on()
	local starting_color = self._text:color()
	local duration = 0.2
	local t = self._color_t

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quartic_out(t, RaidGUIControlButtonSubtitle.COLOR.r, RaidGUIControlButtonSubtitle.ACTIVE_COLOR.r - RaidGUIControlButtonSubtitle.COLOR.r, duration)
		local current_g = Easing.quartic_out(t, RaidGUIControlButtonSubtitle.COLOR.g, RaidGUIControlButtonSubtitle.ACTIVE_COLOR.g - RaidGUIControlButtonSubtitle.COLOR.g, duration)
		local current_b = Easing.quartic_out(t, RaidGUIControlButtonSubtitle.COLOR.b, RaidGUIControlButtonSubtitle.ACTIVE_COLOR.b - RaidGUIControlButtonSubtitle.COLOR.b, duration)

		self._icon:set_color(Color(current_r, current_g, current_b))
		self._text:set_color(Color(current_r, current_g, current_b))

		self._color_t = t / duration
	end

	self._icon:set_color(RaidGUIControlButtonSubtitle.ACTIVE_COLOR)
	self._text:set_color(RaidGUIControlButtonSubtitle.ACTIVE_COLOR)

	self._color_t = 1

	if self._auto_deactivate and self._active then
		self._active = false

		self:_animate_highlight_off()
	end
end

function RaidGUIControlButtonSubtitle:_animate_highlight_off()
	local starting_color = self._text:color()
	local duration = 0.2
	local t = 1 - self._color_t

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quartic_out(t, RaidGUIControlButtonSubtitle.ACTIVE_COLOR.r, RaidGUIControlButtonSubtitle.COLOR.r - RaidGUIControlButtonSubtitle.ACTIVE_COLOR.r, duration)
		local current_g = Easing.quartic_out(t, RaidGUIControlButtonSubtitle.ACTIVE_COLOR.g, RaidGUIControlButtonSubtitle.COLOR.g - RaidGUIControlButtonSubtitle.ACTIVE_COLOR.g, duration)
		local current_b = Easing.quartic_out(t, RaidGUIControlButtonSubtitle.ACTIVE_COLOR.b, RaidGUIControlButtonSubtitle.COLOR.b - RaidGUIControlButtonSubtitle.ACTIVE_COLOR.b, duration)

		self._icon:set_color(Color(current_r, current_g, current_b))
		self._text:set_color(Color(current_r, current_g, current_b))

		self._color_t = 1 - t / duration
	end

	self._icon:set_color(RaidGUIControlButtonSubtitle.COLOR)
	self._text:set_color(RaidGUIControlButtonSubtitle.COLOR)

	self._color_t = 0
end

function RaidGUIControlButtonSubtitle:_animate_press()
	local t = 0
	local duration = 0.05

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_in(t, 1, -(1 - RaidGUIControlButtonSubtitle.PRESSED_SIZE), duration)

		self._icon:set_size(self._icon_w * scale, self._icon_w * scale)
		self._icon:set_center(self._icon_center_x, self._icon_center_y)
	end

	self._icon:set_size(self._icon_w * RaidGUIControlButtonSubtitle.PRESSED_SIZE, self._icon_w * RaidGUIControlButtonSubtitle.PRESSED_SIZE)
	self._icon:set_center(self._icon_center_x, self._icon_center_y)
end

function RaidGUIControlButtonSubtitle:_animate_release()
	local t = 0
	local duration = 0.25

	self._icon:set_size(self._icon_w * RaidGUIControlButtonSubtitle.PRESSED_SIZE, self._icon_w * RaidGUIControlButtonSubtitle.PRESSED_SIZE)
	self._icon:set_center(self._icon_center_x, self._icon_center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, RaidGUIControlButtonSubtitle.PRESSED_SIZE, 1 - RaidGUIControlButtonSubtitle.PRESSED_SIZE, duration)

		self._icon:set_size(self._icon_w * scale, self._icon_w * scale)
		self._icon:set_center(self._icon_center_x, self._icon_center_y)
	end

	self._icon:set_size(self._icon_w, self._icon_w)
	self._icon:set_center(self._icon_center_x, self._icon_center_y)
end
