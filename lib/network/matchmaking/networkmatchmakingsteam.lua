NetworkMatchMakingSTEAM = NetworkMatchMakingSTEAM or class()
NetworkMatchMakingSTEAM.OPEN_SLOTS = 4
NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = "raid_ww2_retail_21_03"
NetworkMatchMakingSTEAM.EMPTY_PLAYER_INFO = "-,-,-,-"

function NetworkMatchMakingSTEAM:init()
	cat_print("lobby", "matchmake = NetworkMatchMakingSTEAM")

	self._callback_map = {}
	self._lobby_filters = {}
	self._distance_filter = 2
	self._difficulty_filter = 0
	self._lobby_return_count = 25
	self._try_re_enter_lobby = nil
	self._server_joinable = false
end

function NetworkMatchMakingSTEAM:register_callback(event, callback)
	self._callback_map[event] = callback
end

function NetworkMatchMakingSTEAM:_call_callback(name, ...)
	if self._callback_map[name] then
		return self._callback_map[name](...)
	else
		Application:error("Callback " .. name .. " not found.")
	end
end

function NetworkMatchMakingSTEAM:_has_callback(name)
	if self._callback_map[name] then
		return true
	end

	return false
end

function NetworkMatchMakingSTEAM:_split_attribute_number(attribute_number, splitter)
	if not splitter or splitter == 0 or type(splitter) ~= "number" then
		Application:error("NetworkMatchMakingSTEAM:_split_attribute_number. splitter needs to be a non 0 number!", "attribute_number", attribute_number, "splitter", splitter)
		Application:stack_dump()

		return 1, 1
	end

	return attribute_number % splitter, math.floor(attribute_number / splitter)
end

function NetworkMatchMakingSTEAM:destroy_game()
	self:leave_game()
end

function NetworkMatchMakingSTEAM:_load_globals()
	if Global.steam and Global.steam.match then
		self.lobby_handler = Global.steam.match.lobby_handler
		self._lobby_attributes = Global.steam.match.lobby_attributes

		if self.lobby_handler then
			self.lobby_handler:setup_callbacks(NetworkMatchMakingSTEAM._on_memberstatus_change, NetworkMatchMakingSTEAM._on_data_update, NetworkMatchMakingSTEAM._on_chat_message)
		end

		self._try_re_enter_lobby = Global.steam.match.try_re_enter_lobby
		self._server_rpc = Global.steam.match.server_rpc
		self._lobby_filters = Global.steam.match.lobby_filters or self._lobby_filters
		self._distance_filter = Global.steam.match.distance_filter or self._distance_filter
		self._difficulty_filter = Global.steam.match.difficulty_filter or self._difficulty_filter
		self._lobby_return_count = Global.steam.match.lobby_return_count or self._lobby_return_count
		Global.steam.match = nil
	end
end

function NetworkMatchMakingSTEAM:_save_globals()
	if not Global.steam then
		Global.steam = {}
	end

	Global.steam.match = {
		lobby_handler = self.lobby_handler,
		lobby_attributes = self._lobby_attributes,
		try_re_enter_lobby = self._try_re_enter_lobby,
		server_rpc = self._server_rpc,
		lobby_filters = self._lobby_filters,
		distance_filter = self._distance_filter,
		difficulty_filter = self._difficulty_filter,
		lobby_return_count = self._lobby_return_count
	}
end

function NetworkMatchMakingSTEAM:set_join_invite_pending(lobby_id)
	self._join_invite_pending = lobby_id
end

function NetworkMatchMakingSTEAM:update()
	Steam:update()

	if self._try_re_enter_lobby then
		if self._try_re_enter_lobby == "lost" then
			Application:error("REQUESTING RE-OPEN LOBBY")
			self._server_rpc:re_open_lobby_request(true)

			self._try_re_enter_lobby = "asked"
		elseif self._try_re_enter_lobby == "asked" then
			-- Nothing
		elseif self._try_re_enter_lobby == "open" and self.lobby_handler then
			self._try_re_enter_lobby = "joining"

			Application:error("RE-ENTERING LOBBY", self.lobby_handler:id())

			local function _join_lobby_result_f(result, handler)
				if result == "success" then
					Application:error("SUCCESS!")

					self.lobby_handler = handler

					self._server_rpc:re_open_lobby_request(false)

					self._try_re_enter_lobby = nil
				else
					Application:error("FAIL!")

					self._try_re_enter_lobby = "open"
				end
			end

			Steam:join_lobby(self.lobby_handler:id(), _join_lobby_result_f)
		end
	end

	if self._join_invite_pending and not managers.network:session() then
		managers.network.matchmake:join_server_with_check(self._join_invite_pending, true)

		self._join_invite_pending = nil
	end
