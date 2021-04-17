ObjectiveUnitElement = ObjectiveUnitElement or class(MissionElement)
ObjectiveUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "objective",
		type = "objective"
	},
	{
		value = "amount",
		type = "number"
	}
}

-- Lines 4-18
function ObjectiveUnitElement:init(unit)
	ObjectiveUnitElement.super.init(self, unit)

	self._hed.state = "complete_and_activate"
	self._hed.objective = "none"
	self._hed.sub_objective = "none"
	self._hed.amount = 0
	self._hed.elements = {}

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "objective")
	table.insert(self._save_values, "sub_objective")
	table.insert(self._save_values, "amount")
	table.insert(self._save_values, "elements")
end

-- Lines 22-31
function ObjectiveUnitElement:draw_links(t, dt, selected_unit, all_units)
	ObjectiveUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.85,
				b = 0.25,
				r = 0.85,
				from_unit = unit,
				to_unit = self._unit
			})
		end
	end
end

-- Lines 33-36
function ObjectiveUnitElement:get_links_to_unit(...)
	ObjectiveUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

-- Lines 38-39
function ObjectiveUnitElement:update_editing()
end

-- Lines 41-55
function ObjectiveUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and ray.unit:name() == Idstring("core/units/mission_elements/logic_counter/logic_counter") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

-- Lines 57-63
function ObjectiveUnitElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

-- Lines 66-68
function ObjectiveUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

-- Lines 71-76
function ObjectiveUnitElement:update_sub_objectives()
	local sub_objectives = table.list_add({
		"none"
	}, managers.objectives:sub_objectives_by_name(self._hed.objective))
	self._hed.sub_objective = "none"

	CoreEws.update_combobox_options(self._sub_objective_params, sub_objectives)
	CoreEws.change_combobox_value(self._sub_objective_params, self._hed.sub_objective)
end

-- Lines 78-83
function ObjectiveUnitElement:set_element_data(params, ...)
	ObjectiveUnitElement.super.set_element_data(self, params, ...)

	if params.value == "objective" then
		self:update_sub_objectives()
	end
end

-- Lines 85-105
function ObjectiveUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "state", {
		"activate",
		"complete",
		"update",
		"remove",
		"complete_and_activate",
		"remove_and_activate",
		"set_objective_current_amount",
		"set_sub_objective_amount",
		"set_sub_objective_current_amount"
	})
	self:_build_value_combobox(panel, panel_sizer, "objective", table.list_add({
		"none"
	}, managers.objectives:objectives_by_name()))

	local options = self._hed.objective ~= "none" and managers.objectives:sub_objectives_by_name(self._hed.objective) or {}
	local _, params = self:_build_value_combobox(panel, panel_sizer, "sub_objective", table.list_add({
		"none"
	}, options), "Select a sub objective from the combobox (if availible)")
	self._sub_objective_params = params

	self:_build_value_number(panel, panel_sizer, "amount", {
		min = 0,
		floats = 0,
		max = 100
	}, "Overrides objective amount counter with this value.")

	local help = {
		panel = panel,
		sizer = panel_sizer,
		text = "State complete_and_activate will complete any previous objective and activate the selected objective. Note that it might not function well with objectives using amount"
	}

	self:add_help_text(help)
end
