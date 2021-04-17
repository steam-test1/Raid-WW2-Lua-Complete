RaidGUIControlRotateUnit = RaidGUIControlRotateUnit or class(RaidGUIControl)

-- Lines 3-14
function RaidGUIControlRotateUnit:init(parent, params)
	RaidGUIControlRotateUnit.super.init(self, parent, params)

	self._params.layer = self._params.layer + 1
	self._params.color = Color(0.3, 0.3, 0.3, 1)
	self._object = self._panel:panel(self._params)
	self._pointer_type = "link"

	table.insert(managers.menu_component._update_components, self)
end

-- Lines 17-31
function RaidGUIControlRotateUnit:set_unit(unit, position, initial_angle, center_offset, screen_adjust_offset)
	self._unit = unit

	if not unit then
		managers.menu_component:removeFromUpdateTable(self)

		return
	end

	self._unit_center_offset = center_offset or Vector3(0, 0, 0)
	self._unit_screen_adjust_offset = screen_adjust_offset or Vector3(0, 0, 0)
	self._original_position = position
	self._original_rotation = self._unit:rotation()

	self:_place_unit(position + self._unit_center_offset + self._unit_screen_adjust_offset, self._original_rotation)
	self:_rotate_unit_by(0)
end

-- Lines 34-36
function RaidGUIControlRotateUnit:mouse_moved(o, x, y)
	RaidGUIControlRotateUnit.super.mouse_moved(self, o, x, y)
end

-- Lines 39-63
function RaidGUIControlRotateUnit:on_mouse_moved(o, x, y)
	if not self._dragging or not self._unit or not alive(self._unit) then
		return
	end

	if not self._last_x then
		self._last_x = x
		self._last_sound_click_angle = self._unit:rotation():yaw()

		return
	end

	self:_rotate_unit_by((x - self._last_x) / 4)

	self._last_x = x

	if self._params.sound_click_every_n_degrees and self._params.sound_click_every_n_degrees < math.abs(self._unit:rotation():yaw() - self._last_sound_click_angle) then
		if not self._params.rotation_click_sound then
			debug_pause("Rotation click sound not set for rotate unit control " .. tostring(self._name))

			return
		end

		managers.menu_component:post_event(self._params.rotation_click_sound)

		self._last_sound_click_angle = self._unit:rotation():yaw()
	end
end

-- Lines 66-85
function RaidGUIControlRotateUnit:_rotate_unit_by(yaw_delta)
	if not self._unit or not alive(self._unit) then
		return
	end

	local rotation = self._unit:rotation()
	local yaw = rotation:yaw()
	local pitch = rotation:pitch()
	local roll = rotation:roll()
	yaw = yaw + yaw_delta
	local rot_out = Rotation(yaw, pitch, roll)
	local rotated_offset = self._unit_center_offset:rotate_with(rot_out)

	self:_place_unit(self._original_position - rotated_offset + self._unit_screen_adjust_offset, rot_out)
end

-- Lines 87-91
function RaidGUIControlRotateUnit:current_position()
	if self._unit then
		return self._unit:position()
	end
end

-- Lines 93-97
function RaidGUIControlRotateUnit:current_rotation()
	if self._unit then
		return self._unit:rotation()
	end
end

-- Lines 99-105
function RaidGUIControlRotateUnit:set_position(position)
	if not self._unit then
		return
	end

	self:_place_unit(position, self._unit:rotation())
end

-- Lines 107-113
function RaidGUIControlRotateUnit:set_rotation(rotation)
	if not self._unit then
		return
	end

	self:_place_unit(self._unit:position(), rotation)
end

-- Lines 115-121
function RaidGUIControlRotateUnit:update(t, dt)
	local menu_controller = managers.menu:get_controller()

	if not managers.menu:is_pc_controller() and menu_controller then
		self:_rotate_unit_by(menu_controller:get_input_axis("look").x * 4)
	end
end

-- Lines 123-128
function RaidGUIControlRotateUnit:_place_unit(position, rotation)
	self._unit:set_position(position)
	self._unit:set_rotation(rotation)
	self._unit:set_moving(2)
end

-- Lines 130-136
function RaidGUIControlRotateUnit:on_mouse_over(x, y)
	RaidGUIControlRotateUnit.super.on_mouse_over(self, x, y)

	if self._params.mouse_over_sound then
		managers.menu_component:post_event(self._params.mouse_over_sound)
	end
end

-- Lines 138-141
function RaidGUIControlRotateUnit:on_mouse_out()
	self._pointer_type = "link"
	self._dragging = false
end

-- Lines 144-154
function RaidGUIControlRotateUnit:on_mouse_pressed()
	self._old_active_control = managers.raid_menu:get_active_control()

	managers.raid_menu:set_active_control(self)

	self._dragging = true
	self._last_x = nil
	self._last_sound_click_angle = nil

	if self._params.mouse_click_sound then
		managers.menu_component:post_event(self._params.mouse_click_sound)
	end
end

-- Lines 157-164
function RaidGUIControlRotateUnit:on_mouse_released()
	managers.raid_menu:set_active_control(self._old_active_control)

	self._dragging = false

	if self._params.mouse_release_sound then
		managers.menu_component:post_event(self._params.mouse_release_sound)
	end
end
