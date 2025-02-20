require("lib/managers/menu/raid_menu/controls/RaidGUIPanel")

RaidGUIControlTableRow = RaidGUIControlTableRow or class(RaidGUIPanel)

function RaidGUIControlTableRow:init(parent, params, row_data, table_params)
	RaidGUIControlTableRow.super.init(self, parent, params)

	self.cells = {}
	self.row_data = row_data
	self._selected = false
	self._type = "raid_gui_control_table_row"
	local cell_params = clone(params)
	cell_params.layer = self:layer() + 150
	cell_params.y = 0
	self._selector_mark = self:rect({
		visible = false,
		y = 0,
		w = 2,
		x = 0,
		h = params.height,
		color = tweak_data.gui.colors.raid_red
	})
	local x = 0

	for column_index, column_data in ipairs(table_params.columns) do
		local cell_class = column_data.cell_class or RaidGUIControlTableCell
		cell_params.name = self._params.name .. "_column_" .. column_index
		cell_params.x = x + (column_data.padding or 0)
		cell_params.w = column_data.w - 2 * (column_data.padding or 0)

		if row_data[column_index] and row_data[column_index].text then
			cell_params.text = row_data[column_index].text or ""
			cell_params.color = row_data[column_index].color or column_data.color or Color.white
		end

		cell_params.align = column_data.align
		cell_params.vertical = column_data.vertical
		cell_params.on_cell_click_callback = column_data.on_cell_click_callback
		cell_params.on_cell_double_click_callback = column_data.on_cell_double_click_callback
		cell_params.value = row_data[column_index].value or nil

		for column_data_item_key, column_data_value in pairs(column_data) do
			cell_params[column_data_item_key] = column_data_value
		end

		local cell = self:create_custom_control(cell_class, cell_params, row_data, table_params)

		table.insert(self.cells, cell)

		x = x + column_data.w
	end
end

function RaidGUIControlTableRow:get_cells()
	return self.cells
end

function RaidGUIControlTableRow:mouse_moved(o, x, y)
	if self:selected() then
		return
	end

	if self:inside(x, y) then
		if not self._mouse_inside then
			self:on_mouse_over(x, y)
		end

		return true, self._pointer_type
	end

	if self._mouse_inside then
		self:on_mouse_out(x, y)
	end

	return false
end

function RaidGUIControlTableRow:selected()
	return self._selected
end

function RaidGUIControlTableRow:on_mouse_over(x, y)
	self._mouse_inside = true

	self:highlight_on()
end

function RaidGUIControlTableRow:on_mouse_out(x, y)
	self._mouse_inside = false

	self:highlight_off()
end

function RaidGUIControlTableRow:highlight_on()
	if self._selected then
		return
	end

	for _, cell in pairs(self.cells) do
		cell:highlight_on()
	end

	if self._params.highlight_background_color and self._params.background_color then
		self:set_background_color(self._params.highlight_background_color)
	end
end

function RaidGUIControlTableRow:highlight_off()
	if self._selected then
		return
	end

	for _, cell in pairs(self.cells) do
		cell:highlight_off()
	end

	if self._params.highlight_background_color and self._params.background_color then
		self:set_background_color(self._params.background_color)
	end
end

function RaidGUIControlTableRow:select_on()
	for _, cell in pairs(self.cells) do
		cell:select_on()
	end

	if self._params.selected_background_color and self._params.background_color then
		self:set_background_color(self._params.selected_background_color)
	end

	if self._params.use_selector_mark then
		self._selector_mark:show()
	end
end

function RaidGUIControlTableRow:select_off()
	for _, cell in pairs(self.cells) do
		cell:select_off()
	end

	if self._params.selected_background_color and self._params.background_color then
		self:set_background_color(self._params.background_color)
	end

	if self._params.use_selector_mark then
		self._selector_mark:hide()
	end
end

function RaidGUIControlTableRow:select()
	self._selected = true

	self:select_on()
	self:highlight_on()
end

function RaidGUIControlTableRow:unselect()
	self._selected = false

	self:select_off()
	self:highlight_off()
end

function RaidGUIControlTableRow:confirm_pressed()
	for _, cell in pairs(self.cells) do
		if cell.on_double_click then
			return cell:on_double_click(cell)
		end
	end
end

function RaidGUIControlTableRow:mouse_released(o, button, x, y)
	return self:on_mouse_released()
end

function RaidGUIControlTableRow:on_mouse_released(button)
	if self._params.on_row_click_callback then
		self._params.on_row_click_callback(self.row_data, self._params.row_index)
	end

	return true
end

function RaidGUIControlTableRow:mouse_double_click(button)
	if self._params.on_row_double_click_callback then
		self._params.on_row_double_click_callback(self.row_data, self._params.row_index)
	end

	return true
end

function RaidGUIControlTableRow:get_data()
	return self.row_data
end
