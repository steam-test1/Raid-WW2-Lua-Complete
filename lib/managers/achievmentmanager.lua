AchievmentManager = AchievmentManager or class()
AchievmentManager.PATH = "gamedata/achievments"
AchievmentManager.FILE_EXTENSION = "achievment"

function AchievmentManager:init()
	self.exp_awards = {
		c = 5000,
		b = 1500,
		a = 500,
		none = 0
	}

	if IS_PC then
		if IS_STEAM then
			AchievmentManager.do_award = AchievmentManager.award_steam

			if not Global.achievment_manager then
				self:_parse_achievments("Steam")

				self.handler = Steam:sa_handler()

				self.handler:initialized_callback(AchievmentManager.fetch_achievments)
				self.handler:init()

				Global.achievment_manager = {
					handler = self.handler,
					achievments = self.achievments
				}
			else
				self.handler = Global.achievment_manager.handler
				self.achievments = Global.achievment_manager.achievments
			end
		else
			AchievmentManager.do_award = AchievmentManager.award_none

			self:_parse_achievments()

			if not Global.achievment_manager then
				Global.achievment_manager = {
					achievments = self.achievments
				}
			end

			self.achievments = Global.achievment_manager.achievments
		end
	elseif IS_PS4 then
		if not Global.achievment_manager then
			self:_parse_achievments("PS4")

			Global.achievment_manager = {
				trophy_requests = {},
				achievments = self.achievments
			}
		else
			self.achievments = Global.achievment_manager.achievments
		end

		AchievmentManager.do_award = AchievmentManager.award_psn
	elseif IS_XB1 then
		if not Global.achievment_manager then
			self:_parse_achievments("XB1")

			Global.achievment_manager = {
				achievments = self.achievments
			}
		else
			self.achievments = Global.achievment_manager.achievments
		end

		AchievmentManager.do_award = AchievmentManager.award_xblive
	else
		Application:error("[AchievmentManager:init] Unsupported platform")
	end
end

function AchievmentManager:init_finalize()
	managers.savefile:add_load_sequence_done_callback_handler(callback(self, self, "_load_done"))
end

function AchievmentManager:fetch_trophies()
	if IS_PS4 then
		Trophies:get_unlockstate(AchievmentManager.unlockstate_result)
	end
end

function AchievmentManager.unlockstate_result(error_str, table)
	if table then
		for i, data in ipairs(table) do
			local psn_id = data.index
			local unlocked = data.unlocked

			if unlocked then
				for id, ach in pairs(managers.achievment.achievments) do
					if ach.id == psn_id then
						ach.awarded = true
					end
				end
			end
		end
	end

	managers.network.account:achievements_fetched()
end

function AchievmentManager.fetch_achievments(error_str)
	if error_str == "success" then
		for id, ach in pairs(managers.achievment.achievments) do
			if managers.achievment.handler:has_achievement(ach.id) then
				ach.awarded = true
			end
		end
	end

	managers.network.account:achievements_fetched()
end

function AchievmentManager:_load_done()
	if IS_XB1 then
		print("[AchievmentManager] _load_done()")

		self._is_fetching_achievments = XboxLive:achievements(managers.user:get_xuid(0), 99, false, callback(self, self, "_achievments_loaded"))
	end
end

