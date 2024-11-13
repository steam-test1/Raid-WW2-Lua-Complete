core:import("CoreEditorUtils")
core:import("CoreEws")

EditUnitSettings = EditUnitSettings or class(EditUnitBase)

function EditUnitSettings:init(editor)
	local panel, sizer = (editor or managers.editor):add_unit_edit_page({
		name = "Settings",
		class = nil,
		class = self
	})
	self._ctrls = {}
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")
	local settings_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Core")
	local cutscene_actor_sizer = EWS:BoxSizer("HORIZONTAL")

	cutscene_actor_sizer:add(EWS:StaticText(panel, "Cutscene Actor:", 0, ""), 1, 0, "ALIGN_CENTER_VERTICAL")

	local cutscene_actor_name = EWS:StaticText(panel, "", 0, "ALIGN_CENTRE,ST_NO_AUTORESIZE")

	cutscene_actor_sizer:add(cutscene_actor_name, 2, 0, "ALIGN_CENTER_VERTICAL")

	local cutscene_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	cutscene_toolbar:add_tool("US_ADD_CUTSCENE_ACTOR", "Add this unit as an actor.", CoreEws.image_path("plus_16x16.png"), "Add this unit as an actor.")
	cutscene_toolbar:connect("US_ADD_CUTSCENE_ACTOR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_cutscene_actor"), nil)
	cutscene_toolbar:add_tool("US_REMOVE_CUTSCENE_ACTOR", "Remove this unit as an actor.", CoreEws.image_path("toolbar\\delete_16x16.png"), "Add this unit as an actor.")
	cutscene_toolbar:connect("US_REMOVE_CUTSCENE_ACTOR", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_cutscene_actor"), nil)
	cutscene_toolbar:realize()
	cutscene_actor_sizer:add(cutscene_toolbar, 0, 0, "EXPAND")
	settings_sizer:add(cutscene_actor_sizer, 0, 5, "EXPAND,BOTTOM")

	local disable_shadows = EWS:CheckBox(panel, "Disable Shadows", "")

	disable_shadows:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_disable_shadows"), nil)
	settings_sizer:add(disable_shadows, 1, 5, "EXPAND,BOTTOM")

	local hide_on_projection_light = EWS:CheckBox(panel, "Hide On Projection Light", "")

	hide_on_projection_light:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_hide_on_projection_light"), nil)
	settings_sizer:add(hide_on_projection_light, 1, 5, "EXPAND,BOTTOM")

	local disable_on_ai_graph = EWS:CheckBox(panel, "Disable On AI Graph", "")

	disable_on_ai_graph:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_disable_on_ai_graph"), nil)
	settings_sizer:add(disable_on_ai_graph, 1, 5, "EXPAND,BOTTOM")
	horizontal_sizer:add(settings_sizer, 0, 0, "ALIGN_LEFT")
	self:_create_physics_simulation(panel, horizontal_sizer)
	sizer:add(horizontal_sizer, 1, 2, "ALIGN_LEFT,EXPAND,ALL")

	self._ctrls.cutscene_actor_name = cutscene_actor_name
	self._ctrls.cutscene_actor_toolbar = cutscene_toolbar
	self._ctrls.disable_shadows = disable_shadows
	self._ctrls.hide_on_projection_light = hide_on_projection_light
	self._ctrls.disable_on_ai_graph = disable_on_ai_graph

	panel:layout()
	panel:set_enabled(false)

	self._panel = panel
end

function EditUnitSettings:_create_physics_simulation(panel, sizer)
	local physics_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Physics simulation")
	local buttons_sizer = EWS:BoxSizer("HORIZONTAL")
	local simulation_button = EWS:Button(panel, "Toggle Simulation", "")

	simulation_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "toggle_physics_simulation"), "")
	buttons_sizer:add(simulation_button, 1, 0, "EXPAND")

	local reset_button = EWS:Button(panel, "Reset", "")

	reset_button:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "stop_physics_simulation", true), "")
	reset_button:set_enabled(false)
	buttons_sizer:add(reset_button, 1, 0, "EXPAND")
	physics_sizer:add(buttons_sizer, 0, 1, "EXPAND")

	self._default_gravity = World:gravity()
	local gravity_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Simulation Gravity")
	local gravity_x = EWS:TextCtrl(panel, self._default_gravity.x, "", "TE_PROCESS_ENTER")

	gravity_x:set_min_size(gravity_x:get_min_size():with_x(65))
	gravity_x:connect("EVT_CHAR", callback(nil, _G, "verify_number"), gravity_x)

	local gravity_y = EWS:TextCtrl(panel, self._default_gravity.y, "", "TE_PROCESS_ENTER")

	gravity_y:set_min_size(gravity_y:get_min_size():with_x(65))
	gravity_y:connect("EVT_CHAR", callback(nil, _G, "verify_number"), gravity_y)

	local gravity_z = EWS:TextCtrl(panel, self._default_gravity.z, "", "TE_PROCESS_ENTER")

	gravity_z:set_min_size(gravity_z:get_min_size():with_x(65))
	gravity_z:connect("EVT_CHAR", callback(nil, _G, "verify_number"), gravity_z)
	gravity_sizer:add(EWS:StaticText(panel, "X", 0, "ALIGN_CENTER"), 0, 2, "ALIGN_CENTER_VERTICAL,ALL")
	gravity_sizer:add(gravity_x, 2, 0, "EXPAND")
	gravity_sizer:add(EWS:StaticText(panel, "Y", 0, "ALIGN_CENTER"), 0, 2, "ALIGN_CENTER_VERTICAL,ALL")
	gravity_sizer:add(gravity_y, 2, 0, "EXPAND")
	gravity_sizer:add(EWS:StaticText(panel, "Z", 0, "ALIGN_CENTER"), 0, 2, "ALIGN_CENTER_VERTICAL,ALL")
	gravity_sizer:add(gravity_z, 2, 0, "EXPAND")

	local reset_gravity = EWS:BitmapButton(panel, CoreEws.image_path("toolbar\\refresh_16x16.png"), "", "NO_BORDER")

	reset_gravity:set_tool_tip("Reset simulation gravity")
	reset_gravity:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "on_reset_gravity"), nil)
	gravity_sizer:add(reset_gravity, 0, 0, "EXPAND")
	physics_sizer:add(gravity_sizer, 1, 2, "EXPAND,ALIGN_CENTER,ALL")

	local physics_status = EWS:TextCtrl(panel, "Simulation Inactive", 0, "TE_NOHIDESEL,TE_RICH2,TE_DONTWRAP,TE_READONLY,TE_CENTRE")

	physics_sizer:add(physics_status, 0, 2, "EXPAND,ALIGN_CENTER")
	sizer:add(physics_sizer, 1, 2, "ALIGN_LEFT,ALL")

	self._ctrls.physics_reset = reset_button
	self._ctrls.physics_status = physics_status
	self._ctrls.physics_gravity_x = gravity_x
	self._ctrls.physics_gravity_y = gravity_y
	self._ctrls.physics_gravity_z = gravity_z
