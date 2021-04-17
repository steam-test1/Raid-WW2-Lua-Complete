CoreWorldEventUnitElement = CoreWorldEventUnitElement or class(MissionElement)

-- Lines 4-13
function CoreWorldEventUnitElement:init(type, ...)
	CoreWorldEventUnitElement.super.init(self, ...)

	self._type = type
	self._guis = {}
	self._hed.event_list = {}

	table.insert(self._save_values, "event_list")
end

-- Lines 15-18
function CoreWorldEventUnitElement:layer_finished(...)
	CoreWorldEventUnitElement.super.layer_finished(self, ...)
end

-- Lines 20-22
function CoreWorldEventUnitElement:selected()
	InstanceEventUnitElement.super.selected(self)
end

-- Lines 24-28
function CoreWorldEventUnitElement:update_selected(t, dt)
	for _, data in ipairs(self._hed.event_list) do
		self:_draw_world_link(t, dt, data.world_name)
	end
end

-- Lines 30-31
function CoreWorldEventUnitElement:update_editing(t, dt)
end

-- Lines 33-40
function CoreWorldEventUnitElement:_draw_world_link(t, dt, world_name)
	local r, g, b = self:get_link_color()

	if self._type == "input" then
		Application:draw_arrow(self._unit:position(), managers.worldcollection:get_world_position(world_name), r, g, b, 0.2)
	else
		Application:draw_arrow(managers.worldcollection:get_world_position(world_name), self._unit:position(), r, g, b, 0.2)
	end
end

-- Lines 42-52
function CoreWorldEventUnitElement:_world_name_raycast()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if not ray or not ray.unit then
		return nil
	end

	local world_name = nil

	if ray.unit:mission_element_data() and ray.unit:mission_element_data().element_class == "ElementWorldPoint" then
		world_name = ray.unit:unit_data().name_id
	end

	return world_name
end

-- Lines 55-68
function CoreWorldEventUnitElement:on_world_changed_name(old_name, new_name)
	for _, data in ipairs(self._hed.event_list) do
		if data.world_name == old_name then
			data.world_name = new_name
		end
	end

	for _, data in ipairs(self._guis) do
		if data.world_name == old_name then
			data.world_name = new_name

			data.world_name_ctrlr:set_label(new_name)
		end
	end
end

-- Lines 71-78
function CoreWorldEventUnitElement:on_world_deleted(name)
	local clone_guis = clone(self._guis)

	for i, event_list_data in ipairs(clone(self._hed.event_list)) do
		if event_list_data.world_name == name then
			self:remove_entry(event_list_data)
		end
	end
end

-- Lines 80-86
function CoreWorldEventUnitElement:_get_events(world_name)
	if self._type == "input" then
		return managers.worldcollection:get_mission_elements_from_script(world_name, "ElementWorldInput")
	else
		return managers.worldcollection:get_mission_elements_from_script(world_name, "ElementWorldOutput")
	end
end

-- Lines 88-93
function CoreWorldEventUnitElement:_set_world_by_raycast()
	local world_name = self:_world_name_raycast()

	if world_name then
		self:_add_world_by_name(world_name)
	end
end

-- Lines 95-102
function CoreWorldEventUnitElement:_add_world_by_name(world_name)
	local world = managers.worldcollection:world_names()[world_name].world
	local events = self:_get_events(world)
	local event_list_data = {
		world_name = world_name,
		event = events[1]
	}

	table.insert(self._hed.event_list, event_list_data)
	self:_add_world_gui(world_name, events, event_list_data)
end

-- Lines 104-143
function CoreWorldEventUnitElement:_add_world_gui(world_name, events, event_list_data)
	local panel = self._panel
	local panel_sizer = self._panel_sizer
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(h_sizer, 0, 1, "EXPAND,LEFT")

	local world_name_ctrlr = EWS:StaticText(panel, "" .. world_name, 0, "ALIGN_LEFT")

	h_sizer:add(world_name_ctrlr, 2, 1, "LEFT,ALIGN_CENTER_VERTICAL")

	local events_params = {
		ctrlr_proportions = 2,
		name_proportions = 0,
		tooltip = "Select an event from the combobox",
		sorted = true,
		sizer_proportions = 2,
		panel = panel,
		sizer = h_sizer,
		options = events,
		value = event_list_data.event
	}
	local event = CoreEws.combobox(events_params)
	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT", "Remove", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("SELECT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_entry"), event_list_data)
	toolbar:realize()
	table.insert(self._guis, {
		world_name_ctrlr = world_name_ctrlr,
		world_name = world_name,
		event = event,
		name_ctrlr = events_params.name_ctrlr,
		toolbar = toolbar
	})
	h_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	event:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_on_gui_set_event_data"), event_list_data)
	panel:layout()
