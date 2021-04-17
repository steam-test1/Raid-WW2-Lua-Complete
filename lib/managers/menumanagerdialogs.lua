-- Lines 1-8
function MenuManager:show_retrieving_servers_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_retrieving_servers_title"),
		text = managers.localization:text("dialog_wait"),
		id = "find_server",
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 10-22
function MenuManager:show_get_world_list_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_logging_in"),
		text = managers.localization:text("dialog_wait"),
		id = "get_world_list"
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = params.cancel_func
	}
	dialog_data.button_list = {
		cancel_button
	}
	dialog_data.indicator = true

	managers.system_menu:show(dialog_data)
end

-- Lines 24-32
function MenuManager:show_game_permission_changed_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_game_permission_changed")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 34-42
function MenuManager:show_too_low_level()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_too_low_level")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 44-52
function MenuManager:show_too_low_level_ovk145()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_too_low_level_ovk145")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 54-62
function MenuManager:show_does_not_own_heist()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_does_not_own_heist")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 64-72
function MenuManager:show_does_not_own_heist_info(heist, player)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_does_not_own_heist_info", {
			HEIST = string.upper(heist),
			PLAYER = string.upper(player)
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 74-82
function MenuManager:show_failed_joining_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_failed_joining_lobby")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 84-92
function MenuManager:show_ok_only_dialog(title, text)
	local dialog_data = {
		title = managers.localization:text(title),
		text = managers.localization:text(text)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 94-130
function MenuManager:show_smartmatch_inexact_match_dialog(params)
	local dialog_data = {
		id = "confirm_inexact_match",
		title = managers.localization:text("menu_smm_contract_inexact_match_title", {
			timeout = params.timeout
		}),
		text = managers.localization:text("menu_smm_contract_inexact_match_body", {
			host = params.host_name,
			job_name = params.job_name,
			difficulty = params.difficulty
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_inexact_match_yes"),
		callback_func = params.yes_clbk
	}
	local no_button = {
		text = managers.localization:text("dialog_inexact_match_no"),
		callback_func = params.no_clbk,
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.focus_button = 1
	local count = params.timeout
	dialog_data.counter = {
		1,
		function ()
			count = count - 1

			if count < 0 then
				params.timeout_clbk()
				managers.system_menu:close(dialog_data.id)
			else
				local dlg = managers.system_menu:get_dialog(dialog_data.id)

				if dlg then
					dlg:set_title(utf8.to_upper(managers.localization:text("menu_smm_contract_inexact_match_title", {
						timeout = count
					})))
				end
			end
		end
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 132-140
function MenuManager:show_cant_join_from_game_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_cant_join_from_game")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 142-150
function MenuManager:show_game_started_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_game_started")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 152-164
function _stop_autofire_sound()
	if not managers.player:player_unit() then
		return
	end

	local equipped_unit = managers.player:player_unit():inventory():equipped_unit()

	if equipped_unit then
		local base = equipped_unit:base()

		if base and base.shooting and base:shooting() then
			base:play_tweak_data_sound("stop_fire")
		end
	end
end

-- Lines 166-174
function MenuManager:show_joining_lobby_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_joining_lobby_title"),
		text = managers.localization:text("dialog_wait"),
		id = "join_server",
		no_buttons = true,
		indicator = true
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 176-191
function MenuManager:show_searching_match_dialog(params)
	local cancel_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_cancel"),
		callback_func = params.cancel_func
	}
	local dialog_data = {
		title = managers.localization:text("menu_smm_searching_for_contract"),
		text = managers.localization:text("dialog_wait"),
		id = "search_match",
		button_list = {
			cancel_button
		},
		indicator = true
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 193-201
function MenuManager:show_fetching_status_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_fetching_status_title"),
		text = managers.localization:text("dialog_wait"),
		id = "fetching_status",
		no_buttons = true,
		indicator = true
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 203-211
function MenuManager:show_no_connection_to_game_servers_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_no_connection_to_game_servers")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 213-221
function MenuManager:show_person_joining(id, nick)
	local dialog_data = {
		title = managers.localization:text("dialog_dropin_title", {
			USER = string.upper(nick)
		}),
		text = managers.localization:text("dialog_wait") .. " 0%",
		id = "user_dropin" .. id,
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)
	_stop_autofire_sound()
end

-- Lines 223-231
function MenuManager:show_corrupt_dlc()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_fail_load_dlc_corrupt")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 233-235
function MenuManager:close_person_joining(id)
	managers.system_menu:close("user_dropin" .. id)
end

-- Lines 237-246
function MenuManager:update_person_joining(id, progress_percentage)
	local dlg = managers.system_menu:get_dialog("user_dropin" .. id)

	if dlg then
		if progress_percentage < 100 then
			dlg:set_text(managers.localization:text("dialog_wait") .. " " .. tostring(progress_percentage) .. "%")
		else
			dlg:set_text(managers.localization:text("dialog_wait_2"))
		end
	end
end

-- Lines 248-260
function MenuManager:show_host_left_dialog(message, clbk)
	message = Global.on_remove_peer_message or message
	local dialog_data = {
		title = managers.localization:text("dialog_returning_to_main_menu"),
		text = managers.localization:text(message)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = clbk
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)

	Global.on_remove_peer_message = nil
end

-- Lines 263-271
function MenuManager:show_lost_connection_to_host_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_returning_to_main_menu"),
		text = managers.localization:text("dialog_lost_connection_to_server")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 273-281
function MenuManager:show_deleting_current_operation_save_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_deleting_current_job_title"),
		text = managers.localization:text("dialog_deleting_current_job")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 284-287
function MenuManager:show_peer_kicked_dialog(params)
	Global.on_remove_peer_message = Global.on_remove_peer_message or "dialog_mp_kicked_out_message"
end

-- Lines 290-301
function MenuManager:show_peer_already_kicked_from_game_dialog(params)
	local title = Global.on_remove_peer_message and "dialog_information_title" or "dialog_mp_kicked_out_title"
	local dialog_data = {
		title = managers.localization:text(title),
		text = managers.localization:text(Global.on_remove_peer_message or "dialog_mp_already_kicked_from_game_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params and params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)

	Global.on_remove_peer_message = nil
end

-- Lines 303-316
function MenuManager:show_default_option_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_default_options_title"),
		text = params.text
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.callback
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 318-331
function MenuManager:show_option_dialog(params)
	local dialog_data = {
		title = params.title,
		text = params.message
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.callback
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 333-346
function MenuManager:show_character_delete_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_character_delete_title"),
		text = params.text
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_yes")),
		callback_func = params.callback
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_no")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 348-357
function MenuManager:show_last_character_delete_forbiden_in_multiplayer(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = params.text
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 359-373
function MenuManager:show_respec_dialog(params)
	local dialog_data = {
		title = managers.localization:text("menu_character_skills_retrain_dialog_title"),
		text = managers.localization:text("menu_character_skills_retrain_dialog_text", {
			GOLD = params.gold
		})
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_yes")),
		class = RaidGUIControlButtonShortPrimaryGold,
		callback_func = params.callback_yes
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_no")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 375-389
function MenuManager:show_character_customization_purchase_dialog(params)
	local dialog_data = {
		title = managers.localization:text("character_customization_purchase_confirm_title"),
		text = managers.localization:text("character_customization_purchase_confirm_text", {
			AMOUNT = params.amount,
			CUSTOMIZATION_NAME = params.customization_name
		})
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_yes")),
		class = RaidGUIControlButtonShortPrimaryGold,
		callback_func = params.callback_yes
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_no")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 391-405
function MenuManager:show_gold_asset_store_purchase_dialog(params)
	local dialog_data = {
		title = managers.localization:text("gold_asset_store_dialog_buy_title"),
		text = managers.localization:text("gold_asset_store_dialog_buy_message", {
			AMOUNT = params.amount,
			GOLD_ITEM_NAME = params.item_name
		})
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_yes")),
		class = RaidGUIControlButtonShortPrimaryGold,
		callback_func = params.callback_yes
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_no")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 407-417
function MenuManager:show_skill_selection_invalid_dialog()
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("menu_character_skills_selection_invalid_title")),
		text = utf8.to_upper(managers.localization:text("menu_character_skills_selection_invalid_text")),
		focus_button = 1
	}
	local ok_button = {
		text = utf8.to_upper(managers.localization:text("dialog_ok")),
		cancel_button = true
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 419-433
function MenuManager:show_skill_selection_confirm_dialog(params)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("menu_character_skills_selection_confirmation_title")),
		text = utf8.to_upper(managers.localization:text("menu_character_skills_selection_confirmation_text")),
		focus_button = 1
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_yes")),
		callback_func = params.yes_callback
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_no")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 436-450
function MenuManager:show_kick_peer_dialog(params)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("menu_kick_confirm_title")),
		text = utf8.to_upper(managers.localization:text("menu_kick_confirm_text", {
			PLAYER = params.player_name
		})),
		focus_button = 2
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_yes")),
		callback_func = params.yes_callback
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_no")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 452-466
function MenuManager:show_save_slot_delete_confirm_dialog(params)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("menu_mission_save_slot_delete_confirmation_title")),
		text = utf8.to_upper(managers.localization:text("menu_mission_save_slot_delete_confirmation_text")),
		focus_button = 1
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_yes")),
		callback_func = params.yes_callback
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_no")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 468-486
function MenuManager:show_redeem_character_customization_dialog(params)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("menu_loot_screen_redeem_character_customization_dialog_title", {
			XP = params.xp
		})),
		text = utf8.to_upper(managers.localization:text("menu_loot_screen_dialog_text")),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.callback,
		class = RaidGUIControlButtonShortPrimary
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true,
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 488-506
function MenuManager:show_redeem_weapon_point_dialog(params)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("menu_loot_screen_redeem_weapon_point_dialog_title", {
			XP = params.xp
		})),
		text = utf8.to_upper(managers.localization:text("menu_loot_screen_dialog_text")),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.callback,
		class = RaidGUIControlButtonShortPrimary
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true,
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 508-527
function MenuManager:show_character_create_dialog(params)
	local dialog_data = {
		textbox = true,
		title = utf8.to_upper(managers.localization:text("menu_character_creation_create_title")),
		focus_button = 1,
		textbox_value = params.textbox_value
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_create")),
		class = RaidGUIControlButtonShortPrimary,
		callback_func = params.callback_yes
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_cancel")),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true,
		callback_func = params.callback_no
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 529-539
function MenuManager:show_err_character_name_dialog(params)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("dialog_error_title")),
		text = managers.localization:text(params.textbox_id),
		no_upper = true
	}
	local ok_button = {
		text = utf8.to_upper(managers.localization:text("dialog_ok")),
		callback_func = params.callback_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 541-551
function MenuManager:show_err_not_signed_in_dialog()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_error_title")),
		text = managers.localization:text("dialog_err_not_signed_in"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = function ()
			self._showing_disconnect_message = nil
		end
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 553-563
function MenuManager:show_mp_disconnected_internet_dialog(params)
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_warning_title")),
		text = managers.localization:text("dialog_mp_disconnected_internet"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 565-574
function MenuManager:show_internet_connection_required()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_error_title")),
		text = managers.localization:text("dialog_internet_connection_required"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 576-591
function MenuManager:show_err_no_chat_parental_control()
	if SystemInfo:platform() == Idstring("PS4") then
		PSN:show_chat_parental_control()
	else
		local dialog_data = {
			title = string.upper(managers.localization:text("dialog_information_title")),
			text = managers.localization:text("dialog_no_chat_parental_control"),
			no_upper = true
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)
	end
end

-- Lines 593-602
function MenuManager:show_err_under_age()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_age_restriction"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 604-613
function MenuManager:show_err_new_patch()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_new_patch"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 615-626
function MenuManager:show_waiting_for_server_response(params)
	local dialog_data = {
		title = managers.localization:text("dialog_waiting_for_server_response_title"),
		text = managers.localization:text("dialog_wait"),
		id = "waiting_for_server_response",
		indicator = true
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = params.cancel_func
	}
	dialog_data.button_list = {
		cancel_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 628-636
function MenuManager:show_request_timed_out_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_request_timed_out_title"),
		text = managers.localization:text("dialog_request_timed_out_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 638-651
function MenuManager:show_restart_game_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_show_restart_game_message")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 653-666
function MenuManager:show_return_to_camp_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_mp_restart_level_title"),
		text = managers.localization:text("dialog_mp_restart_level_host_message")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 668-681
function MenuManager:show_restart_mission_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_mp_restart_mission_title"),
		text = managers.localization:text("dialog_mp_restart_mission_host_message")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 683-691
function MenuManager:show_no_invites_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_no_invites_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 693-701
function MenuManager:show_invite_wrong_version_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_invite_wrong_version_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 703-711
function MenuManager:show_invite_wrong_room_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_invite_wrong_room_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 713-723
function MenuManager:show_invite_join_message(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_mp_invite_join_message"),
		id = "invite_join_message"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 725-735
function MenuManager:show_pending_invite_message(params)
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_mp_pending_invite_short_message"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 737-747
function MenuManager:show_game_is_installing()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_game_is_installing"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 749-759
function MenuManager:show_game_is_installing_menu()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_game_is_installing_menu"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 761-770
function MenuManager:show_NPCommerce_open_fail(params)
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_error_title")),
		text = managers.localization:text("dialog_npcommerce_fail_open"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 772-780
function MenuManager:show_NPCommerce_checkout_fail(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_npcommerce_checkout_fail")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 782-791
function MenuManager:show_waiting_NPCommerce_open(params)
	local dialog_data = {
		title = managers.localization:text("dialog_wait"),
		text = managers.localization:text("dialog_npcommerce_opening"),
		id = "waiting_for_NPCommerce_open",
		no_upper = true,
		no_buttons = true,
		indicator = true
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 793-802
function MenuManager:show_NPCommerce_browse_fail()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_npcommerce_browse_fail"),
		no_upper = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 804-812
function MenuManager:show_NPCommerce_browse_success()
	local dialog_data = {
		title = managers.localization:text("dialog_transaction_successful"),
		text = managers.localization:text("dialog_npcommerce_need_install")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 815-827
function MenuManager:show_dlc_require_restart()
	if not managers.system_menu:is_active() and not self._shown_dlc_require_restart then
		self._shown_dlc_require_restart = true
		local dialog_data = {
			title = managers.localization:text("dialog_dlc_require_restart"),
			text = managers.localization:text("dialog_dlc_require_restart_desc")
		}
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}

		managers.system_menu:show(dialog_data)
	end
end

-- Lines 829-867
function MenuManager:show_video_message_dialog(params)
	local text_params = params.text_params or {}
	text_params.player = text_params.player or tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name())
	local dialog_data = {
		title = managers.localization:text(params.title, params.title_params),
		text = managers.localization:text(params.text, text_params)
	}

	if params.button_list then
		dialog_data.button_list = params.button_list
		dialog_data.focus_button = params.focus_button or #dialog_data.button_list
	else
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}
	end

	dialog_data.texture = params.texture
	dialog_data.video = params.video or nil
	dialog_data.video_loop = params.video_loop or nil
	dialog_data.image_blend_mode = params.image_blend_mode or "normal"
	dialog_data.text_blend_mode = params.text_blend_mode or "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 620
	dialog_data.h = 532
	dialog_data.image_w = 620
	dialog_data.image_h = 300
	dialog_data.image_halign = "center"
	dialog_data.image_valign = "top"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size
	dialog_data.text_formating_color = params.formating_color or Color.white
	dialog_data.text_formating_color_table = params.color_table

	managers.system_menu:show_new_unlock(dialog_data)
end

-- Lines 869-906
function MenuManager:show_new_message_dialog(params)
	local text_params = params.text_params or {}
	text_params.player = text_params.player or tostring(managers.network.account:username() or managers.blackmarket:get_preferred_character_real_name())
	local dialog_data = {
		title = managers.localization:text(params.title, params.title_params),
		text = managers.localization:text(params.text, text_params)
	}

	if params.button_list then
		dialog_data.button_list = params.button_list
		dialog_data.focus_button = params.focus_button or #dialog_data.button_list
	else
		local ok_button = {
			text = managers.localization:text("dialog_ok")
		}
		dialog_data.button_list = {
			ok_button
		}
	end

	dialog_data.texture = params.texture
	dialog_data.video = params.video or nil
	dialog_data.video_loop = params.video_loop or nil
	dialog_data.image_blend_mode = params.image_blend_mode or "normal"
	dialog_data.text_blend_mode = params.text_blend_mode or "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 620
	dialog_data.h = 532
	dialog_data.image_w = 64
	dialog_data.image_h = 64
	dialog_data.image_valign = "top"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size
	dialog_data.text_formating_color = params.formating_color or Color.white
	dialog_data.text_formating_color_table = params.color_table

	managers.system_menu:show_new_unlock(dialog_data)
end

-- Lines 908-942
function MenuManager:show_accept_gfx_settings_dialog(func)
	local count = 10
	local dialog_data = {
		title = managers.localization:text("dialog_accept_changes_title"),
		text = managers.localization:text("dialog_accept_changes", {
			TIME = count
		}),
		id = "accept_changes"
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		class = RaidGUIControlButtonShortSecondary,
		callback_func = func,
		cancel_button = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button,
		cancel_button
	}
	dialog_data.counter = {
		1,
		function ()
			count = count - 1

			if count < 0 then
				func()
				managers.system_menu:close(dialog_data.id)
			else
				local dlg = managers.system_menu:get_dialog(dialog_data.id)

				if dlg then
					dlg:set_text(managers.localization:text("dialog_accept_changes", {
						TIME = count
					}))
				end
			end
		end
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 944-952
function MenuManager:show_key_binding_collision(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_key_binding_collision", params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 954-962
function MenuManager:show_key_binding_forbidden(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_key_binding_forbidden", params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 964-972
function MenuManager:show_no_active_characters()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_no_active_characters")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 974-982
function MenuManager:show_no_safe_for_this_drill(params)
	local dialog_data = {
		title = managers.localization:text("dialog_no_safe_for_this_drill_title"),
		text = managers.localization:text("dialog_no_safe_for_this_drill")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 984-992
function MenuManager:show_and_more_tradable_item_received(params)
	local dialog_data = {
		title = managers.localization:text("dialog_and_more_tradable_item_title"),
		text = managers.localization:text("dialog_and_more_tradable_item", {
			amount = tostring(params.amount_more)
		})
	}
	local ok_button = {
		text = managers.localization:text("dialog_new_tradable_item_accept")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 994-1010
function MenuManager:show_mask_mods_available(params)
	local dialog_data = {
		title = "",
		text = params.text_block
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.text_formating_color = Color.white
	dialog_data.text_formating_color_table = params.color_table

	managers.system_menu:show_new_unlock(dialog_data)
end

-- Lines 1012-1030
function MenuManager:show_confirm_skillpoints(params)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_place_title"),
		text = managers.localization:text(params.text_string, {
			skill = params.skill_name_localized,
			points = params.points,
			remaining_points = params.remaining_points,
			cost = managers.experience:cash_string(params.cost)
		}),
		focus_button = 1
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1032-1053
function MenuManager:show_confirm_respec_skilltree(params)
	local tree_name = managers.localization:text(tweak_data.skilltree.skilltree[params.tree].name_id)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_respec_title"),
		text = managers.localization:text("dialog_respec_skilltree", {
			tree = tree_name
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.no_upper = true

	managers.system_menu:show(dialog_data)
end

-- Lines 1055-1074
function MenuManager:show_confirm_respec_skilltree_all(params)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_respec_title"),
		text = managers.localization:text("dialog_respec_skilltree_all"),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		callback_func = params.no_func,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.no_upper = true

	managers.system_menu:show(dialog_data)
end

-- Lines 1076-1084
function MenuManager:show_skilltree_reseted()
	local dialog_data = {
		title = managers.localization:text("dialog_skills_reseted_title"),
		text = managers.localization:text("dialog_skilltree_reseted")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1086-1104
function MenuManager:show_confirm_infamypoints(params)
	local dialog_data = {
		title = managers.localization:text("dialog_skills_place_title"),
		text = managers.localization:text(params.text_string, {
			item = params.infamy_item,
			points = params.points,
			remaining_points = params.remaining_points
		}),
		focus_button = 1
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1106-1114
function MenuManager:show_infamytree_reseted()
	local dialog_data = {
		title = managers.localization:text("dialog_infamy_reseted_title"),
		text = managers.localization:text("dialog_infamytree_reseted")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1116-1124
function MenuManager:show_enable_steam_overlay()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_requires_steam_overlay")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1126-1134
function MenuManager:show_requires_big_picture()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_requires_big_picture")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1136-1148
function MenuManager:show_buying_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_checking_out"),
		id = "buy_tradable_item"
	}
	local cancel_button = {
		text = managers.localization:text("dialog_cancel"),
		callback_func = function ()
			MenuCallbackHandler:on_steam_transaction_over(true)
		end
	}
	dialog_data.button_list = {
		cancel_button
	}
	dialog_data.indicator = true

	managers.system_menu:show(dialog_data)
end

-- Lines 1150-1159
function MenuManager:show_canceled_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_canceled")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1161-1170
function MenuManager:show_success_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_success")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1172-1180
function MenuManager:show_enable_steam_overlay_tradable_item()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_requires_steam_overlay_tradable_item")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1182-1191
function MenuManager:show_error_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_error")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1193-1202
function MenuManager:show_failed_tradable_item_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_tradable_item_store_title"),
		text = managers.localization:text("dialog_tradable_item_failed")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1204-1224
function MenuManager:show_confirm_blackmarket_sell_no_slot(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_sell_title"),
		text = managers.localization:text("dialog_blackmarket_item", {
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_item_sell", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1226-1253
function MenuManager:show_confirm_blackmarket_mask_remove(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_mask_remove", {
			suffix = params.skip_money and "" or " " .. managers.localization:text("dialog_blackmarket_slot_mask_remove_suffix", {
				money = params.money
			})
		})
	}

	if params.mods_readded and #params.mods_readded > 0 then
		dialog_data.text = dialog_data.text .. "\n"

		for _, mod_id in ipairs(params.mods_readded) do
			dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("dialog_blackmarket_mask_sell_mod_readded", {
				mod = mod_id
			})
		end
	end

	dialog_data.focus_button = 2
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1255-1282
function MenuManager:show_confirm_blackmarket_mask_sell(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_item_sell", {
			money = params.money
		})
	}

	if params.mods_readded and #params.mods_readded > 0 then
		dialog_data.text = dialog_data.text .. "\n"

		for _, mod_id in ipairs(params.mods_readded) do
			dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("dialog_blackmarket_mask_sell_mod_readded", {
				mod = mod_id
			})
		end
	end

	dialog_data.focus_button = 2
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1284-1304
function MenuManager:show_confirm_blackmarket_sell(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_crafted_sell_title"),
		text = managers.localization:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.name
		}) .. "\n\n" .. managers.localization:text("dialog_blackmarket_slot_item_sell", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1306-1325
function MenuManager:show_confirm_blackmarket_buy_weapon_slot(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_weapon_buy_title"),
		text = managers.localization:text("dialog_blackmarket_buy_weapon_slot", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1327-1346
function MenuManager:show_confirm_blackmarket_buy_mask_slot(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_weapon_buy_title"),
		text = managers.localization:text("dialog_blackmarket_buy_mask_slot", {
			money = params.money
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1348-1375
function MenuManager:show_confirm_blackmarket_buy(params)
	local num_in_inventory = ""
	local num_of_same = managers.blackmarket:get_crafted_item_amount(params.category, params.weapon)

	if num_of_same > 0 then
		num_in_inventory = managers.localization:text("dialog_blackmarket_num_in_inventory", {
			item = params.name,
			amount = num_of_same
		})
	end

	local dialog_data = {
		title = managers.localization:text("dialog_bm_weapon_buy_title"),
		text = managers.localization:text("dialog_blackmarket_buy_item", {
			item = params.name,
			money = params.money,
			num_in_inventory = num_in_inventory
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1377-1429
function MenuManager:show_confirm_blackmarket_mod(params)
	local l_local = managers.localization
	local dialog_data = {
		focus_button = 2,
		title = l_local:text("dialog_bm_weapon_modify_title"),
		text = l_local:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.weapon_name
		}) .. "\n\n" .. l_local:text("dialog_blackmarket_mod_" .. (params.add and "add" or "remove"), {
			mod = params.name
		}) .. "\n"
	}
	local warn_lost_mods = false

	if params.add and params.replaces and #params.replaces > 0 then
		dialog_data.text = dialog_data.text .. l_local:text("dialog_blackmarket_mod_replace", {
			mod = managers.weapon_factory:get_part_name_by_part_id(params.replaces[1])
		}) .. "\n"
		warn_lost_mods = true
	end

	if params.removes and #params.removes > 0 then
		local mods = ""

		for _, mod_name in ipairs(params.removes) do
			if Application:production_build() and managers.weapon_factory:is_part_standard_issue(mod_name) then
				Application:error("[MenuManager:show_confirm_blackmarket_mod] Standard Issuse Part Detected!", inspect(params))
			end

			mods = mods .. "\n" .. managers.weapon_factory:get_part_name_by_part_id(mod_name)
		end

		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_mod_conflict", {
			mods = mods
		}) .. "\n"
		warn_lost_mods = true
	end

	if not params.ignore_lost_mods and (warn_lost_mods or not params.add) then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_lost_mods_warning")
	end

	if params.add and params.money then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_blackmarket_mod_cost", {
			money = params.money
		})
	end

	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1431-1467
function MenuManager:show_confirm_weapon_cosmetics(params)
	local l_local = managers.localization
	local dialog_data = {
		type = "weapon_stats",
		focus_button = 2,
		title = l_local:text("dialog_bm_weapon_modify_title"),
		text = l_local:text("dialog_blackmarket_slot_item", {
			slot = params.slot,
			item = params.weapon_name
		}) .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_" .. (params.item_has_cosmetic and "add" or "remove"), {
			cosmetic = params.name
		})
	}

	if params.item_has_cosmetic and params.crafted_has_cosmetic then
		dialog_data.text = dialog_data.text .. "\n" .. l_local:text("dialog_weapon_cosmetics_replace", {
			cosmetic = params.crafted_name
		})
	end

	if params.crafted_has_default_blueprint and not params.item_has_default_blueprint then
		dialog_data.text = dialog_data.text .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_remove_blueprint")
	elseif not params.crafted_has_default_blueprint and params.item_has_default_blueprint then
		dialog_data.text = dialog_data.text .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_set_blueprint")
	end

	if params.customize_locked then
		dialog_data.text = dialog_data.text .. "\n\n" .. l_local:text("dialog_weapon_cosmetics_locked")
	end

	local yes_button = {
		text = managers.localization:text("dialog_apply"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1469-1497
function MenuManager:show_confirm_blackmarket_assemble(params)
	local num_in_inventory = ""
	local num_of_same = managers.blackmarket:get_crafted_item_amount(params.category, params.weapon)

	if num_of_same > 0 then
		num_in_inventory = managers.localization:text("dialog_blackmarket_num_in_inventory", {
			item = params.name,
			amount = num_of_same
		})
	end

	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_assemble_title"),
		text = managers.localization:text("dialog_blackmarket_assemble_item", {
			item = params.name,
			num_in_inventory = num_in_inventory
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1499-1517
function MenuManager:show_confirm_blackmarket_abort(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_custom_abort"),
		text = managers.localization:text("dialog_blackmarket_abort_mask_warning"),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1519-1538
function MenuManager:show_confirm_blackmarket_finalize(params)
	local dialog_data = {
		title = managers.localization:text("dialog_bm_mask_custom_final_title"),
		text = managers.localization:text("dialog_blackmarket_finalize_item", {
			money = params.money,
			ITEM = managers.localization:text("dialog_blackmarket_slot_item", {
				item = params.name,
				slot = params.slot
			})
		}),
		focus_button = 2
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = params.no_func,
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1540-1557
function MenuManager:show_storage_removed_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_storage_removed_warning_X360"),
		force = true
	}
	local ok_button = {
		text = managers.localization:text("dialog_continue")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show_platform(dialog_data)
end

-- Lines 1559-1567
function MenuManager:show_game_no_longer_exists(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_room_no_longer_exists")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1569-1577
function MenuManager:show_game_is_full(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_err_room_is_full")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1579-1587
function MenuManager:show_wrong_version_message()
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_err_wrong_version_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1589-1600
function MenuManager:show_inactive_user_accepted_invite(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_inactive_user_accepted_invite_error"),
		id = "inactive_user_accepted_invite"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1602-1615
function MenuManager:show_question_start_tutorial(params)
	local dialog_data = {
		focus_button = 1,
		title = managers.localization:text("dialog_safehouse_title"),
		text = managers.localization:text("dialog_safehouse_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1617-1629
function MenuManager:show_leave_safehouse_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_safehouse_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_to_leave_game")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1631-1639
function MenuManager:show_save_settings_failed(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("dialog_save_settings_failed")
	}
	local ok_button = {
		text = managers.localization:text("dialog_continue")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1641-1655
function MenuManager:show_play_safehouse_question(params)
	local dialog_data = {
		focus_button = 1,
		title = managers.localization:text("dialog_safehouse_title"),
		text = managers.localization:text("dialog_safehouse_goto_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1657-1669
function MenuManager:show_savefile_wrong_version(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text(params.error_msg),
		id = "wrong_version"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:add_init_show(dialog_data)
end

-- Lines 1671-1683
function MenuManager:show_savefile_wrong_user(params)
	local dialog_data = {
		title = managers.localization:text("dialog_information_title"),
		text = managers.localization:text("dialog_load_wrong_user"),
		id = "wrong_user"
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:add_init_show(dialog_data)
end

-- Lines 1685-1698
function MenuManager:show_account_picker_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_account_picker")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true,
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1700-1713
function MenuManager:show_abort_mission_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_abort_mission_text")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		cancel_button = true,
		class = RaidGUIControlButtonShortSecondary
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1715-1724
function MenuManager:show_safe_error_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text(params.string_id)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_button
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1726-1740
function MenuManager:show_specialization_xp_convert(xp_present, points_present)
	local dialog_data = {
		title = managers.localization:text("dialog_xp_to_specialization"),
		xp_present = xp_present,
		points_present = points_present
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.focus_button = 1
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show_specialization_convert(dialog_data)
end

-- Lines 1742-1754
function MenuManager:show_infamous_message(can_become_infamous)
	local dialog_data = {
		title = managers.localization:text("dialog_infamous_info_title")
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.focus_button = 1
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1756-1778
function MenuManager:show_challenge_warn_choose_reward(params)
	local dialog_data = {
		title = managers.localization:text("dialog_challenge_warn_choose_reward_title"),
		text = managers.localization:text("dialog_challenge_warn_choose_reward", {
			reward = params.reward
		})
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = params.yes_func
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}
	dialog_data.texture = params.image
	dialog_data.image_w = 128
	dialog_data.image_h = 128
	dialog_data.image_valign = "center"

	managers.system_menu:show_new_unlock(dialog_data)
end

-- Lines 1780-1868
function MenuManager:show_challenge_reward(reward)
	local category = reward.type_items
	local id = reward.item_entry
	local td = tweak_data:get_raw_value("blackmarket", category, id)

	if not td then
		return
	end

	local amount = reward.amount or 1
	local name_string = td.name_id and managers.localization:text(td.name_id)
	local params = {}

	if category == "cash" then
		local money = tweak_data:get_value("money_manager", "loot_drop_cash", td.value_id) or 100
		params.cash = managers.experience:cash_string(money * amount)
	elseif category == "xp" then
		local xp = tweak_data:get_value("experience_manager", "loot_drop_value", td.value_id) or 0
		params.xp = managers.experience:experience_string(xp * amount)
	elseif category == "weapon_mods" then
		params.item = name_string
		params.amount = string.add_decimal_marks_to_string(tostring(amount))
		local list_of_weapons = managers.weapon_factory:get_weapons_uses_part(id) or {}

		if table.size(list_of_weapons) <= 4 then
			local s = " ("

			for _, factory_id in pairs(list_of_weapons) do
				s = s .. managers.weapon_factory:get_weapon_name_by_factory_id(factory_id)
				s = s .. ", "
			end

			s = s:sub(1, -3) .. ")"
			params.item = params.item .. s
		end
	else
		params.item = name_string
		params.amount = string.add_decimal_marks_to_string(tostring(amount))
	end

	local dialog_id = category == "cash" and "dialog_challenge_reward_cash" or category == "xp" and "dialog_challenge_reward_xp" or amount > 1 and "dialog_challenge_reward_plural" or "dialog_challenge_reward"
	local dialog_data = {
		title = managers.localization:text("dialog_challenge_reward_title"),
		text = managers.localization:text(dialog_id, params)
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = function ()
			MenuCallbackHandler:refresh_node()
		end
	}
	dialog_data.button_list = {
		ok_button
	}
	local texture_path = "guis/textures/pd2/endscreen/what_is_this"
	local guis_catalog = "guis/"
	local bundle_folder = td.texture_bundle_folder

	if bundle_folder then
		guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
	end

	if category == "textures" then
		texture_path = td.texture
	elseif category == "cash" then
		texture_path = "guis/textures/pd2/blackmarket/cash_drop"
	elseif category == "xp" then
		texture_path = "guis/textures/pd2/blackmarket/xp_drop"
	elseif category ~= "colors" then
		texture_path = guis_catalog .. "textures/pd2/blackmarket/icons/" .. (category == "weapon_mods" and "mods" or category) .. "/" .. id
	end

	dialog_data.texture = texture_path
	dialog_data.text_blend_mode = "add"
	dialog_data.use_text_formating = true
	dialog_data.w = 400
	dialog_data.h = 320
	dialog_data.image_w = 128
	dialog_data.image_h = 128
	dialog_data.image_valign = "center"
	dialog_data.title_font = tweak_data.menu.pd2_medium_font
	dialog_data.title_font_size = tweak_data.menu.pd2_medium_font_size
	dialog_data.font = tweak_data.menu.pd2_small_font
	dialog_data.font_size = tweak_data.menu.pd2_small_font_size

	managers.system_menu:show_new_unlock(dialog_data)
	managers.menu_component:post_event("sidejob_stinger_short")
end

-- Lines 1870-1878
function MenuManager:show_inventory_load_fail_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_inventory_load_fail_title"),
		text = managers.localization:text("dialog_inventory_load_fail_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1880-1895
function MenuManager:show_really_quit_the_game_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_to_quit")
	}
	local yes_button = {}
	local no_button = {}
	yes_button.text = managers.localization:text("dialog_yes")
	yes_button.callback_func = params.yes_func
	no_button.text = managers.localization:text("dialog_no")
	no_button.class = RaidGUIControlButtonShortSecondary
	no_button.cancel_button = true
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1897-1912
function MenuManager:show_unlock_mission_confirm_dialog(params)
	local dialog_data = {
		title = managers.localization:text("mission_unlock_screen_confirm_unlock_title", {
			RAID = params.mission_title
		}),
		text = managers.localization:text("mission_unlock_screen_confirm_unlock_subtitle")
	}
	local yes_button = {}
	local no_button = {}
	yes_button.text = managers.localization:text("dialog_yes")
	yes_button.callback_func = params.yes_func
	no_button.text = managers.localization:text("dialog_no")
	no_button.class = RaidGUIControlButtonShortSecondary
	no_button.cancel_button = true
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end
