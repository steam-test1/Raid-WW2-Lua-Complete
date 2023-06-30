NetworkVoiceChatPSN = NetworkVoiceChatPSN or class()

-- Lines 29-47
function NetworkVoiceChatPSN:init()
	self._started = false
	self._room_id = nil
	self._team = 1
	self._restart_session = nil
	self._peers = {}

	self:_load_globals()

	self._muted_players = {}

	PSNVoice:set_voice_ui_update_callback(callback(self, self, "voice_ui_update_callback"))
	managers.menu_component:toggle_voice_chat_listeners(true)
end

-- Lines 49-50
function NetworkVoiceChatPSN:check_status_information()
end

-- Lines 52-53
function NetworkVoiceChatPSN:open()
end

-- Lines 55-57
function NetworkVoiceChatPSN:voice_type()
	return "voice_psn"
end

-- Lines 59-60
function NetworkVoiceChatPSN:pause()
end

-- Lines 62-63
function NetworkVoiceChatPSN:resume()
end

-- Lines 65-67
function NetworkVoiceChatPSN:set_volume(volume)
	PSNVoice:set_volume(volume / 100)
end

-- Lines 69-77
function NetworkVoiceChatPSN:init_voice()
	if self._started == false and not self._starting then
		self._starting = true

		PSNVoice:assign_callback(function (...)
			self:_callback(...)
		end)
		PSNVoice:init(4, 4, 50, 8000)
		self:set_volume(managers.user:get_setting("voice_volume"))

		self._started = true
	end
end

-- Lines 78-93
function NetworkVoiceChatPSN:destroy_voice(disconnected)
	if self._started == true then
		self._started = false

		if self._room_id and not disconnected then
			self:close_session()
		end

		PSNVoice:destroy()

		self._closing = nil
		self._room_id = nil
		self._restart_session = nil
		self._team = 1
	end
end

-- Lines 95-107
function NetworkVoiceChatPSN:num_peers()
	local l = PSNVoice:get_players_info()

	if l then
		local x = 0

		for k, v in pairs(l) do
			if v.joined == 1 then
				x = x + 1
			end
		end

		return x >= #l
	end

	return true
end

-- Lines 109-145
function NetworkVoiceChatPSN:open_session(roomid)
	if self._room_id and self._room_id == roomid then
		print("Voice: same_room")

		return
	end

	if self._restart_session and self._restart_session == roomid then
		print("Voice: restart")

		return
	end

	if self._closing or self._joining then
		print("Voice: closing|joining")

		self._restart_session = roomid

		return
	end

	if self._started == false then
		self._restart_session = roomid

		self:init_voice()
	end

	if self._room_id then
		print("Voice: restart room")

		return
	end

	self._room_id = roomid
	self._joining = true

	PSNVoice:start_session(roomid)
	self:update_settings()
end

-- Lines 147-168
function NetworkVoiceChatPSN:close_session()
	if self._joining then
		self._close = true

		return
	end

	if self._room_id and not self._closing then
		self._closing = true

		if not PSNVoice:stop_session() then
			self._closing = nil
			self._room_id = nil
			self._delay_frame = TimerManager:wall():time() + 1
		end
	elseif not self._closing then
		self._restart_session = nil
		self._delay_frame = nil
	end
end

-- Lines 170-173
function NetworkVoiceChatPSN:open_channel_to(player_info, context)
	print("[ VOICECHAT ] NetworkVoiceChatPSN:open_channel_to")
end

-- Lines 175-179
function NetworkVoiceChatPSN:close_channel_to(player_info)
	print("[ VOICECHAT ] NetworkVoiceChatPSN:close_channel_to")
	PSNVoice:stop_sending_to(player_info._name)
end

-- Lines 181-182
function NetworkVoiceChatPSN:lost_peer(peer)
end

-- Lines 184-192
function NetworkVoiceChatPSN:close_all()
	if self._room_id then
		self:close_session()
	end

	self._room_id = nil
	self._closing = nil
end

-- Lines 194-200
function NetworkVoiceChatPSN:set_team(team)
	if self._room_id then
		PSN:change_team(self._room_id, PSN:get_local_userid(), team)
		PSNVoice:set_team_target(team)
	end

	self._team = team
end

-- Lines 203-209
function NetworkVoiceChatPSN:clear_team()
	if self._room_id and PSN:get_local_userid() then
		PSN:change_team(self._room_id, PSN:get_local_userid(), 1)
		PSNVoice:set_team_target(1)

		self._team = 1
	end
end

-- Lines 214-216
function NetworkVoiceChatPSN:set_drop_in(data)
	self._drop_in = data
end

-- Lines 218-245
function NetworkVoiceChatPSN:_load_globals()
	if Global.psn and Global.psn.voice then
		self._started = Global.psn.voice.started
	end

	if PSN:is_online() and Global.psn and Global.psn.voice then
		PSNVoice:assign_callback(function (...)
		end)

		self._room_id = Global.psn.voice.room
		self._team = Global.psn.voice.team

		if Global.psn.voice.drop_in then
			self:open_session(Global.psn.voice.drop_in.room_id)
		end

		if Global.psn.voice.restart then
			self._restart_session = restart
			self._delay_frame = TimerManager:wall():time() + 2
		else
			PSNVoice:assign_callback(function (...)
				self:_callback(...)
			end)

			if self._room_id then
				self:set_team(self._team)
			end
		end

		Global.psn.voice = nil
	end
