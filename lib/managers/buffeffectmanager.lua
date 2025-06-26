require("lib/managers/buff_effect/BuffEffect")
require("lib/managers/buff_effect/BuffEffectCandy")
require("lib/managers/buff_effect/BuffEffectTimeSpeed")

BuffEffectManager = BuffEffectManager or class()
BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_REWARD_INCREASE = "enemy_loot_drop_reward_increase"
BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_CHANCE = "enemy_loot_drop_chance"
BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_HEALTH = "enemy_loot_drop_despawn_health"
BuffEffectManager.EFFECT_ENEMY_LOOT_DROP_DESPAWN_AMMO = "enemy_loot_drop_despawn_ammo"
BuffEffectManager.EFFECT_PLAYER_ALL_AMMO_CAPACITY = "player_all_ammo_capacity"
BuffEffectManager.EFFECT_PLAYER_PRIMARY_AMMO_CAPACITY = "player_primary_ammo_capacity"
BuffEffectManager.EFFECT_PLAYER_SECONDARY_AMMO_CAPACITY = "player_secondary_ammo_capacity"
BuffEffectManager.EFFECT_PLAYER_RELOAD_SPEED = "reload_speed"
BuffEffectManager.EFFECT_ENEMIES_RECEIVE_DAMAGE = "enemies_receive_damage"
BuffEffectManager.EFFECT_ENEMY_DOES_DAMAGE = "enemy_does_damage"
BuffEffectManager.EFFECT_SET_BLEEDOUT_TIMER = "set_bleedout_timer"
BuffEffectManager.EFFECT_MODIFY_LIVES = "effect_modify_lives"
BuffEffectManager.EFFECT_MODIFY_BLEEDOUT_TIMER = "modify_bleedout_timer"
BuffEffectManager.EFFECT_PLAYER_HEALTH = "player_health"
BuffEffectManager.EFFECT_PLAYER_CRITICAL_HIT_CHANCE = "player_critical_hit_chance"
BuffEffectManager.EFFECT_PLAYER_HEADSHOT_DOESNT_DO_DAMAGE = "player_headshot_doesnt_do_damage"
BuffEffectManager.EFFECT_PLAYER_HEADSHOT_AUTO_KILL = "player_headshot_auto_kill"
BuffEffectManager.EFFECT_PLAYER_HEADSHOT_DAMAGE = "player_headshot_damage"
BuffEffectManager.EFFECT_ENEMIES_DIE_ONLY_ON_HEADSHOT = "enemies_die_only_on_headshot"
BuffEffectManager.EFFECT_PLAYER_MOVEMENT_SPEED = "effect_player_movement_speed"
BuffEffectManager.EFFECT_PLAYER_CAN_MOVE_ONLY_BACK_AND_SIDE = "player_can_move_only_back_and_side"
BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN = "bags_dont_slow_players_down"
BuffEffectManager.EFFECT_BAG_WEIGHT = "bag_weight"
BuffEffectManager.EFFECT_GRENADE_DAMAGE = "grenade_damage"
BuffEffectManager.EFFECT_AMMO_PICKUPS_REFIL_GRENADES = "ammo_pickups_refill_grenades"
BuffEffectManager.EFFECT_ENEMIES_VULNERABLE_ONLY_TO_EXPLOSION = "enemies_vulnerable_only_to_explosion"
BuffEffectManager.EFFECT_ENEMIES_VULNERABLE_ONLY_TO_MELEE = "enemies_vulnerable_only_to_melee"
BuffEffectManager.EFFECT_ENEMIES_IMPERVIOUS_TO_EXPLOSIVE_DAMAGE = "enemies_impervious_to_explosive_damage"
BuffEffectManager.EFFECT_SHOOTING_SECONDARY_WEAPON_FILLS_PRIMARY_AMMO = "shooting_secondary_weapon_refills_primary_ammo"
BuffEffectManager.EFFECT_SHOOTING_PRIMARY_WEAPON_CONSUMES_BOTH_AMMOS = "shooting_primary_weapon_consumes_both_ammos"
BuffEffectManager.EFFECT_PLAYER_PRIMARY_DAMAGE = "player_primary_damage"
BuffEffectManager.EFFECT_PLAYER_SECONDARY_DAMAGE = "player_secondary_damage"
BuffEffectManager.EFFECT_ENEMY_HEALTH = "enemy_health"
BuffEffectManager.EFFECT_PLAYER_DIED = "player_died"
BuffEffectManager.EFFECT_PLAYER_BLEEDOUT = "player_bleedout"
BuffEffectManager.EFFECT_FORCED_CRATE_TIER = "forced_crate_tier"
BuffEffectManager.EFFECT_PLAYER_FAILED_INTERACTION_MINI_GAME = "player_failed_interaction_mini_game"
BuffEffectManager.EFFECT_PLAYER_MELEE_KILL_REGENERATES_HEALTH = "player_melee_kill_regenerates_health"
BuffEffectManager.EFFECT_PLAYER_KILL_REGENERATES_HEALTH = "player_kill_regenerates_health"
BuffEffectManager.EFFECT_PLAYER_HEALTH_REGEN = "player_health_regen"
BuffEffectManager.EFFECT_PLAYERS_CANT_USE_WARCRIES = "players_cant_use_warcries"
BuffEffectManager.EFFECT_PLAYERS_CANT_EMPTY_CLIPS = "players_cant_empty_clips"
BuffEffectManager.EFFECT_MELEE_DAMAGE_INCREASE = "players_melee_damage_increase"
BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE = "players_only_melee"
BuffEffectManager.EFFECT_WARCRIES_DISABLED = "players_warcries_disabled"
BuffEffectManager.EFFECT_ATTACK_ONLY_IN_AIR = "attack_only_in_air"
BuffEffectManager.EFFECT_PLAYER_LOW_HEALTH_DAMAGE = "player_low_health_damage"
BuffEffectManager.EFFECT_NO_BLEEDOUT_PUMPIKIN_REVIVE = "no_bleedout_pumpkin_revive"
BuffEffectManager.EFFECT_PUMKIN_HEADS = "pumkin_heads"
BuffEffectManager.EFFECT_XMAS_FOIL = "effect_xmas_foil"
BuffEffectManager.EFFECT_XMAS_LOOTBOXES = "effect_xmas_lootboxes"
BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED = "effect_player_carry_invert_speed"
BuffEffectManager.EFFECT_ENEMIES_MELEE_DAMAGE_INCREASE = "effect_enemies_melee_damage_increase"
BuffEffectManager.EFFECT_PLAYER_EQUIP_CROWBAR = "effect_player_equip_crowbar"
BuffEffectManager.EFFECT_PLAYER_RANDOM_RELOAD = "effect_player_random_reload"
BuffEffectManager.EFFECT_LUCKY_DAY = "effect_lucky_day"
BuffEffectManager.EFFECT_PLAYER_DOOMS_DAY = "effect_player_dooms_day"
BuffEffectManager.EFFECT_PLAYER_CANNOT_ADS = "effect_player_cannot_ads"
BuffEffectManager.EFFECT_PLAYER_CANNOT_SPRINT = "effect_player_cannot_sprint"
BuffEffectManager.EFFECT_TIME_SPEED = "effect_time_speed"
BuffEffectManager.EFFECT_TRICK_OR_TREAT = "effect_trick_or_treat"
BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_SPENT_AMMO = "challenge_card_effect_failed_message_player_spent_all_ammo"
BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_FAILED_INTERACTION_MINI_GAME = "challenge_card_effect_failed_message_player_failed_interaction_mini_game"
BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_WENT_TO_BLEEDOUT = "challenge_card_effect_failed_message_player_went_to_bleedout"
BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_DIED = "challenge_card_effect_failed_message_player_died"
BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_USED_ILEGAL_WEAPON_CATEGORY = "challenge_card_effect_failed_message_player_used_ilegal_weapon_category"
BuffEffectManager.FAIL_EFFECT_MESSAGE_COMPLETE_RAID_WITHIN_TIME = "challenge_card_effect_failed_message_complete_raid_within_time"
BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_USED_WARCRY = "challenge_card_effect_failed_message_player_used_warcry"
BuffEffectManager.FAIL_EFFECT_MESSAGE_PLAYER_EMPTIED_A_CLIP = "challenge_card_effect_failed_message_player_emptied_a_clip"
BuffEffectManager.EFFECT_CLASSES = {
	BuffEffectCandy = true,
	BuffEffectTimeSpeed = true
}

