core:import("CoreShapeManager")

CoreShapeUnitElement = CoreShapeUnitElement or class(MissionElement)
ShapeUnitElement = ShapeUnitElement or class(CoreShapeUnitElement)

-- Lines 7-9
function ShapeUnitElement:init(...)
	CoreShapeUnitElement.init(self, ...)
end

-- Lines 11-36
function CoreShapeUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._timeline_color = Vector3(1, 1, 0)
	self._brush = Draw:brush()
	self._hed.trigger_times = 0
	self._hed.shape_type = "box"
	self._hed.width = 500
	self._hed.depth = 500
	self._hed.height = 500
	self._hed.radius = 250
	self._hed.grow = 0
	self._hed.unit_ids = nil

	table.insert(self._save_values, "shape_type")
	table.insert(self._save_values, "width")
	table.insert(self._save_values, "depth")
	table.insert(self._save_values, "height")
	table.insert(self._save_values, "radius")
	table.insert(self._save_values, "grow")
	table.insert(self._save_values, "unit_ids")
end

-- Lines 41-46
function CoreShapeUnitElement:update_selected(t, dt, selected_unit, all_units)
	local shape = self:get_shape()

	if shape then
		shape:draw(t, dt, 1, 1, 1)
	end
end

-- Lines 48-54
function CoreShapeUnitElement:get_shape()
	if not self._shape then
		self:_create_shapes()
	end

	return self._hed.shape_type == "box" and self._shape or self._hed.shape_type == "cylinder" and self._cylinder_shape
end

-- Lines 56-59
function CoreShapeUnitElement:set_shape_property(params)
	self._shape:set_property(params.property, self._hed[params.value])
	self._cylinder_shape:set_property(params.property, self._hed[params.value])
end

-- Lines 61-76
function CoreShapeUnitElement:_set_shape_type()
	local is_box = self._hed.shape_type == "box"
	local is_cylinder = self._hed.shape_type == "cylinder"
	local is_unit = self._hed.shape_type == "unit"

	self._depth_params.number_ctrlr:set_enabled(is_box)
	self._width_params.number_ctrlr:set_enabled(is_box)
	self._height_params.number_ctrlr:set_enabled(is_box or is_cylinder)
	self._radius_params.number_ctrlr:set_enabled(is_cylinder)
	self._grow_params.number_ctrlr:set_enabled(is_unit)
	self._sliders.depth:set_enabled(is_box)
	self._sliders.width:set_enabled(is_box)
	self._sliders.height:set_enabled(is_box or is_cylinder)
	self._sliders.radius:set_enabled(is_cylinder)
	self._sliders.grow:set_enabled(is_unit)
end

-- Lines 78-84
function CoreShapeUnitElement:_create_shapes()
	self._shape = CoreShapeManager.ShapeBoxMiddle:new({
		width = self._hed.width,
		depth = self._hed.depth,
		height = self._hed.height
	})

	self._shape:set_unit(self._unit)

	self._cylinder_shape = CoreShapeManager.ShapeCylinderMiddle:new({
		radius = self._hed.radius,
		height = self._hed.height
	})

	self._cylinder_shape:set_unit(self._unit)
end

-- Lines 86-91
function CoreShapeUnitElement:set_element_data(params, ...)
	CoreShapeUnitElement.super.set_element_data(self, params, ...)

	if params.value == "shape_type" then
		self:_set_shape_type()
	end
end

-- Lines 94-141
function CoreShapeUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "shape_type", {
		"box",
		"cylinder",
		"unit"
	}, "Select shape for area")

	if not self._shape then
		self:_create_shapes()
	end

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

	local radius, radius_params = self:_build_value_number(panel, panel_sizer, "radius", {
		floats = 0,
		min = 0
	}, "Set the radius for the shape")

	radius_params.name_ctrlr:set_label("Radius[cm]:")

	self._radius_params = radius_params

	radius:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_shape_property"), {
		value = "radius",
		property = "radius"
	})
	radius:connect("EVT_KILL_FOCUS", callback(self, self, "set_shape_property"), {
		value = "radius",
		property = "radius"
	})

	local grow, grow_params = self:_build_value_number(panel, panel_sizer, "grow", {
		floats = 0,
		min = 0
	}, "Set the grow(cm) for unit OOBB")

	grow_params.name_ctrlr:set_label("Grow[cm]:")

	self._grow_params = grow_params

	self:scale_slider(panel, panel_sizer, width_params, "width", "Width scale:")
	self:scale_slider(panel, panel_sizer, depth_params, "depth", "Depth scale:")
	self:scale_slider(panel, panel_sizer, height_params, "height", "Height scale:")
	self:scale_slider(panel, panel_sizer, radius_params, "radius", "Radius scale:")
	self:scale_slider(panel, panel_sizer, grow_params, "grow", "Grow OOBB:")
	self:_set_shape_type()
end

-- Lines 143-160
function CoreShapeUnitElement:scale_slider(panel, sizer, number_ctrlr_params, value, name)
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

-- Lines 162-167
function CoreShapeUnitElement:set_size(params)
	local value = self._hed[params.value] * params.ctrlr:get_value() / 100

	self._shape:set_property(params.value, value)
	self._cylinder_shape:set_property(params.value, value)
	CoreEWS.change_entered_number(params.number_ctrlr_params, value)
end

-- Lines 169-172
function CoreShapeUnitElement:size_release(params)
	self._hed[params.value] = params.number_ctrlr_params.value

	params.ctrlr:set_value(100)
end

-- Lines 174-190
function CoreShapeUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)

	if self._hed.unit_ids then
		for _, id in ipairs(self._hed.unit_ids) do
			local unit = managers.editor:layer("Statics"):created_units_pairs()[id]

			if alive(unit) then
				if self:_should_draw_link(selected_unit, unit) then
					self:_draw_link({
						g = 0.5,
						b = 0.75,
						r = 0,
						from_unit = unit,
						to_unit = self._unit
					})
					Application:draw(unit, 0, 0.5, 0.75)
				end
			else
				self:_remove_unit_id(id)
			end
		end
	end
end

-- Lines 192-203
function CoreShapeUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		self._hed.unit_ids = self._hed.unit_ids or {}
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.unit_ids, id) then
			self:_remove_unit_id(id)
		else
			self:_add_unit_id(id)
		end
	end
end

-- Lines 205-207
function CoreShapeUnitElement:_add_unit_id(id)
	table.insert(self._hed.unit_ids, id)
end

-- Lines 209-212
function CoreShapeUnitElement:_remove_unit_id(id)
	table.delete(self._hed.unit_ids, id)

	self._hed.unit_ids = #self._hed.unit_ids > 0 and self._hed.unit_ids or nil
end

-- Lines 214-215
function CoreShapeUnitElement:update_editing()
end

-- Lines 218-220
function CoreShapeUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end
