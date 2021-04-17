RaidGuiBase = RaidGuiBase or class()
RaidGuiBase.BACKGROUND_LAYER = 10
RaidGuiBase.FOREGROUND_LAYER = 20
RaidGuiBase.PADDING = 42
RaidGuiBase.Colors = {
	screen_background = Color(0.85, 0, 0, 0)
}

-- Lines 10-41
function RaidGuiBase:init(ws, fullscreen_ws, node, component_name)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))

	self._name = component_name
	self._ws = ws
	self._fullscreen_ws = fullscreen_ws
	self._node = node
	self._ws_panel = self._ws:panel()
	self._ws_panel = self._ws_panel:panel({
		name = self._name .. "_ws_panel",
		background_color = self._background_color,
		x = self._panel_x,
		y = self._panel_y,
		h = self._panel_h,
		w = self._panel_w,
		layer = self._panel_layer
	})
	self._fullscreen_ws_panel = self._fullscreen_ws:panel()

	self:_setup_properties()
	self:_clear_controller_bindings()

	if not node.components then
		node.components = {}
	end

	self._node.components[self._name] = self
	self._controls = {}

	self:_set_initial_data()

	local params_root_panel = {
		name = self._name .. "_panel",
		background_color = self._background_color,
		x = self._panel_x,
		y = self._panel_y,
		h = self._panel_h,
		w = self._panel_w,
		layer = self._panel_layer,
		is_root_panel = self._panel_is_root_panel
	}
	self._root_panel = RaidGUIPanel:new(self._ws_panel, params_root_panel)

	self:_layout()
	managers.menu_component:post_event("menu_enter")
end

-- Lines 54-62
function RaidGuiBase:_setup_properties()
	self._panel_x = 0
	self._panel_y = 0
	self._panel_w = self._ws:width()
	self._panel_h = self._ws:height()
	self._panel_layer = RaidGuiBase.FOREGROUND_LAYER
	self._panel_is_root_panel = true
	self._background = true
end

-- Lines 66-68
function RaidGuiBase:_set_initial_data()
end

-- Lines 71-78
function RaidGuiBase:translate(text, upper_case_flag)
	local button_macros = managers.localization:get_default_macros()
	local result = managers.localization:text(text, button_macros)

	if upper_case_flag then
		result = utf8.to_upper(result)
	end

	return result
end

-- Lines 80-86
function RaidGuiBase:_disable_dof()
	self._odof_near, self._odof_near_pad, self._odof_far, self._odof_far_pad = managers.environment_controller:get_dof_override_ranges()

	managers.environment_controller:set_dof_override(true)
	managers.environment_controller:set_dof_override_ranges(0, 0, 100000, 0)
end

-- Lines 88-91
function RaidGuiBase:_enable_dof()
	managers.environment_controller:set_dof_override_ranges(self._odof_near, self._odof_near_pad, self._odof_far, self._odof_far_pad)
	managers.environment_controller:set_dof_override(false)
end

-- Lines 93-94
function RaidGuiBase:_layout()
end

