RaidExperienceManager = RaidExperienceManager or class()
RaidExperienceManager.LEVEL_CAP = Application:digest_value(40, true)
RaidExperienceManager.THOUSAND_SEPARATOR = ","
RaidExperienceManager.VERSION = 87
RaidExperienceManager.XP_MIGRATION_VERSION_LIST = {
	85,
	86
}
RaidExperienceManager.SCRIPT_XP_EVENTS = {
	"stealth_bonus",
	"escort_survived_bonus",
	"side_quest_bonus",
	"extra_objectives_bonus",
	"tiny_objectives_bonus",
	"tiny_loot_bonus",
	"sugar_high_bonus"
}

function RaidExperienceManager:init()
	self:_setup()
end

function RaidExperienceManager:xp_migration_needed(version)
	for i = 1, #RaidExperienceManager.XP_MIGRATION_VERSION_LIST do
		if RaidExperienceManager.XP_MIGRATION_VERSION_LIST[i] == version then
			return true
		end
	end

	return false
end

function RaidExperienceManager:_setup()
	self._total_levels = #tweak_data.experience_manager.levels

	if not Global.experience_manager then
		Global.experience_manager = {
			total = Application:digest_value(0, true),
			level = Application:digest_value(1, true),
			total_xp_for_level = {}
		}
		local total_xp = 0

		for i_level = 1, Application:digest_value(RaidExperienceManager.LEVEL_CAP, false) do
			total_xp = total_xp + tweak_data:get_value("experience_manager", "levels", i_level, "points")

			table.insert(Global.experience_manager.total_xp_for_level, Application:digest_value(total_xp, true))
		end
	end

	self._global = Global.experience_manager

	if not self._global.next_level_data then
		self:_set_next_level_data(2)
	end

	self._global.mission_xp = {}
end

function RaidExperienceManager:get_script_xp_events()
	local events = {}

	for i, v in ipairs(RaidExperienceManager.SCRIPT_XP_EVENTS) do
		table.insert(events, v)
	end

	return events
end

function RaidExperienceManager:_set_next_level_data(level)
	if self._total_levels < level then
		print("Reached the level cap")

		return
	end

	local level_data = tweak_data.experience_manager.levels[level]
	self._global.next_level_data = {}

	self:_set_next_level_data_points(level_data.points)
	self:_set_next_level_data_current_points(0)
end

function RaidExperienceManager:get_total_xp_for_level(level)
	if not level or level < 1 then
		Application:error("[RaidExperienceManager:get_total_xp_for_level] level passed in is below 1: ", level)

		level = 1
	elseif Application:digest_value(RaidExperienceManager.LEVEL_CAP, false) < level then
		Application:error("[RaidExperienceManager:get_total_xp_for_level] level passed in is above max: ", level)

		level = Application:digest_value(RaidExperienceManager.LEVEL_CAP, false)
	end

	local xp = Application:digest_value(Global.experience_manager.total_xp_for_level[level], false)

	return xp
end

function RaidExperienceManager:next_level_data_points()
	return self._global.next_level_data and Application:digest_value(self._global.next_level_data.points, false) or 0
end

function RaidExperienceManager:_set_next_level_data_points(value)
	self._global.next_level_data.points = value
end

function RaidExperienceManager:next_level_data_current_points()
	return self._global.next_level_data and Application:digest_value(self._global.next_level_data.current_points, false) or 0
end

function RaidExperienceManager:_set_next_level_data_current_points(value)
	self._global.next_level_data.current_points = Application:digest_value(value, true)
end

function RaidExperienceManager:next_level_data()
	return {
		current_points = nil,
		points = nil,
		points = self:next_level_data_points(),
		current_points = self:next_level_data_current_points()
	}
end

