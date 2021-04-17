PowerupShelf = PowerupShelf or class(UnitBase)

-- Lines 3-7
function PowerupShelf:init(unit)
	PowerupShelf.super.init(self, unit, false)

	self._unit = unit
	self._pickups_spawned = false
end

-- Lines 9-25
function PowerupShelf:spawn_pickups()
	if self._pickups_spawned or not Network:is_server() then
		return
	end

	local loot_locator = self._unit:get_object(Idstring("item_01"))
	local index = 2

	while loot_locator ~= nil do
		managers.drop_loot:drop_item(self._tweak_table, loot_locator:position(), loot_locator:rotation())

		loot_locator = self._unit:get_object(Idstring("item_" .. string.format("%02d", index)))
		index = index + 1
	end

	self._pickups_spawned = true
end

-- Lines 27-29
function PowerupShelf:set_tweak_data(new_tweak_table)
	self._tweak_table = new_tweak_table
end
