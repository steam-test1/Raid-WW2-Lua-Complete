PostGameBreakdownGui = PostGameBreakdownGui or class(RaidGuiBase)
PostGameBreakdownGui.XP_BREAKDOWN_X = 2
PostGameBreakdownGui.XP_BREAKDOWN_Y = 126
PostGameBreakdownGui.TOP_STATS_SMALL_Y = 448
PostGameBreakdownGui.TOP_STATS_SMALL_W = 320
PostGameBreakdownGui.TOP_STATS_SMALL_H = 224
PostGameBreakdownGui.PROGRESS_BAR_Y = 719
PostGameBreakdownGui.XP_BREAKDOWN_WIDTH = 284
PostGameBreakdownGui.XP_BREAKDOWN_HEIGHT = 270
PostGameBreakdownGui.STATS_BREAKDOWN_WIDTH = 284
PostGameBreakdownGui.STATS_BREAKDOWN_HEIGHT = 250
PostGameBreakdownGui.STATS_BREAKDOWN_Y = 126
PostGameBreakdownGui.NEW_LEVEL_LABEL_Y = 533
PostGameBreakdownGui.NEW_LEVEL_LABEL_W = 640
PostGameBreakdownGui.NEW_LEVEL_LABEL_H = 50
PostGameBreakdownGui.NEW_LEVEL_LABEL_FONT_SIZE = tweak_data.gui.font_sizes.size_46
PostGameBreakdownGui.NEW_LEVEL_LABEL_COLOR = tweak_data.gui.colors.raid_red
PostGameBreakdownGui.NEW_WEAPON_LABEL_Y = 597
PostGameBreakdownGui.NEW_WEAPON_LABEL_W = 640
PostGameBreakdownGui.NEW_WEAPON_LABEL_H = 50
PostGameBreakdownGui.NEW_WEAPON_LABEL_FONT_SIZE = tweak_data.gui.font_sizes.size_46
PostGameBreakdownGui.NEW_WEAPON_LABEL_COLOR = tweak_data.gui.colors.raid_red
PostGameBreakdownGui.TOTAL_XP_Y = 549
PostGameBreakdownGui.TOTAL_XP_H = 128
PostGameBreakdownGui.TOTAL_XP_LABEL_FONT_SIZE = tweak_data.gui.font_sizes.size_32
PostGameBreakdownGui.TOTAL_XP_LABEL_COLOR = tweak_data.gui.colors.raid_white
PostGameBreakdownGui.TOTAL_XP_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
PostGameBreakdownGui.TOTAL_XP_VALUE_COLOR = tweak_data.gui.colors.raid_red
PostGameBreakdownGui.TOTAL_XP_VALUE_PADDING = 14
PostGameBreakdownGui.FONT = tweak_data.gui.fonts.din_compressed
PostGameBreakdownGui.CENTRAL_DISPLAY_W = 960
PostGameBreakdownGui.CENTRAL_DISPLAY_H = 512
PostGameBreakdownGui.CENTRAL_DISPLAY_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
PostGameBreakdownGui.CENTRAL_DISPLAY_TITLE_COLOR = tweak_data.gui.colors.raid_red
PostGameBreakdownGui.CENTRAL_DISPLAY_SUBTITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_56
PostGameBreakdownGui.CENTRAL_DISPLAY_SUBTITLE_COLOR = tweak_data.gui.colors.raid_red
PostGameBreakdownGui.CENTRAL_DISPLAY_FLAVOR_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_32
PostGameBreakdownGui.CENTRAL_DISPLAY_FLAVOR_TEXT_COLOR = tweak_data.gui.colors.raid_white
PostGameBreakdownGui.CENTRAL_DISPLAY_TEXT_H = 76
PostGameBreakdownGui.CENTRAL_DISPLAY_SINGLE_ICON_CENTER_Y = 208
PostGameBreakdownGui.GENERIC_WIN_ICON = "experience_no_progress_large"
PostGameBreakdownGui.FAIL_ICON = "experience_mission_fail_large"
PostGameBreakdownGui.ONE_POINT_SOUND_EFFECT = "one_number_one_click"
PostGameBreakdownGui.LEVEL_UP_SOUND_EFFECT = "leveled_up"

