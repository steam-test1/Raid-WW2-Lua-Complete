require("lib/states/GameState")

MenuMainState = MenuMainState or class(GameState)

-- Lines 5-7
function MenuMainState:init(game_state_machine)
	GameState.init(self, "menu_main", game_state_machine)
end

-- Lines 9-107
function MenuMainState:at_enter(old_state)
	managers.worldcollection:reset_global_ref_counter()
	managers.platform:set_playing(false)
	managers.platform:set_rich_presence("Idle")

	if old_state:name() ~= "freeflight" or not managers.menu:is_active() then
		self._sound_listener = SoundDevice:create_listener("main_menu")

		self._sound_listener:activate(true)
		managers.menu:open_menu("menu_main")
		managers.music:post_event(MusicManager.MENU_MUSIC)

		if Global.load_start_menu_lobby then
			if managers.network:session() and (Network:is_server() or managers.network:session():server_peer()) then
				managers.overlay_effect:play_effect({
					sustain = 0.5,
					fade_in = 0,
					blend_mode = "normal",
					fade_out = 0.5,
					color = Color.black
				})
				managers.menu:external_enter_online_menus()
				managers.menu:on_enter_lobby()
			else
				self:server_left()
			end
		elseif Global.load_start_menu then
			managers.overlay_effect:play_effect({
				sustain = 0.25,
				fade_in = 0,
				blend_mode = "normal",
				fade_out = 0.25,
				color = Color.black
			})
		end
	end

	local has_invite = false

	if SystemInfo:platform() == Idstring("PS3") or SystemInfo:platform() == Idstring("PS4") then
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
	elseif SystemInfo:platform() == Idstring("WIN32") then
		if SystemInfo:distribution() == Idstring("STEAM") and Global.boot_invite then
			has_invite = true
			local lobby = Global.boot_invite
			Global.boot_invite = nil

			managers.network.matchmake:join_server_with_check(lobby)
		end
	elseif (SystemInfo:platform() == Idstring("X360") or SystemInfo:platform() == Idstring("XB1")) and Global.boot_invite and next(Global.boot_invite) then
		has_invite = true

		managers.network.matchmake:join_boot_invite()
	end

	if Global.open_trial_buy then
		Global.open_trial_buy = nil

		managers.menu:open_node("trial_info")
	elseif not has_invite and not managers.network:session() and false then
		-- Lines 88-90
		local function yes_func()
			MenuCallbackHandler:play_safehouse({
				skip_question = true
			})
		end

		managers.menu:show_question_start_tutorial({
			yes_func = yes_func
		})
	end

	if Global.savefile_manager.backup_save_enabled then
		-- Nothing
	end

	if Global.exe_argument_level then
		MenuCallbackHandler:start_job({
			job_id = Global.exe_argument_level,
			difficulty = Global.exe_argument_difficulty
		})
	end
end

-- Lines 109-118
function MenuMainState:at_exit(new_state)
	if new_state:name() ~= "freeflight" then
		managers.menu:close_menu("menu_main")
	end

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end
end

-- Lines 120-126
function MenuMainState:server_left()
	if managers.network:session() and (managers.network:session():has_recieved_ok_to_load_level() or managers.network:session():closing()) then
		return
	end

	managers.menu:show_host_left_dialog("dialog_server_left")
end

-- Lines 128-129
function MenuMainState:on_disconnected()
end

-- Lines 131-133
function MenuMainState:is_joinable()
	return false
end
