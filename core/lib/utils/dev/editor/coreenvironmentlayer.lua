core:module("CoreEnvironmentLayer")
core:import("CoreStaticLayer")
core:import("CoreEngineAccess")
core:import("CoreEws")
core:import("CoreEditorSave")
core:import("CoreShapeManager")
core:import("CoreEnvironmentFeeder")

EnvironmentLayer = EnvironmentLayer or class(CoreStaticLayer.StaticLayer)
EnvironmentLayer.ENABLE_PERMANENT = false

-- Lines 13-49
function EnvironmentLayer:init(owner)
	EnvironmentLayer.super.init(self, owner, "environment", {
		"environment"
	}, "environment_layer")

	self._environment_values = {}

	self:reset_environment_values()

	self._wind_pen = Draw:pen("green")
	self._wind_speeds = {}

	table.insert(self._wind_speeds, {
		speed = 0,
		description = "Calm",
		beaufort = 0
	})
	table.insert(self._wind_speeds, {
		speed = 0.3,
		description = "Light air",
		beaufort = 1
	})
	table.insert(self._wind_speeds, {
		speed = 1.6,
		description = "Light breeze",
		beaufort = 2
	})
	table.insert(self._wind_speeds, {
		speed = 3.4,
		description = "Gentle breeze",
		beaufort = 3
	})
	table.insert(self._wind_speeds, {
		speed = 5.5,
		description = "Moderate breeze",
		beaufort = 4
	})
	table.insert(self._wind_speeds, {
		speed = 8,
		description = "Fresh breeze",
		beaufort = 5
	})
	table.insert(self._wind_speeds, {
		speed = 10.8,
		description = "Strong breeze",
		beaufort = 6
	})
	table.insert(self._wind_speeds, {
		speed = 13.9,
		description = "Near Gale",
		beaufort = 7
	})
	table.insert(self._wind_speeds, {
		speed = 17.2,
		description = "Fresh Gale",
		beaufort = 8
	})
	table.insert(self._wind_speeds, {
		speed = 20.8,
		description = "Strong Gale",
		beaufort = 9
	})
	table.insert(self._wind_speeds, {
		speed = 24.5,
		description = "Whole storm",
		beaufort = 10
	})
	table.insert(self._wind_speeds, {
		speed = 28.5,
		description = "Violent storm",
		beaufort = 11
	})
	table.insert(self._wind_speeds, {
		speed = 32.7,
		description = "Hurricane",
		beaufort = 12
	})

	self._draw_wind = false
	self._draw_occ_shape = true
	self._wind_speed = 6
	self._wind_speed_variation = 1
	self._environment_area_unit = "core/units/environment_area/environment_area"
	self._effect_unit = "core/units/effect/effect"
	self._cubemap_unit = "core/units/cubemap_gizmo/cubemap_gizmo"
	self._dome_occ_shape_unit = "core/units/dome_occ_shape/dome_occ_shape"
	self._position_as_slot_mask = self._position_as_slot_mask + managers.slot:get_mask("statics")

	self._owner:viewport():set_environment("core/environments/default")
end

-- Lines 50-52
function EnvironmentLayer:get_layer_name()
	return "Environment"
end

-- Lines 54-78
function EnvironmentLayer:load(world_holder, offset)
	local environment = world_holder:create_world("world", self._save_name, offset)

	if not self:old_load(environment) then
		self._environment_values = environment.environment_values

		CoreEws.change_combobox_value(self._environments_combobox, self._environment_values.environment)
		self._dome_occ_resolution_ctrlr:set_value(self._environment_values.dome_occ_resolution)
		self:_load_wind(environment.wind)
		self:_load_effects(environment.effects)
		self:_load_environment_areas()
		self:_load_dome_occ_shapes(environment.dome_occ_shapes)

		for _, unit in ipairs(environment.units) do
			self:set_up_name_id(unit)
			self._owner:register_unit_id(unit)
			table.insert(self._created_units, unit)
		end
	end

	self:clear_selected_units()

	return environment
end

-- Lines 80-97
function EnvironmentLayer:_load_wind(wind)
	self._wind_rot = Rotation(wind.angle, 0, wind.tilt)
	self._wind_dir_var = wind.angle_var
	self._wind_tilt_var = wind.tilt_var
	self._wind_speed = wind.speed or self._wind_speed
	self._wind_speed_variation = wind.speed_variation or self._wind_speed_variation

	self._wind_ctrls.wind_speed:set_value(self._wind_speed * 10)
	self._wind_ctrls.wind_speed_variation:set_value(self._wind_speed_variation * 10)
	self:update_wind_speed_labels()
	self._wind_ctrls.wind_direction:set_value(wind.angle)
	self._wind_ctrls.wind_variation:set_value(self._wind_dir_var)
	self._wind_ctrls.tilt_angle:set_value(wind.tilt)
	self._wind_ctrls.tilt_variation:set_value(self._wind_tilt_var)
	self:set_wind()
end

-- Lines 99-107
function EnvironmentLayer:_load_effects(effects)
	for _, effect in ipairs(effects) do
		local unit = self:do_spawn_unit(self._effect_unit, effect.position, effect.rotation)

		if effect.name_id then
			self:set_name_id(unit, effect.name_id)
		end

		self:play_effect(unit, effect.name)
	end
