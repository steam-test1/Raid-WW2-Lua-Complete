PlayerDriving = PlayerDriving or class(PlayerStandard)
PlayerDriving.IDS_STEER_LEFT_REDIRECT = Idstring("steering_wheel_left")
PlayerDriving.IDS_STEER_LEFT_STATE = Idstring("fps/driving/wheel_turn_left")
PlayerDriving.IDS_WHEEL_LEFT_ANIM = Idstring("anim_steering_wheel_left")
PlayerDriving.IDS_STEER_RIGHT_REDIRECT = Idstring("steering_wheel_right")
PlayerDriving.IDS_STEER_RIGHT_STATE = Idstring("fps/driving/wheel_turn_right")
PlayerDriving.IDS_WHEEL_RIGHT_ANIM = Idstring("anim_steering_wheel_right")
PlayerDriving.IDS_STEER_IDLE_REDIRECT = Idstring("steering_wheel_idle")
PlayerDriving.IDS_PASSENGER_REDIRECT = Idstring("passenger_vehicle")
PlayerDriving.EXIT_VEHICLE_TIMER = 0.4
PlayerDriving.STANCE_NORMAL = 0
PlayerDriving.STANCE_SHOOTING = 1

function PlayerDriving:init(unit)
	PlayerDriving.super.init(self, unit)

	self._vehicle = nil
	self._dt = 0
	self._move_x = 0
	self._stance = PlayerDriving.STANCE_NORMAL
	self._wheel_idle = false
	self._respawn_hint_shown = false
end

function PlayerDriving:enter(state_data, enter_data)
	print("PlayerDriving:enter( enter_data )")
	managers.viewport:skip_update_env_on_first_viewport(false)
	PlayerDriving.super.enter(self, state_data, enter_data)
	self:_hide_hud_prompts()

	if managers.viewport:first_active_viewport() then
		self._vehicle_unit:camera():setup()
	end
end

function PlayerDriving:_enter(enter_data)
	self:_get_vehicle()

	if self._vehicle == nil then
		print("[DRIVING] No vehicle found")

		return
	end

	if self._vehicle_ext:get_view() == nil then
		print("[DRIVING] No vehicle view point found")

		return
	end

	local idstr_ag_speedometer = Idstring("ag_speedometer")
	local idstr_ag_rpm_meter = Idstring("ag_rpm_meter")
	local anims = self._vehicle_unit:anim_groups()

	if anims then
		for _, v in pairs(anims) do
			if v == idstr_ag_speedometer then
				self._has_speedometer = true

				Application:debug("[PlayerDriving:_enter] has speedometer")
			elseif v == idstr_ag_rpm_meter then
				self._has_rpmmeter = true

				Application:debug("[PlayerDriving:_enter] has rpmmeter")
			end
		end
	end

	self._seat = self._vehicle_ext:find_seat_for_player(self._unit)

	self:_position_player_on_seat()

	self._equipped_unit = self._ext_inventory:equipped_unit()

	if self._equipped_unit:base().add_ignore_unit then
		self._equipped_unit:base():add_ignore_unit(self._vehicle_unit)
	end

	self:_setup_seat()
	self._ext_camera:set_shaker_parameter("breathing", "amplitude", 0)

	local fov = self._seat.fov or self._vehicle_ext._tweak_data.fov

	if fov then
		self._camera_unit:base():animate_fov(fov, 0.33)
	end

	Application:trace("[PlayerDriving:_enter] Setting FOV:  ", fov)

	self._controller = self._unit:base():controller()

	managers.controller:set_ingame_mode("driving")
	self:_upd_attention()
end

function PlayerDriving:_setup_seat()
	self._wheel_idle = false

	self:_set_camera_limits("seat")

	if self._seat.driving then
		if self._vehicle_unit:damage():has_sequence("local_driving_enter") then
			self._vehicle_unit:damage():run_sequence("local_driving_enter")
		end

		self._camera_unit:anim_state_machine():set_global(self._vehicle_ext._tweak_data.animations.vehicle_id, 1)
	else
		if self._vehicle_unit:damage():has_sequence("local_driving_exit") then
			self._vehicle_unit:damage():run_sequence("local_driving_exit")
		end

		self._camera_unit:anim_state_machine():set_global(self._vehicle_ext._tweak_data.animations.vehicle_id, 0)
	end

	self:_apply_allowed_shooting()
end

