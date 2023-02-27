ProjectilesTweakData = ProjectilesTweakData or class()

function ProjectilesTweakData:init(tweak_data)
	self.m24 = {
		name_id = "bm_grenade_frag",
		weapon_id = "m24_grenade",
		unit = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24",
		unit_hand = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_hand",
		unit_dummy = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		can_airburst = true,
		damage = 950,
		player_damage = 20,
		range = 500
	}
	self.m24.enemy_proximity_range = self.m24.range * 0.6
	self.m24.killzone_range = 0.75
	self.m24.init_timer = 4.5
	self.m24.animations = {
		equip_id = "equip_welrod"
	}
	self.m24.sound_event = "grenade_explode"
	self.m24.launch_speed = 350
	self.m24.gui = {
		rotation_offset = 3,
		distance_offset = -80,
		height_offset = -14,
		display_offset = 10,
		initial_rotation = {}
	}
	self.m24.gui.initial_rotation.yaw = -90
	self.m24.gui.initial_rotation.pitch = 60
	self.m24.gui.initial_rotation.roll = 0
	self.concrete = {
		name_id = "bm_grenade_concrete",
		unit = "units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete",
		unit_hand = "units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete_hand",
		unit_dummy = "units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		can_airburst = true,
		damage = 850,
		player_damage = 24,
		range = 750
	}
	self.concrete.enemy_proximity_range = self.concrete.range * 0.6
	self.concrete.killzone_range = 0.75
	self.concrete.init_timer = 4.5
	self.concrete.animations = {
		equip_id = "equip_welrod"
	}
	self.concrete.sound_event = "new_grenade_explode"
	self.concrete.launch_speed = 275
	self.concrete.gui = {
		rotation_offset = 3,
		distance_offset = -80,
		height_offset = -14,
		display_offset = 10,
		initial_rotation = {}
	}
	self.concrete.gui.initial_rotation.yaw = -90
	self.concrete.gui.initial_rotation.pitch = 60
	self.concrete.gui.initial_rotation.roll = 0
	self.d343 = {
		name_id = "bm_grenade_d343",
		unit = "units/upd_003/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343",
		unit_hand = "units/upd_003/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343_hand",
		unit_dummy = "units/upd_003/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		can_airburst = true,
		damage = 950,
		player_damage = 28,
		range = 500
	}
	self.d343.enemy_proximity_range = self.d343.range * 0.6
	self.d343.killzone_range = 0.75
	self.d343.init_timer = 4.5
	self.d343.animations = {
		equip_id = "equip_welrod"
	}
	self.d343.sound_event = "d43d_grenade_explode"
	self.d343.launch_speed = 200
	self.d343.gui = {
		rotation_offset = 0,
		distance_offset = -120,
		height_offset = -8,
		display_offset = 16,
		initial_rotation = {}
	}
	self.d343.gui.initial_rotation.yaw = 0
	self.d343.gui.initial_rotation.pitch = 90
	self.d343.gui.initial_rotation.roll = 30
	self.mills = {
		name_id = "bm_grenade_mills",
		unit = "units/upd_015/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills",
		unit_hand = "units/upd_015/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills_hand",
		unit_dummy = "units/upd_015/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		can_airburst = true,
		damage = 850,
		player_damage = 24,
		range = 1000
	}
	self.mills.enemy_proximity_range = self.mills.range * 0.6
	self.mills.killzone_range = 0.75
	self.mills.init_timer = 4.5
	self.mills.animations = {
		equip_id = "equip_welrod"
	}
	self.mills.sound_event = "mills_grenade_explode"
	self.mills.launch_speed = 200
	self.mills.gui = {
		rotation_offset = 0,
		distance_offset = -120,
		height_offset = -8,
		display_offset = 16,
		initial_rotation = {}
	}
	self.mills.gui.initial_rotation.yaw = -90
	self.mills.gui.initial_rotation.pitch = 60
	self.mills.gui.initial_rotation.roll = 0
	self.betty = {
		name_id = "bm_grenade_betty",
		unit = "units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty",
		unit_hand = "units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty_hand",
		unit_dummy = "units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty_husk",
		icon = "frag_grenade",
		throwable = true,
		instant_throw = true,
		max_amount = 2,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.13333333333333333,
		expire_t = 0.5,
		repeat_expire_t = 1,
		is_a_grenade = true,
		damage = 950,
		player_damage = 35,
		range = 500,
		killzone_range = 0.75,
		init_timer = 3,
		animations = {}
	}
	self.betty.animations.equip_id = "equip_welrod"
	self.betty.sound_event = "mills_grenade_explode"
	self.betty.launch_speed = 150
	self.betty.enemy_proximity_range = 200
	self.betty.enemy_proximity_delay = 0.4
	self.betty.jumpmine_velocity = 540
	self.betty.gui = {
		rotation_offset = 0,
		distance_offset = -120,
		height_offset = -8,
		display_offset = 16,
		initial_rotation = {}
	}
	self.betty.gui.initial_rotation.yaw = -90
	self.betty.gui.initial_rotation.pitch = 60
	self.betty.gui.initial_rotation.roll = 0
	self.cluster = {
		name_id = "bm_grenade_frag",
		unit = "units/vanilla/dev/dev_shrapnel/dev_shrapnel",
		unit_dummy = "units/vanilla/dev/dev_shrapnel/dev_shrapnel_husk",
		throwable = false,
		impact_detonation = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		killzone_range = 0.15,
		is_a_grenade = true,
		damage = 250,
		launch_speed = 20,
		adjust_z = 5,
		player_damage = 3,
		range = 350,
		animations = {}
	}
	self.cluster.animations.equip_id = "equip_welrod"
	self.ammo_bag = {
		name_id = "bm_grenade_frag",
		unit = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24",
		unit_hand = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_hand",
		unit_dummy = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = false,
		damage = 0,
		player_damage = 0,
		range = 1000,
		init_timer = 4.5,
		animations = {}
	}
	self.ammo_bag.animations.equip_id = "equip_welrod"
	self.ammo_bag.push_at_body_index = 0
	self.molotov = {
		name_id = "bm_grenade_molotov",
		icon = "molotov_grenade",
		no_cheat_count = true,
		impact_detonation = true,
		time_cheat = 1,
		throwable = false,
		max_amount = 3,
		texture_bundle_folder = "bbq",
		physic_effect = Idstring("physic_effects/molotov_throw"),
		anim_global_param = "projectile_molotov",
		throw_allowed_expire_t = 0.1,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		init_timer = 10,
		damage = 30,
		player_damage = 5,
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_damage = 10,
			dot_length = 3,
			dot_trigger_max_distance = 3000,
			dot_tick_period = 0.5
		},
		range = 75,
		killzone_range = 0,
		burn_duration = 20,
		burn_tick_period = 0.5,
		sound_event_impact_duration = 4,
		alert_radius = 1500,
		fire_alert_radius = 1500,
		animations = {}
	}
	self.molotov.animations.equip_id = "equip_welrod"
	self.decoy_coin = {
		name_id = "bm_coin",
		unit = "units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace",
		unit_hand = "units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace_husk",
		unit_dummy = "units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace_husk",
		icon = "frag_grenade",
		max_amount = 9
	}
	self.decoy_coin.per_pickup = math.ceil(self.decoy_coin.max_amount / 3)
	self.decoy_coin.throwable = true
	self.decoy_coin.instant_throw = true
	self.decoy_coin.anim_global_param = "projectile_molotov"
	self.decoy_coin.throw_allowed_expire_t = 0.13333333333333333
	self.decoy_coin.expire_t = 0.5
	self.decoy_coin.repeat_expire_t = 1
	self.decoy_coin.is_a_grenade = true
	self.decoy_coin.range = 3000
	self.decoy_coin.animations = {
		equip_id = "equip_welrod"
	}
	self.decoy_coin.launch_speed = 200
	self.decoy_coin.gui = {
		rotation_offset = 0,
		distance_offset = -160,
		height_offset = -12,
		display_offset = 16,
		initial_rotation = {}
	}
	self.decoy_coin.gui.initial_rotation.yaw = 180
	self.decoy_coin.gui.initial_rotation.pitch = 10
	self.decoy_coin.gui.initial_rotation.roll = 0
	self.mortar_shell = {
		name_id = "bm_mortar_shell",
		unit = "units/vanilla/weapons/wpn_npc_proj_mortar_shell/wpn_npc_proj_mortar_shell",
		unit_dummy = "units/vanilla/weapons/wpn_npc_proj_mortar_shell/wpn_npc_proj_mortar_shell_husk",
		weapon_id = "mortar_shell",
		no_cheat_count = false,
		impact_detonation = true,
		physic_effect = Idstring("physic_effects/anti_gravitate"),
		adjust_z = 0,
		push_at_body_index = 0,
		init_timer = 5,
		damage = 80,
		player_damage = 15,
		range = 1200,
		killzone_range = 0,
		init_timer = 15,
		effect_name = "effects/vanilla/explosions/exp_artillery_explosion_001",
		sound_event = "grenade_launcher_explosion",
		sound_event_impact_duration = 4
	}
	self.flamer_death_fake = clone(self.molotov)
	self.flamer_death_fake.init_timer = 0.01
	self.flamer_death_fake.adjust_z = 0
	self.flamer_death_fake.throwable = false
	self.flamer_death_fake.unit = "units/vanilla/dev/flamer_death_fake/flamer_death_fake"
	self.flamer_death_fake.unit_dummy = "units/vanilla/dev/flamer_death_fake/flamer_death_fake_husk"
	self._projectiles_index = {
		"m24",
		"cluster",
		"molotov",
		"mortar_shell",
		"flamer_death_fake",
		"concrete",
		"d343",
		"mills",
		"decoy_coin",
		"betty"
	}

	self:_add_desc_from_name_macro(self)
end

function BlackMarketTweakData:get_projectiles_index()
	return tweak_data.projectiles._projectiles_index
end

function BlackMarketTweakData:get_index_from_projectile_id(projectile_id)
	for index, entry_name in ipairs(tweak_data.projectiles._projectiles_index) do
		if entry_name == projectile_id then
			return index
		end
	end

	return 0
end

function BlackMarketTweakData:get_projectile_name_from_index(index)
	return tweak_data.projectiles._projectiles_index[index]
end

function ProjectilesTweakData:_add_desc_from_name_macro(tweak_data)
	for id, data in pairs(tweak_data) do
		if data.name_id and not data.desc_id then
			data.desc_id = tostring(data.name_id) .. "_desc"
		end

		if not data.name_id then
			-- Nothing
		end
	end
end
