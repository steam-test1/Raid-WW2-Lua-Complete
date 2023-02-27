ExperienceGui = ExperienceGui or class(RaidGuiBase)
ExperienceGui.CHARACTER_BASE_INFO_Y = 0
ExperienceGui.CHARACTER_BASE_INFO_W = 352
ExperienceGui.CHARACTER_BASE_INFO_H = 96
ExperienceGui.INFO_ICON_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_24
ExperienceGui.CHARACTER_LEVEL_LABEL_FONT_SIZE = tweak_data.gui.font_sizes.size_56
ExperienceGui.CHARACTER_LEVEL_LABEL_FONT_COLOR = tweak_data.gui.colors.raid_grey
ExperienceGui.SKILLTREE_X = 0
ExperienceGui.SKILLTREE_Y = 128
ExperienceGui.SKILL_DETAILS_X = 0
ExperienceGui.SKILL_DETAILS_Y = 300
ExperienceGui.RESPEC_X = 1368
ExperienceGui.RESPEC_Y = 675
ExperienceGui.RESPEC_INSUFFICIENT_X = 1526
ExperienceGui.RESPEC_UNAVAILABLE_X = 1576
ExperienceGui.CLASS_INFO_H = 96
ExperienceGui.CLASS_ICON_H = 64
ExperienceGui.CLASS_INFO_TEXT_H = 32
ExperienceGui.NATIONALITY_INFO_W = 128
ExperienceGui.NATIONALITY_INFO_H = 96
ExperienceGui.NATIONALITY_ICON_H = 64
ExperienceGui.NATIONALITY_INFO_TEXT_H = 32
ExperienceGui.LEVEL_INFO_W = 64
ExperienceGui.LEVEL_INFO_H = 96
ExperienceGui.LEVEL_INFO_TEXT_H = 32
ExperienceGui.INFO_ICONS_PADDING = 32
ExperienceGui.APPLY_BUTTON_CENTER_Y = 864
ExperienceGui.CLEAR_BUTTON_X = 256
ExperienceGui.CLEAR_BUTTON_CENTER_Y = 864
ExperienceGui.RESPEC_BUTTON_X = 1520
ExperienceGui.RESPEC_BUTTON_CENTER_Y = 864
ExperienceGui.STAT_LEVEL_ACTIVE = "stat_level_active"
ExperienceGui.STAT_LEVEL_INACTIVE = "stat_level_inactive"
ExperienceGui.STAT_LEVEL_PENDING = "stat_level_pending"
ExperienceGui.STATS_W = 560
ExperienceGui.STATS_H = 160
ExperienceGui.STATS_CENTER_Y = 878
ExperienceGui.SINGLE_STAT_W = 256

function ExperienceGui:init(ws, fullscreen_ws, node, component_name)
	self._closing = false

	ExperienceGui.super.init(self, ws, fullscreen_ws, node, component_name)

	self._activated_skills = {}
	local character_class = managers.skilltree:get_character_profile_class()

	self._node.components.raid_menu_header:set_screen_name_raw(self:translate("menu_skill_screen_title", true) .. " - " .. self:translate("skill_class_" .. character_class .. "_name", true))
	self:_refresh_stats()
end

function ExperienceGui:_set_initial_data()
end

function ExperienceGui:_layout()
	ExperienceGui.super._layout(self)
	self:_layout_character_base_info()
	self:_layout_skilltree()
	self:_layout_respec()
	self:_layout_character_overview()
	self:_layout_buttons()
	self:_layout_stats()
	self._skilltrack_progress_bar:set_selected(true)
	self:bind_controller_inputs_initial_state()
	self:_calculate_respec_visibility()
end

