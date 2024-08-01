GreedItem = GreedItem or class()

function GreedItem:init(unit)
	self._unit = unit
	self._value = 0
end

function GreedItem:set_value(value)
	self._value = value
end

function GreedItem:value()
	return self._value * managers.player:upgrade_value("player", "greed_loot_bonus", 1)
end

function GreedItem:tweak_id()
	return self._tweak_table
end

function GreedItem:value_line_id()
	return tweak_data.greed:value_line_id(self:value())
end

function GreedItem:on_load_complete()
	if not self._dont_register then
		local world_id = managers.worldcollection:get_worlddefinition_by_unit_id(self._unit:unit_data().unit_id):world_id()

		managers.greed:register_greed_item(self._unit, self._tweak_table, world_id)
	end

	self:set_value(tweak_data.greed.greed_items[self._tweak_table].value)
end
