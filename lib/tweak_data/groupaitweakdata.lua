require("lib/tweak_data/group_ai/GroupAIRaidTweakData")
require("lib/tweak_data/group_ai/GroupAIZoneTweakData")

GroupAITweakData = GroupAITweakData or class()

function GroupAITweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	print("[GroupAITweakData:init] difficulty", difficulty, "difficulty_index", difficulty_index)

	self.ai_tick_rate_loud = 80
	self.ai_tick_rate_stealth = 100
	self.game_over_wait = 7
	self.cover_cone_angle = {
		80,
		25
	}
	self.cover_optimal_add_retreat = 400

	self:_create_table_structure()
	self:_init_task_data(difficulty_index)

	if not self.besiege then
		self.besiege = GroupAIRaidTweakData:new(difficulty_index)
		self.raid = GroupAIRaidTweakData:new(difficulty_index)
		self.zone = GroupAIZoneTweakData:new(difficulty_index)
	else
		self.besiege:init(difficulty_index)
		self.raid:init(difficulty_index)
		self.zone:init(difficulty_index)
	end

	self:_init_chatter_data()
	self:_init_unit_categories(difficulty_index)
	self:_init_enemy_spawn_groups(difficulty_index)

	self.commander_backup_groups = {
		"commander_squad",
		"ss_flankers",
		"ss_rifle_range",
		"ss_chargers"
	}
end

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
				3,
				6
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
			radius = 4000,
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
			radius = 4000,
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
		},
		deathguard = {
			radius = 1000,
			max_nr = 1,
			queue = "taunt_player",
			group_min = 1,
			duration = {
				10,
				10
			},
			interval = {
				0.75,
				1.5
			}
		},
		reload = {
			radius = 2500,
			max_nr = 3,
			queue = "reload",
			group_min = 1,
			duration = {
				10,
				20
			},
			interval = {
				6,
				10
			}
		}
	}
end

local access_type_walk_only = {
	walk = true
}
local access_type_all = {
	walk = true,
	acrobatic = true
}