end

function NetworkMatchMakingSTEAM:leave_game()
	self._server_rpc = nil

	if self.lobby_handler then
		self.lobby_handler:leave_lobby()
	end

	self.lobby_handler = nil
	self._server_joinable = true

	if self._try_re_enter_lobby then
		self._try_re_enter_lobby = nil
	end

	print("NetworkMatchMakingSTEAM:leave_game()")
end

function NetworkMatchMakingSTEAM:get_friends_lobbies()
	local lobbies = {}
	local num_updated_lobbies = 0

	local function empty()
	end

	local function f(updated_lobby)
		updated_lobby:setup_callback(empty)
		print("NetworkMatchMakingSTEAM:get_friends_lobbies f")

		num_updated_lobbies = num_updated_lobbies + 1

		if num_updated_lobbies >= #lobbies then
			local info = {
				room_list = {},
				attribute_list = {}
			}

			for _, lobby in ipairs(lobbies) do
				if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY then
					local ikey = lobby:key_value(NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY)

					if ikey ~= "value_missing" and ikey ~= "value_pending" then
						table.insert(info.room_list, {
							owner_id = lobby:key_value("owner_id"),
							owner_name = lobby:key_value("owner_name"),
							room_id = lobby:id()
						})
						table.insert(info.attribute_list, {
							numbers = self:_lobby_to_numbers(lobby)
						})
					end
				end
			end

			self:_call_callback("search_lobby", info)
		end
	end

	if Steam:logged_on() and Steam:friends() then
		for _, friend in ipairs(Steam:friends()) do
			local lobby = friend:lobby()

			if lobby then
				local user_id_to_filter_out = Steam:userid()

				if managers.criminals and managers.criminals:get_num_player_criminals() > 1 and managers.network and managers.network:session() and managers.network:session():all_peers() then
					user_id_to_filter_out = managers.network:session():all_peers()[1]:user_id()
				end

				local add_lobby = true
				local filter_in_camp = tostring(self._lobby_filters.state.value)
				local filter_difficulty = tostring(self._difficulty_filter)
				local filter_job = tostring(self._lobby_filters.job_id.value)

				if filter_in_camp == "1" and filter_in_camp ~= lobby:key_value("state") then
					add_lobby = false
				elseif filter_difficulty ~= "0" and filter_difficulty ~= lobby:key_value("difficulty") then
					add_lobby = false
				elseif filter_job ~= "-1" and filter_job ~= lobby:key_value("job_id") then
					add_lobby = false
				end

				if user_id_to_filter_out ~= lobby:key_value("owner_id") and add_lobby then
					table.insert(lobbies, lobby)
				end
			end
		end
	end

	if #lobbies == 0 then
		local info = {
			room_list = {},
			attribute_list = {}
		}

		self:_call_callback("search_lobby", info)
	else
		for _, lobby in ipairs(lobbies) do
			lobby:setup_callback(f)

			if lobby:key_value("state") == "value_pending" then
				print("NetworkMatchMakingSTEAM:get_friends_lobbies value_pending")
				lobby:request_data()
			else
				f(lobby)
			end
		end
	end
end

function NetworkMatchMakingSTEAM:search_friends_only()
	return self._search_friends_only
end

function NetworkMatchMakingSTEAM:set_search_friends_only(flag)
	self._search_friends_only = flag
end

function NetworkMatchMakingSTEAM:distance_filter()
	return self._distance_filter
end

function NetworkMatchMakingSTEAM:set_distance_filter(filter)
	self._distance_filter = filter
