AkimboShotgunBase = AkimboShotgunBase or class(AkimboWeaponBase)

-- Lines 3-6
function AkimboShotgunBase:init(...)
	AkimboShotgunBase.super.init(self, ...)
	self:setup_default()
end

-- Lines 8-10
function AkimboShotgunBase:setup_default()
	NewShotgunBase.setup_default(self)
end

-- Lines 12-14
function AkimboShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	return NewShotgunBase._fire_raycast(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
end

-- Lines 16-18
function AkimboShotgunBase:get_damage_falloff(damage, col_ray, user_unit)
	return NewShotgunBase.get_damage_falloff(self, damage, col_ray, user_unit)
end

-- Lines 20-22
function AkimboShotgunBase:_update_stats_values()
	NewShotgunBase._update_stats_values(self)
end

NPCAkimboShotgunBase = NPCAkimboShotgunBase or class(NPCAkimboWeaponBase)
