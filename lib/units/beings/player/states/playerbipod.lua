PlayerBipod = PlayerBipod or class(PlayerStandard)
PlayerBipod.target_tilt = -5
PlayerBipod._shoulder_pos = nil
PlayerBipod._camera_pos = nil

-- Lines 6-9
function PlayerBipod:init(unit)
	PlayerBipod.super.init(self, unit)
end

-- Lines 13-16
function PlayerBipod:set_camera_positions(bipod_pos, camera_pos)
	self._shoulder_pos = Vector3(bipod_pos.x, bipod_pos.y, bipod_pos.z)
	self._camera_pos = Vector3(camera_pos.x, camera_pos.y, camera_pos.z)
end

-- Lines 18-20
function PlayerBipod:enter(state_data, enter_data)
	PlayerBipod.super.enter(self, state_data, enter_data)
end

-- Lines 24-68
function PlayerBipod:_enter(enter_data)
	local player = managers.player:player_unit()

	if player and self._unit:base().is_local_player then
		local tweak_data = self._equipped_unit:base():weapon_tweak_data()
		local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()
		local reload_name_id = tweak_data.animations.reload_name_id or self._equipped_unit:base().name_id
		local equipped_unit_id = self._equipped_unit:base().name_id
		self._unit_deploy_position = player:position()

		self._unit:camera():camera_unit():base():set_limits(tweak_data.bipod_camera_spin_limit, tweak_data.bipod_camera_pitch_limit)
		PlayerBipod.super:start_deploying_bipod(tweak_data.timers.deploy_bipod)
		self._equipped_unit:base():tweak_data_anim_stop("undeploy")

		local result = self._ext_camera:play_redirect(Idstring(tweak_data.animations.bipod_enter .. "_" .. equipped_unit_id), speed_multiplier)
		local result_deploy = self._equipped_unit:base():tweak_data_anim_play("deploy", speed_multiplier)
		self._headbob = 0
		self._target_headbob = 0

		self._ext_camera:set_shaker_parameter("headbob", "amplitude", 0)

		PlayerStandard.IDS_RECOIL = Idstring(tweak_data.animations.bipod_recoil .. "_" .. equipped_unit_id)
		PlayerStandard.IDS_RECOIL_ENTER = Idstring(tweak_data.animations.bipod_recoil_enter .. "_" .. equipped_unit_id)
		PlayerStandard.IDS_RECOIL_LOOP = Idstring(tweak_data.animations.bipod_recoil_loop .. "_" .. equipped_unit_id)
		PlayerStandard.IDS_RECOIL_EXIT = Idstring(tweak_data.animations.bipod_recoil_exit .. "_" .. equipped_unit_id)

		self._unit:sound_source():post_event("wp_steady_in")
		self:_stance_entered()
		self:_husk_bipod_data()
	end
end

-- Lines 72-107
function PlayerBipod:exit(state_data, new_state_name)
	PlayerBipod.super.exit(self, state_data or self._state_data, new_state_name)

	local tweak_data = self._equipped_unit:base():weapon_tweak_data()
	local speed_multiplier = self._equipped_unit:base():reload_speed_multiplier()
	local equipped_unit_id = self._equipped_unit:base().name_id

	self._equipped_unit:base():tweak_data_anim_stop("deploy")

	local result = self._ext_camera:play_redirect(Idstring(tweak_data.animations.bipod_exit .. "_" .. equipped_unit_id), speed_multiplier)
	local result_deploy = self._equipped_unit:base():tweak_data_anim_play("undeploy", speed_multiplier)

	self._unit:camera():camera_unit():base():set_target_tilt(0)
	self._unit:camera():camera_unit():base():remove_limits()

	self._unit:camera():camera_unit():base().bipod_location = nil
	local exit_data = {
		skip_equip = true
	}
	self._dye_risk = nil
	PlayerStandard.IDS_RECOIL = Idstring("recoil")
	PlayerStandard.IDS_RECOIL_ENTER = Idstring("recoil_enter")
	PlayerStandard.IDS_RECOIL_LOOP = Idstring("recoil_loop")
	PlayerStandard.IDS_RECOIL_EXIT = Idstring("recoil_exit")

	self._unit:sound_source():post_event("wp_steady_out")

	local peer_id = managers.network:session():peer_by_unit(self._unit):id()

	managers.player:set_bipod_data_for_peer({
		peer_id = peer_id
	})

	return exit_data
end

-- Lines 111-131
function PlayerBipod:_husk_bipod_data()
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local weapon = self._unit:inventory():equipped_unit()
	local bipod_obj = weapon:get_object(Idstring("a_bp"))
	local bipod_pos = nil

	if bipod_obj then
		bipod_pos = bipod_obj:position()

		Application:trace("Getting bipod obj: ", bipod_pos)
	else
		Application:trace("Missing bipod obj: ", bipod_pos)
	end

	local body_pos = Vector3(self._m_pos.x, self._m_pos.y, self._m_pos.z)

	managers.player:set_bipod_data_for_peer({
		peer_id = peer_id,
		bipod_pos = bipod_pos,
		body_pos = body_pos
	})
	managers.network:session():send_to_peers_synched("sync_bipod", bipod_pos, body_pos)
end

-- Lines 136-150
function PlayerBipod:update(t, dt)
	PlayerBipod.super.update(self, t, dt)

	local deploy_valid = self._equipped_unit:base():is_bipod_usable()
	local movement_distance = (self._unit_deploy_position - managers.player:player_unit():position()):length()

	if not managers.player:player_unit():mover():standing() or movement_distance > 10 or not deploy_valid then
		self:exit(nil, "standard")
		managers.player:set_player_state("standard")
	end
