RaidGUIItemAvailabilityFlag = RaidGUIItemAvailabilityFlag or {}
RaidGUIItemAvailabilityFlag.ALWAYS_HIDE = "always_hide"
RaidGUIItemAvailabilityFlag.CAN_SAVE_GAME = "can_save_game"
RaidGUIItemAvailabilityFlag.CUSTOMIZE_CONTROLLER_ENABLED = "customize_controller_enabled"
RaidGUIItemAvailabilityFlag.HAS_INSTALLED_MODS = "has_installed_mods"
RaidGUIItemAvailabilityFlag.IS_CASH_SAFE_BACK_VISIBLE = "is_cash_safe_back_visible"
RaidGUIItemAvailabilityFlag.IS_FULLSCREEN = "is_fullscreen"
RaidGUIItemAvailabilityFlag.IS_IN_CAMP = "is_in_camp"
RaidGUIItemAvailabilityFlag.IS_MULTIPLAYER = "is_multiplayer"
RaidGUIItemAvailabilityFlag.IS_SINGLEPLAYER = "is_singleplayer"
RaidGUIItemAvailabilityFlag.IS_NOT_EDITOR = "is_not_editor"
RaidGUIItemAvailabilityFlag.IS_NOT_CONSUMABLE = "is_not_consumable"
RaidGUIItemAvailabilityFlag.IS_NOT_IN_CAMP = "is_not_in_camp"
RaidGUIItemAvailabilityFlag.IS_NOT_MULTIPLAYER = "is_not_multiplayer"
RaidGUIItemAvailabilityFlag.IS_NOT_PC_CONTROLLER = "is_not_pc_controller"
RaidGUIItemAvailabilityFlag.IS_NOT_XBOX = "is_not_xbox"
RaidGUIItemAvailabilityFlag.IS_PC_CONTROLLER = "is_pc_controller"
RaidGUIItemAvailabilityFlag.IS_SERVER = "is_server"
RaidGUIItemAvailabilityFlag.IS_WIN32 = "is_win32"
RaidGUIItemAvailabilityFlag.IS_X360 = "is_x360"
RaidGUIItemAvailabilityFlag.KICK_PLAYER_VISIBLE = "kick_player_visible"
RaidGUIItemAvailabilityFlag.KICK_VOTE_VISIBLE = "kick_vote_visible"
RaidGUIItemAvailabilityFlag.NON_OVERKILL_145 = "non_overkill_145"
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

function RaidMenuCallbackHandler:menu_options_on_click_controls()
	managers.raid_menu:open_menu("raid_menu_options_controls")
end

function RaidMenuCallbackHandler:menu_options_on_click_video()
	managers.raid_menu:open_menu("raid_menu_options_video")
end

function RaidMenuCallbackHandler:menu_options_on_click_sound()
	managers.raid_menu:open_menu("raid_menu_options_sound")
end

function RaidMenuCallbackHandler:menu_options_on_click_network()
	managers.raid_menu:open_menu("raid_menu_options_network")
end

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

function RaidMenuCallbackHandler:_dialog_clear_progress_yes()
	if game_state_machine:current_state_name() == "menu_main" then
		Application:debug("[RaidMenuCallbackHandler] PROGRESS CLEAR PRESSED YES")
		managers.savefile:clear_progress_data()
	else
		Global.reset_progress = true

		MenuCallbackHandler:_dialog_end_game_yes()
	end
end

function RaidMenuCallbackHandler:init()
	RaidMenuCallbackHandler.super.init(self)
end

function RaidMenuCallbackHandler:debug_menu_enabled()
	return managers.menu:debug_menu_enabled()
end

function RaidMenuCallbackHandler:is_in_camp()
	return managers.raid_job:is_camp_loaded()
end

function RaidMenuCallbackHandler:is_not_in_camp()
	return not managers.raid_job:is_camp_loaded()
end

function RaidMenuCallbackHandler:is_not_editor()
	return not Application:editor()
end

function RaidMenuCallbackHandler:on_multiplayer_clicked()
	managers.raid_menu:open_menu("mission_join_menu")
end

function RaidMenuCallbackHandler:on_select_character_profile_clicked()
	managers.raid_menu:open_menu("profile_selection_menu")
end

