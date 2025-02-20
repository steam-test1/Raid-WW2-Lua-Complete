NetworkMatchMakingPSN = NetworkMatchMakingPSN or class()
NetworkMatchMakingPSN.OPEN_SLOTS = 4
NetworkMatchMakingPSN.MAX_SEARCH_RESULTS = 15
NetworkMatchMakingPSN.ERROR_CODE_ROOM_FULL = "ffffffff80550d19"
NetworkMatchMakingPSN.CLIENT_RETRY_DELAY = 1.9
NetworkMatchMakingPSN.LEVEL_INDEX = 1
NetworkMatchMakingPSN.STATE_ID = 4
NetworkMatchMakingPSN.NUMBER_OF_PLAYERS = 8
NetworkMatchMakingPSN.DIFFICULTY_ID = 9
NetworkMatchMakingPSN.GAME_VERSION = 13
NetworkMatchMakingPSN.JOB_INDEX = 15
NetworkMatchMakingPSN.CHALLENGE_CARD = 12
NetworkMatchMakingPSN.MISSION_TYPE = 16
NetworkMatchMakingPSN.PLAYERS_INFO_1 = 17
NetworkMatchMakingPSN.PLAYERS_INFO_2 = 18
NetworkMatchMakingPSN.PLAYERS_INFO_3 = 19
NetworkMatchMakingPSN.PLAYERS_INFO_4 = 20
NetworkMatchMakingPSN.PROGRESS = 21

function NetworkMatchMakingPSN:init()
	cat_print("lobby", "matchmake = NetworkMatchMakingPSN")

	self._players = {}
	self._TRY_TIME_INC = 10
	self._PSN_TIMEOUT_INC = 80
	self._JOIN_SERVER_TRY_TIME_INC = self._PSN_TIMEOUT_INC + 5
	self._room_id = nil
	self._join_cb_room = nil
	self._server_rpc = nil
	self._is_server_var = false
	self._is_client_var = false
	self._difficulty_filter = 0
	self._private = false
	self._callback_map = {}
	self._hidden = false
	self._server_joinable = true
	self._connection_info = {}
	self._lobby_filters = {}

	local function f(info)
		self:_error_cb(info)
	end

	PSN:set_matchmaking_callback("error", f)
	self:_load_globals()

	self._cancelled = false
	self._retry_join_time = nil
	self._retry_join_flag = false
	self._peer_join_request_remove = {}

	local function f(...)
		self:_custom_message_cb(...)
	end

	PSN:set_matchmaking_callback("custom_message", f)
	PSN:set_matchmaking_callback("invitation_received_result", callback(self, self, "_invitation_received_result_cb"))
	PSN:set_matchmaking_callback("join_invite_accepted_xmb", callback(self, self, "_xmb_join_invite_cb"))
	PSN:set_matchmaking_callback("play_together_host_event_receive", callback(self, self, "_play_together_host_event_receive_cb"))
	PSN:set_matchmaking_callback("worlds_fetched", callback(self, self, "_worlds_fetched_cb"))

	local function js(...)
		self:cb_connection_established(...)
	end

	PSN:set_matchmaking_callback("connection_etablished", js)
end

function NetworkMatchMakingPSN:_xmb_join_invite_cb(message)
	local function ok_func()
		if managers.network.account:signin_state() == "not signed in" then
			managers.network.account:show_signin_ui()
		end
	end

	managers.menu:show_invite_join_message({
		ok_func = ok_func
	})
end

function NetworkMatchMakingPSN:_start_time_out_check()
	self:_trigger_time_out_check()
end

function NetworkMatchMakingPSN:_trigger_time_out_check()
	if self._room_id then
		self._next_time_out_check_t = Application:time() + 4
		self._testing_connection = true
	else
		self._next_time_out_check_t = nil
	end
end

function NetworkMatchMakingPSN:_time_out_check_cb()
	self._last_alive_t = Application:time()
	self._testing_connection = nil
end

function NetworkMatchMakingPSN:_end_time_out_check()
	self._next_time_out_check_t = nil
	self._last_alive_t = nil
end

function NetworkMatchMakingPSN:_on_disconnect_detected()
	if managers.network:session() and managers.network:session():_local_peer_in_lobby() and not managers.network:session():closing() then
		managers.menu:psn_disconnected()
	elseif managers.network:session() then
		managers.network:session():psn_disconnected()
	elseif setup.IS_START_MENU then
		managers.menu:psn_disconnect(false)
	end
end

function NetworkMatchMakingPSN:_worlds_fetched_cb(...)
	print("_worlds_fetched_cb")

	if self._delayed_session_creation ~= nil then
		self._delayed_session_creation()
	end

	self._getting_world_list = nil

	managers.system_menu:close("get_world_list")

	if Global.boot_invite and Global.boot_invite.pending then
		managers.menu:open_sign_in_menu(function (success)
			if not success then
				return
			end

			self:join_boot_invite()
		end)
	end

	if Global.boot_play_together and Global.boot_play_together.pending then
		managers.menu:open_sign_in_menu(function (success)
			if not success then
				return
			end

			self:send_boot_play_together()
		end)
	end
end

function NetworkMatchMakingPSN:_getting_world_list_failed()
	print("failed_getting_world_list")
	managers.menu:back(true)
	managers.menu:show_no_connection_to_game_servers_dialog()
	self:_worlds_fetched_cb()
end

function NetworkMatchMakingPSN:getting_world_list()
	print("getting_world_list")

	self._getting_world_list = true

	managers.menu:show_get_world_list_dialog({
		cancel_func = callback(self, self, "_getting_world_list_failed")
	})
end

function NetworkMatchMakingPSN:_session_destroyed_cb(room_id, ...)
	print("NetworkMatchMakingPSN:_session_destroyed_cb", room_id, ...)
	cat_print("lobby", "NetworkMatchMakingPSN:_session_destroyed_cb")

	if room_id == self._room_id then
		if not self._is_server_var then
			managers.network:queue_stop_network()
			PSN:leave_session(self._room_id)

			self._room_id = nil

			self:leave_game()
		end

		self._room_id = nil

		if Network:is_client() and managers.network:session() and managers.network:session():server_peer() then
			if game_state_machine:current_state().on_server_left then
				Global.on_server_left_message = "dialog_connection_to_host_lost"

				game_state_machine:current_state():on_server_left()
			end
		elseif self._joining_lobby then
			self:_error_cb({
				error = "80022b13"
			})
		end
	end

	self._skip_destroy_cb = nil
end

function NetworkMatchMakingPSN:room_id()
	return self._room_id
end

function NetworkMatchMakingPSN:find_game(settings)
	self._last_settings = settings
	self._private = false
	self._cancelled = false
	self._TRY_TIME_INC = 10
	local world_list = PSN:get_world_list()

	if Global.psn_invite_id then
		Global.psn_invite_id = Global.psn_invite_id + 1

		if Global.psn_invite_id > 990 then
			Global.psn_invite_id = 1
		end
	end

	local function f(info)
		if info and #info.room_list > 0 then
			self:_try_servers(info.room_list)
		else
			self:_create_server()
		end
	end

	PSN:set_matchmaking_callback("session_search", f)

	local table_description = {}
	local attributes = {}
	local gt = {
		type = "GAME_NUM",
		value = self:_translate_settings(settings, "game_mode")
	}
	local priv = {
		type = "GAME_NUM",
		value = 1
	}
	attributes[1] = gt
	attributes[2] = priv
	table_description.attributes = attributes

	PSN:search_session(table_description, world_list[2].world_id)
end

function NetworkMatchMakingPSN:create_private_game(settings)
	self._cancelled = false
	self._private = true

	if Global.psn_invite_id then
		Global.psn_invite_id = Global.psn_invite_id + 1

		if Global.psn_invite_id > 990 then
			Global.psn_invite_id = 1
		end
	end

	self._last_settings = settings

	self:_create_server(true)
end

function NetworkMatchMakingPSN:cancel_find()
	self._cancelled = true
	self._is_server_var = false
	self._is_client_var = false
	self._players = {}
	self._server_rpc = nil
	self._try_list = nil
	self._try_index = nil
	self._trytime = nil

	self:_end_time_out_check()
	self:destroy_game()

	self._room_id = nil

	if not self._join_cb_room then
		self:_call_callback("cancel_done")
	else
		self._cancel_time = TimerManager:wall():time() + 10
	end
