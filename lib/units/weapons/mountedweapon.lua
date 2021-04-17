MountedWeapon = MountedWeapon or class()
MountedWeapon.SEQUENCE_FIRE = "fire"

-- Lines 5-29
function MountedWeapon:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("mounted_weapon"), true)

	self._turret_sync_dt = 0

	self:set_tweak_data(tweak_data.mounted_weapon[self.tweak_data])
	self:set_cannon_sound_source()
	self:set_turret_target_rot(self._unit:rotation(), 0)

	self._turret_rot_forced = false
	self._main_cannon_cooldown = self._tweak_data.main_cannon_reload_speed
	self._main_cannon_cooldown_counter = self._main_cannon_cooldown + 1
	self._main_cannon_locator = self._unit:get_object(Idstring(self._unit:vehicle_driving()._tweak_data.seats.gunner.fire_point))
end

-- Lines 31-44
function MountedWeapon:set_cannon_sound_source()
	self._main_cannon_soundsource = nil
	local snd_main_cannon = nil

	if self._unit:vehicle_driving() and self._unit:vehicle_driving()._tweak_data.seats.gunner then
		snd_main_cannon = self._unit:get_object(Idstring(self._unit:vehicle_driving()._tweak_data.seats.gunner.fire_point))

		if snd_main_cannon then
			self._main_cannon_soundsource = SoundDevice:create_source("mounted_weapon")

			self._main_cannon_soundsource:link(snd_main_cannon)
		end
	end
end

-- Lines 46-56
function MountedWeapon:set_tweak_data(data)
	self._tweak_data = data

	if self._tweak_data.turret then
		self._turret = deep_clone(self._tweak_data.turret)
		self._turret.object = self._unit:get_object(Idstring(self._turret.locator))
		self._turret.gun_object = self._unit:get_object(Idstring(self._turret.gun_locator))
	else
		self._turret = {}
	end
end

-- Lines 58-62
function MountedWeapon:update(unit, t, dt)
	self:update_turret(t, dt)
end

-- Lines 64-90
function MountedWeapon:main_cannon_fire()
	if self._main_cannon_cooldown < self._main_cannon_cooldown_counter then
		self._main_cannon_locator = self._unit:get_object(Idstring(self._unit:vehicle_driving()._tweak_data.seats.gunner.fire_point))
		local direction = self._main_cannon_locator:rotation():y()
		self._tank_shell = {
			position = self._main_cannon_locator:position(),
			direction = direction
		}

		World:effect_manager():spawn({
			effect = Idstring(self._tweak_data.effect.main_cannon_fire),
			position = self._main_cannon_locator:position(),
			normal = direction
		})

		if self._main_cannon_soundsource then
			self._main_cannon_soundsource:post_event(self._tweak_data.sound.main_cannon_fire)
		end

		if self._unit:damage() and self._unit:damage():has_sequence(MountedWeapon.SEQUENCE_FIRE) then
			self._unit:damage():run_sequence_simple(MountedWeapon.SEQUENCE_FIRE)
		end

		self._main_cannon_cooldown_counter = 0
	end
end

-- Lines 96-109
function MountedWeapon:set_turret_target_rot(rot, dt)
	self._turret.target_rot_yaw = rot:yaw()
	self._turret.target_rot_pitch = rot:pitch()
	self._turret.target_rot = rot
	self._turret_rot_forced = true

	if dt then
		if self._turret_sync_dt > 1 then
			managers.network:session():send_to_peers_synched("sync_vehicle_turret_rot", self._unit, rot)

			self._turret_sync_dt = 0
		else
			self._turret_sync_dt = self._turret_sync_dt + dt
		end
	end
end

