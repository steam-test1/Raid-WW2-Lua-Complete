core:import("CoreMenuItem")
core:import("CoreMenuItemOption")

MenuItemMultiChoice = MenuItemMultiChoice or class(CoreMenuItem.Item)
MenuItemMultiChoice.TYPE = "multi_choice"

-- Lines 7-56
function MenuItemMultiChoice:init(data_node, parameters)
	CoreMenuItem.Item.init(self, data_node, parameters)

	self._type = MenuItemMultiChoice.TYPE
	self._options = {}
	self._current_index = 1
	self._all_options = {}

	if data_node then
		for _, c in ipairs(data_node) do
			local type = c._meta

			if type == "option" then
				local option = CoreMenuItemOption.ItemOption:new(c)

				self:add_option(option)

				local visible_callback = c.visible_callback

				if visible_callback then
					option.visible_callback_names = string.split(visible_callback, " ")
				end
			end
		end
	end

	self._enabled = true

	self:_show_options(nil)
end

-- Lines 58-61
function MenuItemMultiChoice:set_enabled(enabled)
	self._enabled = enabled

	self:dirty()
end

-- Lines 63-66
function MenuItemMultiChoice:set_callback_handler(callback_handler)
	MenuItemMultiChoice.super.set_callback_handler(self, callback_handler)
end

-- Lines 68-71
function MenuItemMultiChoice:visible(...)
	self:_show_options(self._callback_handler)

	return MenuItemMultiChoice.super.visible(self, ...)
end

-- Lines 73-99
function MenuItemMultiChoice:_show_options(callback_handler)
	local selected_value = self:selected_option() and self:selected_option():value()
	self._options = {}

	for _, option in ipairs(self._all_options) do
		local show = true

		if callback_handler and option.visible_callback_names then
			for _, id in ipairs(option.visible_callback_names) do
				if not callback_handler[id](callback_handler, option) then
					show = false

					break
				end
			end
		end

		if show then
			table.insert(self._options, option)
		end
	end

	if selected_value then
		self:set_current_index(1)
		self:set_value(selected_value)
	end
end

-- Lines 102-104
function MenuItemMultiChoice:add_option(option)
	table.insert(self._all_options, option)
end

-- Lines 106-108
function MenuItemMultiChoice:clear_options()
	self._all_options = {}
end

-- Lines 110-112
function MenuItemMultiChoice:options()
	return self._options
end

-- Lines 114-116
function MenuItemMultiChoice:selected_option()
	return self._options[self._current_index]
end

-- Lines 118-120
function MenuItemMultiChoice:current_index()
	return self._current_index
end

-- Lines 122-125
function MenuItemMultiChoice:set_current_index(index)
	self._current_index = index

	self:dirty()
end

-- Lines 127-135
function MenuItemMultiChoice:set_value(value)
	for i, option in ipairs(self._options) do
		if option:parameters().value == value then
			self._current_index = i

			break
		end
	end

	self:dirty()
end

-- Lines 137-144
function MenuItemMultiChoice:value()
	local value = ""
	local selected_option = self:selected_option()

	if selected_option then
		value = selected_option:parameters().value
	end

	return value
end

-- Lines 147-155
function MenuItemMultiChoice:_highest_option_index()
	local index = 1

	for i, option in ipairs(self._options) do
		if not option:parameters().exclude then
			index = i
		end
	end

	return index
end

-- Lines 158-164
function MenuItemMultiChoice:_lowest_option_index()
	for i, option in ipairs(self._options) do
		if not option:parameters().exclude then
			return i
		end
	end
end

-- Lines 167-185
function MenuItemMultiChoice:next()
	if not self._enabled then
		return
	end

	if #self._options < 2 then
		return
	end

	if self._current_index == self:_highest_option_index() then
		return
	end

	repeat
		self._current_index = self._current_index == #self._options and 1 or self._current_index + 1
	until not self._options[self._current_index]:parameters().exclude

	return true
end

-- Lines 187-205
function MenuItemMultiChoice:previous()
	if not self._enabled then
		return
	end

	if #self._options < 2 then
		return
	end

	if self._current_index == self:_lowest_option_index() then
		return
	end

	repeat
		self._current_index = self._current_index == 1 and #self._options or self._current_index - 1
	until not self._options[self._current_index]:parameters().exclude

	return true
end

-- Lines 207-209
function MenuItemMultiChoice:left_arrow_visible()
	return self:_lowest_option_index() < self._current_index and self._enabled
end

-- Lines 211-213
function MenuItemMultiChoice:right_arrow_visible()
	return self._current_index < self:_highest_option_index() and self._enabled
end

-- Lines 215-217
function MenuItemMultiChoice:arrow_visible()
	return #self._options > 1
end

-- Lines 221-265
function MenuItemMultiChoice:setup_gui(node, row_item)
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

