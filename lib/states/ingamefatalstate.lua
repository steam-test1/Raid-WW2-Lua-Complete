require("lib/states/GameState")

IngameFatalState = IngameFatalState or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameFatalState:init(game_state_machine)
	IngameFatalState.super.init(self, "ingame_fatal", game_state_machine)
end

-- Lines 9-15
function IngameFatalState.on_local_player_dead()
	local peer_id = managers.network:session():local_peer():id()
	local player = managers.player:player_unit()

	player:network():send("sync_player_movement_state", "dead", player:character_damage():down_time(), player:id())
	managers.groupai:state():on_player_criminal_death(peer_id)
end

-- Lines 17-37
function IngameFatalState:update(t, dt)
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	if player:character_damage():update_downed(t, dt) then
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

-- Lines 40-61
function IngameFatalState:at_enter()
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
		fatal = true
	})

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
end

-- Lines 63-71
function IngameFatalState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end
