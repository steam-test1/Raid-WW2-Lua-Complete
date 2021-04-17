WeaponSelectionGui = WeaponSelectionGui or class(RaidGuiBase)
WeaponSelectionGui.CATEGORY_TABS_PADDING = 30
WeaponSelectionGui.CATEGORY_TABS_Y = 18
WeaponSelectionGui.SCREEN_STATE_WEAPON_LIST = "weapon_list"
WeaponSelectionGui.SCREEN_STATE_UPGRADE = "upgrade"
WeaponSelectionGui.WEAPON_EQUIP_SOUND = "weapon_upgrade_apply"
WeaponSelectionGui.WEAPON_ERROR_EQUIP_SOUND = "generic_fail_sound"
WeaponSelectionGui.TOGGLE_SWITCH_BINDING = {
	{
		"menu_enable_disable_scope",
		"BTN_X",
		"menu_controller_face_left"
	}
}
WeaponSelectionGui.TOGGLE_COSMETICS_BINDING = {
	{
		"menu_enable_disable_weapon_cosmetics",
		"BTN_DPAD_RIGHT",
		"menu_controller_dpad_right"
	}
}

local function f2s(value)
	local value = math.floor(value * 10) / 10

	if value * 10 % 10 ~= 0 then
		return string.format("%.0f", tostring(value))
	else
		return tostring(value)
	end
end

function WeaponSelectionGui:init(ws, fullscreen_ws, node, component_name)
	WeaponSelectionGui.super.init(self, ws, fullscreen_ws, node, component_name)

	self._preloaded_weapon_part_names = {}

	self:_set_screen_state(WeaponSelectionGui.SCREEN_STATE_WEAPON_LIST)
	managers.raid_menu:hide_background()

	self._cached_owned_melee_weapons = managers.weapon_inventory:get_owned_melee_weapons()
end

function WeaponSelectionGui:_setup_properties()
	WeaponSelectionGui.super._setup_properties(self)

	self._background = nil
	self._background_rect = nil
end

function WeaponSelectionGui:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("menu_header_weapons_screen_name")

	self._loading_units = {}
	self._loading_parts_units = {}
end

function WeaponSelectionGui:_set_screen_state(state)
	self._screen_state = state

	managers.raid_menu:register_on_escape_callback(callback(self, self, "back_pressed"))
end

function WeaponSelectionGui:update(t, dt)
end

