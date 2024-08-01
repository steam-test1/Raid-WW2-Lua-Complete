ExperienceGui = ExperienceGui or class(RaidGuiBase)
ExperienceGui.BUTTON_PADDING_X = 32
ExperienceGui.BUTTON_PADDING_Y = 0
ExperienceGui.DIVIDER_SPACE = 24
ExperienceGui.MAIN_PANEL_Y = 96
ExperienceGui.MAIN_PANEL_H = 768
ExperienceGui.L_PANEL_EQUIPPED_TO_OPTIONS_PADDING = 8
ExperienceGui.R_PANEL_EXP = 82
ExperienceGui.R_PANEL_STATS = 104
ExperienceGui.R_PANEL_PADDING = 4
ExperienceGui.MENU_ANIMATION_DISTANCE = 100

-- Lines 20-25
function ExperienceGui:init(ws, fullscreen_ws, node, component_name)
	ExperienceGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self._ws_panel:stop()
	self._ws_panel:animate(callback(self, self, "_animate_open"))
end

-- Lines 29-69
function ExperienceGui:_layout()
	Application:debug("[NewProficiencies] layout everything...")
	ExperienceGui.super._layout(self)
	self:_layout_title_text()

	local menu_shift = 140
	self._menu_left_side = self._root_panel:panel({
		name = "menu_left_side",
		x = 0,
		layer = 1,
		y = ExperienceGui.MAIN_PANEL_Y,
		w = self._root_panel:w() / 2 - ExperienceGui.DIVIDER_SPACE / 2 - menu_shift,
		h = ExperienceGui.MAIN_PANEL_H
	})
	self._menu_right_side = self._root_panel:panel({
		name = "menu_right_side",
		layer = 1,
		x = self._menu_left_side:w() + ExperienceGui.DIVIDER_SPACE,
		y = ExperienceGui.MAIN_PANEL_Y,
		w = self._root_panel:w() / 2 - ExperienceGui.DIVIDER_SPACE / 2 + menu_shift,
		h = ExperienceGui.MAIN_PANEL_H
	})

	self:_layout_player_stats()
	self:_layout_experience_progress()
	self:_layout_upgrade_information()
	self:_layout_equipped_upgrades()
	self:_layout_equipable_upgrades()
	self:bind_controller_inputs_initial_state()
	self:_check_loyalty_reward()
	Application:debug("[NewProficiencies] done layout!")
end

-- Lines 72-84
function ExperienceGui:_check_loyalty_reward()
	local pending_amount = managers.gold_economy:loyalty_reward_pending(GoldEconomyManager.LOYALTY_SKILL_REWORK)

	if pending_amount then
		managers.gold_economy:grant_loyalty_reward(GoldEconomyManager.LOYALTY_SKILL_REWORK)
		managers.menu:show_loyalty_reward_message("dialog_loyalty_reward_skill_rework", pending_amount)
	end

	pending_amount = managers.gold_economy:loyalty_reward_pending(GoldEconomyManager.LOYALTY_REMOVED_SKILL)

	if pending_amount then
		managers.gold_economy:grant_loyalty_reward(GoldEconomyManager.LOYALTY_REMOVED_SKILL)
		managers.menu:show_loyalty_reward_message("dialog_loyalty_reward_skill_removed", pending_amount)
	end
end

-- Lines 88-91
function ExperienceGui:_layout_title_text()
	local character_class = managers.skilltree:get_character_profile_class() or "BROKEN"

	self._node.components.raid_menu_header:set_screen_name_raw(self:translate("menu_skill_screen_title", true) .. " - " .. self:translate("skill_class_" .. character_class .. "_name", true))
end

