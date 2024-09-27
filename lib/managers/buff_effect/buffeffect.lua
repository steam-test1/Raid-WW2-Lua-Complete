BuffEffect = BuffEffect or class()

function BuffEffect:init(effect_name, value, challenge_card_key, fail_message)
	self.effect_name = effect_name
	self.value = value
	self.challenge_card_key = challenge_card_key
	self.fail_message = fail_message
end
