CoreMissionElement = CoreMissionElement or class()
MissionElement = MissionElement or class(CoreMissionElement)
MissionElement.SAVE_UNIT_POSITION = true
MissionElement.SAVE_UNIT_ROTATION = true
MissionElement.RANDOMS = nil

-- Lines 10-12
function MissionElement:init(...)
	CoreMissionElement.init(self, ...)
end

-- Lines 16-51
function CoreMissionElement:init(unit)
	if not CoreMissionElement.editor_link_brush then
		local brush = Draw:brush()

		brush:set_font(Idstring("core/fonts/nice_editor_font"), 10)
		brush:set_render_template(Idstring("OverlayVertexColorTextured"))

		CoreMissionElement.editor_link_brush = brush
	end

	self._unit = unit
	self._hed = self._unit:mission_element_data()
	self._ud = self._unit:unit_data()

	self._unit:anim_play(1)

	self._save_values = {}
	self._update_selected_on = false

	self:_add_default_saves()

	if self.USES_POINT_ORIENTATION then
		self.base_update_editing = callback(self, self, "__update_editing")
	end

	self._parent_panel = managers.editor:mission_element_panel()
	self._parent_sizer = managers.editor:mission_element_sizer()
	self._panels = {}
	self._on_executed_units = {}
	self._arrow_brush = Draw:brush()

	self:_createicon()
end

-- Lines 53-62
function CoreMissionElement:post_init()
	if self.RANDOMS then
		for _, value_name in ipairs(self.RANDOMS) do
			if tonumber(self._hed[value_name]) then
				self._hed[value_name] = {
					self._hed[value_name],
					0
				}
			end
		end
	end
end

-- Lines 68-119
function CoreMissionElement:_createicon()
	local iconsize = 32

	if Global.iconsize then
		iconsize = Global.iconsize
	end

	if self._icon == nil and self._icon_x == nil then
		return
	end

	local root = self._unit:orientation_object()

	if root == nil then
		return
	end

	if self._iconcolor_type then
		if self._iconcolor_type == "trigger" then
			self._iconcolor = "ff81bffc"
		elseif self._iconcolor_type == "logic" then
			self._iconcolor = "ffffffd9"
		elseif self._iconcolor_type == "operator" then
			self._iconcolor = "fffcbc7c"
		elseif self._iconcolor_type == "filter" then
			self._iconcolor = "ff65ad67"
		end
	end

	if self._iconcolor == nil then
		self._iconcolor = "fff"
	end

	self._iconcolor_c = Color(self._iconcolor)
	self._icon_gui = World:newgui()
	local pos = self._unit:position() - Vector3(iconsize / 2, iconsize / 2, 0)
	self._icon_ws = self._icon_gui:create_linked_workspace(64, 64, root, pos, Vector3(iconsize, 0, 0), Vector3(0, iconsize, 0))

	self._icon_ws:set_billboard(self._icon_ws.BILLBOARD_BOTH)
	self._icon_ws:panel():gui(Idstring("core/guis/core_edit_icon"))

	self._icon_script = self._icon_ws:panel():gui(Idstring("core/guis/core_edit_icon")):script()

	if self._icon then
		self._icon_script:seticon(self._icon, tostring(self._iconcolor))
	elseif self._icon_x then
		self._icon_script:seticon_texture_rect(self._icon_x, self._icon_y, self._icon_w, self._icon_h, tostring(self._iconcolor))
	end
end

-- Lines 121-128
function CoreMissionElement:set_iconsize(size)
	if not self._icon_ws then
		return
	end

	local root = self._unit:orientation_object()
	local pos = self._unit:position() - Vector3(size / 2, size / 2, 0)

	self._icon_ws:set_linked(64, 64, root, pos, Vector3(size, 0, 0), Vector3(0, size, 0))
end

-- Lines 131-171
function CoreMissionElement:_add_default_saves()
	self._hed.enabled = true
	self._hed.debug = nil
	self._hed.execute_on_startup = false
	self._hed.execute_on_startup_priority = 100
	self._hed.execute_on_restart = nil
	self._hed.base_delay = 0
	self._hed.base_delay_rand = nil
	self._hed.trigger_times = 0
	self._hed.on_executed = {}

	if self.USES_POINT_ORIENTATION then
		self._hed.orientation_elements = nil
		self._hed.use_orientation_sequenced = nil
		self._hed.disable_orientation_on_use = nil
	end

	if self.USES_INSTIGATOR_RULES then
		self._hed.rules_elements = nil
	end

	if self.INSTANCE_VAR_NAMES then
		self._hed.instance_var_names = nil
	end

	table.insert(self._save_values, "unit:position")
	table.insert(self._save_values, "unit:rotation")
	table.insert(self._save_values, "enabled")
	table.insert(self._save_values, "execute_on_startup")
	table.insert(self._save_values, "execute_on_startup_priority")
	table.insert(self._save_values, "base_delay")
	table.insert(self._save_values, "trigger_times")
	table.insert(self._save_values, "on_executed")
	table.insert(self._save_values, "orientation_elements")
	table.insert(self._save_values, "use_orientation_sequenced")
	table.insert(self._save_values, "disable_orientation_on_use")
	table.insert(self._save_values, "rules_elements")
	table.insert(self._save_values, "instance_var_names")
end

