LootDropManager = LootDropManager or class()
LootDropManager.EVENT_PEER_LOOT_RECEIVED = "peer_loot_received"
LootDropManager.LOOT_VALUE_TYPE_SMALL = "small"
LootDropManager.LOOT_VALUE_TYPE_MEDIUM = "medium"
LootDropManager.LOOT_VALUE_TYPE_BIG = "big"

-- Lines 11-20
function LootDropManager:init()
	self:_setup()

	self._listener_holder = EventListenerHolder:new()
	self._loot_for_peers = {}

	managers.system_event_listener:add_listener("loot_drop_manager_drop_out", {
		CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_DROP_OUT
	}, callback(self, self, "player_droped_out"))
	self:reset_loot_value_counters()
end

-- Lines 24-26
function LootDropManager:_call_listeners(event, params)
	self._listener_holder:call(event, params)
end

-- Lines 29-31
function LootDropManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

-- Lines 33-35
function LootDropManager:remove_listener(key)
	self._listener_holder:remove(key)
end

-- Lines 39-47
function LootDropManager:player_droped_out(params)
	local peer_id = params._id

	for i, drop in ipairs(self._loot_for_peers) do
		if drop.peer_id == peer_id then
			table.remove(self._loot_for_peers, i)

			break
		end
	end
end

-- Lines 49-54
function LootDropManager:_setup()
	if not Global.lootdrop_manager then
		Global.lootdrop_manager = {}
	end

	self._global = Global.lootdrop_manager
end

-- Lines 56-75
function LootDropManager:produce_consumable_mission_drop()
	local gold_bars_earned = 0
	local loot_secured = managers.loot:get_secured()

	while loot_secured do
		local loot_tweak_data = tweak_data.carry[loot_secured.carry_id]

		if loot_tweak_data and loot_tweak_data.value_in_gold then
			gold_bars_earned = gold_bars_earned + loot_tweak_data.value_in_gold
		end

		loot_secured = managers.loot:get_secured()
	end

	local drop = {
		reward_type = LootDropTweakData.REWARD_GOLD_BARS,
		gold_bars_min = gold_bars_earned,
		gold_bars_max = gold_bars_earned
	}

	return drop
end

-- Lines 77-88
function LootDropManager:produce_loot_drop(loot_value, use_reroll_drop_tables, forced_loot_group)
	local loot_group = self:_get_loot_group(loot_value, use_reroll_drop_tables, forced_loot_group)
	local loot_category = self:get_random_item_weighted(loot_group)
	local loot = self:get_random_item_weighted(loot_category)

	return loot
end

-- Lines 91-110
function LootDropManager:_get_loot_group(loot_value, use_reroll_drop_tables, forced_loot_group)
	local loot_group = nil
	local data_source = tweak_data.lootdrop.loot_groups

	if forced_loot_group then
		return data_source[forced_loot_group]
	end

	if use_reroll_drop_tables then
		data_source = tweak_data.lootdrop.loot_groups_doubles_fallback
	end

	for _, group in pairs(data_source) do
		if group.min_loot_value < loot_value and loot_value <= group.max_loot_value then
			loot_group = group

			break
		end
	end

	return loot_group
end

-- Lines 113-130
function LootDropManager:get_random_item_weighted(collection)
	local total = 0

	for _, item_entry in ipairs(collection) do
		total = total + item_entry.chance
	end

	local item = nil
	local value = math.rand(total)

	for _, item_entry in ipairs(collection) do
		value = value - item_entry.chance

		if value <= 0 then
			item = item_entry.value

			break
		end
	end

	return item
end

