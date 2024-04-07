AttackBlimp = AttackBlimp or class()
AttackBlimp.DEFAULT_TURN_SPEED = 1
AttackBlimp.DEFAULT_MOVE_SPEED = 650
AttackBlimp.DEFAULT_STOP_DISTANCE = 6400
AttackBlimp.DEFAULT_SLOW_DISTANCE = 16000
AttackBlimp.DEFAULT_HEIGHT_OVER_GROUND = 24000

function AttackBlimp:init(unit)
	Application:trace("[AttackBlimp:init] Blimbo Initialized!", unit)

	self._unit = unit
	self._detect_obj = unit.detection_point_object
end

function AttackBlimp:update(unit, t, dt)
	self:_update_movement(dt)
end

function AttackBlimp:_update_movement(dt)
	if self._travel_to then
		local old_pos = self._unit:position()
		local travel_vec = self._travel_to - old_pos
		local travel_distance = travel_vec:length()

		if travel_distance > AttackBlimp.DEFAULT_STOP_DISTANCE then
			local old_rot = self._unit:rotation()
			local travel_rot = Rotation:look_at(travel_dir, math.UP)

			self._unit:set_rotation(Rotation(math.lerp(old_rot:yaw(), travel_rot:yaw(), AttackBlimp.DEFAULT_TURN_SPEED * dt), 0, 0))

			local travel_dir = travel_vec:normalized()
			local speed_mul = (travel_distance - AttackBlimp.DEFAULT_STOP_DISTANCE) / AttackBlimp.DEFAULT_SLOW_DISTANCE

			speed_mul = math.clamp(speed_mul * speed_mul, 0.05, 1)

			self._unit:set_position(old_pos + travel_dir * AttackBlimp.DEFAULT_MOVE_SPEED * speed_mul * dt)
		else
			self._travel_to = nil

			Application:trace("[AttackBlimp:update] Blimbo Done MOVE!")
		end
	end
end

function AttackBlimp:debug_force_find_player()
	Application:trace("[AttackBlimp:debug_force_find_player] Blimbo HUNT THEM!")

	local pos

	for criminal_key, criminal_data in pairs(managers.groupai:state():all_char_criminals()) do
		if not criminal_data.status then
			pos = criminal_data.m_pos
			pos = pos:with_z(pos.z + AttackBlimp.DEFAULT_HEIGHT_OVER_GROUND)

			self:travel_to(pos)

			return
		end
	end
end

function AttackBlimp:travel_to(pos)
	Application:trace("[AttackBlimp:travel_to] Blimbo Travelling!")

	self._travel_to = pos
end
