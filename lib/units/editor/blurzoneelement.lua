BlurZoneUnitElement = BlurZoneUnitElement or class(MissionElement)

function BlurZoneUnitElement:init(unit)
	BlurZoneUnitElement.super.init(self, unit)

	self._hed.mode = 0
	self._hed.radius = 200
	self._hed.height = 200

	table.insert(self._save_values, "mode")
	table.insert(self._save_values, "radius")
	table.insert(self._save_values, "height")
end

function BlurZoneUnitElement:update_selected(t, dt, selected_unit, all_units)
	local brush = Draw:brush()

	brush:set_color(Color(0.15, 1, 1, 1))

	local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

	brush:cylinder(self._unit:position(), self._unit:position() + math.Z * self._hed.height, self._hed.radius)
	pen:cylinder(self._unit:position(), self._unit:position() + math.Z * self._hed.height, self._hed.radius)
	brush:half_sphere(self._unit:position(), self._hed.radius, math.Z, 2)
	pen:half_sphere(self._unit:position(), self._hed.radius, math.Z)
	brush:half_sphere(self._unit:position() + math.Z * self._hed.height, self._hed.radius, -math.Z, 2)
	pen:half_sphere(self._unit:position() + math.Z * self._hed.height, self._hed.radius, -math.Z)
end

function BlurZoneUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local mode_params = {
		ctrlr_proportions = 2,
		name_proportions = 1,
		max = 3,
		min = 1,
		tooltip = "Set the mode, 1 is normal, 2 is colored, 3 is flash on enter",
		floats = 0,
		name = "Mode:",
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.mode
	}
	local mode = CoreEWS.number_controller(mode_params)

	mode:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "mode",
		ctrlr = mode
	})
	mode:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "mode",
		ctrlr = mode
	})

	local radius_params = {
		ctrlr_proportions = 2,
		name_proportions = 1,
		min = 1,
		tooltip = "Set the radius",
		floats = 0,
		name = "Radius:",
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.radius
	}
	local radius = CoreEWS.number_controller(radius_params)

	radius:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "radius",
		ctrlr = radius
	})
	radius:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "radius",
		ctrlr = radius
	})

	local height_params = {
		ctrlr_proportions = 2,
		name_proportions = 1,
		min = 0,
		tooltip = "Set the height",
		floats = 0,
		name = "Height:",
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.height
	}
	local height = CoreEWS.number_controller(height_params)

	height:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "height",
		ctrlr = height
	})
	height:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "height",
		ctrlr = height
	})
end
