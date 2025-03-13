local mvec3_dis_sq = mvector3.distance_sq
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
PlayerStandard = PlayerStandard or class(PlayerMovementState)
PlayerStandard.MOVER_STAND = Idstring("stand")
PlayerStandard.MOVER_DUCK = Idstring("duck")
PlayerStandard.IDS_EQUIP = Idstring("equip")
PlayerStandard.IDS_MASK_EQUIP = Idstring("mask_equip")
PlayerStandard.IDS_UNEQUIP = Idstring("unequip")
PlayerStandard.IDS_RELOAD_EXIT = Idstring("reload_exit")
PlayerStandard.IDS_RELOAD_NOT_EMPTY_EXIT = Idstring("reload_not_empty_exit")
PlayerStandard.IDS_START_RUNNING = Idstring("start_running")
PlayerStandard.IDS_STOP_RUNNING = Idstring("stop_running")
PlayerStandard.IDS_STOP_RUNNING_STATE = Idstring("fps/stop_running")
PlayerStandard.IDS_MELEE = Idstring("melee")
PlayerStandard.IDS_MELEE_MISS = Idstring("melee_miss")
PlayerStandard.IDS_MELEE_BAYONET = Idstring("melee_bayonet")
PlayerStandard.IDS_MELEE_MISS_BAYONET = Idstring("melee_miss_bayonet")
PlayerStandard.IDS_IDLE = Idstring("idle")
PlayerStandard.IDS_USE = Idstring("use")
PlayerStandard.IDS_RECOIL = Idstring("recoil")
PlayerStandard.IDS_RECOIL_STEELSIGHT = Idstring("recoil_steelsight")
PlayerStandard.IDS_RECOIL_ENTER = Idstring("recoil_enter")
PlayerStandard.IDS_RECOIL_LOOP = Idstring("recoil_loop")
PlayerStandard.IDS_RECOIL_EXIT = Idstring("recoil_exit")
PlayerStandard.IDS_MELEE_CHARGE = Idstring("melee_charge")
PlayerStandard.IDS_MELEE_CHARGE_STATE = Idstring("fps/melee_charge")
PlayerStandard.IDS_MELEE_CHARGE_IDLE_STATE = Idstring("fps/melee_charge_idle")
PlayerStandard.IDS_MELEE_ATTACK = Idstring("melee_attack")
PlayerStandard.IDS_MELEE_ATTACK_STATE = Idstring("fps/melee_attack")
PlayerStandard.IDS_MELEE_EXIT_STATE = Idstring("fps/melee_exit")
PlayerStandard.IDS_MELEE_ENTER = Idstring("melee_enter")
PlayerStandard.IDS_PROJECTILE_START = Idstring("throw_projectile_start")
PlayerStandard.IDS_PROJECTILE_IDLE = Idstring("throw_projectile_idle")
PlayerStandard.IDS_PROJECTILE_THROW = Idstring("throw_projectile")
PlayerStandard.IDS_PROJECTILE_THROW_STATE = Idstring("fps/throw_projectile")
PlayerStandard.IDS_PROJECTILE_EXIT_STATE = Idstring("fps/throw_projectile_exit")
PlayerStandard.IDS_PROJECTILE_ENTER = Idstring("throw_projectile_enter")
PlayerStandard.IDS_TOSS_AMMO = Idstring("toss_ammo")
PlayerStandard.IDS_CHARGE = Idstring("charge")
PlayerStandard.IDS_BASE = Idstring("base")
PlayerStandard.IDS_CASH_INSPECT = Idstring("cash_inspect")
PlayerStandard.IDS_FALLING = Idstring("falling")
PlayerStandard.IDS_GRENADE_THROW = Idstring("throw_grenade")
PlayerStandard.IDS_GRENADE_THROW_NOW = Idstring("throw_grenade_now")
PlayerStandard.IDS_MANTLE = Idstring("mantle")
PlayerStandard.ALT_ENTER_FULLSCREEN_SWITCH_COOLDOWN = 2
PlayerStandard.THROW_GRENADE_COOLDOWN = 0.75
PlayerStandard.THROW_GRENADE_COOLDOWN_INSTANT = 0.5
PlayerStandard.MELEE_RAY_ATTEMPTS = 5
PlayerStandard.debug_bipod = nil

function PlayerStandard:init(unit)
	PlayerMovementState.init(self, unit)
	self:set_class_tweak_data(managers.skilltree:has_character_profile_class() and managers.skilltree:get_character_profile_class())

	self._obj_com = self._unit:get_object(Idstring("rp_mover"))
	self._slotmask_gnd_ray = managers.slot:get_mask("player_ground_check")
	self._slotmask_fwd_ray = managers.slot:get_mask("bullet_impact_targets")
	self._slotmask_bullet_impact_targets = managers.slot:get_mask("bullet_impact_targets_no_teamai")
	self._slotmask_pickups = managers.slot:get_mask("pickups")
	self._slotmask_AI_visibility = managers.slot:get_mask("AI_visibility")
	self._slotmask_long_distance_interaction = managers.slot:get_mask("long_distance_interaction")
	self._slotmask_enemies = managers.slot:get_mask("enemies")
	self._slotmask_world = managers.slot:get_mask("world_geometry")
	self._ext_camera = unit:camera()
	self._ext_movement = unit:movement()
	self._ext_damage = unit:character_damage()
	self._ext_inventory = unit:inventory()
	self._ext_anim = unit:anim_data()
	self._ext_network = unit:network()
	self._camera_unit = self._ext_camera._camera_unit
	self._camera_unit_anim_data = self._camera_unit:anim_data()
	self._machine = unit:anim_state_machine()
	self._m_pos = self._ext_movement:m_pos()
	self._pos = Vector3()
	self._stick_move = Vector3()
	self._stick_look = Vector3()
	self._cam_fwd_flat = Vector3()
	self._not_moving_t = 0
	self._last_sent_pos = unit:position()
	self._last_sent_pos_t = 0
	self._state_data = unit:movement()._state_data
	self._pickup_area = 120
end

function PlayerStandard:enter(state_data, enter_data)
	PlayerMovementState.enter(self, state_data, enter_data)
	tweak_data:add_reload_callback(self, self.tweak_data_clbk_reload)

	self._state_data = state_data
	self._state_data.using_bipod = managers.player:current_state() == "bipod"
	self._equipped_unit = self._ext_inventory:equipped_unit()
	local weapon = self._ext_inventory:equipped_unit()
	self._weapon_hold = weapon and weapon:base().weapon_hold and weapon:base():weapon_hold() or weapon:base():get_name_id()

	self:inventory_clbk_listener(self._unit, "equip")
	self:_enter(enter_data)
	self:_update_ground_ray()

	self._controller = self._unit:base():controller()

	if not self._unit:mover() then
		self:_activate_mover(PlayerStandard.MOVER_STAND)
	end

	if not self._state_data.on_ladder then
		self:set_gravity(tweak_data.player.gravity)
	end

	if (enter_data and enter_data.wants_crouch or not self:_can_stand()) and not self._state_data.ducking then
		self:_start_action_ducking(managers.player:player_timer():time())
	end

	if self._ext_movement:nav_tracker() then
		self._pos_reservation = {
			radius = 100,
			position = self._ext_movement:m_pos(),
			filter = self._ext_movement:pos_rsrv_id()
		}
		self._pos_reservation_slow = {
			radius = 100,
			position = mvector3.copy(self._ext_movement:m_pos()),
			filter = self._ext_movement:pos_rsrv_id()
		}

		managers.navigation:add_pos_reservation(self._pos_reservation)
		managers.navigation:add_pos_reservation(self._pos_reservation_slow)
	end

	managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())
	self:_check_weapon_forbids()

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE) then
		self:set_weapon_selection_wanted(PlayerInventory.SLOT_4)
	elseif enter_data and enter_data.equip_weapon then
		self:set_weapon_selection_wanted(enter_data.equip_weapon)
	end

	self:_reset_delay_action()
	self:setup_upgrades()

	self._last_velocity_xy = Vector3()
	self._last_sent_pos_t = enter_data and enter_data.last_sent_pos_t or managers.player:player_timer():time()
	self._last_sent_pos = enter_data and enter_data.last_sent_pos or mvector3.copy(self._pos)
	self._gnd_ray = true
end

function PlayerStandard:_enter(enter_data)
	self._unit:base():set_slot(self._unit, 2)

	if Network:is_server() and self._ext_movement:nav_tracker() then
		managers.groupai:state():on_player_weapons_hot()
	end

	if self._ext_movement:nav_tracker() then
		managers.groupai:state():on_criminal_recovered(self._unit)
	end

	local skip_equip = enter_data and enter_data.skip_equip

	if not self:_changing_weapon() and not skip_equip then
		self:_start_action_equip()
	end

	if enter_data then
		self._unequip_weapon_expire_t = enter_data.unequip_weapon_expire_t or self._unequip_weapon_expire_t
		self._equip_weapon_expire_t = enter_data.equip_weapon_expire_t or self._equip_weapon_expire_t
		self._change_weapon_data = enter_data.change_weapon_data or self._change_weapon_data
	end

	self:update_tilt()

	if self._ext_movement:nav_tracker() then
		self._standing_nav_seg_id = self._ext_movement:nav_tracker():nav_segment()
		local metadata = managers.navigation:get_nav_seg_metadata(self._standing_nav_seg_id)

		self._unit:base():set_suspicion_multiplier("area", metadata.suspicion_mul)
		self._unit:base():set_detection_multiplier("area", metadata.detection_mul and 1 / metadata.detection_mul or nil)
		managers.hud:set_map_location(metadata.location_id)
	end

	self:_upd_attention()
	self._ext_network:send("set_stance", 2, false, false)
end

function PlayerStandard:_check_weapon_forbids()
	local block_slot_1 = false
	local block_slot_2 = false
	local block_slot_3 = false
	local block_slot_4 = false

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE) then
		block_slot_1 = true
		block_slot_2 = true
		block_slot_3 = true
		block_slot_4 = false
	end

	if managers.player:has_category_upgrade("player", "bellhop_weight_increase_off_primary") then
		block_slot_2 = managers.player:is_carrying_over_full(true)
	end

	if block_slot_1 and block_slot_2 and block_slot_3 then
		block_slot_4 = false
	end

	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_1, block_slot_1)
	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_2, block_slot_2)
	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_3, block_slot_3)
	self._ext_inventory:set_selection_blocked(PlayerInventory.SLOT_4, block_slot_4)
end

function PlayerStandard:set_tweak_data(name)
	self._tweak_data_name = name
end

function PlayerStandard:update_tilt()
	local tilt = PlayerCarry.target_tilt * math.min(1, managers.player:get_my_carry_weight_ratio())

	self._unit:camera():camera_unit():base():set_target_tilt(tilt)

	if self._ext_camera and managers.user:get_setting("use_headbob") then
		self._ext_camera:play_shaker("player_carry", 0.35)
	end
end

function PlayerStandard:exit(state_data, new_state_name)
	PlayerMovementState.exit(self, state_data)
	tweak_data:remove_reload_callback(self)

	local t = managers.player:player_timer():time()

	self:_interupt_action_interact(t, nil, nil, true)
	self:_interupt_action_use_item()
	managers.environment_controller:set_dof_distance()

	if self._pos_reservation then
		managers.navigation:unreserve_pos(self._pos_reservation)
		managers.navigation:unreserve_pos(self._pos_reservation_slow)

		self._pos_reservation = nil
		self._pos_reservation_slow = nil
	end

	if self._running then
		self:_end_action_running(t)
		self:set_running(false)
	end

	if self._shooting then
		self._shooting = false

		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting()
	end

	self._headbob = 0
	self._target_headbob = 0

	self._ext_camera:set_shaker_parameter("headbob", "amplitude", 0)

	local exit_data = {
		skip_equip = true,
		equip_weapon_expire_t = self._equip_weapon_expire_t,
		unequip_weapon_expire_t = self._unequip_weapon_expire_t,
		change_weapon_data = self._change_weapon_data,
		last_sent_pos_t = self._last_sent_pos_t,
		last_sent_pos = self._last_sent_pos,
		ducking = self._state_data.ducking
	}
	self._state_data.using_bipod = managers.player:current_state() == "bipod"

	self:_update_network_jump(nil, true)

	return exit_data
end

function PlayerStandard:_activate_mover(mover, velocity)
	self._unit:activate_mover(mover, velocity)

	if self._state_data.on_ladder then
		self:set_gravity(0)
	else
		self:set_gravity(tweak_data.player.gravity)
	end

	if self._is_jumping then
		self._unit:mover():jump()
		self._unit:mover():set_velocity(velocity)
	end
end

function PlayerStandard:jumping()
	return self._is_jumping
end

function PlayerStandard:interaction_blocked()
	return self:is_deploying() or self:_on_zipline()
end

function PlayerStandard:bleed_out_blocked()
	return false
end

local tmp_vec1 = Vector3()

function PlayerStandard:update(t, dt)
	if managers.menu.loading_screen_visible or managers.system_menu:is_active() then
		return
	end

	self._controller = self._unit:base():controller()

	if self.debug_bipod then
		self._equipped_unit:base():_debug_bipod()
	end

	if Global.show_weapon_spread and self._equipped_unit and self._equipped_unit:base().update_debug then
		self._equipped_unit:base():update_debug(t, dt)
	end

	PlayerMovementState.update(self, t, dt)
	self:_calculate_standard_variables(t, dt)
	self:_update_ground_ray()
	self:_update_fwd_ray()
	self:_update_check_actions(t, dt)
	self:_find_pickups(t)
	self:_update_movement(t, dt)
	self:_update_aim_speed(t, dt)

	if managers.player:upgrade_value("player", "warcry_aim_assist", false) == true then
		self:_update_check_sweep_aim_assist(t, dt)
	end

	self:_upd_nav_data()
	managers.hud:update_crosshair_offset(t, dt)

	if managers.user:get_setting("hud_crosshairs") then
		self:_update_crosshair_offset()
	end
end

function PlayerStandard:in_air()
	return self._state_data.in_air
end

function PlayerStandard:in_steelsight()
	return self._state_data.in_steelsight
end

function PlayerStandard:is_reticle_aim()
	return self._state_data.reticle_obj and self._camera_unit:base():is_stance_done() and not self._equipped_unit:base():is_second_sight_on()
end

function PlayerStandard:get_fire_weapon_position()
	if self:is_reticle_aim() then
		return self._ext_camera:position_with_shake()
	else
		return self._ext_camera:position()
	end
end

function PlayerStandard:get_fire_weapon_direction()
	if self:is_reticle_aim() then
		return self._ext_camera:forward_with_shake_toward_reticle(self._state_data.reticle_obj)
	else
		return self._ext_camera:forward()
	end
end

local temp_vec1 = Vector3()

function PlayerStandard:_upd_nav_data()
	if mvec3_dis_sq(self._m_pos, self._pos) > 1 then
		if alive(self._ext_movement:nav_tracker()) and self._ext_movement:nav_tracker() then
			self._ext_movement:nav_tracker():move(self._pos)

			local nav_seg_id = self._ext_movement:nav_tracker():nav_segment()

			if self._standing_nav_seg_id ~= nav_seg_id then
				self._standing_nav_seg_id = nav_seg_id
				local metadata = managers.navigation:get_nav_seg_metadata(nav_seg_id)

				self._unit:base():set_suspicion_multiplier("area", metadata.suspicion_mul)
				self._unit:base():set_detection_multiplier("area", metadata.detection_mul and 1 / metadata.detection_mul or nil)
				managers.groupai:state():on_criminal_nav_seg_change(self._unit, nav_seg_id)
				managers.hud:set_map_location(metadata.location_id)
			end
		end

		if self._pos_reservation then
			managers.navigation:move_pos_rsrv(self._pos_reservation)

			local slow_dist = 100

			mvec3_set(temp_vec1, self._pos_reservation_slow.position)
			mvec3_sub(temp_vec1, self._pos_reservation.position)

			if slow_dist < mvec3_norm(temp_vec1) then
				mvec3_mul(temp_vec1, slow_dist)
				mvec3_add(temp_vec1, self._pos_reservation.position)
				mvec3_set(self._pos_reservation_slow.position, temp_vec1)
				managers.navigation:move_pos_rsrv(self._pos_reservation)
			end
		end

		self._ext_movement:set_m_pos(self._pos)
	end
end

function PlayerStandard:_calculate_standard_variables(t, dt)
	self._gnd_ray = nil
	self._gnd_ray_chk = nil

	self._unit:m_position(self._pos)

	self._rot = self._unit:rotation()
	self._cam_fwd = self._ext_camera:forward()

	mvector3.set(self._cam_fwd_flat, self._cam_fwd)
	mvector3.set_z(self._cam_fwd_flat, 0)
	mvector3.normalize(self._cam_fwd_flat)

	local last_vel_xy = self._last_velocity_xy
	local sampled_vel_dir = self._unit:sampled_velocity()

	if not self._state_data.on_ladder then
		mvector3.set_z(sampled_vel_dir, 0)
	end

	local sampled_vel_len = mvector3.normalize(sampled_vel_dir)

	if sampled_vel_len == 0 then
		mvector3.set_zero(self._last_velocity_xy)
	else
		local fwd_dot = mvector3.dot(sampled_vel_dir, last_vel_xy)

		mvector3.set(self._last_velocity_xy, sampled_vel_dir)

		if sampled_vel_len < fwd_dot then
			mvector3.multiply(self._last_velocity_xy, sampled_vel_len)
		else
			mvector3.multiply(self._last_velocity_xy, math.max(0, fwd_dot))
		end
	end

	local not_moving = mvec3_dis_sq(self._m_pos, self._pos) < 1
	self._not_moving_t = not_moving and self._not_moving_t + dt or 0
	self._setting_hold_to_run = managers.user:get_setting("hold_to_run")
	self._setting_hold_to_duck = managers.user:get_setting("hold_to_duck")
end

local tmp_ground_from_vec = Vector3()
local tmp_ground_to_vec = Vector3()
local up_offset_vec = math.UP * 30
local down_offset_vec = math.DOWN * 35
local angle_epsilon = 0.0001

function PlayerStandard:_update_ground_ray()
	local hips_pos = tmp_ground_from_vec
	local down_pos = tmp_ground_to_vec

	mvector3.set(hips_pos, self._pos)
	mvector3.add(hips_pos, up_offset_vec)
	mvector3.set(down_pos, hips_pos)
	mvector3.add(down_pos, down_offset_vec)

	if alive(self._unit:movement():ladder_unit()) then
		self._gnd_ray = self._unit:movement():ladder_unit():raycast("ray", hips_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29, "report")
		self._gnd_angle = 0
	else
		self._gnd_ray = World:raycast("ray", hips_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29)
		self._gnd_angle = self._gnd_ray and self._gnd_ray.normal:angle(math.UP) + angle_epsilon
	end

	self._gnd_ray_chk = true
end

function PlayerStandard:_update_fwd_ray(in_steelsight)
	if not alive(self._equipped_unit) then
		return
	end

	in_steelsight = in_steelsight or self._state_data.in_steelsight
	local range = 4000
	local from = self._ext_movement:m_head_pos()
	local to = self._cam_fwd * range

	mvector3.add(to, from)

	self._fwd_ray = World:raycast("ray", from, to, "slot_mask", self._slotmask_fwd_ray)

	managers.environment_controller:set_dof_distance(math.clamp(self._fwd_ray and self._fwd_ray.distance or range, 0, range) - 200, in_steelsight)
end

function PlayerStandard:_create_on_controller_disabled_input()
	local release_interact = Global.game_settings.single_player or not managers.menu:get_controller():get_input_bool("interact")
	local input = {
		btn_melee_release = true,
		btn_use_item_release = true,
		btn_steelsight_release = true,
		is_customized = true,
		btn_interact_release = release_interact
	}

	return input
end

local win32 = IS_PC

