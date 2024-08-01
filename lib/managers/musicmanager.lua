MusicManager = MusicManager or class(CoreMusicManager)
MusicManager.CAMP_MUSIC = "music_camp"
MusicManager.MENU_MUSIC = "raid_music_menu_test"
MusicManager.CREDITS_MUSIC = "music_credits"
MusicManager.STOP_ALL_MUSIC = "stop_all_music"
MusicManager.RAID_MUSIC_START = "start"
MusicManager.RAID_MUSIC_STEALTH = "stealth"
MusicManager.RAID_MUSIC_ANTICIPATION = "anticipation"
MusicManager.RAID_MUSIC_CONTROL = "control"
MusicManager.RAID_MUSIC_ASSAULT = "assault"

-- Lines 16-19
function MusicManager:init()
	MusicManager.super.init(self)

	self._current_level_music = nil
end

-- Lines 21-25
function MusicManager:init_globals(...)
	MusicManager.super.init_globals(self, ...)
end

-- Lines 27-36
function MusicManager:raid_music_state_change(state_flag)
	Application:debug("[MusicManager:raid_music_state_change()]", state_flag)
	SoundDevice:set_state("raid_states", self:convert_music_state(state_flag))
end

-- Lines 38-47
function MusicManager:convert_music_state(state_flag)
	local res = state_flag

	if state_flag == MusicManager.RAID_MUSIC_START then
		res = MusicManager.RAID_MUSIC_STEALTH
	end

	return res
end

-- Lines 49-52
function MusicManager:save_settings(data)
	local state = {}
	data.MusicManager = state
end

-- Lines 54-59
function MusicManager:load_settings(data)
	local state = data.MusicManager

	if state then
		-- Nothing
	end
end

-- Lines 61-66
function MusicManager:save_profile(data)
	local state = {}
	data.MusicManager = state
end

-- Lines 68-73
function MusicManager:load_profile(data)
	local state = data.MusicManager

	if state then
		-- Nothing
	end
end

-- Lines 76-88
function MusicManager:get_random_event()
	local event_names = {}

	for name, data in pairs(tweak_data.music) do
		if name ~= "default" and data.include_in_shuffle then
			table.insert(event_names, name)
		end
	end

	local tweak_id = event_names[math.floor(math.rand(#event_names)) + 1]
	local event_name = tweak_data.music[tweak_id] and tweak_data.music[tweak_id].start

	Application:debug("[MusicManager:get_random_event()]", event_name)

	return event_name
end

-- Lines 90-110
function MusicManager:get_default_event()
	local tweak_id = Global.level_data and Global.level_data.level_id
	local job = managers.raid_job:current_job()

	if job then
		if job.job_type == OperationsTweakData.JOB_TYPE_RAID then
			tweak_id = job.music_id
		else
			tweak_id = managers.raid_job:current_operation_event().music_id
		end
	end

	local event_name = nil
	event_name = (tweak_id ~= "random" or self:get_random_event()) and tweak_data.music[tweak_id] and tweak_data.music[tweak_id].start

	Application:debug("[MusicManager:get_default_event()]", event_name)

	return event_name
end
