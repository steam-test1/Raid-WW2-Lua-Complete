RaidJobManager = RaidJobManager or class()
RaidJobManager.WORLD_POINT_MISSION = "system_world_point_mission"
RaidJobManager.WORLD_POINT_CAMP = "system_world_point_camp"
RaidJobManager.WORLD_POINT_TUTORIAL = "system_world_point_tutorial"
RaidJobManager.CAMP_ID = "camp"
RaidJobManager.TUTORIAL_ID = "tutorial"
RaidJobManager.SINGLE_MISSION_TYPE_NAME = "RAID"
RaidJobManager.XP_MULTIPLIER_ON_FAIL = 0.05

function RaidJobManager.get_instance()
	if not Global.raid_job_manager then
		Global.raid_job_manager = RaidJobManager:new()
	end

	setmetatable(Global.raid_job_manager, RaidJobManager)

	return Global.raid_job_manager
end

function RaidJobManager:init()
	self:_setup()
end

function RaidJobManager:_setup()
	self._save_slots = {}
	self._loot_data = {}
	self._camp = tweak_data.operations:mission_data(RaidJobManager.CAMP_ID)
	self._play_tutorial = true
end

function RaidJobManager:set_selected_job(job_id, job_data)
	if not Network:is_server() then
		return
	end

	Application:debug("[RaidJobManager:set_selected_job]", job_id, job_data, job_data and inspect(job_data))

	job_id = job_id or job_data.job_id
	job_data = job_data or tweak_data.operations:mission_data(job_id)

	if job_data.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		tweak_data.operations:randomize_operation(job_id, job_data)

		local list_delimited = tweak_data.operations:get_operation_indexes_delimited(job_id, job_data)

		managers.network:session():send_to_peers_synched("sync_randomize_operation", job_id, list_delimited)
	end

	self:local_set_selected_job(job_id, job_data)
	managers.network:session():send_to_peers_synched("sync_set_selected_job", job_id, Global.game_settings.difficulty)
end

function RaidJobManager:local_set_selected_job(job_id, job_data)
	Application:trace("[RaidJobManager:local_set_selected_job]", job_id, inspect(job_data))

	job_id = job_id or job_data.job_id
	local mission_data = job_data or tweak_data.operations:mission_data(job_id)
	self._current_job = nil

	managers.statistics:stop_session({
		success = false,
		quit = true
	})
	managers.network:session():send_to_peers_synched("stop_statistics_session", false, true, "")

	self._selected_job = mission_data
	self._loot_data = {}

	if mission_data.active_card then
		managers.challenge_cards:set_active_card(mission_data.active_card)
	end

	managers.global_state:reset_all_flags()

	if self._selected_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
		self:_select_raid()
		managers.global_state:set_flag(mission_data.mission_flag)
	elseif self._selected_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		self:_select_operation()
		managers.global_state:set_flag(mission_data.current_event_data.mission_flag)
	end
end

function RaidJobManager:_select_raid()
	if not self._selected_job.no_dynamic_objective then
		local job_jective_id = tweak_data.operations:get_camp_goto_objective_id(self._selected_job.level_id)
		local sub_objs = {
			"obj_camp_goto"
		}

		if not Global.game_settings.single_player and self._selected_job and not self._selected_job.active_card then
			table.insert(sub_objs, "obj_pick_a_card")
		end

		self:_select_job_dynamic_objectives(job_jective_id, sub_objs)
	end

	self._current_save_slot = nil

	managers.global_state:set_flag(self._selected_job.mission_state)
end

function RaidJobManager:_select_operation()
	Application:debug("[RaidJobManager:_select_operation]", inspect(self._selected_job))

	if Network:is_server() then
		self:_goto_operation_objective()
	end

	self._current_save_slot = self:get_available_save_slot()

	self:set_current_event(self._selected_job, 1)
	managers.global_state:set_flag(self._selected_job.current_event_data.mission_state)

	self._initial_global_states = managers.global_state:get_all_global_states()
end

function RaidJobManager:_goto_operation_objective()
	if not self:is_camp_loaded() then
		return
	end

	local id = nil

	if self._selected_job and self._selected_job.job_id then
		id = tweak_data.operations:get_camp_goto_objective_id(self._selected_job.job_id)

		Application:debug("[RaidJobManager:_goto_operation_objective] using selected_job job_id", self._selected_job.job_id)
	elseif self._current_job then
		if self._current_job.current_event_data and self._current_job.current_event_data.camp_objective_id then
			id = self._current_job.current_event_data.camp_objective_id

			Application:debug("[RaidJobManager:_goto_operation_objective] using camp_objective_id")
		else
			id = tweak_data.operations:get_camp_goto_objective_id(self._current_job.job_id)

			Application:debug("[RaidJobManager:_goto_operation_objective] using current_job job_id")
		end
	else
		id = "obj_camp_goto_raid"

		Application:debug("[RaidJobManager:_goto_operation_objective] using obj_camp_goto_raid default")
	end

	Application:debug("[RaidJobManager:_goto_operation_objective] ID:", id)

	local sub_objs = {
		"obj_camp_goto"
	}

	if not Global.game_settings.single_player and self._selected_job and not self._selected_job.active_card then
		table.insert(sub_objs, "obj_pick_a_card")
	end

	self:_select_job_dynamic_objectives(id, sub_objs)

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_selected_raid_objective", id)
	end
