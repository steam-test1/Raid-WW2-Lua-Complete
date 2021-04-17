RaidGUIControlScrollGrid = RaidGUIControlScrollGrid or class(RaidGUIControl)
RaidGUIControlScrollGrid.DEFAULT_BORDER_PADDING = 10
RaidGUIControlScrollGrid.DEFAULT_ITEM_PADDING = 16
RaidGUIControlScrollGrid.PAGING_PANEL_HEIGHT = 25
RaidGUIControlScrollGrid.PAGING_STEPPER_WIDTH = 100
RaidGUIControlScrollGrid.SCROLL_STEP = 30

function RaidGUIControlScrollGrid:init(parent, params)
	RaidGUIControlScrollGrid.super.init(self, parent, params)

	RaidGUIControlScrollGrid.control = self

	if not params.grid_params then
		Application:error("[RaidGUIControlScrollGrid:init] grid specific parameters not specified for grid: ", params.name)

		return
	end

	if not params.grid_params.data_source_callback then
		Application:error("[RaidGUIControlScrollGrid:init] Data source callback not specified for grid: ", params.name)

		return
	end

	self._wrapper_panel = self._panel:panel(self._params)
	self._object = self._wrapper_panel
	self._grid_control_width = self._params.w

	if self._params and self._params.grid_params and self._params.grid_params.scroll_marker_w and self._params.grid_params.scroll_marker_w > 0 then
		self._grid_control_width = self._grid_control_width - self._params.grid_params.scroll_marker_w

		self:_create_scroll_marker()
	end

	self._grid_panel = self._wrapper_panel:panel({
		x = 0,
		y = 0,
		w = self._grid_control_width
	})

	self._wrapper_panel:layer(self._grid_panel:layer() + 1)

	self._pointer_type = "arrow"
	self._data_source_callback = self._params.grid_params.data_source_callback
	self._on_click_callback = self._params.grid_params.on_click_callback
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

function RaidGUIControlScrollGrid:_create_scroll_marker()
	self._panel_scroll_marker = self._object:panel({
		w = 8,
		y = 0,
		x = self._grid_control_width + 24,
		h = self._wrapper_panel:h()
	})
	self._scroll_marker = self._panel_scroll_marker:rect({
		h = 128,
		y = 0,
		x = 0,
		w = self._panel_scroll_marker:w(),
		color = tweak_data.gui.colors.raid_grey:with_alpha(0.2)
	})
end

function RaidGUIControlScrollGrid:_check_visibility_scroll_marker()
	if self._wrapper_panel:h() < self._grid_panel:h() then
		self._panel_scroll_marker:show()
	else
		self._panel_scroll_marker:hide()
	end
end

function RaidGUIControlScrollGrid:_move_scroll_marker_location()
	local height_difference = self._grid_panel:h() - self._wrapper_panel:h()

	if height_difference == 0 then
		return
	end

	local grid_panel_bottom_y = self._grid_panel:world_bottom()
	local wrapper_bottom_y = self._wrapper_panel:world_bottom()
	local path_percentage = 1 - (grid_panel_bottom_y - wrapper_bottom_y) / height_difference

	if path_percentage < 0 then
		path_percentage = 0
	elseif path_percentage > 1 then
		path_percentage = 1
	end

	local marker_bottom_start = self._scroll_marker:h()
	local marker_bottom_end = self._panel_scroll_marker:h()

	self._scroll_marker:set_bottom((marker_bottom_end - marker_bottom_start) * path_percentage + marker_bottom_start)
end

function RaidGUIControlScrollGrid:close()
end

function RaidGUIControlScrollGrid:_get_data()
	self._grid_panel:set_y(0)
	self._scroll_marker:set_y(0)

	local grid_data = self._data_source_callback()

	if not grid_data or #grid_data == 0 then
		self._total_items = 0

		Application:error("[RaidGUIControlScrollGrid:_create_items] No items for grid: ", self._params.name)

		return
	end

	self._grid_data = grid_data
	self._total_items = #grid_data
	local row_count = math.ceil(self._total_items / self._num_horizontal_items)

	self._grid_panel:set_h(row_count * (self._selected_marker_h + self._vertical_spacing))
end

function RaidGUIControlScrollGrid:_create_items()
	self:_check_visibility_scroll_marker()

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
		item_params.item_selected_callback = callback(self, self, "_item_selected_callback")
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

