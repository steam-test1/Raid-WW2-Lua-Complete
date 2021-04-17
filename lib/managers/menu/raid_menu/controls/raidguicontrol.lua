RaidGUIControl = RaidGUIControl or class()
RaidGUIControl.ID = 1

-- Lines 5-38
function RaidGUIControl:init(parent, params)
	self._type = self._type or "raid_gui_control"
	self._control_id = RaidGUIControl.ID
	RaidGUIControl.ID = RaidGUIControl.ID + 1
	self._name = params.name or self._type .. "_" .. self._control_id
	self._parent = parent
	self._parent_panel = params.panel or parent.get_panel and parent:get_panel() or parent:panel()
	self._params = clone(params)
	self._params.name = params.name or self._name
	self._mouse_inside = false
	self._params.color = params.color or Color.white
	self._params.layer = params.layer or self._parent_panel:layer() or RaidGuiBase.FOREGROUND_LAYER
	self._params.blend_mode = params.blend_mode or "normal"
	self._panel = self._parent_panel
	self._params.panel = self._panel
	self._pointer_type = "arrow"
	self._on_mouse_enter_callback = params.on_mouse_enter_callback
	self._on_mouse_exit_callback = params.on_mouse_exit_callback
	self._autoconfirm = params.autoconfirm
	self._on_menu_move = params.on_menu_move
	self._selected_control = false
	self._callback_handler = RaidMenuCallbackHandler:new()
	self._enabled = self._params.enabled or true
	self._selectable = self._params.selectable or true
end

-- Lines 40-42
function RaidGUIControl:name()
	return self._params.name
end

-- Lines 44-46
function RaidGUIControl:set_param_value(param_name, param_value)
	self._params[param_name] = param_value
end

-- Lines 48-73
function RaidGUIControl:create_border()
	if not self._object then
		return
	end

	local border_thickness = 1.6
	local x = self._object:x()
	local y = self._object:y()
	local w = self._object:w()
	local h = self._object:h()
	self._border_left = self._parent_panel:gradient({
		name = "border_left",
		orientation = "vertical",
		layer = 2,
		x = x,
		y = y,
		w = border_thickness,
		h = h
	})

	self._border_left:set_gradient_points({
		0,
		Color(0.19215686274509805, 0.23529411764705882, 0.25098039215686274),
		1,
		Color(0.3137254901960784, 0.40784313725490196, 0.35294117647058826)
	})

	self._border_right = self._parent_panel:gradient({
		name = "border_right",
		orientation = "vertical",
		layer = 2,
		x = x + w - border_thickness,
		y = y,
		w = border_thickness,
		h = h
	})

	self._border_right:set_gradient_points({
		0,
		Color(0.3058823529411765, 0.40784313725490196, 0.36470588235294116),
		1,
		Color(0.3411764705882353, 0.35294117647058826, 0.3176470588235294)
	})

	self._border_up = self._parent_panel:gradient({
		name = "border_up",
		orientation = "horizontal",
		layer = 2,
		x = x,
		y = y,
		w = w,
		h = border_thickness
	})

	self._border_up:set_gradient_points({
		0,
		Color(0.19215686274509805, 0.23529411764705882, 0.25098039215686274),
		0.38,
		Color(0.34901960784313724, 0.34901960784313724, 0.3411764705882353),
		0.544,
		Color(0.596078431372549, 0.6274509803921569, 0.5843137254901961),
		0.77,
		Color(0.34901960784313724, 0.34901960784313724, 0.3411764705882353),
		1,
		Color(0.3058823529411765, 0.40784313725490196, 0.36470588235294116)
	})

	self._border_down = self._parent_panel:gradient({
		name = "border_down",
		orientation = "horizontal",
		layer = 2,
		x = x,
		y = y + h - border_thickness,
		w = w,
		h = border_thickness
	})

	self._border_down:set_gradient_points({
		0,
		Color(0.3137254901960784, 0.40784313725490196, 0.35294117647058826),
		0.3,
		Color(0.596078431372549, 0.615686274509804, 0.592156862745098),
		0.69,
		Color(0.6039215686274509, 0.615686274509804, 0.5882352941176471),
		1,
		Color(0.3411764705882353, 0.35294117647058826, 0.3176470588235294)
	})