end

function RaidJobManager:sync_goto_job_objective(obj_id)
	Application:debug("[RaidJobManager:sync_goto_job_objective]", obj_id)

	local sub_objs = {
		"obj_camp_goto"
	}

	if not Global.game_settings.single_player and self._selected_job and not self._selected_job.active_card then
		table.insert(sub_objs, "obj_pick_a_card")
	end

	self:_select_job_dynamic_objectives(obj_id, sub_objs)
end

function RaidJobManager:_select_job_dynamic_objectives(obj_id, sub_id_list, sub_completed_list)
	Application:debug("[RaidJobManager:_select_job_dynamic_objectives] JOBJECTIVE ID", obj_id, inspect(sub_id_list), inspect(sub_completed_list))

	local obj_data = {
		prio = 1,
		id = "dyn_" .. obj_id,
		text = obj_id .. "_hl",
		description = obj_id .. "_desc"
	}
	local i = 1

	for _, t in ipairs(sub_id_list or {}) do
		local subid = "dyn_" .. t .. "_sub"

		print("[OBJ]", subid)

		obj_data[i] = {
			id = subid,
			text = t .. "_sub_hl",
			start_completed = sub_completed_list and sub_completed_list[i]
		}
		i = i + 1
	end

	managers.objectives:generate_dynamic_objective(obj_data)
end

function RaidJobManager:set_current_event(operation, index)
	Application:info("[RaidJobManager:set_current_event]", index, operation and operation.events_index and inspect(operation.events_index))

	operation.current_event = index
	local event_id = operation.events_index[index]
	operation.current_event_data = operation.events[event_id]
end

function RaidJobManager:start_selected_job()
	self:on_mission_started()

	if not Network:is_server() then
		return
	end

	Global.player_manager.game_settings_difficulty = Global.game_settings.difficulty
	self._current_job = self._selected_job
	self._selected_job = nil
	self._previously_completed_job = nil

	managers.statistics:start_session({
		from_beginning = true,
		drop_in = false
	})
	managers.network:session():send_to_peers_synched("start_statistics_session", true, false)
	managers.network:session():send_to_peers_synched("sync_current_job", self._current_job.job_id)
	managers.network:update_matchmake_attributes()
	managers.network.matchmake:set_job_info_by_current_job()
end

function RaidJobManager:on_mission_started()
	Application:debug("[RaidJobManager:on_mission_started()]")
	self:stop_sounds()

	self.start_time = TimerManager:wall_running():time()

	if managers.hud then
		managers.hud:reset_session_time()
	end

	self.memory = {}
	self.shortterm_memory = {}

	managers.experience:clear_mission_xp()
end

function RaidJobManager:on_mission_ended()
	Application:debug("[RaidJobManager:job_completion_trail] on_mission_ended, cleanup memory and save progress")

	self.memory = nil
	self.shortterm_memory = nil

	self:save_progress()
end

function RaidJobManager:on_restart_to_camp()
	self:_on_restart_to_camp()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_raid_job_on_restart_to_camp")
	end
end

function RaidJobManager:synced_on_restart_to_camp()
	self:_on_restart_to_camp()
end

function RaidJobManager:_on_restart_to_camp()
	managers.statistics:stop_session({
		success = false,
		quit = true
	})
	managers.lootdrop:reset_loot_value_counters()
	Application:debug("[AirdropManager] cleanup from RaidJobManager:_on_restart_to_camp")
	managers.airdrop:cleanup()
	managers.hud:reset_session_time()
	managers.global_state:reset_all_flags()

	if managers.player:current_state() == "turret" then
		managers.hud:hide_turret_hud(managers.player:get_turret_unit())
	end

	self:cleanup()

	if Network:is_server() then
		managers.network.matchmake:set_job_info_by_current_job()
	end

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

function RaidJobManager:start_selected_raid()
	self:start_selected_job()
end

function RaidJobManager:start_selected_operation()
	Application:debug("[RaidJobManager:start_selected_operation()]")
	self:start_selected_job()

	if Network:is_server() then
		self:save_progress()

		self._initial_global_states = nil
	end
end

function RaidJobManager:selected_job()
	return self._selected_job
end

function RaidJobManager:selected_job_id()
	return self._selected_job and self._selected_job.job_id
end

function RaidJobManager:previously_completed_job()
	return self._previously_completed_job
end

function RaidJobManager:current_job()
	return self._current_job
end

function RaidJobManager:is_in_tutorial()
	return self._current_job and self._current_job.level_id == "tutorial"
end

function RaidJobManager:current_job_id()
	return self._current_job and self._current_job.job_id
end

function RaidJobManager:current_level_id()
	return self._current_job and self._current_job.level_id
end

function RaidJobManager:current_job_type()
	return self._selected_job and self._selected_job.job_type or self._current_job and self._current_job.job_type
end

