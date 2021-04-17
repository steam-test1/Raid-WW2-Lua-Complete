RaidGUIControlStepperSimple = RaidGUIControlStepperSimple or class(RaidGUIControl)
RaidGUIControlStepperSimple.DEFAULT_WIDTH = 192
RaidGUIControlStepperSimple.DEFAULT_HEIGHT = 32
RaidGUIControlStepperSimple.BUTTON_RIGHT_TEXTURE = "hslider_arrow_right_base"
RaidGUIControlStepperSimple.BUTTON_LEFT_TEXTURE = "hslider_arrow_left_base"
RaidGUIControlStepperSimple.BUTTON_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlStepperSimple.BUTTON_HIGHLIGHT_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlStepperSimple.TEXT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlStepperSimple.TEXT_COLOR_DISABLED = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlStepperSimple.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlStepperSimple.FONT_SIZE = tweak_data.gui.font_sizes.small

-- Lines 15-41
function RaidGUIControlStepperSimple:init(parent, params)
	RaidGUIControlStepperSimple.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlStepperSimple:init] List specific parameters not specified for list: ", params.name)

		return
	end

	if not params.data_source_callback then
		Application:error("[RaidGUIControlStepperSimple:init] Data source callback not specified for list: ", params.name)

		return
	end

	self._pointer_type = "arrow"

	if params.on_item_selected_callback then
		self._on_select_callback = params.on_item_selected_callback
	end

	self._data_source_callback = params.data_source_callback

	self:highlight_off()
	self:_create_stepper_panel()
	self:_create_stepper_controls()
end

-- Lines 43-47
function RaidGUIControlStepperSimple:refresh_data(sort_descending)
	self:_delete_items()
	self:_create_stepper_panel()
	self:_create_stepper_controls(sort_descending)
end

-- Lines 49-59
function RaidGUIControlStepperSimple:set_disabled_items(disabled_item_data)
	for index, data in pairs(self._stepper_data) do
		self._stepper_data[index].disabled = not disabled_item_data[index]
	end

	if self._stepper_data[self._selected_item_index].disabled then
		self._value_label:set_color(RaidGUIControlStepperSimple.TEXT_COLOR_DISABLED)
	else
		self._value_label:set_color(RaidGUIControlStepperSimple.TEXT_COLOR)
	end
end

-- Lines 61-65
function RaidGUIControlStepperSimple:_delete_items()
	self._stepper_data = {}
	self._selected_item = nil

	self._object:clear()
end

-- Lines 67-75
function RaidGUIControlStepperSimple:_create_stepper_panel()
	local stepper_params = clone(self._params)
	stepper_params.name = stepper_params.name .. "_stepper"
	stepper_params.layer = self._panel:layer() + 1
	stepper_params.w = self._params.w or RaidGUIControlStepperSimple.DEFAULT_WIDTH
	stepper_params.h = RaidGUIControlStepperSimple.DEFAULT_HEIGHT
	self._stepper_panel = self._panel:panel(stepper_params)
	self._object = self._stepper_panel
end

