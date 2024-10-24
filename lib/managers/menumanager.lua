core:import("CoreMenuManager")
core:import("CoreMenuCallbackHandler")
require("lib/managers/menu/MenuInput")
require("lib/managers/menu/MenuRenderer")
require("lib/managers/menu/items/MenuItemColumn")
require("lib/managers/menu/items/MenuItemLevel")
require("lib/managers/menu/items/MenuItemMultiChoice")
require("lib/managers/menu/items/MenuItemMultiChoiceRaid")
require("lib/managers/menu/items/MenuItemToggle")
require("lib/managers/menu/items/MenuItemCustomizeController")
require("lib/managers/menu/items/MenuItemInput")
require("lib/managers/menu/nodes/MenuNodeTable")
require("lib/managers/menu/nodes/MenuNodeServerList")
require("lib/managers/menu/MenuCallbackHandler")
require("lib/managers/menu/raid_menu/RaidMenuCallbackHandler")
core:import("CoreEvent")

MenuManager = MenuManager or class(CoreMenuManager.Manager)

require("lib/managers/MenuManagerPD2")

MenuManager.MENU_ITEM_WIDTH = 400
MenuManager.MENU_ITEM_HEIGHT = 32
MenuManager.MENU_ITEM_LEFT_PADDING = 20

require("lib/managers/MenuManagerDialogs")
require("lib/managers/MenuManagerDebug")

