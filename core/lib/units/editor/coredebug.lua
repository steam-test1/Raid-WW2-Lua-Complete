CoreDebugUnitElement = CoreDebugUnitElement or class(MissionElement)
DebugUnitElement = DebugUnitElement or class(CoreDebugUnitElement)
DebugUnitElement.SAVE_UNIT_POSITION = false
DebugUnitElement.SAVE_UNIT_ROTATION = false

function DebugUnitElement:init(...)
	CoreDebugUnitElement.init(self, ...)
end

function CoreDebugUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.debug_string = "none"
	self._hed.as_subtitle = false
	self._hed.show_instigator = false
	self._hed.color = nil
	self._hed.elements = {}

	table.insert(self._save_values, "elements")
	table.insert(self._save_values, "debug_string")
	table.insert(self._save_values, "as_subtitle")
	table.insert(self._save_values, "show_instigator")
	table.insert(self._save_values, "color")
end

function CoreDebugUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local debug = EWS:TextCtrl(panel, self._hed.debug_string, "", "TE_PROCESS_ENTER")

	panel_sizer:add(debug, 0, 0, "EXPAND")
	debug:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "debug_string",
		ctrlr = debug
	})
	debug:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "debug_string",
		ctrlr = debug
	})
	self:_build_value_checkbox(panel, panel_sizer, "as_subtitle", "Show as subtitle")
	self:_build_value_checkbox(panel, panel_sizer, "show_instigator", "Show instigator")
end

function CoreDebugUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

function CoreDebugUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_monitored_unit"))
end

function CoreDebugUnitElement:add_monitored_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:slot() == 10 then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.elements, id) then
			table.delete(self._hed.elements, id)
			self:unregister_monitor(ray.unit)
		else
			table.insert(self._hed.elements, id)
			self:register_monitor(ray.unit)
		end
	end
end

function CoreDebugUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreDebugUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.elements) do
		local unit = all_units[id]
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				r = 0.75,
				b = 0.75,
				g = 0.25,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

function CoreDebugUnitElement:on_delete()
	Application:trace("CoreDebugUnitElement:on_delete()")
end

function CoreDebugUnitElement:register_monitor(unit)
	if unit:mission_element().register_debug_output_unit then
		unit:mission_element():register_debug_output_unit(self._unit:unit_data().unit_id)
	end
end

function CoreDebugUnitElement:unregister_monitor(unit)
	if unit:mission_element().unregister_debug_output_unit then
		unit:mission_element():unregister_debug_output_unit()
	end
end