end

-- Lines 109-118
function EnvironmentLayer:_load_environment_areas()
	for _, area in ipairs(managers.environment_area:areas()) do
		local unit = EnvironmentLayer.super.do_spawn_unit(self, self._environment_area_unit, area:position(), area:rotation())
		unit:unit_data().environment_area = area
		local new_name_id = unit:unit_data().environment_area:set_unit(unit)

		if new_name_id then
			self:set_name_id(unit, new_name_id)
		end
	end
end

-- Lines 120-130
function EnvironmentLayer:_load_dome_occ_shapes(dome_occ_shapes)
	if not dome_occ_shapes then
		return
	end

	for _, dome_occ_shape in ipairs(dome_occ_shapes) do
		local unit = EnvironmentLayer.super.do_spawn_unit(self, self._dome_occ_shape_unit, dome_occ_shape.position, dome_occ_shape.rotation)
		unit:unit_data().occ_shape = CoreShapeManager.ShapeBox:new(dome_occ_shape)

		unit:unit_data().occ_shape:set_unit(unit)
	end
end

-- Lines 133-192
function EnvironmentLayer:old_load(environment)
	if not environment._values then
		return false
	end

	for name, value in pairs(environment._values) do
		self._environment_values[name] = value
	end

	CoreEws.change_combobox_value(self._environments_combobox, self._environment_values.environment)

	if environment._wind then
		local wind_angle = environment._wind.wind_angle
		local wind_tilt = environment._wind.wind_tilt
		self._wind_rot = Rotation(wind_angle, 0, wind_tilt)
		self._wind_dir_var = environment._wind.wind_dir_var
		self._wind_tilt_var = environment._wind.wind_tilt_var
		self._wind_speed = environment._wind.wind_speed or self._wind_speed
		self._wind_speed_variation = environment._wind.wind_speed_variation or self._wind_speed_variation

		self._wind_ctrls.wind_speed:set_value(self._wind_speed * 10)
		self._wind_ctrls.wind_speed_variation:set_value(self._wind_speed_variation * 10)
		self:update_wind_speed_labels()
		self._wind_ctrls.wind_direction:set_value(wind_angle)
		self._wind_ctrls.wind_variation:set_value(self._wind_dir_var)
		self._wind_ctrls.tilt_angle:set_value(wind_tilt)
		self._wind_ctrls.tilt_variation:set_value(self._wind_tilt_var)
		self:set_wind()
	end

	if environment._unit_effects then
		for _, effect in ipairs(environment._unit_effects) do
			local unit = self:do_spawn_unit(self._effect_unit, effect.pos, effect.rot)

			self:play_effect(unit, effect.name)
		end
	end

	for _, area in ipairs(managers.environment_area:areas()) do
		local unit = EnvironmentLayer.super.do_spawn_unit(self, self._environment_area_unit, area:position(), area:rotation())
		unit:unit_data().environment_area = area
		local new_name_id = unit:unit_data().environment_area:set_unit(unit)

		if new_name_id then
			self:set_name_id(unit, new_name_id)
		end
	end

	if environment._units then
		for _, unit in ipairs(environment._units) do
			self:set_up_name_id(unit)
			table.insert(self._created_units, unit)
		end
	end

	self:clear_selected_units()

	return environment
end

-- Lines 194-262
function EnvironmentLayer:save()
	local effects = {}
	local environment_areas = {}
	local environment_paths = {}
	local environment_scenes = {}
	local cubemap_gizmos = {}
	local dome_occ_shapes = {}

	for _, unit in ipairs(self._created_units) do
		if unit:name() == Idstring(self._effect_unit) then
			local effect = unit:unit_data().effect or "none"
			local name_id = unit:unit_data().name_id

			table.insert(effects, {
				name = effect,
				name_id = name_id,
				position = unit:position(),
				rotation = unit:rotation()
			})
			self:_save_to_world_package("effects", effect)
		elseif unit:name() == Idstring(self._environment_area_unit) then
			local area = unit:unit_data().environment_area
			local environment_path = area:environment()

			table.insert(environment_areas, area:save_level_data())
			table.insert(environment_paths, environment_path)

			if area:permanent() or table.contains(area:filter_list(), CoreEnvironmentFeeder.UnderlayPathFeeder.DATA_PATH_KEY) then
				table.insert(environment_scenes, managers.viewport:get_environment_value(environment_path, CoreEnvironmentFeeder.UnderlayPathFeeder.DATA_PATH_KEY))
			end
		elseif unit:name() == Idstring(self._cubemap_unit) then
			table.insert(cubemap_gizmos, CoreEditorSave.save_data_table(unit))
		elseif unit:name() == Idstring(self._dome_occ_shape_unit) then
			local shape = unit:unit_data().occ_shape

			table.insert(dome_occ_shapes, shape:save_level_data())
		end
	end

	local wind = {
		angle = self._wind_rot:yaw(),
		angle_var = self._wind_dir_var,
		tilt = self._wind_rot:roll(),
		tilt_var = self._wind_tilt_var,
		speed = self._wind_speed,
		speed_variation = self._wind_speed_variation
	}
	local data = {
		environment_values = self._environment_values,
		wind = wind,
		effects = effects,
		environment_areas = environment_areas,
		cubemap_gizmos = cubemap_gizmos,
		dome_occ_shapes = dome_occ_shapes
	}

	self:_add_project_save_data(data)

	local t = {
		single_data_block = true,
		entry = self._save_name,
		data = data
	}

	managers.editor:add_save_data(t)
	table.insert(environment_paths, self._environment_values.environment)
	table.insert(environment_scenes, managers.viewport:get_environment_value(self._environment_values.environment, CoreEnvironmentFeeder.UnderlayPathFeeder.DATA_PATH_KEY))

	for _, environment_path in ipairs(environment_paths) do
		self:_save_to_world_package("script_data", environment_path .. ".environment")
	end

	for _, environment_scene in ipairs(environment_scenes) do
		self:_save_to_world_package("scenes", environment_scene)
	end
