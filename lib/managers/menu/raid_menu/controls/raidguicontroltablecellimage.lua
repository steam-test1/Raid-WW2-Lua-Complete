RaidGUIControlTableCellImage = RaidGUIControlTableCellImage or class(RaidGUIControlImage)

-- Lines 3-14
function RaidGUIControlTableCellImage:init(parent, params)
	local local_params = clone(params)

	if local_params.value and local_params.value.texture and not local_params.texture then
		local_params.texture = local_params.value.texture
	end

	if local_params.value and local_params.value.texture_rect and not local_params.texture_rect then
		local_params.texture_rect = local_params.value.texture_rect
	end

	RaidGUIControlTableCellImage.super.init(self, parent, local_params)
end
