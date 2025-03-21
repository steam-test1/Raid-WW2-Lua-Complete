core:module("CoreStaticLayer")
core:import("CoreLayer")
core:import("CoreEditorUtils")
core:import("CoreInput")
core:import("CoreEws")
core:import("CoreTable")

StaticLayer = StaticLayer or class(CoreLayer.Layer)

function StaticLayer:init(owner, save_name, units_vector, slot_mask)
	StaticLayer.super.init(self, owner, save_name)
	self:load_unit_map_from_vector(units_vector)

	self._unit_name = ""
	self._current_pos = Vector3(0, 0, 0)
	self._offset_move_vec = Vector3(0, 0, 0)
	self._move_unit_rep = CoreInput.RepKey:new({
		"move_forward",
		"move_back",
		"move_right",
		"move_left",
		"move_up",
		"move_down"
	})

	self._move_unit_rep:set_input(self._editor_data.virtual_controller)

	self._will_use_widgets = true
	self._slot_mask = managers.slot:get_mask(slot_mask)
	self._position_as_slot_mask = self._slot_mask
	self._ews_triggers = {}
end

function StaticLayer:clone_unit()
	if self:ctrl() then
		self:clone()
		self:cloned_group()
	end
end

function StaticLayer:move_to_continent(name)
	local delete_units = self._selected_units

	self:clone(name)
	managers.editor:freeze_gui_lists()

	for _, unit in ipairs(delete_units) do
		print("delete_unit", unit)
		self:delete_unit(unit)
	end

	managers.editor:set_continent(name)
	managers.editor:thaw_gui_lists()
end

function StaticLayer:clone(to_continent)
	managers.editor:freeze_gui_lists()

	if self._selected_unit and not self:condition() then
		local clone_units = self._selected_units

		if managers.editor:using_groups() then
			self._clone_create_group = true
		end

		self._selected_units = {}

		for _, unit in ipairs(clone_units) do
			local pos = unit:position()
			local rot = unit:rotation()
			self._unit_name = unit:name():s()
			local old_unit = unit
			local new_unit = self:do_spawn_unit(self._unit_name, pos, rot, to_continent)

			self:remove_name_id(new_unit)

			new_unit:unit_data().name_id = self:get_name_id(new_unit, old_unit:unit_data().name_id)

			managers.editor:unit_name_changed(new_unit)
			self:clone_edited_values(new_unit, old_unit)
		end

		self:update_unit_settings()
	end

	managers.editor:thaw_gui_lists()
	self:_cloning_done()
end

function StaticLayer:spawn_unit_release()
	self._point_unit_at_current = nil
end

function StaticLayer:spawn_unit()
	if not self._grab and not self:condition() then
		self:do_spawn_unit(self._unit_name)

		self._point_unit_at_current = true
	end
end

function StaticLayer:do_spawn_unit(...)
	local unit = StaticLayer.super.do_spawn_unit(self, ...)

	if unit then
		self:set_bodies_keyframed(unit)
	end

	return unit
end

function StaticLayer:set_bodies_keyframed(unit)
	local bodies = unit:num_bodies()

	for i = 0, bodies - 1 do
		if unit:body(i):keyframed() then
			return
		end
	end

	for i = 0, bodies - 1 do
		local body = unit:body(i)

		body:set_keyframed()
	end
end

function StaticLayer:use_grab_info()
	StaticLayer.super.use_grab_info(self)

	if self._grab then
		self._grab = false

		self:set_unit_positions(self._grab_info:position())
		self:set_unit_rotations(self._grab_info:rotation() * self._selected_unit:rotation():inverse())
	end
end

function StaticLayer:set_unit_positions(pos)
	if not self._grab then
		managers.editor:set_grid_altitude(pos.z)
	end

	if managers.editor:use_beta_undo() then
		if not self._undo_last_move_t or TimerManager:now() - self._undo_last_move_t > 1 then
			self._undo_last_move_pos = {}

			for _, unit in ipairs(self._selected_units) do
				self._undo_last_move_pos[#self._undo_last_move_pos + 1] = {
					unit = unit,
					pos = unit:position(),
					rot = unit:rotation()
				}
			end
		end

		self._undo_last_move_t = TimerManager:now()
	end

	local reference = self._selected_unit

	for _, unit in ipairs(self._selected_units) do
		if unit ~= reference then
			self:set_unit_position(unit, pos, reference:rotation())
		end
	end

	reference:set_position(pos)

	reference:unit_data().world_pos = pos

	self:_on_unit_moved(reference, pos)
