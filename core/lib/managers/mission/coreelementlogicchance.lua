core:module("CoreElementLogicChance")
core:import("CoreMissionScriptElement")

ElementLogicChance = ElementLogicChance or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 6-10
function ElementLogicChance:init(...)
	ElementLogicChance.super.init(self, ...)

	self._chance = self._values.chance
	self._triggers = {}
end

-- Lines 12-14
function ElementLogicChance:client_on_executed(...)
end

-- Lines 16-41
function ElementLogicChance:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self.monitor_element and self._values.output_monitor_id then
		local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission
		self.monitor_element = mission:get_element_by_id(self._values.output_monitor_id)
	end

	local roll = math.random(100)

	if self._chance < roll then
		self:monitor_output_change(" roll: " .. roll .. " - fail")
		self:_trigger_outcome("fail")

		return
	end

	self:monitor_output_change(" roll: " .. roll .. " - success")
	self:_trigger_outcome("success")
	ElementLogicChance.super.on_executed(self, instigator)
end

-- Lines 43-46
function ElementLogicChance:chance_operation_add_chance(chance)
	self._chance = self._chance + chance

	self:monitor_output_change()
end

-- Lines 48-51
function ElementLogicChance:chance_operation_subtract_chance(chance)
	self._chance = self._chance - chance

	self:monitor_output_change()
end

-- Lines 53-56
function ElementLogicChance:chance_operation_reset()
	self._chance = self._values.chance

	self:monitor_output_change()
end

-- Lines 58-61
function ElementLogicChance:chance_operation_set_chance(chance)
	self._chance = chance

	self:monitor_output_change()
end

-- Lines 63-65
function ElementLogicChance:add_trigger(id, outcome, callback)
	self._triggers[id] = {
		outcome = outcome,
		callback = callback
	}
end

-- Lines 67-69
function ElementLogicChance:remove_trigger(id)
	self._triggers[id] = nil
end

-- Lines 71-77
function ElementLogicChance:_trigger_outcome(outcome)
	for _, data in pairs(self._triggers) do
		if data.outcome == outcome then
			data.callback()
		end
	end
end

-- Lines 79-84
function ElementLogicChance:monitor_output_change(result)
	if self.monitor_element then
		local output_string = "chance: " .. self._chance .. " " .. (result or "")

		self.monitor_element:on_monitored_element(self._editor_name, output_string)
	end
end

ElementLogicChanceOperator = ElementLogicChanceOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 90-92
function ElementLogicChanceOperator:init(...)
	ElementLogicChanceOperator.super.init(self, ...)
end

-- Lines 94-96
function ElementLogicChanceOperator:client_on_executed(...)
end

-- Lines 98-119
function ElementLogicChanceOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self._values.operation == "add_chance" then
				element:chance_operation_add_chance(self._values.chance)
			elseif self._values.operation == "subtract_chance" then
				element:chance_operation_subtract_chance(self._values.chance)
			elseif self._values.operation == "reset" then
				element:chance_operation_reset()
			elseif self._values.operation == "set_chance" then
				element:chance_operation_set_chance(self._values.chance)
			end
		end
	end

	ElementLogicChanceOperator.super.on_executed(self, instigator)
end

ElementLogicChanceTrigger = ElementLogicChanceTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 125-127
function ElementLogicChanceTrigger:init(...)
	ElementLogicChanceTrigger.super.init(self, ...)
end

-- Lines 129-136
function ElementLogicChanceTrigger:on_script_activated()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			element:add_trigger(self._id, self._values.outcome, callback(self, self, "on_executed"))
		end
	end
end

-- Lines 138-140
function ElementLogicChanceTrigger:client_on_executed(...)
end

-- Lines 142-148
function ElementLogicChanceTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementLogicChanceTrigger.super.on_executed(self, instigator)
end
