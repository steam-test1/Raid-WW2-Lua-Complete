RaidGUIControlStepper = RaidGUIControlStepper or class(RaidGUIControl)
RaidGUIControlStepper.DEFAULT_CONTROL_WIDTH = 480
RaidGUIControlStepper.DEFAULT_HEIGHT = 32
RaidGUIControlStepper.TEXT_PADDING = 16
RaidGUIControlStepper.BUTTON_RIGHT_TEXTURE = "hslider_arrow_right_base"
RaidGUIControlStepper.BUTTON_LEFT_TEXTURE = "hslider_arrow_left_base"
RaidGUIControlStepper.BUTTON_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlStepper.BUTTON_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlStepper.TEXT_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlStepper.TEXT_COLOR_DISABLED = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlStepper.SIDELINE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlStepper.SIDELINE_W = 3

-- Lines 17-44
function RaidGUIControlStepper:init(parent, params)
	RaidGUIControlStepper.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlStepper:init] List specific parameters not specified for list: ", params.name)

		return
	end

	if not params.data_source_callback then
		Application:error("[RaidGUIControlStepper:init] Data source callback not specified for list: ", params.name)

		return
	end

	self._pointer_type = "arrow"

	if params.on_item_selected_callback then
		self._on_select_callback = params.on_item_selected_callback
	end

	self._data_source_callback = params.data_source_callback
	self._stepper_params = params

	self:_create_stepper_panel()
	self:_create_stepper_controls()
	self:highlight_off()
end

-- Lines 46-48
function RaidGUIControlStepper:refresh_data(sort_descending)
	self._stepper:refresh_data(sort_descending)
end

-- Lines 50-58
function RaidGUIControlStepper:_create_stepper_panel()
	local stepper_params = clone(self._params)
	stepper_params.name = stepper_params.name .. "_stepper"
	stepper_params.layer = self._panel:layer() + 1
	stepper_params.w = self._params.w or RaidGUIControlStepper.DEFAULT_CONTROL_WIDTH
	stepper_params.h = RaidGUIControlStepper.DEFAULT_HEIGHT
	self._stepper_panel = self._panel:panel(stepper_params)
	self._object = self._stepper_panel
end

-- Lines 61-97
function RaidGUIControlStepper:_create_stepper_controls()
	local sideline_params = {
		alpha = 0,
		y = 0,
		x = 0,
		w = RaidGUIControlStepper.SIDELINE_W,
		h = self._object:h(),
		color = RaidGUIControlStepper.SIDELINE_COLOR
	}
	self._sideline = self._object:rect(sideline_params)
	local stepper_w = self._params.stepper_w or RaidGUIControlStepperSimple.DEFAULT_WIDTH
	local stepper_params = {
		y = 0,
		name = self._name .. "_stepper",
		x = self._object:w() - stepper_w,
		w = stepper_w,
		on_item_selected_callback = self._params.on_item_selected_callback,
		data_source_callback = self._params.data_source_callback,
		start_from_last = self._stepper_params.start_from_last
	}
	self._stepper = self._object:stepper_simple(stepper_params)
	self._description = self._object:text({
		vertical = "center",
		align = "left",
		y = 0,
		x = RaidGUIControlStepper.SIDELINE_W + RaidGUIControlStepper.TEXT_PADDING,
		w = self._object:w() - stepper_w - RaidGUIControlStepper.SIDELINE_W - RaidGUIControlStepper.TEXT_PADDING * 2,
		h = self._object:h(),
		color = RaidGUIControlStepper.TEXT_COLOR,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		text = self._params.description,
		layer = self._object:layer() + 1
	})
end

-- Lines 99-101
function RaidGUIControlStepper:set_disabled_items(data)
	self._stepper:set_disabled_items(data)
end

-- Lines 103-105
function RaidGUIControlStepper:selected_item()
	return self._stepper:selected_item()
end

-- Lines 107-109
function RaidGUIControlStepper:label_x()
	return self._description:x()
end

-- Lines 111-113
function RaidGUIControlStepper:_select_item(index)
	self._stepper:selected_item()
end

-- Lines 115-117
function RaidGUIControlStepper:select_item_by_value(value)
	self._stepper:select_item_by_value(value)
end

-- Lines 119-121
function RaidGUIControlStepper:get_value()
	return self._stepper:get_value()
