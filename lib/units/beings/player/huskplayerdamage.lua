HuskPlayerDamage = HuskPlayerDamage or class()

-- Lines 5-11
function HuskPlayerDamage:init(unit)
	self._unit = unit
	self._spine2_obj = unit:get_object(Idstring("Spine2"))
	self._listener_holder = EventListenerHolder:new()
	self._mission_damage_blockers = {}
	self._health_ratio = 1
end

-- Lines 14-16
function HuskPlayerDamage:set_health_ratio(value)
	self._health_ratio = value
end

-- Lines 18-20
function HuskPlayerDamage:health_ratio()
	return self._health_ratio
end

-- Lines 22-24
function HuskPlayerDamage:_call_listeners(damage_info)
	CopDamage._call_listeners(self, damage_info)
end

-- Lines 28-30
function HuskPlayerDamage:add_listener(...)
	CopDamage.add_listener(self, ...)
end

-- Lines 34-36
function HuskPlayerDamage:remove_listener(key)
	CopDamage.remove_listener(self, key)
end

-- Lines 40-48
function HuskPlayerDamage:sync_damage_bullet(attacker_unit, damage, i_body, height_offset)
	local attack_data = {
		attacker_unit = attacker_unit,
		attack_dir = attacker_unit and attacker_unit:movement():m_pos() - self._unit:movement():m_pos() or Vector3(1, 0, 0),
		pos = mvector3.copy(self._unit:movement():m_head_pos()),
		result = {
			variant = "bullet",
			type = "hurt"
		}
	}

	self:_call_listeners(attack_data)
end

-- Lines 52-54
function HuskPlayerDamage:shoot_pos_mid(m_pos)
	self._spine2_obj:m_position(m_pos)
end

-- Lines 58-60
function HuskPlayerDamage:can_attach_projectiles()
	return false
end

-- Lines 64-66
function HuskPlayerDamage:set_last_down_time(down_time)
	self._last_down_time = down_time
end

-- Lines 70-72
function HuskPlayerDamage:down_time()
	return self._last_down_time
end

-- Lines 76-78
function HuskPlayerDamage:arrested()
	return self._unit:movement():current_state_name() == "arrested"
end

-- Lines 82-84
function HuskPlayerDamage:incapacitated()
	return self._unit:movement():current_state_name() == "incapacitated"
end

-- Lines 88-90
function HuskPlayerDamage:set_mission_damage_blockers(type, state)
	self._mission_damage_blockers[type] = state
end

-- Lines 93-95
function HuskPlayerDamage:get_mission_blocker(type)
	return self._mission_damage_blockers[type]
end

-- Lines 99-100
function HuskPlayerDamage:dead()
end
