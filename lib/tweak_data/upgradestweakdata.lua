UpgradesTweakData = UpgradesTweakData or class()
UpgradesTweakData.WARCRY_RADIUS = {
	500,
	600,
	700
}
UpgradesTweakData.WARCRY_EFFECT_NAME = {
	"dmg_mul"
}
UpgradesTweakData.WARCRY_EFFECT_DATA = {
	1.2,
	1.3,
	1.4
}
UpgradesTweakData.WARCRY_TIME = {
	5,
	6
}
UpgradesTweakData.CLEAR_UPGRADES_FLAG = "CLEAR_ALL_UPGRADES"
UpgradesTweakData.UPGRADE_TYPE_RAW_VALUE_AMOUNT = "stat_type_raw_value_amount"
UpgradesTweakData.UPGRADE_TYPE_RAW_VALUE_REDUCTION = "stat_type_raw_value_reduction"
UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER = "stat_type_multiplier"
UpgradesTweakData.UPGRADE_TYPE_REDUCTIVE_MULTIPLIER = "stat_type_reductive_multiplier"
UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER_REDUCTIVE_STRING = "stat_type_multiplier_inverse_string"
UpgradesTweakData.UPGRADE_TYPE_TEMPORARY_REDUCTION = "stat_type_temporary_reduction"

function UpgradesTweakData:init()
	self.definitions = {}

	self:_create_generic_description_data_types()
	self:_init_value_tables()
	self:_old_init()
	self:_create_raid_team_definitions()
	self:_create_raid_warcry_definitions()
	self:_create_raid_definitions_modifiers()
	self:_create_raid_definitions_abilities()
	self:_create_weapon_definitions()
	self:_create_grenades_definitions()
	self:_raid_temporary_definitions()
	self:_create_melee_weapon_definitions()
	self:_pistol_definitions()
	self:_assault_rifle_definitions()
	self:_smg_definitions()
	self:_shotgun_definitions()
	self:_lmg_definitions()
	self:_snp_definitions()
end

function UpgradesTweakData:_init_value_tables()
	self.values = {
		player = {},
		carry = {},
		interaction = {},
		trip_mine = {},
		ammo_bag = {},
		ecm_jammer = {},
		sentry_gun = {},
		doctor_bag = {},
		cable_tie = {},
		bodybags_bag = {},
		first_aid_kit = {},
		weapon = {},
		pistol = {},
		assault_rifle = {},
		smg = {},
		shotgun = {},
		saw = {},
		lmg = {},
		snp = {},
		akimbo = {},
		minigun = {},
		melee = {}
	}

	self:_primary_weapon_definitions()
	self:_secondary_weapon_definitions()

	self.values.temporary = {}
	self.values.team = {
		player = {},
		weapon = {},
		pistol = {},
		akimbo = {},
		xp = {},
		armor = {},
		stamina = {},
		health = {},
		cash = {},
		damage_dampener = {}
	}
end

function UpgradesTweakData:_create_generic_description_data_types()
	self.description_data_types = {
		generic_multiplier = {
			upgrade_type = UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER
		},
		generic_multiplier_reductive_string = {
			upgrade_type = UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER_REDUCTIVE_STRING
		},
		reductive_multiplier = {
			upgrade_type = UpgradesTweakData.UPGRADE_TYPE_REDUCTIVE_MULTIPLIER
		},
		raw_value_reduction = {
			upgrade_type = UpgradesTweakData.UPGRADE_TYPE_RAW_VALUE_REDUCTION
		},
		raw_value_amount = {
			upgrade_type = UpgradesTweakData.UPGRADE_TYPE_RAW_VALUE_AMOUNT
		},
		temporary_reduction = {
			upgrade_type = UpgradesTweakData.UPGRADE_TYPE_TEMPORARY_REDUCTION
		}
	}
end

function UpgradesTweakData:_create_raid_team_definitions()
	self.values.team.player.warcry_damage_multiplier = {
		1.25,
		1.5,
		1.75,
		2
	}

	self:_create_definition_levels("warcry_team_damage_multiplier", "team", "warcry_damage_multiplier", "player", false, self.values.team.player.warcry_damage_multiplier)

	self.values.team.player.warcry_damage_reduction_multiplier = {
		0.75,
		0.75,
		0.7,
		0.6,
		0.5
	}

	self:_create_definition_levels("warcry_team_damage_reduction_multiplier", "team", "warcry_damage_reduction_multiplier", "player", false, self.values.team.player.warcry_damage_reduction_multiplier)

	self.values.team.player.warcry_stamina_multiplier = {
		1.25,
		1.5,
		1.75,
		2
	}

	self:_create_definition_levels("warcry_team_stamina_multiplier", "team", "warcry_stamina_multiplier", "player", false, self.values.team.player.warcry_stamina_multiplier)

	self.values.team.player.warcry_health_regeneration = {
		0.03,
		0.05,
		0.07,
		0.1,
		0.12
	}

	self:_create_definition_levels("warcry_team_health_regeneration", "team", "warcry_health_regeneration", "player", false, self.values.team.player.warcry_health_regeneration)

	self.values.team.player.warcry_movement_speed_multiplier = {
		1.125,
		1.2,
		1.3,
		1.4
	}

	self:_create_definition_levels("warcry_team_movement_speed_multiplier", "team", "warcry_movement_speed_multiplier", "player", false, self.values.team.player.warcry_movement_speed_multiplier)

	self.values.team.player.warcry_damage_buff_bonus = {
		1.04,
		1.08,
		1.13,
		1.2
	}

	self:_create_definition_levels("warcry_team_damage_buff_bonus", "team", "warcry_damage_buff_bonus", "player", true, self.values.team.player.warcry_damage_buff_bonus)

	self.values.team.player.warcry_team_movement_speed_bonus = {
		1.022,
		1.044,
		1.072,
		1.111
	}

	self:_create_definition_levels("warcry_team_movement_speed_bonus", "team", "warcry_team_movement_speed_bonus", "player", true, self.values.team.player.warcry_team_movement_speed_bonus)

	self.values.team.player.warcry_team_damage_reduction_bonus = {
		0.933,
		0.867,
		0.783,
		0.667
	}

	self:_create_definition_levels("warcry_team_damage_reduction_bonus", "team", "warcry_team_damage_reduction_bonus", "player", true, self.values.team.player.warcry_team_damage_reduction_bonus)

	self.values.team.player.warcry_team_damage_reduction_bonus_on_activate = {
		1,
		2,
		3,
		4
	}

	self:_create_definition_levels("warcry_team_damage_reduction_bonus_on_activate", "team", "warcry_team_damage_reduction_bonus_on_activate", "player", true, self.values.team.player.warcry_team_damage_reduction_bonus_on_activate)
end

function UpgradesTweakData:_create_raid_warcry_definitions()
	self.values.player.warcry_duration = {
		1.1,
		1.2,
		1.325,
		1.5
	}

	self:_create_definition_levels("warcry_player_duration", "feature", "warcry_duration", "player", true, self.values.player.warcry_duration)

	self.values.player.warcry_aim_assist = {
		true
	}

	self:_create_definition("warcry_player_aim_assist", "feature", "warcry_aim_assist", "player", false, 1)

	self.values.player.warcry_health_regen_on_kill = {
		true
	}

	self:_create_definition("warcry_player_health_regen_on_kill", "feature", "warcry_health_regen_on_kill", "player", false, 1)

	self.values.player.warcry_health_regen_amount = {
		5,
		7,
		9,
		12
	}

	self:_create_definition_levels("warcry_player_health_regen_amount", "feature", "warcry_health_regen_amount", "player", false, self.values.player.warcry_health_regen_amount)

	self.values.player.warcry_nullify_spread = {
		true
	}

	self:_create_definition("warcry_player_nullify_spread", "feature", "warcry_nullify_spread", "player", false, 1)

	self.values.player.warcry_sniper_ricochet = {
		true
	}

	self:_create_definition("warcry_player_sniper_ricochet", "feature", "warcry_sniper_ricochet", "player", false, 1)

	self.values.player.warcry_aim_assist_aim_at_head = {
		true
	}

	self:_create_definition("warcry_player_aim_assist_aim_at_head", "feature", "warcry_aim_assist_aim_at_head", "player", false, 1)

	self.values.player.warcry_aim_assist_radius = {
		1,
		1.6,
		2.5
	}

	self:_create_definition_levels("warcry_player_aim_assist_radius", "feature", "warcry_aim_assist_radius", "player", false, self.values.player.warcry_aim_assist_radius)

	self.values.player.warcry_headshot_multiplier_bonus = {
		1.2,
		1.7
	}

	self:_create_definition_levels("warcry_player_headshot_multiplier_bonus", "feature", "warcry_headshot_multiplier_bonus", "player", true, self.values.player.warcry_headshot_multiplier_bonus)

	self.values.player.warcry_long_range_multiplier_bonus = {
		1.2,
		1.7
	}

	self:_create_definition_levels("warcry_player_long_range_multiplier_bonus", "feature", "warcry_long_range_multiplier_bonus", "player", true, self.values.player.warcry_long_range_multiplier_bonus)

	self.values.player.warcry_no_reloads = {
		true
	}

	self:_create_definition("warcry_player_no_reloads", "feature", "warcry_no_reloads", "player", false, 1)

	self.values.player.warcry_refill_clip = {
		true
	}

	self:_create_definition("warcry_player_refill_clip", "feature", "warcry_refill_clip", "player", false, 1)

	self.values.player.warcry_ammo_consumption = {
		2,
		3,
		5,
		0
	}

	self:_create_definition_levels("warcry_player_ammo_consumption", "feature", "warcry_ammo_consumption", "player", false, self.values.player.warcry_ammo_consumption)

	self.values.player.warcry_overheat_multiplier = {
		0.5,
		0.333,
		0.2,
		0.1
	}

	self:_create_definition_levels("warcry_turret_overheat_multiplier", "feature", "warcry_overheat_multiplier", "player", false, self.values.player.warcry_ammo_consumption)

	self.values.player.warcry_dismemberment_multiplier_bonus = {
		2,
		3
	}

	self:_create_definition_levels("warcry_player_dismemberment_multiplier_bonus", "feature", "warcry_dismemberment_multiplier_bonus", "player", true, self.values.player.warcry_dismemberment_multiplier_bonus)

	self.values.player.warcry_low_health_multiplier_bonus = {
		1.2,
		1.7
	}

	self:_create_definition_levels("warcry_player_low_health_multiplier_bonus", "feature", "warcry_low_health_multiplier_bonus", "player", true, self.values.player.warcry_low_health_multiplier_bonus)

	self.values.player.warcry_team_heal_bonus = {
		1.05,
		1.1,
		1.2,
		1.4
	}

	self:_create_definition_levels("warcry_player_team_heal_bonus", "feature", "warcry_team_heal_bonus", "player", true, self.values.player.warcry_team_heal_bonus)

	self.values.player.warcry_dodge = {
		0.5,
		0.6,
		0.7,
		0.85,
		1
	}

	self:_create_definition_levels("warcry_player_dodge", "feature", "warcry_dodge", "player", false, self.values.player.warcry_dodge)

	self.values.player.warcry_slower_detection = {
		0.1,
		0.2,
		0.3,
		0.4,
		0.5
	}

	self:_create_definition_levels("warcry_player_slower_detection", "feature", "warcry_slower_detection", "player", false, self.values.player.warcry_slower_detection)

	self.values.player.warcry_melee_multiplier_bonus = {
		1.2,
		1.7
	}

	self:_create_definition_levels("warcry_player_melee_multiplier_bonus", "feature", "warcry_melee_multiplier_bonus", "player", true, self.values.player.warcry_melee_multiplier_bonus)

	self.values.player.warcry_short_range_multiplier_bonus = {
		1.2,
		1.7
	}

	self:_create_definition_levels("warcry_player_short_range_multiplier_bonus", "feature", "warcry_short_range_multiplier_bonus", "player", true, self.values.player.warcry_short_range_multiplier_bonus)

	self.values.player.warcry_grenade_clusters = {
		1,
		2,
		3,
		4
	}

	self:_create_definition_levels("warcry_player_grenade_clusters", "feature", "warcry_grenade_clusters", "player", false, self.values.player.warcry_grenade_clusters)

	self.values.player.warcry_grenade_cluster_range = {
		0.5,
		0.667,
		0.75
	}

	self:_create_definition_levels("warcry_player_grenade_cluster_range", "feature", "warcry_grenade_cluster_range", "player", false, self.values.player.warcry_grenade_cluster_range)

	self.values.player.warcry_grenade_cluster_damage = {
		0.5,
		0.667,
		0.75
	}

	self:_create_definition_levels("warcry_player_grenade_cluster_damage", "feature", "warcry_grenade_cluster_damage", "player", false, self.values.player.warcry_grenade_cluster_damage)

	self.values.player.warcry_grenade_airburst = {
		true
	}

	self:_create_definition("warcry_player_grenade_airburst", "feature", "warcry_grenade_airburst", "player", false, 1)

	self.values.player.warcry_explosions_multiplier_bonus = {
		1.3,
		1.5
	}

	self:_create_definition_levels("warcry_player_explosions_multiplier_bonus", "feature", "warcry_explosions_multiplier_bonus", "player", true, self.values.player.warcry_explosions_multiplier_bonus)

	self.values.player.warcry_killstreak_multiplier_bonus = {
		1.2,
		1.7
	}

	self:_create_definition_levels("warcry_player_killstreak_multiplier_bonus", "feature", "warcry_killstreak_multiplier_bonus", "player", true, self.values.player.warcry_killstreak_multiplier_bonus)
end

