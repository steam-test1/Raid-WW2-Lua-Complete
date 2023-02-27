PlayerTurret = PlayerTurret or class(PlayerStandard)

function PlayerTurret:init(unit)
	PlayerTurret.super.init(self, unit)
end

function PlayerTurret:enter(state_data, enter_data)
	PlayerTurret.super.enter(self, state_data, enter_data)

	self._weapon_index = managers.player:get_current_state()._unit:inventory()._selected_primary

	managers.player:get_current_state()._unit:inventory():equip_selection(4, true)

	self._turret_unit = managers.player:get_turret_unit()
	self._turret_weapon = self._turret_unit:weapon()
	self._turret_overheated = false
	self._turret_weapon._mode = "player"
	local turret_weapon_name = self._turret_weapon:get_name_id()
	self._state_data.in_steelsight = tweak_data.weapon[turret_weapon_name].use_dof or nil
	self._exit_turret_timer = tweak_data.weapon[turret_weapon_name].exit_turret_speed or 1
	self._camera_limit_h = tweak_data.weapon[turret_weapon_name].camera_limit_horizontal or 45
	self._camera_limit_v = tweak_data.weapon[turret_weapon_name].camera_limit_vertical or 30
	self._camera_limit_v_mid = tweak_data.weapon[turret_weapon_name].camera_limit_vertical_mid or 0
	self._camera_speed_limit = tweak_data.weapon[turret_weapon_name].camera_speed_limit

	if self._camera_limit_h == 360 then
		self._camera_limit_h = nil
	end

	self._shaker_multiplier = tweak_data.weapon[turret_weapon_name].shaker_multiplier or 0.5

	self:_init_locators()
	self._turret_unit:interaction():set_active(false, true)
	self._turret_weapon:set_active(true)
	managers.network:session():send_to_peers_synched("sync_ground_turret_activate", self._turret_unit)
	managers.hud:show_turret_hud(self._turret_unit, tweak_data.weapon[turret_weapon_name].bullet_type)
	managers.hud:set_player_turret_overheating(self._turret_weapon:is_overheating())

	self._turret_sync_dt = 0

	self._turret_weapon:on_player_enter()
	self._turret_weapon:set_weapon_user(self._unit)
	self:_husk_turret_data()

	self._announce_shooting = false
	local result = self._unit:sound_source():post_event("turret_connect")

	self._turret_unit:link(Idstring("first_person_view"), self._unit)
	self:_hide_hud_prompts()
end

function PlayerTurret:_enter(enter_data)
	if self._unit and self._unit:base().is_local_player then
		self._unit_deploy_position = self._unit:position()
	end
end

function PlayerTurret:get_camera_speed_limit()
	return self._camera_speed_limit
end

function PlayerTurret:_init_locators()
	self._turret_unit = managers.player:get_turret_unit()

	if not self._turret_unit then
		Application:trace("PlayerTurret:_init_locators(): Missing turret unit.")

		return
	end

	self._unit:camera():play_redirect(Idstring("unequip"), 5, 60)
	self._unit:inventory():hide_equipped_unit()
	self._unit:kill_mover()
	self:_postion_player()
	self._unit:camera():camera_unit():base():set_pitch(self._camera_limit_v_mid)
	self._unit:camera():camera_unit():base():set_limits(self._camera_limit_h, self._camera_limit_v, nil, self._camera_limit_v_mid)
end

function PlayerTurret:_hide_hud_prompts()
	local player_equipped_unit_base = managers.player:local_player():inventory():equipped_unit():base()

	if player_equipped_unit_base.out_of_ammo and player_equipped_unit_base:out_of_ammo() then
		self._out_of_ammo_prompt_hidden = true
	elseif player_equipped_unit_base.can_reload and player_equipped_unit_base:can_reload() and player_equipped_unit_base.clip_empty and player_equipped_unit_base:clip_empty() then
		self._can_reload_prompt_hidden = true
	end

	managers.hud:hide_prompt("hud_reload_prompt")
	managers.hud:hide_prompt("hud_no_ammo_prompt")
end

function PlayerTurret:_show_hud_prompts()
	if self._out_of_ammo_prompt_hidden then
		managers.hud:set_prompt("hud_no_ammo_prompt", utf8.to_upper(managers.localization:text("hint_no_ammo")))

		self._out_of_ammo_prompt_hidden = false
	elseif self._can_reload_prompt_hidden then
		managers.hud:set_prompt("hud_reload_prompt", utf8.to_upper(managers.localization:text("hint_reload", {
			BTN_RELOAD = managers.localization:btn_macro("reload")
		})))

		self._can_reload_prompt_hidden = false
	end
