BuffEffectCandy = BuffEffectCandy or class(BuffEffect)
BuffEffectCandy.EVENT_CANDY_CONSUMED = "BuffEffectCandy:candy_consumed"

function BuffEffectCandy:init(effect_name, value, challenge_card_key, fail_message, params)
	BuffEffectCandy.super.init(self, effect_name, value, challenge_card_key, fail_message, params)

	self._tweak_data = tweak_data.events.special_events.trick_or_treat
	self._active_effects = {}
	self._inactive_effects = clone(self._tweak_data.malus_effects)
	self._current_stage = params and params.current_stage or 1
	self._candy_consumed = params and params.candy_consumed or 0
	self._candy_target = self._tweak_data.milestones[self._current_stage] or 0
	self._previous_target = self._tweak_data.milestones[self._current_stage - 1] or 0

	if Network:is_server() then
		managers.system_event_listener:add_listener("event_candy_consumed", {
			self.EVENT_CANDY_CONSUMED
		}, callback(self, self, "_on_candy_consumed"))
	end

	for i, upgrade in ipairs(self._tweak_data.upgrades) do
		local identifier = upgrade .. i

		managers.upgrades:aquire(upgrade, nil, identifier)
	end

	if not PackageManager:loaded(self._tweak_data.package) then
		PackageManager:load(self._tweak_data.package)
	end

	if managers.event_system:is_event_active() then
		local challenge = managers.challenge:get_challenge(ChallengeManager.CATEGORY_GENERIC, self._tweak_data.challenge_id)

		if not challenge:completed() then
			managers.challenge:activate_challenge(ChallengeManager.CATEGORY_GENERIC, self._tweak_data.challenge_id)
		end
	end

	local progress = (self._candy_consumed - self._previous_target) / (self._candy_target - self._previous_target)
	local active_card = managers.challenge_cards:get_active_card()

	managers.hud:register_tab_event_panel(HUDTabCandyProgression, {
		tier = self._current_stage - 1,
		progress = progress,
		card = active_card
	})

	if params and params.active_effects then
		for _, data in ipairs(params.active_effects) do
			for id, effect in ipairs(self._inactive_effects) do
				if effect.name == data.name then
					self._active_effects[effect.name] = data.id

					table.remove(self._inactive_effects, id)
					managers.experience:mission_xp_award("sugar_high_bonus")

					local malus_effect = {
						icon = "ico_malus",
						name = effect.name,
						desc_id = effect.desc_id,
						desc_params = effect.desc_params
					}

					managers.hud:set_tab_event_panel_data({
						malus_effect = malus_effect
					})

					break
				end
			end
		end
	end
end

function BuffEffectCandy:destroy()
	managers.system_event_listener:remove_listener("event_candy_consumed")

	for i, upgrade in ipairs(self._tweak_data.upgrades) do
		local identifier = upgrade .. i

		managers.upgrades:unaquire(upgrade, identifier)
	end

	for effect, id in pairs(self._active_effects) do
		managers.buff_effect:deactivate_effect(id)
	end

	if PackageManager:loaded(self._tweak_data.package) then
		PackageManager:unload(self._tweak_data.package)
	end

	managers.challenge:deactivate_challenge(ChallengeManager.CATEGORY_GENERIC, self._tweak_data.challenge_id)
	managers.hud:remove_tab_event_panel()
end

function BuffEffectCandy:save()
	local state = BuffEffectCandy.super.save(self)
	state.effect_class = "BuffEffectCandy"
	state.params = {
		current_stage = self._current_stage,
		candy_consumed = self._candy_consumed,
		active_effects = {}
	}

	for effect_name, id in pairs(self._active_effects) do
		table.insert(state.params.active_effects, {
			id = id,
			name = effect_name
		})
	end

	return state
end

function BuffEffectCandy:_on_candy_consumed(tweak_id)
	if not self._candy_target then
		return
	end

	local consumed = self:sync_candy_consumed(tweak_id)

	if consumed then
		managers.network:session():send_to_peers_synched("sync_candy_consumed", tweak_id)
		self:_check_sugar_high()
	end
end

