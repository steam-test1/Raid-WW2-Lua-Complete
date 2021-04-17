RaidGUIControlSliderSimple = RaidGUIControlSliderSimple or class(RaidGUIControl)
RaidGUIControlSliderSimple.DEFAULT_WIDTH = 240
RaidGUIControlSliderSimple.HEIGHT = 32
RaidGUIControlSliderSimple.SLIDER_ICON = "ico_slider_thumb"
RaidGUIControlSliderSimple.SLIDER_BACKGROUND_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlSliderSimple.SLIDER_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSliderSimple.DISABLED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlSliderSimple.SLIDER_LINE_HEIGHT = 4
RaidGUIControlSliderSimple.CONTROLLER_STEP = 4

-- Lines 15-32
function RaidGUIControlSliderSimple:init(parent, params)
	RaidGUIControlSliderSimple.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSliderSimple:init] Parameters not specified for simple slider " .. tostring(self._name))

		return
	end

	self._value = self._params.value or 0
	self._on_value_change_callback = params.on_value_change_callback

	self:_create_slider_panel()
	self:_create_slider_controls()
	self:render_value()
	self:highlight_off()
end

-- Lines 35-43
function RaidGUIControlSliderSimple:_create_slider_panel()
	local slider_params = clone(self._params)
	slider_params.name = slider_params.name .. "_simple_slider"
	slider_params.layer = self._panel:layer() + 1
	slider_params.w = self._params.w or RaidGUIControlSliderSimple.DEFAULT_WIDTH
	slider_params.h = RaidGUIControlSliderSimple.HEIGHT
	self._slider_panel = self._panel:panel(slider_params)
	self._object = self._slider_panel
end

-- Lines 46-85
function RaidGUIControlSliderSimple:_create_slider_controls()
	local w = self._params.w or RaidGUIControlSliderSimple.DEFAULT_WIDTH
	self._slider_line_panel = self._object:panel({
		name = self._name .. "_slider_line_panel",
		x = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[3] / 2,
		y = RaidGUIControlSliderSimple.HEIGHT / 2 - RaidGUIControlSliderSimple.SLIDER_LINE_HEIGHT / 2,
		w = w - tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[3],
		layer = self._object:layer()
	})
	self._slider_line = self._slider_line_panel:three_cut_bitmap({
		center = "slider_line_center_base",
		right = "slider_line_right_base",
		left = "slider_line_left_base",
		y = 0,
		x = 0,
		name = self._name .. "_slider_line",
		w = self._slider_line_panel:w(),
		color = RaidGUIControlSliderSimple.SLIDER_BACKGROUND_COLOR,
		layer = self._slider_line_panel:layer()
	})
	self._slider_line_active = self._slider_line_panel:three_cut_bitmap({
		center = "slider_line_center_base",
		right = "slider_line_right_base",
		left = "slider_line_left_base",
		y = 0,
		x = 0,
		name = self._name .. "_slider_line_active",
		w = self._slider_line_panel:w(),
		color = RaidGUIControlSliderSimple.SLIDER_COLOR,
		layer = self._slider_line_panel:layer() + 1
	})

	self._slider_line_panel:set_h(self._slider_line:h())

	self._slider_thumb = self._object:bitmap({
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect,
		w = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[3],
		h = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[4],
		layer = self._slider_line_panel:layer() + 200
	})
end

-- Lines 87-97
function RaidGUIControlSliderSimple:on_mouse_pressed()
	if not self._enabled then
		return
	end

	self._old_active_control = managers.raid_menu:get_active_control()

	managers.raid_menu:set_active_control(self)

	self._active = true

	managers.menu_component:post_event("music_slider_radio")
end

-- Lines 99-108
function RaidGUIControlSliderSimple:on_mouse_released()
	if not self._enabled then
		return
	end

	managers.raid_menu:set_active_control(self._old_active_control)

	self._active = false

	managers.menu_component:post_event("music_slider_radio_stop")
end

-- Lines 110-121
function RaidGUIControlSliderSimple:on_mouse_moved(o, x, y)
	if not self._enabled then
		return
	end

	RaidGUIControlSliderSimple.super.on_mouse_moved(o, x, y)

	if self._active and alive(self._object._engine_panel) then
		self:set_value_by_x_coord(x - self._slider_line_panel:world_x())
	end
end

-- Lines 123-126
function RaidGUIControlSliderSimple:on_mouse_out(x, y)
	RaidGUIControlSliderSimple.super.on_mouse_out(self, x, y)
	self:on_mouse_released()
end

-- Lines 128-140
function RaidGUIControlSliderSimple:set_enabled(enabled)
	RaidGUIControlSliderSimple.super.set_enabled(self, enabled)

	if enabled then
		self._slider_thumb:set_color(Color.white)
		self._slider_line:set_color(RaidGUIControlSliderSimple.SLIDER_BACKGROUND_COLOR)
		self._slider_line_active:set_color(RaidGUIControlSliderSimple.SLIDER_COLOR)
	else
		self._slider_thumb:set_color(RaidGUIControlSliderSimple.DISABLED_COLOR)
		self._slider_line:set_color(RaidGUIControlSliderSimple.DISABLED_COLOR)
		self._slider_line_active:set_color(RaidGUIControlSliderSimple.DISABLED_COLOR)
	end
end

-- Lines 142-153
function RaidGUIControlSliderSimple:set_value_by_x_coord(selected_coord_x)
	local value = selected_coord_x / self._slider_line_panel:w() * 100

	if value < 0 then
		value = 0
	end

	if value > 100 then
		value = 100
	end

	self:set_value_and_render(value)
end

-- Lines 155-157
function RaidGUIControlSliderSimple:get_value()
	return self._value
end

