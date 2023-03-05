CharacterTweakData = CharacterTweakData or class()
CharacterTweakData.ENEMY_TYPE_SOLDIER = "soldier"
CharacterTweakData.ENEMY_TYPE_PARATROOPER = "paratrooper"
CharacterTweakData.ENEMY_TYPE_ELITE = "elite"
CharacterTweakData.ENEMY_TYPE_OFFICER = "officer"
CharacterTweakData.ENEMY_TYPE_FLAMER = "flamer"
CharacterTweakData.SPECIAL_UNIT_TYPES = {
	flamer = true,
	commander = true
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

	self:_init_dismemberment_data()
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
	self:_init_russian(presets)
	self:_init_german(presets)
	self:_init_american(presets)
	self:_init_british(presets)
	self:_init_civilian(presets)
	self:_init_escort(presets)
end

function CharacterTweakData:_init_russian(presets)
	self.russian = {
		damage = presets.gang_member_damage
	}
	self.russian.damage.hurt_severity = deep_clone(presets.hurt_severities.only_explosion_hurts)
	self.russian.weapon = deep_clone(presets.weapon.gang_member)
	self.russian.HEALTH_INIT = 400
	self.russian.weapon.weapons_of_choice = {
		primary = Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand"),
		secondary = Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand")
	}
	self.russian.detection = presets.detection.gang_member
	self.russian.dodge = presets.dodge.average
	self.russian.move_speed = presets.move_speed.teamai
	self.russian.crouch_move = false
	self.russian.speech_prefix = "russ"
	self.russian.weapon_voice = "1"
	self.russian.access = "teamAI1"
	self.russian.arrest = {
		timeout = 2400,
		aggression_timeout = 6,
		arrest_timeout = 2400
	}
	self.russian.access = "teamAI1"
	self.russian.vision = presets.vision.easy
end

function CharacterTweakData:_init_german(presets)
	self.german = {
		damage = presets.gang_member_damage
	}
	self.german.damage.hurt_severity = deep_clone(presets.hurt_severities.only_explosion_hurts)
	self.german.weapon = deep_clone(presets.weapon.gang_member)
	self.german.HEALTH_INIT = 400
	self.german.weapon.weapons_of_choice = {
		primary = Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson"),
		secondary = Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson")
	}
	self.german.detection = presets.detection.gang_member
	self.german.dodge = presets.dodge.average
	self.german.move_speed = presets.move_speed.teamai
	self.german.crouch_move = false
	self.german.speech_prefix = "germ"
	self.german.weapon_voice = "2"
	self.german.access = "teamAI1"
	self.german.arrest = {
		timeout = 2400,
		aggression_timeout = 6,
		arrest_timeout = 2400
	}
	self.german.vision = presets.vision.easy
end

function CharacterTweakData:_init_british(presets)
	self.british = {
		damage = presets.gang_member_damage
	}
	self.british.damage.hurt_severity = deep_clone(presets.hurt_severities.only_explosion_hurts)
	self.british.weapon = deep_clone(presets.weapon.gang_member)
	self.british.HEALTH_INIT = 400
	self.british.weapon.weapons_of_choice = {
		primary = Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand"),
		secondary = Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand")
	}
	self.british.detection = presets.detection.gang_member
	self.british.dodge = presets.dodge.average
	self.british.move_speed = presets.move_speed.teamai
	self.british.crouch_move = false
	self.british.speech_prefix = "brit"
	self.british.weapon_voice = "3"
	self.british.access = "teamAI1"
	self.british.arrest = {
		timeout = 2400,
		aggression_timeout = 6,
		arrest_timeout = 2400
	}
	self.british.vision = presets.vision.easy
end

function CharacterTweakData:_init_american(presets)
	self.american = {
		damage = presets.gang_member_damage
	}
	self.american.damage.hurt_severity = deep_clone(presets.hurt_severities.only_explosion_hurts)
	self.american.weapon = deep_clone(presets.weapon.gang_member)
	self.american.HEALTH_INIT = 400
	self.american.weapon.weapons_of_choice = {
		primary = Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson"),
		secondary = Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson")
	}
	self.american.detection = presets.detection.gang_member
	self.american.dodge = presets.dodge.average
	self.american.move_speed = presets.move_speed.teamai
	self.american.crouch_move = false
	self.american.speech_prefix = "amer"
	self.american.weapon_voice = "3"
	self.american.access = "teamAI1"
	self.american.arrest = {
		timeout = 2400,
		aggression_timeout = 6,
		arrest_timeout = 2400
	}
	self.american.vision = presets.vision.easy
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
		ecm_hurts = {}
	}
	self.civilian.experience.cable_tie = "tie_civ"
	self.civilian.speech_prefix_p1 = "cm"
	self.civilian.speech_prefix_count = 2
	self.civilian.access = "civ_male"
	self.civilian.intimidateable = true
	self.civilian.challenges = {
		type = "civilians"
	}
	self.civilian.calls_in = true
	self.civilian.vision = presets.vision.civilian
	self.civilian_female = deep_clone(self.civilian)
	self.civilian_female.speech_prefix_p1 = "cf"
	self.civilian_female.speech_prefix_count = 5
	self.civilian_female.female = true
	self.civilian_female.access = "civ_female"
	self.civilian_female.vision = presets.vision.civilian
end

function CharacterTweakData:_init_dismemberment_data(presets)
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

function CharacterTweakData:_init_german_grunt_light(presets)
	self.german_grunt_light = deep_clone(presets.base)
	self.german_grunt_light.experience = {}
	self.german_grunt_light.weapon = presets.weapon.normal
	self.german_grunt_light.detection = presets.detection.normal
	self.german_grunt_light.vision = presets.vision.easy
	self.german_grunt_light.HEALTH_INIT = 150
	self.german_grunt_light.BASE_HEALTH_INIT = 150
	self.german_grunt_light.headshot_dmg_mul = 1
	self.german_grunt_light.move_speed = presets.move_speed.fast
	self.german_grunt_light.surrender_break_time = {
		10,
		15
	}
	self.german_grunt_light.suppression = presets.suppression.easy
	self.german_grunt_light.surrender = presets.surrender.normal
	self.german_grunt_light.ecm_vulnerability = 1
	self.german_grunt_light.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_grunt_light.weapon_voice = "1"
	self.german_grunt_light.experience.cable_tie = "tie_swat"
	self.german_grunt_light.speech_prefix_p1 = "ger"
	self.german_grunt_light.speech_prefix_p2 = "soldier"
	self.german_grunt_light.speech_prefix_count = 4
	self.german_grunt_light.access = "swat"
	self.german_grunt_light.silent_priority_shout = "shout_loud_soldier"
	self.german_grunt_light.dodge = presets.dodge.athletic
	self.german_grunt_light.deathguard = false
	self.german_grunt_light.chatter = presets.enemy_chatter.cop
	self.german_grunt_light.steal_loot = false
	self.german_grunt_light.no_retreat = true
	self.german_grunt_light.no_arrest = true
	self.german_grunt_light.loot_table = "easy_enemy"
	self.german_grunt_light.type = CharacterTweakData.ENEMY_TYPE_SOLDIER
	self.german_grunt_light.carry_tweak_corpse = "german_grunt_light_body"
	self.german_grunt_light_mp38 = clone(self.german_grunt_light)
	self.german_grunt_light_kar98 = clone(self.german_grunt_light)
	self.german_grunt_light_shotgun = clone(self.german_grunt_light)

	table.insert(self._enemies_list, "german_gebirgsjager_light")
	table.insert(self._enemies_list, "german_grunt_light_mp38")
	table.insert(self._enemies_list, "german_grunt_light_kar98")
	table.insert(self._enemies_list, "german_grunt_light_shotgun")
end

function CharacterTweakData:_init_german_grunt_mid(presets)
	self.german_grunt_mid = deep_clone(presets.base)
	self.german_grunt_mid.experience = {}
	self.german_grunt_mid.weapon = presets.weapon.normal
	self.german_grunt_mid.detection = presets.detection.normal
	self.german_grunt_mid.vision = presets.vision.easy
	self.german_grunt_mid.HEALTH_INIT = 200
	self.german_grunt_mid.BASE_HEALTH_INIT = 200
	self.german_grunt_mid.headshot_dmg_mul = 1
	self.german_grunt_mid.move_speed = presets.move_speed.normal
	self.german_grunt_mid.surrender_break_time = {
		10,
		15
	}
	self.german_grunt_mid.suppression = presets.suppression.easy
	self.german_grunt_mid.surrender = presets.surrender.normal
	self.german_grunt_mid.ecm_vulnerability = 1
	self.german_grunt_mid.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_grunt_mid.weapon_voice = "1"
	self.german_grunt_mid.experience.cable_tie = "tie_swat"
	self.german_grunt_mid.speech_prefix_p1 = "ger"
	self.german_grunt_mid.speech_prefix_p2 = "soldier"
	self.german_grunt_mid.speech_prefix_count = 4
	self.german_grunt_mid.access = "swat"
	self.german_grunt_mid.silent_priority_shout = "shout_loud_soldier"
	self.german_grunt_mid.dodge = presets.dodge.average
	self.german_grunt_mid.deathguard = false
	self.german_grunt_mid.chatter = presets.enemy_chatter.cop
	self.german_grunt_mid.steal_loot = false
	self.german_grunt_mid.no_retreat = true
	self.german_grunt_mid.no_arrest = true
	self.german_grunt_mid.loot_table = "easy_enemy"
	self.german_grunt_mid.type = CharacterTweakData.ENEMY_TYPE_SOLDIER
	self.german_grunt_mid.carry_tweak_corpse = "german_grunt_mid_body"
	self.german_grunt_mid_mp38 = clone(self.german_grunt_mid)
	self.german_grunt_mid_kar98 = clone(self.german_grunt_mid)
	self.german_grunt_mid_shotgun = clone(self.german_grunt_mid)

	table.insert(self._enemies_list, "german_grunt_mid")
	table.insert(self._enemies_list, "german_grunt_mid_mp38")
	table.insert(self._enemies_list, "german_grunt_mid_kar98")
	table.insert(self._enemies_list, "german_grunt_mid_shotgun")
end

function CharacterTweakData:_init_german_grunt_heavy(presets)
	self.german_grunt_heavy = deep_clone(presets.base)
	self.german_grunt_heavy.experience = {}
	self.german_grunt_heavy.weapon = presets.weapon.normal
	self.german_grunt_heavy.detection = presets.detection.normal
	self.german_grunt_heavy.vision = presets.vision.easy
	self.german_grunt_heavy.HEALTH_INIT = 250
	self.german_grunt_heavy.BASE_HEALTH_INIT = 250
	self.german_grunt_heavy.headshot_dmg_mul = 1
	self.german_grunt_heavy.move_speed = presets.move_speed.normal
	self.german_grunt_heavy.crouch_move = false
	self.german_grunt_heavy.surrender_break_time = {
		10,
		15
	}
	self.german_grunt_heavy.suppression = presets.suppression.easy
	self.german_grunt_heavy.surrender = presets.surrender.normal
	self.german_grunt_heavy.ecm_vulnerability = 1
	self.german_grunt_heavy.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_grunt_heavy.weapon_voice = "1"
	self.german_grunt_heavy.experience.cable_tie = "tie_swat"
	self.german_grunt_heavy.speech_prefix_p1 = "ger"
	self.german_grunt_heavy.speech_prefix_p2 = "soldier"
	self.german_grunt_heavy.speech_prefix_count = 4
	self.german_grunt_heavy.access = "swat"
	self.german_grunt_heavy.silent_priority_shout = "shout_loud_soldier"
	self.german_grunt_heavy.dodge = presets.dodge.heavy
	self.german_grunt_heavy.deathguard = false
	self.german_grunt_heavy.chatter = presets.enemy_chatter.cop
	self.german_grunt_heavy.steal_loot = false
	self.german_grunt_heavy.no_retreat = true
	self.german_grunt_heavy.no_arrest = true
	self.german_grunt_heavy.loot_table = "normal_enemy"
	self.german_grunt_heavy.type = CharacterTweakData.ENEMY_TYPE_SOLDIER
	self.german_grunt_heavy.carry_tweak_corpse = "german_grunt_body"
	self.german_grunt_heavy_mp38 = clone(self.german_grunt_heavy)
	self.german_grunt_heavy_kar98 = clone(self.german_grunt_heavy)
	self.german_grunt_heavy_shotgun = clone(self.german_grunt_heavy)
