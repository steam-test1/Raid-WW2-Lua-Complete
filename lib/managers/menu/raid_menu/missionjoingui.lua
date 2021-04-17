MissionJoinGui = MissionJoinGui or class(RaidGuiBase)
MissionJoinGui.FILTER_HEIGHT = 20
MissionJoinGui.FILTER_FONT_SIZE = 19
MissionJoinGui.FILTER_BUTTON_W = 20
MissionJoinGui.FILTER_BUTTON_H = 20
MissionJoinGui.SERVER_TABLE_ROW_HEIGHT = 42

function MissionJoinGui:init(ws, fullscreen_ws, node, component_name)
	MissionJoinGui.super.init(self, ws, fullscreen_ws, node, component_name)
end

function MissionJoinGui:_set_initial_data()
	self.filters = {}
	self._tweak_data = tweak_data.gui.server_browser
	self._max_active_server_jobs = self._tweak_data.max_active_server_jobs
	self._active_jobs = {}
	self._active_server_jobs = {}
	self._server_list_rendered = false
	self._filters_active = false
	self._gui_jobs = {}
end

function MissionJoinGui:_layout()
	MissionJoinGui.super._layout(self)

	self._list_panel = self._root_panel:panel({
		name = "list_panel",
		h = 816,
		y = 0,
		w = 1216,
		x = 0
	})
	self._game_description_panel = self._root_panel:panel({
		visible = true,
		name = "list_panel",
		h = 736,
		y = 64,
		w = 480,
		x = 1248
	})
	self._filters_panel = self._root_panel:panel({
		visible = false,
		name = "list_panel",
		h = 736,
		y = 64,
		w = 480,
		x = 1248
	})
	self._footer_buttons_panel = self._root_panel:panel({
		name = "list_panel",
		h = 64,
		y = 832,
		w = 1728,
		x = 0
	})

	self:_layout_filters()
	self:_layout_server_list_table()
	self:_layout_game_description()
	self:_layout_footer_buttons()
	self:_set_additional_layout()
	self:_update_active_controls()
	self._table_servers:set_selected(true)
	self:_render_filters()
	self:_refresh_server_list()
	self:bind_controller_inputs()
end

function MissionJoinGui:_layout_filters()
	local filter_label_width = 256
	local filter_control_width = 192
	local filter_control_width_wide = 250
	local filter_stepper_width = 470
	local row_spacing = 5
	self._friends_only_button = self._filters_panel:toggle_button({
		name = "friends_only_button",
		text = "",
		w = 470,
		no_highlight = true,
		y = 32,
		x = 0,
		h = MissionJoinGui.FILTER_HEIGHT,
		button_w = MissionJoinGui.FILTER_BUTTON_W,
		button_h = MissionJoinGui.FILTER_BUTTON_H,
		font_size = MissionJoinGui.FILTER_FONT_SIZE,
		on_click_callback = callback(self, self, "friends_only_button_on_click"),
		description = utf8.to_upper(managers.localization:text("menu_mission_join_filters_friends_only")),
		description_color = Color.white,
		on_menu_move = {
			down = "in_camp_servers_only",
			up = "mission_filter_stepper"
		}
	})
	self._in_camp_servers_only = self._filters_panel:toggle_button({
		name = "in_camp_servers_only",
		text = "",
		w = 470,
		no_highlight = true,
		x = self._friends_only_button:x(),
		y = self._friends_only_button:y() + 50,
		h = MissionJoinGui.FILTER_HEIGHT,
		button_w = MissionJoinGui.FILTER_BUTTON_W,
		button_h = MissionJoinGui.FILTER_BUTTON_H,
		font_size = MissionJoinGui.FILTER_FONT_SIZE,
		on_click_callback = callback(self, self, "in_camp_servers_only_button_on_click"),
		description = utf8.to_upper(managers.localization:text("menu_mission_join_filters_in_camp_servers_only")),
		description_color = Color.white,
		on_menu_move = {
			down = "distance_filter_stepper",
			up = "friends_only_button"
		}
	})
	self._distance_filter_stepper = self._filters_panel:stepper({
		name = "distance_filter_stepper",
		font_size = MissionJoinGui.FILTER_FONT_SIZE,
		x = self._in_camp_servers_only:x(),
		y = self._in_camp_servers_only:y() + 50,
		w = filter_stepper_width,
		h = MissionJoinGui.FILTER_HEIGHT,
		stepper_w = filter_control_width_wide + 30,
		description = utf8.to_upper(managers.localization:text("menu_mission_join_filters_distance_filter")),
		description_color = Color.white,
		data_source_callback = callback(self, self, "data_source_distance_filter_stepper"),
		color = tweak_data.menu.raid_red,
		highlight_color = Color.white,
		arrow_color = tweak_data.menu.raid_red,
		arrow_highlight_color = Color.white,
		button_w = MissionJoinGui.FILTER_BUTTON_W,
		button_h = MissionJoinGui.FILTER_BUTTON_H,
		on_menu_move = {
			down = "difficulty_filter_stepper",
			up = "in_camp_servers_only"
		}
	})
	self._difficulty_filter_stepper = self._filters_panel:stepper({
		name = "difficulty_filter_stepper",
		font_size = MissionJoinGui.FILTER_FONT_SIZE,
		x = self._distance_filter_stepper:x(),
		y = self._distance_filter_stepper:y() + 50,
		w = filter_stepper_width,
		h = MissionJoinGui.FILTER_HEIGHT,
		stepper_w = filter_control_width_wide + 30,
		description = utf8.to_upper(managers.localization:text("menu_mission_join_filters_difficulty_filter")),
		description_color = Color.white,
		data_source_callback = callback(self, self, "data_source_difficulty_filter_stepper"),
		color = tweak_data.menu.raid_red,
		highlight_color = Color.white,
		arrow_color = tweak_data.menu.raid_red,
		arrow_highlight_color = Color.white,
		button_w = MissionJoinGui.FILTER_BUTTON_W,
		button_h = MissionJoinGui.FILTER_BUTTON_H,
		on_menu_move = {
			down = "mission_filter_stepper",
			up = "distance_filter_stepper"
		}
	})
	self._mission_filter_stepper = self._filters_panel:stepper({
		name = "mission_filter_stepper",
		font_size = MissionJoinGui.FILTER_FONT_SIZE,
		x = self._difficulty_filter_stepper:x(),
		y = self._difficulty_filter_stepper:y() + 50,
		w = filter_stepper_width,
		h = MissionJoinGui.FILTER_HEIGHT,
		stepper_w = filter_control_width_wide + 30,
		description = utf8.to_upper(managers.localization:text("menu_mission_join_filters_mission_filter")),
		description_color = Color.white,
		data_source_callback = callback(self, self, "data_source_mission_filter_stepper"),
		color = tweak_data.menu.raid_red,
		highlight_color = Color.white,
		arrow_color = tweak_data.menu.raid_red,
		arrow_highlight_color = Color.white,
		button_w = MissionJoinGui.FILTER_BUTTON_W,
		button_h = MissionJoinGui.FILTER_BUTTON_H,
		on_menu_move = {
			down = "friends_only_button",
			up = "difficulty_filter_stepper"
		}
	})
