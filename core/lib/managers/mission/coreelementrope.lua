core:module("CoreElementRope")
core:import("CoreMissionScriptElement")

ElementRopeOperator = ElementRopeOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 8-10
function ElementRopeOperator:init(...)
	ElementRopeOperator.super.init(self, ...)
end

-- Lines 12-14
function ElementRopeOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 16-31
function ElementRopeOperator:on_executed(instigator)
	if not self._values.enabled or not self._values.rope_unit_id then
		return
	end

	local rope_unit = managers.worldcollection:get_unit_with_id(self._values.rope_unit_id, nil, self._sync_id)

	if rope_unit then
		if self._values.operation == "attach" then
			self:_attach_rope(rope_unit)
		elseif self._values.operation == "detach" then
			self:_detach_rope(rope_unit)
		end
	end

	ElementRopeOperator.super.on_executed(self, instigator)
end

-- Lines 33-52
function ElementRopeOperator:_attach_rope(rope_unit)
	local dragged_unit = rope_unit
	local steering_joint = rope_unit:get_object(Idstring("anim_rope_start"))
	local steering_body = rope_unit:body("body_collision_start")
	local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission
	local operator_unit = mission:get_element_by_id(self._id)

	steering_body:set_keyframed()

	local target_position = operator_unit._values.position
	local target_rotation = operator_unit._values.rotation

	steering_body:set_position(target_position)
	steering_body:set_rotation(target_rotation)
	steering_joint:set_position(target_position)
	steering_joint:set_rotation(target_rotation)
end

-- Lines 54-59
function ElementRopeOperator:_detach_rope(rope_unit)
	local dragged_unit = rope_unit
	local steering_body = rope_unit:body("body_collision_start")

	steering_body:set_dynamic()
end

ElementRopeTrigger = ElementRopeTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 65-67
function ElementRopeTrigger:init(...)
	ElementRopeTrigger.super.init(self, ...)
end

-- Lines 69-74
function ElementRopeTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.outcome, callback(self, self, "on_executed"))
	end
end

-- Lines 76-78
function ElementRopeTrigger:client_on_executed(...)
end

-- Lines 80-86
function ElementRopeTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementRopeTrigger.super.on_executed(self, instigator)
end