function PlayerDriving:exit(state_data, new_state_name)
	Application:debug("[PlayerDriving] PlayerDriving: Exiting vehicle")

	if self._seat.driving then
		self._vehicle_ext:stop_horn_sound()

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_honk_horn", self._vehicle_unit, false)
		end
	end

	managers.viewport:skip_update_env_on_first_viewport(false)
	PlayerDriving.super.exit(self, state_data, new_state_name)

	if self._vehicle_unit:camera() then
		self._vehicle_unit:camera():deactivate(self._unit)
	end

	self:_interupt_action_exit_vehicle()
	self:_interupt_action_steelsight()

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade()
	else
		self:_interupt_action_throw_projectile()
	end

	self:_interupt_action_reload()
	self:_interupt_action_charging_weapon()
	self:_interupt_action_melee()

	local exit = self._vehicle_ext:find_exit_position(self._unit)
	exit = exit or {
		position = self._unit:position() + Vector3(0, 0, 180),
		rotation = self._unit:rotation()
	}
	local pos = exit.position + Vector3(0, 0, 30)

	self._unit:set_rotation(exit.rotation)
	self._ext_camera:set_rotation(exit.rotation)
	self._unit:set_position(pos)
	self._ext_camera:set_position(pos)
	self._camera_unit:base():set_spin(exit.rotation:y():to_polar().spin)
	self._camera_unit:base():set_pitch(0)
	self._camera_unit:base():set_target_tilt(0)

	self._camera_unit:base().bipod_location = nil

	if self._vehicle_unit:damage():has_sequence("local_driving_exit") then
		self._vehicle_unit:damage():run_sequence("local_driving_exit")
	end

	self._ext_inventory:show_equipped_unit()
	self:_start_action_equip()
	managers.player:exit_vehicle()

	self._state_data.in_air = false
	self._stance = PlayerDriving.STANCE_NORMAL
	local exit_data = {
		skip_equip = true,
		equip_weapon_expire_t = self._equip_weapon_expire_t,
		unequip_weapon_expire_t = self._unequip_weapon_expire_t
	}
	local velocity = self._unit:mover() and self._unit:mover():velocity() or math.ZERO

	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("set_pose", 1)

	if self._equipped_unit:base().remove_ignore_unit then
		self._equipped_unit:base():remove_ignore_unit(self._vehicle_unit)
	end

	self:_upd_attention()
	self:_remove_camera_limits()
	self._camera_unit:base():animate_fov(75, 0.33)
	self._camera_unit:anim_state_machine():set_global(self._vehicle_ext._tweak_data.animations.vehicle_id, 0)
	managers.controller:set_ingame_mode("main")
	self:_show_hud_prompts()

	return exit_data
end

function PlayerDriving:_hide_hud_prompts()
	local weapon_base = self._equipped_unit:base()

	if weapon_base.out_of_ammo and weapon_base:out_of_ammo() then
		self._out_of_ammo_prompt_hidden = true
	elseif weapon_base.can_reload and weapon_base:can_reload() and weapon_base.clip_empty and weapon_base:clip_empty() then
		self._can_reload_prompt_hidden = true
	end

	managers.hud:hide_prompt("hud_reload_prompt")
	managers.hud:hide_prompt("hud_no_ammo_prompt")
end

function PlayerDriving:_show_hud_prompts()
	if self._out_of_ammo_prompt_hidden then
		managers.hud:set_prompt("hud_no_ammo_prompt", managers.localization:to_upper_text("hint_no_ammo"))

		self._out_of_ammo_prompt_hidden = false
	elseif self._can_reload_prompt_hidden then
		managers.hud:set_prompt("hud_reload_prompt", managers.localization:to_upper_text("hint_reload"))

		self._can_reload_prompt_hidden = false
	end
end

function PlayerDriving:update(t, dt)
	self._controller = self._unit:base():controller()

	if not alive(self._vehicle_unit) then
		return
	end

	if self._vehicle == nil then
		print("[DRIVING] No in a vehicle")

		return
	elseif not self._vehicle:is_active() then
		print("[DRIVING] The vehicle is not active")

		return
	end

	if self._controller == nil then
		print("[DRIVING] No controller available")

		return
	end

	self:_update_input(dt)

	local input = self:_get_input(t, dt)

	self:_calculate_standard_variables(t, dt)
	self:_update_ground_ray()
	self:_update_fwd_ray()
	self:_check_action_rear_cam(t, input)
	self:_check_action_change_seat(t, input)
	self:_check_action_exit_vehicle(t, input)
	self:_update_hud(t, dt)
	self:_update_action_timers(t, input)

	if self._seat.driving then
		self:_update_check_actions_driver(t, dt, input)
	elseif self._seat.allow_shooting or self._stance == PlayerDriving.STANCE_SHOOTING then
		self:_update_check_actions_passenger(t, dt, input)
	else
		self:_update_check_actions_passenger_no_shoot(t, dt, input)
	end

	self:_upd_nav_data()
