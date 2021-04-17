CharacterCustomizationGui = CharacterCustomizationGui or class(RaidGuiBase)
CharacterCustomizationGui.CHARACTER_SPAWN_LOCATION = Vector3(-514.259, -3565.31, -620.056)
CharacterCustomizationGui.CHARACTER_SPAWN_ROTATION = Rotation(0, 0, 0)
CharacterCustomizationGui.CONFIRM_PRESSED_STATE_BUY = "state_buy"
CharacterCustomizationGui.CONFIRM_PRESSED_STATE_EQUIP = "state_equip"

-- Lines 9-19
function CharacterCustomizationGui:init(ws, fullscreen_ws, node, component_name)
	CharacterCustomizationGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_header:set_screen_name("character_customization_title")

	self._confirm_pressed_state = nil

	managers.raid_menu:hide_background()
end

-- Lines 21-25
function CharacterCustomizationGui:_setup_properties()
	CharacterCustomizationGui.super._setup_properties(self)

	self._background = nil
	self._background_rect = nil
end

-- Lines 27-46
function CharacterCustomizationGui:_set_initial_data()
	managers.character_customization:reset_current_version_to_attach()

	self._all_customizations = tweak_data.character_customization.customizations
	self._equipped_head_name = managers.player:get_customization_equiped_head_name()
	self._equipped_upper_name = managers.player:get_customization_equiped_upper_name()
	self._equipped_lower_name = managers.player:get_customization_equiped_lower_name()
	self._selected_head_name = managers.player:get_customization_equiped_head_name()
	self._selected_upper_name = managers.player:get_customization_equiped_upper_name()
	self._selected_lower_name = managers.player:get_customization_equiped_lower_name()
	self._character_spawn_location = nil

	self:get_character_spawn_location()
	self:spawn_character_unit()
	self:render_all_parts()
end

