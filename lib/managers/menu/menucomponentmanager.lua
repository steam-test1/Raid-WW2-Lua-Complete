require("lib/managers/menu/raid_menu/RaidGuiBase")
require("lib/managers/menu/raid_menu/WeaponSelectionGui")
require("lib/managers/menu/raid_menu/CharacterSelectionGui")
require("lib/managers/menu/raid_menu/CharacterCreationGui")
require("lib/managers/menu/raid_menu/CharacterCustomizationGui")
require("lib/managers/menu/raid_menu/ChallengeCardsGui")
require("lib/managers/menu/raid_menu/ChallengeCardsViewGui")
require("lib/managers/menu/raid_menu/ChallengeCardsLootRewardGui")
require("lib/managers/menu/raid_menu/MissionJoinGui")
require("lib/managers/menu/raid_menu/MissionSelectionGui")
require("lib/managers/menu/raid_menu/MissionUnlockGui")
require("lib/managers/menu/raid_menu/RaidMainMenuGui")
require("lib/managers/menu/raid_menu/RaidMenuHeader")
require("lib/managers/menu/raid_menu/RaidMenuFooter")
require("lib/managers/menu/raid_menu/RaidMenuLeftOptions")
require("lib/managers/menu/raid_menu/RaidMenuOptionsControls")
require("lib/managers/menu/raid_menu/RaidMenuOptionsControlsKeybinds")
require("lib/managers/menu/raid_menu/RaidMenuOptionsControlsControllerMapping")
require("lib/managers/menu/raid_menu/RaidMenuOptionsVideo")
require("lib/managers/menu/raid_menu/RaidMenuOptionsVideoAdvanced")
require("lib/managers/menu/raid_menu/RaidMenuOptionsSound")
require("lib/managers/menu/raid_menu/RaidMenuOptionsNetwork")
require("lib/managers/menu/raid_menu/RaidMenuCreditsGui")
require("lib/managers/menu/raid_menu/RaidOptionsBackground")
require("lib/managers/menu/raid_menu/ReadyUpGui")
require("lib/managers/menu/raid_menu/LootScreenGui")
require("lib/managers/menu/raid_menu/GreedLootScreenGui")
require("lib/managers/menu/raid_menu/ExperienceGui")
require("lib/managers/menu/raid_menu/PostGameBreakdownGui")
require("lib/managers/menu/raid_menu/GoldAssetStoreGui")
require("lib/managers/menu/raid_menu/IntelGui")
require("lib/managers/menu/raid_menu/ComicBookGui")
require("lib/managers/menu/raid_menu/SpecialHonorsGui")
require("lib/managers/menu/raid_menu/RaidMenuProfileSwitcher")
require("lib/managers/hud/HUDPlayerVoiceChatStatus")

MenuComponentManager = MenuComponentManager or class()

-- Lines 42-130
function MenuComponentManager:init()
	self._ws = Overlay:gui():create_screen_workspace()
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()

	managers.gui_data:layout_workspace(self._ws)

	self._main_panel = self._ws:panel():panel()
	self._requested_textures = {}
	self._block_texture_requests = false
	self._sound_source = SoundDevice:create_source("MenuComponentManager")
	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
	self._request_done_clbk_func = callback(self, self, "_request_done_callback")
	local is_installing, install_progress = managers.dlc:is_installing()
	self._is_game_installing = is_installing
	self._active_components = {
		raid_menu_mission_selection = {
			create = callback(self, self, "create_raid_menu_mission_selection_gui"),
			close = callback(self, self, "close_raid_menu_mission_selection_gui")
		},
		raid_menu_mission_unlock = {
			create = callback(self, self, "create_raid_menu_mission_unlock_gui"),
			close = callback(self, self, "close_raid_menu_mission_unlock_gui")
		},
		raid_menu_mission_join = {
			create = callback(self, self, "create_raid_menu_mission_join_gui"),
			close = callback(self, self, "close_raid_menu_mission_join_gui")
		},
		raid_menu_weapon_select = {
			create = callback(self, self, "create_raid_menu_weapon_select_gui"),
			close = callback(self, self, "close_raid_menu_weapon_select_gui")
		},
		raid_menu_profile_selection = {
			create = callback(self, self, "create_raid_menu_select_character_profile_gui"),
			close = callback(self, self, "close_raid_menu_select_character_profile_gui")
		},
		raid_menu_profile_creation = {
			create = callback(self, self, "create_raid_menu_create_character_profile_gui"),
			close = callback(self, self, "close_raid_menu_create_character_profile_gui")
		},
		raid_menu_character_customization = {
			create = callback(self, self, "create_raid_menu_character_customization_gui"),
			close = callback(self, self, "close_raid_menu_character_customization_gui")
		},
		raid_menu_main = {
			create = callback(self, self, "create_raid_menu_main_menu_gui"),
			close = callback(self, self, "close_raid_menu_main_menu_gui")
		},
		raid_menu_header = {
			create = callback(self, self, "create_raid_menu_header_gui"),
			close = callback(self, self, "close_raid_menu_header_gui")
		},
		raid_menu_footer = {
			create = callback(self, self, "create_raid_menu_footer_gui"),
			close = callback(self, self, "close_raid_menu_footer_gui")
		},
		raid_menu_left_options = {
			create = callback(self, self, "create_raid_menu_left_options_gui"),
			close = callback(self, self, "close_raid_menu_left_options_gui")
		},
		raid_menu_options_controls = {
			create = callback(self, self, "create_raid_menu_options_controls_gui"),
			close = callback(self, self, "close_raid_menu_options_controls_gui")
		},
		raid_menu_options_controls_keybinds = {
			create = callback(self, self, "create_raid_menu_options_controls_keybinds_gui"),
			close = callback(self, self, "close_raid_menu_options_controls_keybinds_gui")
		},
		raid_menu_options_controller_mapping = {
			create = callback(self, self, "create_raid_menu_options_controller_mapping_gui"),
			close = callback(self, self, "close_raid_menu_options_controller_mapping_gui")
		},
		raid_menu_options_sound = {
			create = callback(self, self, "create_raid_menu_options_sound_gui"),
			close = callback(self, self, "close_raid_menu_options_sound_gui")
		},
		raid_menu_options_network = {
			create = callback(self, self, "create_raid_menu_options_network_gui"),
			close = callback(self, self, "close_raid_menu_options_network_gui")
		},
		raid_menu_options_video = {
			create = callback(self, self, "create_raid_menu_options_video_gui"),
			close = callback(self, self, "close_raid_menu_options_video_gui")
		},
		raid_menu_options_video_advanced = {
			create = callback(self, self, "create_raid_menu_options_video_advanced_gui"),
			close = callback(self, self, "close_raid_menu_options_video_advanced_gui")
		},
		raid_options_background = {
			create = callback(self, self, "create_raid_options_background_gui"),
			close = callback(self, self, "close_raid_options_background_gui")
		},
		raid_menu_ready_up = {
			create = callback(self, self, "create_raid_ready_up_gui"),
			close = callback(self, self, "close_raid_ready_up_gui")
		},
		raid_menu_challenge_cards = {
			create = callback(self, self, "create_raid_challenge_cards_gui"),
			close = callback(self, self, "close_raid_challenge_cards_gui")
		},
		raid_menu_challenge_cards_view = {
			create = callback(self, self, "create_raid_challenge_cards_view_gui"),
			close = callback(self, self, "close_raid_challenge_cards_view_gui")
		},
		raid_menu_challenge_cards_loot_reward = {
			create = callback(self, self, "create_raid_challenge_cards_loot_reward_gui"),
			close = callback(self, self, "close_raid_challenge_cards_loot_reward_gui")
		},
		raid_menu_xp = {
			create = callback(self, self, "create_raid_menu_xp"),
			close = callback(self, self, "close_raid_menu_xp")
		},
		raid_menu_post_game_breakdown = {
			create = callback(self, self, "create_raid_menu_post_game_breakdown"),
			close = callback(self, self, "close_raid_menu_post_game_breakdown")
		},
		raid_menu_special_honors = {
			create = callback(self, self, "create_raid_menu_special_honors"),
			close = callback(self, self, "close_raid_menu_special_honors")
		},
		raid_menu_loot = {
			create = callback(self, self, "create_raid_menu_loot"),
			close = callback(self, self, "close_raid_menu_loot")
		},
		raid_menu_greed_loot = {
			create = callback(self, self, "create_raid_menu_greed_loot"),
			close = callback(self, self, "close_raid_menu_greed_loot")
		},
		raid_menu_gold_asset_store = {
			create = callback(self, self, "create_raid_menu_gold_asset_store_gui"),
			close = callback(self, self, "close_raid_menu_gold_asset_store_gui")
		},
		raid_menu_intel = {
			create = callback(self, self, "create_raid_menu_intel_gui"),
			close = callback(self, self, "close_raid_menu_intel_gui")
		},
		raid_menu_comic_book = {
			create = callback(self, self, "create_raid_menu_comic_book_gui"),
			close = callback(self, self, "close_raid_menu_comic_book_gui")
		},
		raid_menu_credits = {
			create = callback(self, self, "create_raid_menu_credits"),
			close = callback(self, self, "close_raid_menu_credits")
		}
	}
	self._active_controls = {}
	self._update_components = {}
end

-- Lines 132-133
function MenuComponentManager:save(data)
end

-- Lines 135-137
function MenuComponentManager:load(data)
	self:on_whisper_mode_changed()
end

-- Lines 139-140
function MenuComponentManager:on_whisper_mode_changed()
end

-- Lines 142-151
function MenuComponentManager:get_controller_input_bool(button)
	if not managers.menu or not managers.menu:active_menu() then
		return
	end

	local controller = managers.menu:active_menu().input:get_controller_class()

	if managers.menu:active_menu().input:get_accept_input() then
		return controller:get_input_bool(button)
	end