end

function PlayerTurret:exit(state_data, new_state_name)
	PlayerTurret.super.exit(self, state_data or self._state_data, new_state_name)

	if self._firing then
		managers.network:session():send_to_peers_synched("sync_ground_turret_stop_autofire", self._turret_unit)
	end

	local player_head_rotation = self._unit:movement():m_head_rot()

	self._turret_weapon:on_player_exit()

	self._state_data.in_steelsight = nil

	self:_interupt_action_exit_turret()

	self._firing = false

	self._unit:camera():camera_unit():base():remove_limits()
	self._unit:camera():camera_unit():base():set_pitch(0)
	self._unit:unlink()
	self._unit:inventory():show_equipped_unit()
	self._unit:camera():play_redirect(self.IDS_EQUIP)

	if self._player_original_position then
		self._unit:warp_to(self._unit:rotation(), self._player_original_position)
	end

	self:_activate_mover(Idstring("stand"))
	managers.network:session():send_to_peers_synched("sync_ground_turret_rot", self._turret_unit:weapon()._player_rotation, self._turret_unit)
	self._turret_weapon:deactivate()
	self._turret_weapon:set_weapon_user(nil)
	self._turret_unit:interaction():set_active(true, true)
	managers.hud:hide_turret_hud(self._turret_unit)

	local peer_id = managers.network:session():peer_by_unit(self._unit):id()

	managers.player:set_turret_data_for_peer({
		peer_id = peer_id
	})
	self._turret_weapon:enable_automatic_SO(true)
	self:_show_hud_prompts()
	managers.player:get_current_state()._unit:inventory():equip_selection(self._weapon_index, true)

	local weap_base = self._equipped_unit:base()

	if weap_base._name_id == "dp28" then
		weap_base:set_magazine_pos_based_on_ammo()
	end
end

function PlayerTurret:_husk_turret_data()
	local peer_id = managers.network:session():peer_by_unit(self._unit):id()
	local husk_pos = self._turret_weapon._locator_tpp:position()
	local turret_rot = self._turret_weapon._locator_fire:rotation()
	local turret_weapon_name = self._turret_weapon:get_name_id()
	local enter_animation = tweak_data.weapon[turret_weapon_name].anim_enter
	local exit_animation = tweak_data.weapon[turret_weapon_name].anim_exit

	managers.player:set_turret_data_for_peer({
		peer_id = peer_id,
		husk_pos = husk_pos,
		turret_rot = turret_rot,
		enter_animation = enter_animation,
		exit_animation = exit_animation,
		turret_unit = self._turret_unit
	})
	managers.network:session():send_to_peers_synched("sync_ground_turret_husk", husk_pos, turret_rot, enter_animation, exit_animation, self._turret_unit)
end

function PlayerTurret:update(t, dt)
	PlayerTurret.super.update(self, t, dt)

	if not self._turret_weapon:active() then
		return
	end

	self:_reposition_player()
	self:_update_action_timers(t, dt)
	self._turret_weapon:set_turret_rot(dt)

	local body_pos = Vector3(self._m_pos.x, self._m_pos.y, self._m_pos.z)
	local player_head_rotation = self._unit:movement():m_head_rot()

	if self._turret_sync_dt > 1 then
		managers.network:session():send_to_peers_synched("sync_ground_turret_rot", player_head_rotation, self._turret_unit)

		self._turret_sync_dt = 0
	else
		self._turret_sync_dt = self._turret_sync_dt + dt
	end

	if self._turret_weapon._overheated ~= self._turret_overheated then
		self._turret_overheated = self._turret_weapon._overheated

		if self._turret_overheated == true then
			managers.hud:player_turret_overheat(self._turret_unit)
		else
			managers.hud:player_turret_cooldown()
		end
	end

	managers.hud:update_heat_indicator(self._turret_weapon:get_current_heat())
end

function PlayerTurret:set_tweak_data(name)
end

function PlayerTurret:_update_check_actions(t, dt)
	local input = self:_get_input()

	self:_check_stats_screen(t, dt, input)
	self:_check_action_primary_attack(t, input)
	self:_check_action_exit_turret(t, input)
	self:_update_foley(t, input)
	self:_check_warcry(t, input)
end