end

-- Lines 123-125
function RaidGUIControlStepper:set_value_and_render(value_to_select, skip_animation)
	self._stepper:set_value_and_render(value_to_select, skip_animation)
end

-- Lines 127-129
function RaidGUIControlStepper:mouse_released(o, button, x, y)
	return false
end

-- Lines 131-145
function RaidGUIControlStepper:highlight_on()
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

-- Lines 148-159
function RaidGUIControlStepper:highlight_off()
	self._highlighted = false

	if not self._enabled then
		return
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_off"))

	self._play_mouse_over_sound = true
end

-- Lines 161-167
function RaidGUIControlStepper:on_mouse_scroll_up()
	if not self._enabled then
		return
	end

	self._stepper:on_right_arrow_clicked()
end

-- Lines 169-175
function RaidGUIControlStepper:on_mouse_scroll_down()
	if not self._enabled then
		return
	end

	self._stepper:on_left_arrow_clicked()
end

-- Lines 177-179
function RaidGUIControlStepper:x()
	return self._stepper_panel._engine_panel:x()
end

-- Lines 181-183
function RaidGUIControlStepper:w()
	return self._stepper_panel._engine_panel:w()
end

-- Lines 185-189
function RaidGUIControlStepper:confirm_pressed()
	if self._selected then
		return true
	end
end

-- Lines 191-193
function RaidGUIControlStepper:is_selected_control()
	return self._selected_control
end

-- Lines 195-196
function RaidGUIControlStepper:_select_control(value)
end

-- Lines 198-207
function RaidGUIControlStepper:move_down()
	if self._selected then
		return self.super.move_down(self)
	end
end

-- Lines 209-218
function RaidGUIControlStepper:move_up()
	if self._selected then
		return self.super.move_up(self)
	end
end

-- Lines 220-225
function RaidGUIControlStepper:scroll_left()
	if self._selected then
		self._stepper:on_left_arrow_clicked()

		return true
	end
end

-- Lines 227-232
function RaidGUIControlStepper:scroll_right()
	if self._selected then
		self._stepper:on_right_arrow_clicked()

		return true
	end
end

-- Lines 237-258
function RaidGUIControlStepper:_animate_highlight_on()
	local starting_alpha = self._sideline:alpha()
	local duration = 0.2
	local t = duration - (1 - starting_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 0, 1, duration)

		self._sideline:set_alpha(alpha)

		local description_r = Easing.quartic_out(t, RaidGUIControlStepper.TEXT_COLOR.r, RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.r - RaidGUIControlStepper.TEXT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlStepper.TEXT_COLOR.g, RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.g - RaidGUIControlStepper.TEXT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlStepper.TEXT_COLOR.b, RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.b - RaidGUIControlStepper.TEXT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))
	end

	self._sideline:set_alpha(1)
end

-- Lines 260-281
function RaidGUIControlStepper:_animate_highlight_off()
	local starting_alpha = self._sideline:alpha()
	local duration = 0.2
	local t = duration - starting_alpha * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 1, -1, duration)

		self._sideline:set_alpha(alpha)

		local description_r = Easing.quartic_out(t, RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.r, RaidGUIControlStepper.TEXT_COLOR.r - RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.r, duration)
		local description_g = Easing.quartic_out(t, RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.g, RaidGUIControlStepper.TEXT_COLOR.g - RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.g, duration)
		local description_b = Easing.quartic_out(t, RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.b, RaidGUIControlStepper.TEXT_COLOR.b - RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR.b, duration)

		self._description:set_color(Color(description_r, description_g, description_b))
	end

	self._sideline:set_alpha(0)
end

-- Lines 283-300
function RaidGUIControlStepper:set_enabled(enabled)
	RaidGUIControlStepper.super.set_enabled(self, enabled)
	self._stepper:set_enabled(enabled)

	if enabled then
		if self._highlighted then
			self._description:set_color(RaidGUIControlStepper.TEXT_HIGHLIGHT_COLOR)
			self._sideline:set_alpha(1)
		else
			self._description:set_color(RaidGUIControlStepper.TEXT_COLOR)
			self._sideline:set_alpha(0)
		end
	else
		self._description:set_color(RaidGUIControlStepper.TEXT_COLOR_DISABLED)
		self._sideline:set_alpha(0)
	end
end
