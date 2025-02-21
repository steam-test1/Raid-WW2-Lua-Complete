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
			content_file = "gamedata/raid/menus/start_menu",
			renderer = "MenuRenderer",
			id = "start_menu",
			name = "menu_main",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(menu_main)

		local mission_join_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/mission_join_menu",
			renderer = "MenuRenderer",
			id = "mission_join_menu",
			name = "mission_join_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_join_menu)

		local raid_options_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_options_menu",
			renderer = "MenuRenderer",
			id = "raid_options_menu",
			name = "raid_options_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_options_menu)

		local raid_menu_credits = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/show_credits_menu",
			renderer = "MenuRenderer",
			id = "raid_credits_menu",
			name = "raid_credits_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_credits)

		local raid_menu_options_controls = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_controls",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls",
			name = "raid_menu_options_controls",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls)

		local raid_menu_options_controls_keybinds = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_controls_keybinds",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls_keybinds",
			name = "raid_menu_options_controls_keybinds",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls_keybinds)

		local raid_menu_options_controller_mapping = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_controller_mapping",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controller_mapping",
			name = "raid_menu_options_controller_mapping",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controller_mapping)

		local raid_menu_options_video = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_video",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video",
			name = "raid_menu_options_video",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video)

		local raid_menu_options_video_advanced = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_video_advanced",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video_advanced",
			name = "raid_menu_options_video_advanced",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video_advanced)

		local raid_menu_options_interface = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_interface",
			renderer = "MenuRenderer",
			id = "raid_menu_options_interface",
			name = "raid_menu_options_interface",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_interface)

		local raid_menu_options_sound = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_sound",
			renderer = "MenuRenderer",
			id = "raid_menu_options_sound",
			name = "raid_menu_options_sound",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_sound)

		local raid_menu_options_network = {
			input = "MenuInput",
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
			content_file = "gamedata/raid/menus/mission_join_menu",
			renderer = "MenuRenderer",
			id = "mission_join_menu",
			name = "mission_join_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_join_menu)

		local mission_selection_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/mission_selection_menu",
			renderer = "MenuRenderer",
			id = "mission_selection_menu",
			name = "mission_selection_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_selection_menu)

		local mission_unlock_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/mission_unlock_menu",
			renderer = "MenuRenderer",
			id = "mission_unlock_menu",
			name = "mission_unlock_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(mission_unlock_menu)

		local profile_selection_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/profile_selection_menu",
			renderer = "MenuRenderer",
			id = "profile_selection_menu",
			name = "profile_selection_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(profile_selection_menu)

		local profile_creation_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/profile_creation_menu",
			renderer = "MenuRenderer",
			id = "profile_creation_menu",
			name = "profile_creation_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(profile_creation_menu)

		local character_customization_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/character_customization_menu",
			renderer = "MenuRenderer",
			id = "character_customization_menu",
			name = "character_customization_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(character_customization_menu)

		local raid_main_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_main_menu",
			renderer = "MenuRenderer",
			id = "raid_main_menu",
			name = "raid_main_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_main_menu)

		local raid_options_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_options_menu",
			renderer = "MenuRenderer",
			id = "raid_options_menu",
			name = "raid_options_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_options_menu)

		local challenge_cards_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/challenge_cards_menu",
			renderer = "MenuRenderer",
			id = "challenge_cards_menu",
			name = "challenge_cards_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(challenge_cards_menu)

		local ready_up_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/ready_up_menu",
			renderer = "MenuRenderer",
			id = "ready_up_menu",
			name = "ready_up_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(ready_up_menu)

		local challenge_cards_view_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/challenge_cards_view_menu",
			renderer = "MenuRenderer",
			id = "challenge_cards_view_menu",
			name = "challenge_cards_view_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(challenge_cards_view_menu)

		local raid_experience_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/xp_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_xp",
			name = "raid_menu_xp",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_experience_menu)

		local raid_post_game_breakdown_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/post_game_breakdown",
			renderer = "MenuRenderer",
			id = "raid_menu_post_game_breakdown",
			name = "raid_menu_post_game_breakdown",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_post_game_breakdown_menu)

		local raid_special_honors_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/special_honors",
			renderer = "MenuRenderer",
			id = "raid_menu_special_honors",
			name = "raid_menu_special_honors",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_special_honors_menu)

		local raid_loot_screen_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/loot_screen_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_loot_screen",
			name = "raid_menu_loot_screen",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_loot_screen_menu)

		local raid_greed_loot_screen_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/greed_loot_screen_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_greed_loot_screen",
			name = "raid_menu_greed_loot_screen",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_greed_loot_screen_menu)

		local raid_menu_weapon_select = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/weapon_select_menu",
			renderer = "MenuRenderer",
			id = "raid_menu_weapon_select",
			name = "raid_menu_weapon_select",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_weapon_select)

		local raid_menu_credits = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/show_credits_menu",
			renderer = "MenuRenderer",
			id = "raid_credits_menu",
			name = "raid_credits_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_credits)

		local raid_menu_options_controls = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_controls",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls",
			name = "raid_menu_options_controls",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls)

		local raid_menu_options_controller_mapping = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_controller_mapping",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controller_mapping",
			name = "raid_menu_options_controller_mapping",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controller_mapping)

		local raid_menu_options_controls_keybinds = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_controls_keybinds",
			renderer = "MenuRenderer",
			id = "raid_menu_options_controls_keybinds",
			name = "raid_menu_options_controls_keybinds",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_controls_keybinds)

		local raid_menu_options_video = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_video",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video",
			name = "raid_menu_options_video",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video)

		local raid_menu_options_video_advanced = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_video_advanced",
			renderer = "MenuRenderer",
			id = "raid_menu_options_video_advanced",
			name = "raid_menu_options_video_advanced",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_video_advanced)

		local raid_menu_options_interface = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_interface",
			renderer = "MenuRenderer",
			id = "raid_menu_options_interface",
			name = "raid_menu_options_interface",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_interface)

		local raid_menu_options_sound = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_sound",
			renderer = "MenuRenderer",
			id = "raid_menu_options_sound",
			name = "raid_menu_options_sound",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_sound)

		local raid_menu_options_network = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/raid_menu_options_network",
			renderer = "MenuRenderer",
			id = "raid_menu_options_network",
			name = "raid_menu_options_network",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(raid_menu_options_network)

		local gold_asset_store_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/gold_asset_store_menu",
			renderer = "MenuRenderer",
			id = "gold_asset_store_menu",
			name = "gold_asset_store_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(gold_asset_store_menu)

		local intel_menu = {
			input = "MenuInput",
			content_file = "gamedata/raid/menus/intel_menu",
			renderer = "MenuRenderer",
			id = "intel_menu",
			name = "intel_menu",
			callback_handler = MenuCallbackHandler:new()
		}

		self:register_menu(intel_menu)

		local comic_book_menu = {
			input = "MenuInput",
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
		text_id = "menu_back",
		previous_node = true,
		visible_callback = "is_pc_controller",
		back = true,
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
		verbose = false,
		target_db_name = "all",
		send_idstrings = false,
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
	managers.raid_job:deactivate_current_job()
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

MenuOptionInitiator = MenuOptionInitiator or class()

function MenuOptionInitiator:modify_node(node)
	local node_name = node:parameters().name

	if node_name == "debug" then
		return self:modify_debug_options(node)
	elseif node_name == "debug_camp" then
		return self:modify_debug_options(node)
	elseif node_name == "debug_ingame" then
		return self:modify_debug_options(node)
	end
end

function MenuOptionInitiator:refresh_node(node)
	self:modify_node(node)
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

function MenuManager:create_menu_item_background(panel, coord_x, coord_y, width, layer)
	local menu_item_background = panel:bitmap({
		texture = "ui/main_menu/textures/debug_menu_buttons",
		visible = true,
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