-- Lines 48-210
function CharacterCustomizationGui:_layout()
	local character_nationality = managers.player:get_character_profile_nation()

	self:_disable_dof()

	self._filter_body_part = self._root_panel:tabs({
		tab_align = "center",
		name = "filter_body_part",
		tab_width = 240,
		initial_tab_idx = 1,
		tab_height = 64,
		y = 96,
		x = 0,
		on_click_callback = callback(self, self, "_on_click_filter_body_part"),
		tabs_params = {
			{
				name = "tab_upper",
				text = self:translate("character_customization_filter_body_part_upper", true),
				callback_param = CharacterCustomizationTweakData.PART_TYPE_UPPER,
				breadcrumb = {
					category = BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION_UPPER,
					identifiers = {
						character_nationality
					}
				}
			},
			{
				name = "tab_lower",
				text = self:translate("character_customization_filter_body_part_lower", true),
				callback_param = CharacterCustomizationTweakData.PART_TYPE_LOWER,
				breadcrumb = {
					category = BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION_LOWER,
					identifiers = {
						character_nationality
					}
				}
			}
		}
	})
	self._selected_filter_body_part = CharacterCustomizationTweakData.PART_TYPE_UPPER
	local customization_grid_scrollable_area_params = {
		name = "customization_grid_scrollable_area",
		h = 598,
		y = 190,
		w = 484,
		x = 0,
		scroll_step = 30
	}
	self._customization_grid_scrollable_area = self._root_panel:scrollable_area(customization_grid_scrollable_area_params)
	local customization_grid_params = {
		name = "customization_grid",
		y = 0,
		w = 480,
		x = 0,
		scrollable_area_ref = self._customization_grid_scrollable_area,
		grid_params = {
			scroll_marker_w = 32,
			vertical_spacing = 5,
			data_source_callback = callback(self, self, "_data_source_character_customizations"),
			on_click_callback = callback(self, self, "_on_click_character_customizations"),
			on_double_click_callback = callback(self, self, "_on_double_click_character_customizations"),
			on_select_callback = callback(self, self, "_on_selected_character_customizations")
		},
		item_params = {
			item_w = 134,
			grid_item_icon = "path_icon",
			key_value_field = "key_name",
			item_h = 134,
			selected_marker_h = 148,
			selected_marker_w = 148,
			row_class = RaidGUIControlGridItemActive
		}
	}
	self._character_customizations_grid = self._customization_grid_scrollable_area:get_panel():grid_active(customization_grid_params)
	self._profile_name_label = self._root_panel:label({
		name = "profile_name_label",
		h = 32,
		w = 356,
		align = "right",
		text = "",
		y = 96,
		x = 1376,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.large,
		color = tweak_data.gui.colors.raid_white
	})

	self._profile_name_label:set_right(self._root_panel:right())

	self._character_name_label = self._root_panel:label({
		name = "character_name_label",
		h = 32,
		w = 356,
		align = "right",
		text = "",
		y = 128,
		x = 1376,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_grey
	})

	self._character_name_label:set_right(self._root_panel:right())

	self._right_side_info = self._root_panel:create_custom_control(RaidGUIControlCharacterDescription, {
		name = "right_side_info_panel",
		h = 640,
		y = 192,
		w = 356,
		x = 1376,
		mode = RaidGUIControlCharacterDescription.MODE_CUSTOMIZATION
	}, {})

	self._right_side_info:set_right(self._root_panel:right())

	local nationality = PlayerManager:get_character_profile_nation()
	local class_name = managers.skilltree._global.character_profile_base_class
	local level = Application:digest_value(managers.experience._global.level, false)

	self._right_side_info:set_data({
		class_name = class_name,
		nationality = nationality,
		level = level
	})

	local icon_data = self:get_icon_data_for_body_part(self._selected_filter_body_part)
	self._body_part_icon = self._root_panel:image({
		x = self._right_side_info:x(),
		y = self._right_side_info:y() + 176,
		w = icon_data.texture_rect[3],
		h = icon_data.texture_rect[4],
		texture = icon_data.texture,
		texture_rect = icon_data.texture_rect
	})
	local body_part_data = self._all_customizations[self._selected_upper_name]
	self._body_part_title = self._root_panel:label({
		wor_wrap = true,
		wrap = true,
		w = 288,
		x = self._body_part_icon:x() + 48,
		y = self._body_part_icon:y(),
		text = self:translate(body_part_data.name, true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.large,
		color = tweak_data.gui.colors.raid_white
	})
	self._body_part_description = self._root_panel:label({
		h = 448,
		wrap = true,
		w = 352,
		x = self._body_part_icon:x(),
		text = self:translate(body_part_data.description, false),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	})

	self._body_part_description:set_top(self._body_part_title:bottom() + 10)

	self._coord_center_y = 864
	self._equip_button = self._root_panel:short_primary_button({
		name = "equip_button",
		visible = false,
		x = 0,
		text = self:translate("character_customization_equip_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_button_equip")
	})

	self._equip_button:set_center_y(self._coord_center_y)

	self._equip_gold_button = self._root_panel:short_primary_gold_button({
		name = "equip_gold_button",
		visible = false,
		x = 0,
		text = self:translate("character_customization_equip_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_button_equip")
	})

	self._equip_gold_button:set_center_y(self._coord_center_y)

	self._buy_button = self._root_panel:short_primary_gold_button({
		name = "buy_button",
		visible = false,
		x = 0,
		text = self:translate("character_customization_buy_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_button_buy")
	})

	self._buy_button:set_center_y(self._coord_center_y)

	self._info_label = self._root_panel:label({
		name = "info_label",
		h = 60,
		wrap = true,
		w = 520,
		word_wrap = true,
		visible = false,
		x = 0,
		text = self:translate("character_customization_insuficient_gold_label", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small
	})

	self._info_label:set_center_y(self._coord_center_y)

	self._gold_currency_label = self._root_panel:label({
		text = "",
		name = "gold_currency_label",
		visible = false,
		x = 250,
		layer = RaidGuiBase.FOREGROUND_LAYER,
		color = tweak_data.gui.colors.gold_orange,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_38
	})
	local x2, y2, w2, h2 = self._gold_currency_label:text_rect()

	self._gold_currency_label:set_h(h2)
	self._gold_currency_label:set_w(w2)
	self._gold_currency_label:set_center_y(self._coord_center_y)
	self._gold_currency_label:set_right(512)

	self._gold_currency_icon = self._root_panel:bitmap({
		name = "gold_currency_icon",
		visible = false,
		x = 200,
		layer = RaidGuiBase.FOREGROUND_LAYER,
		color = tweak_data.gui.colors.gold_orange,
		texture = tweak_data.gui.icons.gold_amount_purchase.texture,
		texture_rect = tweak_data.gui.icons.gold_amount_purchase.texture_rect
	})

	self._gold_currency_icon:set_center_y(self._coord_center_y)
	self._gold_currency_icon:set_right(self._gold_currency_label:x() - 14)

	self._gold_item_bought_icon = self._root_panel:bitmap({
		name = "gold_item_bought_icon",
		visible = false,
		x = 200,
		layer = RaidGuiBase.FOREGROUND_LAYER,
		texture = tweak_data.gui.icons.consumable_purchased_confirmed.texture,
		texture_rect = tweak_data.gui.icons.consumable_purchased_confirmed.texture_rect
	})

	self._gold_item_bought_icon:set_center_y(self._coord_center_y)
	self._gold_item_bought_icon:set_right(self._gold_currency_label:x() - 14)
	self:bind_controller_inputs()
	self._customization_grid_scrollable_area:setup_scroll_area()
	self._character_customizations_grid:set_selected(true, true)

	local selected_item = self._character_customizations_grid:select_grid_item_by_key_value({
		key = "key_name",
		value = self._equipped_upper_name
	})

	self:show_character_description(selected_item:get_data())
	self._character_customizations_grid:activate_item_by_value({
		key = "key_name",
		value = self._equipped_upper_name
	})
	self:_process_controls_states()
end

-- Lines 212-221
function CharacterCustomizationGui:close()
	self:_enable_dof()
	self:save_equipped_customizations()
	self:destroy_character_unit()
	CharacterCustomizationGui.super.close(self)
end

-- Lines 226-230
function CharacterCustomizationGui:_on_click_button_equip()
	self:_equip_selected_customization()
end

-- Lines 233-241
function CharacterCustomizationGui:_on_click_button_buy()
	Application:trace("[CharacterCustomizationGui:_on_click_button_buy]")

	local selected_item = self._character_customizations_grid:selected_grid_item()
	local selected_item_data = selected_item:get_data()
	local dialog_params = {
		amount = selected_item_data.gold_price,
		customization_name = self:translate(selected_item_data.name, true),
		callback_yes = callback(self, self, "_buy_customization_yes_callback")
	}

	managers.menu:show_character_customization_purchase_dialog(dialog_params)
end

-- Lines 246-250
function CharacterCustomizationGui:_on_click_filter_body_part(data)
	self:_process_body_part_filter(data)
end

-- Lines 253-259
function CharacterCustomizationGui:_data_source_character_customizations()
	local character_nationality = managers.player:get_character_profile_nation()
	local grid_data = managers.character_customization:get_all_parts_indexed_filtered(self._selected_filter_body_part, character_nationality, false)

	return grid_data
end

-- Lines 262-266
function CharacterCustomizationGui:_on_click_character_customizations(item_data)
	self:_select_grid_item(item_data)
end

-- Lines 269-273
function CharacterCustomizationGui:_on_double_click_character_customizations(item_data)
	self:_equip_selected_customization()
end

-- Lines 276-280
function CharacterCustomizationGui:_on_selected_character_customizations(item_idx, item_data)
	self:_select_grid_item(item_data)
end

-- Lines 284-325
function CharacterCustomizationGui:_equip_selected_customization()
	local selected_item_data, character_customizations = nil

	if self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		character_customizations = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_UPPER)
		selected_item_data = character_customizations[self._selected_upper_name]
	elseif self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		character_customizations = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_LOWER)
		selected_item_data = character_customizations[self._selected_lower_name]
	end

	local selected_item = self._character_customizations_grid:selected_grid_item()
	local selected_item_data = selected_item:get_data()

	if not managers.character_customization:is_character_customization_owned(selected_item_data.key_name) then
		return
	end

	self._character_customizations_grid:activate_item_by_value({
		key = "key_name",
		value = selected_item_data.key_name
	})

	if self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		self._equipped_upper_name = selected_item_data.key_name
	elseif self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		self._equipped_lower_name = selected_item_data.key_name
	end

	managers.raid_menu:refresh_footer_gold_amount()
	self:_process_controls_states()
