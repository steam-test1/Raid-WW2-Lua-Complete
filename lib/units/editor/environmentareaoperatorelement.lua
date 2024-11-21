EnvironmentAreaOperatorElement = EnvironmentAreaOperatorElement or class(MissionElement)
EnvironmentAreaOperatorElement.ACTIONS = {
	"set"
}

function EnvironmentAreaOperatorElement:init(unit)
	EnvironmentAreaOperatorElement.super.init(self, unit)

	self._hed.operation = "set"
	self._hed.environment = ""
	self._hed.environment_area = ""
	self._hed.elements = {}

	table.insert(self._save_values, "environment")
	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "environment_area")

	self._actions = EnvironmentAreaOperatorElement.ACTIONS
end

function EnvironmentAreaOperatorElement:clear(...)
end

function EnvironmentAreaOperatorElement:add_to_mission_package()
	managers.editor:add_to_world_package({
		category = "script_data",
		name = self._hed.environment .. ".environment"
	})
	managers.editor:add_to_world_package({
		category = "scenes",
		name = self._hed.environment
	})
end

function EnvironmentAreaOperatorElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", self._actions, "Select an operation for the selected elements")
	self:_build_value_combobox(panel, panel_sizer, "environment", managers.database:list_entries_of_type("environment"), "Select an environment to use")

	local environment_area_names = {}

	for _, area in ipairs(managers.environment_area:areas()) do
		table.insert(environment_area_names, area:name())
	end

	self:_build_value_combobox(panel, panel_sizer, "environment_area", environment_area_names, "Select an environment area to use")
end
