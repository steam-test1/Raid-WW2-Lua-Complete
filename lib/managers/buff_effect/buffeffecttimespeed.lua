BuffEffectTimeSpeed = BuffEffectTimeSpeed or class(BuffEffect)

function BuffEffectTimeSpeed:init(effect_name, value, challenge_card_key, fail_message, params)
	BuffEffectTimeSpeed.super.init(self, effect_name, value, challenge_card_key, fail_message, params)

	local effect_params = clone(tweak_data.timespeed.buff_effect)
	effect_params.speed = value

	managers.time_speed:play_effect(self.challenge_card_key, effect_params)
end

function BuffEffectTimeSpeed:destroy()
	managers.time_speed:stop_effect(self.challenge_card_key)
end

function BuffEffectTimeSpeed:save()
	local state = BuffEffectTimeSpeed.super.save(self)
	state.effect_class = "BuffEffectTimeSpeed"

	return state
end
