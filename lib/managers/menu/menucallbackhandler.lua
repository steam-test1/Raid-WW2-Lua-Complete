MenuCallbackHandler = MenuCallbackHandler or class(CoreMenuCallbackHandler.CallbackHandler)

-- Lines 7-9
function MenuCallbackHandler:init()
	MenuCallbackHandler.super.init(self)
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
	return IS_PC and Steam:overlay_enabled() or false
end

-- Lines 50-61
function MenuCallbackHandler:_on_host_setting_updated()
end

-- Lines 65-89
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

-- Lines 91-93
function MenuCallbackHandler:not_has_all_dlcs()
	return not self:has_all_dlcs()
end

-- Lines 95-97
function MenuCallbackHandler:reputation_check(data)
	return data:value() <= managers.experience:current_level()
end

-- Lines 99-101
function MenuCallbackHandler:is_win32()
	return IS_PC
end

-- Lines 103-105
function MenuCallbackHandler:is_fullscreen()
	return managers.viewport:is_fullscreen()
end

-- Lines 107-109
function MenuCallbackHandler:voice_enabled()
	return IS_PC and managers.network and managers.network.voice_chat and managers.network.voice_chat:enabled()
end

-- Lines 111-113
function MenuCallbackHandler:customize_controller_enabled()
	return true
end

-- Lines 115-117
function MenuCallbackHandler:is_ps4()
	return IS_PS4
end

-- Lines 119-121
function MenuCallbackHandler:is_xb1()
	return IS_XB1
end

-- Lines 124-126
function MenuCallbackHandler:is_server()
	return Network:is_server()
end

-- Lines 128-130
function MenuCallbackHandler:is_not_server()
	return not self:is_server()
end

-- Lines 132-134
function MenuCallbackHandler:is_online()
	return managers.network.account:signin_state() == "signed in"
end

-- Lines 136-138
function MenuCallbackHandler:is_singleplayer()
	return Global.game_settings.single_player
end

-- Lines 140-142
function MenuCallbackHandler:is_multiplayer()
	return not Global.game_settings.single_player
end

-- Lines 144-146
function MenuCallbackHandler:is_not_max_rank()
	return managers.experience:current_rank() < #tweak_data.infamy.ranks
end

-- Lines 148-150
function MenuCallbackHandler:singleplayer_restart()
	return self:is_singleplayer() and self:has_full_game()
end

-- Lines 152-154
function MenuCallbackHandler:kick_player_visible()
	return self:is_server() and self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_host_kick()
end

-- Lines 156-158
function MenuCallbackHandler:kick_vote_visible()
	return self:is_multiplayer() and managers.platform:presence() ~= "Mission_end" and managers.vote:option_vote_kick()
end

-- Lines 160-167
function MenuCallbackHandler:_restart_level_visible()
	if not self:is_multiplayer() or managers.raid_job:is_camp_loaded() then
		return false
	end

	local state = game_state_machine:current_state_name()

	return state ~= "ingame_waiting_for_players" and state ~= "ingame_lobby_menu" and state ~= "empty"
end

-- Lines 169-171
function MenuCallbackHandler:restart_level_visible()
	return self:is_server() and self:_restart_level_visible() and managers.vote:option_host_restart()
end

-- Lines 173-175
function MenuCallbackHandler:restart_vote_visible()
	return self:_restart_level_visible() and managers.vote:option_vote_restart()
end

-- Lines 177-187
function MenuCallbackHandler:abort_mission_visible()
	if not self:is_not_editor() or not self:is_server() or not self:is_multiplayer() then
		return false
	end

	if game_state_machine:current_state_name() == "disconnected" then
		return false
	end

	return true
end

-- Lines 189-191
function MenuCallbackHandler:lobby_exist()
	return managers.network.matchmake.lobby_handler
end

-- Lines 193-195
function MenuCallbackHandler:hidden()
	return false
end

-- Lines 197-200
function MenuCallbackHandler:is_pc_controller()
	return managers.menu:is_pc_controller()