function WeaponSelectionGui:close()
	if self._parts_being_loaded then
		managers.weapon_factory:disassemble(self._parts_being_loaded)
	end

	if self._loading_units then
		for unit_name, unit_loading_flag in pairs(self._loading_units) do
			managers.dyn_resource:unload(Idstring("unit"), Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
		end
	end

	managers.weapon_skills:deactivate_all_upgrades_for_bm_weapon_category_id(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)
	managers.weapon_skills:deactivate_all_upgrades_for_bm_weapon_category_id(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID)

	local equipped_primary_weapon_id = managers.weapon_inventory:get_equipped_primary_weapon_id()
	local equipped_secondary_weapon_id = managers.weapon_inventory:get_equipped_secondary_weapon_id()

	managers.weapon_skills:update_weapon_skills(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID, equipped_primary_weapon_id, WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE)
	managers.weapon_skills:update_weapon_skills(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID, equipped_secondary_weapon_id, WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE)
	managers.player:_internal_load()
	managers.challenge:deactivate_all_challenges()
	managers.weapon_skills:activate_current_challenges_for_weapon(managers.blackmarket:equipped_primary().weapon_id)
	managers.player:local_player():camera():play_redirect(PlayerStandard.IDS_EQUIP)
	managers.weapon_skills:update_weapon_part_animation_weights()
	self._rotate_weapon:set_unit(nil)
	self:_enable_dof()
	WeaponSelectionGui.super.close(self)
	self:destroy_weapon_parts()
	self:destroy_weapon()
	managers.hud:remove_updator("mission_selection_gui")
	managers.savefile:save_game(Global.savefile_manager.save_progress_slot)
end

function WeaponSelectionGui:_layout()
	WeaponSelectionGui.super._layout(self)
	self:_disable_dof()
	self:clear_grenade_secondary_breadbrumbs()
	self:_layout_use_weapon_parts_as_cosmetics()
	self:_layout_left_side_panels()
	self:_layout_category_tabs()
	self:_layout_lists()
	self:_layout_weapon_stats()
	self:_layout_equip_button()
	self:_layout_skill_panel()
	self:_layout_rotate_unit()
	self:_layout_scope_switch()
	self:_layout_available_points()
	self:_layout_upgrade_button()
	self:_layout_weapon_name()
	self:bind_controller_inputs_choose_weapon()
	self:set_weapon_select_allowed(true)
	self._weapon_list:set_selected(true, true)
	self:on_weapon_category_selected(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)
end

function WeaponSelectionGui:clear_grenade_secondary_breadbrumbs()
	if managers.breadcrumb._breadcrumbs.character and managers.breadcrumb._breadcrumbs.character.weapon_secondary then
		for i = 1, #tweak_data.projectiles._projectiles_index do
			if managers.breadcrumb._breadcrumbs.character.weapon_secondary[tweak_data.projectiles._projectiles_index[i]] then
				managers.breadcrumb._breadcrumbs.character.weapon_secondary[tweak_data.projectiles._projectiles_index[i]] = nil
			end
		end
	end
end

function WeaponSelectionGui:set_weapon_select_allowed(value)
	self._weapon_select_allowed = value

	self._list_tabs:set_abort_selection(not value)
	self._weapon_list:set_abort_selection(not value)
end

function WeaponSelectionGui:_layout_use_weapon_parts_as_cosmetics()
	local weapon_parts_toggle_params = {
		name = "toggle_weapon_parts",
		h = 66,
		w = 200,
		align = "right",
		text_align = "right",
		y = 120,
		x = 1200,
		layer = 1,
		description = self:translate("menu_enable_disable_weapon_cosmetics", true),
		on_click_callback = callback(self, self, "on_toggle_weapon_parts_click")
	}
	self._weapon_parts_toggle = self._root_panel:switch_button(weapon_parts_toggle_params)
end

function WeaponSelectionGui:_layout_left_side_panels()
	self._weapon_selection_panel = self._root_panel:panel({
		name = "weapon_selection_panel",
		h = 924,
		y = 96,
		w = 728,
		x = 0,
		layer = 1
	})
	self._weapon_skills_panel = self._root_panel:panel({
		visible = false,
		name = "weapon_skills_panel",
		h = 924,
		y = 96,
		w = 480,
		x = 0,
		layer = 1
	})
end

function WeaponSelectionGui:_layout_category_tabs()
	local category_tabs_params = {
		tab_align = "center",
		name = "category_tabs",
		initial_tab_idx = 1,
		tab_height = 64,
		y = 0,
		x = 0,
		on_click_callback = callback(self, self, "on_weapon_category_selected"),
		parent_control_ref = self,
		tabs_params = {
			{
				name = "tab_primary",
				text = self:translate("menu_weapons_tab_category_primary", true),
				breadcrumb = {
					check_callback = callback(managers.weapon_skills, managers.weapon_skills, "has_new_weapon_upgrades", {
						weapon_category = WeaponInventoryManager.CATEGORY_NAME_PRIMARY
					}),
					category = BreadcrumbManager.CATEGORY_WEAPON_PRIMARY
				},
				callback_param = WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID
			},
			{
				name = "tab_secondary",
				text = self:translate("menu_weapons_tab_category_secondary", true),
				breadcrumb = {
					check_callback = callback(managers.weapon_skills, managers.weapon_skills, "has_new_weapon_upgrades", {
						weapon_category = WeaponInventoryManager.CATEGORY_NAME_SECONDARY
					}),
					category = BreadcrumbManager.CATEGORY_WEAPON_SECONDARY
				},
				callback_param = WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID
			},
			{
				name = "tab_grenades",
				text = self:translate("menu_weapons_tab_category_grenades", true),
				callback_param = WeaponInventoryManager.BM_CATEGORY_GRENADES_ID
			},
			{
				name = "tab_melee",
				text = self:translate("menu_weapons_tab_category_melee", true),
				breadcrumb = {
					category = BreadcrumbManager.CATEGORY_WEAPON_MELEE
				},
				callback_param = WeaponInventoryManager.BM_CATEGORY_MELEE_ID
			}
		}
	}
	self._list_tabs = self._weapon_selection_panel:tabs(category_tabs_params)
	self._selected_weapon_category_id = WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID
	self._equippable_filters_tabs = self._weapon_selection_panel:tabs({
		name = "equippable_filters_tabs",
		tab_width = 140,
		initial_tab_idx = 1,
		tab_align = "center",
		tab_height = 64,
		y = 54,
		x = 0,
		icon = tweak_data.gui.icons.ico_filter,
		item_class = RaidGUIControlTabFilter,
		on_click_callback = callback(self, self, "on_click_filter_equippable"),
		tabs_params = {
			{
				name = "tab_all",
				callback_param = "all",
				text = self:translate("menu_filter_all", true)
			},
			{
				name = "tab_equippable",
				callback_param = "equippable",
				text = self:translate("menu_weapons_filter_equippable", true)
			}
		}
	})
	self._selected_filter = "all"
end

function WeaponSelectionGui:_layout_lists()
	local weapon_list_scrollable_area_params = {
		name = "weapon_list_scrollable_area",
		h = 456,
		y = 128,
		w = 448,
		x = 0,
		scroll_step = 19
	}
	self._weapon_list_scrollable_area = self._weapon_selection_panel:scrollable_area(weapon_list_scrollable_area_params)
	local weapon_list_params = {
		selection_enabled = true,
		name = "weapon_list",
		w = 448,
		on_mouse_over_sound_event = "highlight",
		on_mouse_click_sound_event = "weapon_click",
		y = 0,
		item_h = 62,
		x = 0,
		use_unlocked = false,
		on_item_clicked_callback = callback(self, self, "on_item_clicked_weapon_list"),
		on_item_selected_callback = callback(self, self, "on_item_selected_weapon_list"),
		on_item_double_clicked_callback = callback(self, self, "on_item_double_click"),
		data_source_callback = callback(self, self, "data_source_weapon_list"),
		item_class = RaidGUIControlListItemWeapons,
		scrollable_area_ref = self._weapon_list_scrollable_area
	}
	self._weapon_list = self._weapon_list_scrollable_area:get_panel():list_active(weapon_list_params)
end

function WeaponSelectionGui:_layout_weapon_stats()
	local weapon_stats_params = {
		selection_enabled = false,
		name = "weapon_stats",
		tab_width = 160,
		y = 771,
		tab_height = 60,
		x = 550,
		label_class = RaidGUIControlLabelNamedValueWithDelta
	}
	self._weapon_stats = self._root_panel:create_custom_control(RaidGUIControlWeaponStats, weapon_stats_params)
	local melee_weapon_stats_params = {
		selection_enabled = false,
		name = "melee_weapon_stats",
		tab_width = 200,
		y = 771,
		tab_height = 60,
		x = 550,
		label_class = RaidGUIControlLabelNamedValue
	}
	self._melee_weapon_stats = self._root_panel:create_custom_control(RaidGUIControlMeleeWeaponStats, melee_weapon_stats_params)
	local grenade_weapon_stats_params = {
		selection_enabled = false,
		name = "grenade_weapon_stats",
		tab_width = 180,
		y = 771,
		tab_height = 60,
		x = 550,
		label_class = RaidGUIControlLabelNamedValue
	}
	self._grenade_weapon_stats = self._root_panel:create_custom_control(RaidGUIControlGrenadeWeaponStats, grenade_weapon_stats_params)
end

function WeaponSelectionGui:_layout_equip_button()
	local equip_button_params = {
		name = "equip_button",
		visible = false,
		y = 710,
		x = 0,
		layer = 1,
		text = self:translate("menu_weapons_equip", true),
		on_click_callback = callback(self, self, "on_equip_button_click"),
		on_click_sound = WeaponSelectionGui.WEAPON_EQUIP_SOUND
	}
	self._equip_button = self._weapon_selection_panel:short_primary_button(equip_button_params)
	local equip_disabled_button_params = {
		name = "equip_disabled_button",
		visible = true,
		y = 710,
		x = 0,
		layer = 1,
		text = self:translate("menu_weapons_equipped", true)
	}
	self._equip_disabled_button = self._weapon_selection_panel:short_primary_button_disabled(equip_disabled_button_params)
	local cant_equip_explanation_label_params = {
		y = 722,
		name = "cant_equip_explenation_label",
		h = 60,
		wrap = true,
		w = 520,
		align = "left",
		word_wrap = true,
		text = "",
		visible = false,
		x = 0,
		layer = 1,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_red
	}
	self._cant_equip_explanation_label = self._weapon_selection_panel:label(cant_equip_explanation_label_params)
end

function WeaponSelectionGui:_layout_skill_panel()
	local weapon_skills_params = {
		name = "weapon_skills",
		h = 440,
		y = 11,
		w = 448,
		x = 0,
		layer = 1,
		on_mouse_enter_callback = callback(self, self, "_on_mouse_enter_weapon_skill_button"),
		on_mouse_exit_callback = callback(self, self, "_on_mouse_exit_weapon_skill_button"),
		on_selected_weapon_skill_callback = callback(self, self, "_on_selected_weapon_skill_callback"),
		on_unselected_weapon_skill_callback = callback(self, self, "_on_unselected_weapon_skill_callback"),
		on_click_weapon_skill_callback = callback(self, self, "_on_click_weapon_skill_callback")
	}
	self._weapon_skills = self._weapon_skills_panel:create_custom_control(RaidGUIControlWeaponSkills, weapon_skills_params)
	local skill_desc_params = {
		name = "skill_desc",
		h = 244,
		y = 447,
		x = 0,
		layer = 1,
		w = self._weapon_skills_panel:w()
	}
	self._skill_desc = self._weapon_skills_panel:create_custom_control(RaidGUIControlWeaponSkillDesc, skill_desc_params)
	local apply_button_params = {
		name = "apply_button",
		y = 710,
		x = 0,
		layer = 1,
		text = self:translate("menu_weapons_apply", true),
		on_click_callback = callback(self, self, "on_apply_button_click"),
		on_click_sound = WeaponSelectionGui.WEAPON_EQUIP_SOUND
	}
	self._apply_button = self._weapon_skills_panel:short_primary_button(apply_button_params)

	self._apply_button:disable()

	local available_points_skills_params = {
		w = 190,
		name = "available_points_skills",
		h = 64,
		value_align = "left",
		align = "left",
		visible = false,
		value_padding = 3,
		y = 590,
		x = 0,
		layer = 1,
		text = self:translate("menu_available_points", true),
		value = "" .. managers.weapon_skills:get_available_weapon_skill_points(),
		value_color = tweak_data.gui.colors.raid_red,
		value_font_size = tweak_data.gui.font_sizes.size_32,
		font_size = tweak_data.gui.font_sizes.medium
	}
	self._available_points_skills_label = self._weapon_skills_panel:label_named_value(available_points_skills_params)
	local upgrade_cost_params = {
		w = 190,
		name = "upgrade_cost",
		h = 64,
		value_align = "left",
		value = "00",
		align = "left",
		visible = false,
		value_padding = 3,
		y = 590,
		x = 200,
		layer = 1,
		text = self:translate("menu_upgrade_cost", true),
		value_color = tweak_data.gui.colors.raid_red,
		value_font_size = tweak_data.gui.font_sizes.size_32,
		font_size = tweak_data.gui.font_sizes.medium
	}
	self._upgrade_cost_label = self._weapon_skills_panel:label_named_value(upgrade_cost_params)
end

function WeaponSelectionGui:_layout_rotate_unit()
	local params_rotate_weapon = {
		x = 470,
		name = "rotate_weapon",
		h = 570,
		mouse_release_sound = "weapon_turn_stoped",
		w = 1220,
		mouse_over_sound = "weapon_mouse_over",
		sound_click_every_n_degrees = 10,
		y = 90,
		rotation_click_sound = "weapon_turn",
		mouse_click_sound = "weapon_click"
	}
	self._rotate_weapon = self._root_panel:rotate_unit(params_rotate_weapon)
end

function WeaponSelectionGui:_layout_scope_switch()
	local scope_switch_params = {
		name = "scope_switch",
		h = 66,
		w = 192,
		align = "right",
		text_align = "right",
		y = 120,
		x = 1536,
		layer = 1,
		description = self:translate("menu_enable_disable_scope", true),
		on_click_callback = callback(self, self, "on_enable_scope_click")
	}
	self._scope_switch = self._root_panel:switch_button(scope_switch_params)
end

function WeaponSelectionGui:toggle_scope_switch()
	self._scope_switch:confirm_pressed()
end

function WeaponSelectionGui:toggle_weapon_parts()
	self._weapon_parts_toggle:confirm_pressed()
end

function WeaponSelectionGui:_layout_available_points()
	local available_points_params = {
		w = 192,
		name = "available_points_label",
		h = 90,
		value_padding = 10,
		y = 672,
		x = 1536,
		layer = 1,
		text = self:translate("menu_available_points", true),
		value = "" .. managers.weapon_skills:get_available_weapon_skill_points(),
		value_color = tweak_data.gui.colors.raid_red
	}
	self._available_points_label = self._root_panel:label_named_value(available_points_params)

	self._available_points_label:hide()
end

function WeaponSelectionGui:_layout_upgrade_button()
	local upgrade_button_params = {
		name = "upgrade_button",
		y = 806,
		x = 1536,
		layer = 1,
		text = self:translate("menu_weapons_upgrade", true),
		on_click_callback = callback(self, self, "on_upgrade_button_click")
	}
	self._upgrade_button = self._root_panel:short_secondary_button(upgrade_button_params)

	self._upgrade_button:hide()
end

function WeaponSelectionGui:_show_weapon_list_panel()
	self._weapon_selection_panel:show()
	self._weapon_skills_panel:hide()
	self._upgrade_button:show()
	self:_set_screen_state(WeaponSelectionGui.SCREEN_STATE_WEAPON_LIST)

	if self._preloaded_weapon_part_names and #self._preloaded_weapon_part_names > 1 then
		local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(self._selected_weapon_id)
		local weapon_part_names = tweak_data.weapon.factory[weapon_factory_id].uses_parts
		local weapon_part_unit_path = ""

		for _, weapon_part_name in ipairs(weapon_part_names) do
			if self._preloaded_weapon_part_names[weapon_part_name] then
				weapon_part_unit_path = tweak_data.weapon.factory.parts[weapon_part_name].unit

				managers.dyn_resource:unload(Idstring("unit"), Idstring(weapon_part_unit_path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
			end
		end
	end

	self:bind_controller_inputs_choose_weapon()
end

function WeaponSelectionGui:_layout_weapon_name()
	local weapon_name_params = {
		name = "weapon_name",
		vertical = "bottom",
		h = 64,
		align = "right",
		text = "THOMPSON",
		y = 0,
		x = 1500,
		w = self._root_panel:w() / 2,
		color = tweak_data.gui.colors.raid_dirty_white,
		font_size = tweak_data.gui.font_sizes.menu_list
	}
	self._weapon_name_label = self._root_panel:label(weapon_name_params)

	self._weapon_name_label:set_right(self._root_panel:right())
	self._weapon_name_label:set_bottom(58)
end

function WeaponSelectionGui:_update_scope_switch()
	if managers.player:upgrade_value("player", "can_use_scope") == true and managers.weapon_skills:get_scope_weapon_part_name(self._selected_weapon_id) then
		self._scope_switch:show()

		local use_scope = managers.weapon_skills:get_player_using_scope(self._selected_weapon_id)

		self._scope_switch:set_value_and_render(use_scope)
	else
		self._scope_switch:hide()
	end
end

function WeaponSelectionGui:on_toggle_weapon_parts_click()
	Application:trace("[WeaponSelectionGui:on_toggle_weapon_parts_click] ", self._weapon_parts_toggle:get_value())

	local is_toggle_button_active = self._weapon_parts_toggle:get_value()

	if self._selected_weapon_id then
		managers.weapon_skills:set_cosmetics_flag_for_weapon_id(self._selected_weapon_id, is_toggle_button_active)
		self:_recreate_and_show_weapon_parts()
	end
end

function WeaponSelectionGui:on_weapon_category_selected(selected_category)
	if selected_category == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or selected_category == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		self._upgrade_button:show()
	else
		self._upgrade_button:hide()
		self._available_points_label:hide()
	end

	self:destroy_weapon_parts()
	self:destroy_weapon()

	self._spawned_unit = nil
	self._selected_weapon_category_id = selected_category

	self._weapon_list:refresh_data()

	local weapon_id = self:_get_weapon_id_from_selected_category()

	self:_select_weapon(weapon_id, true)
	self._weapon_list_scrollable_area:setup_scroll_area()
	self:_upgrade_status()
	self:_equip_weapon()
end

function WeaponSelectionGui:_get_weapon_id_from_selected_category()
	local data = self._weapon_list:get_data()
	local result = nil

	if data then
		for _, weapon_data in pairs(data) do
			if weapon_data.selected then
				result = weapon_data.value.weapon_id

				break
			end
		end
	end

	return result
end

function WeaponSelectionGui:on_click_filter_equippable(selected_filter)
	self._selected_filter = selected_filter

	self._equip_button:hide()
	self._equip_disabled_button:hide()
	self._cant_equip_explanation_label:hide()
	self:_reselect_weapons_in_list()
	self._weapon_list_scrollable_area:setup_scroll_area()
end

function WeaponSelectionGui:on_item_clicked_weapon_list(weapon_data)
	if not self._weapon_select_allowed then
		return
	end

	self:_select_weapon(weapon_data.value.weapon_id, false)
end

function WeaponSelectionGui:on_item_selected_weapon_list(weapon_data)
	if not self._weapon_select_allowed then
		return
	end

	self:_select_weapon(weapon_data.value.weapon_id, false)
end

function WeaponSelectionGui:on_item_double_click()
	self:on_equip_button_click()
end

function WeaponSelectionGui:data_source_weapon_list()
	local result = {}
	local temp_result = {}

	if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		temp_result = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		temp_result = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID)
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		temp_result = self._cached_owned_melee_weapons or managers.weapon_inventory:get_owned_melee_weapons()
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		temp_result = managers.weapon_inventory:get_owned_grenades()
	end

	local equipped_weapon_id = nil

	if temp_result then
		for _, weapon_data in pairs(temp_result) do
			if self._selected_filter == "all" or self._selected_filter == "equippable" and weapon_data.unlocked then
				if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
					local breadcrumb_category = nil

					if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
						breadcrumb_category = BreadcrumbManager.CATEGORY_WEAPON_PRIMARY
						equipped_weapon_id = managers.weapon_inventory:get_equipped_primary_weapon_id()
					else
						breadcrumb_category = BreadcrumbManager.CATEGORY_WEAPON_SECONDARY
						equipped_weapon_id = managers.weapon_inventory:get_equipped_secondary_weapon_id()
					end

					local weapon_category = managers.weapon_inventory:get_weapon_category_name_by_bm_category_id(self._selected_weapon_category_id)
					local breadcrumb = nil

					if weapon_data.unlocked then
						breadcrumb = {
							check_callback = callback(managers.weapon_skills, managers.weapon_skills, "has_new_weapon_upgrades", {
								weapon_category = weapon_category,
								weapon_id = weapon_data.weapon_id
							}),
							category = breadcrumb_category,
							identifiers = {
								weapon_data.weapon_id
							}
						}
					end

					if self._selected_weapon_id == weapon_data.weapon_id or equipped_weapon_id == weapon_data.weapon_id then
						table.insert(result, {
							selected = true,
							text = self:translate(tweak_data.weapon[weapon_data.weapon_id].name_id, false),
							value = weapon_data,
							breadcrumb = breadcrumb
						})
					else
						table.insert(result, {
							text = self:translate(tweak_data.weapon[weapon_data.weapon_id].name_id, false),
							value = weapon_data,
							breadcrumb = breadcrumb
						})
					end
				elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
					equipped_weapon_id = managers.weapon_inventory:get_equipped_melee_weapon_id()
					local breadcrumb = {
						category = BreadcrumbManager.CATEGORY_WEAPON_MELEE,
						identifiers = {
							weapon_data.weapon_id
						}
					}

					if self._selected_weapon_id == weapon_data.weapon_id or equipped_weapon_id == weapon_data.weapon_id then
						table.insert(result, {
							selected = true,
							text = self:translate(tweak_data.blackmarket.melee_weapons[weapon_data.weapon_id].name_id, false),
							value = weapon_data,
							breadcrumb = breadcrumb
						})
					else
						table.insert(result, {
							text = self:translate(tweak_data.blackmarket.melee_weapons[weapon_data.weapon_id].name_id, false),
							value = weapon_data,
							breadcrumb = breadcrumb
						})
					end
				elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
					equipped_weapon_id = managers.weapon_inventory:get_equipped_grenade_id()

					if self._selected_weapon_id == weapon_data.weapon_id or equipped_weapon_id == weapon_data.weapon_id then
						table.insert(result, {
							selected = true,
							text = self:translate(tweak_data.projectiles[weapon_data.weapon_id].name_id, false),
							value = weapon_data
						})
					else
						table.insert(result, {
							text = self:translate(tweak_data.projectiles[weapon_data.weapon_id].name_id, false),
							value = weapon_data
						})
					end
				end
			end
		end
	end

	if self._selected_weapon_category_id ~= WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		local class_name = managers.skilltree:get_character_profile_class()

		table.sort(result, function (l, r)
			local l_level = tweak_data.skilltree:get_weapon_unlock_level(l.value.weapon_id, class_name) or 100000
			local r_level = tweak_data.skilltree:get_weapon_unlock_level(r.value.weapon_id, class_name) or 100000

			if l_level ~= r_level then
				return l_level < r_level
			end

			return l.text < r.text
		end)

		return result
	end

	table.sort(result, function (l, r)
		if l.value.unlocked and not r.value.unlocked then
			return true
		elseif not l.value.unlocked and r.value.unlocked then
			return false
		end

		return l.text < r.text
	end)
end

function WeaponSelectionGui:on_equip_button_click()
	if self._weapon_list:selected_item():data().value.unlocked and self._weapon_list:selected_item() ~= self._weapon_list:get_active_item() then
		managers.menu_component:post_event(WeaponSelectionGui.WEAPON_EQUIP_SOUND)
		self:_equip_weapon()
	elseif not self._weapon_list:selected_item():data().value.unlocked then
		managers.menu_component:post_event(WeaponSelectionGui.WEAPON_ERROR_EQUIP_SOUND)
	end
end

function WeaponSelectionGui:on_enable_scope_click()
	local checked = self._scope_switch:get_value()

	managers.weapon_skills:set_player_using_scope(self._selected_weapon_id, checked)

	local weapon_id = managers.weapon_inventory:get_equipped_primary_weapon_id()

	managers.weapon_skills:recreate_weapon_blueprint(weapon_id, WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID, nil, true)
	self:_recreate_and_show_weapon_parts()
	self:_equip_weapon()
end

function WeaponSelectionGui:on_upgrade_button_click()
	if not self._weapon_select_allowed then
		return
	end

	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(self._selected_weapon_id)
	local weapon_part_names = tweak_data.weapon.factory[weapon_factory_id].uses_parts
	local weapon_part_unit_path = ""

	for _, weapon_part_name in ipairs(weapon_part_names) do
		weapon_part_unit_path = tweak_data.weapon.factory.parts[weapon_part_name].unit

		managers.dyn_resource:load(Idstring("unit"), Idstring(weapon_part_unit_path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_on_weapon_part_unit_loaded", weapon_part_name))
	end

	self._weapon_selection_panel:hide()
	self._weapon_skills_panel:show()
	self._upgrade_button:hide()
	self._available_points_label:hide()
	self:_set_screen_state(WeaponSelectionGui.SCREEN_STATE_UPGRADE)
	self:bind_controller_inputs_upgrade_weapon_upgrade_forbiden()
	self._weapon_list:set_selected(false)
	self._weapon_skills:set_weapon(self._selected_weapon_category_id, self._selected_weapon_id)
	self._weapon_skills:set_selected(true, false)
	self:_refresh_available_points()
	self._apply_button:disable()
end

function WeaponSelectionGui:on_apply_button_click()
	self._apply_button:disable()

	local weapon_points_to_apply = self._weapon_skills:get_temp_points()

	self._weapon_skills:apply_selected_skills()
	managers.statistics:spend_weapon_points(weapon_points_to_apply)
	managers.statistics:publish_camp_stats_to_steam()
end

function WeaponSelectionGui:_on_click_weapon_skill_callback(button, data)
	Application:trace("[WeaponSelectionGui:_on_click_weapon_skill_callback] ", button._state, button._name, inspect(data))

	if button:get_state() == RaidGUIControlButtonWeaponSkill.STATE_NORMAL then
		self:_remove_weapon_skill_from_temp_skills(data.value, false)

		local selected_skills = self._weapon_skills:get_temp_skills()
		local selected_skill_count = 0

		for _ in pairs(selected_skills) do
			selected_skill_count = selected_skill_count + 1
		end

		if selected_skill_count == 0 then
			if managers.raid_menu:is_pc_controller() then
				self._apply_button:disable()
			else
				self:bind_controller_inputs_upgrade_weapon_upgrade_forbiden()
			end
		end
	elseif button:get_state() == RaidGUIControlButtonWeaponSkill.STATE_SELECTED then
		self:_add_weapon_skill_to_temp_skills(data.value, false)

		if managers.raid_menu:is_pc_controller() then
			self._apply_button:enable()
		else
			self:bind_controller_inputs_upgrade_weapon()
		end
	end
end

function WeaponSelectionGui:_add_temp_points(value)
	local temp_weapon_points = self._weapon_skills:get_temp_points()
	temp_weapon_points = temp_weapon_points + value

	self._weapon_skills:set_temp_points(temp_weapon_points)
end

function WeaponSelectionGui:_refresh_available_points()
	local available_points = self._weapon_skills:get_available_points()

	self._available_points_skills_label:set_value("" .. available_points)
end

function WeaponSelectionGui:_selected_weapon_skill_button(button, data, tier)
	if data and data.value then
		self._skill_desc:set_weapon_skill(data)
	end

	self:_add_weapon_skill_to_temp_skills(data.value, true)

	local button_state = button:get_state()

	if button_state == RaidGUIControlButtonWeaponSkill.STATE_NORMAL or button_state == RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE or button_state == RaidGUIControlButtonWeaponSkill.STATE_CHALLENGE_ACTIVE or button_state == RaidGUIControlButtonWeaponSkill.STATE_BLOCKED then
		local upgrade_level = managers.weapon_skills:get_weapon_skills_current_upgrade_level(data.value.skill_name, self._selected_weapon_category_id)

		if upgrade_level > 0 then
			managers.weapon_skills:update_weapon_skill(data.value.skill_name, {
				value = upgrade_level
			}, self._selected_weapon_category_id, WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE)
		end

		managers.weapon_skills:update_weapon_skill(data.value.skill_name, data.value, self._selected_weapon_category_id, WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE)
	end

	self:_update_weapon_stats(false)
end

function WeaponSelectionGui:_unselected_weapon_skill_button(button, data)
	local button_state = button:get_state()

	if button_state == RaidGUIControlButtonWeaponSkill.STATE_NORMAL or button_state == RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE or button_state == RaidGUIControlButtonWeaponSkill.STATE_CHALLENGE_ACTIVE or button_state == RaidGUIControlButtonWeaponSkill.STATE_BLOCKED then
		self:_remove_weapon_skill_from_temp_skills(data.value, true)

		local upgrade_level = managers.weapon_skills:get_weapon_skills_current_upgrade_level(data.value.skill_name, self._selected_weapon_category_id)

		if upgrade_level > 0 then
			managers.weapon_skills:update_weapon_skill(data.value.skill_name, {
				value = upgrade_level
			}, self._selected_weapon_category_id, WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE)
		end

		local weapon_skill_button = self:_get_marked_row_skill_button(button:get_data().i_skill)

		if weapon_skill_button then
			managers.weapon_skills:update_weapon_skill(weapon_skill_button:get_data().value.skill_name, weapon_skill_button:get_data().value, self._selected_weapon_category_id, WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE)
		end

		self:_update_weapon_stats(false)
	end
end

function WeaponSelectionGui:_on_mouse_enter_weapon_skill_button(button, data)
	self:_selected_weapon_skill_button(button, data)
end

function WeaponSelectionGui:_on_mouse_exit_weapon_skill_button(button, data)
	self:_unselected_weapon_skill_button(button, data)
end

function WeaponSelectionGui:_on_selected_weapon_skill_callback(button, data, tier)
	self:_selected_weapon_skill_button(button, data)
end

function WeaponSelectionGui:_on_unselected_weapon_skill_callback(button, data)
	self:_unselected_weapon_skill_button(button, data)
end

function WeaponSelectionGui:_add_weapon_skill_to_temp_skills(data_value, view_part_only)
	local temp_skills = self._weapon_skills:get_temp_skills()

	if view_part_only then
		temp_skills = clone(self._weapon_skills:get_temp_skills())
	end

	temp_skills[data_value] = true

	self:_recreate_and_show_weapon_parts(temp_skills)
end

function WeaponSelectionGui:_remove_weapon_skill_from_temp_skills(data_value, view_part_only)
	local temp_skills = self._weapon_skills:get_temp_skills()

	if view_part_only then
		temp_skills = clone(self._weapon_skills:get_temp_skills())
	end

	temp_skills[data_value] = nil

	self:_recreate_and_show_weapon_parts(temp_skills)
end

function WeaponSelectionGui:_on_weapon_part_unit_loaded(params)
	self._preloaded_weapon_part_names[params] = true
end

function WeaponSelectionGui:_update_weapon_stats(reset_applied_stats)
	local result = {}
	local selected_weapon_data = self._weapon_list:selected_item():data().value
	local weapon_name = ""
	local weapon_category = managers.weapon_inventory:get_weapon_category_by_weapon_category_id(self._selected_weapon_category_id)
	local weapon_string = ""

	if weapon_category == WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME or weapon_category == WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME then
		local ammo_max_multiplier = 1

		if weapon_category == WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME then
			ammo_max_multiplier = managers.player:upgrade_value("player", "primary_ammo_increase", 1)
		elseif weapon_category == WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME then
			ammo_max_multiplier = managers.player:upgrade_value("player", "secondary_ammo_increase", 1)
		end

		local base_stats, mods_stats, skill_stats = managers.weapon_inventory:get_weapon_stats(selected_weapon_data.weapon_id, weapon_category, selected_weapon_data.slot, nil)
		local damage = f2s(base_stats.damage.value) + f2s(skill_stats.damage.value)
		local magazine = f2s(base_stats.magazine.value) + f2s(skill_stats.magazine.value)
		local total_ammo = f2s(base_stats.totalammo.value * ammo_max_multiplier)
		local fire_rate = f2s(base_stats.fire_rate.value) + f2s(skill_stats.fire_rate.value)
		local accuracy = f2s(100 / (1 + tweak_data.weapon[selected_weapon_data.weapon_id].spread.steelsight)) + f2s(skill_stats.spread.value)
		local stability = f2s(base_stats.recoil.value) + f2s(skill_stats.recoil.value)

		if reset_applied_stats then
			self._weapon_stats:set_applied_stats({
				damage_applied_value = damage,
				magazine_applied_value = magazine,
				total_ammo_applied_value = total_ammo,
				rate_of_fire_applied_value = fire_rate,
				accuracy_applied_value = accuracy,
				stability_applied_value = stability
			})
		end

		self._weapon_stats:set_modified_stats({
			damage_modified_value = damage,
			magazine_modified_value = magazine,
			total_ammo_modified_value = total_ammo,
			rate_of_fire_modified_value = fire_rate,
			accuracy_modified_value = accuracy,
			stability_modified_value = stability
		})

		weapon_name = tweak_data.weapon[selected_weapon_data.weapon_id].name_id
		weapon_string = "(" .. self:translate("weapon_catagory_" .. tweak_data.weapon[selected_weapon_data.weapon_id].category, true) .. utf8.to_upper(") ") .. self:translate(weapon_name, true)
	elseif weapon_category == WeaponInventoryManager.BM_CATEGORY_MELEE_NAME then
		local base_stats, mods_stats, skill_stats = managers.weapon_inventory:get_melee_weapon_stats(selected_weapon_data.weapon_id)
		local damage = f2s(base_stats.damage.min_value) .. "-" .. f2s(base_stats.damage.max_value)
		local knockback = f2s(base_stats.damage_effect.min_value) .. "-" .. f2s(base_stats.damage_effect.max_value)
		local range = f2s(base_stats.range.value)
		local charge_time = f2s(base_stats.charge_time.value)

		self._melee_weapon_stats:set_stats(damage, knockback, range, charge_time)

		weapon_name = tweak_data.blackmarket.melee_weapons[selected_weapon_data.weapon_id].name_id
		weapon_string = self:translate(weapon_name, true)
	elseif weapon_category == WeaponInventoryManager.BM_CATEGORY_GRENADES_NAME then
		local proj_tweak_data = tweak_data.projectiles[selected_weapon_data.weapon_id]
		local damage = f2s(proj_tweak_data.damage or 0)
		local range = f2s(proj_tweak_data.range)
		local distance = f2s(proj_tweak_data.launch_speed or 250)
		weapon_name = proj_tweak_data.name_id

		self._grenade_weapon_stats:set_stats(damage, range, distance)

		weapon_string = self:translate(weapon_name, true)
	end

	self._weapon_name_label:set_text(weapon_string)
end

function WeaponSelectionGui:_recreate_and_show_weapon_parts(temp_skills)
	local position = self._rotate_weapon:current_position()
	local rotation = self._rotate_weapon:current_rotation()
	local blueprint = managers.weapon_skills:recreate_weapon_blueprint(self._selected_weapon_id, self._weapon_category_id, temp_skills, false)

	self:_show_weapon(self._selected_weapon_id, blueprint)
	self._rotate_weapon:set_position(position)
	self._rotate_weapon:set_rotation(rotation)
end

function WeaponSelectionGui:_get_marked_row_skill_button(i_skill)
	local weapon_skills_row = self._weapon_skills:get_rows()[i_skill]
	local max_skill_value = 0
	local weapon_skill_button = nil

	if weapon_skills_row then
		local skill_buttons = weapon_skills_row:get_skill_buttons()

		if skill_buttons then
			for _, skill_button in pairs(skill_buttons) do
				local button_data = skill_button:get_data()
				local button_state = skill_button:get_state()

				if skill_button:visible() and (button_state == RaidGUIControlButtonWeaponSkill.STATE_ACTIVE or button_state == RaidGUIControlButtonWeaponSkill.STATE_SELECTED) and max_skill_value < button_data.value.value then
					max_skill_value = button_data.value.value
					weapon_skill_button = skill_button
				end
			end
		end
	end

	return weapon_skill_button
end

function WeaponSelectionGui:_equip_weapon()
	local selected_weapon_data = self._weapon_list:selected_item():data().value

	if not selected_weapon_data.unlocked then
		return
	end

	managers.weapon_inventory:equip_weapon(self._selected_weapon_category_id, selected_weapon_data)
	managers.player:_internal_load()
	managers.player:local_player():inventory():equip_selection(self._selected_weapon_category_id, true)
	managers.player:local_player():camera():play_redirect(PlayerStandard.IDS_EQUIP)
	managers.savefile:save_game(Global.savefile_manager.save_progress_slot)
	self._weapon_list:activate_item_by_value(selected_weapon_data)
	self._equip_button:hide()
	self._equip_disabled_button:show()
	self:_update_weapon_stats(true)
end

function WeaponSelectionGui:_select_weapon(weapon_id, weapon_category_switched)
	Application:trace("[WeaponSelectionGui:_select_weapon] weapon_id ", weapon_id)

	local old_weapon_id = self._selected_weapon_id
	local weapon_switched = self._selected_weapon_id ~= weapon_id
	self._selected_weapon_id = weapon_id
	local use_cosmetics = managers.weapon_skills:get_cosmetics_flag_for_weapon_id(weapon_id)

	Application:trace("[WeaponSelectionGui:_select_weapon] use_cosmetics ", use_cosmetics)

	if use_cosmetics == nil then
		self._weapon_parts_toggle:hide()
	else
		self._weapon_parts_toggle:show()
		self._weapon_parts_toggle:set_value_and_render(use_cosmetics)
	end

	if weapon_category_switched then
		managers.weapon_skills:deactivate_all_upgrades_for_bm_weapon_category_id(self._selected_weapon_category_id)
	elseif not weapon_category_switched then
		managers.weapon_skills:update_weapon_skills(self._selected_weapon_category_id, old_weapon_id, WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE)
	end

	managers.weapon_skills:update_weapon_skills(self._selected_weapon_category_id, self._selected_weapon_id, WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE)

	if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		self._weapon_stats:hide()
		self._melee_weapon_stats:hide()
		self._grenade_weapon_stats:show()
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		self._weapon_stats:hide()
		self._melee_weapon_stats:show()
		self._grenade_weapon_stats:hide()
	else
		self._weapon_stats:show()
		self._melee_weapon_stats:hide()
		self._weapon_skills:set_weapon(self._selected_weapon_category_id, weapon_id)
		self._grenade_weapon_stats:hide()
	end

	if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		self:_show_weapon(weapon_id, nil, weapon_switched)
	else
		self:_show_unit(weapon_id)
	end

	self:_update_weapon_stats(true)
	self:_update_scope_switch()

	local selected_weapon = self._weapon_list:selected_item()

	if selected_weapon == self._weapon_list:get_active_item() then
		self._equip_button:hide()
		self._equip_disabled_button:show()
		self._cant_equip_explanation_label:hide()

		if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
			self._upgrade_button:show()
		end
	elseif selected_weapon:data().value.unlocked then
		self._equip_button:show()
		self._equip_disabled_button:hide()
		self._cant_equip_explanation_label:hide()

		if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
			self._upgrade_button:show()
		end
	else
		self._equip_button:hide()
		self._equip_disabled_button:hide()
		self._upgrade_button:hide()

		if self._selected_weapon_category_id ~= WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
			local class_name = managers.skilltree:get_character_profile_class()
			local weapon_unlock_levels = tweak_data.skilltree:get_weapon_unlock_levels()
			local weapon_id = selected_weapon:data().value.weapon_id
			local level = weapon_unlock_levels[weapon_id][class_name]

			if level then
				self._cant_equip_explanation_label:set_text(utf8.to_upper(managers.localization:text("menu_weapons_locked_higher_level", {
					LEVEL = level
				})))
			else
				local classes = ""

				for class_name, _ in pairs(weapon_unlock_levels[weapon_id]) do
					classes = classes .. self:translate("character_skill_tree_" .. class_name, true) .. ", "
				end

				classes = string.sub(classes, 0, -3)

				self._cant_equip_explanation_label:set_text(utf8.to_upper(managers.localization:text("menu_weapons_locked_wrong_class", {
					CLASSES = classes
				})))
			end
		else
			self._cant_equip_explanation_label:set_text(self:translate("character_customization_locked_drop_label", true))
		end

		self._cant_equip_explanation_label:show()
	end

	local weapon_upgrade_tree = managers.weapon_skills:get_weapon_skills_skill_tree()[weapon_id]

	if not weapon_upgrade_tree or not selected_weapon:data().value.unlocked then
		self._upgrade_button:hide()
		self:bind_controller_inputs_choose_weapon_no_upgrade()
	else
		self._upgrade_button:show()
		self:bind_controller_inputs_choose_weapon()
	end
end

function WeaponSelectionGui:_reselect_weapons_in_list()
	local selected_weapon_id = self._selected_weapon_id
	local selected_weapon_data = self._weapon_list:selected_item():data()
	local active_weapon_data = self._weapon_list:get_active_item():data()
	local active_weapon_id = active_weapon_data.value.weapon_id

	self._weapon_list:refresh_data()
	self._weapon_list:select_item_by_value(active_weapon_data.value)
	self:_equip_weapon()
	self._weapon_list:select_item_by_value(selected_weapon_data.value)
end

function WeaponSelectionGui:destroy_weapon()
	if self._spawned_unit and alive(self._spawned_unit) then
		self._spawned_unit:set_slot(0)
	end
end

function WeaponSelectionGui:destroy_weapon_parts()
	if self._spawned_weapon_parts then
		for _, part in pairs(self._spawned_weapon_parts) do
			if alive(part.unit) then
				part.unit:set_slot(0)
			end
		end
	end
end

function WeaponSelectionGui:pix_to_screen(px_x, px_y)
	local sx = 2 * px_x / self._root_panel:w() - 1
	local sy = 2 * px_y / self._root_panel:h() - 1

	return sx, sy
end

function WeaponSelectionGui:_show_weapon(weapon_id, pre_created_blueprint, weapon_switched)
	self:destroy_weapon_parts()

	if weapon_switched then
		self:destroy_weapon()
	end

	if not self._weapon_select_allowed then
		return
	end

	self:set_weapon_select_allowed(false)

	local weapon_tweak_data = tweak_data.weapon[weapon_id]
	local rotation_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.rotation_offset or 0
	local distance_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.distance_offset or 0
	local height_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.height_offset or 0
	local display_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.display_offset or 0
	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
	local unit_path = tweak_data.weapon.factory[weapon_factory_id].unit
	local unit_path_id = Idstring(unit_path)
	self._loading_units[unit_path] = true

	managers.dyn_resource:load(Idstring("unit"), unit_path_id, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_unit_loading_complete", {
		weapon_tweak_data = weapon_tweak_data,
		rotation_offset = rotation_offset,
		distance_offset = distance_offset,
		height_offset = height_offset,
		display_offset = display_offset,
		weapon_factory_id = weapon_factory_id,
		unit_path = unit_path,
		unit_path_id = unit_path_id,
		weapon_switched = weapon_switched,
		weapon_id = weapon_id,
		pre_created_blueprint = pre_created_blueprint
	}))
end

function WeaponSelectionGui:_unit_loading_complete(params)
	self._loading_units[params.unit_path] = nil
	local camera = managers.viewport:get_current_camera()
	local direction_left = -camera:rotation():x()
	local direction_forward = camera:rotation():y()
	local direction_up = camera:rotation():z()
	local sx, sy = self:pix_to_screen(self._rotate_weapon:x() + self._rotate_weapon:w() / 2, self._rotate_weapon:y() + self._rotate_weapon:h() / 2)
	self._spawned_unit_position = camera:screen_to_world(Vector3(sx, sy, 200)) + direction_left * params.display_offset

	if params.weapon_switched or not self._spawned_unit then
		self._spawned_unit = World:spawn_unit(params.unit_path_id, self._spawned_unit_position, Rotation(-90, 0, 0))
	end

	self._spawned_unit_offset = direction_forward * params.rotation_offset

	self._spawned_unit:set_position(self._spawned_unit_position)

	if params.weapon_tweak_data.gui and params.weapon_tweak_data.gui.initial_rotation then
		self._spawned_unit:set_rotation(Rotation(params.weapon_tweak_data.gui.initial_rotation.yaw or -90, params.weapon_tweak_data.gui.initial_rotation.pitch or 0, params.weapon_tweak_data.gui.initial_rotation.roll or 0))
	end

	self._spawned_unit:base():set_factory_data(params.weapon_factory_id)
	self._spawned_unit:base():set_texture_switches(nil)

	local selected_weapon_slot = managers.weapon_inventory:get_weapon_slot_by_weapon_id(params.weapon_id, self._selected_weapon_category_id)
	local weapon_category = managers.weapon_inventory:get_weapon_category_by_weapon_category_id(self._selected_weapon_category_id)
	local weapon_blueprint = params.pre_created_blueprint or managers.blackmarket:get_weapon_blueprint(weapon_category, selected_weapon_slot)
	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(params.weapon_id)
	local default_blueprint = clone(managers.weapon_factory:get_default_blueprint_by_factory_id(weapon_factory_id))
	default_blueprint = managers.weapon_skills:update_scope_in_blueprint(params.weapon_id, weapon_category, default_blueprint)
	local use_default_blueprint = not self._weapon_parts_toggle:get_value()
	weapon_blueprint = not use_default_blueprint and weapon_blueprint or default_blueprint
	local parts, blueprint = managers.weapon_factory:preload_blueprint(params.weapon_factory_id, weapon_blueprint, false, callback(self, self, "_preload_blueprint_completed", {
		weapon_factory_id = params.weapon_factory_id,
		weapon_blueprint = weapon_blueprint,
		direction_forward = direction_forward,
		distance_offset = params.distance_offset,
		direction_up = direction_up,
		height_offset = params.height_offset
	}), false)
	self._parts_being_loaded = parts
end

function WeaponSelectionGui:_preload_blueprint_completed(params)
	local parts, blueprint = managers.weapon_factory:assemble_from_blueprint(params.weapon_factory_id, self._spawned_unit, params.weapon_blueprint, false, callback(self, self, "_assemble_completed"), false)
	self._spawned_weapon_parts = parts
	self._spawned_unit_screen_offset = params.direction_forward * params.distance_offset + params.direction_up * params.height_offset

	self._rotate_weapon:set_unit(self._spawned_unit, self._spawned_unit_position, 90, self._spawned_unit_offset, self._spawned_unit_screen_offset)
end

function WeaponSelectionGui:_assemble_completed()
	self._rotate_weapon:set_unit(self._spawned_unit, self._spawned_unit_position, 90, self._spawned_unit_offset, self._spawned_unit_screen_offset)
	self:set_weapon_select_allowed(true)

	self._parts_being_loaded = nil
end

function WeaponSelectionGui:_show_unit(weapon_id)
	self:destroy_weapon()

	local unit_path, weapon_tweak_data = nil

	if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		weapon_tweak_data = tweak_data.blackmarket.melee_weapons[weapon_id] or managers.blackmarket._defaults.melee_weapon
		unit_path = weapon_tweak_data.unit
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		weapon_tweak_data = tweak_data.projectiles[weapon_id]
		unit_path = weapon_tweak_data.unit_hand
	end

	if not unit_path then
		return
	end

	unit_path = Idstring(unit_path)

	managers.dyn_resource:load(Idstring("unit"), unit_path, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	local rotation_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.rotation_offset or 0
	local distance_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.distance_offset or 0
	local height_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.height_offset or 0
	local display_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.display_offset or 0
	local camera = managers.viewport:get_current_camera()
	local position = camera:position()
	local direction_left = -camera:rotation():x()
	local direction_forward = camera:rotation():y()
	local direction_up = camera:rotation():z()
	local sx, sy = self:pix_to_screen(self._rotate_weapon:x() + self._rotate_weapon:w() / 2, self._rotate_weapon:y() + self._rotate_weapon:h() / 2)
	self._spawned_unit_position = camera:screen_to_world(Vector3(sx, sy, 200)) + direction_left * display_offset
	self._spawned_unit_position_temp = Vector3(0, 0, 0)
	local start_rot = nil

	if weapon_tweak_data.gui and weapon_tweak_data.gui.initial_rotation then
		start_rot = Rotation(weapon_tweak_data.gui.initial_rotation.yaw or -90, weapon_tweak_data.gui.initial_rotation.pitch or 0, weapon_tweak_data.gui.initial_rotation.roll or 0)
	end

	self._spawned_unit = World:spawn_unit(unit_path, self._spawned_unit_position_temp, start_rot or Rotation(-90, 0, 0))
	self._spawned_unit_offset = direction_forward * rotation_offset

	self._spawned_unit:set_position(self._spawned_unit_position)

	self._spawned_unit_screen_offset = direction_forward * distance_offset + direction_up * height_offset

	self._rotate_weapon:set_unit(self._spawned_unit, self._spawned_unit_position, 90, self._spawned_unit_offset, self._spawned_unit_screen_offset)
end

function WeaponSelectionGui:_despawn_parts(parts)
	if parts then
		for _, part in pairs(parts) do
			if alive(part.unit) then
				part.unit:set_slot(0)
			end
		end
	end
end

function WeaponSelectionGui:bind_controller_inputs_choose_weapon()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_weapon_category_tab_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_weapon_category_tab_right")
		},
		{
			key = Idstring("menu_controller_trigger_left"),
			callback = callback(self, self, "_on_equipable_tab_left")
		},
		{
			key = Idstring("menu_controller_trigger_right"),
			callback = callback(self, self, "_on_equipable_tab_right")
		},
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_upgrade_weapon_click")
		}
	}
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_weapons_category",
			"menu_legend_weapons_equipable",
			"menu_legend_weapons_equip",
			"menu_legend_weapons_upgrade"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	if self._scope_switch:visible() then
		local translated_text = managers.localization:get_default_macros()[WeaponSelectionGui.TOGGLE_SWITCH_BINDING[1][2]] .. " "
		translated_text = translated_text .. self:translate(WeaponSelectionGui.TOGGLE_SWITCH_BINDING[1][1], true)

		table.insert(bindings, {
			key = Idstring(WeaponSelectionGui.TOGGLE_SWITCH_BINDING[1][3]),
			callback = callback(self, self, "toggle_scope_switch")
		})
		table.insert(legend.controller, {
			translated_text = translated_text
		})
	end

	if self._weapon_parts_toggle:visible() then
		local translated_text = managers.localization:get_default_macros()[WeaponSelectionGui.TOGGLE_COSMETICS_BINDING[1][2]] .. " "
		translated_text = translated_text .. self:translate(WeaponSelectionGui.TOGGLE_COSMETICS_BINDING[1][1], true)

		table.insert(bindings, {
			key = Idstring(WeaponSelectionGui.TOGGLE_COSMETICS_BINDING[1][3]),
			callback = callback(self, self, "toggle_weapon_parts")
		})
		table.insert(legend.controller, {
			translated_text = translated_text
		})
	end

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