end

function CharacterTweakData:_init_german_gebirgsjager_light(presets)
	self.german_gebirgsjager_light = deep_clone(presets.base)
	self.german_gebirgsjager_light.experience = {}
	self.german_gebirgsjager_light.weapon = presets.weapon.good
	self.german_gebirgsjager_light.detection = presets.detection.normal
	self.german_gebirgsjager_light.vision = presets.vision.normal
	self.german_gebirgsjager_light.HEALTH_INIT = 200
	self.german_gebirgsjager_light.BASE_HEALTH_INIT = 200
	self.german_gebirgsjager_light.headshot_dmg_mul = 1
	self.german_gebirgsjager_light.move_speed = presets.move_speed.fast
	self.german_gebirgsjager_light.surrender_break_time = {
		10,
		15
	}
	self.german_gebirgsjager_light.suppression = presets.suppression.hard_def
	self.german_gebirgsjager_light.surrender = presets.surrender.normal
	self.german_gebirgsjager_light.ecm_vulnerability = 1
	self.german_gebirgsjager_light.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_gebirgsjager_light.weapon_voice = "1"
	self.german_gebirgsjager_light.experience.cable_tie = "tie_swat"
	self.german_gebirgsjager_light.speech_prefix_p1 = "ger"
	self.german_gebirgsjager_light.speech_prefix_p2 = "paratrooper"
	self.german_gebirgsjager_light.speech_prefix_count = 4
	self.german_gebirgsjager_light.access = "swat"
	self.german_gebirgsjager_light.silent_priority_shout = "shout_loud_paratrooper"
	self.german_gebirgsjager_light.dodge = presets.dodge.athletic
	self.german_gebirgsjager_light.deathguard = false
	self.german_gebirgsjager_light.chatter = presets.enemy_chatter.cop
	self.german_gebirgsjager_light.steal_loot = false
	self.german_gebirgsjager_light.no_retreat = true
	self.german_gebirgsjager_light.no_arrest = true
	self.german_gebirgsjager_light.loot_table = "normal_enemy"
	self.german_gebirgsjager_light.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_gebirgsjager_light.carry_tweak_corpse = "gebirgsjager_light_body"
	self.german_gebirgsjager_light_mp38 = clone(self.german_gebirgsjager_light)
	self.german_gebirgsjager_light_kar98 = clone(self.german_gebirgsjager_light)
	self.german_gebirgsjager_light_shotgun = clone(self.german_gebirgsjager_light)

	table.insert(self._enemies_list, "german_gebirgsjager_light")
	table.insert(self._enemies_list, "german_gebirgsjager_light_mp38")
	table.insert(self._enemies_list, "german_gebirgsjager_light_kar98")
	table.insert(self._enemies_list, "german_gebirgsjager_light_shotgun")
end

function CharacterTweakData:_init_german_gebirgsjager_heavy(presets)
	self.german_gebirgsjager_heavy = deep_clone(presets.base)
	self.german_gebirgsjager_heavy.experience = {}
	self.german_gebirgsjager_heavy.weapon = presets.weapon.good
	self.german_gebirgsjager_heavy.detection = presets.detection.normal
	self.german_gebirgsjager_heavy.vision = presets.vision.normal
	self.german_gebirgsjager_heavy.HEALTH_INIT = 250
	self.german_gebirgsjager_heavy.BASE_HEALTH_INIT = 250
	self.german_gebirgsjager_heavy.headshot_dmg_mul = 1
	self.german_gebirgsjager_heavy.move_speed = presets.move_speed.normal
	self.german_gebirgsjager_heavy.crouch_move = false
	self.german_gebirgsjager_heavy.surrender_break_time = {
		10,
		15
	}
	self.german_gebirgsjager_heavy.suppression = presets.suppression.hard_def
	self.german_gebirgsjager_heavy.surrender = presets.surrender.normal
	self.german_gebirgsjager_heavy.ecm_vulnerability = 1
	self.german_gebirgsjager_heavy.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_gebirgsjager_heavy.weapon_voice = "1"
	self.german_gebirgsjager_heavy.experience.cable_tie = "tie_swat"
	self.german_gebirgsjager_heavy.speech_prefix_p1 = "ger"
	self.german_gebirgsjager_heavy.speech_prefix_p2 = "paratrooper"
	self.german_gebirgsjager_heavy.speech_prefix_count = 4
	self.german_gebirgsjager_heavy.access = "swat"
	self.german_gebirgsjager_heavy.silent_priority_shout = "shout_loud_paratrooper"
	self.german_gebirgsjager_heavy.dodge = presets.dodge.heavy
	self.german_gebirgsjager_heavy.deathguard = false
	self.german_gebirgsjager_heavy.chatter = presets.enemy_chatter.cop
	self.german_gebirgsjager_heavy.steal_loot = false
	self.german_gebirgsjager_heavy.no_retreat = true
	self.german_gebirgsjager_heavy.no_arrest = true
	self.german_gebirgsjager_heavy.loot_table = "normal_enemy"
	self.german_gebirgsjager_heavy.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_gebirgsjager_heavy.carry_tweak_corpse = "gebirgsjager_heavy_body"
	self.german_gebirgsjager_heavy_mp38 = clone(self.german_gebirgsjager_heavy)
	self.german_gebirgsjager_heavy_kar98 = clone(self.german_gebirgsjager_heavy)
	self.german_gebirgsjager_heavy_shotgun = clone(self.german_gebirgsjager_heavy)

	table.insert(self._enemies_list, "german_gebirgsjager_heavy")
	table.insert(self._enemies_list, "german_gebirgsjager_heavy_mp38")
	table.insert(self._enemies_list, "german_gebirgsjager_heavy_kar98")
	table.insert(self._enemies_list, "german_gebirgsjager_heavy_shotgun")
end

function CharacterTweakData:_init_german_light(presets)
	self.german_light = deep_clone(presets.base)
	self.german_light.experience = {}
	self.german_light.weapon = presets.weapon.insane
	self.german_light.detection = presets.detection.normal
	self.german_light.vision = presets.vision.normal
	self.german_light.HEALTH_INIT = 600
	self.german_light.BASE_HEALTH_INIT = 600
	self.german_light.headshot_dmg_mul = 1
	self.german_light.move_speed = presets.move_speed.fast
	self.german_light.surrender_break_time = {
		10,
		15
	}
	self.german_light.suppression = presets.suppression.hard_agg
	self.german_light.surrender = presets.surrender.normal
	self.german_light.ecm_vulnerability = 1
	self.german_light.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_light.weapon_voice = "1"
	self.german_light.experience.cable_tie = "tie_swat"
	self.german_light.speech_prefix_p1 = "ger"
	self.german_light.speech_prefix_p2 = "elite"
	self.german_light.speech_prefix_count = 4
	self.german_light.access = "swat"
	self.german_light.silent_priority_shout = "shout_loud_soldier"
	self.german_light.dodge = presets.dodge.athletic
	self.german_light.deathguard = true
	self.german_light.chatter = presets.enemy_chatter.cop
	self.german_light.steal_loot = false
	self.german_light.no_retreat = true
	self.german_light.no_arrest = true
	self.german_light.loot_table = "hard_enemy"
	self.german_light.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_light.carry_tweak_corpse = "german_black_waffen_sentry_light_body"
	self.german_light_kar98 = clone(self.german_light)
	self.german_light_shotgun = clone(self.german_light)

	table.insert(self._enemies_list, "german_light")
	table.insert(self._enemies_list, "german_light_kar98")
	table.insert(self._enemies_list, "german_light_shotgun")
end

function CharacterTweakData:_init_german_heavy(presets)
	self.german_heavy = deep_clone(presets.base)
	self.german_heavy.experience = {}
	self.german_heavy.weapon = presets.weapon.insane
	self.german_heavy.detection = presets.detection.normal
	self.german_heavy.vision = presets.vision.normal
	self.german_heavy.HEALTH_INIT = 700
	self.german_heavy.BASE_HEALTH_INIT = 700
	self.german_heavy.headshot_dmg_mul = 1
	self.german_heavy.move_speed = presets.move_speed.normal
	self.german_heavy.crouch_move = false
	self.german_heavy.surrender_break_time = {
		10,
		15
	}
	self.german_heavy.suppression = presets.suppression.hard_agg
	self.german_heavy.surrender = presets.surrender.normal
	self.german_heavy.ecm_vulnerability = 1
	self.german_heavy.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_heavy.weapon_voice = "1"
	self.german_heavy.experience.cable_tie = "tie_swat"
	self.german_heavy.speech_prefix_p1 = "ger"
	self.german_heavy.speech_prefix_p2 = "elite"
	self.german_heavy.speech_prefix_count = 4
	self.german_heavy.access = "swat"
	self.german_heavy.silent_priority_shout = "shout_loud_soldier"
	self.german_heavy.dodge = presets.dodge.heavy
	self.german_heavy.deathguard = true
	self.german_heavy.chatter = presets.enemy_chatter.cop
	self.german_heavy.steal_loot = false
	self.german_heavy.no_retreat = true
	self.german_heavy.no_arrest = true
	self.german_heavy.loot_table = "elite_enemy"
	self.german_heavy.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_heavy.carry_tweak_corpse = "german_black_waffen_sentry_heavy_body"
	self.german_heavy_mp38 = clone(self.german_heavy)
	self.german_heavy_kar98 = clone(self.german_heavy)
	self.german_heavy_shotgun = clone(self.german_heavy)

	table.insert(self._enemies_list, "german_heavy")
	table.insert(self._enemies_list, "german_heavy_mp38")
	table.insert(self._enemies_list, "german_heavy_kar98")
	table.insert(self._enemies_list, "german_heavy_shotgun")
end

function CharacterTweakData:_init_german_fallschirmjager_light(presets)
	self.german_fallschirmjager_light = deep_clone(presets.base)
	self.german_fallschirmjager_light.experience = {}
	self.german_fallschirmjager_light.weapon = presets.weapon.expert
	self.german_fallschirmjager_light.detection = presets.detection.normal
	self.german_fallschirmjager_light.vision = presets.vision.hard
	self.german_fallschirmjager_light.HEALTH_INIT = 450
	self.german_fallschirmjager_light.BASE_HEALTH_INIT = 450
	self.german_fallschirmjager_light.headshot_dmg_mul = 1
	self.german_fallschirmjager_light.move_speed = presets.move_speed.fast
	self.german_fallschirmjager_light.surrender_break_time = {
		10,
		15
	}
	self.german_fallschirmjager_light.suppression = presets.suppression.hard_def
	self.german_fallschirmjager_light.surrender = presets.surrender.normal
	self.german_fallschirmjager_light.ecm_vulnerability = 1
	self.german_fallschirmjager_light.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_fallschirmjager_light.weapon_voice = "1"
	self.german_fallschirmjager_light.experience.cable_tie = "tie_swat"
	self.german_fallschirmjager_light.speech_prefix_p1 = "ger"
	self.german_fallschirmjager_light.speech_prefix_p2 = "paratrooper"
	self.german_fallschirmjager_light.speech_prefix_count = 4
	self.german_fallschirmjager_light.access = "swat"
	self.german_fallschirmjager_light.silent_priority_shout = "shout_loud_paratrooper"
	self.german_fallschirmjager_light.dodge = presets.dodge.athletic
	self.german_fallschirmjager_light.deathguard = true
	self.german_fallschirmjager_light.chatter = presets.enemy_chatter.cop
	self.german_fallschirmjager_light.steal_loot = false
	self.german_fallschirmjager_light.no_retreat = true
	self.german_fallschirmjager_light.no_arrest = true
	self.german_fallschirmjager_light.loot_table = "hard_enemy"
	self.german_fallschirmjager_light.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_fallschirmjager_light.carry_tweak_corpse = "german_fallschirmjager_light_body"
	self.german_fallschirmjager_light_mp38 = clone(self.german_fallschirmjager_light)
	self.german_fallschirmjager_light_kar98 = clone(self.german_fallschirmjager_light)
	self.german_fallschirmjager_light_shotgun = clone(self.german_fallschirmjager_light)

	table.insert(self._enemies_list, "german_fallschirmjager_light")
	table.insert(self._enemies_list, "german_fallschirmjager_light_mp38")
	table.insert(self._enemies_list, "german_fallschirmjager_light_kar98")
	table.insert(self._enemies_list, "german_fallschirmjager_light_shotgun")