function ExperienceGui:_layout_character_base_info()
	local base_info_panel_params = {
		name = "character_base_info_panel",
		x = 0,
		y = ExperienceGui.CHARACTER_BASE_INFO_Y,
		w = ExperienceGui.CHARACTER_BASE_INFO_W,
		h = ExperienceGui.CHARACTER_BASE_INFO_H
	}
	self._character_base_info_panel = self._root_panel:panel(base_info_panel_params)
	local character_class = managers.skilltree:get_character_profile_class()
	local class_icon_params = {
		name = "class_icon",
		y = 0,
		x = 0,
		h = ExperienceGui.CLASS_INFO_H,
		text_h = ExperienceGui.CLASS_INFO_TEXT_H,
		icon = "ico_class_" .. character_class,
		icon_h = ExperienceGui.CLASS_ICON_H,
		icon_color = Color.white,
		text = self:translate("skill_class_" .. character_class .. "_name", true),
		text_size = ExperienceGui.INFO_ICON_TEXT_FONT_SIZE,
		text_color = ExperienceGui.CHARACTER_LEVEL_LABEL_FONT_COLOR
	}
	self._class_icon = self._character_base_info_panel:info_icon(class_icon_params)

	self._class_icon:set_bottom(self._character_base_info_panel:h())

	local character_nationality = managers.player:get_character_profile_nation()
	local nationality_icon_params = {
		x = 0,
		name = "nationality_icon",
		y = 0,
		w = ExperienceGui.NATIONALITY_INFO_W,
		h = ExperienceGui.NATIONALITY_INFO_H,
		text_h = ExperienceGui.NATIONALITY_INFO_TEXT_H,
		icon = "ico_flag_" .. character_nationality,
		icon_h = ExperienceGui.NATIONALITY_ICON_H,
		icon_color = Color.white,
		text = self:translate("nationality_" .. character_nationality, true),
		text_size = RaidGUIControlPeerDetails.ICON_FONT_SIZE,
		text_size = ExperienceGui.INFO_ICON_TEXT_FONT_SIZE,
		text_color = ExperienceGui.CHARACTER_LEVEL_LABEL_FONT_COLOR
	}
	self._nationality_icon = self._character_base_info_panel:info_icon(nationality_icon_params)

	self._nationality_icon:set_bottom(self._character_base_info_panel:h())

	local character_level = managers.experience:current_level()
	local level_icon_params = {
		name = "level_icon",
		y = 0,
		x = 0,
		w = ExperienceGui.LEVEL_INFO_W,
		h = ExperienceGui.LEVEL_INFO_H,
		text_h = ExperienceGui.LEVEL_INFO_TEXT_H,
		title = tostring(character_level),
		title_size = ExperienceGui.CHARACTER_LEVEL_LABEL_FONT_SIZE,
		title_color = Color.white,
		text = self:translate("menu_level_label", true),
		text_size = ExperienceGui.INFO_ICON_TEXT_FONT_SIZE,
		text_color = ExperienceGui.CHARACTER_LEVEL_LABEL_FONT_COLOR
	}
	self._current_level_icon = self._character_base_info_panel:info_icon(level_icon_params)

	self._current_level_icon:set_bottom(self._character_base_info_panel:h())
	self._character_base_info_panel:set_w(self._class_icon:w() + ExperienceGui.INFO_ICONS_PADDING + self._nationality_icon:w() + ExperienceGui.INFO_ICONS_PADDING + self._current_level_icon:w())
	self._character_base_info_panel:set_right(self._root_panel:right())
	self._current_level_icon:set_right(self._character_base_info_panel:w())
	self._nationality_icon:set_right(self._current_level_icon:x() - ExperienceGui.INFO_ICONS_PADDING)
	self._class_icon:set_right(self._nationality_icon:x() - ExperienceGui.INFO_ICONS_PADDING)
end

function ExperienceGui:_layout_skilltree()
	if self._skilltrack_panel then
		self._skilltrack_panel:clear()
	else
		local params_skill_track_panel = {
			x = ExperienceGui.SKILLTREE_X,
			y = ExperienceGui.SKILLTREE_Y,
			w = self._root_panel:w()
		}
		self._skilltrack_panel = self._root_panel:panel(params_skill_track_panel)
	end

	local params_skill_track = {
		name = "skilltrack_progress_bar",
		y = 0,
		starting_points = 0,
		x = 0,
		w = self._skilltrack_panel:w(),
		on_click_callback = callback(self, self, "on_skill_activated"),
		on_mouse_enter_callback = callback(self, self, "on_skill_mouse_over"),
		on_mouse_exit_callback = callback(self, self, "on_skill_mouse_out"),
		x_step = ExperienceGui.SKILLTRACK_BPB_X_STEP,
		y_step = ExperienceGui.SKILLTRACK_BPB_Y_STEP,
		padding = ExperienceGui.SKILLTRACK_BPB_X_PADDING,
		data_source_callback = callback(self, self, "data_source_branching_progress_bar"),
		on_selection_changed_callback = callback(self, self, "on_skilltree_selection_changed")
	}
	self._skilltrack_progress_bar = self._skilltrack_panel:create_custom_control(RaidGUIControlSkilltree, params_skill_track)

	self._skilltrack_progress_bar:give_points(managers.experience:total())
end

