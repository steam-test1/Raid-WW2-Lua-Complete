EventsTweakData = EventsTweakData or class()
EventsTweakData.REWERD_TYPE_GOLD = "REWERD_TYPE_GOLD"

-- Lines 5-27
function EventsTweakData:init()
	self.active_duty_bonus_rewards = {
		{}
	}
	self.active_duty_bonus_rewards[1].reward = EventsTweakData.REWERD_TYPE_GOLD
	self.active_duty_bonus_rewards[1].amount = 1
	self.active_duty_bonus_rewards[2] = {
		reward = EventsTweakData.REWERD_TYPE_GOLD,
		amount = 1
	}
	self.active_duty_bonus_rewards[3] = {
		reward = EventsTweakData.REWERD_TYPE_GOLD,
		amount = 1
	}
	self.active_duty_bonus_rewards[4] = {
		reward = EventsTweakData.REWERD_TYPE_GOLD,
		amount = 2
	}
	self.active_duty_bonus_rewards[5] = {
		reward = EventsTweakData.REWERD_TYPE_GOLD,
		amount = 5
	}
end
