RaidGUIControlNavigationButton = RaidGUIControlNavigationButton or class(RaidGUIControl)
RaidGUIControlNavigationButton.ICON_SIZE = 32
RaidGUIControlNavigationButton.ICON_TEXT_PADDING = 10
RaidGUIControlNavigationButton.COLOR_NORMAL = tweak_data.gui.colors.raid_grey_effects
RaidGUIControlNavigationButton.COLOR_HOVER = tweak_data.gui.colors.raid_red
RaidGUIControlNavigationButton.COLOR_ACTIVE = tweak_data.gui.colors.raid_dark_red

-- Lines 10-73
function RaidGUIControlNavigationButton:init(parent, params)
	RaidGUIControlNavigationButton.super.init(self, parent, params)

	if not params then
		Application:error("Trying to create a navigation button without parameters!", debug.traceback())

		return
	end

	self._object = self._panel:panel({
		name = "navigation_button_panel_" .. self._name,
		x = params.x,
		y = params.y,
		h = params.h,
		layer = self._panel:layer() + 1
	})
	params.font = tweak_data.gui.fonts.din_compressed
	params.font_size = tweak_data.gui.font_sizes.large
	params.icon_align = params.icon_align
	params.vertical = "center"
	params.highlight_color = tweak_data.gui.colors.raid_black
	params.icon_texture = params.icon.texture
	params.icon_texture_rect = params.icon.texture_rect
	params.text = params.text
	self._on_click_callback = params.on_click_callback
	local icon_coord_x = 0
	local text_coord_x = 0

	if params.icon_align == "right" then
		icon_coord_x = (params.w or 100) - RaidGUIControlNavigationButton.ICON_SIZE
		text_coord_x = 0
	else
		icon_coord_x = 0
		text_coord_x = RaidGUIControlNavigationButton.ICON_SIZE + RaidGUIControlNavigationButton.ICON_TEXT_PADDING
	end

	self._icon = self._object:image({
		y = 0,
		name = "navigation_button_icon_" .. self._name,
		x = icon_coord_x,
		w = RaidGUIControlNavigationButton.ICON_SIZE,
		h = RaidGUIControlNavigationButton.ICON_SIZE,
		texture = params.icon_texture,
		texture_rect = params.icon_texture_rect,
		color = RaidGUIControlNavigationButton.COLOR_NORMAL,
		layer = self._object:layer() - 1
	})
	self._text = self._object:label({
		vertical = "center",
		align = "left",
		y = 0,
		name = "navigation_button_text_" .. self._name,
		x = text_coord_x,
		h = RaidGUIControlNavigationButton.ICON_SIZE,
		font = params.font,
		font_size = params.font_size,
		color = RaidGUIControlNavigationButton.COLOR_NORMAL,
		text = params.text,
		layer = self._object:layer() - 1
	})
	local x, y, w, h = self._text:text_rect()

	self._text:set_w(w)

	if params.icon_align == "left" then
		self._object:set_w(self._icon:w() + self._text:w() + RaidGUIControlNavigationButton.ICON_TEXT_PADDING)

		self._center_x, self._center_y = self._object:center()
		self._size_w, self._size_h = self._object:size()
		self._font_size = params.font_size
	else
		self._object:set_w(self._icon:w() + self._text:w() + RaidGUIControlNavigationButton.ICON_TEXT_PADDING)
		self._text:set_x(0)
		self._icon:set_x(self._text:right() + RaidGUIControlNavigationButton.ICON_TEXT_PADDING)
	end
end

-- Lines 75-79
function RaidGUIControlNavigationButton:highlight_on()
	self._icon:set_color(RaidGUIControlNavigationButton.COLOR_HOVER)
	self._text:set_color(RaidGUIControlNavigationButton.COLOR_HOVER)
end

-- Lines 81-85
function RaidGUIControlNavigationButton:highlight_off()
	self._icon:set_color(RaidGUIControlNavigationButton.COLOR_NORMAL)
	self._text:set_color(RaidGUIControlNavigationButton.COLOR_NORMAL)
end

-- Lines 87-96
function RaidGUIControlNavigationButton:on_mouse_released(button)
	self._icon:set_color(RaidGUIControlNavigationButton.COLOR_HOVER)
	self._text:set_color(RaidGUIControlNavigationButton.COLOR_HOVER)

	if self._on_click_callback then
		self._on_click_callback(button, self, self._data)
	end
end

-- Lines 98-103
function RaidGUIControlNavigationButton:on_mouse_pressed(button)
	self._icon:set_color(RaidGUIControlNavigationButton.COLOR_ACTIVE)
	self._text:set_color(RaidGUIControlNavigationButton.COLOR_ACTIVE)
end