end

function NetworkMatchMakingSTEAM:get_lobby_return_count()
	return self._lobby_return_count
end

function NetworkMatchMakingSTEAM:set_lobby_return_count(lobby_return_count)
	self._lobby_return_count = lobby_return_count
end

function NetworkMatchMakingSTEAM:lobby_filters()
	return self._lobby_filters
end

function NetworkMatchMakingSTEAM:set_lobby_filters(filters)
	self._lobby_filters = filters or {}
end

function NetworkMatchMakingSTEAM:add_lobby_filter(key, value, comparision_type)
	self._lobby_filters[key] = {
		key = key,
		value = value,
		comparision_type = comparision_type
	}
end

function NetworkMatchMakingSTEAM:get_lobby_filter(key)
	return self._lobby_filters[key] and self._lobby_filters[key].value or false
end

function NetworkMatchMakingSTEAM:difficulty_filter()
	return self._difficulty_filter
end

function NetworkMatchMakingSTEAM:set_difficulty_filter(filter)
	self._difficulty_filter = filter
end

function NetworkMatchMakingSTEAM:search_lobby(friends_only)
	self._search_friends_only = friends_only

	if not self:_has_callback("search_lobby") then
		return
	end

	if friends_only then
		self:get_friends_lobbies()
	else
		local function refresh_lobby()
			if not self.browser then
				return
			end

			local lobbies = self.browser:lobbies()
			local info = {
				room_list = {},
				attribute_list = {}
			}

			if lobbies then
				for _, lobby in ipairs(lobbies) do
					if self._difficulty_filter == 0 or self._difficulty_filter == tonumber(lobby:key_value("difficulty")) then
						table.insert(info.room_list, {
							owner_id = lobby:key_value("owner_id"),
							owner_name = lobby:key_value("owner_name"),
							room_id = lobby:id(),
							custom_text = lobby:key_value("custom_text")
						})
						table.insert(info.attribute_list, {
							numbers = self:_lobby_to_numbers(lobby)
						})
					end
				end
			end

			self:_call_callback("search_lobby", info)
		end

		self.browser = LobbyBrowser(refresh_lobby, function ()
		end)
		local interest_keys = {
			"owner_id",
			"owner_name",
			"level",
			"difficulty",
			"permission",
			"state",
			"num_players",
			"drop_in",
			"min_level",
			"kick_option",
			"job_class_min",
			"job_class_max"
		}

		if self._BUILD_SEARCH_INTEREST_KEY then
			table.insert(interest_keys, self._BUILD_SEARCH_INTEREST_KEY)
		end

		self.browser:set_interest_keys(interest_keys)
		self.browser:set_distance_filter(self._distance_filter)
		self.browser:set_lobby_filter(self._BUILD_SEARCH_INTEREST_KEY, "true", "equal")

		local user_id_to_filter_out = Steam:userid()

		if managers.criminals and managers.criminals:get_num_player_criminals() > 1 and managers.network and managers.network:session() and managers.network:session():all_peers() then
			user_id_to_filter_out = managers.network:session():all_peers()[1]:user_id()
		end

		self.browser:set_lobby_filter("owner_id", user_id_to_filter_out, "not_equal")

		for key, data in pairs(self._lobby_filters) do
			if data.value and data.value ~= -1 then
				self.browser:set_lobby_filter(data.key, data.value, data.comparision_type)
			end
		end

		self.browser:set_max_lobby_return_count(self._lobby_return_count)

		if Global.game_settings.playing_lan then
			self.browser:refresh_lan()
		else
			self.browser:refresh()
		end
	end
end

function NetworkMatchMakingSTEAM:search_lobby_done()
	managers.system_menu:close("find_server")

	self.browser = nil
end

function NetworkMatchMakingSTEAM:game_owner_name()
	return managers.network.matchmake.lobby_handler:get_lobby_data("owner_name")
end