end

-- Lines 264-268
function EnvironmentLayer:_save_to_world_package(category, name)
	if name and name ~= "none" then
		managers.editor:add_to_world_package({
			category = category,
			name = name
		})
	end
end

-- Lines 270-314
function EnvironmentLayer:update(t, dt)
	EnvironmentLayer.super.update(self, t, dt)

	if self._draw_wind then
		for i = -0.9, 1.2, 0.3 do
			for j = -0.9, 1.2, 0.3 do
				self:draw_wind(self._owner:screen_to_world(Vector3(j, i, 0), 1000))
			end
		end
	end

	for _, unit in ipairs(self._created_units) do
		if unit:unit_data().current_effect then
			World:effect_manager():move(unit:unit_data().current_effect, unit:position())
			World:effect_manager():rotate(unit:unit_data().current_effect, unit:rotation())
		end

		if unit:name() == Idstring(self._effect_unit) then
			Application:draw(unit, 0, 0, 1)
		end

		if unit:name() == Idstring(self._environment_area_unit) then
			local r = 0
			local g = 0.5
			local b = 0.5

			if alive(self._selected_unit) and unit == self._selected_unit then
				b = 1
				g = 1
				r = 0
			end

			Application:draw(unit, r, g, b)
			unit:unit_data().environment_area:draw(t, dt, r, g, b)
		end

		if self._draw_occ_shape and unit:name() == Idstring(self._dome_occ_shape_unit) then
			local r = 0.5
			local g = 0
			local b = 0.5

			if alive(self._selected_unit) and unit == self._selected_unit then
				b = 1
				g = 0
				r = 1
			end

			Application:draw(unit, r, g, b)
			unit:unit_data().occ_shape:draw(t, dt, r, g, b)
		end
	end
end

-- Lines 316-325
function EnvironmentLayer:draw_wind(pos)
	local rot = Rotation(self._wind_rot:yaw(), self._wind_rot:pitch(), self._wind_rot:roll() * -1)

	self._wind_pen:arrow(pos, pos + rot:x() * 300, 0.25)
	self._wind_pen:arc(pos, pos + rot:x() * 100, self._wind_dir_var, rot:z(), 32)
	self._wind_pen:arc(pos, pos + rot:x() * 100, -self._wind_dir_var, rot:z(), 32)
	self._wind_pen:arc(pos, pos + rot:x() * 100, self._wind_tilt_var, rot:y(), 32)
	self._wind_pen:arc(pos, pos + rot:x() * 100, -self._wind_tilt_var, rot:y(), 32)
end

-- Lines 327-340
function EnvironmentLayer:_build_environment_combobox_and_list()
	local ctrlr, combobox_params = CoreEws.combobox_and_list({
		name = "Default",
		panel = self._env_panel,
		sizer = self._environment_sizer,
		options = managers.database:list_entries_of_type("environment"),
		value = self._environment_values.environment,
		value_changed_cb = function (params)
			self:change_environment(params.ctrlr)
		end
	})
	self._environments_combobox = combobox_params

	managers.viewport:editor_add_environment_created_callback(callback(self, self, "on_environment_list_changed"))
end

-- Lines 342-351
function EnvironmentLayer:on_environment_list_changed()
	local list = managers.database:list_entries_of_type("environment")
	local selected_value = self._environments_combobox.ctrlr:get_value()

	CoreEws.update_combobox_options(self._environments_combobox, list)

	if table.contains(list, selected_value) then
		self._environments_combobox.ctrlr:set_value(selected_value)
	end
end

