GlobalStateManager = GlobalStateManager or class()
GlobalStateManager.PATH = "gamedata/global_state"
GlobalStateManager.FILE_EXTENSION = "state"
GlobalStateManager.FULL_PATH = GlobalStateManager.PATH .. "." .. GlobalStateManager.FILE_EXTENSION
GlobalStateManager.GLOBAL_STATE_NAME = "global_init"
GlobalStateManager.EVENT_PRE_START_RAID = "system_pre_start_raid"
GlobalStateManager.EVENT_START_RAID = "system_start_raid"
GlobalStateManager.EVENT_END_RAID = "system_end_raid"
GlobalStateManager.EVENT_END_TUTORIAL = "system_end_tutorial"
GlobalStateManager.EVENT_RESTART_CAMP = "system_restart_camp"
GlobalStateManager.EVENT_CHARACTER_CREATED = "system_character_created"
GlobalStateManager.TYPE_BOOL = "bool"
GlobalStateManager.TYPE_VALUE = "value"

-- Lines 21-50
function GlobalStateManager:init()
	self._triggers = {}
	self._states = {}
	self._listener_holder = EventListenerHolder:new()

	self:_parse_states()
	self:add_listener("CCM_PRE_START_RAID", {
		GlobalStateManager.EVENT_PRE_START_RAID
	}, callback(managers.challenge_cards, managers.challenge_cards, "system_pre_start_raid"))
	self:add_listener("RM_START_RAID", {
		GlobalStateManager.EVENT_START_RAID
	}, callback(managers.raid_menu, managers.raid_menu, "system_start_raid"))
	self:add_listener("JM_START_MISSION", {
		GlobalStateManager.EVENT_START_RAID
	}, callback(managers.raid_job, managers.raid_job, "external_start_mission"))
	self:add_listener("JM_END_MISSION", {
		GlobalStateManager.EVENT_END_RAID
	}, callback(managers.raid_job, managers.raid_job, "external_end_mission"))
	self:add_listener("JM_END_TUTORIAL", {
		GlobalStateManager.EVENT_END_TUTORIAL
	}, callback(managers.raid_job, managers.raid_job, "tutorial_ended"))
	self:add_listener("OM_START_MISSION", {
		GlobalStateManager.EVENT_START_RAID
	}, callback(managers.objectives, managers.objectives, "on_mission_start_callback"))
	self:add_listener("WM_END_MISSION", {
		GlobalStateManager.EVENT_END_RAID
	}, callback(managers.warcry, managers.warcry, "on_mission_end_callback"))
	self:add_listener("TAI_END_MISSION", {
		GlobalStateManager.EVENT_END_RAID
	}, callback(managers.criminals, managers.criminals, "on_mission_end_callback"))
	self:add_listener("TAI_START_MISSION", {
		GlobalStateManager.EVENT_START_RAID
	}, callback(managers.criminals, managers.criminals, "on_mission_start_callback"))
end

-- Lines 53-56
function GlobalStateManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

-- Lines 58-60
function GlobalStateManager:remove_listener(key)
	self._listener_holder:remove(key)
end

-- Lines 62-69
function GlobalStateManager:register_trigger(trigger, flag)
	if not flag then
		Application:error("[GlobalStateManager:register_trigger] Trying to register trigger without flag!", inspect(trigger))

		return
	end

	self._triggers[flag] = self._triggers[flag] or {}

	table.insert(self._triggers[flag], trigger)
end

-- Lines 71-85
function GlobalStateManager:unregister_trigger(trigger, flag)
	if not flag then
		Application:error("[GlobalStateManager:register_trigger] Trying to unregister trigger without flag!", inspect(trigger))

		return
	end

	local found = nil

	for i, trig in ipairs(self._triggers[flag]) do
		if trig == trigger then
			found = i
		end
	end

	if found then
		table.remove(self._triggers[flag], found)
	end
end

-- Lines 87-93
function GlobalStateManager:flag_names()
	local flag_names = {}

	for name, value in pairs(self._states[GlobalStateManager.GLOBAL_STATE_NAME]) do
		table.insert(flag_names, name)
	end

	return flag_names
end

