ProjectilesTweakData = ProjectilesTweakData or class()

function ProjectilesTweakData:init(tweak_data)
	self.GRENADE_QUANTITY_UPGARDE = {
		{
			upgrade = "grenadier_grenade_quantity",
			category = "player"
		},
		{
			upgrade = "pack_mule_equipment_quantity",
			category = "player"
		}
	}
	self.MINE_QUANTITY_UPGARDE = {
		{
			upgrade = "sapper_mine_quantity",
			category = "player"
		},
		{
			upgrade = "pack_mule_equipment_quantity",
			category = "player"
		}
	}
	self._projectiles_index = {}

	self:_init_m24(tweak_data)
	self:_init_cluster(tweak_data)
	self:_init_molotov(tweak_data)
	self:_init_mortar_shell(tweak_data)
	self:_init_flamer_death_fake(tweak_data)
	self:_init_concrete(tweak_data)
	self:_init_d343(tweak_data)
	self:_init_mills(tweak_data)
	self:_init_decoy_coin(tweak_data)
	self:_init_betty(tweak_data)
	self:_init_gold_bar(tweak_data)
	self:_init_anti_tank(tweak_data)
	self:_add_desc_from_name_macro(self)
end

function ProjectilesTweakData:_init_m24(tweak_data)
	self.m24 = {
		name_id = "bm_grenade_frag",
		weapon_id = "m24_grenade",
		unit = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24",
		unit_hand = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_hand",
		unit_dummy = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_husk",
		icon = "frag_grenade",
		anim_global_param = "projectile_frag",
		throwable = true,
		max_amount = 3,
		pickup_filter = "grenades",
		upgrade_amounts = self.GRENADE_QUANTITY_UPGARDE,
		throw_allowed_expire_t = 0.662,
		expire_t = 0.455,
		repeat_expire_t = 1,
		is_a_grenade = true,
		damage = 600,
		player_damage = 20,
		range = 850,
		can_airburst = true
	}
	self.m24.enemy_proximity_range = self.m24.range * 0.6
	self.m24.killzone_range = 0.33
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

	table.insert(self._projectiles_index, "m24")
end

function ProjectilesTweakData:_init_concrete(tweak_data)
	self.concrete = {
		name_id = "bm_grenade_concrete",
		unit = "units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete",
		unit_hand = "units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete_hand",
		unit_dummy = "units/upd_001/weapons/wpn_fps_gre_concrete/wpn_fps_gre_concrete_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		pickup_filter = "grenades",
		upgrade_amounts = self.GRENADE_QUANTITY_UPGARDE,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.662,
		expire_t = 0.455,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		damage = 800,
		player_damage = 20,
		range = 900,
		can_airburst = true
	}
	self.concrete.enemy_proximity_range = self.concrete.range * 0.6
	self.concrete.killzone_range = 0.33
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

	table.insert(self._projectiles_index, "concrete")
end

function ProjectilesTweakData:_init_d343(tweak_data)
	self.d343 = {
		name_id = "bm_grenade_d343",
		unit = "units/upd_003/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343",
		unit_hand = "units/upd_003/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343_hand",
		unit_dummy = "units/upd_003/weapons/wpn_fps_gre_d343/wpn_fps_gre_d343_husk",
		icon = "frag_grenade",
		throwable = true,
		pickup_filter = "grenades",
		max_amount = 4,
		upgrade_amounts = self.GRENADE_QUANTITY_UPGARDE,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.662,
		expire_t = 0.455,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		can_airburst = true,
		damage = 850,
		player_damage = 20,
		range = 900
	}
	self.d343.enemy_proximity_range = self.d343.range * 0.6
	self.d343.killzone_range = 0.33
	self.d343.init_timer = 4.5
	self.d343.animations = {
		equip_id = "equip_welrod"
	}
	self.d343.sound_event = "d43d_grenade_explode"
	self.d343.launch_speed = 210
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

	table.insert(self._projectiles_index, "d343")
end