-- Lines 353-585
function EnvironmentLayer:build_panel(notebook)
	EnvironmentLayer.super.build_panel(self, notebook)
	cat_print("editor", "EnvironmentLayer:build_panel")

	self._env_panel = EWS:Panel(self._ews_panel, "", "TAB_TRAVERSAL")
	self._env_sizer = EWS:BoxSizer("VERTICAL")

	self._env_panel:set_sizer(self._env_sizer)

	local cubemap_sizer = EWS:StaticBoxSizer(self._env_panel, "HORIZONTAL", "Cubemaps")
	local create_cube_map = EWS:Button(self._env_panel, "Generate all", "", "BU_EXACTFIT,NO_BORDER")

	cubemap_sizer:add(create_cube_map, 1, 5, "EXPAND,TOP,RIGHT")
	create_cube_map:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "create_cube_map"), "all")

	local create_selected_cube_map = EWS:Button(self._env_panel, "Generate selected", "", "BU_EXACTFIT,NO_BORDER")

	cubemap_sizer:add(create_selected_cube_map, 1, 5, "EXPAND,TOP")
	create_selected_cube_map:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "create_cube_map"), "selected")
	self._env_sizer:add(cubemap_sizer, 0, 0, "EXPAND")

	self._environment_sizer = EWS:StaticBoxSizer(self._env_panel, "VERTICAL", "Environment")

	self:_build_environment_combobox_and_list()

	self._environment_area_ctrls = {}
	local ctrlr, combobox_params = CoreEws.combobox_and_list({
		name = "Area:",
		panel = self._env_panel,
		sizer = self._environment_sizer,
		options = managers.database:list_entries_of_type("environment"),
		value = managers.viewport:game_default_environment(),
		value_changed_cb = function (params)
			self:set_environment_area(params.ctrlr)
		end
	})
	self._environment_area_ctrls.environment_combobox = combobox_params
	local transition_prio_sizer = EWS:BoxSizer("HORIZONTAL")

	transition_prio_sizer:add(EWS:StaticText(self._env_panel, "Fade Time [sec]: ", "", ""), 0, 0, "ALIGN_CENTER_VERTICAL")

	local default_transition_text = string.format("%.2f", managers.environment_area:default_transition_time())
	local transition = EWS:TextCtrl(self._env_panel, default_transition_text, "", "TE_CENTRE")

	transition_prio_sizer:add(transition, 3, 0, "EXPAND")
	transition:connect("EVT_CHAR", callback(nil, _G, "verify_number"), transition)
	transition:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_transition_time"), nil)
	transition:connect("EVT_KILL_FOCUS", callback(self, self, "set_transition_time"), nil)
	transition_prio_sizer:add_spacer(10, 0)
	transition_prio_sizer:add(EWS:StaticText(self._env_panel, "Prio (1=highest): ", "", ""), 0, 0, "ALIGN_CENTER_VERTICAL")

	local default_prio_text = tostring(managers.environment_area:default_prio())
	local prio = EWS:TextCtrl(self._env_panel, default_prio_text, "", "TE_CENTRE")

	transition_prio_sizer:add(prio, 3, 0, "EXPAND")
	prio:connect("EVT_CHAR", callback(nil, _G, "verify_number"), prio)
	prio:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_prio"), nil)
	prio:connect("EVT_KILL_FOCUS", callback(self, self, "set_prio"), nil)
	self._environment_sizer:add(transition_prio_sizer, 0, 0, "EXPAND")

	local permanent_cb = EWS:CheckBox(self._env_panel, "Permanent", "")

	permanent_cb:set_value(false)
	permanent_cb:set_tool_tip("This is only useful when it's a linear single player game.")
	permanent_cb:set_enabled(self.ENABLE_PERMANENT)
	self._environment_sizer:add(permanent_cb, 0, 0, "EXPAND")
	permanent_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_permanent"), nil)

	self._environment_area_ctrls.transition_time = transition
	self._environment_area_ctrls.prio = prio
	self._environment_area_ctrls.permanent_cb = permanent_cb

	self._env_sizer:add(self._environment_sizer, 0, 0, "EXPAND")

	self._dome_occ_sizer = EWS:StaticBoxSizer(self._env_panel, "VERTICAL", "Dome Occlusion Shape")
	local draw_occ_cb = EWS:CheckBox(self._env_panel, "Draw", "")

	draw_occ_cb:set_value(self._draw_occ_shape)
	self._dome_occ_sizer:add(draw_occ_cb, 0, 0, "EXPAND")
	draw_occ_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_draw_occ_shape",
		cb = draw_occ_cb
	})

	local generate_dome_occ = EWS:Button(self._env_panel, "Generate", "", "BU_EXACTFIT,NO_BORDER")

	self._dome_occ_sizer:add(generate_dome_occ, 1, 5, "EXPAND,TOP,RIGHT")
	generate_dome_occ:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "generate_dome_occ"), "all")

	local resolution_sizer = EWS:BoxSizer("HORIZONTAL")

	resolution_sizer:add(EWS:StaticText(self._env_panel, "Resolution:", 0, ""), 2, 0, "ALIGN_CENTER_VERTICAL")

	local resolution = EWS:ComboBox(self._env_panel, "", "", "CB_DROPDOWN,CB_READONLY")

	for _, res in pairs({
		64,
		128,
		256,
		512,
		1024
	}) do
		resolution:append(res)
	end

	resolution:set_value(self._environment_values.dome_occ_resolution)
	resolution:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_dome_occ_resolution"), resolution)
	resolution_sizer:add(resolution, 3, 0, "EXPAND")

	self._dome_occ_resolution_ctrlr = resolution

	self._dome_occ_sizer:add(resolution_sizer, 0, 0, "EXPAND")
	self._env_sizer:add(self._dome_occ_sizer, 0, 0, "EXPAND")

	local wind_sizer = EWS:StaticBoxSizer(self._env_panel, "VERTICAL", "Wind")
	local show_wind_cb = EWS:CheckBox(self._env_panel, "Draw Wind", "")

	show_wind_cb:set_value(self._draw_wind)
	wind_sizer:add(show_wind_cb, 0, 0, "EXPAND")
	show_wind_cb:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "cb_toogle"), {
		value = "_draw_wind",
		cb = show_wind_cb
	})

	local direction_sizer = EWS:StaticBoxSizer(self._env_panel, "HORIZONTAL", "Direction / Variation")
	local wind_direction = EWS:Slider(self._env_panel, 0, 0, 360, "", "")

	wind_direction:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_wind_direction"), wind_direction)
	wind_direction:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_wind_direction"), wind_direction)
	direction_sizer:add(wind_direction, 2, 0, "EXPAND")

	local wind_variation = EWS:SpinCtrl(self._env_panel, 0, "", "")

	wind_variation:set_range(0, 180)
	wind_variation:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_wind_variation"), wind_variation)
	wind_variation:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_wind_variation"), wind_variation)
	direction_sizer:add(wind_variation, 1, 0, "EXPAND")
	wind_sizer:add(direction_sizer, 0, 0, "EXPAND")

	local tilt_sizer = EWS:StaticBoxSizer(self._env_panel, "HORIZONTAL", "Tilt / Variation")
	local tilt_angle = EWS:Slider(self._env_panel, 0, -90, 90, "", "")

	tilt_angle:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_tilt_angle"), tilt_angle)
	tilt_angle:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_tilt_angle"), tilt_angle)
	tilt_sizer:add(tilt_angle, 2, 0, "EXPAND")

	local tilt_variation = EWS:SpinCtrl(self._env_panel, 0, "", "")

	tilt_variation:set_range(-90, 90)
	tilt_variation:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_tilt_variation"), tilt_variation)
	tilt_variation:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "update_tilt_variation"), tilt_variation)
	tilt_sizer:add(tilt_variation, 1, 0, "EXPAND")
	wind_sizer:add(tilt_sizer, 0, 0, "EXPAND")

	local speed_sizer = EWS:StaticBoxSizer(self._env_panel, "VERTICAL", "Speed / Variation")
	local speed_help_sizer = EWS:BoxSizer("HORIZONTAL")
	self._speed_text = EWS:StaticText(self._env_panel, self._wind_speed .. " m/s", 0, "")
	self._speed_beaufort = EWS:StaticText(self._env_panel, "Beaufort: " .. self:wind_beaufort(self._wind_speed), 0, "")
	self._speed_description = EWS:StaticText(self._env_panel, self:wind_description(self._wind_speed), 0, "")

	self._speed_text:set_font_size(9)
	self._speed_beaufort:set_font_size(9)
	self._speed_description:set_font_size(9)
	speed_help_sizer:add(self._speed_description, 4, 0, "EXPAND")
	speed_help_sizer:add(self._speed_beaufort, 3, 0, "EXPAND")

	local wind_speed_help = EWS:BitmapButton(self._env_panel, CoreEws.image_path("toolbar\\help_16x16.png"), "", "NO_BORDER")

	wind_speed_help:set_tool_tip("Wind speed references.")
	wind_speed_help:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_wind_speed_help"), nil)
	speed_help_sizer:add(wind_speed_help, 0, 0, "EXPAND")
	speed_sizer:add(speed_help_sizer, 0, 0, "EXPAND")

	local wind_speed_sizer = EWS:BoxSizer("HORIZONTAL")
	local wind_speed = EWS:Slider(self._env_panel, self._wind_speed * 10, 0, 408, "", "")

	wind_speed:set_tool_tip("Wind speed [m/s]")
	wind_speed:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_wind_speed"), wind_speed)
	wind_speed:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_wind_speed"), wind_speed)
	wind_speed_sizer:add(wind_speed, 10, 5, "EXPAND,RIGHT")
	wind_speed_sizer:add(self._speed_text, 3, 0, "EXPAND,ALIGN_CENTER_VERTICAL")
	speed_sizer:add(wind_speed_sizer, 0, 0, "EXPAND")

	local wind_speed_variation_sizer = EWS:BoxSizer("HORIZONTAL")
	local wind_speed_variation = EWS:Slider(self._env_panel, self._wind_speed_variation * 10, 0, 408, "", "")

	wind_speed_variation:set_tool_tip("Wind speed variation [m/s]")
	wind_speed_variation:connect("EVT_SCROLL_CHANGED", callback(self, self, "update_wind_speed_variation"), wind_speed_variation)
	wind_speed_variation:connect("EVT_SCROLL_THUMBTRACK", callback(self, self, "update_wind_speed_variation"), wind_speed_variation)
	wind_speed_variation_sizer:add(wind_speed_variation, 10, 5, "EXPAND,RIGHT")

	self._speed_variation_text = EWS:StaticText(self._env_panel, self._wind_speed_variation .. " m/s", 0, "")

	self._speed_variation_text:set_font_size(9)
	wind_speed_variation_sizer:add(self._speed_variation_text, 3, 0, "EXPAND,ALIGN_CENTER_VERTICAL")
	speed_sizer:add(wind_speed_variation_sizer, 0, 0, "EXPAND")
	wind_sizer:add(speed_sizer, 0, 0, "EXPAND")
	self._env_sizer:add(wind_sizer, 0, 0, "EXPAND")

	self._wind_ctrls = {
		wind_direction = wind_direction,
		wind_variation = wind_variation,
		tilt_angle = tilt_angle,
		tilt_variation = tilt_variation,
		wind_speed = wind_speed,
		wind_speed_variation = wind_speed_variation
	}
	local unit_effect_sizer = EWS:BoxSizer("HORIZONTAL")

	unit_effect_sizer:add(EWS:StaticText(self._env_panel, "Effect", 0, ""), 1, 5, "EXPAND,ALIGN_CENTER_VERTICAL,TOP")

	self._unit_effects = EWS:ComboBox(self._env_panel, "", "", "CB_DROPDOWN,CB_READONLY")

	self:populate_unit_effects()
	self._unit_effects:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "change_unit_effect"), nil)
	unit_effect_sizer:add(self._unit_effects, 4, 0, "EXPAND")

	local reload_effects = EWS:BitmapButton(self._env_panel, CoreEws.image_path("world_editor\\reload_unit_effects.png"), "", "NO_BORDER")

	reload_effects:set_tool_tip("Repopulate combo box with effects from the database.")
	reload_effects:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "populate_unit_effects"), nil)
	unit_effect_sizer:add(reload_effects, 0, 5, "EXPAND,LEFT")
	self._env_sizer:add(unit_effect_sizer, 0, 0, "EXPAND")
	self._sizer:add(self._env_panel, 4, 0, "EXPAND")

	return self._ews_panel
