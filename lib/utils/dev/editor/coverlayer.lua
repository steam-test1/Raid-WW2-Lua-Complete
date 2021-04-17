core:import("CoreStaticLayer")
core:import("CoreEditorUtils")
core:import("CoreEws")

CoverLayer = CoverLayer or class(CoreStaticLayer.StaticLayer)

-- Lines 8-18
function CoverLayer:init(owner, save_name, units_vector, slot_mask)
	CoverLayer.super.init(self, owner, "cover", {
		"cover"
	}, "cover_layer")

	self._brush = Draw:brush()

	self:load_unit_map_from_vector(units_vector)

	self._unit_name = ""
	self._current_pos = Vector3(0, 0, 0)
	self._offset_move_vec = Vector3(0, 0, 0)
	self._slot_mask = managers.slot:get_mask("cover")
end

-- Lines 20-39
function CoverLayer:build_panel(notebook)
	self._ews_panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	self._main_sizer = EWS:BoxSizer("VERTICAL")

	self._ews_panel:set_sizer(self._main_sizer)

	local btn_sizer = EWS:StaticBoxSizer(self._ews_panel, "HORIZONTAL", "")
	local create_btn = EWS:Button(self._ews_panel, "Create covers", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(create_btn, 0, 5, "LEFT,TOP,BOTTOM")
	create_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "create_covers"), nil)

	local delete_btn = EWS:Button(self._ews_panel, "Delete covers", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(delete_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	delete_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "delete_covers"), nil)
	self._main_sizer:add(btn_sizer, 0, 1, "EXPAND,LEFT")

	return self._ews_panel, true
end

-- Lines 41-43
function CoverLayer:add_btns_to_toolbar(...)
	CoverLayer.super.add_btns_to_toolbar(self, ...)
end

-- Lines 45-53
function CoverLayer:create_covers()
	local all_static_units = World:find_units_quick("all", managers.slot:get_mask("world_geometry"))

	for _, unit in pairs(all_static_units) do
		Application:trace(inspect(unit), inspect(unit.cover_placement))

		if unit.cover_placement and unit:cover_placement() then
			unit:cover_placement():create_cover_points()
		end
	end
end

-- Lines 55-62
function CoverLayer:delete_covers()
	local all_static_units = World:find_units_quick("all", managers.slot:get_mask("world_geometry"))

	for _, unit in pairs(all_static_units) do
		if unit.cover_placement then
			unit:delete_cover_points()
		end
	end
end

-- Lines 64-69
function CoverLayer:set_enabled(enabled)
	if not enabled then
		managers.editor:output_warning("Don't want to disable Cover layer since it is super cool.")
	end

	return false
end
