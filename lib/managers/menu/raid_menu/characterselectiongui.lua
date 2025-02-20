CharacterSelectionGui = CharacterSelectionGui or class(RaidGuiBase)
CharacterSelectionGui.BUTTON_H = 47
CharacterSelectionGui.BUTTON_W = 96
CharacterSelectionGui.CLOSE_REQUEST_FLAG = 1
CharacterSelectionGui.CLOSE_MENU_FLAG = 2
CharacterSelectionGui.OPEN_CUSTOMIZE_FLAG = 3
CharacterSelectionGui.OPEN_CREATION_FLAG = 4

function CharacterSelectionGui:init(ws, fullscreen_ws, node, component_name)
	self._loading_units = {}

	CharacterSelectionGui.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.raid_menu:save_sync_player_data()
	self._node.components.raid_menu_header:set_screen_name("character_selection_title")

	self._pre_close_screen_loading_done_callback = callback(self, self, "_pre_close_screen_loading_done")

	managers.savefile:add_load_done_callback(self._pre_close_screen_loading_done_callback)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))

	self._initial_character_slot = managers.savefile:get_save_progress_slot()
	self._slot_to_select = managers.savefile:get_save_progress_slot()

	managers.raid_menu:hide_background()
end

function CharacterSelectionGui:_setup_properties()
	CharacterSelectionGui.super._setup_properties(self)

	self._background = nil
	self._background_rect = nil
end

function CharacterSelectionGui:_set_initial_data()
	managers.character_customization:reset_current_version_to_attach()

	self._slots_loaded = {}

	self:_load_all_slots()
end

