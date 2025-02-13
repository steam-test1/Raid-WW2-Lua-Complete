RaidGUIControlCategorizedGrid = RaidGUIControlCategorizedGrid or class(RaidGUIControlGrid)
RaidGUIControlCategorizedGrid.LABEL_H = 43
RaidGUIControlCategorizedGrid.LABEL_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlCategorizedGrid.LABEL_FONT_SIZE = tweak_data.gui.font_sizes.dialg_title
RaidGUIControlCategorizedGrid.LABEL_COLOR = tweak_data.gui.colors.raid_red

function RaidGUIControlCategorizedGrid:init(parent, params)
	RaidGUIControlCategorizedGrid.super.init(self, parent, params)
end

function RaidGUIControlCategorizedGrid:_get_data()
	self._grid_panel:set_y(0)

	local grid_data = self._data_source_callback()

	if not grid_data or #grid_data == 0 then
		self._total_items = 0

		return
	end

	self._grid_data = grid_data
	self._total_items = 0
	local row_count = 0
	local labels_h = #self._grid_data * RaidGUIControlCategorizedGrid.LABEL_H

	for i = 1, #self._grid_data do
		if grid_data[i].items then
			local num_items = #grid_data[i].items
			self._total_items = self._total_items + num_items
			row_count = row_count + math.ceil(num_items / self._num_horizontal_items)
		end
	end

	self._grid_panel:set_h(row_count * (self._selected_marker_h + self._vertical_spacing) + labels_h)
end

function RaidGUIControlCategorizedGrid:_create_items()
	if self._total_items == 0 then
		return
	end

	self._grid_items = {}
	self._grid_categories = {}
	local vertical_offset = 0

	for i_category_data = 1, #self._grid_data do
		local category_data = self._grid_data[i_category_data]
		local category, items = self:_create_category(category_data, vertical_offset)

		table.insert(self._grid_categories, {
			name = category_data.name or category_data.title,
			category = category,
			items = items
		})

		vertical_offset = vertical_offset + category:h()
	end
end