end

-- Lines 327-378
function CharacterCustomizationGui:_buy_customization_yes_callback()
	local selected_item_data, character_customizations = nil
	local owned_gold = managers.gold_economy:current()

	if self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		character_customizations = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_UPPER)
		selected_item_data = character_customizations[self._selected_upper_name]
	elseif self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		character_customizations = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_LOWER)
		selected_item_data = character_customizations[self._selected_lower_name]
	end

	if not selected_item_data.gold_price or selected_item_data.gold_price and owned_gold < selected_item_data.gold_price then
		return
	end

	managers.gold_economy:spend_gold(selected_item_data.gold_price, false)
	managers.character_customization:add_character_customization_to_inventory(selected_item_data.key_name, true)
	self:_process_body_part_filter(self._selected_filter_body_part)
	self._character_customizations_grid:select_grid_item_by_key_value({
		key = "key_name",
		value = selected_item_data.key_name
	})
	self._character_customizations_grid:activate_item_by_value({
		key = "key_name",
		value = selected_item_data.key_name
	})

	if self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		self._selected_upper_name = selected_item_data.key_name
		self._equipped_upper_name = selected_item_data.key_name
	elseif self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		self._selected_lower_name = selected_item_data.key_name
		self._equipped_lower_name = selected_item_data.key_name
	end

	self:_process_controls_states()
	managers.savefile:save_game(SavefileManager.SETTING_SLOT, false)