function MenuManager:init(is_start_menu)
	MenuManager.super.init(self)

	self._is_start_menu = is_start_menu
	self._active = false
	self._debug_menu_enabled = Global.DEBUG_MENU_ON or Application:production_build()
	Global.debug_contour_enabled = nil

	self:create_controller()

	if is_start_menu then
		local menu_main = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/start_menu",
			renderer = "MenuRenderer",
			id = "start_menu",
			name = "menu_main",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(menu_main)

		local mission_join_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/mission_join_menu",
			renderer = "MenuRenderer",
			id = "mission_join_menu",
			name = "mission_join_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_join_menu)

		local raid_options_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_options_menu",
			renderer = "MenuRenderer",
			id = "raid_options_menu",
			name = "raid_options_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_options_menu)

		local raid_menu_credits = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/show_credits_menu",
			renderer = "MenuRenderer",
			id = "raid_credits_menu",
			name = "raid_credits_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_credits)

		local raid_menu_options_controls = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_controls",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls",
			name = "raid_menu_options_controls",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls)

		local raid_menu_options_controls_keybinds = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_controls_keybinds",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls_keybinds",
			name = "raid_menu_options_controls_keybinds",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls_keybinds)

		local raid_menu_options_controller_mapping = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_controller_mapping",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controller_mapping",
			name = "raid_menu_options_controller_mapping",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controller_mapping)

		local raid_menu_options_video = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_video",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video",
			name = "raid_menu_options_video",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video)

		local raid_menu_options_video_advanced = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_video_advanced",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video_advanced",
			name = "raid_menu_options_video_advanced",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video_advanced)

		local raid_menu_options_interface = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_interface",
			renderer = "MenuRenderer",
			id = "raid_menu_options_interface",
			name = "raid_menu_options_interface",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_interface)

		local raid_menu_options_sound = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_sound",
			renderer = "MenuRenderer",
			id = "raid_menu_options_sound",
			name = "raid_menu_options_sound",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_sound)

		local raid_menu_options_network = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_network",
			renderer = "MenuRenderer",
			id = "raid_menu_options_network",
			name = "raid_menu_options_network",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_network)
	else
		local mission_join_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/mission_join_menu",
			renderer = "MenuRenderer",
			id = "mission_join_menu",
			name = "mission_join_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_join_menu)

		local mission_selection_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/mission_selection_menu",
			renderer = "MenuRenderer",
			id = "mission_selection_menu",
			name = "mission_selection_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_selection_menu)

		local mission_unlock_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/mission_unlock_menu",
			renderer = "MenuRenderer",
			id = "mission_unlock_menu",
			name = "mission_unlock_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_unlock_menu)

		local profile_selection_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/profile_selection_menu",
			renderer = "MenuRenderer",
			id = "profile_selection_menu",
			name = "profile_selection_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(profile_selection_menu)

		local profile_creation_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/profile_creation_menu",
			renderer = "MenuRenderer",
			id = "profile_creation_menu",
			name = "profile_creation_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(profile_creation_menu)

		local character_customization_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/character_customization_menu",
			renderer = "MenuRenderer",
			id = "character_customization_menu",
			name = "character_customization_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(character_customization_menu)

		local raid_main_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_main_menu",
			renderer = "MenuRenderer",
			id = "raid_main_menu",
			name = "raid_main_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_main_menu)

		local raid_options_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_options_menu",
			renderer = "MenuRenderer",
			id = "raid_options_menu",
			name = "raid_options_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_options_menu)

		local challenge_cards_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/challenge_cards_menu",
			renderer = "MenuRenderer",
			id = "challenge_cards_menu",
			name = "challenge_cards_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(challenge_cards_menu)

		local ready_up_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/ready_up_menu",
			renderer = "MenuRenderer",
			id = "ready_up_menu",
			name = "ready_up_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(ready_up_menu)

		local challenge_cards_view_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/challenge_cards_view_menu",
			renderer = "MenuRenderer",
			id = "challenge_cards_view_menu",
			name = "challenge_cards_view_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(challenge_cards_view_menu)

		local raid_experience_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/xp_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_xp",
			name = "raid_menu_xp",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_experience_menu)

		local raid_post_game_breakdown_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/post_game_breakdown",
			renderer = "MenuRenderer",
			id = "raid_menu_post_game_breakdown",
			name = "raid_menu_post_game_breakdown",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_post_game_breakdown_menu)

		local raid_special_honors_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/special_honors",
			renderer = "MenuRenderer",
			id = "raid_menu_special_honors",
			name = "raid_menu_special_honors",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_special_honors_menu)

		local raid_loot_screen_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/loot_screen_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_loot_screen",
			name = "raid_menu_loot_screen",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_loot_screen_menu)

		local raid_greed_loot_screen_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/greed_loot_screen_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_greed_loot_screen",
			name = "raid_menu_greed_loot_screen",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_greed_loot_screen_menu)

		local raid_menu_weapon_select = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/weapon_select_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_weapon_select",
			name = "raid_menu_weapon_select",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_weapon_select)

		local raid_menu_credits = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/show_credits_menu",
			renderer = "MenuRenderer",
			id = "raid_credits_menu",
			name = "raid_credits_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_credits)

		local raid_menu_options_controls = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_controls",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls",
			name = "raid_menu_options_controls",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls)

		local raid_menu_options_controller_mapping = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_controller_mapping",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controller_mapping",
			name = "raid_menu_options_controller_mapping",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controller_mapping)

		local raid_menu_options_controls_keybinds = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_controls_keybinds",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls_keybinds",
			name = "raid_menu_options_controls_keybinds",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls_keybinds)

		local raid_menu_options_video = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_video",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video",
			name = "raid_menu_options_video",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video)

		local raid_menu_options_video_advanced = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_video_advanced",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video_advanced",
			name = "raid_menu_options_video_advanced",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video_advanced)

		local raid_menu_options_interface = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_interface",
			renderer = "MenuRenderer",
			id = "raid_menu_options_interface",
			name = "raid_menu_options_interface",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_interface)

		local raid_menu_options_sound = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_sound",
			renderer = "MenuRenderer",
			id = "raid_menu_options_sound",
			name = "raid_menu_options_sound",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_sound)

		local raid_menu_options_network = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/raid_menu_options_network",
			renderer = "MenuRenderer",
			id = "raid_menu_options_network",
			name = "raid_menu_options_network",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_network)

		local gold_asset_store_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/gold_asset_store_menu",
			renderer = "MenuRenderer",
			id = "gold_asset_store_menu",
			name = "gold_asset_store_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(gold_asset_store_menu)

		local intel_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/intel_menu",
			renderer = "MenuRenderer",
			id = "intel_menu",
			name = "intel_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(intel_menu)

		local comic_book_menu = {
			input = "MenuInput",
			callback_handler = nil,
			content_file = "gamedata/raid/menus/comic_book_menu",
			renderer = "MenuRenderer",
			id = "comic_book_menu",
			name = "comic_book_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(comic_book_menu)
	end

	self._controller:add_trigger("toggle_menu", callback(self, self, "toggle_menu_state"))
	self._controller:add_trigger("toggle_hud", callback(self, self, "toggle_hud_state"))

	if MenuCallbackHandler:is_pc_controller() then
		self._controller:add_trigger("toggle_chat", callback(self, self, "toggle_chatinput"))
	end

	self._controller:add_trigger("push_to_talk", callback(self, self, "push_to_talk", true))
	self._controller:add_release_trigger("push_to_talk", callback(self, self, "push_to_talk", false))

	self._active_changed_callback_handler = CoreEvent.CallbackEventHandler:new()

	managers.user:add_setting_changed_callback("brightness", callback(self, self, "brightness_changed"), true)
	managers.user:add_setting_changed_callback("camera_sensitivity_x", callback(self, self, "camera_sensitivity_x_changed"), true)
	managers.user:add_setting_changed_callback("camera_sensitivity_y", callback(self, self, "camera_sensitivity_y_changed"), true)
	managers.user:add_setting_changed_callback("camera_zoom_sensitivity_x", callback(self, self, "camera_sensitivity_x_changed"), true)
	managers.user:add_setting_changed_callback("camera_zoom_sensitivity_y", callback(self, self, "camera_sensitivity_y_changed"), true)
	managers.user:add_setting_changed_callback("rumble", callback(self, self, "rumble_changed"), true)
	managers.user:add_setting_changed_callback("invert_camera_x", callback(self, self, "invert_camera_x_changed"), true)
	managers.user:add_setting_changed_callback("invert_camera_y", callback(self, self, "invert_camera_y_changed"), true)
	managers.user:add_setting_changed_callback("southpaw", callback(self, self, "southpaw_changed"), true)
	managers.user:add_setting_changed_callback("subtitle", callback(self, self, "subtitle_changed"), true)
	managers.user:add_setting_changed_callback("music_volume", callback(self, self, "music_volume_changed"), true)
	managers.user:add_setting_changed_callback("sfx_volume", callback(self, self, "sfx_volume_changed"), true)
	managers.user:add_setting_changed_callback("voice_volume", callback(self, self, "voice_volume_changed"), true)
	managers.user:add_setting_changed_callback("voice_over_volume", callback(self, self, "voice_over_volume_changed"), true)
	managers.user:add_setting_changed_callback("master_volume", callback(self, self, "master_volume_changed"), true)
	managers.user:add_setting_changed_callback("effect_quality", callback(self, self, "effect_quality_changed"), true)
	managers.user:add_setting_changed_callback("ssao_setting", callback(self, self, "ssao_setting_changed"), true)
	managers.user:add_setting_changed_callback("motion_blur_setting", callback(self, self, "motion_blur_setting_changed"), true)
	managers.user:add_setting_changed_callback("vls_setting", callback(self, self, "volumetric_light_scatter_setting_changed"), true)
	managers.user:add_setting_changed_callback("AA_setting", callback(self, self, "AA_setting_changed"), true)
	managers.user:add_setting_changed_callback("colorblind_setting", callback(self, self, "colorblind_setting_changed"), true)
	managers.user:add_setting_changed_callback("fps_cap", callback(self, self, "fps_limit_changed"), true)
	managers.user:add_setting_changed_callback("net_packet_throttling", callback(self, self, "net_packet_throttling_changed"), true)
	managers.user:add_setting_changed_callback("net_forwarding", callback(self, self, "net_forwarding_changed"), true)
	managers.user:add_setting_changed_callback("net_use_compression", callback(self, self, "net_use_compression_changed"), true)
	managers.user:add_setting_changed_callback("use_thq_weapon_parts", callback(self, self, "use_thq_weapon_parts_changed"), true)
	managers.user:add_setting_changed_callback("detail_distance", callback(self, self, "detail_distance_setting_changed"), true)
	managers.user:add_setting_changed_callback("use_parallax", callback(self, self, "use_parallax_setting_changed"), true)
	managers.user:add_setting_changed_callback("dof_setting", callback(self, self, "dof_setting_changed"), true)
	managers.user:add_setting_changed_callback("hud_special_weapon_panels", callback(self, self, "iconography_ammo_changed"), true)
	managers.user:add_active_user_state_changed_callback(callback(self, self, "on_user_changed"))
	managers.user:add_storage_changed_callback(callback(self, self, "on_storage_changed"))
	managers.savefile:add_active_changed_callback(callback(self, self, "safefile_manager_active_changed"))

	self._delayed_open_savefile_menu_callback = nil
	self._save_game_callback = nil

	self:brightness_changed(nil, nil, managers.user:get_setting("brightness"))
	self:effect_quality_changed(nil, nil, managers.user:get_setting("effect_quality"))
	self:fps_limit_changed(nil, nil, managers.user:get_setting("fps_cap"))
	self:net_packet_throttling_changed(nil, nil, managers.user:get_setting("net_packet_throttling"))
	self:net_forwarding_changed(nil, nil, managers.user:get_setting("net_forwarding"))
	self:net_use_compression_changed(nil, nil, managers.user:get_setting("net_use_compression"))
	self:invert_camera_y_changed("invert_camera_y", nil, managers.user:get_setting("invert_camera_y"))
	self:southpaw_changed("southpaw", nil, managers.user:get_setting("southpaw"))
	self:ssao_setting_changed("ssao_setting", nil, managers.user:get_setting("ssao_setting"))
	self:motion_blur_setting_changed("motion_blur_setting", nil, managers.user:get_setting("motion_blur_setting"))
	self:volumetric_light_scatter_setting_changed("vls_setting", nil, managers.user:get_setting("vls_setting"))
	self:AA_setting_changed("AA_setting", nil, managers.user:get_setting("AA_setting"))
	self:colorblind_setting_changed("colorblind_setting", nil, managers.user:get_setting("colorblind_setting"))
	self:detail_distance_setting_changed("detail_distance", nil, managers.user:get_setting("detail_distance"))
	self:use_parallax_setting_changed("use_parallax", nil, managers.user:get_setting("use_parallax"))
	self:dof_setting_changed("dof_setting", nil, managers.user:get_setting("dof_setting"))
	managers.system_menu:add_active_changed_callback(callback(self, self, "system_menu_active_changed"))

	self._sound_source = SoundDevice:create_source("MenuManager")

	managers.controller:add_hotswap_callback("menu_manager", callback(self, self, "controller_hotswap_triggered"), 1)

	self._loading_screen = self:_init_loading_screen()

	if Global.dropin_loading_screen then
		managers.menu:show_loading_screen(Global.dropin_loading_screen)
	end
end

function MenuManager:_init_loading_screen()
	return HUDLoadingScreen:new()
end

function MenuManager:show_loading_screen(data, clbk, instant)
	self._loading_screen:show(data, clbk, instant)

	if managers and managers.network and managers.network.voice_chat then
		managers.network.voice_chat:trc_check_mute()
	end
end

function MenuManager:fade_to_black()
	self._loading_screen:fade_to_black()
end

function MenuManager:hide_loading_screen()
	self.loading_screen_visible = false

	self._loading_screen:hide()

	local current_game_state_name = nil
	local event_complete_state = false

	if game_state_machine then
		current_game_state_name = game_state_machine:current_state_name()

		if current_game_state_name and current_game_state_name == "event_complete_screen" then
			event_complete_state = true
		end
	end

	if not event_complete_state and managers and managers.network and managers.network.voice_chat then
		managers.network.voice_chat:trc_check_unmute()
	end
end

function MenuManager:controller_hotswap_triggered()
	self:recreate_controller()
	self._controller:add_trigger("toggle_menu", callback(self, self, "toggle_menu_state"))

	local is_pc_controller = not managers.controller:is_controller_present()

	if is_pc_controller then
		self._controller:add_trigger("toggle_chat", callback(self, self, "toggle_chatinput"))
	end

	local active_menu = self:active_menu(nil, nil)

	if active_menu then
		if is_pc_controller then
			active_menu.input:activate_mouse(nil, true)
		else
			active_menu.input:deactivate_mouse(nil, true)
		end
	end

	self._controller:add_trigger("push_to_talk", callback(self, self, "push_to_talk", true))
	self._controller:add_release_trigger("push_to_talk", callback(self, self, "push_to_talk", false))
end

function MenuManager:post_event(event)
end

function MenuManager:_cb_matchmake_found_game(game_id, created)
	print("_cb_matchmake_found_game", game_id, created)
end

function MenuManager:_cb_matchmake_player_joined(player_info)
	print("_cb_matchmake_player_joined")
end

function MenuManager:destroy()
	MenuManager.super.destroy(self)
	self:destroy_controller()
	managers.controller:remove_hotswap_callback("menu_manager")
end

function MenuManager:set_delayed_open_savefile_menu_callback(callback_func)
	self._delayed_open_savefile_menu_callback = callback_func
end

function MenuManager:set_save_game_callback(callback_func)
	self._save_game_callback = callback_func
end

function MenuManager:system_menu_active_changed(active)
	local active_menu = self:active_menu()

	if not active_menu then
		return
	end

	if active then
		active_menu.logic:accept_input(false)
	else
		active_menu.renderer:disable_input(0.01)
	end
end

function MenuManager:set_and_send_sync_state(state)
	if not managers.network or not managers.network:session() then
		return
	end

	local index = tweak_data:menu_sync_state_to_index(state)

	if index then
		self:_set_peer_sync_state(managers.network:session():local_peer():id(), state)
		managers.network:session():send_to_peers_loaded("set_menu_sync_state_index", index)
	end
end

function MenuManager:_set_peer_sync_state(peer_id, state)
	Application:debug("MenuManager: " .. peer_id .. " sync state is now", state)

	self._peers_state = self._peers_state or {}
	self._peers_state[peer_id] = state
end

function MenuManager:set_peer_sync_state_index(peer_id, index)
	local state = tweak_data:index_to_menu_sync_state(index)

	self:_set_peer_sync_state(peer_id, state)
end

function MenuManager:get_all_peers_state()
	return self._peers_state
end

function MenuManager:get_peer_state(peer_id)
	return self._peers_state and self._peers_state[peer_id]
end

function MenuManager:_node_selected(menu_name, node)
	managers.vote:message_vote()
	self:set_and_send_sync_state(node and node:parameters().sync_state)
end

function MenuManager:active_menu(node_name, parameter_list)
	local active_menu = self._open_menus[#self._open_menus]

	if active_menu then
		return active_menu
	end
end

function MenuManager:open_menu(menu_name, position, dont_add_on_stack)
	if not dont_add_on_stack then
		managers.raid_menu:add_menu_name_on_stack(menu_name)
	end

	if managers.raid_job:is_camp_loaded() then
		managers.menu_component:post_event("menu_volume_set")
	end

	MenuManager.super.open_menu(self, menu_name, position)
	self:activate()
	managers.system_menu:force_close_all()
end

function MenuManager:open_node(node_name, parameter_list)
	local active_menu = self._open_menus[#self._open_menus]

	if active_menu then
		active_menu.logic:select_node(node_name, true, unpack(parameter_list or {}))
	end
end

function MenuManager:back(queue, skip_nodes)
	local active_menu = self._open_menus[#self._open_menus]

	if active_menu then
		active_menu.input:back(queue, skip_nodes)
	end
end

function MenuManager:close_menu(menu_name)
	self:post_event("menu_exit")

	if Application:paused() and menu_name == "menu_pause" then
		Application:set_pause(false)
	end

	if managers.raid_job:is_camp_loaded() then
		managers.menu_component:post_event("menu_volume_reset")
	end

	MenuManager.super.close_menu(self, menu_name)
end

function MenuManager:_menu_closed(menu_name)
	MenuManager.super._menu_closed(self, menu_name)
	self:deactivate()
end

function MenuManager:close_all_menus()
	local names = {}

	for _, menu in pairs(self._open_menus) do
		table.insert(names, menu.name)
	end

	for _, name in ipairs(names) do
		self:close_menu(name)
	end

	if managers.menu_component then
		managers.menu_component:close()
	end
end

function MenuManager:is_open(menu_name)
	for _, menu in ipairs(self._open_menus) do
		if menu.name == menu_name then
			return true
		end
	end

	return false
end

function MenuManager:is_in_root(menu_name)
	for _, menu in ipairs(self._open_menus) do
		if menu.name == menu_name then
			return #menu.renderer._node_gui_stack == 1
		end
	end

	return false
end

function MenuManager:is_pc_controller()
	return self:active_menu() and self:active_menu().input and self:active_menu().input._controller and self:active_menu().input._controller.TYPE == "pc" or managers.controller:get_default_wrapper_type() == "pc"
end

function MenuManager:is_xb1_controller()
	return self:active_menu() and self:active_menu().input and self:active_menu().input._controller and self:active_menu().input._controller.TYPE == "xb1" or managers.controller:get_default_wrapper_type() == "xb1"
end

function MenuManager:is_ps4_controller()
	return self:active_menu() and self:active_menu().input and self:active_menu().input._controller and self:active_menu().input._controller.TYPE == "ps4" or managers.controller:get_default_wrapper_type() == "ps4"
end

function MenuManager:is_any_controller()
	return self:is_pc_controller() or self:is_xb1_controller() or self:is_ps4_controller()
end

function MenuManager:mark_main_menu(is_main_menu)
	self._is_start_menu = is_main_menu
end

function MenuManager:toggle_menu_state()
	if managers.vote:is_restarting() or managers.game_play_central and managers.game_play_central:is_restarting() then
		return
	end

	if self._is_start_menu and game_state_machine:current_state_name() == "menu_main" then
		return
	end

	if game_state_machine:current_state_name() == "bootup" or game_state_machine:current_state_name() == "menu_titlescreen" then
		return
	end

	if managers.hud then
		if managers.hud:chat_focus() then
			return
		end

		if managers.hud:is_comm_wheel_visible() then
			managers.hud:hide_comm_wheel()
		end
	end

	if (not Application:editor() or Global.running_simulation) and not managers.system_menu:is_active() then
		if managers.raid_menu._menu_stack and #managers.raid_menu._menu_stack > 0 then
			Application:debug("[MenuManager:toggle_menu_state] Menu Stack >0")
			managers.raid_menu:on_escape()
		else
			Application:debug("[MenuManager:toggle_menu_state] Menu Stack Empty")

			if (not self:active_menu() or #self:active_menu().logic._node_stack == 1 or not managers.menu:active_menu().logic:selected_node() or managers.menu:active_menu().logic:selected_node():parameters().allow_pause_menu) and managers.menu_component:input_focus() ~= 1 then
				local success = managers.raid_menu:open_menu("raid_main_menu")

				if Global.game_settings.single_player or managers.network:session():count_all_peers() == 1 then
					if not managers.raid_job:is_camp_loaded() then
						Application:debug("[MenuManager:toggle_menu_state()] PAUSING")
						Application:set_pause(true)
					end

					local player_unit = managers.player:player_unit()

					if alive(player_unit) and player_unit:movement():current_state().update_check_actions_paused then
						player_unit:movement():current_state():update_check_actions_paused()
					end
				end
			end
		end
	end
end

function MenuManager:push_to_talk(enabled)
	if managers.network and managers.network.voice_chat then
		managers.network.voice_chat:set_recording(enabled)
	end
end

function MenuManager:toggle_chatinput()
	if Global.game_settings.single_player or Application:editor() then
		return
	end

	if not IS_PC then
		return
	end

	if self:active_menu() then
		return
	end

	if not managers.network:session() then
		return
	end

	if managers.hud then
		managers.hud:toggle_chatinput()

		return true
	end
end

function MenuManager:toggle_hud_state()
	if managers.hud and not managers.hud:chat_focus() and not self:is_active() then
		if managers.hud._disabled then
			managers.hud:set_enabled()
		else
			managers.hud:set_disabled()
		end
	end
end

function MenuManager:set_slot_voice(peer, peer_id, active)
end

function MenuManager:recreate_controller()
	self._controller = managers.controller:create_controller("MenuManager", nil, false)
	local setup = self._controller:get_setup()
	local look_connection = setup:get_connection("look")
	self._look_multiplier = look_connection:get_multiplier()

	if not managers.savefile:is_active() then
		self._controller:enable()
	end

	self:set_mouse_sensitivity()
end

function MenuManager:create_controller()
	if not self._controller then
		self._controller = managers.controller:get_controller_by_name("MenuManager")

		if not self._controller then
			self._controller = managers.controller:create_controller("MenuManager", nil, false)
		end

		local setup = self._controller:get_setup()
		local look_connection = setup:get_connection("look")
		self._look_multiplier = look_connection:get_multiplier()

		if not managers.savefile:is_active() then
			self._controller:enable()
		end

		self:set_mouse_sensitivity()
	end
end

function MenuManager:get_controller()
	return self._controller
end

function MenuManager:safefile_manager_active_changed(active)
	if self._controller then
		if active then
			self._controller:disable()
		else
			self._controller:enable()
		end
	end

	if not active then
		if self._delayed_open_savefile_menu_callback then
			self._delayed_open_savefile_menu_callback()
		end

		if self._save_game_callback then
			self._save_game_callback()
		end
	end
end

function MenuManager:destroy_controller()
	if self._controller then
		self._controller:destroy()

		self._controller = nil
	end
end

function MenuManager:activate()
	if #self._open_menus == 1 then
		managers.rumble:set_enabled(false)
		self._active_changed_callback_handler:dispatch(true)

		self._active = true

		managers.menu_component:_voice_panel_align_bottom_right()
	end
end

function MenuManager:deactivate()
	if #self._open_menus == 0 then
		managers.rumble:set_enabled(managers.user:get_setting("rumble"))
		self._active_changed_callback_handler:dispatch(false)

		self._active = false

		managers.menu_component:_voice_panel_align_mid_right()
	end
end

function MenuManager:is_active()
	return self._active
end

function MenuManager:add_active_changed_callback(callback_func)
	self._active_changed_callback_handler:add(callback_func)
end

function MenuManager:remove_active_changed_callback(callback_func)
	self._active_changed_callback_handler:remove(callback_func)
end

function MenuManager:brightness_changed(name, old_value, new_value)
	local brightness = math.clamp(new_value, _G.tweak_data.menu.MIN_BRIGHTNESS, _G.tweak_data.menu.MAX_BRIGHTNESS)

	Application:set_brightness(brightness)

	RenderSettings.brightness = brightness
end

function MenuManager:effect_quality_changed(name, old_value, new_value)
	World:effect_manager():set_quality(new_value)
end

function MenuManager:set_mouse_sensitivity(zoomed)
	local sense_x, sense_y = nil

	if zoomed then
		sense_x = managers.user:get_setting("camera_zoom_sensitivity_x")
		sense_y = managers.user:get_setting("camera_zoom_sensitivity_y")
	else
		sense_x = managers.user:get_setting("camera_sensitivity_x")
		sense_y = managers.user:get_setting("camera_sensitivity_y")
	end

	local multiplier = Vector3()

	mvector3.set_x(multiplier, sense_x * self._look_multiplier.x)
	mvector3.set_y(multiplier, sense_y * self._look_multiplier.y)
	self._controller:get_setup():get_connection("look"):set_multiplier(multiplier)
	managers.controller:rebind_connections()
end

function MenuManager:camera_sensitivity_x_changed(name, old_value, new_value)
	local setup = self._controller:get_setup()
	local look_connection = setup:get_connection("look")
	local look_multiplier = Vector3()

	mvector3.set(look_multiplier, look_connection:get_multiplier())
	mvector3.set_x(look_multiplier, self._look_multiplier.x * new_value)
	look_connection:set_multiplier(look_multiplier)
	managers.controller:rebind_connections()

	if alive(managers.player:player_unit()) then
		local plr_state = managers.player:player_unit():movement():current_state()
		local weapon_id = alive(plr_state._equipped_unit) and plr_state._equipped_unit:base():get_name_id()
		local stances = tweak_data.player.stances[weapon_id] or tweak_data.player.stances.default

		self:set_mouse_sensitivity(plr_state:in_steelsight() and stances.steelsight.zoom_fov)
	else
		self:set_mouse_sensitivity(false)
	end
end

function MenuManager:camera_sensitivity_y_changed(name, old_value, new_value)
	local setup = self._controller:get_setup()
	local look_connection = setup:get_connection("look")
	local look_multiplier = Vector3()

	mvector3.set(look_multiplier, look_connection:get_multiplier())
	mvector3.set_y(look_multiplier, self._look_multiplier.y * new_value)
	look_connection:set_multiplier(look_multiplier)
	managers.controller:rebind_connections()

	if alive(managers.player:player_unit()) then
		local plr_state = managers.player:player_unit():movement():current_state()
		local weapon_id = alive(plr_state._equipped_unit) and plr_state._equipped_unit:base():get_name_id()
		local stances = tweak_data.player.stances[weapon_id] or tweak_data.player.stances.default

		self:set_mouse_sensitivity(plr_state:in_steelsight() and stances.steelsight.zoom_fov)
	else
		self:set_mouse_sensitivity(false)
	end
end

function MenuManager:rumble_changed(name, old_value, new_value)
	managers.rumble:set_enabled(new_value)
end

function MenuManager:invert_camera_x_changed(name, old_value, new_value)
	local setup = self._controller:get_setup()
	local look_connection = setup:get_connection("look")
	local look_inversion = look_connection:get_inversion_unmodified()

	if new_value then
		look_inversion = look_inversion:with_x(-1)
	else
		look_inversion = look_inversion:with_x(1)
	end

	look_connection:set_inversion(look_inversion)
	managers.controller:rebind_connections()
end

function MenuManager:invert_camera_y_changed(name, old_value, new_value)
	local setup = self._controller:get_setup()
	local look_connection = setup:get_connection("look")
	local look_inversion = look_connection:get_inversion_unmodified()

	if new_value then
		look_inversion = look_inversion:with_y(-1)
	else
		look_inversion = look_inversion:with_y(1)
	end

	look_connection:set_inversion(look_inversion)
	managers.controller:rebind_connections()
end

function MenuManager:southpaw_changed(name, old_value, new_value)
	if self._controller.TYPE ~= "xb1" and self._controller.TYPE ~= "ps4" then
		return
	end

	local setup = self._controller:get_setup()
	local look_connection = setup:get_connection("look")
	local move_connection = setup:get_connection("move")
	local drive_connection = setup:get_connection("drive")
	local look_input_name_list = look_connection:get_input_name_list()
	local move_input_name_list = move_connection:get_input_name_list()
	local drive_input_name_list = drive_connection:get_input_name_list()

	if Application:production_build() then
		local got_input_left = 0
		local got_input_right = 0

		for _, input_name in ipairs(look_input_name_list) do
			if input_name == "left" then
				got_input_left = got_input_left + 1
			elseif input_name == "right" then
				got_input_right = got_input_right + 1
			else
				Application:error("[MenuManager:southpaw_changed] Active controller got some other input other than left and right on look!", input_name)
			end
		end

		for _, input_name in ipairs(move_input_name_list) do
			if input_name == "left" then
				got_input_left = got_input_left + 1
			elseif input_name == "right" then
				got_input_right = got_input_right + 1
			else
				Application:error("[MenuManager:southpaw_changed] Active controller got some other input other than left and right on move!", input_name)
			end
		end

		if got_input_left ~= 1 or got_input_right ~= 1 then
			Application:error("[MenuManager:southpaw_changed] Controller look and move are not bound as expected", "got_input_left: " .. tostring(got_input_left), "got_input_right: " .. tostring(got_input_right), "look_input_name_list: " .. inspect(look_input_name_list), "move_input_name_list: " .. inspect(move_input_name_list))
		end
	end

	if new_value then
		move_connection:set_input_name_list({
			"right"
		})
		look_connection:set_input_name_list({
			"left"
		})

		drive_connection._btn_connections.turn_left.name = "right"
		drive_connection._btn_connections.turn_right.name = "right"
	else
		move_connection:set_input_name_list({
			"left"
		})
		look_connection:set_input_name_list({
			"right"
		})

		drive_connection._btn_connections.turn_left.name = "left"
		drive_connection._btn_connections.turn_right.name = "left"
	end

	managers.controller:rebind_connections()
end

function MenuManager:ssao_setting_changed(name, old_value, new_value)
	managers.environment_controller:set_ssao_setting(new_value)
end

function MenuManager:motion_blur_setting_changed(name, old_value, new_value)
	managers.environment_controller:set_motion_blur_setting(new_value)
end

function MenuManager:volumetric_light_scatter_setting_changed(name, old_value, new_value)
	managers.environment_controller:set_volumetric_light_scatter_setting(new_value)
end

function MenuManager:AA_setting_changed(name, old_value, new_value)
	managers.environment_controller:set_AA_setting(new_value)
end

function MenuManager:colorblind_setting_changed(name, old_value, new_value)
	managers.environment_controller:set_colorblind_mode(new_value)
end

function MenuManager:detail_distance_setting_changed(name, old_value, new_value)
	managers.user:set_setting("detail_distance", new_value)

	local min_maps = 0.0003
	local max_maps = 0.02
	local maps = math.lerp(max_maps, min_maps, new_value)

	Application:debug("MenuManager:on_value_change_detail_distance was/now/maps", old_value, new_value, maps)
	World:set_min_allowed_projected_size(maps)
end

function MenuManager:use_parallax_setting_changed(name, old_value, new_value)
	managers.environment_controller:set_parallax_setting(new_value)
end

function MenuManager:dof_setting_changed(name, old_value, new_value)
	managers.environment_controller:set_dof_setting(new_value)
end

function MenuManager:iconography_ammo_changed(name, old_value, new_value)
	local player = managers.player:local_player()

	if alive(player) then
		player:inventory():recreate_weapon_panels()
	end
end

function MenuManager:fps_limit_changed(name, old_value, new_value)
	if not IS_PC then
		return
	end

	setup:set_fps_cap(new_value)
end

function MenuManager:net_packet_throttling_changed(name, old_value, new_value)
	if managers.network then
		managers.network:set_packet_throttling_enabled(new_value)
	end
end

function MenuManager:net_forwarding_changed(name, old_value, new_value)
	print("[Network:set_forwarding_enabled]", new_value)
	Network:set_forwarding_enabled(new_value)
end

function MenuManager:net_use_compression_changed(name, old_value, new_value)
	Network:set_use_compression(new_value)
end

function MenuManager:use_thq_weapon_parts_changed(name, old_value, new_value)
	if managers.weapon_factory then
		managers.weapon_factory:set_use_thq_weapon_parts(managers.user:get_setting("use_thq_weapon_parts"))
	end

	if not game_state_machine or game_state_machine:current_state_name() ~= "menu_main" then
		return
	end

	if managers.network and managers.network:session() then
		for _, peer in ipairs(managers.network:session():peers()) do
			peer:force_reload_outfit()
		end
	end
end

function MenuManager:subtitle_changed(name, old_value, new_value)
	managers.subtitle:set_visible(new_value)
end

function MenuManager:music_volume_changed(name, old_value, new_value)
	local tweak = _G.tweak_data.menu
	local percentage = (new_value - tweak.MIN_MUSIC_VOLUME) / (tweak.MAX_MUSIC_VOLUME - tweak.MIN_MUSIC_VOLUME)

	managers.music:set_volume(percentage)
end

function MenuManager:sfx_volume_changed(name, old_value, new_value)
	local tweak = _G.tweak_data.menu
	local percentage = (new_value - tweak.MIN_SFX_VOLUME) / (tweak.MAX_SFX_VOLUME - tweak.MIN_SFX_VOLUME)

	SoundDevice:set_rtpc("option_sfx_volume", percentage * 100)
	managers.video:volume_changed(percentage)
end

function MenuManager:voice_volume_changed(name, old_value, new_value)
	if managers.network and managers.network.voice_chat then
		managers.network.voice_chat:set_volume(new_value)
	end
end

function MenuManager:voice_over_volume_changed(name, old_value, new_value)
	local tweak = _G.tweak_data.menu

	SoundDevice:set_rtpc("option_vo_volume", new_value)
end

function MenuManager:master_volume_changed(name, old_value, new_value)
	local tweak = _G.tweak_data.menu

	SoundDevice:set_rtpc("option_master_volume", new_value)
end

function MenuManager:set_debug_menu_enabled(enabled)
	self._debug_menu_enabled = enabled
end

function MenuManager:debug_menu_enabled()
	if Application:production_build() then
		return true
	else
		return false
	end
end

function MenuManager:add_back_button(new_node)
	new_node:delete_item("back")

	local params = {
		visible_callback = "is_pc_controller",
		previous_node = true,
		back = true,
		text_id = "menu_back",
		name = "back"
	}
	local new_item = new_node:create_item(nil, params)

	new_node:add_item(new_item)
end

function MenuManager:reload()
	self:_recompile(managers.database:root_path() .. "assets\\guis\\")
end

function MenuManager:_recompile(dir)
	local source_files = self:_source_files(dir)
	local t = {
		source_files = nil,
		source_root = nil,
		verbose = false,
		send_idstrings = false,
		target_db_name = "all",
		platform = nil,
		target_db_root = nil,
		platform = string.lower(SystemInfo:platform():s()),
		source_root = managers.database:root_path() .. "/assets",
		target_db_root = Application:base_path() .. "assets",
		source_files = source_files
	}

	Application:data_compile(t)
	DB:reload()
	managers.database:clear_all_cached_indices()

	for _, file in ipairs(source_files) do
		PackageManager:reload(managers.database:entry_type(file):id(), managers.database:entry_path(file):id())
	end
end

function MenuManager:_source_files(dir)
	local files = {}
	local entry_path = managers.database:entry_path(dir) .. "/"

	for _, file in ipairs(SystemFS:list(dir)) do
		table.insert(files, entry_path .. file)
	end

	for _, sub_dir in ipairs(SystemFS:list(dir, true)) do
		for _, file in ipairs(SystemFS:list(dir .. "/" .. sub_dir)) do
			table.insert(files, entry_path .. sub_dir .. "/" .. file)
		end
	end

	return files
end

function MenuManager:progress_resetted()
	local dialog_data = {
		title = "Dr Evil",
		text = "HAHA, your progress is gone!"
	}
	local no_button = {
		text = "Doh!",
		callback_func = callback(self, self, "_dialog_progress_resetted_ok")
	}
	dialog_data.button_list = {
		no_button
	}

	managers.system_menu:show(dialog_data)
end

function MenuManager:_dialog_progress_resetted_ok()
end

function MenuManager:open_sign_in_menu(cb)
	if IS_PS4 then
		managers.network.matchmake:register_callback("found_game", callback(self, self, "_cb_matchmake_found_game"))
		managers.network.matchmake:register_callback("player_joined", callback(self, self, "_cb_matchmake_player_joined"))

		if PSN:is_fetching_status() then
			self:show_fetching_status_dialog()

			local function f()
				self:open_ps4_sign_in_menu(cb)
			end

			PSN:set_matchmaking_callback("fetch_status", f)
			PSN:fetch_status()
		else
			self:open_ps4_sign_in_menu(cb)
		end
	elseif IS_XB1 then
		self._queued_privilege_check_cb = nil

		managers.system_menu:close("fetching_status")

		if managers.network.account:signin_state() == "signed in" then
			if managers.user:check_privilege(nil, "multiplayer_sessions", callback(self, self, "_check_privilege_callback")) then
				self:show_fetching_status_dialog()

				self._queued_privilege_check_cb = cb
			else
				self:show_err_not_signed_in_dialog()
			end
		else
			self:show_err_not_signed_in_dialog()
		end
	elseif managers.network.account:signin_state() == "signed in" then
		cb(true)
	else
		self:show_err_not_signed_in_dialog()
	end
end

function MenuManager:_check_privilege_callback(is_success)
	if self._queued_privilege_check_cb then
		local cb = self._queued_privilege_check_cb

		managers.system_menu:close("fetching_status")

		self._queued_privilege_check_cb = nil

		if is_success then
			self:open_xb1_sign_in_menu(cb)
		else
			self:show_err_not_signed_in_dialog()
		end
	end
end

function MenuManager:open_ps4_sign_in_menu(cb)
	if managers.system_menu:is_active_by_id("fetching_status") then
		managers.system_menu:close("fetching_status")
	end

	local success = true

	if PSN:needs_update() then
		Global.boot_invite = nil
		Global.boot_play_together = nil
		success = false

		self:show_err_new_patch()
	elseif not PSN:cable_connected() then
		self:show_internet_connection_required()

		success = false
	elseif managers.network.account:signin_state() == "not signed in" then
		if managers.network.account:signin_state() == "signed in" then
			print("SIGNED IN")

			if #PSN:get_world_list() == 0 then
				managers.network.matchmake:getting_world_list()
			end

			success = self:_enter_online_menus_ps4()
		else
			success = false
		end
	elseif PSN:parental_control_settings_active() then
		Global.boot_invite = nil
		Global.boot_play_together = nil
		success = false

		self:show_err_under_age()
	else
		if #PSN:get_world_list() == 0 then
			managers.network.matchmake:getting_world_list()
			PSN:init_matchmaking()
		end

		success = self:_enter_online_menus_ps4()
	end

	cb(success)
end

function MenuManager:open_xb1_sign_in_menu(cb)
	self.xb1_cb = cb

	managers.user:check_privilege(nil, "communications", false, false, callback(self, self, "check_voice_chat_sign_in_callback"))
end

function MenuManager:check_voice_chat_sign_in_callback(is_success)
	if not is_success then
		if self:active_menu() and self:active_menu().callback_handler then
			self:active_menu().callback_handler:toggle_voicechat_raid(false)
		end

		managers.menu:show_voice_chat_blocked_dialog(callback(self, self, "open_xb1_sign_in_menu_after_voice_check"))
	elseif self.xb1_cb then
		local success = self:_enter_online_menus_xb1()

		self.xb1_cb(success)
	end
end

function MenuManager:open_xb1_sign_in_menu_after_voice_check()
	if self.xb1_cb then
		local success = self:_enter_online_menus_xb1()

		self.xb1_cb(success)
	end
end

function MenuManager:external_enter_online_menus()
	if IS_PS4 then
		self:_enter_online_menus_ps4()
	elseif IS_XB1 then
		self:_enter_online_menus_xb1()
	end
end

function MenuManager:_enter_online_menus_ps4()
	if PSN:parental_control_settings_active() then
		Global.boot_invite = nil
		Global.boot_play_together = nil

		self:show_err_under_age()

		return false
	else
		local res = PSN:check_plus()

		if res == 1 then
			managers.platform:set_presence("Signed_in")
			print("voice chat from enter_online_menus")
			managers.network.voice_chat:check_status_information()

			if PSN:is_online() and not PSN:online_chat_allowed() then
				managers.menu:show_err_no_chat_parental_control()
			end

			PSN:set_online_callback(callback(self, self, "psn_disconnect"))

			return true
		elseif res ~= 2 then
			self:show_err_not_signed_in_dialog()
		end
	end

	return false
end

function MenuManager:_enter_online_menus_xb1()
	managers.platform:set_presence("Signed_in")
	managers.user:on_entered_online_menus()

	return true
end

function MenuManager:psn_disconnected()
	if managers.network:session() then
		managers.network:queue_stop_network()
		managers.platform:set_presence("Idle")
		managers.network.matchmake:leave_game()
		managers.network.friends:psn_disconnected()
		managers.network.voice_chat:destroy_voice(true)
		self:exit_online_menues()
	end

	self:show_mp_disconnected_internet_dialog({
		ok_func = nil
	})
end

function MenuManager:steam_disconnected()
	if managers.network:session() then
		managers.network:queue_stop_network()
		managers.platform:set_presence("Idle")
		managers.network.matchmake:leave_game()
		managers.network.voice_chat:destroy_voice(true)
		self:exit_online_menues()
	end

	self:show_mp_disconnected_internet_dialog({
		ok_func = nil
	})
end

function MenuManager:xbox_disconnected()
	print("xbox_disconnected()")

	if managers.network:session() or managers.user:is_online_menu() then
		managers.network:queue_stop_network()
		managers.platform:set_presence("Idle")
		managers.network.matchmake:leave_game()
		managers.network.voice_chat:destroy_voice(true)
	end

	self:exit_online_menues()
	managers.user:on_exit_online_menus()
	self:show_mp_disconnected_internet_dialog({
		ok_func = nil
	})
end

function MenuManager:psn_disconnect(connected)
	if not connected then
		managers.network:queue_stop_network()
		managers.platform:set_presence("Idle")
		managers.network.matchmake:leave_game()
		managers.network.matchmake:psn_disconnected()
		managers.network.friends:psn_disconnected()
		managers.network.voice_chat:destroy_voice(true)
		managers.menu:hide_loading_screen()
		managers.system_menu:close("fetching_status")
		self:show_disconnect_message(true)
	end
end

function MenuManager:show_disconnect_message(requires_signin)
	if self._showing_disconnect_message then
		return
	end

	self:exit_online_menues()

	self._showing_disconnect_message = true

	self:show_mp_disconnected_internet_dialog({
		ok_func = nil,
		ok_func = function ()
			self._showing_disconnect_message = nil
		end
	})
end

function MenuManager:created_lobby()
	Global.game_settings.single_player = false

	managers.network:host_game()
	Network:set_multiplayer(true)
	Network:set_server()
	self:on_enter_lobby()
end

function MenuManager:exit_online_menues()
	managers.system_menu:force_close_all()

	Global.controller_manager.connect_controller_dialog_visible = nil

	self:_close_lobby_menu_components()

	if self:active_menu() then
		self:close_menu(self:active_menu().name)
	end

	self:open_menu("menu_main")

	if not managers.menu:is_pc_controller() then
		-- Nothing
	end
end

function MenuManager:leave_online_menu()
	if IS_PS4 then
		PSN:set_online_callback(callback(self, self, "refresh_player_profile_gui"))
	end

	if IS_XB1 then
		managers.user:on_exit_online_menus()
	end
end

function MenuManager:refresh_player_profile_gui()
	if managers.menu_component then
		managers.menu_component:refresh_player_profile_gui()
	end
end

function MenuManager:_close_lobby_menu_components()
end

function MenuManager:on_leave_lobby()
	local skip_destroy_matchmaking = IS_PS4

	managers.network:prepare_stop_network(skip_destroy_matchmaking)

	if IS_XB1 then
		managers.user:on_exit_online_menus()
	end

	managers.platform:set_rich_presence("InMenus")
	managers.menu:close_menu("menu_main")
	managers.menu:open_menu("menu_main")
	managers.network.matchmake:leave_game()
	managers.network.voice_chat:destroy_voice()
	self:_close_lobby_menu_components()
	managers.raid_job:deactivate_current_job()
end

function MenuManager:show_global_success(node)
	local node_gui = nil

	if not node then
		local stack = managers.menu:active_menu().renderer._node_gui_stack
		node_gui = stack[#stack]

		if not node_gui.set_mini_info then
			print("No mini info to set!")

			return
		end
	end

	if not managers.network.account.get_win_ratio then
		if node_gui then
			node_gui:set_mini_info("")
		end

		return
	end

	local rate = managers.network.account:get_win_ratio(Global.game_settings.difficulty, Global.game_settings.level_id)

	if not rate then
		if node_gui then
			node_gui:set_mini_info("")
		end

		return
	end

	rate = rate * 100
	local rate_str = nil

	if rate >= 10 then
		rate_str = string.format("%.0f", rate)
	else
		rate_str = string.format("%.1f", rate)
	end

	local diff_str = string.upper(managers.localization:text("menu_difficulty_" .. Global.game_settings.difficulty))
	local heist_str = string.upper(managers.localization:text(tweak_data.levels[Global.game_settings.level_id].name_id))
	rate_str = managers.localization:text("menu_global_success", {
		HEIST = nil,
		COUNT = nil,
		DIFFICULTY = nil,
		COUNT = rate_str,
		HEIST = heist_str,
		DIFFICULTY = diff_str
	})

	if node then
		node.mini_info = rate_str
	else
		node_gui:set_mini_info(rate_str)
	end
end

function MenuManager:on_storage_changed(old_user_data, user_data)
	if old_user_data and old_user_data.storage_id and user_data and user_data.signin_state ~= "not_signed_in" and not old_user_data.has_signed_out and managers.user:get_platform_id() == user_data.platform_id and not IS_XB1 then
		self:show_storage_removed_dialog()
		print("!!!!!!!!!!!!!!!!!!! STORAGE LOST")
		managers.savefile:break_loading_sequence()

		if game_state_machine:current_state().on_storage_changed then
			game_state_machine:current_state():on_storage_changed(old_user_data, user_data)
		end
	end
end

function MenuManager:on_user_changed(old_user_data, user_data)
	if old_user_data and (old_user_data.signin_state ~= "not_signed_in" or not old_user_data.username) then
		print("MenuManager:on_user_changed(), clear save data")

		if game_state_machine:current_state().on_user_changed then
			game_state_machine:current_state():on_user_changed(old_user_data, user_data)
		end

		self:reset_all_loaded_data()
	end
end

function MenuManager:reset_all_loaded_data()
	self:do_clear_progress()
	managers.user:reset_setting_map()
	managers.statistics:reset()
	managers.achievment:on_user_signout()
end

function MenuManager:do_clear_progress()
	managers.skilltree:reset()
	managers.experience:reset()
	managers.blackmarket:reset()
	managers.dlc:on_reset_profile()
	managers.mission:on_reset_profile()
	managers.raid_job:cleanup()
	managers.user:set_setting("mask_set", "clowns")

	if IS_PC then
		managers.statistics:publish_level_to_steam()
	end
end

function MenuManager:on_user_sign_out()
	print("MenuManager:on_user_sign_out()")

	if managers.network:session() then
		managers.network:queue_stop_network()
		managers.platform:set_presence("Idle")

		if managers.network:session():_local_peer_in_lobby() then
			managers.network.matchmake:leave_game()
		else
			managers.network.matchmake:destroy_game()
		end

		managers.network.voice_chat:destroy_voice(true)
	end
end

MenuUpgrades = MenuUpgrades or class()

function MenuUpgrades:modify_node(node, up, ...)
	local new_node = up and node or deep_clone(node)
	local tree = new_node:parameters().tree
	local first_locked = true

	for i, upgrade_id in ipairs(tweak_data.upgrades.progress[tree]) do
		local title = managers.upgrades:title(upgrade_id) or managers.upgrades:name(upgrade_id)
		local subtitle = managers.upgrades:subtitle(upgrade_id)
		local params = {
			text_id = nil,
			upgrade_id = nil,
			localize = "false",
			tree = nil,
			topic_text = nil,
			step = nil,
			name = nil,
			step = i,
			tree = tree,
			name = upgrade_id,
			upgrade_id = upgrade_id,
			text_id = string.upper(title and subtitle or title),
			topic_text = subtitle and title and string.upper(title)
		}

		if managers.upgrades:is_locked(i) and first_locked then
			first_locked = false

			new_node:add_item(new_node:create_item({
				type = "MenuItemUpgrade"
			}, {
				localize = "false",
				upgrade_lock = true,
				text_id = nil,
				name = "upgrade_lock",
				text_id = managers.localization:text("menu_upgrades_locked", {
					LEVEL = nil,
					LEVEL = managers.upgrades:get_level_from_step(i)
				})
			}))
		end

		local new_item = new_node:create_item({
			type = "MenuItemUpgrade"
		}, params)

		new_node:add_item(new_item)
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

InviteFriendsPSN = InviteFriendsPSN or class()

function InviteFriendsPSN:modify_node(node, up)
	local new_node = up and node or deep_clone(node)

	local function f2(friends)
		managers.menu:active_menu().logic:refresh_node("invite_friends", true, friends)
	end

	managers.network.friends:register_callback("get_friends_done", f2)
	managers.network.friends:register_callback("status_change", function ()
	end)
	managers.network.friends:get_friends(new_node)

	return new_node
end

function InviteFriendsPSN:refresh_node(node, friends)
	for i, friend in ipairs(friends) do
		if i < 103 then
			local name = tostring(friend._name)
			local signin_status = friend._signin_status
			local item = node:item(name)

			if not item then
				local params = {
					callback = "invite_friend",
					signin_status = nil,
					localize = "false",
					friend = nil,
					text_id = nil,
					name = nil,
					name = name,
					friend = friend._id,
					text_id = utf8.to_upper(friend._name),
					signin_status = signin_status
				}
				local new_item = node:create_item({
					type = "MenuItemFriend"
				}, params)

				node:add_item(new_item)
			elseif item:parameters().signin_status ~= signin_status then
				item:parameters().signin_status = signin_status
			end
		end
	end

	return node
end

function InviteFriendsPSN:update_node(node)
	if self._update_friends_t and Application:time() < self._update_friends_t then
		return
	end

	self._update_friends_t = Application:time() + 2

	managers.network.friends:get_friends()
end

InviteFriendsSTEAM = InviteFriendsSTEAM or class()

function InviteFriendsSTEAM:modify_node(node, up)
	return node
end

function InviteFriendsSTEAM:refresh_node(node, friend)
	return node
end

function InviteFriendsSTEAM:update_node(node)
end

PauseMenu = PauseMenu or class()

function PauseMenu:modify_node(node)
	local item = node:item("restart_vote")

	if item then
		item:set_enabled(managers.vote:available())
		item:set_parameter("help_id", managers.vote:help_text() or "")
	end

	if managers.vote:is_restarting() then
		item = node:item("restart_level")

		if item then
			item:set_enabled(false)
		end
	end

	return node
end

function PauseMenu:refresh_node(node)
	return self:modify_node(node)
end

KickPlayer = KickPlayer or class()

function KickPlayer:modify_node(node, up)
	node:clean_items()

	if managers.network:session() then
		for _, peer in pairs(managers.network:session():peers()) do
			local params = {
				to_upper = false,
				help_id = nil,
				localize = false,
				localize_help = false,
				peer = nil,
				rpc = nil,
				callback = "kick_player",
				text_id = nil,
				name = nil,
				name = peer:name(),
				text_id = peer:name() .. " (" .. (peer:level() or "") .. ")",
				rpc = peer:rpc(),
				peer = peer,
				help_id = peer:is_host() and managers.localization:text("menu_vote_kick_is_host") or managers.vote:option_vote_kick() and managers.vote:help_text() or ""
			}
			local new_item = node:create_item(nil, params)

			if peer:is_host() or managers.vote:option_vote_kick() and not managers.vote:available() then
				new_item:set_enabled(false)
			end

			node:add_item(new_item)
		end
	end

	managers.menu:add_back_button(node)

	return node
end

function KickPlayer:refresh_node(node)
	return self:modify_node(node)
end

MutePlayer = MutePlayer or class()

function MutePlayer:modify_node(node, up)
	local new_node = deep_clone(node)

	if managers.network:session() then
		for _, peer in pairs(managers.network:session():peers()) do
			local params = {
				to_upper = false,
				peer = nil,
				rpc = nil,
				callback = "mute_player",
				localize = "false",
				text_id = nil,
				name = nil,
				name = peer:name(),
				text_id = peer:name() .. (peer:level() or "") .. ")",
				rpc = peer:rpc(),
				peer = peer
			}
			local data = {
				{
					x = 24,
					_meta = "option",
					s_y = 24,
					s_h = 24,
					s_w = 24,
					y = 0,
					s_x = 24,
					s_icon = "ui/main_menu/textures/debug_menu_tickbox",
					h = 24,
					w = 24,
					value = "on",
					icon = "ui/main_menu/textures/debug_menu_tickbox"
				},
				{
					x = 0,
					_meta = "option",
					s_y = 24,
					s_h = 24,
					s_w = 24,
					y = 0,
					s_x = 0,
					s_icon = "ui/main_menu/textures/debug_menu_tickbox",
					h = 24,
					w = 24,
					value = "off",
					icon = "ui/main_menu/textures/debug_menu_tickbox"
				},
				type = "CoreMenuItemToggle.ItemToggle"
			}
			local new_item = node:create_item(data, params)

			new_item:set_value(peer:is_muted() and "on" or "off")
			new_node:add_item(new_item)
		end
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

MutePlayerXB1 = MutePlayerXB1 or class()

function MutePlayerXB1:modify_node(node, up)
	local new_node = deep_clone(node)

	if managers.network:session() then
		for _, peer in pairs(managers.network:session():peers()) do
			local params = {
				to_upper = false,
				peer = nil,
				rpc = nil,
				callback = "mute_xb1_player",
				localize = "false",
				xuid = nil,
				text_id = nil,
				name = nil,
				name = peer:name(),
				text_id = peer:name(),
				rpc = peer:rpc(),
				peer = peer,
				xuid = peer:xuid()
			}
			local data = {
				{
					x = 24,
					_meta = "option",
					s_y = 24,
					s_h = 24,
					s_w = 24,
					y = 0,
					s_x = 24,
					s_icon = "ui/main_menu/textures/debug_menu_tickbox",
					h = 24,
					w = 24,
					value = "on",
					icon = "ui/main_menu/textures/debug_menu_tickbox"
				},
				{
					x = 0,
					_meta = "option",
					s_y = 24,
					s_h = 24,
					s_w = 24,
					y = 0,
					s_x = 0,
					s_icon = "ui/main_menu/textures/debug_menu_tickbox",
					h = 24,
					w = 24,
					value = "off",
					icon = "ui/main_menu/textures/debug_menu_tickbox"
				},
				type = "CoreMenuItemToggle.ItemToggle"
			}
			local new_item = node:create_item(data, params)

			new_item:set_value(peer:is_muted() and "on" or "off")
			new_node:add_item(new_item)
		end
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

MutePlayerPS4 = MutePlayerPS4 or class()

function MutePlayerPS4:modify_node(node, up)
	local new_node = deep_clone(node)

	if managers.network:session() then
		for _, peer in pairs(managers.network:session():peers()) do
			local params = {
				to_upper = false,
				peer = nil,
				rpc = nil,
				callback = "mute_ps4_player",
				localize = "false",
				text_id = nil,
				name = nil,
				name = peer:name(),
				text_id = peer:name(),
				rpc = peer:rpc(),
				peer = peer
			}
			local data = {
				{
					x = 24,
					_meta = "option",
					s_y = 24,
					s_h = 24,
					s_w = 24,
					y = 0,
					s_x = 24,
					s_icon = "ui/main_menu/textures/debug_menu_tickbox",
					h = 24,
					w = 24,
					value = "on",
					icon = "ui/main_menu/textures/debug_menu_tickbox"
				},
				{
					x = 0,
					_meta = "option",
					s_y = 24,
					s_h = 24,
					s_w = 24,
					y = 0,
					s_x = 0,
					s_icon = "ui/main_menu/textures/debug_menu_tickbox",
					h = 24,
					w = 24,
					value = "off",
					icon = "ui/main_menu/textures/debug_menu_tickbox"
				},
				type = "CoreMenuItemToggle.ItemToggle"
			}
			local new_item = node:create_item(data, params)

			new_item:set_value(peer:is_muted() and "on" or "off")
			new_node:add_item(new_item)
		end
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

ViewGamerCard = ViewGamerCard or class()

function ViewGamerCard:modify_node(node, up)
	local new_node = deep_clone(node)

	if managers.network:session() then
		for _, peer in pairs(managers.network:session():peers()) do
			local params = {
				to_upper = false,
				callback = "view_gamer_card",
				localize = "false",
				xuid = nil,
				text_id = nil,
				name = nil,
				name = peer:name(),
				text_id = peer:name(),
				xuid = peer:xuid()
			}
			local new_item = node:create_item(nil, params)

			new_node:add_item(new_item)
		end
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

MenuPSNHostBrowser = MenuPSNHostBrowser or class()

function MenuPSNHostBrowser:modify_node(node, up)
	local new_node = up and node or deep_clone(node)

	return new_node
end

function MenuPSNHostBrowser:update_node(node)
	if #PSN:get_world_list() == 0 then
		return
	end

	managers.network.matchmake:start_search_lobbys(managers.network.matchmake:searching_friends_only())
end

function MenuPSNHostBrowser:add_filter(node)
	if node:item("difficulty_filter") then
		return
	end

	local params = {
		callback = "choice_difficulty_filter_ps4",
		filter = true,
		help_id = "menu_diff_filter_help",
		visible_callback = "is_ps4",
		text_id = "menu_diff_filter",
		name = "difficulty_filter"
	}
	local data_node = {
		{
			value = 0,
			_meta = "option",
			text_id = "menu_all"
		},
		{
			value = 1,
			_meta = "option",
			text_id = "menu_difficulty_1"
		},
		{
			value = 2,
			_meta = "option",
			text_id = "menu_difficulty_2"
		},
		{
			value = 3,
			_meta = "option",
			text_id = "menu_difficulty_3"
		},
		{
			value = 4,
			_meta = "option",
			text_id = "menu_difficulty_4"
		},
		type = "MenuItemMultiChoice"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(managers.network.matchmake:difficulty_filter())
	node:add_item(new_item)
end

function MenuPSNHostBrowser:refresh_node(node, info_list, friends_only)
	local new_node = node

	if not friends_only then
		self:add_filter(new_node)
	end

	if not info_list then
		return new_node
	end

	local dead_list = {}

	for _, item in ipairs(node:items()) do
		if not item:parameters().filter then
			dead_list[item:parameters().name] = true
		end
	end

	for _, info in ipairs(info_list) do
		local room_list = info.room_list
		local attribute_list = info.attribute_list

		for i, room in ipairs(room_list) do
			local name_str = tostring(room.owner_id)
			local friend_str = room.friend_id and tostring(room.friend_id)
			local attributes_numbers = attribute_list[i].numbers

			if managers.network.matchmake:is_server_ok(friends_only, room.owner_id, attributes_numbers) then
				dead_list[name_str] = nil
				local host_name = name_str
				local level_id = attributes_numbers and tweak_data.levels:get_level_name_from_index(attributes_numbers[1] % 1000)
				local name_id = level_id and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id or "N/A"
				local level_name = name_id and managers.localization:text(name_id) or "LEVEL NAME ERROR"
				local difficulty = attributes_numbers and tweak_data:index_to_difficulty(attributes_numbers[2]) or "N/A"
				local state_string_id = attributes_numbers and tweak_data:index_to_server_state(attributes_numbers[4]) or nil
				local state_name = state_string_id and managers.localization:text("menu_lobby_server_state_" .. state_string_id) or "N/A"
				local state = attributes_numbers or "N/A"
				local item = new_node:item(name_str)
				local num_plrs = attributes_numbers and attributes_numbers[8] or 1

				if not item then
					local params = {
						host_name = nil,
						real_level_name = nil,
						callback = "connect_to_lobby",
						columns = nil,
						room_id = nil,
						num_plrs = nil,
						state = nil,
						localize = "false",
						state_name = nil,
						level_id = nil,
						difficulty = nil,
						level_name = nil,
						text_id = nil,
						name = nil,
						name = name_str,
						text_id = name_str,
						room_id = room.room_id,
						columns = {
							string.upper(friend_str or host_name),
							string.upper(level_name),
							string.upper(state_name),
							tostring(num_plrs) .. "/4 "
						},
						level_name = level_id or "N/A",
						real_level_name = level_name,
						level_id = level_id,
						state_name = state_name,
						difficulty = difficulty,
						host_name = host_name,
						state = state,
						num_plrs = num_plrs
					}
					local new_item = new_node:create_item({
						type = "ItemServerColumn"
					}, params)

					new_node:add_item(new_item)
				else
					if item:parameters().real_level_name ~= level_name then
						item:parameters().columns[2] = string.upper(level_name)
						item:parameters().level_name = level_id
						item:parameters().level_id = level_id
						item:parameters().real_level_name = level_name
					end

					if item:parameters().state ~= state then
						item:parameters().columns[3] = state_name
						item:parameters().state = state
						item:parameters().state_name = state_name
					end

					if item:parameters().difficulty ~= difficulty then
						item:parameters().difficulty = difficulty
					end

					if item:parameters().room_id ~= room.room_id then
						item:parameters().room_id = room.room_id
					end

					if item:parameters().num_plrs ~= num_plrs then
						item:parameters().num_plrs = num_plrs
						item:parameters().columns[4] = tostring(num_plrs) .. "/4 "
					end
				end
			end
		end
	end

	for name, _ in pairs(dead_list) do
		new_node:delete_item(name)
	end

	return new_node
end

MenuSTEAMHostBrowser = MenuSTEAMHostBrowser or class()

function MenuSTEAMHostBrowser:modify_node(node, up)
	local new_node = up and node or deep_clone(node)

	return new_node
end

function MenuSTEAMHostBrowser:update_node(node)
	managers.network.matchmake:search_lobby(managers.network.matchmake:search_friends_only())
end

function MenuSTEAMHostBrowser:add_filter(node)
	if node:item("server_filter") then
		return
	end

	local params = {
		callback = "choice_distance_filter",
		filter = true,
		help_id = "menu_dist_filter_help",
		visible_callback = "is_pc_controller",
		text_id = "menu_dist_filter",
		name = "server_filter"
	}
	local data_node = {
		{
			value = 0,
			_meta = "option",
			text_id = "menu_dist_filter_close"
		},
		{
			value = 1,
			_meta = "option",
			text_id = "menu_dist_filter_default"
		},
		{
			value = 2,
			_meta = "option",
			text_id = "menu_dist_filter_far"
		},
		{
			value = 3,
			_meta = "option",
			text_id = "menu_dist_filter_worldwide"
		},
		type = "MenuItemMultiChoice"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(managers.network.matchmake:distance_filter())
	node:add_item(new_item)

	local params = {
		callback = "choice_difficulty_filter",
		filter = true,
		help_id = "menu_diff_filter_help",
		visible_callback = "is_pc_controller",
		text_id = "menu_diff_filter",
		name = "difficulty_filter"
	}
	local data_node = {
		{
			value = 0,
			_meta = "option",
			text_id = "menu_all"
		},
		{
			value = 1,
			_meta = "option",
			text_id = "menu_difficulty_easy"
		},
		{
			value = 2,
			_meta = "option",
			text_id = "menu_difficulty_normal"
		},
		{
			value = 3,
			_meta = "option",
			text_id = "menu_difficulty_hard"
		},
		{
			value = 4,
			_meta = "option",
			text_id = "menu_difficulty_overkill"
		},
		type = "MenuItemMultiChoice"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(managers.network.matchmake:difficulty_filter())
	node:add_item(new_item)
end

function MenuSTEAMHostBrowser:refresh_node(node, info, friends_only)
	local new_node = node

	if not friends_only then
		self:add_filter(new_node)
	end

	if not info then
		managers.menu:add_back_button(new_node)

		return new_node
	end

	local room_list = info.room_list
	local attribute_list = info.attribute_list
	local dead_list = {}

	for _, item in ipairs(node:items()) do
		if not item:parameters().back and not item:parameters().filter and not item:parameters().pd2_corner then
			dead_list[item:parameters().room_id] = true
		end
	end

	for i, room in ipairs(room_list) do
		local name_str = tostring(room.owner_name)
		local attributes_numbers = attribute_list[i].numbers

		if managers.network.matchmake:is_server_ok(friends_only, room.owner_id, attributes_numbers) then
			dead_list[room.room_id] = nil
			local host_name = name_str
			local level_id = tweak_data.levels:get_level_name_from_index(attributes_numbers[1] % 1000)
			local name_id = level_id and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id
			local level_name = name_id and managers.localization:text(name_id) or "LEVEL NAME ERROR"
			local difficulty = tweak_data:index_to_difficulty(attributes_numbers[2])
			local state_string_id = tweak_data:index_to_server_state(attributes_numbers[4])
			local state_name = state_string_id and managers.localization:text("menu_lobby_server_state_" .. state_string_id) or "blah"
			local state = attributes_numbers[4]
			local num_plrs = attributes_numbers[5]
			local item = new_node:item(room.room_id)

			if not item then
				print("ADD", name_str)

				local params = {
					host_name = nil,
					real_level_name = nil,
					callback = "connect_to_lobby",
					columns = nil,
					room_id = nil,
					num_plrs = nil,
					state = nil,
					localize = "false",
					state_name = nil,
					level_id = nil,
					difficulty = nil,
					level_name = nil,
					text_id = nil,
					name = nil,
					name = room.room_id,
					text_id = name_str,
					room_id = room.room_id,
					columns = {
						utf8.to_upper(host_name),
						utf8.to_upper(level_name),
						utf8.to_upper(state_name),
						tostring(num_plrs) .. "/4 "
					},
					level_name = level_id,
					real_level_name = level_name,
					level_id = level_id,
					state_name = state_name,
					difficulty = difficulty,
					host_name = host_name,
					state = state,
					num_plrs = num_plrs
				}
				local new_item = new_node:create_item({
					type = "ItemServerColumn"
				}, params)

				new_node:add_item(new_item)
			else
				if item:parameters().real_level_name ~= level_name then
					item:parameters().columns[2] = utf8.to_upper(level_name)
					item:parameters().level_name = level_id
					item:parameters().level_id = level_id
					item:parameters().real_level_name = level_name
				end

				if item:parameters().state ~= state then
					item:parameters().columns[3] = state_name
					item:parameters().state = state
					item:parameters().state_name = state_name
				end

				if item:parameters().difficulty ~= difficulty then
					item:parameters().difficulty = difficulty
				end

				if item:parameters().room_id ~= room.room_id then
					item:parameters().room_id = room.room_id
				end

				if item:parameters().num_plrs ~= num_plrs then
					item:parameters().num_plrs = num_plrs
					item:parameters().columns[4] = tostring(num_plrs) .. "/4 "
				end
			end
		end
	end

	for name, _ in pairs(dead_list) do
		new_node:delete_item(name)
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

MenuLANHostBrowser = MenuLANHostBrowser or class()

function MenuLANHostBrowser:modify_node(node, up)
	local new_node = up and node or deep_clone(node)

	return new_node
end

function MenuLANHostBrowser:refresh_node(node)
	local new_node = node
	local hosts = managers.network:session():discovered_hosts()

	for _, host_data in ipairs(hosts) do
		local host_rpc = host_data.rpc
		local name_str = host_data.host_name .. ", " .. host_rpc:to_string()
		local level_id = tweak_data.levels:get_level_name_from_world_name(host_data.level_name)
		local name_id = level_id and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id
		local level_name = name_id and managers.localization:text(name_id) or host_data.level_name
		local state_name = host_data.state == 1 and managers.localization:text("menu_lobby_server_state_in_lobby") or managers.localization:text("menu_lobby_server_state_in_game")
		local item = new_node:item(name_str)

		if not item then
			local params = {
				host_name = nil,
				real_level_name = nil,
				rpc = nil,
				columns = nil,
				localize = "false",
				callback = "connect_to_host_rpc",
				state = nil,
				state_name = nil,
				level_id = nil,
				difficulty = nil,
				level_name = nil,
				text_id = nil,
				name = nil,
				name = name_str,
				text_id = name_str,
				columns = {
					string.upper(host_data.host_name),
					string.upper(level_name),
					string.upper(state_name)
				},
				rpc = host_rpc,
				level_name = host_data.level_name,
				real_level_name = level_name,
				level_id = level_id,
				state_name = state_name,
				difficulty = host_data.difficulty,
				host_name = host_data.host_name,
				state = host_data.state
			}
			local new_item = new_node:create_item({
				type = "ItemServerColumn"
			}, params)

			new_node:add_item(new_item)
		else
			if item:parameters().real_level_name ~= level_name then
				item:parameters().columns[2] = string.upper(level_name)
				item:parameters().level_name = host_data.level_name
				item:parameters().real_level_name = level_name
			end

			if item:parameters().state ~= host_data.state then
				item:parameters().columns[3] = state_name
				item:parameters().state = host_data.state
			end

			if item:parameters().difficulty ~= host_data.difficulty then
				item:parameters().difficulty = host_data.difficulty
			end
		end
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

MenuMPHostBrowser = MenuMPHostBrowser or class()

function MenuMPHostBrowser:modify_node(node, up)
	local new_node = up and node or deep_clone(node)

	managers.menu:add_back_button(new_node)

	return new_node
end

function MenuMPHostBrowser:refresh_node(node)
	local new_node = node
	local hosts = managers.network:session():discovered_hosts()
	local j = 1

	for _, host_data in ipairs(hosts) do
		local host_rpc = host_data.rpc
		local name_str = host_data.host_name .. ", " .. host_rpc:to_string()
		local level_id = tweak_data.levels:get_level_name_from_world_name(host_data.level_name)
		local name_id = level_id and tweak_data.levels[level_id] and tweak_data.levels[level_id].name_id
		local level_name = name_id and managers.localization:text(name_id) or host_data.level_name
		local state_name = host_data.state == 1 and managers.localization:text("menu_lobby_server_state_in_lobby") or managers.localization:text("menu_lobby_server_state_in_game")
		local item = new_node:item(name_str)

		if not item then
			local params = {
				host_name = nil,
				real_level_name = nil,
				rpc = nil,
				columns = nil,
				localize = "false",
				callback = "connect_to_host_rpc",
				state = nil,
				state_name = nil,
				level_id = nil,
				difficulty = nil,
				level_name = nil,
				text_id = nil,
				name = nil,
				name = name_str,
				text_id = name_str,
				columns = {
					string.upper(host_data.host_name),
					string.upper(level_name),
					string.upper(state_name)
				},
				rpc = host_rpc,
				level_name = host_data.level_name,
				real_level_name = level_name,
				level_id = level_id,
				state_name = state_name,
				difficulty = host_data.difficulty,
				host_name = host_data.host_name,
				state = host_data.state
			}
			local new_item = new_node:create_item({
				type = "ItemServerColumn"
			}, params)

			new_node:add_item(new_item)
		else
			if item:parameters().real_level_name ~= level_name then
				print("Update level_name - ", level_name)

				item:parameters().columns[2] = string.upper(level_name)
				item:parameters().level_name = host_data.level_name
				item:parameters().real_level_name = level_name
			end

			if item:parameters().state ~= host_data.state then
				item:parameters().columns[3] = state_name
				item:parameters().state = host_data.state
			end

			if item:parameters().difficulty ~= host_data.difficulty then
				item:parameters().difficulty = host_data.difficulty
			end
		end

		j = j + 1
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

MenuResolutionCreator = MenuResolutionCreator or class()

function MenuResolutionCreator:modify_node(node)
	local new_node = deep_clone(node)

	if IS_PC then
		local resolutions = {}

		for _, res in ipairs(RenderSettings.modes) do
			table.insert(resolutions, res)
		end

		table.sort(resolutions)

		for _, res in ipairs(resolutions) do
			local res_string = string.format("%d x %d, %dHz", res.x, res.y, res.z)

			if not new_node:item(res_string) then
				local params = {
					resolution = nil,
					icon = "guis/textures/scrollarrow",
					icon_visible_callback = "is_current_resolution",
					callback = "change_resolution",
					localize = "false",
					icon_rotation = 90,
					text_id = nil,
					name = nil,
					name = res_string,
					text_id = res_string,
					resolution = res
				}
				local new_item = new_node:create_item(nil, params)

				new_node:add_item(new_item)
			end
		end
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

MenuSoundCreator = MenuSoundCreator or class()

function MenuSoundCreator:modify_node(node)
	local music_item = node:item("music_volume")

	if music_item then
		music_item:set_min(_G.tweak_data.menu.MIN_MUSIC_VOLUME)
		music_item:set_max(_G.tweak_data.menu.MAX_MUSIC_VOLUME)
		music_item:set_step(_G.tweak_data.menu.MUSIC_CHANGE)
		music_item:set_value(managers.user:get_setting("music_volume"))
	end

	local sfx_item = node:item("sfx_volume")

	if sfx_item then
		sfx_item:set_min(_G.tweak_data.menu.MIN_SFX_VOLUME)
		sfx_item:set_max(_G.tweak_data.menu.MAX_SFX_VOLUME)
		sfx_item:set_step(_G.tweak_data.menu.SFX_CHANGE)
		sfx_item:set_value(managers.user:get_setting("sfx_volume"))
	end

	local voice_item = node:item("voice_volume")

	if voice_item then
		voice_item:set_min(_G.tweak_data.menu.MIN_VOICE_VOLUME)
		voice_item:set_max(_G.tweak_data.menu.MAX_VOICE_VOLUME)
		voice_item:set_step(_G.tweak_data.menu.VOICE_CHANGE)
		voice_item:set_value(managers.user:get_setting("voice_volume"))
	end

	local option_value = "on"
	local st_item = node:item("toggle_voicechat")

	if st_item then
		if not managers.user:get_setting("voice_chat") then
			option_value = "off"
		end

		st_item:set_value(option_value)
	end

	option_value = "on"
	local st_item = node:item("toggle_push_to_talk")

	if st_item then
		if not managers.user:get_setting("push_to_talk") then
			option_value = "off"
		end

		st_item:set_value(option_value)
	end

	return node
end

function MenuSoundCreator:refresh_node(node)
	self:modify_node(node)
end

function MenuManager.refresh_level_select(node, verify_dlc_owned)
	if verify_dlc_owned and tweak_data.levels[Global.game_settings.level_id].dlc then
		local dlcs = string.split(managers.dlc:dlcs_string(), " ")

		if not table.contains(dlcs, tweak_data.levels[Global.game_settings.level_id].dlc) then
			Global.game_settings.level_id = "bank"
		end
	end

	local min_difficulty = 0

	for _, item in ipairs(node:items()) do
		local level_id = item:parameter("level_id")

		if level_id then
			if level_id == Global.game_settings.level_id then
				min_difficulty = tonumber(item:parameter("difficulty"))
			elseif item:visible() then
				-- Nothing
			end
		end
	end

	local diff = min_difficulty < tweak_data:difficulty_to_index(Global.game_settings.difficulty) and Global.game_settings.difficulty or tweak_data:index_to_difficulty(min_difficulty)

	tweak_data:set_difficulty(diff)

	local item_difficulty = node:item("lobby_difficulty")

	if item_difficulty then
		for i, option in ipairs(item_difficulty:options()) do
			option:parameters().exclude = tonumber(option:parameters().difficulty) < min_difficulty
		end

		item_difficulty:set_value(Global.game_settings.difficulty)
	end

	local lobby_mission_item = node:item("lobby_mission")
	local mission_data = tweak_data.levels[Global.game_settings.level_id].mission_data

	if lobby_mission_item then
		print("lobby_mission_item")

		local params = {
			localize = "false",
			callback = "choice_lobby_mission",
			text_id = "menu_choose_mission",
			name = "lobby_mission"
		}
		local data_node = {
			type = "MenuItemMultiChoice"
		}

		if mission_data then
			for _, data in ipairs(mission_data) do
				table.insert(data_node, {
					localize = false,
					_meta = "option",
					text_id = nil,
					value = nil,
					text_id = data.mission,
					value = data.mission
				})
			end
		else
			table.insert(data_node, {
				localize = false,
				_meta = "option",
				text_id = "none",
				value = "none"
			})
		end

		lobby_mission_item:init(data_node, params)
		lobby_mission_item:set_callback_handler(MenuCallbackHandler:new())
		lobby_mission_item:set_value(data_node[1].value)
	end

	Global.game_settings.mission = mission_data and mission_data[1] and mission_data[1].mission or "none"
end

MenuPSNPlayerProfileInitiator = MenuPSNPlayerProfileInitiator or class()

function MenuPSNPlayerProfileInitiator:modify_node(node)
	if IS_PS4 and not managers.network:session() then
		PSN:set_online_callback(callback(managers.menu, managers.menu, "refresh_player_profile_gui"))
	end

	return node
end

GlobalSuccessRateInitiator = GlobalSuccessRateInitiator or class()

function GlobalSuccessRateInitiator:modify_node(node)
	managers.menu:show_global_success(node)

	return node
end

LobbyOptionInitiator = LobbyOptionInitiator or class()

function LobbyOptionInitiator:modify_node(node)
	MenuManager.refresh_level_select(node, Network:is_server())

	local item_permission_campaign = node:item("lobby_permission")

	if item_permission_campaign then
		item_permission_campaign:set_value(Global.game_settings.permission)
	end

	local item_lobby_toggle_drop_in = node:item("toggle_drop_in")

	if item_lobby_toggle_drop_in then
		item_lobby_toggle_drop_in:set_value(Global.game_settings.drop_in_allowed and "on" or "off")
	end

	local item_lobby_toggle_ai = node:item("toggle_ai")

	if item_lobby_toggle_ai then
		item_lobby_toggle_ai:set_value(Global.game_settings.team_ai and "on" or "off")
	end

	local character_item = node:item("choose_character")

	if character_item then
		local value = managers.network:session() and managers.network:session():local_peer():character() or "random"

		character_item:set_value(value)
	end

	local reputation_permission_item = node:item("lobby_reputation_permission")

	if reputation_permission_item then
		print("reputation_permission_item", "set value", Global.game_settings.reputation_permission, type_name(Global.game_settings.reputation_permission))
		reputation_permission_item:set_value(Global.game_settings.reputation_permission)
	end

	local item_lobby_job_plan = node:item("lobby_job_plan")

	if item_lobby_job_plan then
		item_lobby_job_plan:set_value(Global.game_settings.job_plan or -1)
	end

	local item_lobby_job_custom_text = node:item("lobby_job_custom_text")

	if item_lobby_job_custom_text then
		item_lobby_job_custom_text:set_value(Global.game_settings.custom_text or "")
	end

	return node
end

VerifyLevelOptionInitiator = VerifyLevelOptionInitiator or class()

function VerifyLevelOptionInitiator:modify_node(node)
	MenuManager.refresh_level_select(node, true)

	return node
end

MenuCustomizeControllerCreator = MenuCustomizeControllerCreator or class()
MenuCustomizeControllerCreator.CONTROLS = {
	"move",
	"primary_attack",
	"secondary_attack",
	"primary_choice2",
	"primary_choice1",
	"primary_choice3",
	"primary_choice4",
	"switch_weapon",
	"reload",
	"weapon_firemode",
	"run",
	"jump",
	"duck",
	"melee",
	"interact",
	"comm_wheel",
	"comm_wheel_yes",
	"comm_wheel_no",
	"comm_wheel_found_it",
	"comm_wheel_wait",
	"comm_wheel_not_here",
	"comm_wheel_follow_me",
	"comm_wheel_assistance",
	"comm_wheel_enemy",
	"activate_warcry",
	"use_item",
	"toggle_chat",
	"toggle_hud",
	"push_to_talk",
	"drive",
	"hand_brake",
	"vehicle_rear_camera",
	"vehicle_shooting_stance",
	"vehicle_exit",
	"vehicle_change_seat"
}
MenuCustomizeControllerCreator.AXIS_ORDERED = {
	move = nil,
	drive = nil,
	move = {
		"up",
		"down",
		"left",
		"right"
	},
	drive = {
		"accelerate",
		"brake",
		"turn_left",
		"turn_right"
	}
}
MenuCustomizeControllerCreator.CONTROLS_INFO = {
	move = {
		category = "normal",
		hidden = true,
		type = "movement"
	},
	up = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_forward"
	},
	down = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_back"
	},
	left = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_left"
	},
	right = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_move_right"
	},
	primary_attack = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_fire_weapon"
	},
	secondary_attack = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_aim_down_sight"
	},
	primary_choice1 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot1"
	},
	primary_choice2 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot2"
	},
	primary_choice3 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot3"
	},
	primary_choice4 = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_slot4"
	},
	switch_weapon = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_switch_weapon"
	},
	reload = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_reload"
	},
	run = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_sprint"
	},
	jump = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_jump"
	},
	duck = {
		category = "normal",
		type = "movement",
		text_id = "menu_button_crouch"
	},
	melee = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_melee"
	},
	interact = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_shout"
	},
	use_item = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_deploy"
	},
	toggle_chat = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_chat_message"
	},
	push_to_talk = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_push_to_talk"
	},
	continue = {
		text_id = "menu_button_continue",
		category = "normal"
	},
	weapon_firemode = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_weapon_firemode"
	},
	cash_inspect = {
		text_id = "menu_button_cash_inspect",
		category = "normal"
	},
	deploy_bipod = {
		text_id = "menu_button_deploy_bipod",
		category = "normal"
	},
	comm_wheel = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel"
	},
	comm_wheel_yes = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_yes"
	},
	comm_wheel_no = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_no"
	},
	comm_wheel_found_it = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_found_it"
	},
	comm_wheel_wait = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_wait"
	},
	comm_wheel_not_here = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_not_here"
	},
	comm_wheel_follow_me = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_follow_me"
	},
	comm_wheel_assistance = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_assistance"
	},
	comm_wheel_enemy = {
		category = "normal",
		type = "communication",
		text_id = "menu_button_comm_wheel_enemy"
	},
	activate_warcry = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_activate_warcry"
	},
	toggle_hud = {
		category = "normal",
		type = "usage",
		text_id = "menu_button_toggle_hud"
	},
	drive = {
		category = "vehicle",
		hidden = true,
		type = "movement"
	},
	accelerate = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_accelerate"
	},
	brake = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_brake"
	},
	turn_left = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_turn_left"
	},
	turn_right = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_turn_right"
	},
	hand_brake = {
		category = "vehicle",
		type = "movement",
		text_id = "menu_button_handbrake"
	},
	vehicle_rear_camera = {
		category = "vehicle",
		type = "usage",
		text_id = "menu_button_vehicle_rear_camera"
	},
	vehicle_shooting_stance = {
		category = "vehicle",
		block = nil,
		text_id = "menu_button_vehicle_shooting_stance",
		type = "usage",
		block = {
			"normal"
		}
	},
	vehicle_exit = {
		category = "vehicle",
		type = "usage",
		text_id = "menu_button_vehicle_exit"
	},
	vehicle_change_seat = {
		category = "vehicle",
		type = "usage",
		text_id = "menu_button_vehicle_change_seat"
	}
}

