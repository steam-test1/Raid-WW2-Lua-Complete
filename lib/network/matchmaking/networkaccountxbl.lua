require("lib/network/matchmaking/NetworkAccount")

NetworkAccountXBL = NetworkAccountXBL or class(NetworkAccount)

function NetworkAccountXBL:init()
	NetworkAccount.init(self)
end

function NetworkAccountXBL:signin_state()
	local xbl_state = managers.user:signed_in_state(managers.user:get_index())
	local game_signin_state = self:_translate_signin_state(xbl_state)

	return game_signin_state
end

function NetworkAccountXBL:local_signin_state()
	local xbl_state = managers.user:signed_in_state(managers.user:get_index())

	if xbl_state == "not_signed_in" then
		return "not signed in"
	end

	if xbl_state == "signed_in_locally" then
		return "signed in"
	end

	if xbl_state == "signed_in_to_live" then
		return "signed in"
	end

	return "not signed in"
end

function NetworkAccountXBL:show_signin_ui()
end

function NetworkAccountXBL:username_id()
	return Global.user_manager.user_index and Global.user_manager.user_map[Global.user_manager.user_index].username or ""
end

function NetworkAccountXBL:player_id()
	return managers.user:get_xuid(nil)
end

function NetworkAccountXBL:is_connected()
	return true
end

function NetworkAccountXBL:lan_connection()
	return true
end

function NetworkAccountXBL:publish_statistics(stats, force_store)
	Application:error("NetworkAccountXBL:publish_statistics( stats, force_store )")
	Application:stack_dump()
end

function NetworkAccountXBL:challenges_loaded()
	self._challenges_loaded = true
end

function NetworkAccountXBL:experience_loaded()
	self._experience_loaded = true
end

function NetworkAccountXBL:_translate_signin_state(xbl_state)
	if xbl_state == "signed_in_to_live" then
		return "signed in"
	end

	return "not signed in"
end

function NetworkAccountXBL:inventory_load()
	if self:local_signin_state() == "signed in" then
		self:_clbk_inventory_load(nil, Global.console_local_inventory)
	end
end

function NetworkAccountXBL:_clbk_inventory_load(error, list)
	local filtered_list = self:_verify_filter_cards(list)

	managers.system_event_listener:call_listeners(CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_LOADED, {
		error = nil,
		list = nil,
		error = error,
		list = filtered_list
	})
end

function NetworkAccountXBL:_verify_filter_cards(card_list)
	Application:trace("[NetworkAccountXBL:_verify_filter_cards] card_list: ", inspect(card_list))

	local result = {}

	if card_list == nil or next(card_list) == nil then
		return result
	end

	local filtered_list = {}

	if card_list then
		for _, cc_steamdata in pairs(card_list) do
			if cc_steamdata.category == ChallengeCardsManager.INV_CAT_CHALCARD then
				local cc_tweakdata = managers.challenge_cards:get_challenge_card_data(cc_steamdata.entry)

				if cc_tweakdata then
					if not filtered_list[cc_tweakdata.key_name] then
						filtered_list[cc_tweakdata.key_name] = cc_tweakdata
						filtered_list[cc_tweakdata.key_name].steam_instances = {}
					end

					local instance_id = cc_steamdata.instance_id or #filtered_list[cc_tweakdata.key_name].steam_instances
					filtered_list[cc_tweakdata.key_name].steam_instances[tostring(instance_id)] = {
						stack_amount = nil,
						stack_amount = cc_steamdata.amount or 1
					}
				end
			end
		end
	end

	for card_key_name, card_data in pairs(filtered_list) do
		table.insert(result, card_data)
	end

	return result
end

function NetworkAccountXBL:inventory_remove(key_name_id)
	local card_data = managers.challenge_cards:get_challenge_card_data(key_name_id)

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

function NetworkAccountXBL:inventory_reward(key_name_id, callback_ref)
	Application:trace("[NetworkAccountXBL:inventory_reward] " .. key_name_id)

	local cardsAwarded = {}
	local bundleData = managers.challenge_cards:get_card_bundle_def(key_name_id)

	if bundleData ~= nil then
		local cardDefinitionsAwarded = managers.challenge_cards:generate_cards_from_bundle(bundleData)

		for _, card in pairs(cardDefinitionsAwarded) do
			local added = false

			if not added then
				local new_card = {
					amount = 1,
					bonus = false,
					category = "challenge_card",
					def_id = card.def_id,
					entry = card.key_name,
					quality = ""
				}

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