-- Lines 73-81
function PostGameBreakdownGui:init(ws, fullscreen_ws, node, component_name)
	print("[PostGameBreakdownGui:init()]")

	self._closing = false
	self.current_state = game_state_machine:current_state()

	self:_calculate_xp_needed_for_levels()
	PostGameBreakdownGui.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.raid_menu:register_on_escape_callback(callback(self, self, "on_escape"))
end

-- Lines 83-102
function PostGameBreakdownGui:_set_initial_data()
	if self.current_state:is_success() then
		self._node.components.raid_menu_header:set_screen_name("menu_header_experience_success")
	else
		self._node.components.raid_menu_header:set_screen_name("menu_header_experience_fail")
	end

	self._node.components.raid_menu_header._screen_name_label:set_alpha(0)
end

-- Lines 104-210
function PostGameBreakdownGui:_layout()
	PostGameBreakdownGui.super._layout(self)

	local params_xp_breakdown = {
		name = "xp_breakdown",
		visible = true,
		x = PostGameBreakdownGui.XP_BREAKDOWN_X,
		y = PostGameBreakdownGui.XP_BREAKDOWN_Y,
		data_source_callback = callback(self, self, "data_source_xp_breakdown")
	}
	self._xp_breakdown = self._root_panel:create_custom_control(RaidGUIControlXPBreakdown, params_xp_breakdown)

	self._xp_breakdown:hide()

	local params_stats_breakdown = {
		name = "stats_breakdown",
		visible = true,
		x = self._root_panel:get_engine_panel():w() - RaidGuiBase.PADDING - PostGameBreakdownGui.STATS_BREAKDOWN_WIDTH,
		y = PostGameBreakdownGui.STATS_BREAKDOWN_Y,
		data_source_callback = callback(self, self, "data_source_stats_breakdown")
	}
	self._stats_breakdown = self._root_panel:create_custom_control(RaidGUIControlStatsBreakdown, params_stats_breakdown)

	self._stats_breakdown:set_x(self._root_panel:w() - self._stats_breakdown:w())
	self._stats_breakdown:hide()

	local top_stats_small_panel_params = {
		halign = "right",
		name = "top_stats_small_panel",
		alpha = 0,
		valign = "top",
		y = PostGameBreakdownGui.TOP_STATS_SMALL_Y,
		w = PostGameBreakdownGui.TOP_STATS_SMALL_W,
		h = PostGameBreakdownGui.TOP_STATS_SMALL_H
	}
	self._top_stats_small_panel = self._root_panel:panel(top_stats_small_panel_params)

	self._top_stats_small_panel:set_right(self._root_panel:w())

	self._top_stats_small = {}

	for i = 1, 3 do
		local top_stat_small_params = {
			name = "top_stat_small_" .. tostring(i)
		}
		local top_stat_small = self._top_stats_small_panel:create_custom_control(RaidGUIControlTopStatSmall, top_stat_small_params)

		table.insert(self._top_stats_small, top_stat_small)
	end

	self._top_stats_small[2]:set_center_y(self._top_stats_small_panel:h() / 2)
	self._top_stats_small[3]:set_bottom(self._top_stats_small_panel:h())

	local progress_bar_params = {
		name = "progress_bar",
		bar_w = 62450,
		horizontal_padding = 64,
		y = PostGameBreakdownGui.PROGRESS_BAR_Y,
		w = self._root_panel:w(),
		initial_progress = self:_get_progress(self.current_state.initial_xp),
		initial_level = self:_get_level_by_xp(self.current_state.initial_xp)
	}
	self._progress_bar = self._root_panel:create_custom_control(RaidGUIControlXPProgressBar, progress_bar_params)

	self._progress_bar:hide()

	local current_level = self:_get_level_by_xp(self.current_state.initial_xp)

	if current_level ~= 0 then
		self._progress_bar:set_level(current_level)
	end

	local total_xp_params = {
		name = "total_xp",
		value = "0",
		align = "center",
		value_align = "center",
		x = 0,
		layer = 1,
		y = PostGameBreakdownGui.TOTAL_XP_Y,
		w = self._root_panel:w(),
		h = PostGameBreakdownGui.TOTAL_XP_H,
		text = self:translate("menu_total_xp", true),
		color = PostGameBreakdownGui.TOTAL_XP_LABEL_COLOR,
		font_size = PostGameBreakdownGui.TOTAL_XP_LABEL_FONT_SIZE,
		value_color = PostGameBreakdownGui.TOTAL_XP_VALUE_COLOR,
		value_font_size = PostGameBreakdownGui.TOTAL_XP_VALUE_FONT_SIZE,
		value_padding = PostGameBreakdownGui.TOTAL_XP_VALUE_PADDING
	}
	self._total_xp_label = self._root_panel:label_named_value(total_xp_params)

	self._total_xp_label:set_alpha(0)
	self._total_xp_label:set_value(string.format("%d", self.current_state.initial_xp))
	self:_layout_central_display()
	self:_layout_generic_win_display()
	self:_layout_fail_display()
	self:_layout_skill_unlock_display()
	self:_layout_double_unlock_display()

	self._displaying_double_unlock = false

	if game_state_machine:current_state():is_success() then
		self._current_central_display = self._generic_win_panel
	else
		self._current_central_display = self._fail_panel
	end

	if game_state_machine:current_state().stats_ready then
		self:animate_breakdown()
	end

	self:bind_controller_inputs()
