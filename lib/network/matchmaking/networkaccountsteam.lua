require("lib/network/matchmaking/NetworkAccount")

NetworkAccountSTEAM = NetworkAccountSTEAM or class(NetworkAccount)
NetworkAccountSTEAM.lb_diffs = {
	hard = "Hard",
	overkill = "Very Hard",
	overkill_145 = "Overkill",
	normal = "Normal",
	overkill_290 = "Death Wish",
	easy = "Easy"
}
NetworkAccountSTEAM.lb_levels = {
	slaughter_house = "Slaughterhouse",
	diamond_heist = "Diamond Heist",
	hospital = "No Mercy",
	suburbia = "Counterfeit",
	bridge = "Green Bridge",
	secret_stash = "Undercover",
	apartment = "Panic Room",
	bank = "First World Bank",
	heat_street = "Heat Street"
}

-- Lines 30-63
function NetworkAccountSTEAM:init()
	NetworkAccount.init(self)

	self._listener_holder = EventListenerHolder:new()

	Steam:init()
	Steam:request_listener(NetworkAccountSTEAM._on_join_request, NetworkAccountSTEAM._on_server_request)
	Steam:error_listener(NetworkAccountSTEAM._on_disconnected, NetworkAccountSTEAM._on_ipc_fail, NetworkAccountSTEAM._on_connect_fail)
	Steam:overlay_listener(callback(self, self, "_on_open_overlay"), callback(self, self, "_on_close_overlay"))

	self._gamepad_text_listeners = {}

	if Steam:overlay_open() then
		self:_on_open_overlay()
	end

	Steam:sa_handler():stats_store_callback(NetworkAccountSTEAM._on_stats_stored)
	Steam:sa_handler():init()
	self:_set_presences()
	managers.savefile:add_load_done_callback(callback(self, self, "_load_done"))
	Steam:lb_handler():register_storage_done_callback(NetworkAccountSTEAM._on_leaderboard_stored)
	Steam:lb_handler():register_mappings_done_callback(NetworkAccountSTEAM._on_leaderboard_mapped)
	self:set_lightfx()
	self:inventory_load()
end

-- Lines 65-68
function NetworkAccountSTEAM:_load_done(...)
	print("NetworkAccountSTEAM:_load_done()", ...)
	self:_set_presences()
end

-- Lines 70-72
function NetworkAccountSTEAM:update()
	self:_chk_inventory_outfit_refresh()
end

-- Lines 74-78
function NetworkAccountSTEAM:_set_presences()
	Steam:set_rich_presence("level", managers.experience:current_level())
end

-- Lines 80-82
function NetworkAccountSTEAM:set_presences_peer_id(peer_id)
	Steam:set_rich_presence("peer_id", peer_id)
end

