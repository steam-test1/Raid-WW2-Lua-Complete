WarcryTweakData = WarcryTweakData or class()

function WarcryTweakData:init(tweak_data)
	self.dummy = {
		hud_icon = "player_panel_warcry_sharpshooter"
	}

	self:_init_sharpshooter()
	self:_init_silver_bullet()
	self:_init_berserk()
	self:_init_sentry()
	self:_init_ghost()
	self:_init_pain_train()
	self:_init_clustertruck()
	self:_init_scorched_earth()
end

function WarcryTweakData:_init_sharpshooter()
	self.sharpshooter = {
		name_id = "warcry_sharpshooter_name",
		overlay_pulse_freq = 0.5,
		overlay_pulse_ampl = 0.1,
		health_boost_sound = "recon_warcry_enemy_hit",
		headshot_multiplier = 0.5,
		base_kill_fill_amount = 0.06666666666666667,
		base_duration = 10,
		hud_icon = "player_panel_warcry_sharpshooter",
		sound_switch = "warcry_echo",
		lerp_duration = 0.75,
		desc_id = "warcry_sharpshooter_desc",
		buffs = {
			{
				"warcry_player_aim_assist",
				"warcry_player_aim_assist_aim_at_head",
				"warcry_player_aim_assist_radius_1",
				"warcry_player_nullify_spread"
			},
			{
				"warcry_player_health_regen_amount_1",
				"warcry_player_health_regen_on_kill"
			},
			{
				"warcry_player_health_regen_amount_2"
			},
			{
				"warcry_player_health_regen_amount_3",
				"warcry_player_sniper_ricochet"
			}
		},
		ids_effect_name = Idstring("warcry_sharpshooter")
	}
end

function WarcryTweakData:_init_silver_bullet()
	self.silver_bullet = {
		name_id = "skill_warcry_silver_bullet_name",
		activation_callout = "warcry_sharpshooter",
		duration_bonus_diminish = 0.65,
		fill_drain_multiplier = 0.0025,
		tint_fov = 0.2,
		grain_noise_strength = 1,
		desaturation = 0.5,
		base_kill_fill_amount = 0.08333333333333333,
		base_duration = 7.5,
		hud_icon = "player_panel_warcry_silver_bullet",
		sound_switch = "warcry_heartbeat",
		lerp_duration = 0.75,
		desc_id = "warcry_silver_bullet_desc",
		buffs = {
			{
				"warcry_player_silver_bullet_tint_distance_1",
				"warcry_player_shoot_through_walls",
				"warcry_player_shoot_through_enemies_2",
				"warcry_player_shoot_through_shields",
				"warcry_player_nullify_spread"
			},
			{
				"warcry_player_killshot_duration_bonus"
			},
			{
				"warcry_player_silver_bullet_tint_distance_2",
				"warcry_player_silver_bullet_drain_reduction"
			},
			{
				"warcry_player_penetrate_damage_multiplier"
			}
		},
		ids_effect_name = Idstring("warcry_ghost")
	}
end

function WarcryTweakData:_init_berserk()
	self.berserk = {
		lerp_duration = 0.75,
		name_id = "warcry_berserk_name",
		lens_distortion_value = 0.92,
		distorts_lense = true,
		overlay_pulse_freq = 1.3,
		overlay_pulse_ampl = 0.1,
		base_kill_fill_amount = 0.06666666666666667,
		base_duration = 10,
		hud_icon = "player_panel_warcry_berserk",
		sound_switch = "warcry_flame",
		dismemberment_multiplier = 0.3,
		desc_id = "warcry_berserk_desc",
		buffs = {
			{
				"warcry_player_ammo_consumption_1",
				"warcry_player_kill_heal_bonus_1"
			},
			{
				"warcry_player_kill_heal_bonus_2",
				"warcry_turret_overheat_multiplier"
			},
			{
				"warcry_player_ammo_consumption_2",
				"warcry_player_kill_heal_bonus_3"
			},
			{
				"warcry_player_ammo_consumption_3",
				"warcry_player_refill_clip"
			}
		},
		ids_effect_name = Idstring("warcry_berserk")
	}
end