end

-- Lines 212-222
function PostGameBreakdownGui:_layout_central_display()
	local central_display_panel_params = {
		alpha = 0,
		name = "central_display_params",
		halign = "center",
		valign = "top",
		w = PostGameBreakdownGui.CENTRAL_DISPLAY_W,
		h = PostGameBreakdownGui.CENTRAL_DISPLAY_H
	}
	self._central_display_panel = self._root_panel:panel(central_display_panel_params)

	self._central_display_panel:set_center_x(self._root_panel:w() / 2)
end

-- Lines 225-284
function PostGameBreakdownGui:_layout_generic_win_display()
	local generic_win_panel_params = {
		visible = true,
		name = "generic_win_panel",
		halign = "scale",
		valign = "scale",
		w = self._central_display_panel:w(),
		h = self._central_display_panel:h()
	}
	self._generic_win_panel = self._central_display_panel:panel(generic_win_panel_params)

	if not self.current_state:is_success() then
		self._generic_win_panel:set_visible(false)
	end

	local icon_params = {
		name = "generic_win_icon",
		texture = tweak_data.gui.icons[PostGameBreakdownGui.GENERIC_WIN_ICON].texture,
		texture_rect = tweak_data.gui.icons[PostGameBreakdownGui.GENERIC_WIN_ICON].texture_rect
	}
	local icon = self._generic_win_panel:bitmap(icon_params)

	icon:set_center_x(self._generic_win_panel:w() / 2)
	icon:set_center_y(PostGameBreakdownGui.CENTRAL_DISPLAY_SINGLE_ICON_CENTER_Y)

	local is_player_max_level = managers.experience:reached_level_cap()
	local title_text_params = {
		vertical = "center",
		name = "generic_win_title_text",
		align = "center",
		h = PostGameBreakdownGui.CENTRAL_DISPLAY_TEXT_H,
		font = PostGameBreakdownGui.FONT,
		font_size = PostGameBreakdownGui.CENTRAL_DISPLAY_TITLE_FONT_SIZE,
		color = PostGameBreakdownGui.CENTRAL_DISPLAY_TITLE_COLOR,
		text = self:translate("menu_almost_there", true),
		visible = not is_player_max_level
	}
	local title = self._generic_win_panel:text(title_text_params)
	local _, _, w, h = title:text_rect()

	title:set_w(w)
	title:set_h(h)
	title:set_bottom(self._generic_win_panel:h())
	title:set_center_x(self._generic_win_panel:w() / 2)

	local flavor_text_params = {
		vertical = "center",
		name = "generic_win_flavor_text",
		align = "center",
		h = PostGameBreakdownGui.CENTRAL_DISPLAY_TEXT_H,
		font = PostGameBreakdownGui.FONT,
		font_size = PostGameBreakdownGui.CENTRAL_DISPLAY_FLAVOR_TEXT_FONT_SIZE,
		color = PostGameBreakdownGui.CENTRAL_DISPLAY_FLAVOR_TEXT_COLOR,
		text = self:translate("menu_keep_it_up", true),
		visible = not is_player_max_level
	}
	local flavor_text = self._generic_win_panel:text(flavor_text_params)
	local _, _, w, _ = flavor_text:text_rect()

	flavor_text:set_w(w)
	flavor_text:set_bottom(title:y() + 15)
	flavor_text:set_x(title:x())
end

