MenuItemMultiChoiceRaid = MenuItemMultiChoiceRaid or class(MenuItemMultiChoice)
MenuItemMultiChoiceRaid.TYPE = "multi_choice"

-- Lines 4-9
function MenuItemMultiChoiceRaid:init(data_node, parameters)
	MenuItemMultiChoiceRaid.super.init(self, data_node, parameters)

	self._type = MenuItemMultiChoiceRaid.TYPE
end

-- Lines 20-68
function MenuItemMultiChoiceRaid:setup_gui(node, row_item)
	local right_align = node:_right_align()
	row_item.gui_panel = node.item_panel:panel({
		w = node.item_panel:w()
	})
	row_item.gui_text = node:_text_item_part(row_item, row_item.gui_panel, right_align, row_item.align)

	row_item.gui_text:set_wrap(true)
	row_item.gui_text:set_word_wrap(true)

	local choice_text_align = row_item.align == "left" and "right" or row_item.align == "right" and "left" or row_item.align
	row_item.choice_panel = row_item.gui_panel:panel({
		w = node.item_panel:w()
	})
	row_item.choice_text = row_item.choice_panel:text({
		vertical = "center",
		align = "center",
		y = 0,
		x = 0,
		font_size = row_item.font_size,
		font = row_item.font,
		color = node.row_item_hightlight_color,
		layer = node.layers.items,
		blend_mode = node.row_item_blend_mode,
		text = utf8.to_upper(""),
		render_template = Idstring("VertexColorTextured")
	})
	local w = 20
	local h = 20
	local base = 20
	local height = 15
	row_item.arrow_left = row_item.gui_panel:bitmap({
		texture = "guis/textures/menu_arrows",
		y = 0,
		x = 0,
		texture_rect = {
			0,
			0,
			24,
			24
		},
		color = Color(0.5, 0.5, 0.5),
		visible = self:arrow_visible(),
		layer = node.layers.items,
		blend_mode = node.row_item_blend_mode
	})
	row_item.arrow_right = row_item.gui_panel:bitmap({
		texture = "guis/textures/menu_arrows",
		y = 0,
		x = 0,
		texture_rect = {
			24,
			0,
			-24,
			24
		},
		color = Color(0.5, 0.5, 0.5),
		visible = self:arrow_visible(),
		layer = node.layers.items,
		blend_mode = node.row_item_blend_mode
	})

	if self:info_panel() == "lobby_campaign" then
		node:_create_lobby_campaign(row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node:_create_lobby_difficulty(row_item)
	elseif row_item.help_text then
		-- Nothing
	end

	self:_layout(node, row_item)

	return true
end

-- Lines 70-182
function MenuItemMultiChoiceRaid:_layout(node, row_item)
	local safe_rect = managers.gui_data:scaled_size()
	local right_align = node:_right_align()
	local left_align = node:_left_align()

	if self:parameters().filter then
		-- Nothing
	end

	row_item.gui_panel:set_width(safe_rect.width - node:_mid_align())
	row_item.gui_panel:set_x(node:_mid_align())

	local arrow_size = 24 * tweak_data.scale.multichoice_arrow_multiplier

	row_item.arrow_right:set_size(arrow_size, arrow_size)
	row_item.arrow_left:set_size(arrow_size, arrow_size)

	if row_item.align == "right" then
		row_item.arrow_left:set_left(right_align - row_item.gui_panel:x() + (self:parameters().expand_value or 0))
		row_item.arrow_right:set_left(row_item.arrow_left:right() + 2 * (1 - tweak_data.scale.multichoice_arrow_multiplier))
	else
		row_item.arrow_right:set_right(row_item.gui_panel:w())
		row_item.arrow_left:set_right(row_item.arrow_right:left() + 2 * (1 - tweak_data.scale.multichoice_arrow_multiplier))
	end

	local x, y, w, h = row_item.gui_text:text_rect()

	row_item.gui_text:set_h(h)
	row_item.gui_text:set_width(w + 5)

	if h == 0 then
		h = row_item.font_size

		row_item.choice_panel:set_w(row_item.gui_panel:width() - (arrow_size + node._align_line_padding) * 2)
	else
		row_item.choice_panel:set_w(row_item.gui_panel:width() * 0.4 + (self:parameters().text_offset or 0))
	end

	row_item.choice_panel:set_h(h)

	if row_item.align == "right" then
		row_item.choice_panel:set_left(row_item.arrow_left:right() + node._align_line_padding)
		row_item.arrow_right:set_left(row_item.choice_panel:right())
	else
		row_item.choice_panel:set_right(row_item.arrow_right:left() - node._align_line_padding)
		row_item.arrow_left:set_right(row_item.choice_panel:left())
	end

	row_item.choice_text:set_w(row_item.choice_panel:w())
	row_item.choice_text:set_h(h)
	row_item.choice_text:set_left(0)
	row_item.arrow_right:set_center_y(row_item.choice_panel:center_y())
	row_item.arrow_left:set_center_y(row_item.choice_panel:center_y())

	if row_item.align == "right" then
		row_item.gui_text:set_right(row_item.gui_panel:w())
	else
		row_item.gui_text:set_left(node:_right_align() - row_item.gui_panel:x() + (self:parameters().expand_value or 0))
	end

	row_item.gui_text:set_height(h)
	row_item.gui_panel:set_height(h)

	if row_item.gui_info_panel then
		node:_align_item_gui_info_panel(row_item.gui_info_panel)

		if self:info_panel() == "lobby_campaign" then
			node:_align_lobby_campaign(row_item)
		elseif self:info_panel() == "lobby_difficulty" then
			node:_align_lobby_difficulty(row_item)
		else
			node:_align_info_panel(row_item)
		end
	end

	local node_padding = node:_mid_align()

	if node:_get_node_padding() > 0 then
		node_padding = node:_get_node_padding()
	end

	row_item.gui_panel:set_x(node_padding)
	row_item.gui_text:set_x(0)
	row_item.gui_text:hide()
	row_item.arrow_left:set_x(0)
	row_item.choice_panel:set_x(row_item.arrow_left:right())
	row_item.choice_panel:set_w(row_item.choice_panel:w() * 1.5)
	row_item.choice_text:set_w(row_item.choice_panel:w())
	row_item.arrow_right:set_x(row_item.choice_panel:right())
	row_item.gui_panel:set_w(row_item.arrow_left:w() + row_item.choice_panel:w() + row_item.arrow_right:w())
	row_item.gui_panel:set_h(row_item.gui_panel:h() * 2)

	return true
end