function RaidExperienceManager:mission_xp_award(event)
	table.insert(self._global.mission_xp, event)
	Application:debug("[MissionXPAwards] Added event '" .. event .. "' list size:", #self._global.mission_xp)
end

function RaidExperienceManager:clear_mission_xp()
	self._global.mission_xp = {}

	Application:debug("[MissionXPAwards] Reset XP events")
end

function RaidExperienceManager:add_loot_redeemed_xp(xp)
	if not self._loot_redeemed_xp then
		self._loot_redeemed_xp = 0
	end

	self._loot_redeemed_xp = self._loot_redeemed_xp + xp
end

function RaidExperienceManager:clear_loot_redeemed_xp()
	self._loot_redeemed_xp = nil
end

function RaidExperienceManager:set_loot_bonus_xp(amount)
	self._loot_bonus_xp = amount
end

function RaidExperienceManager:clear_loot_bonus_xp()
	self._loot_bonus_xp = nil
end

function RaidExperienceManager:calculate_exp_breakdown(mission_id, operation_id, success)
	local exp_table = {
		multiplicative = nil,
		additive = nil,
		additive = {},
		multiplicative = {}
	}
	local base_id = operation_id or mission_id
	local event_additive = {
		id = "xp_additive_event"
	}

	if operation_id then
		if table.index_of(game_state_machine:current_state():job_data().events_index, mission_id) == #game_state_machine:current_state():job_data().events_index then
			local operation_additive = {
				id = "xp_additive_operation",
				amount = tweak_data.operations.missions[operation_id].xp
			}

			table.insert(exp_table.additive, operation_additive)
		end

		event_additive.amount = tweak_data.operations.missions[operation_id].events[mission_id].xp
	else
		event_additive.amount = tweak_data.operations.missions[mission_id].xp
	end

	table.insert(exp_table.additive, event_additive)

	if self._loot_bonus_xp then
		local bonus_xp_additive = {
			id = "menu_loot_screen_bonus_xp_points",
			amount = self._loot_bonus_xp
		}

		table.insert(exp_table.additive, bonus_xp_additive)
		self:clear_loot_bonus_xp()
	end

	local card_additive = {
		id = "xp_additive_card",
		amount = game_state_machine:current_state():card_bonus_xp()
	}

	table.insert(exp_table.additive, card_additive)

	if self._loot_redeemed_xp then
		local loot_redeemed = {
			id = "xp_additive_loot_redeemed",
			amount = self._loot_redeemed_xp
		}

		table.insert(exp_table.additive, loot_redeemed)
	end

	if not success then
		local event_fail_multiplicative = {
			id = "xp_multiplicative_event_fail",
			amount = tweak_data:get_value("experience_manager", "level_failed_multiplier") - 1
		}

		table.insert(exp_table.multiplicative, event_fail_multiplicative)
	end

	Application:trace("[RaidExperienceManager:calculate_exp_breakdown] This runs stored mission_xp events:", inspect(self._global.mission_xp))

	for _, event_id in ipairs(self._global.mission_xp) do
		if table.contains(RaidExperienceManager.SCRIPT_XP_EVENTS, event_id) then
			Application:trace("[RaidExperienceManager:calculate_exp_breakdown] Event ID is a SCRIPT_XP_EVENTS id", event_id)

			local event_id_data = tweak_data:get_value("experience_manager", event_id)

			if event_id_data then
				local event_loc_id = "xp_multiplicative_" .. event_id
				local event_amount = tweak_data.operations.missions[base_id][event_id] or event_id_data - 1

				if event_amount then
					local existing_event = false

					for i, existing_event_multi in ipairs(exp_table.multiplicative) do
						Application:trace("[RaidExperienceManager:calculate_exp_breakdown] Should modify? ", existing_event_multi.event_id, event_loc_id, existing_event_multi.event_id == event_loc_id)

						if existing_event_multi.id == event_loc_id then
							existing_event_multi.amount = existing_event_multi.amount + event_amount

							Application:trace("[RaidExperienceManager:calculate_exp_breakdown] Modified event multi", existing_event_multi.id, existing_event_multi.amount)

							existing_event = true

							break
						end
					end

					if not existing_event then
						local event_multi = {
							id = event_loc_id,
							amount = event_amount
						}

						table.insert(exp_table.multiplicative, event_multi)
						Application:trace("[RaidExperienceManager:calculate_exp_breakdown] Added event multi", event_loc_id, event_amount)
					end
				end
			else
				Application:trace("[RaidExperienceManager:calculate_exp_breakdown] Experience Manager does not have event id:", event_id)
			end
		end
	end

	local card_multiplicative = {
		id = "xp_multiplicative_card",
		amount = game_state_machine:current_state():card_xp_multiplier() - 1
	}

	table.insert(exp_table.multiplicative, card_multiplicative)

	local num_players_multiplicative = {
		id = "xp_multiplicative_num_players",
		amount = tweak_data:get_value("experience_manager", "human_player_multiplier", managers.criminals:get_num_player_criminals()) - 1
	}

	table.insert(exp_table.multiplicative, num_players_multiplicative)

	local difficulty_multiplicative = {
		id = "xp_multiplicative_difficulty",
		amount = tweak_data:get_value("experience_manager", "difficulty_multiplier", tweak_data:difficulty_to_index(game_state_machine._current_state._difficulty or Global.game_settings.difficulty)) - 1
	}

	table.insert(exp_table.multiplicative, difficulty_multiplicative)

	local level_difference_multiplicative = {
		id = "xp_multiplicative_level_difference",
		amount = math.lerp(1, tweak_data:get_value("experience_manager", "level_diff_max_multiplier"), self:player_level_difference() / (self:level_cap() - 1)) - 1
	}

	table.insert(exp_table.multiplicative, level_difference_multiplicative)

	return exp_table
end

function RaidExperienceManager:player_level_difference()
	local my_level = self:current_level()
	local min_level = my_level
	local max_level = my_level

	for _, peer in pairs(managers.network:session():peers()) do
		local level = peer:level()

		if level < min_level then
			min_level = level
		elseif max_level < level then
			max_level = level
		end
	end

	return max_level - min_level
end

function RaidExperienceManager:on_loot_drop_xp(value_id)
	local amount = tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0

	self:add_points(amount, false)
end

function RaidExperienceManager:add_points(points, is_debug)
	if not is_debug and managers.platform:presence() ~= "Playing" and managers.platform:presence() ~= "Mission_end" then
		return
	end

	if points <= 0 then
		return
	end

	if not managers.dlc:has_full_game() and self:current_level() >= 10 then
		self:_set_total(self:total() + points)
		self:_set_next_level_data_current_points(0)
		managers.statistics:aquired_money(points)

		return points
	end

	if self:level_cap() <= self:current_level() then
		self:_set_total(self:total() + points)

		return points
	end

	local points_left = self:next_level_data_points() - self:next_level_data_current_points()

	if points < points_left then
		self:_set_total(self:total() + points)
		self:_set_next_level_data_current_points(self:next_level_data_current_points() + points)

		return
	end

	self:_set_total(self:total() + points_left)
	self:_set_next_level_data_current_points(self:next_level_data_current_points() + points_left)
	self:_level_up()

	return self:add_points(points - points_left, is_debug)
end

function RaidExperienceManager:_level_up()
	self:_set_current_level(self:current_level() + 1)
	self:_set_next_level_data(self:current_level() + 1)

	local player = managers.player:player_unit()

	if player then
		player:base():replenish()
	end

	if managers.progression:operations_state() == ProgressionManager.OPERATIONS_STATE_LOCKED and tweak_data.operations.progression.operations_unlock_level <= self:current_level() then
		managers.progression:set_operations_state(ProgressionManager.OPERATIONS_STATE_PENDING)
	end

	managers.skilltree:apply_automatic_unlocks_for_level(self:current_level())
	managers.skilltree:create_breadcrumbs_for_level(self:current_level())

	if managers.achievment then
		managers.achievment:check_experience_achievements()
	end

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_character_level", self:current_level())
	end

	managers.hud:set_player_level(self:current_level())
end

function RaidExperienceManager:current_level()
	return self._global.level and Application:digest_value(self._global.level, false) or 0
end

function RaidExperienceManager:_set_current_level(value)
	local current_level = self:current_level()
	value = math.max(value, 0)
	self._global.level = Application:digest_value(value, true)

	self:update_progress()

	local max_level = self:level_cap()

	if current_level < max_level and value == max_level then
		managers.statistics:leveled_character_to_max()
	end
end

function RaidExperienceManager:total()
	return Application:digest_value(self._global.total, false)
end

function RaidExperienceManager:_set_total(value)
	self._global.total = Application:digest_value(value, true)
end

function RaidExperienceManager:experience_string(xp)
	local total = tostring(math.round(math.abs(xp)))
	local reverse = string.reverse(total)
	local s = ""

	for i = 1, string.len(reverse) do
		s = s .. string.sub(reverse, i, i) .. (math.mod(i, 3) == 0 and i ~= string.len(reverse) and RaidExperienceManager.THOUSAND_SEPARATOR or "")
	end

	return string.reverse(s)
end

function RaidExperienceManager:get_difficulty_multiplier(difficulty)
	local multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty)

	return multiplier or 0
