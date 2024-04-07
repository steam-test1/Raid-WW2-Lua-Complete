WarcryTweakData = WarcryTweakData or class()

function WarcryTweakData:init(tweak_data)
	self:_init_data_sharpshooter()
	self:_init_data_berserk()
	self:_init_data_ghost()
	self:_init_data_clustertruck()
end

function WarcryTweakData:_init_data_sharpshooter()
	self.sharpshooter = {}
	self.sharpshooter.name_id = "warcry_sharpshooter_name"
	self.sharpshooter.desc_id = "warcry_sharpshooter_desc"
	self.sharpshooter.desc_self_id = "warcry_sharpshooter_desc_self"
	self.sharpshooter.desc_short_id = "warcry_sharpshooter_short_desc"
	self.sharpshooter.desc_team_id = "warcry_sharpshooter_team_desc"
	self.sharpshooter.desc_team_short_id = "warcry_sharpshooter_team_short_desc"
	self.sharpshooter.base_duration = 10
	self.sharpshooter.base_kill_fill_amount = 0.1
	self.sharpshooter.headshot_multiplier = 0.3
	self.sharpshooter.distance_multiplier_activation_distance = 1000
	self.sharpshooter.distance_multiplier_addition_per_meter = 0.03
	self.sharpshooter.buffs = {
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
	}
	self.sharpshooter.hud_icon = "player_panel_warcry_sharpshooter"
	self.sharpshooter.menu_icon = "warcry_sharpshooter"
	self.sharpshooter.lerp_duration = 0.75
	self.sharpshooter.ids_effect_name = Idstring("warcry_sharpshooter")
	self.sharpshooter.overlay_pulse_freq = 0.5
	self.sharpshooter.overlay_pulse_ampl = 0.1
	self.sharpshooter.health_boost_sound = "recon_warcry_enemy_hit"
end

function WarcryTweakData:_init_data_berserk()
	self.berserk = {}
	self.berserk.name_id = "warcry_berserk_name"
	self.berserk.desc_id = "warcry_berserk_desc"
	self.berserk.desc_self_id = "warcry_berserk_desc_self"
	self.berserk.desc_short_id = "warcry_berserk_short_desc"
	self.berserk.desc_team_id = "warcry_berserk_team_desc"
	self.berserk.desc_team_short_id = "warcry_berserk_team_short_desc"
	self.berserk.base_duration = 10
	self.berserk.base_kill_fill_amount = 0.1
	self.berserk.dismemberment_multiplier = 0.3
	self.berserk.low_health_multiplier_activation_percentage = 0.4
	self.berserk.low_health_multiplier_min = 0.2
	self.berserk.low_health_multiplier_max = 0.5
	self.berserk.base_team_heal_percentage = 2
	self.berserk.buffs = {
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
	}
	self.berserk.hud_icon = "player_panel_warcry_berserk"
	self.berserk.menu_icon = "warcry_berserk"
	self.berserk.lerp_duration = 0.75
	self.berserk.ids_effect_name = Idstring("warcry_berserk")
	self.berserk.lens_distortion_value = 0.92
	self.berserk.overlay_pulse_freq = 1.3
	self.berserk.overlay_pulse_ampl = 0.1
end

function WarcryTweakData:_init_data_ghost()
	self.ghost = {}
	self.ghost.name_id = "warcry_ghost_name"
	self.ghost.desc_id = "warcry_ghost_desc"
	self.ghost.desc_self_id = "warcry_ghost_desc_self"
	self.ghost.desc_short_id = "warcry_ghost_short_desc"
	self.ghost.desc_team_id = "warcry_ghost_team_desc"
	self.ghost.desc_team_short_id = "warcry_ghost_team_short_desc"
	self.ghost.base_duration = 10
	self.ghost.base_kill_fill_amount = 0.1
	self.ghost.melee_multiplier = 0.3
	self.ghost.distance_multiplier_activation_distance = 500
	self.ghost.distance_multiplier_addition_per_meter = 0.03
	self.ghost.buffs = {
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
	}
	self.ghost.hud_icon = "player_panel_warcry_invisibility"
	self.ghost.menu_icon = "warcry_invisibility"
	self.ghost.lerp_duration = 0.75
	self.ghost.ids_effect_name = Idstring("warcry_ghost")
	self.ghost.desaturation = 0.8
	self.ghost.grain_noise_strength = 10
	self.ghost.tint_distance = 2000
end

function WarcryTweakData:_init_data_clustertruck()
	self.clustertruck = {}
	self.clustertruck.name_id = "warcry_clustertruck_name"
	self.clustertruck.desc_id = "warcry_clustertruck_desc"
	self.clustertruck.desc_self_id = "warcry_clustertruck_desc_self"
	self.clustertruck.desc_short_id = "warcry_clustertruck_short_desc"
	self.clustertruck.desc_team_id = "warcry_clustertruck_team_desc"
	self.clustertruck.desc_team_short_id = "warcry_clustertruck_team_short_desc"
	self.clustertruck.base_duration = 10
	self.clustertruck.killstreak_duration = 10
	self.clustertruck.base_kill_fill_amount = 0.1
	self.clustertruck.explosion_multiplier = 0.15
	self.clustertruck.killstreak_multiplier_bonus_per_enemy = 0.1
	self.clustertruck.grenade_refill_amounts = {
		1,
		1,
		2,
		2,
		2
	}
	self.clustertruck.buffs = {
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
	}
	self.clustertruck.hud_icon = "player_panel_warcry_cluster_truck"
	self.clustertruck.menu_icon = "warcry_cluster_truck"
	self.clustertruck.lerp_duration = 0.75
	self.clustertruck.ids_effect_name = Idstring("warcry_clustertruck")
	self.clustertruck.fire_intensity = 2.6
	self.clustertruck.fire_opacity = 0.5
end
