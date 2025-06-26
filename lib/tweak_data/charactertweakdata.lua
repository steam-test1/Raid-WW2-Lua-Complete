CharacterTweakData = CharacterTweakData or class()
CharacterTweakData.ENEMY_TYPE_SOLDIER = "soldier"
CharacterTweakData.ENEMY_TYPE_PARATROOPER = "paratrooper"
CharacterTweakData.ENEMY_TYPE_ELITE = "elite"
CharacterTweakData.ENEMY_TYPE_OFFICER = "officer"
CharacterTweakData.ENEMY_TYPE_FLAMER = "flamer"
CharacterTweakData.SPECIAL_UNIT_TYPES = {
	commander = true,
	flamer = true
}
CharacterTweakData.SPECIAL_UNIT_TYPE_FLAMER = "flamer"
CharacterTweakData.SPECIAL_UNIT_TYPE_COMMANDER = "commander"
CharacterTweakData.SPECIAL_UNIT_TYPE_SNIPER = "sniper"
CharacterTweakData.SPECIAL_UNIT_TYPE_SPOTTER = "spotter"

function CharacterTweakData:init(tweak_data)
	self:_create_table_structure()

	self._enemies_list = {}
	self.flashbang_multiplier = 1
	local presets = self:_presets(tweak_data)
	self.presets = presets

	self:_init_npc_loadouts(tweak_data)
	self:_init_dismemberment_data()
	self:_init_char_buff_gear()
	self:_init_german_commander(presets)
	self:_init_german_og_commander(presets)
	self:_init_german_officer(presets)
	self:_init_german_grunt_light(presets)
	self:_init_german_grunt_mid(presets)
	self:_init_german_grunt_heavy(presets)
	self:_init_german_light(presets)
	self:_init_german_heavy(presets)
	self:_init_german_gasmask(presets)
	self:_init_german_commander_backup(presets)
	self:_init_german_fallschirmjager_light(presets)
	self:_init_german_fallschirmjager_heavy(presets)
	self:_init_german_waffen_ss(presets)
	self:_init_german_gebirgsjager_light(presets)
	self:_init_german_gebirgsjager_heavy(presets)
	self:_init_german_flamer(presets)
	self:_init_german_sniper(presets)
	self:_init_german_spotter(presets)
	self:_init_soviet_nkvd_int_security_captain(presets)
	self:_init_soviet_nkvd_int_security_captain_b(presets)
	self:_init_british(presets)
	self:_init_russian(presets)
	self:_init_german(presets)
	self:_init_american(presets)
	self:_init_civilian(presets)
	self:_init_escort(presets)
	self:_init_upd_fb(presets)
end

function CharacterTweakData:set_difficulty(diff_index)
	Application:debug("[CharacterTweakData] Setting Difficulty Index: '" .. tostring(diff_index) .. "'!")

	if diff_index == 1 then
		self:_set_difficulty_1()
	elseif diff_index == 2 then
		self:_set_difficulty_2()
	elseif diff_index == 3 then
		self:_set_difficulty_3()
	elseif diff_index == 4 then
		self:_set_difficulty_4()
	end
end

function CharacterTweakData:_init_npc_loadouts(tweak_data)
	self.npc_loadouts = {
		ger_handgun = {
			german_grunt_light_kar98 = nil,
			secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
		},
		ger_rifle = {
			normal = nil,
			german_grunt_light_kar98 = nil,
			primary = Idstring("units/vanilla/weapons/wpn_npc_ger_k98/wpn_npc_ger_k98"),
			secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
		},
		ger_assault_rifle = {
			normal = nil,
			german_grunt_light_kar98 = nil,
			primary = Idstring("units/vanilla/weapons/wpn_npc_ger_stg44/wpn_npc_ger_stg44"),
			secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
		},
		ger_smg = {
			normal = nil,
			german_grunt_light_kar98 = nil,
			primary = Idstring("units/vanilla/weapons/wpn_npc_ger_mp38/wpn_npc_ger_mp38"),
			secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
		},
		ger_shotgun = {
			normal = nil,
			german_grunt_light_kar98 = nil,
			primary = Idstring("units/vanilla/weapons/wpn_npc_ger_geco/wpn_npc_ger_geco"),
			secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
		},
		unarmed = {
			normal = nil,
			german_grunt_light_kar98 = nil
		},
		special_commander = {
			german_grunt_light_kar98 = nil,
			secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger_fancy")
		},
		special_flamethrower = {
			german_grunt_light_kar98 = nil,
			primary = Idstring("units/vanilla/weapons/wpn_npc_spc_m42_flammenwerfer/wpn_npc_spc_m42_flammenwerfer")
		},
		special_sniper = {
			german_grunt_light_kar98 = nil,
			primary = Idstring("units/vanilla/weapons/wpn_npc_ger_k98/wpn_npc_ger_k98_sniper")
		},
		special_spotter = {
			german_grunt_light_kar98 = nil,
			primary = Idstring("units/vanilla/weapons/wpn_npc_binocular/wpn_npc_binocular")
		}
	}
end

function CharacterTweakData:_init_british(presets)
	self.british = {
		access = "teamAI1",
		HEALTH_INIT = 400,
		speech_prefix = "brit",
		flammable = false,
		crouch_move = false,
		no_run_stop = true,
		always_face_enemy = true,
		damage = presets.gang_member_damage,
		weapon = deep_clone(presets.weapon.gang_member),
		detection = presets.detection.gang_member,
		dodge = presets.dodge.athletic,
		move_speed = presets.move_speed.teamai,
		vision = presets.vision.easy,
		loadout = {
			primary = Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand"),
			secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
		}
	}
end

function CharacterTweakData:_init_russian(presets)
	self.russian = clone(self.british)
	self.russian.speech_prefix = "russ"
	self.russian.access = "teamAI2"
	self.russian.loadout = {
		primary = Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson"),
		secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
	}
end

function CharacterTweakData:_init_german(presets)
	self.german = clone(self.british)
	self.german.speech_prefix = "germ"
	self.german.access = "teamAI3"
	self.german.loadout = {
		primary = Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson"),
		secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
	}
end

function CharacterTweakData:_init_american(presets)
	self.american = clone(self.british)
	self.american.speech_prefix = "amer"
	self.american.access = "teamAI4"
	self.american.loadout = {
		primary = Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand"),
		secondary = Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger")
	}
end

function CharacterTweakData:_init_civilian(presets)
	self.civilian = {
		experience = {},
		detection = presets.detection.civilian,
		HEALTH_INIT = 0.9,
		headshot_dmg_mul = 1,
		move_speed = presets.move_speed.civ_fast,
		flee_type = "escape",
		scare_max = {
			10,
			20
		},
		scare_shot = 1,
		scare_intimidate = -5,
		submission_max = {
			60,
			120
		},
		submission_intimidate = 120,
		run_away_delay = {
			5,
			20
		},
		damage = presets.hurt_severities.no_hurts,
		ecm_hurts = {},
		speech_prefix_p1 = "cm",
		speech_prefix_count = 2,
		access = "civ_male",
		intimidateable = true,
		challenges = {
			type = "civilians"
		},
		calls_in = true,
		vision = presets.vision.civilian
	}
	self.civilian_female = deep_clone(self.civilian)
	self.civilian_female.speech_prefix_p1 = "cf"
	self.civilian_female.speech_prefix_count = 5
	self.civilian_female.female = true
	self.civilian_female.access = "civ_female"
	self.civilian_female.vision = presets.vision.civilian
end

function CharacterTweakData:_init_dismemberment_data()
	self.dismemberment_data = {}
	local dismembers = {
		[Idstring("head"):key()] = "dismember_head",
		[Idstring("body"):key()] = "dismember_body_top",
		[Idstring("hit_Head"):key()] = "dismember_head",
		[Idstring("hit_Body"):key()] = "dismember_body_top",
		[Idstring("hit_RightUpLeg"):key()] = "dismember_r_upper_leg",
		[Idstring("hit_LeftUpLeg"):key()] = "dismember_l_upper_leg",
		[Idstring("hit_RightArm"):key()] = "dismember_r_upper_arm",
		[Idstring("hit_LeftArm"):key()] = "dismember_l_upper_arm",
		[Idstring("hit_RightForeArm"):key()] = "dismember_r_lower_arm",
		[Idstring("hit_LeftForeArm"):key()] = "dismember_l_lower_arm",
		[Idstring("hit_RightLeg"):key()] = "dismember_r_lower_leg",
		[Idstring("hit_LeftLeg"):key()] = "dismember_l_lower_leg",
		[Idstring("rag_Head"):key()] = "dismember_head",
		[Idstring("rag_RightUpLeg"):key()] = "dismember_r_upper_leg",
		[Idstring("rag_LeftUpLeg"):key()] = "dismember_l_upper_leg",
		[Idstring("rag_RightArm"):key()] = "dismember_r_upper_arm",
		[Idstring("rag_LeftArm"):key()] = "dismember_l_upper_arm",
		[Idstring("rag_RightForeArm"):key()] = "dismember_r_lower_arm",
		[Idstring("rag_LeftForeArm"):key()] = "dismember_l_lower_arm",
		[Idstring("rag_RightLeg"):key()] = "dismember_r_lower_leg",
		[Idstring("rag_LeftLeg"):key()] = "dismember_l_lower_leg"
	}
	self.dismemberment_data.dismembers = dismembers
	local blood_decal_data = {
		dismember_head = {
			0,
			0.357,
			14
		},
		dismember_body_top = {
			2,
			2,
			30
		},
		dismember_r_upper_leg = {
			-0.098,
			-0.069,
			13.688
		},
		dismember_l_upper_leg = {
			0.098,
			-0.069,
			13.688
		},
		dismember_r_lower_leg = {
			-0.114,
			-0.358,
			25.55
		},
		dismember_l_lower_leg = {
			0.114,
			-0.358,
			25.55
		},
		dismember_r_upper_arm = {
			-0.19,
			0.311,
			14
		},
		dismember_l_upper_arm = {
			0.19,
			0.311,
			14
		},
		dismember_r_lower_arm = {
			-0.327,
			0.22,
			13.69
		},
		dismember_l_lower_arm = {
			0.327,
			0.22,
			13.69
		}
	}
	self.dismemberment_data.blood_decal_data = blood_decal_data
end

function CharacterTweakData:_init_char_buff_gear()
	self.char_buff_gear = {
		pumkin_heads = {}
	}
	local pumpkin_heads = {
		run_char_seqs = {
			"detach_hat_no_debris"
		},
		items = {
			Head = {
				"units/upd_candy/characters/props/pumpkin_mask/pumpkin_mask"
			}
		}
	}
	self.char_buff_gear.pumkin_heads = {
		german_gasmask_commander_backup = pumpkin_heads,
		german_gasmask_commander_backup_shotgun = pumpkin_heads,
		german_heavy_commander_backup = pumpkin_heads,
		german_heavy_commander_backup_kar98 = pumpkin_heads,
		german_heavy_commander_backup_shotgun = pumpkin_heads,
		german_black_waffen_sentry_gasmask = pumpkin_heads,
		german_black_waffen_sentry_gasmask_shotgun = pumpkin_heads,
		german_black_waffen_sentry_gasmask_commander = pumpkin_heads,
		german_black_waffen_sentry_gasmask_commander_shotgun = pumpkin_heads,
		german_black_waffen_sentry_heavy = pumpkin_heads,
		german_black_waffen_sentry_heavy_kar98 = pumpkin_heads,
		german_black_waffen_sentry_heavy_shotgun = pumpkin_heads,
		german_black_waffen_sentry_heavy_commander = pumpkin_heads,
		german_black_waffen_sentry_heavy_commander_kar98 = pumpkin_heads,
		german_black_waffen_sentry_heavy_commander_shotgun = pumpkin_heads,
		german_black_waffen_sentry_light = pumpkin_heads,
		german_black_waffen_sentry_light_kar98 = pumpkin_heads,
		german_black_waffen_sentry_light_shotgun = pumpkin_heads,
		german_light_commander_backup = pumpkin_heads,
		german_light_commander_backup_kar98 = pumpkin_heads,
		german_light_commander_backup_shotgun = pumpkin_heads,
		german_waffen_ss = pumpkin_heads,
		german_waffen_ss_kar98 = pumpkin_heads,
		german_waffen_ss_shotgun = pumpkin_heads,
		german_light = pumpkin_heads,
		german_light_kar98 = pumpkin_heads,
		german_light_shotgun = pumpkin_heads,
		german_gasmask = pumpkin_heads,
		german_gasmask_shotgun = pumpkin_heads,
		german_grunt_light = pumpkin_heads,
		german_grunt_light_kar98 = pumpkin_heads,
		german_grunt_light_mp38 = pumpkin_heads,
		german_grunt_light_shotgun = pumpkin_heads,
		german_grunt_mid = pumpkin_heads,
		german_grunt_mid_kar98 = pumpkin_heads,
		german_grunt_mid_mp38 = pumpkin_heads,
		german_grunt_mid_shotgun = pumpkin_heads,
		german_grunt_heavy = pumpkin_heads,
		german_grunt_heavy_kar98 = pumpkin_heads,
		german_grunt_heavy_mp38 = pumpkin_heads,
		german_grunt_heavy_shotgun = pumpkin_heads,
		german_heavy = pumpkin_heads,
		german_heavy_kar98 = pumpkin_heads,
		german_heavy_mp38 = pumpkin_heads,
		german_heavy_shotgun = pumpkin_heads,
		german_fallschirmjager_light = pumpkin_heads,
		german_fallschirmjager_light_kar98 = pumpkin_heads,
		german_fallschirmjager_light_mp38 = pumpkin_heads,
		german_fallschirmjager_light_shotgun = pumpkin_heads,
		german_fallschirmjager_heavy = pumpkin_heads,
		german_fallschirmjager_heavy_kar98 = pumpkin_heads,
		german_fallschirmjager_heavy_mp38 = pumpkin_heads,
		german_fallschirmjager_heavy_shotgun = pumpkin_heads,
		german_gebirgsjager_light = pumpkin_heads,
		german_gebirgsjager_light_kar98 = pumpkin_heads,
		german_gebirgsjager_light_mp38 = pumpkin_heads,
		german_gebirgsjager_light_shotgun = pumpkin_heads,
		german_gebirgsjager_heavy = pumpkin_heads,
		german_gebirgsjager_heavy_kar98 = pumpkin_heads,
		german_gebirgsjager_heavy_mp38 = pumpkin_heads,
		german_gebirgsjager_heavy_shotgun = pumpkin_heads,
		german_commander = {
			run_char_seqs = {
				"detach_hat_no_debris"
			},
			items = {
				Head = {
					"units/upd_candy/characters/props/pumpkin_mask/pumpkin_mask_commander_1"
				}
			}
		},
		german_officer = {
			run_char_seqs = {
				"detach_hat_no_debris"
			},
			items = {
				Head = {
					"units/upd_candy/characters/props/pumpkin_mask/pumpkin_mask_commander_1"
				}
			}
		},
		german_og_commander = {
			run_char_seqs = {
				"detach_hat_no_debris"
			},
			items = {
				Head = {
					"units/upd_candy/characters/props/pumpkin_mask/pumpkin_mask_commander_2"
				}
			}
		},
		german_flamer = {
			run_char_seqs = {},
			items = {
				Head = {
					"units/upd_candy/characters/props/pumpkin_mask/pumpkin_mask_flamer"
				}
			}
		}
	}
end

function CharacterTweakData:_init_german_grunt_light(presets)
	self.german_grunt_light = deep_clone(presets.base)
	self.german_grunt_light.experience = {}
	self.german_grunt_light.weapon = presets.weapon.normal
	self.german_grunt_light.detection = presets.detection.normal
	self.german_grunt_light.vision = presets.vision.easy
	self.german_grunt_light.HEALTH_INIT = 80
	self.german_grunt_light.BASE_HEALTH_INIT = 80
	self.german_grunt_light.headshot_dmg_mul = 1
	self.german_grunt_light.move_speed = presets.move_speed.fast
	self.german_grunt_light.suppression = presets.suppression.easy
	self.german_grunt_light.ecm_vulnerability = 1
	self.german_grunt_light.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_grunt_light.speech_prefix_p1 = "ger"
	self.german_grunt_light.speech_prefix_p2 = "soldier"
	self.german_grunt_light.speech_prefix_count = 4
	self.german_grunt_light.access = "swat"
	self.german_grunt_light.silent_priority_shout = "shout_loud_soldier"
	self.german_grunt_light.dodge = presets.dodge.poor
	self.german_grunt_light.deathguard = false
	self.german_grunt_light.chatter = presets.enemy_chatter.regular
	self.german_grunt_light.steal_loot = false
	self.german_grunt_light.loot_table = "easy_enemy"
	self.german_grunt_light.type = CharacterTweakData.ENEMY_TYPE_SOLDIER
	self.german_grunt_light.carry_tweak_corpse = "german_grunt_light_body"
	self.german_grunt_light.loadout = self.npc_loadouts.ger_handgun
	self.german_grunt_light_mp38 = clone(self.german_grunt_light)
	self.german_grunt_light_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_grunt_light_kar98 = clone(self.german_grunt_light)
	self.german_grunt_light_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_grunt_light_stg44 = clone(self.german_grunt_light)
	self.german_grunt_light_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_grunt_light_shotgun = clone(self.german_grunt_light)
	self.german_grunt_light_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_grunt_light")
	table.insert(self._enemies_list, "german_grunt_light_mp38")
	table.insert(self._enemies_list, "german_grunt_light_kar98")
	table.insert(self._enemies_list, "german_grunt_light_stg44")
	table.insert(self._enemies_list, "german_grunt_light_shotgun")
end

function CharacterTweakData:_init_german_grunt_mid(presets)
	self.german_grunt_mid = deep_clone(presets.base)
	self.german_grunt_mid.experience = {}
	self.german_grunt_mid.weapon = presets.weapon.normal
	self.german_grunt_mid.detection = presets.detection.normal
	self.german_grunt_mid.vision = presets.vision.easy
	self.german_grunt_mid.HEALTH_INIT = 120
	self.german_grunt_mid.BASE_HEALTH_INIT = 120
	self.german_grunt_mid.headshot_dmg_mul = 1
	self.german_grunt_mid.move_speed = presets.move_speed.normal
	self.german_grunt_mid.suppression = presets.suppression.easy
	self.german_grunt_mid.ecm_vulnerability = 1
	self.german_grunt_mid.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_grunt_mid.speech_prefix_p1 = "ger"
	self.german_grunt_mid.speech_prefix_p2 = "soldier"
	self.german_grunt_mid.speech_prefix_count = 4
	self.german_grunt_mid.access = "swat"
	self.german_grunt_mid.silent_priority_shout = "shout_loud_soldier"
	self.german_grunt_mid.dodge = presets.dodge.average
	self.german_grunt_mid.deathguard = false
	self.german_grunt_mid.chatter = presets.enemy_chatter.regular
	self.german_grunt_mid.steal_loot = false
	self.german_grunt_mid.loot_table = "easy_enemy"
	self.german_grunt_mid.type = CharacterTweakData.ENEMY_TYPE_SOLDIER
	self.german_grunt_mid.carry_tweak_corpse = "german_grunt_mid_body"
	self.german_grunt_mid.loadout = self.npc_loadouts.ger_handgun
	self.german_grunt_mid_mp38 = clone(self.german_grunt_mid)
	self.german_grunt_mid_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_grunt_mid_kar98 = clone(self.german_grunt_mid)
	self.german_grunt_mid_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_grunt_mid_stg44 = clone(self.german_grunt_mid)
	self.german_grunt_mid_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_grunt_mid_shotgun = clone(self.german_grunt_mid)
	self.german_grunt_mid_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_grunt_mid")
	table.insert(self._enemies_list, "german_grunt_mid_mp38")
	table.insert(self._enemies_list, "german_grunt_mid_kar98")
	table.insert(self._enemies_list, "german_grunt_mid_stg44")
	table.insert(self._enemies_list, "german_grunt_mid_shotgun")