-- Lines 173-306
function CoreMissionElement:build_default_gui(panel, sizer)
	self:_build_value_checkbox(panel, sizer, "enabled")
	self:_build_value_checkbox(panel, sizer, "execute_on_startup")
	self:_build_value_number(panel, sizer, "execute_on_startup_priority", {
		floats = 0,
		min = 0
	}, "Specifies priority if this element is executed on startup (lower number means faster execution)")
	self:_build_value_number(panel, sizer, "trigger_times", {
		floats = 0,
		min = 0
	}, "Specifies how many time this element can be executed (0 mean unlimited times)")

	local base_delay_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(base_delay_sizer, 0, 0, "EXPAND,LEFT")

	local base_delay_ctrlr = self:_build_value_number(panel, base_delay_sizer, "base_delay", {
		sizer_proportions = 2,
		min = 0,
		floats = 2,
		name_proportions = 1,
		ctrlr_proportions = 1
	}, "Specifies a base delay that is added to each on executed delay")
	local base_delay_rand_ctrlr = self:_build_value_number(panel, base_delay_sizer, "base_delay_rand", {
		sizer_proportions = 1,
		min = 0,
		floats = 2,
		name_proportions = 0,
		ctrlr_proportions = 1
	}, "Specifies an additional random time to be added to base delay (delay + rand)", "  random")
	local on_executed_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "On Executed")
	local element_sizer = EWS:BoxSizer("HORIZONTAL")

	on_executed_sizer:add(element_sizer, 0, 1, "EXPAND,LEFT")

	self._elements_params = {
		name = "Element:",
		name_proportions = 1,
		tooltip = "Select an element from the combobox",
		sorted = true,
		sizer_proportions = 1,
		ctrlr_proportions = 2,
		panel = panel,
		sizer = element_sizer,
		options = {}
	}
	local elements = CoreEWS.combobox(self._elements_params)

	elements:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "on_executed_element_selected"), nil)

	self._add_elements_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._add_elements_toolbar:add_tool("ADD_ELEMENT", "Add an element", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._add_elements_toolbar:connect("ADD_ELEMENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_toolbar_add_element"), nil)
	self._add_elements_toolbar:realize()
	element_sizer:add(self._add_elements_toolbar, 0, 1, "EXPAND,LEFT")

	self._elements_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._elements_toolbar:add_tool("DELETE_SELECTED", "Remove selected element", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	self._elements_toolbar:connect("DELETE_SELECTED", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_toolbar_remove"), nil)
	self._elements_toolbar:realize()
	element_sizer:add(self._elements_toolbar, 0, 1, "EXPAND,LEFT")

	if not self.ON_EXECUTED_ALTERNATIVES and self._create_dynamic_on_executed_alternatives then
		self:_create_dynamic_on_executed_alternatives()
	end

	if self.ON_EXECUTED_ALTERNATIVES then
		local on_executed_alternatives_params = {
			name = "Alternative:",
			name_proportions = 1,
			tooltip = "Select an alternative on executed from the combobox",
			sorted = false,
			ctrlr_proportions = 2,
			panel = panel,
			sizer = on_executed_sizer,
			options = self.ON_EXECUTED_ALTERNATIVES,
			value = self.ON_EXECUTED_ALTERNATIVES[1]
		}
		local on_executed_alternatives_types = CoreEws.combobox(on_executed_alternatives_params)

		on_executed_alternatives_types:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "on_executed_alternatives_types"), nil)

		self._on_executed_alternatives_params = on_executed_alternatives_params
	end

	local delay_sizer = EWS:BoxSizer("HORIZONTAL")

	on_executed_sizer:add(delay_sizer, 0, 0, "EXPAND,LEFT")

	self._element_delay_params = {
		value = 0,
		name = "Delay:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Sets the delay time for the selected on executed element",
		min = 0,
		floats = 2,
		sizer_proportions = 2,
		panel = panel,
		sizer = delay_sizer
	}
	local element_delay = CoreEws.number_controller(self._element_delay_params)

	element_delay:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_executed_element_delay"), nil)
	element_delay:connect("EVT_KILL_FOCUS", callback(self, self, "on_executed_element_delay"), nil)

	self._element_delay_rand_params = {
		value = 0,
		name = "  Random:",
		ctrlr_proportions = 1,
		name_proportions = 0,
		tooltip = "Specifies an additional random time to be added to delay (delay + rand)",
		min = 0,
		floats = 2,
		sizer_proportions = 1,
		panel = panel,
		sizer = delay_sizer
	}
	local element_delay_rand = CoreEws.number_controller(self._element_delay_rand_params)

	element_delay_rand:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "on_executed_element_delay_rand"), nil)
	element_delay_rand:connect("EVT_KILL_FOCUS", callback(self, self, "on_executed_element_delay_rand"), nil)
	sizer:add(on_executed_sizer, 0, 0, "EXPAND")

	if self.USES_POINT_ORIENTATION then
		sizer:add(self:_build_point_orientation(panel), 0, 0, "EXPAND")
	end

	if self.INSTANCE_VAR_NAMES then
		sizer:add(self:_build_instance_var_names(panel), 0, 0, "EXPAND")
	end

	sizer:add(EWS:StaticLine(panel, "", "LI_HORIZONTAL"), 0, 5, "EXPAND,TOP,BOTTOM")
	self:append_elements_sorted()
	self:set_on_executed_element()

	-- Lines 297-301
	local function refresh_list_flow_cbk(ctrlr)
		-- Lines 298-298
		local function f()
			managers.editor:layer("Mission"):refresh_list_flow()
		end

		ctrlr:connect("EVT_COMMAND_TEXT_ENTER", f, nil)
		ctrlr:connect("EVT_KILL_FOCUS", f, nil)
	end

	refresh_list_flow_cbk(base_delay_ctrlr)
	refresh_list_flow_cbk(base_delay_rand_ctrlr)
	refresh_list_flow_cbk(element_delay)
	refresh_list_flow_cbk(element_delay_rand)
end

-- Lines 308-333
function CoreMissionElement:_build_point_orientation(panel)
	local sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "Point orientation")
	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("ADD_ELEMENT", "Add an element", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("ADD_ELEMENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_add_unit_to_orientation_elements"), nil)
	toolbar:add_tool("DELETE_ELEMENT", "Remove selected element", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("DELETE_ELEMENT", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_remove_unit_from_orientation_elements"), nil)
	toolbar:realize()
	sizer:add(toolbar, 0, 1, "EXPAND,LEFT")

	local use_orientation_sequenced = EWS:CheckBox(panel, "Use sequenced", "")

	use_orientation_sequenced:set_value(self._hed.use_orientation_sequenced)
	use_orientation_sequenced:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "use_orientation_sequenced",
		ctrlr = use_orientation_sequenced
	})
	sizer:add(use_orientation_sequenced, 0, 4, "EXPAND,LEFT")

	local disable_orientation_on_use = EWS:CheckBox(panel, "Disable on use", "")

	disable_orientation_on_use:set_value(self._hed.disable_orientation_on_use)
	disable_orientation_on_use:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		value = "disable_orientation_on_use",
		ctrlr = disable_orientation_on_use
	})
	sizer:add(disable_orientation_on_use, 0, 4, "EXPAND,LEFT")

	return sizer
