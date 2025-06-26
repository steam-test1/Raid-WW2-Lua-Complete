function MenuManager:show_custom_popup_dialog(dialog_data, buttons)
	if buttons then
		dialog_data.focus_button = dialog_data.focus_button or 1
		dialog_data.button_list = {}

		for _, button_data in ipairs(buttons) do
			table.insert(dialog_data.button_list, button_data)
		end
	end

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_retrieving_servers_dialog()
	local dialog_data = {
		title = managers.localization:text("dialog_retrieving_servers_title"),
		text = managers.localization:text("dialog_wait"),
		id = "find_server",
		no_buttons = true
	}

	managers.system_menu:show(dialog_data)
end

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

function MenuManager:show_person_joining(id, nick)
	if managers.user:get_setting("capitalize_names") then
		nick = utf8.to_upper(nick)
	end

	local dialog_data = {
		no_buttons = true,
		title = managers.localization:text("dialog_dropin_title", {
			USER = nick
		}),
		text = managers.localization:text("dialog_wait") .. " 0%",
		id = "user_dropin" .. id
	}

	managers.system_menu:show(dialog_data)

	if managers.network.voice_chat then
		managers.network.voice_chat:trc_check_mute()
	end
end

function MenuManager:close_person_joining(id)
	managers.system_menu:close("user_dropin" .. id)

	if managers.network.voice_chat then
		managers.network.voice_chat:trc_check_unmute()
	end
end

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

function MenuManager:show_peer_kicked_dialog(params)
	Global.on_remove_peer_message = Global.on_remove_peer_message or "dialog_mp_kicked_out_message"
end

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

function MenuManager:show_mod_overrides_warning_dialog(params)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("menu_mod_overrides_warning_title")),
		text = managers.localization:text("menu_mod_overrides_warning_text"),
		focus_button = 1
	}
	local yes_button = {
		text = utf8.to_upper(managers.localization:text("dialog_go_to_mod_overrides")),
		class = RaidGUIControlButtonShortPrimary,
		callback_func = params.callback_yes
	}
	local no_button = {
		text = utf8.to_upper(managers.localization:text("dialog_skip")),
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

function MenuManager:show_voice_chat_blocked_dialog(clbk)
	local dialog_data = {
		title = utf8.to_upper(managers.localization:text("dialog_warning_title")),
		text = managers.localization:text("dialog_err_online_insufficient_privileges_voicechat"),
		no_upper = true
	}
	local ok_button = {
		text = utf8.to_upper(managers.localization:text("dialog_ok")),
		callback_func = clbk and clbk or nil
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

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

function MenuManager:show_mp_disconnected_internet_dialog(params)
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_warning_title"))
	}
	local text_string = "dialog_mp_disconnected_internet"
	dialog_data.text = managers.localization:text(text_string)
	dialog_data.no_upper = true
	dialog_data.id = "show_mp_disconnected_internet_dialog"
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = params.ok_func
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

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

function MenuManager:show_err_no_chat_parental_control()
	if IS_PS4 then
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

function MenuManager:show_err_new_patch()
	local dialog_data = {
		title = string.upper(managers.localization:text("dialog_information_title")),
		text = managers.localization:text("dialog_err_game_patch_pkg_exists_02"),
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

function MenuManager:show_restart_mission_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_mp_restart_mission_title")
	}
	local dialog_text = managers.localization:text("dialog_mp_restart_mission_host_message")

	if managers.challenge_cards:get_active_card() and not managers.raid_job:current_job().active_card and not managers.event_system:is_event_active() then
		dialog_text = dialog_text .. "\n" .. managers.localization:text("dialog_warning_card_will_consume")
	end

	dialog_data.text = dialog_text
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

function MenuManager:show_storage_removed_dialog(params)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_storage_removed_warning"),
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

function MenuManager:show_play_together_rejected_message()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_play_together_reject_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_invite_rejected_message()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_invite_reject_text")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_loyalty_reward_message(text_id, amount)
	local dialog_data = {
		title = managers.localization:text("dialog_loyalty_reward_title"),
		text = managers.localization:text(text_id, {
			AMOUNT = amount
		}),
		button_list = {
			{
				text = managers.localization:text("dialog_ok")
			}
		}
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_skill_profile_rename_dialog(params)
	local yes_button = {
		text = managers.localization:to_upper_text("dialog_rename"),
		class = RaidGUIControlButtonShortPrimary,
		callback_func = params.callback_yes
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:to_upper_text("dialog_cancel"),
		class = RaidGUIControlButtonShortSecondary,
		callback_func = params.callback_no
	}
	local dialog_data = {
		capitalize = false,
		focus_button = 1,
		textbox = true,
		title = managers.localization:to_upper_text("menu_skill_profile_rename_title"),
		textbox_value = params.textbox_value,
		button_list = {
			yes_button,
			no_button
		}
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:show_skill_profile_purchase_dialog(params)
	local yes_button = {
		text = managers.localization:to_upper_text("dialog_yes"),
		class = RaidGUIControlButtonShortPrimaryGold,
		callback_func = params.callback_yes
	}
	local no_button = {
		cancel_button = true,
		text = managers.localization:to_upper_text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary
	}
	local dialog_data = {
		title = managers.localization:text("menu_skill_profile_purchase_title"),
		text = managers.localization:text("menu_skill_profile_purchase_message", {
			AMOUNT = params.amount
		}),
		button_list = {
			yes_button,
			no_button
		}
	}

	managers.system_menu:show(dialog_data)
end
