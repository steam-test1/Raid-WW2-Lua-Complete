TankCopDamage = TankCopDamage or class(CopDamage)

-- Lines 3-5
function TankCopDamage:init(...)
	TankCopDamage.super.init(self, ...)
end

-- Lines 7-9
function TankCopDamage:damage_bullet(attack_data, ...)
	return TankCopDamage.super.damage_bullet(self, attack_data, ...)
end

-- Lines 11-18
function TankCopDamage:damage_melee(attack_data)
	local tweak_data = tweak_data.blackmarket.melee_weapons[attack_data.name_id]

	if tweak_data and (tweak_data.type == "knife" or tweak_data.type == "sword" or attack_data.name_id == "boxing_gloves") then
		return TankCopDamage.super.damage_melee(self, attack_data)
	else
		return
	end
end

-- Lines 20-24
function TankCopDamage:seq_clbk_vizor_shatter()
	if not self._unit:character_damage():dead() then
		self._unit:sound():say("visor_lost")
	end
end
