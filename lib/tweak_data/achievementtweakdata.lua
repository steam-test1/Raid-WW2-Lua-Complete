AchievementTweakData = AchievementTweakData or class()

function AchievementTweakData:init(tweak_data)
	self:_init_experience_awards()
	self:_init_mission_awards()
end

function AchievementTweakData:_init_experience_awards()
	self.experience = {
		{
			id = "ach_reach_level_2",
			level = 2
		},
		{
			id = "ach_reach_level_5",
			level = 5
		},
		{
			id = "ach_reach_level_10",
			level = 10
		},
		{
			id = "ach_reach_level_20",
			level = 20
		},
		{
			id = "ach_reach_level_30",
			level = 30
		},
		{
			id = "ach_reach_level_40",
			level = 40
		}
	}
end

function AchievementTweakData:_init_mission_awards()
	local very_hard = 4
	self.missions = {
		clear_skies = {
			{
				id = "ach_clear_skies_hardest",
				difficulty = very_hard
			},
			{
				no_bleedout = true,
				id = "ach_clear_skies_no_bleedout",
				num_peers = 2
			},
			{
				no_bleedout = true,
				id = "ach_clear_skies_hardest_no_bleedout",
				num_peers = 2,
				difficulty = very_hard
			}
		},
		oper_flamable = {
			{
				id = "ach_burn_hardest",
				difficulty = very_hard
			},
			{
				no_bleedout = true,
				id = "ach_burn_no_bleedout",
				num_peers = 2
			},
			{
				no_bleedout = true,
				id = "ach_burn_hardest_no_bleedout",
				num_peers = 2,
				difficulty = very_hard
			}
		},
		flakturm = {
			{
				id = "ach_flak_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_flak",
				all_dogtags = true
			}
		},
		settlement = {
			{
				id = "ach_castle_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_castle",
				all_dogtags = true
			}
		},
		train_yard = {
			{
				id = "ach_trainyard_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_trainyard",
				all_dogtags = true
			}
		},
		gold_rush = {
			{
				id = "ach_bank_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_bank",
				all_dogtags = true
			}
		},
		radio_defense = {
			{
				id = "ach_radiodefence_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_radiodefence",
				all_dogtags = true
			}
		},
		ger_bridge = {
			{
				id = "ach_bridge_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_bridge",
				all_dogtags = true
			}
		},
		hunters = {
			{
				id = "ach_hunters_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_hunters_stealth",
				stealth = true
			},
			{
				id = "ach_bring_them_home_hunters",
				all_dogtags = true
			}
		},
		tnd = {
			{
				id = "ach_tank_depot_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_tank_depot",
				all_dogtags = true
			}
		},
		bunker_test = {
			{
				id = "ach_bunkers_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_bunkers",
				all_dogtags = true
			}
		},
		convoy = {
			{
				id = "ach_sommelier_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_sommelier",
				all_dogtags = true
			}
		},
		spies_test = {
			{
				id = "ach_airfield_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_airfield",
				all_dogtags = true
			}
		},
		silo = {
			{
				id = "ach_silo_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_silo",
				all_dogtags = true
			}
		},
		kelly = {
			{
				id = "ach_kelly_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_kelly_stealth",
				stealth = true
			},
			{
				id = "ach_bring_them_home_kelly",
				all_dogtags = true
			}
		},
		sto = {
			{
				id = "ach_gallery_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_gallery_stealth",
				stealth = true
			}
		},
		forest_gumpy = {
			{
				id = "ach_forest_convoy_hardest",
				difficulty = very_hard
			}
		},
		fury_railway = {
			{
				id = "ach_fury_railway_hardest",
				difficulty = very_hard
			}
		},
		forest_bunker = {
			{
				id = "ach_forest_bunker_hardest",
				difficulty = very_hard
			},
			{
				id = "ach_bring_them_home_forest_bunker",
				all_dogtags = true
			}
		}
	}
end