function MenuCustomizeControllerCreator.controls_info_by_category(category)
	local t = {}

	for _, name in ipairs(MenuCustomizeControllerCreator.CONTROLS) do
		if MenuCustomizeControllerCreator.CONTROLS_INFO[name].category == category then
			table.insert(t, name)
		end
	end

	return t
end

function MenuCustomizeControllerCreator:modify_node(original_node, data)
	local node = original_node

	return self:setup_node(node)
end

function MenuCustomizeControllerCreator:refresh_node(node)
	self:setup_node(node)

	return node
end

function MenuCustomizeControllerCreator:setup_node(node)
	local new_node = node
	local controller_category = node:parameters().controller_category or "normal"

	node:clean_items()

	local params = {
		callback = "choice_controller_type",
		text_id = "menu_controller_type",
		name = "controller_type"
	}
	local data_node = {
		type = "MenuItemMultiChoice"
	}

	table.insert(data_node, {
		value = "normal",
		_meta = "option",
		text_id = "menu_controller_normal"
	})
	table.insert(data_node, {
		value = "vehicle",
		_meta = "option",
		text_id = "menu_controller_vehicle"
	})

	local new_item = node:create_item(data_node, params)

	new_item:set_value(controller_category)

	local connections = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()

	for _, name in ipairs(self.controls_info_by_category(controller_category)) do
		local name_id = name
		local connection = connections[name]

		if connection._btn_connections then
			local ordered = self.AXIS_ORDERED[name]

			for _, btn_name in ipairs(ordered) do
				local btn_connection = connection._btn_connections[btn_name]

				if btn_connection then
					local name_id = name
					local params = {
						binding = nil,
						connection_name = nil,
						axis = nil,
						button = nil,
						localize = "false",
						text_id = nil,
						name = nil,
						name = btn_name,
						connection_name = name,
						text_id = utf8.to_upper(managers.localization:text(self.CONTROLS_INFO[btn_name].text_id)),
						binding = btn_connection.name,
						axis = connection._name,
						button = btn_name
					}
					local new_item = new_node:create_item({
						type = "MenuItemCustomizeController"
					}, params)

					new_node:add_item(new_item)
				end
			end
		else
			local params = {
				binding = nil,
				connection_name = nil,
				button = nil,
				localize = "false",
				text_id = nil,
				name = nil,
				name = name_id,
				connection_name = name,
				text_id = utf8.to_upper(managers.localization:text(self.CONTROLS_INFO[name].text_id)),
				binding = connection:get_input_name_list()[1],
				button = name
			}
			local new_item = new_node:create_item({
				type = "MenuItemCustomizeController"
			}, params)

			new_node:add_item(new_item)
		end
	end

	local params = {
		category = nil,
		callback = "set_default_controller",
		text_id = "menu_set_default_controller",
		name = "set_default_controller",
		category = controller_category
	}
	local new_item = new_node:create_item(nil, params)

	new_node:add_item(new_item)
	managers.menu:add_back_button(new_node)

	return new_node
