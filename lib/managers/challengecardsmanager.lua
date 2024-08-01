require("lib/managers/BuffEffectManager")

ChallengeCardsManager = ChallengeCardsManager or class()
ChallengeCardsManager.EVENT_NAME_SUGGEST_CARD = "received_suggest_card"
ChallengeCardsManager.EVENT_NAME_ACTIVATE_CARD = "received_activate_card"
ChallengeCardsManager.EVENT_NAME_DEACTIVATE_CARD = "received_deactivate_card"
ChallengeCardsManager.EVENT_NAME_REMOVE_CARD = "received_remove_card"
ChallengeCardsManager.EVENT_NAME_DROP_IN = "player_droped_in"
ChallengeCardsManager.EVENT_NAME_DROP_OUT = "player_droped_out"
ChallengeCardsManager.MAX_INVENTORY_COUNT = 1
ChallengeCardsManager.CARD_STATUS_NORMAL = "normal"
ChallengeCardsManager.CARD_STATUS_ACTIVE = "active"
ChallengeCardsManager.CARD_STATUS_FAILED = "failed"
ChallengeCardsManager.CARD_STATUS_SUCCESS = "success"
ChallengeCardsManager.INV_CAT_CHALCARD = "challenge_card"
ChallengeCardsManager.CARD_PASS_KEY_NAME = "empty"
ChallengeCardsManager.CARD_PASS_TEXTURE = "ui/main_menu/textures/cards_atlas"
ChallengeCardsManager.READYUP_INVENTORY_LOAD_FREQUENCY = 10

-- Lines 27-60
function ChallengeCardsManager:init()
	if not Global.challenge_cards_manager then
		Global.challenge_cards_manager = {}
	end

	self._active_card = nil
	self._suggested_cards = {}
	self._delay_start = false

	managers.system_event_listener:add_listener("challenge_cards_manager_drop_in", {
		CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_DROP_IN
	}, callback(self, self, "player_droped_in"))
	managers.system_event_listener:add_listener("challenge_cards_manager_drop_out", {
		CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_DROP_OUT
	}, callback(self, self, "player_droped_out"))
	managers.system_event_listener:add_listener("challenge_cards_manager_inventory_loaded", {
		CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_LOADED
	}, callback(self, self, "_steam_challenge_cards_inventory_loaded"))

	self._readyup_card_cache = {}
	self._readyup_inventory_load_frequency_counter = 0
end

-- Lines 80-97
function ChallengeCardsManager:update(t, dt)
	if self._delay_start == true then
		self:system_pre_start_raid()
	end

	if self._automatic_steam_inventory_refresh then
		if ChallengeCardsManager.READYUP_INVENTORY_LOAD_FREQUENCY < self._readyup_inventory_load_frequency_counter then
			managers.network.account:inventory_load()

			self._readyup_inventory_load_frequency_counter = 0
		end

		self._readyup_inventory_load_frequency_counter = self._readyup_inventory_load_frequency_counter + dt
	end
end

-- Lines 101-103
function ChallengeCardsManager:set_automatic_steam_inventory_refresh(flag)
	self._automatic_steam_inventory_refresh = flag
end

-- Lines 105-107
function ChallengeCardsManager:get_readyup_card_cache()
	return self._readyup_card_cache
end

-- Lines 109-111
function ChallengeCardsManager:set_readyup_card_cache(card_list)
	self._readyup_card_cache = card_list
end

