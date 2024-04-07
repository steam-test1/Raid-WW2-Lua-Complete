local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local mvec3_cross = mvector3.cross
local math_clamp = math.clamp
local math_lerp = math.lerp
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()

DP28RaycastWeaponBase = DP28RaycastWeaponBase or class(NewRaycastWeaponBase)

function DP28RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local start_ammo = self:get_ammo_remaining_in_clip()
	local weapon_tweak = self:weapon_tweak_data()
	local apply_gun_kick = weapon_tweak and weapon_tweak.gun_kick
	local mvec_direction = tmp_vec1
	local mvec_right = tmp_vec2
	local mvec_up = tmp_vec3

	if apply_gun_kick and (self:in_steelsight() or weapon_tweak.gun_kick.apply_during_hipfire) then
		mvec3_cross(mvec_right, direction, math.UP)
		mvec3_norm(mvec_right)
		mvec3_cross(mvec_up, direction, mvec_right)
		mvec3_norm(mvec_up)
		mvec3_mul(mvec_right, math.rad(self._gun_kick.x.delta))
		mvec3_mul(mvec_up, math.rad(self._gun_kick.y.delta))
		mvec3_set(mvec_direction, direction)
		mvec3_add(mvec_direction, mvec_right)
		mvec3_add(mvec_direction, mvec_up)
	else
		mvec3_set(mvec_direction, direction)
	end

	local ray_res = DP28RaycastWeaponBase.super.super.fire(self, from_pos, mvec_direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	self._spread_firing = (self._spread_firing or 0) + self:_get_fire_spread_add(shoot_player)
	self._spread_last_shot_t = (weapon_tweak.fire_mode_data and weapon_tweak.fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier() * (weapon_tweak.spread.recovery_wait_multiplier or 1)
	self._recoil_firing = self:_get_fire_recoil()
	self._recoil_last_shot_t = (weapon_tweak.fire_mode_data and weapon_tweak.fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier() * (weapon_tweak.kick.recovery_wait_multiplier or 1)

	if apply_gun_kick then
		local gun_kick_values = self:in_steelsight() and weapon_tweak.gun_kick.steelsight or weapon_tweak.gun_kick.hip_fire

		if gun_kick_values then
			local recoil_multiplier = self:recoil_multiplier()
			local kick_x = math.lerp(gun_kick_values[3], gun_kick_values[4], math.random()) * recoil_multiplier
			local kick_y = math.lerp(gun_kick_values[1], gun_kick_values[2], math.random()) * recoil_multiplier

			self._gun_kick.x.velocity = self._gun_kick.x.velocity + kick_x
			self._gun_kick.y.velocity = self._gun_kick.y.velocity + kick_y * -1
		end
	end

	if not self._playing then
		self:tweak_data_anim_play("fire")

		self._playing = true
	end

	if start_ammo - self:get_ammo_remaining_in_clip() >= 1 then
		self:play_magazine_anim()
	end

	return ray_res
end

function DP28RaycastWeaponBase:update(unit, t, dt)
	local is_reloading = self._unit:anim_is_playing(Idstring("reload")) or self._unit:anim_is_playing(Idstring("reload_not_empty"))

	if (self:fire_mode() == "single" or managers.warcry._active_warcry_name == "berserk" and managers.warcry._active) and not is_reloading then
		self:set_magazine_pos_based_on_ammo(false)
	end

	DP28RaycastWeaponBase.super.update(self, unit, t, dt)
end

function DP28RaycastWeaponBase:set_magazine_pos_based_on_ammo(count_max)
	local percent_of_anim = 0

	if self.length then
		if not count_max then
			percent_of_anim = self:get_magazine_true_pos()
		else
			percent_of_anim = self:get_ammo_total() > self:get_ammo_max_per_clip() and 0 or 1 - (0 + self:get_ammo_total()) / (0 + self:get_ammo_max_per_clip())
		end

		self._magazine_time_stamp = percent_of_anim * self.length

		self:set_magazine_time_stamp(self._magazine_time_stamp)
	end
end

function DP28RaycastWeaponBase:get_magazine_true_pos()
	local pos = (0 + self:get_ammo_remaining_in_clip()) / (0 + self:get_ammo_max_per_clip())

	return 1 - pos
end

function DP28RaycastWeaponBase:get_magazine_object()
	return self._parts.wpn_fps_lmg_dp28_m_standard or self._parts.wpn_fps_lmg_dp28_m_extended
end

function DP28RaycastWeaponBase:tweak_data_anim_play(anim, speed_multiplier)
	local data = tweak_data.weapon.factory[self._factory_id]

	if data.animations and data.animations[anim] then
		local anim_name = data.animations[anim]
		local length = self._unit:anim_length(Idstring(anim_name))

		speed_multiplier = speed_multiplier or 1

		self._unit:anim_stop(Idstring(anim_name))
		self._unit:anim_play_to(Idstring(anim_name), length, speed_multiplier)
	end

	if anim == "equip" then
		self:set_magazine_time_stamp(self._magazine_time_stamp or 0)
	end

	local strap_data = self._parts.wpn_fps_lmg_dp28_m_strap

	if strap_data then
		local anim_name = strap_data.animations[anim]

		if anim_name then
			local length = strap_data.unit:anim_length(Idstring(anim_name))

			speed_multiplier = speed_multiplier or 1

			strap_data.unit:anim_stop(Idstring(anim_name))
			strap_data.unit:anim_play_to(Idstring(anim_name), length, speed_multiplier)
		end
	end

	DP28RaycastWeaponBase.super.super.tweak_data_anim_play(self, anim, speed_multiplier)

	return true
end

function DP28RaycastWeaponBase:play_magazine_anim(speed_multiplier)
	local data = self:get_magazine_object()
	local anim_name = data.animations.fire

	self.length = data.unit:anim_length(Idstring(anim_name))
	speed_multiplier = self.length / (self:get_ammo_max_per_clip() * tweak_data.weapon[self._name_id].auto.fire_rate)

	data.unit:anim_play_to(Idstring(anim_name), self.length, speed_multiplier)
end

function DP28RaycastWeaponBase:weapon_parts_anim_pause()
	local data = self:get_magazine_object()
	local anim_name = data.animations.fire

	data.unit:anim_pause(Idstring(anim_name))
	data.unit:anim_play_to(Idstring(anim_name), self:get_anim_length() * self:get_magazine_true_pos())

	self._magazine_time_stamp = data.unit:anim_time(Idstring(anim_name))

	if self._magazine_time_stamp > 3.2 then
		data.unit:anim_pause(Idstring(anim_name))
		self:set_magazine_time_stamp(self:get_anim_length())
	end

	self._playing = false
end

function DP28RaycastWeaponBase:get_anim_length()
	if self.length then
		return self.length
	else
		local data = self:get_magazine_object()
		local anim_name = data.animations.fire

		self.length = data.unit:anim_length(Idstring(anim_name))

		return self.length
	end
end

function DP28RaycastWeaponBase:start_reload(...)
	DP28RaycastWeaponBase.super.start_reload(self, ...)
end

function DP28RaycastWeaponBase:set_magazine_time_stamp(time)
	local data = self:get_magazine_object()

	if data.unit then
		data.unit:anim_set_time(Idstring(data.animations.fire), time)
	end
end

function DP28RaycastWeaponBase:tweak_data_anim_stop(anim, force_fire)
	if anim == "fire" and not force_fire then
		return
	end

	DP28RaycastWeaponBase.super.tweak_data_anim_stop(self, anim)
end

function DP28RaycastWeaponBase:reset_magazine_anim_pos()
	self:set_magazine_pos_based_on_ammo(true)
	print("--Realoaded dp28")
end
