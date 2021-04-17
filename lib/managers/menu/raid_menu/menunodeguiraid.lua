MenuNodeGuiRaid = MenuNodeGuiRaid or class(MenuNodeGui)

-- Lines 3-7
function MenuNodeGuiRaid:init(node, layer, parameters)
	MenuNodeGuiRaid.super.init(self, node, layer, parameters)

	self.node.node_gui_object = self
end

-- Lines 12-20
function MenuNodeGuiRaid:_setup_item_panel(safe_rect, res)
	MenuNodeGuiRaid.super._setup_item_panel(self, safe_rect, res)
	self.item_panel:set_shape(self.item_panel:parent():shape())
end

-- Lines 23-26
function MenuNodeGuiRaid:close(...)
	MenuNodeGuiRaid.super.close(self)

	self.node.node_gui_object = nil
end