end

function RaidExperienceManager:get_levels_gained_from_xp(xp)
	local next_level_data = self:next_level_data()
	local xp_needed_to_level = math.max(1, next_level_data.points - next_level_data.current_points)
	local level_gained = math.min(xp / xp_needed_to_level, 1)
	xp = math.max(xp - xp_needed_to_level, 0)
	local plvl = managers.experience:current_level() + 1
	local level_data = nil

	while xp > 0 and plvl < self._total_levels do
		plvl = plvl + 1
		xp_needed_to_level = tweak_data:get_value("experience_manager", "levels", plvl, "points")
		level_gained = level_gained + math.min(xp / xp_needed_to_level, 1)
		xp = math.max(xp - xp_needed_to_level, 0)
	end

	return level_gained
end

function RaidExperienceManager:level_cap()
	return Application:digest_value(self.LEVEL_CAP, false)
end

function RaidExperienceManager:reached_level_cap()
	return self:level_cap() <= self:current_level()
end

function RaidExperienceManager:get_total_xp_for_levels(level)
	local total_xp = 0

	for i_level = 1, level do
		total_xp = total_xp + tweak_data:get_value("experience_manager", "levels", i_level, "points")
	end

	return total_xp
end

function RaidExperienceManager:save(data)
	local state = {
		level = nil,
		total = nil,
		xp_gained = nil,
		version = nil,
		next_level_data = nil,
		version = self._global.version,
		total = self._global.total,
		xp_gained = self._global.xp_gained,
		next_level_data = self._global.next_level_data,
		level = self._global.level
	}
	data.RaidExperienceManager = state