end

function CharacterTweakData:_init_german_grunt_heavy(presets)
	self.german_grunt_heavy = deep_clone(presets.base)
	self.german_grunt_heavy.experience = {}
	self.german_grunt_heavy.weapon = presets.weapon.normal
	self.german_grunt_heavy.detection = presets.detection.normal
	self.german_grunt_heavy.vision = presets.vision.easy
	self.german_grunt_heavy.HEALTH_INIT = 160
	self.german_grunt_heavy.BASE_HEALTH_INIT = 160
	self.german_grunt_heavy.headshot_dmg_mul = 0.8
	self.german_grunt_heavy.headshot_helmet = true
	self.german_grunt_heavy.move_speed = presets.move_speed.normal
	self.german_grunt_heavy.crouch_move = false
	self.german_grunt_heavy.suppression = presets.suppression.easy
	self.german_grunt_heavy.ecm_vulnerability = 1
	self.german_grunt_heavy.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_grunt_heavy.speech_prefix_p1 = "ger"
	self.german_grunt_heavy.speech_prefix_p2 = "soldier"
	self.german_grunt_heavy.speech_prefix_count = 4
	self.german_grunt_heavy.access = "swat"
	self.german_grunt_heavy.silent_priority_shout = "shout_loud_soldier"
	self.german_grunt_heavy.dodge = presets.dodge.heavy
	self.german_grunt_heavy.deathguard = false
	self.german_grunt_heavy.chatter = presets.enemy_chatter.regular
	self.german_grunt_heavy.steal_loot = false
	self.german_grunt_heavy.loot_table = "normal_enemy"
	self.german_grunt_heavy.type = CharacterTweakData.ENEMY_TYPE_SOLDIER
	self.german_grunt_heavy.carry_tweak_corpse = "german_grunt_heavy_body"
	self.german_grunt_heavy.loadout = self.npc_loadouts.ger_handgun
	self.german_grunt_heavy_mp38 = clone(self.german_grunt_heavy)
	self.german_grunt_heavy_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_grunt_heavy_kar98 = clone(self.german_grunt_heavy)
	self.german_grunt_heavy_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_grunt_heavy_stg44 = clone(self.german_grunt_heavy)
	self.german_grunt_heavy_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_grunt_heavy_shotgun = clone(self.german_grunt_heavy)
	self.german_grunt_heavy_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_grunt_heavy")
	table.insert(self._enemies_list, "german_grunt_heavy_mp38")
	table.insert(self._enemies_list, "german_grunt_heavy_kar98")
	table.insert(self._enemies_list, "german_grunt_heavy_stg44")
	table.insert(self._enemies_list, "german_grunt_heavy_shotgun")
end

function CharacterTweakData:_init_german_gebirgsjager_light(presets)
	self.german_gebirgsjager_light = deep_clone(presets.base)
	self.german_gebirgsjager_light.experience = {}
	self.german_gebirgsjager_light.weapon = presets.weapon.good
	self.german_gebirgsjager_light.detection = presets.detection.normal
	self.german_gebirgsjager_light.vision = presets.vision.normal
	self.german_gebirgsjager_light.HEALTH_INIT = 160
	self.german_gebirgsjager_light.BASE_HEALTH_INIT = 160
	self.german_gebirgsjager_light.headshot_dmg_mul = 1
	self.german_gebirgsjager_light.move_speed = presets.move_speed.fast
	self.german_gebirgsjager_light.suppression = presets.suppression.hard_def
	self.german_gebirgsjager_light.ecm_vulnerability = 1
	self.german_gebirgsjager_light.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_gebirgsjager_light.speech_prefix_p1 = "ger"
	self.german_gebirgsjager_light.speech_prefix_p2 = "paratrooper"
	self.german_gebirgsjager_light.speech_prefix_count = 4
	self.german_gebirgsjager_light.access = "swat"
	self.german_gebirgsjager_light.silent_priority_shout = "shout_loud_paratrooper"
	self.german_gebirgsjager_light.dodge = presets.dodge.athletic
	self.german_gebirgsjager_light.deathguard = false
	self.german_gebirgsjager_light.chatter = presets.enemy_chatter.regular
	self.german_gebirgsjager_light.steal_loot = false
	self.german_gebirgsjager_light.loot_table = "normal_enemy"
	self.german_gebirgsjager_light.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_gebirgsjager_light.carry_tweak_corpse = "german_gebirgsjager_light_body"
	self.german_gebirgsjager_light.loadout = self.npc_loadouts.ger_handgun
	self.german_gebirgsjager_light_mp38 = clone(self.german_gebirgsjager_light)
	self.german_gebirgsjager_light_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_gebirgsjager_light_kar98 = clone(self.german_gebirgsjager_light)
	self.german_gebirgsjager_light_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_gebirgsjager_light_stg44 = clone(self.german_gebirgsjager_light)
	self.german_gebirgsjager_light_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_gebirgsjager_light_shotgun = clone(self.german_gebirgsjager_light)
	self.german_gebirgsjager_light_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_gebirgsjager_light")
	table.insert(self._enemies_list, "german_gebirgsjager_light_mp38")
	table.insert(self._enemies_list, "german_gebirgsjager_light_kar98")
	table.insert(self._enemies_list, "german_gebirgsjager_light_stg44")
	table.insert(self._enemies_list, "german_gebirgsjager_light_shotgun")
end

function CharacterTweakData:_init_german_gebirgsjager_heavy(presets)
	self.german_gebirgsjager_heavy = deep_clone(presets.base)
	self.german_gebirgsjager_heavy.experience = {}
	self.german_gebirgsjager_heavy.weapon = presets.weapon.good
	self.german_gebirgsjager_heavy.detection = presets.detection.normal
	self.german_gebirgsjager_heavy.vision = presets.vision.normal
	self.german_gebirgsjager_heavy.HEALTH_INIT = 210
	self.german_gebirgsjager_heavy.BASE_HEALTH_INIT = 210
	self.german_gebirgsjager_heavy.headshot_dmg_mul = 0.8
	self.german_gebirgsjager_heavy.headshot_helmet = true
	self.german_gebirgsjager_heavy.move_speed = presets.move_speed.normal
	self.german_gebirgsjager_heavy.crouch_move = false
	self.german_gebirgsjager_heavy.suppression = presets.suppression.hard_def
	self.german_gebirgsjager_heavy.ecm_vulnerability = 1
	self.german_gebirgsjager_heavy.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_gebirgsjager_heavy.speech_prefix_p1 = "ger"
	self.german_gebirgsjager_heavy.speech_prefix_p2 = "paratrooper"
	self.german_gebirgsjager_heavy.speech_prefix_count = 4
	self.german_gebirgsjager_heavy.access = "swat"
	self.german_gebirgsjager_heavy.silent_priority_shout = "shout_loud_paratrooper"
	self.german_gebirgsjager_heavy.dodge = presets.dodge.heavy
	self.german_gebirgsjager_heavy.deathguard = false
	self.german_gebirgsjager_heavy.chatter = presets.enemy_chatter.regular
	self.german_gebirgsjager_heavy.steal_loot = false
	self.german_gebirgsjager_heavy.loot_table = "normal_enemy"
	self.german_gebirgsjager_heavy.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_gebirgsjager_heavy.carry_tweak_corpse = "german_gebirgsjager_heavy_body"
	self.german_gebirgsjager_heavy.loadout = self.npc_loadouts.ger_handgun
	self.german_gebirgsjager_heavy_mp38 = clone(self.german_gebirgsjager_heavy)
	self.german_gebirgsjager_heavy_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_gebirgsjager_heavy_kar98 = clone(self.german_gebirgsjager_heavy)
	self.german_gebirgsjager_heavy_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_gebirgsjager_heavy_stg44 = clone(self.german_gebirgsjager_heavy)
	self.german_gebirgsjager_heavy_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_gebirgsjager_heavy_shotgun = clone(self.german_gebirgsjager_heavy)
	self.german_gebirgsjager_heavy_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_gebirgsjager_heavy")
	table.insert(self._enemies_list, "german_gebirgsjager_heavy_mp38")
	table.insert(self._enemies_list, "german_gebirgsjager_heavy_kar98")
	table.insert(self._enemies_list, "german_gebirgsjager_heavy_stg44")
	table.insert(self._enemies_list, "german_gebirgsjager_heavy_shotgun")
end

function CharacterTweakData:_init_german_light(presets)
	self.german_light = deep_clone(presets.base)
	self.german_light.experience = {}
	self.german_light.weapon = presets.weapon.insane
	self.german_light.detection = presets.detection.normal
	self.german_light.vision = presets.vision.normal
	self.german_light.HEALTH_INIT = 160
	self.german_light.BASE_HEALTH_INIT = 160
	self.german_light.headshot_dmg_mul = 1
	self.german_light.move_speed = presets.move_speed.fast
	self.german_light.suppression = presets.suppression.hard_agg
	self.german_light.ecm_vulnerability = 1
	self.german_light.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_light.speech_prefix_p1 = "ger"
	self.german_light.speech_prefix_p2 = "elite"
	self.german_light.speech_prefix_count = 4
	self.german_light.access = "swat"
	self.german_light.silent_priority_shout = "shout_loud_soldier"
	self.german_light.dodge = presets.dodge.athletic
	self.german_light.deathguard = true
	self.german_light.chatter = presets.enemy_chatter.regular
	self.german_light.steal_loot = false
	self.german_light.loot_table = "hard_enemy"
	self.german_light.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_light.carry_tweak_corpse = "german_black_waffen_sentry_light_body"
	self.german_light.loadout = self.npc_loadouts.ger_handgun
	self.german_light_mp38 = clone(self.german_light)
	self.german_light_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_light_kar98 = clone(self.german_light)
	self.german_light_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_light_stg44 = clone(self.german_light)
	self.german_light_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_light_shotgun = clone(self.german_light)
	self.german_light_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_light")
	table.insert(self._enemies_list, "german_light_mp38")
	table.insert(self._enemies_list, "german_light_kar98")
	table.insert(self._enemies_list, "german_light_stg44")
	table.insert(self._enemies_list, "german_light_shotgun")
end

function CharacterTweakData:_init_german_heavy(presets)
	self.german_heavy = deep_clone(presets.base)
	self.german_heavy.experience = {}
	self.german_heavy.weapon = presets.weapon.insane
	self.german_heavy.detection = presets.detection.normal
	self.german_heavy.vision = presets.vision.normal
	self.german_heavy.HEALTH_INIT = 210
	self.german_heavy.BASE_HEALTH_INIT = 210
	self.german_heavy.headshot_dmg_mul = 0.8
	self.german_heavy.headshot_helmet = true
	self.german_heavy.move_speed = presets.move_speed.normal
	self.german_heavy.crouch_move = false
	self.german_heavy.suppression = presets.suppression.hard_agg
	self.german_heavy.ecm_vulnerability = 1
	self.german_heavy.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_heavy.speech_prefix_p1 = "ger"
	self.german_heavy.speech_prefix_p2 = "elite"
	self.german_heavy.speech_prefix_count = 4
	self.german_heavy.access = "swat"
	self.german_heavy.silent_priority_shout = "shout_loud_soldier"
	self.german_heavy.dodge = presets.dodge.heavy
	self.german_heavy.deathguard = true
	self.german_heavy.chatter = presets.enemy_chatter.regular
	self.german_heavy.steal_loot = false
	self.german_heavy.loot_table = "elite_enemy"
	self.german_heavy.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_heavy.carry_tweak_corpse = "german_black_waffen_sentry_heavy_body"
	self.german_heavy.loadout = self.npc_loadouts.ger_handgun
	self.german_heavy_mp38 = clone(self.german_heavy)
	self.german_heavy_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_heavy_kar98 = clone(self.german_heavy)
	self.german_heavy_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_heavy_stg44 = clone(self.german_heavy)
	self.german_heavy_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_heavy_shotgun = clone(self.german_heavy)
	self.german_heavy_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_heavy")
	table.insert(self._enemies_list, "german_heavy_mp38")
	table.insert(self._enemies_list, "german_heavy_kar98")
	table.insert(self._enemies_list, "german_heavy_stg44")
	table.insert(self._enemies_list, "german_heavy_shotgun")
end

function CharacterTweakData:_init_german_fallschirmjager_light(presets)
	self.german_fallschirmjager_light = deep_clone(presets.base)
	self.german_fallschirmjager_light.experience = {}
	self.german_fallschirmjager_light.weapon = presets.weapon.expert
	self.german_fallschirmjager_light.detection = presets.detection.normal
	self.german_fallschirmjager_light.vision = presets.vision.hard
	self.german_fallschirmjager_light.HEALTH_INIT = 160
	self.german_fallschirmjager_light.BASE_HEALTH_INIT = 160
	self.german_fallschirmjager_light.headshot_dmg_mul = 1
	self.german_fallschirmjager_light.move_speed = presets.move_speed.fast
	self.german_fallschirmjager_light.suppression = presets.suppression.hard_def
	self.german_fallschirmjager_light.ecm_vulnerability = 1
	self.german_fallschirmjager_light.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_fallschirmjager_light.speech_prefix_p1 = "ger"
	self.german_fallschirmjager_light.speech_prefix_p2 = "paratrooper"
	self.german_fallschirmjager_light.speech_prefix_count = 4
	self.german_fallschirmjager_light.access = "swat"
	self.german_fallschirmjager_light.silent_priority_shout = "shout_loud_paratrooper"
	self.german_fallschirmjager_light.dodge = presets.dodge.athletic
	self.german_fallschirmjager_light.deathguard = true
	self.german_fallschirmjager_light.chatter = presets.enemy_chatter.regular
	self.german_fallschirmjager_light.steal_loot = false
	self.german_fallschirmjager_light.loot_table = "hard_enemy"
	self.german_fallschirmjager_light.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_fallschirmjager_light.carry_tweak_corpse = "german_fallschirmjager_light_body"
	self.german_fallschirmjager_light.loadout = self.npc_loadouts.ger_handgun
	self.german_fallschirmjager_light_mp38 = clone(self.german_fallschirmjager_light)
	self.german_fallschirmjager_light_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_fallschirmjager_light_kar98 = clone(self.german_fallschirmjager_light)
	self.german_fallschirmjager_light_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_fallschirmjager_light_stg44 = clone(self.german_fallschirmjager_light)
	self.german_fallschirmjager_light_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_fallschirmjager_light_shotgun = clone(self.german_fallschirmjager_light)
	self.german_fallschirmjager_light_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_fallschirmjager_light")
	table.insert(self._enemies_list, "german_fallschirmjager_light_mp38")
	table.insert(self._enemies_list, "german_fallschirmjager_light_kar98")
	table.insert(self._enemies_list, "german_fallschirmjager_light_stg44")
	table.insert(self._enemies_list, "german_fallschirmjager_light_shotgun")
end

function CharacterTweakData:_init_german_fallschirmjager_heavy(presets)
	self.german_fallschirmjager_heavy = deep_clone(presets.base)
	self.german_fallschirmjager_heavy.experience = {}
	self.german_fallschirmjager_heavy.weapon = presets.weapon.expert
	self.german_fallschirmjager_heavy.detection = presets.detection.normal
	self.german_fallschirmjager_heavy.vision = presets.vision.hard
	self.german_fallschirmjager_heavy.HEALTH_INIT = 210
	self.german_fallschirmjager_heavy.BASE_HEALTH_INIT = 210
	self.german_fallschirmjager_heavy.headshot_dmg_mul = 0.8
	self.german_fallschirmjager_heavy.headshot_helmet = true
	self.german_fallschirmjager_heavy.move_speed = presets.move_speed.normal
	self.german_fallschirmjager_heavy.crouch_move = false
	self.german_fallschirmjager_heavy.suppression = presets.suppression.hard_def
	self.german_fallschirmjager_heavy.ecm_vulnerability = 1
	self.german_fallschirmjager_heavy.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_fallschirmjager_heavy.speech_prefix_p1 = "ger"
	self.german_fallschirmjager_heavy.speech_prefix_p2 = "paratrooper"
	self.german_fallschirmjager_heavy.speech_prefix_count = 4
	self.german_fallschirmjager_heavy.access = "swat"
	self.german_fallschirmjager_heavy.silent_priority_shout = "shout_loud_paratrooper"
	self.german_fallschirmjager_heavy.dodge = presets.dodge.heavy
	self.german_fallschirmjager_heavy.deathguard = false
	self.german_fallschirmjager_heavy.chatter = presets.enemy_chatter.regular
	self.german_fallschirmjager_heavy.steal_loot = false
	self.german_fallschirmjager_heavy.loot_table = "hard_enemy"
	self.german_fallschirmjager_heavy.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_fallschirmjager_heavy.carry_tweak_corpse = "german_fallschirmjager_heavy_body"
	self.german_fallschirmjager_heavy.loadout = self.npc_loadouts.ger_handgun
	self.german_fallschirmjager_heavy_mp38 = clone(self.german_fallschirmjager_heavy)
	self.german_fallschirmjager_heavy_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_fallschirmjager_heavy_kar98 = clone(self.german_fallschirmjager_heavy)
	self.german_fallschirmjager_heavy_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_fallschirmjager_heavy_stg44 = clone(self.german_fallschirmjager_heavy)
	self.german_fallschirmjager_heavy_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_fallschirmjager_heavy_shotgun = clone(self.german_fallschirmjager_heavy)
	self.german_fallschirmjager_heavy_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_fallschirmjager_heavy")
	table.insert(self._enemies_list, "german_fallschirmjager_heavy_mp38")
	table.insert(self._enemies_list, "german_fallschirmjager_heavy_kar98")
	table.insert(self._enemies_list, "german_fallschirmjager_heavy_stg44")
	table.insert(self._enemies_list, "german_fallschirmjager_heavy_shotgun")
end

function CharacterTweakData:_init_german_gasmask(presets)
	self.german_gasmask = deep_clone(presets.base)
	self.german_gasmask.experience = {}
	self.german_gasmask.weapon = presets.weapon.expert
	self.german_gasmask.detection = presets.detection.normal
	self.german_gasmask.vision = presets.vision.hard
	self.german_gasmask.HEALTH_INIT = 210
	self.german_gasmask.BASE_HEALTH_INIT = 210
	self.german_gasmask.headshot_dmg_mul = 0.8
	self.german_gasmask.headshot_helmet = true
	self.german_gasmask.move_speed = presets.move_speed.normal
	self.german_gasmask.crouch_move = false
	self.german_gasmask.suppression = presets.suppression.hard_agg
	self.german_gasmask.ecm_vulnerability = 1
	self.german_gasmask.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_gasmask.speech_prefix_p1 = "ger"
	self.german_gasmask.speech_prefix_p2 = "elite"
	self.german_gasmask.speech_prefix_count = 4
	self.german_gasmask.access = "swat"
	self.german_gasmask.silent_priority_shout = "shout_loud_soldier"
	self.german_gasmask.dodge = presets.dodge.average
	self.german_gasmask.deathguard = true
	self.german_gasmask.chatter = presets.enemy_chatter.regular
	self.german_gasmask.steal_loot = false
	self.german_gasmask.loot_table = "elite_enemy"
	self.german_gasmask.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_gasmask.carry_tweak_corpse = "german_black_waffen_sentry_gasmask_body"
	self.german_gasmask.loadout = self.npc_loadouts.ger_handgun
	self.german_gasmask_mp38 = clone(self.german_gasmask)
	self.german_gasmask_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_gasmask_kar98 = clone(self.german_gasmask)
	self.german_gasmask_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_gasmask_stg44 = clone(self.german_gasmask)
	self.german_gasmask_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_gasmask_shotgun = clone(self.german_gasmask)
	self.german_gasmask_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_gasmask")
	table.insert(self._enemies_list, "german_gasmask_mp38")
	table.insert(self._enemies_list, "german_gasmask_kar98")
	table.insert(self._enemies_list, "german_gasmask_stg44")
	table.insert(self._enemies_list, "german_gasmask_shotgun")
end

