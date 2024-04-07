RaidGUIControlLabel = RaidGUIControlLabel or class(RaidGUIControl)

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

	if self._params.text_padding then
		self._params.x = self._params.x - self._params.text_padding

		self._object:set_w(self._object:w() - self._params.text_padding * 2)
	end

	self._params.layer = self._params.layer - 1
end

function RaidGUIControlLabel:is_alive()
	return self._object and alive(self._object)
end

function RaidGUIControlLabel:set_text(text)
	self._object:set_text(text)
end

function RaidGUIControlLabel:text()
	return self._object:text()
end

function RaidGUIControlLabel:set_align(align)
	self._object:set_align(align)
end

function RaidGUIControlLabel:color()
	self._object:color()
end

function RaidGUIControlLabel:set_color(color)
	self._object:set_color(color)
end

function RaidGUIControlLabel:set_alpha(alpha)
	self._object:set_alpha(alpha)
end

function RaidGUIControlLabel:set_font(font)
	self._object:set_font(font)
end

function RaidGUIControlLabel:set_font_size(size)
	self._object:set_font_size(size)
end

function RaidGUIControlLabel:highlight_on()
	return
end

function RaidGUIControlLabel:highlight_off()
	return
end

function RaidGUIControlLabel:center_x(coord)
	return self._object:center_x(coord)
end

function RaidGUIControlLabel:center_y(coord)
	return self._object:center_y(coord)
end

function RaidGUIControlLabel:set_center_x(coord)
	self._object:set_center_x(coord)
end

function RaidGUIControlLabel:set_center_y(coord)
	self._object:set_center_y(coord)
end

function RaidGUIControlLabel:text_rect()
	return self._object:text_rect()
end

function RaidGUIControlLabel:set_width(width)
	self._object:set_width(width)
end

function RaidGUIControlLabel:set_height(height)
	self._object:set_height(height)
end

function RaidGUIControlLabel:mouse_released(o, button, x, y)
	return false
end
