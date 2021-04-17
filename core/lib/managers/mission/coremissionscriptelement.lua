core:module("CoreMissionScriptElement")
core:import("CoreXml")
core:import("CoreCode")
core:import("CoreClass")

MissionScriptElement = MissionScriptElement or class()

-- Lines 9-11
function MissionScriptElement:save(data)
	data.enabled = self._values.enabled
end

-- Lines 13-16
function MissionScriptElement:load(data)
	self:set_enabled(data.enabled)
end

-- Lines 19-26
function MissionScriptElement:init(mission_script, data)
	self._mission_script = mission_script
	self._id = data.id
	self._editor_name = data.editor_name
	self._values = data.values
	self._sync_id = mission_script:sync_id()
end

-- Lines 30-31
function MissionScriptElement:on_created()
end

-- Lines 35-44
function MissionScriptElement:on_script_activated()
	if self._values.rules_elements then
		self._rules_elements = {}

		for _, id in ipairs(self._values.rules_elements) do
			local element = self:get_mission_element(id)

			table.insert(self._rules_elements, element)
		end
	end

	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 47-49
function MissionScriptElement:get_mission_element(id)
	return self._mission_script:element(id)
end

-- Lines 52-54
function MissionScriptElement:editor_name()
	return self._editor_name
end

-- Lines 57-59
function MissionScriptElement:id()
	return self._id
end

-- Lines 62-64
function MissionScriptElement:_unique_string_id()
	return "" .. self._sync_id .. "_" .. self._id
end

-- Lines 67-69
function MissionScriptElement:values()
	return self._values
end

-- Lines 74-86
function MissionScriptElement:value(name)
	if self._values.instance_name and self._values.instance_var_names and self._values.instance_var_names[name] then
		local value = managers.world_instance:get_instance_param(self._sync_id, self._values.instance_name, self._values.instance_var_names[name])

		if value then
			return value
		end
	end

	return self._values[name]
end

-- Lines 89-95
function MissionScriptElement:get_random_table_value(value)
	if tonumber(value) then
		return value
	end

	return value[1] + math.random(value[2] + 1) - 1
end

-- Lines 98-100
function MissionScriptElement:enabled()
	return self._values.enabled
end

-- Lines 103-108
function MissionScriptElement:_check_instigator(instigator)
	if CoreClass.type_name(instigator) == "Unit" then
		return instigator
	end

	return managers.player:player_unit()
end

-- Lines 110-146
function MissionScriptElement:on_executed(instigator, alternative, skip_execute_on_executed)
	if not self._values.enabled then
		return
	end

	instigator = self:_check_instigator(instigator)

	if Network:is_server() then
		if instigator and alive(instigator) and instigator:id() ~= -1 then
			if self._sync_id > 0 and not managers.worldcollection:mission_by_id(self._sync_id) then
				Application:error("[MissionScriptElement:on_executed] Non existant mission manager!!!!!", self._sync_id, self._editor_name)
			end

			managers.network:session():send_to_peers_synched("run_mission_element", self._sync_id, self._id, instigator, self._last_orientation_index or 0)
		else
			managers.network:session():send_to_peers_synched("run_mission_element_no_instigator", self._sync_id, self._id, self._last_orientation_index or 0)
		end
	end

	self._last_orientation_index = nil

	self:_print_debug_on_executed(instigator)
	self:_reduce_trigger_times()

	if Network:is_server() and (not skip_execute_on_executed or CoreClass.type_name(skip_execute_on_executed) ~= "boolean") then
		self:_trigger_execute_on_executed(instigator, alternative)
	end
end

-- Lines 148-153
function MissionScriptElement:_calc_base_delay()
	if not self._values.base_delay_rand then
		return self._values.base_delay
	end

	return self._values.base_delay + math.rand(self._values.base_delay_rand)
end

-- Lines 155-162
function MissionScriptElement:_trigger_execute_on_executed(instigator, alternative)
	local base_delay = self:_calc_base_delay()

	if base_delay > 0 then
		self._mission_script:add(callback(self, self, "_execute_on_executed", {
			instigator = instigator,
			alternative = alternative
		}), base_delay, 1)
	else
		self:execute_on_executed({
			instigator = instigator,
			alternative = alternative
		})
	end
end

-- Lines 164-179
function MissionScriptElement:_print_debug_on_executed(instigator)
	if self:is_debug() then
		self:_print_debug("Element '" .. self._editor_name .. "' executed.", instigator)

		if instigator then
			-- Nothing
		end
	end
end

-- Lines 181-185
function MissionScriptElement:_print_debug(debug, instigator)
	if self:is_debug() then
		self._mission_script:debug_output(debug)
	end
end

-- Lines 187-194
function MissionScriptElement:_reduce_trigger_times()
	if self._values.trigger_times > 0 then
		self._values.trigger_times = self._values.trigger_times - 1

		if self._values.trigger_times <= 0 then
			self._values.enabled = false
		end
	end
end

-- Lines 196-198
function MissionScriptElement:_execute_on_executed(params)
	self:execute_on_executed(params)
end

