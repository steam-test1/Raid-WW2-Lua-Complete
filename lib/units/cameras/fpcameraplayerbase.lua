FPCameraPlayerBase = FPCameraPlayerBase or class(UnitBase)
FPCameraPlayerBase.IDS_EMPTY = Idstring("empty")
FPCameraPlayerBase.IDS_NOSTRING = Idstring("")
FPCameraPlayerBase.bipod_location = nil
FPCameraPlayerBase.camera_last_pos = nil
FPCameraPlayerBase.MAX_PITCH = 85
local mvec3_set = mvector3.set
local mvec3_set_zero = mvector3.set_zero
local mvec3_set_x = mvector3.set_x
local mvec3_set_y = mvector3.set_y
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local mvec3_cross = mvector3.cross
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local tmp_rot1 = Rotation()
local math_sqrt2 = math.sqrt(2)

function FPCameraPlayerBase:init(unit)
	UnitBase.init(self, unit, true)

	self._unit = unit

	unit:set_timer(managers.player:player_timer())
	unit:set_animation_timer(managers.player:player_timer())
	unit:set_approximate_orientation(false)

	self._anims_enabled = true
	self._obj_eye = self._unit:orientation_object()
	self._weap_align = self._unit:get_object(Idstring("right_weapon_align"))
	self._camera_properties = {
		pitch = 0.5,
		spin = 0
	}
	self._output_data = {
		position = unit:position(),
		rotation = unit:rotation()
	}
	self._head_stance = {
		translation = Vector3(),
		rotation = Rotation()
	}
	self._shoulder_stance = {
		translation = Vector3(),
		rotation = Rotation()
	}
	self._vel_overshot = {
		translation = Vector3(),
		rotation = Rotation(),
		last_yaw = 0,
		last_pitch = 0,
		target_yaw = 0,
		target_pitch = 0
	}
	self._aim_assist = {
		direction = Vector3(),
		distance = 0,
		mrotation = Rotation()
	}
	self._aim_assist_sticky = {
		direction = Vector3(),
		distance = 0,
		mrotation = Rotation(),
		distance_to_aim_line = 0,
		is_sticky = true
	}
	self._fov = {
		fov = 75
	}
	self._input = {}
	self._tweak_data = tweak_data.input.gamepad
	self._camera_properties.look_speed_current = self._tweak_data.look_speed_standard
	self._camera_properties.look_speed_transition_timer = 0
	self._camera_properties.target_tilt = 0
	self._camera_properties.current_tilt = 0
	self._view_kick = {
		velocity = 0,
		direction = Vector3(),
		delta = Vector3()
	}

	self:check_flashlight_enabled()
	self:load_fps_mask_units()

	self._use_anim_allowed = true
end

function FPCameraPlayerBase:set_parent_unit(parent_unit)
	self._parent_unit = parent_unit
	self._parent_movement_ext = self._parent_unit:movement()

	parent_unit:base():add_destroy_listener("FPCameraPlayerBase", callback(self, self, "parent_destroyed_clbk"))

	local controller_type = self._parent_unit:base():controller():get_default_controller_id()

	if controller_type == "keyboard" then
		self._look_function = callback(self, self, "_pc_look_function")
	elseif controller_type == "steampad" then
		self._look_function = callback(self, self, "_steampad_look_function")
		self._tweak_data.uses_keyboard = true
	else
		self._look_function = callback(self, self, "_gamepad_look_function")
		self._tweak_data.uses_keyboard = false
	end
end

function FPCameraPlayerBase:parent_destroyed_clbk(parent_unit)
	self._unit:set_extension_update_enabled(Idstring("base"), false)
	self:set_slot(self._unit, 0)

	self._parent_unit = nil
end

function FPCameraPlayerBase:reset_properties()
	self._camera_properties.spin = self._parent_unit:rotation():y():to_polar().spin
end

function FPCameraPlayerBase:update(unit, t, dt)
	if managers.menu.loading_screen_visible or managers.system_menu:is_active() then
		return
	end

	if self._tweak_data.aim_assist_use_sticky_aim then
		self:_update_aim_assist_sticky(t, dt)
	end

	self._parent_unit:base():controller():get_input_axis_clbk("look", callback(self, self, "_update_rot"))
	self:_update_stance(t, dt)
	self:_update_movement(t, dt)

	if managers.player:current_state() == "driving" then
		self:_set_camera_position_in_vehicle()
	else
		self._parent_unit:camera():set_position(self._output_data.position)
		self._parent_unit:camera():set_rotation(self._output_data.rotation)
	end

	if self._fov.dirty then
		self._parent_unit:camera():set_FOV(self._fov.fov)

		self._fov.dirty = nil
	end
end

function FPCameraPlayerBase:check_flashlight_enabled()
	if managers.game_play_central:flashlights_on_player_on() then
		if not alive(self._light) then
			self._light = World:create_light("spot|specular")

			self._light:set_spot_angle_end(45)
			self._light:set_far_range(1000)
		end

		if not self._light_effect then
			self._light_effect = World:effect_manager():spawn({
				effect = Idstring("effects/vanilla/weapons/flashlight/fp_flashlight"),
				position = self._unit:position(),
				rotation = Rotation()
			})
		end

		self._light:set_enable(true)
		World:effect_manager():set_hidden(self._light_effect, false)
	elseif alive(self._light) then
		self._light:set_enable(false)
		World:effect_manager():set_hidden(self._light_effect, true)
	end
end

function FPCameraPlayerBase:start_shooting()
end

function FPCameraPlayerBase:stop_shooting(wait)
end

function FPCameraPlayerBase:break_recoil()
	self._view_kick.x.velocity = 0
	self._view_kick.x.delta = 0
	self._view_kick.y.velocity = 0
	self._view_kick.y.delta = 0

	self:stop_shooting()
end

local bezier_values = {
	0,
	0,
	1,
	1
}

function FPCameraPlayerBase:_update_stance(t, dt)
	if self._shoulder_stance.transition then
		local trans_data = self._shoulder_stance.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			mvector3.set(self._shoulder_stance.translation, trans_data.end_translation)

			self._shoulder_stance.rotation = trans_data.end_rotation
			self._shoulder_stance.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.bezier(bezier_values, progress)

			mvector3.lerp(self._shoulder_stance.translation, trans_data.start_translation, trans_data.end_translation, progress_smooth)

			self._shoulder_stance.rotation = trans_data.start_rotation:slerp(trans_data.end_rotation, progress_smooth)
		end
	end

	if self._head_stance.transition then
		local trans_data = self._head_stance.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			mvector3.set(self._head_stance.translation, trans_data.end_translation)

			self._head_stance.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.bezier(bezier_values, progress)

			mvector3.lerp(self._head_stance.translation, trans_data.start_translation, trans_data.end_translation, progress_smooth)
		end
	end

	if self._vel_overshot.transition then
		local trans_data = self._vel_overshot.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			self._vel_overshot.yaw_neg = trans_data.end_yaw_neg
			self._vel_overshot.yaw_pos = trans_data.end_yaw_pos
			self._vel_overshot.pitch_neg = trans_data.end_pitch_neg
			self._vel_overshot.pitch_pos = trans_data.end_pitch_pos

			mvector3.set(self._vel_overshot.pivot, trans_data.end_pivot)

			self._vel_overshot.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.bezier(bezier_values, progress)
			self._vel_overshot.yaw_neg = math.lerp(trans_data.start_yaw_neg, trans_data.end_yaw_neg, progress_smooth)
			self._vel_overshot.yaw_pos = math.lerp(trans_data.start_yaw_pos, trans_data.end_yaw_pos, progress_smooth)
			self._vel_overshot.pitch_neg = math.lerp(trans_data.start_pitch_neg, trans_data.end_pitch_neg, progress_smooth)
			self._vel_overshot.pitch_pos = math.lerp(trans_data.start_pitch_pos, trans_data.end_pitch_pos, progress_smooth)

			mvector3.lerp(self._vel_overshot.pivot, trans_data.start_pivot, trans_data.end_pivot, progress_smooth)
		end
	end

	self:_calculate_soft_velocity_overshot(dt)

	if self._fov.transition then
		local trans_data = self._fov.transition
		local elapsed_t = t - trans_data.start_t

		if trans_data.duration < elapsed_t then
			self._fov.fov = trans_data.end_fov
			self._fov.transition = nil
		else
			local progress = elapsed_t / trans_data.duration
			local progress_smooth = math.max(math.min(math.bezier(bezier_values, progress), 1), 0)
			self._fov.fov = math.lerp(trans_data.start_fov, trans_data.end_fov, progress_smooth)
		end

		self._fov.dirty = true
	end
end

