core:module("CoreInstancesLayer")
core:import("CoreStaticLayer")
core:import("CoreEditorUtils")
core:import("CoreInput")
core:import("CoreEws")
core:import("CoreTable")
core:import("CoreClass")
core:import("CoreWorldDefinition")

InstancesLayer = InstancesLayer or class(CoreStaticLayer.StaticLayer)

-- Lines 13-23
function InstancesLayer:init(owner)
	InstancesLayer.super.init(self, owner, "instances", {
		"nothing"
	}, "statics_layer")

	self._uses_continents = true
	self._stashed_instance_units = {}
	self._predefined_instances_file = "lib/utils/dev/editor/xml/predefined_instances"

	self:_load_predefined_instances()
	self:_create_overlay_gui()
end

-- Lines 25-30
function InstancesLayer:_load_predefined_instances()
	if DB:has("xml", self._predefined_instances_file) then
		local file = DB:open("xml", self._predefined_instances_file)
		self._predefined_instances = ScriptSerializer:from_generic_xml(file:read())
	end
end

-- Lines 32-38
function InstancesLayer:load(world_holder, offset)
	world_holder:create_world("world", self._save_name, offset)
	self:_update_instances_listbox()
	self:_update_overlay_gui()
end

-- Lines 40-65
function InstancesLayer:save(save_params)
	for _, data in ipairs(managers.world_instance:instance_save_data()) do
		local t = {
			entry = self._save_name,
			continent = data.continent,
			data = data
		}

		managers.editor:add_save_data(t)
	end
end

-- Lines 67-71
function InstancesLayer:clone_unit()
	if self:ctrl() then
		self:clone()
	end
end

-- Lines 73-79
function InstancesLayer:clone()
	if self._selected_instance then
		local data = self._selected_instance:data()
		local suggested_name = managers.world_instance:get_safe_name(nil, data.name)

		self:add_instance(suggested_name, data.folder, data.index_size, data.script, data.position, data.rotation, data.predef)
	end
end

-- Lines 81-87
function InstancesLayer:spawn_unit()
	self._wants_to_create = false

	if not self._grab and not self:condition() then
		self._wants_to_create = true

		self:do_spawn_unit(self._unit_name)
	end
end

-- Lines 89-91
function InstancesLayer:do_spawn_unit(name, pos, rot)
end

-- Lines 94-103
function InstancesLayer:get_preview_unit(name)
	name = name or self._selected_predefined_instance

	if not name then
		return
	end

	local preview_unit = self._predefined_instances[name].preview_unit or nil

	return preview_unit
end

-- Lines 105-112
function InstancesLayer:_mouse_create_instance()
	if not self._grab and not self:condition() and self._wants_to_create then
		self._wants_to_create = false

		self:_get_instance_info_from_user()
	end
end

-- Lines 114-136
function InstancesLayer:_get_instance_info_from_user()
	if not managers.worlddefinition then
		managers.editor:output_error("Instance cannot be placed in new level. Open a saved level first.")

		return
	end

	local predef = self._selected_predefined_instance

	if not predef then
		return
	end

	local script = self:_get_instance_script()

	if not script then
		return
	end

	local name = self:_get_name_from_user(predef)

	if name then
		local folder = self._predefined_instances[predef].folder
		local size = self._predefined_instances[predef].size

		self:add_instance(name, folder, size, script, nil, nil, predef)

		return
	end
end

-- Lines 138-157
function InstancesLayer:_get_instance_script()
	local continent = managers.editor:current_continent():name()
	local scripts = managers.editor:layer("Mission"):scripts_by_continent(continent)

	if #scripts < 1 then
		managers.editor:output_error("There are now mission scripts in continent '" .. continent .. "'. Create one first.")

		return
	end

	local script = scripts[1]

	if #scripts > 1 then
		local dialog = EWS:SingleChoiceDialog(Global.frame_panel, "Select which script the instance should be placed in:", "Scripts", scripts, "")

		dialog:show_modal()

		script = dialog:get_string_selection()

		if not script or script == "" then
			return nil
		end
	end

	return script
end

-- Lines 159-171
function InstancesLayer:_get_name_from_user(predef)
	local suggested_name = predef and managers.world_instance:get_safe_name(predef) or ""

	if predef then
		return suggested_name
	end

	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for the instance:", "Create instance", suggested_name, Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		if managers.world_instance:has_instance(name) then
			return self:_get_name_from_user()
		end

		return name
	end

	return nil
end

-- Lines 173-181
function InstancesLayer:use_grab_info()
	InstancesLayer.super.super.use_grab_info(self)

	if self._grab then
		self._grab = false

		self:set_instance_positions(self._grab_info:position())
		self:set_instance_rotations(self._grab_info:rotation() * self._selected_instance_data.rotation:inverse())
	end
end

-- Lines 183-192
function InstancesLayer:move_unit(btn, pressed)
	if self._selected_instance then
		self._grab = true
		self._grab_info = CoreEditorUtils.GrabInfo:new(nil, self._selected_instance_data.position, self._selected_instance_data.rotation)

		if not managers.editor:invert_move_shift() or managers.editor:invert_move_shift() and self:shift() then
			self._offset_move_vec = self._selected_instance_data.position - self._current_pos
		end
	end
end

