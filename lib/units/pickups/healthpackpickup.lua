HealthPackPickup = HealthPackPickup or class(Pickup)
HealthPackPickup.EVENT_IDS = {
	medic_share_health = 1
}

function HealthPackPickup:init(unit)
	HealthPackPickup.super.init(self, unit)
end

function HealthPackPickup:get_health_recovery()
	local health_pku_tweakdata = tweak_data.drop_loot[self.tweak_data]
	local base_health_recovery = health_pku_tweakdata.health_restored
	local health_pickup_multiplier = 1
	health_pickup_multiplier = health_pickup_multiplier + managers.player:upgrade_value("player", "medic_pick_up_health_multiplier", 1) - 1
	local effect_health_pickup_multiplier = 1

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) then
		effect_health_pickup_multiplier = effect_health_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) or 1) - 1
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_HEALTH_EFFECT_INCREASE) then
		effect_health_pickup_multiplier = effect_health_pickup_multiplier + (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_HEALTH_EFFECT_INCREASE) or 1) - 1
	end

	return base_health_recovery * (health_pickup_multiplier + effect_health_pickup_multiplier - 1)
end

function HealthPackPickup:get_restores_down()
	return tweak_data.drop_loot[self.tweak_data].restore_down
end

function HealthPackPickup:_pickup(unit)
	if self._picked_up then
		return
	end

	if not unit:character_damage():dead() then
		local picked_up = false
		local recovered_health = 0

		if unit:character_damage():need_healing() then
			local max_health = unit:character_damage():get_max_health()
			local current_health = unit:character_damage():get_real_health()
			local recovery = self:get_health_recovery()

			unit:character_damage():restore_health(recovery, true)

			picked_up = true
			recovered_health = unit:character_damage():get_real_health() - current_health

			if current_health < max_health / 4 then
				local health_pku_tweakdata = tweak_data.drop_loot[self.tweak_data]

				unit:sound():say(health_pku_tweakdata.player_voice_over, false, true)
			end
		end

		if self:get_restores_down() then
			unit:character_damage():recover_down()

			picked_up = true
		end

		if picked_up then
			self._picked_up = true

			if managers.player:has_category_upgrade("player", "opportunist_pick_up_health_to_ammo") and unit:inventory() then
				local add_ammo_ratio = managers.player:upgrade_value("player", "opportunist_pick_up_health_to_ammo") - 1
				local add_ammo_amount = recovered_health

				for id, weapon in pairs(unit:inventory():available_selections()) do
					local picked_up, _, add_amount = weapon.unit:base():add_ammo(add_ammo_ratio, add_ammo_amount)
					add_ammo_amount = add_ammo_amount - add_amount

					if picked_up then
						managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
					end
				end
			end

			if managers.player:has_category_upgrade("player", "opportunist_pick_up_supplies_to_warcry") then
				local add_warcry_ratio = managers.player:upgrade_value("player", "opportunist_pick_up_supplies_to_warcry") - 1
				local warcry_fill_amount = math.random() * add_warcry_ratio

				managers.warcry:fill_meter_by_value(warcry_fill_amount)
			end

			if managers.player:has_category_upgrade("player", "medic_health_share_team") then
				managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", HealthPackPickup.EVENT_IDS.medic_share_health)
			end

			if Network:is_client() then
				managers.network:session():send_to_host("sync_pickup", self._unit)
			end

			unit:sound():play(self._pickup_event or "pickup_health", nil, false)
			self:consume()

			return true
		end
	end

	return false
end

function HealthPackPickup:sync_net_event(event, peer)
	local player = managers.player:local_player()
	local peer_unit = peer and peer:unit()

	if not alive(player) or not alive(peer_unit) or not player:character_damage() or player:character_damage():is_downed() or player:character_damage():dead() then
		return
	end

	if event == HealthPackPickup.EVENT_IDS.medic_share_health then
		local player_pos = player:position()
		local source_pos = peer_unit:position()
		local distance_limit = tweak_data.upgrades.medic_health_share_distance
		local damage_ext = player:character_damage()

		if damage_ext and mvector3.distance(player_pos, source_pos) < distance_limit and not damage_ext:is_downed() and not damage_ext:dead() and not damage_ext:is_perseverating() then
			local restore_value = tweak_data.drop_loot[self.tweak_data].health_restored
			local share_multiplier = managers.player:upgrade_value_by_level("player", "medic_health_share_team", 1, 1) - 1

			damage_ext:restore_health(restore_value * share_multiplier, true)
		end
	end
end

function HealthPackPickup:get_pickup_type()
	return "health"
end