function RaidJobManager:on_mission_restart()
	managers.challenge_cards:remove_active_challenge_card()
	managers.greed:on_level_exited(false)
	managers.consumable_missions:on_level_exited(false)
	managers.statistics:reset_session()
	managers.lootdrop:reset_loot_value_counters()
	managers.airdrop:cleanup()
	self:on_mission_ended()
	self:on_mission_started()

	if managers.event_system:is_event_active() and Global.game_settings.event_enabled then
		managers.queued_tasks:queue("special_event_reenable", managers.event_system.activate_current_event, managers.event_system, true, 0.5)
	end

	if self._current_job.active_card then
		managers.queued_tasks:queue("job_active_card_reenable", managers.challenge_cards.set_active_card, managers.challenge_cards, self._current_job.active_card, 0.5)
	end
end

function RaidJobManager:external_start_mission()
	if not Network:is_server() then
		return
	end

	managers.worldcollection.level_transition_in_progress = true

	Application:debug("[RaidJobManager:external_start_mission()]")

	local mission = self._current_job or self._selected_job

	if not mission then
		Application:debug("[RaidJobManager:external_start_mission()] no current or selected job", mission)

		return
	end

	if not mission.job_id then
		Application:error("[RaidJobManager:external_start_mission] Lacking job_id, this will crash peers!", inspect(mission))

		return
	end

	local event_index = self._current_job and self._current_job.current_event or 1

	managers.network:session():send_to_peers_synched("sync_external_start_mission", mission.job_id, event_index, self.reload_mission_flag)
	self:do_external_start_mission(mission, event_index)
end

function RaidJobManager:do_external_start_mission(mission, event_index)
	managers.system_menu:force_close_all()
	managers.menu:close_all_menus()
	managers.player:set_local_player_in_camp(false)

	local data = {}

	managers.global_state:reset_flags_for_job("level_flag")

	if mission.job_type == OperationsTweakData.JOB_TYPE_RAID then
		self:start_selected_raid()

		data.background = mission.loading.image
		data.loading_text = mission.loading.text
		data.mission = mission

		managers.global_state:set_flag(mission.mission_flag)
	elseif mission.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		if event_index <= 1 and self._selected_job then
			self:start_selected_operation()
		end

		data.background = mission.current_event_data.loading.image
		data.loading_text = mission.current_event_data.loading.text
		data.mission = deep_clone(mission.current_event_data)
		data.mission.job_type = OperationsTweakData.JOB_TYPE_OPERATION
		data.mission.current_event = event_index
		data.mission.number_of_events = #mission.events_index
		data.mission.operation_name_id = mission.name_id
		data.mission.operation_icon = mission.icon_menu

		managers.global_state:set_flag(mission.current_event_data.mission_flag)
	else
		Application:error("[RaidJobManager:external_start_mission()] Missing job_type in tweak data for", mission.level_id)

		return
	end

	managers.consumable_missions:on_mission_started()
	managers.menu:show_loading_screen(data)
	managers.queued_tasks:queue(nil, self.external_start_mission_clbk, self, nil, 0.6, nil, true)
end

function RaidJobManager:external_start_mission_clbk()
	Application:debug("[RaidJobManager:external_start_mission_clbk()]", self.reload_mission_flag)

	managers.menu.loading_screen_visible = true
	managers.worldcollection.moving_to_camp = false

	if self._current_job then
		managers.worldcollection:set_world_counter(self._current_job.sub_worlds_spawned or 0)
	end

	managers.queued_tasks:queue(nil, managers.worldcollection.level_transition_started, managers.worldcollection, nil, 0.1)

	local mission_wp = managers.mission:get_element_by_name(RaidJobManager.WORLD_POINT_MISSION)
	local camp_wp = managers.mission:get_element_by_name(RaidJobManager.WORLD_POINT_CAMP)
	self._tutorial_spawned = false

	if self.reload_mission_flag then
		mission_wp._action = "despawn"

		mission_wp:on_executed()
	elseif camp_wp then
		camp_wp._action = "despawn"

		camp_wp:on_executed()
	else
		Application:debug("[RaidJobManager:external_start_mission_clbk()] No camp world point in the script! ", RaidJobManager.WORLD_POINT_CAMP, " Skipping despown step...")
	end

	local level_id, excluded_conts = nil

	if self._current_job then
		if self._current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
			level_id = self._current_job.level_id
			excluded_conts = self._current_job.excluded_continents
		elseif self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
			level_id = self._current_job.current_event_data.level_id
			excluded_conts = self._current_job.current_event_data.excluded_continents
		else
			Application:error("[RaidJobManager:external_start_mission_clbk()] Missing job_type in tweak data for", self._current_job.job_id)

			return
		end

		if not self.reload_mission_flag then
			self:load_level_tweak_packages(level_id)
		end
	end

	if mission_wp then
		mission_wp._action = "spawn"
		mission_wp._spawn_loot = true
		mission_wp._values.world = level_id
		mission_wp._excluded_continents = excluded_conts

		mission_wp:on_executed()
	else
		Application:debug("[RaidJobManager:external_start_mission_clbk()] No mission world point in the script!", RaidJobManager.WORLD_POINT_MISSION, " Skipping spawn step...")
	end