function ExperienceGui:_layout_respec()
	local params_respecs = {
		name = "respec",
		x = ExperienceGui.RESPEC_X,
		y = ExperienceGui.RESPEC_Y
	}
	self._respec = self._root_panel:create_custom_control(RaidGUIControlRespec, params_respecs)
	local gold_icon = tweak_data.gui.icons.gold_amount_footer
	local gold_icon_params = {
		halign = "scale",
		valign = "scale",
		texture = gold_icon.texture,
		texture_rect = gold_icon.texture_rect,
		x = ExperienceGui.RESPEC_X,
		y = ExperienceGui.RESPEC_BUTTON_CENTER_Y - 16,
		color = tweak_data.gui.colors.raid_gold,
		w = gold_icon.texture_rect[3],
		h = gold_icon.texture_rect[4]
	}
	self._cost_icon = self._root_panel:bitmap(gold_icon_params)
	local cost_params = {
		text = "",
		name = "respec_cost",
		y = 0,
		x = ExperienceGui.RESPEC_X + self._cost_icon:w() + 12,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_38,
		color = tweak_data.gui.colors.raid_gold
	}
	self._cost_label = self._root_panel:label(cost_params)

	self._cost_label:set_y(ExperienceGui.RESPEC_BUTTON_CENTER_Y - 19)

	local cost_additional_params = {
		text = "",
		name = "respec_cost_additional",
		y = 0,
		x = 0,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_gold
	}
	self._cost_additional_label = self._root_panel:label(cost_additional_params)

	self._cost_additional_label:set_y(ExperienceGui.RESPEC_BUTTON_CENTER_Y - 13)
end

function ExperienceGui:_layout_character_overview()
end

function ExperienceGui:_layout_buttons()
	local apply_button_params = {
		name = "apply_button",
		y = 0,
		x = 0,
		text = self:translate("menu_weapons_apply", true),
		on_click_callback = callback(self, self, "on_click_apply_callback")
	}
	self._apply_button = self._root_panel:short_primary_button(apply_button_params)

	self._apply_button:set_y(ExperienceGui.APPLY_BUTTON_CENTER_Y - self._apply_button:h() / 2)
	self._apply_button:hide()

	local clear_button_params = {
		name = "clear_button_params",
		y = 0,
		x = ExperienceGui.CLEAR_BUTTON_X,
		text = self:translate("menu_weapons_clear", true),
		on_click_callback = callback(self, self, "on_click_clear_callback")
	}
	self._clear_button = self._root_panel:short_tertiary_button(clear_button_params)

	self._clear_button:set_y(ExperienceGui.CLEAR_BUTTON_CENTER_Y - self._clear_button:h() / 2)
	self._clear_button:hide()

	local respec_button_params = {
		name = "clear_button_params",
		y = 0,
		x = ExperienceGui.RESPEC_BUTTON_X,
		text = self:translate("menu_weapons_respec", true),
		on_click_callback = callback(self, self, "on_click_respec_callback")
	}
	self._respec_button = self._root_panel:short_primary_gold_button(respec_button_params)

	self._respec_button:set_y(ExperienceGui.RESPEC_BUTTON_CENTER_Y - self._clear_button:h() / 2)
end

function ExperienceGui:_layout_stats()
	local stats_panel_params = {
		name = "stats_panel",
		halign = "center",
		w = ExperienceGui.STATS_W,
		h = ExperienceGui.STATS_H
	}
	self._stats_panel = self._root_panel:panel(stats_panel_params)

	self._stats_panel:set_center_x(self._root_panel:w() / 2)
	self._stats_panel:set_center_y(ExperienceGui.STATS_CENTER_Y)

	local health_stat_params = {
		value_padding = 10,
		value_delta_color = tweak_data.gui.colors.raid_red,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey_effects,
		w = ExperienceGui.SINGLE_STAT_W
	}
	self._health_stat = self._stats_panel:create_custom_control(RaidGUIControlLabelNamedValueWithDelta, health_stat_params)

	self._health_stat:set_text(self:translate("select_character_health_label", true))
	self._health_stat:set_value("23")
	self._health_stat:set_value_delta(1)

	local speed_stat_params = {
		value_padding = 10,
		value_delta_color = tweak_data.gui.colors.raid_red,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey_effects,
		w = ExperienceGui.SINGLE_STAT_W
	}
	self._speed_stat = self._stats_panel:create_custom_control(RaidGUIControlLabelNamedValueWithDelta, speed_stat_params)

	self._speed_stat:set_text(self:translate("select_character_speed_label", true))
	self._speed_stat:set_value("34")
	self._speed_stat:set_center_x(self._stats_panel:w() / 2)

	local stamina_stat_params = {
		value_padding = 10,
		value_delta_color = tweak_data.gui.colors.raid_red,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey_effects,
		w = ExperienceGui.SINGLE_STAT_W
	}
	self._stamina_stat = self._stats_panel:create_custom_control(RaidGUIControlLabelNamedValueWithDelta, stamina_stat_params)

	self._stamina_stat:set_text(self:translate("select_character_stamina_label", true))
	self._stamina_stat:set_value("76")
	self._stamina_stat:set_value_delta(3)
	self._stamina_stat:set_right(self._stats_panel:w())