function BuffEffectManager:init()
	self._active_effects = {}
	self._timers = {}
	self._effect_id_counter = 0
	self._dt_sum = 0
end

function BuffEffectManager:activate_effect(effect_data)
	Application:debug("[BuffEffectManager:activate_effect]", effect_data and inspect(effect_data))

	local effect_class = effect_data.effect_class and BuffEffectManager.EFFECT_CLASSES[effect_data.effect_class] and CoreSerialize.string_to_classtable(effect_data.effect_class) or BuffEffect
	local effect = effect_class:new(effect_data.name, effect_data.value, effect_data.challenge_card_key, effect_data.fail_message, effect_data.params)
	self._effect_id_counter = self._effect_id_counter + 1
	self._active_effects[self._effect_id_counter] = effect
	effect.effect_id = self._effect_id_counter

	if effect_data.name == BuffEffectManager.EFFECT_COMPLETE_RAID_WITHIN then
		self._timers[effect_data.name] = {
			start_time = TimerManager:game():time(),
			value = effect_data.value,
			effect_id = effect.effect_id,
			effect_name = effect.effect_name
		}
	elseif effect_data.name == BuffEffectManager.EFFECT_NO_SNIPER then
		managers.global_state:set_flag("card_snipers_deactivate")
	elseif effect_data.name == BuffEffectManager.EFFECT_NO_BARRAGE then
		managers.global_state:set_flag("card_barrage_deactivate")
	elseif effect_data.name == BuffEffectManager.EFFECT_FORCED_CRATE_TIER and effect_data.value == 2 then
		managers.global_state:set_flag("card_all_chests_are_locked")
	elseif effect_data.name == BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE then
		managers.global_state:set_flag("card_only_melee_available")
	end

	return self._effect_id_counter