end

-- Lines 587-597
function EnvironmentLayer:populate_unit_effects()
	self._unit_effects:clear()
	self._unit_effects:append("none")

	for _, name in ipairs(managers.database:list_entries_of_type("effect")) do
		if string.match(name, "scene_") then
			self._unit_effects:append(name)
		end
	end

	self._unit_effects:set_value("none")
	self:update_unit_settings()
end

-- Lines 599-615
function EnvironmentLayer:create_cube_map(type)
	local cubes = {}

	if type == "all" then
		for _, unit in ipairs(self._created_units) do
			if unit:name() == Idstring(self._cubemap_unit) then
				table.insert(cubes, {
					output_name = "outputcube",
					position = unit:position(),
					name = unit:unit_data().name_id
				})
			end
		end
	elseif type == "selected" and self._selected_unit:name() == Idstring(self._cubemap_unit) then
		table.insert(cubes, {
			output_name = "outputcube",
			position = self._selected_unit:position(),
			name = self._selected_unit:unit_data().name_id
		})
	end

	local params = {
		cubes = cubes,
		output_path = managers.database:base_path() .. "environments\\cubemaps\\"
	}

	managers.editor:create_cube_map(params)
end

-- Lines 617-621
function EnvironmentLayer:change_environment(ctrlr)
	self._environment_values.environment = ctrlr:get_value()

	managers.viewport:set_default_environment(self._environment_values.environment, nil, nil)
