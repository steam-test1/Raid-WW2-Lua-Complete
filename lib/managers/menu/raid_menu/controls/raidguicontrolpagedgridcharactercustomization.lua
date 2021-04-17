RaidGUIControlPagedGridCharacterCustomization = RaidGUIControlPagedGridCharacterCustomization or class(RaidGUIControl)
RaidGUIControlPagedGridCharacterCustomization.DEFAULT_BORDER_PADDING = 10
RaidGUIControlPagedGridCharacterCustomization.DEFAULT_ITEM_PADDING = 16
RaidGUIControlPagedGridCharacterCustomization.PAGING_PANEL_HEIGHT = 25
RaidGUIControlPagedGridCharacterCustomization.PAGING_STEPPER_WIDTH = 100

function RaidGUIControlPagedGridCharacterCustomization:init(parent, params)
	RaidGUIControlPagedGridCharacterCustomization.super.init(self, parent, params)

	RaidGUIControlPagedGridCharacterCustomization.control = self

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

	self._num_horizontal_items = 3
	self._num_vertical_items = 4
	self._items_per_page = self._num_horizontal_items * self._num_vertical_items
	self._filter = 1

	self:_get_data()

	self._current_page = 1

	self:_create_paging_controls()
	self:_create_filtering_controls()
	self:_create_items()
end

function RaidGUIControlPagedGridCharacterCustomization:close()
end

function RaidGUIControlPagedGridCharacterCustomization:mouse_moved(o, x, y)
	return self._grid_panel:mouse_moved(o, x, y)
end

function RaidGUIControlPagedGridCharacterCustomization:mouse_released(o, button, x, y)
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

function RaidGUIControlPagedGridCharacterCustomization:_get_data()
	local grid_data = self._data_source_callback()
	self._grid_data = {}

	for index, part_data in pairs(grid_data) do
		local add_check = false

		if self._filter == 1 and not part_data.locked then
			add_check = true
		elseif self._filter == 2 and (not part_data.locked or part_data.locked == CharacterCustomizationManager.LOCKED_NOT_OWNED) then
			add_check = true
		elseif self._filter == 3 then
			add_check = true
		end

		if add_check then
			table.insert(self._grid_data, part_data)
		end
	end

	self._total_items = #self._grid_data
	self._total_pages = math.ceil(self._total_items / self._items_per_page)

	self:_refresh_paging_control()
	self:_refresh_filtering_control()
end

function RaidGUIControlPagedGridCharacterCustomization:_create_grid_panel()
	local grid_params = clone(self._params)
	grid_params.name = grid_params.name .. "_grid"
	grid_params.layer = self._panel:layer() + 1
	grid_params.x = 0
	grid_params.y = 0
	grid_params.h = self._params.h - RaidGUIControlPagedGridCharacterCustomization.PAGING_PANEL_HEIGHT
	self._grid_panel = self._paged_grid_panel:panel(grid_params, true)
end

function RaidGUIControlPagedGridCharacterCustomization:_create_items()
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

function RaidGUIControlPagedGridCharacterCustomization:_create_item(item_params, item_data, grid_params)
	local item_class = RaidGUIControlCustomizationPiece
	local item = self._grid_panel:create_custom_control(item_class, item_params, item_data, grid_params)

	return item
end

function RaidGUIControlPagedGridCharacterCustomization:_create_paging_controls()
	if self._paging_controls_panel then
		self._paging_controls_panel:clear()
	end

	self._current_page = 1

	if self._grid_params.use_paging then
		self._paging_controls_panel_params = {
			visible = true,
			name = self._params.name .. "_paging_controls_panel",
			x = self._params.w / 2 + 25,
			y = self._grid_panel:h(),
			w = self._params.w / 2 - 25,
			h = RaidGUIControlPagedGridCharacterCustomization.PAGING_PANEL_HEIGHT
		}
		self._paging_controls_panel = self._paged_grid_panel:panel(self._paging_controls_panel_params)
		self._page_stepper_params = {
			h = 25,
			y = 0,
			x = 0,
			name = self._params.name .. "_page_stepper_stepper",
			w = self._paging_controls_panel:w(),
			on_item_selected_callback = callback(self, self, "on_item_selected_grid_page"),
			data_source_callback = callback(self, self, "data_source_grid_page_stepper"),
			color = tweak_data.menu.raid_red,
			highlight_color = Color.white,
			arrow_color = tweak_data.menu.raid_red,
			arrow_highlight_color = Color.white,
			button_w = MissionJoinGui.FILTER_BUTTON_W,
			button_h = MissionJoinGui.FILTER_BUTTON_H,
			stepper_w = self._paging_controls_panel:w(),
			background_color = RaidOptions.BACKGROUND_COLOR_UNSELECTED,
			on_menu_move = {
				up = self._params.name .. "_grid",
				down = self._params.name .. "_grid",
				left = self._params.name .. "_filter_stepper_stepper"
			}
		}
		self._page_stepper = self._paging_controls_panel:stepper(self._page_stepper_params)
	end

	self:_show_hide_paging()
