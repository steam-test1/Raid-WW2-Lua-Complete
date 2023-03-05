LootDropManager = LootDropManager or class()
LootDropManager.EVENT_PEER_LOOT_RECEIVED = "peer_loot_received"
LootDropManager.LOOT_VALUE_TYPE_SMALL = "small"
LootDropManager.LOOT_VALUE_TYPE_MEDIUM = "medium"
LootDropManager.LOOT_VALUE_TYPE_BIG = "big"
LootDropManager.LOOT_VALUE_TYPE_DOGTAG = "dogtag"
LootDropManager.LOOT_VALUE_TYPE_DOGTAG_BIG = "dogtag_big"
LootDropManager._REGISTER_LOOT_CONVERTER = {
	[LootDropManager.LOOT_VALUE_TYPE_SMALL] = LootDropTweakData.LOOT_VALUE_TYPE_SMALL_AMOUNT,
	[LootDropManager.LOOT_VALUE_TYPE_MEDIUM] = LootDropTweakData.LOOT_VALUE_TYPE_MEDIUM_AMOUNT,
	[LootDropManager.LOOT_VALUE_TYPE_BIG] = LootDropTweakData.LOOT_VALUE_TYPE_BIG_AMOUNT,
	[LootDropManager.LOOT_VALUE_TYPE_DOGTAG] = LootDropTweakData.LOOT_VALUE_TYPE_DOGTAG_AMOUNT,
	[LootDropManager.LOOT_VALUE_TYPE_DOGTAG_BIG] = LootDropTweakData.LOOT_VALUE_TYPE_DOGTAG_BIG_AMOUNT
}

function LootDropManager:init()
	self:_setup()

	self._listener_holder = EventListenerHolder:new()
	self._loot_for_peers = {}

	managers.system_event_listener:add_listener("loot_drop_manager_drop_out", {
		CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_DROP_OUT
	}, callback(self, self, "player_droped_out"))
	self:reset_loot_value_counters()
end

function LootDropManager:_call_listeners(event, params)
	self._listener_holder:call(event, params)
end

function LootDropManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function LootDropManager:remove_listener(key)
	self._listener_holder:remove(key)
end

function LootDropManager:player_droped_out(params)
	local peer_id = params._id

	for i, drop in ipairs(self._loot_for_peers) do
		if drop.peer_id == peer_id then
			table.remove(self._loot_for_peers, i)

			break
		end
	end
end

function LootDropManager:_setup()
	if not Global.lootdrop_manager then
		Global.lootdrop_manager = {}
	end

	self._global = Global.lootdrop_manager
end

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

	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	gold_bars_earned = math.ceil(gold_bars_earned * tweak_data.operations.consumable_missions.difficulty_reward_multiplier[difficulty_index])
	local drop = {
		reward_type = LootDropTweakData.REWARD_GOLD_BARS,
		gold_bars_min = gold_bars_earned,
		gold_bars_max = gold_bars_earned
	}

	return drop
end

function LootDropManager:produce_loot_drop(loot_value, use_reroll_drop_tables, forced_loot_group)
	local loot_group = self:_get_loot_group(loot_value, use_reroll_drop_tables, forced_loot_group)
	local loot_category = self:get_random_item_weighted(loot_group)
	local drop = self:get_random_item_weighted(loot_category)

	return drop
end

function LootDropManager:_get_loot_group(loot_value, use_reroll_drop_tables, forced_loot_group)
	Application:debug("[LootDropManager:_get_loot_group] get loot:", loot_value, use_reroll_drop_tables, forced_loot_group)

	local loot_group = nil
	local data_source = tweak_data.lootdrop.loot_groups

	if forced_loot_group then
		return data_source[forced_loot_group]
	end

	if use_reroll_drop_tables then
		data_source = tweak_data.lootdrop.loot_groups_doubles_fallback
	end

	for ii, group in pairs(data_source) do
		Application:debug("[LootDropManager:_get_loot_group] data_source grp:", ii, group)

		if group.min_loot_value or loot_value > 0 and loot_value <= (group.max_loot_value or 0) then
			loot_group = deep_clone(group)

			for k, v in pairs(loot_group) do
				Application:debug("[LootDropManager:_get_loot_group] loot group parts:", k)

				if type(v) == "table" and v.conditions then
					Application:debug("[LootDropManager:_get_loot_group] has conditions", k, v.conditions)

					local conditions_met = true

					for _, condition in ipairs(v.conditions) do
						if condition == LootDropTweakData.DROP_CONDITION_BELOW_MAX_LEVEL and managers.experience:reached_level_cap() then
							conditions_met = false

							Application:debug("[LootDropManager:_get_loot_group] DROP_CONDITION_BELOW_MAX_LEVEL failed")
						end
					end

					if not conditions_met then
						Application:debug("[LootDropManager:_get_loot_group] conditions failed removing", k)
						table.remove(loot_group, k)
					end
				end
			end

			break
		end
	end

	return loot_group
end

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