end

function ExperienceGui:_calculate_respec_visibility()
	self._cost_label:set_text(managers.gold_economy:respec_cost_string())

	local found = false
	local level_2 = self._skilltrack_progress_bar._levels[2]

	for j = 1, #level_2.nodes do
		local node = level_2.nodes[j]

		if node:state() == RaidGUIControlBranchingBarNode.STATE_ACTIVE then
			found = true
		end
	end

	if found then
		self._cost_icon:show()
		self._cost_label:show()

		if managers.gold_economy:respec_cost() <= managers.gold_economy:current() then
			self._cost_additional_label:hide()
			self._respec_button:show()
		else
			self._respec_button:hide()
			self._cost_additional_label:show()
			self._cost_additional_label:set_text(utf8.to_upper(managers.localization:text("menu_character_skills_insufficient_funds")))
			self._cost_additional_label:set_color(tweak_data.gui.colors.raid_gold)
			self._cost_additional_label:set_x(ExperienceGui.RESPEC_INSUFFICIENT_X)
		end
	else
		self._respec_button:hide()
		self._cost_icon:hide()
		self._cost_label:hide()
		self._cost_additional_label:show()
		self._cost_additional_label:set_text(utf8.to_upper(managers.localization:text("menu_character_skills_retrain_not_available")))
		self._cost_additional_label:set_color(tweak_data.gui.colors.raid_red)
		self._cost_additional_label:set_x(ExperienceGui.RESPEC_UNAVAILABLE_X)
	end
end

function ExperienceGui:on_skill_activated(button_data)
	table.insert(self._activated_skills, button_data)
end

function ExperienceGui:on_skill_mouse_over(button_data)
	if button_data.skill_title then
		managers.menu_component:post_event("highlight")

		local skill_flavor, skill_description, color_changes = self:_prepare_skill_description(button_data)

		self._skilltrack_progress_bar:select_node(button_data.level, button_data.index)
		self._skilltrack_progress_bar:update_skill_details(button_data, skill_flavor, skill_description, color_changes)
	end
end

function ExperienceGui:on_skill_mouse_out(button_data)
	if button_data.skill_title then
		self._skilltrack_progress_bar:hide_skill_details()
	end
end