-- Lines 85-102
function NetworkAccountSTEAM:get_win_ratio(difficulty, level)
	local plays = Steam:sa_handler():get_global_stat(difficulty .. "_" .. level .. "_plays", 30)
	local wins = Steam:sa_handler():get_global_stat(difficulty .. "_" .. level .. "_wins", 30)
	local ratio = {}

	if #plays == 0 or #wins == 0 then
		return
	end

	for i, plays_n in pairs(plays) do
		ratio[i] = wins[i] / (plays_n == 0 and 1 or plays_n)
	end

	table.sort(ratio)

	return ratio[#ratio / 2]
end

-- Lines 107-109
function NetworkAccountSTEAM:set_lightfx()
end

-- Lines 111-119
function NetworkAccountSTEAM._on_troll_group_recieved(success, page)
	if success and string.find(page, "<steamID64>" .. Steam:userid() .. "</steamID64>") then
		managers.network.account._masks.troll = true
	end

	Steam:http_request("http://steamcommunity.com/gid/103582791432592205/memberslistxml/?xml=1", NetworkAccountSTEAM._on_com_group_recieved)
end

-- Lines 121-129
function NetworkAccountSTEAM._on_com_group_recieved(success, page)
	if success and string.find(page, "<steamID64>" .. Steam:userid() .. "</steamID64>") then
		managers.network.account._masks.hockey_com = true
	end

	Steam:http_request("http://steamcommunity.com/gid/103582791432508229/memberslistxml/?xml=1", NetworkAccountSTEAM._on_dev_group_recieved)
end

-- Lines 131-137
function NetworkAccountSTEAM._on_dev_group_recieved(success, page)
	if success and string.find(page, "<steamID64>" .. Steam:userid() .. "</steamID64>") then
		managers.network.account._masks.developer = true
	end
end

-- Lines 140-142
function NetworkAccountSTEAM:has_alienware()
	return self._has_alienware
end

-- Lines 144-148
function NetworkAccountSTEAM:_call_listeners(event, params)
	if self._listener_holder then
		self._listener_holder:call(event, params)
	end
end

-- Lines 150-152
function NetworkAccountSTEAM:add_overlay_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

-- Lines 154-156
function NetworkAccountSTEAM:remove_overlay_listener(key)
	self._listener_holder:remove(key)
end

-- Lines 158-165
function NetworkAccountSTEAM:_on_open_overlay()
	if self._overlay_opened then
		return
	end

	self._overlay_opened = true

	self:_call_listeners("overlay_open")
	game_state_machine:_set_controller_enabled(false)
end

-- Lines 167-180
function NetworkAccountSTEAM:_on_close_overlay()
	if not self._overlay_opened then
		return
	end

	self._overlay_opened = false

	self:_call_listeners("overlay_close")

	if not managers.raid_menu:is_any_menu_open() then
		game_state_machine:_set_controller_enabled(true)
	end

	managers.dlc:chk_content_updated()
end

-- Lines 182-188
function NetworkAccountSTEAM:_on_gamepad_text_submitted(submitted, submitted_text)
	print("[NetworkAccountSTEAM:_on_gamepad_text_submitted]", "submitted", submitted, "submitted_text", submitted_text)

	for id, clbk in pairs(self._gamepad_text_listeners) do
		clbk(submitted, submitted_text)
	end

	self._gamepad_text_listeners = {}
end

-- Lines 190-212
function NetworkAccountSTEAM:show_gamepad_text_input(id, callback, params)
	return false
end

-- Lines 214-219
function NetworkAccountSTEAM:add_gamepad_text_listener(id, clbk)
	if self._gamepad_text_listeners[id] then
		debug_pause("[NetworkAccountSTEAM:add_gamepad_text_listener] ID already added!", id, "Old Clbk", self._gamepad_text_listeners[id], "New Clbk", clbk)
	end

	self._gamepad_text_listeners[id] = clbk
end

-- Lines 221-226
function NetworkAccountSTEAM:remove_gamepad_text_listener(id)
	if not self._gamepad_text_listeners[id] then
		debug_pause("[NetworkAccountSTEAM:remove_gamepad_text_listener] ID do not exist!", id)
	end

	self._gamepad_text_listeners[id] = nil
end

-- Lines 228-230
function NetworkAccountSTEAM:achievements_fetched()
	self._achievements_fetched = true
end

-- Lines 232-234
function NetworkAccountSTEAM:challenges_loaded()
	self._challenges_loaded = true
end

-- Lines 236-238
function NetworkAccountSTEAM:experience_loaded()
	self._experience_loaded = true
end

-- Lines 240-242
function NetworkAccountSTEAM._on_leaderboard_stored(status)
	print("[NetworkAccountSTEAM:_on_leaderboard_stored] Leaderboard stored, ", status, ".")
end

-- Lines 244-248
function NetworkAccountSTEAM._on_leaderboard_mapped()
	print("[NetworkAccountSTEAM:_on_leaderboard_stored] Leaderboard mapped.")
	Steam:lb_handler():request_storage()
end

-- Lines 250-269
function NetworkAccountSTEAM._on_stats_stored(status)
	print("[NetworkAccountSTEAM:_on_stats_stored] Statistics stored, ", status, ". Publishing leaderboard score to Steam!")
end

-- Lines 271-273
function NetworkAccountSTEAM:get_stat(key)
	return Steam:sa_handler():get_stat(key)
end

-- Lines 275-277
function NetworkAccountSTEAM:get_lifetime_stat(key)
	return Steam:sa_handler():get_lifetime_stat(key)
end

-- Lines 279-305
function NetworkAccountSTEAM:get_global_stat(key, days)
	local value = 0
	local global_stat = nil

	if days and days < 0 then
		local day = math.abs(days) + 1
		global_stat = Steam:sa_handler():get_global_stat(key, day)

		return global_stat[day] or 0
	elseif days then
		global_stat = Steam:sa_handler():get_global_stat(key, days == 1 and 1 or days + 1)

		for i = days > 1 and 2 or 1, #global_stat do
			value = value + global_stat[i]
		end
	else
		global_stat = Steam:sa_handler():get_global_stat(key)

		for _, day in ipairs(global_stat) do
			value = value + day
		end
	end

	return value
end

-- Lines 307-402
function NetworkAccountSTEAM:publish_statistics(stats, force_store)
	if managers.dlc:is_trial() then
		return
	end

	local handler = Steam:sa_handler()
	local err = false

	for key, stat in pairs(stats) do
		local res = nil

		if stat.type == "int" then
			local val = math.max(0, handler:get_stat(key))

			if stat.method == "lowest" then
				if stat.value < val then
					res = handler:set_stat(key, stat.value)
				else
					res = true
				end
			elseif stat.method == "highest" then
				if val < stat.value then
					res = handler:set_stat(key, stat.value)
				else
					res = true
				end
			elseif stat.method == "set" then
				res = handler:set_stat(key, math.clamp(stat.value, 0, 2147483000))
			elseif stat.value > 0 then
				local mval = val / 1000 + stat.value / 1000

				if mval >= 2147483 then
					res = handler:set_stat(key, 2147483000)
				else
					res = handler:set_stat(key, val + stat.value)
				end
			else
				res = true
			end
		elseif stat.type == "float" then
			if stat.value > 0 then
				local val = handler:get_stat_float(key)
				res = handler:set_stat_float(key, val + stat.value)
			else
				res = true
			end
		elseif stat.type == "avgrate" then
			res = handler:set_stat_float(key, stat.value, stat.hours)
		end

		if not res then
			Application:error("[NetworkAccountSTEAM:publish_statistics] Error, could not set stat " .. key)

			err = true
		end
	end

	if not err then
		handler:store_data()
	end
end

-- Lines 404-421
function NetworkAccountSTEAM._on_disconnected(lobby_id, friend_id)
	print("[NetworkAccountSTEAM._on_disconnected]", lobby_id, friend_id)

	if Application:editor() then
		return
	end

	if Network:is_server() then
		managers.raid_menu:show_dialog_disconnected_from_steam()

		Global.game_settings.single_player = true

		if managers.network.matchmake.lobby_handler then
			managers.network.matchmake.lobby_handler:leave_lobby()
		end
	end

	Application:warn("Disconnected from Steam!! Please wait", 12)
end

-- Lines 423-425
function NetworkAccountSTEAM._on_ipc_fail(lobby_id, friend_id)
	print("[NetworkAccountSTEAM._on_ipc_fail]")
end

-- Lines 428-474
function NetworkAccountSTEAM._on_join_request(lobby_id, friend_id)
	Application:trace("[NetworkAccountSTEAM._on_join_request]")

	if managers.savefile:get_active_characters_count() < 1 then
		managers.raid_menu:show_dialog_join_others_forbidden()

		return
	end

	if managers.network.matchmake.lobby_handler and managers.network.matchmake.lobby_handler:id() == lobby_id then
		return
	end

	if managers.network:session() and managers.network:session():has_other_peers() then
		managers.raid_menu:show_dialog_already_in_game()

		return
	end

	if managers.raid_job and managers.raid_job:is_in_tutorial() then
		managers.menu:show_ok_only_dialog("dialog_warning_title", "dialog_err_cant_join_from_game")

		return
	end

	if managers.raid_job and not managers.raid_job:played_tutorial() then
		managers.menu:show_ok_only_dialog("dialog_warning_title", "dialog_err_tutorial_not_finished")

		return
	end

	if game_state_machine:current_state_name() ~= "menu_main" then
		print("INGAME INVITE")

		if managers.groupai then
			managers.groupai:kill_all_AI()
		end

		Global.game_settings.single_player = false
		Global.boot_invite = lobby_id

		MenuCallbackHandler:_dialog_end_game_yes()

		return
	else
		if not Global.user_manager.user_index or not Global.user_manager.active_user_state_change_quit then
			print("BOOT UP INVITE")

			Global.boot_invite = lobby_id

			return
		end

		Global.game_settings.single_player = false

		managers.network.matchmake:join_server_with_check(lobby_id, true)
	end
end

-- Lines 476-479
function NetworkAccountSTEAM._on_server_request(ip, pw)
	print("[NetworkAccountSTEAM._on_server_request]")
end

-- Lines 481-484
function NetworkAccountSTEAM._on_connect_fail(ip, pw)
	print("[NetworkAccountSTEAM._on_connect_fail]")
end

-- Lines 488-493
function NetworkAccountSTEAM:signin_state()
	if self:local_signin_state() == true then
		return "signed in"
	end

	return "not signed in"
end

-- Lines 495-497
function NetworkAccountSTEAM:local_signin_state()
	return Steam:logged_on()
end

-- Lines 499-501
function NetworkAccountSTEAM:username_id()
	return Steam:username()
end

-- Lines 503-505
function NetworkAccountSTEAM:username_by_id(id)
	return Steam:username(id)
end

-- Lines 507-509
function NetworkAccountSTEAM:player_id()
	return Steam:userid()
end

-- Lines 511-513
function NetworkAccountSTEAM:is_connected()
	return true
end

-- Lines 515-517
function NetworkAccountSTEAM:lan_connection()
	return true
end

-- Lines 519-521
function NetworkAccountSTEAM:set_playing(state)
	Steam:set_playing(state)
end

-- Lines 524-534
function NetworkAccountSTEAM:_load_globals()
	if Global.steam and Global.steam.account then
		self._outfit_signature = Global.steam.account.outfit_signature and Global.steam.account.outfit_signature:get_data()

		if Global.steam.account.outfit_signature then
			Global.steam.account.outfit_signature:destroy()
		end

		Global.steam.account = nil
	end
end

-- Lines 536-541
function NetworkAccountSTEAM:_save_globals()
	Global.steam = Global.steam or {}
	Global.steam.account = {
		outfit_signature = self._outfit_signature and Application:create_luabuffer(self._outfit_signature)
	}
end

-- Lines 543-545
function NetworkAccountSTEAM:is_ready_to_close()
	return not self._inventory_is_loading and not self._inventory_outfit_refresh_requested and not self._inventory_outfit_refresh_in_progress
end

-- Lines 551-576
function NetworkAccountSTEAM:inventory_load(callback_ref)
	if self._inventory_is_loading then
		return
	end

	if managers.raid_menu:is_offline_mode() then
		self:_clbk_inventory_load(nil, {})

		return
	end

	if callback_ref then
		Steam:inventory_load(callback_ref)
	else
		Steam:inventory_load(callback(self, self, "_clbk_inventory_load"))
	end
end

-- Lines 578-621
function NetworkAccountSTEAM:_clbk_inventory_load(error, list)
	self._inventory_is_loading = nil

	if error then
		Application:error("[NetworkAccountSTEAM:_clbk_inventory_load] Failed to update tradable inventory (" .. tostring(error) .. ")")
	end

	local filtered_list = self:_verify_filter_cards(list)

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_LOADED, {
		error = error,
		list = filtered_list
	})
