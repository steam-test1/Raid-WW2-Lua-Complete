AchievementTweakData = AchievementTweakData or class()

function AchievementTweakData:init(tweak_data)
	self:_init_experience_awards()
	self:_init_mission_awards()
end

function AchievementTweakData:_init_experience_awards()
	self.experience = {
		{
			level = 2,
			id = "ach_reach_level_2"
		},
		{
			level = 5,
			id = "ach_reach_level_5"
		},
		{
			level = 10,
			id = "ach_reach_level_10"
		},
		{
			level = 20,
			id = "ach_reach_level_20"
		},
		{
			level = 30,
			id = "ach_reach_level_30"
		},
		{
			level = 40,
			id = "ach_reach_level_40"
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
				num_peers = 2,
				no_bleedout = true,
				id = "ach_clear_skies_no_bleedout"
			},
			{
				num_peers = 2,
				no_bleedout = true,
				id = "ach_clear_skies_hardest_no_bleedout",
				difficulty = very_hard
			}
		},
		oper_flamable = {
			{
				id = "ach_burn_hardest",
				difficulty = very_hard
			},
			{
				num_peers = 2,
				no_bleedout = true,
				id = "ach_burn_no_bleedout"
			},
			{
				num_peers = 2,
				no_bleedout = true,
				id = "ach_burn_hardest_no_bleedout",
				difficulty = very_hard
			}
		},
		flakturm = {
			{
				id = "ach_flak_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_flak"
			}
		},
		settlement = {
			{
				id = "ach_castle_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_castle"
			}
		},
		train_yard = {
			{
				id = "ach_trainyard_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_trainyard"
			}
		},
		gold_rush = {
			{
				id = "ach_bank_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_bank"
			}
		},
		radio_defense = {
			{
				id = "ach_radiodefence_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_radiodefence"
			}
		},
		ger_bridge = {
			{
				id = "ach_bridge_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_bridge"
			}
		},
		hunters = {
			{
				id = "ach_hunters_hardest",
				difficulty = very_hard
			},
			{
				stealth = true,
				id = "ach_hunters_stealth"
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_hunters"
			}
		},
		tnd = {
			{
				id = "ach_tank_depot_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_tank_depot"
			}
		},
		bunker_test = {
			{
				id = "ach_bunkers_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_bunkers"
			}
		},
		convoy = {
			{
				id = "ach_sommelier_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_sommelier"
			}
		},
		spies_test = {
			{
				id = "ach_airfield_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_airfield"
			}
		},
		silo = {
			{
				id = "ach_silo_hardest",
				difficulty = very_hard
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_silo"
			}
		},
		kelly = {
			{
				id = "ach_kelly_hardest",
				difficulty = very_hard
			},
			{
				stealth = true,
				id = "ach_kelly_stealth"
			},
			{
				all_dogtags = true,
				id = "ach_bring_them_home_kelly"
			}
		},
		sto = {
			{
				id = "ach_gallery_hardest",
				difficulty = very_hard
			},
			{
				stealth = true,
				id = "ach_gallery_stealth"
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
		}
	}
end