end

MenuOptionInitiator = MenuOptionInitiator or class()

function MenuOptionInitiator:modify_node(node)
	local node_name = node:parameters().name

	if node_name == "resolution" then
		return self:modify_resolution(node)
	elseif node_name == "video" then
		return self:modify_video(node)
	elseif node_name == "adv_video" then
		return self:modify_adv_video(node)
	elseif node_name == "controls" then
		return self:modify_controls(node)
	elseif node_name == "debug" then
		return self:modify_debug_options(node)
	elseif node_name == "debug_camp" then
		return self:modify_debug_options(node)
	elseif node_name == "debug_ingame" then
		return self:modify_debug_options(node)
	elseif node_name == "options" then
		return self:modify_options(node)
	elseif node_name == "network_options" then
		return self:modify_network_options(node)
	end
end

function MenuOptionInitiator:refresh_node(node)
	self:modify_node(node)
end

function MenuOptionInitiator:modify_resolution(node)
	if IS_PC then
		local res_name = string.format("%d x %d, %dHz", RenderSettings.resolution.x, RenderSettings.resolution.y, RenderSettings.resolution.z)

		node:set_default_item_name(res_name)
	end

	return node
end

function MenuOptionInitiator:modify_adv_video(node)
	node:item("toggle_vsync"):set_value(RenderSettings.v_sync and "on" or "off")

	if node:item("choose_streaks") then
		node:item("choose_streaks"):set_value(managers.user:get_setting("video_streaks") and "on" or "off")
	end

	if node:item("choose_light_adaption") then
		node:item("choose_light_adaption"):set_value(managers.user:get_setting("light_adaption") and "on" or "off")
	end

	if node:item("choose_anti_alias") then
		node:item("choose_anti_alias"):set_value(managers.user:get_setting("video_anti_alias"))
	end

	node:item("choose_anim_lod"):set_value(managers.user:get_setting("video_animation_lod"))

	if node:item("choose_color_grading") then
		node:item("choose_color_grading"):set_value(managers.user:get_setting("video_color_grading"))
	end

	node:item("choose_texture_quality"):set_value(RenderSettings.texture_quality_default)
	node:item("choose_shadow_quality"):set_value(RenderSettings.shadow_quality_default)
	node:item("choose_anisotropic"):set_value(RenderSettings.max_anisotropy)

	if node:item("fov_multiplier") then
		node:item("fov_multiplier"):set_value(managers.user:get_setting("fov_multiplier"))
	end

	if node:item("detail_distance") then
		node:item("detail_distance"):set_value(managers.user:get_setting("detail_distance"))
	end

	node:item("choose_fps_cap"):set_value(managers.user:get_setting("fps_cap"))
	node:item("max_streaming_chunk"):set_value(managers.user:get_setting("max_streaming_chunk"))

	if node:item("toggle_use_thq_weapon_parts") then
		node:item("toggle_use_thq_weapon_parts"):set_value(managers.user:get_setting("use_thq_weapon_parts") and "on" or "off")
	end

	local option_value = "off"
	local dof_setting_item = node:item("toggle_dof")

	if dof_setting_item then
		if managers.user:get_setting("dof_setting") ~= "none" then
			option_value = "on"
		end

		dof_setting_item:set_value(option_value)
	end

	local ssao_setting_item = node:item("toggle_ssao")

	if ssao_setting_item then
		option_value = "off"

		if managers.user:get_setting("ssao_setting") ~= "none" then
			option_value = "on"
		end

		ssao_setting_item:set_value(option_value)
	end

	local motion_blur_setting_item = node:item("toggle_motion_blur")

	if motion_blur_setting_item then
		option_value = "off"

		if managers.user:get_setting("motion_blur_setting") ~= "none" then
			option_value = "on"
		end

		motion_blur_setting_item:set_value(option_value)
	end

	local vls_setting_item = node:item("toggle_volumetric_light_scattering")

	if vls_setting_item then
		option_value = "off"

		if managers.user:get_setting("vls_setting") ~= "none" then
			option_value = "on"
		end

		vls_setting_item:set_value(option_value)
	end

	local use_parallax_setting_item = node:item("toggle_parallax")

	if use_parallax_setting_item then
		option_value = "off"

		if managers.user:get_setting("use_parallax") ~= false then
			option_value = "on"
		end

		use_parallax_setting_item:set_value(option_value)
	end

	local AA_setting_item = node:item("choose_AA_quality")

	if AA_setting_item then
		AA_setting_item:set_value(managers.user:get_setting("AA_setting"))
	end

	return node
