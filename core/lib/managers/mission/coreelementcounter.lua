core:module("CoreElementCounter")
core:import("CoreMissionScriptElement")
core:import("CoreClass")

ElementCounter = ElementCounter or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 7-13
function ElementCounter:init(...)
	ElementCounter.super.init(self, ...)

	self._digital_gui_units = {}
	self._triggers = {}
end

-- Lines 15-18
function ElementCounter:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 20-54
function ElementCounter:on_script_activated()
	self._values.counter_target = self:value("counter_target")
	self._original_value = self._values.counter_target

	if self._values.output_monitor_id then
		local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission
		self.monitor_element = mission:get_element_by_id(self._values.output_monitor_id)
	end

	if not Network:is_server() then
		return
	end

	if self._values.digital_gui_unit_ids then
		for _, id in ipairs(self._values.digital_gui_unit_ids) do
			if false then
				local unit = managers.editor:unit_with_id(id)

				table.insert(self._digital_gui_units, unit)
				unit:digital_gui():number_set(self._values.counter_target)
			else
				local unit = self._mission_script:worlddefinition():get_unit_on_load(id, callback(self, self, "_load_unit"))

				if unit then
					table.insert(self._digital_gui_units, unit)
					unit:digital_gui():number_set(self._values.counter_target)
				end
			end
		end
	end

	self:monitor_output_change()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 56-59
function ElementCounter:_load_unit(unit)
	table.insert(self._digital_gui_units, unit)
	unit:digital_gui():number_set(self._values.counter_target)
end

-- Lines 61-82
function ElementCounter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.counter_target > 0 then
		self._values.counter_target = self._values.counter_target - 1

		self:_update_digital_guis_number()

		if self:is_debug() then
			self._mission_script:debug_output("Counter " .. self._editor_name .. ": " .. self._values.counter_target .. " Previous value: " .. self._values.counter_target + 1, Color(1, 0, 0.75, 0))
		end

		if self._values.counter_target == 0 then
			ElementCounter.super.on_executed(self, instigator)
		end
	elseif self:is_debug() then
		self._mission_script:debug_output("Counter " .. self._editor_name .. ": already exhausted!", Color(1, 0, 0.75, 0))
	end

	self:monitor_output_change()
end

-- Lines 84-88
function ElementCounter:reset_counter_target(counter_target)
	self._values.counter_target = counter_target

	self:_update_digital_guis_number()
	self:monitor_output_change()
end

-- Lines 90-96
function ElementCounter:counter_operation_add(amount)
	self._values.counter_target = self._values.counter_target + amount

	self:_update_digital_guis_number()
	self:_check_triggers("add")
	self:_check_triggers("value")
	self:monitor_output_change()
end

-- Lines 98-104
function ElementCounter:counter_operation_subtract(amount)
	self._values.counter_target = self._values.counter_target - amount

	self:_update_digital_guis_number()
	self:_check_triggers("subtract")
	self:_check_triggers("value")
	self:monitor_output_change()
end

-- Lines 106-112
function ElementCounter:counter_operation_reset(amount)
	self._values.counter_target = self._original_value

	self:_update_digital_guis_number()
	self:_check_triggers("reset")
	self:_check_triggers("value")
	self:monitor_output_change()
end

-- Lines 114-120
function ElementCounter:counter_operation_set(amount)
	self._values.counter_target = amount

	self:_update_digital_guis_number()
	self:_check_triggers("set")
	self:_check_triggers("value")
	self:monitor_output_change()
end

-- Lines 122-130
function ElementCounter:apply_job_value(amount)
	local type = CoreClass.type_name(amount)

	if type ~= "number" then
		Application:error("[ElementCounter:apply_job_value] " .. self._id .. "(" .. self._editor_name .. ") Can't apply job value of type " .. type)

		return
	end

	self:counter_operation_set(amount)
end

-- Lines 132-136
function ElementCounter:add_trigger(id, type, amount, callback)
	self._triggers[type] = self._triggers[type] or {}
	self._triggers[type][id] = {
		amount = amount,
		callback = callback
	}
end

-- Lines 138-140
function ElementCounter:counter_value()
	return self._values.counter_target
end

-- Lines 142-144
function ElementCounter:_set_counter_value(counter_value)
	self._values.counter_target = counter_value
end

-- Lines 150-156
function ElementCounter:_update_digital_guis_number()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():number_set(self._values.counter_target, true)
		end
	end
end

-- Lines 158-170
function ElementCounter:_check_triggers(type)
	if not self._triggers[type] then
		return
	end

	for id, cb_data in pairs(self._triggers[type]) do
		if type ~= "value" or cb_data.amount == self._values.counter_target then
			cb_data.callback()
		end
	end
end

