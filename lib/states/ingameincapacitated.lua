require("lib/states/GameState")

IngameIncapacitatedState = IngameIncapacitatedState or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameIncapacitatedState:init(game_state_machine)
	IngameIncapacitatedState.super.init(self, "ingame_incapacitated", game_state_machine)
end

-- Lines 9-29
function IngameIncapacitatedState:update(t, dt)
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	if player:character_damage():update_incapacitated(t, dt) then
		managers.player:force_drop_carry()
		managers.statistics:downed({
			death = true
		})
		IngameFatalState.on_local_player_dead()
		game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
		player:character_damage():set_invulnerable(true)
		player:character_damage():set_health(0)
		player:base():_unregister()
		World:delete_unit(player)
	end
end

-- Lines 31-52
function IngameIncapacitatedState:at_enter()
	local players = managers.player:players()

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end

	managers.statistics:downed({
		incapacitated = true
	})

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
end

-- Lines 54-62
function IngameIncapacitatedState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end