end

function NetworkMatchMakingPSN:remove_ping_watch()
	if self:_is_client() then
		if self._server_rpc then
			-- Nothing
		end
	else
		for k, v in pairs(self._players) do
			if v.rpc then
				-- Nothing
			end
		end
	end
end

function NetworkMatchMakingPSN:leave_game()
	if self.lobby_handler then
		self.lobby_handler:leave_lobby()
	end

	if self._room_id ~= nil then
		PSN:leave_session(self._room_id)

		self._room_id = nil
	end

	self.lobby_handler = nil
	self._server_joinable = true
	local sent = false

	self:remove_ping_watch()
	self:_end_time_out_check()

	self._no_longer_in_session = nil

	if self:_is_client() then
		if self._server_rpc then
			sent = true
		end
	else
		for k, v in pairs(self._players) do
			if v.rpc then
				sent = true
			end
		end
	end
end

function NetworkMatchMakingPSN:register_callback(event, callback)
	self._callback_map[event] = callback
end

function NetworkMatchMakingPSN:join_game(id, private)
	self._cancelled = false
	self._private = private or false
	local room = {
		room_id = PSN:convert_string_to_sessionid(id)
	}
	self._TRY_TIME_INC = 30

	self:_join_server(room)
end

function NetworkMatchMakingPSN:start_game()
	print("\nKrishna: NetworkMatchMakingPSN:start_game() => this method is commented out....")
end

function NetworkMatchMakingPSN:end_game()
end

function NetworkMatchMakingPSN:destroy_game()
	if self._room_id then
		self._no_longer_in_session = nil

		self:_end_time_out_check()

		if self:_is_client() then
			PSN:leave_session(self._room_id)
		else
			PSN:destroy_session(self._room_id)
		end

		self._room_id = nil
	else
		cat_print("multiplayer", "Dont got a room id!?")
	end
end

function NetworkMatchMakingPSN:is_game_owner()
	return self:_is_server() == true
end

function NetworkMatchMakingPSN:game_owner_name()
	return tostring(self._game_owner_id)
end

function NetworkMatchMakingPSN:is_full()
	if #self._players == self.OPEN_SLOTS - 1 then
		return true
	end

	return false
end

function NetworkMatchMakingPSN:get_mm_id(name)
	if name == managers.network.account:username() then
		return managers.network.account:player_id()
	else
		for k, v in pairs(self._players) do
			if v.name == name then
				return v.pnid
			end
		end
	end

	return nil
end

function NetworkMatchMakingPSN:user_in_lobby(id)
	if not self._room_id then
		return false
	end

	if not PSN:get_info_session(self._room_id) then
		return false
	end

	local memberlist = PSN:get_info_session(self._room_id).memberlist

	for _, member in ipairs(memberlist) do
		if member.user_id == id then
			return true
		end
	end

	return false
end

function NetworkMatchMakingPSN:psn_disconnected()
	self._no_longer_in_session = nil
	Global.boot_invite = nil

	if self._joining_lobby then
		self:_joining_lobby_done()
	end

	if self._searching_lobbys then
		self:search_lobby_done()
	end

	if self._creating_lobby then
		self:_create_lobby_done()
	end
end

function NetworkMatchMakingPSN:CheckMultiplayerFlag()
	if managers.network and managers.network:session() then
		local numPlayers = managers.network:session():amount_of_players()

		if numPlayers == 2 then
			if managers.network:session():chk_all_peers_spawned() then
				PSN:set_num_players(numPlayers)
			else
				PSN:set_num_players(1)
			end
		else
			PSN:set_num_players(numPlayers)
		end
	else
		PSN:set_num_players(1)
	end
end

function NetworkMatchMakingPSN:update(time)
	self:CheckMultiplayerFlag()

	if self._queue_end_game then
		self._queue_end_game = self._queue_end_game - 1

		if self._queue_end_game < 0 then
			print("EXITING FOR INVITE")

			self._queue_end_game = nil

			MenuCallbackHandler:_dialog_end_game_yes()
		end
	end

	if self._retry_join_flag and self._retry_join_time and self._retry_join_time < TimerManager:wall():time() then
		managers.network.matchmake._retry_join_time = nil
		managers.network.matchmake._retry_join_flag = false

		self:_retry_join()
	end

	if self._no_longer_in_session then
		if self._no_longer_in_session == 0 then
			if Network:is_client() and managers.network:session() and managers.network:session():server_peer() then
				if game_state_machine:current_state().on_server_left then
					Global.on_server_left_message = "dialog_connection_to_host_lost"

					game_state_machine:current_state():on_server_left()
				end
			elseif Network:is_server() and managers.network:session() and game_state_machine:current_state().on_disconnected then
				game_state_machine:current_state():on_disconnected()
			end

			self._no_longer_in_session = nil
		else
			self._no_longer_in_session = self._no_longer_in_session - 1
		end
	end

	if self._next_time_out_check_t then
		if self._last_alive_t and self._last_alive_t + self._PSN_TIMEOUT_INC < Application:time() then
			self._last_alive_t = nil

			self:_on_disconnect_detected()
		elseif self._next_time_out_check_t and self._next_time_out_check_t < Application:time() then
			self:_trigger_time_out_check()
		end
	end

	if self._trytime and self._trytime < TimerManager:wall():time() then
		self._trytime = nil

		print("self._trytime run out!", inspect(self))

		local is_server = self._is_server_var
		self._is_server_var = false
		self._is_client_var = false

		managers.platform:set_presence("Signed_in")

		self._players = {}
		self._server_rpc = nil

		if self._joining_lobby then
			self:_error_cb({
				error = "8002231d"
			})
		end

		if self._room_id then
			if not is_server then
				print(" LEAVE SESSION BECAUSE OF TIME OUT", self._room_id)
				self:leave_game()

				self._room_id = nil
				self._trytime = TimerManager:wall():time() + 5
			end
		elseif not self._last_settings then
			self:_call_callback("cancel_done")
		else
			self:_try_servers()
		end
	end

	if self._leave_time and self._leave_time < TimerManager:wall():time() then
		local closed = false

		if self._room_id then
			if not self._call_server_timed_out then
				self._leaving_timer = TimerManager:wall():time() + 10
			end

			if self:_is_client() then
				print("leave session HERE")

				closed = PSN:leave_session(self._room_id)
			else
				closed = PSN:destroy_session(self._room_id)
			end
		end

		self._players = {}
		self._game_owner_id = nil
		self._server_rpc = nil
		self._leave_time = nil
		self._is_client_var = false
		self._is_server_var = false

		if self._call_server_timed_out == true then
			self._call_server_timed_out = nil

			self:_call_callback("server_timedout")
		elseif closed == false then
			print("left game callback")
			managers.system_menu:close("leaving_game")

			if self._invite_room_id then
				self:join_server_with_check(self._invite_room_id, true)
			end

			self:_call_callback("left_game")
		end
	end

	if self._leaving_timer and self._leaving_timer < TimerManager:wall():time() then
		print("self._leaving_timer left_game")
		managers.system_menu:close("leaving_game")

		self._room_id = nil
		self._leaving_timer = nil

		self:_call_callback("left_game")
	end

	if self._cancel_time and self._cancel_time < TimerManager:wall():time() then
		self._cancel_time = nil
		self._join_cb_room = nil

		self:_call_callback("cancel_done")
	end

	if Global.boot_play_together and Global.boot_play_together.invite_send ~= true and Network:multiplayer() and managers.raid_job:is_camp_loaded() and Network:is_server() and not Global.game_settings.single_player then
		Global.boot_play_together.invite_send = true

		PSN:send_play_together_invite({})
	end
end

