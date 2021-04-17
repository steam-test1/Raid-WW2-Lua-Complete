PlayerFoxhole = PlayerFoxhole or class(PlayerStandard)
PlayerFoxhole.EXIT_TIMER = 0.4
PlayerFoxhole._update_movement = PlayerBleedOut._update_movement

-- Lines 6-19
function PlayerFoxhole:enter(state_data, enter_data)
	PlayerFoxhole.super.enter(self, state_data, enter_data)
	self._unit:camera():camera_unit():base():set_target_tilt(0)
	self._unit:camera():camera_unit():base():set_limits(60, 20)
	self:_start_action_unequip_weapon(managers.player:player_timer():time(), {
		selection_wanted = 1
	})
	self:_stance_entered()

	local velocity = self._unit:mover():velocity()

	self._unit:kill_mover()
	self._unit:character_damage():set_invulnerable(true)
end

-- Lines 21-35
function PlayerFoxhole:exit(state_data, new_state_name)
	PlayerFoxhole.super.exit(self, state_data, new_state_name)
	self._unit:camera():camera_unit():base():remove_limits()
	self._ext_movement:foxhole_unit():foxhole():unregister_player()
	self._ext_movement:set_foxhole_unit(nil)
	self:_start_action_equip(self.IDS_EQUIP)
	self:_stance_entered()
	self:_activate_mover(PlayerStandard.MOVER_STAND)
	self._unit:character_damage():set_invulnerable(false)
end

-- Lines 37-46
function PlayerFoxhole:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_update_foley(t, input)
	self:_check_stats_screen(t, dt, input)
	self:_check_action_exit_foxhole(t, input)
	self:_update_action_timers(t, input)
end

-- Lines 48-58
function PlayerFoxhole:_check_action_exit_foxhole(t, input)
	if input.btn_interact_press and not self._ext_movement:foxhole_unit():foxhole():locked() then
		self:_start_interaction_exit_foxhole(t)
	end

	if input.btn_interact_release then
		self:_interupt_action_exit_foxhole(t)
	end
end

-- Lines 60-70
function PlayerFoxhole:_start_interaction_exit_foxhole(t)
	if self._ext_movement:foxhole_unit():foxhole():locked() then
		return
	end

	local timer = PlayerFoxhole.EXIT_TIMER
	self._exit_foxhole_expire_t = t + timer
	local text = utf8.to_upper(managers.localization:text("hud_action_exit_foxhole"))

	managers.hud:show_progress_timer_bar(0, timer, text)
end

-- Lines 72-74
function PlayerFoxhole:_interacting()
	return PlayerFoxhole.super._interacting(self) or self._exit_foxhole_expire_t
end

-- Lines 77-82
function PlayerFoxhole:_interupt_action_exit_foxhole(t, input, complete)
	if self._exit_foxhole_expire_t then
		self._exit_foxhole_expire_t = nil

		managers.hud:hide_progress_timer_bar(complete)
	end
end

-- Lines 84-93
function PlayerFoxhole:_update_action_timers(t, input)
	if self._exit_foxhole_expire_t then
		local timer = PlayerFoxhole.EXIT_TIMER

		managers.hud:set_progress_timer_bar_width(timer - (self._exit_foxhole_expire_t - t), timer)

		if self._exit_foxhole_expire_t <= t then
			self:_end_action_exit_foxhole()

			self._exit_foxhole_expire_t = nil
		end
	end
end

-- Lines 95-98
function PlayerFoxhole:_end_action_exit_foxhole()
	managers.hud:hide_progress_timer_bar(true)
	managers.player:set_player_state("standard")
end