-- Lines 95-102
function GlobalStateManager:flag(flag_name)
	local flag = self._states[GlobalStateManager.GLOBAL_STATE_NAME][flag_name]

	if not flag then
		debug_pause("[GlobalStateManager:set_flag] Trying to get a flag that is not defined, check and resave level, or add it to global_state.state. Flag:", flag_name)

		return
	end

	return flag.value
end

-- Lines 104-113
function GlobalStateManager:set_flag(flag_name)
	local flag = self._states[GlobalStateManager.GLOBAL_STATE_NAME][flag_name]

	if not flag then
		debug_pause("[GlobalStateManager:set_flag] Trying to set a flag that is not defined, check and resave level, or add it to global_state.state. Flag:", flag_name)

		return
	end

	local old_state = flag.value
	flag.value = true

	self:_fire_triggers(flag_name, old_state, true)
end

-- Lines 115-124
function GlobalStateManager:set_value_flag(flag_name, value)
	local flag = self._states[GlobalStateManager.GLOBAL_STATE_NAME][flag_name]

	if not flag then
		debug_pause("[GlobalStateManager:set_flag] Trying to set a flag that is not defined, check and resave level, or add it to global_state.state. Flag:", flag_name)

		return
	end

	local old_state = flag.value
	flag.value = value

	self:_fire_triggers(flag_name, old_state, value)
end

-- Lines 127-129
function GlobalStateManager:set_implicit_flag(flag_name)
	self:_fire_triggers(flag_name, false, true)
end

-- Lines 131-133
function GlobalStateManager:clear_implicit_flag(flag_name)
	self:_fire_triggers(flag_name, true, false)
end

-- Lines 135-146
function GlobalStateManager:clear_flag(flag_name)
	local flag = self._states[GlobalStateManager.GLOBAL_STATE_NAME][flag_name]

	if not flag then
		debug_pause("[GlobalStateManager:set_flag] Trying to set a flag that is not defined, check and resave level, or add it to global_state.state. Flag:", flag_name)

		return
	end

	local old_state = flag.value
	flag.value = false

	self:_fire_triggers(flag_name, old_state, false)
end

-- Lines 149-206
function GlobalStateManager:fire_event(flag_name)
	if flag_name == GlobalStateManager.EVENT_START_RAID then
		managers.raid_menu:set_pause_menu_enabled(false)
	end

	if GlobalStateManager.EVENT_START_RAID == flag_name or GlobalStateManager.EVENT_END_RAID == flag_name then
		if not managers.network:session():chk_all_peers_spawned(true) then
			Application:debug("[GlobalStateManager:fire_event] Reschedule level start!")
			managers.queued_tasks:queue(nil, managers.global_state.fire_event, managers.global_state, flag_name, 1, nil)

			self._fire_event_delay = true
			local t = Application:time()

			if not self._next_hint_t or self._next_hint_t < t then
				self._next_hint_t = t + 6

				managers.notification:add_notification({
					duration = 2,
					shelf_life = 5,
					id = "hud_waiting_for_player_dropin",
					text = managers.localization:text("hud_waiting_for_player_dropin")
				})
			end

			return
		elseif managers.vote:is_restarting() or not managers.raid_job.reload_mission_flag and managers.game_play_central:is_restarting() then
			return
		end
	end

	if self._fire_event_delay then
		self._fire_event_delay = nil

		managers.queued_tasks:queue(nil, managers.global_state.fire_event, managers.global_state, flag_name, ElementPlayerSpawner.HIDE_LOADING_SCREEN_DELAY + 0.1, nil)

		return
	end

	local flag = self._states[GlobalStateManager.GLOBAL_STATE_NAME][flag_name]

	if not flag then
		debug_pause("[GlobalStateManager:set_flag] Trying to set a flag that is not defined, check and resave level, or add it to global_state.state. Flag:", flag_name)

		return
	end

	if self._listener_holder._listeners and self._listener_holder._listeners[flag_name] then
		self:_call_listeners(flag_name)
	end

	if not self._triggers[flag_name] then
		return
	end

	for _, trigger in ipairs(self._triggers[flag_name]) do
		trigger:execute(flag_name, nil, true)
	end
end

-- Lines 209-211
function GlobalStateManager:set_to_default(flag_name)
	self._states[GlobalStateManager.GLOBAL_STATE_NAME][flag_name].value = self._states[GlobalStateManager.GLOBAL_STATE_NAME][flag_name].default
