EscortUnitElement = EscortUnitElement or class(MissionElement)

-- Lines 3-20
function EscortUnitElement:init(unit)
	EscortUnitElement.super.init(self, unit)

	self._test_units = {}
	self._hed.break_so = "none"
	self._hed.break_point = false
	self._hed.next_points = {}
	self._hed.spawn_elements = {}
	self._hed.usage_times = 0
	self._hed.test_unit = "units/vanilla/characters/enemies/models/german_grunt_light_test/german_grunt_light_test"

	table.insert(self._save_values, "break_so")
	table.insert(self._save_values, "break_point")
	table.insert(self._save_values, "next_points")
	table.insert(self._save_values, "spawn_elements")
	table.insert(self._save_values, "usage_times")
end

-- Lines 22-25
function EscortUnitElement:post_init()
	self:set_break_point_icon_color(self._hed.break_point)

	return EscortUnitElement.super.post_init(self)
end

-- Lines 27-41
function EscortUnitElement:_raycast_get_type()
	local unit_type, unit, id = nil
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit then
		if string.find(ray.unit:name():s(), "point_escort", 1, true) then
			unit_type = "next_points"
		elseif string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true) or string.find(ray.unit:name():s(), "ai_civilian_group", 1, true) then
			unit_type = "spawn_elements"
		else
			return
		end

		return ray.unit:unit_data().unit_id, ray.unit, unit_type
	end
end

-- Lines 43-55
function EscortUnitElement:_lmb()
	local id, unit, unit_type = self:_raycast_get_type()

	if id and alive(unit) then
		local index = table.get_vector_index(self._hed[unit_type], id)

		if index then
			table.remove(self._hed[unit_type], index)
		else
			table.insert(self._hed[unit_type], id)
		end

		self._so_combobox:set_enabled(self._hed.break_point or #self._hed.next_points == 0)
	end
end

-- Lines 57-87
function EscortUnitElement:test_element()
	if not managers.navigation:is_data_ready() then
		EWS:message_box(Global.frame_panel, "Can't test spawn unit without ready navigation data (AI-graph)", "Spawn", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local spawn_unit_name = self._hed.test_unit or Idstring("units/vanilla/characters/enemies/models/german_grunt_light/german_grunt_light")
	local test_unit = safe_spawn_unit(spawn_unit_name, self._unit:position(), self._unit:rotation())

	if not test_unit then
		return
	end

	table.insert(self._test_units, test_unit)
	managers.groupai:state():set_char_team(test_unit, tweak_data.levels:get_default_team_ID("non_combatant"))
	test_unit:movement():set_root_blend(false)

	test_unit:anim_data().panic = true
	local action = {
		clamp_to_graph = true,
		body_part = 1,
		type = "act",
		variant = self._hed.break_so
	}

	test_unit:movement():action_request(action)
end

-- Lines 89-94
function EscortUnitElement:stop_test_element()
	for _, test_unit in ipairs(self._test_units) do
		test_unit:set_slot(0)
	end

	self._test_units = {}
end

-- Lines 96-98
function EscortUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "_lmb"))
end

-- Lines 100-116
function EscortUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_checkbox(panel, panel_sizer, "break_point", "The escort will interrupt their walk at this point", "Break Point")
	self:_build_value_number(panel, panel_sizer, "usage_times", {}, "Sets how many times this point can be used in a path (0 for infinite)", "Usage Times")

	local so_options = table.list_add({
		"none",
		"panic"
	}, clone(CopActionAct._act_redirects.SO))
	self._so_combobox = self:_build_value_combobox(panel, panel_sizer, "break_so", so_options, "Select an SO that will play at this point")

	self._so_combobox:set_enabled(self._hed.break_point or #self._hed.next_points == 0)

	local test_units = table.list_add(SpawnCivilianUnitElement._options, managers.enemy:enemy_units())

	self:_build_value_combobox(panel, panel_sizer, "test_unit", test_units, "Select a unit to use when testing the SO")
end

-- Lines 118-119
function EscortUnitElement:update_editing()
end

-- Lines 121-164
function EscortUnitElement:draw_links(t, dt, selected_unit, all_units)
	EscortUnitElement.super.draw_links(self, t, dt, selected_unit, all_units)

	local path = {}
	local next_points_list = {}
	local visited = {}

	table.insert(next_points_list, {
		from = self._ud.unit_id,
		to = self._hed.next_points
	})

	local draw = self._unit == selected_unit

	while #next_points_list > 0 do
		local data = table.remove(next_points_list, 1)

		for _, next_point in ipairs(data.to) do
			local unit = all_units[next_point]

			if alive(unit) then
				if path[data.from] then
					table.insert(path[data.from], unit)
				else
					path[data.from] = {
						unit
					}
				end

				draw = draw or unit == selected_unit

				if not visited[next_point] then
					table.insert(next_points_list, {
						from = next_point,
						to = unit:mission_element()._hed.next_points
					})
				end

				visited[next_point] = true
			end
		end
	end

	if draw then
		for point, units in pairs(path) do
			local from_unit = all_units[point]

			for _, unit in ipairs(units) do
				self:_draw_link({
					g = 0.85,
					b = 0,
					r = 0,
					from_unit = from_unit,
					to_unit = unit
				})
			end
		end
	end

	for _, spawn_id in ipairs(self._hed.spawn_elements) do
		local unit = all_units[spawn_id]

		if unit == selected_unit or self._unit == selected_unit then
			self:_draw_link({
				g = 0.85,
				b = 0.85,
				r = 0.85,
				from_unit = unit,
				to_unit = self._unit
			})
		end
	end
end

-- Lines 166-168
function EscortUnitElement:set_break_point_icon_color(is_break_point)
	self._icon_script.icon_bitmap:set_color(Color(is_break_point and "fffc4c4c" or self._iconcolor))
end

-- Lines 170-178
function EscortUnitElement:set_element_data(data)
	if data.value == "break_point" then
		local is_break_point = data.ctrlr:get_value()

		self._so_combobox:set_enabled(is_break_point)
		self:set_break_point_icon_color(is_break_point)
	end

	return EscortUnitElement.super.set_element_data(self, data)
end

-- Lines 180-189
function EscortUnitElement:_base_check_removed_units(all_units)
	EscortUnitElement.super._base_check_removed_units(self, all_units)

	for i, next_point in ipairs(clone(self._hed.next_points)) do
		if not alive(all_units[next_point]) then
			table.remove(self._hed.next_points, i)
		end
	end
end
