NPCGrenadeLauncherBase = NPCGrenadeLauncherBase or class(NPCRaycastWeaponBase)

-- Lines 3-6
function NPCGrenadeLauncherBase:init(...)
	NPCGrenadeLauncherBase.super.init(self, ...)

	self._grenade_id = self.grenade_id or "m24"
end

-- Lines 10-12
function NPCGrenadeLauncherBase:ejects_shells()
	return false
end

-- Lines 16-19
function NPCGrenadeLauncherBase:fire_blank(direction, impact)
	World:effect_manager():spawn(self._muzzle_effect_table)
	self:_sound_singleshot()
end

-- Lines 23-47
function NPCGrenadeLauncherBase:singleshot(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if not Network:is_server() then
		return
	end

	local fired = self:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	Application:trace("[NPCGrenadeLauncherBase:singleshot]   fired: ", fired)

	if fired then
		local direction = self._obj_fire:rotation():y()

		if fired.hit_pos then
			direction = (fired.hit_pos - self._obj_fire:position()):normalized()
		elseif target_unit then
			direction = (target_unit:position() - self._obj_fire:position()):normalized()
		end

		local index = tweak_data.blackmarket:get_index_from_projectile_id(self._grenade_id)

		ProjectileBase.throw_projectile(index, self._obj_fire:position(), direction * 10)
		self:_sound_singleshot()
	end

	return fired
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local mvec1 = Vector3()

-- Lines 55-100
function NPCGrenadeLauncherBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local result = {}
	local hit_unit = nil
	local spread = self:_get_spread(user_unit)

	mvector3.set(mvec_spread_direction, direction)

	if spread then
		-- Nothing
	end

	local ray_distance = self._weapon_range or 20000

	if target_unit then
		mvector3.set(mvec_to, target_unit:position())
	else
		mvector3.set(mvec_to, direction)
		mvector3.multiply(mvec_to, ray_distance)
		mvector3.add(mvec_to, from_pos)
	end

	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

	if col_ray then
		result.hit_enemy = col_ray.hit_unit
	end

	if self._alert_events then
		result.rays = {
			col_ray
		}

		if col_ray then
			result.hit_pos = col_ray.position

			Application:debug("hit pos ", result.hit_pos)
		end
	end

	return result
end