end

-- Lines 75-87
function RaidGUIControl:remove_border()
	if self._object then
		self._border_left:parent():remove(self._border_left)

		self._border_left = nil

		self._border_right:parent():remove(self._border_right)

		self._border_right = nil

		self._border_down:parent():remove(self._border_down)

		self._border_down = nil

		self._border_up:parent():remove(self._border_up)

		self._border_up = nil
	end
end

-- Lines 89-90
function RaidGUIControl:close()
end

-- Lines 92-108
function RaidGUIControl:translate(text, upper_case_flag, additional_macros)
	local button_macros = nil

	if additional_macros then
		button_macros = clone(managers.localization:get_default_macros())

		for index, macro in pairs(additional_macros) do
			button_macros[index] = macro
		end
	else
		button_macros = managers.localization:get_default_macros()
	end

	local result = managers.localization:text(text, button_macros)

	if upper_case_flag then
		result = utf8.to_upper(result)
	end

	return result
end

-- Lines 110-124
function RaidGUIControl:_show_dialog_error_msg(error_title, error_msg)
	local dialog_data = {
		title = error_title,
		text = error_msg
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	-- Lines 121-121
	function ok_button.callback_func()
	end

	managers.system_menu:show(dialog_data)
end

-- Lines 126-128
function RaidGUIControl:inside(x, y)
	return self._object and self._object:inside(x, y) and self._object:tree_visible()
end

-- Lines 130-144
function RaidGUIControl:mouse_moved(o, x, y)
	if self:inside(x, y) then
		if not self._mouse_inside then
			self:on_mouse_over(x, y)
		end

		self:on_mouse_moved(o, x, y)

		return true, self._pointer_type
	end

	if self._mouse_inside then
		self:on_mouse_out(x, y)
	end

	return false
end

-- Lines 146-152
function RaidGUIControl:mouse_pressed(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_pressed(button, x, y)
	end

	return false
end

-- Lines 154-160
function RaidGUIControl:mouse_clicked(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_clicked(button)
	end

	return false
end

-- Lines 162-168
function RaidGUIControl:mouse_released(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_released(button)
	end

	return false
end

-- Lines 170-175
function RaidGUIControl:mouse_scroll_up(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_scroll_up(button)
	end

	return false
end

-- Lines 177-182
function RaidGUIControl:mouse_scroll_down(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_scroll_down(button)
	end

	return false
end

-- Lines 184-189
function RaidGUIControl:mouse_double_click(o, button, x, y)
	if self:inside(x, y) and self.on_double_click then
		return self:on_double_click(button)
	end

	return false
end

-- Lines 191-192
function RaidGUIControl:on_mouse_moved(o, x, y)
end

-- Lines 194-202
function RaidGUIControl:on_mouse_over(x, y)
	self._mouse_inside = true

	self:highlight_on()

	if self._on_mouse_enter_callback then
		self:_on_mouse_enter_callback(self._data)
	end
end

-- Lines 204-212
function RaidGUIControl:on_mouse_out(x, y)
	self._mouse_inside = false

	self:highlight_off()

	if self._on_mouse_exit_callback then
		self:_on_mouse_exit_callback(self._data)
	end
end

-- Lines 214-216
function RaidGUIControl:on_mouse_pressed()
	return false
end

-- Lines 218-220
function RaidGUIControl:on_mouse_clicked()
	return false
end

-- Lines 222-225
function RaidGUIControl:on_mouse_released()
	return false
end

-- Lines 227-229
function RaidGUIControl:on_mouse_double_click()
	return false
end

-- Lines 231-233
function RaidGUIControl:on_mouse_scroll_up()
	return false
end

-- Lines 235-237
function RaidGUIControl:on_mouse_scroll_down()
	return false
end

-- Lines 239-250
function RaidGUIControl:highlight_on()
	if self._object and self._object.highlight_on then
		self._object:highlight_on()
	end
end

-- Lines 252-260
function RaidGUIControl:highlight_off()
	if self._object and self._object.highlight_off then
		self._object:highlight_off()
	end
end

-- Lines 262-264
function RaidGUIControl:show()
	self._object:show()
end

-- Lines 266-268
function RaidGUIControl:hide()
	self._object:hide()
end

-- Lines 270-272
function RaidGUIControl:center_x()
	return self._object:center_x()
end

-- Lines 274-276
function RaidGUIControl:center_y()
	return self._object:center_y()
end

-- Lines 278-280
function RaidGUIControl:set_center_x(x)
	self._object:set_center_x(x)
end

-- Lines 282-284
function RaidGUIControl:set_center_y(y)
	self._object:set_center_y(y)
end

-- Lines 286-288
function RaidGUIControl:set_center(x, y)
	self._object:set_center(x, y)
end

-- Lines 290-292
function RaidGUIControl:rotate(angle)
	self._object:rotate(angle)
end

-- Lines 294-296
function RaidGUIControl:set_rotation(angle)
	self._object:set_rotation(angle)
end

-- Lines 298-300
function RaidGUIControl:rotation()
	return self._object:rotation()
end

-- Lines 302-304
function RaidGUIControl:set_visible(visible)
	self._object:set_visible(visible)
end

-- Lines 306-314
function RaidGUIControl:visible()
	if self._object.alive then
		return self._object.alive and alive(self._object) and self._object:visible()
	else
		return self._object:visible()
	end
end

-- Lines 316-318
function RaidGUIControl:set_selectable(value)
	self._selectable = value
end

-- Lines 320-322
function RaidGUIControl:selectable()
	return self._selectable
end

-- Lines 324-328
function RaidGUIControl:set_alpha(alpha)
	if self._object.set_alpha then
		self._object:set_alpha(alpha)
	end
end

-- Lines 330-336
function RaidGUIControl:alpha()
	if self._object.alpha then
		return self._object:alpha()
	end

	return nil
end

-- Lines 338-340
function RaidGUIControl:set_x(x)
	self._object:set_x(x)
end

-- Lines 342-344
function RaidGUIControl:set_top(value)
	self._object:set_top(value)
end

-- Lines 346-348
function RaidGUIControl:set_bottom(value)
	self._object:set_bottom(value)
end

-- Lines 350-352
function RaidGUIControl:set_right(value)
	self._object:set_right(value)
end

-- Lines 354-356
function RaidGUIControl:set_left(value)
	self._object:set_left(value)
end

-- Lines 358-360
function RaidGUIControl:set_y(y)
	self._object:set_y(y)
end

-- Lines 362-364
function RaidGUIControl:set_w(w)
	self._object:set_w(w)
end

-- Lines 366-368
function RaidGUIControl:set_h(h)
	self._object:set_h(h)
end

-- Lines 370-372
function RaidGUIControl:w()
	return self._object:w()
end

-- Lines 374-376
function RaidGUIControl:h()
	return self._object:h()
end

-- Lines 378-380
function RaidGUIControl:x()
	return self._object:x()
end

-- Lines 382-384
function RaidGUIControl:y()
	return self._object:y()
end

-- Lines 386-388
function RaidGUIControl:world_x()
	return self._object:world_x()
end

-- Lines 390-392
function RaidGUIControl:world_y()
	return self._object:world_y()
end

-- Lines 394-396
function RaidGUIControl:layer()
	return self._object:layer()
end

-- Lines 398-400
function RaidGUIControl:set_layer(layer)
	return self._object._engine_panel:set_layer(layer)
end

-- Lines 408-410
function RaidGUIControl:left()
	return self._object:left()
end

-- Lines 412-414
function RaidGUIControl:right()
	return self._object:right()
end

-- Lines 415-417
function RaidGUIControl:top()
	return self._object:top()
end

-- Lines 419-421
function RaidGUIControl:bottom()
	return self._object:bottom()
end

-- Lines 423-431
function RaidGUIControl:set_selected(value)
	self._selected = value

	if self._selected then
		self:highlight_on()
	else
		self:highlight_off()
	end
end

-- Lines 433-435
function RaidGUIControl:is_selected()
	return self._selected
end

-- Lines 437-441
function RaidGUIControl:move_up()
	if self._selected and self._on_menu_move and self._on_menu_move.up then
		return self:_menu_move_to(self._on_menu_move.up, "up")
	end
end

-- Lines 443-447
function RaidGUIControl:move_down()
	if self._selected and self._on_menu_move and self._on_menu_move.down then
		return self:_menu_move_to(self._on_menu_move.down, "down")
	end
end

-- Lines 449-453
function RaidGUIControl:move_left()
	if self._selected and self._on_menu_move and self._on_menu_move.left then
		return self:_menu_move_to(self._on_menu_move.left, "left")
	end
end

-- Lines 455-459
function RaidGUIControl:move_right()
	if self._selected and self._on_menu_move and self._on_menu_move.right then
		return self:_menu_move_to(self._on_menu_move.right, "right")
	end
end

-- Lines 461-463
function RaidGUIControl:scroll_up()
	return false
end

-- Lines 465-467
function RaidGUIControl:scroll_down()
	return false
end

-- Lines 469-471
function RaidGUIControl:scroll_left()
	return false
end

-- Lines 473-475
function RaidGUIControl:scroll_right()
	return false
end

-- Lines 477-479
function RaidGUIControl:special_btn_pressed(...)
end

-- Lines 481-483
function RaidGUIControl:set_menu_move_controls(controls)
	self._on_menu_move = controls
end

-- Lines 485-507
function RaidGUIControl:_menu_move_to(target_control_name, direction)
	local component_controls = managers.menu_component._active_controls

	for _, controls in pairs(component_controls) do
		for _, control in pairs(controls) do
			if control._name == target_control_name then
				if control:visible() and control:selectable() and control:enabled() then
					self:set_selected(false)

					if control._autoconfirm then
						if control._on_click_callback then
							control:_on_click_callback()
						end
					else
						control:set_selected(true)
					end

					return true
				else
					return self:_find_next_visible_control(control, direction)
				end
			end
		end
	end

	return nil, target_control_name
end

-- Lines 509-516
function RaidGUIControl:_find_next_visible_control(control_ref, direction)
	local next_control_name = control_ref and control_ref._on_menu_move and control_ref._on_menu_move[direction]

	if next_control_name then
		self:_menu_move_to(next_control_name, direction)
	else
		return false
	end
end

-- Lines 518-519
function RaidGUIControl:confirm_pressed()
end

-- Lines 522-540
function RaidGUIControl:check_item_availability(item, availability_flags)
	if not availability_flags then
		return true
	end

	self._callback_handler = self._callback_handler or RaidMenuCallbackHandler:new()
	local result = true

	for _, availability_flag in pairs(availability_flags) do
		local availability_callback = callback(self._callback_handler, self._callback_handler, availability_flag)

		if availability_callback then
			result = result and availability_callback()
		end
	end

	return result
end

-- Lines 544-546
function RaidGUIControl:scrollable_area_post_setup(params)
end

-- Lines 550-552
function RaidGUIControl:enabled()
	return self._enabled
end

-- Lines 554-556
function RaidGUIControl:set_enabled(enabled)
	self._enabled = enabled
end