function CharacterTweakData:_init_german_commander_backup(presets)
	self.german_light_commander_backup = clone(self.german_light)
	self.german_light_commander_backup.carry_tweak_corpse = "german_black_waffen_sentry_light_commander_body"

	table.insert(self._enemies_list, "german_light_commander_backup")

	self.german_light_commander_backup_mp38 = clone(self.german_light_mp38)
	self.german_light_commander_backup_mp38.carry_tweak_corpse = "german_black_waffen_sentry_light_commander_body"

	table.insert(self._enemies_list, "german_light_commander_backup_mp38")

	self.german_light_commander_backup_kar98 = clone(self.german_light_kar98)
	self.german_light_commander_backup_kar98.carry_tweak_corpse = "german_black_waffen_sentry_light_commander_body"

	table.insert(self._enemies_list, "german_light_commander_backup_kar98")

	self.german_light_commander_backup_stg44 = clone(self.german_light_stg44)
	self.german_light_commander_backup_stg44.carry_tweak_corpse = "german_black_waffen_sentry_light_commander_body"

	table.insert(self._enemies_list, "german_light_commander_backup_stg44")

	self.german_light_commander_backup_shotgun = clone(self.german_light_shotgun)
	self.german_light_commander_backup_shotgun.carry_tweak_corpse = "german_black_waffen_sentry_light_commander_body"

	table.insert(self._enemies_list, "german_light_commander_backup_shotgun")

	self.german_heavy_commander_backup = clone(self.german_heavy)
	self.german_heavy_commander_backup.carry_tweak_corpse = "german_black_waffen_sentry_heavy_commander_body"

	table.insert(self._enemies_list, "german_heavy_commander_backup")

	self.german_heavy_commander_backup_mp38 = clone(self.german_heavy_mp38)
	self.german_heavy_commander_backup_mp38.carry_tweak_corpse = "german_black_waffen_sentry_heavy_commander_body"

	table.insert(self._enemies_list, "german_heavy_commander_backup_mp38")

	self.german_heavy_commander_backup_kar98 = clone(self.german_heavy_kar98)
	self.german_heavy_commander_backup_kar98.carry_tweak_corpse = "german_black_waffen_sentry_heavy_commander_body"

	table.insert(self._enemies_list, "german_heavy_commander_backup_kar98")

	self.german_heavy_commander_backup_stg44 = clone(self.german_heavy_stg44)
	self.german_heavy_commander_backup_stg44.carry_tweak_corpse = "german_black_waffen_sentry_heavy_commander_body"

	table.insert(self._enemies_list, "german_heavy_commander_backup_stg44")

	self.german_heavy_commander_backup_shotgun = clone(self.german_heavy_shotgun)
	self.german_heavy_commander_backup_shotgun.carry_tweak_corpse = "german_black_waffen_sentry_heavy_commander_body"

	table.insert(self._enemies_list, "german_heavy_commander_backup_shotgun")
end

function CharacterTweakData:_init_german_waffen_ss(presets)
	self.german_waffen_ss = deep_clone(presets.base)
	self.german_waffen_ss.experience = {}
	self.german_waffen_ss.weapon = presets.weapon.insane
	self.german_waffen_ss.detection = presets.detection.normal
	self.german_waffen_ss.vision = presets.vision.hard
	self.german_waffen_ss.HEALTH_INIT = 210
	self.german_waffen_ss.BASE_HEALTH_INIT = 210
	self.german_waffen_ss.headshot_dmg_mul = 1
	self.german_waffen_ss.move_speed = presets.move_speed.fast
	self.german_waffen_ss.crouch_move = false
	self.german_waffen_ss.suppression = presets.suppression.hard_def
	self.german_waffen_ss.ecm_vulnerability = 1
	self.german_waffen_ss.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_waffen_ss.speech_prefix_p1 = "ger"
	self.german_waffen_ss.speech_prefix_p2 = "paratrooper"
	self.german_waffen_ss.speech_prefix_count = 4
	self.german_waffen_ss.access = "swat"
	self.german_waffen_ss.silent_priority_shout = "shout_loud_soldier"
	self.german_waffen_ss.dodge = presets.dodge.average
	self.german_waffen_ss.deathguard = false
	self.german_waffen_ss.chatter = presets.enemy_chatter.regular
	self.german_waffen_ss.steal_loot = false
	self.german_waffen_ss.loot_table = "elite_enemy"
	self.german_waffen_ss.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_waffen_ss.carry_tweak_corpse = "german_fallschirmjager_heavy_body"
	self.german_waffen_ss.loadout = self.npc_loadouts.ger_handgun
	self.german_waffen_ss_mp38 = clone(self.german_waffen_ss)
	self.german_waffen_ss_mp38.loadout = self.npc_loadouts.ger_smg
	self.german_waffen_ss_kar98 = clone(self.german_waffen_ss)
	self.german_waffen_ss_kar98.loadout = self.npc_loadouts.ger_rifle
	self.german_waffen_ss_stg44 = clone(self.german_waffen_ss)
	self.german_waffen_ss_stg44.loadout = self.npc_loadouts.ger_assault_rifle
	self.german_waffen_ss_shotgun = clone(self.german_waffen_ss)
	self.german_waffen_ss_shotgun.loadout = self.npc_loadouts.ger_shotgun

	table.insert(self._enemies_list, "german_waffen_ss")
	table.insert(self._enemies_list, "german_waffen_ss_mp38")
	table.insert(self._enemies_list, "german_waffen_ss_kar98")
	table.insert(self._enemies_list, "german_waffen_ss_stg44")
	table.insert(self._enemies_list, "german_waffen_ss_shotgun")
end

function CharacterTweakData:_init_german_commander(presets)
	self.german_commander = deep_clone(presets.base)
	self.german_commander.experience = {}
	self.german_commander.weapon = presets.weapon.expert
	self.german_commander.detection = presets.detection.normal
	self.german_commander.vision = presets.vision.commander
	self.german_commander.HEALTH_INIT = 400
	self.german_commander.BASE_HEALTH_INIT = 400
	self.german_commander.headshot_dmg_mul = 1
	self.german_commander.move_speed = presets.move_speed.very_fast
	self.german_commander.suppression = presets.suppression.no_supress
	self.german_commander.ecm_vulnerability = 1
	self.german_commander.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_commander.speech_prefix_p1 = "ger"
	self.german_commander.speech_prefix_p2 = "officer"
	self.german_commander.speech_prefix_count = 4
	self.german_commander.access = "fbi"
	self.german_commander.silent_priority_shout = "shout_loud_officer"
	self.german_commander.priority_shout = "shout_loud_officer"
	self.german_commander.priority_waypoint = "waypoint_special_mark_officer"
	self.german_commander.announce_incomming = "incomming_commander"
	self.german_commander.dodge = presets.dodge.athletic
	self.german_commander.deathguard = true
	self.german_commander.chatter = presets.enemy_chatter.special
	self.german_commander.steal_loot = false
	self.german_commander.loot_table = "special_enemy"
	self.german_commander.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.german_commander.is_special = true
	self.german_commander.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_COMMANDER
	self.german_commander.carry_tweak_corpse = "german_commander_body"
	self.german_commander.gear = {
		run_char_seqs = {},
		items = {
			Spine2 = {
				"units/vanilla/characters/props/prop_backpack_radio/prop_backpack_radio"
			}
		}
	}
	self.german_commander.loadout = self.npc_loadouts.special_commander

	table.insert(self._enemies_list, "german_commander")
end

function CharacterTweakData:_init_german_og_commander(presets)
	self.german_og_commander = deep_clone(presets.base)
	self.german_og_commander.experience = {}
	self.german_og_commander.weapon = presets.weapon.expert
	self.german_og_commander.detection = presets.detection.normal
	self.german_og_commander.vision = presets.vision.commander
	self.german_og_commander.HEALTH_INIT = 400
	self.german_og_commander.BASE_HEALTH_INIT = 400
	self.german_og_commander.headshot_dmg_mul = 1
	self.german_og_commander.move_speed = presets.move_speed.very_fast
	self.german_og_commander.suppression = presets.suppression.no_supress
	self.german_og_commander.ecm_vulnerability = 1
	self.german_og_commander.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_og_commander.speech_prefix_p1 = "ger"
	self.german_og_commander.speech_prefix_p2 = "officer"
	self.german_og_commander.speech_prefix_count = 4
	self.german_og_commander.access = "fbi"
	self.german_og_commander.silent_priority_shout = "shout_loud_officer"
	self.german_og_commander.priority_shout = "shout_loud_officer"
	self.german_og_commander.priority_waypoint = "waypoint_special_mark_officer"
	self.german_og_commander.announce_incomming = "incomming_commander"
	self.german_og_commander.dodge = presets.dodge.athletic
	self.german_og_commander.deathguard = true
	self.german_og_commander.chatter = presets.enemy_chatter.special
	self.german_og_commander.steal_loot = false
	self.german_og_commander.loot_table = "special_enemy"
	self.german_og_commander.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.german_og_commander.is_special = true
	self.german_og_commander.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_COMMANDER
	self.german_og_commander.carry_tweak_corpse = "german_og_commander_body"
	self.german_og_commander.gear = {
		run_char_seqs = {},
		items = {
			Spine2 = {
				"units/vanilla/characters/props/prop_backpack_radio/prop_backpack_radio"
			}
		}
	}
	self.german_og_commander.loadout = self.npc_loadouts.special_commander

	table.insert(self._enemies_list, "german_og_commander")
end

function CharacterTweakData:_init_german_officer(presets)
	self.german_officer = deep_clone(presets.base)
	self.german_officer.experience = {}
	self.german_officer.weapon = presets.weapon.expert
	self.german_officer.detection = presets.detection.normal
	self.german_officer.vision = presets.vision.commander
	self.german_officer.HEALTH_INIT = 400
	self.german_officer.BASE_HEALTH_INIT = 400
	self.german_officer.headshot_dmg_mul = 1
	self.german_officer.move_speed = presets.move_speed.very_fast
	self.german_officer.suppression = presets.suppression.no_supress
	self.german_officer.ecm_vulnerability = 1
	self.german_officer.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_officer.speech_prefix_p1 = "ger"
	self.german_officer.speech_prefix_p2 = "officer"
	self.german_officer.speech_prefix_count = 4
	self.german_officer.access = "fbi"
	self.german_officer.silent_priority_shout = "shout_loud_officer"
	self.german_officer.priority_waypoint = "waypoint_special_mark_officer"
	self.german_officer.dodge = presets.dodge.athletic
	self.german_officer.deathguard = true
	self.german_officer.chatter = presets.enemy_chatter.special
	self.german_officer.steal_loot = false
	self.german_officer.loot_table = "special_enemy"
	self.german_officer.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.german_officer.carry_tweak_corpse = "german_commander_body"
	self.german_officer.loadout = self.npc_loadouts.special_commander

	table.insert(self._enemies_list, "german_officer")
end

function CharacterTweakData:_init_soviet_nkvd_int_security_captain(presets)
	self.soviet_nkvd_int_security_captain = deep_clone(presets.base)
	self.soviet_nkvd_int_security_captain.experience = {}
	self.soviet_nkvd_int_security_captain.weapon = presets.weapon.expert
	self.soviet_nkvd_int_security_captain.detection = presets.detection.normal
	self.soviet_nkvd_int_security_captain.vision = presets.vision.commander
	self.soviet_nkvd_int_security_captain.HEALTH_INIT = 100
	self.soviet_nkvd_int_security_captain.BASE_HEALTH_INIT = 100
	self.soviet_nkvd_int_security_captain.headshot_dmg_mul = 1
	self.soviet_nkvd_int_security_captain.move_speed = presets.move_speed.very_fast
	self.soviet_nkvd_int_security_captain.suppression = presets.suppression.no_supress
	self.soviet_nkvd_int_security_captain.ecm_vulnerability = 1
	self.soviet_nkvd_int_security_captain.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.soviet_nkvd_int_security_captain.speech_prefix_p1 = "ger"
	self.soviet_nkvd_int_security_captain.speech_prefix_p2 = "officer"
	self.soviet_nkvd_int_security_captain.speech_prefix_count = 4
	self.soviet_nkvd_int_security_captain.access = "swat"
	self.soviet_nkvd_int_security_captain.silent_priority_shout = "shout_loud_soldier"
	self.soviet_nkvd_int_security_captain.dodge = presets.dodge.athletic
	self.soviet_nkvd_int_security_captain.deathguard = true
	self.soviet_nkvd_int_security_captain.chatter = presets.enemy_chatter.no_chatter
	self.soviet_nkvd_int_security_captain.steal_loot = false
	self.soviet_nkvd_int_security_captain.loot_table = "special_enemy"
	self.soviet_nkvd_int_security_captain.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.soviet_nkvd_int_security_captain.carry_tweak_corpse = "soviet_nkvd_int_security_captain_body"
	self.soviet_nkvd_int_security_captain.loadout = self.npc_loadouts.unarmed

	table.insert(self._enemies_list, "soviet_nkvd_int_security_captain")
end

function CharacterTweakData:_init_soviet_nkvd_int_security_captain_b(presets)
	self.soviet_nkvd_int_security_captain_b = deep_clone(self.soviet_nkvd_int_security_captain)
	self.soviet_nkvd_int_security_captain_b.speech_prefix_p1 = "ger"
	self.soviet_nkvd_int_security_captain_b.speech_prefix_p2 = "officer"
	self.soviet_nkvd_int_security_captain_b.speech_prefix_count = 4

	table.insert(self._enemies_list, "soviet_nkvd_int_security_captain_b")
end

function CharacterTweakData:_init_german_flamer(presets)
	self.german_flamer = deep_clone(presets.base)
	self.german_flamer.experience = {}
	self.german_flamer.detection = presets.detection.flamer
	self.german_flamer.vision = presets.vision.easy
	self.german_flamer.HEALTH_INIT = 1
	self.german_flamer.headshot_dmg_mul = 0.8
	self.german_flamer.headshot_helmet = true
	self.german_flamer.friendly_fire_dmg_mul = 0.5
	self.german_flamer.dodge = presets.dodge.poor
	self.german_flamer.allowed_stances = {
		cbt = true
	}
	self.german_flamer.allowed_poses = {
		stand = true
	}
	self.german_flamer.always_face_enemy = true
	self.german_flamer.move_speed = presets.move_speed.super_slow
	self.german_flamer.crouch_move = false
	self.german_flamer.no_run_start = true
	self.german_flamer.no_run_stop = true
	self.german_flamer.loot_table = "flamer_enemy"
	self.german_flamer.priority_shout = "shout_loud_flamer"
	self.german_flamer.priority_waypoint = "waypoint_special_mark_flamer"
	self.german_flamer.deathguard = true
	self.german_flamer.no_equip_anim = true
	self.german_flamer.never_strafe = true
	self.german_flamer.wall_fwd_offset = 100
	self.german_flamer.calls_in = nil
	self.german_flamer.damage.explosion_damage_mul = 0.665
	self.german_flamer.damage.fire_damage_mul = 0.011
	self.german_flamer.critical_hits.damage_mul = 1.2
	self.german_flamer.damage.hurt_severity = deep_clone(presets.hurt_severities.no_hurts)
	self.german_flamer.damage.hurt_severity.explosion = {
		health_reference = "current",
		zones = {
			{
				none = 1,
				health_limit = 0.1
			},
			{
				explode = 0.5,
				none = 0.5,
				health_limit = 0.5
			},
			{
				explode = 1
			}
		}
	}
	self.german_flamer.damage.ignore_knockdown = true
	self.german_flamer.use_animation_on_fire_damage = false
	self.german_flamer.flammable = true
	self.german_flamer.loadout = self.npc_loadouts.special_flamethrower
	self.german_flamer.weapon = {}
	local max_range = 1200
	self.german_flamer.weapon.ak47 = {
		aim_delay = {
			0.05,
			0.1
		},
		focus_delay = 7,
		focus_dis = 200,
		spread = 15,
		miss_dis = max_range - 100,
		RELOAD_SPEED = 1,
		melee_speed = 1,
		melee_dmg = 2,
		melee_retry_delay = {
			1,
			2
		},
		max_range = max_range,
		additional_weapon_stats = {
			shooting_duration = 2.5,
			cooldown_duration = 0.76
		},
		range = {
			far = 500,
			optimal = 400,
			close = 300
		},
		autofire_rounds = {
			25,
			50
		},
		FALLOFF = {
			{
				dmg_mul = 2,
				r = 400,
				acc = {
					1,
					1
				},
				recoil = {
					0,
					0
				},
				mode = {
					0,
					2,
					4,
					10
				}
			},
			{
				dmg_mul = 0.5,
				r = 1000,
				acc = {
					1,
					1
				},
				recoil = {
					0,
					0
				},
				mode = {
					0,
					2,
					4,
					10
				}
			},
			{
				dmg_mul = 0.25,
				r = max_range,
				acc = {
					1,
					1
				},
				recoil = {
					0,
					0
				},
				mode = {
					0,
					2,
					4,
					10
				}
			}
		},
		SUPPRESSION_ACC_CHANCE = 1
	}

	self:_process_weapon_usage_table(self.german_flamer.weapon)

	self.german_flamer.throwable = {
		throw_chance = 0.15,
		projectile_id = "flamer_incendiary",
		cooldown = 30
	}
	self.german_flamer.speech_prefix_p1 = "ger"
	self.german_flamer.speech_prefix_p2 = "flamer"
	self.german_flamer.speech_prefix_count = 4
	self.german_flamer.access = "tank"
	self.german_flamer.chatter = presets.enemy_chatter.special
	self.german_flamer.announce_incomming = "incomming_flamer"
	self.german_flamer.steal_loot = nil
	self.german_flamer.use_animation_on_fire_damage = false
	self.german_flamer.type = CharacterTweakData.ENEMY_TYPE_FLAMER
	self.german_flamer.dismemberment_enabled = false
	self.german_flamer.is_special = true
	self.german_flamer.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_FLAMER
	self.german_flamer.dont_modify_weapon_usage = true
end

function CharacterTweakData:_init_german_sniper(presets)
	self.german_sniper = deep_clone(presets.base)
	self.german_sniper.experience = {}
	self.german_sniper.detection = presets.detection.sniper
	self.german_sniper.vision = presets.vision.easy
	self.german_sniper.HEALTH_INIT = 80
	self.german_sniper.BASE_HEALTH_INIT = 80
	self.german_sniper.headshot_dmg_mul = 4
	self.german_sniper.allowed_stances = {
		cbt = true
	}
	self.german_sniper.move_speed = presets.move_speed.normal
	self.german_sniper.suppression = presets.suppression.easy
	self.german_sniper.loot_table = "normal_enemy"
	self.german_sniper.ecm_vulnerability = 0
	self.german_sniper.ecm_hurts = {
		ears = {
			min_duration = 7,
			max_duration = 9
		}
	}
	self.german_sniper.priority_shout = "shout_loud_sniper"
	self.german_sniper.priority_waypoint = "waypoint_special_mark_sniper"
	self.german_sniper.deathguard = false
	self.german_sniper.no_equip_anim = true
	self.german_sniper.wall_fwd_offset = 100
	self.german_sniper.damage.explosion_damage_mul = 1
	self.german_sniper.calls_in = nil
	self.german_sniper.allowed_poses = {
		stand = true
	}
	self.german_sniper.always_face_enemy = true
	self.german_sniper.crouch_move = true
	self.german_sniper.use_animation_on_fire_damage = true
	self.german_sniper.flammable = true
	self.german_sniper.weapon = presets.weapon.sniper

	self:_process_weapon_usage_table(self.german_sniper.weapon)

	self.german_sniper.dont_modify_weapon_usage = true
	self.german_sniper.speech_prefix_p1 = "ger"
	self.german_sniper.speech_prefix_p2 = "elite"
	self.german_sniper.speech_prefix_count = 4
	self.german_sniper.access = "sniper"
	self.german_sniper.chatter = presets.enemy_chatter.no_chatter
	self.german_sniper.announce_incomming = "incomming_sniper"
	self.german_sniper.dodge = presets.dodge.athletic
	self.german_sniper.steal_loot = nil
	self.german_sniper.use_animation_on_fire_damage = false
	self.german_sniper.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_sniper.dismemberment_enabled = false
	self.german_sniper.is_special = true
	self.german_sniper.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_SNIPER
	self.german_sniper.damage.hurt_severity = deep_clone(presets.hurt_severities.base)
	self.german_sniper.damage.hurt_severity.bullet = {
		health_reference = "current",
		zones = {
			{
				none = 1,
				health_limit = 0.01
			},
			{
				none = 1,
				health_limit = 0.3,
				moderate = 0,
				light = 0,
				heavy = 0
			},
			{
				none = 1,
				health_limit = 0.6,
				moderate = 0,
				light = 0,
				heavy = 0
			},
			{
				none = 1,
				health_limit = 0.9,
				moderate = 0,
				light = 0,
				heavy = 0
			},
			{
				moderate = 0,
				light = 0,
				none = 1,
				heavy = 0
			}
		}
	}
	self.german_sniper.loadout = self.npc_loadouts.special_sniper

	table.insert(self._enemies_list, "german_sniper")
