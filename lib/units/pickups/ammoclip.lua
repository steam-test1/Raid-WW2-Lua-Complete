AmmoClip = AmmoClip or class(Pickup)
AmmoClip.EVENT_IDS = {
	mule_share_ammo = 1
}

function AmmoClip:init(unit)
	AmmoClip.super.init(self, unit)

	self._ammo_type = ""
	local material = self._unit:material(Idstring("mat_effect"))

	if material then
		Pickup.randomize_glow_effect(material)
	end
end

function AmmoClip:_pickup(unit)
	if self._picked_up then
		return
	end

	local inventory = unit:inventory()

	if not unit:character_damage():dead() and inventory then
		local picked_up = false
		local all_added_ammmo = 0

		if self._pickup_filter and self._pickup_filter == tweak_data.projectiles[managers.blackmarket:equipped_projectile()].pickup_filter then
			if managers.player:add_grenade_amount(self._ammo_count or 1) > 0 then
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

			local effect_ammo_pickup_multiplier = 1

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) then
				effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) or 1) - 1
			end

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_AMMO_EFFECT_INCREASE) then
				effect_ammo_pickup_multiplier = effect_ammo_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_AMMO_EFFECT_INCREASE) or 1) - 1
			end

			local base_ammo_amount = tweak_data.drop_loot[self.tweak_data].ammo_multiplier or 1
			local ammo_pickup_multiplier = 1
			ammo_pickup_multiplier = ammo_pickup_multiplier + managers.player:upgrade_value("player", "clipazines_pick_up_ammo_multiplier", 1) - 1
			ammo_pickup_multiplier = ammo_pickup_multiplier + managers.player:upgrade_value("player", "cache_basket_pick_up_ammo_multiplier", 1) - 1
			local add_ammo_amount_ratio = base_ammo_amount * (ammo_pickup_multiplier + effect_ammo_pickup_multiplier - 1)
			local success, add_amount, ammo_picked_up = nil

			for _, weapon in ipairs(available_selections) do
				if not self._weapon_category or self._weapon_category == weapon.unit:base():weapon_tweak_data().category then
					success, add_amount, ammo_picked_up = weapon.unit:base():add_ammo(add_ammo_amount_ratio, self._ammo_count)
					all_added_ammmo = all_added_ammmo + (add_amount or 0)
					picked_up = success or picked_up

					if self._ammo_count then
						self._ammo_count = math.max(math.floor(self._ammo_count - add_amount), 0)
					end
				end
			end
		end

		if picked_up then
			self._picked_up = true

			if not self._weapon_category and not self._pickup_filter then
				if managers.player:has_category_upgrade("player", "opportunist_pick_up_ammo_to_health") then
					local damage_ext = unit:character_damage()

					if damage_ext and not damage_ext:is_downed() and not damage_ext:dead() and not damage_ext:is_perseverating() then
						local restore_ratio = managers.player:upgrade_value("player", "opportunist_pick_up_ammo_to_health") - 1
						local restore_value = all_added_ammmo * restore_ratio

						damage_ext:restore_health(restore_value, true)
					end
				end

				if managers.player:has_category_upgrade("player", "opportunist_pick_up_supplies_to_warcry") then
					local add_warcry_ratio = managers.player:upgrade_value("player", "opportunist_pick_up_supplies_to_warcry") - 1
					local warcry_fill_amount = math.random() * add_warcry_ratio

					managers.warcry:fill_meter_by_value(warcry_fill_amount)
				end

				if managers.player:has_category_upgrade("player", "pack_mule_ammo_share_team") then
					managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", AmmoClip.EVENT_IDS.mule_share_ammo)
				end
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
	local peer_unit = peer and peer:unit()

	if not alive(player) or not alive(peer_unit) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():dead() then
		return
	end

	if event == AmmoClip.EVENT_IDS.mule_share_ammo then
		local player_pos = player:position()
		local source_pos = peer_unit:position()
		local distance_limit = tweak_data.upgrades.pack_mule_ammo_share_distance
		local inventory = player:inventory()

		if inventory and mvector3.distance(player_pos, source_pos) < distance_limit then
			local loot_tweak = tweak_data.drop_loot[self.tweak_data]
			local add_ammo_ratio = loot_tweak and loot_tweak.ammo_multiplier or 1
			local share_multiplier = managers.player:upgrade_value_by_level("player", "pack_mule_ammo_share_team", 1, 1) - 1

			for id, weapon in pairs(inventory:available_selections()) do
				if weapon.unit:base():add_ammo(add_ammo_ratio * share_multiplier) then
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end
		end
	end
end

function AmmoClip:get_pickup_type()
	return "ammo"
end
