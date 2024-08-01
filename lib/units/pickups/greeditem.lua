GreedItem = GreedItem or class()

-- Lines 3-6
function GreedItem:init(unit)
	self._unit = unit
	self._value = 0
end

-- Lines 8-10
function GreedItem:set_value(value)
	self._value = value
end

-- Lines 12-14
function GreedItem:value()
	return self._value * managers.player:upgrade_value("player", "greed_loot_bonus", 1)
end

-- Lines 16-18
function GreedItem:tweak_id()
	return self._tweak_table
end

-- Lines 20-22
function GreedItem:value_line_id()
	return tweak_data.greed:value_line_id(self:value())
end

-- Lines 24-32
function GreedItem:on_load_complete()
	if not self._dont_register then
		local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:unit_data().unit_id):world_id()

		managers.greed:register_greed_item(self._unit, self._tweak_table, world_id)
	end

	self:set_value(tweak_data.greed.greed_items[self._tweak_table].value)
end
