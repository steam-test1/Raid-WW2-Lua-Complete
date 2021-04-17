NPCFlamethrowerBase = NPCFlamethrowerBase or class(NPCRaycastWeaponBase)
NPCFlamethrowerBase.EXPLOSION_TYPE = "flamer_death_fake"

-- Lines 6-16
function NPCFlamethrowerBase:init(...)
	NPCFlamethrowerBase.super.init(self, ...)

	self._bullet_class = FlameBulletBase
	self._use_shell_ejection_effect = false
	self._use_trails = false
	self._already_detonated = false
end

-- Lines 20-22
function NPCFlamethrowerBase:ejects_shells()
	return false
end

-- Lines 25-27
function NPCFlamethrowerBase:_spawn_muzzle_effect(from_pos, direction)
	self._unit:flamethrower_effect_extension():_spawn_muzzle_effect(from_pos, direction)
end

-- Lines 29-31
function NPCFlamethrowerBase:_spawn_trail_effect(direction, col_ray)
end

-- Lines 35-42
function NPCFlamethrowerBase:fire_blank(direction, impact)
	if not self._check_shooting_expired then
		self:play_tweak_data_sound("fire")
	end

	self._check_shooting_expired = {
		check_t = Application:time() + 0.3
	}

	self._unit:set_extension_update_enabled(Idstring("base"), true)
end

-- Lines 46-55
function NPCFlamethrowerBase:update(unit, t, dt)
	if self._check_shooting_expired and self._check_shooting_expired.check_t < t then
		self._check_shooting_expired = nil

		self._unit:set_extension_update_enabled(Idstring("base"), false)
		SawWeaponBase._stop_sawing_effect(self)
		self:play_tweak_data_sound("stop_fire")
	end
end

-- Lines 57-60
function NPCFlamethrowerBase:start_autofire(nr_shots)
	self:_spawn_muzzle_effect(self._obj_fire:position(), self._obj_fire:rotation():y())
	NPCFlamethrowerBase.super.start_autofire(self, nr_shots)
end

-- Lines 63-66
function NPCFlamethrowerBase:trigger_held(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	self:_spawn_muzzle_effect(self._obj_fire:position(), direction)
	NPCFlamethrowerBase.super.trigger_held(self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
end