function AchievmentManager:_achievments_loaded(achievment_list)
	print("[AchievmentManager] Achievment loaded: " .. tostring(achievment_list and #achievment_list))

	if not self._is_fetching_achievments then
		print("[AchievmentManager] Achievment loading aborted.")

		return
	end

	for _, achievment in ipairs(achievment_list) do
		if achievment.type == "achieved" then
			for _, achievment2 in pairs(managers.achievment.achievments) do
				if achievment.id == tostring(achievment2.id) then
					print("[AchievmentManager] Awarded by load: " .. tostring(achievment.id))

					achievment2.awarded = true

					break
				end
			end
		end
	end
end

function AchievmentManager:on_user_signout()
	if IS_XB1 then
		print("[AchievmentManager] on_user_signout()")

		self._is_fetching_achievments = nil

		for id, ach in pairs(managers.achievment.achievments) do
			ach.awarded = false
		end
	end
end

function AchievmentManager:_parse_achievments(platform)
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())
	self.achievments = {}

	for _, ach in ipairs(list) do
		if ach._meta == "achievment" then
			for _, reward in ipairs(ach) do
				if reward._meta == "reward" and (Application:editor() or not platform or platform == reward.platform) then
					self.achievments[ach.id] = {
						awarded = false,
						id = reward.id,
						name = ach.name,
						exp = self.exp_awards[ach.awards_exp],
						dlc_loot = reward.dlc_loot or false
					}
				end
			end
		end
	end
end

function AchievmentManager:exists(id)
	return self.achievments[id] ~= nil
end

function AchievmentManager:get_info(id)
	return self.achievments[id]
end

function AchievmentManager:total_amount()
	return table.size(self.achievments)
end

function AchievmentManager:total_unlocked()
	local i = 0

	for _, ach in pairs(self.achievments) do
		if ach.awarded then
			i = i + 1
		end
	end

	return i
end

function AchievmentManager:award(id)
	Application:debug("[AchievmentManager:award] Awarding achievement", "id", id)

	if not self:exists(id) then
		Application:debug("[AchievmentManager:award] Awarding non-existing achievement", "id", id)

		return
	end

	if self:get_info(id).awarded then
		Application:debug("[AchievmentManager:award] Awarding already awarded achievement", "id", id)

		return
	end

	self:do_award(id)
end

function AchievmentManager:_give_reward(id)
	local data = self:get_info(id)
	data.awarded = true

	if data.dlc_loot then
		managers.dlc:on_achievement_award_loot()
	end
end

function AchievmentManager:award_progress(stat, value)
	if Application:editor() then
		return
	end

	if IS_PC then
		self.handler:achievement_store_callback(AchievmentManager.steam_unlock_result)
	end

	local stats = {
		[stat] = {
			type = "int",
			value = value or 1
		}
	}

	managers.network.account:publish_statistics(stats, true)
end

function AchievmentManager:get_stat(stat)
	if IS_PC then
		return managers.network.account:get_stat(stat)
	end

	return false
end

function AchievmentManager:award_none(id)
	Application:debug("[AchievmentManager:award_none] Awarded achievment", id)
end

function AchievmentManager:award_steam(id)
	if not self.handler:initialized() then
		Application:error("[AchievmentManager:award_steam] Achievements are not initialized. Cannot award achievment:", id)

		return
	end

	self.handler:achievement_store_callback(AchievmentManager.steam_unlock_result)
	self.handler:set_achievement(self:get_info(id).id)
	self.handler:store_data()
end

function AchievmentManager:clear_steam(id)
	if not self.handler:initialized() then
		Application:error("[AchievmentManager:clear_steam] Achievements are not initialized. Cannot clear achievment:", id)

		return
	end

	self.handler:clear_achievement(self:get_info(id).id)
	self.handler:store_data()
end

function AchievmentManager:reset_achievements()
	managers.achievment:clear_all_steam()

	Global.achievment_manager = nil

	managers.achievment:init()
	managers.savefile:save_setting()
end

function AchievmentManager:clear_all_steam()
	print("[AchievmentManager:clear_all_steam]")

	if not self.handler:initialized() then
		print("[AchievmentManager:clear_steam] Achievments are not initialized. Cannot clear steam:")

		return
	end

	local result = self.handler:clear_all_stats(true)

	self.handler:store_data()
end

function AchievmentManager.steam_unlock_result(achievment)
	for id, ach in pairs(managers.achievment.achievments) do
		if ach.id == achievment then
			managers.achievment:_give_reward(id)

			return
		end
	end
end

function AchievmentManager:award_xblive(id)
	print("[AchievmentManager:award_xblive] Awarded Xbox Live achievment", id)

	local function xblive_unlock_result(result)
		print("result", result)

		if result then
			managers.achievment:_give_reward(id)
		end
	end

	XboxLive:award_achievement(managers.user:get_platform_id(), self:get_info(id).id, xblive_unlock_result)
end

function AchievmentManager:award_psn(id)
	print("[AchievmentManager:award] Awarded PSN achievment", id, self:get_info(id).id)

	if not self._trophies_installed then
		print("[AchievmentManager:award] Trophies are not installed. Cannot award trophy:", id)

		return
	end

	local request = Trophies:unlock_id(self:get_info(id).id, AchievmentManager.psn_unlock_result)
	Global.achievment_manager.trophy_requests[request] = id
end

function AchievmentManager.psn_unlock_result(request, error_str)
	print("[AchievmentManager:psn_unlock_result] Awarded PSN achievment", request, error_str)

	local id = Global.achievment_manager.trophy_requests[request]

	if error_str == "success" then
		Global.achievment_manager.trophy_requests[request] = nil

		managers.achievment:_give_reward(id)
	end
end

function AchievmentManager:chk_install_trophies()
	if Trophies:is_installed() then
		print("[AchievmentManager:chk_install_trophies] Already installed")

		self._trophies_installed = true

		Trophies:get_unlockstate(self.unlockstate_result)
		self:fetch_trophies()
	elseif managers.dlc:has_full_game() then
		print("[AchievmentManager:chk_install_trophies] Installing")
		Trophies:install(callback(self, self, "clbk_install_trophies"))
	end
end

function AchievmentManager:clbk_install_trophies(result)
	print("[AchievmentManager:clbk_install_trophies]", result)

	if result then
		self._trophies_installed = true

		self:fetch_trophies()
	end
end

function AchievmentManager:check_achievement_complete_raid_with_4_different_classes()
	local peers = managers.network:session():all_peers()

	if peers and #peers == 4 then
		local classes = {}

		for _, peer in ipairs(peers) do
			local class = peer:class()

			if not class or classes[class] then
				return
			end

			classes[class] = true
		end

		managers.achievment:award("ach_every_player_different_class")
	end
end

function AchievmentManager:check_achievement_complete_raid_with_no_kills()
	if managers.statistics._global.session.killed.total.count == 0 then
		managers.achievment:award("ach_complete_raid_with_no_kills")
	end
end

function AchievmentManager:check_achievement_kill_30_enemies_with_vehicle_on_bank_level()
	local is_bank_level = false
	local current_job = managers.raid_job:current_job()
	local bank_level_name = "gold_rush"

	if current_job then
		if current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
			is_bank_level = current_job.job_id == bank_level_name
		elseif current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
			local current_job_event_index = current_job.current_event
			is_bank_level = current_job.events_index[current_job_event_index] == bank_level_name
		end

		if managers.statistics._global.session.killed_by_vehicle.count >= 30 and is_bank_level then
			managers.achievment:award("Treasury - Bumpy ride")
		end
	end
end

function AchievmentManager:on_level_loaded_callback()
	if not managers.raid_job:is_camp_loaded() then
		return
	end

	if managers.raid_job:current_job() then
		return
	end

	self:check_experience_achievements()
	self:check_achievement_mission_award()
end

function AchievmentManager:check_achievement_mission_award()
	for job_id, data in pairs(tweak_data.achievement.missions) do
		self:check_mission_achievements(job_id)
	end
end

function AchievmentManager:check_mission_achievements(job_id, mission_data)
	if not tweak_data.operations.missions[job_id] then
		return
	end

	if not tweak_data.achievement.missions[job_id] then
		return
	end

	Application:info("[AchievmentManager:check_mission_achievements]", job_id, mission_data and inspect(mission_data))

	local job_data = managers.raid_job:current_job() or tweak_data.operations.missions[job_id]
	local job_achievements = tweak_data.achievement.missions[job_id]
	local job_type = job_data.job_type
	local _, difficulty_completed = managers.progression:get_mission_progression(job_type, job_id)

	if mission_data then
		difficulty_completed = mission_data.difficulty or difficulty_completed
	end

	if not difficulty_completed then
		return
	end

	local stealthed = mission_data and mission_data.stealthed
	local dogtags_collected = mission_data and mission_data.dogtags_collected
	local peers_connected = mission_data and mission_data.peers_connected or 1
	local no_bleedout = mission_data and mission_data.no_bleedout or false

	for _, data in ipairs(job_achievements) do
		local achieved = difficulty_completed >= (data.difficulty or 1)

		if achieved and data.all_dogtags then
			achieved = dogtags_collected
		end

		if achieved and data.num_peers then
			achieved = data.num_peers <= peers_connected
		end

		if achieved and data.no_bleedout then
			achieved = no_bleedout
		end

		if achieved and data.stealth then
			achieved = stealthed
		end

		if achieved then
			self:award(data.id)
		end
	end
end

function AchievmentManager:check_experience_achievements()
	local achievements = tweak_data.achievement.experience
	local highest_level = 0

	for i = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
		local save_data = Global.savefile_manager.meta_data_list[i]

		if save_data and save_data.is_cached_slot and save_data.cache and save_data.cache.RaidExperienceManager then
			local digest_level = save_data.cache.RaidExperienceManager.level
			local character_level = Application:digest_value(digest_level, false) or 0
			highest_level = math.max(character_level, highest_level)
		end
	end

	for _, data in ipairs(achievements) do
		if data.level <= highest_level then
			managers.achievment:award(data.id)
		end
	end
end
