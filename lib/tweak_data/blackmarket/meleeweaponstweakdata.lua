function BlackMarketTweakData:_init_melee_weapons(tweak_data)
	self.melee_sounds = {
		generic = {
			hit_body = "melee_hit_body",
			hit_gen = "melee_hit_gen"
		},
		fist = {
			hit_body = "punch_gunstock_1p",
			hit_air = "knife_hit_air",
			hit_gen = "melee_hit_gen",
			equip = "fist_equip"
		},
		knife = {
			hit_gen = "knife_hit_gen",
			hit_body = "knife_hit_body",
			hit_air = "knife_hit_air",
			killing_blow = "knife_killing_blow",
			equip = "knife_equip"
		},
		machete = {
			hit_gen = "knife_hit_gen",
			hit_body = "machete_hit_body",
			hit_air = "knife_hit_air",
			killing_blow = "machete_killing_blow",
			equip = "knife_equip"
		}
	}
	local MELEE_SPEED_INSTANT = 0
	local MELEE_SPEED_NORMAL = 1
	local MELEE_HEADSHOT_MULTIPLIER = 1.5
	self.melee_weapons = {
		weapon = {
			stats = nil,
			sounds = nil,
			expire_t = 0.6,
			repeat_expire_t = 0.6,
			free = true,
			instant = true,
			animations = nil,
			name_id = "bm_melee_weapon",
			type = "weapon",
			sounds = self.melee_sounds.generic,
			stats = {
				min_damage_effect = 1,
				max_damage = 75,
				min_damage = 75,
				weapon_type = "blunt",
				range = 150,
				charge_time = nil,
				max_damage_effect = 1,
				charge_time = MELEE_SPEED_INSTANT
			}
		},
		fists = {
			melee_damage_delay = 0.2,
			expire_t = 1,
			free = true,
			stats = nil,
			sounds = nil,
			anim_attack_vars = nil,
			repeat_expire_t = 0.55,
			anim_global_param = "melee_fist",
			animations = nil,
			name_id = "bm_melee_fists",
			type = "fists",
			melee_charge_shaker = "player_melee_charge_fist",
			anim_attack_vars = {
				"var1",
				"var2",
				"var3",
				"var4"
			},
			sounds = self.melee_sounds.fist,
			stats = {
				min_damage_effect = 3,
				max_damage = 92,
				min_damage = 50,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "blunt",
				range = 150,
				charge_time = nil,
				max_damage_effect = 2,
				charge_time = MELEE_SPEED_NORMAL
			}
		},
		m3_knife = {
			melee_damage_delay = 0.223,
			third_unit = "units/vanilla/weapons/wpn_third_mel_m3_knife/wpn_third_mel_m3_knife",
			timers = nil,
			sounds = nil,
			animations = nil,
			desc_id = "bm_melee_m3_knife_desc",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			align_objects = nil,
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "m3",
			stats = nil,
			stance = "m3",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_m3_knife/wpn_fps_mel_m3_knife",
			name_id = "bm_melee_m3_knife",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = 10,
				height_offset = -8,
				distance_offset = -100,
				rotation_offset = -2,
				initial_rotation = {
					roll = 160,
					pitch = 20,
					yaw = 90
				}
			}
		},
		robbins_dudley_trench_push_dagger = {
			melee_damage_delay = 0.1,
			align_objects = nil,
			timers = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/wpn_fps_mel_robbins_dudley_trench_push_dagger",
			sounds = nil,
			animations = nil,
			third_unit = "units/vanilla/weapons/wpn_third_mel_robbins_dudley_trench_push_dagger/wpn_third_mel_robbins_dudley_trench_push_dagger",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/robbins_dudley_trench_push_dagger_hud",
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "robbins_dudley_trench_push_dagger",
			stats = nil,
			stance = "robbins_dudley_trench_push_dagger",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			desc_id = "bm_melee_robbins_dudley_trench_push_dagger_desc",
			name_id = "bm_melee_robbins_dudley_trench_push_dagger",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = 12,
				height_offset = -12,
				distance_offset = -100,
				rotation_offset = 4,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		german_brass_knuckles = {
			melee_damage_delay = 0.1,
			align_objects = nil,
			timers = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/wpn_fps_mel_german_brass_knuckles",
			sounds = nil,
			animations = nil,
			third_unit = "units/vanilla/weapons/wpn_third_mel_german_brass_knuckles/wpn_third_mel_german_brass_knuckles",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/german_brass_knuckles_hud",
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "brass_knuckles",
			stats = nil,
			stance = "brass_knuckles",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			desc_id = "bm_melee_german_brass_knuckles_desc",
			name_id = "bm_melee_german_brass_knuckles",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.fist,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = 14,
				height_offset = -9,
				distance_offset = -130,
				rotation_offset = 4,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		lockwood_brothers_push_dagger = {
			melee_damage_delay = 0.1,
			align_objects = nil,
			timers = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/wpn_fps_mel_lockwood_brothers_push_dagger",
			sounds = nil,
			animations = nil,
			third_unit = "units/vanilla/weapons/wpn_third_mel_lockwood_brothers_push_dagger/wpn_third_mel_lockwood_brothers_push_dagger",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/lockwood_brothers_push_dagger_hud",
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "lockwood_brothers_push_dagger",
			stats = nil,
			stance = "lockwood_brothers_push_dagger",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			desc_id = "bm_melee_lockwood_brothers_push_dagger_desc",
			name_id = "bm_melee_lockwood_brothers_push_dagger",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				effect = "knife",
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = 13,
				height_offset = -11,
				distance_offset = -120,
				rotation_offset = 1,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		bc41_knuckle_knife = {
			melee_damage_delay = 0.1,
			align_objects = nil,
			timers = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/wpn_fps_mel_bc41_knuckle_knife",
			sounds = nil,
			animations = nil,
			third_unit = "units/vanilla/weapons/wpn_third_mel_bc41_knuckle_knife/wpn_third_mel_bc41_knuckle_knife",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			reward_image = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/bc41_knuckle_knife_hud",
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "bc41_knuckle_knife",
			stats = nil,
			stance = "bc41_knuckle_knife",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			desc_id = "bm_melee_bc41_knuckle_knife_desc",
			name_id = "bm_melee_bc41_knuckle_knife",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = 13,
				height_offset = -9,
				distance_offset = -120,
				rotation_offset = 2,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		km_dagger = {
			melee_damage_delay = 0.1,
			third_unit = "units/vanilla/weapons/wpn_third_mel_km_dagger/wpn_third_mel_km_dagger",
			timers = nil,
			sounds = nil,
			dlc = nil,
			animations = nil,
			unit = "units/vanilla/weapons/wpn_fps_km_dagger/wpn_fps_km_dagger",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			align_objects = nil,
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "km_dagger",
			stats = nil,
			stance = "km_dagger",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			desc_id = "bm_melee_km_dagger_desc",
			name_id = "bm_melee_km_dagger",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = 9,
				height_offset = -8,
				distance_offset = -75,
				rotation_offset = -12,
				initial_rotation = {
					roll = 15,
					pitch = -165,
					yaw = -90
				}
			}
		},
		marching_mace = {
			melee_damage_delay = 0.1,
			third_unit = "units/vanilla/weapons/wpn_third_mel_marching_mace/wpn_third_mel_marching_mace",
			timers = nil,
			sounds = nil,
			dlc = nil,
			animations = nil,
			desc_id = "bm_melee_marching_mace_desc",
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			align_objects = nil,
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "marching_mace",
			weapon_hold = "marching_mace",
			stats = nil,
			stance = "marching_mace",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_marching_mace/wpn_fps_mel_marching_mace",
			name_id = "bm_melee_marching_mace",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = -6,
				height_offset = -10,
				distance_offset = 60,
				rotation_offset = -30,
				initial_rotation = {
					roll = 0,
					pitch = 30,
					yaw = -90
				}
			}
		},
		lc14b = {
			melee_damage_delay = 0.1,
			dismember_chance = 0.5,
			timers = nil,
			unit = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b",
			align_objects = nil,
			sounds = nil,
			animations = nil,
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			third_unit = "units/event_001_halloween/weapons/wpn_third_mel_lc14b/wpn_third_mel_lc14b",
			reward_image = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b_hud",
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "machete",
			weapon_hold = "machete",
			stats = nil,
			stance = "machete",
			expire_t = 0.75,
			repeat_expire_t = 0.6,
			gui = nil,
			desc_id = "bm_melee_lc14b_desc",
			name_id = "bm_melee_lc14b",
			type = "knife",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.machete,
			stats = {
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
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
				unequip = nil,
				selection_index = nil,
				equip = nil,
				selection_index = tweak_data.weapon.WEAPON_SLOT_MELEE,
				equip = {
					align_place = "right_hand"
				},
				unequip = {
					align_place = "back"
				}
			},
			gui = {
				initial_rotation = nil,
				display_offset = 8,
				height_offset = -4,
				distance_offset = -80,
				rotation_offset = -10,
				initial_rotation = {
					roll = 160,
					pitch = 10,
					yaw = 100
				}
			}
		}
	}

	self:_add_desc_from_name_macro(self.melee_weapons)
end