end

-- Lines 335-355
function CoreMissionElement:_add_unit_to_orientation_elements()
	local script = self._unit:mission_element_data().script

	-- Lines 337-349
	local function f(unit)
		if not string.find(unit:name():s(), "point_orientation", 1, true) then
			return
		end

		if not unit:mission_element_data() or unit:mission_element_data().script ~= script then
			return
		end

		local id = unit:unit_data().unit_id

		if self._hed.orientation_elements and table.contains(self._hed.orientation_elements, id) then
			return false
		end

		return managers.editor:layer("Mission"):category_map()[unit:type():s()]
	end

	local dialog = SelectUnitByNameModal:new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		self:_add_orientation_unit_id(unit:unit_data().unit_id)
	end
end

-- Lines 357-367
function CoreMissionElement:_remove_unit_from_orientation_elements()
	if not self._hed.orientation_elements then
		return
	end

	-- Lines 361-361
	local function f(unit)
		return table.contains(self._hed.orientation_elements, unit:unit_data().unit_id)
	end

	local dialog = SelectUnitByNameModal:new("Remove Unit", f)

	if dialog:cancelled() then
		return
	end

	for _, unit in ipairs(dialog:selected_units()) do
		self:_remove_orientation_unit_id(unit:unit_data().unit_id)
	end
end

-- Lines 369-402
function CoreMissionElement:_build_instance_var_names(panel)
	local sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "Instance variables")
	local options = {}
	local func_instance_params_units = managers.editor:layer("Mission"):get_created_unit_by_pattern({
		"func_instance_params"
	})

	for _, unit in ipairs(func_instance_params_units) do
		for _, param in ipairs(unit:mission_element_data().params) do
			options[param.type] = options[param.type] or {}

			table.insert(options[param.type], param.var_name)
		end
	end

	for _, data in ipairs(self.INSTANCE_VAR_NAMES) do
		local params = {
			default = "not_used",
			ctrlr_proportions = 2,
			name_proportions = 1,
			sizer_proportions = 1,
			tooltip = "Select a value",
			sorted = true,
			name = string.pretty(data.value, true) .. ":",
			panel = panel,
			sizer = sizer,
			options = options[data.type] or {},
			value = self._hed.instance_var_names and self._hed.instance_var_names[data.value] or "not_used"
		}
		local ctrlr = CoreEws.combobox(params)

		ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_instance_var_name"), {
			ctrlr = ctrlr,
			data = data
		})
	end

	return sizer
end

-- Lines 404-410
function CoreMissionElement:_set_instance_var_name(params)
	local value = params.ctrlr:get_value()
	value = value ~= "not_used" and value or nil
	self._hed.instance_var_names = self._hed.instance_var_names or {}
	self._hed.instance_var_names[params.data.value] = value
	self._hed.instance_var_names = next(self._hed.instance_var_names) and self._hed.instance_var_names or nil
end

-- Lines 413-430
function CoreMissionElement:_create_panel()
	if self._panel then
		return
	end

	self._panel, self._panel_sizer = self:_add_panel(self._parent_panel, self._parent_sizer)
end

-- Lines 435-438
function CoreMissionElement:_build_panel()
	self:_create_panel()
end

-- Lines 442-456
function CoreMissionElement:panel(id, parent, parent_sizer)
	if id then
		if self._panels[id] then
			return self._panels[id]
		end

		local panel, panel_sizer = self:_add_panel(parent, parent_sizer)

		self:_build_panel(panel, panel_sizer)

		self._panels[id] = panel

		return self._panels[id]
	end

	if not self._panel then
		self:_build_panel()
	end

	return self._panel
end

-- Lines 458-476
function CoreMissionElement:_add_panel(parent, parent_sizer)
	local panel = EWS:ScrolledWindow(parent, "", "VSCROLL,TAB_TRAVERSAL")

	panel:set_scroll_rate(Vector3(0, 20, 0))
	panel:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))

	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)
	parent_sizer:add(panel, 1, 0, "EXPAND")
	panel:set_visible(false)
	panel:set_extension({
		alive = true
	})
	self:build_default_gui(panel, panel_sizer)

	return panel, panel_sizer
end

-- Lines 483-487
function CoreMissionElement:add_help_text(data)
	if data.panel and data.sizer then
		data.sizer:add(EWS:TextCtrl(data.panel, data.text, 0, "TE_MULTILINE,TE_READONLY,TE_WORDWRAP,TE_CENTRE"), 0, 5, "EXPAND,TOP,BOTTOM")
	end
end

-- Lines 489-492
function CoreMissionElement:_add_help_text(text)
	local help = {
		panel = self._panel,
		sizer = self._panel_sizer,
		text = text
	}

	self:add_help_text(help)
end

-- Lines 495-501
function CoreMissionElement:_on_toolbar_add_element()
	-- Lines 496-496
	local function f(unit)
		return unit:type() == Idstring("mission_element") and unit ~= self._unit
	end

	local dialog = SelectUnitByNameModal:new("Add/Remove element", f)

	for _, unit in ipairs(dialog:selected_units()) do
		self:add_on_executed(unit)
	end
end

-- Lines 504-506
function CoreMissionElement:_on_toolbar_remove()
	self:remove_on_execute(self:_current_element_unit())
end

-- Lines 510-537
function CoreMissionElement:set_element_data(data)
	if data.callback then
		local he = self._unit:mission_element()

		he[data.callback](he, data.ctrlr, data.params)
	end

	if data.value then
		self._hed[data.value] = data.ctrlr:get_value()
		self._hed[data.value] = tonumber(self._hed[data.value]) or self._hed[data.value]

		if data.value == "base_delay_rand" then
			self._hed[data.value] = self._hed[data.value] > 0 and self._hed[data.value] or nil
		end

		if EWS:get_key_state("K_CONTROL") then
			local value = tonumber(self._hed[data.value]) or self._hed[data.value]

			for _, unit in ipairs(managers.editor:layer("Mission"):selected_units()) do
				if unit ~= self._unit and unit:mission_element_data() then
					unit:mission_element_data()[data.value] = value

					unit:mission_element():set_panel_dirty()
				end
			end
		end
	end