-- Lines 194-222
function InstancesLayer:rotate_unit(btn, pressed)
	if self._selected_instance and not self:condition() then
		local rot_axis = nil
		local snap_axis = self:snap_rotation_axis()

		if self:local_rot() then
			if snap_axis == "x" then
				rot_axis = self._selected_instance_data.rotation:x()
			elseif snap_axis == "y" then
				rot_axis = self._selected_instance_data.rotation:y()
			elseif snap_axis == "z" then
				rot_axis = self._selected_instance_data.rotation:z()
			end
		elseif snap_axis == "x" then
			rot_axis = Vector3(1, 0, 0)
		elseif snap_axis == "y" then
			rot_axis = Vector3(0, 1, 0)
		elseif snap_axis == "z" then
			rot_axis = Vector3(0, 0, 1)
		end

		local step = self:snap_rotation()

		if self:shift() then
			step = -step
		end

		local rot = Rotation(rot_axis, step)

		self:set_instance_rotations(rot)
	end
end

-- Lines 224-233
function InstancesLayer:position_as()
	if self._selected_instance and not self:condition() then
		local data = {
			ray_type = "body editor",
			sample = true,
			mask = self._position_as_slot_mask
		}
		local ray = managers.editor:unit_by_raycast(data)

		if ray and ray.unit then
			self:set_instance_positions(ray.unit:position())
			self:set_instance_rotations(ray.unit:rotation() * self._selected_instance:data().rotation:inverse())
		end
	end
end

-- Lines 235-246
function InstancesLayer:click_select_unit()
	if self:condition() or self:grab() then
		return
	end

	managers.editor:click_select_unit(self)
end

-- Lines 248-271
function InstancesLayer:select_instance(instance_name)
	self._selected_instance = nil
	self._selected_instance_data = nil

	self._mission_placed_ctrlr:set_enabled(instance_name and true or false)
	self:_set_selection_instances_listbox(instance_name)

	if instance_name then
		self._selected_instance = Instance:new(managers.world_instance:get_instance_data_by_name(instance_name))
		self._selected_instance_data = managers.world_instance:get_instance_data_by_name(instance_name)

		managers.editor:set_grid_altitude(self._selected_instance:data().position.z)

		local instance_data = managers.world_instance:get_instance_data_by_name(instance_name)
		local continent_data = managers.editor:continents()[instance_data.continent]
		local start_index = continent_data:base_id() + managers.world_instance:start_offset_index() + instance_data.start_index

		self._instance_info_guis.start_index:set_label("" .. start_index)
		self._instance_info_guis.end_index:set_label("" .. start_index + instance_data.index_size)
		self._mission_placed_ctrlr:set_value(instance_data.mission_placed)
	else
		self._instance_info_guis.start_index:set_label("N/A")
		self._instance_info_guis.end_index:set_label("N/A")
	end

	self:update_unit_settings()
	self:_update_overlay_gui()
end

-- Lines 273-276
function InstancesLayer:set_select_unit(unit)
	self:select_instance(unit and unit:unit_data().instance or nil)
end

-- Lines 278-285
function InstancesLayer:release_unit()
	InstancesLayer.super.release_unit(self)
end

-- Lines 287-310
function InstancesLayer:get_instance_units_by_name(name)
	if self._stashed_instance_units[name] then
		return self._stashed_instance_units[name]
	end

	local layer_names = {
		"Statics",
		"Dynamics"
	}
	local t = {}

	for _, layer_name in ipairs(layer_names) do
		t[layer_name] = t[layer_name] or {}

		for _, unit in ipairs(managers.editor:layer(layer_name):created_units()) do
			if alive(unit) and unit:unit_data().instance and unit:unit_data().instance == name then
				table.insert(t[layer_name], unit)
			end
		end
	end

	self._stashed_instance_units[name] = t

	return t
end

-- Lines 312-345
function InstancesLayer:_delete_instance_by_name(name)
	managers.editor:freeze_gui_lists()

	if self._selected_instance and not self:condition() then
		local instance_units = self:get_instance_units_by_name(name)

		for name, units in pairs(instance_units) do
			for _, unit in ipairs(units) do
				managers.editor:layer(name):delete_unit(unit)
			end
		end

		for i, instance in ipairs(managers.world_instance:instance_data()) do
			if instance.name == name then
				table.remove(managers.world_instance:instance_data(), i)

				self._stashed_instance_units[name] = nil
				local mission_units = managers.editor:layer("Mission"):get_created_unit_by_pattern({
					"func_instance_input_event",
					"func_instance_output_event",
					"func_instance_point",
					"func_instance_set_params"
				})

				for _, mission_unit in ipairs(mission_units) do
					if mission_unit:mission_element().on_instance_deleted then
						mission_unit:mission_element():on_instance_deleted(name)
					end
				end

				if self._selected_instance:name() == name then
					self._selected_instance = nil
					self._selected_instance_data = nil
				end

				self:_update_instances_listbox()

				break
			end
		end
	end

	managers.editor:thaw_gui_lists()
	self:update_unit_settings()
	self:_update_overlay_gui()
end

-- Lines 347-351
function InstancesLayer:delete_selected_unit(btn, pressed)
	if self._selected_instance then
		self:_delete_instance_by_name(self._selected_instance:name())
	end
end

-- Lines 353-355
function InstancesLayer:reset_rotation()
end

