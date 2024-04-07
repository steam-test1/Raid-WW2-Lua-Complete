StatisticsTweakData = StatisticsTweakData or class()

function StatisticsTweakData:init()
	self.session = {}
	self.killed = {
		civilian = {
			total = {
				count = 0,
				type = "normal"
			},
			head_shots = {
				count = 0,
				type = "normal"
			},
			session = {
				count = 0,
				type = "session"
			}
		},
		civilian = {
			count = 0,
			head_shots = 0
		},
		security = {
			count = 0,
			head_shots = 0
		},
		cop = {
			count = 0,
			head_shots = 0
		},
		swat = {
			count = 0,
			head_shots = 0
		},
		total = {
			count = 0,
			head_shots = 0
		}
	}

	self:_init_top_stats()
	self:_init_bottom_stats()
end

function StatisticsTweakData:_init_top_stats()
	self.top_stats = {}
	self.top_stats.top_stat_most_kills = {}
	self.top_stats.top_stat_most_kills.text_id = "top_stat_most_kills"
	self.top_stats.top_stat_most_kills.xp_bonus = 50
	self.top_stats.top_stat_most_kills.loot_value = 20
	self.top_stats.top_stat_most_kills.weight_multiplier = 2
	self.top_stats.top_stat_most_kills.tie_breaker_multiplier = 6
	self.top_stats.top_stat_most_kills.stat = "kills"
	self.top_stats.top_stat_most_kills.icon = "bonus_most_kills"
	self.top_stats.top_stat_most_specials = {}
	self.top_stats.top_stat_most_specials.text_id = "top_stat_most_specials"
	self.top_stats.top_stat_most_specials.xp_bonus = 100
	self.top_stats.top_stat_most_specials.loot_value = 20
	self.top_stats.top_stat_most_specials.weight_multiplier = 4
	self.top_stats.top_stat_most_specials.tie_breaker_multiplier = 3
	self.top_stats.top_stat_most_specials.stat = "specials_kills"
	self.top_stats.top_stat_most_specials.icon = "bonus_most_specials_killed"
	self.top_stats.top_stat_most_accurate = {}
	self.top_stats.top_stat_most_accurate.text_id = "top_stat_most_accurate"
	self.top_stats.top_stat_most_accurate.xp_bonus = 75
	self.top_stats.top_stat_most_accurate.loot_value = 20
	self.top_stats.top_stat_most_accurate.weight_multiplier = 0.5
	self.top_stats.top_stat_most_accurate.tie_breaker_multiplier = 5
	self.top_stats.top_stat_most_accurate.score_format = "%d%%"
	self.top_stats.top_stat_most_accurate.stat = "accuracy"
	self.top_stats.top_stat_most_accurate.icon = "bonus_highest_accu"
	self.top_stats.top_stat_most_head_shots = {}
	self.top_stats.top_stat_most_head_shots.text_id = "top_stat_most_head_shots"
	self.top_stats.top_stat_most_head_shots.xp_bonus = 100
	self.top_stats.top_stat_most_head_shots.loot_value = 20
	self.top_stats.top_stat_most_head_shots.weight_multiplier = 3
	self.top_stats.top_stat_most_head_shots.tie_breaker_multiplier = 4
	self.top_stats.top_stat_most_head_shots.stat = "head_shots"
	self.top_stats.top_stat_most_head_shots.icon = "bonus_most_headshots"
	self.top_stats.top_stat_most_downs = {}
	self.top_stats.top_stat_most_downs.text_id = "top_stat_most_downs"
	self.top_stats.top_stat_most_downs.xp_bonus = -50
	self.top_stats.top_stat_most_downs.loot_value = -20
	self.top_stats.top_stat_most_downs.weight_multiplier = 1
	self.top_stats.top_stat_most_downs.tie_breaker_multiplier = 1
	self.top_stats.top_stat_most_downs.stat = "downs"
	self.top_stats.top_stat_most_downs.icon = "bonus_most_bleedouts"
	self.top_stats.top_stat_most_revives = {}
	self.top_stats.top_stat_most_revives.text_id = "top_stat_most_revives"
	self.top_stats.top_stat_most_revives.xp_bonus = 100
	self.top_stats.top_stat_most_revives.loot_value = 20
	self.top_stats.top_stat_most_revives.weight_multiplier = 3
	self.top_stats.top_stat_most_revives.tie_breaker_multiplier = 2
	self.top_stats.top_stat_most_revives.stat = "revives"
	self.top_stats.top_stat_most_revives.icon = "bonus_most_revives"
	self.top_stats_calculated = {
		"top_stat_most_kills",
		"top_stat_most_specials",
		"top_stat_most_accurate",
		"top_stat_most_head_shots",
		"top_stat_most_revives"
	}
end

