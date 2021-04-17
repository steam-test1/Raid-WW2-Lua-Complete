core:module("CoreMenuInput")
core:import("CoreDebug")
core:import("CoreMenuItem")
core:import("CoreMenuItemSlider")
core:import("CoreMenuItemToggle")

MenuInput = MenuInput or class()

-- Lines 9-29
function MenuInput:init(logic, menu_name)
	self._logic = logic
	self._menu_name = menu_name
	self._accept_input = true

	self._logic:register_callback("input_accept_input", callback(self, self, "accept_input"))

	self._axis_delay_timer = {
		x = 0,
		y = 0
	}
	self._scroll_delay_timer = {
		x = 0,
		y = 0
	}
	self._item_input_action_map = {
		[CoreMenuItem.Item.TYPE] = callback(self, self, "input_item"),
		[CoreMenuItemSlider.ItemSlider.TYPE] = callback(self, self, "input_slider"),
		[CoreMenuItemToggle.ItemToggle.TYPE] = callback(self, self, "input_toggle")
	}
end

-- Lines 31-33
function MenuInput:open(...)
	self:create_controller()
end

-- Lines 35-37
function MenuInput:close()
	self:destroy_controller()
end

-- Lines 39-41
function MenuInput:axis_timer()
	return self._axis_delay_timer
end

-- Lines 44-46
function MenuInput:set_axis_x_timer(time)
	self._axis_delay_timer.x = time
end

-- Lines 47-49
function MenuInput:set_axis_y_timer(time)
	self._axis_delay_timer.y = time
end

-- Lines 51-53
function MenuInput:scroll_timer()
	return self._scroll_delay_timer
end

-- Lines 56-58
function MenuInput:set_scroll_x_timer(time)
	self._scroll_delay_timer.x = time
end

-- Lines 59-61
function MenuInput:set_scroll_y_timer(time)
	self._scroll_delay_timer.y = time
end

-- Lines 63-66
function MenuInput:_input_hijacked()
	local active_menu = managers.menu:active_menu()

	return active_menu and active_menu.renderer:input_focus()
end

-- Lines 69-89
function MenuInput:input_item(item, controller, mouse_click)
	if controller:get_input_pressed("confirm") or mouse_click then
		if item:parameters().sign_in then
			print("requires sign in")

			-- Lines 73-73
			local function f(success)
				print(success)

				if success then
					self._logic:trigger_item(true, item)
					self:select_node()
				end
			end

			managers.menu:open_sign_in_menu(f)
		else
			local node_gui = managers.menu:active_menu().renderer:active_node_gui()

			if node_gui and node_gui._listening_to_input then
				return
			end

			self._logic:trigger_item(true, item)
			self:select_node()
		end
	end
end

-- Lines 92-120
function MenuInput:input_slider(item, controller)
	local slider_delay_down = 0.1
	local slider_delay_pressed = 0.2

	if self:menu_right_input_bool() then
		item:increase()
		self._logic:trigger_item(true, item)
		self:set_axis_x_timer(slider_delay_down)

		if self:menu_right_pressed() then
			local percentage = item:percentage()

			if percentage > 0 and percentage < 100 then
				self:post_event("slider_increase")
			end

			self:set_axis_x_timer(slider_delay_pressed)
		end
	elseif self:menu_left_input_bool() then
		item:decrease()
		self._logic:trigger_item(true, item)
		self:set_axis_x_timer(slider_delay_down)

		if self:menu_left_pressed() then
			self:set_axis_x_timer(slider_delay_pressed)

			local percentage = item:percentage()

			if percentage > 0 and percentage < 100 then
				self:post_event("slider_decrease")
			end
		end
	end
end

-- Lines 123-147
function MenuInput:input_toggle(item, controller, mouse_click)
	local toggle_delay_down = 0.3
	local toggle_delay_pressed = 0.6

	if controller:get_input_pressed("confirm") or mouse_click then
		item:toggle()
		self._logic:trigger_item(true, item)
	end
end

-- Lines 149-221
function MenuInput:update(t, dt)
	self:_check_releases()
	self:any_keyboard_used()

	local axis_timer = self:axis_timer()
	local scroll_timer = self:scroll_timer()

	if axis_timer.y > 0 then
		self:set_axis_y_timer(axis_timer.y - dt)
	end

	if axis_timer.x > 0 then
		self:set_axis_x_timer(axis_timer.x - dt)
	end

	if scroll_timer.y > 0 then
		self:set_scroll_y_timer(scroll_timer.y - dt)
	end

	if scroll_timer.x > 0 then
		self:set_scroll_x_timer(scroll_timer.x - dt)
	end

	if self:_input_hijacked() then
		return false
	end

	if self._accept_input and self._controller then
		if axis_timer.y <= 0 then
			if self:menu_up_input_bool() then
				managers.menu:active_menu().renderer:move_up()
				self:prev_item()
				self:set_axis_y_timer(0.12)

				if self:menu_up_pressed() then
					self:set_axis_y_timer(0.3)
				end
			elseif self:menu_down_input_bool() then
				managers.menu:active_menu().renderer:move_down()
				self:next_item()
				self:set_axis_y_timer(0.12)

				if self:menu_down_pressed() then
					self:set_axis_y_timer(0.3)
				end
			end
		end

		if axis_timer.x <= 0 then
			local item = self._logic:selected_item()

			if item then
				self._item_input_action_map[item.TYPE](item, self._controller)
			end
		end

		if self._controller:get_input_pressed("menu_update") then
			print("update something")
			self._logic:update_node()
		end
	end

	return true
