require("lib/states/GameState")

IngameSpecialInteraction = IngameSpecialInteraction or class(IngamePlayerBaseState)
IngameSpecialInteraction.FAILED_COOLDOWN = 1
IngameSpecialInteraction.COMPLETED_DELAY = 0.5
IngameSpecialInteraction.LOCKPICK_DOF_DIST = 3

-- Lines 10-13
function IngameSpecialInteraction:init(game_state_machine)
	IngameSpecialInteraction.super.init(self, "ingame_special_interaction", game_state_machine)

	self._current_stage = 1
end

-- Lines 15-29
function IngameSpecialInteraction:_setup_controller()
	managers.menu:get_controller():disable()

	self._controller = managers.controller:create_controller("ingame_special_interaction", managers.controller:get_default_wrapper_index(), false)
	self._leave_cb = callback(self, self, "cb_leave")
	self._interact_cb = callback(self, self, "cb_interact")

	self._controller:add_trigger("jump", self._leave_cb)
	self._controller:add_trigger("interact", self._interact_cb)
	self._controller:set_enabled(true)
end

-- Lines 33-47
function IngameSpecialInteraction:_clear_controller()
	local menu_controller = managers.menu:get_controller()

	if menu_controller then
		menu_controller:enable()
	end

	if self._controller then
		self._controller:remove_trigger("jump", self._leave_cb)
		self._controller:remove_trigger("interact", self._interact_cb)
		self._controller:set_enabled(false)
		self._controller:destroy()

		self._controller = nil
	end
end

-- Lines 49-53
function IngameSpecialInteraction:set_controller_enabled(enabled)
	if self._controller then
		self._controller:set_enabled(enabled)
	end
end

-- Lines 55-61
function IngameSpecialInteraction:cb_leave()
	Application:debug("[IngameSpecialInteraction:cb_leave()]")

	if self._completed then
		return
	end

	game_state_machine:change_state_by_name(self._old_state)
end

-- Lines 63-70
function IngameSpecialInteraction:cb_interact()
	if self._cooldown > 0 or self._completed then
		return
	end

	self:_check_stage_complete()
	self:_check_all_complete()
end

-- Lines 72-73
function IngameSpecialInteraction:on_destroyed()
end

-- Lines 75-113
function IngameSpecialInteraction:update(t, dt)
	if not self._hud then
		return
	end

	self._hud:rotate_circles(dt)

	if self._cooldown > 0 then
		self._cooldown = self._cooldown - dt

		if self._cooldown <= 0 then
			self._cooldown = 0

			if self._invalid_stage then
				self._hud:set_bar_valid(self._invalid_stage, true)

				self._invalid_stage = nil

				if self._tweak_data.sounds then
					self:_play_sound(self._tweak_data.sounds.circles[self._current_stage].mechanics)
				end
			end
		end
	end

	if self._completed then
		self._end_t = self._end_t - dt

		if self._end_t <= 0 then
			self._end_t = 0

			if self._tweak_data.target_unit:interaction() then
				self._tweak_data.target_unit:interaction():special_interaction_done()
				game_state_machine:change_state_by_name(self._old_state)
			end
		end
	end

	if alive(self._tweak_data.target_unit) and self._tweak_data.target_unit:unit_data()._interaction_done then
		self._completed_by_other = true

		game_state_machine:change_state_by_name(self._old_state)
	end
end

-- Lines 115-121
function IngameSpecialInteraction:update_player_stamina(t, dt)
	local player = managers.player:player_unit()

	if player and player:movement() then
		player:movement():update_stamina(t, dt, true)
	end
end

-- Lines 123-125
function IngameSpecialInteraction:_player_damage(info)
end

