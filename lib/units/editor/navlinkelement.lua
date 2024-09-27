NavLinkUnitElement = NavLinkUnitElement or class(MissionElement)
NavLinkUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "so_action",
		type = "special_objective_action"
	}
}
NavLinkUnitElement._AI_SO_types = {
	"AI_defend",
	"AI_security",
	"AI_hunt",
	"AI_search",
	"AI_idle",
	"AI_escort",
	"AI_sniper"
}
NavLinkUnitElement.PRESETS = {
	security = nil,
	civilians = nil,
	team_ai = nil,
	acrobats = nil,
	heavies = nil,
	civilians = {
		"civ_male",
		"civ_female"
	},
	team_ai = {
		"teamAI1",
		"teamAI2",
		"teamAI3",
		"teamAI4"
	},
	security = {
		"security",
		"security_patrol"
	},
	acrobats = {
		"cop",
		"fbi",
		"swat",
		"sniper",
		"gangster",
		"murky",
		"teamAI1",
		"teamAI2",
		"teamAI3",
		"teamAI4"
	},
	heavies = {
		"shield",
		"tank"
	}
}

function NavLinkUnitElement:init(unit)
	NavLinkUnitElement.super.init(self, unit)

	self._nav_link_filter = {}
	self._nav_link_filter_check_boxes = {}
	self._hed.ai_group = "none"
	self._hed.align_rotation = true
	self._hed.align_position = true
	self._hed.needs_pos_rsrv = true
	self._hed.is_navigation_link = true
	self._hed.so_action = "none"
	self._hed.search_position = self._unit:position()
	self._hed.interval = ElementNavLink._DEFAULT_VALUES.interval
	self._hed.attitude = "none"
	self._hed.SO_access = "0"
	self._hed.test_unit = "default"
	self._hed._patrol_group = false

	table.insert(self._save_values, "ai_group")
	table.insert(self._save_values, "align_rotation")
	table.insert(self._save_values, "align_position")
	table.insert(self._save_values, "needs_pos_rsrv")
	table.insert(self._save_values, "so_action")
	table.insert(self._save_values, "search_position")
	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "attitude")
	table.insert(self._save_values, "followup_elements")
	table.insert(self._save_values, "SO_access")
	table.insert(self._save_values, "is_navigation_link")
end

function NavLinkUnitElement:post_init(...)
	NavLinkUnitElement.super.post_init(self, ...)

	self._nav_link_filter = managers.navigation:convert_access_filter_to_table(self._hed.SO_access)

	if type_name(self._hed.SO_access) == "number" then
		self._hed.SO_access = tostring(self._hed.SO_access)
	end
end