function PlayerTurret:_check_action_exit_turret(t, input)
	if input.btn_interact_press then
		self:_start_action_exit_turret(t)
	end

	if input.btn_interact_release then
		self:_interupt_action_exit_turret()
	end
end

function PlayerTurret:_start_action_exit_turret(t)
	self:_end_action_exit_turret()
end

function PlayerTurret:_interupt_action_exit_turret()
	if self._exit_turret_expire_t then
		self._exit_turret_expire_t = nil

		managers.hud:hide_progress_timer_bar()
		managers.hud:remove_progress_timer()
	end
end

function PlayerTurret:_update_action_timers(t, dt)
	if self._exit_turret_expire_t then
		managers.hud:set_progress_timer_bar_width(self._exit_turret_timer - (self._exit_turret_expire_t - t), self._exit_turret_timer)

		if self._exit_turret_expire_t <= t then
			self:_end_action_exit_turret()

			self._exit_turret_expire_t = nil
		end
	end
end

function PlayerTurret:_end_action_exit_turret()
	if self._turret_weapon._moving then
		self._turret_weapon:stop_moving_sound()
	end

	self._unit:camera():play_redirect(self.IDS_IDLE)
	managers.player:leave_turret()
	managers.player:set_player_state("standard")
end

function PlayerTurret:interaction_blocked()
	return true
end

function PlayerTurret:_announce_cooldown()
	self._announce_shooting_clbk_id = "announce_shooting_" .. tostring(managers.network:session():local_peer()._id)
	local weapon_name = self._turret_weapon:get_name_id()
	local cooldown_duration = tweak_data.weapon[weapon_name].announce_shooting_cooldown or {
		10,
		15
	}
	local cooldown_spread = cooldown_duration[2] - cooldown_duration[1]
	local final_cooldown = cooldown_duration[1] + math.random(0, cooldown_spread)

	managers.queued_tasks:unqueue_all(self._announce_shooting_clbk_id, self)
	managers.queued_tasks:queue(self._announce_shooting_clbk_id, self._enable_announcing, self, nil, final_cooldown)
end

function PlayerTurret:_enable_announcing()
	self._announce_shooting = false
end

function PlayerTurret:_check_action_primary_attack(t, input)
	if not self._turret_weapon then
		return
	end

	if self._turret_weapon._overheated then
		return
	end

	local action_wanted = input.btn_primary_attack_state or input.btn_primary_attack_release

	if action_wanted then
		if input.btn_primary_attack_press then
			self._turret_weapon:start_autofire()

			self._firing = true

			if not self._announce_shooting then
				local result = self._unit:sound_source():post_event("player_shooting_turret")
				self._announce_shooting = true

				self:_announce_cooldown()
			end

			managers.network:session():send_to_peers_synched("sync_ground_turret_start_autofire", self._turret_unit)
		end

		if input.btn_primary_attack_release then
			self._turret_weapon:stop_autofire()

			self._firing = false

			managers.network:session():send_to_peers_synched("sync_ground_turret_stop_autofire", self._turret_unit)
		end

		if self._firing then
			local fired = self._turret_weapon:trigger_held(false, false, false, nil, 1)

			if fired then
				self._unit:camera():play_shaker("fire_weapon_rot", 1 * self._shaker_multiplier)
				self._unit:camera():play_shaker("fire_weapon_kick", 1 * self._shaker_multiplier, 1, 0.15)
			end

			managers.network:session():send_to_peers_synched("sync_ground_turret_trigger_held", self._turret_unit, false, false, false, nil, 0)
		end
	end
end

function PlayerTurret:_check_stop_shooting()
	if self._shooting then
		self._equipped_unit:base():stop_shooting()
		self._camera_unit:base():stop_shooting(self._equipped_unit:base():recoil_wait())

		local weap_base = self._equipped_unit:base()
		local fire_mode = weap_base:fire_mode()

		if fire_mode == "auto" and not self:_is_reloading() and not self:_is_meleeing() then
			self._unit:camera():play_redirect(self.IDS_RECOIL_EXIT)
		end

		self._shooting = false
	end
end

function PlayerTurret:_check_step(t)
end

function PlayerTurret:_check_action_reload(t, input)
end

function PlayerTurret:_check_action_run(...)
end

function PlayerTurret:_check_use_item(t, input)
end

