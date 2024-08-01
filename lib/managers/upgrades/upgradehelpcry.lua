local UpgradeHelpCry = {}

function UpgradeHelpCry:check_activate()
	managers.player:remove_coroutine("helpcry_warcry_auto_fill")

	if managers.player:has_category_upgrade("player", "helpcry_warcry_auto_fill") then
		managers.player:add_coroutine("helpcry_warcry_auto_fill", UpgradeHelpCry.update)
	end
end

function UpgradeHelpCry.update()
	local player = managers.player:local_player()

	if not alive(player) then
		return
	end

	local base_fill_amount = managers.warcry:get_active_warcry():base_kill_fill_amount()
	local fill_amount = base_fill_amount * tweak_data.upgrades.helpcry_warcry_fill_multiplier
	local timer = managers.player:upgrade_value("player", "helpcry_warcry_auto_fill")

	coroutine.yield(timer)

	while alive(player) do
		local damage_ext = player:character_damage()
		local action_forbidden = damage_ext:is_downed() or damage_ext:is_perseverating() or managers.groupai:state():whisper_mode()

		if not action_forbidden then
			managers.warcry:fill_meter_by_value(fill_amount, true)
		end

		coroutine.yield(timer)
	end
end

return UpgradeHelpCry