-- Lines 288-342
function PostGameBreakdownGui:_layout_fail_display()
	local fail_panel_params = {
		visible = false,
		name = "fail_display_panel",
		halign = "scale",
		valign = "scale",
		w = self._central_display_panel:w(),
		h = self._central_display_panel:h()
	}
	self._fail_panel = self._central_display_panel:panel(fail_panel_params)

	if not self.current_state:is_success() then
		self._fail_panel:set_visible(true)
	end

	local icon_params = {
		name = "fail_icon",
		texture = tweak_data.gui.icons[PostGameBreakdownGui.FAIL_ICON].texture,
		texture_rect = tweak_data.gui.icons[PostGameBreakdownGui.FAIL_ICON].texture_rect
	}
	local icon = self._fail_panel:bitmap(icon_params)

	icon:set_center_x(self._fail_panel:w() / 2)
	icon:set_center_y(PostGameBreakdownGui.CENTRAL_DISPLAY_SINGLE_ICON_CENTER_Y)

	local title_text_params = {
		align = "center",
		vertical = "center",
		name = "fail_title_text",
		h = PostGameBreakdownGui.CENTRAL_DISPLAY_TEXT_H,
		font = PostGameBreakdownGui.FONT,
		font_size = PostGameBreakdownGui.CENTRAL_DISPLAY_TITLE_FONT_SIZE,
		color = PostGameBreakdownGui.CENTRAL_DISPLAY_TITLE_COLOR,
		text = self:translate("menu_better_luck_next_time", true)
	}
	local title = self._fail_panel:text(title_text_params)
	local _, _, w, h = title:text_rect()

	title:set_w(w)
	title:set_h(h)
	title:set_bottom(self._fail_panel:h())
	title:set_center_x(self._fail_panel:w() / 2)

	local flavor_text_params = {
		align = "center",
		vertical = "center",
		name = "fail_flavor_text",
		h = PostGameBreakdownGui.CENTRAL_DISPLAY_TEXT_H,
		font = PostGameBreakdownGui.FONT,
		font_size = PostGameBreakdownGui.CENTRAL_DISPLAY_FLAVOR_TEXT_FONT_SIZE,
		color = PostGameBreakdownGui.CENTRAL_DISPLAY_FLAVOR_TEXT_COLOR,
		text = self:translate("menu_fail", true)
	}
	local flavor_text = self._fail_panel:text(flavor_text_params)
	local _, _, w, _ = flavor_text:text_rect()

	flavor_text:set_w(w)
	flavor_text:set_bottom(title:y() + 15)
	flavor_text:set_x(title:x())
end

-- Lines 345-347
function PostGameBreakdownGui:_layout_skill_unlock_display()
	self._skill_unlock_display = RaidGUIControlXPSkillSet:new(self._central_display_panel)
end

-- Lines 349-351
function PostGameBreakdownGui:_layout_double_unlock_display()
	self._double_unlock_display = RaidGUIControlXPDoubleUnlock:new(self._central_display_panel)
end

-- Lines 355-373
function PostGameBreakdownGui:_get_progress(current_xp)
	local level_cap = managers.experience:level_cap()
	local current_level = self:_get_level_by_xp(current_xp)
	local xp_for_current_level = managers.experience:get_total_xp_for_level(current_level)
	local xp_for_next_level = xp_for_current_level

	if current_level < level_cap then
		xp_for_next_level = managers.experience:get_total_xp_for_level(current_level + 1)
	end

	local progress_to_level = (current_level - 1) / (level_cap - 1)
	local progress_in_level = 0

	if xp_for_next_level ~= xp_for_current_level then
		progress_in_level = 1 / (level_cap - 1) * (current_xp - xp_for_current_level) / (xp_for_next_level - xp_for_current_level)
	end

	return math.clamp(progress_to_level + progress_in_level, 0, 1)
end

-- Lines 375-383
function PostGameBreakdownGui:_calculate_xp_needed_for_levels()
	local level_cap = managers.experience:level_cap()
	self._levels_by_xp = {}

	for i = 1, level_cap do
		local points_needed = managers.experience:get_total_xp_for_level(i)

		table.insert(self._levels_by_xp, points_needed)
	end
end

-- Lines 385-398
function PostGameBreakdownGui:_get_level_by_xp(xp)
	local level_cap = managers.experience:level_cap()
	local points_needed = self._levels_by_xp[1]
	local level = 0

	while level_cap > level and points_needed < xp do
		level = level + 1
		points_needed = self._levels_by_xp[level + 1]
	end

	return level
