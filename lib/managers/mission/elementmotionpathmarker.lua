core:import("CoreMissionScriptElement")

ElementMotionpathMarker = ElementMotionpathMarker or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-13
function ElementMotionpathMarker:init(...)
	ElementMotionpathMarker.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/VehicleMarker" then
		self._values.icon = "wp_standard"
	end
end

-- Lines 15-17
function ElementMotionpathMarker:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 19-21
function ElementMotionpathMarker:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 23-25
function ElementMotionpathMarker:on_executed(instigator)
	ElementMotionpathMarker.super.on_executed(self, instigator)
end

-- Lines 27-29
function ElementMotionpathMarker:operation_remove()
end

-- Lines 31-34
function ElementMotionpathMarker:save(data)
	data.enabled = self._values.enabled
	data.motion_state = self._values.motion_state
end

-- Lines 36-39
function ElementMotionpathMarker:load(data)
	self:set_enabled(data.enabled)

	self._values.motion_state = data.motion_state
end

-- Lines 41-44
function ElementMotionpathMarker:add_trigger(trigger_id, outcome, callback)
	local motion_path = self._sync_id ~= 0 and managers.worldcollection:motion_path_by_id(self._sync_id) or managers.motion_path

	motion_path:add_trigger(self._id, self._values.path_id, trigger_id, outcome, callback)
end

-- Lines 50-53
function ElementMotionpathMarker:motion_operation_goto_marker(checkpoint_marker_id, goto_marker_id)
	local motion_path = self._sync_id ~= 0 and managers.worldcollection:motion_path_by_id(self._sync_id) or managers.motion_path

	motion_path:operation_goto_marker(checkpoint_marker_id, goto_marker_id)
end

-- Lines 55-58
function ElementMotionpathMarker:motion_operation_teleport_to_marker(checkpoint_marker_id, teleport_to_marker_id)
	local motion_path = self._sync_id ~= 0 and managers.worldcollection:motion_path_by_id(self._sync_id) or managers.motion_path

	motion_path:operation_teleport_to_marker(checkpoint_marker_id, teleport_to_marker_id)
end

-- Lines 60-63
function ElementMotionpathMarker:motion_operation_set_motion_state(state)
	self._values.motion_state = state
end

-- Lines 66-69
function ElementMotionpathMarker:motion_operation_set_rotation(operator_id)
	local motion_path = self._sync_id ~= 0 and managers.worldcollection:motion_path_by_id(self._sync_id) or managers.motion_path

	motion_path:operation_set_unit_target_rotation(self._id, operator_id)
end
