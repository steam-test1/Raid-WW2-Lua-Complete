ElementNavigationStitcherOperator = ElementNavigationStitcherOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-5
function ElementNavigationStitcherOperator:init(...)
	ElementNavigationStitcherOperator.super.init(self, ...)
end

-- Lines 7-12
function ElementNavigationStitcherOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 14-25
function ElementNavigationStitcherOperator:_apply_operator(mission_script_element)
	if mission_script_element then
		local call = mission_script_element[self._values.operation]

		if call then
			call(mission_script_element)
		else
			Application:error("Operator applied to a unit that doesn't support the specified operation - opertion: ", self._values.operation)
		end
	else
		Application:error("WorldOperator applied to a unit that doesn't exist - operator: ", inspect(self._unit))
	end
end

-- Lines 27-40
function ElementNavigationStitcherOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission

	for _, id in ipairs(self._values.elements) do
		local mission_script_element = mission:get_element_by_id(id)

		self:_apply_operator(mission_script_element)
	end

	ElementWorldOperator.super.on_executed(self, instigator)
end