end

function BuffEffectManager:deactivate_effect_by_card_id(card_id)
	for _, effect in pairs(self._active_effects) do
		if effect.challenge_card_key and effect.challenge_card_key == card_id then
			if effect.destroy then
				effect:destroy()
			end

			self:deactivate_special_effect_and_timer(effect.effect_id)

			self._active_effects[effect.effect_id] = nil
		end
	end
end

function BuffEffectManager:deactivate_effect(active_effect_id)
	self:deactivate_special_effect_and_timer(active_effect_id)

	if self._active_effects and self._active_effects[active_effect_id] then
		if self._active_effects[active_effect_id].destroy then
			self._active_effects[active_effect_id]:destroy()
		end

		self._active_effects[active_effect_id] = nil
	end
end

function BuffEffectManager:deactivate_special_effect_and_timer(active_effect_id)
	if self._active_effects and self._active_effects[active_effect_id] then
		local effect = self._active_effects[active_effect_id]

		if self._active_effects[active_effect_id].effect_name == BuffEffectManager.EFFECT_COMPLETE_RAID_WITHIN then
			self._timers[effect.effect_name] = nil
		elseif self._active_effects[active_effect_id].effect_name == BuffEffectManager.EFFECT_NO_SNIPER then
			managers.global_state:clear_flag("card_snipers_deactivate")
		elseif self._active_effects[active_effect_id].effect_name == BuffEffectManager.EFFECT_NO_BARRAGE then
			managers.global_state:clear_flag("card_barrage_deactivate")
		elseif self._active_effects[active_effect_id].effect_name == BuffEffectManager.EFFECT_ALL_CHESTS_ARE_LOCKED then
			managers.global_state:clear_flag("card_all_chests_are_locked")
		elseif self._active_effects[active_effect_id].effect_name == BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE then
			managers.global_state:clear_flag("card_only_melee_available")
		end
	end
