RaidGUIControlList = RaidGUIControlList or class(RaidGUIControl)
RaidGUIControlList.DIVIDER_HEIGHT = 2

-- Lines 5-36
function RaidGUIControlList:init(parent, params)
	RaidGUIControlList.super.init(self, parent, params)

	self._on_click_callback = params.on_item_clicked_callback
	self._on_double_click_callback = params.on_item_double_clicked_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._data_source_callback = params.data_source_callback
	self._list_params = params
	self._loop_items = params.loop_items
	self._list_items = {}

	self:_create_list_panel()
	self:_create_items()

	self._selection_enabled = self._list_params.selection_enabled
	self._abort_selection = false
end

-- Lines 38-40
function RaidGUIControlList:scrollable_area_post_setup(params)
	self:_reposition_selected_item()
end

-- Lines 44-46
function RaidGUIControlList:set_abort_selection(value)
	self._abort_selection = value
end

-- Lines 48-50
function RaidGUIControlList:get_abort_selection()
	return self._abort_selection
end

-- Lines 54-56
function RaidGUIControlList:close()
	self:_delete_items()
end

-- Lines 58-60
function RaidGUIControlList:get_data()
	return self._list_data
end

-- Lines 62-67
function RaidGUIControlList:_create_list_panel()
	local list_params = clone(self._params)
	list_params.name = list_params.name .. "_list"
	self._object = self._panel:panel(list_params)
end

-- Lines 69-139
function RaidGUIControlList:_create_items()
	self._list_data = self._data_source_callback()

	if not self._list_data then
		Application:error("[RaidGUIControlList:_create_items] No items for list: ", self._params.name)

		return
	end

	local selected_item = nil
	local y = self._params.padding_top or 0
	local counter = 1

	for i, item_data in ipairs(self._list_data) do
		item_data.availability_flags = item_data.availability_flags or {}
		local item_is_available = RaidGUIControl:check_item_availability(self, item_data.availability_flags)

		if item_is_available then
			local item_params = self._params.item_params or {}
			item_params.name = self._params.name .. "_list_item_" .. i
			item_params.use_unlocked = self._list_params.use_unlocked
			item_params.x = 0
			item_params.y = y
			item_params.w = self._params.w
			item_params.h = self._params.item_h or 64
			item_params.text = item_data.text
			item_params.text_id = item_data.text_id
			item_params.panel = self._object
			item_params.selectable = self._selection_enabled
			item_params.color = item_data.color
			item_params.selected_color = item_data.selected_color
			item_params.item_font = self._params.item_font
			item_params.item_font_size = self._params.item_font_size
			item_params.on_click_callback = callback(self, self, "on_item_clicked")
			item_params.on_double_click_callback = callback(self, self, "on_item_double_clicked")
			item_params.on_item_selected_callback = callback(self, self, "on_item_selected")
			item_params.on_mouse_over_sound_event = self._params.on_mouse_over_sound_event
			item_params.on_mouse_click_sound_event = self._params.on_mouse_click_sound_event

			for _, flag in pairs(item_data.availability_flags) do
				if flag == RaidGUIItemAvailabilityFlag.DEBUG_MENU_ENABLED then
					item_params.color = tweak_data.gui.colors.raid_debug
				end
			end

			local item = self:_create_item(self._params.item_class or RaidGUIControlListItem, item_params, item_data)

			table.insert(self._list_items, item)

			if item_data.selected == true then
				selected_item = item
				self._selected_item_idx = counter
			end

			y = y + item:h()

			if self._list_params and self._list_params.vertical_spacing and self._list_params.vertical_spacing > 0 then
				y = y + self._list_params.vertical_spacing
			end

			counter = counter + 1
		end
	end

	if selected_item then
		self:_select_item(selected_item, true)
	end

	self._object:fit_content_height()
end

-- Lines 141-143
function RaidGUIControlList:_create_item(item_class, item_params, item_data)
	return self._object:create_custom_control(item_class, item_params, item_data)
end

-- Lines 145-155
function RaidGUIControlList:_delete_items()
	if self._list_items then
		for _, item in ipairs(self._list_items) do
			item:close()
		end
	end

	self._list_items = {}
	self._selected = false
	self._selected_item = nil

	self._object:clear()
