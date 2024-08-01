EventsTweakData = EventsTweakData or class()
EventsTweakData.REWERD_TYPE_GOLD = "REWERD_TYPE_GOLD"
EventsTweakData.REWERD_TYPE_OUTLAW = "REWERD_TYPE_OUTLAW"
EventsTweakData.REWARD_ICON_SINGLE = "gold_bar_single"
EventsTweakData.REWARD_ICON_FEW = "gold_bar_3"
EventsTweakData.REWARD_ICON_MANY = "gold_bar_box"
EventsTweakData.REWARD_ICON_OUTLAW = "outlaw_raid_hud_item"

-- Lines 15-52
function EventsTweakData:init()
	self.active_duty_bonus_rewards = {
		{}
	}
	self.active_duty_bonus_rewards[1].reward = EventsTweakData.REWERD_TYPE_GOLD
	self.active_duty_bonus_rewards[1].icon = EventsTweakData.REWARD_ICON_SINGLE
	self.active_duty_bonus_rewards[1].amount = 5
	self.active_duty_bonus_rewards[2] = {
		reward = EventsTweakData.REWERD_TYPE_GOLD,
		icon = EventsTweakData.REWARD_ICON_FEW,
		amount = 10
	}
	self.active_duty_bonus_rewards[3] = {
		reward = EventsTweakData.REWERD_TYPE_GOLD,
		icon = EventsTweakData.REWARD_ICON_FEW,
		amount = 20
	}
	self.active_duty_bonus_rewards[4] = {
		reward = EventsTweakData.REWERD_TYPE_GOLD,
		icon = EventsTweakData.REWARD_ICON_MANY,
		amount = 30
	}
	self.active_duty_bonus_rewards[5] = {
		reward = EventsTweakData.REWERD_TYPE_OUTLAW,
		icon_outlaw = EventsTweakData.REWARD_ICON_OUTLAW,
		icon = EventsTweakData.REWARD_ICON_MANY,
		amount = 50
	}
end
