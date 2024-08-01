HybridReloadRaycastWeaponBase = HybridReloadRaycastWeaponBase or class(NewRaycastWeaponBase)

function HybridReloadRaycastWeaponBase:mag_is_empty()
	self._mag_is_empty = self:clip_empty()

	return self._mag_is_empty
end

function HybridReloadRaycastWeaponBase:use_shotgun_reload()
	return not self:mag_is_empty()
end

function HybridReloadRaycastWeaponBase:reload_interuptable()
	return self:use_shotgun_reload() and not self._started_reload_empty
end
