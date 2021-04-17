ElementWorldOperator = ElementWorldOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-5
function ElementWorldOperator:init(...)
	ElementWorldOperator.super.init(self, ...)
end

-- Lines 7-9
function ElementWorldOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 11-13
function ElementWorldOperator:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 15-22
function ElementWorldOperator:_get_unit(unit_id)
	if false then
		return managers.editor:unit_with_id(unit_id)
	else
		return managers.worlddefinition:get_unit(unit_id)
	end
end

-- Lines 25-35
function ElementWorldOperator:_apply_operator(mission_script_element)
	if mission_script_element then
		if mission_script_element.execute_action then
			mission_script_element:execute_action(self._values.operation)
		else
			Application:error("WorldOperator applied to a unit that does not have execute action. ", self._editor_name, inspect(mission_script_element))
		end
	else
		Application:error("WorldOperator applied to a unit that doesn't exist - operator: ", inspect(self._unit))
	end
end

-- Lines 38-49
function ElementWorldOperator:on_executed(instigator)
	Application:debug("ElementWorldOperator:on_executed", self._editor_name)

	if not self._values.enabled then
		return
	end

	ElementWorldOperator.super.on_executed(self, instigator)

	local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission

	for _, id in ipairs(self._values.elements) do
		local mission_script_element = mission:get_element_by_id(id)

		self:_apply_operator(mission_script_element)
	end
end