function UpgradesTweakData:_create_raid_definitions_modifiers()
	self.values.player.max_health_multiplier = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_max_health_multiplier", "feature", "max_health_multiplier", "player", true, self.values.player.max_health_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.pick_up_ammo_multiplier = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_pick_up_ammo_multiplier", "feature", "pick_up_ammo_multiplier", "player", true, self.values.player.pick_up_ammo_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.pick_up_health_multiplier = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_pick_up_health_multiplier", "feature", "pick_up_health_multiplier", "player", true, self.values.player.pick_up_health_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.primary_ammo_increase = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_primary_ammo_increase", "feature", "primary_ammo_increase", "player", true, self.values.player.primary_ammo_increase, self.description_data_types.generic_multiplier)

	self.values.player.secondary_ammo_increase = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_secondary_ammo_increase", "feature", "secondary_ammo_increase", "player", true, self.values.player.secondary_ammo_increase, self.description_data_types.generic_multiplier)

	self.values.player.all_movement_speed_increase = {
		1.02,
		1.04,
		1.07,
		1.1
	}

	self:_create_definition_levels("player_all_movement_speed_increase", "feature", "all_movement_speed_increase", "player", true, self.values.player.all_movement_speed_increase, self.description_data_types.generic_multiplier)

	self.values.player.run_speed_increase = {
		1.05,
		1.1,
		1.16,
		1.25
	}

	self:_create_definition_levels("player_run_speed_increase", "feature", "run_speed_increase", "player", true, self.values.player.run_speed_increase, self.description_data_types.generic_multiplier)

	self.values.player.climb_speed_increase = {
		1.5,
		1.7,
		1.9
	}

	self:_create_definition_levels("player_climb_speed_increase", "feature", "climb_speed_increase", "player", true, self.values.player.climb_speed_increase)

	self.values.player.crouch_speed_increase = {
		1.05,
		1.1,
		1.16,
		1.25
	}

	self:_create_definition_levels("player_crouch_speed_increase", "feature", "crouch_speed_increase", "player", true, self.values.player.crouch_speed_increase, self.description_data_types.generic_multiplier)

	self.values.player.carry_penalty_decrease = {
		1.1,
		1.2,
		1.3,
		1.4
	}

	self:_create_definition_levels("player_carry_penalty_decrease", "feature", "carry_penalty_decrease", "player", true, self.values.player.carry_penalty_decrease, self.description_data_types.generic_multiplier_reductive_string)

	self.values.player.running_damage_reduction = {
		0.9,
		0.8,
		0.68,
		0.5
	}

	self:_create_definition_levels("player_running_damage_reduction", "feature", "running_damage_reduction", "player", true, self.values.player.running_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.crouching_damage_reduction = {
		0.93,
		0.86,
		0.77,
		0.65
	}

	self:_create_definition_levels("player_crouching_damage_reduction", "feature", "crouching_damage_reduction", "player", true, self.values.player.crouching_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.interacting_damage_reduction = {
		0.85,
		0.7,
		0.51,
		0.25
	}

	self:_create_definition_levels("player_interacting_damage_reduction", "feature", "interacting_damage_reduction", "player", true, self.values.player.interacting_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.bullet_damage_reduction = {
		0.95,
		0.9,
		0.84,
		0.75
	}

	self:_create_definition_levels("player_bullet_damage_reduction", "feature", "bullet_damage_reduction", "player", true, self.values.player.bullet_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.melee_damage_reduction = {
		0.9,
		0.8,
		0.68,
		0.5
	}

	self:_create_definition_levels("player_melee_damage_reduction", "feature", "melee_damage_reduction", "player", true, self.values.player.melee_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.headshot_damage_multiplier = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_headshot_damage_multiplier", "feature", "headshot_damage_multiplier", "player", true, self.values.player.headshot_damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.melee_damage_multiplier = {
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("player_melee_damage_multiplier", "feature", "melee_damage_multiplier", "player", true, self.values.player.melee_damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.critical_hit_chance = {
		1.025,
		1.05,
		1.1,
		1.25
	}

	self:_create_definition_levels("player_critical_hit_chance", "feature", "critical_hit_chance", "player", true, self.values.player.critical_hit_chance, self.description_data_types.generic_multiplier)

	self.values.player.enter_steelsight_speed_multiplier = {
		1.5,
		2,
		2.5
	}

	self:_create_definition_levels("player_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "player", true, self.values.player.enter_steelsight_speed_multiplier)

	self.values.player.ready_weapon_speed_multiplier = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("player_ready_weapon_speed_multiplier", "feature", "ready_weapon_speed_multiplier", "player", true, self.values.player.ready_weapon_speed_multiplier, self.description_data_types.generic_multiplier_reductive_string)

	self.values.player.steelsight_speed_increase = {
		1.25
	}

	self:_create_definition_levels("player_steelsight_speed_increase", "feature", "steelsight_speed_increase", "player", true, self.values.player.steelsight_speed_increase)

	self.values.player.weapon_sway_decrease = {
		0.7,
		0.4
	}

	self:_create_definition_levels("player_weapon_sway_decrease", "feature", "weapon_sway_decrease", "player", true, self.values.player.weapon_sway_decrease)

	self.values.player.on_hit_flinch_reduction = {
		0.83,
		0.71,
		0.61,
		0.5
	}

	self:_create_definition_levels("player_on_hit_flinch_reduction", "feature", "on_hit_flinch_reduction", "player", true, self.values.player.on_hit_flinch_reduction, self.description_data_types.generic_multiplier_reductive_string)

	self.values.player.swap_speed_multiplier = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("player_swap_speed_multiplier", "feature", "swap_speed_multiplier", "player", true, self.values.player.swap_speed_multiplier, self.description_data_types.generic_multiplier_reductive_string)

	self.values.interaction.general_interaction_timer_multiplier = {
		0.83,
		0.71,
		0.61,
		0.5
	}

	self:_create_definition_levels("interaction_general_interaction_timer_multiplier", "feature", "general_interaction_timer_multiplier", "interaction", true, self.values.interaction.general_interaction_timer_multiplier, self.description_data_types.reductive_multiplier)

	self.values.interaction.open_crate_multiplier = {
		0.75
	}

	self:_create_definition_levels("interaction_open_crate_multiplier", "feature", "open_crate_multiplier", "interaction", true, self.values.interaction.open_crate_multiplier)

	self.values.interaction.wheel_hotspot_increase = {
		0.96,
		0.92,
		0.865,
		0.8
	}

	self:_create_definition_levels("interaction_wheel_hotspot_increase", "feature", "wheel_hotspot_increase", "interaction", true, self.values.interaction.wheel_hotspot_increase, self.description_data_types.reductive_multiplier)

	self.values.interaction.wheel_amount_decrease = {
		1,
		2
	}

	self:_create_definition_levels("interaction_wheel_amount_decrease", "feature", "wheel_amount_decrease", "interaction", true, self.values.interaction.wheel_amount_decrease, self.description_data_types.raw_value_reduction)

	self.values.interaction.wheel_rotation_speed_increase = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("interaction_wheel_rotation_speed_increase", "feature", "wheel_rotation_speed_increase", "interaction", true, self.values.interaction.wheel_rotation_speed_increase, self.description_data_types.generic_multiplier)

	self.values.interaction.dynamite_plant_multiplier = {
		0.75
	}

	self:_create_definition_levels("interaction_dynamite_plant_multiplier", "feature", "dynamite_plant_multiplier", "interaction", true, self.values.interaction.dynamite_plant_multiplier)

	self.values.interaction.carry_pickup_multiplier = {
		0.8,
		0.6
	}

	self:_create_definition_levels("interaction_carry_pickup_multiplier", "feature", "carry_pickup_multiplier", "interaction", true, self.values.interaction.carry_pickup_multiplier)

	self.values.player.stamina_multiplier = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("player_stamina_multiplier", "feature", "stamina_multiplier", "player", true, self.values.player.stamina_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.stamina_regeneration_increase = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("player_stamina_regeneration_increase", "feature", "stamina_regeneration_increase", "player", true, self.values.player.stamina_regeneration_increase, self.description_data_types.generic_multiplier)

	self.values.player.stamina_decay_decrease = {
		0.9
	}

	self:_create_definition_levels("player_stamina_decay_decrease", "feature", "stamina_decay_decrease", "player", true, self.values.player.stamina_decay_decrease)

	self.values.player.stamina_regen_timer_multiplier = {
		0.75,
		0.5
	}

	self:_create_definition_levels("player_stamina_regen_timer_multiplier", "feature", "stamina_regen_timer_multiplier", "player", true, self.values.player.stamina_regen_timer_multiplier)

	self.values.player.revive_from_bleed_out = {
		1,
		3
	}

	self:_create_definition_levels("player_revive_from_bleed_out", "feature", "revive_from_bleed_out", "player", true, self.values.player.revive_from_bleed_out)

	self.values.player.bleedout_timer_increase = {
		4,
		8,
		13,
		20
	}

	self:_create_definition_levels("player_bleedout_timer_increase", "feature", "bleedout_timer_increase", "player", true, self.values.player.bleedout_timer_increase, self.description_data_types.raw_value_amount)

	self.values.player.revive_interaction_speed_multiplier = {
		0.83,
		0.71,
		0.61,
		0.5
	}

	self:_create_definition_levels("player_revive_interaction_speed_multiplier", "feature", "revive_interaction_speed_multiplier", "player", true, self.values.player.revive_interaction_speed_multiplier, self.description_data_types.reductive_multiplier)

	self.values.player.long_dis_revive = {
		1
	}

	self:_create_definition_levels("player_long_dis_revive", "feature", "long_dis_revive", "player", true, self.values.player.long_dis_revive)
end

function UpgradesTweakData:_create_raid_definitions_abilities()
	self.values.player.highlight_enemy = {
		true
	}

	self:_create_definition("player_highlight_enemy", "feature", "highlight_enemy", "player", true, 1)

	self.values.player.can_use_scope = {
		true
	}

	self:_create_definition("player_can_use_scope", "feature", "can_use_scope", "player", true, 1)

	self.values.player.highlight_enemy_damage_bonus = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_highlight_enemy_damage_bonus", "feature", "highlight_enemy_damage_bonus", "player", true, self.values.player.highlight_enemy_damage_bonus, self.description_data_types.generic_multiplier)

	self.values.player.undetectable_by_spotters = {
		true
	}

	self:_create_definition("player_undetectable_by_spotters", "feature", "undetectable_by_spotters", "player", true, 1)

	self.values.player.self_administered_adrenaline = {
		true
	}

	self:_create_definition("player_self_administered_adrenaline", "feature", "self_administered_adrenaline", "player", true, 1)

	self.values.player.toss_ammo = {
		1,
		2
	}

	self:_create_definition("player_toss_ammo", "feature", "toss_ammo", "player", true, 1)

	self.values.player.warcry_dmg = {
		{
			name = 1,
			radius = 2,
			time = 1,
			cooldown = 10,
			data = 1
		}
	}

	self:_create_definition("player_warcry_dmg", "feature", "warcry_dmg", "player", true, 1)
end

function UpgradesTweakData:_raid_temporary_definitions()
	self.values.temporary.revived_damage_bonus = {
		{
			1.3,
			10
		}
	}

	self:_create_definition_levels("temporary_revived_damage_bonus", "temporary", "revived_damage_bonus", "temporary", false, self.values.temporary.revived_damage_bonus)

	self.values.temporary.revived_melee_damage_bonus = {
		{
			1.3,
			10
		}
	}

	self:_create_definition_levels("temporary_revived_melee_damage_bonus", "temporary", "revived_melee_damage_bonus", "temporary", false, self.values.temporary.revived_melee_damage_bonus)

	self.values.temporary.on_revived_damage_reduction = {
		{
			0.85,
			5
		},
		{
			0.7,
			6
		},
		{
			0.51,
			7
		},
		{
			0.25,
			10
		}
	}

	self:_create_definition_levels("temporary_on_revived_damage_reduction", "temporary", "on_revived_damage_reduction", "temporary", true, self.values.temporary.on_revived_damage_reduction, self.description_data_types.temporary_reduction)
end

function UpgradesTweakData:_create_weapon_definitions()
	self.values.player.recon_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_recon_tier_4_unlocked", "feature", "recon_tier_4_unlocked", "player", false, 1)

	self.values.player.assault_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_assault_tier_4_unlocked", "feature", "assault_tier_4_unlocked", "player", false, 1)

	self.values.player.infiltrator_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_infiltrator_tier_4_unlocked", "feature", "infiltrator_tier_4_unlocked", "player", false, 1)

	self.values.player.demolitions_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_demolitions_tier_4_unlocked", "feature", "demolitions_tier_4_unlocked", "player", false, 1)

	self.values.player.weapon_tier_unlocked = {
		1,
		2,
		3,
		4
	}

	self:_create_definition_levels("player_weapon_tier_unlocked", "feature", "weapon_tier_unlocked", "player", false, self.values.player.weapon_tier_unlocked)

	self.values.player.grenade_quantity = {
		1,
		2
	}

	self:_create_definition_levels("player_grenade_quantity", "feature", "grenade_quantity", "player", false, self.values.player.grenade_quantity, self.description_data_types.raw_value_amount)

	self.values.player.turret_m2_overheat_reduction = {
		0.83,
		0.71,
		0.61,
		0.5
	}

	self:_create_definition_levels("player_turret_m2_overheat_reduction", "feature", "turret_m2_overheat_reduction", "player", false, self.values.player.turret_m2_overheat_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.turret_flakvierling_overheat_reduction = {
		0.83,
		0.71,
		0.61,
		0.5
	}

	self:_create_definition_levels("player_turret_flakvierling_overheat_reduction", "feature", "turret_flakvierling_overheat_reduction", "player", false, self.values.player.turret_flakvierling_overheat_reduction)

	self.definitions.m1911 = {
		free = true,
		factory_id = "wpn_fps_pis_m1911",
		weapon_id = "m1911",
		category = "weapon"
	}
	self.definitions.geco = {
		factory_id = "wpn_fps_sho_geco",
		weapon_id = "geco",
		category = "weapon"
	}
	self.definitions.dp28 = {
		factory_id = "wpn_fps_lmg_dp28",
		weapon_id = "dp28",
		category = "weapon"
	}
	self.definitions.bren = {
		factory_id = "wpn_fps_lmg_bren",
		weapon_id = "bren",
		category = "weapon"
	}
	self.definitions.tt33 = {
		factory_id = "wpn_fps_pis_tt33",
		weapon_id = "tt33",
		category = "weapon"
	}
	self.definitions.ithaca = {
		factory_id = "wpn_fps_sho_ithaca",
		weapon_id = "ithaca",
		category = "weapon"
	}
	self.definitions.browning = {
		factory_id = "wpn_fps_sho_browning",
		weapon_id = "browning",
		category = "weapon"
	}
	self.definitions.welrod = {
		factory_id = "wpn_fps_pis_welrod",
		weapon_id = "welrod",
		category = "weapon"
	}
	self.definitions.shotty = {
		factory_id = "wpn_fps_pis_shotty",
		weapon_id = "shotty",
		category = "weapon"
	}
	self.definitions.kar_98k = {
		factory_id = "wpn_fps_snp_kar_98k",
		weapon_id = "kar_98k",
		category = "weapon"
	}
	self.definitions.lee_enfield = {
		factory_id = "wpn_fps_snp_lee_enfield",
		weapon_id = "lee_enfield",
		category = "weapon"
	}
	self.definitions.thompson = {
		free = true,
		factory_id = "wpn_fps_smg_thompson",
		weapon_id = "thompson",
		category = "weapon"
	}
	self.definitions.sten = {
		free = true,
		factory_id = "wpn_fps_smg_sten",
		weapon_id = "sten",
		category = "weapon"
	}
	self.definitions.garand = {
		factory_id = "wpn_fps_ass_garand",
		weapon_id = "garand",
		category = "weapon"
	}
	self.definitions.m1918 = {
		factory_id = "wpn_fps_lmg_m1918",
		weapon_id = "m1918",
		category = "weapon"
	}
	self.definitions.m1903 = {
		factory_id = "wpn_fps_snp_m1903",
		weapon_id = "m1903",
		category = "weapon"
	}
	self.definitions.m1912 = {
		factory_id = "wpn_fps_sho_m1912",
		weapon_id = "m1912",
		category = "weapon"
	}
	self.definitions.mp38 = {
		free = true,
		factory_id = "wpn_fps_smg_mp38",
		weapon_id = "mp38",
		category = "weapon"
	}
	self.definitions.mp44 = {
		free = true,
		factory_id = "wpn_fps_ass_mp44",
		weapon_id = "mp44",
		category = "weapon"
	}
	self.definitions.carbine = {
		free = true,
		factory_id = "wpn_fps_ass_carbine",
		weapon_id = "carbine",
		category = "weapon"
	}
	self.definitions.mg42 = {
		factory_id = "wpn_fps_lmg_mg42",
		weapon_id = "mg42",
		category = "weapon"
	}
	self.definitions.c96 = {
		factory_id = "wpn_fps_pis_c96",
		weapon_id = "c96",
		category = "weapon"
	}
	self.definitions.webley = {
		factory_id = "wpn_fps_pis_webley",
		weapon_id = "webley",
		category = "weapon"
	}
	self.definitions.mosin = {
		factory_id = "wpn_fps_snp_mosin",
		weapon_id = "mosin",
		category = "weapon"
	}
	self.definitions.sterling = {
		factory_id = "wpn_fps_smg_sterling",
		weapon_id = "sterling",
		category = "weapon"
	}
	self.definitions.geco = {
		free = true,
		factory_id = "wpn_fps_sho_geco",
		weapon_id = "geco",
		category = "weapon"
	}
end

function UpgradesTweakData:_create_melee_weapon_definitions()
	self.definitions.weapon = {
		category = "melee_weapon"
	}
	self.definitions.fists = {
		category = "melee_weapon"
	}
	self.definitions.m3_knife = {
		category = "melee_weapon"
	}
	self.definitions.robbins_dudley_trench_push_dagger = {
		category = "melee_weapon"
	}
	self.definitions.german_brass_knuckles = {
		category = "melee_weapon"
	}
	self.definitions.lockwood_brothers_push_dagger = {
		category = "melee_weapon"
	}
	self.definitions.bc41_knuckle_knife = {
		category = "melee_weapon"
	}
	self.definitions.km_dagger = {
		category = "melee_weapon"
	}
	self.definitions.marching_mace = {
		category = "melee_weapon"
	}
	self.definitions.lc14b = {
		category = "melee_weapon"
	}
end

function UpgradesTweakData:_create_grenades_definitions()
	self.definitions.m24 = {
		category = "grenade"
	}
	self.definitions.concrete = {
		category = "grenade"
	}
	self.definitions.d343 = {
		category = "grenade"
	}
	self.definitions.mills = {
		category = "grenade"
	}
	self.definitions.decoy_coin = {
		category = "grenade"
	}
	self.definitions.betty = {
		category = "grenade"
	}
end

function UpgradesTweakData:_primary_weapon_definitions()
	self.values.primary_weapon = self.values.primary_weapon or {}
	self.values.primary_weapon.damage_multiplier = {
		1.1,
		1.2,
		1.3,
		1.4,
		1.5
	}

	self:_create_definition_levels("primary_weapon_damage_multiplier", "feature", "damage_multiplier", "primary_weapon", false, self.values.primary_weapon.damage_multiplier)

	self.values.primary_weapon.recoil_reduction = {
		0.95,
		0.9,
		0.85,
		0.8,
		0.7
	}

	self:_create_definition_levels("primary_weapon_recoil_reduction", "feature", "recoil_reduction", "primary_weapon", false, self.values.primary_weapon.recoil_reduction)

	self.values.primary_weapon.reload_speed_multiplier = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("primary_weapon_reload_speed_multiplier", "feature", "reload_speed_multiplier", "primary_weapon", true, self.values.primary_weapon.reload_speed_multiplier, self.description_data_types.generic_multiplier)

	self.values.primary_weapon.enter_steelsight_speed_multiplier = {
		1.15,
		1.3,
		1.45,
		1.6,
		1.75
	}

	self:_create_definition_levels("primary_weapon_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "primary_weapon", false, self.values.primary_weapon.enter_steelsight_speed_multiplier)

	self.values.primary_weapon.spread_multiplier = {
		0.75,
		0.65,
		0.55,
		0.45,
		1.15,
		1.3,
		1.4,
		1.5
	}

	self:_create_definition_levels("primary_weapon_spread_multiplier", "feature", "spread_multiplier", "primary_weapon", false, self.values.primary_weapon.spread_multiplier)

	self.values.primary_weapon.magazine_upgrade = {
		4,
		6,
		8,
		11,
		30
	}

	self:_create_definition_levels("primary_weapon_magazine_upgrade", "feature", "magazine_upgrade", "primary_weapon", false, self.values.primary_weapon.magazine_upgrade)
end

function UpgradesTweakData:_secondary_weapon_definitions()
	self.values.secondary_weapon = self.values.secondary_weapon or {}
	self.values.secondary_weapon.damage_multiplier = {
		1.1,
		1.2,
		1.3,
		1.4,
		1.5
	}

	self:_create_definition_levels("secondary_weapon_damage_multiplier", "feature", "damage_multiplier", "secondary_weapon", false, self.values.secondary_weapon.damage_multiplier)

	self.values.secondary_weapon.recoil_reduction = {
		0.95,
		0.9,
		0.85,
		0.8,
		0.7
	}

	self:_create_definition_levels("secondary_weapon_recoil_reduction", "feature", "recoil_reduction", "secondary_weapon", false, self.values.secondary_weapon.recoil_reduction)

	self.values.secondary_weapon.reload_speed_multiplier = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("secondary_weapon_reload_speed_multiplier", "feature", "reload_speed_multiplier", "secondary_weapon", true, self.values.secondary_weapon.reload_speed_multiplier, self.description_data_types.generic_multiplier)

	self.values.secondary_weapon.enter_steelsight_speed_multiplier = {
		1.25,
		1.35,
		1.5,
		1.9,
		2.25
	}

	self:_create_definition_levels("secondary_weapon_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "secondary_weapon", false, self.values.secondary_weapon.enter_steelsight_speed_multiplier)

	self.values.secondary_weapon.spread_multiplier = {
		0.75,
		0.65,
		0.55,
		0.45,
		1.15,
		1.3,
		1.4,
		1.5
	}

	self:_create_definition_levels("secondary_weapon_spread_multiplier", "feature", "spread_multiplier", "secondary_weapon", false, self.values.secondary_weapon.spread_multiplier)

	self.values.secondary_weapon.magazine_upgrade = {
		5,
		8,
		13,
		16,
		23
	}

	self:_create_definition_levels("secondary_weapon_magazine_upgrade", "feature", "magazine_upgrade", "secondary_weapon", false, self.values.secondary_weapon.magazine_upgrade)
end

function UpgradesTweakData:_pistol_definitions()
	self.values.pistol = self.values.pistol or {}
	self.values.pistol.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("pistol_recoil_reduction", "feature", "recoil_reduction", "pistol", false, self.values.pistol.recoil_reduction)

	self.values.pistol.reload_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("pistol_reload_speed_multiplier", "feature", "reload_speed_multiplier", "pistol", false, self.values.pistol.reload_speed_multiplier)

	self.values.pistol.damage_multiplier = {
		1.1,
		1.2
	}

	self:_create_definition_levels("pistol_damage_multiplier", "feature", "damage_multiplier", "pistol", false, self.values.pistol.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.pistol.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("pistol_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "pistol", false, self.values.pistol.enter_steelsight_speed_multiplier)

	self.values.pistol.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("pistol_spread_multiplier", "feature", "spread_multiplier", "pistol", false, self.values.pistol.spread_multiplier)

	self.values.pistol.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("pistol_fire_rate_multiplier", "feature", "fire_rate_multiplier", "pistol", false, self.values.pistol.fire_rate_multiplier)

	self.values.pistol.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("pistol_exit_run_speed_multiplier", "feature", "exit_run_speed_multiplier", "pistol", false, self.values.pistol.exit_run_speed_multiplier)

	self.values.pistol.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("pistol_hip_fire_spread_multiplier", "feature", "hip_fire_spread_multiplier", "pistol", false, self.values.pistol.hip_fire_spread_multiplier)

	self.values.pistol.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("pistol_hip_fire_damage_multiplier", "feature", "hip_fire_damage_multiplier", "pistol", false, self.values.pistol.hip_fire_damage_multiplier)

	self.values.pistol.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("pistol_swap_speed_multiplier", "feature", "swap_speed_multiplier", "pistol", false, self.values.pistol.swap_speed_multiplier)

	self.values.pistol.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("pistol_stacking_hit_damage_multiplier", "feature", "stacking_hit_damage_multiplier", "pistol", false, self.values.pistol.stacking_hit_damage_multiplier)

	self.values.pistol.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("pistol_stacking_hit_expire_t", "feature", "stacking_hit_expire_t", "pistol", false, self.values.pistol.stacking_hit_expire_t)

	self.values.pistol.damage_addend = {
		1.5
	}

	self:_create_definition_levels("pistol_damage_addend", "feature", "damage_addend", "pistol", false, self.values.pistol.damage_addend)
end

function UpgradesTweakData:_assault_rifle_definitions()
	self.values.assault_rifle.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("assault_rifle_recoil_reduction", "feature", "recoil_reduction", "assault_rifle", false, self.values.assault_rifle.recoil_reduction)

	self.values.assault_rifle.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("assault_rifle_recoil_multiplier", "feature", "recoil_multiplier", "assault_rifle", false, self.values.assault_rifle.recoil_multiplier)

	self.values.assault_rifle.reload_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("assault_rifle_reload_speed_multiplier", "feature", "reload_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.reload_speed_multiplier)

	self.values.assault_rifle.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("assault_rifle_damage_multiplier", "feature", "damage_multiplier", "assault_rifle", false, self.values.assault_rifle.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.assault_rifle.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("assault_rifle_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.enter_steelsight_speed_multiplier)

	self.values.assault_rifle.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("assault_rifle_spread_multiplier", "feature", "spread_multiplier", "assault_rifle", false, self.values.assault_rifle.spread_multiplier)

	self.values.assault_rifle.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("assault_rifle_fire_rate_multiplier", "feature", "fire_rate_multiplier", "assault_rifle", false, self.values.assault_rifle.fire_rate_multiplier)

	self.values.assault_rifle.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("assault_rifle_exit_run_speed_multiplier", "feature", "exit_run_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.exit_run_speed_multiplier)

	self.values.assault_rifle.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("assault_rifle_hip_fire_spread_multiplier", "feature", "hip_fire_spread_multiplier", "assault_rifle", false, self.values.assault_rifle.hip_fire_spread_multiplier)

	self.values.assault_rifle.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("assault_rifle_hip_fire_damage_multiplier", "feature", "hip_fire_damage_multiplier", "assault_rifle", false, self.values.assault_rifle.hip_fire_damage_multiplier)

	self.values.assault_rifle.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("assault_rifle_swap_speed_multiplier", "feature", "swap_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.swap_speed_multiplier)

	self.values.assault_rifle.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("assault_rifle_stacking_hit_damage_multiplier", "feature", "stacking_hit_damage_multiplier", "assault_rifle", false, self.values.assault_rifle.stacking_hit_damage_multiplier)

	self.values.assault_rifle.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("assault_rifle_stacking_hit_expire_t", "feature", "stacking_hit_expire_t", "assault_rifle", false, self.values.assault_rifle.stacking_hit_expire_t)

	self.values.assault_rifle.damage_addend = {
		1.5
	}

	self:_create_definition_levels("assault_rifle_damage_addend", "feature", "damage_addend", "assault_rifle", false, self.values.assault_rifle.damage_addend)

	self.values.assault_rifle.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("assault_rifle_move_spread_multiplier", "feature", "move_spread_multiplier", "assault_rifle", false, self.values.assault_rifle.move_spread_multiplier)

	self.values.assault_rifle.zoom_increase = {
		2
	}

	self:_create_definition_levels("assault_rifle_zoom_increase", "feature", "zoom_increase", "assault_rifle", false, self.values.assault_rifle.zoom_increase)
end

function UpgradesTweakData:_lmg_definitions()
	self.values.lmg.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("lmg_recoil_reduction", "feature", "recoil_reduction", "lmg", false, self.values.lmg.recoil_reduction)

	self.values.lmg.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("lmg_recoil_multiplier", "feature", "recoil_multiplier", "lmg", false, self.values.lmg.recoil_multiplier)

	self.values.lmg.reload_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("lmg_reload_speed_multiplier", "feature", "reload_speed_multiplier", "lmg", false, self.values.lmg.reload_speed_multiplier)

	self.values.lmg.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("lmg_damage_multiplier", "feature", "damage_multiplier", "lmg", false, self.values.lmg.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.lmg.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("lmg_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "lmg", false, self.values.lmg.enter_steelsight_speed_multiplier)

	self.values.lmg.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("lmg_spread_multiplier", "feature", "spread_multiplier", "lmg", false, self.values.lmg.spread_multiplier)

	self.values.lmg.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("lmg_fire_rate_multiplier", "feature", "fire_rate_multiplier", "lmg", false, self.values.lmg.fire_rate_multiplier)

	self.values.lmg.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("lmg_exit_run_speed_multiplier", "feature", "exit_run_speed_multiplier", "lmg", false, self.values.lmg.exit_run_speed_multiplier)

	self.values.lmg.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("lmg_hip_fire_spread_multiplier", "feature", "hip_fire_spread_multiplier", "lmg", false, self.values.lmg.hip_fire_spread_multiplier)

	self.values.lmg.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("lmg_hip_fire_damage_multiplier", "feature", "hip_fire_damage_multiplier", "lmg", false, self.values.lmg.hip_fire_damage_multiplier)

	self.values.lmg.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("lmg_swap_speed_multiplier", "feature", "swap_speed_multiplier", "lmg", false, self.values.lmg.swap_speed_multiplier)

	self.values.lmg.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("lmg_stacking_hit_damage_multiplier", "feature", "stacking_hit_damage_multiplier", "lmg", false, self.values.lmg.stacking_hit_damage_multiplier)

	self.values.lmg.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("lmg_stacking_hit_expire_t", "feature", "stacking_hit_expire_t", "lmg", false, self.values.lmg.stacking_hit_expire_t)

	self.values.lmg.damage_addend = {
		1.5
	}

	self:_create_definition_levels("lmg_damage_addend", "feature", "damage_addend", "lmg", false, self.values.lmg.damage_addend)

	self.values.lmg.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("lmg_move_spread_multiplier", "feature", "move_spread_multiplier", "lmg", false, self.values.lmg.move_spread_multiplier)

	self.values.lmg.zoom_increase = {
		2
	}

	self:_create_definition_levels("lmg_zoom_increase", "feature", "zoom_increase", "lmg", false, self.values.lmg.zoom_increase)
end

function UpgradesTweakData:_snp_definitions()
	self.values.snp.recoil_reduction = {
		0.9,
		0.8,
		0.7
	}

	self:_create_definition_levels("snp_recoil_reduction", "feature", "recoil_reduction", "snp", false, self.values.snp.recoil_reduction)

	self.values.snp.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("snp_recoil_multiplier", "feature", "recoil_multiplier", "snp", false, self.values.snp.recoil_multiplier)

	self.values.snp.reload_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("snp_reload_speed_multiplier", "feature", "reload_speed_multiplier", "snp", false, self.values.snp.reload_speed_multiplier)

	self.values.snp.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("snp_damage_multiplier", "feature", "damage_multiplier", "snp", false, self.values.snp.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.snp.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("snp_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "snp", false, self.values.snp.enter_steelsight_speed_multiplier)

	self.values.snp.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("snp_spread_multiplier", "feature", "spread_multiplier", "snp", false, self.values.snp.spread_multiplier)

	self.values.snp.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("snp_fire_rate_multiplier", "feature", "fire_rate_multiplier", "snp", false, self.values.snp.fire_rate_multiplier)

	self.values.snp.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("snp_exit_run_speed_multiplier", "feature", "exit_run_speed_multiplier", "snp", false, self.values.snp.exit_run_speed_multiplier)

	self.values.snp.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("snp_hip_fire_spread_multiplier", "feature", "hip_fire_spread_multiplier", "snp", false, self.values.snp.hip_fire_spread_multiplier)

	self.values.snp.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("snp_hip_fire_damage_multiplier", "feature", "hip_fire_damage_multiplier", "snp", false, self.values.snp.hip_fire_damage_multiplier)

	self.values.snp.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("snp_swap_speed_multiplier", "feature", "swap_speed_multiplier", "snp", false, self.values.snp.swap_speed_multiplier)

	self.values.snp.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("snp_stacking_hit_damage_multiplier", "feature", "stacking_hit_damage_multiplier", "snp", false, self.values.snp.stacking_hit_damage_multiplier)

	self.values.snp.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("snp_stacking_hit_expire_t", "feature", "stacking_hit_expire_t", "snp", false, self.values.snp.stacking_hit_expire_t)

	self.values.snp.damage_addend = {
		1.5
	}

	self:_create_definition_levels("snp_damage_addend", "feature", "damage_addend", "snp", false, self.values.snp.damage_addend)

	self.values.snp.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("snp_move_spread_multiplier", "feature", "move_spread_multiplier", "snp", false, self.values.snp.move_spread_multiplier)

	self.values.snp.zoom_increase = {
		2
	}

	self:_create_definition_levels("snp_zoom_increase", "feature", "zoom_increase", "snp", false, self.values.snp.zoom_increase)
end

function UpgradesTweakData:_smg_definitions()
	self.values.smg.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("smg_recoil_reduction", "feature", "recoil_reduction", "smg", false, self.values.smg.recoil_reduction)

	self.values.smg.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("smg_recoil_multiplier", "feature", "recoil_multiplier", "smg", false, self.values.smg.recoil_multiplier)

	self.values.smg.reload_speed_multiplier = {
		1.35
	}

	self:_create_definition_levels("smg_reload_speed_multiplier", "feature", "reload_speed_multiplier", "smg", false, self.values.smg.reload_speed_multiplier)

	self.values.smg.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("smg_damage_multiplier", "feature", "damage_multiplier", "smg", false, self.values.smg.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.smg.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("smg_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "smg", false, self.values.smg.enter_steelsight_speed_multiplier)

	self.values.smg.spread_multiplier = {
		0.9,
		0.8
	}

	self:_create_definition_levels("smg_spread_multiplier", "feature", "spread_multiplier", "smg", false, self.values.smg.spread_multiplier)

	self.values.smg.fire_rate_multiplier = {
		1.2
	}

	self:_create_definition_levels("smg_fire_rate_multiplier", "feature", "fire_rate_multiplier", "smg", false, self.values.smg.fire_rate_multiplier)

	self.values.smg.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("smg_exit_run_speed_multiplier", "feature", "exit_run_speed_multiplier", "smg", false, self.values.smg.exit_run_speed_multiplier)

	self.values.smg.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("smg_hip_fire_spread_multiplier", "feature", "hip_fire_spread_multiplier", "smg", false, self.values.smg.hip_fire_spread_multiplier)

	self.values.smg.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("smg_hip_fire_damage_multiplier", "feature", "hip_fire_damage_multiplier", "smg", false, self.values.smg.hip_fire_damage_multiplier)

	self.values.smg.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("smg_swap_speed_multiplier", "feature", "swap_speed_multiplier", "smg", false, self.values.smg.swap_speed_multiplier)

	self.values.smg.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("smg_stacking_hit_damage_multiplier", "feature", "stacking_hit_damage_multiplier", "smg", false, self.values.smg.stacking_hit_damage_multiplier)

	self.values.smg.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("smg_stacking_hit_expire_t", "feature", "stacking_hit_expire_t", "smg", false, self.values.smg.stacking_hit_expire_t)

	self.values.smg.damage_addend = {
		1.5
	}

	self:_create_definition_levels("smg_damage_addend", "feature", "damage_addend", "smg", false, self.values.smg.damage_addend)

	self.values.smg.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("smg_move_spread_multiplier", "feature", "move_spread_multiplier", "smg", false, self.values.smg.move_spread_multiplier)

	self.values.smg.zoom_increase = {
		2
	}

	self:_create_definition_levels("smg_zoom_increase", "feature", "zoom_increase", "smg", false, self.values.smg.zoom_increase)
end

function UpgradesTweakData:_shotgun_definitions()
	self.values.shotgun.recoil_reduction = {
		0.85,
		0.75
	}

	self:_create_definition_levels("shotgun_recoil_reduction", "feature", "recoil_reduction", "shotgun", false, self.values.shotgun.recoil_reduction)

	self.values.shotgun.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("shotgun_recoil_multiplier", "feature", "recoil_multiplier", "shotgun", false, self.values.shotgun.recoil_multiplier)

	self.values.shotgun.reload_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("shotgun_reload_speed_multiplier", "feature", "reload_speed_multiplier", "shotgun", false, self.values.shotgun.reload_speed_multiplier)

	self.values.shotgun.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("shotgun_damage_multiplier", "feature", "damage_multiplier", "shotgun", false, self.values.shotgun.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.shotgun.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("shotgun_enter_steelsight_speed_multiplier", "feature", "enter_steelsight_speed_multiplier", "shotgun", false, self.values.shotgun.enter_steelsight_speed_multiplier)

	self.values.shotgun.spread_multiplier = {
		1.1
	}

	self:_create_definition_levels("shotgun_spread_multiplier", "feature", "spread_multiplier", "shotgun", false, self.values.shotgun.spread_multiplier)

	self.values.shotgun.fire_rate_multiplier = {
		1.2
	}

	self:_create_definition_levels("shotgun_fire_rate_multiplier", "feature", "fire_rate_multiplier", "shotgun", false, self.values.shotgun.fire_rate_multiplier)

	self.values.shotgun.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("shotgun_exit_run_speed_multiplier", "feature", "exit_run_speed_multiplier", "shotgun", false, self.values.shotgun.exit_run_speed_multiplier)

	self.values.shotgun.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("shotgun_hip_fire_spread_multiplier", "feature", "hip_fire_spread_multiplier", "shotgun", false, self.values.shotgun.hip_fire_spread_multiplier)

	self.values.shotgun.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("shotgun_hip_fire_damage_multiplier", "feature", "hip_fire_damage_multiplier", "shotgun", false, self.values.shotgun.hip_fire_damage_multiplier)

	self.values.shotgun.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("shotgun_swap_speed_multiplier", "feature", "swap_speed_multiplier", "shotgun", false, self.values.shotgun.swap_speed_multiplier)

	self.values.shotgun.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("shotgun_stacking_hit_damage_multiplier", "feature", "stacking_hit_damage_multiplier", "shotgun", false, self.values.shotgun.stacking_hit_damage_multiplier)

	self.values.shotgun.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("shotgun_stacking_hit_expire_t", "feature", "stacking_hit_expire_t", "shotgun", false, self.values.shotgun.stacking_hit_expire_t)

	self.values.shotgun.damage_addend = {
		1.5
	}

	self:_create_definition_levels("shotgun_damage_addend", "feature", "damage_addend", "shotgun", false, self.values.shotgun.damage_addend)

	self.values.shotgun.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("shotgun_move_spread_multiplier", "feature", "move_spread_multiplier", "shotgun", false, self.values.shotgun.move_spread_multiplier)

	self.values.shotgun.zoom_increase = {
		2
	}

	self:_create_definition_levels("shotgun_zoom_increase", "feature", "zoom_increase", "shotgun", false, self.values.shotgun.zoom_increase)

	self.values.shotgun.consume_no_ammo_chance = {
		0.01,
		0.03
	}

	self:_create_definition_levels("shotgun_consume_no_ammo_chance", "feature", "consume_no_ammo_chance", "shotgun", false, self.values.shotgun.consume_no_ammo_chance)

	self.values.shotgun.melee_knockdown_mul = {
		1.75
	}

	self:_create_definition_levels("shotgun_melee_knockdown_mul", "feature", "melee_knockdown_mul", "shotgun", false, self.values.shotgun.melee_knockdown_mul)
end

function UpgradesTweakData:_create_definition_levels(definition_name, definition_category, upgrade_name, upgrade_category, incremental, values, description_data)
	for index = 1, #values do
		local definition_name_level = definition_name .. "_" .. index
		local name_id = "menu_" .. definition_name

		self:_create_definition(definition_name_level, definition_category, upgrade_name, upgrade_category, incremental, index, true, description_data)
	end
end

function UpgradesTweakData:_create_definition(definition_name, definition_category, upgrade_name, upgrade_category, incremental, value, has_levels, description_data)
	local name_id = "menu_" .. upgrade_category .. "_" .. upgrade_name
	local definition = {
		category = definition_category,
		incremental = incremental,
		description_data = description_data,
		has_levels = has_levels or false,
		name_id = name_id,
		upgrade = {
			category = upgrade_category,
			upgrade = upgrade_name,
			value = value
		}
	}
	self.definitions[definition_name] = definition
end

function UpgradesTweakData:upgrade_has_levels(definition_name)
	local definition = self.definitions[definition_name] or self.definitions[definition_name .. "_1"]

	if definition and definition.has_levels == true then
		return true
	end

	return false
end

function UpgradesTweakData:_init_pd2_values()
	self.values.player.marked_enemy_damage_mul = 1.15
	self.values.player.immune_to_gas = {
		true
	}
	self.values.player.knockdown = {
		true
	}
	self.values.weapon.passive_headshot_damage_multiplier = {
		1.25
	}
	self.values.player.special_enemy_highlight = {
		true
	}
	self.values.player.hostage_trade = {
		true
	}
	self.values.player.sec_camera_highlight = {
		true
	}
	self.values.player.sec_camera_highlight_mask_off = {
		true
	}
	self.values.player.special_enemy_highlight_mask_off = {
		true
	}
	self.values.rep_upgrades = {
		classes = {
			"rep_upgrade"
		},
		values = {
			2
		}
	}
	self.values.player.body_armor = {
		armor = {
			0,
			1,
			2,
			3,
			5,
			7,
			15
		},
		movement = {
			1.05,
			1.025,
			1,
			0.95,
			0.75,
			0.65,
			0.575
		},
		concealment = {
			30,
			26,
			23,
			21,
			18,
			12,
			1
		},
		dodge = {
			0.1,
			-0.2,
			-0.25,
			-0.3,
			-0.35,
			-0.4,
			-0.5
		},
		damage_shake = {
			1,
			0.96,
			0.92,
			0.85,
			0.8,
			0.7,
			0.5
		},
		stamina = {
			1.025,
			1,
			0.95,
			0.9,
			0.85,
			0.8,
			0.7
		},
		skill_ammo_mul = {
			1,
			1.02,
			1.04,
			1.06,
			1.8,
			1.1,
			1.12
		}
	}
	self.ammo_bag_base = 3
	self.ecm_jammer_base_battery_life = 20
	self.ecm_jammer_base_low_battery_life = 8
	self.ecm_jammer_base_range = 2500
	self.ecm_feedback_min_duration = 15
	self.ecm_feedback_max_duration = 20
	self.ecm_feedback_interval = 1.5
	self.sentry_gun_base_ammo = 150
	self.sentry_gun_base_armor = 10
	self.doctor_bag_base = 2
	self.grenade_crate_base = 3
	self.max_grenade_amount = 3
	self.bodybag_crate_base = 3
	self.cop_hurt_alert_radius_whisper = 600
	self.cop_hurt_alert_radius = 400
	self.drill_alert_radius = 2500
	self.taser_malfunction_min = 1
	self.taser_malfunction_max = 3
	self.counter_taser_damage = 0.5
	self.morale_boost_speed_bonus = 1.2
	self.morale_boost_suppression_resistance = 1
	self.morale_boost_time = 10
	self.morale_boost_reload_speed_bonus = 1.2
	self.morale_boost_base_cooldown = 3.5
	self.max_weapon_dmg_mul_stacks = 4
	self.max_melee_weapon_dmg_mul_stacks = 4
	self.hostage_near_player_radius = 1000
	self.hostage_near_player_check_t = 0.5
	self.hostage_near_player_multiplier = 1.25
	self.hostage_max_num = {
		damage_dampener = 1,
		health_regen = 1,
		stamina = 10,
		health = 10
	}
	self.on_headshot_dealt_cooldown = 2
	self.on_killshot_cooldown = 2
	self.on_damage_dealt_cooldown = 2
	self.close_combat_distance = 1800
	self.killshot_close_panic_range = 900
	self.berserker_movement_speed_multiplier = 0.4
	self.weapon_cost_multiplier = {
		akimbo = 1.4
	}
	self.weapon_movement_penalty = {
		lmg = 1,
		minigun = 1
	}
	self.explosive_bullet = {
		curve_pow = 0.5,
		player_dmg_mul = 0.1,
		range = 200
	}
	self.explosive_bullet.feedback_range = self.explosive_bullet.range
	self.explosive_bullet.camera_shake_max_mul = 2
	self.values.player.crime_net_deal = {
		0.9,
		0.8
	}
	self.values.player.corpse_alarm_pager_bluff = {
		true
	}
	self.values.player.marked_enemy_extra_damage = {
		true
	}
	self.values.cable_tie.interact_speed_multiplier = {
		0.25
	}
	self.values.cable_tie.quantity_1 = {
		4
	}
	self.values.cable_tie.can_cable_tie_doors = {
		true
	}
	self.values.temporary.combat_medic_damage_multiplier = {
		{
			1.25,
			10
		},
		{
			1.25,
			15
		}
	}
	self.values.player.revive_health_boost = {
		1
	}
	self.revive_health_multiplier = {
		1.3
	}
	self.values.player.civ_harmless_bullets = {
		true
	}
	self.values.player.civ_harmless_melee = {
		true
	}
	self.values.player.civ_calming_alerts = {
		true
	}
	self.values.player.civ_intimidation_mul = {
		1.5
	}
	self.values.team.pistol.recoil_multiplier = {
		0.75
	}
	self.values.team.akimbo.recoil_multiplier = self.values.team.pistol.recoil_multiplier
	self.values.team.weapon.recoil_multiplier = {
		0.5
	}
	self.values.team.pistol.suppression_recoil_multiplier = self.values.team.pistol.recoil_multiplier
	self.values.team.akimbo.suppression_recoil_multiplier = self.values.team.akimbo.recoil_multiplier
	self.values.team.weapon.suppression_recoil_multiplier = self.values.team.weapon.recoil_multiplier
	self.values.player.assets_cost_multiplier = {
		0.5
	}
	self.values.player.additional_assets = {
		true
	}
	self.values.team.stamina.multiplier = {
		1.5
	}
	self.values.player.intimidate_enemies = {
		true
	}
	self.values.player.intimidate_range_mul = {
		1.5
	}
	self.values.player.intimidate_aura = {
		700
	}
	self.values.player.civilian_reviver = {
		true
	}
	self.values.player.civilian_gives_ammo = {
		true
	}
	self.values.player.buy_cost_multiplier = {
		0.9,
		0.7
	}
	self.values.player.sell_cost_multiplier = {
		1.25
	}
	self.values.doctor_bag.quantity = {
		1
	}
	self.values.doctor_bag.amount_increase = {
		2
	}
	self.values.player.convert_enemies = {
		true
	}
	self.values.player.convert_enemies_max_minions = {
		1,
		2
	}
	self.values.player.convert_enemies_health_multiplier = {
		0.65
	}
	self.values.player.convert_enemies_damage_multiplier = {
		1.45
	}
	self.values.player.xp_multiplier = {
		1.15
	}
	self.values.team.xp.multiplier = {
		1.3
	}
	self.values.akimbo.reload_speed_multiplier = self.values.pistol.reload_speed_multiplier
	self.values.akimbo.damage_addend = {
		0.75
	}
	self.values.assault_rifle.move_spread_multiplier = {
		0.5
	}
	self.values.akimbo.spread_multiplier = self.values.pistol.spread_multiplier
	self.values.akimbo.swap_speed_multiplier = self.values.pistol.swap_speed_multiplier
	self.values.akimbo.fire_rate_multiplier = self.values.pistol.fire_rate_multiplier
	self.values.doctor_bag.interaction_speed_multiplier = {
		0.8
	}
	self.values.team.stamina.passive_multiplier = {
		1.5,
		1.3
	}
	self.values.player.passive_intimidate_range_mul = {
		1.25
	}
	self.values.team.health.passive_multiplier = {
		1.1
	}
	self.values.player.passive_convert_enemies_health_multiplier = {
		0.25
	}
	self.values.player.passive_convert_enemies_damage_multiplier = {
		1.15
	}
	self.values.player.convert_enemies_interaction_speed_multiplier = {
		0.35
	}
	self.values.player.empowered_intimidation_mul = {
		3
	}
	self.values.player.passive_assets_cost_multiplier = {
		0.5
	}
	self.values.player.suppression_multiplier = {
		1.25,
		1.75
	}
	self.values.carry.movement_speed_multiplier = {
		1.5
	}
	self.values.carry.throw_distance_multiplier = {
		1.5
	}
	self.values.temporary.no_ammo_cost = {
		{
			true,
			5
		},
		{
			true,
			15
		}
	}
	self.values.player.primary_weapon_when_downed = {
		true
	}
	self.values.player.armor_regen_timer_multiplier = {
		0.85
	}
	self.values.temporary.dmg_multiplier_outnumbered = {
		{
			1.15,
			7
		}
	}
	self.values.temporary.dmg_dampener_outnumbered = {
		{
			0.85,
			7
		}
	}
	self.values.player.extra_ammo_multiplier = {
		1.25
	}
	self.values.player.damage_shake_multiplier = {
		0.5
	}
	self.values.player.bleed_out_health_multiplier = {
		1.25
	}
	self.values.ammo_bag.quantity = {
		1
	}
	self.values.ammo_bag.ammo_increase = {
		2
	}
	self.values.saw.extra_ammo_multiplier = {
		1.5
	}
	self.values.player.flashbang_multiplier = {
		0.75,
		0.25
	}
	self.values.player.saw_speed_multiplier = {
		0.95,
		0.65
	}
	self.values.saw.lock_damage_multiplier = {
		1.2,
		1.4
	}
	self.values.saw.enemy_slicer = {
		true
	}
	self.values.player.melee_damage_health_ratio_multiplier = {
		2.5
	}
	self.values.player.damage_health_ratio_multiplier = {
		1
	}
	self.player_damage_health_ratio_threshold = 0.25
	self.values.player.shield_knock = {
		true
	}
	self.values.temporary.overkill_damage_multiplier = {
		{
			1.75,
			5
		}
	}
	self.values.player.overkill_all_weapons = {
		true
	}
	self.values.player.passive_suppression_multiplier = {
		1.1,
		1.2
	}
	self.values.player.passive_health_multiplier = {
		1.1,
		1.2,
		1.4,
		1.8
	}
	self.values.weapon.passive_damage_multiplier = {
		1.05
	}
	self.values.player.crafting_weapon_multiplier = {
		0.9
	}
	self.values.player.crafting_mask_multiplier = {
		0.9
	}
	self.values.trip_mine.quantity_1 = {
		1
	}
	self.values.trip_mine.can_switch_on_off = {
		true
	}
	self.values.player.drill_speed_multiplier = {
		0.85,
		0.7
	}
	self.values.player.trip_mine_deploy_time_multiplier = {
		0.8,
		0.6
	}
	self.values.trip_mine.sensor_toggle = {
		true
	}
	self.values.player.drill_fix_interaction_speed_multiplier = {
		0.75
	}
	self.values.player.drill_autorepair = {
		0.3
	}
	self.values.player.sentry_gun_deploy_time_multiplier = {
		0.5
	}
	self.values.sentry_gun.armor_multiplier = {
		2.5
	}
	self.values.weapon.single_spread_multiplier = {
		0.8
	}
	self.values.player.taser_malfunction = {
		true
	}
	self.values.player.taser_self_shock = {
		true
	}
	self.values.sentry_gun.spread_multiplier = {
		0.5
	}
	self.values.sentry_gun.rot_speed_multiplier = {
		2.5
	}
	self.values.player.steelsight_when_downed = {
		true
	}
	self.values.player.drill_alert_rad = {
		900
	}
	self.values.player.silent_drill = {
		true
	}
	self.values.sentry_gun.extra_ammo_multiplier = {
		1.5,
		2.5
	}
	self.values.sentry_gun.shield = {
		true
	}
	self.values.trip_mine.explosion_size_multiplier_1 = {
		1.3
	}
	self.values.trip_mine.explosion_size_multiplier_2 = {
		1.7
	}
	self.values.trip_mine.quantity_3 = {
		3
	}
	self.values.player.trip_mine_shaped_charge = {
		true
	}
	self.values.sentry_gun.quantity = {
		1
	}
	self.values.sentry_gun.damage_multiplier = {
		4
	}
	self.values.weapon.clip_ammo_increase = {
		5,
		15
	}
	self.values.player.armor_multiplier = {
		1.5
	}
	self.values.team.armor.regen_time_multiplier = {
		0.75
	}
	self.values.player.passive_crafting_weapon_multiplier = {
		0.99,
		0.96,
		0.91
	}
	self.values.player.passive_crafting_mask_multiplier = {
		0.99,
		0.96,
		0.91
	}
	self.values.weapon.passive_recoil_multiplier = {
		0.95,
		0.9
	}
	self.values.player.passive_armor_multiplier = {
		1.1,
		1.25
	}
	self.values.team.armor.passive_regen_time_multiplier = {
		0.9
	}
	self.values.player.small_loot_multiplier = {
		1.1,
		1.3
	}
	self.values.player.run_dodge_chance = {
		0.25
	}
	self.values.player.fall_damage_multiplier = {
		0.25
	}
	self.values.player.fall_health_damage_multiplier = {
		0
	}
	self.values.player.respawn_time_multiplier = {
		0.5
	}
	self.values.weapon.special_damage_taken_multiplier = {
		1.05
	}
	self.values.player.buy_bodybags_asset = {
		true
	}
	self.values.player.corpse_dispose = {
		true
	}
	self.values.player.corpse_dispose_amount = {
		1,
		2
	}
	self.values.carry.interact_speed_multiplier = {
		0.75,
		0.25
	}
	self.values.player.suspicion_multiplier = {
		0.75
	}
	self.values.player.camouflage_bonus = {
		0.85
	}
	self.values.player.silent_kill = {
		25
	}
	self.values.player.melee_knockdown_mul = {
		1.5
	}
	self.values.player.damage_dampener = {
		0.95
	}
	self.values.player.melee_damage_dampener = {
		0.5
	}
	self.values.player.additional_lives = {
		1,
		3
	}
	self.values.player.cheat_death_chance = {
		0.35
	}
	self.values.ecm_jammer.can_activate_feedback = {
		true
	}
	self.values.ecm_jammer.feedback_duration_boost = {
		1.25
	}
	self.values.ecm_jammer.interaction_speed_multiplier = {
		0
	}
	self.values.weapon.silencer_damage_multiplier = {
		1.15,
		1.3
	}
	self.values.weapon.armor_piercing_chance_silencer = {
		0.2,
		0.4
	}
	self.values.ecm_jammer.duration_multiplier = {
		1.25
	}
	self.values.ecm_jammer.can_open_sec_doors = {
		true
	}
	self.values.player.pick_lock_easy = {
		true
	}
	self.values.player.pick_lock_easy_speed_multiplier = {
		0.75,
		0.5
	}
	self.values.player.pick_lock_hard = {
		true
	}
	self.values.weapon.silencer_recoil_multiplier = {
		0.5
	}
	self.values.weapon.silencer_spread_multiplier = {
		0.5
	}
	self.values.player.loot_drop_multiplier = {
		1.5,
		3
	}
	self.values.ecm_jammer.quantity = {
		1,
		3
	}
	self.values.ecm_jammer.duration_multiplier_2 = {
		1.25
	}
	self.values.ecm_jammer.feedback_duration_boost_2 = {
		1.25
	}
	self.values.ecm_jammer.affects_pagers = {
		true
	}
	self.values.player.can_strafe_run = {
		true
	}
	self.values.player.can_free_run = {
		true
	}
	self.values.ecm_jammer.affects_cameras = {
		true
	}
	self.values.player.passive_dodge_chance = {
		0.05,
		0.15,
		0.25
	}
	self.values.weapon.passive_swap_speed_multiplier = {
		1.8,
		2
	}
	self.values.player.passive_concealment_modifier = {
		1
	}
	self.values.player.passive_armor_movement_penalty_multiplier = {
		0.75
	}
	self.values.player.passive_loot_drop_multiplier = {
		1.1
	}
	self.values.weapon.armor_piercing_chance = {
		0.25
	}
	self.values.player.run_and_shoot = {
		true
	}
	self.values.player.run_and_reload = {
		true
	}
	self.values.player.morale_boost = {
		true
	}
	self.values.player.electrocution_resistance_multiplier = {
		0.25
	}
	self.values.player.concealment_modifier = {
		5,
		10,
		15
	}
	self.values.sentry_gun.armor_multiplier2 = {
		1.25
	}
	self.values.saw.armor_piercing_chance = {
		1
	}
	self.values.saw.swap_speed_multiplier = {
		1.5
	}
	self.values.saw.reload_speed_multiplier = {
		1.5
	}
	self.values.team.health.hostage_multiplier = {
		1.02
	}
	self.values.team.stamina.hostage_multiplier = {
		1.04
	}
	self.values.player.minion_master_speed_multiplier = {
		1.1
	}
	self.values.player.minion_master_health_multiplier = {
		1.2
	}
	self.values.player.mark_enemy_time_multiplier = {
		1
	}
	self.values.player.melee_kill_snatch_pager_chance = {
		0.25
	}
	self.values.player.detection_risk_add_crit_chance = {
		{
			0.03,
			3,
			"below",
			35,
			0.3
		},
		{
			0.03,
			1,
			"below",
			35,
			0.3
		}
	}
	self.values.player.detection_risk_add_dodge_chance = {
		{
			0.01,
			3,
			"below",
			35,
			0.1
		},
		{
			0.01,
			1,
			"below",
			35,
			0.1
		}
	}
	self.values.player.detection_risk_damage_multiplier = {
		{
			0.05,
			7,
			"above",
			40
		}
	}
	self.values.player.overkill_health_to_damage_multiplier = {
		0.66
	}
	self.values.player.tased_recover_multiplier = {
		0.5
	}
	self.values.player.secured_bags_speed_multiplier = {
		1.02
	}
	self.values.temporary.no_ammo_cost_buff = {
		{
			true,
			60
		}
	}
	self.values.player.secured_bags_money_multiplier = {
		1.02
	}
	self.values.carry.movement_penalty_nullifier = {
		true
	}
	self.values.temporary.berserker_damage_multiplier = {
		{
			1,
			3
		},
		{
			1,
			9
		}
	}
	self.values.player.berserker_no_ammo_cost = {
		true
	}
	self.values.player.hostage_health_regen_addend = {
		0.015,
		0.045
	}
	self.values.player.carry_sentry_and_trip = {
		true
	}
	self.values.player.tier_armor_multiplier = {
		1.05,
		1.1,
		1.2,
		1.3,
		1.15,
		1.35
	}
	self.values.saw.hip_fire_damage_multiplier = {
		1.2
	}
	self.values.player.add_armor_stat_skill_ammo_mul = {
		true
	}
	self.values.saw.melee_knockdown_mul = {
		1.75
	}
	self.values.player.assets_cost_multiplier_b = {
		0.5
	}
	self.values.player.premium_contract_cost_multiplier = {
		0.5
	}
	self.values.player.morale_boost_cooldown_multiplier = {
		0.5
	}
	self.values.player.level_interaction_timer_multiplier = {
		{
			0.01,
			10
		}
	}
	self.values.team.player.clients_buy_assets = {
		true
	}
	self.values.player.steelsight_normal_movement_speed = {
		true
	}
	self.values.team.weapon.move_spread_multiplier = {
		1.1
	}
	self.values.team.player.civ_intimidation_mul = {
		1.15
	}
	self.values.sentry_gun.can_revive = {
		true
	}
	self.values.sentry_gun.can_reload = {
		true
	}
	self.sentry_gun_reload_ratio = 1
	self.values.weapon.modded_damage_multiplier = {
		1.1
	}
	self.values.weapon.modded_spread_multiplier = {
		0.9
	}
	self.values.weapon.modded_recoil_multiplier = {
		0.9
	}
	self.values.sentry_gun.armor_piercing_chance = {
		0.15
	}
	self.values.sentry_gun.armor_piercing_chance_2 = {
		0.05
	}
	self.values.weapon.armor_piercing_chance_2 = {
		0.05
	}
	self.values.player.resist_firing_tased = {
		true
	}
	self.values.player.crouch_dodge_chance = {
		0.05,
		0.15
	}
	self.values.team.xp.stealth_multiplier = {
		1.5
	}
	self.values.team.cash.stealth_money_multiplier = {
		1.5
	}
	self.values.team.cash.stealth_bags_multiplier = {
		1.5
	}
	self.values.player.tape_loop_duration = {
		10,
		20
	}
	self.values.player.tape_loop_interact_distance_mul = {
		1.4
	}
	self.values.player.buy_spotter_asset = {
		true
	}
	self.values.player.close_to_hostage_boost = {
		true
	}
	self.values.trip_mine.sensor_highlight = {
		true
	}
	self.values.player.on_zipline_dodge_chance = {
		0.15
	}
	self.values.player.movement_speed_multiplier = {
		1.1
	}
	self.values.player.gangster_damage_dampener = {
		0.9,
		0.65
	}
	self.values.player.level_2_armor_addend = {
		2
	}
	self.values.player.level_3_armor_addend = {
		2
	}
	self.values.player.level_4_armor_addend = {
		2
	}
	self.values.player.level_2_dodge_addend = {
		0.1,
		0.2,
		0.35
	}
	self.values.player.level_3_dodge_addend = {
		0.1,
		0.2,
		0.35
	}
	self.values.player.level_4_dodge_addend = {
		0.1,
		0.2,
		0.35
	}
	self.values.player.damage_shake_addend = {
		1
	}
	self.values.player.melee_concealment_modifier = {
		2
	}
	self.values.player.melee_sharp_damage_multiplier = {
		3
	}
	self.values.team.armor.multiplier = {
		1.05
	}
	self.values.player.armor_regen_timer_multiplier_passive = {
		0.9
	}
	self.values.player.armor_regen_timer_multiplier_tier = {
		0.9
	}
	self.values.player.camouflage_multiplier = {
		0.85
	}
	self.values.player.uncover_multiplier = {
		1.15
	}
	self.values.player.passive_xp_multiplier = {
		1.45
	}
	self.values.team.damage_dampener.hostage_multiplier = {
		0.92
	}
	self.values.player.level_2_armor_multiplier = {
		1.2,
		1.4,
		1.65
	}
	self.values.player.level_3_armor_multiplier = {
		1.2,
		1.4,
		1.65
	}
	self.values.player.level_4_armor_multiplier = {
		1.2,
		1.4,
		1.65
	}
	self.values.player.passive_health_regen = {
		0.04
	}
	self.values.cable_tie.quantity_2 = {
		4
	}
	self.ecm_feedback_retrigger_interval = 240
	self.ecm_feedback_retrigger_chance = 1
	self.values.player.revive_damage_reduction_level = {
		1,
		2
	}
	self.values.trip_mine.marked_enemy_extra_damage = {
		true
	}
	self.values.ecm_jammer.can_retrigger = {
		true
	}
	self.values.player.panic_suppression = {
		true
	}
	self.values.akimbo.extra_ammo_multiplier = {
		1.25,
		1.5
	}
	self.values.akimbo.damage_multiplier = {
		1.5,
		3
	}
	self.values.akimbo.recoil_multiplier = {
		2.5,
		2,
		1.5
	}
	self.values.akimbo.passive_recoil_multiplier = {
		2.5,
		2
	}
	self.values.akimbo.clip_ammo_increase = self.values.weapon.clip_ammo_increase
	self.values.player.perk_armor_regen_timer_multiplier = {
		0.95,
		0.85,
		0.75,
		0.65,
		0.55
	}
	self.values.player.perk_armor_loss_multiplier = {
		0.95,
		0.9,
		0.85,
		0.8
	}
	self.values.player.headshot_regen_armor_bonus = {
		1.5,
		4.5
	}
	self.values.bodybags_bag.quantity = {
		1
	}
	self.values.first_aid_kit.quantity = {
		3,
		10
	}
	self.values.first_aid_kit.deploy_time_multiplier = {
		0.5
	}
	self.values.first_aid_kit.damage_reduction_upgrade = {
		true
	}
	self.values.first_aid_kit.downs_restore_chance = {
		0.1
	}
	self.values.temporary.first_aid_damage_reduction = {
		{
			0.8,
			10
		}
	}
	self.values.player.extra_corpse_dispose_amount = {
		1
	}
	self.values.player.standstill_omniscience = {
		true
	}
	self.values.player.mask_off_pickup = {
		true
	}
	self.values.player.cleaner_cost_multiplier = {
		0.25
	}
	self.values.player.counter_strike_melee = {
		true
	}
	self.values.player.counter_strike_spooc = {
		true
	}
	self.values.temporary.passive_revive_damage_reduction = {
		{
			0.9,
			5
		},
		{
			0.7,
			5
		}
	}
	self.values.player.passive_convert_enemies_health_multiplier = {
		0.6,
		0.2
	}
	self.values.player.armor_regen_timer_stand_still_multiplier = {
		0.8
	}
	self.values.player.tier_dodge_chance = {
		0.1,
		0.15,
		0.2
	}
	self.values.player.stand_still_crouch_camouflage_bonus = {
		0.9,
		0.85,
		0.8
	}
	self.values.player.corpse_dispose_speed_multiplier = {
		0.8
	}
	self.values.player.pick_lock_speed_multiplier = {
		0.8
	}
	self.values.player.alarm_pager_speed_multiplier = {
		0.9
	}
	self.values.temporary.melee_life_leech = {
		{
			0.2,
			10
		}
	}
	self.values.temporary.dmg_dampener_outnumbered_strong = {
		{
			0.92,
			7
		}
	}
	self.values.temporary.dmg_dampener_close_contact = {
		{
			0.92,
			7
		},
		{
			0.84,
			7
		},
		{
			0.76,
			7
		}
	}
	self.values.melee.stacking_hit_damage_multiplier = {
		0.1,
		0.2
	}
	self.values.melee.stacking_hit_expire_t = {
		7
	}
	self.values.player.melee_kill_life_leech = {
		0.1
	}
	self.values.player.killshot_regen_armor_bonus = {
		3
	}
	self.values.player.killshot_close_regen_armor_bonus = {
		3
	}
	self.values.player.killshot_close_panic_chance = {
		0.75
	}
	self.loose_ammo_restore_health_values = {
		{
			0,
			2
		},
		{
			2,
			4
		},
		{
			4,
			6
		},
		multiplier = 0.2,
		cd = 4,
		base = 4
	}
	self.loose_ammo_give_team_ratio = 0.5
	self.loose_ammo_give_team_health_ratio = 1
	self.values.temporary.loose_ammo_restore_health = {}

	for i, data in ipairs(self.loose_ammo_restore_health_values) do
		local base = self.loose_ammo_restore_health_values.base

		table.insert(self.values.temporary.loose_ammo_restore_health, {
			{
				base + data[1],
				base + data[2]
			},
			self.loose_ammo_restore_health_values.cd
		})
	end

	self.values.temporary.loose_ammo_give_team = {
		{
			true,
			5
		}
	}
	self.values.player.loose_ammo_restore_health_give_team = {
		true
	}
	self.damage_to_hot_data = {
		tick_time = 0.5,
		works_with_armor_kit = true,
		stacking_cooldown = 1.5,
		total_ticks = 10,
		max_stacks = false,
		armors_allowed = {
			"level_1",
			"level_2"
		},
		add_stack_sources = {
			melee = true,
			fire = true,
			bullet = true,
			explosion = true,
			taser_tased = true,
			civilian = false,
			swat_van = true,
			poison = true
		}
	}
	self.values.player.damage_to_hot = {
		0.1,
		0.2,
		0.3,
		0.4
	}
	self.values.player.damage_to_hot_extra_ticks = {
		2
	}
	self.values.player.armor_piercing_chance = {
		0.1,
		0.3
	}
	self.values.assault_rifle.move_spread_index_addend = {
		2
	}
	self.values.snp.move_spread_index_addend = {
		2
	}
	self.values.pistol.spread_index_addend = {
		1
	}
	self.values.akimbo.spread_index_addend = self.values.pistol.spread_index_addend
	self.values.shotgun.hip_fire_spread_index_addend = {
		1
	}
	self.values.weapon.hip_fire_spread_index_addend = {
		1
	}
	self.values.weapon.single_spread_index_addend = {
		1
	}
	self.values.weapon.silencer_spread_index_addend = {
		2
	}
	self.values.team.pistol.recoil_index_addend = {
		1
	}
	self.values.team.akimbo.recoil_index_addend = self.values.team.pistol.recoil_index_addend
	self.values.team.weapon.recoil_index_addend = {
		2
	}
	self.values.team.pistol.suppression_recoil_index_addend = self.values.team.pistol.recoil_index_addend
	self.values.team.akimbo.suppression_recoil_index_addend = self.values.team.akimbo.recoil_index_addend
	self.values.team.weapon.suppression_recoil_index_addend = self.values.team.weapon.recoil_index_addend
	self.values.shotgun.recoil_index_addend = {
		1
	}
	self.values.assault_rifle.recoil_index_addend = {
		1
	}
	self.values.weapon.silencer_recoil_index_addend = {
		2
	}
	self.values.lmg.recoil_index_addend = {
		1
	}
	self.values.snp.recoil_index_addend = {
		1
	}
	self.values.akimbo.recoil_index_addend = {
		-6,
		-4,
		-2
	}
	local editable_skill_descs = {
		ammo_2x = {
			{
				"2"
			},
			{
				"200%"
			}
		},
		ammo_reservoir = {
			{
				"5"
			},
			{
				"10"
			}
		},
		assassin = {
			{
				"25%",
				"10%"
			},
			{
				"95%"
			}
		},
		bandoliers = {
			{
				"25%"
			},
			{
				"175%"
			}
		},
		black_marketeer = {
			{
				"1.5%",
				"5"
			},
			{
				"4.5%",
				"5"
			}
		},
		blast_radius = {
			{
				"70%"
			},
			{}
		},
		cable_guy = {
			{
				"75%"
			},
			{
				"4"
			}
		},
		carbon_blade = {
			{
				"20%"
			},
			{
				"50%",
				"20%"
			}
		},
		cat_burglar = {
			{
				"75%"
			},
			{
				"50%"
			}
		},
		chameleon = {
			{
				"25%"
			},
			{
				"15%"
			}
		},
		cleaner = {
			{
				"5%",
				"3"
			},
			{
				"1"
			}
		},
		combat_medic = {
			{
				"25%",
				"10"
			},
			{
				"30%"
			}
		},
		control_freak = {
			{
				"10%",
				"40%"
			},
			{
				"20%",
				"40%"
			}
		},
		discipline = {
			{
				"50%"
			},
			{}
		},
		dominator = {
			{},
			{
				"50%"
			}
		},
		drill_expert = {
			{
				"15%"
			},
			{
				"15%"
			}
		},
		ecm_2x = {
			{
				"2"
			},
			{
				"25%",
				"25%"
			}
		},
		ecm_booster = {
			{
				"25%"
			},
			{}
		},
		ecm_feedback = {
			{
				"50%-100%",
				"25",
				"1.5",
				"15-20"
			},
			{
				"25%",
				"100%",
				"4"
			}
		},
		enforcer = {
			{
				"400%"
			},
			{}
		},
		equilibrium = {
			{
				"4",
				"50%"
			},
			{
				"100%"
			}
		},
		fast_learner = {
			{
				"10%",
				"5"
			},
			{
				"20%"
			}
		},
		from_the_hip = {
			{
				"4"
			},
			{
				"4"
			}
		},
		ghost = {
			{
				"1",
				"20"
			},
			{}
		},
		good_luck_charm = {
			{
				"10",
				"1"
			},
			{
				"10"
			}
		},
		gun_fighter = {
			{
				"50%"
			},
			{
				"15"
			}
		},
		hardware_expert = {
			{
				"25%",
				"20%"
			},
			{
				"30%",
				"50%"
			}
		},
		hitman = {
			{
				"15%"
			},
			{
				"15%",
				"20%"
			}
		},
		inside_man = {
			{
				"50%"
			},
			{}
		},
		inspire = {
			{
				"50%",
				"20%",
				"10"
			},
			{
				"75%"
			}
		},
		insulation = {
			{},
			{
				"50%"
			}
		},
		iron_man = {
			{
				"50%"
			},
			{
				"25%"
			}
		},
		joker = {
			{},
			{
				"55%",
				"45%",
				"65%"
			}
		},
		juggernaut = {
			{},
			{}
		},
		kilmer = {
			{
				"25%"
			},
			{
				"8"
			}
		},
		leadership = {
			{
				"4"
			},
			{
				"8"
			}
		},
		mag_plus = {
			{
				"5"
			},
			{
				"10"
			}
		},
		magic_touch = {
			{
				"25%"
			},
			{
				"25%"
			}
		},
		martial_arts = {
			{
				"50%"
			},
			{
				"50%"
			}
		},
		master_craftsman = {
			{
				"30%"
			},
			{
				"15%"
			}
		},
		mastermind = {
			{
				"2"
			},
			{}
		},
		medic_2x = {
			{
				"2"
			},
			{
				"2"
			}
		},
		nine_lives = {
			{
				"1"
			},
			{
				"35%"
			}
		},
		oppressor = {
			{
				"25%"
			},
			{
				"50%"
			}
		},
		overkill = {
			{
				"75%",
				"5"
			},
			{}
		},
		pack_mule = {
			{
				"50%"
			},
			{
				"50%"
			}
		},
		pistol_messiah = {
			{
				"1"
			},
			{
				"2"
			}
		},
		portable_saw = {
			{},
			{
				"1"
			}
		},
		rifleman = {
			{
				"100%"
			},
			{
				"25%"
			}
		},
		scavenger = {
			{
				"10%"
			},
			{
				"20%"
			}
		},
		sentry_2_0 = {
			{},
			{}
		},
		sentry_gun = {
			{},
			{
				"150%"
			}
		},
		sentry_gun_2x = {
			{
				"2"
			},
			{
				"300%"
			}
		},
		sentry_targeting_package = {
			{
				"100%"
			},
			{
				"150%",
				"50%"
			}
		},
		shades = {
			{
				"25%"
			},
			{
				"50%"
			}
		},
		shaped_charge = {
			{
				"3"
			},
			{}
		},
		sharpshooter = {
			{
				"4"
			},
			{
				"8"
			}
		},
		shotgun_cqb = {
			{
				"50%"
			},
			{
				"125%"
			}
		},
		shotgun_impact = {
			{
				"4"
			},
			{
				"35%"
			}
		},
		show_of_force = {
			{},
			{
				"15%"
			}
		},
		silence = {
			{},
			{}
		},
		silence_expert = {
			{
				"8",
				"100%"
			},
			{
				"8",
				"20%"
			}
		},
		silent_drilling = {
			{
				"65%"
			},
			{}
		},
		smg_master = {
			{
				"35%"
			},
			{
				"20%"
			}
		},
		smg_training = {
			{},
			{}
		},
		sprinter = {
			{
				"25%",
				"25%"
			},
			{
				"25%",
				"25%"
			}
		},
		steroids = {
			{
				"50%"
			},
			{
				"50%"
			}
		},
		stockholm_syndrome = {
			{},
			{}
		},
		tactician = {
			{
				"15%"
			},
			{}
		},
		target_mark = {
			{},
			{}
		},
		technician = {
			{
				"2"
			},
			{}
		},
		tough_guy = {
			{
				"50%"
			},
			{
				"25%"
			}
		},
		transporter = {
			{
				"25%"
			},
			{
				"50%"
			}
		},
		triathlete = {
			{
				"100%"
			},
			{
				"50%"
			}
		},
		trip_mine_expert = {
			{},
			{}
		},
		trip_miner = {
			{
				"1"
			},
			{
				"20%"
			}
		},
		underdog = {
			{
				"15%"
			},
			{
				"15%"
			}
		},
		wolverine = {
			{
				"25%",
				"250%"
			},
			{
				"25%",
				"100%"
			}
		},
		hoxton = {
			{
				"4"
			},
			{}
		},
		freedom_call = {
			{
				"20%"
			},
			{
				"15%"
			}
		},
		hidden_blade = {
			{
				"2"
			},
			{
				"95%"
			}
		},
		tea_time = {
			{
				"50%"
			},
			{
				"20%",
				"10"
			}
		},
		awareness = {
			{
				"10%"
			},
			{}
		},
		alpha_dog = {
			{
				"5%"
			},
			{
				"10%"
			}
		},
		tea_cookies = {
			{
				"3"
			},
			{
				"7"
			}
		},
		cell_mates = {
			{
				"10%"
			},
			{
				"25%"
			}
		},
		thug_life = {
			{
				"1"
			},
			{
				"75%"
			}
		},
		thick_skin = {
			{
				"10"
			},
			{
				"20"
			}
		},
		backstab = {
			{
				"3%",
				"3",
				"35",
				"30%"
			},
			{
				"3%",
				"1",
				"35",
				"30%"
			}
		},
		drop_soap = {
			{},
			{}
		},
		second_chances = {
			{},
			{
				"2"
			}
		},
		trigger_happy = {
			{
				"10%",
				"2",
				"4"
			},
			{
				"8"
			}
		},
		perseverance = {
			{
				"0",
				"3",
				"60%"
			},
			{
				"6"
			}
		},
		jail_workout = {
			{
				"3.5",
				"10"
			},
			{}
		},
		akimbo = {
			{
				"-16"
			},
			{
				"-8",
				"150%"
			}
		},
		jail_diet = {
			{
				"1%",
				"3",
				"35",
				"10%"
			},
			{
				"1%",
				"1",
				"35",
				"10%"
			}
		},
		prison_wife = {
			{
				"15",
				"2"
			},
			{
				"30",
				"2"
			}
		}
	}
	self.skill_descs = {}

	for skill_id, skill_desc in pairs(editable_skill_descs) do
		self.skill_descs[skill_id] = {}

		for index, skill_version in ipairs(skill_desc) do
			local version = index == 1 and "multibasic" or "multipro"
			self.skill_descs[skill_id][index] = #skill_version

			for i, desc in ipairs(skill_version) do
				self.skill_descs[skill_id][version .. (i == 1 and "" or tostring(i))] = desc
			end
		end
	end
end

function UpgradesTweakData:_old_init()
	self.level_tree = {
		{
			name_id = "body_armor",
			upgrades = {
				"body_armor2",
				"m1911",
				"thompson",
				"sten",
				"garand",
				"garand_gold",
				"m1918",
				"m1903",
				"m1912",
				"mp38",
				"mp44",
				"carbine",
				"mg42",
				"c96",
				"webley",
				"mosin",
				"sterling",
				"geco",
				"dp28",
				"tt33",
				"ithaca",
				"kar_98k",
				"bren",
				"lee_enfield",
				"browning",
				"welrod",
				"shotty"
			}
		}
	}

	self:_init_pd2_values()
	self:_init_values()

	self.steps = {}
	self.values.player = self.values.player or {}
	self.values.player.thick_skin = {
		2,
		4,
		6,
		8,
		10
	}
	self.values.player.primary_weapon_when_carrying = {
		true
	}
	self.values.player.health_multiplier = {
		1.1
	}
	self.values.player.dye_pack_chance_multiplier = {
		0.5
	}
	self.values.player.dye_pack_cash_loss_multiplier = {
		0.4
	}
	self.values.player.toolset = {
		0.95,
		0.9,
		0.85,
		0.8
	}
	self.values.player.uncover_progress_mul = {
		0.5
	}
	self.values.player.uncover_progress_decay_mul = {
		1.5
	}
	self.values.player.suppressed_multiplier = {
		0.5
	}
	self.values.player.intimidate_specials = {
		true
	}
	self.values.player.intimidation_multiplier = {
		1.25
	}
	self.steps.player = {
		thick_skin = {
			nil,
			8,
			18,
			27,
			39
		},
		extra_ammo_multiplier = {
			nil,
			7,
			16,
			24,
			38
		},
		toolset = {
			nil,
			7,
			16,
			38
		}
	}
	self.values.trip_mine = self.values.trip_mine or {}
	self.values.trip_mine.quantity = {
		1,
		2,
		3,
		4,
		5,
		8
	}
	self.values.trip_mine.quantity_2 = {
		2
	}
	self.values.trip_mine.quantity_increase = {
		2
	}
	self.values.trip_mine.explode_timer_delay = {
		2
	}
	self.steps.trip_mine = {
		quantity = {
			14,
			22,
			29,
			36,
			42,
			47
		},
		damage_multiplier = {
			6,
			32
		}
	}
	self.values.ammo_bag = self.values.ammo_bag or {}
	self.steps.ammo_bag = {
		ammo_increase = {
			10,
			19,
			30
		}
	}
	self.values.ecm_jammer = self.values.ecm_jammer or {}
	self.values.first_aid_kit = self.values.first_aid_kit or {}
	self.values.sentry_gun = self.values.sentry_gun or {}
	self.steps.sentry_gun = {}
	self.values.doctor_bag = self.values.doctor_bag or {}
	self.steps.doctor_bag = {
		amount_increase = {
			11,
			19,
			33
		}
	}
	self.values.extra_cable_tie = {
		quantity = {
			1,
			2,
			3,
			4
		}
	}
	self.steps.extra_cable_tie = {
		quantity = {
			nil,
			12,
			23,
			33
		}
	}
	self.values.striker = {
		reload_speed_multiplier = {
			1.15
		}
	}

	self:_player_definitions()
	self:_trip_mine_definitions()
	self:_ecm_jammer_definitions()
	self:_ammo_bag_definitions()
	self:_doctor_bag_definitions()
	self:_cable_tie_definitions()
	self:_sentry_gun_definitions()
	self:_armor_kit_definitions()
	self:_first_aid_kit_definitions()
	self:_bodybags_bag_definitions()
	self:_rep_definitions()
	self:_flamethrower_mk2_definitions()
	self:_weapon_upgrades_definitions()
	self:_carry_definitions()
	self:_team_definitions()
	self:_shape_charge_definitions()
	self:_temporary_definitions()

	self.definitions.lucky_charm = {
		name_id = "menu_lucky_charm",
		category = "what_is_this"
	}
	self.levels = {}

	for name, upgrade in pairs(self.definitions) do
		local unlock_lvl = upgrade.unlock_lvl or 1
		self.levels[unlock_lvl] = self.levels[unlock_lvl] or {}

		if upgrade.prio and upgrade.prio == "high" then
			table.insert(self.levels[unlock_lvl], 1, name)
		else
			table.insert(self.levels[unlock_lvl], name)
		end
	end

	self.progress = {
		{},
		{},
		{},
		{}
	}

	for name, upgrade in pairs(self.definitions) do
		if upgrade.tree then
			if upgrade.step then
				if self.progress[upgrade.tree][upgrade.step] then
					Application:error("upgrade collision", upgrade.tree, upgrade.step, self.progress[upgrade.tree][upgrade.step], name)
				end

				self.progress[upgrade.tree][upgrade.step] = name
			else
				print(name, upgrade.tree, "is in no step")
			end
		end
	end

	self.progress[1][49] = "mr_nice_guy"
	self.progress[2][49] = "mr_nice_guy"
	self.progress[3][49] = "mr_nice_guy"
	self.progress[4][49] = "mr_nice_guy"
end

function UpgradesTweakData:_init_values()
	self.values.weapon = self.values.weapon or {}
	self.values.weapon.reload_speed_multiplier = {
		1
	}
	self.values.weapon.damage_multiplier = {
		1
	}
	self.values.weapon.swap_speed_multiplier = {
		1.25
	}
	self.values.weapon.passive_reload_speed_multiplier = {
		1.1
	}
	self.values.weapon.auto_spread_multiplier = {
		1
	}
	self.values.weapon.spread_multiplier = {
		0.9
	}
	self.values.weapon.fire_rate_multiplier = {
		2
	}
	self.values.assault_rifle = self.values.assault_rifle or {}
	self.values.smg = self.values.smg or {}
	self.values.shotgun = self.values.shotgun or {}
	self.values.carry = self.values.carry or {}
	self.values.carry.catch_interaction_speed = {
		0.6,
		0.1
	}
	self.values.cable_tie = self.values.cable_tie or {}
	self.values.cable_tie.quantity_unlimited = {
		true
	}
	self.values.temporary = self.values.temporary or {}
	self.values.temporary.wolverine_health_regen = {
		{
			0.002,
			1
		}
	}
	self.values.temporary.pistol_revive_from_bleed_out = {
		{
			true,
			3
		}
	}
	self.values.temporary.revive_health_boost = {
		{
			true,
			10
		}
	}
	self.values.team = self.values.team or {}
	self.values.team.player = self.values.team.player or {}
	self.values.team.pistol = self.values.team.pistol or {}
	self.values.team.weapon = self.values.team.weapon or {}
	self.values.team.xp = self.values.team.xp or {}
	self.values.team.armor = self.values.team.armor or {}
	self.values.team.stamina = self.values.team.stamina or {}
	self.values.saw = self.values.saw or {}
	self.values.saw.recoil_multiplier = {
		0.75
	}
	self.values.saw.fire_rate_multiplier = {
		1.25,
		1.5
	}
end

function UpgradesTweakData:_player_definitions()
	self.definitions.body_armor1 = {
		name_id = "bm_armor_level_2",
		armor_id = "level_2",
		category = "armor"
	}
	self.definitions.body_armor2 = {
		name_id = "bm_armor_level_3",
		armor_id = "level_3",
		category = "armor"
	}
	self.definitions.body_armor3 = {
		name_id = "bm_armor_level_4",
		armor_id = "level_4",
		category = "armor"
	}
	self.definitions.body_armor4 = {
		name_id = "bm_armor_level_5",
		armor_id = "level_5",
		category = "armor"
	}
	self.definitions.body_armor5 = {
		name_id = "bm_armor_level_6",
		armor_id = "level_6",
		category = "armor"
	}
	self.definitions.body_armor6 = {
		name_id = "bm_armor_level_7",
		armor_id = "level_7",
		category = "armor"
	}
	self.definitions.thick_skin = {
		description_text_id = "thick_skin",
		category = "equipment",
		equipment_id = "thick_skin",
		tree = 2,
		image = "upgrades_thugskin",
		image_slice = "upgrades_thugskin_slice",
		title_id = "debug_upgrade_player_upgrade",
		slot = 2,
		subtitle_id = "debug_upgrade_thick_skin1",
		name_id = "debug_upgrade_thick_skin1",
		icon = "equipment_armor",
		unlock_lvl = 0,
		step = 2,
		aquire = {
			upgrade = "thick_skin1"
		}
	}

	for i, _ in ipairs(self.values.player.thick_skin) do
		local depends_on = i - 1 > 0 and "thick_skin" .. i - 1
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["thick_skin" .. i] = {
			description_text_id = "thick_skin",
			tree = 2,
			image = "upgrades_thugskin",
			image_slice = "upgrades_thugskin_slice",
			title_id = "debug_upgrade_player_upgrade",
			category = "feature",
			icon = "equipment_thick_skin",
			step = self.steps.player.thick_skin[i],
			subtitle_id = "debug_upgrade_thick_skin" .. i,
			name_id = "debug_upgrade_thick_skin" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "thick_skin",
				category = "player",
				value = i
			}
		}
	end

	self.definitions.extra_start_out_ammo = {
		description_text_id = "extra_ammo_multiplier",
		category = "equipment",
		equipment_id = "extra_start_out_ammo",
		tree = 3,
		image = "upgrades_extrastartammo",
		image_slice = "upgrades_extrastartammo_slice",
		slot = 2,
		title_id = "debug_upgrade_player_upgrade",
		prio = "high",
		subtitle_id = "debug_upgrade_extra_start_out_ammo1",
		name_id = "debug_upgrade_extra_start_out_ammo1",
		icon = "equipment_extra_start_out_ammo",
		unlock_lvl = 13,
		step = 2,
		aquire = {
			upgrade = "extra_ammo_multiplier1"
		}
	}

	for i, _ in ipairs(self.values.player.extra_ammo_multiplier) do
		local depends_on = i - 1 > 0 and "extra_ammo_multiplier" .. i - 1
		local unlock_lvl = 14
		local prio = i == 1 and "high"
		self.definitions["extra_ammo_multiplier" .. i] = {
			description_text_id = "extra_ammo_multiplier",
			tree = 3,
			image = "upgrades_extrastartammo",
			image_slice = "upgrades_extrastartammo_slice",
			title_id = "debug_upgrade_player_upgrade",
			category = "feature",
			icon = "equipment_extra_start_out_ammo",
			step = self.steps.player.extra_ammo_multiplier[i],
			name_id = "debug_upgrade_extra_start_out_ammo" .. i,
			subtitle_id = "debug_upgrade_extra_start_out_ammo" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "extra_ammo_multiplier",
				category = "player",
				value = i
			}
		}
	end

	self.definitions.player_add_armor_stat_skill_ammo_mul = {
		name_id = "menu_player_add_armor_stat_skill_ammo_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "add_armor_stat_skill_ammo_mul",
			category = "player"
		}
	}
	self.definitions.player_overkill_health_to_damage_multiplier = {
		name_id = "menu_player_overkill_health_to_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "overkill_health_to_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_crit_chance_1 = {
		name_id = "menu_player_detection_risk_add_crit_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "detection_risk_add_crit_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_crit_chance_2 = {
		name_id = "menu_player_detection_risk_add_crit_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "detection_risk_add_crit_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_dodge_chance_1 = {
		name_id = "menu_player_detection_risk_add_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "detection_risk_add_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_add_dodge_chance_2 = {
		name_id = "menu_player_detection_risk_add_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "detection_risk_add_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_detection_risk_damage_multiplier = {
		name_id = "menu_player_detection_risk_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "detection_risk_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_melee_kill_snatch_pager_chance = {
		name_id = "menu_player_melee_kill_snatch_pager_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_kill_snatch_pager_chance",
			category = "player"
		}
	}
	self.definitions.player_knockdown = {
		name_id = "menu_player_knockdown",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "knockdown",
			category = "player"
		}
	}
	self.definitions.player_immune_to_gas = {
		name_id = "menu_player_immune_to_gas",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "immune_to_gas",
			category = "player"
		}
	}
	self.definitions.player_mark_enemy_time_multiplier = {
		name_id = "menu_player_mark_enemy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mark_enemy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_minion_master_health_multiplier = {
		name_id = "menu_player_minion_master_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "minion_master_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_minion_master_speed_multiplier = {
		name_id = "menu_player_minion_master_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "minion_master_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_flashbang_multiplier_1 = {
		name_id = "menu_player_flashbang_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "flashbang_multiplier",
			category = "player"
		}
	}
	self.definitions.player_flashbang_multiplier_2 = {
		name_id = "menu_player_flashbang_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "flashbang_multiplier",
			category = "player"
		}
	}
	self.definitions.player_revive_damage_reduction_level_1 = {
		name_id = "menu_player_revive_damage_reduction_level",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "revive_damage_reduction_level",
			category = "player"
		}
	}
	self.definitions.player_revive_damage_reduction_level_2 = {
		name_id = "menu_player_revive_damage_reduction_level",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "revive_damage_reduction_level",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_4 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_4 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_5 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 5,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_6 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 6,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_panic_suppression = {
		name_id = "menu_player_panic_suppression",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "panic_suppression",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_multiplier_passive = {
		name_id = "menu_player_armor_regen_timer_multiplier_passive",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_multiplier_passive",
			category = "player"
		}
	}
	self.definitions.player_hostage_health_regen_addend_1 = {
		name_id = "menu_player_hostage_health_regen_addend",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "hostage_health_regen_addend",
			category = "player"
		}
	}
	self.definitions.player_hostage_health_regen_addend_2 = {
		name_id = "menu_player_hostage_health_regen_addend",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "hostage_health_regen_addend",
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_3 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_4 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.team_passive_armor_multiplier = {
		name_id = "menu_team_passive_armor_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "multiplier",
			category = "armor"
		}
	}
	self.definitions.player_camouflage_multiplier = {
		name_id = "menu_player_camouflage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "camouflage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_uncover_multiplier = {
		name_id = "menu_player_uncover_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "uncover_multiplier",
			category = "player"
		}
	}
	self.definitions.player_primary_weapon_when_downed = {
		name_id = "menu_player_primary_weapon_when_downed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "primary_weapon_when_downed",
			category = "player"
		}
	}
	self.definitions.player_primary_weapon_when_carrying = {
		name_id = "menu_player_primary_weapon_when_carrying",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "primary_weapon_when_carrying",
			category = "player"
		}
	}
	self.definitions.player_pistol_revive_from_bleed_out_timer = {
		name_id = "menu_player_pistol_revive_from_bleed_out_timer",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "pistol_revive_from_bleed_out",
			category = "temporary"
		}
	}
	self.definitions.player_can_strafe_run = {
		name_id = "menu_player_can_strafe_run",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_strafe_run",
			category = "player"
		}
	}
	self.definitions.player_can_free_run = {
		name_id = "menu_player_can_free_run",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_free_run",
			category = "player"
		}
	}
	self.definitions.player_damage_shake_multiplier = {
		name_id = "menu_player_damage_shake_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_shake_multiplier",
			category = "player"
		}
	}
	self.definitions.player_health_multiplier = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_1 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_2 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_health_multiplier_3 = {
		name_id = "menu_player_health_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_bleed_out_health_multiplier = {
		name_id = "menu_player_bleed_out_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "bleed_out_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_shield_knock = {
		name_id = "menu_player_shield_knock",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "shield_knock",
			category = "player"
		}
	}
	self.definitions.player_steelsight_when_downed = {
		name_id = "menu_player_steelsight_when_downed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "steelsight_when_downed",
			category = "player"
		}
	}
	self.definitions.player_armor_multiplier = {
		name_id = "menu_player_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_1 = {
		name_id = "menu_player_tier_armor_multiplier_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_2 = {
		name_id = "menu_player_tier_armor_multiplier_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_armor_multiplier_3 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "tier_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_convert_enemies_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_convert_enemies_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_counter_strike_melee = {
		name_id = "menu_player_counter_strike_melee",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "counter_strike_melee",
			category = "player"
		}
	}
	self.definitions.player_counter_strike_spooc = {
		name_id = "menu_player_counter_strike_spooc",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "counter_strike_spooc",
			category = "player"
		}
	}
	self.definitions.player_extra_corpse_dispose_amount = {
		name_id = "menu_player_extra_corpse_dispose_amount",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "extra_corpse_dispose_amount",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_multiplier_tier = {
		name_id = "menu_player_armor_regen_timer_multiplier_tier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_multiplier_tier",
			category = "player"
		}
	}
	self.definitions.player_standstill_omniscience = {
		name_id = "menu_player_standstill_omniscience",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "standstill_omniscience",
			category = "player"
		}
	}
	self.definitions.player_mask_off_pickup = {
		name_id = "menu_player_mask_off_pickup",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "mask_off_pickup",
			category = "player"
		}
	}
	self.definitions.player_cleaner_cost_multiplier = {
		name_id = "menu_player_cleaner_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cleaner_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_addend = {
		name_id = "menu_player_level_2_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_addend = {
		name_id = "menu_player_level_3_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_addend = {
		name_id = "menu_player_level_4_armor_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_2_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_3_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_dodge_addend_1 = {
		incremental = true,
		name_id = "menu_player_level_4_dodge_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_2_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_2_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_3_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_3_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_dodge_addend_2 = {
		incremental = true,
		name_id = "menu_player_level_4_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_4_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_2_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_2_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_3_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_3_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_3_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_level_4_dodge_addend_3 = {
		incremental = true,
		name_id = "menu_player_level_4_dodge_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "level_4_dodge_addend",
			category = "player"
		}
	}
	self.definitions.player_damage_shake_addend = {
		name_id = "menu_player_damage_shake_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_shake_addend",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_2_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_3_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_multiplier_1 = {
		incremental = true,
		name_id = "menu_player_level_4_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_2_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_3_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_level_4_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_2_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_2_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_2_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_3_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_3_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_3_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_level_4_armor_multiplier_3 = {
		incremental = true,
		name_id = "menu_player_level_4_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_4_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tier_dodge_chance_1 = {
		name_id = "menu_player_tier_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tier_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_tier_dodge_chance_2 = {
		name_id = "menu_player_tier_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tier_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_tier_dodge_chance_3 = {
		name_id = "menu_player_tier_dodge_chance",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "tier_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_stand_still_crouch_camouflage_bonus_1 = {
		name_id = "menu_player_stand_still_crouch_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stand_still_crouch_camouflage_bonus",
			category = "player"
		}
	}
	self.definitions.player_stand_still_crouch_camouflage_bonus_2 = {
		name_id = "menu_player_stand_still_crouch_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "stand_still_crouch_camouflage_bonus",
			category = "player"
		}
	}
	self.definitions.player_stand_still_crouch_camouflage_bonus_3 = {
		name_id = "menu_player_stand_still_crouch_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "stand_still_crouch_camouflage_bonus",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_speed_multiplier = {
		name_id = "menu_player_pick_lock_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose_speed_multiplier = {
		name_id = "menu_player_corpse_dispose_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_dispose_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_alarm_pager_speed_multiplier = {
		name_id = "menu_player_alarm_pager_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "alarm_pager_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_melee_life_leech = {
		name_id = "menu_player_melee_life_leech",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "melee_life_leech",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_outnumbered_strong = {
		name_id = "menu_player_dmg_dampener_outnumbered_strong",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_dampener_outnumbered_strong",
			category = "temporary"
		}
	}
	self.definitions.player_melee_kill_life_leech = {
		name_id = "menu_player_melee_kill_life_leech",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_kill_life_leech",
			category = "player"
		}
	}
	self.definitions.player_killshot_regen_armor_bonus = {
		name_id = "menu_player_killshot_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "killshot_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_killshot_close_regen_armor_bonus = {
		name_id = "menu_player_killshot_close_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "killshot_close_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_killshot_close_panic_chance = {
		name_id = "menu_player_killshot_close_panic_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "killshot_close_panic_chance",
			category = "player"
		}
	}
	self.definitions.player_damage_dampener_close_contact_1 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_dampener_close_contact",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_close_contact_2 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "dmg_dampener_close_contact",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_close_contact_3 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = {
			value = 3,
			upgrade = "dmg_dampener_close_contact",
			category = "temporary"
		}
	}
	self.definitions.melee_stacking_hit_damage_multiplier_1 = {
		name_id = "menu_melee_stacking_hit_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacking_hit_damage_multiplier",
			category = "melee"
		}
	}
	self.definitions.melee_stacking_hit_damage_multiplier_2 = {
		name_id = "menu_melee_stacking_hit_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "stacking_hit_damage_multiplier",
			category = "melee"
		}
	}
	self.definitions.melee_stacking_hit_expire_t = {
		name_id = "menu_melee_stacking_hit_expire_t",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "stacking_hit_expire_t",
			category = "melee"
		}
	}

	for i, value in ipairs(self.values.player.perk_armor_regen_timer_multiplier) do
		self.definitions["player_perk_armor_regen_timer_multiplier_" .. tostring(i)] = {
			name_id = "menu_player_perk_armor_regen_timer_multiplier",
			category = "feature",
			upgrade = {
				upgrade = "perk_armor_regen_timer_multiplier",
				category = "player",
				value = i
			}
		}
	end

	for i, value in ipairs(self.values.player.perk_armor_loss_multiplier) do
		self.definitions["player_perk_armor_loss_multiplier_" .. tostring(i)] = {
			name_id = "menu_player_perk_armor_loss_multiplier",
			category = "feature",
			upgrade = {
				upgrade = "perk_armor_loss_multiplier",
				category = "player",
				value = i
			}
		}
	end

	self.definitions.player_passive_armor_multiplier_1 = {
		name_id = "menu_player_passive_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_armor_multiplier_2 = {
		name_id = "menu_player_passive_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_armor_multiplier",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_multiplier = {
		name_id = "menu_player_armor_regen_timer_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_multiplier",
			category = "player"
		}
	}
	self.definitions.player_armor_regen_timer_stand_still_multiplier = {
		name_id = "menu_player_armor_regen_timer_stand_still_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_regen_timer_stand_still_multiplier",
			category = "player"
		}
	}
	self.definitions.player_wolverine_health_regen = {
		name_id = "menu_player_wolverine_health_regen",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "wolverine_health_regen",
			category = "temporary"
		}
	}
	self.definitions.player_hostage_health_regen_addend = {
		name_id = "menu_player_hostage_health_regen_addend",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "hostage_health_regen_addend",
			category = "player"
		}
	}
	self.definitions.player_passive_health_regen = {
		name_id = "menu_player_passive_health_regen",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "passive_health_regen",
			category = "player"
		}
	}
	self.definitions.player_close_to_hostage_boost = {
		name_id = "menu_player_close_to_hostage_boost",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "close_to_hostage_boost",
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_1 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_passive_dodge_chance_2 = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_run_dodge_chance = {
		name_id = "menu_player_run_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_fall_damage_multiplier = {
		name_id = "menu_player_fall_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fall_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_fall_health_damage_multiplier = {
		name_id = "menu_player_fall_health_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fall_health_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_damage_health_ratio_multiplier = {
		name_id = "menu_player_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_melee_damage_health_ratio_multiplier = {
		name_id = "menu_player_melee_damage_health_ratio_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_damage_health_ratio_multiplier",
			category = "player"
		}
	}
	self.definitions.player_respawn_time_multiplier = {
		name_id = "menu_player_respawn_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "respawn_time_multiplier",
			category = "player"
		}
	}
	self.definitions.passive_player_xp_multiplier = {
		name_id = "menu_player_xp_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_xp_multiplier",
			category = "player"
		}
	}
	self.definitions.player_xp_multiplier = {
		name_id = "menu_player_xp_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "xp_multiplier",
			category = "player"
		}
	}
	self.definitions.player_non_special_melee_multiplier = {
		name_id = "menu_player_non_special_melee_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "non_special_melee_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_suspicion_bonus = {
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_concealment_bonus_1 = {
		incremental = true,
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_concealment_bonus_2 = {
		incremental = true,
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_concealment_bonus_3 = {
		incremental = true,
		name_id = "menu_player_passive_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_melee_concealment_modifier = {
		incremental = true,
		name_id = "menu_player_melee_concealment_modifier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_concealment_modifier",
			category = "player"
		}
	}
	self.definitions.player_melee_sharp_damage_multiplier = {
		incremental = true,
		name_id = "menu_player_melee_sharp_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_sharp_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_suspicion_bonus = {
		name_id = "menu_player_suspicion_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "suspicion_multiplier",
			category = "player"
		}
	}
	self.definitions.player_loose_ammo_restore_health_give_team = {
		name_id = "menu_player_loose_ammo_restore_health_give_team",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_restore_health_give_team",
			category = "player"
		}
	}
	self.definitions.player_uncover_progress_mul = {
		name_id = "player_uncover_progress_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "uncover_progress_mul",
			category = "player"
		}
	}
	self.definitions.player_uncover_progress_decay_mul = {
		name_id = "menu_player_uncover_progress_decay_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "uncover_progress_decay_mul",
			category = "player"
		}
	}
	self.definitions.player_camouflage_bonus = {
		name_id = "menu_player_camouflage_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "camouflage_bonus",
			category = "player"
		}
	}
	self.definitions.player_suppressed_bonus = {
		name_id = "menu_player_suppressed_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "suppressed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_suppression_bonus_1 = {
		name_id = "menu_player_suppression_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_suppression_bonus_2 = {
		name_id = "menu_player_suppression_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_suppression_bonus = {
		name_id = "menu_player_suppression_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_civilian_reviver = {
		name_id = "menu_player_civilian_reviver",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civilian_reviver",
			category = "player"
		}
	}
	self.definitions.player_overkill_damage_multiplier = {
		name_id = "menu_player_overkill_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "overkill_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.player_overkill_all_weapons = {
		name_id = "menu_player_overkill_all_weapons",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "overkill_all_weapons",
			category = "player"
		}
	}
	self.definitions.player_berserker_no_ammo_cost = {
		name_id = "menu_player_berserker_no_ammo_cost",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "berserker_no_ammo_cost",
			category = "player"
		}
	}
	self.definitions.player_damage_multiplier_outnumbered = {
		name_id = "menu_player_dmg_mul_outnumbered",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_multiplier_outnumbered",
			category = "temporary"
		}
	}
	self.definitions.player_damage_dampener_outnumbered = {
		name_id = "menu_player_dmg_damp_outnumbered",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "dmg_dampener_outnumbered",
			category = "temporary"
		}
	}
	self.definitions.player_corpse_alarm_pager_bluff = {
		name_id = "menu_player_pager_dis",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_alarm_pager_bluff",
			category = "player"
		}
	}
	self.definitions.player_buy_bodybags_asset = {
		name_id = "menu_player_buy_bodybags_asset",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "buy_bodybags_asset",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose = {
		name_id = "menu_player_corpse_disp",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_dispose",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose_amount_1 = {
		name_id = "menu_player_corpse_disp_amount_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "corpse_dispose_amount",
			category = "player"
		}
	}
	self.definitions.player_corpse_dispose_amount_2 = {
		name_id = "menu_player_corpse_disp_amount_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "corpse_dispose_amount",
			category = "player"
		}
	}
	self.definitions.player_taser_malfunction = {
		name_id = "menu_player_taser_malf",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "taser_malfunction",
			category = "player"
		}
	}
	self.definitions.player_taser_self_shock = {
		name_id = "menu_player_taser_shock",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "taser_self_shock",
			category = "player"
		}
	}
	self.definitions.player_electrocution_resistance = {
		name_id = "menu_player_electrocution_resistance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "electrocution_resistance_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tased_recover_multiplier = {
		name_id = "menu_player_tased_recover_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tased_recover_multiplier",
			category = "player"
		}
	}
	self.definitions.player_secured_bags_speed_multiplier = {
		name_id = "menu_player_secured_bags_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "secured_bags_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_secured_bags_money_multiplier = {
		name_id = "menu_secured_bags_money_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "secured_bags_money_multiplier",
			category = "player"
		}
	}
	self.definitions.player_silent_kill = {
		name_id = "menu_player_silent_kill",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silent_kill",
			category = "player"
		}
	}
	self.definitions.player_melee_knockdown_mul = {
		name_id = "menu_player_melee_knockdown_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_knockdown_mul",
			category = "player"
		}
	}
	self.definitions.player_suppression_mul_2 = {
		name_id = "menu_player_suppression_mul_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "suppression_multiplier",
			category = "player"
		}
	}
	self.definitions.player_damage_dampener = {
		name_id = "menu_player_damage_dampener",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_dampener",
			category = "player"
		}
	}
	self.definitions.player_melee_damage_dampener = {
		name_id = "menu_player_melee_damage_dampener",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "melee_damage_dampener",
			category = "player"
		}
	}
	self.definitions.player_marked_enemy_extra_damage = {
		name_id = "menu_player_marked_enemy_extra_damage",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "marked_enemy_extra_damage",
			category = "player"
		}
	}
	self.definitions.player_civ_intimidation_mul = {
		name_id = "menu_player_civ_intimidation_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_intimidation_mul",
			category = "player"
		}
	}
	self.definitions.player_civ_harmless_bullets = {
		name_id = "menu_player_civ_harmless_bullets",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_harmless_bullets",
			category = "player"
		}
	}
	self.definitions.player_civ_harmless_melee = {
		name_id = "menu_player_civ_harmless_melee",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_harmless_melee",
			category = "player"
		}
	}
	self.definitions.player_civ_calming_alerts = {
		name_id = "menu_player_civ_calming_alerts",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civ_calming_alerts",
			category = "player"
		}
	}
	self.definitions.player_special_enemy_highlight = {
		name_id = "menu_player_special_enemy_highlight",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "special_enemy_highlight",
			category = "player"
		}
	}
	self.definitions.player_drill_alert = {
		name_id = "menu_player_drill_alert",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_alert_rad",
			category = "player"
		}
	}
	self.definitions.player_silent_drill = {
		name_id = "menu_player_silent_drill",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silent_drill",
			category = "player"
		}
	}
	self.definitions.player_drill_speed_multiplier1 = {
		name_id = "menu_player_drill_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_drill_speed_multiplier2 = {
		name_id = "menu_player_drill_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "drill_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_saw_speed_multiplier_1 = {
		name_id = "menu_player_saw_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "saw_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_saw_speed_multiplier_2 = {
		name_id = "menu_player_saw_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "saw_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_drill_fix_interaction_speed_multiplier = {
		name_id = "menu_player_drill_fix_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_fix_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_dye_pack_chance_multiplier = {
		name_id = "menu_player_dye_pack_chance_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dye_pack_chance_multiplier",
			category = "player"
		}
	}
	self.definitions.player_dye_pack_cash_loss_multiplier = {
		name_id = "menu_player_dye_pack_cash_loss_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dye_pack_cash_loss_multiplier",
			category = "player"
		}
	}
	self.definitions.player_cheat_death_chance = {
		name_id = "menu_player_cheat_death_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cheat_death_chance",
			category = "player"
		}
	}
	self.definitions.player_additional_lives_1 = {
		name_id = "menu_player_additional_lives_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "additional_lives",
			category = "player"
		}
	}
	self.definitions.player_additional_lives_2 = {
		name_id = "menu_player_additional_lives_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "additional_lives",
			category = "player"
		}
	}
	self.definitions.player_trip_mine_shaped_charge = {
		name_id = "menu_player_trip_mine_shaped_charge",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "trip_mine_shaped_charge",
			category = "player"
		}
	}
	self.definitions.player_small_loot_multiplier1 = {
		name_id = "menu_player_small_loot_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "small_loot_multiplier",
			category = "player"
		}
	}
	self.definitions.player_small_loot_multiplier2 = {
		name_id = "menu_player_small_loot_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "small_loot_multiplier",
			category = "player"
		}
	}
	self.definitions.player_intimidate_enemies = {
		name_id = "menu_player_intimidate_enemies",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_enemies",
			category = "player"
		}
	}
	self.definitions.player_intimidate_specials = {
		name_id = "menu_player_intimidate_specials",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_specials",
			category = "player"
		}
	}
	self.definitions.player_passive_empowered_intimidation = {
		name_id = "menu_player_passive_empowered_intimidation",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "empowered_intimidation_mul",
			category = "player"
		}
	}
	self.definitions.player_intimidation_multiplier = {
		name_id = "menu_player_intimidation_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidation_multiplier",
			category = "player"
		}
	}
	self.definitions.player_sentry_gun_deploy_time_multiplier = {
		name_id = "menu_player_sentry_gun_deploy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sentry_gun_deploy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_trip_mine_deploy_time_multiplier = {
		incremental = true,
		name_id = "menu_player_trip_mine_deploy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "trip_mine_deploy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_trip_mine_deploy_time_multiplier_2 = {
		incremental = true,
		name_id = "menu_player_trip_mine_deploy_time_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "trip_mine_deploy_time_multiplier",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies = {
		name_id = "menu_player_convert_enemies",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_max_minions_1 = {
		name_id = "menu_player_convert_enemies_max_minions",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_max_minions",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_max_minions_2 = {
		name_id = "menu_player_convert_enemies_max_minions",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "convert_enemies_max_minions",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_interaction_speed_multiplier = {
		name_id = "menu_player_convert_enemies_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_interaction_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_health_multiplier = {
		name_id = "menu_player_convert_enemies_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier = {
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_convert_enemies_health_multiplier",
			category = "player"
		}
	}
	self.definitions.player_convert_enemies_damage_multiplier = {
		name_id = "menu_player_convert_enemies_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "convert_enemies_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_convert_enemies_damage_multiplier = {
		name_id = "menu_player_passive_convert_enemies_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_convert_enemies_damage_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_intimidate_range_mul = {
		name_id = "menu_player_intimidate_range_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_intimidate_range_mul",
			category = "player"
		}
	}
	self.definitions.player_intimidate_range_mul = {
		name_id = "menu_player_intimidate_range_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_range_mul",
			category = "player"
		}
	}
	self.definitions.player_intimidate_aura = {
		name_id = "menu_player_intimidate_aura",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "intimidate_aura",
			category = "player"
		}
	}
	self.definitions.player_civilian_gives_ammo = {
		name_id = "menu_player_civilian_gives_ammo",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "civilian_gives_ammo",
			category = "player"
		}
	}
	self.definitions.player_drill_autorepair = {
		name_id = "menu_player_drill_autorepair",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "drill_autorepair",
			category = "player"
		}
	}
	self.definitions.player_hostage_trade = {
		name_id = "menu_player_hostage_trade",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hostage_trade",
			category = "player"
		}
	}
	self.definitions.player_sec_camera_highlight = {
		name_id = "menu_player_sec_camera_highlight",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sec_camera_highlight",
			category = "player"
		}
	}
	self.definitions.player_sec_camera_highlight_mask_off = {
		name_id = "menu_player_sec_camera_highlight_mask_off",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sec_camera_highlight_mask_off",
			category = "player"
		}
	}
	self.definitions.player_special_enemy_highlight_mask_off = {
		name_id = "menu_player_special_enemy_highlight_mask_off",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "special_enemy_highlight_mask_off",
			category = "player"
		}
	}
	self.definitions.player_morale_boost = {
		name_id = "menu_player_morale_boost",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "morale_boost",
			category = "player"
		}
	}
	self.definitions.player_morale_boost_cooldown_multiplier = {
		name_id = "menu_player_morale_boost_cooldown_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "morale_boost_cooldown_multiplier",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_easy = {
		name_id = "menu_player_pick_lock_easy",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_easy",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_hard = {
		name_id = "menu_player_pick_lock_hard",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_hard",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_easy_speed_multiplier = {
		name_id = "menu_player_pick_lock_easy_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_pick_lock_easy_speed_multiplier_2 = {
		name_id = "menu_player_pick_lock_easy_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_loot_drop_multiplier_1 = {
		name_id = "menu_player_loot_drop_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "loot_drop_multiplier",
			category = "player"
		}
	}
	self.definitions.player_loot_drop_multiplier_2 = {
		name_id = "menu_player_loot_drop_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "loot_drop_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_loot_drop_multiplier = {
		name_id = "menu_player_passive_loot_drop_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_loot_drop_multiplier",
			category = "player"
		}
	}
	self.definitions.weapon_passive_armor_piercing_chance = {
		name_id = "menu_weapon_passive_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance",
			category = "weapon"
		}
	}
	self.definitions.weapon_armor_piercing_chance_2 = {
		name_id = "menu_weapon_armor_piercing_chance_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_2",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_armor_piercing_chance_1 = {
		incremental = true,
		name_id = "menu_weapon_silencer_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_silencer",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_armor_piercing_chance_2 = {
		incremental = true,
		name_id = "menu_weapon_silencer_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_silencer",
			category = "weapon"
		}
	}
	self.definitions.player_passive_armor_movement_penalty_multiplier = {
		name_id = "menu_passive_armor_movement_penalty_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_armor_movement_penalty_multiplier",
			category = "player"
		}
	}
	self.definitions.player_buy_cost_multiplier_1 = {
		name_id = "menu_player_buy_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "buy_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_buy_cost_multiplier_2 = {
		name_id = "menu_player_buy_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "buy_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_crime_net_deal = {
		name_id = "menu_player_crime_net_deal",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crime_net_deal",
			category = "player"
		}
	}
	self.definitions.player_crime_net_deal_2 = {
		name_id = "menu_player_crime_net_deal",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "crime_net_deal",
			category = "player"
		}
	}
	self.definitions.player_sell_cost_multiplier_1 = {
		name_id = "menu_player_sell_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sell_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_crafting_weapon_multiplier = {
		name_id = "menu_player_crafting_weapon_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_weapon_multiplier_1 = {
		name_id = "menu_player_crafting_weapon_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_weapon_multiplier_2 = {
		name_id = "menu_player_crafting_weapon_multiplier_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_weapon_multiplier_3 = {
		name_id = "menu_player_crafting_weapon_multiplier_3",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_crafting_weapon_multiplier",
			category = "player"
		}
	}
	self.definitions.player_crafting_mask_multiplier = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_mask_multiplier_1 = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_mask_multiplier_2 = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_passive_crafting_mask_multiplier_3 = {
		name_id = "menu_player_crafting_mask_multiplier",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "passive_crafting_mask_multiplier",
			category = "player"
		}
	}
	self.definitions.player_additional_assets = {
		name_id = "menu_player_additional_assets",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "additional_assets",
			category = "player"
		}
	}
	self.definitions.player_assets_cost_multiplier = {
		name_id = "menu_player_assets_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "assets_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_assets_cost_multiplier_b = {
		name_id = "menu_player_assets_cost_multiplier_b",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "assets_cost_multiplier_b",
			category = "player"
		}
	}
	self.definitions.player_premium_contract_cost_multiplier = {
		name_id = "menu_player_premium_contract_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "premium_contract_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.passive_player_assets_cost_multiplier = {
		name_id = "menu_passive_player_assets_cost_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_assets_cost_multiplier",
			category = "player"
		}
	}
	self.definitions.player_revive_health_boost = {
		name_id = "menu_player_revive_health_boost",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "revive_health_boost",
			category = "player"
		}
	}
	self.definitions.player_run_and_shoot = {
		name_id = "menu_player_run_and_shoot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_and_shoot",
			category = "player"
		}
	}
	self.definitions.player_carry_sentry_and_trip = {
		name_id = "menu_player_carry_sentry_and_trip",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "carry_sentry_and_trip",
			category = "player"
		}
	}
	self.definitions.player_run_and_reload = {
		name_id = "menu_player_run_and_reload",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "run_and_reload",
			category = "player"
		}
	}
	self.definitions.player_level_interaction_timer_multiplier = {
		name_id = "menu_player_level_interaction_timer_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "level_interaction_timer_multiplier",
			category = "player"
		}
	}
	self.definitions.player_steelsight_normal_movement_speed = {
		name_id = "menu_player_steelsight_normal_movement_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "steelsight_normal_movement_speed",
			category = "player"
		}
	}
	self.definitions.player_headshot_regen_armor_bonus_1 = {
		name_id = "menu_player_headshot_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "headshot_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_headshot_regen_armor_bonus_2 = {
		name_id = "menu_player_headshot_regen_armor_bonus",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "headshot_regen_armor_bonus",
			category = "player"
		}
	}
	self.definitions.player_resist_firing_tased = {
		name_id = "menu_player_resist_firing_tased",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "resist_firing_tased",
			category = "player"
		}
	}
	self.definitions.player_crouch_dodge_chance_1 = {
		name_id = "menu_player_crouch_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crouch_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_crouch_dodge_chance_2 = {
		name_id = "menu_player_crouch_dodge_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "crouch_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_on_zipline_dodge_chance = {
		name_id = "menu_player_on_zipline_dodge_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "on_zipline_dodge_chance",
			category = "player"
		}
	}
	self.definitions.player_movement_speed_multiplier = {
		name_id = "menu_player_movement_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "movement_speed_multiplier",
			category = "player"
		}
	}
	self.definitions.player_tape_loop_duration_1 = {
		name_id = "menu_player_tape_loop_duration",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tape_loop_duration",
			category = "player"
		}
	}
	self.definitions.player_tape_loop_duration_2 = {
		name_id = "menu_player_tape_loop_duration",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "tape_loop_duration",
			category = "player"
		}
	}
	self.definitions.player_tape_loop_interact_distance_mul_1 = {
		name_id = "menu_player_tape_loop_interact_distance_mul",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "tape_loop_interact_distance_mul",
			category = "player"
		}
	}
	self.definitions.player_buy_spotter_asset = {
		name_id = "menu_player_buy_spotter_asset",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "buy_spotter_asset",
			category = "player"
		}
	}
	self.definitions.player_gangster_damage_dampener_1 = {
		name_id = "menu_player_gangster_damage_dampener",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "gangster_damage_dampener",
			category = "player"
		}
	}
	self.definitions.player_gangster_damage_dampener_2 = {
		name_id = "menu_player_gangster_damage_dampener",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "gangster_damage_dampener",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_1 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_2 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_3 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_4 = {
		name_id = "menu_player_damage_to_hot",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "damage_to_hot",
			category = "player"
		}
	}
	self.definitions.player_damage_to_hot_extra_ticks = {
		name_id = "menu_player_damage_to_hot_extra_ticks",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_to_hot_extra_ticks",
			category = "player"
		}
	}
	self.definitions.player_armor_piercing_chance_1 = {
		name_id = "menu_player_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance",
			category = "player"
		}
	}
	self.definitions.player_armor_piercing_chance_2 = {
		name_id = "menu_player_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_piercing_chance",
			category = "player"
		}
	}
	self.definitions.toolset = {
		description_text_id = "toolset",
		category = "equipment",
		equipment_id = "toolset",
		tree = 4,
		image = "upgrades_toolset",
		image_slice = "upgrades_toolset_slice",
		title_id = "debug_upgrade_player_upgrade",
		slot = 2,
		subtitle_id = "debug_upgrade_toolset1",
		name_id = "debug_upgrade_toolset1",
		icon = "equipment_toolset",
		unlock_lvl = 0,
		step = 1,
		aquire = {
			upgrade = "toolset1"
		}
	}

	for i, _ in ipairs(self.values.player.toolset) do
		local depends_on = i - 1 > 0 and "toolset" .. i - 1
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["toolset" .. i] = {
			description_text_id = "toolset",
			tree = 4,
			image = "upgrades_toolset",
			image_slice = "upgrades_toolset_slice",
			title_id = "debug_upgrade_player_upgrade",
			category = "feature",
			icon = "equipment_toolset",
			step = self.steps.player.toolset[i],
			subtitle_id = "debug_upgrade_toolset" .. i,
			name_id = "debug_upgrade_toolset" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "toolset",
				category = "player",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_trip_mine_definitions()
	self.definitions.trip_mine = {
		description_text_id = "trip_mine",
		category = "equipment",
		slot = 1,
		equipment_id = "trip_mine",
		tree = 2,
		image = "upgrades_tripmines",
		image_slice = "upgrades_tripmines_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_trip_mine",
		name_id = "debug_trip_mine",
		icon = "equipment_trip_mine",
		unlock_lvl = 0,
		step = 4
	}
	self.definitions.trip_mine_can_switch_on_off = {
		name_id = "menu_trip_mine_can_switch_on_off",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_switch_on_off",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_sensor_toggle = {
		name_id = "menu_trip_mine_sensor_toggle",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sensor_toggle",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_sensor_highlight = {
		name_id = "menu_trip_mine_sensor_toggle",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sensor_highlight",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_quantity_increase_1 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "quantity_1",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_quantity_increase_2 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "quantity_2",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_quantity_increase_3 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "quantity_3",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_explosion_size_multiplier_1 = {
		incremental = true,
		name_id = "menu_trip_mine_explosion_size_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explosion_size_multiplier_1",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_explosion_size_multiplier_2 = {
		incremental = true,
		name_id = "menu_trip_mine_explosion_size_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explosion_size_multiplier_2",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_explode_timer_delay = {
		incremental = true,
		name_id = "menu_trip_mine_explode_timer_delay",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explode_timer_delay",
			category = "trip_mine"
		}
	}
	self.definitions.trip_mine_marked_enemy_extra_damage = {
		name_id = "menu_trip_mine_marked_enemy_extra_damage",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "marked_enemy_extra_damage",
			category = "trip_mine"
		}
	}
end

function UpgradesTweakData:_ecm_jammer_definitions()
	self.definitions.ecm_jammer = {
		name_id = "menu_equipment_ecm_jammer",
		slot = 1,
		equipment_id = "ecm_jammer",
		category = "equipment"
	}
	self.definitions.ecm_jammer_can_activate_feedback = {
		name_id = "menu_ecm_jammer_can_activate_feedback",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_activate_feedback",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_can_open_sec_doors = {
		name_id = "menu_ecm_jammer_can_open_sec_doors",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_open_sec_doors",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_quantity_increase_1 = {
		name_id = "menu_ecm_jammer_quantity_1",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_quantity_increase_2 = {
		name_id = "menu_ecm_jammer_quantity_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 2,
			upgrade = "quantity",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_duration_multiplier = {
		name_id = "menu_ecm_jammer_duration_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "duration_multiplier",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_duration_multiplier_2 = {
		name_id = "menu_ecm_jammer_duration_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "duration_multiplier_2",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_affects_cameras = {
		name_id = "menu_ecm_jammer_affects_cameras",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "affects_cameras",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_affects_pagers = {
		name_id = "",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "affects_pagers",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_feedback_duration_boost = {
		name_id = "menu_ecm_jammer_feedback_duration_boost",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "feedback_duration_boost",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_feedback_duration_boost_2 = {
		name_id = "menu_ecm_jammer_feedback_duration_boost_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "feedback_duration_boost_2",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_interaction_speed_multiplier = {
		name_id = "menu_ecm_jammer_interaction_speed_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "interaction_speed_multiplier",
			category = "ecm_jammer"
		}
	}
	self.definitions.ecm_jammer_can_retrigger = {
		name_id = "menu_ecm_jammer_can_retrigger",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_retrigger",
			category = "ecm_jammer"
		}
	}
end

function UpgradesTweakData:_ammo_bag_definitions()
	self.definitions.ammo_bag = {
		description_text_id = "ammo_bag",
		category = "equipment",
		slot = 1,
		equipment_id = "ammo_bag",
		tree = 1,
		image = "upgrades_ammobag",
		image_slice = "upgrades_ammobag_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_ammo_bag",
		name_id = "debug_ammo_bag",
		icon = "equipment_ammo_bag",
		unlock_lvl = 0,
		step = 2
	}

	for i, _ in ipairs(self.values.ammo_bag.ammo_increase) do
		local depends_on = i - 1 > 0 and "ammo_bag_ammo_increase" .. i - 1 or "ammo_bag"
		local unlock_lvl = 11
		local prio = i == 1 and "high"
		self.definitions["ammo_bag_ammo_increase" .. i] = {
			description_text_id = "ammo_bag_increase",
			tree = 1,
			image = "upgrades_ammobag",
			image_slice = "upgrades_ammobag_slice",
			title_id = "debug_ammo_bag",
			category = "equipment_upgrade",
			icon = "equipment_ammo_bag",
			step = self.steps.ammo_bag.ammo_increase[i],
			name_id = "debug_upgrade_ammo_bag_ammo_increase" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "ammo_increase",
				category = "ammo_bag",
				value = i
			}
		}
	end

	self.definitions.ammo_bag_quantity = {
		name_id = "menu_ammo_bag_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "ammo_bag"
		}
	}
end

function UpgradesTweakData:_doctor_bag_definitions()
	self.definitions.doctor_bag = {
		description_text_id = "doctor_bag",
		category = "equipment",
		slot = 1,
		equipment_id = "doctor_bag",
		tree = 3,
		image = "upgrades_doctorbag",
		image_slice = "upgrades_doctorbag_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_doctor_bag",
		name_id = "debug_doctor_bag",
		icon = "equipment_doctor_bag",
		unlock_lvl = 2,
		step = 5
	}

	for i, _ in ipairs(self.values.doctor_bag.amount_increase) do
		local depends_on = i - 1 > 0 and "doctor_bag_amount_increase" .. i - 1 or "doctor_bag"
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["doctor_bag_amount_increase" .. i] = {
			description_text_id = "doctor_bag_increase",
			tree = 3,
			image = "upgrades_doctorbag",
			image_slice = "upgrades_doctorbag_slice",
			title_id = "debug_doctor_bag",
			category = "equipment_upgrade",
			icon = "equipment_doctor_bag",
			step = self.steps.doctor_bag.amount_increase[i],
			name_id = "debug_upgrade_doctor_bag_amount_increase" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "amount_increase",
				category = "doctor_bag",
				value = i
			}
		}
	end

	self.definitions.doctor_bag_quantity = {
		name_id = "menu_doctor_bag_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "doctor_bag"
		}
	}
	self.definitions.passive_doctor_bag_interaction_speed_multiplier = {
		name_id = "menu_passive_doctor_bag_interaction_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "interaction_speed_multiplier",
			category = "doctor_bag"
		}
	}
