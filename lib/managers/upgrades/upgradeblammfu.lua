local UpgradeBlammFu = {
	check_activate = function (self)
		managers.system_event_listener:remove_listener("blammfu_explosive_melee")

		if alive(managers.player:local_player()) and managers.player:has_category_upgrade("player", "blammfu_explosive_grenade_melee") then
			managers.system_event_listener:add_listener("blammfu_explosive_melee", {
				CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_DAMAGED_ENEMY_MELEE
			}, callback(self, self, "_on_melee"))

			self._explosion_chance = managers.player:upgrade_value("player", "blammfu_explosive_grenade_melee", 1) - 1
		else
			self._explosion_chance = nil
		end
	end,
	_on_melee = function (self, params)
		if not alive(params.unit) or not params.attack_data then
			return
		end

		local local_player = managers.player:local_player()
		local equipped_weapon = managers.player:equipped_weapon_unit()

		if not alive(local_player) or not alive(equipped_weapon) then
			return
		end

		if not equipped_weapon:base():is_category(WeaponTweakData.WEAPON_CATEGORY_GRENADE) then
			return
		end

		if not managers.player:can_throw_grenade() or self._explosion_chance < math.random() then
			return
		end

		local equipped_grenade = managers.blackmarket:equipped_grenade()
		local projectile_data = tweak_data.projectiles[equipped_grenade]
		local grenade_index = tweak_data.blackmarket:get_index_from_projectile_id(equipped_grenade)

		if not projectile_data.can_airburst then
			return
		end

		local cooking_t = -1
		local from = local_player:movement():m_head_pos()
		local pos = from + local_player:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
		local dir = local_player:movement():m_head_rot():y()

		if Network:is_client() then
			managers.network:session():send_to_host("request_throw_projectile", grenade_index, pos, dir, cooking_t, nil)
		else
			ProjectileBase.throw_projectile(grenade_index, pos, dir, managers.network:session():local_peer():id(), cooking_t)
			managers.player:verify_grenade(managers.network:session():local_peer():id())
		end

		managers.player:on_throw_grenade()

		local current_state = managers.player:get_current_state()

		if current_state then
			local push_vel = -(projectile_data.enemy_proximity_range or projectile_data.range or 100)

			current_state:do_action_blammfu_melee(dir * push_vel)
		end
	end
}

return UpgradeBlammFu