function GroupAITweakData:_init_unit_categories(difficulty_index)
	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.special_unit_spawn_limits = {
			commander = 0,
			flamer = 0
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.special_unit_spawn_limits = {
			commander = 1,
			flamer = 1
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.special_unit_spawn_limits = {
			commander = 1,
			flamer = 2
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.special_unit_spawn_limits = {
			commander = 1,
			flamer = 3
		}
	end

	self.unit_categories = {}

	self:_init_unit_categories_german(difficulty_index)
end

function GroupAITweakData:_init_unit_categories_german(difficulty_index)
	self.unit_categories.german = {
		german_grunt_light = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light")
			},
			access = access_type_all
		},
		german_grunt_light_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_mp38")
			},
			access = access_type_all
		},
		german_grunt_light_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_kar98")
			},
			access = access_type_all
		},
		german_grunt_light_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_stg44")
			},
			access = access_type_all
		},
		german_grunt_light_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light_shotgun")
			},
			access = access_type_all
		},
		german_grunt_mid = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid")
			},
			access = access_type_all
		},
		german_grunt_mid_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_mp38")
			},
			access = access_type_all
		},
		german_grunt_mid_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_kar98")
			},
			access = access_type_all
		},
		german_grunt_mid_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_stg44")
			},
			access = access_type_all
		},
		german_grunt_mid_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_mid/german_grunt_mid_shotgun")
			},
			access = access_type_all
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
		german_grunt_heavy_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_grunt_heavy/german_grunt_heavy_stg44")
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
		german_light_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_mp38")
			},
			access = access_type_all
		},
		german_light_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_kar98")
			},
			access = access_type_all
		},
		german_light_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light/german_black_waffen_sentry_light_stg44")
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
			access = access_type_walk_only
		},
		german_heavy_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_mp38")
			},
			access = access_type_walk_only
		},
		german_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_kar98")
			},
			access = access_type_walk_only
		},
		german_heavy_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_stg44")
			},
			access = access_type_walk_only
		},
		german_heavy_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_shotgun")
			},
			access = access_type_walk_only
		},
		german_gasmask = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy")
			},
			access = access_type_all
		},
		german_gasmask_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_mp38")
			},
			access = access_type_all
		},
		german_gasmask_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_kar98")
			},
			access = access_type_all
		},
		german_gasmask_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_stg44")
			},
			access = access_type_all
		},
		german_gasmask_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_shotgun")
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
		german_gebirgsjager_light_stg44 = {
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
			access = access_type_walk_only
		},
		german_gebirgsjager_heavy_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_mp38")
			},
			access = access_type_walk_only
		},
		german_gebirgsjager_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_kar98")
			},
			access = access_type_walk_only
		},
		german_gebirgsjager_heavy_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_kar98")
			},
			access = access_type_walk_only
		},
		german_gebirgsjager_heavy_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_gebirgsjager_heavy/german_gebirgsjager_heavy_shotgun")
			},
			access = access_type_walk_only
		},
		german_fallschirmjager_heavy = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy")
			},
			access = access_type_walk_only
		},
		german_fallschirmjager_heavy_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_mp38")
			},
			access = access_type_walk_only
		},
		german_fallschirmjager_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_kar98")
			},
			access = access_type_walk_only
		},
		german_fallschirmjager_heavy_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_kar98")
			},
			access = access_type_walk_only
		},
		german_fallschirmjager_heavy_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_heavy/german_fallschirmjager_heavy_shotgun")
			},
			access = access_type_walk_only
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
		german_fallschirmjager_light_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_fallschirmjager_light/german_fallschirmjager_light_stg44")
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
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy")
			},
			access = access_type_walk_only
		},
		german_gasmask_commander_backup_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_mp38")
			},
			access = access_type_walk_only
		},
		german_gasmask_commander_backup_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_kar98")
			},
			access = access_type_walk_only
		},
		german_gasmask_commander_backup_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_stg44")
			},
			access = access_type_walk_only
		},
		german_gasmask_commander_backup_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_shotgun")
			},
			access = access_type_walk_only
		},
		german_heavy_commander_backup = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander")
			},
			access = access_type_walk_only
		},
		german_heavy_commander_backup_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_mp38")
			},
			access = access_type_walk_only
		},
		german_heavy_commander_backup_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_kar98")
			},
			access = access_type_walk_only
		},
		german_heavy_commander_backup_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_stg44")
			},
			access = access_type_walk_only
		},
		german_heavy_commander_backup_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_shotgun")
			},
			access = access_type_walk_only
		},
		german_light_commander_backup = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander")
			},
			access = access_type_walk_only
		},
		german_light_commander_backup_mp38 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_mp38")
			},
			access = access_type_walk_only
		},
		german_light_commander_backup_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_kar98")
			},
			access = access_type_walk_only
		},
		german_light_commander_backup_stg44 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_stg44")
			},
			access = access_type_walk_only
		},
		german_light_commander_backup_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_shotgun")
			},
			access = access_type_walk_only
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

function GroupAITweakData:_init_enemy_spawn_groups(difficulty_index)
	self._tactics = {
		grunt_chargers = {
			"charge"
		},
		grunt_flankers = {
			"flank"
		},
		grunt_support_range = {
			"attack_range"
		},
		gerbish_chargers = {
			"charge"
		},
		gerbish_flankers = {
			"flank"
		},
		gerbish_rifle_range = {
			"attack_range"
		},
		fallschirm_chargers = {
			"charge"
		},
		fallschirm_flankers = {
			"flank"
		},
		fallschirm_support = {
			"attack_range"
		},
		flamethrower = {
			"flank",
			"charge",
			"deathguard"
		},
		commander = {
			"flank",
			"attack_range"
		},
		ss_chargers = {
			"charge",
			"deathguard"
		},
		ss_flankers = {
			"flank",
			"deathguard"
		},
		ss_rifle_range = {
			"attack_range",
			"deathguard"
		}
	}
	self.enemy_spawn_groups = {}

	self:_init_enemy_spawn_groups_german(difficulty_index)
end

