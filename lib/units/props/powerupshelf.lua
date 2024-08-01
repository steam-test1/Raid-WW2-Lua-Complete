PowerupShelf = PowerupShelf or class(UnitBase)

-- Lines 6-14
function PowerupShelf:init(unit)
	PowerupShelf.super.init(self, unit, false)

	self._unit = unit
	self._pickups_spawned = {}
	self.loot_locators = self.loot_locators or {}
end

-- Lines 17-19
function PowerupShelf:is_spawned()
	return not table.empty(self._pickups_spawned)
end

-- Lines 22-24
function PowerupShelf:add_loot_locator(key)
	table.insert(self.loot_locators, key)
end

-- Lines 27-29
function PowerupShelf:reset_loot_locators()
	self.loot_locators = {}
end

-- Lines 33-92
function PowerupShelf:spawn_pickups()
	Application:debug("[PowerupShelf:spawn_pickups]", self._unit)

	if self:is_spawned() or not Network:is_server() then
		return
	end

	local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:id())
	local difficulty = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)
	local difficulty_multipliers = tweak_data.drop_loot[self._tweak_table].difficulty_multipliers
	local chances = difficulty_multipliers and difficulty_multipliers[difficulty_index] or 1

	if chances < 1 then
		chances = math.rand(chances, 1)
	end

	chances = math.clamp(chances, 0, 1)
	local loot_locator_objs = {}
	local locator_name = tweak_data.drop_loot[self._tweak_table].locator_name or "item_"

	if table.empty(self.loot_locators) then
		repeat
			local loot_locator = self._unit:get_object(Idstring(locator_name .. string.format("%02d", #loot_locator_objs + 1)))

			if loot_locator ~= nil then
				table.insert(loot_locator_objs, loot_locator)
			end
		until not loot_locator
	else
		for i, locator_name in ipairs(self.loot_locators) do
			local loot_locator = self._unit:get_object(Idstring(locator_name))

			if loot_locator ~= nil then
				table.insert(loot_locator_objs, loot_locator)
			end
		end
	end

	loot_locator_objs = table.shuffled(loot_locator_objs)
	local a = math.ceil(#loot_locator_objs * chances)

	for i = 1, a do
		local loot_locator = table.remove(loot_locator_objs)

		repeat
			local drop = managers.drop_loot:drop_item(self._tweak_table, loot_locator:position(), loot_locator:rotation(), world_id)

			table.insert(self._pickups_spawned, drop)
		until drop
	end
end

-- Lines 96-103
function PowerupShelf:despawn_pickups()
	for _, unit in ipairs(self._pickups_spawned) do
		if alive(unit) then
			unit:set_slot(0)
		end
	end

	self._pickups_spawned = {}
end

-- Lines 106-112
function PowerupShelf:set_tweak_data(new_tweak_table)
	if tweak_data.drop_loot[new_tweak_table] then
		self._tweak_table = new_tweak_table
	else
		Application:error("[PowerupShelf:set_tweak_data] Cannot set tweak table ID", new_tweak_table, "does not exist in tweakdata!")
	end
end

-- Lines 115-117
function PowerupShelf:destroy()
	self:despawn_pickups()
end
