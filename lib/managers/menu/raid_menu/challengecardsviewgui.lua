ChallengeCardsViewGui = ChallengeCardsViewGui or class(RaidGuiBase)

function ChallengeCardsViewGui:init(ws, fullscreen_ws, node, component_name)
	ChallengeCardsViewGui.super.init(self, ws, fullscreen_ws, node, component_name)
end

function ChallengeCardsViewGui:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("challenge_cards_album_view_title")

	self._challenge_cards_data_source = {}
	self._challenge_cards_steam_data_source = {}
	self._filter_rarity = nil
	self._filter_type = nil
end

function ChallengeCardsViewGui:_layout()
	local tabs_params = {
		{
			callback_param = nil,
			text = nil,
			name = "tab_common",
			text = self:translate("loot_rarity_common", true),
			callback_param = LootDropTweakData.RARITY_COMMON
		},
		{
			callback_param = nil,
			text = nil,
			name = "tab_uncommon",
			text = self:translate("loot_rarity_uncommon", true),
			callback_param = LootDropTweakData.RARITY_UNCOMMON
		},
		{
			callback_param = nil,
			text = nil,
			name = "tab_rare",
			text = self:translate("loot_rarity_rare", true),
			callback_param = LootDropTweakData.RARITY_RARE
		},
		{
			callback_param = nil,
			text = nil,
			name = "tab_other",
			text = self:translate("menu_filter_other", true),
			callback_param = LootDropTweakData.RARITY_OTHER
		},
		{
			callback_param = nil,
			text = nil,
			name = "tab_all",
			text = self:translate("menu_filter_all", true)
		}
	}
	self._rarity_filters_tabs = self._root_panel:tabs({
		x = 0,
		name = "rarity_filters_tabs",
		dont_trigger_special_buttons = true,
		tabs_params = nil,
		on_click_callback = nil,
		initial_tab_idx = nil,
		tab_align = "center",
		tab_height = 64,
		tab_width = nil,
		y = 96,
		tab_width = 640 / #tabs_params,
		initial_tab_idx = #tabs_params,
		on_click_callback = callback(self, self, "on_click_filter_rarity"),
		tabs_params = tabs_params
	})
	self._type_filters_tabs = self._root_panel:tabs({
		x = 0,
		tab_width = 140,
		name = "type_filters_tabs",
		icon = nil,
		dont_trigger_special_buttons = true,
		tabs_params = nil,
		on_click_callback = nil,
		initial_tab_idx = 3,
		tab_align = "center",
		tab_height = 32,
		item_class = nil,
		y = 176,
		icon = tweak_data.gui.icons.ico_filter,
		item_class = RaidGUIControlTabFilter,
		on_click_callback = callback(self, self, "on_click_filter_type"),
		tabs_params = {
			{
				callback_param = nil,
				text = nil,
				name = "filter_raid",
				text = self:translate("menu_mission_selected_mission_type_raid", true),
				callback_param = OperationsTweakData.JOB_TYPE_RAID
			},
			{
				callback_param = nil,
				text = nil,
				name = "filter_operation",
				text = self:translate("menu_mission_selected_mission_type_operation", true),
				callback_param = OperationsTweakData.JOB_TYPE_OPERATION
			},
			{
				callback_param = nil,
				text = nil,
				name = "filter_type_all",
				text = self:translate("menu_mission_selected_mission_type_both", true)
			}
		}
	})
	local challenge_cards_grid_scrollable_area_params = {
		x = 0,
		y = 224,
		name = "challenge_cards_grid_scrollable_area",
		scroll_step = 30,
		h = 580,
		w = 640
	}
	self._challenge_cards_grid_scrollable_area = self._root_panel:scrollable_area(challenge_cards_grid_scrollable_area_params)
	local challenge_cards_grid_params = {
		x = 0,
		y = 0,
		scrollable_area_ref = nil,
		name = "challenge_cards_grid",
		grid_params = nil,
		item_params = nil,
		w = 636,
		scrollable_area_ref = self._challenge_cards_grid_scrollable_area,
		grid_params = {
			on_select_callback = nil,
			on_click_callback = nil,
			data_source_callback = nil,
			scroll_marker_w = 32,
			vertical_spacing = 5,
			data_source_callback = callback(self, self, "data_source_inventory_cards"),
			on_click_callback = callback(self, self, "_on_click_inventory_cards"),
			on_select_callback = callback(self, self, "_on_select_inventory_cards")
		},
		item_params = {
			key_value_field = "key_name",
			hover_selects = true,
			row_class = nil,
			selected_marker_h = 250,
			selected_marker_w = 192,
			item_h = 216,
			item_w = 156,
			row_class = RaidGUIControlCardWithSelector
		}
	}
	self._card_grid = self._challenge_cards_grid_scrollable_area:get_panel():grid(challenge_cards_grid_params)
	local card_details_params = {
		x = 736,
		visible = true,
		w = 992,
		name = "card_deatils",
		h = 736,
		y = 96
	}
	self._card_details = self._root_panel:create_custom_control(RaidGUIControlCardDetails, card_details_params)

	self._card_details:set_control_mode(RaidGUIControlCardDetails.MODE_VIEW_ONLY)
	managers.system_event_listener:add_listener("challenge_cards_view_gui_steam_inventory_loaded", {
		CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_LOADED
	}, callback(self, self, "render_player_inventory"))
	managers.network.account:inventory_load()
	self:bind_controller_inputs()
end

