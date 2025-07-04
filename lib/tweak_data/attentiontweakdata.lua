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
		release_delay = 1,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 1,
		notice_requires_FOV = true,
		filter = "none",
		reaction = "REACT_IDLE"
	}
	self.settings.pl_mask_off_friend_combatant = {
		relation = "friend",
		notice_requires_FOV = false,
		release_delay = 3,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 1000,
		filter = "combatant",
		reaction = "REACT_IDLE",
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
		max_range = 1000,
		suspicion_range = 900,
		notice_delay_mul = 0.35,
		relation = "foe",
		notice_requires_FOV = true,
		release_delay = 2,
		verification_interval = 0.02,
		uncover_range = 325,
		turn_around_range = 250,
		suspicion_duration = 5,
		filter = "combatant",
		reaction = "REACT_SUSPICIOUS"
	}
	self.settings.pl_mask_on_friend_combatant_whisper_mode = {
		relation = "friend",
		notice_requires_FOV = true,
		release_delay = 3,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 2000,
		filter = "combatant",
		reaction = "REACT_CHECK",
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
		attract_chance = 0.5,
		notice_interval = 0.5,
		notice_requires_FOV = true,
		release_delay = 3,
		verification_interval = 2,
		notice_delay_mul = 0,
		max_range = 600,
		filter = "non_combatant",
		reaction = "REACT_IDLE",
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
		relation = "friend",
		attract_chance = 0.5,
		notice_interval = 0.5,
		notice_requires_FOV = true,
		release_delay = 3,
		verification_interval = 2,
		notice_delay_mul = 0,
		max_range = 600,
		filter = "non_combatant",
		reaction = "REACT_IDLE",
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
		notice_clbk = "clbk_attention_notice_sneak",
		uncover_range = 280,
		relation = "foe",
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.0531,
		notice_delay_mul = 1.1,
		filter = "combatant",
		reaction = "REACT_COMBAT"
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_stand = deep_clone(self.settings.pl_mask_on_foe_combatant_whisper_mode_stand)
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_stand.reaction = "REACT_COMBAT"
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_stand.filter = "non_combatant"
	self.settings.pl_mask_on_foe_combatant_whisper_mode_crouch = {
		notice_clbk = "clbk_attention_notice_sneak",
		uncover_range = 140,
		range_mul = 0.9,
		relation = "foe",
		notice_requires_FOV = true,
		release_delay = 0.8,
		verification_interval = 0.1,
		notice_delay_mul = 1,
		filter = "combatant",
		reaction = "REACT_COMBAT"
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_crouch = deep_clone(self.settings.pl_mask_on_foe_combatant_whisper_mode_crouch)
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_crouch.reaction = "REACT_COMBAT"
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_crouch.filter = "non_combatant"
	self.settings.pl_mask_on_foe_combatant_whisper_mode_run = {
		notice_clbk = "clbk_attention_notice_sneak",
		uncover_range = 300,
		range_mul = 1.5,
		relation = "foe",
		notice_requires_FOV = true,
		release_delay = 1.3,
		verification_interval = 0.0525,
		notice_delay_mul = 0.65,
		filter = "combatant",
		reaction = "REACT_COMBAT"
	}
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_run = deep_clone(self.settings.pl_mask_on_foe_combatant_whisper_mode_run)
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_run.reaction = "REACT_COMBAT"
	self.settings.pl_mask_on_foe_non_combatant_whisper_mode_run.filter = "non_combatant"
	self.settings.pl_friend_combatant_cbt = {
		relation = "friend",
		notice_requires_FOV = false,
		release_delay = 3,
		verification_interval = 4,
		notice_delay_mul = 1,
		max_range = 3000,
		filter = "combatant",
		reaction = "REACT_CHECK",
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
		release_delay = 1,
		verification_interval = 0.1,
		uncover_range = 300,
		notice_delay_mul = 1.5,
		relation = "friend",
		filter = "non_combatant",
		notice_requires_FOV = true,
		reaction = "REACT_SCARED"
	}
	self.settings.pl_foe_combatant_cbt_crouch = {
		release_delay = 1,
		verification_interval = 0.1,
		uncover_range = 150,
		notice_delay_mul = 2,
		relation = "foe",
		filter = "combatant",
		notice_requires_FOV = true,
		reaction = "REACT_COMBAT"
	}
	self.settings.pl_foe_combatant_cbt_stand = {
		notice_clbk = "clbk_attention_notice_sneak",
		relation = "foe",
		notice_interval = 0.1,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1,
		uncover_range = 300,
		filter = "combatant",
		reaction = "REACT_COMBAT"
	}
	self.settings.pl_foe_non_combatant_cbt_crouch = {
		release_delay = 1,
		verification_interval = 0.1,
		uncover_range = 150,
		notice_delay_mul = 2.5,
		notice_clbk = "clbk_attention_notice_sneak",
		filter = "non_combatant",
		notice_requires_FOV = true,
		reaction = "REACT_COMBAT"
	}
	self.settings.pl_foe_non_combatant_cbt_stand = deep_clone(self.settings.pl_foe_combatant_cbt_stand)
	self.settings.pl_foe_non_combatant_cbt_stand.filter = "non_combatant"
end

function AttentionTweakData:_init_team_AI()
	self.settings.team_team_idle = {
		relation = "friend",
		notice_requires_FOV = false,
		release_delay = 2,
		verification_interval = 3,
		max_range = 1000,
		filter = "all",
		reaction = "REACT_IDLE",
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
		relation = "foe",
		notice_requires_FOV = false,
		release_delay = 1,
		verification_interval = 3,
		max_range = 550,
		filter = "combatant",
		reaction = "REACT_IDLE",
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
		relation = "foe",
		notice_interval = 1,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 300,
		max_range = 20000,
		filter = "all",
		reaction = "REACT_COMBAT"
	}
end

function AttentionTweakData:_init_civilian()
	self.settings.civ_all_peaceful = {
		release_delay = 2,
		verification_interval = 2,
		max_range = 2000,
		filter = "all",
		notice_requires_FOV = true,
		reaction = "REACT_IDLE",
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
		uncover_range = 300,
		notice_clbk = "clbk_attention_notice_corpse",
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 0.0556,
		notice_delay_mul = 1,
		max_range = 8000,
		filter = "all",
		reaction = "REACT_SCARED",
		duration = {
			3,
			6
		}
	}
	self.settings.civ_murderer_cbt = {
		weight_mul = 0.75,
		relation = "foe",
		notice_interval = 1,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.25,
		uncover_range = 300,
		max_range = 20000,
		filter = "murderer",
		reaction = "REACT_SHOOT"
	}
	self.settings.civ_enemy_corpse_sneak = {
		uncover_range = 800,
		filter = "all",
		notice_requires_cool = true,
		uncover_requires_FOV = true,
		attract_chance = 0.25,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 0.0573,
		notice_delay_mul = 0.5,
		max_range = 2000,
		suspicion_range = 1600,
		reaction = "REACT_SCARED"
	}
	self.settings.civ_civ_cbt = {
		release_delay = 6,
		verification_interval = 0.0546,
		uncover_range = 300,
		notice_delay_mul = 0.0586,
		filter = "all",
		notice_requires_FOV = true,
		reaction = "REACT_SCARED",
		duration = {
			3,
			6
		}
	}
end

function AttentionTweakData:_init_enemy()
	self.settings.enemy_team_idle = {
		relation = "foe",
		notice_requires_FOV = false,
		release_delay = 1,
		verification_interval = 1,
		max_range = 2000,
		filter = "combatant",
		reaction = "REACT_IDLE",
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
		relation = "foe",
		notice_interval = 0.2,
		notice_requires_FOV = false,
		release_delay = 2,
		verification_interval = 0.5,
		notice_delay_mul = 0,
		max_range = 20000,
		filter = "combatant",
		reaction = "REACT_COMBAT"
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
		uncover_range = 300,
		relation = "friend",
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.25,
		notice_delay_mul = 0.5,
		max_range = 8000,
		filter = "combatant",
		reaction = "REACT_SCARED"
	}
	self.settings.enemy_civ_cbt = {
		uncover_range = 300,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 0.25,
		notice_delay_mul = 0.2,
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
		release_delay = 10,
		verification_interval = 10,
		max_range = 2000,
		filter = "none",
		reaction = "REACT_IDLE"
	}
	self.settings.custom_team_idle = {
		release_delay = 1,
		verification_interval = 3,
		max_range = 2000,
		filter = "criminal",
		notice_requires_FOV = false,
		reaction = "REACT_IDLE",
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
		release_delay = 2,
		verification_interval = 1.5,
		notice_requires_FOV = false,
		max_range = 20000,
		filter = "criminal",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_team_shoot_const = {
		release_delay = 2,
		verification_interval = 1.5,
		notice_requires_FOV = false,
		max_range = 10000,
		filter = "criminal",
		reaction = "REACT_SHOOT"
	}
	self.settings.custom_team_shoot_burst = {
		release_delay = 2,
		verification_interval = 1.5,
		max_range = 10000,
		notice_requires_FOV = false,
		filter = "criminal",
		reaction = "REACT_SHOOT",
		duration = {
			2,
			4
		}
	}
	self.settings.custom_team_aim_const = {
		release_delay = 2,
		verification_interval = 1.5,
		notice_requires_FOV = false,
		max_range = 10000,
		filter = "criminal",
		reaction = "REACT_AIM"
	}
	self.settings.custom_enemy_forest_survive_kruka = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = false,
		max_range = 20000,
		filter = "all_enemy",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_enemy_suburbia_shootout = {
		release_delay = 5,
		verification_interval = 2,
		turn_around_range = 15000,
		max_range = 12000,
		notice_requires_FOV = true,
		filter = "all_enemy",
		weight_mul = 0.5,
		reaction = "REACT_SHOOT"
	}
	self.settings.custom_enemy_suburbia_shootout_cops = {
		release_delay = 5,
		verification_interval = 2,
		turn_around_range = 15000,
		max_range = 2000,
		notice_requires_FOV = true,
		filter = "all_enemy",
		reaction = "REACT_SHOOT"
	}
	self.settings.custom_enemy_china_store_vase_shoot = {
		release_delay = 3,
		verification_interval = 2,
		turn_around_range = 500,
		max_range = 1200,
		notice_requires_FOV = true,
		filter = "all_enemy",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_enemy_china_store_vase_melee = {
		release_delay = 10,
		verification_interval = 5,
		pause = 10,
		max_range = 500,
		turn_around_range = 250,
		filter = "all_enemy",
		notice_requires_FOV = true,
		reaction = "REACT_MELEE"
	}
	self.settings.custom_enemy_china_store_vase_aim = {
		release_delay = 10,
		verification_interval = 5,
		pause = 10,
		max_range = 500,
		notice_requires_FOV = false,
		filter = "all_enemy",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_enemy_shoot_const = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = true,
		max_range = 10000,
		filter = "all_enemy",
		reaction = "REACT_SHOOT"
	}
	self.settings.custom_gangster_shoot_const = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = true,
		max_range = 10000,
		filter = "gangster",
		reaction = "REACT_SHOOT"
	}
	self.settings.custom_law_shoot_const = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = false,
		max_range = 100000,
		filter = "law_enforcer",
		reaction = "REACT_SHOOT"
	}
	self.settings.custom_law_look_in_container = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = false,
		max_range = 100000,
		filter = "law_enforcer",
		reaction = "REACT_AIM"
	}
	self.settings.custom_law_shoot_const_escape_vehicle = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = false,
		max_range = 4500,
		filter = "law_enforcer",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_law_shoot_const_container = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = false,
		max_range = 2000,
		filter = "law_enforcer",
		reaction = "REACT_SHOOT"
	}
	self.settings.custom_gangsters_shoot_warehouse = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = false,
		max_range = 2000,
		filter = "gangster",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_gangster_sniper_apartment_suspicous = {
		release_delay = 6,
		verification_interval = 1,
		uncover_range = 350,
		max_range = 850,
		notice_requires_FOV = true,
		filter = "law_enforcer",
		notice_delay_mul = 0.1,
		reaction = "REACT_SCARED"
	}
	self.settings.custom_gangster_docks_idle = {
		release_delay = 6,
		verification_interval = 1,
		notice_requires_FOV = true,
		max_range = 10000,
		filter = "gangster",
		reaction = "REACT_CURIOUS"
	}
	self.settings.custom_enemy_civ_scared = {
		release_delay = 2,
		verification_interval = 5,
		notice_requires_FOV = true,
		filter = "civilians_enemies",
		reaction = "REACT_SCARED",
		duration = {
			2,
			4
		}
	}
	self.settings.custom_boat_gangster = {
		release_delay = 2,
		verification_interval = 1,
		notice_requires_FOV = false,
		max_range = 4000,
		filter = "gangster",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_law_cbt = {
		release_delay = 1,
		verification_interval = 1,
		uncover_range = 350,
		notice_clbk = "clbk_attention_notice_sneak",
		notice_requires_FOV = true,
		filter = "law_enforcer",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_airport_window = {
		uncover_range = 100,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 1.5,
		notice_delay_mul = 0.2,
		max_range = 1500,
		filter = "all_enemy",
		reaction = "REACT_CURIOUS",
		duration = {
			3,
			6
		}
	}
	self.settings.custom_look_at = {
		release_delay = 3,
		verification_interval = 1,
		notice_delay_mul = 0.2,
		max_range = 15000,
		notice_requires_FOV = false,
		filter = "all_enemy",
		reaction = "REACT_IDLE"
	}
	self.settings.custom_look_at_FOV = {
		release_delay = 6,
		verification_interval = 1.5,
		notice_delay_mul = 0.2,
		max_range = 1500,
		filter = "all_enemy",
		notice_requires_FOV = true,
		reaction = "REACT_CURIOUS",
		duration = {
			3,
			6
		}
	}
	self.settings.custom_server_room = {
		uncover_range = 100,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 1.5,
		notice_delay_mul = 0.2,
		max_range = 350,
		filter = "all_enemy",
		reaction = "REACT_SCARED",
		duration = {
			3,
			6
		}
	}
	self.settings.custom_team_ai_shoot_target = {
		uncover_range = 100,
		notice_requires_FOV = true,
		release_delay = 6,
		verification_interval = 1.5,
		notice_delay_mul = 0.2,
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
		relation = "foe",
		notice_interval = 1,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1.5,
		max_range = 2000,
		filter = "law_enforcer",
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_escort_cbt = {
		release_delay = 2,
		verification_interval = 1.5,
		notice_requires_FOV = false,
		max_range = 20000,
		relation = "foe",
		filter = "combatant",
		weight_mul = 100,
		reaction = "REACT_COMBAT"
	}
	self.settings.custom_enemy_shoot_at_delayed = {
		release_delay = 2,
		verification_interval = 1.5,
		pause = 4,
		max_range = 1000,
		turn_around_range = 250,
		filter = "law_enforcer",
		notice_requires_FOV = true,
		reaction = "REACT_COMBAT"
	}
end

function AttentionTweakData:_init_drill()
	self.settings.drill_civ_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 2300,
		filter = "civilians_enemies",
		suspicion_range = 1100,
		notice_requires_FOV = false,
		reaction = "REACT_SCARED"
	}
	self.settings.drill_silent_civ_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 2200,
		filter = "civilians_enemies",
		suspicion_range = 1000,
		notice_requires_FOV = true,
		reaction = "REACT_SCARED"
	}
end

function AttentionTweakData:_init_sentry_gun()
	self.settings.sentry_gun_enemy_cbt = {
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 300,
		relation = "foe",
		filter = "combatant",
		reaction = "REACT_COMBAT"
	}
	self.settings.sentry_gun_enemy_cbt_hacked = {
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 300,
		weight_mul = 0.2,
		relation = "foe",
		filter = "combatant",
		reaction = "REACT_COMBAT"
	}
end

function AttentionTweakData:_init_prop()
	self.settings.prop_carry_bag = {
		filter = "law_enforcer",
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 1500,
		suspicion_duration = 8,
		suspicion_range = 800,
		reaction = "REACT_SCARED"
	}
	self.settings.prop_carry_bodybag = self.settings.enemy_law_corpse_sneak
	self.settings.prop_civ_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 150,
		notice_requires_FOV = true,
		filter = "civilians_enemies",
		reaction = "REACT_AIM"
	}
	self.settings.prop_ene_ntl_edaycrate = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 150,
		max_range = 700,
		notice_requires_FOV = true,
		filter = "all_enemy",
		reaction = "REACT_AIM"
	}
	self.settings.prop_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 150,
		notice_requires_FOV = true,
		filter = "all_enemy",
		reaction = "REACT_AIM"
	}
	self.settings.broken_cam_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		suspicion_range = 1000,
		filter = "law_enforcer",
		notice_requires_FOV = true,
		reaction = "REACT_AIM"
	}
	self.settings.prop_law_scary = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 300,
		notice_requires_FOV = true,
		filter = "law_enforcer",
		reaction = "REACT_SCARED"
	}
	self.settings.prop_state_civ_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		notice_requires_FOV = true,
		filter = "civilians_enemies",
		reaction = "REACT_CURIOUS"
	}
	self.settings.no_staff_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		suspicion_range = 1000,
		filter = "law_enforcer",
		notice_requires_FOV = true,
		reaction = "REACT_AIM"
	}
	self.settings.timelock_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		suspicion_range = 1000,
		filter = "law_enforcer",
		notice_requires_FOV = true,
		reaction = "REACT_AIM"
	}
	self.settings.open_security_gate_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 1200,
		suspicion_range = 1000,
		filter = "law_enforcer",
		notice_requires_FOV = true,
		reaction = "REACT_AIM"
	}
	self.settings.open_vault_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 100,
		max_range = 600,
		suspicion_range = 500,
		filter = "law_enforcer",
		notice_requires_FOV = true,
		reaction = "REACT_AIM"
	}
	self.settings.vehicle_enemy_cbt = {
		weight_mul = 0.4,
		relation = "foe",
		notice_interval = 1,
		notice_requires_FOV = true,
		release_delay = 1,
		verification_interval = 1.5,
		uncover_range = 1200,
		max_range = 20000,
		filter = "combatant",
		reaction = "REACT_COMBAT"
	}
	self.settings.open_elevator_ene_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 800,
		max_range = 1500,
		suspicion_range = 1200,
		filter = "civilians_enemies",
		notice_requires_FOV = true,
		reaction = "REACT_AIM"
	}
end

function AttentionTweakData:_init_distraction_rock()
	self.settings.distraction_ntl = {
		release_delay = 1,
		verification_interval = 0.4,
		uncover_range = 200,
		max_range = 5300,
		filter = "all_enemy",
		suspicion_range = 1100,
		notice_requires_FOV = false,
		reaction = "REACT_SCARED"
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
