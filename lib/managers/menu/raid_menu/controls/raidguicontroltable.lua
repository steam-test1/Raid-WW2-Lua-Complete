RaidGUIControlTable = RaidGUIControlTable or class(RaidGUIControl)
RaidGUIControlTable.DIVIDER_HEIGHT = 1

function RaidGUIControlTable:init(parent, params)
	RaidGUIControlTable.super.init(self, parent, params)

	if not params.table_params then
		Application:error("[RaidGUIControlTable:init] table specific parameters not specified for table: ", params.name)

		return
	end

	if not params.table_params.data_source_callback then
		Application:error("[RaidGUIControlTable:init] Data source callback not specified for table: ", params.name)

		return
	end

	self._pointer_type = "arrow"
	self._data_source_callback = params.table_params.data_source_callback
	self._on_selected_callback = params.on_selected_callback
	self._table_params = params.table_params
	self._table_rows = {}

	self:_create_table_panel()

	self._use_row_dividers = params.use_row_dividers

	self:_create_items(self._use_row_dividers)

	self._loop_items = params.loop_items
	self._autoconfirm_row = params.autoconfirm_row

	if not params.h then
		self:_fit_panel()
	end
end

function RaidGUIControlTable:is_alive()
	return self._object and alive(self._object._engine_panel)
end

function RaidGUIControlTable:close()
	self:_delete_items()
	self._table_panel:clear()
end

function RaidGUIControlTable:_create_table_panel()
	local table_params = clone(self._params)
	table_params.name = table_params.name .. "_table"
	table_params.layer = self._panel:layer() + 1
	self._table_panel = self._panel:panel(table_params)
	self._object = self._table_panel
end

function RaidGUIControlTable:_fit_panel()
	local header_height = 0
	local row_height = 0
	local dividers_height = 0

	if self._table_params.header_params then
		header_height = self._table_params.header_params.header_height
	end

	if self._table_params.row_params.height then
		row_height = self._table_params.row_params.height
	end

	if self._params.use_row_dividers then
		dividers_height = RaidGUIControlTable.DIVIDER_HEIGHT
	end

	local object_height = header_height + #self._table_rows * row_height + #self._table_rows * dividers_height

	self._object:set_h(object_height)
end

function RaidGUIControlTable:_create_items(use_row_dividers)
	local table_data = self._data_source_callback()

	if table_data and #table_data == 0 then
		-- Nothing
	end

	self._table_data = table_data
	local y = 0

	if self._table_params.header_params then
		self:_create_header()

		y = y + self._table_params.header_params.header_height
	end

	local row_height = self._table_params.row_params.height
	local row_params = {}
	row_params = clone(self._table_params.row_params)
	row_params.x = row_params.x or 0
	row_params.layer = row_params.layer or self._table_panel:layer() + 1
	row_params.color = row_params.color or Color.white
	row_params.panel = row_params.panel or self._table_panel
	row_params.row_class = row_params.row_class or self._params.row_class

	for i, row_data in ipairs(table_data) do
		row_params.name = self._params.name .. "_table_row_" .. i
		row_params.y = y
		row_params.height = row_height
		row_params.text = row_data.text
		row_params.panel = nil
		row_params.color = self._table_params.row_color
		row_params.background_color = row_params.row_background_color
		row_params.highlight_background_color = row_params.row_highlight_background_color
		row_params.selected_background_color = row_params.row_selected_background_color
		row_params.row_index = i
		row_params.use_selector_mark = self._params.use_selector_mark

		if self._table_params.alternate_row_color and i % 2 == 1 then
			row_params.color = self._table_params.alternate_row_color
		end

		if row_params.alternate_row_background_color and i % 2 == 1 then
			row_params.background_color = row_params.alternate_row_background_color
		end

		if self._table_params.row_params.row_texture_background then
			row_params.texture = self._table_params.row_params.row_texture_background
		end

		if self._table_params.row_params.row_texture_rect_background then
			row_params.texture_rect = self._table_paramsrow_params .. row_texture_rect_background
		end

		if self._table_params.row_params.row_texture_color then
			row_params.color = self._table_params.row_params.row_texture_color
		end

		row_params.w = self._table_params.w
		local row = self:_create_row(row_params, row_data, self._table_params)

		table.insert(self._table_rows, row)

		y = y + row_height + (row_params.spacing or 0)

		if use_row_dividers then
			self:_create_row_separator(y)

			y = y + RaidGUIControlTable.DIVIDER_HEIGHT
		end
	end

	if not self._params.h then
		self:_fit_panel()
	end
