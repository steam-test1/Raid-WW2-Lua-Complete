core:module("CoreElementRope")
core:import("CoreMissionScriptElement")

ElementRopeOperator = ElementRopeOperator or class(CoreMissionScriptElement.MissionScriptElement)

function ElementRopeOperator:init(...)
	ElementRopeOperator.super.init(self, ...)
end

function ElementRopeOperator:client_on_executed(...)
	self:on_executed(...)
end

function ElementRopeOperator:on_executed(instigator)
	Application:debug("[ElementRopeOperator:on_executed] enabled/rope_unit_id", self._values.enabled, self._values.rope_unit_id)

	if not self._values.enabled or not self._values.rope_unit_id then
		return
	end

	local rope_unit = managers.worldcollection:get_unit_with_id(self._values.rope_unit_id, nil, self._sync_id)

	Application:debug("[ElementRopeOperator:on_executed] rope_unit", rope_unit, self._values.rope_unit_id)

	if rope_unit then
		if self._values.operation == "attach" then
			Application:debug("[ElementRopeOperator:on_executed] ATTACH")
			self:_attach_rope(rope_unit)
		elseif self._values.operation == "detach" then
			Application:debug("[ElementRopeOperator:on_executed] DETACH")
			self:_detach_rope(rope_unit)
		end
	end

	ElementRopeOperator.super.on_executed(self, instigator)
end

function ElementRopeOperator:_attach_rope(rope_unit)
	local dragged_unit = rope_unit
	local steering_body = rope_unit:body(rope_unit:unit_data().steering_body)
	local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission
	local operator_unit = mission:get_element_by_id(self._id)
	local target_position = operator_unit._values.position
	local target_rotation = operator_unit._values.rotation

	steering_body:set_keyframed()
	steering_body:set_position(target_position)
	steering_body:set_rotation(target_rotation)

	local brush = Draw:brush(Color(0.3, 1, 1, 1), 2)

	brush:sphere(target_position, 5)
	brush:sphere(steering_body:position(), 5)
	brush:cylinder(steering_body:position(), target_position, 3, 3)
end

function ElementRopeOperator:_detach_rope(rope_unit)
	local dragged_unit = rope_unit
	local steering_body = rope_unit:body(rope_unit:unit_data().steering_body)

	steering_body:set_dynamic()
end

ElementRopeTrigger = ElementRopeTrigger or class(CoreMissionScriptElement.MissionScriptElement)

function ElementRopeTrigger:init(...)
	ElementRopeTrigger.super.init(self, ...)
end

function ElementRopeTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.outcome, callback(self, self, "on_executed"))
	end
end

function ElementRopeTrigger:client_on_executed(...)
end

function ElementRopeTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementRopeTrigger.super.on_executed(self, instigator)
end
