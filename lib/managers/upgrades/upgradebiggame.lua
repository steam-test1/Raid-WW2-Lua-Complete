local UpgradeBigGame = {}

function UpgradeBigGame:check_activate()
	if managers.player:has_category_upgrade("player", "big_game_special_sense") then
		managers.player:add_coroutine("big_game_special_sense", UpgradeBigGame.update)
	else
		managers.player:remove_coroutine("big_game_special_sense")
	end

	managers.system_event_listener:remove_listener("big_game_special_health_regen")

	if managers.player:has_category_upgrade("temporary", "big_game_special_health_regen") then
		managers.system_event_listener:add_listener("big_game_special_health_regen", {
			CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
		}, callback(self, self, "_on_enemy_killed"))
	end
end

function UpgradeBigGame.update()
	local player = managers.player:local_player()

	if not alive(player) then
		return
	end

	local retrigger_time = managers.player:upgrade_value("player", "big_game_retrigger_time")
	local search_radius = managers.player:upgrade_value("player", "big_game_special_sense") * 100
	local slotmask = managers.slot:get_mask("enemies")

	coroutine.yield(retrigger_time)

	while alive(player) do
		local sensed_targets = World:find_units_quick("sphere", player:movement():m_pos(), search_radius, slotmask)
		local play_callout = false

		for _, unit in ipairs(sensed_targets) do
			if alive(unit) and (unit:base():is_special() or unit:unit_data().turret_weapon) then
				local marked = managers.game_play_central:auto_highlight_enemy(unit, true)
				play_callout = play_callout or marked and UpgradeBigGame._play_callout(unit)
			end
		end

		if play_callout then
			managers.dialog:queue_dialog("shout_feel_spotter", {
				skip_idle_check = true,
				instigator = player
			})
		end

		coroutine.yield(retrigger_time)
	end
end

function UpgradeBigGame._play_callout(unit)
	local special_type = unit:base():special_type()

	return special_type == CharacterTweakData.SPECIAL_UNIT_TYPE_SNIPER or special_type == CharacterTweakData.SPECIAL_UNIT_TYPE_SPOTTER
end

function UpgradeBigGame:_on_enemy_killed(params)
	if params.special_enemy_type and params.enemy_marked then
		managers.player:activate_temporary_upgrade("temporary", "big_game_special_health_regen")
	end
end

return UpgradeBigGame
