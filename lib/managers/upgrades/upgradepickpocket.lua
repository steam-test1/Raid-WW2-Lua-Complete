local UpgradePickpocket = {
	check_activate = function (self)
		managers.system_event_listener:remove_listener("pickpocket_melee_steal")

		if alive(managers.player:local_player()) and managers.player:has_category_upgrade("temporary", "pickpocket_melee_ammo_steal") then
			managers.system_event_listener:add_listener("pickpocket_melee_steal", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGED_ENEMY_MELEE
			}, callback(self, self, "_on_enemy_melee"))

			self._ammo_steal = managers.player:upgrade_value("temporary", "pickpocket_melee_ammo_steal")
			self._health_steal = managers.player:upgrade_value("player", "pickpocket_melee_health_steal", 0)
		else
			self._ammo_steal = nil
			self._health_steal = nil
		end
	end,
	_on_enemy_melee = function (self, params)
		if managers.player:has_activate_temporary_upgrade("temporary", "pickpocket_melee_ammo_steal") then
			return
		end

		local local_player = managers.player:local_player()
		local enemy_unit = params.unit

		if not alive(local_player) or not alive(enemy_unit) or enemy_unit:unit_data().pickpocketed then
			return
		end

		local success = false
		local steal_amount_ammo = self._ammo_steal and self._ammo_steal[1] or 1
		steal_amount_ammo = (steal_amount_ammo - 1) * 10
		local _, ammo_gained = local_player:inventory():add_ammo_to_equipped(steal_amount_ammo)
		success = ammo_gained and ammo_gained > 0

		if not success then
			_, ammo_gained = local_player:inventory():add_ammo_to_selection(PlayerInventory.SLOT_2, steal_amount_ammo)
			success = ammo_gained and ammo_gained > 0
		end

		if not success then
			_, ammo_gained = local_player:inventory():add_ammo_to_selection(PlayerInventory.SLOT_1, steal_amount_ammo)
			success = ammo_gained and ammo_gained > 0
		end

		if self._health_steal > 0 and not local_player:character_damage():dead() then
			local health_restored = local_player:character_damage():restore_health(self._health_steal, true)
			success = success or health_restored
		end

		if success then
			local_player:sound():play("pickup_ammo", nil, false)
			managers.player:activate_temporary_upgrade("temporary", "pickpocket_melee_ammo_steal")

			enemy_unit:unit_data().pickpocketed = true
		end
	end
}

return UpgradePickpocket
