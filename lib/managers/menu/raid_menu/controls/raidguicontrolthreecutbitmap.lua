RaidGUIControlThreeCutBitmap = RaidGUIControlThreeCutBitmap or class(RaidGUIControl)
RaidGUIControlThreeCutBitmap.CENTER_OVERFLOW = 1

-- Lines 5-15
function RaidGUIControlThreeCutBitmap:init(parent, params)
	RaidGUIControlThreeCutBitmap.super.init(self, parent, params)

	if not self._params.left or not self._params.center or not self._params.right then
		Application:error("[RaidGUIControlThreeCutBitmap:init] One or more textures not specified for the three cut bitmap control: ", self._params.name)

		return
	end

	self:_create_panel()
	self:_layout_parts()
end

-- Lines 17-25
function RaidGUIControlThreeCutBitmap:_create_panel()
	local three_cut_params = clone(self._params)
	three_cut_params.name = three_cut_params.name .. "_three_cut_bitmap"
	three_cut_params.layer = self._panel:layer()
	three_cut_params.h = self._params.h or self:h()
	self._slider_panel = self._panel:panel(three_cut_params)
	self._object = self._slider_panel
end

-- Lines 27-106
function RaidGUIControlThreeCutBitmap:_layout_parts()
	self._h = self:h()
	local left_texture_rect = {
		tweak_data.gui.icons[self._params.left].texture_rect[1],
		tweak_data.gui.icons[self._params.left].texture_rect[2],
		tweak_data.gui.icons[self._params.left].texture_rect[3] - 1,
		tweak_data.gui.icons[self._params.left].texture_rect[4]
	}
	local left_params = {
		x = 0,
		name = self._name .. "_left",
		y = self._h / 2 - tweak_data.gui.icons[self._params.left].texture_rect[4] / 2,
		w = tweak_data.gui.icons[self._params.left].texture_rect[3] - 1,
		h = self._object:h(),
		texture = tweak_data.gui.icons[self._params.left].texture,
		texture_rect = left_texture_rect,
		color = self._params.color or Color.white,
		layer = self._object:layer() + 2
	}
	self._left = self._object:bitmap(left_params)
	local right_texture_rect = {
		tweak_data.gui.icons[self._params.right].texture_rect[1] + 1,
		tweak_data.gui.icons[self._params.right].texture_rect[2],
		tweak_data.gui.icons[self._params.right].texture_rect[3] - 1,
		tweak_data.gui.icons[self._params.right].texture_rect[4]
	}
	local right_params = {
		name = self._name .. "_right",
		x = self._object:w() - tweak_data.gui.icons[self._params.right].texture_rect[3],
		y = self._h / 2 - tweak_data.gui.icons[self._params.right].texture_rect[4] / 2,
		w = tweak_data.gui.icons[self._params.right].texture_rect[3] - 1,
		h = self._object:h(),
		texture = tweak_data.gui.icons[self._params.right].texture,
		texture_rect = right_texture_rect,
		color = self._params.color or Color.white,
		layer = self._object:layer() + 2
	}
	self._right = self._object:bitmap(right_params)

	self._right:set_right(self._object:right())

	local center_texture_rect = {
		tweak_data.gui.icons[self._params.center].texture_rect[1] + 2,
		tweak_data.gui.icons[self._params.center].texture_rect[2],
		tweak_data.gui.icons[self._params.center].texture_rect[3] - 4,
		tweak_data.gui.icons[self._params.center].texture_rect[4]
	}
	local center_params = {
		name = self._name .. "_center",
		x = self._left:w(),
		y = self._h / 2 - tweak_data.gui.icons[self._params.center].texture_rect[4] / 2,
		w = self._object:w() - self._left:w() - self._right:w(),
		h = self._object:h(),
		texture = tweak_data.gui.icons[self._params.center].texture,
		texture_rect = center_texture_rect,
		color = self._params.color or Color.white
	}
	self._center = self._object:bitmap(center_params)
end

-- Lines 108-112
function RaidGUIControlThreeCutBitmap:set_color(color)
	self._left:set_color(color)
	self._center:set_color(color)
	self._right:set_color(color)
end

-- Lines 114-116
function RaidGUIControlThreeCutBitmap:color()
	return self._left:color()
end

-- Lines 126-144
function RaidGUIControlThreeCutBitmap:set_w(w)
	self._object:set_w(w)
	self._left:set_x(0)

	local center_w = math.ceil(w - self._left:w() - self._right:w() + 2 * RaidGUIControlThreeCutBitmap.CENTER_OVERFLOW)

	if center_w < 0 then
		center_w = 0
	end

	self._center:set_w(center_w)

	local center_x = self._left:w() - RaidGUIControlThreeCutBitmap.CENTER_OVERFLOW

	if center_x < 0 then
		center_x = 0
	end

	self._center:set_x(center_x)
	self._right:set_x(self._center:x() + self._center:w() - RaidGUIControlThreeCutBitmap.CENTER_OVERFLOW)
end

-- Lines 146-148
function RaidGUIControlThreeCutBitmap:mouse_released(o, button, x, y)
	return false
end

-- Lines 150-162
function RaidGUIControlThreeCutBitmap:h()
	local height = tweak_data.gui.icons[self._params.left].texture_rect[4]

	if height < tweak_data.gui.icons[self._params.center].texture_rect[4] then
		height = tweak_data.gui.icons[self._params.center].texture_rect[4]
	end

	if height < tweak_data.gui.icons[self._params.right].texture_rect[4] then
		height = tweak_data.gui.icons[self._params.right].texture_rect[4]
	end

	return height
end