-- Lines 357-397
function InstancesLayer:add_instance(name, folder, index_size, script, pos, rot, predef)
	folder = folder or "levels/tests/inst/world"
	continent = managers.editor:current_continent():name()
	script = script or "default"
	local instance = {
		continent = continent,
		folder = folder,
		name = name,
		position = pos or self._current_pos,
		rotation = rot or self._current_rot or Rotation(),
		script = script,
		index_size = index_size
	}
	instance.start_index = managers.world_instance:get_safe_start_index(instance.index_size, instance.continent)
	instance.predef = predef

	managers.world_instance:add_instance_data(instance)

	local continent_data = managers.editor:current_continent():values()
	local prepared_unit_data = managers.world_instance:prepare_unit_data(instance, continent_data)

	if prepared_unit_data.statics then
		for _, static in ipairs(prepared_unit_data.statics) do
			local unit = managers.worlddefinition:_create_statics_unit(static, Vector3())

			managers.editor:layer("Statics"):add_unit_to_created_units(unit)
		end
	end

	if prepared_unit_data.dynamics then
		for _, entry in ipairs(prepared_unit_data.dynamics) do
			local unit = managers.worlddefinition:_create_dynamics_unit(entry, Vector3())

			managers.editor:layer("Dynamics"):add_unit_to_created_units(unit)

			for i = 0, unit:num_bodies() - 1 do
				unit:body(i):set_keyframed(true)
				unit:set_keyframed(true)
			end
		end
	end

	self:_update_instances_listbox()
	self:select_instance(instance.name)
	self:_update_overlay_gui()
end

-- Lines 399-458
function InstancesLayer:update(t, dt)
	InstancesLayer.super.super.update(self, t, dt)

	for _, instance_data in ipairs(managers.world_instance:instances_data_by_continent(managers.editor:current_continent():name())) do
		local instance_units = self:get_instance_units_by_name(instance_data.name)

		if #instance_units == 0 then
			Application:draw_sphere(instance_data.position, 50, 0.5, 0.5, 0.5)
		end
	end

	if self._selected_instance then
		self:_draw_instance(t, dt, self._selected_instance:name())
	end

	if not self:condition() then
		if self._grab and self:shift() and not managers.editor:invert_move_shift() or not self:shift() and managers.editor:invert_move_shift() then
			self._offset_move_vec = Vector3(0, 0, 0)
		end

		local current_pos, current_rot = managers.editor:current_orientation(self._offset_move_vec, self._selected_unit)
		self._current_pos = current_pos or self._current_pos
		self._current_rot = current_rot

		if self._current_pos and self._grab then
			if self._selected_instance then
				self:set_instance_positions(self._current_pos)
			else
				self._grab = false
			end
		end

		if self._current_rot then
			if self._ctrl:down(Idstring("assign_suface_normal")) then
				self:set_unit_rotations(self._current_rot)
			end

			if self._grab then
				if self._ctrl:down(Idstring("surface_move_align_normal")) then
					self:set_unit_rotations(self._current_rot)
				end

				if self:use_snappoints() then
					self:set_unit_rotations(self._current_rot)
				end
			end
		end

		self:draw_marker(t, dt)
		self:draw_grid(t, dt)
	end

	self:update_move_triggers(t, dt)
	self:update_rotate_triggers(t, dt)
end

-- Lines 461-490
function InstancesLayer:update_move_triggers(t, dt)
	if not self._selected_instance or not self._editor_data.keyboard_available or self:condition() then
		return
	end

	if not self._move_unit_rep:update(d, dt) or CoreInput.shift() then
		return
	end

	local mov_vec = nil
	local u_rot = self._selected_instance_data.rotation

	if self._ctrl:down(Idstring("move_forward")) then
		mov_vec = self:local_rot() and u_rot:y() or Vector3(0, 1, 0)
	elseif self._ctrl:down(Idstring("move_back")) then
		mov_vec = self:local_rot() and u_rot:y() * -1 or Vector3(0, 1, 0) * -1
	elseif self._ctrl:down(Idstring("move_left")) then
		mov_vec = self:local_rot() and u_rot:x() * -1 or Vector3(1, 0, 0) * -1
	elseif self._ctrl:down(Idstring("move_right")) then
		mov_vec = self:local_rot() and u_rot:x() or Vector3(1, 0, 0)
	elseif self._ctrl:down(Idstring("move_up")) then
		mov_vec = self:local_rot() and u_rot:z() or Vector3(0, 0, 1)
	elseif self._ctrl:down(Idstring("move_down")) then
		mov_vec = self:local_rot() and u_rot:z() * -1 or Vector3(0, 0, 1) * -1
	end

	if mov_vec then
		self:set_instance_positions(self._selected_instance_data.position + mov_vec * self:grid_size())
	end
end

-- Lines 493-524
function InstancesLayer:update_rotate_triggers(t, dt)
	if not self._selected_instance or not self._editor_data.keyboard_available or self:condition() then
		return
	end

	local rot_speed = self:rotation_speed() * dt

	if self:shift() then
		rot_speed = rot_speed / 2
	end

	local rot_axis = nil
	local u_rot = self._selected_instance_data.rotation

	if self._ctrl:down(Idstring("roll_left")) then
		rot_axis = self:local_rot() and u_rot:z() or Vector3(0, 0, 1)
	elseif self._ctrl:down(Idstring("roll_right")) then
		rot_axis = (self:local_rot() and u_rot:z() or Vector3(0, 0, 1)) * -1
	elseif self._ctrl:down(Idstring("pitch_right")) then
		rot_axis = self:local_rot() and u_rot:y() or Vector3(0, 1, 0)
	elseif self._ctrl:down(Idstring("pitch_left")) then
		rot_axis = (self:local_rot() and u_rot:y() or Vector3(0, 1, 0)) * -1
	elseif self._ctrl:down(Idstring("yaw_backward")) then
		rot_axis = self:local_rot() and u_rot:x() or Vector3(1, 0, 0)
	elseif self._ctrl:down(Idstring("yaw_forward")) then
		rot_axis = (self:local_rot() and u_rot:x() or Vector3(1, 0, 0)) * -1
	end

	if rot_axis then
		local rot = Rotation(rot_axis, rot_speed)

		self:set_instance_rotations(rot)
	end