-- Lines 114-161
function ChallengeCardsManager:_process_fresh_steam_inventory(params)
	if params.list then
		if #params.list ~= #self:get_readyup_card_cache() then
			Application:trace("[ChallengeCardsManager:_process_fresh_steam_inventory] new list has different number of elements ")
			self:set_readyup_card_cache(params.list)
			managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_PROCESSED, params)

			return
		end

		local cached_list = self:get_readyup_card_cache()

		table.sort(cached_list, function (a, b)
			return a.key_name < b.key_name
		end)
		table.sort(params.list, function (a, b)
			return a.key_name < b.key_name
		end)

		for card_index, card_data in ipairs(cached_list) do
			local cached_card_data = cached_list[card_index]
			local steam_card_data = params.list[card_index]

			if cached_card_data.key_name ~= steam_card_data.key_name then
				Application:trace("[ChallengeCardsManager:_process_fresh_steam_inventory] missmatch (Keyname) in cached and fresh list index ", card_index)
				self:set_readyup_card_cache(params.list)
				managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_PROCESSED, params)

				return
			end

			if cached_card_data.key_name == steam_card_data.key_name and cached_card_data.stack_amount ~= steam_card_data.stack_amount then
				Application:trace("[ChallengeCardsManager:_process_fresh_steam_inventory] missmatch (Amount) in cached and fresh list index ", card_index)
				self:set_readyup_card_cache(params.list)
				managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_PROCESSED, params)

				return
			end
		end
	end
end

-- Lines 163-180
function ChallengeCardsManager:get_cards_count_per_type(card_list)
	local raid_count = 0
	local operation_count = 0

	if card_list then
		for _, card_data in pairs(card_list) do
			if card_data.card_type == ChallengeCardsTweakData.CARD_TYPE_RAID then
				raid_count = raid_count + 1
			elseif card_data.card_type == ChallengeCardsTweakData.CARD_TYPE_OPERATION then
				operation_count = operation_count + 1
			end
		end
	end

	return raid_count, operation_count
end

-- Lines 184-186
function ChallengeCardsManager:set_temp_steam_loot(loot_list)
	self._temp_steam_loot = loot_list
end

-- Lines 188-190
function ChallengeCardsManager:get_temp_steam_loot()
	return self._temp_steam_loot
end

-- Lines 192-218
function ChallengeCardsManager:get_card_description(card_key_name)
	local positive_description = ""
	local negative_description = ""
	local card_data = self:get_challenge_card_data(card_key_name)

	if card_data then
		if card_data.positive_description then
			if card_data.positive_description.desc_params then
				positive_description = managers.localization:text(card_data.positive_description.desc_id, card_data.positive_description.desc_params)
			else
				positive_description = managers.localization:text(card_data.positive_description.desc_id)
			end
		end

		if card_data.negative_description then
			if card_data.negative_description.desc_params then
				negative_description = managers.localization:text(card_data.negative_description.desc_id, card_data.negative_description.desc_params)
			else
				negative_description = managers.localization:text(card_data.negative_description.desc_id)
			end
		end
	end

	return positive_description, negative_description
end

-- Lines 223-226
function ChallengeCardsManager:_steam_challenge_cards_inventory_loaded(params)
	self:_process_fresh_steam_inventory(params)
end

-- Lines 230-254
function ChallengeCardsManager:system_pre_start_raid(params)
	local _peer_still_connecting = false

	Application:trace("Starting raid")

	for _, p in pairs(managers.network:session()._peers) do
		if p._peer_connecting == true and not p._synced then
			_peer_still_connecting = true

			break
		end
	end

	if _peer_still_connecting == false then
		managers.raid_menu:close_all_menus()
		managers.raid_menu:open_menu("ready_up_menu")

		self._delay_start = false
	else
		self._delay_start = true
	end
end

-- Lines 259-262
function ChallengeCardsManager:player_droped_in(params)
end

-- Lines 264-277
function ChallengeCardsManager:player_droped_out(params)
	if self._suggested_cards and self._suggested_cards[params._id] then
		self._suggested_cards[params._id] = nil
	end

	if self._active_card and self._active_card.peer_id == params._id and self._active_card.spent then
		self:remove_active_challenge_card()
	end

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED)
end

-- Lines 281-283
function ChallengeCardsManager:get_all_challenge_cards_indexed()
	return tweak_data.challenge_cards:get_all_cards_indexed()
end

-- Lines 285-287
function ChallengeCardsManager:get_challenge_card_data(challenge_card_key)
	return tweak_data.challenge_cards:get_card_by_key_name(challenge_card_key)
