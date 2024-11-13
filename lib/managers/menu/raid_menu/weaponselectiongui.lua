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
			managers.dyn_resource:unload(IDS_UNIT, Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
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

	if managers.savefile._save_icon then
		managers.savefile._save_icon:offset_position(0, 0)
	end
end

function WeaponSelectionGui:_layout()
	WeaponSelectionGui.super._layout(self)
	self:_disable_dof()
	self:clear_grenade_secondary_breadbrumbs()
	self:_layout_left_side_panels()
	self:_layout_category_tabs()
	self:_layout_lists()
	self:_layout_weapon_stats()
	self:_layout_equip_button()
	self:_layout_skill_panel()
	self:_layout_rotate_unit()
	self:_layout_available_points()
	self:_layout_upgrade_button()
	self:_layout_skins_button()
	self:_layout_weapon_name()
	self:_layout_weapon_desc()
	self:bind_controller_inputs_choose_weapon()
	self:set_weapon_select_allowed(true)
	self._weapon_list:set_selected(true, true)
	self:on_weapon_category_selected(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)

	if managers.savefile._save_icon then
		managers.savefile._save_icon:offset_position(0, -50)
	end
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

function WeaponSelectionGui:_layout_left_side_panels()
	self._weapon_selection_panel = self._root_panel:panel({
		name = "weapon_selection_panel",
		layer = 1,
		h = 924,
		w = 728,
		y = 96,
		x = 0
	})
	self._weapon_skills_panel = self._root_panel:panel({
		name = "weapon_skills_panel",
		layer = 1,
		h = 924,
		w = 480,
		y = 96,
		x = 0,
		visible = false
	})
end

function WeaponSelectionGui:_layout_category_tabs()
	local category_tabs_params = {
		name = "category_tabs",
		tabs_params = nil,
		y = 0,
		x = 0,
		parent_control_ref = nil,
		on_click_callback = nil,
		initial_tab_idx = 1,
		tab_align = "center",
		tab_height = 64,
		on_click_callback = callback(self, self, "on_weapon_category_selected"),
		parent_control_ref = self,
		tabs_params = {
			{
				name = "tab_primary",
				breadcrumb = nil,
				callback_param = nil,
				text = nil,
				text = self:translate("menu_weapons_tab_category_primary", true),
				callback_param = WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID,
				breadcrumb = {
					check_callback = nil,
					check_callback = callback(managers.weapon_skills, managers.weapon_skills, "has_weapon_breadcrumbs", {
						weapon_category = nil,
						weapon_category = WeaponInventoryManager.CATEGORY_NAME_PRIMARY
					})
				}
			},
			{
				name = "tab_secondary",
				breadcrumb = nil,
				callback_param = nil,
				text = nil,
				text = self:translate("menu_weapons_tab_category_secondary", true),
				callback_param = WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID,
				breadcrumb = {
					check_callback = nil,
					check_callback = callback(managers.weapon_skills, managers.weapon_skills, "has_weapon_breadcrumbs", {
						weapon_category = nil,
						weapon_category = WeaponInventoryManager.CATEGORY_NAME_SECONDARY
					})
				}
			},
			{
				name = "tab_grenades",
				callback_param = nil,
				text = nil,
				text = self:translate("menu_weapons_tab_category_grenades", true),
				callback_param = WeaponInventoryManager.BM_CATEGORY_GRENADES_ID
			},
			{
				name = "tab_melee",
				breadcrumb = nil,
				callback_param = nil,
				text = nil,
				text = self:translate("menu_weapons_tab_category_melee", true),
				breadcrumb = {
					category = nil,
					category = BreadcrumbManager.CATEGORY_WEAPON_MELEE
				},
				callback_param = WeaponInventoryManager.BM_CATEGORY_MELEE_ID
			}
		}
	}
	self._list_tabs = self._weapon_selection_panel:tabs(category_tabs_params)
	self._selected_weapon_category_id = WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID
	self._equippable_filters_tabs = self._weapon_selection_panel:tabs({
		item_class = nil,
		name = "equippable_filters_tabs",
		tabs_params = nil,
		icon = nil,
		y = 54,
		x = 0,
		tab_width = 140,
		on_click_callback = nil,
		initial_tab_idx = 1,
		tab_align = "center",
		tab_height = 64,
		icon = tweak_data.gui.icons.ico_filter,
		item_class = RaidGUIControlTabFilter,
		on_click_callback = callback(self, self, "on_click_filter_equippable"),
		tabs_params = {
			{
				name = "tab_all",
				callback_param = "all",
				text = nil,
				text = self:translate("menu_filter_all", true)
			},
			{
				name = "tab_equippable",
				callback_param = "equippable",
				text = nil,
				text = self:translate("menu_weapons_filter_equippable", true)
			}
		}
	})
	self._selected_filter = "all"
end

function WeaponSelectionGui:_layout_lists()
	local weapon_list_width = 480
	local weapon_list_scrollable_area_params = {
		name = "weapon_list_scrollable_area",
		scroll_step = 19,
		h = 456,
		w = nil,
		y = 128,
		x = 0,
		w = weapon_list_width
	}
	self._weapon_list_scrollable_area = self._weapon_selection_panel:scrollable_area(weapon_list_scrollable_area_params)
	local weapon_list_params = {
		x = 0,
		on_item_double_clicked_callback = nil,
		on_item_clicked_callback = nil,
		on_item_selected_callback = nil,
		w = nil,
		y = 0,
		item_h = 62,
		on_mouse_click_sound_event = "weapon_click",
		name = "weapon_list",
		item_class = nil,
		on_mouse_over_sound_event = "highlight",
		use_unlocked = false,
		selection_enabled = true,
		scrollable_area_ref = nil,
		data_source_callback = nil,
		w = weapon_list_width,
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
		name = "weapon_stats",
		label_class = nil,
		data_source_callback = nil,
		selection_enabled = false,
		tab_height = 60,
		y = 771,
		x = 550,
		tab_width = 160,
		label_class = RaidGUIControlLabelNamedValueWithDelta
	}
	self._weapon_stats = self._root_panel:create_custom_control(RaidGUIControlWeaponStats, weapon_stats_params)
	local melee_weapon_stats_params = {
		name = "melee_weapon_stats",
		label_class = nil,
		data_source_callback = nil,
		selection_enabled = false,
		tab_height = 60,
		y = 771,
		x = 550,
		tab_width = 200,
		label_class = RaidGUIControlLabelNamedValue
	}
	self._melee_weapon_stats = self._root_panel:create_custom_control(RaidGUIControlMeleeWeaponStats, melee_weapon_stats_params)
	local grenade_weapon_stats_params = {
		name = "grenade_weapon_stats",
		label_class = nil,
		data_source_callback = nil,
		selection_enabled = false,
		tab_height = 60,
		y = 771,
		x = 550,
		tab_width = 180,
		label_class = RaidGUIControlLabelNamedValue
	}
	self._grenade_weapon_stats = self._root_panel:create_custom_control(RaidGUIControlGrenadeWeaponStats, grenade_weapon_stats_params)
end

function WeaponSelectionGui:_layout_equip_button()
	local equip_button_params = {
		name = "equip_button",
		on_click_callback = nil,
		layer = 1,
		text = nil,
		on_click_sound = nil,
		y = 710,
		x = 0,
		visible = false,
		text = self:translate("menu_weapons_equip", true),
		on_click_callback = callback(self, self, "on_equip_button_click"),
		on_click_sound = WeaponSelectionGui.WEAPON_EQUIP_SOUND
	}
	self._equip_button = self._weapon_selection_panel:short_primary_button(equip_button_params)
	local equip_disabled_button_params = {
		name = "equip_disabled_button",
		layer = 1,
		text = nil,
		y = 710,
		x = 0,
		visible = true,
		text = self:translate("menu_weapons_equipped", true)
	}
	self._equip_disabled_button = self._weapon_selection_panel:short_primary_button_disabled(equip_disabled_button_params)

	if managers.controller:is_controller_present() then
		self._equip_button:hide()
		self._equip_disabled_button:hide()
	end

	local cant_equip_explanation_label_params = {
		font = nil,
		align = "left",
		layer = 1,
		h = 60,
		w = 520,
		y = 722,
		x = 0,
		wrap = true,
		name = "cant_equip_explenation_label",
		text = "",
		color = nil,
		word_wrap = true,
		font_size = nil,
		visible = false,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_red
	}
	self._cant_equip_explanation_label = self._weapon_selection_panel:label(cant_equip_explanation_label_params)
end

function WeaponSelectionGui:_layout_skill_panel()
	local weapon_skills_params = {
		on_mouse_exit_callback = nil,
		on_mouse_enter_callback = nil,
		layer = 1,
		h = 440,
		w = 448,
		y = 11,
		x = 0,
		name = "weapon_skills",
		on_click_weapon_skill_callback = nil,
		on_unselected_weapon_skill_callback = nil,
		on_selected_weapon_skill_callback = nil,
		on_mouse_enter_callback = callback(self, self, "_on_mouse_enter_weapon_skill_button"),
		on_mouse_exit_callback = callback(self, self, "_on_mouse_exit_weapon_skill_button"),
		on_selected_weapon_skill_callback = callback(self, self, "_on_selected_weapon_skill_callback"),
		on_unselected_weapon_skill_callback = callback(self, self, "_on_unselected_weapon_skill_callback"),
		on_click_weapon_skill_callback = callback(self, self, "_on_click_weapon_skill_callback")
	}
	self._weapon_skills = self._weapon_skills_panel:create_custom_control(RaidGUIControlWeaponSkills, weapon_skills_params)
	local skill_desc_params = {
		name = "skill_desc",
		layer = 1,
		h = 244,
		w = nil,
		y = 447,
		x = 0,
		w = self._weapon_skills_panel:w()
	}
	self._skill_desc = self._weapon_skills_panel:create_custom_control(RaidGUIControlWeaponSkillDesc, skill_desc_params)
	local apply_button_params = {
		name = "apply_button",
		on_click_callback = nil,
		layer = 1,
		text = nil,
		y = 710,
		x = 0,
		on_click_sound = nil,
		text = self:translate("menu_weapons_apply", true),
		on_click_callback = callback(self, self, "on_apply_button_click"),
		on_click_sound = WeaponSelectionGui.WEAPON_EQUIP_SOUND
	}
	self._apply_button = self._weapon_skills_panel:short_primary_button(apply_button_params)

	self._apply_button:disable()

	local available_points_skills_params = {
		text = nil,
		value_align = "left",
		layer = 1,
		h = 64,
		w = 190,
		y = 590,
		x = 0,
		value_padding = 3,
		name = "available_points_skills",
		value = nil,
		value_color = nil,
		value_font_size = nil,
		align = "left",
		font_size = nil,
		visible = false,
		text = self:translate("menu_available_points", true),
		value = "" .. managers.weapon_skills:get_available_weapon_skill_points(),
		value_color = tweak_data.gui.colors.raid_red,
		value_font_size = tweak_data.gui.font_sizes.size_32,
		font_size = tweak_data.gui.font_sizes.medium
	}
	self._available_points_skills_label = self._weapon_skills_panel:label_named_value(available_points_skills_params)
	local upgrade_cost_params = {
		text = nil,
		value_align = "left",
		layer = 1,
		h = 64,
		w = 190,
		y = 590,
		x = 200,
		value_padding = 3,
		name = "upgrade_cost",
		value = "00",
		value_color = nil,
		value_font_size = nil,
		align = "left",
		font_size = nil,
		visible = false,
		text = self:translate("menu_upgrade_cost", true),
		value_color = tweak_data.gui.colors.raid_red,
		value_font_size = tweak_data.gui.font_sizes.size_32,
		font_size = tweak_data.gui.font_sizes.medium
	}
	self._upgrade_cost_label = self._weapon_skills_panel:label_named_value(upgrade_cost_params)
end

function WeaponSelectionGui:_layout_rotate_unit()
	local params_rotate_weapon = {
		rotation_click_sound = "weapon_turn",
		name = "rotate_weapon",
		mouse_release_sound = "weapon_turn_stoped",
		h = 570,
		w = 1220,
		y = 90,
		x = 470,
		sound_click_every_n_degrees = 10,
		mouse_click_sound = "weapon_click",
		mouse_over_sound = "weapon_mouse_over"
	}
	self._rotate_weapon = self._root_panel:rotate_unit(params_rotate_weapon)
end

function WeaponSelectionGui:_layout_available_points()
	local available_points_params = {
		y = 672,
		text = nil,
		layer = 1,
		h = 90,
		w = 192,
		value_color = nil,
		x = 1536,
		value_padding = 10,
		name = "available_points_label",
		value = nil,
		text = self:translate("menu_available_points", true),
		value = "" .. managers.weapon_skills:get_available_weapon_skill_points(),
		value_color = tweak_data.gui.colors.raid_red
	}
	self._available_points_label = self._root_panel:label_named_value(available_points_params)

	self._available_points_label:hide()
end

function WeaponSelectionGui:_layout_upgrade_button()
	local x_off = self._equip_button:x() + self._equip_button:w() + 60
	local upgrade_button_params = {
		name = "upgrade_button",
		on_click_callback = nil,
		layer = 1,
		text = nil,
		y = 806,
		x = nil,
		x = x_off,
		text = self:translate("menu_weapons_upgrade", true),
		on_click_callback = callback(self, self, "on_upgrade_button_click")
	}
	self._upgrade_button = self._root_panel:short_secondary_button(upgrade_button_params)

	self._upgrade_button:hide()
end

function WeaponSelectionGui:_layout_skins_button()
	local x_off = self._equip_button:x()
	local y_off = self._equip_button:y() + 15
	local skins_button_params = {
		layer = 1,
		on_item_selected_callback = nil,
		w = 450,
		y = nil,
		x = nil,
		name = "skins_button",
		stepper_w = 280,
		description = nil,
		data_source_callback = nil,
		description = self:translate("menu_weapons_skins", true),
		x = x_off,
		y = y_off,
		data_source_callback = callback(self, self, "_get_skins_list"),
		on_item_selected_callback = callback(self, self, "on_skins_button_click")
	}
	self._skins_button = self._root_panel:stepper_simple(skins_button_params)
	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(self._selected_weapon_id)
	weapon_factory_id = weapon_factory_id or self._selected_weapon_id
	local wep_skin = managers.weapon_inventory:get_weapons_skin(weapon_factory_id)

	Application:debug("[WeaponSelectionGui] ----------------------------------------------------------------------- ")
	Application:debug("[WeaponSelectionGui] Gun has skin applied:", weapon_factory_id, wep_skin)

	if wep_skin then
		self._skins_button:set_value_and_render(wep_skin, true)
	end

	self._skins_button:hide()
end

function WeaponSelectionGui:_update_selected_weapon_skins()
	if self._skins_button then
		Application:debug("[WeaponSelectionGui] _update_selected_weapon_skins skins button already exists!!")
		self._skins_button:hide()
	end

	self:_layout_skins_button()
end

function WeaponSelectionGui:_get_skins_list()
	local list = {}

	table.insert(list, {
		info = nil,
		value = "default",
		text = nil,
		text = utf8.to_upper(managers.localization:text("menu_weapon_no_skin")),
		info = utf8.to_upper(managers.localization:text("menu_weapon_no_skin"))
	})

	if self._selected_weapon_id then
		local my_skins = tweak_data.weapon:get_weapon_skins(self._selected_weapon_id)

		Application:trace("[WeaponSelectionGui:_get_skins_list] Skins:", inspect(my_skins))

		if my_skins then
			for _, skin in ipairs(my_skins) do
				local name_id = tweak_data.weapon:get_weapon_skin_name_id(skin)

				table.insert(list, {
					info = nil,
					value = nil,
					text = nil,
					value = skin,
					text = utf8.to_upper(managers.localization:text(name_id)),
					info = utf8.to_upper(managers.localization:text(name_id))
				})
			end
		end
	else
		Application:debug("[WeaponSelectionGui] cant get skins from weapon, current weapon doesnt exist yet")
	end

	return list
end

function WeaponSelectionGui:on_skins_button_click(item)
	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(self._selected_weapon_id)
	weapon_factory_id = weapon_factory_id or self._selected_weapon_id

	managers.weapon_inventory:set_weapons_skin(weapon_factory_id, item.value)
	Application:debug("[WeaponSelectionGui] on_skins_button_click", weapon_factory_id, item.value)
	self._weapon_list:refresh_data()
	self:_recreate_and_show_weapon_parts()
	self:_update_weapon_stats(false)
	managers.menu_component:post_event("weapon_click")
	managers.savefile:save_game(Global.savefile_manager.save_progress_slot)
end

function WeaponSelectionGui:_on_weapon_skin_left()
	self._skins_button:on_left_arrow_clicked()
end

function WeaponSelectionGui:_on_weapon_skin_right()
	self._skins_button:on_right_arrow_clicked()
end

function WeaponSelectionGui:show_skins_button_if_skins()
	if self._selected_weapon_id then
		local my_skins = tweak_data.weapon:get_weapon_skins(self._selected_weapon_id)

		if #my_skins > 0 then
			self._skins_button:show()
		end
	end
end

function WeaponSelectionGui:_show_weapon_list_panel()
	self._weapon_selection_panel:show()
	self._weapon_skills_panel:hide()
	self._upgrade_button:show()
	self:show_skins_button_if_skins()
	self:_set_screen_state(WeaponSelectionGui.SCREEN_STATE_WEAPON_LIST)

	if self._preloaded_weapon_part_names and #self._preloaded_weapon_part_names > 1 then
		local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(self._selected_weapon_id)
		local weapon_part_names = tweak_data.weapon.factory[weapon_factory_id].uses_parts
		local weapon_part_unit_path = ""

		for _, weapon_part_name in ipairs(weapon_part_names) do
			if self._preloaded_weapon_part_names[weapon_part_name] then
				weapon_part_unit_path = tweak_data.weapon.factory.parts[weapon_part_name].unit

				managers.dyn_resource:unload(IDS_UNIT, Idstring(weapon_part_unit_path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
			end
		end
	end

	self:bind_controller_inputs_choose_weapon()
end

function WeaponSelectionGui:_layout_weapon_name()
	local font_size = tweak_data.gui.font_sizes.size_46
	local weapon_name_params = {
		font = nil,
		color = nil,
		align = "right",
		h = nil,
		w = nil,
		y = 0,
		x = 1500,
		text = "THOMPSON\nGUNGUN",
		name = "weapon_name",
		vertical = "bottom",
		font_size = nil,
		w = self._root_panel:w() / 2,
		h = font_size,
		color = tweak_data.gui.colors.raid_dirty_white,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = font_size
	}
	self._weapon_name_label = self._root_panel:label(weapon_name_params)

	self._weapon_name_label:set_right(self._root_panel:right())
	self._weapon_name_label:set_bottom(100)
end

function WeaponSelectionGui:_layout_weapon_desc()
	local font_size = tweak_data.gui.font_sizes.size_24
	local weapon_name_params = {
		font = nil,
		text = [[
Despite Sterlings attitude he is infact a right bugger.
Slap his buns for me.
Ok but seriously now what is up with space?
I am not joking about the buns thing.]],
		align = "right",
		h = nil,
		w = 520,
		y = 0,
		x = 1500,
		wrap = true,
		name = "weapon_desc",
		color = nil,
		vertical = "top",
		word_wrap = true,
		font_size = nil,
		h = font_size * 6,
		color = tweak_data.gui.colors.raid_dirty_white,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = font_size
	}
	self._weapon_desc_label = self._root_panel:label(weapon_name_params)

	self._weapon_desc_label:set_right(self._root_panel:right())
	self._weapon_desc_label:set_top(self._weapon_name_label:bottom())
end

function WeaponSelectionGui:on_weapon_category_selected(selected_category)
	if selected_category == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or selected_category == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		self._upgrade_button:show()
	else
		self._upgrade_button:hide()
		self._available_points_label:hide()
	end

	self:show_skins_button_if_skins()
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
	local owned_weapons = {}

	if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		owned_weapons = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID)
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		owned_weapons = managers.weapon_inventory:get_owned_weapons(WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID)
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		owned_weapons = self._cached_owned_melee_weapons or managers.weapon_inventory:get_owned_melee_weapons()
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		owned_weapons = managers.weapon_inventory:get_owned_grenades()
	end

	local equipped_weapon_id = nil

	if owned_weapons then
		for _, weapon_data in pairs(owned_weapons) do
			if self._selected_filter == "all" or self._selected_filter == "equippable" and weapon_data.unlocked then
				if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
					local name_id = nil
					local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_data.weapon_id)
					local _, skin_data = managers.weapon_inventory:get_weapons_skin(weapon_factory_id)

					if skin_data then
						name_id = skin_data.name_id
					else
						name_id = tweak_data.weapon[weapon_data.weapon_id].name_id
					end

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
							category = nil,
							identifiers = nil,
							check_callback = nil,
							check_callback = callback(managers.weapon_skills, managers.weapon_skills, "has_weapon_breadcrumbs", {
								weapon_id = nil,
								weapon_category = nil,
								weapon_category = weapon_category,
								weapon_id = weapon_data.weapon_id
							}),
							category = breadcrumb_category,
							identifiers = {
								weapon_data.weapon_id
							}
						}
					end

					local selected = self._selected_weapon_id == weapon_data.weapon_id or equipped_weapon_id == weapon_data.weapon_id

					table.insert(result, {
						breadcrumb = nil,
						value = nil,
						selected = nil,
						text = nil,
						text = self:translate(name_id, false),
						value = weapon_data,
						breadcrumb = breadcrumb,
						selected = selected
					})
				elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
					equipped_weapon_id = managers.weapon_inventory:get_equipped_melee_weapon_id()
					local breadcrumb = {
						identifiers = nil,
						category = nil,
						category = BreadcrumbManager.CATEGORY_WEAPON_MELEE,
						identifiers = {
							weapon_data.weapon_id
						}
					}

					if self._selected_weapon_id == weapon_data.weapon_id or equipped_weapon_id == weapon_data.weapon_id then
						table.insert(result, {
							breadcrumb = nil,
							value = nil,
							selected = true,
							text = nil,
							text = self:translate(tweak_data.blackmarket.melee_weapons[weapon_data.weapon_id].name_id, false),
							value = weapon_data,
							breadcrumb = breadcrumb
						})
					else
						table.insert(result, {
							breadcrumb = nil,
							value = nil,
							text = nil,
							text = self:translate(tweak_data.blackmarket.melee_weapons[weapon_data.weapon_id].name_id, false),
							value = weapon_data,
							breadcrumb = breadcrumb
						})
					end
				elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
					local name_id = nil
					local _, skin_data = managers.weapon_inventory:get_weapons_skin(weapon_data.weapon_id)

					if skin_data then
						name_id = skin_data.name_id
					else
						name_id = tweak_data.weapon[weapon_data.weapon_id].name_id
					end

					equipped_weapon_id = managers.weapon_inventory:get_equipped_grenade_id()
					local selected = self._selected_weapon_id == weapon_data.weapon_id or equipped_weapon_id == weapon_data.weapon_id

					table.insert(result, {
						selected = nil,
						value = nil,
						text = nil,
						text = self:translate(name_id, false),
						value = weapon_data,
						selected = selected
					})
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

