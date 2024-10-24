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
UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER = "stat_type_multiplier"
UpgradesTweakData.UPGRADE_TYPE_REDUCTIVE_MULTIPLIER = "stat_type_reductive_multiplier"
UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER_REDUCTIVE_STRING = "stat_type_multiplier_inverse_string"
UpgradesTweakData.UPGRADE_TYPE_TEMPORARY_RAW_VALUE_AMOUNT = "stat_type_temporary_raw_value_amount"
UpgradesTweakData.UPGRADE_TYPE_TEMPORARY_MULTIPLIER = "stat_type_temporary_multiplier"
UpgradesTweakData.UPGRADE_TYPE_TEMPORARY_REDUCTION = "stat_type_temporary_reduction"
UpgradesTweakData.DEF_CAT_FEATURE = "feature"
UpgradesTweakData.DEF_CAT_TEMPORARY = "temporary"
UpgradesTweakData.DEF_CAT_TEAM = "team"
UpgradesTweakData.UPG_CAT_WEAPON = "weapon"
UpgradesTweakData.UPG_CAT_PLAYER = "player"
UpgradesTweakData.UPG_CAT_INTERACT = "interaction"
UpgradesTweakData.UPG_CAT_TEMPORARY = "temporary"
UpgradesTweakData.UPG_CAT_CARRY = "carry"

function UpgradesTweakData:init()
	self:_create_generic_description_data_types()

	self.definitions = {}

	self:_init_value_tables()
	self:_old_init()
	self:_create_warcry_definitions()
	self:_create_boost_definitions()
	self:_create_talent_definitions()
	self:_create_raid_definitions_abilities()
	self:_create_weapon_definitions()
	self:_create_grenades_definitions()
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
		sentry_gun = {},
		doctor_bag = {},
		first_aid_kit = {},
		weapon = {},
		pistol = {},
		assault_rifle = {},
		smg = {},
		shotgun = {},
		saw = {},
		lmg = {},
		snp = {},
		grenade = {},
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
			upgrade_type = nil,
			upgrade_type = self.UPGRADE_TYPE_MULTIPLIER
		},
		generic_multiplier_reductive_string = {
			upgrade_type = nil,
			upgrade_type = self.UPGRADE_TYPE_MULTIPLIER_REDUCTIVE_STRING
		},
		reductive_multiplier = {
			upgrade_type = nil,
			upgrade_type = self.UPGRADE_TYPE_REDUCTIVE_MULTIPLIER
		},
		raw_value_amount = {
			upgrade_type = nil,
			upgrade_type = self.UPGRADE_TYPE_RAW_VALUE_AMOUNT
		},
		temporary_raw_value_amount = {
			upgrade_type = nil,
			upgrade_type = self.UPGRADE_TYPE_TEMPORARY_RAW_VALUE_AMOUNT
		},
		temporary_multiplier = {
			upgrade_type = nil,
			upgrade_type = self.UPGRADE_TYPE_TEMPORARY_MULTIPLIER
		},
		temporary_reduction = {
			upgrade_type = nil,
			upgrade_type = self.UPGRADE_TYPE_TEMPORARY_REDUCTION
		}
	}
end

