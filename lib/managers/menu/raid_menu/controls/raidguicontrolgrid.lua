RaidGUIControlGrid = RaidGUIControlGrid or class(RaidGUIControl)
RaidGUIControlGrid.DEFAULT_BORDER_PADDING = 10
RaidGUIControlGrid.DEFAULT_ITEM_PADDING = 16
RaidGUIControlGrid.PAGING_PANEL_HEIGHT = 25
RaidGUIControlGrid.PAGING_STEPPER_WIDTH = 100
RaidGUIControlGrid.SCROLL_STEP = 30

function RaidGUIControlGrid:init(parent, params)
	RaidGUIControlGrid.super.init(self, parent, params)

	RaidGUIControlGrid.control = self

	if not params.grid_params then
		Application:error("[RaidGUIControlGrid:init] grid specific parameters not specified for grid: ", params.name)

		return
	end

	if not params.grid_params.data_source_callback then
		Application:error("[RaidGUIControlGrid:init] Data source callback not specified for grid: ", params.name)

		return
	end

	self._grid_panel = self._panel:panel({
		x = 0,
		y = 0,
		w = self._grid_control_width
	})
	self._object = self._grid_panel

	self._object:layer(self._panel:layer() - 100)

	self._pointer_type = "arrow"
	self._data_source_callback = self._params.grid_params.data_source_callback
	self._on_click_callback = self._params.grid_params.on_click_callback
	self._on_double_click_callback = self._params.grid_params.on_double_click_callback
	self._on_select_callback = self._params.grid_params.on_select_callback
	self._grid_params = self._params.grid_params or {}
	self._vertical_spacing = self._params.grid_params.vertical_spacing or 5
	self._item_params = self._params.item_params or {}
	self._item_width = self._item_params.item_w or 1
	self._item_height = self._item_params.item_h or 1
	self._selected_marker_w = self._item_params.selected_marker_w
	self._selected_marker_h = self._item_params.selected_marker_h
	self._num_horizontal_items = math.floor(self._grid_panel:w() / self._selected_marker_w)

	self:_get_data()
	self:_create_items()
end

function RaidGUIControlGrid:close()
end

function RaidGUIControlGrid:_get_data()
	self._grid_panel:set_y(0)

	local grid_data = self._data_source_callback()

	if not grid_data or #grid_data == 0 then
		self._total_items = 0

		return
	end

	self._grid_data = grid_data
	self._total_items = #grid_data
	local row_count = math.ceil(self._total_items / self._num_horizontal_items)

	self._grid_panel:set_h(row_count * (self._selected_marker_h + self._vertical_spacing))
end

function RaidGUIControlGrid:_create_items()
	if self._total_items == 0 then
		return
	end

	local item_count = 0
	local i_vertical = 1
	local i_horizontal = 1
	self._grid_items = {}
	local item_params = clone(self._item_params)
	local horizontal_spacing = math.floor((self._grid_panel:w() - self._num_horizontal_items * self._selected_marker_w) / (self._num_horizontal_items - 1))

	for i_item_data = 1, #self._grid_data do
		local item_data = self._grid_data[i_item_data]
		item_params.name = self._params.name .. "_grid_item_" .. i_horizontal .. "_" .. i_vertical
		item_params.x = (self._selected_marker_w + horizontal_spacing) * (i_horizontal - 1)
		item_params.y = (self._selected_marker_h + self._vertical_spacing) * (i_vertical - 1)
		item_params.item_w = self._item_width
		item_params.item_h = self._item_height
		item_params.selected_marker_w = self._selected_marker_w
		item_params.selected_marker_h = self._selected_marker_h
		item_params.show_amount = true
		item_params.item_selected_callback = callback(self, self, "_on_item_selected_callback")
		item_params.item_clicked_callback = callback(self, self, "_on_item_clicked_callback")
		item_params.item_double_clicked_callback = callback(self, self, "_on_item_double_clicked_callback")
		item_params.item_idx = i_item_data
		local item = self:_create_item(item_params, item_data, self._grid_params)

		table.insert(self._grid_items, item)

		i_horizontal = i_horizontal + 1

		if self._num_horizontal_items < i_horizontal then
			i_horizontal = 1
			i_vertical = i_vertical + 1
		end
	end
end

function RaidGUIControlGrid:_create_item(item_params, item_data, grid_params)
	local item = self._grid_panel:create_custom_control(item_params.row_class or RaidGUIControlCardBase, item_params, item_data, grid_params)

	if item.set_card then
		item:set_card(item_data)
	end

	return item
end

function RaidGUIControlGrid:_delete_items()
	self._grid_items = {}
	self._selected_item = nil

	self._grid_panel:clear()