function NetworkMatchMakingSTEAM:is_server_ok(friends_only, room, attributes_numbers, is_invite)
	local permission = tweak_data:index_to_permission(attributes_numbers[3])

	if (not NetworkManager.DROPIN_ENABLED or attributes_numbers[6] == 0) and attributes_numbers[4] ~= 1 then
		Application:debug("NetworkMatchMakingSTEAM:is_server_ok() server rejected. DROPING NOT ENABLED")

		return false, 1
	end

	if managers.experience:current_level() < attributes_numbers[7] then
		Application:debug("NetworkMatchMakingSTEAM:is_server_ok() server rejected. REPUTATION CAP")

		return false, 3
	end

	if not is_invite and permission == "private" then
		Application:debug("NetworkMatchMakingSTEAM:is_server_ok() server rejected. PRIVATE GAME")

		return false, 2
	end

	if permission == "public" then
		return true
	end

	return true
end

function NetworkMatchMakingSTEAM:join_server_with_check(room_id, is_invite)
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

	self._join_called_from_camp = managers.player and managers.player:local_player_in_camp()

	managers.menu:show_joining_lobby_dialog()

	local lobby = Steam:lobby(room_id)

	local function empty()
	end

	local function f()
		print("NetworkMatchMakingSTEAM:join_server_with_check f")
		lobby:setup_callback(empty)

		local attributes = self:_lobby_to_numbers(lobby)

		if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY then
			local ikey = lobby:key_value(NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY)

			if ikey == "value_missing" or ikey == "value_pending" then
				print("Wrong version!!")
				managers.system_menu:close("join_server")
				managers.menu:show_failed_joining_dialog()

				return
			end
		end

		print(inspect(attributes))

		local server_ok, ok_error = self:is_server_ok(nil, room_id, attributes, is_invite)

		if server_ok then
			self:join_server(room_id, true)
		else
			managers.system_menu:close("join_server")

			managers.worldcollection.level_transition_in_progress = false

			if ok_error == 1 then
				managers.menu:show_game_started_dialog()
			elseif ok_error == 2 then
				managers.menu:show_game_permission_changed_dialog()
			elseif ok_error == 3 then
				managers.menu:show_too_low_level()
			elseif ok_error == 4 then
				managers.menu:show_does_not_own_heist()
			end

			self:search_lobby(self:search_friends_only())
		end
	end

	lobby:setup_callback(f)

	if lobby:key_value("state") == "value_pending" then
		print("NetworkMatchMakingSTEAM:join_server_with_check value_pending")
		lobby:request_data()
	else
		f()
	end
end

function NetworkMatchMakingSTEAM._on_member_left(steam_id, status)
	if not managers.network:session() then
		return
	end

	local peer = managers.network:session():peer_by_user_id(steam_id)

	if not peer then
		return
	end

	if peer == managers.network:session():local_peer() and not managers.network:session():closing() then
		Application:error("[NetworkMatchMakingSTEAM][_on_member_left] left the lobby")

		managers.network.matchmake._try_re_enter_lobby = "lost"
	else
		managers.network:session():on_peer_left(peer, peer:id())
		managers.network:session():on_peer_left_lobby(peer)
	end
end

function NetworkMatchMakingSTEAM._on_memberstatus_change(memberstatus)
	print("[NetworkMatchMakingSTEAM._on_memberstatus_change]", memberstatus)

	local user, status = unpack(string.split(memberstatus, ":"))

	if status == "lost_steam_connection" or status == "left_become_owner" or status == "left" or status == "kicked" or status == "banned" or status == "invalid" then
		NetworkMatchMakingSTEAM._on_member_left(user, status)
	end
end

function NetworkMatchMakingSTEAM._on_data_update(...)
end

function NetworkMatchMakingSTEAM._on_chat_message(user, message)
	print("[NetworkMatchMakingSTEAM._on_chat_message]", user, message)
	NetworkMatchMakingSTEAM._handle_chat_message(user, message)
end

function NetworkMatchMakingSTEAM._handle_chat_message(user, message)
	local s = "" .. message

	managers.chat:receive_message_by_name(ChatManager.GLOBAL, user:name(), s)
end

