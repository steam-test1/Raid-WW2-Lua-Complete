CopSound = CopSound or class()
CopSound.MAX_DISTANCE_FROM_PLAYER = 2500
CopSound.FOOTSTEP_COOLDOWN = 1.1
CopSound.VO_COOLDOWN = 2

-- Lines 7-23
function CopSound:init(unit)
	self._unit = unit
	self._speak_expire_t = 0
	self._footstep_expire_t = 0
	local char_tweak = tweak_data.character[unit:base()._tweak_table]

	self:set_voice_prefix(nil)

	local nr_variations = char_tweak.speech_prefix_count
	self._prefix = (char_tweak.speech_prefix_p1 or "") .. "_" .. (nr_variations and tostring(math.random(nr_variations)) or "") .. "_" .. (char_tweak.speech_prefix_p2 or "") .. "_"

	if self._unit:base():char_tweak().spawn_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event, nil, nil)
	end

	unit:base():post_init()
end

-- Lines 27-28
function CopSound:destroy(unit)
end

-- Lines 32-41
function CopSound:set_voice_prefix(index)
	local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
	local nr_variations = char_tweak.speech_prefix_count

	if index and (index < 1 or nr_variations < index) then
		debug_pause_unit(self._unit, "[CopSound:set_voice_prefix] Invalid prefix index:", index, ". nr_variations:", nr_variations)
	end

	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(index or math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"
end

-- Lines 46-64
function CopSound:_out_of_hearing_range()
	local player_unit = nil

	if game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
		player_unit = game_state_machine:current_state():currently_spectated_unit()
	else
		player_unit = managers.player:local_player()
	end

	if not player_unit then
		Application:error("[CopSound:_out_of_hearing_range]: Player unit is nil; couldn't determine the distance. The sound won't be played.")

		return true
	end

	local distance_vector = self._unit:position() - player_unit:position()

	return CopSound.MAX_DISTANCE_FROM_PLAYER < distance_vector:length()
end

-- Lines 68-83
function CopSound:_play(sound_name, source_name)
	if self:_out_of_hearing_range() then
		return
	end

	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	local event = self._unit:sound_source(source):post_event(sound_name)

	return event
end

-- Lines 87-103
function CopSound:play(sound_name, source_name, sync)
	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)
		local sync_source_name = source_name or ""

		self._unit:network():send("unit_sound_play", event_id, sync_source_name)
	end

	local event = self:_play(sound_name or event_id, source_name)

	return event
end

-- Lines 107-131
function CopSound:corpse_play(sound_name, source_name, sync)
	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)
		local sync_source_name = source_name or ""
		local u_id = self._unit:id()

		managers.network:session():send_to_peers_synched("corpse_sound_play", u_id, event_id, sync_source_name)
	end

	local event = self:_play(sound_name or event_id, source_name)

	if not event then
		Application:error("[CopSound:corpse_play] event not found in Wwise", sound_name, event_id, self._unit)
		Application:stack_dump("error")

		return
	end

	return event
end

-- Lines 135-141
function CopSound:stop(source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	self._unit:sound_source(source):stop()
end

-- Lines 145-176
function CopSound:say(sound_name, sync, skip_prefix)
	if self._last_speech then
		self._last_speech:stop()
	end

	local full_sound = nil

	if skip_prefix then
		full_sound = sound_name
	else
		full_sound = self._prefix .. sound_name
	end

	local event_id = nil

	if type(full_sound) == "number" then
		event_id = full_sound
		full_sound = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(full_sound)

		self._unit:network():send("say", event_id)
	end

	self._last_speech = self:_play(full_sound or event_id)

	if not self._last_speech then
		return
	end

	self._speak_expire_t = TimerManager:game():time() + CopSound.VO_COOLDOWN
end

-- Lines 180-185
function CopSound:sync_say_str(full_sound)
	if self._last_speech then
		self._last_speech:stop()
	end

	self._last_speech = self:play(full_sound)
end

-- Lines 189-191
function CopSound:speaking(t)
	return (t or TimerManager:game():time()) < self._speak_expire_t
end

-- Lines 195-197
function CopSound:playing_footsteps(t)
	return (t or TimerManager:game():time()) < self._footstep_expire_t
end

-- Lines 201-206
function CopSound:anim_clbk_play_sound(unit, queue_name)
	if not self:speaking() and not self:playing_footsteps() then
		self._footstep_expire_t = self._footstep_expire_t + CopSound.FOOTSTEP_COOLDOWN

		self:_play(queue_name)
	end
end