local mrot1 = Rotation()
local mrot2 = Rotation()
local mrot3 = Rotation()
local mrot4 = Rotation()
local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mvec4 = Vector3()

function FPCameraPlayerBase:_update_movement(t, dt)
	if self._force_rotation2 then
		self._parent_unit:camera():set_rotation(self._force_rotation2)

		self._output_data.rotation = self._force_rotation2
		self._force_rotation2 = nil

		return
	end

	if not self._previous_direction then
		self._previous_direction = mvector3.copy(self._parent_unit:camera():forward())
	end

	local current_direction = mvector3.copy(self._parent_unit:camera():forward())
	self._movement_speed = mvector3.angle(current_direction, self._previous_direction) / dt
	self._previous_direction = current_direction
	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)
	mvector3.add(new_head_pos, self._head_stance.translation)

	local stick_input_x = 0
	local stick_input_y = 0
	local aim_assist_x, aim_assist_y = self:_get_aim_assist(t, dt, self._tweak_data.aim_assist_snap_speed, self._aim_assist)
	local recoil_x, recoil_y = self:_update_view_kick_vector(t, dt)
	stick_input_x = stick_input_x + aim_assist_x + recoil_x
	stick_input_y = stick_input_y + aim_assist_y + recoil_y
	local look_polar_spin = data.spin - stick_input_x
	local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -FPCameraPlayerBase.MAX_PITCH, FPCameraPlayerBase.MAX_PITCH)

	if not self._limits or not self._limits.spin then
		look_polar_spin = look_polar_spin % 360
	end

	local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
	local look_vec = look_polar:to_vector()
	local cam_offset_rot = mrot3

	mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)
	mrotation.set_zero(new_head_rot)
	mrotation.multiply(new_head_rot, self._head_stance.rotation)
	mrotation.multiply(new_head_rot, cam_offset_rot)

	data.pitch = look_polar_pitch
	data.spin = look_polar_spin
	self._output_data.position = new_head_pos
	self._output_data.rotation = new_head_rot or self._output_data.rotation

	if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
		self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
	end

	if self._camera_properties.current_tilt ~= 0 then
		self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
	end

	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, self._output_data.rotation)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, self._output_data.rotation)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)
	self:set_position(new_shoulder_pos)
	self:set_rotation(new_shoulder_rot)
end

function FPCameraPlayerBase:force_rot(rot)
	self._force_rotation = rot
	self._force_rotation2 = rot
end

local mvec1 = Vector3()

function FPCameraPlayerBase:_update_rot(axis, unscaled_axis)
	if self._force_rotation then
		self._parent_unit:camera():set_rotation(self._force_rotation)

		self._output_data.rotation = self._force_rotation
		local forward_polar = self._force_rotation:y():to_polar()
		self._camera_properties.spin = forward_polar.spin
		self._camera_properties.pitch = forward_polar.pitch
		self._force_rotation = nil

		return
	end

	if self._animate_pitch then
		self:animate_pitch_upd()
	end

	local t = managers.player:player_timer():time()
	local dt = t - (self._last_rot_t or t)
	self._last_rot_t = t
	local data = self._camera_properties
	local new_head_pos = mvec2
	local new_shoulder_pos = mvec1
	local new_shoulder_rot = mrot1
	local new_head_rot = mrot2

	self._parent_unit:m_position(new_head_pos)

	if managers.player:current_state() ~= "turret" then
		mvector3.add(new_head_pos, self._head_stance.translation)
	end

	self._input.look = axis
	self._input.look_multiplier = self._parent_unit:base():controller():get_setup():get_connection("look"):get_multiplier()
	local stick_input_x, stick_input_y = self._look_function(axis, self._input.look_multiplier, dt, unscaled_axis)
	local multiplier = 1

	if self._parent_unit:movement()._current_state:in_steelsight() then
		local equipped_unit_base = managers.player:player_unit():movement():current_state()._equipped_unit:base()

		if equipped_unit_base and equipped_unit_base.get_name_id and equipped_unit_base.get_reticle_obj and equipped_unit_base:get_reticle_obj() then
			local weapon_id = equipped_unit_base:get_name_id()
			local stances = tweak_data.player.stances[weapon_id] or tweak_data.player.stances.default
			multiplier = stances.steelsight.camera_sensitivity_multiplier or multiplier
		end
	end

	stick_input_x = stick_input_x * self:_get_aim_assist_look_multiplier() * multiplier
	stick_input_y = stick_input_y * self:_get_aim_assist_look_multiplier() * multiplier
	self._stick_input_length = mvector3.length(Vector3(stick_input_x, stick_input_y, 0))

	if managers.player:current_state() == "turret" then
		local current_State = self._parent_unit:movement()._current_state
		local camera_speed_limit = current_State.get_camera_speed_limit and current_State:get_camera_speed_limit()

		if camera_speed_limit then
			stick_input_x = math.clamp(stick_input_x, -camera_speed_limit, camera_speed_limit)
			stick_input_y = math.clamp(stick_input_y, -camera_speed_limit, camera_speed_limit)
		end
	end

	local look_polar_spin = data.spin - stick_input_x
	local look_polar_pitch = math.clamp(data.pitch + stick_input_y, -FPCameraPlayerBase.MAX_PITCH, FPCameraPlayerBase.MAX_PITCH)
	local player_state = managers.player:current_state()

	if player_state == "turret" and not self._limits then
		self._turret_unit = managers.player:get_turret_unit()
		local turret_weapon_name = managers.player:get_turret_unit():weapon():get_name_id()
		local spin = tweak_data.weapon[turret_weapon_name].camera_limit_horizontal or 45
		local pitch = tweak_data.weapon[turret_weapon_name].camera_limit_vertical or 30
		local mid_spin = (self._turret_unit:rotation():y():to_polar().spin + 360) % 360
		local mid_pitch = tweak_data.weapon[turret_weapon_name].camera_limit_vertical_mid or 0

		self:set_limits(spin, pitch, mid_spin, mid_pitch)
	end

	if self._limits then
		if self._limits.spin then
			local angle = look_polar_spin
			local mid = self._limits.spin.mid
			local dist_angle_to_mid = math.abs(mid - angle) % 360

			if dist_angle_to_mid > 180 then
				dist_angle_to_mid = 360 - dist_angle_to_mid
			end

			local d = dist_angle_to_mid / self._limits.spin.offset
			d = math.clamp(d, -1, 1)
			look_polar_spin = data.spin - math.lerp(stick_input_x, 0, math.abs(d))
		end

		if self._limits.pitch then
			local angle = look_polar_pitch
			local mid = self._limits.pitch.mid
			local dist_angle_to_mid = math.abs(mid - angle) % 360

			if dist_angle_to_mid > 180 then
				dist_angle_to_mid = 360 - dist_angle_to_mid
			end

			local d = dist_angle_to_mid / self._limits.pitch.offset
			d = math.clamp(d, -1, 1)
			look_polar_pitch = data.pitch + math.lerp(stick_input_y, 0, math.abs(d))
			look_polar_pitch = math.clamp(look_polar_pitch, -FPCameraPlayerBase.MAX_PITCH, FPCameraPlayerBase.MAX_PITCH)
		end
	end

	if not self._limits or not self._limits.spin then
		look_polar_spin = look_polar_spin % 360
	end

	local look_polar = Polar(1, look_polar_pitch, look_polar_spin)
	local look_vec = look_polar:to_vector()
	local cam_offset_rot = mrot3

	mrotation.set_look_at(cam_offset_rot, look_vec, math.UP)

	if self._animate_pitch == nil then
		mrotation.set_zero(new_head_rot)
		mrotation.multiply(new_head_rot, self._head_stance.rotation)
		mrotation.multiply(new_head_rot, cam_offset_rot)

		data.pitch = look_polar_pitch
		data.spin = look_polar_spin
	end

	self._output_data.position = new_head_pos

	if self._camera_properties.camera_offset then
		mvector3.set(mvec4, self._camera_properties.camera_offset)
		mvector3.rotate_with(mvec4, Rotation(self._output_data.rotation:yaw(), 0, 0))
		mvector3.add(self._output_data.position, mvec4)
	end

	if self._parachute_exit then
		self._parachute_exit = false
		self._output_data.rotation = self._parent_unit:movement().fall_rotation

		mrotation.multiply(self._output_data.rotation, self._parent_unit:camera():rotation())

		data.spin = self._output_data.rotation:y():to_polar().spin
	else
		self._output_data.rotation = new_head_rot or self._output_data.rotation
	end

	if self._camera_properties.current_tilt ~= self._camera_properties.target_tilt then
		self._camera_properties.current_tilt = math.step(self._camera_properties.current_tilt, self._camera_properties.target_tilt, 150 * dt)
	end

	if self._camera_properties.current_tilt ~= 0 then
		self._output_data.rotation = Rotation(self._output_data.rotation:yaw(), self._output_data.rotation:pitch(), self._output_data.rotation:roll() + self._camera_properties.current_tilt)
	end

	local equipped_weapon = self._parent_unit:inventory():equipped_unit()
	local bipod_weapon_translation = Vector3(0, 0, 0)

	if equipped_weapon and equipped_weapon:base() then
		local weapon_tweak_data = equipped_weapon:base():weapon_tweak_data()

		if weapon_tweak_data and weapon_tweak_data.bipod_weapon_translation then
			bipod_weapon_translation = weapon_tweak_data.bipod_weapon_translation
		end
	end

	local bipod_pos = Vector3(0, 0, 0)
	local bipod_rot = new_shoulder_rot

	mvector3.set(bipod_pos, bipod_weapon_translation)
	mvector3.rotate_with(bipod_pos, self._output_data.rotation)
	mvector3.add(bipod_pos, new_head_pos)
	mvector3.set(new_shoulder_pos, self._shoulder_stance.translation)
	mvector3.add(new_shoulder_pos, self._vel_overshot.translation)
	mvector3.rotate_with(new_shoulder_pos, self._output_data.rotation)
	mvector3.add(new_shoulder_pos, new_head_pos)
	mrotation.set_zero(new_shoulder_rot)
	mrotation.multiply(new_shoulder_rot, self._output_data.rotation)
	mrotation.multiply(new_shoulder_rot, self._shoulder_stance.rotation)
	mrotation.multiply(new_shoulder_rot, self._vel_overshot.rotation)

	if equipped_weapon and equipped_weapon:base() then
		local apply_gun_kick = alive(equipped_weapon) and equipped_weapon:base().is_melee_weapon and not equipped_weapon:base():is_melee_weapon()

		if apply_gun_kick then
			local gun_kick = equipped_weapon:base():gun_kick()
			local gun_kick_tweak = equipped_weapon:base():weapon_tweak_data().gun_kick
			local position_ratio = gun_kick_tweak and gun_kick_tweak.position_ratio or 0.25
			local kick_x = gun_kick.x.delta
			local kick_y = gun_kick.y.delta

			mrotation.set_zero(tmp_rot1)
			mrotation.set_yaw_pitch_roll(tmp_rot1, kick_x * -1, kick_y * -1, 0)
			mrotation.multiply(new_shoulder_rot, tmp_rot1)

			local direction = self._parent_unit:camera():forward()
			local mvec_direction = tmp_vec1
			local mvec_right = tmp_vec2
			local mvec_up = tmp_vec3

			mvec3_cross(mvec_right, direction, math.UP)
			mvec3_norm(mvec_right)
			mvec3_cross(mvec_up, direction, mvec_right)
			mvec3_norm(mvec_up)
			mvec3_mul(mvec_right, kick_x * position_ratio)
			mvec3_mul(mvec_up, kick_y * position_ratio)

			local gun_kick_pos = Vector3()

			mvector3.add(gun_kick_pos, mvec_right)
			mvector3.add(gun_kick_pos, mvec_up)
			mvector3.add(new_shoulder_pos, gun_kick_pos)
		end
	end

	local player_state = managers.player:current_state()

	if player_state == "driving" then
		self:_set_camera_position_in_vehicle()
	elseif player_state == "freefall" or player_state == "parachuting" then
		mrotation.set_zero(cam_offset_rot)
		mrotation.multiply(cam_offset_rot, self._parent_unit:movement().fall_rotation)
		mrotation.multiply(cam_offset_rot, self._output_data.rotation)

		local shoulder_pos = mvec3
		local shoulder_rot = mrot4

		mrotation.set_zero(shoulder_rot)
		mrotation.multiply(shoulder_rot, cam_offset_rot)
		mrotation.multiply(shoulder_rot, self._shoulder_stance.rotation)
		mrotation.multiply(shoulder_rot, self._vel_overshot.rotation)
		mvector3.set(shoulder_pos, self._shoulder_stance.translation)
		mvector3.add(shoulder_pos, self._vel_overshot.translation)
		mvector3.rotate_with(shoulder_pos, cam_offset_rot)
		mvector3.add(shoulder_pos, self._parent_unit:position())
		self:set_position(shoulder_pos)
		self:set_rotation(shoulder_rot)
		self._parent_unit:camera():set_position(self._parent_unit:position())
		self._parent_unit:camera():set_rotation(cam_offset_rot)
	else
		self:set_position(new_shoulder_pos)
		self:set_rotation(new_shoulder_rot)
		self._parent_unit:camera():set_position(self._output_data.position)
		self._parent_unit:camera():set_rotation(self._output_data.rotation)
	end

	if player_state == "bipod" and not self._parent_unit:movement()._current_state:in_steelsight() then
		self:set_position(PlayerBipod._shoulder_pos or new_shoulder_pos)
		self:set_rotation(bipod_rot)
		self._parent_unit:camera():set_position(PlayerBipod._camera_pos or self._output_data.position)
		self:set_fov_instant(40)
	elseif not self._parent_unit:movement()._current_state:in_steelsight() then
		PlayerBipod:set_camera_positions(bipod_pos, self._output_data.position)
	end
