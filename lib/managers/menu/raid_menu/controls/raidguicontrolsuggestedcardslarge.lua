RaidGUIControlSuggestedCardsLarge = RaidGUIControlSuggestedCardsLarge or class(RaidGUIControl)

function RaidGUIControlSuggestedCardsLarge:init(parent, params)
	RaidGUIControlSuggestedCardsLarge.super.init(self, parent, params)

	RaidGUIControlSuggestedCardsLarge.control = self
	self._grid_params = self._params.grid_params or {}
	self._item_params = self._params.item_params or {}
	self._item_width = self._item_params.item_w
	self._item_height = self._item_params.item_h
	self._selected_marker_w = self._item_params.selected_marker_w
	self._selected_marker_h = self._item_params.selected_marker_h
	self._grid_items = {}

	self:layout()
end

function RaidGUIControlSuggestedCardsLarge:layout()
	self._suggested_cards_panel = self._panel:panel({
		name = "suggested_cards_panel_large_" .. self._name,
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	}, true)
	self._object = self._suggested_cards_panel

	self:_create_items()
end

function RaidGUIControlSuggestedCardsLarge:_create_items()
	local item_data = {}
	local item_params = {}
	local item_spacing = math.floor((self._params.w - RaidGUIControlSuggestedCards.PLAYERS_COUNT * self._selected_marker_w) / (RaidGUIControlSuggestedCards.PLAYERS_COUNT - 1))

	for i = 1, RaidGUIControlSuggestedCards.PLAYERS_COUNT do
		item_params.x = (self._selected_marker_w + item_spacing) * (i - 1)
		item_params.y = 0
		item_params.item_width = self._item_width
		item_params.item_height = self._item_height
		item_params.selected_marker_w = self._selected_marker_w
		item_params.selected_marker_h = self._selected_marker_h
		item_params.name = "suggested_card_" .. i
		item_params.peer_id = i
		item_params.item_selected_callback = callback(self, self, "_item_selected_callback")
		item_params.item_idx = i
		item_data = managers.challenge_cards:get_suggested_cards()[i]
		local item = self._suggested_cards_panel:create_custom_control(RaidGUIControlCardSuggestedLarge, item_params, item_data, self._grid_params)

		if item_data then
			item:set_card(item_data)
		end

		self._grid_items[i] = item
	end
end

function RaidGUIControlSuggestedCardsLarge:_item_selected_callback(item_idx)
	self:select_item(item_idx)
end

function RaidGUIControlSuggestedCardsLarge:_delete_items()
	for index, control in pairs(self._suggested_cards_panel._controls) do
		-- Nothing
	end

	self._suggested_cards_panel:clear()
end

function RaidGUIControlSuggestedCardsLarge:refresh_data()
	self:_delete_items()
	self:_create_items()
end

function RaidGUIControlSuggestedCardsLarge:mouse_released(o, button, x, y)
	for _, grid_item in ipairs(self._grid_items) do
		if grid_item:inside(x, y) then
			local handled = grid_item:mouse_released(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	return false
end

function RaidGUIControlSuggestedCardsLarge:mouse_moved(o, x, y)
	if self._grid_items then
		for i = 1, #self._grid_items do
			local handled = self._grid_items[i]:mouse_moved(o, x, y)

			return handled
		end
	end

	return false
end

function RaidGUIControlSuggestedCardsLarge:move_selection_right()
	local index = self._selected_item._params.item_idx
	local start_index = index

	while true do
		index = (index + 1) % (#self._grid_items + 1)

		if index == 0 then
			index = 1
		end

		local selected_item = self:select_item(index)

		if selected_item then
			return selected_item:get_data()
		end

		if index == start_index then
			return
		end
	end
end

function RaidGUIControlSuggestedCardsLarge:move_selection_left()
	local index = self._selected_item._params.item_idx
	local start_index = index

	while true do
		index = index - 1

		if index == 0 then
			index = #self._grid_items
		end

		local selected_item = self:select_item(index)

		if selected_item then
			return selected_item:get_data()
		end

		if index == start_index then
			return
		end
	end
end

function RaidGUIControlSuggestedCardsLarge:select_first_available_item()
	for i_item_data = 1, #self._grid_items do
		local selected_item = self:select_item(i_item_data)

		if selected_item then
			return selected_item
		end
	end
end

function RaidGUIControlSuggestedCardsLarge:select_item(item_idx)
	if not self._grid_items[item_idx] or not self._grid_items[item_idx]:get_data() or self._grid_items[item_idx]:get_data().key_name == ChallengeCardsManager.CARD_PASS_KEY_NAME then
		return
	end

	for i_item_data = 1, #self._grid_items do
		if i_item_data == item_idx then
			self._grid_items[i_item_data]:select(true)

			self._selected_item = self._grid_items[i_item_data]
		else
			self._grid_items[i_item_data]:unselect()
		end
	end

	return self._selected_item
end

function RaidGUIControlSuggestedCardsLarge:selected_item()
	return self._selected_item
end

function RaidGUIControlSuggestedCardsLarge:lock_selected_grid_item()
	if self._selected_item then
		self._locked_item = self._selected_item

		self._locked_item:lock()
	end
end

function RaidGUIControlSuggestedCardsLarge:unlock_grid_item()
	if self._locked_item then
		self._locked_item:unlock()

		self._locked_item = nil
	end
end

function RaidGUIControlSuggestedCardsLarge:locked_grid_item()
	return self._locked_item
end