function WarcryTweakData:_init_sentry()
	self.sentry = {
		name_id = "skill_warcry_sentry_name",
		activation_callout = "warcry_berserk",
		distorts_lense = true,
		lens_distortion_value = 1.02,
		overlay_pulse_freq = 1.3,
		overlay_pulse_ampl = 0.1,
		base_kill_fill_amount = 0.09090909090909091,
		base_duration = 6,
		hud_icon = "player_panel_warcry_sentry",
		sound_switch = "warcry_spiral",
		lerp_duration = 0.75,
		desc_id = "warcry_sentry_desc",
		buffs = {
			{
				"warcry_player_shooting_movement_speed_reduction",
				"warcry_player_nullify_spread",
				"warcry_player_nullify_recoil",
				"warcry_temporary_sentry_shooting"
			},
			{
				"warcry_player_magazine_size_multiplier",
				"warcry_player_shooting_damage_reduction_1"
			},
			{
				"warcry_player_shooting_drain_reduction",
				"warcry_player_shooting_damage_reduction_2"
			},
			{
				"warcry_player_shoot_through_enemies_1",
				"warcry_player_dismember_always"
			}
		},
		ids_effect_name = Idstring("warcry_berserk")
	}
end

function WarcryTweakData:_init_ghost()
	self.ghost = {
		melee_multiplier = 0.3,
		name_id = "warcry_ghost_name",
		tint_distance = 3200,
		grain_noise_strength = 10,
		desaturation = 0.8,
		base_kill_fill_amount = 0.06666666666666667,
		base_duration = 8,
		hud_icon = "player_panel_warcry_invisibility",
		sound_switch = "warcry_heartbeat",
		lerp_duration = 0.75,
		desc_id = "warcry_ghost_desc",
		buffs = {
			{
				"warcry_player_dodge_1"
			},
			{
				"warcry_player_dodge_2"
			},
			{
				"warcry_player_dodge_3"
			},
			{
				"warcry_player_dodge_4"
			}
		},
		ids_effect_name = Idstring("warcry_ghost")
	}
end

function WarcryTweakData:_init_pain_train()
	self.pain_train = {
		knockdown_distance = 170,
		name_id = "skill_warcry_pain_train_name",
		lens_distortion_value = 1.02,
		distorts_lense = true,
		interrupt_penalty_percentage = 0.1,
		knockdown_fill_penalty = 0.15,
		activation_threshold = 0.5,
		base_kill_fill_amount = 0.08333333333333333,
		base_duration = 4.6,
		hud_icon = "player_panel_warcry_pain_train",
		lerp_duration = 0.75,
		desc_id = "warcry_pain_train_desc",
		buffs = {
			{
				"warcry_player_charge_damage_reduction_1",
				"warcry_player_charge_knockdown_fov_1"
			},
			{},
			{
				"warcry_player_charge_knockdown_fov_2",
				"warcry_player_charge_damage_reduction_2"
			},
			{
				"warcry_player_charge_damage_reduction_3",
				"warcry_player_charge_knockdown_flamer"
			}
		}
	}
end

function WarcryTweakData:_init_clustertruck()
	self.clustertruck = {
		name_id = "warcry_clustertruck_name",
		fire_intensity = 2.6,
		interrupt_penalty_percentage = 0.2,
		fire_opacity = 0.5,
		interrupt_penalty_multiplier = 0.7,
		activation_equip_weapon = "anti_tank",
		base_kill_fill_amount = 0.06666666666666667,
		base_duration = 8,
		hud_icon = "player_panel_warcry_cluster_truck",
		sound_switch = "warcry_spiral",
		lerp_duration = 0.75,
		desc_id = "warcry_clustertruck_desc",
		buffs = {
			{
				"warcry_player_grenade_clusters_1",
				"warcry_player_grenade_cluster_damage_1",
				"warcry_player_grenade_cluster_range_1"
			},
			{
				"warcry_player_grenade_cluster_damage_2",
				"warcry_player_grenade_cluster_range_2"
			},
			{
				"warcry_player_grenade_clusters_2",
				"warcry_player_grenade_cluster_damage_3",
				"warcry_player_grenade_cluster_range_3"
			},
			{
				"warcry_player_grenade_airburst"
			}
		},
		ids_effect_name = Idstring("warcry_clustertruck")
	}
end

function WarcryTweakData:_init_scorched_earth()
	self.scorched_earth = {
		name_id = "skill_warcry_scorched_earth_name",
		fire_intensity = 3,
		interrupt_penalty_percentage = 0.2,
		fire_opacity = 0.4,
		interrupt_penalty_multiplier = 0.7,
		activation_equip_weapon = "thermite",
		base_kill_fill_amount = 0.05555555555555555,
		base_duration = 10,
		hud_icon = "player_panel_warcry_scorched_earth",
		sound_switch = "warcry_spiral",
		lerp_duration = 0.7,
		desc_id = "skill_warcry_scorched_earth_desc",
		buffs = {
			{},
			{
				"warcry_player_thermite_shot_detonation"
			},
			{},
			{
				"warcry_player_thermite_finale_detonation"
			}
		},
		ids_effect_name = Idstring("warcry_clustertruck")
	}
end