function NavLinkUnitElement:test_element()
	Application:trace("NavLinkUnitElement:test_element: ")

	if not managers.navigation:is_data_ready() then
		EWS:message_box(Global.frame_panel, "Can't test spawn unit without ready navigation data (AI-graph)", "Spawn", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	self:stop_test_element()

	local spawn_unit_name = nil

	if self._hed.test_unit == "default" then
		local SO_access_strings = managers.navigation:convert_access_filter_to_table(self._hed.SO_access)

		for _, access_category in ipairs(SO_access_strings) do
			-- Nothing
		end
	else
		spawn_unit_name = self._hed.test_unit
	end

	spawn_unit_name = spawn_unit_name or Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light")
	self._test_unit = safe_spawn_unit(spawn_unit_name, self._unit:position(), self._unit:rotation())

	if not alive(self._test_unit) then
		return
	end

	managers.groupai:state():set_char_team(self._test_unit, tweak_data.levels:get_default_team_ID("non_combatant"))
	self._test_unit:movement():set_root_blend(false)

	local t = {
		id = nil,
		editor_name = nil,
		id = self._unit:unit_data().unit_id,
		editor_name = self._unit:unit_data().name_id,
		values = self:new_save_values()
	}
	t.values.enabled = true
	t.values.use_instigator = true
	t.values.is_navigation_link = false
	t.values.is_alert_point = false
	t.values.followup_elements = nil
	t.values.spawn_instigator_ids = nil
	self._script = MissionScript:new({
		elements = nil,
		elements = {}
	})
	self._so_class = ElementSpecialObjective:new(self._script, t)
	self._so_class._values.align_position = nil
	self._so_class._values.align_rotation = nil

	self._so_class:on_executed(self._test_unit)
	self._so_class:add_event_callback("complete", callback(self, self, "loop_test_element"))

	self._start_test_t = Application:time()
end

function NavLinkUnitElement:loop_test_element()
	self._test_unit:warp_to(self._unit:rotation(), self._unit:position())
	self._so_class:on_executed(self._test_unit)
end

function NavLinkUnitElement:stop_test_element()
	if alive(self._test_unit) then
		self._test_unit:set_slot(0)
	end

	if self._start_test_t then
		print("Stop test time", self._start_test_t and Application:time() - self._start_test_t or 0)

		self._start_test_t = nil
	end

	if self._so_class then
		self._so_class:destroy()

		self._so_class = nil
	end
end

function NavLinkUnitElement:draw_links(t, dt, selected_unit, all_units)
	if self._hed._patrol_group then
		return
	end

	NavLinkUnitElement.super.draw_links(self, t, dt, selected_unit)
	self:_draw_follow_up(selected_unit, all_units)
end

function NavLinkUnitElement:update_selected(t, dt, selected_unit, all_units)
	local brush = Draw:brush()

	brush:set_color(Color(0.15, 1, 1, 1))

	local pen = Draw:pen(Color(0.15, 0.5, 0.5, 0.5))

	brush:sphere(self._hed.search_position, 0, 4)
	pen:sphere(self._hed.search_position, 0)
	brush:sphere(self._hed.search_position, 10, 4)
	Application:draw_line(self._hed.search_position, self._unit:position(), 0, 1, 0)
	self:_draw_follow_up(selected_unit, all_units)
	self:_highlight_if_outside_the_nav_field(t)
end

function NavLinkUnitElement:_highlight_if_outside_the_nav_field(t)
	if managers.navigation:is_data_ready() then
		local my_pos = self._unit:position()
		local nav_tracker = managers.navigation._quad_field:create_nav_tracker(my_pos, true)

		if nav_tracker:lost() then
			local t1 = t % 0.5
			local t2 = t % 1
			local alpha = nil

			if t2 > 0.5 then
				alpha = t1
			else
				alpha = 0.5 - t1
			end

			alpha = math.lerp(0.1, 0.5, alpha)
			local nav_color = Color(alpha, 1, 0, 0)

			Draw:brush(nav_color):cylinder(my_pos, my_pos + math.UP * 80, 20, 4)
		end

		managers.navigation:destroy_nav_tracker(nav_tracker)
	end
end

function NavLinkUnitElement:update_unselected(t, dt, selected_unit, all_units)
	if self._hed.followup_elements then
		local followup_elements = self._hed.followup_elements
		local i = #followup_elements

		while i > 0 do
			local element_id = followup_elements[i]

			if not alive(all_units[element_id]) then
				table.remove(followup_elements, i)
			end

			i = i - 1
		end

		if not next(followup_elements) then
			self._hed.followup_elements = nil
		end
	end
end

function NavLinkUnitElement:_draw_follow_up(selected_unit, all_units)
	if self._hed.followup_elements then
		for _, element_id in ipairs(self._hed.followup_elements) do
			local unit = all_units[element_id]
			local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

			if draw then
				self:_draw_link({
					b = 0,
					g = 0.75,
					r = 0,
					to_unit = nil,
					from_unit = nil,
					from_unit = self._unit,
					to_unit = unit
				})
			end
		end
	end
end

function NavLinkUnitElement:update_editing()
	self:_so_raycast()
	self:_spawn_raycast()
	self:_raycast()
end

function NavLinkUnitElement:_so_raycast()
	local ray = managers.editor:unit_by_raycast({
		mask = 10,
		ray_type = "editor"
	})

	if ray and ray.unit and (string.find(ray.unit:name():s(), "point_special_objective", 1, true) or string.find(ray.unit:name():s(), "ai_so_group", 1, true)) then
		local id = ray.unit:unit_data().unit_id

		Application:draw(ray.unit, 0, 1, 0)

		return id
	end

	return nil
end

function NavLinkUnitElement:_spawn_raycast()
	local ray = managers.editor:unit_by_raycast({
		mask = 10,
		ray_type = "editor"
	})

	if not ray or not ray.unit then
		return
	end

	local id = nil

	if string.find(ray.unit:name():s(), "ai_enemy_group", 1, true) or string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) or string.find(ray.unit:name():s(), "ai_civilian_group", 1, true) or string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true) then
		id = ray.unit:unit_data().unit_id

		Application:draw(ray.unit, 0, 0, 1)
	end

	return id
end

function NavLinkUnitElement:_raycast()
	local from = managers.editor:get_cursor_look_point(0)
	local to = managers.editor:get_cursor_look_point(100000)
	local ray = World:raycast(from, to, nil, managers.slot:get_mask("all"))

	if ray and ray.position then
		Application:draw_sphere(ray.position, 10, 1, 1, 1)

		return ray.position
	end

	return nil
end

function NavLinkUnitElement:_lmb()
	local id = self:_so_raycast()

	if id then
		if self._hed.followup_elements then
			for i, element_id in ipairs(self._hed.followup_elements) do
				if element_id == id then
					table.remove(self._hed.followup_elements, i)

					if not next(self._hed.followup_elements) then
						self._hed.followup_elements = nil
					end

					return
				end
			end
		end

		self._hed.followup_elements = self._hed.followup_elements or {}

		table.insert(self._hed.followup_elements, id)

		return
	end

	self._hed.search_position = self:_raycast() or self._hed.search_position
end

function NavLinkUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "_lmb"))
end

function NavLinkUnitElement:selected()
	NavLinkUnitElement.super.selected(self)
end

