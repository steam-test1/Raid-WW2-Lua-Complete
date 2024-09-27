require("lib/states/GameState")

MenuMainState = MenuMainState or class(GameState)

function MenuMainState:init(game_state_machine)
	GameState.init(self, "menu_main", game_state_machine)
end

function MenuMainState:at_enter(old_state)
	managers.worldcollection:reset_global_ref_counter()
	managers.platform:set_playing(false)
	managers.platform:set_rich_presence("InMenus")

	if old_state:name() ~= "freeflight" or not managers.menu:is_active() then
		self._sound_listener = SoundDevice:create_listener("main_menu")

		self._sound_listener:activate(true)
		managers.menu:open_menu("menu_main")
		managers.music:post_event(MusicManager.MENU_MUSIC)

		if Global.load_start_menu_lobby then
			if managers.network:session() and (Network:is_server() or managers.network:session():server_peer()) then
				managers.overlay_effect:play_effect({
					blend_mode = "normal",
					fade_out = 0.5,
					sustain = 0.5,
					fade_in = 0,
					color = nil,
					color = Color.black
				})
				managers.menu:external_enter_online_menus()
				managers.menu:on_enter_lobby()
			else
				self:server_left()
			end
		elseif Global.load_start_menu then
			managers.overlay_effect:play_effect({
				blend_mode = "normal",
				fade_out = 0.25,
				sustain = 0.25,
				fade_in = 0,
				color = nil,
				color = Color.black
			})
		end
	end

	local has_invite = false
	local has_play_together = false

	if IS_PS4 then
		local is_boot = not Global.psn_boot_invite_checked and Application:is_booted_from_invitation()

		if not is_boot then
			Global.boot_invite = Global.boot_invite or nil
		else
			Global.boot_invite = {}
		end

		if is_boot or Global.boot_invite and not Global.boot_invite.used then
			has_invite = true
			Global.boot_invite.used = false
			Global.boot_invite.pending = true

			managers.menu:open_sign_in_menu(function (success)
				if success then
					Global.boot_invite = is_boot and PSN:get_boot_invitation() or Global.boot_invite
					Global.boot_invite.used = false
					Global.boot_invite.pending = true

					managers.network.matchmake:join_boot_invite()
				end
			end)
		end

		Global.psn_boot_invite_checked = true
		local is_boot_play_together = not Global.psn_boot_playtogether_checked and Application:is_booted_from_play_together()

		if not is_boot_play_together then
			Global.boot_play_together = Global.boot_play_together or nil
		else
			Global.boot_play_together = {}
		end

		if is_boot_play_together or Global.boot_play_together and not Global.boot_play_together.used then
			has_play_together = true
			Global.boot_play_together.used = false
			Global.boot_play_together.pending = true
			Global.boot_play_together.invite_send = false

			managers.menu:open_sign_in_menu(function (success)
				if success then
					Global.boot_play_together = is_boot_play_together and PSN:get_boot_playtogether() or Global.boot_play_together
					Global.boot_play_together.used = false
					Global.boot_play_together.pending = true
					Global.boot_play_together.invite_send = false

					managers.network.matchmake:send_boot_play_together()
				end
			end)
		end

		Global.psn_boot_playtogether_checked = true
	elseif IS_PC then
		if IS_STEAM and Global.boot_invite then
			has_invite = true
			local lobby = Global.boot_invite
			Global.boot_invite = nil

			managers.network.matchmake:join_server_with_check(lobby)
		end
	elseif IS_XB1 and Global.boot_invite and next(Global.boot_invite) then
		has_invite = true

		managers.network.matchmake:join_boot_invite()
	end

	if Global.open_trial_buy then
		Global.open_trial_buy = nil

		managers.menu:open_node("trial_info")
	elseif not has_invite and not managers.network:session() and false then
		local function yes_func()
			MenuCallbackHandler:play_safehouse({
				skip_question = true
			})
		end

		managers.menu:show_question_start_tutorial({
			yes_func = nil,
			yes_func = yes_func
		})
	end

	if Global.exe_argument_level then
		MenuCallbackHandler:start_job({
			job_id = nil,
			difficulty = nil,
			job_id = Global.exe_argument_level,
			difficulty = Global.exe_argument_difficulty
		})
	end

	if Global.requestShowDisconnectedMessage then
		managers.menu:show_mp_disconnected_internet_dialog({
			ok_func = nil,
			ok_func = function ()
				Global.requestShowDisconnectedMessage = nil
			end
		})
	end
end

function MenuMainState:at_exit(new_state)
	if new_state:name() ~= "freeflight" then
		managers.menu:close_menu("menu_main")
	end

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end
end

function MenuMainState:server_left()
	if managers.network:session() and (managers.network:session():has_recieved_ok_to_load_level() or managers.network:session():closing()) then
		return
	end

	managers.menu:show_host_left_dialog("dialog_server_left")
end

function MenuMainState:on_disconnected()
end

function MenuMainState:is_joinable()
	return false
end

function MenuMainState:_file_streaming_profile()
	return DynamicResourceManager.STREAMING_PROFILE_LOADING
end
