PlayerSound = PlayerSound or class()

-- Lines 3-22
function PlayerSound:init(unit)
	self._unit = unit

	unit:base():post_init()

	local ss = unit:sound_source()

	ss:set_switch("robber", "rb3")

	if unit:base().is_local_player then
		ss:set_switch("actor_switch", "first")
	else
		ss:set_switch("actor_switch", "third")
	end

	self._queue = {}
end

-- Lines 25-26
function PlayerSound:destroy(unit)
end

-- Lines 30-42
function PlayerSound:_play(sound_name, source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	local event = self._unit:sound_source(source):post_event(sound_name, self.sound_callback, self._unit, "marker", "end_of_event")

	return event
end

-- Lines 46-59
function PlayerSound:sound_callback(instance, event_type, unit, sound_source, label, identifier, position)
	if not alive(unit) then
		return
	end

	if event_type == "end_of_event" then
		unit:sound()._speaking = nil

		if unit:sound()._queue ~= nil and #unit:sound()._queue > 0 then
			unit:sound():say(unit:sound()._queue[1]._sound, unit:sound()._queue[1]._source, unit:sound()._queue[1]._sync)
			table.remove(unit:sound()._queue, 1)
		end
	end
end

-- Lines 63-65
function PlayerSound:queue_sound(id, sound_name, source_name, sync)
	table.insert(self._queue, {
		_id = id,
		_sound = sound_name,
		_source = source_name,
		_sync = sync
	})
end

-- Lines 67-69
function PlayerSound:clear_queue()
	self._queue = {}
end

-- Lines 73-92
function PlayerSound:play(sound_name, source_name, sync)
	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)
		source_name = source_name or ""

		self._unit:network():send("unit_sound_play", event_id, source_name)
	end

	local event = self:_play(sound_name or event_id, source_name)

	return event
end

-- Lines 96-102
function PlayerSound:stop(source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	self._unit:sound_source(source):stop()
end

-- Lines 106-114
function PlayerSound:play_footstep(foot, material_name)
	if self._last_material ~= material_name then
		self._last_material = material_name
		local material_name = tweak_data.materials[material_name:key()]

		self._unit:sound_source(Idstring("root")):set_switch("materials", material_name or "no_material")
	end

	local sound_name = self._unit:movement():running() and "footsteps_1p_run" or "footsteps_1p"

	self:_play(sound_name)
end

-- Lines 118-125
function PlayerSound:play_land(material_name)
	if self._last_material ~= material_name then
		self._last_material = material_name
		local material_name = tweak_data.materials[material_name:key()]

		self._unit:sound_source(Idstring("root")):set_switch("materials", material_name or "concrete")
	end

	self:_play("footstep_land_1p")
end

-- Lines 129-134
function PlayerSound:play_whizby(params)
	self:_play("whizby")
end

-- Lines 138-162
function PlayerSound:say(sound_name, important_say, sync)
	if self._last_speech and self._speaking and important_say == true then
		self._last_speech:stop()

		self._speaking = nil
	end

	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)

		self._unit:network():send("say", event_id)
	end

	if important_say == true or self._speaking == nil or self._speaking == false then
		self._last_speech = self:_play(sound_name or event_id, nil, true)
		self._speaking = true
	end

	return self._last_speech
end

-- Lines 166-168
function PlayerSound:speaking()
	return self._speaking
end

-- Lines 172-174
function PlayerSound:set_voice(voice)
	self._unit:sound_source():set_switch("robber", voice)
end

-- Lines 178-185
function PlayerSound:stop_speaking()
	if self._last_speech and self._speaking then
		self._last_speech:stop()

		self._speaking = nil
	end

	self:clear_queue()
end