function WeaponSelectionGui:bind_controller_inputs_choose_weapon_no_upgrade()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_weapon_category_tab_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_weapon_category_tab_right")
		},
		{
			key = Idstring("menu_controller_trigger_left"),
			callback = callback(self, self, "_on_equipable_tab_left")
		},
		{
			key = Idstring("menu_controller_trigger_right"),
			callback = callback(self, self, "_on_equipable_tab_right")
		}
	}
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_weapons_category",
			"menu_legend_weapons_equipable",
			"menu_legend_weapons_equip"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	if self._scope_switch:visible() then
		local translated_text = managers.localization:get_default_macros()[WeaponSelectionGui.TOGGLE_SWITCH_BINDING[1][2]] .. " "
		translated_text = translated_text .. self:translate(WeaponSelectionGui.TOGGLE_SWITCH_BINDING[1][1], true)

		table.insert(bindings, {
			key = Idstring(WeaponSelectionGui.TOGGLE_SWITCH_BINDING[1][3]),
			callback = callback(self, self, "toggle_scope_switch")
		})
		table.insert(legend.controller, {
			translated_text = translated_text
		})
	end

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

function WeaponSelectionGui:bind_controller_inputs_upgrade_weapon()
	local bindings = {
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_apply_weapon_skills_click")
		},
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_on_select_weapon_skills_click")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_weapons_weapon_skill_select",
			"menu_legend_weapons_weapon_skill_apply"
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

