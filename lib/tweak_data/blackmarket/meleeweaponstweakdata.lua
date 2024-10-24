function BlackMarketTweakData:_init_melee_weapons(tweak_data)
	self.melee_sounds = {
		generic = {
			hit_gen = "melee_hit_gen",
			hit_body = "melee_hit_body"
		},
		fist = {
			hit_air = "knife_hit_air",
			hit_gen = "melee_hit_gen",
			equip = "fist_equip",
			hit_body = "punch_gunstock_1p"
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
			animations = nil,
			name_id = "bm_melee_weapon",
			type = "weapon",
			stats = nil,
			sounds = nil,
			expire_t = 0.6,
			repeat_expire_t = 0.6,
			free = true,
			instant = true,
			sounds = self.melee_sounds.generic,
			stats = {
				max_damage = 75,
				min_damage = 75,
				weapon_type = "blunt",
				range = 150,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				charge_time = MELEE_SPEED_INSTANT
			}
		},
		fists = {
			expire_t = 1,
			animations = nil,
			name_id = "bm_melee_fists",
			type = "fists",
			free = true,
			melee_charge_shaker = "player_melee_charge_fist",
			melee_damage_delay = 0.2,
			stats = nil,
			sounds = nil,
			anim_attack_vars = nil,
			repeat_expire_t = 0.55,
			anim_global_param = "melee_fist",
			anim_attack_vars = {
				"var1",
				"var2",
				"var3",
				"var4"
			},
			sounds = self.melee_sounds.fist,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "blunt",
				range = 150,
				charge_time = nil,
				max_damage_effect = 2,
				min_damage_effect = 3,
				max_damage = 92,
				min_damage = 50,
				charge_time = MELEE_SPEED_NORMAL
			}
		},
		m3_knife = {
			unit = "units/vanilla/weapons/wpn_fps_mel_m3_knife/wpn_fps_mel_m3_knife",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_m3_knife",
			type = "knife",
			desc_id = "bm_melee_m3_knife_desc",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.223,
			animations = nil,
			timers = nil,
			sounds = nil,
			gui = nil,
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
			third_unit = "units/vanilla/weapons/wpn_third_mel_m3_knife/wpn_third_mel_m3_knife",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = -2,
				initial_rotation = nil,
				display_offset = 10,
				height_offset = -8,
				distance_offset = -100,
				initial_rotation = {
					roll = 160,
					pitch = 20,
					yaw = 90
				}
			}
		},
		robbins_dudley_trench_push_dagger = {
			desc_id = "bm_melee_robbins_dudley_trench_push_dagger_desc",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_robbins_dudley_trench_push_dagger",
			type = "knife",
			reward_image = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/robbins_dudley_trench_push_dagger_hud",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.1,
			sounds = nil,
			timers = nil,
			animations = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/wpn_fps_mel_robbins_dudley_trench_push_dagger",
			gui = nil,
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			align_objects = nil,
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "robbins_dudley_trench_push_dagger",
			stats = nil,
			stance = "robbins_dudley_trench_push_dagger",
			expire_t = 0.75,
			third_unit = "units/vanilla/weapons/wpn_third_mel_robbins_dudley_trench_push_dagger/wpn_third_mel_robbins_dudley_trench_push_dagger",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = 4,
				initial_rotation = nil,
				display_offset = 12,
				height_offset = -12,
				distance_offset = -100,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		german_brass_knuckles = {
			desc_id = "bm_melee_german_brass_knuckles_desc",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_german_brass_knuckles",
			type = "knife",
			reward_image = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/german_brass_knuckles_hud",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.1,
			sounds = nil,
			timers = nil,
			animations = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/wpn_fps_mel_german_brass_knuckles",
			gui = nil,
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			align_objects = nil,
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "brass_knuckles",
			stats = nil,
			stance = "brass_knuckles",
			expire_t = 0.75,
			third_unit = "units/vanilla/weapons/wpn_third_mel_german_brass_knuckles/wpn_third_mel_german_brass_knuckles",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.fist,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = 4,
				initial_rotation = nil,
				display_offset = 14,
				height_offset = -9,
				distance_offset = -130,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		lockwood_brothers_push_dagger = {
			desc_id = "bm_melee_lockwood_brothers_push_dagger_desc",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_lockwood_brothers_push_dagger",
			type = "knife",
			reward_image = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/lockwood_brothers_push_dagger_hud",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.1,
			sounds = nil,
			timers = nil,
			animations = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/wpn_fps_mel_lockwood_brothers_push_dagger",
			gui = nil,
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			align_objects = nil,
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "lockwood_brothers_push_dagger",
			stats = nil,
			stance = "lockwood_brothers_push_dagger",
			expire_t = 0.75,
			third_unit = "units/vanilla/weapons/wpn_third_mel_lockwood_brothers_push_dagger/wpn_third_mel_lockwood_brothers_push_dagger",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				effect = "knife",
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = 1,
				initial_rotation = nil,
				display_offset = 13,
				height_offset = -11,
				distance_offset = -120,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		bc41_knuckle_knife = {
			desc_id = "bm_melee_bc41_knuckle_knife_desc",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_bc41_knuckle_knife",
			type = "knife",
			reward_image = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/bc41_knuckle_knife_hud",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.1,
			sounds = nil,
			timers = nil,
			animations = nil,
			unit = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/wpn_fps_mel_bc41_knuckle_knife",
			gui = nil,
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			align_objects = nil,
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "melee",
			weapon_hold = "bc41_knuckle_knife",
			stats = nil,
			stance = "bc41_knuckle_knife",
			expire_t = 0.75,
			third_unit = "units/vanilla/weapons/wpn_third_mel_bc41_knuckle_knife/wpn_third_mel_bc41_knuckle_knife",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = 2,
				initial_rotation = nil,
				display_offset = 13,
				height_offset = -9,
				distance_offset = -120,
				initial_rotation = {
					roll = 0,
					pitch = 0,
					yaw = -90
				}
			}
		},
		km_dagger = {
			unit = "units/vanilla/weapons/wpn_fps_km_dagger/wpn_fps_km_dagger",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_km_dagger",
			type = "knife",
			desc_id = "bm_melee_km_dagger_desc",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.1,
			dlc = nil,
			timers = nil,
			animations = nil,
			sounds = nil,
			gui = nil,
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
			third_unit = "units/vanilla/weapons/wpn_third_mel_km_dagger/wpn_third_mel_km_dagger",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = -12,
				initial_rotation = nil,
				display_offset = 9,
				height_offset = -8,
				distance_offset = -75,
				initial_rotation = {
					roll = 15,
					pitch = -165,
					yaw = -90
				}
			}
		},
		marching_mace = {
			unit = "units/vanilla/weapons/wpn_fps_mel_marching_mace/wpn_fps_mel_marching_mace",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_marching_mace",
			type = "knife",
			desc_id = "bm_melee_marching_mace_desc",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.1,
			dlc = nil,
			timers = nil,
			animations = nil,
			sounds = nil,
			gui = nil,
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
			third_unit = "units/vanilla/weapons/wpn_third_mel_marching_mace/wpn_third_mel_marching_mace",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.knife,
			dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = -30,
				initial_rotation = nil,
				display_offset = -6,
				height_offset = -10,
				distance_offset = 60,
				initial_rotation = {
					roll = 0,
					pitch = 30,
					yaw = -90
				}
			}
		},
		lc14b = {
			desc_id = "bm_melee_lc14b_desc",
			repeat_expire_t = 0.6,
			name_id = "bm_melee_lc14b",
			type = "knife",
			reward_image = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b_hud",
			use_data = nil,
			melee_charge_shaker = "player_melee_charge",
			melee_damage_delay = 0.1,
			sounds = nil,
			timers = nil,
			animations = nil,
			unit = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b",
			gui = nil,
			transition_duration = 0,
			exit_run_speed_multiplier = 1,
			headshot_multiplier = nil,
			weapon_movement_penalty = 1,
			dismember_chance = 0.5,
			align_objects = nil,
			decal_effect = "knife",
			usage_anim = "c45",
			hold = "machete",
			weapon_hold = "machete",
			stats = nil,
			stance = "machete",
			expire_t = 0.75,
			third_unit = "units/event_001_halloween/weapons/wpn_third_mel_lc14b/wpn_third_mel_lc14b",
			align_objects = {
				"a_weapon_right"
			},
			headshot_multiplier = MELEE_HEADSHOT_MULTIPLIER,
			sounds = self.melee_sounds.machete,
			stats = {
				remove_weapon_movement_penalty = true,
				concealment = 30,
				weapon_type = "sharp",
				range = 185,
				charge_time = nil,
				max_damage_effect = 1,
				min_damage_effect = 1,
				max_damage = 150,
				min_damage = 80,
				charge_time = MELEE_SPEED_NORMAL
			},
			animations = {
				equip_id = "equip_welrod"
			},
			timers = {
				reload_not_empty = 1.25,
				equip = 0.25,
				unequip = 0.5,
				reload_empty = 1.65
			},
			use_data = {
				selection_index = nil,
				unequip = nil,
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
				rotation_offset = -10,
				initial_rotation = nil,
				display_offset = 8,
				height_offset = -4,
				distance_offset = -80,
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