end

function MissionJoinGui:_layout_server_list_table()
	self._servers_title_label = self._list_panel:label({
		name = "servers_title_label",
		vertical = "top",
		h = 69,
		w = 320,
		y = 0,
		x = 0,
		text = utf8.to_upper(managers.localization:text("menu_mission_join_server_list_title")),
		color = tweak_data.gui.colors.raid_red,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.title
	})
	local server_list_scrollable_area_params = {
		name = "servers_table_scrollable_area",
		h = 720,
		y = 96,
		w = 1216,
		x = 0,
		scroll_step = 35
	}
	self._server_list_scrollable_area = self._list_panel:scrollable_area(server_list_scrollable_area_params)
	self._params_servers_table = {
		use_row_dividers = true,
		name = "servers_table",
		loop_items = true,
		use_selector_mark = true,
		y = 0,
		x = 0,
		w = self._server_list_scrollable_area:w(),
		scrollable_area_ref = self._server_list_scrollable_area,
		on_selected_callback = callback(self, self, "bind_controller_inputs"),
		table_params = {
			header_params = {
				header_height = 32,
				text_color = tweak_data.gui.colors.raid_white,
				font = tweak_data.gui.fonts.din_compressed,
				font_size = tweak_data.gui.font_sizes.small
			},
			row_params = {
				spacing = 0,
				row_background_color = tweak_data.gui.colors.raid_white:with_alpha(0),
				row_highlight_background_color = tweak_data.gui.colors.raid_white:with_alpha(0.1),
				row_selected_background_color = tweak_data.gui.colors.raid_white:with_alpha(0.1),
				height = MissionJoinGui.SERVER_TABLE_ROW_HEIGHT,
				font = tweak_data.gui.fonts.din_compressed,
				font_size = tweak_data.gui.font_sizes.extra_small,
				color = tweak_data.gui.colors.raid_grey,
				highlight_color = tweak_data.gui.colors.raid_white,
				selected_color = tweak_data.gui.colors.raid_red,
				on_row_select_callback = callback(self, self, "on_row_selected_servers_table"),
				on_row_click_callback = callback(self, self, "on_row_clicked_servers_table"),
				on_row_double_clicked_callback = callback(self, self, "on_row_double_clicked_servers_table")
			},
			data_source_callback = callback(self, self, "data_source_servers_table"),
			columns = {
				{
					vertical = "center",
					w = 480,
					align = "left",
					header_padding = 32,
					padding = 32,
					header_text = self:translate("menu_mission_join_server_list_columns_mission_type", true),
					on_cell_click_callback = callback(self, self, "on_cell_click_servers_table"),
					cell_class = RaidGUIControlTableCell,
					color = tweak_data.gui.colors.raid_grey,
					selected_color = tweak_data.gui.colors.raid_red,
					highlight_color = tweak_data.gui.colors.raid_white
				},
				{
					vertical = "center",
					w = 224,
					align = "left",
					header_padding = 0,
					padding = 0,
					header_text = self:translate("menu_mission_join_server_list_columns_difficulty", true),
					on_cell_click_callback = callback(self, self, "on_cell_click_servers_table"),
					cell_class = RaidGUIControlTableCell,
					color = tweak_data.gui.colors.raid_grey,
					selected_color = tweak_data.gui.colors.raid_red,
					highlight_color = tweak_data.gui.colors.raid_white
				},
				{
					vertical = "center",
					w = 352,
					align = "left",
					header_padding = 0,
					padding = 0,
					header_text = self:translate("menu_mission_join_server_list_columns_host_name", true),
					on_cell_click_callback = callback(self, self, "on_cell_click_servers_table"),
					cell_class = RaidGUIControlTableCell,
					color = tweak_data.gui.colors.raid_grey,
					selected_color = tweak_data.gui.colors.raid_red,
					highlight_color = tweak_data.gui.colors.raid_white
				},
				{
					vertical = "center",
					w = 144,
					align = "left",
					header_padding = 0,
					padding = 0,
					header_text = self:translate("menu_mission_join_server_list_columns_players", true),
					on_cell_click_callback = callback(self, self, "on_cell_click_servers_table"),
					cell_class = RaidGUIControlTableCell,
					color = tweak_data.gui.colors.raid_grey,
					selected_color = tweak_data.gui.colors.raid_red,
					highlight_color = tweak_data.gui.colors.raid_white
				}
			}
		}
	}

	if SystemInfo:platform() == Idstring("XB1") or SystemInfo:platform() == Idstring("X360") then
		self._params_servers_table.on_menu_move = {
			right = "player_description_1"
		}
	end

	self._table_servers = self._server_list_scrollable_area:get_panel():table(self._params_servers_table)

	self._server_list_scrollable_area:setup_scroll_area()
end

