core:module("CoreElementMotionPath")
core:import("CoreMissionScriptElement")

ElementMotionPathOperator = ElementMotionPathOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 8-10
function ElementMotionPathOperator:init(...)
	ElementMotionPathOperator.super.init(self, ...)
end

-- Lines 12-14
function ElementMotionPathOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 16-56
function ElementMotionPathOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local motion_path = self._sync_id ~= 0 and managers.worldcollection:motion_path_by_id(self._sync_id) or managers.motion_path

	Application:debug("[ElementMotionPathOperator:on_executed]", motion_path)

	if self._values.operation == "activate_bridge" then
		motion_path:motion_operation_activate_bridge(self._values.elements)
	elseif self._values.operation == "deactivate_bridge" then
		motion_path:motion_operation_deactivate_bridge(self._values.elements)
	elseif self._values.operation == "path_stop" then
		motion_path:motion_operation_path_activate(false, self._values.elements)
	elseif self._values.operation == "path_start" then
		motion_path:motion_operation_path_activate(true, self._values.elements)
	else
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			if element then
				if self._values.operation == "goto_marker" then
					element:motion_operation_goto_marker(element:id(), self._values.marker_ids[self._values.marker])
				elseif self._values.operation == "teleport" then
					element:motion_operation_teleport_to_marker(element:id(), self._values.marker_ids[self._values.marker])
				elseif self._values.operation == "move" then
					element:motion_operation_set_motion_state("move")
				elseif self._values.operation == "wait" then
					element:motion_operation_set_motion_state("wait")
				elseif self._values.operation == "rotate" then
					element:motion_operation_set_rotation(self._id)
				end
			end
		end
	end

	ElementMotionPathOperator.super.on_executed(self, instigator)
end

ElementMotionPathTrigger = ElementMotionPathTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 62-64
function ElementMotionPathTrigger:init(...)
	ElementMotionPathTrigger.super.init(self, ...)
end

-- Lines 66-71
function ElementMotionPathTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.outcome, callback(self, self, "on_executed"))
	end
end

-- Lines 73-75
function ElementMotionPathTrigger:client_on_executed(...)
end

-- Lines 77-83
function ElementMotionPathTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementMotionPathTrigger.super.on_executed(self, instigator)
end
