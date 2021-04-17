require("lib/tweak_data/group_ai/GroupAIRaidTweakData")

GroupAITweakData = GroupAITweakData or class()

-- Lines 6-32
function GroupAITweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	print("[GroupAITweakData:init] difficulty", difficulty, "difficulty_index", difficulty_index)

	self.ai_tick_rate = 180

	self:_read_mission_preset(tweak_data)
	self:_create_table_structure()
	self:_init_task_data(difficulty_index)

	if not self.besiege then
		self.besiege = GroupAIRaidTweakData:new(difficulty_index)
		self.raid = GroupAIRaidTweakData:new(difficulty_index)
		self.street = self.raid
	else
		self.besiege:init(difficulty_index)
		self.raid:init(difficulty_index)

		self.street = self.raid
	end

	self:_init_chatter_data()
	self:_init_unit_categories(difficulty_index)
	self:_init_enemy_spawn_groups(difficulty_index)
end

-- Lines 38-121
function GroupAITweakData:_init_chatter_data()
	self.enemy_chatter = {
		spotted_player = {
			radius = 3500,
			max_nr = 1,
			queue = "spotted_player",
			group_min = 1,
			duration = {
				1,
				2
			},
			interval = {
				7,
				10
			}
		},
		aggressive = {
			radius = 3500,
			max_nr = 1,
			queue = "aggressive",
			group_min = 1,
			duration = {
				1,
				2
			},
			interval = {
				0.75,
				1.5
			}
		},
		retreat = {
			radius = 3500,
			max_nr = 1,
			queue = "retreat",
			group_min = 1,
			duration = {
				1,
				2
			},
			interval = {
				0.75,
				1.5
			}
		},
		follow_me = {
			radius = 3500,
			max_nr = 1,
			queue = "follow_me",
			group_min = 1,
			duration = {
				1,
				2
			},
			interval = {
				0.75,
				1.5
			}
		},
		clear = {
			radius = 3500,
			max_nr = 1,
			queue = "clear",
			group_min = 1,
			duration = {
				1,
				2
			},
			interval = {
				0.75,
				1.5
			}
		},
		go_go = {
			radius = 3500,
			max_nr = 1,
			queue = "go_go",
			group_min = 1,
			duration = {
				1,
				2
			},
			interval = {
				0.75,
				1.5
			}
		},
		ready = {
			radius = 3500,
			max_nr = 1,
			queue = "ready",
			group_min = 1,
			duration = {
				1,
				2
			},
			interval = {
				0.75,
				1.5
			}
		},
		smoke = {
			radius = 3500,
			max_nr = 1,
			queue = "smoke",
			group_min = 2,
			duration = {
				0,
				0
			},
			interval = {
				0,
				0
			}
		},
		incomming_flamer = {
			radius = 3500,
			max_nr = 1,
			queue = "incomming_flamer",
			group_min = 1,
			duration = {
				60,
				60
			},
			interval = {
				0.5,
				1
			}
		},
		incomming_commander = {
			radius = 3500,
			max_nr = 1,
			queue = "incomming_commander",
			group_min = 1,
			duration = {
				60,
				60
			},
			interval = {
				0.5,
				1
			}
		}
	}
end

local access_type_walk_only = {
	walk = true
}
local access_type_all = {
	acrobatic = true,
	walk = true
}

