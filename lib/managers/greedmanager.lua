GreedManager = GreedManager or class()
GreedManager.VERSION = 1

-- Lines 7-15
function GreedManager.get_instance()
	if not Global.greed_manager then
		Global.greed_manager = GreedManager:new()
	end

	setmetatable(Global.greed_manager, GreedManager)

	return Global.greed_manager
end

-- Lines 18-20
function GreedManager:init()
	self:reset()
end

-- Lines 23-34
function GreedManager:reset()
	self._registered_greed_items = {}
	self._registered_greed_cache_items = {}
	self._current_loot_counter = 0
	self._mission_loot_counter = 0
	self._gold_awarded_in_mission = 0
	self._active_greed_items = {}
end

-- Lines 37-48
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

-- Lines 50-59
function GreedManager:register_greed_cache_item(unit, world_id)
	self._registered_greed_cache_items[world_id] = self._registered_greed_cache_items[world_id] or {}
	local greed_cache_item_data = {
		unit = unit,
		world_id = world_id
	}

	table.insert(self._registered_greed_cache_items[world_id], greed_cache_item_data)
end

-- Lines 62-151
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
		print("[GreedManager][plant_greed_items_on_level] No greed units registered on the level! Not spawning anything. World id: " .. tostring(world_id), "Job id: " .. tostring(job_id))

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

		print("[GreedManager][plant_greed_items_on_level] A cache item will be spawned! Unit: " .. tostring(chosen_cache_unit))
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

-- Lines 154-185
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

-- Lines 190-204
function GreedManager:pickup_greed_item(value, unit)
	self:on_loot_picked_up(value)

	for i = #self._active_greed_items, 1, -1 do
		if self._active_greed_items[i] == unit then
			table.remove(self._active_greed_items, i)

			break
		end
	end
end

-- Lines 207-209
function GreedManager:pickup_cache_loot(value)
	self:on_loot_picked_up(value)
end

-- Lines 212-222
function GreedManager:on_loot_picked_up(value)
	self._mission_loot_counter = self._mission_loot_counter + value
	local acquired_new_goldbar = tweak_data.greed.points_needed_for_gold_bar <= self._current_loot_counter + self._mission_loot_counter - self._gold_awarded_in_mission * tweak_data.greed.points_needed_for_gold_bar

	if acquired_new_goldbar then
		self._gold_awarded_in_mission = self._gold_awarded_in_mission + 1
	end

	managers.hud:on_greed_loot_picked_up(self._current_loot_counter + self._mission_loot_counter - value, self._current_loot_counter + self._mission_loot_counter)
end

-- Lines 225-227
function GreedManager:current_loot_counter()
	return self._current_loot_counter
end

-- Lines 230-232
function GreedManager:loot_needed_for_gold_bar()
	return tweak_data.greed.points_needed_for_gold_bar
end

-- Lines 236-259
function GreedManager:on_level_exited(success)
	self._registered_greed_items = {}
	self._registered_greed_cache_items = {}
	self._greed_items_spawned_value = 0
	self._cache_current = self._current_loot_counter
	self._cache_mission = self._mission_loot_counter

	if not success then
		self._gold_awarded_in_mission = 0
	else
		self._current_loot_counter = self._current_loot_counter + self._mission_loot_counter - self._gold_awarded_in_mission * tweak_data.greed.points_needed_for_gold_bar
	end

	self._mission_loot_counter = 0

	if managers.hud then
		managers.hud:reset_greed_indicators()
	end
end

-- Lines 261-263
function GreedManager:cache()
	return self._cache_current, self._cache_mission
end

-- Lines 265-268
function GreedManager:clear_cache()
	self._cache_current = nil
	self._cache_mission = nil
end

-- Lines 271-273
function GreedManager:acquired_gold_in_mission()
	return self._gold_awarded_in_mission > 0
end

-- Lines 276-279
function GreedManager:award_gold_picked_up_in_mission()
	managers.gold_economy:add_gold(self._gold_awarded_in_mission)

	self._gold_awarded_in_mission = 0
end

-- Lines 282-289
function GreedManager:save_profile_slot(data)
	local state = {
		version = GreedManager.VERSION,
		current_loot_counter = self._current_loot_counter
	}
	data.GreedManager = state
end

-- Lines 293-305
function GreedManager:load_profile_slot(data, version)
	local state = data.GreedManager

	if not state then
		return
	end

	if state.version and state.version ~= GreedManager.VERSION then
		self:reset()

		return
	end

	self._current_loot_counter = state.current_loot_counter
end
