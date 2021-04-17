local mvec3_set = mvector3.set
local mvec3_z = mvector3.z
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_lerp = mvector3.lerp
local mvec3_cpy = mvector3.copy
local mvec3_set_l = mvector3.set_length
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_len = mvector3.length
local mvec3_rot = mvector3.rotate_with
local mrot_lookat = mrotation.set_look_at
local mrot_slerp = mrotation.slerp
local math_abs = math.abs
local math_max = math.max
local math_min = math.min
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local tmp_vec4 = Vector3()
local temp_rot1 = Rotation()
local idstr_base = Idstring("base")
FlamerActionWalk = FlamerActionWalk or class(CopActionWalk)
FlamerActionWalk.DISTANCE_SPRINT_START = 30000
FlamerActionWalk.DISTANCE_SPRINT_END = 1200
FlamerActionWalk._walk_anim_velocities = {
	stand = {
		cbt = {
			walk = {
				bwd = 112.85,
				l = 118.53,
				fwd = 144,
				r = 122.48
			},
			run = {
				bwd = 357.23,
				l = 287.43,
				fwd = 361.5,
				r = 318.33
			}
		}
	}
}
FlamerActionWalk._walk_anim_velocities.stand.ntl = FlamerActionWalk._walk_anim_velocities.stand.cbt
FlamerActionWalk._walk_anim_velocities.stand.hos = FlamerActionWalk._walk_anim_velocities.stand.cbt
FlamerActionWalk._walk_anim_velocities.stand.wnd = FlamerActionWalk._walk_anim_velocities.stand.cbt
FlamerActionWalk._walk_anim_velocities.crouch = FlamerActionWalk._walk_anim_velocities.stand
FlamerActionWalk._walk_anim_lengths = {
	stand = {
		cbt = {
			walk = {
				bwd = 40,
				l = 40,
				fwd = 34,
				r = 38
			},
			run = {
				bwd = 21,
				l = 20,
				fwd = 20,
				r = 21
			}
		}
	}
}

for pose, stances in pairs(FlamerActionWalk._walk_anim_lengths) do
	for stance, speeds in pairs(stances) do
		for speed, sides in pairs(speeds) do
			for side, speed in pairs(sides) do
				sides[side] = speed * 0.03333
			end
		end
	end
end

FlamerActionWalk._walk_anim_lengths.stand.ntl = FlamerActionWalk._walk_anim_lengths.stand.cbt
FlamerActionWalk._walk_anim_lengths.stand.hos = FlamerActionWalk._walk_anim_lengths.stand.cbt
FlamerActionWalk._walk_anim_lengths.stand.wnd = FlamerActionWalk._walk_anim_lengths.stand.cbt
FlamerActionWalk._walk_anim_lengths.crouch = FlamerActionWalk._walk_anim_lengths.stand

-- Lines 78-82
function FlamerActionWalk:_get_max_walk_speed()
	local speed = self._common_data.char_tweak.move_speed[self._ext_anim.pose][self._haste][self._stance.name]

	return speed
end