function PlayerStandard:_get_input(t, dt)
	if self._state_data.controller_enabled ~= self._controller:enabled() then
		if self._state_data.controller_enabled then
			self._state_data.controller_enabled = self._controller:enabled()

			return self:_create_on_controller_disabled_input()
		else
			self._state_data.controller_enabled = self._controller:enabled()

			return {}
		end
	elseif not self._state_data.controller_enabled then
		local input = {
			is_customized = true,
			btn_interact_release = managers.menu:get_controller():get_input_released("interact")
		}

		return input
	end

	self._state_data.controller_enabled = self._controller:enabled()
	local pressed = self._controller:get_any_input_pressed()
	local released = self._controller:get_any_input_released()
	local held = self._controller:get_any_input()

	if not pressed and not released and not held then
		return {}
	end

	local input = {
		btn_deploy_bipod = false,
		any_input_pressed = pressed,
		any_input_released = released,
		any_input_held = held,
		btn_stats_screen_press = pressed and self._controller:get_input_pressed("stats_screen"),
		btn_stats_screen_down = held and self._controller:get_input_bool("stats_screen"),
		btn_stats_screen_release = released and self._controller:get_input_released("stats_screen"),
		btn_duck_press = pressed and self._controller:get_input_pressed("duck"),
		btn_duck_state = held and self._controller:get_input_bool("duck"),
		btn_duck_release = released and self._controller:get_input_released("duck"),
		btn_activate_warcry_press = pressed and self._controller:get_input_pressed("activate_warcry"),
		btn_warcry_left_state = held and self._controller:get_input_bool("menu_controller_shoulder_left"),
		btn_warcry_right_state = held and self._controller:get_input_bool("menu_controller_shoulder_right"),
		btn_jump_press = pressed and self._controller:get_input_pressed("jump"),
		btn_primary_attack_press = pressed and self._controller:get_input_pressed("primary_attack"),
		btn_primary_attack_state = held and self._controller:get_input_bool("primary_attack"),
		btn_primary_attack_release = released and self._controller:get_input_released("primary_attack"),
		btn_reload_press = pressed and self._controller:get_input_pressed("reload"),
		btn_weapon_firemode_press = pressed and self._controller:get_input_pressed("weapon_firemode"),
		btn_steelsight_press = pressed and self._controller:get_input_pressed("secondary_attack"),
		btn_steelsight_state = held and self._controller:get_input_bool("secondary_attack"),
		btn_steelsight_release = released and self._controller:get_input_released("secondary_attack"),
		btn_interact_press = pressed and self._controller:get_input_pressed("interact"),
		btn_interact_release = released and self._controller:get_input_released("interact"),
		btn_run_press = pressed and self._controller:get_input_pressed("run"),
		btn_run_state = held and self._controller:get_input_bool("run"),
		btn_run_release = released and self._controller:get_input_released("run"),
		btn_switch_weapon_press = pressed and self._controller:get_input_pressed("switch_weapon"),
		btn_next_weapon_press = pressed and self._controller:get_input_pressed("next_weapon"),
		btn_previous_weapon_press = pressed and self._controller:get_input_pressed("previous_weapon"),
		btn_use_item_press = pressed and self._controller:get_input_pressed("use_item"),
		btn_use_item_release = released and self._controller:get_input_released("use_item"),
		btn_melee_press = pressed and self._controller:get_input_pressed("melee"),
		btn_melee_state = held and self._controller:get_input_bool("melee"),
		btn_melee_release = released and self._controller:get_input_released("melee"),
		btn_weapon_gadget_press = pressed and self._controller:get_input_pressed("weapon_gadget"),
		btn_throw_grenade_press = pressed and self._controller:get_input_pressed("throw_grenade"),
		btn_projectile_press = pressed and self._controller:get_input_pressed("throw_grenade"),
		btn_projectile_state = held and self._controller:get_input_bool("throw_grenade"),
		btn_projectile_release = released and self._controller:get_input_released("throw_grenade"),
		btn_left_alt_inspect_state = held and self._controller:get_input_bool("lean_modifier"),
		btn_enter_inspect_state = held and self._controller:get_input_bool("start"),
		btn_vehicle_exit_press = pressed and self._controller:get_input_pressed("vehicle_exit"),
		btn_vehicle_exit_release = released and self._controller:get_input_released("vehicle_exit"),
		btn_vehicle_rear_view_press = pressed and self._controller:get_input_pressed("vehicle_rear_camera"),
		btn_vehicle_rear_view_release = released and self._controller:get_input_released("vehicle_rear_camera"),
		btn_vehicle_shooting_stance_press = pressed and self._controller:get_input_pressed("vehicle_shooting_stance"),
		btn_vehicle_shooting_stance_release = released and self._controller:get_input_released("vehicle_shooting_stance"),
		btn_vehicle_change_seat_press = pressed and self._controller:get_input_pressed("vehicle_change_seat"),
		btn_comm_wheel_press = pressed and self._controller:get_input_pressed("comm_wheel"),
		btn_comm_wheel_release = released and self._controller:get_input_released("comm_wheel")
	}
	local is_kbm = self._controller:get_type() == "pc"

	if is_kbm then
		input.btn_comm_wheel_yes_press = pressed and self._controller:get_input_pressed("comm_wheel_yes")
		input.btn_comm_wheel_no_press = pressed and self._controller:get_input_pressed("comm_wheel_no")
		input.btn_comm_wheel_found_it_press = pressed and self._controller:get_input_pressed("comm_wheel_found_it")
		input.btn_comm_wheel_wait_press = pressed and self._controller:get_input_pressed("comm_wheel_wait")
		input.btn_comm_wheel_not_here_press = pressed and self._controller:get_input_pressed("comm_wheel_not_here")
		input.btn_comm_wheel_follow_me_press = pressed and self._controller:get_input_pressed("comm_wheel_follow_me")
		input.btn_comm_wheel_assistance_press = pressed and self._controller:get_input_pressed("comm_wheel_assistance")
		input.btn_comm_wheel_enemy_press = pressed and self._controller:get_input_pressed("comm_wheel_enemy")
		input.btn_cash_inspect_press = pressed and self._controller:get_input_pressed("cash_inspect")
	end

	if is_kbm then
		if self._controller:get_input_pressed("primary_choice1") then
			input.btn_primary_choice = 1
		end

		if self._controller:get_input_pressed("primary_choice2") then
			input.btn_primary_choice = 2
		end
	end

	if self._controller:get_input_pressed("primary_choice3") then
		input.btn_primary_choice = 3
	end

	if self._controller:get_input_pressed("primary_choice4") then
		input.btn_primary_choice = 4
	end

	if input.btn_primary_attack_press then
		self._queue_primary_attack_t = t + tweak_data.player.primary_attack_buffer
	elseif input.btn_primary_attack_release then
		self._queue_primary_attack_t = nil
	end

	return input
end

function PlayerStandard:_determine_move_direction()
	self._stick_move = self._controller:get_input_axis("move")

	if self._state_data.on_zipline or self._state_data.mantling then
		return
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CAN_MOVE_ONLY_BACK_AND_SIDE) then
		mvector3.set(self._stick_move, Vector3(self._stick_move.x, -math.abs(self._stick_move.y), self._stick_move.z))
	end

	local condition = mvector3.length(self._stick_move) < 0.1 or self:_interacting() or self:_does_deploying_limit_movement()

	if condition then
		self._move_dir = nil
		self._normal_move_dir = nil
	else
		local ladder_unit = self._unit:movement():ladder_unit()

		if alive(ladder_unit) then
			local ladder_ext = ladder_unit:ladder()
			self._move_dir = mvector3.copy(self._stick_move)
			self._normal_move_dir = mvector3.copy(self._move_dir)
			local cam_flat_rot = Rotation(self._cam_fwd_flat, math.UP)

			mvector3.rotate_with(self._normal_move_dir, cam_flat_rot)

			local cam_rot = Rotation(self._cam_fwd, self._ext_camera:rotation():z())

			mvector3.rotate_with(self._move_dir, cam_rot)

			local up_dot = math.dot(self._move_dir, ladder_ext:up())
			local w_dir_dot = math.dot(self._move_dir, ladder_ext:w_dir())
			local normal_dot = math.dot(self._move_dir, ladder_ext:normal()) * -1
			local normal_offset = ladder_ext:get_normal_move_offset(self._unit:movement():m_pos())

			mvector3.set(self._move_dir, ladder_ext:up() * (up_dot + normal_dot))
			mvector3.add(self._move_dir, ladder_ext:w_dir() * w_dir_dot)
			mvector3.add(self._move_dir, ladder_ext:normal() * normal_offset)
		else
			self._move_dir = mvector3.copy(self._stick_move)
			local cam_rot = self._ext_camera:rotation()
			local cam_yaw = cam_rot:yaw()

			if cam_rot:roll() ~= 0 then
				local pitch_factor = math.abs(cam_rot:pitch()) / 90
				cam_yaw = cam_yaw + cam_rot:roll() * pitch_factor
			end

			local cam_flat_rot = Rotation(cam_yaw, 0, 0)

			mvector3.rotate_with(self._move_dir, cam_flat_rot)

			self._normal_move_dir = mvector3.copy(self._move_dir)
		end
	end
end

function PlayerStandard:_find_pickups(t)
	local perseverance_active = self._ext_damage:is_perseverating()
	local need_ammo = self._ext_inventory:need_ammo()
	local need_heal = self._ext_damage:need_healing()

	if perseverance_active or not need_ammo and not need_heal then
		return
	end

	local pickups = World:find_units_quick("sphere", self._unit:movement():m_pos(), self._pickup_area, self._slotmask_pickups)

	for _, pickup in ipairs(pickups) do
		if pickup:pickup().get_automatic_pickup and pickup:pickup():get_automatic_pickup() then
			local pickup_type = pickup:pickup():get_pickup_type()

			if pickup_type then
				if need_ammo and pickup_type == "ammo" then
					pickup:pickup():pickup(self._unit)
				elseif need_heal and pickup_type == "health" then
					pickup:pickup():pickup(self._unit)
				end
			end
		end
	end
end

function PlayerStandard:update_check_actions_paused(t, dt)
	self:_update_check_actions(Application:time(), 0.1)
end

function PlayerStandard:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.projectiles[projectile_entry].is_a_grenade then
		self:_update_throw_grenade_timers(t, dt, input)
	else
		self:_update_throw_projectile_timers(t, input)
	end

	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_charging_weapon_timers(t, input)
	self:_update_use_item_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_mantle_timers(t, dt)
	self:_update_zipline_timers(t, dt)

	if self._change_item_expire_t and self._change_item_expire_t <= t then
		self._change_item_expire_t = nil
	end

	if self._change_weapon_pressed_expire_t and self._change_weapon_pressed_expire_t <= t then
		self._change_weapon_pressed_expire_t = nil
	end

	self:_update_steelsight_timers(t, dt)
	self:_update_foley(t, input)

	local new_action = nil
	local anim_data = self._ext_anim
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	new_action = new_action or self:_check_action_primary_attack(t, input)

	if not new_action then
		self:_check_action_next_weapon(t, input)
		self:_check_action_previous_weapon(t, input)
	end

	new_action = new_action or self:_check_action_equip(t, input)
	new_action = new_action or self:_check_use_item(t, input)

	if not new_action then
		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.projectiles[projectile_entry].is_a_grenade then
			new_action = self:_check_action_throw_grenade(t, input)
		else
			new_action = self:_check_action_throw_projectile(t, input)
		end
	end

	new_action = new_action or self:_check_action_interact(t, input)

	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)
	self:_check_action_deploy_bipod(t, input)
	self:_check_comm_wheel(t, input)
	self:_check_action_warcry(t, input)
	self:_check_stats_screen(t, dt, input)
	self:_check_fullscreen_switch(t, dt, input)
	self:_check_action_duck(t, input)
	self:_check_action_steelsight(t, input)
end

local mvec_pos_new = Vector3()
local mvec_achieved_walk_vel = Vector3()
local mvec_move_dir_normalized = Vector3()

function PlayerStandard:_update_movement(t, dt)
	local anim_data = self._unit:anim_data()
	local pos_new = nil
	self._target_headbob = self._target_headbob or 0
	self._headbob = self._headbob or 0

	if self._state_data.on_zipline and self._state_data.zipline_data.position then
		local speed = mvector3.length(self._state_data.zipline_data.position - self._pos) / dt / 500
		pos_new = mvec_pos_new

		mvector3.set(pos_new, self._state_data.zipline_data.position)

		if self._state_data.zipline_data.camera_shake then
			self._ext_camera:shaker():set_parameter(self._state_data.zipline_data.camera_shake, "amplitude", speed)
		end

		if alive(self._state_data.zipline_data.zipline_unit) then
			local dot = mvector3.dot(self._ext_camera:rotation():x(), self._state_data.zipline_data.zipline_unit:zipline():current_direction())

			self._ext_camera:camera_unit():base():set_target_tilt(dot * 10 * speed)
		end

		self._target_headbob = 0
	elseif self._state_data.mantling and self._state_data.mantle_data.position then
		pos_new = mvec_pos_new

		mvector3.set(pos_new, self._state_data.mantle_data.position)
	elseif self._move_dir then
		local enter_moving = not self:moving()
		self._moving = true

		if enter_moving then
			self._last_sent_pos_t = t
		end

		local WALK_SPEED_MAX = self:_get_max_walk_speed(t)

		mvector3.set(mvec_move_dir_normalized, self._move_dir)
		mvector3.normalize(mvec_move_dir_normalized)

		local wanted_walk_speed = WALK_SPEED_MAX * math.min(1, self._move_dir:length())
		local acceleration = self:in_air() and 700 or self._running and 5000 or 3000
		local achieved_walk_vel = mvec_achieved_walk_vel

		if self._jump_vel_xy and self:in_air() and mvector3.dot(self._jump_vel_xy, self._last_velocity_xy) > 0 then
			local input_move_vec = wanted_walk_speed * self._move_dir
			local jump_dir = mvector3.copy(self._last_velocity_xy)
			local jump_vel = mvector3.normalize(jump_dir)
			local fwd_dot = jump_dir:dot(input_move_vec)

			if fwd_dot < jump_vel then
				local sustain_dot = (input_move_vec:normalized() * jump_vel):dot(jump_dir)
				local new_move_vec = input_move_vec + jump_dir * (sustain_dot - fwd_dot)

				mvector3.step(achieved_walk_vel, self._last_velocity_xy, new_move_vec, 700 * dt)
			else
				mvector3.multiply(mvec_move_dir_normalized, wanted_walk_speed)
				mvector3.step(achieved_walk_vel, self._last_velocity_xy, wanted_walk_speed * self._move_dir:normalized(), acceleration * dt)
			end

			local fwd_component = nil
		else
			mvector3.multiply(mvec_move_dir_normalized, wanted_walk_speed)
			mvector3.step(achieved_walk_vel, self._last_velocity_xy, mvec_move_dir_normalized, acceleration * dt)
		end

		if mvector3.is_zero(self._last_velocity_xy) then
			mvector3.set_length(achieved_walk_vel, math.max(achieved_walk_vel:length(), 100))
		end

		pos_new = mvec_pos_new

		mvector3.set(pos_new, achieved_walk_vel)
		mvector3.multiply(pos_new, dt)
		mvector3.add(pos_new, self._pos)

		self._target_headbob = self:_get_walk_headbob()
		self._target_headbob = self._target_headbob * self._move_dir:normalized():length()
	elseif not mvector3.is_zero(self._last_velocity_xy) then
		local decceleration = self:in_air() and 250 or math.lerp(2000, 1500, math.min(self._last_velocity_xy:length() / self._tweak_data.movement.speed.RUNNING_SPEED, 1))
		local achieved_walk_vel = math.step(self._last_velocity_xy, Vector3(), decceleration * dt)
		pos_new = mvec_pos_new

		mvector3.set(pos_new, achieved_walk_vel)
		mvector3.multiply(pos_new, dt)
		mvector3.add(pos_new, self._pos)

		self._target_headbob = 0
	elseif self:moving() then
		self._target_headbob = 0
		self._moving = false
	end

	if self._headbob ~= self._target_headbob then
		self._headbob = math.step(self._headbob, self._target_headbob, dt / 4)

		self._ext_camera:set_shaker_parameter("headbob", "amplitude", self._headbob)
	end

	if pos_new then
		self._unit:movement():set_position(pos_new)
		mvector3.set(self._last_velocity_xy, pos_new)
		mvector3.subtract(self._last_velocity_xy, self._pos)

		if not self._state_data.on_ladder and not self._state_data.on_zipline then
			mvector3.set_z(self._last_velocity_xy, 0)
		end

		mvector3.divide(self._last_velocity_xy, dt)
	else
		mvector3.set_static(self._last_velocity_xy, 0, 0, 0)
	end

	local cur_pos = pos_new or self._pos

	self:_update_network_jump(cur_pos, false)

	local move_dis = mvector3.distance_sq(cur_pos, self._last_sent_pos)

	if self:is_network_move_allowed() and (move_dis > 22500 or move_dis > 400 and (t - self._last_sent_pos_t > 1.5 or not pos_new)) then
		self._ext_network:send("action_walk_nav_point", cur_pos)
		mvector3.set(self._last_sent_pos, cur_pos)

		self._last_sent_pos_t = t
	end
end

function PlayerStandard:is_network_move_allowed()
	return not self:_on_zipline() and not self._is_jumping
end

function PlayerStandard:_get_walk_headbob()
	if not managers.user:get_setting("use_headbob") then
		return 0
	elseif self._state_data.using_bipod then
		return 0
	elseif self._state_data.in_steelsight then
		return 0
	elseif self:in_air() then
		return 0
	elseif self._state_data.ducking then
		return 0.0125
	elseif self._running then
		return 0.1 * (self._run_and_shoot and 0.5 or 1)
	end

	return 0.025
end

function PlayerStandard:_update_foley(t, input)
	if self._state_data.on_zipline or self._state_data.mantling then
		return
	end

	if not self._gnd_ray and not self._state_data.on_ladder then
		if not self:in_air() then
			self._state_data.in_air = true
			self._state_data.enter_air_pos_z = self._pos.z

			self:_interupt_action_running(t)
			self._unit:set_driving("orientation_object")
		end
	elseif self:in_air() then
		self._unit:set_driving("script")

		self._state_data.in_air = false
		local from = self._pos + math.UP * 10
		local to = self._pos - math.UP * 60
		local material_name, pos, norm = World:pick_decal_material(from, to, self._slotmask_bullet_impact_targets)

		self._unit:sound():play_land(material_name, pos and pos - Vector3(0, 0, 45))

		local fall_data = self._state_data.dive_data or {}
		fall_data.height = self._state_data.enter_air_pos_z - self._pos.z
		fall_data.onto_ladder = self:on_ladder()
		local damage_taken = self._unit:character_damage():damage_fall(fall_data)

		if damage_taken then
			self._running_wanted = false

			managers.rumble:play("hard_land")
			self._ext_camera:play_shaker("player_fall_damage")

			if not self._setting_hold_to_duck then
				self:_start_action_ducking(t)
			end
		elseif input.btn_run_state then
			self._running_wanted = true
		end

		if self:_is_diving() then
			if damage_taken then
				self._unit:sound():play("high_dive_heavy_land", nil, true)

				local ray = World:raycast("ray", from, to, "slot_mask", self._slotmask_bullet_impact_targets)

				if ray then
					World:project_decal(tweak_data.upgrades.high_dive_land_decal, ray.position, ray.ray, ray.unit, nil, ray.normal)
				end
			else
				self._unit:sound():play("high_dive_land", nil, true)
				self._ext_camera:play_shaker("player_fall_damage", 0.3)
			end

			local world_effect = World:effect_manager():spawn({
				effect = tweak_data.upgrades.high_dive_land_effect,
				position = self._pos + math.UP,
				rotation = self._unit:rotation()
			})

			if fall_data.knockdown and not managers.player:has_activate_temporary_upgrade("temporary", "high_dive_enemy_knockdown") then
				local units = World:find_units_quick("sphere", self._m_pos, tweak_data.upgrades.high_dive_knockdown_range, self._slotmask_enemies)
				local success = false

				for e_key, unit in pairs(units) do
					if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
						local direction = unit:position() - self._m_pos

						if CopDamage.skill_action_knockdown(unit, self._m_pos, direction, "expl_hurt") then
							managers.network:session():send_to_peers_synched("skill_action_knockdown", unit, self._m_pos, direction, "expl_hurt")

							success = true
						end
					end
				end

				if success then
					managers.player:activate_temporary_upgrade("temporary", "high_dive_enemy_knockdown")
				end
			end
		end

		self:_interupt_action_diving()

		self._jump_t = nil
		self._jump_vel_xy = nil

		self._ext_camera:play_shaker("player_land", 0.5)
		managers.rumble:play("land")
	elseif self._jump_vel_xy and t - self._jump_t > 0.3 then
		self._jump_vel_xy = nil

		if input.btn_run_state then
			self._running_wanted = true
		end
	end

	self:_check_step(t)
end

function PlayerStandard:_check_step(t)
	if self:in_air() then
		return
	end

	self._last_step_pos = self._last_step_pos or Vector3()
	local step_length = self._state_data.on_ladder and 50 or self._state_data.in_steelsight and 100 or self._state_data.ducking and 125 or self._running and 175 or 150

	if mvector3.distance_sq(self._last_step_pos, self._pos) > step_length * step_length then
		mvector3.set(self._last_step_pos, self._pos)
		self._unit:base():anim_data_clbk_footstep()
	end
end

function PlayerStandard:_update_aim_speed(t, dt)
	if not self._previous_aim_direction then
		self._previous_aim_direction = mvector3.copy(self._ext_camera:forward())

		return
	end

	local aim_direction = mvector3.copy(self._ext_camera:forward())
	self._aim_speed = mvector3.angle(aim_direction, self._previous_aim_direction) / dt
	self._previous_aim_direction = mvector3.copy(aim_direction)
end

function PlayerStandard:_update_check_sweep_aim_assist(t, dt)
	if not alive(self._equipped_unit) or not self._equipped_unit:base().can_use_aim_assist then
		self:reset_aim_assist_look_multiplier()

		return
	end

	local closest_ray = self._equipped_unit:base():check_autoaim(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), 200000, true)

	if closest_ray then
		self._camera_unit:base():calculate_aim_assist_look_multiplier(closest_ray)

		self._aim_locked = true
	else
		self:reset_aim_assist_look_multiplier()
	end
end

function PlayerStandard:reset_aim_assist_look_multiplier()
	self._camera_unit:base():reset_aim_assist()

	self._aim_locked = false
end

function PlayerStandard:_update_crosshair_offset()
	if not alive(self._equipped_unit) then
		return
	end

	if self:running() and not self._run_and_shoot or self._unequip_weapon_expire_t or self:_interacting() then
		managers.hud:set_crosshair_fade(false)

		return
	end

	local name_id = self._equipped_unit:base():get_name_id()

	if not tweak_data.weapon[name_id] then
		managers.hud:set_crosshair_visible(false)

		return
	end

	local crosshair_data = tweak_data.weapon[name_id].crosshair

	if not crosshair_data then
		managers.hud:set_crosshair_visible(false)

		return
	else
		managers.hud:set_crosshair_visible(true)
	end

	local stance = nil

	if self._state_data.in_steelsight then
		stance = "steelsight"
	elseif self._state_data.ducking then
		stance = "crouching"
	else
		stance = "standing"
	end

	if crosshair_data[stance].hidden then
		managers.hud:set_crosshair_fade(false)
		managers.hud:set_crosshair_offset(0)
	else
		managers.hud:set_crosshair_fade(true)

		local moving = self:moving() or self:in_air()
		local offset = crosshair_data[stance][moving and "moving_offset" or "offset"]

		if self._equipped_unit:base()._get_spread then
			managers.hud:set_crosshair_offset(offset * self._equipped_unit:base():_get_spread(self._unit))
		else
			managers.hud:set_crosshair_offset(offset)
		end
	end
end

function PlayerStandard:_stance_entered(unequipped)
	if not alive(self._equipped_unit) then
		return
	end

	local stance_standard = tweak_data.player.stances.default[managers.player:current_state()] or tweak_data.player.stances.default.standard
	local head_stance = self._state_data.ducking and tweak_data.player.stances.default.crouched.head or stance_standard.head
	local stance_id = nil
	local stance_mod = {
		translation = Vector3(0, 0, 0)
	}

	if not unequipped then
		stance_id = self._equipped_unit:base():get_stance_id()

		if self._state_data.in_steelsight and self._equipped_unit:base().stance_mod then
			stance_mod = self._equipped_unit:base():stance_mod() or stance_mod
		end
	end

	local stances = nil
	stances = (not self:_is_meleeing() and not self:_is_throwing_projectile() or tweak_data.player.stances.default) and (not self:_is_carrying_corpse() or tweak_data.player.stances.carrying) and (tweak_data.player.stances[stance_id] or tweak_data.player.stances.default)
	local misc_attribs = self:_get_modified_stances(stances)
	local new_fov = self:get_zoom_fov(misc_attribs)
	local duration = stance_standard.transition_duration or tweak_data.player.TRANSITION_DURATION
	duration = duration + (self._equipped_unit:base():transition_duration() or 0)
	local duration_multiplier = self._state_data.in_steelsight and 1 / self._equipped_unit:base():enter_steelsight_speed_multiplier() or 1

	self._camera_unit:base():clbk_stance_entered(misc_attribs.shoulders, head_stance, misc_attribs.vel_overshot, new_fov, misc_attribs.shakers, stance_mod, duration_multiplier, duration)
	managers.menu:set_mouse_sensitivity(self:in_steelsight())

	local sensitivity_multiplier = self:get_sensitivity_multiplier(new_fov)

	self._camera_unit:base():set_sensitivity_multiplier(sensitivity_multiplier)
end

