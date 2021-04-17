CharacterManageSpawnedUnits = CharacterManageSpawnedUnits or class(ManageSpawnedUnits)
local mvec1 = Vector3()

function CharacterManageSpawnedUnits:spawn_character_debris(unit_id, align_obj_name, unit, push_mass)
	local align_obj = self._unit:get_object(Idstring(align_obj_name))
	local spawned_unit = nil
	local child_bodies = {}

	if not self._unit:character_damage() then
		Application:error("[CharacterManageSpawnedUnits:spawn_character_debris] Unit is missing CopDamage extension!", inspect(unit))

		return
	end

	if type_name(unit) == "string" then
		local spawn_pos = align_obj:position()
		spawned_unit = safe_spawn_unit(Idstring(unit), spawn_pos, Rotation(0, 0, 0))
		spawned_unit:unit_data().parent_unit = self._unit
	else
		Application:error("[CharacterManageSpawnedUnits:spawn_character_debris] Unit name provided is of type: " .. type(unit) .. ". String was expected")

		return
	end

	if not spawned_unit then
		Application:error("[CharacterManageSpawnedUnits:spawn_character_debris] Failed to spawn unit: ", unit)

		return
	end

	local materials = spawned_unit:materials()
	local decal_data = tweak_data.character.dismemberment_data.blood_decal_data[unit_id]

	for _, material in ipairs(materials) do
		material:set_variable(Idstring("gradient_uv_offset"), Vector3(decal_data[1], decal_data[2], 0))
		material:set_variable(Idstring("gradient_power"), decal_data[3])
	end

	local unit_entry = {
		align_obj_name = align_obj_name,
		unit = spawned_unit
	}
	self._spawned_units[unit_id] = unit_entry

	for i = 0, spawned_unit:num_bodies() - 1 do
		child_bodies[i] = spawned_unit:body(i)

		child_bodies[i]:set_enabled(false)
	end

	spawned_unit:set_visible(false)

	local joint_root_array = {
		"Neck",
		"LeftArm",
		"RightArm",
		"LeftUpLeg",
		"RightUpLeg"
	}

	for _, joint in ipairs(joint_root_array) do
		local child_joint = spawned_unit:get_object(Idstring(joint))

		if child_joint then
			local parent_joint = self._unit:get_object(Idstring(joint))

			child_joint:set_rotation(parent_joint:rotation())
			spawned_unit:set_moving()
		end
	end

	local joint_array = {
		"Head",
		"LeftForeArm",
		"RightForeArm",
		"LeftLeg",
		"RightLeg"
	}

	for _, joint in ipairs(joint_array) do
		local child_joint = spawned_unit:get_object(Idstring(joint))

		if child_joint then
			local parent_joint = self._unit:get_object(Idstring(joint))

			child_joint:set_local_rotation(parent_joint:local_rotation())
			spawned_unit:set_moving()
		end
	end

	local direction = self._unit:character_damage():get_last_damage_direction()

	if not direction then
		Application:error("Vector3 direction specified is nil")

		return
	end

	local que_data = {
		unit = spawned_unit,
		push_direction = direction,
		push_mass = push_mass
	}

	managers.queued_tasks:queue("enable_bodies", self.enable_debris_bodies, self, que_data, 0.02, nil)
end

function CharacterManageSpawnedUnits:enable_debris_bodies(data)
	local unit = data.unit
	local direction = data.push_direction
	local push_mass = data.push_mass

	if not alive(unit) then
		return
	end

	for i = 0, unit:num_bodies() - 1 do
		unit:body(i):set_enabled(true)
	end

	mvector3.set(mvec1, direction)
	mvector3.multiply(mvec1, 1000)
	unit:push(push_mass, mvec1)
	unit:set_visible(true)
end

function CharacterManageSpawnedUnits:destroy(unit)
	CharacterManageSpawnedUnits.super.destroy(self, unit)
	managers.queued_tasks:unqueue_all(nil, self)
end
