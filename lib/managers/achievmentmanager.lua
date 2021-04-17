AchievmentManager = AchievmentManager or class()
AchievmentManager.PATH = "gamedata/achievments"
AchievmentManager.FILE_EXTENSION = "achievment"

-- Lines 7-70
function AchievmentManager:init()
	self.exp_awards = {
		b = 1500,
		a = 500,
		c = 5000,
		none = 0
	}
	self.script_data = {}

	if SystemInfo:platform() == Idstring("WIN32") then
		if SystemInfo:distribution() == Idstring("STEAM") then
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
	elseif SystemInfo:platform() == Idstring("PS3") then
		if not Global.achievment_manager then
			Global.achievment_manager = {
				trophy_requests = {}
			}
		end

		self:_parse_achievments("PSN")

		AchievmentManager.do_award = AchievmentManager.award_psn
	elseif SystemInfo:platform() == Idstring("PS4") then
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
	elseif SystemInfo:platform() == Idstring("X360") then
		self:_parse_achievments("X360")

		AchievmentManager.do_award = AchievmentManager.award_x360
	elseif SystemInfo:platform() == Idstring("XB1") then
		if not Global.achievment_manager then
			self:_parse_achievments("XB1")

			Global.achievment_manager = {
				achievments = self.achievments
			}
		else
			self.achievments = Global.achievment_manager.achievments
		end

		AchievmentManager.do_award = AchievmentManager.award_x360
	else
		Application:error("[AchievmentManager:init] Unsupported platform")
	end
end

-- Lines 72-74
function AchievmentManager:init_finalize()
	managers.savefile:add_load_sequence_done_callback_handler(callback(self, self, "_load_done"))
end

-- Lines 76-80
function AchievmentManager:fetch_trophies()
	if SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4") then
		Trophies:get_unlockstate(AchievmentManager.unlockstate_result)
	end
end

-- Lines 83-100
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

-- Lines 103-113
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

-- Lines 115-120
function AchievmentManager:_load_done()
	if SystemInfo:platform() == Idstring("XB1") then
		print("[AchievmentManager] _load_done()")

		self._is_fetching_achievments = XboxLive:achievements(0, 1000, true, callback(self, self, "_achievments_loaded"))
	end
end

-- Lines 122-141
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

-- Lines 143-152
function AchievmentManager:on_user_signout()
	if SystemInfo:platform() == Idstring("XB1") then
		print("[AchievmentManager] on_user_signout()")

		self._is_fetching_achievments = nil

		for id, ach in pairs(managers.achievment.achievments) do
			ach.awarded = false
		end
	end
end

-- Lines 156-169
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

-- Lines 173-175
function AchievmentManager:get_script_data(id)
	return self.script_data[id]
end

-- Lines 177-179
function AchievmentManager:set_script_data(id, data)
	self.script_data[id] = data
end

-- Lines 183-185
function AchievmentManager:exists(id)
	return self.achievments[id] ~= nil
end

-- Lines 187-189
function AchievmentManager:get_info(id)
	return self.achievments[id]
end

-- Lines 191-193
function AchievmentManager:total_amount()
	return table.size(self.achievments)
end

-- Lines 195-203
function AchievmentManager:total_unlocked()
	local i = 0

	for _, ach in pairs(self.achievments) do
		if ach.awarded then
			i = i + 1
		end
	end

	return i
end

-- Lines 207-228
function AchievmentManager:award(id)
	Application:debug("[AchievmentManager:award] Awarding achievement", "id", id)

	if not self:exists(id) then
		Application:debug("[AchievmentManager:award] Awarding non-existing achievement", "id", id)

		return
	end

	if self:get_info(id).awarded then
		return
	end

	if id == "christmas_present" then
		managers.network.account._masks.santa = true
	elseif id == "golden_boy" then
		managers.network.account._masks.gold = true
	end

	self:do_award(id)
end

-- Lines 231-239
function AchievmentManager:_give_reward(id)
	local data = self:get_info(id)
	data.awarded = true

	if data.dlc_loot then
		managers.dlc:on_achievement_award_loot()
	end
end

-- Lines 242-255
function AchievmentManager:award_progress(stat, value)
	if Application:editor() then
		return
	end

	if SystemInfo:platform() == Idstring("WIN32") then
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

-- Lines 259-264
function AchievmentManager:get_stat(stat)
	if SystemInfo:platform() == Idstring("WIN32") then
		return managers.network.account:get_stat(stat)
	end

	return false
end

-- Lines 268-270
function AchievmentManager:award_none(id)
	Application:debug("[AchievmentManager:award_none] Awarded achievment", id)
end

-- Lines 274-283
function AchievmentManager:award_steam(id)
	if not self.handler:initialized() then
		Application:error("[AchievmentManager:award_steam] Achievements are not initialized. Cannot award achievment:", id)

		return
	end

	self.handler:achievement_store_callback(AchievmentManager.steam_unlock_result)
	self.handler:set_achievement(self:get_info(id).id)
	self.handler:store_data()
end

-- Lines 287-295
function AchievmentManager:clear_steam(id)
	if not self.handler:initialized() then
		Application:error("[AchievmentManager:clear_steam] Achievements are not initialized. Cannot clear achievment:", id)

		return
	end

	self.handler:clear_achievement(self:get_info(id).id)
	self.handler:store_data()
end

-- Lines 299-306
function AchievmentManager:reset_achievements()
	managers.achievment:clear_all_steam()

	Global.achievment_manager = nil

	managers.achievment:init()
	managers.savefile:save_setting()
end

