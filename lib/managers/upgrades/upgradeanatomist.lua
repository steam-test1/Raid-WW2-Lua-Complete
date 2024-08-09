local UpgradeAnatomist = {
	check_activate = function (self)
		managers.system_event_listener:remove_listener("anatomist_knockdown")

		if managers.player:has_category_upgrade("weapon", "anatomist_legshot_knockdown") then
			managers.system_event_listener:add_listener("anatomist_knockdown", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGED_ENEMY
			}, callback(self, self, "_on_knockdown"))

			self._max_damage = managers.player:upgrade_value("weapon", "anatomist_legshot_knockdown")
		else
			self._max_damage = nil
		end
	end,
	_on_knockdown = function (self, params)
		if not alive(params.unit) or not params.attack_data or not params.attack_data.col_ray or params.attack_data.variant ~= "bullet" then
			return
		end

		local enemy_unit = params.unit
		local character_damage = enemy_unit:character_damage()

		if not character_damage or character_damage:dead() or character_damage.ignore_knockdown and character_damage:ignore_knockdown() then
			return
		end

		local col_ray = params.attack_data.col_ray
		local body_name = col_ray.body and col_ray.body:name()

		if not body_name or not table.contains(tweak_data.upgrades.anatomist_bodies, body_name) then
			return
		end

		local damage = params.attack_data.damage or 1
		local knockdown_chance = math.clamp(damage / self._max_damage, 0, 1)
		local knockdown_roll = math.random()

		if knockdown_roll <= knockdown_chance and CopDamage.skill_action_knockdown(enemy_unit, col_ray.position, col_ray.normal) then
			managers.network:session():send_to_peers_synched("skill_action_knockdown", enemy_unit, col_ray.position, col_ray.normal, "knockdown")
		end
	end
}

return UpgradeAnatomist
