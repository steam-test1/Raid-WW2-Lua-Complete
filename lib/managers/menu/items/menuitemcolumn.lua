core:import("CoreMenuItem")

ItemColumn = ItemColumn or class(CoreMenuItem.Item)
ItemColumn.TYPE = "column"

function ItemColumn:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = ItemColumn.TYPE
end
