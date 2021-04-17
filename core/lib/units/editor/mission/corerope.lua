CoreRopeOperatorUnitElement = CoreRopeOperatorUnitElement or class(MissionElement)
RopeOperatorUnitElement = RopeOperatorUnitElement or class(CoreRopeOperatorUnitElement)
RopeOperatorUnitElement.OPERATIONS = {
	"attach",
	"detach"
}

-- Lines 7-9
function RopeOperatorUnitElement:init(...)
	RopeOperatorUnitElement.super.init(self, ...)
end

-- Lines 13-21
function CoreRopeOperatorUnitElement:init(unit)
	CoreRopeOperatorUnitElement.super.init(self, unit)

	self._hed.operation = RopeOperatorUnitElement.OPERATIONS[1]
	self._hed.rope_unit_id = nil

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "rope_unit_id")
end

-- Lines 23-35
function CoreRopeOperatorUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreRopeOperatorUnitElement.super.draw_links(self, t, dt, selected_unit)

	if self._hed.rope_unit_id then
		local unit = self:_get_unit(self._hed.rope_unit_id)
		local draw = not selected_unit or unit == selected_unit or self._unit == selected_unit

		if draw then
			self:_draw_link({
				g = 0,
				b = 1,
				r = 0,
				from_unit = self._unit,
				to_unit = unit
			})
		end
	end
end

-- Lines 37-40
function CoreRopeOperatorUnitElement:get_links_to_unit(...)
	CoreRopeOperatorUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.rope_units, "operator", ...)
end

-- Lines 42-47
function CoreRopeOperatorUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 0, 1)
	end
end

-- Lines 49-51
function CoreRopeOperatorUnitElement:update_selected()
	Application:draw_arrow(self._unit:position(), self._unit:position() + self._unit:rotation():y() * -100, 1, 1, 1, 0.3)
end

-- Lines 53-66
function CoreRopeOperatorUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:name() == Idstring("units/vanilla/props/props_rope/props_rope") then
		local id = ray.unit:unit_data().unit_id

		if self._hed.rope_unit_id == id then
			self._hed.rope_unit_id = nil
		else
			self._hed.rope_unit_id = id
		end
	end
end

-- Lines 68-70
function CoreRopeOperatorUnitElement:remove_links(unit)
	self._hed.rope_unit_id = nil
end

-- Lines 73-75
function CoreRopeOperatorUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

-- Lines 78-88
function CoreRopeOperatorUnitElement:add_unit_list_btn()
	-- Lines 79-82
	local function f(unit)
		return unit:unit_data().name_id:find("props_rope")
	end

	local dialog = SingleSelectUnitByNameModal:new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		self._hed.rope_unit_id = unit:unit_data().unit_id
	end
end

-- Lines 90-92
function CoreRopeOperatorUnitElement:remove_unit_list_btn()
	self._hed.rope_unit_id = nil
end

-- Lines 94-115
function CoreRopeOperatorUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", RopeOperatorUnitElement.OPERATIONS, "Select an operation for the selected element.")
	self:_add_help_text("This element can control rope units. Select rope unit by using insert and clicking on the element.")

	self._btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._btn_toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._btn_toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	self._btn_toolbar:add_tool("REMOVE_UNIT_LIST", "Remove unit from unit list", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	self._btn_toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_unit_list_btn"), nil)
	self._btn_toolbar:realize()
	panel_sizer:add(self._btn_toolbar, 0, 1, "EXPAND,LEFT")
end

-- Lines 117-118
function CoreRopeOperatorUnitElement:on_executed_marker_selected()
end

-- Lines 120-126
function CoreRopeOperatorUnitElement:_get_unit(unit_id)
	if Application:editor() then
		return managers.editor:unit_with_id(unit_id)
	else
		return managers.worlddefinition:get_unit(unit_id)
	end
end

CoreRopeTriggerUnitElement = CoreRopeTriggerUnitElement or class(MissionElement)
RopeTriggerUnitElement = RopeTriggerUnitElement or class(CoreRopeTriggerUnitElement)

-- Lines 134-136
function RopeTriggerUnitElement:init(...)
	RopeTriggerUnitElement.super.init(self, ...)
end

-- Lines 138-146
function CoreRopeTriggerUnitElement:init(unit)
	CoreRopeTriggerUnitElement.super.init(self, unit)

	self._hed.outcome = "marker_reached"
	self._hed.rope_units = {}

	table.insert(self._save_values, "outcome")
	table.insert(self._save_values, "elements")
end

-- Lines 148-157
function CoreRopeTriggerUnitElement:draw_links(t, dt, selected_unit, all_units)
	CoreRopeTriggerUnitElement.super.draw_links(self, t, dt, selected_unit)

	for _, id in ipairs(self._hed.rope_units) do
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

-- Lines 159-162
function CoreRopeTriggerUnitElement:get_links_to_unit(...)
	CoreRopeTriggerUnitElement.super.get_links_to_unit(self, ...)
	self:_get_links_of_type_from_elements(self._hed.rope_units, "trigger", ...)
end

-- Lines 164-169
function CoreRopeTriggerUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

-- Lines 171-184
function CoreRopeTriggerUnitElement:add_element()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit and ray.unit:name() == Idstring("units/dev_tools/mission_elements/motion_path_marker/motion_path_marker") then
		local id = ray.unit:unit_data().unit_id

		if table.contains(self._hed.rope_units, id) then
			table.delete(self._hed.rope_units, id)
		else
			table.insert(self._hed.rope_units, id)
		end
	end
end

-- Lines 186-192
function CoreRopeTriggerUnitElement:remove_links(unit)
	for _, id in ipairs(self._hed.rope_units) do
		if id == unit:unit_data().unit_id then
			table.delete(self._hed.rope_units, id)
		end
	end
end

-- Lines 195-197
function CoreRopeTriggerUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "add_element"))
end

-- Lines 199-208
function CoreRopeTriggerUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "outcome", {
		"marker_reached"
	}, "Select an outcome to trigger on")
	self:_add_help_text("This element is a trigger on motion path marker element.")
end