end

function RaidGUIControlTable:_create_header()
	local header_params = {
		y = 0,
		x = 0,
		h = self._table_params.header_params.header_height,
		layer = self._table_panel:layer() + 1,
		text_color = self._table_params.header_params.text_color,
		background_color = self._table_params.header_params.background_color,
		panel = self._table_panel
	}

	if self._table_params.header_params.background_color then
		self._header_background = self._table_panel:rect(header_params)
	end

	local header_column_params = header_params
	local x = 0
	self._header_column_items = {}
	header_params.layer = self._table_panel:layer() + 2

	for column_index, column_data in ipairs(self._table_params.columns) do
		header_column_params.name = "table_header_column_" .. column_index
		header_column_params.x = x + (column_data.header_padding or 0)
		header_column_params.w = column_data.w - 2 * (column_data.header_padding or 0)
		header_column_params.text_id = column_data.header_text_id
		header_column_params.text = column_data.header_text
		header_column_params.color = self._table_params.header_params.text_color or tweak_data.gui.colors.raid_white
		header_column_params.align = column_data.header_align
		header_column_params.vertical = column_data.header_vertical
		header_column_params.layer = self._table_panel:layer() + 10 + column_index
		header_column_params.font = self._params.table_params.header_params.font
		header_column_params.font_size = self._params.table_params.header_params.font_size
		local item = RaidGUIControlLabel:new(self._parent, header_column_params)

		table.insert(self._header_column_items, item)

		x = x + column_data.w
	end
end

function RaidGUIControlTable:_create_row(row_params, row_data, table_params)
	row_params.x = 0
	row_params.w = table_params.w
	row_params.on_row_click_callback = callback(self, self, "on_row_clicked")
	row_params.on_row_double_click_callback = callback(self, self, "on_row_double_clicked")
	local row_class = row_params.row_class or RaidGUIControlTableRow
	local row = self._table_panel:create_custom_control(row_class, row_params, row_data, table_params)

	return row
end

function RaidGUIControlTable:on_row_clicked(row_data, row_index)
	self:select_table_row_by_row_idx(row_index)

	if self._table_params.row_params.on_row_click_callback then
		self._table_params.row_params.on_row_click_callback(row_data, row_index)
	end
end

function RaidGUIControlTable:on_row_double_clicked(row_data, row_index)
	self:select_table_row_by_row_idx(row_index)

	if self._table_params.row_params.on_row_double_clicked_callback then
		self._table_params.row_params.on_row_double_clicked_callback(row_data, row_index)
	end
end

function RaidGUIControlTable:get_selected_row()
	return self._selected_row
end

function RaidGUIControlTable:_create_row_separator(y)
	local divider_line = self._table_panel:rect({
		h = 1,
		x = 0,
		y = y + 0.6,
		w = self._table_panel:w(),
		color = tweak_data.gui.colors.raid_white:with_alpha(0.25)
	})
end

function RaidGUIControlTable:_delete_items()
	self._table_rows = {}
	self._selected_row = nil

	self._table_panel:clear()
end

function RaidGUIControlTable:get_rows()
	return self._table_rows
end

function RaidGUIControlTable:get_row(i)
	return self._table_rows[i]
end