end

function EditUnitSettings:add_cutscene_actor()
	local name = EWS:get_text_from_user(Global.frame_panel, "Enter name for cutscene actor:", "Add cutscene actor", "", Vector3(-1, -1, 0), true)

	if name and name ~= "" then
		self._ctrls.unit:unit_data().cutscene_actor = name

		if managers.cutscene:register_cutscene_actor(self._ctrls.unit) then
			self._ctrls.cutscene_actor_name:set_value(name)
			self._ctrls.cutscene_actor_toolbar:set_tool_enabled("US_REMOVE_CUTSCENE_ACTOR", true)
		else
			self._ctrls.unit:unit_data().cutscene_actor = nil

			self:add_cutscene_actor()
		end
	end
end

function EditUnitSettings:remove_cutscene_actor()
	managers.cutscene:unregister_cutscene_actor(self._ctrls.unit)

	self._ctrls.unit:unit_data().cutscene_actor = nil

	self._ctrls.cutscene_actor_name:set_value("")
end

function EditUnitSettings:set_disable_shadows()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			unit:unit_data().disable_shadows = self._ctrls.disable_shadows:get_value()

			unit:set_shadows_disabled(unit:unit_data().disable_shadows)
		end
	end
end

function EditUnitSettings:set_hide_on_projection_light()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			unit:unit_data().hide_on_projection_light = self._ctrls.hide_on_projection_light:get_value() or nil
		end
	end
end

