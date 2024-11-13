HybridReloadRaycastWeaponBase = HybridReloadRaycastWeaponBase or class(NewRaycastWeaponBase)

function HybridReloadRaycastWeaponBase:mag_is_empty()
	self._mag_is_empty = self:clip_empty()

	return self._mag_is_empty
end

function HybridReloadRaycastWeaponBase:use_shotgun_reload()
	self._use_shotgun_reload = not self:mag_is_empty()

	return self._use_shotgun_reload
end

function HybridReloadRaycastWeaponBase:reload_interuptable()
	return self._use_shotgun_reload and not self._started_reload_empty
end

function HybridReloadRaycastWeaponBase:on_reload()
	HybridReloadRaycastWeaponBase.super.on_reload(self)

	self._started_reload_empty = nil
end