end

-- Lines 153-164
function MenuComponentManager:_setup_controller_input()
	if not self._controller_connected then
		self._left_axis_vector = Vector3()
		self._right_axis_vector = Vector3()

		if managers.menu:active_menu() then
			self._fullscreen_ws:connect_controller(managers.menu:active_menu().input:get_controller(), true)
			self._fullscreen_ws:panel():axis_move(callback(self, self, "_axis_move"))
		end

		self._controller_connected = true
	end
end

-- Lines 166-180
function MenuComponentManager:_destroy_controller_input()
	if self._controller_connected then
		self._fullscreen_ws:disconnect_all_controllers()

		if alive(self._fullscreen_ws:panel()) then
			self._fullscreen_ws:panel():axis_move(nil)
		end

		self._controller_connected = nil

		if _G.IS_PC then
			self._fullscreen_ws:disconnect_keyboard()
			self._fullscreen_ws:panel():key_press(nil)
		end
	end
end

-- Lines 182-184
function MenuComponentManager:saferect_ws()
	return self._ws
end

-- Lines 186-188
function MenuComponentManager:fullscreen_ws()
	return self._fullscreen_ws
end

-- Lines 190-197
function MenuComponentManager:resolution_changed()
	managers.gui_data:layout_workspace(self._ws)
	managers.gui_data:layout_fullscreen_16_9_workspace(self._fullscreen_ws)

	if self._tcst then
		managers.gui_data:layout_fullscreen_16_9_workspace(self._tcst)
	end
end

-- Lines 199-205
function MenuComponentManager:_axis_move(o, axis_name, axis_vector, controller)
	if axis_name == Idstring("left") then
		mvector3.set(self._left_axis_vector, axis_vector)
	elseif axis_name == Idstring("right") then
		mvector3.set(self._right_axis_vector, axis_vector)
	end
end

-- Lines 207-232
function MenuComponentManager:set_active_components(components, node)
	local to_close = {}

	for component, _ in pairs(self._active_components) do
		to_close[component] = true
	end

	for _, component in ipairs(components) do
		local component_data = self._active_components[component]

		if component_data then
			to_close[component] = nil
			local component_object = component_data.create(node, component)
			component_data.component_object = component_object
		end
	end

	for component, _ in pairs(to_close) do
		local component_data = self._active_components[component]

		component_data.close(node, component)

		component_data.component_object = nil
	end

	if not managers.menu:is_pc_controller() then
		self:_setup_controller_input()
	end
end

