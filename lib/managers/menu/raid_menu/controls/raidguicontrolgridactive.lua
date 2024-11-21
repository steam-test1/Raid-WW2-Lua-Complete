RaidGUIControlGridActive = RaidGUIControlGridActive or class(RaidGUIControlGrid)

function RaidGUIControlGridActive:init(parent, params)
	RaidGUIControlGridActive.super.init(self, parent, params)
end

function RaidGUIControlGridActive:activate_item_by_value(params)
	for grid_item_index, grid_item in ipairs(self._grid_items) do
		local grid_item_data = grid_item:get_data()

		if grid_item_data[params.key] == params.value then
			self._active_item = grid_item

			self._active_item:activate()

			self._active_item_idx = grid_item_index
		else
			grid_item:deactivate()
		end
	end

	return self._active_item
end

function RaidGUIControlGridActive:get_active_item()
	return self._active_item
end

function RaidGUIControlGridActive:set_selected(value, dont_fire_select_callback)
	if value then
		local first_item_data = self._grid_items[1]:get_data()

		self:activate_item_by_value({
			key = "key_name",
			value = first_item_data.key_name
		})
		RaidGUIControlGridActive.super.set_selected(self, value, dont_fire_select_callback)
	end
end
