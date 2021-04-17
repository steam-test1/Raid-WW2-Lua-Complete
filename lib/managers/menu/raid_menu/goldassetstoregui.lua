GoldAssetStoreGui = GoldAssetStoreGui or class(RaidGuiBase)
GoldAssetStoreGui.CONFIRM_PRESSED_STATE_BUY = "state_buy"
GoldAssetStoreGui.CONFIRM_PRESSED_STATE_APPLY = "state_apply"

-- Lines 6-16
function GoldAssetStoreGui:init(ws, fullscreen_ws, node, component_name)
	GoldAssetStoreGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_header:set_screen_name("menu_gold_asset_store_title")

	self._confirm_pressed_state = nil

	managers.raid_menu:hide_background()
end

-- Lines 18-22
function GoldAssetStoreGui:_setup_properties()
	GoldAssetStoreGui.super._setup_properties(self)

	self._background = nil
	self._background_rect = nil
end

-- Lines 24-28
function GoldAssetStoreGui:_set_initial_data()
	self._loaded_units = {}
	self._unit_data_to_show = nil
end

-- Lines 30-141
function GoldAssetStoreGui:_layout()
	self:_disable_dof()

	local gold_asset_store_grid_scrollable_area_params = {
		scrollbar_offset = 14,
		name = "gold_asset_store_grid_scrollable_area",
		h = 612,
		y = 120,
		w = 498,
		x = 0,
		scroll_step = 30
	}
	self._gold_asset_store_grid_scrollable_area = self._root_panel:scrollable_area(gold_asset_store_grid_scrollable_area_params)
	local gold_asset_store_grid_params = {
		name = "gold_asset_store_grid",
		y = 0,
		w = 480,
		x = 0,
		scrollable_area_ref = self._gold_asset_store_grid_scrollable_area,
		grid_params = {
			scroll_marker_w = 32,
			vertical_spacing = 5,
			data_source_callback = callback(self, self, "_data_source_gold_asset_store"),
			on_click_callback = callback(self, self, "_on_click_gold_asset_store"),
			on_double_click_callback = callback(self, self, "_on_double_click_gold_asset_store"),
			on_select_callback = callback(self, self, "_on_selected_gold_asset_store")
		},
		item_params = {
			item_w = 134,
			grid_item_icon = "grid_icon",
			key_value_field = "key_name",
			item_h = 134,
			selected_marker_h = 148,
			selected_marker_w = 148,
			row_class = RaidGUIControlGridItem
		}
	}
	self._gold_asset_store_grid = self._gold_asset_store_grid_scrollable_area:get_panel():grid(gold_asset_store_grid_params)
	local params_rotate_gold_item = {
		name = "rotate_gold_item",
		h = 750,
		y = 90,
		w = 800,
		x = 500
	}
	self._rotate_gold_item = self._root_panel:rotate_unit(params_rotate_gold_item)
	self._item_title = self._root_panel:label({
		w = 352,
		h = 64,
		align = "left",
		text = "",
		y = 0,
		x = 0,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_38,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._item_description = self._root_panel:label({
		w = 352,
		h = 352,
		wrap = true,
		text = "",
		y = 176,
		x = 0,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	})

	self._item_description:set_right(self._root_panel:w())
	self._item_title:set_x(self._item_description:x())
	self._item_title:set_center_y(140)

	self._coord_center_y = 864
	self._buy_button = self._root_panel:short_primary_gold_button({
		name = "buy_button",
		visible = false,
		x = 0,
		text = self:translate("gold_asset_store_buy_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_button_buy")
	})

	self._buy_button:set_center_y(self._coord_center_y)

	self._apply_button = self._root_panel:short_primary_gold_button({
		name = "buy_button",
		visible = false,
		x = 0,
		text = self:translate("gold_asset_store_apply_button", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_button_apply")
	})

	self._apply_button:set_center_y(self._coord_center_y)

	self._info_label = self._root_panel:label({
		name = "info_label",
		visible = false,
		x = 0,
		text = self:translate("grid_item_insuficient_gold_label", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small
	})
	local x1, y1, w1, h1 = self._info_label:text_rect()

	self._info_label:set_h(h1)
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
	self._gold_currency_label:set_right(self._gold_asset_store_grid_scrollable_area:x() + self._gold_asset_store_grid:x() + self._gold_asset_store_grid:w())

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
	self:_layout_greed_info()
	self:bind_controller_inputs()
	self._gold_asset_store_grid_scrollable_area:setup_scroll_area()
	self._gold_asset_store_grid:set_selected(true)

	local selected_item = self._gold_asset_store_grid:selected_grid_item()

	if selected_item then
		local selected_item_data = selected_item:get_data()

		self:_populate_selected_item_data_and_load(selected_item_data)
	end
end

-- Lines 143-176
function GoldAssetStoreGui:_layout_greed_info()
	local greed_panel_default_h = 288
	local greed_panel_bottom = 896
	local greed_info_panel_params = {
		w = 352,
		name = "greed_info_panel",
		h = greed_panel_default_h
	}
	self._greed_info_panel = self._root_panel:panel(greed_info_panel_params)

	self._greed_info_panel:set_right(self._root_panel:w())

	local greed_bar = self._greed_info_panel:create_custom_control(RaidGUIControlGreedBarSmall, {})

	greed_bar:set_data_from_manager()

	local greed_description_params = {
		name = "greed_description",
		wrap = true,
		halign = "left",
		valign = "top",
		y = greed_bar:h(),
		h = self._greed_info_panel:h() - greed_bar:h(),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey,
		text = self:translate("menu_greed_description", false)
	}
	local greed_description = self._greed_info_panel:text(greed_description_params)
	local _, _, _, h = greed_description:text_rect()

	greed_description:set_h(h)

	local greed_panel_h = math.max(greed_description:y() + greed_description:h(), greed_panel_default_h)

	self._greed_info_panel:set_h(greed_panel_h)
	self._greed_info_panel:set_bottom(greed_panel_bottom)
end

-- Lines 181-189
function GoldAssetStoreGui:_data_source_gold_asset_store()
	local gold_items_data_source = managers.gold_economy:get_store_items_data()

	for _, gold_item in pairs(gold_items_data_source) do
		gold_item.key_name = gold_item.upgrade_name .. "_level_" .. gold_item.level
	end

	return gold_items_data_source
end

-- Lines 192-196
function GoldAssetStoreGui:_on_click_gold_asset_store(item_data)
	self:_grid_item_clicked_selected(item_data)
end

-- Lines 199-203
function GoldAssetStoreGui:_on_double_click_gold_asset_store(item_data)
	self:_grid_item_clicked_selected(item_data)
end

-- Lines 206-210
function GoldAssetStoreGui:_on_selected_gold_asset_store(item_idx, item_data)
	self:_grid_item_clicked_selected(item_data)
end

-- Lines 213-221
function GoldAssetStoreGui:_on_click_button_buy()
	local selected_item = self._gold_asset_store_grid:selected_grid_item()
	local selected_item_data = selected_item:get_data()
	local dialog_params = {
		amount = selected_item_data.gold_price,
		item_name = self:translate(selected_item_data.name_id, true),
		callback_yes = callback(self, self, "_buy_gold_item_yes_callback", selected_item_data)
	}

	managers.menu:show_gold_asset_store_purchase_dialog(dialog_params)
end

-- Lines 224-232
function GoldAssetStoreGui:_on_click_button_apply()
	local selected_item = self._gold_asset_store_grid:selected_grid_item()
	local selected_item_data = selected_item:get_data()

	self:_apply_upgrade_to_camp(selected_item_data.upgrade_name, selected_item_data.level)
end

-- Lines 234-241
function GoldAssetStoreGui:update(t, dt)
	if self._unit_data_to_show and self._loaded_units[self._unit_data_to_show.scene_unit] and self._unit_data_to_show_changed then
		self:_spawn_scene_camp_unit(self._unit_data_to_show)

		self._unit_data_to_show_changed = false
	end
end

-- Lines 245-255
function GoldAssetStoreGui:_grid_item_clicked_selected(item_data)
	if self._unit_data_to_show == item_data then
		return
	end

	self:_despawn_scene_camp_unit()

	self._unit_data_to_show = item_data
	self._unit_data_to_show_changed = true

	self:_populate_selected_item_data_and_load(item_data)
end

-- Lines 257-272
function GoldAssetStoreGui:_populate_selected_item_data_and_load(item_data)
	self:_load_scene_camp_unit(item_data)
	self._item_description:set_text(self:translate(item_data.description_id, false))
	self._item_title:set_text(self:translate(item_data.name_id, true))

	local _, _, w, _ = self._item_title:text_rect()

	self._item_title:set_w(w)

	local title_x = math.min(self._item_description:x(), self._root_panel:w() - w)

	self._item_title:set_x(title_x)
	self:_process_controls_states()
end

-- Lines 274-284
function GoldAssetStoreGui:_load_scene_camp_unit(item_data)
	if not item_data.scene_unit or item_data.scene_unit == "" then
		return
	end

	self._loaded_units[item_data.scene_unit] = false

	managers.dyn_resource:load(Idstring("unit"), Idstring(item_data.scene_unit), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_camp_scene_unit_loaded_callback", item_data))
end

-- Lines 286-296
function GoldAssetStoreGui:_spawn_scene_camp_unit(unit_data_to_show)
	self._spawned_unit_position = self:get_character_spawn_location()
	self._spawned_unit = World:spawn_unit(Idstring(unit_data_to_show.scene_unit), self._spawned_unit_position, Rotation(0, 0, 0))

	if unit_data_to_show and unit_data_to_show.scene_unit_rotation then
		self._spawned_unit:set_rotation(unit_data_to_show.scene_unit_rotation)
	end

	self._rotate_gold_item:set_unit(self._spawned_unit, self._spawned_unit_position, 90, self._spawned_unit_offset, Vector3(0, 0, 0))
end

-- Lines 298-313
function GoldAssetStoreGui:get_character_spawn_location()
	local units = World:find_units_quick("all", managers.slot:get_mask("env_effect"))
	local result = nil

	if units then
		for _, unit in pairs(units) do
			if unit:name() == Idstring("units/vanilla/props/props_camp_upgrades/golden_store_floor/golden_store_floor") then
				result = unit:get_object(Idstring("rp_golden_store_floor")):position()

				mvector3.add(result, Vector3(0, 0, 10))
			end
		end
	end

	return result
end

-- Lines 315-319
function GoldAssetStoreGui:pix_to_screen(px_x, px_y)
	local sx = 2 * px_x / self._root_panel:w() - 1
	local sy = 2 * px_y / self._root_panel:h() - 1

	return sx, sy
end

-- Lines 321-326
function GoldAssetStoreGui:_despawn_scene_camp_unit()
	if self._spawned_unit then
		self._spawned_unit:set_slot(0)

		self._spawned_unit = nil
	end
end

-- Lines 328-331
function GoldAssetStoreGui:_camp_scene_unit_loaded_callback(item_data)
	self._loaded_units[item_data.scene_unit] = true
end

-- Lines 333-422
function GoldAssetStoreGui:_process_controls_states()
	local selected_item_data = self._gold_asset_store_grid:selected_grid_item():get_data()

	if selected_item_data.gold_price then
		self._gold_currency_label:set_text(selected_item_data.gold_price)

		local x2, y2, w2, h2 = self._gold_currency_label:text_rect()

		self._gold_currency_label:set_h(h2)
		self._gold_currency_label:set_w(w2)
		self._gold_currency_label:set_center_y(self._coord_center_y)
		self._gold_currency_label:set_right(self._gold_asset_store_grid_scrollable_area:x() + self._gold_asset_store_grid:x() + self._gold_asset_store_grid:w())
		self._gold_currency_icon:set_center_y(self._coord_center_y)
		self._gold_currency_icon:set_right(self._gold_currency_label:x() - 14)
		self._gold_item_bought_icon:set_center_y(self._coord_center_y)
		self._gold_item_bought_icon:set_right(self._gold_currency_label:x() - 14)
	end

	if not Network:is_server() then
		self._info_label:show()
		self._info_label:set_text(self:translate("gold_asset_store_only_host", true))
		self._info_label:set_color(tweak_data.gui.colors.raid_red)
		self._gold_currency_icon:hide()
		self._gold_currency_label:hide()
		self._gold_item_bought_icon:hide()
		self:bind_controller_inputs()

		return
	end

	if selected_item_data.status == RaidGUIControlGridItem.STATUS_OWNED_OR_PURCHASED then
		self._buy_button:hide()
		self._gold_currency_icon:hide()
		self._gold_currency_label:hide()
		self._gold_item_bought_icon:hide()

		if managers.gold_economy:is_upgrade_applied(selected_item_data.upgrade_name, selected_item_data.level) then
			self._apply_button:hide()
			self._info_label:show()
			self._info_label:set_text(self:translate("gold_asset_store_upgrade_is_applied", true))
			self._info_label:set_color(tweak_data.gui.colors.raid_white)
			self:bind_controller_inputs()
		else
			self._apply_button:show()
			self._info_label:hide()
			self:bind_controller_inputs_apply()
		end
	elseif selected_item_data.status == RaidGUIControlGridItem.STATUS_PURCHASABLE then
		self._apply_button:hide()
		self._buy_button:show()
		self._buy_button:enable()
		self._buy_button:set_text(self:translate("gold_asset_store_buy_button", true))
		self._info_label:hide()
		self._gold_currency_icon:show()
		self._gold_currency_label:show()
		self._gold_item_bought_icon:hide()
		self:bind_controller_inputs_buy()
	elseif selected_item_data.status == RaidGUIControlGridItem.STATUS_NOT_ENOUGHT_RESOURCES then
		self._apply_button:hide()
		self._buy_button:hide()
		self._info_label:show()
		self._info_label:set_text(self:translate("gold_asset_store_insuficient_gold_label", true))
		self._info_label:set_color(tweak_data.gui.colors.raid_red)
		self._gold_currency_icon:show()
		self._gold_currency_label:show()
		self._gold_item_bought_icon:hide()
		self:bind_controller_inputs()
	end
end

-- Lines 424-431
function GoldAssetStoreGui:_buy_gold_item_yes_callback(item_data)
	Application:trace("[GoldAssetStoreGui:_buy_gold_item_yes_callback] item_data ", inspect(item_data))
	managers.gold_economy:spend_gold(item_data.gold_price)
	self:_apply_upgrade_to_camp(item_data.upgrade_name, item_data.level)
end

-- Lines 434-451
function GoldAssetStoreGui:_apply_upgrade_to_camp(upgrade_name, level)
	managers.gold_economy:update_camp_upgrade(upgrade_name, level)
	self._gold_asset_store_grid:refresh_data()
	self._gold_asset_store_grid:select_grid_item_by_key_value({
		key = "key_name",
		value = upgrade_name .. "_level_" .. level
	})
	self:_process_controls_states()
	managers.savefile:setting_changed()
	managers.savefile:save_setting(true)
	managers.gold_economy:layout_camp()
	managers.menu_component:post_event("gold_spending_apply")
end

-- Lines 453-465
function GoldAssetStoreGui:close()
	for scene_unit, loaded in pairs(self._loaded_units) do
		if not loaded then
			Application:trace("[GoldAssetStoreGui][close] Unloading unit ", scene_unit)
			managers.dyn_resource:unload(Idstring("unit"), Idstring(scene_unit), managers.dyn_resource.DYN_RESOURCES_PACKAGE, false)
		end
	end

	self:_despawn_scene_camp_unit()
	self:_enable_dof()
	GoldAssetStoreGui.super.close(self)
end

-- Lines 471-483
function GoldAssetStoreGui:bind_controller_inputs()
	local legend = {
		controller = {
			"menu_legend_back"
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

-- Lines 485-498
function GoldAssetStoreGui:bind_controller_inputs_buy()
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_gold_asset_store_buy"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)

	self._confirm_pressed_state = GoldAssetStoreGui.CONFIRM_PRESSED_STATE_BUY
end

-- Lines 500-513
function GoldAssetStoreGui:bind_controller_inputs_apply()
	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_gold_asset_store_apply"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}

	self:set_legend(legend)

	self._confirm_pressed_state = GoldAssetStoreGui.CONFIRM_PRESSED_STATE_APPLY
end

-- Lines 515-528
function GoldAssetStoreGui:confirm_pressed()
	local selected_item = self._gold_asset_store_grid:selected_grid_item()

	if selected_item and selected_item:get_data() then
		if self._confirm_pressed_state == GoldAssetStoreGui.CONFIRM_PRESSED_STATE_BUY then
			self:_on_click_button_buy()
		elseif self._confirm_pressed_state == GoldAssetStoreGui.CONFIRM_PRESSED_STATE_APPLY then
			self:_on_click_button_apply()
		end
	end

	return true
end