end

-- Lines 202-204
function MenuCallbackHandler:is_not_pc_controller()
	return not self:is_pc_controller()
end

-- Lines 206-208
function MenuCallbackHandler:is_not_editor()
	return not Application:editor()
end

-- Lines 210-212
function MenuCallbackHandler:show_credits()
	game_state_machine:change_state_by_name("menu_credits")
end

-- Lines 214-217
function MenuCallbackHandler:can_load_game()
	return not Application:editor() and not Network:multiplayer()
end

-- Lines 219-221
function MenuCallbackHandler:can_save_game()
	return not Application:editor() and not Network:multiplayer()
end

-- Lines 223-225
function MenuCallbackHandler:is_not_multiplayer()
	return not Network:multiplayer()
end

-- Lines 229-231
function MenuCallbackHandler:debug_menu_enabled()
	return managers.menu:debug_menu_enabled()
end

-- Lines 235-239
function MenuCallbackHandler:leave_online_menu()
	managers.menu:leave_online_menu()
end

-- Lines 241-248
function MenuCallbackHandler:on_account_picker()
	print("MenuCallbackHandler:on_account_picker()")

	-- Lines 243-246
	local function confirm_cb()
		-- Lines 244-244
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

-- Lines 250-253
function MenuCallbackHandler:on_menu_option_help()
	print("MenuCallbackHandler:on_menu_option_help()")
	XboxLive:show_help_ui()
end

-- Lines 255-272
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

-- Lines 274-276
function MenuCallbackHandler:_dialog_quit_yes()
	self:_dialog_save_progress_backup_no()
end

-- Lines 278-279
function MenuCallbackHandler:_dialog_quit_no()
end

-- Lines 281-285
function MenuCallbackHandler:_dialog_save_progress_backup_yes()
	setup:quit()
end

-- Lines 287-289
function MenuCallbackHandler:_dialog_save_progress_backup_no()
	setup:quit()
end

-- Lines 291-295
function MenuCallbackHandler:chk_dlc_content_updated()
	if managers.dlc then
		managers.dlc:chk_content_updated()
	end
end

-- Lines 298-315
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

-- Lines 317-322
function MenuCallbackHandler:change_nr_players(item)
	local nr_players = item:value()
	Global.nr_players = nr_players

	managers.player:set_nr_players(nr_players)
end

-- Lines 324-327
function MenuCallbackHandler:invert_camera_horisontally(item)
	local invert = item:value() == "on"

	managers.user:set_setting("invert_camera_x", invert)
end

-- Lines 329-332
function MenuCallbackHandler:invert_camera_vertically(item)
	local invert = item:value() == "on"

	managers.user:set_setting("invert_camera_y", invert)
end

-- Lines 334-337
function MenuCallbackHandler:toggle_dof_setting(item)
	local dof_setting = item:value() == "on"

	managers.user:set_setting("dof_setting", dof_setting and "standard" or "none")
end

-- Lines 339-342
function MenuCallbackHandler:toggle_ssao_setting(item)
	local ssao_setting = item:value() == "on"

	managers.user:set_setting("ssao_setting", ssao_setting and "standard" or "none")
end

-- Lines 344-347
function MenuCallbackHandler:toggle_motion_blur_setting(item)
	local motion_blur_setting = item:value() == "on"

	managers.user:set_setting("motion_blur_setting", motion_blur_setting and "standard" or "none")
end

-- Lines 349-352
function MenuCallbackHandler:toggle_volumetric_light_scattering_setting(item)
	local vls_setting = item:value() == "on"

	managers.user:set_setting("vls_setting", vls_setting and "standard" or "none")
end

-- Lines 354-357
function MenuCallbackHandler:choice_choose_AA_quality(item)
	local AA_setting = item:value()

	managers.user:set_setting("AA_setting", AA_setting)
end

-- Lines 359-362
function MenuCallbackHandler:choice_choose_cb_mode(item)
	local cb_setting = item:value()

	managers.user:set_setting("colorblind_setting", cb_setting)