end

function FPCameraPlayerBase:catmullrom(t, p0, p1, p2, p3)
	return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t)
end

function FPCameraPlayerBase:_set_camera_position_in_vehicle()
	local vehicle_data = managers.player:get_vehicle()

	if not vehicle_data then
		return
	end

	local vehicle_unit = vehicle_data.vehicle_unit

	if not alive(vehicle_unit) then
		return
	end

	local vehicle = vehicle_unit:vehicle()
	local vehicle_ext = vehicle_unit:vehicle_driving()
	local seat = vehicle_ext:find_seat_for_player(managers.player:player_unit())
	local obj_pos, obj_rot = vehicle_ext:get_object_placement(managers.player:local_player())

	if obj_pos == nil or obj_rot == nil then
		return
	end

	local stance = managers.player:local_player():movement():current_state():stance()

	if stance == PlayerDriving.STANCE_SHOOTING then
		mvector3.add(obj_pos, seat.shooting_pos:rotate_with(vehicle:rotation()))
	end

	local camera_rot = mrot3

	mrotation.set_zero(camera_rot)
	mrotation.multiply(camera_rot, obj_rot)
	mrotation.multiply(camera_rot, self._output_data.rotation)

	local hands_rot = mrot4

	mrotation.set_zero(hands_rot)
	mrotation.multiply(hands_rot, obj_rot)

	local target = Vector3(0, 0, 0)
	local target_camera = Vector3(0, 0, 0)

	if vehicle_ext._tweak_data.driver_camera_offset then
		target_camera = target_camera + vehicle_ext._tweak_data.driver_camera_offset
	end

	mvector3.rotate_with(target, vehicle:rotation())
	mvector3.rotate_with(target_camera, vehicle:rotation())

	local pos = obj_pos + target
	local camera_pos = obj_pos + target_camera

	if seat.driving then
		if vehicle_unit:camera() then
			vehicle_unit:camera():update_camera()
		end

		self:set_position(pos)
		self:set_rotation(hands_rot)
		self._parent_unit:camera():set_position(camera_pos)
		self._parent_unit:camera():set_rotation(camera_rot)
	else
		local shoulder_pos = mvec3
		local shoulder_rot = mrot4

		mrotation.set_zero(shoulder_rot)
		mrotation.multiply(shoulder_rot, camera_rot)
		mrotation.multiply(shoulder_rot, self._shoulder_stance.rotation)
		mrotation.multiply(shoulder_rot, self._vel_overshot.rotation)
		mvector3.set(shoulder_pos, self._shoulder_stance.translation)
		mvector3.add(shoulder_pos, self._vel_overshot.translation)
		mvector3.rotate_with(shoulder_pos, camera_rot)
		mvector3.add(shoulder_pos, pos)
		self:set_position(shoulder_pos)
		self:set_rotation(shoulder_rot)
		self._parent_unit:camera():set_position(pos)
		self._parent_unit:camera():set_rotation(camera_rot)
	end
end

function FPCameraPlayerBase:_get_aim_assist(t, dt, speed, aim_data)
	if aim_data.distance == 0 then
		return 0, 0
	end

	local s_value = math.step(0, aim_data.distance, speed * dt)
	local r_value_x = mvector3.x(aim_data.direction) * s_value
	local r_value_y = mvector3.y(aim_data.direction) * s_value

	if aim_data.is_sticky and self._tweak_data.aim_assist_use_sticky_aim then
		local strength = 1 - math.min(1, (aim_data.distance_to_aim_line or 0) / 100)
		local mx = 1 - self._tweak_data.aim_assist_gradient_max
		local mn = 1 - self._tweak_data.aim_assist_gradient_min
		local min_strength = math.lerp(mn, mx, math.min(1, (aim_data.target_distance or 0) / self._tweak_data.aim_assist_gradient_max_distance))
		strength = math.max(0, strength - min_strength) / (1 - min_strength)
		r_value_x = r_value_x * strength
		r_value_y = r_value_y * strength
	end

	aim_data.distance = aim_data.distance - s_value

	if aim_data.distance <= 0 then
		self:_stop_aim_assist(aim_data)
	end

	return r_value_x, r_value_y