function NetworkMatchMakingPSN:_load_globals()
	if Global.psn and Global.psn.match then
		self._game_owner_id = Global.psn.match._game_owner_id
		self._room_id = Global.psn.match._room_id
		self._is_server_var = Global.psn.match._is_server
		self._is_client_var = Global.psn.match._is_client
		self._players = Global.psn.match._players
		self._server_rpc = Global.psn.match._server_ip and Network:handshake(Global.psn.match._server_ip, nil, "TCP_IP")
		self._attributes_numbers = Global.psn.match._attributes_numbers
		self._connection_info = Global.psn.match._connection_info
		self._hidden = Global.psn.match._hidden
		self._num_players = Global.psn.match._num_players
		self._lobby_filters = Global.psn.match.lobby_filters or self._lobby_filters
		Global.psn.match = nil

		self:_start_time_out_check()

		if self._room_id then
			local info_session = PSN:get_info_session(self._room_id)

			if not info_session or #info_session.memberlist == 0 then
				self._no_longer_in_session = 1
			end
		end
	end
end

function NetworkMatchMakingPSN:_save_globals()
	if not Global.psn then
		Global.psn = {}
	end

	Global.psn.match = {
		_game_owner_id = self._game_owner_id,
		_room_id = self._room_id,
		_is_server = self._is_server_var,
		_is_client = self._is_client_var,
		_players = self._players,
		_server_ip = self._server_rpc and self._server_rpc:ip_at_index(0),
		_attributes_numbers = self._attributes_numbers,
		_connection_info = self._connection_info,
		_hidden = self._hidden,
		_num_players = self._num_players,
		lobby_filters = self._lobby_filters
	}
end

function NetworkMatchMakingPSN:_call_callback(name, ...)
	if self._callback_map[name] then
		return self._callback_map[name](...)
	else
		Application:error("Callback " .. name .. " not found.")
	end
end

function NetworkMatchMakingPSN:_clear_psn_callback(cb)
	local function f()
	end

	PSN:set_matchmaking_callback(cb, f)
end

function NetworkMatchMakingPSN:psn_member_joined(info)
	print("psn_member_joined")
	print(inspect(info))

	if info and info.room_id == self._room_id then
		if not self._private then
			managers.network.voice_chat:open_session(self._room_id)
		end

		if info.user_id ~= managers.network.account:player_id() then
			local time_left = 10
		end
	end

	if Network:is_server() then
		self._peer_join_request_remove[tostring(info.user_id)] = nil

		print("   remove from remove list", tostring(info.user_id))
	end
end

function NetworkMatchMakingPSN:psn_member_left(info)
	if info and info.room_id == self._room_id then
		if info.user_id == managers.network.account:player_id() then
			print("IT WAS ME WHO LEFT")

			self._skip_destroy_cb = true
			self._connection_info = {}

			managers.platform:set_presence("Signed_in")
			managers.system_menu:close("leaving_game")

			if self._try_time then
				self._trytime = nil

				if not self._last_settings then
					self:_call_callback("cancel_done")
				end

				if self._invite_room_id then
					self:join_server_with_check(self._invite_room_id, true)
				end

				return
			end

			if self._leaving_timer then
				self._room_id = nil
				self._leaving_timer = nil

				self:_call_callback("left_game")

				if self._invite_room_id then
					self:join_server_with_check(self._invite_room_id, true)
				end

				return
			end
		else
			print("SOMEONE ELSE LEFT", info.user_id)

			local user_name = tostring(info.user_id)

			self:_remove_peer_by_user_id(info.user_id)
		end
	end
end

function NetworkMatchMakingPSN:_remove_peer_by_user_id(user_id)
	self._connection_info[user_id] = nil

	if not managers.network:session() then
		return
	end

	local user_name = tostring(user_id)

	for pid, peer in pairs(managers.network:session():peers()) do
		if peer:name() == user_name then
			print(" _remove_peer_by_user_id on_peer_left", peer:id(), pid)
			managers.network:session():on_peer_left(peer, pid)

			return
		end
	end

	if Network:is_server() then
		self._peer_join_request_remove[user_id] = true

		print("queue to remove if we get a request", user_id)
	end
end

function NetworkMatchMakingPSN:check_peer_join_request_remove(user_id)
	local has = self._peer_join_request_remove[user_id]
	self._peer_join_request_remove[user_id] = nil

	return has
end

function NetworkMatchMakingPSN:_is_server(set)
	if set == true or set == false then
		self._is_server_var = set
	else
		return self._is_server_var
	end
end

function NetworkMatchMakingPSN:_is_client(set)
	if set == true or set == false then
		self._is_client_var = set
	else
		return self._is_client_var
	end
end

function NetworkMatchMakingPSN:_game_version()
	return PSN:game_version()
end

function NetworkMatchMakingPSN:create_lobby(settings, return_to_camp_client)
	Application:debug("[NetworkMatchMakingPSN:create_lobby] A", inspect(settings))

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

	self._players = {}
	self._peer_join_request_remove = {}

	local function session_created(roomid)
		managers.network.matchmake:_created_lobby(roomid)
	end

	PSN:set_matchmaking_callback("session_created", session_created)
	self:set_server_attributes(settings)

	self._creating_lobby = true

	local function f()
		local world_list = PSN:get_world_list()

		if world_list ~= nil and world_list[1] ~= nil and world_list[1].world_id ~= nil then
			self._server_joinable = true
			self._server_rpc = nil

			PSN:create_session(self._attributes_numbers, world_list[1].world_id, 0, self.OPEN_SLOTS, 0)

			return true
		end

		return false
	end

	local success = f()

	if not success then
		Application:debug("[NetworkMatchMakingPSN:create_lobby] NOT success", success)

		self._delayed_session_creation = f
	end
end

function NetworkMatchMakingPSN:_create_lobby_failed()
	self:_create_lobby_done()
	print("\n Krishna: NetworkMatchMakingPSN:_create_lobby_failed() => MenuCallbackHandler:create_lobby()")
	MenuCallbackHandler:create_lobby()
end

function NetworkMatchMakingPSN:_create_lobby_done()
	self._creating_lobby = nil

	managers.system_menu:close("create_lobby")
end

function NetworkMatchMakingPSN:_created_lobby(room_id)
	self:_create_lobby_done()
	managers.menu:created_lobby()
	print("NetworkMatchMakingPSN:_created_lobby( room_id )", room_id)

	self._trytime = nil

	self:_is_server(true)
	self:_is_client(false)

	self._room_id = room_id

	if self._restart_in_camp then
		self._restart_in_camp = nil

		managers.platform:set_presence("Playing")
		managers.network:session():local_peer():set_synched(true)
		managers.network:session():local_peer():set_loaded(true)
		managers.network:session():spawn_players()
	end

	managers.network.voice_chat:open_session(self._room_id)

	local playerinfo = {
		name = managers.network.account:username(),
		player_id = managers.network.account:player_id(),
		rpc = Network:self("TCP_IP")
	}

	self:_call_callback("found_game", self._room_id, true)
	self:_call_callback("player_joined", playerinfo)
	self:_start_time_out_check()
end

function NetworkMatchMakingPSN:difficulty_filter()
	return self._difficulty_filter
end

function NetworkMatchMakingPSN:set_difficulty_filter(filter)
	self._difficulty_filter = filter
end

function NetworkMatchMakingPSN:set_search_friends_only(flag)
	self._search_friends_only = flag
end

function NetworkMatchMakingPSN:get_lobby_return_count()
	return self._lobby_return_count
end

function NetworkMatchMakingPSN:set_lobby_return_count(lobby_return_count)
	self._lobby_return_count = lobby_return_count
end

function NetworkMatchMakingPSN:lobby_filters()
	return self._lobby_filters
end

function NetworkMatchMakingPSN:set_lobby_filters(filters)
	self._lobby_filters = filters or {}
end

function NetworkMatchMakingPSN:add_lobby_filter(key, value, comparision_type)
	self._lobby_filters[key] = {
		key = key,
		value = value,
		comparision_type = comparision_type
	}
end

function NetworkMatchMakingPSN:get_lobby_filter(key)
	return self._lobby_filters[key] and self._lobby_filters[key].value or false
end

function NetworkMatchMakingPSN:_filter_out_the_host(info)
	local new_info = {
		attribute_list = {},
		room_list = {}
	}

	for i, room_info in ipairs(info.room_list) do
		local numbers = info.attribute_list[i].numbers
		local strings = info.attribute_list[i].strings
		local owner_id = room_info.owner_id
		local room_id = room_info.room_id

		if room_id ~= self._room_id then
			table.insert(new_info.attribute_list, {
				numbers = numbers,
				strings = strings
			})
			table.insert(new_info.room_list, {
				owner_id = owner_id,
				room_id = room_id
			})
		end
	end

	return new_info
