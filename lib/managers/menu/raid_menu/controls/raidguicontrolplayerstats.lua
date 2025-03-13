RaidGUIControlPlayerStats = RaidGUIControlPlayerStats or class(RaidGUIControl)
RaidGUIControlPlayerStats.X = 0
RaidGUIControlPlayerStats.y = 0
RaidGUIControlPlayerStats.W = 1200
RaidGUIControlPlayerStats.H = 32
RaidGUIControlPlayerStats.FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlPlayerStats.BACKGROUND_IMAGE = "backgrounds_chat_bg"
RaidGUIControlPlayerStats.ITEMS_PADDING = 15

function RaidGUIControlPlayerStats:init(parent, params)
	RaidGUIControlPlayerStats.super.init(self, parent, params)

	if not params.data_source_callback then
		Application:error("[RaidGUIControlPlayerStats:init] Data source callback not specified for player stats panel: ", params.name)

		return
	end

	self._static = params.static
	self._data_source_callback = self._params.data_source_callback
	self._item_params = self._params.item_params or {}

	self:_create_panels()
	self:_create_background()
	self:_get_data()
	self:_create_items()
end

function RaidGUIControlPlayerStats:_create_panels()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = panel_params.layer or self._panel:layer() + 1
	panel_params.x = panel_params.x or RaidGUIControlPlayerStats.X
	panel_params.y = panel_params.y or RaidGUIControlPlayerStats.Y
	panel_params.w = panel_params.w or RaidGUIControlPlayerStats.W
	panel_params.h = panel_params.h or RaidGUIControlPlayerStats.H
	self._object = self._panel:panel(panel_params)
end

function RaidGUIControlPlayerStats:_create_background()
	local backgrounds_chat_bg = tweak_data.gui.icons[RaidGUIControlPlayerStats.BACKGROUND_IMAGE]
	self._player_stats_background = self._object:bitmap({
		name = "_player_stats_background",
		w = self._object:w(),
		h = self._object:h(),
		texture = backgrounds_chat_bg.texture,
		texture_rect = backgrounds_chat_bg.texture_rect
	})
end

function RaidGUIControlPlayerStats:_get_data()
	local stats_data = self._data_source_callback()

	if not stats_data or #stats_data == 0 then
		Application:error("[RaidGUIControlPlayerStats:_create_items] No items for player stats panel: ", self._params.name)

		return
	end

	self._stats_data = stats_data
end

function RaidGUIControlPlayerStats:_create_items()
	if not self._stats_data or #self._stats_data == 0 then
		return
	end

	local padding = self._params.items_padding or self.ITEMS_PADDING
	local i_horizontal = 0
	local item_left = padding / 2
	local item_width = (self._object:w() - padding) / #self._stats_data
	local item_height = self._object:h()
	self._stat_items = {}
	local item_params = clone(self._item_params)

	for i_item_data = 1, #self._stats_data do
		local item_data = self._stats_data[i_item_data]
		item_params.name = item_data.name
		item_params.x = item_left + item_width * i_horizontal
		item_params.w = item_width
		item_params.h = item_height
		item_params.font_size = item_params.font_size or RaidGUIControlPlayerStats.FONT_SIZE
		local item = self:_create_item(item_params, item_data)
		self._stat_items[item_data.name] = item
		i_horizontal = i_horizontal + 1
	end
end

function RaidGUIControlPlayerStats:_create_item(item_params, item_data)
	local item = self._object:create_custom_control(RaidGUIControlLabelNamedValueWithDelta, item_params)
	item.format_value = item_data.format_value or "%.0f"
	local label_text = self:translate(item_data.text_id or "LONGNAME", true)

	item:set_text(label_text)
	item:set_value(string.format(item.format_value, 0))

	return item
end

function RaidGUIControlPlayerStats:calculate_stats(character_class)
	local stats = managers.skilltree:calculate_stats(character_class)

	for name, item in pairs(self._stat_items) do
		if stats[name] then
			item:set_value(string.format(item.format_value, stats[name]))
		end
	end
end