function ProjectilesTweakData:_init_mills(tweak_data)
	self.mills = {
		name_id = "bm_grenade_mills",
		unit = "units/upd_015/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills",
		unit_hand = "units/upd_015/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills_hand",
		unit_dummy = "units/upd_015/weapons/wpn_fps_gre_mills/wpn_fps_gre_mills_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		pickup_filter = "grenades",
		upgrade_amounts = self.GRENADE_QUANTITY_UPGARDE,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0.662,
		expire_t = 0.455,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		can_airburst = true,
		damage = 900,
		player_damage = 20,
		range = 700
	}
	self.mills.enemy_proximity_range = self.mills.range * 0.6
	self.mills.killzone_range = 0.33
	self.mills.init_timer = 4.5
	self.mills.animations = {
		equip_id = "equip_welrod"
	}
	self.mills.sound_event = "mills_grenade_explode"
	self.mills.launch_speed = 210
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

	table.insert(self._projectiles_index, "mills")
end

function ProjectilesTweakData:_init_betty(tweak_data)
	self.betty = {
		name_id = "bm_grenade_betty",
		unit = "units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty",
		unit_hand = "units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty_hand",
		unit_dummy = "units/upd_021/weapons/wpn_fps_gre_betty/wpn_fps_gre_betty_husk",
		icon = "frag_grenade",
		throwable = true,
		instant_throw = true,
		max_amount = 2,
		pickup_filter = "grenades",
		upgrade_amounts = self.MINE_QUANTITY_UPGARDE,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0,
		expire_t = 0.46,
		repeat_expire_t = 1,
		is_a_grenade = true,
		damage = 750,
		player_damage = 35,
		range = 550,
		killzone_range = 0.5,
		init_timer = 3,
		animations = {}
	}
	self.betty.animations.equip_id = "equip_welrod"
	self.betty.sound_event = "mills_grenade_explode"
	self.betty.launch_speed = 150
	self.betty.enemy_proximity_range = 200
	self.betty.enemy_proximity_delay = 0.44
	self.betty.jumpmine_velocity = 350
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

	table.insert(self._projectiles_index, "betty")
end

function ProjectilesTweakData:_init_cluster(tweak_data)
	self.cluster = {
		name_id = "bm_grenade_frag",
		unit = "units/vanilla/dev/dev_shrapnel/dev_shrapnel",
		unit_dummy = "units/vanilla/dev/dev_shrapnel/dev_shrapnel_husk",
		throwable = false,
		impact_detonation = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		killzone_range = 0.33,
		is_a_grenade = true,
		damage = 250,
		player_damage = 3,
		range = 250,
		launch_speed = 2,
		adjust_z_range = {
			1,
			1.8
		},
		animations = {}
	}
	self.cluster.animations.equip_id = "equip_welrod"

	table.insert(self._projectiles_index, "cluster")
end

function ProjectilesTweakData:_init_ammo_bag(tweak_data)
	self.ammo_bag = {
		name_id = "bm_grenade_frag",
		unit = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24",
		unit_hand = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_hand",
		unit_dummy = "units/vanilla/weapons/wpn_gre_m24/wpn_gre_m24_husk",
		icon = "frag_grenade",
		throwable = true,
		max_amount = 3,
		anim_global_param = "projectile_frag",
		throw_allowed_expire_t = 0,
		expire_t = 1.1,
		repeat_expire_t = 1.5,
		is_a_grenade = false,
		damage = 0,
		player_damage = 0,
		range = 1000,
		init_timer = 4.5,
		push_at_body_index = 0,
		animations = {}
	}
	self.ammo_bag.animations.equip_id = "equip_welrod"

	table.insert(self._projectiles_index, "ammo_bag")
end

