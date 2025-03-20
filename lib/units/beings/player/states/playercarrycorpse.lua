PlayerCarryCorpse = PlayerCarryCorpse or class(PlayerCarry)
PlayerCarryCorpse.target_tilt = -5
PlayerCarryCorpse.IDS_CORPSE_EQUIP = Idstring("carry_corpse_equip")
PlayerCarryCorpse.IDS_CORPSE_UNEQUIP = Idstring("carry_corpse_unequip")
PlayerCarryCorpse.UNEQUIP_TIMER = 0.76

function PlayerCarryCorpse:init(unit)
	PlayerCarryCorpse.super.init(self, unit)
end

function PlayerCarryCorpse:enter(state_data, enter_data)
	if enter_data then
		enter_data.skip_equip = true
	end

	PlayerCarryCorpse.super.enter(self, state_data, enter_data)
	self._unit:camera():camera_unit():base():set_target_tilt(PlayerCarryCorpse.target_tilt)

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
	self:_stance_entered(true)
end

function PlayerCarryCorpse:_enter(enter_data)
	PlayerCarryCorpse.super._enter(self, enter_data)
	self._unit:camera():play_redirect(self.IDS_CORPSE_EQUIP)

	self._carrying_corpse = true
end

function PlayerCarryCorpse:exit(state_data, new_state_name)
	self:_start_action_equip(self.IDS_CORPSE_UNEQUIP, self.UNEQUIP_TIMER)

	self._carrying_corpse = false
	local exit_data = PlayerCarryCorpse.super.exit(self, state_data, new_state_name)

	return exit_data
end

function PlayerCarryCorpse:update(t, dt)
	PlayerCarryCorpse.super.update(self, t, dt)
end

function PlayerCarryCorpse:set_tweak_data(name)
	self._tweak_data_name = name
end

function PlayerCarryCorpse:_check_change_weapon(...)
	return false
end

function PlayerCarryCorpse:_check_action_equip(...)
	return false
end

function PlayerCarryCorpse:_check_action_mantle(...)
	return false
end

function PlayerCarryCorpse:_check_action_run(t, input)
	if input.btn_run_press then
		managers.notification:add_notification({
			id = "hint_cant_run",
			duration = 2,
			shelf_life = 5,
			text = managers.localization:text("hint_cant_run")
		})
	end
end

function PlayerCarryCorpse:_check_action_interact(t, input)
	local new_action, timer, interact_object = nil

	if input.btn_interact_press then
		if managers.interaction:active_unit() then
			managers.notification:add_notification({
				id = "hud_hint_carry_corpse_block_interact",
				duration = 2,
				shelf_life = 5,
				text = managers.localization:text("hud_hint_carry_corpse_block_interact")
			})

			new_action = nil
		else
			new_action = new_action or self:_start_action_intimidate(t)
		end
	end

	return new_action
end

function PlayerCarryCorpse:_update_movement(t, dt)
	PlayerCarryCorpse.super._update_movement(self, t, dt)
end

function PlayerCarryCorpse:_update_crosshair_offset()
	managers.hud:set_crosshair_fade(false)
end

function PlayerCarryCorpse:_start_action_jump(...)
	PlayerCarryCorpse.super._start_action_jump(self, ...)
end

function PlayerCarryCorpse:_perform_jump(jump_vec)
	if not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_BAGS_DONT_SLOW_PLAYERS_DOWN) then
		local ratio = managers.player:get_my_carry_weight_ratio()
		local jump_modifier = tweak_data.carry:get_type_value_weighted(self._tweak_data_name, "jump_modifier", ratio)

		mvector3.multiply(jump_vec, jump_modifier)
	end

	PlayerCarryCorpse.super._perform_jump(self, jump_vec)
end

function PlayerCarryCorpse:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	self:_update_interaction_timers(t)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)

	local warcry_action = self:_check_action_warcry(t, input)

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

function PlayerCarryCorpse:force_change_weapon_slot(slot, instant)
end
