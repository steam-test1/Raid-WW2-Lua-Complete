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

-- Lines 13-26
function GameState:default_transition(next_state, params)
	self:at_exit(next_state, params)
	self:set_controller_enabled(false)

	if self:gsm():is_controller_enabled() then
		next_state:set_controller_enabled(true)
	end

	managers.dyn_resource:set_file_streaming_profile(next_state._file_streaming_profile())
	next_state:at_enter(self, params)
end

-- Lines 28-29
function GameState:on_disconnected()
end

-- Lines 31-42
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

-- Lines 44-47
function GameState:on_kicked()
	managers.menu:show_peer_kicked_dialog()
	managers.menu_component:post_event("kick_player")
end

-- Lines 49-51
function GameState:is_joinable()
	return true
end

-- Lines 53-55
function GameState._file_streaming_profile()
	return DynamicResourceManager.STREAMING_PROFILE_INGAME
end

CoreClass.override_class(CoreInternalGameState.GameState, GameState)