function NetworkMatchMakingSTEAM._joined_game(res, level_index, difficulty_index, state_index)
	local matchmake = managers.network.matchmake

	if res ~= "FAILED_CONNECT" or matchmake._server_connect_retried and NetworkMatchMaking.RETRY_CONNECT_COUNT <= matchmake._server_connect_retried then
		managers.system_menu:close("waiting_for_server_response")
	end

	print("[NetworkMatchMakingSTEAM:join_server:joined_game]", res, level_index, difficulty_index, state_index)

	if res == "JOINED_LOBBY" then
		if managers.groupai then
			managers.groupai:kill_all_AI()
		end

		managers.menu:on_enter_lobby()
	elseif res == "JOINED_GAME" then
		if managers.groupai then
			managers.groupai:kill_all_AI()
		end

		local level_id = tweak_data.levels:get_level_name_from_index(level_index)
		Global.game_settings.level_id = level_id

		managers.network:session():local_peer():set_in_lobby(false)
	elseif res == "KICKED" then
		matchmake:_restart_network()
		managers.menu:show_peer_already_kicked_from_game_dialog()
	elseif res == "TIMED_OUT" then
		matchmake:_restart_network()
		managers.menu:show_request_timed_out_dialog()
	elseif res == "GAME_STARTED" then
		matchmake:_restart_network()
		managers.menu:show_failed_joining_dialog()
	elseif res == "DO_NOT_OWN_HEIST" then
		matchmake:_restart_network()
		managers.menu:show_does_not_own_heist()
	elseif res == "CANCELLED" then
		matchmake:_restart_network()
	elseif res == "FAILED_CONNECT" then
		if not matchmake._server_connect_retried or matchmake._server_connect_retried < NetworkMatchMaking.RETRY_CONNECT_COUNT then
			if not matchmake._server_connect_retried then
				matchmake._server_connect_retried = 1
			else
				matchmake._server_connect_retried = matchmake._server_connect_retried + 1
			end

			Application:debug("[NetworkMatchMakingSTEAM:join_server] Retry to connect!", matchmake._server_connect_retried)
			managers.queued_tasks:queue("NetworkRetryJoinAttempt", matchmake._retry_join, matchmake, nil, 1.5)
		else
			Application:debug("[NetworkMatchMakingSTEAM:join_server] Fail to connect!")
			matchmake:_restart_network()
			managers.menu:show_failed_joining_dialog()
		end
	elseif res == "GAME_FULL" then
		matchmake:_restart_network()
		managers.menu:show_game_is_full()
	elseif res == "LOW_LEVEL" then
		matchmake:_restart_network()
		managers.menu:show_too_low_level()
	elseif res == "WRONG_VERSION" then
		matchmake:_restart_network()
		managers.menu:show_wrong_version_message()
	elseif res == "AUTH_FAILED" or res == "AUTH_HOST_FAILED" then
		matchmake:_restart_network()

		Global.on_remove_peer_message = res == "AUTH_HOST_FAILED" and "dialog_authentication_host_fail" or "dialog_authentication_fail"

		managers.menu:show_peer_kicked_dialog()
	else
		Application:error("[NetworkMatchMakingSTEAM:join_server] FAILED TO START MULTIPLAYER!", res)
	end

	World:set_extensions_update_enabled(true)
end

function NetworkMatchMakingSTEAM:join_server(room_id, skip_showing_dialog)
	if not skip_showing_dialog then
		managers.menu:show_joining_lobby_dialog()
	end

	setup.exit_to_main_menu = true
	self._join_called_from_camp = managers.player and managers.player:local_player_in_camp()

	local function f(result, handler)
		print("[NetworkMatchMakingSTEAM:join_server:f]", result, handler)
		managers.system_menu:close("join_server")

		managers.worldcollection.level_transition_in_progress = false

		if result == "success" then
			print("Success!")

			self.lobby_handler = handler
			local _, host_id, owner = self.lobby_handler:get_server_details()

			print("[NetworkMatchMakingSTEAM:join_server] server details", _, host_id)
			print("Gonna handshake now!")

			self._server_rpc = Network:handshake(host_id:tostring(), nil, "STEAM")

			print("Handshook!")
			print("Server RPC:", self._server_rpc and self._server_rpc:ip_at_index(0))

			if not self._server_rpc then
				return
			end

			self.lobby_handler:setup_callbacks(NetworkMatchMakingSTEAM._on_memberstatus_change, NetworkMatchMakingSTEAM._on_data_update, NetworkMatchMakingSTEAM._on_chat_message)
			managers.platform:set_presence("Signed_in")
			managers.network:start_client()

			managers.network._restart_in_camp = managers.player and managers.player:local_player_in_camp()

			managers.menu:show_waiting_for_server_response({
				cancel_func = function ()
					Application:debug("[ NetworkMatchMakingSTEAM:join_server:f] Pressed cancel")
					managers.network:session():on_join_request_cancelled()
					managers.network:queue_stop_network()
					World:set_extensions_update_enabled(true)
				end
			})
			managers.network:join_game_at_host_rpc(self._server_rpc, self._joined_game)
		else
			World:set_extensions_update_enabled(true)
			managers.menu:show_failed_joining_dialog()
			self:search_lobby(self:search_friends_only())
		end
	end

	World:set_extensions_update_enabled(false)
	Steam:join_lobby(room_id, f)
