require("lib/states/GameState")

IngameParachuting = IngameParachuting or class(IngamePlayerBaseState)

-- Lines 5-7
function IngameParachuting:init(game_state_machine)
	IngameParachuting.super.init(self, "ingame_parachuting", game_state_machine)
end

-- Lines 9-30
function IngameParachuting:at_enter()
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
		player:character_damage():set_invulnerable(true)
	end

	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
end

-- Lines 32-45
function IngameParachuting:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)

		local unit = safe_spawn_unit(Idstring("units/vanilla/props/props_parachute/props_parachute"), player:position(), player:rotation())

		unit:damage():run_sequence_simple("make_dynamic")
		player:character_damage():set_invulnerable(false)
		managers.worldcollection:register_spawned_unit_on_last_world(unit)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end

-- Lines 47-49
function IngameParachuting:is_joinable()
	return false
end
