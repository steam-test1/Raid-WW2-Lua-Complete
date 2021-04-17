HUDObjectivesTab = HUDObjectivesTab or class(HUDObjectives)

-- Lines 3-7
function HUDObjectivesTab:init(panel)
	HUDObjectivesTab.super.init(self, panel)

	self._show_objective_descriptions = true
end