end

function CharacterTweakData:_init_german_spotter(presets)
	self.german_spotter = deep_clone(presets.base)
	self.german_spotter.experience = {}
	self.german_spotter.weapon = presets.weapon.expert
	self.german_spotter.detection = presets.detection.normal
	self.german_spotter.vision = presets.vision.spotter
	self.german_spotter.HEALTH_INIT = 80
	self.german_spotter.BASE_HEALTH_INIT = 80
	self.german_spotter.headshot_dmg_mul = 4
	self.german_spotter.move_speed = presets.move_speed.slow
	self.german_spotter.crouch_move = false
	self.german_spotter.suppression = presets.suppression.hard_agg
	self.german_spotter.ecm_vulnerability = 1
	self.german_spotter.ecm_hurts = {
		ears = {
			min_duration = 8,
			max_duration = 10
		}
	}
	self.german_spotter.speech_prefix_p1 = "ger"
	self.german_spotter.speech_prefix_p2 = "elite"
	self.german_spotter.speech_prefix_count = 4
	self.german_spotter.access = "sniper"
	self.german_spotter.silent_priority_shout = "f37"
	self.german_spotter.priority_shout = "shout_loud_spotter"
	self.german_spotter.priority_waypoint = "waypoint_special_mark_spotter"
	self.german_spotter.dodge = presets.dodge.poor
	self.german_spotter.deathguard = false
	self.german_spotter.chatter = presets.enemy_chatter.special
	self.german_spotter.steal_loot = false
	self.german_spotter.loot_table = "normal_enemy"
	self.german_spotter.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_spotter.damage.hurt_severity = deep_clone(presets.hurt_severities.base)
	self.german_spotter.damage.hurt_severity.bullet = {
		health_reference = "current",
		zones = {
			{
				none = 1,
				health_limit = 0.01
			},
			{
				none = 1,
				health_limit = 0.3,
				moderate = 0,
				light = 0,
				heavy = 0
			},
			{
				none = 1,
				health_limit = 0.6,
				moderate = 0,
				light = 0,
				heavy = 0
			},
			{
				none = 1,
				health_limit = 0.9,
				moderate = 0,
				light = 0,
				heavy = 0
			},
			{
				moderate = 0,
				light = 0,
				none = 1,
				heavy = 0
			}
		}
	}
	self.german_spotter.loadout = self.npc_loadouts.special_spotter
	self.german_spotter.dismemberment_enabled = false
	self.german_spotter.is_special = true
	self.german_spotter.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_SPOTTER
	self.german_spotter.dont_modify_weapon_usage = true

	table.insert(self._enemies_list, "german_spotter")
end

function CharacterTweakData:_init_escort(presets)
	self.escort = deep_clone(self.civilian)
	self.escort.HEALTH_INIT = 5
	self.escort.is_escort = true
	self.escort.escort_idle_talk = true
	self.escort.outline_on_discover = true
	self.escort.calls_in = nil
	self.escort.escort_safe_dist = 800
	self.escort.escort_scared_dist = 220
	self.escort.intimidateable = false
	self.escort.damage = presets.base.damage
end

function CharacterTweakData:_init_upd_fb(presets)
	self.fb_german_commander = deep_clone(self.german_commander)
	self.fb_german_commander.move_speed = presets.move_speed.very_fast
	self.fb_german_commander.dodge = presets.dodge.poor
	self.fb_german_commander.allowed_poses = {
		stand = true
	}
	self.fb_german_commander.speech_prefix_p1 = "ger"
	self.fb_german_commander.speech_prefix_p2 = "fb_commander"
	self.fb_german_commander.speech_prefix_count = 1
	self.fb_german_commander.chatter = presets.enemy_chatter.no_chatter
	self.fb_german_commander.crouch_move = false
	self.fb_german_commander.gear = nil
	self.fb_german_commander.silent_priority_shout = nil
	self.fb_german_commander.priority_shout = nil
	self.fb_german_commander_boss = deep_clone(self.fb_german_commander)
	self.fb_german_commander_boss.HEALTH_INIT = 2500
	self.fb_german_commander_boss.BASE_HEALTH_INIT = 2500
	self.fb_german_commander_boss.headshot_dmg_mul = 0.8
	self.fb_german_commander_boss.headshot_helmet = true
	self.fb_german_commander_boss.damage.hurt_severity = deep_clone(presets.hurt_severities.no_hurts)
	self.fb_german_commander_boss.damage.hurt_severity.explosion = {
		health_reference = "current",
		zones = {
			{
				none = 1,
				health_limit = 0.3
			},
			{
				explode = 0.1,
				none = 0.7,
				health_limit = 0.7
			},
			{
				none = 0.5,
				explode = 0.5
			}
		}
	}
	self.fb_german_commander_boss.gear = self.german_commander.gear

	table.insert(self._enemies_list, "fb_german_commander_boss")
end

