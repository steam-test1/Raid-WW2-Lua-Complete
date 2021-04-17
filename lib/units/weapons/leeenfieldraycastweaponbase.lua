LeeEnfieldRaycastWeaponBase = LeeEnfieldRaycastWeaponBase or class(HybridReloadRaycastWeaponBase)

-- Lines 3-9
function LeeEnfieldRaycastWeaponBase:use_shotgun_reload()
	if managers.weapon_skills:get_weapon_skills("lee_enfield")[2][3][1].active then
		return false
	end

	return LeeEnfieldRaycastWeaponBase.super.use_shotgun_reload(self)
end
