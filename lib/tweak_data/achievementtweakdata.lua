AchievementTweakData = AchievementTweakData or class()

-- Lines 3-15
function AchievementTweakData:init(tweak_data)
	self.levels = {
		{
			achievement = "ach_reach_level_2",
			level = 2
		},
		{
			achievement = "ach_reach_level_5",
			level = 5
		},
		{
			achievement = "ach_reach_level_10",
			level = 10
		},
		{
			achievement = "ach_reach_level_20",
			level = 20
		},
		{
			achievement = "ach_reach_level_30",
			level = 30
		},
		{
			achievement = "ach_reach_level_40",
			level = 40
		}
	}
end
