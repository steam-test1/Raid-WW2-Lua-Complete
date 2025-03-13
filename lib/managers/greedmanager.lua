GreedManager = GreedManager or class()
GreedManager.VERSION = 2

function GreedManager.get_instance()
	if not Global.greed_manager then
		Global.greed_manager = GreedManager:new()
	end

	setmetatable(Global.greed_manager, GreedManager)

	return Global.greed_manager
end

function GreedManager:init()
	self:reset()
end

function GreedManager:reset()
	self._registered_greed_items = {}
	self._registered_greed_cache_items = {}
	self._current_loot_counter = 0
	self._mission_loot_counter = 0
	self._gold_awarded_in_mission = 0
	self._active_greed_items = {}
	self._secured_bounty = false
end

function GreedManager:register_greed_item(unit, tweak_table, world_id)
	self._registered_greed_items[world_id] = self._registered_greed_items[world_id] or {}
	local item_tweak_data = tweak_data.greed.greed_items[tweak_table]
	local greed_item_data = {
		unit = unit,
		value = item_tweak_data.value,
		world_id = world_id
	}

	table.insert(self._registered_greed_items[world_id], greed_item_data)
end

function GreedManager:register_greed_cache_item(unit, world_id)
	self._registered_greed_cache_items[world_id] = self._registered_greed_cache_items[world_id] or {}
	local greed_cache_item_data = {
		unit = unit,
		world_id = world_id
	}

	table.insert(self._registered_greed_cache_items[world_id], greed_cache_item_data)
end

function GreedManager:plant_greed_items_on_level(world_id)
	if not Network:is_server() or Application:editor() or not self._registered_greed_items[world_id] then
		return
	end

	local job_data = managers.raid_job:current_job()
	local total_value = tweak_data.greed.points_spawned_on_level_default
	local job_id = job_data and job_data.job_id

	if job_data and job_data.greed_items then
		total_value = math.random(job_data.greed_items.min, job_data.greed_items.max)
	end

	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local current_difficulty = tweak_data:difficulty_to_index(difficulty)
	total_value = total_value * tweak_data.greed.difficulty_level_point_multipliers[current_difficulty]
	self._greed_items_spawned_value = 0
	self._registered_greed_items[world_id] = self._registered_greed_items[world_id] or {}
	self._active_greed_items = {}

	if #self._registered_greed_items[world_id] == 0 then
		Application:debug("[GreedManager] No greed units registered on the level! Not spawning anything. World id: " .. tostring(world_id), "Job id: " .. tostring(job_id))

		return
	end

	math.shuffle(self._registered_greed_items[world_id])

	for _, greed_item in ipairs(self._registered_greed_items[world_id]) do
		if not alive(greed_item.unit) then
			greed_item.deleted = true
		else
			local should_remove_greed_item = total_value <= self._greed_items_spawned_value

			if should_remove_greed_item then
				greed_item.unit:set_slot(0)

				greed_item.deleted = true
			else
				self._greed_items_spawned_value = self._greed_items_spawned_value + greed_item.value

				table.insert(self._active_greed_items, greed_item.unit)
			end
		end
	end

	self._registered_greed_cache_items[world_id] = self._registered_greed_cache_items[world_id] or {}
	local cache_spawn_chance = tweak_data.greed.cache_base_spawn_chance
	cache_spawn_chance = cache_spawn_chance * tweak_data.greed.difficulty_cache_chance_multipliers[current_difficulty]
	local chosen_cache_unit = nil

	if #self._registered_greed_cache_items[world_id] > 0 and math.random() <= math.clamp(cache_spawn_chance, -1, 1) then
		math.shuffle(self._registered_greed_cache_items[world_id])

		chosen_cache_unit = self._registered_greed_cache_items[world_id][1].unit

		Application:debug("[GreedManager] A cache item will be spawned! Unit: " .. tostring(chosen_cache_unit))
	end

	if alive(chosen_cache_unit) then
		if chosen_cache_unit:damage() and chosen_cache_unit:damage():has_sequence("chosen_one") then
			chosen_cache_unit:damage():run_sequence_simple("chosen_one")
		end
	else
		Application:warn("[GreedManager] Chosen Cache Unit was not alive, this might be a problem...")
	end

	for index, cache_item in pairs(self._registered_greed_cache_items[world_id]) do
		if alive(cache_item.unit) and cache_item.unit ~= chosen_cache_unit then
			cache_item.unit:set_slot(0)

			cache_item.deleted = true
		end
	end

	if self._greed_items_spawned_value < total_value then
		print("[GreedManager][plant_loot_on_level] All greed units on level used, level greed cap still not reached (curr_value, total_value):", self._greed_items_spawned_value, total_value)
	else
		print("[GreedManager][plant_loot_on_level] Greed value placed on level:", self._greed_items_spawned_value)
	end
end

function GreedManager:remove_greed_items_from_level(world_id)
	if not Network:is_server() then
		return
	end

	self._registered_greed_items[world_id] = self._registered_greed_items[world_id] or {}

	for _, greed_item_data in ipairs(self._registered_greed_items[world_id]) do
		greed_item_data.unit:set_slot(0)

		greed_item_data.deleted = true
	end

	self._registered_greed_items[world_id] = {}
	self._active_greed_items = {}
	self._registered_greed_cache_items[world_id] = self._registered_greed_cache_items[world_id] or {}

	for _, greed_item_data in ipairs(self._registered_greed_cache_items[world_id]) do
		greed_item_data.unit:set_slot(0)

		greed_item_data.deleted = true
	end

	self._registered_greed_cache_items[world_id] = {}