end

-- Lines 213-220
function GlobalStateManager:reset_flags_for_job(job_id)
	for name, flag in pairs(self._states[GlobalStateManager.GLOBAL_STATE_NAME]) do
		if flag.job_id == job_id then
			flag.value = flag.default
		end
	end
end

-- Lines 222-226
function GlobalStateManager:reset_all_flags()
	for name, flag in pairs(self._states[GlobalStateManager.GLOBAL_STATE_NAME]) do
		flag.value = flag.default
	end
end

-- Lines 228-233
function GlobalStateManager:sync_save(data)
	local state = {
		data = self._states
	}
	data.GlobalStateManager = state
end

-- Lines 235-240
function GlobalStateManager:sync_load(data)
	local state = data.GlobalStateManager

	if state then
		self._states = state.data
	end
end

-- Lines 242-251
function GlobalStateManager:get_all_global_states()
	local global_states = {}

	for id, data in pairs(self._states.global_init) do
		local state = {
			{
				id = id,
				value = data.value
			}
		}

		table.insert(global_states, {
			id = id,
			value = data.value
		})
	end

	return global_states
end

-- Lines 253-257
function GlobalStateManager:set_global_states(states)
	for i = 1, #states do
		self._states.global_init[states[i].id].value = states[i].value
	end
end

-- Lines 259-268
function GlobalStateManager:save_game(data)
	local global_states = {}

	for id, data in pairs(self._states.global_init) do
		local state = {
			{
				id = id,
				value = data.value
			}
		}

		table.insert(global_states, {
			id = id,
			value = data.value
		})
	end

	data.global_state = global_states
end

-- Lines 270-276
function GlobalStateManager:load_game(data)
	if data.global_state then
		for i = 1, #data.global_state do
			self._states.global_init[data.global_state[i].id].value = data.global_state[i].value
		end
	end
end

-- Lines 278-282
function GlobalStateManager:on_simulation_ended()
	self._triggers = {}
	self._states = {}

	self:_parse_states()
end

-- Lines 284-305
function GlobalStateManager:check_flag_value(check_type, value1, value2)
	if check_type == "equal" then
		return value1 == value2
	end

	if check_type == "less_or_equal" then
		return value2 <= value1
	end

	if check_type == "greater_or_equal" then
		return value1 <= value2
	end

	if check_type == "less_than" then
		return value2 < value1
	end

	if check_type == "greater_than" then
		return value1 < value2
	end
end

-- Lines 310-328
function GlobalStateManager:_parse_states()
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())
	local states = list.states

	for _, state in ipairs(states) do
		for _, flag in ipairs(state) do
			if flag._meta == "flag" then
				self._states = self._states or {}
				self._states[state.id] = self._states[state.id] or {}
				self._states[state.id][flag.id] = self._states[state.id][flag.id] or {}
				self._states[state.id][flag.id].job_id = flag.job_id
				self._states[state.id][flag.id].data_type = flag.data_type or GlobalStateManager.TYPE_BOOL
				self._states[state.id][flag.id].value = self:_parse_value(flag.value, self._states[state.id][flag.id].data_type)
				self._states[state.id][flag.id].default = self:_parse_value(flag.value, self._states[state.id][flag.id].data_type)
			else
				Application:error("Unknown node \"" .. tostring(data._meta) .. "\" in \"" .. self.FULL_PATH .. "\". Expected \"flag\" node.")
			end
		end
	end
end

-- Lines 330-340
function GlobalStateManager:_parse_value(value, data_type)
	if data_type == GlobalStateManager.TYPE_VALUE then
		return value
	elseif value == "set" then
		return true
	elseif value == "cleared" then
		return false
	end
end

-- Lines 342-359
function GlobalStateManager:_fire_triggers(flag, old_state, new_state)
	if old_state == new_state then
		return
	end

	if not self._triggers[flag] then
		return
	end

	for _, trigger in ipairs(self._triggers[flag]) do
		trigger:execute(flag, new_state)
	end
end

-- Lines 361-364
function GlobalStateManager:_call_listeners(event, params)
	self._listener_holder:call(event, params)
end