end

-- Lines 380-515
function CharacterCustomizationGui:_process_controls_states()
	local equipped_item_data = self._character_customizations_grid:get_active_item():get_data()
	local selected_item_data = self._character_customizations_grid:selected_grid_item():get_data()

	if selected_item_data.gold_price then
		self._gold_currency_label:set_text(selected_item_data.gold_price)

		local x2, y2, w2, h2 = self._gold_currency_label:text_rect()

		self._gold_currency_label:set_h(h2)
		self._gold_currency_label:set_w(w2)
		self._gold_currency_label:set_center_y(self._coord_center_y)
		self._gold_currency_label:set_right(512)
		self._gold_currency_icon:set_center_y(self._coord_center_y)
		self._gold_currency_icon:set_right(self._gold_currency_label:x() - 14)
		self._gold_item_bought_icon:set_center_y(self._coord_center_y)
		self._gold_item_bought_icon:set_right(self._gold_currency_label:x() - 14)
	end

	if selected_item_data.locked == CharacterCustomizationManager.LOCKED_GOLD_NOT_OWNED and selected_item_data.gold_price and managers.gold_economy:current() < selected_item_data.gold_price then
		self._equip_button:hide()
		self._equip_gold_button:hide()
		self._buy_button:hide()
		self._info_label:show()
		self._info_label:set_text(self:translate("character_customization_insuficient_gold_label", true))
		self._info_label:set_color(tweak_data.gui.colors.gold_orange)
		self._gold_currency_icon:show()
		self._gold_currency_label:show()
		self._gold_item_bought_icon:hide()
		self:bind_controller_inputs()
	elseif selected_item_data.locked == CharacterCustomizationManager.LOCKED_GOLD_NOT_OWNED and selected_item_data.gold_price and selected_item_data.gold_price <= managers.gold_economy:current() then
		self._equip_button:hide()
		self._equip_gold_button:hide()
		self._buy_button:show()
		self._info_label:hide()
		self._gold_currency_icon:show()
		self._gold_currency_label:show()
		self._gold_item_bought_icon:hide()
		self:bind_controller_inputs_buy()
	elseif selected_item_data.locked == CharacterCustomizationManager.LOCKED_NOT_OWNED then
		self._equip_button:hide()
		self._equip_gold_button:hide()
		self._buy_button:hide()
		self._info_label:show()
		self._info_label:set_text(self:translate("character_customization_locked_drop_label", true))
		self._info_label:set_color(tweak_data.gui.colors.raid_red)
		self._gold_currency_icon:hide()
		self._gold_currency_label:hide()
		self._gold_item_bought_icon:hide()
		self:bind_controller_inputs()
	elseif selected_item_data.locked == CharacterCustomizationManager.LOCKED_DLC_SPECIFIC then
		self._equip_button:hide()
		self._equip_gold_button:hide()
		self._buy_button:hide()
		self._info_label:show()
		self._info_label:set_text(self:translate("character_customization_locked_dlc_label", true))
		self._info_label:set_color(tweak_data.gui.colors.raid_red)
		self._gold_currency_icon:hide()
		self._gold_currency_label:hide()
		self._gold_item_bought_icon:hide()
		self:bind_controller_inputs()
	elseif not selected_item_data.locked and selected_item_data.gold_price then
		self._equip_button:hide()
		self._equip_gold_button:show()
		self._buy_button:hide()
		self._info_label:hide()
		self._gold_currency_icon:hide()
		self._gold_currency_label:show()
		self._gold_item_bought_icon:show()

		if selected_item_data.key_name == equipped_item_data.key_name then
			self._equip_gold_button:disable()
			self._equip_gold_button:set_text(self:translate("character_customization_equipped_button", true))
		else
			self._equip_gold_button:enable()
			self._equip_gold_button:set_text(self:translate("character_customization_equip_button", true))
		end

		self:bind_controller_inputs_equip()
	elseif not selected_item_data.locked and not selected_item_data.gold_price then
		self._equip_button:show()
		self._equip_gold_button:hide()
		self._buy_button:hide()
		self._info_label:hide()
		self._gold_currency_icon:hide()
		self._gold_currency_label:hide()
		self._gold_item_bought_icon:hide()

		if selected_item_data.key_name == equipped_item_data.key_name then
			self._equip_button:disable()
			self._equip_button:set_text(self:translate("character_customization_equipped_button", true))
		else
			self._equip_button:enable()
			self._equip_button:set_text(self:translate("character_customization_equip_button", true))
		end

		self:bind_controller_inputs_equip()
	end
