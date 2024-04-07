HybridReloadRaycastWeaponBase = HybridReloadRaycastWeaponBase or class(NewRaycastWeaponBase)

function HybridReloadRaycastWeaponBase:start_reload(...)
	self._started_reload_empty = self:clip_empty()

	if self:use_shotgun_reload() then
		self:update_next_shell_reload_t(true)
	end
end

function HybridReloadRaycastWeaponBase:mag_is_empty()
	self._mag_is_empty = self:clip_empty()

	return self._mag_is_empty
end

function HybridReloadRaycastWeaponBase:use_shotgun_reload()
	local is_empty = self:mag_is_empty()

	return not is_empty
end

function HybridReloadRaycastWeaponBase:reload_interuptable()
	if self._started_reload_empty and not self:use_shotgun_reload() then
		return false
	end

	return true
end

function HybridReloadRaycastWeaponBase:update_reloading(t, dt, time_left)
	if self:use_shotgun_reload() and self._next_shell_reloded_t and t > self._next_shell_reloded_t then
		self:update_next_shell_reload_t()
		self:set_ammo_remaining_in_clip(math.min(self:get_ammo_max_per_clip(), self:get_ammo_remaining_in_clip() + self:get_ammo_reload_clip_single()))
		managers.raid_job:set_memory("kill_count_no_reload_" .. tostring(self._name_id), nil, true)

		return true
	end
end

function HybridReloadRaycastWeaponBase:update_next_shell_reload_t(start)
	local reload_shell_expire_t = self:reload_shell_expire_t()

	if reload_shell_expire_t then
		local speed_multiplier = self:reload_speed_multiplier()
		local old_shell_reloded_t = start and managers.player:player_timer():time() or self._next_shell_reloded_t

		self._next_shell_reloded_t = old_shell_reloded_t + reload_shell_expire_t / speed_multiplier
	end
end
