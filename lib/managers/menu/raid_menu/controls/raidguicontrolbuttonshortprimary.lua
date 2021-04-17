RaidGUIControlButtonShortPrimary = RaidGUIControlButtonShortPrimary or class(RaidGUIControlButton)
RaidGUIControlButtonShortPrimary.ICON = "btn_primary_192"
RaidGUIControlButtonShortPrimary.HOVER_ICON = "btn_primary_192_hover"
RaidGUIControlButtonShortPrimary.DISABLED_ICON = "btn_dissabled_192"
RaidGUIControlButtonShortPrimary.DISABLED_HOVER_ICON = "btn_dissabled_192_hover"
RaidGUIControlButtonShortPrimary.W = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.ICON].texture_rect[3]
RaidGUIControlButtonShortPrimary.H = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.ICON].texture_rect[4]

-- Lines 11-41
function RaidGUIControlButtonShortPrimary:init(parent, params)
	if not params then
		Application:error("Trying to create a short primary button without parameters!", debug.traceback())

		return
	end

	params.font = params.font or tweak_data.gui.fonts.din_compressed
	params.font_size = params.font_size or tweak_data.gui.font_sizes.medium
	params.align = "center"
	params.vertical = "center"
	params.color = tweak_data.gui.colors.raid_black
	params.highlight_color = tweak_data.gui.colors.raid_black
	params.disable_color = tweak_data.gui.colors.raid_red
	params.texture = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.ICON].texture
	params.texture_rect = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.ICON].texture_rect
	params.texture_color = Color.white
	params.highlight_texture = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.HOVER_ICON].texture
	params.highlight_texture_rect = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.HOVER_ICON].texture_rect
	params.texture_highlight_color = Color.white
	params.disabled_texture = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.DISABLED_ICON].texture
	params.disabled_texture_rect = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.DISABLED_ICON].texture_rect
	params.highlight_disabled_texture = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.DISABLED_ICON].texture
	params.highlight_disabled_texture_rect = tweak_data.gui.icons[RaidGUIControlButtonShortPrimary.DISABLED_ICON].texture_rect
	params.w = RaidGUIControlButtonShortPrimary.W
	params.h = RaidGUIControlButtonShortPrimary.H

	RaidGUIControlButtonShortPrimary.super.init(self, parent, params)
end

-- Lines 43-56
function RaidGUIControlButtonShortPrimary:enable()
	if self._object_image then
		self._object_image:set_image(self._params.texture, unpack(self._params.texture_rect))
	end

	if self._object_text then
		self._object_text:set_color(self._params.color)
	end

	self:set_param_value("no_highlight", false)
	self:set_param_value("no_click", false)

	self._enabled = true
end

-- Lines 58-74
function RaidGUIControlButtonShortPrimary:disable()
	self:highlight_off()
	self:set_param_value("no_highlight", true)
	self:set_param_value("no_click", true)

	if self._object_image then
		self._object_image:set_image(self._params.disabled_texture, unpack(self._params.disabled_texture_rect))
	end

	if self._object_text then
		self._object_text:set_color(self._params.disable_color)
	end

	self._enabled = false
end