-- Lines 128-159
function GroupAITweakData:_init_unit_categories(difficulty_index)
	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.special_unit_spawn_limits = {
			flamer = 1,
			commander = 1
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.special_unit_spawn_limits = {
			flamer = 1,
			commander = 1
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.special_unit_spawn_limits = {
			flamer = 2,
			commander = 1
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.special_unit_spawn_limits = {
			flamer = 3,
			commander = 1
		}
	end

	self.unit_categories = {}

	self:_init_unit_categories_german(difficulty_index)
end

-- Lines 162-518
function GroupAITweakData:_init_unit_categories_german(difficulty_index)
	self.unit_categories.german = {
		german_grunt_light = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light")
			},
			access = access_type_walk_only
		},
		german_grunt_light_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_mp38")
			},
			access = access_type_walk_only
		},
		german_grunt_light_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_kar98")
			},
			access = access_type_walk_only
		},
		german_grunt_light_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_shotgun")
			},
			access = access_type_walk_only
		},
		german_grunt_mid = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid")
			},
			access = access_type_walk_only
		},
		german_grunt_mid_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_mp38")
			},
			access = access_type_walk_only
		},
		german_grunt_mid_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_kar98")
			},
			access = access_type_walk_only
		},
		german_grunt_mid_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_shotgun")
			},
			access = access_type_walk_only
		},
		german_grunt_heavy = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy")
			},
			access = access_type_walk_only
		},
		german_grunt_heavy_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_mp38")
			},
			access = access_type_walk_only
		},
		german_grunt_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_kar98")
			},
			access = access_type_walk_only
		},
		german_grunt_heavy_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_shotgun")
			},
			access = access_type_walk_only
		},
		german_light = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light")
			},
			access = access_type_all
		},
		german_light_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_kar98")
			},
			access = access_type_all
		},
		german_light_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_shotgun")
			},
			access = access_type_all
		},
		german_heavy = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy")
			},
			access = access_type_all
		},
		german_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_kar98")
			},
			access = access_type_all
		},
		german_heavy_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_shotgun")
			},
			access = access_type_all
		},
		german_gasmask = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask/german_black_waffen_sentry_gasmask")
			},
			access = access_type_all
		},
		german_gasmask_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask/german_black_waffen_sentry_gasmask_shotgun")
			},
			access = access_type_all
		},
		german_gebirgsjager_light = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light")
			},
			access = access_type_all
		},
		german_gebirgsjager_light_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light_mp38")
			},
			access = access_type_all
		},
		german_gebirgsjager_light_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light_kar98")
			},
			access = access_type_all
		},
		german_gebirgsjager_light_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_light/german_gebirgsjager_light_shotgun")
			},
			access = access_type_all
		},
		german_gebirgsjager_heavy = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy")
			},
			access = access_type_all
		},
		german_gebirgsjager_heavy_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_mp38")
			},
			access = access_type_all
		},
		german_gebirgsjager_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_kar98")
			},
			access = access_type_all
		},
		german_gebirgsjager_heavy_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_shotgun")
			},
			access = access_type_all
		},
		german_fallschirmjager_heavy = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy")
			},
			access = access_type_all
		},
		german_fallschirmjager_heavy_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_mp38")
			},
			access = access_type_all
		},
		german_fallschirmjager_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_kar98")
			},
			access = access_type_all
		},
		german_fallschirmjager_heavy_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_shotgun")
			},
			access = access_type_all
		},
		german_fallschirmjager_light = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light")
			},
			access = access_type_all
		},
		german_fallschirmjager_light_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light_mp38")
			},
			access = access_type_all
		},
		german_fallschirmjager_light_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light_kar98")
			},
			access = access_type_all
		},
		german_fallschirmjager_light_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light_shotgun")
			},
			access = access_type_all
		},
		german_flamethrower = {
			special_type = "flamer",
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_flamer/german_flamer")
			},
			access = access_type_walk_only
		},
		german_commander = {
			special_type = "commander",
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_commander/german_commander")
			},
			access = access_type_walk_only
		},
		german_gasmask_commander_backup = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask_commander/german_black_waffen_sentry_gasmask_commander")
			},
			access = access_type_all
		},
		german_gasmask_commander_backup_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask_commander/german_black_waffen_sentry_gasmask_commander_shotgun")
			},
			access = access_type_all
		},
		german_heavy_commander_backup = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander")
			},
			access = access_type_all
		},
		german_heavy_commander_backup_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_kar98")
			},
			access = access_type_all
		},
		german_heavy_commander_backup_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_shotgun")
			},
			access = access_type_all
		},
		german_light_commander_backup = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander")
			},
			access = access_type_all
		},
		german_light_commander_backup_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_kar98")
			},
			access = access_type_all
		},
		german_light_commander_backup_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_shotgun")
			},
			access = access_type_all
		},
		german_og_commander = {
			special_type = "commander",
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_og_commander/german_og_commander")
			},
			access = access_type_walk_only
		},
		german_officer = {
			special_type = "officer",
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_commander/german_commander")
			},
			access = access_type_walk_only
		}
	}
end