-- Lines 308-318
function AchievmentManager:clear_all_steam()
	print("[AchievmentManager:clear_all_steam]")

	if not self.handler:initialized() then
		print("[AchievmentManager:clear_steam] Achievments are not initialized. Cannot clear steam:")

		return
	end

	local result = self.handler:clear_all_stats(true)

	self.handler:store_data()
end

-- Lines 322-329
function AchievmentManager.steam_unlock_result(achievment)
	for id, ach in pairs(managers.achievment.achievments) do
		if ach.id == achievment then
			managers.achievment:_give_reward(id)

			return
		end
	end
end

-- Lines 332-348
function AchievmentManager:award_x360(id)
	print("[AchievmentManager:award_x360] Awarded X360 achievment", id)

	-- Lines 340-345
	local function x360_unlock_result(result)
		print("result", result)

		if result then
			managers.achievment:_give_reward(id)
		end
	end

	XboxLive:award_achievement(managers.user:get_platform_id(), self:get_info(id).id, x360_unlock_result)
end

-- Lines 352-363
function AchievmentManager:award_psn(id)
	print("[AchievmentManager:award] Awarded PSN achievment", id, self:get_info(id).id)

	if not self._trophies_installed then
		print("[AchievmentManager:award] Trophies are not installed. Cannot award trophy:", id)

		return
	end

	local request = Trophies:unlock_id(self:get_info(id).id, AchievmentManager.psn_unlock_result)
	Global.achievment_manager.trophy_requests[request] = id
end

-- Lines 365-373
function AchievmentManager.psn_unlock_result(request, error_str)
	print("[AchievmentManager:psn_unlock_result] Awarded PSN achievment", request, error_str)

	local id = Global.achievment_manager.trophy_requests[request]

	if error_str == "success" then
		Global.achievment_manager.trophy_requests[request] = nil

		managers.achievment:_give_reward(id)
	end
end

-- Lines 377-387
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

-- Lines 391-397
function AchievmentManager:clbk_install_trophies(result)
	print("[AchievmentManager:clbk_install_trophies]", result)

	if result then
		self._trophies_installed = true

		self:fetch_trophies()
	end
end

-- Lines 402-430
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

-- Lines 433-437
function AchievmentManager:check_achievement_complete_raid_with_no_kills()
	if managers.statistics._global.session.killed.total.count == 0 then
		managers.achievment:award("ach_complete_raid_with_no_kills")
	end
end

-- Lines 439-455
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

-- Lines 459-466
function AchievmentManager:check_achievement_operation_clear_sky_hardest(operation_save_data)
	if Network:is_server() and operation_save_data.difficulty_id == tweak_data.hardest_difficulty.id and operation_save_data.current_job.job_id == "clear_skies" then
		managers.achievment:award("ach_clear_skies_hardest")
		managers.network:session():send_to_peers("sync_award_achievement", "ach_clear_skies_hardest")
	end
end

-- Lines 468-492
function AchievmentManager:check_achievement_operation_clear_sky_no_bleedout(operation_save_data)
	if Network:is_server() and managers.network:session():count_all_peers() == 4 then
		local total_downed_count = 0

		if operation_save_data.current_job.job_id == "clear_skies" then
			for events_index_index, events_index_level_name in ipairs(operation_save_data.events_index) do
				local event_data = operation_save_data.event_data[events_index_index]

				for peer_index, peer_data in pairs(event_data.peer_data) do
					total_downed_count = total_downed_count + (peer_data.statistics.downs or 0)
				end
			end

			if total_downed_count <= 0 then
				managers.achievment:award("ach_clear_skies_no_bleedout")
				managers.network:session():send_to_peers("sync_award_achievement", "ach_clear_skies_no_bleedout")

				if operation_save_data.difficulty_id == tweak_data.hardest_difficulty.id then
					managers.achievment:award("ach_clear_skies_hardest_no_bleedout")
					managers.network:session():send_to_peers("sync_award_achievement", "ach_clear_skies_hardest_no_bleedout")
				end
			end
		end
	end
end

-- Lines 494-501
function AchievmentManager:check_achievement_operation_burn_hardest(operation_save_data)
	if Network:is_server() and operation_save_data.difficulty_id == tweak_data.hardest_difficulty.id and operation_save_data.current_job.job_id == "oper_flamable" then
		managers.achievment:award("ach_burn_hardest")
		managers.network:session():send_to_peers("sync_award_achievement", "ach_burn_hardest")
	end
end

-- Lines 503-527
function AchievmentManager:check_achievement_operation_burn_no_bleedout(operation_save_data)
	if Network:is_server() and managers.network:session():count_all_peers() == 4 then
		local total_downed_count = 0

		if operation_save_data.current_job.job_id == "oper_flamable" then
			for events_index_index, events_index_level_name in ipairs(operation_save_data.events_index) do
				local event_data = operation_save_data.event_data[events_index_index]

				for peer_index, peer_data in pairs(event_data.peer_data) do
					total_downed_count = total_downed_count + (peer_data.statistics.downs or 0)
				end
			end

			if total_downed_count <= 0 then
				managers.achievment:award("ach_burn_no_bleedout")
				managers.network:session():send_to_peers("sync_award_achievement", "ach_burn_no_bleedout")

				if operation_save_data.difficulty_id == tweak_data.hardest_difficulty.id then
					managers.achievment:award("ach_burn_hardest_no_bleedout")
					managers.network:session():send_to_peers("sync_award_achievement", "ach_burn_hardest_no_bleedout")
				end
			end
		end
	end
end

-- Lines 531-548
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
