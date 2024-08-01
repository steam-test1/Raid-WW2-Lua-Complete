GreedCacheItem = GreedCacheItem or class()

-- Lines 3-7
function GreedCacheItem:init(unit)
	self._unit = unit
	self._reserve = 0
	self._unlocked = false
end

-- Lines 9-12
function GreedCacheItem:set_reserve(value)
	self._reserve = value
	self._current_amount = value
end

-- Lines 14-16
function GreedCacheItem:reserve()
	return self._reserve
end

-- Lines 18-20
function GreedCacheItem:reserve_left()
	return self._current_amount
end

-- Lines 22-28
function GreedCacheItem:pickup_amount()
	local value = tweak_data.greed.cache_items[self._tweak_table].single_interaction_value
	local data = tweak_data.greed.cache_items[self._tweak_table].single_interaction_value_rand
	local rand = math.random(data[1]) * data[2]

	Application:debug("[GreedCacheItem:pickup_amount] value + rand", value, rand)

	return value + rand
end

-- Lines 30-39
function GreedCacheItem:on_interacted(amount)
	local pickup_amount = amount or self:pickup_amount()
	pickup_amount = math.clamp(pickup_amount, 0, self:reserve_left())
	self._current_amount = self._current_amount - pickup_amount

	self:_check_current_sequence()

	return pickup_amount * managers.player:upgrade_value("player", "greed_loot_bonus", 1)
end

-- Lines 41-53
function GreedCacheItem:_check_current_sequence()
	local fill_sequences = tweak_data.greed.cache_items[self._tweak_table].sequences

	if fill_sequences then
		local current_percentage = self._current_amount / self._reserve

		for sequence_index, sequence_data in pairs(fill_sequences) do
			if current_percentage <= sequence_data.max_value then
				self._unit:damage():run_sequence_simple(sequence_data.sequence)

				break
			end
		end
	end
end

-- Lines 55-64
function GreedCacheItem:get_lockpick_parameters()
	local parameters = deep_clone(tweak_data.greed.cache_items[self._tweak_table].lockpick)
	parameters.circle_radius = {
		tweak_data.interaction.MINIGAME_CIRCLE_RADIUS_SMALL,
		tweak_data.interaction.MINIGAME_CIRCLE_RADIUS_MEDIUM,
		tweak_data.interaction.MINIGAME_CIRCLE_RADIUS_BIG
	}

	return parameters
end

-- Lines 66-69
function GreedCacheItem:unlock()
	self._unlocked = true

	self:_check_current_sequence()
end

-- Lines 71-73
function GreedCacheItem:locked()
	return not self._unlocked
end

-- Lines 75-77
function GreedCacheItem:interaction_timer_value()
	return tweak_data.greed.cache_items[self._tweak_table].interaction_timer
end

-- Lines 79-86
function GreedCacheItem:on_load_complete()
	local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:unit_data().unit_id):world_id()

	managers.greed:register_greed_cache_item(self._unit, world_id)

	if not self._reserve or not self._current_amount then
		self:set_reserve(tweak_data.greed.cache_items[self._tweak_table].value)
	end
end

-- Lines 88-92
function GreedCacheItem:save(data)
	data.reserve = self._reserve
	data.current_amount = self._current_amount
	data.unlocked = self._unlocked
end

-- Lines 94-102
function GreedCacheItem:load(data)
	self._reserve = data.reserve
	self._current_amount = data.current_amount
	self._unlocked = data.unlocked

	if self._unlocked then
		self:_check_current_sequence()
	end
end
