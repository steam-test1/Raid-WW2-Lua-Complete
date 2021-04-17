TankTurretWeapon = TankTurretWeapon or class(SentryGunWeapon)

-- Lines 4-13
function TankTurretWeapon:init(unit)
	TankTurretWeapon.super.init(self, unit)

	self._laser_align_name = nil
	self._laser_align = nil
	self._fire_obj = self._unit:get_object(Idstring("fire"))
	self._test_delete_after = {}
end

-- Lines 17-20
function TankTurretWeapon:setup(setup_data, damage_multiplier)
	TankTurretWeapon.super.setup(self, setup_data, damage_multiplier)

	self._custom_params = {
		effect = self._tweak_data.effect.main_cannon_fire_hit,
		sound_event = self._tweak_data.sound.main_cannon_fire_hit,
		idstr_decal = self._tweak_data.effect.explosion_decal,
		idstr_effect = self._tweak_data.effect.explosion_lingering_effect
	}
end

-- Lines 24-30
function TankTurretWeapon:play_lock_on_sound()
	local sound_source = self._unit:sound_source()
	local weapon_tweak_data = self._tweak_data

	if sound_source and weapon_tweak_data.sound.main_cannon_lock_on then
		sound_source:post_event(weapon_tweak_data.sound.main_cannon_lock_on)
	end
end

-- Lines 34-36
function TankTurretWeapon:start_autofire()
	debug_pause("[TankTurretWeapon:start_autofire] start_autofire() not supported by the tank turret, unit: ", inspect(self._unit))
end

-- Lines 40-42
function TankTurretWeapon:stop_autofire()
	debug_pause("[TankTurretWeapon:start_autofire] stop_autofire() not supported by the tank turret, unit: ", inspect(self._unit))
end

-- Lines 46-48
function TankTurretWeapon:trigger_held(blanks, expend_ammo, shoot_player, target_unit)
	debug_pause("[TankTurretWeapon:start_autofire] autofire() not supported by the tank turret, unit: ", inspect(self._unit))
end

-- Lines 52-80
function TankTurretWeapon:singleshot(blanks, expend_ammo, shoot_player, target_pos)
	if not Network:is_server() then
		return
	end

	if expend_ammo then
		if self._ammo_total <= 0 then
			return
		end

		self:change_ammo(-1)
	end

	local weapon_tweak_data = self._tweak_data
	self._fire_locator = self._fire_locator or self._effect_align[self._interleaving_fire]
	local from_pos = self._fire_obj:position()
	local direction = (target_pos - from_pos):normalized()

	mvector3.spread(direction, weapon_tweak_data.SPREAD * self._spread_mul)

	self._tank_shell = {
		vel_gravity = 0,
		position = from_pos,
		direction = direction
	}

	self._unit:set_extension_update_enabled(Idstring("weapon"), true)
	self:play_singleshot_sound_and_effect(from_pos, direction)
	managers.network:session():send_to_peers_synched("sync_ai_tank_singleshot_blank", self._unit, from_pos, direction)
end

-- Lines 83-103
function TankTurretWeapon:play_singleshot_sound_and_effect(position, normal)
	local weapon_tweak_data = self._tweak_data
	local effect_range = weapon_tweak_data.sound.main_cannon_fire_tinnitus_range

	World:effect_manager():spawn({
		effect = Idstring(weapon_tweak_data.effect.main_cannon_fire),
		position = position,
		normal = normal
	})

	local sound_source = self._unit:sound_source()

	if sound_source then
		sound_source:post_event(weapon_tweak_data.sound.main_cannon_fire)
	end

	local custom_params = {
		sound_muffle_effect = true,
		camera_shake_max_mul = 4,
		feedback_range = effect_range
	}

	managers.explosion:player_feedback(position, normal, effect_range, custom_params)

	local fire_anim_sequence = weapon_tweak_data.fire_anim_sequence

	if fire_anim_sequence and self._unit:damage() and self._unit:damage():has_sequence(fire_anim_sequence) then
		self._unit:damage():run_sequence_simple(fire_anim_sequence)
	end
end

-- Lines 107-152
function TankTurretWeapon:update(unit, t, dt)
	if self._test_delete_after then
		for _, object in ipairs(self._test_delete_after) do
			if t > object.time + 7 then
				DebugDraw:destroy_primitive(object.id)
				table.remove(self._test_delete_after, _)
			end
		end
	end

	if not self._tank_shell then
		return
	end

	local new_position = self._tank_shell.position + self._tank_shell.direction * self._tweak_data.main_cannon_shell_speed * dt
	self._tank_shell.direction = (new_position - self._tank_shell.position):normalized()
	local raycast = World:raycast("ray", self._tank_shell.position, new_position)

	if raycast then
		World:effect_manager():spawn({
			effect = Idstring(self._tweak_data.effect.main_cannon_fire_hit),
			position = raycast.hit_position,
			normal = raycast.normal
		})

		self._tank_shell = nil
		VehicleDrivingExt.cumulative_dt = 0
		VehicleDrivingExt.cumulative_gravity = 0

		self:_hit_explosion(raycast, raycast.hit_position + Vector3(0, 0, 2))

		if TankTurretWeapon.show_trajectory then
			local sphere_id = DebugDraw:sphere(Color.green, raycast.hit_position + Vector3(0, 0, 2), 30, 2)

			table.insert(self._test_delete_after, {
				time = t,
				id = sphere_id
			})
		end

		self._unit:set_extension_update_enabled(Idstring("weapon"), false)
	else
		self._tank_shell.position = new_position

		if TankTurretWeapon.show_trajectory then
			local sphere_id = DebugDraw:sphere(Color.red, new_position, 10, 2)

			table.insert(self._test_delete_after, {
				time = t,
				id = sphere_id
			})
		end
	end
end

-- Lines 156-188
function TankTurretWeapon:_hit_explosion(raycast, hit_position)
	if not Network:is_server() then
		return
	end

	local pos = hit_position
	local normal = raycast.normal
	local damage_radius = self._tweak_data.turret.damage_radius or 1000
	local slot_mask = managers.slot:get_mask("explosion_targets")
	local damage = self._tweak_data.turret.damage or 1000
	local player_damage = self._tweak_data.turret.player_damage or 10
	local armor_piercing = self._tweak_data.turret.armor_piercing
	local curve_pow = 3
	local alert_radius = self._tweak_data.alert_size

	managers.explosion:give_local_player_dmg(pos, damage_radius, player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, damage_radius, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		hit_pos = pos,
		range = damage_radius,
		collision_slotmask = slot_mask,
		curve_pow = curve_pow,
		damage = damage,
		player_damage = player_damage,
		ignore_unit = self._unit,
		alert_radius = alert_radius,
		user = managers.player:local_player(),
		armor_piercing = armor_piercing
	})

	managers.network:session():send_to_peers_synched("sync_ai_tank_grenade_explosion", self._unit, pos, damage_radius, damage, player_damage, curve_pow)
end

-- Lines 192-200
function TankTurretWeapon:_hit_explosion_on_client(position, radius, damage, player_damage, curve_pow)
	local sound_event = "grenade_explode"
	local damage_radius = radius or self._tweak_data.turret.damage_radius or 1000
	local custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = damage_radius * 2
	}

	managers.explosion:give_local_player_dmg(position, damage_radius, player_damage)
	managers.explosion:explode_on_client(position, math.UP, nil, damage, damage_radius, curve_pow, custom_params)
end

-- Lines 204-206
function TankTurretWeapon:adjust_target_pos(target_pos)
	return target_pos - Vector3(0, 0, 150)
end