function RaidMenuCallbackHandler:on_weapon_select_clicked()
	managers.raid_menu:open_menu("raid_menu_weapon_select")
end

function RaidMenuCallbackHandler:on_select_character_skills_clicked()
	managers.raid_menu:open_menu("raid_menu_xp")
end

function RaidMenuCallbackHandler:on_select_challenge_cards_view_clicked()
	managers.raid_menu:open_menu("challenge_cards_view_menu")
end

function RaidMenuCallbackHandler:on_mission_selection_clicked()
	if managers.progression:have_pending_missions_to_unlock() then
		managers.raid_menu:open_menu("mission_unlock_menu")
	else
		managers.raid_menu:open_menu("mission_selection_menu")
	end
end

function RaidMenuCallbackHandler:on_options_clicked()
	managers.raid_menu:open_menu("raid_options_menu")
end

function RaidMenuCallbackHandler:on_gold_asset_store_clicked()
	managers.raid_menu:open_menu("gold_asset_store_menu")
end

function RaidMenuCallbackHandler:on_intel_clicked()
	managers.raid_menu:open_menu("intel_menu")
end

function RaidMenuCallbackHandler:on_comic_book_clicked()
	managers.raid_menu:open_menu("comic_book_menu")
end

function RaidMenuCallbackHandler:show_credits()
	managers.raid_menu:open_menu("raid_credits_menu")
end

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

function RaidMenuCallbackHandler:_dialog_end_game_yes()
	setup.exit_to_main_menu = true

	setup:quit_to_main_menu()
end

function RaidMenuCallbackHandler:_dialog_end_game_no()
end

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

function RaidMenuCallbackHandler:_dialog_leave_ready_up_yes()
	managers.raid_menu:close_all_menus()
	managers.network:session():send_to_peers_synched("leave_ready_up_menu")
end

function RaidMenuCallbackHandler:_dialog_leave_ready_up_no()
end

function RaidMenuCallbackHandler:debug_camp()
	managers.menu:open_node("debug_camp")
end

function RaidMenuCallbackHandler:debug_ingame()
	managers.menu:open_node("debug_ingame")
end

function RaidMenuCallbackHandler:debug_main()
	managers.menu:open_node("debug")
end

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

function RaidMenuCallbackHandler:is_singleplayer()
	return Global.game_settings.single_player
end

function RaidMenuCallbackHandler:has_full_game()
	return managers.dlc:has_full_game()
end

function RaidMenuCallbackHandler:always_hide()
	return false
end

function RaidMenuCallbackHandler:is_server()
	return Network:is_server()
end

function RaidMenuCallbackHandler:is_multiplayer()
	return not Global.game_settings.single_player
end

function RaidMenuCallbackHandler:kick_player_visible()
	return self:is_server() and self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_host_kick()
end

function RaidMenuCallbackHandler:kick_vote_visible()
	return self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_vote_kick()
end

function RaidMenuCallbackHandler:voice_enabled()
	return self:is_ps3() or self:is_win32() and managers.network and managers.network.voice_chat and managers.network.voice_chat:enabled()
end

function RaidMenuCallbackHandler:is_in_main_menu()
	return game_state_machine:current_state_name() == "menu_main"
end

function RaidMenuCallbackHandler:is_not_in_main_menu()
	return game_state_machine:current_state_name() ~= "menu_main"
end

function RaidMenuCallbackHandler:has_special_edition()
	return managers.dlc:is_dlc_unlocked(DLCTweakData.DLC_NAME_SPECIAL_EDITION)
end

function RaidMenuCallbackHandler:should_show_tutorial()
	return game_state_machine:current_state_name() == "menu_main" and not managers.raid_job:played_tutorial()
end

function RaidMenuCallbackHandler:should_not_show_tutorial()
	return not self:should_show_tutorial()
end

function RaidMenuCallbackHandler:should_show_tutorial_skip()
	return managers.raid_job:is_in_tutorial()
end

function RaidMenuCallbackHandler:is_ps3()
	return _G.IS_PS3
end

function RaidMenuCallbackHandler:is_win32()
	return _G.IS_PC
end

function RaidMenuCallbackHandler:restart_vote_visible()
	return self:_restart_level_visible() and managers.vote:option_vote_restart()
end

function RaidMenuCallbackHandler:restart_level_visible()
	local res = self:is_server() and self:_restart_level_visible() and managers.vote:option_host_restart()

	return res