function ChallengeCardsViewGui:on_click_filter_rarity(rarity)
	self._filter_rarity = rarity

	self:reload_filtered_data()
end

function ChallengeCardsViewGui:on_click_filter_type(type)
	self._filter_type = type

	self:reload_filtered_data()
end

function ChallengeCardsViewGui:reload_filtered_data()
	if self._challenge_cards_steam_data_source and (self._filter_rarity == LootDropTweakData.RARITY_ALL or not self._filter_rarity) then
		self._challenge_cards_data_source = clone(self._challenge_cards_steam_data_source)
	elseif self._challenge_cards_steam_data_source and self._filter_rarity ~= LootDropTweakData.RARITY_ALL then
		local result = {}

		for _, card_data in ipairs(self._challenge_cards_steam_data_source) do
			if self._filter_rarity == LootDropTweakData.RARITY_OTHER then
				if card_data.rarity ~= LootDropTweakData.RARITY_COMMON and card_data.rarity ~= LootDropTweakData.RARITY_UNCOMMON then
					if card_data.rarity ~= LootDropTweakData.RARITY_RARE then
						table.insert(result, clone(card_data))
					end
				end
			elseif self._filter_rarity == card_data.rarity then
				table.insert(result, clone(card_data))
			end
		end

		self._challenge_cards_data_source = clone(result)
	end

	local result = {}

	if self._filter_type then
		for _, card_data in ipairs(self._challenge_cards_data_source) do
			if self._filter_type == OperationsTweakData.JOB_TYPE_RAID and card_data.card_type == ChallengeCardsTweakData.CARD_TYPE_RAID or self._filter_type == OperationsTweakData.JOB_TYPE_OPERATION and card_data.card_type == ChallengeCardsTweakData.CARD_TYPE_OPERATION then
				table.insert(result, card_data)
			end
		end

		self._challenge_cards_data_source = clone(result)
	end

	self._card_grid:refresh_data()
	self._challenge_cards_grid_scrollable_area:setup_scroll_area()
	self:_auto_select_first_card_in_grid()
	self._card_grid:set_selected(true)
end

function ChallengeCardsViewGui:data_source_inventory_cards()
	self._challenge_cards_data_source = self._challenge_cards_data_source or {}

	return self._challenge_cards_data_source
end

function ChallengeCardsViewGui:_on_click_inventory_cards(item_data)
	if item_data then
		self._card_details:set_card(item_data.key_name, item_data.steam_instance_id)
		self._card_details:set_control_mode(RaidGUIControlCardDetails.MODE_VIEW_ONLY)
	end
end

function ChallengeCardsViewGui:_on_select_inventory_cards(item_idx, item_data)
	if item_data then
		self._card_details:set_card(item_data.key_name, item_data.steam_instance_id)
		self._card_details:set_control_mode(RaidGUIControlCardDetails.MODE_VIEW_ONLY)
	end
end

function ChallengeCardsViewGui:render_player_inventory(params)
	if not params or not params.list then
		return
	end

	local result = {}

	if params.list then
		result = params.list
	end

	self._challenge_cards_steam_data_source = result
	self._challenge_cards_data_source = clone(self._challenge_cards_steam_data_source)

	self._card_grid:refresh_data()
	self:_auto_select_first_card_in_grid()
	self._challenge_cards_grid_scrollable_area:setup_scroll_area()
	self._card_grid:set_selected(true)
end

function ChallengeCardsViewGui:close()
	managers.system_event_listener:remove_listener("challenge_cards_view_gui_steam_inventory_loaded")
	ChallengeCardsGui.super.close(self)
end

function ChallengeCardsViewGui:_auto_select_first_card_in_grid()
	local card_data = nil

	if self._challenge_cards_data_source and #self._challenge_cards_data_source >= 1 then
		card_data = self._challenge_cards_data_source[1]

		self._card_details:set_card(card_data.key_name, card_data.steam_instance_id)
		self._card_details:set_control_mode(RaidGUIControlCardDetails.MODE_VIEW_ONLY)
	else
		card_data = tweak_data.challenge_cards:get_card_by_key_name(ChallengeCardsManager.CARD_PASS_KEY_NAME)
	end
end

function ChallengeCardsViewGui:on_mouse_moved(o, x, y)
	return false
end

function ChallengeCardsViewGui:bind_controller_inputs()
	local bindings = {
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_tabs_rarity_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_tabs_rarity_right")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_trigger_left"),
			callback = callback(self, self, "_on_tabs_type_left")
		},
		{
			callback = nil,
			key = nil,
			key = Idstring("menu_controller_trigger_right"),
			callback = callback(self, self, "_on_tabs_type_right")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		keyboard = nil,
		controller = nil,
		controller = {
			"menu_legend_back",
			"menu_legend_challenge_cards_rarity",
			"menu_legend_challenge_cards_type"
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

function ChallengeCardsViewGui:_on_tabs_rarity_left()
	self._rarity_filters_tabs:_move_left()

	return true, nil
end

function ChallengeCardsViewGui:_on_tabs_rarity_right()
	self._rarity_filters_tabs:_move_right()

	return true, nil
end

function ChallengeCardsViewGui:_on_tabs_type_left()
	self._type_filters_tabs:_move_left()

	return true, nil
end

function ChallengeCardsViewGui:_on_tabs_type_right()
	self._type_filters_tabs:_move_right()

	return true, nil
end

function ChallengeCardsViewGui:back_pressed()
	managers.raid_menu:on_escape()
end