end

-- Lines 517-559
function CharacterCustomizationGui:_process_body_part_filter(data)
	local active_item_data = self._character_customizations_grid:get_active_item():get_data()

	self._character_customizations_grid:select_grid_item_by_key_value({
		key = "key_name",
		value = active_item_data.key_name
	})
	self:_equip_selected_customization()

	self._selected_filter_body_part = data

	self._character_customizations_grid:refresh_data()

	local body_part_name = ""

	if self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		body_part_name = self._equipped_upper_name
	elseif self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		body_part_name = self._equipped_lower_name
	end

	self._customization_grid_scrollable_area:setup_scroll_area()
	self._character_customizations_grid:set_selected(true, true)

	local selected_item = self._character_customizations_grid:select_grid_item_by_key_value({
		key = "key_name",
		value = body_part_name
	})

	self:show_character_description(selected_item:get_data())
	self._character_customizations_grid:activate_item_by_value({
		key = "key_name",
		value = selected_item:get_data().key_name
	})
	self:_process_controls_states()
end

-- Lines 561-604
function CharacterCustomizationGui:_select_grid_item(item_data)
	if self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_HEAD then
		if self._selected_head_name == item_data.key_name then
			return
		end

		self._selected_head_name = item_data.key_name

		self:_set_selected_piece(CharacterCustomizationTweakData.PART_TYPE_HEAD, item_data)
	elseif self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		if self._selected_upper_name == item_data.key_name then
			return
		end

		self._selected_upper_name = item_data.key_name

		self:_set_selected_piece(CharacterCustomizationTweakData.PART_TYPE_UPPER, item_data)
	elseif self._selected_filter_body_part == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		if self._selected_lower_name == item_data.key_name then
			return
		end

		self._selected_lower_name = item_data.key_name

		self:_set_selected_piece(CharacterCustomizationTweakData.PART_TYPE_LOWER, item_data)
	end

	self:_process_controls_states()
	managers.dialog:queue_dialog("player_gen_custom_right_clothes", {
		skip_idle_check = true,
		instigator = managers.player:local_player()
	})

	local random_animation_index = math.random(1, #tweak_data.character_customization.customization_animations)
	local anim_state_name = tweak_data.character_customization.customization_animations[random_animation_index]
	local state = self._spawned_character_unit:play_redirect(Idstring(anim_state_name))

	self._spawned_character_unit:anim_state_machine():set_parameter(state)
	self:show_character_description(item_data)
	managers.menu_component:post_event("clothes_selection_change")
end

-- Lines 606-619
function CharacterCustomizationGui:show_character_description(item_data)
	local icon_data = self:get_icon_data_for_body_part(self._selected_filter_body_part)

	self._body_part_icon:set_image(icon_data.texture)
	self._body_part_icon:set_texture_rect(icon_data.texture_rect)
	self._body_part_title:set_text(self:translate(item_data.name, true))

	local x, y, w, h = self._body_part_title:text_rect()

	self._body_part_title:set_h(h)
	self._body_part_description:set_top(self._body_part_title:bottom() + 10)
	self._body_part_description:set_text(self:translate(item_data.description, false))
end

-- Lines 621-631
function CharacterCustomizationGui:get_character_spawn_location()
	local units = World:find_units_quick("all", managers.slot:get_mask("env_effect"))

	if units then
		for _, unit in pairs(units) do
			if unit:name() == Idstring("units/vanilla/arhitecture/ber_a/ber_a_caracter_menu/caracter_menu_floor/caracter_menu_floor") then
				self._character_spawn_location = unit:get_object(Idstring("rp_caracter_menu_floor"))
			end
		end
	end
end

-- Lines 633-643
function CharacterCustomizationGui:spawn_character_unit()
	if not self._spawned_character_unit then
		self:destroy_character_unit()

		local unit_name = CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT
		local position = self._character_spawn_location:position() or Vector3(0, 0, 0)
		local rotation = Rotation(0, 0, 0)
		self._spawned_character_unit = World:spawn_unit(Idstring(unit_name), position, rotation)
	end
end

-- Lines 645-651
function CharacterCustomizationGui:destroy_character_unit()
	if self._spawned_character_unit then
		self._spawned_character_unit:customization():destroy_all_parts_on_character()
		self._spawned_character_unit:set_slot(0)

		self._spawned_character_unit = nil
	end
end

-- Lines 653-663
function CharacterCustomizationGui:render_all_parts()
	local character_nationality = managers.player:get_character_profile_nation()

	self._spawned_character_unit:customization():attach_all_parts_to_character_by_parts(character_nationality, self._selected_head_name, self._selected_upper_name, self._selected_lower_name)

	local anim_state_name = tweak_data.character_customization.customization_animation_idle_loop
	local state = self._spawned_character_unit:play_redirect(Idstring(anim_state_name))

	self._spawned_character_unit:anim_state_machine():set_parameter(state)
end

-- Lines 666-693
function CharacterCustomizationGui:_set_selected_piece(part_type, part_data)
	if part_type == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		self._spawned_character_unit:customization():set_unit(part_type, part_data.path)

		local lower_data = self._all_customizations[self._selected_lower_name]
		local lower_path = part_data.length == CharacterCustomizationTweakData.PART_LENGTH_SHORT and lower_data.path_long or lower_data.path_short

		self._spawned_character_unit:customization():set_unit(CharacterCustomizationTweakData.PART_TYPE_LOWER, lower_path)
	elseif part_type == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		local upper_data = self._all_customizations[self._selected_upper_name]
		local lower_path = upper_data.length == CharacterCustomizationTweakData.PART_LENGTH_SHORT and part_data.path_long or part_data.path_short

		self._spawned_character_unit:customization():set_unit(part_type, lower_path)
	else
		self._spawned_character_unit:customization():set_unit(part_type, part_data.path)
	end
end

-- Lines 695-723
function CharacterCustomizationGui:save_equipped_customizations()
	Application:trace("self._equipped_upper_name ", inspect(self._equipped_upper_name))
	managers.player:set_customization_equiped_head_name(self._equipped_head_name)
	managers.player:set_customization_equiped_upper_name(self._equipped_upper_name)
	managers.player:set_customization_equiped_lower_name(self._equipped_lower_name)
	managers.savefile:save_game(managers.savefile:get_save_progress_slot(), false)

	local local_peer = managers.network:session():local_peer()
	local outfit_string = managers.blackmarket:outfit_string()

	Application:trace("outfit_string ", inspect(outfit_string))

	local outfit_version = local_peer:outfit_version()

	local_peer:set_outfit_string(outfit_string, outfit_version)

	local team_id = tweak_data.levels:get_default_team_ID("player")

	managers.network:session():send_to_peers_synched("set_character_customization", local_peer._unit, outfit_string, outfit_version, local_peer._id)
	managers.player:local_player():camera():camera_unit():customizationfps():attach_fps_hands(managers.player:get_character_profile_nation(), self._equipped_upper_name)
end

-- Lines 725-736
function CharacterCustomizationGui:get_icon_data_for_body_part(body_part)
	local icon_data = nil

	if body_part == CharacterCustomizationTweakData.PART_TYPE_UPPER then
		icon_data = tweak_data.gui.icons.ico_upper_body
	elseif body_part == CharacterCustomizationTweakData.PART_TYPE_LOWER then
		icon_data = tweak_data.gui.icons.ico_lower_body
	end

	return icon_data
end

-- Lines 743-761
function CharacterCustomizationGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_filter_body_part_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_filter_body_part_right")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_character_customization_shoulder"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)

	self._confirm_pressed_state = nil
