function BlackMarketTweakData:_init_melee_weapons()
	local MELEE_SLOT = 4
	local MELEE_SPEED_INSTANT = 0
	local MELEE_SPEED_NORMAL = 1
	self.melee_weapons = {
		weapon = {}
	}
	self.melee_weapons.weapon.name_id = "bm_melee_weapon"
	self.melee_weapons.weapon.type = "weapon"
	self.melee_weapons.weapon.unit = nil
	self.melee_weapons.weapon.animation = nil
	self.melee_weapons.weapon.instant = true
	self.melee_weapons.weapon.free = true
	self.melee_weapons.weapon.stats = {
		min_damage = 75,
		max_damage = 75,
		min_damage_effect = 1,
		max_damage_effect = 1,
		charge_time = MELEE_SPEED_INSTANT,
		range = 150,
		weapon_type = "blunt"
	}
	self.melee_weapons.weapon.expire_t = 0.6
	self.melee_weapons.weapon.repeat_expire_t = 0.6
	self.melee_weapons.weapon.sounds = {
		hit_body = "melee_hit_body",
		hit_gen = "melee_hit_gen"
	}
	self.melee_weapons.fists = {
		name_id = "bm_melee_fists",
		type = "fists",
		unit = nil,
		animation = nil,
		free = true,
		stats = {}
	}
	self.melee_weapons.fists.stats.min_damage = 50
	self.melee_weapons.fists.stats.max_damage = 92
	self.melee_weapons.fists.stats.min_damage_effect = 3
	self.melee_weapons.fists.stats.max_damage_effect = 2
	self.melee_weapons.fists.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.fists.stats.range = 150
	self.melee_weapons.fists.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.fists.stats.weapon_type = "blunt"
	self.melee_weapons.fists.anim_global_param = "melee_fist"
	self.melee_weapons.fists.anim_attack_vars = {
		"var1",
		"var2",
		"var3",
		"var4"
	}
	self.melee_weapons.fists.expire_t = 1
	self.melee_weapons.fists.repeat_expire_t = 0.55
	self.melee_weapons.fists.melee_damage_delay = 0.2
	self.melee_weapons.fists.melee_charge_shaker = "player_melee_charge_fist"
	self.melee_weapons.fists.sounds = {
		equip = "fist_equip",
		hit_air = "fist_hit_air",
		hit_gen = "fist_hit_gen",
		hit_body = "fist_hit_body",
		charge = "fist_charge"
	}
	self.melee_weapons.fists.stats.concealment = 30
	self.melee_weapons.m3_knife = {
		type = "knife",
		name_id = "bm_melee_m3_knife",
		desc_id = "bm_melee_m3_knife_desc",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "m3",
		weapon_hold = "m3",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/vanilla/weapons/wpn_fps_mel_m3_knife/wpn_fps_mel_m3_knife",
		third_unit = "units/vanilla/weapons/wpn_third_mel_m3_knife/wpn_third_mel_m3_knife",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.m3_knife.stats.min_damage = 133
	self.melee_weapons.m3_knife.stats.max_damage = 250
	self.melee_weapons.m3_knife.stats.min_damage_effect = 1
	self.melee_weapons.m3_knife.stats.max_damage_effect = 1
	self.melee_weapons.m3_knife.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.m3_knife.stats.range = 185
	self.melee_weapons.m3_knife.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.m3_knife.stats.weapon_type = "sharp"
	self.melee_weapons.m3_knife.stats.concealment = 30
	self.melee_weapons.m3_knife.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.m3_knife.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.m3_knife.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.m3_knife.hold = "melee"
	self.melee_weapons.m3_knife.usage_anim = "c45"
	self.melee_weapons.m3_knife.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "knife_hit_body",
		killing_blow = "knife_killing_blow"
	}
	self.melee_weapons.m3_knife.gui = {
		rotation_offset = -2,
		distance_offset = -100,
		height_offset = -8,
		display_offset = 10,
		initial_rotation = {}
	}
	self.melee_weapons.m3_knife.gui.initial_rotation.yaw = 90
	self.melee_weapons.m3_knife.gui.initial_rotation.pitch = 20
	self.melee_weapons.m3_knife.gui.initial_rotation.roll = 160
	self.melee_weapons.robbins_dudley_trench_push_dagger = {
		type = "knife",
		name_id = "bm_melee_robbins_dudley_trench_push_dagger",
		desc_id = "bm_melee_robbins_dudley_trench_push_dagger_desc",
		reward_image = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/robbins_dudley_trench_push_dagger_hud",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "robbins_dudley_trench_push_dagger",
		weapon_hold = "robbins_dudley_trench_push_dagger",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/vanilla/weapons/wpn_fps_mel_robbins_dudley_trench_push_dagger/wpn_fps_mel_robbins_dudley_trench_push_dagger",
		third_unit = "units/vanilla/weapons/wpn_third_mel_robbins_dudley_trench_push_dagger/wpn_third_mel_robbins_dudley_trench_push_dagger",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.min_damage = 133
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.max_damage = 250
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.min_damage_effect = 1
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.max_damage_effect = 1
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.range = 185
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.weapon_type = "sharp"
	self.melee_weapons.robbins_dudley_trench_push_dagger.stats.concealment = 30
	self.melee_weapons.robbins_dudley_trench_push_dagger.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.robbins_dudley_trench_push_dagger.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.robbins_dudley_trench_push_dagger.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.robbins_dudley_trench_push_dagger.hold = "melee"
	self.melee_weapons.robbins_dudley_trench_push_dagger.usage_anim = "c45"
	self.melee_weapons.robbins_dudley_trench_push_dagger.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "knife_hit_body",
		killing_blow = "knife_killing_blow"
	}
	self.melee_weapons.robbins_dudley_trench_push_dagger.gui = {
		rotation_offset = 4,
		distance_offset = -100,
		height_offset = -12,
		display_offset = 12,
		initial_rotation = {}
	}
	self.melee_weapons.robbins_dudley_trench_push_dagger.gui.initial_rotation.yaw = -90
	self.melee_weapons.robbins_dudley_trench_push_dagger.gui.initial_rotation.pitch = 0
	self.melee_weapons.robbins_dudley_trench_push_dagger.gui.initial_rotation.roll = 0
	self.melee_weapons.german_brass_knuckles = {
		type = "knife",
		name_id = "bm_melee_german_brass_knuckles",
		desc_id = "bm_melee_german_brass_knuckles_desc",
		reward_image = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/german_brass_knuckles_hud",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "brass_knuckles",
		weapon_hold = "brass_knuckles",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/vanilla/weapons/wpn_fps_mel_german_brass_knuckles/wpn_fps_mel_german_brass_knuckles",
		third_unit = "units/vanilla/weapons/wpn_third_mel_german_brass_knuckles/wpn_third_mel_german_brass_knuckles",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.german_brass_knuckles.stats.min_damage = 133
	self.melee_weapons.german_brass_knuckles.stats.max_damage = 250
	self.melee_weapons.german_brass_knuckles.stats.min_damage_effect = 1
	self.melee_weapons.german_brass_knuckles.stats.max_damage_effect = 1
	self.melee_weapons.german_brass_knuckles.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.german_brass_knuckles.stats.range = 185
	self.melee_weapons.german_brass_knuckles.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.german_brass_knuckles.stats.weapon_type = "sharp"
	self.melee_weapons.german_brass_knuckles.stats.concealment = 30
	self.melee_weapons.german_brass_knuckles.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.german_brass_knuckles.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.german_brass_knuckles.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.german_brass_knuckles.hold = "melee"
	self.melee_weapons.german_brass_knuckles.usage_anim = "c45"
	self.melee_weapons.german_brass_knuckles.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "knife_hit_body",
		killing_blow = "knife_killing_blow"
	}
	self.melee_weapons.german_brass_knuckles.gui = {
		rotation_offset = 4,
		distance_offset = -130,
		height_offset = -9,
		display_offset = 14,
		initial_rotation = {}
	}
	self.melee_weapons.german_brass_knuckles.gui.initial_rotation.yaw = -90
	self.melee_weapons.german_brass_knuckles.gui.initial_rotation.pitch = 0
	self.melee_weapons.german_brass_knuckles.gui.initial_rotation.roll = 0
	self.melee_weapons.lockwood_brothers_push_dagger = {
		type = "knife",
		name_id = "bm_melee_lockwood_brothers_push_dagger",
		desc_id = "bm_melee_lockwood_brothers_push_dagger_desc",
		reward_image = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/lockwood_brothers_push_dagger_hud",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "lockwood_brothers_push_dagger",
		weapon_hold = "lockwood_brothers_push_dagger",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/vanilla/weapons/wpn_fps_mel_lockwood_brothers_push_dagger/wpn_fps_mel_lockwood_brothers_push_dagger",
		third_unit = "units/vanilla/weapons/wpn_third_mel_lockwood_brothers_push_dagger/wpn_third_mel_lockwood_brothers_push_dagger",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.lockwood_brothers_push_dagger.stats.min_damage = 133
	self.melee_weapons.lockwood_brothers_push_dagger.stats.max_damage = 250
	self.melee_weapons.lockwood_brothers_push_dagger.stats.min_damage_effect = 1
	self.melee_weapons.lockwood_brothers_push_dagger.stats.max_damage_effect = 1
	self.melee_weapons.lockwood_brothers_push_dagger.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.lockwood_brothers_push_dagger.stats.range = 185
	self.melee_weapons.lockwood_brothers_push_dagger.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.lockwood_brothers_push_dagger.stats.weapon_type = "sharp"
	self.melee_weapons.lockwood_brothers_push_dagger.stats.concealment = 30
	self.melee_weapons.lockwood_brothers_push_dagger.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.lockwood_brothers_push_dagger.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.lockwood_brothers_push_dagger.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.lockwood_brothers_push_dagger.hold = "melee"
	self.melee_weapons.lockwood_brothers_push_dagger.usage_anim = "c45"
	self.melee_weapons.lockwood_brothers_push_dagger.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "knife_hit_body",
		killing_blow = "knife_killing_blow"
	}
	self.melee_weapons.lockwood_brothers_push_dagger.gui = {
		rotation_offset = 1,
		distance_offset = -120,
		height_offset = -11,
		display_offset = 13,
		initial_rotation = {}
	}
	self.melee_weapons.lockwood_brothers_push_dagger.gui.initial_rotation.yaw = -90
	self.melee_weapons.lockwood_brothers_push_dagger.gui.initial_rotation.pitch = 0
	self.melee_weapons.lockwood_brothers_push_dagger.gui.initial_rotation.roll = 0
	self.melee_weapons.bc41_knuckle_knife = {
		type = "knife",
		name_id = "bm_melee_bc41_knuckle_knife",
		desc_id = "bm_melee_bc41_knuckle_knife_desc",
		reward_image = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/bc41_knuckle_knife_hud",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "bc41_knuckle_knife",
		weapon_hold = "bc41_knuckle_knife",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/vanilla/weapons/wpn_fps_mel_bc41_knuckle_knife/wpn_fps_mel_bc41_knuckle_knife",
		third_unit = "units/vanilla/weapons/wpn_third_mel_bc41_knuckle_knife/wpn_third_mel_bc41_knuckle_knife",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.bc41_knuckle_knife.stats.min_damage = 133
	self.melee_weapons.bc41_knuckle_knife.stats.max_damage = 250
	self.melee_weapons.bc41_knuckle_knife.stats.min_damage_effect = 1
	self.melee_weapons.bc41_knuckle_knife.stats.max_damage_effect = 1
	self.melee_weapons.bc41_knuckle_knife.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.bc41_knuckle_knife.stats.range = 185
	self.melee_weapons.bc41_knuckle_knife.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.bc41_knuckle_knife.stats.weapon_type = "sharp"
	self.melee_weapons.bc41_knuckle_knife.stats.concealment = 30
	self.melee_weapons.bc41_knuckle_knife.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.bc41_knuckle_knife.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.bc41_knuckle_knife.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.bc41_knuckle_knife.hold = "melee"
	self.melee_weapons.bc41_knuckle_knife.usage_anim = "c45"
	self.melee_weapons.bc41_knuckle_knife.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "knife_hit_body",
		killing_blow = "knife_killing_blow"
	}
	self.melee_weapons.bc41_knuckle_knife.gui = {
		rotation_offset = 2,
		distance_offset = -120,
		height_offset = -9,
		display_offset = 13,
		initial_rotation = {}
	}
	self.melee_weapons.bc41_knuckle_knife.gui.initial_rotation.yaw = -90
	self.melee_weapons.bc41_knuckle_knife.gui.initial_rotation.pitch = 0
	self.melee_weapons.bc41_knuckle_knife.gui.initial_rotation.roll = 0
	self.melee_weapons.km_dagger = {
		type = "knife",
		name_id = "bm_melee_km_dagger",
		desc_id = "bm_melee_km_dagger_desc",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "km_dagger",
		weapon_hold = "km_dagger",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/vanilla/weapons/wpn_fps_km_dagger/wpn_fps_km_dagger",
		third_unit = "units/vanilla/weapons/wpn_third_mel_km_dagger/wpn_third_mel_km_dagger",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.km_dagger.stats.min_damage = 133
	self.melee_weapons.km_dagger.stats.max_damage = 250
	self.melee_weapons.km_dagger.stats.min_damage_effect = 1
	self.melee_weapons.km_dagger.stats.max_damage_effect = 1
	self.melee_weapons.km_dagger.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.km_dagger.stats.range = 185
	self.melee_weapons.km_dagger.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.km_dagger.stats.weapon_type = "sharp"
	self.melee_weapons.km_dagger.stats.concealment = 30
	self.melee_weapons.km_dagger.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.km_dagger.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.km_dagger.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.km_dagger.hold = "melee"
	self.melee_weapons.km_dagger.usage_anim = "c45"
	self.melee_weapons.km_dagger.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "knife_hit_body",
		killing_blow = "knife_killing_blow"
	}
	self.melee_weapons.km_dagger.gui = {
		rotation_offset = -12,
		distance_offset = -75,
		height_offset = -8,
		display_offset = 9,
		initial_rotation = {}
	}
	self.melee_weapons.km_dagger.gui.initial_rotation.yaw = -90
	self.melee_weapons.km_dagger.gui.initial_rotation.pitch = -165
	self.melee_weapons.km_dagger.gui.initial_rotation.roll = 15
	self.melee_weapons.km_dagger.dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION
	self.melee_weapons.marching_mace = {
		type = "knife",
		name_id = "bm_melee_marching_mace",
		desc_id = "bm_melee_marching_mace_desc",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "marching_mace",
		weapon_hold = "marching_mace",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/vanilla/weapons/wpn_fps_mel_marching_mace/wpn_fps_mel_marching_mace",
		third_unit = "units/vanilla/weapons/wpn_third_mel_marching_mace/wpn_third_mel_marching_mace",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.marching_mace.stats.min_damage = 133
	self.melee_weapons.marching_mace.stats.max_damage = 250
	self.melee_weapons.marching_mace.stats.min_damage_effect = 1
	self.melee_weapons.marching_mace.stats.max_damage_effect = 1
	self.melee_weapons.marching_mace.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.marching_mace.stats.range = 185
	self.melee_weapons.marching_mace.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.marching_mace.stats.weapon_type = "sharp"
	self.melee_weapons.marching_mace.stats.concealment = 30
	self.melee_weapons.marching_mace.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.marching_mace.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.marching_mace.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.marching_mace.hold = "marching_mace"
	self.melee_weapons.marching_mace.usage_anim = "c45"
	self.melee_weapons.marching_mace.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "knife_hit_body",
		killing_blow = "knife_killing_blow"
	}
	self.melee_weapons.marching_mace.dlc = DLCTweakData.DLC_NAME_SPECIAL_EDITION
	self.melee_weapons.marching_mace.gui = {
		rotation_offset = -30,
		distance_offset = 60,
		height_offset = -10,
		display_offset = -6,
		initial_rotation = {}
	}
	self.melee_weapons.marching_mace.gui.initial_rotation.yaw = -90
	self.melee_weapons.marching_mace.gui.initial_rotation.pitch = 30
	self.melee_weapons.marching_mace.gui.initial_rotation.roll = 0
	self.melee_weapons.lc14b = {
		type = "knife",
		name_id = "bm_melee_lc14b",
		desc_id = "bm_melee_lc14b_desc",
		reward_image = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b_hud",
		weapon_movement_penalty = 1,
		exit_run_speed_multiplier = 1,
		transition_duration = 0,
		stance = "machete",
		weapon_hold = "machete",
		align_objects = {
			"a_weapon_right"
		},
		unit = "units/event_001_halloween/weapons/wpn_fps_mel_lc14b/wpn_fps_mel_lc14b",
		third_unit = "units/event_001_halloween/weapons/wpn_third_mel_lc14b/wpn_third_mel_lc14b",
		repeat_expire_t = 0.6,
		expire_t = 0.75,
		melee_damage_delay = 0.1,
		melee_charge_shaker = "player_melee_charge",
		stats = {}
	}
	self.melee_weapons.lc14b.stats.min_damage = 133
	self.melee_weapons.lc14b.stats.max_damage = 250
	self.melee_weapons.lc14b.stats.min_damage_effect = 1
	self.melee_weapons.lc14b.stats.max_damage_effect = 1
	self.melee_weapons.lc14b.stats.charge_time = MELEE_SPEED_NORMAL
	self.melee_weapons.lc14b.stats.range = 185
	self.melee_weapons.lc14b.stats.remove_weapon_movement_penalty = true
	self.melee_weapons.lc14b.stats.weapon_type = "sharp"
	self.melee_weapons.lc14b.stats.concealment = 30
	self.melee_weapons.lc14b.animations = {
		equip_id = "equip_welrod"
	}
	self.melee_weapons.lc14b.timers = {
		reload_not_empty = 1.25,
		reload_empty = 1.65,
		unequip = 0.5,
		equip = 0.25
	}
	self.melee_weapons.lc14b.use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = MELEE_SLOT,
		unequip = {
			align_place = "back"
		}
	}
	self.melee_weapons.lc14b.hold = "machete"
	self.melee_weapons.lc14b.usage_anim = "c45"
	self.melee_weapons.lc14b.sounds = {
		equip = "knife_equip",
		hit_air = "knife_hit_air",
		hit_gen = "knife_hit_gen",
		hit_body = "machete_hit_body",
		killing_blow = "machete_killing_blow"
	}
	self.melee_weapons.lc14b.dismember_chance = 0.5
	self.melee_weapons.lc14b.gui = {
		rotation_offset = -10,
		distance_offset = -80,
		height_offset = -4,
		display_offset = 8,
		initial_rotation = {}
	}
	self.melee_weapons.lc14b.gui.initial_rotation.yaw = 100
	self.melee_weapons.lc14b.gui.initial_rotation.pitch = 10
	self.melee_weapons.lc14b.gui.initial_rotation.roll = 160

	self:_add_desc_from_name_macro(self.melee_weapons)
end