-- Lines 554-600
function GroupAITweakData:_init_enemy_spawn_groups(difficulty_index)
	self._tactics = {
		ranged_fire = {
			"ranged_fire"
		},
		defend = {
			"flank",
			"ranged_fire"
		},
		flanker = {
			"flank"
		},
		close_assault = {
			"charge",
			"ranged_fire",
			"deathguard"
		},
		close_assault_flank = {
			"charge",
			"flank",
			"ranged_fire",
			"deathguard"
		},
		close_assault_grenade = {
			"charge"
		},
		close_assault_grenade_flank = {
			"charge",
			"flank"
		},
		close_assault_supprise = {
			"flank"
		},
		sniper = {
			"ranged_fire"
		},
		commander = {
			"ranged_fire"
		},
		grunt_chargers = {
			"provide_coverfire",
			"provide_support"
		},
		grunt_flankers = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support"
		},
		grunt_support_range = {
			"ranged_fire",
			"provide_coverfire"
		},
		gerbish_chargers = {
			"provide_coverfire",
			"provide_support"
		},
		gerbish_flankers = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support"
		},
		gerbish_rifle_range = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support"
		},
		fallschirm_chargers = {
			"provide_coverfire",
			"provide_support"
		},
		fallschirm_flankers = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support",
			"flank"
		},
		fallschirm_support = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support"
		},
		ss_chargers = {
			"provide_coverfire",
			"provide_support"
		},
		ss_flankers = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support",
			"flank"
		},
		ss_rifle_range = {
			"ranged_fire",
			"provide_coverfire",
			"provide_support"
		},
		flamethrower = {
			"charge",
			"flank",
			"deathguard"
		},
		commander = {
			"flank"
		}
	}
	self.enemy_spawn_groups = {}

	self:_init_enemy_spawn_groups_german(difficulty_index)
end

