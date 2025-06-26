local UpgradeBrutality = {
	check_activate = function (self)
		managers.system_event_listener:remove_listener("brutality_health_regen")

		if alive(managers.player:local_player()) and managers.player:has_category_upgrade("temporary", "brutality_dismember_critical_hit_chance") then
			managers.system_event_listener:add_listener("brutality_health_regen", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
			}, callback(self, self, "_on_enemy_killed"))
		end
	end,
	_on_enemy_killed = function (self, params)
		if not params or not params.dismemberment_occured or not params.damage_type or params.damage_type ~= "bullet" then
			return
		end

		if not managers.player:has_activate_temporary_upgrade("temporary", "brutality_dismember_critical_hit_chance") then
			managers.player:activate_temporary_upgrade("temporary", "brutality_dismember_critical_hit_chance")
		end
	end
}

return UpgradeBrutality