end

-- Lines 145-149
function CoreWorldEventUnitElement:_on_gui_set_event_data(event_list_data)
	local guis = self:_get_guis_by_event_list_data(event_list_data)
	local event = guis.event:get_value()
	event_list_data.event = event
end

-- Lines 151-157
function CoreWorldEventUnitElement:_get_guis_by_event_list_data(event_list_data)
	for i, entry in pairs(clone(self._hed.event_list)) do
		if entry == event_list_data then
			return self._guis[i]
		end
	end
end

-- Lines 159-181
function CoreWorldEventUnitElement:remove_entry(event_list_data)
	-- Lines 160-172
	local function _remove_guis(guis)
		if guis then
			guis.world_name_ctrlr:destroy()
			guis.event:destroy()

			if guis.name_ctrlr then
				guis.name_ctrlr:destroy()
			end

			guis.toolbar:destroy()
			table.delete(self._guis, guis)
			self._panel:layout()
		end
	end

	for i, entry in pairs(clone(self._hed.event_list)) do
		if entry == event_list_data then
			table.remove(self._hed.event_list, i)
			_remove_guis(self._guis[i])

			break
		end
	end
end

-- Lines 183-185
function CoreWorldEventUnitElement:destroy_panel(...)
	CoreWorldEventUnitElement.super.destroy_panel(self, ...)
end

-- Lines 187-199
function CoreWorldEventUnitElement:_on_gui_select_world_list()
	local settings = {
		list_style = "LC_REPORT,LC_NO_HEADER,LC_SORT_ASCENDING"
	}
	local names = managers.worldcollection:world_name_ids()
	local dialog = SelectNameModal:new("Select worlds", names, settings)

	if dialog:cancelled() then
		return
	end

	for _, instance_name in ipairs(dialog:_selected_item_assets()) do
		self:_add_world_by_name(instance_name)
	end
end

-- Lines 201-221
function CoreWorldEventUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	btn_toolbar:add_tool("SELECT_UNIT_LIST", "Select unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	btn_toolbar:connect("SELECT_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_select_world_list"), nil)
	btn_toolbar:realize()
	panel_sizer:add(btn_toolbar, 0, 1, "EXPAND,LEFT")

	for _, data in pairs(clone(self._hed.event_list)) do
		local world = managers.worldcollection:world_names()[data.world_name].world
		local events = self:_get_events(world)

		self:_add_world_gui(data.world_name, events, data)
	end
end

-- Lines 223-225
function CoreWorldEventUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "_set_world_by_raycast"))
end

CoreWorldInputEventUnitElement = CoreWorldInputEventUnitElement or class(CoreWorldEventUnitElement)

-- Lines 230-232
function CoreWorldInputEventUnitElement:init(...)
	CoreWorldInputEventUnitElement.super.init(self, "input", ...)
end

CoreWorldOutputEventUnitElement = CoreWorldOutputEventUnitElement or class(CoreWorldEventUnitElement)

-- Lines 237-239
function CoreWorldOutputEventUnitElement:init(...)
	CoreWorldOutputEventUnitElement.super.init(self, "output", ...)
end

CoreWorldInputUnitElement = CoreWorldInputUnitElement or class(MissionElement)

-- Lines 245-249
function CoreWorldInputUnitElement:init(...)
	CoreWorldInputUnitElement.super.init(self, ...)

	self._hed.event = "none"

	table.insert(self._save_values, "event")
end

-- Lines 251-263
function CoreWorldInputUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local event = EWS:TextCtrl(panel, self._hed.event, "", "TE_PROCESS_ENTER")

	panel_sizer:add(event, 0, 0, "EXPAND")
	event:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "event",
		ctrlr = event
	})
	event:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "event",
		ctrlr = event
	})
end

CoreWorldOutputUnitElement = CoreWorldOutputUnitElement or class(MissionElement)

-- Lines 269-273
function CoreWorldOutputUnitElement:init(...)
	CoreWorldOutputUnitElement.super.init(self, ...)

	self._hed.event = "none"

	table.insert(self._save_values, "event")
end

