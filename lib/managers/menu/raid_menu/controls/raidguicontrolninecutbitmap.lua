RaidGUIControlNineCutBitmap = RaidGUIControlNineCutBitmap or class(RaidGUIControl)
RaidGUIControlNineCutBitmap.CORNER_SIZE = 32

-- Lines 6-18
function RaidGUIControlNineCutBitmap:init(parent, params)
	RaidGUIControlNineCutBitmap.super.init(self, parent, params)

	self._params.corner_size = self._params.corner_size or RaidGUIControlNineCutBitmap.CORNER_SIZE

	if not self._params.icon then
		Application:error("[RaidGUIControlNineCutBitmap:init] Icon not specified for the nine cut bitmap control: ", self._params.name)

		return
	end

	self:_create_panel()
	self:_layout_parts()
end

-- Lines 20-31
function RaidGUIControlNineCutBitmap:_create_panel()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_nine_cut_bitmap"
	panel_params.layer = self._panel:layer()
	panel_params.w = self._params.w or self._params.corner_size * 3
	panel_params.h = self._params.h or self._params.corner_size * 3
	self._slider_panel = self._panel:panel(panel_params)
	self._object = self._slider_panel
end

-- Lines 33-144
function RaidGUIControlNineCutBitmap:_layout_parts()
	local corner_size = self._params.corner_size
	local top_left_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_top_left")
	self._top_left = self._object:bitmap({
		name = self._name .. "_top_left",
		w = corner_size,
		h = corner_size,
		texture = top_left_icon.texture,
		texture_rect = top_left_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local top_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_top")
	self._top = self._object:bitmap({
		name = self._name .. "_top",
		x = corner_size,
		w = self._object:w() - corner_size * 2,
		h = corner_size,
		texture = top_icon.texture,
		texture_rect = top_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local top_right_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_top_right")
	self._top_right = self._object:bitmap({
		name = self._name .. "_top_right",
		x = self._object:w() - corner_size,
		w = corner_size,
		h = corner_size,
		texture = top_right_icon.texture,
		texture_rect = top_right_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local left_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_left")
	self._left = self._object:bitmap({
		name = self._name .. "_left",
		y = corner_size,
		w = corner_size,
		h = self._object:h() - corner_size * 2,
		texture = left_icon.texture,
		texture_rect = left_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local center_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_center")
	self._center = self._object:bitmap({
		name = self._name .. "_center",
		x = corner_size,
		y = corner_size,
		w = self._object:w() - corner_size * 2,
		h = self._object:h() - corner_size * 2,
		texture = center_icon.texture,
		texture_rect = center_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local right_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_right")
	self._right = self._object:bitmap({
		name = self._name .. "_right",
		x = self._object:w() - corner_size,
		y = corner_size,
		w = corner_size,
		h = self._object:h() - corner_size * 2,
		texture = right_icon.texture,
		texture_rect = right_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local bottom_left_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_bottom_left")
	self._bottom_left = self._object:bitmap({
		name = self._name .. "_bottom_left",
		y = self._object:h() - corner_size,
		w = corner_size,
		h = corner_size,
		texture = bottom_left_icon.texture,
		texture_rect = bottom_left_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local bottom_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_bottom")
	self._bottom = self._object:bitmap({
		name = self._name .. "_bottom",
		x = corner_size,
		y = self._object:h() - corner_size,
		w = self._object:w() - corner_size * 2,
		h = corner_size,
		texture = bottom_icon.texture,
		texture_rect = bottom_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
	local bottom_right_icon = tweak_data.gui:get_full_gui_data(self._params.icon .. "_bottom_right")
	self._bottom_right = self._object:bitmap({
		name = self._name .. "_bottom_right",
		x = self._object:w() - corner_size,
		y = self._object:h() - corner_size,
		w = corner_size,
		h = corner_size,
		texture = bottom_right_icon.texture,
		texture_rect = bottom_right_icon.texture_rect,
		alpha = self._params.alpha,
		color = self._params.color
	})
end

-- Lines 146-158
function RaidGUIControlNineCutBitmap:set_color(color)
	self._top_left:set_color(color)
	self._top:set_color(color)
	self._top_right:set_color(color)
	self._left:set_color(color)
	self._center:set_color(color)
	self._right:set_color(color)
	self._bottom_left:set_color(color)
	self._bottom:set_color(color)
	self._bottom_right:set_color(color)
end

-- Lines 160-162
function RaidGUIControlNineCutBitmap:color()
	return self._left:color()
end

-- Lines 164-167
function RaidGUIControlNineCutBitmap:set_size(w, h)
	self:set_w(w)
	self:set_h(h)
end

-- Lines 169-183
function RaidGUIControlNineCutBitmap:set_w(w)
	w = math.max(w, self._params.corner_size * 2)
	local inner_w = w - self._params.corner_size * 2

	self._object:set_w(w)
	self._top:set_w(inner_w)
	self._center:set_w(inner_w)
	self._bottom:set_w(inner_w)
	self._top_right:set_x(w - self._params.corner_size)
	self._right:set_x(w - self._params.corner_size)
	self._bottom_right:set_x(w - self._params.corner_size)
end

-- Lines 185-199
function RaidGUIControlNineCutBitmap:set_h(h)
	h = math.max(h, self._params.corner_size * 2)
	local inner_h = h - self._params.corner_size * 2

	self._object:set_h(h)
	self._left:set_h(inner_h)
	self._center:set_h(inner_h)
	self._right:set_h(inner_h)
	self._bottom_left:set_y(h - self._params.corner_size)
	self._bottom:set_y(h - self._params.corner_size)
	self._bottom_right:set_y(h - self._params.corner_size)
end

-- Lines 201-203
function RaidGUIControlNineCutBitmap:mouse_released(o, button, x, y)
	return false
end
