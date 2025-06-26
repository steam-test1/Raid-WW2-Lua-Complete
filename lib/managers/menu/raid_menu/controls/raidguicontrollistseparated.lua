RaidGUIControlListSeparated = RaidGUIControlListSeparated or class(RaidGUIControlSingleSelectList)
RaidGUIControlListSeparated.SEPARATOR_HEIGHT = 1
RaidGUIControlListSeparated.SEPARATOR_UNSELECTED_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlListSeparated.SEPARATOR_SELECTED_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlListSeparated.SEPARATOR_LEFT = "list_separator_left"
RaidGUIControlListSeparated.SEPARATOR_CENTER = "list_separator_center"
RaidGUIControlListSeparated.SEPARATOR_RIGHT = "list_separator_right"

function RaidGUIControlListSeparated:init(parent, params)
	params.separator_height = params.separator_height or RaidGUIControlListSeparated.SEPARATOR_HEIGHT
	params.vertical_spacing = params.separator_height + (params.vertical_spacing or 0)
	params.padding_top = params.separator_height + (params.padding_top or 0)
	self._special_action_callback = params.special_action_callback
	self._selected_callback = params.selected_callback
	self._unselected_callback = params.unselected_callback
	self._separator_items = {}

	RaidGUIControlListSeparated.super.init(self, parent, params)
end

function RaidGUIControlListSeparated:refresh_data()
	self._object:stop()
	RaidGUIControlListSeparated.super.refresh_data(self)
end

function RaidGUIControlListSeparated:_delete_items()
	self._separator_items = {}

	RaidGUIControlListSeparated.super._delete_items(self)
end

function RaidGUIControlListSeparated:_create_item(item_class, item_params, item_data)
	if self._special_action_callback then
		item_params.special_action_callback = self._special_action_callback
	end

	if #self._list_items == 0 then
		self:_create_separator()
	end

	local item = RaidGUIControlListSeparated.super._create_item(self, item_class, item_params, item_data)

	if item then
		self:_create_separator(item)
	end

	return item
end

function RaidGUIControlListSeparated:_create_separator(parent_item)
	local separator = self._object:three_cut_bitmap({
		y = parent_item and parent_item:bottom(),
		h = self._list_params.separator_height,
		left = self.SEPARATOR_LEFT,
		center = self.SEPARATOR_CENTER,
		right = self.SEPARATOR_RIGHT,
		color = self.SEPARATOR_UNSELECTED_COLOR
	})

	table.insert(self._separator_items, separator)
end

function RaidGUIControlListSeparated:set_selected(value, dont_trigger_selected_callback)
	self._selected = value

	if self._selected_item and self._selected then
		self._selected_item:unselect()
	end

	if self._selected then
		self._selected_item_idx = self._selected_item_idx or 1

		self:select_item_by_index(self._selected_item_idx, dont_trigger_selected_callback, true)

		if self._selected_callback then
			self._selected_callback()
		end
	end

	if not self._selected then
		if self._list_items then
			for idx, item in pairs(self._list_items) do
				item:unselect()

				if idx == self._selected_item_idx then
					item:highlight_off()
				end
			end
		end

		if self._unselected_callback then
			self._unselected_callback()
		end

		self._highlighted_item_idx = nil
	end
end

function RaidGUIControlListSeparated:_select_item(item, dont_trigger_selected_callback)
	RaidGUIControlListSeparated.super._select_item(self, item, dont_trigger_selected_callback)

	self._highlighted_item_idx = self._selected_item_idx

	self:_highlight_separators()
end

function RaidGUIControlListSeparated:on_mouse_enter(button, data)
	RaidGUIControlListSeparated.super.on_mouse_enter(self, button, data)

	local index = data.key

	if index then
		self._highlighted_item_idx = index
	end

	self:_highlight_separators()
end

function RaidGUIControlListSeparated:on_mouse_exit(button, data)
	local index = data.key

	if index and index == self._highlighted_item_idx then
		self._highlighted_item_idx = nil
	end

	self:_highlight_separators()
end

function RaidGUIControlListSeparated:_highlight_separators()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight"))
end

function RaidGUIControlListSeparated:_animate_highlight()
	local duration = 0.12
	local t = 0
	local top_idx = self._highlighted_item_idx or -1
	local bottom_idx = top_idx + 1
	local selected_color = self.SEPARATOR_SELECTED_COLOR
	local item = self._list_items[self._highlighted_item_idx]

	if item and item.data then
		local data = item:data()
		selected_color = data.separator_highlight_color or selected_color
	end

	local start_colors = {}

	for _, separator in ipairs(self._separator_items) do
		table.insert(start_colors, separator:color())
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)

		for i, separator in ipairs(self._separator_items) do
			local target_color = (i == top_idx or i == bottom_idx) and selected_color or self.SEPARATOR_UNSELECTED_COLOR
			local current_color = math.lerp(start_colors[i], target_color, progress)

			separator:set_color(current_color)
		end
	end

	for i, separator in ipairs(self._separator_items) do
		local target_color = (i == top_idx or i == bottom_idx) and selected_color or self.SEPARATOR_UNSELECTED_COLOR

		separator:set_color(target_color)
	end
end
