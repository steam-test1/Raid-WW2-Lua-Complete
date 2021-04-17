PointOfNoReturnElement = PointOfNoReturnElement or class(MissionElement)

-- Lines 3-19
function PointOfNoReturnElement:init(unit)
	PointOfNoReturnElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.time_normal = 240
	self._hed.time_hard = 120
	self._hed.time_overkill = 60
	self._hed.time_overkill_145 = 30

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "time_easy")
	table.insert(self._save_values, "time_normal")
	table.insert(self._save_values, "time_hard")
	table.insert(self._save_values, "time_overkill")
	table.insert(self._save_values, "time_overkill_145")
	table.insert(self._save_values, "time_overkill_290")
end

-- Lines 23-153
function PointOfNoReturnElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local exact_names = {
		"core/units/mission_elements/trigger_area/trigger_area"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, nil, exact_names)

	local time_params_easy = {
		name = "Time left on easy:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the time left",
		min = 1,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.time_easy
	}
	local time_easy = CoreEWS.number_controller(time_params_easy)

	time_easy:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "time_easy",
		ctrlr = time_easy
	})
	time_easy:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "time_easy",
		ctrlr = time_easy
	})

	local time_params_normal = {
		name = "Time left on normal:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the time left",
		min = 1,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.time_normal
	}
	local time_normal = CoreEWS.number_controller(time_params_normal)

	time_normal:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "time_normal",
		ctrlr = time_normal
	})
	time_normal:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "time_normal",
		ctrlr = time_normal
	})

	local time_params_hard = {
		name = "Time left on hard:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the time left",
		min = 1,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.time_hard
	}
	local time_hard = CoreEWS.number_controller(time_params_hard)

	time_hard:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "time_hard",
		ctrlr = time_hard
	})
	time_hard:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "time_hard",
		ctrlr = time_hard
	})

	local time_params_overkill = {
		name = "Time left on overkill:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the time left",
		min = 1,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.time_overkill
	}
	local time_overkill = CoreEWS.number_controller(time_params_overkill)

	time_overkill:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "time_overkill",
		ctrlr = time_overkill
	})
	time_overkill:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "time_overkill",
		ctrlr = time_overkill
	})

	local time_params_overkill_145 = {
		name = "Time left on overkill 145:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the time left",
		min = 1,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.time_overkill_145
	}
	local time_overkill_145 = CoreEWS.number_controller(time_params_overkill_145)

	time_overkill_145:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "time_overkill_145",
		ctrlr = time_overkill_145
	})
	time_overkill_145:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "time_overkill_145",
		ctrlr = time_overkill_145
	})

	local time_params_overkill_290 = {
		name = "Time left on overkill 290:",
		ctrlr_proportions = 2,
		name_proportions = 1,
		tooltip = "Set the time left",
		min = 1,
		floats = 0,
		panel = panel,
		sizer = panel_sizer,
		value = self._hed.time_overkill_290
	}
	local time_overkill_290 = CoreEWS.number_controller(time_params_overkill_290)

	time_overkill_290:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "time_overkill_290",
		ctrlr = time_overkill_290
	})
	time_overkill_290:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "time_overkill_290",
		ctrlr = time_overkill_290
	})
end

-- Lines 162-164
function PointOfNoReturnElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

-- Lines 166-167
function PointOfNoReturnElement:update_editing()
end

-- Lines 170-178
function PointOfNoReturnElement:update_selected(t, dt, selected_unit, all_units)
	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0,
				b = 0.75,
				r = 0.75,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

-- Lines 180-190
function PointOfNoReturnElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name():s() == "core/units/mission_elements/trigger_area/trigger_area" then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

-- Lines 192-198
function PointOfNoReturnElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

-- Lines 201-203
function PointOfNoReturnElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end