end

function PlayerDriving:set_tweak_data(name)
end

function PlayerDriving:_update_hud(t, dt)
	if self._vehicle_ext.respawn_available and self._seat.driving then
		if not self._respawn_hint_shown then
			local string_macros = {}

			BaseInteractionExt:_add_string_macros(string_macros)

			local text = managers.localization:text("hud_int_press_respawn", string_macros)
			self._respawn_hint_shown = true

			managers.hud:show_interact({
				text = text
			})
		end
	elseif self._respawn_hint_shown then
		managers.hud:remove_interact()

		self._respawn_hint_shown = false
	end

	if managers.user:get_setting("hud_crosshairs") then
		if self:is_player_shooting_allowed() then
			managers.hud:update_crosshair_offset(t, dt)
			self:_update_crosshair_offset()
		else
			managers.hud:set_crosshair_fade(false)
		end
	end
end

function PlayerDriving:_update_check_actions_driver(t, dt, input)
	if managers.menu:is_pc_controller() and self._vehicle_unit and self._vehicle_ext then
		if input.btn_primary_attack_press then
			self._vehicle_ext:play_horn_sound()

			if managers.network:session() then
				managers.network:session():send_to_peers_synched("sync_honk_horn", self._vehicle_unit, true)
			end
		elseif input.btn_primary_attack_release then
			self._vehicle_ext:stop_horn_sound()

			if managers.network:session() then
				managers.network:session():send_to_peers_synched("sync_honk_horn", self._vehicle_unit, false)
			end
		end
	end

	self:_check_stats_screen(t, dt, input)
end

function PlayerDriving:_update_check_actions_passenger(t, dt, input)
	self:_update_check_actions(t, dt)
	self:_check_action_shooting_stance(t, input)
end

function PlayerDriving:_update_check_actions_passenger_no_shoot(t, dt, input)
	self:_check_stats_screen(t, dt, input)
	self:_check_action_shooting_stance(t, input)
end

function PlayerDriving:_check_action_warcry(t, input)
end

function PlayerDriving:on_action_reload_success()
	self._can_reload_prompt_hidden = false
end

function PlayerDriving:_check_action_jump(t, input)
	return false
end

function PlayerDriving:_check_action_interact(t, input)
	return false
end

function PlayerDriving:_check_action_duck()
	return false
end

function PlayerDriving:interaction_blocked()
	return true
end

function PlayerDriving:_check_action_shooting_stance(t, input)
	if self._shooting_stance_mandatory then
		return
	end

	if self._shooting_stance_allowed then
		if input.btn_vehicle_shooting_stance_press then
			self:_check_stop_shooting()
			self:_interupt_action_reload()

			if self._stance == PlayerDriving.STANCE_NORMAL then
				self:enter_shooting_stance()
			else
				self:exit_shooting_stance()
			end
		end
	elseif self._stance == PlayerDriving.STANCE_SHOOTING then
		self:exit_shooting_stance()
	end
end

function PlayerDriving:enter_shooting_stance()
	self._stance = PlayerDriving.STANCE_SHOOTING

	self:_position_player_on_seat()
	self:_set_camera_limits("shooting")
	self:_equip_weapons_for_shooting()
	self._ext_network:send("sync_vehicle_change_stance", self._stance)
end

function PlayerDriving:_equip_weapons_for_shooting()
	self._ext_inventory:show_equipped_unit()
	self:_start_action_equip()
	managers.hud:set_crosshair_fade(true)
end

function PlayerDriving:exit_shooting_stance()
	self._stance = PlayerDriving.STANCE_NORMAL

	self:_position_player_on_seat()
	self:_set_camera_limits("seat")
	self:_apply_allowed_shooting()
	managers.hud:set_crosshair_fade(false)
	self._ext_network:send("sync_vehicle_change_stance", self._stance)
end