-- Lines 133-138
function LootDropManager:_get_random_item(collection)
	local num_items = #collection
	local index = math.random(#collection)
	local item = collection[index]

	return item
end

-- Lines 141-143
function LootDropManager:get_dropped_loot()
	return self._dropped_loot
end

-- Lines 146-207
function LootDropManager:give_loot_to_player(loot_value, use_reroll_drop_tables, forced_loot_group)
	self._loot_value = loot_value
	local need_reroll = false
	local drop = nil

	if game_state_machine._current_state._current_job_data and game_state_machine._current_state._current_job_data.consumable then
		drop = self:produce_consumable_mission_drop()
	else
		drop = self:produce_loot_drop(self._loot_value, use_reroll_drop_tables, forced_loot_group)
	end

	self._dropped_loot = drop

	Application:trace("[LootDropManager:give_loot_to_player]        loot drop 1: ", inspect(self._dropped_loot))

	if drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
		if not self._cards_already_rejected and not managers.raid_menu:is_offline_mode() then
			managers.network.account:inventory_reward(drop.pack_type, callback(self, self, "card_drop_callback"))

			self._card_drop_pack_type = drop.pack_type

			managers.network.account:inventory_load()

			return
		end

		Application:trace(" **** REROLLING CARDS **** ")
		self:give_loot_to_player(self._loot_value, false)

		return
	elseif drop.reward_type == LootDropTweakData.REWARD_XP then
		self:_give_xp_to_player(drop)
	elseif drop.reward_type == LootDropTweakData.REWARD_CUSTOMIZATION then
		local result = self:_give_character_customization_to_player(drop)
		need_reroll = not result
	elseif drop.reward_type == LootDropTweakData.REWARD_WEAPON_POINT then
		self:_give_weapon_point_to_player(drop)
	elseif drop.reward_type == LootDropTweakData.REWARD_MELEE_WEAPON then
		local result = self:_give_melee_weapon_to_player(drop)
		need_reroll = not result
	elseif drop.reward_type == LootDropTweakData.REWARD_GOLD_BARS then
		self:_give_gold_bars_to_player(drop)
	elseif drop.reward_type == LootDropTweakData.REWARD_HALLOWEEN_2017 then
		local result = self:_give_halloween_2017_weapon_to_player(drop)
		need_reroll = not result
	end

	if need_reroll then
		Application:trace(" **** REROLLING **** ")
		self:give_loot_to_player(self._loot_value, true)

		return
	end

	Application:trace("[LootDropManager:give_loot_to_player]        loot drop 2: ", inspect(self._dropped_loot))
	self:on_loot_dropped_for_player()
end

-- Lines 209-262
function LootDropManager:debug_drop_card_pack()
	local loot_list = {
		{
			bonus = false,
			entry = "op_war_weary",
			instance_id = 1.5012326827715203e+18,
			category = "challenge_card",
			def_id = 150002,
			amount = 1
		},
		{
			bonus = false,
			entry = "ra_b_walk_it_off",
			instance_id = 1.5012326827715203e+18,
			category = "challenge_card",
			def_id = 100005,
			amount = 1
		},
		{
			bonus = false,
			entry = "op_b_recycle_for_victory",
			instance_id = 1.5012326827715203e+18,
			category = "challenge_card",
			def_id = 100011,
			amount = 1
		},
		{
			bonus = false,
			entry = "ra_helmet_shortage",
			instance_id = 1.5012326827715203e+18,
			category = "challenge_card",
			def_id = 100003,
			amount = 1
		},
		{
			bonus = false,
			entry = "ra_no_second_chances",
			instance_id = 1.5012326827715203e+18,
			category = "challenge_card",
			def_id = 100008,
			amount = 1
		}
	}

	managers.challenge_cards:set_temp_steam_loot(loot_list)
	self:on_loot_dropped_for_player()
	managers.network:session():send_to_peers_synched("sync_loot_to_peers", LootDropTweakData.REWARD_CARD_PACK, "", self._card_drop_pack_type, managers.network:session():local_peer():id())

	self._card_drop_pack_type = nil
end

-- Lines 264-276
function LootDropManager:card_drop_callback(error, loot_list)
	if not loot_list then
		managers.challenge_cards:set_temp_steam_loot(nil)

		self._cards_already_rejected = true
		self._card_drop_pack_type = nil

		self:give_loot_to_player(self._loot_value)
	else
		managers.challenge_cards:set_temp_steam_loot(loot_list)
		self:on_loot_dropped_for_player()
		managers.network:session():send_to_peers_synched("sync_loot_to_peers", LootDropTweakData.REWARD_CARD_PACK, "", self._card_drop_pack_type, managers.network:session():local_peer():id())

		self._card_drop_pack_type = nil
	end
end

-- Lines 278-282
function LootDropManager:on_loot_dropped_for_player()
	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
	game_state_machine:current_state():on_loot_dropped_for_player()
end

-- Lines 284-301
function LootDropManager:redeem_dropped_loot_for_xp()
	local drop = self._dropped_loot

	if drop.reward_type == LootDropTweakData.REWARD_CUSTOMIZATION then
		managers.character_customization:remove_character_customization_from_inventory(drop.character_customization_key)
		managers.experience:add_loot_redeemed_xp(drop.character_customization.redeem_xp)
	elseif drop.reward_type == LootDropTweakData.REWARD_WEAPON_POINT then
		managers.weapon_skills:remove_weapon_skill_points_as_drops(1)
		managers.experience:add_loot_redeemed_xp(drop.redeemed_xp)
	elseif drop.reward_type == LootDropTweakData.REWARD_MELEE_WEAPON then
		managers.weapon_inventory:remove_melee_weapon_as_drop(drop)
		managers.experience:add_loot_redeemed_xp(drop.redeemed_xp)
	elseif drop.reward_type == LootDropTweakData.REWARD_HALLOWEEN_2017 then
		managers.weapon_inventory:remove_melee_weapon_as_drop(drop)
		managers.experience:add_loot_redeemed_xp(drop.redeemed_xp)
	end
end

-- Lines 304-308
function LootDropManager:_give_xp_to_player(drop)
	drop.awarded_xp = math.round(math.rand(drop.xp_min, drop.xp_max))

	managers.experience:set_loot_bonus_xp(drop.awarded_xp)
	managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, "", drop.awarded_xp, managers.network:session():local_peer():id())
