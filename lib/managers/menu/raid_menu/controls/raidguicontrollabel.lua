RaidGUIControlLabel = RaidGUIControlLabel or class(RaidGUIControl)

-- Lines 3-48
function RaidGUIControlLabel:init(parent, params)
	RaidGUIControlLabel.super.init(self, parent, params)

	if not self._params.text_id and not self._params.text then
		Application:error("[RaidGUIControlLabel:init] Text not specified for the label control: ", params.name)

		return
	end

	local default_font_size = tweak_data.gui.font_sizes.size_24
	local default_font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, default_font_size)
	self._params.font = self._params.font or default_font
	self._params.font_size = self._params.font_size or default_font_size
	self._params.text = self._params.text or managers.localization:text(self._params.text_id)
	self._params.text_id = nil
	self._params.background_color = params.item_background_color
	self._params.vertical = params.vertical

	if self._params.background_color then
		local background_params = clone(self._params)
		background_params.color = self._params.background_color
		self._background = self._panel:rect(background_params)
	end

	self._params.layer = self._params.layer + 2

	if self._params.text_padding then
		self._params.x = self._params.x + self._params.text_padding
	end

	self._object = self._panel:text(self._params)

	if self._params.fit_text then
		local x, y, w, h = self._object:text_rect()

		self._object:set_size(w, h)
	end

	if self._params.text_padding then
		self._params.x = self._params.x - self._params.text_padding

		self._object:set_w(self._object:w() - self._params.text_padding * 2)
	end

	self._params.layer = self._params.layer - 1
end

-- Lines 50-52
function RaidGUIControlLabel:is_alive()
	return self._object and alive(self._object)
end

-- Lines 54-62
function RaidGUIControlLabel:set_text(text)
	self._object:set_text(text)

	if self._params.fit_text then
		local x, y, w, h = self._object:text_rect()

		self._object:set_size(w, h)
	end
end

-- Lines 64-66
function RaidGUIControlLabel:text()
	return self._object:text()
end

-- Lines 68-70
function RaidGUIControlLabel:set_align(align)
	self._object:set_align(align)
end

-- Lines 72-74
function RaidGUIControlLabel:color()
	self._object:color()
end

-- Lines 76-78
function RaidGUIControlLabel:set_color(color)
	self._object:set_color(color)
end

-- Lines 80-82
function RaidGUIControlLabel:set_alpha(alpha)
	self._object:set_alpha(alpha)
end

-- Lines 84-86
function RaidGUIControlLabel:set_font(font)
	self._object:set_font(font)
end

-- Lines 88-90
function RaidGUIControlLabel:set_font_size(size)
	self._object:set_font_size(size)
end

-- Lines 92-93
function RaidGUIControlLabel:highlight_on()
end

-- Lines 95-96
function RaidGUIControlLabel:highlight_off()
end

-- Lines 98-100
function RaidGUIControlLabel:center_x(coord)
	return self._object:center_x(coord)
end

-- Lines 102-104
function RaidGUIControlLabel:center_y(coord)
	return self._object:center_y(coord)
end

-- Lines 106-108
function RaidGUIControlLabel:set_center_x(coord)
	self._object:set_center_x(coord)
end

-- Lines 110-112
function RaidGUIControlLabel:set_center_y(coord)
	self._object:set_center_y(coord)
end

-- Lines 114-116
function RaidGUIControlLabel:text_rect()
	return self._object:text_rect()
end

-- Lines 118-120
function RaidGUIControlLabel:set_width(width)
	self._object:set_width(width)
end

-- Lines 122-124
function RaidGUIControlLabel:set_height(height)
	self._object:set_height(height)
end

-- Lines 126-129
function RaidGUIControlLabel:mouse_released(o, button, x, y)
	return false
end