end

function StaticLayer:set_unit_position(unit, pos, rot)
	local new_pos = pos + unit:unit_data().local_pos:rotate_with(rot)

	unit:set_position(new_pos)

	unit:unit_data().world_pos = new_pos

	self:_on_unit_moved(unit, new_pos)
	unit:set_moving()
end

function StaticLayer:set_unit_rotations(rot)
	if managers.editor:use_beta_undo() then
		if not self._undo_last_move_t or TimerManager:now() - self._undo_last_move_t > 1 then
			self._undo_last_move_pos = {}

			for _, unit in ipairs(self._selected_units) do
				self._undo_last_move_pos[#self._undo_last_move_pos + 1] = {
					unit = unit,
					pos = unit:position(),
					rot = unit:rotation()
				}
			end
		end

		self._undo_last_move_t = TimerManager:now()
	end

	local reference = self._selected_unit
	local rot = rot * reference:rotation()

	reference:set_rotation(rot)
	self:_on_unit_rotated(reference, rot)

	for _, unit in ipairs(self._selected_units) do
		if unit ~= reference then
			self:set_unit_position(unit, reference:position(), rot)
			self:set_unit_rotation(unit, rot)
		end
	end
end

function StaticLayer:set_unit_rotation(unit, rot)
	local rot = rot * unit:unit_data().local_rot

	unit:set_rotation(rot)
	self:_on_unit_rotated(unit, rot)
end

function StaticLayer:_on_unit_moved(unit, pos)
	if unit:ladder() then
		unit:set_position(pos)
		unit:ladder():set_config()
	end

	if unit:zipline() then
		unit:zipline():set_start_pos(pos)
	end
end

function StaticLayer:_on_unit_rotated(unit, rot)
	if unit:ladder() then
		unit:set_rotation(rot)
		unit:ladder():set_config()
	end
end

function StaticLayer:move_unit(btn, pressed)
	if self._selected_unit then
		self._grab = true
		self._grab_info = CoreEditorUtils.GrabInfo:new(self._selected_unit)

		if not managers.editor:invert_move_shift() or managers.editor:invert_move_shift() and self:shift() then
			self._offset_move_vec = self._selected_unit:position() - self._current_pos
		end
	end
end

function StaticLayer:rotate_unit_release(btn, pressed)
	self._point_units_at_current = nil
end

function StaticLayer:rotate_unit(btn, pressed)
	if self:alt() then
		self._point_units_at_current = true
	elseif self._selected_unit and not self:condition() then
		local rot_axis = nil
		local snap_axis = self:snap_rotation_axis()

		if self:local_rot() then
			if snap_axis == "x" then
				rot_axis = self._selected_unit:rotation():x()
			elseif snap_axis == "y" then
				rot_axis = self._selected_unit:rotation():y()
			elseif snap_axis == "z" then
				rot_axis = self._selected_unit:rotation():z()
			end
		elseif snap_axis == "x" then
			rot_axis = Vector3(1, 0, 0)
		elseif snap_axis == "y" then
			rot_axis = Vector3(0, 1, 0)
		elseif snap_axis == "z" then
			rot_axis = Vector3(0, 0, 1)
		end

		local step = self:snap_rotation()

		if self:shift() then
			step = -step
		end

		local rot = Rotation(rot_axis, step)

		self:set_unit_rotations(rot)
	end
end

function StaticLayer:position_as()
	if self._selected_unit and not self:condition() then
		local data = {
			ray_type = "body editor",
			sample = true,
			mask = self._position_as_slot_mask
		}
		local ray = managers.editor:unit_by_raycast(data)

		if ray and ray.unit then
			self:set_unit_positions(ray.unit:position())
			self:set_unit_rotations(ray.unit:rotation() * self._selected_unit:rotation():inverse())
		end
	end