end

function RaidMenuCallbackHandler:restart_level_visible_client()
	local res = not self:is_server() and self:is_multiplayer() and not managers.raid_job:is_in_tutorial()

	if not res then
		return false
	end

	local state = game_state_machine:current_state_name()

	return state ~= "ingame_waiting_for_players" and state ~= "ingame_lobby_menu" and state ~= "menu_main" and state ~= "empty"
end

function RaidMenuCallbackHandler:is_not_consumable()
	if managers.raid_job:current_job() and managers.raid_job:current_job().consumable then
		return false
	end

	return true
end

function RaidMenuCallbackHandler:_restart_level_visible()
	if not self:is_multiplayer() or managers.raid_job:is_camp_loaded() or managers.raid_job:is_in_tutorial() then
		return false
	end

	local state = game_state_machine:current_state_name()

	return state ~= "ingame_waiting_for_players" and state ~= "ingame_lobby_menu" and state ~= "menu_main" and state ~= "empty"
end

function RaidMenuCallbackHandler:resume_game_raid()
	managers.raid_menu:on_escape()
end

function RaidMenuCallbackHandler:edit_game_settings()
	managers.menu:open_node("edit_game_settings")
end

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

function RaidMenuCallbackHandler:singleplayer_restart_mission(item)
	managers.menu:show_restart_mission_dialog({
		yes_func = RaidMenuCallbackHandler.singleplayer_restart_restart_mission_yes
	})
end

function RaidMenuCallbackHandler:singleplayer_restart_restart_mission_yes(item)
	Application:set_pause(false)
	managers.game_play_central:restart_the_mission()
end

function RaidMenuCallbackHandler:singleplayer_restart_game_to_camp(item)
	managers.menu:show_return_to_camp_dialog({
		yes_func = RaidMenuCallbackHandler.singleplayer_restart_game_to_camp_yes
	})
end

function RaidMenuCallbackHandler:singleplayer_restart_game_to_camp_yes(item)
	Application:set_pause(false)
	managers.game_play_central:restart_the_game()
end

function RaidMenuCallbackHandler:quit_game()
	self:_quit_game(managers.localization:text("dialog_are_you_sure_you_want_to_quit"))
end

function RaidMenuCallbackHandler:quit_game_pause_menu()
	self:_quit_game(managers.localization:text("dialog_are_you_sure_you_want_to_quit_pause_menu"))
end

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

function RaidMenuCallbackHandler:_dialog_quit_yes()
	self:_dialog_save_progress_backup_no()
end

function RaidMenuCallbackHandler:_dialog_save_progress_backup_no()
	setup:quit()
end

function RaidMenuCallbackHandler:_dialog_quit_no()
end

function RaidMenuCallbackHandler:raid_play_online()
	if _G.IS_PC then
		Global.game_settings.single_player = false
		Global.exe_argument_level = OperationsTweakData.ENTRY_POINT_LEVEL
		Global.exe_argument_difficulty = Global.exe_argument_difficulty or Global.DEFAULT_DIFFICULTY

		MenuCallbackHandler:start_job({
			job_id = Global.exe_argument_level,
			difficulty = Global.exe_argument_difficulty
		})
	elseif _G.IS_PS4 then
		if Global.boot_invite and Global.boot_invite.pending then
			managers.menu:show_fetching_status_dialog()

			return
		end

		managers.menu:open_sign_in_menu(function (success)
			if not success then
				if managers.network.account:signin_state() == "not signed in" and PSN:cable_connected() then
					managers.menu:show_ok_only_dialog("dialog_warning_title", "dialog_err_not_signed_in")
				end

				return
			end

			Global.exe_argument_level = "streaming_level"
			Global.exe_argument_difficulty = Global.exe_argument_difficulty or "difficulty_1"

			MenuCallbackHandler:start_job({
				job_id = Global.exe_argument_level,
				difficulty = Global.exe_argument_difficulty
			})
		end)
	end
end

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

function RaidMenuCallbackHandler:_do_play_offline()
	MenuCallbackHandler:play_single_player()
	MenuCallbackHandler:start_single_player_job({
		job_id = Global.exe_argument_level,
		difficulty = Global.exe_argument_difficulty
	})
end