end

function NetworkMatchMakingPSN:start_search_lobbys(friends_only)
	if self._searching_lobbys then
		return
	end

	self._searching_lobbys = true
	self._search_lobbys_index = 1
	self._lobbys_info_list = {}
	self._search_friends_only = friends_only

	if not self._search_friends_only then
		local function f(info)
			Application:trace("Krishna:\n NetworkMatchMakingPSN:start_search_lobbys() info: ", inspect(info))

			local new_info = self:_filter_out_the_host(info)

			table.insert(self._lobbys_info_list, new_info)

			if self._search_lobbys_index >= 1 then
				self:_call_callback("search_lobby", new_info)
			else
				self._search_lobbys_index = self._search_lobbys_index + self.MAX_SEARCH_RESULTS

				self:search_lobby()
			end
		end

		PSN:set_matchmaking_callback("session_search", f)
		self:search_lobby()
	else
		local function f(results, ...)
			local room_ids = {}
			local info = {
				attribute_list = {},
				request_id = 0,
				room_list = {}
			}
			local reverse_lookup = {}

			for i_user, user_info in ipairs(results.users) do
				if user_info.joined_sessions then
					local room_id = user_info.joined_sessions[1]

					table.insert(room_ids, room_id)

					local friend_id = user_info.user_id
					reverse_lookup[tostring(room_id)] = friend_id
				end
			end

			local function f2(results)
				if results.rooms then
					local info = {
						attribute_list = {},
						request_id = 0,
						room_list = {}
					}

					table.insert(self._lobbys_info_list, info)

					for _, room_info in ipairs(results.rooms) do
						local attributes = room_info.attributes
						local full = room_info.full
						local closed = room_info.closed
						local numbers = attributes.numbers
						local strings = attributes.strings
						local owner_id = room_info.owner
						local room_id = room_info.room_id
						local friend_id = reverse_lookup[tostring(room_id)]

						if not full and not closed and attributes.numbers[self.GAME_VERSION] == self:_game_version() then
							table.insert(info.attribute_list, {
								numbers = numbers,
								strings = strings
							})
							table.insert(info.room_list, {
								owner_id = owner_id,
								room_id = room_id
							})
						end
					end

					self:_call_callback("search_lobby", info)
				end
			end

			if #room_ids > 0 then
				self:_end_time_out_check()
				PSN:set_matchmaking_callback("fetch_session_attributes", f2)

				local wanted_attributes = {
					numbers = {
						1,
						2,
						3,
						4,
						5,
						6,
						7,
						8
					}
				}

				PSN:get_session_attributes(room_ids, wanted_attributes)
			else
				self:_call_callback("search_lobby", self._lobbys_info_list)
			end
		end

		local friends = managers.network.friends:get_npid_friends_list()

		PSN:set_matchmaking_callback("fetch_user_info", f)

		if #friends == 0 or not PSN:request_user_info(friends) then
			self:_call_callback("search_lobby", self._lobbys_info_list)
		end
	end
end

function NetworkMatchMakingPSN:search_lobby(friends_only)
	self._search_friends_only = friends_only
	local table_description = {
		numbers = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8
		},
		strings = {
			1,
			2
		}
	}
	local filter = {
		full = false,
		numbers = {
			{
				7,
				"==",
				self:_game_version()
			}
		}
	}

	if self._lobby_filters.job_id and self._lobby_filters.job_id.value ~= -1 then
		table.insert(filter.numbers, {
			1,
			"==",
			tweak_data.levels:get_index_from_name_id(self._lobby_filters.job_id.value)
		})
	end

	if self._difficulty_filter and self._difficulty_filter ~= 0 then
		table.insert(filter.numbers, {
			5,
			"==",
			self._difficulty_filter
		})
	end

	local world_list = PSN:get_world_list()

	if world_list ~= nil and world_list[1] ~= nil then
		PSN:search_session(table_description, filter, world_list[1].world_id, self._search_lobbys_index, self.MAX_SEARCH_RESULTS, true)
	end
end

function NetworkMatchMakingPSN:_search_lobby_failed()
	self:search_lobby_done()
end

function NetworkMatchMakingPSN:searching_lobbys()
	return self._searching_lobbys
end

function NetworkMatchMakingPSN:search_lobby_done()
	self._searching_lobbys = nil

	managers.system_menu:close("find_server")
end

function NetworkMatchMakingPSN:set_num_players(num)
	self._num_players = num

	if self._attributes_numbers then
		self:_set_attributes()
	end
end

function NetworkMatchMakingPSN:search_friends_only()
	return self._search_friends_only
end

function NetworkMatchMakingPSN:distance_filter()
	return self._distance_filter
end

function NetworkMatchMakingPSN:set_distance_filter(filter)
	self._distance_filter = filter
end

function NetworkMatchMakingPSN:set_job_info_by_current_job()
	local level_id, job_id, progress, mission_type, server_state_id = managers.network.matchmake:get_job_info_by_current_job()

	if self._lobby_attributes then
		self._lobby_attributes.level = level_id
		self._lobby_attributes.job_id = job_id
		self._lobby_attributes.progress = progress
		self._lobby_attributes.mission_type = mission_type
		self._lobby_attributes.state = server_state_id

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingPSN:set_challenge_card_info()
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

function NetworkMatchMakingPSN:get_job_info_by_current_job()
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

function NetworkMatchMakingPSN:get_all_players_info()
	local host_level = managers.experience:current_level() or "-"
	local host_class = managers.skilltree:get_character_profile_class() or "-"
	local host_name = managers.network.account:username()
	local host_nationality = Global.player_manager.character_profile_nation
	local players_data = host_level .. "," .. host_class .. "," .. host_name .. "," .. host_nationality .. ";"
	local peer_id = 0

	for peer_id = 2, 4 do
		if managers.network and managers.network:session() and managers.network:session():all_peers() then
			local peer_data = managers.network:session():all_peers()[peer_id]

			if peer_data then
				local peer_level = peer_data:level() or "-"
				local peer_class = peer_data:class() or "-"
				local peer_name = peer_data:name() or ""
				local peer_nationality = peer_data:nationality() or ""
				players_data = players_data .. peer_level .. "," .. peer_class .. "," .. peer_name .. "," .. peer_nationality .. ";"
			else
				players_data = players_data .. "-,-,-,-;"
			end
		else
			players_data = players_data .. "-,-;"
		end
	end

	return string.split(players_data, ";")
end

function NetworkMatchMakingPSN:remove_player_info(peer_id)
	if self._lobby_attributes and self._lobby_attributes.players_info then
		local players_info = ""
		local player_data = string.split(self._lobby_attributes.players_info, ";")

		for index, data in pairs(player_data) do
			if index == peer_id then
				players_info = players_info .. "-,-;"
			else
				local peer_data = string.split(data, ",")

				if peer_data[1] and peer_data[2] then
					players_info = players_info .. peer_data[1] .. "," .. peer_data[2] .. ";"
				else
					players_info = players_info .. "-,-;"
				end
			end
		end

		self._lobby_attributes.players_info = players_info

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingPSN:add_player_info(peer_id)
	if self._lobby_attributes and self._lobby_attributes.players_info then
		local players_info = ""
		local player_data = string.split(self._lobby_attributes.players_info, ";")

		for index, data in pairs(player_data) do
			if index == peer_id then
				if managers.network and managers.network:session() and managers.network:session():all_peers() then
					local peer_data = managers.network:session():all_peers()[peer_id]
					local peer_level = managers.network:session():all_peers()[peer_id]:level()
					local peer_class = "-"
					players_info = players_info .. peer_class .. "," .. peer_level .. ";"
				else
					players_info = players_info .. "-,-;"
				end
			else
				local peer_data = string.split(data, ",")

				if peer_data[1] and peer_data[2] then
					players_info = players_info .. peer_data[1] .. "," .. peer_data[2] .. ";"
				else
					players_info = players_info .. "-,-;"
				end
			end
		end

		self._lobby_attributes.players_info = players_info

		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingPSN:_set_attributes(settings)
	if not self._room_id then
		return
	end

	self._attributes_numbers = settings and settings.numbers or self._attributes_numbers
	local numbers = self._attributes_numbers
	local S1 = ""

	if self._attributes_numbers[self.CHALLENGE_CARD] then
		S1 = self._attributes_numbers[self.CHALLENGE_CARD]
	end

	if self._attributes_numbers[self.PROGRESS] then
		S1 = S1 .. ";" .. self._attributes_numbers[self.PROGRESS]
	end

	local S2 = ""

	if self._attributes_numbers[self.PLAYERS_INFO_1] then
		S2 = self._attributes_numbers[self.PLAYERS_INFO_1]
	end

	if self._attributes_numbers[self.PLAYERS_INFO_2] then
		S2 = S2 .. ";" .. self._attributes_numbers[self.PLAYERS_INFO_2]
	end

	if self._attributes_numbers[self.PLAYERS_INFO_3] then
		S2 = S2 .. ";" .. self._attributes_numbers[self.PLAYERS_INFO_3]
	end

	if self._attributes_numbers[self.PLAYERS_INFO_4] then
		S2 = S2 .. ";" .. self._attributes_numbers[self.PLAYERS_INFO_4]
	end

	local strings = {
		S1,
		S2
	}
	local attributes = {
		numbers = numbers,
		strings = strings
	}

	PSN:set_session_attributes(self._room_id, attributes)