-- Lines 127-179
function IngameSpecialInteraction:at_enter(old_state, params)
	local player = managers.player:player_unit()

	if player then
		player:movement():current_state():interupt_all_actions()
		player:camera():play_redirect(PlayerStandard.IDS_UNEQUIP)
		player:base():set_enabled(true)
		player:character_damage():add_listener("IngameSpecialInteraction", {
			"hurt",
			"death"
		}, callback(self, self, "_player_damage"))
		managers.dialog:queue_dialog("player_gen_picking_lock", {
			skip_idle_check = true,
			instigator = managers.player:local_player()
		})
		SoundDevice:set_rtpc("stamina", 100)
	end

	self._sound_source = self._sound_source or SoundDevice:create_source("ingame_special_interaction")

	self._sound_source:set_position(player:position())

	self._tweak_data = params
	self._cooldown = 0.1
	self._completed = false
	self._old_state = old_state:name()

	managers.hud:remove_interact()
	player:camera():set_shaker_parameter("headbob", "amplitude", 0)

	self._hud = managers.hud:create_special_interaction(managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT), params)

	self._hud:show()
	managers.environment_controller:set_vignette(1)
	self:_setup_controller()

	if self._tweak_data.sounds then
		self:_play_sound(self._tweak_data.sounds.circles[1].mechanics)
	end

	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
	managers.network:session():send_to_peers("enter_lockpicking_state")
end

-- Lines 182-218
function IngameSpecialInteraction:at_exit()
	self._sound_source:stop()

	if self._completed then
		self:_play_sound(self._tweak_data.sounds.success)
		managers.dialog:queue_dialog("player_gen_lock_picked", {
			skip_idle_check = true,
			instigator = managers.player:local_player()
		})
	end

	managers.environment_controller:set_vignette(0)
	self:_clear_controller()

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
		player:base():set_visible(true)

		player:base().skip_update_one_frame = true

		player:camera():play_redirect(PlayerStandard.IDS_EQUIP)
		player:character_damage():remove_listener("IngameSpecialInteraction")
	end

	managers.hud:hide_special_interaction(self._completed)

	if not self._completed and not self._completed_by_other and alive(self._tweak_data.target_unit) and self._tweak_data.target_unit:interaction() and self._tweak_data.target_unit:interaction():active() then
		managers.hud:show_interact()
	end

	self._hud = nil

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
	managers.network:session():send_to_peers("exit_lockpicking_state")
end

-- Lines 220-265
function IngameSpecialInteraction:_check_stage_complete()
	local current_stage_data, current_stage = nil

	for stage, stage_data in pairs(self._hud:circles()) do
		if not stage_data.completed then
			current_stage = stage
			current_stage_data = stage_data

			break
		end
	end

	if not current_stage then
		return
	end

	self._current_stage = current_stage
	local circle_difficulty = self._tweak_data.circle_difficulty[current_stage]
	local diff_degrees = 360 * (1 - circle_difficulty) - 3
	local circle = current_stage_data.circle._circle
	local current_rot = circle:rotation()

	if current_rot < diff_degrees then
		self._hud:complete_stage(current_stage)

		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.circles[current_stage].lock)

			if self._tweak_data.sounds.circles[current_stage + 1] then
				self:_play_sound(self._tweak_data.sounds.circles[current_stage + 1].mechanics, true)
			end
		end
	else
		self._hud:set_bar_valid(current_stage, false)

		local new_start_rotation = math.random() * 360

		circle:set_rotation(new_start_rotation)

		self._cooldown = IngameSpecialInteraction.FAILED_COOLDOWN
		self._invalid_stage = current_stage

		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.failed)
			managers.dialog:queue_dialog("player_gen_lockpick_fail", {
				skip_idle_check = true,
				instigator = managers.player:local_player()
			})
		end

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_FAILED_INTERACTION_MINI_GAME) then
			managers.buff_effect:fail_effect(BuffEffectManager.EFFECT_PLAYER_FAILED_INTERACTION_MINI_GAME, managers.network:session():local_peer():id())
		end
	end
end

-- Lines 267-279
function IngameSpecialInteraction:_check_all_complete(t, dt)
	local completed = true

	for stage, stage_data in pairs(self._hud:circles()) do
		completed = completed and stage_data.completed
	end

	self._completed = completed

	if completed then
		if self._tweak_data.sounds then
			self:_play_sound(self._tweak_data.sounds.last_circle)
		end

		self._end_t = IngameSpecialInteraction.COMPLETED_DELAY
	end
end

-- Lines 281-289
function IngameSpecialInteraction:_play_sound(event, no_stop)
	if event then
		if not no_stop then
			self._sound_source:stop()
		end

		self._sound_source:post_event(event)
	end
end