end

function UpgradesTweakData:_cable_tie_definitions()
	self.definitions.cable_tie = {
		equipment_id = "cable_tie",
		image = "upgrades_extracableties",
		image_slice = "upgrades_extracableties_slice",
		title_id = "debug_equipment_cable_tie",
		prio = "high",
		category = "equipment",
		name_id = "debug_equipment_cable_tie",
		icon = "equipment_cable_ties",
		unlock_lvl = 0
	}
	self.definitions.extra_cable_tie = {
		description_text_id = "extra_cable_tie",
		category = "equipment",
		equipment_id = "extra_cable_tie",
		tree = 1,
		image = "upgrades_extracableties",
		image_slice = "upgrades_extracableties_slice",
		slot = 2,
		title_id = "debug_equipment_cable_tie",
		prio = "high",
		subtitle_id = "debug_upgrade_amount_increase1",
		name_id = "debug_upgrade_extra_cable_tie_quantity1",
		icon = "equipment_extra_cable_ties",
		unlock_lvl = 3,
		step = 4,
		aquire = {
			upgrade = "extra_cable_tie_quantity1"
		}
	}

	for i, _ in ipairs(self.values.extra_cable_tie.quantity) do
		local depends_on = i - 1 > 0 and "extra_cable_tie_quantity" .. i - 1 or "extra_cable_tie"
		local unlock_lvl = 4
		local prio = i == 1 and "high"
		self.definitions["extra_cable_tie_quantity" .. i] = {
			description_text_id = "extra_cable_tie",
			tree = 1,
			image = "upgrades_extracableties",
			image_slice = "upgrades_extracableties_slice",
			title_id = "debug_equipment_cable_tie",
			category = "equipment_upgrade",
			icon = "equipment_extra_cable_ties",
			step = self.steps.extra_cable_tie.quantity[i],
			name_id = "debug_upgrade_extra_cable_tie_quantity" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				upgrade = "quantity",
				category = "extra_cable_tie",
				value = i
			}
		}
	end

	self.definitions.cable_tie_quantity = {
		name_id = "menu_cable_tie_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity_1",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_quantity_2 = {
		name_id = "menu_cable_tie_quantity_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity_2",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_interact_speed_multiplier = {
		name_id = "menu_cable_tie_interact_speed_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "interact_speed_multiplier",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_can_cable_tie_doors = {
		name_id = "menu_cable_tie_can_cable_tie_doors",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "can_cable_tie_doors",
			category = "cable_tie"
		}
	}
	self.definitions.cable_tie_quantity_unlimited = {
		name_id = "menu_cable_tie_quantity_unlimited",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity_unlimited",
			category = "cable_tie"
		}
	}
