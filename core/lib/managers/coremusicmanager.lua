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

-- Lines 61-68
function CoreMusicManager:init_finalize()
end

-- Lines 70-71
function CoreMusicManager:init_globals()
end

-- Lines 73-75
function CoreMusicManager:music_tracks()
	return {}
end

-- Lines 77-91
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

-- Lines 95-98
function CoreMusicManager:stop()
	Global.music_manager.source:stop()

	Global.music_manager.current_event = nil
end

-- Lines 100-102
function CoreMusicManager:music_paths()
	return self._path_list
end

-- Lines 104-106
function CoreMusicManager:music_events(path)
	return self._event_map[path]
end

-- Lines 108-110
function CoreMusicManager:music_events_list()
	return self._event_list
end

-- Lines 112-114
function CoreMusicManager:music_path(event)
	return self._path_map[event]
end

-- Lines 117-124
function CoreMusicManager:set_volume(volume)
	Global.music_manager.volume = volume

	if self._has_music_control then
		SoundDevice:set_rtpc("option_music_volume", volume * 100)
	else
		SoundDevice:set_rtpc("option_music_volume", 0)
	end
end

-- Lines 127-136
function CoreMusicManager:clbk_game_has_music_control(status)
	print("[CoreMusicManager:clbk_game_has_music_control]", status)

	if status then
		SoundDevice:set_rtpc("option_music_volume", Global.music_manager.volume * 100)
	else
		SoundDevice:set_rtpc("option_music_volume", 0)
	end

	self._has_music_control = status
end

-- Lines 138-140
function CoreMusicManager:has_music_control()
	return self._has_music_control
end

-- Lines 143-153
function CoreMusicManager:save(data)
	local state = {}

	if game_state_machine:current_state_name() ~= "ingame_waiting_for_players" then
		state.event = Global.music_manager.current_event
	end

	state.track = Global.music_manager.current_track
	data.CoreMusicManager = state
end

-- Lines 155-162
function CoreMusicManager:load(data)
	local state = data.CoreMusicManager

	if state.event then
		self:post_event(state.event)
	end

	Global.music_manager.synced_track = state.track
end
