ProgressionManager = ProgressionManager or class()
ProgressionManager.VERSION = 1
ProgressionManager.MISSION_STATE_LOCKED = "locked"
ProgressionManager.MISSION_STATE_OFFERED = "offered"
ProgressionManager.MISSION_STATE_UNLOCKED = "unlocked"
ProgressionManager.OPERATIONS_STATE_LOCKED = "locked"
ProgressionManager.OPERATIONS_STATE_PENDING = "pending"
ProgressionManager.OPERATIONS_STATE_UNLOCKED = "unlocked"
ProgressionManager.TROPHY_CASE_UNIT = Idstring("units/vanilla/props/props_camp_upgrades/props_camp_trophy_case/props_camp_trophy_case")
ProgressionManager.TROPHY_DIFFICULTY_SEQUENCES = {
	"wood",
	"bronze",
	"silver",
	"gold"
}
ProgressionManager.TROPHY_MAX_ROTATION_OFFSET = 22
ProgressionManager.TROPHY_MAX_X_OFFSET = 8
ProgressionManager.TROPHY_MAX_Y_OFFSET = 5

-- Lines 37-45
function ProgressionManager.get_instance()
	if not Global.progression_manager then
		Global.progression_manager = ProgressionManager:new()
	end

	setmetatable(Global.progression_manager, ProgressionManager)

	return Global.progression_manager
end

-- Lines 48-59
function ProgressionManager:init()
	self._mission_progression_completion_pending = false
	self._mission_progression_completed = false
	self._first_time_missions_unlocked = false
	self._operations_state = ProgressionManager.OPERATIONS_STATE_LOCKED
	self._unlock_cycles_completed = 0
	self._mission_unlock_timer = tweak_data.operations.progression.regular_unlock_cycle_duration
	self._mission_progression = {}

	self:_setup()
	self:_unlock_first_time_missions()
end

-- Lines 62-64
function ProgressionManager:reset()
	self:init()
end

-- Lines 67-69
function ProgressionManager:_setup()
	self:_setup_mission_states()
end

-- Lines 72-103
function ProgressionManager:_setup_mission_states()
	if not self._mission_progression[OperationsTweakData.JOB_TYPE_RAID] then
		self._mission_progression[OperationsTweakData.JOB_TYPE_RAID] = {}
	end

	for group_index, progression_group in pairs(tweak_data.operations.progression.mission_groups) do
		for mission_index, mission_id in pairs(progression_group) do
			if not self._mission_progression[OperationsTweakData.JOB_TYPE_RAID][mission_id] then
				self._mission_progression[OperationsTweakData.JOB_TYPE_RAID][mission_id] = {}

				if self._mission_progression_completed or self._mission_progression_completion_pending then
					self:_unlock_mission(OperationsTweakData.JOB_TYPE_RAID, mission_id)
				else
					self._mission_progression[OperationsTweakData.JOB_TYPE_RAID][mission_id].state = ProgressionManager.MISSION_STATE_LOCKED
				end
			end
		end
	end

	if not self._mission_progression[OperationsTweakData.JOB_TYPE_OPERATION] then
		self._mission_progression[OperationsTweakData.JOB_TYPE_OPERATION] = {}
	end

	for mission_id, mission_data in pairs(tweak_data.operations.missions) do
		if mission_data.job_type and mission_data.job_type == OperationsTweakData.JOB_TYPE_OPERATION and not self._mission_progression[OperationsTweakData.JOB_TYPE_OPERATION][mission_id] then
			self._mission_progression[OperationsTweakData.JOB_TYPE_OPERATION][mission_id] = {}

			self:_unlock_mission(OperationsTweakData.JOB_TYPE_OPERATION, mission_id)
		end
	end
end

-- Lines 106-111
function ProgressionManager:_unlock_mission(job_type, mission_id)
	Application:trace("[ProgressionManager][_unlock_mission] Unlocking mission " .. tostring(mission_id))

	self._mission_progression[job_type][mission_id].state = ProgressionManager.MISSION_STATE_UNLOCKED
	self._mission_progression[job_type][mission_id].difficulty_available = tweak_data.operations.progression.initially_unlocked_difficulty
	self._mission_progression[job_type][mission_id].difficulty_completed = 0