function PlayerDriving:_apply_allowed_shooting()
	self._shooting_stance_allowed = self._vehicle_ext:shooting_stance_allowed() and self._seat.has_shooting_mode and self._seat.shooting_pos
	self._shooting_stance_mandatory = self._vehicle_ext:shooting_stance_mandatory() and self._shooting_stance_allowed

	if self._shooting_stance_mandatory then
		self:enter_shooting_stance()
	elseif self._seat.allow_shooting then
		self:_equip_weapons_for_shooting()
	else
		local t = managers.player:player_timer():time()

		self:_interupt_action_steelsight()

		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.projectiles[projectile_entry].is_a_grenade then
			self:_interupt_action_throw_grenade(t)
		else
			self:_interupt_action_throw_projectile(t)
		end

		self:_interupt_action_reload(t)
		self:_interupt_action_charging_weapon(t)
		self:_interupt_action_melee(t)
		self:_interupt_action_use_item(t)
		self._ext_camera:play_redirect(self.IDS_PASSENGER_REDIRECT)
		self._ext_camera:set_shaker_parameter("breathing", "amplitude", 0)
	end

	managers.controller:set_ingame_mode("driving")
end

function PlayerDriving:_check_action_exit_vehicle(t, input)
	if input.btn_vehicle_exit_press then
		if self._vehicle_ext.respawn_available then
			if self._seat.driving then
				self._vehicle_ext:respawn_vehicle()
			else
				self:_start_action_exit_vehicle(t)
			end
		else
			self:_start_action_exit_vehicle(t)
		end
	end

	if input.btn_vehicle_exit_release then
		self:_interupt_action_exit_vehicle()
	end
end

function PlayerDriving:_start_action_exit_vehicle(t)
	if not self._vehicle_ext:allow_exit() then
		return
	end

	if self:is_deploying() then
		return
	end

	local deploy_timer = PlayerDriving.EXIT_VEHICLE_TIMER
	self._exit_vehicle_expire_t = t + deploy_timer
	local text = utf8.to_upper(managers.localization:text("hud_action_exit_vehicle"))

	managers.hud:show_progress_timer_bar(0, deploy_timer, text)
end

function PlayerDriving:_interacting()
	return PlayerDriving.super._interacting(self) or self._exit_vehicle_expire_t
end

function PlayerDriving:_interupt_action_exit_vehicle(t, input, complete)
	if self._exit_vehicle_expire_t then
		self._exit_vehicle_expire_t = nil

		managers.hud:hide_progress_timer_bar(complete)
	end
end

function PlayerDriving:_update_action_timers(t, input)
	if self._exit_vehicle_expire_t then
		local deploy_timer = PlayerDriving.EXIT_VEHICLE_TIMER

		managers.hud:set_progress_timer_bar_width(deploy_timer - (self._exit_vehicle_expire_t - t), deploy_timer)

		if self._exit_vehicle_expire_t <= t then
			self:_end_action_exit_vehicle()

			self._exit_vehicle_expire_t = nil
		end
	end
end

function PlayerDriving:_end_action_exit_vehicle()
	managers.hud:hide_progress_timer_bar(true)
	self:cb_leave()
end

function PlayerDriving:_check_action_change_camera(t, input)
end

function PlayerDriving:_check_action_change_seat(t, input)
	if input.btn_vehicle_change_seat_press then
		self:_move_to_next_seat()
	end
end

function PlayerDriving:_check_action_rear_cam(t, input)
	if not self._seat.driving then
		return
	end

	if not self._vehicle_unit:camera() then
		return
	end

	if input.btn_vehicle_rear_view_press then
		self._vehicle_unit:camera():set_rear_cam_active(true, self._unit)
	elseif input.btn_vehicle_rear_view_release then
		self._vehicle_unit:camera():set_rear_cam_active(false, self._unit)
	end
end

function PlayerDriving:_check_action_run(...)
end

function PlayerDriving:pre_destroy(unit)
end

function PlayerDriving:stance()
	return self._stance
end

function PlayerDriving:is_player_shooting_allowed()
	return self._stance == PlayerDriving.STANCE_SHOOTING or self._seat.allow_shooting
end

function PlayerDriving:_set_camera_limits(mode)
	if mode == "seat" then
		if self._seat.camera_limits then
			self._camera_unit:base():set_limits(unpack(self._seat.camera_limits))
		else
			self._camera_unit:base():set_limits(60, 20)
		end
	elseif mode == "shooting" then
		if self._seat.camera_limits_shooting then
			self._camera_unit:base():set_limits(unpack(self._seat.camera_limits_shooting))
		else
			self._camera_unit:base():set_limits(nil, 40)
		end
	end