function ExperienceGui:_prepare_skill_description(button_data)
	local skill = tweak_data.skilltree.skills[button_data.skill]
	local upgrade_tweak_data = tweak_data.upgrades.definitions[skill.upgrades[1]]
	local description_raw = managers.localization:text(button_data.skill_description)
	local description = utf8.sub(description_raw, 0, string.len(description_raw))
	local stat_line = ""
	local color_changes = {}

	if skill.acquires and skill.acquires[1] and skill.acquires[1].warcry_level then
		stat_line = self:_prepare_warcry_upgrade_description(button_data.level, skill.acquires[1].warcry_level)
	end

	if not skill.upgrades[1] then
		Application:error("[ExperienceGui:_prepare_skill_description] NO UPGRADES " .. (skill.stat_desc_id or "stat_desc_id nil"))

		return description, stat_line, color_changes
	end

	local upgrade = tweak_data.upgrades.definitions[skill.upgrades[1]].upgrade
	local current_upgrade_level = managers.player:upgrade_level(upgrade.category, upgrade.upgrade)
	local current_selected_level = self:_upgrade_level_from_selected_skills(skill, button_data.level, button_data.index)
	local total_upgrade_level = current_upgrade_level + current_selected_level

	if skill.stat_desc_id then
		local macros = {}
		local pending = false

		if (button_data.state == RaidGUIControlBranchingBarNode.STATE_HOVER or button_data.state == RaidGUIControlBranchingBarNode.STATE_SELECTED or button_data.state == RaidGUIControlBranchingBarNode.STATE_PENDING) and tweak_data.upgrades.values[upgrade.category][upgrade.upgrade][total_upgrade_level + 1] then
			macros.LEVEL = total_upgrade_level + 1
			pending = true
		else
			macros.LEVEL = total_upgrade_level
		end

		local stat_line_raw = managers.localization:text(skill.stat_desc_id, macros)
		local stat_line_utf8 = utf8.sub(stat_line_raw, 0, string.len(stat_line_raw))

		if upgrade_tweak_data.description_data then
			if upgrade_tweak_data.description_data.upgrade_type == UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER then
				self:_prepare_upgrade_stats_type_multiplier(stat_line_utf8, total_upgrade_level, pending, upgrade_tweak_data, macros, color_changes)
			elseif upgrade_tweak_data.description_data.upgrade_type == UpgradesTweakData.UPGRADE_TYPE_REDUCTIVE_MULTIPLIER then
				self:_prepare_upgrade_stats_type_reductive_multiplier(stat_line_utf8, total_upgrade_level, pending, upgrade_tweak_data, macros, color_changes)
			elseif upgrade_tweak_data.description_data.upgrade_type == UpgradesTweakData.UPGRADE_TYPE_MULTIPLIER_REDUCTIVE_STRING then
				self:_prepare_upgrade_stats_type_multiplier_reductive_string(stat_line_utf8, total_upgrade_level, pending, upgrade_tweak_data, macros, color_changes)
			elseif upgrade_tweak_data.description_data.upgrade_type == UpgradesTweakData.UPGRADE_TYPE_RAW_VALUE_REDUCTION then
				self:_prepare_upgrade_stats_type_raw_value_reduction(stat_line_utf8, total_upgrade_level, pending, upgrade_tweak_data, macros, color_changes)
			elseif upgrade_tweak_data.description_data.upgrade_type == UpgradesTweakData.UPGRADE_TYPE_RAW_VALUE_AMOUNT then
				self:_prepare_upgrade_stats_type_raw_value_amount(stat_line_utf8, total_upgrade_level, pending, upgrade_tweak_data, macros, color_changes)
			elseif upgrade_tweak_data.description_data.upgrade_type == UpgradesTweakData.UPGRADE_TYPE_TEMPORARY_REDUCTION then
				self:_prepare_upgrade_stats_type_temporary_reduction(stat_line_utf8, total_upgrade_level, pending, upgrade_tweak_data, macros, color_changes)
			end
		end

		stat_line = managers.localization:text(skill.stat_desc_id, macros)
	end

	return description, stat_line, color_changes
end

function ExperienceGui:_prepare_warcry_upgrade_description(level, warcry_level_increase)
	local active_warcry = managers.warcry:get_active_warcry()
	local target_warcry_level = math.round(level / 10) + 1

	return active_warcry:get_level_description(target_warcry_level)
end

function ExperienceGui:_upgrade_level_from_selected_skills(skill, skill_button_level, skill_button_index)
	local selected_nodes = self._skilltrack_progress_bar:get_selected_nodes()
	local selected_num = 0

	for index, node_data in pairs(selected_nodes) do
		local same_button = node_data.level == skill_button_level and node_data.index == skill_button_index

		if skill.name_id == node_data.skill_title and not same_button then
			selected_num = selected_num + 1
		end
	end

	return selected_num
end

function ExperienceGui:_prepare_upgrade_stats_type_raw_value_reduction(string, current_level, pending, upgrade_tweak_data, macros, color_changes)
	local upgrade_values = tweak_data.upgrades.values[upgrade_tweak_data.upgrade.category][upgrade_tweak_data.upgrade.upgrade]
	local starting_index = string:find("$REDUCTION;") - 1
	local current_index = starting_index
	local macro = ""
	local separator = " / "

	for index, value in pairs(upgrade_values) do
		local current_value = string.format("%.0f", value)

		if index <= current_level then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_ACTIVE,
				start_index = current_index,
				end_index = current_index + string.len(current_value) + string.len(separator)
			})
		elseif index == current_level + 1 and pending then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_PENDING,
				start_index = current_index,
				end_index = current_index + string.len(current_value)
			})
		end

		macro = macro .. current_value

		if index ~= #upgrade_values then
			macro = macro .. separator
		end

		current_index = current_index + string.len(current_value) + string.len(separator)
	end

	table.insert(color_changes, 1, {
		state = ExperienceGui.STAT_LEVEL_INACTIVE,
		start_index = starting_index,
		end_index = starting_index + string.len(macro)
	})

	macros.REDUCTION = macro
end