function PlayerStandard:_get_modified_stances(stances)
	local misc_attribs = nil

	if self:_is_using_bipod() and not self:_is_throwing_projectile() then
		misc_attribs = deep_clone(stances.bipod)
	elseif self:in_steelsight() then
		misc_attribs = deep_clone(stances.steelsight)
		local multiplier = managers.player:upgrade_value("player", "steadiness_weapon_sway_decrease", 1)
		misc_attribs.shakers.breathing.amplitude = misc_attribs.shakers.breathing.amplitude * multiplier
	else
		local stance = self:ducking() and stances.crouched or stances.standard
		misc_attribs = deep_clone(stance)
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_DOOMS_DAY) then
		local ads_shoulders_t = stances.steelsight.shoulders.translation
		misc_attribs.shoulders.translation = Vector3(ads_shoulders_t.x, ads_shoulders_t.y, misc_attribs.shoulders.translation.z - 3)
	end

	if not self:in_steelsight() then
		local multiplier = managers.user:get_setting("fov_multiplier") - 1.35
		local offset = tweak_data.player.STANCE_FOV_OFFSET_MAX * multiplier
		misc_attribs.shoulders.translation = Vector3(misc_attribs.shoulders.translation.x + offset.x, misc_attribs.shoulders.translation.y + offset.y, misc_attribs.shoulders.translation.z + offset.z)
	else
		local fov_multiplier = managers.player:upgrade_value("player", "farsighted_steelsight_fov_multiplier", false)

		if fov_multiplier and self._equipped_unit:base().has_scope and self._equipped_unit:base():has_scope() then
			misc_attribs.shoulders.translation = Vector3(misc_attribs.shoulders.translation.x, misc_attribs.shoulders.translation.y + 2 * fov_multiplier, misc_attribs.shoulders.translation.z)
		end
	end

	return misc_attribs
end

function PlayerStandard:_get_weapon_lens_distortion()
	local weapon = self._equipped_unit:base()

	if weapon then
		return weapon:stance_mod().lens_distortion
	end

	return managers.environment_controller:get_lens_distortion_value()
end

function PlayerStandard:update_fov_external()
	if not alive(self._equipped_unit) then
		return
	end

	local stance_id = self._equipped_unit:base():get_stance_id()
	local stances = tweak_data.player.stances[stance_id] or tweak_data.player.stances.default
	local misc_attribs = self:_get_modified_stances(stances)
	local new_fov = self:get_zoom_fov(misc_attribs)

	self._camera_unit:base():set_fov_instant(new_fov)

	local tid = "PlayerStandard.update_fov_external"

	if managers.queued_tasks:has_task(tid) then
		managers.queued_tasks:delay_queued_task(tid, 0.02, true)
	else
		managers.queued_tasks:queue(tid, self._stance_entered, self, false, 1)
	end
end

function PlayerStandard:animate_fov_multiplier(multiplier, time)
	if not alive(self._equipped_unit) then
		return
	end

	local stance_id = self._equipped_unit:base():get_stance_id()
	local stances = tweak_data.player.stances[stance_id] or tweak_data.player.stances.default
	local misc_attribs = self:_get_modified_stances(stances)
	local new_fov = self:get_zoom_fov(misc_attribs) * multiplier

	self._camera_unit:base():animate_fov(new_fov, time)
end

function PlayerStandard:_get_max_walk_speed(t)
	local speed_tweak = self._tweak_data.movement.speed
	local movement_speed = speed_tweak.WALKING_SPEED
	local speed_state = "walk"
	local is_climbing = self:on_ladder()
	local is_crouching = self._state_data.ducking
	local is_running = self._running
	local in_steelsight = self._state_data.in_steelsight

	if in_steelsight and not managers.player:has_category_upgrade("player", "focus_steelsight_normal_movement_speed") then
		movement_speed = speed_tweak.STEELSIGHT_SPEED
		speed_state = "steelsight"
	elseif is_climbing then
		movement_speed = speed_tweak.CLIMBING_SPEED
		speed_state = "climb"
	elseif is_crouching then
		movement_speed = speed_tweak.CROUCHING_SPEED
		speed_state = "crouch"
	elseif self:in_air() then
		movement_speed = speed_tweak.AIR_SPEED
		speed_state = nil
	elseif is_running then
		movement_speed = speed_tweak.RUNNING_SPEED
		speed_state = "run"
	end

	local health_ratio = self._ext_damage:health_ratio()
	local multiplier = managers.player:movement_speed_multiplier(is_running, is_climbing, is_crouching, in_steelsight, health_ratio)
	local apply_weapon_penalty = true

	if self:_is_meleeing() then
		local melee_entry = self:_get_melee_weapon()
		apply_weapon_penalty = not tweak_data.blackmarket.melee_weapons[melee_entry].stats.remove_weapon_movement_penalty
	end

	if alive(self._equipped_unit) and apply_weapon_penalty then
		multiplier = multiplier * self._equipped_unit:base():movement_penalty()
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_MOVEMENT_SPEED) then
		multiplier = multiplier * (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_PLAYER_MOVEMENT_SPEED) or 1)
	end

	return movement_speed * multiplier
end

function PlayerStandard:_start_action_steelsight(t)
	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CANNOT_ADS) then
		self._steelsight_wanted = false
		self._state_data.in_steelsight = false

		return
	end

	if self:_changing_weapon() or self:_is_reloading() or self:_interacting() or self:_is_meleeing() or self._use_item_expire_t or self:_is_throwing_projectile() or self:_on_zipline() or self:_mantling() then
		self._steelsight_wanted = true

		return
	end

	if self._running and not self._end_running_expire_t then
		self:_interupt_action_running(t)

		self._steelsight_wanted = true

		return
	end

	self:_break_intimidate_redirect(t)

	self._steelsight_wanted = false
	self._state_data.in_steelsight = true

	self:_stance_entered()
	self:_interupt_action_running(t)
	self:_interupt_action_cash_inspect(t)

	local weap_base = self._equipped_unit:base()

	if weap_base.play_tweak_data_sound then
		weap_base:play_tweak_data_sound("enter_steelsight")
	end

	if weap_base:weapon_tweak_data().animations.recoil_steelsight_weight then
		self:_need_to_play_idle_redirect()

		self._state_data.steelsight_weight_target = 1

		self._camera_unit:base():set_steelsight_anim_enabled(true)
	end

	local current_state_name = self._camera_unit:anim_state_machine():segment_state(self.IDS_BASE)

	if current_state_name == self.IDS_STOP_RUNNING_STATE then
		self._ext_camera:play_redirect(self.IDS_IDLE)
	end

	self._state_data.reticle_obj = weap_base.get_reticle_obj and weap_base:get_reticle_obj()

	if managers.controller:get_default_wrapper_type() ~= "pc" and managers.user:get_setting("aim_assist") or managers.player:upgrade_value("player", "warcry_aim_assist", false) == true then
		if self._equipped_unit:base().check_autoaim then
			local closest_ray = self._equipped_unit:base():check_autoaim(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), nil, true)

			self._camera_unit:base():clbk_aim_assist(closest_ray)
		else
			Application:warn("[PlayerStandard:_start_action_steelsight] check_autoaim method missing for", self._equipped_unit:base():get_name_id())
		end
	end

	self._ext_network:send("set_stance", 3, false, false)

	if managers.hud:is_motion_dot_ads_fade() then
		managers.hud:fade_out_motion_dot()
	end
end

function PlayerStandard:_end_action_steelsight(t)
	if not managers.warcry:active() or not managers.warcry:get_active_warcry():distorts_lense() then
		managers.environment_controller:reset_lens_distortion_value()
	end

	self._state_data.in_steelsight = false
	self._state_data.reticle_obj = nil

	self:_stance_entered()
	self._camera_unit:base():clbk_stop_aim_assist()

	local weap_base = self._equipped_unit:base()

	if weap_base.play_tweak_data_sound then
		weap_base:play_tweak_data_sound("leave_steelsight")
	end

	if weap_base.weapon_tweak_data and weap_base:weapon_tweak_data().animations.recoil_steelsight_weight then
		self:_need_to_play_idle_redirect()

		self._state_data.steelsight_weight_target = 0

		self._camera_unit:base():set_steelsight_anim_enabled(true)
	end

	self._ext_network:send("set_stance", 2, false, false)

	if managers.hud:is_motion_dot_ads_fade() then
		managers.hud:fade_in_motion_dot()
	end
end

function PlayerStandard:_need_to_play_idle_redirect()
	if not self._camera_unit:base():anims_enabled() or self._camera_unit:base():playing_empty_state() then
		self._ext_camera:play_redirect(self.IDS_IDLE)
	end
end

function PlayerStandard:_interupt_action_steelsight(t)
	self._steelsight_wanted = false

	if self._state_data.in_steelsight then
		self:_end_action_steelsight(t)
	end
end

function PlayerStandard:_update_steelsight_timers(t, dt)
	if self._state_data.steelsight_weight_target then
		self._state_data.steelsight_weight = self._state_data.steelsight_weight or 0
		self._state_data.steelsight_weight = math.step(self._state_data.steelsight_weight, self._state_data.steelsight_weight_target, dt * 5)

		self._camera_unit:anim_state_machine():set_global("steelsight_weight", self._state_data.steelsight_weight)

		if self._state_data.steelsight_weight == self._state_data.steelsight_weight_target then
			self._camera_unit:base():set_steelsight_anim_enabled(false)

			self._state_data.steelsight_weight_target = nil
		end
	end
end

function PlayerStandard:_start_action_running(t)
	if not self._move_dir then
		self._running_wanted = true

		return
	end

	if self:on_ladder() or self:_on_zipline() then
		return
	end

	if self:_is_meleeing() and not self._melee_and_run then
		return
	end

	if self._shooting and not self._run_and_shoot or self._use_item_expire_t or self:in_air() or self:_is_throwing_projectile() or self:_is_charging_weapon() or self:_interacting() or self:_mantling() then
		self._running_wanted = true

		return
	end

	if self._state_data.ducking and not self:_can_stand() then
		self._running_wanted = true

		return
	end

	if not self:_can_run_directional() then
		return
	end

	self._running_wanted = false

	if managers.player:get_player_rule("no_run") then
		return
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CANNOT_SPRINT) then
		return
	end

	if not self._unit:movement():is_above_stamina_threshold() then
		return
	end

	if (not self._state_data.shake_player_start_running or not self._ext_camera:shaker():is_playing(self._state_data.shake_player_start_running)) and managers.user:get_setting("use_camera_accel") then
		self._state_data.shake_player_start_running = self._ext_camera:play_shaker("player_start_running", 0.75)
	end

	self:set_running(true)

	self._end_running_expire_t = nil
	self._start_running_t = t

	if (not self._run_and_reload or not self:_is_reloading()) and not self:_is_meleeing() and not self._delay_running_expire_t then
		self._ext_camera:play_redirect(self._run_and_shoot and self.IDS_IDLE or self.IDS_START_RUNNING)
	end

	if not self._run_and_reload then
		self:_interupt_action_reload(t)
	end

	self:_interupt_action_steelsight(t)
	self:_interupt_action_ducking(t)
end

function PlayerStandard:_interupt_action_running(t)
	if self._running and not self._end_running_expire_t then
		self:_end_action_running(t)
	end
end

function PlayerStandard:_end_action_running(t)
	if self._state_data.charging then
		return
	end

	if not self._end_running_expire_t then
		local speed_multiplier = self._equipped_unit:base():exit_run_speed_multiplier()
		local waiting_to_run = self._delay_running_expire_t ~= nil
		self._end_running_expire_t = t + 0.4 / speed_multiplier
		local play_animation = (not self._melee_and_run or not self:_is_meleeing()) and (not self._run_and_reload or not self:_is_reloading()) and not self._run_and_shoot

		if not waiting_to_run and play_animation then
			self._ext_camera:play_redirect(self.IDS_STOP_RUNNING, speed_multiplier)
		end
	end
end

function PlayerStandard:_start_action_ducking(t)
	if self:_on_zipline() or self:_mantling() then
		return
	end

	self:_interupt_action_running(t)

	self._state_data.ducking = true

	self:_stance_entered()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_DUCK, velocity)
	self._ext_network:send("set_pose", 2)

	if managers.user:get_setting("use_camera_accel") then
		self._ext_camera:play_shaker("player_crouch", self:in_steelsight() and 0.1)
	end

	if self._high_dive and self:in_air() then
		self:_check_action_diving()
	end

	self:_upd_attention()
end

function PlayerStandard:_end_action_ducking(t, skip_can_stand_check)
	if not skip_can_stand_check and not self:_can_stand() then
		managers.notification:add_notification({
			duration = 2,
			id = "hint_cant_stand_up",
			shelf_life = 5,
			text = managers.localization:text("hint_cant_stand_up")
		})

		return
	end

	self._state_data.ducking = false

	self:_stance_entered()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self:_activate_mover(PlayerStandard.MOVER_STAND, velocity)
	self._ext_network:send("set_pose", 1)

	if managers.user:get_setting("use_camera_accel") then
		self._ext_camera:play_shaker("player_crouch", self:in_steelsight() and -0.1 or -1)
	end

	self:_upd_attention()
end

function PlayerStandard:_interupt_action_ducking(t, skip_can_stand_check)
	if self._state_data.ducking then
		self:_end_action_ducking(t, skip_can_stand_check)
	end
end

function PlayerStandard:_check_action_diving()
	if not self._ext_movement:is_above_stamina_threshold() then
		return
	end

	local hips_pos = self._pos
	local down_pos = tmp_ground_to_vec
	local down_offset_vec = math.DOWN * 120

	mvector3.set(down_pos, hips_pos)
	mvector3.add(down_pos, down_offset_vec)

	local down_ray = World:raycast("ray", hips_pos, down_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 20, "report")

	if not down_ray then
		local gravity_mul = managers.player:upgrade_value("player", "high_dive_gravity_multiplier", 1)

		self:set_gravity(tweak_data.player.gravity * gravity_mul)

		self._state_data.diving = true
		self._state_data.dive_data = managers.player:upgrade_value("player", "high_dive_ground_slam", {})
		self._state_data.dive_data.knockdown = managers.player:has_category_upgrade("temporary", "high_dive_enemy_knockdown")
	end
end

function PlayerStandard:_interupt_action_diving(t)
	if self:_is_diving() then
		self:_end_action_diving(t)
	end
end

function PlayerStandard:_end_action_diving()
	self._state_data.diving = nil
	self._state_data.dive_data = nil

	if not self._state_data.on_ladder then
		self:set_gravity(tweak_data.player.gravity)
	end
end

function PlayerStandard:_is_diving()
	return self:ducking() and self._state_data.diving
end

function PlayerStandard:_can_stand(ignored_bodies)
	if self:_is_diving() then
		return false
	end

	local offset = 50
	local radius = 30
	local hips_pos = self._obj_com:position() + math.UP * offset
	local up_pos = math.UP * (160 - offset)

	mvector3.add(up_pos, hips_pos)

	local ray_table = {
		"ray",
		hips_pos,
		up_pos,
		"slot_mask",
		self._slotmask_gnd_ray,
		"ray_type",
		"body mover",
		"sphere_cast_radius",
		radius,
		"bundle",
		20
	}

	if ignored_bodies then
		table.insert(ray_table, "ignore_body")
		table.insert(ray_table, ignored_bodies)
	end

	local ray = World:raycast(unpack(ray_table))

	if ray then
		if alive(ray.body) and not ray.body:collides_with_mover() then
			ignored_bodies = ignored_bodies or {}

			table.insert(ignored_bodies, ray.body)

			return self:_can_stand(ignored_bodies)
		end

		return false
	end

	return true
end

function PlayerStandard:_can_run_directional()
	if self._can_free_run then
		return true
	end

	local can_run = mvector3.angle(self._stick_move, math.Y) <= 50

	return can_run
end

function PlayerStandard:_start_action_equip(redirect, extra_time, skip_timer)
	local redirect = redirect or self.IDS_EQUIP
	extra_time = extra_time or 0
	local speed_multiplier = self:_get_swap_speed_multiplier()
	local weapon_tweak = self._equipped_unit:base():weapon_tweak_data()
	local equip_timer = (weapon_tweak.timers.equip or 0.7) / speed_multiplier

	if not skip_timer then
		self._equip_weapon_expire_t = managers.player:player_timer():time() + equip_timer + extra_time
	end

	if redirect == self.IDS_EQUIP then
		self._equipped_unit:base():tweak_data_anim_stop("unequip")
		self._equipped_unit:base():tweak_data_anim_play("equip", speed_multiplier)
	end

	local result = self._ext_camera:play_redirect(redirect, speed_multiplier)
end

function PlayerStandard:_check_action_throw_projectile(t, input)
	if not managers.player:can_throw_grenade() then
		self._state_data.projectile_throw_wanted = nil
		self._state_data.projectile_idle_wanted = nil

		return
	end

	if self._state_data.projectile_throw_wanted then
		if not self._state_data.projectile_throw_allowed_t then
			self._state_data.projectile_throw_wanted = nil

			self:_do_action_throw_projectile(t, input)
		end

		return
	end

	local action_wanted = input.btn_projectile_press or input.btn_projectile_release or self._state_data.projectile_idle_wanted

	if not action_wanted then
		return
	end

	if input.btn_projectile_release then
		if self._state_data.throwing_projectile then
			if self._state_data.projectile_throw_allowed_t then
				self._state_data.projectile_throw_wanted = true

				return
			end

			self:_do_action_throw_projectile(t, input)
		end

		return
	end

	local action_forbidden = not PlayerBase.USE_GRENADES or not self:_projectile_repeat_allowed() or self:chk_action_forbidden("interact") or self:_interacting() or self:is_deploying() or self:_changing_weapon() or self:_is_meleeing() or self:_is_using_bipod() or self:_is_comm_wheel_active() or self:_mantling()

	if action_forbidden then
		return
	end

	self:_start_action_throw_projectile(t, input)

	return true
end

function PlayerStandard:interupt_all_actions()
	local t = TimerManager:game():time()

	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)
	self:_interupt_action_interact(t)
	self:_interupt_action_ladder(t)
	self:_interupt_action_melee(t)
	self:_interupt_action_throw_grenade(t)
	self:_interupt_action_throw_projectile(t)
	self:_interupt_action_use_item(t)
	self:_interupt_action_cash_inspect(t)
	self:_interupt_action_mantle(t)
	self:_interupt_action_diving(t)
	self:_check_stop_shooting()
end

function PlayerStandard:_start_action_throw_projectile(t, input)
	self._equipped_unit:base():tweak_data_anim_stop("fire")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	self._state_data.projectile_idle_wanted = nil
	self._state_data.throwing_projectile = true
	self._state_data.projectile_start_t = nil
	local projectile_entry = managers.blackmarket:equipped_projectile()

	self:_stance_entered()

	if self._state_data.projectile_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 0)
	end

	self._state_data.projectile_global_value = tweak_data.projectiles[projectile_entry].anim_global_param or "projectile_frag"

	self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 1)

	local current_state_name = self._camera_unit:anim_state_machine():segment_state(PlayerStandard.IDS_BASE)
	local throw_allowed_expire_t = tweak_data.projectiles[projectile_entry].throw_allowed_expire_t or 0.15
	self._state_data.projectile_throw_allowed_t = t + (current_state_name ~= PlayerStandard.IDS_PROJECTILE_THROW_STATE and throw_allowed_expire_t or 0)

	if current_state_name == PlayerStandard.IDS_PROJECTILE_THROW_STATE then
		self._ext_camera:play_redirect(PlayerStandard.IDS_PROJECTILE_IDLE)

		return
	end

	local offset = nil

	if current_state_name == PlayerStandard.IDS_PROJECTILE_EXIT_STATE then
		local segment_relative_time = self._camera_unit:anim_state_machine():segment_relative_time(PlayerStandard.IDS_BASE)
		offset = (1 - segment_relative_time) * 0.9
	end

	self._ext_camera:play_redirect(PlayerStandard.IDS_PROJECTILE_ENTER, nil, offset)
end

function PlayerStandard:_is_throwing_projectile()
	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.projectiles[projectile_entry].is_a_grenade then
		return self:_is_throwing_grenade()
	end

	return self._state_data.throwing_projectile or self._state_data.projectile_expire_t and true
end

function PlayerStandard:_is_carrying_corpse()
	return self._carrying_corpse
end

function PlayerStandard:in_throw_projectile()
	return self._state_data.throwing_projectile and true
end

function PlayerStandard:_projectile_repeat_allowed()
	return not self._camera_unit_anim_data.throwing and not self._state_data.throwing_projectile and not self._state_data.projectile_repeat_expire_t
end

function PlayerStandard:_do_action_throw_projectile(t, input, drop_projectile)
	local current_state_name = self._camera_unit:anim_state_machine():segment_state(PlayerStandard.IDS_BASE)
	self._state_data.throwing_projectile = nil
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_data = tweak_data.projectiles[projectile_entry]
	self._state_data.projectile_expire_t = t + projectile_data.expire_t
	self._state_data.projectile_repeat_expire_t = t + math.min(projectile_data.repeat_expire_t, projectile_data.expire_t)

	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, "throw_grenade")

	self._state_data.projectile_global_value = projectile_data.anim_global_param or "projectile_frag"

	self._camera_unit:anim_state_machine():set_global(self._state_data.projectile_global_value, 1)
	self._ext_camera:play_redirect(self.IDS_PROJECTILE_THROW)
	self:_stance_entered()
end

function PlayerStandard:_interupt_action_throw_projectile(t)
	if not self:_is_throwing_projectile() then
		return
	end

	self._state_data.projectile_idle_wanted = nil
	self._state_data.projectile_expire_t = nil
	self._state_data.projectile_throw_allowed_t = nil
	self._state_data.throwing_projectile = nil
	self._camera_unit_anim_data.throwing = nil

	self:_start_action_equip()
	self._camera_unit:base():unspawn_grenade()
	self._camera_unit:base():show_weapon()
	self:_stance_entered()
end

function PlayerStandard:_update_throw_projectile_timers(t, input)
	if self._state_data.throwing_projectile then
		-- Nothing
	end

	if self._state_data.projectile_throw_allowed_t and self._state_data.projectile_throw_allowed_t <= t then
		self._state_data.projectile_start_t = t
		self._state_data.projectile_throw_allowed_t = nil
		local projectile_entry = managers.blackmarket:equipped_projectile()
		local instant = tweak_data.projectiles[projectile_entry].instant

		if instant then
			self:_do_action_throw_projectile(t, input)

			return
		end
	end

	if self._state_data.projectile_repeat_expire_t and self._state_data.projectile_repeat_expire_t <= t then
		self._state_data.projectile_repeat_expire_t = nil

		if input.btn_projectile_state then
			local projectile_entry = managers.blackmarket:equipped_projectile()
			local instant_throw = tweak_data.projectiles[projectile_entry].instant
			self._state_data.projectile_idle_wanted = not instant_throw and true
		end
	end

	if self._state_data.projectile_expire_t and self._state_data.projectile_expire_t <= t then
		self._state_data.projectile_expire_t = nil
		self._state_data.projectile_repeat_expire_t = nil

		self:_stance_entered()

		if self._equipped_unit and input.btn_steelsight_state then
			self._steelsight_wanted = true
		end
	end