end

function PlayerDriving:_remove_camera_limits()
	self._camera_unit:base():remove_limits()
end

function PlayerDriving:_position_player_on_seat()
	local rot = self._seat.object:rotation()
	local pos = self._seat.object:position() + VehicleDrivingExt.PLAYER_CAPSULE_OFFSET

	self._unit:set_rotation(rot)
	self._unit:set_position(pos)
	self._ext_camera:set_rotation(rot)
	self._ext_camera:set_position(pos)
	self._camera_unit:base():set_spin(90)
	self._camera_unit:base():set_pitch(0)
end

function PlayerDriving:_move_to_next_seat()
	if self._seat.driving then
		self._vehicle_ext:stop_horn_sound()

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_honk_horn", self._vehicle_unit, false)
		end
	end

	self:_interupt_action_reload()
	self:_check_stop_shooting()
	managers.player:move_to_next_seat(self._vehicle_unit)
end

function PlayerDriving:sync_move_to_next_seat()
	self._seat = self._vehicle_ext:find_seat_for_player(self._unit)

	self._vehicle_unit:camera():set_rear_cam_active(false, self._unit)
	self:exit_shooting_stance()
	self:_setup_seat()
end

function PlayerDriving:destroy()
end

function PlayerDriving:_get_vehicle()
	self._vehicle_unit = managers.player:get_vehicle().vehicle_unit

	if self._vehicle_unit == nil then
		print("[DRIVING] no vehicles found in the scene")

		return
	end

	self._vehicle_ext = self._vehicle_unit:vehicle_driving()
	self._vehicle = self._vehicle_unit:vehicle()
end

function PlayerDriving:cb_leave()
	local exit_position = self._vehicle_ext:find_exit_position(self._unit)

	if exit_position == nil then
		print("[DRIVING] PlayerDriving: Could not found valid exit position, aborting exit.")
		managers.notification:add_notification({
			id = "hint_cant_exit_vehicle",
			shelf_life = 5,
			duration = 3,
			text = managers.localization:text("hint_cant_exit_vehicle")
		})

		return
	end

	managers.player:set_player_state("standard")
end