end

-- Lines 311-332
function LootDropManager:_give_character_customization_to_player(drop)
	local candidate_customizations = tweak_data.character_customization:get_reward_loot_by_rarity(drop.rarity)
	drop.character_customization_key = self:_get_random_item(candidate_customizations)
	drop.character_customization = tweak_data.character_customization.customizations[drop.character_customization_key]

	if not managers.character_customization:is_character_customization_owned(drop.character_customization_key) then
		drop.redeemed_xp = 0
		drop.duplicate = false

		managers.character_customization:add_character_customization_to_inventory(drop.character_customization_key)
		managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, drop.character_customization_key, drop.redeemed_xp, managers.network:session():local_peer():id())

		return true
	else
		return false
	end
end

-- Lines 334-338
function LootDropManager:_give_weapon_point_to_player(drop)
	managers.weapon_skills:add_weapon_skill_points_as_drops(1)

	drop.redeemed_xp = tweak_data.weapon_skills.weapon_point_reedemed_xp

	managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, "", drop.reedemed_xp, managers.network:session():local_peer():id())
end

-- Lines 340-359
function LootDropManager:_give_halloween_2017_weapon_to_player(drop)
	local candidate_melee_weapon = clone(managers.weapon_inventory:get_weapon_data(WeaponInventoryManager.CATEGORY_NAME_MELEE, drop.weapon_id))

	if not managers.weapon_inventory:is_melee_weapon_owned(candidate_melee_weapon.weapon_id) then
		drop.weapon_id = candidate_melee_weapon.weapon_id
		drop.redeemed_xp = candidate_melee_weapon.redeemed_xp
		drop.duplicate = false

		managers.weapon_inventory:add_melee_weapon_as_drop(drop)
		managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, drop.weapon_id, drop.reedemed_xp, managers.network:session():local_peer():id())

		return true
	else
		return false
	end
end

-- Lines 361-381
function LootDropManager:_give_melee_weapon_to_player(drop)
	Application:trace("[LootDropManager:_give_melee_weapon_to_player] drop 1: ", inspect(drop))

	local candidate_melee_weapon = managers.weapon_inventory:get_melee_weapon_loot_drop_candidates()
	local melee_weapon_drop = self:_get_random_item(candidate_melee_weapon)

	if not managers.weapon_inventory:is_melee_weapon_owned(melee_weapon_drop.weapon_id) then
		drop.weapon_id = melee_weapon_drop.weapon_id
		drop.redeemed_xp = melee_weapon_drop.redeemed_xp
		drop.duplicate = false

		managers.weapon_inventory:add_melee_weapon_as_drop(drop)
		managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, drop.weapon_id, drop.reedemed_xp, managers.network:session():local_peer():id())

		return true
	else
		return false
	end
end

-- Lines 383-388
function LootDropManager:_give_gold_bars_to_player(drop)
	drop.awarded_gold_bars = math.round(math.rand(drop.gold_bars_min, drop.gold_bars_max))

	managers.gold_economy:add_gold(drop.awarded_gold_bars)
	managers.gold_economy:layout_camp()
	managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, "", drop.awarded_gold_bars, managers.network:session():local_peer():id())
end

