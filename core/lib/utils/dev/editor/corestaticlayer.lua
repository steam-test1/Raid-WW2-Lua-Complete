core:module("CoreStaticLayer")
core:import("CoreLayer")
core:import("CoreEditorUtils")
core:import("CoreInput")
core:import("CoreEws")
core:import("CoreTable")
core:import("CoreUndoableCommand")

local IDS_MOVE_FWD = Idstring("move_forward")
local IDS_MOVE_BWD = Idstring("move_back")
local IDS_MOVE_L = Idstring("move_left")
local IDS_MOVE_R = Idstring("move_right")
local IDS_MOVE_UP = Idstring("move_up")
local IDS_MOVE_DWN = Idstring("move_down")
local IDS_ROLL_L = Idstring("roll_left")
local IDS_ROLL_R = Idstring("roll_right")
local IDS_PITCH_L = Idstring("pitch_left")
local IDS_PITCH_R = Idstring("pitch_right")
local IDS_YAW_FWD = Idstring("yaw_backward")
local IDS_YAW_BWD = Idstring("yaw_forward")
StaticLayer = StaticLayer or class(CoreLayer.Layer)

function StaticLayer:init(owner, save_name, units_vector, slot_mask)
	StaticLayer.super.init(self, owner, save_name)
	self:load_unit_map_from_vector(units_vector)

	self._unit_name = ""
	self._current_pos = Vector3(0, 0, 0)
	self._offset_move_vec = Vector3(0, 0, 0)
	self._spawning_unit = nil
	self._point_units_at_current = nil
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
		self:delete_unit(unit)
	end

	managers.editor:set_continent(name)
	managers.editor:thaw_gui_lists()
end

function StaticLayer:clone(continent_name)
	local continent = continent_name and managers.editor:continent(continent_name) or managers.editor:current_continent()

	if continent:value("locked") then
		managers.editor:output_warning("Can't create units in continent " .. continent:name() .. " because it is locked!")

		return
	end

	managers.editor:freeze_gui_lists()

	if self._selected_unit and not self:condition() then
		local clone_units = self._selected_units
		self._selected_units = {}

		if managers.editor:using_groups() then
			self._clone_create_group = true
		end

		local command = CoreUndoableCommand.CloneUnit:new(self)

		for _, old_unit in ipairs(clone_units) do
			local name = old_unit:name():s()
			local pos = old_unit:position()
			local rot = old_unit:rotation()
			local reference = old_unit == self._selected_unit
			local new_unit = command:execute(name, pos, rot, continent_name)

			self:remove_name_id(new_unit)

			new_unit:unit_data().name_id = self:get_name_id(new_unit, old_unit:unit_data().name_id)

			managers.editor:unit_name_changed(new_unit)
			self:clone_edited_values(new_unit, old_unit)
		end

		self:update_unit_settings()
		managers.editor:add_undoable_command(command)
	end

	managers.editor:thaw_gui_lists()
	self:_cloning_done()
end

function StaticLayer:spawn_unit_release()
	self._spawning_unit = nil
end

function StaticLayer:spawn_unit()
	if not self._grab and not self:condition() then
		self:do_spawn_unit(self._unit_name)

		if not self:alt() then
			self._spawning_unit = true
		end
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

		if self._move_command then
			self._move_command:undo()

			self._move_command = nil
		end

		if self._rotate_command then
			self._rotate_command:undo()

			self._rotate_command = nil
		end
	end
end

function StaticLayer:set_unit_positions(pos, cancelled)
	if not self._grab then
		managers.editor:set_grid_altitude(pos.z)
	end

	self._move_command = self._move_command or CoreUndoableCommand.MoveUnit:new(self)

	self._move_command:execute(pos)

	if not self._grab and not cancelled then
		managers.editor:add_undoable_command(self._move_command)

		self._move_command = nil
	end
end

