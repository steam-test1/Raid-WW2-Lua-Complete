RaidGUIItemAvailabilityFlag = RaidGUIItemAvailabilityFlag or {}
RaidGUIItemAvailabilityFlag.ALWAYS_HIDE = "always_hide"
RaidGUIItemAvailabilityFlag.CAN_SAVE_GAME = "can_save_game"
RaidGUIItemAvailabilityFlag.CUSTOMIZE_CONTROLLER_ENABLED = "customize_controller_enabled"
RaidGUIItemAvailabilityFlag.HAS_INSTALLED_MODS = "has_installed_mods"
RaidGUIItemAvailabilityFlag.IS_FULLSCREEN = "is_fullscreen"
RaidGUIItemAvailabilityFlag.IS_IN_CAMP = "is_in_camp"
RaidGUIItemAvailabilityFlag.IS_MULTIPLAYER = "is_multiplayer"
RaidGUIItemAvailabilityFlag.IS_SINGLEPLAYER = "is_singleplayer"
RaidGUIItemAvailabilityFlag.IS_NOT_EDITOR = "is_not_editor"
RaidGUIItemAvailabilityFlag.IS_NOT_CONSUMABLE = "is_not_consumable"
RaidGUIItemAvailabilityFlag.IS_NOT_IN_CAMP = "is_not_in_camp"
RaidGUIItemAvailabilityFlag.IS_NOT_MULTIPLAYER = "is_not_multiplayer"
RaidGUIItemAvailabilityFlag.IS_NOT_PC_CONTROLLER = "is_not_pc_controller"
RaidGUIItemAvailabilityFlag.IS_PC_CONTROLLER = "is_pc_controller"
RaidGUIItemAvailabilityFlag.IS_SERVER = "is_server"
RaidGUIItemAvailabilityFlag.IS_WIN32 = "is_win32"
RaidGUIItemAvailabilityFlag.KICK_PLAYER_VISIBLE = "kick_player_visible"
RaidGUIItemAvailabilityFlag.KICK_VOTE_VISIBLE = "kick_vote_visible"
RaidGUIItemAvailabilityFlag.REPUTATION_CHECK = "reputation_check"
RaidGUIItemAvailabilityFlag.RESTART_LEVEL_VISIBLE = "restart_level_visible"
RaidGUIItemAvailabilityFlag.RESTART_LEVEL_VISIBLE_CLIENT = "restart_level_visible_client"
RaidGUIItemAvailabilityFlag.RESTART_VOTE_VISIBLE = "restart_vote_visible"
RaidGUIItemAvailabilityFlag.SINGLEPLAYER_RESTART = "singleplayer_restart"
RaidGUIItemAvailabilityFlag.VOICE_ENABLED = "voice_enabled"
RaidGUIItemAvailabilityFlag.IS_IN_MAIN_MENU = "is_in_main_menu"
RaidGUIItemAvailabilityFlag.IS_NOT_IN_MAIN_MENU = "is_not_in_main_menu"
RaidGUIItemAvailabilityFlag.SHOULD_SHOW_TUTORIAL = "should_show_tutorial"
RaidGUIItemAvailabilityFlag.SHOULD_NOT_SHOW_TUTORIAL = "should_not_show_tutorial"
RaidGUIItemAvailabilityFlag.SHOULD_SHOW_TUTORIAL_SKIP = "should_show_tutorial_skip"
RaidGUIItemAvailabilityFlag.HAS_SPECIAL_EDITION = "has_special_edition"
RaidMenuCallbackHandler = RaidMenuCallbackHandler or class(CoreMenuCallbackHandler.CallbackHandler)

-- Lines 44-47
function RaidMenuCallbackHandler:menu_options_on_click_controls()
	managers.raid_menu:open_menu("raid_menu_options_controls")
end

-- Lines 49-52
function RaidMenuCallbackHandler:menu_options_on_click_video()
	managers.raid_menu:open_menu("raid_menu_options_video")
end

-- Lines 54-57
function RaidMenuCallbackHandler:menu_options_on_click_interface()
	managers.raid_menu:open_menu("raid_menu_options_interface")
end

-- Lines 59-62
function RaidMenuCallbackHandler:menu_options_on_click_sound()
	managers.raid_menu:open_menu("raid_menu_options_sound")
end

-- Lines 64-67
function RaidMenuCallbackHandler:menu_options_on_click_network()
	managers.raid_menu:open_menu("raid_menu_options_network")
end

