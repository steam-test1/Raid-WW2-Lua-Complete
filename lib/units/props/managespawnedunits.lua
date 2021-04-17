ManageSpawnedUnits = ManageSpawnedUnits or class()

-- Lines 4-8
function ManageSpawnedUnits:init(unit)
	self._unit = unit
	self._spawned_units = {}
	self._temp_link_units = {}
end

-- Lines 24-56
function ManageSpawnedUnits:spawn_unit(unit_id, align_obj_name, unit)
	local align_obj = self._unit:get_object(Idstring(align_obj_name))
	local spawn_unit = nil

	if type_name(unit) == "string" then
		if Network:is_server() then
			local spawn_pos = align_obj:position()
			local spawn_rot = align_obj:rotation()
			spawn_unit = safe_spawn_unit(Idstring(unit), spawn_pos, spawn_rot)
			spawn_unit:unit_data().parent_unit = self._unit
		end
	else
		spawn_unit = unit
	end

	if not spawn_unit then
		return
	end

	self._unit:link(Idstring(align_obj_name), spawn_unit, spawn_unit:orientation_object():name(), true)

	local unit_entry = {
		align_obj_name = align_obj_name,
		unit = spawn_unit
	}
	self._spawned_units[unit_id] = unit_entry

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_unit_spawn", self._unit, spawn_unit, align_obj_name, unit_id, "spawn_manager")
	end
end

-- Lines 58-63
function ManageSpawnedUnits:sync_link_unit(align_obj_name, spawn_unit)
	if align_obj_name and spawn_unit then
		self._unit:link(Idstring(align_obj_name), spawn_unit, spawn_unit:orientation_object():name(), true)
	end
end

-- Lines 83-108
function ManageSpawnedUnits:spawn_and_link_unit(joint_table, unit_id, unit)
	if not self[joint_table] then
		Application:error("No table named:", joint_table, "in unit file:", self._unit:name())

		return
	end

	if not unit_id then
		Application:error("param2", "nil:\n", self._unit:name())

		return
	end

	if not unit then
		Application:error("param3", "nil:\n", self._unit:name())

		return
	end

	self:spawn_unit(unit_id, self[joint_table][1], unit)

	self._sync_spawn_and_link = self._sync_spawn_and_link or {}
	self._sync_spawn_and_link[unit_id] = {
		joint_table = joint_table
	}

	if Network:is_server() then
		self:_link_joints(unit_id, joint_table)
	elseif self._temp_link_units[unit_id] then
		self._temp_link_units[unit_id] = nil

		self:_link_joints(unit_id, joint_table)
	end
end

-- Lines 121-135
function ManageSpawnedUnits:spawn_run_sequence(unit_id, sequence_name)
	local entry = self._spawned_units[unit_id]

	if not entry then
		return
	end

	if not alive(entry.unit) then
		return
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("run_spawn_unit_sequence", self._unit, "spawn_manager", unit_id, sequence_name)
	end

	self:_spawn_run_sequence(unit_id, sequence_name)
end

-- Lines 157-206
function ManageSpawnedUnits:local_push_child_unit(unit_id, mass, pow, vec3_a, vec3_b)
	if not unit_id then
		Application:error("param1", "nil:\n", self._spawned_units[unit_id].unit:name())

		return
	end

	if not mass then
		Application:error("param2", "nil:\n", self._spawned_units[unit_id].unit:name())

		return
	end

	if not pow then
		Application:error("param3", "nil:\n", self._spawned_units[unit_id].unit:name())

		return
	end

	if not vec3_a then
		Application:error("param4", "nil:\n", self._spawned_units[unit_id].unit:name())

		return
	end

	if not vec3_b then
		Application:error("param5", "nil:\n", self._spawned_units[unit_id].unit:name())

		return
	end

	if not self._spawned_units then
		return
	end

	if not self._spawned_units[unit_id] then
		return
	end

	if not alive(self._spawned_units[unit_id].unit) then
		return
	end

	local dir = Vector3()
	local spawnObj = self._unit:get_object(Idstring(vec3_a)):position()
	local forwObj = self._unit:get_object(Idstring(vec3_b)):position()

	mvector3.direction(dir, spawnObj, forwObj)
	mvector3.multiply(dir, pow)

	if self._push_spread then
		mvector3.spread(dir, self._push_spread)
	end

	self._spawned_units[unit_id].unit:push(mass, dir)

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("run_local_push_child_unit", self._unit, "spawn_manager", unit_id, mass, pow, vec3_a, vec3_b)
	end
end

-- Lines 216-233
function ManageSpawnedUnits:remove_unit(unit_id)
	local entry = self._spawned_units[unit_id]

	if Network:is_server() and alive(entry.unit) then
		entry.unit:set_slot(0)
	end

	self._spawned_units[unit_id] = nil
end

-- Lines 241-249
function ManageSpawnedUnits:destroy(unit)
	for i, entry in pairs(self._spawned_units) do
		if alive(entry.unit) then
			entry.unit:set_slot(0)
		end
	end

	self._spawned_units = {}
end

-- Lines 253-266
function ManageSpawnedUnits:save(data)
	if not alive(self._unit) or self._unit:id() == -1 then
		return
	end

	data.managed_spawned_units = {
		linked_joints = self._sync_spawn_and_link
	}

	for sync_id, unit_entry in pairs(self._spawned_units) do
		if alive(unit_entry.unit) and sync_id ~= -1 then
			managers.network:session():send_to_peers_synched("sync_unit_spawn", self._unit, unit_entry.unit, unit_entry.align_obj_name, sync_id, "spawn_manager")
		end
	end
end

-- Lines 270-275
function ManageSpawnedUnits:load(data)
	if not data.managed_spawned_units then
		return
	end

	self._sync_spawn_and_link = data.managed_spawned_units.linked_joints or {}
end

-- Lines 279-299
function ManageSpawnedUnits:_spawn_run_sequence(unit_id, sequence_name)
	local entry = self._spawned_units[unit_id]

	if not entry then
		return
	end

	if not alive(entry.unit) then
		return
	end

	if not sequence_name then
		Application:error("No sequence_name param passed\n", self._unit:name(), "\n")

		return
	end

	if self._spawned_units[unit_id].unit:damage():has_sequence(sequence_name) then
		self._spawned_units[unit_id].unit:damage():run_sequence_simple(sequence_name)
	else
		Application:error(sequence_name, "sequence does not exist in:\n", self._spawned_units[unit_id].unit:name())
	end
end

-- Lines 303-314
function ManageSpawnedUnits:_link_joints(unit_id, joint_table)
	for index, value in ipairs(self[joint_table]) do
		if index > 1 then
			local parent_object = self._unit:get_object(Idstring(value))
			local child_object = self._spawned_units[unit_id].unit:get_object(Idstring(value))

			child_object:link(parent_object)
			child_object:set_position(parent_object:position())
			child_object:set_rotation(parent_object:rotation())
		end
	end

	self._unit:set_moving()
end

-- Lines 318-327
function ManageSpawnedUnits:sync_unit_spawn(unit_id)
	if self._sync_spawn_and_link and self._sync_spawn_and_link[unit_id] then
		self:_link_joints(unit_id, self._sync_spawn_and_link[unit_id].joint_table)

		self._sync_spawn_and_link[unit_id] = nil
	else
		self._temp_link_units = self._temp_link_units or {}
		self._temp_link_units[unit_id] = true
	end
end