end

-- Lines 152-155
function PlayerBipod:set_tweak_data(name)
end

-- Lines 162-245
function PlayerBipod:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.projectiles[projectile_entry].is_a_grenade then
		self:_update_throw_grenade_timers(t, input)
	else
		self:_update_throw_projectile_timers(t, input)
	end

	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)
	self:_check_stats_screen(t, dt, input)
	self:_update_foley(t, input)

	local new_action = false
	new_action = self:_check_action_reload(t, input)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)
		self._shooting = new_action
	end

	new_action = new_action or self:_check_action_jump(t, input)
	new_action = new_action or self:_check_action_run(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	new_action = new_action or self:_check_action_unmount_bipod(t, input)

	if not new_action then
		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.projectiles[projectile_entry].is_a_grenade then
			self:_check_action_throw_grenade(t, input)
		else
			self:_check_action_throw_projectile(t, input)
		end
	end

	self:_check_action_steelsight(t, input)
	self:_check_use_item(t, input)
end

-- Lines 247-249
function PlayerBipod:interaction_blocked()
	return true
end

-- Lines 251-252
function PlayerBipod:_check_step(t)
end

-- Lines 254-269
function PlayerBipod:_check_action_reload(t, input)
	local new_action = nil
	local action_wanted = input.btn_reload_press

	if action_wanted and self._equipped_unit and not self._equipped_unit:base():clip_full() then
		self:exit(nil, "standard")
		managers.player:set_player_state("standard")
		self:_start_action_reload_enter(t)

		new_action = true
	end

	return new_action
end

-- Lines 273-279
function PlayerBipod:_check_action_unmount_bipod(t, input)
	if not input.btn_deploy_bipod then
		return false
	end

	self:_unmount_bipod()

	return true
end

-- Lines 281-290
function PlayerBipod:_unmount_bipod()
	local weapon = self._equipped_unit:base()
	local bipod_part = managers.weapon_factory:get_parts_from_weapon_by_perk("bipod", weapon._parts)

	if bipod_part and bipod_part[1] then
		local bipod_unit = bipod_part[1].unit:base()

		bipod_unit:_unmount()
		self:exit(nil, "standard")
		managers.player:set_player_state("standard")
	end
end

-- Lines 294-305
function PlayerBipod:_check_action_jump(t, input)
	if input.btn_jump_press then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_check_action_jump(t, input)
		end

		return true
	end

	return false
end

-- Lines 307-319
function PlayerBipod:_check_action_run(t, input)
	local move = self._controller:get_input_axis("move")

	if input.btn_run_state and move.y > 0.1 then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_start_action_running(t)
		end

		return true
	end

	return false
end

-- Lines 321-332
function PlayerBipod:_check_change_weapon(t, input)
	if input.btn_switch_weapon_press or input.btn_primary_choice == 1 then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_check_change_weapon(t, input)
			current_state:_check_action_equip(t, input)
		end

		return true
	end

	return false
end

-- Lines 334-344
function PlayerBipod:_check_use_item(t, input)
	if input.btn_use_item_press then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_check_use_item(t, input)
		end

		return true
	end

	return false
end

-- Lines 346-358
function PlayerBipod:_check_action_throw_grenade(t, input)
	local action_forbidden = not PlayerBase.USE_GRENADES or self._unit:base():stats_screen_visible()

	if input.btn_throw_grenade_press and managers.player:can_throw_grenade() and not action_forbidden then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_start_action_throw_grenade(t, input)
		end

		return true
	end

	return false
end

-- Lines 360-372
function PlayerBipod:_check_action_throw_projectile(t, input)
	local action_forbidden = not PlayerBase.USE_GRENADES or not managers.player:can_throw_grenade() or not self:_projectile_repeat_allowed()

	if input.btn_projectile_press and not action_forbidden then
		self:_unmount_bipod()

		local current_state = managers.player:get_current_state()

		if current_state then
			current_state:_start_action_throw_projectile(t, input)
		end

		return true
	end

	return false
end

-- Lines 374-391
function PlayerBipod:_check_action_equip(t, input)
	local new_action = nil
	local selection_wanted = input.btn_primary_choice

	if selection_wanted then
		local action_forbidden = self:chk_action_forbidden("equip")
		action_forbidden = action_forbidden or not self._ext_inventory:is_selection_available(selection_wanted) or self._use_item_expire_t or self:_changing_weapon()

		if not action_forbidden then
			local new_action = not self._ext_inventory:is_equipped(selection_wanted)

			if new_action then
				self:_unmount_bipod()
			end
		end
	end

	return new_action
end

-- Lines 393-394
function PlayerBipod:_check_action_steelsight(t, input)
end

-- Lines 398-399
function PlayerBipod:_update_movement(t, dt)
end

-- Lines 403-404
function PlayerBipod:_start_action_jump(...)
end

-- Lines 406-407
function PlayerBipod:_perform_jump(jump_vec)
end

-- Lines 411-412
function PlayerBipod:_get_max_walk_speed(...)
end

-- Lines 414-416
function PlayerBipod:_get_walk_headbob(...)
	return 0
end

-- Lines 420-422
function PlayerBipod:pre_destroy(unit)
end

-- Lines 426-428
function PlayerBipod:destroy()
end