function StaticLayer:set_unit_position(unit, pos, rot)
	local new_pos = pos + unit:unit_data().local_pos:rotate_with(rot)

	unit:set_position(new_pos)

	unit:unit_data().world_pos = new_pos

	self:_on_unit_moved(unit, new_pos)
	unit:set_moving()
end

function StaticLayer:set_unit_rotations(rot, cancelled)
	self._rotate_command = self._rotate_command or CoreUndoableCommand.RotateUnit:new(self)

	self._rotate_command:execute(rot)

	if not self._grab and not cancelled then
		managers.editor:add_undoable_command(self._rotate_command)

		self._rotate_command = nil
	end
end

function StaticLayer:set_unit_rotation(unit, rot)
	local new_rot = rot * unit:unit_data().local_rot

	unit:set_rotation(new_rot)
	self:_on_unit_rotated(unit, new_rot)
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
		local rot_axis, ref_rot = nil
		local snap_axis = self:snap_rotation_axis()
		local step = self:snap_rotation()
		local coor_sys = managers.editor:coordinate_system()

		if coor_sys == "Local" then
			ref_rot = self._selected_unit:rotation()
		elseif coor_sys == "Camera" then
			ref_rot = managers.editor:camera():rotation()
		end

		if snap_axis == "x" then
			rot_axis = ref_rot and ref_rot:x() or math.X
		elseif snap_axis == "y" then
			rot_axis = ref_rot and ref_rot:y() or math.Y
		elseif snap_axis == "z" then
			rot_axis = ref_rot and ref_rot:z() or math.Z
		end

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
	if not self._grab then
		return
	end

	self._grab = false

	self:set_unit_positions(self._current_pos)

	self._offset_move_vec = Vector3(0, 0, 0)

	if self._selected_unit then
		managers.editor:set_grid_altitude(self._selected_unit:position().z)
	end
end

