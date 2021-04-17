CharacterSelectionGui = CharacterSelectionGui or class(RaidGuiBase)

function CharacterSelectionGui:init(ws, fullscreen_ws, node, component_name)
	self._loading_units = {}

	CharacterSelectionGui.super.init(self, ws, fullscreen_ws, node, component_name)

	self._character_spawn_location = nil

	managers.raid_menu:save_sync_player_data()
	self._node.components.raid_menu_header:set_screen_name("character_selection_title")

	self._pre_close_screen_loading_done_callback = callback(self, self, "_pre_close_screen_loading_done")

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
		w = 416,
		name = "subtitle_profiles",
		h = 32,
		y = 96,
		x = 0,
		text = self:translate("character_selection_subtitle", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.large,
		color = tweak_data.gui.colors.raid_white
	})
	self._root_panel:label({
		w = 416,
		name = "subtitle_small_profiles",
		h = 32,
		y = 128,
		x = 0,
		text = self:translate("character_selection_subtitle_small", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_grey
	})

	self._characters_list = self._root_panel:list_active({
		selection_enabled = true,
		name = "characters_list",
		h = 480,
		w = 650,
		y = 224,
		vertical_spacing = 2,
		item_h = 94,
		x = 0,
		item_class = RaidGUIControlListItemCharacterSelect,
		on_item_clicked_callback = callback(self, self, "_on_item_click"),
		on_item_selected_callback = callback(self, self, "_on_item_selected"),
		on_item_double_clicked_callback = callback(self, self, "_on_item_double_click"),
		data_source_callback = callback(self, self, "_data_source_characters_list"),
		special_action_callback = callback(self, self, "_character_action_callback")
	})
	self._select_character_button = self._root_panel:long_primary_button({
		name = "select_character_button",
		visible = false,
		y = 736,
		x = 0,
		text = self:translate("character_selection_select_character_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "on_select_character_button")
	})
	self._select_character_button_disabled = self._root_panel:long_primary_button_disabled({
		name = "select_character_button_disabled",
		visible = true,
		y = 736,
		x = 0,
		text = self:translate("character_selection_selected_character_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER
	})

	self._select_character_button:set_x((416 - self._select_character_button:w()) / 2)
	self._select_character_button_disabled:set_x((416 - self._select_character_button_disabled:w()) / 2)

	self._profile_name_label = self._root_panel:label({
		name = "profile_name_label",
		h = 41,
		w = 356,
		align = "right",
		text = "PROFILE NAME 01",
		y = 96,
		x = 1376,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_38,
		color = tweak_data.gui.colors.raid_white
	})

	self._profile_name_label:set_right(self._root_panel:right())

	self._character_name_label = self._root_panel:label({
		name = "character_name_label",
		h = 32,
		w = 356,
		align = "right",
		text = "KURGAN",
		y = 136,
		x = 1376,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey
	})

	self._character_name_label:set_right(self._root_panel:right())

	self._right_side_info = self._root_panel:create_custom_control(RaidGUIControlCharacterDescription, {
		name = "right_side_info_panel",
		h = 680,
		y = 192,
		w = 356,
		x = 1376
	}, {})

	self._right_side_info:set_right(self._root_panel:right())
end

function CharacterSelectionGui:_data_source_characters_list()
	local characters = {}

	for slot_index = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
		local slot_data = Global.savefile_manager.meta_data_list[slot_index]

		if slot_data.cache then
			local character_name = slot_data.cache.PlayerManager.character_profile_name

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
	elseif action == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_DELETE then
		if slot_index then
			self:_delete_character(slot_index)
		end
	elseif action == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CREATE then
		self:_create_character()
	end
end

function CharacterSelectionGui:_customize_character()
	self._open_customization_screen_flag = true
	self._open_creation_screen_flag = false

	self:_pre_close_screen()
end

function CharacterSelectionGui:_delete_character(slot_index)
	if managers.network:session():has_other_peers() and managers.savefile:get_active_characters_count() <= 1 then
		local params = {
			text = managers.localization:text("character_profile_last_character_delete_forbiden_in_multiplayer")
		}

		managers.menu:show_last_character_delete_forbiden_in_multiplayer(params)

		return
	end

	self._open_customization_screen_flag = false
	self._open_creation_screen_flag = false
	self._character_slot_to_delete = slot_index

	self:show_character_delete_confirmation(callback(self, self, "on_item_yes_delete_characters_list"))
end

function CharacterSelectionGui:_create_character()
	managers.savefile:set_create_character_slot(self._selected_character_slot)

	self._open_customization_screen_flag = false
	self._open_creation_screen_flag = true

	self:_pre_close_screen()
end

function CharacterSelectionGui:_on_item_click(slot_index)
	Application:trace("[CharacterSelectionGui:_on_item_click]")
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
	for slot_index = SavefileManager.CHARACTER_PROFILE_STARTING_SLOT, SavefileManager.CHARACTER_PROFILE_STARTING_SLOT + SavefileManager.CHARACTER_PROFILE_SLOTS_COUNT - 1 do
		if Global.savefile_manager.meta_data_list and Global.savefile_manager.meta_data_list[slot_index] then
			Global.savefile_manager.meta_data_list[slot_index].is_load_done = false
			Global.savefile_manager.meta_data_list[slot_index].is_cached_slot = false
		end

		self:_load_slot_data(slot_index, false)
	end

	local last_selected_slot = managers.savefile:get_save_progress_slot()

	if last_selected_slot ~= -1 then
		self:_load_slot_data(last_selected_slot, false)
	end

	self._active_character_slot = last_selected_slot
end

function CharacterSelectionGui:_load_slot_data(slot_index, save_as_last_selected_slot)
	managers.warcry:reset()

	self._slots_loaded[slot_index] = false
	self._is_load_done = false
	self._is_render_done = false

	managers.savefile:_set_cache(slot_index, nil)
	managers.savefile:_load(slot_index, false, nil)
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

	if managers.controller:is_xbox_controller_present() then
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

	self:_activate_character_profile(self._selected_character_slot)
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
	local level = ""
	local class_stats = nil

	if Global.savefile_manager.meta_data_list[slot_index] and Global.savefile_manager.meta_data_list[slot_index].cache then
		cache = Global.savefile_manager.meta_data_list[slot_index].cache
		profile_name = cache.PlayerManager.character_profile_name
		nationality = cache.PlayerManager.character_profile_nation
		class_name = cache.SkillTreeManager.character_profile_base_class
		level = Application:digest_value(cache.RaidExperienceManager.level, false)
		class_stats = tweak_data.skilltree.classes[class_name].stats
	end

	if not cache then
		self._right_side_info:set_visible(false)
		self._profile_name_label:set_visible(false)
		self._character_name_label:set_visible(false)
	else
		local skills_applied = {}

		if cache.SkillTreeManager and cache.SkillTreeManager.base_class_skill_tree then
			for level_index, level in pairs(cache.SkillTreeManager.base_class_skill_tree) do
				for skill_index, skill in ipairs(level) do
					if skill.active then
						table.insert(skills_applied, skill.skill_name)
					end
				end
			end
		end

		local character_stats = managers.skilltree:calculate_stats(class_name, skills_applied)

		self._right_side_info:set_visible(true)
		self._right_side_info:set_data({
			class_name = class_name,
			nationality = nationality,
			level = level,
			class_stats = class_stats,
			character_stats = character_stats
		})
		self._profile_name_label:set_visible(true)
		self._profile_name_label:set_text(profile_name)
		self._character_name_label:set_visible(true)
		self._character_name_label:set_text(self:translate("menu_" .. nationality, true))
	end
end

function CharacterSelectionGui:show_selected_character(slot_index)
	self._loading_units[CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT] = true

	managers.dyn_resource:load(Idstring("unit"), Idstring(CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_show_selected_character_loaded", slot_index))
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
	self:get_character_spawn_location()

	if not self._spawned_character_unit then
		self:destroy_character_unit()

		local unit_name = CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT
		local position = self._character_spawn_location:position() or Vector3(0, 0, 0)
		local rotation = Rotation(0, 0, 0)
		self._spawned_character_unit = World:spawn_unit(Idstring(unit_name), position, rotation)
	end

	local random_animation_index = math.random(1, #tweak_data.character_customization.customization_animations)
	local anim_state_name = tweak_data.character_customization.customization_animations[random_animation_index]
	local state = self._spawned_character_unit:play_redirect(Idstring(anim_state_name))

	self._spawned_character_unit:anim_state_machine():set_parameter(state)
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

	if units then
		for _, unit in pairs(units) do
			if unit:name() == Idstring("units/vanilla/arhitecture/ber_a/ber_a_caracter_menu/caracter_menu_floor/caracter_menu_floor") then
				self._character_spawn_location = unit:get_object(Idstring("rp_caracter_menu_floor"))
			end
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
	Application:trace("[CharacterSelectionGui][_pre_close_screen]")
	self:destroy_character_unit()
	managers.savefile:set_save_progress_slot(self._active_character_slot)
	managers.savefile:_set_current_game_cache_slot(self._active_character_slot, true)

	if managers.savefile:get_save_progress_slot() ~= self._initial_character_slot then
		local nation = "american"

		if Global.savefile_manager.meta_data_list[Global.savefile_manager.current_game_cache_slot].cache then
			nation = Global.savefile_manager.meta_data_list[Global.savefile_manager.current_game_cache_slot].cache.PlayerManager.character_profile_nation
		end

		managers.character_customization:reaply_character_criminal(nation)
		managers.savefile:add_load_done_callback(self._pre_close_screen_loading_done_callback)

		local last_selected_slot = managers.savefile:get_save_progress_slot()

		managers.savefile:save_last_selected_character_profile_slot()
		self:_load_slot_data(last_selected_slot, true)
	else
		self:_extra_character_setup()
	end

	self:reset_weapon_challenges()
end

function CharacterSelectionGui:_extra_character_setup()
	Application:trace("[CharacterSelectionGui:_extra_character_setup]")
	managers.hud:refresh_player_panel()

	local selection_category_index = managers.player:local_player():inventory():equipped_selection()

	managers.player:_internal_load()
	managers.player:local_player():inventory():equip_selection(selection_category_index, false)
	managers.player:local_player():camera():play_redirect(PlayerStandard.IDS_EQUIP)
	managers.hud:set_ammo_amount(1, managers.player:local_player():inventory():available_selections()[1].unit:base():ammo_info())
	managers.hud:set_ammo_amount(2, managers.player:local_player():inventory():available_selections()[2].unit:base():ammo_info())

	local grenade_icon = tweak_data.projectiles[managers.player:local_player():inventory():available_selections()[3].unit:base().name_id].icon
	local grenade_amount = Application:digest_value(Global.player_manager.synced_grenades[managers.network:session():local_peer():id()].amount, false)

	managers.hud:set_teammate_grenades_amount(HUDManager.PLAYER_PANEL, {
		icon = grenade_icon,
		amount = grenade_amount
	})

	if self._open_customization_screen_flag then
		managers.raid_menu:open_menu("character_customization_menu")
	elseif self._open_creation_screen_flag then
		managers.raid_menu:open_menu("profile_creation_menu")
	end

	managers.weapon_skills:update_weapon_part_animation_weights()
end

function CharacterSelectionGui:_pre_close_screen_loading_done()
	Application:trace("[CharacterSelectionGui:_pre_close_screen_loading_done]")
	managers.savefile:remove_load_done_callback(self._pre_close_screen_loading_done_callback)
	managers.raid_menu:load_sync_player_data()

	if Global.savefile_manager.meta_data_list[Global.savefile_manager.current_game_cache_slot] and Global.savefile_manager.meta_data_list[Global.savefile_manager.current_game_cache_slot].cache then
		local character_nationality = Global.savefile_manager.meta_data_list[Global.savefile_manager.current_game_cache_slot].cache.PlayerManager.character_profile_nation
		local local_peer = managers.network:session():local_peer()
		local team_id = tweak_data.levels:get_default_team_ID("player")

		managers.network:session():send_to_peers_synched("set_character_customization", local_peer._unit, managers.blackmarket:outfit_string(), local_peer:outfit_version(), local_peer._id)
		managers.network:session():send_to_peers_synched("sync_character_level", managers.experience:current_level())
		managers.network:session():send_to_peers_synched("sync_character_class_nationality", managers.skilltree:get_character_profile_class(), managers.player:get_character_profile_nation())
		managers.player:local_player():camera():camera_unit():customizationfps():attach_fps_hands(character_nationality, managers.player:get_customization_equiped_upper_name(), managers.character_customization:get_current_version_to_attach())
	end

	local local_peer = managers.network:session():local_peer()

	local_peer:set_outfit_string(managers.blackmarket:outfit_string())
	managers.network:session():check_send_outfit()
	managers.player:sync_upgrades()
	managers.player:set_character_class(managers.skilltree:get_character_profile_class())
	self:_extra_character_setup()
	managers.network:start_matchmake_attributes_update()
	self:reset_weapon_challenges()
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
			managers.dyn_resource:unload(Idstring("unit"), Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
		end
	end

	self:_enable_dof()
	CharacterSelectionGui.super.close(self)

	self._closing_screen = true
end

function CharacterSelectionGui:on_escape()
	Application:trace("[CharacterSelectionGui:on_escape]")
	self:_pre_close_screen()
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

	if self._is_load_done and not self._is_render_done then
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
			self._characters_list:activate_item_by_value(last_selected_slot)
		else
			managers.raid_menu:set_close_menu_allowed(false)
		end
	end
end

function CharacterSelectionGui:_bind_active_slot_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_character_customize")
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
			"menu_legend_delete",
			"menu_legend_character_customize"
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