end

function FPCameraPlayerBase:_get_aim_assist_look_multiplier()
	if not self._aim_assist_look_multiplier then
		return 1
	end

	return self._aim_assist_look_multiplier
end

function FPCameraPlayerBase:calculate_aim_assist_look_multiplier(col_ray)
	local yaw, pitch, roll = self:_get_aim_assist_direction(col_ray)
	local distance = mvector3.length(Vector3(yaw, -pitch, roll))
	distance = distance / managers.player:upgrade_value("player", "warcry_aim_assist_radius", 1)

	if not self._previous_aim_assist_distance then
		self._previous_aim_assist_distance = distance
	end

	if self._aim_locked then
		self._aim_assist_look_multiplier = distance / 7 + 0.07

		if tostring(self._stick_input_length) == tostring(0) and distance < 3 then
			self:clbk_aim_assist(col_ray)
		end

		self._locked_unit = col_ray.unit

		if distance > 10 then
			self._aim_locked = false
			self._locked_unit = nil
		end
	else
		if distance < 6 then
			self:clbk_aim_assist(col_ray)

			self._aim_locked = true
			self._locked_unit = col_ray.unit
		end

		self._aim_assist_look_multiplier = distance / 10

		if self._movement_speed > 1 then
			self._aim_assist_look_multiplier = self._aim_assist_look_multiplier / math.sqrt(self._movement_speed / 5)
		end
	end

	self._previous_aim_assist_distance = distance
end

function FPCameraPlayerBase:locked_unit()
	return self._locked_unit
end

function FPCameraPlayerBase:reset_aim_assist()
	self._aim_locked = false
	self._locked_unit = nil
	self._aim_assist_look_multiplier = 1
end

function FPCameraPlayerBase:set_aim_assist_look_multiplier(multiplier)
	self._aim_assist_look_multiplier = multiplier
end

local viewkick_multiplier = 12
local recenter_divisor = 16
local max_deflection = 10
local viewkick_velocity = 0
local viewkick_velocity_vec = Vector3()
local viewkick_delta_vec = Vector3()

function FPCameraPlayerBase:recoil_kick(up, down, left, right, recoil_multiplier)
	recoil_multiplier = recoil_multiplier or 1
	up = up * recoil_multiplier * viewkick_multiplier
	down = down * recoil_multiplier * viewkick_multiplier
	left = left * recoil_multiplier * viewkick_multiplier
	right = right * recoil_multiplier * viewkick_multiplier
	local kick_x = math.lerp(left, right, math.random())
	local kick_y = math.lerp(down, up, math.random())
	kick_x = self:_get_minimum_view_kick(kick_x, 2, recoil_multiplier) / math_sqrt2
	kick_y = self:_get_minimum_view_kick(kick_y, 1, recoil_multiplier) / math_sqrt2

	mvec3_set(tmp_vec1, self._view_kick.delta)
	mvec3_norm(tmp_vec1)

	local x_delta_sign = math.sign(tmp_vec1.x)

	if x_delta_sign == 0 or math.sign(kick_x) == x_delta_sign then
		mvec3_set_x(self._view_kick.direction, kick_x)
	else
		mvec3_set_x(self._view_kick.direction, self._view_kick.direction.x + kick_x / recenter_divisor)
	end

	local y_delta_sign = math.sign(tmp_vec1.y)

	if y_delta_sign == 0 or math.sign(kick_y) == y_delta_sign then
		mvec3_set_y(self._view_kick.direction, kick_y)
	else
		mvec3_set_y(self._view_kick.direction, self._view_kick.direction.y + kick_y / recenter_divisor)
	end

	self._view_kick.velocity = mvec3_norm(self._view_kick.direction)
end

function FPCameraPlayerBase:_get_minimum_view_kick(kick_value, axis, recoil_multiplier)
	local player_state = managers.player:get_current_state()
	local weapon = self._parent_unit:inventory():equipped_unit()
	local minimum_kick_values = alive(weapon) and weapon:base():weapon_tweak_data().minimum_view_kick

	if player_state and minimum_kick_values then
		local state_data = player_state._state_data
		local state = state_data.in_steelsight and state_data.ducking and "crouching_steelsight" or state_data.in_steelsight and "steelsight" or state_data.ducking and "crouching" or "standing"

		if minimum_kick_values[state] then
			local min = minimum_kick_values[state][axis] * recoil_multiplier * viewkick_multiplier

			return math.max(math.abs(kick_value), min) * math.sign(kick_value)
		end
	end

	return kick_value
end

function FPCameraPlayerBase:_get_view_kick_center_acceleration()
	local view_kick_center_speed = 500
	local weapon = self._parent_unit:inventory():equipped_unit()

	if alive(weapon) and weapon:base().is_melee_weapon and not weapon:base():is_melee_weapon() then
		local weapon_base = weapon:base()

		if weapon_base:in_steelsight() then
			return weapon_base:weapon_tweak_data().kick.recenter_speed_steelsight or view_kick_center_speed
		else
			return weapon_base:weapon_tweak_data().kick.recenter_speed or view_kick_center_speed
		end
	else
		return view_kick_center_speed
	end
end

function FPCameraPlayerBase:_update_view_kick_vector(t, dt)
	local player_state = managers.player:current_state()

	if player_state == "bipod" then
		return 0, 0
	end

	local view_kick_center_speed = self:_get_view_kick_center_acceleration()
	local acceleration = view_kick_center_speed * dt
	local delta_normalized = tmp_vec1

	mvec3_set(tmp_vec1, self._view_kick.delta)
	mvec3_norm(tmp_vec1)

	local x = self._view_kick.direction.x * self._view_kick.velocity * dt
	local y = self._view_kick.direction.y * self._view_kick.velocity * dt

	mvec3_set_zero(tmp_vec2)
	mvec3_set_x(tmp_vec2, x)
	mvec3_set_y(tmp_vec2, y)
	mvec3_add(self._view_kick.delta, tmp_vec2)

	local delta_length = mvec3_len(self._view_kick.delta)

	if delta_length > 0 and math.sign(self._view_kick.velocity) ~= math.sign(delta_length) then
		mvec3_set_zero(self._view_kick.direction)
		mvec3_set_x(self._view_kick.direction, delta_normalized.x)
		mvec3_set_y(self._view_kick.direction, delta_normalized.y)

		acceleration = acceleration / recenter_divisor
	end

	if max_deflection < delta_length then
		mvec3_norm(self._view_kick.delta)
		mvec3_mul(self._view_kick.delta, max_deflection)

		self._view_kick.velocity = 0
		x = x - delta_normalized.x * (delta_length - max_deflection)
		y = y - delta_normalized.y * (delta_length - max_deflection)
	end

	acceleration = acceleration * math.sign(delta_length) * -1
	self._view_kick.velocity = self._view_kick.velocity + acceleration

	if math.sign(delta_length + self._view_kick.velocity * dt) ~= math.sign(delta_length) then
		x = x - delta_normalized.x * delta_length
		y = y - delta_normalized.y * delta_length

		mvec3_set_zero(self._view_kick.delta)
		mvec3_set_zero(self._view_kick.direction)

		self._view_kick.velocity = 0
	end

	return x, y
end

function FPCameraPlayerBase:_pc_look_function(stick_input, stick_input_multiplier, dt)
	return stick_input.x, stick_input.y
end

local multiplier = Vector3()

