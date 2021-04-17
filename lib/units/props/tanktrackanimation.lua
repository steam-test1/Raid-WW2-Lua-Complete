TankTrackAnimation = TankTrackAnimation or class()
local ids_uv_offset = Idstring("uv_offset")

function TankTrackAnimation:init(unit)
	self._unit = unit

	self._unit:set_extension_update_enabled(Idstring("tank_track_animation"), true)

	self._left_track_mat = self._unit:material(Idstring("mat_track_left"))
	self._left_ref_object = self._unit:get_object(Idstring("wheel_left_drive"))
	self._prev_left_pos = self._left_ref_object:position()
	self._right_track_mat = self._unit:material(Idstring("mat_track_right"))
	self._right_ref_object = self._unit:get_object(Idstring("wheel_right_drive"))
	self._prev_right_pos = self._right_ref_object:position()
	self._wheels_left = {}
	self._wheels_right = {}

	for i = 1, 20 do
		local o = self._unit:get_object(Idstring("wheel_left_" .. i))

		if o then
			table.insert(self._wheels_left, {
				o,
				self._wheel_diameter
			})
		else
			break
		end

		o = self._unit:get_object(Idstring("wheel_right_" .. i))

		if o then
			table.insert(self._wheels_right, {
				o,
				self._wheel_diameter
			})
		end
	end

	table.insert(self._wheels_left, {
		self._unit:get_object(Idstring("wheel_left_tension")),
		self._tension_diameter
	})
	table.insert(self._wheels_right, {
		self._unit:get_object(Idstring("wheel_right_tension")),
		self._drive_diameter
	})
	table.insert(self._wheels_left, {
		self._unit:get_object(Idstring("wheel_left_drive")),
		self._tension_diameter
	})
	table.insert(self._wheels_right, {
		self._unit:get_object(Idstring("wheel_right_drive")),
		self._drive_diameter
	})

	self._left_tesnion = self._unit:get_object(Idstring("wheel_left_tension"))
end

function TankTrackAnimation:update(unit, t, dt)
	local curr_left_tension_pos = self._left_tesnion:position()
	local curr_left_pos = self._left_ref_object:position()
	local forward_dir = (curr_left_pos - curr_left_tension_pos):normalized()
	local diff_left_pos = curr_left_pos - self._prev_left_pos
	local diff_left_sign = math.sign(mvector3.dot(diff_left_pos, forward_dir))
	local len_diff_left = diff_left_pos:length()
	local uv_diff_left = diff_left_sign * len_diff_left / self._track_length
	local uv_left = self._left_track_mat:get_variable(ids_uv_offset).x + uv_diff_left

	self._left_track_mat:set_variable(ids_uv_offset, Vector3(uv_left, 0, 0))

	for _, wheel in ipairs(self._wheels_left) do
		local c = wheel[2] * math.pi
		local angle = -diff_left_sign * len_diff_left / c * 360
		local rot = wheel[1]:local_rotation() * Rotation(0, angle, 0)

		wheel[1]:set_local_rotation(rot)
	end

	local curr_right_pos = self._right_ref_object:position()
	local diff_right_pos = curr_right_pos - self._prev_right_pos
	local diff_right_sign = math.sign(mvector3.dot(diff_right_pos, forward_dir))
	local len_diff_right = diff_right_pos:length()
	local uv_diff_right = diff_right_sign * len_diff_right / self._track_length
	local uv_right = self._right_track_mat:get_variable(ids_uv_offset).x + uv_diff_right

	self._right_track_mat:set_variable(ids_uv_offset, Vector3(uv_right, 0, 0))

	for _, wheel in ipairs(self._wheels_right) do
		local c = wheel[2] * math.pi
		local angle = -diff_right_sign * len_diff_left / c * 360
		local rot = wheel[1]:local_rotation() * Rotation(0, angle, 0)

		wheel[1]:set_local_rotation(rot)
	end

	self._prev_left_pos = curr_left_pos
	self._prev_right_pos = curr_right_pos
end
