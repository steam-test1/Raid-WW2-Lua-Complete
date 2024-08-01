core:import("CoreInternalGameState")

GameState = GameState or class(CoreInternalGameState.GameState)

function GameState:freeflight_drop_player(pos, rot)
	if managers.player then
		managers.player:warp_to(pos, rot)
	end
end

function GameState:set_controller_enabled(enabled)
end

function GameState:default_transition(next_state, params)
	self:at_exit(next_state, params)
	self:set_controller_enabled(false)

	if self:gsm():is_controller_enabled() then
		next_state:set_controller_enabled(true)
	end

	managers.dyn_resource:set_file_streaming_profile(next_state._file_streaming_profile())
	next_state:at_enter(self, params)
end

function GameState:on_disconnected()
end

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

function GameState:on_kicked()
	managers.menu:show_peer_kicked_dialog()
	managers.menu_component:post_event("kick_player")
end

function GameState:is_joinable()
	return true
end

function GameState._file_streaming_profile()
	return DynamicResourceManager.STREAMING_PROFILE_INGAME
end

CoreClass.override_class(CoreInternalGameState.GameState, GameState)
