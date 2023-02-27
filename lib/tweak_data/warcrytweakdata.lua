WarcryTweakData = WarcryTweakData or class()

function WarcryTweakData:init(tweak_data)
	self:_init_data_sharpshooter()
	self:_init_data_berserk()
	self:_init_data_ghost()
	self:_init_data_clustertruck()
end

function WarcryTweakData:_init_data_sharpshooter()
	self.sharpshooter = {
		name_id = "warcry_sharpshooter_name",
		desc_id = "warcry_sharpshooter_desc",
		desc_self_id = "warcry_sharpshooter_desc_self",
		desc_short_id = "warcry_sharpshooter_short_desc",
		desc_team_id = "warcry_sharpshooter_team_desc",
		desc_team_short_id = "warcry_sharpshooter_team_short_desc",
		base_duration = 10,
		base_kill_fill_amount = 0.1,
		headshot_multiplier = 0.3,
		distance_multiplier_activation_distance = 1000,
		distance_multiplier_addition_per_meter = 0.03,
		buffs = {
			{
				"warcry_player_aim_assist",
				"warcry_player_aim_assist_aim_at_head",
				"warcry_player_aim_assist_radius_1",
				"warcry_player_nullify_spread",
				"warcry_team_damage_multiplier_1"
			},
			{
				"warcry_player_aim_assist",
				"warcry_player_aim_assist_aim_at_head",
				"warcry_player_aim_assist_radius_1",
				"warcry_player_nullify_spread",
				"warcry_team_damage_multiplier_1",
				"warcry_player_health_regen_on_kill",
				"warcry_player_health_regen_amount_1"
			},
			{
				"warcry_player_aim_assist",
				"warcry_player_aim_assist_aim_at_head",
				"warcry_player_aim_assist_radius_1",
				"warcry_player_nullify_spread",
				"warcry_team_damage_multiplier_1",
				"warcry_player_health_regen_on_kill",
				"warcry_player_health_regen_amount_2"
			},
			{
				"warcry_player_aim_assist",
				"warcry_player_aim_assist_aim_at_head",
				"warcry_player_aim_assist_radius_1",
				"warcry_player_nullify_spread",
				"warcry_team_damage_multiplier_1",
				"warcry_player_health_regen_on_kill",
				"warcry_player_health_regen_amount_3"
			},
			{
				"warcry_player_aim_assist",
				"warcry_player_aim_assist_aim_at_head",
				"warcry_player_aim_assist_radius_1",
				"warcry_player_nullify_spread",
				"warcry_team_damage_multiplier_1",
				"warcry_player_health_regen_on_kill",
				"warcry_player_health_regen_amount_4",
				"warcry_player_sniper_ricochet"
			}
		},
		hud_icon = "player_panel_warcry_sharpshooter",
		menu_icon = "warcry_sharpshooter",
		lerp_duration = 0.75,
		ids_effect_name = Idstring("warcry_sharpshooter"),
		overlay_pulse_freq = 0.5,
		overlay_pulse_ampl = 0.1,
		health_boost_sound = "recon_warcry_enemy_hit"
	}
end

function WarcryTweakData:_init_data_berserk()
	self.berserk = {
		name_id = "warcry_berserk_name",
		desc_id = "warcry_berserk_desc",
		desc_self_id = "warcry_berserk_desc_self",
		desc_short_id = "warcry_berserk_short_desc",
		desc_team_id = "warcry_berserk_team_desc",
		desc_team_short_id = "warcry_berserk_team_short_desc",
		base_duration = 10,
		base_kill_fill_amount = 0.1,
		dismemberment_multiplier = 0.3,
		low_health_multiplier_activation_percentage = 0.4,
		low_health_multiplier_min = 0.2,
		low_health_multiplier_max = 0.5,
		base_team_heal_percentage = 2,
		buffs = {
			{
				"warcry_player_ammo_consumption_1",
				"warcry_turret_overheat_multiplier_1"
			},
			{
				"warcry_player_ammo_consumption_2",
				"warcry_turret_overheat_multiplier_2"
			},
			{
				"warcry_player_ammo_consumption_3",
				"warcry_turret_overheat_multiplier_3"
			},
			{
				"warcry_player_ammo_consumption_4",
				"warcry_turret_overheat_multiplier_4"
			},
			{
				"warcry_player_ammo_consumption_4",
				"warcry_turret_overheat_multiplier_4",
				"warcry_player_refill_clip"
			}
		},
		hud_icon = "player_panel_warcry_berserk",
		menu_icon = "warcry_berserk",
		lerp_duration = 0.75,
		ids_effect_name = Idstring("warcry_berserk"),
		lens_distortion_value = 0.92,
		overlay_pulse_freq = 1.3,
		overlay_pulse_ampl = 0.1
	}