end

-- Lines 289-291
function ChallengeCardsManager:get_active_card()
	return self._active_card
end

-- Lines 293-313
function ChallengeCardsManager:set_active_card(card)
	self._active_card = card

	if self._active_card and self._active_card.status == ChallengeCardsManager.CARD_STATUS_ACTIVE then
		for _, effect in pairs(self._active_card.effects) do
			effect.challenge_card_key = self._active_card.key_name
			local effect_id = managers.buff_effect:activate_effect(effect)
			effect.effect_id = effect_id
		end
	end

	if Network:is_server() then
		Application:trace("[ChallengeCardsManager:set_active_card] server only", inspect(card))

		local card_key = card.key_name
		local locked = card.locked_suggestion or true
		local card_status = card.status or ChallengeCardsManager.CARD_STATUS_ACTIVE

		managers.network:session():send_to_peers_synched("sync_active_challenge_card", card_key, locked, card_status)
	end
end

-- Lines 315-321
function ChallengeCardsManager:sync_active_challenge_card(card_key, locked, card_status)
	local card = deep_clone(tweak_data.challenge_cards:get_card_by_key_name(card_key))
	card.locked_suggestion = locked
	card.status = card_status

	self:set_active_card(card)
end

-- Lines 323-328
function ChallengeCardsManager:get_suggested_cards()
	if not self._suggested_cards then
		self._suggested_cards = {}
	end

	return self._suggested_cards
end

-- Lines 330-348
function ChallengeCardsManager:did_everyone_locked_sugested_card()
	local result = true
	local suggested_cards = self:get_suggested_cards()

	if suggested_cards then
		for peer_id, _ in pairs(managers.network:session():all_peers()) do
			local card_data = suggested_cards[peer_id]

			if not card_data then
				result = false
			elseif card_data and not card_data.locked_suggestion then
				result = false
			end
		end
	else
		result = false
	end

	return result
end

-- Lines 350-355
function ChallengeCardsManager:get_active_card_status()
	if not self._active_card then
		return nil
	end

	return self._active_card.status
end

-- Lines 358-363
function ChallengeCardsManager:mark_active_card_as_spent()
	if self._active_card then
		self._active_card.spent = true
	end
end

-- Lines 368-382
function ChallengeCardsManager:select_challenge_card(peer_id)
	if peer_id then
		self._active_card = self:get_suggested_cards()[peer_id]

		if self._active_card then
			self._active_card.status = ChallengeCardsManager.CARD_STATUS_NORMAL
		end
	else
		self._active_card = nil
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("select_challenge_card", peer_id)
	end
end

-- Lines 385-390
function ChallengeCardsManager:activate_challenge_card()
	if Network:is_server() then
		self:_activate_challenge_card()
		self:sync_activate_challenge_card()
	end
end

-- Lines 392-395
function ChallengeCardsManager:sync_activate_challenge_card()
	managers.network:session():send_to_peers_synched("sync_activate_challenge_card")
end

-- Lines 397-432
function ChallengeCardsManager:_activate_challenge_card()
	Application:debug("[ChallengeCardsManager:_activate_challenge_card]")

	managers.challenge_cards._suggested_cards = nil
	managers.challenge_cards._temp_steam_loot = nil

	if not self._active_card or self._active_card and self._active_card.status ~= ChallengeCardsManager.CARD_STATUS_NORMAL then
		return
	end

	if self._active_card.key_name == ChallengeCardsManager.CARD_PASS_KEY_NAME then
		return
	end

	self._active_card.status = ChallengeCardsManager.CARD_STATUS_ACTIVE

	for _, effect in pairs(self._active_card.effects) do
		effect.challenge_card_key = self._active_card.key_name
		local effect_id = managers.buff_effect:activate_effect(effect)
		effect.effect_id = effect_id
	end

	if self._active_card.peer_id == managers.network:session():local_peer()._id then
		self:consume_steam_challenge_card(self._active_card.steam_instance_id)
	end

	if Network:is_server() then
		managers.network.matchmake:set_challenge_card_info()
	end
