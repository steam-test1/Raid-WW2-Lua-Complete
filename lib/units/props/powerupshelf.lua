PowerupShelf = PowerupShelf or class(UnitBase)

function PowerupShelf:init(unit)
	PowerupShelf.super.init(self, unit, false)

	self._unit = unit
	self._pickups_spawned = {}
	self.loot_locators = self.loot_locators or {}
end

function PowerupShelf:is_spawned()
	return not table.empty(self._pickups_spawned)
end

function PowerupShelf:add_loot_locator(key)
	table.insert(self.loot_locators, key)
end

function PowerupShelf:reset_loot_locators()
	self.loot_locators = {}
end

function PowerupShelf:spawn_pickups()
	Application:debug("[PowerupShelf:spawn_pickups]", self._unit)

	if self:is_spawned() or not Network:is_server() then
		return
	end

	local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:id())
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

	for _, loot_locator in ipairs(loot_locator_objs) do
		local drop = managers.drop_loot:drop_item(self._tweak_table, loot_locator:position(), loot_locator:rotation(), world_id)

		if alive(drop) then
			table.insert(self._pickups_spawned, drop)
		end
	end
end

function PowerupShelf:despawn_pickups()
	for _, unit in ipairs(self._pickups_spawned) do
		if alive(unit) then
			unit:set_slot(0)
		end
	end

	self._pickups_spawned = {}
end

function PowerupShelf:set_tweak_data(new_tweak_table)
	if tweak_data.drop_loot[new_tweak_table] then
		self._tweak_table = new_tweak_table
	else
		Application:error("[PowerupShelf:set_tweak_data] Cannot set tweak table ID", new_tweak_table, "does not exist in tweakdata!")
	end
end

function PowerupShelf:destroy()
	self:despawn_pickups()
end