end

-- Lines 364-367
function MenuCallbackHandler:hold_to_steelsight(item)
	local hold = item:value() == "on"

	managers.user:set_setting("hold_to_steelsight", hold)
end

-- Lines 369-372
function MenuCallbackHandler:hold_to_run(item)
	local hold = item:value() == "on"

	managers.user:set_setting("hold_to_run", hold)
end

-- Lines 374-377
function MenuCallbackHandler:hold_to_duck(item)
	local hold = item:value() == "on"

	managers.user:set_setting("hold_to_duck", hold)
end

-- Lines 379-394
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

-- Lines 396-399
function MenuCallbackHandler:toggle_subtitle(item)
	local subtitle = item:value() == "on"

	managers.user:set_setting("subtitle", subtitle)
end

-- Lines 402-405
function MenuCallbackHandler:choose_hit_indicator(item)
	local value = item:value()

	managers.user:set_setting("hit_indicator", value)
end

-- Lines 407-410
function MenuCallbackHandler:toggle_motion_dot(item)
	local on = item:value() == "on"

	managers.user:set_setting("motion_dot", on)
end

-- Lines 412-415
function MenuCallbackHandler:toggle_objective_reminder(item)
	local on = item:value() == "on"

	managers.user:set_setting("objective_reminder", on)
end

-- Lines 417-420
function MenuCallbackHandler:toggle_voicechat(item)
	local vchat = item:value() == "on"

	managers.user:set_setting("voice_chat", vchat)
end

-- Lines 422-425
function MenuCallbackHandler:toggle_push_to_talk(item)
	local vchat = item:value() == "on"

	managers.user:set_setting("push_to_talk", vchat)
end

-- Lines 428-431
function MenuCallbackHandler:toggle_team_AI(item)
	Global.game_settings.team_ai = item:value() == "on"

	managers.groupai:state():on_criminal_team_AI_enabled_state_changed()
end

-- Lines 433-441
function MenuCallbackHandler:toggle_coordinates(item)
	Global.debug_show_coords = item:value() == "on"

	if Global.debug_show_coords then
		managers.hud:debug_show_coordinates()
	else
		managers.hud:debug_hide_coordinates()
	end
end

-- Lines 443-446
function MenuCallbackHandler:toggle_net_throttling(item)
	local state = item:value() == "on"

	managers.user:set_setting("net_packet_throttling", state, nil)
end

-- Lines 448-451
function MenuCallbackHandler:toggle_net_forwarding(item)
	local state = item:value() == "on"

	managers.user:set_setting("net_forwarding", state, nil)
end

-- Lines 453-457
function MenuCallbackHandler:toggle_net_use_compression(item)
	local state = item:value() == "on"

	print("[MenuCallbackHandler:toggle_net_use_compression]", state)
	managers.user:set_setting("net_use_compression", state, nil)
end

-- Lines 459-475
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

-- Lines 477-494
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