-- Lines 603-1187
function GroupAITweakData:_init_enemy_spawn_groups_german(difficulty_index)
	self.enemy_spawn_groups.german = {}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = {
				3,
				4
			},
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 4,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_grunt_mid",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_mid",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_grunt_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = {
				3,
				4
			},
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 0,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					freq = 4,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_flankers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_flankers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_mid",
					tactics = self._tactics.grunt_flankers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					freq = 3,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_heavy_kar98",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = {
				3,
				4
			},
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.grunt_support_range
				},
				{
					freq = 4,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_support_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.grunt_support_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.grunt_support_range
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.grunt_support_range
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_heavy_kar98",
					tactics = self._tactics.grunt_support_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_support_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_heavy",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = {
				3,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "german_gebirgsjager_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 3,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_gebirgsjager_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_light_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_heavy_mp38",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_gebirgsjager_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_light",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 2,
					rank = 1,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 2,
					rank = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.gerbish_flankers = {
			amount = {
				3,
				4
			},
			spawn = {
				{
					rank = 3,
					freq = 1,
					amount_max = 1,
					unit = "german_grunt_heavy",
					tactics = self._tactics.gerbish_flankers
				},
				{
					rank = 2,
					freq = 2,
					amount_max = 2,
					unit = "german_gebirgsjager_light_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 5,
					amount_min = 2,
					rank = 1,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.gerbish_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_gebirgsjager_heavy_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_light_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.gerbish_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_light_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_gebirgsjager_heavy_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.gerbish_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_gebirgsjager_heavy_shotgun",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_fallschirmjager_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_light",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_fallschirmjager_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_fallschirmjager_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_fallschirmjager_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_fallschirmjager_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_heavy",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_light_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 1,
					unit = "german_fallschirmjager_light",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_light",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_fallschirmjager_light",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 2,
					rank = 1,
					unit = "german_fallschirmjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_fallschirmjager_heavy",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_fallschirmjager_heavy",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_fallschirmjager_light",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_light",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 3,
					rank = 2,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_fallschirmjager_heavy_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_fallschirmjager_heavy",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_heavy",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_heavy_mp38",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_fallschirmjager_heavy_mp38",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_heavy",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_light",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_light",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 2,
					rank = 1,
					unit = "german_grunt_light",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_light_",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 2,
					rank = 1,
					unit = "german_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_light",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 2,
					rank = 1,
					unit = "german_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_heavy",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_light",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_grunt_light",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 4,
					rank = 1,
					unit = "german_light",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 2,
					amount_min = 3,
					rank = 1,
					unit = "german_light",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 2,
					rank = 2,
					unit = "german_grunt_heavy",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					freq = 1,
					amount_min = 0,
					rank = 1,
					unit = "german_light",
					tactics = self._tactics.gerbish_flankers
				},
				{
					freq = 1,
					amount_min = 0,
					rank = 2,
					unit = "german_heavy",
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	end

	self.enemy_spawn_groups.german.flamethrower = {
		amount = {
			1,
			1
		},
		spawn = {
			{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 2,
				unit = "german_flamethrower",
				tactics = self._tactics.flamethrower
			}
		}
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.commanders = {
			amount = {
				1,
				1
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "german_commander",
					tactics = self._tactics.commander
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.commanders = {
			amount = {
				2,
				2
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_commander",
					tactics = self._tactics.commander
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.commanders = {
			amount = {
				1,
				1
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_commander",
					tactics = self._tactics.commander
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.commanders = {
			amount = {
				1,
				1
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_commander",
					tactics = self._tactics.commander
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = {
				1,
				1
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_gasmask",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					amount_min = 1,
					rank = 2,
					unit = "german_gasmask_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = {
				2,
				2
			},
			spawn = {
				{
					freq = 2,
					amount_min = 1,
					rank = 2,
					unit = "german_gasmask",
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 2,
					unit = "german_gasmask_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = {
				2,
				2
			},
			spawn = {
				{
					freq = 2,
					amount_min = 0,
					rank = 2,
					unit = "german_light_commander_backup",
					tactics = self._tactics.gerbish_chargers
				},
				{
					freq = 2,
					amount_min = 0,
					rank = 1,
					unit = "german_light_commander_backup_kar98",
					tactics = self._tactics.gerbish_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 2,
					amount_min = 1,
					rank = 2,
					unit = "german_heavy_commander_backup_shotgun",
					tactics = self._tactics.gerbish_chargers
				},
				{
					freq = 2,
					amount_min = 1,
					rank = 1,
					unit = "german_heavy_commander_backup_kar98",
					tactics = self._tactics.gerbish_chargers
				}
			}
		}
	end

	self.enemy_spawn_groups.german.recon_grunt_chargers = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				freq = 2,
				amount_min = 2,
				rank = 2,
				unit = "german_grunt_light",
				tactics = self._tactics.grunt_chargers
			},
			{
				freq = 2,
				amount_min = 0,
				rank = 1,
				unit = "german_grunt_mid",
				tactics = self._tactics.grunt_chargers
			}
		}
	}
	self.enemy_spawn_groups.german.recon_grunt_flankers = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				freq = 2,
				amount_min = 2,
				rank = 2,
				unit = "german_grunt_light",
				tactics = self._tactics.grunt_chargers
			},
			{
				freq = 2,
				amount_min = 0,
				rank = 1,
				unit = "german_grunt_mid",
				tactics = self._tactics.grunt_chargers
			}
		}
	}
	self.enemy_spawn_groups.german.recon_grunt_support_range = {
		amount = {
			3,
			4
		},
		spawn = {
			{
				freq = 2,
				amount_min = 2,
				rank = 2,
				unit = "german_grunt_light",
				tactics = self._tactics.grunt_chargers
			},
			{
				freq = 2,
				amount_min = 0,
				rank = 1,
				unit = "german_grunt_mid",
				tactics = self._tactics.grunt_chargers
			}
		}
	}
end

-- Lines 1191-1260
function GroupAITweakData:_init_task_data(difficulty_index, difficulty)
	local is_console = SystemInfo:platform() ~= Idstring("WIN32")
	self.difficulty_curve_points = {
		0.5
	}
	self.smoke_and_flash_grenade_timeout = {
		10,
		20
	}
	self.smoke_grenade_lifetime = 7.5
	self.flash_grenade_lifetime = 7.5
	self.optimal_trade_distance = {
		0,
		0
	}
	self.bain_assault_praise_limits = {
		1,
		3
	}
	self.phalanx.minions.min_count = 4
	self.phalanx.minions.amount = 10
	self.phalanx.minions.distance = 100
	self.phalanx.vip.health_ratio_flee = 0.2
	self.phalanx.vip.damage_reduction = {
		max = 0.5,
		start = 0.1,
		increase_intervall = 5,
		increase = 0.05
	}
	self.phalanx.check_spawn_intervall = 120
	self.phalanx.chance_increase_intervall = 120

	if difficulty_index == TweakData.DIFFICULTY_3 then
		self.phalanx.spawn_chance = {
			decrease = 0.7,
			start = 0,
			respawn_delay = 300000,
			increase = 0.05,
			max = 1
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.phalanx.spawn_chance = {
			decrease = 0.7,
			start = 0.01,
			respawn_delay = 300000,
			increase = 0.09,
			max = 1
		}
	else
		self.phalanx.spawn_chance = {
			decrease = 0,
			start = 0,
			respawn_delay = 120,
			increase = 0,
			max = 0
		}
	end
end

-- Lines 1269-1275
function GroupAITweakData:_read_mission_preset(tweak_data)
	if not Global.game_settings then
		return
	end

	local lvl_tweak_data = tweak_data.levels[Global.game_settings.level_id]
	self._mission_preset = lvl_tweak_data.group_ai_preset
end

-- Lines 1279-1303
function GroupAITweakData:_create_table_structure()
	self.enemy_spawn_groups = {}
	self.phalanx = {
		minions = {},
		vip = {},
		spawn_chance = {}
	}
	self.street = {
		blockade = {
			force = {}
		},
		assault = {
			force = {}
		},
		regroup = {},
		capture = {
			force = {}
		}
	}
end