end

function StaticLayer:set_select_unit(unit)
	StaticLayer.super.set_select_unit(self, unit)

	if unit then
		self:set_bodies_keyframed(unit)
	end

	if alive(self._selected_unit) then
		managers.editor:set_grid_altitude(self._selected_unit:position().z)
	end
end

function StaticLayer:release_unit()
	self._grab = false
	self._offset_move_vec = Vector3(0, 0, 0)

	if self._selected_unit then
		managers.editor:set_grid_altitude(self._selected_unit:position().z)
	end
end

function StaticLayer:delete_selected_unit(btn, pressed)
	managers.editor:freeze_gui_lists()

	if self._selected_unit and not self:condition() then
		local to_delete = CoreTable.clone(self._selected_units)

		for _, unit in ipairs(to_delete) do
			if table.contains(self._created_units, unit) then
				self:delete_unit(unit)
			else
				local unit_in_layer_name = managers.editor:unit_in_layer_name(unit)

				if unit_in_layer_name then
					managers.editor:output_warning("" .. tostring(unit:unit_data().name_id) .. " belongs to " .. tostring(unit_in_layer_name) .. " and cannot be deleted from here.")
				else
					managers.editor:output_warning("" .. tostring(unit:unit_data().name_id) .. " belongs to nothing and will be deleted")
					self:delete_unit(unit)
				end
			end
		end
	end

	managers.editor:thaw_gui_lists()
end

function StaticLayer:create_marker(marker)
	if self._selected_unit then
		marker:set_pos(self._selected_unit:position())
		marker:set_rot(self._selected_unit:rotation())

		return true
	end
end

function StaticLayer:use_marker(marker)
	if self._selected_unit then
		self:set_unit_positions(marker._pos)
		self:set_unit_rotations(marker._rot * self._selected_unit:rotation():inverse())
	end
end

function StaticLayer:reset_rotation()
	if self._selected_unit then
		local yaw = not self:shift() and self._selected_unit:rotation():yaw() or 0

		self:set_unit_rotations(Rotation(yaw, 0, 0) * self._selected_unit:rotation():inverse())
	end
end

function StaticLayer:update(t, dt)
	self:draw_units(t, dt)
	self:draw_rotation(t, dt)
	StaticLayer.super.update(self, t, dt)

	if not self:condition() then
		if self._grab and self:shift() and not managers.editor:invert_move_shift() or not self:shift() and managers.editor:invert_move_shift() then
			self._offset_move_vec = Vector3(0, 0, 0)
		end

		local current_pos, current_rot = managers.editor:current_orientation(self._offset_move_vec, self._selected_unit)
		self._current_pos = current_pos or self._current_pos
		self._current_rot = current_rot

		if self._current_pos and self._grab then
			if alive(self._selected_unit) then
				self:set_unit_positions(self._current_pos)
			else
				self._grab = false
			end
		end

		if self._current_rot then
			if self._ctrl:down(Idstring("assign_suface_normal")) then
				self:set_unit_rotations(self._current_rot)
			end

			if self._grab then
				if self._ctrl:down(Idstring("surface_move_align_normal")) then
					self:set_unit_rotations(self._current_rot)
				end

				if self:use_snappoints() then
					self:set_unit_rotations(self._current_rot)
				end
			end
		end

		self:draw_marker(t, dt)
		self:draw_grid(t, dt)
	end

	self:update_move_triggers(t, dt)
	self:update_rotate_triggers(t, dt)
	self:_update_point_at()
end

function StaticLayer:_update_point_at()
	if self._point_unit_at_current then
		self:update_aim_unit(self._selected_unit)
	elseif self._point_units_at_current then
		if self:alt() then
			for _, unit in ipairs(self._selected_units) do
				self:update_aim_unit(unit)
			end
		else
			self._point_units_at_current = nil
		end
	end
end

