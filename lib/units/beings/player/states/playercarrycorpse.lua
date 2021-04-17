PlayerCarryCorpse = PlayerCarryCorpse or class(PlayerCarry)

-- Lines 3-5
function PlayerCarryCorpse:init(unit)
	PlayerCarryCorpse.super.init(self, unit)
end

-- Lines 9-31
function PlayerCarryCorpse:enter(state_data, enter_data)
	if enter_data then
		enter_data.skip_equip = true
	end

	PlayerCarryCorpse.super.enter(self, state_data, enter_data)
	Application:debug("[PlayerCarryCorpse:enter] **********************************************************")
	managers.dialog:queue_dialog("player_gen_carry_body", {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})

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
end

-- Lines 35-39
function PlayerCarryCorpse:_enter(enter_data)
	PlayerCarryCorpse.super._enter(self, enter_data)
	self._unit:camera():play_redirect(Idstring("carry_corpse_equip"))

	self._carrying_corpse = true
end

-- Lines 43-48
function PlayerCarryCorpse:exit(state_data, new_state_name)
	self._unit:camera():play_redirect(Idstring("carry_corpse_unequip"))

	self._carrying_corpse = false
	local exit_data = PlayerCarryCorpse.super.exit(self, state_data, new_state_name)

	return exit_data
end

-- Lines 52-54
function PlayerCarryCorpse:update(t, dt)
	PlayerCarryCorpse.super.update(self, t, dt)
end

-- Lines 56-59
function PlayerCarryCorpse:set_tweak_data(name)
	self._tweak_data_name = name

	self:_check_dye_pack()
end

-- Lines 64-66
function PlayerCarryCorpse:_check_change_weapon(...)
	return false
end

-- Lines 68-70
function PlayerCarryCorpse:_check_action_equip(...)
	return false
end

-- Lines 72-89
function PlayerCarryCorpse:_check_action_interact(t, input)
	local new_action, timer, interact_object = nil

	if input.btn_interact_press then
		if managers.interaction:active_unit() then
			managers.notification:add_notification({
				duration = 2,
				shelf_life = 5,
				id = "hud_hint_carry_corpse_block_interact",
				text = managers.localization:text("hud_hint_carry_corpse_block_interact")
			})

			new_action = nil
		else
			new_action = new_action or self:_start_action_intimidate(t)
		end
	end

	return new_action
end

-- Lines 92-94
function PlayerCarryCorpse:_update_movement(t, dt)
	PlayerCarryCorpse.super._update_movement(self, t, dt)
end

-- Lines 98-101
function PlayerCarryCorpse:_start_action_jump(...)
	PlayerCarryCorpse.super._start_action_jump(self, ...)
end

-- Lines 103-109
function PlayerCarryCorpse:_perform_jump(jump_vec)
	if not managers.player:has_category_upgrade("carry", "movement_penalty_nullifier") then
		if not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN) then
			mvector3.multiply(jump_vec, tweak_data.carry.types[self._tweak_data_name].jump_modifier)
		end
	end

	PlayerCarryCorpse.super._perform_jump(self, jump_vec)
end

-- Lines 114-176
function PlayerCarryCorpse:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)

	local warcry_action = self:_check_warcry(t, input)

	self:_update_foley(t, input)
	self:_check_action_interact(t, input)
	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)
	self:_check_action_duck(t, input)

	if not warcry_action then
		self:_check_use_item(t, input)
	end

	self:_check_comm_wheel(t, input)
	self:_check_stats_screen(t, dt, input)
end
