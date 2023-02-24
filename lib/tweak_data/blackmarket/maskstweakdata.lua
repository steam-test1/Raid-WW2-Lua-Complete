local is_nextgen_console = _G.IS_PS4 or _G.IS_XB1

function BlackMarketTweakData:_init_masks()
	self.masks = {}

	self:_add_desc_from_name_macro(self.masks)
end