function PlayerTurret:_check_change_weapon(t, input)
	local new_action = nil
	local action_wanted = input.btn_switch_weapon_press

	if action_wanted then
		local action_forbidden = self:_changing_weapon()
		action_forbidden = action_forbidden or self._use_item_expire_t or self._change_item_expire_t
		action_forbidden = action_forbidden or self._unit:inventory():num_selections() == 1

		if not action_forbidden then
			self:exit(nil, "standard")
			managers.player:set_player_state("standard")

			new_action = true
		end
	end

	return new_action
end

function PlayerTurret:_check_action_equip(t, input)
	local new_action = nil
	local selection_wanted = input.btn_primary_choice

	if selection_wanted then
		local action_forbidden = self:chk_action_forbidden("equip")
		action_forbidden = action_forbidden or not self._ext_inventory:is_selection_available(selection_wanted) or self._use_item_expire_t or self:_changing_weapon()

		if not action_forbidden then
			local new_action = not self._ext_inventory:is_equipped(selection_wanted)

			if new_action then
				self:exit(nil, "standard")
				managers.player:set_player_state("standard")
			end
		end
	end

	return new_action
end

function PlayerTurret:_check_action_jump(t, input)
	local new_action = nil
	local action_wanted = input.btn_jump_press

	if action_wanted then
		local action_forbidden = self._jump_t and t < self._jump_t + 0.55
		action_forbidden = action_forbidden or self._unit:base():stats_screen_visible() or self._state_data.in_air

		if not action_forbidden then
			local action_start_data = {}
			local jump_vel_z = self._tweak_data.movement.jump_velocity.z
			action_start_data.jump_vel_z = jump_vel_z

			self:exit(nil, "standard")
			managers.player:set_player_state("standard")

			new_action = self:_start_action_jump(t, action_start_data)
		end
	end

	return new_action
end

function PlayerTurret:_check_action_steelsight(t, input)
end

function PlayerTurret:_update_movement(t, dt)
end

function PlayerTurret:_get_max_walk_speed(...)
	return 0
end

function PlayerTurret:_get_walk_headbob(...)
	return 0
end

function PlayerTurret:_postion_player()
	self._player_original_position = self._unit:position()
	local rot = self._turret_unit:rotation()

	self._unit:set_rotation(rot)

	local pos = self._turret_unit:get_object(Idstring("first_person_view")):position()

	self._unit:set_position(pos)
	self._unit:camera():set_rotation(rot)
	self._unit:camera():set_position(pos)
	self._unit:camera():camera_unit():base():set_spin(rot:y():to_polar().spin)
	self._unit:camera():camera_unit():base():set_pitch(0)
end

function PlayerTurret:_reposition_player()
	if not managers.raid_job:current_level_id() then
		return
	end

	local pos = self._turret_unit:get_object(Idstring("first_person_view")):position()

	if self._unit:position() ~= pos then
		self._unit:set_position(pos)
		self._unit:camera():set_position(pos)
	end
end

function PlayerTurret:pre_destroy(unit)
end

function PlayerTurret:destroy()
end

function PlayerTurret:_debug_draw_positions()
	Application:trace([[

-----
PlayerTurret:_postion_player 
 turret rot ]], self._turret_unit:rotation(), "\n turret yaw: ", self._turret_unit:rotation():yaw(), "\n turret y: ", self._turret_unit:rotation():y(), "\n turret spin: ", self._turret_unit:rotation():y():to_polar().spin, "\n\n player rot: ", self._unit:movement():m_head_rot(), "\n player yaw: ", self._unit:movement():m_head_rot():yaw(), "\n player y: ", self._unit:movement():m_head_rot():y(), "\n player spin: ", self._unit:movement():m_head_rot():y():to_polar().spin, "\n\n joint heading rot: ", self._joint_heading:rotation(), "\n joint heading yaw: ", self._joint_heading:rotation():yaw(), "\n joint heading y: ", self._joint_heading:rotation():y(), "\n joint heading spin: ", self._joint_heading:rotation():y():to_polar().spin, "\n\n joint local heading rot: ", self._joint_heading:local_rotation(), "\n joint local heading yaw: ", self._joint_heading:local_rotation():yaw(), "\n joint local heading y: ", self._joint_heading:local_rotation():y(), "\n joint local heading spin: ", self._joint_heading:local_rotation():y():to_polar().spin, "\n\n joint local pitch rot: ", self._joint_pitch:local_rotation(), "\n joint local pitch yaw: ", self._joint_pitch:local_rotation():yaw(), "\n joint local pitch y: ", self._joint_pitch:local_rotation():y(), "\n joint local pitch spin: ", self._joint_pitch:local_rotation():y():to_polar().spin)
end
