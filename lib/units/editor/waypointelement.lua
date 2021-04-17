WaypointUnitElement = WaypointUnitElement or class(MissionElement)

function WaypointUnitElement:init(unit)
	WaypointUnitElement.super.init(self, unit)
	self:_add_wp_options()

	self._icon_options = {
		"map_waypoint_pov_in",
		"map_waypoint_pov_out",
		"waypoint_special_aim",
		"waypoint_special_air_strike",
		"waypoint_special_ammo",
		"waypoint_special_boat",
		"waypoint_special_code_book",
		"waypoint_special_code_device",
		"waypoint_special_crowbar",
		"waypoint_special_cvy_foxhole",
		"waypoint_special_cvy_landimine",
		"waypoint_special_defend",
		"waypoint_special_dog_tags",
		"waypoint_special_door",
		"waypoint_special_downed",
		"waypoint_special_dynamite_stick",
		"waypoint_special_escape",
		"waypoint_special_explosive",
		"waypoint_special_fire",
		"waypoint_special_fix",
		"waypoint_special_general_vip_sit",
		"waypoint_special_gereneral_vip_move",
		"waypoint_special_gold",
		"waypoint_special_health",
		"waypoint_special_key",
		"waypoint_special_kill",
		"waypoint_special_lockpick",
		"waypoint_special_loot",
		"waypoint_special_loot_drop",
		"waypoint_special_parachute",
		"waypoint_special_phone",
		"waypoint_special_portable_radio",
		"waypoint_special_power",
		"waypoint_special_prisoner",
		"waypoint_special_recording_device",
		"waypoint_special_refuel",
		"waypoint_special_refuel_empty",
		"waypoint_special_stash_box",
		"waypoint_special_thermite",
		"waypoint_special_tools",
		"waypoint_special_valve",
		"waypoint_special_vehicle_kugelwagen",
		"waypoint_special_vehicle_truck",
		"waypoint_special_wait",
		"waypoint_special_where",
		"raid_wp_wait",
		"raid_prisoner",
		"pd2_lootdrop",
		"pd2_escape",
		"pd2_talk",
		"pd2_kill",
		"pd2_drill",
		"pd2_generic_look",
		"pd2_phone",
		"pd2_c4",
		"pd2_power",
		"pd2_door",
		"pd2_computer",
		"pd2_wirecutter",
		"pd2_fire",
		"pd2_loot",
		"pd2_methlab",
		"pd2_generic_interact",
		"pd2_goto",
		"pd2_ladder",
		"pd2_fix",
		"pd2_question",
		"pd2_defend",
		"pd2_generic_saw",
		"pd2_chainsaw"
	}
	self._map_display_options = {
		"point",
		"square",
		"circle"
	}
	self._hed.map_display = "point"
	self._hed.color = {
		g = 0.8,
		b = 0.33,
		r = 0.38
	}
	self._hed.width = 100
	self._hed.depth = 100
	self._hed.radius = 150
	self._hed.icon = "pd2_goto"
	self._hed.text_id = "debug_none"
	self._hed.only_in_civilian = false

	table.insert(self._save_values, "icon")
	table.insert(self._save_values, "map_display")
	table.insert(self._save_values, "color")
	table.insert(self._save_values, "width")
	table.insert(self._save_values, "depth")
	table.insert(self._save_values, "radius")
	table.insert(self._save_values, "text_id")
	table.insert(self._save_values, "only_in_civilian")
end

function WaypointUnitElement:_add_wp_options()
	self._text_options = {
		"debug_none"
	}
end

function WaypointUnitElement:_set_text()
	self._text:set_value(managers.localization:text(self._hed.text_id))
end

function WaypointUnitElement:set_element_data(params, ...)
	WaypointUnitElement.super.set_element_data(self, params, ...)

	if params.value == "text_id" then
		self:_set_text()
	end
end

function WaypointUnitElement:update_selected(t, dt, selected_unit, all_units)
	local shape = self:get_shape()
	local color = self._hed.color

	if shape then
		shape:draw(t, dt, color.r, color.g, color.b)
	end
end

function WaypointUnitElement:get_shape()
	if not self._square_shape then
		self:_create_shapes()
	end

	return self._hed.map_display == "square" and self._square_shape or self._hed.map_display == "circle" and self._circle_shape
end

function WaypointUnitElement:clone_data(...)
	WaypointUnitElement.super.clone_data(self, ...)
	self:_recreate_shapes()
end

function WaypointUnitElement:_create_shapes()
	self._square_shape = CoreShapeManager.ShapeBoxMiddle:new({
		height = 200,
		width = self._hed.width,
		depth = self._hed.depth
	})

	self._square_shape:set_unit(self._unit)

	self._circle_shape = CoreShapeManager.ShapeCylinderMiddle:new({
		height = 200,
		radius = self._hed.radius
	})

	self._circle_shape:set_unit(self._unit)
