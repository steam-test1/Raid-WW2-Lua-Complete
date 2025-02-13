local FireSpawners = {
	LOCATOR_OFFSET = math.UP * 5
}
local temp_vect = Vector3()

function FireSpawners.find_surface(position, normal, search_host, slotmask)
	local start_pos = position
	local target_pos = position
	local raycast = search_host:raycast("ray", start_pos, target_pos, "slot_mask", slotmask)

	if not raycast then
		start_pos = position + math.UP * 20
		target_pos = position + math.DOWN * 150
		raycast = search_host:raycast("ray", start_pos, target_pos, "slot_mask", slotmask)
	end

	if not raycast then
		start_pos = start_pos + normal * 20
		target_pos = target_pos - normal * 50
		raycast = search_host:raycast("ray", start_pos, target_pos, "slot_mask", slotmask)
	end

	if not raycast then
		start_pos = position + math.UP * 20
		target_pos = position + math.DOWN * 400
		raycast = search_host:raycast("ray", start_pos, target_pos, "slot_mask", slotmask)
	end

	return raycast
end

function FireSpawners.recalculate_splinters(patch_data, splinter_vectors, search_host, slotmask)
	local hit_pos = patch_data.current_pos
	local splinters = {
		mvector3.copy(hit_pos)
	}

	for _, dir in ipairs(splinter_vectors) do
		mvector3.set(temp_vect, dir)
		mvector3.add(temp_vect, hit_pos)

		local splinter_ray = search_host:raycast("ray", hit_pos, temp_vect, "slot_mask", slotmask)
		local position = splinter_ray and splinter_ray.position or temp_vect
		local distance = splinter_ray and splinter_ray.distance or 0
		temp_vect = position - dir:normalized() * math.min(distance, 10)
		local near_splinter = false

		for _, s_pos in ipairs(splinters) do
			if mvector3.distance_sq(temp_vect, s_pos) < 900 then
				near_splinter = true

				break
			end
		end

		if not near_splinter then
			table.insert(splinters, mvector3.copy(temp_vect))
		end
	end

	patch_data.splinters = splinters
end

function FireSpawners.single(fire_tweak, params, patches_table)
	local down_ray = FireSpawners.find_surface(params.position, params.normal, params.search_host, params.slotmask)

	if not down_ray or not alive(down_ray.body) then
		return
	end

	local ray_pos = down_ray.position
	local ray_normal = down_ray.normal
	local ray_cross_normal = ray_normal:cross(math.UP)
	local ray_rot = Rotation(ray_cross_normal, ray_normal)
	local parent_object = down_ray.body:root_object()
	local parent_pos = parent_object:position()
	local parent_rot = parent_object:rotation():inverse()
	local effect_id = nil

	if fire_tweak.effect_name then
		local offset_pos = (ray_pos - parent_pos):rotate_with(parent_rot)
		local offset_rot = Rotation:rotation_difference(ray_rot, parent_rot)
		effect_id = World:effect_manager():spawn({
			effect = fire_tweak.effect_name,
			parent = parent_object,
			position = offset_pos,
			rotation = offset_rot
		})
	end

	local effect = {
		effect_id = effect_id,
		parent_object = parent_object,
		parent_pos = parent_pos,
		current_pos = ray_pos + FireSpawners.LOCATOR_OFFSET
	}

	FireSpawners.recalculate_splinters(effect, params.splinter_vectors, params.search_host, params.slotmask)
	table.insert(patches_table, effect)

	return true
end

function FireSpawners.parented(fire_tweak, params, patches_table)
	local parent_object = params.parent_object

	if not parent_object then
		return
	end

	local parent_pos = parent_object:position()
	local effect_id = nil

	if fire_tweak.effect_name then
		effect_id = World:effect_manager():spawn({
			effect = fire_tweak.effect_name,
			parent = parent_object,
			normal = params.normal,
			rotation = parent_object:rotation():inverse()
		})
	end

	local effect = {
		effect_id = effect_id,
		parent_object = parent_object,
		parent_pos = parent_pos,
		current_pos = parent_pos
	}

	table.insert(patches_table, effect)
	FireSpawners.recalculate_splinters(effect, params.splinter_vectors, params.search_host, params.slotmask)

	return true
end

function FireSpawners.hex(fire_tweak, params, patches_table)
	local center_position = params.position
	local normal = params.normal
	local search_host = params.search_host
	local slotmask = params.slotmask
	local iterations = fire_tweak.iterations
	local success = FireSpawners.single(fire_tweak, params, patches_table)

	if success then
		center_position = patches_table[1].current_pos + math.UP * 8
	end

	local offset = Vector3(normal.z, normal.z, -normal.x - normal.y)

	if offset.x == 0 and offset.y == 0 and offset.z == 0 then
		offset = Vector3(-normal.y - normal.z, normal.x, normal.x)
	end

	mvector3.normalize(offset)
	mvector3.multiply(offset, fire_tweak.range * 1.5)

	local rotation = Rotation()
	local axis_angle = 360 / iterations
	axis_angle = math.random(axis_angle * 0.88, axis_angle * 1.22)

	mrotation.set_axis_angle(rotation, normal, axis_angle)

	for i = 1, iterations do
		local random_offset = 0.8 + math.random() * 0.4
		params.position = center_position + offset * random_offset
		local raycast = search_host:raycast("ray", center_position, params.position, "slot_mask", slotmask)

		if not raycast then
			FireSpawners.single(fire_tweak, params, patches_table)
		end

		mvector3.rotate_with(offset, rotation)
	end
end

function FireSpawners.line(fire_tweak, params, patches_table)
	local rotation = params.rotation or Rotation()
	local iterations = fire_tweak.iterations or 0

	mrotation.set_yaw_pitch_roll(rotation, 0, rotation:yaw(), 0)

	local offset = math.X * fire_tweak.range * 1.5

	mvector3.rotate_with(offset, rotation)

	local ray_hit = nil
	local next_position = params.position + offset
	local search_host = params.search_host

	for i = 0, iterations do
		local success = FireSpawners.single(fire_tweak, params, patches_table)

		if not success then
			break
		end

		ray_hit = search_host:raycast("ray", params.position, next_position, "slot_mask", params.slotmask, "report")

		if ray_hit then
			break
		end

		params.position = next_position
		next_position = params.position + offset
	end
end

return FireSpawners
