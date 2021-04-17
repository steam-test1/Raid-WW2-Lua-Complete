RaidGUIControlListActive = RaidGUIControlListActive or class(RaidGUIControlList)

-- Lines 5-11
function RaidGUIControlListActive:init(parent, params)
	RaidGUIControlListActive.super.init(self, parent, params)

	self._special_action_callback = self._params.special_action_callback
	self._selected_callback = self._params.selected_callback
	self._unselected_callback = self._params.unselected_callback
end

-- Lines 13-28
function RaidGUIControlListActive:activate_item_by_value(item_value)
	if self._active_item then
		self._active_item:deactivate()

		self._active_item = nil
	end

	if self._list_items then
		for _, item in pairs(self._list_items) do
			local item_data = item:data()

			if item_data.value == item_value then
				self._active_item = item

				self._active_item:activate()
			end
		end
	end
end

-- Lines 30-32
function RaidGUIControlListActive:activate_item_by_index(index)
	self:activate_item_by_value(self._list_items[index]:data().value)
end

-- Lines 34-36
function RaidGUIControlListActive:get_active_item()
	return self._active_item
end

-- Lines 38-50
function RaidGUIControlListActive:get_active_item_index()
	if self._active_item and self._list_items then
		for index, item in pairs(self._list_items) do
			if item == self._active_item then
				return index
			end
		end
	end

	return nil
end

-- Lines 52-58
function RaidGUIControlListActive:_create_item(item_class, item_params, item_data)
	if self._special_action_callback then
		item_params.special_action_callback = self._special_action_callback
	end

	return self._object:create_custom_control(item_class, item_params, item_data)
end

-- Lines 61-92
function RaidGUIControlListActive:set_selected(value, dont_trigger_selected_callback)
	self._selected = value

	if self._selected_item and self._selected then
		self._selected_item:unselect()
	end

	if self._selected then
		self._selected_item_idx = self:get_active_item_index() or 1

		self:select_item_by_index(self._selected_item_idx, dont_trigger_selected_callback, true)

		if self._selected_callback then
			self._selected_callback()
		end
	end

	if not self._selected then
		if self._list_items then
			for _, item in pairs(self._list_items) do
				if _ ~= self._selected_item_idx then
					item:unselect()
				else
					item:highlight_off()
				end
			end
		end

		if self._unselected_callback then
			self._unselected_callback()
		end
	end
end
