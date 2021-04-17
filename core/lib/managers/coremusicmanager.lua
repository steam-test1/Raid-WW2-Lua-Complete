CoreMusicManager = CoreMusicManager or class()

-- Lines 3-59
function CoreMusicManager:init()
	if not Global.music_manager then
		Global.music_manager = {
			source = SoundDevice:create_source("music"),
			volume = 0
		}

		self:init_globals()
	end

	self._path_list = {}
	self._event_list = {}
	self._path_map = {}
	self._event_map = {}
	local temp_list = {}

	if Application:editor() then
		local music_tracks = self:music_tracks()

		for _, track in pairs(music_tracks) do
			local events = PackageManager:has(Idstring("bnk"), Idstring(track)) and SoundDevice:events(track)

			if events then
				for k, v in pairs(events) do
					if not temp_list[v.path] then
						temp_list[v.path] = 1

						table.insert(self._path_list, v.path)
					end

					self._path_map[k] = v.path

					if not self._event_map[v.path] then
						self._event_map[v.path] = {}
					end

					table.insert(self._event_map[v.path], k)
					table.insert(self._event_list, k)
				end
			end
		end

		table.sort(self._path_list)
		table.sort(self._event_list)

		for k, v in pairs(self._event_map) do
			table.sort(v)
		end
	end

	self._has_music_control = true
	self._external_media_playing = false
end

-- Lines 61-69
function CoreMusicManager:init_finalize()
	if SystemInfo:platform() == Idstring("X360") then
		self._has_music_control = XboxLive:app_has_playback_control()

		print("[CoreMusicManager:init_finalize]", self._has_music_control)
		managers.platform:add_event_callback("media_player_control", callback(self, self, "clbk_game_has_music_control"))
		self:set_volume(Global.music_manager.volume)
	end
end

-- Lines 71-72
function CoreMusicManager:init_globals()
end

-- Lines 74-76
function CoreMusicManager:music_tracks()
	return {}
end

-- Lines 78-92
function CoreMusicManager:post_event(name)
	if not name then
		return
	end

	if Global.music_manager.current_event ~= name then
		if not self._skip_play then
			Application:debug("[CoreMusicManager:post_event]", name)
			self:stop()

			Global.music_manager.current_wwise_event = Global.music_manager.source:post_event(name)
		end

		Global.music_manager.current_event = name
	end
end

-- Lines 96-99
function CoreMusicManager:stop()
	Global.music_manager.source:stop()

	Global.music_manager.current_event = nil
end

-- Lines 101-103
function CoreMusicManager:music_paths()
	return self._path_list
end

-- Lines 105-107
function CoreMusicManager:music_events(path)
	return self._event_map[path]
end

-- Lines 109-111
function CoreMusicManager:music_events_list()
	return self._event_list
end

-- Lines 113-115
function CoreMusicManager:music_path(event)
	return self._path_map[event]
end

-- Lines 118-125
function CoreMusicManager:set_volume(volume)
	Global.music_manager.volume = volume

	if self._has_music_control then
		SoundDevice:set_rtpc("option_music_volume", volume * 100)
	else
		SoundDevice:set_rtpc("option_music_volume", 0)
	end
end

-- Lines 128-137
function CoreMusicManager:clbk_game_has_music_control(status)
	print("[CoreMusicManager:clbk_game_has_music_control]", status)

	if status then
		SoundDevice:set_rtpc("option_music_volume", Global.music_manager.volume * 100)
	else
		SoundDevice:set_rtpc("option_music_volume", 0)
	end

	self._has_music_control = status
end

-- Lines 139-141
function CoreMusicManager:has_music_control()
	return self._has_music_control
end

-- Lines 144-154
function CoreMusicManager:save(data)
	local state = {}

	if game_state_machine:current_state_name() ~= "ingame_waiting_for_players" then
		state.event = Global.music_manager.current_event
	end

	state.track = Global.music_manager.current_track
	data.CoreMusicManager = state
end

-- Lines 156-163
function CoreMusicManager:load(data)
	local state = data.CoreMusicManager

	if state.event then
		self:post_event(state.event)
	end

	Global.music_manager.synced_track = state.track
end
