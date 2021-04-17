CoreTimerUnitElement = CoreTimerUnitElement or class(MissionElement)
CoreTimerUnitElement.SAVE_UNIT_POSITION = false
CoreTimerUnitElement.SAVE_UNIT_ROTATION = false
CoreTimerUnitElement.INSTANCE_VAR_NAMES = {
	{
		value = "timer",
		type = "number"
	}
}
TimerUnitElement = TimerUnitElement or class(CoreTimerUnitElement)

-- Lines 8-10
function TimerUnitElement:init(...)
	TimerUnitElement.super.init(self, ...)
end

-- Lines 12-25
function CoreTimerUnitElement:init(unit)
	CoreTimerUnitElement.super.init(self, unit)

	self._digital_gui_units = {}
	self._hed.timer = 0
	self._hed.digital_gui_unit_ids = {}
	self._hed.output_monitor_id = nil

	table.insert(self._save_values, "output_monitor_id")
	table.insert(self._save_values, "timer")
	table.insert(self._save_values, "digital_gui_unit_ids")
end

-- Lines 28-37
function CoreTimerUnitElement:layer_finished()
	MissionElement.layer_finished(self)

	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "load_unit"))

		if unit then
			self._digital_gui_units[unit:unit_data().unit_id] = unit
		end
	end
end

-- Lines 39-43
function CoreTimerUnitElement:load_unit(unit)
	if unit then
		self._digital_gui_units[unit:unit_data().unit_id] = unit
	end
end

-- Lines 45-68
function CoreTimerUnitElement:update_selected()
	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		if not alive(self._digital_gui_units[id]) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
		end
	end

	for id, unit in pairs(self._digital_gui_units) do
		if not alive(unit) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
		else
			local params = {
				g = 1,
				b = 0,
				r = 0,
				from_unit = self._unit,
				to_unit = unit
			}

			self:_draw_link(params)
			Application:draw(unit, 0, 1, 0)
		end
	end
end

-- Lines 70-83
function CoreTimerUnitElement:update_unselected(t, dt, selected_unit, all_units)
	for _, id in pairs(self._hed.digital_gui_unit_ids) do
		if not alive(self._digital_gui_units[id]) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
		end
	end

	for id, unit in pairs(self._digital_gui_units) do
		if not alive(unit) then
			table.delete(self._hed.digital_gui_unit_ids, id)

			self._digital_gui_units[id] = nil
		end
	end
end

-- Lines 85-98
function CoreTimerUnitElement:draw_links_unselected(...)
	CoreTimerUnitElement.super.draw_links_unselected(self, ...)

	for id, unit in pairs(self._digital_gui_units) do
		local params = {
			g = 0.5,
			b = 0,
			r = 0,
			from_unit = self._unit,
			to_unit = unit
		}

		self:_draw_link(params)
		Application:draw(unit, 0, 0.5, 0)
	end
end

-- Lines 100-105
function CoreTimerUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:digital_gui() and ray.unit:digital_gui():is_timer() then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

-- Lines 107-119
function CoreTimerUnitElement:select_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:digital_gui() and ray.unit:digital_gui():is_timer() then
		local unit = ray.unit

		if self._digital_gui_units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		else
			self:_add_unit(unit)
		end
	end
end

-- Lines 121-124
function CoreTimerUnitElement:_remove_unit(unit)
	self._digital_gui_units[unit:unit_data().unit_id] = nil

	table.delete(self._hed.digital_gui_unit_ids, unit:unit_data().unit_id)
end

-- Lines 126-129
function CoreTimerUnitElement:_add_unit(unit)
	self._digital_gui_units[unit:unit_data().unit_id] = unit

	table.insert(self._hed.digital_gui_unit_ids, unit:unit_data().unit_id)
end

-- Lines 131-133
function CoreTimerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "select_unit"))
end

-- Lines 135-140
function CoreTimerUnitElement:_add_unit_filter(unit)
	if self._digital_gui_units[unit:unit_data().unit_id] then
		return false
	end

	return unit:digital_gui() and unit:digital_gui():is_timer()
end

-- Lines 142-144
function CoreTimerUnitElement:_remove_unit_filter(unit)
	return self._digital_gui_units[unit:unit_data().unit_id]
end

-- Lines 146-160
function CoreTimerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_add_remove_static_unit_from_list(panel, panel_sizer, {
		add_filter = callback(self, self, "_add_unit_filter"),
		add_result = callback(self, self, "_add_unit"),
		remove_filter = callback(self, self, "_remove_unit_filter"),
		remove_result = callback(self, self, "_remove_unit")
	})
	self:_build_value_number(panel, panel_sizer, "timer", {
		floats = 1,
		min = 0
	}, "Specifies how long time (in seconds) to wait before execute")
	self:_add_help_text("Creates a timer element. When the timer runs out, execute will be run. The timer element can be operated on using the logic_timer_operator")
