AIAreaElement = AIAreaElement or class(MissionElement)
AIAreaElement.SAVE_UNIT_ROTATION = false

function AIAreaElement:init(unit)
	AIAreaElement.super.init(self, unit)

	self._nav_seg_units = {}

	table.insert(self._save_values, "nav_segs")
end

function AIAreaElement:post_init(...)
	AIAreaElement.super.post_init(self, ...)
end

function AIAreaElement:layer_finished()
	AIAreaElement.super.layer_finished(self)

	if not self._hed.nav_segs then
		return
	end

	for _, u_id in ipairs(self._hed.nav_segs) do
		local unit = managers.worlddefinition:get_unit_on_load(u_id, callback(self, self, "load_nav_seg_unit"))

		if unit then
			self._nav_seg_units[u_id] = unit
		end
	end
end

function AIAreaElement:load_nav_seg_unit(unit)
	self._nav_seg_units[unit:unit_data().unit_id] = unit
end

function AIAreaElement:draw_links(t, dt, selected_unit, all_units)
	AIAreaElement.super.draw_links(self, t, dt, selected_unit)

	if selected_unit and self._unit ~= selected_unit and not self._nav_seg_units[selected_unit:unit_data().unit_id] then
		return
	end

	for u_id, unit in pairs(self._nav_seg_units) do
		self:_draw_link({
			g = 0.75,
			b = 0,
			r = 0,
			from_unit = self._unit,
			to_unit = unit
		})
	end
end

function AIAreaElement:update_selected(t, dt, selected_unit, all_units)
	self:_chk_units_alive()
	managers.editor:layer("Ai"):external_draw(t, dt)
	self:draw_links(t, dt, selected_unit, all_units)
	SpecialObjectiveUnitElement._highlight_if_outside_the_nav_field(self, t)
end

function AIAreaElement:update_unselected(t, dt, selected_unit, all_units)
	self:_chk_units_alive()
end

function AIAreaElement:_chk_units_alive()
	for u_id, unit in pairs(self._nav_seg_units) do
		if not alive(unit) then
			self._nav_seg_units[u_id] = nil

			self:_remove_nav_seg(u_id)
		end
	end
end

function AIAreaElement:update_editing()
	self:_raycast()
end

function AIAreaElement:_raycast()
	local ray = managers.editor:unit_by_raycast({
		ray_type = "editor",
		mask = 19
	})

	if not ray then
		return
	end

	if ray.unit:name():s() == "core/units/nav_surface/nav_surface" then
		Application:draw(ray.unit, 0, 1, 0)

		return ray.unit
	else
		Application:draw_sphere(ray.position, 10, 1, 1, 1)
	end
end

function AIAreaElement:_lmb()
	local unit = self:_raycast()

	if not unit then
		return
	end

	local u_id = unit:unit_data().unit_id

	if self._nav_seg_units[u_id] then
		self:_remove_unit(unit)
	else
		self:_add_unit(unit)
	end
end

function AIAreaElement:_add_unit(unit)
	local u_id = unit:unit_data().unit_id

	self._nav_seg_units[u_id] = unit

	self:_add_nav_seg(unit)
end

function AIAreaElement:_remove_unit(unit)
	local u_id = unit:unit_data().unit_id

	self._nav_seg_units[u_id] = nil

	self:_remove_nav_seg(u_id)
end

function AIAreaElement:add_triggers(vc)
	vc:add_trigger(Idstring("lmb"), callback(self, self, "_lmb"))
end

function AIAreaElement:selected()
	AIAreaElement.super.selected(self)
	self:_chk_units_alive()
end

function AIAreaElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	self._btn_toolbar = EWS:ToolBar(panel, "", "TB_FLAT,TB_NODIVIDER")

	self._btn_toolbar:add_tool("ADD_UNIT_LIST", "Add unit from unit list", CoreEws.image_path("world_editor\\unit_by_name_list.png"), nil)
	self._btn_toolbar:connect("ADD_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "add_unit_list_btn"), nil)
	self._btn_toolbar:add_tool("REMOVE_UNIT_LIST", "Remove unit from unit list", CoreEws.image_path("toolbar\\delete_16x16.png"), nil)
	self._btn_toolbar:connect("REMOVE_UNIT_LIST", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "remove_unit_list_btn"), nil)
	self._btn_toolbar:realize()
	panel_sizer:add(self._btn_toolbar, 0, 1, "EXPAND,LEFT")
end

function AIAreaElement:add_unit_list_btn()
	local function f(unit)
		if self._nav_seg_units[unit:unit_data().unit_id] then
			return false
		end

		if unit:name():s() == "core/units/nav_surface/nav_surface" then
			return true
		else
			return false
		end
	end

	local dialog = SelectUnitByNameModal:new("Add Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		if not self._nav_seg_units[unit:unit_data().unit_id] then
			self:_add_unit(unit)
		end
	end
end

function AIAreaElement:remove_unit_list_btn()
	local function f(unit)
		return self._nav_seg_units[unit:unit_data().unit_id]
	end

	local dialog = SelectUnitByNameModal:new("Remove Unit", f)

	for _, unit in ipairs(dialog:selected_units()) do
		if self._nav_seg_units[unit:unit_data().unit_id] then
			self:_remove_unit(unit)
		end
	end
end

function AIAreaElement:add_to_mission_package()
	return
end

function AIAreaElement:_add_nav_seg(unit)
	self._hed.nav_segs = self._hed.nav_segs or {}

	table.insert(self._hed.nav_segs, unit:unit_data().unit_id)
end

function AIAreaElement:_remove_nav_seg(u_id)
	for i, test_u_id in ipairs(self._hed.nav_segs) do
		if u_id == test_u_id then
			table.remove(self._hed.nav_segs, i)

			if #self._hed.nav_segs == 0 then
				self._hed.nav_segs = nil
			end

			return
		end
	end
end