-- Lines 69-108
function RaidMenuCallbackHandler:menu_options_on_click_default()
	local params = {
		title = managers.localization:text("dialog_reset_all_options_title"),
		message = managers.localization:text("dialog_reset_all_options_message"),
		callback = function ()
			managers.user:reset_controls_setting_map()
			managers.controller:load_settings("settings/controller_settings")
			managers.controller:clear_user_mod("normal", MenuCustomizeControllerCreator.CONTROLS_INFO)
			managers.user:reset_video_setting_map()
			managers.menu:active_menu().callback_handler:set_fullscreen_default_raid_no_dialog()

			local resolution = Vector3(tweak_data.gui.base_resolution.x, tweak_data.gui.base_resolution.y, tweak_data.gui.base_resolution.z)

			managers.menu:active_menu().callback_handler:set_resolution_default_raid_no_dialog(resolution)
			managers.menu:active_menu().callback_handler:_refresh_brightness()
			managers.user:reset_advanced_video_setting_map()

			RenderSettings.texture_quality_default = "high"
			RenderSettings.shadow_quality_default = "high"
			RenderSettings.max_anisotropy = 16
			RenderSettings.v_sync = false

			managers.menu:active_menu().callback_handler:apply_and_save_render_settings()
			managers.menu:active_menu().callback_handler:_refresh_brightness()
			managers.user:reset_sound_setting_map()
			managers.menu:active_menu().callback_handler:_reset_mainmusic()
			managers.user:reset_network_setting_map()

			Global.savefile_manager.setting_changed = true

			managers.savefile:save_setting(true)
		end
	}

	managers.menu:show_option_dialog(params)
end

-- Lines 110-128
function RaidMenuCallbackHandler:menu_options_on_click_reset_progress()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_to_clear_progress")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_clear_progress_yes")
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

-- Lines 130-144
function RaidMenuCallbackHandler:_dialog_clear_progress_yes()
	if game_state_machine:current_state_name() == "menu_main" then
		Application:debug("[RaidMenuCallbackHandler] PROGRESS CLEAR PRESSED YES")
		managers.savefile:clear_progress_data()
	else
		Global.reset_progress = true

		MenuCallbackHandler:_dialog_end_game_yes()
	end
end

-- Lines 146-148
function RaidMenuCallbackHandler:init()
	RaidMenuCallbackHandler.super.init(self)
end

-- Lines 150-152
function RaidMenuCallbackHandler:debug_menu_enabled()
	return managers.menu:debug_menu_enabled()
end

-- Lines 154-156
function RaidMenuCallbackHandler:is_in_camp()
	return managers.raid_job:is_camp_loaded()
end

-- Lines 158-160
function RaidMenuCallbackHandler:is_not_in_camp()
	return not managers.raid_job:is_camp_loaded()
end

-- Lines 162-164
function RaidMenuCallbackHandler:is_not_editor()
	return not Application:editor()
end

-- Lines 166-178
function RaidMenuCallbackHandler:on_multiplayer_clicked()
	managers.raid_menu:open_menu("mission_join_menu")
end

-- Lines 195-197
function RaidMenuCallbackHandler:on_select_character_profile_clicked()
	managers.raid_menu:open_menu("profile_selection_menu")
end

-- Lines 199-201
function RaidMenuCallbackHandler:on_weapon_select_clicked()
	managers.raid_menu:open_menu("raid_menu_weapon_select")
end

-- Lines 203-205
function RaidMenuCallbackHandler:on_select_character_skills_clicked()
	managers.raid_menu:open_menu("raid_menu_xp")
end

-- Lines 207-209
function RaidMenuCallbackHandler:on_select_challenge_cards_view_clicked()
	managers.raid_menu:open_menu("challenge_cards_view_menu")
end

-- Lines 211-217
function RaidMenuCallbackHandler:on_mission_selection_clicked()
	if managers.progression:have_pending_missions_to_unlock() then
		managers.raid_menu:open_menu("mission_unlock_menu")
	else
		managers.raid_menu:open_menu("mission_selection_menu")
	end
end

-- Lines 219-221
function RaidMenuCallbackHandler:on_options_clicked()
	managers.raid_menu:open_menu("raid_options_menu")
end

-- Lines 223-225
function RaidMenuCallbackHandler:on_gold_asset_store_clicked()
	managers.raid_menu:open_menu("gold_asset_store_menu")
end

-- Lines 227-229
function RaidMenuCallbackHandler:on_intel_clicked()
	managers.raid_menu:open_menu("intel_menu")
end

-- Lines 231-233
function RaidMenuCallbackHandler:on_comic_book_clicked()
	managers.raid_menu:open_menu("comic_book_menu")
end

-- Lines 235-237
function RaidMenuCallbackHandler:show_credits()
	managers.raid_menu:open_menu("raid_credits_menu")
end

-- Lines 240-258
function RaidMenuCallbackHandler:end_game()
	print(" RaidMenuCallbackHandler:end_game() ")

	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_to_leave_game")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_end_game_yes")
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_end_game_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 260-263
function RaidMenuCallbackHandler:_dialog_end_game_yes()
	setup.exit_to_main_menu = true

	setup:quit_to_main_menu()
