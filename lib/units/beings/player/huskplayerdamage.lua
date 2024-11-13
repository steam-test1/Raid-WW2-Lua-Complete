HuskPlayerDamage = HuskPlayerDamage or class()

function HuskPlayerDamage:init(unit)
	self._unit = unit
	self._spine2_obj = unit:get_object(Idstring("Spine2"))
	self._listener_holder = EventListenerHolder:new()
	self._mission_damage_blockers = {}
	self._health_ratio = 1
end

function HuskPlayerDamage:set_health_ratio(value)
	self._health_ratio = value
end

function HuskPlayerDamage:health_ratio()
	return self._health_ratio
end

function HuskPlayerDamage:_call_listeners(damage_info)
	CopDamage._call_listeners(self, damage_info)
end

function HuskPlayerDamage:add_listener(...)
	CopDamage.add_listener(self, ...)
end

function HuskPlayerDamage:remove_listener(key)
	CopDamage.remove_listener(self, key)
end

function HuskPlayerDamage:sync_martyrdom(projectile_entry)
	PlayerDamage.on_martyrdom(self, projectile_entry)
end

function HuskPlayerDamage:sync_damage_bullet(attacker_unit, damage, i_body, height_offset)
	local attack_data = {
		pos = nil,
		attack_dir = nil,
		attacker_unit = nil,
		result = nil,
		attacker_unit = attacker_unit,
		attack_dir = attacker_unit and attacker_unit:movement():m_pos() - self._unit:movement():m_pos() or Vector3(1, 0, 0),
		pos = mvector3.copy(self._unit:movement():m_head_pos()),
		result = {
			type = "hurt",
			variant = "bullet"
		}
	}

	self:_call_listeners(attack_data)
end

function HuskPlayerDamage:shoot_pos_mid(m_pos)
	self._spine2_obj:m_position(m_pos)
end

function HuskPlayerDamage:can_attach_projectiles()
	return false
end

function HuskPlayerDamage:set_last_down_time(down_time)
	self._last_down_time = down_time
end

function HuskPlayerDamage:down_time()
	return self._last_down_time
end

function HuskPlayerDamage:incapacitated()
	return self._unit:movement():current_state_name() == "incapacitated"
end

function HuskPlayerDamage:set_mission_damage_blockers(type, state)
	self._mission_damage_blockers[type] = state
end

function HuskPlayerDamage:get_mission_blocker(type)
	return self._mission_damage_blockers[type]
end

function HuskPlayerDamage:dead()
end