-- Lines 390-419
function LootDropManager:on_loot_dropped_for_peer(loot_type, name, value, peer_id)
	local drop = {
		peer_id = peer_id,
		peer_name = managers.network:session():peer(peer_id) and managers.network:session():peer(peer_id):name() or "",
		reward_type = loot_type
	}

	if drop.reward_type == LootDropTweakData.REWARD_XP then
		drop.awarded_xp = value
	elseif drop.reward_type == LootDropTweakData.REWARD_CUSTOMIZATION then
		drop.character_customization_key = name
		drop.character_customization = tweak_data.character_customization.customizations[name]
		drop.redeemed_xp = value
	elseif drop.reward_type == LootDropTweakData.REWARD_WEAPON_POINT then
		drop.redeemed_xp = value
	elseif drop.reward_type == LootDropTweakData.REWARD_MELEE_WEAPON then
		drop.redeemed_xp = value
		drop.weapon_id = name
	elseif drop.reward_type == LootDropTweakData.REWARD_GOLD_BARS then
		drop.awarded_gold_bars = value
	elseif drop.reward_type == LootDropTweakData.REWARD_CARD_PACK then
		drop.pack_type = value
	elseif drop.reward_type == LootDropTweakData.REWARD_HALLOWEEN_2017 then
		drop.redeemed_xp = value
		drop.weapon_id = name
	end

	table.insert(self._loot_for_peers, drop)
	self:_call_listeners(LootDropManager.EVENT_PEER_LOOT_RECEIVED, drop)
end

-- Lines 421-423
function LootDropManager:get_loot_for_peers()
	return self._loot_for_peers
end

-- Lines 425-431
function LootDropManager:clear_dropped_loot()
	self._dropped_loot = nil
	self._loot_for_peers = {}
	self._cards_already_rejected = false
	self._loot_value = nil
	self._card_drop_pack_type = nil
end

-- Lines 437-457
function LootDropManager:register_loot(unit, value_type, world_id)
	local value = nil

	if value_type == LootDropManager.LOOT_VALUE_TYPE_SMALL then
		value = LootDropTweakData.LOOT_VALUE_TYPE_SMALL_AMOUNT
	elseif value_type == LootDropManager.LOOT_VALUE_TYPE_MEDIUM then
		value = LootDropTweakData.LOOT_VALUE_TYPE_MEDIUM_AMOUNT
	elseif value_type == LootDropManager.LOOT_VALUE_TYPE_BIG then
		value = LootDropTweakData.LOOT_VALUE_TYPE_BIG_AMOUNT
	else
		debug_pause("[LootDropManager:register_loot] Unknown loot value size!", value_type)

		return
	end

	unit:loot_drop():set_value(value)

	self._registered_loot_units[world_id] = self._registered_loot_units[world_id] or {}
	local loot_data = {
		unit = unit,
		value = value,
		world_id = world_id
	}

	table.insert(self._registered_loot_units[world_id], loot_data)

	self._loot_registered_last_leg = self._loot_registered_last_leg + value
end

-- Lines 459-477
function LootDropManager:remove_loot_from_level(world_id)
	if not Network:is_server() then
		return
	end

	self._registered_loot_units[world_id] = self._registered_loot_units[world_id] or {}

	for _, loot_data in ipairs(self._registered_loot_units[world_id]) do
		loot_data.unit:set_slot(0)

		loot_data.deleted = true
	end

	self._registered_loot_units[world_id] = {}
	self._active_loot_units = {}
end

-- Lines 481-546
function LootDropManager:plant_loot_on_level(world_id, total_value, job_id)
	if not Network:is_server() or Application:editor() then
		return
	end

	print("[LootDropManager:plant_loot_on_level()] Planting loot on level, loot value (value, mission):", total_value, job_id)

	self._loot_spawned_current_leg = 0
	self._registered_loot_units[world_id] = self._registered_loot_units[world_id] or {}
	self._active_loot_units = {}

	if #self._registered_loot_units[world_id] == 0 then
		print("[LootDropManager:plant_loot_on_level()] no loot units registered on the level")

		return
	end

	local used_all = true

	math.shuffle(self._registered_loot_units[world_id])

	for _, loot_data in ipairs(self._registered_loot_units[world_id]) do
		if not alive(loot_data.unit) then
			loot_data.deleted = true
		else
			local should_remove_loot_unit = total_value <= self._loot_spawned_current_leg

			if should_remove_loot_unit then
				loot_data.unit:set_slot(0)

				loot_data.deleted = true
			else
				self._loot_spawned_current_leg = self._loot_spawned_current_leg + loot_data.value

				table.insert(self._active_loot_units, loot_data.unit)
			end
		end
	end

	if self._loot_spawned_current_leg < total_value then
		print("[LootDropManager:plant_loot_on_level()] All loot units on level used, level loot cap still not reached (curr_value, total_value):", self._loot_spawned_current_leg, total_value)
	else
		print("[LootDropManager:plant_loot_on_level()] Loot value placed on level:", self._loot_spawned_current_leg)
	end

	self._loot_spawned_total = self._loot_spawned_total + self._loot_spawned_current_leg
	self._picked_up_total = self._picked_up_total + self._picked_up_current_leg

	managers.network:session():send_to_peers_synched("sync_spawned_loot_values", managers.lootdrop:loot_spawned_current_leg(), managers.lootdrop:loot_spawned_total())

	for _, loot_data in ipairs(self._registered_loot_units[world_id]) do
		if not loot_data.deleted then
			managers.network:session():send_to_peers_synched("sync_loot_value", loot_data.unit, loot_data.value)
		end
	end

	self._picked_up_current_leg = 0
	self._registered_loot_units[world_id] = {}

	managers.hud:set_loot_picked_up(self._picked_up_current_leg)
	managers.hud:set_loot_total(self._loot_spawned_current_leg)
