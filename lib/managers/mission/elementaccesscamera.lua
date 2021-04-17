core:import("CoreMissionScriptElement")

ElementAccessCamera = ElementAccessCamera or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-10
function ElementAccessCamera:init(...)
	ElementAccessCamera.super.init(self, ...)

	self._camera_unit = nil
	self._triggers = {}
end

-- Lines 12-30
function ElementAccessCamera:on_script_activated()
	if self._values.camera_u_id then
		local id = self._values.camera_u_id
		local unit = nil

		if false then
			unit = managers.editor:unit_with_id(id)
		else
			unit = self._mission_script:worlddefinition():get_unit_on_load(id, callback(self, self, "_load_unit"))
		end

		if unit then
			unit:base():set_access_camera_mission_element(self)

			self._camera_unit = unit
		end
	end

	self._has_fetched_units = true

	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 32-37
function ElementAccessCamera:_load_unit(unit)
	unit:base():set_access_camera_mission_element(self)

	self._camera_unit = unit
end

-- Lines 39-41
function ElementAccessCamera:client_on_executed(...)
end

-- Lines 43-49
function ElementAccessCamera:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementAccessCamera.super.on_executed(self, instigator)
end

-- Lines 51-55
function ElementAccessCamera:access_camera_operation_destroy()
	self._values.destroyed = true

	self:check_triggers("destroyed")
end

-- Lines 57-61
function ElementAccessCamera:add_trigger(id, type, callback)
	self._triggers[type] = self._triggers[type] or {}
	self._triggers[type][id] = {
		callback = callback
	}
end

-- Lines 63-67
function ElementAccessCamera:remove_trigger(id, type)
	if self._triggers[type] then
		self._triggers[type][id] = nil
	end
end

-- Lines 69-75
function ElementAccessCamera:trigger_accessed(instigator)
	if Network:is_client() then
		managers.network:session():send_to_host("to_server_access_camera_trigger", self._sync_id, self._id, "accessed", instigator)
	else
		self:check_triggers("accessed", instigator)
	end
end

-- Lines 77-86
function ElementAccessCamera:check_triggers(type, instigator)
	if not self._triggers[type] then
		return
	end

	for id, cb_data in pairs(self._triggers[type]) do
		cb_data.callback(instigator)
	end
end

-- Lines 88-94
function ElementAccessCamera:enabled(...)
	if alive(self._camera_unit) then
		return self._camera_unit:enabled()
	end

	return ElementAccessCamera.super.enabled(self, ...)
end

-- Lines 96-98
function ElementAccessCamera:has_camera_unit()
	return alive(self._camera_unit) and true or false
end

-- Lines 100-105
function ElementAccessCamera:camera_unit()
	if alive(self._camera_unit) then
		return self._camera_unit
	end

	return nil
end

-- Lines 107-112
function ElementAccessCamera:camera_position()
	if alive(self._camera_unit) then
		return self._camera_unit:get_object(Idstring("CameraLens")):position()
	end

	return self:value("position")
end

-- Lines 115-118
function ElementAccessCamera:save(data)
	data.enabled = self._values.enabled
	data.destroyed = self._values.destroyed
end

-- Lines 120-126
function ElementAccessCamera:load(data)
	self:set_enabled(data.enabled)

	self._values.destroyed = data.destroyed

	if not self._has_fetched_units then
		self:on_script_activated()
	end
end

ElementAccessCameraOperator = ElementAccessCameraOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 132-134
function ElementAccessCameraOperator:init(...)
	ElementAccessCameraOperator.super.init(self, ...)
end

-- Lines 136-138
function ElementAccessCameraOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 140-155
function ElementAccessCameraOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element and self._values.operation == "destroy" then
			element:access_camera_operation_destroy()
		end
	end

	ElementAccessCameraOperator.super.on_executed(self, instigator)
end

ElementAccessCameraTrigger = ElementAccessCameraTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 161-163
function ElementAccessCameraTrigger:init(...)
	ElementAccessCameraTrigger.super.init(self, ...)
end

-- Lines 165-170
function ElementAccessCameraTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.trigger_type, callback(self, self, "on_executed"))
	end
end

-- Lines 172-174
function ElementAccessCameraTrigger:client_on_executed(...)
end

-- Lines 176-182
function ElementAccessCameraTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementAccessCameraTrigger.super.on_executed(self, instigator)
end