end

-- Lines 114-117
function ProgressionManager:_offer_mission(mission_id)
	Application:trace("[ProgressionManager][_offer_mission] Offering mission " .. tostring(mission_id))

	self._mission_progression[OperationsTweakData.JOB_TYPE_RAID][mission_id].state = ProgressionManager.MISSION_STATE_OFFERED
end

-- Lines 120-126
function ProgressionManager:mission_unlocked(job_type, mission_id)
	if self._mission_progression[job_type][mission_id] and self._mission_progression[job_type][mission_id].state == ProgressionManager.MISSION_STATE_UNLOCKED then
		return true
	end

	return false
end

-- Lines 131-143
function ProgressionManager:have_pending_missions_to_unlock()
	for mission_type, mission_group in pairs(self._mission_progression) do
		for mission_id, mission_data in pairs(mission_group) do
			if tweak_data.operations.missions[mission_id] and mission_data.state == ProgressionManager.MISSION_STATE_OFFERED then
				return true
			end
		end
	end

	return false
end

-- Lines 146-158
function ProgressionManager:pending_missions_to_unlock()
	local pending_missions = {}

	for mission_type, mission_group in pairs(self._mission_progression) do
		for mission_id, mission_data in pairs(mission_group) do
			if mission_data.state == ProgressionManager.MISSION_STATE_OFFERED then
				table.insert(pending_missions, mission_id)
			end
		end
	end

	return pending_missions
end

-- Lines 161-163
function ProgressionManager:mission_progression_completed()
	return self._mission_progression_completed
end

-- Lines 167-181
function ProgressionManager:set_operations_state(state)
	if self._operations_state == state then
		return
	end

	Application:trace("[ProgressionManager][set_operations_state] Changing the Operations state from " .. tostring(self._operations_state) .. " to " .. tostring(state))

	self._operations_state = state

	if state == ProgressionManager.OPERATIONS_STATE_PENDING and not managers.breadcrumb:category_has_breadcrumbs(BreadcrumbManager.CATEGORY_OPERATIONS) then
		managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_OPERATIONS, {
			"operations_pending"
		})
	end

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

-- Lines 184-186
function ProgressionManager:operations_state()
	return self._operations_state
end

-- Lines 189-191
function ProgressionManager:operations_unlocked()
	return self._operations_state == ProgressionManager.OPERATIONS_STATE_UNLOCKED
end

-- Lines 194-200
function ProgressionManager:at_final_unlock_cycle()
	if not self._mission_progression_completed and (self._unlock_cycles_completed == tweak_data.operations.progression.unlock_cycles - 1 or self._unlock_cycles_completed == tweak_data.operations.progression.unlock_cycles) then
		return true
	end

	return false
end

-- Lines 203-209
function ProgressionManager:time_until_next_unlock()
	if self._mission_progression_completed or self._mission_progression_completion_pending then
		return 0
	end

	return self._mission_unlock_timer
end

-- Lines 212-218
function ProgressionManager:get_mission_progression(mission_type, mission_id)
	if not self:mission_unlocked(mission_type, mission_id) then
		return
	end

	return self._mission_progression[mission_type][mission_id].difficulty_available, self._mission_progression[mission_type][mission_id].difficulty_completed
end

-- Lines 221-234
function ProgressionManager:complete_mission_on_difficulty(job_type, mission_id, difficulty)
	Application:trace("[ProgressionManager][complete_mission_on_difficulty] Completing mission " .. tostring(mission_id) .. " on difficulty " .. tostring(difficulty))

	if not self._mission_progression[job_type][mission_id] or self._mission_progression[job_type][mission_id].state ~= ProgressionManager.MISSION_STATE_UNLOCKED then
		return
	end

	if self._mission_progression[job_type][mission_id].difficulty_completed < difficulty then
		self._mission_progression[job_type][mission_id].difficulty_completed = math.clamp(difficulty, 1, self._mission_progression[job_type][mission_id].difficulty_available)
	end

	if self._mission_progression[job_type][mission_id].difficulty_completed == self._mission_progression[job_type][mission_id].difficulty_available then
		self._mission_progression[job_type][mission_id].difficulty_available = math.clamp(self._mission_progression[job_type][mission_id].difficulty_available + 1, 1, tweak_data:number_of_difficulties())
	end