function RaidGUIControlTable:get_last_row()
	return self._table_rows and self._table_rows[#self._table_rows]
end

function RaidGUIControlTable:mouse_moved(o, x, y)
	return self._table_panel:mouse_moved(o, x, y)
end

function RaidGUIControlTable:mouse_released(o, button, x, y)
	return self._table_panel:mouse_released(o, x, y)
end

function RaidGUIControlTable:highlight_on()
end

function RaidGUIControlTable:highlight_off()
end

function RaidGUIControlTable:refresh_data()
	self:_delete_items()
	self:_create_items(self._use_row_dividers)
end

function RaidGUIControlTable:select_table_row_by_row_idx(row_index)
	if self._selected_row then
		self._selected_row:unselect()
	end

	self._selected_row = self._table_rows[row_index]

	if self._selected_row then
		self._selected_row_idx = row_index

		self._selected_row:select()
	end
end

function RaidGUIControlTable:select_table_row_by_row(table_row)
	if self._selected_row then
		self._selected_row:unselect()
	end

	self._selected_row = table_row

	self._selected_row:select()
end

function RaidGUIControlTable:selected_table_row()
	return self._selected_row
end

function RaidGUIControlTable:set_selected(value)
	self._selected = value

	self:_unselect_all()

	if self._selected then
		local rows = self:get_rows()

		if #rows > 0 then
			self._selected_row_idx = self._selected_row_idx or 1

			self:select_table_row_by_row_idx(self._selected_row_idx)
		end

		if self._on_selected_callback then
			self._on_selected_callback()
		end
	end
end

function RaidGUIControlTable:_unselect_all()
	self._selected_row = nil

	for _, row in ipairs(self._table_rows) do
		row:unselect()
	end
end

function RaidGUIControlTable:move_up()
	if self._selected and #self:get_rows() > 0 then
		local previous_row_idx = self:_previous_row_idx()

		if previous_row_idx then
			self:select_table_row_by_row_idx(self._selected_row_idx)

			if self._table_params.row_params.on_row_select_callback then
				local row_data = self._selected_row:get_data()

				self._table_params.row_params.on_row_select_callback(row_data, self._selected_row_idx)
			end

			self:_calculate_selected_item_position()

			return true
		else
			return self.super.move_up(self)
		end
	end
end

function RaidGUIControlTable:move_down()
	if self._selected and #self:get_rows() > 0 then
		local next_row = self:_next_row_idx()

		if next_row then
			self:select_table_row_by_row_idx(self._selected_row_idx)

			if self._table_params.row_params.on_row_select_callback then
				local row_data = self._selected_row:get_data()

				self._table_params.row_params.on_row_select_callback(row_data, self._selected_row_idx)
			end

			self:_calculate_selected_item_position()

			return true
		else
			return self.super.move_down(self)
		end
	end
end

function RaidGUIControlTable:move_left()
	if self._selected then
		return self.super.move_left(self)
	end
end

function RaidGUIControlTable:confirm_pressed()
	if self._selected and self._selected_row then
		self._selected_row:confirm_pressed()

		return true
	end
end

function RaidGUIControlTable:_previous_row_idx()
	self._selected_row_idx = self._selected_row_idx - 1

	if self._selected_row_idx <= 0 then
		if self._loop_items then
			self._selected_row_idx = #self._table_rows

			return true
		else
			return false
		end
	end

	return true
end

function RaidGUIControlTable:_next_row_idx()
	self._selected_row_idx = self._selected_row_idx + 1

	if self._selected_row_idx > #self._table_rows then
		if self._loop_items then
			self._selected_row_idx = 1

			return true
		else
			return false
		end
	end

	return true
end

function RaidGUIControlTable:_calculate_selected_item_position()
	self._selected_item = self._selected_row

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
		if selected_item_y < self._selected_item:h() then
			self._inner_panel:set_y(0)
		else
			self._inner_panel:set_y(-selected_item_y)
		end
	elseif inner_panel_y <= 0 and inner_panel_bottom < selected_item_bottom then
		self._inner_panel:set_y(-(selected_item_bottom - outer_panel_height))
	end

	local new_y = self._inner_panel:y()
	local ep_h = self._inner_panel:h()

	self._inner_panel:set_y(new_y)

	local scroll_y = self._outer_panel:h() * -new_y / ep_h

	self._scrollbar:set_y(scroll_y)
end