-- Lines 496-500
function MenuCallbackHandler:choice_max_lobbies_filter(item)
	local max_server_jobs_filter = item:value()

	managers.network.matchmake:set_lobby_return_count(max_server_jobs_filter)
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 502-511
function MenuCallbackHandler:choice_distance_filter(item)
	local dist_filter = item:value()

	if managers.network.matchmake:distance_filter() == dist_filter then
		return
	end

	managers.network.matchmake:set_distance_filter(dist_filter)
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 513-527
function MenuCallbackHandler:choice_difficulty_filter(item)
	local diff_filter = item:value()

	print("diff_filter", diff_filter)

	if managers.network.matchmake:get_lobby_filter("difficulty") == diff_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("difficulty", diff_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 529-538
function MenuCallbackHandler:choice_job_id_filter(item)
	local job_id_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("job_id") == job_id_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("job_id", job_id_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 540-549
function MenuCallbackHandler:choice_new_servers_only(item)
	local num_players_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("num_players") == num_players_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("num_players", num_players_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 551-560
function MenuCallbackHandler:choice_kick_option(item)
	local kicking_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("kick_option") == kicking_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("kick_option", kicking_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 562-567
function MenuCallbackHandler:choice_job_appropriate_filter(item)
	local diff_appropriate = item:value()
	Global.game_settings.search_appropriate_jobs = diff_appropriate == "on" and true or false

	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 569-578
function MenuCallbackHandler:choice_server_state_lobby(item)
	local state_filter = item:value()

	if managers.network.matchmake:get_lobby_filter("state") == state_filter then
		return
	end

	managers.network.matchmake:add_lobby_filter("state", state_filter, "equal")
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

-- Lines 580-586
function MenuCallbackHandler:refresh_node(item)
	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
	end
end

-- Lines 589-597
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

-- Lines 600-621
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

-- Lines 623-625
function MenuCallbackHandler:set_lan_game()
	Global.game_settings.playing_lan = true
end

-- Lines 627-629
function MenuCallbackHandler:set_not_lan_game()
	Global.game_settings.playing_lan = nil
end

-- Lines 631-633
function MenuCallbackHandler:create_lobby()
	managers.network.matchmake:create_lobby(managers.network:get_matchmake_attributes())
end

-- Lines 637-642
function MenuCallbackHandler:play_single_player()
	Global.game_settings.single_player = true

	managers.network:host_game()
	Network:set_server()
end

-- Lines 644-647
function MenuCallbackHandler:play_online_game()
	Application:debug("[MenuCallbackHandler:play_online_game]")

	Global.game_settings.single_player = false
end

-- Lines 649-674
function MenuCallbackHandler:apply_and_save_render_settings()
	-- Lines 652-655
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

-- Lines 676-683
function MenuCallbackHandler:choice_choose_texture_quality(item)
	RenderSettings.texture_quality_default = item:value()

	if IS_PC then
		MenuCallbackHandler:apply_and_save_render_settings()
		self:_refresh_brightness()
	end
end

-- Lines 685-692
function MenuCallbackHandler:choice_choose_shadow_quality(item)
	RenderSettings.shadow_quality_default = item:value()

	if IS_PC then
		MenuCallbackHandler:apply_and_save_render_settings()
		self:_refresh_brightness()
	end
end

-- Lines 694-699
function MenuCallbackHandler:choice_choose_anisotropic(item)
	RenderSettings.max_anisotropy = item:value()

	MenuCallbackHandler:apply_and_save_render_settings()
	self:_refresh_brightness()
end

-- Lines 701-704
function MenuCallbackHandler:choice_fps_cap(item)
	setup:set_fps_cap(item:value())
	managers.user:set_setting("fps_cap", item:value())
end

-- Lines 706-708
function MenuCallbackHandler:choice_choose_color_grading(item)
	managers.user:set_setting("video_color_grading", item:value())
end

-- Lines 710-712
function MenuCallbackHandler:choice_choose_anti_alias(item)
	managers.user:set_setting("video_anti_alias", item:value())
end

-- Lines 714-716
function MenuCallbackHandler:choice_choose_anim_lod(item)
	managers.user:set_setting("video_animation_lod", item:value())
end

-- Lines 718-721
function MenuCallbackHandler:toggle_vsync(item)
	managers.viewport:set_vsync(item:value() == "on")
	self:_refresh_brightness()
end

-- Lines 724-726
function MenuCallbackHandler:toggle_use_thq_weapon_parts(item)
	managers.user:set_setting("use_thq_weapon_parts", item:value() == "on")
end

-- Lines 728-730
function MenuCallbackHandler:toggle_streaks(item)
	managers.user:set_setting("video_streaks", item:value() == "on")
end

-- Lines 732-734
function MenuCallbackHandler:toggle_light_adaption(item)
	managers.user:set_setting("light_adaption", item:value() == "on")
end

-- Lines 737-739
function MenuCallbackHandler:choice_max_streaming_chunk(item)
	managers.user:set_setting("max_streaming_chunk", item:value())
end

-- Lines 741-748
function MenuCallbackHandler:set_fov_multiplier(item)
	local fov_multiplier = item:value()

	managers.user:set_setting("fov_multiplier", fov_multiplier)

	if alive(managers.player:player_unit()) then
		managers.player:player_unit():movement():current_state():update_fov_external()
	end
end

-- Lines 750-753
function MenuCallbackHandler:set_detail_distance(item)
	debug_pause("[MenuCallbackHandler:set_detail_distance] DEPRECATED")
end

-- Lines 755-758
function MenuCallbackHandler:set_use_parallax(item)
	local use_parallax = item:value() == "on"

	managers.user:set_setting("use_parallax", use_parallax)
end

-- Lines 760-762
function MenuCallbackHandler:toggle_headbob(item)
	managers.user:set_setting("use_headbob", item:value() == "on")
end

-- Lines 764-766
function MenuCallbackHandler:on_stage_success()
	managers.mission:on_stage_success()
end

-- Lines 768-770
function MenuCallbackHandler:lobby_start_the_game()
	MenuCallbackHandler:start_the_game()
end

-- Lines 773-800
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

-- Lines 802-821
function MenuCallbackHandler:_dialog_leave_lobby_yes()
	if managers.network:session() then
		managers.network:session():local_peer():set_in_lobby(false)
		managers.network:session():send_to_peers("set_peer_left")
	end

	managers.menu:on_leave_lobby()
end

-- Lines 823-824
function MenuCallbackHandler:_dialog_leave_lobby_no()
end

-- Lines 829-846
function MenuCallbackHandler:connect_to_host_rpc(item)
	-- Lines 830-843
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

-- Lines 848-857
function MenuCallbackHandler:host_multiplayer(item)
	managers.network:host_game()

	local level_id = item:parameters().level_id
	local level_name = level_id and tweak_data.levels[level_id].world_name
	level_id = level_id or tweak_data.levels:get_level_name_from_world_name(item:parameters().level)
	level_name = level_name or item:parameters().level or "bank"
	Global.game_settings.level_id = level_id

	managers.network:session():load_level(level_name, nil, nil, nil, level_id)
end

-- Lines 859-866
function MenuCallbackHandler:join_multiplayer()
	-- Lines 860-864
	local function f(new_host_rpc)
		if new_host_rpc then
			managers.menu:active_menu().logic:refresh_node("select_host")
		end
	end

	managers.network:discover_hosts(f)
end

-- Lines 868-877
function MenuCallbackHandler:find_lan_games()
	if self:is_win32() then
		-- Lines 870-874
		local function f(new_host_rpc)
			if new_host_rpc then
				managers.menu:active_menu().logic:refresh_node("play_lan")
			end
		end

		managers.network:discover_hosts(f)
	end
end

-- Lines 879-881
function MenuCallbackHandler:find_online_games_with_friends()
	self:_find_online_games(true)
end

-- Lines 883-885
function MenuCallbackHandler:find_online_games()
	self:_find_online_games()
end

-- Lines 887-945
function MenuCallbackHandler:_find_online_games(friends_only)
	if self:is_win32() then
		-- Lines 889-894
		local function f(info)
			print("info in function")
			print(inspect(info))
			managers.network.matchmake:search_lobby_done()
			managers.menu:active_menu().logic:refresh_node("play_online", true, info, friends_only)
		end

		managers.network.matchmake:register_callback("search_lobby", f)
		managers.network.matchmake:search_lobby(friends_only)

		-- Lines 900-911
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

		-- Lines 924-929
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

-- Lines 948-952
function MenuCallbackHandler:connect_to_lobby(item)
	managers.network.matchmake:join_server_with_check(item:parameters().room_id)
end

-- Lines 954-963
function MenuCallbackHandler:stop_multiplayer()
	Application:debug("[MenuCallbackHandler:stop_multiplayer()]")

	Global.game_settings.single_player = false

	if managers.network:session() and managers.network:session():local_peer():id() == 1 then
		managers.network:stop_network(true)
	end
end

-- Lines 965-975
function MenuCallbackHandler:invite_friends()
	if managers.network.matchmake.lobby_handler then
		if MenuCallbackHandler:is_overlay_enabled() then
			Steam:overlay_activate("invite", managers.network.matchmake.lobby_handler:id())
		else
			managers.menu:show_enable_steam_overlay()
		end
	end
end

-- Lines 977-982
function MenuCallbackHandler:invite_friend(item)
	if item:parameters().signin_status ~= "signed_in" then
		return
	end

	managers.network.matchmake:send_join_invite(item:parameters().friend)
end

-- Lines 985-988
function MenuCallbackHandler:invite_friends_XB1()
	local platform_id = managers.user:get_platform_id()

	XboxLive:invite_friends_ui(platform_id, managers.network.matchmake._session)
end

-- Lines 991-994
function MenuCallbackHandler:invite_xbox_live_party()
	local platform_id = managers.user:get_platform_id()

	XboxLive:show_party_ui(platform_id)
end

-- Lines 996-999
function MenuCallbackHandler:invite_friends_ps4()
	PSN:invite_friends()
end

-- Lines 1001-1006
function MenuCallbackHandler:view_invites()
	print("View invites")
	print(PSN:display_message_invitation())
end

-- Lines 1008-1018
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

-- Lines 1020-1025
function MenuCallbackHandler:mute_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:mute_player(item:parameters().peer, item:value() == "on")
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1027-1032
function MenuCallbackHandler:mute_xbox_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:set_muted(item:parameters().xuid, item:value() == "on")
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1034-1039
function MenuCallbackHandler:mute_xb1_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:set_muted(item:parameters().xuid, item:value() == "on")
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1041-1047
function MenuCallbackHandler:mute_ps4_player(item)
	if managers.network.voice_chat then
		managers.network.voice_chat:mute_player(item:parameters().peer, item:value() == "on")
		item:parameters().peer:set_muted(item:value() == "on")
	end
end

-- Lines 1049-1075
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

-- Lines 1077-1079
function MenuCallbackHandler:view_gamer_card(item)
	XboxLive:show_gamer_card_ui(managers.user:get_platform_id(), item:parameters().xuid)
end

-- Lines 1081-1083
function MenuCallbackHandler:save_settings()
	managers.savefile:save_setting(true)
end

-- Lines 1085-1087
function MenuCallbackHandler:save_progress()
	managers.savefile:save_progress()
end

-- Lines 1089-1094
function MenuCallbackHandler:debug_level_jump(item)
	local param_map = item:parameters()

	managers.network:host_game()

	local level_id = tweak_data.levels:get_level_name_from_world_name(param_map.level)

	managers.network:session():load_level(param_map.level, param_map.mission, param_map.world_setting, param_map.level_class_name, level_id, nil)
end

-- Lines 1096-1107
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

-- Lines 1109-1112
function MenuCallbackHandler:save_game_callback()
	managers.menu:set_save_game_callback(nil)
	managers.menu:back()
end

-- Lines 1114-1134
function MenuCallbackHandler:start_the_game()
	managers.worldcollection.level_transition_in_progress = true
	local level_id = Global.game_settings.level_id
	local level_name = level_id and tweak_data.levels[level_id].world_name

	if Global.boot_invite then
		Global.boot_invite.used = true
		Global.boot_invite.pending = false
	end

	if Global.boot_play_together then
		Global.boot_play_together.used = true
		Global.boot_play_together.pending = false
	end

	local mission = Global.game_settings.mission ~= "none" and Global.game_settings.mission or nil
	local world_setting = Global.game_settings.world_setting

	managers.network:session():load_level(level_name, mission, world_setting, nil, level_id)
end

-- Lines 1136-1140
function MenuCallbackHandler:singleplayer_restart_game_to_camp(item)
	managers.menu:show_restart_game_dialog({
		yes_func = function ()
			managers.game_play_central:restart_the_game()
		end
	})
end

-- Lines 1142-1146
function MenuCallbackHandler:singleplayer_restart_mission(item)
	managers.menu:show_restart_game_dialog({
		yes_func = function ()
			managers.game_play_central:restart_the_game()
		end
	})
end

-- Lines 1148-1150
function MenuCallbackHandler:always_hide()
	return false
end

-- Lines 1152-1157
function MenuCallbackHandler:set_music_volume(item)
	local volume = item:value()
	local old_volume = managers.user:get_setting("music_volume")

	managers.user:set_setting("music_volume", volume)
end

-- Lines 1159-1164
function MenuCallbackHandler:set_sfx_volume(item)
	local volume = item:value()
	local old_volume = managers.user:get_setting("sfx_volume")

	managers.user:set_setting("sfx_volume", volume)
end

-- Lines 1166-1171
function MenuCallbackHandler:set_voice_volume(item)
	local volume = item:value()
	local old_volume = managers.user:get_setting("voice_volume")

	managers.user:set_setting("voice_volume", volume)
end

-- Lines 1173-1176
function MenuCallbackHandler:_refresh_brightness()
	managers.user:set_setting("brightness", managers.user:get_setting("brightness"), true)
end

-- Lines 1178-1181
function MenuCallbackHandler:set_brightness(item)
	local brightness = item:value()

	managers.user:set_setting("brightness", brightness)
end

-- Lines 1183-1187
function MenuCallbackHandler:set_effect_quality(item)
	local effect_quality = item:value()

	managers.user:set_setting("effect_quality", effect_quality)
end

-- Lines 1189-1200
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

-- Lines 1202-1213
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

-- Lines 1215-1225
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

-- Lines 1227-1229
function MenuCallbackHandler:is_current_resolution(item)
	return item:name() == string.format("%d x %d, %dHz", RenderSettings.resolution.x, RenderSettings.resolution.y, RenderSettings.resolution.z)
end

-- Lines 1232-1250
function MenuCallbackHandler:end_game()
	print(" MenuCallbackHandler:end_game() ")

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

-- Lines 1252-1288
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
	managers.challenge_cards:clear_suggested_cards()

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

-- Lines 1290-1295
function MenuCallbackHandler:leave_safehouse()
	-- Lines 1291-1293
	local function yes_func()
		self:_dialog_end_game_yes()
	end

	managers.menu:show_leave_safehouse_dialog({
		yes_func = yes_func
	})
end

-- Lines 1297-1308
function MenuCallbackHandler:abort_mission()
	if game_state_machine:current_state_name() == "disconnected" then
		return
	end

	-- Lines 1302-1306
	local function yes_func()
		if game_state_machine:current_state_name() ~= "disconnected" then
			self:load_start_menu_lobby()
		end
	end

	managers.menu:show_abort_mission_dialog({
		yes_func = yes_func
	})
end

-- Lines 1310-1312
function MenuCallbackHandler:load_start_menu_lobby()
	managers.network:session():load_lobby()
end

-- Lines 1314-1315
function MenuCallbackHandler:_dialog_end_game_no()
end

-- Lines 1317-1320
function MenuCallbackHandler:_reset_mainmusic()
	managers.music:post_event(MusicManager.STOP_ALL_MUSIC)
	managers.music:post_event(MusicManager.MENU_MUSIC)
end

-- Lines 1322-1332
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

-- Lines 1334-1340
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

-- Lines 1342-1348
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

-- Lines 1350-1356
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

-- Lines 1358-1364
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

-- Lines 1366-1368
function MenuCallbackHandler:resume_game()
	managers.menu:close_menu("menu_pause")
end

-- Lines 1370-1371
function MenuCallbackHandler:change_upgrade(menu_item)
end

-- Lines 1373-1381
function MenuCallbackHandler:delayed_open_savefile_menu(item)
	if not self._delayed_open_savefile_menu_callback then
		if managers.savefile:is_active() then
			managers.menu:set_delayed_open_savefile_menu_callback(callback(self, self, "open_savefile_menu", item))
		else
			self:open_savefile_menu(item)
		end
	end
end

-- Lines 1383-1388
function MenuCallbackHandler:open_savefile_menu(item)
	managers.menu:set_delayed_open_savefile_menu_callback(nil)

	local parameter_map = item:parameters()

	managers.menu:open_node(parameter_map.delayed_node, {
		parameter_map
	})
end

-- Lines 1390-1392
function MenuCallbackHandler:hide_huds()
	managers.hud:set_disabled()
end

-- Lines 1394-1400
function MenuCallbackHandler:toggle_hide_huds(item)
	if item:value() == "on" then
		managers.hud:set_disabled()
	else
		managers.hud:set_enabled()
	end
end

-- Lines 1402-1404
function MenuCallbackHandler:toggle_mission_fading_debug_enabled(item)
	managers.mission:set_fading_debug_enabled(item:value() == "off")
end

-- Lines 1406-1408
function MenuCallbackHandler:menu_back()
	managers.menu:back()
end

-- Lines 1410-1426
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

-- Lines 1428-1431
function MenuCallbackHandler:choice_button_layout_category(item)
	local node_gui = managers.menu:active_menu().renderer:active_node_gui()

	node_gui:set_current_category(item:value())
end

-- Lines 1433-1456
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

-- Lines 1459-1516
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

		local active_menu = managers.menu:active_menu()

		if active_menu and active_menu.logic then
			active_menu.logic:navigate_back(true)
			active_menu.logic:refresh_node("lobby", true)
		end
	else
		managers.network.matchmake:create_lobby(matchmake_attributes)
	end

	if job_data.job_id == OperationsTweakData.ENTRY_POINT_LEVEL then
		local mission = tweak_data.operations:mission_data(managers.raid_job:played_tutorial() and RaidJobManager.CAMP_ID or RaidJobManager.TUTORIAL_ID)
		local data = {
			background = mission.loading.image,
			loading_text = mission.loading.text,
			mission = mission
		}

		managers.menu:show_loading_screen(data)
	end

	managers.raid_job:on_mission_started()
end

-- Lines 1518-1522
function MenuCallbackHandler:play_single_player_job(item)
	self:play_single_player()
	self:start_single_player_job({
		job_id = item:parameter("job_id"),
		difficulty = Global.DEFAULT_DIFFICULTY
	})
end

-- Lines 1525-1527
function MenuCallbackHandler:play_quick_start_job(item)
	self:start_job({
		job_id = item:parameter("job_id"),
		difficulty = Global.DEFAULT_DIFFICULTY
	})
end

-- Lines 1529-1539
function MenuCallbackHandler:start_single_player_job(job_data)
	local raid_data = tweak_data.operations:mission_data(job_data.job_id)
	Global.game_settings.level_id = raid_data.level_id
	Global.game_settings.mission = "none"
	Global.game_settings.world_setting = nil

	tweak_data:set_difficulty(job_data.difficulty)
	MenuCallbackHandler:start_the_game()
	managers.raid_job:on_mission_started()
end

-- Lines 1541-1554
function MenuCallbackHandler:_update_outfit_information()
	local outfit_string = managers.blackmarket:outfit_string()

	if self:is_win32() then
		Steam:set_rich_presence("outfit", outfit_string)
	end

	if managers.network:session() then
		local local_peer = managers.network:session():local_peer()
		local in_lobby = local_peer:in_lobby() and game_state_machine:current_state_name() ~= "ingame_lobby_menu"

		local_peer:set_outfit_string(outfit_string)
		managers.network:session():check_send_outfit()
	end
end

-- Lines 1556-1561
function MenuCallbackHandler:stage_success()
	if not managers.raid_job:has_active_job() then
		return true
	end

	return managers.raid_job:stage_success()
end