end

function CharacterTweakData:_init_german_gasmask(presets)
	self.german_gasmask = deep_clone(presets.base)
	self.german_gasmask.experience = {}
	self.german_gasmask.weapon = presets.weapon.expert
	self.german_gasmask.detection = presets.detection.normal
	self.german_gasmask.vision = presets.vision.hard
	self.german_gasmask.HEALTH_INIT = 500
	self.german_gasmask.BASE_HEALTH_INIT = 500
	self.german_gasmask.headshot_dmg_mul = 1
	self.german_gasmask.move_speed = presets.move_speed.normal
	self.german_gasmask.crouch_move = false
	self.german_gasmask.surrender_break_time = {
		10,
		15
	}
	self.german_gasmask.suppression = presets.suppression.hard_agg
	self.german_gasmask.surrender = presets.surrender.normal
	self.german_gasmask.ecm_vulnerability = 1
	self.german_gasmask.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_gasmask.weapon_voice = "1"
	self.german_gasmask.experience.cable_tie = "tie_swat"
	self.german_gasmask.speech_prefix_p1 = "ger"
	self.german_gasmask.speech_prefix_p2 = "elite"
	self.german_gasmask.speech_prefix_count = 4
	self.german_gasmask.access = "swat"
	self.german_gasmask.silent_priority_shout = "shout_loud_soldier"
	self.german_gasmask.dodge = presets.dodge.average
	self.german_gasmask.deathguard = true
	self.german_gasmask.chatter = presets.enemy_chatter.cop
	self.german_gasmask.steal_loot = false
	self.german_gasmask.no_retreat = true
	self.german_gasmask.no_arrest = true
	self.german_gasmask.loot_table = "elite_enemy"
	self.german_gasmask.type = CharacterTweakData.ENEMY_TYPE_ELITE
	self.german_gasmask.carry_tweak_corpse = "german_black_waffen_sentry_gasmask_body"
	self.german_gasmask_shotgun = deep_clone(self.german_gasmask)
	self.german_gasmask_shotgun.move_speed = presets.move_speed.fast
	self.german_gasmask_shotgun.HEALTH_INIT = 500

	table.insert(self._enemies_list, "german_gasmask")
end

function CharacterTweakData:_init_german_commander_backup(presets)
	self.german_light_commander_backup = deep_clone(self.german_light)
	self.german_light_commander_backup.carry_tweak_corpse = "german_black_waffen_sentry_light_commander_body"

	table.insert(self._enemies_list, "german_light_commander_backup")

	self.german_heavy_commander_backup = deep_clone(self.german_heavy)
	self.german_heavy_commander_backup.carry_tweak_corpse = "german_black_waffen_sentry_heavy_commander_body"

	table.insert(self._enemies_list, "german_heavy_commander_backup")

	self.german_gasmask_commander_backup = deep_clone(self.german_gasmask)

	table.insert(self._enemies_list, "german_gasmask_commander_backup")

	self.german_gasmask_commander_backup_shotgun = deep_clone(self.german_gasmask_shotgun)

	table.insert(self._enemies_list, "german_gasmask_commander_backup_shotgun")
end

function CharacterTweakData:_init_german_fallschirmjager_heavy(presets)
	self.german_fallschirmjager_heavy = deep_clone(presets.base)
	self.german_fallschirmjager_heavy.experience = {}
	self.german_fallschirmjager_heavy.weapon = presets.weapon.expert
	self.german_fallschirmjager_heavy.detection = presets.detection.normal
	self.german_fallschirmjager_heavy.vision = presets.vision.hard
	self.german_fallschirmjager_heavy.HEALTH_INIT = 500
	self.german_fallschirmjager_heavy.BASE_HEALTH_INIT = 500
	self.german_fallschirmjager_heavy.headshot_dmg_mul = 1
	self.german_fallschirmjager_heavy.move_speed = presets.move_speed.normal
	self.german_fallschirmjager_heavy.crouch_move = false
	self.german_fallschirmjager_heavy.surrender_break_time = {
		10,
		15
	}
	self.german_fallschirmjager_heavy.suppression = presets.suppression.hard_def
	self.german_fallschirmjager_heavy.surrender = presets.surrender.normal
	self.german_fallschirmjager_heavy.ecm_vulnerability = 1
	self.german_fallschirmjager_heavy.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_fallschirmjager_heavy.weapon_voice = "1"
	self.german_fallschirmjager_heavy.experience.cable_tie = "tie_swat"
	self.german_fallschirmjager_heavy.speech_prefix_p1 = "ger"
	self.german_fallschirmjager_heavy.speech_prefix_p2 = "paratrooper"
	self.german_fallschirmjager_heavy.speech_prefix_count = 4
	self.german_fallschirmjager_heavy.access = "swat"
	self.german_fallschirmjager_heavy.silent_priority_shout = "shout_loud_paratrooper"
	self.german_fallschirmjager_heavy.dodge = presets.dodge.heavy
	self.german_fallschirmjager_heavy.deathguard = false
	self.german_fallschirmjager_heavy.chatter = presets.enemy_chatter.cop
	self.german_fallschirmjager_heavy.steal_loot = false
	self.german_fallschirmjager_heavy.no_retreat = true
	self.german_fallschirmjager_heavy.no_arrest = true
	self.german_fallschirmjager_heavy.loot_table = "hard_enemy"
	self.german_fallschirmjager_heavy.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_fallschirmjager_heavy.carry_tweak_corpse = "german_fallschirmjager_heavy_body"
	self.german_fallschirmjager_heavy_mp38 = clone(self.german_fallschirmjager_heavy)
	self.german_fallschirmjager_heavy_kar98 = clone(self.german_fallschirmjager_heavy)
	self.german_fallschirmjager_heavy_shotgun = clone(self.german_fallschirmjager_heavy)
	self.german_fallschirmjager_heavy_shotgun.HEALTH_INIT = 25

	table.insert(self._enemies_list, "german_fallschirmjager_heavy")
	table.insert(self._enemies_list, "german_fallschirmjager_heavy_mp38")
	table.insert(self._enemies_list, "german_fallschirmjager_heavy_kar98")
	table.insert(self._enemies_list, "german_fallschirmjager_heavy_shotgun")
end

function CharacterTweakData:_init_german_waffen_ss(presets)
	self.german_waffen_ss = deep_clone(presets.base)
	self.german_waffen_ss.experience = {}
	self.german_waffen_ss.weapon = presets.weapon.insane
	self.german_waffen_ss.detection = presets.detection.normal
	self.german_waffen_ss.vision = presets.vision.hard
	self.german_waffen_ss.HEALTH_INIT = 600
	self.german_waffen_ss.BASE_HEALTH_INIT = 600
	self.german_waffen_ss.headshot_dmg_mul = 1
	self.german_waffen_ss.move_speed = presets.move_speed.fast
	self.german_waffen_ss.crouch_move = false
	self.german_waffen_ss.surrender_break_time = {
		10,
		15
	}
	self.german_waffen_ss.suppression = presets.suppression.hard_def
	self.german_waffen_ss.surrender = presets.surrender.normal
	self.german_waffen_ss.ecm_vulnerability = 1
	self.german_waffen_ss.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_waffen_ss.weapon_voice = "1"
	self.german_waffen_ss.experience.cable_tie = "tie_swat"
	self.german_waffen_ss.speech_prefix_p1 = "ger"
	self.german_waffen_ss.speech_prefix_p2 = "paratrooper"
	self.german_waffen_ss.speech_prefix_count = 4
	self.german_waffen_ss.access = "swat"
	self.german_waffen_ss.silent_priority_shout = "shout_loud_paratrooper"
	self.german_waffen_ss.dodge = presets.dodge.average
	self.german_waffen_ss.deathguard = false
	self.german_waffen_ss.chatter = presets.enemy_chatter.cop
	self.german_waffen_ss.steal_loot = false
	self.german_waffen_ss.no_retreat = true
	self.german_waffen_ss.no_arrest = true
	self.german_waffen_ss.loot_table = "elite_enemy"
	self.german_waffen_ss.type = CharacterTweakData.ENEMY_TYPE_PARATROOPER
	self.german_waffen_ss.carry_tweak_corpse = "german_waffen_ss_body"
	self.german_waffen_ss_mp38 = clone(self.german_waffen_ss)
	self.german_waffen_ss_kar98 = clone(self.german_waffen_ss)
	self.german_waffen_ss_shotgun = clone(self.german_waffen_ss)
	self.german_waffen_ss_shotgun.HEALTH_INIT = 420
	self.german_waffen_ss_shotgun.BASE_HEALTH_INIT = 420

	table.insert(self._enemies_list, "german_waffen_ss")
	table.insert(self._enemies_list, "german_waffen_ss_mp38")
	table.insert(self._enemies_list, "german_waffen_ss_kar98")
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
	self.german_commander.surrender_break_time = {
		10,
		15
	}
	self.german_commander.suppression = presets.suppression.no_supress
	self.german_commander.ecm_vulnerability = 1
	self.german_commander.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_commander.weapon_voice = "1"
	self.german_commander.experience.cable_tie = "tie_swat"
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
	self.german_commander.chatter = presets.enemy_chatter.cop
	self.german_commander.steal_loot = false
	self.german_commander.no_retreat = true
	self.german_commander.no_arrest = true
	self.german_commander.surrender = nil
	self.german_commander.loot_table = "elite_enemy"
	self.german_commander.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.german_commander.carry_tweak_corpse = "german_commander_body"
	self.german_commander.is_special = true
	self.german_commander.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_COMMANDER

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
	self.german_og_commander.surrender_break_time = {
		10,
		15
	}
	self.german_og_commander.suppression = presets.suppression.no_supress
	self.german_og_commander.ecm_vulnerability = 1
	self.german_og_commander.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_og_commander.weapon_voice = "1"
	self.german_og_commander.experience.cable_tie = "tie_swat"
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
	self.german_og_commander.chatter = presets.enemy_chatter.cop
	self.german_og_commander.steal_loot = false
	self.german_og_commander.no_retreat = true
	self.german_og_commander.no_arrest = true
	self.german_og_commander.surrender = nil
	self.german_og_commander.loot_table = "special_enemy"
	self.german_og_commander.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.german_og_commander.carry_tweak_corpse = "german_og_commander_body"
	self.german_og_commander.is_special = true
	self.german_og_commander.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_COMMANDER

	table.insert(self._enemies_list, "german_og_commander")
end