function ProjectilesTweakData:_init_molotov(tweak_data)
	self.molotov = {
		name_id = "bm_grenade_molotov",
		icon = "molotov_grenade",
		no_cheat_count = true,
		impact_detonation = true,
		time_cheat = 1,
		throwable = false,
		max_amount = 3,
		upgrade_amounts = self.GRENADE_QUANTITY_UPGARDE,
		texture_bundle_folder = "bbq",
		physic_effect = tweak_data.physics_effects.molotov_throw,
		anim_global_param = "projectile_molotov",
		throw_allowed_expire_t = 0.662,
		expire_t = 0.46,
		repeat_expire_t = 1.5,
		is_a_grenade = true,
		init_timer = 10,
		damage = 15,
		player_damage = 5,
		fire_dot_data = {
			dot_trigger_chance = 35,
			dot_trigger_max_distance = 3000,
			dot_damage = 10,
			dot_tick_period = 0.5,
			dot_length = 2.01
		},
		range = 75,
		killzone_range = 0,
		burn_duration = 20,
		burn_tick_period = 0.665,
		sound_event_impact_duration = 4,
		alert_radius = 1500,
		fire_alert_radius = 1500,
		animations = {}
	}
	self.molotov.animations.equip_id = "equip_welrod"

	table.insert(self._projectiles_index, "molotov")
end

function ProjectilesTweakData:_init_decoy_coin(tweak_data)
	self.decoy_coin = {
		name_id = "bm_coin",
		unit = "units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace",
		unit_hand = "units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace_hand",
		unit_dummy = "units/vanilla/weapons/wpn_fps_decoy_coin_peace/wpn_decoy_coin_peace_husk",
		icon = "frag_grenade",
		max_amount = 5,
		upgrade_amount = {
			upgrade = "pack_mule_equipment_quantity",
			category = "player"
		},
		pickup_filter = "coins",
		is_a_grenade = true,
		throwable = true,
		instant_throw = true,
		impact_detonation = true,
		remove_on_impact = false,
		attach_on_collision = false,
		anim_global_param = "projectile_molotov",
		throw_allowed_expire_t = 0,
		expire_t = 0.46,
		repeat_expire_t = 1,
		range = 1000,
		launch_speed = 200,
		damage = 15,
		headshot_multiplier = 3,
		animations = {}
	}
	self.decoy_coin.animations.equip_id = "equip_welrod"
	self.decoy_coin.gui = {
		rotation_offset = 0,
		distance_offset = -160,
		height_offset = -14,
		display_offset = 22,
		initial_rotation = {}
	}
	self.decoy_coin.gui.initial_rotation.yaw = 150
	self.decoy_coin.gui.initial_rotation.pitch = 8
	self.decoy_coin.gui.initial_rotation.roll = 0

	table.insert(self._projectiles_index, "decoy_coin")
end

function ProjectilesTweakData:_init_anti_tank(tweak_data)
	table.insert(self._projectiles_index, "anti_tank")

	self.anti_tank = {
		name_id = "bm_grenade_anti_tank",
		weapon_id = "anti_tank_grenade",
		unit = "units/upd_blaze/weapons/gre_anti_tank/wpn_prj_gre_anti_tank",
		unit_hand = "units/upd_blaze/weapons/gre_anti_tank/wpn_fps_gre_anti_tank",
		unit_dummy = "units/upd_blaze/weapons/gre_anti_tank/wpn_tps_gre_anti_tank",
		icon = "frag_grenade",
		anim_global_param = "projectile_frag",
		throwable = true,
		max_amount = 2,
		pickup_filter = "nopickup",
		upgrade_amounts = table.list_union(self.GRENADE_QUANTITY_UPGARDE, {
			{
				upgrade = "warcry_grenade_refill_amounts",
				category = "player"
			}
		}),
		throw_allowed_expire_t = 0.662,
		expire_t = 0.455,
		repeat_expire_t = 1,
		is_a_grenade = true,
		damage = 600,
		player_damage = 20,
		launch_speed = 300,
		range = 850,
		can_airburst = true
	}
	self.anti_tank.enemy_proximity_range = self.anti_tank.range * 0.6
	self.anti_tank.killzone_range = 0.66
	self.anti_tank.init_timer = 3
	self.anti_tank.animations = {
		equip_id = "equip_welrod"
	}
	self.anti_tank.sound_event = "grenade_explode"
	self.anti_tank.gui = {
		height_offset = -14,
		distance_offset = -80,
		rotation_offset = 3,
		initial_rotation = nil,
		display_offset = 10,
		initial_rotation = {
			pitch = 60,
			yaw = -90,
			roll = 0
		}
	}