function GroupAITweakData:_init_enemy_spawn_groups_german(difficulty_index)
	self.enemy_spawn_groups.german = {}
	local amount_one = {
		1,
		1
	}
	local amount_four = {
		4,
		4
	}
	local amount_easy = {
		2,
		2
	}
	local amount_norm = {
		2,
		3
	}
	local amount_hard = {
		2,
		3
	}
	local amount_vhrd = {
		3,
		3
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = amount_easy,
			spawn = {
				{
					rank = 3,
					amount_max = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 2,
					amount_max = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 3,
					unit = "german_grunt_light_stg44",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_mid_stg44",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = amount_hard,
			spawn = {
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 2,
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_mid_stg44",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = amount_easy,
			spawn = {
				{
					rank = 3,
					amount_max = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 2,
					amount_max = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 4,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 3,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = amount_hard,
			spawn = {
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = amount_easy,
			spawn = {
				{
					rank = 1,
					amount_max = 1,
					amount_min = 0,
					freq = 4,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 3,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 2,
					amount_max = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = amount_norm,
			spawn = {
				{
					rank = 1,
					amount_max = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid_mp38",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 1,
					amount_max = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = amount_hard,
			spawn = {
				{
					rank = 1,
					amount_max = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 2,
					amount_max = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid_stg44",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 1,
					amount_max = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_heavy_mp38",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_stg44",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = amount_easy,
			spawn = {
				{
					rank = 3,
					amount_max = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_gebirgsjager_light_mp38",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 3,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light_kar98",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = amount_hard,
			spawn = {
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_heavy_mp38",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_stg44",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_heavy_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = amount_easy,
			spawn = {
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_gebirgsjager_heavy",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = amount_norm,
			spawn = {
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_stg44",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = amount_hard,
			spawn = {
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_heavy_stg44",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_gebirgsjager_heavy_stg44",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_gebirgsjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	end

	self.enemy_spawn_groups.german.gerbish_flankers = {
		amount = amount_easy,
		spawn = {}
	}

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		table.insert(self.enemy_spawn_groups.german.gerbish_flankers.spawn, {
			{
				rank = 3,
				amount_max = 1,
				freq = 1,
				unit = "german_grunt_heavy_mp38",
				tactics = self._tactics.grunt_flankers
			},
			{
				rank = 2,
				amount_max = 2,
				freq = 2,
				unit = "german_gebirgsjager_light_mp38",
				tactics = self._tactics.gerbish_flankers
			},
			{
				rank = 1,
				amount_min = 2,
				freq = 5,
				unit = "german_grunt_light_mp38",
				tactics = self._tactics.grunt_flankers
			}
		})
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		table.insert(self.enemy_spawn_groups.german.gerbish_flankers.spawn, {
			{
				rank = 2,
				amount_min = 0,
				freq = 1,
				unit = "german_gebirgsjager_heavy_mp38",
				tactics = self._tactics.gerbish_flankers
			},
			{
				rank = 1,
				amount_min = 0,
				freq = 2,
				unit = "german_gebirgsjager_light_mp38",
				tactics = self._tactics.gerbish_flankers
			},
			{
				rank = 1,
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_light_mp38",
				tactics = self._tactics.grunt_flankers
			}
		})
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		table.insert(self.enemy_spawn_groups.german.gerbish_flankers.spawn, {
			{
				rank = 1,
				amount_min = 0,
				freq = 1,
				unit = "german_gebirgsjager_light_mp38",
				tactics = self._tactics.gerbish_flankers
			},
			{
				rank = 2,
				amount_min = 0,
				freq = 2,
				unit = "german_gebirgsjager_heavy_mp38",
				tactics = self._tactics.gerbish_flankers
			},
			{
				rank = 1,
				amount_min = 0,
				freq = 2,
				unit = "german_gebirgsjager_heavy_stg44",
				tactics = self._tactics.gerbish_flankers
			}
		})
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		table.insert(self.enemy_spawn_groups.german.gerbish_flankers.spawn, {
			{
				rank = 2,
				amount_min = 2,
				freq = 1,
				unit = "german_gebirgsjager_heavy_stg44",
				tactics = self._tactics.gerbish_flankers
			},
			{
				rank = 1,
				amount_min = 1,
				freq = 2,
				unit = "german_gebirgsjager_heavy_shotgun",
				tactics = self._tactics.gerbish_flankers
			},
			{
				rank = 1,
				amount_min = 1,
				freq = 2,
				unit = "german_gebirgsjager_heavy_kar98",
				tactics = self._tactics.gerbish_flankers
			}
		})
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_easy,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light",
					tactics = self._tactics.fallschirm_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.grunt_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 3,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light_shotgun",
					tactics = self._tactics.fallschirm_chargers
				},
				{
					rank = 2,
					amount_min = 2,
					freq = 3,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.fallschirm_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_hard,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_shotgun",
					tactics = self._tactics.fallschirm_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 3,
					unit = "german_fallschirmjager_light_stg44",
					tactics = self._tactics.fallschirm_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_shotgun",
					tactics = self._tactics.fallschirm_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_shotgun",
					tactics = self._tactics.fallschirm_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 3,
					unit = "german_fallschirmjager_heavy_stg44",
					tactics = self._tactics.fallschirm_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_shotgun",
					tactics = self._tactics.fallschirm_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_easy,
			spawn = {
				{
					rank = 1,
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.grunt_support_range
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 3,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_kar98",
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_hard,
			spawn = {
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 3,
					unit = "german_fallschirmjager_heavy_mp38",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy_stg44",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_kar98",
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy_kar98",
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = amount_easy,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.fallschirm_flankers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.grunt_flankers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 3,
					freq = 1,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.fallschirm_flankers
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_fallschirmjager_heavy_mp38",
					tactics = self._tactics.fallschirm_flankers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_fallschirmjager_heavy_stg44",
					tactics = self._tactics.fallschirm_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = amount_hard,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.fallschirm_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy_stg44",
					tactics = self._tactics.fallschirm_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_mp38",
					tactics = self._tactics.fallschirm_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 2,
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy_mp38",
					tactics = self._tactics.fallschirm_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy_stg44",
					tactics = self._tactics.fallschirm_flankers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_mp38",
					tactics = self._tactics.fallschirm_flankers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_easy,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 2,
					unit = "german_light_stg44",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_shotgun",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 2,
					unit = "german_light_stg44",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 2,
					amount_min = 2,
					freq = 2,
					unit = "german_light_shotgun",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_hard,
			spawn = {
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_light_stg44",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_light_shotgun",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_heavy_shotgun",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 1,
					amount_min = 0,
					freq = 2,
					unit = "german_light_stg44",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_light_shotgun",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_heavy_shotgun",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_easy,
			spawn = {
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_light_stg44",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_light_stg44",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.ss_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 1,
					unit = "german_light_stg44",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_light_kar98",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_heavy_kar98",
					tactics = self._tactics.ss_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_hard,
			spawn = {
				{
					rank = 2,
					amount_min = 2,
					freq = 1,
					unit = "german_light_stg44",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 2,
					freq = 2,
					unit = "german_light_kar98",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_heavy_kar98",
					tactics = self._tactics.ss_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 2,
					amount_min = 1,
					freq = 3,
					unit = "german_heavy_stg44",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_light_kar98",
					tactics = self._tactics.ss_rifle_range
				},
				{
					rank = 1,
					amount_min = 0,
					freq = 1,
					unit = "german_heavy_kar98",
					tactics = self._tactics.ss_rifle_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_easy,
			spawn = {
				{
					rank = 1,
					amount_min = 1,
					freq = 2,
					unit = "german_light_mp38",
					tactics = self._tactics.ss_flankers
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_kar98",
					tactics = self._tactics.ss_flankers
				},
				{
					rank = 2,
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_light",
					tactics = self._tactics.ss_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_norm,
			spawn = {
				{
					rank = 1,
					amount_min = 4,
					freq = 2,
					unit = "german_light_mp38",
					tactics = self._tactics.ss_flankers
				},
				{
					rank = 2,
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_mp38",
					tactics = self._tactics.ss_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_hard,
			spawn = {
				{
					rank = 1,
					amount_min = 3,
					freq = 2,
					unit = "german_light_mp38",
					tactics = self._tactics.ss_flankers
				},
				{
					rank = 2,
					amount_min = 2,
					freq = 1,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.ss_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_vhrd,
			spawn = {
				{
					rank = 1,
					amount_min = 1,
					freq = 1,
					unit = "german_light_mp38",
					tactics = self._tactics.ss_flankers
				},
				{
					rank = 2,
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy_stg44",
					tactics = self._tactics.ss_flankers
				}
			}
		}
	end

	self.enemy_spawn_groups.german.flamethrower = {
		amount = amount_one,
		spawn = {
			{
				rank = 2,
				amount_max = 1,
				amount_min = 1,
				freq = 1,
				unit = "german_flamethrower",
				tactics = self._tactics.flamethrower
			}
		}
	}
	self.enemy_spawn_groups.german.commanders = {
		amount = {
			5,
			5
		},
		spawn = {}
	}

	if difficulty_index <= TweakData.DIFFICULTY_3 then
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 5,
			amount_max = 1,
			amount_min = 1,
			freq = 1,
			unit = "german_commander",
			tactics = self._tactics.commander
		})
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 4,
			amount_max = 2,
			amount_min = 2,
			freq = 2,
			unit = "german_light_commander_backup_mp38",
			tactics = self._tactics.ss_chargers
		})
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 4,
			amount_max = 1,
			amount_min = 1,
			freq = 1,
			unit = "german_light_commander_backup_stg44",
			tactics = self._tactics.ss_chargers
		})
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 4,
			amount_max = 1,
			amount_min = 1,
			freq = 1,
			unit = "german_light_commander_backup_shotgun",
			tactics = self._tactics.ss_chargers
		})
	else
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 5,
			amount_max = 1,
			amount_min = 1,
			freq = 1,
			unit = "german_og_commander",
			tactics = self._tactics.commander
		})
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 4,
			amount_max = 2,
			amount_min = 2,
			freq = 2,
			unit = "german_gasmask_commander_backup_mp38",
			tactics = self._tactics.ss_chargers
		})
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 4,
			amount_max = 1,
			amount_min = 1,
			freq = 1,
			unit = "german_gasmask_commander_backup_stg44",
			tactics = self._tactics.ss_chargers
		})
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			rank = 4,
			amount_max = 1,
			amount_min = 1,
			freq = 1,
			unit = "german_gasmask_commander_backup_shotgun",
			tactics = self._tactics.ss_chargers
		})
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_easy,
			spawn = {
				{
					rank = 2,
					freq = 2,
					unit = "german_light_commander_backup",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					freq = 1,
					unit = "german_light_commander_backup_shotgun",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					freq = 1,
					unit = "german_light_commander_backup_kar98",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_easy,
			spawn = {
				{
					rank = 2,
					freq = 2,
					unit = "german_light_commander_backup",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					freq = 1,
					unit = "german_light_commander_backup_shotgun",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					freq = 1,
					unit = "german_light_commander_backup_kar98",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					freq = 2,
					unit = "german_heavy_commander_backup",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					freq = 1,
					unit = "german_heavy_commander_backup_shotgun",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					freq = 1,
					unit = "german_heavy_commander_backup_kar98",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_norm,
			spawn = {
				{
					rank = 2,
					freq = 3,
					unit = "german_gasmask_commander_backup",
					tactics = self._tactics.ss_chargers
				},
				{
					rank = 1,
					freq = 1,
					unit = "german_gasmask_commander_backup_shotgun",
					tactics = self._tactics.ss_chargers
				}
			}
		}
	end

	self.enemy_spawn_groups.german.recon_grunt_chargers = {
		amount = amount_hard,
		spawn = {
			{
				rank = 2,
				amount_min = 2,
				freq = 2,
				unit = "german_grunt_light",
				tactics = self._tactics.grunt_chargers
			},
			{
				rank = 1,
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_mid",
				tactics = self._tactics.grunt_chargers
			}
		}
	}
	self.enemy_spawn_groups.german.recon_grunt_flankers = {
		amount = amount_hard,
		spawn = {
			{
				rank = 2,
				amount_min = 2,
				freq = 2,
				unit = "german_grunt_light",
				tactics = self._tactics.grunt_chargers
			},
			{
				rank = 1,
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_mid",
				tactics = self._tactics.grunt_chargers
			}
		}
	}
	self.enemy_spawn_groups.german.recon_grunt_support_range = {
		amount = amount_hard,
		spawn = {
			{
				rank = 2,
				amount_min = 2,
				freq = 2,
				unit = "german_grunt_light",
				tactics = self._tactics.grunt_chargers
			},
			{
				rank = 1,
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_mid",
				tactics = self._tactics.grunt_chargers
			}
		}
	}
end

function GroupAITweakData:_init_task_data(difficulty_index, difficulty)
	self.difficulty_curve_points = {
		0.5,
		0.75,
		1
	}
	self.phalanx.minions.min_count = 4
	self.phalanx.minions.amount = 10
	self.phalanx.minions.distance = 100
	self.phalanx.vip.health_ratio_flee = 0.2
	self.phalanx.vip.damage_reduction = {
		max = 0.5,
		increase = 0.05,
		start = 0.1,
		increase_intervall = 5
	}
	self.phalanx.check_spawn_intervall = 120
	self.phalanx.chance_increase_intervall = 120

	if difficulty_index == TweakData.DIFFICULTY_3 then
		self.phalanx.spawn_chance = {
			max = 1,
			increase = 0.05,
			start = 0,
			decrease = 0.7,
			respawn_delay = 300000
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.phalanx.spawn_chance = {
			max = 1,
			increase = 0.09,
			start = 0.01,
			decrease = 0.7,
			respawn_delay = 300000
		}
	else
		self.phalanx.spawn_chance = {
			max = 0,
			increase = 0,
			start = 0,
			decrease = 0,
			respawn_delay = 120
		}
	end
end

function GroupAITweakData:_create_table_structure()
	self.enemy_spawn_groups = {}
	self.phalanx = {
		minions = {},
		vip = {},
		spawn_chance = {}
	}
end
