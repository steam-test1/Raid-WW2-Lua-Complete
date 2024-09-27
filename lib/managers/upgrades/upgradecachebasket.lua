local UpgradeCacheBasket = {}

function UpgradeCacheBasket:check_activate()
	managers.player:remove_coroutine("cache_basket_ammo_regen")

	if managers.player:has_team_category_upgrade("player", "warcry_ammo_regeneration") then
		managers.player:add_coroutine("cache_basket_ammo_regen", UpgradeCacheBasket.update)
	end
end

function UpgradeCacheBasket.update()
	local player = managers.player:local_player()

	if not alive(player) then
		return
	end

	local inventory_ext = player:inventory()
	local timer = 1
	local regeneration_amount = managers.player:team_upgrade_value("player", "warcry_ammo_regeneration", 1) - 1

	while alive(player) and managers.player:has_team_category_upgrade("player", "warcry_ammo_regeneration") do
		for id, weapon in pairs(inventory_ext:available_selections()) do
			if weapon.unit:base():uses_ammo() then
				local total_ammo = weapon.unit:base():get_ammo_max()

				weapon.unit:base():add_ammo(1, total_ammo * regeneration_amount, true)
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end

		coroutine.yield(timer)
	end
end

return UpgradeCacheBasket
