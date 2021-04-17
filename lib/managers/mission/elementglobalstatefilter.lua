ElementGlobalStateFilter = ElementGlobalStateFilter or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-5
function ElementGlobalStateFilter:init(...)
	ElementGlobalStateFilter.super.init(self, ...)
end

-- Lines 7-9
function ElementGlobalStateFilter:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 11-32
function ElementGlobalStateFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.flag and self._values.state then
		local flag_state = managers.global_state:flag(self._values.flag)

		if self._values.state == "value" then
			if managers.global_state:check_flag_value(self._values.check_type, self._values.value, flag_state) then
				ElementGlobalStateFilter.super.on_executed(self, instigator)
			end
		else
			local check_state = self._values.state == "set" and true or self._values.state == "cleared" and false

			if flag_state == check_state then
				ElementGlobalStateFilter.super.on_executed(self, instigator)
			end
		end
	else
		Application:error("[ElementGlobalStateFilter:on_executed] Values for the flag or state not selected, check your mission element.")
	end
end
