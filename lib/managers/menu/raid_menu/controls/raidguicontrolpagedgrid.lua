RaidGUIControlPagedGrid = RaidGUIControlPagedGrid or class(RaidGUIControl)
RaidGUIControlPagedGrid.DEFAULT_BORDER_PADDING = 10
RaidGUIControlPagedGrid.DEFAULT_ITEM_PADDING = 16
RaidGUIControlPagedGrid.PAGING_PANEL_HEIGHT = 25
RaidGUIControlPagedGrid.PAGING_STEPPER_WIDTH = 100

-- Lines 33-90
function RaidGUIControlPagedGrid:init(parent, params)
	RaidGUIControlPagedGrid.super.init(self, parent, params)

	RaidGUIControlPagedGrid.control = self

	if not params.grid_params then
		Application:error("[RaidGUIControlPagedGrid:init] grid specific parameters not specified for grid: ", params.name)

		return
	end

	if not params.grid_params.data_source_callback then
		Application:error("[RaidGUIControlPagedGrid:init] Data source callback not specified for grid: ", params.name)

		return
	end

	self._paged_grid_panel = self._panel:panel(self._params)
	self._object = self._paged_grid_panel
	self._pointer_type = "arrow"
	self._data_source_callback = self._params.grid_params.data_source_callback
	self._grid_params = self._params.grid_params or {}
	self._border_padding = self._params.grid_params.border_padding or RaidGUIControlPagedGrid.DEFAULT_BORDER_PADDING
	self._item_padding = self._params.grid_params.item_padding or RaidGUIControlPagedGrid.DEFAULT_ITEM_PADDING
	self._data_source_filter_callback = self._grid_params.data_source_filter_callback
	self._filter_value = self._grid_params.filter_value
	self._item_params = self._params.item_params or {}
	self._item_width = self._item_params.w + self._item_padding
	self._item_height = self._item_params.h + self._item_padding

	self:_create_grid_panel()

	self._num_horizontal_items = math.floor((self._grid_panel:w() - 2 * self._border_padding + self._item_padding) / self._item_width)
	self._num_vertical_items = math.floor((self._grid_panel:h() - 2 * self._border_padding + self._item_padding) / self._item_height)
	self._items_per_page = self._num_horizontal_items * self._num_vertical_items

	self:_get_data()

	self._current_page = 1

	if self._grid_params.use_paging then
		self:_create_paging_controls()
	end

	if self._data_source_filter_callback then
		self:_create_filter_controls()
	end

	self:_create_items()
end

-- Lines 93-94
function RaidGUIControlPagedGrid:close()
end

-- Lines 97-105
function RaidGUIControlPagedGrid:_create_grid_panel()
	local grid_params = clone(self._params)
	grid_params.name = grid_params.name .. "_grid"
	grid_params.layer = self._panel:layer() + 1
	grid_params.x = 0
	grid_params.y = 0
	grid_params.h = self._params.h - RaidGUIControlPagedGrid.PAGING_PANEL_HEIGHT
	self._grid_panel = self._paged_grid_panel:panel(grid_params, true)
end

-- Lines 108-137
function RaidGUIControlPagedGrid:_get_data()
	local grid_data = self._data_source_callback()

	if not grid_data or #grid_data == 0 then
		self._total_items = 0
		self._total_pages = 1

		Application:error("[RaidGUIControlPagedGrid:_create_items] No items for grid: ", self._params.name)

		return
	end

	if self._filter_value == self:translate(ChallengeCardsTweakData.FILTER_ALL_ITEMS) then
		self._grid_data = grid_data
	else
		self._grid_data = {}

		for key, value in pairs(grid_data) do
			if self:translate(value.card_type) == self._filter_value then
				table.insert(self._grid_data, value)
			end
		end
	end

	self._total_items = #self._grid_data
	self._total_pages = math.ceil(self._total_items / self._items_per_page)
end

-- Lines 139-172
function RaidGUIControlPagedGrid:_create_items()
	local item_count = 0
	local i_vertical = 1
	local i_horizontal = 1
	self._grid_items = {}
	local item_params = clone(self._item_params)
	local first_item = (self._current_page - 1) * self._items_per_page + 1
	local last_item = math.min(self._total_items, self._current_page * self._items_per_page)

	for i_item_data = first_item, last_item do
		local item_data = self._grid_data[i_item_data]
		item_params.name = self._params.name .. "_grid_item_" .. i_horizontal .. "_" .. i_vertical
		item_params.x = self._border_padding + (i_horizontal - 1) * self._item_width
		item_params.y = self._border_padding + (i_vertical - 1) * self._item_height
		item_params.color = Color.blue
		local item = self:_create_item(item_params, item_data, self._grid_params)

		table.insert(self._grid_items, item)

		i_horizontal = i_horizontal + 1

		if self._num_horizontal_items < i_horizontal then
			i_horizontal = 1
			i_vertical = i_vertical + 1

			if self._num_vertical_items < i_vertical then
				return
			end
		end
	end