end

function PlayerStandard:_check_action_throw_grenade(t, input)
	if self._ext_inventory:equipped_selection() ~= PlayerInventory.SLOT_3 then
		return
	end

	local action_wanted = input.btn_primary_attack_press or input.btn_primary_attack_release
	local action_wanted_secondary = input.btn_steelsight_press or input.btn_steelsight_release

	if not action_wanted and not action_wanted_secondary then
		return
	end

	local action_forbidden = not PlayerBase.USE_GRENADES or self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_interacting() or self:is_deploying() or self:_changing_weapon() or self:_is_meleeing() or self:_is_using_bipod() or self:_mantling()

	if action_forbidden then
		return
	end

	self:_start_action_throw_grenade(t, input, action_wanted)

	return action_wanted or action_wanted_secondary
end

function PlayerStandard:_start_action_throw_grenade(t, input, primary)
	local press = input.btn_primary_attack_press or input.btn_steelsight_press
	local release = input.btn_primary_attack_release or input.btn_steelsight_release

	if press and managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ATTACK_ONLY_IN_AIR) and not self:in_air() then
		return
	end

	if self._state_data.throw_high and input.btn_steelsight_release then
		return
	end

	if not self._state_data.throw_high and input.btn_primary_attack_release then
		return
	end

	local equipped_grenade = managers.blackmarket:equipped_grenade()
	local grenade_insta_throw = tweak_data.projectiles[equipped_grenade].instant_throw

	if press and not self:_is_throwing_grenade() and managers.player:can_throw_grenade() then
		if self._state_data.throw_grenade_cooldown and t < self._state_data.throw_grenade_cooldown then
			return
		end

		local throw_high = input.btn_primary_attack_press and 1 or 0

		self:_interupt_action_reload(t)
		self:_interupt_action_steelsight(t)
		self:_interupt_action_running(t)
		self:_interupt_action_charging_weapon(t)
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, "throw_grenade_charge")

		local projectile_data = tweak_data.projectiles[equipped_grenade]

		self._camera_unit:anim_state_machine():set_global("throw_high", throw_high)
		self._camera_unit:anim_state_machine():set_global("throw_low", 1 - throw_high)

		self._state_data.throw_grenade_expire_t = projectile_data.expire_t or 1.1
		self._state_data.throw_high = input.btn_primary_attack_press

		if grenade_insta_throw then
			self._state_data.throw_grenade_cooldown = t + PlayerStandard.THROW_GRENADE_COOLDOWN_INSTANT

			managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, "throw_grenade")
			self._ext_camera:play_redirect(PlayerStandard.IDS_GRENADE_THROW_NOW)
		else
			projectile_data.context_rot_dir = input.btn_primary_attack_press and math.UP or math.X
			projectile_data.context_adjust_z = input.btn_primary_attack_press and 0 or -45
			self._state_data.throw_grenade_allowed_t = t + (projectile_data.throw_allowed_expire_t or 0.15)
			self._state_data.throw_grenade_cooldown = t + PlayerStandard.THROW_GRENADE_COOLDOWN
			local redirect_id = projectile_data.animations and projectile_data.animations.throw or PlayerStandard.IDS_GRENADE_THROW

			self._ext_camera:play_redirect(redirect_id)

			self._unit:equipment()._cooking_start = t

			self:_stance_entered()
		end
	end
end

function PlayerStandard:_update_throw_grenade_timers(t, dt, input)
	if self._state_data.throw_grenade_allowed_t and self._state_data.throw_grenade_allowed_t <= t then
		local attack_held = self._state_data.throw_high and input.btn_primary_attack_state or input.btn_steelsight_state

		if self._ext_camera:anim_data().throwing and not attack_held then
			self._state_data.throw_grenade_cooldown = t + PlayerStandard.THROW_GRENADE_COOLDOWN
			self._state_data.throw_grenade_allowed_t = nil

			managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, "throw_grenade")
			self._ext_camera:play_redirect(PlayerStandard.IDS_GRENADE_THROW_NOW)
		end
	end

	if self._state_data.throw_grenade_expire_t and not self._ext_camera:anim_data().throwing then
		self._state_data.throw_grenade_expire_t = self._state_data.throw_grenade_expire_t - dt

		if self._state_data.throw_grenade_expire_t <= 0 then
			self._state_data.throw_grenade_expire_t = nil
			self._state_data.throw_high = nil

			if not managers.player:can_throw_grenade() then
				self._ext_inventory:equip_not_empty(true)
				self:_start_action_equip()
			end

			self:_stance_entered()

			self._delay_running_expire_t = t + tweak_data.player.run_delay.equip

			if self._equipped_unit and input.btn_steelsight_state then
				self._steelsight_wanted = true
			end
		end
	end
end

function PlayerStandard:_interupt_action_throw_grenade(t, input)
	if not self:_is_throwing_grenade() then
		return
	end

	Application:debug("[PlayerStandard:_interupt_action_throw_grenade]")

	self._state_data.throw_grenade_expire_t = nil
	self._state_data.throw_grenade_cooldown = nil
	self._state_data.throw_grenade_allowed_t = nil
	self._state_data.throw_high = nil
	self._camera_unit_anim_data.throwing = nil
	self._unit:equipment()._cooking_start = nil

	self._camera_unit:base():show_weapon()
	self:_stance_entered()
end

function PlayerStandard:_is_throwing_grenade()
	return (self._camera_unit_anim_data.throwing or self._state_data.throw_grenade_expire_t) and true or false
end

function PlayerStandard:_check_action_interact(t, input)
	local new_action, timer, interact_object = nil
	local interaction_wanted = input.btn_interact_press

	if interaction_wanted then
		local action_forbidden = self:chk_action_forbidden("interact") or self._unit:base():stats_screen_visible() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self:_is_comm_wheel_active() or self:_mantling() or self._state_data.interaction_delay_t

		if not action_forbidden then
			new_action, timer, interact_object = managers.interaction:interact(self._unit)

			Application:debug("[PlayerStandard:_check_action_interact] interact", new_action, timer, interact_object)

			if timer then
				Application:debug("[PlayerStandard:_check_action_interact]", timer)

				new_action = true

				self._ext_camera:camera_unit():base():set_limits(80, 50)
				self:_start_action_interact(t, input, timer, interact_object)
			elseif new_action then
				self:_play_interact_redirect(t, interact_object)

				if alive(interact_object) then
					local interact_delay = interact_object:interaction():interact_delay_completed()
					self._state_data.interaction_delay_t = t + interact_delay
				end
			end

			new_action = new_action or self:_start_action_intimidate(t)
		end
	end

	if input.btn_interact_release then
		self:_interupt_action_interact(t, nil, nil, true)
	end

	return new_action
end

function PlayerStandard:_start_action_interact(t, input, timer, interact_object)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	self._interact_expire_t = t + timer
	self._interact_params = {
		object = interact_object,
		timer = timer,
		tweak_data = interact_object:interaction().tweak_data
	}
	local redirect = interact_object:interaction():interact_redirect()

	self._ext_camera:play_redirect(redirect or self.IDS_UNEQUIP)
	self._equipped_unit:base():tweak_data_anim_stop("equip")

	if not redirect then
		self._equipped_unit:base():tweak_data_anim_play("unequip")
	end

	managers.hud:show_interaction_bar(0, timer)
	managers.network:session():send_to_peers_synched("sync_teammate_start_progress", timer, interact_object)
end

function PlayerStandard:_interupt_action_interact(t, input, complete, show_interact_at_finish)
	if self._interact_expire_t then
		self._interact_expire_t = nil

		if alive(self._interact_params.object) then
			local interact_ext = self._interact_params.object:interaction()

			interact_ext:interact_interupt(self._unit, complete)

			local interact_delay = complete and interact_ext:interact_delay_completed() or interact_ext:interact_delay_interrupted()
			self._state_data.interaction_delay_t = t + interact_delay
		end

		self._ext_camera:camera_unit():base():remove_limits()
		managers.interaction:interupt_action_interact(self._unit)

		local sync_message = complete and "sync_teammate_complete_progress" or "sync_teammate_cancel_progress"

		managers.network:session():send_to_peers_synched(sync_message)

		self._interact_params = nil

		self:_start_action_equip(nil, nil, true)
		managers.hud:hide_interaction_bar(complete, show_interact_at_finish)
	end
end

function PlayerStandard:_end_action_interact(t)
	self:_interupt_action_interact(t, nil, true, true)
	managers.interaction:end_action_interact(self._unit)
end

function PlayerStandard:_interacting()
	return self._interact_expire_t or game_state_machine:current_state_name() == "ingame_special_interaction"
end

function PlayerStandard:interupt_interact()
	if self:_interacting() then
		local t = managers.player:player_timer():time()

		self:_interupt_action_interact(t, nil, nil, true)
		managers.interaction:interupt_action_interact()

		self._interact_expire_t = nil
	end
end

function PlayerStandard:_update_interaction_timers(t)
	if self._interact_expire_t then
		if not alive(self._interact_params.object) then
			self:_interupt_action_interact(t, nil, nil, true)
		elseif self._interact_params.object ~= managers.interaction:active_unit() then
			self:_interupt_action_interact(t, nil, nil, false)
		elseif self._interact_params.tweak_data ~= self._interact_params.object:interaction().tweak_data then
			self:_interupt_action_interact(t, nil, nil, true)
		elseif self._interact_params.object:interaction():check_interupt() then
			self:_interupt_action_interact(t, nil, nil, true)
		else
			managers.hud:set_interaction_bar_width(self._interact_params.timer - (self._interact_expire_t - t), self._interact_params.timer)

			if self._interact_expire_t <= t then
				self:_end_action_interact(t)

				self._interact_expire_t = nil
			end
		end
	end

	if self._state_data.interaction_delay_t and self._state_data.interaction_delay_t <= t then
		self._state_data.interaction_delay_t = nil
	end
end

function PlayerStandard:_check_action_weapon_firemode(t, input)
	if input.btn_weapon_firemode_press then
		if self._equipped_unit:base().can_toggle_firemode and self._equipped_unit:base():can_toggle_firemode() then
			self:_check_stop_shooting()
		end

		if self._equipped_unit:base().toggle_firemode and self._equipped_unit:base():toggle_firemode() then
			managers.hud:set_teammate_weapon_firemode(HUDManager.PLAYER_PANEL, self._unit:inventory():equipped_selection(), self._equipped_unit:base():fire_mode())
		end
	end
end

function PlayerStandard:_check_action_weapon_gadget(t, input)
	if input.btn_weapon_gadget_press and self._equipped_unit:base().toggle_gadget and self._equipped_unit:base():has_gadget() and self._equipped_unit:base():toggle_gadget() then
		if self._equipped_unit:base():gadget_toggle_requires_stance_update() then
			self:_stance_entered()
		end

		self._unit:network():send("set_weapon_gadget_state", self._equipped_unit:base()._gadget_on)
	end
end

function PlayerStandard:_check_action_melee(t, input)
	local melee_entry = self:_get_melee_weapon()
	local melee_tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
	local instant = melee_tweak.instant

	if self._state_data.melee_attack_wanted then
		if not self._state_data.melee_attack_allowed_t then
			self._state_data.melee_attack_wanted = nil

			self:_do_action_melee(t, input)
		end

		return
	end

	local action_wanted = nil

	if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_4 then
		action_wanted = input.btn_melee_state or input.btn_melee_release or input.btn_primary_attack_state or input.btn_primary_attack_release or self._state_data.melee_charge_wanted
	else
		action_wanted = input.btn_melee_press or input.btn_melee_release or self._state_data.melee_charge_wanted
	end

	if not action_wanted then
		return
	end

	if input.btn_melee_release or input.btn_primary_attack_release then
		if self._state_data.meleeing then
			if self._state_data.melee_attack_allowed_t then
				self._state_data.melee_attack_wanted = true

				return
			end

			self:_do_action_melee(t, input)
		end

		return
	end

	local action_forbidden = not self:_melee_repeat_allowed() or self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self:_is_throwing_projectile() or self:_is_using_bipod() or self:_is_comm_wheel_active() or self:shooting() or self:_mantling()

	if self._start_melee_t and t - self._start_melee_t > 0.18 and not instant then
		local current_state_name = self._camera_unit:anim_state_machine():segment_state(PlayerStandard.IDS_BASE)

		if current_state_name ~= PlayerStandard.IDS_MELEE_ATTACK_STATE and current_state_name ~= PlayerStandard.IDS_MELEE_CHARGE_STATE and current_state_name ~= PlayerStandard.IDS_MELEE_CHARGE_IDLE_STATE then
			local multiplier = managers.player:upgrade_value(UpgradesTweakData.UPG_CAT_PLAYER, "holdbarred_melee_charge_multiplier", 1)
			local anim_multiplier = 2 - multiplier

			self._ext_camera:play_redirect(PlayerStandard.IDS_MELEE_CHARGE, anim_multiplier)

			self._state_data.melee_max_charge_time = melee_tweak.stats.charge_time * multiplier
			self._melee_charge = true
		end
	end

	if action_forbidden then
		return
	end

	self:_start_action_melee(t, input, instant)

	return true
end

function PlayerStandard:_start_action_melee(t, input, instant)
	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ATTACK_ONLY_IN_AIR) and not self:in_air() then
		return
	end

	self._start_melee_t = t

	self._equipped_unit:base():tweak_data_anim_stop("fire")
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_charging_weapon(t)

	if not self._melee_and_run then
		self:_interupt_action_running(t)
	end

	self._state_data.melee_charge_wanted = nil
	self._state_data.melee_max_charge_time = nil
	self._state_data.melee_start_t = nil
	self._state_data.meleeing = true
	local melee_entry = self:_get_melee_weapon()
	local melee_tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local current_state_name = self._camera_unit:anim_state_machine():segment_state(PlayerStandard.IDS_BASE)

	if instant then
		self:_do_action_melee(t, input)

		return
	end

	self:_stance_entered()

	if self._state_data.melee_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 0)
	end

	self._state_data.melee_global_value = melee_tweak.anim_global_param

	if self._state_data.melee_global_value then
		self._camera_unit:anim_state_machine():set_global(self._state_data.melee_global_value, 1)
	end

	local multiplier = managers.player:upgrade_value(UpgradesTweakData.UPG_CAT_PLAYER, "do_die_melee_repeat_multiplier", 1)
	local attack_allowed_expire_t = melee_tweak.attack_allowed_expire_t or 0.15
	attack_allowed_expire_t = attack_allowed_expire_t * multiplier
	self._state_data.melee_attack_allowed_t = t + (current_state_name ~= PlayerStandard.IDS_MELEE_ATTACK_STATE and attack_allowed_expire_t or 0)
	local offset = nil

	if current_state_name == PlayerStandard.IDS_MELEE_EXIT_STATE then
		local segment_relative_time = self._camera_unit:anim_state_machine():segment_relative_time(PlayerStandard.IDS_BASE)
		offset = (1 - segment_relative_time) * 0.9
	end
end

function PlayerStandard:_is_meleeing()
	return self._state_data.meleeing or self._state_data.melee_expire_t and true
end

function PlayerStandard:in_melee()
	return self._state_data.meleeing and true
end

function PlayerStandard:discharge_melee()
	self:_do_action_melee(managers.player:player_timer():time(), nil, true)
end

function PlayerStandard:_melee_repeat_allowed()
	return not self._state_data.meleeing and not self._state_data.melee_repeat_expire_t
end

function PlayerStandard:_get_melee_charge_lerp_value(t, offset)
	if not self._state_data.melee_start_t or not self._state_data.melee_max_charge_time then
		return 0
	end

	local max_charge_time = self._state_data.melee_max_charge_time
	offset = offset or 0

	return math.clamp(t - self._state_data.melee_start_t - offset, 0, max_charge_time) / max_charge_time
end

local melee_vars = {
	"player_melee",
	"player_melee_var2"
}