end

-- Lines 623-626
function EnvironmentLayer:set_environment_area()
	local area = self._selected_unit:unit_data().environment_area

	area:set_environment(self._environment_area_ctrls.environment_combobox.value)
end

-- Lines 628-631
function EnvironmentLayer:set_permanent()
	local area = self._selected_unit:unit_data().environment_area

	area:set_permanent(self._environment_area_ctrls.permanent_cb:get_value())
end

-- Lines 633-639
function EnvironmentLayer:set_transition_time()
	local area = self._selected_unit:unit_data().environment_area
	local value = tonumber(self._environment_area_ctrls.transition_time:get_value())
	value = math.clamp(value, 0, 100000000)

	self._environment_area_ctrls.transition_time:change_value(string.format("%.2f", value))
	area:set_transition_time(value)
end

-- Lines 641-647
function EnvironmentLayer:set_prio()
	local area = self._selected_unit:unit_data().environment_area
	local value = tonumber(self._environment_area_ctrls.prio:get_value())
	value = math.clamp(value, 1, 100000000)

	self._environment_area_ctrls.prio:change_value(tostring(value))
	area:set_prio(value)
end

-- Lines 649-664
function EnvironmentLayer:generate_dome_occ()
	local shape = nil

	for _, unit in ipairs(self:created_units()) do
		if unit:name() == Idstring(self._dome_occ_shape_unit) then
			shape = unit:unit_data().occ_shape

			break
		end
	end

	if not shape then
		managers.editor:output_error("No dome occ unit in level!")

		return
	end

	local res = self._environment_values.dome_occ_resolution or 256

	managers.editor:init_create_dome_occlusion(shape, res)
end

-- Lines 666-668
function EnvironmentLayer:set_dome_occ_resolution()
	self._environment_values.dome_occ_resolution = tonumber(self._dome_occ_resolution_ctrlr:get_value())
end

-- Lines 670-674
function EnvironmentLayer:update_wind_direction(wind_direction)
	local dir = wind_direction:get_value()
	self._wind_rot = Rotation(dir, 0, self._wind_rot:roll())

	self:set_wind()
end

-- Lines 676-681
function EnvironmentLayer:set_wind()
	Wind:set_direction(self._wind_rot:yaw(), self._wind_dir_var, 5)
	Wind:set_tilt(self._wind_rot:roll(), self._wind_tilt_var, 5)
	Wind:set_speed_m_s(self._wind_speed, self._wind_speed_variation, 5)
	Wind:set_enabled(true)
end

-- Lines 683-686
function EnvironmentLayer:update_wind_variation(wind_variation)
	self._wind_dir_var = wind_variation:get_value()

	self:set_wind()
end