function FPCameraPlayerBase:_gamepad_look_function(stick_input, stick_input_multiplier, dt, unscaled_stick_input)
	local aim_assist_x = 0
	local aim_assist_y = 0
	local cs = managers.player:current_state()
	local aim_assist = false

	if (cs == "standard" or cs == "carry" or cs == "bipod") and managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("sticky_aim") then
		aim_assist = true
	end

	local dz = self._tweak_data.look_speed_dead_zone
	local length = mvector3.length(unscaled_stick_input)

	if dz < length then
		mvector3.set(multiplier, stick_input_multiplier)

		if multiplier.x - 1 > 0.001 then
			mvector3.set_x(multiplier, 1 + 1.6 * (multiplier.x - 1) / ((tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 0.5))
		end

		if multiplier.y - 1 > 0.001 then
			mvector3.set_y(multiplier, 1 + 1.6 * (multiplier.y - 1) / ((tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 0.5))
		end

		if aim_assist then
			aim_assist_x, aim_assist_y = self:_get_aim_assist(0, dt, self._tweak_data.aim_assist_look_speed, self._aim_assist_sticky)
		end

		local x = unscaled_stick_input.x
		local y = unscaled_stick_input.y
		x = x / length
		y = y / length
		length = math.min(length, 1)
		local scale = (length - dz) / (1 - dz)
		x = x * scale
		y = y * scale
		unscaled_stick_input = Vector3(x, y, 0)
		local look_speed_x, look_speed_y = self:_get_look_speed(unscaled_stick_input, multiplier, dt)
		look_speed_y = look_speed_x
		look_speed_x = look_speed_x * multiplier.x
		look_speed_y = look_speed_y * multiplier.y
		local stick_input_x = unscaled_stick_input.x * dt * look_speed_x
		local stick_input_y = unscaled_stick_input.y * dt * look_speed_y
		local look = Vector3(stick_input_x, stick_input_y, 0)

		if aim_assist then
			local len = mvector3.length(look)
			look = Vector3(look.x + aim_assist_x, look.y, 0)

			if length < 0.08 then
				mvector3.normalize(look)

				look = look * len
			end
		end

		return look.x, look.y
	end

	if aim_assist then
		aim_assist_x, aim_assist_y = self:_get_aim_assist(0, dt, self._tweak_data.aim_assist_move_speed, self._aim_assist_sticky)
		local move = math.abs(self._parent_unit:movement()._current_state._stick_move.x)

		if self._tweak_data.aim_assist_move_th_min <= move and move <= self._tweak_data.aim_assist_move_th_max then
			return aim_assist_x, 0
		end
	end

	return 0, 0
end

function FPCameraPlayerBase:_steampad_look_function(stick_input, stick_input_multiplier, dt)
	if mvector3.length(stick_input) > self._tweak_data.look_speed_dead_zone * stick_input_multiplier.x then
		local x = stick_input.x
		local y = stick_input.y
		local look_speed = self._tweak_data.look_speed_standard * (alive(self._parent_unit) and self._parent_unit:base():controller():get_input_bool("change_sensitivity") and 1 or 0.5)
		local stick_input_x = x * dt * look_speed
		local stick_input_y = y * dt * look_speed

		return stick_input_x, stick_input_y
	end

	return 0, 0
end

local function get_look_setting(a, b, c, t)
	if t < 0.5 then
		return math.lerp(a, b, t / 0.5)
	end

	return math.lerp(b, c, (t - 0.5) / 0.5)
end

local function get_look_setting_x_y(a, b, c, x, y)
	return get_look_setting(a, b, c, x), get_look_setting(a, b, c, y)
end

function FPCameraPlayerBase:_get_look_speed(stick_input, stick_input_multiplier, dt)
	if self._parent_unit:movement()._current_state:in_steelsight() then
		return self._tweak_data.look_speed_steel_sight
	end

	if self._tweak_data.look_speed_transition_occluder >= mvector3.length(stick_input) or self._tweak_data.look_speed_transition_zone >= math.abs(stick_input.x) then
		self._camera_properties.look_speed_transition_timer = 0

		return self._tweak_data.look_speed_standard
	end

	if self._camera_properties.look_speed_transition_timer >= 1 then
		return self._tweak_data.look_speed_fast
	end

	local p1 = self._tweak_data.look_speed_standard
	local p2 = self._tweak_data.look_speed_standard
	local p3 = self._tweak_data.look_speed_standard + (self._tweak_data.look_speed_fast - self._tweak_data.look_speed_standard) / 3 * 2
	local p4 = self._tweak_data.look_speed_fast
	self._camera_properties.look_speed_transition_timer = self._camera_properties.look_speed_transition_timer + dt / self._tweak_data.look_speed_transition_to_fast

	return math.bezier({
		p1,
		p2,
		p3,
		p4
	}, self._camera_properties.look_speed_transition_timer)
end

function FPCameraPlayerBase:_calculate_soft_velocity_overshot(dt)
	local stick_input = self._input.look
	local vel_overshot = self._vel_overshot

	if not stick_input then
		return
	end

	local input_yaw, input_pitch, input_x, input_z = nil
	local mul = self._tweak_data.uses_keyboard and 0.002 / dt or 0.4

	if not managers.player:is_view_disabled() then
		if stick_input.x >= 0 then
			local stick_input_x = math.pow(math.abs(math.clamp(mul * stick_input.x, 0, 1)), 1.5) * math.sign(stick_input.x)
			input_yaw = stick_input_x * vel_overshot.yaw_pos
		else
			local stick_input_x = math.pow(math.abs(math.clamp(mul * stick_input.x, -1, 0)), 1.5)
			input_yaw = stick_input_x * vel_overshot.yaw_neg
		end
	else
		input_yaw = 0
	end

	local last_yaw = vel_overshot.last_yaw
	local sign_in_yaw = math.sign(input_yaw)
	local abs_in_yaw = math.abs(input_yaw)
	local sign_last_yaw = math.sign(last_yaw)
	local abs_last_yaw = math.abs(last_yaw)
	local step_v = self._tweak_data.uses_keyboard and 120 * dt or 2
	vel_overshot.target_yaw = math.step(vel_overshot.target_yaw, input_yaw, step_v)
	local final_yaw = nil
	local diff = math.abs(vel_overshot.target_yaw - last_yaw)
	local diff_clamp = 40
	local diff_ratio = math.pow(diff / diff_clamp, 1)
	local diff_ratio_clamped = math.clamp(diff_ratio, 0, 1)
	local step_amount = math.lerp(3, 180, diff_ratio_clamped) * dt
	final_yaw = math.step(last_yaw, vel_overshot.target_yaw, step_amount)
	vel_overshot.last_yaw = final_yaw
	local mul = self._tweak_data.uses_keyboard and 0.002 / dt or 0.4

	if not managers.player:is_view_disabled() then
		if stick_input.y >= 0 then
			local stick_input_y = math.pow(math.abs(math.clamp(mul * stick_input.y, 0, 1)), 1.5) * math.sign(stick_input.y)
			input_pitch = stick_input_y * vel_overshot.pitch_pos
		else
			local stick_input_y = math.pow(math.abs(math.clamp(mul * stick_input.y, -1, 0)), 1.5)
			input_pitch = stick_input_y * vel_overshot.pitch_neg
		end
	else
		input_pitch = 0
	end

	local last_pitch = vel_overshot.last_pitch
	local sign_in_pitch = math.sign(input_pitch)
	local abs_in_pitch = math.abs(input_pitch)
	local sign_last_pitch = math.sign(last_pitch)
	local abs_last_pitch = math.abs(last_pitch)
	local step_v = self._tweak_data.uses_keyboard and 120 * dt or 2
	vel_overshot.target_pitch = math.step(vel_overshot.target_pitch, input_pitch, step_v)
	local final_pitch = nil
	local diff = math.abs(vel_overshot.target_pitch - last_pitch)
	local diff_clamp = 40
	local diff_ratio = math.pow(diff / diff_clamp, 1)
	local diff_ratio_clamped = math.clamp(diff_ratio, 0, 1)
	local step_amount = math.lerp(3, 180, diff_ratio_clamped) * dt
	final_pitch = math.step(last_pitch, vel_overshot.target_pitch, step_amount)
	vel_overshot.last_pitch = final_pitch

	mrotation.set_yaw_pitch_roll(vel_overshot.rotation, final_yaw, final_pitch, -final_yaw)

	local pivot = vel_overshot.pivot
	local new_root = mvec3

	mvector3.set(new_root, pivot)
	mvector3.negate(new_root)
	mvector3.rotate_with(new_root, vel_overshot.rotation)
	mvector3.add(new_root, pivot)
	mvector3.set(vel_overshot.translation, new_root)
end

function FPCameraPlayerBase:set_position(pos)
	self._unit:set_position(pos)
end

function FPCameraPlayerBase:set_rotation(rot)
	self._unit:set_rotation(rot)
end

function FPCameraPlayerBase:eye_position()
	return self._obj_eye:position()
end

function FPCameraPlayerBase:eye_rotation()
	return self._obj_eye:rotation()
end

function FPCameraPlayerBase:play_redirect(redirect_name, speed, offset_time)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false

	if not self._use_anim_allowed and redirect_name == Idstring("use") then
		return
	end

	local result = self._unit:play_redirect(redirect_name, offset_time)

	if result == self.IDS_NOSTRING then
		return false
	end

	if redirect_name == Idstring("use") then
		self._use_anim_allowed = false
	end

	if speed then
		self._unit:anim_state_machine():set_speed(result, speed)
	end

	return result
end

function FPCameraPlayerBase:play_redirect_timeblend(state, redirect_name, offset_time, t)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false

	self._unit:anim_state_machine():set_parameter(state, "t", t)

	local result = self._unit:play_redirect(redirect_name, offset_time)

	if result == self.IDS_NOSTRING then
		return false
	end

	return result
end

function FPCameraPlayerBase:play_raw(name, params)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false
	local asm = self._unit:anim_state_machine()
	local result = asm:play_raw(name, params)

	return result ~= self.IDS_NOSTRING and result
end

function FPCameraPlayerBase:set_steelsight_anim_enabled(enabled)
	self._steelsight_anims_enabled = enabled

	self:_check_play_empty_state()
end

function FPCameraPlayerBase:play_state(state_name)
	self:set_anims_enabled(true)

	self._anim_empty_state_wanted = false
	local result = self._unit:play_state(Idstring(state_name))

	return result ~= self.IDS_NOSTRING and result
end

function FPCameraPlayerBase:set_target_tilt(tilt)
	self._camera_properties.target_tilt = tilt
end

function FPCameraPlayerBase:current_tilt()
	return self._camera_properties.current_tilt
end

function FPCameraPlayerBase:set_camera_offset(camera_offset)
	self._camera_properties.camera_offset = camera_offset
end

function FPCameraPlayerBase:set_stance_instant(stance_name)
	local new_stance = tweak_data.player.stances.default[stance_name].shoulders

	if new_stance then
		self._shoulder_stance.transition = nil
		self._shoulder_stance.translation = mvector3.copy(new_stance.translation)
		self._shoulder_stance.rotation = new_stance.rotation
	end

	local new_stance = tweak_data.player.stances.default[stance_name].head

	if new_stance then
		self._head_stance.transition = nil
		self._head_stance.translation = mvector3.copy(new_stance.translation)
		self._head_stance.rotation = new_stance.rotation
	end

	local new_overshot = tweak_data.player.stances.default[stance_name].vel_overshot

	if new_overshot then
		self._vel_overshot.transition = nil
		self._vel_overshot.yaw_neg = new_overshot.yaw_neg
		self._vel_overshot.yaw_pos = new_overshot.yaw_pos
		self._vel_overshot.pitch_neg = new_overshot.pitch_neg
		self._vel_overshot.pitch_pos = new_overshot.pitch_pos
		self._vel_overshot.pivot = mvector3.copy(new_overshot.pivot)
	end

	self:set_stance_fov_instant(stance_name)
end

function FPCameraPlayerBase:is_stance_done()
	return not self._shoulder_stance.transition and not self._head_stance.transition and not self._vel_overshot.transition
end

function FPCameraPlayerBase:set_fov_instant(new_fov)
	if new_fov then
		self._fov.transition = nil
		self._fov.fov = new_fov
		self._fov.dirty = true

		if Application:paused() then
			self._parent_unit:camera():set_FOV(self._fov.fov)
		end
	end
end

function FPCameraPlayerBase:set_stance_fov_instant(stance_name)
	local new_fov = tweak_data.player.stances.default[stance_name].zoom_fov and managers.user:get_setting("fov_zoom") or managers.user:get_setting("fov_standard")

	if new_fov then
		self._fov.transition = nil
		self._fov.fov = new_fov
		self._fov.dirty = true

		if Application:paused() then
			self._parent_unit:camera():set_FOV(self._fov.fov)
		end
	end
end

function FPCameraPlayerBase:clbk_stance_entered(new_shoulder_stance, new_head_stance, new_vel_overshot, new_fov, new_shakers, stance_mod, duration_multiplier, duration)
	local t = Application:time()

	if new_shoulder_stance then
		local transition = {}
		self._shoulder_stance.transition = transition
		transition.end_translation = new_shoulder_stance.translation + (stance_mod.translation or Vector3())
		transition.end_rotation = new_shoulder_stance.rotation * (stance_mod.rotation or Rotation())
		transition.start_translation = mvector3.copy(self._shoulder_stance.translation)
		transition.start_rotation = self._shoulder_stance.rotation
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_head_stance then
		local transition = {}
		self._head_stance.transition = transition
		transition.end_translation = new_head_stance.translation
		transition.end_rotation = new_head_stance.rotation
		transition.start_translation = mvector3.copy(self._head_stance.translation)
		transition.start_rotation = self._head_stance.rotation
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_vel_overshot then
		local transition = {}
		self._vel_overshot.transition = transition
		transition.end_pivot = new_vel_overshot.pivot
		transition.end_yaw_neg = new_vel_overshot.yaw_neg
		transition.end_yaw_pos = new_vel_overshot.yaw_pos
		transition.end_pitch_neg = new_vel_overshot.pitch_neg
		transition.end_pitch_pos = new_vel_overshot.pitch_pos
		transition.start_pivot = mvector3.copy(self._vel_overshot.pivot)
		transition.start_yaw_neg = self._vel_overshot.yaw_neg
		transition.start_yaw_pos = self._vel_overshot.yaw_pos
		transition.start_pitch_neg = self._vel_overshot.pitch_neg
		transition.start_pitch_pos = self._vel_overshot.pitch_pos
		transition.start_t = t
		transition.duration = duration * duration_multiplier
	end

	if new_fov then
		if new_fov == self._fov.fov then
			self._fov.transition = nil
		else
			local transition = {}
			self._fov.transition = transition
			transition.end_fov = new_fov
			transition.start_fov = self._fov.fov
			transition.start_t = t
			transition.duration = duration * duration_multiplier
		end
	end

	if new_shakers then
		for effect, values in pairs(new_shakers) do
			for parameter, value in pairs(values) do
				self._parent_unit:camera():set_shaker_parameter(effect, parameter, value)
			end
		end
	end
end

function FPCameraPlayerBase:_get_aim_assist_direction(col_ray)
	if col_ray then
		local ray = col_ray.ray
		local r1 = self._parent_unit:camera():rotation()
		local r2 = self._aim_assist.mrotation or Rotation()

		mrotation.set_look_at(r2, ray, r1:z())

		local yaw = mrotation.yaw(r1) - mrotation.yaw(r2)
		local pitch = mrotation.pitch(r1) - mrotation.pitch(r2)

		if yaw > 180 then
			yaw = 360 - yaw
		elseif yaw < -180 then
			yaw = 360 + yaw
		end

		if pitch > 180 then
			pitch = 360 - pitch
		elseif pitch < -180 then
			pitch = 360 + pitch
		end

		return yaw, pitch, 0
	end
end

function FPCameraPlayerBase:_start_aim_assist(col_ray, aim_data)
	if col_ray then
		local ray = col_ray.ray
		local r1 = self._parent_unit:camera():rotation()
		local r2 = aim_data.mrotation or Rotation()

		mrotation.set_look_at(r2, ray, r1:z())

		local yaw = mrotation.yaw(r1) - mrotation.yaw(r2)
		local pitch = mrotation.pitch(r1) - mrotation.pitch(r2)

		if yaw > 180 then
			yaw = 360 - yaw
		elseif yaw < -180 then
			yaw = 360 + yaw
		end

		if pitch > 180 then
			pitch = 360 - pitch
		elseif pitch < -180 then
			pitch = 360 + pitch
		end

		mvector3.set_static(aim_data.direction, yaw, -pitch, 0)

		aim_data.distance = mvector3.normalize(aim_data.direction)
		aim_data.target_distance = col_ray.distance
		aim_data.distance_to_aim_line = col_ray.distance_to_aim_line
	end
end

function FPCameraPlayerBase:_stop_aim_assist(aim_data)
	mvector3.set_static(aim_data.direction, 0, 0, 0)

	aim_data.distance = 0
	aim_data.target_distance = 0
	aim_data.distance_to_aim_line = 0
end

function FPCameraPlayerBase:_update_aim_assist_sticky(t, dt)
	if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("sticky_aim") then
		local weapon = self._parent_unit:inventory():equipped_unit()
		local player_state = self._parent_unit:movement():current_state()

		if weapon then
			local closest_ray = weapon:base():get_aim_assist(player_state:get_fire_weapon_position(), player_state:get_fire_weapon_direction(), nil, true)

			self:_start_aim_assist(closest_ray, self._aim_assist_sticky)
		else
			self:_stop_aim_assist(self._aim_assist_sticky)
		end
	end
end

function FPCameraPlayerBase:clbk_aim_assist(col_ray)
	if col_ray then
		local yaw, pitch, roll = self:_get_aim_assist_direction(col_ray)

		mvector3.set_static(self._aim_assist.direction, yaw, -pitch, 0)

		self._aim_assist.distance = mvector3.normalize(self._aim_assist.direction)
	end
end

function FPCameraPlayerBase:clbk_stop_aim_assist()
	mvector3.set_static(self._aim_assist.direction, 0, 0, 0)

	self._aim_assist.distance = 0
end

function FPCameraPlayerBase:animate_fov(new_fov, duration_multiplier)
	if new_fov == self._fov.fov then
		self._fov.transition = nil
	else
		local transition = {}
		self._fov.transition = transition
		transition.end_fov = new_fov
		transition.start_fov = self._fov.fov
		transition.start_t = managers.player:player_timer():time()
		transition.duration = 0.23 * (duration_multiplier or 1)
	end
end

function FPCameraPlayerBase:anim_clbk_idle_full_blend()
	self._anim_empty_state_wanted = true

	self:_check_play_empty_state()
end

function FPCameraPlayerBase:_check_play_empty_state()
	if not self._anim_empty_state_wanted then
		return
	end

	if self._steelsight_anims_enabled then
		return
	end

	self:play_redirect(self.IDS_EMPTY)
end

function FPCameraPlayerBase:anim_clbk_idle_exit()
end

function FPCameraPlayerBase:anim_clbk_empty_enter()
	self._playing_empty_state = true
end

function FPCameraPlayerBase:anim_clbk_empty_exit()
	self._playing_empty_state = false
end

function FPCameraPlayerBase:playing_empty_state()
	return self._playing_empty_state
end

function FPCameraPlayerBase:anim_clbk_empty_full_blend()
	self._playing_empty_state = false

	self:set_anims_enabled(false)
end

function FPCameraPlayerBase:anim_clbk_spawn_handcuffs()
end

function FPCameraPlayerBase:anim_clbk_unspawn_handcuffs()
end

function FPCameraPlayerBase:anim_clbk_use_exit()
	self._use_anim_allowed = true
end

function FPCameraPlayerBase:get_weapon_offsets()
	local weapon = self._parent_unit:inventory():equipped_unit()
	local object = weapon:get_object(Idstring("a_sight"))

	print((object:position() - self._unit:position()):rotate_HP(self._unit:rotation():inverse()))
	print(self._unit:rotation():inverse() * object:rotation())
end

function FPCameraPlayerBase:get_weapon_part_offsets(part_id)
	local weapon = self._parent_unit:inventory():equipped_unit()
	local weapon_part_position, weapon_part_rotation = self:_get_position_and_rotation(weapon, Idstring(part_id))

	if weapon_part_position and weapon_part_rotation then
		print((weapon_part_position - self._unit:position()):rotate_HP(self._unit:rotation():inverse()))
		print(self._unit:rotation():inverse() * weapon_part_rotation)
	else
		print("Weapon part '" .. tostring(part_id) .. "' not found!")
	end
end

function FPCameraPlayerBase:_get_position_and_rotation(unit, part_id)
	local children = nil

	if unit.get_objects then
		children = unit:get_objects("*")
	elseif unit.children then
		children = unit:children()
	end

	local object_position, object_rotation = nil

	if children then
		for i = 1, #children do
			if children[i]:name() == part_id then
				return children[i]:position(), children[i]:rotation()
			else
				object_position, object_rotation = self:_get_position_and_rotation(children[i], part_id)

				if object_position and object_rotation then
					return object_position, object_rotation
				end
			end
		end
	end
end

function FPCameraPlayerBase:set_anims_enabled(state)
	if state ~= self._anims_enabled then
		self._unit:set_animations_enabled(state)

		self._anims_enabled = state
	end
end

function FPCameraPlayerBase:anims_enabled()
	return self._anims_enabled
end

function FPCameraPlayerBase:anim_clbk_hide_pin(unit)
	if alive(self._parent_unit) and alive(self._parent_unit:inventory():equipped_unit()) and self._parent_unit:inventory():equipped_unit():damage() and self._parent_unit:inventory():equipped_unit():damage():has_sequence("hide_pin") then
		self._parent_unit:inventory():equipped_unit():damage():run_sequence_simple("hide_pin")
	end
end

function FPCameraPlayerBase:anim_clbk_show_pin(unit)
	if alive(self._parent_unit) and alive(self._parent_unit:inventory():equipped_unit()) and self._parent_unit:inventory():equipped_unit():damage() and self._parent_unit:inventory():equipped_unit():damage():has_sequence("show_pin") then
		self._parent_unit:inventory():equipped_unit():damage():run_sequence_simple("show_pin")
	end
end

function FPCameraPlayerBase:play_sound(unit, event)
	if alive(self._parent_unit) then
		self._parent_unit:sound():play(event)
	end
end

function FPCameraPlayerBase:play_melee_sound(unit, sound_id)
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]

	if not tweak_data.sounds or not tweak_data.sounds[sound_id] then
		return
	end

	if alive(self._parent_unit) then
		self._parent_unit:sound():play(tweak_data.sounds[sound_id], nil, false)
	end
end

function FPCameraPlayerBase:set_limits(spin, pitch, mid_spin, mid_pitch)
	self._limits = {}

	if spin then
		local mid = mid_spin or self._camera_properties.spin
		self._limits.spin = {
			mid = mid,
			offset = spin
		}
	end

	if pitch then
		local mid = mid_pitch or self._camera_properties.pitch
		self._limits.pitch = {
			mid = mid,
			offset = pitch
		}
	end
end

function FPCameraPlayerBase:remove_limits()
	self._limits = nil
end

function FPCameraPlayerBase:throw_projectile(unit)
	self:unspawn_grenade()

	if alive(self._parent_unit) then
		self._parent_unit:equipment():throw_projectile()
	end
end

function FPCameraPlayerBase:throw_grenade(unit)
	self:unspawn_grenade()

	if alive(self._parent_unit) then
		self._parent_unit:equipment():throw_grenade()
	end
end

function FPCameraPlayerBase:spawn_grenade()
	if alive(self._grenade_unit) then
		return
	end

	local align_obj_l_name = Idstring("a_weapon_left")
	local align_obj_r_name = Idstring("a_weapon_right")
	local align_obj_l = self._unit:get_object(align_obj_l_name)
	local align_obj_r = self._unit:get_object(align_obj_r_name)
	local grenade_entry = managers.blackmarket:equipped_grenade()
	self._grenade_unit = World:spawn_unit(Idstring(tweak_data.projectiles[grenade_entry].unit), align_obj_r:position(), align_obj_r:rotation())

	self._unit:link(align_obj_r:name(), self._grenade_unit, self._grenade_unit:orientation_object():name())
end

function FPCameraPlayerBase:unspawn_grenade()
	if alive(self._grenade_unit) then
		self._grenade_unit:unlink()
		World:delete_unit(self._grenade_unit)

		self._grenade_unit = nil
	end
end

function FPCameraPlayerBase:spawn_ammo_bag()
	local align_obj_r_name = Idstring("a_weapon_right")
	local align_obj_r = self._unit:get_object(align_obj_r_name)
	local pos = align_obj_r:position()
	local dir = self._parent_unit:camera():forward()
	local idx = managers.player:upgrade_value("player", "toss_ammo", 0)

	ThrowableAmmoBag.spawn(pos, dir, idx)
end

function FPCameraPlayerBase:spawn_melee_item()
	if self._melee_item_units then
		return
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local unit_name = tweak_data.blackmarket.melee_weapons[melee_entry].unit

	if unit_name then
		local aligns = tweak_data.blackmarket.melee_weapons[melee_entry].align_objects or {
			"a_weapon_left"
		}
		local graphic_objects = tweak_data.blackmarket.melee_weapons[melee_entry].graphic_objects or {}
		self._melee_item_units = {}

		for _, align in ipairs(aligns) do
			local align_obj_name = Idstring(align)
			local align_obj = self._unit:get_object(align_obj_name)
			local unit = World:spawn_unit(Idstring(unit_name), align_obj:position(), align_obj:rotation())

			self._unit:link(align_obj:name(), unit, unit:orientation_object():name())

			for a_object, g_object in pairs(graphic_objects) do
				local graphic_obj_name = Idstring(g_object)
				local graphic_obj = unit:get_object(graphic_obj_name)

				graphic_obj:set_visibility(Idstring(a_object) == align_obj_name)
			end

			table.insert(self._melee_item_units, unit)
		end
	end
end

function FPCameraPlayerBase:unspawn_melee_item()
	if not self._melee_item_units then
		return
	end

	for _, unit in ipairs(self._melee_item_units) do
		if alive(unit) then
			unit:unlink()
			World:delete_unit(unit)
		end
	end

	self._melee_item_units = nil
end

function FPCameraPlayerBase:hide_weapon()
	if alive(self._parent_unit) then
		self._parent_unit:inventory():hide_equipped_unit()
	end
end

function FPCameraPlayerBase:show_weapon()
	if alive(self._parent_unit) then
		self._parent_unit:inventory():show_equipped_unit()
	end
end

function FPCameraPlayerBase:enter_shotgun_reload_loop(unit, state, ...)
	if alive(self._parent_unit) then
		local speed_multiplier = self._parent_unit:inventory():equipped_unit():base():reload_speed_multiplier()

		self._unit:anim_state_machine():set_speed(Idstring(state), speed_multiplier)
	end
end

function FPCameraPlayerBase:counter_taser()
	local current_state = self._parent_movement_ext._current_state

	if current_state and current_state.give_shock_to_taser then
		current_state:give_shock_to_taser()

		if alive(self._taser_hooks_unit) then
			local align_obj = self._unit:get_object(Idstring("a_weapon_right"))

			World:effect_manager():spawn({
				effect = Idstring("effects/vanilla/character/taser_stop"),
				position = align_obj:position(),
				normal = align_obj:rotation():y()
			})
		end
	end
end

function FPCameraPlayerBase:spawn_taser_hooks()
end

function FPCameraPlayerBase:unspawn_taser_hooks()
	if alive(self._taser_hooks_unit) then
		self._taser_hooks_unit:unlink()

		local name = self._taser_hooks_unit:name()

		World:delete_unit(self._taser_hooks_unit)
		managers.dyn_resource:unload(Idstring("unit"), name, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

		self._taser_hooks_unit = nil
	end
end

function FPCameraPlayerBase:end_tase()
	local current_state = self._parent_movement_ext._current_state

	if current_state and current_state.clbk_exit_to_std then
		current_state:clbk_exit_to_std()
	end
end

function FPCameraPlayerBase:anim_clbk_check_bullet_object()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():predict_bullet_objects()
		end
	end
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_reload()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop("reload")
			weapon:base():tweak_data_anim_stop("reload_not_empty")
		end
	end
end

function FPCameraPlayerBase:anim_clbk_play_weapon_anim(unit, anim, speed)
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_play(anim, speed)
		end
	end
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_anim(unit, anim)
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop(anim)
		end
	end
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_reload_all()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop("reload_enter")
			weapon:base():tweak_data_anim_stop("reload_exit")
		end
	end
end

function FPCameraPlayerBase:anim_clbk_stop_weapon_magazine_empty()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) then
			weapon:base():tweak_data_anim_stop("magazine_empty")
			weapon:base():tweak_data_anim_stop("magazine_empty")
		end
	end
end

function FPCameraPlayerBase:anim_clbk_reset_dp28_mag_pos()
	local weapon = self._parent_unit:inventory():equipped_unit()

	weapon:base():reset_magazine_anim_pos()
end

function FPCameraPlayerBase:anim_clbk_punch_bren_mag()
	local align_obj = self._parent_unit:inventory():equipped_unit():base()._unit:get_object(Idstring("align_mag"))
	local position = align_obj:position()
	local rotation = align_obj:rotation()

	self:_unspawn_bren_mag_shell()

	local weapon_unit = self._parent_unit:inventory():equipped_unit():base()
	local mag_unit = nil

	if weapon_unit and weapon_unit._parts and weapon_unit._parts.wpn_fps_lmg_bren_m_extended then
		mag_unit = Idstring("units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_m_extended_prop")
	else
		mag_unit = Idstring("units/upd_005/weapons/wpn_fps_lmg_bren_pts/wpn_fps_lmg_bren_m_standard_prop")
	end

	self._bren_magazine = World:spawn_unit(mag_unit, position, rotation)

	self._bren_magazine:push_at(30, self._parent_unit:camera()._m_cam_fwd * 5, self._bren_magazine:position())
end

function FPCameraPlayerBase:_unspawn_bren_mag_shell()
	if not alive(self._bren_magazine) then
		return
	end

	World:delete_unit(self._bren_magazine)

	self._bren_magazine = nil
end

function FPCameraPlayerBase:anim_clbk_spawn_shotgun_shell()
	if alive(self._parent_unit) then
		local weapon = self._parent_unit:inventory():equipped_unit()

		if alive(weapon) and weapon:base().shotgun_shell_data then
			local shotgun_shell_data = weapon:base():shotgun_shell_data()

			if not shotgun_shell_data then
				return
			end

			local align_obj_l_name = Idstring("a_weapon_left")
			local align_obj_r_name = Idstring("a_weapon_right")
			local align_obj_l = self._unit:get_object(align_obj_l_name)
			local align_obj_r = self._unit:get_object(align_obj_r_name)
			local align_obj = align_obj_l

			if shotgun_shell_data.align and shotgun_shell_data.align == "right" then
				align_obj = align_obj_r
			end

			self:_unspawn_shotgun_shell()

			self._shell = World:spawn_unit(Idstring(shotgun_shell_data.unit_name), align_obj:position(), align_obj:rotation())

			self._unit:link(align_obj:name(), self._shell, self._shell:orientation_object():name())
		end
	end
end

function FPCameraPlayerBase:anim_clbk_unspawn_shotgun_shell()
	self:_unspawn_shotgun_shell()
end

function FPCameraPlayerBase:_unspawn_shotgun_shell()
	if not alive(self._shell) then
		return
	end

	self._shell:unlink()
	World:delete_unit(self._shell)

	self._shell = nil
end

function FPCameraPlayerBase:load_fps_mask_units()
	if not self._mask_backface_loaded then
		self._mask_backface_loaded = true
	end
end

function FPCameraPlayerBase:destroy()
	if self._parent_unit then
		self._parent_unit:base():remove_destroy_listener("FPCameraPlayerBase")
	end

	if self._light then
		World:delete_light(self._light)
	end

	if self._light_effect then
		World:effect_manager():kill(self._light_effect)

		self._light_effect = nil
	end

	self:anim_clbk_unspawn_handcuffs()
	self:unspawn_grenade()
	self:unspawn_melee_item()
	self:_unspawn_shotgun_shell()

	if self._mask_backface_loaded then
		self._mask_backface_loaded = nil
	end
end

function FPCameraPlayerBase:set_spin(_spin)
	self._camera_properties.spin = _spin
end

function FPCameraPlayerBase:set_pitch(_pitch)
	self._camera_properties.pitch = _pitch
end

function FPCameraPlayerBase:current_tilt()
	return self._camera_properties.current_tilt
end

function FPCameraPlayerBase:animate_pitch(start_t, start_pitch, end_pitch, total_duration)
	self._animate_pitch = {
		start_t = start_t,
		start_pitch = start_pitch or self._camera_properties.pitch,
		end_pitch = end_pitch,
		duration = total_duration
	}
end

function FPCameraPlayerBase:animate_pitch_upd()
	local t = Application:time()
	local elapsed_t = t - self._animate_pitch.start_t
	local step = elapsed_t / self._animate_pitch.duration

	if step > 1 then
		self._animate_pitch = nil
	else
		step = self:catmullrom(step, -10, 0, 1, 0.7)
		self._camera_properties.pitch = math.lerp(self._animate_pitch.start_pitch, self._animate_pitch.end_pitch, step)
	end
end

function FPCameraPlayerBase:update_tilt_smooth(direction, max_tilt, tilt_speed, dt)
	self._tilt_dt = self._tilt_dt or 0

	if direction < 0 and self._camera_properties.current_tilt <= 0 then
		self:set_target_tilt(-1 * self:smoothstep(0, max_tilt, self._tilt_dt, tilt_speed))

		if self._tilt_dt < tilt_speed then
			self._tilt_dt = self._tilt_dt + dt
		end
	elseif direction > 0 and self._camera_properties.current_tilt >= 0 then
		self:set_target_tilt(self:smoothstep(0, max_tilt, self._tilt_dt, tilt_speed))

		if self._tilt_dt < tilt_speed then
			self._tilt_dt = self._tilt_dt + dt
		end
	else
		self:set_target_tilt(math.sign(self._camera_properties.current_tilt) * self:smoothstep(0, max_tilt, self._tilt_dt, tilt_speed))

		if self._tilt_dt > 0 then
			self._tilt_dt = self._tilt_dt - 2 * dt

			if self._tilt_dt < 0 then
				self._tilt_dt = 0
			end
		end
	end
end

function FPCameraPlayerBase:catmullrom(t, p0, p1, p2, p3)
	return 0.5 * (2 * p1 + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t * t + (-p0 + 3 * p1 - 3 * p2 + p3) * t * t * t)
end

function FPCameraPlayerBase:smoothstep(a, b, step, n)
	local v = step / n
	v = 1 - (1 - v) * (1 - v)
	local x = a * (1 - v) + b * v

	return x
end
