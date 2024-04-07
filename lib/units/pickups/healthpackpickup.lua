HealthPackPickup = HealthPackPickup or class(Pickup)

function HealthPackPickup:init(unit)
	HealthPackPickup.super.init(self, unit)
	self:_randomize_glow_effect()
end

function HealthPackPickup:_pickup(unit)
	if self._picked_up then
		return
	end

	if not unit:character_damage():dead() then
		local picked_up = false

		if not unit:character_damage():full_health() then
			local current_health = unit:character_damage():get_real_health()
			local effect_health_pickup_multiplier = 1

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) then
				effect_health_pickup_multiplier = effect_health_pickup_multiplier + ((managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE) or 1) - 1)
			end

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_HEALTH_EFFECT_INCREASE) then
				effect_health_pickup_multiplier = effect_health_pickup_multiplier + ((managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_HEALTH_EFFECT_INCREASE) or 1) - 1)
			end

			local health_pku_tweakdata = tweak_data.drop_loot[self.tweak_data]
			local base_health_recovery = health_pku_tweakdata.health_restored
			local upgrade_health_pickup_multiplier = managers.player:upgrade_value("player", "pick_up_health_multiplier", 1)
			local recovery_percentage = base_health_recovery * (upgrade_health_pickup_multiplier + (effect_health_pickup_multiplier - 1)) / 100
			local max_health = unit:character_damage():get_max_health()

			unit:character_damage():set_health(current_health + recovery_percentage * max_health)

			picked_up = true

			if current_health < max_health / 4 then
				unit:sound_source():post_event(health_pku_tweakdata.player_voice_over)
			end

			if health_pku_tweakdata.restore_down then
				managers.player:player_unit():character_damage():recover_down()
			end
		end

		if picked_up then
			self._picked_up = true

			if Network:is_client() then
				managers.network:session():send_to_host("sync_pickup", self._unit)
			end

			self:consume()

			return true
		end
	end

	return false
end

function HealthPackPickup:sync_net_event(event, peer)
	return
end

function HealthPackPickup:get_pickup_type()
	return "health"
end
