ElementGlobalStateOperator = ElementGlobalStateOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-5
function ElementGlobalStateOperator:init(...)
	ElementGlobalStateOperator.super.init(self, ...)
end

-- Lines 7-9
function ElementGlobalStateOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 11-33
function ElementGlobalStateOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local flag = self._values.flag
	local value = self._values.value
	local action = self._values.action

	if action == "set" then
		managers.global_state:set_flag(flag)
	elseif action == "clear" then
		managers.global_state:clear_flag(flag)
	elseif action == "default" then
		managers.global_state:set_to_default(flag)
	elseif action == "event" then
		managers.global_state:fire_event(flag)
	elseif action == "set_value" then
		managers.global_state:set_value_flag(flag, value)
	end

	ElementGlobalStateOperator.super.on_executed(self, instigator)
end