function WeaponSelectionGui:bind_controller_inputs_upgrade_weapon_upgrade_forbiden()
	local bindings = {}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_weapons_weapon_skill_select"
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

function WeaponSelectionGui:_on_weapon_category_tab_left()
	self._list_tabs:_move_left()

	return true, nil
end

function WeaponSelectionGui:_on_weapon_category_tab_right()
	self._list_tabs:_move_right()

	return true, nil
end

function WeaponSelectionGui:_on_equipable_tab_left()
	self._equippable_filters_tabs:_move_left()

	return true, nil
end

function WeaponSelectionGui:_on_equipable_tab_right()
	self._equippable_filters_tabs:_move_right()

	return true, nil
end

function WeaponSelectionGui:_on_upgrade_weapon_click()
	self:on_upgrade_button_click()

	return true, nil
end

function WeaponSelectionGui:_on_apply_weapon_skills_click()
	self:on_apply_button_click()

	return true, nil
end

function WeaponSelectionGui:_on_select_weapon_skills_click()
	self._weapon_skills:confirm_pressed()

	return true, nil
end

function WeaponSelectionGui:confirm_pressed()
	if self._weapon_selection_panel:visible() then
		self:on_equip_button_click(nil, nil, nil)
	elseif self._weapon_skills_panel:visible() then
		self._weapon_skills:confirm_pressed()
	end

	return true
end

function WeaponSelectionGui:_upgrade_status()
	if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		self:bind_controller_inputs_choose_weapon()
	else
		self:bind_controller_inputs_choose_weapon_no_upgrade()
	end
end

function WeaponSelectionGui:back_pressed()
	if not managers.raid_menu:is_pc_controller() then
		if self._weapon_selection_panel:visible() then
			managers.raid_menu:register_on_escape_callback(nil)
			managers.raid_menu:on_escape()
		elseif self._weapon_skills_panel:visible() then
			self:_show_weapon_list_panel()
			self._weapon_list:set_selected(true)
			self._weapon_skills:set_selected(false)
			self._weapon_skills:unacquire_all_temp_skills(self._selected_weapon_category_id)
			self:_reselect_weapons_in_list()

			return true
		end
	else
		if self._weapon_selection_panel:visible() then
			-- Nothing
		elseif self._weapon_skills_panel:visible() then
			self:_show_weapon_list_panel()
			self._weapon_list:set_selected(true)
			self._weapon_skills:set_selected(false)
			self._weapon_skills:unacquire_all_temp_skills(self._selected_weapon_category_id)
			self:_reselect_weapons_in_list()

			return true
		end

		return false
	end
end