-- Lines 84-304
function FlamerActionWalk:update(t)
	local dt = nil
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if vis_state == 1 then
		dt = t - self._last_upd_t
		self._last_upd_t = TimerManager:game():time()
	elseif self._skipped_frames < vis_state then
		self._skipped_frames = self._skipped_frames + 1

		return
	else
		self._skipped_frames = 1
		dt = t - self._last_upd_t
		self._last_upd_t = TimerManager:game():time()
	end

	local pos_new = nil

	if self._end_of_path and (not self._ext_anim.act or not self._ext_anim.walk) then
		if self._next_is_nav_link then
			self:_set_updator("_upd_nav_link_first_frame")
			self:update(t)

			return
		elseif self._persistent then
			self:_set_updator("_upd_wait")
		else
			self._expired = true

			if self._end_rot then
				self._ext_movement:set_rotation(self._end_rot)
			end
		end
	else
		self:_nav_chk_walk(t, dt, vis_state)
	end

	local move_dir = tmp_vec3

	mvec3_set(move_dir, self._last_pos)
	mvec3_sub(move_dir, self._common_data.pos)
	mvec3_set_z(move_dir, 0)

	if self._cur_vel < 0.1 or self._ext_anim.act and self._ext_anim.walk then
		move_dir = nil
	end

	local anim_data = self._ext_anim

	if move_dir and not self._expired then
		local face_fwd = tmp_vec1
		local wanted_walk_dir = nil
		local move_dir_norm = move_dir:normalized()

		if self._no_strafe or self._walk_turn then
			wanted_walk_dir = "fwd"
		else
			if self._curve_path_end_rot and mvector3.distance_sq(self._last_pos, self._footstep_pos) < 19600 then
				mvec3_set(face_fwd, self._common_data.fwd)
			elseif self._attention_pos then
				mvec3_set(face_fwd, self._attention_pos)
				mvec3_sub(face_fwd, self._common_data.pos)
			elseif self._footstep_pos then
				mvec3_set(face_fwd, self._footstep_pos)
				mvec3_sub(face_fwd, self._common_data.pos)
			else
				mvec3_set(face_fwd, self._common_data.fwd)
			end

			mvec3_set_z(face_fwd, 0)
			mvec3_norm(face_fwd)

			local face_right = tmp_vec2

			mvec3_cross(face_right, face_fwd, math.UP)
			mvec3_norm(face_right)

			local right_dot = mvec3_dot(move_dir_norm, face_right)
			local fwd_dot = mvec3_dot(move_dir_norm, face_fwd)

			if math_abs(right_dot) < math_abs(fwd_dot) then
				if (anim_data.move_l and right_dot < 0 or anim_data.move_r and right_dot > 0) and math_abs(fwd_dot) < 0.73 then
					wanted_walk_dir = anim_data.move_side
				elseif fwd_dot > 0 then
					wanted_walk_dir = "fwd"
				else
					wanted_walk_dir = "bwd"
				end
			elseif (anim_data.move_fwd and fwd_dot > 0 or anim_data.move_bwd and fwd_dot < 0) and math_abs(right_dot) < 0.73 then
				wanted_walk_dir = anim_data.move_side
			elseif right_dot > 0 then
				wanted_walk_dir = "r"
			else
				wanted_walk_dir = "l"
			end
		end

		local rot_new = nil

		if self._curve_path_end_rot then
			local dis_lerp = 1 - math.min(1, mvec3_dis(self._last_pos, self._footstep_pos) / 140)
			rot_new = temp_rot1

			mrot_slerp(rot_new, self._curve_path_end_rot, self._nav_link_rot or self._end_rot, dis_lerp)
		else
			local wanted_u_fwd = tmp_vec1

			mvec3_set(wanted_u_fwd, move_dir_norm)
			mvec3_rot(wanted_u_fwd, self._walk_side_rot[wanted_walk_dir])
			mrot_lookat(temp_rot1, wanted_u_fwd, math.UP)

			rot_new = temp_rot1

			mrot_slerp(rot_new, self._common_data.rot, rot_new, math.min(1, dt * 5))
		end

		self._ext_movement:set_rotation(rot_new)

		if self._chk_stop_dis and not self._common_data.char_tweak.no_run_stop then
			local end_dis = mvec3_dis(self._nav_point_pos(self._simplified_path[#self._simplified_path]), self._last_pos)

			if end_dis < self._chk_stop_dis then
				local stop_anim_fwd = not self._nav_link_rot and self._end_rot and self._end_rot:y() or move_dir_norm:rotate_with(self._walk_side_rot[wanted_walk_dir])
				local fwd_dot = mvec3_dot(stop_anim_fwd, move_dir_norm)
				local move_dir_r_norm = tmp_vec3

				mvec3_cross(move_dir_r_norm, move_dir_norm, math.UP)

				local fwd_dot = mvec3_dot(stop_anim_fwd, move_dir_norm)
				local r_dot = mvec3_dot(stop_anim_fwd, move_dir_r_norm)
				local stop_anim_side = nil

				if math.abs(r_dot) < math.abs(fwd_dot) then
					if fwd_dot > 0 then
						stop_anim_side = "fwd"
					else
						stop_anim_side = "bwd"
					end
				elseif r_dot > 0 then
					stop_anim_side = "l"
				else
					stop_anim_side = "r"
				end

				local stop_pose = nil

				if self._action_desc.end_pose then
					stop_pose = self._action_desc.end_pose
				else
					stop_pose = self._ext_anim.pose
				end

				if stop_pose ~= self._ext_anim.pose then
					local pose_redir_res = self._ext_movement:play_redirect(stop_pose)

					if not pose_redir_res then
						debug_pause_unit(self._unit, "STOP POSE FAIL!!!", self._unit, stop_pose)
					end
				end

				local stop_dis = self._anim_movement[stop_pose]["run_stop_" .. stop_anim_side]

				if stop_dis and end_dis < stop_dis then
					self._stop_anim_side = stop_anim_side
					self._stop_anim_fwd = stop_anim_fwd
					self._stop_dis = stop_dis

					self:_set_updator("_upd_stop_anim_first_frame")
				end
			end
		elseif self._walk_turn and not self._chk_stop_dis then
			local end_dis = mvec3_dis(self._curve_path[self._curve_path_index + 1], self._last_pos)

			if end_dis < 45 then
				self:_set_updator("_upd_walk_turn_first_frame")
			end
		end

		local pose = self._stance.values[4] > 0 and "wounded" or self._ext_anim.pose or "stand"
		local real_velocity = self._cur_vel
		local variant = self._haste

		if variant == "run" and not self._no_walk then
			if self._ext_anim.sprint then
				if real_velocity > 480 and self._ext_anim.pose == "stand" then
					variant = "sprint"
				elseif real_velocity > 250 then
					variant = "run"
				else
					variant = "walk"
				end
			elseif self._ext_anim.run then
				if not self._walk_anim_velocities[pose] then
					debug_pause_unit(self._unit, "No walk anim velocities for pose:", pose, inspect(self._walk_anim_velocities), self._unit)
				elseif not self._walk_anim_velocities[pose][self._stance.name] then
					debug_pause_unit(self._unit, "No walk anim velocities for (pose, stance name):", pose, self._stance.name, inspect(self._walk_anim_velocities), inspect(self._walk_anim_velocities[pose]), self._unit)
				elseif real_velocity > 530 and self._walk_anim_velocities[pose] and self._walk_anim_velocities[pose][self._stance.name] and self._walk_anim_velocities[pose][self._stance.name].sprint and self._ext_anim.pose == "stand" then
					variant = "sprint"
				elseif real_velocity > 250 then
					variant = "run"
				else
					variant = "walk"
				end
			elseif real_velocity > 530 and self._walk_anim_velocities[pose][self._stance.name].sprint and self._ext_anim.pose == "stand" then
				variant = "sprint"
			elseif real_velocity > 300 then
				variant = "run"
			else
				variant = "walk"
			end
		end

		self:_adjust_move_anim(wanted_walk_dir, variant)

		if not self._walk_anim_velocities[pose] or not self._walk_anim_velocities[pose][self._stance.name] or not self._walk_anim_velocities[pose][self._stance.name][variant] or not self._walk_anim_velocities[pose][self._stance.name][variant][wanted_walk_dir] then
			Application:error("Boom...", self._common_data.unit, "pose", pose, "stance", self._stance.name, "variant", variant, "wanted_walk_dir", wanted_walk_dir, self._machine:segment_state(Idstring("base")))

			return
		end

		local anim_walk_speed = self._walk_anim_velocities[pose][self._stance.name][variant][wanted_walk_dir]
		local wanted_walk_anim_speed = real_velocity / anim_walk_speed
		local distance_to_target = self._unit:brain():distance_to_target()

		if distance_to_target and distance_to_target < FlamerActionWalk.DISTANCE_SPRINT_START and FlamerActionWalk.DISTANCE_SPRINT_END < distance_to_target then
			wanted_walk_anim_speed = wanted_walk_anim_speed * 1.5
		end

		self:_adjust_walk_anim_speed(dt, wanted_walk_anim_speed)
	end

	self:_set_new_pos(dt)
end
