core:import("CoreShapeManager")

NavigationStitcherUnitElement = NavigationStitcherUnitElement or class(MissionElement)

function NavigationStitcherUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._timeline_color = Vector3(1, 1, 0)
	self._brush = Draw:brush()
	self._hed.trigger_times = 1
	self._hed.spacing = 100
	self._hed.width = 500
	self._hed.depth = 500
	self._hed.height = 500
	self._hed.use_shape_element_ids = nil

	table.insert(self._save_values, "spacing")
	table.insert(self._save_values, "width")
	table.insert(self._save_values, "depth")
	table.insert(self._save_values, "height")
	table.insert(self._save_values, "spawn_unit_elements")
	table.insert(self._save_values, "use_shape_element_ids")
end

function NavigationStitcherUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)

	if self._hed.use_shape_element_ids then
		for _, id in ipairs(self._hed.use_shape_element_ids) do
			local unit = all_units[id]

			if self:_should_draw_link(selected_unit, unit) then
				local r, g, b = unit:mission_element():get_link_color()

				self:_draw_link({
					from_unit = unit,
					to_unit = self._unit,
					r = r,
					g = g,
					b = b
				})
			end
		end
	end
end

function NavigationStitcherUnitElement:update_editing()
end

function NavigationStitcherUnitElement:add_element()
end

function NavigationStitcherUnitElement:remove_links(unit)
end

function NavigationStitcherUnitElement:update_selected(t, dt, selected_unit, all_units)
	local shape = self:get_shape()

	if shape then
		shape:draw(t, dt, 0.2, 0.2, 0.8, 0.3)
	end
end

function NavigationStitcherUnitElement:get_shape()
	if not self._shape then
		self:_create_shapes()
	end

	return self._shape
end

function NavigationStitcherUnitElement:set_shape_property(params)
	self._shape:set_property(params.property, self._hed[params.value])
end

function NavigationStitcherUnitElement:add_triggers(vc)
end

function NavigationStitcherUnitElement:_set_shape_type()
	self._spacing_params.number_ctrlr:set_enabled(true)
	self._depth_params.number_ctrlr:set_enabled(true)
	self._width_params.number_ctrlr:set_enabled(true)
	self._height_params.number_ctrlr:set_enabled(true)
	self._sliders.depth:set_enabled(true)
	self._sliders.width:set_enabled(true)
	self._sliders.height:set_enabled(true)
end

function NavigationStitcherUnitElement:_create_shapes()
	self._shape = CoreShapeManager.ShapeBoxMiddle:new({
		width = self._hed.width,
		depth = self._hed.depth,
		height = self._hed.height
	})

	self._shape:set_unit(self._unit)
end

function NavigationStitcherUnitElement:_recreate_shapes()
	self._shape = nil

	self:_create_shapes()
end

function NavigationStitcherUnitElement:set_element_data(params, ...)
	NavigationStitcherUnitElement.super.set_element_data(self, params, ...)
end

function NavigationStitcherUnitElement:_build_panel(panel, panel_sizer, disable_params)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_create_shapes()

	local spacing, spacing_params = self:_build_value_number(panel, panel_sizer, "spacing", {
		floats = 0,
		min = 0
	}, "Set the spacing between navlinks")

	spacing_params.name_ctrlr:set_label("spacing[cm]:")

	self._spacing_params = spacing_params

	spacing:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "spacing",
		property = "spacing"
	})
	spacing:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "spacing",
		property = "spacing"
	})

	local width, width_params = self:_build_value_number(panel, panel_sizer, "width", {
		floats = 0,
		min = 0
	}, "Set the width for the shape")

	width_params.name_ctrlr:set_label("Width[cm]:")

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
		min = 0
	}, "Set the depth for the shape")

	depth_params.name_ctrlr:set_label("Depth[cm]:")

	self._depth_params = depth_params

	depth:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "depth",
		property = "depth"
	})
	depth:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "depth",
		property = "depth"
	})

	local height, height_params = self:_build_value_number(panel, panel_sizer, "height", {
		floats = 0,
		min = 0
	}, "Set the height for the shape")

	height_params.name_ctrlr:set_label("Height[cm]:")

	self._height_params = height_params

	height:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "height",
		property = "height"
	})
	height:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "height",
		property = "height"
	})
	self:scale_slider(panel, panel_sizer, width_params, "width", "Width scale:")
	self:scale_slider(panel, panel_sizer, depth_params, "depth", "Depth scale:")
	self:scale_slider(panel, panel_sizer, height_params, "height", "Height scale:")
	self:_set_shape_type()
end

function NavigationStitcherUnitElement:scale_slider(panel, sizer, number_ctrlr_params, value, name)
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

function NavigationStitcherUnitElement:set_size(params)
	local value = self._hed[params.value] * params.ctrlr:get_value() / 100

	self._shape:set_property(params.value, value)
	CoreEWS.change_entered_number(params.number_ctrlr_params, value)
end

function NavigationStitcherUnitElement:size_release(params)
	self._hed[params.value] = params.number_ctrlr_params.value

	params.ctrlr:set_value(100)
end

function NavigationStitcherUnitElement:clone_data(...)
	NavigationStitcherUnitElement.super.clone_data(self, ...)
	self:_recreate_shapes()
end