end

function NetworkMatchMakingSTEAM:_retry_join()
	Application:debug("[NetworkMatchMakingSTEAM:_retry_join]")

	if self._server_rpc then
		managers.network:join_game_at_host_rpc(self._server_rpc, self._joined_game)
	end
end

function NetworkMatchMakingSTEAM:_restart_network()
	if self._join_called_from_camp then
		managers.menu:hide_loading_screen()

		Global.dropin_loading_screen = nil

		managers.network.matchmake:leave_game()
		managers.network.voice_chat:destroy_voice()
		managers.network:queue_stop_network()
		managers.game_play_central:restart_the_game()
	else
		managers.network:prepare_stop_network()
	end
end

function NetworkMatchMakingSTEAM:send_join_invite(friend)
end

function NetworkMatchMakingSTEAM:set_server_attributes(settings)
	self:set_attributes(settings)
end

function NetworkMatchMakingSTEAM:create_lobby(settings, return_to_camp_client)
	if Global.game_settings.single_player then
		return
	end

	self._num_players = nil
	local dialog_data = {
		title = managers.localization:text("dialog_creating_lobby_title"),
		text = managers.localization:text("dialog_wait"),
		id = "create_lobby",
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)

	local function f(result, handler)
		print("Create lobby callback!!", result, return_to_camp_client, handler)

		if result == "success" then
			self.lobby_handler = handler

			self:set_attributes(settings)
			self.lobby_handler:publish_server_details()

			self._server_joinable = true

			self.lobby_handler:set_joinable(true)
			self.lobby_handler:setup_callbacks(NetworkMatchMakingSTEAM._on_memberstatus_change, NetworkMatchMakingSTEAM._on_data_update, NetworkMatchMakingSTEAM._on_chat_message)
			managers.system_menu:close("create_lobby")

			if not return_to_camp_client then
				managers.menu:created_lobby()

				if self._restart_in_camp then
					self._restart_in_camp = nil

					managers.platform:set_presence("Playing")
					managers.network:session():local_peer():set_synched(true)
					managers.network:session():local_peer():set_loaded(true)
					managers.network:session():spawn_players()
					managers.global_state:fire_event(GlobalStateManager.EVENT_RESTART_CAMP)
				end
			end
		else
			managers.system_menu:close("create_lobby")
			managers.menu:hide_loading_screen()

			local title = managers.localization:text("dialog_error_title")
			local dialog_data = {
				title = title,
				text = managers.localization:text("dialog_err_failed_creating_lobby"),
				button_list = {
					{
						text = managers.localization:text("dialog_ok"),
						callback_func = callback(setup, setup, "quit_to_main_menu")
					}
				}
			}

			managers.system_menu:show(dialog_data)
		end
	end

	return Steam:create_lobby(f, NetworkMatchMakingSTEAM.OPEN_SLOTS, "invisible")
end

