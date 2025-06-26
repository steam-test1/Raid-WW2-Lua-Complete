local UpgradeToughness = {
	ACTIVE_COLOR = tweak_data.gui.colors.raid_gold
}

function UpgradeToughness:check_activate()
	managers.system_event_listener:remove_listener("toughness_on_bleedout")
	managers.system_event_listener:remove_listener("toughness_revived")

	if alive(managers.player:local_player()) and managers.player:has_category_upgrade("player", "toughness_death_defiant") then
		managers.system_event_listener:add_listener("toughness_on_bleedout", {
			CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_CHECK_BLEEDOUT
		}, callback(self, self, "_on_bleedout"))
		managers.system_event_listener:add_listener("toughness_revived", {
			CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_REVIVED
		}, callback(self, self, "_on_revived"))
		managers.hud:override_player_down_color(UpgradeToughness.ACTIVE_COLOR)

		self._health_gain = managers.player:upgrade_value("player", "toughness_death_defiant", 0)
		self._active = true
	else
		if self._active then
			managers.hud:override_player_down_color()
		end

		self._health_gain = nil
		self._active = nil
	end
end

function UpgradeToughness:_on_bleedout(params)
	if not params or params.bleed_out_blocked then
		return
	end

	local player = managers.player:local_player()

	if not alive(player) then
		return
	end

	if self._active then
		self._active = false
		params.bleed_out_blocked = true
		local revives = player:character_damage():get_revives()

		managers.hud:override_player_down_color()
		managers.hud:set_player_downs(revives)
		player:character_damage():restore_health(self._health_gain)
		player:sound():play("toughness_death_defy")
		managers.warcry:downed()
	end
end

function UpgradeToughness:_on_revived()
	if not self._active then
		self._active = true

		managers.hud:override_player_down_color(UpgradeToughness.ACTIVE_COLOR)
	end
end

return UpgradeToughness