end

-- Lines 246-275
function NetworkVoiceChatPSN:_save_globals(disable_voice)
	if disable_voice == nil then
		return
	end

	if not Global.psn then
		Global.psn = {}
	end

	-- Lines 255-255
	local function f(...)
	end

	PSNVoice:assign_callback(f)

	Global.psn.voice = {
		started = self._started,
		drop_in = self._drop_in
	}

	if type(disable_voice) == "boolean" then
		if disable_voice == true then
			Global.psn.voice.room = self._room_id
			Global.psn.voice.team = self._team
		else
			Global.psn.voice.team = 1
		end
	else
		self:close_all()

		Global.psn.voice.restart = disable_voice
		Global.psn.voice.team = 1
	end
end

-- Lines 277-279
function NetworkVoiceChatPSN:enabled()
	return managers.user:get_setting("voice_chat")
end

-- Lines 282-289
function NetworkVoiceChatPSN:update_settings()
	local value = managers.user:get_setting("voice_chat")

	if value then
		self:soft_enable()
	else
		self:soft_disable()
	end
end

-- Lines 292-314
function NetworkVoiceChatPSN:set_recording(button_pushed_to_talk)
end

-- Lines 316-320
function NetworkVoiceChatPSN:soft_disable()
	PSNVoice:stop_recording()
	PSNVoice:set_enable(false)
	Application:trace("SOFT DISABLE VOICE CHAT!!")
end

-- Lines 322-331
function NetworkVoiceChatPSN:soft_enable()
	local enabled = managers.user:get_setting("voice_chat")

	if enabled then
		PSNVoice:set_enable(true)
		PSNVoice:start_recording()
		Application:trace("SOFT ENABLE VOICE CHAT!!")
	else
		self:soft_disable()
	end
end

-- Lines 333-336
function NetworkVoiceChatPSN:trc_check_mute()
	self:set_volume(0)
	PSNVoice:mute(true)
end

-- Lines 338-342
function NetworkVoiceChatPSN:trc_check_unmute()
	local voice_volume = math.clamp(managers.user:get_setting("voice_volume"), 0, 100)

	self:set_volume(voice_volume)
	PSNVoice:mute(false)
end

-- Lines 345-386
function NetworkVoiceChatPSN:_callback(info)
	if info and PSN:get_local_userid() then
		if info.load_succeeded ~= nil then
			self._starting = nil

			if info.load_succeeded then
				self._started = true
				self._delay_frame = TimerManager:wall():time() + 1
			end

			return
		end

		if info.join_succeeded ~= nil then
			self._joining = nil

			if info.join_succeeded == false then
				self._room_id = nil
			else
				self:set_team(self._team)
			end

			if self._restart_session then
				self._delay_frame = TimerManager:wall():time() + 1
			end

			if self._close then
				self._close = nil

				self:close_session()
			end
		end

		if info.leave_succeeded ~= nil then
			self._closing = nil
			self._room_id = nil

			if self._restart_session then
				self._delay_frame = TimerManager:wall():time() + 1
			end
		end

		if info.unload_succeeded ~= nil then
			-- Lines 382-382
			local function f(...)
			end

			PSNVoice:assign_callback(f)
		end
	end
end

-- Lines 388-398
function NetworkVoiceChatPSN:update()
	if self._delay_frame and self._delay_frame < TimerManager:wall():time() then
		self._delay_frame = nil

		if self._restart_session then
			PSNVoice:assign_callback(function (...)
				self:_callback(...)
			end)

			local r = self._restart_session
			self._restart_session = nil

			self:open_session(r)
		end
	end
end

-- Lines 401-410
function NetworkVoiceChatPSN:voice_ui_update_callback(user_info)
	if user_info and managers.network and managers.network:session() then
		managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.UPDATE_VOICE_CHAT_UI, {
			status_type = "talk",
			user_data = user_info
		})
	end
end

-- Lines 413-420
function NetworkVoiceChatPSN:psn_session_destroyed(roomid)
	if self._room_id and self._room_id == roomid then
		self._room_id = nil
		self._closing = nil
	end
end

-- Lines 423-436
function NetworkVoiceChatPSN:_get_peer_user_id(peer)
	if not self._room_id then
		return
	end

	local members = PSN:get_info_session(self._room_id).memberlist
	local name = peer:name()

	for i, member in ipairs(members) do
		if tostring(member.user_id) == name then
			return member.user_id
		end
	end
end

-- Lines 439-443
function NetworkVoiceChatPSN:on_member_added(peer, mute)
	if peer:rpc() then
		PSNVoice:on_member_added(peer:name(), peer:rpc(), mute)
	end
end

-- Lines 446-448
function NetworkVoiceChatPSN:on_member_removed(peer)
	PSNVoice:on_member_removed(peer:name())
end

-- Lines 451-463
function NetworkVoiceChatPSN:mute_player(peer, mute)
	self._muted_players[peer:name()] = mute

	PSNVoice:mute_player(mute, peer:name())

	local user_info = {
		user_name = peer:name(),
		state = mute
	}

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.UPDATE_VOICE_CHAT_UI, {
		status_type = "mute",
		user_data = user_info
	})
end

-- Lines 466-468
function NetworkVoiceChatPSN:is_muted(peer)
	return self._muted_players[peer:name()] or false
end