-- Lines 688-692
function EnvironmentLayer:update_tilt_angle(tilt_angle)
	local dir = tilt_angle:get_value()
	self._wind_rot = Rotation(self._wind_rot:yaw(), 0, dir)

	self:set_wind()
end

-- Lines 694-697
function EnvironmentLayer:update_tilt_variation(tilt_variation)
	self._wind_tilt_var = tilt_variation:get_value()

	self:set_wind()
end

-- Lines 699-701
function EnvironmentLayer:on_wind_speed_help()
	EWS:launch_url("http://en.wikipedia.org/wiki/Beaufort_scale")
end

-- Lines 703-707
function EnvironmentLayer:update_wind_speed(wind_speed)
	self._wind_speed = wind_speed:get_value() / 10

	self:update_wind_speed_labels()
	self:set_wind()
end

-- Lines 709-713
function EnvironmentLayer:update_wind_speed_variation(wind_speed_variation)
	self._wind_speed_variation = wind_speed_variation:get_value() / 10

	self:update_wind_speed_labels()
	self:set_wind()
end

-- Lines 715-720
function EnvironmentLayer:update_wind_speed_labels()
	self._speed_text:set_value(string.format("%.3g", self._wind_speed) .. " m/s")
	self._speed_beaufort:set_value("Beaufort: " .. self:wind_beaufort(self._wind_speed))
	self._speed_description:set_value(self:wind_description(self._wind_speed))
	self._speed_variation_text:set_value(string.format("%.3g", self._wind_speed_variation) .. " m/s")
end

-- Lines 722-726
function EnvironmentLayer:unit_ok(unit)
	return unit:name() == Idstring(self._effect_unit) or unit:name() == Idstring(self._cubemap_unit) or unit:name() == Idstring(self._environment_area_unit) or unit:name() == Idstring(self._dome_occ_shape_unit)
end

-- Lines 728-753
function EnvironmentLayer:do_spawn_unit(...)
	local unit = EnvironmentLayer.super.do_spawn_unit(self, ...)

	if alive(unit) then
		if unit:name() == Idstring(self._environment_area_unit) then
			if not unit:unit_data().environment_area then
				unit:unit_data().environment_area = managers.environment_area:add_area({})

				unit:unit_data().environment_area:set_unit(unit)

				self._current_shape_panel = unit:unit_data().environment_area:panel(self._env_panel, self._environment_sizer)
			end

			self:set_environment_area_parameters()
		end

		if unit:name() == Idstring(self._dome_occ_shape_unit) then
			if not unit:unit_data().occ_shape then
				unit:unit_data().occ_shape = CoreShapeManager.ShapeBox:new({})

				unit:unit_data().occ_shape:set_unit(unit)

				self._current_shape_panel = unit:unit_data().occ_shape:panel(self._env_panel, self._dome_occ_sizer)
			end

			self:set_environment_area_parameters()
		end
	end

	return unit
end

-- Lines 755-773
function EnvironmentLayer:clone_edited_values(unit, source)
	EnvironmentLayer.super.clone_edited_values(self, unit, source)

	if unit:name() == Idstring(self._environment_area_unit) then
		local area = unit:unit_data().environment_area
		local source_area = source:unit_data().environment_area

		area:set_environment(source_area:environment())
		area:set_filter_list(source_area:filter_list() and table.list_copy(source_area:filter_list()))
		area:set_bezier_curve(source_area:bezier_curve() and table.list_copy(source_area:bezier_curve()))
		area:set_transition_time(source_area:transition_time())
		area:set_prio(source_area:prio())
		area:set_permanent(source_area:permanent())
		area:set_property("width", source_area:property("width"))
		area:set_property("depth", source_area:property("depth"))
		area:set_property("height", source_area:property("height"))
	end

	if unit:name() == Idstring(self._effect_unit) then
		self:play_effect(unit, source:unit_data().effect)
	end
end

-- Lines 776-800
function EnvironmentLayer:delete_unit(unit)
	self:kill_effect(unit)

	if unit:name() == Idstring(self._environment_area_unit) then
		managers.environment_area:remove_area(unit:unit_data().environment_area)

		if unit:unit_data().environment_area:panel() then
			if self._current_shape_panel == unit:unit_data().environment_area:panel() then
				self._current_shape_panel = nil
			end

			unit:unit_data().environment_area:panel():destroy()
			self._env_panel:layout()
		end
	end

	if unit:name() == Idstring(self._dome_occ_shape_unit) and unit:unit_data().occ_shape:panel() then
		if self._current_shape_panel == unit:unit_data().occ_shape:panel() then
			self._current_shape_panel = nil
		end

		unit:unit_data().occ_shape:panel():destroy()
		self._env_panel:layout()
	end

	EnvironmentLayer.super.delete_unit(self, unit)
end

-- Lines 802-808
function EnvironmentLayer:play_effect(unit, effect)
	unit:unit_data().effect = effect

	if DB:has("effect", effect) then
		CoreEngineAccess._editor_load(Idstring("effect"), effect:id())

		unit:unit_data().current_effect = World:effect_manager():spawn({
			effect = Idstring(effect),
			position = unit:position(),
			rotation = unit:rotation()
		})
	end
end

-- Lines 810-817
function EnvironmentLayer:kill_effect(unit)
	if unit:name() == Idstring(self._effect_unit) and unit:unit_data().current_effect then
		World:effect_manager():kill(unit:unit_data().current_effect)

		unit:unit_data().current_effect = nil
	end
