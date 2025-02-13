HuskCivilianEscortDamage = HuskCivilianEscortDamage or class(HuskCivilianDamage)
HuskCivilianEscortDamage.damage_bullet = CivilianEscortDamage.damage_bullet
HuskCivilianEscortDamage.damage_explosion = CivilianEscortDamage.damage_explosion
HuskCivilianEscortDamage.damage_fire = CivilianEscortDamage.damage_fire
HuskCivilianEscortDamage.damage_melee = CivilianEscortDamage.damage_melee
HuskCivilianEscortDamage.damage_tase = CivilianEscortDamage.damage_tase
HuskCivilianEscortDamage._escort_damage = CivilianEscortDamage._escort_damage
HuskCivilianEscortDamage._on_damage_received = CivilianDamage._on_damage_received
HuskCivilianEscortDamage.grace_period = CivilianEscortDamage.grace_period

function HuskCivilianEscortDamage:init(...)
	HuskCivilianEscortDamage.super.init(self, ...)

	self._last_damage_taken = 0
	self._last_damage_t = 0
end

function HuskCivilianEscortDamage:_apply_damage_to_health(damage)
	HuskCivilianEscortDamage.super._apply_damage_to_health(self, damage)

	if self._unit:escort() then
		self._unit:escort():update_health_bar()
	end
end

function HuskCivilianEscortDamage:die()
	HuskCivilianEscortDamage.super.die(self)

	if self._unit:escort() then
		self._unit:escort():remove_waypoint()
		self._unit:escort():remove_health_bar()
	end

	if self._unit:contour() then
		self._unit:contour():remove("highlight_character")
	end
end