function RaidMenuCallbackHandler:raid_play_tutorial()
	Application:debug("[RaidMenuCallbackHandler][raid_play_tutorial] Starting tutorial")
	managers.raid_job:set_temp_play_flag()
	self:raid_play_offline()
end

function RaidMenuCallbackHandler:raid_skip_tutorial()
	Application:debug("[RaidMenuCallbackHandler][raid_skip_tutorial] Skipping and ending tutorial")
	managers.raid_job:save_tutorial_played_flag(true)
	managers.global_state:fire_event("system_end_tutorial")
	managers.raid_menu:on_escape()
	managers.queued_tasks:queue(nil, managers.global_state.fire_event, managers.global_state, "system_end_raid", 1, nil)
end

function MenuCallbackHandler:on_play_clicked()
	managers.raid_menu:open_menu("mission_selection_menu")
end

function MenuCallbackHandler:on_multiplayer_clicked()
	managers.raid_menu:open_menu("mission_join_menu")
end

function MenuCallbackHandler:on_mission_selection_clicked()
	if managers.progression:have_pending_missions_to_unlock() then
		managers.raid_menu:open_menu("mission_unlock_menu")
	else
		managers.raid_menu:open_menu("mission_selection_menu")
	end
end

function MenuCallbackHandler:on_select_character_profile_clicked()
	managers.raid_menu:open_menu("profile_selection_menu")
end

function MenuCallbackHandler:on_select_character_customization_clicked()
	managers.raid_menu:open_menu("character_customization_menu")
end

function MenuCallbackHandler:on_select_challenge_cards_clicked()
	managers.raid_menu:open_menu("challenge_cards_menu")
end

function MenuCallbackHandler:on_select_challenge_cards_view_clicked()
	managers.raid_menu:open_menu("challenge_cards_view_menu")
end

function MenuCallbackHandler:on_select_character_skills_clicked()
	managers.raid_menu:open_menu("raid_menu_xp")
end

function MenuCallbackHandler:choice_choose_raid_permission(item)
	local value = item:value()
	Global.game_settings.permission = value
end

function MenuCallbackHandler:choice_choose_raid_mission_zone(item)
	local value = item:value()
	Global.game_settings.raid_zone = value

	if managers.menu_component._raid_menu_mission_selection_gui then
		managers.menu_component._raid_menu_mission_selection_gui:_show_jobs()
	end
end

function MenuCallbackHandler:is_in_camp()
	return managers.raid_job:is_camp_loaded()
end

function MenuCallbackHandler:is_not_in_camp()
	return not managers.raid_job:is_camp_loaded()
end

function RaidMenuCallbackHandler.invite_friend()
	if Network:multiplayer() then
		if _G.IS_PS4 then
			MenuCallbackHandler:invite_friends_ps4()
		elseif _G.IS_XB1 then
			MenuCallbackHandler:invite_friends_XB1()
		end
	end
end

function MenuCallbackHandler:set_camera_sensitivity_x_raid(value)
	managers.user:set_setting("camera_sensitivity_x", value)
end

function MenuCallbackHandler:set_camera_sensitivity_y_raid(value)
	managers.user:set_setting("camera_sensitivity_y", value)
end

function MenuCallbackHandler:set_camera_zoom_sensitivity_x_raid(value)
	managers.user:set_setting("camera_zoom_sensitivity_x", value)
end

function MenuCallbackHandler:set_camera_zoom_sensitivity_y_raid(value)
	managers.user:set_setting("camera_zoom_sensitivity_y", value)
end

function MenuCallbackHandler:toggle_zoom_sensitivity_raid(value)
	managers.user:set_setting("enable_camera_zoom_sensitivity", value)
end

function MenuCallbackHandler:invert_camera_vertically_raid(value)
	managers.user:set_setting("invert_camera_y", value)
end

function MenuCallbackHandler:hold_to_steelsight_raid(value)
	managers.user:set_setting("hold_to_steelsight", value)
end

function MenuCallbackHandler:hold_to_run_raid(value)
	managers.user:set_setting("hold_to_run", value)
end

function MenuCallbackHandler:hold_to_duck_raid(value)
	managers.user:set_setting("hold_to_duck", value)
end

function MenuCallbackHandler:toggle_rumble(value)
	managers.user:set_setting("rumble", value)