end

-- Lines 401-454
function PostGameBreakdownGui:_get_xp_breakdown()
	local xp_table = {
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		},
		{
			{
				value = 1,
				info = "empty",
				text = ""
			},
			{
				value = 0,
				info = "empty",
				text = ""
			}
		}
	}

	return xp_table
end

-- Lines 456-458
function PostGameBreakdownGui:data_source_xp_breakdown()
	return self:_get_xp_breakdown()
end

-- Lines 460-491
function PostGameBreakdownGui:_get_stats_breakdown()
	local personal_stats = game_state_machine:current_state().personal_stats
	local stats_breakdown = {
		{
			{
				value = 1,
				info = "lvl diff",
				text = self:translate("menu_stat_total_kills_title", true)
			},
			{
				value = 200,
				info = "lvl diff",
				text = tostring(personal_stats.session_killed)
			}
		},
		{
			{
				value = 1,
				info = "surviving players",
				text = self:translate("menu_stat_accuracy_title", true)
			},
			{
				value = 500,
				info = "surviving players",
				text = string.format("%.0f", personal_stats.session_accuracy) .. "%"
			}
		},
		{
			{
				value = 1,
				info = "human players",
				text = self:translate("menu_stat_headshots_title", true)
			},
			{
				value = 450,
				info = "human players",
				text = tostring(personal_stats.session_headshots) .. " (" .. string.format("%.0f", personal_stats.session_headshot_percentage) .. "%)"
			}
		},
		{
			{
				value = 1,
				info = "most kills",
				text = self:translate("menu_stat_special_kills_title", true)
			},
			{
				value = 0,
				info = "most kills",
				text = tostring(personal_stats.session_special_kills)
			}
		},
		{
			{
				value = 1,
				info = "best acc",
				text = self:translate("menu_stat_teammates_revived_title", true)
			},
			{
				value = 0,
				info = "best acc",
				text = tostring(personal_stats.session_teammates_revived)
			}
		},
		{
			{
				value = 1,
				info = "most specials",
				text = self:translate("menu_stat_bleedouts_title", true)
			},
			{
				value = 500,
				info = "most specials",
				text = tostring(personal_stats.session_bleedouts)
			}
		}
	}

	return stats_breakdown
end

-- Lines 493-495
function PostGameBreakdownGui:data_source_stats_breakdown()
	return self:_get_stats_breakdown()
end

-- Lines 498-500
function PostGameBreakdownGui:_continue_button_on_click()
	managers.raid_menu:close_menu()
end

-- Lines 502-514
function PostGameBreakdownGui:close()
	if self._closing then
		return
	end

	self._root_panel:get_engine_panel():stop()

	self._closing = true

	if game_state_machine:current_state_name() == "event_complete_screen" then
		game_state_machine:current_state():continue()
	end

	PostGameBreakdownGui.super.close(self)
end

-- Lines 516-518
function PostGameBreakdownGui:give_xp(xp_earned)
	self._root_panel:get_engine_panel():animate(callback(self, self, "_animate_giving_xp"), xp_earned)
end

-- Lines 520-543
function PostGameBreakdownGui:_unlock_level(level)
	if level == 1 then
		return
	end

	managers.menu_component:post_event(PostGameBreakdownGui.LEVEL_UP_SOUND_EFFECT)

	local character_class = managers.skilltree:get_character_profile_class()
	local weapon_unlock_progression = tweak_data.skilltree.automatic_unlock_progressions[character_class]

	self._progress_bar:unlock_level(level)
	self._skill_unlock_display:set_level(level)
	self._double_unlock_display:set_level(level)

	self._displaying_double_unlock = false

	if (weapon_unlock_progression[level] and weapon_unlock_progression[level].weapons or self._should_display_double_unlock) and not self._displaying_double_unlock then
		self._should_display_double_unlock = true

		self._central_display_panel:get_engine_panel():stop()
		self._central_display_panel:get_engine_panel():animate(callback(self, self, "_animate_active_display_panel"), self._double_unlock_display)
	elseif self._current_central_display == self._generic_win_panel or self._current_central_display == self._fail_panel then
		self._central_display_panel:get_engine_panel():stop()
		self._central_display_panel:get_engine_panel():animate(callback(self, self, "_animate_active_display_panel"), self._skill_unlock_display)
	end