-- Lines 95-184
function ExperienceGui:_layout_equipped_upgrades()
	Application:debug("[NewProficiencies] _layout_equipped_upgrades")

	local unlocked_warcry_slots = managers.skilltree.get_unlocked_warcry_slots()
	local unlocked_boost_slots = managers.skilltree.get_unlocked_boost_slots()
	local unlocked_talent_slots = managers.skilltree.get_unlocked_talent_slots()
	local total_icons = #unlocked_warcry_slots + #unlocked_boost_slots + #unlocked_talent_slots
	local padding = 8
	local total_blocks_w = self._menu_left_side:w() - padding * (total_icons - 1)
	local block_size = math.floor(total_blocks_w / total_icons * 2 + 0.5)
	block_size = math.floor(block_size / 2 - total_icons * 0.025)
	local x = 0
	local slot_i = 1
	self._toprow_icons = {}

	-- Lines 120-166
	local function make_skill_button(unlocked_slot_list, slot_type)
		self._toprow_icons[slot_type] = self._toprow_icons[slot_type] or {}

		for i, unlocked in ipairs(unlocked_slot_list) do
			local slot_type_str = SkillTreeTweakData.TYPE_TRANSLATIONS[slot_type]
			local level_lock, color = nil
			local color_icon = Color.white
			local icon = "skill_slot_unlocked"

			if slot_type == SkillTreeTweakData.TYPE_WARCRY then
				level_lock = managers.skilltree.get_skill_warcry_level_lock(i)
			elseif slot_type == SkillTreeTweakData.TYPE_BOOSTS then
				level_lock = managers.skilltree.get_skill_boost_level_lock(i)
			elseif slot_type == SkillTreeTweakData.TYPE_TALENT then
				level_lock = managers.skilltree.get_skill_talent_level_lock(i)
			end

			if unlocked then
				color = tweak_data.gui.colors["raid_skill_" .. slot_type_str] or Color.red
			else
				color = tweak_data.gui.colors.raid_skill_locked
			end

			local grid_item = self._menu_left_side:create_custom_control(RaidGUIControlButtonSkillTiny, {
				text = "",
				y = 4,
				layer = 1,
				name = "equippped_slot_" .. slot_type_str .. i,
				x = x,
				w = block_size,
				h = block_size,
				icon = icon,
				locked = not unlocked,
				color = color,
				color_edge = color * 0.5,
				color_icon = color_icon,
				level_lock = level_lock,
				on_mouse_enter_callback = callback(self, self, "on_equipped_selected_upgrade"),
				on_click_callback = callback(self, self, "on_equipped_clicked_upgrade")
			})

			table.insert(self._toprow_icons[slot_type], grid_item)

			x = math.floor(x + block_size + padding)
			slot_i = slot_i + 1
		end
	end

	make_skill_button(unlocked_warcry_slots, SkillTreeTweakData.TYPE_WARCRY)
	make_skill_button(unlocked_boost_slots, SkillTreeTweakData.TYPE_BOOSTS)
	make_skill_button(unlocked_talent_slots, SkillTreeTweakData.TYPE_TALENT)
	self:_update_equipped_upgrades()

	local backgrounds_chat_bg = tweak_data.gui.icons.backgrounds_chat_bg
	self._equipped_upgrades_area = self._menu_left_side:bitmap({
		name = "_temp_equipped_upgrades",
		alpha = 0.8,
		layer = 0,
		w = self._menu_left_side:w(),
		h = block_size + 8,
		texture = backgrounds_chat_bg.texture,
		texture_rect = backgrounds_chat_bg.texture_rect
	})
end

-- Lines 187-192
function ExperienceGui:on_equipped_selected_upgrade(item_data)
	if item_data.skill_data and item_data.skill_id then
		self._upgrade_information:set_skill(item_data.skill_data, item_data.skill_id)
	end
end

-- Lines 195-202
function ExperienceGui:on_equipped_clicked_upgrade(item_idx, item_data)
	if not item_data.skill_data and not item_data.skill_data.upgrades_type and not item_data.skill_id then
		return
	end

	self:_set_skill_equipped(item_data.skill_data.upgrades_type, item_data.skill_id, false)
end

-- Lines 205-232
function ExperienceGui:_update_equipped_upgrades()
	if not self._toprow_icons then
		Application:error("[ExperienceGui:_update_equipped_upgrades] Toprow icon inputs are not ready!")

		return
	end

	for slot_type, skills in ipairs(managers.skilltree:get_skills_applied_grouped()) do
		if self._toprow_icons[slot_type] then
			local skills_keymap = table.map_keys(skills)

			for i, toprow_child in ipairs(self._toprow_icons[slot_type]) do
				local key = skills_keymap[i]
				local skill_data = nil

				if key then
					local skill = tweak_data.skilltree.skills[key]
					skill_data = self:_buttonize_skill_data(skill, key)
					skill_data.tag_color = tweak_data.skilltree.skill_category_colors[slot_type]
				end

				toprow_child:update_skill_data(skill_data, key)
			end
		end
	end