end

-- Lines 539-546
function CoreMissionElement:set_panel_dirty()
	if not alive(self._panel) then
		return
	end

	self._panel:destroy()

	self._panel = nil
end

-- Lines 549-551
function CoreMissionElement:selected()
	self:append_elements_sorted()
end

-- Lines 554-555
function CoreMissionElement:update_selected()
end

-- Lines 558-559
function CoreMissionElement:update_unselected()
end

-- Lines 561-563
function CoreMissionElement:can_edit()
	return self.update_editing or self.base_update_editing
end

-- Lines 565-567
function CoreMissionElement:begin_editing()
end

-- Lines 569-571
function CoreMissionElement:end_editing()
end

-- Lines 574-578
function CoreMissionElement:clone_data(all_units)
	for _, data in ipairs(self._hed.on_executed) do
		table.insert(self._on_executed_units, all_units[data.id])
	end
end

-- Lines 594-599
function CoreMissionElement:layer_finished()
	for _, data in ipairs(self._hed.on_executed) do
		local unit = managers.worlddefinition:get_mission_element_unit(data.id)

		table.insert(self._on_executed_units, unit)
	end
end

-- Lines 603-605
function CoreMissionElement:save_data(file, t)
	self:save_values(file, t)
end

-- Lines 608-615
function CoreMissionElement:save_values(file, t)
	t = t .. "\t"

	file:puts(t .. "<values>")

	for _, name in ipairs(self._save_values) do
		self:save_value(file, t, name)
	end

	file:puts(t .. "</values>")
end

-- Lines 618-621
function CoreMissionElement:save_value(file, t, name)
	t = t .. "\t"

	file:puts(save_value_string(self._hed, name, t, self._unit))
end

-- Lines 623-649
function CoreMissionElement:new_save_values()
	local t = {
		position = self.SAVE_UNIT_POSITION and self._unit:position() or nil,
		rotation = self.SAVE_UNIT_ROTATION and self._unit:rotation() or nil
	}

	for _, value in ipairs(self._save_values) do
		t[value] = self._hed[value]
	end

	t.base_delay_rand = self._hed.base_delay_rand and self._hed.base_delay_rand > 0 and self._hed.base_delay_rand or nil

	if self.save then
		self:save(t)
	end

	if self.RANDOMS then
		for _, value_name in ipairs(self.RANDOMS) do
			if t[value_name][2] == 0 then
				t[value_name] = t[value_name][1]
			end
		end
	end

	return t
end

-- Lines 651-653
function CoreMissionElement:name()
	return self._unit:name() .. self._ud.unit_id
end

-- Lines 656-657
function CoreMissionElement:add_to_mission_package()
end

-- Lines 660-669
function CoreMissionElement:get_color(type)
	if type then
		if type == "activate" or type == "enable" then
			return 0, 1, 0
		elseif type == "deactivate" or type == "disable" then
			return 1, 0, 0
		end
	end

	return 0, 1, 0
end

-- Lines 672-683
function CoreMissionElement:draw_links_selected(t, dt, selected_unit)
	local unit = self:_current_element_unit()

	if alive(unit) then
		local r = 1
		local g = 1
		local b = 1

		if self._iconcolor and managers.editor:layer("Mission"):use_colored_links() then
			r = self._iconcolor_c.r
			g = self._iconcolor_c.g
			b = self._iconcolor_c.b
		end

		self:_draw_link({
			thick = true,
			from_unit = self._unit,
			to_unit = unit,
			r = r,
			g = g,
			b = b
		})
	end
end

-- Lines 685-688
function CoreMissionElement:_draw_link(params)
	params.draw_flow = managers.editor:layer("Mission"):visualize_flow()

	Application:draw_link(params)
end

-- Lines 691-693
function CoreMissionElement:draw_links_unselected()
end

-- Lines 698-699
function CoreMissionElement:clear()
end

-- Lines 703-705
function CoreMissionElement:action_types()
	return self._action_types
end

-- Lines 707-709
function CoreMissionElement:timeline_color()
	return self._timeline_color
end

-- Lines 712-713
function CoreMissionElement:add_triggers(vc)
end

-- Lines 716-723
function CoreMissionElement:base_add_triggers(vc)
	if self.USES_POINT_ORIENTATION then
		vc:add_trigger(Idstring("lmb"), callback(self, self, "_on_use_point_orientation"))
	end

	if self.USES_INSTIGATOR_RULES then
		vc:add_trigger(Idstring("lmb"), callback(self, self, "_on_use_instigator_rule"))
	end
end

-- Lines 726-739
function CoreMissionElement:_on_use_point_orientation()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "point_orientation", 1, true) then
		local id = ray.unit:unit_data().unit_id

		if self._hed.orientation_elements and table.contains(self._hed.orientation_elements, id) then
			self:_remove_orientation_unit_id(id)
		else
			self:_add_orientation_unit_id(id)
		end
	end
end

-- Lines 741-744
function CoreMissionElement:_add_orientation_unit_id(id)
	self._hed.orientation_elements = self._hed.orientation_elements or {}

	table.insert(self._hed.orientation_elements, id)
end

-- Lines 746-749
function CoreMissionElement:_remove_orientation_unit_id(id)
	table.delete(self._hed.orientation_elements, id)

	self._hed.orientation_elements = #self._hed.orientation_elements > 0 and self._hed.orientation_elements or nil
end

-- Lines 752-765
function CoreMissionElement:_on_use_instigator_rule()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 10
	})

	if ray and ray.unit and string.find(ray.unit:name():s(), "data_instigator_rule", 1, true) then
		local id = ray.unit:unit_data().unit_id

		if self._hed.rules_elements and table.contains(self._hed.rules_elements, id) then
			self:_remove_instigator_rule_unit_id(id)
		else
			self:_add_instigator_rule_unit_id(id)
		end
	end