end

-- Lines 265-266
function RaidMenuCallbackHandler:_dialog_end_game_no()
end

-- Lines 271-296
function RaidMenuCallbackHandler:leave_ready_up()
	if game_state_machine:current_state_name() == "ingame_lobby_menu" then
		self:end_game()

		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_leave_ready_up"),
		id = "leave_ready_up"
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_leave_ready_up_yes")
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_leave_ready_up_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)

	return true
end

-- Lines 298-303
function RaidMenuCallbackHandler:_dialog_leave_ready_up_yes()
	managers.raid_menu:close_all_menus()
	managers.challenge_cards:remove_suggested_challenge_card()
	managers.network:session():send_to_peers_synched("leave_ready_up_menu")
end

-- Lines 305-306
function RaidMenuCallbackHandler:_dialog_leave_ready_up_no()
end

-- Lines 310-312
function RaidMenuCallbackHandler:debug_camp()
	managers.menu:open_node("debug_camp")
end

-- Lines 314-316
function RaidMenuCallbackHandler:debug_ingame()
	managers.menu:open_node("debug_ingame")
end

-- Lines 318-320
function RaidMenuCallbackHandler:debug_main()
	managers.menu:open_node("debug")
end

-- Lines 322-335
function RaidMenuCallbackHandler:singleplayer_restart()
	local visible = true
	local state = game_state_machine:current_state_name()
	visible = visible and state ~= "menu_main"
	visible = visible and not managers.raid_job:is_camp_loaded()
	visible = visible and not managers.raid_job:is_in_tutorial()
	visible = visible and self:is_singleplayer()
	visible = visible and self:has_full_game()

	return visible
end

-- Lines 337-339
function RaidMenuCallbackHandler:is_singleplayer()
	return Global.game_settings.single_player
end

-- Lines 341-343
function RaidMenuCallbackHandler:has_full_game()
	return managers.dlc:has_full_game()
end

-- Lines 345-347
function RaidMenuCallbackHandler:always_hide()
	return false
end

-- Lines 349-351
function RaidMenuCallbackHandler:is_server()
	return Network:is_server()
end

-- Lines 353-355
function RaidMenuCallbackHandler:is_multiplayer()
	return not Global.game_settings.single_player
end

-- Lines 357-359
function RaidMenuCallbackHandler:kick_player_visible()
	return self:is_server() and self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_host_kick()
end

-- Lines 361-363
function RaidMenuCallbackHandler:kick_vote_visible()
	return self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_vote_kick()
end

-- Lines 365-367
function RaidMenuCallbackHandler:voice_enabled()
	return self:is_ps3() or self:is_win32() and managers.network and managers.network.voice_chat and managers.network.voice_chat:enabled()
end

-- Lines 369-371
function RaidMenuCallbackHandler:is_in_main_menu()
	return game_state_machine:current_state_name() == "menu_main"
end

-- Lines 373-375
function RaidMenuCallbackHandler:is_not_in_main_menu()
	return game_state_machine:current_state_name() ~= "menu_main"
end

-- Lines 377-379
function RaidMenuCallbackHandler:has_special_edition()
	return managers.dlc:is_dlc_unlocked(DLCTweakData.DLC_NAME_SPECIAL_EDITION)
end

-- Lines 383-386
function RaidMenuCallbackHandler:should_show_tutorial()
	return game_state_machine:current_state_name() == "menu_main" and not managers.raid_job:played_tutorial()
end

-- Lines 388-390
function RaidMenuCallbackHandler:should_not_show_tutorial()
	return not self:should_show_tutorial()
end

-- Lines 393-395
function RaidMenuCallbackHandler:should_show_tutorial_skip()
	return managers.raid_job:is_in_tutorial()
end

-- Lines 398-400
function RaidMenuCallbackHandler:is_ps3()
	return false
end

-- Lines 402-404
function RaidMenuCallbackHandler:is_win32()
	return IS_PC
end

-- Lines 406-408
function RaidMenuCallbackHandler:restart_vote_visible()
	return self:_restart_level_visible() and managers.vote:option_vote_restart()
end

-- Lines 410-413
function RaidMenuCallbackHandler:restart_level_visible()
	local res = self:is_server() and self:_restart_level_visible() and managers.vote:option_host_restart()

	return res
end

-- Lines 415-422
function RaidMenuCallbackHandler:restart_level_visible_client()
	local res = not self:is_server() and self:is_multiplayer() and not managers.raid_job:is_in_tutorial()

	if not res then
		return false
	end

	local state = game_state_machine:current_state_name()

	return state ~= "ingame_waiting_for_players" and state ~= "ingame_lobby_menu" and state ~= "menu_main" and state ~= "empty"
