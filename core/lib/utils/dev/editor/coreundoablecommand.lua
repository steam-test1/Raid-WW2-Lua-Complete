core:module("CoreUndoableCommand")

CommandStack = CommandStack or class()

function CommandStack:init(history_size)
	self:clear()

	self._history_size = history_size
end

function CommandStack:clear()
	self._undo_stack = {}
	self._redo_stack = {}
end

function CommandStack:set_history_size(history_size)
	self._history_size = history_size

	if self._history_size < #self._undo_stack then
		table.crop(self._undo_stack, self._history_size)
	end
end

function CommandStack:add_command(command)
	if not command then
		return
	end

	table.insert(self._undo_stack, command)

	if self._history_size < #self._undo_stack then
		table.crop(self._undo_stack, self._history_size)
	end

	if #self._redo_stack > 0 then
		self._redo_stack = {}
	end
end

function CommandStack:undo()
	if #self._undo_stack == 0 then
		return
	end

	local command = table.remove(self._undo_stack, #self._undo_stack)

	command:undo()

	local description = command:description()

	if description then
		managers.editor:output("Undo " .. description)
	end

	table.insert(self._redo_stack, command)
end

function CommandStack:redo()
	if #self._redo_stack == 0 then
		return
	end

	local command = table.remove(self._redo_stack, #self._redo_stack)

	command:redo()

	local description = command:description()

	if description then
		managers.editor:output_info("Redo " .. description)
	end

	table.insert(self._undo_stack, command)
end

UndoableCommand = UndoableCommand or class()
UndoableCommand.NAME = "undoable_command"

function UndoableCommand:init(layer)
	self._layer = layer
end

function UndoableCommand:description()
	return "Generic Command"
end

function UndoableCommand:execute()
	Application:error("Execute not implemented")
end

function UndoableCommand:undo()
	Application:error("Undo not implemented")
end

function UndoableCommand:redo()
	Application:error("Redo not implemented")
end

function UndoableCommand:_change_to_layer()
	local layer_name = self._layer:get_layer_name()

	if layer_name then
		managers.editor:change_layer_notebook(layer_name)
	end
end

UnitCommand = UnitCommand or class(UndoableCommand)

function UnitCommand:init(layer)
	UnitCommand.super.init(self, layer)

	local selected_unit = layer:selected_unit()
	self._reference_unit = alive(selected_unit) and selected_unit:unit_data().unit_id
	self._selected_units = {
		self._reference_unit
	}

	for _, unit in ipairs(layer:selected_units()) do
		if unit ~= selected_unit then
			table.insert(self._selected_units, unit:unit_data().unit_id)
		end
	end
end

function UnitCommand:_select_units(unit_ids)
	local units = {}

	for _, unit_id in ipairs(unit_ids) do
		local unit = self._layer:unit_by_id(unit_id)

		if alive(unit) then
			table.insert(units, unit)
		end
	end

	self._layer:set_selected_units(units)
end

SelectUnit = SelectUnit or class(UnitCommand)
SelectUnit.NAME = "select_unit"

function SelectUnit:init(layer)
	SelectUnit.super.init(self, layer)
end

function SelectUnit:description()
	local reference = self._layer:unit_by_id(self._reference_unit)

	if not alive(reference) then
		return
	end

	if #self._selected_units > 0 then
		return "Select unit " .. reference:unit_data().name_id
	else
		return "Deselect Unit"
	end
end

function SelectUnit:execute(unit)
	local selected_unit = self._layer:selected_unit()
	self._reference_unit = alive(selected_unit) and selected_unit:unit_data().unit_id
	self._new_selected_units = {
		self._reference_unit
	}

	for _, unit in ipairs(self._layer:selected_units()) do
		if unit ~= selected_unit then
			table.insert(self._new_selected_units, unit:unit_data().unit_id)
		end
	end
end

function SelectUnit:undo()
	self:_change_to_layer()
	self:_select_units(self._selected_units)
end

function SelectUnit:redo()
	self:_change_to_layer()
	self:_select_units(self._new_selected_units)
end

MoveUnit = MoveUnit or class(UnitCommand)
MoveUnit.NAME = "move_unit"

function MoveUnit:init(layer)
	MoveUnit.super.init(self, layer)

	local reference = self._layer:selected_unit()
	self._start_pos = reference:position()
end

function MoveUnit:description()
	local start_pos = tostring(self._start_pos):gsub("Vector3", "")
	local end_pos = tostring(self._end_pos):gsub("Vector3", "")

	return string.format("Move unit from %s to %s", start_pos, end_pos)
end

function MoveUnit:execute(pos, select)
	self._end_pos = pos or self._end_pos

	self:_execute(pos, select)
end

function MoveUnit:_execute(pos, select)
	if not pos then
		return
	end

	local reference = self._layer:unit_by_id(self._reference_unit)

	if not alive(reference) then
		return
	end

	if select then
		self:_select_units(self._selected_units)
	end

	local selected_units = self._layer:selected_units()

	for _, unit in ipairs(selected_units) do
		if unit ~= reference then
			self._layer:set_unit_position(unit, pos, reference:rotation())
		end
	end

	reference:set_position(pos)

	reference:unit_data().world_pos = pos

	self._layer:_on_unit_moved(reference, pos)
end

function MoveUnit:undo()
	self:_change_to_layer()
	self:_execute(self._start_pos, true)
end

function MoveUnit:redo()
	self:_change_to_layer()
	self:_execute(self._end_pos, true)
end

RotateUnit = RotateUnit or class(UnitCommand)
RotateUnit.NAME = "rotate_unit"

function RotateUnit:init(layer)
	RotateUnit.super.init(self, layer)

	self._rot = Rotation()
end

function RotateUnit:description()
	local rot = tostring(self._rot):gsub("Rotation", "")

	return string.format("Rotate unit by %s", rot)
end

function RotateUnit:execute(rot, select)
	self._rot = rot and self._rot * rot or self._rot

	self:_execute(rot, select)
end

function RotateUnit:_execute(rot, select)
	if not rot then
		return
	end

	local reference = self._layer:unit_by_id(self._reference_unit)

	if not alive(reference) then
		return
	end

	if select then
		self:_select_units(self._selected_units)
	end

	local selected_units = self._layer:selected_units()
	local new_rot = rot * reference:rotation()

	reference:set_rotation(new_rot)
	self._layer:_on_unit_rotated(reference, new_rot)

	for _, unit in ipairs(selected_units) do
		if unit ~= reference then
			self._layer:set_unit_position(unit, reference:position(), new_rot)
			self._layer:set_unit_rotation(unit, new_rot)
		end
	end
end

function RotateUnit:undo()
	self:_change_to_layer()
	self:_execute(self._rot:inverse(), true)
end

function RotateUnit:redo()
	self:_change_to_layer()
	self:_execute(self._rot, true)
end

SpawnUnit = SpawnUnit or class(UndoableCommand)
SpawnUnit.NAME = "spawn_unit"

function SpawnUnit:init(layer)
	SpawnUnit.super.init(self, layer)

	self._units = {}
end

function SpawnUnit:description()
	if #self._units > 1 then
		return string.format("Spawn %d units", #self._units)
	elseif self._units[1] then
		local data = self._units[1]
		local unit_name = data.params[1]:s()

		return string.format("Spawn unit %s", unit_name)
	end
end

function SpawnUnit:execute(...)
	if select("#", ...) < 3 then
		return
	end

	local data = {
		params = {
			...
		}
	}

	table.insert(self._units, data)

	return self:_execute(data)
end

function SpawnUnit:_execute(data)
	local unit = self._layer:create_unit(unpack(data.params))
	data.id = unit:unit_data().unit_id
	local created_units = self._layer:created_units()

	table.insert(created_units, unit)

	local created_units_pairs = self._layer:created_units_pairs()
	created_units_pairs[data.id] = unit
	local unit_ids = {}

	for _, spawn_data in ipairs(self._units) do
		if spawn_data.id then
			table.insert(unit_ids, spawn_data.id)
		end
	end

	UnitCommand._select_units(self, unit_ids)

	return unit
end

function SpawnUnit:undo()
	self:_change_to_layer()

	for _, data in ipairs(self._units) do
		local unit = self._layer:unit_by_id(data.id)

		if alive(unit) then
			self._layer:delete_unit(unit, true)
		end
	end
end

function SpawnUnit:redo()
	self:_change_to_layer()

	for _, data in ipairs(self._units) do
		self:_execute(data)
	end
end

CloneUnit = CloneUnit or class(SpawnUnit)
CloneUnit.NAME = "clone_unit"

function CloneUnit:description()
	if #self._units > 1 then
		return string.format("Clone %d units", #self._units)
	elseif self._units[1] then
		local spawn = self._units[1]
		local unit_name = spawn.params[1]:s()

		return string.format("Clone unit %s", unit_name)
	end
end

DeleteUnit = DeleteUnit or class(UndoableCommand)
DeleteUnit.NAME = "delete_unit"

function DeleteUnit:init(layer)
	DeleteUnit.super.init(self, layer)

	self._units = {}
end

function DeleteUnit:description()
	if #self._units > 1 then
		return string.format("Delete %d units", #self._units)
	elseif self._units[1] then
		local data = self._units[1]
		local unit_name = data.name_id

		return string.format("Delete unit %s", unit_name)
	end
end

function DeleteUnit:execute(unit)
	if not alive(unit) then
		return
	end

	local data = self._layer:prepare_replace_params(unit)

	table.insert(self._units, data)
	self:_execute(unit)
end

function DeleteUnit:_execute(unit)
	if self._layer:selected_unit() == unit then
		self._layer:set_reference_unit(nil)
		self._layer:update_unit_settings()
	end

	local created_units = self._layer:created_units()

	table.delete(created_units, unit)

	local unit_pairs = self._layer:created_units_pairs()
	unit_pairs[unit:unit_data().unit_id] = nil

	self._layer:on_unit_deleted(unit)
	self._layer:remove_unit(unit)
end

function DeleteUnit:undo()
	self:_change_to_layer()

	local created_units = self._layer:recreate_units(nil, self._units)
	self._units = {}

	for _, unit in ipairs(created_units) do
		local data = self._layer:prepare_replace_params(unit)

		table.insert(self._units, data)
	end
end

function DeleteUnit:redo()
	self:_change_to_layer()

	for _, data in ipairs(self._units) do
		local unit_id = data.unit_id
		local unit = self._layer:unit_by_id(unit_id)

		if alive(unit) then
			self:_execute(unit)
		end
	end
end