function StaticLayer:update_aim_unit(unit)
	if alive(unit) then
		local dist = mvector3.distance(self._current_pos, unit:position())

		if dist > self:grid_size() / 2 then
			local dir_2d = (self._current_pos:with_z(0) - unit:position():with_z(0)):normalized()
			local up = unit:rotation():z()
			local rot = Rotation:look_at(dir_2d, up)

			unit:set_rotation(rot)
			self:_on_unit_rotated(unit, rot)

			local pos = unit:position() + Vector3(0, 0, 1)

			Application:draw_line(pos, pos + dir_2d * 10000, 1, 0, 0)
		end
	end
end

function StaticLayer:draw_marker(t, dt)
	if not managers.editor:layer_draw_marker() then
		return
	end

	local ray = nil

	if alive(self._selected_unit) then
		ray = self._selected_unit:raycast(self._current_pos + Vector3(0, 0, 2000), self._current_pos + Vector3(0, 0, -500), nil, self._slot_mask)
	else
		ray = World:raycast(self._current_pos + Vector3(0, 0, 2000), self._current_pos + Vector3(0, 0, -500), nil, self._slot_mask)
	end

	if ray and ray.unit then
		Application:draw_line(self._current_pos - Vector3(0, 0, 2000), self._current_pos + Vector3(0, 0, 2000), 1, 0, 0)
		Application:draw_sphere(self._current_pos, self._marker_sphere_size, 1, 0, 0)
	else
		Application:draw_line(self._current_pos - Vector3(0, 0, 2000), self._current_pos + Vector3(0, 0, 2000), 0, 1, 0)
		Application:draw_sphere(self._current_pos, self._marker_sphere_size, 0, 1, 0)
	end
end

function StaticLayer:update_move_triggers(t, dt)
	if not alive(self._selected_unit) or not self._editor_data.keyboard_available or self:condition() then
		return
	end

	if not self._move_unit_rep:update(d, dt) or CoreInput.shift() then
		return
	end

	local mov_vec = nil
	local u_rot = self._selected_unit:rotation()

	if self._ctrl:down(Idstring("move_forward")) then
		mov_vec = self:local_rot() and u_rot:y() or Vector3(0, 1, 0)
	elseif self._ctrl:down(Idstring("move_back")) then
		mov_vec = self:local_rot() and u_rot:y() * -1 or Vector3(0, 1, 0) * -1
	elseif self._ctrl:down(Idstring("move_left")) then
		mov_vec = self:local_rot() and u_rot:x() * -1 or Vector3(1, 0, 0) * -1
	elseif self._ctrl:down(Idstring("move_right")) then
		mov_vec = self:local_rot() and u_rot:x() or Vector3(1, 0, 0)
	elseif self._ctrl:down(Idstring("move_up")) then
		mov_vec = self:local_rot() and u_rot:z() or Vector3(0, 0, 1)
	elseif self._ctrl:down(Idstring("move_down")) then
		mov_vec = self:local_rot() and u_rot:z() * -1 or Vector3(0, 0, 1) * -1
	end

	if mov_vec then
		self:set_unit_positions(self._selected_unit:position() + mov_vec * self:grid_size())
	end
end

function StaticLayer:update_rotate_triggers(t, dt)
	if not alive(self._selected_unit) or not self._editor_data.keyboard_available or self:condition() then
		return
	end

	local rot_speed = self:rotation_speed() * dt

	if self:shift() then
		rot_speed = rot_speed / 2
	end

	local rot_axis = nil
	local u_rot = self._selected_unit:rotation()

	if self._ctrl:down(Idstring("roll_left")) then
		rot_axis = self:local_rot() and u_rot:z() or Vector3(0, 0, 1)
	elseif self._ctrl:down(Idstring("roll_right")) then
		rot_axis = (self:local_rot() and u_rot:z() or Vector3(0, 0, 1)) * -1
	elseif self._ctrl:down(Idstring("pitch_right")) then
		rot_axis = self:local_rot() and u_rot:y() or Vector3(0, 1, 0)
	elseif self._ctrl:down(Idstring("pitch_left")) then
		rot_axis = (self:local_rot() and u_rot:y() or Vector3(0, 1, 0)) * -1
	elseif self._ctrl:down(Idstring("yaw_backward")) then
		rot_axis = self:local_rot() and u_rot:x() or Vector3(1, 0, 0)
	elseif self._ctrl:down(Idstring("yaw_forward")) then
		rot_axis = (self:local_rot() and u_rot:x() or Vector3(1, 0, 0)) * -1
	end

	if rot_axis then
		local rot = Rotation(rot_axis, rot_speed)

		self:set_unit_rotations(rot)
	end