function ExperienceGui:_prepare_upgrade_stats_type_raw_value_amount(string, current_level, pending, upgrade_tweak_data, macros, color_changes)
	local upgrade_values = tweak_data.upgrades.values[upgrade_tweak_data.upgrade.category][upgrade_tweak_data.upgrade.upgrade]
	local starting_index = string:find("$AMOUNT;") - 1
	local current_index = starting_index
	local macro = ""
	local separator = " / "

	for index, value in pairs(upgrade_values) do
		local current_value = string.format("%.0f", value)

		if index <= current_level then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_ACTIVE,
				start_index = current_index,
				end_index = current_index + string.len(current_value) + string.len(separator)
			})
		elseif index == current_level + 1 and pending then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_PENDING,
				start_index = current_index,
				end_index = current_index + string.len(current_value)
			})
		end

		macro = macro .. current_value

		if index ~= #upgrade_values then
			macro = macro .. separator
		end

		current_index = current_index + string.len(current_value) + string.len(separator)
	end

	table.insert(color_changes, 1, {
		state = ExperienceGui.STAT_LEVEL_INACTIVE,
		start_index = starting_index,
		end_index = starting_index + string.len(macro)
	})

	macros.AMOUNT = macro
end

function ExperienceGui:_prepare_upgrade_stats_type_temporary_reduction(string, current_level, pending, upgrade_tweak_data, macros, color_changes)
	local upgrade_values = tweak_data.upgrades.values[upgrade_tweak_data.upgrade.category][upgrade_tweak_data.upgrade.upgrade]
	local starting_index = string:find("$PERCENTAGE;") - 1
	local current_index = starting_index
	local macro = ""
	local separator = " / "

	for index, value in pairs(upgrade_values) do
		local current_value = string.format("%.0f%%", (1 - value[1]) * 100)

		if index <= current_level then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_ACTIVE,
				start_index = current_index,
				end_index = current_index + string.len(current_value) + string.len(separator)
			})
		elseif index == current_level + 1 and pending then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_PENDING,
				start_index = current_index,
				end_index = current_index + string.len(current_value)
			})
		end

		macro = macro .. current_value

		if index ~= #upgrade_values then
			macro = macro .. separator
		end

		current_index = current_index + string.len(current_value) + string.len(separator)
	end

	table.insert(color_changes, 1, {
		state = ExperienceGui.STAT_LEVEL_INACTIVE,
		start_index = starting_index,
		end_index = starting_index + string.len(macro)
	})

	macros.PERCENTAGE = macro
	starting_index = string:find("$SECONDS;") + string.len(macro) - 13
	current_index = starting_index
	macro = ""

	for index, value in pairs(upgrade_values) do
		local current_value = string.format("%.0f", value[2])

		if index <= current_level then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_ACTIVE,
				start_index = current_index,
				end_index = current_index + string.len(current_value) + string.len(separator)
			})
		elseif index == current_level + 1 and pending then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_PENDING,
				start_index = current_index,
				end_index = current_index + string.len(current_value)
			})
		end

		macro = macro .. current_value

		if index ~= #upgrade_values then
			macro = macro .. separator
		end

		current_index = current_index + string.len(current_value) + string.len(separator)
	end

	table.insert(color_changes, 1, {
		state = ExperienceGui.STAT_LEVEL_INACTIVE,
		start_index = starting_index,
		end_index = starting_index + string.len(macro)
	})

	macros.SECONDS = macro
end

function ExperienceGui:_prepare_upgrade_stats_type_multiplier(string, current_level, pending, upgrade_tweak_data, macros, color_changes)
	local upgrade_values = tweak_data.upgrades.values[upgrade_tweak_data.upgrade.category][upgrade_tweak_data.upgrade.upgrade]
	local starting_index = string:find("$PERCENTAGE;") - 1
	local current_index = starting_index
	local macro = ""
	local separator = " / "

	for index, value in pairs(upgrade_values) do
		local current_value = string.format("%.0f%%", (value - 1) * 100)

		if index <= current_level then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_ACTIVE,
				start_index = current_index,
				end_index = current_index + string.len(current_value) + string.len(separator)
			})
		elseif index == current_level + 1 and pending then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_PENDING,
				start_index = current_index,
				end_index = current_index + string.len(current_value)
			})
		end

		macro = macro .. current_value

		if index ~= #upgrade_values then
			macro = macro .. separator
		end

		current_index = current_index + string.len(current_value) + string.len(separator)
	end

	table.insert(color_changes, 1, {
		state = ExperienceGui.STAT_LEVEL_INACTIVE,
		start_index = starting_index,
		end_index = starting_index + string.len(macro)
	})

	macros.PERCENTAGE = macro
end