function PlayerStandard:_do_action_melee(t, input, skip_damage)
	self._state_data.meleeing = nil
	local melee_entry = self:_get_melee_weapon()
	local melee_tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
	local instant_hit = melee_tweak.instant
	local speed_multiplier = managers.player:upgrade_value("player", "holdbarred_melee_speed_multiplier", 1)

	if not instant_hit then
		speed_multiplier = speed_multiplier * managers.player:temporary_upgrade_value("player", "do_die_melee_speed_multiplier", 1)
	end

	local animation_speed = 2 - speed_multiplier
	local melee_damage_delay = (melee_tweak.melee_damage_delay or 0) * speed_multiplier
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_melee = false
	self._state_data.melee_expire_t = t + melee_tweak.expire_t * speed_multiplier
	self._state_data.melee_repeat_expire_t = t + math.min(melee_tweak.repeat_expire_t, melee_tweak.expire_t) * speed_multiplier

	if not instant_hit and not skip_damage then
		self._state_data.melee_damage_delay_t = t + math.min(melee_damage_delay, melee_tweak.repeat_expire_t) * speed_multiplier
	end

	local send_redirect = "melee_husk"

	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, send_redirect)

	if self._state_data.melee_charge_shake then
		self._ext_camera:shaker():stop(self._state_data.melee_charge_shake)

		self._state_data.melee_charge_shake = nil
	end

	self._start_melee_t = nil

	if instant_hit then
		local col_ray = self:_melee_col_ray()
		local hit = skip_damage or col_ray

		if hit then
			self._ext_camera:play_redirect(bayonet_melee and self.IDS_MELEE_BAYONET or self.IDS_MELEE, animation_speed)
			managers.queued_tasks:queue(nil, self._do_melee_damage, self, {
				t,
				bayonet_melee,
				col_ray
			}, 0.22, nil)
		else
			self:_play_melee_sound(melee_entry, "hit_air")
			self._ext_camera:play_redirect(bayonet_melee and self.IDS_MELEE_MISS_BAYONET or self.IDS_MELEE_MISS, animation_speed)
		end
	else
		self:_play_melee_sound(melee_entry, "hit_air")

		if self._melee_charge then
			self._camera_unit:anim_state_machine():set_global("charge", 1)
		else
			self._camera_unit:anim_state_machine():set_global("charge", 0)
		end

		local state = self._ext_camera:play_redirect(PlayerStandard.IDS_MELEE_ATTACK, animation_speed)
		local anim_attack_vars = melee_tweak.anim_attack_vars

		if anim_attack_vars then
			self._camera_unit:anim_state_machine():set_parameter(state, anim_attack_vars[math.random(#anim_attack_vars)], 1)
		end
	end

	self._melee_charge = nil
end

function PlayerStandard:_melee_col_ray()
	local attempt = 1
	local col_ray = nil
	local melee_entry = self:_get_melee_weapon()
	local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * range

	while (not col_ray or not col_ray.unit:character_damage()) and attempt <= PlayerStandard.MELEE_RAY_ATTEMPTS do
		local sphere_cast_radius = 20 / PlayerStandard.MELEE_RAY_ATTEMPTS * attempt
		col_ray = self._unit:raycast("ray", from, to, "slot_mask", self._slotmask_bullet_impact_targets, "sphere_cast_radius", sphere_cast_radius, "ray_type", "body melee")
		attempt = attempt + 1
	end

	return col_ray
end

function PlayerStandard:_do_melee_damage(t, bayonet_melee, col_ray)
	if type(t) == "table" then
		col_ray = t[3]
		bayonet_melee = t[2]
		t = t[1]
	end

	local melee_entry = self:_get_melee_weapon()
	local melee_tweak = tweak_data.blackmarket.melee_weapons[melee_entry]
	local instant_hit = melee_tweak.instant
	local melee_damage_delay = melee_tweak.melee_damage_delay or 0
	local charge_lerp_value = instant_hit and 0 or self:_get_melee_charge_lerp_value(t, melee_damage_delay)

	self._ext_camera:play_shaker(melee_vars[math.random(#melee_vars)], math.max(0.3, charge_lerp_value))

	local sphere_cast_radius = 20
	local range = melee_tweak.stats.range or 175
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * range
	local material_name, pos, norm = World:pick_decal_material(from, to, self._slotmask_bullet_impact_targets)
	local material_string = managers.game_play_central:material_name(material_name)

	if col_ray and alive(col_ray.unit) then
		local is_melee_equipped = self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_4
		local damage, damage_effect = nil

		if is_melee_equipped then
			damage, damage_effect = managers.blackmarket:equipped_melee_weapon_damage_info(charge_lerp_value)
		else
			damage, damage_effect = self._equipped_unit:base():melee_damage_info()
		end

		local damage_effect_mul = math.max(managers.player:upgrade_value("player", "holdbarred_melee_knockdown_multiplier", 1), managers.player:upgrade_value(self._equipped_unit:base():weapon_tweak_data().category, "melee_knockdown_mul", 1))
		damage_effect = damage_effect * damage_effect_mul
		col_ray.sphere_cast_radius = sphere_cast_radius
		local hit_unit = col_ray.unit

		if hit_unit:character_damage() then
			if hit_unit:character_damage()._no_blood then
				self:_play_melee_sound(melee_entry, "hit_gen", material_string)
			elseif bayonet_melee then
				self._unit:sound():play("fairbairn_hit_body", nil, false)
			else
				self:_play_melee_sound(melee_entry, "hit_body")
			end

			if not hit_unit:character_damage()._no_blood then
				managers.game_play_central:play_impact_flesh({
					col_ray = col_ray
				})
				managers.game_play_central:play_impact_sound_and_effects({
					no_sound = true,
					no_decal = true,
					col_ray = col_ray
				})
			end
		else
			if bayonet_melee then
				self._unit:sound():play("knife_hit_gen", nil, false)
			else
				self:_play_melee_sound(melee_entry, "hit_gen", material_string)
			end

			local decal_effect = melee_tweak.decal_effect

			managers.game_play_central:play_impact_sound_and_effects({
				weapon_type = "knife",
				col_ray = col_ray,
				effect = tweak_data.common_effects.impact,
				no_decal = not decal_effect,
				decal = decal_effect
			})
		end

		if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
			col_ray.body:extension().damage:damage_melee(self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if hit_unit:id() ~= -1 then
				managers.network:session():send_to_peers_synched("sync_body_damage_melee", col_ray.body, self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
			end
		end

		managers.rumble:play("melee_hit")
		managers.game_play_central:physics_push(col_ray)

		if hit_unit:character_damage() and hit_unit:character_damage().damage_melee then
			local is_whisper_mode = managers.groupai:state():whisper_mode()
			local dmg_multiplier = 1

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_MELEE_DAMAGE_INCREASE) then
				local mp = managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_MELEE_DAMAGE_INCREASE) or 1
				dmg_multiplier = dmg_multiplier * mp
			end

			if self._state_data.marshal_data then
				local multiplier = managers.player:upgrade_value("player", "marshal_stacking_melee_damage", 1) - 1

				if multiplier > 0 then
					dmg_multiplier = dmg_multiplier * (1 + self._state_data.marshal_data.stacks * multiplier)

					self:_marshal_change_stacks(-self._state_data.marshal_data.stacks)
				end
			end

			local can_headshot = false

			if is_melee_equipped then
				dmg_multiplier = dmg_multiplier * managers.player:upgrade_value("player", "boxer_melee_damage_multiplier", 1)
				can_headshot = managers.player:upgrade_value("player", "boxer_melee_headshots", false)
			end

			local health_ratio = self._ext_damage:health_ratio()
			local special_weapon = melee_tweak.special_weapon
			local action_variant = special_weapon == "taser" and "taser_tased" or "melee"
			local stealth_knock = is_whisper_mode and hit_unit:character_damage():is_surprise_knockdown()
			local action_data = {
				variant = action_variant,
				name_id = melee_entry,
				damage = damage * dmg_multiplier,
				damage_effect = damage_effect,
				weapon_unit = self._equipped_unit,
				attacker_unit = self._unit,
				col_ray = col_ray,
				can_headshot = can_headshot,
				shield_knock = stealth_knock,
				charge_lerp_value = charge_lerp_value
			}
			local defense_data = hit_unit:character_damage():damage_melee(action_data)

			self:_check_melee_dot_damage(col_ray, defense_data, melee_entry)

			return defense_data
		end
	end

	return col_ray
end

function PlayerStandard:_check_melee_dot_damage(col_ray, defense_data, melee_entry)
	if not defense_data or defense_data.type == "death" then
		return
	end

	local dot_data = tweak_data.blackmarket.melee_weapons[melee_entry].dot_data

	if not dot_data then
		return
	end

	local data = managers.dot:create_dot_data(dot_data.type, dot_data.custom_data)
	local damage_class = CoreSerialize.string_to_classtable(data.damage_class)

	damage_class:start_dot_damage(col_ray, nil, data)
end

function PlayerStandard:_play_melee_sound(melee_entry, sound_id, material_string)
	local tweak_data = tweak_data.blackmarket.melee_weapons[melee_entry]

	self._unit:sound():play_melee(tweak_data.sounds and tweak_data.sounds[sound_id], material_string)
end

function PlayerStandard:_interupt_action_melee(t)
	if not self:_is_meleeing() then
		return
	end

	self._state_data.melee_charge_wanted = nil
	self._state_data.melee_expire_t = nil
	self._state_data.melee_repeat_expire_t = nil
	self._state_data.melee_attack_allowed_t = nil
	self._state_data.melee_damage_delay_t = nil
	self._state_data.melee_max_charge_time = nil
	self._state_data.melee_start_t = nil
	self._state_data.meleeing = nil

	self:_start_action_equip()
	self._camera_unit:base():show_weapon()

	if self._state_data.melee_charge_shake then
		self._ext_camera:stop_shaker(self._state_data.melee_charge_shake)

		self._state_data.melee_charge_shake = nil
	end

	self:_stance_entered()
end

function PlayerStandard:_update_melee_timers(t, input)
	if self._state_data.meleeing then
		local lerp_value = self:_get_melee_charge_lerp_value(t)

		if self._state_data.melee_charge_shake then
			self._ext_camera:shaker():set_parameter(self._state_data.melee_charge_shake, "amplitude", math.bezier({
				0,
				0,
				1,
				1
			}, lerp_value))
		end
	end

	if self._state_data.melee_damage_delay_t and self._state_data.melee_damage_delay_t <= t then
		self:_do_melee_damage(t, nil, self:_melee_col_ray())

		self._state_data.melee_damage_delay_t = nil
	end

	if self._state_data.melee_attack_allowed_t and self._state_data.melee_attack_allowed_t <= t then
		self._state_data.melee_start_t = t
		local melee_entry = self:_get_melee_weapon()
		local melee_charge_shaker = tweak_data.blackmarket.melee_weapons[melee_entry].melee_charge_shaker or "player_melee_charge"
		self._state_data.melee_charge_shake = self._ext_camera:play_shaker(melee_charge_shaker, 0)
		self._state_data.melee_attack_allowed_t = nil
	end

	if self._state_data.melee_repeat_expire_t and self._state_data.melee_repeat_expire_t <= t then
		self._state_data.melee_repeat_expire_t = nil

		if input.btn_melee_state then
			local melee_entry = self:_get_melee_weapon()
			local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
			self._state_data.melee_charge_wanted = not instant_hit and true
		end
	end

	if self._state_data.melee_expire_t and self._state_data.melee_expire_t <= t then
		self._state_data.melee_expire_t = nil
		self._state_data.melee_repeat_expire_t = nil

		if self._equipped_unit and input.btn_steelsight_state then
			self._steelsight_wanted = true
		end

		self:_stance_entered()

		if self._melee_and_run and self._running and not self._end_running_expire_t then
			self._delay_running_expire_t = t
		end
	end
end

function PlayerStandard:do_action_blammfu_melee(push_vel)
	if not self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_3 then
		return
	end

	self:push(push_vel)

	if not managers.player:can_throw_grenade() then
		self._ext_inventory:equip_not_empty(true)
		self:_interupt_action_melee()
	else
		managers.queued_tasks:queue(nil, self._start_action_equip, self, nil, 0.21, nil)
	end
end

function PlayerStandard:_check_action_reload(t, input)
	if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_4 or self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_3 then
		return
	end

	local new_action = nil
	local action_wanted = input.btn_reload_press

	if action_wanted then
		local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile() or self:_is_comm_wheel_active() or self:_mantling()

		if not action_forbidden and self._equipped_unit and not self._equipped_unit:base():clip_full() then
			self:_start_action_reload_enter(t)

			new_action = true
		end
	end

	return new_action
end

function PlayerStandard:_update_reload_timers(t, dt, input)
	if self._state_data.reload_enter_expire_t and self._state_data.reload_enter_expire_t <= t then
		self._state_data.reload_enter_expire_t = nil

		self:_start_action_reload(t)
	end

	if self._state_data.reload_expire_t then
		local interupt = false

		if self._equipped_unit:base():update_reloading(t, dt, self._state_data.reload_expire_t - t) then
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

			if self._queue_reload_interupt_t then
				interupt = t < self._queue_reload_interupt_t
				self._queue_reload_interupt_t = nil
			end
		end

		if self._state_data.reload_expire_t <= t or interupt then
			self._state_data.reload_expire_t = nil
			self._queue_reload_interupt_t = nil

			if self._equipped_unit:base():use_shotgun_reload() then
				local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()

				if self._equipped_unit:base():started_reload_empty() then
					self._state_data.reload_exit_expire_t = t + self._equipped_unit:base():reload_exit_expire_t() / speed_multiplier

					self._ext_camera:play_redirect(self.IDS_RELOAD_EXIT, speed_multiplier)
					self._equipped_unit:base():tweak_data_anim_play("reload_exit", speed_multiplier)
				else
					self._state_data.reload_exit_expire_t = t + self._equipped_unit:base():reload_not_empty_exit_expire_t() / speed_multiplier

					self._ext_camera:play_redirect(self.IDS_RELOAD_NOT_EMPTY_EXIT, speed_multiplier)
					self._equipped_unit:base():tweak_data_anim_play("reload_not_empty_exit", speed_multiplier)
				end

				self._equipped_unit:base():on_reload_shotgun()
			else
				if not interupt then
					self._equipped_unit:base():on_reload()
				end

				managers.statistics:reloaded()
				managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

				if input.btn_steelsight_state then
					self._steelsight_wanted = true
				elseif self._run_and_reload and self._running and not self._end_running_expire_t and not self._run_and_shoot then
					self._delay_running_expire_t = t + tweak_data.player.run_delay.equip
				end
			end

			self:on_action_reload_success()
		end
	end

	if self._state_data.reload_exit_expire_t and self._state_data.reload_exit_expire_t <= t then
		self._state_data.reload_exit_expire_t = nil

		if self._equipped_unit then
			managers.statistics:reloaded()
			managers.hud:set_ammo_amount(self._equipped_unit:base():selection_index(), self._equipped_unit:base():ammo_info())

			if input.btn_steelsight_state then
				self._steelsight_wanted = true
			elseif self._run_and_reload and self._running and not self._end_running_expire_t and not self._run_and_shoot then
				self._delay_running_expire_t = t + tweak_data.player.run_delay.equip
			end
		end
	end
end

function PlayerStandard:on_action_reload_success()
end

function PlayerStandard:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_press

	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_interacting() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_is_comm_wheel_active() or self:_mantling()

		if not action_forbidden and managers.player:can_use_selected_equipment(self._unit) then
			self:_start_action_use_item(t)

			new_action = true
		end
	end

	if input.btn_use_item_release then
		self:_interupt_action_use_item()
	end

	return new_action
end

function PlayerStandard:_update_use_item_timers(t, input)
	if self._use_item_expire_t then
		local valid = managers.player:check_selected_equipment_placement_valid(self._unit)
		local deploy_timer = managers.player:selected_equipment_deploy_timer()

		managers.hud:set_progress_timer_bar_valid(valid, not valid and "hud_deploy_valid_help")
		managers.hud:set_progress_timer_bar_width(deploy_timer - (self._use_item_expire_t - t), deploy_timer)

		if self._use_item_expire_t <= t then
			self:_end_action_use_item(valid)

			self._use_item_expire_t = nil
		end
	end
end

function PlayerStandard:_does_deploying_limit_movement()
	return self:is_deploying() and managers.player:selected_equipment_limit_movement() or false
end

function PlayerStandard:is_deploying()
	return self._use_item_expire_t and true or false
end

function PlayerStandard:_start_action_use_item(t)
	self:_interupt_action_reload(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_running(t)
	self:_interupt_action_charging_weapon(t)

	local deploy_timer = managers.player:selected_equipment_deploy_timer()
	self._use_item_expire_t = t + deploy_timer

	self._ext_camera:play_redirect(self.IDS_UNEQUIP)
	self._equipped_unit:base():tweak_data_anim_stop("equip")
	self._equipped_unit:base():tweak_data_anim_play("unequip")
	managers.hud:show_progress_timer_bar(0, deploy_timer)

	local text = managers.player:selected_equipment_deploying_text() or managers.localization:text("hud_deploying_equipment", {
		EQUIPMENT = managers.player:selected_equipment_name()
	})

	managers.hud:show_progress_timer({
		print = nil,
		text = text
	})

	local post_event = managers.player:selected_equipment_sound_start()

	if post_event then
		self._unit:sound_source():post_event(post_event)
	end

	local equipment_id = managers.player:selected_equipment_id()

	managers.network:session():send_to_peers_synched("sync_teammate_start_progress", deploy_timer)
end

function PlayerStandard:_end_action_use_item(valid)
	local post_event = managers.player:selected_equipment_sound_done()
	local result = managers.player:use_selected_equipment(self._unit)

	self:_interupt_action_use_item(nil, nil, valid)

	if valid and post_event then
		self._unit:sound_source():post_event(post_event)
	end
end

function PlayerStandard:_interupt_action_use_item(t, input, complete)
	if self._use_item_expire_t then
		self._use_item_expire_t = nil

		self:_start_action_equip()
		managers.hud:hide_progress_timer_bar(complete)
		managers.hud:remove_progress_timer()

		local post_event = managers.player:selected_equipment_sound_interupt()

		if not complete and post_event then
			self._unit:sound_source():post_event(post_event)
		end

		self._unit:equipment():on_deploy_interupted()

		if complete then
			managers.network:session():send_to_peers_synched("sync_teammate_complete_progress")
		else
			managers.network:session():send_to_peers_synched("sync_teammate_cancel_progress")
		end
	end
end

function PlayerStandard:_check_change_weapon(t, input)
	local new_action = nil
	local action_wanted = input.btn_switch_weapon_press

	if action_wanted then
		local equipped_selection = self._ext_inventory:equipped_selection()
		local selection_wanted = equipped_selection == PlayerInventory.SLOT_1 and PlayerInventory.SLOT_2 or PlayerInventory.SLOT_1
		local action_forbidden = self:_is_meleeing() or self._use_item_expire_t or self._change_item_expire_t or self._ext_inventory:is_selection_blocked(selection_wanted)
		action_forbidden = action_forbidden or self._unit:inventory():num_selections() == 1 or self:_interacting() or self:_is_throwing_projectile() or self:_is_comm_wheel_active() or self:_mantling()

		if not action_forbidden then
			local data = {
				selection_wanted = selection_wanted
			}
			self._change_weapon_pressed_expire_t = t + 0.33

			self:_start_action_unequip_weapon(t, data)

			new_action = true
		end
	end

	return new_action
end

function PlayerStandard:_check_action_next_weapon(t, input)
	if input.btn_next_weapon_press then
		local selection_wanted = self._ext_inventory:next_selection()

		self:set_weapon_selection_wanted(selection_wanted)
	end
end

function PlayerStandard:_check_action_previous_weapon(t, input)
	if input.btn_previous_weapon_press then
		local selection_wanted = self._ext_inventory:previous_selection()

		self:set_weapon_selection_wanted(selection_wanted)
	end
end

function PlayerStandard:_update_equip_weapon_timers(t, input)
	if self._unequip_weapon_expire_t and self._unequip_weapon_expire_t <= t then
		self._unequip_weapon_expire_t = nil

		self:_start_action_equip_weapon(t)
	end

	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil

		if input.btn_steelsight_state then
			self._steelsight_wanted = true
		end
	end
end

function PlayerStandard:is_equipping()
	return self._equip_weapon_expire_t
end

function PlayerStandard:_add_unit_to_char_table(char_table, unit, unit_type, interaction_dist, interaction_through_walls, tight_area, priority, my_head_pos, cam_fwd, ray_ignore_units)
	if unit:unit_data().disable_shout and not unit:brain():interaction_voice() then
		return
	end

	local u_head_pos = unit_type == 3 and unit:base():get_mark_check_position() or unit:movement():m_head_pos() + math.UP * 30
	local vec = u_head_pos - my_head_pos
	local dis = mvector3.normalize(vec)
	local max_dis = interaction_dist

	if dis < max_dis then
		local max_angle = math.max(8, math.lerp(tight_area and 30 or 90, tight_area and 10 or 30, dis / 1200))
		local angle = vec:angle(cam_fwd)

		if angle < max_angle then
			local ing_wgt = dis * dis * (1 - vec:dot(cam_fwd)) / priority

			if interaction_through_walls then
				table.insert(char_table, {
					unit = unit,
					inv_wgt = ing_wgt,
					unit_type = unit_type
				})
			else
				local ray = World:raycast("ray", my_head_pos, u_head_pos, "slot_mask", self._slotmask_AI_visibility, "ray_type", "ai_vision", "ignore_unit", ray_ignore_units or {})

				if not ray or mvector3.distance(ray.position, u_head_pos) < 30 then
					table.insert(char_table, {
						unit = unit,
						inv_wgt = ing_wgt,
						unit_type = unit_type
					})
				end
			end
		end
	end
end

function PlayerStandard:_get_interaction_target(char_table, my_head_pos, cam_fwd)
	local prime_target = nil
	local ray = World:raycast("ray", my_head_pos, my_head_pos + cam_fwd * 100 * 100, "slot_mask", self._slotmask_long_distance_interaction)

	if ray then
		for _, char in pairs(char_table) do
			if ray.unit == char.unit then
				prime_target = char

				break
			end
		end
	end

	if not prime_target then
		local low_wgt = nil

		for _, char in pairs(char_table) do
			local inv_wgt = char.inv_wgt

			if not low_wgt or inv_wgt < low_wgt then
				low_wgt = inv_wgt
				prime_target = char
			end
		end
	end

	return prime_target
end

function PlayerStandard:_get_intimidation_action(prime_target, char_table, amount, primary_only, detect_only)
	local voice_type, new_action, plural = nil
	local unit_type_enemy = 0
	local unit_type_civilian = 1
	local unit_type_teammate = 2
	local unit_type_camera = 3
	local unit_type_turret = 4
	local is_whisper_mode = managers.groupai:state():whisper_mode()

	if prime_target then
		if prime_target.unit_type == unit_type_teammate then
			local is_human_player, record = nil

			if not detect_only then
				record = managers.groupai:state():all_criminals()[prime_target.unit:key()]

				if record.ai then
					prime_target.unit:movement():set_cool(false)
					prime_target.unit:brain():on_long_dis_interacted(0, self._unit)
				else
					is_human_player = true
				end
			end

			local amount = 0
			local rally_skill_data = self._ext_movement:rally_skill_data()

			if rally_skill_data and mvector3.distance_sq(self._pos, record.m_pos) < rally_skill_data.range_sq then
				local needs_revive = nil

				if prime_target.unit:base().is_husk_player then
					needs_revive = prime_target.unit:interaction():active() and prime_target.unit:movement():need_revive()
				else
					needs_revive = prime_target.unit:character_damage():need_revive()
				end

				if needs_revive and rally_skill_data.long_dis_revive then
					voice_type = "revive"
				elseif not needs_revive and rally_skill_data.morale_boost_delay_t and rally_skill_data.morale_boost_delay_t < managers.player:player_timer():time() then
					voice_type = "boost"
					amount = 1
				end
			end

			if is_human_player then
				prime_target.unit:network():send_to_unit({
					"long_dis_interaction",
					prime_target.unit,
					amount,
					self._unit
				})
			elseif voice_type == "revive" then
				-- Nothing
			elseif voice_type == "boost" then
				if Network:is_server() then
					prime_target.unit:brain():on_long_dis_interacted(amount, self._unit)
				else
					managers.network:session():send_to_host("long_dis_interaction", prime_target.unit, amount, self._unit)
				end
			end

			voice_type = voice_type or "come"
			plural = false
		else
			local prime_target_key = prime_target.unit:key()

			if prime_target.unit_type == unit_type_enemy then
				plural = false

				if prime_target.unit:anim_data().hands_back then
					voice_type = "cuff_cop"
				elseif prime_target.unit:anim_data().surrender then
					voice_type = "down_cop"
				elseif is_whisper_mode and prime_target.unit:movement():cool() and prime_target.unit:base():char_tweak().silent_priority_shout then
					voice_type = "mark_cop_quiet"
				elseif prime_target.unit:base():char_tweak().priority_shout then
					voice_type = "mark_cop"
				else
					voice_type = "stop_cop"
				end
			elseif prime_target.unit_type == unit_type_camera then
				plural = false
				voice_type = "mark_camera"
			elseif prime_target.unit_type == unit_type_turret then
				local turret_mode = prime_target.unit:weapon():mode()

				if turret_mode and turret_mode == "enemy" then
					plural = false
					voice_type = "mark_turret"
				end
			elseif prime_target.unit:base():char_tweak().is_escort then
				plural = false
				local e_guy = prime_target.unit

				if e_guy:anim_data().move then
					voice_type = "escort_keep"
				elseif e_guy:anim_data().panic then
					voice_type = "escort_go"
				else
					voice_type = "escort"
				end
			else
				if prime_target.unit:movement():stance_name() == "cbt" and prime_target.unit:anim_data().stand then
					voice_type = "come"
				elseif prime_target.unit:anim_data().move then
					voice_type = "stop"
				elseif prime_target.unit:anim_data().drop then
					voice_type = "down_stay"
				else
					voice_type = "down"
				end

				local num_affected = 0

				for _, char in pairs(char_table) do
					if char.unit_type == unit_type_civilian then
						if voice_type == "stop" and char.unit:anim_data().move then
							num_affected = num_affected + 1
						elseif voice_type == "down_stay" and char.unit:anim_data().drop then
							num_affected = num_affected + 1
						elseif voice_type == "down" and not char.unit:anim_data().move and not char.unit:anim_data().drop then
							num_affected = num_affected + 1
						end
					end
				end

				if num_affected > 1 then
					plural = true
				else
					plural = false
				end
			end

			local max_inv_wgt = 0

			for _, char in pairs(char_table) do
				if max_inv_wgt < char.inv_wgt then
					max_inv_wgt = char.inv_wgt
				end
			end

			if max_inv_wgt < 1 then
				max_inv_wgt = 1
			end

			if detect_only then
				voice_type = "come"
			else
				for _, char in pairs(char_table) do
					if char.unit_type ~= unit_type_camera and char.unit_type ~= unit_type_teammate and (not is_whisper_mode or not char.unit:movement():cool()) then
						if char.unit_type == unit_type_civilian then
							amount = amount or tweak_data.player.long_dis_interaction.intimidate_strength
						end

						if prime_target_key == char.unit:key() then
							voice_type = char.unit:brain():on_intimidated(amount or tweak_data.player.long_dis_interaction.intimidate_strength, self._unit) or voice_type
						elseif not primary_only and char.unit_type ~= unit_type_enemy then
							char.unit:brain():on_intimidated((amount or tweak_data.player.long_dis_interaction.intimidate_strength) * char.inv_wgt / max_inv_wgt, self._unit)
						end
					end
				end
			end
		end
	end

	return voice_type, plural, prime_target
end

function PlayerStandard:_get_unit_intimidation_action(intimidate_enemies, intimidate_civilians, intimidate_teammates, only_special_enemies, intimidate_escorts, intimidation_amount, primary_only, detect_only)
	local char_table = {}
	local unit_type_enemy = 0
	local unit_type_civilian = 1
	local unit_type_teammate = 2
	local unit_type_camera = 3
	local unit_type_turret = 4
	local cam_fwd = self._ext_camera:forward()
	local my_head_pos = self._ext_movement:m_head_pos()
	local range_mul = 1
	local intimidate_range_civ = tweak_data.player.long_dis_interaction.intimidate_range_civilians * range_mul
	local intimidate_range_ene = tweak_data.player.long_dis_interaction.intimidate_range_enemies * range_mul
	local highlight_range = tweak_data.player.long_dis_interaction.highlight_range * range_mul

	if intimidate_enemies then
		local enemies = managers.enemy:all_enemies()

		for u_key, u_data in pairs(enemies) do
			if self._unit:movement():team().foes[u_data.unit:movement():team().id] and not u_data.unit:anim_data().hands_tied and not u_data.unit:anim_data().long_dis_interact_disabled and (u_data.char_tweak.priority_shout or not only_special_enemies) then
				if managers.groupai:state():whisper_mode() then
					if u_data.char_tweak.silent_priority_shout and u_data.unit:movement():cool() then
						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, highlight_range, false, false, 0.01, my_head_pos, cam_fwd)
					elseif not u_data.unit:movement():cool() then
						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, intimidate_range_ene, false, false, 100, my_head_pos, cam_fwd)
					end
				elseif u_data.char_tweak.priority_shout then
					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, highlight_range, false, false, 0.01, my_head_pos, cam_fwd)
				else
					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_enemy, intimidate_range_ene, false, false, 100, my_head_pos, cam_fwd)
				end
			end
		end
	end

	if intimidate_civilians then
		local civilians = managers.enemy:all_civilians()

		for u_key, u_data in pairs(civilians) do
			if u_data.unit:in_slot(21) and not u_data.unit:movement():cool() and not u_data.unit:anim_data().long_dis_interact_disabled then
				local is_escort = u_data.char_tweak.is_escort

				if not is_escort or intimidate_escorts then
					local dist = is_escort and 300 or intimidate_range_civ
					local prio = is_escort and 100000 or 0.001

					self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_civilian, dist, false, false, prio, my_head_pos, cam_fwd)
				end
			end
		end
	end

	if intimidate_teammates and not managers.groupai:state():whisper_mode() then
		local criminals = managers.groupai:state():all_char_criminals()

		for u_key, u_data in pairs(criminals) do
			local added = nil

			if u_key ~= self._unit:key() then
				local rally_skill_data = self._ext_movement:rally_skill_data()

				if rally_skill_data and rally_skill_data.long_dis_revive and mvector3.distance_sq(self._pos, u_data.m_pos) < rally_skill_data.range_sq then
					local needs_revive = nil

					if u_data.unit:base().is_husk_player then
						needs_revive = u_data.unit:interaction():active() and u_data.unit:movement():need_revive()
					else
						needs_revive = u_data.unit:character_damage():need_revive()
					end

					if needs_revive then
						added = true

						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_teammate, 100000, true, true, 5000, my_head_pos, cam_fwd)
					end
				end
			end

			if not added and not u_data.is_deployable and not u_data.unit:movement():downed() and not u_data.unit:base().is_local_player and not u_data.unit:anim_data().long_dis_interact_disabled then
				self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_teammate, 100000, true, true, 0.01, my_head_pos, cam_fwd)
			end
		end
	end

	if intimidate_enemies then
		local turret_units = managers.groupai:state():turrets()

		if turret_units then
			for _, unit in pairs(turret_units) do
				if alive(unit) and unit:weapon() and unit:weapon().name_id == "turret_m2" then
					self:_add_unit_to_char_table(char_table, unit, unit_type_turret, highlight_range, false, false, 0.01, my_head_pos, cam_fwd, {
						unit
					})
				end
			end
		end
	end

	local prime_target = self:_get_interaction_target(char_table, my_head_pos, cam_fwd)

	return self:_get_intimidation_action(prime_target, char_table, intimidation_amount, primary_only, detect_only)