end

function StaticLayer:draw_rotation(t, dt)
	if not alive(self._selected_unit) then
		return
	end

	local p_rot = self._owner:get_cursor_look_point(500)

	if self:local_rot() then
		Application:draw_rotation(p_rot, self._selected_unit:rotation())
	else
		Application:draw_rotation(p_rot, Rotation(0, 0, 0))
	end
end

function StaticLayer:draw_units(t, dt)
	if self._selected_units then
		for _, unit in ipairs(self._selected_units) do
			if alive(unit) and unit ~= self._selected_unit then
				Application:draw(unit, 1, 1, 1)
			end
		end
	end

	if not alive(self._selected_unit) then
		return
	end

	Application:draw_rotation(self._selected_unit:position(), self._selected_unit:rotation())
	Application:draw(self._selected_unit, 0, 1, 0)
end

function StaticLayer:build_panel(notebook, settings)
	cat_print("editor", "StaticLayer:build_panel")

	self._ews_panel = EWS:ScrolledWindow(notebook, "", "VSCROLL")

	self._ews_panel:set_scroll_rate(Vector3(10, 20, 0))
	self._ews_panel:set_virtual_size_hints(Vector3(0, 0, 0), Vector3(1, -1, -1))

	self._main_sizer = EWS:BoxSizer("VERTICAL")

	self._ews_panel:set_sizer(self._main_sizer)

	self._sizer = EWS:BoxSizer("VERTICAL")
	local static_sizer = EWS:BoxSizer("HORIZONTAL")

	self._sizer:add(static_sizer, 0, 0, "EXPAND")
	self:build_name_id()

	self._btn_toolbar = EWS:ToolBar(self._ews_panel, "", "TB_FLAT,TB_NODIVIDER")

	self:add_btns_to_toolbar()
	self._btn_toolbar:realize()
	self._sizer:add(self._btn_toolbar, 0, 1, "EXPAND,BOTTOM")
	self._sizer:add(self:build_units(settings), settings and settings.units_noteboook_proportion or 1, 0, "EXPAND")
	self._main_sizer:add(self._sizer, 1, 0, "EXPAND")

	return self._ews_panel
end

function StaticLayer:build_btn_toolbar()
end