function ExperienceGui:_prepare_upgrade_stats_type_multiplier_reductive_string(string, current_level, pending, upgrade_tweak_data, macros, color_changes)
	local upgrade_values = tweak_data.upgrades.values[upgrade_tweak_data.upgrade.category][upgrade_tweak_data.upgrade.upgrade]
	local starting_index = string:find("$PERCENTAGE;") - 1
	local current_index = starting_index
	local macro = ""
	local separator = " / "

	for index, value in pairs(upgrade_values) do
		local current_value = string.format("%.0f%%", math.abs(1 - 1 / value) * 100)

		if index <= current_level then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_ACTIVE,
				start_index = current_index,
				end_index = current_index + string.len(current_value) + string.len(separator)
			})
		elseif index == current_level + 1 and pending then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_PENDING,
				start_index = current_index,
				end_index = current_index + string.len(current_value)
			})
		end

		macro = macro .. current_value

		if index ~= #upgrade_values then
			macro = macro .. separator
		end

		current_index = current_index + string.len(current_value) + string.len(separator)
	end

	table.insert(color_changes, 1, {
		state = ExperienceGui.STAT_LEVEL_INACTIVE,
		start_index = starting_index,
		end_index = starting_index + string.len(macro)
	})

	macros.PERCENTAGE = macro
end

function ExperienceGui:_prepare_upgrade_stats_type_reductive_multiplier(string, current_level, pending, upgrade_tweak_data, macros, color_changes)
	local upgrade_values = tweak_data.upgrades.values[upgrade_tweak_data.upgrade.category][upgrade_tweak_data.upgrade.upgrade]
	local starting_index = string:find("$PERCENTAGE;") - 1
	local current_index = starting_index
	local macro = ""
	local separator = " / "

	for index, value in pairs(upgrade_values) do
		local current_value = string.format("%.0f%%", (1 - value) * 100)

		if index <= current_level then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_ACTIVE,
				start_index = current_index,
				end_index = current_index + string.len(current_value) + string.len(separator)
			})
		elseif index == current_level + 1 and pending then
			table.insert(color_changes, {
				state = ExperienceGui.STAT_LEVEL_PENDING,
				start_index = current_index,
				end_index = current_index + string.len(current_value)
			})
		end

		macro = macro .. current_value

		if index ~= #upgrade_values then
			macro = macro .. separator
		end

		current_index = current_index + string.len(current_value) + string.len(separator)
	end

	table.insert(color_changes, 1, {
		state = ExperienceGui.STAT_LEVEL_INACTIVE,
		start_index = starting_index,
		end_index = starting_index + string.len(macro)
	})

	macros.PERCENTAGE = macro
end

function ExperienceGui:_refresh_stats(additional_hover_pending_skill)
	local character_class = managers.skilltree:get_character_profile_class()
	local applied_skills = managers.skilltree:get_character_skilltree()
	local skills_applied = {}

	for level_index, level in pairs(applied_skills) do
		for skill_index, skill in ipairs(level) do
			if skill.active then
				table.insert(skills_applied, skill.skill_name)
			end
		end
	end

	local selected_nodes = self._skilltrack_progress_bar:get_selected_nodes()
	local pending_skills = {}

	for level_index, skill_node in pairs(selected_nodes) do
		table.insert(pending_skills, skill_node.skill)
	end

	if additional_hover_pending_skill then
		table.insert(pending_skills, additional_hover_pending_skill)
	end

	local stats = managers.skilltree:calculate_stats(character_class, skills_applied, pending_skills)

	self._health_stat:set_value(string.format("%.0f", stats.health.base))
	self._health_stat:set_value_delta(math.round(stats.health.pending))
	self._speed_stat:set_value(string.format("%.0f", stats.speed.base))
	self._speed_stat:set_value_delta(math.round(stats.speed.pending))
	self._stamina_stat:set_value(string.format("%.0f", stats.stamina.base))
	self._stamina_stat:set_value_delta(math.round(stats.stamina.pending))
end

function ExperienceGui:on_skilltree_selection_changed()
	local selected_nodes = self._skilltrack_progress_bar:get_selected_nodes()
	local selected_quantity = 0

	for _, _ in pairs(selected_nodes) do
		selected_quantity = selected_quantity + 1
	end

	Application:debug("[ExperienceGui:on_skilltree_selection_changed()] selected_quantity", selected_quantity)

	if selected_quantity == 0 then
		self._apply_button:animate_hide()
		self._clear_button:animate_hide()
		self:bind_controller_inputs_initial_state()
	elseif selected_quantity >= 1 then
		self._apply_button:animate_show()
		self._clear_button:animate_show()
		self:bind_controller_inputs_apply_state()
	end

	self:_refresh_stats()
end

function ExperienceGui:on_click_apply_callback(button_data)
	local selection_valid = self._skilltrack_progress_bar:is_selection_valid()

	if not selection_valid then
		managers.menu:show_skill_selection_invalid_dialog()

		return
	end

	local confirm_callback = callback(self, self, "on_skill_acquisition_confirmed")

	managers.menu:show_skill_selection_confirm_dialog({
		yes_callback = confirm_callback
	})
