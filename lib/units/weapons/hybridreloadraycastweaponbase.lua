HybridReloadRaycastWeaponBase = HybridReloadRaycastWeaponBase or class(NewRaycastWeaponBase)

-- Lines 4-10
function HybridReloadRaycastWeaponBase:start_reload(...)
	self._started_reload_empty = self:clip_empty()

	if self:use_shotgun_reload() then
		local speed_multiplier = self:reload_speed_multiplier()
		self._next_shell_reloded_t = managers.player:player_timer():time() + self:_first_shell_reload_expire_t() / speed_multiplier
	end
end

-- Lines 12-15
function HybridReloadRaycastWeaponBase:use_shotgun_reload()
	local is_empty = self:mag_is_empty()

	return not is_empty
end

-- Lines 17-20
function HybridReloadRaycastWeaponBase:mag_is_empty()
	self._mag_is_empty = self:clip_empty()

	return self._mag_is_empty
end

-- Lines 23-28
function HybridReloadRaycastWeaponBase:reload_interuptable()
	if self._started_reload_empty and not self:use_shotgun_reload() then
		return false
	end

	return true
end

-- Lines 30-41
function HybridReloadRaycastWeaponBase:update_reloading(t, dt, time_left)
	if self:use_shotgun_reload() and self._next_shell_reloded_t and self._next_shell_reloded_t < t then
		local speed_multiplier = self:reload_speed_multiplier()
		self._next_shell_reloded_t = self._next_shell_reloded_t + self:reload_shell_expire_t() / speed_multiplier

		self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip() + 1))
		managers.raid_job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

		return true
	end
end
