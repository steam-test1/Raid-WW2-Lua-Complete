RaidGUIControlInfoIcon = RaidGUIControlInfoIcon or class(RaidGUIControl)
RaidGUIControlInfoIcon.DEFAULT_WIDTH = 100
RaidGUIControlInfoIcon.DEFAULT_HEIGHT = 50
RaidGUIControlInfoIcon.TEXT_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlInfoIcon.TEXT_SIZE = tweak_data.gui.font_sizes.extra_small
RaidGUIControlInfoIcon.TITLE_TEXT_SIZE = 46
RaidGUIControlInfoIcon.COLOR = tweak_data.gui.colors.raid_black
RaidGUIControlInfoIcon.TOP_PADDING_DOWN = 5
RaidGUIControlInfoIcon.TOP_W = 48
RaidGUIControlInfoIcon.TOP_H = 48

-- Lines 13-82
function RaidGUIControlInfoIcon:init(parent, params)
	RaidGUIControlInfoIcon.super.init(self, parent, params)

	if not params.icon and not params.title then
		Application:error("[RaidGUIControlInfoIcon:init] No icon or title set for info icon " .. tostring(self._name))

		return
	end

	if not params.text then
		Application:error("[RaidGUIControlInfoIcon:init] No text set for info icon " .. tostring(self._name))

		return
	end

	self:_init_panel()

	if params.icon then
		local icon_params = {
			y = 0,
			x = 0,
			layer = self._object:layer() + 1,
			texture = tweak_data.gui.icons[self._params.icon].texture,
			texture_rect = tweak_data.gui.icons[self._params.icon].texture_rect,
			h = params.icon_h or RaidGUIControlInfoIcon.TOP_H,
			color = params.icon_color or RaidGUIControlInfoIcon.COLOR
		}
		self._top = self._object:bitmap(icon_params)

		self._top:set_w(self._top:h() * tweak_data.gui:icon_w(self._params.icon) / tweak_data.gui:icon_h(self._params.icon))

		self._top_w = self._top:w()
		self._top_h = self._top:h()
	else
		local title_params = {
			vertical = "center",
			wrap = false,
			align = "center",
			y = 0,
			x = 0,
			layer = self._object:layer() + 1,
			font = RaidGUIControlInfoIcon.TEXT_FONT,
			font_size = params.title_size or RaidGUIControlInfoIcon.TITLE_TEXT_SIZE,
			h = params.title_h or RaidGUIControlInfoIcon.TOP_H,
			color = params.title_color or RaidGUIControlInfoIcon.COLOR,
			text = params.title
		}
		self._top = self._object:text(title_params)
		local _, _, w, h = self._top:text_rect()

		self._top:set_w(w)
		self._top:set_h(h)

		self._top_w = w
		self._top_h = h
	end

	local text_params = {
		vertical = "center",
		wrap = false,
		align = "center",
		y = 0,
		x = 0,
		h = params.text_h or 0,
		font = RaidGUIControlInfoIcon.TEXT_FONT,
		font_size = params.text_size or RaidGUIControlInfoIcon.TEXT_SIZE,
		text = params.text,
		color = params.text_color or RaidGUIControlInfoIcon.COLOR,
		layer = self._object:layer() + 1
	}
	self._text = self._object:text(text_params)
	local _, _, w, h = self._text:text_rect()

	self._text:set_w(w)

	if not params.text_h then
		self._text:set_h(h)
	end

	self:_fit_size()

	self._align = self._params.align or "left"
end

-- Lines 84-94
function RaidGUIControlInfoIcon:_init_panel()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_info_icon"
	panel_params.layer = self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or RaidGUIControlInfoIcon.DEFAULT_WIDTH
	panel_params.h = self._params.h or RaidGUIControlInfoIcon.DEFAULT_HEIGHT
	self._object = self._panel:panel(panel_params)
end

-- Lines 97-119
function RaidGUIControlInfoIcon:_fit_size()
	if not self._params.w then
		if self._text:w() <= self._top:w() then
			self._object:set_w(self._top:w())
		else
			self._object:set_w(self._text:w())
		end
	end

	if not self._params.h then
		self._object:set_h(self._top:h() + RaidGUIControlInfoIcon.TOP_PADDING_DOWN + self._text:h())
	end

	self._top:set_center_x(self._object:w() / 2)
	self._top:set_y(0)

	if self._params.top_offset_y then
		self._top:set_y(self._params.top_offset_y)
	end

	self._text:set_center_x(self._object:w() / 2)
	self._text:set_bottom(self._object:h())
