PlayerCharging = PlayerCharging or class(PlayerStandard)
PlayerCharging.TRANSITION_T = 0.35
PlayerCharging.SPEED_MUL = 1.58
PlayerCharging.SENSITIVITY_MUL = 0.032
PlayerCharging.AIR_INTERRUPT_T = 0.78
PlayerCharging.COLLISION_INTERRUPT_T = 0.18
PlayerCharging.INTERRUPT_TASK_ID = "PlayerCharging:interrupt_charge"

function PlayerCharging:init(unit)
	PlayerCharging.super.init(self, unit)

	self._slotmask_charge = self._slotmask_gnd_ray
end

function PlayerCharging:enter(state_data, enter_data)
	local activate_warcry = managers.warcry:get_active_warcry_name()

	if activate_warcry ~= Warcry.PAIN_TRAIN then
		Application:warn("[PlayerCharging:enter] Tried to enter charging state with the wrong warcry equipped:", activate_warcry)
		self:_interrupt_charge()

		return
	end

	self._equipped_unit = self._ext_inventory:equipped_unit()

	self:interupt_all_actions()
	self:_interupt_action_ducking()
	PlayerCharging.super.enter(self, state_data, enter_data)
end

function PlayerCharging:_enter(enter_data)
	local t = managers.player:player_timer():time()
	self._initial_warcry_fill = managers.warcry:current_meter_value() or 0
	self._full_speed_t = t + PlayerCharging.TRANSITION_T
	self._air_interrupt_t = t + PlayerCharging.AIR_INTERRUPT_T
	self._interrupted = nil
	local equipped_selection = self._ext_inventory:equipped_selection()

	if equipped_selection ~= PlayerInventory.SLOT_4 then
		self._old_selection = equipped_selection

		self:_start_action_unequip_weapon(t, {
			selection_wanted = PlayerInventory.SLOT_4
		})
		self:_start_action_equip_weapon(t)
	else
		self._old_selection = nil

		self._ext_camera:play_redirect(self.IDS_START_RUNNING)
	end

	self._state_data.melee_expire_t = nil
	self._state_data.melee_repeat_expire_t = nil

	self:_set_camera_limits(t)
	self:_stance_entered()
	self:animate_fov_multiplier(1.15, PlayerCharging.TRANSITION_T * 2)
	managers.hud:set_crosshair_fade(false)
end

function PlayerCharging:exit(state_data, new_state_name)
	PlayerCharging.super.exit(self, state_data, new_state_name)

	self._interrupted = nil
	self._initial_warcry_fill = nil
	self._state_data.melee_expire_t = nil
	self._state_data.melee_repeat_expire_t = nil

	managers.queued_tasks:unqueue(PlayerCharging.INTERRUPT_TASK_ID)
	self:_remove_camera_limits()
	self._ext_camera:play_redirect(self.IDS_STOP_RUNNING)
	self:animate_fov_multiplier(1, PlayerCharging.TRANSITION_T)

	local exit_data = {
		skip_equip = true,
		equip_weapon = self._old_selection
	}

	return exit_data
end

function PlayerCharging:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	self:_check_stats_screen(t, dt, input)
	self:_update_foley(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_melee_timers(t, input)

	if self._gnd_ray then
		self._air_interrupt_t = t + PlayerCharging.AIR_INTERRUPT_T
	end
end

function PlayerCharging:_update_equip_weapon_timers(t, input)
	if self._equip_weapon_expire_t and self._equip_weapon_expire_t <= t then
		self._equip_weapon_expire_t = nil

		self._ext_camera:play_redirect(self.IDS_START_RUNNING)
	end
end

function PlayerCharging:_determine_move_direction()
	self._stick_move = self._controller:get_input_axis("move")

	if self._interrupted then
		self._move_dir = nil
	else
		self._move_dir = mvector3.copy(self._cam_fwd_flat)

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_CAN_MOVE_ONLY_BACK_AND_SIDE) then
			self._move_dir = -self._move_dir
		end
	end
end

function PlayerCharging:update(t, dt)
	PlayerCharging.super.update(self, t, dt)
	self:_check_charge_interrupt(t, dt)
end

