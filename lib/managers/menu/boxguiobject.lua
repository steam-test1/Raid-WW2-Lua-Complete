BoxGuiObject = BoxGuiObject or class()
local mvector_tl = Vector3()
local mvector_tr = Vector3()
local mvector_bl = Vector3()
local mvector_br = Vector3()

-- Lines 8-10
function BoxGuiObject:init(panel, config)
	self:create_sides(panel, config)
end

-- Lines 12-36
function BoxGuiObject:create_sides(panel, config)
	if not alive(panel) then
		Application:error("[BoxGuiObject:create_sides] Failed creating BoxGui. Parent panel not alive!")
		Application:stack_dump()

		return
	end

	if alive(self._panel) then
		self._panel:parent():remove(self._panel)

		self._panel = nil
	end

	self._panel = panel:panel({
		valign = "grow",
		layer = 1,
		halign = "grow",
		name = config.name
	})
	self._color = config.color or self._color or Color.white
	local left_side = config.sides and config.sides[1] or config.left or 0
	local right_side = config.sides and config.sides[2] or config.right or 0
	local top_side = config.sides and config.sides[3] or config.top or 0
	local bottom_side = config.sides and config.sides[4] or config.bottom or 0

	self:_create_side(self._panel, "left", left_side)
	self:_create_side(self._panel, "right", right_side)
	self:_create_side(self._panel, "top", top_side)
	self:_create_side(self._panel, "bottom", bottom_side)
end

-- Lines 38-149
function BoxGuiObject:_create_side(panel, side, type)
	local ids_side = Idstring(side)
	local ids_left = Idstring("left")
	local ids_right = Idstring("right")
	local ids_top = Idstring("top")
	local ids_bottom = Idstring("bottom")
	local left_or_right = false
	local w, h = nil

	if ids_side == ids_left or ids_side == ids_right then
		left_or_right = true
		w = 2
		h = panel:h()
	else
		w = panel:w()
		h = 2
	end

	local side_panel = panel:panel({
		halign = "grow",
		valign = "grow",
		name = side,
		w = w,
		h = h
	})

	if type == 0 then
		return
	elseif type == 1 then
		-- Nothing
	elseif type ~= 2 then
		Application:error("[BoxGuiObject] Type", type, "is not supported")
		Application:stack_dump()

		return
	end

	side_panel:set_position(0, 0)

	if ids_side == ids_right then
		side_panel:set_right(panel:w())
	elseif ids_side == ids_bottom then
		side_panel:set_bottom(panel:h())
	end

	return side_panel
end

-- Lines 151-154
function BoxGuiObject:hide()
	self._panel:hide()
end

-- Lines 156-159
function BoxGuiObject:show()
	self._panel:show()
end

-- Lines 161-164
function BoxGuiObject:set_visible(visible)
	self._panel:set_visible(visible)
end

-- Lines 166-168
function BoxGuiObject:visible()
	return self._panel:visible()
end

-- Lines 170-172
function BoxGuiObject:set_layer(layer)
	self._panel:set_layer(layer)
end

-- Lines 174-176
function BoxGuiObject:size()
	return self._panel:size()
end

-- Lines 178-180
function BoxGuiObject:alive()
	return alive(self._panel)
end

-- Lines 182-192
function BoxGuiObject:inside(x, y, side)
	if not self:alive() then
		return false
	end

	if side then
		return self._panel:child(side) and self._panel:child(side):inside(x, y)
	else
		return self._panel:inside(x, y)
	end
end

-- Lines 194-199
function BoxGuiObject:set_aligns(halign, valign)
	for i, d in pairs(self._panel:children()) do
		d:set_valign(valign)
		d:set_halign(halign)
	end
end

-- Lines 201-209
function BoxGuiObject:set_clipping(clip, rec_panel)
	for i, d in pairs(rec_panel and rec_panel:children() or self._panel:children()) do
		if d.set_rotation then
			d:set_rotation(clip and 0 or 360)
		else
			self:set_clipping(clip, d)
		end
	end
end

-- Lines 211-213
function BoxGuiObject:color()
	return self._color
end

-- Lines 215-224
function BoxGuiObject:set_color(color, rec_panel)
	self._color = color

	for i, d in pairs(rec_panel and rec_panel:children() or self._panel:children()) do
		if d.set_color then
			d:set_color(color)
		else
			self:set_color(color, d)
		end
	end
end

-- Lines 226-228
function BoxGuiObject:blend_mode()
	return self._blend_mode
end

-- Lines 230-239
function BoxGuiObject:set_blend_mode(blend_mode, rec_panel)
	self._blend_mode = blend_mode

	for i, d in pairs(rec_panel and rec_panel:children() or self._panel:children()) do
		if d.set_blend_mode then
			d:set_blend_mode(blend_mode)
		else
			self:set_blend_mode(blend_mode, d)
		end
	end
end

-- Lines 241-245
function BoxGuiObject:close()
	if alive(self._panel) and alive(self._panel:parent()) then
		self._panel:parent():remove(self._panel)
	end
end
