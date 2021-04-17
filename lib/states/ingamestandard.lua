require("lib/states/GameState")

IngameStandardState = IngameStandardState or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameStandardState:init(game_state_machine)
	IngameStandardState.super.init(self, "ingame_standard", game_state_machine)
end

-- Lines 9-35
function IngameStandardState:at_enter()
	local players = managers.player:players()

	if managers.global_state.fire_character_created_event then
		Application:debug("[IngameStandardState:enter] managers.global_state:fire_event(GlobalStateManager.EVENT_CHARACTER_CREATED)")

		managers.global_state.fire_character_created_event = nil

		managers.global_state:fire_event(GlobalStateManager.EVENT_CHARACTER_CREATED)
	end

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
end

-- Lines 37-47
function IngameStandardState:at_exit()
	managers.environment_controller:set_dof_distance()

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end
