core:module("CoreElementTimer")
core:import("CoreMissionScriptElement")

ElementTimer = ElementTimer or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 6-12
function ElementTimer:init(...)
	ElementTimer.super.init(self, ...)

	self._digital_gui_units = {}
	self._triggers = {}
end

-- Lines 14-52
function ElementTimer:on_script_activated()
	self._timer = self:value("timer")
	self._monitor_timer = self:value("timer")

	if not Network:is_server() then
		return
	end

	if self._values.digital_gui_unit_ids then
		for _, id in ipairs(self._values.digital_gui_unit_ids) do
			if false then
				local unit = managers.editor:unit_with_id(id)

				table.insert(self._digital_gui_units, unit)
				unit:digital_gui():timer_set(self._timer)
			else
				local unit = self._mission_script:worlddefinition():get_unit_on_load(id, callback(self, self, "_load_unit"))

				if unit then
					table.insert(self._digital_gui_units, unit)
					unit:digital_gui():timer_set(self._timer)
				end
			end
		end
	end

	if not self.monitor_element and self._values.output_monitor_id then
		local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission
		self.monitor_element = mission:get_element_by_id(self._values.output_monitor_id)
	end

	self:monitor_output_change()
end

-- Lines 54-57
function ElementTimer:_load_unit(unit)
	table.insert(self._digital_gui_units, unit)
	unit:digital_gui():timer_set(self._timer)
end

-- Lines 59-66
function ElementTimer:set_enabled(enabled)
	ElementTimer.super.set_enabled(self, enabled)
end

-- Lines 68-78
function ElementTimer:add_updator()
	if not Network:is_server() then
		return
	end

	if not self._updator then
		self._updator = true

		self._mission_script:add_updator(self._id, callback(self, self, "update_timer"))
	end
end

-- Lines 80-85
function ElementTimer:remove_updator()
	if self._updator then
		self._mission_script:remove_updator(self._id)

		self._updator = nil
	end
end

-- Lines 87-110
function ElementTimer:update_timer(t, dt)
	self._timer = self._timer - dt

	if self._monitor_timer - self._timer > 1 then
		self._monitor_timer = self._timer

		self:monitor_output_change()
	end

	if self._timer <= 0 then
		self:remove_updator()
		self:on_executed()
	end

	for id, cb_data in pairs(self._triggers) do
		if self._timer <= cb_data.time then
			cb_data.callback()
			self:remove_trigger(id)
		end
	end
end

-- Lines 112-114
function ElementTimer:client_on_executed(...)
end

-- Lines 116-122
function ElementTimer:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementTimer.super.on_executed(self, instigator)
end

-- Lines 124-128
function ElementTimer:timer_operation_pause()
	self:remove_updator()
	self:_pause_digital_guis()
	self:monitor_output_change("... paused")
end

-- Lines 130-134
function ElementTimer:timer_operation_start()
	self:add_updator()
	self:_start_digital_guis_count_down()
	self:monitor_output_change("... started")
end

-- Lines 136-140
function ElementTimer:timer_operation_add_time(time)
	self._timer = self._timer + time

	self:_update_digital_guis_timer()
	self:monitor_output_change("... add (" .. time .. ")")
end

-- Lines 142-146
function ElementTimer:timer_operation_subtract_time(time)
	self._timer = self._timer - time

	self:_update_digital_guis_timer()
	self:monitor_output_change("... subtract (" .. time .. ")")
end

-- Lines 148-152
function ElementTimer:timer_operation_reset()
	self._timer = self._values.timer

	self:_update_digital_guis_timer()
	self:monitor_output_change("... reset")
end

-- Lines 154-158
function ElementTimer:timer_operation_set_time(time)
	self._timer = time

	self:_update_digital_guis_timer()
	self:monitor_output_change("... set (" .. time .. ")")
end

-- Lines 160-166
function ElementTimer:_update_digital_guis_timer()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_set(self._timer, true)
		end
	end
end

-- Lines 168-174
function ElementTimer:_start_digital_guis_count_down()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_start_count_down(true)
		end
	end
end

-- Lines 176-182
function ElementTimer:_start_digital_guis_count_up()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_start_count_up(true)
		end
	end
end

-- Lines 184-190
function ElementTimer:_pause_digital_guis()
	for _, unit in ipairs(self._digital_gui_units) do
		if alive(unit) then
			unit:digital_gui():timer_pause(true)
		end
	end
end