end

-- Lines 236-300
function ExperienceGui:_layout_equipable_upgrades()
	Application:debug("[NewProficiencies] _layout_equipable_upgrades")

	local y = self._equipped_upgrades_area:bottom() + ExperienceGui.L_PANEL_EQUIPPED_TO_OPTIONS_PADDING
	local h = self._menu_left_side:h() - y
	local backgrounds_chat_bg = tweak_data.gui.icons.backgrounds_chat_bg
	self._equipable_upgrades_background = self._menu_left_side:image({
		name = "grid_item_icon_sprite",
		alpha = 0.5,
		layer = -1,
		y = y,
		w = self._menu_left_side:w(),
		h = h,
		texture = backgrounds_chat_bg.texture,
		texture_rect = backgrounds_chat_bg.texture_rect
	})
	local item_size = 90
	local equippable_upgrades_scrollable_area_params = {
		scrollbar_offset = 8,
		name = "equippable_upgrades_scrollable_area_params",
		y = y,
		w = self._menu_left_side:w(),
		h = h,
		scroll_step = item_size * 0.8
	}
	self._equippable_upgrades_scrollable_area = self._menu_left_side:scrollable_area(equippable_upgrades_scrollable_area_params)
	local equippable_upgrades_params = {
		name = "equippable_upgrades_grid",
		w = equippable_upgrades_scrollable_area_params.w,
		h = equippable_upgrades_scrollable_area_params.h,
		scrollable_area_ref = self._equippable_upgrades_scrollable_area,
		grid_params = {
			scroll_marker_w = 16,
			vertical_spacing = 12,
			on_click_callback = callback(self, self, "on_item_clicked_upgrade"),
			on_select_callback = callback(self, self, "on_item_selected_upgrade"),
			data_source_callback = callback(self, self, "data_source_upgrades")
		},
		item_params = {
			key_value_field = "key_name",
			grid_item_tag_color = "tag_color",
			grid_item_icon = "grid_icon",
			item_w = item_size,
			item_h = item_size,
			icon_size_on = item_size * 0.85,
			icon_size_off = item_size * 0.65,
			selected_marker_w = item_size,
			selected_marker_h = item_size,
			row_class = RaidGUIControlGridItemSkill
		}
	}
	self._equippable_upgrades = self._equippable_upgrades_scrollable_area:get_panel():categorized_grid(equippable_upgrades_params)

	self._equippable_upgrades_scrollable_area:setup_scroll_area()
	self._equippable_upgrades:set_selected(true)
end

-- Lines 303-315
function ExperienceGui:on_item_clicked_upgrade(data)
	Application:debug("[ExperienceGui:on_item_clicked_upgrade] on_item_clicked_upgrade", data.key_name, "is active:", data.active)

	if data.status == RaidGUIControlGridItemSkill.STATE_PURCHASABLE then
		self:_on_upgrade_purchased(data)
	else
		local selected_item = self._equippable_upgrades:selected_grid_item()
		local data = selected_item:get_data()

		self:_set_skill_equipped(data.upgrades_type, data.key_name, data.active)
	end
end

-- Lines 318-327
function ExperienceGui:_set_skill_equipped(upgrades_type, skill_id, equipped)
	managers.skilltree:toggle_skill_by_id(upgrades_type, skill_id, true, equipped)
	self:_refresh_stats()
	self._equippable_upgrades:refresh_category(upgrades_type)
	managers.player:on_upgrades_changed()
end

-- Lines 329-336
function ExperienceGui:_on_upgrade_purchased(item_data)
	local key_field_name = "key_name"

	self._upgrade_information:skill_purchased(item_data)
	self._equippable_upgrades:refresh_data()
	self._equippable_upgrades:select_grid_item_by_key_value({
		dont_fire_select_callback = true,
		key = key_field_name,
		value = item_data[key_field_name]
	})
end

-- Lines 339-350
function ExperienceGui:on_item_selected_upgrade(item_idx, item_data)
	if not item_data then
		Application:error("[ExperienceGui:on_item_selected_upgrade] Bad item_data!")

		return
	end

	self._upgrade_information:set_skill(item_data)