end

function NetworkMatchMakingPSN:set_server_attributes(settings)
	local mission_type = settings.numbers[16]
	local level_index = settings.numbers[1]

	if self._attributes_numbers == nil then
		self._attributes_numbers = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		}
	end

	self._attributes_numbers[self.LEVEL_INDEX] = level_index
	self._attributes_numbers[2] = 0
	self._attributes_numbers[3] = settings.numbers[3]
	self._attributes_numbers[5] = 0
	self._attributes_numbers[6] = settings.numbers[6]
	self._attributes_numbers[7] = settings.numbers[7]
	self._attributes_numbers[self.NUMBER_OF_PLAYERS] = self._num_players or 1
	self._attributes_numbers[self.DIFFICULTY_ID] = settings.numbers[2]
	self._attributes_numbers[self.CHALLENGE_CARD] = settings.numbers[12]
	self._attributes_numbers[self.GAME_VERSION] = self:_game_version()
	self._attributes_numbers[14] = 0
	self._attributes_numbers[self.JOB_INDEX] = settings.numbers[14]
	self._attributes_numbers[self.MISSION_TYPE] = mission_type
	self._attributes_numbers[self.PLAYERS_INFO_1] = settings.numbers[17]
	self._attributes_numbers[self.PLAYERS_INFO_2] = settings.numbers[18]
	self._attributes_numbers[self.PLAYERS_INFO_3] = settings.numbers[19]
	self._attributes_numbers[self.PLAYERS_INFO_4] = settings.numbers[20]
	self._attributes_numbers[self.PROGRESS] = settings.numbers[15]

	self:_set_attributes({
		numbers = self._attributes_numbers
	})
end

function NetworkMatchMakingPSN:set_server_state(state)
	if not self._room_id then
		return
	end

	local state_id = tweak_data:server_state_to_index(state)
	self._attributes_numbers[self.STATE_ID] = state_id

	self:_set_attributes({
		numbers = self._attributes_numbers
	})
end

function NetworkMatchMakingPSN:server_state_name()
	return tweak_data:index_to_server_state(self._attributes_numbers[self.STATE_ID])
end

function NetworkMatchMakingPSN:test_search()
	local function f(info)
		print(inspect(info))
		print(inspect(info.room_list[1]))
		print(inspect(info.room_list[1].owner_id))
		print(help(info.room_list[1].owner_id))
		print(inspect(info.room_list[1].room_id))
		print(help(info.room_list[1].room_id))
		print(inspect(PSN:get_info_session(info.room_list[1].room_id)))
	end

	PSN:set_matchmaking_callback("session_search", f)
end

function NetworkMatchMakingPSN:test_search_session()
	local search_params = {
		numbers = {
			1,
			2,
			3,
			4
		}
	}

	PSN:search_session(search_params, {}, PSN:get_world_list()[1].world_id)
end

function NetworkMatchMakingPSN:_custom_message_cb(message)
	print("_custom_message_cb")
	print(inspect(message.custom_table))
	print("message.sender", message.sender)
	print("message", inspect(message))

	if message.custom_table and message.custom_table.join_invite then
		if self._room_id == message.room_id then
			return
		end

		if message.custom_table.version ~= self:_game_version() then
			return
		end

		if (not self._game_owner_id or self._game_owner_id ~= message.sender) and not self._has_pending_invite then
			print("managers.platform:presence() ~= Idle", managers.platform:presence() ~= "Idle")

			if managers.platform:presence() ~= "Idle" then
				self:_recived_join_invite(message)
			end
		end

		if self._join_enable then
			-- Nothing
		end
	end
end

function NetworkMatchMakingPSN:_invitation_received_cb(message, ...)
	print("_invitation_received_cb")
	print(inspect(message.custom_table))
	print("message.sender", message.sender)
	print("message", inspect(message))
	print("...", inspect(...))
end

function NetworkMatchMakingPSN:_play_together_host_event_receive_cb(message)
	print("\n\n_play_together_host_event_receive")
	print("message", inspect(message))

	Global.boot_play_together = message
	Global.boot_play_together.invite_send = false

	if not Global.user_manager.user_index or not Global.user_manager.active_user_state_change_quit then
		print("BOOT UP INVITE")

		Global.boot_play_together.used = false
		Global.boot_play_together.pending = true
		Global.boot_play_together.invite_send = false

		return
	end

	if setup:has_queued_exec() then
		Global.boot_play_together.used = false
		Global.boot_play_together.pending = true
		Global.boot_play_together.invite_send = false

		return
	end

	if Network:multiplayer() and Network:is_client() and self._room_id then
		print("INGAME INVITE")

		Global.boot_invite = message
		Global.boot_play_together.used = false
		Global.boot_play_together.pending = true
		Global.boot_play_together.invite_send = false
		self._queue_end_game = 15

		return
	end

	local isInCamp = game_state_machine:current_state_name() == "ingame_standard"

	if isInCamp and Global.game_settings.single_player then
		Global.boot_play_together.used = false
		Global.boot_play_together.pending = true
		Global.boot_play_together.invite_send = false
		self._queue_end_game = 15

		return
	end

	managers.menu:open_sign_in_menu(function (success)
		if not success then
			return
		end

		self:_send_play_together_invite()
	end)
end

function NetworkMatchMakingPSN:_invitation_received_result_cb(message)
	print("_invitation_received_result_cb")
	print(inspect(message.custom_table))
	print("message.sender", message.sender)
	print("message", inspect(message))

	Global.boot_invite = message

	if not Global.user_manager.user_index or not Global.user_manager.active_user_state_change_quit then
		print("BOOT UP INVITE")

		Global.boot_invite = message
		Global.boot_invite.used = false
		Global.boot_invite.pending = true

		return
	end

	if managers.dlc:is_installing() then
		managers.menu:show_game_is_installing()

		return
	end

	if game_state_machine:current_state_name() ~= "menu_main" then
		print("INGAME INVITE")

		if self._room_id == message.room_id then
			Global.boot_invite.used = true
			Global.boot_invite.pending = false

			return
		end

		Global.boot_invite = message
		Global.boot_invite.used = false
		Global.boot_invite.pending = true
		self._queue_end_game = 15

		return
	end

	if setup:has_queued_exec() then
		Global.boot_invite.used = false
		Global.boot_invite.pending = true

		return
	end

	managers.menu:open_sign_in_menu(function (success)
		if not success then
			return
		end

		if not message.room_id or message.room_id:is_empty() then
			managers.menu:show_invite_wrong_room_message()

			return
		end

		print("SELF ", self._room_id, " INVITE ", message.room_id)

		if self._room_id == message.room_id then
			return
		end

		if message.version ~= self:_game_version() then
			managers.menu:show_invite_wrong_version_message()

			return
		end

		self:_join_invite_accepted(message.room_id)
	end)
end

