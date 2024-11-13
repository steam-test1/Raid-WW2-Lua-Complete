HUDMapPlayerPin = HUDMapPlayerPin or class()
HUDMapPlayerPin.W = 128
HUDMapPlayerPin.H = 128

function HUDMapPlayerPin:init(panel, params)
	self._id = params.id
	self._ai = params.ai or false
	self._hidden = false

	self:_create_panel(panel)
	self:_create_nationality_icon(params)
end

function HUDMapPlayerPin:_create_panel(panel)
	local panel_params = {
		h = nil,
		w = nil,
		visible = false,
		name = nil,
		halign = "center",
		valign = "center",
		name = "player_pin_" .. tostring(self._id),
		w = HUDMapPlayerPin.W,
		h = HUDMapPlayerPin.H
	}
	self._object = panel:panel(panel_params)
end

function HUDMapPlayerPin:_create_nationality_icon(params)
	local nationality = params.nationality or "german"
	local nationality_icon = "player_panel_nationality_" .. nationality
	local nationality_icon_params = {
		halign = "center",
		texture_rect = nil,
		name = "nationality_icon",
		texture = nil,
		valign = "center",
		texture = tweak_data.gui.icons[nationality_icon].texture,
		texture_rect = tweak_data.gui.icons[nationality_icon].texture_rect
	}
	self._nationality_icon = self._object:bitmap(nationality_icon_params)

	self._nationality_icon:set_center_x(self._object:w() / 2)
	self._nationality_icon:set_center_y(self._object:h() / 2)
end

function HUDMapPlayerPin:set_nationality(nationality)
	local nationality_icon = "player_panel_nationality_" .. nationality

	self._nationality_icon:set_image(tweak_data.gui.icons[nationality_icon].texture)
	self._nationality_icon:set_texture_rect(unpack(tweak_data.gui.icons[nationality_icon].texture_rect))
end

function HUDMapPlayerPin:set_center_x(x)
	self._object:set_center_x(x)
end

function HUDMapPlayerPin:set_center_y(y)
	self._object:set_center_y(y)
end

function HUDMapPlayerPin:set_position(x, y)
	self:set_center_x(x)
	self:set_center_y(y)
end

function HUDMapPlayerPin:ai()
	return self._ai
end

function HUDMapPlayerPin:id()
	return self._id
end

function HUDMapPlayerPin:show()
	self._shown = true

	if not self._hidden then
		self._object:set_visible(true)
	end
end

function HUDMapPlayerPin:hide()
	self._shown = false

	self._object:set_visible(false)
end

function HUDMapPlayerPin:set_hidden(value)
	self._hidden = value

	self._object:set_visible(not value)

	if not self._hidden and self._shown then
		self:show()
	elseif self._hidden and not self._shown then
		self:hide()
	end
end
