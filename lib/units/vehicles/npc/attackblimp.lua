AttackBlimp = AttackBlimp or class()
AttackBlimp.DEFAULT_TURN_SPEED = 1
AttackBlimp.DEFAULT_MOVE_SPEED = 750
AttackBlimp.DEFAULT_STOP_DISTANCE = 10000
AttackBlimp.DEFAULT_SLOW_DISTANCE = 24000
AttackBlimp.DEFAULT_HEIGHT_OVER_GROUND = 20000

function AttackBlimp:init(unit)
	Application:trace("[AttackBlimp] Blimbo Initialized!", unit)

	self._unit = unit
	self._detect_ids = self.detection_point_object and Idstring(self.detection_point_object)
	self._detect_obj = self.detection_point_object and self._unit:get_object(self._detect_ids)
	self._spotlight_ids = self.spotlight_point_object and Idstring(self.spotlight_point_object)
	self._spotlight_obj = self.spotlight_point_object and self._unit:get_object(self._spotlight_ids)
	self._barrage_ids = self.barrage_point_object and Idstring(self.barrage_point_object)
	self._barrage_obj = self.barrage_point_object and self._unit:get_object(self._barrage_ids)
	self._active = false
	self._target_player = nil
	self._travel_to = nil
end

function AttackBlimp:update(unit, t, dt)
	if not self:is_active() then
		return
	end

	self:_update_movement(dt)
	self:_update_detection(dt)
end

function AttackBlimp:_update_movement(dt)
	if not self._travel_to then
		return
	end

	local old_pos = self._unit:position()
	local travel_vec = self._travel_to - old_pos
	local travel_distance = travel_vec:length()

	if AttackBlimp.DEFAULT_STOP_DISTANCE < travel_distance then
		local travel_dir = travel_vec:with_z(travel_vec.z * 2):normalized()
		local old_rot = self._unit:rotation()
		local travel_rot = Rotation:look_at(travel_dir, math.UP)

		self._unit:set_rotation(Rotation(math.lerp(old_rot:yaw(), travel_rot:yaw(), AttackBlimp.DEFAULT_TURN_SPEED * dt), 0, 0))

		local speed_mul = (travel_distance - AttackBlimp.DEFAULT_STOP_DISTANCE) / AttackBlimp.DEFAULT_SLOW_DISTANCE
		speed_mul = math.clamp(speed_mul * speed_mul, 0.05, 1)

		self._unit:set_position(old_pos + travel_dir * AttackBlimp.DEFAULT_MOVE_SPEED * speed_mul * dt)
	else
		self._travel_to = nil

		Application:trace("[AttackBlimp] Blimbo Done MOVE!")
	end
end

function AttackBlimp:_update_detection(dt)
	local slot = managers.slot:get_mask("AI_visibility")
	local from = self._detect_obj and self._detect_obj:position() or self._unit:position()
	local to = nil

	for criminal_key, criminal_data in pairs(managers.groupai:state():all_char_criminals()) do
		if not criminal_data.status then
			if criminal_data.unit and criminal_data.unit == managers.player:local_player() and criminal_data.unit.movement and criminal_data.unit:movement().attention_handler then
				local attention = criminal_data.unit:movement():attention_handler()
				to = attention:get_detection_m_pos()
			end

			if to and from then
				local vis_ray = CopLogicBase._detection_ray(from, to, slot)

				if not vis_ray then
					-- Nothing
				end
			end
		end
	end
end

function AttackBlimp:debug_force_find_player()
	Application:trace("[AttackBlimp] Blimbo HUNT THEM!")

	local pos = nil

	for criminal_key, criminal_data in pairs(managers.groupai:state():all_char_criminals()) do
		if not criminal_data.status then
			self._target_player = criminal_data.unit
			pos = criminal_data.m_pos
			pos = pos:with_z(pos.z + AttackBlimp.DEFAULT_HEIGHT_OVER_GROUND)

			self:travel_to(pos)

			return
		end
	end
end

function AttackBlimp:travel_to(pos)
	Application:trace("[AttackBlimp] Blimbo Travelling!")

	self._travel_to = pos

	self:activate()
end

function AttackBlimp:get_barrage_launch_align()
	return self._barrage_obj or self._unit
end

function AttackBlimp:is_active()
	return not not self._active
end

function AttackBlimp:activate()
	if not self:is_active() then
		Application:trace("[AttackBlimp] Activating the almighty Blimbo!")
		self._unit:set_moving()

		self._active = true

		managers.barrage:register_barrage_unit("blimp", self._unit)

		if self._unit:damage() and self._unit:damage():has_sequence("activated") then
			self._unit:damage():run_sequence_simple("activated")
		end
	end
end

function AttackBlimp:deactivate()
	if self:is_active() then
		Application:trace("[AttackBlimp] De-Activating the almighty Blimbo!")

		self._active = false

		managers.barrage:unregister_barrage_unit("blimp", self._unit)

		if self._unit:damage() and self._unit:damage():has_sequence("deactivated") then
			self._unit:damage():run_sequence_simple("deactivated")
		end
	end
end