-- Lines 78-143
function RaidGUIControlStepperSimple:_create_stepper_controls(sort_descending)
	local left_arrow_params = {
		name = "stepper_simple_left_arrow",
		x = 0,
		y = self._object:h() / 2 - tweak_data.gui:icon_h(RaidGUIControlStepperSimple.BUTTON_LEFT_TEXTURE) / 2,
		texture = tweak_data.gui.icons[RaidGUIControlStepperSimple.BUTTON_LEFT_TEXTURE].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlStepperSimple.BUTTON_LEFT_TEXTURE].texture_rect,
		w = tweak_data.gui:icon_w(RaidGUIControlStepperSimple.BUTTON_LEFT_TEXTURE),
		h = tweak_data.gui:icon_h(RaidGUIControlStepperSimple.BUTTON_LEFT_TEXTURE),
		color = RaidGUIControlStepperSimple.BUTTON_COLOR,
		highlight_color = RaidGUIControlStepperSimple.BUTTON_HIGHLIGHT_COLOR,
		layer = self._object:layer() + 1,
		on_click_callback = callback(self, self, "on_left_arrow_clicked")
	}
	self._arrow_left = self._object:image_button(left_arrow_params)
	local right_arrow_params = {
		name = "stepper_simple_right_arrow",
		x = self._object:w() - tweak_data.gui:icon_w(RaidGUIControlStepperSimple.BUTTON_RIGHT_TEXTURE),
		y = self._object:h() / 2 - tweak_data.gui:icon_h(RaidGUIControlStepperSimple.BUTTON_RIGHT_TEXTURE) / 2,
		texture = tweak_data.gui.icons[RaidGUIControlStepperSimple.BUTTON_RIGHT_TEXTURE].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlStepperSimple.BUTTON_RIGHT_TEXTURE].texture_rect,
		w = tweak_data.gui:icon_w(RaidGUIControlStepperSimple.BUTTON_RIGHT_TEXTURE),
		h = tweak_data.gui:icon_h(RaidGUIControlStepperSimple.BUTTON_RIGHT_TEXTURE),
		color = RaidGUIControlStepperSimple.BUTTON_COLOR,
		highlight_color = RaidGUIControlStepperSimple.BUTTON_HIGHLIGHT_COLOR,
		layer = self._object:layer() + 1,
		on_click_callback = callback(self, self, "on_right_arrow_clicked")
	}
	self._arrow_right = self._object:image_button(right_arrow_params)
	local label_params = {
		name = "stepper_simple_value",
		vertical = "center",
		align = "center",
		text = "VALUE",
		y = 0,
		x = self._arrow_left:w(),
		w = self._object:w() - self._arrow_left:w() - self._arrow_right:w(),
		h = self._object:h(),
		color = RaidGUIControlStepperSimple.TEXT_COLOR,
		layer = self._object:layer() + 1,
		font = RaidGUIControlStepperSimple.FONT,
		font_size = RaidGUIControlStepperSimple.FONT_SIZE
	}
	self._value_label = self._object:text(label_params)
	local stepper_data = self._data_source_callback()
	self._stepper_data = clone(stepper_data)
	self._selected_item_index = 1

	if sort_descending then
		self._selected_item_index = #self._stepper_data
	end

	if self._stepper_data then
		for item_index, item_data in pairs(self._stepper_data) do
			if item_data.selected then
				self._selected_item_index = item_index

				break
			end
		end
	end

	self:_select_item(self._selected_item_index, true)
end

-- Lines 146-148
function RaidGUIControlStepperSimple:selected_item()
	return self._stepper_data[self._selected_item_index]
end

-- Lines 151-180
function RaidGUIControlStepperSimple:_select_item(index, skip_animation)
	local item = self._stepper_data[index]
	local text = item.text or managers.localization:text(item.text_id)
	local disabled = item.disabled
	self._selected_item_index = index

	if index == 1 then
		self._arrow_left._object:set_alpha(0)
		self._arrow_right._object:set_alpha(1)
	elseif index == #self._stepper_data then
		self._arrow_left._object:set_alpha(1)
		self._arrow_right._object:set_alpha(0)
	else
		self._arrow_left._object:set_alpha(1)
		self._arrow_right._object:set_alpha(1)
	end

	if skip_animation then
		self._value_label:set_text(text)

		if index == 1 then
			self._arrow_left._object:set_alpha(0)
		elseif index == #self._stepper_data then
			self._arrow_right._object:set_alpha(0)
		end
	else
		self._value_label:stop()
		self._value_label:animate(callback(self, self, "_animate_value_change"), text, disabled)
	end
end

-- Lines 182-191
function RaidGUIControlStepperSimple:select_item_by_value(value)
	if self._stepper_data then
		for item_index, item_data in pairs(self._stepper_data) do
			if value == item_data.value then
				self:_select_item(item_index)

				return
			end
		end
	end
end

-- Lines 193-196
function RaidGUIControlStepperSimple:get_value()
	local item = self._stepper_data[self._selected_item_index]

	return item.value
end

-- Lines 198-214
function RaidGUIControlStepperSimple:set_value_and_render(value_to_select, skip_animation)
	if self._stepper_data then
		for key, value in pairs(self._stepper_data) do
			if type(value.value) == "table" then
				if value_to_select:is_equal(value.value) then
					self:_select_item(key, skip_animation)

					break
				end
			elseif utf8.to_upper(value.value) == utf8.to_upper(value_to_select) then
				self:_select_item(key, skip_animation)

				break
			end
		end
	end
end

-- Lines 216-218
function RaidGUIControlStepperSimple:_delete_stepper_items()
	self._stepper_panel:clear()
end