function BuffEffectCandy:_check_sugar_high()
	if self._current_stage > #self._tweak_data.milestones then
		return
	end

	if self._candy_consumed < self._candy_target then
		return
	end

	self._current_stage = self._current_stage + 1
	self._previous_target = self._candy_target
	self._candy_target = self._tweak_data.milestones[self._current_stage]
	local already_checked = {}
	local effect = nil

	while not effect do
		local candidate_id = math.random(1, #self._inactive_effects)
		local candidate_effect = self._inactive_effects[candidate_id]

		if not self._active_effects[candidate_effect.name] or not already_checked[candidate_id] then
			local stage_available = candidate_effect.stage or 1
			local accept_candidate = stage_available <= self._current_stage
			accept_candidate = accept_candidate and not self._active_effects[candidate_effect.blocked_by]

			if accept_candidate and candidate_effect.chance then
				local chance_rolled = math.random() <= candidate_effect.chance / 100
				accept_candidate = accept_candidate and chance_rolled
			end

			if accept_candidate then
				effect = candidate_effect

				table.remove(self._inactive_effects, candidate_id)
			else
				already_checked[candidate_id] = true
			end
		end
	end

	self:_activate_sugar_high(effect)
	managers.network:session():send_to_peers_synched("sync_candy_sugar_high", effect.name)
end

function BuffEffectCandy:_activate_sugar_high(effect)
	local effect_id = managers.buff_effect:activate_effect(effect)
	self._active_effects[effect.name] = effect_id

	managers.experience:mission_xp_award("sugar_high_bonus")

	local possible_buffs = {}
	local chosen_buff = ""
	local player = managers.player:local_player()

	if alive(player) then
		table.insert(possible_buffs, "refill_ammo")

		if not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_WARCRIES_DISABLED) and not managers.warcry:meter_full() and not managers.warcry:active() then
			table.insert(possible_buffs, "refill_warcry")
		end

		if not player:character_damage():is_max_revives() then
			table.insert(possible_buffs, "refill_down")
		elseif player:character_damage():need_healing() then
			table.insert(possible_buffs, "refill_health")
		end

		chosen_buff = table.random(possible_buffs)

		if chosen_buff == "refill_warcry" then
			managers.warcry:fill_meter_by_value(1)
		elseif chosen_buff == "refill_ammo" then
			managers.player:replenish_player_weapons()
		else
			player:character_damage():recover_down()
		end
	elseif game_state_machine:current_state_name() == "ingame_waiting_for_respawn" then
		chosen_buff = "undead"

		game_state_machine:current_state():finish_trade()
	end

	local effects = {
		{
			icon = "ico_bonus",
			name = chosen_buff,
			desc_id = self._tweak_data.bonus_effects[chosen_buff]
		}
	}
	local malus_effect = {
		icon = "ico_malus",
		name = effect.name,
		desc_id = effect.desc_id,
		desc_params = effect.desc_params
	}

	table.insert(effects, malus_effect)
	managers.notification:add_notification({
		id = "candy_progress",
		progress = 1,
		initial_progress = 1,
		priority = 0,
		notification_type = HUDNotification.CANDY_PROGRESSION,
		sugar_high = {
			tier = self._current_stage - 1,
			buffs = effects
		}
	})
	managers.hud:set_tab_event_panel_data({
		progress = 1,
		tier = self._current_stage - 1,
		malus_effect = malus_effect
	})
end

function BuffEffectCandy:sync_candy_consumed(tweak_id)
	if not tweak_data.drop_loot[tweak_id] or not tweak_data.drop_loot[tweak_id].candy_value then
		return false
	end

	local initial_progress = (self._candy_consumed - self._previous_target) / (self._candy_target - self._previous_target)
	local value = tweak_data.drop_loot[tweak_id].candy_value
	self._candy_consumed = self._candy_consumed + value
	local progress = (self._candy_consumed - self._previous_target) / (self._candy_target - self._previous_target)

	managers.notification:add_notification({
		id = "candy_progress",
		priority = 0,
		notification_type = HUDNotification.CANDY_PROGRESSION,
		progress = progress,
		initial_progress = initial_progress
	})
	managers.hud:set_tab_event_panel_data({
		progress = progress
	})
	Application:info("[BuffEffectCandy:_on_candy_consumed] consumed", self._candy_consumed, value, initial_progress, progress)

	return true
end

function BuffEffectCandy:sync_candy_sugar_high(effect_name)
	self._current_stage = self._current_stage + 1
	self._previous_target = self._candy_target
	self._candy_target = self._tweak_data.milestones[self._current_stage]

	if self._active_effects[effect_name] then
		return
	end

	for id, effect in ipairs(self._inactive_effects) do
		if effect.name == effect_name then
			self:_activate_sugar_high(effect)
			table.remove(self._inactive_effects, id)

			break
		end
	end
end