function CharacterTweakData:_init_german_officer(presets)
	self.german_officer = deep_clone(presets.base)
	self.german_officer.experience = {}
	self.german_officer.weapon = presets.weapon.expert
	self.german_officer.detection = presets.detection.normal
	self.german_officer.vision = presets.vision.commander
	self.german_officer.HEALTH_INIT = 650
	self.german_officer.BASE_HEALTH_INIT = 650
	self.german_officer.headshot_dmg_mul = 1
	self.german_officer.move_speed = presets.move_speed.very_fast
	self.german_officer.surrender_break_time = {
		10,
		15
	}
	self.german_officer.suppression = presets.suppression.no_supress
	self.german_officer.surrender = presets.surrender.normal
	self.german_officer.ecm_vulnerability = 1
	self.german_officer.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_officer.weapon_voice = "1"
	self.german_officer.experience.cable_tie = "tie_swat"
	self.german_officer.speech_prefix_p1 = "ger"
	self.german_officer.speech_prefix_p2 = "officer"
	self.german_officer.speech_prefix_count = 4
	self.german_officer.access = "fbi"
	self.german_officer.silent_priority_shout = "shout_loud_officer"
	self.german_officer.priority_waypoint = "waypoint_special_mark_officer"
	self.german_officer.dodge = presets.dodge.athletic
	self.german_officer.deathguard = true
	self.german_officer.chatter = presets.enemy_chatter.cop
	self.german_officer.steal_loot = false
	self.german_officer.no_retreat = true
	self.german_officer.no_arrest = true
	self.german_officer.loot_table = "elite_enemy"
	self.german_officer.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.german_officer.carry_tweak_corpse = "german_commander_body"

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
	self.soviet_nkvd_int_security_captain.surrender_break_time = {
		10,
		15
	}
	self.soviet_nkvd_int_security_captain.suppression = presets.suppression.no_supress
	self.soviet_nkvd_int_security_captain.surrender = presets.surrender.normal
	self.soviet_nkvd_int_security_captain.ecm_vulnerability = 1
	self.soviet_nkvd_int_security_captain.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.soviet_nkvd_int_security_captain.weapon_voice = "1"
	self.soviet_nkvd_int_security_captain.experience.cable_tie = "tie_swat"
	self.soviet_nkvd_int_security_captain.speech_prefix_p1 = "ger"
	self.soviet_nkvd_int_security_captain.speech_prefix_p2 = "officer"
	self.soviet_nkvd_int_security_captain.speech_prefix_count = 4
	self.soviet_nkvd_int_security_captain.access = "swat"
	self.soviet_nkvd_int_security_captain.silent_priority_shout = "shout_loud_soldier"
	self.soviet_nkvd_int_security_captain.dodge = presets.dodge.athletic
	self.soviet_nkvd_int_security_captain.deathguard = true
	self.soviet_nkvd_int_security_captain.chatter = presets.enemy_chatter.cop
	self.soviet_nkvd_int_security_captain.steal_loot = false
	self.soviet_nkvd_int_security_captain.no_retreat = true
	self.soviet_nkvd_int_security_captain.no_arrest = true
	self.soviet_nkvd_int_security_captain.loot_table = "special_enemy"
	self.soviet_nkvd_int_security_captain.type = CharacterTweakData.ENEMY_TYPE_OFFICER
	self.soviet_nkvd_int_security_captain.carry_tweak_corpse = "soviet_nkvd_int_security_captain_body"

	table.insert(self._enemies_list, "soviet_nkvd_int_security_captain")
end

function CharacterTweakData:_init_soviet_nkvd_int_security_captain_b(presets)
	self.soviet_nkvd_int_security_captain_b = deep_clone(self.soviet_nkvd_int_security_captain)
	self.soviet_nkvd_int_security_captain_b.weapon_voice = "1"
	self.soviet_nkvd_int_security_captain_b.speech_prefix_p1 = "ger"
	self.soviet_nkvd_int_security_captain_b.speech_prefix_p2 = "officer"
	self.soviet_nkvd_int_security_captain_b.speech_prefix_count = 4

	table.insert(self._enemies_list, "soviet_nkvd_int_security_captain_b")
end

function CharacterTweakData:_init_german_flamer(presets)
	self.german_flamer = deep_clone(presets.base)
	self.german_flamer.experience = {}
	self.german_flamer.detection = presets.detection.normal
	self.german_flamer.vision = presets.vision.easy
	self.german_flamer.HEALTH_INIT = 1900
	self.german_flamer.headshot_dmg_mul = 1
	self.german_flamer.friendly_fire_dmg_mul = 0.5
	self.german_flamer.dodge = presets.dodge.poor
	self.german_flamer.allowed_stances = {
		cbt = true
	}
	self.german_flamer.allowed_poses = {
		stand = true
	}
	self.german_flamer.always_face_enemy = true
	self.german_flamer.move_speed = presets.move_speed.very_slow
	self.german_flamer.crouch_move = false
	self.german_flamer.suppression = presets.suppression.no_supdeathguard
	self.german_flamer.no_run_start = true
	self.german_flamer.no_run_stop = true
	self.german_flamer.no_retreat = true
	self.german_flamer.no_arrest = true
	self.german_flamer.loot_table = "special_enemy"
	self.german_flamer.surrender = nil
	self.german_flamer.ecm_vulnerability = 0
	self.german_flamer.ecm_hurts = {
		ears = {
			max_duration = 9,
			min_duration = 7
		}
	}
	self.german_flamer.priority_shout = "shout_loud_flamer"
	self.german_flamer.priority_waypoint = "waypoint_special_mark_flamer"
	self.german_flamer.rescue_hostages = false
	self.german_flamer.deathguard = true
	self.german_flamer.no_equip_anim = true
	self.german_flamer.wall_fwd_offset = 100
	self.german_flamer.damage.explosion_damage_mul = 1
	self.german_flamer.calls_in = nil
	self.german_flamer.damage.hurt_severity = presets.hurt_severities.only_explosion_hurts
	self.german_flamer.damage.flamer_knocked = true
	self.german_flamer.use_animation_on_fire_damage = false
	self.german_flamer.flammable = true
	self.german_flamer.weapon = {
		ak47 = {}
	}
	self.german_flamer.weapon.ak47.aim_delay = {
		0,
		0.1
	}
	self.german_flamer.weapon.ak47.focus_delay = 7
	self.german_flamer.weapon.ak47.focus_dis = 200
	self.german_flamer.weapon.ak47.spread = 0
	self.german_flamer.weapon.ak47.miss_dis = 600
	self.german_flamer.weapon.ak47.RELOAD_SPEED = 1
	self.german_flamer.weapon.ak47.melee_speed = 1
	self.german_flamer.weapon.ak47.melee_dmg = 2
	self.german_flamer.weapon.ak47.melee_retry_delay = {
		1,
		2
	}
	self.german_flamer.weapon.ak47.max_range = 950
	self.german_flamer.weapon.ak47.additional_weapon_stats = {
		cooldown_duration = 1.25,
		shooting_duration = 3.5
	}
	self.german_flamer.weapon.ak47.range = {
		optimal = 300,
		far = 300,
		close = 300
	}
	self.german_flamer.weapon.ak47.autofire_rounds = {
		25,
		50
	}
	self.german_flamer.weapon.ak47.use_laser = false
	self.german_flamer.weapon.ak47.FALLOFF = {
		{
			dmg_mul = 4,
			r = 0,
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
			dmg_mul = 3,
			r = 300,
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
			dmg_mul = 1,
			r = 1100,
			acc = {
				5,
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
	}

	self:_process_weapon_usage_table(self.german_flamer.weapon)

	self.german_flamer.weapon_voice = "3"
	self.german_flamer.experience.cable_tie = "tie_swat"
	self.german_flamer.speech_prefix_p1 = "ger"
	self.german_flamer.speech_prefix_p2 = "flamer"
	self.german_flamer.speech_prefix_count = 4
	self.german_flamer.access = "tank"
	self.german_flamer.chatter = presets.enemy_chatter.cop
	self.german_flamer.announce_incomming = "incomming_flamer"
	self.german_flamer.steal_loot = nil
	self.german_flamer.use_animation_on_fire_damage = false
	self.german_flamer.type = CharacterTweakData.ENEMY_TYPE_FLAMER
	self.german_flamer.dismemberment_enabled = false
	self.german_flamer.is_special = true
	self.german_flamer.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_FLAMER
end

function CharacterTweakData:_init_german_sniper(presets)
	self.german_sniper = deep_clone(presets.base)
	self.german_sniper.experience = {}
	self.german_sniper.detection = presets.detection.sniper
	self.german_sniper.vision = presets.vision.easy
	self.german_sniper.HEALTH_INIT = 160
	self.german_sniper.BASE_HEALTH_INIT = 160
	self.german_sniper.headshot_dmg_mul = nil
	self.german_sniper.allowed_stances = {
		cbt = true
	}
	self.german_sniper.move_speed = presets.move_speed.normal
	self.german_sniper.suppression = presets.suppression.easy
	self.german_sniper.no_retreat = true
	self.german_sniper.no_arrest = true
	self.german_sniper.loot_table = "normal_enemy"
	self.german_sniper.surrender = nil
	self.german_sniper.ecm_vulnerability = 0
	self.german_sniper.ecm_hurts = {
		ears = {
			max_duration = 9,
			min_duration = 7
		}
	}
	self.german_sniper.priority_shout = "shout_loud_sniper"
	self.german_sniper.priority_waypoint = "waypoint_special_mark_sniper"
	self.german_sniper.rescue_hostages = false
	self.german_sniper.deathguard = false
	self.german_sniper.no_equip_anim = true
	self.german_sniper.wall_fwd_offset = 100
	self.german_sniper.damage.explosion_damage_mul = 1
	self.german_sniper.calls_in = nil
	self.german_sniper.use_animation_on_fire_damage = true
	self.german_sniper.flammable = true
	self.german_sniper.weapon = presets.weapon.sniper

	self:_process_weapon_usage_table(self.german_sniper.weapon)

	self.german_sniper.weapon_voice = "1"
	self.german_sniper.experience.cable_tie = "tie_swat"
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
				heavy = 0,
				health_limit = 0.3,
				light = 0,
				moderate = 0,
				none = 1
			},
			{
				heavy = 0,
				health_limit = 0.6,
				light = 0,
				moderate = 0,
				none = 1
			},
			{
				heavy = 0,
				health_limit = 0.9,
				light = 0,
				moderate = 0,
				none = 1
			},
			{
				heavy = 0,
				light = 0,
				moderate = 0,
				none = 1
			}
		}
	}

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
	self.german_spotter.headshot_dmg_mul = nil
	self.german_spotter.move_speed = presets.move_speed.slow
	self.german_spotter.crouch_move = false
	self.german_spotter.surrender_break_time = {
		10,
		15
	}
	self.german_spotter.suppression = presets.suppression.hard_agg
	self.german_spotter.surrender = presets.surrender.normal
	self.german_spotter.ecm_vulnerability = 1
	self.german_spotter.ecm_hurts = {
		ears = {
			max_duration = 10,
			min_duration = 8
		}
	}
	self.german_spotter.weapon_voice = "1"
	self.german_spotter.experience.cable_tie = "tie_swat"
	self.german_spotter.speech_prefix_p1 = "ger"
	self.german_spotter.speech_prefix_p2 = "elite"
	self.german_spotter.speech_prefix_count = 4
	self.german_spotter.access = "sniper"
	self.german_spotter.silent_priority_shout = "f37"
	self.german_spotter.priority_shout = "shout_loud_spotter"
	self.german_spotter.priority_waypoint = "waypoint_special_mark_spotter"
	self.german_spotter.dodge = presets.dodge.poor
	self.german_spotter.deathguard = true
	self.german_spotter.chatter = presets.enemy_chatter.cop
	self.german_spotter.steal_loot = false
	self.german_spotter.no_retreat = true
	self.german_spotter.no_arrest = true
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
				heavy = 0,
				health_limit = 0.3,
				light = 0,
				moderate = 0,
				none = 1
			},
			{
				heavy = 0,
				health_limit = 0.6,
				light = 0,
				moderate = 0,
				none = 1
			},
			{
				heavy = 0,
				health_limit = 0.9,
				light = 0,
				moderate = 0,
				none = 1
			},
			{
				heavy = 0,
				light = 0,
				moderate = 0,
				none = 1
			}
		}
	}
	self.german_spotter.dismemberment_enabled = false
	self.german_spotter.is_special = true
	self.german_spotter.special_type = CharacterTweakData.SPECIAL_UNIT_TYPE_SPOTTER

	table.insert(self._enemies_list, "german_spotter")
end