end

-- Lines 767-770
function CoreMissionElement:_add_instigator_rule_unit_id(id)
	self._hed.rules_elements = self._hed.rules_elements or {}

	table.insert(self._hed.rules_elements, id)
end

-- Lines 772-775
function CoreMissionElement:_remove_instigator_rule_unit_id(id)
	table.delete(self._hed.rules_elements, id)

	self._hed.rules_elements = #self._hed.rules_elements > 0 and self._hed.rules_elements or nil
end

-- Lines 777-780
function CoreMissionElement:__update_editing(_, t, dt, current_pos)
end

-- Lines 783-784
function CoreMissionElement:clear_triggers()
end

-- Lines 787-789
function CoreMissionElement:widget_affect_object()
	return nil
end

-- Lines 792-794
function CoreMissionElement:use_widget_position()
	return nil
end

-- Lines 799-803
function CoreMissionElement:set_enabled()
	if self._icon_ws then
		self._icon_ws:show()
	end
end

-- Lines 808-812
function CoreMissionElement:set_disabled()
	if self._icon_ws then
		self._icon_ws:hide()
	end
end

-- Lines 815-823
function CoreMissionElement:on_set_visible(visible)
	if self._icon_ws then
		if visible then
			self._icon_ws:show()
		else
			self._icon_ws:hide()
		end
	end
end

-- Lines 826-828
function CoreMissionElement:set_update_selected_on(value)
	self._update_selected_on = value
end

-- Lines 831-833
function CoreMissionElement:update_selected_on()
	return self._update_selected_on
end

-- Lines 836-842
function CoreMissionElement:destroy_panel()
	if self._panel then
		self._panel:extension().alive = false

		self._panel:destroy()

		self._panel = nil
	end
end

-- Lines 845-858
function CoreMissionElement:destroy()
	if self._timeline then
		self._timeline:destroy()
	end

	if self._panel then
		self._panel:extension().alive = false

		self._panel:destroy()
	end

	if self._icon_ws and alive(self._icon_gui) and alive(self._icon_ws) then
		self._icon_gui:destroy_workspace(self._icon_ws)

		self._icon_ws = nil
	end
end

-- Lines 862-868
function CoreMissionElement:draw_links(t, dt, selected_unit, all_units)
	self:_base_check_removed_units(all_units)
	self:draw_link_on_executed(t, dt, selected_unit)
	self:_draw_elements(t, dt, self._hed.orientation_elements, selected_unit, all_units)
	self:_draw_elements(t, dt, self._hed.rules_elements, selected_unit, all_units)
end

-- Lines 870-888
function CoreMissionElement:_base_check_removed_units(all_units)
	if self._hed.orientation_elements then
		for _, id in ipairs(clone(self._hed.orientation_elements)) do
			local unit = all_units[id]

			if not alive(unit) then
				self:_remove_orientation_unit_id(id)
			end
		end
	end

	if self._hed.rules_elements then
		for _, id in ipairs(clone(self._hed.rules_elements)) do
			local unit = all_units[id]

			if not alive(unit) then
				self:_remove_instigator_rule_unit_id(id)
			end
		end
	end
end

-- Lines 890-903
function CoreMissionElement:_draw_elements(t, dt, elements, selected_unit, all_units)
	if not elements then
		return
	end

	for _, id in ipairs(elements) do
		local unit = all_units[id]

		if self:_should_draw_link(selected_unit, unit) then
			local r, g, b = unit:mission_element():get_link_color()

			self:_draw_link({
				from_unit = unit,
				to_unit = self._unit,
				r = r,
				g = g,
				b = b
			})
		end
	end
end

-- Lines 922-924
function CoreMissionElement:_should_draw_link(selected_unit, unit)
	return not selected_unit or unit == selected_unit or self._unit == selected_unit
end

-- Lines 926-934
function CoreMissionElement:get_link_color(unit)
	local r = 1
	local g = 1
	local b = 1

	if self._iconcolor and managers.editor:layer("Mission"):use_colored_links() then
		r = self._iconcolor_c.r
		g = self._iconcolor_c.g
		b = self._iconcolor_c.b
	end

	return r, g, b
end

-- Lines 936-963
function CoreMissionElement:draw_link_on_executed(t, dt, selected_unit)
	local unit_sel = self._unit == selected_unit

	CoreMissionElement.editor_link_brush:set_color(unit_sel and Color.green or Color.white)

	for _, unit in ipairs(self._on_executed_units) do
		if not selected_unit or unit_sel or unit == selected_unit then
			local dir = mvector3.copy(unit:position())

			mvector3.subtract(dir, self._unit:position())

			local vec_len = mvector3.normalize(dir)
			local offset = math.min(50, vec_len)

			mvector3.multiply(dir, offset)

			if self._distance_to_camera < 1000000 then
				local text = self:_get_delay_string(unit:unit_data().unit_id)
				local alternative = self:_get_on_executed(unit:unit_data().unit_id).alternative

				if alternative then
					text = text .. " - " .. alternative .. ""
				end

				CoreMissionElement.editor_link_brush:center_text(self._unit:position() + dir, text, managers.editor:camera_rotation():x(), -managers.editor:camera_rotation():z())
			end

			local r, g, b = self:get_link_color()

			self:_draw_link({
				from_unit = self._unit,
				to_unit = unit,
				r = r * 0.75,
				g = g * 0.75,
				b = b * 0.75
			})
		end
	end
end

-- Lines 965-974
function CoreMissionElement:_get_delay_string(unit_id)
	local delay = self._hed.base_delay + self:_get_on_executed(unit_id).delay
	local text = string.format("%.2f", delay)

	if self._hed.base_delay_rand or self:_get_on_executed(unit_id).delay_rand then
		local delay_max = delay + (self:_get_on_executed(unit_id).delay_rand or 0)
		delay_max = delay_max + (self._hed.base_delay_rand and self._hed.base_delay_rand or 0)
		text = text .. "-" .. string.format("%.2f", delay_max) .. ""
	end

	return text
end

