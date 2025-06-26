local UpgradeLeaded = {
	check_activate = function (self)
		managers.system_event_listener:remove_listener("leaded_sponge_damage")

		if alive(managers.player:local_player()) and managers.player:has_category_upgrade("player", "leaded_ammo_sponge") then
			managers.system_event_listener:add_listener("leaded_sponge_damage", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGE_TAKEN
			}, callback(self, self, "_on_damage_taken"))

			self._hit_count = 0
			self._hit_target = managers.player:upgrade_value("player", "leaded_ammo_sponge", 0)
			self._refill_magazine = managers.player:upgrade_value("player", "leaded_magazine_refill", false)
			self._absorb_reduction = managers.player:upgrade_value("player", "leaded_damage_reduction", 1)
			self._player = managers.player:local_player()
		else
			self._hit_count = nil
			self._hit_target = nil
			self._refill_magazine = nil
			self._absorb_reduction = nil
		end
	end,
	_on_damage_taken = function (self, attack_data)
		if not attack_data.variant == "bullet" then
			return
		end

		self._hit_count = self._hit_count + 1

		if self._hit_count < self._hit_target then
			return
		end

		local equipped_weapon = self._player:inventory():equipped_unit()

		if alive(equipped_weapon) and equipped_weapon:base():uses_ammo() then
			local weapon_base = equipped_weapon:base()

			if not weapon_base:ammo_full() or not weapon_base:clip_full() then
				local ammo_ratio = weapon_base:get_ammo_in_clip_ratio()

				weapon_base:add_ammo(nil, 1)

				if self._refill_magazine then
					local ammo_in_clip = weapon_base:get_ammo_remaining_in_clip()

					weapon_base:set_ammo_remaining_in_clip(ammo_in_clip + 1)
				end

				managers.hud:set_ammo_amount(weapon_base:selection_index(), weapon_base:ammo_info())

				if weapon_base:can_reload() then
					managers.hud:hide_prompt("hud_reload_prompt")
				end

				if not weapon_base:out_of_ammo() then
					managers.hud:hide_prompt("hud_no_ammo_prompt")
				end
			end
		end

		attack_data.damage = attack_data.damage * self._absorb_reduction

		self._player:sound():play("ammo_sponge_absorb")

		self._hit_count = 0
	end
}

return UpgradeLeaded
