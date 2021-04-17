RaidGUIControlButtonSmall = RaidGUIControlButtonSmall or class(RaidGUIControlButton)
RaidGUIControlButtonSmall.ICON = "btn_small_128"
RaidGUIControlButtonSmall.HOVER_ICON = "btn_small_128_hover"
RaidGUIControlButtonSmall.W = tweak_data.gui.icons[RaidGUIControlButtonSmall.ICON].texture_rect[3]
RaidGUIControlButtonSmall.H = tweak_data.gui.icons[RaidGUIControlButtonSmall.ICON].texture_rect[4]

-- Lines 8-33
function RaidGUIControlButtonSmall:init(parent, params)
	if not params then
		Application:error("Trying to create a long primary button without parameters!", debug.traceback())

		return
	end

	params.font = params.font or tweak_data.gui.fonts.din_compressed
	params.font_size = params.font_size or tweak_data.gui.font_sizes.medium
	params.align = "center"
	params.vertical = "center"
	params.color = tweak_data.gui.colors.raid_grey
	params.highlight_color = tweak_data.gui.colors.raid_grey
	params.texture = tweak_data.gui.icons[RaidGUIControlButtonSmall.ICON].texture
	params.texture_rect = tweak_data.gui.icons[RaidGUIControlButtonSmall.ICON].texture_rect
	params.texture_color = Color.white
	params.highlight_texture = tweak_data.gui.icons[RaidGUIControlButtonSmall.HOVER_ICON].texture
	params.highlight_texture_rect = tweak_data.gui.icons[RaidGUIControlButtonSmall.HOVER_ICON].texture_rect
	params.texture_highlight_color = Color.white
	params.w = RaidGUIControlButtonSmall.W
	params.h = RaidGUIControlButtonSmall.H

	RaidGUIControlButtonSmall.super.init(self, parent, params)
end