-- Lines 978-994
function CoreMissionElement:add_on_executed(unit)
	if self:remove_on_execute(unit) then
		return
	end

	local params = {
		delay = 0,
		id = unit:unit_data().unit_id,
		alternative = self.ON_EXECUTED_ALTERNATIVES and self.ON_EXECUTED_ALTERNATIVES[1] or nil
	}

	table.insert(self._on_executed_units, unit)
	table.insert(self._hed.on_executed, params)

	if self._timeline then
		self._timeline:add_element(unit, params)
	end

	self:append_elements_sorted()
	self:set_on_executed_element(unit)
end

-- Lines 996-998
function CoreMissionElement:remove_links(unit)
end

-- Lines 1003-1016
function CoreMissionElement:remove_on_execute(unit)
	for _, on_executed in ipairs(self._hed.on_executed) do
		if on_executed.id == unit:unit_data().unit_id then
			if self._timeline then
				self._timeline:remove_element(on_executed)
			end

			table.delete(self._hed.on_executed, on_executed)
			table.delete(self._on_executed_units, unit)
			self:append_elements_sorted()

			return true
		end
	end

	return false
end

-- Lines 1021-1027
function CoreMissionElement:delete_unit(units)
	local id = self._unit:unit_data().unit_id

	for _, unit in ipairs(units) do
		unit:mission_element():remove_on_execute(self._unit)
		unit:mission_element():remove_links(self._unit)
	end
end

-- Lines 1033-1047
function CoreMissionElement:set_on_executed_element(unit, id)
	unit = unit or self:on_execute_unit_by_id(id)

	if not alive(unit) then
		self:_set_on_execute_ctrlrs_enabled(false)
		self:_set_first_executed_element()

		return
	end

	self:_set_on_execute_ctrlrs_enabled(true)

	if self._elements_params then
		local name = self:combobox_name(unit)

		CoreEWS.change_combobox_value(self._elements_params, name)
		self:set_on_executed_data()
	end
end

-- Lines 1050-1061
function CoreMissionElement:set_on_executed_data()
	local id = self:combobox_id(self._elements_params.value)
	local params = self:_get_on_executed(id)

	CoreEWS.change_entered_number(self._element_delay_params, params.delay)
	CoreEWS.change_entered_number(self._element_delay_rand_params, params.delay_rand or 0)

	if self._on_executed_alternatives_params then
		CoreEWS.change_combobox_value(self._on_executed_alternatives_params, params.alternative)
	end

	if self._timeline then
		self._timeline:select_element(params)
	end
end

-- Lines 1064-1068
function CoreMissionElement:_set_first_executed_element()
	if #self._hed.on_executed > 0 then
		self:set_on_executed_element(nil, self._hed.on_executed[1].id)
	end
end

-- Lines 1071-1083
function CoreMissionElement:_set_on_execute_ctrlrs_enabled(enabled)
	if not self._elements_params then
		return
	end

	self._elements_params.ctrlr:set_enabled(enabled)
	self._element_delay_params.number_ctrlr:set_enabled(enabled)
	self._element_delay_rand_params.number_ctrlr:set_enabled(enabled)
	self._elements_toolbar:set_enabled(enabled)

	if self._on_executed_alternatives_params then
		self._on_executed_alternatives_params.ctrlr:set_enabled(enabled)
	end
end

-- Lines 1086-1088
function CoreMissionElement:on_executed_element_selected()
	self:set_on_executed_data()
end

-- Lines 1091-1097
function CoreMissionElement:_get_on_executed(id)
	for _, params in ipairs(self._hed.on_executed) do
		if params.id == id then
			return params
		end
	end
end

-- Lines 1100-1105
function CoreMissionElement:_current_element_id()
	if not self._elements_params or not self._elements_params.value then
		return nil
	end

	return self:combobox_id(self._elements_params.value)
end

-- Lines 1108-1118
function CoreMissionElement:_current_element_unit()
	local id = self:_current_element_id()

	if not id then
		return nil
	end

	local unit = self:on_execute_unit_by_id(id)

	if not alive(unit) then
		return nil
	end

	return unit
end

-- Lines 1121-1128
function CoreMissionElement:on_executed_element_delay()
	local id = self:combobox_id(self._elements_params.value)
	local params = self:_get_on_executed(id)
	params.delay = self._element_delay_params.value

	if self._timeline then
		self._timeline:delay_updated(params)
	end
end

-- Lines 1131-1135
function CoreMissionElement:on_executed_element_delay_rand()
	local id = self:combobox_id(self._elements_params.value)
	local params = self:_get_on_executed(id)
	params.delay_rand = self._element_delay_rand_params.value > 0 and self._element_delay_rand_params.value or nil
end

-- Lines 1138-1143
function CoreMissionElement:on_executed_alternatives_types()
	local id = self:combobox_id(self._elements_params.value)
	local params = self:_get_on_executed(id)

	print("self._on_executed_alternatives_params.value", self._on_executed_alternatives_params.value)

	params.alternative = self._on_executed_alternatives_params.value
end

-- Lines 1146-1154
function CoreMissionElement:append_elements_sorted()
	if not self._elements_params then
		return
	end

	local id = self:_current_element_id()

	CoreEWS.update_combobox_options(self._elements_params, self:_combobox_names_names(self._on_executed_units))
	self:set_on_executed_element(nil, id)
end

-- Lines 1157-1159
function CoreMissionElement:combobox_name(unit)
	return unit:unit_data().name_id .. " (" .. unit:unit_data().unit_id .. ")"
end

-- Lines 1162-1173
function CoreMissionElement:combobox_id(name)
	local s = nil
	local e = string.len(name) - 1

	for i = string.len(name), 0, -1 do
		local t = string.sub(name, i, i)

		if t == "(" then
			s = i + 1

			break
		end
	end

	return tonumber(string.sub(name, s, e))
end

-- Lines 1176-1183
function CoreMissionElement:on_execute_unit_by_id(id)
	for _, unit in ipairs(self._on_executed_units) do
		if unit:unit_data().unit_id == id then
			return unit
		end
	end

	return nil
end

-- Lines 1186-1192
function CoreMissionElement:_combobox_names_names(units)
	local names = {}

	for _, unit in ipairs(units) do
		table.insert(names, self:combobox_name(unit))
	end

	return names
