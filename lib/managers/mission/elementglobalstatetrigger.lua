ElementGlobalStateTrigger = ElementGlobalStateTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-6
function ElementGlobalStateTrigger:init(...)
	ElementGlobalStateTrigger.super.init(self, ...)
	managers.global_state:register_trigger(self, self._values.flag)
end

-- Lines 8-10
function ElementGlobalStateTrigger:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 12-32
function ElementGlobalStateTrigger:execute(flag, state, event)
	if not self._values.enabled then
		return
	end

	if self._values.flag == flag then
		if event then
			if self._values.on_event then
				self:on_executed()
			end
		elseif self._values.on_value then
			if managers.global_state:check_flag_value(self._values.check_type, self._values.value, state) then
				self:on_executed()
			end
		elseif self._values.on_set and state or self._values.on_clear and not state then
			self:on_executed()
		end
	end
end

-- Lines 34-40
function ElementGlobalStateTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementGlobalStateTrigger.super.on_executed(self, instigator)
end

-- Lines 42-44
function ElementGlobalStateTrigger:destroy()
	managers.global_state:unregister_trigger(self, self._values.flag)
end

-- Lines 46-48
function ElementGlobalStateTrigger:unregister()
	managers.global_state:unregister_trigger(self, self._values.flag)
end
