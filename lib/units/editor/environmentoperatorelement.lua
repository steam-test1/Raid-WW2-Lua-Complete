EnvironmentOperatorElement = EnvironmentOperatorElement or class(MissionElement)
EnvironmentOperatorElement.ACTIONS = {
	"set"
}

-- Lines 8-19
function EnvironmentOperatorElement:init(unit)
	EnvironmentOperatorElement.super.init(self, unit)

	self._hed.operation = "set"
	self._hed.environment = ""
	self._hed.elements = {}

	table.insert(self._save_values, "environment")
	table.insert(self._save_values, "operation")

	self._actions = EnvironmentOperatorElement.ACTIONS
end

-- Lines 21-23
function EnvironmentOperatorElement:clear(...)
end

-- Lines 25-28
function EnvironmentOperatorElement:add_to_mission_package()
	managers.editor:add_to_world_package({
		category = "script_data",
		name = self._hed.environment .. ".environment"
	})
	managers.editor:add_to_world_package({
		category = "scenes",
		name = self._hed.environment
	})
end

-- Lines 30-38
function EnvironmentOperatorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", self._actions, "Select an operation for the selected elements")
	self:_build_value_combobox(panel, panel_sizer, "environment", managers.database:list_entries_of_type("environment"), "Select an environment to use")
end