end

-- Lines 1195-1202
function CoreMissionElement:on_timeline()
	if not self._timeline then
		self._timeline = MissionElementTimeline:new(self._unit:unit_data().name_id)

		self._timeline:set_mission_unit(self._unit)
	else
		self._timeline:set_visible(true)
	end
end

-- Lines 1205-1232
function CoreMissionElement:_build_value_combobox(panel, sizer, value_name, options, tooltip, custom_name, params)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, params and params.horizontal_sizer_proportions or 0, 1, "EXPAND,LEFT")

	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(custom_name or value_name, true) .. ":",
		panel = panel,
		sizer = horizontal_sizer,
		options = options,
		value = self._hed[value_name],
		tooltip = tooltip or "Select an option from the combobox"
	}
	local ctrlr = CoreEws.combobox(combobox_params)

	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "set_element_data"), {
		ctrlr = ctrlr,
		value = value_name
	})

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("SELECT_NAME_LIST", "Select from list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("SELECT_NAME_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_on_gui_value_combobox_toolbar_select_dialog"), {
		combobox_params = combobox_params,
		value_name = value_name
	})
	toolbar:realize()
	horizontal_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")

	return ctrlr, combobox_params
end

-- Lines 1235-1244
function CoreMissionElement:_on_gui_value_combobox_toolbar_select_dialog(params)
	local dialog = SelectNameModal:new("Select name", params.combobox_params.options)

	if dialog:cancelled() then
		return
	end

	for _, name in ipairs(dialog:_selected_item_assets()) do
		CoreEws.change_combobox_value(params.combobox_params, name)
		self:set_element_data({
			ctrlr = params.combobox_params.ctrlr,
			value = params.value_name
		})
	end
end

-- Lines 1246-1266
function CoreMissionElement:_build_value_number(panel, sizer, value_name, options, tooltip, custom_name)
	local number_params = {
		name = string.pretty(custom_name or value_name, true) .. ":",
		panel = panel,
		sizer = sizer,
		value = self._hed[value_name],
		floats = options.floats,
		tooltip = tooltip or "Set a number value",
		min = options.min,
		max = options.max,
		name_proportions = options.name_proportions or 1,
		ctrlr_proportions = options.ctrlr_proportions or 2,
		sizer_proportions = options.sizer_proportions
	}
	local ctrlr = CoreEws.number_controller(number_params)

	ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "set_element_data"), {
		ctrlr = ctrlr,
		value = value_name
	})
	ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "set_element_data"), {
		ctrlr = ctrlr,
		value = value_name
	})

	return ctrlr, number_params
end

-- Lines 1268-1277
function CoreMissionElement:_build_value_checkbox(panel, sizer, value_name, tooltip, custom_name)
	local checkbox = EWS:CheckBox(panel, custom_name or string.pretty(value_name, true), "")

	checkbox:set_value(self._hed[value_name])
	checkbox:set_tool_tip(tooltip or "Click to toggle")
	checkbox:connect("EVT_COMMAND_CHECKBOX_CLICKED", callback(self, self, "set_element_data"), {
		ctrlr = checkbox,
		value = value_name
	})
	sizer:add(checkbox, 0, 0, "EXPAND")

	return checkbox
end

-- Lines 1279-1291
function CoreMissionElement:_open_color_picker(panel, color_ctrlr)
	self.__color_picker_dialog = self.__color_picker_dialog or CoreColorPickerDialog.ColorPickerDialog:new(panel, true, "HORIZONTAL", true)

	self.__color_picker_dialog._window:set_focus()
	self.__color_picker_dialog:connect("EVT_CLOSE_WINDOW", function ()
		self.__color_picker_dialog = nil
	end)
	self.__color_picker_dialog:connect("EVT_COLOR_UPDATED", callback(self, self, "_on_color_changed"), "")

	local editor_window = self._parent_panel:parent():parent():parent():parent():parent():parent()
	local distance = Vector3(editor_window:get_size().x * 0.85, editor_window:get_size().y * 0.6, editor_window:get_size().z)

	self.__color_picker_dialog:set_position(editor_window:get_position() + distance)
	self.__color_picker_dialog:set_visible(true)
end

-- Lines 1293-1309
function CoreMissionElement:_build_value_color(panel, sizer, value_name, tooltip, custom_name)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 0, "EXPAND,ALIGN_RIGHT")

	local text_ctrlr = EWS:StaticText(panel, custom_name or string.pretty(value_name, true) .. ": ")

	text_ctrlr:set_tool_tip(tooltip or "Click to select a color")
	horizontal_sizer:add(text_ctrlr, 0, 158 - text_ctrlr:get_size().x, "ALIGN_LEFT,ALIGN_CENTER_VERTICAL,RIGHT")

	local color_ctrlr = EWS:Button(panel, "", "", "BU_RIGHT")

	color_ctrlr:set_background_colour(0, 255, 0)
	color_ctrlr:set_tool_tip(tooltip or "Click to select a color")
	color_ctrlr:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "_open_color_picker"), {
		panel = panel,
		color_ctrlr = color_ctrlr
	})
	horizontal_sizer:add(color_ctrlr, 1, 0, "RIGHT")

	return text_ctrlr, color_ctrlr
end