end

-- Lines 434-450
function ChallengeCardsManager:consume_steam_challenge_card(steam_instance_id)
	Application:trace("[ChallengeCardsManager:consume_steam_challenge_card] steam_instance_id ", steam_instance_id)

	if not steam_instance_id or steam_instance_id == 0 then
		Application:error("[ChallengeCardsManager:consume_steam_challenge_card] COULD NOT CONSUME steam_instance_id ", steam_instance_id)

		return
	end

	local consume_status = managers.network.account:inventory_remove(steam_instance_id)
end

-- Lines 455-472
function ChallengeCardsManager:set_successfull_raid_end()
	if not self._active_card then
		return
	end

	self._active_card.status = ChallengeCardsManager.CARD_STATUS_SUCCESS

	if self._active_card.effects then
		for _, effect in pairs(self._active_card.effects) do
			managers.buff_effect:deactivate_special_effect_and_timer(effect.effect_id)
		end
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("set_successfull_raid_end")
	end
end

-- Lines 475-491
function ChallengeCardsManager:deactivate_active_challenge_card()
	if self._active_card then
		if self._active_card.effects then
			for _, effect in pairs(self._active_card.effects) do
				managers.buff_effect:deactivate_effect(effect.effect_id)
			end
		end

		self._active_card.status = ChallengeCardsManager.CARD_STATUS_FAILED
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("deactivate_active_challenge_card")
	end
end

-- Lines 493-503
function ChallengeCardsManager:remove_active_challenge_card()
	if not self._active_card then
		return
	end

	self:deactivate_active_effects()

	self._active_card = nil
end

-- Lines 510-518
function ChallengeCardsManager:deactivate_active_effects()
	if self._active_card and self._active_card.effects then
		for _, effect in pairs(self._active_card.effects) do
			managers.buff_effect:deactivate_effect(effect.effect_id)
		end
	end
end

-- Lines 520-532
function ChallengeCardsManager:suggest_challenge_card(challenge_card_key, steam_instance_id)
	Application:trace("[ChallengeCardsManager:suggest_challenge_card] challenge_card_key steam_instance_id ", challenge_card_key, steam_instance_id)

	local local_peer = managers.network:session():local_peer()
	local card = tweak_data.challenge_cards:get_card_by_key_name(challenge_card_key)
	card.steam_instance_id = steam_instance_id
	self._suggested_cards[local_peer._id] = card

	managers.network:session():send_to_peers_synched("send_suggested_card_to_peers", challenge_card_key, local_peer._id, steam_instance_id)
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED, nil)
end

-- Lines 534-542
function ChallengeCardsManager:sync_suggested_card_from_peer(challenge_card_key, peer_id, steam_instance_id)
	Application:trace("[ChallengeCardsManager:sync_suggested_card_from_peer] challenge_card_key, peer_id, steam_instance_id ", challenge_card_key, peer_id, steam_instance_id)

	local card = tweak_data.challenge_cards:get_card_by_key_name(challenge_card_key)
	card.steam_instance_id = steam_instance_id
	self._suggested_cards[peer_id] = card

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED, nil)
end

-- Lines 544-563
function ChallengeCardsManager:remove_suggested_challenge_card()
	local local_peer = managers.network:session():local_peer()
	local remove_suggested_card = self._suggested_cards[local_peer._id]

	if not remove_suggested_card then
		return
	end

	local active_card = self:get_active_card()

	if active_card and remove_suggested_card.key_name == active_card.key_name then
		self:remove_active_challenge_card()
	end

	self._suggested_cards[local_peer._id] = nil

	managers.network:session():send_to_peers_synched("send_remove_suggested_card_to_peers", local_peer._id)
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED, nil)
end