function RaidGUIControlCategorizedGrid:_create_category(category_data, vertical_offset)
	local row_count = math.ceil(#category_data.items / self._num_horizontal_items)
	local padding = self._selected_marker_h + self._vertical_spacing
	local category_name = category_data.name or "category_panel_" .. category_data.title
	local category_panel = self._grid_panel:panel({
		name = category_name,
		y = vertical_offset,
		h = RaidGUIControlCategorizedGrid.LABEL_H + row_count * padding
	})
	local backgrounds_chat_bg = tweak_data.gui.icons.backgrounds_chat_bg
	local background = category_panel:image({
		alpha = 0.4,
		name = "category_background",
		layer = -1,
		y = RaidGUIControlCategorizedGrid.LABEL_H - self._vertical_spacing / 2,
		w = category_panel:w(),
		h = category_panel:h() - RaidGUIControlCategorizedGrid.LABEL_H,
		texture = backgrounds_chat_bg.texture,
		texture_rect = backgrounds_chat_bg.texture_rect
	})
	local items = {}
	local label = self:_create_label(category_panel, {
		text = category_data.title
	})
	local item_params = clone(self._item_params)
	local horizontal_spacing = math.floor((category_panel:w() - self._num_horizontal_items * self._selected_marker_w) / (self._num_horizontal_items - 1))
	local click_callback = callback(self, self, "_on_item_clicked_callback")
	local double_click_callback = callback(self, self, "_on_item_double_clicked_callback")
	local item_selected_callback = callback(self, self, "_on_item_selected_callback")
	local mouse_enter_callback = callback(self, self, "_on_item_mouse_enter")
	local i_vertical = 1
	local i_horizontal = 1

	for i_item_data = 1, #category_data.items do
		local item_data = category_data.items[i_item_data]
		item_params.name = self._params.name .. "_grid_item_" .. i_horizontal .. "_" .. i_vertical
		item_params.x = math.floor((self._selected_marker_w + horizontal_spacing) * (i_horizontal - 1))
		item_params.y = math.floor(RaidGUIControlCategorizedGrid.LABEL_H + padding * (i_vertical - 1))
		item_params.item_w = self._item_width
		item_params.item_h = self._item_height
		item_params.selected_marker_w = self._selected_marker_w
		item_params.selected_marker_h = self._selected_marker_h
		item_params.show_amount = true
		item_params.item_idx = i_item_data
		item_params.item_clicked_callback = click_callback
		item_params.item_double_clicked_callback = double_click_callback
		item_params.item_selected_callback = item_selected_callback
		item_params.on_mouse_enter_callback = mouse_enter_callback
		local item = self:_create_item(category_panel, item_params, item_data, self._grid_params)

		table.insert(self._grid_items, item)
		table.insert(items, item)

		i_horizontal = i_horizontal + 1

		if self._num_horizontal_items < i_horizontal then
			i_horizontal = 1
			i_vertical = i_vertical + 1
		end
	end

	return category_panel, items
end

function RaidGUIControlCategorizedGrid:_on_item_mouse_enter(item, data)
	if self._selected_item and self._selected_item ~= item then
		self._selected_item:unselect()
	end
end

function RaidGUIControlCategorizedGrid:_create_label(parent, params)
	params.font = RaidGUIControlCategorizedGrid.LABEL_FONT
	params.font_size = RaidGUIControlCategorizedGrid.LABEL_FONT_SIZE
	params.color = RaidGUIControlCategorizedGrid.LABEL_COLOR
	params.h = RaidGUIControlCategorizedGrid.LABEL_H
	local item = parent:label(params)

	return item
end

function RaidGUIControlCategorizedGrid:_create_item(parent, item_params, item_data, grid_params)
	local item = parent:create_custom_control(item_params.row_class or RaidGUIControlCardBase, item_params, item_data, grid_params)

	return item
end

function RaidGUIControlCategorizedGrid:refresh_items()
	for _, grid_category in ipairs(self._grid_categories) do
		self:refresh_category(nil, grid_category)
	end
end

function RaidGUIControlCategorizedGrid:refresh_category(category_name, refresh_category)
	if not refresh_category then
		for _, grid_category in ipairs(self._grid_categories) do
			if grid_category.name == category_name then
				refresh_category = grid_category
			end
		end
	end

	if not refresh_category then
		Application:warn("[RaidGUIControlCategorizedGrid:refresh_category] Trying to refresh a nil category:", category_name)

		return
	end

	for _, grid_item in ipairs(refresh_category.items) do
		if grid_item.refresh then
			grid_item:refresh()
		end
	end
end

function RaidGUIControlCategorizedGrid:select_grid_category_by_category(category_item, dont_fire_select_callback)
	self._selected_category = category_item
end

function RaidGUIControlCategorizedGrid:select_grid_item_by_key_value(params)
	for grid_category_index, grid_category in ipairs(self._grid_categories) do
		for grid_item_index, grid_item in ipairs(grid_category.items) do
			local grid_item_data = grid_item:get_data()

			if grid_item_data[params.key] == params.value then
				self._selected_category = grid_category
				self._selected_category_idx = grid_category_index
				self._selected_item = grid_item

				self._selected_item:select(params.dont_fire_select_callback)

				self._selected_item_idx = grid_item_index
			else
				grid_item:unselect()
			end
		end
	end

	return self._selected_item
end

function RaidGUIControlCategorizedGrid:set_selected(value, dont_fire_select_callback)
	self._selected = value

	self:_unselect_all()

	if self._selected then
		self:select_grid_category_by_category(self._grid_categories[1], dont_fire_select_callback)
		self:select_grid_item_by_item(self._grid_items[1], dont_fire_select_callback)

		self._selected_category_idx = 1
		self._selected_item_idx = 1
	end
end

function RaidGUIControlCategorizedGrid:_unselect_all()
	self._selected_category = nil
	self._selected_item = nil
	self._selected_category_idx = 0
	self._selected_item_idx = 0

	for _, grid_item in ipairs(self._grid_items) do
		grid_item:unselect()
	end
end

function RaidGUIControlCategorizedGrid:move_up()
	if self._selected then
		local new_item_idx = self._selected_item_idx - self._num_horizontal_items
		local new_category_idx = self._selected_category_idx

		if new_item_idx < 1 and self._on_menu_move and self._on_menu_move.up then
			return self:_menu_move_to(self._on_menu_move.up)
		elseif new_item_idx < 1 then
			new_category_idx = new_category_idx - 1

			if new_category_idx < 1 then
				new_category_idx = #self._grid_categories
			end

			self:select_grid_category_by_category(self._grid_categories[new_category_idx])

			local num_items = #self._selected_category.items
			local last_col = num_items % self._num_horizontal_items
			local num_horizontal = new_item_idx % self._num_horizontal_items

			if num_horizontal == 0 then
				num_horizontal = self._num_horizontal_items or num_horizontal
			end

			new_item_idx = num_items + num_horizontal - last_col

			if last_col < num_horizontal then
				new_item_idx = math.clamp(new_item_idx - self._num_horizontal_items, 1, num_items)
			end
		end

		self._selected_category_idx = new_category_idx
		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._selected_category.items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlCategorizedGrid:move_down()
	if self._selected then
		local new_item_idx = self._selected_item_idx + self._num_horizontal_items
		local new_category_idx = self._selected_category_idx

		if new_item_idx > #self._selected_category.items and self._on_menu_move and self._on_menu_move.down then
			return self:_menu_move_to(self._on_menu_move.down)
		elseif new_item_idx > #self._selected_category.items then
			new_category_idx = new_category_idx + 1

			if new_category_idx > #self._grid_categories then
				new_category_idx = 1
			end

			self:select_grid_category_by_category(self._grid_categories[new_category_idx])

			local num_horizontal = new_item_idx % self._num_horizontal_items

			if num_horizontal == 0 then
				num_horizontal = self._num_horizontal_items or num_horizontal
			end

			new_item_idx = math.min(num_horizontal, #self._selected_category.items)
		end

		self._selected_category_idx = new_category_idx
		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._selected_category.items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlCategorizedGrid:move_left()
	if self._selected then
		local new_item_idx = math.max(0, self._selected_item_idx - 1)
		local new_category_idx = self._selected_category_idx

		if new_item_idx % self._num_horizontal_items == 0 and new_item_idx < 1 and self._on_menu_move and self._on_menu_move.left then
			return self:_menu_move_to(self._on_menu_move.left)
		elseif new_item_idx < 1 then
			new_category_idx = new_category_idx - 1

			if new_category_idx < 1 then
				new_category_idx = #self._grid_categories
			end

			self:select_grid_category_by_category(self._grid_categories[new_category_idx])

			new_item_idx = #self._selected_category.items
		end

		self._selected_category_idx = new_category_idx
		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._selected_category.items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlCategorizedGrid:move_right()
	if self._selected then
		local new_item_idx = math.max(1, self._selected_item_idx + 1)
		local new_category_idx = self._selected_category_idx

		if self._selected_item_idx % self._num_horizontal_items == 0 and new_item_idx > #self._selected_category.items and self._on_menu_move and self._on_menu_move.right then
			return self:_menu_move_to(self._on_menu_move.right)
		elseif new_item_idx > #self._selected_category.items then
			new_category_idx = new_category_idx + 1

			if new_category_idx > #self._grid_categories then
				new_category_idx = 1
			end

			self:select_grid_category_by_category(self._grid_categories[new_category_idx])

			new_item_idx = 1
		end

		self._selected_category_idx = new_category_idx
		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._selected_category.items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlCategorizedGrid:_calculate_selected_item_position()
	if not self._selected_item or not self._params.scrollable_area_ref then
		return
	end

	self._inner_panel = self._params.scrollable_area_ref._inner_panel
	self._outer_panel = self._params.scrollable_area_ref._object
	self._scrollbar = self._params.scrollable_area_ref._scrollbar
	local inner_panel_y = self._inner_panel:y()
	local category_y = self._selected_category.category:y()
	local selected_item_bottom = category_y + self._selected_item:bottom()
	local selected_item_y = category_y + self._selected_item:y()
	local inner_panel_bottom = math.abs(self._inner_panel:y()) + self._outer_panel:h()
	local outer_panel_height = self._outer_panel:h()

	if selected_item_y < math.abs(inner_panel_y) then
		self._inner_panel:set_y(-selected_item_y)
	elseif inner_panel_y <= 0 and inner_panel_bottom < selected_item_bottom then
		self._inner_panel:set_y(-(selected_item_bottom - outer_panel_height))
	end

	local new_y = self._inner_panel:y()
	local ep_h = self._inner_panel:h()

	self._inner_panel:set_y(new_y)

	local scroll_y = self._outer_panel:h() * -new_y / ep_h

	self._scrollbar:set_y(scroll_y)
end
