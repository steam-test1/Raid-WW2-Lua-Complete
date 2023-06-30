PowerupShelf = PowerupShelf or class(UnitBase)

function PowerupShelf:init(unit)
	PowerupShelf.super.init(self, unit, false)

	self._unit = unit
	self._pickups_spawned = {}
end

function PowerupShelf:is_spawned()
	return table.empty(self._pickups_spawned)
end

function PowerupShelf:spawn_pickups()
	if not self:is_spawned() or not Network:is_server() then
		return
	end

	repeat
		local loot_locator = self._unit:get_object(Idstring("item_" .. string.format("%02d", #self._pickups_spawned + 1)))

		if loot_locator ~= nil then
			local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:id())
			local drop = managers.drop_loot:drop_item(self._tweak_table, loot_locator:position(), loot_locator:rotation(), world_id)

			table.insert(self._pickups_spawned, drop)
		end
	until not loot_locator
end

function PowerupShelf:set_tweak_data(new_tweak_table)
	self._tweak_table = new_tweak_table
end