-- Lines 111-214
function MountedWeapon:update_turret(t, dt)
	if not self._turret or not self._turret.object then
		return
	end

	if not self._turret_rot_forced then
		local rot = self._unit:rotation()
		self._turret.target_rot_yaw = rot:yaw()
		self._turret.target_rot_pitch = rot:pitch()
	end

	local turret_rot = self._turret.object:rotation()
	local diff_yaw = self._turret.target_rot_yaw - turret_rot:yaw()

	if diff_yaw > 180 then
		diff_yaw = diff_yaw - 360
	elseif diff_yaw < -180 then
		diff_yaw = diff_yaw + 360
	end

	local delta_yaw = 10 * dt
	local turret_local_rot = self._turret.object:local_rotation()
	local yaw = turret_local_rot:yaw()

	if diff_yaw > 3 then
		yaw = turret_local_rot:yaw() + delta_yaw
	elseif diff_yaw < -3 then
		yaw = turret_local_rot:yaw() - delta_yaw
	end

	local gun_rot = self._turret.gun_object:rotation()
	local gun_local_rot = self._turret.gun_object:local_rotation()
	local diff_pitch = self._turret.target_rot_pitch - gun_rot:pitch()
	local delta_pitch = 10 * dt
	local pitch = gun_local_rot:pitch()

	if diff_pitch > 3 then
		pitch = gun_local_rot:pitch() + delta_pitch
	elseif diff_pitch < -3 then
		pitch = gun_local_rot:pitch() - delta_pitch
	end

	self._turret.object:set_local_rotation(Rotation(yaw, turret_local_rot:pitch(), turret_local_rot:roll()))
	self._turret.gun_object:set_local_rotation(Rotation(gun_local_rot:yaw(), pitch, gun_local_rot:roll()))

	if self._tank_shell and self._turret.range < mvector3.distance(self._tank_shell.position, self._main_cannon_locator:position()) then
		self._tank_shell = nil
	end

	if self._tank_shell then
		VehicleDrivingExt.cumulative_dt = VehicleDrivingExt.cumulative_dt + dt
		VehicleDrivingExt.cumulative_gravity = VehicleDrivingExt.cumulative_gravity + 9.81 * dt
		local new_position = self._tank_shell.position + self._tank_shell.direction * self._tweak_data.main_cannon_shell_speed * dt + Vector3(0, 0, -VehicleDrivingExt.cumulative_gravity)
		local raycast = World:raycast("ray", self._tank_shell.position, new_position)

		Application:trace("raycast: ", self._tank_shell.position, new_position, inspect(raycast))

		if raycast then
			World:effect_manager():spawn({
				effect = Idstring(self._tweak_data.effect.main_cannon_fire_hit),
				position = raycast.hit_position,
				normal = raycast.normal
			})

			self._tank_shell = nil
			VehicleDrivingExt.cumulative_dt = 0
			VehicleDrivingExt.cumulative_gravity = 0

			self:_tank_main_cannon_hit_explosion(raycast, raycast.hit_position + Vector3(0, 0, 2))
		else
			self._tank_shell.position = new_position
		end
	end

	self._main_cannon_cooldown_counter = self._main_cannon_cooldown_counter + dt
end

-- Lines 216-264
function MountedWeapon:_update_tank_input(dt)
	local move_d = self._controller:get_input_axis("drive")
	local forced_gear = -1
	local vehicle_state = self._vehicle:get_state()

	if vehicle_state:get_speed() < 0.5 and move_d.y < 0 and vehicle_state:get_gear() ~= 0 then
		forced_gear = 0
	end

	if vehicle_state:get_speed() < 0.5 and move_d.y > 0 and vehicle_state:get_gear() ~= 2 then
		forced_gear = 2
	end

	local direction = 1

	if vehicle_state:get_gear() == 0 and move_d.y ~= 0 then
		direction = -1
	end

	if self._seat.driving then
		local accelerate = 0
		local brake = 0

		if direction > 0 then
			if move_d.y > 0 then
				accelerate = move_d.y
			else
				brake = -move_d.y
			end
		elseif move_d.y > 0 then
			brake = move_d.y
		else
			accelerate = -move_d.y
		end

		local steer = move_d.x
		local handbrake = 0

		self._vehicle_ext:set_input(accelerate, steer, brake, handbrake, false, false, forced_gear, dt, move_d.y)
	end

	local pressed = self._controller:get_any_input()
	local btn_weapon_gadget_press = pressed and self._controller:get_input_pressed("weapon_gadget")

	if btn_weapon_gadget_press then
		Application:trace("[PlayerDriving:_update_tank_input] current seat: ", inspect(self._seat.name))
		self:_move_to_next_seat()
	end
end

-- Lines 266-297
function MountedWeapon:_tank_main_cannon_hit_explosion(raycast, hit_position)
	local pos = hit_position
	local normal = raycast.normal
	local damage_radius = self._tweak_data.turret.damage_radius or 1000
	local slot_mask = managers.slot:get_mask("explosion_targets")
	local damage = self._tweak_data.turret.damage or 1000
	local player_damage = self._tweak_data.turret.player_damage or 10
	local armor_piercing = self._tweak_data.turret.armor_piercing
	local curve_pow = 3

	managers.explosion:give_local_player_dmg(pos, damage_radius, player_damage)

	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		alert_radius = 10000,
		hit_pos = pos,
		range = damage_radius,
		collision_slotmask = slot_mask,
		curve_pow = curve_pow,
		damage = damage,
		player_damage = player_damage,
		ignore_unit = managers.player:local_player(),
		user = managers.player:local_player(),
		armor_piercing = armor_piercing
	})

	managers.network:session():send_to_peers_synched("sync_tank_cannon_explosion", self._unit, pos, damage_radius, damage, player_damage, curve_pow)
end

-- Lines 299-309
function MountedWeapon:_tank_main_cannon_hit_explosion_on_client(position, radius, damage, player_damage, curve_pow)
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