end

-- Lines 237-270
function ProgressionManager:choose_offered_mission(mission_id)
	Application:trace("[ProgressionManager][choose_offered_mission] The player has chosen to unlock mission " .. tostring(mission_id))

	if not self._mission_progression[OperationsTweakData.JOB_TYPE_RAID][mission_id] or self._mission_progression[OperationsTweakData.JOB_TYPE_RAID][mission_id].state ~= ProgressionManager.MISSION_STATE_OFFERED then
		Application:error("[ProgressionManager:choose_offered_mission] Tried to unlock a mission that was not available to unlock!", mission_id)

		return
	end

	self:_unlock_mission(OperationsTweakData.JOB_TYPE_RAID, mission_id)

	for mission_id, mission_data in pairs(self._mission_progression[OperationsTweakData.JOB_TYPE_RAID]) do
		if mission_data.state == ProgressionManager.MISSION_STATE_OFFERED then
			mission_data.state = ProgressionManager.MISSION_STATE_LOCKED
		end
	end

	self._unlock_cycles_completed = self._unlock_cycles_completed + 1

	if self._unlock_cycles_completed == tweak_data.operations.progression.unlock_cycles then
		self._mission_progression_completed = true
	elseif self._unlock_cycles_completed < tweak_data.operations.progression.unlock_cycles - 1 then
		self._mission_unlock_timer = tweak_data.operations.progression.regular_unlock_cycle_duration
	else
		self._mission_unlock_timer = tweak_data.operations.progression.final_unlock_cycle_duration
	end

	managers.breadcrumb:remove_breadcrumb(BreadcrumbManager.CATEGORY_NEW_RAID, {
		"progression_system_new_raid"
	})
	managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_NEW_RAID, {
		mission_id
	})

	self._last_unlocked_raid = mission_id

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

-- Lines 273-283
function ProgressionManager:clear_last_unlocked_raid()
	local last_unlocked = nil

	if self._last_unlocked_raid then
		last_unlocked = self._last_unlocked_raid
		self._last_unlocked_raid = nil

		managers.savefile:save_game(SavefileManager.SETTING_SLOT)
	end

	return last_unlocked
end

