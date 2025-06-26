TimeSpeedManager = TimeSpeedManager or class()

function TimeSpeedManager:init()
	self._pausable_timer = TimerManager:pausable()
	self._game_timer = TimerManager:game()
	self._game_anim_timer = TimerManager:game_animation()
	self._game_speed_rtpc = 1
end

function TimeSpeedManager:_update_timers(multiplier)
	SoundDevice:set_rtpc("game_speed", multiplier)

	for _, timer_info in pairs(self._affected_timers) do
		timer_info.timer:set_multiplier(multiplier)
	end
end

function TimeSpeedManager:play_effect(id, effect_desc)
	local effect = {
		desc = effect_desc
	}

	if effect_desc.affect_timer then
		if type(effect_desc.affect_timer) == "table" then
			effect.affect_timers = {}

			for _, timer_name in ipairs(effect_desc.affect_timer) do
				local timer = TimerManager:timer(Idstring(timer_name))
				effect.affect_timers[timer:key()] = timer
			end
		else
			local timer = TimerManager:timer(Idstring(effect_desc.affect_timer))
			effect.affect_timers = {
				[timer:key()] = timer
			}
		end
	else
		effect.affect_timers = {
			[self._game_timer:key()] = self._game_timer,
			[self._game_anim_timer:key()] = self._game_anim_timer
		}
	end

	self._affected_timers = self._affected_timers or {}

	for timer_key, affect_timer in pairs(effect.affect_timers) do
		if self._affected_timers[timer_key] then
			self._affected_timers[timer_key].ref_count = self._affected_timers[timer_key].ref_count + 1
		else
			self._affected_timers[timer_key] = {
				ref_count = 1,
				mul = 1,
				timer = affect_timer
			}
		end
	end

	self._active_effects = self._active_effects or {}
	self._active_effects[id] = effect

	self:_update_timers(effect_desc.speed)
end

function TimeSpeedManager:stop_effect(id, fade_out_duration)
	if not self._active_effects then
		return
	end

	self:_on_effect_expired(id)
end

function TimeSpeedManager:_on_effect_expired(effect_id)
	local effect = self._active_effects[effect_id]

	for timer_key in pairs(effect.affect_timers) do
		local timer_info = self._affected_timers[timer_key]
		timer_info.ref_count = timer_info.ref_count - 1

		if timer_info.ref_count == 0 then
			timer_info.timer:set_multiplier(1)

			self._affected_timers[timer_key] = nil
		end
	end

	self._active_effects[effect_id] = nil

	if not next(self._active_effects) then
		SoundDevice:set_rtpc("game_speed", 1)

		self._active_effects = nil
		self._affected_timers = nil
	end
end

function TimeSpeedManager:in_effect()
	return self._active_effects and true
end

function TimeSpeedManager:destroy()
	while self._active_effects do
		local eff_id = next(self._active_effects)

		self:_on_effect_expired(eff_id)
	end

	SoundDevice:set_rtpc("game_speed", 1)
end