end

-- Lines 121-145
function RaidGUIControlInfoIcon:set_icon(icon, params)
	if self._top then
		self._object:remove(self._top)
	end

	if not tweak_data.gui.icons[icon] then
		return
	end

	local icon_params = {
		y = 0,
		x = 0,
		layer = self._object:layer() + 1,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect,
		h = params and params.icon_h or RaidGUIControlInfoIcon.TOP_H,
		color = params and params.color or Color.white
	}
	self._top = self._object:bitmap(icon_params)

	self._top:set_w(self._top:h() * tweak_data.gui:icon_w(icon) / tweak_data.gui:icon_h(icon))

	self._top_w = self._top:w()
	self._top_h = self._top:h()

	self:_fit_size()
end

-- Lines 147-192
function RaidGUIControlInfoIcon:set_title(title, params)
	local h = nil

	if self._top then
		h = self._top:h()

		self._object:remove(self._top)
	end

	local x = 0

	if self._align == "left" then
		x = self._object:x()
	elseif self._align == "center" then
		x = self._object:center_x()
	elseif self._align == "right" then
		x = self._object:right()
	end

	local title_params = {
		vertical = "center",
		wrap = false,
		align = "center",
		y = 0,
		x = 0,
		layer = self._object:layer() + 1,
		font = params and params.font or RaidGUIControlInfoIcon.TEXT_FONT,
		font_size = params and params.font_size or RaidGUIControlInfoIcon.TITLE_TEXT_SIZE,
		h = h or RaidGUIControlInfoIcon.TOP_H,
		color = params and params.color or RaidGUIControlInfoIcon.COLOR,
		text = title
	}
	self._top = self._object:text(title_params)
	local _, _, w, h = self._top:text_rect()

	self._top:set_w(w)
	self._top:set_h(h)

	self._top_w = w
	self._top_h = h

	self:_fit_size()

	if self._align == "left" then
		self:set_x(x)
	elseif self._align == "center" then
		self:set_center_x(x)
	elseif self._align == "right" then
		self:set_right(x)
	end
end

-- Lines 194-235
function RaidGUIControlInfoIcon:set_text(text, params)
	if self._text then
		self._object:remove(self._text)
	end

	local x = 0

	if self._align == "left" then
		x = self._object:x()
	elseif self._align == "center" then
		x = self._object:center_x()
	elseif self._align == "right" then
		x = self._object:right()
	end

	local text_params = {
		vertical = "center",
		wrap = false,
		align = "center",
		y = 0,
		x = 0,
		font = RaidGUIControlInfoIcon.TEXT_FONT,
		font_size = params and params.text_size or RaidGUIControlInfoIcon.TEXT_SIZE,
		text = params and params.no_translate and text or self:translate(text, true),
		color = params and params.color or RaidGUIControlInfoIcon.COLOR,
		layer = self._object:layer() + 1
	}
	self._text = self._object:text(text_params)
	local _, _, w, h = self._text:text_rect()

	self._text:set_w(w)
	self._text:set_h(h)
	self:_fit_size()

	if self._align == "left" then
		self:set_x(x)
	elseif self._align == "center" then
		self:set_center_x(x)
	elseif self._align == "right" then
		self:set_right(x)
	end
end

-- Lines 237-240
function RaidGUIControlInfoIcon:set_x(x)
	self._object:set_x(x)

	self._align = "left"
end

-- Lines 242-245
function RaidGUIControlInfoIcon:set_center_x(x)
	self._object:set_center_x(x)

	self._align = "center"
end

-- Lines 247-249
function RaidGUIControlInfoIcon:set_center_y(y)
	self._object:set_center_y(y)
end

-- Lines 251-254
function RaidGUIControlInfoIcon:set_right(x)
	self._object:set_right(x)

	self._align = "right"
end

-- Lines 256-258
function RaidGUIControlInfoIcon:set_y(y)
	self._object:set_y(y)
end

-- Lines 260-262
function RaidGUIControlInfoIcon:set_bottom(bottom)
	self._object:set_bottom(bottom)
end

-- Lines 270-272
function RaidGUIControlInfoIcon:set_alpha(alpha)
	self._object:set_alpha(alpha)
end

-- Lines 274-276
function RaidGUIControlInfoIcon:show()
	self._object:set_visible(true)
end

-- Lines 278-280
function RaidGUIControlInfoIcon:hide()
	self._object:set_visible(false)
end