function NetworkMatchMakingPSN:join_boot_invite()
	print("[NetworkMatchMakingPSN:join_boot_invite]", inspect(Global.boot_invite))

	if not Global.boot_invite.pending then
		return
	end

	Global.boot_invite.used = true
	Global.boot_invite.pending = false

	if managers.dlc:is_installing() then
		managers.menu:show_game_is_installing()

		return
	end

	local message = Global.boot_invite

	if not message then
		print("[NetworkMatchMakingPSN:join_boot_invite] PSN:get_boot_invitation failed")

		return
	end

	print("[NetworkMatchMakingPSN:join_boot_invite] message: ", message)

	for i, k in pairs(message) do
		print(i, k)
	end

	print("JSELF ", self._room_id, " INVITE ", message.room_id)

	if self._room_id == message.room_id then
		print("[NetworkMatchMakingPSN:join_boot_invite] we are already joined")

		return
	end

	if not message.room_id or message.room_id:is_empty() then
		managers.menu:show_invite_wrong_room_message()

		return
	end

	if message.version ~= self:_game_version() then
		print("[NetworkMatchMakingPSN:join_boot_invite] WRONG VERSION, INFORM USER")
		managers.menu:show_invite_wrong_version_message()

		return
	end

	Global.game_settings.single_player = false

	managers.network:psn_determine_voice(false)
	self:_join_invite_accepted(message.room_id)
end

function NetworkMatchMakingPSN:send_boot_play_together()
	print("[NetworkMatchMakingPSN:send_boot_play_together]", inspect(Global.boot_play_together))

	if not Global.boot_play_together.pending then
		return
	end

	Global.boot_play_together.used = true
	Global.boot_play_together.pending = false
	local message = Global.boot_play_together

	if not message then
		print("[NetworkMatchMakingPSN:send_boot_play_together] PSN:get_boot_invitation failed")

		return
	end

	print("[NetworkMatchMakingPSN:send_boot_play_together] message: ", message)

	for i, k in pairs(message) do
		print(i, k)
	end

	local isInCamp = game_state_machine:current_state_name() == "ingame_standard"

	if not isInCamp then
		Global.game_settings.single_player = false

		managers.network:psn_determine_voice(false)
	end

	self:_send_play_together_invite()
end

function NetworkMatchMakingPSN:_send_play_together_invite()
	print("_send_play_together_invite")

	Global.boot_play_together.used = true
	Global.boot_play_together.pending = false

	if managers.raid_job._play_tutorial ~= nil and managers.raid_job._play_tutorial == true then
		managers.menu:show_play_together_rejected_message()

		Global.boot_play_together.invite_send = true

		return
	end

	Global.game_settings.single_player = false

	if Network:multiplayer() and self._room_id then
		PSN:send_play_together_invite({})

		Global.boot_play_together.invite_send = true

		return
	end

	local isInCamp = game_state_machine:current_state_name() == "ingame_standard"

	if not isInCamp then
		RaidMenuCallbackHandler:raid_play_online()
	end
end

function NetworkMatchMakingPSN:create_server(settings)
	self._last_settings = {
		game_mode = "coop"
	}

	self:_create_server()
end

function NetworkMatchMakingPSN:_create_server(private)
	Application:debug("[NetworkMatchMakingPSN:_create_server] private", private)

	local world_list = PSN:get_world_list()
	self._server_rpc = nil
	self._players = {}

	local function session_created(roomid)
		managers.network.matchmake:_create_server_cb(roomid)
	end

	PSN:set_matchmaking_callback("session_created", session_created)

	local table_description = {}
	local attributes = {}
	local gt = {
		type = "GAME_NUM",
		value = self:_translate_settings(self._last_settings, "game_mode")
	}
	local priv = {
		type = "GAME_NUM"
	}

	if private and private == true then
		priv.value = 2
	else
		priv.value = 1
	end

	attributes[1] = gt
	attributes[2] = priv
	table_description.attributes = attributes

	PSN:create_session(table_description, world_list[1].world_id, 0, self.OPEN_SLOTS, 0)
end

function NetworkMatchMakingPSN:_create_server_cb(roomid)
	self:_clear_psn_callback("connection_etablished")

	self._trytime = nil

	self:_is_server(true)
	self:_is_client(false)

	self._room_id = roomid
	local playerinfo = {
		name = managers.network.account:username(),
		player_id = managers.network.account:player_id(),
		rpc = Network:self("TCP_IP")
	}

	self:_call_callback("found_game", self._room_id, true)
	self:_call_callback("player_joined", playerinfo)
end

function NetworkMatchMakingPSN:_try_servers(list)
	if self._cancelled == true then
		return
	end

	if list then
		self._try_list = list
		self._try_index = 1

		managers.network.matchmake:_join_server(self._try_list[self._try_index])

		return
	elseif self._try_list and self._try_index < #self._try_list then
		self._try_index = self._try_index + 1

		managers.network.matchmake:_join_server(self._try_list[self._try_index])

		return
	end

	self._try_list = nil
	self._try_index = nil
	self._trytime = nil

	self:_create_server()
end

function NetworkMatchMakingPSN:is_server_ok(friends_only, owner_id, attributes_numbers, skip_permission_check)
	local permission = attributes_numbers and tweak_data:index_to_permission(attributes_numbers[3]) or "public"

	if (attributes_numbers[6] ~= 1 or not NetworkManager.DROPIN_ENABLED) and attributes_numbers[4] ~= 1 then
		print("[NetworkMatchMakingPSN:is_server_ok] Discard server due to drop in state")

		return false, 1
	end

	if managers.experience:current_level() < attributes_numbers[7] then
		print("[NetworkMatchMakingPSN:is_server_ok] Discard server due to reputation level limit")

		return false, 3
	end

	if friends_only then
		-- Nothing
	end

	if skip_permission_check or permission == "public" then
		return true
	end

	if permission == "friends_only" then
		if not managers.network.friends:is_friend(owner_id) then
			print("[NetworkMatchMakingPSN:is_server_ok] Discard server cause friends only perimssion")
		end

		return managers.network.friends:is_friend(owner_id), 2
	end

	print("[NetworkMatchMakingPSN:is_server_ok] Discard server")

	return false, 2
end

function NetworkMatchMakingPSN:check_server_attributes_failed()
	self:check_server_attributes_done()
end

function NetworkMatchMakingPSN:check_server_attributes_done()
	self._checking_server_attributes = nil
	self._check_room_id = nil
end

function NetworkMatchMakingPSN:join_server_with_check(room_id, skip_permission_check)
	if managers.network == nil then
		managers.menu:show_ok_only_dialog("dialog_error_title")

		return
	end

	if managers.network:session() and managers.network:session():has_other_peers() > 0 then
		managers.menu:show_ok_only_dialog("dialog_error_title", "dialog_err_cant_join_from_game")

		return
	end

	self._joining_lobby = true

	if not managers.system_menu:is_active_by_id("join_server") then
		managers.menu:show_joining_lobby_dialog()
	end

	self._check_room_id = room_id
	self._checking_server_attributes = true

	local function f(results)
		PSN:set_matchmaking_callback("fetch_session_attributes", function ()
		end)
		print("\nKrishna: fetch_session_attributes callback result => join_server() \n", inspect(results))

		local room_id = self._check_room_id

		self:check_server_attributes_done()

		if not results.rooms then
			self:join_server(room_id)

			return
		end

		local room_info = results.rooms[1]
		local attributes = room_info.attributes
		local owner_id = room_info.owner
		local server_ok, ok_error = self:is_server_ok(nil, owner_id, attributes.numbers, skip_permission_check)

		if server_ok then
			self:join_server(room_id)
		else
			self:_joining_lobby_done()

			if ok_error == 1 then
				managers.menu:show_game_started_dialog()
			elseif ok_error == 2 then
				managers.menu:show_game_permission_changed_dialog()
			elseif ok_error == 3 then
				managers.menu:show_too_low_level()
			elseif ok_error == 4 then
				managers.menu:show_does_not_own_heist()
			end

			managers.network.matchmake:start_search_lobbys(self._search_friends_only)
		end
	end

	self:_end_time_out_check()
	PSN:set_matchmaking_callback("fetch_session_attributes", f)

	local wanted_attributes = {
		numbers = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8
		}
	}

	PSN:get_session_attributes({
		room_id
	}, wanted_attributes)