end

function MenuCallbackHandler:toggle_aim_assist(value)
	managers.user:set_setting("aim_assist", value)
end

function MenuCallbackHandler:toggle_sticky_aim(value)
	managers.user:set_setting("sticky_aim", value)
end

function MenuCallbackHandler:toggle_southpaw(value)
	managers.user:set_setting("southpaw", value)
end

function MenuCallbackHandler:toggle_net_throttling_raid(value)
	managers.user:set_setting("net_packet_throttling", value)
end

function MenuCallbackHandler:toggle_net_forwarding_raid(value)
	managers.user:set_setting("net_forwarding", value)
end

function MenuCallbackHandler:toggle_net_use_compression_raid(value)
	managers.user:set_setting("net_use_compression", value)
end

function MenuCallbackHandler:set_master_volume_raid(volume)
	local old_volume = managers.user:get_setting("master_volume")

	managers.user:set_setting("master_volume", volume)
	managers.video:volume_changed(volume / 100)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

function MenuCallbackHandler:set_music_volume_raid(volume)
	local old_volume = managers.user:get_setting("music_volume")

	managers.user:set_setting("music_volume", volume)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

function MenuCallbackHandler:set_sfx_volume_raid(volume)
	local old_volume = managers.user:get_setting("sfx_volume")

	managers.user:set_setting("sfx_volume", volume)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

function MenuCallbackHandler:set_voice_volume_raid(volume)
	local old_volume = managers.user:get_setting("voice_volume")

	managers.user:set_setting("voice_volume", volume / 100)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

function MenuCallbackHandler:set_voice_over_volume_raid(volume)
	local old_volume = managers.user:get_setting("voice_over_volume")

	managers.user:set_setting("voice_over_volume", volume)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

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

function MenuCallbackHandler:toggle_push_to_talk_raid(value)
	managers.user:set_setting("push_to_talk", value)
end

function MenuCallbackHandler:toggle_tinnitus_raid(value)
	managers.user:set_setting("tinnitus_sound_enabled", value)
end

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

	local blackborder_workspace = MenuRenderer.get_blackborder_workspace_instance()

	blackborder_workspace:set_screen(resolution.x, resolution.y, 0, 0, resolution.x, resolution.y, resolution.x, resolution.y)

	if not no_dialog then
		managers.menu:show_accept_gfx_settings_dialog(function ()
			managers.viewport:set_resolution(old_resolution)
			managers.viewport:set_aspect_ratio(old_resolution.x / old_resolution.y)
			managers.worldcamera:scale_worldcamera_fov(old_resolution.x / old_resolution.y)

			local blackborder_workspace = MenuRenderer.get_blackborder_workspace_instance()

			blackborder_workspace:set_screen(old_resolution.x, old_resolution.y, 0, 0, old_resolution.x, old_resolution.y, old_resolution.x, old_resolution.y)
		end)
	end

	self:_refresh_brightness()
end

function MenuCallbackHandler:set_resolution_default_raid_no_dialog(resolution)
	local old_resolution = RenderSettings.resolution

	if resolution == old_resolution then
		return
	end

	managers.viewport:set_resolution(resolution)
	managers.viewport:set_aspect_ratio(resolution.x / resolution.y)
	managers.worldcamera:scale_worldcamera_fov(resolution.x / resolution.y)

	local blackborder_workspace = MenuRenderer.get_blackborder_workspace_instance()

	blackborder_workspace:set_screen(resolution.x, resolution.y, 0, 0, resolution.x, resolution.y, resolution.x, resolution.y)
end

function MenuCallbackHandler:toggle_fullscreen_raid(fullscreen, current_fullscreen, borderless, current_borderless, callback)
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

	managers.menu:show_accept_gfx_settings_dialog(function ()
		managers.viewport:set_fullscreen(current_fullscreen)
		managers.viewport:set_borderless(current_borderless)

		if managers.viewport:is_fullscreen() then
			managers.mouse_pointer:acquire_input()
		else
			managers.mouse_pointer:unacquire_input()
		end

		self:refresh_node()
		callback()
	end)
	self:refresh_node()
	self:_refresh_brightness()
end

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

function MenuCallbackHandler:toggle_subtitle_raid(value)
	managers.user:set_setting("subtitle", value)
end