-- Lines 275-287
function CoreWorldOutputUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local event = EWS:TextCtrl(panel, self._hed.event, "", "TE_PROCESS_ENTER")

	panel_sizer:add(event, 0, 0, "EXPAND")
	event:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		value = "event",
		ctrlr = event
	})
	event:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		value = "event",
		ctrlr = event
	})
end

CoreWorldSpawnerElement = CoreWorldSpawnerElement or class(MissionElement)

-- Lines 293-301
function CoreWorldSpawnerElement:init(unit)
	CoreWorldSpawnerElement.super.init(self, unit)

	self._hed.world = ""

	table.insert(self._save_values, "state")
	table.insert(self._save_values, "world")
end

-- Lines 303-317
function CoreWorldSpawnerElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local worlds = managers.worldcollection:get_all_worlds()

	table.insert(worlds, "")
	table.sort(worlds)
	self:_build_value_combobox(panel, panel_sizer, "world", worlds, "Select a world from the combobox")
	self:_add_help_text("The world that will be loaded")
end

-- Lines 319-323
function CoreWorldSpawnerElement:set_element_data(...)
	CoreWorldSpawnerElement.super.set_element_data(self, ...)
	self:_change_world()
end

-- Lines 325-329
function CoreWorldSpawnerElement:post_init()
	CoreWorldSpawnerElement.super.post_init(self)
	managers.worldcollection:register_editor_position(self._unit:unit_data().name_id, self._unit:position())
	self:_change_world()
end

-- Lines 331-355
function CoreWorldSpawnerElement:_change_world()
	if self._low_poly_unit then
		World:delete_unit(self._low_poly_unit)

		self._low_poly_unit = nil
	end

	local world_meta_data = managers.worldcollection:get_world_meta_data(self._hed.world)

	if world_meta_data then
		if world_meta_data.low_poly and world_meta_data.low_poly ~= "" then
			self._low_poly_unit = CoreUnit.safe_spawn_unit(world_meta_data.low_poly, self._unit:position(), self._unit:rotation())

			self._unit:link(Idstring("rp_worlds"), self._low_poly_unit)
		end

		managers.worldcollection:register_editor_name(self._unit:unit_data().name_id, self._hed.world)
	else
		self._hed.world = nil

		managers.worldcollection:register_editor_name(self._unit:unit_data().name_id)

		if self._low_poly_unit then
			World:delete_unit(self._low_poly_unit)

			self._low_poly_unit = nil
		end
	end
end

-- Lines 357-363
function CoreWorldSpawnerElement:destroy()
	if alive(self._low_poly_unit) then
		World:delete_unit(self._low_poly_unit)

		self._low_poly_unit = nil
	end

	CoreWorldSpawnerElement.super.destroy(self)
end

-- Lines 365-370
function CoreWorldSpawnerElement:set_disabled()
	if self._low_poly_unit then
		self._low_poly_unit:set_visible(false)
	end

	CoreWorldSpawnerElement.super.set_disabled(self)
end

-- Lines 372-377
function CoreWorldSpawnerElement:set_enabled()
	if self._low_poly_unit then
		self._low_poly_unit:set_visible(true)
	end

	CoreWorldSpawnerElement.super.set_enabled(self)
end

-- Lines 379-390
function CoreWorldSpawnerElement:on_name_changed(old_name, new_name)
	Application:debug("[CoreWorldSpawnerElement:on_name_changed]", old_name, new_name)

	local mission_units = managers.editor:layer("Mission"):get_created_unit_by_pattern({
		"func_world_input_event",
		"func_world_output_event",
		"func_world_point",
		"func_world_set_params"
	})

	for _, mission_unit in ipairs(mission_units) do
		if mission_unit:mission_element().on_world_changed_name then
			mission_unit:mission_element():on_world_changed_name(old_name, new_name)
		elseif mission_unit:mission_element_data().world == old_name then
			self._hed.world = new_name
		end
	end

	managers.worldcollection:on_editor_changed_name(old_name, new_name)
end

-- Lines 392-402
function CoreWorldSpawnerElement:on_world_deleted()
	Application:debug("[CoreWorldSpawnerElement:on_world_deleted()]")

	local editor_name = self._unit:unit_data().name_id
	local mission_units = managers.editor:layer("Mission"):get_created_unit_by_pattern({
		"func_world_input_event",
		"func_world_output_event",
		"func_world_set_params"
	})

	for _, mission_unit in ipairs(mission_units) do
		if mission_unit:mission_element().on_world_deleted then
			mission_unit:mission_element():on_world_deleted(editor_name)
		end
	end

	managers.worldcollection:unregister_editor_name(editor_name)
end