function CharacterSelectionGui:_layout()
	self:_disable_dof()
	self._root_panel:label({
		h = 32,
		w = 416,
		y = 96,
		x = 0,
		name = "subtitle_profiles",
		text = self:translate("character_selection_subtitle", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.large,
		color = tweak_data.gui.colors.raid_white
	})
	self._root_panel:label({
		h = 32,
		w = 416,
		y = 128,
		x = 0,
		name = "subtitle_small_profiles",
		text = self:translate("character_selection_subtitle_small", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_grey
	})

	self._characters_list = self._root_panel:list_active({
		loop_items = true,
		vertical_spacing = 2,
		item_h = 94,
		selection_enabled = true,
		h = 480,
		w = 650,
		y = 224,
		x = 0,
		name = "characters_list",
		item_class = RaidGUIControlListItemCharacterSelect,
		on_item_clicked_callback = callback(self, self, "_on_item_click"),
		on_item_selected_callback = callback(self, self, "_on_item_selected"),
		on_item_double_clicked_callback = callback(self, self, "_on_item_double_click"),
		data_source_callback = callback(self, self, "_data_source_characters_list"),
		special_action_callback = callback(self, self, "_character_action_callback")
	})
	self._select_character_button = self._root_panel:long_primary_button({
		visible = false,
		y = 736,
		x = 0,
		name = "select_character_button",
		text = self:translate("character_selection_select_character_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "on_select_character_button")
	})
	self._select_character_button_disabled = self._root_panel:long_primary_button_disabled({
		y = 736,
		x = 0,
		name = "select_character_button_disabled",
		text = self:translate("character_selection_selected_character_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		visible = not managers.controller:is_controller_present()
	})

	self._select_character_button:set_x((416 - self._select_character_button:w()) / 2)
	self._select_character_button_disabled:set_x((416 - self._select_character_button_disabled:w()) / 2)

	self._right_side_info = self._root_panel:create_custom_control(RaidGUIControlCharacterDescription, {
		h = 720,
		w = 516,
		y = 0,
		x = 1308,
		name = "right_side_info_panel"
	}, {
		class = nil,
		World = nil
	})

	self._right_side_info:set_right(self._root_panel:right())
	self._right_side_info:set_center_y(self._root_panel:h() / 2)

	if managers.controller:is_controller_present() and self._select_character_button then
		self._select_character_button:hide()
		self._select_character_button_disabled:hide()
	end
end

function CharacterSelectionGui:_data_source_characters_list()
	local characters = {}

	for slot_index = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
		local slot_data = Global.savefile_manager.meta_data_list[slot_index]

		if slot_data.cache then
			local character_name = slot_data.cache.PlayerManager.character_profile_name or ""

			table.insert(characters, {
				text = character_name,
				value = slot_index,
				info = "Character " .. character_name
			})
		else
			table.insert(characters, {
				info = "",
				text = "",
				value = slot_index
			})
		end
	end

	return characters
end

function CharacterSelectionGui:on_select_character_button()
	self:activate_selected_character()
	self._characters_list:selected_item():select()
end

function CharacterSelectionGui:_character_action_callback(slot_index, action)
	Application:trace("[CharacterSelectionGui:_character_action_callback] slot_index, action ", slot_index, action)

	if action == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CUSTOMIZE then
		if managers.savefile:get_active_characters_count() <= 0 then
			managers.menu:show_no_active_characters()

			return
		end

		self:_customize_character()
	elseif action == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_RENAME then
		local cache = Global.savefile_manager.meta_data_list[slot_index].cache
		local profile_name = cache.PlayerManager.character_profile_name
		local params = {
			callback_yes = callback(self, self, "_callback_yes_function"),
			textbox_value = profile_name
		}

		managers.menu:show_character_create_dialog(params)
	elseif action == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_NATION then
		if slot_index then
			self:_change_nationality(slot_index)
		end
	elseif action == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_DELETE then
		if slot_index then
			self:_delete_character(slot_index)
		end
	elseif action == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CREATE and slot_index then
		self:_create_character()
	end
end

function CharacterSelectionGui:_change_nationality(slot_index)
	if managers.network:session():has_other_peers() and managers.savefile:get_active_characters_count() <= 1 then
		managers.menu:show_last_character_delete_forbiden_in_multiplayer({
			text = managers.localization:text("character_profile_nationality_change_forbiden_in_multiplayer")
		})

		return
	end

	local cache = Global.savefile_manager.meta_data_list[slot_index].cache

	if not cache then
		return
	end

	local character_nationality = cache.PlayerManager.character_profile_nation
	local character_names = tweak_data.criminals.character_names
	local pick_idx = 1

	for i, v in ipairs(character_names) do
		if v == character_nationality then
			pick_idx = i + 1
		end
	end

	if pick_idx > #character_names then
		pick_idx = 1
	end

	self._new_nationality = character_names[pick_idx]

	managers.raid_menu:on_escape()
end

function CharacterSelectionGui:_callback_yes_function(button, button_data, data)
	local new_profile_name = trim(data.input_field_text)

	if new_profile_name == "" then
		local params = {
			textbox_id = "dialog_err_empty_character_name"
		}

		managers.menu:show_err_character_name_dialog(params)

		return
	elseif character_name_exists(new_profile_name) then
		local params = {
			textbox_id = "dialog_err_duplicate_character_name"
		}

		managers.menu:show_err_character_name_dialog(params)

		return
	end

	self._new_profile_name = new_profile_name

	self:_pre_close_screen()
end

function CharacterSelectionGui:_customize_character()
	if not self._transition_flag then
		self._transition_flag = self.OPEN_CUSTOMIZE_FLAG

		self:_pre_close_screen()
	end
end

function CharacterSelectionGui:_delete_character(slot_index)
	if managers.network:session():has_other_peers() and managers.savefile:get_active_characters_count() <= 1 then
		Application:debug("[CharacterSelectionGui] Delete character: Slot", slot_index, "(Cannot delete last slot!)")

		local params = {
			text = managers.localization:text("character_profile_last_character_delete_forbiden_in_multiplayer")
		}

		managers.menu:show_last_character_delete_forbiden_in_multiplayer(params)

		return
	end

	Application:debug("[CharacterSelectionGui] Delete character: Slot", slot_index)

	self._transition_flag = nil
	self._character_slot_to_delete = slot_index

	self:show_character_delete_confirmation(callback(self, self, "on_item_yes_delete_characters_list"))
end

function CharacterSelectionGui:_create_character()
	if not self._transition_flag then
		Application:debug("[CharacterSelectionGui] Create character: Slot", self._selected_character_slot)

		self._transition_flag = self.OPEN_CREATION_FLAG

		managers.savefile:set_create_character_slot(self._selected_character_slot)
		self:_pre_close_screen()
	end
end

function CharacterSelectionGui:_on_item_click(slot_index)
	Application:trace("[CharacterSelectionGui:_on_item_click] slot_index", slot_index)
	self:_select_character_slot(slot_index)
end

function CharacterSelectionGui:_on_item_selected(slot_index)
	Application:trace("[CharacterSelectionGui:_on_item_selected] slot_index ", slot_index)
	self:_select_character_slot(slot_index)
end

function CharacterSelectionGui:_on_item_double_click(slot_index)
	self:_select_character_slot(slot_index)
	self:activate_selected_character()
	self._characters_list:selected_item():select()
end

function CharacterSelectionGui:_rebind_controller_buttons(slot_index)
	local cache = Global.savefile_manager.meta_data_list[slot_index].cache

	if not cache then
		self:_bind_empty_slot_controller_inputs()
	elseif slot_index == self._active_character_slot then
		self:_bind_active_slot_controller_inputs()
	else
		self:_bind_inactive_slot_controller_inputs()
	end
end

function CharacterSelectionGui:_load_all_slots()
	local last_selected_slot = managers.savefile:get_save_progress_slot()
	local has_last_slot = last_selected_slot ~= -1

	for slot_index = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
		if Global.savefile_manager.meta_data_list and Global.savefile_manager.meta_data_list[slot_index] then
			Global.savefile_manager.meta_data_list[slot_index].is_load_done = false
			Global.savefile_manager.meta_data_list[slot_index].is_cached_slot = false
		end

		self:_load_slot_data(slot_index, false)
	end

	if has_last_slot then
		self:_load_slot_data(last_selected_slot, false)
	end

	self._active_character_slot = last_selected_slot
end

function CharacterSelectionGui:_select_character_slot(slot_index)
	Application:trace("[CharacterSelectionGui:_select_character_slot] slot_index, self._selected_character_slot, self._active_character_slot ", slot_index, self._selected_character_slot, self._active_character_slot)
	self:_rebind_controller_buttons(slot_index)

	if self._selected_character_slot ~= slot_index then
		self._selected_character_slot = slot_index

		self:show_selected_character_details(self._selected_character_slot)
		self:show_selected_character(self._selected_character_slot)
	end

	local slot_empty = not Global.savefile_manager.meta_data_list[slot_index].cache

	if managers.controller:is_controller_present() then
		self._select_character_button:hide()
		self._select_character_button_disabled:hide()
	elseif slot_empty then
		self._select_character_button:hide()
		self._select_character_button_disabled:hide()
	elseif slot_index == self._active_character_slot or slot_empty then
		self._select_character_button:hide()
		self._select_character_button_disabled:show()
	else
		self._select_character_button:show()
		self._select_character_button_disabled:hide()
	end
end

function CharacterSelectionGui:activate_selected_character()
	Application:trace("[CharacterSelectionGui:activate_selected_character] selected_slot, active_slot ", self._selected_character_slot, self._active_character_slot)
	managers.menu_component:post_event("character_selection_doubleclick")

	local old_progress_slot_index = self._active_character_slot
	local new_progress_slot_index = self._selected_character_slot

	if old_progress_slot_index == new_progress_slot_index then
		return
	end

	if self._active_character_slot == self._selected_character_slot then
		return
	end

	local cache = Global.savefile_manager.meta_data_list[self._selected_character_slot].cache

	if not cache then
		return
	end

	self:_activate_character_profile(new_progress_slot_index)
	managers.savefile:set_save_progress_slot(new_progress_slot_index)
end

function CharacterSelectionGui:_activate_character_profile(slot_index)
	Application:trace("[CharacterSelectionGui:_activate_character_profile] slot_index ", slot_index)

	if not Global.savefile_manager.meta_data_list[slot_index] or not Global.savefile_manager.meta_data_list[slot_index].cache then
		self:destroy_character_unit()
		self._right_side_info:set_visible(false)

		return
	end

	self._active_character_slot = slot_index

	self._characters_list:activate_item_by_value(self._active_character_slot)
end

function CharacterSelectionGui:show_selected_character_details(slot_index)
	local cache = nil
	local profile_name = ""
	local nationality = ""
	local class_name = ""
	local skill_tree = {}
	local level = ""
	local active_warcry = ""
	local character_stats = nil

	if Global.savefile_manager.meta_data_list[slot_index] and Global.savefile_manager.meta_data_list[slot_index].cache then
		cache = Global.savefile_manager.meta_data_list[slot_index].cache
		profile_name = cache.PlayerManager.character_profile_name
		nationality = cache.PlayerManager.character_profile_nation
		level = Application:digest_value(cache.RaidExperienceManager.level, false)
		class_name = cache.SkillTreeManager.character_profile_base_class
		skill_tree = cache.SkillTreeManager.base_class_skill_tree
		character_stats = cache.SkillTreeManager.display_stats
		active_warcry = cache.warcry_manager.active_warcry
	end

	if not cache then
		self._right_side_info:set_visible(false)
	else
		self._right_side_info:set_visible(true)
		self._right_side_info:set_data({
			class_name = class_name,
			nationality = nationality,
			level = level,
			character_stats = character_stats,
			profile_name = profile_name,
			active_warcry = active_warcry,
			skill_tree = skill_tree
		})
	end
end

function CharacterSelectionGui:show_selected_character(slot_index)
	self._loading_units[CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT] = true

	managers.dyn_resource:load(IDS_UNIT, Idstring(CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_show_selected_character_loaded", slot_index))
end

function CharacterSelectionGui:_show_selected_character_loaded(slot_index)
	if self._closing_screen then
		if self._spawned_character_unit then
			self._spawned_character_unit:customization():destroy_all_parts_on_character()
		end

		self:destroy_character_unit()

		return
	end

	self._loading_units[CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT] = nil

	managers.character_customization:increase_current_version_to_attach()

	self._character_spawn_location = self:get_character_spawn_location()

	if not self._spawned_character_unit then
		self:destroy_character_unit()

		local unit_name = CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT
		local position = self._character_spawn_location and self._character_spawn_location:position() or Vector3()
		local rotation = self._character_spawn_location and self._character_spawn_location:rotation() or Rotation()
		self._spawned_character_unit = World:spawn_unit(Idstring(unit_name), position, rotation)
		local anim_state_name = tweak_data.character_customization.customization_animation_idle_loop
		local state = self._spawned_character_unit:play_redirect(Idstring(anim_state_name))
	end

	self._spawned_character_unit:customization():destroy_all_parts_on_character()
	self._spawned_character_unit:customization():attach_all_parts_to_character(slot_index, managers.character_customization:get_current_version_to_attach())
end

function CharacterSelectionGui:destroy_character_unit()
	if self._spawned_character_unit then
		self._spawned_character_unit:customization():destroy_all_parts_on_character()
		self._spawned_character_unit:set_slot(0)

		self._spawned_character_unit = nil
	end
end

function CharacterSelectionGui:get_character_spawn_location()
	local units = World:find_units_quick("all", managers.slot:get_mask("env_effect"))

	if not units then
		return
	end

	local ids_unit = Idstring("units/vanilla/arhitecture/ber_a/ber_a_caracter_menu/caracter_menu_floor/caracter_menu_floor")

	for _, unit in pairs(units) do
		if unit:name() == ids_unit then
			return unit:get_object(Idstring("rp_caracter_menu_floor"))
		end
	end
end

function CharacterSelectionGui:back_pressed()
	Application:trace("[CharacterSelectionGui:back_pressed] ")

	if not Global.savefile_manager.meta_data_list[self._active_character_slot].cache then
		return false
	end

	CharacterSelectionGui.super.back_pressed(self)
end

function CharacterSelectionGui:_pre_close_screen()
	self:destroy_character_unit()

	local last_selected_cache = Global.savefile_manager.current_game_cache_slot

	managers.savefile:_set_current_game_cache_slot(self._active_character_slot, true)
	managers.savefile:set_save_progress_slot(self._active_character_slot)

	local last_selected_slot = managers.savefile:get_save_progress_slot()
	self._slot_to_select = last_selected_slot

	Application:trace("[CharacterSelectionGui][_pre_close_screen]", last_selected_slot)

	if last_selected_slot ~= self._initial_character_slot or last_selected_cache ~= self._initial_character_slot then
		managers.savefile:save_last_selected_character_profile_slot()
		self:_load_slot_data(last_selected_slot, true)
	else
		self._slots_loaded[last_selected_slot] = false
		self._is_load_done = false
		self._is_render_done = false

		self:_pre_close_screen_loading_done()
	end

	self:reset_weapon_challenges()
end

function CharacterSelectionGui:_load_slot_data(slot_index, save_as_last_selected_slot)
	managers.warcry:reset()

	self._slots_loaded[slot_index] = false
	self._is_load_done = false
	self._is_render_done = false

	managers.savefile:load_game(slot_index, false)
end

function CharacterSelectionGui:_extra_character_setup()
	Application:trace("[CharacterSelectionGui][_extra_character_setup]")
	managers.hud:refresh_player_panel()

	local selection_category_index = managers.player:local_player():inventory():equipped_selection()

	managers.player:_internal_load()
	managers.player:get_current_state():force_change_weapon_slot(selection_category_index)
	managers.raid_menu:load_sync_player_data()

	local slot = Global.savefile_manager.meta_data_list[Global.savefile_manager.current_game_cache_slot]

	if slot and slot.cache then
		local character_nationality = slot.cache.PlayerManager.character_profile_nation
		local local_peer = managers.network:session():local_peer()
		local team_id = tweak_data.levels:get_default_team_ID("player")

		managers.network:session():send_to_peers_synched("set_character_customization", local_peer._unit, managers.blackmarket:outfit_string(), local_peer:outfit_version(), local_peer._id)
		managers.network:session():send_to_peers_synched("sync_character_level", managers.experience:current_level())
		managers.network:session():send_to_peers_synched("sync_character_class_nationality", managers.skilltree:get_character_profile_class(), managers.player:get_character_profile_nation())
		managers.character_customization:reaply_character_criminal(character_nationality)
	end

	local local_peer = managers.network:session():local_peer()

	local_peer:set_outfit_string(managers.blackmarket:outfit_string())
	managers.network:session():check_send_outfit()
	managers.player:on_upgrades_changed()
	managers.player:set_character_class(managers.skilltree:get_character_profile_class())
	managers.network:start_matchmake_attributes_update()
	self:reset_weapon_challenges()
	managers.weapon_skills:update_weapon_part_animation_weights()
end

function CharacterSelectionGui:_pre_close_screen_loading_done()
	Application:trace("[CharacterSelectionGui]_pre_close_screen_loading_done]")

	if self._new_profile_name then
		managers.player:set_character_profile_name(self._new_profile_name)
		managers.savefile:save_game(managers.savefile:get_save_progress_slot())

		self._new_profile_name = nil
		self._is_render_done = false
	elseif self._new_nationality then
		managers.player:set_character_profile_nation(self._new_nationality)
		managers.blackmarket:set_preferred_character(self._new_nationality, 1)
		managers.savefile:save_game(managers.savefile:get_save_progress_slot())
	end

	if not self._transition_flag then
		return
	end

	if self._transition_flag == self.OPEN_CUSTOMIZE_FLAG then
		managers.raid_menu:open_menu("character_customization_menu")
	elseif self._transition_flag == self.OPEN_CREATION_FLAG then
		managers.raid_menu:open_menu("profile_creation_menu")
	elseif self._transition_flag == self.CLOSE_REQUEST_FLAG then
		self._transition_flag = self.CLOSE_MENU_FLAG

		managers.raid_menu:on_escape()
	end
end

function CharacterSelectionGui:reset_weapon_challenges()
	managers.challenge:deactivate_all_challenges()
	managers.weapon_skills:activate_current_challenges_for_weapon(managers.player:get_current_state()._equipped_unit:base()._name_id)
end

function CharacterSelectionGui:close()
	Application:trace("[CharacterSelectionGui][close] ")

	if self._loading_units then
		for unit_name, _ in pairs(self._loading_units) do
			Application:trace("[CharacterSelectionGui][close] Unloading unit ", unit_name)
			managers.dyn_resource:unload(IDS_UNIT, Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
		end
	end

	managers.savefile:remove_load_done_callback(self._pre_close_screen_loading_done_callback)

	if self._transition_flag == self.CLOSE_MENU_FLAG then
		self:_extra_character_setup()
		self:_enable_dof()
	end

	CharacterSelectionGui.super.close(self)
end

function CharacterSelectionGui:on_escape()
	if self._transition_flag and self._transition_flag == self.CLOSE_MENU_FLAG then
		return false
	end

	if not self._transition_flag then
		self._transition_flag = self.CLOSE_REQUEST_FLAG

		self:_pre_close_screen()
	end

	return true
end

function CharacterSelectionGui:show_character_delete_confirmation(callback_yes_function)
	local params = {
		text = managers.localization:text("dialog_character_delete_message"),
		callback = callback_yes_function
	}

	managers.menu:show_character_delete_dialog(params)
	managers.menu_component:post_event("delete_character_prompt")
end

function CharacterSelectionGui:on_item_yes_delete_characters_list()
	Application:trace("[CharacterSelectionGui:on_item_yes_delete_characters_list] self._character_slot_to_delete ", self._character_slot_to_delete)

	local slot_to_delete = self._character_slot_to_delete

	managers.menu_component:post_event("delete_character")

	Global.savefile_manager.meta_data_list[slot_to_delete].is_deleting = true

	managers.savefile:_remove(slot_to_delete)
	managers.savefile:_set_synched_cache(slot_to_delete, false)

	self._is_load_done = false
	self._is_render_done = false
	self._slots_loaded[slot_to_delete] = false
	local new_slot = -1

	if slot_to_delete == self._active_character_slot then
		for slot_counter = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
			if Global.savefile_manager.meta_data_list[slot_counter] and Global.savefile_manager.meta_data_list[slot_counter].cache and slot_counter ~= slot_to_delete then
				self._selected_character_slot = -1
				self._active_character_slot = -1
				self._slot_to_select = slot_counter
				new_slot = slot_counter

				break
			end
		end
	else
		self._selected_character_slot = -1
		self._slot_to_select = self._active_character_slot
		new_slot = self._active_character_slot
	end

	if new_slot == -1 then
		self._is_load_done = false
		self._is_render_done = false
		self._slots_loaded[11] = false
		self._slots_loaded[12] = false
		self._slots_loaded[13] = false
		self._slots_loaded[14] = false
		self._slots_loaded[15] = false
	else
		self:_activate_character_profile(new_slot)
		managers.savefile:set_save_progress_slot(new_slot)
		managers.savefile:save_last_selected_character_profile_slot()
	end

	self._character_slot_to_delete = nil
end

function CharacterSelectionGui:update(t, dt)
	if not self._is_load_done and not self._is_render_done then
		self._is_load_done = true

		for slot_index = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
			if self._slots_loaded[slot_index] == false then
				if Global.savefile_manager.meta_data_list[slot_index].is_deleting and Global.savefile_manager.meta_data_list[slot_index].cache then
					self._is_load_done = false

					managers.savefile:_load(slot_index, false, nil)
				elseif Global.savefile_manager.meta_data_list[slot_index].is_deleting and not Global.savefile_manager.meta_data_list[slot_index].cache then
					Global.savefile_manager.meta_data_list[slot_index].is_deleting = nil
					self._is_load_done = true

					self:destroy_character_unit(slot_index)
					self:show_selected_character_details(slot_index)
				elseif Global.savefile_manager.meta_data_list and Global.savefile_manager.meta_data_list[slot_index] and Global.savefile_manager.meta_data_list[slot_index].is_cached_slot and Global.savefile_manager.meta_data_list[slot_index].cache then
					self._slots_loaded[slot_index] = true
				elseif Global.savefile_manager.meta_data_list and Global.savefile_manager.meta_data_list[slot_index] and not Global.savefile_manager.meta_data_list[slot_index].is_cached_slot and Global.savefile_manager.meta_data_list[slot_index].is_load_done then
					self._slots_loaded[slot_index] = true
				else
					self._is_load_done = false
				end
			end
		end
	end

	if not self._initialisation_done then
		self._initialisation_done = true
		self._is_load_done = false
		self._is_render_done = false
	end

	if self._is_load_done and not self._transition_flag and not self._is_render_done then
		self._characters_list:refresh_data()

		self._is_render_done = true

		self._characters_list:set_selected(true, false)

		local last_selected_slot = self._slot_to_select

		if last_selected_slot ~= nil and last_selected_slot ~= -1 then
			self:_activate_character_profile(last_selected_slot)
		end

		if self._characters_list:selected_item() then
			self._characters_list:select_item_by_value(last_selected_slot, true)
		end

		if managers.savefile:get_active_characters_count() > 0 then
			managers.raid_menu:set_close_menu_allowed(true)
		else
			managers.raid_menu:set_close_menu_allowed(false)
		end
	end
end

function CharacterSelectionGui:_bind_active_slot_controller_inputs()
	Application:debug("[CharacterSelectionGui:_bind_active_slot_controller_inputs]")

	local bindings = {
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_on_character_customize")
		},
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_character_nation")
		},
		{
			key = Idstring("menu_controller_trigger_right"),
			callback = callback(self, self, "_on_character_rename")
		},
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_character_delete")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_character_customize",
			"menu_legend_delete",
			"menu_legend_character_nation",
			"menu_legend_character_rename"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end

function CharacterSelectionGui:_bind_inactive_slot_controller_inputs()
	Application:debug("[CharacterSelectionGui:_bind_inactive_slot_controller_inputs]")

	local bindings = {
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_character_delete")
		},
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_on_character_select")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_delete",
			"menu_legend_character_select"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end

function CharacterSelectionGui:_bind_empty_slot_controller_inputs()
	Application:debug("[CharacterSelectionGui:_bind_empty_slot_controller_inputs]")

	local bindings = {
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_on_character_create")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_character_create"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)
end

function CharacterSelectionGui:_on_character_customize()
	Application:trace("[CharacterSelectionGui:_on_character_customize]")
	self:_customize_character()
end

function CharacterSelectionGui:_on_character_rename()
	Application:trace("[CharacterSelectionGui:_on_character_rename]")

	local cache = Global.savefile_manager.meta_data_list[self._selected_character_slot].cache
	local profile_name = cache.PlayerManager.character_profile_name
	local params = {
		callback_yes = callback(self, self, "_callback_yes_function"),
		textbox_value = profile_name
	}

	managers.menu:show_character_create_dialog(params)
end

function CharacterSelectionGui:_on_character_nation()
	Application:trace("[CharacterSelectionGui:_on_character_nation]")
	self:_change_nationality(self._selected_character_slot)
end

function CharacterSelectionGui:_on_character_delete()
	Application:trace("[CharacterSelectionGui:_on_character_delete]")
	self:_delete_character(self._selected_character_slot)
end

function CharacterSelectionGui:_on_character_select()
	Application:trace("[CharacterSelectionGui:_on_character_select]")
	self:activate_selected_character()
end

function CharacterSelectionGui:_on_character_create()
	Application:trace("[CharacterSelectionGui:_on_character_create]")
	self:_create_character()
end