end

-- Lines 526-528
function InstancesLayer:external_draw_instance(t, dt, instance_name, r, g, b)
	self:_draw_instance(t, dt, instance_name, r, g, b)
end

-- Lines 530-574
function InstancesLayer:_draw_instance(t, dt, instance_name, r, g, b)
	r = r or 1
	g = g or 1
	b = b or 1
	local unit_brush = Draw:brush(Color(0.15, r, g, b))
	local instance_units = self:get_instance_units_by_name(instance_name)

	for name, units in pairs(instance_units) do
		for _, unit in ipairs(units) do
			if alive(unit) and unit:unit_data().instance and unit:unit_data().instance == instance_name then
				Application:draw(unit, r, g, b)
				unit_brush:unit(unit)
			end
		end
	end

	if #instance_units == 0 then
		local instance_data = managers.world_instance:get_instance_data_by_name(instance_name)

		unit_brush:sphere(instance_data.position, 50, 2)
		Application:draw_sphere(instance_data.position, 50, r, g, b)
	end

	local name_brush = Draw:brush(Color(0.3, 1, 0.5))

	name_brush:set_font(Idstring("core/fonts/diesel"), 8)
	name_brush:set_render_template(Idstring("OverlayVertexColorTextured"))

	for _, element in pairs(managers.world_instance:prepare_mission_data_by_name(instance_name).default.elements) do
		unit_brush:set_color(Color(1, r, g, b))

		if element.values.position then
			unit_brush:sphere(element.values.position, 2, 2)

			if managers.viewport:get_current_camera() then
				local cam_up = managers.viewport:get_current_camera():rotation():z()
				local cam_right = managers.viewport:get_current_camera():rotation():x()

				name_brush:center_text(element.values.position + Vector3(0, 0, 25), utf8.from_latin1(element.editor_name), cam_right, -cam_up)
			end

			if element.values.rotation then
				local rotation = CoreClass.type_name(element.values.rotation) == "Rotation" and element.values.rotation or Rotation(element.values.rotation, 0, 0)

				unit_brush:set_color(Color(0.15, 1, 0, 0))
				unit_brush:cylinder(element.values.position, element.values.position + rotation:x() * 20, 1)
				unit_brush:set_color(Color(0.15, 0, 1, 0))
				unit_brush:cylinder(element.values.position, element.values.position + rotation:y() * 20, 1)
				unit_brush:set_color(Color(0.15, 0, 0, 1))
				unit_brush:cylinder(element.values.position, element.values.position + rotation:z() * 20, 1)
			end
		end
	end
end

-- Lines 576-587
function InstancesLayer:draw_rotation(t, dt)
end

-- Lines 589-611
function InstancesLayer:draw_units(t, dt)
end

-- Lines 613-615
function InstancesLayer:widget_affect_object()
	return self._selected_instance
end

-- Lines 617-619
function InstancesLayer:use_widget_position(pos)
	self:set_instance_positions(pos)
end

-- Lines 621-623
function InstancesLayer:use_widget_rotation(rot)
	self:set_instance_rotations(rot * self:widget_affect_object():rotation():inverse())
end

-- Lines 625-627
function InstancesLayer:set_unit_positions(pos)
	self:set_instance_positions(pos)
end

-- Lines 629-631
function InstancesLayer:set_unit_rotations(rot)
	self:set_instance_rotations(rot)
end

-- Lines 633-646
function InstancesLayer:set_instance_positions(pos)
	for name, units in pairs(self:get_instance_units_by_name(self._selected_instance:name())) do
		for _, unit in ipairs(units) do
			self:recalc_locals(unit, Reference:new(self._selected_instance_data.position, self._selected_instance_data.rotation))
			managers.editor:layer("Statics"):set_unit_position(unit, pos, self._selected_instance_data.rotation)
		end
	end

	self._selected_instance_data.position = pos
end

-- Lines 648-664
function InstancesLayer:set_instance_rotations(rot)
	local rot = rot * self._selected_instance_data.rotation

	for name, units in pairs(self:get_instance_units_by_name(self._selected_instance:name())) do
		for _, unit in ipairs(units) do
			self:recalc_locals(unit, Reference:new(self._selected_instance_data.position, self._selected_instance_data.rotation))
			managers.editor:layer("Statics"):set_unit_position(unit, self._selected_instance_data.position, rot)
			managers.editor:layer("Statics"):set_unit_rotation(unit, rot)
		end
	end

	self._selected_instance_data.rotation = rot
end

