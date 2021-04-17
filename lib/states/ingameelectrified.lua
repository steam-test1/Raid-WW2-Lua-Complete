require("lib/states/GameState")

IngameElectrifiedState = IngameElectrifiedState or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameElectrifiedState:init(game_state_machine)
	IngamePlayerBaseState.super.init(self, "ingame_electrified", game_state_machine)
end

-- Lines 9-10
function IngameElectrifiedState:update(t, dt)
end

-- Lines 12-34
function IngameElectrifiedState:at_enter()
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

-- Lines 36-44
function IngameElectrifiedState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end