-- Lines 172-177
function ElementCounter:monitor_output_change()
	if self.monitor_element then
		local output_string = self._values.counter_target

		self.monitor_element:on_monitored_element(self._editor_name, output_string)
	end
end

-- Lines 180-185
function ElementCounter:save(data)
	data.counter_value = self:counter_value()
	data.original_value = self._original_value
	data.enabled = self._values.enabled
end

-- Lines 187-194
function ElementCounter:load(data)
	if data.counter_value then
		self:_set_counter_value(data.counter_value)
	end

	self._original_value = data.original_value

	self:set_enabled(data.enabled)
end

ElementCounterReset = ElementCounterReset or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 201-203
function ElementCounterReset:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 205-207
function ElementCounterReset:init(...)
	ElementCounterReset.super.init(self, ...)
end

-- Lines 209-226
function ElementCounterReset:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self:is_debug() then
				self._mission_script:debug_output("Counter reset " .. element:editor_name() .. " to: " .. self._values.counter_target, Color(1, 0, 0.75, 0))
			end

			element:reset_counter_target(self._values.counter_target)
		end
	end

	ElementCounterReset.super.on_executed(self, instigator)
end

ElementCounterOperator = ElementCounterOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 232-234
function ElementCounterOperator:init(...)
	ElementCounterOperator.super.init(self, ...)
end

-- Lines 236-239
function ElementCounterOperator:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 241-271
function ElementCounterOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local amount = self:value("amount")

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if not element:counter_value() then
				_G.debug_pause("[ElementCounterOperator:on_executed] Counter operator called on element without value!", element:editor_name(), amount)
			end

			if self._values.operation == "add" then
				element:counter_operation_add(amount)
			elseif self._values.operation == "subtract" then
				element:counter_operation_subtract(amount)
			elseif self._values.operation == "reset" then
				element:counter_operation_reset(amount)
			elseif self._values.operation == "set" then
				element:counter_operation_set(amount)
			end
		end
	end

	ElementCounterOperator.super.on_executed(self, instigator)
end

ElementCounterTrigger = ElementCounterTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 277-279
function ElementCounterTrigger:init(...)
	ElementCounterTrigger.super.init(self, ...)
end

-- Lines 281-288
function ElementCounterTrigger:on_script_activated()
	if Network:is_server() then
		for _, id in ipairs(self._values.elements) do
			local element = self:get_mission_element(id)

			element:add_trigger(self._id, self._values.trigger_type, self._values.amount, callback(self, self, "on_executed"))
		end
	end
end

-- Lines 290-292
function ElementCounterTrigger:client_on_executed(...)
end

-- Lines 294-300
function ElementCounterTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementCounterTrigger.super.on_executed(self, instigator)
end

ElementCounterFilter = ElementCounterFilter or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 306-308
function ElementCounterFilter:init(...)
	ElementCounterFilter.super.init(self, ...)
end

-- Lines 310-312
function ElementCounterFilter:on_script_activated()
end

-- Lines 314-316
function ElementCounterFilter:client_on_executed(...)
end

-- Lines 318-328
function ElementCounterFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self:_values_ok() then
		return
	end

	ElementCounterFilter.super.on_executed(self, instigator)
end

-- Lines 330-348
function ElementCounterFilter:_values_ok()
	if self._values.check_type == "counters_equal" then
		return self:_all_counter_values_equal()
	end

	if self._values.check_type == "counters_not_equal" then
		return not self:_all_counter_values_equal()
	end

	if self._values.needed_to_execute == "all" then
		return self:_all_counters_ok()
	end

	if self._values.needed_to_execute == "any" then
		return self:_any_counters_ok()
	end
end

-- Lines 350-361
function ElementCounterFilter:_all_counter_values_equal()
	local test_value = nil

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)
		test_value = test_value or element:counter_value()

		if test_value ~= element:counter_value() then
			return false
		end
	end

	return true
end

-- Lines 363-370
function ElementCounterFilter:_all_counters_ok()
	for _, id in ipairs(self._values.elements) do
		if not self:_check_type(self:get_mission_element(id)) then
			return false
		end
	end

	return true
end

-- Lines 372-379
function ElementCounterFilter:_any_counters_ok()
	for _, id in ipairs(self._values.elements) do
		if self:_check_type(self:get_mission_element(id)) then
			return true
		end
	end

	return false
end

-- Lines 381-402
function ElementCounterFilter:_check_type(element)
	if not self._values.check_type or self._values.check_type == "equal" then
		return element:counter_value() == self._values.value
	end

	if self._values.check_type == "less_or_equal" then
		return element:counter_value() <= self._values.value
	end

	if self._values.check_type == "greater_or_equal" then
		return self._values.value <= element:counter_value()
	end

	if self._values.check_type == "less_than" then
		return element:counter_value() < self._values.value
	end

	if self._values.check_type == "greater_than" then
		return self._values.value < element:counter_value()
	end
end
