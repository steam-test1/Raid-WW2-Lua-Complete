WaypointUnitElement = WaypointUnitElement or class(MissionElement)
WaypointUnitElement.HED_COLOR = Color.white
WaypointUnitElement.USES_POINT_ORIENTATION = true

function WaypointUnitElement:init(unit)
	WaypointUnitElement.super.init(self, unit)
	self:_add_wp_options()

	self._icon_options = {
		"map_waypoint_pov_in",
		"map_waypoint_pov_out",
		"raid_wp_wait",
		"raid_prisoner"
	}

	self:_setup_waypoints_list()

	self._map_display_options = {
		"point",
		"icon",
		"circle"
	}
	self._hed.map_display = "point"
	self._hed.radius = 150
	self._hed.range_max = nil
	self._hed.range_min = nil
	self._hed.icon = "map_waypoint_pov_in"
	self._hed.text_id = "debug_none"

	table.insert(self._save_values, "icon")
	table.insert(self._save_values, "map_display")
	table.insert(self._save_values, "radius")
	table.insert(self._save_values, "range_max")
	table.insert(self._save_values, "range_min")
	table.insert(self._save_values, "text_id")
end

function WaypointUnitElement:_setup_waypoints_list()
	for key, value in pairs(tweak_data.gui.icons) do
		if string.match(key, "^waypoint_special_") then
			table.insert(self._icon_options, key)
		end
	end
end

function WaypointUnitElement:_add_wp_options()
	self._text_options = {
		"debug_none"
	}
end

function WaypointUnitElement:_set_text()
	self._text:set_value(managers.localization:text(self._hed.text_id))
end

function WaypointUnitElement:_set_shape_type()
	local display_type = self._hed.map_display

	self._icon_ctrlr:set_enabled(display_type ~= "circle")
	self._radius_params.number_ctrlr:set_enabled(display_type == "circle")
	self._sliders.radius:set_enabled(display_type == "circle")
end

function WaypointUnitElement:_set_ranges()
	if self._hed.range_max == 0 then
		self._hed.range_max = nil
	end

	if self._hed.range_min == 0 then
		self._hed.range_min = nil
	end
end

function WaypointUnitElement:set_element_data(params, ...)
	WaypointUnitElement.super.set_element_data(self, params, ...)

	if params.value == "text_id" then
		self:_set_text()
	elseif params.value == "map_display" then
		self:_set_shape_type()
	elseif params.value == "range_max" or params.value == "range_min" then
		self:_set_ranges()
	end
end

function WaypointUnitElement:update_selected(t, dt, selected_unit, all_units)
	local shape = self:get_shape()
	local color = WaypointUnitElement.HED_COLOR

	if shape then
		shape:draw(t, dt, color.r, color.g, color.b)
	end
end

function WaypointUnitElement:get_shape()
	self:_create_shapes()

	return self._hed.map_display == "circle" and self._circle_shape
end

function WaypointUnitElement:clone_data(...)
	WaypointUnitElement.super.clone_data(self, ...)
	self:_recreate_shapes()
end

function WaypointUnitElement:_create_shapes()
	self._circle_shape = CoreShapeManager.ShapeCylinderMiddle:new({
		height = 200,
		radius = self._hed.radius
	})

	self._circle_shape:set_unit(self._unit)
end

function WaypointUnitElement:_recreate_shapes()
	self._circle_shape = nil

	self:_create_shapes()
end

function WaypointUnitElement:set_shape_property(params)
	self._circle_shape:set_property(params.property, self._hed[params.value])
end

function WaypointUnitElement:_split_string(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	local i = 1

	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end

	return t
end

function WaypointUnitElement:scale_slider(panel, sizer, number_ctrlr_params, value, name)
	local slider_sizer = EWS:BoxSizer("HORIZONTAL")

	slider_sizer:add(EWS:StaticText(panel, name, "", "ALIGN_LEFT"), 1, 0, "ALIGN_CENTER_VERTICAL")

	local slider = EWS:Slider(panel, 100, 1, 200, "", "")

	slider_sizer:add(slider, 2, 0, "EXPAND")
	slider:connect("EVT_SCROLL_CHANGED", callback(self, self, "set_size"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	slider:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "set_size"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	slider:connect("EVT_SCROLL_CHANGED", callback(self, self, "size_release"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	slider:connect("EVT_SCROLL_THUMBRELEASE", callback(self, self, "size_release"), {
		ctrlr = slider,
		number_ctrlr_params = number_ctrlr_params,
		value = value
	})
	sizer:add(slider_sizer, 0, 0, "EXPAND")

	self._sliders = self._sliders or {}
	self._sliders[value] = slider
end

function WaypointUnitElement:set_size(params)
	local value = self._hed[params.value] * params.ctrlr:get_value() / 100

	if value < 10 then
		value = 10
	end

	self._circle_shape:set_property(params.value, value)
	CoreEWS.change_entered_number(params.number_ctrlr_params, value)
end

function WaypointUnitElement:size_release(params)
	self._hed[params.value] = params.number_ctrlr_params.value

	params.ctrlr:set_value(100)
end

function WaypointUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "map_display", self._map_display_options, "Select a map display type")

	self._icon_ctrlr = self:_build_value_combobox(panel, panel_sizer, "icon", self._icon_options, "Select an icon")

	self:_create_shapes()

	local radius, radius_params = self:_build_value_number(panel, panel_sizer, "radius", {
		floats = 0,
		min = 10
	}, "If map display type is \"circle,\" this specifies the radius of the element on the map (in pixels).")

	radius_params.name_ctrlr:set_label("Radius [cm]:")

	self._radius_params = radius_params

	radius:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		property = "radius",
		value = "radius"
	})
	radius:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		property = "radius",
		value = "radius"
	})
	self:scale_slider(panel, panel_sizer, radius_params, "radius", "Radius scale:")

	local range_max, range_max_params = self:_build_value_number(panel, panel_sizer, "range_max", {
		floats = 0,
		min = 0
	}, "The maximum range within the waypoint is visible (0 for always).")

	range_max_params.name_ctrlr:set_label("Max Range [cm]:")

	local range_min, range_min_params = self:_build_value_number(panel, panel_sizer, "range_min", {
		floats = 0,
		min = 0
	}, "The minimum range within the waypoint is visible (0 for always).")

	range_min_params.name_ctrlr:set_label("Min Range [cm]:")
	self:_build_value_combobox(panel, panel_sizer, "text_id", self._text_options, "Select a text id")

	local text_sizer = EWS:BoxSizer("HORIZONTAL")

	text_sizer:add(EWS:StaticText(panel, "Text: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	self._text = EWS:StaticText(panel, managers.localization:text(self._hed.text_id), "", "")

	text_sizer:add(self._text, 2, 2, "RIGHT,TOP,EXPAND")
	panel_sizer:add(text_sizer, 1, 0, "EXPAND")
	self:_set_shape_type()
end