function StaticLayer:add_btns_to_toolbar()
	self._btn_toolbar:add_tool("HIDE_ALL", "Hide All", CoreEws.image_path("toolbar\\hide_16x16.png"), "Hide All")
	self._btn_toolbar:connect("HIDE_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "hide_all"), nil)
	self._btn_toolbar:add_tool("UNHIDE_ALL", "Unhide All", CoreEws.image_path("toolbar\\show_16x16.png"), "Unhide All")
	self._btn_toolbar:connect("UNHIDE_ALL", "EVT_COMMAND_MENU_SELECTED", callback(self, self, "unhide_all"), nil)
end

function StaticLayer:get_help(text)
	local t = "\t"
	local n = "\n"
	text = text .. "Create unit:        Right mouse button" .. n
	text = text .. t .. "+Alt;   Create without selections" .. n
	text = text .. t .. "+Ctrl;  Create keeping selections" .. n
	text = text .. t .. "+Shift; Create keeping selections" .. n
	text = text .. "Select unit:        Left mouse button" .. n
	text = text .. t .. "+Alt;   Deselect only" .. n
	text = text .. t .. "+Ctrl;  Add to selections" .. n
	text = text .. t .. "+Shift; Select as focused" .. n
	text = text .. "Snap rotate:        Middle mouse button or [F] key" .. n
	text = text .. t .. "+Alt;   Point at cursor" .. n
	text = text .. t .. "+Ctrl;  Rotate by 1 degree" .. n
	text = text .. t .. "+Shift; Reverse rotation" .. n
	text = text .. "Move unit:          Thumb mouse button (keep pressed to drag)" .. n
	text = text .. t .. "+Shift; Position at cursor" .. n
	text = text .. "Remove unit:        Delete" .. n
	text = text .. "Align with unit:    Point and press P" .. n
	text = text .. "Sample unit:        Point and press B" .. n
	text = text .. "Replace unit:       Press R" .. n
	text = text .. "Clone unit:         Ctrl + V" .. n
	text = text .. "Toggle local/world: Numpad 0" .. n
	text = text .. "Rotate around X:    Numpad 8 and 2" .. n
	text = text .. "Rotate around Y:    Numpad 1 and 3" .. n
	text = text .. "Rotate around Z:    Numpad 4 and 6" .. n
	text = text .. "Clone values:       Point and press [M] key to clone values to all selected" .. n
	text = text .. t .. "+Shift; Instead clone values from focused to pointed" .. n
	text = text .. "Reset rotation:     Numpad-Enter (reset but keeps Z-axis rotations)" .. n
	text = text .. t .. "+Shift; Reset all axis" .. n
	text = text .. "Hide / Unide:       Ctrl+J will hide the selected units, CTRL+SHIFT+J will unide all hidden units" .. n

	return text
end

function StaticLayer:undo()
	if not managers.editor:use_beta_undo() then
		return
	end

	if self._undo_last_move_pos then
		self._redo_last_move_pos = {}

		for _, pos_info in ipairs(self._undo_last_move_pos) do
			local unit = pos_info.unit

			if alive(unit) then
				local new_pos = pos_info.pos
				local new_rot = pos_info.rot
				self._redo_last_move_pos[#self._redo_last_move_pos + 1] = {
					unit = unit,
					pos = unit:position(),
					rot = unit:rotation()
				}

				unit:set_position(new_pos)

				unit:unit_data().world_pos = new_pos

				self:_on_unit_moved(unit, new_pos)
				unit:set_moving()
				unit:set_rotation(new_rot)
				self:_on_unit_rotated(unit, new_rot)
			end
		end

		self._undo_last_move_pos = self._redo_last_move_pos
		self._redo_last_move_pos = nil
	end
end

function StaticLayer:deactivate()
	StaticLayer.super.deactivate(self)
end

function StaticLayer:add_triggers()
	StaticLayer.super.add_triggers(self)

	local vc = self._editor_data.virtual_controller
	local IDS_RMB = Idstring("rmb")

	vc:add_trigger(IDS_RMB, callback(self, self, "spawn_unit"))
	vc:add_release_trigger(IDS_RMB, callback(self, self, "spawn_unit_release"))
	vc:add_trigger(IDS_RMB, callback(self, self, "use_grab_info"))

	local IDS_MMB = Idstring("mmb")

	vc:add_trigger(IDS_MMB, callback(self, self, "rotate_unit"))
	vc:add_release_trigger(IDS_MMB, callback(self, self, "rotate_unit_release"))
	vc:add_trigger(Idstring("move_unit"), callback(self, self, "move_unit"))
	vc:add_release_trigger(Idstring("move_unit"), callback(self, self, "release_unit"))
	vc:add_trigger(Idstring("destroy"), callback(self, self, "delete_selected_unit"))
	vc:add_trigger(Idstring("position_as"), callback(self, self, "position_as"))
	vc:add_trigger(Idstring("show_replace_units"), callback(self, self, "show_replace_units"))
	vc:add_trigger(Idstring("reset_rotation"), callback(self, self, "reset_rotation"))
	vc:add_trigger(Idstring("clone"), callback(self, self, "clone_unit"))
	vc:add_trigger(Idstring("snap_rotate"), callback(self, self, "rotate_unit"))

	for k, cb in pairs(self._ews_triggers) do
		vc:add_trigger(Idstring(k), cb)
	end
end
