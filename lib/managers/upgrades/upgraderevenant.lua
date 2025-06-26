local UpgradeRevenant = {
	check_activate = function (self)
		managers.system_event_listener:remove_listener("player_revive_effects")

		if alive(managers.player:local_player()) and managers.player:has_category_upgrade("player", "revenant_additional_life") then
			managers.system_event_listener:add_listener("player_revive_effects", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_REVIVED
			}, callback(self, self, "_on_revived"))
		end
	end,
	_on_revived = function (self)
		if managers.player:has_category_upgrade("temporary", "revenant_revived_damage_reduction") then
			managers.player:activate_temporary_upgrade("temporary", "revenant_revived_damage_reduction")
		end

		if managers.player:has_category_upgrade("temporary", "revenant_revived_critical_hit_chance") then
			managers.player:activate_temporary_upgrade("temporary", "revenant_revived_critical_hit_chance")
		end
	end
}

return UpgradeRevenant