end

-- Lines 763-782
function CharacterCustomizationGui:bind_controller_inputs_equip()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_filter_body_part_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_filter_body_part_right")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_character_customization_shoulder",
			"menu_legend_character_customization_equip"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)

	self._confirm_pressed_state = CharacterCustomizationGui.CONFIRM_PRESSED_STATE_EQUIP
end

-- Lines 784-803
function CharacterCustomizationGui:bind_controller_inputs_buy()
	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_filter_body_part_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_filter_body_part_right")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_character_customization_shoulder",
			"menu_legend_character_customization_buy"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)

	self._confirm_pressed_state = CharacterCustomizationGui.CONFIRM_PRESSED_STATE_BUY
end

-- Lines 805-808
function CharacterCustomizationGui:_on_filter_body_part_left()
	self._filter_body_part:_move_left()

	return true, nil
end

-- Lines 810-813
function CharacterCustomizationGui:_on_filter_body_part_right()
	self._filter_body_part:_move_right()

	return true, nil
end

-- Lines 815-826
function CharacterCustomizationGui:confirm_pressed()
	local selected_item = self._character_customizations_grid:selected_grid_item()

	if selected_item and selected_item:get_data() and self._confirm_pressed_state == CharacterCustomizationGui.CONFIRM_PRESSED_STATE_EQUIP then
		self:_equip_selected_customization()
	elseif selected_item and selected_item:get_data() and self._confirm_pressed_state == CharacterCustomizationGui.CONFIRM_PRESSED_STATE_BUY then
		self:_on_click_button_buy()
	end

	return true
end
