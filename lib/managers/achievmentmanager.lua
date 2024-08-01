AchievmentManager = AchievmentManager or class()
AchievmentManager.PATH = "gamedata/achievments"
AchievmentManager.FILE_EXTENSION = "achievment"

-- Lines 17-72
function AchievmentManager:init()
	self.exp_awards = {
		b = 1500,
		a = 500,
		c = 5000,
		none = 0
	}
	self.script_data = {}

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

-- Lines 74-76
function AchievmentManager:init_finalize()
	managers.savefile:add_load_sequence_done_callback_handler(callback(self, self, "_load_done"))
end

-- Lines 78-82
function AchievmentManager:fetch_trophies()
	if IS_PS4 then
		Trophies:get_unlockstate(AchievmentManager.unlockstate_result)
	end
end

-- Lines 85-102
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

-- Lines 105-115
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

-- Lines 117-125
function AchievmentManager:_load_done()
	if IS_XB1 then
		print("[AchievmentManager] _load_done()")

		self._is_fetching_achievments = XboxLive:achievements(managers.user:get_xuid(0), 99, false, callback(self, self, "_achievments_loaded"))
	end
end

-- Lines 127-146
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

-- Lines 148-157
function AchievmentManager:on_user_signout()
	if IS_XB1 then
		print("[AchievmentManager] on_user_signout()")

		self._is_fetching_achievments = nil

		for id, ach in pairs(managers.achievment.achievments) do
			ach.awarded = false
		end
	end
end

-- Lines 161-174
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

-- Lines 178-180
function AchievmentManager:get_script_data(id)
	return self.script_data[id]
end

-- Lines 182-184
function AchievmentManager:set_script_data(id, data)
	self.script_data[id] = data
end

-- Lines 188-190
function AchievmentManager:exists(id)
	return self.achievments[id] ~= nil
end

-- Lines 192-194
function AchievmentManager:get_info(id)
	return self.achievments[id]
end

-- Lines 196-198
function AchievmentManager:total_amount()
	return table.size(self.achievments)
end

-- Lines 200-208
function AchievmentManager:total_unlocked()
	local i = 0

	for _, ach in pairs(self.achievments) do
		if ach.awarded then
			i = i + 1
		end
	end

	return i
end

-- Lines 212-225
function AchievmentManager:award(id)
	Application:debug("[AchievmentManager:award] Awarding achievement", "id", id)

	if not self:exists(id) then
		Application:debug("[AchievmentManager:award] Awarding non-existing achievement", "id", id)

		return
	end

	if self:get_info(id).awarded then
		return
	end

	self:do_award(id)
end

-- Lines 228-236
function AchievmentManager:_give_reward(id)
	local data = self:get_info(id)
	data.awarded = true

	if data.dlc_loot then
		managers.dlc:on_achievement_award_loot()
	end
end

-- Lines 239-252
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

-- Lines 256-261
function AchievmentManager:get_stat(stat)
	if IS_PC then
		return managers.network.account:get_stat(stat)
	end

	return false
end

-- Lines 265-267
function AchievmentManager:award_none(id)
	Application:debug("[AchievmentManager:award_none] Awarded achievment", id)
end

-- Lines 271-280
function AchievmentManager:award_steam(id)
	if not self.handler:initialized() then
		Application:error("[AchievmentManager:award_steam] Achievements are not initialized. Cannot award achievment:", id)

		return
	end

	self.handler:achievement_store_callback(AchievmentManager.steam_unlock_result)
	self.handler:set_achievement(self:get_info(id).id)
	self.handler:store_data()
end

-- Lines 284-292
function AchievmentManager:clear_steam(id)
	if not self.handler:initialized() then
		Application:error("[AchievmentManager:clear_steam] Achievements are not initialized. Cannot clear achievment:", id)

		return
	end

	self.handler:clear_achievement(self:get_info(id).id)
	self.handler:store_data()
end

-- Lines 296-303
function AchievmentManager:reset_achievements()
	managers.achievment:clear_all_steam()

	Global.achievment_manager = nil

	managers.achievment:init()
	managers.savefile:save_setting()
end

-- Lines 305-315
function AchievmentManager:clear_all_steam()
	print("[AchievmentManager:clear_all_steam]")

	if not self.handler:initialized() then
		print("[AchievmentManager:clear_steam] Achievments are not initialized. Cannot clear steam:")

		return
	end

	local result = self.handler:clear_all_stats(true)

	self.handler:store_data()
end

-- Lines 319-326
function AchievmentManager.steam_unlock_result(achievment)
	for id, ach in pairs(managers.achievment.achievments) do
		if ach.id == achievment then
			managers.achievment:_give_reward(id)

			return
		end
	end
end

-- Lines 329-345
function AchievmentManager:award_xblive(id)
	print("[AchievmentManager:award_xblive] Awarded Xbox Live achievment", id)

	-- Lines 337-342
	local function xblive_unlock_result(result)
		print("result", result)

		if result then
			managers.achievment:_give_reward(id)
		end
	end

	XboxLive:award_achievement(managers.user:get_platform_id(), self:get_info(id).id, xblive_unlock_result)
