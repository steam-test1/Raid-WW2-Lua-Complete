ProjectileWeaponBase = ProjectileWeaponBase or class(NewRaycastWeaponBase)

-- Lines 3-6
function ProjectileWeaponBase:init(...)
	ProjectileWeaponBase.super.init(self, ...)

	self._projectile_type_index = self:weapon_tweak_data().projectile_type_index
end

local mvec_spread_direction = Vector3()

-- Lines 11-53
function ProjectileWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local unit = nil
	local spread = self:_get_spread(user_unit)

	mvector3.set(mvec_spread_direction, direction)

	if spread then
		mvector3.spread(mvec_spread_direction, spread * (spread_mul or 1))
	end

	local projectile_type_index = self._projectile_type_index or 2

	if self._ammo_data and self._ammo_data.launcher_grenade then
		projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id(self._ammo_data.launcher_grenade)
	end

	self:_adjust_throw_z(mvec_spread_direction)

	mvec_spread_direction = mvec_spread_direction * self:projectile_speed_multiplier()
	local spawn_offset = self:_get_spawn_offset()
	self._dmg_mul = dmg_mul or 1

	if not self._client_authoritative then
		if Network:is_client() then
			managers.network:session():send_to_host("request_throw_projectile", projectile_type_index, from_pos, mvec_spread_direction, 0)
		else
			unit = ProjectileBase.throw_projectile(projectile_type_index, from_pos, mvec_spread_direction, managers.network:session():local_peer():id())
		end
	else
		unit = ProjectileBase.throw_projectile(projectile_type_index, from_pos, mvec_spread_direction, managers.network:session():local_peer():id())
	end

	managers.statistics:shot_fired({
		hit = false,
		weapon_unit = self._unit
	})

	return {}
end

-- Lines 57-64
function ProjectileWeaponBase:_update_stats_values()
	ProjectileWeaponBase.super._update_stats_values(self)

	if self._ammo_data and self._ammo_data.projectile_type_index ~= nil then
		self._projectile_type_index = self._ammo_data.projectile_type_index
	end
end

-- Lines 66-68
function ProjectileWeaponBase:_adjust_throw_z(m_vec)
end

-- Lines 72-74
function ProjectileWeaponBase:projectile_damage_multiplier()
	return self._dmg_mul
end

-- Lines 78-80
function ProjectileWeaponBase:projectile_speed_multiplier()
	return 1
end

-- Lines 84-86
function ProjectileWeaponBase:_get_spawn_offset()
	return 0
end