end

-- Lines 424-429
function RaidMenuCallbackHandler:is_not_consumable()
	if managers.raid_job:current_job() and managers.raid_job:current_job().consumable then
		return false
	end

	return true
end

-- Lines 431-438
function RaidMenuCallbackHandler:_restart_level_visible()
	if not self:is_multiplayer() or managers.raid_job:is_camp_loaded() or managers.raid_job:is_in_tutorial() then
		return false
	end

	local state = game_state_machine:current_state_name()

	return state ~= "ingame_waiting_for_players" and state ~= "ingame_lobby_menu" and state ~= "menu_main" and state ~= "empty"
end

-- Lines 440-442
function RaidMenuCallbackHandler:resume_game_raid()
	managers.raid_menu:on_escape()
end

-- Lines 444-446
function RaidMenuCallbackHandler:edit_game_settings()
	managers.menu:open_node("edit_game_settings")
end

-- Lines 449-476
function RaidMenuCallbackHandler:restart_mission(item)
	if not managers.vote:available() or managers.vote:is_restarting() then
		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_mp_restart_mission_title"),
		text = managers.localization:text(managers.vote:option_vote_restart() and "dialog_mp_restart_level_message" or "dialog_mp_restart_mission_host_message")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = function ()
			if managers.vote:option_vote_restart() then
				managers.vote:restart_mission()
			else
				managers.vote:restart_mission_auto()
			end

			managers.raid_menu:on_escape()
		end
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

