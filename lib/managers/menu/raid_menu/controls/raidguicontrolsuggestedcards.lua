RaidGUIControlSuggestedCards = RaidGUIControlSuggestedCards or class(RaidGUIControl)
RaidGUIControlSuggestedCards.PLAYERS_COUNT = 4

function RaidGUIControlSuggestedCards:init(parent, params)
	RaidGUIControlSuggestedCards.super.init(self, parent, params)

	RaidGUIControlSuggestedCards.control = self
	self._grid_params = self._params.grid_params or {}
	self._item_params = self._params.item_params or {}
	self._border_padding = 10
	self._item_width = self._item_params.w or 90
	self._item_height = self._item_params.h or 135
	self._grid_items = {}

	self:layout()
end

function RaidGUIControlSuggestedCards:layout()
	self._suggested_cards_panel = self._panel:panel({
		name = "suggested_cards_panel",
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	}, true)
	self._object = self._suggested_cards_panel

	self:_create_items()
end

function RaidGUIControlSuggestedCards:_create_items()
	local item_data = {}
	local item_params = {}
	local horizontal_spacing = math.floor((self._object:w() - RaidGUIControlSuggestedCards.PLAYERS_COUNT * self._item_width) / (RaidGUIControlSuggestedCards.PLAYERS_COUNT - 1))

	for i = 1, RaidGUIControlSuggestedCards.PLAYERS_COUNT do
		item_params.x = (self._item_width + horizontal_spacing) * (i - 1)
		item_params.y = 0
		item_params.item_w = self._item_width
		item_params.item_h = self._item_height
		item_params.name = "suggested_card_" .. i
		item_params.peer_id = i
		item_data = managers.challenge_cards:get_suggested_cards()[i]
		local peer_name = ""

		if managers.network:session():all_peers()[i] then
			peer_name = managers.network:session():all_peers()[i]:name()
			item_params.peer_name = peer_name
		else
			item_params.peer_name = ""
		end

		self._label_peer_name = self._suggested_cards_panel:label({
			name = "label_peer_name",
			h = 30,
			wrap = true,
			align = "center",
			vertical = "center",
			x = item_params.x,
			y = self._suggested_cards_panel:h() - 30,
			w = self._item_width,
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.filter,
			text = utf8.to_upper(peer_name)
		})
		local item = self._suggested_cards_panel:create_custom_control(RaidGUIControlCardSuggested, item_params, item_data, self._grid_params)

		if item_data then
			item:set_card(item_data)
		end

		self._grid_items[i] = item
	end
end

function RaidGUIControlSuggestedCards:_delete_items()
	for index, control in pairs(self._suggested_cards_panel._controls) do
		-- Nothing
	end

	self._suggested_cards_panel:clear()
end

function RaidGUIControlSuggestedCards:refresh_data()
	self:_delete_items()
	self:_create_items()
end

function RaidGUIControlSuggestedCards:mouse_released(o, button, x, y)
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

function RaidGUIControlSuggestedCards:select_grid_item_by_item(grid_item)
	if self._selected_item then
		self._selected_item:unselect()
	end

	self._selected_item = grid_item

	if self._selected_item then
		self._selected_item:select()
	end
end

function RaidGUIControlSuggestedCards:selected_grid_item()
	for index, grid_item in ipairs(self._grid_items) do
		if grid_item == self._selected_item then
			return self._selected_item, index
		end
	end

	return nil, nil
end

function RaidGUIControlSuggestedCards:lock_selected_grid_item()
	if self._selected_item then
		self._locked_item = self._selected_item

		self._locked_item:lock()
	end
end

function RaidGUIControlSuggestedCards:unlock_grid_item()
	if self._locked_item then
		self._locked_item:unlock()

		self._locked_item = nil
	end
end

function RaidGUIControlSuggestedCards:locked_grid_item()
	return self._locked_item
end

function RaidGUIControlSuggestedCards:mouse_moved(o, x, y)
	if self._grid_items then
		for i = 1, #self._grid_items do
			local handled = self._grid_items[i]:mouse_moved(o, x, y)

			return handled
		end
	end

	return false
end
