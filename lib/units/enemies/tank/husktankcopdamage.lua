HuskTankCopDamage = HuskTankCopDamage or class(HuskCopDamage)

-- Lines 3-5
function HuskTankCopDamage:init(...)
	HuskTankCopDamage.super.init(self, ...)
end

-- Lines 7-9
function HuskTankCopDamage:damage_bullet(attack_data, ...)
	return HuskTankCopDamage.super.damage_bullet(self, attack_data, ...)
end

-- Lines 11-18
function HuskTankCopDamage:damage_melee(attack_data)
	local tweak_data = tweak_data.blackmarket.melee_weapons[attack_data.name_id]

	if tweak_data and (tweak_data.type == "knife" or tweak_data.type == "sword" or attack_data.name_id == "boxing_gloves") then
		return HuskTankCopDamage.super.damage_melee(self, attack_data)
	else
		return
	end
end

-- Lines 20-22
function HuskTankCopDamage:seq_clbk_vizor_shatter()
	TankCopDamage.seq_clbk_vizor_shatter(self)
end