end

function PlayerStandard:_start_action_intimidate(t)
	if not self._intimidate_t or tweak_data.player.movement_state.interaction_delay < t - self._intimidate_t then
		local skip_alert = managers.groupai:state():whisper_mode()
		local voice_type, plural, prime_target = self:_get_unit_intimidation_action(true, true, true, false, true, nil, nil, nil)
		local interact_type, sound_name, queue_sound_name = nil
		local sound_suffix = plural and "plu" or "sin"

		if voice_type == "stop" then
			interact_type = "cmd_stop"
		elseif voice_type == "stop_cop" then
			interact_type = "cmd_stop"
		elseif voice_type == "mark_cop" or voice_type == "mark_cop_quiet" or voice_type == "mark_turret" then
			interact_type = "cmd_point"

			if voice_type == "mark_turret" then
				sound_name = "shout_loud_turret"
			elseif voice_type == "mark_cop_quiet" then
				sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].silent_priority_shout
			else
				sound_name = tweak_data.character[prime_target.unit:base()._tweak_table].priority_shout
			end

			self:_mark_prime_target(prime_target)

			if prime_target.unit:unit_data().mission_element then
				prime_target.unit:unit_data().mission_element:event("marked", prime_target.unit)
			end
		elseif voice_type == "down" then
			interact_type = "cmd_down"
			self._shout_down_t = t
		elseif voice_type == "down_cop" then
			interact_type = "cmd_down"
		elseif voice_type == "cuff_cop" then
			interact_type = "cmd_down"
		elseif voice_type == "down_stay" then
			interact_type = "cmd_down"
		elseif voice_type == "come" then
			interact_type = "cmd_come"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)
			local target, nationality = self:teammate_aimed_at_by_player()

			if target then
				local player_nationality = self:get_wwise_nationality_from_nationality(managers.network:session():local_peer()._character)
				local target_nationality = self:get_wwise_nationality_from_nationality(nationality)

				if target_nationality == player_nationality and player_nationality ~= "amer" then
					target_nationality = "amer"
				elseif target_nationality == player_nationality and player_nationality == "amer" then
					target_nationality = "brit"
				end

				sound_name = player_nationality .. "_call_" .. target_nationality
			else
				sound_name = "player_intimidate_follow"
			end
		elseif voice_type == "revive" then
			interact_type = "cmd_get_up"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if not static_data then
				return
			end

			local character_code = static_data.ssuffix

			if math.random() < self._ext_movement:rally_skill_data().revive_chance then
				prime_target.unit:interaction():interact(self._unit)
			end

			self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		elseif voice_type == "boost" then
			interact_type = "cmd_gogo"
			local static_data = managers.criminals:character_static_data_by_unit(prime_target.unit)

			if not static_data then
				return
			end

			local character_code = static_data.ssuffix
			sound_name = "g18"
			self._ext_movement:rally_skill_data().morale_boost_delay_t = managers.player:player_timer():time() + (self._ext_movement:rally_skill_data().morale_boost_cooldown_t or 3.5)
		elseif voice_type == "escort" then
			interact_type = "cmd_point"
			sound_name = "player_gen_impatient"
		elseif voice_type == "escort_keep" or voice_type == "escort_go" then
			interact_type = "cmd_point"
			sound_name = "player_gen_impatient"
		elseif voice_type == "bridge_codeword" then
			interact_type = "cmd_point"
		elseif voice_type == "bridge_chair" then
			interact_type = "cmd_point"
		elseif voice_type == "undercover_interrogate" then
			interact_type = "cmd_point"
		elseif voice_type == "mark_camera" then
			interact_type = "cmd_point"

			prime_target.unit:contour():add("mark_unit", true)
		end

		self:_do_action_intimidate(t, interact_type, sound_name, queue_sound_name, skip_alert)
	end
end

function PlayerStandard:_mark_prime_target(prime_target)
	local time_multi = 1
	local damage_multiplier = managers.player:upgrade_value("player", "highlight_enemy_damage_bonus", 1)
	local setup = nil
	local turret_weapon = prime_target.unit:weapon()

	if turret_weapon then
		turret_weapon:mark_turret({
			"mark_enemy",
			true,
			time_multi,
			damage_multiplier
		})
	else
		setup = prime_target.unit:contour():add("mark_enemy", true, time_multi, damage_multiplier)
	end
end

function PlayerStandard:_is_turret_dangerous(turret_target)
	if turret_target.unit:movement():team().foes[self._ext_movement:team().id] then
		return true
	end
end

function PlayerStandard:_do_action_intimidate(t, interact_type, sound_name, queue_sound_name, skip_alert)
	if sound_name then
		self._intimidate_t = t

		managers.dialog:queue_dialog(sound_name, {
			skip_idle_check = true,
			instigator = self._unit
		})
	end

	if interact_type and not self:_is_using_bipod() then
		self:_play_distance_interact_redirect(t, interact_type)
	end
end

function PlayerStandard:get_wwise_nationality_from_nationality(character)
	local lower = string.lower(character)

	if lower == "russian" then
		return "rus"
	elseif lower == "german" then
		return "ger"
	elseif lower == "spanish" then
		return "brit"
	elseif lower == "american" then
		return "amer"
	end

	return "brit"
end

function PlayerStandard:teammate_aimed_at_by_player()
	local criminals = managers.groupai:state():all_char_criminals()
	local char_table = {}
	local cam_fwd = self._ext_camera:forward()
	local my_head_pos = self._ext_movement:m_head_pos()

	for u_key, u_data in pairs(criminals) do
		local added = nil

		if u_key ~= self._unit:key() then
			local rally_skill_data = self._ext_movement:rally_skill_data()

			if rally_skill_data and rally_skill_data.long_dis_revive and mvector3.distance_sq(self._pos, u_data.m_pos) < rally_skill_data.range_sq then
				local needs_revive = nil

				if u_data.unit:base().is_husk_player then
					needs_revive = u_data.unit:interaction():active() and u_data.unit:movement():need_revive()
				else
					needs_revive = u_data.unit:character_damage():need_revive()
				end

				if needs_revive then
					added = true

					self:_add_unit_to_char_table(char_table, u_data.unit, 2, 100000, true, true, 5000, my_head_pos, cam_fwd)
				end
			end
		end

		if not added and not u_data.is_deployable and not u_data.unit:movement():downed() and not u_data.unit:base().is_local_player and not u_data.unit:anim_data().long_dis_interact_disabled then
			self:_add_unit_to_char_table(char_table, u_data.unit, 2, 100000, true, true, 0.01, my_head_pos, cam_fwd)
		end
	end

	local prime_target = self:_get_interaction_target(char_table, my_head_pos, cam_fwd)

	if prime_target then
		local bots = managers.groupai:state()._ai_criminals
		local players = managers.player:players()

		for i = 1, #players do
			if prime_target.unit == players[i] then
				return prime_target.unit:base():nick_name(), prime_target.unit:base()._tweak_table, prime_target.unit
			end
		end

		for u_key, u_data in pairs(managers.network:session():peers()) do
			if prime_target.unit == u_data._unit then
				return u_data._name, u_data._character, u_data.unit
			end
		end

		for u_key, u_data in pairs(bots) do
			if prime_target.unit == u_data.unit then
				return prime_target.unit:base():nick_name(), prime_target.unit:base()._tweak_table, prime_target.unit
			end
		end
	end

	return nil, nil, nil
end

function PlayerStandard:say_line(sound_name, queue_sound_name, skip_alert)
	self._unit:sound():say(sound_name, nil, true)

	if queue_sound_name then
		self._unit:sound():queue_sound("player_standard", queue_sound_name, nil, true)
	end

	skip_alert = skip_alert or managers.groupai:state():whisper_mode()

	if not skip_alert then
		local alert_rad = 500
		local new_alert = {
			"vo_cbt",
			self._unit:movement():m_head_pos(),
			alert_rad,
			self._unit:movement():SO_access(),
			self._unit
		}

		managers.groupai:state():propagate_alert(new_alert)
	end
end

function PlayerStandard:_play_distance_interact_redirect(t, variant)
	managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, variant)

	if self._state_data.in_steelsight then
		return
	end

	if self._shooting or not self._equipped_unit:base():start_shooting_allowed() then
		return
	end

	if self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t then
		return
	end

	if self:_is_carrying_corpse() then
		return
	end

	if not self._state_data.interact_redirect_t or self._state_data.interact_redirect_t < t then
		local delay = tweak_data.player.run_delay[variant] or tweak_data.player.run_delay.distance_interact
		self._delay_running_expire_t = t + delay
	end

	self._state_data.interact_redirect_t = t + 1

	self._ext_camera:play_redirect(Idstring(variant))
end

function PlayerStandard:_break_intimidate_redirect(t)
	if self._shooting then
		return
	end

	if self._state_data.interact_redirect_t and t < self._state_data.interact_redirect_t then
		self._ext_camera:play_redirect(self.IDS_IDLE)
	end
end

function PlayerStandard:_play_interact_redirect(t, interact_object)
	if self._shooting or not self._equipped_unit:base():start_shooting_allowed() then
		return
	end

	if self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self:in_steelsight() then
		return
	end

	if not self._interact_redirect_state or not self._camera_unit:anim_state_machine():is_playing(self._interact_redirect_state) then
		local delay = tweak_data.player.run_delay.use_generic
		self._delay_running_expire_t = t + delay
	end

	local redirect = self.IDS_USE

	if alive(interact_object) then
		redirect = interact_object:interaction():interact_redirect()
	end

	self._state_data.interact_redirect_t = t + 1
	local result = self._ext_camera:play_redirect(redirect or self.IDS_USE)

	if result then
		self._interact_redirect_state = result
	end
end

function PlayerStandard:_break_interact_redirect(t)
	self._ext_camera:play_redirect(self.IDS_IDLE)
end

function PlayerStandard:set_weapon_selection_wanted(selection_wanted)
	self._weapon_selection_wanted = selection_wanted
end

function PlayerStandard:_check_action_equip(t, input)
	local new_action = nil
	local selection_wanted = input.btn_primary_choice or self._weapon_selection_wanted

	if selection_wanted then
		local action_forbidden = self:chk_action_forbidden("equip") or self._ext_inventory:is_selection_blocked(selection_wanted) or self._use_item_expire_t or self:_is_meleeing() or self:_interacting() or self:_is_throwing_projectile() or self:_is_comm_wheel_active() or self:_mantling()

		if not action_forbidden then
			local new_action = not self._ext_inventory:is_equipped(selection_wanted) or self._unequip_weapon_expire_t
			local fail_reason = nil

			if selection_wanted == PlayerInventory.SLOT_3 and not managers.player:can_throw_grenade() then
				fail_reason = "hint_out_of_grenades"
				new_action = nil
			end

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ONLY_MELEE_AVAILABLE) and selection_wanted ~= PlayerInventory.SLOT_4 then
				fail_reason = "hint_weapon_slot_melee_only"
				new_action = nil
			end

			if new_action then
				self:_start_action_unequip_weapon(t, {
					selection_wanted = selection_wanted
				})
			elseif fail_reason then
				managers.notification:add_notification({
					duration = 3,
					shelf_life = 5,
					id = fail_reason,
					text = managers.localization:text(fail_reason)
				})
			end
		end
	end

	self._weapon_selection_wanted = nil

	return new_action
end

function PlayerStandard:_check_comm_wheel(t, input)
	local action_forbidden = self:chk_action_forbidden("comm_wheel") or self._unit:base():stats_screen_visible() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self:_mantling()

	if action_forbidden then
		return
	end

	local wheel_active = self:_is_comm_wheel_active()

	if not wheel_active and input.btn_comm_wheel_press then
		managers.hud:show_comm_wheel()
	elseif wheel_active and input.btn_comm_wheel_release then
		managers.hud:hide_comm_wheel()
	end

	if input.btn_comm_wheel_yes_press then
		managers.hud:trigger_comm_wheel_option("yes")
	elseif input.btn_comm_wheel_no_press then
		managers.hud:trigger_comm_wheel_option("no")
	elseif input.btn_comm_wheel_found_it_press then
		managers.hud:trigger_comm_wheel_option("found_it")
	elseif input.btn_comm_wheel_wait_press then
		managers.hud:trigger_comm_wheel_option("wait")
	elseif input.btn_comm_wheel_not_here_press then
		managers.hud:trigger_comm_wheel_option("not_here")
	elseif input.btn_comm_wheel_follow_me_press then
		managers.hud:trigger_comm_wheel_option("follow_me")
	elseif input.btn_comm_wheel_assistance_press then
		managers.hud:trigger_comm_wheel_option("assistance")
	elseif input.btn_comm_wheel_enemy_press then
		managers.hud:trigger_comm_wheel_option("enemy")
	end
end

function PlayerStandard:_check_action_warcry(t, input)
	if not managers.warcry:meter_full() or managers.warcry:active() then
		return false
	end

	if managers.controller:is_using_controller() then
		if input.btn_warcry_left_state and input.btn_warcry_right_state then
			managers.warcry:activate_warcry()

			return true
		end
	elseif input.btn_activate_warcry_press then
		managers.warcry:activate_warcry()

		return true
	end

	return false
end

function PlayerStandard:_check_fullscreen_switch(t, dt, input)
	self._alt_enter_fullscreen_switch_timer = (self._alt_enter_fullscreen_switch_timer or 0) + dt

	if self._alt_enter_fullscreen_switch_timer < PlayerStandard.ALT_ENTER_FULLSCREEN_SWITCH_COOLDOWN then
		return
	end

	if input.btn_left_alt_inspect_state and input.btn_enter_inspect_state then
		managers.raid_menu:toggle_fullscreen_raid()

		self._alt_enter_fullscreen_switch_timer = 0
	end
end

function PlayerStandard:_toss_ammo(...)
	local idx = managers.player:upgrade_value("player", "toss_ammo", 0)

	if idx ~= 0 then
		local ratio = 1 + 1 - ThrowableAmmoBag.LEVEL[idx]
		local can_throw = true
		local inventory = self._unit:inventory()

		for id, weapon in pairs(inventory:available_selections()) do
			if weapon.unit:base().get_ammo_ratio_excluding_clip and weapon.unit:base():get_ammo_ratio_excluding_clip() < ThrowableAmmoBag.LEVEL[idx] - 1 then
				can_throw = false
			end
		end

		if can_throw then
			for id, weapon in pairs(inventory:available_selections()) do
				if weapon.unit:base().add_ammo_ratio and weapon.unit:base():add_ammo_ratio(ratio) then
					managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
				end
			end

			self._ext_camera:play_redirect(PlayerStandard.IDS_TOSS_AMMO)
		end
	end
end

function PlayerStandard:_closest_visible_team_member(max_distance_sq, slotmask)
	local criminals = managers.groupai:state():all_char_criminals()
	local char_table = {}
	local max_angle = 20
	local cam_fwd = self._ext_camera:forward()
	local my_head_pos = self._ext_movement:m_head_pos()
	local last_error, prime_target_unit = nil
	local cam_fwd = self._ext_camera:forward()

	for u_key, u_data in pairs(criminals) do
		if u_key ~= self._unit:key() then
			local distance_sq = mvector3.distance_sq(my_head_pos, u_data.m_det_pos)
			local vec = u_data.m_det_pos - my_head_pos
			local angle = vec:angle(cam_fwd)

			print("unit ", u_data.unit)
			print("angle ", angle)

			if angle < max_angle then
				if max_distance_sq < distance_sq then
					local ray = World:raycast("ray", my_head_pos, u_data.m_det_pos, "slot_mask", slotmask or self._slotmask_world)

					if not ray then
						prime_target_unit = u_data.unit
						max_distance_sq = distance_sq
					else
						last_error = "object in the way"
					end
				else
					last_error = "target too far away"
				end
			else
				last_error = "no targets in view"
			end
		end
	end

	if not prime_target_unit and last_error then
		print("ERROR: ", last_error)
	else
		print("prime target: ", prime_target_unit)
	end

	return prime_target_unit
end

function PlayerStandard:_check_stats_screen(t, dt, input)
	if input.btn_stats_screen_press then
		local notification_react = managers.notification:react(t)

		if not notification_react then
			managers.hud:show_stats_screen()
		end
	elseif input.btn_stats_screen_down then
		managers.notification:react_hold(t, dt)
	elseif input.btn_stats_screen_release then
		managers.notification:react_cancel()
		managers.hud:hide_stats_screen()
	end
end

function PlayerStandard:_check_action_jump(t, input)
	local new_action = nil
	local action_wanted = input.btn_jump_press

	if action_wanted then
		local angle_limit = tweak_data.player.max_floor_jump_angle[self._not_moving_t > 0.1 and "max" or "min"]
		local action_forbidden = self._jump_t and t < self._jump_t + 0.55
		action_forbidden = action_forbidden or self._gnd_angle and angle_limit < self._gnd_angle
		action_forbidden = action_forbidden or self._unit:base():stats_screen_visible() or self:in_air() or self:_interacting() or self:_on_zipline() or self:_does_deploying_limit_movement() or self:_is_using_bipod() or self:_is_comm_wheel_active() or self:_mantling()

		if not action_forbidden then
			if self._state_data.ducking then
				self:_interupt_action_ducking(t)
			elseif not self:_check_action_mantle(t, input) then
				if self._state_data.on_ladder then
					self:_interupt_action_ladder(t)
				end

				local action_start_data = {}
				local jump_vel_z = self._tweak_data.movement.jump_velocity.z
				jump_vel_z = jump_vel_z * managers.player:temporary_upgrade_value("temporary", "candy_jump_boost", 1)
				action_start_data.jump_vel_z = jump_vel_z

				if self._move_dir then
					local is_running = self._running and t - self._start_running_t > 0.2
					local jump_vel_xy = self._tweak_data.movement.jump_velocity.xy[is_running and "run" or "walk"]
					action_start_data.jump_vel_xy = jump_vel_xy

					if is_running then
						self._unit:movement():subtract_stamina(self._unit:movement():get_jump_stamina_drain())
					end
				end

				new_action = self:_start_action_jump(t, action_start_data)
			end
		end
	end

	return new_action
end

function PlayerStandard:_start_action_jump(t, action_start_data)
	self:_interupt_action_running(t)

	self._jump_t = t
	local jump_vec = action_start_data.jump_vel_z * math.UP

	self._unit:mover():jump()

	if self._move_dir then
		local move_dir_clamp = self._move_dir:normalized() * math.min(1, self._move_dir:length())
		self._last_velocity_xy = move_dir_clamp * action_start_data.jump_vel_xy
		self._jump_vel_xy = mvector3.copy(self._last_velocity_xy)
	else
		self._last_velocity_xy = Vector3()
	end

	self:_perform_jump(jump_vec)
end

function PlayerStandard:_perform_jump(jump_vec)
	self._unit:mover():set_velocity(jump_vec)

	self._send_jump_vec = jump_vec * 0.87

	if self._jump_vel_xy then
		mvec3_set(temp_vec1, self._jump_vel_xy)
		mvec3_set_z(temp_vec1, 0)
		mvec3_add(self._send_jump_vec, temp_vec1)
	end
end

function PlayerStandard:_update_network_jump(pos, is_exit)
	local mover = self._unit:mover()

	if self._is_jumping and (is_exit or not mover or mover:standing() and mover:velocity().z < 0 or mover:gravity().z == 0) then
		if not self._is_jump_middle_passed then
			self._ext_network:send("action_jump_middle", pos or self._pos)

			self._is_jump_middle_passed = true
		end

		self._is_jumping = nil

		self._ext_network:send("action_land", pos or self._pos)
	elseif self._send_jump_vec and not is_exit then
		if self._is_jumping then
			self._ext_network:send("action_land", pos or self._pos)
		end

		self._ext_network:send("action_jump", pos or self._pos, self._send_jump_vec)

		self._send_jump_vec = nil
		self._is_jumping = true
		self._is_jump_middle_passed = nil

		if managers.user:get_setting("use_camera_accel") then
			self._ext_camera:play_shaker("player_jump", self:in_steelsight() and 0.2)
		end

		mvector3.set(self._last_sent_pos, pos or self._pos)
	elseif self._is_jumping and not self._is_jump_middle_passed and mover and mover:velocity().z < 0 then
		self._ext_network:send("action_jump_middle", pos or self._pos)

		self._is_jump_middle_passed = true
	end
end