function UpgradesTweakData:_create_boost_definitions()
	self.values.player.box_o_choc_low_health_regen_multiplier = {
		1.35
	}

	self:_create_definition("player_box_o_choc_low_health_regen_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "box_o_choc_low_health_regen_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.box_o_choc_health_regen_timer_multiplier = {
		0.8
	}

	self:_create_definition("player_box_o_choc_health_regen_timer_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "box_o_choc_health_regen_timer_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.team.player.warcry_health_regeneration = {
		1.02,
		1.025,
		1.03,
		1.04
	}

	self:_create_definition_levels("warcry_team_health_regeneration", UpgradesTweakData.DEF_CAT_TEAM, "warcry_health_regeneration", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.team.player.warcry_health_regeneration, self.description_data_types.generic_multiplier)

	self.values.player.painkiller_explosive_damage_reduction = {
		0.5
	}

	self:_create_definition("player_painkiller_explosive_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "painkiller_explosive_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.painkiller_fire_damage_reduction = {
		0.5
	}

	self:_create_definition("player_painkiller_fire_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "painkiller_fire_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.painkiller_damage_interval_multiplier = {
		1.15
	}

	self:_create_definition("player_painkiller_damage_interval_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "painkiller_damage_interval_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.team.player.warcry_damage_reduction_multiplier = {
		0.9,
		0.8,
		0.7,
		0.65
	}

	self:_create_definition_levels("warcry_team_damage_reduction_multiplier", UpgradesTweakData.DEF_CAT_TEAM, "warcry_damage_reduction_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.team.player.warcry_damage_reduction_multiplier, self.description_data_types.reductive_multiplier)

	self.values.player.sprinter_running_detection_multiplier = {
		0.7
	}

	self:_create_definition("player_sprinter_running_detection_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "sprinter_running_detection_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.sprinter_run_speed_increase = {
		1.2
	}

	self:_create_definition("player_sprinter_run_speed_increase", UpgradesTweakData.DEF_CAT_FEATURE, "sprinter_run_speed_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.team.player.warcry_movement_speed_multiplier = {
		1.025,
		1.05,
		1.1,
		1.15
	}

	self:_create_definition_levels("warcry_team_movement_speed_multiplier", UpgradesTweakData.DEF_CAT_TEAM, "warcry_movement_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.team.player.warcry_movement_speed_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.cache_basket_pick_up_ammo_multiplier = {
		1.12
	}

	self:_create_definition("player_cache_basket_pick_up_ammo_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "cache_basket_pick_up_ammo_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.cache_basket_ammo_total_increase = {
		1.15
	}

	self:_create_definition("player_cache_basket_ammo_total_increase", UpgradesTweakData.DEF_CAT_FEATURE, "cache_basket_ammo_total_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.team.player.warcry_ammo_regeneration = {
		1.035,
		1.04,
		1.045,
		1.05
	}

	self:_create_definition_levels("warcry_team_ammo_regeneration", UpgradesTweakData.DEF_CAT_TEAM, "warcry_ammo_regeneration", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.team.player.warcry_ammo_regeneration, self.description_data_types.generic_multiplier)

	self.values.player.critbrain_critical_hit_chance = {
		1.08
	}

	self:_create_definition("player_critbrain_critical_hit_chance", UpgradesTweakData.DEF_CAT_FEATURE, "critbrain_critical_hit_chance", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.critbrain_critical_hit_damage = {
		1.2
	}

	self:_create_definition("player_critbrain_critical_hit_damage", UpgradesTweakData.DEF_CAT_FEATURE, "critbrain_critical_hit_damage", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.team.player.warcry_critical_hit_chance = {
		1.05,
		1.1,
		1.15,
		1.2
	}

	self:_create_definition_levels("warcry_team_critical_hit_chance", UpgradesTweakData.DEF_CAT_TEAM, "warcry_critical_hit_chance", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.team.player.warcry_critical_hit_chance, self.description_data_types.generic_multiplier)

	self.values.player.greed_loot_bonus = {
		1.05,
		1.1,
		1.2,
		1.3
	}

	self:_create_definition_levels("player_greed_loot_bonus", UpgradesTweakData.DEF_CAT_FEATURE, "greed_loot_bonus", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.greed_loot_bonus, self.description_data_types.generic_multiplier)

	self.values.team.player.warcry_team_damage_reduction_bonus_on_activate = {
		1,
		2,
		3,
		4
	}

	self:_create_definition_levels("warcry_team_damage_reduction_bonus_on_activate", UpgradesTweakData.DEF_CAT_TEAM, "warcry_team_damage_reduction_bonus_on_activate", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.team.player.warcry_team_damage_reduction_bonus_on_activate, self.description_data_types.raw_value_amount)
end

function UpgradesTweakData:_create_warcry_definitions()
	self.values.player.warcry_nullify_spread = {
		true
	}

	self:_create_definition("warcry_player_nullify_spread", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_nullify_spread", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_nullify_spread_steelsight = {
		true
	}

	self:_create_definition("warcry_player_nullify_spread_steelsight", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_nullify_spread_steelsight", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_nullify_spread_hipfire = {
		true
	}

	self:_create_definition("warcry_player_nullify_spread_hipfire", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_nullify_spread_hipfire", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_nullify_recoil = {
		0
	}

	self:_create_definition("warcry_player_nullify_recoil", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_nullify_recoil", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_reduce_recoil_steelsight = {
		0.8,
		0.7,
		0.6,
		0.5
	}

	self:_create_definition_levels("warcry_player_reduce_recoil_steelsight", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_reduce_recoil_steelsight", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_reduce_recoil_steelsight)

	self.values.player.warcry_reduce_recoil_hipfire = {
		0.8,
		0.7,
		0.6,
		0.5
	}

	self:_create_definition_levels("warcry_player_reduce_recoil_hipfire", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_reduce_recoil_hipfire", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_reduce_recoil_hipfire)

	self.values.player.warcry_reduce_recoil = {
		0.8,
		0.7,
		0.6,
		0.5
	}

	self:_create_definition_levels("warcry_player_reduce_recoil", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_reduce_recoil", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_reduce_recoil)

	self.values.temporary.warcry_sentry_shooting = {
		{
			true,
			0.66
		}
	}

	self:_create_definition("warcry_temporary_sentry_shooting", UpgradesTweakData.DEF_CAT_TEMPORARY, "warcry_sentry_shooting", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.player.warcry_shooting_movement_speed_reduction = {
		0.3
	}

	self:_create_definition("warcry_player_shooting_movement_speed_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_shooting_movement_speed_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.warcry_shooting_damage_reduction = {
		0.5,
		0.3
	}

	self:_create_definition_levels("warcry_player_shooting_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_shooting_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_shooting_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.warcry_magazine_size_multiplier = {
		2
	}

	self:_create_definition("warcry_player_magazine_size_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_magazine_size_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.warcry_shooting_drain_reduction = {
		0.6
	}

	self:_create_definition("warcry_player_shooting_drain_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_shooting_drain_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.warcry_dismember_always = {
		true
	}

	self:_create_definition("warcry_player_dismember_always", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_dismember_always", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_aim_assist = {
		true
	}

	self:_create_definition("warcry_player_aim_assist", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_aim_assist", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_health_regen_on_kill = {
		true
	}

	self:_create_definition("warcry_player_health_regen_on_kill", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_health_regen_on_kill", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_health_regen_amount = {
		4,
		6,
		8,
		10
	}

	self:_create_definition_levels("warcry_player_health_regen_amount", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_health_regen_amount", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_health_regen_amount, self.description_data_types.raw_value_amount)

	self.values.player.warcry_sniper_ricochet = {
		true
	}

	self:_create_definition("warcry_player_sniper_ricochet", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_sniper_ricochet", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_aim_assist_aim_at_head = {
		true
	}

	self:_create_definition("warcry_player_aim_assist_aim_at_head", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_aim_assist_aim_at_head", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_aim_assist_radius = {
		1,
		1.5,
		1.9,
		2.5
	}

	self:_create_definition_levels("warcry_player_aim_assist_radius", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_aim_assist_radius", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_aim_assist_radius)

	self.values.player.warcry_headshot_multiplier_bonus = {
		1.1,
		1.2,
		1.4,
		1.7
	}

	self:_create_definition_levels("warcry_player_headshot_multiplier_bonus", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_headshot_multiplier_bonus", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_headshot_multiplier_bonus)

	self.values.player.warcry_no_reloads = {
		true
	}

	self:_create_definition("warcry_player_no_reloads", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_no_reloads", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_refill_clip = {
		true
	}

	self:_create_definition("warcry_player_refill_clip", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_refill_clip", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_ammo_consumption = {
		2,
		5,
		0
	}

	self:_create_definition_levels("warcry_player_ammo_consumption", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_ammo_consumption", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_ammo_consumption)

	self.values.player.warcry_overheat_multiplier = {
		0.2
	}

	self:_create_definition("warcry_turret_overheat_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_overheat_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.warcry_kill_heal_bonus = {
		1.05,
		1.075,
		1.1
	}

	self:_create_definition_levels("warcry_player_kill_heal_bonus", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_kill_heal_bonus", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_kill_heal_bonus, self.description_data_types.generic_multiplier)

	self.values.player.warcry_dodge = {
		1.6,
		1.7,
		1.8,
		1.9
	}

	self:_create_definition_levels("warcry_player_dodge", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_dodge", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_dodge, self.description_data_types.generic_multiplier)

	self.values.player.warcry_slower_detection = {
		0.1,
		0.2,
		0.3,
		0.4,
		0.5
	}

	self:_create_definition_levels("warcry_player_slower_detection", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_slower_detection", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_slower_detection)

	self.values.player.warcry_short_range_multiplier_bonus = {
		1.1,
		1.2,
		1.4,
		1.7
	}

	self:_create_definition_levels("warcry_player_short_range_multiplier_bonus", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_short_range_multiplier_bonus", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_short_range_multiplier_bonus)

	self.values.player.warcry_grenade_clusters = {
		2,
		3,
		4
	}

	self:_create_definition_levels("warcry_player_grenade_clusters", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_grenade_clusters", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_grenade_clusters, self.description_data_types.raw_value_amount)

	self.values.player.warcry_grenade_refill_amounts = {
		1,
		2
	}

	self:_create_definition_levels("warcry_player_grenade_refill_amounts", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_grenade_refill_amounts", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_grenade_refill_amounts, self.description_data_types.raw_value_amount)

	self.values.player.warcry_grenade_cluster_range = {
		1.5,
		1.667,
		1.75
	}

	self:_create_definition_levels("warcry_player_grenade_cluster_range", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_grenade_cluster_range", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_grenade_cluster_range, self.description_data_types.generic_multiplier)

	self.values.player.warcry_grenade_cluster_damage = {
		1.5,
		1.65,
		1.75
	}

	self:_create_definition_levels("warcry_player_grenade_cluster_damage", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_grenade_cluster_damage", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_grenade_cluster_damage, self.description_data_types.generic_multiplier)

	self.values.player.warcry_grenade_airburst = {
		true
	}

	self:_create_definition("warcry_player_grenade_airburst", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_grenade_airburst", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_killstreak_multiplier_bonus = {
		1.1,
		1.2,
		1.4,
		1.7
	}

	self:_create_definition_levels("warcry_player_killstreak_multiplier_bonus", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_killstreak_multiplier_bonus", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_killstreak_multiplier_bonus)

	self.values.player.warcry_silver_bullet_tint_distance = {
		20,
		35
	}

	self:_create_definition_levels("warcry_player_silver_bullet_tint_distance", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_silver_bullet_tint_distance", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.warcry_silver_bullet_tint_distance, self.description_data_types.raw_value_amount)

	self.values.player.warcry_shoot_through_walls = {
		20
	}

	self:_create_definition("warcry_player_shoot_through_walls", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_shoot_through_walls", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.warcry_shoot_through_enemies = {
		3,
		12
	}

	self:_create_definition_levels("warcry_player_shoot_through_enemies", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_shoot_through_enemies", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.warcry_shoot_through_enemies, self.description_data_types.raw_value_amount)

	self.values.player.warcry_shoot_through_shields = {
		8
	}

	self:_create_definition("warcry_player_shoot_through_shields", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_shoot_through_shields", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.warcry_killshot_duration_bonus = {
		2
	}

	self:_create_definition("warcry_player_killshot_duration_bonus", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_killshot_duration_bonus", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.warcry_silver_bullet_drain_reduction = {
		0.44
	}

	self:_create_definition("warcry_player_silver_bullet_drain_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_silver_bullet_drain_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.warcry_penetrate_damage_multiplier = {
		1.33
	}

	self:_create_definition("warcry_player_penetrate_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_penetrate_damage_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.warcry_charge_knockdown_fov = {
		30,
		50
	}

	self:_create_definition_levels("warcry_player_charge_knockdown_fov", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_charge_knockdown_fov", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.warcry_charge_knockdown_fov, self.description_data_types.raw_value_amount)

	self.values.player.warcry_charge_damage_reduction = {
		0.7,
		0.58,
		0.45
	}

	self:_create_definition_levels("warcry_player_charge_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_charge_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.warcry_charge_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.warcry_charge_activation_threshold = {
		0.5
	}

	self:_create_definition("warcry_player_charge_activation_threshold", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_charge_activation_threshold", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.warcry_charge_knockdown_flamer = {
		true
	}

	self:_create_definition("warcry_player_charge_knockdown_flamer", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_charge_knockdown_flamer", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)
end

function UpgradesTweakData:_create_talent_definitions()
	self.values.player.fitness_stamina_threshold_decrease = {
		0.65
	}

	self:_create_definition("player_fitness_stamina_threshold_decrease", UpgradesTweakData.DEF_CAT_FEATURE, "fitness_stamina_threshold_decrease", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.fitness_stamina_regeneration_increase = {
		1.42
	}

	self:_create_definition("player_fitness_stamina_regeneration_increase", UpgradesTweakData.DEF_CAT_FEATURE, "fitness_stamina_regeneration_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.fitness_stamina_multiplier = {
		1.28
	}

	self:_create_definition("player_fitness_stamina_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fitness_stamina_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.fitness_can_free_run = {
		true
	}

	self:_create_definition("player_fitness_can_free_run", UpgradesTweakData.DEF_CAT_FEATURE, "fitness_can_free_run", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.fasthand_enter_steelsight_speed_multiplier = {
		1.5
	}

	self:_create_definition("player_fasthand_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fasthand_enter_steelsight_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.fasthand_climb_speed_increase = {
		1.5
	}

	self:_create_definition("player_fasthand_climb_speed_increase", UpgradesTweakData.DEF_CAT_FEATURE, "fasthand_climb_speed_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.fasthand_mantle_speed_increase = {
		1.25
	}

	self:_create_definition("player_fasthand_mantle_speed_increase", UpgradesTweakData.DEF_CAT_FEATURE, "fasthand_mantle_speed_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.weapon.fasthand_reload_speed_multiplier = {
		1.2
	}

	self:_create_definition("weapon_fasthand_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fasthand_reload_speed_multiplier", UpgradesTweakData.UPG_CAT_WEAPON, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.fasthand_swap_speed_multiplier = {
		1.25
	}

	self:_create_definition("player_fasthand_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fasthand_swap_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.gunner_turret_m2_overheat_reduction = {
		0.76,
		0.62
	}

	self:_create_definition_levels("player_gunner_turret_m2_overheat_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "gunner_turret_m2_overheat_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.gunner_turret_m2_overheat_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.gunner_turret_flakvierling_overheat_reduction = {
		0.8,
		0.68
	}

	self:_create_definition_levels("player_gunner_turret_flakvierling_overheat_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "gunner_turret_flakvierling_overheat_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.gunner_turret_flakvierling_overheat_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.gunner_turret_camera_speed_multiplier = {
		1.24
	}

	self:_create_definition("player_gunner_turret_camera_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "gunner_turret_camera_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.gunner_damage_reduction = {
		0.65,
		0.45
	}

	self:_create_definition_levels("player_gunner_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "gunner_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.gunner_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.gunner_turret_damage_multiplier = {
		1.18,
		1.3
	}

	self:_create_definition_levels("player_gunner_turret_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "gunner_turret_damage_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.gunner_turret_damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.interaction.handyman_generic_speed_multiplier = {
		0.78
	}

	self:_create_definition("interaction_handyman_generic_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "handyman_generic_speed_multiplier", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.interaction.handyman_vehicle_speed_multipler = {
		0.4
	}

	self:_create_definition("interaction_handyman_vehicle_speed_multipler", UpgradesTweakData.DEF_CAT_FEATURE, "handyman_vehicle_speed_multipler", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.interaction.handyman_rewire_speed_multipler = {
		0.3
	}

	self:_create_definition("interaction_handyman_rewire_speed_multipler", UpgradesTweakData.DEF_CAT_FEATURE, "handyman_rewire_speed_multipler", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.temporary.handyman_interaction_boost = {
		{
			0.6,
			2
		}
	}

	self:_create_definition("temporary_handyman_interaction_boost", UpgradesTweakData.DEF_CAT_TEMPORARY, "handyman_interaction_boost", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_reduction)

	self.values.player.focus_interaction_damage_reduction = {
		0.5
	}

	self:_create_definition("player_focus_interaction_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "focus_interaction_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.focus_vehicle_damage_reduction = {
		0.62
	}

	self:_create_definition("player_focus_vehicle_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "focus_vehicle_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.focus_steelsight_damage_reduction = {
		0.82
	}

	self:_create_definition("player_focus_steelsight_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "focus_steelsight_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.focus_steelsight_normal_movement_speed = {
		true
	}

	self:_create_definition("player_focus_steelsight_normal_movement_speed", UpgradesTweakData.DEF_CAT_FEATURE, "focus_steelsight_normal_movement_speed", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.medic_pick_up_health_multiplier = {
		1.1,
		1.15
	}

	self:_create_definition_levels("player_medic_pick_up_health_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "medic_pick_up_health_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.medic_pick_up_health_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.medic_attention_weight_reduction = {
		0.65,
		0.5
	}

	self:_create_definition_levels("player_medic_attention_weight_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "medic_attention_weight_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.medic_attention_weight_reduction, self.description_data_types.reductive_multiplier)

	self.values.interaction.medic_revive_speed_multiplier = {
		0.7,
		0.5
	}

	self:_create_definition_levels("interaction_medic_revive_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "medic_revive_speed_multiplier", UpgradesTweakData.UPG_CAT_INTERACT, false, self.values.interaction.medic_revive_speed_multiplier, self.description_data_types.reductive_multiplier)

	self.values.player.medic_health_share_team = {
		1.06,
		1.08
	}

	self:_create_definition_levels("player_medic_health_share_team", UpgradesTweakData.DEF_CAT_FEATURE, "medic_health_share_team", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.medic_health_share_team, self.description_data_types.generic_multiplier)

	self.medic_health_share_distance = 1500
	self.values.player.pack_mule_ammo_total_increase = {
		1.25
	}

	self:_create_definition("player_pack_mule_ammo_total_increase", UpgradesTweakData.DEF_CAT_FEATURE, "pack_mule_ammo_total_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.pack_mule_equipment_quantity = {
		1
	}

	self:_create_definition("player_pack_mule_equipment_quantity", UpgradesTweakData.DEF_CAT_FEATURE, "pack_mule_equipment_quantity", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.raw_value_amount)

	self.values.carry.pack_mule_weight_increase = {
		2
	}

	self:_create_definition("carry_pack_mule_weight_increase", UpgradesTweakData.DEF_CAT_FEATURE, "pack_mule_weight_increase", UpgradesTweakData.UPG_CAT_CARRY, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.pack_mule_ammo_share_team = {
		1.15
	}

	self:_create_definition("player_pack_mule_ammo_share_team", UpgradesTweakData.DEF_CAT_FEATURE, "pack_mule_ammo_share_team", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.pack_mule_ammo_share_distance = 1500
	self.values.player.helpcry_warcry_fill_multiplier = {
		1.15
	}

	self:_create_definition("player_helpcry_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "helpcry_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.helpcry_warcry_auto_fill = {
		7,
		5
	}

	self:_create_definition_levels("player_helpcry_warcry_auto_fill", UpgradesTweakData.DEF_CAT_FEATURE, "helpcry_warcry_auto_fill", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.helpcry_warcry_auto_fill, self.description_data_types.raw_value_amount)

	self.helpcry_warcry_fill_multiplier = 0.6
	self.values.player.helpcry_warcry_duration_multiplier = {
		1.38
	}

	self:_create_definition("player_helpcry_warcry_duration_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "helpcry_warcry_duration_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.helpcry_warcry_downed_reduction = {
		1.17
	}

	self:_create_definition("player_helpcry_warcry_downed_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "helpcry_warcry_downed_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.interaction.locksmith_wheel_hotspot_increase = {
		0.975
	}

	self:_create_definition("interaction_locksmith_wheel_hotspot_increase", UpgradesTweakData.DEF_CAT_FEATURE, "locksmith_wheel_hotspot_increase", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.interaction.locksmith_wheel_rotation_speed_increase = {
		1.15
	}

	self:_create_definition("interaction_locksmith_wheel_rotation_speed_increase", UpgradesTweakData.DEF_CAT_FEATURE, "locksmith_wheel_rotation_speed_increase", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.locksmith_lockpicking_damage_reduction = {
		0.42
	}

	self:_create_definition("player_locksmith_lockpicking_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "locksmith_lockpicking_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.interaction.locksmith_wheel_amount_decrease = {
		1
	}

	self:_create_definition("interaction_locksmith_wheel_amount_decrease", UpgradesTweakData.DEF_CAT_FEATURE, "locksmith_wheel_amount_decrease", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.interaction.locksmith_failure_rotation_speed_decrease = {
		0.58
	}

	self:_create_definition("interaction_locksmith_failure_rotation_speed_decrease", UpgradesTweakData.DEF_CAT_FEATURE, "locksmith_failure_rotation_speed_decrease", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.reductive_multiplier)

	self.locksmith_failure_speed_decrease_step = 0.084
	self.values.player.opportunist_pick_up_health_to_ammo = {
		1.08
	}

	self:_create_definition("player_opportunist_pick_up_health_to_ammo", UpgradesTweakData.DEF_CAT_FEATURE, "opportunist_pick_up_health_to_ammo", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.opportunist_pick_up_ammo_to_health = {
		1.23
	}

	self:_create_definition("player_opportunist_pick_up_ammo_to_health", UpgradesTweakData.DEF_CAT_FEATURE, "opportunist_pick_up_ammo_to_health", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.opportunist_pick_up_grenade_to_ammo = {
		1.2
	}

	self:_create_definition("player_opportunist_pick_up_grenade_to_ammo", UpgradesTweakData.DEF_CAT_FEATURE, "opportunist_pick_up_grenade_to_ammo", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.opportunist_pick_up_grenade_to_health = {
		10
	}

	self:_create_definition("player_opportunist_pick_up_grenade_to_health", UpgradesTweakData.DEF_CAT_FEATURE, "opportunist_pick_up_grenade_to_health", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.opportunist_pick_up_supplies_to_warcry = {
		1.04
	}

	self:_create_definition("player_opportunist_pick_up_supplies_to_warcry", UpgradesTweakData.DEF_CAT_FEATURE, "opportunist_pick_up_supplies_to_warcry", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.snp.steelsight_hit_flinch_reduction = {
		0
	}

	self:_create_definition("snp_steelsight_hit_flinch_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "steelsight_hit_flinch_reduction", "snp", false, 1, false)

	self.values.snp.steelsight_movement_speed_multiplier = {
		0.68
	}

	self:_create_definition("snp_steelsight_movement_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "steelsight_movement_speed_multiplier", "snp", false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.steadiness_headshot_warcry_fill_multiplier = {
		1.25
	}

	self:_create_definition("player_steadiness_headshot_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "steadiness_headshot_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.steadiness_weapon_sway_decrease = {
		0.05
	}

	self:_create_definition("player_steadiness_weapon_sway_decrease", UpgradesTweakData.DEF_CAT_FEATURE, "steadiness_weapon_sway_decrease", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.snp.steelsight_fire_rate_multiplier = {
		1.26
	}

	self:_create_definition("snp_steelsight_fire_rate_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "steelsight_fire_rate_multiplier", "snp", false, 1, false, self.description_data_types.generic_multiplier)

	self.values.weapon.clipazines_empty_reload_speed_multiplier = {
		1.22
	}

	self:_create_definition("weapon_clipazines_empty_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_empty_reload_speed_multiplier", UpgradesTweakData.UPG_CAT_WEAPON, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.clipazines_pick_up_ammo_multiplier = {
		1.33
	}

	self:_create_definition("player_clipazines_pick_up_ammo_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_pick_up_ammo_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.lmg.clipazines_magazine_upgrade = {
		12
	}

	self:_create_definition("lmg_clipazines_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_magazine_upgrade", "lmg", false, 1, false, self.description_data_types.raw_value_amount)

	self.values.assault_rifle.clipazines_magazine_upgrade = {
		5
	}

	self:_create_definition("assault_rifle_clipazines_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_magazine_upgrade", "assault_rifle", false, 1, false, self.description_data_types.raw_value_amount)

	self.values.smg.clipazines_magazine_upgrade = {
		8
	}

	self:_create_definition("smg_clipazines_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_magazine_upgrade", "smg", false, 1, false, self.description_data_types.raw_value_amount)

	self.values.snp.clipazines_magazine_upgrade = {
		2
	}

	self:_create_definition("snp_clipazines_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_magazine_upgrade", "snp", false, 1, false, self.description_data_types.raw_value_amount)

	self.values.shotgun.clipazines_magazine_upgrade = {
		3
	}

	self:_create_definition("shotgun_clipazines_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_magazine_upgrade", "shotgun", false, 1, false, self.description_data_types.raw_value_amount)

	self.values.pistol.clipazines_magazine_upgrade = {
		6
	}

	self:_create_definition("pistol_clipazines_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_magazine_upgrade", "pistol", false, 1, false, self.description_data_types.raw_value_amount)

	self.values.weapon.clipazines_reload_hybrid_rounds = {
		2
	}

	self:_create_definition("weapon_clipazines_reload_hybrid_rounds", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_reload_hybrid_rounds", UpgradesTweakData.UPG_CAT_WEAPON, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.weapon.clipazines_reload_full_magazine = {
		true
	}

	self:_create_definition("weapon_clipazines_reload_full_magazine", UpgradesTweakData.DEF_CAT_FEATURE, "clipazines_reload_full_magazine", UpgradesTweakData.UPG_CAT_WEAPON, false, 1)

	self.values.player.grenadier_grenade_quantity = {
		1,
		2
	}

	self:_create_definition_levels("player_grenadier_grenade_quantity", UpgradesTweakData.DEF_CAT_FEATURE, "grenadier_grenade_quantity", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.grenadier_grenade_quantity, self.description_data_types.raw_value_amount)

	self.values.player.grenadier_explosive_damage_reduction = {
		0.7,
		0.5
	}

	self:_create_definition_levels("player_grenadier_explosive_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "grenadier_explosive_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.grenadier_explosive_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.grenadier_explosive_warcry_fill_multiplier = {
		1.15,
		1.3
	}

	self:_create_definition_levels("player_grenadier_explosive_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "grenadier_explosive_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.grenadier_explosive_warcry_fill_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.grenadier_grenade_radius_multiplier = {
		1.25,
		1.45
	}

	self:_create_definition_levels("player_grenadier_grenade_radius_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "grenadier_grenade_radius_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.grenadier_explosive_damage_reduction, self.description_data_types.generic_multiplier)

	self.values.interaction.strongback_carry_pickup_multiplier = {
		0.45
	}

	self:_create_definition("interaction_strongback_carry_pickup_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "strongback_carry_pickup_multiplier", UpgradesTweakData.UPG_CAT_INTERACT, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.carry.strongback_weight_increase = {
		2,
		3,
		4
	}

	self:_create_definition_levels("carry_strongback_weight_increase", UpgradesTweakData.DEF_CAT_FEATURE, "strongback_weight_increase", UpgradesTweakData.UPG_CAT_CARRY, true, self.values.carry.strongback_weight_increase, self.description_data_types.raw_value_amount)

	self.values.carry.strongback_throw_distance_multiplier = {
		1.5
	}

	self:_create_definition("carry_strongback_throw_distance_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "strongback_throw_distance_multiplier", UpgradesTweakData.UPG_CAT_CARRY, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.carry.strongback_heavy_penalty_decrease = {
		1.16
	}

	self:_create_definition("carry_strongback_heavy_penalty_decrease", UpgradesTweakData.DEF_CAT_FEATURE, "strongback_heavy_penalty_decrease", UpgradesTweakData.UPG_CAT_CARRY, false, 1, false, self.description_data_types.generic_multiplier_reductive_string)

	self.values.player.fleetfoot_movement_speed_multiplier = {
		1.12
	}

	self:_create_definition("player_fleetfoot_movement_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fleetfoot_movement_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.fleetfoot_silent_fall = {
		true
	}

	self:_create_definition("player_fleetfoot_silent_fall", UpgradesTweakData.DEF_CAT_FEATURE, "fleetfoot_silent_fall", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.fleetfoot_fall_damage_reduction = {
		0.35
	}

	self:_create_definition("player_fleetfoot_fall_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "fleetfoot_fall_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.fleetfoot_critical_movement_speed_multiplier = {
		1.3
	}

	self:_create_definition("player_fleetfoot_critical_movement_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fleetfoot_critical_movement_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.temporary.pickpocket_melee_ammo_steal = {
		{
			1.15,
			7
		}
	}

	self:_create_definition("temporary_pickpocket_melee_ammo_steal", UpgradesTweakData.DEF_CAT_TEMPORARY, "pickpocket_melee_ammo_steal", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_multiplier)

	self.values.player.pickpocket_melee_health_steal = {
		16
	}

	self:_create_definition("player_pickpocket_melee_health_steal", UpgradesTweakData.DEF_CAT_FEATURE, "pickpocket_melee_health_steal", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.pickpocket_uncover_detection = {
		0.02
	}

	self:_create_definition("player_pickpocket_uncover_detection", UpgradesTweakData.DEF_CAT_FEATURE, "pickpocket_uncover_detection", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.interaction.pickpocket_greed_steal = {
		true
	}

	self:_create_definition("interaction_pickpocket_greed_steal", UpgradesTweakData.DEF_CAT_FEATURE, "pickpocket_greed_steal", UpgradesTweakData.UPG_CAT_INTERACT, false, 1)

	self.values.player.scuttler_crouch_speed_increase = {
		1.2
	}

	self:_create_definition("player_scuttler_crouch_speed_increase", UpgradesTweakData.DEF_CAT_FEATURE, "scuttler_crouch_speed_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.scuttler_crouch_spread_multiplier = {
		0.75
	}

	self:_create_definition("player_scuttler_crouch_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "scuttler_crouch_spread_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier_reductive_string)

	self.values.player.scuttler_stamina_regeneration_increase = {
		1.5
	}

	self:_create_definition("player_scuttler_stamina_regeneration_increase", UpgradesTweakData.DEF_CAT_FEATURE, "scuttler_stamina_regeneration_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.carry.scuttler_crouch_penalty_decrease = {
		1.16
	}

	self:_create_definition("carry_scuttler_crouch_penalty_decrease", UpgradesTweakData.DEF_CAT_FEATURE, "scuttler_crouch_penalty_decrease", UpgradesTweakData.UPG_CAT_CARRY, false, 1, false, self.description_data_types.generic_multiplier_reductive_string)

	self.values.player.holdbarred_melee_speed_multiplier = {
		0.82
	}

	self:_create_definition("player_holdbarred_melee_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "holdbarred_melee_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.holdbarred_melee_charge_multiplier = {
		0.35
	}

	self:_create_definition("player_holdbarred_melee_charge_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "holdbarred_melee_charge_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.holdbarred_melee_knockdown_multiplier = {
		1.74
	}

	self:_create_definition("player_holdbarred_melee_knockdown_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "holdbarred_melee_knockdown_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.holdbarred_melee_kill_panic_range = 1000
	self.values.player.holdbarred_melee_kill_panic_chance = {
		1.58
	}

	self:_create_definition("player_holdbarred_melee_kill_panic_chance", UpgradesTweakData.DEF_CAT_FEATURE, "holdbarred_melee_kill_panic_chance", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.revenant_additional_life = {
		1
	}

	self:_create_definition("player_revenant_additional_life", UpgradesTweakData.DEF_CAT_FEATURE, "revenant_additional_life", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.revenant_bleedout_timer_reduction = {
		0.65
	}

	self:_create_definition("player_revenant_bleedout_timer_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "revenant_bleedout_timer_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.revenant_steelsight_when_downed = {
		true
	}

	self:_create_definition("player_revenant_steelsight_when_downed", UpgradesTweakData.DEF_CAT_FEATURE, "revenant_steelsight_when_downed", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.temporary.revenant_revived_damage_reduction = {
		{
			0.5,
			10
		}
	}

	self:_create_definition("temporary_revenant_revived_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "revenant_revived_damage_reduction", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_reduction)

	self.values.temporary.revenant_revived_critical_hit_chance = {
		{
			1.3,
			7
		}
	}

	self:_create_definition("temporary_revenant_revived_critical_hit_chance", UpgradesTweakData.DEF_CAT_FEATURE, "revenant_revived_critical_hit_chance", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_multiplier)

	self.values.player.revenant_downed_critical_hit_chance = {
		1.3
	}

	self:_create_definition("player_revenant_downed_critical_hit_chance", UpgradesTweakData.DEF_CAT_FEATURE, "revenant_downed_critical_hit_chance", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.sapper_mine_quantity = {
		2
	}

	self:_create_definition("player_sapper_mine_quantity", UpgradesTweakData.DEF_CAT_FEATURE, "sapper_mine_quantity", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.raw_value_amount)

	self.values.interaction.sapper_crowbar_speed_multiplier = {
		0.57
	}

	self:_create_definition("interaction_sapper_crowbar_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "sapper_crowbar_speed_multiplier", UpgradesTweakData.UPG_CAT_INTERACT, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.interaction.sapper_lockpick_crate_bypass = {
		true
	}

	self:_create_definition("interaction_sapper_lockpick_crate_bypass", UpgradesTweakData.DEF_CAT_FEATURE, "sapper_lockpick_crate_bypass", UpgradesTweakData.UPG_CAT_INTERACT, true, 1)

	self.values.player.sapper_tank_disabler = {
		20
	}

	self:_create_definition("player_sapper_tank_disabler", UpgradesTweakData.DEF_CAT_FEATURE, "sapper_tank_disabler", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.sapper_tank_disabler_cooldown = {
		240
	}

	self:_create_definition("player_sapper_tank_disabler_cooldown", UpgradesTweakData.DEF_CAT_FEATURE, "sapper_tank_disabler_cooldown", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.toughness_low_health_regen_limit_multiplier = {
		1.5
	}

	self:_create_definition("player_toughness_low_health_regen_limit_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "toughness_low_health_regen_limit_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.toughness_low_health_warcry_fill_multiplier = {
		1.4
	}

	self:_create_definition("player_toughness_low_health_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "toughness_low_health_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.toughness_activation_ratio = 0.4
	self.toughness_multiplier_min = 0.3
	self.values.player.toughness_critical_damage_reduction = {
		0.75
	}

	self:_create_definition("player_toughness_critical_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "toughness_critical_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.toughness_death_defiant = {
		0.25
	}

	self:_create_definition("player_toughness_death_defiant", UpgradesTweakData.DEF_CAT_FEATURE, "toughness_death_defiant", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.leaded_ammo_sponge = {
		10,
		8
	}

	self:_create_definition_levels("player_leaded_ammo_sponge", UpgradesTweakData.DEF_CAT_FEATURE, "leaded_ammo_sponge", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.leaded_ammo_sponge, self.description_data_types.raw_value_amount)

	self.values.player.leaded_magazine_refill = {
		true
	}

	self:_create_definition("player_leaded_magazine_refill", UpgradesTweakData.DEF_CAT_FEATURE, "leaded_magazine_refill", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.leaded_damage_reduction = {
		0.5,
		0
	}

	self:_create_definition_levels("player_leaded_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "leaded_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.leaded_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.big_game_special_sense = {
		18,
		30
	}

	self:_create_definition_levels("player_big_game_special_sense", UpgradesTweakData.DEF_CAT_FEATURE, "big_game_special_sense", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.big_game_special_sense, self.description_data_types.raw_value_amount)

	self.values.player.big_game_retrigger_time = {
		15
	}

	self:_create_definition("player_big_game_retrigger_time", UpgradesTweakData.DEF_CAT_FEATURE, "big_game_retrigger_time", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.big_game_highlight_enemy_multiplier = {
		1.35
	}

	self:_create_definition("player_big_game_highlight_enemy_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "big_game_highlight_enemy_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.temporary.big_game_special_health_regen = {
		{
			1.04,
			6
		}
	}

	self:_create_definition("temporary_big_game_special_health_regen", UpgradesTweakData.DEF_CAT_TEMPORARY, "big_game_special_health_regen", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_multiplier)

	self.values.player.brutality_dismemberment_warcry_fill_multiplier = {
		1.5
	}

	self:_create_definition("player_brutality_dismemberment_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "brutality_dismemberment_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.brutality_single_critical_hit_chance = {
		1.19
	}

	self:_create_definition("player_brutality_single_critical_hit_chance", UpgradesTweakData.DEF_CAT_FEATURE, "brutality_single_critical_hit_chance", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.brutality_single_dismember_chance = {
		1.12
	}

	self:_create_definition("player_brutality_single_dismember_chance", UpgradesTweakData.DEF_CAT_FEATURE, "brutality_single_dismember_chance", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.temporary.brutality_dismember_critical_hit_chance = {
		{
			1.2,
			5
		}
	}

	self:_create_definition("temporary_brutality_dismember_critical_hit_chance", UpgradesTweakData.DEF_CAT_TEMPORARY, "brutality_dismember_critical_hit_chance", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_multiplier)

	self.values.primary_weapon.farsighted_long_range_damage_multiplier = {
		1.2
	}

	self:_create_definition("primary_weapon_farsighted_long_range_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "farsighted_long_range_damage_multiplier", "primary_weapon", false, 1, false, self.description_data_types.generic_multiplier)

	self.farsighted_activation_distance = 1700
	self.farsighted_sensitivity_multiplier = 0.93
	self.values.player.farsighted_steelsight_fov_multiplier = {
		0.76
	}

	self:_create_definition("player_farsighted_steelsight_fov_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "farsighted_steelsight_fov_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.farsighted_long_range_warcry_fill_multiplier = {
		1.46
	}

	self:_create_definition("player_farsighted_long_range_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "farsighted_long_range_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.farsighted_long_range_critical_hit_chance = {
		1.12
	}

	self:_create_definition("player_farsighted_long_range_critical_hit_chance", UpgradesTweakData.DEF_CAT_FEATURE, "farsighted_long_range_critical_hit_chance", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.do_die_melee_repeat_multiplier = {
		0.6
	}

	self:_create_definition("player_do_die_melee_repeat_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "do_die_melee_repeat_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.do_die_melee_warcry_fill_multiplier = {
		1.36
	}

	self:_create_definition("player_do_die_melee_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "do_die_melee_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.do_die_melee_running_charge = {
		true
	}

	self:_create_definition("player_do_die_melee_running_charge", UpgradesTweakData.DEF_CAT_FEATURE, "do_die_melee_running_charge", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.temporary.do_die_melee_speed_multiplier = {
		{
			0.72,
			3
		}
	}

	self:_create_definition("temporary_do_die_melee_speed_multiplier", UpgradesTweakData.DEF_CAT_TEMPORARY, "do_die_melee_speed_multiplier", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_reduction)

	self.values.player.boxer_melee_damage_reduction = {
		0.5
	}

	self:_create_definition("player_boxer_melee_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "boxer_melee_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.boxer_melee_damage_multiplier = {
		1.45
	}

	self:_create_definition("player_boxer_melee_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "boxer_melee_damage_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.boxer_melee_warcry_fill_multiplier = {
		1.72
	}

	self:_create_definition("player_boxer_melee_warcry_fill_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "boxer_melee_warcry_fill_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.boxer_melee_headshots = {
		true
	}

	self:_create_definition("player_boxer_melee_headshots", UpgradesTweakData.DEF_CAT_FEATURE, "boxer_melee_headshots", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.interaction.saboteur_dynamite_speed_multiplier = {
		0.45
	}

	self:_create_definition("interaction_saboteur_dynamite_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "saboteur_dynamite_speed_multiplier", UpgradesTweakData.UPG_CAT_INTERACT, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.carry.saboteur_shell_weight_multiplier = {
		0.5
	}

	self:_create_definition("carry_saboteur_shell_weight_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "saboteur_shell_weight_multiplier", UpgradesTweakData.UPG_CAT_CARRY, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.interaction.saboteur_fuse_hotspot_increase = {
		1.06
	}

	self:_create_definition("interaction_saboteur_fuse_hotspot_increase", UpgradesTweakData.DEF_CAT_FEATURE, "saboteur_fuse_hotspot_increase", UpgradesTweakData.UPG_CAT_INTERACT, true, 1, false, self.description_data_types.generic_multiplier)

	self.values.interaction.saboteur_boobytrap_turret = {
		true
	}

	self:_create_definition("interaction_saboteur_boobytrap_turret", UpgradesTweakData.DEF_CAT_FEATURE, "saboteur_boobytrap_turret", UpgradesTweakData.UPG_CAT_INTERACT, true, 1)

	self.values.player.dac_stamina_regen_delay_multiplier = {
		0.85
	}

	self:_create_definition("player_dac_stamina_regen_delay_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "dac_stamina_regen_delay_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.dac_jump_stamina_drain_reduction = {
		0.7
	}

	self:_create_definition("player_dac_jump_stamina_drain_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "dac_jump_stamina_drain_reduction", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.carry.dac_stamina_consumption_reduction = {
		0.75
	}

	self:_create_definition("carry_dac_stamina_consumption_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "dac_stamina_consumption_reduction", UpgradesTweakData.UPG_CAT_CARRY, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.dac_stamina_regeneration_on_kill = {
		true
	}

	self:_create_definition("player_dac_stamina_regeneration_on_kill", UpgradesTweakData.DEF_CAT_FEATURE, "dac_stamina_regeneration_on_kill", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.agile_ready_weapon_speed_multiplier = {
		1.3
	}

	self:_create_definition("player_agile_ready_weapon_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "agile_ready_weapon_speed_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.agile_moving_spread_multiplier = {
		0.55
	}

	self:_create_definition("player_agile_moving_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "agile_moving_spread_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.agile_running_damage_reduction = {
		0.72
	}

	self:_create_definition("player_agile_running_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "agile_running_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.agile_run_and_reload = {
		true
	}

	self:_create_definition("player_agile_run_and_reload", UpgradesTweakData.DEF_CAT_FEATURE, "agile_run_and_reload", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.rally_low_health_regen_multiplier = {
		0
	}

	self:_create_definition("player_rally_low_health_regen_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "rally_low_health_regen_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.rally_recoverable_health = {
		32,
		48
	}

	self:_create_definition_levels("player_rally_recoverable_health", UpgradesTweakData.DEF_CAT_FEATURE, "rally_recoverable_health", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.rally_recoverable_health, self.description_data_types.raw_value_amount)

	self.values.player.rally_recoverable_damage_ratio = {
		1.35,
		1.5
	}

	self:_create_definition_levels("player_rally_recoverable_damage_ratio", UpgradesTweakData.DEF_CAT_FEATURE, "rally_recoverable_damage_ratio", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.rally_recoverable_damage_ratio, self.description_data_types.generic_multiplier)

	self.values.player.rally_recovery_headshot_multiplier = {
		1.5
	}

	self:_create_definition("player_rally_recovery_headshot_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "rally_recovery_headshot_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.generic_multiplier)

	self.rally_recovery_amount = 2
	self.values.player.marshal_max_multiplier_stacks = {
		8
	}

	self:_create_definition("player_marshal_max_multiplier_stacks", UpgradesTweakData.DEF_CAT_FEATURE, "marshal_max_multiplier_stacks", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.marshal_stack_decay_timer = {
		1,
		2
	}

	self:_create_definition_levels("player_marshal_stack_decay_timer", UpgradesTweakData.DEF_CAT_FEATURE, "marshal_stack_decay_timer", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.marshal_stack_decay_timer, self.description_data_types.raw_value_amount)

	self.values.pistol.marshal_stacking_reload_speed_multiplier = {
		1.025
	}

	self:_create_definition("pistol_marshal_stacking_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "marshal_stacking_reload_speed_multiplier", "pistol", true, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.marshal_stacking_melee_damage = {
		1.13,
		1.24
	}

	self:_create_definition_levels("player_marshal_stacking_melee_damage", UpgradesTweakData.DEF_CAT_FEATURE, "marshal_stacking_melee_damage", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.marshal_stacking_melee_damage, self.description_data_types.generic_multiplier)

	self.values.pistol.marshal_stacking_damage_multiplier = {
		1.06,
		1.08
	}

	self:_create_definition_levels("pistol_marshal_stacking_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "marshal_stacking_damage_multiplier", "pistol", true, self.values.pistol.marshal_stacking_damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.blammfu_explosive_grenade_melee = {
		1.6,
		2
	}

	self:_create_definition_levels("player_blammfu_explosive_grenade_melee", UpgradesTweakData.DEF_CAT_FEATURE, "blammfu_explosive_grenade_melee", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.blammfu_explosive_grenade_melee, self.description_data_types.generic_multiplier)

	self.values.grenade.swap_speed_multiplier = {
		1.8
	}

	self:_create_definition("grenade_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "swap_speed_multiplier", "grenade", true, 1, false, self.description_data_types.generic_multiplier)

	self.values.player.blammfu_grenade_player_damage_reduction = {
		0.5
	}

	self:_create_definition("player_blammfu_grenade_player_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "blammfu_grenade_player_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.carry.predator_corpse_weight_multiplier = {
		0.1
	}

	self:_create_definition("carry_predator_corpse_weight_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "predator_corpse_weight_multiplier", UpgradesTweakData.UPG_CAT_CARRY, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.interaction.predator_corpse_speed_multiplier = {
		0.38
	}

	self:_create_definition("interaction_predator_corpse_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "predator_corpse_speed_multiplier", UpgradesTweakData.UPG_CAT_INTERACT, true, 1, false, self.description_data_types.reductive_multiplier)

	self.values.player.predator_surprise_kill_leeway_multiplier = {
		0.47
	}

	self:_create_definition("player_predator_surprise_kill_leeway_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "predator_surprise_kill_leeway_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.predator_surprise_knockdown = {
		1.5
	}

	self:_create_definition("player_predator_surprise_knockdown", UpgradesTweakData.DEF_CAT_FEATURE, "predator_surprise_knockdown", UpgradesTweakData.UPG_CAT_PLAYER, true, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.fragstone_downed_martyrdom = {
		false,
		true
	}

	self:_create_definition_levels("player_fragstone_downed_martyrdom", UpgradesTweakData.DEF_CAT_FEATURE, "fragstone_downed_martyrdom", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.fragstone_downed_martyrdom)

	self.values.player.fragstone_grenades_when_downed = {
		true
	}

	self:_create_definition("player_fragstone_grenades_when_downed", UpgradesTweakData.DEF_CAT_FEATURE, "fragstone_grenades_when_downed", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.fragstone_martyrdom_no_consumption = {
		true
	}

	self:_create_definition("player_fragstone_martyrdom_no_consumption", UpgradesTweakData.DEF_CAT_FEATURE, "fragstone_martyrdom_no_consumption", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.high_dive_ground_slam = {
		{
			negate_damage = true
		},
		{
			negate_fatal = true,
			negate_damage = true
		}
	}

	self:_create_definition_levels("player_high_dive_ground_slam", UpgradesTweakData.DEF_CAT_FEATURE, "high_dive_ground_slam", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.high_dive_ground_slam)

	self.values.player.high_dive_gravity_multiplier = {
		1.5,
		2.8
	}

	self:_create_definition_levels("player_high_dive_gravity_multiplier", UpgradesTweakData.DEF_CAT_TEMPORARY, "high_dive_gravity_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.high_dive_gravity_multiplier, self.description_data_types.generic_multiplier)

	self.values.temporary.high_dive_enemy_knockdown = {
		{
			1,
			10
		}
	}

	self:_create_definition("temporary_high_dive_enemy_knockdown", UpgradesTweakData.DEF_CAT_TEMPORARY, "high_dive_enemy_knockdown", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1, false, self.description_data_types.temporary_raw_value_amount)

	self.high_dive_knockdown_range = 340
	self.high_dive_health_to_stamina_mul = 0.35
	self.high_dive_land_effect = Idstring("effects/upd_skills/character/high_dive_land")
	self.high_dive_land_decal = Idstring("explosion_std")
	self.values.primary_weapon.anatomist_bodyshot_damage_multiplier = {
		1.2
	}

	self:_create_definition("primary_weapon_anatomist_bodyshot_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "anatomist_bodyshot_damage_multiplier", "primary_weapon", true, 1, false, self.description_data_types.generic_multiplier)

	self.values.secondary_weapon.anatomist_headshot_damage_multiplier = {
		1.2
	}

	self:_create_definition("secondary_weapon_anatomist_headshot_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "anatomist_headshot_damage_multiplier", "secondary_weapon", true, 1, false, self.description_data_types.generic_multiplier)

	self.values.snp.anatomist_critical_hit_chance = {
		1.2
	}

	self:_create_definition("snp_anatomist_critical_hit_chance", UpgradesTweakData.DEF_CAT_FEATURE, "anatomist_critical_hit_chance", "snp", true, 1, false, self.description_data_types.generic_multiplier)

	self.values.smg.anatomist_critical_hit_chance = {
		1.1
	}

	self:_create_definition("smg_anatomist_critical_hit_chance", UpgradesTweakData.DEF_CAT_FEATURE, "anatomist_critical_hit_chance", "smg", true, 1, false, self.description_data_types.generic_multiplier)

	self.values.weapon.anatomist_legshot_knockdown = {
		142
	}

	self:_create_definition("weapon_anatomist_legshot_knockdown", UpgradesTweakData.DEF_CAT_FEATURE, "anatomist_legshot_knockdown", UpgradesTweakData.UPG_CAT_WEAPON, true, 1, false, self.description_data_types.generic_multiplier)

	self.anatomist_bodies = {
		Idstring("hit_Body"),
		Idstring("hit_RightLeg"),
		Idstring("hit_RightUpLeg"),
		Idstring("hit_LeftLeg"),
		Idstring("hit_LeftUpLeg")
	}
	self.values.player.perseverance_prolong_life = {
		5,
		9
	}

	self:_create_definition_levels("player_perseverance_prolong_life", UpgradesTweakData.DEF_CAT_FEATURE, "perseverance_prolong_life", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.perseverance_prolong_life, self.description_data_types.raw_value_amount)

	self.values.player.perseverance_killshot_timer_increase = {
		0.5
	}

	self:_create_definition("player_perseverance_killshot_timer_increase", UpgradesTweakData.DEF_CAT_FEATURE, "perseverance_killshot_timer_increase", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.perseverance_timer_diminish = 0.912
	self.values.interaction.perseverance_allowed_interaction = {
		true
	}

	self:_create_definition("interaction_perseverance_allowed_interaction", UpgradesTweakData.DEF_CAT_FEATURE, "perseverance_allowed_interaction", UpgradesTweakData.UPG_CAT_INTERACT, false, 1)

	self.values.player.bellhop_weight_increase_off_primary = {
		3
	}

	self:_create_definition("player_bellhop_weight_increase_off_primary", UpgradesTweakData.DEF_CAT_FEATURE, "bellhop_weight_increase_off_primary", UpgradesTweakData.UPG_CAT_PLAYER, false, 1, false, self.description_data_types.raw_value_amount)

	self.values.player.bellhop_weight_penalty_removal_melees = {
		true
	}

	self:_create_definition("player_bellhop_weight_penalty_removal_melees", UpgradesTweakData.DEF_CAT_FEATURE, "bellhop_weight_penalty_removal_melees", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.bellhop_weight_penalty_removal_throwables = {
		true
	}

	self:_create_definition("player_bellhop_weight_penalty_removal_throwables", UpgradesTweakData.DEF_CAT_FEATURE, "bellhop_weight_penalty_removal_throwables", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.bellhop_carry_stamina_consume_slower = {
		0.75,
		0.5
	}

	self:_create_definition_levels("player_bellhop_carry_stamina_consume_slower", UpgradesTweakData.DEF_CAT_FEATURE, "bellhop_carry_stamina_consume_slower", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.bellhop_carry_stamina_consume_slower, self.description_data_types.reductive_multiplier)

	self.values.player.primary_ammo_increase = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_primary_ammo_increase", UpgradesTweakData.DEF_CAT_FEATURE, "primary_ammo_increase", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.primary_ammo_increase, self.description_data_types.generic_multiplier)

	self.values.player.secondary_ammo_increase = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_secondary_ammo_increase", UpgradesTweakData.DEF_CAT_FEATURE, "secondary_ammo_increase", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.secondary_ammo_increase, self.description_data_types.generic_multiplier)

	self.values.player.carry_penalty_decrease = {
		1.05,
		1.1,
		1.15,
		1.2
	}

	self:_create_definition_levels("player_carry_penalty_decrease", UpgradesTweakData.DEF_CAT_FEATURE, "carry_penalty_decrease", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.carry_penalty_decrease, self.description_data_types.generic_multiplier_reductive_string)

	self.values.player.carry_weight_increase = {
		1,
		1,
		2,
		2
	}

	self:_create_definition_levels("player_carry_weight_increase", UpgradesTweakData.DEF_CAT_FEATURE, "carry_weight_increase", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.carry_weight_increase, self.description_data_types.raw_value_amount)

	self.values.player.running_damage_reduction = {
		0.9,
		0.8,
		0.68,
		0.5
	}

	self:_create_definition_levels("player_running_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "running_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.running_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.crouching_damage_reduction = {
		0.93,
		0.86,
		0.77,
		0.65
	}

	self:_create_definition_levels("player_crouching_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "crouching_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.crouching_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.bullet_damage_reduction = {
		0.95,
		0.9,
		0.85,
		0.75
	}

	self:_create_definition_levels("player_bullet_damage_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "bullet_damage_reduction", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.bullet_damage_reduction, self.description_data_types.reductive_multiplier)

	self.values.player.headshot_damage_multiplier = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_headshot_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "headshot_damage_multiplier", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.headshot_damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.player.long_dis_revive = {
		1
	}

	self:_create_definition_levels("player_long_dis_revive", UpgradesTweakData.DEF_CAT_FEATURE, "long_dis_revive", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.long_dis_revive)
end

function UpgradesTweakData:_create_raid_definitions_abilities()
	self.values.player.highlight_enemy_damage_bonus = {
		1.1,
		1.2,
		1.33,
		1.5
	}

	self:_create_definition_levels("player_highlight_enemy_damage_bonus", UpgradesTweakData.DEF_CAT_FEATURE, "highlight_enemy_damage_bonus", UpgradesTweakData.UPG_CAT_PLAYER, true, self.values.player.highlight_enemy_damage_bonus, self.description_data_types.generic_multiplier)

	self.values.player.undetectable_by_spotters = {
		true
	}

	self:_create_definition("player_undetectable_by_spotters", UpgradesTweakData.DEF_CAT_FEATURE, "undetectable_by_spotters", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.self_administered_adrenaline = {
		true
	}

	self:_create_definition("player_self_administered_adrenaline", UpgradesTweakData.DEF_CAT_FEATURE, "self_administered_adrenaline", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.toss_ammo = {
		1,
		2
	}

	self:_create_definition("player_toss_ammo", UpgradesTweakData.DEF_CAT_FEATURE, "toss_ammo", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.player.warcry_dmg = {
		{
			data = 1,
			name = 1,
			radius = 2,
			cooldown = 10,
			time = 1
		}
	}

	self:_create_definition("player_warcry_dmg", UpgradesTweakData.DEF_CAT_FEATURE, "warcry_dmg", UpgradesTweakData.UPG_CAT_PLAYER, true, 1)

	self.values.temporary.candy_health_regen = {
		{
			1.05,
			20
		}
	}

	self:_create_definition("temporary_candy_health_regen", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_health_regen", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.temporary.candy_god_mode = {
		{
			0,
			20
		}
	}

	self:_create_definition("temporary_candy_god_mode", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_god_mode", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.temporary.candy_armor_pen = {
		{
			5,
			20
		}
	}

	self:_create_definition("temporary_candy_armor_pen", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_armor_pen", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.temporary.candy_unlimited_ammo = {
		{
			true,
			20
		}
	}

	self:_create_definition("temporary_candy_unlimited_ammo", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_unlimited_ammo", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.temporary.candy_sprint_speed = {
		{
			1.45,
			25
		}
	}

	self:_create_definition("temporary_candy_sprint_speed", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_sprint_speed", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.temporary.candy_jump_boost = {
		{
			1.66,
			25
		}
	}

	self:_create_definition("temporary_candy_jump_boost", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_jump_boost", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.temporary.candy_attack_damage = {
		{
			1.45,
			30
		}
	}

	self:_create_definition("temporary_candy_attack_damage", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_attack_damage", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)

	self.values.temporary.candy_critical_hit_chance = {
		{
			1.8,
			25
		}
	}

	self:_create_definition("temporary_candy_critical_hit_chance", UpgradesTweakData.DEF_CAT_TEMPORARY, "candy_critical_hit_chance", UpgradesTweakData.UPG_CAT_TEMPORARY, false, 1)
end

function UpgradesTweakData:_create_weapon_definitions()
	self.values.player.recon_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_recon_tier_4_unlocked", UpgradesTweakData.DEF_CAT_FEATURE, "recon_tier_4_unlocked", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.assault_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_assault_tier_4_unlocked", UpgradesTweakData.DEF_CAT_FEATURE, "assault_tier_4_unlocked", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.infiltrator_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_infiltrator_tier_4_unlocked", UpgradesTweakData.DEF_CAT_FEATURE, "infiltrator_tier_4_unlocked", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.demolitions_tier_4_unlocked = {
		true
	}

	self:_create_definition("player_demolitions_tier_4_unlocked", UpgradesTweakData.DEF_CAT_FEATURE, "demolitions_tier_4_unlocked", UpgradesTweakData.UPG_CAT_PLAYER, false, 1)

	self.values.player.weapon_tier_unlocked = {
		1,
		2,
		3,
		4
	}

	self:_create_definition_levels("player_weapon_tier_unlocked", UpgradesTweakData.DEF_CAT_FEATURE, "weapon_tier_unlocked", UpgradesTweakData.UPG_CAT_PLAYER, false, self.values.player.weapon_tier_unlocked)

	self.definitions.m1911 = {
		weapon_id = "m1911",
		category = nil,
		free = true,
		factory_id = "wpn_fps_pis_m1911",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.geco = {
		weapon_id = "geco",
		category = nil,
		factory_id = "wpn_fps_sho_geco",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.dp28 = {
		weapon_id = "dp28",
		category = nil,
		factory_id = "wpn_fps_lmg_dp28",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.bren = {
		weapon_id = "bren",
		category = nil,
		factory_id = "wpn_fps_lmg_bren",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.tt33 = {
		weapon_id = "tt33",
		category = nil,
		factory_id = "wpn_fps_pis_tt33",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.ithaca = {
		weapon_id = "ithaca",
		category = nil,
		factory_id = "wpn_fps_sho_ithaca",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.browning = {
		weapon_id = "browning",
		category = nil,
		factory_id = "wpn_fps_sho_browning",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.welrod = {
		weapon_id = "welrod",
		category = nil,
		factory_id = "wpn_fps_pis_welrod",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.shotty = {
		weapon_id = "shotty",
		category = nil,
		factory_id = "wpn_fps_pis_shotty",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.kar_98k = {
		weapon_id = "kar_98k",
		category = nil,
		factory_id = "wpn_fps_snp_kar_98k",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.lee_enfield = {
		weapon_id = "lee_enfield",
		category = nil,
		factory_id = "wpn_fps_snp_lee_enfield",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.thompson = {
		weapon_id = "thompson",
		category = nil,
		free = true,
		factory_id = "wpn_fps_smg_thompson",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.sten = {
		weapon_id = "sten",
		category = nil,
		free = true,
		factory_id = "wpn_fps_smg_sten",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.garand = {
		weapon_id = "garand",
		category = nil,
		factory_id = "wpn_fps_ass_garand",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.m1918 = {
		weapon_id = "m1918",
		category = nil,
		factory_id = "wpn_fps_lmg_m1918",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.m1903 = {
		weapon_id = "m1903",
		category = nil,
		factory_id = "wpn_fps_snp_m1903",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.m1912 = {
		weapon_id = "m1912",
		category = nil,
		factory_id = "wpn_fps_sho_m1912",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.mp38 = {
		weapon_id = "mp38",
		category = nil,
		free = true,
		factory_id = "wpn_fps_smg_mp38",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.mp44 = {
		weapon_id = "mp44",
		category = nil,
		free = true,
		factory_id = "wpn_fps_ass_mp44",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.carbine = {
		weapon_id = "carbine",
		category = nil,
		free = true,
		factory_id = "wpn_fps_ass_carbine",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.mg42 = {
		weapon_id = "mg42",
		category = nil,
		factory_id = "wpn_fps_lmg_mg42",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.c96 = {
		weapon_id = "c96",
		category = nil,
		factory_id = "wpn_fps_pis_c96",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.webley = {
		weapon_id = "webley",
		category = nil,
		factory_id = "wpn_fps_pis_webley",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.mosin = {
		weapon_id = "mosin",
		category = nil,
		factory_id = "wpn_fps_snp_mosin",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.sterling = {
		weapon_id = "sterling",
		category = nil,
		factory_id = "wpn_fps_smg_sterling",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.definitions.geco = {
		weapon_id = "geco",
		category = nil,
		free = true,
		factory_id = "wpn_fps_sho_geco",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
end

function UpgradesTweakData:_create_melee_weapon_definitions()
	self.definitions[UpgradesTweakData.UPG_CAT_WEAPON] = {
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
	self.definitions.ammo_bag = {
		category = "grenade"
	}
	self.definitions.gold_bar = {
		category = "grenade"
	}
	self.definitions.thermite = {
		category = "grenade"
	}
	self.definitions.anti_tank = {
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

	self:_create_definition_levels("primary_weapon_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "primary_weapon", false, self.values.primary_weapon.damage_multiplier)

	self.values.primary_weapon.recoil_reduction = {
		0.95,
		0.9,
		0.85,
		0.8,
		0.7
	}

	self:_create_definition_levels("primary_weapon_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "primary_weapon", false, self.values.primary_weapon.recoil_reduction)

	self.values.primary_weapon.reload_speed_multiplier = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("primary_weapon_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "primary_weapon", true, self.values.primary_weapon.reload_speed_multiplier, self.description_data_types.generic_multiplier)

	self.values.primary_weapon.enter_steelsight_speed_multiplier = {
		1.15,
		1.3,
		1.45,
		1.6,
		1.75
	}

	self:_create_definition_levels("primary_weapon_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "primary_weapon", false, self.values.primary_weapon.enter_steelsight_speed_multiplier)

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

	self:_create_definition_levels("primary_weapon_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "primary_weapon", false, self.values.primary_weapon.spread_multiplier)

	self.values.primary_weapon.magazine_upgrade = {
		5,
		10,
		12,
		15,
		32
	}

	self:_create_definition_levels("primary_weapon_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "magazine_upgrade", "primary_weapon", false, self.values.primary_weapon.magazine_upgrade)
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

	self:_create_definition_levels("secondary_weapon_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "secondary_weapon", false, self.values.secondary_weapon.damage_multiplier)

	self.values.secondary_weapon.recoil_reduction = {
		0.95,
		0.9,
		0.85,
		0.8,
		0.7
	}

	self:_create_definition_levels("secondary_weapon_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "secondary_weapon", false, self.values.secondary_weapon.recoil_reduction)

	self.values.secondary_weapon.reload_speed_multiplier = {
		1.2,
		1.4,
		1.65,
		2
	}

	self:_create_definition_levels("secondary_weapon_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "secondary_weapon", true, self.values.secondary_weapon.reload_speed_multiplier, self.description_data_types.generic_multiplier)

	self.values.secondary_weapon.enter_steelsight_speed_multiplier = {
		1.25,
		1.35,
		1.5,
		1.9,
		2.25
	}

	self:_create_definition_levels("secondary_weapon_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "secondary_weapon", false, self.values.secondary_weapon.enter_steelsight_speed_multiplier)

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

	self:_create_definition_levels("secondary_weapon_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "secondary_weapon", false, self.values.secondary_weapon.spread_multiplier)

	self.values.secondary_weapon.magazine_upgrade = {
		5,
		8,
		13,
		16,
		23
	}

	self:_create_definition_levels("secondary_weapon_magazine_upgrade", UpgradesTweakData.DEF_CAT_FEATURE, "magazine_upgrade", "secondary_weapon", false, self.values.secondary_weapon.magazine_upgrade)
end

function UpgradesTweakData:_pistol_definitions()
	self.values.pistol = self.values.pistol or {}
	self.values.pistol.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("pistol_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "pistol", false, self.values.pistol.recoil_reduction)

	self.values.pistol.reload_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("pistol_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "pistol", false, self.values.pistol.reload_speed_multiplier)

	self.values.pistol.damage_multiplier = {
		1.1,
		1.2
	}

	self:_create_definition_levels("pistol_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "pistol", false, self.values.pistol.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.pistol.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("pistol_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "pistol", false, self.values.pistol.enter_steelsight_speed_multiplier)

	self.values.pistol.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("pistol_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "pistol", false, self.values.pistol.spread_multiplier)

	self.values.pistol.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("pistol_fire_rate_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fire_rate_multiplier", "pistol", false, self.values.pistol.fire_rate_multiplier)

	self.values.pistol.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("pistol_exit_run_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "exit_run_speed_multiplier", "pistol", false, self.values.pistol.exit_run_speed_multiplier)

	self.values.pistol.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("pistol_hip_fire_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_spread_multiplier", "pistol", false, self.values.pistol.hip_fire_spread_multiplier)

	self.values.pistol.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("pistol_hip_fire_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_damage_multiplier", "pistol", false, self.values.pistol.hip_fire_damage_multiplier)

	self.values.pistol.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("pistol_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "swap_speed_multiplier", "pistol", false, self.values.pistol.swap_speed_multiplier)

	self.values.pistol.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("pistol_stacking_hit_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_damage_multiplier", "pistol", false, self.values.pistol.stacking_hit_damage_multiplier)

	self.values.pistol.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("pistol_stacking_hit_expire_t", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_expire_t", "pistol", false, self.values.pistol.stacking_hit_expire_t)

	self.values.pistol.damage_addend = {
		1.5
	}

	self:_create_definition_levels("pistol_damage_addend", UpgradesTweakData.DEF_CAT_FEATURE, "damage_addend", "pistol", false, self.values.pistol.damage_addend)
end

function UpgradesTweakData:_assault_rifle_definitions()
	self.values.assault_rifle.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("assault_rifle_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "assault_rifle", false, self.values.assault_rifle.recoil_reduction)

	self.values.assault_rifle.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("assault_rifle_recoil_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_multiplier", "assault_rifle", false, self.values.assault_rifle.recoil_multiplier)

	self.values.assault_rifle.reload_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("assault_rifle_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.reload_speed_multiplier)

	self.values.assault_rifle.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("assault_rifle_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "assault_rifle", false, self.values.assault_rifle.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.assault_rifle.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("assault_rifle_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.enter_steelsight_speed_multiplier)

	self.values.assault_rifle.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("assault_rifle_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "assault_rifle", false, self.values.assault_rifle.spread_multiplier)

	self.values.assault_rifle.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("assault_rifle_fire_rate_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fire_rate_multiplier", "assault_rifle", false, self.values.assault_rifle.fire_rate_multiplier)

	self.values.assault_rifle.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("assault_rifle_exit_run_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "exit_run_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.exit_run_speed_multiplier)

	self.values.assault_rifle.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("assault_rifle_hip_fire_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_spread_multiplier", "assault_rifle", false, self.values.assault_rifle.hip_fire_spread_multiplier)

	self.values.assault_rifle.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("assault_rifle_hip_fire_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_damage_multiplier", "assault_rifle", false, self.values.assault_rifle.hip_fire_damage_multiplier)

	self.values.assault_rifle.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("assault_rifle_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "swap_speed_multiplier", "assault_rifle", false, self.values.assault_rifle.swap_speed_multiplier)

	self.values.assault_rifle.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("assault_rifle_stacking_hit_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_damage_multiplier", "assault_rifle", false, self.values.assault_rifle.stacking_hit_damage_multiplier)

	self.values.assault_rifle.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("assault_rifle_stacking_hit_expire_t", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_expire_t", "assault_rifle", false, self.values.assault_rifle.stacking_hit_expire_t)

	self.values.assault_rifle.damage_addend = {
		1.5
	}

	self:_create_definition_levels("assault_rifle_damage_addend", UpgradesTweakData.DEF_CAT_FEATURE, "damage_addend", "assault_rifle", false, self.values.assault_rifle.damage_addend)

	self.values.assault_rifle.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("assault_rifle_move_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "move_spread_multiplier", "assault_rifle", false, self.values.assault_rifle.move_spread_multiplier)

	self.values.assault_rifle.zoom_increase = {
		2
	}

	self:_create_definition_levels("assault_rifle_zoom_increase", UpgradesTweakData.DEF_CAT_FEATURE, "zoom_increase", "assault_rifle", false, self.values.assault_rifle.zoom_increase)
end

function UpgradesTweakData:_lmg_definitions()
	self.values.lmg.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("lmg_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "lmg", false, self.values.lmg.recoil_reduction)

	self.values.lmg.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("lmg_recoil_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_multiplier", "lmg", false, self.values.lmg.recoil_multiplier)

	self.values.lmg.reload_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("lmg_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "lmg", false, self.values.lmg.reload_speed_multiplier)

	self.values.lmg.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("lmg_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "lmg", false, self.values.lmg.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.lmg.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("lmg_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "lmg", false, self.values.lmg.enter_steelsight_speed_multiplier)

	self.values.lmg.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("lmg_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "lmg", false, self.values.lmg.spread_multiplier)

	self.values.lmg.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("lmg_fire_rate_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fire_rate_multiplier", "lmg", false, self.values.lmg.fire_rate_multiplier)

	self.values.lmg.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("lmg_exit_run_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "exit_run_speed_multiplier", "lmg", false, self.values.lmg.exit_run_speed_multiplier)

	self.values.lmg.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("lmg_hip_fire_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_spread_multiplier", "lmg", false, self.values.lmg.hip_fire_spread_multiplier)

	self.values.lmg.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("lmg_hip_fire_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_damage_multiplier", "lmg", false, self.values.lmg.hip_fire_damage_multiplier)

	self.values.lmg.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("lmg_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "swap_speed_multiplier", "lmg", false, self.values.lmg.swap_speed_multiplier)

	self.values.lmg.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("lmg_stacking_hit_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_damage_multiplier", "lmg", false, self.values.lmg.stacking_hit_damage_multiplier)

	self.values.lmg.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("lmg_stacking_hit_expire_t", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_expire_t", "lmg", false, self.values.lmg.stacking_hit_expire_t)

	self.values.lmg.damage_addend = {
		1.5
	}

	self:_create_definition_levels("lmg_damage_addend", UpgradesTweakData.DEF_CAT_FEATURE, "damage_addend", "lmg", false, self.values.lmg.damage_addend)

	self.values.lmg.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("lmg_move_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "move_spread_multiplier", "lmg", false, self.values.lmg.move_spread_multiplier)

	self.values.lmg.zoom_increase = {
		2
	}

	self:_create_definition_levels("lmg_zoom_increase", UpgradesTweakData.DEF_CAT_FEATURE, "zoom_increase", "lmg", false, self.values.lmg.zoom_increase)
end

function UpgradesTweakData:_snp_definitions()
	self.values.snp.recoil_reduction = {
		0.9,
		0.8,
		0.7
	}

	self:_create_definition_levels("snp_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "snp", false, self.values.snp.recoil_reduction)

	self.values.snp.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("snp_recoil_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_multiplier", "snp", false, self.values.snp.recoil_multiplier)

	self.values.snp.reload_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("snp_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "snp", false, self.values.snp.reload_speed_multiplier)

	self.values.snp.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("snp_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "snp", false, self.values.snp.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.snp.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("snp_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "snp", false, self.values.snp.enter_steelsight_speed_multiplier)

	self.values.snp.spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("snp_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "snp", false, self.values.snp.spread_multiplier)

	self.values.snp.fire_rate_multiplier = {
		2
	}

	self:_create_definition_levels("snp_fire_rate_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fire_rate_multiplier", "snp", false, self.values.snp.fire_rate_multiplier)

	self.values.snp.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("snp_exit_run_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "exit_run_speed_multiplier", "snp", false, self.values.snp.exit_run_speed_multiplier)

	self.values.snp.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("snp_hip_fire_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_spread_multiplier", "snp", false, self.values.snp.hip_fire_spread_multiplier)

	self.values.snp.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("snp_hip_fire_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_damage_multiplier", "snp", false, self.values.snp.hip_fire_damage_multiplier)

	self.values.snp.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("snp_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "swap_speed_multiplier", "snp", false, self.values.snp.swap_speed_multiplier)

	self.values.snp.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("snp_stacking_hit_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_damage_multiplier", "snp", false, self.values.snp.stacking_hit_damage_multiplier)

	self.values.snp.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("snp_stacking_hit_expire_t", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_expire_t", "snp", false, self.values.snp.stacking_hit_expire_t)

	self.values.snp.damage_addend = {
		1.5
	}

	self:_create_definition_levels("snp_damage_addend", UpgradesTweakData.DEF_CAT_FEATURE, "damage_addend", "snp", false, self.values.snp.damage_addend)

	self.values.snp.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("snp_move_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "move_spread_multiplier", "snp", false, self.values.snp.move_spread_multiplier)

	self.values.snp.zoom_increase = {
		2
	}

	self:_create_definition_levels("snp_zoom_increase", UpgradesTweakData.DEF_CAT_FEATURE, "zoom_increase", "snp", false, self.values.snp.zoom_increase)
end

function UpgradesTweakData:_smg_definitions()
	self.values.smg.recoil_reduction = {
		0.75
	}

	self:_create_definition_levels("smg_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "smg", false, self.values.smg.recoil_reduction)

	self.values.smg.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("smg_recoil_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_multiplier", "smg", false, self.values.smg.recoil_multiplier)

	self.values.smg.reload_speed_multiplier = {
		1.35
	}

	self:_create_definition_levels("smg_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "smg", false, self.values.smg.reload_speed_multiplier)

	self.values.smg.damage_multiplier = {
		1.1,
		1.2,
		1.33
	}

	self:_create_definition_levels("smg_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "smg", false, self.values.smg.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.smg.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("smg_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "smg", false, self.values.smg.enter_steelsight_speed_multiplier)

	self.values.smg.spread_multiplier = {
		0.9,
		0.8
	}

	self:_create_definition_levels("smg_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "smg", false, self.values.smg.spread_multiplier)

	self.values.smg.fire_rate_multiplier = {
		1.2
	}

	self:_create_definition_levels("smg_fire_rate_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fire_rate_multiplier", "smg", false, self.values.smg.fire_rate_multiplier)

	self.values.smg.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("smg_exit_run_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "exit_run_speed_multiplier", "smg", false, self.values.smg.exit_run_speed_multiplier)

	self.values.smg.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("smg_hip_fire_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_spread_multiplier", "smg", false, self.values.smg.hip_fire_spread_multiplier)

	self.values.smg.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("smg_hip_fire_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_damage_multiplier", "smg", false, self.values.smg.hip_fire_damage_multiplier)

	self.values.smg.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("smg_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "swap_speed_multiplier", "smg", false, self.values.smg.swap_speed_multiplier)

	self.values.smg.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("smg_stacking_hit_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_damage_multiplier", "smg", false, self.values.smg.stacking_hit_damage_multiplier)

	self.values.smg.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("smg_stacking_hit_expire_t", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_expire_t", "smg", false, self.values.smg.stacking_hit_expire_t)

	self.values.smg.damage_addend = {
		1.5
	}

	self:_create_definition_levels("smg_damage_addend", UpgradesTweakData.DEF_CAT_FEATURE, "damage_addend", "smg", false, self.values.smg.damage_addend)

	self.values.smg.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("smg_move_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "move_spread_multiplier", "smg", false, self.values.smg.move_spread_multiplier)

	self.values.smg.zoom_increase = {
		2
	}

	self:_create_definition_levels("smg_zoom_increase", UpgradesTweakData.DEF_CAT_FEATURE, "zoom_increase", "smg", false, self.values.smg.zoom_increase)
end

function UpgradesTweakData:_shotgun_definitions()
	self.values.shotgun.recoil_reduction = {
		0.85,
		0.75
	}

	self:_create_definition_levels("shotgun_recoil_reduction", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_reduction", "shotgun", false, self.values.shotgun.recoil_reduction)

	self.values.shotgun.recoil_multiplier = {
		0.75
	}

	self:_create_definition_levels("shotgun_recoil_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "recoil_multiplier", "shotgun", false, self.values.shotgun.recoil_multiplier)

	self.values.shotgun.reload_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("shotgun_reload_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "reload_speed_multiplier", "shotgun", false, self.values.shotgun.reload_speed_multiplier)

	self.values.shotgun.damage_multiplier = {
		1.05,
		1.1,
		1.15
	}

	self:_create_definition_levels("shotgun_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "damage_multiplier", "shotgun", false, self.values.shotgun.damage_multiplier, self.description_data_types.generic_multiplier)

	self.values.shotgun.enter_steelsight_speed_multiplier = {
		2
	}

	self:_create_definition_levels("shotgun_enter_steelsight_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "enter_steelsight_speed_multiplier", "shotgun", false, self.values.shotgun.enter_steelsight_speed_multiplier)

	self.values.shotgun.spread_multiplier = {
		1.1
	}

	self:_create_definition_levels("shotgun_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "spread_multiplier", "shotgun", false, self.values.shotgun.spread_multiplier)

	self.values.shotgun.fire_rate_multiplier = {
		1.2
	}

	self:_create_definition_levels("shotgun_fire_rate_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "fire_rate_multiplier", "shotgun", false, self.values.shotgun.fire_rate_multiplier)

	self.values.shotgun.exit_run_speed_multiplier = {
		1.25
	}

	self:_create_definition_levels("shotgun_exit_run_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "exit_run_speed_multiplier", "shotgun", false, self.values.shotgun.exit_run_speed_multiplier)

	self.values.shotgun.hip_fire_spread_multiplier = {
		0.8
	}

	self:_create_definition_levels("shotgun_hip_fire_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_spread_multiplier", "shotgun", false, self.values.shotgun.hip_fire_spread_multiplier)

	self.values.shotgun.hip_fire_damage_multiplier = {
		1.2
	}

	self:_create_definition_levels("shotgun_hip_fire_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "hip_fire_damage_multiplier", "shotgun", false, self.values.shotgun.hip_fire_damage_multiplier)

	self.values.shotgun.swap_speed_multiplier = {
		1.5
	}

	self:_create_definition_levels("shotgun_swap_speed_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "swap_speed_multiplier", "shotgun", false, self.values.shotgun.swap_speed_multiplier)

	self.values.shotgun.stacking_hit_damage_multiplier = {
		0.1
	}

	self:_create_definition_levels("shotgun_stacking_hit_damage_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_damage_multiplier", "shotgun", false, self.values.shotgun.stacking_hit_damage_multiplier)

	self.values.shotgun.stacking_hit_expire_t = {
		2,
		8
	}

	self:_create_definition_levels("shotgun_stacking_hit_expire_t", UpgradesTweakData.DEF_CAT_FEATURE, "stacking_hit_expire_t", "shotgun", false, self.values.shotgun.stacking_hit_expire_t)

	self.values.shotgun.damage_addend = {
		1.5
	}

	self:_create_definition_levels("shotgun_damage_addend", UpgradesTweakData.DEF_CAT_FEATURE, "damage_addend", "shotgun", false, self.values.shotgun.damage_addend)

	self.values.shotgun.move_spread_multiplier = {
		0.5
	}

	self:_create_definition_levels("shotgun_move_spread_multiplier", UpgradesTweakData.DEF_CAT_FEATURE, "move_spread_multiplier", "shotgun", false, self.values.shotgun.move_spread_multiplier)

	self.values.shotgun.zoom_increase = {
		2
	}

	self:_create_definition_levels("shotgun_zoom_increase", UpgradesTweakData.DEF_CAT_FEATURE, "zoom_increase", "shotgun", false, self.values.shotgun.zoom_increase)

	self.values.shotgun.consume_no_ammo_chance = {
		0.01,
		0.03
	}

	self:_create_definition_levels("shotgun_consume_no_ammo_chance", UpgradesTweakData.DEF_CAT_FEATURE, "consume_no_ammo_chance", "shotgun", false, self.values.shotgun.consume_no_ammo_chance)

	self.values.shotgun.melee_knockdown_mul = {
		1.75
	}

	self:_create_definition_levels("shotgun_melee_knockdown_mul", UpgradesTweakData.DEF_CAT_FEATURE, "melee_knockdown_mul", "shotgun", false, self.values.shotgun.melee_knockdown_mul)
end

function UpgradesTweakData:_create_definition_levels(definition_name, definition_category, upgrade_name, upgrade_category, incremental, values, description_data)
	for index = 1, #values do
		local definition_name_level = definition_name .. "_" .. index
		local name_id = "menu_" .. definition_name

		self:_create_definition(definition_name_level, definition_category, upgrade_name, upgrade_category, incremental, index, true, description_data)
	end
end

function UpgradesTweakData:_create_definition(definition_name, definition_category, upgrade_name, upgrade_category, incremental, value_index, has_levels, description_data)
	local name_id = "menu_" .. upgrade_category .. "_" .. upgrade_name
	local definition = {
		name_id = nil,
		category = nil,
		incremental = nil,
		upgrade = nil,
		description_data = nil,
		has_levels = nil,
		category = definition_category,
		incremental = incremental,
		description_data = description_data,
		has_levels = has_levels or false,
		name_id = name_id,
		upgrade = {
			category = nil,
			value = nil,
			upgrade = nil,
			category = upgrade_category,
			upgrade = upgrade_name,
			value = value_index
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
	self.values.weapon.passive_headshot_damage_multiplier = {
		1.25
	}
	self.values.player.special_enemy_highlight = {
		true
	}
	self.values.player.hostage_trade = {
		true
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
	self.sentry_gun_base_ammo = 150
	self.sentry_gun_base_armor = 10
	self.doctor_bag_base = 2
	self.grenade_crate_base = 3
	self.max_grenade_amount = 3
	self.morale_boost_speed_bonus = 1.2
	self.morale_boost_suppression_resistance = 1
	self.morale_boost_time = 10
	self.morale_boost_reload_speed_bonus = 1.2
	self.morale_boost_base_cooldown = 3.5
	self.hostage_max_num = {
		health = 10,
		stamina = 10,
		damage_dampener = 1,
		health_regen = 1
	}
	self.on_headshot_dealt_cooldown = 2
	self.on_killshot_cooldown = 2
	self.on_damage_dealt_cooldown = 2
	self.close_combat_distance = 1800
	self.weapon_movement_penalty = {}
	self.explosive_bullet = {
		curve_pow = 0.5,
		player_dmg_mul = 0.1,
		range = 200
	}
	self.explosive_bullet.feedback_range = self.explosive_bullet.range
	self.explosive_bullet.camera_shake_max_mul = 2
	self.values.player.marked_enemy_extra_damage = {
		true
	}
	self.values.player.revive_health_boost = {
		1
	}
	self.revive_health_multiplier = {
		1.3
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
	self.values.team.stamina.multiplier = {
		1.5
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
	self.values.player.suppression_multiplier = {
		1.25,
		1.75
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
	self.values.ammo_bag.quantity = {
		1
	}
	self.values.ammo_bag.ammo_increase = {
		2
	}
	self.values.saw.extra_ammo_multiplier = {
		1.5
	}
	self.values.saw.lock_damage_multiplier = {
		1.2,
		1.4
	}
	self.values.saw.enemy_slicer = {
		true
	}
	self.values.weapon.passive_damage_multiplier = {
		1.05
	}
	self.values.trip_mine.quantity_1 = {
		1
	}
	self.values.sentry_gun.armor_multiplier = {
		2.5
	}
	self.values.weapon.single_spread_multiplier = {
		0.8
	}
	self.values.sentry_gun.spread_multiplier = {
		0.5
	}
	self.values.sentry_gun.rot_speed_multiplier = {
		2.5
	}
	self.values.sentry_gun.extra_ammo_multiplier = {
		1.5,
		2.5
	}
	self.values.sentry_gun.shield = {
		true
	}
	self.values.trip_mine.quantity_3 = {
		3
	}
	self.values.sentry_gun.quantity = {
		1
	}
	self.values.sentry_gun.damage_multiplier = {
		4
	}
	self.values.player.armor_multiplier = {
		1.5
	}
	self.values.weapon.passive_recoil_multiplier = {
		0.95,
		0.9
	}
	self.values.player.passive_armor_multiplier = {
		1.1,
		1.25
	}
	self.values.player.suspicion_multiplier = {
		0.75
	}
	self.values.weapon.silencer_damage_multiplier = {
		1.15,
		1.3
	}
	self.values.weapon.silencer_recoil_multiplier = {
		0.5
	}
	self.values.weapon.silencer_spread_multiplier = {
		0.5
	}
	self.values.player.run_and_shoot = {
		true
	}
	self.values.player.morale_boost = {
		true
	}
	self.values.player.concealment_modifier = {
		5,
		10,
		15
	}
	self.values.sentry_gun.armor_multiplier2 = {
		1.25
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
	self.values.player.mark_enemy_time_multiplier = {
		1
	}
	self.values.player.detection_risk_damage_multiplier = {
		{
			0.05,
			7,
			"above",
			40
		}
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
	self.values.saw.melee_knockdown_mul = {
		1.75
	}
	self.values.team.weapon.move_spread_multiplier = {
		1.1
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
	self.values.player.level_2_armor_addend = {
		2
	}
	self.values.player.level_3_armor_addend = {
		2
	}
	self.values.player.level_4_armor_addend = {
		2
	}
	self.values.team.armor.multiplier = {
		1.05
	}
	self.values.team.damage_dampener.hostage_multiplier = {
		0.92
	}
	self.values.player.revive_damage_reduction_level = {
		1,
		2
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
	self.values.player.headshot_regen_armor_bonus = {
		1.5,
		4.5
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
end

function UpgradesTweakData:_old_init()
	self.level_tree = {
		{
			name_id = "body_armor",
			upgrades = nil,
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
	self.values.player.toolset = {
		0.95,
		0.9,
		0.85,
		0.8
	}
	self.values.player.suppressed_multiplier = {
		0.5
	}
	self.steps.player = {
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
	self.values.striker = {
		reload_speed_multiplier = {
			1.15
		}
	}

	self:_player_definitions()
	self:_flamethrower_mk2_definitions()
	self:_weapon_upgrades_definitions()
	self:_team_definitions()
	self:_shape_charge_definitions()
	self:_temporary_definitions()

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
	self.values.temporary = self.values.temporary or {}
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
		category = "armor",
		armor_id = "level_2"
	}
	self.definitions.body_armor2 = {
		name_id = "bm_armor_level_3",
		category = "armor",
		armor_id = "level_3"
	}
	self.definitions.body_armor3 = {
		name_id = "bm_armor_level_4",
		category = "armor",
		armor_id = "level_4"
	}
	self.definitions.body_armor4 = {
		name_id = "bm_armor_level_5",
		category = "armor",
		armor_id = "level_5"
	}
	self.definitions.body_armor5 = {
		name_id = "bm_armor_level_6",
		category = "armor",
		armor_id = "level_6"
	}
	self.definitions.body_armor6 = {
		name_id = "bm_armor_level_7",
		category = "armor",
		armor_id = "level_7"
	}
	self.definitions.player_detection_risk_damage_multiplier = {
		name_id = "menu_player_detection_risk_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "detection_risk_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_mark_enemy_time_multiplier = {
		name_id = "menu_player_mark_enemy_time_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "mark_enemy_time_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_revive_damage_reduction_level_1 = {
		name_id = "menu_player_revive_damage_reduction_level",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "revive_damage_reduction_level",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_revive_damage_reduction_level_2 = {
		name_id = "menu_player_revive_damage_reduction_level",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "revive_damage_reduction_level",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_passive_health_multiplier_4 = {
		name_id = "menu_player_health_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 4,
			upgrade = "passive_health_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_tier_armor_multiplier_4 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 4,
			upgrade = "tier_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_tier_armor_multiplier_5 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 5,
			upgrade = "tier_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_tier_armor_multiplier_6 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 6,
			upgrade = "tier_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.team_passive_armor_multiplier = {
		name_id = "menu_team_passive_armor_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "armor",
			value = 1,
			upgrade = "multiplier"
		}
	}
	self.definitions.player_armor_multiplier = {
		name_id = "menu_player_armor_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_tier_armor_multiplier_1 = {
		name_id = "menu_player_tier_armor_multiplier_1",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "tier_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_tier_armor_multiplier_2 = {
		name_id = "menu_player_tier_armor_multiplier_2",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "tier_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_tier_armor_multiplier_3 = {
		name_id = "menu_player_tier_armor_multiplier_3",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 3,
			upgrade = "tier_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier_1 = {
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = nil,
		incremental = true,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_convert_enemies_health_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier_2 = {
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = nil,
		incremental = true,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "passive_convert_enemies_health_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_level_2_armor_addend = {
		name_id = "menu_player_level_2_armor_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "level_2_armor_addend",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_level_3_armor_addend = {
		name_id = "menu_player_level_3_armor_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "level_3_armor_addend",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_level_4_armor_addend = {
		name_id = "menu_player_level_4_armor_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "level_4_armor_addend",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_damage_dampener_outnumbered_strong = {
		name_id = "menu_player_dmg_dampener_outnumbered_strong",
		category = "temporary",
		upgrade = nil,
		upgrade = {
			category = "temporary",
			value = 1,
			upgrade = "dmg_dampener_outnumbered_strong"
		}
	}
	self.definitions.player_damage_dampener_close_contact_1 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = nil,
		upgrade = {
			category = "temporary",
			value = 1,
			upgrade = "dmg_dampener_close_contact"
		}
	}
	self.definitions.player_damage_dampener_close_contact_2 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = nil,
		upgrade = {
			category = "temporary",
			value = 2,
			upgrade = "dmg_dampener_close_contact"
		}
	}
	self.definitions.player_damage_dampener_close_contact_3 = {
		name_id = "menu_player_dmg_dampener_close_contact",
		category = "temporary",
		upgrade = nil,
		upgrade = {
			category = "temporary",
			value = 3,
			upgrade = "dmg_dampener_close_contact"
		}
	}
	self.definitions.player_passive_armor_multiplier_1 = {
		name_id = "menu_player_passive_armor_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_passive_armor_multiplier_2 = {
		name_id = "menu_player_passive_armor_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "passive_armor_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_xp_multiplier = {
		name_id = "menu_player_xp_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "xp_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_non_special_melee_multiplier = {
		name_id = "menu_player_non_special_melee_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "non_special_melee_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_concealment_bonus_1 = {
		name_id = "menu_player_passive_suspicion_bonus",
		category = nil,
		incremental = true,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "concealment_modifier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_concealment_bonus_2 = {
		name_id = "menu_player_passive_suspicion_bonus",
		category = nil,
		incremental = true,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "concealment_modifier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_concealment_bonus_3 = {
		name_id = "menu_player_passive_suspicion_bonus",
		category = nil,
		incremental = true,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "concealment_modifier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_suspicion_bonus = {
		name_id = "menu_player_suspicion_bonus",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "suspicion_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_suppressed_bonus = {
		name_id = "menu_player_suppressed_bonus",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "suppressed_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_suppression_bonus = {
		name_id = "menu_player_suppression_bonus",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "suppression_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_damage_multiplier_outnumbered = {
		name_id = "menu_player_dmg_mul_outnumbered",
		category = "temporary",
		upgrade = nil,
		upgrade = {
			category = "temporary",
			value = 1,
			upgrade = "dmg_multiplier_outnumbered"
		}
	}
	self.definitions.player_damage_dampener_outnumbered = {
		name_id = "menu_player_dmg_damp_outnumbered",
		category = "temporary",
		upgrade = nil,
		upgrade = {
			category = "temporary",
			value = 1,
			upgrade = "dmg_dampener_outnumbered"
		}
	}
	self.definitions.player_suppression_mul_2 = {
		name_id = "menu_player_suppression_mul_2",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "suppression_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_marked_enemy_extra_damage = {
		name_id = "menu_player_marked_enemy_extra_damage",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "marked_enemy_extra_damage",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_special_enemy_highlight = {
		name_id = "menu_player_special_enemy_highlight",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "special_enemy_highlight",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_convert_enemies = {
		name_id = "menu_player_convert_enemies",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "convert_enemies",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_convert_enemies_max_minions_1 = {
		name_id = "menu_player_convert_enemies_max_minions",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "convert_enemies_max_minions",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_convert_enemies_max_minions_2 = {
		name_id = "menu_player_convert_enemies_max_minions",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "convert_enemies_max_minions",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_convert_enemies_interaction_speed_multiplier = {
		name_id = "menu_player_convert_enemies_interaction_speed_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "convert_enemies_interaction_speed_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_convert_enemies_health_multiplier = {
		name_id = "menu_player_convert_enemies_health_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "convert_enemies_health_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_passive_convert_enemies_health_multiplier = {
		name_id = "menu_player_passive_convert_enemies_health_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_convert_enemies_health_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_convert_enemies_damage_multiplier = {
		name_id = "menu_player_convert_enemies_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "convert_enemies_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_passive_convert_enemies_damage_multiplier = {
		name_id = "menu_player_passive_convert_enemies_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_convert_enemies_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_hostage_trade = {
		name_id = "menu_player_hostage_trade",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "hostage_trade",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_morale_boost = {
		name_id = "menu_player_morale_boost",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "morale_boost",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_revive_health_boost = {
		name_id = "menu_player_revive_health_boost",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "revive_health_boost",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_run_and_shoot = {
		name_id = "menu_player_run_and_shoot",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "run_and_shoot",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_headshot_regen_armor_bonus_1 = {
		name_id = "menu_player_headshot_regen_armor_bonus",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "headshot_regen_armor_bonus",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.player_headshot_regen_armor_bonus_2 = {
		name_id = "menu_player_headshot_regen_armor_bonus",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "headshot_regen_armor_bonus",
			category = UpgradesTweakData.UPG_CAT_PLAYER
		}
	}
	self.definitions.toolset = {
		description_text_id = "toolset",
		image = "upgrades_toolset",
		aquire = nil,
		icon = "equipment_toolset",
		step = 1,
		tree = 4,
		name_id = "debug_upgrade_toolset1",
		category = "equipment",
		slot = 2,
		subtitle_id = "debug_upgrade_toolset1",
		unlock_lvl = 0,
		title_id = "debug_upgrade_player_upgrade",
		equipment_id = "toolset",
		image_slice = "upgrades_toolset_slice",
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
			image = "upgrades_toolset",
			depends_on = nil,
			icon = "equipment_toolset",
			prio = nil,
			step = nil,
			tree = 4,
			upgrade = nil,
			name_id = nil,
			category = nil,
			subtitle_id = nil,
			unlock_lvl = nil,
			title_id = "debug_upgrade_player_upgrade",
			image_slice = "upgrades_toolset_slice",
			step = self.steps.player.toolset[i],
			category = UpgradesTweakData.DEF_CAT_FEATURE,
			subtitle_id = "debug_upgrade_toolset" .. i,
			name_id = "debug_upgrade_toolset" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				category = nil,
				value = nil,
				upgrade = "toolset",
				category = UpgradesTweakData.UPG_CAT_PLAYER,
				value = i
			}
		}
	end
end

function UpgradesTweakData:_trip_mine_definitions()
	self.definitions.trip_mine = {
		description_text_id = "trip_mine",
		image = "upgrades_tripmines",
		prio = "high",
		icon = "equipment_trip_mine",
		step = 4,
		tree = 2,
		name_id = "debug_trip_mine",
		category = "equipment",
		slot = 1,
		subtitle_id = "debug_trip_mine",
		unlock_lvl = 0,
		title_id = "debug_upgrade_new_equipment",
		equipment_id = "trip_mine",
		image_slice = "upgrades_tripmines_slice"
	}
	self.definitions.trip_mine_quantity_increase_1 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "trip_mine",
			value = 1,
			upgrade = "quantity_1"
		}
	}
	self.definitions.trip_mine_quantity_increase_2 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "trip_mine",
			value = 1,
			upgrade = "quantity_2"
		}
	}
	self.definitions.trip_mine_quantity_increase_3 = {
		name_id = "menu_trip_mine_quantity_increase_1",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "trip_mine",
			value = 1,
			upgrade = "quantity_3"
		}
	}
end

function UpgradesTweakData:_ammo_bag_definitions()
	self.definitions.ammo_bag = {
		description_text_id = "ammo_bag",
		image = "upgrades_ammobag",
		prio = "high",
		icon = "equipment_ammo_bag",
		step = 2,
		tree = 1,
		name_id = "debug_ammo_bag",
		category = "equipment",
		slot = 1,
		subtitle_id = "debug_ammo_bag",
		unlock_lvl = 0,
		title_id = "debug_upgrade_new_equipment",
		equipment_id = "ammo_bag",
		image_slice = "upgrades_ammobag_slice"
	}

	for i, _ in ipairs(self.values.ammo_bag.ammo_increase) do
		local depends_on = i - 1 > 0 and "ammo_bag_ammo_increase" .. i - 1 or "ammo_bag"
		local unlock_lvl = 11
		local prio = i == 1 and "high"
		self.definitions["ammo_bag_ammo_increase" .. i] = {
			description_text_id = "ammo_bag_increase",
			image = "upgrades_ammobag",
			depends_on = nil,
			icon = "equipment_ammo_bag",
			prio = nil,
			step = nil,
			tree = 1,
			upgrade = nil,
			name_id = nil,
			category = "equipment_upgrade",
			subtitle_id = nil,
			unlock_lvl = nil,
			title_id = "debug_ammo_bag",
			image_slice = "upgrades_ammobag_slice",
			step = self.steps.ammo_bag.ammo_increase[i],
			name_id = "debug_upgrade_ammo_bag_ammo_increase" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				category = "ammo_bag",
				value = nil,
				upgrade = "ammo_increase",
				value = i
			}
		}
	end
end

function UpgradesTweakData:_doctor_bag_definitions()
	self.definitions.doctor_bag = {
		description_text_id = "doctor_bag",
		image = "upgrades_doctorbag",
		prio = "high",
		icon = "equipment_doctor_bag",
		step = 5,
		tree = 3,
		name_id = "debug_doctor_bag",
		category = "equipment",
		slot = 1,
		subtitle_id = "debug_doctor_bag",
		unlock_lvl = 2,
		title_id = "debug_upgrade_new_equipment",
		equipment_id = "doctor_bag",
		image_slice = "upgrades_doctorbag_slice"
	}

	for i, _ in ipairs(self.values.doctor_bag.amount_increase) do
		local depends_on = i - 1 > 0 and "doctor_bag_amount_increase" .. i - 1 or "doctor_bag"
		local unlock_lvl = 3
		local prio = i == 1 and "high"
		self.definitions["doctor_bag_amount_increase" .. i] = {
			description_text_id = "doctor_bag_increase",
			image = "upgrades_doctorbag",
			depends_on = nil,
			icon = "equipment_doctor_bag",
			prio = nil,
			step = nil,
			tree = 3,
			upgrade = nil,
			name_id = nil,
			category = "equipment_upgrade",
			subtitle_id = nil,
			unlock_lvl = nil,
			title_id = "debug_doctor_bag",
			image_slice = "upgrades_doctorbag_slice",
			step = self.steps.doctor_bag.amount_increase[i],
			name_id = "debug_upgrade_doctor_bag_amount_increase" .. i,
			subtitle_id = "debug_upgrade_amount_increase" .. i,
			depends_on = depends_on,
			unlock_lvl = unlock_lvl,
			prio = prio,
			upgrade = {
				category = "doctor_bag",
				value = nil,
				upgrade = "amount_increase",
				value = i
			}
		}
	end

	self.definitions.doctor_bag_quantity = {
		name_id = "menu_doctor_bag_quantity",
		category = "equipment_upgrade",
		upgrade = nil,
		upgrade = {
			category = "doctor_bag",
			value = 1,
			upgrade = "quantity"
		}
	}
	self.definitions.passive_doctor_bag_interaction_speed_multiplier = {
		name_id = "menu_passive_doctor_bag_interaction_speed_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "doctor_bag",
			value = 1,
			upgrade = "interaction_speed_multiplier"
		}
	}
end

function UpgradesTweakData:_weapon_upgrades_definitions()
	self.definitions.assault_rifle_move_spread_index_addend = {
		name_id = "menu_assault_rifle_move_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "assault_rifle",
			value = 1,
			upgrade = "move_spread_index_addend"
		}
	}
	self.definitions.snp_move_spread_index_addend = {
		name_id = "menu_snp_move_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "snp",
			value = 1,
			upgrade = "move_spread_index_addend"
		}
	}
	self.definitions.weapon_silencer_spread_index_addend = {
		name_id = "menu_weapon_silencer_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "silencer_spread_index_addend",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.pistol_spread_index_addend = {
		name_id = "menu_pistol_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "pistol",
			value = 1,
			upgrade = "spread_index_addend"
		}
	}
	self.definitions.akimbo_spread_index_addend = {
		name_id = "menu_akimbo_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "akimbo",
			value = 1,
			upgrade = "spread_index_addend"
		}
	}
	self.definitions.shotgun_hip_fire_spread_index_addend = {
		name_id = "menu_shotgun_hip_fire_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "shotgun",
			value = 1,
			upgrade = "hip_fire_spread_index_addend"
		}
	}
	self.definitions.weapon_hip_fire_spread_index_addend = {
		name_id = "menu_weapon_hip_fire_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "hip_fire_spread_index_addend",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_single_spread_index_addend = {
		name_id = "menu_weapon_single_spread_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "single_spread_index_addend",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.shotgun_recoil_index_addend = {
		name_id = "menu_shotgun_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "shotgun",
			value = 1,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.assault_rifle_recoil_index_addend = {
		name_id = "menu_assault_rifle_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "assault_rifle",
			value = 1,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.lmg_recoil_index_addend = {
		name_id = "menu_lmg_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "lmg",
			value = 1,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.snp_recoil_index_addend = {
		name_id = "menu_snp_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "snp",
			value = 1,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.akimbo_recoil_index_addend_1 = {
		name_id = "menu_akimbo_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "akimbo",
			value = 1,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.akimbo_recoil_index_addend_2 = {
		name_id = "menu_akimbo_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "akimbo",
			value = 2,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.akimbo_recoil_index_addend_3 = {
		name_id = "menu_akimbo_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "akimbo",
			value = 3,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.weapon_silencer_recoil_index_addend = {
		name_id = "menu_weapon_silencer_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "silencer_recoil_index_addend",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_modded_damage_multiplier = {
		name_id = "menu_modded_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "modded_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_modded_spread_multiplier = {
		name_id = "menu_modded_spread_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "modded_spread_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_modded_recoil_multiplier = {
		name_id = "menu_modded_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "modded_recoil_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_swap_speed_multiplier = {
		name_id = "menu_weapon_swap_speed_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "swap_speed_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_single_spread_multiplier = {
		name_id = "menu_weapon_single_spread_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "single_spread_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_silencer_spread_multiplier = {
		name_id = "menu_silencer_spread_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "silencer_spread_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_silencer_recoil_multiplier = {
		name_id = "menu_silencer_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "silencer_recoil_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_silencer_damage_multiplier_1 = {
		name_id = "silencer_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "silencer_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_silencer_damage_multiplier_2 = {
		name_id = "silencer_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "silencer_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_passive_reload_speed_multiplier = {
		name_id = "menu_weapon_reload_speed",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_reload_speed_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_passive_recoil_multiplier_1 = {
		name_id = "menu_weapon_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_recoil_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_passive_recoil_multiplier_2 = {
		name_id = "menu_weapon_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 2,
			upgrade = "passive_recoil_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_passive_headshot_damage_multiplier = {
		name_id = "menu_weapon_headshot_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_headshot_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_passive_damage_multiplier = {
		name_id = "menu_weapon_passive_damage_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "passive_damage_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_spread_multiplier = {
		name_id = "menu_weapon_spread_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "spread_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.weapon_fire_rate_multiplier = {
		name_id = "menu_weapon_fire_rate_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "fire_rate_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
end

function UpgradesTweakData:_team_definitions()
	self.definitions.team_pistol_recoil_index_addend = {
		name_id = "menu_team_pistol_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "pistol",
			value = 1,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.team_akimbo_recoil_index_addend = {
		name_id = "menu_team_akimbo_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "akimbo",
			value = 1,
			upgrade = "recoil_index_addend"
		}
	}
	self.definitions.team_weapon_recoil_index_addend = {
		name_id = "menu_team_weapon_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "recoil_index_addend",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.team_pistol_suppression_recoil_index_addend = {
		name_id = "menu_team_pistol_suppression_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "pistol",
			value = 1,
			upgrade = "suppression_recoil_index_addend"
		}
	}
	self.definitions.team_akimbo_suppression_recoil_index_addend = {
		name_id = "menu_team_akimbo_suppression_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "akimbo",
			value = 1,
			upgrade = "suppression_recoil_index_addend"
		}
	}
	self.definitions.team_weapon_suppression_recoil_index_addend = {
		name_id = "menu_team_weapon_suppression_recoil_index_addend",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "suppression_recoil_index_addend",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.team_pistol_suppression_recoil_multiplier = {
		name_id = "menu_team_pistol_suppression_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "pistol",
			value = 1,
			upgrade = "suppression_recoil_multiplier"
		}
	}
	self.definitions.team_akimbo_suppression_recoil_multiplier = {
		name_id = "menu_team_akimbo_suppression_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "akimbo",
			value = 1,
			upgrade = "suppression_recoil_multiplier"
		}
	}
	self.definitions.team_pistol_recoil_multiplier = {
		name_id = "menu_team_pistol_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "pistol",
			value = 1,
			upgrade = "recoil_multiplier"
		}
	}
	self.definitions.team_akimbo_recoil_multiplier = {
		name_id = "menu_team_akimbo_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "akimbo",
			value = 1,
			upgrade = "recoil_multiplier"
		}
	}
	self.definitions.team_weapon_suppression_recoil_multiplier = {
		name_id = "menu_team_weapon_suppression_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "suppression_recoil_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.team_weapon_recoil_multiplier = {
		name_id = "menu_team_weapon_recoil_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "recoil_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.team_xp_multiplier = {
		name_id = "menu_team_xp_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "xp",
			value = 1,
			upgrade = "multiplier"
		}
	}
	self.definitions.team_stamina_multiplier = {
		name_id = "menu_team_stamina_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "stamina",
			value = 1,
			upgrade = "multiplier"
		}
	}
	self.definitions.team_passive_stamina_multiplier_1 = {
		name_id = "menu_team_stamina_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "stamina",
			value = 1,
			upgrade = "passive_multiplier"
		}
	}
	self.definitions.team_passive_stamina_multiplier_2 = {
		name_id = "menu_team_stamina_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "stamina",
			value = 2,
			upgrade = "passive_multiplier"
		}
	}
	self.definitions.team_passive_health_multiplier = {
		name_id = "menu_team_health_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "health",
			value = 1,
			upgrade = "passive_multiplier"
		}
	}
	self.definitions.team_hostage_health_multiplier = {
		name_id = "menu_team_hostage_health_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "health",
			value = 1,
			upgrade = "hostage_multiplier"
		}
	}
	self.definitions.team_hostage_stamina_multiplier = {
		name_id = "menu_team_hostage_stamina_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "stamina",
			value = 1,
			upgrade = "hostage_multiplier"
		}
	}
	self.definitions.team_move_spread_multiplier = {
		name_id = "menu_team_move_spread_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = nil,
			value = 1,
			upgrade = "move_spread_multiplier",
			category = UpgradesTweakData.UPG_CAT_WEAPON
		}
	}
	self.definitions.team_hostage_damage_dampener_multiplier = {
		name_id = "menu_team_hostage_damage_dampener_multiplier",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_TEAM,
		upgrade = {
			category = "damage_dampener",
			value = 1,
			upgrade = "hostage_multiplier"
		}
	}
end

function UpgradesTweakData:_temporary_definitions()
	self.definitions.temporary_revive_health_boost = {
		name_id = "menu_temporary_revive_health_boost",
		category = "temporary",
		upgrade = nil,
		upgrade = {
			category = "temporary",
			value = 1,
			upgrade = "revive_health_boost"
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_1 = {
		name_id = "menu_passive_revive_damage_reduction_1",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "temporary",
			value = 1,
			upgrade = "passive_revive_damage_reduction_1"
		}
	}
	self.definitions.temporary_passive_revive_damage_reduction_2 = {
		name_id = "menu_passive_revive_damage_reduction",
		category = nil,
		upgrade = nil,
		category = UpgradesTweakData.DEF_CAT_FEATURE,
		upgrade = {
			category = "temporary",
			value = 2,
			upgrade = "passive_revive_damage_reduction"
		}
	}
end

function UpgradesTweakData:_shape_charge_definitions()
	self.definitions.shape_charge = {
		name_id = "menu_shape_charge",
		category = "equipment",
		equipment_id = "shape_charge"
	}
end

function UpgradesTweakData:_first_aid_kit_definitions()
	self.definitions.first_aid_kit = {
		name_id = "menu_equipment_first_aid_kit",
		category = "equipment",
		equipment_id = "first_aid_kit",
		slot = 1
	}
	self.definitions.first_aid_kit_quantity_increase_1 = {
		name_id = "menu_first_aid_kit_quantity_1",
		category = "equipment_upgrade",
		incremental = true,
		upgrade = nil,
		upgrade = {
			category = "first_aid_kit",
			value = 1,
			upgrade = "quantity"
		}
	}
	self.definitions.first_aid_kit_quantity_increase_2 = {
		name_id = "menu_first_aid_kit_quantity_2",
		category = "equipment_upgrade",
		incremental = true,
		upgrade = nil,
		upgrade = {
			category = "first_aid_kit",
			value = 1,
			upgrade = "quantity"
		}
	}
	self.definitions.first_aid_kit_deploy_time_multiplier = {
		name_id = "menu_first_aid_kit_deploy_time_multiplier",
		category = "equipment_upgrade",
		incremental = true,
		upgrade = nil,
		upgrade = {
			category = "first_aid_kit",
			value = 1,
			upgrade = "deploy_time_multiplier"
		}
	}
	self.definitions.first_aid_kit_damage_reduction_upgrade = {
		name_id = "menu_first_aid_kit_damage_reduction_upgrade",
		category = "equipment_upgrade",
		incremental = true,
		upgrade = nil,
		upgrade = {
			category = "first_aid_kit",
			value = 1,
			upgrade = "damage_reduction_upgrade"
		}
	}
end

function UpgradesTweakData:_flamethrower_mk2_definitions()
	self.definitions.flamethrower_mk2 = {
		weapon_id = "flamethrower_mk2",
		category = nil,
		factory_id = "wpn_fps_fla_mk2",
		category = UpgradesTweakData.UPG_CAT_WEAPON
	}
	self.flame_bullet = {
		show_blood_hits = false
	}
end
