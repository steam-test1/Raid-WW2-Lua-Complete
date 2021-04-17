SoundSwitchElement = SoundSwitchElement or class(MissionElement)

-- Lines 4-10
function SoundSwitchElement:init(unit)
	SoundSwitchElement.super.init(self, unit)

	self._hed.switch = "daytime_set_day"

	table.insert(self._save_values, "switch")
end

-- Lines 12-19
function SoundSwitchElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "Switch", ElementSoundSwitch.SWITCHES, "Select switch to apply")
end
