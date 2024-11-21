PlayerSound = PlayerSound or class()
PlayerSound.IDS_ROOT = Idstring("root")

function PlayerSound:init(unit)
	self._unit = unit

	unit:base():post_init()

	local ss = unit:sound_source()

	ss:set_switch("hero_switch", "amer")

	if unit:base().is_local_player then
		ss:set_switch("actor_switch", "first")
	else
		ss:set_switch("actor_switch", "third")
	end

	self._queue = {}
end

function PlayerSound:destroy(unit)
	self:clear_queue()
	self:stop()
end

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

function PlayerSound:stop(source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	self._unit:sound_source(source):stop()
end

function PlayerSound:_play(sound_name, source_name)
	local source = nil

	if source_name then
		source = Idstring(source_name)
	end

	local event = self._unit:sound_source(source):post_event(sound_name)

	return event
end

function PlayerSound:play_footstep(foot, material_name, pos)
	if self._last_material ~= material_name then
		self._last_material = material_name
		local material_name = tweak_data.materials[material_name:key()]

		self._unit:sound_source(PlayerSound.IDS_ROOT):set_switch("materials", material_name or "no_material")

		self._last_material_effect = material_name and tweak_data.materials_effects[material_name:key()] or nil
	end

	local sprinting = self._unit:movement():running()

	self:_play(sprinting and "footsteps_1p_run" or "footsteps_1p")

	local world_effect = self._last_material_effect and self._last_material_effect.step and World:effect_manager():spawn({
		effect = self._last_material_effect[sprinting and "sprint" or "step"],
		position = pos or self._unit:position(),
		rotation = self._unit:rotation()
	})
end

function PlayerSound:play_land(material_name, pos)
	if self._last_material ~= material_name then
		self._last_material = material_name
		local material_name = tweak_data.materials[material_name:key()]

		self._unit:sound_source(PlayerSound.IDS_ROOT):set_switch("materials", material_name or "concrete")

		self._last_material_effect = material_name and tweak_data.materials_effects[material_name:key()] or nil
	end

	self:_play("footstep_land_1p")

	local world_effect = self._last_material_effect and self._last_material_effect.land and World:effect_manager():spawn({
		effect = self._last_material_effect.land,
		position = pos or self._unit:position(),
		rotation = self._unit:rotation()
	})
end

function PlayerSound:play_melee(sound_name, material_name)
	if self._last_material ~= material_name then
		self._last_material = material_name

		self._unit:sound_source(PlayerSound.IDS_ROOT):set_switch("materials", material_name or "no_material")
	end

	if sound_name then
		self:_play(sound_name)
	end
end

function PlayerSound:play_whizby(params)
	self:_play("whizby")
end

function PlayerSound:say(sound_name, important_say, sync)
	if self._speaking and not important_say then
		return
	end

	if self._speaking == sound_name then
		return
	end

	if managers.dialog:is_unit_talking(self._unit) then
		Application:trace("[PlayerSound:say] can't talk while a dialog is already playing, skipping")

		return
	end

	self:stop_speaking(true)

	local event_id = nil

	if type(sound_name) == "number" then
		event_id = sound_name
		sound_name = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(sound_name)

		self._unit:network():send("say", event_id)
	end

	local ss = self._unit:sound_source()
	self._last_speech = ss:post_event(sound_name or event_id, callback(self, self, "sound_callback"), self._unit, "end_of_event")
	self._speaking = sound_name or event_id

	return self._last_speech
end

function PlayerSound:sound_callback(instance, event_type, unit, sound_source, label, identifier, position)
	self._speaking = nil

	if self._queue ~= nil and #self._queue > 0 then
		self:say(unpack(self._queue[1]))
		table.remove(self._queue, 1)
	end
end

function PlayerSound:queue_sound(id, sound_name, source_name, sync)
	table.insert(self._queue, {
		sound_name,
		source_name,
		sync,
		id
	})
end

function PlayerSound:clear_queue()
	self._queue = {}
end

function PlayerSound:speaking()
	return self._speaking
end

function PlayerSound:set_voice(voice)
	self._unit:sound_source():set_switch("hero_switch", voice)
end

function PlayerSound:stop_speaking(keep_queue)
	if self._last_speech and self._speaking then
		self._last_speech:stop()

		self._speaking = nil
	end

	if not keep_queue then
		self:clear_queue()
	end
end
