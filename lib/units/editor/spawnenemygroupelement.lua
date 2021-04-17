SpawnEnemyGroupUnitElement = SpawnEnemyGroupUnitElement or class(MissionElement)
SpawnEnemyGroupUnitElement.SAVE_UNIT_POSITION = false
SpawnEnemyGroupUnitElement.SAVE_UNIT_ROTATION = false
SpawnEnemyGroupUnitElement.RANDOMS = {
	"amount"
}

-- Lines 7-27
function SpawnEnemyGroupUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.spawn_type = "ordered"
	self._hed.ignore_disabled = true
	self._hed.amount = {
		0,
		0
	}
	self._hed.elements = {}
	self._hed.nationality = "german"
	self._hed.interval = 0
	self._hed.team = "default"

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "spawn_type")
	table.insert(self._save_values, "ignore_disabled")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "nationality")
	table.insert(self._save_values, "preferred_spawn_groups")
	table.insert(self._save_values, "interval")
	table.insert(self._save_values, "team")
end

-- Lines 30-51
function SpawnEnemyGroupUnitElement:post_init(...)
	SpawnEnemyGroupUnitElement.super.post_init(self, ...)

	if self._hed.preferred_spawn_groups and tweak_data.group_ai.enemy_spawn_groups[self._hed.nationality] then
		local i = 1

		while i <= #self._hed.preferred_spawn_groups do
			if not tweak_data.group_ai.enemy_spawn_groups[self._hed.nationality][self._hed.preferred_spawn_groups[i]] then
				table.remove(self._hed.preferred_spawn_groups, i)
			else
				i = i + 1
			end
		end

		if not next(self._hed.preferred_spawn_groups) then
			self._hed.preferred_spawn_groups = nil
		end
	end

	if self._hed.random ~= nil then
		self._hed.spawn_type = self._hed.random and "random" or "ordered"
		self._hed.random = nil
	end
end

-- Lines 53-55
function SpawnEnemyGroupUnitElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

-- Lines 57-58
function SpawnEnemyGroupUnitElement:update_editing()
end

-- Lines 60-68
function SpawnEnemyGroupUnitElement:update_selected(t, dt, selected_unit, all_units)
	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.75,
				b = 0,
				r = 0,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

-- Lines 70-80
function SpawnEnemyGroupUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

-- Lines 82-88
function SpawnEnemyGroupUnitElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

-- Lines 90-93
function SpawnEnemyGroupUnitElement:get_links_to_unit(...)
	SpawnEnemyGroupUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "spawn_point", ...)
end

-- Lines 96-98
function SpawnEnemyGroupUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

-- Lines 101-163
function SpawnEnemyGroupUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "spawn_type", table.list_add({
		"ordered"
	}, {
		"random",
		"group"
	}), "Specify how the enemy will be spawned.")
	self:_build_value_checkbox(panel, panel_sizer, "ignore_disabled", "Select if disabled spawn points should be ignored or not")
	self:_build_value_random_number(panel, panel_sizer, "amount", {
		floats = 0,
		min = 0
	}, "Specify amount of enemies to spawn from group")
	self:_build_value_number(panel, panel_sizer, "interval", {
		floats = 0,
		min = 0
	}, "Used to specify how often this spawn can be used. 0 means no interval")
	self:_build_value_combobox(panel, panel_sizer, "team", table.list_add({
		"default"
	}, tweak_data.levels:get_team_names_indexed()), "Select the group's team (overrides character team).")

	local opt_sizer = panel_sizer
	local filter_sizer = EWS:BoxSizer("HORIZONTAL")
	local opt1_sizer = EWS:BoxSizer("VERTICAL")
	local opt2_sizer = EWS:BoxSizer("VERTICAL")
	local opt3_sizer = EWS:BoxSizer("VERTICAL")
	local opt_nationalities = {}

	for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
		table.insert(opt_nationalities, cat_name)
	end

	table.sort(opt_nationalities)
	self:_build_value_combobox(panel, panel_sizer, "nationality", table.list_add(opt_nationalities), "Select the nationality to choose the groups from.")

	local opt_groups = {}

	for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups[opt_nationalities[1]]) do
		table.insert(opt_groups, cat_name)
	end

	table.sort(opt_groups)

	for i, o in ipairs(opt_groups) do
		local check = EWS:CheckBox(panel, o, "")

		if self._hed.preferred_spawn_groups and table.contains(self._hed.preferred_spawn_groups, o) then
			check:set_value(true)
		else
			check:set_value(false)
		end

		check:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "on_preferred_spawn_groups_checkbox_changed"), {
			ctrlr = check,
			name = o
		})

		if i <= math.round(#opt_groups / 3) then
			opt1_sizer:add(check, 0, 0, "EXPAND")
		elseif i <= math.round(#opt_groups / 3) * 2 then
			opt2_sizer:add(check, 0, 0, "EXPAND")
		else
			opt3_sizer:add(check, 0, 0, "EXPAND")
		end
	end

	filter_sizer:add(opt1_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt2_sizer, 1, 0, "EXPAND")
	filter_sizer:add(opt3_sizer, 1, 0, "EXPAND")
	opt_sizer:add(filter_sizer, 1, 0, "EXPAND")
end

-- Lines 167-185
function SpawnEnemyGroupUnitElement:on_preferred_spawn_groups_checkbox_changed(params)
	local value = params.ctrlr:get_value()

	if value then
		self._hed.preferred_spawn_groups = self._hed.preferred_spawn_groups or {}

		if table.contains(self._hed.preferred_spawn_groups, params.name) then
			return
		end

		table.insert(self._hed.preferred_spawn_groups, params.name)
	elseif self._hed.preferred_spawn_groups then
		table.delete(self._hed.preferred_spawn_groups, params.name)

		if not next(self._hed.preferred_spawn_groups) then
			self._hed.preferred_spawn_groups = nil
		end
	end
end