end

-- Lines 224-229
function MenuInput:menu_up_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_up")
	end

	return false
end

-- Lines 231-236
function MenuInput:menu_up_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_up")
	end

	return false
end

-- Lines 238-243
function MenuInput:menu_up_released()
	if self._controller then
		return self._controller:get_input_released("menu_up")
	end

	return false
end

-- Lines 246-251
function MenuInput:menu_down_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_down")
	end

	return false
end

-- Lines 253-258
function MenuInput:menu_down_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_down")
	end

	return false
end

-- Lines 260-265
function MenuInput:menu_down_released()
	if self._controller then
		return self._controller:get_input_released("menu_down")
	end

	return false
end

-- Lines 268-273
function MenuInput:menu_left_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_left")
	end

	return false
end

-- Lines 275-280
function MenuInput:menu_left_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_left")
	end

	return false
end

-- Lines 282-287
function MenuInput:menu_left_released()
	if self._controller then
		return self._controller:get_input_released("menu_left")
	end

	return false
end

-- Lines 290-295
function MenuInput:menu_right_input_bool()
	if self._controller then
		return self._controller:get_input_bool("menu_right")
	end

	return false
end

-- Lines 297-302
function MenuInput:menu_right_pressed()
	if self._controller then
		return self._controller:get_input_pressed("menu_right")
	end

	return false
end

-- Lines 303-308
function MenuInput:menu_right_released()
	if self._controller then
		return self._controller:get_input_released("menu_right")
	end

	return false
end

-- Lines 359-367
function MenuInput:_check_releases()
	if self:menu_left_released() or self:menu_right_released() then
		self:set_axis_x_timer(0.01)
	end

	if self:menu_up_released() or self:menu_down_released() then
		self:set_axis_y_timer(0.01)
	end
end

-- Lines 369-371
function MenuInput:accept_input(accept)
	self._accept_input = accept
end

-- Lines 373-380
function MenuInput:focus(focus)
	if focus then
		self:create_controller()
	else
		self:destroy_controller()
	end
end

-- Lines 382-386
function MenuInput:controller_hotswap_triggered()
	self._controller = nil

	self:create_controller()
end

-- Lines 388-398
function MenuInput:create_controller()
	if not self._controller then
		local controller = managers.controller:create_controller(nil, nil, false)

		controller:add_trigger("cancel", callback(self, self, "back"))
		controller:set_enabled(true)

		self._controller = controller

		managers.controller:add_hotswap_callback("menu_input", callback(self, self, "controller_hotswap_triggered"))
	end
end

-- Lines 400-405
function MenuInput:destroy_controller()
	if self._controller then
		self._controller:destroy()

		self._controller = nil
	end
end

-- Lines 407-408
function MenuInput:logic_changed()
end

-- Lines 410-439
function MenuInput:next_item()
	if not self._accept_input then
		return
	end

	local current_item = self._logic:selected_item()

	if current_item then
		local current_item_name = current_item:parameters().name
		local items = self._logic:selected_node():items()
		local done = nil

		for i, v in ipairs(items) do
			if v:parameters().name == current_item_name then
				for check = 1, #items - 1 do
					local next_item = items[(i + check - 1) % #items + 1]

					if next_item:visible() and next_item.TYPE ~= "divider" then
						self._logic:select_item(next_item:parameters().name, true)

						done = true

						break
					end
				end

				if done then
					break
				end
			end
		end
	end
end

-- Lines 441-466
function MenuInput:prev_item()
	local current_item = self._logic:selected_item()

	if current_item then
		local current_item_name = current_item:parameters().name
		local items = self._logic:selected_node():items()
		local done = nil

		for i, v in ipairs(items) do
			if v:parameters().name == current_item_name then
				for check = 1, #items - 1 do
					local prev_item = items[(i - check - 1) % #items + 1]

					if prev_item:visible() and prev_item.TYPE ~= "divider" then
						self._logic:select_item(prev_item:parameters().name, true)

						done = true

						break
					end
				end

				if done then
					break
				end
			end
		end
	end
end

-- Lines 470-480
function MenuInput:back(queue, skip_nodes)
	if self:_input_hijacked() == true then
		return
	end

	if self._logic:selected_node() and self._logic:selected_node():parameters().block_back then
		return
	end

	self._logic:navigate_back(queue == true or false, type(skip_nodes) == "number" and skip_nodes or false)
end

-- Lines 482-496
function MenuInput:select_node()
	local item = self._logic:selected_item()

	if item and item:visible() then
		local parameters = item:parameters()

		if parameters.next_node and (item:enabled() or parameters.ignore_disabled) then
			self._logic:select_node(parameters.next_node, true, unpack(parameters.next_node_parameters or {}))
		end

		if parameters.previous_node then
			self:back()
		end
	end
end

-- Lines 498-510
function MenuInput:any_keyboard_used()
	if self._keyboard_used or not self._controller or managers.controller:get_default_wrapper_type() ~= "pc" and managers.controller:get_default_wrapper_type() ~= "steam" then
		return
	end

	for _, key in ipairs({
		"menu_right",
		"menu_left",
		"menu_up",
		"menu_down",
		"confirm"
	}) do
		if self._controller:get_input_bool(key) then
			self._keyboard_used = true

			return
		end
	end
end