function CharacterTweakData:_init_escort(presets)
	self.escort = deep_clone(self.civilian)
	self.escort.HEALTH_INIT = 80
	self.escort.is_escort = true
	self.escort.escort_idle_talk = true
	self.escort.calls_in = nil
	self.escort.escort_safe_dist = 700
	self.escort.escort_scared_dist = 300
	self.escort.intimidateable = false
	self.escort.damage = presets.base.damage
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
	presets.hurt_severities.only_explosion_hurts = {
		bullet = {
			health_reference = "current",
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
					explode = 1
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
	presets.hurt_severities.base = {
		bullet = {
			health_reference = "current",
			zones = {
				{
					none = 1,
					health_limit = 0.01
				},
				{
					heavy = 0.05,
					health_limit = 0.3,
					light = 0.7,
					moderate = 0.05,
					none = 0.2
				},
				{
					heavy = 0.2,
					light = 0.4,
					moderate = 0.4,
					health_limit = 0.6
				},
				{
					heavy = 0.6,
					light = 0.2,
					moderate = 0.2,
					health_limit = 0.9
				},
				{
					light = 0,
					moderate = 0,
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
					none = 0.6,
					heavy = 0.4,
					health_limit = 0.2
				},
				{
					explode = 0.4,
					heavy = 0.6,
					health_limit = 0.5
				},
				{
					explode = 0.8,
					heavy = 0.2
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
					heavy = 0,
					health_limit = 0.3,
					light = 0.7,
					moderate = 0,
					none = 0.3
				},
				{
					heavy = 0,
					light = 1,
					moderate = 0,
					health_limit = 0.8
				},
				{
					heavy = 0.2,
					light = 0.6,
					moderate = 0.2,
					health_limit = 0.9
				},
				{
					light = 0,
					moderate = 0,
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
					poison = 1,
					none = 0
				}
			}
		}
	}
	presets.base = {
		HEALTH_INIT = 2.5,
		headshot_dmg_mul = 1,
		SPEED_WALK = {
			ntl = 120,
			cbt = 160,
			hos = 180,
			pnc = 160
		},
		SPEED_RUN = 370,
		crouch_move = true,
		shooting_death = true,
		suspicious = true,
		surrender_break_time = {
			20,
			30
		},
		submission_max = {
			45,
			60
		},
		submission_intimidate = 15,
		speech_prefix = "po",
		speech_prefix_count = 1,
		rescue_hostages = true,
		use_radio = nil,
		dodge = nil,
		challenges = {
			type = "law"
		},
		calls_in = true,
		dead_body_drop_sound = "body_fall",
		shout_radius = 500,
		shout_radius_difficulty = {
			200,
			500,
			1000,
			1200
		},
		kill_shout_chance = 0,
		experience = {}
	}
	presets.base.experience.cable_tie = "tie_swat"
	presets.base.damage = {
		hurt_severity = presets.hurt_severities.base,
		death_severity = 0.75,
		explosion_damage_mul = 1
	}
	presets.base.dismemberment_enabled = true
	presets.gang_member_damage = {
		HEALTH_INIT = 75,
		REGENERATE_TIME = 2,
		REGENERATE_TIME_AWAY = 0.2,
		DOWNED_TIME = tweak_data.player.damage.DOWNED_TIME,
		TASED_TIME = tweak_data.player.damage.TASED_TIME,
		BLEED_OUT_HEALTH_INIT = tweak_data.player.damage.BLEED_OUT_HEALTH_INIT,
		ARRESTED_TIME = tweak_data.player.damage.ARRESTED_TIME,
		INCAPACITATED_TIME = tweak_data.player.damage.INCAPACITATED_TIME,
		hurt_severity = deep_clone(presets.hurt_severities.base)
	}
	presets.gang_member_damage.hurt_severity.bullet = {
		health_reference = "current",
		zones = {
			{
				none = 0.3,
				light = 0.6,
				moderate = 0.1,
				health_limit = 0.4
			},
			{
				none = 0.1,
				light = 0.7,
				moderate = 0.2,
				health_limit = 0.7
			},
			{
				heavy = 0.1,
				light = 0.5,
				moderate = 0.3,
				none = 0.1
			}
		}
	}
	presets.gang_member_damage.MIN_DAMAGE_INTERVAL = 0.1
	presets.gang_member_damage.respawn_time_penalty = 0
	presets.gang_member_damage.base_respawn_time_penalty = 5
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
	presets.weapon.normal.usa_garand_npc.aim_delay = {
		6,
		8
	}
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
		optimal = 3500,
		far = 5000,
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
	presets.weapon.normal.usa_m1911_npc.aim_delay = {
		6,
		8
	}
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
		optimal = 3500,
		far = 5000,
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
	presets.weapon.normal.usa_thomspon_npc.aim_delay = {
		6,
		8
	}
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
		optimal = 3500,
		far = 5000,
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
	presets.weapon.normal.ger_kar98_npc.aim_delay = {
		1.5,
		3
	}
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
		optimal = 3500,
		far = 6000,
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
	presets.weapon.normal.ger_luger_npc.aim_delay = {
		1.5,
		3
	}
	presets.weapon.normal.ger_luger_npc.focus_delay = 2
	presets.weapon.normal.ger_luger_npc.focus_dis = 200
	presets.weapon.normal.ger_luger_npc.spread = 20
	presets.weapon.normal.ger_luger_npc.miss_dis = 50
	presets.weapon.normal.ger_luger_npc.RELOAD_SPEED = 0.8
	presets.weapon.normal.ger_luger_npc.melee_speed = 1
	presets.weapon.normal.ger_luger_npc.melee_dmg = 5
	presets.weapon.normal.ger_luger_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.ger_luger_npc.range = {
		optimal = 1200,
		far = 2200,
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
			dmg_mul = 0.5,
			r = 1500,
			acc = {
				0.2,
				0.7
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
			dmg_mul = 0.25,
			r = 2000,
			acc = {
				0.05,
				0.55
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
			dmg_mul = 0,
			r = 2500,
			acc = {
				0.05,
				0.25
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
	presets.weapon.normal.ger_mp38_npc.aim_delay = {
		1.5,
		3
	}
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
		optimal = 2200,
		far = 2400,
		close = 1000
	}
	presets.weapon.normal.ger_mp38_npc.autofire_rounds = {
		3,
		6
	}
	presets.weapon.normal.ger_mp38_npc.FALLOFF = {
		{
			dmg_mul = 1,
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
	presets.weapon.normal.ger_stg44_npc.aim_delay = {
		1.5,
		3
	}
	presets.weapon.normal.ger_stg44_npc.focus_delay = 2
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
		optimal = 2400,
		far = 2600,
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
	presets.weapon.normal.ger_geco_npc.aim_delay = {
		1.5,
		3
	}
	presets.weapon.normal.ger_geco_npc.focus_delay = 2
	presets.weapon.normal.ger_geco_npc.focus_dis = 200
	presets.weapon.normal.ger_geco_npc.spread = 15
	presets.weapon.normal.ger_geco_npc.miss_dis = 20
	presets.weapon.normal.ger_geco_npc.RELOAD_SPEED = 2
	presets.weapon.normal.ger_geco_npc.melee_speed = 1
	presets.weapon.normal.ger_geco_npc.melee_dmg = 5
	presets.weapon.normal.ger_geco_npc.melee_retry_delay = {
		1,
		2
	}
	presets.weapon.normal.ger_geco_npc.range = {
		optimal = 800,
		far = 1000,
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
	presets.weapon.good.usa_garand_npc.aim_delay = {
		4,
		6
	}
	presets.weapon.good.usa_garand_npc.focus_delay = 2
	presets.weapon.good.usa_garand_npc.focus_dis = 200
	presets.weapon.good.usa_garand_npc.spread = 20
	presets.weapon.good.usa_garand_npc.miss_dis = 40
	presets.weapon.good.usa_garand_npc.RELOAD_SPEED = 1
	presets.weapon.good.usa_garand_npc.melee_speed = 1
	presets.weapon.good.usa_garand_npc.melee_dmg = 2
	presets.weapon.good.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.good.usa_garand_npc.range = {
		optimal = 3500,
		far = 5000,
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
	presets.weapon.good.usa_m1911_npc.aim_delay = {
		4,
		6
	}
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
	presets.weapon.good.usa_thomspon_npc.aim_delay = {
		1,
		2
	}
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
	presets.weapon.good.ger_kar98_npc.aim_delay = {
		1,
		2
	}
	presets.weapon.good.ger_kar98_npc.focus_delay = 2
	presets.weapon.good.ger_kar98_npc.focus_dis = 200
	presets.weapon.good.ger_kar98_npc.spread = 20
	presets.weapon.good.ger_kar98_npc.miss_dis = 40
	presets.weapon.good.ger_kar98_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_kar98_npc.melee_speed = 1
	presets.weapon.good.ger_kar98_npc.melee_dmg = 5
	presets.weapon.good.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.good.ger_kar98_npc.range = {
		optimal = 3500,
		far = 4500,
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
	presets.weapon.good.ger_luger_npc.aim_delay = {
		1,
		2
	}
	presets.weapon.good.ger_luger_npc.focus_delay = 2
	presets.weapon.good.ger_luger_npc.focus_dis = 200
	presets.weapon.good.ger_luger_npc.spread = 20
	presets.weapon.good.ger_luger_npc.miss_dis = 50
	presets.weapon.good.ger_luger_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_luger_npc.melee_speed = presets.weapon.normal.ger_luger_npc.melee_speed
	presets.weapon.good.ger_luger_npc.melee_dmg = 5
	presets.weapon.good.ger_luger_npc.melee_retry_delay = presets.weapon.normal.ger_luger_npc.melee_retry_delay
	presets.weapon.good.ger_luger_npc.range = {
		optimal = 1200,
		far = 2200,
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
			r = 1500,
			acc = {
				0.4,
				0.9
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
			dmg_mul = 0.5,
			r = 2000,
			acc = {
				0.15,
				0.65
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
			dmg_mul = 0,
			r = 2500,
			acc = {
				0.05,
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
	presets.weapon.good.ger_mp38_npc.aim_delay = {
		1,
		2
	}
	presets.weapon.good.ger_mp38_npc.focus_delay = 2
	presets.weapon.good.ger_mp38_npc.focus_dis = 200
	presets.weapon.good.ger_mp38_npc.spread = 15
	presets.weapon.good.ger_mp38_npc.miss_dis = 10
	presets.weapon.good.ger_mp38_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_mp38_npc.melee_speed = presets.weapon.normal.ger_mp38_npc.melee_speed
	presets.weapon.good.ger_mp38_npc.melee_dmg = 5
	presets.weapon.good.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.good.ger_mp38_npc.range = {
		optimal = 2200,
		far = 2500,
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
	presets.weapon.good.ger_stg44_npc.aim_delay = {
		1,
		2
	}
	presets.weapon.good.ger_stg44_npc.focus_delay = 2
	presets.weapon.good.ger_stg44_npc.focus_dis = 200
	presets.weapon.good.ger_stg44_npc.spread = 20
	presets.weapon.good.ger_stg44_npc.miss_dis = 40
	presets.weapon.good.ger_stg44_npc.RELOAD_SPEED = 1
	presets.weapon.good.ger_stg44_npc.melee_speed = 1
	presets.weapon.good.ger_stg44_npc.melee_dmg = 5
	presets.weapon.good.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.good.ger_stg44_npc.range = {
		optimal = 2400,
		far = 2600,
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
	presets.weapon.good.ger_geco_npc.aim_delay = {
		1,
		2
	}
	presets.weapon.good.ger_geco_npc.focus_delay = 2
	presets.weapon.good.ger_geco_npc.focus_dis = 200
	presets.weapon.good.ger_geco_npc.spread = 15
	presets.weapon.good.ger_geco_npc.miss_dis = 20
	presets.weapon.good.ger_geco_npc.RELOAD_SPEED = 1.75
	presets.weapon.good.ger_geco_npc.melee_speed = 1
	presets.weapon.good.ger_geco_npc.melee_dmg = 5
	presets.weapon.good.ger_geco_npc.melee_retry_delay = presets.weapon.normal.ger_geco_npc.melee_retry_delay
	presets.weapon.good.ger_geco_npc.range = {
		optimal = 1200,
		far = 2000,
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
	presets.weapon.expert.usa_garand_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.expert.usa_garand_npc.focus_delay = 2
	presets.weapon.expert.usa_garand_npc.focus_dis = 200
	presets.weapon.expert.usa_garand_npc.spread = 20
	presets.weapon.expert.usa_garand_npc.miss_dis = 40
	presets.weapon.expert.usa_garand_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.usa_garand_npc.melee_speed = 1
	presets.weapon.expert.usa_garand_npc.melee_dmg = 2
	presets.weapon.expert.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.expert.usa_garand_npc.range = {
		optimal = 3500,
		far = 5000,
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
	presets.weapon.expert.usa_m1911_npc.aim_delay = {
		0.5,
		1
	}
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
	presets.weapon.expert.usa_thomspon_npc.aim_delay = {
		2,
		4
	}
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
	presets.weapon.expert.ger_kar98_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.expert.ger_kar98_npc.focus_delay = 1
	presets.weapon.expert.ger_kar98_npc.focus_dis = 200
	presets.weapon.expert.ger_kar98_npc.spread = 20
	presets.weapon.expert.ger_kar98_npc.miss_dis = 40
	presets.weapon.expert.ger_kar98_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.ger_kar98_npc.melee_speed = 1
	presets.weapon.expert.ger_kar98_npc.melee_dmg = 10
	presets.weapon.expert.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.expert.ger_kar98_npc.range = {
		optimal = 2600,
		far = 3000,
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
	presets.weapon.expert.ger_luger_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.expert.ger_luger_npc.focus_delay = 1
	presets.weapon.expert.ger_luger_npc.focus_dis = 200
	presets.weapon.expert.ger_luger_npc.spread = 20
	presets.weapon.expert.ger_luger_npc.miss_dis = 50
	presets.weapon.expert.ger_luger_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.ger_luger_npc.melee_speed = presets.weapon.normal.ger_luger_npc.melee_speed
	presets.weapon.expert.ger_luger_npc.melee_dmg = 10
	presets.weapon.expert.ger_luger_npc.melee_retry_delay = presets.weapon.normal.ger_luger_npc.melee_retry_delay
	presets.weapon.expert.ger_luger_npc.range = {
		optimal = 1200,
		far = 2200,
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
			dmg_mul = 3,
			r = 1500,
			acc = {
				0.6,
				0.9
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
			dmg_mul = 2,
			r = 2000,
			acc = {
				0.15,
				0.65
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
			r = 2500,
			acc = {
				0.05,
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
	presets.weapon.expert.ger_mp38_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.expert.ger_mp38_npc.focus_delay = 1
	presets.weapon.expert.ger_mp38_npc.focus_dis = 200
	presets.weapon.expert.ger_mp38_npc.spread = 15
	presets.weapon.expert.ger_mp38_npc.miss_dis = 10
	presets.weapon.expert.ger_mp38_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.ger_mp38_npc.melee_speed = presets.weapon.normal.ger_mp38_npc.melee_speed
	presets.weapon.expert.ger_mp38_npc.melee_dmg = 10
	presets.weapon.expert.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.expert.ger_mp38_npc.range = {
		optimal = 1200,
		far = 1400,
		close = 1000
	}
	presets.weapon.expert.ger_mp38_npc.autofire_rounds = presets.weapon.normal.ger_mp38_npc.autofire_rounds
	presets.weapon.expert.ger_mp38_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
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
	presets.weapon.expert.ger_stg44_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.expert.ger_stg44_npc.focus_delay = 1
	presets.weapon.expert.ger_stg44_npc.focus_dis = 200
	presets.weapon.expert.ger_stg44_npc.spread = 20
	presets.weapon.expert.ger_stg44_npc.miss_dis = 40
	presets.weapon.expert.ger_stg44_npc.RELOAD_SPEED = 1.4
	presets.weapon.expert.ger_stg44_npc.melee_speed = 1
	presets.weapon.expert.ger_stg44_npc.melee_dmg = 10
	presets.weapon.expert.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.expert.ger_stg44_npc.range = {
		optimal = 2400,
		far = 3200,
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
	presets.weapon.expert.ger_geco_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.expert.ger_geco_npc.focus_delay = 1
	presets.weapon.expert.ger_geco_npc.focus_dis = 200
	presets.weapon.expert.ger_geco_npc.spread = 15
	presets.weapon.expert.ger_geco_npc.miss_dis = 20
	presets.weapon.expert.ger_geco_npc.RELOAD_SPEED = 1.5
	presets.weapon.expert.ger_geco_npc.melee_speed = 1
	presets.weapon.expert.ger_geco_npc.melee_dmg = 10
	presets.weapon.expert.ger_geco_npc.melee_retry_delay = presets.weapon.normal.ger_geco_npc.melee_retry_delay
	presets.weapon.expert.ger_geco_npc.range = {
		optimal = 900,
		far = 1000,
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
	presets.weapon.sniper = {
		ger_kar98_npc = {}
	}
	presets.weapon.sniper.ger_kar98_npc.aim_delay = {
		0,
		0.1
	}
	presets.weapon.sniper.ger_kar98_npc.focus_delay = 7
	presets.weapon.sniper.ger_kar98_npc.focus_dis = 1000
	presets.weapon.sniper.ger_kar98_npc.spread = 30
	presets.weapon.sniper.ger_kar98_npc.miss_dis = 250
	presets.weapon.sniper.ger_kar98_npc.RELOAD_SPEED = 0.75
	presets.weapon.sniper.ger_kar98_npc.melee_speed = presets.weapon.normal.ger_kar98_npc.melee_speed
	presets.weapon.sniper.ger_kar98_npc.melee_dmg = presets.weapon.normal.ger_kar98_npc.melee_dmg
	presets.weapon.sniper.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.sniper.ger_kar98_npc.range = {
		optimal = 40000,
		far = 80000,
		close = 15000
	}
	presets.weapon.sniper.ger_kar98_npc.use_laser = true
	presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 5,
			r = 700,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				2,
				4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 5,
			r = 3500,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				3,
				4
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
			r = 10000,
			acc = {
				0,
				0.25
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.gang_member = {
		ger_luger_npc = {},
		ger_mp38_npc = {},
		ger_stg44_npc = {},
		usa_garand_npc = {},
		usa_m1911_npc = {},
		thompson_npc = {}
	}
	presets.weapon.gang_member.ger_luger_npc.aim_delay = {
		0,
		1
	}
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
	presets.weapon.gang_member.ger_mp38_npc.aim_delay = {
		10,
		10
	}
	presets.weapon.gang_member.ger_mp38_npc.focus_delay = 3
	presets.weapon.gang_member.ger_mp38_npc.focus_dis = 3000
	presets.weapon.gang_member.ger_mp38_npc.spread = 25
	presets.weapon.gang_member.ger_mp38_npc.miss_dis = 10
	presets.weapon.gang_member.ger_mp38_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.ger_mp38_npc.melee_speed = 2
	presets.weapon.gang_member.ger_mp38_npc.melee_dmg = 2
	presets.weapon.gang_member.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.gang_member.ger_mp38_npc.range = {
		optimal = 2500,
		far = 6000,
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
	presets.weapon.gang_member.ger_stg44_npc.aim_delay = {
		0,
		1
	}
	presets.weapon.gang_member.ger_stg44_npc.focus_delay = 1
	presets.weapon.gang_member.ger_stg44_npc.focus_dis = 3000
	presets.weapon.gang_member.ger_stg44_npc.spread = 25
	presets.weapon.gang_member.ger_stg44_npc.miss_dis = 10
	presets.weapon.gang_member.ger_stg44_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.ger_stg44_npc.melee_speed = 2
	presets.weapon.gang_member.ger_stg44_npc.melee_dmg = 2
	presets.weapon.gang_member.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.gang_member.ger_stg44_npc.range = {
		optimal = 2500,
		far = 6000,
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
	presets.weapon.gang_member.usa_garand_npc.aim_delay = {
		0,
		1
	}
	presets.weapon.gang_member.usa_garand_npc.focus_delay = 0.15
	presets.weapon.gang_member.usa_garand_npc.focus_dis = 3000
	presets.weapon.gang_member.usa_garand_npc.spread = 9
	presets.weapon.gang_member.usa_garand_npc.miss_dis = 0
	presets.weapon.gang_member.usa_garand_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.usa_garand_npc.melee_speed = 2
	presets.weapon.gang_member.usa_garand_npc.melee_dmg = 2
	presets.weapon.gang_member.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.gang_member.usa_garand_npc.range = {
		optimal = 3500,
		far = 8000,
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
	presets.weapon.gang_member.usa_m1911_npc.aim_delay = {
		0,
		1
	}
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
	presets.weapon.gang_member.thompson_npc.aim_delay = {
		0,
		0.1
	}
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
		optimal = 2000,
		far = 6000,
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
	presets.weapon.insane.usa_garand_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.insane.usa_garand_npc.focus_delay = 2
	presets.weapon.insane.usa_garand_npc.focus_dis = 200
	presets.weapon.insane.usa_garand_npc.spread = 20
	presets.weapon.insane.usa_garand_npc.miss_dis = 40
	presets.weapon.insane.usa_garand_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.usa_garand_npc.melee_speed = 1
	presets.weapon.insane.usa_garand_npc.melee_dmg = 2
	presets.weapon.insane.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.insane.usa_garand_npc.range = {
		optimal = 3000,
		far = 5000,
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
	presets.weapon.insane.usa_m1911_npc.aim_delay = {
		0.5,
		1
	}
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
	presets.weapon.insane.usa_thomspon_npc.aim_delay = {
		2,
		4
	}
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
	presets.weapon.insane.ger_kar98_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.insane.ger_kar98_npc.focus_delay = 1
	presets.weapon.insane.ger_kar98_npc.focus_dis = 200
	presets.weapon.insane.ger_kar98_npc.spread = 20
	presets.weapon.insane.ger_kar98_npc.miss_dis = 40
	presets.weapon.insane.ger_kar98_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.ger_kar98_npc.melee_speed = 1
	presets.weapon.insane.ger_kar98_npc.melee_dmg = 10
	presets.weapon.insane.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.insane.ger_kar98_npc.range = {
		optimal = 3600,
		far = 5000,
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
	presets.weapon.insane.ger_luger_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.insane.ger_luger_npc.focus_delay = 1
	presets.weapon.insane.ger_luger_npc.focus_dis = 200
	presets.weapon.insane.ger_luger_npc.spread = 20
	presets.weapon.insane.ger_luger_npc.miss_dis = 50
	presets.weapon.insane.ger_luger_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.ger_luger_npc.melee_speed = presets.weapon.normal.ger_luger_npc.melee_speed
	presets.weapon.insane.ger_luger_npc.melee_dmg = 10
	presets.weapon.insane.ger_luger_npc.melee_retry_delay = presets.weapon.normal.ger_luger_npc.melee_retry_delay
	presets.weapon.insane.ger_luger_npc.range = {
		optimal = 800,
		far = 1200,
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
			dmg_mul = 3,
			r = 1500,
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
			dmg_mul = 2,
			r = 2500,
			acc = {
				0.15,
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
	presets.weapon.insane.ger_mp38_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.insane.ger_mp38_npc.focus_delay = 1
	presets.weapon.insane.ger_mp38_npc.focus_dis = 200
	presets.weapon.insane.ger_mp38_npc.spread = 15
	presets.weapon.insane.ger_mp38_npc.miss_dis = 10
	presets.weapon.insane.ger_mp38_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.ger_mp38_npc.melee_speed = presets.weapon.normal.ger_mp38_npc.melee_speed
	presets.weapon.insane.ger_mp38_npc.melee_dmg = 10
	presets.weapon.insane.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.insane.ger_mp38_npc.range = {
		optimal = 2200,
		far = 3400,
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
			dmg_mul = 4,
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
	presets.weapon.insane.ger_stg44_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.insane.ger_stg44_npc.focus_delay = 1
	presets.weapon.insane.ger_stg44_npc.focus_dis = 200
	presets.weapon.insane.ger_stg44_npc.spread = 20
	presets.weapon.insane.ger_stg44_npc.miss_dis = 40
	presets.weapon.insane.ger_stg44_npc.RELOAD_SPEED = 1.4
	presets.weapon.insane.ger_stg44_npc.melee_speed = 1
	presets.weapon.insane.ger_stg44_npc.melee_dmg = 10
	presets.weapon.insane.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.insane.ger_stg44_npc.range = {
		optimal = 2400,
		far = 3600,
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
	presets.weapon.insane.ger_geco_npc.aim_delay = {
		0.5,
		1
	}
	presets.weapon.insane.ger_geco_npc.focus_delay = 1
	presets.weapon.insane.ger_geco_npc.focus_dis = 200
	presets.weapon.insane.ger_geco_npc.spread = 15
	presets.weapon.insane.ger_geco_npc.miss_dis = 20
	presets.weapon.insane.ger_geco_npc.RELOAD_SPEED = 1.3
	presets.weapon.insane.ger_geco_npc.melee_speed = 1
	presets.weapon.insane.ger_geco_npc.melee_dmg = 10
	presets.weapon.insane.ger_geco_npc.melee_retry_delay = presets.weapon.normal.ger_geco_npc.melee_retry_delay
	presets.weapon.insane.ger_geco_npc.range = {
		optimal = 800,
		far = 1000,
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
	presets.weapon.sniper = {
		ger_kar98_npc = {}
	}
	presets.weapon.sniper.ger_kar98_npc.aim_delay = {
		0,
		0.1
	}
	presets.weapon.sniper.ger_kar98_npc.focus_delay = 7
	presets.weapon.sniper.ger_kar98_npc.focus_dis = 1000
	presets.weapon.sniper.ger_kar98_npc.spread = 30
	presets.weapon.sniper.ger_kar98_npc.miss_dis = 250
	presets.weapon.sniper.ger_kar98_npc.RELOAD_SPEED = 1.3
	presets.weapon.sniper.ger_kar98_npc.melee_speed = presets.weapon.normal.ger_kar98_npc.melee_speed
	presets.weapon.sniper.ger_kar98_npc.melee_dmg = presets.weapon.normal.ger_kar98_npc.melee_dmg
	presets.weapon.sniper.ger_kar98_npc.melee_retry_delay = presets.weapon.normal.ger_kar98_npc.melee_retry_delay
	presets.weapon.sniper.ger_kar98_npc.range = {
		optimal = 40000,
		far = 80000,
		close = 15000
	}
	presets.weapon.sniper.ger_kar98_npc.use_laser = true
	presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 4.5,
			r = 700,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				2,
				4
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
			r = 3500,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				3,
				4
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
			r = 10000,
			acc = {
				0,
				0.25
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	presets.weapon.gang_member = {
		ger_luger_npc = {},
		ger_mp38_npc = {},
		ger_stg44_npc = {},
		usa_garand_npc = {},
		usa_m1911_npc = {},
		thompson_npc = {}
	}
	presets.weapon.gang_member.ger_luger_npc.aim_delay = {
		0,
		1
	}
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
	presets.weapon.gang_member.ger_mp38_npc.aim_delay = {
		10,
		10
	}
	presets.weapon.gang_member.ger_mp38_npc.focus_delay = 3
	presets.weapon.gang_member.ger_mp38_npc.focus_dis = 3000
	presets.weapon.gang_member.ger_mp38_npc.spread = 25
	presets.weapon.gang_member.ger_mp38_npc.miss_dis = 10
	presets.weapon.gang_member.ger_mp38_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.ger_mp38_npc.melee_speed = 2
	presets.weapon.gang_member.ger_mp38_npc.melee_dmg = 2
	presets.weapon.gang_member.ger_mp38_npc.melee_retry_delay = presets.weapon.normal.ger_mp38_npc.melee_retry_delay
	presets.weapon.gang_member.ger_mp38_npc.range = {
		optimal = 2500,
		far = 6000,
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
	presets.weapon.gang_member.ger_stg44_npc.aim_delay = {
		0,
		1
	}
	presets.weapon.gang_member.ger_stg44_npc.focus_delay = 1
	presets.weapon.gang_member.ger_stg44_npc.focus_dis = 3000
	presets.weapon.gang_member.ger_stg44_npc.spread = 25
	presets.weapon.gang_member.ger_stg44_npc.miss_dis = 10
	presets.weapon.gang_member.ger_stg44_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.ger_stg44_npc.melee_speed = 2
	presets.weapon.gang_member.ger_stg44_npc.melee_dmg = 2
	presets.weapon.gang_member.ger_stg44_npc.melee_retry_delay = presets.weapon.normal.ger_stg44_npc.melee_retry_delay
	presets.weapon.gang_member.ger_stg44_npc.range = {
		optimal = 2500,
		far = 6000,
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
	presets.weapon.gang_member.usa_garand_npc.aim_delay = {
		0,
		1
	}
	presets.weapon.gang_member.usa_garand_npc.focus_delay = 0.15
	presets.weapon.gang_member.usa_garand_npc.focus_dis = 3000
	presets.weapon.gang_member.usa_garand_npc.spread = 9
	presets.weapon.gang_member.usa_garand_npc.miss_dis = 0
	presets.weapon.gang_member.usa_garand_npc.RELOAD_SPEED = 1
	presets.weapon.gang_member.usa_garand_npc.melee_speed = 2
	presets.weapon.gang_member.usa_garand_npc.melee_dmg = 2
	presets.weapon.gang_member.usa_garand_npc.melee_retry_delay = presets.weapon.normal.usa_garand_npc.melee_retry_delay
	presets.weapon.gang_member.usa_garand_npc.range = {
		optimal = 3500,
		far = 8000,
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
	presets.weapon.gang_member.usa_m1911_npc.aim_delay = {
		0,
		1
	}
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
	presets.weapon.gang_member.thompson_npc.aim_delay = {
		0,
		0.1
	}
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
		optimal = 2000,
		far = 6000,
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
	presets.vision.easy.idle.cone_2.speed_mul = 2.5
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
	presets.vision.normal.idle.cone_2.speed_mul = 2.5
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
	presets.vision.hard.idle.cone_2.speed_mul = 2.5
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
	presets.vision.special_forces.idle.cone_2.speed_mul = 2
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
	presets.vision.spotter.combat.cone_1.distance = 2200
	presets.vision.spotter.combat.cone_1.speed_mul = 2
	presets.vision.spotter.combat.cone_2.angle = 280
	presets.vision.spotter.combat.cone_2.distance = 3200
	presets.vision.spotter.combat.cone_2.speed_mul = 4
	presets.vision.spotter.combat.cone_3.angle = 280
	presets.vision.spotter.combat.cone_3.distance = 5200
	presets.vision.spotter.combat.cone_3.speed_mul = 6
	presets.vision.spotter.idle = deep_clone(presets.vision.spotter.combat)
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
	presets.detection.normal.recon.name = "normal.recon"
	presets.detection.normal.guard.dis_max = 10000
	presets.detection.normal.guard.angle_max = 120
	presets.detection.normal.guard.delay = {
		0,
		0
	}
	presets.detection.normal.guard.search_for_player = true
	presets.detection.normal.guard.name = "normal.guard"
	presets.detection.normal.ntl.dis_max = 4000
	presets.detection.normal.ntl.angle_max = 60
	presets.detection.normal.ntl.delay = {
		0.2,
		2
	}
	presets.detection.normal.ntl.use_uncover_range = true
	presets.detection.normal.ntl.search_for_player = true
	presets.detection.normal.ntl.name = "normal.ntl"
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
	presets.detection.sniper.idle.dis_max = 10000
	presets.detection.sniper.idle.angle_max = 180
	presets.detection.sniper.idle.delay = {
		0.5,
		1
	}
	presets.detection.sniper.idle.use_uncover_range = true
	presets.detection.sniper.combat.dis_max = 10000
	presets.detection.sniper.combat.angle_max = 120
	presets.detection.sniper.combat.delay = {
		0.5,
		1
	}
	presets.detection.sniper.combat.use_uncover_range = true
	presets.detection.sniper.recon.dis_max = 10000
	presets.detection.sniper.recon.angle_max = 120
	presets.detection.sniper.recon.delay = {
		0.5,
		1
	}
	presets.detection.sniper.recon.use_uncover_range = true
	presets.detection.sniper.guard.dis_max = 10000
	presets.detection.sniper.guard.angle_max = 150
	presets.detection.sniper.guard.delay = {
		0.3,
		1
	}
	presets.detection.sniper.ntl = presets.detection.normal.ntl
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
					chance = 0.9,
					check_timeout = {
						0,
						0
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
						1,
						2
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
				preemptive = {
					chance = 0.5,
					check_timeout = {
						1,
						3
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
							shoot_chance = 0.8,
							shoot_accuracy = 0.5,
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
							shoot_chance = 0.8,
							shoot_accuracy = 0.7,
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
							shoot_chance = 0.5,
							shoot_accuracy = 0.4,
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
							shoot_chance = 0.8,
							shoot_accuracy = 0.5,
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
							shoot_chance = 1,
							shoot_accuracy = 0.7,
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
							shoot_chance = 0.5,
							shoot_accuracy = 0.4,
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
							shoot_chance = 1,
							shoot_accuracy = 0.7,
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
							shoot_chance = 1,
							shoot_accuracy = 0.8,
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
							shoot_chance = 0.8,
							shoot_accuracy = 0.6,
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
						strafe = 120,
						fwd = 150,
						bwd = 100
					},
					hos = {
						strafe = 190,
						fwd = 210,
						bwd = 160
					},
					cbt = {
						strafe = 175,
						fwd = 210,
						bwd = 160
					}
				},
				run = {
					hos = {
						strafe = 192,
						fwd = 500,
						bwd = 230
					},
					cbt = {
						strafe = 250,
						fwd = 500,
						bwd = 230
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 160,
						fwd = 174,
						bwd = 163
					},
					cbt = {
						strafe = 160,
						fwd = 174,
						bwd = 163
					}
				},
				run = {
					hos = {
						strafe = 245,
						fwd = 312,
						bwd = 260
					},
					cbt = {
						strafe = 245,
						fwd = 312,
						bwd = 260
					}
				}
			}
		},
		lightning = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 110
					},
					hos = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					},
					cbt = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					}
				},
				run = {
					hos = {
						strafe = 400,
						fwd = 800,
						bwd = 350
					},
					cbt = {
						strafe = 380,
						fwd = 750,
						bwd = 320
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 210,
						fwd = 245,
						bwd = 190
					},
					cbt = {
						strafe = 190,
						fwd = 255,
						bwd = 190
					}
				},
				run = {
					hos = {
						strafe = 300,
						fwd = 420,
						bwd = 250
					},
					cbt = {
						strafe = 300,
						fwd = 412,
						bwd = 280
					}
				}
			}
		},
		very_slow = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 140,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 100,
						fwd = 144,
						bwd = 125
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 130,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 100,
						fwd = 144,
						bwd = 125
					}
				}
			}
		},
		slow = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 150,
						fwd = 360,
						bwd = 135
					},
					cbt = {
						strafe = 150,
						fwd = 360,
						bwd = 155
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					},
					cbt = {
						strafe = 120,
						fwd = 144,
						bwd = 113
					}
				},
				run = {
					hos = {
						strafe = 140,
						fwd = 360,
						bwd = 150
					},
					cbt = {
						strafe = 140,
						fwd = 360,
						bwd = 155
					}
				}
			}
		},
		normal = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 100
					},
					hos = {
						strafe = 190,
						fwd = 220,
						bwd = 170
					},
					cbt = {
						strafe = 190,
						fwd = 220,
						bwd = 170
					}
				},
				run = {
					hos = {
						strafe = 290,
						fwd = 450,
						bwd = 255
					},
					cbt = {
						strafe = 250,
						fwd = 400,
						bwd = 255
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 170,
						fwd = 210,
						bwd = 160
					},
					cbt = {
						strafe = 170,
						fwd = 210,
						bwd = 160
					}
				},
				run = {
					hos = {
						strafe = 260,
						fwd = 310,
						bwd = 235
					},
					cbt = {
						strafe = 260,
						fwd = 350,
						bwd = 235
					}
				}
			}
		},
		fast = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 110
					},
					hos = {
						strafe = 215,
						fwd = 270,
						bwd = 185
					},
					cbt = {
						strafe = 215,
						fwd = 270,
						bwd = 185
					}
				},
				run = {
					hos = {
						strafe = 315,
						fwd = 625,
						bwd = 280
					},
					cbt = {
						strafe = 285,
						fwd = 450,
						bwd = 280
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 180,
						fwd = 235,
						bwd = 170
					},
					cbt = {
						strafe = 180,
						fwd = 235,
						bwd = 170
					}
				},
				run = {
					hos = {
						strafe = 280,
						fwd = 330,
						bwd = 255
					},
					cbt = {
						strafe = 270,
						fwd = 312,
						bwd = 255
					}
				}
			}
		},
		very_fast = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 150,
						bwd = 110
					},
					hos = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					},
					cbt = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					}
				},
				run = {
					hos = {
						strafe = 340,
						fwd = 670,
						bwd = 325
					},
					cbt = {
						strafe = 325,
						fwd = 475,
						bwd = 300
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 210,
						fwd = 245,
						bwd = 190
					},
					cbt = {
						strafe = 190,
						fwd = 255,
						bwd = 190
					}
				},
				run = {
					hos = {
						strafe = 282,
						fwd = 350,
						bwd = 268
					},
					cbt = {
						strafe = 282,
						fwd = 312,
						bwd = 268
					}
				}
			}
		},
		teamai = {
			stand = {
				walk = {
					ntl = {
						strafe = 120,
						fwd = 145,
						bwd = 120
					},
					hos = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					},
					cbt = {
						strafe = 225,
						fwd = 285,
						bwd = 215
					}
				},
				run = {
					hos = {
						strafe = 300,
						fwd = 500,
						bwd = 300
					},
					cbt = {
						strafe = 325,
						fwd = 475,
						bwd = 300
					}
				}
			},
			crouch = {
				walk = {
					hos = {
						strafe = 210,
						fwd = 245,
						bwd = 190
					},
					cbt = {
						strafe = 190,
						fwd = 255,
						bwd = 190
					}
				},
				run = {
					hos = {
						strafe = 282,
						fwd = 350,
						bwd = 268
					},
					cbt = {
						strafe = 282,
						fwd = 312,
						bwd = 268
					}
				}
			}
		}
	}

	for speed_preset_name, poses in pairs(presets.move_speed) do
		for pose, hastes in pairs(poses) do
			hastes.run.ntl = hastes.run.hos
		end

		poses.crouch.walk.ntl = poses.crouch.walk.hos
		poses.crouch.run.ntl = poses.crouch.run.hos
		poses.stand.run.ntl = poses.stand.run.hos
		poses.panic = poses.stand
	end

	presets.surrender = {
		easy = {
			base_chance = 0.75,
			significant_chance = 0.1,
			violence_timeout = 2,
			reasons = {
				pants_down = 1,
				isolated = 0.1,
				weapon_down = 0.8,
				health = {
					[1.0] = 0.2,
					[0.3] = 1
				}
			},
			factors = {
				unaware_of_aggressor = 0.08,
				enemy_weap_cold = 0.15,
				flanked = 0.07,
				aggressor_dis = {
					[300.0] = 0.15,
					[1000.0] = 0.02
				}
			}
		},
		normal = {
			base_chance = 0.5,
			significant_chance = 0.2,
			violence_timeout = 2,
			reasons = {
				pants_down = 1,
				isolated = 0.08,
				weapon_down = 0.5,
				health = {
					[1.0] = 0,
					[0.5] = 0.5
				}
			},
			factors = {
				unaware_of_aggressor = 0.1,
				enemy_weap_cold = 0.11,
				flanked = 0.05,
				aggressor_dis = {
					[300.0] = 0.1,
					[1000.0] = 0
				}
			}
		},
		hard = {
			base_chance = 0.35,
			significant_chance = 0.25,
			violence_timeout = 2,
			reasons = {
				pants_down = 0.8,
				weapon_down = 0.2,
				health = {
					[1.0] = 0,
					[0.35] = 0.5
				}
			},
			factors = {
				enemy_weap_cold = 0.05,
				unaware_of_aggressor = 0.1,
				flanked = 0.04,
				isolated = 0.1,
				aggressor_dis = {
					[300.0] = 0.1,
					[1000.0] = 0
				}
			}
		},
		special = {
			base_chance = 0.25,
			significant_chance = 0.25,
			violence_timeout = 2,
			reasons = {
				pants_down = 0.6,
				weapon_down = 0.02,
				health = {
					[0.5] = 0,
					[0.2] = 0.25
				}
			},
			factors = {
				enemy_weap_cold = 0.05,
				unaware_of_aggressor = 0.02,
				isolated = 0.05,
				flanked = 0.015
			}
		}
	}
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
		cop = {
			incomming_commander = true,
			clear = true,
			ready = true,
			contact = true,
			suppress = true,
			smoke = true,
			retreat = true,
			incomming_flamer = true,
			go_go = true,
			aggressive = true,
			follow_me = true
		},
		swat = {
			incomming_commander = true,
			clear = true,
			ready = true,
			contact = true,
			suppress = true,
			smoke = true,
			retreat = true,
			incomming_flamer = true,
			go_go = true,
			aggressive = true,
			follow_me = true
		},
		shield = {
			follow_me = true
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
		"ger_luger_npc_invisible",
		"ger_stg44_npc",
		"usa_garand_npc",
		"usa_m1911_npc",
		"thompson_npc",
		"ger_geco_npc",
		"ger_shotgun_npc"
	}
	self.weap_unit_names = {
		Idstring("units/vanilla/weapons/wpn_npc_spc_m42_flammenwerfer/wpn_npc_spc_m42_flammenwerfer"),
		Idstring("units/temp/weapons/wpn_npc_spc_panzerfaust_60/wpn_npc_spc_panzerfaust_60"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_k98/wpn_npc_ger_k98"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_k98/wpn_npc_ger_k98_sniper"),
		Idstring("units/vanilla/weapons/wpn_npc_binocular/wpn_npc_binocular"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_mp38/wpn_npc_ger_mp38"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_luger/wpn_npc_ger_luger_invisible"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_stg44/wpn_npc_ger_stg44"),
		Idstring("units/vanilla/weapons/wpn_npc_usa_garand/wpn_npc_usa_garand"),
		Idstring("units/vanilla/weapons/wpn_npc_usa_m1911/wpn_npc_usa_m1911"),
		Idstring("units/vanilla/weapons/wpn_npc_smg_thompson/wpn_npc_smg_thompson"),
		Idstring("units/vanilla/weapons/wpn_npc_ger_geco/wpn_npc_ger_geco"),
		Idstring("units/vanilla/weapons/ger_shotgun_npc/ger_shotgun_npc"),
		Idstring("units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_husk"),
		Idstring("units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace_husk"),
		Idstring("units/vanilla/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills_husk"),
		Idstring("units/vanilla/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343_husk"),
		Idstring("units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete_husk"),
		Idstring("units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty_husk"),
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

		if usage_data then
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

	self.presets.gang_member_damage.REGENERATE_TIME = 1.5
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.2
	self.presets.gang_member_damage.HEALTH_INIT = 175

	self:_set_characters_weapon_preset("normal")

	self.escort.HEALTH_INIT = 80
	self.flashbang_multiplier = 1
	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3,
			r = 700,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				2,
				4
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
			r = 3500,
			acc = {
				0.1,
				0.75
			},
			recoil = {
				3,
				4
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
			r = 10000,
			acc = {
				0,
				0.25
			},
			recoil = {
				3,
				5
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
	self.german_flamer.headshot_dmg_mul = 0.6
end

function CharacterTweakData:_set_difficulty_2()
	self:_multiply_all_hp(1.2)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 1)
	self:_multiply_weapon_delay(self.presets.weapon.good, 1)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 1)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 1)

	self.presets.gang_member_damage.REGENERATE_TIME = 1.5
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.4
	self.presets.gang_member_damage.HEALTH_INIT = 200

	self:_set_characters_weapon_preset("good")

	self.escort.HEALTH_INIT = 100
	self.flashbang_multiplier = 1.25
	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3,
			r = 700,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				2,
				4
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
			r = 3500,
			acc = {
				0.2,
				0.75
			},
			recoil = {
				3,
				4
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
			r = 10000,
			acc = {
				0,
				0.25
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.german_flamer.HEALTH_INIT = 3200
	self.german_flamer.headshot_dmg_mul = 0.45
end

function CharacterTweakData:_set_difficulty_3()
	self:_multiply_all_hp(1.35)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0.9)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0.9)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0.9)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.9)

	self.presets.gang_member_damage.REGENERATE_TIME = 1.5
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.5
	self.presets.gang_member_damage.HEALTH_INIT = 275

	self:_set_characters_weapon_preset("expert")

	self.escort.HEALTH_INIT = 120
	self.flashbang_multiplier = 1.5
	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 3.5,
			r = 700,
			acc = {
				0.5,
				0.95
			},
			recoil = {
				2,
				4
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
			r = 3500,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				3,
				4
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
			r = 10000,
			acc = {
				0,
				0.25
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.german_flamer.HEALTH_INIT = 4400
	self.german_flamer.headshot_dmg_mul = 0.35
end

function CharacterTweakData:_set_difficulty_4()
	self:_multiply_all_hp(1.45)
	self:_multiply_all_speeds(2, 2.1)
	self:_multiply_weapon_delay(self.presets.weapon.normal, 0.8)
	self:_multiply_weapon_delay(self.presets.weapon.good, 0.8)
	self:_multiply_weapon_delay(self.presets.weapon.expert, 0.8)
	self:_multiply_weapon_delay(self.presets.weapon.sniper, 3)
	self:_multiply_weapon_delay(self.presets.weapon.gang_member, 0.8)

	self.presets.gang_member_damage.REGENERATE_TIME = 1.5
	self.presets.gang_member_damage.REGENERATE_TIME_AWAY = 0.5
	self.presets.gang_member_damage.HEALTH_INIT = 325

	self:_set_characters_weapon_preset("insane")

	self.escort.HEALTH_INIT = 140
	self.flashbang_multiplier = 1.75
	self.presets.weapon.sniper.ger_kar98_npc.FALLOFF = {
		{
			dmg_mul = 6,
			r = 700,
			acc = {
				0.4,
				0.95
			},
			recoil = {
				2,
				4
			},
			mode = {
				1,
				0,
				0,
				0
			}
		},
		{
			dmg_mul = 6,
			r = 3500,
			acc = {
				0.5,
				0.75
			},
			recoil = {
				3,
				4
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
			r = 10000,
			acc = {
				0,
				0.25
			},
			recoil = {
				3,
				5
			},
			mode = {
				1,
				0,
				0,
				0
			}
		}
	}
	self.german_flamer.HEALTH_INIT = 5400
	self.german_flamer.headshot_dmg_mul = 0.25
end

function CharacterTweakData:_multiply_weapon_delay(weap_usage_table, mul)
	for _, weap_id in ipairs(self.weap_ids) do
		local usage_data = weap_usage_table[weap_id]

		if usage_data then
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
	return

	for _, name in ipairs(self._enemies_list) do
		self[name].weapon = self.presets.weapon[preset]
	end
end

function CharacterTweakData:character_map()
	local char_map = {
		raidww2 = {
			path = "units/vanilla/characters/enemies/models/",
			list = {
				"german_sommilier",
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
				"german_sniper",
				"soviet_nkvd_int_security_captain"
			}
		}
	}

	if TweakData._init_wip_character_map then
		TweakData._init_wip_character_map(char_map)
	end

	return char_map
end

function CharacterTweakData:get_special_enemies()
	local special_enemies = {}

	return special_enemies
end
