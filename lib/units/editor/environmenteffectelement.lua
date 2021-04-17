EnvironmentEffectElement = EnvironmentEffectElement or class(MissionElement)
EnvironmentEffectElement.ACTIONS = {
	"set",
	"remove"
}

-- Lines 8-21
function EnvironmentEffectElement:init(unit)
	EnvironmentEffectElement.super.init(self, unit)

	self._hed.action = "set"
	self._hed.effect = ""
	self._hed.local_only = false
	self._hed.elements = {}

	table.insert(self._save_values, "effect")
	table.insert(self._save_values, "action")
	table.insert(self._save_values, "local_only")

	self._actions = EnvironmentEffectElement.ACTIONS
end

-- Lines 23-24
function EnvironmentEffectElement:clear(...)
end

-- Lines 26-27
function EnvironmentEffectElement:add_to_mission_package()
end

-- Lines 29-38
function EnvironmentEffectElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "action", self._actions, "Select an action for the selected elements")
	self:_build_value_combobox(panel, panel_sizer, "effect", managers.environment_effects:effects_names(), "Select an effect to use")
	self:_build_value_checkbox(panel, panel_sizer, "local_only", "Local Only")
end
