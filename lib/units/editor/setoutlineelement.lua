SetOutlineElement = SetOutlineElement or class(MissionElement)

function SetOutlineElement:init(unit)
	SetOutlineElement.super.init(self, unit)

	self._hed.elements = {}
	self._hed.set_outline = true
	self._hed.outline_type = "highlight_character"
	self._hed.instigator_only = false

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "set_outline")
	table.insert(self._save_values, "outline_type")
	table.insert(self._save_values, "instigator_only")
end

function SetOutlineElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"ai_spawn_enemy",
		"ai_spawn_civilian"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)

	local set_outline = EWS:CheckBox(panel, "Enable outline", "")

	set_outline:set_value(self._hed.set_outline)
	set_outline:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "set_outline",
		ctrlr = nil,
		ctrlr = set_outline
	})
	panel_sizer:add(set_outline, 0, 0, "EXPAND")

	local instigator_only = EWS:CheckBox(panel, "Outline instigator only", "")

	instigator_only:set_value(self._hed.instigator_only)
	instigator_only:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "instigator_only",
		ctrlr = nil,
		ctrlr = instigator_only
	})
	panel_sizer:add(instigator_only, 0, 0, "EXPAND")

	local outline_list = table.map_keys(ContourExt._types)

	self:_build_value_combobox(panel, panel_sizer, "outline_type", outline_list, "Select outline type.")
end

function SetOutlineElement:draw_links(t, dt, selected_unit, all_units)
	MissionElement.draw_links(self, t, dt, selected_unit, all_units)
end

function SetOutlineElement:update_editing()
end

function SetOutlineElement:update_selected(t, dt, selected_unit, all_units)
	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				b = 1,
				g = 0.5,
				r = 0.9,
				to_unit = nil,
				from_unit = nil,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function SetOutlineElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (string.find(ray.unit:name():s(), "ai_spawn_enemy", 1, true) or string.find(ray.unit:name():s(), "ai_spawn_civilian", 1, true)) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

function SetOutlineElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

function SetOutlineElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end