function NetworkMatchMakingSTEAM:set_num_players(num)
	print("NetworkMatchMakingSTEAM:set_num_players", num)

	self._num_players = num

	if self._lobby_attributes then
		self._lobby_attributes.num_players = num

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingSTEAM:set_job_info_by_current_job()
	local level_id, job_id, progress, mission_type, server_state_id = managers.network.matchmake:get_job_info_by_current_job()

	if self._lobby_attributes and self.lobby_handler then
		self._lobby_attributes.level = level_id
		self._lobby_attributes.job_id = job_id
		self._lobby_attributes.progress = progress
		self._lobby_attributes.mission_type = mission_type
		self._lobby_attributes.state = server_state_id

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingSTEAM:set_challenge_card_info()
	local active_card = managers.challenge_cards:get_active_card()

	if self._lobby_attributes then
		if active_card then
			self._lobby_attributes.challenge_card_id = active_card.key_name
		else
			self._lobby_attributes.challenge_card_id = "nocards"
		end

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingSTEAM:get_job_info_by_current_job()
	local level_id = OperationsTweakData.IN_LOBBY
	local job_id = OperationsTweakData.IN_LOBBY
	local progress = "-"
	local server_state_id = 1
	local mission_type = managers.raid_job:current_job() and managers.raid_job:current_job().job_type or OperationsTweakData.IN_LOBBY

	if mission_type == OperationsTweakData.JOB_TYPE_OPERATION then
		progress = managers.raid_job:current_job().current_event .. "/" .. #managers.raid_job:current_job().events_index
		level_id = managers.raid_job:current_job().events_index[managers.raid_job:current_job().current_event]
		job_id = managers.raid_job:current_job().job_id
		server_state_id = 3
	elseif mission_type == OperationsTweakData.JOB_TYPE_RAID then
		progress = "1/1"
		level_id = managers.raid_job:current_job().level_id
		job_id = level_id
		server_state_id = 3
	end

	return level_id, job_id, progress, mission_type, server_state_id
end

function NetworkMatchMakingSTEAM:get_all_players_info()
	local host_level = managers.experience:current_level() or "-"
	local host_class = managers.skilltree:get_character_profile_class() or "-"
	local host_name = string.gsub(managers.network.account:username() or "", ",", "")
	local host_nationality = managers.network:session() and managers.network:session():all_peers() and managers.network:session():all_peers()[1] and managers.network:session():all_peers()[1]:character() or Global.player_manager.character_profile_nation
	local players_data = {}
	local peer_id = 0

	for peer_id = 2, 4 do
		if managers.network and managers.network:session() and managers.network:session():all_peers() then
			local peer_data = managers.network:session():all_peers()[peer_id]

			if peer_data then
				local peer_level = peer_data:level() or ""
				local peer_class = peer_data:class() or ""
				local peer_name = string.gsub(peer_data:name() or "", ",", "")
				local peer_nationality = peer_data:character() or ""
				players_data[peer_id] = peer_level .. "," .. peer_class .. "," .. peer_name .. "," .. peer_nationality
			end
		else
			players_data[peer_id] = NetworkMatchMakingSTEAM.EMPTY_PLAYER_INFO
		end
	end

	players_data[1] = host_level .. "," .. host_class .. "," .. host_name .. "," .. host_nationality

	return players_data
end

function NetworkMatchMakingSTEAM:remove_player_info(peer_id)
	if self._lobby_attributes then
		self._lobby_attributes["players_info_" .. peer_id] = NetworkMatchMakingSTEAM.EMPTY_PLAYER_INFO

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingSTEAM:add_player_info(peer_id)
	if self._lobby_attributes then
		local players_info = NetworkMatchMakingSTEAM.EMPTY_PLAYER_INFO
		local player_data = self._lobby_attributes["players_info_" .. peer_id]

		if managers.network and managers.network:session() and managers.network:session():all_peers() then
			local peer_data = managers.network:session():all_peers()[peer_id]

			if peer_data then
				local peer_level = peer_data:level() or ""
				local peer_class = managers.network:session():all_peers()[peer_id]:blackmarket_outfit().skills or ""
				local peer_name = string.gsub(peer_data:name() or "", ",", "")
				local peer_nationality = peer_data:character() or ""
				players_info = peer_level .. "," .. peer_class .. "," .. peer_name .. "," .. peer_nationality
			end
		end

		self._lobby_attributes["players_info_" .. peer_id] = players_info

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingSTEAM:set_server_state(state)
	if self._lobby_attributes then
		local state_id = tweak_data:server_state_to_index(state)
		self._lobby_attributes.state = state_id

		if state_id == 3 and not managers.raid_job:current_job() then
			self._lobby_attributes.state = 1
		end

		if self.lobby_handler then
			self.lobby_handler:set_lobby_data(self._lobby_attributes)
		end

		managers.network:session():chk_server_joinable_state()
	end
