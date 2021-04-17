RaidGUIControlLabelTitle = RaidGUIControlLabelTitle or class(RaidGUIControlLabel)

-- Lines 3-13
function RaidGUIControlLabelTitle:init(parent, params)
	params.font = tweak_data.gui.fonts.din_compressed
	params.font_size = tweak_data.gui.font_sizes.size_56
	params.color = tweak_data.gui.colors.raid_red

	RaidGUIControlLabelTitle.super.init(self, parent, params)

	local _, _, w, h = self._object:text_rect()

	self._object:set_w(w)
	self._object:set_h(h)
end
