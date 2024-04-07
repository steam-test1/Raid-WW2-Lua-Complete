PlayerMoveObject = PlayerMoveObject or class(PlayerStandard)
PlayerMoveObject.target_tilt = -5

function PlayerMoveObject:init(unit)
	PlayerMoveObject.super.init(self, unit)
end

function PlayerMoveObject:enter(state_data, enter_data)
	PlayerMoveObject.super.enter(self, state_data, enter_data)

	local move_object_data = managers.player:get_move_object_data()

	self._moving_unit = move_object_data.moving_unit
	self._moving_body = self._moving_unit:body(0)
	self._player_align_points = self._moving_unit:get_objects("player_align_0*")

	Application:trace("PlayerMoveObject:enter: ", inspect(move_object_data))

	for _, obj in pairs(self._moving_unit:get_objects("player_align_0*")) do
		Application:trace("PlayerMoveObject:enter: ", inspect(obj))
	end
end

function PlayerMoveObject:_enter(enter_data)
	return
end

function PlayerMoveObject:exit(state_data, new_state_name)
	PlayerMoveObject.super.exit(self, state_data, new_state_name)
	self._unit:camera():camera_unit():base():set_target_tilt(0)
end

function PlayerMoveObject:update(t, dt)
	PlayerMoveObject.super.update(self, t, dt)

	if self._normal_move_dir then
		local player_speed = self:_get_max_walk_speed(t)

		Application:trace("PlayerMoveObject:update: ", inspect(self._normal_move_dir), inspect(player_speed), inspect(self._moving_unit:mass()))
		self._moving_body:set_dynamic()
		self._moving_unit:set_driving("script")
		self._moving_body:set_velocity(self._normal_move_dir * player_speed)
	end
end

function PlayerMoveObject:set_tweak_data(name)
	self._tweak_data_name = name
end

function PlayerMoveObject:_update_check_actions(t, dt)
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
	self:_update_steelsight_timers(t, dt)
	self:_update_foley(t, input)

	local new_action

	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	new_action = new_action or self:_check_action_equip(t, input)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)
		self._shooting = new_action
	end

	if not new_action then
		local projectile_entry = managers.blackmarket:equipped_projectile()

		if tweak_data.projectiles[projectile_entry].is_a_grenade then
			new_action = self:_check_action_throw_grenade(t, input)
		else
			new_action = self:_check_action_throw_projectile(t, input)
		end
	end

	self:_check_action_interact(t, input)
	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)
	self:_check_action_deploy_bipod(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_steelsight(t, input)
	self:_check_use_item(t, input)
	self:_check_comm_wheel(t, input)
	self:_check_stats_screen(t, dt, input)
end

function PlayerMoveObject:_check_action_run(...)
	return
end

function PlayerMoveObject:_check_action_interact(t, input)
	local new_action, timer, interact_object
	local interaction_wanted = input.btn_interact_press

	if interaction_wanted then
		managers.player:set_player_state("standard")

		return
	end
end

function PlayerMoveObject:_check_change_weapon(...)
	return PlayerMoveObject.super._check_change_weapon(self, ...)
end

function PlayerMoveObject:_check_action_equip(...)
	return PlayerMoveObject.super._check_action_equip(self, ...)
end

function PlayerMoveObject:_update_movement(t, dt)
	PlayerMoveObject.super._update_movement(self, t, dt)
end

function PlayerMoveObject:_start_action_jump(...)
	PlayerMoveObject.super._start_action_jump(self, ...)
end

function PlayerMoveObject:_perform_jump(jump_vec)
	PlayerMoveObject.super._perform_jump(self, jump_vec)
end

function PlayerMoveObject:_get_max_walk_speed(...)
	local multiplier = 0.5

	return PlayerMoveObject.super._get_max_walk_speed(self, ...) * multiplier
end

function PlayerMoveObject:_get_walk_headbob(...)
	local multiplier = 0.5

	return PlayerMoveObject.super._get_walk_headbob(self, ...) * multiplier
end

function PlayerMoveObject:pre_destroy(unit)
	return
end

function PlayerMoveObject:destroy()
	return
end