-- Lines 200-205
function MissionScriptElement:_calc_element_delay(params)
	if not params.delay_rand then
		return params.delay
	end

	return params.delay + math.rand(params.delay_rand)
end

-- Lines 207-227
function MissionScriptElement:execute_on_executed(execute_params)
	for _, params in ipairs(self._values.on_executed) do
		if not execute_params.alternative or not params.alternative or execute_params.alternative == params.alternative then
			local element = self:get_mission_element(params.id)

			if element then
				local delay = self:_calc_element_delay(params)

				if delay > 0 then
					if self:is_debug() or element:is_debug() then
						self._mission_script:debug_output("  Executing element '" .. element:editor_name() .. "' in " .. delay .. " seconds ...", Color(1, 0.75, 0.75, 0.75))
					end

					self._mission_script:add(callback(element, element, "on_executed", execute_params.instigator), delay, 1)
				else
					if self:is_debug() or element:is_debug() then
						self._mission_script:debug_output("  Executing element '" .. element:editor_name() .. "' ...", Color(1, 0.75, 0.75, 0.75))
					end

					element:on_executed(execute_params.instigator)
				end
			end
		end
	end
end

-- Lines 229-231
function MissionScriptElement:on_execute_element(element, instigator)
	element:on_executed(instigator)
end

-- Lines 233-240
function MissionScriptElement:_has_on_executed_alternative(alternative)
	for _, params in ipairs(self._values.on_executed) do
		if params.alternative and params.alternative == alternative then
			return true
		end
	end

	return false
end

-- Lines 243-245
function MissionScriptElement:set_enabled(enabled)
	self._values.enabled = enabled
end

-- Lines 248-249
function MissionScriptElement:on_toggle(value)
end

-- Lines 252-254
function MissionScriptElement:set_trigger_times(trigger_times)
	self._values.trigger_times = trigger_times
end

-- Lines 257-259
function MissionScriptElement:is_debug()
	return self._values.debug or self._mission_script:is_debug()
end

-- Lines 262-263
function MissionScriptElement:stop_simulation(...)
end

-- Lines 266-270
function MissionScriptElement:operation_add()
	if Application:editor() then
		managers.editor:output_error("Element " .. self:editor_name() .. " doesn't have an 'add' operator implemented.")
	end
end

-- Lines 273-277
function MissionScriptElement:operation_remove()
	if Application:editor() then
		managers.editor:output_error("Element " .. self:editor_name() .. " doesn't have a 'remove' operator implemented.")
	end
end

-- Lines 280-284
function MissionScriptElement:apply_job_value()
	if Application:editor() then
		managers.editor:output_error("Element " .. self:editor_name() .. " doesn't have a 'apply_job_value' function implemented.")
	end
end

-- Lines 287-293
function MissionScriptElement:set_synced_orientation_element_index(orientation_element_index)
	if orientation_element_index and orientation_element_index > 0 then
		self._synced_orientation_element_index = orientation_element_index
	else
		self._synced_orientation_element_index = nil
	end
end

-- Lines 295-308
function MissionScriptElement:get_orientation_by_index(index)
	if not index or index == 0 then
		return self._values.position, self._values.rotation
	end

	local id = self._values.orientation_elements[index]
	local element = self:get_mission_element(id)

	if self._values.disable_orientation_on_use then
		element:set_enabled(false)
	end

	return element:get_orientation_by_index(0)
end

-- Lines 310-353
function MissionScriptElement:get_orientation_index()
	if self._values.orientation_elements and #self._values.orientation_elements > 0 then
		if not self._unused_orientation_indices then
			self._unused_orientation_indices = {}

			for index, id in ipairs(self._values.orientation_elements) do
				table.insert(self._unused_orientation_indices, index)
			end
		end

		local alternatives = {}

		for i, index in ipairs(self._unused_orientation_indices) do
			local element_id = self._values.orientation_elements[index]
			local element = self:get_mission_element(element_id)

			if element:enabled() then
				table.insert(alternatives, i)
			end
		end

		if #alternatives == 0 then
			if #self._unused_orientation_indices == #self._values.orientation_elements then
				_G.debug_pause("There where no enabled orientation elements!", self:editor_name())

				return
			elseif #self._unused_orientation_indices < #self._values.orientation_elements then
				self._unused_orientation_indices = nil

				return self:get_orientation_index()
			end
		end

		local use_i = alternatives[self._values.use_orientation_sequenced and 1 or math.random(#alternatives)]
		local index = table.remove(self._unused_orientation_indices, use_i)
		self._unused_orientation_indices = #self._unused_orientation_indices > 0 and self._unused_orientation_indices or nil

		return index
	else
		return 0
	end
end

-- Lines 357-409
function MissionScriptElement:get_orientation(use_last_orientation_index)
	local index = use_last_orientation_index and self._last_orientation_index
	index = index or self._synced_orientation_element_index or self:get_orientation_index()
	self._last_orientation_index = index
	local pos, rot = self:get_orientation_by_index(index)

	return pos, rot
end

-- Lines 412-413
function MissionScriptElement:debug_draw()
end

-- Lines 416-417
function MissionScriptElement:pre_destroy()
end

-- Lines 420-421
function MissionScriptElement:destroy()
end