function EditUnitSettings:set_disable_on_ai_graph()
	for _, unit in ipairs(self._ctrls.units) do
		if alive(unit) then
			unit:unit_data().disable_on_ai_graph = self._ctrls.disable_on_ai_graph:get_value() or nil
		end
	end
end

function EditUnitSettings:is_editable(unit, units)
	self:stop_physics_simulation(true)

	if alive(unit) then
		self._ctrls.unit = unit
		self._ctrls.units = units

		self._ctrls.cutscene_actor_name:set_value(self._ctrls.unit:unit_data().cutscene_actor or "")
		self._ctrls.cutscene_actor_toolbar:set_tool_enabled("US_REMOVE_CUTSCENE_ACTOR", self._ctrls.unit:unit_data().cutscene_actor)
		self._ctrls.disable_shadows:set_value(self._ctrls.unit:unit_data().disable_shadows)
		self._ctrls.hide_on_projection_light:set_value(self._ctrls.unit:unit_data().hide_on_projection_light)
		self._ctrls.disable_on_ai_graph:set_value(self._ctrls.unit:unit_data().disable_on_ai_graph)

		return true
	end

	return false
end

function EditUnitSettings:on_reset_gravity()
	self._ctrls.physics_gravity_x:set_value(self._default_gravity.x)
	self._ctrls.physics_gravity_y:set_value(self._default_gravity.y)
	self._ctrls.physics_gravity_z:set_value(self._default_gravity.z)
	World:set_gravity(self._default_gravity)
end

function EditUnitSettings:toggle_physics_simulation()
	if self._simulating_physics then
		self:stop_physics_simulation()
	else
		self:start_physics_simulation()
	end
end

function EditUnitSettings:start_physics_simulation()
	if not self._ctrls.units or #self._ctrls.units == 0 then
		return
	end

	self._simulation_data = {}
	local new_gravity = Vector3(self._ctrls.physics_gravity_x:get_value(), self._ctrls.physics_gravity_y:get_value(), self._ctrls.physics_gravity_z:get_value())

	World:set_gravity(new_gravity)

	for _, unit in ipairs(self._ctrls.units) do
		if self:_should_simulate_physics(unit) then
			local unit_data = {
				position = nil,
				rotation = nil,
				unit = nil,
				unit = unit,
				position = unit:position(),
				rotation = unit:rotation()
			}
			local root = unit:orientation_object()

			for index = 0, unit:num_bodies() - 1 do
				local body = unit:body(index)

				if body and root == body:root_object() then
					body:set_collisions_enabled(true)
					body:set_ignore_static(false)
					body:set_dynamic()
				end
			end

			table.insert(self._simulation_data, unit_data)
		end
	end

	if #self._simulation_data == 0 then
		self._simulation_data = nil

		return
	end

	self._simulating_physics = true

	self._ctrls.physics_status:change_value("")
	self._ctrls.physics_status:set_default_style_colour(Vector3(0, 200, 0))
	self._ctrls.physics_status:append("Simulating on " .. #self._simulation_data .. " unit(s)")
end

function EditUnitSettings:_should_simulate_physics(unit)
	if not alive(unit) or unit:num_bodies() == 0 or unit:mission_element() then
		return false
	end

	return true
end

function EditUnitSettings:stop_physics_simulation(canceled)
	if not self._simulating_physics then
		return
	end

	local statics = managers.editor:layer("Statics")

	for _, setting in ipairs(self._simulation_data) do
		setting.unit:unit_data().local_pos = Vector3()
		setting.unit:unit_data().local_rot = Rotation()
		local new_pos = canceled and setting.position or setting.unit:position()
		local new_rot = canceled and setting.rotation or setting.unit:rotation()

		statics:set_bodies_keyframed(setting.unit)
		statics:set_unit_position(setting.unit, new_pos, Rotation())
		statics:set_unit_rotation(setting.unit, new_rot)
	end

	statics:recalc_all_locals()
	statics:set_unit_positions(self._ctrls.unit:position(), self._ctrls.unit:rotation())
	statics:set_unit_rotations(Rotation())
	World:set_gravity(self._default_gravity)
	self._ctrls.physics_reset:set_enabled(false)

	self._simulating_physics = false
	self._simulation_data = nil

	self._ctrls.physics_status:change_value("")
	self._ctrls.physics_status:set_default_style_colour(Vector3(0, 0, 0))
	self._ctrls.physics_status:append("Simulation Inactive")
end