-- Lines 236-278
function MenuComponentManager:make_color_text(text_object, color)
	local text = text_object:text()
	local text_dissected = utf8.characters(text)
	local idsp = Idstring("#")
	local start_ci = {}
	local end_ci = {}
	local first_ci = true

	for i, c in ipairs(text_dissected) do
		if Idstring(c) == idsp then
			local next_c = text_dissected[i + 1]

			if next_c and Idstring(next_c) == idsp then
				if first_ci then
					table.insert(start_ci, i)
				else
					table.insert(end_ci, i)
				end

				first_ci = not first_ci
			end
		end
	end

	if #start_ci == #end_ci then
		for i = 1, #start_ci do
			start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
			end_ci[i] = end_ci[i] - (i * 4 - 1)
		end
	end

	text = string.gsub(text, "##", "")

	text_object:set_text(text)
	text_object:clear_range_color(1, utf8.len(text))

	if #start_ci ~= #end_ci then
		Application:error("MenuComponentManager:make_color_text: Not even amount of ##'s in text", #start_ci, #end_ci)
	else
		for i = 1, #start_ci do
			text_object:set_range_color(start_ci[i], end_ci[i], color or tweak_data.screen_colors.resource)
		end
	end
end

-- Lines 282-283
function MenuComponentManager:on_job_updated()
end

-- Lines 292-299
function MenuComponentManager:update(t, dt)
	for _, component in pairs(self._update_components) do
		if component then
			component:update(t, dt)
		end
	end
end

-- Lines 301-310
function MenuComponentManager:get_left_controller_axis()
	if managers.menu:is_pc_controller() or not self._left_axis_vector then
		return 0, 0
	end

	local x = mvector3.x(self._left_axis_vector)
	local y = mvector3.y(self._left_axis_vector)

	return x, y
end

-- Lines 312-321
function MenuComponentManager:get_right_controller_axis()
	if managers.menu:is_pc_controller() or not self._right_axis_vector then
		return 0, 0
	end

	local x = mvector3.x(self._right_axis_vector)
	local y = mvector3.y(self._right_axis_vector)

	return x, y
end

-- Lines 325-326
function MenuComponentManager:accept_input(accept)
end

-- Lines 328-332
function MenuComponentManager:input_focus()
	if managers.system_menu and managers.system_menu:is_active() and not managers.system_menu:is_closing() then
		return true
	end
end

-- Lines 334-335
function MenuComponentManager:scroll_up()
end

-- Lines 337-338
function MenuComponentManager:scroll_down()
end

-- Lines 341-353
function MenuComponentManager:move_up()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:move_up()

			if handled then
				return true
			end

			if not handled and target then
				return self:_set_active_control(target)
			end
		end
	end
end

-- Lines 355-367
function MenuComponentManager:move_down()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:move_down()

			if handled then
				return true
			end

			if not handled and target then
				return self:_set_active_control(target)
			end
		end
	end
end

-- Lines 369-381
function MenuComponentManager:move_left()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:move_left()

			if handled then
				return true
			end

			if not handled and target then
				return self:_set_active_control(target)
			end
		end
	end
end

-- Lines 383-390
function MenuComponentManager:_set_active_control(target_control_name)
	for _, active_control in pairs(self._active_controls) do
		if active_control[target_control_name] then
			managers.raid_menu:set_active_control(active_control[target_control_name])
			active_control[target_control_name]:set_selected(true)
		end
	end
end

-- Lines 392-405
function MenuComponentManager:move_right()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:move_right()

			if handled then
				return true
			end

			if not handled and target then
				return self:_set_active_control(target)
			end
		end
	end
end

-- Lines 407-416
function MenuComponentManager:scroll_up()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:scroll_up()

			if handled then
				return true
			end
		end
	end
end

-- Lines 418-427
function MenuComponentManager:scroll_down()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:scroll_down()

			if handled then
				return true
			end
		end
	end
end

-- Lines 429-438
function MenuComponentManager:scroll_left()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:scroll_left()

			if handled then
				return true
			end
		end
	end
end

-- Lines 440-449
function MenuComponentManager:scroll_right()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled, target = component.component_object:scroll_right()

			if handled then
				return true
			end
		end
	end
end

-- Lines 452-463
function MenuComponentManager:next_page()
	if self._game_chat_gui and self._game_chat_gui:input_focus() == true then
		return true
	end

	if self._blackmarket_gui and self._blackmarket_gui:next_page() then
		return true
	end
end

-- Lines 465-476
function MenuComponentManager:previous_page()
	if self._game_chat_gui and self._game_chat_gui:input_focus() == true then
		return true
	end

	if self._blackmarket_gui and self._blackmarket_gui:previous_page() then
		return true
	end
end

-- Lines 479-504
function MenuComponentManager:confirm_pressed()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled = component.component_object:confirm_pressed()

			if handled then
				return true
			end
		end
	end

	if self._game_chat_gui and self._game_chat_gui:input_focus() == true then
		return true
	end

	if self._blackmarket_gui and self._blackmarket_gui:confirm_pressed() then
		return true
	end

	if Application:production_build() and self._debug_font_gui then
		self._debug_font_gui:toggle()
	end
end

-- Lines 506-521
function MenuComponentManager:back_pressed()
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled = component.component_object:back_pressed()

			if handled then
				return true
			end
		end
	end

	if self._game_chat_gui and self._game_chat_gui:input_focus() == true then
		return true
	end
end

-- Lines 523-549
function MenuComponentManager:special_btn_pressed(...)
	for _, component in pairs(self._active_components) do
		if component.component_object and component.component_object.special_btn_pressed then
			local handled, target = component.component_object:special_btn_pressed(...)

			if handled then
				return true
			end

			if not handled and target then
				return self:_set_active_control(target)
			end
		end
	end

	if self._game_chat_gui and self._game_chat_gui:input_focus() == true then
		return true
	end

	if self._game_chat_gui and self._game_chat_gui:special_btn_pressed(...) then
		return true
	end

	if self._blackmarket_gui and self._blackmarket_gui:special_btn_pressed(...) then
		return true
	end
end

-- Lines 553-694
function MenuComponentManager:mouse_pressed(o, button, x, y)
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled = component.component_object:mouse_pressed(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	if self._game_chat_gui and self._game_chat_gui:mouse_pressed(button, x, y) then
		return true
	end

	if self._blackmarket_gui and self._blackmarket_gui:mouse_pressed(button, x, y) then
		return true
	end

	if self._server_info_gui then
		if self._server_info_gui:mouse_pressed(button, x, y) then
			return true
		end

		if button == Idstring("0") then
			if self._server_info_gui:check_minimize(x, y) then
				local minimized_data = {
					text = "SERVER INFO",
					help_text = "MAXIMIZE SERVER INFO WINDOW"
				}

				self._server_info_gui:set_minimized(true, minimized_data)

				return true
			end

			if self._server_info_gui:check_grab_scroll_bar(x, y) then
				return true
			end
		elseif button == Idstring("mouse wheel down") then
			if self._server_info_gui:mouse_wheel_down(x, y) then
				return true
			end
		elseif button == Idstring("mouse wheel up") and self._server_info_gui:mouse_wheel_up(x, y) then
			return true
		end
	end

	if self._lobby_profile_gui then
		if self._lobby_profile_gui:mouse_pressed(button, x, y) then
			return true
		end

		if button == Idstring("0") then
			if self._lobby_profile_gui:check_minimize(x, y) then
				return true
			end

			if self._lobby_profile_gui:check_grab_scroll_bar(x, y) then
				return true
			end
		elseif button == Idstring("mouse wheel down") then
			if self._lobby_profile_gui:mouse_wheel_down(x, y) then
				return true
			end
		elseif button == Idstring("mouse wheel up") and self._lobby_profile_gui:mouse_wheel_up(x, y) then
			return true
		end
	end

	if self._view_character_profile_gui then
		if self._view_character_profile_gui:mouse_pressed(button, x, y) then
			return true
		end

		if button == Idstring("0") then
			if self._view_character_profile_gui:check_minimize(x, y) then
				return true
			end

			if self._view_character_profile_gui:check_grab_scroll_bar(x, y) then
				return true
			end
		elseif button == Idstring("mouse wheel down") then
			if self._view_character_profile_gui:mouse_wheel_down(x, y) then
				return true
			end
		elseif button == Idstring("mouse wheel up") and self._view_character_profile_gui:mouse_wheel_up(x, y) then
			return true
		end
	end

	if self._test_profile1 then
		if self._test_profile1:check_grab_scroll_bar(x, y) then
			return true
		end

		if self._test_profile2:check_grab_scroll_bar(x, y) then
			return true
		end

		if self._test_profile3:check_grab_scroll_bar(x, y) then
			return true
		end

		if self._test_profile4:check_grab_scroll_bar(x, y) then
			return true
		end
	end

	if self._minimized_list and button == Idstring("0") then
		for i, data in ipairs(self._minimized_list) do
			if data.panel:inside(x, y) then
				data:callback()

				break
			end
		end
	end
end

-- Lines 696-709
function MenuComponentManager:mouse_clicked(o, button, x, y)
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled = component.component_object:mouse_clicked(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	if self._blackmarket_gui then
		return self._blackmarket_gui:mouse_clicked(o, button, x, y)
	end
end

-- Lines 711-724
function MenuComponentManager:mouse_double_click(o, button, x, y)
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled = component.component_object:mouse_double_click(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	if self._blackmarket_gui then
		return self._blackmarket_gui:mouse_double_click(o, button, x, y)
	end
end

-- Lines 726-786
function MenuComponentManager:mouse_released(o, button, x, y)
	for _, component in pairs(self._active_components) do
		if component.component_object then
			local handled = component.component_object:mouse_released(o, button, x, y)

			if handled then
				return true
			end
		end
	end

	if self._game_chat_gui and self._game_chat_gui:mouse_released(o, button, x, y) then
		return true
	end

	if self._blackmarket_gui then
		return self._blackmarket_gui:mouse_released(button, x, y)
	end

	if self._chat_book then
		local used, pointer = self._chat_book:release_scroll_bar()

		if used then
			return true, pointer
		end
	end

	if self._server_info_gui and self._server_info_gui:release_scroll_bar() then
		return true
	end

	if self._lobby_profile_gui and self._lobby_profile_gui:release_scroll_bar() then
		return true
	end

	if self._view_character_profile_gui and self._view_character_profile_gui:release_scroll_bar() then
		return true
	end

	if self._test_profile1 then
		if self._test_profile1:release_scroll_bar() then
			return true
		end

		if self._test_profile2:release_scroll_bar() then
			return true
		end

		if self._test_profile3:release_scroll_bar() then
			return true
		end

		if self._test_profile4:release_scroll_bar() then
			return true
		end
	end

	return false
end

-- Lines 788-891
function MenuComponentManager:mouse_moved(o, x, y)
	local wanted_pointer = "arrow"

	for _, component in pairs(self._active_components) do
		if component.component_object then
			local used, pointer = component.component_object:mouse_moved(o, x, y)
			wanted_pointer = pointer or wanted_pointer

			if used then
				return true, wanted_pointer
			end
		end
	end

	if self._game_chat_gui then
		local used, pointer = self._game_chat_gui:mouse_moved(x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	if self._blackmarket_gui then
		local used, pointer = self._blackmarket_gui:mouse_moved(o, x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	if self._server_info_gui then
		local used, pointer = self._server_info_gui:moved_scroll_bar(x, y)

		if used then
			return true, pointer
		end

		local used, pointer = self._server_info_gui:mouse_moved(x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	if self._backdrop_gui then
		local used, pointer = self._backdrop_gui:mouse_moved(x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	if self._lobby_profile_gui then
		local used, pointer = self._lobby_profile_gui:moved_scroll_bar(x, y)

		if used then
			return true, pointer
		end

		local used, pointer = self._lobby_profile_gui:mouse_moved(x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	if self._view_character_profile_gui then
		local used, pointer = self._view_character_profile_gui:moved_scroll_bar(x, y)

		if used then
			return true, pointer
		end

		local used, pointer = self._view_character_profile_gui:mouse_moved(x, y)
		wanted_pointer = pointer or wanted_pointer

		if used then
			return true, wanted_pointer
		end
	end

	if self._test_profile1 then
		local used, pointer = self._test_profile1:moved_scroll_bar(x, y)

		if used then
			return true, pointer
		end

		local used, pointer = self._test_profile2:moved_scroll_bar(x, y)

		if used then
			return true, pointer
		end

		local used, pointer = self._test_profile3:moved_scroll_bar(x, y)

		if used then
			return true, pointer
		end

		local used, pointer = self._test_profile4:moved_scroll_bar(x, y)

		if used then
			return true, pointer
		end
	end

	if self._minimized_list then
		for i, data in ipairs(self._minimized_list) do
			if data.mouse_over ~= data.panel:inside(x, y) then
				data.mouse_over = data.panel:inside(x, y)

				data.text:set_font(data.mouse_over and tweak_data.menu.default_font_no_outline_id or Idstring(tweak_data.menu.default_font))
				data.text:set_color(data.mouse_over and Color.black or Color.white)
				data.selected:set_visible(data.mouse_over)
				data.help_text:set_visible(data.mouse_over)
			end

			data.help_text:set_position(x + 12, y + 12)
		end
	end

	return false, wanted_pointer
end

-- Lines 893-894
function MenuComponentManager:peer_outfit_updated(peer_id)
end

-- Lines 896-897
function MenuComponentManager:on_peer_removed(peer, reason)
end

-- Lines 900-910
function MenuComponentManager:_create_chat_gui()
	if _G.IS_PC and MenuCallbackHandler:is_multiplayer() and managers.network:session() then
		if self._game_chat_gui then
			self:show_game_chat_gui()
		else
			self:add_game_chat()
		end

		self._game_chat_gui:set_params(self._saved_game_chat_params or "default")

		self._saved_game_chat_params = nil
	end
end

-- Lines 912-925
function MenuComponentManager:create_chat_gui()
	self:close_chat_gui()

	local config = {
		w = 540,
		use_minimize_legend = true,
		h = 220,
		header_type = "fit",
		no_close_legend = true,
		x = 290
	}
	self._chat_book = BookBoxGui:new(self._ws, nil, config)

	self._chat_book:set_layer(8)

	local global_gui = ChatGui:new(self._ws, "Global", "")

	global_gui:set_channel_id(ChatManager.GLOBAL)
	global_gui:set_layer(self._chat_book:layer())
	self._chat_book:add_page("Global", global_gui, false)
	self._chat_book:set_layer(tweak_data.gui.MENU_COMPONENT_LAYER)
end

-- Lines 927-950
function MenuComponentManager:add_game_chat()
	if _G.IS_PC then
		self._game_chat_gui = ChatGui:new(self._ws)

		if self._game_chat_params then
			self._game_chat_gui:set_params(self._game_chat_params)

			self._game_chat_params = nil
		end
	end
end

-- Lines 952-959
function MenuComponentManager:set_max_lines_game_chat(max_lines)
	if self._game_chat_gui then
		self._game_chat_gui:set_max_lines(max_lines)
	else
		self._game_chat_params = self._game_chat_params or {}
		self._game_chat_params.max_lines = max_lines
	end
end

-- Lines 961-969
function MenuComponentManager:pre_set_game_chat_leftbottom(from_left, from_bottom)
	if self._game_chat_gui then
		self._game_chat_gui:set_leftbottom(from_left, from_bottom)
	else
		self._game_chat_params = self._game_chat_params or {}
		self._game_chat_params.left = from_left
		self._game_chat_params.bottom = from_bottom
	end
end

-- Lines 971-980
function MenuComponentManager:remove_game_chat()
	if not self._chat_book then
		return
	end

	self._chat_book:remove_page("Game")
end

-- Lines 982-986
function MenuComponentManager:hide_game_chat_gui()
	if self._game_chat_gui then
		self._game_chat_gui:hide()
	end
end

-- Lines 988-992
function MenuComponentManager:show_game_chat_gui()
	if self._game_chat_gui then
		self._game_chat_gui:show()
	end
end

-- Lines 994-998
function MenuComponentManager:_disable_chat_gui()
	if self._game_chat_gui then
		self._game_chat_gui:set_enabled(false)
	end
end

-- Lines 1000-1012
function MenuComponentManager:close_chat_gui()
	if self._game_chat_gui then
		self._game_chat_gui:close()

		self._game_chat_gui = nil
	end

	if self._chat_book_minimized_id then
		self:remove_minimized(self._chat_book_minimized_id)

		self._chat_book_minimized_id = nil
	end

	self._game_chat_bottom = nil
end

-- Lines 1015-1021
function MenuComponentManager:create_lobby_profile_gui(peer_id, x, y)
	self:close_lobby_profile_gui()

	self._lobby_profile_gui = LobbyProfileBoxGui:new(self._ws, nil, nil, nil, {
		h = 160,
		x = x,
		y = y
	}, peer_id)

	self._lobby_profile_gui:set_title(nil)
	self._lobby_profile_gui:set_use_minimize_legend(false)
	table.insert(self._update_components, self._lobby_profile_gui)
end

-- Lines 1023-1033
function MenuComponentManager:close_lobby_profile_gui()
	if self._lobby_profile_gui then
		self:removeFromUpdateTable(self._lobby_profile_gui)
		self._lobby_profile_gui:close()

		self._lobby_profile_gui = nil
	end

	if self._lobby_profile_gui_minimized_id then
		self:remove_minimized(self._lobby_profile_gui_minimized_id)

		self._lobby_profile_gui_minimized_id = nil
	end
end

-- Lines 1036-1043
function MenuComponentManager:create_view_character_profile_gui(user, x, y)
	self:close_view_character_profile_gui()

	self._view_character_profile_gui = ViewCharacterProfileBoxGui:new(self._ws, nil, nil, nil, {
		w = 360,
		x = 837,
		h = 160,
		y = 100
	}, user)

	self._view_character_profile_gui:set_title(nil)
	self._view_character_profile_gui:set_use_minimize_legend(false)
	table.insert(self._update_components, self._view_character_profile_gui)
end

-- Lines 1045-1055
function MenuComponentManager:close_view_character_profile_gui()
	if self._view_character_profile_gui then
		self:removeFromUpdateTable(self._view_character_profile_gui)
		self._view_character_profile_gui:close()

		self._view_character_profile_gui = nil
	end

	if self._view_character_profile_gui_minimized_id then
		self:remove_minimized(self._view_character_profile_gui_minimized_id)

		self._view_character_profile_gui_minimized_id = nil
	end
end

-- Lines 1059-1099
function MenuComponentManager:get_texture_from_mod_type(type, sub_type, gadget, silencer, is_auto, equipped, mods, types, is_a_path)
	local texture = nil

	if is_a_path then
		texture = type
	elseif silencer then
		texture = "guis/textures/pd2/blackmarket/inv_mod_silencer"
	elseif type == "gadget" then
		texture = "guis/textures/pd2/blackmarket/inv_mod_" .. (gadget or "flashlight")
	elseif type == "upper_reciever" or type == "lower_reciever" then
		texture = "guis/textures/pd2/blackmarket/inv_mod_custom"
	elseif type == "custom" then
		texture = "guis/textures/pd2/blackmarket/inv_mod_" .. (sub_type or is_auto and "autofire" or "singlefire")
	elseif type == "sight" then
		texture = "guis/textures/pd2/blackmarket/inv_mod_scope"
	elseif type == "ammo" then
		if equipped then
			texture = "guis/textures/pd2/blackmarket/inv_mod_" .. tostring(sub_type or type)
		elseif mods and #mods > 0 then
			local weapon_factory_tweak_data = tweak_data.weapon.factory.parts
			local part_id = mods[1][1]
			type = weapon_factory_tweak_data[part_id].type
			sub_type = weapon_factory_tweak_data[part_id].sub_type
			texture = "guis/textures/pd2/blackmarket/inv_mod_" .. tostring(sub_type or type)
		end

		texture = "guis/textures/pd2/blackmarket/inv_mod_" .. tostring(sub_type or type)
	elseif type == "bonus" then
		texture = equipped and "guis/textures/pd2/blackmarket/inv_mod_" .. tostring(sub_type or type) or "guis/textures/pd2/blackmarket/inv_mod_bonus"
		texture = "guis/textures/pd2/blackmarket/inv_mod_" .. tostring(sub_type or type)
	else
		texture = "guis/textures/pd2/blackmarket/inv_mod_" .. type
	end

	return texture
end

-- Lines 1104-1108
function MenuComponentManager:set_blackmarket_tradable_loaded(error)
	if self._blackmarket_gui then
		self._blackmarket_gui:set_tradable_loaded(error)
	end
end

-- Lines 1111-1113
function MenuComponentManager:_maximize_weapon_box(data)
	self:remove_minimized(data.id)
end

-- Lines 1121-1159
function MenuComponentManager:add_minimized(config)
	self._minimized_list = self._minimized_list or {}
	self._minimized_id = (self._minimized_id or 0) + 1
	local panel = self._main_panel:panel({
		w = 100,
		h = 20,
		layer = tweak_data.gui.MENU_COMPONENT_LAYER
	})
	local text = nil

	if config.text then
		text = panel:text({
			vertical = "center",
			hvertical = "center",
			halign = "left",
			font_size = 22,
			align = "center",
			layer = 2,
			text = config.text,
			font = tweak_data.menu.default_font
		})

		text:set_center_y(panel:center_y())

		local _, _, w, h = text:text_rect()

		text:set_size(w + 8, h)
		panel:set_size(w + 8, h)
	end

	local help_text = panel:parent():text({
		halign = "left",
		vertical = "center",
		hvertical = "center",
		align = "left",
		visible = false,
		layer = 3,
		text = config.help_text or "CLICK TO MAXIMIZE WEAPON INFO",
		font = tweak_data.menu.small_font,
		font_size = tweak_data.menu.small_font_size,
		color = Color.white
	})

	help_text:set_shape(help_text:text_rect())

	local unselected = panel:bitmap({
		texture = "guis/textures/menu_unselected",
		layer = 0
	})

	unselected:set_h(64 * panel:h() / 32)
	unselected:set_center_y(panel:center_y())

	local selected = panel:bitmap({
		texture = "guis/textures/menu_selected",
		visible = false,
		layer = 1
	})

	selected:set_h(64 * panel:h() / 32)
	selected:set_center_y(panel:center_y())
	panel:set_bottom(self._main_panel:h() - CoreMenuRenderer.Renderer.border_height)

	local top_line = panel:parent():bitmap({
		texture = "guis/textures/headershadow",
		layer = 1,
		visible = false,
		w = panel:w()
	})

	top_line:set_bottom(panel:top())
	table.insert(self._minimized_list, {
		mouse_over = false,
		id = self._minimized_id,
		panel = panel,
		selected = selected,
		text = text,
		help_text = help_text,
		top_line = top_line,
		callback = config.callback
	})
	self:_layout_minimized()

	return self._minimized_id
end

-- Lines 1161-1168
function MenuComponentManager:_layout_minimized()
	local x = 0

	for i, data in ipairs(self._minimized_list) do
		data.panel:set_x(x)
		data.top_line:set_x(x)

		x = x + data.panel:w() + 2
	end
end

-- Lines 1170-1181
function MenuComponentManager:remove_minimized(id)
	for i, data in ipairs(self._minimized_list) do
		if data.id == id then
			data.help_text:parent():remove(data.help_text)
			data.top_line:parent():remove(data.top_line)
			self._main_panel:remove(data.panel)
			table.remove(self._minimized_list, i)

			break
		end
	end

	self:_layout_minimized()
end

-- Lines 1184-1201
function MenuComponentManager:_request_done_callback(texture_ids)
	local key = texture_ids:key()
	local entry = self._requested_textures[key]

	if not entry then
		return
	end

	local clbks = {}

	for index, owner_data in pairs(entry.owners) do
		table.insert(clbks, owner_data.clbk)

		owner_data.clbk = nil
	end

	for _, clbk in pairs(clbks) do
		clbk(texture_ids)
	end
end

-- Lines 1203-1243
function MenuComponentManager:request_texture(texture, done_cb)
	if self._block_texture_requests then
		debug_pause(string.format("[MenuComponentManager:request_texture] Requesting texture is blocked! %s", texture))

		return false
	end

	local texture_ids = Idstring(texture)

	if not DB:has(Idstring("texture"), texture_ids) then
		Application:error(string.format("[MenuComponentManager:request_texture] No texture entry named \"%s\" in database.", texture))

		return false
	end

	local key = texture_ids:key()
	local entry = self._requested_textures[key]

	if not entry then
		entry = {
			next_index = 1,
			owners = {},
			texture_ids = texture_ids
		}
		self._requested_textures[key] = entry
	end

	local index = entry.next_index
	entry.owners[index] = {
		clbk = done_cb
	}
	local next_index = index + 1

	while entry.owners[next_index] do
		if index == next_index then
			debug_pause("[MenuComponentManager:request_texture] overflow!")
		end

		next_index = next_index + 1

		if next_index == 10000 then
			next_index = 1
		end
	end

	entry.next_index = next_index

	TextureCache:request(texture_ids, "NORMAL", callback(self, self, "_request_done_callback"), 100)

	return index
end

-- Lines 1245-1258
function MenuComponentManager:unretrieve_texture(texture, index)
	local texture_ids = Idstring(texture)
	local key = texture_ids:key()
	local entry = self._requested_textures[key]

	if entry and entry.owners[index] then
		entry.owners[index] = nil

		if not next(entry.owners) then
			self._requested_textures[key] = nil
		end

		TextureCache:unretrieve(texture_ids)
	end
end

-- Lines 1261-1265
function MenuComponentManager:retrieve_texture(texture)
	return TextureCache:retrieve(texture, "NORMAL")
end

-- Lines 1268-1322
function MenuComponentManager:add_colors_to_text_object(text_object, ...)
	local text = text_object:text()
	local unchanged_text = text
	local colors = {
		...
	}
	local default_color = #colors == 1 and colors[1] or tweak_data.screen_colors.text
	local start_ci, end_ci, first_ci = nil
	local text_dissected = utf8.characters(text)
	local idsp = Idstring("#")
	start_ci = {}
	end_ci = {}
	first_ci = true

	for i, c in ipairs(text_dissected) do
		if Idstring(c) == idsp then
			local next_c = text_dissected[i + 1]

			if next_c and Idstring(next_c) == idsp then
				if first_ci then
					table.insert(start_ci, i)
				else
					table.insert(end_ci, i)
				end

				first_ci = not first_ci
			end
		end
	end

	if #start_ci == #end_ci then
		for i = 1, #start_ci do
			start_ci[i] = start_ci[i] - ((i - 1) * 4 + 1)
			end_ci[i] = end_ci[i] - (i * 4 - 1)
		end
	end

	text = string.gsub(text, "##", "")

	text_object:set_text(text)

	if colors then
		text_object:clear_range_color(1, utf8.len(text))

		if #start_ci ~= #end_ci then
			Application:error("[MenuComponentManager:color_text_object]: Missing '#' in text:", unchanged_text, #start_ci, #end_ci)
		else
			for i = 1, #start_ci do
				text_object:set_range_color(start_ci[i], end_ci[i], colors[i] or default_color)
			end
		end
	end
end

MenuComponentPostEventInstance = MenuComponentPostEventInstance or class()

-- Lines 1325-1328
function MenuComponentPostEventInstance:init(sound_source)
	self._sound_source = sound_source
	self._post_event = false
end

-- Lines 1330-1339
function MenuComponentPostEventInstance:post_event(event)
	if alive(self._post_event) then
		self._post_event:stop()
	end

	self._post_event = false

	if alive(self._sound_source) then
		self._post_event = self._sound_source:post_event(event)
	end
end

-- Lines 1341-1346
function MenuComponentPostEventInstance:stop_event()
	if alive(self._post_event) then
		self._post_event:stop()
	end

	self._post_event = false
end

-- Lines 1348-1353
function MenuComponentManager:new_post_event_instance()
	local event_instance = MenuComponentPostEventInstance:new(self._sound_source)
	self._unique_event_instances = self._unique_event_instances or {}

	table.insert(self._unique_event_instances, event_instance)

	return event_instance
end

-- Lines 1355-1366
function MenuComponentManager:post_event(event, unique)
	if alive(self._post_event) then
		self._post_event:stop()

		self._post_event = nil
	end

	local post_event = self._sound_source:post_event(event)

	if unique then
		self._post_event = post_event
	end

	return post_event
end

-- Lines 1368-1374
function MenuComponentManager:stop_event()
	print("MenuComponentManager:stop_event()")

	if alive(self._post_event) then
		self._post_event:stop()

		self._post_event = nil
	end
end

-- Lines 1376-1419
function MenuComponentManager:close()
	print("[MenuComponentManager:close]")
	self:close_chat_gui()

	if alive(self._sound_source) then
		self._sound_source:stop()
	end

	self:_destroy_controller_input()

	if self._requested_textures then
		for key, entry in pairs(self._requested_textures) do
			TextureCache:unretrieve(entry.texture_ids)
		end
	end

	self._requested_textures = {}
	self._block_texture_requests = true
end

-- Lines 1421-1446
function MenuComponentManager:play_transition(run_in_pause)
	if self._transition_panel then
		self._transition_panel:parent():remove(self._transition_panel)
	end

	self._transition_panel = self._fullscreen_ws:panel():panel({
		layer = 10000,
		name = "transition_panel"
	})

	self._transition_panel:rect({
		name = "fade1",
		valign = "scale ",
		halign = "scale",
		color = Color.black
	})

	-- Lines 1428-1444
	local function animate_transition(o)
		local fade1 = o:child("fade1")
		local seconds = 0.5
		local t = 0
		local dt, p = nil

		while t < seconds do
			dt = coroutine.yield()

			if dt == 0 and run_in_pause then
				dt = TimerManager:main():delta_time()
			end

			t = t + dt
			p = t / seconds

			fade1:set_alpha(1 - p)
		end
	end

	self._transition_panel:animate(animate_transition)
end

-- Lines 1448-1523
function MenuComponentManager:test_camera_shutter_tech()
	if not self._tcst then
		self._tcst = managers.gui_data:create_fullscreen_16_9_workspace()
		local o = self._tcst:panel():panel({
			layer = 10000
		})
		local b = o:rect({
			valign = "scale",
			name = "black",
			halign = "scale",
			layer = 5,
			color = Color.black
		})

		-- Lines 1458-1462
		local function one_frame_hide(o)
			o:hide()
			coroutine.yield()
			o:show()
		end

		b:animate(one_frame_hide)
	end

	local o = self._tcst:panel():children()[1]

	-- Lines 1503-1519
	local function animate_fade(o)
		local black = o:child("black")

		over(0.5, function (p)
			black:set_alpha(1 - p)
		end)
	end

	o:stop()
	o:animate(animate_fade)
end

-- Lines 1526-1546
function MenuComponentManager:create_test_gui()
	if alive(Global.test_gui) then
		Overlay:gui():destroy_workspace(Global.test_gui)

		Global.test_gui = nil
	end

	Global.test_gui = managers.gui_data:create_fullscreen_16_9_workspace()
	local panel = Global.test_gui:panel()
	local bg = panel:rect({
		layer = 1000,
		color = Color.black
	})
	local size = 48
	local x = 0

	for i = 3, 3 do
		local bitmap = panel:bitmap({
			texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/mezzanine_test",
			name = "bitmap",
			rotation = 360,
			render_template = "TextDistanceField",
			layer = 1001
		})

		bitmap:set_size(bitmap:texture_width() * i, bitmap:texture_height() * i)
		bitmap:set_position(x, 0)

		x = bitmap:right() + 10
	end
end

-- Lines 1548-1553
function MenuComponentManager:destroy_test_gui()
	if alive(Global.test_gui) then
		Overlay:gui():destroy_workspace(Global.test_gui)

		Global.test_gui = nil
	end
end

-- Lines 1556-1570
function MenuComponentManager:close_raid_menu_test_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_test_gui then
		self._raid_menu_test_gui:close()

		self._raid_menu_test_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1574-1576
function MenuComponentManager:create_raid_menu_mission_selection_gui(node, component)
	return self:_create_raid_menu_mission_selection_gui(node, component)
end

-- Lines 1578-1602
function MenuComponentManager:_create_raid_menu_mission_selection_gui(node, component)
	self:close_raid_menu_mission_selection_gui(node, component)

	self._raid_menu_mission_selection_gui = MissionSelectionGui:new(self._ws, self._fullscreen_ws, node, component)

	table.insert(self._update_components, self._raid_menu_mission_selection_gui)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_mission_selection_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end

		final_list.raid_list = self._raid_menu_mission_selection_gui._raid_list
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_mission_selection_gui
end

-- Lines 1604-1619
function MenuComponentManager:close_raid_menu_mission_selection_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_mission_selection_gui then
		self:removeFromUpdateTable(self._raid_menu_mission_selection_gui)
		self._raid_menu_mission_selection_gui:close()

		self._raid_menu_mission_selection_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1624-1626
function MenuComponentManager:create_raid_menu_mission_unlock_gui(node, component)
	return self:_create_raid_menu_mission_unlock_gui(node, component)
end

-- Lines 1628-1652
function MenuComponentManager:_create_raid_menu_mission_unlock_gui(node, component)
	self:close_raid_menu_mission_unlock_gui(node, component)

	self._raid_menu_mission_unlock_gui = MissionUnlockGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_mission_unlock_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end

		final_list.raid_list = self._raid_menu_mission_unlock_gui._raid_list
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_menu_mission_unlock_gui)

	return self._raid_menu_mission_unlock_gui
end

-- Lines 1654-1669
function MenuComponentManager:close_raid_menu_mission_unlock_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_mission_unlock_gui then
		self:removeFromUpdateTable(self._raid_menu_mission_unlock_gui)
		self._raid_menu_mission_unlock_gui:close()

		self._raid_menu_mission_unlock_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1675-1677
function MenuComponentManager:create_raid_menu_mission_join_gui(node, component)
	return self:_create_raid_menu_mission_join_gui(node, component)
end

-- Lines 1679-1699
function MenuComponentManager:_create_raid_menu_mission_join_gui(node, component)
	self:close_raid_menu_mission_join_gui(node, component)

	self._raid_menu_mission_join_gui = MissionJoinGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_mission_join_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_menu_mission_join_gui)

	return self._raid_menu_mission_join_gui
end

-- Lines 1701-1716
function MenuComponentManager:close_raid_menu_mission_join_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_mission_join_gui then
		self:removeFromUpdateTable(self._raid_menu_mission_join_gui)
		self._raid_menu_mission_join_gui:close()

		self._raid_menu_mission_join_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1720-1722
function MenuComponentManager:create_raid_menu_weapon_select_gui(node, component)
	return self:_create_raid_menu_weapon_select_gui(node, component)
end

-- Lines 1724-1746
function MenuComponentManager:_create_raid_menu_weapon_select_gui(node, component)
	self:close_raid_menu_weapon_select_gui(node, component)

	self._raid_menu_weapon_select_gui = WeaponSelectionGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_weapon_select_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end

		final_list.weapon_list = self._raid_menu_weapon_select_gui._weapon_list
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_weapon_select_gui
end

-- Lines 1748-1762
function MenuComponentManager:close_raid_menu_weapon_select_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_weapon_select_gui then
		self._raid_menu_weapon_select_gui:close()

		self._raid_menu_weapon_select_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1766-1768
function MenuComponentManager:create_raid_menu_main_menu_gui(node, component)
	return self:_create_raid_menu_main_menu_gui(node, component)
end

-- Lines 1770-1789
function MenuComponentManager:_create_raid_menu_main_menu_gui(node, component)
	self:close_raid_menu_main_menu_gui(node, component)

	self._raid_menu_main_menu_gui = RaidMainMenuGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_main_menu_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_main_menu_gui
end

-- Lines 1791-1805
function MenuComponentManager:close_raid_menu_main_menu_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_main_menu_gui then
		self._raid_menu_main_menu_gui:close()

		self._raid_menu_main_menu_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1809-1811
function MenuComponentManager:create_raid_menu_select_character_profile_gui(node, component)
	return self:_create_raid_menu_select_character_profile_gui(node, component)
end

-- Lines 1813-1834
function MenuComponentManager:_create_raid_menu_select_character_profile_gui(node, component)
	self:close_raid_menu_select_character_profile_gui(node, component)

	self._raid_menu_select_character_profile_gui = CharacterSelectionGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_select_character_profile_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_menu_select_character_profile_gui)

	return self._raid_menu_select_character_profile_gui
end

-- Lines 1836-1851
function MenuComponentManager:close_raid_menu_select_character_profile_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_select_character_profile_gui then
		self:removeFromUpdateTable(self._raid_menu_select_character_profile_gui)
		self._raid_menu_select_character_profile_gui:close()

		self._raid_menu_select_character_profile_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1855-1857
function MenuComponentManager:create_raid_menu_create_character_profile_gui(node, component)
	return self:_create_raid_menu_create_character_profile_gui(node, component)
end

-- Lines 1859-1880
function MenuComponentManager:_create_raid_menu_create_character_profile_gui(node, component)
	self:close_raid_menu_create_character_profile_gui(node, component)

	self._raid_menu_create_character_profile_gui = CharacterCreationGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_create_character_profile_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_menu_create_character_profile_gui)

	return self._raid_menu_create_character_profile_gui
end

-- Lines 1882-1897
function MenuComponentManager:close_raid_menu_create_character_profile_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_create_character_profile_gui then
		self:removeFromUpdateTable(self._raid_menu_create_character_profile_gui)
		self._raid_menu_create_character_profile_gui:close()

		self._raid_menu_create_character_profile_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1901-1903
function MenuComponentManager:create_raid_menu_character_customization_gui(node, component)
	return self:_create_raid_menu_character_customization_gui(node, component)
end

-- Lines 1905-1928
function MenuComponentManager:_create_raid_menu_character_customization_gui(node, component)
	self:close_raid_menu_character_customization_gui(node, component)

	self._raid_menu_character_customization_gui = CharacterCustomizationGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_character_customization_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end

		final_list.character_customizations_grid = self._raid_menu_character_customization_gui._character_customizations_grid
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_character_customization_gui
end

-- Lines 1930-1944
function MenuComponentManager:close_raid_menu_character_customization_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_character_customization_gui then
		self._raid_menu_character_customization_gui:close()

		self._raid_menu_character_customization_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1948-1950
function MenuComponentManager:create_raid_menu_gold_asset_store_gui(node, component)
	return self:_create_raid_menu_gold_asset_store_gui(node, component)
end

-- Lines 1952-1976
function MenuComponentManager:_create_raid_menu_gold_asset_store_gui(node, component)
	self:close_raid_menu_gold_asset_store_gui(node, component)

	self._raid_menu_gold_asset_store_gui = GoldAssetStoreGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_gold_asset_store_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end

		final_list.gold_asset_store_grid = self._raid_menu_gold_asset_store_gui._gold_asset_store_grid
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_menu_gold_asset_store_gui)

	return self._raid_menu_gold_asset_store_gui
end

-- Lines 1978-1993
function MenuComponentManager:close_raid_menu_gold_asset_store_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_gold_asset_store_gui then
		self:removeFromUpdateTable(self._raid_menu_gold_asset_store_gui)
		self._raid_menu_gold_asset_store_gui:close()

		self._raid_menu_gold_asset_store_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 1997-1999
function MenuComponentManager:create_raid_menu_intel_gui(node, component)
	return self:_create_raid_menu_intel_gui(node, component)
end

-- Lines 2001-2025
function MenuComponentManager:_create_raid_menu_intel_gui(node, component)
	self:close_raid_menu_intel_gui(node, component)

	self._raid_menu_intel_gui = IntelGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_intel_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end

		final_list.intel_grid = self._raid_menu_intel_gui._intel_grid
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_menu_intel_gui)

	return self._raid_menu_intel_gui
end

-- Lines 2027-2042
function MenuComponentManager:close_raid_menu_intel_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_intel_gui then
		self:removeFromUpdateTable(self._raid_menu_intel_gui)
		self._raid_menu_intel_gui:close()

		self._raid_menu_intel_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2046-2048
function MenuComponentManager:create_raid_menu_comic_book_gui(node, component)
	return self:_create_raid_menu_comic_book_gui(node, component)
end

-- Lines 2050-2071
function MenuComponentManager:_create_raid_menu_comic_book_gui(node, component)
	self:close_raid_menu_comic_book_gui(node, component)

	self._raid_menu_comic_book_gui = ComicBookGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_comic_book_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_comic_book_gui
end

-- Lines 2073-2087
function MenuComponentManager:close_raid_menu_comic_book_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_comic_book_gui then
		self._raid_menu_comic_book_gui:close()

		self._raid_menu_comic_book_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2091-2093
function MenuComponentManager:create_raid_menu_header_gui(node, component)
	return self:_create_raid_menu_header_gui(node, component)
end

-- Lines 2095-2105
function MenuComponentManager:_create_raid_menu_header_gui(node, component)
	self:close_raid_menu_header_gui()

	self._raid_menu_header_gui = RaidMenuHeader:new(self._ws, self._fullscreen_ws, node, component)
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_header_gui
end

-- Lines 2107-2117
function MenuComponentManager:close_raid_menu_header_gui()
	if self._raid_menu_header_gui then
		self._raid_menu_header_gui:close()

		self._raid_menu_header_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2121-2123
function MenuComponentManager:create_raid_menu_footer_gui(node, component)
	return self:_create_raid_menu_footer_gui(node, component)
end

-- Lines 2125-2135
function MenuComponentManager:_create_raid_menu_footer_gui(node, component)
	self:close_raid_menu_footer_gui(node, component)

	self._raid_menu_footer_gui = RaidMenuFooter:new(self._ws, self._fullscreen_ws, node, component)
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_footer_gui
end

-- Lines 2137-2147
function MenuComponentManager:close_raid_menu_footer_gui(node, component)
	if self._raid_menu_footer_gui then
		self._raid_menu_footer_gui:close()

		self._raid_menu_footer_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2151-2156
function MenuComponentManager:refresh_player_profile_gui()
	if self._raid_menu_footer_gui then
		self._raid_menu_footer_gui:refresh_player_profile()
	end
end

-- Lines 2161-2163
function MenuComponentManager:create_raid_menu_profile_switcher_gui(node, component)
	return self:_create_raid_menu_profile_switcher_gui(node, component)
end

-- Lines 2165-2175
function MenuComponentManager:_create_raid_menu_profile_switcher_gui(node, component)
	self:close_raid_menu_profile_switcher_gui(node, component)

	self._raid_menu_profile_switcher_gui = RaidMenuProfileSwitcher:new(self._ws, self._fullscreen_ws, node, component)
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_profile_switcher_gui
end

-- Lines 2177-2187
function MenuComponentManager:close_raid_menu_profile_switcher_gui(node, component)
	if self._raid_menu_profile_switcher_gui then
		self._raid_menu_profile_switcher_gui:close()

		self._raid_menu_profile_switcher_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2193-2195
function MenuComponentManager:create_raid_menu_left_options_gui(node, component)
	return self:_create_raid_menu_left_options_gui(node, component)
end

-- Lines 2197-2217
function MenuComponentManager:_create_raid_menu_left_options_gui(node, component)
	self:close_raid_menu_left_options_gui(node, component)

	self._raid_menu_left_options_gui = RaidMenuLeftOptions:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_left_options_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_left_options_gui
end

-- Lines 2219-2233
function MenuComponentManager:close_raid_menu_left_options_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_left_options_gui then
		self._raid_menu_left_options_gui:close()

		self._raid_menu_left_options_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2237-2239
function MenuComponentManager:create_raid_options_background_gui(node, component)
	return self:_create_raid_options_background_gui(node, component)
end

-- Lines 2241-2261
function MenuComponentManager:_create_raid_options_background_gui(node, component)
	self:close_raid_options_background_gui(node, component)

	self._raid_options_background_gui = RaidOptionsBackground:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_options_background_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_options_background_gui
end

-- Lines 2263-2277
function MenuComponentManager:close_raid_options_background_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_options_background_gui then
		self._raid_options_background_gui:close()

		self._raid_options_background_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2326-2328
function MenuComponentManager:create_raid_menu_options_controls_gui(node, component)
	return self:_create_raid_menu_options_controls_gui(node, component)
end

-- Lines 2330-2350
function MenuComponentManager:_create_raid_menu_options_controls_gui(node, component)
	self:close_raid_menu_options_controls_gui(node, component)

	self._raid_options_controls_gui = RaidMenuOptionsControls:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_options_controls_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_options_controls_gui
end

-- Lines 2352-2367
function MenuComponentManager:close_raid_menu_options_controls_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_options_controls_gui then
		self._raid_options_controls_gui:close()

		self._raid_options_controls_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2370-2372
function MenuComponentManager:create_raid_menu_options_controls_keybinds_gui(node, component)
	return self:_create_raid_menu_options_controls_keybinds_gui(node, component)
end

-- Lines 2374-2394
function MenuComponentManager:_create_raid_menu_options_controls_keybinds_gui(node, component)
	self:close_raid_menu_options_controls_keybinds_gui(node, component)

	self._raid_options_controls_keybinds_gui = RaidMenuOptionsControlsKeybinds:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_options_controls_keybinds_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_options_controls_keybinds_gui
end

-- Lines 2396-2410
function MenuComponentManager:close_raid_menu_options_controls_keybinds_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_options_controls_keybinds_gui then
		self._raid_options_controls_keybinds_gui:close()

		self._raid_options_controls_keybinds_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2414-2416
function MenuComponentManager:create_raid_menu_options_controller_mapping_gui(node, component)
	return self:_create_raid_menu_options_controller_mapping_gui(node, component)
end

-- Lines 2418-2438
function MenuComponentManager:_create_raid_menu_options_controller_mapping_gui(node, component)
	self:close_raid_menu_options_controller_mapping_gui(node, component)

	self._raid_menu_options_controller_mapping_gui = RaidMenuOptionsControlsControllerMapping:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_options_controller_mapping_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_options_controller_mapping_gui
end

-- Lines 2440-2454
function MenuComponentManager:close_raid_menu_options_controller_mapping_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_options_controller_mapping_gui then
		self._raid_menu_options_controller_mapping_gui:close()

		self._raid_menu_options_controller_mapping_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2458-2460
function MenuComponentManager:create_raid_menu_options_sound_gui(node, component)
	return self:_create_raid_menu_options_sound_gui(node, component)
end

-- Lines 2462-2482
function MenuComponentManager:_create_raid_menu_options_sound_gui(node, component)
	self:close_raid_menu_options_sound_gui(node, component)

	self._raid_options_sound_gui = RaidMenuOptionsSound:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_options_sound_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_options_sound_gui
end

-- Lines 2484-2498
function MenuComponentManager:close_raid_menu_options_sound_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_options_sound_gui then
		self._raid_options_sound_gui:close()

		self._raid_options_sound_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2501-2503
function MenuComponentManager:create_raid_menu_options_network_gui(node, component)
	return self:_create_raid_menu_options_network_gui(node, component)
end

-- Lines 2505-2525
function MenuComponentManager:_create_raid_menu_options_network_gui(node, component)
	self:close_raid_menu_options_network_gui(node, component)

	self._raid_options_network_gui = RaidMenuOptionsNetwork:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_options_network_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_options_network_gui
end

-- Lines 2527-2541
function MenuComponentManager:close_raid_menu_options_network_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_options_network_gui then
		self._raid_options_network_gui:close()

		self._raid_options_network_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2544-2546
function MenuComponentManager:create_raid_menu_options_video_gui(node, component)
	return self:_create_raid_menu_options_video_gui(node, component)
end

-- Lines 2548-2568
function MenuComponentManager:_create_raid_menu_options_video_gui(node, component)
	self:close_raid_menu_options_video_gui(node, component)

	self._raid_options_video_gui = RaidMenuOptionsVideo:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_options_video_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_options_video_gui
end

-- Lines 2570-2584
function MenuComponentManager:close_raid_menu_options_video_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_options_video_gui then
		self._raid_options_video_gui:close()

		self._raid_options_video_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2587-2589
function MenuComponentManager:create_raid_menu_options_video_advanced_gui(node, component)
	return self:_create_raid_menu_options_video_advanced_gui(node, component)
end

-- Lines 2591-2611
function MenuComponentManager:_create_raid_menu_options_video_advanced_gui(node, component)
	self:close_raid_menu_options_video_advanced_gui(node, component)

	self._raid_options_video_advanced_gui = RaidMenuOptionsVideoAdvanced:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_options_video_advanced_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_options_video_advanced_gui
end

-- Lines 2613-2627
function MenuComponentManager:close_raid_menu_options_video_advanced_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_options_video_advanced_gui then
		self._raid_options_video_advanced_gui:close()

		self._raid_options_video_advanced_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2631-2657
function MenuComponentManager:create_raid_ready_up_gui(node, component)
	self:close_raid_ready_up_gui(node, component)

	self._raid_ready_up_gui = ReadyUpGui:new(self._ws, self._fullscreen_ws, node, component)
	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_ready_up_gui)

	return self._raid_ready_up_gui
end

-- Lines 2659-2669
function MenuComponentManager:close_raid_ready_up_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_ready_up_gui then
		self:removeFromUpdateTable(self._raid_ready_up_gui)
		self._raid_ready_up_gui:close()

		self._raid_ready_up_gui = nil
	end
end

-- Lines 2673-2675
function MenuComponentManager:create_raid_challenge_cards_gui(node, component)
	return self:_create_raid_challenge_cards_gui(node, component)
end

-- Lines 2677-2701
function MenuComponentManager:_create_raid_challenge_cards_gui(node, component)
	self:close_raid_challenge_cards_gui(node, component)

	self._raid_challenge_cards_gui = ChallengeCardsGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_challenge_cards_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end

		final_list.card_grid = self._raid_challenge_cards_gui._card_grid
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_challenge_cards_gui)

	return self._raid_challenge_cards_gui
end

-- Lines 2703-2713
function MenuComponentManager:close_raid_challenge_cards_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_challenge_cards_gui then
		self:removeFromUpdateTable(self._raid_challenge_cards_gui)
		self._raid_challenge_cards_gui:close()

		self._raid_challenge_cards_gui = nil
	end
end

-- Lines 2717-2719
function MenuComponentManager:create_raid_challenge_cards_view_gui(node, component)
	return self:_create_raid_challenge_cards_view_gui(node, component)
end

-- Lines 2721-2741
function MenuComponentManager:_create_raid_challenge_cards_view_gui(node, component)
	self:close_raid_challenge_cards_view_gui(node, component)

	self._raid_challenge_cards_view_gui = ChallengeCardsViewGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_challenge_cards_view_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_challenge_cards_view_gui
end

-- Lines 2743-2757
function MenuComponentManager:close_raid_challenge_cards_view_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_challenge_cards_view_gui then
		self._raid_challenge_cards_view_gui:close()

		self._raid_challenge_cards_view_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2761-2763
function MenuComponentManager:create_raid_challenge_cards_loot_reward_gui(node, component)
	return self:_create_raid_challenge_cards_loot_reward_gui(node, component)
end

-- Lines 2765-2786
function MenuComponentManager:_create_raid_challenge_cards_loot_reward_gui(node, component)
	self:close_raid_challenge_cards_loot_reward_gui(node, component)

	self._raid_challenge_cards_loot_reward_gui = ChallengeCardsLootRewardGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_challenge_cards_loot_reward_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	table.insert(self._update_components, self._raid_challenge_cards_loot_reward_gui)

	return self._raid_challenge_cards_loot_reward_gui
end

-- Lines 2788-2803
function MenuComponentManager:close_raid_challenge_cards_loot_reward_gui(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_challenge_cards_loot_reward_gui then
		self:removeFromUpdateTable(self._raid_challenge_cards_loot_reward_gui)
		self._raid_challenge_cards_loot_reward_gui:close()

		self._raid_challenge_cards_loot_reward_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2807-2809
function MenuComponentManager:create_raid_menu_xp(node, component)
	return self:_create_raid_menu_xp(node, component)
end

-- Lines 2811-2831
function MenuComponentManager:_create_raid_menu_xp(node, component)
	self:close_raid_menu_xp(node, component)

	self._raid_menu_xp_gui = ExperienceGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_xp_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_xp_gui
end

-- Lines 2833-2847
function MenuComponentManager:close_raid_menu_xp(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_xp_gui then
		self._raid_menu_xp_gui:close()

		self._raid_menu_xp_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2852-2854
function MenuComponentManager:create_raid_menu_post_game_breakdown(node, component)
	return self:_create_raid_menu_post_game_breakdown(node, component)
end

-- Lines 2856-2876
function MenuComponentManager:_create_raid_menu_post_game_breakdown(node, component)
	self:close_raid_menu_post_game_breakdown(node, component)

	self._raid_menu_post_game_breakdown_gui = PostGameBreakdownGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_post_game_breakdown_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_post_game_breakdown_gui
end

-- Lines 2878-2892
function MenuComponentManager:close_raid_menu_post_game_breakdown(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_post_game_breakdown_gui then
		self._raid_menu_post_game_breakdown_gui:close()

		self._raid_menu_post_game_breakdown_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2898-2900
function MenuComponentManager:create_raid_menu_special_honors(node, component)
	return self:_create_raid_menu_special_honors(node, component)
end

-- Lines 2902-2922
function MenuComponentManager:_create_raid_menu_special_honors(node, component)
	self:close_raid_menu_special_honors(node, component)

	self._raid_menu_special_honors_gui = SpecialHonorsGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_special_honors_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_special_honors_gui
end

-- Lines 2924-2938
function MenuComponentManager:close_raid_menu_special_honors(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_special_honors_gui then
		self._raid_menu_special_honors_gui:close()

		self._raid_menu_special_honors_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2945-2947
function MenuComponentManager:create_raid_menu_loot(node, component)
	return self:_create_raid_menu_loot(node, component)
end

-- Lines 2949-2969
function MenuComponentManager:_create_raid_menu_loot(node, component)
	self:close_raid_menu_loot(node, component)

	self._raid_menu_loot_gui = LootScreenGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_loot_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_loot_gui
end

-- Lines 2971-2985
function MenuComponentManager:close_raid_menu_loot(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_loot_gui then
		self._raid_menu_loot_gui:close()

		self._raid_menu_loot_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 2992-2994
function MenuComponentManager:create_raid_menu_greed_loot(node, component)
	return self:_create_raid_menu_greed_loot(node, component)
end

-- Lines 2996-3016
function MenuComponentManager:_create_raid_menu_greed_loot(node, component)
	self:close_raid_menu_loot(node, component)

	self._raid_menu_greed_loot_gui = GreedLootScreenGui:new(self._ws, self._fullscreen_ws, node, component)

	if component then
		self._active_controls[component] = {}
		local final_list = self._active_controls[component]

		for _, control in ipairs(self._raid_menu_greed_loot_gui._root_panel._controls) do
			self:_collect_controls(control, final_list)
		end
	end

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_greed_loot_gui
end

-- Lines 3018-3032
function MenuComponentManager:close_raid_menu_greed_loot(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_greed_loot_gui then
		self._raid_menu_greed_loot_gui:close()

		self._raid_menu_greed_loot_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 3039-3041
function MenuComponentManager:create_raid_menu_credits(node, component)
	return self:_create_raid_menu_credits(node, component)
end

-- Lines 3043-3059
function MenuComponentManager:_create_raid_menu_credits(node, component)
	self:close_raid_menu_credits(node, component)

	self._raid_menu_credits_gui = RaidMenuCreditsGui:new(self._ws, self._fullscreen_ws, node, component)

	table.insert(self._update_components, self._raid_menu_credits_gui)

	local active_menu = managers.menu:active_menu()

	if active_menu then
		active_menu.input:set_force_input(true)
	end

	return self._raid_menu_credits_gui
end

-- Lines 3061-3076
function MenuComponentManager:close_raid_menu_credits(node, component)
	if component then
		self._active_controls[component] = {}
	end

	if self._raid_menu_credits_gui then
		self:removeFromUpdateTable(self._raid_menu_credits_gui)
		self._raid_menu_credits_gui:close()

		self._raid_menu_credits_gui = nil
		local active_menu = managers.menu:active_menu()

		if active_menu then
			active_menu.input:set_force_input(false)
		end
	end
end

-- Lines 3080-3101
function MenuComponentManager:_collect_controls(controls_list, final_list)
	if controls_list._controls then
		for _, control in ipairs(controls_list._controls) do
			if control._controls then
				self:_collect_controls(control._controls, final_list)
			elseif control._name and control._type and control._type == "raid_gui_control" then
				final_list[control._name] = control
			end
		end
	end

	if controls_list._name and controls_list._type and controls_list._type == "raid_gui_control" then
		final_list[controls_list._name] = controls_list
	else
		for _, control in ipairs(controls_list) do
			if control._type and control._type == "raid_gui_control" then
				final_list[control._name] = control
			end
		end
	end
end

-- Lines 3103-3123
function MenuComponentManager:gather_controls_for_component(component_name)
	if component_name then
		self._active_controls[component_name] = {}
		local final_list = self._active_controls[component_name]
		local component_object = self._active_components[component_name].component_object

		if component_object then
			for _, control in ipairs(component_object._root_panel._controls) do
				self:_collect_controls(control, final_list)
			end
		end
	end
end

-- Lines 3125-3138
function MenuComponentManager:debug_controls()
	local component_controls = self._active_controls

	for name, controls in pairs(component_controls) do
		print("MenuComponentManager:debug_controls - inspecting ", name)

		for name, control in pairs(controls) do
			print("MenuComponentManager:debug_controls: ", control._type, name, control._name)
		end
	end

	for idx, control in ipairs(self._raid_menu_mission_join_gui._root_panel._controls) do
		Application:trace(idx, control._name)
	end
end

-- Lines 3141-3147
function MenuComponentManager:removeFromUpdateTable(unit)
	for i = 1, #self._update_components do
		if self._update_components[i] == unit then
			table.remove(self._update_components, i)
		end
	end
end

-- Lines 3158-3182
function MenuComponentManager:_create_voice_chat_status_info()
	local widget_panel_params = {
		name = "voice_chat_panel",
		x = 0,
		w = HUDPlayerVoiceChatStatus.DEFAULT_W,
		h = HUDPlayerVoiceChatStatus.DEFAULT_H * 4
	}
	self._voice_chat_panel = self._voicechat_ws:panel():panel(widget_panel_params)

	self._voice_chat_panel:set_top(self._voicechat_ws:panel():h() / 2 - HUDPlayerVoiceChatStatus.DEFAULT_H * 2)
	self._voice_chat_panel:set_right(self._voicechat_ws:panel():w() - HUDPlayerVoiceChatStatus.DEFAULT_W / 4)

	self._voice_chat_widgets = {
		HUDPlayerVoiceChatStatus:new(0, self._voice_chat_panel),
		HUDPlayerVoiceChatStatus:new(1, self._voice_chat_panel),
		HUDPlayerVoiceChatStatus:new(2, self._voice_chat_panel),
		HUDPlayerVoiceChatStatus:new(3, self._voice_chat_panel)
	}
end

-- Lines 3184-3190
function MenuComponentManager:_voice_panel_align_bottom_right()
	if self._voice_chat_panel then
		Application:trace("MenuComponentManager:_create_voice_chat_status_info")
		self._voice_chat_panel:set_bottom(self._voicechat_ws:panel():h() / 2 + HUDPlayerVoiceChatStatus.DEFAULT_H * 6)
		self._voice_chat_panel:set_right(self._voicechat_ws:panel():w() - HUDPlayerVoiceChatStatus.DEFAULT_W / 4)
	end
end

-- Lines 3192-3200
function MenuComponentManager:_voice_panel_align_mid_right(offset_y)
	if self._voice_chat_panel then
		local offset = offset_y and offset_y or 0

		Application:trace("MenuComponentManager:_create_voice_chat_status_info")
		self._voice_chat_panel:set_top(self._voicechat_ws:panel():h() / 2 - HUDPlayerVoiceChatStatus.DEFAULT_H * 2 + offset)
		self._voice_chat_panel:set_right(self._voicechat_ws:panel():w() - HUDPlayerVoiceChatStatus.DEFAULT_W / 4)
	end
end

-- Lines 3202-3208
function MenuComponentManager:_voice_panel_align_top_right()
	if self._voice_chat_panel then
		Application:trace("MenuComponentManager:_create_voice_chat_status_info")
		self._voice_chat_panel:set_top(self._voicechat_ws:panel():h() / 2 - HUDPlayerVoiceChatStatus.DEFAULT_H * 4)
		self._voice_chat_panel:set_right(self._voicechat_ws:panel():w() - HUDPlayerVoiceChatStatus.DEFAULT_W / 4)
	end
end

-- Lines 3210-3216
function MenuComponentManager:_voice_panel_align_bottom_left()
	if self._voice_chat_panel then
		Application:trace("MenuComponentManager:_create_voice_chat_status_info")
		self._voice_chat_panel:set_bottom(self._voicechat_ws:panel():h() / 2 + HUDPlayerVoiceChatStatus.DEFAULT_H * 6)
		self._voice_chat_panel:set_right(HUDPlayerVoiceChatStatus.DEFAULT_W)
	end
end

-- Lines 3218-3224
function MenuComponentManager:_voice_panel_align_mid_left()
	if self._voice_chat_panel then
		Application:trace("MenuComponentManager:_create_voice_chat_status_info")
		self._voice_chat_panel:set_top(self._voicechat_ws:panel():h() / 2 - HUDPlayerVoiceChatStatus.DEFAULT_H * 2)
		self._voice_chat_panel:set_right(HUDPlayerVoiceChatStatus.DEFAULT_W)
	end
end

-- Lines 3226-3234
function MenuComponentManager:toggle_voice_chat_listeners(enable)
	if enable then
		managers.system_event_listener:add_listener("voice_chat_ui_update_menumanager", {
			CoreSystemEventListenerManager.SystemEventListenerManager.UPDATE_VOICE_CHAT_UI
		}, callback(self, self, "_update_voice_chat_ui"))
		managers.system_event_listener:add_listener("menucomponent_drop_out", {
			CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_DROP_OUT
		}, callback(self, self, "_peer_dropped_out"))
	else
		managers.system_event_listener:remove_listener("voice_chat_ui_update_menumanager")
	end
end

-- Lines 3237-3246
function MenuComponentManager:_peer_dropped_out(params)
	if params then
		local peer_id = params._id

		Application:trace("MenuComponentManager:_peer_dropped_out [peer id] " .. tostring(peer_id))

		if self._voice_chat_widgets[peer_id] then
			self._voice_chat_widgets[peer_id]:hide_chat_indicator()
		end
	end
end

-- Lines 3248-3286
function MenuComponentManager:_update_voice_chat_ui(params)
	Application:trace("MenuComponentManager:_update_voice_chat_ui")

	if params.status_type ~= "talk" then
		return
	end

	local user_data = params.user_data
	local is_local_user = false

	if SystemInfo:platform() == Idstring("XB1") then
		is_local_user = managers.network.account:player_id() == user_data.user_xuid
	elseif SystemInfo:platform() == Idstring("PS4") then
		is_local_user = managers.network.account:username_id() == user_data.user_name
	end

	local peer_to_update = nil

	if is_local_user then
		peer_to_update = managers.network:session():local_peer()
	elseif SystemInfo:platform() == Idstring("XB1") then
		peer_to_update = managers.network:session():peer_by_xuid(user_data.user_xuid)
	elseif SystemInfo:platform() == Idstring("PS4") then
		peer_to_update = managers.network:session():peer_by_name(user_data.user_name)
	end

	if peer_to_update then
		local peer_id = peer_to_update:id()
		local peer_name = peer_to_update:name()

		Application:trace("MenuComponentManager:_update_voice_chat_ui peer is present " .. peer_name .. " peer id " .. tostring(peer_id))

		if self._voice_chat_widgets[peer_id] then
			if user_data.user_talking then
				self._voice_chat_widgets[peer_id]:show_chat_indicator(peer_name)
			else
				self._voice_chat_widgets[peer_id]:hide_chat_indicator()
			end
		end
	end
end