-- Lines 192-194
function ElementTimer:add_trigger(id, time, callback)
	self._triggers[id] = {
		time = time,
		callback = callback
	}
end

-- Lines 196-198
function ElementTimer:remove_trigger(id)
	self._triggers[id] = nil
end

-- Lines 200-205
function ElementTimer:monitor_output_change(output)
	if self.monitor_element then
		local output_string = "time: " .. math.round(self._timer) .. " " .. (output or "")

		self.monitor_element:on_monitored_element(self._editor_name, output_string)
	end
end

ElementTimerHud = ElementTimerHud or class(ElementTimer)

-- Lines 211-223
function ElementTimerHud:init(...)
	ElementTimerHud.super.init(self, ...)

	self._show_hud_timer = false
	self._total_timer_value = self._values.timer
	self._hud_timer_next_sync = Application:time() + 9
end

-- Lines 225-234
function ElementTimerHud:on_script_activated()
	self._timer = self:value("timer")

	if not Network:is_server() then
		return
	end

	self._on_script_activated_done = true

	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 236-245
function ElementTimerHud:save(data)
	if self._timer <= 0 then
		self._show_hud_timer = false
	end

	data.timer = self._timer
	data.show_hud_timer = self._show_hud_timer
	data.total_timer_value = self._total_timer_value
	data.enabled = self._values.enabled
end

-- Lines 247-269
function ElementTimerHud:load(data)
	if not self._on_script_activated_done then
		self:on_script_activated()
	end

	self:set_enabled(data.enabled)

	self._timer = data.timer
	self._show_hud_timer = data.show_hud_timer
	self._total_timer_value = data.total_timer_value

	if self._show_hud_timer then
		self:_timer_start()
		self:_timer_show_hud_timer()
	end
end

-- Lines 271-283
function ElementTimerHud:add_updator()
	if not self._updator then
		self._updator = true

		self._mission_script:add_updator(self._id, callback(self, self, "update_timer"))
	end
end

-- Lines 285-323
function ElementTimerHud:update_timer(t, dt)
	self._timer = self._timer - dt

	if self._timer <= 0 then
		self:remove_updator()
		self:on_executed()

		if self._show_hud_timer then
			managers.hud:remove_objectives_timer_hud(true)

			self._hud_timer_start_time = nil
			self._show_hud_timer = false
		end
	end

	for id, cb_data in pairs(self._triggers) do
		if self._timer <= cb_data.time then
			cb_data.callback()
			self:remove_trigger(id)
		end
	end

	if self._show_hud_timer and self._timer >= 0 then
		managers.hud:set_objectives_timer_hud_value(self._total_timer_value - self._timer, self._total_timer_value, self._timer)

		if Network:is_server() and self._hud_timer_next_sync < Application:time() then
			self._hud_timer_next_sync = Application:time() + 9

			for peer_id, peer in pairs(managers.network:session():peers()) do
				local sync_time = math.min(100000, self._timer + Network:qos(peer:rpc()).ping / 1000)

				self:execute_client_hud_timer_command("sync_time", sync_time)
			end
		end
	end
end

-- Lines 325-329
function ElementTimerHud:timer_operation_pause()
	self:_timer_pause()
	self:execute_client_hud_timer_command("pause", nil)
end

-- Lines 331-335
function ElementTimerHud:timer_operation_start()
	self:_timer_start()
	self:execute_client_hud_timer_command("start", nil)
end

-- Lines 337-341
function ElementTimerHud:timer_operation_add_time(time)
	self:_timer_add_time(time)
	self:execute_client_hud_timer_command("add_time", time)
end

-- Lines 343-347
function ElementTimerHud:timer_operation_subtract_time(time)
	self:_timer_subtract_time(time)
	self:execute_client_hud_timer_command("subtract_time", time)
end

-- Lines 349-353
function ElementTimerHud:timer_operation_reset()
	self:_timer_reset()
	self:execute_client_hud_timer_command("reset", nil)
end

-- Lines 355-359
function ElementTimerHud:timer_operation_set_time(time)
	self:_timer_set_time(time)
	self:execute_client_hud_timer_command("set_time", time)
end

-- Lines 361-365
function ElementTimerHud:timer_operation_show_hud_timer()
	self:_timer_show_hud_timer()
	self:execute_client_hud_timer_command("show_hud_timer", nil)
end

-- Lines 367-371
function ElementTimerHud:timer_operation_hide_hud_timer()
	self:_timer_hide_hud_timer()
	self:execute_client_hud_timer_command("hide_hud_timer", nil)
end