end

function RaidJobManager:load_level_tweak_packages(level_id)
	local packages_to_load = tweak_data.levels[level_id] and tweak_data.levels[level_id].package

	if packages_to_load then
		Application:debug("[RaidJobManager:load_level_tweak_packages()] Load coded level packages: #" .. tostring(#packages_to_load))

		for _, v in ipairs(packages_to_load) do
			PackageManager:load(v)
		end
	end
end

function RaidJobManager:external_end_mission(restart_camp, is_failed)
	Application:debug("[RaidJobManager:external_end_mission] SERVER?, restart_camp, is_failed", Network:is_server(), restart_camp, is_failed)

	managers.worldcollection.level_transition_in_progress = true

	managers.game_play_central:set_restarting(true)

	restart_camp = restart_camp or false
	local failed = is_failed or false
	self.restart_to_camp = restart_camp

	self:set_stage_success(not failed)

	if Network:is_server() then
		Application:debug("[RaidJobManager:external_end_mission()]")
		managers.network:session():send_to_peers_synched("sync_external_end_mission", restart_camp, failed or false)
		self:do_external_end_mission(restart_camp)
	end
end

function RaidJobManager:external_end_tutorial()
	if self:is_in_tutorial() then
		self:save_tutorial_played_flag(true)
		managers.global_state:fire_event("system_end_tutorial")

		setup.exit_to_main_menu = true

		managers.menu:fade_to_black()
		managers.queued_tasks:queue(nil, setup.quit_to_main_menu, setup, nil, 1)
	end
end

function RaidJobManager:tutorial_ended()
	self._tutorial_ended = nil

	Application:debug("[RaidJobManager:do_external_end_mission] tutorial_ended TRUE")
end

function RaidJobManager:set_temp_play_flag()
	PackageManager:load("packages/zone_germany")

	self._play_tutorial = true
	self._temp_play_flag = true
end

function RaidJobManager:revert_temp_play_flag()
	if self._temp_play_flag then
		self._play_tutorial = false
		self._tutorial_ended = false
	end

	self._temp_play_flag = nil
end

function RaidJobManager:played_tutorial()
	return not self._play_tutorial
end

function RaidJobManager:has_finished_tutorial()
	return self._tutorial_ended == nil
end

function RaidJobManager:do_external_end_mission(restart_camp)
	Application:debug("[RaidJobManager:job_completion_trail] do_external_end_mission, restart_camp:", restart_camp)
	managers.system_menu:force_close_all()
	managers.menu:close_all_menus()
	managers.player:set_local_player_in_camp(true)

	local current_job_success = self._current_job and self:stage_success()

	if current_job_success then
		for _, peer_data in pairs(managers.player:get_all_synced_carry()) do
			for _, data in pairs(peer_data) do
				local carry_data = tweak_data.carry[data.carry_id]

				if carry_data and not carry_data.skip_exit_secure then
					Application:debug("[RaidJobManager:job_completion_trail] Securing carry out bags!", data.carry_id)

					local carry_id = data.carry_id
					local multiplier = data.multiplier or 1
					local silent = true

					managers.loot:secure(carry_id, multiplier, silent)
				end
			end
		end
	end

	managers.consumable_missions:on_level_exited(current_job_success)
	managers.greed:on_level_exited(current_job_success)

	if restart_camp then
		Application:debug("[RaidJobManager:job_completion_trail] Restarting to camp")
		self:restart_camp()
	else
		Application:debug("[RaidJobManager:job_completion_trail] Level ended in either loss of win.    Success?", current_job_success)

		if self:is_at_last_event() and managers.challenge_cards:get_active_card_status() == ChallengeCardsManager.CARD_STATUS_ACTIVE then
			managers.challenge_cards:set_successfull_raid_end()
		end

		managers.drop_loot:set_enabled(true)

		local mission = self._camp

		if self._play_tutorial then
			self:set_selected_job("tutorial", nil)

			if game_state_machine:current_state().show_intro_video and not game_state_machine:current_state().intro_video_shown then
				game_state_machine:current_state():show_intro_video()

				return
			end

			self:start_selected_job()

			mission = self._current_job
		end

		local data = {}

		if not managers.worldcollection:first_pass() and mission.loading_success then
			Application:debug("[RaidJobManager:job_completion_trail] Loading screen as a mission success")

			local at_last_stage = false

			if not self._current_job then
				Application:debug("[RaidJobManager:job_completion_trail] Load success without current job...")

				data.mission = mission
			elseif self._current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
				Application:debug("[RaidJobManager:job_completion_trail] Load success as single stage raid job...")

				data.mission = self._current_job
				at_last_stage = true
			else
				Application:debug("[RaidJobManager:job_completion_trail] Load success as operation stage...")

				local operation_tweak_data = tweak_data.operations.missions[self._current_job.job_id]
				local current_event_id = self._current_job.events_index[self._current_job.current_event]
				local event_tweak_data = operation_tweak_data.events[current_event_id]
				data.mission = event_tweak_data
				at_last_stage = self._current_job.current_event == #self._current_job.events_index
			end

			if self._current_job then
				data.success = self:stage_success()

				if data.success and at_last_stage then
					Application:debug("[RaidJobManager:job_completion_trail] Current job stage is a success and we were on the last stage")

					local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
					local difficulty_index = tweak_data:difficulty_to_index(difficulty)

					Application:trace("[RaidJobManager:job_completion_trail] finished it on difficulty", difficulty)
					managers.progression:complete_mission_on_difficulty(self._current_job.job_type, self._current_job.job_id, difficulty_index)
				end

				local is_stealth = managers.groupai and managers.groupai:state():whisper_mode() or false

				self:set_memory("stealth_completion", is_stealth)
			end

			data.background = data.mission.loading.image
			data.loading_text = data.mission.loading.text
		else
			data.background = mission.loading.image
			data.loading_text = mission.loading.text
			data.mission = mission
		end

		if self._tutorial_ended then
			Application:debug("[RaidJobManager:job_completion_trail] _tutorial_ended is: TRUE (reset NIL)")
			self:tutorial_ended()
			self:complete_job()
		end

		managers.menu:show_loading_screen(data)
		managers.queued_tasks:queue(nil, self.external_end_mission_clbk, self, nil, 0.6, nil, true)
	end
end

function RaidJobManager:save_tutorial_played_flag(value)
	self._play_tutorial = not value

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

function RaidJobManager:set_tutorial_played_flag(value)
	self._play_tutorial = not value
end

function RaidJobManager:restart_camp()
	self:deactivate_current_job()
end

function RaidJobManager:external_end_mission_clbk()
	Application:debug("[RaidJobManager:external_end_mission_clbk()]")

	managers.menu.loading_screen_visible = true
	managers.worldcollection.moving_to_camp = true

	managers.worldcollection:set_world_counter(0)
	managers.queued_tasks:queue(nil, managers.worldcollection.level_transition_started, managers.worldcollection, nil, 0.1, nil)

	local mission_wp = managers.mission:get_element_by_name(RaidJobManager.WORLD_POINT_MISSION)
	local camp_wp = managers.mission:get_element_by_name(RaidJobManager.WORLD_POINT_CAMP)
	local tutorial_wp = managers.mission:get_element_by_name(RaidJobManager.WORLD_POINT_TUTORIAL)

	if self._play_tutorial then
		self._tutorial_spawned = true

		tutorial_wp:on_executed()

		return
	end

	if self._tutorial_spawned then
		if self:is_in_tutorial() then
			self:restart_camp()
		end

		self._tutorial_spawned = false
	end

	if mission_wp then
		mission_wp._action = "despawn"

		mission_wp:on_executed()
	else
		Application:debug("[RaidJobManager:external_end_mission_clbk()] No mission world point in the script!", RaidJobManager.WORLD_POINT_MISSION, " Skipping despown step...")
	end

	if camp_wp then
		camp_wp._action = "spawn"
		camp_wp._excluded_continents = self._camp.excluded_continents

		camp_wp:on_executed()
	else
		Application:debug("[RaidJobManager:external_end_mission_clbk()] No camp world point in the script! ", RaidJobManager.WORLD_POINT_CAMP, " Skipping spawn step...")
	end
end

function RaidJobManager:is_camp_loaded()
	local camp_wp = managers.mission:get_element_by_name(RaidJobManager.WORLD_POINT_CAMP)

	return camp_wp and camp_wp._has_created or false
end

function RaidJobManager:has_active_job()
	return not not self._current_job
end

function RaidJobManager:get_available_save_slot()
	local available_save_slot = nil

	for i = 1, SavefileManager.OPERATION_SAFE_SLOTS do
		if not self._save_slots[i] then
			available_save_slot = i

			break
		end
	end

	return available_save_slot
end

function RaidJobManager:get_first_save_slot()
	return self._save_slots and next(self._save_slots)
end

function RaidJobManager:has_available_save_slot()
	for i = 1, SavefileManager.OPERATION_SAFE_SLOTS do
		if not self._save_slots[i] then
			return true
		end
	end

	return false
end

function RaidJobManager:is_at_last_event()
	local job = self._current_job or game_state_machine._current_state._current_job_data

	if not job then
		if not managers.worldcollection:first_pass() then
			Application:warn("[RaidJobManager:is_at_last_event] Checking if at last event, but there is no current job! Returning FALSE")
		end

		return false
	end

	if job.job_type == OperationsTweakData.JOB_TYPE_RAID or job.current_event == #job.events_index then
		return true
	end

	return false
end

function RaidJobManager:complete_current_event()
	Application:trace("[RaidJobManager][complete_current_event]")

	if not self._current_job then
		Application:error("[RaidJobManager:complete_current_event] It seems you are not in a mission.")

		return
	end

	local event_loot_data = {
		acquired = managers.lootdrop:picked_up_current_leg(),
		spawned = managers.lootdrop:loot_spawned_current_leg()
	}

	table.insert(self._loot_data, event_loot_data)
	managers.system_event_listener:call_listeners(EventCompleteState.LOOT_DATA_READY_KEY)

	if self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		if self._stage_success then
			self._next_event_index = self._current_job.current_event + 1
		else
			self._next_event_index = self._current_job.current_event
		end

		Application:trace("[RaidJobManager:complete_current_event] self._next_event_index ", self._next_event_index)
	end

	managers.network.matchmake:set_job_info_by_current_job()
	managers.network:session():send_to_peers_synched("sync_event_loot_data", event_loot_data.acquired, event_loot_data.spawned)
	self:on_mission_ended()
end

function RaidJobManager:sync_current_event_index(current_event)
	self:set_current_event(self._current_job, current_event)
	self:on_mission_started()
end

function RaidJobManager:sync_event_loot_data(loot_acquired, loot_spawned)
	Application:trace("[RaidJobManager][sync_event_loot_data]")

	local event_loot_data = {
		acquired = loot_acquired,
		spawned = loot_spawned
	}

	table.insert(self._loot_data, event_loot_data)
	managers.system_event_listener:call_listeners(EventCompleteState.LOOT_DATA_READY_KEY)
end

function RaidJobManager:job_loot_data()
	return self._loot_data
end

function RaidJobManager:loot_acquired_in_job()
	local loot_acquired = 0

	for i, data in pairs(self._loot_data) do
		loot_acquired = loot_acquired + data.acquired
	end

	return loot_acquired
end

function RaidJobManager:loot_spawned_in_job()
	local loot_spawned = 0

	for i, data in pairs(self._loot_data) do
		loot_spawned = loot_spawned + data.spawned
	end

	return loot_spawned
end

function RaidJobManager:is_at_checkpoint()
	local current_event = self:current_operation_event()

	return current_event and current_event.checkpoint
end

function RaidJobManager:current_operation_event()
	if not self._current_job then
		return nil
	end

	return self._current_job.events[self._current_job.events_index[self._current_job.current_event]]
end

function RaidJobManager:start_next_event()
	if not self._current_job then
		self._stage_success = nil

		return
	end

	if self._current_job.current_event then
		if self._stage_success then
			self:start_event(self._current_job.current_event + 1)
		else
			self:start_event(self._current_job.current_event)
		end
	elseif self._current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
		self:complete_job()
	end

	self._stage_success = nil
end

function RaidJobManager:start_event(event_id)
	Application:debug("[RaidJobManager:start_event]", event_id)

	if not self._current_job then
		return
	end

	self:set_current_event(self._current_job, event_id)

	if self._current_job.job_type == OperationsTweakData.JOB_TYPE_RAID or self._current_job.current_event > #self._current_job.events_index then
		self:complete_job()

		return
	end

	if Network:is_server() and self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		self:_goto_operation_objective()
	end

	managers.network:session():send_to_peers_synched("sync_current_event_index", self._current_job.current_event)
	managers.global_state:reset_flags_for_job("sys_location")
	managers.global_state:set_flag(self._current_job.current_event_data.mission_state)
	managers.global_state:reset_flags_for_job("level_flag")
	managers.global_state:set_flag(self._current_job.current_event_data.mission_flag)
	managers.statistics:start_session({
		from_beginning = false,
		drop_in = false
	})
	managers.network:session():send_to_peers_synched("start_statistics_session", false, false)
	managers.lootdrop:reset_loot_value_counters()
	self:on_mission_started()
end

function RaidJobManager:complete_job()
	if Network:is_server() then
		if self._current_job then
			Application:debug("[RaidJobManager:job_completion_trail] (HOST) complete the whole job (raid finished or operation completed)")

			if self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
				self:delete_save(self._current_save_slot)
			end

			managers.network:session():send_to_peers_synched("sync_complete_job")
		else
			Application:warn("[RaidJobManager:job_completion_trail] (HOST) No job to complete? -> self._current_job", self._current_job)
		end
	else
		Application:debug("[RaidJobManager:job_completion_trail] (CLIENT) complete the whole job (raid finished or operation completed)")
	end

	self._current_save_slot = nil
	self._previously_completed_job = self._current_job
	self._current_job = nil
	self._loot_data = {}

	self:on_mission_ended()
	managers.statistics:reset_session()
	managers.lootdrop:reset_loot_value_counters()
end

function RaidJobManager:continue_operation(slot)
	local save_slot = self._save_slots[slot]

	if not save_slot then
		Application:error("[RaidJobManager:continue_operation] Cannot continue nil slot! Slot", slot, save_slot)

		return
	end

	managers.global_state:reset_all_flags()
	managers.global_state:set_global_states(save_slot.global_states)

	self._current_job = save_slot.current_job
	self._current_job.events_index = save_slot.events_index

	if self._current_job.events_index then
		tweak_data.operations.missions[self._current_job.job_id].events_index = self._current_job.events_index
		local list_delimited = table.concat(self._current_job.events_index, "|")

		managers.network:session():send_to_peers_synched("sync_randomize_operation", self._current_job.job_id, list_delimited)
	end

	if save_slot.difficulty then
		tweak_data:set_difficulty(save_slot.difficulty)
	end

	if save_slot.team_ai then
		Global.game_settings.team_ai = save_slot.team_ai
	end

	managers.network:session():send_to_peers_synched("sync_set_selected_job", self._current_job.job_id, Global.game_settings.difficulty)
	managers.network:session():send_to_peers_synched("sync_current_job", self._current_job.job_id)

	if save_slot.active_card then
		managers.challenge_cards:set_active_card(save_slot.active_card)
	end

	self._current_save_slot = slot
	self._loot_data = {}

	if save_slot.event_data then
		for event_index, event_data in pairs(save_slot.event_data) do
			local loot_data = event_data.loot_data

			if loot_data then
				self._loot_data[event_index] = loot_data

				managers.network:session():send_to_peers_synched("sync_event_loot_data", loot_data.acquired, loot_data.spawned)
			end
		end
	end

	managers.network.matchmake:set_job_info_by_current_job()

	local current_event = self._current_job.current_event
	self._selected_job = current_event == 1 and self._current_job

	self:start_event(current_event)
end

function RaidJobManager:clear_operations_save_slots()
	for i = 1, SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT do
		self._save_slots[i] = nil
	end

	self._current_save_slot = nil

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

function RaidJobManager:delete_save(slot)
	self._save_slots[slot] = nil
	self._current_save_slot = nil

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

function RaidJobManager:get_save_slots()
	return self._save_slots
end

function RaidJobManager:get_save_slot_downs(save_slot)
	local save_data = self._save_slots[save_slot]
	local total_downs = 0
	local all_players_downed = true

	if save_data then
		for events_index_index, _ in ipairs(save_data.events_index) do
			local event_data = save_data.event_data[events_index_index]

			if event_data and event_data.peer_data then
				for _, peer_data in pairs(event_data.peer_data) do
					if peer_data.statistics then
						total_downs = total_downs + (peer_data.statistics.downs or 0)

						if not peer_data.statistics.downs or peer_data.statistics.downs < 1 then
							all_players_downed = false
						end
					end
				end
			end
		end
	end

	return total_downs, all_players_downed
end

function RaidJobManager:save_progress()
	if self._current_job then
		if self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION or self._current_job.bounty then
			Application:info("[RaidJobManager:save_progress] Needs to save!")

			self._need_to_save = true

			managers.savefile:save_game(SavefileManager.SETTING_SLOT)
		end
	else
		Application:warn("[RaidJobManager:save_progress] Cant save, no current job")
	end
end

function RaidJobManager:on_challenge_card_failed()
	if self._current_job then
		if self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
			self._save_slots[self._current_save_slot].active_card.status = ChallengeCardsManager.CARD_STATUS_FAILED

			managers.savefile:save_game(SavefileManager.SETTING_SLOT)
		end
	else
		Application:warn("[RaidJobManager:on_challenge_card_failed] Cant save, no current job")
	end
end

function RaidJobManager:get_current_save_slot()
	return self._current_save_slot
end

function RaidJobManager:load_game(data)
	Application:trace("[RaidJobManager:load_game]", inspect(data.job_manager))

	local state = data.job_manager

	if state then
		if state.slots then
			self._save_slots = state.slots
		end

		self._play_tutorial = not state.tutorial_played
	end
end

function RaidJobManager:save_game(data)
	data.job_manager = {
		tutorial_played = not self._play_tutorial
	}

	if not self._current_job or self._current_job.job_type ~= OperationsTweakData.JOB_TYPE_OPERATION or not self._need_to_save then
		data.job_manager.slots = self._save_slots
		self._need_to_save = nil
		self._next_event_index = nil

		return
	end

	if managers.global_state then
		if Network:is_server() and self._current_save_slot and self._current_job then
			local save_data = {
				global_states = self._initial_global_states or managers.global_state:get_all_global_states()
			}
			local current_job = deep_clone(self._current_job)

			if not self._save_slots[self._current_save_slot] then
				self._save_slots[self._current_save_slot] = {}
			end

			save_data.event_data = self._save_slots[self._current_save_slot].event_data

			if not save_data.event_data then
				save_data.event_data = {}
			end

			if not save_data.event_data[current_job.current_event] then
				save_data.event_data[current_job.current_event] = {}
			end

			save_data.event_data[current_job.current_event].peer_data = self:_prepare_peer_save_data()

			if self._next_event_index then
				current_job.current_event = self._next_event_index
			end

			local active_card = managers.challenge_cards:get_active_card()

			if active_card then
				save_data.active_card = deep_clone(active_card)
				save_data.active_card.status = ChallengeCardsManager.CARD_STATUS_NORMAL
			end

			save_data.current_job = current_job

			for index, data in pairs(self._loot_data) do
				if not save_data.event_data[index] then
					save_data.event_data[index] = {}
				end

				save_data.event_data[index].loot_data = data
			end

			save_data.difficulty = Global.game_settings.difficulty
			save_data.difficulty_id = tweak_data:difficulty_to_index(save_data.difficulty)
			save_data.permission = Global.game_settings.permission
			save_data.drop_in_allowed = Global.game_settings.drop_in_allowed
			save_data.team_ai = self._save_slots[self._current_save_slot].team_ai

			if save_data.team_ai == nil then
				save_data.team_ai = Global.game_settings.team_ai
			end

			save_data.events_index = current_job.events_index
			self._save_slots[self._current_save_slot] = save_data
		end

		data.job_manager.slots = self._save_slots
		self._need_to_save = nil
	end
end

function RaidJobManager:_prepare_peer_save_data()
	local local_peer = managers.network:session():local_peer()
	local peer_id = local_peer:id()
	local local_player_data = {
		is_local_player = true,
		name = utf8.to_upper(managers.player:get_character_profile_name()),
		class = managers.skilltree:get_character_profile_class(),
		nationality = local_peer:character(),
		level = managers.experience:current_level(),
		player_id = local_peer:user_id(),
		statistics = local_peer:statistics()
	}
	local peer_save_data = {
		local_player_data
	}

	for index, peer in pairs(managers.network:session():all_peers()) do
		if not peer:id() == peer_id then
			local peer_data = {
				name = peer:name(),
				class = peer:class(),
				nationality = peer:character(),
				level = peer:level(),
				player_id = peer:user_id(),
				statistics = peer:statistics()
			}

			table.insert(peer_save_data, peer_data)
		end
	end

	return peer_save_data
end

function RaidJobManager:sync_current_job(job_id)
	self._loot_data = {}
	self._selected_job = nil
	self._current_job = nil
	self._current_job = tweak_data.operations:mission_data(job_id)

	if self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		self:set_current_event(self._current_job, 1)
	end

	self:on_mission_started()
end

function RaidJobManager:set_memory(key, value, is_shortterm)
	if self.memory and not is_shortterm then
		self.memory[key] = value
	elseif self.shortterm_memory then
		self.shortterm_memory[key] = value
	end

	return false
end

function RaidJobManager:get_memory(key, is_shortterm)
	if is_shortterm then
		return self.shortterm_memory and self.shortterm_memory[key]
	else
		return self.memory and self.memory[key]
	end
end

function RaidJobManager:sync_save(data)
	local state = {
		selected_job_id = self._selected_job and self._selected_job.job_id,
		current_job_id = self._current_job and self._current_job.job_id,
		current_job_event = self._current_job and self._current_job.current_event,
		loot_data = self._loot_data
	}

	if self._selected_job and self._selected_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		state.events_index = self._selected_job.events_index
	end

	if self._current_job and self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		state.events_index = self._current_job.events_index
	end

	data.RaidJobManager = state
end

function RaidJobManager:sync_load(data)
	local state = data.RaidJobManager

	Application:debug("[RaidJobManager:sync_load]", inspect(state))

	if state.current_job_id then
		self._current_job = tweak_data.operations:mission_data(state.current_job_id)
		self._current_job.job_id = state.current_job_id

		if self._current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
			self._current_job.events_index = state.events_index
			tweak_data.operations.missions[state.current_job_id].events_index = state.events_index

			self:set_current_event(self._current_job, state.current_job_event)
			self:_goto_operation_objective()
		end

		self._loot_data = state.loot_data
	end

	if state.selected_job_id then
		self._selected_job = tweak_data.operations:mission_data(state.selected_job_id)

		if state.events_index then
			self._selected_job.events_index = state.events_index
			tweak_data.operations.missions[state.selected_job_id].events_index = state.events_index
		end

		self._selected_job.job_id = state.selected_job_id

		if self._selected_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
			self:_goto_operation_objective()
		else
			local job_jective_id = tweak_data.operations:get_camp_goto_objective_id(self._selected_job.level_id)

			self:sync_goto_job_objective(job_jective_id)
		end
	end
end

function RaidJobManager:cleanup()
	self._current_save_slot = {}
	self._loot_data = {}
	self._selected_job = nil
	self._current_job = nil
	self._stage_success = nil
	self._tutorial_spawned = nil
end

function RaidJobManager:reset()
	self:cleanup()

	self._save_slots = {}
end

function RaidJobManager:on_simulation_ended()
	self._save_slots = {}

	self:cleanup()
end

function RaidJobManager:stop_sounds()
	local cleanup = SoundDevice:create_source("cleanup")
end

function RaidJobManager:set_stage_success(success)
	Application:info("[RaidJobManager:set_stage_success]", success)

	self._stage_success = success
end

function RaidJobManager:stage_success()
	return self._stage_success
end

function RaidJobManager:deactivate_current_job()
	self._current_job = nil
	self._selected_job = nil
	self._stage_success = nil
	self.start_time = nil
	self.memory = nil
	self.shortterm_memory = nil

	managers.loot:on_job_deactivated()
	managers.mission:on_job_deactivated()
	self:stop_sounds()
	managers.network.matchmake:set_job_info_by_current_job()
end

function RaidJobManager:set_camp(job_id)
	local job = tweak_data.operations.missions[job_id]
	self._camp = job

	return true
end

function RaidJobManager:camp()
	return self._camp
end

function RaidJobManager:exclude_camp_continent(continent_id)
	if self._camp and not table.contains(self._camp.excluded_continents, continent_id) then
		table.insert(self._camp.excluded_continents, continent_id)
	end
end