end

function RaidGUIControlPagedGridCharacterCustomization:data_source_grid_page_stepper()
	local pages = {}

	for i_page = 1, self._total_pages do
		table.insert(pages, {
			text = i_page .. "/" .. self._total_pages,
			value = i_page
		})
	end

	return pages
end

function RaidGUIControlPagedGridCharacterCustomization:on_item_selected_grid_page(item)
	self._current_page = item.value

	self:refresh_data()
end

function RaidGUIControlPagedGridCharacterCustomization:_refresh_paging_control()
	if self._page_stepper then
		self._page_stepper:refresh_data()
		self._page_stepper:select_item_by_value(self._current_page)
	end

	self:_show_hide_paging()
end

function RaidGUIControlPagedGridCharacterCustomization:_show_hide_paging()
	if self._paging_controls_panel then
		if self._total_pages <= 1 then
			self._paging_controls_panel = nil
		else
			self:_create_paging_controls()
		end
	end
end

function RaidGUIControlPagedGridCharacterCustomization:_create_filtering_controls()
	if self._filtering_controls_panel then
		self._filtering_controls_panel:clear()
	end

	self._filtering_controls_panel_params = {
		visible = true,
		x = 0,
		name = self._params.name .. "_filtering_controls_panel",
		y = self._grid_panel:h(),
		w = self._params.w / 2 - 25,
		h = RaidGUIControlPagedGridCharacterCustomization.PAGING_PANEL_HEIGHT
	}
	self._filtering_controls_panel = self._paged_grid_panel:panel(self._filtering_controls_panel_params)
	self._filter_stepper_params = {
		h = 25,
		y = 0,
		x = 0,
		name = self._params.name .. "_filter_stepper_stepper",
		w = self._filtering_controls_panel:w(),
		on_item_selected_callback = callback(self, self, "on_item_selected_grid_filter"),
		data_source_callback = callback(self, self, "data_source_grid_filter_stepper"),
		color = tweak_data.menu.raid_red,
		highlight_color = Color.white,
		arrow_color = tweak_data.menu.raid_red,
		arrow_highlight_color = Color.white,
		button_w = MissionJoinGui.FILTER_BUTTON_W,
		button_h = MissionJoinGui.FILTER_BUTTON_H,
		stepper_w = self._filtering_controls_panel:w(),
		background_color = RaidOptions.BACKGROUND_COLOR_UNSELECTED,
		on_menu_move = {
			up = self._params.name .. "_grid",
			down = self._params.name .. "_grid",
			right = self._params.name .. "_page_stepper_stepper"
		}
	}
	self._filter_stepper = self._filtering_controls_panel:stepper(self._filter_stepper_params)

	if self._filtering_controls_panel then
		-- Nothing
	end
end

function RaidGUIControlPagedGridCharacterCustomization:data_source_grid_filter_stepper()
	local filters = {}

	table.insert(filters, {
		value = 1,
		text = self:translate("character_customization_filter_equipable", true)
	})
	table.insert(filters, {
		value = 2,
		text = self:translate("character_customization_filter_character", true)
	})
	table.insert(filters, {
		value = 3,
		text = self:translate("character_customization_filter_all", true)
	})

	return filters
end

function RaidGUIControlPagedGridCharacterCustomization:on_item_selected_grid_filter(item)
	if self._filter == item.value then
		return
	end

	self._filter = item.value
	self._current_page = 1

	self:refresh_data()
end

function RaidGUIControlPagedGridCharacterCustomization:_refresh_filtering_control()
	if self._filter_stepper then
		self._filter_stepper:refresh_data()
		self._filter_stepper:select_item_by_value(self._filter)
	end
end

function RaidGUIControlPagedGridCharacterCustomization:select_grid_item_by_item(grid_item)
	if self._selected_item then
		self._selected_item:unselect()
	end

	self._selected_item = grid_item

	if self._selected_item then
		self._selected_item:select()
	end
end

function RaidGUIControlPagedGridCharacterCustomization:_delete_items()
	self._grid_items = {}
	self._selected_item = nil

	self._grid_panel:clear()
end

function RaidGUIControlPagedGridCharacterCustomization:refresh_data()
	self:_delete_items()
	self:_get_data()
	self:_create_items()
end

function RaidGUIControlPagedGridCharacterCustomization:get_filter_value()
	return self._filter
end

function RaidGUIControlPagedGridCharacterCustomization:set_selected(value)
	self._selected = value

	self:_unselect_all()

	if self._selected then
		self:select_grid_item_by_item(self._grid_items[1])

		self._selected_item_idx = 1
	end
end