-- Lines 375-378
function ElementTimerHud:_timer_pause()
	self:remove_updator()
end

-- Lines 380-383
function ElementTimerHud:_timer_start()
	self:add_updator()
end

-- Lines 385-389
function ElementTimerHud:_timer_add_time(time)
	self._timer = self._timer + time
	self._total_timer_value = self._total_timer_value + time
end

-- Lines 391-395
function ElementTimerHud:_timer_subtract_time(time)
	self._timer = self._timer - time
	self._total_timer_value = self._total_timer_value - time
end

-- Lines 397-401
function ElementTimerHud:_timer_reset()
	self._timer = self._values.timer
	self._total_timer_value = self._values.timer
end

-- Lines 403-407
function ElementTimerHud:_timer_set_time(time)
	self._timer = time
	self._total_timer_value = time
end

-- Lines 409-411
function ElementTimerHud:_timer_sync_time(time)
	self._timer = time
end

-- Lines 413-416
function ElementTimerHud:_timer_show_hud_timer()
	managers.hud:create_objectives_timer_hud(0, 100)

	self._show_hud_timer = true
end

-- Lines 418-421
function ElementTimerHud:_timer_hide_hud_timer()
	self._show_hud_timer = false

	managers.hud:remove_objectives_timer_hud(false)
end

-- Lines 425-432
function ElementTimerHud:execute_client_hud_timer_command(command, command_value)
	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_client_hud_timer_command", self._sync_id, self._id, self._last_orientation_index or 0, command, command_value)
	end
end

-- Lines 434-459
function ElementTimerHud:sync_client_hud_timer_command(command, command_value)
	if command then
		if command == "pause" then
			self:_timer_pause()
		elseif command == "start" then
			self:_timer_start()
		elseif command == "add_time" then
			self:_timer_add_time(command_value)
		elseif command == "subtract_time" then
			self:_timer_subtract_time(command_value)
		elseif command == "reset" then
			self:_timer_reset()
		elseif command == "set_time" then
			self:_timer_set_time(command_value)
		elseif command == "show_hud_timer" then
			self:_timer_show_hud_timer()
		elseif command == "hide_hud_timer" then
			self:_timer_hide_hud_timer()
		elseif command == "sync_time" then
			self:_timer_sync_time(command_value)
		end
	end
end

ElementTimerOperator = ElementTimerOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 465-467
function ElementTimerOperator:init(...)
	ElementTimerOperator.super.init(self, ...)
end

-- Lines 469-472
function ElementTimerOperator:client_on_executed(...)
	Application:trace("[ElementTimerOperator:client_on_executed]")
end

-- Lines 474-504
function ElementTimerOperator:on_executed(instigator)
	Application:trace("[ElementTimerOperator:on_executed]")

	if not self._values.enabled then
		return
	end

	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		if element then
			if self._values.operation == "pause" then
				element:timer_operation_pause()
			elseif self._values.operation == "start" then
				element:timer_operation_start()
			elseif self._values.operation == "add_time" then
				element:timer_operation_add_time(self._values.time)
			elseif self._values.operation == "subtract_time" then
				element:timer_operation_subtract_time(self._values.time)
			elseif self._values.operation == "reset" then
				element:timer_operation_reset(self._values.time)
			elseif self._values.operation == "set_time" then
				element:timer_operation_set_time(self._values.time)
			elseif self._values.operation == "show_hud_timer" then
				element:timer_operation_show_hud_timer()
			elseif self._values.operation == "hide_hud_timer" then
				element:timer_operation_hide_hud_timer()
			end
		end
	end

	ElementTimerOperator.super.on_executed(self, instigator)
end

ElementTimerTrigger = ElementTimerTrigger or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 510-512
function ElementTimerTrigger:init(...)
	ElementTimerTrigger.super.init(self, ...)
end

-- Lines 514-516
function ElementTimerTrigger:on_script_activated()
	self:activate_trigger()
end

-- Lines 518-520
function ElementTimerTrigger:client_on_executed(...)
end

-- Lines 522-528
function ElementTimerTrigger:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	ElementTimerTrigger.super.on_executed(self, instigator)
end

-- Lines 530-536
function ElementTimerTrigger:activate_trigger()
	for _, id in ipairs(self._values.elements) do
		local element = self:get_mission_element(id)

		element:add_trigger(self._id, self._values.time, callback(self, self, "on_executed"))
	end
end

-- Lines 538-540
function ElementTimerTrigger:operation_add()
	self:activate_trigger()
end