function WeaponSelectionGui:on_upgrade_button_click()
	if not self._weapon_select_allowed then
		return
	end

	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(self._selected_weapon_id)

	if weapon_factory_id == nil then
		return
	end

	local weapon_part_names = tweak_data.weapon.factory[weapon_factory_id].uses_parts
	local weapon_part_unit_path = ""

	for _, weapon_part_name in ipairs(weapon_part_names) do
		weapon_part_unit_path = tweak_data.weapon.factory.parts[weapon_part_name].unit

		managers.dyn_resource:load(IDS_UNIT, Idstring(weapon_part_unit_path), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_on_weapon_part_unit_loaded", weapon_part_name))
	end

	self._weapon_selection_panel:hide()
	self._weapon_skills_panel:show()
	self._upgrade_button:hide()
	self._skins_button:hide()
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
				value = nil,
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
				value = nil,
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
	local weapon_name_string = ""
	local weapon_desc_string = ""

	if weapon_category == WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME or weapon_category == WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME then
		local ammo_max_multiplier = 1

		if weapon_category == WeaponInventoryManager.BM_CATEGORY_PRIMARY_NAME then
			ammo_max_multiplier = managers.player:upgrade_value("player", "primary_ammo_increase", 1)
		elseif weapon_category == WeaponInventoryManager.BM_CATEGORY_SECONDARY_NAME then
			ammo_max_multiplier = managers.player:upgrade_value("player", "secondary_ammo_increase", 1)
		end

		ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value("player", "pack_mule_ammo_total_increase", 1)
		ammo_max_multiplier = ammo_max_multiplier * managers.player:upgrade_value("player", "cache_basket_ammo_total_increase", 1)
		local base_stats, mods_stats, skill_stats = managers.weapon_inventory:get_weapon_stats(selected_weapon_data.weapon_id, weapon_category, selected_weapon_data.slot, nil)
		local damage = f2s(base_stats.damage.value) + f2s(skill_stats.damage.value)
		local magazine = f2s(base_stats.magazine.value) + f2s(skill_stats.magazine.value)
		local total_ammo = f2s(base_stats.totalammo.value * ammo_max_multiplier)
		local fire_rate = f2s(base_stats.fire_rate.value) + f2s(skill_stats.fire_rate.value)
		local accuracy = f2s(100 / (1 + tweak_data.weapon[selected_weapon_data.weapon_id].spread.steelsight)) + f2s(skill_stats.spread.value)
		local stability = f2s(base_stats.recoil.value) + f2s(skill_stats.recoil.value)
		local accuracy_as_spread = false

		if tweak_data.weapon[selected_weapon_data.weapon_id].category == WeaponTweakData.WEAPON_CATEGORY_SHOTGUN then
			accuracy_as_spread = true
		end

		if reset_applied_stats then
			self._weapon_stats:set_applied_stats({
				stability_applied_value = nil,
				accuracy_as_spread = nil,
				rate_of_fire_applied_value = nil,
				total_ammo_applied_value = nil,
				magazine_applied_value = nil,
				damage_applied_value = nil,
				accuracy_applied_value = nil,
				accuracy_as_spread = accuracy_as_spread,
				damage_applied_value = damage,
				magazine_applied_value = magazine,
				total_ammo_applied_value = total_ammo,
				rate_of_fire_applied_value = fire_rate,
				accuracy_applied_value = accuracy,
				stability_applied_value = stability
			})
		end

		self._weapon_stats:set_modified_stats({
			stability_modified_value = nil,
			accuracy_as_spread = nil,
			accuracy_modified_value = nil,
			rate_of_fire_modified_value = nil,
			total_ammo_modified_value = nil,
			magazine_modified_value = nil,
			damage_modified_value = nil,
			accuracy_as_spread = accuracy_as_spread,
			damage_modified_value = damage,
			magazine_modified_value = magazine,
			total_ammo_modified_value = total_ammo,
			rate_of_fire_modified_value = fire_rate,
			accuracy_modified_value = accuracy,
			stability_modified_value = stability
		})

		local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(selected_weapon_data.weapon_id)
		local _, skin_data = managers.weapon_inventory:get_weapons_skin(weapon_factory_id)

		if skin_data then
			weapon_name = skin_data.name_id
		else
			weapon_name = tweak_data.weapon[selected_weapon_data.weapon_id].name_id
		end

		weapon_name_string = self:translate(weapon_name, true) .. " - " .. self:translate("weapon_catagory_" .. tweak_data.weapon[selected_weapon_data.weapon_id].category, true)
		weapon_desc_string = self:translate(weapon_name .. "_desc", true)
	elseif weapon_category == WeaponInventoryManager.BM_CATEGORY_MELEE_NAME then
		local base_stats, mods_stats, skill_stats = managers.weapon_inventory:get_melee_weapon_stats(selected_weapon_data.weapon_id)
		local damage = f2s(base_stats.damage.min_value) .. "-" .. f2s(base_stats.damage.max_value)
		local knockback = f2s(base_stats.damage_effect.min_value) .. "-" .. f2s(base_stats.damage_effect.max_value)
		local range = f2s(base_stats.range.value)
		local charge_time = f2s(base_stats.charge_time.value)

		self._melee_weapon_stats:set_stats(damage, knockback, range, charge_time)

		weapon_name = tweak_data.blackmarket.melee_weapons[selected_weapon_data.weapon_id].name_id
	elseif weapon_category == WeaponInventoryManager.BM_CATEGORY_GRENADES_NAME then
		local weapon_id = selected_weapon_data.weapon_id
		local proj_tweak_data = tweak_data.projectiles[weapon_id]
		local damage = f2s(proj_tweak_data.damage or 0)
		local range = f2s(proj_tweak_data.range or 0)
		local distance = f2s(proj_tweak_data.launch_speed or 250)
		local capacity = f2s(managers.player:get_max_grenades(weapon_id))
		local _, skin_data = managers.weapon_inventory:get_weapons_skin(weapon_id)

		if skin_data then
			weapon_name = skin_data.name_id
		else
			weapon_name = proj_tweak_data.name_id
		end

		self._grenade_weapon_stats:set_stats(damage, range, distance, capacity)
	end

	if weapon_name_string == "" then
		weapon_name_string = self:translate(weapon_name, true)
	end

	if weapon_desc_string == "" then
		weapon_desc_string = self:translate(weapon_name .. "_desc", true)
	end

	self._weapon_name_label:set_text(weapon_name_string)
	self._weapon_desc_label:set_text(weapon_desc_string)
end

function WeaponSelectionGui:_recreate_and_show_weapon_parts(temp_skills)
	if self._rotate_weapon then
		local position = self._rotate_weapon:current_position()
		local rotation = self._rotate_weapon:current_rotation()
		local selected_weapon_data = self._weapon_list:selected_item():data()
		local active_weapon_data = self._weapon_list:get_active_item():data()

		if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
			local blueprint = managers.weapon_skills:recreate_weapon_blueprint(self._selected_weapon_id, self._weapon_category_id, temp_skills, false)

			self:_show_weapon(self._selected_weapon_id, blueprint)
		else
			self:_show_unit(self._selected_weapon_id)
		end

		self._rotate_weapon:set_position(position)
		self._rotate_weapon:set_rotation(rotation)
	else
		Application:error("[WeaponSelectionGui:_recreate_and_show_weapon_parts] There was no 'self._rotate_weapon'! Temp skills:", inspect(temp_skills))
	end
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
	self:show_skins_button_if_skins()
	self:_update_weapon_stats(true)
end

function WeaponSelectionGui:_select_weapon(weapon_id, weapon_category_switched)
	Application:trace("[WeaponSelectionGui:_select_weapon] weapon_id ", weapon_id, ",old:", self._selected_weapon_id)

	local old_weapon_id = self._selected_weapon_id
	local weapon_switched = self._selected_weapon_id ~= weapon_id
	self._selected_weapon_id = weapon_id

	self:_update_selected_weapon_skins()

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

	local selected_weapon = self._weapon_list:selected_item()

	if selected_weapon == self._weapon_list:get_active_item() then
		self._equip_button:hide()
		self._equip_disabled_button:show()
		self._cant_equip_explanation_label:hide()

		if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
			self._upgrade_button:show()
		end

		self:show_skins_button_if_skins()
	elseif selected_weapon:data().value.unlocked then
		self._equip_button:show()
		self._equip_disabled_button:hide()
		self._cant_equip_explanation_label:hide()

		if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID or self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
			self._upgrade_button:show()
		end

		self:show_skins_button_if_skins()
	else
		self._equip_button:hide()
		self._equip_disabled_button:hide()
		self._upgrade_button:hide()
		self._skins_button:hide()

		local info_label_text = nil

		if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
			if selected_weapon:data().value.is_challenge_reward then
				info_label_text = self:translate("character_customization_locked_cc_label", true)
			else
				info_label_text = self:translate("character_customization_locked_drop_label", true)
			end
		else
			local class_name = managers.skilltree:get_character_profile_class()
			local weapon_unlock_levels = tweak_data.skilltree:get_weapon_unlock_levels()
			local weapon_id = selected_weapon:data().value.weapon_id
			local weapon_unlocks = weapon_unlock_levels[weapon_id]
			local level = weapon_unlocks and weapon_unlocks[class_name]

			if selected_weapon:data().value.challenge then
				local challenge_id = selected_weapon:data().value.challenge
				local challenge = tweak_data.challenge[challenge_id]

				if challenge and challenge.challenge_name_id then
					local challenge_name = managers.localization:to_upper_text(challenge.challenge_name_id)
					info_label_text = managers.localization:to_upper_text("character_customization_locked_challenge_label", {
						CHALLENGE = nil,
						CHALLENGE = challenge_name
					})
				end
			elseif level then
				info_label_text = managers.localization:to_upper_text("menu_weapons_locked_higher_level", {
					LEVEL = nil,
					LEVEL = level
				})
			elseif weapon_unlocks then
				local classes = ""

				for class_name, _ in pairs(weapon_unlocks) do
					classes = classes .. self:translate("character_skill_tree_" .. class_name, true) .. ", "
				end

				classes = string.sub(classes, 0, -3)
				info_label_text = managers.localization:to_upper_text("menu_weapons_locked_wrong_class", {
					CLASSES = nil,
					CLASSES = classes
				})
			end
		end

		self._cant_equip_explanation_label:set_text(info_label_text)
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

	managers.dyn_resource:load(IDS_UNIT, unit_path_id, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_unit_loading_complete", {
		weapon_id = nil,
		weapon_switched = nil,
		pre_created_blueprint = nil,
		weapon_factory_id = nil,
		unit_path_id = nil,
		unit_path = nil,
		display_offset = nil,
		height_offset = nil,
		distance_offset = nil,
		rotation_offset = nil,
		weapon_tweak_data = nil,
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
	local wep_rot = Rotation(params.weapon_tweak_data.gui.initial_rotation.yaw or -90, params.weapon_tweak_data.gui.initial_rotation.pitch or 0, params.weapon_tweak_data.gui.initial_rotation.roll or 0)
	self._spawned_unit_position_temp = Vector3(0, 0, 0)

	if params.weapon_switched or not self._spawned_unit then
		self._spawned_unit = World:spawn_unit(params.unit_path_id, self._spawned_unit_position_temp, wep_rot)
	end

	self._spawned_unit_offset = direction_forward * params.rotation_offset

	self._spawned_unit:set_position(self._spawned_unit_position)

	if params.weapon_tweak_data.gui and params.weapon_tweak_data.gui.initial_rotation then
		self._spawned_unit:set_rotation(wep_rot)
	end

	self._spawned_unit:base():set_factory_data(params.weapon_factory_id)
	self._spawned_unit:base():set_texture_switches(nil)

	local selected_weapon_slot = managers.weapon_inventory:get_weapon_slot_by_weapon_id(params.weapon_id, self._selected_weapon_category_id)
	local weapon_category = managers.weapon_inventory:get_weapon_category_by_weapon_category_id(self._selected_weapon_category_id)
	local weapon_blueprint = params.pre_created_blueprint or managers.blackmarket:get_weapon_blueprint(weapon_category, selected_weapon_slot)
	local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(params.weapon_id)
	local parts, blueprint = managers.weapon_factory:preload_blueprint(params.weapon_factory_id, weapon_blueprint, false, callback(self, self, "_preload_blueprint_completed", {
		weapon_blueprint = nil,
		height_offset = nil,
		direction_up = nil,
		direction_forward = nil,
		distance_offset = nil,
		weapon_factory_id = nil,
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
	params.weapon_blueprint = managers.weapon_factory:modify_skin_blueprint(params.weapon_factory_id, params.weapon_blueprint)
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
	local skin_id, skin_data = managers.weapon_inventory:get_weapons_skin(weapon_id)

	if self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_MELEE_ID then
		weapon_tweak_data = tweak_data.blackmarket.melee_weapons[weapon_id] or managers.blackmarket._defaults.melee_weapon
		unit_path = weapon_tweak_data.unit
	elseif self._selected_weapon_category_id == WeaponInventoryManager.BM_CATEGORY_GRENADES_ID then
		weapon_tweak_data = tweak_data.projectiles[weapon_id]

		if skin_data and skin_data.replaces_units then
			unit_path = skin_data.replaces_units.unit_hand
		else
			unit_path = weapon_tweak_data.unit_hand
		end
	end

	if not unit_path then
		return
	end

	local ids_unit_path = Idstring(unit_path)

	managers.dyn_resource:load(IDS_UNIT, ids_unit_path, DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	local rotation_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.rotation_offset or 0
	local distance_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.distance_offset or 0
	local height_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.height_offset or 0
	local display_offset = weapon_tweak_data.gui and weapon_tweak_data.gui.display_offset or 0
	local camera = managers.viewport:get_current_camera()
	local rotation = camera:rotation()
	local direction_left = -rotation:x()
	local direction_forward = rotation:y()
	local direction_up = rotation:z()
	local sx, sy = self:pix_to_screen(self._rotate_weapon:x() + self._rotate_weapon:w() / 2, self._rotate_weapon:y() + self._rotate_weapon:h() / 2)
	self._spawned_unit_position = camera:screen_to_world(Vector3(sx, sy, 200)) + direction_left * display_offset
	self._spawned_unit_position_temp = Vector3(0, 0, 0)
	local start_rot = nil

	if weapon_tweak_data.gui and weapon_tweak_data.gui.initial_rotation then
		start_rot = Rotation(weapon_tweak_data.gui.initial_rotation.yaw or WeaponTweakData.INIT_ROTATION_YAW, weapon_tweak_data.gui.initial_rotation.pitch or 0, weapon_tweak_data.gui.initial_rotation.roll or 0)
	end

	self._spawned_unit = World:spawn_unit(ids_unit_path, self._spawned_unit_position_temp, start_rot or Rotation(-90, 0, 0))
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
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_weapon_category_tab_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_weapon_category_tab_right")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_trigger_left"),
			callback = callback(self, self, "_on_equipable_tab_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_trigger_right"),
			callback = callback(self, self, "_on_equipable_tab_right")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_upgrade_weapon_click")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_dpad_left"),
			callback = callback(self, self, "_on_weapon_skin_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_dpad_right"),
			callback = callback(self, self, "_on_weapon_skin_right")
		}
	}
	local controller_legend = {
		"menu_legend_back",
		"menu_legend_weapons_category",
		"menu_legend_weapons_equipable",
		"menu_legend_weapons_equip",
		"menu_legend_weapons_upgrade"
	}
	local legend = {
		keyboard = nil,
		controller = nil,
		controller = controller_legend,
		keyboard = {
			{
				callback = nil,
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

function WeaponSelectionGui:bind_controller_inputs_choose_weapon_no_upgrade()
	local bindings = {
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_weapon_category_tab_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_weapon_category_tab_right")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_trigger_left"),
			callback = callback(self, self, "_on_equipable_tab_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_trigger_right"),
			callback = callback(self, self, "_on_equipable_tab_right")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_dpad_left"),
			callback = callback(self, self, "_on_weapon_skin_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_dpad_right"),
			callback = callback(self, self, "_on_weapon_skin_right")
		}
	}
	local controller_legend = {
		"menu_legend_back",
		"menu_legend_weapons_category",
		"menu_legend_weapons_equipable",
		"menu_legend_weapons_equip"
	}
	local legend = {
		keyboard = nil,
		controller = nil,
		controller = controller_legend,
		keyboard = {
			{
				callback = nil,
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_controller_bindings(bindings, true)
	self:set_legend(legend)
end

function WeaponSelectionGui:bind_controller_inputs_upgrade_weapon()
	local bindings = {
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_apply_weapon_skills_click")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_on_select_weapon_skills_click")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		keyboard = nil,
		controller = nil,
		controller = {
			"menu_legend_back",
			"menu_legend_weapons_weapon_skill_select",
			"menu_legend_weapons_weapon_skill_apply"
		},
		keyboard = {
			{
				callback = nil,
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
		keyboard = nil,
		controller = nil,
		controller = {
			"menu_legend_back",
			"menu_legend_weapons_weapon_skill_select"
		},
		keyboard = {
			{
				callback = nil,
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
	if next(self._loading_units) == nil and self._weapon_select_allowed then
		self:on_upgrade_button_click()
	end

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