end

function WarcryTweakData:_init_data_ghost()
	self.ghost = {
		name_id = "warcry_ghost_name",
		desc_id = "warcry_ghost_desc",
		desc_self_id = "warcry_ghost_desc_self",
		desc_short_id = "warcry_ghost_short_desc",
		desc_team_id = "warcry_ghost_team_desc",
		desc_team_short_id = "warcry_ghost_team_short_desc",
		base_duration = 10,
		base_kill_fill_amount = 0.1,
		melee_multiplier = 0.3,
		distance_multiplier_activation_distance = 500,
		distance_multiplier_addition_per_meter = 0.03,
		buffs = {
			{
				"warcry_player_dodge_1",
				"warcry_team_movement_speed_multiplier_1"
			},
			{
				"warcry_player_dodge_2",
				"warcry_team_movement_speed_multiplier_1"
			},
			{
				"warcry_player_dodge_3",
				"warcry_team_movement_speed_multiplier_1"
			},
			{
				"warcry_player_dodge_4",
				"warcry_team_movement_speed_multiplier_1"
			},
			{
				"warcry_player_dodge_5",
				"warcry_team_movement_speed_multiplier_1"
			}
		},
		hud_icon = "player_panel_warcry_invisibility",
		menu_icon = "warcry_invisibility",
		lerp_duration = 0.75,
		ids_effect_name = Idstring("warcry_ghost"),
		desaturation = 0.8,
		grain_noise_strength = 10,
		tint_distance = 2000
	}
end

function WarcryTweakData:_init_data_clustertruck()
	self.clustertruck = {
		name_id = "warcry_clustertruck_name",
		desc_id = "warcry_clustertruck_desc",
		desc_self_id = "warcry_clustertruck_desc_self",
		desc_short_id = "warcry_clustertruck_short_desc",
		desc_team_id = "warcry_clustertruck_team_desc",
		desc_team_short_id = "warcry_clustertruck_team_short_desc",
		base_duration = 10,
		killstreak_duration = 10,
		base_kill_fill_amount = 0.1,
		explosion_multiplier = 0.15,
		killstreak_multiplier_bonus_per_enemy = 0.1,
		grenade_refill_amounts = {
			1,
			1,
			2,
			2,
			2
		},
		buffs = {
			{
				"warcry_player_grenade_clusters_1",
				"warcry_player_grenade_cluster_range_1",
				"warcry_player_grenade_cluster_damage_1",
				"warcry_team_damage_reduction_multiplier_1"
			},
			{
				"warcry_player_grenade_clusters_1",
				"warcry_player_grenade_cluster_range_2",
				"warcry_player_grenade_cluster_damage_2",
				"warcry_team_damage_reduction_multiplier_1"
			},
			{
				"warcry_player_grenade_clusters_2",
				"warcry_player_grenade_cluster_range_2",
				"warcry_player_grenade_cluster_damage_2",
				"warcry_team_damage_reduction_multiplier_1"
			},
			{
				"warcry_player_grenade_clusters_2",
				"warcry_player_grenade_cluster_range_3",
				"warcry_player_grenade_cluster_damage_3",
				"warcry_team_damage_reduction_multiplier_1"
			},
			{
				"warcry_player_grenade_clusters_3",
				"warcry_player_grenade_cluster_range_3",
				"warcry_player_grenade_cluster_damage_3",
				"warcry_team_damage_reduction_multiplier_1",
				"warcry_player_grenade_airburst_1"
			}
		},
		hud_icon = "player_panel_warcry_cluster_truck",
		menu_icon = "warcry_cluster_truck",
		lerp_duration = 0.75,
		ids_effect_name = Idstring("warcry_clustertruck"),
		fire_intensity = 2.6,
		fire_opacity = 0.5
	}
end