-- Lines 221-237
function RaidGUIControlStepperSimple:on_left_arrow_clicked()
	if not self._enabled then
		return
	end

	if self._selected_item_index > 1 then
		self._selected_item_index = self._selected_item_index - 1
	else
		return
	end

	self:_select_item(self._selected_item_index)

	if self._on_select_callback then
		self._on_select_callback(self._stepper_data[self._selected_item_index])
	end
end

-- Lines 240-256
function RaidGUIControlStepperSimple:on_right_arrow_clicked()
	if not self._enabled then
		return
	end

	if self._selected_item_index < #self._stepper_data then
		self._selected_item_index = self._selected_item_index + 1
	else
		return
	end

	self:_select_item(self._selected_item_index)

	if self._on_select_callback then
		self._on_select_callback(self._stepper_data[self._selected_item_index])
	end
end

-- Lines 259-279
function RaidGUIControlStepperSimple:mouse_moved(o, x, y)
	if not self:inside(x, y) then
		if self._mouse_inside then
			self._arrow_left:on_mouse_out()
			self._arrow_right:on_mouse_out()
		end

		self._mouse_inside = false

		return false, nil
	end

	self._mouse_inside = true
	local used = false
	local pointer = nil
	used, pointer = self._arrow_left:mouse_moved(o, x, y)

	if used then
		return used, pointer
	end

	used, pointer = self._arrow_right:mouse_moved(o, x, y)

	return used, pointer
end

-- Lines 282-284
function RaidGUIControlStepperSimple:mouse_released(o, button, x, y)
	return false
end

-- Lines 286-292
function RaidGUIControlStepperSimple:on_mouse_scroll_up()
	if not self._enabled then
		return
	end

	self:on_right_arrow_clicked()
end

-- Lines 294-300
function RaidGUIControlStepperSimple:on_mouse_scroll_down()
	if not self._enabled then
		return
	end

	self:on_left_arrow_clicked()
end

-- Lines 302-304
function RaidGUIControlStepperSimple:x()
	return self._stepper_panel._engine_panel:x()
end

-- Lines 306-308
function RaidGUIControlStepperSimple:w()
	return self._stepper_panel._engine_panel:w()
end

-- Lines 310-320
function RaidGUIControlStepperSimple:confirm_pressed()
	if not self._enabled then
		return
	end

	if self._selected then
		self._selected_control = not self._selected_control

		self:_select_control(self._selected_control)

		return true
	end
end

-- Lines 322-324
function RaidGUIControlStepperSimple:is_selected_control()
	return self._selected_control
end

-- Lines 327-328
function RaidGUIControlStepperSimple:_select_control(value)
end

-- Lines 330-339
function RaidGUIControlStepperSimple:move_down()
	if self._selected then
		self._selected_control = false

		self:_select_control(false)

		return self.super.move_down(self)
	end
end

-- Lines 341-350
function RaidGUIControlStepperSimple:move_up()
	if self._selected then
		self._selected_control = false

		self:_select_control(false)

		return self.super.move_up(self)
	end
end

-- Lines 352-367
function RaidGUIControlStepperSimple:set_enabled(enabled)
	RaidGUIControlStepperSimple.super.set_enabled(self, enabled)
	self._arrow_left:set_enabled(enabled)
	self._arrow_right:set_enabled(enabled)

	if enabled then
		if self._stepper_data[self._selected_item_index].disabled then
			self._value_label:set_color(RaidGUIControlStepperSimple.TEXT_COLOR_DISABLED)
		else
			self._value_label:set_color(RaidGUIControlStepperSimple.TEXT_COLOR)
		end
	else
		self._value_label:set_color(RaidGUIControlStepperSimple.TEXT_COLOR_DISABLED)
	end
end

-- Lines 402-439
function RaidGUIControlStepperSimple:_animate_value_change(o, text, disabled)
	local starting_alpha = self._value_label:alpha()
	local duration = 0.13
	local t = duration - starting_alpha * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.linear(t, 1, -1, duration)

		self._value_label:set_alpha(alpha)
	end

	self._value_label:set_alpha(0)
	self._value_label:set_text(text)

	if disabled then
		self._value_label:set_color(RaidGUIControlStepperSimple.TEXT_COLOR_DISABLED)
	else
		self._value_label:set_color(RaidGUIControlStepperSimple.TEXT_COLOR)
	end

	duration = 0.18
	t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 0, 1, duration)

		self._value_label:set_alpha(alpha)
	end

	self._value_label:set_alpha(1)
end