end

-- Lines 174-182
function RaidGUIControlPagedGrid:_create_item(item_params, item_data, grid_params)
	local item_class = RaidGUIControlCard
	local item = self._grid_panel:create_custom_control(item_class, item_params, item_data, grid_params)

	return item
end

-- Lines 184-202
function RaidGUIControlPagedGrid:_create_paging_controls()
	if self._paging_controls_panel then
		self._paging_controls_panel:clear()
	end

	if self._total_pages >= 1 then
		self._current_page = 1
		self._paging_controls_panel_params = {
			visible = true,
			x = 0,
			name = self._params.name .. "_paging_controls_panel",
			y = self._grid_panel:h(),
			w = self._params.w,
			h = RaidGUIControlPagedGrid.PAGING_PANEL_HEIGHT
		}
		self._paging_controls_panel = self._paged_grid_panel:panel(self._paging_controls_panel_params)
		self._page_stepper_params = {
			h = 25,
			y = 0,
			name = self._params.name .. "_page_stepper_stepper",
			x = self._params.w / 2 + 25,
			w = RaidGUIControlPagedGrid.PAGING_STEPPER_WIDTH,
			w = self._paging_controls_panel:w() / 2 - 50,
			on_item_selected_callback = callback(self, self, "on_item_selected_grid_page"),
			data_source_callback = callback(self, self, "data_source_grid_page_stepper")
		}
		self._page_stepper = self._paging_controls_panel:stepper(self._page_stepper_params)
	end
end

-- Lines 204-219
function RaidGUIControlPagedGrid:_create_filter_controls()
	if not self._paging_controls_panel then
		self._paging_controls_panel_params = {
			visible = true,
			x = 0,
			name = self._params.name .. "_paging_controls_panel",
			y = self._grid_panel:h(),
			w = self._params.w,
			h = RaidGUIControlPagedGrid.PAGING_PANEL_HEIGHT
		}
		self._paging_controls_panel = self._paged_grid_panel:panel(self._paging_controls_panel_params)
	end

	if self._paging_controls_panel then
		self._filter_stepper_params = {
			h = 25,
			y = 0,
			x = 0,
			name = self._params.name .. "_filter_stepper_stepper",
			w = RaidGUIControlPagedGrid.PAGING_STEPPER_WIDTH,
			w = self._paging_controls_panel:w() / 2 - 50,
			on_item_selected_callback = callback(self, self, "on_item_selected_grid_filter"),
			data_source_callback = callback(self, self, "data_source_grid_filter_stepper")
		}
		self._filter_stepper = self._paging_controls_panel:stepper(self._filter_stepper_params)
	end
end

-- Lines 222-226
function RaidGUIControlPagedGrid:_delete_items()
	self._grid_items = {}
	self._selected_item = nil

	self._grid_panel:clear()
end

-- Lines 229-231
function RaidGUIControlPagedGrid:mouse_moved(o, x, y)
	return self._grid_panel:mouse_moved(o, x, y)
end

-- Lines 234-247
function RaidGUIControlPagedGrid:mouse_released(o, button, x, y)
	for _, grid_item in ipairs(self._grid_items) do
		if grid_item:inside(x, y) then
			local handled = grid_item:mouse_released(o, button, x, y)

			if handled then
				self:select_grid_item_by_item(grid_item)

				return true
			end
		end
	end

	return false
end

-- Lines 250-252
function RaidGUIControlPagedGrid:highlight_on()
end

-- Lines 255-257
function RaidGUIControlPagedGrid:highlight_off()
end

-- Lines 259-264
function RaidGUIControlPagedGrid:refresh_data()
	self:_delete_items()
	self:_get_data()
	self:_create_items()
end

-- Lines 266-275
function RaidGUIControlPagedGrid:select_grid_item_by_item(grid_item)
	if self._selected_item then
		self._selected_item:unselect()
	end

	self._selected_item = grid_item

	if self._selected_item then
		self._selected_item:select()
	end
end

-- Lines 277-279
function RaidGUIControlPagedGrid:selected_grid_item()
	return self._selected_item
end

-- Lines 282-288
function RaidGUIControlPagedGrid:on_item_selected_grid_page(item)
	self._current_page = item.value

	self:refresh_data()
end

-- Lines 291-298
function RaidGUIControlPagedGrid:data_source_grid_page_stepper()
	local pages = {}

	for i_page = 1, self._total_pages do
		table.insert(pages, {
			text = i_page .. "/" .. self._total_pages,
			value = i_page
		})
	end

	return pages
end

-- Lines 300-305
function RaidGUIControlPagedGrid:on_item_selected_grid_filter(item)
	self._filter_value = item.value
	self._current_page = 1

	self:refresh_data()
end

-- Lines 308-313
function RaidGUIControlPagedGrid:data_source_grid_filter_stepper()
	if self._data_source_filter_callback then
		return self._data_source_filter_callback()
	end
end
