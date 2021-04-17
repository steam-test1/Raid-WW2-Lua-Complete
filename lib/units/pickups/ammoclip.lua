AmmoClip = AmmoClip or class(Pickup)
AmmoClip.EVENT_IDS = {
	bonnie_share_ammo = 1,
	register_grenade = 16
}

function AmmoClip:init(unit)
	AmmoClip.super.init(self, unit)

	self._ammo_type = ""

	self:_randomize_glow_effect()
end

function AmmoClip:_pickup(unit)
	if self._picked_up then
		return
	end

	local inventory = unit:inventory()

	if not unit:character_damage():dead() and inventory then
		local picked_up = false

		if self._projectile_id then
			if managers.blackmarket:equipped_projectile() == self._projectile_id and not managers.player:got_max_grenades() then
				managers.player:add_grenade_amount(self._ammo_count or 1)

				picked_up = true
			end
		else
			local available_selections = {}

			for i, weapon in pairs(inventory:available_selections()) do
				if inventory:is_equipped(i) then
					table.insert(available_selections, 1, weapon)
				else
					table.insert(available_selections, weapon)
				end
			end

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_AMMO_PICKUPS_REFIL_GRENADES) then
				local grenades_refill_amount = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_AMMO_PICKUPS_REFIL_GRENADES)

				managers.player:add_grenade_amount(grenades_refill_amount or 1)
			end

			local success, add_amount = nil

			for _, weapon in ipairs(available_selections) do
				if not self._weapon_category or self._weapon_category == weapon.unit:base():weapon_tweak_data().category then
					local effect_ammo_pickup_multiplier = 1

					if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) then
						effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) or 1) - 1
					end

					if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_AMMO_EFFECT_INCREASE) then
						effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_AMMO_EFFECT_INCREASE) or 1) - 1
					end

					local base_ammo_amount = tweak_data.drop_loot[self.tweak_data].ammo_multiplier or 1
					local upgrade_ammo_pickup_multiplier = managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
					local add_ammo_amount_ratio = base_ammo_amount * (upgrade_ammo_pickup_multiplier + effect_ammo_pickup_multiplier - 1)
					success, add_amount = weapon.unit:base():add_ammo(add_ammo_amount_ratio, self._ammo_count)
					picked_up = success or picked_up

					if self._ammo_count then
						self._ammo_count = math.max(math.floor(self._ammo_count - add_amount), 0)
					end
				end
			end
		end

		if picked_up then
			self._picked_up = true

			if not self._projectile_id and not self._weapon_category then
				local restored_health = nil

				if not unit:character_damage():is_downed() and managers.player:has_category_upgrade("temporary", "loose_ammo_restore_health") and not managers.player:has_activate_temporary_upgrade("temporary", "loose_ammo_restore_health") then
					managers.player:activate_temporary_upgrade("temporary", "loose_ammo_restore_health")

					local values = managers.player:temporary_upgrade_value("temporary", "loose_ammo_restore_health", 0)

					if values ~= 0 then
						local restore_value = math.random(values[1], values[2])
						local base = tweak_data.upgrades.loose_ammo_restore_health_values.base
						local sync_value = math.round(math.clamp(restore_value - base, 0, 13))
						restore_value = restore_value * (tweak_data.upgrades.loose_ammo_restore_health_values.multiplier or 0.1)
						local damage_ext = unit:character_damage()

						if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
							damage_ext:restore_health(restore_value, true)
							unit:sound():play("pickup_ammo_health_boost", nil, false)
						end

						if managers.player:has_category_upgrade("player", "loose_ammo_restore_health_give_team") then
							managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", 2 + sync_value)
						end
					end
				end

				if managers.player:has_category_upgrade("temporary", "loose_ammo_give_team") and not managers.player:has_activate_temporary_upgrade("temporary", "loose_ammo_give_team") then
					managers.player:activate_temporary_upgrade("temporary", "loose_ammo_give_team")
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.bonnie_share_ammo)
				end
			elseif self._projectile_id then
				managers.player:register_grenade(managers.network:session():local_peer():id())
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.register_grenade)
			end

			if Network:is_client() then
				managers.network:session():send_to_host("sync_pickup", self._unit)
			end

			if inventory and picked_up then
				for id, wpn in pairs(inventory:available_selections()) do
					managers.hud:set_ammo_amount(id, wpn.unit:base():ammo_info())
				end
			end

			unit:sound():play(self._pickup_event or "pickup_ammo", nil, false)
			self:consume()

			return true
		end
	end

	return false
end

function AmmoClip:sync_net_event(event, peer)
	local player = managers.player:local_player()

	if not alive(player) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():dead() then
		return
	end

	if event == AmmoClip.EVENT_IDS.bonnie_share_ammo then
		local inventory = player:inventory()

		if inventory then
			local picked_up = false

			for id, weapon in pairs(inventory:available_selections()) do
				picked_up = weapon.unit:base():add_ammo((tweak_data.drop_loot[self.tweak_data].ammo_multiplier or 1) * (tweak_data.upgrades.loose_ammo_give_team_ratio or 0.25), nil) or picked_up
			end

			if picked_up then
				for id, weapon in pairs(inventory:available_selections()) do
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end
		end
	elseif event == AmmoClip.EVENT_IDS.register_grenade then
		if peer and not self._grenade_registered then
			managers.player:register_grenade(peer:id())

			self._grenade_registered = true
		end
	elseif AmmoClip.EVENT_IDS.bonnie_share_ammo < event then
		local damage_ext = player:character_damage()

		if not damage_ext:need_revive() and not damage_ext:dead() and not damage_ext:is_berserker() then
			local restore_value = event - 2 + (tweak_data.upgrades.loose_ammo_restore_health_values.base or 3)
			restore_value = restore_value * (tweak_data.upgrades.loose_ammo_restore_health_values.multiplier or 0.1)
			restore_value = restore_value * (tweak_data.upgrades.loose_ammo_give_team_health_ratio or 0.35)
		end
	end
end

function AmmoClip:get_pickup_type()
	return "ammo"
end