-- Lines 286-303
function ProgressionManager:_unlock_first_time_missions()
	Application:trace("[ProgressionManager][_unlock_first_time_missions] Unlocking first-time missions!")

	for blueprint_index, blueprint_mission_type in pairs(tweak_data.operations.progression.initial_mission_unlock_blueprint) do
		local unlocked_required_mission = false
		local potential_missions = tweak_data.operations.progression.mission_groups[blueprint_mission_type]

		while not unlocked_required_mission do
			local mission_index_chosen = math.random(1, #potential_missions)

			if not self:mission_unlocked(OperationsTweakData.JOB_TYPE_RAID, potential_missions[mission_index_chosen]) then
				self:_unlock_mission(OperationsTweakData.JOB_TYPE_RAID, potential_missions[mission_index_chosen])

				unlocked_required_mission = true
			end
		end
	end

	self._first_time_missions_unlocked = true
end

-- Lines 306-330
function ProgressionManager:_unlock_all_missions()
	Application:trace("[ProgressionManager][_unlock_all_missions] Unlocking all remaining missions!")

	for mission_type_id, mission_type_missions in pairs(self._mission_progression) do
		for mission_id, mission_data in pairs(mission_type_missions) do
			if mission_data.state ~= ProgressionManager.MISSION_STATE_UNLOCKED then
				self:_unlock_mission(mission_type_id, mission_id)
			end

			local mission_tweak_data = tweak_data.operations.missions[mission_id]

			if mission_tweak_data and mission_tweak_data.control_brief_video then
				for video_index, video_path in pairs(mission_tweak_data.control_brief_video) do
					local chosen_video_unlock_id = tweak_data.intel:get_control_video_by_path(video_path)

					if chosen_video_unlock_id then
						managers.unlock:unlock({
							slot = UnlockManager.SLOT_PROFILE,
							identifier = UnlockManager.CATEGORY_CONTROL_ARCHIVE
						}, {
							chosen_video_unlock_id
						})
					end
				end
			else
				Application:trace("[ProgressionManager:_unlock_all_missions] Tried to unlock a map that doesn't exist, call programmers, level:" .. mission_id)
			end
		end
	end

	self._unlock_cycles_completed = self._unlock_cycles_completed + 1
	self._mission_progression_completion_pending = true
end

-- Lines 333-335
function ProgressionManager:mission_progression_completion_pending()
	return self._mission_progression_completion_pending
end

-- Lines 338-344
function ProgressionManager:complete_mission_progression()
	Application:trace("[ProgressionManager][complete_mission_progression] Mission progression completed!")

	self._mission_progression_completed = true
	self._mission_progression_completion_pending = false

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

-- Lines 347-390
function ProgressionManager:_offer_new_missions()
	Application:trace("[ProgressionManager][_offer_new_missions] Offering a couple of new missions!")

	local missions_to_make_available = #tweak_data.operations.progression.regular_mission_unlock_blueprint
	local locked_missions = {}
	local have_locked_missions = false

	for _, mission_type in pairs(tweak_data.operations.progression.regular_mission_unlock_blueprint) do
		if not locked_missions[mission_type] then
			locked_missions[mission_type] = {}

			for index, mission_name in pairs(tweak_data.operations.progression.mission_groups[mission_type]) do
				if not self:mission_unlocked(OperationsTweakData.JOB_TYPE_RAID, mission_name) then
					table.insert(locked_missions[mission_type], mission_name)

					have_locked_missions = true
				end
			end
		end
	end

	while missions_to_make_available > 0 and have_locked_missions do
		have_locked_missions = false

		for _, mission_type in pairs(tweak_data.operations.progression.regular_mission_unlock_blueprint) do
			if locked_missions[mission_type] and #locked_missions[mission_type] > 0 then
				math.shuffle(locked_missions[mission_type])

				local mission_unlocked = table.remove(locked_missions[mission_type])

				self:_offer_mission(mission_unlocked)

				missions_to_make_available = missions_to_make_available - 1
			end
		end

		for mission_type, locked_missions_of_type in pairs(locked_missions) do
			if #locked_missions_of_type > 0 then
				have_locked_missions = true

				break
			else
				locked_missions[mission_type] = nil
			end
		end
	end

	managers.breadcrumb:add_breadcrumb(BreadcrumbManager.CATEGORY_NEW_RAID, {
		"progression_system_new_raid"
	})
end

-- Lines 393-402
function ProgressionManager:update(t, dt)
	local is_in_mission = BaseNetworkHandler._gamestate_filter.any_ingame_mission[game_state_machine:current_state_name()] and not managers.raid_job:is_camp_loaded()
	local doneso = is_in_mission and managers.raid_job:played_tutorial() and not self._mission_progression_completed and not self._mission_progression_completion_pending and self._mission_unlock_timer > 0

	if doneso then
		self._mission_unlock_timer = math.max(0, self._mission_unlock_timer - dt)

		if self._mission_unlock_timer == 0 then
			self:_on_cycle_completed()
		end
	end
end

-- Lines 405-419
function ProgressionManager:_on_cycle_completed()
	Application:trace("[ProgressionManager][_on_cycle_completed] Progression cycle completed. Determining what to do...")

	self._mission_unlock_timer = 0

	if self._unlock_cycles_completed == tweak_data.operations.progression.unlock_cycles - 1 then
		self:_unlock_all_missions()
	else
		self:_offer_new_missions()
	end

	if managers.hud then
		managers.hud:on_progression_cycle_completed()
	end

	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
end

-- Lines 422-462
function ProgressionManager:layout_camp()
	Application:trace("[ProgressionManager][layout_camp] Laying out camp.")

	local trophy_case_unit = self:_get_trophy_case_unit()

	if not managers.player:local_player_in_camp() or not trophy_case_unit then
		return
	end

	local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(trophy_case_unit:id())

	for mission_type, missions_of_type in pairs(self._mission_progression) do
		for mission_id, mission_data in pairs(missions_of_type) do
			if mission_data.state == ProgressionManager.MISSION_STATE_UNLOCKED and mission_data.difficulty_completed > 0 then
				local mission_trophy = tweak_data.operations.missions[mission_id] and tweak_data.operations.missions[mission_id].trophy

				if mission_trophy then
					local trophy_locator = trophy_case_unit:get_object(Idstring(mission_trophy.position))
					local difficulty_sequence_to_run = ProgressionManager.TROPHY_DIFFICULTY_SEQUENCES[mission_data.difficulty_completed]
					local rotation_offset = math.random(-ProgressionManager.TROPHY_MAX_ROTATION_OFFSET, ProgressionManager.TROPHY_MAX_ROTATION_OFFSET)
					local spawn_rotation = Rotation(trophy_locator:rotation():yaw() + rotation_offset, trophy_locator:rotation():pitch(), trophy_locator:rotation():roll())
					local position_offset_x = math.random(-ProgressionManager.TROPHY_MAX_X_OFFSET, ProgressionManager.TROPHY_MAX_X_OFFSET)
					local position_offset_y = math.random(-ProgressionManager.TROPHY_MAX_Y_OFFSET, ProgressionManager.TROPHY_MAX_Y_OFFSET)
					local spawn_position = Vector3(trophy_locator:position().x + position_offset_x, trophy_locator:position().y + position_offset_y, trophy_locator:position().z)

					Application:trace("[ProgressionManager][layout_camp] Creating a " .. tostring(difficulty_sequence_to_run) .. " " .. tostring(mission_id) .. " trophy!")

					local trophy = World:spawn_unit(Idstring(mission_trophy.unit), spawn_position, spawn_rotation)

					trophy:damage():run_sequence_simple(difficulty_sequence_to_run)
					managers.network:session():send_to_peers_synched("sync_camp_trophy", trophy, mission_data.difficulty_completed)

					if not Application:editor() then
						managers.worldcollection:register_spawned_unit(trophy, spawn_position, world_id)
					end
				end
			end
		end
	end
end

-- Lines 464-467
function ProgressionManager:sync_trophy_level(unit, trophy_level)
	local difficulty_sequence_to_run = ProgressionManager.TROPHY_DIFFICULTY_SEQUENCES[trophy_level]

	unit:damage():run_sequence_simple(difficulty_sequence_to_run)
end

-- Lines 470-483
function ProgressionManager:_get_trophy_case_unit()
	local units = World:find_units_quick("all", managers.slot:get_mask("world_geometry"))

	if units then
		for _, unit in pairs(units) do
			if unit:name() == ProgressionManager.TROPHY_CASE_UNIT then
				return unit
			end
		end
	end
end

-- Lines 486-498
function ProgressionManager:save_profile_slot(data)
	local state = {
		version = ProgressionManager.VERSION,
		mission_progression_completed = self._mission_progression_completed,
		mission_progression_completion_pending = self._mission_progression_completion_pending,
		unlock_cycles_completed = self._unlock_cycles_completed,
		first_time_missions_unlocked = self._first_time_missions_unlocked,
		operations_state = self._operations_state,
		mission_unlock_timer = self._mission_unlock_timer,
		mission_progression = self._mission_progression
	}
	data.ProgressionManager = state
end

-- Lines 501-527
function ProgressionManager:load_profile_slot(data, version)
	local state = data.ProgressionManager

	if not state then
		self:_unlock_first_time_missions()
		managers.savefile:set_resave_required()

		return
	end

	if not state.version or state.version and state.version ~= ProgressionManager.VERSION then
		self.version = ProgressionManager.VERSION
	else
		self.version = state.version or 1
		self._mission_progression_completed = state.mission_progression_completed
		self._mission_progression_completion_pending = state.mission_progression_completion_pending
		self._unlock_cycles_completed = state.unlock_cycles_completed
		self._first_time_missions_unlocked = state.first_time_missions_unlocked
		self._operations_state = state.operations_state
		self._mission_unlock_timer = math.max(30, state.mission_unlock_timer)
		self._mission_progression = state.mission_progression or {}
	end

	self:_setup()

	if not self._first_time_missions_unlocked then
		self:_unlock_first_time_missions()
		managers.savefile:set_resave_required()
	end
end
