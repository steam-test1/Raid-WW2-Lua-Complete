HUDObjectiveDescription = HUDObjectiveDescription or class(HUDObjectiveBase)
HUDObjectiveDescription.W = 512
HUDObjectiveDescription.DESCRIPTION_TEXT_FONT = tweak_data.gui.fonts.lato
HUDObjectiveDescription.DESCRIPTION_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_20

-- Lines 8-15
function HUDObjectiveDescription:init(objectives_panel, objective)
	self._objective = objective
	self._id = objective.id

	self:_create_text(objectives_panel)
	self:set_hidden()
end

-- Lines 17-32
function HUDObjectiveDescription:_create_text(objectives_panel)
	local panel_params = {
		vertical = "top",
		wrap = true,
		align = "right",
		halign = "scale",
		valign = "top",
		name = "objective_" .. tostring(self._id) .. "_description",
		w = HUDObjectiveDescription.W,
		font = tweak_data.gui:get_font_path(HUDObjectiveDescription.DESCRIPTION_TEXT_FONT, HUDObjectiveDescription.DESCRIPTION_TEXT_FONT_SIZE),
		font_size = HUDObjectiveDescription.DESCRIPTION_TEXT_FONT_SIZE,
		text = self._objective.description
	}
	self._object = objectives_panel:text(panel_params)
	local _, _, _, h = self._object:text_rect()

	self._object:set_h(h)
end

-- Lines 34-36
function HUDObjectiveDescription:set_objective_text(text)
	self._object:set_text(text)
end