end

-- Lines 548-565
function LootDropManager:reset_loot_value_counters()
	self._registered_loot_units = {}
	self._active_loot_units = {}
	self._loot_registered_last_leg = 0
	self._picked_up_total = 0
	self._picked_up_current_leg = 0
	self._loot_spawned_total = 0
	self._loot_spawned_current_leg = 0

	if managers.hud then
		managers.hud:set_loot_picked_up(self._picked_up_current_leg)
		managers.hud:set_loot_total(self._loot_spawned_current_leg)
	end
end

-- Lines 567-576
function LootDropManager:current_loot_pickup_ratio()
	local result = nil

	if self._loot_spawned_current_leg == 0 then
		result = 0
	else
		result = self._picked_up_current_leg / self._loot_spawned_current_leg * 100
		result = string.format("%.1f", result)
	end

	return result
end

-- Lines 578-586
function LootDropManager:pickup_loot(value, unit)
	self._picked_up_current_leg = self._picked_up_current_leg + value

	managers.hud:set_loot_picked_up(self._picked_up_current_leg)
end

-- Lines 588-591
function LootDropManager:on_simulation_ended()
	Application:trace("LootDropManager:on_simulation_ended()")
	self:reset_loot_value_counters()
end

-- Lines 673-680
function LootDropManager:reset()
	Global.lootdrop_manager = nil

	self:_setup()
end

-- Lines 682-684
function LootDropManager:picked_up_current_leg()
	return self._picked_up_current_leg
end

-- Lines 686-688
function LootDropManager:picked_up_total()
	return self._picked_up_total
end

-- Lines 690-692
function LootDropManager:loot_spawned_total()
	return self._loot_spawned_total
end

-- Lines 694-696
function LootDropManager:loot_spawned_current_leg()
	return self._loot_spawned_current_leg
end

-- Lines 698-701
function LootDropManager:set_picked_up_current_leg(picked_up_current_leg)
	self._picked_up_current_leg = picked_up_current_leg

	managers.hud:set_loot_picked_up(self._picked_up_current_leg)
end

-- Lines 703-705
function LootDropManager:set_picked_up_total(picked_up_total)
	self._picked_up_total = picked_up_total
end

-- Lines 707-709
function LootDropManager:set_loot_spawned_total(loot_spawned_total)
	self._loot_spawned_total = loot_spawned_total
end

-- Lines 711-714
function LootDropManager:set_loot_spawned_current_leg(loot_spawned_current_leg)
	self._loot_spawned_current_leg = loot_spawned_current_leg

	managers.hud:set_loot_total(self._loot_spawned_current_leg)
end

-- Lines 717-724
function LootDropManager:sync_load(data)
	local state = data.LootDropManager
	self._picked_up_total = state.picked_up_total
	self._picked_up_current_leg = state.picked_up_current_leg
	self._loot_spawned_total = state.loot_spawned_total
	self._loot_spawned_current_leg = state.loot_spawned_current_leg
end

-- Lines 727-735
function LootDropManager:sync_save(data)
	local state = {
		picked_up_total = self._picked_up_total,
		picked_up_current_leg = self._picked_up_current_leg,
		loot_spawned_total = self._loot_spawned_total,
		loot_spawned_current_leg = self._loot_spawned_current_leg
	}
	data.LootDropManager = state
end

-- Lines 738-740
function LootDropManager:save(data)
	data.LootDropManager = self._global
end

-- Lines 743-745
function LootDropManager:load(data)
	self._global = data.LootDropManager
end