-- Lines 97-112
function RaidGuiBase:_create_border()
	local border_thickness = 1.6
	self._border_left = self._root_panel:gradient({
		name = "border_left",
		y = 0,
		orientation = "vertical",
		x = 0,
		layer = 100,
		w = border_thickness,
		h = self._root_panel:h()
	})

	self._border_left:set_gradient_points({
		0,
		Color(0.19215686274509805, 0.23529411764705882, 0.25098039215686274),
		1,
		Color(0.3137254901960784, 0.40784313725490196, 0.35294117647058826)
	})

	self._border_right = self._root_panel:gradient({
		name = "border_right",
		y = 0,
		orientation = "vertical",
		layer = 100,
		x = self._root_panel:w() - border_thickness,
		w = border_thickness,
		h = self._root_panel:h()
	})

	self._border_right:set_gradient_points({
		0,
		Color(0.3058823529411765, 0.40784313725490196, 0.36470588235294116),
		1,
		Color(0.3411764705882353, 0.35294117647058826, 0.3176470588235294)
	})

	self._border_up = self._root_panel:gradient({
		name = "border_up",
		y = 0,
		orientation = "horizontal",
		x = 0,
		layer = 100,
		w = self._root_panel:w(),
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

	self._border_down = self._root_panel:gradient({
		name = "border_down",
		orientation = "horizontal",
		x = 0,
		layer = 100,
		y = self._root_panel:h() - border_thickness,
		w = self._root_panel:w(),
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

-- Lines 155-164
function RaidGuiBase:_remove_border()
	self._border_left:parent():remove(self._border_left)

	self._border_left = nil

	self._border_right:parent():remove(self._border_right)

	self._border_right = nil

	self._border_down:parent():remove(self._border_down)

	self._border_down = nil

	self._border_up:parent():remove(self._border_up)

	self._border_up = nil
end

-- Lines 167-178
function RaidGuiBase:close()
	self._node.components[self._name] = nil

	for _, control in ipairs(self._controls) do
		control:close()
	end

	self._root_panel:close()
	self._ws_panel:clear()
	self._fullscreen_ws_panel:clear()
	managers.menu_component:post_event("menu_exit")
end

-- Lines 181-188
function RaidGuiBase:mouse_moved(o, x, y)
	local active_control = managers.raid_menu:get_active_control()

	if active_control then
		local used, pointer = active_control:on_mouse_moved(o, x, y)

		return used, pointer
	end

	return self._root_panel:mouse_moved(o, x, y)
end

-- Lines 190-201
function RaidGuiBase:mouse_pressed(o, button, x, y)
	if button == Idstring("mouse wheel up") then
		return self._root_panel:mouse_scroll_up(o, button, x, y)
	elseif button == Idstring("mouse wheel down") then
		return self._root_panel:mouse_scroll_down(o, button, x, y)
	else
		return self._root_panel:mouse_pressed(o, button, x, y)
	end
end

-- Lines 203-205
function RaidGuiBase:mouse_clicked(o, button, x, y)
	return self._root_panel:mouse_clicked(o, button, x, y)
end

-- Lines 207-209
function RaidGuiBase:mouse_double_click(o, button, x, y)
	return self._root_panel:mouse_double_click(o, button, x, y)
end

-- Lines 212-220
function RaidGuiBase:mouse_released(o, button, x, y)
	local is_left_click = button == Idstring("0")

	if not is_left_click then
		return true
	end

	managers.raid_menu:clear_active_control()

	return self._root_panel:mouse_released(o, button, x, y)
end

-- Lines 222-226
function RaidGuiBase:back_pressed()
	managers.raid_menu:on_escape()

	return true
end

-- Lines 228-231
function RaidGuiBase:move_up()
	return self._root_panel:move_up()
end

-- Lines 233-236
function RaidGuiBase:move_down()
	return self._root_panel:move_down()
end

-- Lines 238-241
function RaidGuiBase:move_left()
	return self._root_panel:move_left()
end

-- Lines 243-246
function RaidGuiBase:move_right()
	return self._root_panel:move_right()
end

-- Lines 248-250
function RaidGuiBase:scroll_up()
	return self._root_panel:scroll_up()
end

-- Lines 252-254
function RaidGuiBase:scroll_down()
	return self._root_panel:scroll_down()
end

-- Lines 256-258
function RaidGuiBase:scroll_left()
	return self._root_panel:scroll_left()
end

-- Lines 260-262
function RaidGuiBase:scroll_right()
	return self._root_panel:scroll_right()
end

-- Lines 264-267
function RaidGuiBase:confirm_pressed()
	return self._root_panel:confirm_pressed()
end

-- Lines 269-271
function RaidGuiBase:on_escape()
	return false
end

-- Lines 275-277
function RaidGuiBase:_clear_controller_bindings()
	self._controller_bindings = {}
end

-- Lines 283-300
function RaidGuiBase:set_controller_bindings(bindings, clear_old)
	if clear_old then
		self:_clear_controller_bindings()
	end

	for _, binding in ipairs(bindings) do
		local found = false

		for index, current_binding in ipairs(self._controller_bindings) do
			if current_binding.key == binding.key then
				self._controller_bindings[index] = binding
				found = true
			end
		end

		if not found then
			table.insert(self._controller_bindings, binding)
		end
	end
end

-- Lines 302-319
function RaidGuiBase:special_btn_pressed(button)
	local binding_to_trigger = nil

	for index, binding in ipairs(self._controller_bindings) do
		if binding.key == button then
			binding_to_trigger = binding
		end
	end

	if binding_to_trigger then
		return binding_to_trigger.callback(binding_to_trigger.data)
	end

	return false, nil
end

-- Lines 321-323
function RaidGuiBase:set_legend(legend)
	managers.raid_menu:set_legend_labels(legend)
end

-- Lines 325-327
function RaidGuiBase:_on_legend_pc_back()
	managers.raid_menu:on_escape()
end
