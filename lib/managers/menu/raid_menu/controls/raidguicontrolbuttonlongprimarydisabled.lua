RaidGUIControlButtonLongPrimaryDisabled = RaidGUIControlButtonLongPrimaryDisabled or class(RaidGUIControlButton)
RaidGUIControlButtonLongPrimaryDisabled.ICON = "btn_dissabled_256"
RaidGUIControlButtonLongPrimaryDisabled.HOVER_ICON = "btn_dissabled_256_hover"
RaidGUIControlButtonLongPrimaryDisabled.W = tweak_data.gui.icons[RaidGUIControlButtonLongPrimaryDisabled.ICON].texture_rect[3]
RaidGUIControlButtonLongPrimaryDisabled.H = tweak_data.gui.icons[RaidGUIControlButtonLongPrimaryDisabled.ICON].texture_rect[4]

-- Lines 8-36
function RaidGUIControlButtonLongPrimaryDisabled:init(parent, params)
	if not params then
		Application:error("Trying to create a long primary disabled button without parameters!", debug.traceback())

		return
	end

	params.font = params.font or tweak_data.gui.fonts.din_compressed
	params.font_size = params.font_size or tweak_data.gui.font_sizes.medium
	params.align = "center"
	params.vertical = "center"
	params.color = tweak_data.gui.colors.raid_red
	params.texture = tweak_data.gui.icons[RaidGUIControlButtonLongPrimaryDisabled.ICON].texture
	params.texture_rect = tweak_data.gui.icons[RaidGUIControlButtonLongPrimaryDisabled.ICON].texture_rect
	params.texture_color = Color.white
	params.no_highlight = true
	params.no_click = true
	params.w = RaidGUIControlButtonLongPrimary.W
	params.h = RaidGUIControlButtonLongPrimary.H

	RaidGUIControlButtonLongPrimaryDisabled.super.init(self, parent, params)
end

-- Lines 38-42
function RaidGUIControlButtonLongPrimaryDisabled:show()
	RaidGUIControlButtonLongPrimaryDisabled.super.show(self)

	self._params.no_click = true
	self._params.no_highlight = true
end

-- Lines 44-48
function RaidGUIControlButtonLongPrimaryDisabled:hide()
	RaidGUIControlButtonLongPrimaryDisabled.super.hide(self)

	self._params.no_click = true
	self._params.no_highlight = true
end