end

function ExperienceGui:on_click_respec_callback(button_data)
	local dialog_params = {
		gold = managers.gold_economy:respec_cost_string(),
		callback_yes = callback(self, self, "do_respec")
	}

	managers.menu:show_respec_dialog(dialog_params)
end

function ExperienceGui:on_click_clear_callback(button_data)
	self._skilltrack_progress_bar:clear_selection()
	self:on_skilltree_selection_changed()
end

function ExperienceGui:on_skill_acquisition_confirmed()
	local selected_skills = self._skilltrack_progress_bar:get_selected_nodes()

	managers.hud._sound_source:post_event("skill_confirm")

	for _, skill in pairs(selected_skills) do
		managers.skilltree:activate_skill_by_index(skill.level, skill.index, skill.skill, true)
	end

	self._skilltrack_progress_bar:apply_selected_skills()
	self._apply_button:animate_hide()
	self._clear_button:animate_hide()
	self:bind_controller_inputs_initial_state()
	self:_calculate_respec_visibility()
	managers.player:sync_upgrades()
	self:_refresh_stats()
	managers.player:replenish_player_weapons()
end

function ExperienceGui:_get_character_skilltree()
	local skill_tree = managers.skilltree:get_character_skilltree()
	local tree = {}
	local last_skill_level = {
		nodes = {}
	}

	for level, skills in ipairs(skill_tree) do
		local skill_level = {
			points_needed = managers.experience:get_total_xp_for_level(skills.level_required),
			nodes = {}
		}

		for index, skill_item in ipairs(skills) do
			local node = {}
			local skill = tweak_data.skilltree.skills[skill_item.skill_name]
			node.value = {
				skill = skill_item.skill_name,
				skill_title = skill.name_id,
				skill_description = skill.desc_id
			}
			node.state = skill_item.active and "active" or "inactive"
			node.parents = {}

			for i = 1, #last_skill_level.nodes do
				table.insert(node.parents, i)
			end

			table.insert(skill_level.nodes, node)
		end

		table.insert(tree, skill_level)

		last_skill_level = skill_level
	end

	return tree
end

function ExperienceGui:data_source_branching_progress_bar()
	return self:_get_character_skilltree()
end

function ExperienceGui:close()
	if self._closing then
		return
	end

	self._closing = true

	if game_state_machine:current_state_name() == "event_complete_screen" then
		game_state_machine:current_state():continue()
	end

	managers.savefile:save_progress()
	ExperienceGui.super.close(self)
end

function ExperienceGui:bind_controller_inputs_initial_state()
	local have_enough_money = managers.gold_economy:respec_cost() <= managers.gold_economy:current()
	local respec_binding, respec_legend = nil

	if have_enough_money then
		respec_binding = {
			key = Idstring("menu_controller_trigger_left"),
			callback = callback(self, self, "on_click_respec_callback")
		}
		respec_legend = "menu_legend_player_skill_retrain"
	end

	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_move_panel_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_move_panel_right")
		},
		respec_binding
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_player_skill_select",
			"menu_legend_player_skill_shoulder",
			respec_legend
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

function ExperienceGui:bind_controller_inputs_apply_state()
	local have_enough_money = managers.gold_economy:respec_cost() <= managers.gold_economy:current()
	local respec_binding, respec_legend = nil

	if have_enough_money then
		respec_binding = {
			key = Idstring("menu_controller_trigger_left"),
			callback = callback(self, self, "on_click_respec_callback")
		}
		respec_legend = "menu_legend_player_skill_retrain"
	end

	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_move_panel_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_move_panel_right")
		},
		{
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_apply_selected_skills")
		},
		respec_binding
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_player_skill_select",
			"menu_legend_player_skill_shoulder",
			"menu_legend_player_skill_apply",
			respec_legend
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

function ExperienceGui:_on_move_panel_left()
	self._skilltrack_progress_bar:shoulder_move_left()
end

function ExperienceGui:_on_move_panel_right()
	self._skilltrack_progress_bar:shoulder_move_right()
end

function ExperienceGui:_on_apply_selected_skills()
	self:on_click_apply_callback()
end

function ExperienceGui:do_respec()
	managers.skilltree:respec()
	managers.gold_economy:respec()
	self._skilltrack_progress_bar:on_respec()
	self:on_skilltree_selection_changed()
	self:_calculate_respec_visibility()
	managers.savefile:save_game(0)
	managers.player:replenish_player_weapons()
end