end

-- Lines 162-164
function CoreTimerUnitElement:register_debug_output_unit(output_monitor_id)
	self._hed.output_monitor_id = output_monitor_id
end

-- Lines 167-169
function CoreTimerUnitElement:unregister_debug_output_unit()
	self._hed.output_monitor_id = nil
end

CoreTimerOperatorUnitElement = CoreTimerOperatorUnitElement or class(MissionElement)
TimerOperatorUnitElement = TimerOperatorUnitElement or class(CoreTimerOperatorUnitElement)

-- Lines 177-179
function TimerOperatorUnitElement:init(...)
	TimerOperatorUnitElement.super.init(self, ...)
end

-- Lines 181-191
function CoreTimerOperatorUnitElement:init(unit)
	CoreTimerOperatorUnitElement.super.init(self, unit)

	self._hed.operation = "none"
	self._hed.time = 0
	self._hed.elements = {}

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "time")
	table.insert(self._save_values, "elements")
end

-- Lines 193-202
function CoreTimerOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreTimerOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0.75,
				b = 0.25,
				r = 0.75,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

-- Lines 204-207
function CoreTimerOperatorUnitElement:get_links_to_unit(...)
	CoreTimerOperatorUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "operator", ...)
end

-- Lines 209-210
function CoreTimerOperatorUnitElement:update_editing()
end

-- Lines 212-226
function CoreTimerOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (ray.unit:name() == Idstring("core/units/mission_elements/logic_timer/logic_timer") or ray.unit:name() == Idstring("core/units/mission_elements/logic_timer_hud/logic_timer_hud")) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

-- Lines 228-234
function CoreTimerOperatorUnitElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

-- Lines 237-239
function CoreTimerOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

-- Lines 241-254
function CoreTimerOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_timer/logic_timer"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_combobox(panel, panel_sizer, "operation", {
		"none",
		"pause",
		"start",
		"add_time",
		"subtract_time",
		"reset",
		"set_time",
		"show_hud_timer",
		"hide_hud_timer"
	}, "Select an operation for the selected elements")
	self:_build_value_number(panel, panel_sizer, "time", {
		floats = 1,
		min = 0
	}, "Amount of time to add, subtract or set to the timers.")
	self:_add_help_text("This element can modify logic_timer element. Select timers to modify using insert and clicking on the elements.")
end

CoreTimerTriggerUnitElement = CoreTimerTriggerUnitElement or class(MissionElement)
TimerTriggerUnitElement = TimerTriggerUnitElement or class(CoreTimerTriggerUnitElement)

-- Lines 262-264
function TimerTriggerUnitElement:init(...)
	TimerTriggerUnitElement.super.init(self, ...)
end

-- Lines 266-274
function CoreTimerTriggerUnitElement:init(unit)
	CoreTimerTriggerUnitElement.super.init(self, unit)

	self._hed.time = 0
	self._hed.elements = {}

	table.insert(self._save_values, "time")
	table.insert(self._save_values, "elements")
end

-- Lines 276-285
function CoreTimerTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreTimerTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

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

-- Lines 287-290
function CoreTimerTriggerUnitElement:get_links_to_unit(...)
	CoreTimerTriggerUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.elements, "trigger", ...)
end

-- Lines 292-293
function CoreTimerTriggerUnitElement:update_editing()
end

-- Lines 295-311
function CoreTimerTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and (ray.unit:name() == Idstring("core/units/mission_elements/logic_timer/logic_timer") or ray.unit:name() == Idstring("core/units/mission_elements/logic_timer_hud/logic_timer_hud")) then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
		else
			table.insert(self._hed.elements, id)
		end
	end
end

-- Lines 313-319
function CoreTimerTriggerUnitElement:remove_links(unit)
	for _, id in ipairs(self._hed.elements) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.elements, id)
		end
	end
end

-- Lines 322-324
function CoreTimerTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

-- Lines 326-338
function CoreTimerTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local names = {
		"logic_timer/logic_timer"
	}

	self:_build_add_remove_unit_from_list(panel, panel_sizer, self._hed.elements, names)
	self:_build_value_number(panel, panel_sizer, "time", {
		floats = 1,
		min = 0
	}, "Specify how much time should be left on the timer to trigger.")
	self:_add_help_text("This element is a trigger to logic_timer element.")
end