end

function UpgradesTweakData:_armor_kit_definitions()
	self.definitions.armor_kit = {
		name_id = "menu_equipment_armor_kit",
		slot = 1,
		equipment_id = "armor_kit",
		category = "equipment"
	}
end

function UpgradesTweakData:_sentry_gun_definitions()
	self.definitions.sentry_gun = {
		description_text_id = "sentry_gun",
		category = "equipment",
		slot = 1,
		equipment_id = "sentry_gun",
		tree = 4,
		image = "upgrades_sentry",
		image_slice = "upgrades_sentry_slice",
		title_id = "debug_upgrade_new_equipment",
		prio = "high",
		subtitle_id = "debug_sentry_gun",
		name_id = "debug_sentry_gun",
		icon = "equipment_sentry",
		unlock_lvl = 0,
		step = 5
	}
	self.definitions.sentry_gun_quantity_increase = {
		name_id = "menu_sentry_gun_quantity_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_damage_multiplier = {
		name_id = "menu_sentry_gun_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "damage_multiplier",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_extra_ammo_multiplier_1 = {
		incremental = true,
		name_id = "menu_sentry_gun_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "extra_ammo_multiplier",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_extra_ammo_multiplier_2 = {
		incremental = true,
		name_id = "menu_sentry_gun_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "extra_ammo_multiplier",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_multiplier = {
		name_id = "menu_sentry_gun_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_multiplier",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_multiplier2 = {
		name_id = "menu_sentry_gun_armor_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_multiplier2",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_spread_multiplier = {
		name_id = "menu_sentry_gun_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_multiplier",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_rot_speed_multiplier = {
		name_id = "menu_sentry_gun_rot_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "rot_speed_multiplier",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_shield = {
		name_id = "menu_sentry_gun_shield",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "shield",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_can_revive = {
		name_id = "menu_sentry_gun_can_revive",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_revive",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_can_reload = {
		name_id = "menu_sentry_gun_can_reload",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "can_reload",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_piercing_chance = {
		name_id = "menu_sentry_gun_armor_piercing_chance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance",
			category = "sentry_gun"
		}
	}
	self.definitions.sentry_gun_armor_piercing_chance_2 = {
		name_id = "menu_sentry_gun_armor_piercing_chance_2",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_piercing_chance_2",
			category = "sentry_gun"
		}
	}
end

function UpgradesTweakData:_rep_definitions()
	local rep_upgrades = self.values.rep_upgrades

	for index, rep_class in ipairs(rep_upgrades.classes) do
		for i = 1, 10 do
			self.definitions[rep_class .. i] = {
				category = "rep_upgrade",
				value = rep_upgrades.values[index]
			}
		end
	end
end

function UpgradesTweakData:_weapon_upgrades_definitions()
	self.definitions.assault_rifle_move_spread_index_addend = {
		name_id = "menu_assault_rifle_move_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_index_addend",
			category = "assault_rifle"
		}
	}
	self.definitions.snp_move_spread_index_addend = {
		name_id = "menu_snp_move_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_spread_index_addend",
			category = "snp"
		}
	}
	self.definitions.weapon_silencer_spread_index_addend = {
		name_id = "menu_weapon_silencer_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_spread_index_addend",
			category = "weapon"
		}
	}
	self.definitions.pistol_spread_index_addend = {
		name_id = "menu_pistol_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_index_addend",
			category = "pistol"
		}
	}
	self.definitions.akimbo_spread_index_addend = {
		name_id = "menu_akimbo_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.shotgun_hip_fire_spread_index_addend = {
		name_id = "menu_shotgun_hip_fire_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_index_addend",
			category = "shotgun"
		}
	}
	self.definitions.weapon_hip_fire_spread_index_addend = {
		name_id = "menu_weapon_hip_fire_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_fire_spread_index_addend",
			category = "weapon"
		}
	}
	self.definitions.weapon_single_spread_index_addend = {
		name_id = "menu_weapon_single_spread_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "single_spread_index_addend",
			category = "weapon"
		}
	}
	self.definitions.shotgun_recoil_index_addend = {
		name_id = "menu_shotgun_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "shotgun"
		}
	}
	self.definitions.assault_rifle_recoil_index_addend = {
		name_id = "menu_assault_rifle_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "assault_rifle"
		}
	}
	self.definitions.lmg_recoil_index_addend = {
		name_id = "menu_lmg_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "lmg"
		}
	}
	self.definitions.snp_recoil_index_addend = {
		name_id = "menu_snp_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "snp"
		}
	}
	self.definitions.akimbo_recoil_index_addend_1 = {
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_index_addend_2 = {
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.akimbo_recoil_index_addend_3 = {
		name_id = "menu_akimbo_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.weapon_silencer_recoil_index_addend = {
		name_id = "menu_weapon_silencer_recoil_index_addend",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_recoil_index_addend",
			category = "weapon"
		}
	}
	self.definitions.weapon_modded_damage_multiplier = {
		name_id = "menu_modded_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "modded_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_modded_spread_multiplier = {
		name_id = "menu_modded_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "modded_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_modded_recoil_multiplier = {
		name_id = "menu_modded_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "modded_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_clip_ammo_increase_1 = {
		name_id = "menu_weapon_clip_ammo_increase_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "clip_ammo_increase",
			category = "weapon"
		}
	}
	self.definitions.weapon_clip_ammo_increase_2 = {
		name_id = "menu_weapon_clip_ammo_increase_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "clip_ammo_increase",
			category = "weapon"
		}
	}
	self.definitions.weapon_swap_speed_multiplier = {
		name_id = "menu_weapon_swap_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "swap_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_single_spread_multiplier = {
		name_id = "menu_weapon_single_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "single_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_spread_multiplier = {
		name_id = "menu_silencer_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_recoil_multiplier = {
		name_id = "menu_silencer_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_damage_multiplier_1 = {
		name_id = "silencer_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "silencer_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_silencer_damage_multiplier_2 = {
		name_id = "silencer_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "silencer_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_reload_speed_multiplier = {
		name_id = "menu_weapon_reload_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_reload_speed_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_recoil_multiplier_1 = {
		name_id = "menu_weapon_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_recoil_multiplier_2 = {
		name_id = "menu_weapon_recoil_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_headshot_damage_multiplier = {
		name_id = "menu_weapon_headshot_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_headshot_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_passive_damage_multiplier = {
		name_id = "menu_weapon_passive_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_damage_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_special_damage_taken_multiplier = {
		name_id = "menu_weapon_special_damage_taken_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "special_damage_taken_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_spread_multiplier = {
		name_id = "menu_weapon_spread_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.weapon_fire_rate_multiplier = {
		name_id = "menu_weapon_fire_rate_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "fire_rate_multiplier",
			category = "weapon"
		}
	}
end

function UpgradesTweakData:_carry_definitions()
	self.definitions.carry_throw_distance_multiplier = {
		name_id = "menu_carry_throw_distance_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "throw_distance_multiplier",
			category = "carry"
		}
	}
	self.definitions.carry_interact_speed_multiplier_1 = {
		name_id = "menu_carry_interact_speed_multiplierr",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "interact_speed_multiplier",
			category = "carry"
		}
	}
	self.definitions.carry_catch_interaction_speed_1 = {
		name_id = "menu_carry_catch_interaction_speed",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "catch_interaction_speed",
			category = "carry"
		}
	}
	self.definitions.carry_interact_speed_multiplier_2 = {
		name_id = "menu_carry_interact_speed_multiplierr",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "interact_speed_multiplier",
			category = "carry"
		}
	}
	self.definitions.carry_catch_interaction_speed_2 = {
		name_id = "menu_carry_catch_interaction_speed",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "catch_interaction_speed",
			category = "carry"
		}
	}
end

function UpgradesTweakData:_team_definitions()
	self.definitions.team_pistol_recoil_index_addend = {
		name_id = "menu_team_pistol_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "pistol"
		}
	}
	self.definitions.team_akimbo_recoil_index_addend = {
		name_id = "menu_team_akimbo_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.team_weapon_recoil_index_addend = {
		name_id = "menu_team_weapon_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_index_addend",
			category = "weapon"
		}
	}
	self.definitions.team_pistol_suppression_recoil_index_addend = {
		name_id = "menu_team_pistol_suppression_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_index_addend",
			category = "pistol"
		}
	}
	self.definitions.team_akimbo_suppression_recoil_index_addend = {
		name_id = "menu_team_akimbo_suppression_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_index_addend",
			category = "akimbo"
		}
	}
	self.definitions.team_weapon_suppression_recoil_index_addend = {
		name_id = "menu_team_weapon_suppression_recoil_index_addend",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_index_addend",
			category = "weapon"
		}
	}
	self.definitions.team_pistol_suppression_recoil_multiplier = {
		name_id = "menu_team_pistol_suppression_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_multiplier",
			category = "pistol"
		}
	}
	self.definitions.team_akimbo_suppression_recoil_multiplier = {
		name_id = "menu_team_akimbo_suppression_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.team_pistol_recoil_multiplier = {
		name_id = "menu_team_pistol_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "pistol"
		}
	}
	self.definitions.team_akimbo_recoil_multiplier = {
		name_id = "menu_team_akimbo_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "akimbo"
		}
	}
	self.definitions.team_weapon_suppression_recoil_multiplier = {
		name_id = "menu_team_weapon_suppression_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "suppression_recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.team_weapon_recoil_multiplier = {
		name_id = "menu_team_weapon_recoil_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "recoil_multiplier",
			category = "weapon"
		}
	}
	self.definitions.team_xp_multiplier = {
		name_id = "menu_team_xp_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "multiplier",
			category = "xp"
		}
	}
	self.definitions.team_armor_regen_time_multiplier = {
		name_id = "menu_team_armor_regen_time_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "regen_time_multiplier",
			category = "armor"
		}
	}
	self.definitions.team_passive_armor_regen_time_multiplier = {
		name_id = "menu_team_armor_regen_time_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "passive_regen_time_multiplier",
			category = "armor"
		}
	}
	self.definitions.team_stamina_multiplier = {
		name_id = "menu_team_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_passive_stamina_multiplier_1 = {
		name_id = "menu_team_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "passive_multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_passive_stamina_multiplier_2 = {
		name_id = "menu_team_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 2,
			upgrade = "passive_multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_passive_health_multiplier = {
		name_id = "menu_team_health_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "passive_multiplier",
			category = "health"
		}
	}
	self.definitions.team_hostage_health_multiplier = {
		name_id = "menu_team_hostage_health_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hostage_multiplier",
			category = "health"
		}
	}
	self.definitions.team_hostage_stamina_multiplier = {
		name_id = "menu_team_hostage_stamina_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hostage_multiplier",
			category = "stamina"
		}
	}
	self.definitions.team_clients_buy_assets = {
		name_id = "menu_team_clients_buy_assets",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "clients_buy_assets",
			category = "player"
		}
	}
	self.definitions.team_move_spread_multiplier = {
		name_id = "menu_team_move_spread_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "move_spread_multiplier",
			category = "weapon"
		}
	}
	self.definitions.team_civ_intimidation_mul = {
		name_id = "menu_team_civ_intimidation_mul",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "civ_intimidation_mul",
			category = "player"
		}
	}
	self.definitions.team_xp_stealth_multiplier = {
		name_id = "menu_team_xp_stealth_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "stealth_multiplier",
			category = "xp"
		}
	}
	self.definitions.team_cash_stealth_multiplier = {
		name_id = "menu_team_cash_stealth_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "stealth_money_multiplier",
			category = "cash"
		}
	}
	self.definitions.team_bags_stealth_multiplier = {
		name_id = "menu_team_bags_stealth_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "stealth_bags_multiplier",
			category = "cash"
		}
	}
	self.definitions.team_hostage_damage_dampener_multiplier = {
		name_id = "menu_team_hostage_damage_dampener_multiplier",
		category = "team",
		upgrade = {
			value = 1,
			upgrade = "hostage_multiplier",
			category = "damage_dampener"
		}
	}