function PlayerStandard:_check_action_mantle(t, input)
	local action_forbidden = self:in_steelsight() or self:_changing_weapon() or self:_on_zipline() or self:_is_throwing_projectile() or self:shooting() or self:_is_meleeing() or self:in_air() or self:on_ladder()

	if action_forbidden then
		return false
	end

	local move_dot = self._move_dir and mvector3.dot(self._move_dir, self._cam_fwd_flat) or 0

	if move_dot <= 0 or self._state_data.mantling then
		return false
	end

	local mover_radius = 31
	local sphere_offset = math.UP * (mover_radius + 1)
	local fwd_vect = self._cam_fwd_flat * self._tweak_data.movement.mantle.CLOSE_CHECK_DISTANCE
	local precision_vect = fwd_vect:rotate_with(Rotation(90, 0, 0)) / 2
	local fwd_pos = self._pos + fwd_vect

	local function pos_available(hit_pos, crouched)
		local head_pos = self._ext_movement:m_head_pos()
		local check_height = tweak_data.player[crouched and "PLAYER_EYE_HEIGHT_CROUCH" or "PLAYER_EYE_HEIGHT"]
		local check_start_pos = hit_pos + sphere_offset
		local check_end_pos = check_start_pos + math.UP * check_height
		local ray = World:raycast("ray", head_pos, check_end_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 8, "report")

		if not ray then
			local bodies = self._unit:find_bodies("intersect", "cylinder", check_start_pos, check_end_pos, mover_radius, self._slotmask_gnd_ray)
			local obstructed = false

			for _, hit_body in ipairs(bodies) do
				obstructed = obstructed or hit_body:collides_with_mover()
			end

			if obstructed then
				return false
			end

			local hit_end_pos = hit_pos + math.DOWN * self._tweak_data.damage.FALL_DAMAGE_FATAL_HEIGHT
			local fall_ray = World:raycast("ray", hit_pos, hit_end_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "report")

			if fall_ray then
				return hit_pos
			end
		end

		return false
	end

	local max_pos = fwd_pos + self._tweak_data.movement.mantle.MAX_CHECK_HEIGHT
	local min_pos = fwd_pos + self._tweak_data.movement.mantle.MIN_CHECK_HEIGHT
	local max_angle = tweak_data.player.max_floor_jump_angle.min - angle_epsilon
	local ray = World:raycast("ray", max_pos, min_pos, "slot_mask", self._slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 8)

	if ray and ray.distance > 0 and ray.normal:angle(math.UP) < max_angle then
		local crouch_pos, close_pos, mid_pos, far_pos = nil

		for i = 1, tweak_data.player.MANTLE_PRECISION do
			local check_offset = precision_vect * (i % 3 - 1)
			local check_pos = ray.position + check_offset
			crouch_pos = pos_available(check_pos, true)

			if crouch_pos then
				break
			end
		end

		if not crouch_pos then
			return false
		end

		close_pos = pos_available(crouch_pos)

		if not close_pos or self._running then
			local mid_vect = self._cam_fwd_flat * self._tweak_data.movement.mantle.MID_CHECK_DISTANCE
			local check_pos = crouch_pos + mid_vect - sphere_offset * 2
			mid_pos = pos_available(check_pos)
		end

		if not mid_pos and not close_pos then
			local far_vect = self._cam_fwd_flat * self._tweak_data.movement.mantle.FAR_CHECK_DISTANCE
			local check_pos = crouch_pos + far_vect - sphere_offset * 2
			far_pos = pos_available(check_pos)
		end

		local target_pos = far_pos or mid_pos or close_pos or crouch_pos

		if target_pos then
			self:_start_action_mantle(t, input, target_pos, far_pos or mid_pos)

			return true
		end
	end

	return false
end

function PlayerStandard:_start_action_mantle(t, input, end_pos, is_vault)
	self:_interupt_action_running(t)
	self:_interupt_action_steelsight(t)
	self:_interupt_action_reload(t)

	if not is_vault then
		self:_start_action_ducking(t)
	end

	self._ext_camera:play_redirect(self.IDS_MANTLE)
	self._equipped_unit:base():tweak_data_anim_stop("fire")

	if managers.user:get_setting("use_camera_accel") then
		self._ext_camera:play_shaker(is_vault and "player_vault" or "player_mantle")
	end

	self._camera_unit:base():set_limits(60, 40)
	self._camera_unit:base():set_sensitivity_multiplier(0.4)

	local multiplier = managers.player:upgrade_value("player", "fasthand_mantle_speed_increase", 1)
	local mantle_speed = self._tweak_data.movement.mantle.MANTLING_SPEED * multiplier
	local is_running = self._running and t - self._start_running_t > 0.2

	if is_running and is_vault then
		self._unit:movement():subtract_stamina(self._unit:movement():get_jump_stamina_drain() / 2)
	end

	self._state_data.mantling = true
	self._state_data.mantle_data = {
		start_pos = self._unit:position(),
		end_pos = end_pos
	}
	self._state_data.mantle_data.slack = -math.max(0, math.abs(self._state_data.mantle_data.start_pos.z - self._state_data.mantle_data.end_pos.z) / 2)
	self._state_data.mantle_data.tot_t = (self._state_data.mantle_data.end_pos - self._state_data.mantle_data.start_pos):length() / mantle_speed
	self._state_data.mantle_data.t = 0
	self._state_data.mantle_data.is_vault = is_vault

	self._unit:kill_mover()
end

function PlayerStandard:_update_mantle_timers(t, dt)
	if not self._state_data.mantling then
		return
	end

	self._state_data.mantle_data.t = math.min(self._state_data.mantle_data.t + dt / self._state_data.mantle_data.tot_t, 1)
	local mantling_speed = math.bezier({
		0,
		0,
		0.6,
		1
	}, self._state_data.mantle_data.t)
	self._state_data.mantle_data.position = math.lerp(self._state_data.mantle_data.start_pos, self._state_data.mantle_data.end_pos, mantling_speed)
	local bez = math.bezier({
		0,
		0.16,
		0.55,
		0.1
	}, mantling_speed)
	local slack = math.lerp(0, self._state_data.mantle_data.slack, bez)

	mvector3.set_z(self._state_data.mantle_data.position, mvector3.z(self._state_data.mantle_data.position) - slack)

	if self._state_data.mantle_data.t >= 1 then
		self:_end_action_mantle(t)
	end
end

function PlayerStandard:_interupt_action_mantle(t)
	if self._state_data.mantling then
		self:_end_action_mantle(t)
	end
end

function PlayerStandard:_end_action_mantle(t)
	self._state_data.mantling = nil
	self._state_data.mantle_data = nil

	self._camera_unit:base():remove_limits()
	self._camera_unit:base():set_sensitivity_multiplier(1)

	if self:_can_stand() then
		self:_activate_mover(PlayerStandard.MOVER_STAND)
		self:_interupt_action_ducking(t, true)
	else
		self:_activate_mover(PlayerStandard.MOVER_DUCK)
	end
end

function PlayerStandard:_mantling()
	return self._state_data.mantling
end

function PlayerStandard:_check_action_zipline(t, input)
	if self:in_air() then
		return
	end

	if not self._state_data.on_zipline then
		local zipline_unit = self._unit:movement():zipline_unit()

		if alive(zipline_unit) then
			self:_start_action_zipline(t, input, zipline_unit)
		end
	end
end

function PlayerStandard:_start_action_zipline(t, input, zipline_unit)
	self:_interupt_action_running(t)
	self:_interupt_action_ducking(t, true)
	self:_interupt_action_steelsight(t)

	self._state_data.on_zipline = true
	self._state_data.zipline_data = {
		zipline_unit = zipline_unit
	}

	self._ext_camera:play_shaker("player_enter_zipline")

	if zipline_unit then
		self._state_data.zipline_data.player_lerp_t = 0
		self._state_data.zipline_data.player_lerp_tot_t = 0.5
		self._state_data.zipline_data.tot_t = zipline_unit:zipline():total_time()
	else
		self._state_data.zipline_data.start_pos = self._unit:position()
		self._state_data.zipline_data.end_pos = self._fwd_ray.position
		self._state_data.zipline_data.slack = math.max(0, math.abs(self._state_data.zipline_data.start_pos.z - self._state_data.zipline_data.end_pos.z) / 3)
		self._state_data.zipline_data.tot_t = (self._state_data.zipline_data.end_pos - self._state_data.zipline_data.start_pos):length() / 1000
	end

	self._state_data.zipline_data.t = 0
	self._state_data.zipline_data.camera_shake = self._ext_camera:play_shaker("player_on_zipline", 0)

	self._unit:kill_mover()
end

function PlayerStandard:_update_zipline_timers(t, dt)
	if not self._state_data.on_zipline then
		return
	end

	self._state_data.zipline_data.t = math.min(self._state_data.zipline_data.t + dt / self._state_data.zipline_data.tot_t, 1)

	if alive(self._state_data.zipline_data.zipline_unit) then
		self._state_data.zipline_data.position = self._state_data.zipline_data.zipline_unit:zipline():update_and_get_pos_at_time(self._state_data.zipline_data.t)

		if self._state_data.zipline_data.player_lerp_t then
			self._state_data.zipline_data.player_lerp_t = math.min(self._state_data.zipline_data.player_lerp_t + dt / self._state_data.zipline_data.player_lerp_tot_t, 1)
			self._state_data.zipline_data.position = math.lerp(self._unit:position(), self._state_data.zipline_data.position, self._state_data.zipline_data.player_lerp_t)

			if self._state_data.zipline_data.player_lerp_t == 1 then
				self._state_data.zipline_data.player_lerp_t = nil
			end
		end
	else
		self._state_data.on_zipline_move = math.bezier({
			0,
			0,
			1,
			1
		}, self._state_data.zipline_data.t)
		self._state_data.zipline_data.position = math.lerp(self._state_data.zipline_data.start_pos, self._state_data.zipline_data.end_pos, self._state_data.on_zipline_move)
		local bez = math.bezier({
			0,
			1,
			0.5,
			0
		}, self._state_data.on_zipline_move)
		local slack = math.lerp(0, self._state_data.zipline_data.slack, bez)

		mvector3.set_z(self._state_data.zipline_data.position, mvector3.z(self._state_data.zipline_data.position) - slack)
	end

	if self._state_data.zipline_data.t == 1 then
		self:_end_action_zipline(t)
	end
end

function PlayerStandard:_end_action_zipline(t)
	self._ext_camera:play_shaker("player_exit_zipline", 1)

	local tilt = managers.player:is_carrying() and PlayerCarry.target_tilt or 0

	self._ext_camera:camera_unit():base():set_target_tilt(tilt)

	self._state_data.on_zipline = nil

	self._unit:movement():on_exit_zipline()

	if self._state_data.zipline_data.camera_shake then
		self._ext_camera:shaker():stop(self._state_data.zipline_data.camera_shake)

		self._state_data.zipline_data.camera_shake = nil
	end

	self._state_data.zipline_data = nil

	self:_activate_mover(PlayerStandard.MOVER_STAND)
end

function PlayerStandard:_on_zipline()
	return self._state_data.on_zipline
end

function PlayerStandard:_check_action_deploy_bipod(t, input)
	if not input.btn_deploy_bipod then
		return
	end

	if self:in_steelsight() or self:_on_zipline() or self:_is_throwing_projectile() or self:_is_meleeing() then
		return
	end

	local weapon = self._equipped_unit:base()
	local bipod_part = managers.weapon_factory:get_parts_from_weapon_by_perk("bipod", weapon._parts)

	if bipod_part and bipod_part[1] then
		local bipod_unit = bipod_part[1].unit:base()

		bipod_unit:check_state()
	end
end

function PlayerStandard:_check_action_cash_inspect(t, input)
	if input.btn_cash_inspect_press then
		return
	end

	if not input.btn_cash_inspect_press then
		return
	end

	local action_forbidden = self:_interacting() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self:running() or self:_is_reloading() or self:in_steelsight() or self:is_equipping() or self:shooting() or self:_is_cash_inspecting(t) or self:_is_comm_wheel_active()

	if action_forbidden then
		return
	end

	self._ext_camera:play_redirect(self.IDS_CASH_INSPECT)
end

function PlayerStandard:_is_cash_inspecting(t)
	return self._camera_unit_anim_data.cash_inspecting
end

function PlayerStandard:_interupt_action_cash_inspect(t)
	if not self:_is_cash_inspecting() then
		return
	end

	self._ext_camera:play_redirect(self.IDS_IDLE)
end

function PlayerStandard:_check_action_run(t, input)
	local move_dir_length = self._move_dir and self._move_dir:length() or 0

	if self._setting_hold_to_run and input.btn_run_release or self._running and move_dir_length < tweak_data.player.run_move_dir_treshold then
		self._running_wanted = false

		if self._running then
			self:_end_action_running(t)

			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	elseif not self._setting_hold_to_run and input.btn_run_release and not self._move_dir then
		self._running_wanted = false
	elseif input.btn_run_press or self._running_wanted or input.btn_run_state and self._setting_hold_to_run and not self:ducking() and not self:in_steelsight() and not self:_is_reloading() and not input.btn_primary_attack_state and not self._steelsight_wanted and not self._jump_t then
		if (not self._running or self._end_running_expire_t) and tweak_data.player.run_move_dir_treshold <= move_dir_length then
			self:_start_action_running(t)
		elseif self._running and not self._setting_hold_to_run then
			self:_end_action_running(t)

			if input.btn_steelsight_state and not self._state_data.in_steelsight then
				self._steelsight_wanted = true
			end
		end
	end
end

function PlayerStandard:_update_running_timers(t)
	if self._end_running_expire_t then
		if self._end_running_expire_t <= t then
			self._end_running_expire_t = nil

			self:set_running(false)
			self._unit:sound():play("foley_run_m4_02")
		end
	elseif self._running and (self._unit:movement():is_stamina_drained() or not self:_can_run_directional()) then
		self:_interupt_action_running(t)
	end

	if self._delay_running_expire_t and self._delay_running_expire_t <= t then
		self._delay_running_expire_t = nil

		if self._running and not self._end_running_expire_t then
			self._ext_camera:play_redirect(self._run_and_shoot and self.IDS_IDLE or self.IDS_START_RUNNING)
		end
	end
end

function PlayerStandard:set_running(running)
	self._running = running

	self._unit:movement():set_running(self._running)
	self:_upd_attention()
end