end

-- Lines 623-661
function NetworkAccountSTEAM:_verify_filter_cards(card_list)
	local filtered_list = {}
	local result = {}

	if card_list then
		for _, card_steam_data in pairs(card_list) do
			if card_steam_data.category == "challenge_card" then
				local challenge_card_data = managers.challenge_cards:get_challenge_card_data(card_steam_data.entry)

				if challenge_card_data then
					if not filtered_list[challenge_card_data.key_name] then
						filtered_list[challenge_card_data.key_name] = challenge_card_data
						filtered_list[challenge_card_data.key_name].steam_instance_ids = {}
					end

					table.insert(filtered_list[challenge_card_data.key_name].steam_instance_ids, card_steam_data.instance_id)
				end
			end
		end
	end

	if filtered_list then
		for card_key_name, card_data in pairs(filtered_list) do
			table.insert(result, card_data)
		end
	end

	return result
end

-- Lines 663-665
function NetworkAccountSTEAM:inventory_is_loading()
	return self._inventory_is_loading
end

-- Lines 667-689
function NetworkAccountSTEAM:inventory_reward(item_def_id, callback_ref)
	if not item_def_id or item_def_id < 1 then
		Application:error("[NetworkAccountSTEAM:inventory_reward] item_def_id nil")

		item_def_id = 1
	end

	if callback_ref then
		Application:debug("[NetworkAccountSTEAM:inventory_reward] callback_ref exists:", callback_ref, item_def_id)
		Steam:inventory_reward(callback_ref, item_def_id)
	else
		Application:debug("[NetworkAccountSTEAM:inventory_reward] callback_ref nil:", item_def_id)
		Steam:inventory_reward(callback(self, self, "_clbk_inventory_reward"), item_def_id)
	end

	return true
