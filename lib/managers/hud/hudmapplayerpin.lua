HUDMapPlayerPin = HUDMapPlayerPin or class()
HUDMapPlayerPin.W = 128
HUDMapPlayerPin.H = 128

-- Lines 6-13
function HUDMapPlayerPin:init(panel, params)
	self._id = params.id
	self._ai = params.ai or false
	self._hidden = false

	self:_create_panel(panel)
	self:_create_nationality_icon(params)
end

-- Lines 15-24
function HUDMapPlayerPin:_create_panel(panel)
	local panel_params = {
		visible = false,
		halign = "center",
		valign = "center",
		name = "player_pin_" .. tostring(self._id),
		w = HUDMapPlayerPin.W,
		h = HUDMapPlayerPin.H
	}
	self._object = panel:panel(panel_params)
end

-- Lines 26-40
function HUDMapPlayerPin:_create_nationality_icon(params)
	local nationality = params.nationality or "german"
	local nationality_icon = "player_panel_nationality_" .. nationality
	local nationality_icon_params = {
		name = "nationality_icon",
		valign = "center",
		halign = "center",
		texture = tweak_data.gui.icons[nationality_icon].texture,
		texture_rect = tweak_data.gui.icons[nationality_icon].texture_rect
	}
	self._nationality_icon = self._object:bitmap(nationality_icon_params)

	self._nationality_icon:set_center_x(self._object:w() / 2)
	self._nationality_icon:set_center_y(self._object:h() / 2)
end

-- Lines 42-47
function HUDMapPlayerPin:set_nationality(nationality)
	local nationality_icon = "player_panel_nationality_" .. nationality

	self._nationality_icon:set_image(tweak_data.gui.icons[nationality_icon].texture)
	self._nationality_icon:set_texture_rect(unpack(tweak_data.gui.icons[nationality_icon].texture_rect))
end

-- Lines 49-51
function HUDMapPlayerPin:set_center_x(x)
	self._object:set_center_x(x)
end

-- Lines 53-55
function HUDMapPlayerPin:set_center_y(y)
	self._object:set_center_y(y)
end

-- Lines 57-60
function HUDMapPlayerPin:set_position(x, y)
	self:set_center_x(x)
	self:set_center_y(y)
end

-- Lines 62-64
function HUDMapPlayerPin:ai()
	return self._ai
end

-- Lines 66-68
function HUDMapPlayerPin:id()
	return self._id
end

-- Lines 70-76
function HUDMapPlayerPin:show()
	self._shown = true

	if not self._hidden then
		self._object:set_visible(true)
	end
end

-- Lines 78-82
function HUDMapPlayerPin:hide()
	self._shown = false

	self._object:set_visible(false)
end

-- Lines 85-94
function HUDMapPlayerPin:set_hidden(value)
	self._hidden = value

	self._object:set_visible(not value)

	if not self._hidden and self._shown then
		self:show()
	elseif self._hidden and not self._shown then
		self:hide()
	end
end
