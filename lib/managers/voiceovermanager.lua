VoiceOverManager = VoiceOverManager or class()

function VoiceOverManager:init()
	self:_setup()
end

function VoiceOverManager:_setup()
	self._disabled = false
	self._investigated = {}
	self._idle_timers = {
		rnd_delay = nil,
		delay = nil,
		cooldown = nil,
		delay = tweak_data.voiceover.idle_delay,
		rnd_delay = tweak_data.voiceover.idle_rnd_delay,
		cooldown = tweak_data.voiceover.idle_cooldown
	}
	self._idle_queue = {}
	self._idle_cooldowns = {}
	self._units_speaking = {}
end

function VoiceOverManager:update(t, dt)
	if self._disabled then
		return
	end

	if managers.groupai:state():is_police_called() then
		self:disable()
	end

	self:_update_idle_chatter()
end

function VoiceOverManager:_update_idle_chatter()
	local current_time = Application:time()

	for unit_key, data in pairs(self._idle_cooldowns) do
		local elapsed_time = current_time - data.started_at

		if self._idle_timers.cooldown <= elapsed_time then
			self._idle_cooldowns[unit_key] = nil

			if self._idle_queue[unit_key] then
				local time_offset = math.random(self._idle_timers.rnd_delay)
				self._idle_queue[unit_key] = {
					registered_at = nil,
					unit = nil,
					time_offset = nil,
					unit = self._idle_queue[unit_key].unit,
					registered_at = Application:time(),
					time_offset = time_offset
				}
			end
		end
	end

	for unit_key, data in pairs(self._idle_queue) do
		local elapsed_time = current_time - data.registered_at

		if elapsed_time > self._idle_timers.delay + data.time_offset and not self._idle_cooldowns[unit_key] then
			if alive(data.unit) and not data.unit:character_damage():dead() then
				self:_play_sound(data.unit, math.rand_bool() and "ste_idle" or "ste_patrol")

				self._idle_cooldowns[unit_key] = {
					started_at = nil,
					started_at = current_time
				}
			else
				self._idle_queue[unit_key] = nil
			end
		end
	end
end

function VoiceOverManager:guard_register_idle(source_unit)
	if self._disabled then
		return
	end

	local time_offset = math.random(self._idle_timers.rnd_delay)
	self._idle_queue[source_unit:key()] = {
		registered_at = nil,
		unit = nil,
		time_offset = nil,
		unit = source_unit,
		registered_at = Application:time(),
		time_offset = time_offset
	}
end

function VoiceOverManager:guard_unregister_idle(source_unit)
	if self._disabled then
		return
	end

	self._idle_queue[source_unit:key()] = nil
end

function VoiceOverManager:guard_investigate(source_unit)
	if self._disabled then
		return
	end

	if not self._investigated[source_unit:key()] then
		self._investigated[source_unit:key()] = Application:time()

		self:_play_sound(source_unit, "ste_investigate")
	else
		self:_play_sound(source_unit, "ste_investigateagain")
	end
end

function VoiceOverManager:guard_saw_something_ot(source_unit)
	if self._disabled then
		return
	end

	self:_play_sound(source_unit, "ste_sawsomethingot")
end

function VoiceOverManager:guard_saw_something_ut(source_unit)
	if self._disabled then
		return
	end

	self:_play_sound(source_unit, "ste_sawsomethingut")
end

function VoiceOverManager:guard_saw_enemy(source_unit)
	if self._disabled then
		return
	end

	self:_play_sound(source_unit, "ste_sawenemy")
end

function VoiceOverManager:guard_saw_body(source_unit)
	if self._disabled then
		return
	end

	self:_play_sound(source_unit, "ste_raisealarm")
end

function VoiceOverManager:guard_saw_bag(source_unit)
	if self._disabled then
		return
	end

	self:_play_sound(source_unit, "ste_raisealarm")
end

function VoiceOverManager:guard_raise_alarm(source_unit)
	self:_play_sound(source_unit, "ste_raisealarm")
end

function VoiceOverManager:guard_back_to_patrol(source_unit)
	if self._disabled then
		return
	end

	self:_play_sound(source_unit, "ste_investigateresult")
end

function VoiceOverManager:guard_found_coin(source_unit)
	if self._disabled then
		return
	end

	self:_play_sound(source_unit, "ste_coin_found")
end

function VoiceOverManager:enemy_reload(source_unit)
	self:_play_sound(source_unit, "reload", false)
end

function VoiceOverManager:_play_sound(source_unit, event)
	if self._disabled then
		return
	end

	if source_unit and source_unit:base()._char_tweak ~= nil and source_unit:base()._char_tweak.access == "teamAI1" then
		return
	end

	if alive(source_unit) and source_unit:sound() and not source_unit:sound():speaking() then
		source_unit:sound():say(event, true, false)
	end
end

function VoiceOverManager:on_simulation_ended()
	self:enable()
end

function VoiceOverManager:on_tweak_data_reloaded()
	self:_setup()
end

function VoiceOverManager:disable()
	Application:debug("[VoiceOverManager] disable")

	self._disabled = true
end

function VoiceOverManager:enable()
	Application:debug("[VoiceOverManager] enable")

	self._disabled = false
end
