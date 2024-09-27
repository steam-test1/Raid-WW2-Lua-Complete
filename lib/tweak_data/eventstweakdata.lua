EventsTweakData = EventsTweakData or class()
EventsTweakData.REWARD_TYPE_GOLD = "REWARD_TYPE_GOLD"
EventsTweakData.REWARD_TYPE_OUTLAW = "REWARD_TYPE_OUTLAW"
EventsTweakData.REWARD_ICON_SINGLE = "gold_bar_single"
EventsTweakData.REWARD_ICON_FEW = "gold_bar_3"
EventsTweakData.REWARD_ICON_MANY = "gold_bar_box"
EventsTweakData.REWARD_ICON_OUTLAW = "outlaw_raid_hud_item"

function EventsTweakData:init()
	self.login_rewards = {
		active_duty = {
			{
				reward = nil,
				amount = 5,
				icon = nil,
				reward = EventsTweakData.REWARD_TYPE_GOLD,
				icon = EventsTweakData.REWARD_ICON_SINGLE
			},
			{
				reward = nil,
				amount = 10,
				icon = nil,
				reward = EventsTweakData.REWARD_TYPE_GOLD,
				icon = EventsTweakData.REWARD_ICON_FEW
			},
			{
				reward = nil,
				amount = 20,
				icon = nil,
				reward = EventsTweakData.REWARD_TYPE_GOLD,
				icon = EventsTweakData.REWARD_ICON_FEW
			},
			{
				reward = nil,
				amount = 30,
				icon = nil,
				reward = EventsTweakData.REWARD_TYPE_GOLD,
				icon = EventsTweakData.REWARD_ICON_MANY
			},
			{
				reward = nil,
				icon_outlaw = nil,
				amount = 50,
				icon = nil,
				reward = EventsTweakData.REWARD_TYPE_OUTLAW,
				icon_outlaw = EventsTweakData.REWARD_ICON_OUTLAW,
				icon = EventsTweakData.REWARD_ICON_MANY
			}
		}
	}
end