-- Lines 565-578
function ChallengeCardsManager:sync_remove_suggested_card_from_peer(peer_id)
	local remove_suggested_card = self._suggested_cards[peer_id]
	local active_card = self:get_active_card()

	if active_card and remove_suggested_card.key_name == active_card.key_name then
		self:remove_active_challenge_card()
	end

	self._suggested_cards[peer_id] = nil

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED, nil)
end

-- Lines 580-586
function ChallengeCardsManager:clear_suggested_cards()
	self._suggested_cards = {}

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("clear_suggested_cards")
	end
end

-- Lines 588-602
function ChallengeCardsManager:toggle_lock_suggested_challenge_card()
	local local_peer = managers.network:session():local_peer()
	local suggested_card = self._suggested_cards[local_peer._id]

	if not suggested_card then
		return
	end

	suggested_card.locked_suggestion = not suggested_card.locked_suggestion

	managers.network:session():send_to_peers_synched("send_toggle_lock_suggested_card_to_peers", local_peer._id)
	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED, nil)
end

-- Lines 604-611
function ChallengeCardsManager:sync_toggle_lock_suggested_challenge_card(peer_id)
	local suggested_card = self._suggested_cards[peer_id]
	suggested_card.locked_suggestion = not suggested_card.locked_suggestion

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED, nil)
end

-- Lines 618-624
function ChallengeCardsManager:on_restart_to_camp()
	self:_on_restart_to_camp()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_challenge_cards_on_restart_to_camp")
	end
end

-- Lines 626-628
function ChallengeCardsManager:sync_challenge_cards_on_restart_to_camp()
	self:_on_restart_to_camp()
end

-- Lines 630-637
function ChallengeCardsManager:_on_restart_to_camp()
	self:remove_active_challenge_card()

	if Network:is_server() then
		managers.network.matchmake:set_challenge_card_info()
	end
end

-- Lines 641-657
function ChallengeCardsManager:card_failed_warning(challenge_card_key, effect_id, peer_id)
	local notification_data = {
		priority = 1,
		duration = 10,
		id = challenge_card_key,
		notification_type = HUDNotification.CARD_FAIL,
		card = challenge_card_key,
		reaction = {
			callback = managers.hud.show_stats_screen,
			callback_self = managers.hud
		}
	}

	managers.notification:add_notification(notification_data)

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("card_failed_warning", challenge_card_key, effect_id, peer_id)
	end
end

-- Lines 660-669
function ChallengeCardsManager:save_dropin(data)
	local state = {
		active_card = self._active_card,
		suggested_cards = self._suggested_cards
	}
	data.ChallengeCardsManager = state
end

-- Lines 672-680
function ChallengeCardsManager:load_dropin(data)
	local state = data.ChallengeCardsManager

	if state then
		self._active_card = state.active_card
		self._suggested_cards = state.suggested_cards
	end
end

-- Lines 685-694
function ChallengeCardsManager:get_victory_xp_amount()
	local result = 0

	if self._active_card and self._active_card.status == ChallengeCardsManager.CARD_STATUS_SUCCESS then
		local card = tweak_data.challenge_cards.cards[self._active_card[ChallengeCardsTweakData.KEY_NAME_FIELD]]
		result = card.bonus_xp or 0
	end

	return result
end

-- Lines 696-704
function ChallengeCardsManager:get_victory_xp_multiplier()
	local result = 1

	if self._active_card and self._active_card.status == ChallengeCardsManager.CARD_STATUS_SUCCESS then
		result = self._active_card.bonus_xp_multiplier or 1
	end

	return result
end

-- Lines 708-718
function ChallengeCardsManager:get_card_xp_amount(card_key_name)
	local result = 0
	local card_data = tweak_data.challenge_cards:get_card_by_key_name(card_key_name)

	if card_data then
		result = card_data.bonus_xp or 0
	end

	return result
end

-- Lines 720-730
function ChallengeCardsManager:get_card_xp_multiplier(card_key_name)
	local result = 0
	local card_data = tweak_data.challenge_cards:get_card_by_key_name(card_key_name)

	if card_data then
		result = card_data.bonus_xp_multiplier or 0
	end

	return result