end

-- Lines 545-577
function PostGameBreakdownGui:_animate_active_display_panel(central_display_panel, new_active_panel)
	local fade_out_duration = 0.25
	local fade_in_duration = 0.3
	local t = (1 - self._central_display_panel:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._central_display_panel:set_alpha(current_alpha)
	end

	self._central_display_panel:set_alpha(0)
	self._current_central_display:set_visible(false)

	self._current_central_display = new_active_panel

	self._current_central_display:set_visible(true)

	if new_active_panel == self._double_unlock_display then
		self._displaying_double_unlock = true
	end

	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_in_duration)

		self._central_display_panel:set_alpha(current_alpha)
	end

	self._central_display_panel:set_alpha(1)
end

-- Lines 579-610
function PostGameBreakdownGui:animate_breakdown()
	if managers.network:session():amount_of_players() > 1 then
		local top_stats = managers.statistics:get_top_stats()

		for i = 1, 3 do
			local data = {
				player_nickname = top_stats[i].peer_name,
				stat = top_stats[i].id,
				icon = tweak_data.statistics.top_stats[top_stats[i].id].icon,
				icon_texture = tweak_data.statistics.top_stats[top_stats[i].id].texture,
				icon_texture_rect = tweak_data.statistics.top_stats[top_stats[i].id].texture_rect,
				score = top_stats[i].score,
				score_format = tweak_data.statistics.top_stats[top_stats[i].id].score_format
			}

			self._top_stats_small[i]:set_data(data)
		end
	end

	Application:debug("[PostGameBreakdownGui:_layout()] Saving progress!")
	managers.savefile:save_progress()
	self._root_panel:get_engine_panel():animate(callback(self, self, "_animate_xp_breakdown"))
end