end

function NetworkMatchMakingSTEAM:set_server_joinable(state)
	if state == self._server_joinable then
		return
	end

	self._server_joinable = state

	if self.lobby_handler then
		self.lobby_handler:set_joinable(state)
	end
end

function NetworkMatchMakingSTEAM:is_server_joinable()
	return self._server_joinable
end

function NetworkMatchMakingSTEAM:server_state_name()
	return tweak_data:index_to_server_state(self._lobby_attributes.state)
end

function NetworkMatchMakingSTEAM:set_attributes(settings)
	if not self.lobby_handler then
		return
	end

	local permissions = {
		"public",
		"friend",
		"private"
	}
	local lobby_attributes = {
		owner_name = managers.network.account:username_id(),
		owner_id = managers.network.account:player_id(),
		custom_text = Global.game_settings.custom_text or "",
		level = settings.numbers[1],
		difficulty = settings.numbers[2],
		permission = settings.numbers[3],
		state = settings.numbers[4] or self._lobby_attributes and self._lobby_attributes.state or 1,
		min_level = settings.numbers[7] or 0,
		num_players = self._num_players or 1,
		drop_in = settings.numbers[6] or 1,
		job_id = settings.numbers[14] or 0,
		kick_option = settings.numbers[8] or 0,
		job_class_min = settings.numbers[9] or 10,
		job_class_max = settings.numbers[9] or 10,
		job_plan = settings.numbers[10],
		region = settings.numbers[11],
		challenge_card_id = settings.numbers[12],
		progress = settings.numbers[15],
		mission_type = settings.numbers[16],
		players_info_1 = settings.numbers[17],
		players_info_2 = settings.numbers[18],
		players_info_3 = settings.numbers[19],
		players_info_4 = settings.numbers[20]
	}

	if self._BUILD_SEARCH_INTEREST_KEY then
		lobby_attributes[self._BUILD_SEARCH_INTEREST_KEY] = "true"
	end

	self._lobby_attributes = lobby_attributes

	self.lobby_handler:set_lobby_data(lobby_attributes)
	self.lobby_handler:set_lobby_type(permissions[settings.numbers[3]])
end

function NetworkMatchMakingSTEAM:_lobby_to_numbers(lobby)
	return {
		lobby:key_value("level"),
		tonumber(lobby:key_value("difficulty")),
		tonumber(lobby:key_value("permission")),
		tonumber(lobby:key_value("state")),
		tonumber(lobby:key_value("num_players")),
		tonumber(lobby:key_value("drop_in")),
		tonumber(lobby:key_value("min_level")),
		tonumber(lobby:key_value("kick_option")),
		tonumber(lobby:key_value("job_class")),
		tonumber(lobby:key_value("job_plan")),
		tonumber(lobby:key_value("region")),
		lobby:key_value("challenge_card_id"),
		lobby:key_value("players_info"),
		lobby:key_value("job_id"),
		lobby:key_value("progress"),
		lobby:key_value("mission_type"),
		lobby:key_value("players_info_1"),
		lobby:key_value("players_info_2"),
		lobby:key_value("players_info_3"),
		lobby:key_value("players_info_4")
	}
end

function NetworkMatchMakingSTEAM:from_host_lobby_re_opened(status)
	print("[NetworkMatchMakingSTEAM::from_host_lobby_re_opened]", self._try_re_enter_lobby, status)

	if self._try_re_enter_lobby == "asked" then
		if status then
			self._try_re_enter_lobby = "open"
		else
			self._try_re_enter_lobby = nil

			managers.network.matchmake:leave_game()
		end
	end
end
