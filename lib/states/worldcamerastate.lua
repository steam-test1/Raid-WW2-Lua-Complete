require("lib/states/GameState")

WorldCameraState = WorldCameraState or class(GameState)

-- Lines 5-7
function WorldCameraState:init(game_state_machine)
	GameState.init(self, "world_camera", game_state_machine)
end

-- Lines 9-10
function WorldCameraState:at_enter()
end

-- Lines 12-13
function WorldCameraState:at_exit()
end

-- Lines 15-17
function WorldCameraState._file_streaming_profile()
	return DynamicResourceManager.STREAMING_PROFILE_LOADING
end