end

-- Lines 691-699
function NetworkAccountSTEAM:_clbk_inventory_reward(error, tradable_list)
	Application:trace("[NetworkAccountSTEAM:_clbk_inventory_reward]")
	Application:trace("error ", inspect(error))
	Application:trace("tradable_list ", inspect(tradable_list))
	Application:error("*This is empty callback, you need to pass callback that you want to process loot drop. If you are seeing this there was no valid callback set!")
end

-- Lines 701-714
function NetworkAccountSTEAM:inventory_remove(instance_id)
	Application:trace("[ChallengeCardsManager:inventory_remove] instance_id ", instance_id)

	local return_status = Steam:inventory_remove(instance_id)
end

-- Lines 716-717
function NetworkAccount:inventory_reward_open(safe, safe_instance_id, reward_unlock_callback)
end

-- Lines 719-727
function NetworkAccountSTEAM:inventory_reward_dlc(def_id, reward_promo_callback)
end

-- Lines 729-738
function NetworkAccountSTEAM:inventory_outfit_refresh()
	self._inventory_outfit_refresh_requested = true
end

-- Lines 740-752
function NetworkAccountSTEAM:_inventory_outfit_refresh()
	local outfit = managers.blackmarket:tradable_outfit()

	print("[NetworkAccountSTEAM:_inventory_outfit_refresh]", "outfit: ", inspect(outfit))

	if table.size(outfit) > 0 then
		self._outfit_signature = nil
		self._inventory_outfit_refresh_in_progress = true

		Steam:inventory_signature_create(outfit, callback(self, self, "_clbk_tradable_outfit_data"))
	else
		self._outfit_signature = ""

		managers.network:session():check_send_outfit()
	end