end

-- Lines 157-181
function RaidGUIControlList:mouse_moved(o, x, y)
	if not self:inside(x, y) then
		if self._mouse_inside then
			for _, item in ipairs(self._list_items) do
				item:on_mouse_out()
			end

			self._mouse_inside = false
		end

		return false
	end

	self._mouse_inside = true
	local used = false
	local pointer = nil

	for _, item in ipairs(self._list_items) do
		local u, p = item:mouse_moved(o, x, y)

		if not used and u then
			used = u
			pointer = p
		end
	end

	return used, pointer
end

-- Lines 183-184
function RaidGUIControlList:highlight_on()
end

-- Lines 186-187
function RaidGUIControlList:highlight_off()
end

-- Lines 189-193
function RaidGUIControlList:selected_item()
	if self._selected_item and self._selected_item:data() then
		return self._selected_item
	end
end

-- Lines 195-212
function RaidGUIControlList:_select_item(item, dont_trigger_selected_callback)
	if self._selected_item then
		self._selected_item:unselect()
	end

	self._selected_item = item

	item:select(dont_trigger_selected_callback)

	if self._on_item_selected_callback then
		-- Nothing
	end

	for list_item_idx, list_item in ipairs(self._list_items) do
		if item == list_item then
			self._selected_item_idx = list_item_idx

			break
		end
	end
end

-- Lines 214-247
function RaidGUIControlList:_reposition_selected_item()
	if self._params.scrollable_area_ref and self._selected_item then
		self._inner_panel = self._params.scrollable_area_ref._inner_panel
		self._outer_panel = self._params.scrollable_area_ref._object
		self._scrollbar = self._params.scrollable_area_ref._scrollbar
		local inner_panel_top = self._inner_panel:top()
		local outer_panel_height = self._outer_panel:h()
		local inner_panel_y = self._inner_panel:y()
		local selected_item_bottom = self._selected_item:bottom()

		if self._selected_item:y() < math.abs(inner_panel_y) then
			local new_y = self._selected_item:y()

			self._inner_panel:set_y(-new_y)
		elseif self._selected_item:bottom() >= self._outer_panel:h() + math.abs(inner_panel_y) then
			local new_y = -(self._selected_item:bottom() - self._outer_panel:h())

			self._inner_panel:set_y(new_y)
		end

		self._params.scrollable_area_ref:move_scrollbar_manually()
	end
end

-- Lines 249-253
function RaidGUIControlList:click_item(item_index)
	if self._list_items[item_index] then
		self._list_items[item_index]:on_mouse_released(Idstring("0"))
	end
end

-- Lines 255-275
function RaidGUIControlList:select_item_by_index(item_index, dont_trigger_selected_callback, regaining_focus)
	local new_item = self._list_items[item_index]

	if self._selected_item == new_item and not regaining_focus then
		return
	end

	if self._selected_item then
		self._selected_item:unselect()
	end

	self._selected_item = new_item

	if self._selected_item then
		self:_select_item(self._selected_item, dont_trigger_selected_callback)

		self._selected_item_idx = item_index
	end

	if self._on_item_selected_callback then
		-- Nothing
	end
end

-- Lines 277-296
function RaidGUIControlList:select_item_by_value(item_value)
	if self._selected_item then
		self._selected_item:unselect()
	end

	if self._list_items then
		for item_index, item in ipairs(self._list_items) do
			if item:data().value == item_value then
				self._selected_item = item

				self._selected_item:select()

				self._selected_item_idx = item_index

				self:_reposition_selected_item()

				if self._on_item_selected_callback then
					-- Nothing
				end

				return
			end
		end
	end
end

-- Lines 298-311
function RaidGUIControlList:on_item_clicked(button, item, data, skip_select)
	if self:get_abort_selection() then
		Application:trace("[RaidGUIControlList:on_item_clicked] ABORT SELECTION")

		return
	end

	self:_select_item(item, true)

	if self._on_click_callback then
		self._on_click_callback(data)
	end
end

-- Lines 313-326
function RaidGUIControlList:on_item_double_clicked(button, item, data, skip_select)
	if self:get_abort_selection() then
		Application:trace("[RaidGUIControlList:on_item_double_clicked] ABORT SELECTION")

		return
	end

	if not skip_select then
		self:_select_item(item)
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(data)
	end
