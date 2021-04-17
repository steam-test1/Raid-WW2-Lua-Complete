core:import("CoreInternalGameState")

GameState = GameState or class(CoreInternalGameState.GameState)

-- Lines 5-9
function GameState:freeflight_drop_player(pos, rot)
	if managers.player then
		managers.player:warp_to(pos, rot)
	end
end

-- Lines 11-11
function GameState:set_controller_enabled(enabled)
end

-- Lines 13-23
function GameState:default_transition(next_state, params)
	self:at_exit(next_state, params)
	self:set_controller_enabled(false)

	if self:gsm():is_controller_enabled() then
		next_state:set_controller_enabled(true)
	end

	next_state:at_enter(self, params)
end

-- Lines 25-26
function GameState:on_disconnected()
end

-- Lines 28-39
function GameState:on_server_left(message)
	managers.worldcollection:on_server_left()

	if managers.game_play_central then
		managers.game_play_central:stop_the_game()
	end

	if message then
		managers.menu:show_host_left_dialog(message, MenuCallbackHandler._dialog_end_game_yes)
	else
		MenuCallbackHandler:_dialog_end_game_yes()
	end
end

-- Lines 41-44
function GameState:on_kicked()
	managers.menu:show_peer_kicked_dialog()
	managers.menu_component:post_event("kick_player")
end

-- Lines 46-48
function GameState:is_joinable()
	return true
end

CoreClass.override_class(CoreInternalGameState.GameState, GameState)
