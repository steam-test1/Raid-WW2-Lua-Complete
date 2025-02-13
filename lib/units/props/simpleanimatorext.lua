SimpleAnimatorExt = SimpleAnimatorExt or class()
local _EXT_ID = "simple_anim_ext"

function SimpleAnimatorExt:init(unit)
	self._unit = unit
	self._animations = {}

	if Network:is_server() then
		self._acted_objects = {}
	end
end

function SimpleAnimatorExt:animate_object_rotation_only(obj_id, duration, to_rot, from_rot)
	self:animate_object(obj_id, duration, nil, to_rot, nil, from_rot)
end

function SimpleAnimatorExt:animate_object(obj_id, duration, to_pos, to_rot, from_pos, from_rot)
	local object = self._unit:get_object(Idstring(obj_id))

	if not object then
		debug_pause_unit(self._unit, "An object is required for this function! Value is... " .. tostring(obj_id))

		return
	end

	duration = duration or 1
	to_pos = to_pos or object:local_position()
	from_pos = from_pos or object:local_position()
	to_rot = to_rot or object:local_rotation()
	from_rot = from_rot or object:local_rotation()
	self._animations[obj_id] = {
		paused = false,
		looping = false,
		_t = 0,
		obj_id = obj_id,
		object = object,
		duration = duration,
		to_pos = to_pos,
		to_rot = to_rot,
		from_pos = from_pos,
		from_rot = from_rot
	}

	if Network:is_server() then
		self._acted_objects[obj_id] = true
	end

	self:set_update_enabled_state(true)
end

function SimpleAnimatorExt:set_paused(obj_id, state)
	local data = self._animations[obj_id]

	if data then
		data.paused = state

		if not state then
			self:set_update_enabled_state(true)
		end
	else
		Application:warn("[SimpleAnimatorExt:pause_object] Not animation data " .. tostring(obj_id))
	end
end

function SimpleAnimatorExt:update(unit, t, dt)
	self:_update_animations(dt)

	if table.empty(self._animations) or self:_all_animations_paused() then
		Application:debug("[SimpleAnimatorExt:update] Completed all animations!")
		self:set_update_enabled_state(false)
	end
end

function SimpleAnimatorExt:_all_animations_paused()
	for k, data in pairs(self._animations) do
		if not data.paused then
			return false
		end
	end

	return true
end

function SimpleAnimatorExt:_update_animations(dt)
	for obj_id, data in pairs(self._animations) do
		if not data.looping and data.duration < data._t then
			data.object:set_local_position(data.to_pos)
			data.object:set_local_rotation(data.to_rot)

			self._animations[obj_id] = nil

			self._unit:damage():has_then_run_sequence_simple("animation_completed_" .. data.obj_id)
		elseif not data.paused then
			data._t = data._t + dt
			local lerp_time = data._t / data.duration

			data.object:set_local_position(math.lerp(data.from_pos, data.to_pos, lerp_time))
			data.object:set_local_rotation(math.rotation_lerp(data.from_rot, data.to_rot, lerp_time))
		end
	end

	self._unit:set_position(self._unit:position())
end

function SimpleAnimatorExt:set_update_enabled_state(state)
	self._unit:set_extension_update_enabled(Idstring(_EXT_ID), state)
end

function SimpleAnimatorExt:save(data)
	local state = {}
	data.SimpleAnimatorExt = state
	state._animations = {}

	for obj_id, anim_data in pairs(self._animations) do
		state._animations[obj_id] = deep_clone(anim_data)
		state._animations[obj_id].object = nil
	end

	state._object_transforms = {}

	for obj_id, _ in pairs(self._acted_objects) do
		local object = self._unit:get_object(Idstring(obj_id))
		state._object_transforms[obj_id] = {
			object:local_position(),
			object:local_rotation()
		}
	end
end

function SimpleAnimatorExt:load(data)
	local state = data.SimpleAnimatorExt

	if not state then
		return
	end

	for obj_id, pos_rot in pairs(state._object_transforms) do
		local object = self._unit:get_object(Idstring(obj_id))

		if object then
			object:set_local_position(pos_rot[1])
			object:set_local_rotation(pos_rot[2])
		end
	end

	if state._animations then
		self._animations = state._animations

		for obj_id, anim_data in pairs(self._animations) do
			local object = self._unit:get_object(Idstring(obj_id))

			if object then
				self._animations[obj_id].object = object
			end
		end

		self:set_update_enabled_state(true)
	end

	self._unit:set_position(self._unit:position())
end