function PlayerDriving:_update_input(dt)
	if not self._seat.driving then
		return
	end

	local move_d = self._controller:get_input_axis("drive")
	local vehicle_state = self._vehicle:get_state()
	local steer = self._vehicle:get_steer()

	if steer == 0 and not self._wheel_idle then
		self._ext_camera:play_redirect(self.IDS_STEER_IDLE_REDIRECT)
		self._vehicle_unit:anim_stop(self.IDS_WHEEL_LEFT_ANIM)
		self._vehicle_unit:anim_stop(self.IDS_WHEEL_RIGHT_ANIM)

		self._wheel_idle = true
	end

	if steer > 0 then
		self._vehicle_unit:anim_stop(self.IDS_WHEEL_RIGHT_ANIM)

		local anim_length = self._vehicle_unit:anim_length(self.IDS_WHEEL_LEFT_ANIM)

		self._vehicle_unit:anim_set_time(self.IDS_WHEEL_LEFT_ANIM, math.abs(steer) * anim_length)
		self._vehicle_unit:anim_play(self.IDS_WHEEL_LEFT_ANIM)
		self._ext_camera:play_redirect_timeblend(self.IDS_STEER_LEFT_STATE, self.IDS_STEER_LEFT_REDIRECT, 0, math.abs(steer))

		self._wheel_idle = false
	end

	if steer < 0 then
		self._vehicle_unit:anim_stop(self.IDS_WHEEL_LEFT_ANIM)

		local anim_length = self._vehicle_unit:anim_length(self.IDS_WHEEL_RIGHT_ANIM)

		self._vehicle_unit:anim_set_time(self.IDS_WHEEL_RIGHT_ANIM, math.abs(steer) * anim_length)
		self._vehicle_unit:anim_play(self.IDS_WHEEL_RIGHT_ANIM)
		self._ext_camera:play_redirect_timeblend(self.IDS_STEER_RIGHT_STATE, self.IDS_STEER_RIGHT_REDIRECT, 0, math.abs(steer))

		self._wheel_idle = false
	end

	if self._has_speedometer then
		local speed_anim_length = self._vehicle_unit:anim_length(Idstring("ag_speedometer"))
		local rpm_anim_length = 1

		if self._has_rpmmeter then
			rpm_anim_length = self._vehicle_unit:anim_length(Idstring("ag_rpm_meter"))
		end

		local speed = vehicle_state:get_speed() * 3.6
		speed = speed * 1.25
		local rpm = vehicle_state:get_rpm()
		local max_speed = self._vehicle_ext._tweak_data.max_speed
		local max_rpm = self._vehicle:get_max_rpm()
		local relative_speed = speed / max_speed

		if relative_speed > 1 then
			relative_speed = 1
		end

		relative_speed = relative_speed * speed_anim_length
		local relative_rpm = rpm / max_rpm

		if relative_rpm > 1 then
			relative_rpm = 1
		end

		relative_rpm = relative_rpm * rpm_anim_length

		self._vehicle_unit:anim_set_time(Idstring("ag_speedometer"), relative_speed)
		self._vehicle_unit:anim_play(Idstring("ag_speedometer"))

		if self._has_rpmmeter then
			self._vehicle_unit:anim_set_time(Idstring("ag_rpm_meter"), relative_rpm)
			self._vehicle_unit:anim_play(Idstring("ag_rpm_meter"))
		end
	end

	local forced_gear = -1

	if vehicle_state:get_speed() < 0.5 and move_d.y < 0 and vehicle_state:get_gear() ~= 0 then
		forced_gear = 0
	end

	if vehicle_state:get_speed() < 0.5 and move_d.y > 0 and vehicle_state:get_gear() ~= 2 then
		forced_gear = 2
	end

	local direction = 1

	if vehicle_state:get_gear() == 0 and move_d.y ~= 0 then
		direction = -1
	end

	local accelerate = 0
	local brake = 0

	if direction > 0 then
		if move_d.y > 0 then
			accelerate = move_d.y
		else
			brake = -move_d.y
		end
	elseif move_d.y > 0 then
		brake = move_d.y
	else
		accelerate = -move_d.y
	end

	local input_held = self._controller:get_any_input()
	local btn_handbrake_held = input_held and self._controller:get_input_bool("jump")
	local handbrake = 0

	if btn_handbrake_held then
		handbrake = 1
	end

	if move_d.x == 0 and math.abs(self._move_x) > 0 then
		self._dt = dt
		self._max_steer = math.abs(steer)
	else
		self._max_steer = 0
	end

	if math.abs(self._move_x) < math.abs(move_d.x) then
		-- Nothing
	end

	local steer = -self._move_x

	if self._dt > 0 and self._dt < self._max_steer then
		self._move_x = self:smoothstep(0, self._max_steer, self._dt, self._max_steer) * math.sign(self._move_x)
		self._dt = self._dt + dt
	elseif math.abs(move_d.x) == 1 and math.abs(self._move_x) < 0.99 then
		self._move_x = self:smoothstep(math.abs(move_d.x), 0, self._dt, math.abs(move_d.x)) * math.sign(move_d.x)
		self._dt = self._dt + dt
	else
		self._move_x = move_d.x
		self._dt = 0
	end

	local back_light = self._vehicle_unit:get_object(Idstring("light_back"))
	local back_light_effect = self._vehicle_unit:get_object(Idstring("g_lights_rear_effect"))

	if back_light and brake > 0 then
		back_light:set_enable(true)
	elseif back_light then
		back_light:set_enable(false)
	end

	if back_light_effect and brake > 0 then
		back_light_effect:set_visibility(true)
	elseif back_light_effect then
		back_light_effect:set_visibility(false)
	end

	self._vehicle_ext:set_input(accelerate, steer, brake, handbrake, false, false, forced_gear, dt, move_d.y)
end

function PlayerDriving:inventory_clbk_listener(unit, event)
	if event == "equip" and alive(self._equipped_unit) and self._equipped_unit:base().remove_ignore_unit then
		self._equipped_unit:base():remove_ignore_unit(self._vehicle_unit)
	end

	PlayerDriving.super.inventory_clbk_listener(self, unit, event)

	if event == "equip" and alive(self._equipped_unit) and self._equipped_unit:base().add_ignore_unit then
		self._equipped_unit:base():add_ignore_unit(self._vehicle_unit)
	end
end

function PlayerDriving:smoothstep(a, b, step, n)
	local v = step / n
	v = 1 - (1 - v) * (1 - v)
	local x = a * v + b * (1 - v)

	return x
end

function PlayerDriving:force_change_weapon_slot(slot, instant)
end
