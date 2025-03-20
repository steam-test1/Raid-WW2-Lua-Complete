RaidGUIControlSlider = RaidGUIControlSlider or class(RaidGUIControl)
RaidGUIControlSlider.DEFAULT_WIDTH = 576
RaidGUIControlSlider.DEFAULT_HEIGHT = 32
RaidGUIControlSlider.TEXT_PADDING = 16
RaidGUIControlSlider.TEXT_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlSlider.DISABLED_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlSlider.SIDELINE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSlider.SIDELINE_W = 3
RaidGUIControlSlider.VALUE_LABEL_W = 64

function RaidGUIControlSlider:init(parent, params)
	RaidGUIControlSlider.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSlider:init] Parameters not specified for slider " .. tostring(self._name))

		return
	end

	if string.find(self._params.description, "\r\n") or string.find(self._params.description, "\n") then
		RaidGUIControlSlider.DEFAULT_HEIGHT = 64
		self._double_height = true
	else
		RaidGUIControlSlider.DEFAULT_HEIGHT = 32
		self._double_height = false
	end

	self._value = self._params.value or 0
	self._value_label_format = self._params.value_format or "%d"
	self._value_slider_step = self._params.value_step or 4
	self._on_value_change_callback = params.on_value_change_callback
	self._min_display_value = params.min_display_value or 0
	self._max_display_value = params.max_display_value or 100
	self._slider_params = params.slider_params

	self:_create_slider_panel()
	self:_create_slider_controls()
	self:set_value(self._value)
	self:highlight_off()
end

function RaidGUIControlSlider:set_selected(value)
	RaidGUIControlSlider.super.set_selected(self, value)
	self._slider:set_selected(value)
end

function RaidGUIControlSlider:set_enabled(enabled)
	RaidGUIControlSlider.super.set_enabled(self, enabled)
	self._slider:set_enabled(enabled)
	self._slider:set_enabled(enabled)

	if enabled then
		if self._highlighted then
			self._description:set_color(RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR)
			self._value_label:set_color(RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR)
			self._sideline:set_alpha(1)
		else
			self._description:set_color(RaidGUIControlSlider.TEXT_COLOR)
			self._value_label:set_color(RaidGUIControlSlider.TEXT_COLOR)
			self._sideline:set_alpha(0)
		end
	else
		self._description:set_color(RaidGUIControlSlider.DISABLED_COLOR)
		self._value_label:set_color(RaidGUIControlSlider.DISABLED_COLOR)
		self._sideline:set_alpha(0)
	end
end

function RaidGUIControlSlider:_create_slider_panel()
	local slider_params = clone(self._params)
	slider_params.name = slider_params.name .. "_slider"
	slider_params.layer = self._panel:layer() + 1
	slider_params.w = self._params.w or RaidGUIControlSlider.DEFAULT_WIDTH
	slider_params.h = self._params.h or RaidGUIControlSlider.DEFAULT_HEIGHT
	self._slider_panel = self._panel:panel(slider_params)
	self._object = self._slider_panel
end

function RaidGUIControlSlider:_create_slider_controls()
	local sideline_params = {
		alpha = 0,
		y = 0,
		x = 0,
		w = RaidGUIControlSlider.SIDELINE_W,
		h = self._object:h(),
		color = RaidGUIControlSlider.SIDELINE_COLOR
	}
	self._sideline = self._object:rect(sideline_params)
	local value_label_params = {
		y = 0,
		vertical = "center",
		align = "left",
		x = self._object:w() - RaidGUIControlSlider.VALUE_LABEL_W,
		w = RaidGUIControlSlider.VALUE_LABEL_W,
		h = self._object:h(),
		color = RaidGUIControlSlider.TEXT_COLOR,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		layer = self._object:layer() + 1
	}
	self._value_label = self._object:text(value_label_params)
	self._slider = self._object:slider_simple({
		y = 0,
		x = 0,
		name = "slider_simple_" .. self._name,
		on_value_change_callback = callback(self, self, "_on_value_changed")
	})

	self._slider:set_right(self._value_label:x())
	self._slider:set_y(self._object:h() / 2 - self._slider:h() / 2)

	local description_params = {
		y = 0,
		vertical = "center",
		align = "left",
		x = RaidGUIControlSlider.SIDELINE_W + RaidGUIControlSlider.TEXT_PADDING,
		w = self._object:w() - RaidGUIControlSlider.SIDELINE_W - RaidGUIControlSlider.VALUE_LABEL_W - RaidGUIControlSlider.TEXT_PADDING * 2,
		h = self._object:h(),
		color = RaidGUIControlSlider.TEXT_COLOR,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		text = self._params.description,
		layer = self._object:layer() + 1
	}
	self._description = self._object:text(description_params)
end

function RaidGUIControlSlider:on_mouse_out(x, y)
	RaidGUIControlSlider.super.on_mouse_out(self, x, y)
	self:on_mouse_released()
end

function RaidGUIControlSlider:get_value()
	return self._value
end

function RaidGUIControlSlider:set_value(value)
	self._value = math.clamp(value, 0, 100)
	local display_value = math.lerp(self._min_display_value, self._max_display_value, self._value / 100)

	self._value_label:set_text(string.format(self._value_label_format, display_value))
	self._slider:set_value(value)
	self._slider:render_value()
end

function RaidGUIControlSlider:_on_value_changed()
	local current_value = self._slider:get_value()

	self:set_value(current_value)

	if self._on_value_change_callback then
		self._on_value_change_callback(self._value)
	end
end

function RaidGUIControlSlider:highlight_on()
	if not self._enabled then
		return
	end

	self._highlighted = true

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_on"))
end

function RaidGUIControlSlider:highlight_off()
	if not self._enabled then
		return
	end

	self._highlighted = false

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_off"))
end

function RaidGUIControlSlider:_animate_highlight_on()
	local starting_alpha = self._sideline:alpha()
	local duration = 0.2
	local t = duration - (1 - starting_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 0, 1, duration)

		self._sideline:set_alpha(alpha)

		local description_r = Easing.quartic_out(t, RaidGUIControlSlider.TEXT_COLOR.r, RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.r - RaidGUIControlSlider.TEXT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlSlider.TEXT_COLOR.g, RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.g - RaidGUIControlSlider.TEXT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlSlider.TEXT_COLOR.b, RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.b - RaidGUIControlSlider.TEXT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))
		self._value_label:set_color(Color(description_r, description_g, description_b))
	end

	self._sideline:set_alpha(1)
	self._description:set_color(RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR)
	self._value_label:set_color(RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR)
end

function RaidGUIControlSlider:_animate_highlight_off()
	local starting_alpha = self._sideline:alpha()
	local duration = 0.2
	local t = duration - starting_alpha * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 1, -1, duration)

		self._sideline:set_alpha(alpha)

		local description_r = Easing.quartic_out(t, RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.r, RaidGUIControlSlider.TEXT_COLOR.r - RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.g, RaidGUIControlSlider.TEXT_COLOR.g - RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.b, RaidGUIControlSlider.TEXT_COLOR.b - RaidGUIControlSlider.TEXT_HIGHLIGHT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))
		self._value_label:set_color(Color(description_r, description_g, description_b))
	end

	self._sideline:set_alpha(0)
	self._description:set_color(RaidGUIControlSlider.TEXT_COLOR)
	self._value_label:set_color(RaidGUIControlSlider.TEXT_COLOR)
end