end

function RaidGUIControlGrid:highlight_on()
end

function RaidGUIControlGrid:highlight_off()
end

function RaidGUIControlGrid:refresh_data()
	self:_delete_items()
	self:_get_data()
	self:_create_items()
end

function RaidGUIControlGrid:select_grid_item_by_item(grid_item, dont_fire_select_callback)
	if self._selected_item then
		self._selected_item:unselect()
	end

	self._selected_item = grid_item

	if self._selected_item then
		self._selected_item:select(dont_fire_select_callback)
	end
end

function RaidGUIControlGrid:select_grid_item_by_key_value(params)
	for grid_item_index, grid_item in ipairs(self._grid_items) do
		local grid_item_data = grid_item:get_data()

		if grid_item_data[params.key] == params.value then
			self._selected_item = grid_item

			self._selected_item:select(params.dont_fire_select_callback)

			self._selected_item_idx = grid_item_index
		else
			grid_item:unselect()
		end
	end

	return self._selected_item
end

function RaidGUIControlGrid:selected_grid_item()
	return self._selected_item
end

function RaidGUIControlGrid:_on_item_clicked_callback(item_data, key_field_name)
	self:select_grid_item_by_key_value({
		dont_fire_select_callback = true,
		key = key_field_name,
		value = item_data[key_field_name]
	})

	if self._on_click_callback then
		self._on_click_callback(item_data)
	end
end

function RaidGUIControlGrid:_on_item_double_clicked_callback(item_data, key_field_name)
	if self._on_double_click_callback then
		self._on_double_click_callback(item_data)
	end
end

function RaidGUIControlGrid:_on_item_selected_callback(item_idx, item_data)
	if self._on_select_callback then
		self._on_select_callback(item_idx, item_data)
	end
end

function RaidGUIControlGrid:set_selected(value, dont_fire_select_callback)
	self._selected = value

	self:_unselect_all()

	if self._selected then
		self:select_grid_item_by_item(self._grid_items[1], dont_fire_select_callback)

		self._selected_item_idx = 1
	end
end

function RaidGUIControlGrid:_unselect_all()
	self._selected_item = nil
	self._selected_item_idx = 0

	for _, grid_item in ipairs(self._grid_items) do
		grid_item:unselect()
	end
end

function RaidGUIControlGrid:move_up()
	if self._selected then
		local new_item_idx = self._selected_item_idx - self._num_horizontal_items

		if self._selected_item_idx == 0 then
			-- Nothing
		elseif new_item_idx < 1 then
			new_item_idx = #self._grid_items
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlGrid:move_down()
	if self._selected then
		local new_item_idx = self._selected_item_idx + self._num_horizontal_items

		if self._selected_item_idx == 0 then
			-- Nothing
		elseif new_item_idx > #self._grid_items and self._filtering_controls_panel and self._filter_stepper then
			self:_unselect_all()
			self._filter_stepper:set_selected(true)

			return true
		elseif new_item_idx > #self._grid_items then
			new_item_idx = 1
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlGrid:move_left()
	if self._selected then
		local new_item_idx = self._selected_item_idx - 1

		if self._selected_item_idx == 0 then
			-- Nothing
		elseif new_item_idx % self._num_horizontal_items == 0 and new_item_idx < 1 and self._on_menu_move and self._on_menu_move.left then
			return self:_menu_move_to(self._on_menu_move.left)
		elseif new_item_idx < 1 then
			new_item_idx = #self._grid_items
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlGrid:move_right()
	if self._selected then
		local new_item_idx = self._selected_item_idx + 1

		if self._selected_item_idx == 0 then
			-- Nothing
		elseif self._selected_item_idx % self._num_horizontal_items == 0 and new_item_idx > #self._grid_items and self._on_menu_move and self._on_menu_move.right then
			return self:_menu_move_to(self._on_menu_move.right)
		elseif new_item_idx > #self._grid_items then
			new_item_idx = 1
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])
		self:_calculate_selected_item_position()

		return true
	end
end

function RaidGUIControlGrid:_calculate_selected_item_position()
	if not self._selected_item or not self._params.scrollable_area_ref then
		return
	end

	self._inner_panel = self._params.scrollable_area_ref._inner_panel
	self._outer_panel = self._params.scrollable_area_ref._object
	self._scrollbar = self._params.scrollable_area_ref._scrollbar
	local inner_panel_y = self._inner_panel:y()
	local selected_item_bottom = self._selected_item:bottom()
	local selected_item_y = self._selected_item:y()
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

function RaidGUIControlGrid:confirm_pressed()
end
