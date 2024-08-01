require("lib/states/GameState")

IngameSpecialInteraction = IngameSpecialInteraction or class(IngamePlayerBaseState)
IngameSpecialInteraction.FAILED_COOLDOWN = 1
IngameSpecialInteraction.COMPLETED_DELAY = 0.5
IngameSpecialInteraction.LOCKPICK_DOF_DIST = 3

-- Lines 10-12
function IngameSpecialInteraction:init(game_state_machine)
	IngameSpecialInteraction.super.init(self, "ingame_special_interaction", game_state_machine)
end

-- Lines 16-30
function IngameSpecialInteraction:_setup_controller()
	managers.menu:get_controller():disable()

	self._controller = managers.controller:create_controller("ingame_special_interaction", managers.controller:get_default_wrapper_index(), false)
	self._cb_table = {
		jump = callback(self, self, "cb_leave"),
		interact = callback(self, self, "cb_interact")
	}

	for k, cb in pairs(self._cb_table) do
		self._controller:add_trigger(k, cb)
	end

	self._controller:set_enabled(true)
end

-- Lines 34-48
function IngameSpecialInteraction:_clear_controller()
	local menu_controller = managers.menu:get_controller()

	if menu_controller then
		menu_controller:enable()
	end

	if self._controller then
		for k, cb in pairs(self._cb_table) do
			self._controller:remove_trigger(k, cb)
		end

		self._controller:set_enabled(false)
		self._controller:destroy()

		self._controller = nil
	end
end

-- Lines 52-56
function IngameSpecialInteraction:set_controller_enabled(enabled)
	if self._controller then
		self._controller:set_enabled(enabled)
	end
end

-- Lines 60-69
function IngameSpecialInteraction:cb_leave()
	Application:debug("[IngameSpecialInteraction:cb_leave]")

	if self._hud:cooldown() or self._completed then
		return
	end

	if self._hud:on_leave() then
		game_state_machine:change_state_by_name(self._old_state)
	end
end

-- Lines 73-81
function IngameSpecialInteraction:cb_interact()
	Application:debug("[IngameSpecialInteraction:cb_interact]")

	if self._hud:cooldown() or self._completed then
		return
	end

	self:_check_interact()
	self:_check_all_complete()
end

-- Lines 85-87
function IngameSpecialInteraction:on_destroyed()
	Application:debug("[IngameSpecialInteraction:on_destroyed]")
end

-- Lines 91-124
function IngameSpecialInteraction:update(t, dt)
	if not self._hud then
		return
	end

	self._hud:update(t, dt)

	if self._completed then
		self._end_t = self._end_t - dt

		if self._end_t <= 0 then
			self._end_t = 0

			if alive(self._tweak_data.target_unit) and self._tweak_data.target_unit:interaction() then
				local data = self._hud:get_interaction_data()
				local itu = self._tweak_data.target_unit:interaction()

				if itu.special_interaction_done then
					itu:special_interaction_done(data)
				end

				game_state_machine:change_state_by_name(self._old_state)
			end
		end
	else
		self:_check_all_complete()
	end

	if alive(self._tweak_data.target_unit) and self._tweak_data.target_unit:unit_data()._interaction_done then
		self._completed_by_other = true

		game_state_machine:change_state_by_name(self._old_state)
	end
end

-- Lines 129-135
function IngameSpecialInteraction:update_player_stamina(t, dt)
	local player = managers.player:player_unit()

	if player and player:movement() then
		player:movement():update_stamina(t, dt, true)
	end
end

-- Lines 139-141
function IngameSpecialInteraction:_player_damage(info)
end

-- Lines 145-193
function IngameSpecialInteraction:at_enter(old_state, params)
	Application:debug("[IngameSpecialInteraction:at_enter]", inspect(params))

	local player = managers.player:player_unit()

	if alive(player) then
		player:movement():current_state():interupt_all_actions()
		player:camera():play_redirect(PlayerStandard.IDS_UNEQUIP)
		player:base():set_enabled(true)
		player:character_damage():add_listener("IngameSpecialInteraction", {
			"hurt",
			"death"
		}, callback(self, self, "_player_damage"))

		if params.sounds and params.sounds.dialog_enter then
			player:sound():say(params.sounds.dialog_enter, nil, true)
		end

		if params.sounds and params.sounds.start then
			player:sound():play(params.sounds.start)
		end

		SoundDevice:set_rtpc("stamina", 100)
	end

	self._sound_source = self._sound_source or SoundDevice:create_source("ingame_special_interaction")

	self._sound_source:set_position(player:position())

	params.sound_source = self._sound_source
	self._tweak_data = params
	self._completed = false
	self._old_state = old_state:name()

	managers.hud:remove_interact()
	player:camera():set_shaker_parameter("headbob", "amplitude", 0)

	self._hud = managers.hud:create_special_interaction(managers.hud:script(PlayerBase.INGAME_HUD_SAFERECT), params)

	self._hud:show()
	managers.hud:hide_stats_screen()
	self:_setup_controller()
	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
	managers.network:session():send_to_peers("enter_special_interaction_state", self:minigame_type())
end

-- Lines 197-235
function IngameSpecialInteraction:at_exit()
	self._sound_source:stop()
	self:_clear_controller()

	local player = managers.player:player_unit()

	if alive(player) then
		player:base():set_enabled(true)
		player:base():set_visible(true)

		player:base().skip_update_one_frame = true

		player:camera():play_redirect(PlayerStandard.IDS_EQUIP)
		player:character_damage():remove_listener("IngameSpecialInteraction")

		if self._completed and self._tweak_data.sounds and self._tweak_data.sounds.dialog_success then
			player:sound():say(self._tweak_data.sounds.dialog_success, true, true)
		end

		if self._tweak_data.sounds and self._tweak_data.sounds.finish then
			player:sound():play(self._tweak_data.sounds.finish)
		end
	end

	managers.hud:hide_special_interaction(self._completed)

	if not self._completed and not self._completed_by_other and alive(self._tweak_data.target_unit) and self._tweak_data.target_unit:interaction() and self._tweak_data.target_unit:interaction():active() then
		managers.hud:show_interact()
	end

	self._hud = nil

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
	managers.network:session():send_to_peers("exit_special_interaction_state")
end

-- Lines 239-253
function IngameSpecialInteraction:_check_interact()
	if not self._hud:check_interact() then
		local player = managers.player:player_unit()

		if alive(player) and self._tweak_data.sounds and self._tweak_data.sounds.dialog_fail then
			player:sound():say(self._tweak_data.sounds.dialog_fail, nil, true)
		end

		if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_PLAYER_FAILED_INTERACTION_MINI_GAME) then
			managers.buff_effect:fail_effect(BuffEffectManager.EFFECT_PLAYER_FAILED_INTERACTION_MINI_GAME, managers.network:session():local_peer():id())
		end
	end
end

-- Lines 257-263
function IngameSpecialInteraction:_check_all_complete()
	local completed = self._hud:check_all_complete()
	self._completed = completed

	if completed then
		self._end_t = IngameSpecialInteraction.COMPLETED_DELAY
	end
end

-- Lines 267-269
function IngameSpecialInteraction:minigame_type()
	return self._tweak_data.minigame_type
end
