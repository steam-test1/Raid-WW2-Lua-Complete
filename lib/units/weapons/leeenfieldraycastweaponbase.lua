LeeEnfieldRaycastWeaponBase = LeeEnfieldRaycastWeaponBase or class(HybridReloadRaycastWeaponBase)

function LeeEnfieldRaycastWeaponBase:use_shotgun_reload()
	if managers.weapon_skills:get_weapon_skills("lee_enfield")[2][3][1].active and not managers.weapon_skills:get_hide_cosmetic_part("lee_enfield", "wpn_fps_snp_lee_enfield_m_extended") then
		return false
	end

	return LeeEnfieldRaycastWeaponBase.super.use_shotgun_reload(self)
end
