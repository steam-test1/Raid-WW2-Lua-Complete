AttentionTweakData = AttentionTweakData or class()

function AttentionTweakData:init()
	self.settings = {}
	self.indexes = {}

	self:_init_player()
	self:_init_team_AI()
	self:_init_civilian()
	self:_init_enemy()
	self:_init_drill()
	self:_init_sentry_gun()
	self:_init_prop()
	self:_init_custom()
	self:_init_distraction_rock()
	self:_post_init()
end

function AttentionTweakData:_init_player()
	self.settings.pl_civilian = {
		notice_requires_FOV = true,
		reaction = "REACT_IDLE",
		release_delay = 1,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 1,
		filter = "none"
	}
	self.settings.pl_mask_off_friend_combatant = {
		notice_requires_FOV = false,
		release_delay = 3,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 1000,
		filter = "combatant",
		reaction = "REACT_IDLE",
		relation = "friend",
		duration = {
			2,
			5
		},
		pause = {
			15,
			25
		}
	}
	self.settings.pl_mask_off_foe_combatant = {
		turn_around_range = 250,
		notice_requires_FOV = true,
		release_delay = 2,
		verification_interval = 0.02,
		uncover_range = 325,
		max_range = 1000,
		suspicion_duration = 5,
		filter = "combatant",
		notice_delay_mul = 0.35,
		reaction = "REACT_SUSPICIOUS",
		suspicion_range = 900,
		relation = "foe"
	}
	self.settings.pl_mask_on_friend_combatant_whisper_mode = {
		notice_requires_FOV = true,
		release_delay = 3,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 2000,
		filter = "combatant",
		reaction = "REACT_CHECK",
		relation = "friend",
		duration = {
			2,
			5
		},
		pause = {
			25,
			50
		}
	}
	self.settings.pl_mask_off_foe_non_combatant = {
		notice_requires_FOV = true,
		release_delay = 3,
		verification_interval = 2,
		notice_delay_mul = 0,
		max_range = 600,
		filter = "non_combatant",
		reaction = "REACT_IDLE",
		attract_chance = 0.5,
		notice_interval = 0.5,
		duration = {
			2,
			15
		},
		pause = {
			10,
			60
		}
	}
	self.settings.pl_mask_off_friend_non_combatant = {
		attract_chance = 0.5,
		notice_requires_FOV = true,
		release_delay = 3,
		verification_interval = 2,
		notice_delay_mul = 0,
		max_range = 600,
		filter = "non_combatant",
		reaction = "REACT_IDLE",
		relation = "friend",
		notice_interval = 0.5,
		duration = {
			2,
			15
		},
		pause = {
			10,
			60
		}
	}
	self.settings.pl_mask_on_friend_non_combatant_whisper_mode = self.settings.pl_mask_off_friend_non_combatant
	self.settings.pl_mask_on_foe_combatant_whisper_mode_stand = {
		reaction = "REACT_COMBAT",
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.0531,
		uncover_range = 280,
		notice_delay_mul = 1.1,
		filter = "combatant",
		notice_clbk = "clbk_attention_notice_sneak",
		relation = "foe"
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_stand = deep_clone(self.settings.pl_mask_on_foe_combatant_whisper_mode_stand)
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_stand.reaction = "REACT_COMBAT"
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_stand.filter = "non_combatant"
	self.settings.pl_mask_on_foe_combatant_whisper_mode_crouch = {
		reaction = "REACT_COMBAT",
		notice_requires_FOV = true,
		release_delay = 0.8,
		verification_interval = 0.1,
		uncover_range = 140,
		notice_delay_mul = 1,
		range_mul = 0.9,
		filter = "combatant",
		notice_clbk = "clbk_attention_notice_sneak",
		relation = "foe"
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_crouch = deep_clone(self.settings.pl_mask_on_foe_combatant_whisper_mode_crouch)
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_crouch.reaction = "REACT_COMBAT"
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_crouch.filter = "non_combatant"
	self.settings.pl_mask_on_foe_combatant_whisper_mode_run = {
		reaction = "REACT_COMBAT",
		notice_requires_FOV = true,
		release_delay = 1.3,
		verification_interval = 0.0525,
		uncover_range = 300,
		notice_delay_mul = 0.65,
		range_mul = 1.5,
		filter = "combatant",
		notice_clbk = "clbk_attention_notice_sneak",
		relation = "foe"
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_run = deep_clone(self.settings.pl_mask_on_foe_combatant_whisper_mode_run)
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_run.reaction = "REACT_COMBAT"
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_run.filter = "non_combatant"
	self.settings.pl_friend_combatant_cbt = {
		notice_requires_FOV = false,
		release_delay = 3,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 3000,
		filter = "combatant",
		reaction = "REACT_CHECK",
		relation = "friend",
		duration = {
			2,
			3
		},
		pause = {
			45,
			60
		}
	}
	self.settings.pl_friend_non_combatant_cbt = {
		notice_delay_mul = 1.5,
		reaction = "REACT_SCARED",
		release_delay = 1,
		verification_interval = 0.1,
		uncover_range = 300,
		notice_requires_FOV = true,
		relation = "friend",
		filter = "non_combatant"
	}
	self.settings.pl_foe_combatant_cbt_crouch = {
		notice_delay_mul = 2,
		reaction = "REACT_COMBAT",
		release_delay = 1,
		verification_interval = 0.1,
		uncover_range = 150,
		notice_requires_FOV = true,
		relation = "foe",
		filter = "combatant"
	}
	self.settings.pl_foe_combatant_cbt_stand = {
		reaction = "REACT_COMBAT",
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1,
		uncover_range = 300,
		filter = "combatant",
		notice_clbk = "clbk_attention_notice_sneak",
		relation = "foe",
		notice_interval = 0.1
	}
	self.settings.pl_foe_non_combatant_cbt_crouch = {
		notice_delay_mul = 2.5,
		reaction = "REACT_COMBAT",
		release_delay = 1,
		verification_interval = 0.1,
		uncover_range = 150,
		notice_clbk = "clbk_attention_notice_sneak",
		notice_requires_FOV = true,
		filter = "non_combatant"
	}
	self.settings.pl_foe_non_combatant_cbt_stand = deep_clone(self.settings.pl_foe_combatant_cbt_stand)
	self.settings.pl_foe_non_combatant_cbt_stand.filter = "non_combatant"
end

function AttentionTweakData:_init_team_AI()
	self.settings.team_team_idle = {
		notice_requires_FOV = false,
		release_delay = 2,
		verification_interval = 3,
		max_range = 1000,
		filter = "all",
		reaction = "REACT_IDLE",
		relation = "friend",
		duration = {
			1.5,
			4
		},
		pause = {
			25,
			40
		}
	}
	self.settings.team_enemy_idle = {
		notice_requires_FOV = false,
		release_delay = 1,
		verification_interval = 3,
		max_range = 550,
		filter = "combatant",
		reaction = "REACT_IDLE",
		relation = "foe",
		duration = {
			1.5,
			3
		},
		pause = {
			35,
			60
		}
	}
	self.settings.team_enemy_cbt = {
		weight_mul = 0.5,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 300,
		max_range = 20000,
		filter = "all",
		reaction = "REACT_COMBAT",
		relation = "foe",
		notice_interval = 1
	}
end

function AttentionTweakData:_init_civilian()
	self.settings.civ_all_peaceful = {
		reaction = "REACT_IDLE",
		release_delay = 2,
		verification_interval = 2,
		max_range = 2000,
		notice_requires_FOV = true,
		filter = "all",
		duration = {
			1.5,
			6
		},
		pause = {
			35,
			60
		}
	}
	self.settings.civ_enemy_cbt = {
		notice_delay_mul = 1,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 0.0556,
		uncover_range = 300,
		max_range = 8000,
		notice_clbk = "clbk_attention_notice_corpse",
		filter = "all",
		reaction = "REACT_SCARED",
		duration = {
			3,
			6
		}
	}
	self.settings.civ_murderer_cbt = {
		weight_mul = 0.75,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.25,
		uncover_range = 300,
		max_range = 20000,
		filter = "murderer",
		reaction = "REACT_SHOOT",
		relation = "foe",
		notice_interval = 1
	}
	self.settings.civ_enemy_corpse_sneak = {
		notice_delay_mul = 0.5,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 0.0573,
		uncover_range = 800,
		max_range = 2000,
		suspicion_range = 1600,
		filter = "all",
		reaction = "REACT_SCARED",
		notice_requires_cool = true,
		uncover_requires_FOV = true,
		attract_chance = 0.25
	}
	self.settings.civ_civ_cbt = {
		uncover_range = 300,
		reaction = "REACT_SCARED",
		release_delay = 6,
		verification_interval = 0.0546,
		notice_delay_mul = 0.0586,
		notice_requires_FOV = true,
		filter = "all",
		duration = {
			3,
			6
		}
	}
end

function AttentionTweakData:_init_enemy()
	self.settings.enemy_team_idle = {
		notice_requires_FOV = false,
		release_delay = 1,
		verification_interval = 1,
		max_range = 2000,
		filter = "combatant",
		reaction = "REACT_IDLE",
		relation = "foe",
		duration = {
			2,
			4
		},
		pause = {
			9,
			40
		}
	}
	self.settings.enemy_team_cbt = {
		notice_requires_FOV = false,
		release_delay = 2,
		verification_interval = 0.5,
		notice_delay_mul = 0,
		max_range = 20000,
		filter = "combatant",
		reaction = "REACT_COMBAT",
		relation = "foe",
		notice_interval = 0.2
	}
	self.settings.enemy_law_corpse_sneak = self.settings.civ_enemy_corpse_sneak
	self.settings.enemy_team_corpse_sneak = self.settings.civ_enemy_corpse_sneak
	self.settings.enemy_combatant_corpse_cbt = {
		notice_requires_cool = true,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.25,
		notice_delay_mul = 0.1,
		max_range = 800,
		filter = "combatant",
		reaction = "REACT_CHECK",
		duration = {
			2,
			3
		}
	}
	self.settings.enemy_enemy_cbt = {
		notice_delay_mul = 0.5,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.25,
		uncover_range = 300,
		max_range = 8000,
		filter = "combatant",
		reaction = "REACT_SCARED",
		relation = "friend"
	}
	self.settings.enemy_civ_cbt = {
		notice_delay_mul = 0.2,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 0.25,
		uncover_range = 300,
		max_range = 8000,
		filter = "non_combatant",
		reaction = "REACT_SCARED",
		duration = {
			1.5,
			3
		}
	}
end

function AttentionTweakData:_init_custom()
	self.settings.custom_void = {
		reaction = "REACT_IDLE",
		release_delay = 10,
		verification_interval = 10,
		max_range = 2000,
		filter = "none"
	}
	self.settings.custom_team_idle = {
		reaction = "REACT_IDLE",
		release_delay = 1,
		verification_interval = 3,
		max_range = 2000,
		notice_requires_FOV = false,
		filter = "criminal",
		duration = {
			2,
			4
		},
		pause = {
			9,
			40
		}
	}
	self.settings.custom_team_cbt = {
		notice_requires_FOV = false,
		reaction = "REACT_COMBAT",
		release_delay = 2,
		verification_interval = 1.5,
		max_range = 20000,
		filter = "criminal"
	}
	self.settings.custom_team_shoot_const = {
		notice_requires_FOV = false,
		reaction = "REACT_SHOOT",
		release_delay = 2,
		verification_interval = 1.5,
		max_range = 10000,
		filter = "criminal"
	}
	self.settings.custom_team_shoot_burst = {
		notice_requires_FOV = false,
		reaction = "REACT_SHOOT",
		release_delay = 2,
		verification_interval = 1.5,
		max_range = 10000,
		filter = "criminal",
		duration = {
			2,
			4
		}
	}
	self.settings.custom_team_aim_const = {
		notice_requires_FOV = false,
		reaction = "REACT_AIM",
		release_delay = 2,
		verification_interval = 1.5,
		max_range = 10000,
		filter = "criminal"
	}
	self.settings.custom_enemy_forest_survive_kruka = {
		notice_requires_FOV = false,
		reaction = "REACT_COMBAT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 20000,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_suburbia_shootout = {
		turn_around_range = 15000,
		reaction = "REACT_SHOOT",
		release_delay = 5,
		verification_interval = 2,
		notice_requires_FOV = true,
		max_range = 12000,
		weight_mul = 0.5,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_suburbia_shootout_cops = {
		turn_around_range = 15000,
		reaction = "REACT_SHOOT",
		release_delay = 5,
		verification_interval = 2,
		notice_requires_FOV = true,
		max_range = 2000,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_china_store_vase_shoot = {
		turn_around_range = 500,
		reaction = "REACT_COMBAT",
		release_delay = 3,
		verification_interval = 2,
		notice_requires_FOV = true,
		max_range = 1200,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_china_store_vase_melee = {
		pause = 10,
		reaction = "REACT_MELEE",
		release_delay = 10,
		verification_interval = 5,
		turn_around_range = 250,
		max_range = 500,
		notice_requires_FOV = true,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_china_store_vase_aim = {
		pause = 10,
		reaction = "REACT_COMBAT",
		release_delay = 10,
		verification_interval = 5,
		notice_requires_FOV = false,
		max_range = 500,
		filter = "all_enemy"
	}
	self.settings.custom_enemy_shoot_const = {
		notice_requires_FOV = true,
		reaction = "REACT_SHOOT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 10000,
		filter = "all_enemy"
	}
	self.settings.custom_gangster_shoot_const = {
		notice_requires_FOV = true,
		reaction = "REACT_SHOOT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 10000,
		filter = "gangster"
	}
	self.settings.custom_law_shoot_const = {
		notice_requires_FOV = false,
		reaction = "REACT_SHOOT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 100000,
		filter = "law_enforcer"
	}
	self.settings.custom_law_look_in_container = {
		notice_requires_FOV = false,
		reaction = "REACT_AIM",
		release_delay = 2,
		verification_interval = 1,
		max_range = 100000,
		filter = "law_enforcer"
	}
	self.settings.custom_law_shoot_const_escape_vehicle = {
		notice_requires_FOV = false,
		reaction = "REACT_COMBAT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 4500,
		filter = "law_enforcer"
	}
	self.settings.custom_law_shoot_const_container = {
		notice_requires_FOV = false,
		reaction = "REACT_SHOOT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 2000,
		filter = "law_enforcer"
	}
	self.settings.custom_gangsters_shoot_warehouse = {
		notice_requires_FOV = false,
		reaction = "REACT_COMBAT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 2000,
		filter = "gangster"
	}
	self.settings.custom_gangster_sniper_apartment_suspicous = {
		notice_requires_FOV = true,
		reaction = "REACT_SCARED",
		release_delay = 6,
		verification_interval = 1,
		uncover_range = 350,
		max_range = 850,
		notice_delay_mul = 0.1,
		filter = "law_enforcer"
	}
	self.settings.custom_gangster_docks_idle = {
		notice_requires_FOV = true,
		reaction = "REACT_CURIOUS",
		release_delay = 6,
		verification_interval = 1,
		max_range = 10000,
		filter = "gangster"
	}
	self.settings.custom_enemy_civ_scared = {
		notice_requires_FOV = true,
		reaction = "REACT_SCARED",
		release_delay = 2,
		verification_interval = 5,
		filter = "civilians_enemies",
		duration = {
			2,
			4
		}
	}
	self.settings.custom_boat_gangster = {
		notice_requires_FOV = false,
		reaction = "REACT_COMBAT",
		release_delay = 2,
		verification_interval = 1,
		max_range = 4000,
		filter = "gangster"
	}
	self.settings.custom_law_cbt = {
		notice_clbk = "clbk_attention_notice_sneak",
		reaction = "REACT_COMBAT",
		release_delay = 1,
		verification_interval = 1,
		uncover_range = 350,
		notice_requires_FOV = true,
		filter = "law_enforcer"
	}
	self.settings.custom_airport_window = {
		notice_delay_mul = 0.2,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 1.5,
		uncover_range = 100,
		max_range = 1500,
		filter = "all_enemy",
		reaction = "REACT_CURIOUS",
		duration = {
			3,
			6
		}
	}
	self.settings.custom_look_at = {
		notice_requires_FOV = false,
		reaction = "REACT_IDLE",
		release_delay = 3,
		verification_interval = 1,
		notice_delay_mul = 0.2,
		max_range = 15000,
		filter = "all_enemy"
	}
	self.settings.custom_look_at_FOV = {
		reaction = "REACT_CURIOUS",
		release_delay = 6,
		verification_interval = 1.5,
		notice_delay_mul = 0.2,
		max_range = 1500,
		notice_requires_FOV = true,
		filter = "all_enemy",
		duration = {
			3,
			6
		}
	}
	self.settings.custom_server_room = {
		notice_delay_mul = 0.2,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 1.5,
		uncover_range = 100,
		max_range = 350,
		filter = "all_enemy",
		reaction = "REACT_SCARED",
		duration = {
			3,
			6
		}
	}
	self.settings.custom_team_ai_shoot_target = {
		notice_delay_mul = 0.2,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 1.5,
		uncover_range = 100,
		max_range = 1500,
		filter = "criminal",
		reaction = "REACT_SHOOT",
		duration = {
			3,
			6
		}
	}
	self.settings.tank_shoot = {
		weight_mul = 100,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1.5,
		max_range = 2000,
		filter = "law_enforcer",
		reaction = "REACT_COMBAT",
		relation = "foe",
		notice_interval = 1
	}
	self.settings.custom_escort_cbt = {
		notice_requires_FOV = false,
		reaction = "REACT_COMBAT",
		release_delay = 2,
		verification_interval = 1.5,
		weight_mul = 100,
		max_range = 20000,
		relation = "foe",
		filter = "combatant"
	}
	self.settings.custom_enemy_shoot_at_delayed = {
		pause = 4,
		reaction = "REACT_COMBAT",
		release_delay = 2,
		verification_interval = 1.5,
		turn_around_range = 250,
		max_range = 1000,
		notice_requires_FOV = true,
		filter = "law_enforcer"
	}
end

function AttentionTweakData:_init_drill()
	self.settings.drill_civ_ene_ntl = {
		suspicion_range = 1100,
		reaction = "REACT_SCARED",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 2300,
		notice_requires_FOV = false,
		filter = "civilians_enemies"
	}
	self.settings.drill_silent_civ_ene_ntl = {
		suspicion_range = 1000,
		reaction = "REACT_SCARED",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 2200,
		notice_requires_FOV = true,
		filter = "civilians_enemies"
	}
end

function AttentionTweakData:_init_sentry_gun()
	self.settings.sentry_gun_enemy_cbt = {
		reaction = "REACT_COMBAT",
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 300,
		relation = "foe",
		filter = "combatant"
	}
	self.settings.sentry_gun_enemy_cbt_hacked = {
		reaction = "REACT_COMBAT",
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 300,
		weight_mul = 0.2,
		relation = "foe",
		filter = "combatant"
	}
end

function AttentionTweakData:_init_prop()
	self.settings.prop_carry_bag = {
		suspicion_range = 800,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 1500,
		suspicion_duration = 8,
		filter = "law_enforcer",
		reaction = "REACT_SCARED"
	}
	self.settings.prop_carry_bodybag = self.settings.enemy_law_corpse_sneak
	self.settings.prop_civ_ene_ntl = {
		notice_requires_FOV = true,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 150,
		filter = "civilians_enemies"
	}
	self.settings.prop_ene_ntl_edaycrate = {
		notice_requires_FOV = true,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 150,
		max_range = 700,
		filter = "all_enemy"
	}
	self.settings.prop_ene_ntl = {
		notice_requires_FOV = true,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 150,
		filter = "all_enemy"
	}
	self.settings.broken_cam_ene_ntl = {
		suspicion_range = 1000,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		notice_requires_FOV = true,
		filter = "law_enforcer"
	}
	self.settings.prop_law_scary = {
		notice_requires_FOV = true,
		reaction = "REACT_SCARED",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 300,
		filter = "law_enforcer"
	}
	self.settings.prop_state_civ_ene_ntl = {
		notice_requires_FOV = true,
		reaction = "REACT_CURIOUS",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		filter = "civilians_enemies"
	}
	self.settings.no_staff_ene_ntl = {
		suspicion_range = 1000,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		notice_requires_FOV = true,
		filter = "law_enforcer"
	}
	self.settings.timelock_ene_ntl = {
		suspicion_range = 1000,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		notice_requires_FOV = true,
		filter = "law_enforcer"
	}
	self.settings.open_security_gate_ene_ntl = {
		suspicion_range = 1000,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		notice_requires_FOV = true,
		filter = "law_enforcer"
	}
	self.settings.open_vault_ene_ntl = {
		suspicion_range = 500,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 600,
		notice_requires_FOV = true,
		filter = "law_enforcer"
	}
	self.settings.vehicle_enemy_cbt = {
		weight_mul = 0.4,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 1200,
		max_range = 20000,
		filter = "combatant",
		reaction = "REACT_COMBAT",
		relation = "foe",
		notice_interval = 1
	}
	self.settings.open_elevator_ene_ntl = {
		suspicion_range = 1200,
		reaction = "REACT_AIM",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 800,
		max_range = 1500,
		notice_requires_FOV = true,
		filter = "civilians_enemies"
	}
end

function AttentionTweakData:_init_distraction_rock()
	self.settings.distraction_ntl = {
		suspicion_range = 1100,
		reaction = "REACT_SCARED",
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 5300,
		notice_requires_FOV = false,
		filter = "all_enemy"
	}
end

function AttentionTweakData:get_attention_index(setting_name)
	for i_setting, test_setting_name in ipairs(self.indexes) do
		if setting_name == test_setting_name then
			return i_setting
		end
	end
end

function AttentionTweakData:get_attention_name(index)
	return self.indexes[index]
end

function AttentionTweakData:_post_init()
	for setting_name, setting in pairs(self.settings) do
		local i_insert = 1

		while self.indexes[i_insert] and self.indexes[i_insert] <= setting_name do
			i_insert = i_insert + 1
		end

		table.insert(self.indexes, i_insert, setting_name)
	end
end