end

-- Lines 349-360
function AchievmentManager:award_psn(id)
	print("[AchievmentManager:award] Awarded PSN achievment", id, self:get_info(id).id)

	if not self._trophies_installed then
		print("[AchievmentManager:award] Trophies are not installed. Cannot award trophy:", id)

		return
	end

	local request = Trophies:unlock_id(self:get_info(id).id, AchievmentManager.psn_unlock_result)
	Global.achievment_manager.trophy_requests[request] = id
end

-- Lines 362-370
function AchievmentManager.psn_unlock_result(request, error_str)
	print("[AchievmentManager:psn_unlock_result] Awarded PSN achievment", request, error_str)

	local id = Global.achievment_manager.trophy_requests[request]

	if error_str == "success" then
		Global.achievment_manager.trophy_requests[request] = nil

		managers.achievment:_give_reward(id)
	end
end

-- Lines 374-384
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

-- Lines 388-394
function AchievmentManager:clbk_install_trophies(result)
	print("[AchievmentManager:clbk_install_trophies]", result)

	if result then
		self._trophies_installed = true

		self:fetch_trophies()
	end
end

-- Lines 399-427
function AchievmentManager:check_achievement_complete_raid_with_4_different_classes()
	local peers = managers.network:session():all_peers()

	if peers and #peers == 4 then
		local classes = {}

		for peer_id, peer in ipairs(peers) do
			local peer_outfit = peer:blackmarket_outfit()

			if peer_outfit and peer_outfit.skills then
				if classes[peer_outfit.skills] then
					return false
				end

				classes[peer_outfit.skills] = true
			else
				return false
			end
		end

		managers.achievment:award("ach_every_player_different_class")
	end
end

-- Lines 430-434
function AchievmentManager:check_achievement_complete_raid_with_no_kills()
	if managers.statistics._global.session.killed.total.count == 0 then
		managers.achievment:award("ach_complete_raid_with_no_kills")
	end
end

-- Lines 436-452
function AchievmentManager:check_achievement_kill_30_enemies_with_vehicle_on_bank_level()
	local is_bank_level = false
	local current_job = managers.raid_job:current_job()
	local bank_level_name = "gold_rush"

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

AchievmentManager._T = {
	clear_skies = {
		hardest = "ach_clear_skies_hardest",
		nobleed = "ach_clear_skies_no_bleedout",
		hardest_nobleed = "ach_clear_skies_hardest_no_bleedout"
	},
	oper_flamable = {
		hardest = "ach_burn_hardest",
		nobleed = "ach_burn_no_bleedout",
		hardest_nobleed = "ach_burn_hardest_no_bleedout"
	}
}

-- Lines 473-519
function AchievmentManager:check_achievement_operation(operation_save_data)
	local job_achi_data = AchievmentManager._T[operation_save_data.current_job.job_id]

	if not job_achi_data then
		return
	end

	local is_hardest_difficulty = operation_save_data.difficulty_id == tweak_data.hardest_difficulty.id

	if is_hardest_difficulty and job_achi_data.hardest then
		managers.achievment:award(job_achi_data.hardest)
	end

	if managers.network:session():count_all_peers() >= 2 and (job_achi_data.nobleed or job_achi_data.hardest_nobleed) then
		local total_downed_count = 0

		for events_index_index, events_index_level_name in ipairs(operation_save_data.events_index) do
			local event_data = operation_save_data.event_data[events_index_index]

			Application:debug("[AchievmentManager:check_achievement_operation] NOBLEED Check event data:", inspect(event_data))

			if event_data and event_data.peer_data then
				for peer_index, peer_data in pairs(event_data.peer_data) do
					if peer_data.statistics ~= nil then
						total_downed_count = total_downed_count + (peer_data.statistics.downs or 0)
					end
				end
			end
		end

		if total_downed_count <= 0 then
			if job_achi_data.nobleed then
				managers.achievment:award(job_achi_data.nobleed)
			end

			if is_hardest_difficulty and job_achi_data.hardest_nobleed then
				managers.achievment:award(job_achi_data.hardest_nobleed)
			end
		end
	end
end

-- Lines 523-539
function AchievmentManager:check_achievement_group_bring_them_home(current_job_data)
	if current_job_data and current_job_data.job_type and current_job_data.job_type == OperationsTweakData.JOB_TYPE_RAID then
		if current_job_data.job_id == "flakturm" then
			managers.achievment:award("ach_bring_them_home_flak")
		elseif current_job_data.job_id == "ger_bridge" then
			managers.achievment:award("ach_bring_them_home_bridge")
		elseif current_job_data.job_id == "train_yard" then
			managers.achievment:award("ach_bring_them_home_trainyard")
		elseif current_job_data.job_id == "gold_rush" then
			managers.achievment:award("ach_bring_them_home_bank")
		elseif current_job_data.job_id == "settlement" then
			managers.achievment:award("ach_bring_them_home_castle")
		elseif current_job_data.job_id == "radio_defense" then
			managers.achievment:award("ach_bring_them_home_radiodefence")
		end
	end
end