end

function MenuOptionInitiator:modify_video(node)
	local option_value = "off"
	local fs_item = node:item("toggle_fullscreen")

	if fs_item then
		if managers.viewport:is_fullscreen() then
			option_value = "on"
		end

		fs_item:set_value(option_value)
	end

	option_value = "off"
	local st_item = node:item("toggle_subtitle")

	if st_item then
		if managers.user:get_setting("subtitle") then
			option_value = "on"
		end

		st_item:set_value(option_value)
	end

	local hit_indicator_item = node:item("stepper_hit_indicator")

	if hit_indicator_item then
		hit_indicator_item:set_value(managers.user:get_setting("hit_indicator"))
	end

	local motion_dot_item = node:item("stepper_motion_dot")

	if motion_dot_item then
		motion_dot_item:set_value(managers.user:get_setting("motion_dot"))
	end

	option_value = "off"
	local hud_special_weapon_panels_item = node:item("toggle_hud_special_weapon_panels")

	if hud_special_weapon_panels_item then
		if managers.user:get_setting("hud_special_weapon_panels") then
			option_value = "on"
		end

		hud_special_weapon_panels_item:set_value(option_value)
	end

	option_value = "off"
	local objective_reminder_item = node:item("toggle_objective_reminder")

	if objective_reminder_item then
		if managers.user:get_setting("objective_reminder") then
			option_value = "on"
		end

		objective_reminder_item:set_value(option_value)
	end

	option_value = "off"
	local objective_reminder_item = node:item("use_headbob")

	if objective_reminder_item then
		if managers.user:get_setting("objective_reminder") then
			option_value = "on"
		end

		objective_reminder_item:set_value(option_value)
	end

	local br_item = node:item("brightness")

	if br_item then
		br_item:set_min(_G.tweak_data.menu.MIN_BRIGHTNESS)
		br_item:set_max(_G.tweak_data.menu.MAX_BRIGHTNESS)
		br_item:set_step(_G.tweak_data.menu.BRIGHTNESS_CHANGE)

		option_value = managers.user:get_setting("brightness")

		br_item:set_value(option_value)
	end

	local effect_quality_item = node:item("effect_quality")

	if effect_quality_item then
		option_value = managers.user:get_setting("effect_quality")

		effect_quality_item:set_value(option_value)
	end

	return node