function PlayerStandard:_check_action_ladder(t, input)
	if self._state_data.on_ladder then
		local ladder_unit = self._unit:movement():ladder_unit()

		if not ladder_unit then
			return
		end

		local end_climbing = ladder_unit:ladder():check_end_climbing(self._unit:movement():m_pos(), self._normal_move_dir, self._gnd_ray)

		if end_climbing then
			self:_end_action_ladder()
		end

		return
	end

	local action_forbidden = not self._move_dir or self._state_data.on_zipline or self._state_data.mantling

	if not action_forbidden then
		local u_pos = self._unit:movement():m_pos()

		for i = 1, math.min(Ladder.LADDERS_PER_FRAME, #Ladder.active_ladders) do
			local ladder_unit = Ladder.next_ladder()

			if alive(ladder_unit) then
				local can_access = ladder_unit:ladder():can_access(u_pos, self._move_dir)

				if can_access then
					self:_start_action_ladder(t, ladder_unit)

					break
				end
			end
		end
	end
end

function PlayerStandard:_start_action_ladder(t, ladder_unit)
	self._state_data.on_ladder = true

	self:_interupt_action_running(t)
	self._unit:mover():set_velocity(Vector3())
	self:set_gravity(0)
	self._unit:mover():jump()
	self._unit:movement():on_enter_ladder(ladder_unit)
end

function PlayerStandard:_end_action_ladder(t, input)
	if not self._state_data.on_ladder then
		return
	end

	self._state_data.on_ladder = false

	self:set_gravity(tweak_data.player.gravity)
	self._unit:movement():on_exit_ladder()
end

function PlayerStandard:_interupt_action_ladder(t, input)
	self:_end_action_ladder()
end

function PlayerStandard:on_ladder()
	return self._state_data.on_ladder
end

function PlayerStandard:_check_action_duck(t, input)
	local action_forbidden = self:_is_using_bipod() or self:_mantling()

	if action_forbidden then
		return
	end

	if self._unit:base().skip_update_one_frame then
		self._unit:base().skip_update_one_frame = false

		return
	end

	if game_state_machine:current_state_name() == "ingame_special_interaction" then
		return
	end

	if input.btn_duck_press then
		if not self._unit:base():stats_screen_visible() then
			if not self._state_data.ducking then
				self:_start_action_ducking(t)
			elseif self._state_data.ducking then
				self:_end_action_ducking(t)
			end
		end
	elseif self._setting_hold_to_duck and not input.btn_duck_state and self._state_data.ducking then
		self:_end_action_ducking(t)
	end
end

function PlayerStandard:_check_action_steelsight(t, input)
	if self._camera_unit:base():is_stance_done() and self._state_data.in_steelsight then
		local wpn_lens_distortion = self:_get_weapon_lens_distortion()

		managers.environment_controller:set_lens_distortion_power(wpn_lens_distortion)
	end

	local new_action = nil
	local action_forbidden = self:_is_comm_wheel_active()

	if not alive(self._equipped_unit) or action_forbidden then
		return new_action
	end

	if not self._ext_inventory:equipped_selection() or PlayerInventory.SLOT_2 < self._ext_inventory:equipped_selection() then
		return
	end

	if self._equipped_unit then
		local result = nil
		local weap_base = self._equipped_unit:base()

		if weap_base.manages_steelsight and weap_base:manages_steelsight() then
			if input.btn_steelsight_press and weap_base.steelsight_pressed then
				result = weap_base:steelsight_pressed()
			elseif input.btn_steelsight_release and weap_base.steelsight_released then
				result = weap_base:steelsight_released()
			end

			if result then
				if result.enter_steelsight and not self._state_data.in_steelsight then
					self:_start_action_steelsight(t)

					new_action = true
				elseif result.exit_steelsight and self._state_data.in_steelsight then
					self:_end_action_steelsight(t)

					new_action = true
				end
			end

			return new_action
		end
	end

	if managers.user:get_setting("hold_to_steelsight") and input.btn_steelsight_release then
		self._steelsight_wanted = false

		if self._state_data.in_steelsight then
			self:_end_action_steelsight(t)

			new_action = true
		end
	elseif input.btn_steelsight_press or self._steelsight_wanted then
		if self._state_data.in_steelsight then
			self:_end_action_steelsight(t)

			new_action = true
		elseif not self._state_data.in_steelsight then
			self:_start_action_steelsight(t)

			new_action = true
		end
	end

	return new_action
end

function PlayerStandard:shooting()
	return self._shooting
end

function PlayerStandard:running()
	return self._running
end

function PlayerStandard:moving()
	return self._moving
end

function PlayerStandard:ducking()
	return self._state_data and self._state_data.ducking
end

function PlayerStandard:get_zoom_fov(stance_data)
	local fov = stance_data and stance_data.FOV or 75
	local fov_multiplier = managers.user:get_setting("fov_multiplier")

	if self._state_data.in_steelsight then
		local base = self._equipped_unit:base()
		fov = base.zoom and base:zoom() or 1
		fov_multiplier = 1 + (fov_multiplier - 1) / 2
		fov_multiplier = fov_multiplier * managers.player:upgrade_value("player", "farsighted_steelsight_fov_multiplier", 1)
	end

	return fov * fov_multiplier
end

function PlayerStandard:get_sensitivity_multiplier(current_fov)
	local multiplier = 1

	if self._state_data.in_steelsight and managers.player:has_category_upgrade("player", "farsighted_steelsight_fov_multiplier") then
		multiplier = multiplier * tweak_data.upgrades.farsighted_sensitivity_multiplier
	end

	return multiplier
end

function PlayerStandard:_is_throwing_coin(t)
	if self._equipped_unit and self._state_data.throw_grenade_cooldown then
		return t - self._state_data.throw_grenade_cooldown <= self._equipped_unit:base():weapon_tweak_data().timers.equip
	else
		return false
	end
end

function PlayerStandard:_check_action_primary_attack(t, input)
	local new_action = nil

	if not self._equipped_unit then
		return
	end

	if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_4 then
		return
	end

	if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_3 then
		return
	end

	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release

	if action_wanted then
		local action_forbidden = self:_is_reloading() or self:_changing_weapon() or self:_is_meleeing() or self._use_item_expire_t or self:_interacting() or self:_is_throwing_projectile() or self:_is_deploying_bipod() or self:_is_comm_wheel_active() or self:_is_throwing_grenade() or self:_is_throwing_coin(t)

		if not action_forbidden then
			local use_recoil_anim = true
			local fire_pressed = self._queue_primary_attack_t and t < self._queue_primary_attack_t or input.btn_primary_attack_press
			self._queue_reload_interupt_t = nil

			self._ext_inventory:equip_selected_primary(false)

			local weap_base = self._equipped_unit:base()
			local fire_mode = weap_base.fire_mode and weap_base:fire_mode()

			if not fire_mode then
				return false
			end

			if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYERS_CAN_ONLY_USE_SINGLE_FIRE) then
				fire_mode = "single"
			end

			local fire_on_release = weap_base:fire_on_release()

			if weap_base.out_of_ammo and weap_base:out_of_ammo() then
				if fire_pressed then
					managers.dialog:queue_dialog("player_gen_no_ammo", {
						skip_idle_check = true,
						instigator = self._unit
					})
					managers.hud:set_prompt("hud_no_ammo_prompt", managers.localization:to_upper_text("hint_no_ammo"))

					self._queue_primary_attack_t = nil

					weap_base:dryfire()
				end
			elseif weap_base.clip_empty and weap_base:clip_empty() then
				if self:_is_using_bipod() then
					if input.btn_primary_attack_press then
						weap_base:dryfire()
					end

					self._equipped_unit:base():tweak_data_anim_stop("fire")
				elseif input.btn_primary_attack_press then
					new_action = true

					self:_start_action_reload_enter(t)
				end
			elseif self._running and not self._run_and_shoot then
				self:_interupt_action_running(t)
			else
				if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ATTACK_ONLY_IN_AIR) and not self:in_air() then
					if self._equipped_unit and (input.btn_primary_attack_press or input.btn_primary_attack_release) then
						local weap_base = self._equipped_unit:base()

						weap_base:dryfire()
					end

					self:_check_stop_shooting()

					return
				end

				if not self._shooting then
					if weap_base:start_shooting_allowed() then
						local start = fire_mode == "single" and fire_pressed
						start = start or fire_mode ~= "single" and input.btn_primary_attack_state
						start = start and not fire_on_release
						start = start or fire_on_release and input.btn_primary_attack_release

						if start then
							weap_base:start_shooting()
							self._camera_unit:base():start_shooting()

							self._shooting = true

							if fire_mode == "auto" then
								if use_recoil_anim then
									self._unit:camera():play_redirect(self.IDS_RECOIL_ENTER)
								end

								if not weap_base.akimbo and (not weap_base.third_person_important or weap_base.third_person_important and not weap_base:third_person_important()) then
									self._ext_network:send("sync_start_auto_fire_sound")
								end
							end
						end
					else
						return false
					end
				end

				local suppression_ratio = self._unit:character_damage():effective_suppression_ratio()
				local spread_mul = math.lerp(1, tweak_data.player.suppression.spread_mul, suppression_ratio)
				local autohit_mul = math.lerp(1, tweak_data.player.suppression.autohit_chance_mul, suppression_ratio)
				local suppression_mul = managers.blackmarket:threat_multiplier()
				local dmg_mul = managers.player:temporary_upgrade_value("temporary", "dmg_multiplier_outnumbered", 1)
				dmg_mul = dmg_mul * managers.player:temporary_upgrade_value("temporary", "candy_attack_damage", 1)
				local weapon_category = weap_base:category()

				if self._state_data.marshal_data then
					local multiplier = managers.player:upgrade_value(weapon_category, "marshal_stacking_damage_multiplier", 1) - 1
					dmg_mul = dmg_mul * (1 + self._state_data.marshal_data.stacks * multiplier)
				end

				local fired = nil

				if fire_mode == "single" then
					if fire_pressed then
						fired = weap_base:trigger_pressed(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
					elseif fire_on_release then
						if input.btn_primary_attack_release then
							fired = weap_base:trigger_released(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						elseif input.btn_primary_attack_state then
							weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
						end
					end
				elseif input.btn_primary_attack_state then
					fired = weap_base:trigger_held(self:get_fire_weapon_position(), self:get_fire_weapon_direction(), dmg_mul, nil, spread_mul, autohit_mul, suppression_mul)
				end

				if weap_base.manages_steelsight and weap_base:manages_steelsight() then
					if weap_base:wants_steelsight() and not self._state_data.in_steelsight then
						self:_start_action_steelsight(t)
					elseif not weap_base:wants_steelsight() and self._state_data.in_steelsight then
						self:_end_action_steelsight(t)
					end
				end

				local charging_weapon = fire_on_release and weap_base:charging()

				if not self._state_data.charging_weapon and charging_weapon then
					self:_start_action_charging_weapon(t)
				elseif self._state_data.charging_weapon and not charging_weapon then
					self:_end_action_charging_weapon(t)
				end

				new_action = true

				if fired then
					managers.rumble:play("weapon_fire")

					local wpn_spread = weap_base:spread_multiplier()

					managers.hud:set_crosshair_offset_kick(wpn_spread)

					local weap_tweak_data = tweak_data.weapon[weap_base:get_name_id()]
					local shake_multiplier = weap_tweak_data.shake[self._state_data.in_steelsight and "fire_steelsight_multiplier" or "fire_multiplier"]
					local fire_rate_multiplier = weap_base:fire_rate_multiplier()
					self._queue_primary_attack_t = nil

					self._ext_camera:play_shaker("fire_weapon_rot", 1 * shake_multiplier)
					self._ext_camera:play_shaker("fire_weapon_kick", 1 * shake_multiplier, 1, 0.15)
					self._equipped_unit:base():tweak_data_anim_stop("unequip")
					self._equipped_unit:base():tweak_data_anim_stop("equip")

					if not self._state_data.in_steelsight or not weap_base:tweak_data_anim_play("fire_steelsight", fire_rate_multiplier) then
						weap_base:tweak_data_anim_play("fire", fire_rate_multiplier)
					end

					if use_recoil_anim and fire_mode == "single" then
						if not self._state_data.in_steelsight or weap_tweak_data.animations.recoil_steelsight_weight then
							self._ext_camera:play_redirect(self.IDS_RECOIL, fire_rate_multiplier)
						elseif weap_tweak_data.animations.recoil_steelsight then
							self._ext_camera:play_redirect(self.IDS_RECOIL_STEELSIGHT)
						end

						self._delay_running_expire_t = self._equipped_unit:base():next_fire_allowed()
					end

					local recoil_multiplier = (weap_base:recoil() + weap_base:recoil_addend()) * weap_base:recoil_multiplier()
					recoil_multiplier = recoil_multiplier * managers.player:upgrade_value("player", "warcry_reduce_recoil", 1)
					recoil_multiplier = recoil_multiplier * managers.player:upgrade_value("player", "warcry_nullify_recoil", 1)

					if self._state_data.in_steelsight then
						recoil_multiplier = recoil_multiplier * managers.player:upgrade_value("player", "warcry_reduce_recoil_steelsight", 1)
					else
						recoil_multiplier = recoil_multiplier * managers.player:upgrade_value("player", "warcry_reduce_recoil_hipfire", 1)
					end

					local up, down, left, right = unpack(weap_tweak_data.kick[self._state_data.in_steelsight and self._state_data.ducking and "crouching_steelsight" or self._state_data.in_steelsight and "steelsight" or self._state_data.ducking and "crouching" or "standing"])

					self._camera_unit:base():recoil_kick(up, down, left, right, recoil_multiplier)

					if self._state_data.marshal_data and managers.player:has_category_upgrade(weapon_category, "marshal_stacking_damage_multiplier") then
						self:_marshal_change_stacks(fired.hit_enemy and 1 or -1)
					end

					if weap_base.set_recharge_clbk then
						weap_base:set_recharge_clbk(callback(self, self, "weapon_recharge_clbk_listener"))
					end

					managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())

					local impact = not fired.hit_enemy

					self._ext_network:send("shot_blank", impact)
				elseif fire_mode == "single" then
					new_action = false
				end
			end
		elseif self:_is_reloading() and self._equipped_unit:base():reload_interuptable() and input.btn_primary_attack_press then
			self._queue_reload_interupt_t = t + tweak_data.player.reload_interupt_buffer
		end
	end

	if not new_action then
		self:_check_stop_shooting()
	end

	return new_action
end

function PlayerStandard:_check_stop_shooting()
	if self._shooting then
		self._ext_network:send("sync_stop_auto_fire_sound")
		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting(self._equipped_unit:base():recoil_wait())

		local weap_base = self._equipped_unit:base()

		if weap_base._name_id == "dp28" then
			weap_base:weapon_parts_anim_pause()
		end

		local fire_mode = weap_base:fire_mode()
		local use_recoil_anim = true

		if use_recoil_anim and fire_mode == "auto" and not self:_is_reloading() and not self:_is_meleeing() then
			self._unit:camera():play_redirect(self.IDS_RECOIL_EXIT)
		end

		self._shooting = false
	end
end

function PlayerStandard:_start_action_charging_weapon(t)
	self._state_data.charging_weapon = true
	self._state_data.charging_weapon_data = {
		t = t,
		max_t = 2.5
	}
	local ANIM_LENGTH = 1.5
	local max = self._equipped_unit:base():charge_max_t()
	local speed_multiplier = ANIM_LENGTH / max

	self._equipped_unit:base():tweak_data_anim_play("charge", speed_multiplier)
	self._ext_camera:play_redirect(self.IDS_CHARGE, speed_multiplier)
end

function PlayerStandard:_interupt_action_charging_weapon(t)
	if not self._state_data.charging_weapon then
		return
	end

	self._equipped_unit:base():interupt_charging()
	self:_end_action_charging_weapon(t)
end

function PlayerStandard:_end_action_charging_weapon(t)
	self._state_data.charging_weapon = nil

	self._equipped_unit:base():tweak_data_anim_stop("charge")
	self._ext_camera:play_redirect(self.IDS_IDLE)
end

function PlayerStandard:_is_charging_weapon()
	return self._state_data.charging_weapon
end

function PlayerStandard:_update_charging_weapon_timers(t, dt)
	if not self._state_data.charging_weapon then
		return
	end
end

function PlayerStandard:_start_action_reload_enter(t)
	if self._equipped_unit:base():can_reload() then
		self:_interupt_action_steelsight(t)

		if not self._run_and_reload then
			self:_interupt_action_running(t)
		end

		self._delay_running_expire_t = nil

		self._equipped_unit:base():tweak_data_anim_stop("fire")

		if self._equipped_unit:base():use_shotgun_reload() then
			local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()

			self._ext_camera:play_redirect(Idstring("reload_enter_" .. self._equipped_unit:base().name_id), speed_multiplier)

			self._state_data.reload_enter_expire_t = t + self._equipped_unit:base():reload_enter_expire_t() / speed_multiplier

			self._equipped_unit:base():tweak_data_anim_play("reload_enter", speed_multiplier)
		else
			self:_start_action_reload(t)
		end
	end
end

function PlayerStandard:_start_action_reload(t)
	if self._equipped_unit:base():can_reload() then
		managers.hud:hide_prompt("hud_reload_prompt")
		managers.dialog:queue_dialog("player_reloading", {
			skip_idle_check = true,
			instigator = self._unit
		})

		local weap_base = self._equipped_unit:base()

		weap_base:tweak_data_anim_stop("fire")

		local speed_multiplier = weap_base:reload_speed_multiplier()
		local weapon_category = weap_base:category()

		if self._state_data.marshal_data then
			local multiplier = managers.player:upgrade_value(weapon_category, "marshal_stacking_reload_speed_multiplier", 1) - 1
			speed_multiplier = speed_multiplier * (1 + self._state_data.marshal_data.stacks * multiplier)
		end

		local tweak_data = weap_base:weapon_tweak_data()
		local reload_anim = "reload"
		local reload_name_id = tweak_data.animations.reload_name_id or weap_base.name_id

		if weap_base:clip_empty() then
			local result = weap_base:use_shotgun_reload() or self._ext_camera:play_redirect(Idstring("reload_" .. reload_name_id), speed_multiplier)
			local expire_t = weap_base:use_shotgun_reload() and weap_base:reload_expire_t() or tweak_data.timers.reload_empty or 2.6
			self._state_data.reload_expire_t = t + expire_t / speed_multiplier
		else
			reload_anim = "reload_not_empty"
			local result = weap_base:use_shotgun_reload() or self._ext_camera:play_redirect(Idstring("reload_not_empty_" .. reload_name_id), speed_multiplier)
			local expire_t = weap_base:use_shotgun_reload() and weap_base:reload_expire_t() or tweak_data.timers.reload_not_empty or 2.2
			self._state_data.reload_expire_t = t + expire_t / speed_multiplier
		end

		weap_base:start_reload()

		if not weap_base:use_shotgun_reload() and not weap_base:tweak_data_anim_play(reload_anim, speed_multiplier) then
			weap_base:tweak_data_anim_play("reload", speed_multiplier)
		end

		self._ext_network:send("reload_weapon")
	end
end

function PlayerStandard:_interupt_action_reload(t)
	if alive(self._equipped_unit) then
		if self._equipped_unit:base().check_bullet_objects then
			self._equipped_unit:base():check_bullet_objects()
		end

		if self:_is_reloading() then
			self._equipped_unit:base():tweak_data_anim_stop("reload_enter")
			self._equipped_unit:base():tweak_data_anim_stop("reload")
			self._equipped_unit:base():tweak_data_anim_stop("reload_not_empty")
			self._equipped_unit:base():tweak_data_anim_stop("reload_exit")
		end

		if self._equipped_unit:base().can_reload and self._equipped_unit:base():can_reload() and self._equipped_unit:base().clip_empty and self._equipped_unit:base():clip_empty() then
			managers.hud:set_prompt("hud_reload_prompt", managers.localization:to_upper_text("hint_reload"))
		end
	end

	self._queue_reload_interupt_t = nil
	self._state_data.reload_enter_expire_t = nil
	self._state_data.reload_expire_t = nil
	self._state_data.reload_exit_expire_t = nil
end

function PlayerStandard:_is_reloading()
	return self._state_data.reload_expire_t or self._state_data.reload_enter_expire_t or self._state_data.reload_exit_expire_t
end

function PlayerStandard:_is_comm_wheel_active()
	return managers.hud:is_comm_wheel_visible() or managers.hud:is_carry_wheel_visible()
end

function PlayerStandard:start_deploying_bipod(bipod_deploy_duration)
	self._deploy_bipod_expire_t = managers.player:player_timer():time() + bipod_deploy_duration
end

function PlayerStandard:_is_deploying_bipod()
	local deploying = false

	if self._deploy_bipod_expire_t and managers.player:player_timer():time() < self._deploy_bipod_expire_t then
		deploying = true
	end

	return deploying
end

function PlayerStandard:_is_using_bipod()
	return self._state_data.using_bipod
end

function PlayerStandard:_get_swap_speed_multiplier()
	local multiplier = 1
	multiplier = multiplier * managers.player:upgrade_value("weapon", "swap_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value("player", "fasthand_swap_speed_multiplier", 1)
	multiplier = multiplier * managers.player:upgrade_value(self._equipped_unit:base():category(), "swap_speed_multiplier", 1)

	return multiplier
end

function PlayerStandard:force_change_weapon_slot(slot, instant)
	local tbl = {
		selection_wanted = slot
	}

	if instant then
		self._change_weapon_data = tbl

		self:_start_action_equip_weapon(managers.player:player_timer():time())
	else
		self:_start_action_unequip_weapon(managers.player:player_timer():time(), tbl)
	end
end

function PlayerStandard:_start_action_unequip_weapon(t, data)
	if not self._unequip_weapon_expire_t then
		local speed_multiplier = self:_get_swap_speed_multiplier()
		local weapon_tweak = self._equipped_unit:base():weapon_tweak_data()
		self._unequip_weapon_expire_t = t + (weapon_tweak.timers.unequip or 0.5) / speed_multiplier + (data.delay or 0)
		self._delay_running_expire_t = self._unequip_weapon_expire_t + tweak_data.player.run_delay.equip

		self._equipped_unit:base():tweak_data_anim_stop("fire")
		self._equipped_unit:base():tweak_data_anim_stop("equip")
		self._equipped_unit:base():tweak_data_anim_play("unequip", speed_multiplier)

		local result = self._ext_camera:play_redirect(self.IDS_UNEQUIP, speed_multiplier)

		self:_interupt_action_charging_weapon(t)
		self:_interupt_action_reload(t)
		self:_interupt_action_steelsight(t)
		managers.hud:set_crosshair_fade(false)
	end

	if data and data.selection_wanted then
		managers.hud:set_weapon_selected_by_inventory_index(data.selection_wanted)
	end

	self._change_weapon_data = data
end

function PlayerStandard:_start_action_equip_weapon(t)
	if not self._change_weapon_data then
		if self._ext_inventory:equipped_selection() == 2 then
			self._ext_inventory:equip_selection(1, false)
		else
			self._ext_inventory:equip_selection(2, false)
		end
	elseif self._change_weapon_data.selection_wanted then
		self._ext_inventory:equip_selection(self._change_weapon_data.selection_wanted, false)
	end

	self:_start_action_equip()
	managers.upgrades:setup_current_weapon()
	managers.player:refresh_carry_elements()

	if self._equipped_unit:base().out_of_ammo and self._equipped_unit:base():out_of_ammo() then
		managers.hud:set_prompt("hud_no_ammo_prompt", managers.localization:to_upper_text("hint_no_ammo"))
	elseif self._equipped_unit:base().can_reload and self._equipped_unit:base():can_reload() and self._equipped_unit:base().clip_empty and self._equipped_unit:base():clip_empty() then
		managers.hud:set_prompt("hud_reload_prompt", managers.localization:to_upper_text("hint_reload"))
	else
		managers.hud:hide_prompt("hud_reload_prompt")
		managers.hud:hide_prompt("hud_no_ammo_prompt")
	end

	if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_3 then
		self._unit:inventory():show_equipped_unit()
	end
end

function PlayerStandard:_changing_weapon()
	return self._unequip_weapon_expire_t or self._equip_weapon_expire_t
end

function PlayerStandard:_upd_attention()
	local preset = nil

	if false and self._seat and self._seat.driving then
		-- Nothing
	elseif managers.groupai:state():whisper_mode() then
		if self._running then
			preset = {
				"pl_mask_on_friend_combatant_whisper_mode",
				"pl_mask_on_friend_non_combatant_whisper_mode",
				"pl_mask_on_foe_combatant_whisper_mode_run",
				"pl_mask_on_foe_non_combatant_whisper_mode_run"
			}
		elseif self._state_data.ducking then
			preset = {
				"pl_mask_on_friend_combatant_whisper_mode",
				"pl_mask_on_friend_non_combatant_whisper_mode",
				"pl_mask_on_foe_combatant_whisper_mode_crouch",
				"pl_mask_on_foe_non_combatant_whisper_mode_crouch"
			}
		else
			preset = {
				"pl_mask_on_friend_combatant_whisper_mode",
				"pl_mask_on_friend_non_combatant_whisper_mode",
				"pl_mask_on_foe_combatant_whisper_mode_stand",
				"pl_mask_on_foe_non_combatant_whisper_mode_stand"
			}
		end
	elseif self._state_data.ducking then
		preset = {
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt",
			"pl_foe_combatant_cbt_crouch",
			"pl_foe_non_combatant_cbt_crouch"
		}
	else
		preset = {
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt",
			"pl_foe_combatant_cbt_stand",
			"pl_foe_non_combatant_cbt_stand"
		}
	end

	self._ext_movement:set_attention_settings(preset)
end

function PlayerStandard:push(vel)
	if self._unit:mover() then
		self._last_velocity_xy = self._last_velocity_xy + vel

		self._unit:mover():set_velocity(self._last_velocity_xy)
	end

	self:_interupt_action_running(managers.player:player_timer():time())
end

function PlayerStandard:set_gravity(gravity)
	self._unit:mover():set_gravity(math.DOWN * gravity)
end

function PlayerStandard:_get_dir_str_from_vec(fwd, dir_vec)
	local att_dir_spin = dir_vec:to_polar_with_reference(fwd, math.UP).spin
	local abs_spin = math.abs(att_dir_spin)

	if abs_spin < 45 then
		return "fwd"
	elseif abs_spin > 135 then
		return "bwd"
	elseif att_dir_spin < 0 then
		return "right"
	else
		return "left"
	end
end

function PlayerStandard:inventory_clbk_listener(unit, event)
	if event == "equip" then
		local weapon = self._ext_inventory:equipped_unit()

		if self._weapon_hold then
			self._camera_unit:anim_state_machine():set_global(self._weapon_hold, 0)
		end

		self._weapon_hold = weapon:base().weapon_hold and weapon:base():weapon_hold() or weapon:base():get_name_id()

		self._camera_unit:anim_state_machine():set_global(self._weapon_hold, 1)

		self._equipped_unit = weapon

		weapon:base():on_equip()

		local index = self._ext_inventory:equipped_selection()

		managers.hud:set_weapon_selected_by_inventory_index(index)

		for id, weapon in pairs(self._ext_inventory:available_selections()) do
			managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
		end

		self:_stance_entered()
	end
end

function PlayerStandard:weapon_recharge_clbk_listener()
	for id, weapon in pairs(self._ext_inventory:available_selections()) do
		managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
	end
end

function PlayerStandard:save(data)
	if self._state_data.ducking then
		data.pose = 2
	else
		data.pose = 1
	end
end

function PlayerStandard:pre_destroy()
	if self._pos_reservation then
		managers.navigation:unreserve_pos(self._pos_reservation)

		self._pos_reservation = nil

		managers.navigation:unreserve_pos(self._pos_reservation_slow)

		self._pos_reservation_slow = nil
	end

	managers.environment_effects:stop("speed_lines")
end

function PlayerStandard:tweak_data_clbk_reload()
	self:set_class_tweak_data(managers.skilltree:has_character_profile_class() and managers.skilltree:get_character_profile_class())
end

function PlayerStandard:set_class_tweak_data(class)
	self._player_class = class
	self._tweak_data = tweak_data.player:get_tweak_data_for_class(self._player_class)
end

function PlayerStandard:setup_upgrades()
	self._run_and_shoot = managers.player:has_category_upgrade("player", "run_and_shoot", false)
	self._run_and_reload = managers.player:has_category_upgrade("player", "agile_run_and_reload", false)
	self._can_free_run = managers.player:has_category_upgrade("player", "fitness_can_free_run", false)
	self._high_dive = managers.player:has_category_upgrade("player", "high_dive_ground_slam", false)
	self._melee_and_run = managers.player:has_category_upgrade("player", "do_die_melee_running_charge", false)

	if managers.player:has_category_upgrade("player", "marshal_max_multiplier_stacks") then
		self._state_data.marshal_data = self._state_data.marshal_data or {
			stacks = 0,
			max_stacks = managers.player:upgrade_value("player", "marshal_max_multiplier_stacks", 1),
			decay_time = managers.player:upgrade_value("player", "marshal_stack_decay_timer", 1)
		}
	else
		managers.queued_tasks:unqueue("upgrade_marshal_stack_decay")

		self._state_data.marshal_data = nil
	end
end

function PlayerStandard:_marshal_change_stacks(change)
	if not self._state_data.marshal_data then
		return
	end

	managers.queued_tasks:unqueue("upgrade_marshal_stack_decay")

	self._state_data.marshal_data.stacks = math.clamp(self._state_data.marshal_data.stacks + change, 0, self._state_data.marshal_data.max_stacks)

	if self._state_data.marshal_data.stacks > 0 then
		managers.queued_tasks:queue("upgrade_marshal_stack_decay", self._marshal_change_stacks, self, -1, self._state_data.marshal_data.decay_time)
	end

	Application:trace("[PlayerStandard:_marshal_change_stacks] current stacks:", self._state_data.marshal_data.stacks)
end

function PlayerStandard:_get_melee_weapon()
	if self._ext_inventory:equipped_selection() == PlayerInventory.SLOT_4 then
		return managers.blackmarket:equipped_melee_weapon()
	end

	return "weapon"
end

function PlayerStandard:call_teammate(line, t, no_gesture, skip_alert, skip_mark_cop)
	local voice_type, plural, prime_target = self:_get_unit_intimidation_action(true, false, true, true, false)
	local interact_type, queue_name = nil

	if voice_type == "come" then
		interact_type = "cmd_come"
		local character_code = managers.criminals:character_static_data_by_unit(prime_target.unit).ssuffix
	elseif voice_type == "mark_cop" and not skip_mark_cop then
		local shout_tweak_data = tweak_data.character[prime_target.unit:base()._tweak_table]
		local shout_sound = shout_tweak_data.priority_shout

		if managers.groupai:state():whisper_mode() then
			shout_sound = tweak_data.character[prime_target.unit:base()._tweak_table].silent_priority_shout or shout_sound
		end

		if shout_sound then
			interact_type = "cmd_point"

			if managers.player:has_category_upgrade("player", "special_enemy_highlight") then
				prime_target.unit:contour():add(managers.player:has_category_upgrade("player", "marked_enemy_extra_damage") and "mark_enemy_damage_bonus" or "mark_enemy", true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
			end
		end
	end

	if interact_type then
		self:_do_action_intimidate(t, not no_gesture and interact_type or nil, queue_name, nil, skip_alert)

		return true
	end
end