function RaidGUIControlPagedGridCharacterCustomization:_unselect_all()
	self._selected_item = nil
	self._selected_item_idx = 0

	for _, grid_item in ipairs(self._grid_items) do
		grid_item:unselect()
	end
end

function RaidGUIControlPagedGridCharacterCustomization:move_up()
	if self._selected then
		local new_item_idx = self._selected_item_idx - self._num_horizontal_items

		if self._selected_item_idx == 0 then
			if self._filter_stepper:is_selected() then
				self._filter_stepper:move_up()
				self:_unselect_all()
				self:select_grid_item_by_item(self._grid_items[1])

				self._selected_item_idx = 1

				return true
			elseif self._page_stepper:is_selected() then
				self._page_stepper:move_up()
				self:_unselect_all()
				self:select_grid_item_by_item(self._grid_items[1])

				self._selected_item_idx = 1

				return true
			end
		elseif new_item_idx < 1 and self._on_menu_move and self._on_menu_move.up then
			return self:_menu_move_to(self._on_menu_move.up)
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])

		return true
	end
end

function RaidGUIControlPagedGridCharacterCustomization:move_down()
	if self._selected then
		local new_item_idx = self._selected_item_idx + self._num_horizontal_items

		if self._selected_item_idx == 0 then
			if self._filter_stepper:is_selected() then
				self._filter_stepper:move_down()
				self:_unselect_all()
			elseif self._page_stepper:is_selected() then
				self._page_stepper:move_down()
				self:_unselect_all()
			end

			return self:_menu_move_to(self._on_menu_move.down)
		elseif new_item_idx > #self._grid_items and self._filtering_controls_panel and self._filter_stepper then
			self:_unselect_all()
			self._filter_stepper:set_selected(true)

			return true
		elseif new_item_idx > #self._grid_items and self._on_menu_move and self._on_menu_move.down then
			return self:_menu_move_to(self._on_menu_move.down)
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])

		return true
	end
end

function RaidGUIControlPagedGridCharacterCustomization:move_left()
	if self._selected then
		local new_item_idx = self._selected_item_idx - 1

		if self._selected_item_idx == 0 then
			new_item_idx = 0

			if self._filter_stepper:is_selected() and self._filter_stepper:is_selected_control() then
				self._filter_stepper:move_left()

				return true
			elseif self._page_stepper:is_selected() and self._page_stepper:is_selected_control() then
				self._page_stepper:move_left()

				return true
			elseif self._filter_stepper:is_selected() and not self._filter_stepper:is_selected_control() then
				self:_unselect_all()
				self._filter_stepper:set_selected(false)
				self._page_stepper:set_selected(true)

				return true
			elseif self._page_stepper:is_selected() and not self._page_stepper:is_selected_control() then
				self:_unselect_all()
				self._filter_stepper:set_selected(true)
				self._page_stepper:set_selected(false)

				return true
			end
		elseif new_item_idx % self._num_horizontal_items == 0 and new_item_idx < 1 and self._on_menu_move and self._on_menu_move.left then
			return self:_menu_move_to(self._on_menu_move.left)
		elseif new_item_idx < 1 then
			new_item_idx = #self._grid_items
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])

		return true
	end
end

function RaidGUIControlPagedGridCharacterCustomization:move_right()
	if self._selected then
		local new_item_idx = self._selected_item_idx + 1

		if self._selected_item_idx == 0 then
			new_item_idx = 0

			if self._filter_stepper:is_selected() and self._filter_stepper:is_selected_control() then
				self._filter_stepper:move_right()

				return true
			elseif self._page_stepper:is_selected() and self._page_stepper:is_selected_control() then
				self._page_stepper:move_right()

				return true
			elseif self._filter_stepper:is_selected() and not self._filter_stepper:is_selected_control() then
				self:_unselect_all()
				self._filter_stepper:set_selected(false)
				self._page_stepper:set_selected(true)

				return true
			elseif self._page_stepper:is_selected() and not self._page_stepper:is_selected_control() then
				self:_unselect_all()
				self._filter_stepper:set_selected(true)
				self._page_stepper:set_selected(false)

				return true
			end
		elseif self._selected_item_idx % self._num_horizontal_items == 0 and new_item_idx > #self._grid_items and self._on_menu_move and self._on_menu_move.right then
			return self:_menu_move_to(self._on_menu_move.right)
		elseif new_item_idx > #self._grid_items then
			new_item_idx = 1
		end

		self._selected_item_idx = new_item_idx

		self:select_grid_item_by_item(self._grid_items[new_item_idx])

		return true
	end
end

function RaidGUIControlPagedGridCharacterCustomization:confirm_pressed()
	if self._selected then
		if self._selected_item_idx == 0 then
			self._filter_stepper:confirm_pressed()
		elseif self._selected_item then
			self._selected_item:confirm_pressed()
		end
	end
end