end

function BuffEffectManager:is_effect_active(effect_name)
	if managers.player:local_player_in_camp() then
		return false
	end

	local result = false

	for effect_id, effect in pairs(self._active_effects) do
		if effect_name == effect.effect_name then
			result = true

			break
		end
	end

	return result
end

function BuffEffectManager:get_effect_value(effect_name)
	if managers.player:local_player_in_camp() then
		return 0
	end

	local result = 0

	for effect_id, effect in pairs(self._active_effects) do
		if effect_name == effect.effect_name then
			result = effect.value

			break
		end
	end

	return result
end

function BuffEffectManager:get_effect(effect_name)
	if managers.player:local_player_in_camp() then
		return 0
	end

	local result = 0

	for effect_id, effect in pairs(self._active_effects) do
		if effect_name == effect.effect_name then
			return effect
		end
	end
end

function BuffEffectManager:update(t, dt)
	self._dt_sum = self._dt_sum + dt

	if self._dt_sum >= 1 then
		if self._timers then
			for timer_name, timer_data in pairs(self._timers) do
				if timer_data.start_time + timer_data.value * 60 < TimerManager:game():time() then
					self:fail_effect(timer_data.effect_name, nil)

					self._timers[timer_name] = nil
				end
			end
		end

		self._dt_sum = 0
	end
end

function BuffEffectManager:get_active_effect_by_effect_id(effect_id)
	return self._active_effects[effect_id]
end

function BuffEffectManager:player_failed_challenge_card_effect(failed_effect_name, peer_id)
	if Network:is_server() then
		local challenge_card_key = ""
		local effectid = 0

		if self._active_effects then
			for effect_id, effect in pairs(self._active_effects) do
				if effect.effect_name == failed_effect_name then
					challenge_card_key = effect.challenge_card_key
					effectid = effect.effect_id

					break
				end
			end
		end

		managers.raid_job:on_challenge_card_failed()
		managers.challenge_cards:card_failed_warning(challenge_card_key, effectid, peer_id)
		managers.challenge_cards:deactivate_active_challenge_card()
	end
end

function BuffEffectManager:fail_effect(failed_effect_name, peer_id)
	local active_card = managers.challenge_cards:get_active_card()
	local active_card_status = managers.challenge_cards:get_active_card_status()

	if active_card and active_card_status ~= ChallengeCardsManager.CARD_STATUS_ACTIVE then
		return
	end

	if Network:is_server() then
		self:player_failed_challenge_card_effect(failed_effect_name, peer_id)
	else
		managers.network:session():send_to_host("fail_effect", failed_effect_name, peer_id)
	end
end

function BuffEffectManager:save_dropin(data)
	local active_effects = {}

	for _, effect in pairs(self._active_effects) do
		local state = effect:save()

		table.insert(active_effects, state)
	end

	local state = {
		active_effects = active_effects,
		dt_sum = self._dt_sum,
		effect_id_counter = self._effect_id_counter,
		timers = self._timers
	}
	data.BuffEffectManager = state
end

function BuffEffectManager:load_dropin(data)
	local state = data.BuffEffectManager

	if state then
		self._dt_sum = state.dt_sum or 0
		self._effect_id_counter = state.effect_id_counter or 0
		self._active_effects = {}
		local active_effects = state.active_effects

		if active_effects then
			self._effect_id_counter = math.max(0, self._effect_id_counter - #active_effects)

			for _, effect_data in pairs(active_effects) do
				self:activate_effect(effect_data)
			end
		end

		self._timers = state.timers or {}
	end

	if managers.challenge_cards:get_active_card() and managers.challenge_cards:get_active_card().active then
		managers.raid_menu:_activate_card()
	end
end