end

-- Lines 754-766
function NetworkAccountSTEAM:_chk_inventory_outfit_refresh()
	if not self._inventory_outfit_refresh_requested then
		return
	end

	if self._inventory_outfit_refresh_in_progress then
		return
	end

	self._inventory_outfit_refresh_requested = nil

	self:_inventory_outfit_refresh()
end

-- Lines 768-774
function NetworkAccountSTEAM:inventory_outfit_verify(steam_id, outfit_data, outfit_callback)
	if outfit_data == "" then
		return outfit_callback and outfit_callback(nil, false, {})
	end

	Steam:inventory_signature_verify(steam_id, outfit_data, outfit_callback)
end

-- Lines 776-778
function NetworkAccountSTEAM:inventory_outfit_signature()
	return self._outfit_signature
end

-- Lines 780-781
function NetworkAccountSTEAM:inventory_repair_list(list)
end

-- Lines 783-800
function NetworkAccountSTEAM:_clbk_tradable_outfit_data(error, outfit_signature)
	print("[NetworkAccountSTEAM:_clbk_tradable_outfit_data] error: ", error, ", self._outfit_signature: ", self._outfit_signature, "\n outfit_signature: ", outfit_signature, "\n")

	self._inventory_outfit_refresh_in_progress = nil

	if self._inventory_outfit_refresh_requested then
		return
	end

	if error then
		Application:error("[NetworkAccountSTEAM:_clbk_tradable_outfit_data] Failed to check tradable inventory (" .. tostring(error) .. ")")
	end

	self._outfit_signature = outfit_signature

	if managers.network:session() then
		managers.network:session():check_send_outfit()
	end