function MenuCallbackHandler:set_hit_indicator_raid(value)
	managers.user:set_setting("hit_indicator", value)
end

function MenuCallbackHandler:toggle_hud_special_weapon_panels(value)
	managers.user:set_setting("hud_special_weapon_panels", value)
end

function MenuCallbackHandler:set_motion_dot_raid(value)
	managers.user:set_setting("motion_dot", value)

	if managers.hud then
		managers.hud:set_motiondot_visibility(value)
	end
end

function MenuCallbackHandler:set_motion_dot_size_raid(value)
	managers.user:set_setting("motion_dot_size", value)

	if managers.hud then
		managers.hud:set_motiondot_sizes(value)
	end
end

function MenuCallbackHandler:toggle_objective_reminder_raid(value)
	managers.user:set_setting("objective_reminder", value)
end

function MenuCallbackHandler:toggle_headbob_raid(value)
	managers.user:set_setting("use_headbob", value)
end

function MenuCallbackHandler:set_effect_quality_raid(value)
	managers.user:set_setting("effect_quality", value)
end

function MenuCallbackHandler:set_brightness_raid(value)
	managers.user:set_setting("brightness", value)
end

function MenuCallbackHandler:toggle_dof_setting_raid(value)
	managers.user:set_setting("dof_setting", value and "standard" or "none")
end

function MenuCallbackHandler:toggle_ssao_setting_raid(value)
	managers.user:set_setting("ssao_setting", value and "standard" or "none")
end

function MenuCallbackHandler:set_use_parallax_raid(value)
	managers.user:set_setting("use_parallax", value)
end

function MenuCallbackHandler:toggle_motion_blur_setting_raid(value)
	managers.user:set_setting("motion_blur_setting", value and "standard" or "none")
end

function MenuCallbackHandler:toggle_volumetric_light_scattering_setting_raid(value)
	managers.user:set_setting("vls_setting", value and "standard" or "none")
end

function MenuCallbackHandler:toggle_gpu_flush_setting_raid(value)
	managers.user:set_setting("flush_gpu_command_queue", value)
end

function MenuCallbackHandler:toggle_lightfx_raid(value)
	managers.user:set_setting("use_lightfx", value)
end

function MenuCallbackHandler:toggle_vsync_raid(vsync_value, buffer_count)
	managers.viewport:set_vsync(vsync_value)
	managers.viewport:set_buffer_count(buffer_count)
	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

function MenuCallbackHandler:set_fov_multiplier_raid(value)
	managers.user:set_setting("fov_multiplier", value)

	if alive(managers.player:player_unit()) then
		managers.player:player_unit():movement():current_state():update_fov_external()
	end
end

function MenuCallbackHandler:set_detail_distance_raid(detail_distance)
	managers.user:set_setting("detail_distance", detail_distance)

	local min_maps = 0.0025
	local max_maps = 0.05
	local maps = math.lerp(max_maps, min_maps, detail_distance)

	Application:debug("RaidMenuOptionsVideoAdvanced:on_value_change_detail_distance", detail_distance, maps)
	World:set_min_allowed_projected_size(maps)
end

function MenuCallbackHandler:choice_choose_anti_alias_raid(value)
	managers.user:set_setting("AA_setting", value)
end

function MenuCallbackHandler:choice_choose_texture_quality_raid(value)
	RenderSettings.texture_quality_default = value

	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

function MenuCallbackHandler:choice_choose_shadow_quality_raid(value)
	RenderSettings.shadow_quality_default = value

	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

function MenuCallbackHandler:choice_choose_anisotropic_raid(value)
	RenderSettings.max_anisotropy = value

	self:apply_and_save_render_settings()
	self:_refresh_brightness()
end

function MenuCallbackHandler:choice_choose_anim_lod_raid(value)
	managers.user:set_setting("video_animation_lod", value)
end

function MenuCallbackHandler:choice_fps_cap_raid(value)
	setup:set_fps_cap(value)
	managers.user:set_setting("fps_cap", value)
end

function MenuCallbackHandler:choice_max_streaming_chunk_raid(value)
	managers.user:set_setting("max_streaming_chunk", value)
end

function MenuCallbackHandler:choice_choose_cb_mode_raid(value)
	managers.user:set_setting("colorblind_setting", value)
end

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
