NewNPCFlamethrowerBase = NewNPCFlamethrowerBase or class(NewNPCRaycastWeaponBase)

function NewNPCFlamethrowerBase:init(...)
	NewNPCFlamethrowerBase.super.init(self, ...)
	self:setup_default()
end

function NewNPCFlamethrowerBase:setup_default()
	self._use_shell_ejection_effect = false
	self._use_trails = false
end

function NewNPCFlamethrowerBase:_spawn_muzzle_effect(from_pos, direction)
end

function NewNPCFlamethrowerBase:update(unit, t, dt)
	if self._check_shooting_expired and self._check_shooting_expired.check_t < t then
		self._check_shooting_expired = nil

		self._unit:set_extension_update_enabled(Idstring("base"), false)
		SawWeaponBase._stop_sawing_effect(self)
		self:play_tweak_data_sound("stop_fire")
	end
end

function NewNPCFlamethrowerBase:fire_blank(direction, impact)
	if not self._check_shooting_expired then
		self:play_tweak_data_sound("fire")
	end

	self._check_shooting_expired = {
		check_t = Application:time() + 0.3
	}

	self._unit:set_extension_update_enabled(Idstring("base"), true)
	self._unit:flamethrower_effect_extension():_spawn_muzzle_effect(self._obj_fire:position(), direction)
end
