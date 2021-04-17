MenuCallbackHandler = MenuCallbackHandler or class(CoreMenuCallbackHandler.CallbackHandler)

-- Lines 6-9
function MenuCallbackHandler:init()
	MenuCallbackHandler.super.init(self)

	self._sound_source = SoundDevice:create_source("MenuCallbackHandler")
end

-- Lines 11-14
function MenuCallbackHandler:trial_buy()
	print("[MenuCallbackHandler:trial_buy]")
	managers.dlc:buy_full_game()
end

-- Lines 16-19
function MenuCallbackHandler:dlc_buy_pc()
	print("[MenuCallbackHandler:dlc_buy_pc]")
	Steam:overlay_activate("store", managers.dlc:get_app_id())
end

-- Lines 21-23
function MenuCallbackHandler:has_full_game()
	return managers.dlc:has_full_game()
end

-- Lines 25-27
function MenuCallbackHandler:is_trial()
	return managers.dlc:is_trial()
end

-- Lines 29-31
function MenuCallbackHandler:is_not_trial()
	return not self:is_trial()
end

-- Lines 33-35
function MenuCallbackHandler:has_preorder()
	return managers.dlc:has_preorder()
end

-- Lines 37-39
function MenuCallbackHandler:not_has_preorder()
	return not managers.dlc:has_preorder()
end

-- Lines 41-43
function MenuCallbackHandler:has_all_dlcs()
	return true
end

-- Lines 45-47
function MenuCallbackHandler:is_overlay_enabled()
	return SystemInfo:platform() == Idstring("WIN32") and Steam:overlay_enabled() or false
end

-- Lines 49-55
function MenuCallbackHandler:is_installed()
	if SystemInfo:platform() == Idstring("WIN32") then
		return true
	end

	local is_installing, install_progress = managers.dlc:is_installing()

	return not is_installing
end

-- Lines 57-59
function MenuCallbackHandler:show_game_is_installing_menu()
	managers.menu:show_game_is_installing_menu()
end

-- Lines 61-63
function MenuCallbackHandler:bang_active()
	return true
end

-- Lines 65-76
function MenuCallbackHandler:_on_host_setting_updated()
end

