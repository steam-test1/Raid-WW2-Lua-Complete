CarryUnitElement = CarryUnitElement or class(MissionElement)
CarryUnitElement.SAVE_UNIT_POSITION = false
CarryUnitElement.SAVE_UNIT_ROTATION = false
CarryUnitElement.CARRY_OPTIONS = {
	"remove",
	"remove_align",
	"freeze",
	"secure",
	"secure_silent",
	"add_to_respawn",
	"filter_only"
}

-- Lines 16-29
function CarryUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._align_units = {}
	self._hed.elements = {}
	self._hed.operation = "secure"
	self._hed.type_filter = "none"
	self._hed.anim_align_unit_ids = {}

	table.insert(self._save_values, "operation")
	table.insert(self._save_values, "type_filter")
	table.insert(self._save_values, "anim_align_unit_ids")
end

-- Lines 33-55
function CarryUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer

	self:_build_value_combobox(panel, panel_sizer, "operation", CarryUnitElement.CARRY_OPTIONS)
	self:_build_value_combobox(panel, panel_sizer, "type_filter", table.list_add({
		"none"
	}, tweak_data.carry:get_carry_ids()))

	local toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	toolbar:add_tool("REMOVE_UNIT_LIST", "Remove unit from unit list", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_unit_list_btn"), nil)
	toolbar:realize()
	panel_sizer:add(toolbar, 0, 1, "EXPAND,LEFT")
	self:_add_help_text("Units linked to Carry element must have a 'carry_align' extension to function with 'remove_align'!")
end

-- Lines 60-65
function CarryUnitElement:update_editing()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	if ray and ray.unit then
		Application:draw(ray.unit, 0, 1, 0)
	end
end

-- Lines 67-77
function CarryUnitElement:layer_finished()
	MissionElement.layer_finished(self)

	for _, id in pairs(self._hed.anim_align_unit_ids) do
		local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "load_unit"))

		if unit then
			self._align_units[unit:unit_data().unit_id] = unit
		end
	end
end

-- Lines 79-83
function CarryUnitElement:load_unit(unit)
	if unit then
		self._align_units[unit:unit_data().unit_id] = unit
	end
end

-- Lines 85-110
function CarryUnitElement:update_selected(t, dt, selected_unit, all_units)
	for _, id in pairs(self._hed.anim_align_unit_ids) do
		if not alive(self._align_units[id]) then
			table.delete(self._hed.anim_align_unit_ids, id)

			self._align_units[id] = nil
		end
	end

	for id, unit in pairs(self._align_units) do
		if not alive(unit) then
			table.delete(self._hed.anim_align_unit_ids, id)

			self._units[id] = nil
		else
			self:_draw_link({
				g = 0.5,
				r = 0,
				b = 0,
				from_unit = self._unit,
				to_unit = unit
			})
			Application:draw(unit, 0, 0.5, 0)
		end
	end
end

-- Lines 112-116
function CarryUnitElement:_remove_unit(unit)
	self._align_units[unit:unit_data().unit_id] = nil

	table.delete(self._hed.anim_align_unit_ids, unit:unit_data().unit_id)
end

-- Lines 118-122
function CarryUnitElement:_add_unit(unit)
	self._align_units[unit:unit_data().unit_id] = unit

	table.insert(self._hed.anim_align_unit_ids, unit:unit_data().unit_id)
end

-- Lines 124-126
function CarryUnitElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "select_unit"))
end

-- Lines 128-148
function CarryUnitElement:select_unit()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "body editor",
		sample = true,
		mask = managers.slot:get_mask("all")
	})

	-- Lines 132-136
	local function f(unit)
		if unit:carry_align() then
			return managers.editor:unit_in_layer(unit) == managers.editor:layer("Statics")
		end
	end

	if ray and ray.unit and f(ray.unit) then
		local unit = ray.unit

		if self._align_units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		else
			self:_add_unit(unit)
		end
	end
end

-- Lines 153-171
function CarryUnitElement:add_unit_list_btn()
	-- Lines 154-163
	local function f(unit)
		if not unit:carry_align() then
			return false
		end

		local id = unit:unit_data().unit_id

		if table.contains(self._hed.anim_align_unit_ids, id) then
			return false
		end

		return managers.editor:unit_in_layer(unit) == managers.editor:layer("Statics")
	end

	local dialog = SelectUnitByNameModal:new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		if not self._align_units[unit:unit_data().unit_id] then
			self:_add_unit(unit)
		end
	end
end

-- Lines 173-181
function CarryUnitElement:remove_unit_list_btn()
	-- Lines 174-174
	local function f(unit)
		return table.contains(self._hed.anim_align_unit_ids, unit:unit_data().unit_id)
	end

	local dialog = SelectUnitByNameModal:new("Remove Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		if self._align_units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		end
	end
end
