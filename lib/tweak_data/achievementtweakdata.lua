AchievementTweakData = AchievementTweakData or class()

function AchievementTweakData:init(tweak_data)
	self.levels = {
		{
			level = 2,
			achievement = "ach_reach_level_2"
		},
		{
			level = 5,
			achievement = "ach_reach_level_5"
		},
		{
			level = 10,
			achievement = "ach_reach_level_10"
		},
		{
			level = 20,
			achievement = "ach_reach_level_20"
		},
		{
			level = 30,
			achievement = "ach_reach_level_30"
		},
		{
			level = 40,
			achievement = "ach_reach_level_40"
		}
	}
end