-- Lines 1311-1352
function CoreMissionElement:_build_value_random_number(panel, sizer, value_name, options, tooltip, custom_name)
	local horizontal_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(horizontal_sizer, 0, 0, "EXPAND,LEFT")

	local number_params = {
		name = string.pretty(custom_name or value_name, true) .. ":",
		panel = panel,
		sizer = horizontal_sizer,
		value = self._hed[value_name][1],
		floats = options.floats,
		tooltip = tooltip or "Set a number value",
		min = options.min,
		max = options.max,
		name_proportions = options.name_proportions or 2,
		ctrlr_proportions = options.ctrlr_proportions or 2,
		sizer_proportions = options.sizer_proportions or 2
	}
	local ctrlr = CoreEws.number_controller(number_params)

	ctrlr:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "_set_random_number_element_data"), {
		index = 1,
		ctrlr = ctrlr,
		value = value_name
	})
	ctrlr:connect("EVT_KILL_FOCUS", callback(self, self, "_set_random_number_element_data"), {
		index = 1,
		ctrlr = ctrlr,
		value = value_name
	})

	local number2_params = {
		name = "+ random:",
		tooltip = "Add a random amount",
		panel = panel,
		sizer = horizontal_sizer,
		value = self._hed[value_name][2],
		floats = options.floats,
		min = options.min,
		max = options.max,
		name_proportions = options.name_proportions or 1,
		ctrlr_proportions = options.ctrlr_proportions or 2,
		sizer_proportions = options.sizer_proportions or 1
	}
	local ctrlr2 = CoreEws.number_controller(number2_params)

	ctrlr2:connect("EVT_COMMAND_TEXT_ENTER", callback(self, self, "_set_random_number_element_data"), {
		index = 2,
		ctrlr = ctrlr2,
		value = value_name
	})
	ctrlr2:connect("EVT_KILL_FOCUS", callback(self, self, "_set_random_number_element_data"), {
		index = 2,
		ctrlr = ctrlr2,
		value = value_name
	})

	return ctrlr, number_params
end

-- Lines 1354-1368
function CoreMissionElement:_set_random_number_element_data(data)
	print("_set_random_number_element_data", inspect(data))

	local value = data.ctrlr:get_value()
	value = tonumber(value)

	print("data.ctrlr:get_value()", value, type(value))
	print("self._hed[ data.value ]", inspect(self._hed[data.value]))

	self._hed[data.value][data.index] = value
end

-- Lines 1376-1388
function CoreMissionElement:_build_add_remove_unit_from_list(panel, sizer, elements, names, exact_names)
	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_add_unit_list_btn"), {
		elements = elements,
		names = names,
		exact_names = exact_names
	})
	toolbar:add_tool("REMOVE_UNIT_LIST", "Remove unit from unit list", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_remove_unit_list_btn"), {
		elements = elements
	})
	toolbar:realize()
	sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
end

-- Lines 1390-1435
function CoreMissionElement:_add_unit_list_btn(params)
	local elements = params.elements or {}
	local script = self._unit:mission_element_data().script

	-- Lines 1394-1414
	local function f_correct_unit(unit)
		if not params.names and not params.exact_names then
			return true
		end

		local u_name = unit:name():s()

		if params.exact_names then
			for _, name in ipairs(params.exact_names) do
				if u_name == name then
					return true
				end
			end
		end

		if params.names then
			for _, name in ipairs(params.names) do
				if string.find(u_name, name, 1, true) then
					return true
				end
			end
		end

		return false
	end

	-- Lines 1416-1428
	local function f(unit)
		if not unit:mission_element_data() or unit:mission_element_data().script ~= script then
			return
		end

		local id = unit:unit_data().unit_id

		if table.contains(elements, id) then
			return false
		end

		if f_correct_unit(unit) then
			return true
		end

		return false
	end

	local dialog = SelectUnitByNameModal:new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		local id = unit:unit_data().unit_id

		table.insert(elements, id)
	end
end

-- Lines 1437-1445
function CoreMissionElement:_remove_unit_list_btn(params)
	local elements = params.elements

	-- Lines 1439-1439
	local function f(unit)
		return table.contains(elements, unit:unit_data().unit_id)
	end

	local dialog = SelectUnitByNameModal:new("Remove Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		local id = unit:unit_data().unit_id

		table.delete(elements, id)
	end
end

-- Lines 1451-1463
function CoreMissionElement:_build_add_remove_static_unit_from_list(panel, sizer, params)
	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_add_static_unit_list_btn"), params)
	toolbar:add_tool("REMOVE_UNIT_LIST", "Remove unit from unit list", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "_remove_static_unit_list_btn"), params)
	toolbar:realize()
	sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
end

-- Lines 1465-1471
function CoreMissionElement:_add_static_unit_list_btn(params)
	local dialog = (params.single and SingleSelectUnitByNameModal or SelectUnitByNameModal):new("Add Unit", params.add_filter)

	for _, unit in ipairs(dialog:selected_units()) do
		local id = unit:unit_data().unit_id

		params.add_result(unit)
	end
end

-- Lines 1473-1478
function CoreMissionElement:_remove_static_unit_list_btn(params)
	local dialog = (params.single and SingleSelectUnitByNameModal or SelectUnitByNameModal):new("Remove Unit", params.remove_filter)

	for _, unit in ipairs(dialog:selected_units()) do
		params.remove_result(unit)
	end
end

-- Lines 1482-1499
function CoreMissionElement:get_links_to_unit(to_unit, links, all_units)
	if to_unit == self._unit then
		for _, data in ipairs(self._hed.on_executed) do
			local on_executed_unit = all_units[data.id]
			local delay = self:_get_delay_string(on_executed_unit:unit_data().unit_id)
			local type = "on_executed" .. (data.alternative and " " .. data.alternative or "")

			table.insert(links.on_executed, {
				unit = on_executed_unit,
				alternative = type,
				delay = delay
			})
		end
	end

	for _, data in ipairs(self._hed.on_executed) do
		local unit = all_units[data.id]

		if unit == to_unit then
			local delay = self:_get_delay_string(unit:unit_data().unit_id)
			local type = "on_executed" .. (data.alternative and " " .. data.alternative or "")

			table.insert(links.executers, {
				unit = self._unit,
				alternative = type,
				delay = delay
			})
		end
	end
end

-- Lines 1502-1513
function CoreMissionElement:_get_links_of_type_from_elements(elements, type, to_unit, links, all_units)
	local links1 = type == "operator" and links.on_executed or type == "trigger" and links.executers or type == "filter" and links.executers or links.on_executed
	local links2 = type == "operator" and links.executers or type == "trigger" and links.on_executed or type == "filter" and links.on_executed or links.executers
	local to_unit_id = to_unit:unit_data().unit_id

	for _, id in ipairs(elements) do
		if to_unit == self._unit then
			table.insert(links1, {
				unit = all_units[id],
				alternative = type
			})
		elseif id == to_unit_id then
			table.insert(links2, {
				unit = self._unit,
				alternative = type
			})
		end
	end
end
