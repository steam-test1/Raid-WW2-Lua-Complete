local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local math_clamp = math.clamp
local math_lerp = math.lerp
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
SawWeaponBase = SawWeaponBase or class(NewRaycastWeaponBase)

function SawWeaponBase:init(unit)
	SawWeaponBase.super.init(self, unit)

	self._active_effect_name = Idstring("effects/vanilla/weapons/saw/sawing")
	self._active_effect_table = {
		force_synch = true,
		effect = self._active_effect_name,
		parent = self._obj_fire
	}
end

function SawWeaponBase:change_fire_object(new_obj)
	SawWeaponBase.super.change_fire_object(self, new_obj)

	self._active_effect_table.parent = new_obj
end

function SawWeaponBase:start_shooting(...)
	SawWeaponBase.super.start_shooting(self, ...)
end

function SawWeaponBase:stop_shooting(...)
	self:_stop_sawing_effect()
	SawWeaponBase.super.stop_shooting(self, ...)
end

function SawWeaponBase:_play_sound_sawing()
	self:play_sound("Play_saw_handheld_grind_generic")
end

function SawWeaponBase:_play_sound_idle()
	self:play_sound("Play_saw_handheld_loop_idle")
end

function SawWeaponBase:_start_sawing_effect()
	if not self._active_effect then
		self:_play_sound_sawing()

		self._active_effect = World:effect_manager():spawn(self._active_effect_table)
	end
end

function SawWeaponBase:_stop_sawing_effect()
	if self._active_effect then
		self:_play_sound_idle()
		World:effect_manager():fade_kill(self._active_effect)

		self._active_effect = nil
	end
end

function SawWeaponBase:setup(setup_data)
	SawWeaponBase.super.setup(self, setup_data)

	self._no_hit_alert_size = self._alert_size
	self._hit_alert_size = tweak_data.weapon.stats.alert_size[math.clamp(self:check_stats().alert_size - (self:weapon_tweak_data().hit_alert_size_increase or 0), 1, #tweak_data.weapon.stats.alert_size)]
end

function SawWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if self:get_ammo_remaining_in_clip() == 0 then
		return
	end

	local user_unit = self._setup.user_unit
	local ray_res, hit_something = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if hit_something then
		self:_start_sawing_effect()

		local ammo_usage = 5

		if ray_res.hit_enemy then
			if managers.player:has_category_upgrade("saw", "enemy_slicer") then
				ammo_usage = 10
			else
				ammo_usage = 15
			end
		end

		ammo_usage = ammo_usage + math.ceil(math.random() * 10)

		if managers.player:has_category_upgrade("saw", "consume_no_ammo_chance") then
			local roll = math.rand(1)
			local chance = managers.player:upgrade_value("saw", "consume_no_ammo_chance", 0)

			if roll < chance then
				ammo_usage = 0
			end
		end

		ammo_usage = math.min(ammo_usage, self:get_ammo_remaining_in_clip())

		self:set_ammo_remaining_in_clip(math.max(self:get_ammo_remaining_in_clip() - ammo_usage, 0))
		self:set_ammo_total(math.max(self:get_ammo_total() - ammo_usage, 0))
		self:_check_ammo_total(user_unit)
	else
		self:_stop_sawing_effect()
	end

	if self._alert_events and ray_res.rays then
		if hit_something then
			self._alert_size = self._hit_alert_size
		else
			self._alert_size = self._no_hit_alert_size
		end

		self._current_stats.alert_size = self._alert_size

		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	return ray_res
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()

function SawWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	local result = {}
	local hit_unit = nil
	local spread = self:_get_spread(user_unit)
	from_pos = self._obj_fire:position()
	direction = self._obj_fire:rotation():y()

	mvec3_add(from_pos, direction * -30)
	mvector3.set(mvec_spread_direction, direction)
	mvector3.set(mvec_to, mvec_spread_direction)
	mvector3.multiply(mvec_to, 100)
	mvector3.add(mvec_to, from_pos)

	local damage = self:_get_current_damage(dmg_mul)
	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")

	if col_ray then
		hit_unit = SawHit:on_collision(col_ray, self._unit, user_unit, damage)
	end

	result.hit_enemy = hit_unit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	if col_ray then
		managers.statistics:shot_fired({
			hit = true,
			weapon_unit = self._unit
		})
	end

	return result, col_ray and col_ray.unit
end

function SawWeaponBase:ammo_info()
	return self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip(), self:remaining_full_clips(), self:get_ammo_max()
end

function SawWeaponBase:can_reload()
	return self:clip_empty() and SawWeaponBase.super.can_reload(self)
end

SawHit = SawHit or class(InstantBulletBase)

function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage)
	local hit_unit = col_ray.unit

	if hit_unit and false then
		damage = 50
	end

	local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage)

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 200)

		col_ray.body:extension().damage:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)

		if hit_unit:id() ~= -1 then
			managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_ray.body, damage)
		end
	end

	return result
end

function SawHit:play_impact_sound_and_effects(col_ray)
	managers.game_play_central:play_impact_sound_and_effects({
		decal = "saw",
		no_sound = true,
		col_ray = col_ray
	})
end
