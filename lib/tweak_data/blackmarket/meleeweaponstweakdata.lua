function BlackMarketTweakData:_init_melee_weapons(tweak_data)
	self.melee_sounds = {
		generic = {
			hit_body = "melee_hit_body",
			hit_gen = "melee_hit_gen"
		},
		fist = {
			hit_body = "punch_gunstock_1p",
			hit_air = "knife_hit_air",
			equip = "fist_equip",
			hit_gen = "melee_hit_gen"
		},
		knife = {
			hit_body = "knife_hit_body",
			hit_air = "knife_hit_air",
			hit_gen = "knife_hit_gen",
			killing_blow = "knife_killing_blow",
			equip = "knife_equip"
		},
		machete = {
			hit_body = "machete_hit_body",
			hit_air = "knife_hit_air",
			hit_gen = "knife_hit_gen",
			killing_blow = "machete_killing_blow",
			equip = "knife_equip"
		}
	}
	local MELEE_SPEED_INSTANT = 0
	local MELEE_SPEED_NORMAL = 1
	local MELEE_HEADSHOT_MULTIPLIER = 1.5
	self.melee_weapons = {
		weapon = {
			repeat_expire_t = 0.6,
			free = true,
			type = "weapon",
			instant = true,
			name_id = "bm_melee_weapon",
			expire_t = 0.6,
			sounds = self.melee_sounds.generic,
			stats = {
				min_damage = 75,
				min_damage_effect = 1,
				range = 150,
				max_damage_effect = 1,
				weapon_type = "blunt",
				max_damage = 75,
				charge_time = MELEE_SPEED_INSTANT
			}
		},
		fists = {
			free = true,
			type = "fists",
			name_id = "bm_melee_fists",
			anim_global_param = "melee_fist",
			repeat_expire_t = 0.55,
			melee_charge_shaker = "player_melee_charge_fist",
			melee_damage_delay = 0.2,
			expire_t = 1,
			anim_attack_vars = {
				"var1",
				"var2",
				"var3",
				"var4"
			},
			sounds = self.melee_sounds.fist,
			stats = {
				weapon_type = "blunt",
				range = 150,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 2,
				max_damage = 92,
				min_damage = 50,
				min_damage_effect = 3,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			}
		},
		m3_knife = {
			melee_damage_delay = 0.223,
			desc_id = "bm_melee_m3_knife_desc",
			usage_anim = "c45",
			type = "knife",
			weapon_movement_penalty = 1,
			stance = "m3",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			decal_effect = "knife",
			unit = "units/vanilla/weapons/wpn_fps_mel_m3_knife/wpn_fps_mel_m3_knife",
			weapon_hold = "m3",
			hold = "melee",
			third_unit = "units/vanilla/weapons/wpn_third_mel_m3_knife/wpn_third_mel_m3_knife",
			repeat_expire_t = 0.6,
			melee_charge_shaker = "player_melee_charge",
			name_id = "bm_melee_m3_knife",
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = 10,
				distance_offset = -100,
				height_offset = -8,
				rotation_offset = -2,
				initial_rotation = {
					pitch = 20,
					yaw = 90,
					roll = 160
				}
			}
		},
		robbins_dudley_trench_push_dagger = {
			melee_damage_delay = 0.1,
			desc_id = "bm_melee_robbins_dudley_trench_push_dagger_desc",
			usage_anim = "c45",
			stance = "robbins_dudley_trench_push_dagger",
			weapon_movement_penalty = 1,
			type = "knife",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			decal_effect = "knife",
			unit = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/wpn_fps_mel_robbins_dudley_trench_push_dagger",
			weapon_hold = "robbins_dudley_trench_push_dagger",
			hold = "melee",
			third_unit = "units/vanilla/weapons/wpn_third_mel_robbins_dudley_trench_push_dagger/wpn_third_mel_robbins_dudley_trench_push_dagger",
			repeat_expire_t = 0.6,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/robbins_dudley_trench_push_dagger_hud",
			melee_charge_shaker = "player_melee_charge",
			name_id = "bm_melee_robbins_dudley_trench_push_dagger",
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = 12,
				distance_offset = -100,
				height_offset = -12,
				rotation_offset = 4,
				initial_rotation = {
					pitch = 0,
					yaw = -90,
					roll = 0
				}
			}
		},
		german_brass_knuckles = {
			melee_damage_delay = 0.1,
			desc_id = "bm_melee_german_brass_knuckles_desc",
			usage_anim = "c45",
			type = "knife",
			weapon_movement_penalty = 1,
			stance = "brass_knuckles",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			unit = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/wpn_fps_mel_german_brass_knuckles",
			weapon_hold = "brass_knuckles",
			hold = "melee",
			third_unit = "units/vanilla/weapons/wpn_third_mel_german_brass_knuckles/wpn_third_mel_german_brass_knuckles",
			repeat_expire_t = 0.6,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/german_brass_knuckles_hud",
			melee_charge_shaker = "player_melee_charge",
			name_id = "bm_melee_german_brass_knuckles",
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.fist,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = 14,
				distance_offset = -130,
				height_offset = -9,
				rotation_offset = 4,
				initial_rotation = {
					pitch = 0,
					yaw = -90,
					roll = 0
				}
			}
		},
		lockwood_brothers_push_dagger = {
			melee_damage_delay = 0.1,
			desc_id = "bm_melee_lockwood_brothers_push_dagger_desc",
			usage_anim = "c45",
			type = "knife",
			weapon_movement_penalty = 1,
			stance = "lockwood_brothers_push_dagger",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			unit = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/wpn_fps_mel_lockwood_brothers_push_dagger",
			weapon_hold = "lockwood_brothers_push_dagger",
			hold = "melee",
			third_unit = "units/vanilla/weapons/wpn_third_mel_lockwood_brothers_push_dagger/wpn_third_mel_lockwood_brothers_push_dagger",
			repeat_expire_t = 0.6,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/lockwood_brothers_push_dagger_hud",
			melee_charge_shaker = "player_melee_charge",
			name_id = "bm_melee_lockwood_brothers_push_dagger",
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				effect = "knife",
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = 13,
				distance_offset = -120,
				height_offset = -11,
				rotation_offset = 1,
				initial_rotation = {
					pitch = 0,
					yaw = -90,
					roll = 0
				}
			}
		},
		bc41_knuckle_knife = {
			melee_damage_delay = 0.1,
			desc_id = "bm_melee_bc41_knuckle_knife_desc",
			usage_anim = "c45",
			stance = "bc41_knuckle_knife",
			weapon_movement_penalty = 1,
			type = "knife",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			decal_effect = "knife",
			unit = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/wpn_fps_mel_bc41_knuckle_knife",
			weapon_hold = "bc41_knuckle_knife",
			hold = "melee",
			third_unit = "units/vanilla/weapons/wpn_third_mel_bc41_knuckle_knife/wpn_third_mel_bc41_knuckle_knife",
			repeat_expire_t = 0.6,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/bc41_knuckle_knife_hud",
			melee_charge_shaker = "player_melee_charge",
			name_id = "bm_melee_bc41_knuckle_knife",
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = 13,
				distance_offset = -120,
				height_offset = -9,
				rotation_offset = 2,
				initial_rotation = {
					pitch = 0,
					yaw = -90,
					roll = 0
				}
			}
		},
		km_dagger = {
			name_id = "bm_melee_km_dagger",
			melee_damage_delay = 0.1,
			usage_anim = "c45",
			desc_id = "bm_melee_km_dagger_desc",
			weapon_movement_penalty = 1,
			type = "knife",
			transition_duration = 0,
			stance = "km_dagger",
			unit = "units/vanilla/weapons/wpn_fps_km_dagger/wpn_fps_km_dagger",
			weapon_hold = "km_dagger",
			hold = "melee",
			third_unit = "units/vanilla/weapons/wpn_third_mel_km_dagger/wpn_third_mel_km_dagger",
			repeat_expire_t = 0.6,
			melee_charge_shaker = "player_melee_charge",
			exit_run_speed_multiplier = 1,
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = 9,
				distance_offset = -75,
				height_offset = -8,
				rotation_offset = -12,
				initial_rotation = {
					pitch = -165,
					yaw = -90,
					roll = 15
				}
			}
		},
		marching_mace = {
			melee_damage_delay = 0.1,
			desc_id = "bm_melee_marching_mace_desc",
			usage_anim = "c45",
			type = "knife",
			weapon_movement_penalty = 1,
			stance = "marching_mace",
			transition_duration = 0,
			decal_effect = "knife",
			exit_run_speed_multiplier = 1,
			unit = "units/vanilla/weapons/wpn_fps_mel_marching_mace/wpn_fps_mel_marching_mace",
			weapon_hold = "marching_mace",
			hold = "marching_mace",
			third_unit = "units/vanilla/weapons/wpn_third_mel_marching_mace/wpn_third_mel_marching_mace",
			repeat_expire_t = 0.6,
			melee_charge_shaker = "player_melee_charge",
			name_id = "bm_melee_marching_mace",
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = -6,
				distance_offset = 60,
				height_offset = -10,
				rotation_offset = -30,
				initial_rotation = {
					pitch = 30,
					yaw = -90,
					roll = 0
				}
			}
		},
		lc14b = {
			melee_damage_delay = 0.1,
			desc_id = "bm_melee_lc14b_desc",
			usage_anim = "c45",
			stance = "machete",
			weapon_movement_penalty = 1,
			type = "knife",
			dismember_chance = 0.5,
			transition_duration = 0,
			decal_effect = "knife",
			exit_run_speed_multiplier = 1,
			unit = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b",
			weapon_hold = "machete",
			hold = "machete",
			third_unit = "units/event_001_halloween/weapons/wpn_third_mel_lc14b/wpn_third_mel_lc14b",
			repeat_expire_t = 0.6,
			reward_image = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b_hud",
			melee_charge_shaker = "player_melee_charge",
			name_id = "bm_melee_lc14b",
			expire_t = 0.75,
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.machete,
			stats = {
				weapon_type = "sharp",
				range = 185,
				remove_weapon_movement_penalty = true,
				max_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				min_damage_effect = 1,
				concealment = 30,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_empty = 1.65,
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5
			},
			use_data = {
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				display_offset = 8,
				distance_offset = -80,
				height_offset = -4,
				rotation_offset = -10,
				initial_rotation = {
					pitch = 10,
					yaw = 100,
					roll = 160
				}
			}
		}
	}

	self:_add_desc_from_name_macro(self.melee_weapons)
end