function PlayerCharging:_check_charge_interrupt(t, dt)
	if self._interrupted then
		return
	end

	if not self._move_dir then
		return true
	end

	local ray = self:_check_forward_collision()
	local velocity = self._last_velocity_xy and self._last_velocity_xy:length() or 0
	local collision = ray and alive(ray.unit) or velocity < 80

	if collision then
		self:_interrupt_charge(t, collision)
	end

	local interrupt = self:ducking() or self._air_interrupt_t < t or not managers.warcry:active()
end

function PlayerCharging:_interrupt_charge(t, collision)
	t = t or managers.player:player_timer():time()
	self._interrupted = true

	if collision and self._full_speed_t < t then
		self:_on_collision()
		managers.queued_tasks:queue(PlayerCharging.INTERRUPT_TASK_ID, self._start_action_state_standard, self, {
			true
		}, PlayerCharging.COLLISION_INTERRUPT_T)
	else
		self:_start_action_state_standard()
	end
end

function PlayerCharging:_start_action_state_standard(hard_collided)
	if managers.warcry:active() then
		local initial_fill = self._initial_warcry_fill

		managers.warcry:deactivate_warcry()

		if not hard_collided and initial_fill then
			local new_fill = initial_fill - managers.warcry:current_meter_value()

			managers.warcry:fill_meter_by_value(new_fill, true)
		end
	end
end

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local up_offset_vec = math.UP * 80
local sphere_radius = 30
local fwd_offset = 80

function PlayerCharging:_check_forward_collision()
	local hips_pos = tmp_vec1
	local fwd_pos = tmp_vec2

	mvector3.set(hips_pos, self._pos)
	mvector3.add(hips_pos, up_offset_vec)
	mvector3.set(fwd_pos, hips_pos)
	mvector3.add(fwd_pos, self._move_dir:normalized() * fwd_offset)

	local ray = World:raycast("ray", hips_pos, fwd_pos, "slot_mask", self._slotmask_charge, "ray_type", "body mover", "sphere_cast_radius", sphere_radius)

	if ray and alive(ray.body) and ray.body:collides_with_mover() then
		return ray
	end

	return nil
end

function PlayerCharging:_on_collision()
	managers.rumble:play("hard_land")
	self._ext_camera:play_shaker("melee_hit", 0.5)
	self._ext_camera:play_shaker("player_start_running", 3)
	self:push(-(self._last_velocity_xy * 0.5))
	managers.environment_controller:hit_feedback_front()
	self._unit:sound():play("hit_bullet_1p")
	self:say_line("player_gen_pain_impact")
end

function PlayerCharging:knockdown_melee(t, ray)
	if ray and self:_melee_repeat_allowed() then
		local melee_entry = self:_get_melee_weapon()

		self:_play_melee_sound(melee_entry, "hit_air")
		self._camera_unit:anim_state_machine():set_global("charge", 1)
		self._ext_camera:play_redirect(PlayerStandard.IDS_MELEE_ATTACK)
		self:_do_melee_damage(t, nil, ray)

		self._state_data.melee_expire_t = t + tweak_data.blackmarket.melee_weapons[melee_entry].expire_t
		self._state_data.melee_repeat_expire_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t)
		self._equip_weapon_expire_t = self._state_data.melee_repeat_expire_t
	end
end

function PlayerCharging:_get_melee_charge_lerp_value(t, offset)
	return 1
end

function PlayerCharging:interaction_blocked()
	return true
end

function PlayerCharging:_start_action_ducking(t)
end

function PlayerCharging:_get_max_walk_speed(t)
	local speed_tweak = self._tweak_data.movement.speed

	return speed_tweak.RUNNING_SPEED * self.SPEED_MUL
end

function PlayerCharging:_set_camera_limits(t)
	self._camera_unit:base():animate_pitch(t, nil, 0, PlayerCharging.TRANSITION_T)
	self._camera_unit:base():set_limits(40, 30, nil, 0)
end

function PlayerCharging:get_sensitivity_multiplier()
	return self.SENSITIVITY_MUL
end

function PlayerCharging:_remove_camera_limits()
	self._camera_unit:base():remove_limits()
	self._camera_unit:base():set_sensitivity_multiplier(1)
end
