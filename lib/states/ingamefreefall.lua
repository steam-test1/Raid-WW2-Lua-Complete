require("lib/states/GameState")

IngameFreefall = IngameFreefall or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameFreefall:init(game_state_machine)
	IngameFreefall.super.init(self, "ingame_freefall", game_state_machine)
end

-- Lines 9-29
function IngameFreefall:at_enter()
	local players = managers.player:players()

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

-- Lines 31-40
function IngameFreefall:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end

-- Lines 43-45
function IngameFreefall:is_joinable()
	return false
end