end

-- Lines 732-751
function ChallengeCardsManager:get_card_xp_label(card_key_name, hide_xp_suffix)
	local result = ""
	local card_data = tweak_data.challenge_cards:get_card_by_key_name(card_key_name)

	if not card_data then
		return result
	end

	if card_data.bonus_xp and card_data.bonus_xp > 0 then
		result = "+" .. card_data.bonus_xp
	elseif card_data.bonus_xp_multiplier and card_data.bonus_xp_multiplier > 0 then
		result = "x" .. string.format("%.2f", card_data.bonus_xp_multiplier)
	end

	if not hide_xp_suffix and not result == "" then
		result = result .. "xp"
	end

	return result
end

-- Lines 755-765
function ChallengeCardsManager:get_loot_drop_group(card_name)
	if not card_name then
		return
	end

	Application:debug("[ChallengeCardsManager:get_loot_drop_group]", card_name)

	local card_data = tweak_data.challenge_cards:get_card_by_key_name(card_name)
	local has_group = not not card_data.loot_drop_group

	return has_group and LootDropTweakData.LOOT_GROUP_PREFIX .. card_data.loot_drop_group or nil
end

-- Lines 768-809
function ChallengeCardsManager:get_cards_stacking_texture(card_data)
	if card_data and card_data.steam_instances and not card_data.card_back then
		local stack_amount = 0

		for steam_inst_id, steam_data in pairs(card_data.steam_instances) do
			stack_amount = stack_amount + (steam_data.stack_amount or 1)
		end

		if card_data.card_category == ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER and stack_amount == 2 then
			return tweak_data.challenge_cards.challenge_card_stackable_booster_2_texture_path, tweak_data.challenge_cards.challenge_card_stackable_booster_2_texture_rect
		elseif card_data.card_category == ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER and stack_amount > 2 then
			return tweak_data.challenge_cards.challenge_card_stackable_booster_3_texture_path, tweak_data.challenge_cards.challenge_card_stackable_booster_3_texture_rect
		elseif card_data.card_category == ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD and stack_amount == 2 then
			return tweak_data.challenge_cards.challenge_card_stackable_2_texture_path, tweak_data.challenge_cards.challenge_card_stackable_2_texture_rect
		elseif card_data.card_category == ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD and stack_amount > 2 then
			return tweak_data.challenge_cards.challenge_card_stackable_3_texture_path, tweak_data.challenge_cards.challenge_card_stackable_3_texture_rect
		end
	end

	return nil, nil
end

-- Lines 811-823
function ChallengeCardsManager:get_cards_back_texture(card_data)
	if card_data then
		if card_data.card_back then
			return tweak_data.challenge_cards[card_data.card_back].texture, tweak_data.challenge_cards[card_data.card_back].texture_rect
		elseif card_data.card_category == ChallengeCardsTweakData.CARD_CATEGORY_BOOSTER then
			return tweak_data.challenge_cards.card_back_boosters.texture, tweak_data.challenge_cards.card_back_boosters.texture_rect
		else
			return tweak_data.challenge_cards.card_back_challenge_cards.texture, tweak_data.challenge_cards.card_back_challenge_cards.texture_rect
		end
	end

	return nil, nil
end

-- Lines 862-869
function ChallengeCardsManager:inventory_alter_stacks(source_steam_instance_id, destination_steam_instance_id, amount)
end

-- Lines 871-874
function ChallengeCardsManager:start_inventory_fix_all_stacks()
end

-- Lines 876-908
function ChallengeCardsManager:inventory_fix_all_stacks(error, list)
end

-- Lines 910-914
function ChallengeCardsManager:inventory_reward_unlock(instance_id_1, instance_id_2, reward_item_def_id)
end

-- Lines 916-930
function ChallengeCardsManager:_clbk_inventory_reward_unlock(error, items_new, items_removed)
end
