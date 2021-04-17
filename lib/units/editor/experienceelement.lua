ExperienceUnitElement = ExperienceUnitElement or class(MissionElement)
ExperienceUnitElement.SAVE_UNIT_POSITION = false
ExperienceUnitElement.SAVE_UNIT_ROTATION = false

-- Lines 6-13
function ExperienceUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.elements = {}
	self._hed.event = nil

	table.insert(self._save_values, "event")
end

-- Lines 18-25
function ExperienceUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "event", managers.experience:get_script_xp_events(), "Specify special xp bonus awarded to player.")
end
