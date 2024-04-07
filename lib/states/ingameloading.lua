require("lib/states/GameState")

IngameLoading = IngameLoading or class(IngamePlayerBaseState)

function IngameLoading:init(game_state_machine)
	IngameLoading.super.init(self, "ingame_loading", game_state_machine)
end

function IngameLoading:_setup_controller()
	self._controller = managers.controller:create_controller("ingame_loading", managers.controller:get_default_wrapper_index(), false)
	self._continue_cb = callback(self, self, "continue")

	self._controller:set_enabled(true)
end

function IngameLoading:_clear_controller()
	if self._controller then
		self._controller:set_enabled(false)
		self._controller:destroy()

		self._controller = nil
	end
end

function IngameLoading:set_controller_enabled(enabled)
	if self._controller then
		self._controller:set_enabled(enabled)
	end
end

function IngameLoading:continue()
	game_state_machine:change_state_by_name(self._old_state)
end

function IngameLoading:on_destroyed()
	return
end

function IngameLoading:update(t, dt)
	return
end

function IngameLoading:at_enter(old_state, params)
	self._old_state = old_state:name()
	self._old_state = "ingame_standard"

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
		player:movement():current_state():interupt_all_actions()
	end

	managers.hud:hide_comm_wheel(true)

	managers.worldcollection.team_ai_transition = true

	managers.groupai:state():on_criminal_team_AI_enabled_state_changed()
	managers.raid_menu:on_escape(true)
	self:_setup_controller()
end

function IngameLoading:at_exit()
	managers.worldcollection.team_ai_transition = false

	managers.groupai:state():on_criminal_team_AI_enabled_state_changed(true)

	if managers.player:local_player() and managers.player:local_player():movement() and managers.player:local_player():movement():current_state() then
		managers.player:local_player():movement():current_state()._state_data.in_air = false
	end

	self:_clear_controller()
end

function IngameLoading:game_ended()
	return true
end

function IngameLoading:is_joinable()
	return false
end