function NavLinkUnitElement:_apply_preset(params)
	local value = params.ctrlr:get_value()
	local confirm = EWS:message_box(Global.frame_panel, "Apply preset " .. value .. "?", "Special objective", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	if value == "clear" then
		self:_clear_all_nav_link_filters()
	elseif value == "all" then
		self:_enable_all_nav_link_filters()
	elseif NavLinkUnitElement.PRESETS[value] then
		self:_set_preset_nav_link_filters(value)
	else
		print("Didn't have preset", value, "yet.")
	end
end

function NavLinkUnitElement:_enable_all_nav_link_filters()
	for name, ctrlr in pairs(self._nav_link_filter_check_boxes) do
		ctrlr:set_value(true)
		self:_toggle_nav_link_filter_value({
			name = nil,
			ctrlr = nil,
			ctrlr = ctrlr,
			name = name
		})
	end
end

function NavLinkUnitElement:_clear_all_nav_link_filters()
	for name, ctrlr in pairs(self._nav_link_filter_check_boxes) do
		ctrlr:set_value(false)
		self:_toggle_nav_link_filter_value({
			name = nil,
			ctrlr = nil,
			ctrlr = ctrlr,
			name = name
		})
	end
end

function NavLinkUnitElement:_set_preset_nav_link_filters(value)
	local list = NavLinkUnitElement.PRESETS[value]

	for name, ctrlr in pairs(self._nav_link_filter_check_boxes) do
		local state = table.contains(list, name)

		ctrlr:set_value(state)
		self:_toggle_nav_link_filter_value({
			name = nil,
			ctrlr = nil,
			ctrlr = ctrlr,
			name = name
		})
	end
end

function NavLinkUnitElement:_toggle_nav_link_filter_value(params)
	local value = params.ctrlr:get_value()

	if value then
		for i, k in ipairs(self._nav_link_filter) do
			if k == params.name then
				return
			end
		end

		table.insert(self._nav_link_filter, params.name)
	else
		table.delete(self._nav_link_filter, params.name)
	end

	self._hed.SO_access = managers.navigation:convert_access_filter_to_string(self._nav_link_filter)
end

function NavLinkUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	self._nav_link_filter = managers.navigation:convert_access_filter_to_table(self._hed.SO_access)
	local opt_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Filter")
	local filter_preset_params = {
		name = "Preset:",
		tooltip = "Select a preset.",
		options = nil,
		sizer = nil,
		ctrlr_proportions = 2,
		sorted = true,
		panel = nil,
		name_proportions = 1,
		panel = panel,
		sizer = opt_sizer,
		options = {
			"clear",
			"all",
			"civilians",
			"team_ai",
			"security",
			"acrobats",
			"heavies"
		}
	}
	local filter_preset = CoreEWS.combobox(filter_preset_params)

	filter_preset:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_apply_preset"), {
		ctrlr = nil,
		ctrlr = filter_preset
	})

	local filter_sizer = EWS:BoxSizer("HORIZONTAL")
	local opt1_sizer = EWS:BoxSizer("VERTICAL")
	local opt2_sizer = EWS:BoxSizer("VERTICAL")
	local opt3_sizer = EWS:BoxSizer("VERTICAL")
	local opt = NavigationManager.ACCESS_FLAGS

	for i, o in ipairs(opt) do
		local check = EWS:CheckBox(panel, o, "")

		check:set_value(table.contains(self._nav_link_filter, o))
		check:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "_toggle_nav_link_filter_value"), {
			name = nil,
			ctrlr = nil,
			ctrlr = check,
			name = o
		})

		self._nav_link_filter_check_boxes[o] = check

		if i <= math.round(#opt / 3) then
			opt1_sizer:add(check, 0, 0, "EXPAND")
		elseif i <= math.round(#opt / 3) * 2 then
			opt2_sizer:add(check, 0, 0, "EXPAND")
		else
			opt3_sizer:add(check, 0, 0, "EXPAND")
		end
	end

	filter_sizer:add(opt1_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt2_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt3_sizer, 1, 0, "EXPAND")
	opt_sizer:add(filter_sizer, 1, 0, "EXPAND")
	panel_sizer:add(opt_sizer, 0, 0, "EXPAND")
	self:_build_value_combobox(panel, panel_sizer, "ai_group", table.list_add({
		"none"
	}, clone(ElementSpecialObjective._AI_GROUPS)), "Select an ai group.")

	local options = table.list_add({
		"none"
	}, clone(CopActionAct._act_redirects.SO))

	self:_build_value_combobox(panel, panel_sizer, "so_action", table.list_add(options, self._AI_SO_types), "Select a action that the unit should start with.")
	self:_build_value_combobox(panel, panel_sizer, "attitude", table.list_add({
		"none"
	}, ElementSpecialObjective._ATTITUDES), "Select combat attitude.")
	self:_build_value_number(panel, panel_sizer, "interval", {
		min = -1,
		floats = 2
	}, "Used to specify how often the SO should search for an actor. A negative value means it will check only once.")

	local test_units = table.list_add(SpawnCivilianUnitElement._options, managers.enemy:enemy_units())

	table.insert(test_units, 1, "default")
	self:_build_value_combobox(panel, panel_sizer, "test_unit", test_units, "Select the unit to be used when testing.")
end

function NavLinkUnitElement:add_to_mission_package()
end
