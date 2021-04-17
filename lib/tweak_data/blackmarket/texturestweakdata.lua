local is_nextgen_console = SystemInfo:platform() == Idstring("PS4") or SystemInfo:platform() == Idstring("XB1")

-- Lines 3-5
function BlackMarketTweakData:_init_textures()
	self.textures = {}
end