end

function NetworkMatchMakingPSN:update_session_attributes(rooms, cb_func)
	if self._joining_lobby then
		cb_func(nil)

		return
	end

	if #rooms <= 0 then
		cb_func({})

		return
	end

	self._update_session_attributes_cb = cb_func

	self:_end_time_out_check()
	PSN:set_matchmaking_callback("fetch_session_attributes", callback(self, self, "_update_session_attributes_result"))

	local wanted_attributes = {
		numbers = {
			1,
			2,
			3,
			4,
			5,
			6,
			7,
			8
		}
	}

	PSN:get_session_attributes(rooms, wanted_attributes)
end

function NetworkMatchMakingPSN:_update_session_attributes_result(results)
	local info_list = {}
	local info = {
		attribute_list = {},
		request_id = 0,
		room_list = {}
	}

	table.insert(info_list, info)

	if results.rooms then
		for _, room_info in ipairs(results.rooms) do
			local attributes = room_info.attributes
			local full = room_info.full
			local closed = room_info.closed
			local owner_id = room_info.owner
			local room_id = room_info.room_id

			if not full and not closed and attributes.numbers[self.GAME_VERSION] == self:_game_version() then
				table.insert(info.attribute_list, attributes)
				table.insert(info.room_list, {
					owner_id = owner_id,
					room_id = room_id
				})
			end
		end
	end

	if self._room_id then
		self:_start_time_out_check()
	end

	if self._update_session_attributes_cb then
		self._update_session_attributes_cb(info_list)
	end
end

function NetworkMatchMakingPSN:join_server(room_id)
	local room = {
		room_id = room_id
	}

	self:_join_server(room)
end

function NetworkMatchMakingPSN:_join_server(room)
	self._connection_info = {}
	self._joining_lobby = true
	self._server_rpc = nil
	self._players = {}

	self:_is_server(false)
	self:_is_client(true)
	print("\nKrishna: NetworkMatchMakingPSN:_join_server()\n")
	print(inspect(room))

	self._room_id = room.room_id

	if not managers.system_menu:is_active_by_id("join_server") then
		managers.menu:show_joining_lobby_dialog()
	end

	self._join_cb_room = self._room_id

	if PSN:join_session(room.room_id, callback(self, self, "clbk_join_session_result")) then
		self._trytime = TimerManager:wall():time() + self._JOIN_SERVER_TRY_TIME_INC

		self:_start_time_out_check()
	else
		print("NetworkMatchMakingPSN:_join_server failed\n")
		managers.system_menu:close("join_server")
		managers.menu:show_failed_joining_dialog()
		PSN:leave_session(self._room_id)

		self._room_id = nil

		self:search_lobby(self:search_friends_only())
	end
end

function NetworkMatchMakingPSN:clbk_join_session_result(info)
	if not info.status then
		self:_end_time_out_check()
		self:_joining_lobby_done()

		if info.error == self.ERROR_CODE_ROOM_FULL then
			managers.menu:show_game_is_full()

			self._cancel_time = nil
			self._join_cb_room = nil

			self:_call_callback("cancel_done")
		elseif info.error == "ffffffff80550d13" or info.error == "ffffffff80550d15" or info.error == "ffffffff80550c30" then
			managers.menu:show_game_no_longer_exists()
		elseif info.error == "ffffffff80550d0f" then
			managers.menu:show_game_session_closed()
		else
			managers.menu:show_failed_joining_dialog()
		end

		PSN:leave_session(self._room_id)

		self._room_id = nil

		self:search_lobby(self:search_friends_only())
	end
end

function NetworkMatchMakingPSN:_joining_lobby_done_failed()
	self:_joining_lobby_done()
end

function NetworkMatchMakingPSN:_joining_lobby_done()
	managers.system_menu:close("join_server")

	self._joining_lobby = nil
end

function NetworkMatchMakingPSN:on_peer_added(peer)
	print("NetworkMatchMakingPSN:on_peer_added")
end

function NetworkMatchMakingPSN:on_peer_removed(peer)
	managers.network.voice_chat:close_channel_to(peer)
end

function NetworkMatchMakingPSN:_joined_game(res, level_index, difficulty_index, state_index)
	if res ~= "FAILED_CONNECT" or managers.network.matchmake._server_connect_retried and NetworkMatchMaking.RETRY_CONNECT_COUNT <= managers.network.matchmake._server_connect_retried then
		managers.system_menu:close("waiting_for_server_response")

		managers.network.matchmake._retry_join_time = nil
		managers.network.matchmake._retry_join_flag = false
	end

	if res == "JOINED_LOBBY" then
		if managers.groupai then
			managers.groupai:kill_all_AI()
		end

		managers.menu:on_enter_lobby()
	elseif res == "JOINED_GAME" then
		if managers.groupai then
			managers.groupai:kill_all_AI()
		end

		managers.network.voice_chat:set_drop_in({
			room_id = managers.network.matchmake:room_id()
		})

		local level_id = tweak_data.levels:get_level_name_from_index(level_index)
		Global.game_settings.level_id = level_id

		PSN:leave_user_created_session()
	elseif res == "KICKED" then
		managers.network.matchmake:_restart_network()
		managers.menu:show_peer_kicked_dialog()
	elseif res == "TIMED_OUT" or res == "AUTH_FAILED" or res == "AUTH_HOST_FAILED" then
		managers.network.matchmake:_restart_network()
		managers.menu:show_request_timed_out_dialog()
	elseif res == "FAILED_CONNECT" then
		if not managers.network.matchmake._server_connect_retried or managers.network.matchmake._server_connect_retried < NetworkMatchMaking.RETRY_CONNECT_COUNT then
			if not managers.network.matchmake._server_connect_retried then
				managers.network.matchmake._server_connect_retried = 1
			else
				managers.network.matchmake._server_connect_retried = managers.network.matchmake._server_connect_retried + 1
			end

			Application:debug("[NetworkMatchMakingPSN:join_server] Retry to connect!", managers.network.matchmake._server_connect_retried)

			managers.network.matchmake._retry_join_time = TimerManager:wall():time() + NetworkMatchMakingPSN.CLIENT_RETRY_DELAY
			managers.network.matchmake._retry_join_flag = true
		else
			Application:debug("[NetworkMatchMakingPSN:join_server] Fail to connect!")
			managers.network.matchmake:_restart_network()
			managers.menu:show_failed_joining_dialog()
		end
	elseif res == "GAME_STARTED" then
		managers.network.matchmake:_restart_network()
		managers.menu:show_game_started_dialog()
	elseif res == "DO_NOT_OWN_HEIST" then
		managers.network.matchmake:_restart_network()
		managers.menu:show_does_not_own_heist()
	elseif res == "CANCELLED" then
		-- Nothing
	elseif res == "GAME_FULL" then
		managers.network.matchmake:_restart_network()
		managers.menu:show_game_is_full()
	elseif res == "LOW_LEVEL" then
		managers.network.matchmake:_restart_network()
		managers.menu:show_too_low_level()
	elseif res == "WRONG_VERSION" then
		managers.network.matchmake:_restart_network()
		managers.menu:show_wrong_version_message()
	else
		Application:error("[NetworkMatchMakingPSN:connect_to_host_rpc] FAILED TO START MULTIPLAYER!")
	end

	World:set_extensions_update_enabled(true)
end

function NetworkMatchMakingPSN:_retry_join()
	Application:debug("[NetworkMatchMakingPSN:_retry_join]")
	managers.network:join_game_at_host_rpc(managers.network.matchmake._server_rpc, callback(self, self, "_joined_game"))
end

