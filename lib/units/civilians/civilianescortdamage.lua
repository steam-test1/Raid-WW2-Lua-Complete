CivilianEscortDamage = CivilianEscortDamage or class(CivilianDamage)
CivilianEscortDamage.grace_period = 0.5

function CivilianEscortDamage:init(...)
	CivilianEscortDamage.super.init(self, ...)

	self._last_damage_taken = 0
	self._last_damage_t = 0
end

function CivilianEscortDamage:_escort_damage(attack_data)
	local t = TimerManager:game():time()

	if self._last_damage_t > t - self.grace_period and attack_data.damage <= self._last_damage_taken then
		return "no_damage"
	end

	if self._unit:escort() and (self._unit:escort():is_safe() or not self._unit:escort():active()) then
		return "no_damage"
	end

	self._last_damage_t = t
	self._last_damage_taken = attack_data.damage
end

function CivilianEscortDamage:_apply_damage_to_health(damage)
	CivilianEscortDamage.super._apply_damage_to_health(self, damage)

	if self._unit:escort() then
		self._unit:escort():update_health_bar()
	end
end

function CivilianEscortDamage:die()
	CivilianEscortDamage.super.die(self)

	if self._unit:escort() then
		self._unit:escort():remove_waypoint()
		self._unit:escort():remove_health_bar()
	end

	if self._unit:contour() then
		self._unit:contour():remove("highlight_character")
	end
end

function CivilianEscortDamage:damage_bullet(attack_data)
	return self:_escort_damage(attack_data) or CopDamage.damage_bullet(self, attack_data)
end

function CivilianEscortDamage:damage_explosion(attack_data)
	return self:_escort_damage(attack_data) or CopDamage.damage_explosion(self, attack_data)
end

function CivilianEscortDamage:damage_fire(attack_data)
	return self:_escort_damage(attack_data) or CopDamage.damage_fire(self, attack_data)
end

function CivilianEscortDamage:damage_melee(attack_data)
	return self:_escort_damage(attack_data) or CopDamage.damage_melee(self, attack_data)
end

function CivilianEscortDamage:damage_tase(attack_data)
	return self:_escort_damage(attack_data) or CopDamage.damage_tase(self, attack_data)
end