function RaidGUIControlScrollGrid:_create_item(item_params, item_data, grid_params)
	local item = self._grid_panel:create_custom_control(item_params.row_class or RaidGUIControlCardBase, item_params, item_data, grid_params)

	if item.set_card then
		item:set_card(item_data)
	end

	return item
end

function RaidGUIControlScrollGrid:_delete_items()
	self._grid_items = {}
	self._selected_item = nil

	self._grid_panel:clear()
end

function RaidGUIControlScrollGrid:_item_selected_callback(item_idx)
	for i_item_data = 1, #self._grid_items do
		if i_item_data == item_idx then
			self._grid_items[i_item_data]:select()
		else
			self._grid_items[i_item_data]:unselect()
		end
	end
end

function RaidGUIControlScrollGrid:mouse_moved(o, x, y)
	return self._grid_panel:mouse_moved(o, x, y)
end

function RaidGUIControlScrollGrid:mouse_released(o, button, x, y)
	return false
end

function RaidGUIControlScrollGrid:on_mouse_scroll_up()
	if self._grid_panel:top() < 0 then
		local coord_y = self._grid_panel:y() + RaidGUIControlScrollGrid.SCROLL_STEP

		if coord_y > 1 then
			coord_y = 0
		end

		self._grid_panel:set_y(coord_y)
	end

	self:_move_scroll_marker_location()
end

function RaidGUIControlScrollGrid:on_mouse_scroll_down()
	if self._grid_panel:h() < self._wrapper_panel:h() then
		return
	end

	self._grid_panel:set_y(self._grid_panel:y() - RaidGUIControlScrollGrid.SCROLL_STEP)

	if self._grid_panel:bottom() < self._wrapper_panel:h() then
		self._grid_panel:set_bottom(self._wrapper_panel:h())
	end

	self:_move_scroll_marker_location()
end

function RaidGUIControlScrollGrid:highlight_on()
end

function RaidGUIControlScrollGrid:highlight_off()
end

function RaidGUIControlScrollGrid:refresh_data()
	self:_delete_items()
	self:_get_data()
	self:_create_items()
end

function RaidGUIControlScrollGrid:select_grid_item_by_item(grid_item)
	if self._selected_item then
		self._selected_item:unselect()
	end

	self._selected_item = grid_item

	if self._selected_item then
		self._selected_item:select()
	end
end

function RaidGUIControlScrollGrid:select_grid_item_by_key_value(params)
	for _, grid_item in ipairs(self._grid_items) do
		local grid_item_data = grid_item:get_data()

		if grid_item_data[params.key] == params.value then
			self._selected_item = grid_item

			self._selected_item:select()
		else
			grid_item:unselect()
		end
	end

	return self._selected_item
end

function RaidGUIControlScrollGrid:selected_grid_item()
	return self._selected_item
end

function RaidGUIControlScrollGrid:on_mouse_pressed(button, x, y)
	if self._scroll_marker:inside(x, y) then
		self._old_active_control = managers.raid_menu:get_active_control()

		managers.raid_menu:set_active_control(self)

		self._active = true
	end
end

function RaidGUIControlScrollGrid:on_mouse_released()
	if self._active then
		managers.raid_menu:set_active_control(self._old_active_control)

		self._active = false
		self._coord_y_from_marker_top = nil

		return true
	end
end

function RaidGUIControlScrollGrid:on_mouse_moved(o, x, y)
	if self._active then
		local coord_y_from_panel_top = y - self._panel_scroll_marker:world_y()

		if not self._coord_y_from_marker_top then
			self._coord_y_from_marker_top = y - self._scroll_marker:world_y()
		end

		self:set_value_by_y_coord(math.floor(coord_y_from_panel_top - self._coord_y_from_marker_top))
	end
end

function RaidGUIControlScrollGrid:on_mouse_out(x, y)
	RaidGUIControlScrollGrid.super.on_mouse_out(self, x, y)
end

function RaidGUIControlScrollGrid:set_value_by_y_coord(selected_coord_y)
	if selected_coord_y < 0 then
		selected_coord_y = 0
	end

	self._scroll_marker:set_y(selected_coord_y)

	if self._panel_scroll_marker:bottom() < self._scroll_marker:bottom() then
		self._scroll_marker:set_bottom(self._panel_scroll_marker:bottom())
	end
end