function MissionJoinGui:_layout_game_description()
	local desc_mission_icon_name = tweak_data.operations.missions.flakturm.icon_menu
	local desc_mission_icon = {
		texture = tweak_data.gui.icons[desc_mission_icon_name].texture,
		texture_rect = tweak_data.gui.icons[desc_mission_icon_name].texture_rect
	}
	self._desc_mission_icon = self._game_description_panel:bitmap({
		visible = false,
		y = 0,
		x = 0,
		texture = desc_mission_icon.texture,
		texture_rect = desc_mission_icon.texture_rect
	})
	self._desc_mission_name = self._game_description_panel:label({
		y = 0,
		vertical = "center",
		h = 96,
		w = 400,
		align = "left",
		text = "FLAKTURM",
		visible = false,
		x = 80,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.menu_list,
		color = tweak_data.gui.colors.raid_red
	})
	self._desc_mission_name_small = self._game_description_panel:label({
		y = 0,
		vertical = "center",
		h = 32,
		w = 400,
		align = "left",
		text = "FLAKTURM",
		visible = false,
		x = 80,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_red
	})
	local difficulty_params = {
		name = "mission_difficulty",
		amount = tweak_data:number_of_difficulties()
	}
	self._server_difficulty_indicator = RaidGuiControlDifficultyStars:new(self._game_description_panel, difficulty_params)

	self._server_difficulty_indicator:set_x(80)

	self._desc_xp_amount = self._game_description_panel:label({
		y = 96,
		vertical = "center",
		h = 32,
		w = 240,
		align = "right",
		text = "1000 XP",
		visible = false,
		x = 240,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_grey
	})
	self._player_info_panel = self._game_description_panel:panel({
		name = "player_info_panel",
		h = 288,
		y = 160,
		w = 480,
		x = 0
	})
	self._player_controls = {}

	for counter = 1, 3 do
		local player_description_params = {
			h = 96,
			w = 480,
			x = 0,
			name = "player_description_" .. tostring(counter),
			y = (counter - 1) * 96
		}

		if SystemInfo:platform() == Idstring("XB1") or SystemInfo:platform() == Idstring("X360") then
			player_description_params.on_menu_move = {
				left = "servers_table",
				up = "player_description_" .. tostring(counter > 1 and counter - 1 or 3),
				down = "player_description_" .. tostring(counter % 3 + 1)
			}
			player_description_params.on_selected_callback = callback(self, self, "bind_controller_inputs_player_description")
		end

		local player_control = self._player_info_panel:create_custom_control(RaidGUIControlServerPlayerDescription, player_description_params)

		player_control:set_data(nil)
		table.insert(self._player_controls, player_control)
	end

	self._desc_challenge_card_panel = self._game_description_panel:panel({
		visible = false,
		h = 224,
		y = 512,
		w = 480,
		x = 0
	})
	self.desc_challenge_card_icon = self._desc_challenge_card_panel:bitmap({
		h = 138,
		y = 64,
		w = 96,
		x = 0,
		texture = tweak_data.challenge_cards.rarity_definition.loot_rarity_common.texture_path,
		texture_rect = tweak_data.challenge_cards.rarity_definition.loot_rarity_common.texture_rect
	})
	self._desc_challenge_card_name = self._desc_challenge_card_panel:label({
		vertical = "center",
		h = 64,
		w = 384,
		align = "left",
		text = "SWITCH HITLER",
		y = 0,
		x = 0,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	local desc_challenge_card_rarity_icon = tweak_data.gui.icons.loot_rarity_uncommon
	self._desc_challenge_card_rarity_icon = self._desc_challenge_card_panel:bitmap({
		h = 32,
		y = 16,
		w = 32,
		x = 384,
		texture = desc_challenge_card_rarity_icon.texture,
		texture_rect = desc_challenge_card_rarity_icon.texture_rect
	})
	self._desc_challenge_card_xp = self._desc_challenge_card_panel:label({
		vertical = "center",
		h = 64,
		w = 64,
		align = "right",
		text = "X1.5",
		y = 0,
		x = 416,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._desc_challenge_card_name_on_card = self._desc_challenge_card_panel:label({
		vertical = "center",
		wrap = true,
		align = "center",
		text = "SWITCH HITLER",
		w = self.desc_challenge_card_icon:w() * (1 - 2 * RaidGUIControlCardBase.TITLE_PADDING),
		h = self.desc_challenge_card_icon:h() * RaidGUIControlCardBase.TITLE_H,
		x = self.desc_challenge_card_icon:x() + self.desc_challenge_card_icon:w() * RaidGUIControlCardBase.TITLE_PADDING,
		y = self.desc_challenge_card_icon:y() + self.desc_challenge_card_icon:h() * RaidGUIControlCardBase.TITLE_Y,
		font = RaidGUIControlCardBase.TITLE_FONT,
		font_size = math.ceil(RaidGUIControlCardBase.TITLE_TEXT_SIZE * self.desc_challenge_card_icon:h() / 255),
		color = tweak_data.gui.colors.raid_dirty_white
	})
	local desc_challenge_card_rarity_icon = tweak_data.gui.icons.loot_rarity_uncommon
	local card_rarity_icon_texture = desc_challenge_card_rarity_icon.texture
	local card_rarity_icon_texture_rect = desc_challenge_card_rarity_icon.texture_rect
	local card_rarity_h = self.desc_challenge_card_icon:h() * RaidGUIControlCardBase.ICON_H
	local card_rarity_w = card_rarity_h * card_rarity_icon_texture_rect[3] / card_rarity_icon_texture_rect[4]
	self._desc_challenge_card_rarity_icon_on_card = self._desc_challenge_card_panel:bitmap({
		w = card_rarity_w,
		h = card_rarity_h,
		x = self.desc_challenge_card_icon:w() - card_rarity_w - self.desc_challenge_card_icon:w() * RaidGUIControlCardBase.ICON_LEFT_PADDING,
		y = self.desc_challenge_card_icon:y() + self.desc_challenge_card_icon:h() * RaidGUIControlCardBase.ICON_TOP_PADDING,
		texture = desc_challenge_card_rarity_icon.texture,
		texture_rect = desc_challenge_card_rarity_icon.texture_rect
	})
	local card_type = tweak_data.gui.icons.ico_raid
	local card_type_h = card_rarity_h
	local card_type_w = card_type_h * card_type.texture_rect[3] / card_type.texture_rect[4]
	local params_card_type = {
		name = "card_type_icon",
		w = card_type_w,
		h = card_type_h,
		x = self.desc_challenge_card_icon:w() * RaidGUIControlCardBase.ICON_LEFT_PADDING,
		y = self.desc_challenge_card_icon:y() + self.desc_challenge_card_icon:h() * RaidGUIControlCardBase.ICON_TOP_PADDING,
		texture = card_type.texture,
		texture_rect = card_type.texture_rect,
		layer = self.desc_challenge_card_icon:layer() + 1
	}
	self._desc_challenge_card_type_icon_on_card = self._desc_challenge_card_panel:image(params_card_type)
	self._desc_challenge_card_xp_on_card = self._desc_challenge_card_panel:label({
		vertical = "center",
		align = "center",
		text = "X1.5",
		x = 0,
		y = self.desc_challenge_card_icon:y() + self.desc_challenge_card_icon:h() * RaidGUIControlCardBase.XP_BONUS_Y,
		w = self.desc_challenge_card_icon:w() * RaidGUIControlCardBase.XP_BONUS_W,
		h = self.desc_challenge_card_icon:h() * RaidGUIControlCardBase.XP_BONUS_H,
		font = RaidGUIControlCardBase.XP_BONUS_FONT,
		font_size = math.ceil(RaidGUIControlCardBase.XP_BONUS_FONT_SIZE * self.desc_challenge_card_icon:w() * 0.002),
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._desc_challenge_card_bonus = self._desc_challenge_card_panel:label({
		vertical = "top",
		h = 64,
		wrap = true,
		w = 352,
		align = "left",
		text = "+ shooting your secondary weapon fills up your primary ammo",
		y = 64,
		x = 128,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_18,
		color = tweak_data.gui.colors.raid_grey_effects
	})
	self._desc_challenge_card_malus = self._desc_challenge_card_panel:label({
		vertical = "top",
		h = 64,
		wrap = true,
		w = 352,
		align = "left",
		text = "- shooting your primary weapon consumes both primary and secondary ammo",
		y = 128,
		x = 128,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_18,
		color = tweak_data.gui.colors.raid_grey_effects
	})
end

function MissionJoinGui:_layout_footer_buttons()
	self._join_button = self._footer_buttons_panel:short_primary_button({
		name = "join_button",
		visible = true,
		y = 0,
		x = 0,
		on_click_callback = callback(self, self, "on_click_join_button"),
		text = self:translate("menu_mission_join_join", true),
		on_menu_move = {
			left = "friends_only_button",
			up = "servers_table"
		}
	})
	self._apply_filters_button = self._footer_buttons_panel:short_tertiary_button({
		w = 128,
		name = "apply_filters_button",
		h = 28,
		align = "center",
		vertical = "center",
		y = 0,
		visible = true,
		x = 1280,
		on_click_callback = callback(self, self, "on_click_apply_filters_button"),
		text = self:translate("menu_mission_join_filters_apply", true),
		color = Color.black,
		highlight_color = Color.white,
		texture_color = tweak_data.menu.raid_red,
		texture_highlight_color = tweak_data.menu.raid_red
	})
	self._show_filters_button = self._footer_buttons_panel:short_secondary_button({
		w = 128,
		name = "show_filters_button",
		h = 28,
		align = "center",
		vertical = "center",
		y = 0,
		visible = true,
		x = 1536,
		on_click_callback = callback(self, self, "on_click_show_filters_button"),
		text = self:translate("menu_mission_join_filters_show", true),
		color = Color.black,
		highlight_color = Color.white,
		texture_color = tweak_data.menu.raid_red,
		texture_highlight_color = tweak_data.menu.raid_red
	})
	self._online_users_count = self._footer_buttons_panel:label({
		name = "online_users_count",
		vertical = "center",
		h = 64,
		w = 320,
		align = "left",
		text = "",
		y = 0,
		x = 960,
		color = tweak_data.gui.colors.raid_white,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.large
	})
end

function MissionJoinGui:_set_additional_layout()
	self._join_button:set_center_y(self._footer_buttons_panel:h() / 2)
	self._apply_filters_button:set_center_y(self._footer_buttons_panel:h() / 2)
	self._show_filters_button:set_center_y(self._footer_buttons_panel:h() / 2)
	self._desc_mission_icon:set_center_y(58)
	self._desc_mission_name_small:set_center_y(self._desc_mission_icon:center_y() - 14)
	self._server_difficulty_indicator:set_center_y(self._desc_mission_icon:center_y() + 14)
	self._desc_xp_amount:set_center_y(self._server_difficulty_indicator:center_y())
end

function MissionJoinGui:close()
	MissionJoinGui.super.close(self)
	self:_remove_active_controls()
end

function MissionJoinGui:update(t, dt)
end

function MissionJoinGui:friends_only_button_on_click()
	local friends_only = self._friends_only_button:get_value()

	managers.network.matchmake:set_search_friends_only(friends_only)
end

function MissionJoinGui:in_camp_servers_only_button_on_click()
	local state = self._in_camp_servers_only:get_value() and 1 or -1

	managers.network.matchmake:add_lobby_filter("state", state, "equal")
end

function MissionJoinGui:on_row_clicked_servers_table(row_data, row_index)
	self:_select_server_list_item(row_data[5].value)
end

function MissionJoinGui:on_row_double_clicked_servers_table(row_data, row_index)
	Application:trace("[MissionJoinGui:on_row_double_clicked_servers_table]", inspect(row_data), row_index)
	self:_select_server_list_item(row_data[5].value)
	self:_join_game()
end

function MissionJoinGui:on_row_selected_servers_table(row_data, row_index)
	self:_select_server_list_item(row_data[5].value)
end

function MissionJoinGui:on_cell_click_servers_table(data)
	self:_select_server_list_item(self._selected_row_data[5].value)
end

function MissionJoinGui:data_source_servers_table()
	local missions = {}

	if not self._gui_jobs then
		self._gui_jobs = {}
	end

	local mission_data = nil

	for key, value in pairs(self._gui_jobs) do
		if utf8.to_lower(value.level_id) == OperationsTweakData.IN_LOBBY then
			mission_data = {
				text = self:translate(tweak_data.operations.missions.camp.name_id, true),
				value = value.room_id,
				info = value.level_name
			}
		elseif utf8.to_upper(value.job_name) == RaidJobManager.SINGLE_MISSION_TYPE_NAME then
			mission_data = {
				text = utf8.to_upper(value.level_name),
				value = value.room_id,
				info = value.level_name
			}
		else
			mission_data = {
				text = utf8.to_upper(value.job_name .. " " .. value.progress .. ": " .. value.level_name),
				value = value.room_id,
				info = value.level_name
			}
		end

		table.insert(missions, {
			mission_data,
			{
				text = utf8.to_upper(value.difficulty),
				value = value.room_id,
				info = value.difficulty
			},
			{
				text = utf8.to_upper(value.host_name),
				value = value.room_id,
				info = value.host_name
			},
			{
				text = value.num_plrs .. "",
				value = value.room_id,
				info = value.num_plrs .. ""
			},
			{
				value = value
			}
		})
	end

	return missions
end

function MissionJoinGui:_update_active_controls()
	local active_controls = managers.menu_component._active_controls

	if self._table_servers then
		active_controls[self._table_servers._name] = {
			[self._table_servers._name] = self._table_servers
		}
	end
end

function MissionJoinGui:_remove_active_controls()
	local active_controls = managers.menu_component._active_controls

	if self._table_servers then
		active_controls[self._table_servers._name] = {}
	end
end

function MissionJoinGui:data_source_distance_filter_stepper()
	local result = {}

	table.insert(result, {
		value = 0,
		info = "Close",
		text = utf8.to_upper(managers.localization:text("menu_dist_filter_close"))
	})
	table.insert(result, {
		value = 2,
		info = "Far",
		text = utf8.to_upper(managers.localization:text("menu_dist_filter_far"))
	})
	table.insert(result, {
		value = 3,
		info = "Worldwide",
		text = utf8.to_upper(managers.localization:text("menu_dist_filter_worldwide"))
	})

	return result
end

function MissionJoinGui:data_source_difficulty_filter_stepper()
	local result = {}

	if tweak_data.difficulties then
		table.insert(result, {
			value = 0,
			info = "Any",
			text = utf8.to_upper(managers.localization:text("menu_any"))
		})

		for diff_index, diff_name in pairs(tweak_data.difficulties) do
			table.insert(result, {
				text = self:translate("menu_" .. diff_name),
				value = diff_index,
				info = diff_name
			})
		end
	end

	return result
end

function MissionJoinGui:data_source_mission_filter_stepper()
	local result = {}

	table.insert(result, {
		value = -1,
		info = "Any",
		text = utf8.to_upper(managers.localization:text("menu_any"))
	})

	for _, mission_name_id in pairs(tweak_data.operations:get_raids_index()) do
		local mission_data = tweak_data.operations:mission_data(mission_name_id)
		local mission_name = self:translate(mission_data.name_id, true)

		table.insert(result, {
			text = mission_name,
			value = mission_name_id
		})
	end

	for _, mission_name_id in pairs(tweak_data.operations:get_operations_index()) do
		local mission_data = tweak_data.operations:mission_data(mission_name_id)
		local mission_name = self:translate(mission_data.name_id, true)

		table.insert(result, {
			text = mission_name,
			value = mission_name_id
		})
	end

	return result
end

function MissionJoinGui:on_click_apply_filters_button()
	self:_refresh_server_list()
end

function MissionJoinGui:on_click_show_filters_button()
	self._filters_panel:set_visible(not self._filters_panel:visible())

	if self._selected_row_data then
		self._game_description_panel:set_visible(not self._filters_panel:visible())
	end
end

function MissionJoinGui:on_click_join_button()
	Application:trace("[MissionJoinGui:on_click_join_button]")
	self:_join_game()
end

function MissionJoinGui:_refresh_server_list()
	self._apply_filters_button:hide()

	local maximum_servers = managers.network.matchmake:get_lobby_return_count()
	local distance_filter = self._distance_filter_stepper:get_value()
	local difficulty_filter = self._difficulty_filter_stepper:get_value()
	local mission_filter = self._mission_filter_stepper:get_value()
	local state = self._in_camp_servers_only:get_value() and 1 or -1

	managers.network.matchmake:set_lobby_return_count(maximum_servers)
	managers.network.matchmake:set_distance_filter(distance_filter)
	managers.network.matchmake:set_difficulty_filter(difficulty_filter)
	managers.network.matchmake:add_lobby_filter("job_id", mission_filter, "equal")
	managers.network.matchmake:add_lobby_filter("state", state, "equal")

	self._selected_row_data = nil

	self:_find_online_games(managers.network.matchmake:search_friends_only())
end

function MissionJoinGui:_select_server_list_item(data_value)
	self:_select_game_from_list()
	self:_set_game_description_data(data_value)
end

function MissionJoinGui:_render_filters()
	self._friends_only_button:set_value_and_render(managers.network.matchmake:search_friends_only())
	self._in_camp_servers_only:set_value_and_render(managers.network.matchmake:get_lobby_filter("state") == 1)
	self._distance_filter_stepper:select_item_by_value(managers.network.matchmake:distance_filter())
	self._difficulty_filter_stepper:select_item_by_value(managers.network.matchmake:difficulty_filter())
	self._mission_filter_stepper:select_item_by_value(managers.network.matchmake:get_lobby_filter("job_id"))
end

function MissionJoinGui:_join_game()
	local selected_row = self._table_servers:get_selected_row()

	if not selected_row or not selected_row:get_data() then
		return
	end

	local data = selected_row:get_data()
	local steam_player_id = data[4].value

	managers.network.matchmake:join_server_with_check(steam_player_id)
end

function MissionJoinGui:_select_game_from_list()
	local selected_row = self._table_servers:get_selected_row()

	if not selected_row then
		return
	end

	self._selected_row_data = selected_row:get_data()
end

function MissionJoinGui:_set_game_description_data(data)
	local in_camp = data.level_id == "camp"

	if data.level_id == OperationsTweakData.IN_LOBBY then
		data.level_id = "camp"
		in_camp = true
	end

	if data.job_id and data.level_id then
		local desc_mission_icon_name = nil

		if data.mission_type == tostring(OperationsTweakData.JOB_TYPE_RAID) or in_camp then
			desc_mission_icon_name = tweak_data.operations.missions[data.level_id] and tweak_data.operations.missions[data.level_id].icon_menu
		elseif data.mission_type == tostring(OperationsTweakData.JOB_TYPE_OPERATION) then
			desc_mission_icon_name = tweak_data.operations.missions[data.job_id] and tweak_data.operations.missions[data.job_id].icon_menu
		end

		if desc_mission_icon_name then
			local desc_mission_icon = {
				texture = tweak_data.gui.icons[desc_mission_icon_name].texture,
				texture_rect = tweak_data.gui.icons[desc_mission_icon_name].texture_rect
			}

			self._desc_mission_icon:set_image(desc_mission_icon.texture, unpack(desc_mission_icon.texture_rect))
			self._desc_mission_icon:set_w(desc_mission_icon.texture_rect[3])
			self._desc_mission_icon:set_h(desc_mission_icon.texture_rect[4])
			self._desc_mission_icon:show()
		else
			self._desc_mission_icon:hide()
		end
	else
		self._desc_mission_icon:hide()
	end

	if data.job_id and data.level_id then
		if in_camp then
			self._desc_mission_name:set_text(self:translate(tweak_data.operations.missions[data.level_id].name_id, true))
			self._desc_mission_name:show()
			self._desc_mission_name_small:hide()
			self._server_difficulty_indicator:hide()
		else
			local level_name = ""

			if data.mission_type == tostring(OperationsTweakData.JOB_TYPE_RAID) then
				level_name = tweak_data.operations.missions[data.level_id] and self:translate(tweak_data.operations.missions[data.level_id].name_id, true)
			elseif data.mission_type == tostring(OperationsTweakData.JOB_TYPE_OPERATION) then
				level_name = self:translate(tweak_data.operations.missions[data.job_id].name_id, true) .. " " .. data.progress .. ": " .. self:translate(tweak_data.operations.missions[data.job_id].events[data.level_id].name_id, true)
			end

			self._desc_mission_name_small:set_text(level_name)
			self._server_difficulty_indicator:set_active_difficulty(data.difficulty_id)
			self._desc_mission_name_small:show()
			self._server_difficulty_indicator:show()
			self._desc_mission_name:hide()
		end
	else
		self._desc_mission_name:hide()
	end

	local level_xp_amount = 0

	if tostring(data.mission_type) == tostring(OperationsTweakData.JOB_TYPE_RAID) then
		if data.level_id then
			level_xp_amount = tweak_data.operations.missions[data.level_id] and tweak_data.operations.missions[data.level_id].xp
		else
			level_xp_amount = 0
		end
	elseif tostring(data.mission_type) == tostring(OperationsTweakData.JOB_TYPE_OPERATION) then
		level_xp_amount = tweak_data.operations.missions[data.job_id].xp
	elseif tostring(data.mission_type) == OperationsTweakData.IN_LOBBY then
		-- Nothing
	end

	if level_xp_amount and level_xp_amount > 0 then
		self._desc_xp_amount:set_text(level_xp_amount .. " XP")
		self._desc_xp_amount:show()
	else
		self._desc_xp_amount:hide()
	end

	if self._player_controls then
		for _, player_description_control in pairs(self._player_controls) do
			player_description_control:hide()
		end
	end

	local control_counter = 1

	for peer_counter = 1, 4 do
		local control_data = data["players_info_" .. peer_counter]

		if control_data ~= NetworkMatchMakingSTEAM.EMPTY_PLAYER_INFO then
			if not self._player_controls[control_counter] then
				break
			end

			if control_data ~= "value_pending" then
				self._player_controls[control_counter]:set_data(control_data)
				self._player_controls[control_counter]:set_host(peer_counter == 1)

				control_counter = control_counter + 1
			end
		end
	end

	if SystemInfo:platform() == Idstring("XB1") or SystemInfo:platform() == Idstring("X360") then
		for i = 1, control_counter do
			local on_menu_move = {
				left = "servers_table",
				up = "player_description_" .. tostring(i > 1 and i - 1 or control_counter),
				down = "player_description_" .. tostring(i % control_counter + 1)
			}

			self._player_controls[i]:set_menu_move_controls(on_menu_move)
		end
	end

	local card_key_name = data.challenge_card
	local card_data = nil

	if card_key_name ~= "empty" then
		card_data = tweak_data.challenge_cards.cards[card_key_name]
	end

	if card_data then
		self._desc_challenge_card_panel:show()
		self.desc_challenge_card_icon:set_image(tweak_data.challenge_cards.challenge_card_texture_path .. card_data.texture, unpack(tweak_data.challenge_cards.challenge_card_texture_rect))
		self.desc_challenge_card_icon:show()
		self._desc_challenge_card_name:set_text(self:translate(card_data.name, true))

		local bonus_xp_reward = managers.challenge_cards:get_card_xp_label(card_key_name)

		self._desc_challenge_card_xp:set_text(bonus_xp_reward)

		local x1, y1, w1, h1 = self._desc_challenge_card_xp:text_rect()

		self._desc_challenge_card_xp:set_w(w1)
		self._desc_challenge_card_xp:set_right(self._game_description_panel:w())

		local desc_challenge_card_rarity_icon = tweak_data.gui.icons[card_data.rarity]

		self._desc_challenge_card_rarity_icon:set_image(desc_challenge_card_rarity_icon.texture, unpack(desc_challenge_card_rarity_icon.texture_rect))
		self._desc_challenge_card_rarity_icon:set_right(self._desc_challenge_card_xp:x() - 12)
		self._desc_challenge_card_rarity_icon:show()

		if not card_data.title_in_texture then
			self._desc_challenge_card_name_on_card:set_text(self:translate(card_data.name, true))
		else
			self._desc_challenge_card_name_on_card:set_text("")
		end

		local bonus_xp_reward = managers.challenge_cards:get_card_xp_label(card_key_name)

		self._desc_challenge_card_xp_on_card:set_text(bonus_xp_reward)

		local x1, y1, w1, h1 = self._desc_challenge_card_xp_on_card:text_rect()

		self._desc_challenge_card_xp_on_card:set_w(w1)
		self._desc_challenge_card_xp_on_card:set_h(h1)
		self._desc_challenge_card_xp_on_card:set_center_x(self.desc_challenge_card_icon:w() / 2)
		self._desc_challenge_card_rarity_icon_on_card:set_image(desc_challenge_card_rarity_icon.texture, unpack(desc_challenge_card_rarity_icon.texture_rect))

		local type_definition = tweak_data.challenge_cards.type_definition[card_data.card_type]

		self._desc_challenge_card_type_icon_on_card:set_image(type_definition.texture_path)
		self._desc_challenge_card_type_icon_on_card:set_texture_rect(type_definition.texture_rect)

		local bonus_description, malus_description = managers.challenge_cards:get_card_description(card_key_name)
		local card_effect_y = 64

		if bonus_description and bonus_description ~= "" then
			self._desc_challenge_card_bonus:set_text("+ " .. bonus_description)

			local _, _, _, h = self._desc_challenge_card_bonus:text_rect()

			self._desc_challenge_card_bonus:set_h(h)

			card_effect_y = card_effect_y + h
		else
			self._desc_challenge_card_bonus:set_text("")
		end

		if malus_description and malus_description ~= "" then
			self._desc_challenge_card_malus:set_text("- " .. malus_description)

			local _, _, _, h = self._desc_challenge_card_malus:text_rect()

			self._desc_challenge_card_malus:set_h(h)
			self._desc_challenge_card_malus:set_y(card_effect_y)
		else
			self._desc_challenge_card_malus:set_text("")
		end
	else
		self._desc_challenge_card_panel:hide()
		self._desc_challenge_card_name:set_text("")
		self._desc_challenge_card_rarity_icon:hide()
		self._desc_challenge_card_xp:set_text("")
		self.desc_challenge_card_icon:hide()
		self._desc_challenge_card_bonus:set_text("")
		self._desc_challenge_card_malus:set_text("")
	end
end

local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local is_ps3 = SystemInfo:platform() == Idstring("PS3")
local is_x360 = SystemInfo:platform() == Idstring("X360")
local is_xb1 = SystemInfo:platform() == Idstring("XB1")
local is_ps4 = SystemInfo:platform() == Idstring("PS4")

function MissionJoinGui:_find_online_games(friends_only)
	if is_win32 then
		self:_find_online_games_win32(friends_only)
	elseif is_ps3 then
		self:_find_online_games_ps3(friends_only)
	elseif is_ps4 then
		self:_find_online_games_ps4(friends_only)
	elseif is_x360 then
		self:_find_online_games_xbox360(friends_only)
	elseif is_xb1 then
		self:_find_online_games_xb1(friends_only)
	else
		Application:error("[MissionJoinGui] Unknown gaming platform trying to find online games!")
	end
end

function MissionJoinGui:_find_online_games_win32(friends_only)
	local function f(info)
		managers.network.matchmake:search_lobby_done()

		local room_list = info.room_list
		local attribute_list = info.attribute_list
		local dead_list = {}

		for id, _ in pairs(self._active_server_jobs) do
			dead_list[id] = true
		end

		for i, room in ipairs(room_list) do
			local name_str = tostring(room.owner_name)
			local attributes_numbers = attribute_list[i].numbers

			if managers.network.matchmake:is_server_ok(friends_only, room.owner_id, attributes_numbers) then
				dead_list[room.room_id] = nil
				local host_name = name_str
				local level_id = attributes_numbers[1]
				local name_id = ""
				local level_name = ""
				local difficulty_id = attributes_numbers[2]
				local difficulty = self:translate(tweak_data:get_difficulty_string_name_from_index(difficulty_id), true)
				local job_id = attributes_numbers[14]
				local job_name = ""
				local kick_option = attributes_numbers[8]
				local job_plan = attributes_numbers[10]
				local state_string_id = tweak_data:index_to_server_state(attributes_numbers[4])
				local state_name = state_string_id and managers.localization:text("menu_lobby_server_state_" .. state_string_id) or "UNKNOWN"
				local state = attributes_numbers[4]
				local num_plrs = attributes_numbers[5]
				local challenge_card = attributes_numbers[12]
				local players_info = attributes_numbers[13]
				local progress = attributes_numbers[15]
				local mission_type = attributes_numbers[16]
				local players_info_1 = attributes_numbers[17]
				local players_info_2 = attributes_numbers[18]
				local players_info_3 = attributes_numbers[19]
				local players_info_4 = attributes_numbers[20]

				if challenge_card == "nocards" or challenge_card == "" or challenge_card == "value_pending" then
					challenge_card = ""
				end

				if players_info == "value_pending" then
					players_info = ""
				end

				if progress == "value_pending" then
					progress = ""
				end

				if mission_type == "value_pending" then
					mission_type = ""
				end

				if level_id == OperationsTweakData.IN_LOBBY then
					level_name = self:translate("menu_mission_select_in_lobby")
					job_name = self:translate("menu_mission_select_in_lobby")
				elseif tonumber(mission_type) == OperationsTweakData.JOB_TYPE_OPERATION then
					level_name = ""
					job_name = ""
					local operation_data = tweak_data.operations.missions[job_id]

					if operation_data and operation_data.events and operation_data.events[level_id] then
						level_name = self:translate(tweak_data.operations.missions[job_id].events[level_id].name_id)
						job_name = self:translate(tweak_data.operations.missions[job_id].name_id)
					else
						level_name = "N/A"
						job_name = "N/A"

						Application:error("Level '" .. level_id .. "' can't be found in operation '" .. job_id .. "'.")
					end
				elseif tonumber(mission_type) == OperationsTweakData.JOB_TYPE_RAID then
					local mission_data = tweak_data.operations.missions[level_id]
					level_name = ""

					if mission_data and mission_data.name_id then
						level_name = self:translate(tweak_data.operations.missions[level_id].name_id)
					end

					job_name = self:translate("menu_mission_selected_mission_type_raid")
				end

				local is_friend = false

				if Steam:logged_on() and Steam:friends() then
					for _, friend in ipairs(Steam:friends()) do
						if friend:id() == room.owner_id then
							is_friend = true

							break
						end
					end
				end

				name_id = name_id or "unknown"

				if name_id then
					if not self._active_server_jobs[room.room_id] then
						if table.size(self._active_jobs) + table.size(self._active_server_jobs) < self._tweak_data.total_active_jobs and table.size(self._active_server_jobs) < self._max_active_server_jobs then
							self._active_server_jobs[room.room_id] = {
								added = false,
								alive_time = 0
							}

							self:add_gui_job({
								room_id = room.room_id,
								id = room.room_id,
								level_id = level_id,
								difficulty = difficulty,
								difficulty_id = difficulty_id,
								num_plrs = num_plrs,
								host_name = host_name,
								state_name = state_name,
								state = state,
								level_name = level_name,
								job_id = job_id,
								is_friend = is_friend,
								kick_option = kick_option,
								job_plan = job_plan,
								custom_text = room.custom_text,
								challenge_card = challenge_card,
								players_info = players_info,
								progress = progress,
								mission_type = mission_type,
								job_name = job_name,
								players_info_1 = players_info_1,
								players_info_2 = players_info_2,
								players_info_3 = players_info_3,
								players_info_4 = players_info_4
							})
						end
					else
						self:update_gui_job({
							room_id = room.room_id,
							id = room.room_id,
							level_id = level_id,
							difficulty = difficulty,
							difficulty_id = difficulty_id,
							num_plrs = num_plrs,
							host_name = host_name,
							state_name = state_name,
							state = state,
							level_name = level_name,
							job_id = job_id,
							is_friend = is_friend,
							kick_option = kick_option,
							job_plan = job_plan,
							custom_text = room.custom_text,
							challenge_card = challenge_card,
							players_info = players_info,
							progress = progress,
							mission_type = mission_type,
							job_name = job_name,
							players_info_1 = players_info_1,
							players_info_2 = players_info_2,
							players_info_3 = players_info_3,
							players_info_4 = players_info_4
						})
					end
				end
			end
		end

		for id, _ in pairs(dead_list) do
			self._active_server_jobs[id] = nil

			self:remove_gui_job(id)
		end

		if self._table_servers and self._table_servers:is_alive() then
			self._table_servers:refresh_data()
			self._server_list_scrollable_area:setup_scroll_area()
			self._table_servers:select_table_row_by_row_idx(1)
			self:_select_game_from_list()

			if self._selected_row_data then
				self:_set_game_description_data(self._selected_row_data[5].value)
				self._game_description_panel:show()
				self._filters_panel:hide()
				self:_filters_set_selected_server_table()
			else
				self._game_description_panel:hide()
				self._filters_panel:show()
				self:_filters_set_selected_filters()
			end
		end

		self._apply_filters_button:show()
	end

	managers.network.matchmake:register_callback("search_lobby", f)
	managers.network.matchmake:search_lobby(friends_only)

	local function usrs_f(success, amount)
		print("usrs_f", success, amount)

		if success then
			self:set_players_online(amount)
		end
	end

	Steam:sa_handler():concurrent_users_callback(usrs_f)
	Steam:sa_handler():get_concurrent_users()
end

function MissionJoinGui:add_gui_job(data)
	self._gui_jobs[data.id] = data
end

function MissionJoinGui:update_gui_job(data)
	self._gui_jobs[data.id] = data
end

function MissionJoinGui:remove_gui_job(id)
	self._gui_jobs[id] = nil
end

function MissionJoinGui:set_players_online(amount)
	if self._online_users_count and self._online_users_count:is_alive() then
		self._online_users_count:set_text(self:translate("menu_mission_join_users_online_count", true) .. " " .. amount)
	end
end

function MissionJoinGui:_filters_set_selected_server_table()
	self._filters_active = false

	self._friends_only_button:set_selected(false)
	self._in_camp_servers_only:set_selected(false)
	self._distance_filter_stepper:set_selected(false)
	self._difficulty_filter_stepper:set_selected(false)
	self._mission_filter_stepper:set_selected(false)

	for i = 1, #self._player_controls do
		self._player_controls[i]:set_selected(false)
	end

	self._table_servers:set_selected(true)
end

function MissionJoinGui:_filters_set_selected_filters()
	self._filters_active = true

	self._friends_only_button:set_selected(true)
	self._in_camp_servers_only:set_selected(false)
	self._distance_filter_stepper:set_selected(false)
	self._difficulty_filter_stepper:set_selected(false)
	self._mission_filter_stepper:set_selected(false)

	for i = 1, #self._player_controls do
		self._player_controls[i]:set_selected(false)
	end

	self._table_servers:set_selected(false)
end

function MissionJoinGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_refresh")
		},
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_filter")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_mission_join_refresh",
			"menu_legend_mission_join_filter",
			"menu_legend_mission_join_join"
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

function MissionJoinGui:bind_controller_inputs_no_join()
	local bindings = {
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_refresh")
		},
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_filter")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_mission_join_refresh",
			"menu_legend_mission_join_filter"
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

function MissionJoinGui:bind_controller_inputs_player_description()
	local bindings = {
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_refresh")
		},
		{
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_filter")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_mission_join_refresh",
			"menu_legend_mission_join_filter",
			{
				translated_text = managers.localization:get_default_macros().BTN_A .. " " .. self:translate("menu_gamercard_widget_label", true)
			}
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

function MissionJoinGui:_on_refresh()
	self:on_click_apply_filters_button()
	self:bind_controller_inputs()

	return true, nil
end

function MissionJoinGui:_on_filter()
	local server_table_selected = self._table_servers:is_selected()
	local have_any_servers = false

	for index, job_data in pairs(self._gui_jobs) do
		have_any_servers = true

		break
	end

	if not self._filters_active or not have_any_servers then
		self:_filters_set_selected_filters()
		self:bind_controller_inputs_no_join()
	else
		self:_filters_set_selected_server_table()
		self:bind_controller_inputs()
	end

	self:on_click_show_filters_button()

	return true, nil
end

function MissionJoinGui:confirm_pressed()
	Application:trace("[MissionJoinGui:confirm_pressed]")

	local server_table_selected = self._table_servers:is_selected()

	if server_table_selected then
		self:on_click_join_button()
	else
		MissionJoinGui.super.confirm_pressed(self)
	end
end

function MissionJoinGui:back_pressed()
	Application:trace("[MissionJoinGui:back_pressed]")
	managers.raid_menu:on_escape()
end