end

-- Lines 354-417
function ExperienceGui:data_source_upgrades()
	local my_class = managers.skilltree:get_character_profile_class()
	local skills_organised = tweak_data.skilltree:get_skills_organised(my_class)
	local categories = {}

	-- Lines 362-370
	local function sort_func(a, b)
		if a.bought ~= b.bought then
			return a.bought
		end

		return a.level_required < b.level_required
	end

	-- Lines 372-409
	local function fill_category(skill_type, title_id)
		local skills = skills_organised[skill_type]
		local items = {}
		local unlocked = 0

		for id, skill in pairs(skills) do
			local skill_data = self:_buttonize_skill_data(skill, id)

			if skill_data then
				skill_data.tag_color = tweak_data.skilltree.skill_category_colors[skill_type]
				skill_data.status = managers.skilltree:get_skill_button_status(skill_type, id)

				if skill_data.status == RaidGUIControlGridItemSkill.STATE_APPLIED or skill_data.status == RaidGUIControlGridItemSkill.STATE_NORMAL then
					unlocked = unlocked + 1
				else
					skill_data.bought = false
				end

				table.insert(items, skill_data)
			end
		end

		if #items > 0 then
			table.sort(items, sort_func)

			local category_data = {
				name = skill_type,
				items = items,
				title = utf8.to_upper(self:translate(title_id)) .. " - " .. unlocked .. "/" .. #items
			}

			table.insert(categories, category_data)
		end
	end

	fill_category(SkillTreeTweakData.TYPE_WARCRY, "menu_skills_category_warcry")
	fill_category(SkillTreeTweakData.TYPE_BOOSTS, "menu_skills_category_boost")
	fill_category(SkillTreeTweakData.TYPE_TALENT, "menu_skills_category_talent")

	return categories
end

-- Lines 424-458
function ExperienceGui:_buttonize_skill_data(data, id)
	if not data then
		Application:warn("[ExperienceGui:_buttonize_skill_data] get_skill_data func didnt have valid data", data, id)

		return {}
	end

	local char_skill = managers.skilltree:get_character_skill(data.upgrades_type, id)
	local skill_purchased = managers.skilltree:is_skill_purchased(id)
	local t = {
		key_name = id,
		grid_icon = tweak_data.skilltree:get_skill_icon_tiered(id),
		name_id = data.name_id,
		description_id = data.desc_id,
		upgrades_desc = data.upgrades_desc,
		stat_desc_id = data.stat_desc_id,
		upgrades_type = data.upgrades_type,
		class_lock = data.class_lock,
		gold_requirements = data.gold_requirements or 0,
		level_required = data.level_required or 0,
		exp_requirements = data.exp_requirements or 0,
		bought = skill_purchased or data.default_unlocked or false,
		active = char_skill and char_skill.active or false,
		exp_tier = char_skill and char_skill.exp_tier or 1,
		exp_progression = char_skill and char_skill.exp_progression or 0
	}

	return t
end

-- Lines 464-492
function ExperienceGui:_layout_player_stats()
	Application:debug("[NewProficiencies] _layout_equipable_upgrades")

	local h = ExperienceGui.R_PANEL_STATS
	self._player_stats_panel = self._menu_right_side:panel({
		name = "player_stats_panel",
		w = self._menu_right_side:w(),
		h = h
	})

	self._player_stats_panel:set_bottom(self._menu_right_side:h())

	self._player_stats = self._player_stats_panel:player_stats({
		name = "player_stats",
		w = self._player_stats_panel:w(),
		h = self._player_stats_panel:h(),
		data_source_callback = callback(self, self, "data_source_stats"),
		item_params = {
			color = tweak_data.gui.colors.raid_dark_grey,
			value_font_size = tweak_data.gui.font_sizes.menu_list,
			font_size = tweak_data.gui.font_sizes.size_24
		}
	})

	self:_refresh_stats()
end

