MousePointerManager = MousePointerManager or class()

-- Lines 3-6
function MousePointerManager:init()
	self._tweak_data = tweak_data.gui.mouse_pointer

	self:_setup()
end

local is_editor = Application:editor()

-- Lines 9-41
function MousePointerManager:_setup()
	self._mouse_callbacks = {}
	self._id = 0
	self._controller_updater = nil
	self._controller_x = nil
	self._controller_y = nil
	self._test_controller_acc = nil
	self._enabled = true
	self._ws = managers.gui_data:create_fullscreen_workspace()

	if not is_editor and not managers.viewport:is_fullscreen() then
		self:unacquire_input()
	end

	local x = 640
	local y = 360
	self._mouse = self._ws:panel():panel({
		name = "mouse",
		h = 23,
		w = 19,
		name_s = "mouse",
		x = x,
		y = y,
		layer = tweak_data.gui.MOUSE_LAYER
	})

	self._mouse:bitmap({
		texture = "guis/textures/mouse_pointer",
		name = "pointer",
		h = 23,
		rotation = 360,
		w = 19,
		y = -2,
		x = -7,
		texture_rect = {
			0,
			0,
			19,
			23
		},
		color = Color(1, 0.7, 0.7, 0.7)
	})
	self._ws:hide()

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
end

-- Lines 43-59
function MousePointerManager:unacquire_input()
	Input:mouse():unacquire()
	Input:mouse():set_deviceless(true)

	local base_aspect = tweak_data.gui.base_resolution.x / tweak_data.gui.base_resolution.y
	local xscale = tweak_data.gui.base_resolution.x / (RenderSettings.resolution.y * base_aspect)
	local yscale = tweak_data.gui.base_resolution.x / (RenderSettings.resolution.y * base_aspect)

	if RenderSettings.resolution.x / RenderSettings.resolution.y <= base_aspect + 0.0001 then
		xscale = tweak_data.gui.base_resolution.x / RenderSettings.resolution.x
		yscale = tweak_data.gui.base_resolution.x / RenderSettings.resolution.x
	end

	self._ws:set_absolute_mouse(xscale, yscale, 0, 0)
end

-- Lines 61-68
function MousePointerManager:acquire_input()
	Input:mouse():acquire()
	Input:mouse():set_deviceless(false)
	self._ws:set_relative_mouse(1, 0)
end

-- Lines 70-78
function MousePointerManager:resolution_changed()
	if not is_editor and not managers.viewport:is_fullscreen() then
		self:unacquire_input()
	end

	managers.gui_data:layout_fullscreen_workspace(self._ws)
end

-- Lines 80-93
function MousePointerManager:set_pointer_image(type)
	local types = {
		arrow = {
			0,
			0,
			19,
			23
		},
		link = {
			20,
			0,
			19,
			23
		},
		hand = {
			40,
			0,
			19,
			23
		},
		grab = {
			60,
			0,
			19,
			23
		},
		none = {
			0,
			0,
			0,
			0
		}
	}
	local rect = types[type]

	if rect and self._mouse_pointer_image ~= type then
		self._mouse_pointer_image = type

		self._mouse:child("pointer"):set_texture_rect(rect[1], rect[2], rect[3], rect[4])
	end
end

-- Lines 95-100
function MousePointerManager:_scaled_size()
	return managers.gui_data:scaled_size()
end

-- Lines 102-117
function MousePointerManager:_set_size()
	local safe_rect = managers.viewport:get_safe_rect_pixels()
	local scaled_size = self:_scaled_size()
	local res = RenderSettings.resolution
	local w = scaled_size.width
	local h = scaled_size.height
	local y = res.y / 2 - res.x / w * h / 2
	local n = w / math.clamp(res.x, 0, w)
	local m = res.x / res.y

	print("safe_rect.x, y+safe_rect.y", safe_rect.x, y + safe_rect.y)
	self._ws:set_screen(w, h, 0, 0, 1919)
end

-- Lines 119-123
function MousePointerManager:get_id()
	local id = "mouse_pointer_id" .. tostring(self._id)
	self._id = self._id + 1

	return id
end