end

function GreedManager:greed_value_difficulty_multiplier()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local current_difficulty = tweak_data:difficulty_to_index(difficulty)

	return tweak_data.greed.difficulty_level_point_multipliers_carry[current_difficulty]
end

function GreedManager:pickup_greed_item(value, unit)
	local notification_item = {
		icon = "carry_gold",
		name_id = "menu_greed_loot_title",
		value = value
	}

	if alive(unit) and unit:greed() then
		local tweak = tweak_data.greed.greed_items[unit:greed():tweak_id()]
		value = unit:greed():value()
		notification_item.name_id = tweak.name_id
		notification_item.icon = tweak.hud_icon
	end

	self:on_loot_picked_up(value, notification_item)

	for i = #self._active_greed_items, 1, -1 do
		if self._active_greed_items[i] == unit then
			table.remove(self._active_greed_items, i)

			break
		end
	end
end

function GreedManager:secure_greed_carry_loot(carry_id, multiplier)
	local tweak = tweak_data.carry[carry_id]
	local value = tweak.loot_greed_value
	value = value and value * multiplier * self:greed_value_difficulty_multiplier() * managers.player:upgrade_value("player", "greed_loot_bonus", 1)

	if value then
		local notification_item = {
			name_id = tweak.name_id,
			icon = tweak.hud_icon,
			value = value
		}

		self:on_loot_picked_up(value, notification_item)
	end
end

function GreedManager:on_loot_pickpocketed()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local current_difficulty = tweak_data:difficulty_to_index(difficulty)
	local weights = tweak_data.greed.value_weights.pickpocket[current_difficulty]
	local tweak_table_name, tweak = tweak_data.greed:get_random_item_weighted(weights)

	if tweak then
		local value = tweak.value * managers.player:upgrade_value("player", "greed_loot_bonus", 1)
		local notification_item = {
			name_id = tweak.name_id,
			icon = tweak.hud_icon,
			value = value
		}

		self:on_loot_picked_up(value, notification_item)

		return tweak_table_name, tweak
	end
end

function GreedManager:pickup_cache_loot(value)
	self:on_loot_picked_up(value)
end

function GreedManager:secure_bounty(bars)
	if not managers.raid_job:is_camp_loaded() and not managers.raid_job:is_in_tutorial() then
		managers.network:session():send_to_peers_synched("sync_secured_bounty", bars)
		self:sync_secured_bounty(bars)
	else
		Application:warn("[GreedManager:secure_bounty] Cannot award bounty out of a mission!")
	end
end

function GreedManager:sync_secured_bounty(bars)
	if not self._secured_bounty then
		self:on_loot_picked_up(self:loot_needed_for_gold_bar() * bars)

		self._secured_bounty = true
	end
end

function GreedManager:on_loot_picked_up(value, notification_item)
	self._mission_loot_counter = self._mission_loot_counter + value
	local total_loot_counter = self:current_loot_counter() + self:current_mission_loot_counter() - self._gold_awarded_in_mission * self:loot_needed_for_gold_bar()
	local acquired_new_goldbar = self:loot_needed_for_gold_bar() <= total_loot_counter

	if acquired_new_goldbar then
		self._gold_awarded_in_mission = self._gold_awarded_in_mission + math.floor(total_loot_counter / self:loot_needed_for_gold_bar())
	end

	managers.hud:on_greed_loot_picked_up(self._current_loot_counter + self._mission_loot_counter - value, self._current_loot_counter + self._mission_loot_counter, notification_item)
end

function GreedManager:current_loot_counter()
	return self._current_loot_counter
end

function GreedManager:current_mission_loot_counter()
	return self._mission_loot_counter
end

function GreedManager:loot_needed_for_gold_bar()
	return tweak_data.greed.item_value.complete_gold_bar
end

function GreedManager:on_level_exited(success)
	self._registered_greed_items = {}
	self._registered_greed_cache_items = {}
	self._greed_items_spawned_value = 0
	self._cache_current = self._current_loot_counter
	self._cache_mission = self._mission_loot_counter

	if success then
		self._current_loot_counter = self._current_loot_counter + self._mission_loot_counter - self._gold_awarded_in_mission * tweak_data.greed.item_value.complete_gold_bar
		self._current_loot_counter = self._current_loot_counter % self:loot_needed_for_gold_bar()
	else
		self._gold_awarded_in_mission = 0
	end

	self._mission_loot_counter = 0
	self._secured_bounty = false

	if managers.hud then
		managers.hud:reset_greed_indicators()
	end
end

function GreedManager:cache()
	return self._cache_current, self._cache_mission
end

function GreedManager:clear_cache()
	self._cache_current = nil
	self._cache_mission = nil
end

function GreedManager:acquired_gold_in_mission()
	return self._gold_awarded_in_mission > 0
end

function GreedManager:greed_items_spawned_value()
	return self._greed_items_spawned_value
end

function GreedManager:award_gold_picked_up_in_mission()
	managers.gold_economy:add_gold(self._gold_awarded_in_mission)

	self._gold_awarded_in_mission = 0
end

function GreedManager:save_profile_slot(data)
	local state = {
		version = GreedManager.VERSION,
		current_loot_counter = self._current_loot_counter % self:loot_needed_for_gold_bar()
	}
	data.GreedManager = state
end

function GreedManager:load_profile_slot(data, version)
	local state = data.GreedManager

	if not state then
		return
	end

	if state.version and state.version ~= GreedManager.VERSION then
		self:reset()

		return
	end

	self._current_loot_counter = state.current_loot_counter % self:loot_needed_for_gold_bar()
end