-- Lines 494-536
function ExperienceGui:data_source_stats()
	local t = {}

	table.insert(t, {
		text_id = "character_stats_health_label",
		name = "health"
	})
	table.insert(t, {
		text_id = "character_stats_stamina_label",
		name = "stamina"
	})
	table.insert(t, {
		format_value = "%.2g/s",
		name = "stamina_regen",
		text_id = "character_stats_stamina_regen_label"
	})
	table.insert(t, {
		format_value = "%.2gs",
		name = "stamina_delay",
		text_id = "character_stats_stamina_delay_label"
	})
	table.insert(t, {
		text_id = "character_stats_speed_walk_label",
		name = "speed_walk"
	})
	table.insert(t, {
		text_id = "character_stats_speed_run_label",
		name = "speed_run"
	})
	table.insert(t, {
		text_id = "character_stats_carry_limit_label",
		name = "carry_limit"
	})

	return t
end

-- Lines 538-543
function ExperienceGui:_refresh_stats()
	local character_class = managers.skilltree:get_character_profile_class()

	self._player_stats:calculate_stats(character_class)
	self:_update_equipped_upgrades()
end

-- Lines 547-573
function ExperienceGui:_layout_experience_progress()
	Application:debug("[NewProficiencies] _layout_equipable_upgrades")

	local h = ExperienceGui.R_PANEL_EXP
	local y = self._player_stats_panel:y() - h
	local backgrounds_chat_bg = tweak_data.gui.icons.backgrounds_chat_bg
	self._experience_progress_background = self._menu_right_side:bitmap({
		name = "grid_item_icon_sprite",
		layer = -1,
		y = y,
		w = self._menu_right_side:w(),
		h = h,
		texture = backgrounds_chat_bg.texture,
		texture_rect = backgrounds_chat_bg.texture_rect
	})
	self._progress_bar = self._menu_right_side:create_custom_control(RaidGUIControlSkilltreeProgressBar, {
		name = "progress_bar",
		horizontal_padding = 15,
		w = self._menu_right_side:w() - 100,
		h = h - 12
	})

	self._progress_bar:set_center(self._experience_progress_background:center())
	self._progress_bar:update_progress()
end

-- Lines 577-587
function ExperienceGui:_layout_upgrade_information()
	Application:debug("[NewProficiencies] _layout_equipable_upgrades")

	local h = self._experience_progress_background:y() - ExperienceGui.R_PANEL_PADDING
	self._upgrade_information = self._menu_right_side:create_custom_control(RaidGUIControlSkillDetails, {
		layer = 1,
		w = self._menu_right_side:w(),
		h = h
	})
end

-- Lines 592-593
function ExperienceGui:on_click_respec_callback()
end

-- Lines 597-609
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

-- Lines 616-640
function ExperienceGui:bind_controller_inputs_initial_state()
	Application:debug("[NewProficiencies] bind_controller_inputs_initial_state")

	local legend = {
		controller = {
			"menu_legend_back",
			"menu_legend_player_skill_select"
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

-- Lines 643-649
function ExperienceGui:confirm_pressed()
	local selected_item = self._equippable_upgrades:selected_grid_item()

	selected_item:activate()

	return true
end

-- Lines 655-676
function ExperienceGui:_animate_open()
	local duration = 0.15
	local t = 0
	local right_x = self._menu_left_side:w() + ExperienceGui.DIVIDER_SPACE

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in_out(t, 0, 1, duration)

		self._ws_panel:set_alpha(current_alpha)

		local current_offset = Easing.quadratic_out(t, ExperienceGui.MENU_ANIMATION_DISTANCE, -ExperienceGui.MENU_ANIMATION_DISTANCE, duration)

		self._menu_left_side:set_x(current_offset)
		self._menu_right_side:set_x(right_x - current_offset)
	end

	self._ws_panel:set_alpha(1)
	self._menu_left_side:set_x(0)
	self._menu_right_side:set_x(right_x)
end

-- Lines 678-697
function ExperienceGui:_animate_close()
	local duration = 0.15
	local t = 0
	local right_x = self._menu_left_side:w() + ExperienceGui.DIVIDER_SPACE

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in_out(t, 1, -1, duration)

		self._ws_panel:set_alpha(current_alpha)

		local current_offset = Easing.quadratic_in(t, 0, ExperienceGui.MENU_ANIMATION_DISTANCE, duration)

		self._menu_left_side:set_x(current_offset)
		self._menu_right_side:set_x(right_x - current_offset)
	end

	self:_close()
end