-- Lines 666-767
function InstancesLayer:build_panel(notebook, settings)
	InstancesLayer.super.super.build_panel(self, notebook)
	cat_print("editor", "InstancesLayer:build_panel")

	self._ews_panel = EWS:ScrolledWindow(notebook, "", "VSCROLL")

	self._ews_panel:set_scroll_rate(Vector3(0, 1, 0))
	self._ews_panel:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))

	self._main_sizer = EWS:BoxSizer("VERTICAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")

	self._main_sizer:add(self._sizer, 1, 0, "EXPAND")

	local instances_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Instances")

	self._sizer:add(instances_sizer, 3, 0, "EXPAND")

	local toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("OPEN", "Open world file", CoreEws.image_path("folder_open_16x16.png"), "Open selected instance world")
	toolbar:connect("OPEN", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_open_selected_instance_path"), nil)
	toolbar:add_tool("RENAME", "Rename instance", CoreEws.image_path("toolbar\\rename2_16x16.png"), "Rename instance")
	toolbar:connect("RENAME", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_rename_instance"), nil)
	toolbar:add_tool("DELETE", "Delete instance", CoreEws.image_path("toolbar\\delete_16x16.png"), "Delete instance")
	toolbar:connect("DELETE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_delete_instance"), nil)
	toolbar:realize()
	instances_sizer:add(toolbar, 0, 1, "EXPAND,BOTTOM")

	self._instances_listbox = EWS:ListBox(self._ews_panel, "instances_layer_instances", "LB_SINGLE,LB_HSCROLL,LB_NEEDED_SB,LB_SORT")

	instances_sizer:add(self._instances_listbox, 1, 0, "EXPAND")
	self._instances_listbox:connect("EVT_COMMAND_LISTBOX_SELECTED", callback(self, self, "_on_gui_select_instance"), self._instances_listbox)

	self._mission_placed_ctrlr = EWS:CheckBox(self._ews_panel, "Mission placed", "", "ALIGN_LEFT")

	self._mission_placed_ctrlr:set_value(false)
	self._mission_placed_ctrlr:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "_on_gui_mission_placed"), nil)
	instances_sizer:add(self._mission_placed_ctrlr, 0, 0, "EXPAND")

	self._instance_info_guis = {}

	-- Lines 713-720
	local function _info(name)
		local text_sizer = EWS:BoxSizer("HORIZONTAL")

		instances_sizer:add(text_sizer, 0, 0, "EXPAND")
		text_sizer:add(EWS:StaticText(self._ews_panel, string.pretty(name, true) .. ": ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

		self._instance_info_guis[name] = EWS:StaticText(self._ews_panel, "", "", "")

		text_sizer:add(self._instance_info_guis[name], 2, 2, "RIGHT,TOP,EXPAND")
	end

	_info("start_index")
	_info("end_index")

	local predefined_instances_sizer = EWS:StaticBoxSizer(self._ews_panel, "VERTICAL", "Predefined instances")

	self._sizer:add(predefined_instances_sizer, 4, 0, "EXPAND")
	predefined_instances_sizer:add(self:_build_predefined_instances_notebook(), 1, 0, "EXPAND")

	self._predefined_instances_info_guis = {}

	-- Lines 732-739
	local function _info(name)
		local text_sizer = EWS:BoxSizer("HORIZONTAL")

		predefined_instances_sizer:add(text_sizer, 0, 0, "EXPAND")
		text_sizer:add(EWS:StaticText(self._ews_panel, string.pretty(name, true) .. ": ", "", ""), 1, 2, "ALIGN_CENTER_VERTICAL,RIGHT,EXPAND")

		self._predefined_instances_info_guis[name] = EWS:StaticText(self._ews_panel, "", "", "")

		text_sizer:add(self._predefined_instances_info_guis[name], 2, 2, "RIGHT,TOP,EXPAND")
	end

	_info("folder")
	_info("size")
	_info("actual_size")
	_info("highest_id")
	_info("mission_elements")
	_info("statics")
	_info("dynamics")

	local pi_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER,ALIGN_BOTTOM")

	pi_toolbar:add_tool("TB_OPEN_INSTANCE_WORLD", "Open world file", CoreEws.image_path("folder_open_16x16.png"), "Open predefined instance world")
	pi_toolbar:connect("TB_OPEN_INSTANCE_WORLD", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_open_instance_path"), nil)
	pi_toolbar:add_tool("TB_OPEN_PREDEFINED_INSTANCES_FILE", "Open predefined instances file", CoreEws.image_path("document_16x16.png"), "Open predefined instances file")
	pi_toolbar:connect("TB_OPEN_PREDEFINED_INSTANCES_FILE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_open_predefined_instances_file"), nil)
	pi_toolbar:add_tool("TB_OPEN_RELOAD_PREDEFINED_INSTANCES_FILE", "Reload predefined instances file", CoreEws.image_path("toolbar\\refresh_16x16.png"), "Reload predefined instances file")
	pi_toolbar:connect("TB_OPEN_RELOAD_PREDEFINED_INSTANCES_FILE", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_reload_predefined_instances_file"), nil)
	pi_toolbar:realize()
	predefined_instances_sizer:add(pi_toolbar, 0, 1, "EXPAND,BOTTOM")

	local help = EWS:TextCtrl(self._ews_panel, "Predefined instances can be added in " .. self._predefined_instances_file .. ".xml.", 0, "TE_MULTILINE,TE_READONLY,TE_WORDWRAP,TE_CENTRE")

	self._sizer:add(help, 0, 0, "EXPAND")

	return self._ews_panel
end

-- Lines 769-779
function InstancesLayer:_build_predefined_instances_notebook()
	local notebook_sizer = EWS:BoxSizer("VERTICAL")
	self._predefined_instances_notebook = EWS:Notebook(self._ews_panel, "", "NB_TOP,NB_MULTILINE")

	self._predefined_instances_notebook:connect("EVT_COMMAND_NOTEBOOK_PAGE_CHANGING", callback(self, self, "_on_gui_instances_page_changed"), nil)
	notebook_sizer:add(self._predefined_instances_notebook, 1, 0, "EXPAND")
	self:_add_predefined_instances_notebook_pages()

	return notebook_sizer
end

-- Lines 781-821
function InstancesLayer:_add_predefined_instances_notebook_pages()
	local style = "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING,LC_SINGLE_SEL"
	self._predefined_instances_notebook_lists = {}
	local predefined_data_by_category = self:_predefined_data_by_category()

	for c, names in pairs(predefined_data_by_category) do
		local panel = EWS:Panel(self._predefined_instances_notebook, "", "TAB_TRAVERSAL")
		local instance_sizer = EWS:BoxSizer("VERTICAL")

		panel:set_sizer(instance_sizer)
		instance_sizer:add(EWS:StaticText(panel, "Filter", 0, ""), 0, 0, "ALIGN_CENTER_HORIZONTAL")

		local instance_filter = EWS:TextCtrl(panel, "", "", "TE_CENTRE")

		instance_sizer:add(instance_filter, 0, 0, "EXPAND")

		local instances = EWS:ListCtrl(panel, "", style)

		instances:clear_all()
		instances:append_column("Name")

		for _, name in ipairs(names) do
			local i = instances:append_item(name)

			instances:set_item_data(i, name)
		end

		instances:autosize_column(0)
		instance_sizer:add(instances, 1, 0, "EXPAND")
		instances:connect("EVT_COMMAND_LIST_ITEM_SELECTED", callback(self, self, "_on_gui_select_predefined_instance"), instances)
		instance_filter:connect("EVT_COMMAND_TEXT_UPDATED", callback(self, self, "_on_gui_instances_update_filter"), {
			filter = instance_filter,
			instances = instances,
			category = c
		})

		local page_name = c
		self._predefined_instances_notebook_lists[page_name] = {
			instances = instances,
			filter = instance_filter
		}

		self._predefined_instances_notebook:add_page(panel, page_name, page_name == "ALL")
	end
end

-- Lines 823-828
function InstancesLayer:_clear_predefined_instances_notebook()
	self._predefined_instances_notebook_lists = {}

	while self._predefined_instances_notebook:get_page_count() > 0 do
		self._predefined_instances_notebook:delete_page(self._predefined_instances_notebook:get_page_count() - 1)
	end
end

-- Lines 830-839
function InstancesLayer:_predefined_data_by_category()
	local t = {
		ALL = {}
	}

	for name, data in pairs(self._predefined_instances) do
		local category = data.category or "N/A"
		t[category] = t[category] or {}

		table.insert(t[category], name)
		table.insert(t.ALL, name)
	end

	return t
end

-- Lines 842-848
function InstancesLayer:_on_gui_instances_page_changed()
	for _, data in pairs(self._predefined_instances_notebook_lists) do
		for _, item in ipairs(data.instances:selected_items()) do
			data.instances:set_item_selected(item, false)
		end
	end
end

-- Lines 851-864
function InstancesLayer:_on_gui_instances_update_filter(data)
	local filter = data.filter:get_value()

	data.instances:delete_all_items()

	local instances_names = self:_predefined_data_by_category()[data.category]

	for _, name in ipairs(instances_names) do
		if string.find(name, filter, 1, true) then
			local i = data.instances:append_item(name)

			data.instances:set_item_data(i, name)
		end
	end

	data.instances:autosize_column(0)
end

-- Lines 866-869
function InstancesLayer:_on_gui_new_instance()
	self:_get_instance_info_from_user()
end

-- Lines 871-877
function InstancesLayer:_on_gui_open_selected_instance_path()
	local name = self:_get_selection_instances_listbox()

	if name then
		local instance_data = managers.world_instance:get_instance_data_by_name(name)

		self:_open_instance_path(instance_data.folder)
	end
end

-- Lines 879-909
function InstancesLayer:_on_gui_rename_instance()
	local name = self:_get_selection_instances_listbox()

	if name then
		local new_name = self:_get_name_from_user()

		if new_name then
			local instance_units = self:get_instance_units_by_name(name)
			self._stashed_instance_units[name] = nil

			managers.world_instance:rename_instance(name, new_name)

			for name, units in pairs(instance_units) do
				for _, unit in ipairs(units) do
					unit:unit_data().instance = new_name
				end
			end

			local mission_units = managers.editor:layer("Mission"):get_created_unit_by_pattern({
				"func_instance_input_event",
				"func_instance_output_event",
				"func_instance_point",
				"func_instance_set_params"
			})

			for _, mission_unit in ipairs(mission_units) do
				if mission_unit:mission_element().on_instance_changed_name then
					mission_unit:mission_element():on_instance_changed_name(name, new_name)
				elseif mission_unit:mission_element_data().instance == name then
					mission_unit:mission_element():external_change_instance(new_name)
				end
			end

			self:_update_instances_listbox()
			self:_set_selection_instances_listbox(new_name)
		end
	end
end

-- Lines 911-916
function InstancesLayer:_on_gui_delete_instance()
	local name = self:_get_selection_instances_listbox()

	if name then
		self:_delete_instance_by_name(name)
	end
end

-- Lines 918-923
function InstancesLayer:_on_gui_mission_placed()
	local name = self:_get_selection_instances_listbox()

	if name then
		managers.world_instance:get_instance_data_by_name(name).mission_placed = self._mission_placed_ctrlr:get_value() and true or nil
	end
end

-- Lines 925-928
function InstancesLayer:_on_gui_select_predefined_instance(predefined_instances_list_box)
	local name = self:_get_selection_predefined_instances_listbox(predefined_instances_list_box)

	self:_set_selected_predefined_instance(name)
end

-- Lines 930-968
function InstancesLayer:_set_selected_predefined_instance(name)
	self._selected_predefined_instance = name

	if not name then
		self._predefined_instances_info_guis.folder:set_label("")
		self._predefined_instances_info_guis.size:set_label("")
		self._predefined_instances_info_guis.actual_size:set_label("")
		self._predefined_instances_info_guis.mission_elements:set_label("")
		self._predefined_instances_info_guis.statics:set_label("")
		self._predefined_instances_info_guis.dynamics:set_label("")
		self._predefined_instances_info_guis.highest_id:set_label("")

		return
	end

	local folder = self._predefined_instances[name].folder
	local size = self._predefined_instances[name].size
	local id, amount, type_amount = managers.world_instance:check_highest_id({
		folder = folder
	})

	self._predefined_instances_info_guis.folder:set_label(folder)
	self._predefined_instances_info_guis.size:set_label("" .. size)
	self._predefined_instances_info_guis.actual_size:set_label("" .. amount)
	self._predefined_instances_info_guis.mission_elements:set_label("" .. type_amount.mission)
	self._predefined_instances_info_guis.statics:set_label("" .. type_amount.statics)
	self._predefined_instances_info_guis.dynamics:set_label("" .. type_amount.dynamics)
	self._predefined_instances_info_guis.highest_id:set_label("" .. id)

	if size < amount then
		local message = "Actual size (" .. amount .. ") of instance \"" .. name .. "\" is higher than size in predefined instances xml (" .. size .. "). It will not be allowed to be placed. Any previously placed instances needs to be looked over and replaced if needed."

		EWS:message_box(Global.frame_panel, message, "Instances", "OK,ICON_ERROR", Vector3(-1, -1, 0))
		self:_set_selected_predefined_instance(nil)

		return
	end

	if size < id then
		local message = "Highest id (" .. id .. ") of instance \"" .. name .. "\" is higher than size in predefined instances xml (" .. size .. "). It will not be allowed to be placed. Any previously placed instances needs to be looked over and replaced if needed."

		EWS:message_box(Global.frame_panel, message, "Instances", "OK,ICON_ERROR", Vector3(-1, -1, 0))
		self:_set_selected_predefined_instance(nil)
	end
end

-- Lines 970-977
function InstancesLayer:_get_selection_predefined_instances_listbox(predefined_instances_list_box)
	predefined_instances_list_box = predefined_instances_list_box or self._predefined_instances_listbox
	local i = predefined_instances_list_box:selected_item()

	if i > -1 then
		return predefined_instances_list_box:get_item(i, 0)
	end

	return nil
end

-- Lines 979-985
function InstancesLayer:_on_gui_select_instance()
	local i = self._instances_listbox:selected_index()

	if i > -1 then
		local name = self._instances_listbox:get_string(i)

		self:select_instance(name)
	end
end

-- Lines 987-993
function InstancesLayer:_get_selection_instances_listbox()
	local i = self._instances_listbox:selected_index()

	if i > -1 then
		return self._instances_listbox:get_string(i)
	end

	return nil
end

-- Lines 995-1000
function InstancesLayer:_update_instances_listbox()
	self._instances_listbox:clear()

	for _, name in ipairs(managers.world_instance:instance_names(managers.editor:current_continent():name())) do
		self._instances_listbox:append(name)
	end
end

-- Lines 1002-1015
function InstancesLayer:_set_selection_instances_listbox(name)
	if not name then
		local i = self._instances_listbox:selected_index()

		if i > -1 then
			self._instances_listbox:deselect_index(i)
		end

		return
	end

	for i = 0, self._instances_listbox:nr_items() - 1 do
		if name == self._instances_listbox:get_string(i) then
			self._instances_listbox:select_index(i)
		end
	end
end

-- Lines 1017-1026
function InstancesLayer:_on_gui_open_instance_path(name)
	name = name or self._selected_predefined_instance

	if not name then
		return
	end

	local folder = self._predefined_instances[name].folder

	self:_open_instance_path(folder)
end

-- Lines 1028-1038
function InstancesLayer:_open_instance_path(folder)
	if managers.editor:confirm_on_new() then
		return
	end

	local reverse = string.reverse(folder)
	local i = string.find(reverse, "/")
	local p_folder = string.reverse(string.sub(reverse, i + 1))
	local abs_folder = managers.database:entry_expanded_directory(p_folder)
	local abs_file = abs_folder .. "\\world.world"

	managers.editor:load_level(abs_folder, abs_file)
end

-- Lines 1040-1042
function InstancesLayer:_on_gui_open_predefined_instances_file()
	os.execute("start " .. managers.database:entry_expanded_directory(self._predefined_instances_file .. ".xml"))
end

-- Lines 1044-1068
function InstancesLayer:_on_gui_reload_predefined_instances_file()
	local t = {
		target_db_name = "all",
		send_idstrings = false,
		preprocessor_definitions = "preprocessor_definitions",
		verbose = false,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:base_path(),
		target_db_root = Application:base_path() .. "assets",
		source_files = {
			self._predefined_instances_file .. ".xml"
		}
	}

	Application:data_compile(t)
	DB:reload()
	self:_load_predefined_instances()

	local current_page_index = CoreEws.get_notebook_current_page_index(self._predefined_instances_notebook)

	self._predefined_instances_notebook:freeze()
	self:_clear_predefined_instances_notebook()
	self:_add_predefined_instances_notebook_pages()
	self._predefined_instances_notebook:thaw()
	self._predefined_instances_notebook:set_page(math.min(current_page_index, self._predefined_instances_notebook:get_page_count() - 1))
end

-- Lines 1070-1076
function InstancesLayer:on_continent_changed(...)
	InstancesLayer.super.on_continent_changed(self, ...)
	self:select_instance(nil)
	self:_update_instances_listbox()
	self:_update_overlay_gui()
end

-- Lines 1078-1090
function InstancesLayer:on_hide_selected()
	if not self._selected_instance then
		return
	end

	for name, units in pairs(self:get_instance_units_by_name(self._selected_instance:name())) do
		for _, unit in ipairs(units) do
			managers.editor:set_unit_visible(unit, false)
		end
	end

	self:select_instance(nil)
end

-- Lines 1092-1100
function InstancesLayer:_create_overlay_gui()
	if self._workspace then
		Overlay:newgui():destroy_workspace(self._workspace)
	end

	self._workspace = Overlay:newgui():create_screen_workspace(0, 0, 1, 1)

	self._workspace:hide()

	self._gui_panel = self._workspace:panel():panel({
		halign = "scale",
		valign = "scale",
		h = 16,
		y = self._workspace:panel():h() - 16
	})
end

-- Lines 1102-1125
function InstancesLayer:_update_overlay_gui()
	self._gui_panel:clear()
	self._gui_panel:rect({
		valign = "scale",
		halign = "scale",
		color = Color.black
	})

	local instance_data = self._selected_instance and self._selected_instance:data()
	local tot_w = self._workspace:panel():w()
	local tot_indices = 70000
	local start_indices, end_indices = managers.world_instance:get_used_indices(managers.editor:current_continent():name())

	for i, start_index in ipairs(start_indices) do
		local x = start_index * tot_w / tot_indices
		local w = end_indices[i] * tot_w / tot_indices - x

		self._gui_panel:rect({
			layer = 2,
			x = x,
			w = w,
			color = Color.green
		})
	end

	if instance_data then
		local x = instance_data.start_index * tot_w / tot_indices
		local w = instance_data.index_size * tot_w / tot_indices

		self._gui_panel:rect({
			layer = 3,
			x = x,
			w = w,
			color = Color.blue
		})
	end
end

-- Lines 1151-1163
function InstancesLayer:on_simulation_started()
	for _, instance_data in ipairs(managers.world_instance:instance_data()) do
		if instance_data.mission_placed then
			local instance_units = self:get_instance_units_by_name(instance_data.name)

			for name, units in pairs(instance_units) do
				for _, unit in ipairs(units) do
					managers.editor:layer(name):delete_unit(unit)
				end
			end

			self._stashed_instance_units[instance_data.name] = nil
		end
	end
end

-- Lines 1165-1168
function InstancesLayer:update_unit_settings(...)
	InstancesLayer.super.update_unit_settings(self, ...)
	managers.editor:on_reference_unit(self._selected_instance)
end

-- Lines 1170-1175
function InstancesLayer:activate()
	InstancesLayer.super.activate(self)

	if self._workspace then
		self._workspace:show()
	end
end

-- Lines 1177-1183
function InstancesLayer:deactivate()
	self._stashed_instance_units = {}

	InstancesLayer.super.deactivate(self)

	if self._workspace then
		self._workspace:hide()
	end
end

-- Lines 1185-1190
function InstancesLayer:add_triggers()
	local vc = self._editor_data.virtual_controller

	vc:add_release_trigger(Idstring("rmb"), callback(self, self, "_mouse_create_instance"))
	InstancesLayer.super.add_triggers(self)
end

-- Lines 1192-1194
function InstancesLayer:selected_amount_string()
	return "Selected " .. self._save_name .. ": " .. (self._selected_instance and 1 or 0)
end

-- Lines 1196-1207
function InstancesLayer:clear()
	self._stashed_instance_units = {}
	self._selected_instance = nil

	managers.world_instance:clear()
	self:_update_instances_listbox()
	self:_update_overlay_gui()
	InstancesLayer.super.clear(self)
end

Reference = Reference or class()

-- Lines 1210-1213
function Reference:init(pos, rot)
	self._pos = pos
	self._rot = rot
end

-- Lines 1214-1216
function Reference:position()
	return self._pos
end

-- Lines 1217-1219
function Reference:rotation()
	return self._rot
end

Instance = Instance or class()

-- Lines 1222-1224
function Instance:init(data)
	self._data = data
end

-- Lines 1225-1227
function Instance:name()
	return self._data.name
end

-- Lines 1228-1230
function Instance:alive()
	return true
end

-- Lines 1231-1233
function Instance:data()
	return self._data
end

-- Lines 1234-1236
function Instance:position()
	return self._data.position or Vector3()
end

-- Lines 1237-1239
function Instance:rotation()
	return self._data.rotation or Rotation()
end