end

function MenuOptionInitiator:modify_controls(node)
	local option_value = "off"
	local rumble_item = node:item("toggle_rumble")

	if rumble_item then
		if managers.user:get_setting("rumble") then
			option_value = "on"
		end

		rumble_item:set_value(option_value)
	end

	option_value = "off"
	local inv_cam_horizontally_item = node:item("toggle_invert_camera_horisontally")

	if inv_cam_horizontally_item then
		if managers.user:get_setting("invert_camera_x") then
			option_value = "on"
		end

		inv_cam_horizontally_item:set_value(option_value)
	end

	option_value = "off"
	local inv_cam_vertically_item = node:item("toggle_invert_camera_vertically")

	if inv_cam_vertically_item then
		if managers.user:get_setting("invert_camera_y") then
			option_value = "on"
		end

		inv_cam_vertically_item:set_value(option_value)
	end

	option_value = "off"
	local southpaw_item = node:item("toggle_southpaw")

	if southpaw_item then
		if managers.user:get_setting("southpaw") then
			option_value = "on"
		end

		southpaw_item:set_value(option_value)
	end

	option_value = "off"
	local hold_to_steelsight_item = node:item("toggle_hold_to_steelsight")

	if hold_to_steelsight_item then
		if managers.user:get_setting("hold_to_steelsight") then
			option_value = "on"
		end

		hold_to_steelsight_item:set_value(option_value)
	end

	option_value = "off"
	local hold_to_run_item = node:item("toggle_hold_to_run")

	if hold_to_run_item then
		if managers.user:get_setting("hold_to_run") then
			option_value = "on"
		end

		hold_to_run_item:set_value(option_value)
	end

	option_value = "off"
	local hold_to_duck_item = node:item("toggle_hold_to_duck")

	if hold_to_duck_item then
		if managers.user:get_setting("hold_to_duck") then
			option_value = "on"
		end

		hold_to_duck_item:set_value(option_value)
	end

	option_value = "off"
	local aim_assist_item = node:item("toggle_aim_assist")

	if aim_assist_item then
		if managers.user:get_setting("aim_assist") then
			option_value = "on"
		end

		aim_assist_item:set_value(option_value)
	end

	option_value = "off"
	local sticky_aim_item = node:item("toggle_sticky_aim")

	if sticky_aim_item then
		if managers.user:get_setting("sticky_aim") then
			option_value = "on"
		end

		sticky_aim_item:set_value(option_value)
	end

	local cs_item = node:item("camera_sensitivity")

	if cs_item then
		cs_item:set_min(tweak_data.player.camera.MIN_SENSITIVITY)
		cs_item:set_max(tweak_data.player.camera.MAX_SENSITIVITY)
		cs_item:set_step((tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 0.1)
		cs_item:set_value(managers.user:get_setting("camera_sensitivity"))
	end

	local czs_item = node:item("camera_zoom_sensitivity")

	if czs_item then
		czs_item:set_min(tweak_data.player.camera.MIN_SENSITIVITY)
		czs_item:set_max(tweak_data.player.camera.MAX_SENSITIVITY)
		czs_item:set_step((tweak_data.player.camera.MAX_SENSITIVITY - tweak_data.player.camera.MIN_SENSITIVITY) * 0.1)
		czs_item:set_value(managers.user:get_setting("camera_zoom_sensitivity"))
	end

	node:item("toggle_zoom_sensitivity"):set_value(managers.user:get_setting("enable_camera_zoom_sensitivity") and "on" or "off")

	return node
end

function MenuOptionInitiator:modify_debug_options(node)
	local option_value = "off"
	local players_item = node:item("toggle_players")

	if players_item then
		players_item:set_value(Global.nr_players)
	end

	local cinematic_mode_item = node:item("toggle_cinematic_mode")

	if cinematic_mode_item then
		local cinematic_mode_value = Global.cinematic_mode and "on" or "off"

		cinematic_mode_item:set_value(cinematic_mode_value)
	end

	local spawn_all_intel_documents_item = node:item("toggle_spawn_all_intel_documents")

	if spawn_all_intel_documents_item then
		local spawn_all_intel_documents_value = Global.spawn_all_intel_documents and "on" or "off"

		spawn_all_intel_documents_item:set_value(spawn_all_intel_documents_value)
	end

	local show_all_intel_documents_item = node:item("toggle_show_all_intel_documents")

	if show_all_intel_documents_item then
		local show_all_intel_documents_value = Global.show_intel_document_positions and "on" or "off"

		show_all_intel_documents_item:set_value(show_all_intel_documents_value)
	end

	local spawn_all_dog_tags_item = node:item("toggle_spawn_all_dog_tags")

	if spawn_all_dog_tags_item then
		local spawn_all_dog_tags_value = Global.spawn_all_dog_tags and "on" or "off"

		spawn_all_dog_tags_item:set_value(spawn_all_dog_tags_value)
	end

	local show_dog_tags_item = node:item("toggle_debug_show_dog_tags")

	if show_dog_tags_item then
		local show_dog_tags_value = Global.debug_show_dog_tags and "on" or "off"

		show_dog_tags_item:set_value(show_dog_tags_value)
	end

	local spawn_all_greed_items_item = node:item("toggle_spawn_all_greed_items")

	if spawn_all_greed_items_item then
		local spawn_all_greed_items_value = Global.spawn_all_greed_items and "on" or "off"

		spawn_all_greed_items_item:set_value(spawn_all_greed_items_value)
	end

	local show_greed_items_item = node:item("toggle_debug_show_greed_items")

	if show_greed_items_item then
		local show_greed_items_value = Global.show_greed_item_positions and "on" or "off"

		show_greed_items_item:set_value(show_greed_items_value)
	end

	local god_mode_item = node:item("toggle_god_mode")

	if god_mode_item then
		local god_mode_value = Global.god_mode and "on" or "off"

		god_mode_item:set_value(god_mode_value)
	end

	local post_effects_item = node:item("toggle_post_effects")

	if post_effects_item then
		local post_effects_value = Global.debug_post_effects_enabled and "on" or "off"

		post_effects_item:set_value(post_effects_value)
	end

	local team_AI_mode_item = node:item("toggle_team_AI")

	if team_AI_mode_item then
		local team_AI_mode_value = managers.groupai:state():team_ai_enabled() and "on" or "off"

		team_AI_mode_item:set_value(team_AI_mode_value)
	end

	local toggle_coordinates_item = node:item("toggle_coordinates")

	if toggle_coordinates_item then
		local toggle_coordinates_value = Global.debug_show_coords and "on" or "off"

		toggle_coordinates_item:set_value(toggle_coordinates_value)
	end

	return node
end

function MenuOptionInitiator:modify_options(node)
	return node
end

function MenuOptionInitiator:modify_network_options(node)
	local toggle_throttling_item = node:item("toggle_throttling")

	if toggle_throttling_item then
		local toggle_throttling_value = managers.user:get_setting("net_packet_throttling") and "on" or "off"

		toggle_throttling_item:set_value(toggle_throttling_value)
	end

	local toggle_net_forwarding_item = node:item("toggle_net_forwarding")

	if toggle_net_forwarding_item then
		local toggle_net_forwarding_value = managers.user:get_setting("net_forwarding") and "on" or "off"

		toggle_net_forwarding_item:set_value(toggle_net_forwarding_value)
	end

	local net_use_compression_item = node:item("toggle_net_use_compression")

	if net_use_compression_item then
		local net_use_compression_value = managers.user:get_setting("net_use_compression") and "on" or "off"

		net_use_compression_item:set_value(net_use_compression_value)
	end

	return node
end

ModMenuCreator = ModMenuCreator or class()

function ModMenuCreator:modify_node(original_node, data)
	local node = original_node

	self:create_mod_menu(node)

	return node
end

function ModMenuCreator:create_mod_menu(node)
	node:clean_items()

	local sorted_mods = {}
	local mods = {}
	local conflicted_content = {}
	local modded_content = {}

	local function id_key(path)
		return Idstring(path):key()
	end

	for mod_name, mod_data in pairs(DB:mods()) do
		table.insert(sorted_mods, mod_name)

		mods[mod_name] = {
			conflicted = nil,
			content = nil,
			content = {},
			conflicted = {}
		}

		for _, path in ipairs(mod_data.files or {}) do
			table.insert(mods[mod_name].content, path)

			modded_content[id_key(path)] = modded_content[id_key(path)] or {}

			table.insert(modded_content[id_key(path)], mod_name)

			if #modded_content[id_key(path)] == 2 then
				conflicted_content[id_key(path)] = modded_content[id_key(path)]
			end
		end

		table.sort(mods[mod_name].content)
	end

	for idk, conflicted_mods in pairs(conflicted_content) do
		for _, mod_name in ipairs(conflicted_mods) do
			mods[mod_name].conflicted[idk] = conflicted_mods
		end
	end

	table.sort(sorted_mods)

	local list_of_mods = {}
	local mod_item = nil

	for _, mod_name in ipairs(sorted_mods) do
		local conflicts = table.size(mods[mod_name].conflicted) > 0
		mod_item = self:create_item(node, {
			row_item_color = nil,
			localize = false,
			hightlight_color = nil,
			enabled = true,
			text_id = nil,
			name = nil,
			name = mod_name,
			text_id = mod_name,
			hightlight_color = conflicts and tweak_data.screen_colors.important_1,
			row_item_color = conflicts and tweak_data.screen_colors.important_2
		})
	end

	self:add_back_button(node)

	node:parameters().mods = mods
	node:parameters().sorted_mods = sorted_mods
	node:parameters().conflicted_content = conflicted_content
	node:parameters().modded_content = modded_content
end

function ModMenuCreator:create_divider(node, id, text_id, size, color)
	local params = {
		color = nil,
		no_text = nil,
		size = nil,
		text_id = nil,
		name = nil,
		name = "divider_" .. id,
		no_text = not text_id,
		text_id = text_id,
		size = size or 8,
		color = color
	}
	local data_node = {
		type = "MenuItemDivider"
	}
	local new_item = node:create_item(data_node, params)

	node:add_item(new_item)
end

function ModMenuCreator:create_item(node, params)
	local data_node = {}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(params.enabled)
	node:add_item(new_item)
end

function ModMenuCreator:create_toggle(node, params)
	local data_node = {
		{
			x = 24,
			_meta = "option",
			s_y = 24,
			s_h = 24,
			s_w = 24,
			y = 0,
			s_x = 24,
			s_icon = "ui/main_menu/textures/debug_menu_tickbox",
			h = 24,
			w = 24,
			value = "on",
			icon = "ui/main_menu/textures/debug_menu_tickbox"
		},
		{
			x = 0,
			_meta = "option",
			s_y = 24,
			s_h = 24,
			s_w = 24,
			y = 0,
			s_x = 0,
			s_icon = "ui/main_menu/textures/debug_menu_tickbox",
			h = 24,
			w = 24,
			value = "off",
			icon = "ui/main_menu/textures/debug_menu_tickbox"
		},
		type = "MenuItemToggleWithIcon"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_enabled(params.enabled)
	node:add_item(new_item)

	return new_item
end

function ModMenuCreator:add_back_button(node)
	node:delete_item("back")

	local params = {
		visible_callback = "is_pc_controller",
		previous_node = true,
		back = true,
		text_id = "menu_back",
		name = "back"
	}
	local new_item = node:create_item(nil, params)

	node:add_item(new_item)
end

function MenuManager:create_menu_item_background(panel, coord_x, coord_y, width, layer)
	local menu_item_background = panel:bitmap({
		visible = true,
		x = nil,
		h = nil,
		y = nil,
		texture_rect = nil,
		layer = nil,
		texture = "ui/main_menu/textures/debug_menu_buttons",
		name = "background_image",
		texture_rect = {
			0,
			14,
			256,
			40
		},
		x = coord_x,
		y = coord_y,
		h = managers.menu.MENU_ITEM_HEIGHT,
		layer = layer
	})

	if width then
		menu_item_background:set_width(width)
	end

	return menu_item_background
end

function MenuManager:get_menu_item_width()
	return managers.gui_data:scaled_size().width / 5 * 2 / 2 + 20
end
