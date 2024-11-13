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

function ObjectiveUnitElement:draw_links(t, dt, selected_unit, all_units)
	ObjectiveUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				b = 0.25,
				g = 0.85,
				r = 0.85,
				to_unit = nil,
				from_unit = nil,
				from_unit = unit,
				to_unit = self._unit
			})
		end
	end
end

function ObjectiveUnitElement:get_links_to_unit(...)
	ObjectiveUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

function ObjectiveUnitElement:update_editing()
end

function ObjectiveUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		mask = 10,
		ray_type = "editor"
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

function ObjectiveUnitElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

function ObjectiveUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

function ObjectiveUnitElement:update_sub_objectives()
	local sub_objectives = table.list_add({
		"none"
	}, managers.objectives:sub_objectives_by_name(self._hed.objective))
	self._hed.sub_objective = "none"

	CoreEws.update_combobox_options(self._sub_objective_params, sub_objectives)
	CoreEws.change_combobox_value(self._sub_objective_params, self._hed.sub_objective)
end

function ObjectiveUnitElement:update_localization()
	local objective = managers.objectives:get_objective(self._hed.objective)
	local sub_objective = objective and objective.sub_objectives[self._hed.sub_objective]

	self._objective_text:set_value(objective and objective.text or "")
	self._sub_objective_text:set_value(sub_objective and sub_objective.text or "")
end

function ObjectiveUnitElement:set_element_data(params, ...)
	ObjectiveUnitElement.super.set_element_data(self, params, ...)

	if params.value == "objective" then
		self:update_sub_objectives()
	end

	self:update_localization()
end

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

	self._objective_text = EWS:TextCtrl(panel, "", 0, "TE_NOHIDESEL,TE_RICH2,TE_DONTWRAP,TE_READONLY")

	panel_sizer:add(self._objective_text, 0, 0, "EXPAND,ALIGN_CENTER")

	local options = self._hed.objective ~= "none" and managers.objectives:sub_objectives_by_name(self._hed.objective) or {}
	local _, params = self:_build_value_combobox(panel, panel_sizer, "sub_objective", table.list_add({
		"none"
	}, options), "Select a sub objective from the combobox (if availible)")
	self._sub_objective_params = params
	self._sub_objective_text = EWS:TextCtrl(panel, "", 0, "TE_NOHIDESEL,TE_RICH2,TE_DONTWRAP,TE_READONLY")

	panel_sizer:add(self._sub_objective_text, 0, 0, "EXPAND,ALIGN_CENTER")
	self:_build_value_number(panel, panel_sizer, "amount", {
		min = 0,
		floats = 0,
		max = 100
	}, "Overrides objective amount counter with this value.")

	local help = {
		sizer = nil,
		panel = nil,
		panel = panel,
		sizer = panel_sizer,
		text = "State complete_and_activate will complete any previous objective and activate the selected objective. Note that it might not function well with objectives using amount"
	}

	self:add_help_text(help)
	self:update_localization()
end
