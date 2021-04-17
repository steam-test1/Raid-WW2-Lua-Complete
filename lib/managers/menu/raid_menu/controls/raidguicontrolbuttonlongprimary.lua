RaidGUIControlButtonLongPrimary = RaidGUIControlButtonLongPrimary or class(RaidGUIControlButton)
RaidGUIControlButtonLongPrimary.ICON = "btn_primary_256"
RaidGUIControlButtonLongPrimary.HOVER_ICON = "btn_primary_256_hover"
RaidGUIControlButtonLongPrimary.W = tweak_data.gui.icons[RaidGUIControlButtonLongPrimary.ICON].texture_rect[3]
RaidGUIControlButtonLongPrimary.H = tweak_data.gui.icons[RaidGUIControlButtonLongPrimary.ICON].texture_rect[4]

-- Lines 8-33
function RaidGUIControlButtonLongPrimary:init(parent, params)
	if not params then
		Application:error("Trying to create a long primary button without parameters!", debug.traceback())

		return
	end

	params.font = params.font or tweak_data.gui.fonts.din_compressed
	params.font_size = params.font_size or tweak_data.gui.font_sizes.medium
	params.align = "center"
	params.vertical = "center"
	params.color = tweak_data.gui.colors.raid_black
	params.highlight_color = tweak_data.gui.colors.raid_black
	params.texture = tweak_data.gui.icons[RaidGUIControlButtonLongPrimary.ICON].texture
	params.texture_rect = tweak_data.gui.icons[RaidGUIControlButtonLongPrimary.ICON].texture_rect
	params.texture_color = Color.white
	params.highlight_texture = tweak_data.gui.icons[RaidGUIControlButtonLongPrimary.HOVER_ICON].texture
	params.highlight_texture_rect = tweak_data.gui.icons[RaidGUIControlButtonLongPrimary.HOVER_ICON].texture_rect
	params.texture_highlight_color = Color.white
	params.w = RaidGUIControlButtonLongPrimary.W
	params.h = RaidGUIControlButtonLongPrimary.H

	RaidGUIControlButtonLongPrimary.super.init(self, parent, params)
end