function LootDropManager:_get_random_item(collection)
	local num_items = #collection
	local index = math.random(#collection)
	local item = collection[index]

	return item
end

function LootDropManager:get_dropped_loot()
	return self._dropped_loot
end

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

function LootDropManager:on_loot_dropped_for_player()
	managers.savefile:save_game(SavefileManager.SETTING_SLOT)
	game_state_machine:current_state():on_loot_dropped_for_player()
end

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

function LootDropManager:redeem_dropped_loot_for_goldbars()
	local drop = self._dropped_loot
	local drop_redeemed_gold = drop.redeemed_gold or 5

	Application:trace("[LootDropManager:redeem_dropped_loot_for_goldbars]        loot: ", inspect(drop))

	if drop.reward_type == LootDropTweakData.REWARD_CUSTOMIZATION then
		managers.character_customization:remove_character_customization_from_inventory(drop.character_customization_key)
		self:_give_gold_bars_to_player(drop_redeemed_gold)
	elseif drop.reward_type == LootDropTweakData.REWARD_WEAPON_POINT then
		managers.weapon_skills:remove_weapon_skill_points_as_drops(1)
		self:_give_gold_bars_to_player(drop_redeemed_gold)
	elseif drop.reward_type == LootDropTweakData.REWARD_MELEE_WEAPON then
		managers.weapon_inventory:remove_melee_weapon_as_drop(drop)
		self:_give_gold_bars_to_player(drop_redeemed_gold)
	elseif drop.reward_type == LootDropTweakData.REWARD_HALLOWEEN_2017 then
		managers.weapon_inventory:remove_melee_weapon_as_drop(drop)
		self:_give_gold_bars_to_player(drop_redeemed_gold)
	end
end

function LootDropManager:_give_xp_to_player(drop)
	drop.awarded_xp = math.round(math.rand(drop.xp_min, drop.xp_max))

	managers.experience:set_loot_bonus_xp(drop.awarded_xp)
	managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, "", drop.awarded_xp, managers.network:session():local_peer():id())
end

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

function LootDropManager:_give_weapon_point_to_player(drop)
	managers.weapon_skills:add_weapon_skill_points_as_drops(1)

	drop.redeemed_xp = tweak_data.weapon_skills.weapon_point_reedemed_xp

	managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, "", drop.reedemed_xp, managers.network:session():local_peer():id())
end

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

function LootDropManager:_give_gold_bars_to_player(drop)
	drop.awarded_gold_bars = math.round(math.rand(drop.gold_bars_min, drop.gold_bars_max))

	managers.gold_economy:add_gold(drop.awarded_gold_bars)
	managers.gold_economy:layout_camp()
	managers.network:session():send_to_peers_synched("sync_loot_to_peers", drop.reward_type, "", drop.awarded_gold_bars, managers.network:session():local_peer():id())
end

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

function LootDropManager:get_loot_for_peers()
	return self._loot_for_peers
end

function LootDropManager:clear_dropped_loot()
	self._dropped_loot = nil
	self._loot_for_peers = {}
	self._cards_already_rejected = false
	self._loot_value = nil
	self._card_drop_pack_type = nil
end

function LootDropManager:convert_loot_register_value(id)
	return not not LootDropManager._REGISTER_LOOT_CONVERTER[id] and LootDropManager._REGISTER_LOOT_CONVERTER[id] or false
end

function LootDropManager:register_loot(unit, value_type, world_id)
	local value = self:convert_loot_register_value(value_type)

	if not value then
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

function LootDropManager:plant_loot_on_level(world_id, total_value, job_id)
	if not Network:is_server() or Application:editor() then
		return
	end

	Application:debug("[LootDropManager:plant_loot_on_level()] Planting loot on level, loot value (value, mission):", total_value, job_id)

	self._loot_spawned_current_leg = 0
	self._registered_loot_units[world_id] = self._registered_loot_units[world_id] or {}
	self._active_loot_units = {}

	if #self._registered_loot_units[world_id] == 0 then
		Application:debug("[LootDropManager:plant_loot_on_level()] no loot units registered on the level")

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

function LootDropManager:pickup_loot(value, unit)
	self._picked_up_current_leg = self._picked_up_current_leg + value

	managers.hud:set_loot_picked_up(self._picked_up_current_leg)
end

function LootDropManager:on_simulation_ended()
	Application:trace("LootDropManager:on_simulation_ended()")
	self:reset_loot_value_counters()
end

function LootDropManager:reset()
	Global.lootdrop_manager = nil

	self:_setup()
end

function LootDropManager:picked_up_current_leg()
	return self._picked_up_current_leg
end

function LootDropManager:picked_up_total()
	return self._picked_up_total
end

function LootDropManager:loot_spawned_total()
	return self._loot_spawned_total
end

function LootDropManager:loot_spawned_current_leg()
	return self._loot_spawned_current_leg
end

function LootDropManager:set_picked_up_current_leg(picked_up_current_leg)
	self._picked_up_current_leg = picked_up_current_leg

	managers.hud:set_loot_picked_up(self._picked_up_current_leg)
end

function LootDropManager:set_picked_up_total(picked_up_total)
	self._picked_up_total = picked_up_total
end

function LootDropManager:set_loot_spawned_total(loot_spawned_total)
	self._loot_spawned_total = loot_spawned_total
end

function LootDropManager:set_loot_spawned_current_leg(loot_spawned_current_leg)
	self._loot_spawned_current_leg = loot_spawned_current_leg

	managers.hud:set_loot_total(self._loot_spawned_current_leg)
end

function LootDropManager:sync_load(data)
	local state = data.LootDropManager
	self._picked_up_total = state.picked_up_total
	self._picked_up_current_leg = state.picked_up_current_leg
	self._loot_spawned_total = state.loot_spawned_total
	self._loot_spawned_current_leg = state.loot_spawned_current_leg
end

function LootDropManager:sync_save(data)
	local state = {
		picked_up_total = self._picked_up_total,
		picked_up_current_leg = self._picked_up_current_leg,
		loot_spawned_total = self._loot_spawned_total,
		loot_spawned_current_leg = self._loot_spawned_current_leg
	}
	data.LootDropManager = state
end

function LootDropManager:save(data)
	data.LootDropManager = self._global
end

function LootDropManager:load(data)
	self._global = data.LootDropManager
end