end

-- Lines 819-822
function EnvironmentLayer:change_unit_effect()
	self:kill_effect(self._selected_unit)
	self:play_effect(self._selected_unit, self._unit_effects:get_value())
end

-- Lines 824-834
function EnvironmentLayer:update_unit_settings()
	EnvironmentLayer.super.update_unit_settings(self)
	self._unit_effects:set_enabled(false)

	if alive(self._selected_unit) and self._selected_unit:name() == Idstring(self._effect_unit) then
		self._unit_effects:set_enabled(true)
		self._unit_effects:set_value(self._selected_unit:unit_data().effect or "none")
	end

	self:set_environment_area_parameters()
end

-- Lines 836-879
function EnvironmentLayer:set_environment_area_parameters()
	CoreEws.set_combobox_and_list_enabled(self._environment_area_ctrls.environment_combobox, false)
	self._environment_area_ctrls.permanent_cb:set_enabled(false)
	self._environment_area_ctrls.transition_time:set_enabled(false)
	self._environment_area_ctrls.prio:set_enabled(false)

	if self._current_shape_panel then
		self._current_shape_panel:set_visible(false)
	end

	if alive(self._selected_unit) and self._selected_unit:name() == Idstring(self._environment_area_unit) then
		local area = self._selected_unit:unit_data().environment_area

		if area then
			self._current_shape_panel = area:panel(self._env_panel, self._environment_sizer)

			self._current_shape_panel:set_visible(true)
			CoreEws.set_combobox_and_list_enabled(self._environment_area_ctrls.environment_combobox, true)
			CoreEws.change_combobox_value(self._environment_area_ctrls.environment_combobox, area:environment())
			self._environment_area_ctrls.permanent_cb:set_enabled(self.ENABLE_PERMANENT)
			self._environment_area_ctrls.permanent_cb:set_value(self.ENABLE_PERMANENT and area:permanent())
			self._environment_area_ctrls.transition_time:set_enabled(true)
			self._environment_area_ctrls.transition_time:set_value(string.format("%.2f", area:transition_time()))
			self._environment_area_ctrls.prio:set_enabled(true)
			self._environment_area_ctrls.prio:set_value(tostring(area:prio()))
		end
	end

	if alive(self._selected_unit) and self._selected_unit:name() == Idstring(self._dome_occ_shape_unit) then
		local shape = self._selected_unit:unit_data().occ_shape

		if shape then
			self._current_shape_panel = shape:panel(self._env_panel, self._dome_occ_sizer)

			self._current_shape_panel:set_visible(true)
		end
	end

	self._env_panel:layout()
	self._ews_panel:fit_inside()
	self._ews_panel:refresh()
end

-- Lines 882-891
function EnvironmentLayer:wind_description(speed)
	local description = nil

	for _, data in ipairs(self._wind_speeds) do
		if speed < data.speed then
			return description
		end

		description = data.description
	end

	return description
end

-- Lines 893-902
function EnvironmentLayer:wind_beaufort(speed)
	local beaufort = nil

	for _, data in ipairs(self._wind_speeds) do
		if speed < data.speed then
			return beaufort
		end

		beaufort = data.beaufort
	end

	return beaufort
end

-- Lines 904-911
function EnvironmentLayer:reset_environment_values()
	self._environment_values.environment = managers.viewport:game_default_environment()

	managers.viewport:update_global_environment_value(CoreEnvironmentFeeder.SkyRotationFeeder.DATA_PATH_KEY)

	self._environment_values.dome_occ_resolution = 256
end

-- Lines 913-951
function EnvironmentLayer:clear()
	managers.viewport:editor_reset_environment()
	self:reset_environment_values()
	managers.viewport:set_default_environment(self._environment_values.environment, nil, nil)
	CoreEws.change_combobox_value(self._environments_combobox, self._environment_values.environment)
	self._dome_occ_resolution_ctrlr:set_value(self._environment_values.dome_occ_resolution)

	self._wind_rot = Rotation(0, 0, 0)
	self._wind_dir_var = 0
	self._wind_tilt_var = 0
	self._wind_speed = 6
	self._wind_speed_variation = 1

	self._wind_ctrls.wind_speed:set_value(self._wind_speed * 10)
	self._wind_ctrls.wind_speed_variation:set_value(self._wind_speed_variation * 10)
	self:update_wind_speed_labels()
	self._wind_ctrls.wind_direction:set_value(0)
	self._wind_ctrls.wind_variation:set_value(0)
	self._wind_ctrls.tilt_angle:set_value(0)
	self._wind_ctrls.tilt_variation:set_value(0)
	self:set_wind()

	for _, unit in ipairs(self._created_units) do
		self:kill_effect(unit)

		if unit:name() == Idstring(self._environment_area_unit) then
			managers.environment_area:remove_area(unit:unit_data().environment_area)
		end
	end

	EnvironmentLayer.super.clear(self)
	self:set_environment_area_parameters()
end

-- Lines 953-955
function EnvironmentLayer:add_triggers()
	EnvironmentLayer.super.add_triggers(self)
end

-- Lines 957-959
function EnvironmentLayer:clear_triggers()
	self._editor_data.virtual_controller:clear_triggers()
end