end

function UpgradesTweakData:_temporary_definitions()
	self.definitions.temporary_combat_medic_damage_multiplier1 = {
		incremental = true,
		name_id = "menu_temporary_combat_medic_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "combat_medic_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_combat_medic_damage_multiplier2 = {
		incremental = true,
		name_id = "menu_temporary_combat_medic_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "combat_medic_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_revive_health_boost = {
		name_id = "menu_temporary_revive_health_boost",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "revive_health_boost",
			category = "temporary"
		}
	}
	self.definitions.temporary_berserker_damage_multiplier_1 = {
		name_id = "menu_temporary_berserker_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "berserker_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_berserker_damage_multiplier_2 = {
		name_id = "menu_temporary_berserker_damage_multiplier",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "berserker_damage_multiplier",
			category = "temporary"
		}
	}
	self.definitions.temporary_no_ammo_cost_buff = {
		name_id = "menu_temporary_no_ammo_cost_buff",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "no_ammo_cost_buff",
			category = "temporary"
		}
	}
	self.definitions.temporary_no_ammo_cost_1 = {
		name_id = "menu_temporary_no_ammo_cost_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "no_ammo_cost",
			category = "temporary"
		}
	}
	self.definitions.temporary_no_ammo_cost_2 = {
		name_id = "menu_temporary_no_ammo_cost_2",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "no_ammo_cost",
			category = "temporary"
		}
	}
	self.definitions.temporary_first_aid_damage_reduction = {
		name_id = "menu_temporary_first_aid_damage_reduction",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "first_aid_damage_reduction",
			category = "temporary"
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_1 = {
		name_id = "menu_passive_revive_damage_reduction_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "passive_revive_damage_reduction_1",
			category = "temporary"
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_2 = {
		name_id = "menu_passive_revive_damage_reduction",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "passive_revive_damage_reduction",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_restore_health_1 = {
		name_id = "menu_temporary_loose_ammo_restore_health",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_restore_health",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_restore_health_2 = {
		name_id = "menu_temporary_loose_ammo_restore_health",
		category = "temporary",
		upgrade = {
			value = 2,
			upgrade = "loose_ammo_restore_health",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_restore_health_3 = {
		name_id = "menu_temporary_loose_ammo_restore_health",
		category = "temporary",
		upgrade = {
			value = 3,
			upgrade = "loose_ammo_restore_health",
			category = "temporary"
		}
	}
	self.definitions.temporary_loose_ammo_give_team = {
		name_id = "menu_temporary_loose_ammo_give_team",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = "loose_ammo_give_team",
			category = "temporary"
		}
	}
end

function UpgradesTweakData:_shape_charge_definitions()
	self.definitions.shape_charge = {
		name_id = "menu_shape_charge",
		equipment_id = "shape_charge",
		category = "equipment"
	}
end

function UpgradesTweakData:_first_aid_kit_definitions()
	self.definitions.first_aid_kit = {
		name_id = "menu_equipment_first_aid_kit",
		slot = 1,
		equipment_id = "first_aid_kit",
		category = "equipment"
	}
	self.definitions.first_aid_kit_quantity_increase_1 = {
		incremental = true,
		name_id = "menu_first_aid_kit_quantity_1",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_quantity_increase_2 = {
		incremental = true,
		name_id = "menu_first_aid_kit_quantity_2",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_deploy_time_multiplier = {
		incremental = true,
		name_id = "menu_first_aid_kit_deploy_time_multiplier",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "deploy_time_multiplier",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_damage_reduction_upgrade = {
		incremental = true,
		name_id = "menu_first_aid_kit_damage_reduction_upgrade",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "damage_reduction_upgrade",
			category = "first_aid_kit"
		}
	}
	self.definitions.first_aid_kit_downs_restore_chance = {
		incremental = true,
		name_id = "menu_first_aid_kit_downs_restore_chance",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "downs_restore_chance",
			category = "first_aid_kit"
		}
	}
end

function UpgradesTweakData:_bodybags_bag_definitions()
	self.definitions.bodybags_bag = {
		name_id = "menu_equipment_bodybags_bag",
		slot = 1,
		equipment_id = "bodybags_bag",
		category = "equipment"
	}
	self.definitions.bodybags_bag_quantity = {
		name_id = "menu_bodybags_bag_quantity",
		category = "equipment_upgrade",
		upgrade = {
			value = 1,
			upgrade = "quantity",
			category = "bodybags_bag"
		}
	}
end

function UpgradesTweakData:_flamethrower_mk2_definitions()
	self.definitions.flamethrower_mk2 = {
		factory_id = "wpn_fps_fla_mk2",
		weapon_id = "flamethrower_mk2",
		category = "weapon"
	}
	self.flame_bullet = {
		show_blood_hits = false
	}
end
