EnvironmentOperatorElement = EnvironmentOperatorElement or class(MissionElement)
EnvironmentOperatorElement.ACTIONS = {
	"set"
}

function EnvironmentOperatorElement:init(unit)
	EnvironmentOperatorElement.super.init(self, unit)

	self._hed.operation = "set"
	self._hed.environment = ""
	self._hed.elements = {}

	table.insert(self._save_values, "environment")
	table.insert(self._save_values, "operation")

	self._actions = EnvironmentOperatorElement.ACTIONS
end

function EnvironmentOperatorElement:clear(...)
end

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

function EnvironmentOperatorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", self._actions, "Select an operation for the selected elements")
	self:_build_value_combobox(panel, panel_sizer, "environment", managers.database:list_entries_of_type("environment"), "Select an environment to use")
end