end

-- Lines 808-927
function NetworkAccountSTEAM.output_global_stats(file)
	local num_days = 100
	local sa = Steam:sa_handler()
	local invalid = sa:get_global_stat("easy_slaughter_house_plays", num_days)
	invalid[1] = 1
	invalid[3] = 1
	invalid[11] = 1
	invalid[12] = 1
	invalid[19] = 1
	invalid[28] = 1
	invalid[51] = 1
	invalid[57] = 1

	-- Lines 824-846
	local function get_lvl_stat(diff, heist, stat, i)
		if i == 0 then
			local st = NetworkAccountSTEAM.lb_levels[heist] .. ", " .. NetworkAccountSTEAM.lb_diffs[diff] .. " - "

			if type(stat) == "string" then
				return st .. stat
			else
				return st .. stat[1] .. "/" .. stat[2]
			end
		end

		local num = nil

		if type(stat) == "string" then
			num = sa:get_global_stat(diff .. "_" .. heist .. "_" .. stat, num_days)[i] or 0
		else
			local f = sa:get_global_stat(diff .. "_" .. heist .. "_" .. stat[1], num_days)[i] or 0
			local s = sa:get_global_stat(diff .. "_" .. heist .. "_" .. stat[2], num_days)[i] or 1
			num = f / (s == 0 and 1 or s)
		end

		return num
	end

	-- Lines 849-871
	local function get_weapon_stat(weapon, stat, i)
		if i == 0 then
			local st = weapon .. " - "

			if type(stat) == "string" then
				return st .. stat
			else
				return st .. stat[1] .. "/" .. stat[2]
			end
		end

		local num = nil

		if type(stat) == "string" then
			num = sa:get_global_stat(weapon .. "_" .. stat, num_days)[i] or 0
		else
			local f = sa:get_global_stat(weapon .. "_" .. stat[1], num_days)[i] or 0
			local s = sa:get_global_stat(weapon .. "_" .. stat[2], num_days)[i] or 1
			num = f / (s == 0 and 1 or s)
		end

		return num
	end

	local diffs = {
		"easy",
		"normal",
		"hard",
		"overkill",
		"overkill_145",
		"overkill_290"
	}
	local heists = {
		"bank",
		"heat_street",
		"bridge",
		"apartment",
		"slaughter_house",
		"diamond_heist"
	}
	local weapons = {
		"beretta92",
		"c45",
		"raging_bull",
		"r870_shotgun",
		"mossberg",
		"m4",
		"mp5",
		"mac11",
		"m14",
		"hk21"
	}
	local lvl_stats = {
		"plays",
		{
			"wins",
			"plays"
		},
		{
			"kills",
			"plays"
		}
	}
	local wep_stats = {
		"kills",
		{
			"kills",
			"shots"
		},
		{
			"headshots",
			"shots"
		}
	}
	local lines = {}

	for i = 0, #invalid do
		if i == 0 or invalid[i] == 0 then
			local out = "" .. i

			for _, lvl_stat in ipairs(lvl_stats) do
				for _, diff in ipairs(diffs) do
					for _, heist in ipairs(heists) do
						out = out .. ";" .. get_lvl_stat(diff, heist, lvl_stat, i)
					end
				end
			end

			for _, wep_stat in ipairs(wep_stats) do
				for _, weapon in ipairs(weapons) do
					out = out .. ";" .. get_weapon_stat(weapon, wep_stat, i)
				end
			end

			table.insert(lines, out)
		end
	end

	local file_handle = SystemFS:open(file, "w")

	for i = 1, #lines do
		file_handle:puts(lines[i == 1 and 1 or #lines - i + 2])
	end
end
