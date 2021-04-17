RaidGUIControlTabs = RaidGUIControlTabs or class(RaidGUIControl)
RaidGUIControlTabs.DEFAULT_HEIGHT = 64
RaidGUIControlTabs.BOTTOM_LINE_HEIGHT = 5
RaidGUIControlTabs.ACTIVE_LINE_COLOR = tweak_data.gui.colors.raid_red

-- Lines 7-50
function RaidGUIControlTabs:init(parent, params)
	RaidGUIControlTabs.super.init(self, parent, params)

	self._tab_width = self._params.tab_width or parent:w() / #self._params.tabs_params
	self._tab_height = self._params.tab_height or RaidGUIControlTabs.DEFAULT_HEIGHT
	local panel_params = {
		name = "tabs_control",
		x = self._params.x,
		y = self._params.y,
		w = self._tab_width * #self._params.tabs_params,
		h = self._tab_height,
		layer = self._panel:layer() + 1
	}
	self._object = self._panel:panel(panel_params)

	if self._params.icon then
		self._icon_title = self._object:image({
			name = "tabs_control_icon_title",
			y = 0,
			vertical = "center",
			x = 0,
			w = self._params.icon.texture_rect[3],
			h = self._params.icon.texture_rect[4],
			texture = self._params.icon.texture,
			texture_rect = self._params.icon.texture_rect
		})

		self._object:set_w(self._object:w() + self._icon_title:w())
	end

	self._on_click_callback = self._params.on_click_callback
	self._item_class = self._params.item_class or RaidGUIControlTab
	self._items = {}
	self._initial_tab_idx = self._params.initial_tab_idx or 1

	self:_create_items()

	if self._item_class.needs_bottom_line() then
		self:_create_bottom_line()
	end

	self:_initial_tab_selected(self._initial_tab_idx)

	self._dont_trigger_special_buttons = self._params.dont_trigger_special_buttons or false
	self._abort_selection = false
end

-- Lines 52-74
function RaidGUIControlTabs:_create_items()
	if self._params.tabs_params then
		for index, tab_params in ipairs(self._params.tabs_params) do
			tab_params.x = (index - 1) * self._tab_width + (self._icon_title and self._icon_title:w() or 0)
			tab_params.y = 0
			tab_params.w = self._tab_width
			tab_params.h = self._tab_height
			tab_params.tab_select_callback = callback(self, self, "_tab_selected")
			tab_params.tab_align = self._params.tab_align
			tab_params.tab_idx = index
			tab_params.callback_param = tab_params.callback_param
			tab_params.parent_control_ref = self
			tab_params.tab_font_size = self._params.tab_font_size
			local item = self._object:create_custom_control(self._params.item_class or RaidGUIControlTab, tab_params, self._params)

			if index ~= #self._params.tabs_params and self._item_class.needs_divider() then
				item:set_divider()
			end

			table.insert(self._items, item)
		end
	end
end

-- Lines 76-88
function RaidGUIControlTabs:_create_bottom_line()
	local bottom_line_params = {
		name = "bottom_line",
		x = (self._initial_tab_idx - 1) * self._tab_width,
		y = self._object:h() - RaidGUIControlTabs.BOTTOM_LINE_HEIGHT,
		w = self._tab_width,
		h = RaidGUIControlTabs.BOTTOM_LINE_HEIGHT,
		color = RaidGUIControlTabs.ACTIVE_LINE_COLOR,
		layer = self._object:layer() + 3
	}
	self._bottom_line = self._object:rect(bottom_line_params)
	self._line_movement_t = 0
end

-- Lines 90-101
function RaidGUIControlTabs:_initial_tab_selected(tab_idx)
	for tab_index, tab in ipairs(self._items) do
		if tab_index == tab_idx then
			tab:select()
		else
			tab:unselect()
		end

		self._selected_item_idx = tab_idx
	end
end

-- Lines 104-119
function RaidGUIControlTabs:_tab_selected(tab_idx, callback_param)
	if self:get_abort_selection() then
		Application:trace("[RaidGUIControlTabs:_tab_selected] ABORT SELECTION")

		return
	end

	self:_initial_tab_selected(tab_idx)
	self._on_click_callback(callback_param)

	if self._bottom_line then
		self._bottom_line:stop()

		self._line_movement_t = 0

		self._bottom_line:animate(callback(self, self, "_move_bottom_line"))
	end
end

-- Lines 121-125
function RaidGUIControlTabs:_unselect_all()
	for _, item in ipairs(self._items) do
		item:unselect()
	end
end

-- Lines 127-129
function RaidGUIControlTabs:set_abort_selection(value)
	self._abort_selection = value
end

-- Lines 131-133
function RaidGUIControlTabs:get_abort_selection()
	return self._abort_selection
end

-- Lines 138-147
function RaidGUIControlTabs:set_selected(value)
	self._selected = value

	self:_unselect_all()

	if self._selected then
		self._selected_item_idx = self._selected_item_idx or self._initial_tab_idx
		local callback_param = self._items[self._selected_item_idx]:get_callback_param()

		self:_tab_selected(self._selected_item_idx, callback_param)
	end
end

-- Lines 149-154
function RaidGUIControlTabs:move_up()
	if self._selected and self._on_menu_move and self._on_menu_move.up then
		local result, target = self:_menu_move_to(self._on_menu_move.up)

		return result, target
	end
end

-- Lines 156-161
function RaidGUIControlTabs:move_down()
	if self._selected and self._on_menu_move and self._on_menu_move.down then
		local result, target = self:_menu_move_to(self._on_menu_move.down)

		return result, target
	end
end

-- Lines 163-181
function RaidGUIControlTabs:_move_left()
	if not self._enabled then
		return
	end

	if self._selected_item_idx <= 1 then
		self._selected_item_idx = 1

		return true
	else
		self._selected_item_idx = self._selected_item_idx - 1
	end

	local callback_param = self._items[self._selected_item_idx]:get_callback_param()

	self:_tab_selected(self._selected_item_idx, callback_param)

	return true
end

-- Lines 183-199
function RaidGUIControlTabs:_move_right()
	if not self._enabled then
		return
	end

	if self._selected_item_idx == #self._items then
		return true
	else
		self._selected_item_idx = self._selected_item_idx + 1
	end

	local callback_param = self._items[self._selected_item_idx]:get_callback_param()

	self:_tab_selected(self._selected_item_idx, callback_param)

	return true
end

-- Lines 203-221
function RaidGUIControlTabs:_move_bottom_line()
	local duration = 0.2
	local t = duration - (1 - self._line_movement_t) * duration
	local original_x = self._bottom_line:x()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_x = Easing.quartic_in_out(t, original_x, (self._selected_item_idx - 1) * self._tab_width - original_x, duration)

		self._bottom_line:set_x(current_x)

		self._line_movement_t = t / duration
	end

	self._bottom_line:set_x((self._selected_item_idx - 1) * self._tab_width)

	self._line_movement_t = 1
end