end

function WaypointUnitElement:_recreate_shapes()
	self._square_shape = nil
	self._circle_shape = nil

	self:_create_shapes()
end

function WaypointUnitElement:_set_shape_type()
	local display_type = self._hed.map_display

	self._color.control:set_enabled(display_type == "circle" or display_type == "square")

	if display_type == "point" then
		self._icon_ctrlr:set_enabled(true)
		self._color.control:set_background_colour(Color(self._hed.color.r * 255, self._hed.color.g * 255, self._hed.color.b * 255))
	else
		self._icon_ctrlr:set_enabled(false)
		self._color.control:set_background_colour(self._hed.color.r * 255, self._hed.color.g * 255, self._hed.color.b * 255)
	end

	self._width_params.number_ctrlr:set_enabled(display_type == "square")
	self._depth_params.number_ctrlr:set_enabled(display_type == "square")
	self._radius_params.number_ctrlr:set_enabled(display_type == "circle")
	self._sliders.depth:set_enabled(display_type == "square")
	self._sliders.width:set_enabled(display_type == "square")
	self._sliders.radius:set_enabled(display_type == "circle")
end

function WaypointUnitElement:set_shape_property(params)
	self._square_shape:set_property(params.property, self._hed[params.value])
	self._circle_shape:set_property(params.property, self._hed[params.value])
end

function WaypointUnitElement:set_element_data(params, ...)
	WaypointUnitElement.super.set_element_data(self, params, ...)

	if params.value == "map_display" then
		self:_set_shape_type()
	elseif params.value == "color" then
		local colors = self:_split_string(tostring(self._hed.color), " ")

		for i = 1, 3 do
			colors[i] = colors[i] / 255
		end

		self._hed.color = {
			r = colors[1],
			g = colors[2],
			b = colors[3]
		}
	end
end

function WaypointUnitElement:_on_color_changed()
	local color = self.__color_picker_dialog:color()
	self._hed.color = {
		r = color.r,
		g = color.g,
		b = color.b
	}

	self._color.control:set_background_colour(color.r * 255, color.g * 255, color.b * 255)
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

	self._square_shape:set_property(params.value, value)
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

	self:_build_value_checkbox(panel, panel_sizer, "only_in_civilian", "This waypoint will only be visible for players that are in civilian mode")
	self:_build_value_combobox(panel, panel_sizer, "map_display", self._map_display_options, "Select a map display type")

	self._icon_ctrlr = self:_build_value_combobox(panel, panel_sizer, "icon", self._icon_options, "Select an icon")
	self._color = {}
	self._color.label, self._color.control = self:_build_value_color(panel, panel_sizer, "color", "Select the color of the waypoint on the map")

	if not self._square_shape then
		self:_create_shapes()
	end

	local width, width_params = self:_build_value_number(panel, panel_sizer, "width", {
		floats = 0,
		min = 10
	}, "If map display type is \"square,\" this specifies the width of the element on the map (in pixels).")

	width_params.name_ctrlr:set_label("Width [cm]:")

	self._width_params = width_params

	width:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "width",
		property = "width"
	})
	width:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "width",
		property = "width"
	})

	local depth, depth_params = self:_build_value_number(panel, panel_sizer, "depth", {
		floats = 0,
		min = 10
	}, "If map display type is \"square,\" this specifies the depth of the element on the map (in pixels).")

	depth_params.name_ctrlr:set_label("Depth [cm]:")

	self._depth_params = depth_params

	depth:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "depth",
		property = "depth"
	})
	depth:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "depth",
		property = "depth"
	})

	local radius, radius_params = self:_build_value_number(panel, panel_sizer, "radius", {
		floats = 0,
		min = 10
	}, "If map display type is \"circle,\" this specifies the radius of the element on the map (in pixels).")

	radius_params.name_ctrlr:set_label("Radius [cm]:")

	self._radius_params = radius_params

	radius:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "radius",
		property = "radius"
	})
	radius:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "radius",
		property = "radius"
	})
	self:scale_slider(panel, panel_sizer, width_params, "width", "Width scale:")
	self:scale_slider(panel, panel_sizer, depth_params, "depth", "Depth scale:")
	self:scale_slider(panel, panel_sizer, radius_params, "radius", "Radius scale:")
	self:_build_value_combobox(panel, panel_sizer, "text_id", self._text_options, "Select a text id")

	local text_sizer = EWS:BoxSizer("HORIZONTAL")

	text_sizer:add(EWS:StaticText(panel, "Text: ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

	self._text = EWS:StaticText(panel, managers.localization:text(self._hed.text_id), "", "")

	text_sizer:add(self._text, 2, 2, "RIGHT,TOP,EXPAND")
	panel_sizer:add(text_sizer, 1, 0, "EXPAND")
	self:_set_shape_type()
end
