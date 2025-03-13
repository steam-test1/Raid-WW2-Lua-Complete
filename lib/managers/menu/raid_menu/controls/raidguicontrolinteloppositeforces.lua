RaidGUIControlIntelOppositeForces = RaidGUIControlIntelOppositeForces or class(RaidGUIControl)

function RaidGUIControlIntelOppositeForces:init(parent, params)
	RaidGUIControlIntelOppositeForces.super.init(self, parent, params)

	self._object = self._panel:panel(self._params)
	self._category_name = "opposition_forces"

	self:_layout()
end

function RaidGUIControlIntelOppositeForces:_layout()
	self._bg_image = self._object:bitmap({
		y = 0,
		x = 0,
		layer = self._object:layer() + 1,
		w = tweak_data.gui.icons.intel_table_opposition_card.texture_rect[3],
		h = tweak_data.gui.icons.intel_table_opposition_card.texture_rect[4],
		texture = tweak_data.gui.icons.intel_table_opposition_card.texture,
		texture_rect = tweak_data.gui.icons.intel_table_opposition_card.texture_rect
	})
	self._title = self._object:text({
		x = 96,
		h = 64,
		w = 384,
		y = 96,
		text = "",
		layer = self._object:layer() + 2,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		color = tweak_data.gui.colors.chat_border
	})
	local scrollable_area_description_params = {
		w = 416,
		y = 160,
		x = 96,
		name = "scrollable_area_description",
		scroll_step = 19,
		h = 448,
		scrollbar_width = 10,
		layer = self._object:layer() + 2
	}
	self._scrollable_area_description = self._object:scrollable_area(scrollable_area_description_params)
	local content_panel_params = {
		w = 384,
		y = 0,
		x = 0,
		layer = self._object:layer() + 2
	}
	self._content_panel = self._scrollable_area_description:get_panel():panel(content_panel_params)

	self._scrollable_area_description:setup_scroll_area()

	self._description = self._content_panel:text({
		x = 0,
		y = 0,
		w = 380,
		wrap = true,
		text = "",
		layer = self._object:layer() + 2,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.chat_border
	})
	local image_viewer_params = {
		w = 320,
		h = 480,
		y = 128,
		x = 576,
		visible = true
	}
	self._image_viewer = self._object:create_custom_control(RaidGUIControlImageViewer, image_viewer_params)
end

function RaidGUIControlIntelOppositeForces:set_data(item_value)
	self._data = tweak_data.intel:get_item_data(self._category_name, item_value)

	self._title:set_text(self:translate(self._data.name_id, true))
	self._description:set_text(self:translate(self._data.desc_id, false))

	local x1, y1, w1, h1 = self._description:text_rect()

	self._description:set_h(h1)
	self._content_panel:set_h(h1)
	self._scrollable_area_description:setup_scroll_area()
	self._image_viewer:set_data(self._data.images)
end

function RaidGUIControlIntelOppositeForces:get_data()
	return self._data
end