-- Lines 612-755
function PostGameBreakdownGui:_animate_xp_breakdown()
	local t = 0
	local xp_breakdown = self.current_state.xp_breakdown
	local table = self._xp_breakdown._breakdown_table
	local table_rows = table:get_rows()
	local total_row_cells = table_rows[#table_rows]:get_cells()
	local shown_total_row = false
	local current_index = 1
	local current_multiplier = 1
	local current_total = 0
	local previous_level = self:_get_level_by_xp(self.current_state.initial_xp)
	local current_level = previous_level
	local max_unlocked_level = previous_level
	local actual_level = managers.experience:current_level()

	wait(0.5)
	self._node.components.raid_menu_header._screen_name_label._object:animate(callback(self, self, "_fade_in_label"), 0.2)
	self._xp_breakdown:fade_in()
	self._progress_bar:fade_in()
	self._total_xp_label._object:get_engine_panel():animate(callback(self, self, "_fade_in_label"), 0.2)
	self._central_display_panel:get_engine_panel():animate(callback(self, self, "_fade_in_label"), 0.2)
	wait(1.1)

	for i = 1, #xp_breakdown.additive do
		local previous_value = 0
		local current_value = 0
		t = 0
		local row_cells = table_rows[current_index]:get_cells()

		row_cells[1]:set_visible(false)
		row_cells[2]:set_visible(false)
		row_cells[1]:set_text(utf8.to_upper(managers.localization:text(xp_breakdown.additive[i].id)))
		row_cells[2]:set_text("0")
		row_cells[1]:fade_in(0.15)
		row_cells[2]:fade_in(0.15)

		if not shown_total_row then
			self._xp_breakdown:set_total("0")
			self._xp_breakdown:fade_in_total()

			shown_total_row = true
		end

		wait(0.13)

		while t < 0.5 do
			local dt = coroutine.yield()
			t = t + dt
			current_value = Easing.quartic_in_out(t, 0, xp_breakdown.additive[i].amount, 0.5)

			row_cells[2]:set_text(string.format("%.0f", current_value), true)
			self._xp_breakdown:set_total(string.format("%.0f", current_total + current_value), true)
			self._total_xp_label:set_value(string.format("%.0f", self.current_state.initial_xp + current_total + current_value), true)

			if current_value ~= previous_value then
				managers.menu_component:post_event(PostGameBreakdownGui.ONE_POINT_SOUND_EFFECT)
			end

			self._progress_bar:set_progress(self:_get_progress(self.current_state.initial_xp + current_total + current_value), current_total + current_value)

			current_level = self:_get_level_by_xp(self.current_state.initial_xp + current_total + current_value)

			if previous_level < current_level and max_unlocked_level < current_level and current_level <= actual_level then
				self:_unlock_level(current_level)

				max_unlocked_level = current_level
			end

			previous_value = current_value
			previous_level = current_level
		end

		wait(0.1)

		current_total = current_total + xp_breakdown.additive[i].amount
		current_index = current_index + 1
	end

	wait(0.25)

	current_index = current_index + 1
	local total_base = current_total

	for i = 1, #xp_breakdown.multiplicative do
		local previous_value = 0
		local current_value = 0
		t = 0
		local row_cells = table_rows[current_index]:get_cells()

		row_cells[1]:set_visible(false)
		row_cells[2]:set_visible(false)
		row_cells[1]:set_text(utf8.to_upper(managers.localization:text(xp_breakdown.multiplicative[i].id)))
		row_cells[2]:set_text("+0%")
		row_cells[1]:fade_in(0.15)
		row_cells[2]:fade_in(0.15)
		wait(0.13)

		while t < 0.5 do
			local dt = coroutine.yield()
			t = t + dt
			current_value = Easing.quartic_in_out(t, 0, xp_breakdown.multiplicative[i].amount, 0.5)

			row_cells[2]:set_text(string.format("+%.0f%%", current_value * 100), true)
			self._xp_breakdown:set_total(string.format("%.0f", current_total + current_value * total_base), true)
			self._total_xp_label:set_value(string.format("%.0f", self.current_state.initial_xp + current_total + current_value * total_base), true)

			if current_value ~= previous_value then
				managers.menu_component:post_event(PostGameBreakdownGui.ONE_POINT_SOUND_EFFECT)
			end

			local current_progress = self:_get_progress(self.current_state.initial_xp + current_total + current_value * total_base)

			self._progress_bar:set_progress(self:_get_progress(self.current_state.initial_xp + current_total + current_value * total_base), current_total + current_value * total_base)

			current_level = self:_get_level_by_xp(self.current_state.initial_xp + current_total + current_value * total_base)

			if previous_level < current_level and max_unlocked_level < current_level and current_level <= actual_level then
				self:_unlock_level(current_level)

				max_unlocked_level = current_level
			end

			previous_value = current_value
			previous_level = current_level
		end

		wait(0.1)

		current_total = current_total + xp_breakdown.multiplicative[i].amount * total_base
		current_index = current_index + 1
	end

	self._stats_breakdown:fade_in()

	if managers.network:session():amount_of_players() > 1 and game_state_machine:current_state():is_success() and SystemInfo:platform() ~= Idstring("XB1") and SystemInfo:platform() ~= Idstring("X360") then
		wait(1.5)
		self._top_stats_small_panel:get_engine_panel():animate(callback(self, self, "_fade_in_label"), 0.2)
	end
end

-- Lines 757-775
function PostGameBreakdownGui:_fade_in_label(text, duration, delay)
	local anim_duration = duration or 0.15
	local t = text:alpha() * anim_duration

	if delay then
		wait(delay)
	end

	while t < anim_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, anim_duration)

		text:set_alpha(current_alpha)
	end

	text:set_alpha(1)
end

-- Lines 777-803
function PostGameBreakdownGui:_animate_giving_xp(panel, xp_earned)
	local points_given = 0
	local mid_speed = 30
	local in_duration = 3
	local out_duration = 2
	local t = 0

	while in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_speed = Easing.quadratic_in(t, 1, mid_speed - 1, in_duration)

		if xp_earned < points_given + current_speed then
			break
		end

		points_given = points_given + current_speed
	end

	while xp_earned > points_given + mid_speed do
		local dt = coroutine.yield()
		points_given = points_given + mid_speed
	end
end

-- Lines 805-807
function PostGameBreakdownGui:confirm_pressed()
	self:_continue_button_on_click()
end

-- Lines 809-811
function PostGameBreakdownGui:on_escape()
	return true
end

-- Lines 813-828
function PostGameBreakdownGui:bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_continue_button_on_click")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_continue"
		},
		keyboard = {
			{
				key = "footer_continue",
				callback = callback(self, self, "_continue_button_on_click", nil)
			}
		}
	}

	self:set_legend(legend)
end