function CharacterTweakData:_presets(tweak_data)
	local presets = {
		hurt_severities = {}
	}
	presets.hurt_severities.no_hurts = {
		bullet = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		explosion = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		melee = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		fire = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		},
		poison = {
			health_reference = 1,
			zones = {
				{
					none = 1
				}
			}
		}
	}
	presets.hurt_severities.only_explosion_hurts = deep_clone(presets.hurt_severities.no_hurts)
	presets.hurt_severities.only_explosion_hurts.explosion = {
		health_reference = 1,
		zones = {
			{
				explode = 1
			}
		}
	}
	presets.hurt_severities.base = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					none = 1,
					health_limit = 0.01
				},
				{
					none = 0.2,
					health_limit = 0.3,
					moderate = 0.05,
					light = 0.7,
					heavy = 0.05
				},
				{
					moderate = 0.4,
					light = 0.4,
					heavy = 0.2,
					health_limit = 0.6
				},
				{
					moderate = 0.2,
					light = 0.2,
					heavy = 0.6,
					health_limit = 0.9
				},
				{
					moderate = 0,
					light = 0,
					heavy = 1
				}
			}
		},
		explosion = {
			health_reference = "current",
			zones = {
				{
					none = 1,
					health_limit = 0.01
				},
				{
					heavy = 0.4,
					none = 0.6,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					heavy = 0.2,
					explode = 0.8
				}
			}
		},
		melee = {
			health_reference = "current",
			zones = {
				{
					none = 1,
					health_limit = 0.01
				},
				{
					none = 0.3,
					health_limit = 0.3,
					moderate = 0,
					light = 0.7,
					heavy = 0
				},
				{
					moderate = 0,
					light = 1,
					heavy = 0,
					health_limit = 0.8
				},
				{
					moderate = 0.2,
					light = 0.6,
					heavy = 0.2,
					health_limit = 0.9
				},
				{
					moderate = 0,
					light = 0,
					heavy = 9
				}
			}
		},
		fire = {
			health_reference = "current",
			zones = {
				{
					none = 1,
					health_limit = 0.01
				},
				{
					fire = 1
				}
			}
		},
		poison = {
			health_reference = "current",
			zones = {
				{
					none = 1,
					health_limit = 0.01
				},
				{
					none = 0,
					poison = 1
				}
			}
		}
	}
	presets.base = {
		HEALTH_INIT = 2.5,
		headshot_dmg_mul = 1,
		SPEED_WALK = {
			cbt = 160,
			pnc = 160,
			hos = 180,
			ntl = 120
		},
		SPEED_RUN = 370,
		crouch_move = true,
		shooting_death = true,
		suspicious = true,
		submission_max = {
			45,
			60
		},
		submission_intimidate = 15,
		speech_prefix = "po",
		speech_prefix_count = 1,
		use_radio = nil,
		dodge = nil,
		challenges = {
			type = "law"
		},
		calls_in = true,
		dead_body_drop_sound = "body_fall",
		shout_radius = 260,
		shout_radius_difficulty = {
			200,
			500,
			1000,
			1200
		},
		kill_shout_chance = 0,
		experience = {},
		critical_hits = {}
	}
	presets.base.critical_hits.damage_mul = 1.5
	presets.base.damage = {
		hurt_severity = presets.hurt_severities.base,
		death_severity = 0.75,
		explosion_damage_mul = 1
	}
	presets.base.dismemberment_enabled = true
	presets.gang_member_damage = {
		MIN_DAMAGE_INTERVAL = 0.25,
		explosion_damage_mul = 0.8,
		fire_damage_mul = 0.6,
		reviving_damage_mul = 0.75,
		HEALTH_INIT = 100,
		REGENERATE_RATIO = 0.09,
		DISTANCE_IS_AWAY = 1000000,
		REGENERATE_TIME_AWAY = 2,
		REGENERATE_TIME = 1,
		DOWNED_TIME = tweak_data.player.damage.DOWNED_TIME,
		TASED_TIME = tweak_data.player.damage.TASED_TIME,
		hurt_severity = presets.hurt_severities.only_explosion_hurts
	}
	local shotgun_aim_delay = {
		2,
		4
	}
	local rifle_aim_delay = {
		1.5,
		3
	}
	local smg_aim_delay = {
		0.5,
		1
	}
	local pistol_aim_delay = {
		0.1,
		0.3
	}
	presets.weapon = {
		normal = {
			ger_kar98_npc = {},
			ger_luger_npc = {},
			ger_mp38_npc = {},
			ger_stg44_npc = {},
			usa_garand_npc = {},
			usa_m1911_npc = {},
			usa_thomspon_npc = {},
			ger_geco_npc = {}
		}
	}
	presets.weapon.normal.usa_garand_npc.aim_delay = rifle_aim_delay
	presets.weapon.normal.usa_garand_npc.focus_delay = 10
	presets.weapon.normal.usa_garand_npc.focus_dis = 200
	presets.weapon.normal.usa_garand_npc.spread = 20
	presets.weapon.normal.usa_garand_npc.miss_dis = 40
	presets.weapon.normal.usa_garand_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.usa_garand_npc.melee_speed = 1
	presets.weapon.normal.usa_garand_npc.melee_dmg = 2
	presets.weapon.normal.usa_garand_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.usa_garand_npc.range = {
		far = 5000,
		optimal = 3500,
		close = 1000
	}
	presets.weapon.normal.usa_garand_npc.autofire_rounds = {
		3,
		6
	}
	presets.weapon.normal.usa_garand_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.2,
				0.5
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.normal.usa_m1911_npc.aim_delay = pistol_aim_delay
	presets.weapon.normal.usa_m1911_npc.focus_delay = 10
	presets.weapon.normal.usa_m1911_npc.focus_dis = 200
	presets.weapon.normal.usa_m1911_npc.spread = 20
	presets.weapon.normal.usa_m1911_npc.miss_dis = 50
	presets.weapon.normal.usa_m1911_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.usa_m1911_npc.melee_speed = 1
	presets.weapon.normal.usa_m1911_npc.melee_dmg = 2
	presets.weapon.normal.usa_m1911_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.usa_m1911_npc.range = {
		far = 5000,
		optimal = 3500,
		close = 1000
	}
	presets.weapon.normal.usa_m1911_npc.FALLOFF = {
		{
			dmg_mul = 1,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.15,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 500,
			acc = {
				0.4,
				0.85
			},
			recoil = {
				0.15,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 1000,
			acc = {
				0.375,
				0.55
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.25,
				0.45
			},
			recoil = {
				0.3,
				0.7
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				0.4,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.normal.usa_thomspon_npc.aim_delay = smg_aim_delay
	presets.weapon.normal.usa_thomspon_npc.focus_delay = 10
	presets.weapon.normal.usa_thomspon_npc.focus_dis = 200
	presets.weapon.normal.usa_thomspon_npc.spread = 15
	presets.weapon.normal.usa_thomspon_npc.miss_dis = 20
	presets.weapon.normal.usa_thomspon_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.usa_thomspon_npc.melee_speed = 1
	presets.weapon.normal.usa_thomspon_npc.melee_dmg = 2
	presets.weapon.normal.usa_thomspon_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.usa_thomspon_npc.range = {
		far = 5000,
		optimal = 3500,
		close = 1000
	}
	presets.weapon.normal.usa_thomspon_npc.autofire_rounds = {
		3,
		6
	}
	presets.weapon.normal.usa_thomspon_npc.FALLOFF = {
		{
			dmg_mul = 1,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.3,
				0.4
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.1,
				0.45
			},
			recoil = {
				0.3,
				0.4
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				0.5,
				0.6
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	presets.weapon.normal.ger_kar98_npc.aim_delay = rifle_aim_delay
	presets.weapon.normal.ger_kar98_npc.focus_delay = 2
	presets.weapon.normal.ger_kar98_npc.focus_dis = 200
	presets.weapon.normal.ger_kar98_npc.spread = 20
	presets.weapon.normal.ger_kar98_npc.miss_dis = 40
	presets.weapon.normal.ger_kar98_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.ger_kar98_npc.melee_speed = 1
	presets.weapon.normal.ger_kar98_npc.melee_dmg = 5
	presets.weapon.normal.ger_kar98_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.ger_kar98_npc.range = {
		far = 6000,
		optimal = 3500,
		close = 2400
	}
	presets.weapon.normal.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 1600,
			acc = {
				0.3,
				0.7
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 3500,
			acc = {
				0.1,
				0.7
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 4000,
			acc = {
				0.035,
				0.55
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.1,
			r = 5000,
			acc = {
				0.035,
				0.25
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.normal.ger_luger_npc.aim_delay = pistol_aim_delay
	presets.weapon.normal.ger_luger_npc.focus_delay = 2
	presets.weapon.normal.ger_luger_npc.focus_dis = 200
	presets.weapon.normal.ger_luger_npc.spread = 20
	presets.weapon.normal.ger_luger_npc.miss_dis = 50
	presets.weapon.normal.ger_luger_npc.RELOAD_SPEED = 1
	presets.weapon.normal.ger_luger_npc.melee_speed = 1
	presets.weapon.normal.ger_luger_npc.melee_dmg = 5
	presets.weapon.normal.ger_luger_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.ger_luger_npc.range = {
		far = 2200,
		optimal = 1200,
		close = 600
	}
	presets.weapon.normal.ger_luger_npc.FALLOFF = {
		{
			dmg_mul = 1.5,
			r = 800,
			acc = {
				0.7,
				0.8
			},
			recoil = {
				0.65,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 1500,
			acc = {
				0.2,
				0.7
			},
			recoil = {
				0.65,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 2000,
			acc = {
				0.05,
				0.55
			},
			recoil = {
				0.8,
				1.2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 2500,
			acc = {
				0.05,
				0.25
			},
			recoil = {
				0.9,
				1.5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.normal.ger_mp38_npc.aim_delay = smg_aim_delay
	presets.weapon.normal.ger_mp38_npc.focus_delay = 2
	presets.weapon.normal.ger_mp38_npc.focus_dis = 200
	presets.weapon.normal.ger_mp38_npc.spread = 35
	presets.weapon.normal.ger_mp38_npc.miss_dis = 20
	presets.weapon.normal.ger_mp38_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.ger_mp38_npc.melee_speed = 1
	presets.weapon.normal.ger_mp38_npc.melee_dmg = 5
	presets.weapon.normal.ger_mp38_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.ger_mp38_npc.range = {
		far = 2400,
		optimal = 2200,
		close = 1000
	}
	presets.weapon.normal.ger_mp38_npc.autofire_rounds = {
		3,
		6
	}
	presets.weapon.normal.ger_mp38_npc.FALLOFF = {
		{
			dmg_mul = 1.5,
			r = 1400,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.2,
				0.7
			},
			recoil = {
				0.3,
				0.4
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 2500,
			acc = {
				0.05,
				0.55
			},
			recoil = {
				0.5,
				0.6
			},
			mode = {
				1,
				3,
				2,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 3000,
			acc = {
				0.05,
				0.25
			},
			recoil = {
				0.5,
				0.6
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	presets.weapon.normal.ger_stg44_npc.aim_delay = rifle_aim_delay
	presets.weapon.normal.ger_stg44_npc.focus_delay = 4
	presets.weapon.normal.ger_stg44_npc.focus_dis = 200
	presets.weapon.normal.ger_stg44_npc.spread = 20
	presets.weapon.normal.ger_stg44_npc.miss_dis = 40
	presets.weapon.normal.ger_stg44_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.ger_stg44_npc.melee_speed = 1
	presets.weapon.normal.ger_stg44_npc.melee_dmg = 5
	presets.weapon.normal.ger_stg44_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.ger_stg44_npc.range = {
		far = 2600,
		optimal = 2400,
		close = 1200
	}
	presets.weapon.normal.ger_stg44_npc.autofire_rounds = {
		3,
		6
	}
	presets.weapon.normal.ger_stg44_npc.FALLOFF = {
		{
			dmg_mul = 1,
			r = 1800,
			acc = {
				0.4,
				0.7
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 2500,
			acc = {
				0.2,
				0.7
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.25,
			r = 3000,
			acc = {
				0.05,
				0.55
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 4000,
			acc = {
				0.05,
				0.25
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	presets.weapon.normal.ger_geco_npc.aim_delay = shotgun_aim_delay
	presets.weapon.normal.ger_geco_npc.focus_delay = 4
	presets.weapon.normal.ger_geco_npc.focus_dis = 200
	presets.weapon.normal.ger_geco_npc.spread = 15
	presets.weapon.normal.ger_geco_npc.miss_dis = 20
	presets.weapon.normal.ger_geco_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.ger_geco_npc.melee_speed = 1
	presets.weapon.normal.ger_geco_npc.melee_dmg = 5
	presets.weapon.normal.ger_geco_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.ger_geco_npc.range = {
		far = 1000,
		optimal = 800,
		close = 600
	}
	presets.weapon.normal.ger_geco_npc.FALLOFF = {
		{
			dmg_mul = 1,
			r = 600,
			acc = {
				0.6,
				0.7
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.3,
			r = 1000,
			acc = {
				0.2,
				0.7
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.25,
			r = 1200,
			acc = {
				0.05,
				0.55
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 2000,
			acc = {
				0.05,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.normal.ger_geco_npc.SUPPRESSION_ACC_CHANCE = 0.25
	presets.weapon.good = {
		ger_kar98_npc = {},
		ger_luger_npc = {},
		ger_mp38_npc = {},
		ger_stg44_npc = {},
		usa_garand_npc = {},
		usa_m1911_npc = {},
		usa_thomspon_npc = {},
		ger_geco_npc = {}
	}
	presets.weapon.good.usa_garand_npc.aim_delay = rifle_aim_delay
	presets.weapon.good.usa_garand_npc.focus_delay = 2
	presets.weapon.good.usa_garand_npc.focus_dis = 200
	presets.weapon.good.usa_garand_npc.spread = 20
	presets.weapon.good.usa_garand_npc.miss_dis = 40
	presets.weapon.good.usa_garand_npc.RELOAD_SPEED = 1
	presets.weapon.good.usa_garand_npc.melee_speed = 1
	presets.weapon.good.usa_garand_npc.melee_dmg = 2
	presets.weapon.good.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.good.usa_garand_npc.range = {
		far = 5000,
		optimal = 3500,
		close = 1000
	}
	presets.weapon.good.usa_garand_npc.autofire_rounds = presets.weapon.normal.usa_garand_npc.autofire_rounds
	presets.weapon.good.usa_garand_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.2,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.2,
				0.5
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.good.usa_m1911_npc.aim_delay = pistol_aim_delay
	presets.weapon.good.usa_m1911_npc.focus_delay = 2
	presets.weapon.good.usa_m1911_npc.focus_dis = 200
	presets.weapon.good.usa_m1911_npc.spread = 20
	presets.weapon.good.usa_m1911_npc.miss_dis = 50
	presets.weapon.good.usa_m1911_npc.RELOAD_SPEED = 1
	presets.weapon.good.usa_m1911_npc.melee_speed = presets.weapon.normal.usa_m1911_npc.melee_speed
	presets.weapon.good.usa_m1911_npc.melee_dmg = presets.weapon.normal.usa_m1911_npc.melee_dmg
	presets.weapon.good.usa_m1911_npc.melee_retry_delay = presets.weapon.normal.usa_m1911_npc.melee_retry_delay
	presets.weapon.good.usa_m1911_npc.range = presets.weapon.normal.usa_m1911_npc.range
	presets.weapon.good.usa_m1911_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.15,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				0.5,
				0.85
			},
			recoil = {
				0.15,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.375,
				0.55
			},
			recoil = {
				0.15,
				0.4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.25,
				0.45
			},
			recoil = {
				0.4,
				0.9
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.01,
				0.35
			},
			recoil = {
				0.4,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.good.usa_thomspon_npc.aim_delay = smg_aim_delay
	presets.weapon.good.usa_thomspon_npc.focus_delay = 2
	presets.weapon.good.usa_thomspon_npc.focus_dis = 200
	presets.weapon.good.usa_thomspon_npc.spread = 15
	presets.weapon.good.usa_thomspon_npc.miss_dis = 10
	presets.weapon.good.usa_thomspon_npc.RELOAD_SPEED = 1
	presets.weapon.good.usa_thomspon_npc.melee_speed = presets.weapon.normal.usa_thomspon_npc.melee_speed
	presets.weapon.good.usa_thomspon_npc.melee_dmg = 5
	presets.weapon.good.usa_thomspon_npc.melee_retry_delay = presets.weapon.normal.usa_thomspon_npc.melee_retry_delay
	presets.weapon.good.usa_thomspon_npc.range = presets.weapon.normal.usa_thomspon_npc.range
	presets.weapon.good.usa_thomspon_npc.autofire_rounds = presets.weapon.normal.usa_thomspon_npc.autofire_rounds
	presets.weapon.good.usa_thomspon_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 500,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 1000,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.1,
				0.45
			},
			recoil = {
				0.35,
				0.6
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.1,
				0.35
			},
			recoil = {
				0.5,
				0.6
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	presets.weapon.good.ger_kar98_npc.aim_delay = rifle_aim_delay
	presets.weapon.good.ger_kar98_npc.focus_delay = 3
	presets.weapon.good.ger_kar98_npc.focus_dis = 200
	presets.weapon.good.ger_kar98_npc.spread = 20
	presets.weapon.good.ger_kar98_npc.miss_dis = 40
	presets.weapon.good.ger_kar98_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_kar98_npc.melee_speed = 1
	presets.weapon.good.ger_kar98_npc.melee_dmg = 5
	presets.weapon.good.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.good.ger_kar98_npc.range = {
		far = 4500,
		optimal = 3500,
		close = 2400
	}
	presets.weapon.good.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 2.5,
			r = 1600,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2300,
			acc = {
				0.35,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.1,
				0.65
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 4000,
			acc = {
				0.035,
				0.35
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.good.ger_luger_npc.aim_delay = pistol_aim_delay
	presets.weapon.good.ger_luger_npc.focus_delay = 3
	presets.weapon.good.ger_luger_npc.focus_dis = 200
	presets.weapon.good.ger_luger_npc.spread = 20
	presets.weapon.good.ger_luger_npc.miss_dis = 50
	presets.weapon.good.ger_luger_npc.RELOAD_SPEED = 1.2
	presets.weapon.good.ger_luger_npc.melee_speed = presets.weapon.normal.ger_luger_npc.melee_speed
	presets.weapon.good.ger_luger_npc.melee_dmg = 5
	presets.weapon.good.ger_luger_npc.melee_retry_delay = presets.weapon.normal.ger_luger_npc.melee_retry_delay
	presets.weapon.good.ger_luger_npc.range = {
		far = 2200,
		optimal = 1200,
		close = 600
	}
	presets.weapon.good.ger_luger_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 800,
			acc = {
				0.8,
				0.9
			},
			recoil = {
				0.45,
				0.5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 1500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.65
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				0.55,
				0.95
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 2500,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				0.65,
				1.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.good.ger_mp38_npc.aim_delay = smg_aim_delay
	presets.weapon.good.ger_mp38_npc.focus_delay = 3
	presets.weapon.good.ger_mp38_npc.focus_dis = 200
	presets.weapon.good.ger_mp38_npc.spread = 15
	presets.weapon.good.ger_mp38_npc.miss_dis = 10
	presets.weapon.good.ger_mp38_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_mp38_npc.melee_speed = presets.weapon.normal.ger_mp38_npc.melee_speed
	presets.weapon.good.ger_mp38_npc.melee_dmg = 5
	presets.weapon.good.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.good.ger_mp38_npc.range = {
		far = 2500,
		optimal = 2200,
		close = 1000
	}
	presets.weapon.good.ger_mp38_npc.autofire_rounds = presets.weapon.normal.ger_mp38_npc.autofire_rounds
	presets.weapon.good.ger_mp38_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 1400,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 2500,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				0.3,
				0.4
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 3500,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				0.5,
				0.6
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	presets.weapon.good.ger_stg44_npc.aim_delay = rifle_aim_delay
	presets.weapon.good.ger_stg44_npc.focus_delay = 3
	presets.weapon.good.ger_stg44_npc.focus_dis = 200
	presets.weapon.good.ger_stg44_npc.spread = 20
	presets.weapon.good.ger_stg44_npc.miss_dis = 40
	presets.weapon.good.ger_stg44_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_stg44_npc.melee_speed = 1
	presets.weapon.good.ger_stg44_npc.melee_dmg = 5
	presets.weapon.good.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.good.ger_stg44_npc.range = {
		far = 2600,
		optimal = 2400,
		close = 1200
	}
	presets.weapon.good.ger_stg44_npc.autofire_rounds = presets.weapon.normal.ger_stg44_npc.autofire_rounds
	presets.weapon.good.ger_stg44_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 1800,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 2500,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0.5,
			r = 3000,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 0,
			r = 3500,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	presets.weapon.good.ger_geco_npc.aim_delay = shotgun_aim_delay
	presets.weapon.good.ger_geco_npc.focus_delay = 3
	presets.weapon.good.ger_geco_npc.focus_dis = 200
	presets.weapon.good.ger_geco_npc.spread = 15
	presets.weapon.good.ger_geco_npc.miss_dis = 20
	presets.weapon.good.ger_geco_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_geco_npc.melee_speed = 1
	presets.weapon.good.ger_geco_npc.melee_dmg = 5
	presets.weapon.good.ger_geco_npc.melee_retry_delay = presets.weapon.normal.ger_geco_npc.melee_retry_delay
	presets.weapon.good.ger_geco_npc.range = {
		far = 2000,
		optimal = 1200,
		close = 600
	}
	presets.weapon.good.ger_geco_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 600,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.7,
			r = 1000,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 1500,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0,
			r = 2000,
			acc = {
				0.05,
				0.25
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.good.ger_geco_npc.SUPPRESSION_ACC_CHANCE = 0.3
	presets.weapon.expert = {
		ger_kar98_npc = {},
		ger_luger_npc = {},
		ger_mp38_npc = {},
		ger_stg44_npc = {},
		usa_garand_npc = {},
		usa_m1911_npc = {},
		usa_thomspon_npc = {},
		ger_geco_npc = {}
	}
	presets.weapon.expert.usa_garand_npc.aim_delay = rifle_aim_delay
	presets.weapon.expert.usa_garand_npc.focus_delay = 2
	presets.weapon.expert.usa_garand_npc.focus_dis = 200
	presets.weapon.expert.usa_garand_npc.spread = 20
	presets.weapon.expert.usa_garand_npc.miss_dis = 40
	presets.weapon.expert.usa_garand_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.usa_garand_npc.melee_speed = 1
	presets.weapon.expert.usa_garand_npc.melee_dmg = 2
	presets.weapon.expert.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.expert.usa_garand_npc.range = {
		far = 5000,
		optimal = 3500,
		close = 1000
	}
	presets.weapon.expert.usa_garand_npc.autofire_rounds = presets.weapon.normal.usa_garand_npc.autofire_rounds
	presets.weapon.expert.usa_garand_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.4,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 500,
			acc = {
				0.55,
				0.95
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 1000,
			acc = {
				0.525,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 2000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 3000,
			acc = {
				0.2,
				0.4
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.expert.usa_m1911_npc.aim_delay = pistol_aim_delay
	presets.weapon.expert.usa_m1911_npc.focus_delay = 2
	presets.weapon.expert.usa_m1911_npc.focus_dis = 200
	presets.weapon.expert.usa_m1911_npc.spread = 20
	presets.weapon.expert.usa_m1911_npc.miss_dis = 50
	presets.weapon.expert.usa_m1911_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.usa_m1911_npc.melee_speed = presets.weapon.normal.usa_m1911_npc.melee_speed
	presets.weapon.expert.usa_m1911_npc.melee_dmg = 2
	presets.weapon.expert.usa_m1911_npc.melee_retry_delay = presets.weapon.normal.usa_m1911_npc.melee_retry_delay
	presets.weapon.expert.usa_m1911_npc.range = presets.weapon.normal.usa_m1911_npc.range
	presets.weapon.expert.usa_m1911_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 100,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.15,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 4.5,
			r = 500,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 1000,
			acc = {
				0.4,
				0.65
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 2000,
			acc = {
				0.3,
				0.5
			},
			recoil = {
				0.4,
				0.9
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 3000,
			acc = {
				0.1,
				0.25
			},
			recoil = {
				0.4,
				1.4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.expert.usa_thomspon_npc.aim_delay = smg_aim_delay
	presets.weapon.expert.usa_thomspon_npc.focus_delay = 2
	presets.weapon.expert.usa_thomspon_npc.focus_dis = 200
	presets.weapon.expert.usa_thomspon_npc.spread = 15
	presets.weapon.expert.usa_thomspon_npc.miss_dis = 10
	presets.weapon.expert.usa_thomspon_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.usa_thomspon_npc.melee_speed = presets.weapon.normal.usa_thomspon_npc.melee_speed
	presets.weapon.expert.usa_thomspon_npc.melee_dmg = 10
	presets.weapon.expert.usa_thomspon_npc.melee_retry_delay = presets.weapon.normal.usa_thomspon_npc.melee_retry_delay
	presets.weapon.expert.usa_thomspon_npc.range = presets.weapon.normal.usa_thomspon_npc.range
	presets.weapon.expert.usa_thomspon_npc.autofire_rounds = presets.weapon.normal.usa_thomspon_npc.autofire_rounds
	presets.weapon.expert.usa_thomspon_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 100,
			acc = {
				0.6,
				0.95
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 4.5,
			r = 500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 4.5,
			r = 1000,
			acc = {
				0.4,
				0.65
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 2000,
			acc = {
				0.4,
				0.6
			},
			recoil = {
				0.35,
				0.7
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 3000,
			acc = {
				0.2,
				0.35
			},
			recoil = {
				0.5,
				1.5
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	presets.weapon.expert.ger_kar98_npc.aim_delay = rifle_aim_delay
	presets.weapon.expert.ger_kar98_npc.focus_delay = 2
	presets.weapon.expert.ger_kar98_npc.focus_dis = 200
	presets.weapon.expert.ger_kar98_npc.spread = 20
	presets.weapon.expert.ger_kar98_npc.miss_dis = 40
	presets.weapon.expert.ger_kar98_npc.RELOAD_SPEED = 1.1
	presets.weapon.expert.ger_kar98_npc.melee_speed = 1
	presets.weapon.expert.ger_kar98_npc.melee_dmg = 10
	presets.weapon.expert.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.expert.ger_kar98_npc.range = {
		far = 3000,
		optimal = 2600,
		close = 1400
	}
	presets.weapon.expert.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 4,
			r = 1600,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 2300,
			acc = {
				0.4,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.1,
				0.65
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3500,
			acc = {
				0.035,
				0.35
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.expert.ger_luger_npc.aim_delay = pistol_aim_delay
	presets.weapon.expert.ger_luger_npc.focus_delay = 2
	presets.weapon.expert.ger_luger_npc.focus_dis = 200
	presets.weapon.expert.ger_luger_npc.spread = 20
	presets.weapon.expert.ger_luger_npc.miss_dis = 50
	presets.weapon.expert.ger_luger_npc.RELOAD_SPEED = 1.3
	presets.weapon.expert.ger_luger_npc.melee_speed = presets.weapon.normal.ger_luger_npc.melee_speed
	presets.weapon.expert.ger_luger_npc.melee_dmg = 10
	presets.weapon.expert.ger_luger_npc.melee_retry_delay = presets.weapon.normal.ger_luger_npc.melee_retry_delay
	presets.weapon.expert.ger_luger_npc.range = {
		far = 2200,
		optimal = 1200,
		close = 600
	}
	presets.weapon.expert.ger_luger_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 800,
			acc = {
				0.8,
				0.9
			},
			recoil = {
				0.35,
				0.4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 1500,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.35,
				0.55
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				0.45,
				0.85
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2500,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				0.55,
				1.15
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.expert.ger_mp38_npc.aim_delay = smg_aim_delay
	presets.weapon.expert.ger_mp38_npc.focus_delay = 2
	presets.weapon.expert.ger_mp38_npc.focus_dis = 200
	presets.weapon.expert.ger_mp38_npc.spread = 15
	presets.weapon.expert.ger_mp38_npc.miss_dis = 10
	presets.weapon.expert.ger_mp38_npc.RELOAD_SPEED = 1.1
	presets.weapon.expert.ger_mp38_npc.melee_speed = presets.weapon.normal.ger_mp38_npc.melee_speed
	presets.weapon.expert.ger_mp38_npc.melee_dmg = 10
	presets.weapon.expert.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.expert.ger_mp38_npc.range = {
		far = 1400,
		optimal = 1200,
		close = 1000
	}
	presets.weapon.expert.ger_mp38_npc.autofire_rounds = presets.weapon.normal.ger_mp38_npc.autofire_rounds
	presets.weapon.expert.ger_mp38_npc.FALLOFF = {
		{
			dmg_mul = 4,
			r = 1400,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 3,
			r = 2000,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 2500,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 3000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				0.35,
				0.7
			},
			mode = {
				0,
				3,
				3,
				0
			}
		}
	}
	presets.weapon.expert.ger_stg44_npc.aim_delay = rifle_aim_delay
	presets.weapon.expert.ger_stg44_npc.focus_delay = 2
	presets.weapon.expert.ger_stg44_npc.focus_dis = 200
	presets.weapon.expert.ger_stg44_npc.spread = 20
	presets.weapon.expert.ger_stg44_npc.miss_dis = 40
	presets.weapon.expert.ger_stg44_npc.RELOAD_SPEED = 1.1
	presets.weapon.expert.ger_stg44_npc.melee_speed = 1
	presets.weapon.expert.ger_stg44_npc.melee_dmg = 10
	presets.weapon.expert.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.expert.ger_stg44_npc.range = {
		far = 3200,
		optimal = 2400,
		close = 1200
	}
	presets.weapon.expert.ger_stg44_npc.autofire_rounds = presets.weapon.normal.ger_stg44_npc.autofire_rounds
	presets.weapon.expert.ger_stg44_npc.FALLOFF = {
		{
			dmg_mul = 5,
			r = 1800,
			acc = {
				0.6,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 3,
			r = 2500,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 1,
			r = 3500,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	presets.weapon.expert.ger_geco_npc.aim_delay = shotgun_aim_delay
	presets.weapon.expert.ger_geco_npc.focus_delay = 2
	presets.weapon.expert.ger_geco_npc.focus_dis = 200
	presets.weapon.expert.ger_geco_npc.spread = 15
	presets.weapon.expert.ger_geco_npc.miss_dis = 20
	presets.weapon.expert.ger_geco_npc.RELOAD_SPEED = 1.1
	presets.weapon.expert.ger_geco_npc.melee_speed = 1
	presets.weapon.expert.ger_geco_npc.melee_dmg = 10
	presets.weapon.expert.ger_geco_npc.melee_retry_delay = presets.weapon.normal.ger_geco_npc.melee_retry_delay
	presets.weapon.expert.ger_geco_npc.range = {
		far = 1000,
		optimal = 900,
		close = 600
	}
	presets.weapon.expert.ger_geco_npc.FALLOFF = {
		{
			dmg_mul = 5,
			r = 600,
			acc = {
				0.8,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 1000,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1500,
			acc = {
				0.15,
				0.65
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.05,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.expert.ger_geco_npc.SUPPRESSION_ACC_CHANCE = 0.35
	presets.weapon.insane = {
		ger_kar98_npc = {},
		ger_luger_npc = {},
		ger_mp38_npc = {},
		ger_stg44_npc = {},
		usa_garand_npc = {},
		usa_m1911_npc = {},
		usa_thomspon_npc = {},
		ger_geco_npc = {}
	}
	presets.weapon.insane.usa_garand_npc.aim_delay = rifle_aim_delay
	presets.weapon.insane.usa_garand_npc.focus_delay = 2
	presets.weapon.insane.usa_garand_npc.focus_dis = 200
	presets.weapon.insane.usa_garand_npc.spread = 20
	presets.weapon.insane.usa_garand_npc.miss_dis = 40
	presets.weapon.insane.usa_garand_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.usa_garand_npc.melee_speed = 1
	presets.weapon.insane.usa_garand_npc.melee_dmg = 2
	presets.weapon.insane.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.insane.usa_garand_npc.range = {
		far = 5000,
		optimal = 3000,
		close = 1000
	}
	presets.weapon.insane.usa_garand_npc.autofire_rounds = presets.weapon.normal.usa_garand_npc.autofire_rounds
	presets.weapon.insane.usa_garand_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.4,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 500,
			acc = {
				0.7,
				0.95
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 1000,
			acc = {
				0.5,
				0.8
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 2000,
			acc = {
				0.5,
				0.7
			},
			recoil = {
				0.4,
				1.2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 3000,
			acc = {
				0.3,
				0.4
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.insane.usa_m1911_npc.aim_delay = pistol_aim_delay
	presets.weapon.insane.usa_m1911_npc.focus_delay = 2
	presets.weapon.insane.usa_m1911_npc.focus_dis = 200
	presets.weapon.insane.usa_m1911_npc.spread = 20
	presets.weapon.insane.usa_m1911_npc.miss_dis = 50
	presets.weapon.insane.usa_m1911_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.usa_m1911_npc.melee_speed = presets.weapon.normal.usa_m1911_npc.melee_speed
	presets.weapon.insane.usa_m1911_npc.melee_dmg = 2
	presets.weapon.insane.usa_m1911_npc.melee_retry_delay = presets.weapon.normal.usa_m1911_npc.melee_retry_delay
	presets.weapon.insane.usa_m1911_npc.range = presets.weapon.normal.usa_m1911_npc.range
	presets.weapon.insane.usa_m1911_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 100,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.15,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 4.5,
			r = 500,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 1000,
			acc = {
				0.5,
				0.65
			},
			recoil = {
				0.15,
				0.3
			},
			mode = {
				1,
				0,
				1,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 2000,
			acc = {
				0.5,
				0.5
			},
			recoil = {
				0.4,
				0.9
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 3000,
			acc = {
				0.3,
				0.25
			},
			recoil = {
				0.4,
				1.4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.insane.usa_thomspon_npc.aim_delay = smg_aim_delay
	presets.weapon.insane.usa_thomspon_npc.focus_delay = 2
	presets.weapon.insane.usa_thomspon_npc.focus_dis = 200
	presets.weapon.insane.usa_thomspon_npc.spread = 15
	presets.weapon.insane.usa_thomspon_npc.miss_dis = 10
	presets.weapon.insane.usa_thomspon_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.usa_thomspon_npc.melee_speed = presets.weapon.normal.usa_thomspon_npc.melee_speed
	presets.weapon.insane.usa_thomspon_npc.melee_dmg = 10
	presets.weapon.insane.usa_thomspon_npc.melee_retry_delay = presets.weapon.normal.usa_thomspon_npc.melee_retry_delay
	presets.weapon.insane.usa_thomspon_npc.range = presets.weapon.normal.usa_thomspon_npc.range
	presets.weapon.insane.usa_thomspon_npc.autofire_rounds = presets.weapon.normal.usa_thomspon_npc.autofire_rounds
	presets.weapon.insane.usa_thomspon_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 100,
			acc = {
				0.7,
				0.95
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 4.5,
			r = 500,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 4.5,
			r = 1000,
			acc = {
				0.5,
				0.65
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 2000,
			acc = {
				0.5,
				0.6
			},
			recoil = {
				0.35,
				0.7
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 4.5,
			r = 3000,
			acc = {
				0.3,
				0.35
			},
			recoil = {
				0.5,
				1.5
			},
			mode = {
				1,
				3,
				2,
				0
			}
		}
	}
	presets.weapon.insane.ger_kar98_npc.aim_delay = rifle_aim_delay
	presets.weapon.insane.ger_kar98_npc.focus_delay = 2
	presets.weapon.insane.ger_kar98_npc.focus_dis = 200
	presets.weapon.insane.ger_kar98_npc.spread = 20
	presets.weapon.insane.ger_kar98_npc.miss_dis = 40
	presets.weapon.insane.ger_kar98_npc.RELOAD_SPEED = 1.2
	presets.weapon.insane.ger_kar98_npc.melee_speed = 1
	presets.weapon.insane.ger_kar98_npc.melee_dmg = 10
	presets.weapon.insane.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.insane.ger_kar98_npc.range = {
		far = 5000,
		optimal = 3600,
		close = 1400
	}
	presets.weapon.insane.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 1600,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 2300,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 3000,
			acc = {
				0.25,
				0.65
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 3500,
			acc = {
				0.15,
				0.35
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.insane.ger_luger_npc.aim_delay = pistol_aim_delay
	presets.weapon.insane.ger_luger_npc.focus_delay = 1
	presets.weapon.insane.ger_luger_npc.focus_dis = 200
	presets.weapon.insane.ger_luger_npc.spread = 20
	presets.weapon.insane.ger_luger_npc.miss_dis = 50
	presets.weapon.insane.ger_luger_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.ger_luger_npc.melee_speed = presets.weapon.normal.ger_luger_npc.melee_speed
	presets.weapon.insane.ger_luger_npc.melee_dmg = 10
	presets.weapon.insane.ger_luger_npc.melee_retry_delay = presets.weapon.normal.ger_luger_npc.melee_retry_delay
	presets.weapon.insane.ger_luger_npc.range = {
		far = 1200,
		optimal = 800,
		close = 600
	}
	presets.weapon.insane.ger_luger_npc.FALLOFF = {
		{
			dmg_mul = 4,
			r = 800,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.25,
				0.3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3,
			r = 1500,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 2000,
			acc = {
				0.25,
				0.65
			},
			recoil = {
				0.35,
				0.75
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2500,
			acc = {
				0.15,
				0.35
			},
			recoil = {
				0.45,
				1.05
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.insane.ger_mp38_npc.aim_delay = smg_aim_delay
	presets.weapon.insane.ger_mp38_npc.focus_delay = 2
	presets.weapon.insane.ger_mp38_npc.focus_dis = 200
	presets.weapon.insane.ger_mp38_npc.spread = 15
	presets.weapon.insane.ger_mp38_npc.miss_dis = 10
	presets.weapon.insane.ger_mp38_npc.RELOAD_SPEED = 1.2
	presets.weapon.insane.ger_mp38_npc.melee_speed = presets.weapon.normal.ger_mp38_npc.melee_speed
	presets.weapon.insane.ger_mp38_npc.melee_dmg = 10
	presets.weapon.insane.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.insane.ger_mp38_npc.range = {
		far = 3400,
		optimal = 2200,
		close = 1000
	}
	presets.weapon.insane.ger_mp38_npc.autofire_rounds = presets.weapon.normal.ger_mp38_npc.autofire_rounds
	presets.weapon.insane.ger_mp38_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 1400,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.1,
				0.25
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 3.5,
			r = 2000,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.1,
				0.3
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 3,
			r = 2500,
			acc = {
				0.25,
				0.65
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				0,
				3,
				3,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 3000,
			acc = {
				0.15,
				0.35
			},
			recoil = {
				0.35,
				0.7
			},
			mode = {
				0,
				3,
				3,
				0
			}
		}
	}
	presets.weapon.insane.ger_stg44_npc.aim_delay = rifle_aim_delay
	presets.weapon.insane.ger_stg44_npc.focus_delay = 2
	presets.weapon.insane.ger_stg44_npc.focus_dis = 200
	presets.weapon.insane.ger_stg44_npc.spread = 20
	presets.weapon.insane.ger_stg44_npc.miss_dis = 40
	presets.weapon.insane.ger_stg44_npc.RELOAD_SPEED = 1.2
	presets.weapon.insane.ger_stg44_npc.melee_speed = 1
	presets.weapon.insane.ger_stg44_npc.melee_dmg = 10
	presets.weapon.insane.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.insane.ger_stg44_npc.range = {
		far = 3600,
		optimal = 2400,
		close = 1200
	}
	presets.weapon.insane.ger_stg44_npc.autofire_rounds = presets.weapon.normal.ger_stg44_npc.autofire_rounds
	presets.weapon.insane.ger_stg44_npc.FALLOFF = {
		{
			dmg_mul = 4,
			r = 1800,
			acc = {
				0.7,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 3.5,
			r = 2500,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 3,
			r = 3000,
			acc = {
				0.25,
				0.65
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				0,
				3,
				3,
				1
			}
		},
		{
			dmg_mul = 2,
			r = 3500,
			acc = {
				0.15,
				0.35
			},
			recoil = {
				1.5,
				3
			},
			mode = {
				3,
				1,
				1,
				0
			}
		}
	}
	presets.weapon.insane.ger_geco_npc.aim_delay = shotgun_aim_delay
	presets.weapon.insane.ger_geco_npc.focus_delay = 2
	presets.weapon.insane.ger_geco_npc.focus_dis = 200
	presets.weapon.insane.ger_geco_npc.spread = 15
	presets.weapon.insane.ger_geco_npc.miss_dis = 20
	presets.weapon.insane.ger_geco_npc.RELOAD_SPEED = 1.2
	presets.weapon.insane.ger_geco_npc.melee_speed = 1
	presets.weapon.insane.ger_geco_npc.melee_dmg = 10
	presets.weapon.insane.ger_geco_npc.melee_retry_delay = presets.weapon.normal.ger_geco_npc.melee_retry_delay
	presets.weapon.insane.ger_geco_npc.range = {
		far = 1000,
		optimal = 800,
		close = 600
	}
	presets.weapon.insane.ger_geco_npc.FALLOFF = {
		{
			dmg_mul = 5,
			r = 600,
			acc = {
				0.9,
				1
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 1000,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1500,
			acc = {
				0.25,
				0.65
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.15,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.insane.ger_geco_npc.SUPPRESSION_ACC_CHANCE = 0.4
	presets.weapon.sniper = {
		ger_kar98_npc = {}
	}
	presets.weapon.sniper.ger_kar98_npc.aim_delay = {
		5,
		5
	}
	presets.weapon.sniper.ger_kar98_npc.focus_delay = 2.5
	presets.weapon.sniper.ger_kar98_npc.focus_dis = 15000
	presets.weapon.sniper.ger_kar98_npc.spread = 30
	presets.weapon.sniper.ger_kar98_npc.miss_dis = 250
	presets.weapon.sniper.ger_kar98_npc.RELOAD_SPEED = 1
	presets.weapon.sniper.ger_kar98_npc.melee_speed = presets.weapon.normal.ger_kar98_npc.melee_speed
	presets.weapon.sniper.ger_kar98_npc.melee_dmg = presets.weapon.normal.ger_kar98_npc.melee_dmg
	presets.weapon.sniper.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.sniper.ger_kar98_npc.range = {
		far = 80000,
		optimal = 40000,
		close = 15000
	}
	presets.weapon.sniper.ger_kar98_npc.use_laser = true
	presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 1000,
			acc = {
				0.8,
				0.95
			},
			recoil = {
				5,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 15000,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				8,
				10
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 40000,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				8,
				10
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 80000,
			acc = {
				0,
				0.25
			},
			recoil = {
				8,
				10
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.sniper.ger_kar98_npc.SUPPRESSION_ACC_CHANCE = 0.25
	presets.weapon.gang_member = {
		ger_luger_npc = {},
		ger_mp38_npc = {},
		ger_stg44_npc = {},
		usa_garand_npc = {},
		usa_m1911_npc = {},
		usa_m1912_npc = {},
		thompson_npc = {}
	}
	presets.weapon.gang_member.ger_luger_npc.aim_delay = pistol_aim_delay
	presets.weapon.gang_member.ger_luger_npc.focus_delay = 1
	presets.weapon.gang_member.ger_luger_npc.focus_dis = 2000
	presets.weapon.gang_member.ger_luger_npc.spread = 25
	presets.weapon.gang_member.ger_luger_npc.miss_dis = 20
	presets.weapon.gang_member.ger_luger_npc.RELOAD_SPEED = 1.5
	presets.weapon.gang_member.ger_luger_npc.melee_speed = 3
	presets.weapon.gang_member.ger_luger_npc.melee_dmg = 2
	presets.weapon.gang_member.ger_luger_npc.melee_retry_delay = presets.weapon.normal.ger_luger_npc.melee_retry_delay
	presets.weapon.gang_member.ger_luger_npc.range = presets.weapon.normal.ger_luger_npc.range
	presets.weapon.gang_member.ger_luger_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 300,
			acc = {
				0.7,
				0.8
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.1,
				0.6
			},
			recoil = {
				0.25,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				0,
				0.15
			},
			recoil = {
				2,
				3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.gang_member.ger_mp38_npc.aim_delay = smg_aim_delay
	presets.weapon.gang_member.ger_mp38_npc.focus_delay = 3
	presets.weapon.gang_member.ger_mp38_npc.focus_dis = 3000
	presets.weapon.gang_member.ger_mp38_npc.spread = 25
	presets.weapon.gang_member.ger_mp38_npc.miss_dis = 10
	presets.weapon.gang_member.ger_mp38_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.ger_mp38_npc.melee_speed = 2
	presets.weapon.gang_member.ger_mp38_npc.melee_dmg = 2
	presets.weapon.gang_member.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.gang_member.ger_mp38_npc.range = {
		far = 6000,
		optimal = 2500,
		close = 1500
	}
	presets.weapon.gang_member.ger_mp38_npc.autofire_rounds = presets.weapon.normal.ger_mp38_npc.autofire_rounds
	presets.weapon.gang_member.ger_mp38_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 300,
			acc = {
				0.7,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.1,
				0.6
			},
			recoil = {
				0.25,
				2
			},
			mode = {
				2,
				2,
				5,
				8
			}
		},
		{
			dmg_mul = 0.5,
			r = 10000,
			acc = {
				0,
				0.15
			},
			recoil = {
				2,
				3
			},
			mode = {
				2,
				1,
				1,
				0.01
			}
		}
	}
	presets.weapon.gang_member.ger_stg44_npc.aim_delay = rifle_aim_delay
	presets.weapon.gang_member.ger_stg44_npc.focus_delay = 1
	presets.weapon.gang_member.ger_stg44_npc.focus_dis = 3000
	presets.weapon.gang_member.ger_stg44_npc.spread = 25
	presets.weapon.gang_member.ger_stg44_npc.miss_dis = 10
	presets.weapon.gang_member.ger_stg44_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.ger_stg44_npc.melee_speed = 2
	presets.weapon.gang_member.ger_stg44_npc.melee_dmg = 2
	presets.weapon.gang_member.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.gang_member.ger_stg44_npc.range = {
		far = 6000,
		optimal = 2500,
		close = 1500
	}
	presets.weapon.gang_member.ger_stg44_npc.autofire_rounds = presets.weapon.normal.ger_stg44_npc.autofire_rounds
	presets.weapon.gang_member.ger_stg44_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 300,
			acc = {
				0.7,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.1,
				0.6
			},
			recoil = {
				0.25,
				2
			},
			mode = {
				2,
				2,
				5,
				8
			}
		},
		{
			dmg_mul = 0.5,
			r = 10000,
			acc = {
				0,
				0.15
			},
			recoil = {
				2,
				3
			},
			mode = {
				2,
				1,
				1,
				0.01
			}
		}
	}
	presets.weapon.gang_member.usa_garand_npc.aim_delay = rifle_aim_delay
	presets.weapon.gang_member.usa_garand_npc.focus_delay = 0.15
	presets.weapon.gang_member.usa_garand_npc.focus_dis = 3000
	presets.weapon.gang_member.usa_garand_npc.spread = 9
	presets.weapon.gang_member.usa_garand_npc.miss_dis = 0
	presets.weapon.gang_member.usa_garand_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.usa_garand_npc.melee_speed = 2
	presets.weapon.gang_member.usa_garand_npc.melee_dmg = 2
	presets.weapon.gang_member.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.gang_member.usa_garand_npc.range = {
		far = 8000,
		optimal = 3500,
		close = 1500
	}
	presets.weapon.gang_member.usa_garand_npc.autofire_rounds = presets.weapon.normal.usa_garand_npc.autofire_rounds
	presets.weapon.gang_member.usa_garand_npc.FALLOFF = {
		{
			dmg_mul = 2,
			r = 300,
			acc = {
				0.9,
				1
			},
			recoil = {
				0.15,
				0.25
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.9,
				1
			},
			recoil = {
				0.35,
				0.5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 0.5,
			r = 10000,
			acc = {
				0.9,
				1
			},
			recoil = {
				0.6,
				1
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.gang_member.usa_m1911_npc.aim_delay = pistol_aim_delay
	presets.weapon.gang_member.usa_m1911_npc.focus_delay = 0.25
	presets.weapon.gang_member.usa_m1911_npc.focus_dis = 2000
	presets.weapon.gang_member.usa_m1911_npc.spread = 1
	presets.weapon.gang_member.usa_m1911_npc.miss_dis = 0
	presets.weapon.gang_member.usa_m1911_npc.RELOAD_SPEED = 1.5
	presets.weapon.gang_member.usa_m1911_npc.melee_speed = 3
	presets.weapon.gang_member.usa_m1911_npc.melee_dmg = 2
	presets.weapon.gang_member.usa_m1911_npc.melee_retry_delay = presets.weapon.normal.usa_m1911_npc.melee_retry_delay
	presets.weapon.gang_member.usa_m1911_npc.range = presets.weapon.normal.usa_m1911_npc.range
	presets.weapon.gang_member.usa_m1911_npc.FALLOFF = {
		{
			dmg_mul = 4,
			r = 300,
			acc = {
				0.7,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.7,
				1
			},
			recoil = {
				0.25,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 10000,
			acc = {
				0.7,
				1
			},
			recoil = {
				2,
				3
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.gang_member.usa_m1912_npc.aim_delay = shotgun_aim_delay
	presets.weapon.gang_member.usa_m1912_npc.focus_delay = 2
	presets.weapon.gang_member.usa_m1912_npc.focus_dis = 200
	presets.weapon.gang_member.usa_m1912_npc.spread = 15
	presets.weapon.gang_member.usa_m1912_npc.miss_dis = 20
	presets.weapon.gang_member.usa_m1912_npc.RELOAD_SPEED = 1.3
	presets.weapon.gang_member.usa_m1912_npc.melee_speed = 1
	presets.weapon.gang_member.usa_m1912_npc.melee_dmg = 2
	presets.weapon.gang_member.usa_m1912_npc.melee_retry_delay = presets.weapon.gang_member.usa_garand_npc.melee_retry_delay
	presets.weapon.gang_member.usa_m1912_npc.range = {
		far = 1000,
		optimal = 800,
		close = 600
	}
	presets.weapon.gang_member.usa_m1912_npc.FALLOFF = {
		{
			dmg_mul = 5,
			r = 600,
			acc = {
				0.9,
				1
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 1000,
			acc = {
				0.5,
				0.9
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2,
			r = 1500,
			acc = {
				0.25,
				0.65
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1,
			r = 2000,
			acc = {
				0.15,
				0.35
			},
			recoil = {
				1.5,
				2
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.gang_member.thompson_npc.aim_delay = smg_aim_delay
	presets.weapon.gang_member.thompson_npc.focus_delay = 0.1
	presets.weapon.gang_member.thompson_npc.focus_dis = 3000
	presets.weapon.gang_member.thompson_npc.spread = 2
	presets.weapon.gang_member.thompson_npc.miss_dis = 0
	presets.weapon.gang_member.thompson_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.thompson_npc.melee_speed = 2
	presets.weapon.gang_member.thompson_npc.melee_dmg = 2
	presets.weapon.gang_member.thompson_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.gang_member.thompson_npc.range = {
		far = 6000,
		optimal = 2000,
		close = 1000
	}
	presets.weapon.gang_member.thompson_npc.autofire_rounds = {
		10,
		20
	}
	presets.weapon.gang_member.thompson_npc.FALLOFF = {
		{
			dmg_mul = 1,
			r = 300,
			acc = {
				0.9,
				1
			},
			recoil = {
				0.25,
				0.45
			},
			mode = {
				0.1,
				0.3,
				4,
				7
			}
		},
		{
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.9,
				1
			},
			recoil = {
				0.25,
				1
			},
			mode = {
				2,
				2,
				5,
				8
			}
		},
		{
			dmg_mul = 0.25,
			r = 10000,
			acc = {
				0.9,
				1
			},
			recoil = {
				1,
				2
			},
			mode = {
				2,
				1,
				1,
				0.01
			}
		}
	}
	presets.vision = {
		easy = {
			idle = {},
			combat = {}
		}
	}
	presets.vision.easy.idle = {
		name = "easy",
		cone_1 = {},
		cone_2 = {},
		cone_3 = {}
	}
	presets.vision.easy.idle.cone_1.angle = 160
	presets.vision.easy.idle.cone_1.distance = 500
	presets.vision.easy.idle.cone_1.speed_mul = 1.75
	presets.vision.easy.idle.cone_2.angle = 50
	presets.vision.easy.idle.cone_2.distance = 1550
	presets.vision.easy.idle.cone_2.speed_mul = 2.2
	presets.vision.easy.idle.cone_3.angle = 110
	presets.vision.easy.idle.cone_3.distance = 3000
	presets.vision.easy.idle.cone_3.speed_mul = 7
	presets.vision.easy.combat = {
		name = "easy-cbt",
		cone_1 = {},
		cone_2 = {},
		cone_3 = {},
		detection_delay = 2
	}
	presets.vision.easy.combat.cone_1.angle = 210
	presets.vision.easy.combat.cone_1.distance = 2000
	presets.vision.easy.combat.cone_1.speed_mul = 0.5
	presets.vision.easy.combat.cone_2.angle = 210
	presets.vision.easy.combat.cone_2.distance = 2000
	presets.vision.easy.combat.cone_2.speed_mul = 0.5
	presets.vision.easy.combat.cone_3.angle = 210
	presets.vision.easy.combat.cone_3.distance = 2000
	presets.vision.easy.combat.cone_3.speed_mul = 0.5
	presets.vision.normal = {
		idle = {},
		combat = {},
		idle = {
			name = "normal",
			cone_1 = {},
			cone_2 = {},
			cone_3 = {}
		}
	}
	presets.vision.normal.idle.cone_1.angle = 170
	presets.vision.normal.idle.cone_1.distance = 500
	presets.vision.normal.idle.cone_1.speed_mul = 1.75
	presets.vision.normal.idle.cone_2.angle = 60
	presets.vision.normal.idle.cone_2.distance = 1550
	presets.vision.normal.idle.cone_2.speed_mul = 2
	presets.vision.normal.idle.cone_3.angle = 120
	presets.vision.normal.idle.cone_3.distance = 3000
	presets.vision.normal.idle.cone_3.speed_mul = 7
	presets.vision.normal.combat = {
		name = "normal-cbt",
		cone_1 = {},
		cone_2 = {},
		cone_3 = {},
		detection_delay = 1
	}
	presets.vision.normal.combat.cone_1.angle = 210
	presets.vision.normal.combat.cone_1.distance = 3000
	presets.vision.normal.combat.cone_1.speed_mul = 0.5
	presets.vision.normal.combat.cone_2.angle = 210
	presets.vision.normal.combat.cone_2.distance = 3000
	presets.vision.normal.combat.cone_2.speed_mul = 0.5
	presets.vision.normal.combat.cone_3.angle = 210
	presets.vision.normal.combat.cone_3.distance = 3000
	presets.vision.normal.combat.cone_3.speed_mul = 0.5
	presets.vision.hard = {
		idle = {},
		combat = {},
		idle = {
			name = "hard",
			cone_1 = {},
			cone_2 = {},
			cone_3 = {}
		}
	}
	presets.vision.hard.idle.cone_1.angle = 180
	presets.vision.hard.idle.cone_1.distance = 500
	presets.vision.hard.idle.cone_1.speed_mul = 1.75
	presets.vision.hard.idle.cone_2.angle = 70
	presets.vision.hard.idle.cone_2.distance = 1550
	presets.vision.hard.idle.cone_2.speed_mul = 2
	presets.vision.hard.idle.cone_3.angle = 130
	presets.vision.hard.idle.cone_3.distance = 3000
	presets.vision.hard.idle.cone_3.speed_mul = 7
	presets.vision.hard.combat = {
		name = "hard-cbt",
		cone_1 = {},
		cone_2 = {},
		cone_3 = {},
		detection_delay = 0.5
	}
	presets.vision.hard.combat.cone_1.angle = 210
	presets.vision.hard.combat.cone_1.distance = 3500
	presets.vision.hard.combat.cone_1.speed_mul = 0.3
	presets.vision.hard.combat.cone_2.angle = 220
	presets.vision.hard.combat.cone_2.distance = 3500
	presets.vision.hard.combat.cone_2.speed_mul = 0.3
	presets.vision.hard.combat.cone_3.angle = 240
	presets.vision.hard.combat.cone_3.distance = 3500
	presets.vision.hard.combat.cone_3.speed_mul = 0.3
	presets.vision.commander = {
		idle = {},
		combat = {},
		idle = {
			name = "commander",
			cone_1 = {},
			cone_2 = {},
			cone_3 = {}
		}
	}
	presets.vision.commander.idle.cone_1.angle = 180
	presets.vision.commander.idle.cone_1.distance = 600
	presets.vision.commander.idle.cone_1.speed_mul = 1
	presets.vision.commander.idle.cone_2.angle = 80
	presets.vision.commander.idle.cone_2.distance = 1650
	presets.vision.commander.idle.cone_2.speed_mul = 1.5
	presets.vision.commander.idle.cone_3.angle = 130
	presets.vision.commander.idle.cone_3.distance = 3400
	presets.vision.commander.idle.cone_3.speed_mul = 5
	presets.vision.commander.combat = {
		name = "commander-cbt",
		cone_1 = {},
		cone_2 = {},
		cone_3 = {}
	}
	presets.vision.commander.combat.cone_1.angle = 280
	presets.vision.commander.combat.cone_1.distance = 2500
	presets.vision.commander.combat.cone_1.speed_mul = 0.5
	presets.vision.commander.combat.cone_2.angle = 280
	presets.vision.commander.combat.cone_2.distance = 2500
	presets.vision.commander.combat.cone_2.speed_mul = 0.5
	presets.vision.commander.combat.cone_3.angle = 280
	presets.vision.commander.combat.cone_3.distance = 2500
	presets.vision.commander.combat.cone_3.speed_mul = 0.5
	presets.vision.special_forces = {
		idle = {},
		combat = {},
		idle = {
			name = "special_forces",
			cone_1 = {},
			cone_2 = {},
			cone_3 = {}
		}
	}
	presets.vision.special_forces.idle.cone_1.angle = 160
	presets.vision.special_forces.idle.cone_1.distance = 500
	presets.vision.special_forces.idle.cone_1.speed_mul = 1.25
	presets.vision.special_forces.idle.cone_2.angle = 50
	presets.vision.special_forces.idle.cone_2.distance = 1550
	presets.vision.special_forces.idle.cone_2.speed_mul = 1.8
	presets.vision.special_forces.idle.cone_3.angle = 110
	presets.vision.special_forces.idle.cone_3.distance = 3000
	presets.vision.special_forces.idle.cone_3.speed_mul = 7
	presets.vision.special_forces.combat = {
		name = "special_forces-cbt",
		cone_1 = {},
		cone_2 = {},
		cone_3 = {}
	}
	presets.vision.special_forces.combat.cone_1.angle = 280
	presets.vision.special_forces.combat.cone_1.distance = 5200
	presets.vision.special_forces.combat.cone_1.speed_mul = 0.25
	presets.vision.special_forces.combat.cone_2.angle = 380
	presets.vision.special_forces.combat.cone_2.distance = 5200
	presets.vision.special_forces.combat.cone_2.speed_mul = 0.25
	presets.vision.special_forces.combat.cone_3.angle = 280
	presets.vision.special_forces.combat.cone_3.distance = 5200
	presets.vision.special_forces.combat.cone_3.speed_mul = 0.25
	presets.vision.civilian = {
		name = "civilian",
		cone_1 = {},
		cone_2 = {},
		cone_3 = {}
	}
	presets.vision.civilian.cone_1.angle = 30
	presets.vision.civilian.cone_1.distance = 3200
	presets.vision.civilian.cone_1.speed_mul = 4
	presets.vision.civilian.cone_2.angle = 75
	presets.vision.civilian.cone_2.distance = 2500
	presets.vision.civilian.cone_2.speed_mul = 2
	presets.vision.civilian.cone_3.angle = 210
	presets.vision.civilian.cone_3.distance = 800
	presets.vision.civilian.cone_3.speed_mul = 0.5
	presets.detection = {
		normal = {
			idle = {},
			combat = {},
			recon = {},
			guard = {},
			ntl = {}
		}
	}
	presets.detection.normal.idle.dis_max = 10000
	presets.detection.normal.idle.angle_max = 120
	presets.detection.normal.idle.delay = {
		0,
		0
	}
	presets.detection.normal.idle.use_uncover_range = true
	presets.detection.normal.idle.search_for_player = true
	presets.detection.normal.idle.avoid_suppressive_firing = true
	presets.detection.normal.idle.name = "normal.idle"
	presets.detection.normal.combat.dis_max = 10000
	presets.detection.normal.combat.angle_max = 120
	presets.detection.normal.combat.delay = {
		0,
		0
	}
	presets.detection.normal.combat.use_uncover_range = true
	presets.detection.normal.combat.name = "normal.combat"
	presets.detection.normal.recon.dis_max = 10000
	presets.detection.normal.recon.angle_max = 120
	presets.detection.normal.recon.delay = {
		0,
		0
	}
	presets.detection.normal.recon.use_uncover_range = true
	presets.detection.normal.recon.search_for_player = true
	presets.detection.normal.recon.avoid_suppressive_firing = true
	presets.detection.normal.recon.name = "normal.recon"
	presets.detection.normal.guard.dis_max = 10000
	presets.detection.normal.guard.angle_max = 120
	presets.detection.normal.guard.delay = {
		0,
		0
	}
	presets.detection.normal.guard.search_for_player = true
	presets.detection.normal.guard.avoid_suppressive_firing = true
	presets.detection.normal.guard.name = "normal.guard"
	presets.detection.normal.ntl.dis_max = 4000
	presets.detection.normal.ntl.angle_max = 60
	presets.detection.normal.ntl.delay = {
		0.2,
		2
	}
	presets.detection.normal.ntl.use_uncover_range = true
	presets.detection.normal.ntl.search_for_player = true
	presets.detection.normal.ntl.avoid_suppressive_firing = true
	presets.detection.normal.ntl.name = "normal.ntl"
	presets.detection.flamer = deep_clone(presets.detection.normal)
	presets.detection.flamer.idle.avoid_suppressive_firing = true
	presets.detection.flamer.combat.avoid_suppressive_firing = true
	presets.detection.flamer.recon.avoid_suppressive_firing = true
	presets.detection.flamer.guard.avoid_suppressive_firing = true
	presets.detection.flamer.ntl.avoid_suppressive_firing = true
	presets.detection.guard = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.guard.idle.dis_max = 10000
	presets.detection.guard.idle.angle_max = 120
	presets.detection.guard.idle.delay = {
		0,
		0
	}
	presets.detection.guard.idle.use_uncover_range = true
	presets.detection.guard.idle.search_for_player = true
	presets.detection.guard.idle.name = "guard.idle"
	presets.detection.guard.combat.dis_max = 10000
	presets.detection.guard.combat.angle_max = 120
	presets.detection.guard.combat.delay = {
		0,
		0
	}
	presets.detection.guard.combat.use_uncover_range = true
	presets.detection.guard.combat.name = "guard.combat"
	presets.detection.guard.recon.dis_max = 10000
	presets.detection.guard.recon.angle_max = 120
	presets.detection.guard.recon.delay = {
		0,
		0
	}
	presets.detection.guard.recon.use_uncover_range = true
	presets.detection.guard.recon.search_for_player = true
	presets.detection.guard.recon.name = "guard.recon"
	presets.detection.guard.guard.dis_max = 10000
	presets.detection.guard.guard.angle_max = 120
	presets.detection.guard.guard.delay = {
		0,
		0
	}
	presets.detection.guard.ntl = presets.detection.normal.ntl
	presets.detection.sniper = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.sniper.idle.dis_max = 40000
	presets.detection.sniper.idle.angle_max = 120
	presets.detection.sniper.idle.delay = {
		0.5,
		1
	}
	presets.detection.sniper.idle.use_uncover_range = true
	presets.detection.sniper.idle.avoid_suppressive_firing = true
	presets.detection.sniper.combat.dis_max = 40000
	presets.detection.sniper.combat.angle_max = 120
	presets.detection.sniper.combat.delay = {
		2,
		3
	}
	presets.detection.sniper.combat.use_uncover_range = true
	presets.detection.sniper.combat.avoid_suppressive_firing = true
	presets.detection.sniper.recon.dis_max = 40000
	presets.detection.sniper.recon.angle_max = 120
	presets.detection.sniper.recon.delay = {
		0.5,
		1
	}
	presets.detection.sniper.recon.use_uncover_range = true
	presets.detection.sniper.recon.avoid_suppressive_firing = true
	presets.detection.sniper.guard.dis_max = 40000
	presets.detection.sniper.guard.angle_max = 150
	presets.detection.sniper.guard.delay = {
		1,
		2
	}
	presets.detection.sniper.ntl = presets.detection.normal.ntl
	presets.vision.spotter = {
		idle = {},
		combat = {},
		combat = {
			name = "spotter",
			cone_1 = {},
			cone_2 = {},
			cone_3 = {}
		}
	}
	presets.vision.spotter.combat.cone_1.angle = 280
	presets.vision.spotter.combat.cone_1.distance = 4000
	presets.vision.spotter.combat.cone_1.speed_mul = 2
	presets.vision.spotter.combat.cone_2.angle = 280
	presets.vision.spotter.combat.cone_2.distance = 6000
	presets.vision.spotter.combat.cone_2.speed_mul = 4
	presets.vision.spotter.combat.cone_3.angle = 280
	presets.vision.spotter.combat.cone_3.distance = 8000
	presets.vision.spotter.combat.cone_3.speed_mul = 6
	presets.vision.spotter.idle = deep_clone(presets.vision.spotter.combat)
	presets.detection.gang_member = {
		idle = {},
		combat = {},
		recon = {},
		guard = {},
		ntl = {}
	}
	presets.detection.gang_member.idle.dis_max = 11000
	presets.detection.gang_member.idle.angle_max = 180
	presets.detection.gang_member.idle.delay = {
		0.1,
		0.25
	}
	presets.detection.gang_member.idle.use_uncover_range = true
	presets.detection.gang_member.combat.dis_max = 10000
	presets.detection.gang_member.combat.angle_max = 200
	presets.detection.gang_member.combat.delay = {
		0,
		0
	}
	presets.detection.gang_member.combat.use_uncover_range = true
	presets.detection.gang_member.recon.dis_max = 10000
	presets.detection.gang_member.recon.angle_max = 180
	presets.detection.gang_member.recon.delay = {
		0,
		0
	}
	presets.detection.gang_member.recon.use_uncover_range = true
	presets.detection.gang_member.guard.dis_max = 10000
	presets.detection.gang_member.guard.angle_max = 180
	presets.detection.gang_member.guard.delay = {
		0,
		0
	}
	presets.detection.gang_member.ntl = presets.detection.normal.ntl

	self:_process_weapon_usage_table(presets.weapon.normal)
	self:_process_weapon_usage_table(presets.weapon.good)
	self:_process_weapon_usage_table(presets.weapon.expert)
	self:_process_weapon_usage_table(presets.weapon.insane)
	self:_process_weapon_usage_table(presets.weapon.sniper)
	self:_process_weapon_usage_table(presets.weapon.gang_member)

	presets.detection.civilian = {
		cbt = {},
		ntl = {}
	}
	presets.detection.civilian.cbt.dis_max = 700
	presets.detection.civilian.cbt.angle_max = 120
	presets.detection.civilian.cbt.delay = {
		0,
		0
	}
	presets.detection.civilian.cbt.use_uncover_range = true
	presets.detection.civilian.ntl.dis_max = 2000
	presets.detection.civilian.ntl.angle_max = 60
	presets.detection.civilian.ntl.delay = {
		0.2,
		3
	}
	presets.dodge = {
		poor = {
			speed = 0.9,
			occasions = {
				hit = {
					chance = 0.1,
					check_timeout = {
						100,
						100
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								2,
								3
							}
						}
					}
				},
				scared = {
					chance = 0.5,
					check_timeout = {
						3,
						5
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								3,
								5
							}
						}
					}
				},
				preemptive = {
					chance = 0.5,
					check_timeout = {
						3,
						5
					},
					variations = {
						side_step = {
							chance = 1,
							timeout = {
								3,
								5
							}
						}
					}
				}
			}
		},
		average = {
			speed = 1,
			occasions = {
				hit = {
					chance = 0.35,
					check_timeout = {
						0,
						0
					},
					variations = {
						roll = {
							chance = 1,
							timeout = {
								4,
								8
							}
						},
						side_step = {
							chance = 4,
							timeout = {
								2,
								3
							}
						}
					}
				},
				scared = {
					chance = 0.4,
					check_timeout = {
						4,
						7
					},
					variations = {
						roll = {
							chance = 1,
							timeout = {
								8,
								10
							}
						},
						dive = {
							chance = 5,
							timeout = {
								5,
								8
							}
						}
					}
				},
				preemptive = {
					chance = 0.5,
					check_timeout = {
						1,
						3
					},
					variations = {
						roll = {
							chance = 1,
							timeout = {
								4,
								8
							}
						},
						side_step = {
							chance = 4,
							timeout = {
								2,
								3
							}
						}
					}
				}
			}
		},
		heavy = {
			speed = 1,
			occasions = {
				hit = {
					chance = 0.75,
					check_timeout = {
						0,
						0
					},
					variations = {
						side_step = {
							chance = 9,
							shoot_accuracy = 0.5,
							shoot_chance = 0.8,
							timeout = {
								0,
								7
							}
						},
						roll = {
							chance = 0,
							timeout = {
								8,
								10
							}
						}
					}
				},
				preemptive = {
					chance = 0.5,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 9,
							shoot_accuracy = 0.7,
							shoot_chance = 0.8,
							timeout = {
								1,
								7
							}
						}
					}
				},
				scared = {
					chance = 0.8,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_accuracy = 0.4,
							shoot_chance = 0.5,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 2,
							timeout = {
								8,
								10
							}
						},
						dive = {
							chance = 4,
							timeout = {
								8,
								10
							}
						}
					}
				}
			}
		},
		athletic = {
			speed = 1.3,
			occasions = {
				hit = {
					chance = 0.9,
					check_timeout = {
						0,
						0
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_accuracy = 0.5,
							shoot_chance = 0.8,
							timeout = {
								1,
								3
							}
						},
						roll = {
							chance = 1,
							timeout = {
								3,
								4
							}
						}
					}
				},
				preemptive = {
					chance = 0.35,
					check_timeout = {
						2,
						3
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_accuracy = 0.7,
							shoot_chance = 1,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								3,
								4
							}
						}
					}
				},
				scared = {
					chance = 0.4,
					check_timeout = {
						1,
						2
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_accuracy = 0.4,
							shoot_chance = 0.5,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 3,
							timeout = {
								3,
								5
							}
						},
						dive = {
							chance = 0,
							timeout = {
								3,
								5
							}
						}
					}
				}
			}
		},
		ninja = {
			speed = 1.6,
			occasions = {
				hit = {
					chance = 0.9,
					check_timeout = {
						0,
						3
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_accuracy = 0.7,
							shoot_chance = 1,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 2,
							timeout = {
								1.2,
								2
							}
						}
					}
				},
				preemptive = {
					chance = 0.6,
					check_timeout = {
						0,
						3
					},
					variations = {
						side_step = {
							chance = 3,
							shoot_accuracy = 0.8,
							shoot_chance = 1,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 1,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 2,
							timeout = {
								1.2,
								2
							}
						}
					}
				},
				scared = {
					chance = 0.9,
					check_timeout = {
						0,
						3
					},
					variations = {
						side_step = {
							chance = 5,
							shoot_accuracy = 0.6,
							shoot_chance = 0.8,
							timeout = {
								1,
								2
							}
						},
						roll = {
							chance = 3,
							timeout = {
								1.2,
								2
							}
						},
						wheel = {
							chance = 3,
							timeout = {
								1.2,
								2
							}
						},
						dive = {
							chance = 0,
							timeout = {
								1.2,
								2
							}
						}
					}
				}
			}
		}
	}

	for preset_name, preset_data in pairs(presets.dodge) do
		for reason_name, reason_data in pairs(preset_data.occasions) do
			local total_w = 0

			for variation_name, variation_data in pairs(reason_data.variations) do
				total_w = total_w + variation_data.chance
			end

			if total_w > 0 then
				for variation_name, variation_data in pairs(reason_data.variations) do
					variation_data.chance = variation_data.chance / total_w
				end
			end
		end
	end

	presets.move_speed = {
		civ_fast = {
			stand = {
				walk = {
					ntl = {
						bwd = 100,
						strafe = 120,
						fwd = 150
					},
					hos = {
						bwd = 160,
						strafe = 190,
						fwd = 210
					},
					cbt = {
						bwd = 160,
						strafe = 175,
						fwd = 210
					}
				},
				run = {
					hos = {
						bwd = 230,
						strafe = 192,
						fwd = 500
					},
					cbt = {
						bwd = 230,
						strafe = 250,
						fwd = 500
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 163,
						strafe = 160,
						fwd = 174
					},
					cbt = {
						bwd = 163,
						strafe = 160,
						fwd = 174
					}
				},
				run = {
					hos = {
						bwd = 260,
						strafe = 245,
						fwd = 312
					},
					cbt = {
						bwd = 260,
						strafe = 245,
						fwd = 312
					}
				}
			}
		},
		lightning = {
			stand = {
				walk = {
					ntl = {
						bwd = 110,
						strafe = 120,
						fwd = 150
					},
					hos = {
						bwd = 215,
						strafe = 225,
						fwd = 285
					},
					cbt = {
						bwd = 215,
						strafe = 225,
						fwd = 285
					}
				},
				run = {
					hos = {
						bwd = 350,
						strafe = 400,
						fwd = 800
					},
					cbt = {
						bwd = 320,
						strafe = 380,
						fwd = 750
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 190,
						strafe = 210,
						fwd = 245
					},
					cbt = {
						bwd = 190,
						strafe = 190,
						fwd = 255
					}
				},
				run = {
					hos = {
						bwd = 250,
						strafe = 300,
						fwd = 420
					},
					cbt = {
						bwd = 280,
						strafe = 300,
						fwd = 412
					}
				}
			}
		},
		super_slow = {
			stand = {
				walk = {
					ntl = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					hos = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					cbt = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					}
				},
				run = {
					hos = {
						bwd = 113,
						strafe = 140,
						fwd = 144
					},
					cbt = {
						bwd = 125,
						strafe = 100,
						fwd = 144
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					cbt = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					}
				},
				run = {
					hos = {
						bwd = 113,
						strafe = 130,
						fwd = 144
					},
					cbt = {
						bwd = 125,
						strafe = 100,
						fwd = 144
					}
				}
			}
		},
		very_slow = {
			stand = {
				walk = {
					ntl = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					hos = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					cbt = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					}
				},
				run = {
					hos = {
						bwd = 170,
						strafe = 180,
						fwd = 216
					},
					cbt = {
						bwd = 170,
						strafe = 180,
						fwd = 216
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					cbt = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					}
				},
				run = {
					hos = {
						bwd = 170,
						strafe = 180,
						fwd = 216
					},
					cbt = {
						bwd = 170,
						strafe = 180,
						fwd = 216
					}
				}
			}
		},
		slow = {
			stand = {
				walk = {
					ntl = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					hos = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					cbt = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					}
				},
				run = {
					hos = {
						bwd = 135,
						strafe = 150,
						fwd = 360
					},
					cbt = {
						bwd = 155,
						strafe = 150,
						fwd = 360
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					},
					cbt = {
						bwd = 113,
						strafe = 120,
						fwd = 144
					}
				},
				run = {
					hos = {
						bwd = 150,
						strafe = 140,
						fwd = 360
					},
					cbt = {
						bwd = 155,
						strafe = 140,
						fwd = 360
					}
				}
			}
		},
		normal = {
			stand = {
				walk = {
					ntl = {
						bwd = 100,
						strafe = 120,
						fwd = 150
					},
					hos = {
						bwd = 170,
						strafe = 190,
						fwd = 220
					},
					cbt = {
						bwd = 170,
						strafe = 190,
						fwd = 220
					}
				},
				run = {
					hos = {
						bwd = 255,
						strafe = 290,
						fwd = 450
					},
					cbt = {
						bwd = 255,
						strafe = 250,
						fwd = 400
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 160,
						strafe = 170,
						fwd = 210
					},
					cbt = {
						bwd = 160,
						strafe = 170,
						fwd = 210
					}
				},
				run = {
					hos = {
						bwd = 235,
						strafe = 260,
						fwd = 310
					},
					cbt = {
						bwd = 235,
						strafe = 260,
						fwd = 350
					}
				}
			}
		},
		fast = {
			stand = {
				walk = {
					ntl = {
						bwd = 110,
						strafe = 120,
						fwd = 150
					},
					hos = {
						bwd = 185,
						strafe = 215,
						fwd = 270
					},
					cbt = {
						bwd = 185,
						strafe = 215,
						fwd = 270
					}
				},
				run = {
					hos = {
						bwd = 280,
						strafe = 315,
						fwd = 625
					},
					cbt = {
						bwd = 280,
						strafe = 285,
						fwd = 450
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 170,
						strafe = 180,
						fwd = 235
					},
					cbt = {
						bwd = 170,
						strafe = 180,
						fwd = 235
					}
				},
				run = {
					hos = {
						bwd = 255,
						strafe = 280,
						fwd = 330
					},
					cbt = {
						bwd = 255,
						strafe = 270,
						fwd = 312
					}
				}
			}
		},
		very_fast = {
			stand = {
				walk = {
					ntl = {
						bwd = 110,
						strafe = 120,
						fwd = 150
					},
					hos = {
						bwd = 215,
						strafe = 225,
						fwd = 285
					},
					cbt = {
						bwd = 215,
						strafe = 225,
						fwd = 285
					}
				},
				run = {
					hos = {
						bwd = 325,
						strafe = 340,
						fwd = 670
					},
					cbt = {
						bwd = 300,
						strafe = 325,
						fwd = 475
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 190,
						strafe = 210,
						fwd = 245
					},
					cbt = {
						bwd = 190,
						strafe = 190,
						fwd = 255
					}
				},
				run = {
					hos = {
						bwd = 268,
						strafe = 282,
						fwd = 350
					},
					cbt = {
						bwd = 268,
						strafe = 282,
						fwd = 312
					}
				}
			}
		},
		teamai = {
			stand = {
				walk = {
					ntl = {
						bwd = 120,
						strafe = 120,
						fwd = 145
					},
					hos = {
						bwd = 215,
						strafe = 225,
						fwd = 285
					},
					cbt = {
						bwd = 215,
						strafe = 225,
						fwd = 285
					}
				},
				run = {
					hos = {
						bwd = 325,
						strafe = 340,
						fwd = 580
					},
					cbt = {
						bwd = 300,
						strafe = 325,
						fwd = 475
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						bwd = 190,
						strafe = 210,
						fwd = 245
					},
					cbt = {
						bwd = 190,
						strafe = 190,
						fwd = 255
					}
				},
				run = {
					hos = {
						bwd = 268,
						strafe = 282,
						fwd = 350
					},
					cbt = {
						bwd = 268,
						strafe = 282,
						fwd = 312
					}
				}
			}
		}
	}

	for _, poses in pairs(presets.move_speed) do
		for _, hastes in pairs(poses) do
			hastes.run.ntl = hastes.run.hos
		end

		poses.crouch.walk.ntl = poses.crouch.walk.hos
		poses.crouch.run.ntl = poses.crouch.run.hos
		poses.stand.run.ntl = poses.stand.run.hos
		poses.panic = poses.stand
	end

	presets.suppression = {
		easy = {
			panic_chance_mul = 1,
			duration = {
				10,
				15
			},
			react_point = {
				0,
				2
			},
			brown_point = {
				3,
				5
			}
		},
		hard_def = {
			panic_chance_mul = 0.7,
			duration = {
				5,
				10
			},
			react_point = {
				0,
				2
			},
			brown_point = {
				5,
				6
			}
		},
		hard_agg = {
			panic_chance_mul = 0.7,
			duration = {
				5,
				8
			},
			react_point = {
				2,
				5
			},
			brown_point = {
				5,
				6
			}
		},
		no_supress = {
			panic_chance_mul = 0,
			duration = {
				0.1,
				0.15
			},
			react_point = {
				100,
				200
			},
			brown_point = {
				400,
				500
			}
		}
	}
	presets.enemy_chatter = {
		no_chatter = {},
		regular = {
			incomming_commander = true,
			clear = true,
			follow_me = true,
			smoke = true,
			ready = true,
			suppress = true,
			contact = true,
			go_go = true,
			retreat = true,
			aggressive = true,
			incomming_flamer = true
		},
		special = {
			contact = true,
			go_go = true,
			clear = true,
			aggressive = true,
			follow_me = true,
			ready = true,
			suppress = true
		}
	}

	return presets
end

function CharacterTweakData:_create_table_structure()
	self.weap_ids = {
		"m42_flammenwerfer",
		"panzerfaust_60",
		"ger_kar98_npc",
		"sniper_kar98_npc",
		"spotting_optics_npc",
		"ger_mp38_npc",
		"ger_luger_npc",
		"ger_luger_fancy_npc",
		"ger_luger_npc_invisible",
		"ger_stg44_npc",
		"usa_garand_npc",
		"usa_m1911_npc",
		"usa_m1912_npc",
		"thompson_npc",
		"ger_geco_npc"
	}
	self.weap_unit_names = {
		Idstring("units/vanilla/weapons/wpn_npc_spc_m42_flammenwerfer/wpn_npc_spc_m42_flammenwerfer"),
		Idstring("units/temp/weapons/wpn_npc_spc_panzerfaust_60/wpn_npc_spc_panzerfaust_60"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_k98/wpn_npc_ger_k98"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_k98/wpn_npc_ger_k98_sniper"),
		Idstring("units/vanilla/weapons/wpn_npc_binocular/wpn_npc_binocular"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_mp38/wpn_npc_ger_mp38"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger_fancy"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_stg44/wpn_npc_ger_stg44"),
		Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand"),
		Idstring("units/vanilla/weapons/wpn_npc_usa_m1911/wpn_npc_usa_m1911"),
		Idstring("units/vanilla/weapons/wpn_npc_usa_m1912/wpn_npc_usa_m1912"),
		Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_geco/wpn_npc_ger_geco"),
		Idstring("units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_husk"),
		Idstring("units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace_husk"),
		Idstring("units/vanilla/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills_husk"),
		Idstring("units/vanilla/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343_husk"),
		Idstring("units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete_husk"),
		Idstring("units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty_husk"),
		Idstring("units/upd_candy/weapons/gre_gold_bar/wpn_tps_gre_gold_bar"),
		Idstring("units/upd_blaze/weapons/gre_thermite/wpn_tps_gre_thermite"),
		Idstring("units/upd_blaze/weapons/gre_anti_tank/wpn_tps_gre_anti_tank"),
		Idstring("units/vanilla/weapons/wpn_third_mel_m3_knife/wpn_third_mel_m3_knife"),
		Idstring("units/vanilla/weapons/wpn_third_mel_robbins_dudley_trench_push_dagger/wpn_third_mel_robbins_dudley_trench_push_dagger"),
		Idstring("units/vanilla/weapons/wpn_third_mel_german_brass_knuckles/wpn_third_mel_german_brass_knuckles"),
		Idstring("units/vanilla/weapons/wpn_third_mel_lockwood_brothers_push_dagger/wpn_third_mel_lockwood_brothers_push_dagger"),
		Idstring("units/vanilla/weapons/wpn_third_mel_bc41_knuckle_knife/wpn_third_mel_bc41_knuckle_knife"),
		Idstring("units/vanilla/weapons/wpn_third_mel_km_dagger/wpn_third_mel_km_dagger"),
		Idstring("units/vanilla/weapons/wpn_third_mel_marching_mace/wpn_third_mel_marching_mace"),
		Idstring("units/event_001_halloween/weapons/wpn_third_mel_lc14b/wpn_third_mel_lc14b")
	}
	self.hack_weap_unit_names = {
		[Idstring("units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_hand"):key()] = Idstring("units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_husk"),
		[Idstring("units/vanilla/weapons/wpn_fps_mel_m3_knife/wpn_fps_mel_m3_knife"):key()] = Idstring("units/vanilla/weapons/wpn_third_mel_m3_knife/wpn_third_mel_m3_knife"),
		[Idstring("units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/wpn_fps_mel_robbins_dudley_trench_push_dagger"):key()] = Idstring("units/vanilla/weapons/wpn_third_mel_robbins_dudley_trench_push_dagger/wpn_third_mel_robbins_dudley_trench_push_dagger"),
		[Idstring("units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/wpn_fps_mel_german_brass_knuckles"):key()] = Idstring("units/vanilla/weapons/wpn_third_mel_german_brass_knuckles/wpn_third_mel_german_brass_knuckles"),
		[Idstring("units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/wpn_fps_mel_lockwood_brothers_push_dagger"):key()] = Idstring("units/vanilla/weapons/wpn_third_mel_lockwood_brothers_push_dagger/wpn_third_mel_lockwood_brothers_push_dagger"),
		[Idstring("units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/wpn_fps_mel_bc41_knuckle_knife"):key()] = Idstring("units/vanilla/weapons/wpn_third_mel_bc41_knuckle_knife/wpn_third_mel_bc41_knuckle_knife"),
		[Idstring("units/vanilla/weapons/wpn_fps_km_dagger/wpn_fps_km_dagger"):key()] = Idstring("units/vanilla/weapons/wpn_third_mel_km_dagger/wpn_third_mel_km_dagger"),
		[Idstring("units/vanilla/weapons/wpn_fps_marching_mace/wpn_fps_marching_mace"):key()] = Idstring("units/vanilla/weapons/wpn_third_mel_marching_mace/wpn_third_mel_marching_mace"),
		[Idstring("units/event_001_halloween/weapons/wpn_fps_lc14b/wpn_fps_lc14b"):key()] = Idstring("units/event_001_halloween/weapons/wpn_third_mel_lc14b/wpn_third_mel_lc14b")
	}
end

function CharacterTweakData:_process_weapon_usage_table(weap_usage_table)
	for _, weap_id in ipairs(self.weap_ids) do
		local usage_data = weap_usage_table[weap_id]

		if usage_data and usage_data.FALLOFF then
			for i_range, range_data in ipairs(usage_data.FALLOFF) do
				local modes = range_data.mode
				local total = 0

				for i_firemode, value in ipairs(modes) do
					total = total + value
				end

				local prev_value = nil

				for i_firemode, value in ipairs(modes) do
					prev_value = (prev_value or 0) + value / total
					modes[i_firemode] = prev_value
				end
			end
		end
	end
end

function CharacterTweakData:_set_difficulty_1()
	self:_multiply_all_hp(1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 1)
	self:_multiply_weapon_delay(self.presets.weapon.good, 1)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 1)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 1)

	self.presets.gang_member_damage.HEALTH_INIT = 100
	self.escort.HEALTH_INIT = 80
	self.flashbang_multiplier = 1

	self:_set_characters_weapon_preset("normal")

	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 1000,
			acc = {
				0.8,
				0.95
			},
			recoil = {
				5,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 15000,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				8,
				10
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 40000,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				8,
				10
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 80000,
			acc = {
				0,
				0.25
			},
			recoil = {
				8,
				10
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.german_flamer.HEALTH_INIT = 1600
	self.german_flamer.throwable.throw_chance = 0
	self.german_flamer.throwable.cooldown = 40
	self.german_flamer.move_speed = self.presets.move_speed.super_slow
end

function CharacterTweakData:_set_difficulty_2()
	self:_multiply_all_hp(1.2)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 1)
	self:_multiply_weapon_delay(self.presets.weapon.good, 1)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 1)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 1)

	self.presets.gang_member_damage.HEALTH_INIT = 100
	self.escort.HEALTH_INIT = 100
	self.flashbang_multiplier = 1.25

	self:_set_characters_weapon_preset("good")

	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 1000,
			acc = {
				0.8,
				0.95
			},
			recoil = {
				5,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 15000,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				5,
				8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 40000,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				6,
				9
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 80000,
			acc = {
				0,
				0.25
			},
			recoil = {
				7,
				10
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.german_flamer.HEALTH_INIT = 2000
	self.german_flamer.throwable.throw_chance = 0.15
	self.german_flamer.throwable.cooldown = 30
	self.german_flamer.move_speed = self.presets.move_speed.super_slow
end

function CharacterTweakData:_set_difficulty_3()
	self:_multiply_all_hp(1.4)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0.9)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0.9)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0.9)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.9)

	self.presets.gang_member_damage.HEALTH_INIT = 125
	self.escort.HEALTH_INIT = 120
	self.flashbang_multiplier = 1.5

	self:_set_characters_weapon_preset("expert")

	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 1000,
			acc = {
				0.8,
				0.95
			},
			recoil = {
				5,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 15000,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				6,
				7
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 40000,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				7,
				8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 80000,
			acc = {
				0,
				0.25
			},
			recoil = {
				8,
				9
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.german_flamer.HEALTH_INIT = 2200
	self.german_flamer.throwable.throw_chance = 0.2
	self.german_flamer.throwable.cooldown = 22
	self.german_flamer.move_speed = self.presets.move_speed.very_slow
end

function CharacterTweakData:_set_difficulty_4()
	self:_multiply_all_hp(1.55)
	self:_multiply_all_speeds(2, 2.1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0.8)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0.8)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0.8)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.8)

	self.presets.gang_member_damage.HEALTH_INIT = 150
	self.escort.HEALTH_INIT = 140
	self.flashbang_multiplier = 1.75

	self:_set_characters_weapon_preset("insane")

	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 1000,
			acc = {
				0.8,
				0.95
			},
			recoil = {
				5,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 3.5,
			r = 15000,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				5,
				6
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 2.5,
			r = 40000,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				6,
				7
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 1.5,
			r = 80000,
			acc = {
				0,
				0.25
			},
			recoil = {
				7,
				8
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.german_flamer.HEALTH_INIT = 2600
	self.german_flamer.throwable.throw_chance = 0.28
	self.german_flamer.throwable.cooldown = 15
	self.german_flamer.move_speed = self.presets.move_speed.very_slow
end

function CharacterTweakData:_multiply_weapon_delay(weap_usage_table, mul)
	for _, weap_id in ipairs(self.weap_ids) do
		local usage_data = weap_usage_table[weap_id]

		if usage_data and usage_data.focus_delay then
			usage_data.focus_delay = usage_data.focus_delay * mul
		end
	end
end

function CharacterTweakData:_multiply_all_hp(hp_mul)
	for _, name in ipairs(self._enemies_list) do
		self[name].HEALTH_INIT = self[name].BASE_HEALTH_INIT * hp_mul
	end
end

function CharacterTweakData:_multiply_all_speeds(walk_mul, run_mul)
	for _, name in ipairs(self._enemies_list) do
		local speed_table = self[name].SPEED_WALK
		speed_table.hos = speed_table.hos * walk_mul
		speed_table.cbt = speed_table.cbt * walk_mul
		local sprint_speed = self[name].SPEED_RUN
		sprint_speed = sprint_speed * run_mul
	end
end

function CharacterTweakData:_set_characters_weapon_preset(preset)
	for _, name in ipairs(self._enemies_list) do
		if self[name].dont_modify_weapon_usage then
			Application:debug("[CharacterTweakData:_set_characters_weapon_preset] Skipping " .. tostring(name))
		else
			self[name].weapon = self.presets.weapon[preset]
		end
	end
end

function CharacterTweakData:character_map()
	local char_map = {
		raidww2 = {
			path = "units/vanilla/characters/enemies/models/",
			list = {
				"german_black_waffen_sentry_light",
				"german_black_waffen_sentry_heavy",
				"german_black_waffen_sentry_gasmask",
				"german_black_waffen_sentry_light_commander",
				"german_black_waffen_sentry_heavy_commander",
				"german_black_waffen_sentry_gasmask_commander",
				"german_waffen_ss",
				"german_commander",
				"german_og_commander",
				"german_officer",
				"german_flamer",
				"german_sniper",
				"german_fallschirmjager_light",
				"german_fallschirmjager_heavy",
				"german_gebirgsjager_light",
				"german_gebirgsjager_heavy",
				"german_grunt_light",
				"german_grunt_mid",
				"german_grunt_heavy",
				"soviet_nkvd_int_security_captain",
				"soviet_nkvd_int_security_captain_b",
				"male_spy",
				"female_spy",
				"soviet_nightwitch_01",
				"soviet_nightwitch_02",
				"german_sommilier"
			}
		},
		upd_fb = {
			path = "units/upd_fb/characters/enemies/models/",
			list = {
				"fb_german_commander_boss",
				"fb_german_commander"
			}
		}
	}

	return char_map
end

function CharacterTweakData:get_special_enemies()
	local special_enemies = {}

	return special_enemies
end