function StatisticsTweakData:_init_bottom_stats()
	self.bottom_stats = {}
	self.bottom_stats.bottom_stat_least_kills = {}
	self.bottom_stats.bottom_stat_least_kills.text_id = "bottom_stat_least_kills"
	self.bottom_stats.bottom_stat_least_kills.weight_multiplier = 2
	self.bottom_stats.bottom_stat_least_kills.tie_breaker_multiplier = 6
	self.bottom_stats.bottom_stat_least_kills.stat = "kills"
	self.bottom_stats.bottom_stat_least_kills.icon = "bonus_most_kills"
	self.bottom_stats.bottom_stat_least_specials = {}
	self.bottom_stats.bottom_stat_least_specials.text_id = "bottom_stat_least_specials"
	self.bottom_stats.bottom_stat_least_specials.weight_multiplier = 4
	self.bottom_stats.bottom_stat_least_specials.tie_breaker_multiplier = 3
	self.bottom_stats.bottom_stat_least_specials.stat = "specials_kills"
	self.bottom_stats.bottom_stat_least_specials.icon = "bonus_most_specials_killed"
	self.bottom_stats.bottom_stat_least_accurate = {}
	self.bottom_stats.bottom_stat_least_accurate.text_id = "bottom_stat_least_accurate"
	self.bottom_stats.bottom_stat_least_accurate.weight_multiplier = 0.5
	self.bottom_stats.bottom_stat_least_accurate.tie_breaker_multiplier = 5
	self.bottom_stats.bottom_stat_least_accurate.score_format = "%d%%"
	self.bottom_stats.bottom_stat_least_accurate.stat = "accuracy"
	self.bottom_stats.bottom_stat_least_accurate.icon = "bonus_highest_accu"
	self.bottom_stats.bottom_stat_least_head_shots = {}
	self.bottom_stats.bottom_stat_least_head_shots.text_id = "bottom_stat_least_head_shots"
	self.bottom_stats.bottom_stat_least_head_shots.weight_multiplier = 3
	self.bottom_stats.bottom_stat_least_head_shots.tie_breaker_multiplier = 4
	self.bottom_stats.bottom_stat_least_head_shots.stat = "head_shots"
	self.bottom_stats.bottom_stat_least_head_shots.icon = "bonus_most_headshots"
	self.bottom_stats.bottom_stat_most_downs = {}
	self.bottom_stats.bottom_stat_most_downs.text_id = "bottom_stat_most_downs"
	self.bottom_stats.bottom_stat_most_downs.weight_multiplier = 1
	self.bottom_stats.bottom_stat_most_downs.tie_breaker_multiplier = 1
	self.bottom_stats.bottom_stat_most_downs.stat = "downs"
	self.bottom_stats.bottom_stat_most_downs.icon = "bonus_most_bleedouts"
	self.bottom_stats.bottom_stat_least_revives = {}
	self.bottom_stats.bottom_stat_least_revives.text_id = "bottom_stat_least_revives"
	self.bottom_stats.bottom_stat_least_revives.weight_multiplier = 3
	self.bottom_stats.bottom_stat_least_revives.tie_breaker_multiplier = 2
	self.bottom_stats.bottom_stat_least_revives.stat = "revives"
	self.bottom_stats.bottom_stat_least_revives.icon = "bonus_most_revives"
	self.bottom_stats_calculated = {
		"bottom_stat_least_kills",
		"bottom_stat_least_specials",
		"bottom_stat_least_accurate",
		"bottom_stat_least_head_shots",
		"bottom_stat_most_downs",
		"bottom_stat_least_revives"
	}
end

function StatisticsTweakData:statistics_specializations()
	return 12
end

function StatisticsTweakData:statistics_table()
	local level_list = {
		"flakturm",
		"forest_gumpy",
		"train_yard",
		"radio_defense",
		"ger_bridge",
		"hunters",
		"spies_test",
		"convoy",
		"tnd",
		"sto",
		"bunker_test",
		"gold_rush",
		"settlement",
		"tutorial",
		"ger_bridge_operation"
	}
	local job_list = {
		"clear_skies",
		"oper_flamable"
	}
	local mask_list = {
		"character_locked"
	}
	local weapon_list = {
		"m1911",
		"webley",
		"c96",
		"thompson",
		"sten",
		"garand",
		"m1918",
		"m1903",
		"m1912",
		"mp38",
		"carbine",
		"mp44",
		"mg42",
		"mosin",
		"sterling",
		"geco",
		"dp28",
		"tt33",
		"ithaca",
		"kar_98k",
		"bren",
		"lee_enfield",
		"browning",
		"welrod",
		"shotty"
	}
	local melee_list = {
		"weapon",
		"fists",
		"m3_knife",
		"robbins_dudley_trench_push_dagger",
		"german_brass_knuckles",
		"lockwood_brothers_push_dagger",
		"bc41_knuckle_knife",
		"km_dagger",
		"marching_mace",
		"lc14b"
	}
	local grenade_list = {
		"m24",
		"concrete",
		"d343",
		"mills",
		"betty"
	}
	local enemy_list = {
		"german_black_waffen_sentry_gasmask",
		"german_black_waffen_sentry_heavy",
		"german_black_waffen_sentry_light",
		"german_commander",
		"german_og_commander",
		"german_officer",
		"german_fallschirmjager_heavy",
		"german_waffen_ss",
		"german_fallschirmjager_light",
		"german_flamer",
		"german_gebirgsjager_heavy",
		"german_gebirgsjager_light",
		"german_grunt_heavy",
		"german_grunt_light",
		"german_grunt_mid",
		"german_sniper"
	}
	local character_list = {
		"russian",
		"german",
		"british",
		"american"
	}

	return level_list, job_list, weapon_list, melee_list, grenade_list, enemy_list, character_list
end

function StatisticsTweakData:resolution_statistics_table()
	return {
		"3840x2160",
		"2560x1440",
		"1920x1200",
		"1920x1080",
		"1680x1050",
		"1600x900",
		"1536x864",
		"1440x900",
		"1366x768",
		"1360x768",
		"1280x1024",
		"1280x800",
		"1280x720",
		"1024x768"
	}
end
