local is_nextgen_console = SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1")

-- Lines 3-6
function BlackMarketTweakData:_init_masks()
	self.masks = {}

	self:_add_desc_from_name_macro(self.masks)
end