end

function ProjectilesTweakData:_init_mortar_shell(tweak_data)
	self.mortar_shell = {
		name_id = "bm_mortar_shell",
		unit = "units/vanilla/weapons/wpn_npc_proj_mortar_shell/wpn_npc_proj_mortar_shell",
		unit_dummy = "units/vanilla/weapons/wpn_npc_proj_mortar_shell/wpn_npc_proj_mortar_shell_husk",
		weapon_id = "mortar_shell",
		no_cheat_count = false,
		impact_detonation = true,
		physic_effect = tweak_data.physics_effects.no_gravity,
		adjust_z = 0,
		push_at_body_index = 0,
		init_timer = 5,
		damage = 75,
		player_damage = 25,
		range = 2400,
		killzone_range = 0.33,
		init_timer = 15,
		effect_name = "effects/vanilla/explosions/exp_artillery_explosion_001",
		sound_event = "grenade_launcher_explosion",
		sound_event_impact_duration = 4
	}

	table.insert(self._projectiles_index, "mortar_shell")
end

function ProjectilesTweakData:_init_flamer_death_fake(tweak_data)
	self.flamer_death_fake = clone(self.molotov)
	self.flamer_death_fake.init_timer = 0.01
	self.flamer_death_fake.adjust_z = 0
	self.flamer_death_fake.throwable = false
	self.flamer_death_fake.unit = "units/vanilla/dev/flamer_death_fake/flamer_death_fake"
	self.flamer_death_fake.unit_dummy = "units/vanilla/dev/flamer_death_fake/flamer_death_fake_husk"
	self.flamer_death_fake.burn_duration = 10
	self.flamer_death_fake.sound_event_impact_duration = 1

	table.insert(self._projectiles_index, "flamer_death_fake")
end

function ProjectilesTweakData:_init_gold_bar(tweak_data)
	self.gold_bar = {
		name_id = "bm_lead_bar",
		unit = "units/upd_candy/weapons/wpn_gre_gold_bar/default/wpn_gre_lead_bar",
		unit_local = "units/upd_candy/weapons/wpn_gre_gold_bar/default/wpn_gre_lead_bar_local",
		unit_hand = "units/upd_candy/weapons/wpn_gre_gold_bar/default/wpn_gre_lead_bar_hand",
		unit_dummy = "units/upd_candy/weapons/wpn_gre_gold_bar/default/wpn_gre_lead_bar_husk",
		icon = "frag_grenade",
		max_amount = 5,
		upgrade_amounts = {
			{
				upgrade = "pack_mule_equipment_quantity",
				category = "player"
			},
			{
				upgrade = "midas_gold_bar_quantity",
				category = "player"
			}
		},
		pickup_filter = "gold_bar",
		weapon_id = "gold_bar",
		is_a_grenade = true,
		throwable = true,
		client_authoritative = true,
		impact_detonation = true,
		instant_throw = true,
		remove_on_impact = false,
		attach_on_collision = false,
		anim_global_param = "projectile_molotov",
		throw_allowed_expire_t = 0,
		expire_t = 0.46,
		repeat_expire_t = 1,
		launch_speed = 560,
		adjust_z = 40,
		damage = 150,
		headshot_multiplier = 3,
		range = 500,
		animations = {}
	}
	self.gold_bar.animations.equip_id = "equip_welrod"
	self.gold_bar.gui = {
		height_offset = -14,
		distance_offset = -140,
		rotation_offset = 3,
		initial_rotation = nil,
		display_offset = 22,
		initial_rotation = {
			pitch = 80,
			yaw = 52,
			roll = 0
		}
	}

	table.insert(self._projectiles_index, "gold_bar")
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