end

-- Lines 328-337
function RaidGUIControlList:on_item_selected(item, data)
	if self:get_abort_selection() then
		Application:trace("[RaidGUIControlList:on_item_selected] ABORT SELECTION")

		return
	end

	if self._on_item_selected_callback then
		self._on_item_selected_callback(data)
	end
end

-- Lines 339-344
function RaidGUIControlList:refresh_data()
	local cached_selected_value = self._selected

	self:_delete_items()
	self:_create_items()

	self._selected = cached_selected_value
end

-- Lines 347-372
function RaidGUIControlList:set_selected(value, dont_trigger_selected_callback)
	if self._selected_item and self._selected then
		self._selected_item:unfocus()
	end

	self._selected = value

	if self._selected then
		self._selected_item_idx = self._selected_item_idx or 1

		self:select_item_by_index(self._selected_item_idx, dont_trigger_selected_callback, true)
	end

	if not self._selected and self._list_items then
		for _, item in pairs(self._list_items) do
			if _ ~= self._selected_item_idx then
				item:unfocus()
			else
				item:highlight_off()
			end
		end
	end
end

-- Lines 374-376
function RaidGUIControlList:selected_item_index()
	return self._selected_item_idx
end

-- Lines 378-387
function RaidGUIControlList:move_up()
	if self:get_abort_selection() then
		Application:trace("[RaidGUIControlList:move_up] ABORT SELECTION")

		return
	end

	if self._selected then
		return self:select_previous_row()
	end
end

-- Lines 389-395
function RaidGUIControlList:select_previous_row()
	if self:_previous_row_idx() then
		self:select_item_by_index(self._selected_item_idx)
		self:_reposition_selected_item()

		return true
	end
end

-- Lines 397-412
function RaidGUIControlList:move_down()
	if self:get_abort_selection() then
		Application:trace("[RaidGUIControlList:move_down] ABORT SELECTION")

		return
	end

	if self._selected then
		local next_row_selected = self:select_next_row()

		if not next_row_selected then
			return RaidGUIControlList.super.move_down(self)
		end

		return next_row_selected
	end
end

-- Lines 414-420
function RaidGUIControlList:select_next_row()
	if self:_next_row_idx() then
		self:select_item_by_index(self._selected_item_idx)
		self:_reposition_selected_item()

		return true
	end
end

-- Lines 422-429
function RaidGUIControlList:confirm_pressed()
	if self._selected and self._selected_item then
		self._selected_item:confirm_pressed()

		return true
	end
end

-- Lines 431-432
function RaidGUIControlList:special_btn_pressed(...)
end

-- Lines 435-469
function RaidGUIControlList:_previous_row_idx()
	self._new_selected_item_idx = self._selected_item_idx - 1

	if self._new_selected_item_idx <= 0 then
		if self._loop_items then
			for counter = #self._list_items, 1, -1 do
				if self._list_items[counter]:enabled() then
					self._selected_item_idx = counter

					return true
				end
			end
		end
	else
		for counter = self._new_selected_item_idx, 1, -1 do
			if self._list_items[counter]:enabled() then
				self._selected_item_idx = counter

				return true
			end
		end

		if self._loop_items then
			for counter = #self._list_items, self._selected_item_idx + 1, -1 do
				if self._list_items[counter]:enabled() then
					self._selected_item_idx = counter

					return true
				end
			end
		end
	end

	return false
end

-- Lines 471-506
function RaidGUIControlList:_next_row_idx()
	self._new_selected_item_idx = self._selected_item_idx + 1

	if self._new_selected_item_idx > #self._list_items then
		if self._loop_items then
			for counter = 1, self._selected_item_idx - 1 do
				if self._list_items[counter]:enabled() then
					self._selected_item_idx = counter

					return true
				end
			end
		end
	else
		for counter = self._new_selected_item_idx, #self._list_items do
			if self._list_items[counter]:enabled() then
				self._selected_item_idx = counter

				return true
			end
		end

		if self._loop_items then
			for counter = 1, self._selected_item_idx - 1 do
				if self._list_items[counter]:enabled() then
					self._selected_item_idx = counter

					return true
				end
			end
		end
	end

	return false
end