-- Lines 78-87
function MenuCallbackHandler:choice_region_filter(item)
	local region_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("region") == region_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("region", region_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 89-98
function MenuCallbackHandler:choice_job_plan_filter(item)
	local job_plan_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("job_plan") == job_plan_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("job_plan", job_plan_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 103-127
function MenuCallbackHandler:is_dlc_latest_locked(check_dlc)
	local dlcs = {}
	local dlc_tweak_data = tweak_data.dlc

	for _, dlc in ipairs(dlcs) do
		if dlc_tweak_data[dlc] then
			local dlc_func = dlc_tweak_data[dlc].dlc

			if dlc_tweak_data[dlc].free then
				return false
			elseif dlc_func then
				if not managers.dlc[dlc_func](managers.dlc, dlc_tweak_data[dlc]) then
					return dlc == check_dlc
				end
			else
				Application:error("[MenuCallbackHandler:is_dlc_lastest_locked] DLC do not have a dlc check function tweak_data_dlc.dlc", dlc)
			end

			if dlc == check_dlc then
				break
			end
		else
			Application:error("[MenuCallbackHandler:is_dlc_lastest_locked] DLC do not exist in dlc tweak data", dlc)
		end
	end

	return false
end

-- Lines 129-131
function MenuCallbackHandler:not_has_all_dlcs()
	return not self:has_all_dlcs()
end

-- Lines 133-135
function MenuCallbackHandler:reputation_check(data)
	return data:value() <= managers.experience:current_level()
end

-- Lines 137-139
function MenuCallbackHandler:non_overkill_145(data)
	return true
end

-- Lines 141-143
function MenuCallbackHandler:to_be_continued()
	return true
end

-- Lines 145-147
function MenuCallbackHandler:is_level_145()
	return managers.experience:current_level() >= 145
end

-- Lines 149-151
function MenuCallbackHandler:is_level_100()
	return managers.experience:current_level() >= 100
end

-- Lines 153-155
function MenuCallbackHandler:is_level_50()
	return managers.experience:current_level() >= 50
end

-- Lines 157-159
function MenuCallbackHandler:is_win32()
	return SystemInfo:platform() == Idstring("WIN32")
end

-- Lines 161-163
function MenuCallbackHandler:is_fullscreen()
	return managers.viewport:is_fullscreen()
end

-- Lines 165-167
function MenuCallbackHandler:voice_enabled()
	return self:is_ps3() or self:is_win32() and managers.network and managers.network.voice_chat and managers.network.voice_chat:enabled()
end

-- Lines 169-171
function MenuCallbackHandler:customize_controller_enabled()
	return true
end

-- Lines 173-175
function MenuCallbackHandler:is_win32_not_lan()
	return SystemInfo:platform() == Idstring("WIN32") and not Global.game_settings.playing_lan
end

-- Lines 177-179
function MenuCallbackHandler:is_console()
	return self:is_ps3() or self:is_x360() or self:is_ps4() or self:is_xb1()
end

-- Lines 181-183
function MenuCallbackHandler:is_ps3()
	return SystemInfo:platform() == Idstring("PS3")
end

-- Lines 185-187
function MenuCallbackHandler:is_ps4()
	return SystemInfo:platform() == Idstring("PS4")
end

-- Lines 189-191
function MenuCallbackHandler:is_x360()
	return SystemInfo:platform() == Idstring("X360")
end

-- Lines 193-195
function MenuCallbackHandler:is_xb1()
	return SystemInfo:platform() == Idstring("XB1")
end

-- Lines 197-199
function MenuCallbackHandler:is_not_x360()
	return not self:is_x360()
end

-- Lines 201-203
function MenuCallbackHandler:is_not_xbox()
	return not self:is_x360()
end

-- Lines 205-207
function MenuCallbackHandler:is_not_nextgen()
	return not self:is_xb1() and not self:is_ps4()
end

-- Lines 209-211
function MenuCallbackHandler:is_na()
	return MenuManager.IS_NORTH_AMERICA
end

-- Lines 213-215
function MenuCallbackHandler:has_dropin()
	return NetworkManager.DROPIN_ENABLED
end

-- Lines 218-220
function MenuCallbackHandler:is_server()
	return Network:is_server()
end

-- Lines 222-224
function MenuCallbackHandler:is_not_server()
	return not self:is_server()
end

-- Lines 226-228
function MenuCallbackHandler:is_online()
	return managers.network.account:signin_state() == "signed in"
end

-- Lines 230-232
function MenuCallbackHandler:is_singleplayer()
	return Global.game_settings.single_player
end

-- Lines 234-236
function MenuCallbackHandler:is_multiplayer()
	return not Global.game_settings.single_player
end

-- Lines 238-240
function MenuCallbackHandler:is_not_max_rank()
	return managers.experience:current_rank() < #tweak_data.infamy.ranks
end

-- Lines 242-244
function MenuCallbackHandler:can_become_infamous()
	return self:is_level_100() and self:is_not_max_rank()
end

-- Lines 246-248
function MenuCallbackHandler:singleplayer_restart()
	return self:is_singleplayer() and self:has_full_game()
end

-- Lines 250-252
function MenuCallbackHandler:kick_player_visible()
	return self:is_server() and self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_host_kick()
end

-- Lines 254-256
function MenuCallbackHandler:kick_vote_visible()
	return self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_vote_kick()
end

-- Lines 258-265
function MenuCallbackHandler:_restart_level_visible()
	if not self:is_multiplayer() or managers.raid_job:is_camp_loaded() then
		return false
	end

	local state = game_state_machine:current_state_name()

	return state ~= "ingame_waiting_for_players" and state ~= "ingame_lobby_menu" and state ~= "empty"
end

-- Lines 267-269
function MenuCallbackHandler:restart_level_visible()
	return self:is_server() and self:_restart_level_visible() and managers.vote:option_host_restart()
end

-- Lines 271-273
function MenuCallbackHandler:restart_vote_visible()
	return self:_restart_level_visible() and managers.vote:option_vote_restart()
end

-- Lines 275-285
function MenuCallbackHandler:abort_mission_visible()
	if not self:is_not_editor() or not self:is_server() or not self:is_multiplayer() then
		return false
	end

	if game_state_machine:current_state_name() == "disconnected" then
		return false
	end

	return true
end

-- Lines 287-289
function MenuCallbackHandler:lobby_exist()
	return managers.network.matchmake.lobby_handler
end

-- Lines 291-293
function MenuCallbackHandler:hidden()
	return false
end

-- Lines 295-298
function MenuCallbackHandler:chat_visible()
	return SystemInfo:platform() == Idstring("WIN32")
end

-- Lines 300-303
function MenuCallbackHandler:is_pc_controller()
	return managers.menu:is_pc_controller()
end

-- Lines 305-307
function MenuCallbackHandler:is_not_pc_controller()
	return not self:is_pc_controller()
end

-- Lines 309-311
function MenuCallbackHandler:is_steam_controller()
	return managers.menu:is_steam_controller()
end

-- Lines 313-315
function MenuCallbackHandler:is_not_steam_controller()
	return not self:is_steam_controller()
end

-- Lines 317-319
function MenuCallbackHandler:is_not_editor()
	return not Application:editor()
end

-- Lines 321-323
function MenuCallbackHandler:show_credits()
	game_state_machine:change_state_by_name("menu_credits")
end

-- Lines 325-328
function MenuCallbackHandler:can_load_game()
	return not Application:editor() and not Network:multiplayer()
end

-- Lines 330-332
function MenuCallbackHandler:can_save_game()
	return not Application:editor() and not Network:multiplayer()
end

-- Lines 334-336
function MenuCallbackHandler:is_not_multiplayer()
	return not Network:multiplayer()
end

-- Lines 338-340
function MenuCallbackHandler:debug_menu_enabled()
	return managers.menu:debug_menu_enabled()
end

-- Lines 342-346
function MenuCallbackHandler:leave_online_menu()
	managers.menu:leave_online_menu()
end

-- Lines 348-350
function MenuCallbackHandler:has_peer_1()
	return not not managers.network:session() and managers.network:session():peer(1)
end

-- Lines 352-354
function MenuCallbackHandler:has_peer_2()
	return not not managers.network:session() and managers.network:session():peer(2)
end

-- Lines 356-358
function MenuCallbackHandler:has_peer_3()
	return not not managers.network:session() and managers.network:session():peer(3)
end

-- Lines 360-362
function MenuCallbackHandler:has_peer_4()
	return not not managers.network:session() and managers.network:session():peer(4)
end

-- Lines 365-371
function MenuCallbackHandler:on_visit_forum()
	if not MenuCallbackHandler:is_overlay_enabled() then
		managers.menu:show_enable_steam_overlay()

		return
	end

	Steam:overlay_activate("url", "http://forums.steampowered.com/forums/forumdisplay.php?f=1225")
end

-- Lines 373-379
function MenuCallbackHandler:on_visit_gamehub()
	if not MenuCallbackHandler:is_overlay_enabled() then
		managers.menu:show_enable_steam_overlay()

		return
	end

	Steam:overlay_activate("url", "http://steamcommunity.com/app/" .. tostring(managers.dlc:get_app_id()))
end

-- Lines 381-383
function MenuCallbackHandler:on_buy_dlc1()
	Steam:overlay_activate("store", managers.dlc:get_app_id())
end

-- Lines 385-392
function MenuCallbackHandler:on_account_picker()
	print("MenuCallbackHandler:on_account_picker()")

	-- Lines 387-390
	local function confirm_cb()
		-- Lines 388-388
		local function f(...)
			print("result", ...)
		end

		managers.system_menu:show_select_user({
			count = 1,
			callback_func = f
		})
	end

	managers.menu:show_account_picker_dialog({
		yes_func = confirm_cb
	})
end

-- Lines 394-397
function MenuCallbackHandler:on_menu_option_help()
	print("MenuCallbackHandler:on_menu_option_help()")
	XboxLive:show_help_ui()
end

-- Lines 399-416
function MenuCallbackHandler:quit_game()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_to_quit")
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

-- Lines 418-437
function MenuCallbackHandler:_dialog_quit_yes()
	self:_dialog_save_progress_backup_no()
end

-- Lines 439-440
function MenuCallbackHandler:_dialog_quit_no()
end

-- Lines 442-446
function MenuCallbackHandler:_dialog_save_progress_backup_yes()
	setup:quit()
end

-- Lines 448-450
function MenuCallbackHandler:_dialog_save_progress_backup_no()
	setup:quit()
end

-- Lines 452-456
function MenuCallbackHandler:chk_dlc_content_updated()
	if managers.dlc then
		managers.dlc:chk_content_updated()
	end
end

-- Lines 459-476
function MenuCallbackHandler:toggle_ready(item)
	local ready = item:value() == "on"

	if not managers.network:session() then
		return
	end

	managers.network:session():local_peer():set_waiting_for_player_ready(ready)
	managers.network:session():chk_send_local_player_ready()

	if managers.menu:active_menu() and managers.menu:active_menu().renderer and managers.menu:active_menu().renderer.set_ready_items_enabled then
		managers.menu:active_menu().renderer:set_ready_items_enabled(not ready)
	end

	managers.network:session():on_set_member_ready(managers.network:session():local_peer():id(), ready, true, false)
end

-- Lines 478-483
function MenuCallbackHandler:change_nr_players(item)
	local nr_players = item:value()
	Global.nr_players = nr_players

	managers.player:set_nr_players(nr_players)
end

-- Lines 485-488
function MenuCallbackHandler:invert_camera_horisontally(item)
	local invert = item:value() == "on"

	managers.user:set_setting("invert_camera_x", invert)
end

-- Lines 490-493
function MenuCallbackHandler:invert_camera_vertically(item)
	local invert = item:value() == "on"

	managers.user:set_setting("invert_camera_y", invert)
end

-- Lines 495-498
function MenuCallbackHandler:toggle_dof_setting(item)
	local dof_setting = item:value() == "on"

	managers.user:set_setting("dof_setting", dof_setting and "standard" or "none")
end

-- Lines 500-503
function MenuCallbackHandler:toggle_ssao_setting(item)
	local ssao_setting = item:value() == "on"

	managers.user:set_setting("ssao_setting", ssao_setting and "standard" or "none")
end

-- Lines 505-508
function MenuCallbackHandler:toggle_motion_blur_setting(item)
	local motion_blur_setting = item:value() == "on"

	managers.user:set_setting("motion_blur_setting", motion_blur_setting and "standard" or "none")
end

-- Lines 510-513
function MenuCallbackHandler:toggle_volumetric_light_scattering_setting(item)
	local vls_setting = item:value() == "on"

	managers.user:set_setting("vls_setting", vls_setting and "standard" or "none")
end

-- Lines 515-518
function MenuCallbackHandler:choice_choose_AA_quality(item)
	local AA_setting = item:value()

	managers.user:set_setting("AA_setting", AA_setting)
end

-- Lines 520-523
function MenuCallbackHandler:choice_choose_cb_mode(item)
	local cb_setting = item:value()

	managers.user:set_setting("colorblind_setting", cb_setting)
end

-- Lines 525-528
function MenuCallbackHandler:hold_to_steelsight(item)
	local hold = item:value() == "on"

	managers.user:set_setting("hold_to_steelsight", hold)
end

-- Lines 530-533
function MenuCallbackHandler:hold_to_run(item)
	local hold = item:value() == "on"

	managers.user:set_setting("hold_to_run", hold)
end

-- Lines 535-538
function MenuCallbackHandler:hold_to_duck(item)
	local hold = item:value() == "on"

	managers.user:set_setting("hold_to_duck", hold)
end

-- Lines 540-555
function MenuCallbackHandler:toggle_fullscreen(item)
	local fullscreen = item:value() == "on"

	if managers.viewport:is_fullscreen() == fullscreen then
		return
	end

	managers.viewport:set_fullscreen(fullscreen)
	managers.menu:show_accept_gfx_settings_dialog(function ()
		managers.viewport:set_fullscreen(not fullscreen)
		item:set_value(not fullscreen and "on" or "off")
		self:refresh_node()
	end)
	self:refresh_node()
end

-- Lines 557-560
function MenuCallbackHandler:toggle_subtitle(item)
	local subtitle = item:value() == "on"

	managers.user:set_setting("subtitle", subtitle)
end

-- Lines 562-565
function MenuCallbackHandler:toggle_hit_indicator(item)
	local on = item:value() == "on"

	managers.user:set_setting("hit_indicator", on)
end

-- Lines 567-570
function MenuCallbackHandler:toggle_objective_reminder(item)
	local on = item:value() == "on"

	managers.user:set_setting("objective_reminder", on)
end

-- Lines 572-575
function MenuCallbackHandler:toggle_voicechat(item)
	local vchat = item:value() == "on"

	managers.user:set_setting("voice_chat", vchat)
end

-- Lines 577-580
function MenuCallbackHandler:toggle_push_to_talk(item)
	local vchat = item:value() == "on"

	managers.user:set_setting("push_to_talk", vchat)
end

-- Lines 583-586
function MenuCallbackHandler:toggle_team_AI(item)
	Global.game_settings.team_ai = item:value() == "on"

	managers.groupai:state():on_criminal_team_AI_enabled_state_changed()
end

-- Lines 588-596
function MenuCallbackHandler:toggle_coordinates(item)
	Global.debug_show_coords = item:value() == "on"

	if Global.debug_show_coords then
		managers.hud:debug_show_coordinates()
	else
		managers.hud:debug_hide_coordinates()
	end
end

-- Lines 598-601
function MenuCallbackHandler:toggle_net_throttling(item)
	local state = item:value() == "on"

	managers.user:set_setting("net_packet_throttling", state, nil)
end

-- Lines 603-606
function MenuCallbackHandler:toggle_net_forwarding(item)
	local state = item:value() == "on"

	managers.user:set_setting("net_forwarding", state, nil)
end

-- Lines 608-612
function MenuCallbackHandler:toggle_net_use_compression(item)
	local state = item:value() == "on"

	print("[MenuCallbackHandler:toggle_net_use_compression]", state)
	managers.user:set_setting("net_use_compression", state, nil)
end

-- Lines 614-630
function MenuCallbackHandler:change_resolution(item)
	local old_resolution = RenderSettings.resolution

	if item:parameters().resolution == old_resolution then
		return
	end

	managers.viewport:set_resolution(item:parameters().resolution)
	managers.viewport:set_aspect_ratio(item:parameters().resolution.x / item:parameters().resolution.y)
	managers.menu:show_accept_gfx_settings_dialog(function ()
		managers.viewport:set_resolution(old_resolution)
		managers.viewport:set_aspect_ratio(old_resolution.x / old_resolution.y)
	end)
	self:_refresh_brightness()
end

-- Lines 632-635
function MenuCallbackHandler:choice_test(item)
	local test = item:value()

	print("MenuCallbackHandler", test)
end

-- Lines 637-656
function MenuCallbackHandler:choice_premium_contact(item)
	if not managers.menu:active_menu() then
		return false
	end

	if not managers.menu:active_menu().logic then
		return false
	end

	if not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	managers.menu:active_menu().logic:selected_node():parameters().listed_contact = string.gsub(item:value(), "#", "")
	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
	end
end

-- Lines 658-675
function MenuCallbackHandler:choice_controller_type(item)
	if not managers.menu:active_menu() then
		return false
	end

	if not managers.menu:active_menu().logic then
		return false
	end

	if not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	managers.menu:active_menu().logic:selected_node():parameters().controller_category = item:value()
	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
	end
end

-- Lines 677-681
function MenuCallbackHandler:choice_max_lobbies_filter(item)
	local max_server_jobs_filter = item:value()

	managers.network.matchmake:set_lobby_return_count(max_server_jobs_filter)
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 683-692
function MenuCallbackHandler:choice_distance_filter(item)
	local dist_filter = item:value()

	if managers.network.matchmake:distance_filter() == dist_filter then
		return
	end

	managers.network.matchmake:set_distance_filter(dist_filter)
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 694-708
function MenuCallbackHandler:choice_difficulty_filter(item)
	local diff_filter = item:value()

	print("diff_filter", diff_filter)

	if managers.network.matchmake:get_lobby_filter("difficulty") == diff_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("difficulty", diff_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 710-719
function MenuCallbackHandler:choice_job_id_filter(item)
	local job_id_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("job_id") == job_id_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("job_id", job_id_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 721-730
function MenuCallbackHandler:choice_new_servers_only(item)
	local num_players_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("num_players") == num_players_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("num_players", num_players_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 732-741
function MenuCallbackHandler:choice_kick_option(item)
	local kicking_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("kick_option") == kicking_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("kick_option", kicking_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 743-748
function MenuCallbackHandler:choice_job_appropriate_filter(item)
	local diff_appropriate = item:value()
	Global.game_settings.search_appropriate_jobs = diff_appropriate == "on" and true or false

	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 750-759
function MenuCallbackHandler:choice_server_state_lobby(item)
	local state_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("state") == state_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("state", state_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 761-767
function MenuCallbackHandler:refresh_node(item)
	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
	end
end

-- Lines 770-776
function MenuCallbackHandler:crimenet_casino_secured_cards()
	local card1 = managers.menu:active_menu().logic:selected_node():item("secure_card_1"):value() == "on" and 1 or 0
	local card2 = managers.menu:active_menu().logic:selected_node():item("secure_card_2"):value() == "on" and 1 or 0
	local card3 = managers.menu:active_menu().logic:selected_node():item("secure_card_3"):value() == "on" and 1 or 0

	return card1 + card2 + card3
end

-- Lines 778-782
function MenuCallbackHandler:crimenet_casino_update(item)
	if item:enabled() then
		self:refresh_node()
	end
end

-- Lines 784-795
function MenuCallbackHandler:crimenet_casino_safe_card1(item)
	if managers.menu:active_menu().logic:selected_node():item("secure_card_1"):enabled() then
		if managers.menu:active_menu().logic:selected_node():item("secure_card_2"):value() == "on" then
			managers.menu:active_menu().logic:selected_node():item("secure_card_1"):set_value("on")
		end

		managers.menu:active_menu().logic:selected_node():item("secure_card_2"):set_value("off")
		managers.menu:active_menu().logic:selected_node():item("secure_card_3"):set_value("off")
		self:refresh_node()
	end
end

-- Lines 797-808
function MenuCallbackHandler:crimenet_casino_safe_card2(item)
	if managers.menu:active_menu().logic:selected_node():item("secure_card_2"):enabled() then
		if managers.menu:active_menu().logic:selected_node():item("secure_card_3"):value() == "on" then
			managers.menu:active_menu().logic:selected_node():item("secure_card_2"):set_value("on")
		end

		managers.menu:active_menu().logic:selected_node():item("secure_card_1"):set_value("on")
		managers.menu:active_menu().logic:selected_node():item("secure_card_3"):set_value("off")
		self:refresh_node()
	end
end

-- Lines 810-817
function MenuCallbackHandler:crimenet_casino_safe_card3(item)
	if managers.menu:active_menu().logic:selected_node():item("secure_card_3"):enabled() then
		managers.menu:active_menu().logic:selected_node():item("secure_card_1"):set_value("on")
		managers.menu:active_menu().logic:selected_node():item("secure_card_2"):set_value("on")
		self:refresh_node()
	end
end

-- Lines 819-828
function MenuCallbackHandler:choice_difficulty_filter_ps3(item)
	local diff_filter = item:value()

	print("diff_filter", diff_filter)

	if managers.network.matchmake:difficulty_filter() == diff_filter then
		return
	end

	managers.network.matchmake:set_difficulty_filter(diff_filter)
	managers.network.matchmake:start_search_lobbys(managers.network.matchmake:searching_friends_only())
end

-- Lines 830-838
function MenuCallbackHandler:lobby_create_campaign(item)
	MenuCallbackHandler:choice_lobby_campaign(item)

	local job_id = Global.game_settings.level_id

	Application:debug("[MenuCallbackHandler:lobby_create_campaign]", job_id)

	Global.exe_argument_level = job_id
	Global.exe_argument_difficulty = Global.exe_argument_difficulty or Global.DEFAULT_DIFFICULTY

	MenuCallbackHandler:start_job({
		job_id = job_id,
		difficulty = Global.DEFAULT_DIFFICULTY
	})
end

-- Lines 841-862
function MenuCallbackHandler:choice_lobby_campaign(item)
	Application:debug("[MenuCallbackHandler:choice_lobby_campaign]")

	if not item:enabled() then
		return
	end

	Global.game_settings.level_id = item:parameter("level_id")

	MenuManager.refresh_level_select(managers.menu:active_menu().logic:selected_node(), true)

	if managers.menu:active_menu().renderer.update_level_id then
		managers.menu:active_menu().renderer:update_level_id(Global.game_settings.level_id)
	end

	if managers.menu:active_menu().renderer.update_difficulty then
		managers.menu:active_menu().renderer:update_difficulty()
	end

	managers.menu:show_global_success()
	managers.network:update_matchmake_attributes()
end

-- Lines 864-866
function MenuCallbackHandler:set_lan_game()
	Global.game_settings.playing_lan = true
end

-- Lines 868-870
function MenuCallbackHandler:set_not_lan_game()
	Global.game_settings.playing_lan = nil
end

-- Lines 872-874
function MenuCallbackHandler:create_lobby()
	managers.network.matchmake:create_lobby(managers.network:get_matchmake_attributes())
end

-- Lines 878-883
function MenuCallbackHandler:play_single_player()
	Global.game_settings.single_player = true

	managers.network:host_game()
	Network:set_server()
end

-- Lines 885-888
function MenuCallbackHandler:play_online_game()
	Application:debug("[MenuCallbackHandler:play_online_game]")

	Global.game_settings.single_player = false
end

-- Lines 890-912
function MenuCallbackHandler:apply_and_save_render_settings()
	-- Lines 891-894
	local function func()
		Application:apply_render_settings()
		Application:save_render_settings()
	end

	local fullscreen_ws = managers.menu_component and managers.menu_component._fullscreen_ws

	if game_state_machine:current_state()._name ~= "menu_main" and alive(fullscreen_ws) then
		local black_overlay = fullscreen_ws:panel():panel({
			name = "apply_render_settings_panel",
			layer = tweak_data.gui.MOUSE_LAYER - 1
		})

		black_overlay:rect({
			color = Color.black
		})
		black_overlay:animate(function (o)
			coroutine.yield()
			func()
			over(0.05, function (p)
				black_overlay:set_alpha(1 - p)
			end)
			fullscreen_ws:panel():remove(black_overlay)
		end)

		return
	end

	func()
end

-- Lines 914-919
function MenuCallbackHandler:choice_choose_texture_quality(item)
	RenderSettings.texture_quality_default = item:value()

	MenuCallbackHandler:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 921-926
function MenuCallbackHandler:choice_choose_shadow_quality(item)
	RenderSettings.shadow_quality_default = item:value()

	MenuCallbackHandler:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 928-930
function MenuCallbackHandler:toggle_gpu_flush_setting(item)
	managers.user:set_setting("flush_gpu_command_queue", item:value() == "on")
end

-- Lines 932-937
function MenuCallbackHandler:choice_choose_anisotropic(item)
	RenderSettings.max_anisotropy = item:value()

	MenuCallbackHandler:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 939-942
function MenuCallbackHandler:choice_fps_cap(item)
	setup:set_fps_cap(item:value())
	managers.user:set_setting("fps_cap", item:value())
end

-- Lines 944-946
function MenuCallbackHandler:choice_choose_color_grading(item)
	managers.user:set_setting("video_color_grading", item:value())
end

-- Lines 948-950
function MenuCallbackHandler:choice_choose_anti_alias(item)
	managers.user:set_setting("video_anti_alias", item:value())
end

-- Lines 952-954
function MenuCallbackHandler:choice_choose_anim_lod(item)
	managers.user:set_setting("video_animation_lod", item:value())
end

-- Lines 956-959
function MenuCallbackHandler:toggle_vsync(item)
	managers.viewport:set_vsync(item:value() == "on")
	self:_refresh_brightness()
end

-- Lines 962-964
function MenuCallbackHandler:toggle_use_thq_weapon_parts(item)
	managers.user:set_setting("use_thq_weapon_parts", item:value() == "on")
end

-- Lines 966-968
function MenuCallbackHandler:toggle_streaks(item)
	managers.user:set_setting("video_streaks", item:value() == "on")
end

-- Lines 970-972
function MenuCallbackHandler:toggle_light_adaption(item)
	managers.user:set_setting("light_adaption", item:value() == "on")
end

-- Lines 975-977
function MenuCallbackHandler:toggle_lightfx(item)
	managers.user:set_setting("use_lightfx", item:value() == "on")
end

-- Lines 979-981
function MenuCallbackHandler:choice_max_streaming_chunk(item)
	managers.user:set_setting("max_streaming_chunk", item:value())
end

-- Lines 983-990
function MenuCallbackHandler:set_fov_multiplier(item)
	local fov_multiplier = item:value()

	managers.user:set_setting("fov_multiplier", fov_multiplier)

	if alive(managers.player:player_unit()) then
		managers.player:player_unit():movement():current_state():update_fov_external()
	end
end

-- Lines 992-1002
function MenuCallbackHandler:set_detail_distance(item)
	local detail_distance = item:value()

	managers.user:set_setting("detail_distance", detail_distance)

	local min_maps = 0.01
	local max_maps = 0.04
	local maps = min_maps * detail_distance + max_maps * (1 - detail_distance)

	World:set_min_allowed_projected_size(maps)
end

-- Lines 1004-1007
function MenuCallbackHandler:set_use_parallax(item)
	local use_parallax = item:value() == "on"

	managers.user:set_setting("use_parallax", use_parallax)
end

-- Lines 1009-1025
function MenuCallbackHandler:set_fov_standard(item)
	return

	local fov = item:value()

	managers.user:set_setting("fov_standard", fov)

	local item_fov_zoom = managers.menu:active_menu().logic:selected_node():item("fov_zoom")

	if fov < item_fov_zoom:value() then
		item_fov_zoom:set_value(fov)
		item_fov_zoom:trigger()
	end

	if alive(managers.player:player_unit()) then
		local plr_state = managers.player:player_unit():movement():current_state()
		local stance = plr_state:in_steelsight() and "steelsight" or plr_state._state_data.ducking and "crouched" or "standard"

		plr_state._camera_unit:base():set_stance_fov_instant(stance)
	end
end

-- Lines 1027-1043
function MenuCallbackHandler:set_fov_zoom(item)
	return

	local fov = item:value()

	managers.user:set_setting("fov_zoom", fov)

	local item_fov_standard = managers.menu:active_menu().logic:selected_node():item("fov_standard")

	if item_fov_standard:value() < fov then
		item_fov_standard:set_value(fov)
		item_fov_standard:trigger()
	end

	if alive(managers.player:player_unit()) then
		local plr_state = managers.player:player_unit():movement():current_state()
		local stance = plr_state:in_steelsight() and "steelsight" or plr_state._state_data.ducking and "crouched" or "standard"

		plr_state._camera_unit:base():set_stance_fov_instant(stance)
	end
end

-- Lines 1045-1047
function MenuCallbackHandler:toggle_headbob(item)
	managers.user:set_setting("use_headbob", item:value() == "on")
end

-- Lines 1049-1051
function MenuCallbackHandler:on_stage_success()
	managers.mission:on_stage_success()
end

-- Lines 1053-1055
function MenuCallbackHandler:lobby_start_the_game()
	MenuCallbackHandler:start_the_game()
end

-- Lines 1057-1084
function MenuCallbackHandler:leave_lobby()
	if game_state_machine:current_state_name() == "ingame_lobby_menu" then
		self:end_game()

		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_are_you_sure_you_want_leave"),
		id = "leave_lobby"
	}
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = callback(self, self, "_dialog_leave_lobby_yes")
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		callback_func = callback(self, self, "_dialog_leave_lobby_no"),
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

-- Lines 1086-1105
function MenuCallbackHandler:_dialog_leave_lobby_yes()
	if managers.network:session() then
		managers.network:session():local_peer():set_in_lobby(false)
		managers.network:session():send_to_peers("set_peer_left")
	end

	managers.menu:on_leave_lobby()
end

-- Lines 1107-1108
function MenuCallbackHandler:_dialog_leave_lobby_no()
end

-- Lines 1110-1127
function MenuCallbackHandler:connect_to_host_rpc(item)
	-- Lines 1111-1124
	local function f(res)
		if res == "JOINED_LOBBY" then
			self:on_enter_lobby()
		elseif res == "JOINED_GAME" then
			local level_id = tweak_data.levels:get_level_name_from_world_name(item:parameters().level_name)

			managers.network:session():load_level(item:parameters().level_name, nil, nil, nil, level_id, nil)
		elseif res == "KICKED" then
			managers.menu:show_peer_kicked_dialog()
		else
			Application:error("[MenuCallbackHandler:connect_to_host_rpc] FAILED TO START MULTIPLAYER!")
		end
	end

	managers.network:join_game_at_host_rpc(item:parameters().rpc, f)
end

-- Lines 1129-1146
function MenuCallbackHandler:host_multiplayer(item)
	managers.network:host_game()

	local level_id = item:parameters().level_id
	local level_name = level_id and tweak_data.levels[level_id].world_name
	level_id = level_id or tweak_data.levels:get_level_name_from_world_name(item:parameters().level)
	level_name = level_name or item:parameters().level or "bank"
	Global.game_settings.level_id = level_id

	managers.network:session():load_level(level_name, nil, nil, nil, level_id)
end

-- Lines 1148-1160
function MenuCallbackHandler:join_multiplayer()
	-- Lines 1149-1158
	local function f(new_host_rpc)
		if new_host_rpc then
			managers.menu:active_menu().logic:refresh_node("select_host")
		end
	end

	managers.network:discover_hosts(f)
end

-- Lines 1162-1171
function MenuCallbackHandler:find_lan_games()
	if self:is_win32() then
		-- Lines 1164-1168
		local function f(new_host_rpc)
			if new_host_rpc then
				managers.menu:active_menu().logic:refresh_node("play_lan")
			end
		end

		managers.network:discover_hosts(f)
	end
end

-- Lines 1173-1175
function MenuCallbackHandler:find_online_games_with_friends()
	self:_find_online_games(true)
end

-- Lines 1177-1179
function MenuCallbackHandler:find_online_games()
	self:_find_online_games()
end

-- Lines 1181-1239
function MenuCallbackHandler:_find_online_games(friends_only)
	if self:is_win32() then
		-- Lines 1183-1188
		local function f(info)
			print("info in function")
			print(inspect(info))
			managers.network.matchmake:search_lobby_done()
			managers.menu:active_menu().logic:refresh_node("play_online", true, info, friends_only)
		end

		managers.network.matchmake:register_callback("search_lobby", f)
		managers.network.matchmake:search_lobby(friends_only)

		-- Lines 1194-1205
		local function usrs_f(success, amount)
			print("usrs_f", success, amount)

			if success then
				local stack = managers.menu:active_menu().renderer._node_gui_stack
				local node_gui = stack[#stack]

				if node_gui.set_mini_info then
					node_gui:set_mini_info(managers.localization:text("menu_players_online", {
						COUNT = amount
					}))
				end
			end
		end

		Steam:sa_handler():concurrent_users_callback(usrs_f)
		Steam:sa_handler():get_concurrent_users()
	end

	if self:is_ps3() or self:is_ps4() then
		if #PSN:get_world_list() == 0 then
			return
		end

		-- Lines 1218-1223
		local function f(info_list)
			print("info_list in function")
			print(inspect(info_list))
			managers.network.matchmake:search_lobby_done()
			managers.menu:active_menu().logic:refresh_node("play_online", true, info_list, friends_only)
		end

		managers.network.matchmake:register_callback("search_lobby", f)
		managers.network.matchmake:start_search_lobbys(friends_only)
	end
end

-- Lines 1242-1246
function MenuCallbackHandler:connect_to_lobby(item)
	managers.network.matchmake:join_server_with_check(item:parameters().room_id)
end

-- Lines 1248-1257
function MenuCallbackHandler:stop_multiplayer()
	Global.game_settings.single_player = false

	if managers.network:session() and managers.network:session():local_peer():id() == 1 then
		managers.network:stop_network(true)
	end
end

-- Lines 1259-1262
function MenuCallbackHandler:find_friends()
end

-- Lines 1264-1274
function MenuCallbackHandler:invite_friends()
	if managers.network.matchmake.lobby_handler then
		if MenuCallbackHandler:is_overlay_enabled() then
			Steam:overlay_activate("invite", managers.network.matchmake.lobby_handler:id())
		else
			managers.menu:show_enable_steam_overlay()
		end
	end
end

-- Lines 1276-1283
function MenuCallbackHandler:invite_friend(item)
	if item:parameters().signin_status ~= "signed_in" then
		return
	end

	managers.network.matchmake:send_join_invite(item:parameters().friend)
end

-- Lines 1296-1299
function MenuCallbackHandler:invite_friends_X360()
	local platform_id = managers.user:get_platform_id()

	XboxLive:show_friends_ui(platform_id)
end

-- Lines 1301-1304
function MenuCallbackHandler:invite_friends_XB1()
	local platform_id = managers.user:get_platform_id()

	XboxLive:invite_friends_ui(platform_id, managers.network.matchmake._session)
end

-- Lines 1307-1310
function MenuCallbackHandler:invite_xbox_live_party()
	local platform_id = managers.user:get_platform_id()

	XboxLive:show_party_ui(platform_id)
end

-- Lines 1312-1315
function MenuCallbackHandler:invite_friends_ps4()
	PSN:invite_friends()
end

-- Lines 1317-1322
function MenuCallbackHandler:view_invites()
	print("View invites")
	print(PSN:display_message_invitation())
end

-- Lines 1324-1334
function MenuCallbackHandler:kick_player(item)
	if managers.vote:is_restarting() then
		Application:debug("[MenuCallbackHandler:kick_player] No kick during restart.")

		return
	end

	if managers.vote:option_host_kick() then
		managers.vote:message_host_kick(item:parameters().peer)
	elseif managers.vote:option_vote_kick() then
		managers.vote:kick(item:parameters().peer:id())
	end
end

-- Lines 1336-1341
function MenuCallbackHandler:mute_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:mute_player(item:parameters().peer, item:value() == "on")
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1343-1348
function MenuCallbackHandler:mute_xbox_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:set_muted(item:parameters().xuid, item:value() == "on")
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1350-1355
function MenuCallbackHandler:mute_xb1_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:set_muted(item:parameters().xuid, item:value() == "on")
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1357-1362
function MenuCallbackHandler:mute_ps4_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:mute_player(item:value() == "on", item:parameters().peer)
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1364-1390
function MenuCallbackHandler:restart_mission(item)
	if not managers.vote:available() or managers.vote:is_restarting() then
		return
	end

	local dialog_data = {
		title = managers.localization:text("dialog_mp_restart_mission_title"),
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

-- Lines 1392-1394
function MenuCallbackHandler:view_gamer_card(item)
	XboxLive:show_gamer_card_ui(managers.user:get_platform_id(), item:parameters().xuid)
end

-- Lines 1396-1398
function MenuCallbackHandler:save_settings()
	managers.savefile:save_setting(true)
end

-- Lines 1400-1402
function MenuCallbackHandler:save_progress()
	managers.savefile:save_progress()
end

-- Lines 1404-1409
function MenuCallbackHandler:debug_level_jump(item)
	local param_map = item:parameters()

	managers.network:host_game()

	local level_id = tweak_data.levels:get_level_name_from_world_name(param_map.level)

	managers.network:session():load_level(param_map.level, param_map.mission, param_map.world_setting, param_map.level_class_name, level_id, nil)
end

-- Lines 1411-1422
function MenuCallbackHandler:save_game(item)
	if not managers.savefile:is_active() then
		local param_map = item:parameters()

		managers.savefile:save_game(param_map.slot, false)

		if managers.savefile:is_active() then
			managers.menu:set_save_game_callback(callback(self, self, "save_game_callback"))
		else
			self:save_game_callback()
		end
	end
end

-- Lines 1424-1427
function MenuCallbackHandler:save_game_callback()
	managers.menu:set_save_game_callback(nil)
	managers.menu:back()
end

-- Lines 1429-1443
function MenuCallbackHandler:start_the_game()
	managers.worldcollection.level_transition_in_progress = true
	local level_id = Global.game_settings.level_id
	local level_name = level_id and tweak_data.levels[level_id].world_name

	if Global.boot_invite then
		Global.boot_invite.used = true
		Global.boot_invite.pending = false
	end

	local mission = Global.game_settings.mission ~= "none" and Global.game_settings.mission or nil
	local world_setting = Global.game_settings.world_setting

	managers.network:session():load_level(level_name, mission, world_setting, nil, level_id)
end

-- Lines 1445-1449
function MenuCallbackHandler:singleplayer_restart_game_to_camp(item)
	managers.menu:show_restart_game_dialog({
		yes_func = function ()
			managers.game_play_central:restart_the_game()
		end
	})
end

-- Lines 1451-1455
function MenuCallbackHandler:singleplayer_restart_mission(item)
	managers.menu:show_restart_game_dialog({
		yes_func = function ()
			managers.game_play_central:restart_the_game()
		end
	})
end

-- Lines 1457-1459
function MenuCallbackHandler:always_hide()
	return false
end

-- Lines 1461-1472
function MenuCallbackHandler:set_music_volume(item)
	local volume = item:value()
	local old_volume = managers.user:get_setting("music_volume")

	managers.user:set_setting("music_volume", volume)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

-- Lines 1474-1485
function MenuCallbackHandler:set_sfx_volume(item)
	local volume = item:value()
	local old_volume = managers.user:get_setting("sfx_volume")

	managers.user:set_setting("sfx_volume", volume)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

-- Lines 1487-1498
function MenuCallbackHandler:set_voice_volume(item)
	local volume = item:value()
	local old_volume = managers.user:get_setting("voice_volume")

	managers.user:set_setting("voice_volume", volume)

	if old_volume < volume then
		self._sound_source:post_event("slider_increase")
	elseif volume < old_volume then
		self._sound_source:post_event("slider_decrease")
	end
end

-- Lines 1500-1503
function MenuCallbackHandler:_refresh_brightness()
	managers.user:set_setting("brightness", managers.user:get_setting("brightness"), true)
end

-- Lines 1505-1508
function MenuCallbackHandler:set_brightness(item)
	local brightness = item:value()

	managers.user:set_setting("brightness", brightness)
end

-- Lines 1510-1514
function MenuCallbackHandler:set_effect_quality(item)
	local effect_quality = item:value()

	managers.user:set_setting("effect_quality", effect_quality)
end

-- Lines 1516-1527
function MenuCallbackHandler:set_camera_sensitivity(item)
	local value = item:value()

	managers.user:set_setting("camera_sensitivity", value)

	if not managers.user:get_setting("enable_camera_zoom_sensitivity") then
		local item_other_sens = managers.menu:active_menu().logic:selected_node():item("camera_zoom_sensitivity")

		if item_other_sens and item_other_sens:visible() and math.abs(value - item_other_sens:value()) > 0.001 then
			item_other_sens:set_value(value)
			item_other_sens:trigger()
		end
	end
end

-- Lines 1529-1540
function MenuCallbackHandler:set_camera_zoom_sensitivity(item)
	local value = item:value()

	managers.user:set_setting("camera_zoom_sensitivity", value)

	if not managers.user:get_setting("enable_camera_zoom_sensitivity") then
		local item_other_sens = managers.menu:active_menu().logic:selected_node():item("camera_sensitivity")

		if item_other_sens and item_other_sens:visible() and math.abs(value - item_other_sens:value()) > 0.001 then
			item_other_sens:set_value(value)
			item_other_sens:trigger()
		end
	end
end

-- Lines 1542-1552
function MenuCallbackHandler:toggle_zoom_sensitivity(item)
	local value = item:value() == "on"

	managers.user:set_setting("enable_camera_zoom_sensitivity", value)

	if value == false then
		local item_sens = managers.menu:active_menu().logic:selected_node():item("camera_sensitivity")
		local item_sens_zoom = managers.menu:active_menu().logic:selected_node():item("camera_zoom_sensitivity")

		item_sens_zoom:set_value(item_sens:value())
		item_sens_zoom:trigger()
	end
end

-- Lines 1554-1556
function MenuCallbackHandler:is_current_resolution(item)
	return item:name() == string.format("%d x %d, %dHz", RenderSettings.resolution.x, RenderSettings.resolution.y, RenderSettings.resolution.z)
end

-- Lines 1559-1576
function MenuCallbackHandler:end_game()
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

-- Lines 1578-1607
function MenuCallbackHandler:_dialog_end_game_yes()
	managers.platform:set_playing(false)
	managers.statistics:stop_session({
		quit = true
	})
	managers.savefile:save_setting(true)
	managers.raid_job:deactivate_current_job()
	managers.raid_job:cleanup()
	managers.lootdrop:reset_loot_value_counters()
	managers.consumable_missions:on_level_exited(false)
	managers.greed:on_level_exited(false)
	managers.worldcollection:on_simulation_ended()

	if Network:multiplayer() then
		Network:set_multiplayer(false)
		managers.network:session():send_to_peers("set_peer_left")
		managers.network:queue_stop_network()
	end

	managers.network.matchmake:destroy_game()
	managers.network.voice_chat:destroy_voice()

	if managers.groupai then
		managers.groupai:state():set_AI_enabled(false)
	end

	managers.menu:post_event("menu_exit")
	managers.menu:close_menu("menu_pause")
	setup:load_start_menu()
end

-- Lines 1609-1614
function MenuCallbackHandler:leave_safehouse()
	-- Lines 1610-1612
	local function yes_func()
		self:_dialog_end_game_yes()
	end

	managers.menu:show_leave_safehouse_dialog({
		yes_func = yes_func
	})
end

-- Lines 1616-1627
function MenuCallbackHandler:abort_mission()
	if game_state_machine:current_state_name() == "disconnected" then
		return
	end

	-- Lines 1621-1625
	local function yes_func()
		if game_state_machine:current_state_name() ~= "disconnected" then
			self:load_start_menu_lobby()
		end
	end

	managers.menu:show_abort_mission_dialog({
		yes_func = yes_func
	})
end

-- Lines 1629-1653
function MenuCallbackHandler:load_start_menu_lobby()
	managers.network:session():load_lobby()
end

-- Lines 1655-1656
function MenuCallbackHandler:_dialog_end_game_no()
end

-- Lines 1658-1661
function MenuCallbackHandler:_reset_mainmusic()
	managers.music:post_event(MusicManager.STOP_ALL_MUSIC)
	managers.music:post_event(MusicManager.MENU_MUSIC)
end

-- Lines 1663-1677
function MenuCallbackHandler:show_steam_controller_binding_panel()
	if MenuCallbackHandler:is_not_steam_controller() then
		return
	end

	local controller = managers.controller:get_default_controller()

	if controller then
		if controller:show_binding_panel() then
			-- Nothing
		elseif MenuCallbackHandler:is_overlay_enabled() then
			managers.menu:show_requires_big_picture()
		else
			managers.menu:show_enable_steam_overlay()
		end
	end
end

-- Lines 1679-1689
function MenuCallbackHandler:set_default_options()
	local params = {
		text = managers.localization:text("dialog_default_options_message"),
		callback = function ()
			managers.user:reset_setting_map()
			self:_reset_mainmusic()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1691-1697
function MenuCallbackHandler:set_default_control_options()
	local params = {
		text = managers.localization:text("dialog_default_controls_options_message"),
		callback = function ()
			managers.user:reset_controls_setting_map()
			self:refresh_node()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1699-1705
function MenuCallbackHandler:set_default_video_options()
	local params = {
		text = managers.localization:text("dialog_default_video_options_message"),
		callback = function ()
			managers.user:reset_video_setting_map()
			self:refresh_node()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1707-1713
function MenuCallbackHandler:set_default_sound_options()
	local params = {
		text = managers.localization:text("dialog_default_sound_options_message"),
		callback = function ()
			managers.user:reset_sound_setting_map()
			self:refresh_node()
			self:_reset_mainmusic()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1715-1721
function MenuCallbackHandler:set_default_network_options()
	local params = {
		text = managers.localization:text("dialog_default_network_options_message"),
		callback = function ()
			managers.user:reset_network_setting_map()
			self:refresh_node()
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1723-1725
function MenuCallbackHandler:resume_game()
	managers.menu:close_menu("menu_pause")
end

-- Lines 1727-1728
function MenuCallbackHandler:change_upgrade(menu_item)
end

-- Lines 1730-1738
function MenuCallbackHandler:delayed_open_savefile_menu(item)
	if not self._delayed_open_savefile_menu_callback then
		if managers.savefile:is_active() then
			managers.menu:set_delayed_open_savefile_menu_callback(callback(self, self, "open_savefile_menu", item))
		else
			self:open_savefile_menu(item)
		end
	end
end

-- Lines 1740-1745
function MenuCallbackHandler:open_savefile_menu(item)
	managers.menu:set_delayed_open_savefile_menu_callback(nil)

	local parameter_map = item:parameters()

	managers.menu:open_node(parameter_map.delayed_node, {
		parameter_map
	})
end

-- Lines 1747-1749
function MenuCallbackHandler:hide_huds()
	managers.hud:set_disabled()
end

-- Lines 1751-1757
function MenuCallbackHandler:toggle_hide_huds(item)
	if item:value() == "on" then
		managers.hud:set_disabled()
	else
		managers.hud:set_enabled()
	end
end

-- Lines 1759-1761
function MenuCallbackHandler:toggle_mission_fading_debug_enabled(item)
	managers.mission:set_fading_debug_enabled(item:value() == "off")
end

-- Lines 1763-1765
function MenuCallbackHandler:menu_back()
	managers.menu:back()
end

-- Lines 1767-1783
function MenuCallbackHandler:set_default_controller(item)
	local params = {
		text = managers.localization:text("dialog_use_default_keys_message"),
		callback = function ()
			managers.controller:load_settings("settings/controller_settings")
			managers.controller:clear_user_mod(item:parameters().category, MenuCustomizeControllerCreator.CONTROLS_INFO)

			local logic = managers.menu:active_menu().logic

			if logic then
				logic:refresh_node()
			end
		end
	}

	managers.menu:show_default_option_dialog(params)
end

-- Lines 1785-1788
function MenuCallbackHandler:choice_button_layout_category(item)
	local node_gui = managers.menu:active_menu().renderer:active_node_gui()

	node_gui:set_current_category(item:value())
end

-- Lines 1790-1813
function MenuCallbackHandler:debug_goto_custody()
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	if managers.player:current_state() ~= "bleed_out" then
		managers.player:set_player_state("bleed_out")
	end

	if managers.player:current_state() ~= "fatal" then
		managers.player:set_player_state("fatal")
	end

	managers.player:force_drop_carry()
	managers.statistics:downed({
		death = true
	})
	IngameFatalState.on_local_player_dead()
	game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
	player:character_damage():set_invulnerable(true)
	player:character_damage():set_health(0)
	player:base():_unregister()
	player:base():set_slot(player, 0)
end

-- Lines 1816-1827
function MenuCallbackHandler:toggle_visual_upgrade(item)
	managers.upgrades:toggle_visual_weapon_upgrade(item:parameters().upgrade_id)
	managers.upgrades:setup_current_weapon()

	if managers.upgrades:visual_weapon_upgrade_active(item:parameters().upgrade_id) then
		self._sound_source:post_event("box_tick")
	else
		self._sound_source:post_event("box_untick")
	end

	print("Toggled", item:parameters().upgrade_id)
end

-- Lines 1830-1847
function MenuCallbackHandler:set_contact_info(item)
	local parameters = item:parameters() or {}
	local id = parameters.name
	local name_id = parameters.text_id
	local files = parameters.files
	local active_node_gui = managers.menu:active_menu().renderer:active_node_gui()

	if active_node_gui and active_node_gui.set_contact_info and active_node_gui:get_contact_info() ~= item:name() then
		active_node_gui:set_contact_info(id, name_id, files, 1)
	end

	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
	end
end

-- Lines 1849-1856
function MenuCallbackHandler:is_current_contact_info(item)
	local active_node_gui = managers.menu:active_menu().renderer:active_node_gui()

	if active_node_gui and active_node_gui.get_contact_info then
		return active_node_gui:get_contact_info() == item:name()
	end

	return false
end

-- Lines 1860-1878
function MenuCallbackHandler:is_reticle_applicable(node)
	local type = node:item("reticle_type"):value()
	local color = node:item("reticle_color"):value()
	local type_data = tweak_data:get_raw_value("gui", "weapon_texture_switches", "types", "sight", type)
	local color_data = tweak_data:get_raw_value("gui", "weapon_texture_switches", "color_indexes", color)

	if Application:production_build() then
		assert(type_data, "Missing sight type in tweak data", type)
		assert(color_data, "Missing sight color in tweak data", color)
	end

	local type_dlc = type_data and type_data.dlc or false
	local color_dlc = color_data and color_data.dlc or false
	local pass_type = not type_dlc or managers.dlc:is_dlc_unlocked(type_dlc)
	local pass_color = not color_dlc or managers.dlc:is_dlc_unlocked(color_dlc)

	return pass_type and pass_color
end

-- Lines 1880-1912
function MenuCallbackHandler:update_weapon_texture_switch(item)
	if not managers.menu:active_menu() then
		return false
	end

	if not managers.menu:active_menu().logic then
		return false
	end

	if not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	local node = managers.menu:active_menu().logic:selected_node()
	local color = node:item("reticle_color"):value()
	local type = node:item("reticle_type"):value()
	local data = node:parameters().menu_component_data
	local part_id = data.name
	local data_string = tostring(color) .. " " .. tostring(type)
	local texture = managers.blackmarket:get_texture_switch_from_data(data_string, part_id)
	local active_node_gui = managers.menu:active_menu().renderer:active_node_gui()

	if active_node_gui and active_node_gui.set_reticle_texture and texture and active_node_gui:get_recticle_texture_ids() ~= Idstring(texture) then
		active_node_gui:set_reticle_texture(texture)
	end

	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
	end
end

-- Lines 1914-1916
function MenuCallbackHandler:casino_betting_visible()
	return true
end

-- Lines 1919-1951
function MenuCallbackHandler:unlock_skill_switch(item)
	local spending_cost = managers.money:get_unlock_skill_switch_spending_cost(item:parameters().name)
	local offshore_cost = managers.money:get_unlock_skill_switch_offshore_cost(item:parameters().name)
	local dialog_data = {
		title = managers.localization:text("dialog_unlock_skill_switch_title")
	}
	local cost_text = ""

	if spending_cost ~= 0 and offshore_cost ~= 0 then
		cost_text = managers.localization:text("dialog_unlock_skill_switch_spending_offshore", {
			spending = managers.experience:cash_string(spending_cost),
			offshore = managers.experience:cash_string(offshore_cost)
		})
	elseif spending_cost ~= 0 then
		cost_text = managers.localization:text("dialog_unlock_skill_switch_spending", {
			spending = managers.experience:cash_string(spending_cost)
		})
	elseif offshore_cost ~= 0 then
		cost_text = managers.localization:text("dialog_unlock_skill_switch_offshore", {
			offshore = managers.experience:cash_string(offshore_cost)
		})
	else
		cost_text = managers.localization:text("dialog_unlock_skill_switch_free")
	end

	dialog_data.text = managers.localization:text("dialog_unlock_skill_switch", {
		cost_text = cost_text
	})
	local yes_button = {
		text = managers.localization:text("dialog_yes"),
		callback_func = function ()
			managers.skilltree:on_skill_switch_unlocked(item:parameters().name)
			self:refresh_node()
		end
	}
	local no_button = {
		text = managers.localization:text("dialog_no"),
		class = RaidGUIControlButtonShortSecondary,
		callback_func = function ()
			self:refresh_node()
		end,
		cancel_button = true
	}
	dialog_data.button_list = {
		yes_button,
		no_button
	}

	managers.system_menu:show(dialog_data)
end

-- Lines 1953-1956
function MenuCallbackHandler:set_active_skill_switch(item)
	managers.skilltree:switch_skills(item:parameters().name)
	self:refresh_node()
end

-- Lines 1961-1963
function MenuCallbackHandler:has_installed_mods()
	return not self:is_console() and table.size(DB:mods()) > 0
end

-- Lines 1965-1967
function MenuCallbackHandler:save_mod_changes(node)
end

-- Lines 1969-1975
function MenuCallbackHandler:mod_option_toggle_enabled(item)
	print("mod_option_toggle_enabled", "mod", item:name(), "status", item:value())

	local enabled = item:value() == "on"

	DB:set_mod_enabled(item:name(), enabled)
end

-- Lines 1978-1985
function MenuCallbackHandler:is_current_challenge(item)
	return false
end

-- Lines 1987-1999
function MenuCallbackHandler:update_challenge_menu_node()
	if not managers.menu:active_menu() then
		return false
	end

	if not managers.menu:active_menu().logic then
		return false
	end

	if not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	MenuCallbackHandler:refresh_node()
end

-- Lines 2001-2025
function MenuCallbackHandler:give_challenge_reward(item)
	return false
end

-- Lines 2027-2048
function MenuCallbackHandler:choice_challenge_choose_weapon_category(item)
	if not managers.menu:active_menu() then
		return false
	end

	if not managers.menu:active_menu().logic then
		return false
	end

	if not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	local node = managers.menu:active_menu().logic:selected_node()
	node:parameters().listed_category = string.gsub(item:value(), "#", "")

	if string.find(item:value(), "#") then
		item:set_value(string.gsub(item:value(), "#", ""))
	end

	node:parameters().clicked_category = true
	node:parameters().listed_weapon = node:parameters().first_weapons[item:value()]

	MenuCallbackHandler:refresh_node()
end

-- Lines 2050-2069
function MenuCallbackHandler:choice_challenge_choose_weapon(item)
	if not managers.menu:active_menu() then
		return false
	end

	if not managers.menu:active_menu().logic then
		return false
	end

	if not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	if managers.menu:active_menu().logic:selected_node():parameters().clicked_category then
		return false
	end

	managers.menu:active_menu().logic:selected_node():parameters().listed_weapon = string.gsub(item:value(), "#", "")

	if string.find(item:value(), "#") then
		item:set_value(string.gsub(item:value(), "#", ""))
	end

	MenuCallbackHandler:refresh_node()
end

-- Lines 2071-2091
function MenuCallbackHandler:choice_challenge_choose_global_value(item)
	if not managers.menu:active_menu() then
		return false
	end

	if not managers.menu:active_menu().logic then
		return false
	end

	if not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	if managers.menu:active_menu().logic:selected_node():parameters().clicked_category then
		return false
	end

	managers.menu:active_menu().logic:selected_node():parameters().listed_global_value = string.gsub(item:value(), "#", "")

	if string.find(item:value(), "#") then
		item:set_value(string.gsub(item:value(), "#", ""))
	end

	MenuCallbackHandler:refresh_node()
end

-- Lines 2093-2096
function MenuCallbackHandler:continue_to_lobby()
end

-- Lines 2098-2103
function MenuCallbackHandler:on_view_character_focus(node, in_focus, data)
	if not in_focus or not data then
		managers.menu_component:close_view_character_profile_gui()
	end
end

-- Lines 2105-2108
function MenuCallbackHandler:on_character_customization()
	managers.menu_component:close_weapon_box()
end

-- Lines 2110-2158
function MenuCallbackHandler:start_job(job_data)
	local raid_data = tweak_data.operations:mission_data(job_data.job_id)
	Global.game_settings.level_id = raid_data.level_id or job_data.job_id
	Global.game_settings.mission = "none"
	Global.game_settings.world_setting = nil

	tweak_data:set_difficulty(job_data.difficulty)

	local matchmake_attributes = managers.network:get_matchmake_attributes()

	if Network:is_server() then
		local job_id_index = tweak_data.operations:get_index_from_raid_id(managers.raid_job:current_job_id())
		local level_id_index = tweak_data.levels:get_index_from_level_id(Global.game_settings.level_id)
		local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

		managers.network:session():send_to_peers("sync_game_settings", job_id_index, level_id_index, difficulty_index)
		managers.network.matchmake:set_server_attributes(matchmake_attributes)
		managers.menu_component:on_job_updated()
		managers.menu:active_menu().logic:navigate_back(true)
		managers.menu:active_menu().logic:refresh_node("lobby", true)
	else
		managers.network.matchmake:create_lobby(matchmake_attributes)
	end

	if job_data.job_id == OperationsTweakData.ENTRY_POINT_LEVEL then
		local mission = nil

		if managers.raid_job:played_tutorial() then
			mission = tweak_data.operations:mission_data(RaidJobManager.CAMP_ID)
		else
			mission = tweak_data.operations:mission_data(RaidJobManager.TUTORIAL_ID)
		end

		local data = {
			background = mission.loading.image,
			loading_text = mission.loading.text,
			mission = mission
		}

		managers.menu:show_loading_screen(data)
	end

	managers.raid_job:on_mission_started()
end

-- Lines 2160-2164
function MenuCallbackHandler:play_single_player_job(item)
	self:play_single_player()
	self:start_single_player_job({
		job_id = item:parameter("job_id"),
		difficulty = Global.DEFAULT_DIFFICULTY
	})
end

-- Lines 2166-2168
function MenuCallbackHandler:play_quick_start_job(item)
	self:start_job({
		job_id = item:parameter("job_id"),
		difficulty = Global.DEFAULT_DIFFICULTY
	})
end

-- Lines 2170-2180
function MenuCallbackHandler:start_single_player_job(job_data)
	local raid_data = tweak_data.operations:mission_data(job_data.job_id)
	Global.game_settings.level_id = raid_data.level_id
	Global.game_settings.mission = "none"
	Global.game_settings.world_setting = nil

	tweak_data:set_difficulty(job_data.difficulty)
	MenuCallbackHandler:start_the_game()
	managers.raid_job:on_mission_started()
end

-- Lines 2182-2184
function MenuCallbackHandler:can_buy_weapon(item)
	return not Global.blackmarket_manager.weapons[item:parameter("weapon_id")].owned
end

-- Lines 2186-2189
function MenuCallbackHandler:owns_weapon(item)
	return not self:can_buy_weapon(item)
end

-- Lines 2191-2193
function MenuCallbackHandler:open_blackmarket_node()
	managers.menu:active_menu().logic:select_node("blackmarket")
end

-- Lines 2195-2199
function MenuCallbackHandler:leave_blackmarket(...)
	managers.menu_component:close_weapon_box()
	managers.blackmarket:release_preloaded_blueprints()
end

-- Lines 2201-2202
function MenuCallbackHandler:_left_blackmarket()
end

-- Lines 2204-2206
function MenuCallbackHandler:blackmarket_abort_customize_mask()
	managers.blackmarket:abort_customize_mask()
end

-- Lines 2208-2210
function MenuCallbackHandler:got_skillpoint_to_spend()
	return false
end

-- Lines 2212-2214
function MenuCallbackHandler:got_new_content_update()
	return false
end

-- Lines 2216-2218
function MenuCallbackHandler:got_new_fav_videos()
	return false
end

-- Lines 2220-2222
function MenuCallbackHandler:not_got_new_content_update()
	return not self:got_new_content_update()
end

-- Lines 2224-2225
function MenuCallbackHandler:do_content_lootdrop(node)
end

-- Lines 2227-2232
function MenuCallbackHandler:buy_weapon(item)
	local name = managers.localization:text(tweak_data.weapon[item:parameter("weapon_id")].name_id)
	local cost = 50000
	local yes_func = callback(self, self, "on_buy_weapon_yes", {
		item = item,
		cost = cost
	})

	managers.menu:show_buy_weapon({
		yes_func = yes_func
	}, name, "$" .. cost)
end

-- Lines 2234-2240
function MenuCallbackHandler:on_buy_weapon_yes(params)
	Global.blackmarket_manager.weapons[params.item:parameter("weapon_id")].owned = true
	params.item:parameter("parent_item"):parameters().owned = true

	params.item:dirty()
	params.item:parameters().parent_item:on_buy(params.item:parameters().gui_node)
end

-- Lines 2242-2250
function MenuCallbackHandler:equip_weapon(item)
	Global.player_manager.kit.weapon_slots[item:parameter("weapon_slot")] = item:parameter("weapon_id")

	for weapon_id, data in pairs(Global.blackmarket_manager.weapons) do
		if data.selection_index == item:parameter("weapon_slot") then
			data.equipped = weapon_id == item:parameter("weapon_id")
		end
	end
end

-- Lines 2252-2261
function MenuCallbackHandler:repair_weapon(item)
	if item:_at_max_condition() then
		return
	end

	local name = managers.localization:text(tweak_data.weapon[item:parameter("weapon_id")].name_id)
	local cost = 50000 * (1 - item:parameter("parent_item"):condition() / item:_max_condition())
	local yes_func = callback(self, self, "on_repair_yes", {
		item = item,
		cost = cost
	})

	managers.menu:show_repair_weapon({
		yes_func = yes_func
	}, name, "$" .. cost)
end

-- Lines 2263-2268
function MenuCallbackHandler:on_repair_yes(params)
	Global.blackmarket_manager.weapons[params.item:parameters().weapon_id].condition = params.item:_max_condition()

	params.item:dirty()
	self:test_clicked_weapon(params.item:parameters().parent_item)
end

-- Lines 2270-2271
function MenuCallbackHandler:clicked_weapon_upgrade_type(item)
end

-- Lines 2273-2274
function MenuCallbackHandler:clicked_weapon_upgrade(item)
end

-- Lines 2277-2279
function MenuCallbackHandler:can_buy_weapon_upgrade(item)
	return false
end

-- Lines 2282-2284
function MenuCallbackHandler:owns_weapon_upgrade(item)
	return true
end

-- Lines 2287-2288
function MenuCallbackHandler:buy_weapon_upgrades(item)
end

-- Lines 2291-2293
function MenuCallbackHandler:buy_weapon_upgrade(item)
	return
end

-- Lines 2296-2298
function MenuCallbackHandler:_on_buy_weapon_upgrade_yes(params)
	return
end

-- Lines 2301-2303
function MenuCallbackHandler:attach_weapon_upgrade(item)
	return
end

-- Lines 2306-2307
function MenuCallbackHandler:clicked_customize_character_category(item)
end

-- Lines 2309-2312
function MenuCallbackHandler:test_clicked_mask(item)
	managers.menu_component:close_weapon_box()
end

-- Lines 2314-2316
function MenuCallbackHandler:can_buy_mask(item)
	return not self:owns_mask(item)
end

-- Lines 2318-2320
function MenuCallbackHandler:owns_mask(item)
	return Global.blackmarket_manager.masks[item:parameter("mask_id")].owned
end

-- Lines 2322-2329
function MenuCallbackHandler:equip_mask(item)
	local mask_id = item:parameter("mask_id")

	managers.blackmarket:on_buy_mask(mask_id, "normal", 9)
	managers.blackmarket:equip_mask(9)
	self:_update_outfit_information()
end

-- Lines 2331-2349
function MenuCallbackHandler:_update_outfit_information()
	local outfit_string = managers.blackmarket:outfit_string()

	if self:is_win32() then
		Steam:set_rich_presence("outfit", outfit_string)
	end

	if managers.network:session() then
		local local_peer = managers.network:session():local_peer()
		local in_lobby = local_peer:in_lobby() and game_state_machine:current_state_name() ~= "ingame_lobby_menu"

		local_peer:set_outfit_string(outfit_string)

		local local_player = managers.player:local_player()

		if alive(local_player) and local_player:character_damage() then
			local_player:character_damage():update_armor_stored_health()
		end

		managers.network:session():check_send_outfit()
	end
end

-- Lines 2351-2357
function MenuCallbackHandler:buy_mask(item)
	local name = managers.localization:text(tweak_data.blackmarket.masks[item:parameter("mask_id")].name_id)
	local cost = 10000
	local yes_func = callback(self, self, "_on_buy_mask_yes", {
		item = item,
		cost = cost
	})

	managers.menu:show_buy_weapon({
		yes_func = yes_func
	}, name, "$" .. cost)
end

-- Lines 2359-2365
function MenuCallbackHandler:_on_buy_mask_yes(params)
	Global.blackmarket_manager.masks[params.item:parameter("mask_id")].owned = true
	params.item:parameter("parent_item"):parameters().owned = true

	params.item:dirty()
	params.item:parameters().parent_item:on_buy(params.item:parameters().gui_node)
end

-- Lines 2367-2369
function MenuCallbackHandler:leave_character_customization()
	self:leave_blackmarket()
end

-- Lines 2372-2374
function MenuCallbackHandler:clicked_character(item)
	print("MenuCallbackHandler:clicked_character", item)
end

-- Lines 2376-2387
function MenuCallbackHandler:equip_character(item)
	local character_id = item:parameter("character_id")
	Global.blackmarket_manager.characters[character_id].equipped = true

	for id, character in pairs(Global.blackmarket_manager.characters) do
		if id ~= character_id then
			character.equipped = false
		end
	end

	self:_update_outfit_information()
end

-- Lines 2389-2391
function MenuCallbackHandler:can_buy_character(item)
	return not self:owns_character(item)
end

-- Lines 2393-2395
function MenuCallbackHandler:owns_character(item)
	return Global.blackmarket_manager.characters[item:parameter("character_id")].owned
end

-- Lines 2397-2403
function MenuCallbackHandler:buy_character(item)
	local name = managers.localization:text(tweak_data.blackmarket.characters[item:parameter("character_id")].name_id)
	local cost = 10000
	local yes_func = callback(self, self, "_on_buy_character_yes", {
		item = item,
		cost = cost
	})

	managers.menu:show_buy_weapon({
		yes_func = yes_func
	}, name, "$" .. cost)
end

-- Lines 2405-2411
function MenuCallbackHandler:_on_buy_character_yes(params)
	Global.blackmarket_manager.characters[params.item:parameter("character_id")].owned = true
	params.item:parameter("parent_item"):parameters().owned = true

	params.item:dirty()
	params.item:parameters().parent_item:on_buy(params.item:parameters().gui_node)
end

-- Lines 2483-2488
function MenuCallbackHandler:stage_success()
	if not managers.raid_job:has_active_job() then
		return true
	end

	return managers.raid_job:stage_success()
end

-- Lines 2490-2492
function MenuCallbackHandler:stage_not_success()
	return not self:stage_success()
end

-- Lines 2494-2496
function MenuCallbackHandler:got_job()
	return managers.raid_job:has_active_job()
end

-- Lines 2498-2500
function MenuCallbackHandler:got_no_job()
	return not self:got_job()
end

-- Lines 2503-2504
function MenuCallbackHandler:start_safe_test_overkill()
end

-- Lines 2506-2507
function MenuCallbackHandler:start_safe_test_event_01()
end

-- Lines 2509-2510
function MenuCallbackHandler:start_safe_test_weapon_01()
end

-- Lines 2512-2517
function MenuCallbackHandler:reset_safe_scene()
	if not managers.menu:cash_safe_scene_done() then
		return true
	end

	managers.menu:set_cash_safe_scene_done(false)
end

-- Lines 2519-2521
function MenuCallbackHandler:is_cash_safe_back_visible()
	return managers.menu:cash_safe_scene_done()
end

-- Lines 2523-2525
function MenuCallbackHandler:on_visit_crimefest_challenges()
	Steam:overlay_activate("url", tweak_data.gui.crimefest_challenges_webpage)
end

-- Lines 2529-2530
function MenuCallbackHandler:leave_steam_inventory(item)
end

-- Lines 2534-2538
function MenuCallbackHandler:can_toggle_chat()
	local input = managers.menu:active_menu() and managers.menu:active_menu().input

	return not input or input.can_toggle_chat and input:can_toggle_chat()
end

-- Lines 2543-2549
function MenuCallbackHandler:on_visit_fbi_files()
	if MenuCallbackHandler:is_overlay_enabled() then
		Steam:overlay_activate("url", tweak_data.gui.fbi_files_webpage)
	else
		managers.menu:show_enable_steam_overlay()
	end
end

-- Lines 2551-2559
function MenuCallbackHandler:on_visit_fbi_files_suspect(item)
	if item then
		if MenuCallbackHandler:is_overlay_enabled() then
			Steam:overlay_activate("url", tweak_data.gui.fbi_files_webpage .. (item and "/suspect/" .. item:name() .. "/" or ""))
		else
			managers.menu:show_enable_steam_overlay()
		end
	end
end

-- Lines 2561-2566
function MenuCallbackHandler:on_steam_transaction_over(canceled)
	print("on_steam_transaction_over", canceled)
	managers.network.account:remove_overlay_listener("steam_transaction_tradable_item")
	managers.network.account:inventory_load()
	managers.system_menu:close("buy_tradable_item")
end

-- Lines 2568-2592
function MenuCallbackHandler:steam_open_container(item)
	if not managers.menu:active_menu() or not managers.menu:active_menu().logic:selected_node() then
		return false
	end

	local data = managers.menu:active_menu().logic:selected_node():parameters().container_data

	if not MenuCallbackHandler:have_safe_and_drill_for_container(data) then
		return
	end

	local safe_entry = data.safe

	-- Lines 2581-2587
	local function ready_clbk()
		print("ECONOMY SAFE READY CALLBACK")
		managers.menu:back()
		managers.system_menu:force_close_all()
		managers.menu_component:set_blackmarket_enabled(false)
		managers.menu:open_node("open_steam_safe", {
			data.content
		})
	end

	managers.menu_component:set_blackmarket_disable_fetching(true)
	managers.menu_component:set_blackmarket_enabled(false)
	managers.network.account:inventory_reward_unlock(data.safe, data.safe_id, data.drill_id, callback(MenuCallbackHandler, MenuCallbackHandler, "_safe_result_recieved"))
end

-- Lines 2594-2605
function MenuCallbackHandler:_safe_result_recieved(error, items_new, items_removed)
	local active_node_gui = managers.menu:active_menu().renderer:active_node_gui()

	managers.network.account:inventory_repair_list(items_new)
	managers.network.account:inventory_repair_list(items_removed)

	if active_node_gui and active_node_gui._safe_result_recieved then
		active_node_gui:_safe_result_recieved(error, items_new, items_removed)
	end
end
