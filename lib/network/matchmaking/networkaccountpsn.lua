require("lib/network/matchmaking/NetworkAccount")

NetworkAccountPSN = NetworkAccountPSN or class(NetworkAccount)

function NetworkAccountPSN:init()
	NetworkAccount.init(self)
end

function NetworkAccountPSN:signin_state()
	if PSN:is_online() == true then
		return "signed in"
	end

	return "not signed in"
end

function NetworkAccountPSN:local_signin_state()
	if not PSN:cable_connected() then
		return false
	end

	local n = PSN:get_localinfo()

	if not n then
		return false
	end

	if not n.local_ip then
		return false
	end

	return true
end

function NetworkAccountPSN:show_signin_ui()
	PSN:display_online_connection()
end

function NetworkAccountPSN:username_id()
	local online_name = PSN:get_npid_user()

	if online_name then
		return online_name
	else
		local local_user_info_name = PS3:get_userinfo()

		if local_user_info_name then
			return local_user_info_name
		end
	end

	return managers.localization:text("menu_mp_player")
end

function NetworkAccountPSN:player_id()
	if PSN:get_npid_user() == nil then
		local n = PSN:get_localinfo()

		if n and n.local_ip then
			return n.local_ip
		end

		Application:error("Could not get local ip, returning \"player_id\" VERY BAD!.")

		return "player_id"
	end

	return PSN:get_npid_user()
end

function NetworkAccountPSN:is_connected()
	return true
end

function NetworkAccountPSN:lan_connection()
	return PSN:cable_connected()
end

function NetworkAccountPSN:_lan_ip()
	local l = PSN:get_lan_info()

	if l and l.lan_ip then
		return l.lan_ip
	end

	return "player_lan"
end

function NetworkAccountPSN:publish_statistics(stats, force_store)
	Application:debug("NetworkAccountPSN:publish_statistics has been stubbed, does nothing")
end

function NetworkAccountPSN:achievements_fetched()
	self._achievements_fetched = true
end

function NetworkAccountPSN:challenges_loaded()
	self._challenges_loaded = true
end

function NetworkAccountPSN:experience_loaded()
	self._experience_loaded = true
end

function NetworkAccountPSN:inventory_load()
	self:_clbk_inventory_load(nil, Global.console_local_inventory)
end

function NetworkAccountPSN:_clbk_inventory_load(error, list)
	local filtered_list = self:_verify_filter_cards(list)

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_LOADED, {
		error = error,
		list = filtered_list
	})
end

function NetworkAccountPSN:_verify_filter_cards(card_list)
	Application:trace("[NetworkAccountPSN:_verify_filter_cards] card_list: ", inspect(card_list))

	local result = {}

	if card_list == nil or next(card_list) == nil then
		return result
	end

	local filtered_list = {}

	for _, card_data in pairs(card_list) do
		if card_data.category == "challenge_card" then
			local challenge_card_data = managers.challenge_cards:get_challenge_card_data(card_data.entry)

			if challenge_card_data then
				if not filtered_list[challenge_card_data.key_name] then
					filtered_list[challenge_card_data.key_name] = challenge_card_data
					filtered_list[challenge_card_data.key_name].steam_instance_ids = {}
				end

				table.insert(filtered_list[challenge_card_data.key_name].steam_instance_ids, card_data.instance_id or "1")
			end
		end
	end

	for card_key_name, card_data in pairs(filtered_list) do
		table.insert(result, card_data)
	end

	return result
end

function NetworkAccountPSN:inventory_remove(item_def_id)
	local card_data = managers.challenge_cards:get_challenge_card_data(item_def_id)

	if card_data then
		local card_list = Global.console_local_inventory

		for i = 1, #card_list do
			if card_list[i].def_id == card_data.def_id then
				if card_list[i].amount > 1 then
					card_list[i].amount = card_list[i].amount - 1
				else
					table.remove(card_list, i)
				end

				return true
			end
		end

		return false
	end
end

function NetworkAccountPSN:inventory_reward(key_name_id, callback_ref)
	local cardsAwarded = {}
	local bundleData = managers.challenge_cards:get_card_bundle_def(key_name_id)

	if bundleData ~= nil then
		local cardDefinitionsAwarded = managers.challenge_cards:generate_cards_from_bundle(bundleData)

		for _, card in pairs(cardDefinitionsAwarded) do
			local added = false

			if not added then
				local new_card = {}

				new_card.amount = 1
				new_card.bonus = false
				new_card.category = "challenge_card"
				new_card.def_id = card.def_id
				new_card.entry = card.key_name
				new_card.quality = ""

				table.insert(Global.console_local_inventory, new_card)
			end

			table.insert(cardsAwarded, card)
		end

		if callback_ref then
			callback_ref(nil, cardDefinitionsAwarded)
		end
	end

	Global.savefile_manager.setting_changed = true

	managers.savefile:save_setting(true)
end
