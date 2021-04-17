VehicleCamera = VehicleCamera or class()

-- Lines 3-12
function VehicleCamera:init(unit)
	self._unit = unit
	self._camera = World:create_camera()
	self._default_fov = 80

	self._camera:set_fov(self._default_fov)
	self._camera:set_near_range(managers.viewport.CAMERA_NEAR_RANGE)
	self._camera:set_far_range(managers.viewport.CAMERA_FAR_RANGE)
end

-- Lines 14-39
function VehicleCamera:setup()
	self._viewport = managers.viewport:first_active_viewport()
	self._director = self._viewport:director()
	self._on_foot_camera = self._viewport:camera()
	self._on_foot_camera_controller = self._director:camera()
	self._camera_controller = self._director:make_camera(self._camera, Idstring("vehicle_camera"))

	self._director:position_as(self._camera)

	self._camera_list = {}

	for _, object_name in ipairs(self._camera_object_names or {}) do
		table.insert(self._camera_list, self._unit:get_object(Idstring(object_name)))
	end

	if self._back_camera_object_name then
		self._back_camera_object = self._unit:get_object(Idstring(self._back_camera_object_name))
	end

	if #self._camera_list > 0 then
		self._camera_controller:set_both(self._camera_list[1])
	end
end

-- Lines 42-52
function VehicleCamera:_setup_sound_listener()
	self._listener_id = managers.listener:add_listener("access_camera", self._camera, self._camera, nil, false)

	managers.listener:add_set("access_camera", {
		"access_camera"
	})

	self._listener_activation_id = managers.listener:activate_set("main", "access_camera")
	self._sound_check_object = managers.sound_environment:add_check_object({
		primary = true,
		active = true,
		object = self._unit:orientation_object()
	})
end

local pos = Vector3()
local target = Vector3()

-- Lines 56-73
function VehicleCamera:update_camera()
	if not self._active then
		return
	end

	local rot = self._unit:vehicle():object_rotation(self._active_camera_object)

	mvector3.set(pos, self._unit:vehicle():object_position(self._active_camera_object))
	self._camera_controller:set_camera(pos)
	mrotation.y(rot, target)
	mvector3.multiply(target, 100)
	mvector3.add(target, pos)
	self._camera_controller:set_target(target)
	mrotation.z(rot, target)
	self._camera_controller:set_default_up(target)
end

-- Lines 75-85
function VehicleCamera:activate(player_unit)
	self._active = true

	if self._viewport and self._viewport:name() == "playernil" then
		self._viewport:set_camera(self._camera)
		self._director:set_camera(self._camera_controller)
	end

	if alive(player_unit) then
		player_unit:camera():set_listener_object(self._camera)
	end
end

-- Lines 87-98
function VehicleCamera:deactivate(player_unit)
	self._active = false
	self._rear_cam_active = false

	if self._viewport and self._viewport:name() == "playernil" then
		self._viewport:set_camera(self._on_foot_camera)
		self._director:set_camera(self._on_foot_camera_controller)
	end

	if alive(player_unit) then
		player_unit:camera():set_default_listener_object()
	end
end

-- Lines 101-116
function VehicleCamera:show_next(player_unit)
	if #self._camera_list == 0 then
		return
	end

	if not self._active then
		self._camera_list_i = 1
		self._active_camera_object = self._camera_list[self._camera_list_i]

		self:activate(player_unit)
	elseif self._camera_list_i >= #self._camera_list then
		self:deactivate(player_unit)
	else
		self._camera_list_i = self._camera_list_i + 1
		self._active_camera_object = self._camera_list[self._camera_list_i]
	end
end

-- Lines 118-140
function VehicleCamera:set_rear_cam_active(active, player_unit)
	if not self._back_camera_object then
		return
	end

	if self._rear_cam_active == active then
		return
	end

	self._rear_cam_active = active

	if active then
		if self._active then
			self._old_active_camera_object = self._active_camera_object
		end

		self._active_camera_object = self._back_camera_object

		self:activate(player_unit)
	elseif self._old_active_camera_object then
		self._active_camera_object = self._old_active_camera_object
		self._old_active_camera_object = nil
	else
		self:deactivate(player_unit)
	end
end

-- Lines 142-144
function VehicleCamera:rear_cam_active()
	return self._rear_cam_active
end

-- Lines 146-158
function VehicleCamera:destroy()
	if alive(self._camera) then
		World:delete_camera(self._camera)

		self._camera = nil
	end

	if self._listener_id then
		managers.sound_environment:remove_check_object(self._sound_check_object)
		managers.listener:remove_listener(self._listener_id)
		managers.listener:remove_set("access_camera")

		self._listener_id = nil
	end
end