-- Lines 159-161
function RaidGUIControlSliderSimple:set_value(value)
	self._value = value
end

-- Lines 163-170
function RaidGUIControlSliderSimple:set_value_and_render(value)
	self:set_value(value)
	self:render_value()

	if self._on_value_change_callback then
		self._on_value_change_callback()
	end
end

-- Lines 172-179
function RaidGUIControlSliderSimple:render_value()
	self._value = math.clamp(self._value, 0, 100)
	local width = self._value / 100 * self._slider_line_panel:w()

	self._slider_line_active:set_w(width)
	self._slider_thumb:set_center_x(self._slider_line_panel:x() + width)
end

-- Lines 181-190
function RaidGUIControlSliderSimple:highlight_on()
	if not self._enabled then
		return
	end

	self._highlighted = true

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_on"))
end

-- Lines 192-201
function RaidGUIControlSliderSimple:highlight_off()
	if not self._enabled then
		return
	end

	self._highlighted = true

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_off"))
end

-- Lines 203-205
function RaidGUIControlSliderSimple:set_right(value)
	self._object:set_right(value)
end

-- Lines 207-209
function RaidGUIControlSliderSimple:set_left(value)
	self._object:set_left(value)
end

-- Lines 218-225
function RaidGUIControlSliderSimple:move_left()
	Application:trace("[RaidGUIControlSliderSimple:move_left] ", self._name, self._selected)

	if self._selected then
		local current_value = self:get_value()

		self:set_value_and_render(current_value - RaidGUIControlSliderSimple.CONTROLLER_STEP)

		return true
	end
end

-- Lines 227-234
function RaidGUIControlSliderSimple:move_right()
	Application:trace("[RaidGUIControlSliderSimple:move_right] ", self._name, self._selected)

	if self._selected then
		local current_value = self:get_value()

		self:set_value_and_render(current_value + RaidGUIControlSliderSimple.CONTROLLER_STEP)

		return true
	end
end

-- Lines 238-257
function RaidGUIControlSliderSimple:_animate_highlight_on()
	local t = 0
	local starting_color = self._slider_line_active:color()
	local duration = 0.2 * (RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR.r - starting_color.r) / (RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR.r - RaidGUIControlSliderSimple.SLIDER_COLOR.r)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quartic_out(t, starting_color.r, RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR.r - starting_color.r, duration)
		local current_g = Easing.quartic_out(t, starting_color.g, RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR.g - starting_color.g, duration)
		local current_b = Easing.quartic_out(t, starting_color.b, RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR.b - starting_color.b, duration)

		self._slider_line_active:set_color(Color(current_r, current_g, current_b))
		self._slider_thumb:set_color(Color(current_r, current_g, current_b))
	end

	self._slider_line_active:set_color(RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR)
	self._slider_thumb:set_color(RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR)
end

-- Lines 259-278
function RaidGUIControlSliderSimple:_animate_highlight_off()
	local t = 0
	local starting_color = self._slider_line_active:color()
	local duration = 0.2 * (RaidGUIControlSliderSimple.SLIDER_COLOR.r - starting_color.r) / (RaidGUIControlSliderSimple.SLIDER_COLOR.r - RaidGUIControlSliderSimple.SLIDER_HIGHLIGHT_COLOR.r)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quartic_out(t, starting_color.r, RaidGUIControlSliderSimple.SLIDER_COLOR.r - starting_color.r, duration)
		local current_g = Easing.quartic_out(t, starting_color.g, RaidGUIControlSliderSimple.SLIDER_COLOR.g - starting_color.g, duration)
		local current_b = Easing.quartic_out(t, starting_color.b, RaidGUIControlSliderSimple.SLIDER_COLOR.b - starting_color.b, duration)

		self._slider_line_active:set_color(Color(current_r, current_g, current_b))
		self._slider_thumb:set_color(Color(current_r, current_g, current_b))
	end

	self._slider_line_active:set_color(RaidGUIControlSliderSimple.SLIDER_COLOR)
	self._slider_thumb:set_color(RaidGUIControlSliderSimple.SLIDER_COLOR)
end

-- Lines 280-302
function RaidGUIControlSliderSimple:_animate_thumb_press()
	local t = 0
	local original_w = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[3]
	local original_h = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[4]
	local starting_scale = self._slider_thumb:w() / original_w
	local duration = 0.25 * (starting_scale - 0.9) / 0.1
	local center_x, center_y = self._slider_thumb:center()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, starting_scale, 0.9 - starting_scale, duration)

		self._slider_thumb:set_w(original_w * scale)
		self._slider_thumb:set_h(original_h * scale)
		self._slider_thumb:set_center(center_x, center_y)
	end

	self._slider_thumb:set_w(original_w * 0.9)
	self._slider_thumb:set_h(original_h * 0.9)
	self._slider_thumb:set_center(center_x, center_y)
end

-- Lines 304-329
function RaidGUIControlSliderSimple:_animate_thumb_release()
	local t = 0
	local duration = 0.25
	local target_w = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[3]
	local target_h = tweak_data.gui.icons[RaidGUIControlSliderSimple.SLIDER_ICON].texture_rect[4]
	local center_x, center_y = self._slider_thumb:center()

	self._slider_thumb:set_w(target_w * 0.9)
	self._slider_thumb:set_h(target_h * 0.9)
	self._slider_thumb:set_center(center_x, center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, 0.9, 0.1, duration)

		self._slider_thumb:set_w(target_w * scale)
		self._slider_thumb:set_h(target_h * scale)
		self._slider_thumb:set_center(center_x, center_y)
	end

	self._slider_thumb:set_w(target_w)
	self._slider_thumb:set_h(target_h)
	self._slider_thumb:set_center(center_x, center_y)
end
