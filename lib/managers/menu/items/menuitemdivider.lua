core:import("CoreMenuItem")

MenuItemDivider = MenuItemDivider or class(CoreMenuItem.Item)
MenuItemDivider.TYPE = "divider"

-- Lines 6-10
function MenuItemDivider:init(data_node, parameters)
	MenuItemDivider.super.init(self, data_node, parameters)

	self._type = MenuItemDivider.TYPE
end

-- Lines 13-33
function MenuItemDivider:setup_gui(node, row_item)
	local scaled_size = managers.gui_data:scaled_size()
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	local h = row_item.item:parameters().size or 10

	if row_item.text then
		row_item.text = node:_text_item_part(row_item, row_item.gui_panel, 0)
		local _, _, tw, th = row_item.text:text_rect()

		row_item.text:set_size(tw, th)

		h = th
	end

	row_item.gui_panel:set_left(node:_mid_align())
	row_item.gui_panel:set_w(scaled_size.width - row_item.gui_panel:left())
	row_item.gui_panel:set_h(h)

	return true
end

-- Lines 36-43
function MenuItemDivider:reload(row_item, node)
	MenuItemDivider.super.reload(self, row_item, node)
	self:_set_row_item_state(node, row_item)

	return true
end

-- Lines 46-49
function MenuItemDivider:highlight_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

-- Lines 52-55
function MenuItemDivider:fade_row_item(node, row_item, mouse_over)
	self:_set_row_item_state(node, row_item)

	return true
end

-- Lines 58-62
function MenuItemDivider:_set_row_item_state(node, row_item)
	if row_item.highlighted then
		-- Nothing
	end
end

-- Lines 64-66
function MenuItemDivider:menu_unselected_visible()
	return false
end

-- Lines 69-71
function MenuItemDivider:on_delete_row_item(row_item, ...)
	MenuItemDivider.super.on_delete_row_item(self, row_item, ...)
end
