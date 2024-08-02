local UpgradeRally = {
	check_activate = function (self)
		managers.system_event_listener:remove_listener("rally_damage_taken")
		managers.system_event_listener:remove_listener("rally_damaged_enemy")
		managers.system_event_listener:remove_listener("rally_reset")

		if managers.player:has_category_upgrade("player", "rally_recoverable_health") then
			managers.system_event_listener:add_listener("rally_damage_taken", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGE_TAKEN
			}, callback(self, self, "_on_damage_taken"))
			managers.system_event_listener:add_listener("rally_damaged_enemy", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGED_ENEMY
			}, callback(self, self, "_on_damaged_enemy"))
			managers.system_event_listener:add_listener("rally_reset", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_ENTER_BLEEDOUT,
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_SET_HEALTH_EFFECTS
			}, callback(self, self, "_on_reset"))

			self._rally_health = 0
			self._max_amount = managers.player:upgrade_value("player", "rally_recoverable_health")
			self._damage_ratio = managers.player:upgrade_value("player", "rally_recoverable_damage_ratio", 1) - 1
			self._headshot_multiplier = managers.player:upgrade_value("player", "rally_recovery_headshot_multiplier", 1)
			self._damage_ext = managers.player:local_player():character_damage()
		else
			self._rally_health = nil
			self._max_amount = nil
			self._damage_ratio = nil
			self._headshot_multiplier = nil

			managers.hud:set_player_special_health({
				current = 0,
				total = 0
			})
		end
	end,
	_on_damage_taken = function (self, attack_data)
		if not self._damage_ext or self._damage_ext:bleed_out() or self._damage_ext:is_perseverating() or self._damage_ext:health_effects_blocked() or not attack_data then
			return
		end

		local damage_taken = attack_data.damage
		local damage_to_rally = damage_taken * self._damage_ratio
		self._rally_health = math.min(self._rally_health + damage_to_rally, self._max_amount)

		self._damage_ext:set_reserved_health(self._rally_health)
		managers.hud:set_player_special_health({
			current = self._rally_health,
			total = self._damage_ext:get_max_health()
		})
	end,
	_on_damaged_enemy = function (self, params)
		if not self._damage_ext or self._damage_ext:bleed_out() or self._damage_ext:is_perseverating() or self._damage_ext:health_effects_blocked() or not params or not params.attack_data then
			return
		end

		if self._rally_health > 0 then
			local recovery_multipler = params.attack_data.headshot and self._headshot_multiplier or 1
			local recovery_amount = math.min(tweak_data.upgrades.rally_recovery_amount * recovery_multipler, self._rally_health)
			self._rally_health = self._rally_health - recovery_amount

			self._damage_ext:set_reserved_health(self._rally_health)
			self._damage_ext:change_health(recovery_amount)
			managers.hud:set_player_special_health({
				current = self._rally_health,
				total = self._damage_ext:get_max_health()
			})
		end
	end,
	_on_reset = function (self)
		self._rally_health = 0

		managers.hud:set_player_special_health({
			current = 0,
			total = 0
		})
	end
}

return UpgradeRally