function NetworkMatchMakingPSN:cb_connection_established(info)
	if self._is_server_var then
		return
	end

	print("NetworkMatchMakingPSN:cb_connection_established")
	print(inspect(info))
	print("connection established to", info.user_id)

	self._connection_info[tostring(info.user_id)] = info

	if info.dead then
		managers.system_menu:close("join_server")

		if managers.network:session() then
			local peer = managers.network:session():peer_by_name(tostring(info.user_id))

			if peer then
				managers.network:session():on_peer_lost(peer, peer:id())
			else
				managers.menu:show_failed_joining_dialog()
			end
		end

		managers.network.matchmake:_restart_network()

		return
	end

	self._invite_room_id = nil

	if info.room_id == self._room_id and info.is_server == true then
		self:_joining_lobby_done()

		self._room_id = info.room_id
		self._game_owner_id = info.owner_id

		if info.external_ip and info.port then
			self._server_rpc = Network:handshake(info.external_ip, info.port, "TCP_IP")

			if not self._server_rpc then
				self._trytime = TimerManager:wall():time()

				return
			end
		else
			self._trytime = TimerManager:wall():time()

			return
		end

		self._trytime = nil

		managers.network:start_client()

		managers.network._restart_in_camp = managers.player and managers.player:local_player_in_camp()

		managers.network.voice_chat:open_session(self._room_id)
		managers.menu:show_waiting_for_server_response({
			cancel_func = function ()
				managers.network.matchmake._retry_join_time = nil
				managers.network.matchmake._retry_join_flag = false

				if managers.network:session() then
					managers.network:session():on_join_request_cancelled()
				end

				managers.network:queue_stop_network()
				managers.network.matchmake:_restart_network()
				World:set_extensions_update_enabled(true)
			end
		})

		managers.network.matchmake._server_connect_retried = nil

		managers.network:join_game_at_host_rpc(self._server_rpc, callback(self, self, "_joined_game"))
	elseif info and managers.network:session() then
		managers.network:session():on_PSN_connection_established(tostring(info.user_id), info.external_ip .. ":" .. info.port)
	end

	if self._join_cb_room and info.room_id == self._join_cb_room then
		if self._cancelled == true then
			self._cancel_time = nil

			self:_call_callback("cancel_done")
		end

		self._join_cb_room = nil
	end
end

function NetworkMatchMakingPSN:get_connection_info(npid_name)
	return self._connection_info[npid_name]
end

function NetworkMatchMakingPSN:_in_list(id)
	for k, v in pairs(self._players) do
		if tostring(v.pnid) == tostring(id) then
			return true
		end
	end

	return false
end

function NetworkMatchMakingPSN:_translate_settings(settings, value)
	if value == "game_mode" then
		local game_mode_in_settings = settings.game_mode

		if game_mode_in_settings == "coop" then
			return 1
		end

		Application:error("Not a supported game mode")
	end
end

function NetworkMatchMakingPSN:_error_cb(info)
	if info then
		print(" _error_cb")
		print(inspect(info))
		managers.system_menu:close("join_server")
		self:_error_message_solver(info)

		if info.error == "8002232c" then
			-- Nothing
		end

		if info.error ~= "8002233a" and info.error == "8002231d" then
			-- Nothing
		end

		if self._checking_server_attributes then
			self:check_server_attributes_failed()
		end

		if self._searching_lobbys then
			self:_search_lobby_failed()
		end

		if self._creating_lobby then
			self:_create_lobby_failed()
		end

		if self._joining_lobby then
			self:_joining_lobby_done_failed()
		end

		if info.error == "ffffffff80550c36" and setup.IS_START_MENU and not self._room_id then
			self:_on_disconnect_detected()
		end

		if self._getting_world_list then
			self:_getting_world_list_failed()
		end

		if (info.error == "80550d19" or info.error == "80550d0f" or info.error == "80550d15" or info.error == "80550d13") and not self._invite_room_id then
			managers.network.matchmake:start_search_lobbys(self._search_friends_only)
		end

		self._invite_room_id = nil

		if info.error == "80550d19" or info.error == "80550d0f" or info.error == "80022328" or info.error == "8002232c" or info.error == "80550d13" or info.error == "80550d15" and self._trytime then
			self._trytime = 0
			self._room_id = nil
		end
	end
end

function NetworkMatchMakingPSN:_error_message_solver(info)
	if info.error == "8002232c" or info.error == "ffffffff80550c3a" or info.error == "80550d0f" then
		return
	end

	if info.error == "8002233a" and self._testing_connection then
		self._testing_connection = nil

		return
	end

	local error_texts = {
		["80550D15"] = "dialog_err_failed_joining_lobby",
		["80022328"] = "dialog_err_room_allready_joined",
		["80550d13"] = "dialog_err_room_no_longer_exists",
		["80550d15"] = "dialog_err_room_no_longer_exists",
		["80550d19"] = "dialog_err_room_is_full",
		["80550C3A"] = "dialog_err_failed_joining_lobby",
		["80550c30"] = "dialog_err_room_no_longer_exists",
		["8002233a"] = self._creating_lobby and "dialog_err_failed_creating_lobby" or self._searching_lobbys and "dialog_err_failed_searching_lobbys" or self._joining_lobby and "dialog_err_failed_joining_lobby" or nil,
		["8002231d"] = self._creating_lobby and "dialog_err_failed_creating_lobby" or self._searching_lobbys and "dialog_err_failed_searching_lobbys" or self._joining_lobby and "dialog_err_failed_joining_lobby" or nil
	}
	local text_id = error_texts[info.error]
	local title = managers.localization:text("dialog_error_title")
	local dialog_data = {
		title = title,
		text = text_id and managers.localization:text(text_id) or managers.localization:text("system_msg_network_error") .. "\n[ " .. info.error .. " ]"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function NetworkMatchMakingPSN:_restart_network()
	Application:debug("[NetworkMatchMakingPSN:_restart_network()]", debug.traceback())

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

	if managers.game_play_central ~= nil then
		managers.game_play_central:restart_the_game()
	end
end

function NetworkMatchMakingPSN:send_join_invite(friend)
	if not self._room_id then
		return
	end

	local body = managers.localization:text("dialog_mp_invite_message")
	local len = string.len(body)

	for i = 1, 512 - len do
		body = body .. " "
	end

	PSN:send_message_gui({
		type = "INVITE",
		attachment = {
			version = self:_game_version(),
			room_id = self._room_id
		},
		body = body,
		subject = managers.localization:text("dialog_mp_invite_title"),
		list_npid = {
			tostring(friend)
		}
	})
end

function NetworkMatchMakingPSN:_recived_join_invite(message)
	self._has_pending_invite = true

	print("_recived_join_invite")

	local dialog_data = {
		title = managers.localization:text("dialog_mp_groupinvite_title"),
		text = managers.localization:text("dialog_mp_groupinvite_message", {
			GROUP = tostring(message.sender)
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_join_invite_accepted", message.room_id)
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = function ()
			self._has_pending_invite = nil
		end,
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function NetworkMatchMakingPSN:_join_invite_accepted(room_id)
	if managers.savefile:get_active_characters_count() < 1 then
		Global.boot_invite.used = true
		Global.boot_invite.pending = false

		managers.raid_menu:show_dialog_join_others_forbidden()

		return
	end

	if managers.raid_job._play_tutorial ~= nil and managers.raid_job._play_tutorial == true then
		Global.boot_invite.used = true
		Global.boot_invite.pending = false

		managers.menu:show_invite_rejected_message()

		return
	end

	print("_join_invite_accepted", room_id)

	Global.game_settings.single_player = false
	self._has_pending_invite = nil
	self._invite_room_id = room_id

	if self._room_id then
		print("MUST LEAVE ROOM")
		MenuCallbackHandler:_dialog_leave_lobby_yes()

		self._room_id = nil

		return
	end

	Global.boot_invite.used = true
	Global.boot_invite.pending = false

	managers.system_menu:force_close_all()
	self:join_server_with_check(room_id, true)
end

function NetworkMatchMakingPSN:_set_room_hidden(set)
	if set == self._hidden or not self._room_id then
		return
	end

	PSN:set_session_visible(self._room_id, not set)
	PSN:set_session_open(self._room_id, not set)

	self._hidden = set
end

function NetworkMatchMakingPSN:_server_timed_out(rpc)
end

function NetworkMatchMakingPSN:_client_timed_out(rpc)
	for k, v in pairs(self._players) do
		if v.rpc:ip_at_index(0) == rpc:ip_at_index(0) then
			return
		end
	end
end

function NetworkMatchMakingPSN:set_server_joinable(state)
	self._server_joinable = state

	self:_set_room_hidden(not state)
end

function NetworkMatchMakingPSN:is_server_joinable()
	return self._server_joinable
end
