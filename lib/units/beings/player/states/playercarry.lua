PlayerCarry = PlayerCarry or class(PlayerStandard)
PlayerCarry.WHEEL_OPEN_TIME = 0.15
PlayerCarry.target_tilt = -5

function PlayerCarry:init(unit)
	PlayerCarry.super.init(self, unit)
end

function PlayerCarry:enter(state_data, enter_data)
	PlayerCarry.super.enter(self, state_data, enter_data)
	self:update_tilt()
end

function PlayerCarry:_enter(enter_data)
	if managers.player:is_carrying() then
		local my_carry_data = managers.player:get_my_carry_data()
		local carry_item = tweak_data.carry[my_carry_data[1].carry_id]
		self._tweak_data_name = carry_item.type
	else
		self._tweak_data_name = "normal"
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

	if not self._state_data.ducking then
		self._ext_movement:set_attention_settings({
			"pl_friend_combatant_cbt",
			"pl_friend_non_combatant_cbt",
			"pl_foe_combatant_cbt_stand",
			"pl_foe_non_combatant_cbt_stand"
		})
	end

	self._carry_cant_stack = managers.player:is_carrying_cannot_stack()

	managers.raid_job:set_memory("kill_count_carry", nil, true)
	managers.raid_job:set_memory("kill_count_no_carry", nil, true)
end

function PlayerCarry:exit(state_data, new_state_name)
	PlayerCarry.super.exit(self, state_data, new_state_name)
	self._camera_unit:base():set_target_tilt(0)

	local exit_data = {
		skip_equip = true,
		equip_weapon_expire_t = self._equip_weapon_expire_t,
		unequip_weapon_expire_t = self._unequip_weapon_expire_t,
		change_weapon_data = self._change_weapon_data
	}
	self._carry_cant_stack = nil

	managers.raid_job:set_memory("kill_count_carry", nil, true)
	managers.raid_job:set_memory("kill_count_no_carry", nil, true)

	return exit_data
end

function PlayerCarry:update(t, dt)
	PlayerCarry.super.update(self, t, dt)
end

function PlayerCarry:_update_check_actions(t, dt)
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
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_mantle_timers(t, dt)
	self:_update_zipline_timers(t, dt)
	self:_update_steelsight_timers(t, dt)
	self:_update_foley(t, input)

	local new_action = nil
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	new_action = new_action or self:_check_action_next_weapon(t, input)
	new_action = new_action or self:_check_action_previous_weapon(t, input)
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

	local warcry_action = self:_check_action_warcry(t, input)

	self:_check_action_interact(t, input)
	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)
	self:_check_action_deploy_bipod(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_steelsight(t, input)

	if not warcry_action then
		self:_check_use_item(t, input)
	end

	self:_check_comm_wheel(t, input)
	self:_check_stats_screen(t, dt, input)
end

function PlayerCarry:_check_action_run(t, input)
	local ratio = managers.player:get_my_carry_weight_ratio()
	local can_run_value = tweak_data.carry.types[self._tweak_data_name].can_run
	local can_run = nil
	can_run = managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN) and true or type(can_run_value) == "boolean" and can_run_value or ratio <= tweak_data.carry.types[self._tweak_data_name].can_run

	if can_run then
		PlayerCarry.super._check_action_run(self, t, input)
	elseif input.btn_run_press then
		managers.notification:add_notification({
			duration = 2,
			shelf_life = 5,
			id = "hint_cant_run",
			text = managers.localization:text("hint_cant_run")
		})
	end
end

function PlayerCarry:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_release

	if input.btn_use_item_press then
		self._wheel_expire_t = t + PlayerCarry.WHEEL_OPEN_TIME
		self._input_down = true
	end

	if not self._input_down then
		return
	end

	if action_wanted then
		if self._wheel_open then
			managers.hud:hide_carry_wheel()

			self._wheel_open = false
		else
			local expire_t = self._use_item_expire_t or self:_changing_weapon()
			local not_expired = expire_t and t < expire_t
			local action_forbidden = not_expired or self._wheel_open or self:_interacting() or self._ext_movement:has_carry_restriction() or self:_is_throwing_projectile() or self:_on_zipline()

			if not action_forbidden then
				Application:debug("[PlayerCarry:_check_use_item] drop carry")
				managers.player:drop_carry(nil, nil)

				new_action = true
			end
		end

		self._input_down = false
		self._wheel_expire_t = nil
	elseif self._wheel_expire_t and self._wheel_expire_t < t then
		local action_forbidden = self:_is_comm_wheel_active() or self:_interacting() or self:_on_zipline() or managers.player:current_state() == "bleed_out" or managers.player:is_carrying_cannot_stack()

		if not action_forbidden then
			managers.hud:show_carry_wheel()

			self._wheel_open = true
		end

		self._wheel_expire_t = nil
	end

	return new_action
end

function PlayerCarry:_perform_jump(jump_vec)
	if not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN) then
		local ratio = managers.player:get_my_carry_weight_ratio()
		local jump_modifier = tweak_data.carry:get_type_value_weighted(self._tweak_data_name, "jump_modifier", ratio)

		mvector3.multiply(jump_vec, jump_modifier)
	end

	PlayerCarry.super._perform_jump(self, jump_vec)
end

function PlayerCarry:inventory_clbk_listener(unit, event)
	if event == "equip" then
		managers.hud:hide_carry_wheel(true)

		self._wheel_open = false
		self._input_down = false
		self._wheel_expire_t = nil
	end

	PlayerCarry.super.inventory_clbk_listener(self, unit, event)
end

function PlayerCarry:_get_max_walk_speed(...)
	local ratio = nil

	if managers.player:has_category_upgrade("player", "bellhop_weight_penalty_removal_throwables") and managers.player:equipped_weapon_index() == tweak_data.WEAPON_SLOT_THROWABLE or managers.player:has_category_upgrade("player", "bellhop_weight_penalty_removal_melees") and managers.player:equipped_weapon_index() == tweak_data.WEAPON_SLOT_MELEE then
		ratio = 0
	else
		ratio = managers.player:get_my_carry_weight_ratio()
	end

	local multiplier = tweak_data.carry:get_type_value_weighted(self._tweak_data_name, "move_speed_modifier", ratio)

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_BAG_WEIGHT) then
		multiplier = multiplier / (managers.buff_effect:get_effect_value(BuffEffectManager.EFFECT_BAG_WEIGHT) or 1)
	end

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN) then
		multiplier = 1
	elseif managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CARRY_INVERT_SPEED) then
		multiplier = 2 - multiplier
	else
		if self._carry_cant_stack and not self._carrying_corpse then
			multiplier = math.clamp(multiplier * managers.player:upgrade_value("carry", "strongback_heavy_penalty_decrease", 1), 0, 1)
		else
			multiplier = math.clamp(multiplier * managers.player:upgrade_value("player", "carry_penalty_decrease", 1), 0, 1)
		end

		if self:ducking() then
			multiplier = math.clamp(multiplier * managers.player:upgrade_value("carry", "scuttler_crouch_penalty_decrease", 1), 0, 1)
		end
	end

	return PlayerCarry.super._get_max_walk_speed(self, ...) * multiplier
end

function PlayerCarry:_get_walk_headbob(...)
	local ratio = managers.player:get_my_carry_weight_ratio()
	local multiplier = tweak_data.carry:get_type_value_weighted(self._tweak_data_name, "move_speed_modifier", ratio)

	return PlayerCarry.super._get_walk_headbob(self, ...) * multiplier
end

function PlayerCarry:pre_destroy(unit)
end

function PlayerCarry:destroy()
end