-- Lines 125-199
function MousePointerManager:change_mouse_to_controller(controller)
	if not self._controller_updater then
		self._ws:disconnect_mouse()
		self:_deactivate()

		self._controller_x = 0
		self._controller_y = 0
		self._controller_acc_x = 0
		self._controller_acc_y = 0
		self._test_controller_acc = nil

		-- Lines 136-192
		local function update_controller_pointer(o, self)
			local ws = self._ws
			local mouse = self._mouse
			local confine_panel = self._confine_panel
			local convert_mouse_pos = self.convert_mouse_pos
			local max = math.max
			local min = math.min
			local move_x = 0
			local move_y = 0
			local acc = 0
			local dt = 0
			local tweak_data = self._tweak_data.controller
			local acc_speed = tweak_data.acceleration_speed
			local max_acc = tweak_data.max_acceleration
			local mouse_speed = tweak_data.mouse_pointer_speed

			while true do
				if self._enabled and (self._controller_x ~= 0 or self._controller_y ~= 0) then
					self._controller_acc_x = self._controller_x * max(1, acc)
					self._controller_acc_y = -(self._controller_y * max(1, acc))
					acc = min(acc + dt * acc_speed, max_acc)
					move_x = self._controller_acc_x * mouse_speed * dt
					move_y = self._controller_acc_y * mouse_speed * dt

					if confine_panel then
						local converted_x, converted_y = convert_mouse_pos(self, mouse:world_x() + move_x, mouse:world_y() + move_y)
						local outside_left = math.max(0, confine_panel:world_left() - converted_x + 1)
						local outside_right = math.max(0, converted_x - confine_panel:world_right() + o:w() + 1)
						local outside_top = math.max(0, confine_panel:world_top() - converted_y + 1)
						local outside_bottom = math.max(0, converted_y - confine_panel:world_bottom() + o:h() + 1)

						mouse:move(outside_left - outside_right, outside_top - outside_bottom)
					end

					mouse:move(move_x, move_y)

					if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_move then
						self._mouse_callbacks[#self._mouse_callbacks].mouse_move(mouse, mouse:x(), mouse:y(), ws)
					end
				else
					self._controller_acc_x = 0
					self._controller_acc_y = 0
					acc = 0
				end

				dt = coroutine.yield()
			end
		end

		self._ws:connect_controller(controller, true)

		self._controller_updater = self._mouse:animate(update_controller_pointer, self)

		return true
	end
end

-- Lines 201-215
function MousePointerManager:change_controller_to_mouse()
	if self._controller_updater then
		self._mouse:stop(self._controller_updater)
		self._ws:disconnect_all_controllers()
		self:_deactivate()
		self._ws:connect_mouse(managers.controller:get_mouse_controller())

		self._controller_updater = nil
		self._controller_acc_x = 0
		self._controller_acc_y = 0

		return true
	end
end

-- Lines 217-236
function MousePointerManager:use_mouse(params, position)
	for _, active_params in ipairs(self._mouse_callbacks) do
		if params.id == active_params.id then
			Application:error("[MousePointerManager][use_mouse] Trying to use a mouse that is already used ", params.id)

			return
		end
	end

	if position then
		table.insert(self._mouse_callbacks, position, params)
	else
		table.insert(self._mouse_callbacks, params)
	end

	self:_activate()
end

-- Lines 238-261
function MousePointerManager:remove_mouse(id)
	local removed = false

	if id then
		for i, params in ipairs(self._mouse_callbacks) do
			if params.id == id then
				removed = true

				table.remove(self._mouse_callbacks, i)

				break
			end
		end
	end

	if not removed then
		table.remove(self._mouse_callbacks)
	end

	if #self._mouse_callbacks <= 0 then
		self:_deactivate()
	end
end

-- Lines 263-285
function MousePointerManager:_activate()
	if self._active then
		return
	end

	self._active = true
	self._enabled = true

	self._ws:show()
	self._ws:connect_mouse(managers.controller:get_mouse_controller())
	self._ws:feed_mouse_position(self._mouse:world_position())

	if not self._controller_updater then
		self._mouse:mouse_move(callback(self, self, "_mouse_move"))
		self._mouse:mouse_press(callback(self, self, "_mouse_press"))
		self._mouse:mouse_release(callback(self, self, "_mouse_release"))
		self._mouse:mouse_click(callback(self, self, "_mouse_click"))
		self._mouse:mouse_double_click(callback(self, self, "_mouse_double_click"))
	else
		self._mouse:axis_move(callback(self, self, "_axis_move"))
		self._mouse:button_press(nil)
		self._mouse:button_release(nil)
		self._mouse:button_click(nil)
	end
end

-- Lines 287-301
function MousePointerManager:_deactivate()
	self._active = false
	self._enabled = nil

	self._ws:hide()
	self._mouse:mouse_move(nil)
	self._mouse:mouse_press(nil)
	self._mouse:mouse_release(nil)
	self._mouse:mouse_click(nil)
	self._mouse:mouse_double_click(nil)
	self._mouse:axis_move(nil)
	self._mouse:button_press(nil)
	self._mouse:button_release(nil)
	self._mouse:button_click(nil)
end

-- Lines 303-308
function MousePointerManager:enable()
	if self._active then
		self._ws:show()
	end

	self._enabled = true
end

-- Lines 310-315
function MousePointerManager:disable()
	if self._active then
		self._ws:hide()
	end

	self._enabled = false
end

-- Lines 317-319
function MousePointerManager:confine_mouse_pointer(panel)
	self._confine_panel = panel
end

-- Lines 321-323
function MousePointerManager:release_mouse_pointer()
	self._confine_panel = nil
end

-- Lines 325-327
function MousePointerManager:mouse_move_x()
	return self._controller_acc_x
end

-- Lines 328-330
function MousePointerManager:mouse_move_y()
	return self._controller_acc_y
end

-- Lines 332-339
function MousePointerManager:_mouse_move(o, x, y)
	o:set_position(x, y)

	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_move then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_move(o, x, y, self._ws)
	end
end

-- Lines 341-343
function MousePointerManager:_modify_mouse_button(button)
	return button
end

-- Lines 345-355
function MousePointerManager:_mouse_press(o, button, x, y)
	button = self:_modify_mouse_button(button)

	if not button then
		return
	end

	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_press then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_press(o, button, x, y)
	end
end

-- Lines 357-367
function MousePointerManager:_mouse_release(o, button, x, y)
	button = self:_modify_mouse_button(button)

	if not button then
		return
	end

	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_release then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_release(o, button, x, y)
	end
end

-- Lines 369-379
function MousePointerManager:_mouse_click(o, button, x, y)
	button = self:_modify_mouse_button(button)

	if not button then
		return
	end

	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_click then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_click(o, button, x, y)
	end
end

-- Lines 381-391
function MousePointerManager:_mouse_double_click(o, button, x, y)
	button = self:_modify_mouse_button(button)

	if not button then
		return
	end

	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_double_click then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_double_click(o, button, x, y)
	end
end

-- Lines 394-407
function MousePointerManager:_axis_move(o, axis_name, axis_vector, controller)
	if not self._test_controller_acc then
		self._test_controller_acc = {}
	end

	self._test_controller_acc[axis_name:key()] = axis_vector
	self._controller_x = 0
	self._controller_y = 0

	for i, axis in pairs(self._test_controller_acc) do
		self._controller_x = self._controller_x + axis.x
		self._controller_y = self._controller_y + axis.y
	end
end

-- Lines 409-415
function MousePointerManager:_button_press(o, button, controller)
	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_press then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_press(o, button, o:x(), o:y())
	end
end

-- Lines 417-424
function MousePointerManager:_button_release(o, button, controller)
	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_release then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_release(o, button, o:x(), o:y())
	end
end

-- Lines 426-433
function MousePointerManager:_button_click(o, button, controller)
	if self._mouse_callbacks[#self._mouse_callbacks] and self._mouse_callbacks[#self._mouse_callbacks].mouse_click then
		self._mouse_callbacks[#self._mouse_callbacks].mouse_click(o, button, o:x(), o:y())
	end
end

-- Lines 435-438
function MousePointerManager:set_mouse_world_position(x, y)
	self._mouse:set_world_position(x, y)
	self._ws:feed_mouse_position(self._mouse:world_position())
end

-- Lines 440-443
function MousePointerManager:force_move_mouse_pointer(x, y)
	self._mouse:move(x, y)
	self._ws:feed_mouse_position(self._mouse:world_position())
end

-- Lines 445-447
function MousePointerManager:mouse()
	return self._mouse
end

-- Lines 449-451
function MousePointerManager:world_position()
	return self._mouse:world_position()
end

-- Lines 453-471
function MousePointerManager:convert_mouse_pos(x, y)
	return managers.gui_data:full_to_safe(x, y)
end

-- Lines 473-476
function MousePointerManager:modified_mouse_pos()
	local x, y = self._mouse:world_position()

	return self:convert_mouse_pos(x, y)
end

-- Lines 478-482
function MousePointerManager:convert_1280_mouse_pos(x, y)
	local full_1280_size = managers.gui_data:full_1280_size()

	return x - full_1280_size.convert_x, y - full_1280_size.convert_y
end

-- Lines 484-492
function MousePointerManager:convert_fullscreen_mouse_pos(x, y)
	return x, y
end

-- Lines 494-496
function MousePointerManager:convert_fullscreen_16_9_mouse_pos(x, y)
	return managers.gui_data:full_to_full_16_9(x, y)
end

-- Lines 498-501
function MousePointerManager:modified_fullscreen_mouse_pos(x, y)
	local x, y = self._mouse:world_position()

	return self:convert_fullscreen_mouse_pos(x, y)
end

-- Lines 503-506
function MousePointerManager:modified_fullscreen_16_9_mouse_pos(x, y)
	local x, y = self._mouse:world_position()

	return self:convert_fullscreen_16_9_mouse_pos(x, y)
end