-- Lines 267-313
function MenuItemMultiChoice:reload(row_item, node)
	if not row_item then
		return
	end

	if node.localize_strings and self:selected_option():parameters().localize ~= false then
		row_item.option_text = managers.localization:text(self:selected_option():parameters().text_id)
	else
		row_item.option_text = self:selected_option():parameters().text_id
	end

	row_item.choice_text:set_text(utf8.to_upper(row_item.option_text))

	local arrow_alpha = row_item.highlighted and 1 or 0.5

	row_item.arrow_left:set_visible(self:arrow_visible())
	row_item.arrow_right:set_visible(self:arrow_visible())
	row_item.arrow_left:set_color(not self._enabled and row_item.disabled_color or self:left_arrow_visible() and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	row_item.arrow_right:set_color(not self._enabled and row_item.disabled_color or self:right_arrow_visible() and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	row_item.arrow_left:set_alpha(arrow_alpha)
	row_item.arrow_right:set_alpha(arrow_alpha)
	row_item.gui_text:set_color(row_item.color)
	row_item.choice_text:set_color(not self._enabled and row_item.disabled_color or self:selected_option():parameters().color or node.row_item_hightlight_color)
	row_item.choice_text:set_alpha(self._enabled and 1 or 0.75)

	if self:info_panel() == "lobby_campaign" then
		node:_reload_lobby_campaign(row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node:_reload_lobby_difficulty(row_item)
	end

	local color = self:selected_option():parameters().color1

	if color then
		local count = 1

		while color do
			row_item.choice_text:set_range_color(self:selected_option():parameters()["color_start" .. count], self:selected_option():parameters()["color_stop" .. count], color)

			count = count + 1
			color = self:selected_option():parameters()["color" .. count]
		end
	end

	return true
end

-- Lines 315-340
function MenuItemMultiChoice:highlight_row_item(node, row_item, mouse_over)
	row_item.gui_text:set_color(row_item.color)
	row_item.choice_text:set_color(not self._enabled and row_item.disabled_color or self:selected_option():parameters().color or node.row_item_hightlight_color)
	row_item.choice_text:set_alpha(self._enabled and 1 or 0.75)
	row_item.arrow_left:set_image("guis/textures/menu_arrows", 24, 0, 24, 24)
	row_item.arrow_right:set_image("guis/textures/menu_arrows", 48, 0, -24, 24)
	row_item.arrow_left:set_color(not self._enabled and row_item.disabled_color or self:left_arrow_visible() and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	row_item.arrow_right:set_color(not self._enabled and row_item.disabled_color or self:right_arrow_visible() and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	row_item.arrow_left:set_alpha(self._enabled and 1 or 0.75)
	row_item.arrow_right:set_alpha(self._enabled and 1 or 0.75)

	if self:info_panel() == "lobby_campaign" then
		node:_highlight_lobby_campaign(row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node:_highlight_lobby_difficulty(row_item)
	elseif row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(true)
	end

	return true
end

-- Lines 342-368
function MenuItemMultiChoice:fade_row_item(node, row_item, mouse_over)
	row_item.gui_text:set_color(row_item.color)
	row_item.choice_text:set_color(not self._enabled and row_item.disabled_color or self:selected_option():parameters().color or node.row_item_hightlight_color)
	row_item.choice_text:set_alpha(self._enabled and 1 or 0.75)
	row_item.arrow_left:set_image("guis/textures/menu_arrows", 0, 0, 24, 24)
	row_item.arrow_right:set_image("guis/textures/menu_arrows", 24, 0, -24, 24)
	row_item.arrow_left:set_color(not self._enabled and row_item.disabled_color or self:left_arrow_visible() and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	row_item.arrow_right:set_color(not self._enabled and row_item.disabled_color or self:right_arrow_visible() and tweak_data.screen_colors.button_stage_2 or tweak_data.screen_colors.button_stage_3)
	row_item.arrow_left:set_alpha(self._enabled and 0.5 or 0.25)
	row_item.arrow_right:set_alpha(self._enabled and 0.5 or 0.25)

	if self:info_panel() == "lobby_campaign" then
		node:_fade_lobby_campaign(row_item)
	elseif self:info_panel() == "lobby_difficulty" then
		node:_fade_lobby_difficulty(row_item)
	elseif row_item.gui_info_panel then
		row_item.gui_info_panel:set_visible(false)
	end

	return true
end

local xl_pad = 64

-- Lines 371-473
function MenuItemMultiChoice:_layout(node, row_item)
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

	return true
end

MenuItemMultiChoiceWithIcon = MenuItemMultiChoiceWithIcon or class(MenuItemMultiChoice)

-- Lines 479-483
function MenuItemMultiChoiceWithIcon:init(data_node, parameters, ...)
	MenuItemMultiChoiceWithIcon.super.init(self, data_node, parameters, ...)

	self._icon_texture = parameters and parameters.icon
end

-- Lines 485-496
function MenuItemMultiChoiceWithIcon:setup_gui(node, row_item, ...)
	MenuItemMultiChoiceWithIcon.super.setup_gui(self, node, row_item, ...)

	self._icon = row_item.gui_panel:bitmap({
		name = "icon",
		h = 16,
		y = 6,
		w = 16,
		layer = 0,
		texture = self._icon_texture,
		blend_mode = node.row_item_blend_mode
	})

	self._icon:set_right(row_item.arrow_right:x())
	self._icon:set_visible(false)
	self._icon:set_color(not self._enabled and row_item.disabled_color or self:selected_option():parameters().color or node.row_item_hightlight_color)
	self._icon:set_alpha(self._enabled and 1 or 0.75)

	return true
end

-- Lines 498-500
function MenuItemMultiChoiceWithIcon:set_icon_visible(state)
	self._icon:set_visible(state)
end
