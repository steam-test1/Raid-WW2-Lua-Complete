PowerupShelf = PowerupShelf or class(UnitBase)

function PowerupShelf:init(unit)
	PowerupShelf.super.init(self, unit, false)

	self._unit = unit
	self._pickups_spawned = false
end

function PowerupShelf:spawn_pickups()
	if self._pickups_spawned or not Network:is_server() then
		return
	end

	local index = 1

	while index < 100 do
		local loot_locator = self._unit:get_object(Idstring("item_" .. string.format("%02d", index)))

		if loot_locator == nil then
			break
		end

		managers.drop_loot:drop_item(self._tweak_table, loot_locator:position(), loot_locator:rotation())

		index = index + 1
	end

	self._pickups_spawned = true
end

function PowerupShelf:set_tweak_data(new_tweak_table)
	self._tweak_table = new_tweak_table
end
