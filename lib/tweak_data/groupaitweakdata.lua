require("lib/tweak_data/group_ai/GroupAIRaidTweakData")
require("lib/tweak_data/group_ai/GroupAIStreetTweakData")

GroupAITweakData = GroupAITweakData or class()

function GroupAITweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	print("[GroupAITweakData:init] difficulty", difficulty, "difficulty_index", difficulty_index)

	self.ai_tick_rate_loud = 80
	self.ai_tick_rate_stealth = 100

	self:_read_mission_preset(tweak_data)
	self:_create_table_structure()
	self:_init_task_data(difficulty_index)

	if not self.besiege then
		self.besiege = GroupAIRaidTweakData:new(difficulty_index)
		self.raid = GroupAIRaidTweakData:new(difficulty_index)
		self.street = GroupAIStreetTweakData:new(difficulty_index)
	else
		self.besiege:init(difficulty_index)
		self.raid:init(difficulty_index)
		self.street:init(difficulty_index)
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 3500,
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
			max_nr = 1,
			radius = 4000,
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
			max_nr = 1,
			radius = 4000,
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

function GroupAITweakData:_init_unit_categories(difficulty_index)
	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.special_unit_spawn_limits = {
			flamer = 0,
			commander = 0
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
			access = access_type_walk_only
		},
		german_heavy_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy/german_black_waffen_sentry_heavy_kar98")
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
			access = access_type_walk_only
		},
		german_gasmask_commander_backup_shotgun = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_gasmask_commander/german_black_waffen_sentry_gasmask_commander_shotgun")
			},
			access = access_type_walk_only
		},
		german_heavy_commander_backup = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander")
			},
			access = access_type_walk_only
		},
		german_heavy_commander_backup_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_heavy_commander/german_black_waffen_sentry_heavy_commander_kar98")
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
		german_light_commander_backup_kar98 = {
			units = {
				Idstring("units/vanilla/characters/enemies/models/german_black_waffen_sentry_light_commander/german_black_waffen_sentry_light_commander_kar98")
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
			"flank"
		},
		commander = {
			"flank"
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
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_light_shotgun",
					rank = 3,
					amount_max = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_mp38",
					rank = 2,
					amount_max = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 3,
					unit = "german_grunt_light",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_mid",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_mp38",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_mid",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_heavy",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_chargers = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_heavy_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_heavy",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_heavy_mp38",
					rank = 1,
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
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy",
					rank = 3,
					amount_max = 1,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid_mp38",
					rank = 2,
					amount_max = 2,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 0,
					freq = 4,
					unit = "german_grunt_light_mp38",
					rank = 1,
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy",
					rank = 2,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy_mp38",
					rank = 1,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 0,
					freq = 3,
					unit = "german_grunt_mid_mp38",
					rank = 1,
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_mid",
					rank = 1,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_heavy",
					rank = 1,
					tactics = self._tactics.grunt_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_flankers = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid",
					rank = 1,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_mp38",
					rank = 2,
					tactics = self._tactics.grunt_flankers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_heavy_shotgun",
					rank = 2,
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
					amount_min = 0,
					freq = 4,
					unit = "german_grunt_light_kar98",
					rank = 1,
					amount_max = 1,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid",
					rank = 3,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid_kar98",
					rank = 2,
					amount_max = 1,
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_kar98",
					rank = 1,
					amount_max = 1,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid",
					rank = 2,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid_kar98",
					rank = 1,
					amount_max = 1,
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_kar98",
					rank = 1,
					amount_max = 1,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_mid_kar98",
					rank = 2,
					amount_max = 1,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_heavy",
					rank = 1,
					tactics = self._tactics.grunt_support_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.grunt_support_range = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_heavy_kar98",
					rank = 1,
					amount_max = 2,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_mid",
					rank = 1,
					tactics = self._tactics.grunt_support_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_grunt_heavy",
					rank = 1,
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
					amount_min = 1,
					freq = 1,
					unit = "german_gebirgsjager_light",
					rank = 3,
					amount_max = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_grunt_light_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 3,
					unit = "german_grunt_light",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_light_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light_mp38",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_heavy_mp38",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.gerbish_chargers = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_heavy_shotgun",
					rank = 1,
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
					amount_min = 1,
					freq = 1,
					unit = "german_gebirgsjager_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_kar98",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_kar98",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_heavy_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_gebirgsjager_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_gebirgsjager_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.gerbish_rifle_range = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					unit = "german_gebirgsjager_heavy",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_gebirgsjager_heavy_kar98",
					rank = 1,
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
				freq = 1,
				unit = "german_grunt_heavy",
				rank = 3,
				amount_max = 1,
				tactics = self._tactics.gerbish_flankers
			},
			{
				freq = 2,
				unit = "german_gebirgsjager_light_mp38",
				rank = 2,
				amount_max = 2,
				tactics = self._tactics.gerbish_flankers
			},
			{
				amount_min = 2,
				freq = 5,
				unit = "german_grunt_light_mp38",
				rank = 1,
				tactics = self._tactics.gerbish_flankers
			}
		})
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		table.insert(self.enemy_spawn_groups.german.gerbish_flankers.spawn, {
			{
				amount_min = 0,
				freq = 1,
				unit = "german_gebirgsjager_heavy_mp38",
				rank = 2,
				tactics = self._tactics.gerbish_flankers
			},
			{
				amount_min = 0,
				freq = 2,
				unit = "german_gebirgsjager_light_mp38",
				rank = 1,
				tactics = self._tactics.gerbish_flankers
			},
			{
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_light_mp38",
				rank = 1,
				tactics = self._tactics.gerbish_flankers
			}
		})
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		table.insert(self.enemy_spawn_groups.german.gerbish_flankers.spawn, {
			{
				amount_min = 0,
				freq = 1,
				unit = "german_gebirgsjager_light_mp38",
				rank = 1,
				tactics = self._tactics.gerbish_flankers
			},
			{
				amount_min = 0,
				freq = 2,
				unit = "german_gebirgsjager_heavy_mp38",
				rank = 2,
				tactics = self._tactics.gerbish_flankers
			},
			{
				amount_min = 0,
				freq = 2,
				unit = "german_gebirgsjager_heavy",
				rank = 1,
				tactics = self._tactics.gerbish_flankers
			}
		})
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		table.insert(self.enemy_spawn_groups.german.gerbish_flankers.spawn, {
			{
				amount_min = 2,
				freq = 1,
				unit = "german_gebirgsjager_heavy",
				rank = 2,
				tactics = self._tactics.gerbish_flankers
			},
			{
				amount_min = 1,
				freq = 2,
				unit = "german_gebirgsjager_heavy_shotgun",
				rank = 1,
				tactics = self._tactics.gerbish_flankers
			},
			{
				amount_min = 1,
				freq = 2,
				unit = "german_gebirgsjager_heavy_kar98",
				rank = 1,
				tactics = self._tactics.gerbish_flankers
			}
		})
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_easy,
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 3,
					unit = "german_grunt_light",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 2,
					freq = 3,
					unit = "german_fallschirmjager_light",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 3,
					unit = "german_fallschirmjager_light",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_charge = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 3,
					unit = "german_fallschirmjager_heavy",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_easy,
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_kar98",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 2,
					freq = 3,
					unit = "german_fallschirmjager_light",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 3,
					unit = "german_fallschirmjager_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_support = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy_kar98",
					rank = 1,
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
					amount_min = 2,
					freq = 1,
					unit = "german_fallschirmjager_light",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					unit = "german_fallschirmjager_light_mp38",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_fallschirmjager_heavy_mp38",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_fallschirmjager_heavy",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_light_mp38",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_heavy_mp38",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.fallschirm_flankers = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy_mp38",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 0,
					freq = 2,
					unit = "german_fallschirmjager_heavy",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_fallschirmjager_light_mp38",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_easy,
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					unit = "german_light",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					unit = "german_light",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_light_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_mid_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					unit = "german_light",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_light_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_heavy_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_chargers = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					unit = "german_light",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_light_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_heavy_shotgun",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_easy,
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					unit = "german_light",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_light",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_grunt_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					unit = "german_light",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_heavy_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					unit = "german_light",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 1,
					freq = 2,
					unit = "german_heavy_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_rifle_range = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 1,
					freq = 3,
					unit = "german_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_light_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_heavy_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_rifle_range
				}
			}
		}
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_easy,
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					unit = "german_light",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_kar98",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 2,
					freq = 2,
					unit = "german_grunt_light",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_norm,
			spawn = {
				{
					amount_min = 4,
					freq = 2,
					unit = "german_light",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 1,
					freq = 1,
					unit = "german_grunt_light_mp38",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_hard,
			spawn = {
				{
					amount_min = 3,
					freq = 2,
					unit = "german_light",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 2,
					freq = 1,
					unit = "german_grunt_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.ss_flankers = {
			amount = amount_vhrd,
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					unit = "german_light",
					rank = 1,
					tactics = self._tactics.gerbish_flankers
				},
				{
					amount_min = 0,
					freq = 1,
					unit = "german_heavy",
					rank = 2,
					tactics = self._tactics.gerbish_flankers
				}
			}
		}
	end

	self.enemy_spawn_groups.german.flamethrower = {
		amount = amount_one,
		spawn = {
			{
				amount_min = 1,
				freq = 1,
				unit = "german_flamethrower",
				rank = 2,
				amount_max = 1,
				tactics = self._tactics.flamethrower
			}
		}
	}
	self.enemy_spawn_groups.german.commanders = {
		amount = amount_one,
		spawn = {}
	}

	if difficulty_index <= TweakData.DIFFICULTY_3 then
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			amount_min = 1,
			freq = 1,
			unit = "german_commander",
			rank = 2,
			amount_max = 1,
			tactics = self._tactics.commander
		})
	else
		table.insert(self.enemy_spawn_groups.german.commanders.spawn, {
			amount_min = 1,
			freq = 1,
			unit = "german_og_commander",
			rank = 2,
			amount_max = 1,
			tactics = self._tactics.commander
		})
	end

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_easy,
			spawn = {
				{
					freq = 2,
					unit = "german_light_commander_backup",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					unit = "german_light_commander_backup_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					unit = "german_light_commander_backup_kar98",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_easy,
			spawn = {
				{
					freq = 2,
					unit = "german_light_commander_backup",
					rank = 2,
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					unit = "german_light_commander_backup_shotgun",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				},
				{
					freq = 1,
					unit = "german_light_commander_backup_kar98",
					rank = 1,
					tactics = self._tactics.grunt_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_norm,
			spawn = {
				{
					freq = 2,
					unit = "german_heavy_commander_backup",
					rank = 2,
					tactics = self._tactics.gerbish_chargers
				},
				{
					freq = 1,
					unit = "german_heavy_commander_backup_shotgun",
					rank = 1,
					tactics = self._tactics.gerbish_chargers
				},
				{
					freq = 1,
					unit = "german_heavy_commander_backup_kar98",
					rank = 1,
					tactics = self._tactics.gerbish_chargers
				}
			}
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.enemy_spawn_groups.german.commander_squad = {
			amount = amount_norm,
			spawn = {
				{
					freq = 3,
					unit = "german_gasmask_commander_backup",
					rank = 2,
					tactics = self._tactics.gerbish_chargers
				},
				{
					freq = 1,
					unit = "german_gasmask_commander_backup_shotgun",
					rank = 1,
					tactics = self._tactics.gerbish_chargers
				}
			}
		}
	end

	self.enemy_spawn_groups.german.recon_grunt_chargers = {
		amount = amount_hard,
		spawn = {
			{
				amount_min = 2,
				freq = 2,
				unit = "german_grunt_light",
				rank = 2,
				tactics = self._tactics.grunt_chargers
			},
			{
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_mid",
				rank = 1,
				tactics = self._tactics.grunt_chargers
			}
		}
	}
	self.enemy_spawn_groups.german.recon_grunt_flankers = {
		amount = amount_hard,
		spawn = {
			{
				amount_min = 2,
				freq = 2,
				unit = "german_grunt_light",
				rank = 2,
				tactics = self._tactics.grunt_chargers
			},
			{
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_mid",
				rank = 1,
				tactics = self._tactics.grunt_chargers
			}
		}
	}
	self.enemy_spawn_groups.german.recon_grunt_support_range = {
		amount = amount_hard,
		spawn = {
			{
				amount_min = 2,
				freq = 2,
				unit = "german_grunt_light",
				rank = 2,
				tactics = self._tactics.grunt_chargers
			},
			{
				amount_min = 0,
				freq = 2,
				unit = "german_grunt_mid",
				rank = 1,
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
		start = 0.1,
		increase_intervall = 5,
		max = 0.5,
		increase = 0.05
	}
	self.phalanx.check_spawn_intervall = 120
	self.phalanx.chance_increase_intervall = 120

	if difficulty_index == TweakData.DIFFICULTY_3 then
		self.phalanx.spawn_chance = {
			start = 0,
			decrease = 0.7,
			respawn_delay = 300000,
			max = 1,
			increase = 0.05
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.phalanx.spawn_chance = {
			start = 0.01,
			decrease = 0.7,
			respawn_delay = 300000,
			max = 1,
			increase = 0.09
		}
	else
		self.phalanx.spawn_chance = {
			start = 0,
			decrease = 0,
			respawn_delay = 120,
			max = 0,
			increase = 0
		}
	end
end

function GroupAITweakData:_read_mission_preset(tweak_data)
	if not Global.game_settings then
		return
	end

	local lvl_tweak_data = tweak_data.levels[Global.game_settings.level_id]
	self._mission_preset = lvl_tweak_data.group_ai_preset
end

function GroupAITweakData:_create_table_structure()
	self.enemy_spawn_groups = {}
	self.phalanx = {
		minions = {},
		vip = {},
		spawn_chance = {}
	}
end