-- Lines 478-497
function RaidMenuCallbackHandler:restart_to_camp_client(item)
	local dialog_data = {
		title = managers.localization:text("dialog_mp_restart_level_title"),
		text = managers.localization:text("dialog_mp_restart_level_client_message")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = function ()
			managers.raid_menu:on_escape()
			setup:return_to_camp_client()
		end
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

-- Lines 499-526
function RaidMenuCallbackHandler:restart_to_camp(item)
	if not managers.vote:available() or managers.vote:is_restarting() then
		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_mp_restart_level_title"),
		text = managers.localization:text(managers.vote:option_vote_restart() and "dialog_mp_restart_level_message" or "dialog_mp_restart_level_host_message")
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = function ()
			if managers.vote:option_vote_restart() then
				managers.vote:restart()
			else
				managers.vote:restart_auto()
			end

			managers.raid_menu:on_escape()
		end
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

-- Lines 528-530
function RaidMenuCallbackHandler:singleplayer_restart_mission(item)
	managers.menu:show_restart_mission_dialog({
		yes_func = RaidMenuCallbackHandler.singleplayer_restart_restart_mission_yes
	})
end

-- Lines 532-535
function RaidMenuCallbackHandler:singleplayer_restart_restart_mission_yes(item)
	Application:set_pause(false)
	managers.game_play_central:restart_the_mission()
end

-- Lines 537-539
function RaidMenuCallbackHandler:singleplayer_restart_game_to_camp(item)
	managers.menu:show_return_to_camp_dialog({
		yes_func = RaidMenuCallbackHandler.singleplayer_restart_game_to_camp_yes
	})
end

-- Lines 541-544
function RaidMenuCallbackHandler:singleplayer_restart_game_to_camp_yes(item)
	Application:set_pause(false)
	managers.game_play_central:restart_the_game()
end

-- Lines 546-553
function RaidMenuCallbackHandler:quit_game()
	self:_quit_game(managers.localization:text("dialog_are_you_sure_you_want_to_quit"))
end

-- Lines 555-557
function RaidMenuCallbackHandler:quit_game_pause_menu()
	self:_quit_game(managers.localization:text("dialog_are_you_sure_you_want_to_quit_pause_menu"))
end

-- Lines 559-576
function RaidMenuCallbackHandler:_quit_game(dialog_text)
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = dialog_text
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_quit_yes")
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_quit_no"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 578-597
function RaidMenuCallbackHandler:_dialog_quit_yes()
	self:_dialog_save_progress_backup_no()
end

-- Lines 599-601
function RaidMenuCallbackHandler:_dialog_save_progress_backup_no()
	setup:quit()
end

-- Lines 603-604
function RaidMenuCallbackHandler:_dialog_quit_no()
end

-- Lines 606-636
function RaidMenuCallbackHandler:raid_play_online()
	Global.game_settings.single_player = false
	Global.exe_argument_level = OperationsTweakData.ENTRY_POINT_LEVEL
	Global.exe_argument_difficulty = Global.exe_argument_difficulty or Global.DEFAULT_DIFFICULTY

	MenuCallbackHandler:start_job({
		job_id = Global.exe_argument_level,
		difficulty = Global.exe_argument_difficulty
	})
end

-- Lines 638-654
function RaidMenuCallbackHandler:raid_play_offline()
	Global.exe_argument_level = OperationsTweakData.ENTRY_POINT_LEVEL
	Global.exe_argument_difficulty = Global.exe_argument_difficulty or Global.DEFAULT_DIFFICULTY
	local mission = tweak_data.operations:mission_data(managers.raid_job:played_tutorial() and RaidJobManager.CAMP_ID or RaidJobManager.TUTORIAL_ID)
	local data = {
		background = mission.loading.image,
		loading_text = mission.loading.text,
		mission = mission
	}

	managers.menu:show_loading_screen(data, callback(self, self, "_do_play_offline"))
end

-- Lines 656-659
function RaidMenuCallbackHandler:_do_play_offline()
	MenuCallbackHandler:play_single_player()
	MenuCallbackHandler:start_single_player_job({
		job_id = Global.exe_argument_level,
		difficulty = Global.exe_argument_difficulty
	})
end

-- Lines 661-665
function RaidMenuCallbackHandler:raid_play_tutorial()
	Application:debug("[RaidMenuCallbackHandler][raid_play_tutorial] Starting tutorial")
	managers.raid_job:set_temp_play_flag()
	self:raid_play_offline()
end

-- Lines 667-671
function RaidMenuCallbackHandler:raid_skip_tutorial()
	Application:debug("[RaidMenuCallbackHandler][raid_skip_tutorial] Skipping and ending tutorial")
	managers.raid_menu:on_escape()
	managers.raid_job:external_end_tutorial()
end

-- Lines 675-678
function MenuCallbackHandler:on_play_clicked()
	managers.raid_menu:open_menu("mission_selection_menu")
end

-- Lines 680-692
function MenuCallbackHandler:on_multiplayer_clicked()
	managers.raid_menu:open_menu("mission_join_menu")
end

-- Lines 709-716
function MenuCallbackHandler:on_mission_selection_clicked()
	if managers.progression:have_pending_missions_to_unlock() then
		managers.raid_menu:open_menu("mission_unlock_menu")
	else
		managers.raid_menu:open_menu("mission_selection_menu")
	end
end

-- Lines 718-721
function MenuCallbackHandler:on_select_character_profile_clicked()
	managers.raid_menu:open_menu("profile_selection_menu")
end

-- Lines 723-726
function MenuCallbackHandler:on_select_character_customization_clicked()
	managers.raid_menu:open_menu("character_customization_menu")
end

-- Lines 728-731
function MenuCallbackHandler:on_select_challenge_cards_clicked()
	managers.raid_menu:open_menu("challenge_cards_menu")
end

-- Lines 733-736
function MenuCallbackHandler:on_select_challenge_cards_view_clicked()
	managers.raid_menu:open_menu("challenge_cards_view_menu")
end

-- Lines 738-741
function MenuCallbackHandler:on_select_character_skills_clicked()
	managers.raid_menu:open_menu("raid_menu_xp")
end

-- Lines 743-746
function MenuCallbackHandler:choice_choose_raid_permission(item)
	local value = item:value()
	Global.game_settings.permission = value
end

-- Lines 748-755
function MenuCallbackHandler:choice_choose_raid_mission_zone(item)
	local value = item:value()
	Global.game_settings.raid_zone = value

	if managers.menu_component._raid_menu_mission_selection_gui then
		managers.menu_component._raid_menu_mission_selection_gui:_show_jobs()
	end
end

-- Lines 757-761
function MenuCallbackHandler:is_in_camp()
	return managers.raid_job:is_camp_loaded()
end

-- Lines 763-767
function MenuCallbackHandler:is_not_in_camp()
	return not managers.raid_job:is_camp_loaded()
end

-- Lines 771-782
function RaidMenuCallbackHandler.invite_friend()
	if Network:multiplayer() then
		if IS_PS4 then
			MenuCallbackHandler:invite_friends_ps4()
		elseif IS_XB1 then
			MenuCallbackHandler:invite_friends_XB1()
		end
	end
end

-- Lines 803-805
function MenuCallbackHandler:set_camera_sensitivity_x_raid(value)
	managers.user:set_setting("camera_sensitivity_x", value)
end

-- Lines 807-809
function MenuCallbackHandler:set_camera_sensitivity_y_raid(value)
	managers.user:set_setting("camera_sensitivity_y", value)
end

-- Lines 811-813
function MenuCallbackHandler:set_camera_zoom_sensitivity_x_raid(value)
	managers.user:set_setting("camera_zoom_sensitivity_x", value)
end

-- Lines 815-817
function MenuCallbackHandler:set_camera_zoom_sensitivity_y_raid(value)
	managers.user:set_setting("camera_zoom_sensitivity_y", value)
end

-- Lines 819-821
function MenuCallbackHandler:toggle_zoom_sensitivity_raid(value)
	managers.user:set_setting("enable_camera_zoom_sensitivity", value)
end

-- Lines 823-825
function MenuCallbackHandler:invert_camera_vertically_raid(value)
	managers.user:set_setting("invert_camera_y", value)
end

-- Lines 827-829
function MenuCallbackHandler:hold_to_steelsight_raid(value)
	managers.user:set_setting("hold_to_steelsight", value)
end

-- Lines 831-833
function MenuCallbackHandler:hold_to_run_raid(value)
	managers.user:set_setting("hold_to_run", value)
end

-- Lines 835-837
function MenuCallbackHandler:hold_to_duck_raid(value)
	managers.user:set_setting("hold_to_duck", value)
end

-- Lines 841-843
function MenuCallbackHandler:toggle_rumble(value)
	managers.user:set_setting("rumble", value)
end

-- Lines 845-847
function MenuCallbackHandler:toggle_aim_assist(value)
	managers.user:set_setting("aim_assist", value)
end

-- Lines 849-851
function MenuCallbackHandler:toggle_sticky_aim(value)
	managers.user:set_setting("sticky_aim", value)
end

-- Lines 853-855
function MenuCallbackHandler:toggle_southpaw(value)
	managers.user:set_setting("southpaw", value)
end

-- Lines 859-861
function MenuCallbackHandler:toggle_net_throttling_raid(value)
	managers.user:set_setting("net_packet_throttling", value)
end

-- Lines 863-865
function MenuCallbackHandler:toggle_net_forwarding_raid(value)
	managers.user:set_setting("net_forwarding", value)
end

-- Lines 867-869
function MenuCallbackHandler:toggle_net_use_compression_raid(value)
	managers.user:set_setting("net_use_compression", value)
end

-- Lines 873-888
function MenuCallbackHandler:set_master_volume_raid(volume)
	local old_volume = managers.user:get_setting("master_volume")

	managers.user:set_setting("master_volume", volume)
	managers.video:volume_changed(volume / 100)

	if self._sound_source then
		if old_volume < volume then
			self._sound_source:post_event("slider_increase")
		elseif volume < old_volume then
			self._sound_source:post_event("slider_decrease")
		end
	else
		Application:error("[MenuCallbackHandler] Missing sound source for master volume!")
	end
end

-- Lines 890-904
function MenuCallbackHandler:set_music_volume_raid(volume)
	local old_volume = managers.user:get_setting("music_volume")

	managers.user:set_setting("music_volume", volume)

	if self._sound_source then
		if old_volume < volume then
			self._sound_source:post_event("slider_increase")
		elseif volume < old_volume then
			self._sound_source:post_event("slider_decrease")
		end
	else
		Application:error("[MenuCallbackHandler] Missing sound source for master volume!")
	end
end

-- Lines 906-920
function MenuCallbackHandler:set_sfx_volume_raid(volume)
	local old_volume = managers.user:get_setting("sfx_volume")

	managers.user:set_setting("sfx_volume", volume)

	if self._sound_source then
		if old_volume < volume then
			self._sound_source:post_event("slider_increase")
		elseif volume < old_volume then
			self._sound_source:post_event("slider_decrease")
		end
	else
		Application:error("[MenuCallbackHandler] Missing sound source for master volume!")
	end
end

-- Lines 922-936
function MenuCallbackHandler:set_voice_volume_raid(volume)
	local old_volume = managers.user:get_setting("voice_volume")

	managers.user:set_setting("voice_volume", volume / 100)

	if self._sound_source then
		if old_volume < volume then
			self._sound_source:post_event("slider_increase")
		elseif volume < old_volume then
			self._sound_source:post_event("slider_decrease")
		end
	else
		Application:error("[MenuCallbackHandler] Missing sound source for master volume!")
	end
end

-- Lines 938-952
function MenuCallbackHandler:set_voice_over_volume_raid(volume)
	local old_volume = managers.user:get_setting("voice_over_volume")

	managers.user:set_setting("voice_over_volume", volume)

	if self._sound_source then
		if old_volume < volume then
			self._sound_source:post_event("slider_increase")
		elseif volume < old_volume then
			self._sound_source:post_event("slider_decrease")
		end
	else
		Application:error("[MenuCallbackHandler] Missing sound source for master volume!")
	end
end

-- Lines 954-966
function MenuCallbackHandler:toggle_voicechat_raid(value)
	managers.user:set_setting("voice_chat", value)

	if managers.network.voice_chat then
		if value then
			managers.network.voice_chat:soft_enable()
		else
			managers.network.voice_chat:soft_disable()
		end
	end
end

-- Lines 968-970
function MenuCallbackHandler:toggle_push_to_talk_raid(value)
	managers.user:set_setting("push_to_talk", value)
end

-- Lines 972-974
function MenuCallbackHandler:toggle_tinnitus_raid(value)
	managers.user:set_setting("tinnitus_sound_enabled", value)
end

-- Lines 978-995
function MenuCallbackHandler:change_resolution_raid(resolution, no_dialog)
	local old_resolution = RenderSettings.resolution

	if resolution == old_resolution then
		return
	end

	managers.viewport:set_resolution(resolution)
	managers.viewport:set_aspect_ratio(resolution.x / resolution.y)
	managers.worldcamera:scale_worldcamera_fov(resolution.x / resolution.y)

	RenderSettings.resolution = resolution

	Application:apply_render_settings()
	self:_refresh_brightness()
end

-- Lines 997-1006
function MenuCallbackHandler:set_resolution_default_raid_no_dialog(resolution)
	local old_resolution = RenderSettings.resolution

	if resolution == old_resolution then
		return
	end

	managers.viewport:set_resolution(resolution)
	managers.viewport:set_aspect_ratio(resolution.x / resolution.y)
	managers.worldcamera:scale_worldcamera_fov(resolution.x / resolution.y)
end

-- Lines 1008-1033
function MenuCallbackHandler:toggle_fullscreen_raid(fullscreen, borderless)
	if fullscreen and managers.viewport:is_fullscreen() then
		return
	end

	if fullscreen then
		managers.mouse_pointer:acquire_input()
	else
		managers.mouse_pointer:unacquire_input()
	end

	managers.viewport:set_fullscreen(fullscreen)
	managers.viewport:set_borderless(borderless)

	if borderless then
		local monitor_res = Application:monitor_resolution()

		self:change_resolution_raid(Vector3(monitor_res.x, monitor_res.y, RenderSettings.resolution.z), true)
	end

	self:refresh_node()
	self:_refresh_brightness()
end

-- Lines 1035-1054
function MenuCallbackHandler:set_fullscreen_default_raid_no_dialog()
	local fullscreen = true

	if managers.viewport:is_fullscreen() == fullscreen then
		return
	end

	if fullscreen then
		managers.mouse_pointer:acquire_input()
	else
		managers.mouse_pointer:unacquire_input()
	end

	managers.viewport:set_fullscreen(fullscreen)
	self:refresh_node()
	self:_refresh_brightness()
end

-- Lines 1056-1058
function MenuCallbackHandler:toggle_subtitle_raid(value)
	managers.user:set_setting("subtitle", value)
end

-- Lines 1060-1062
function MenuCallbackHandler:set_hit_indicator_raid(value)
	managers.user:set_setting("hit_indicator", value)
end

-- Lines 1064-1070
function MenuCallbackHandler:set_hud_crosshairs_raid(value)
	managers.user:set_setting("hud_crosshairs", value)

	if managers.hud then
		managers.hud:set_crosshair_visible(value)
	end
end

-- Lines 1072-1075
function MenuCallbackHandler:toggle_hud_special_weapon_panels(value)
	managers.user:set_setting("hud_special_weapon_panels", value)
end

-- Lines 1077-1082
function MenuCallbackHandler:set_motion_dot_raid(value)
	managers.user:set_setting("motion_dot", value)

	if managers.hud then
		managers.hud:set_motiondot_type(value)
	end
end

-- Lines 1084-1089
function MenuCallbackHandler:set_motion_dot_size_raid(value)
	managers.user:set_setting("motion_dot_size", value)

	if managers.hud then
		managers.hud:set_motiondot_sizes(value)
	end
end

-- Lines 1091-1093
function MenuCallbackHandler:toggle_objective_reminder_raid(value)
	managers.user:set_setting("objective_reminder", value)
end

-- Lines 1095-1097
function MenuCallbackHandler:toggle_skip_cinematics_raid(value)
	managers.user:set_setting("skip_cinematics", value)
end

-- Lines 1099-1101
function MenuCallbackHandler:toggle_headbob_raid(value)
	managers.user:set_setting("use_headbob", value)
end

-- Lines 1103-1105
function MenuCallbackHandler:set_effect_quality_raid(value)
	managers.user:set_setting("effect_quality", value)
end

-- Lines 1107-1110
function MenuCallbackHandler:set_brightness_raid(value)
	managers.user:set_setting("brightness", value)
end

-- Lines 1114-1116
function MenuCallbackHandler:toggle_dof_setting_raid(value)
	managers.user:set_setting("dof_setting", value and "standard" or "none")
end

-- Lines 1118-1120
function MenuCallbackHandler:toggle_ssao_setting_raid(value)
	managers.user:set_setting("ssao_setting", value and "standard" or "none")
end

-- Lines 1122-1124
function MenuCallbackHandler:set_use_parallax_raid(value)
	managers.user:set_setting("use_parallax", value)
end

-- Lines 1126-1128
function MenuCallbackHandler:toggle_motion_blur_setting_raid(value)
	managers.user:set_setting("motion_blur_setting", value and "standard" or "none")
end

-- Lines 1130-1132
function MenuCallbackHandler:toggle_volumetric_light_scattering_setting_raid(value)
	managers.user:set_setting("vls_setting", value and "standard" or "none")
end

-- Lines 1134-1139
function MenuCallbackHandler:toggle_vsync_raid(vsync_value, buffer_count)
	managers.viewport:set_vsync(vsync_value)
	managers.viewport:set_buffer_count(buffer_count)
	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 1141-1147
function MenuCallbackHandler:set_fov_multiplier_raid(value)
	managers.user:set_setting("fov_multiplier", value)

	if alive(managers.player:player_unit()) then
		managers.player:player_unit():movement():current_state():update_fov_external()
	end
end

-- Lines 1150-1160
function MenuCallbackHandler:set_detail_distance_raid(detail_distance)
	managers.user:set_setting("detail_distance", detail_distance)

	local min_maps = 0.0003
	local max_maps = 0.02
	local maps = math.lerp(max_maps, min_maps, detail_distance)

	Application:debug("RaidMenuOptionsVideoAdvanced:on_value_change_detail_distance", detail_distance, maps)
	World:set_min_allowed_projected_size(maps)
end

-- Lines 1162-1164
function MenuCallbackHandler:choice_choose_anti_alias_raid(value)
	managers.user:set_setting("AA_setting", value)
end

-- Lines 1166-1172
function MenuCallbackHandler:choice_choose_texture_quality_raid(value)
	RenderSettings.texture_quality_default = value

	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 1174-1180
function MenuCallbackHandler:choice_choose_shadow_quality_raid(value)
	RenderSettings.shadow_quality_default = value

	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 1182-1188
function MenuCallbackHandler:choice_choose_anisotropic_raid(value)
	RenderSettings.max_anisotropy = value

	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 1190-1192
function MenuCallbackHandler:choice_choose_anim_lod_raid(value)
	managers.user:set_setting("video_animation_lod", value)
end

-- Lines 1194-1197
function MenuCallbackHandler:choice_fps_cap_raid(value)
	setup:set_fps_cap(value)
	managers.user:set_setting("fps_cap", value)
end

-- Lines 1199-1201
function MenuCallbackHandler:choice_max_streaming_chunk_raid(value)
	managers.user:set_setting("max_streaming_chunk", value)
end

-- Lines 1203-1205
function MenuCallbackHandler:choice_choose_cb_mode_raid(value)
	managers.user:set_setting("colorblind_setting", value)
end

-- Lines 1209-1224
function MenuCallbackHandler:set_default_options_raid(node_component)
	local params = {
		text = managers.localization:text("dialog_default_options_message"),
		callback = function ()
			managers.user:reset_setting_map()
			self:_reset_mainmusic()
			node_component:_load_controls_values()
			node_component:_load_video_values()
			node_component:_load_advanced_video_values()
			node_component:_load_sound_values()
			node_component:_load_network_values()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1226-1233
function MenuCallbackHandler:set_default_control_options_raid(node_component)
	local params = {
		text = managers.localization:text("dialog_default_controls_options_message"),
		callback = function ()
			managers.user:reset_controls_setting_map()
			node_component:_load_controls_values()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1235-1246
function MenuCallbackHandler:set_default_keybinds_raid(node_component)
	local params = {
		text = managers.localization:text("dialog_use_default_keys_message"),
		callback = function ()
			managers.controller:load_settings("settings/controller_settings")
			managers.controller:clear_user_mod("normal", MenuCustomizeControllerCreator.CONTROLS_INFO)
			node_component:refresh_keybinds()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1248-1260
function MenuCallbackHandler:set_default_video_options_raid(node_component, callback_function)
	local params = {
		text = managers.localization:text("dialog_default_video_options_message"),
		callback = function ()
			managers.user:reset_video_setting_map()
			node_component:_load_video_values()
			node_component:_load_advanced_video_values()
			callback_function()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1262-1273
function MenuCallbackHandler:set_default_sound_options_raid(node_component)
	local params = {
		text = managers.localization:text("dialog_default_sound_options_message"),
		callback = function ()
			managers.user:reset_sound_setting_map()
			self:_reset_mainmusic()
			node_component:_load_sound_values()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1275-1282
function MenuCallbackHandler:set_default_network_options_raid(node_component)
	local params = {
		text = managers.localization:text("dialog_default_network_options_message"),
		callback = function ()
			managers.user:reset_network_setting_map()
			node_component:_load_network_values()
		end
	}

	managers.menu:show_default_option_dialog(params)
end