end

function RaidExperienceManager:load(data)
	self:reset()

	local state = data.RaidExperienceManager

	if state then
		if not state.version or state.version and state.version ~= RaidExperienceManager.VERSION and self:xp_migration_needed(state.version) then
			Application:trace("[RaidExperienceManager:load] The save data and manager version are mismatched! Migrating...")

			local temp = {
				level = nil,
				max_level = nil,
				level = Application:digest_value(state.level, false),
				max_level = Application:digest_value(RaidExperienceManager.LEVEL_CAP, false)
			}
			self._global.version = RaidExperienceManager.VERSION
			self._global.level = state.level or Application:digest_value(1, true)
			local current_xp_ratio = Application:digest_value(state.next_level_data.current_points, false) / Application:digest_value(state.next_level_data.points, false)
			self._global.total = Application:digest_value(managers.experience:get_total_xp_for_level(temp.level) + Application:digest_value(tweak_data.experience_manager.levels[temp.level].points, false) * current_xp_ratio, true)
			self._global.xp_gained = state.xp_gained or state.total
			local next_level = temp.level + 1

			if temp.max_level < next_level then
				next_level = temp.max_level
			end

			self._global.next_level_data = {
				current_points = nil,
				points = nil,
				points = tweak_data.experience_manager.levels[next_level].points,
				current_points = Application:digest_value(Application:digest_value(tweak_data.experience_manager.levels[next_level].points, false) * current_xp_ratio, true)
			}
		else
			self._global.version = state.version
			self._global.total = state.total
			self._global.xp_gained = state.xp_gained or state.total
			self._global.next_level_data = state.next_level_data
			self._global.level = state.level or Application:digest_value(1, true)

			self:_set_current_level(math.min(self:current_level(), self:level_cap()))

			if not self._global.next_level_data or not tweak_data.experience_manager.levels[self:current_level() + 1] or self:next_level_data_points() ~= tweak_data:get_value("experience_manager", "levels", self:current_level() + 1, "points") then
				self:_set_next_level_data(self:current_level() + 1)
			end
		end
	end

	managers.network.account:experience_loaded()
end

function RaidExperienceManager:reset()
	managers.upgrades:reset()
	managers.player:reset()

	Global.experience_manager = nil

	self:_setup()
	self:update_progress()
end

function RaidExperienceManager:update_progress()
	managers.platform:set_progress(math.clamp(self:current_level() / self:level_cap(), 0, 1))
end

function RaidExperienceManager:chk_ask_use_backup(savegame_data, backup_savegame_data)
	local savegame_exp_total, backup_savegame_exp_total = nil
	local state = savegame_data.RaidExperienceManager

	if state then
		savegame_exp_total = state.total
	end

	state = backup_savegame_data.RaidExperienceManager

	if state then
		backup_savegame_exp_total = state.total
	end

	if savegame_exp_total and backup_savegame_exp_total and Application:digest_value(savegame_exp_total, false) < Application:digest_value(backup_savegame_exp_total, false) then
		return true
	end
end
