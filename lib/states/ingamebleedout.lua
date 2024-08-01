require("lib/states/GameState")

IngameBleedOutState = IngameBleedOutState or class(IngamePlayerBaseState)

function IngameBleedOutState:init(game_state_machine)
	IngameBleedOutState.super.init(self, "ingame_bleed_out", game_state_machine)
end

function IngameBleedOutState:update(t, dt)
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	if player:movement():nav_tracker() and player:character_damage():update_downed(t, dt) then
		managers.player:force_drop_carry()
		managers.statistics:downed({
			death = true
		})
		IngameFatalState.on_local_player_dead()
		player:base():set_enabled(false)
		game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
		player:character_damage():set_invulnerable(true)
		player:character_damage():set_health(0)
		player:base():_unregister()
		World:delete_unit(player)
	end
end

function IngameBleedOutState:at_enter()
	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_NO_BLEEDOUT_PUMPIKIN_REVIVE) then
		managers.player:kill()

		return
	end

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
		bleed_out = true
	})

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
	end

	managers.warcry:downed()
	managers.dialog:queue_dialog("player_gen_downed", {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})
	managers.hud:show(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:show(PlayerBase.INGAME_HUD_FULLSCREEN)
end

function IngameBleedOutState:at_exit()
	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(false)
	end

	managers.hud:hide(PlayerBase.INGAME_HUD_SAFERECT)
	managers.hud:hide(PlayerBase.INGAME_HUD_FULLSCREEN)
end
