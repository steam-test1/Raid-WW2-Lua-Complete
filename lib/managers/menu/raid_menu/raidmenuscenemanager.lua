RaidMenuSceneManager = RaidMenuSceneManager or class()
RaidMenuSceneManager.default_camp_world = "levels/tests/menu_test"
RaidMenuSceneManager.CAMERA_TRANSITION_DURATION = 2.5
RaidMenuSceneManager.menus = {
	menu_main = {}
}
RaidMenuSceneManager.menus.menu_main.name = "menu_main"
RaidMenuSceneManager.menus.menu_main.camera = nil
RaidMenuSceneManager.menus.menu_main.keep_state = true
RaidMenuSceneManager.menus.raid_main_menu = {
	name = "raid_main_menu",
	camera = nil
}
RaidMenuSceneManager.menus.mission_selection_menu = {
	name = "mission_selection_menu",
	camera = nil
}
RaidMenuSceneManager.menus.mission_unlock_menu = {
	name = "mission_unlock_menu",
	camera = nil
}
RaidMenuSceneManager.menus.mission_join_menu = {
	name = "mission_join_menu",
	camera = nil
}
RaidMenuSceneManager.menus.profile_selection_menu = {
	name = "profile_selection_menu",
	camera = "character_menu_camera"
}
RaidMenuSceneManager.menus.profile_creation_menu = {
	name = "profile_creation_menu",
	camera = "character_menu_camera"
}
RaidMenuSceneManager.menus.character_customization_menu = {
	name = "character_customization_menu",
	camera = "character_menu_camera"
}
RaidMenuSceneManager.menus.challenge_cards_menu = {
	name = "challenge_cards_menu",
	camera = nil
}
RaidMenuSceneManager.menus.challenge_cards_view_menu = {
	name = "challenge_cards_view_menu",
	camera = nil
}
RaidMenuSceneManager.menus.ready_up_menu = {
	name = "ready_up_menu",
	camera = "ready_up_camera",
	keep_state = true
}
RaidMenuSceneManager.menus.raid_options_menu = {
	name = "raid_options_menu",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_options_controls = {
	name = "raid_menu_options_controls",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_options_controls_keybinds = {
	name = "raid_menu_options_controls_keybinds",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_options_controller_mapping = {
	name = "raid_menu_options_controller_mapping",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_options_video = {
	name = "raid_menu_options_video",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_options_video_advanced = {
	name = "raid_menu_options_video_advanced",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_options_sound = {
	name = "raid_menu_options_sound",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_options_network = {
	name = "raid_menu_options_network",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_loot_screen = {
	name = "raid_menu_loot_screen",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_greed_loot_screen = {
	name = "raid_menu_greed_loot_screen",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_xp = {
	name = "raid_menu_xp",
	camera = nil
}
RaidMenuSceneManager.menus.raid_menu_post_game_breakdown = {
	name = "raid_menu_post_game_breakdown",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_special_honors = {
	name = "raid_menu_special_honors",
	camera = nil,
	keep_state = true
}
RaidMenuSceneManager.menus.raid_menu_weapon_select = {
	name = "raid_menu_weapon_select",
	camera = "weapons_menu_camera"
}
RaidMenuSceneManager.menus.raid_credits_menu = {
	name = "raid_credits_menu",
	camera = nil
}
RaidMenuSceneManager.menus.gold_asset_store_menu = {
	name = "gold_asset_store_menu",
	camera = "gold_test"
}
RaidMenuSceneManager.menus.intel_menu = {
	name = "intel_menu"
}
RaidMenuSceneManager.menus.comic_book_menu = {
	name = "comic_book_menu"
}

function _get_background_image_instance()
	if not Global.background_image then
		Global.menu_background_image = RaidGUIControlBackgroundImage:new()
	end

	return Global.menu_background_image
end

local is_editor = Application:editor()

function RaidMenuSceneManager:init()
	self._menu_stack = {}
	self._character_sync_player_data = {}
	self._close_menu_allowed = true
	self._component_on_escape_callback = nil
	self._background_image = _get_background_image_instance()
	self._pause_menu_enabled = Application:editor()

	self:hide_background()
end

function RaidMenuSceneManager:is_offline_mode()
	local callback_handler = RaidMenuCallbackHandler:new()

	return callback_handler:is_singleplayer()
end

function RaidMenuSceneManager:register_on_escape_callback(callback_ref)
	self._component_on_escape_callback = callback_ref
end

function RaidMenuSceneManager:show_background()
	managers.menu:hide_loading_screen()
	self._background_image:set_visible(true)
end

function RaidMenuSceneManager:hide_background()
	self._background_image:set_visible(false)
end

function RaidMenuSceneManager:clean_up_background()
	self:close_all_menus()

	if managers.hud then
		managers.hud:set_enabled()
	end
end

function RaidMenuSceneManager:set_pause_menu_enabled(enabled)
	self._pause_menu_enabled = enabled
end

function RaidMenuSceneManager:is_any_menu_open()
	local menu_open = self._menu_stack and #self._menu_stack > 0

	return menu_open
end

function RaidMenuSceneManager:ct_open_menus()
	if not self._menu_stack then
		return 0
	end

	return #self._menu_stack
end

function RaidMenuSceneManager:open_menu(name, dont_add_on_stack)
	if name == "raid_main_menu" and not self._pause_menu_enabled then
		return
	end

	local menu = RaidMenuSceneManager.menus[name]

	if not menu then
		Application:error("[RaidMenuSceneManager:open_menu] Not able to open menu menu, it does not exist: ", name)

		return false
	end

	managers.raid_menu:close_menu(true)

	if #self._menu_stack == 0 and Global.game_settings.single_player then
		managers.menu_component:post_event("pause_all_gameplay_sounds")
	end

	self:_start_menu_camera(menu)

	if #self._menu_stack == 0 then
		managers.hud:post_event("bckg_fire")
	end

	self:show_background()

	if managers.hud then
		managers.hud:hide_stats_screen()
	end

	managers.menu:open_menu(menu.name, nil, dont_add_on_stack)

	if not is_editor and not managers.viewport:is_fullscreen() then
		managers.mouse_pointer:unacquire_input()
	end

	return true
end

function RaidMenuSceneManager:close_all_menus()
	managers.mouse_pointer:acquire_input()

	if self._menu_stack and #self._menu_stack > 0 then
		Application:trace("[RaidMenuSceneManager:close_all_menus] self._menu_stack ", inspect(self._menu_stack))

		for i = 1, #self._menu_stack do
			Application:trace("[RaidMenuSceneManager:close_all_menus] self._menu_stack[ i ] ", self._menu_stack[i])
			self:close_menu(false)
		end
	end

	MenuRenderer._remove_blackborders()
end

function RaidMenuSceneManager:close_menu(dont_remove_from_stack)
	if not is_editor and #self._menu_stack == 1 and not dont_remove_from_stack then
		managers.mouse_pointer:acquire_input()
	end

	managers.menu:close_menu()

	if not dont_remove_from_stack then
		local menu_stack_index = #self._menu_stack
		self._menu_stack[menu_stack_index] = nil
	end

	if #self._menu_stack == 0 then
		if Global.game_settings.single_player and not dont_remove_from_stack then
			managers.menu_component:post_event("resume_all_gameplay_sounds")
		end

		managers.worldcamera:stop_sequences()

		if Global.game_settings.single_player and game_state_machine:current_state_name() ~= "menu_main" then
			Application:set_pause(false)
			SoundDevice:set_rtpc("ingame_sound", 1)
		end

		if game_state_machine:current_state_name() == "ingame_menu" then
			-- Nothing
		end

		if managers.hud then
			managers.hud:set_enabled()
		end

		if managers.dialog then
			managers.dialog:set_paused(false)
			managers.dialog:set_subtitles_shown(true)
		end

		self:_reinitialize_viewports()
		managers.hud:post_event("bckg_fire_stop")
		self:hide_background()
	end

	if managers.menu_component then
		managers.menu_component:close()
	end
end

function RaidMenuSceneManager:add_menu_name_on_stack(menu_name)
	table.insert(self._menu_stack, menu_name)

	if managers.hud then
		managers.hud:set_disabled()
	end

	if managers.dialog then
		if managers.raid_job:is_camp_loaded() then
			managers.dialog:set_paused(true)
		elseif managers.subtitle:is_showing_subtitles() then
			managers.dialog:set_subtitles_shown(false)
			managers.subtitle:set_enabled(false)
		end
	end
end

function RaidMenuSceneManager:remove_menu_name_from_stack(menu_name)
	for i = 1, #self._menu_stack do
		if self._menu_stack[i] == menu_name then
			table.remove(self._menu_stack, i)

			return
		end
	end
end

function RaidMenuSceneManager:on_escape(flag_close_all_menus)
	if self._component_on_escape_callback then
		local handles = self._component_on_escape_callback()

		if handles then
			return
		end
	end

	if managers.menu:is_open("menu_main") then
		local callback_handler = RaidMenuCallbackHandler:new()
		local params = {
			yes_func = callback(callback_handler, callback_handler, "_dialog_quit_yes")
		}

		managers.menu:show_really_quit_the_game_dialog(params)

		return
	end

	if managers.menu:is_open("ready_up_menu") then
		return
	end

	if not self:get_close_menu_allowed() then
		managers.menu:show_no_active_characters()

		return
	end

	local active_menu = managers.menu:active_menu()

	if not active_menu then
		if not flag_close_all_menus then
			Application:error("[RaidMenuSceneManager:on_escape] Trying to close a menu while no menu active")
		end

		managers.raid_menu:close_menu()

		return
	end

	local active_menu = active_menu.name

	managers.raid_menu:close_menu()

	if managers.queued_tasks then
		managers.queued_tasks:unqueue_all(nil, self)
	end

	if flag_close_all_menus then
		Application:trace("were here!")
		managers.worldcamera:stop_sequences()
	end

	if #self._menu_stack > 0 then
		self:open_menu(self._menu_stack[#self._menu_stack], true)
	end
end

function RaidMenuSceneManager:get_close_menu_allowed()
	return self._close_menu_allowed
end

function RaidMenuSceneManager:set_close_menu_allowed(flag)
	self._close_menu_allowed = flag
end

function RaidMenuSceneManager:_set_menu_state(menu)
	local camera_name = menu.camera

	if camera_name and managers.worldcamera:world_camera(camera_name) then
		managers.worldcamera:play_world_camera_sequence(camera_name, nil, true)
	elseif not menu.keep_state then
		game_state_machine:change_state_by_name("ingame_menu")
	end
end

function RaidMenuSceneManager:_reinitialize_viewports()
	local players = managers.player:players()

	if managers.subtitle:is_showing_subtitles() then
		managers.subtitle:presenter():show()
	end

	for k, player in ipairs(players) do
		local vp = player:camera():viewport()

		if vp then
			vp:set_active(true)
		else
			Application:error("No viewport for player " .. tostring(k))
		end
	end
end

function RaidMenuSceneManager:_start_menu_camera(menu)
	local camera_name = menu.camera

	if camera_name and managers.worldcamera:world_camera(camera_name) then
		managers.worldcamera:play_world_camera_sequence(camera_name, nil, true)
	else
		managers.worldcamera:stop_sequences()
	end
end

function RaidMenuSceneManager:get_active_control(control)
	return self._active_control
end

function RaidMenuSceneManager:set_active_control(control)
	self._active_control = control
end

function RaidMenuSceneManager:clear_active_control()
	self._active_control = nil
end

function RaidMenuSceneManager:save_sync_player_data()
	managers.raid_menu._character_sync_player_data.synced_ammo_info = clone(managers.player._global.synced_ammo_info)
	managers.raid_menu._character_sync_player_data.synced_bipod = clone(managers.player._global.synced_bipod)
	managers.raid_menu._character_sync_player_data.synced_bonuses = clone(managers.player._global.synced_bonuses)
	managers.raid_menu._character_sync_player_data.synced_cable_ties = clone(managers.player._global.synced_cable_ties)
	managers.raid_menu._character_sync_player_data.synced_carry = clone(managers.player._global.synced_carry)
	managers.raid_menu._character_sync_player_data.synced_deployables = clone(managers.player._global.synced_deployables)
	managers.raid_menu._character_sync_player_data.synced_drag_body = clone(managers.player._global.synced_drag_body)
	managers.raid_menu._character_sync_player_data.synced_equipment_possession = clone(managers.player._global.synced_equipment_possession)
	managers.raid_menu._character_sync_player_data.synced_grenades = clone(managers.player._global.synced_grenades)
	managers.raid_menu._character_sync_player_data.synced_team_upgrades = clone(managers.player._global.synced_team_upgrades)
	managers.raid_menu._character_sync_player_data.synced_turret = clone(managers.player._global.synced_turret)
	managers.raid_menu._character_sync_player_data.synced_vehicle_data = clone(managers.player._global.synced_vehicle_data)
end

function RaidMenuSceneManager:load_sync_player_data()
	managers.player._global.synced_ammo_info = clone(managers.raid_menu._character_sync_player_data.synced_ammo_info)
	managers.player._global.synced_bipod = clone(managers.raid_menu._character_sync_player_data.synced_bipod)
	managers.player._global.synced_bonuses = clone(managers.raid_menu._character_sync_player_data.synced_bonuses)
	managers.player._global.synced_cable_ties = clone(managers.raid_menu._character_sync_player_data.synced_cable_ties)
	managers.player._global.synced_carry = clone(managers.raid_menu._character_sync_player_data.synced_carry)
	managers.player._global.synced_deployables = clone(managers.raid_menu._character_sync_player_data.synced_deployables)
	managers.player._global.synced_drag_body = clone(managers.raid_menu._character_sync_player_data.synced_drag_body)
	managers.player._global.synced_equipment_possession = clone(managers.raid_menu._character_sync_player_data.synced_equipment_possession)
	managers.player._global.synced_grenades = clone(managers.raid_menu._character_sync_player_data.synced_grenades)
	managers.player._global.synced_team_upgrades = clone(managers.raid_menu._character_sync_player_data.synced_team_upgrades)
	managers.player._global.synced_turret = clone(managers.raid_menu._character_sync_player_data.synced_turret)
	managers.player._global.synced_vehicle_data = clone(managers.raid_menu._character_sync_player_data.synced_vehicle_data)
end

function RaidMenuSceneManager:first_login_check()
	Application:trace("[RaidMenuSceneManager:first_login_check]")

	if managers.savefile:get_active_characters_count() == 0 then
		local success = managers.raid_menu:open_menu("profile_creation_menu")

		if success then
			-- Nothing
		end
	elseif managers.raid_job._tutorial_spawned then
		Application:debug("[RaidMenuSceneManager:first_login_check()] managers.global_state:fire_event(GlobalStateManager.EVENT_CHARACTER_CREATED)")

		managers.global_state.fire_character_created_event = nil

		managers.global_state:fire_event(GlobalStateManager.EVENT_CHARACTER_CREATED)
	end

	managers.statistics:publish_custom_stat_to_steam("game_played")
end

function RaidMenuSceneManager:system_start_raid()
	Application:trace("[RaidMenuSceneManager:system_start_raid]")
	managers.challenge_cards:activate_challenge_card()
	managers.player:replenish_player()
	managers.player:replenish_player_weapons()
end

function RaidMenuSceneManager:set_current_legend_control(control)
	self._current_legend_control = control
end

function RaidMenuSceneManager:current_legend_control()
	return self._current_legend_control
end

function RaidMenuSceneManager:set_legend_labels(legend)
	if not self._current_legend_control then
		Application:error("[RaidMenuSceneManager:set_legend_labels] Trying to set controller legend while no legend control is present")

		return
	end

	self._current_legend_control:set_labels(legend)
end

function RaidMenuSceneManager:toggle_fullscreen_raid()
	local is_fullscreen = managers.viewport:is_fullscreen()

	managers.viewport:set_fullscreen(not is_fullscreen)
end

function RaidMenuSceneManager:is_pc_controller()
	if not managers.controller:is_xbox_controller_present() or managers.menu:is_pc_controller() then
		return true
	else
		return false
	end
end

function RaidMenuSceneManager:refresh_footer_gold_amount()
	if not managers.menu_component._active_components.raid_menu_footer.component_object then
		return
	end

	managers.menu_component._active_components.raid_menu_footer.component_object:refresh_gold_amount()
end

function RaidMenuSceneManager:show_dialog_join_others_forbidden()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_join_others_forbidden_message")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function RaidMenuSceneManager:show_dialog_disconnected_from_steam()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_disconnected_from_steam")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function RaidMenuSceneManager:show_dialog_already_in_game()
	local dialog_data = {
		title = managers.localization:text("dialog_warning_title"),
		text = managers.localization:text("dialog_cant_join_in_mp")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		class = RaidGUIControlButtonShortSecondary,
		cancel_button = true
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)
end

function RaidMenuSceneManager:show_release_dialog_helper(message)
	local dialog_data = {
		title = "release dialog helper",
		text = message
	}
	local no_button = {
		text = "ok"
	}
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show(dialog_data)
end
