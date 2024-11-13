BuffEffect = BuffEffect or class()

function BuffEffect:init(effect_name, value, challenge_card_key, fail_message, params)
	self.effect_name = effect_name
	self.value = value
	self.challenge_card_key = challenge_card_key
	self.fail_message = fail_message
end

function BuffEffect:save()
	local state = {
		name = nil,
		challenge_card_key = nil,
		value = nil,
		fail_message = nil,
		name = self.effect_name,
		value = self.value,
		challenge_card_key = self.challenge_card_key,
		fail_message = self.fail_message
	}

	return state
end