function StaticLayer:delete_selected_unit(btn, pressed)
	managers.editor:freeze_gui_lists()

	if self._selected_unit and not self:condition() then
		local command = CoreUndoableCommand.DeleteUnit:new(self)
		local to_delete = CoreTable.clone(self._selected_units)

		for _, unit in ipairs(to_delete) do
			if table.contains(self._created_units, unit) then
				command:execute(unit)
			else
				local unit_in_layer_name = managers.editor:unit_in_layer_name(unit)

				if unit_in_layer_name then
					managers.editor:output_warning("" .. tostring(unit:unit_data().name_id) .. " belongs to " .. tostring(unit_in_layer_name) .. " and cannot be deleted from here.")
				else
					managers.editor:output_warning("" .. tostring(unit:unit_data().name_id) .. " belongs to nothing and will be deleted")
					command:execute(unit)
				end
			end
		end

		managers.editor:add_undoable_command(command)
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
	if self._spawning_unit and self:alt() then
		self:update_aim_unit(self._selected_units[#self._selected_units])
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

	local coor_sys = managers.editor:coordinate_system()
	local ref_rot, mov_vec = nil

	if coor_sys == "Local" then
		ref_rot = self._selected_unit:rotation()
	elseif coor_sys == "Camera" then
		ref_rot = managers.editor:camera():rotation()
	end

	if self._ctrl:down(IDS_MOVE_FWD) then
		mov_vec = ref_rot and ref_rot:y() or math.Y
	elseif self._ctrl:down(IDS_MOVE_BWD) then
		mov_vec = ref_rot and -ref_rot:y() or -math.Y
	elseif self._ctrl:down(IDS_MOVE_R) then
		mov_vec = ref_rot and ref_rot:x() or math.X
	elseif self._ctrl:down(IDS_MOVE_L) then
		mov_vec = ref_rot and -ref_rot:x() or -math.X
	elseif self._ctrl:down(IDS_MOVE_UP) then
		mov_vec = ref_rot and ref_rot:z() or math.Z
	elseif self._ctrl:down(IDS_MOVE_DWN) then
		mov_vec = ref_rot and -ref_rot:z() or -math.Z
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

	local coor_sys = managers.editor:coordinate_system()
	local ref_rot, rot_axis = nil

	if coor_sys == "Local" then
		ref_rot = self._selected_unit:rotation()
	elseif coor_sys == "Camera" then
		ref_rot = managers.editor:camera():rotation()
	end

	if self._ctrl:down(IDS_ROLL_L) then
		rot_axis = ref_rot and ref_rot:z() or math.Z
	elseif self._ctrl:down(IDS_ROLL_R) then
		rot_axis = ref_rot and -ref_rot:z() or -math.Z
	elseif self._ctrl:down(IDS_PITCH_R) then
		rot_axis = ref_rot and ref_rot:y() or math.Y
	elseif self._ctrl:down(IDS_PITCH_L) then
		rot_axis = ref_rot and -ref_rot:y() or -math.Y
	elseif self._ctrl:down(IDS_YAW_FWD) then
		rot_axis = ref_rot and ref_rot:x() or math.X
	elseif self._ctrl:down(IDS_YAW_BWD) then
		rot_axis = ref_rot and -ref_rot:x() or -math.X
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
	local tt = "\t\t"
	local n = "\n"
	text = text .. "Create unit:" .. t .. "Right mouse button" .. n
	text = text .. tt .. "+Alt;   Create without selections" .. n
	text = text .. tt .. "+Ctrl;  Create keeping selections" .. n
	text = text .. tt .. "+Shift; Create keeping selections" .. n
	text = text .. tt .. "While holding down create unit press Alt to aim the unit in a direction" .. n
	text = text .. n
	text = text .. "Select unit:" .. t .. "Left mouse button" .. n
	text = text .. tt .. "+Alt;   Deselect only" .. n
	text = text .. tt .. "+Ctrl;  Add to selections" .. n
	text = text .. tt .. "+Shift; Select as focused" .. n
	text = text .. n
	text = text .. "Snap rotate:" .. t .. "Middle mouse button or [F] key" .. n
	text = text .. tt .. "+Alt;   Point at cursor" .. n
	text = text .. tt .. "+Ctrl;  Rotate by 1 degree" .. n
	text = text .. tt .. "+Shift; Reverse rotation" .. n
	text = text .. n
	text = text .. "Move unit:" .. t .. "Thumb mouse button (keep pressed to drag)" .. n
	text = text .. tt .. "+Shift; Position at cursor" .. n
	text = text .. n
	text = text .. "Remove unit:" .. t .. "Delete" .. n
	text = text .. "Align with unit:" .. t .. "Point and press P" .. n
	text = text .. "Sample unit:" .. t .. "Point and press B" .. n
	text = text .. "Replace unit:" .. t .. "Press R" .. n
	text = text .. "Clone unit:" .. t .. "Ctrl + V" .. n
	text = text .. n
	text = text .. "Toggle reference coordinate mode:" .. t .. "Numpad 0" .. n
	text = text .. n
	text = text .. "Rotate around X:" .. t .. "Numpad 8 and 2" .. n
	text = text .. "Rotate around Y:" .. t .. "Numpad 1 and 3" .. n
	text = text .. "Rotate around Z:" .. t .. "Numpad 4 and 6" .. n
	text = text .. n
	text = text .. "Clone values:       Point and press [M] key to clone values to all selected" .. n
	text = text .. tt .. "+Shift; Instead clone values from focused to pointed" .. n
	text = text .. n
	text = text .. "Reset rotation:     Numpad-Enter (reset but keeps Z-axis rotations)" .. n
	text = text .. tt .. "+Shift; Reset all axis" .. n
	text = text .. n
	text = text .. "Hide / Unide:" .. t .. "Ctrl + J to hide selected units" .. n
	text = text .. "Unhide All:" .. t .. "Ctrl + Shift + J to unide all hidden units" .. n

	return text
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
