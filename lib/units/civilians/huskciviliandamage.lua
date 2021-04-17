HuskCivilianDamage = HuskCivilianDamage or class(HuskCopDamage)
HuskCivilianDamage._HEALTH_INIT = CivilianDamage._HEALTH_INIT
HuskCivilianDamage.damage_bullet = CivilianDamage.damage_bullet
HuskCivilianDamage.damage_melee = CivilianDamage.damage_melee

-- Lines 8-10
function HuskCivilianDamage:_on_damage_received(damage_info)
	CivilianDamage._on_damage_received(self, damage_info)
end

-- Lines 14-16
function HuskCivilianDamage:_unregister_from_enemy_manager(damage_info)
	CivilianDamage._unregister_from_enemy_manager(self, damage_info)
end

-- Lines 20-25
function HuskCivilianDamage:damage_explosion(attack_data)
	if attack_data.variant == "explosion" then
		attack_data.damage = 10
	end

	return CopDamage.damage_explosion(self, attack_data)
end

-- Lines 29-34
function HuskCivilianDamage:damage_fire(attack_data)
	if attack_data.variant == "fire" then
		attack_data.damage = 10
	end

	return CopDamage.damage_fire(self, attack_data)
end
