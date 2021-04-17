RaidGUIControlWeaponSkills = RaidGUIControlWeaponSkills or class(RaidGUIControl)
RaidGUIControlWeaponSkills.ROW_HEIGHT = 96
RaidGUIControlWeaponSkills.FIRST_ROW_Y = 39
RaidGUIControlWeaponSkills.ROMAN_NUMERALS = {
	"I",
	"II",
	"III",
	"IV"
}
RaidGUIControlWeaponSkills.TIER_LABEL_ACTIVE_ALPHA = 1
RaidGUIControlWeaponSkills.TIER_LABEL_INACTIVE_ALPHA = 0.6

function RaidGUIControlWeaponSkills:init(parent, params)
	RaidGUIControlWeaponSkills.super.init(self, parent, params)

	self._object = self._panel:panel(params)

	self:_create_items()
	self:_create_tier_labels()

	self._temp_weapon_points = 0
	self._temp_skills = {}
	RaidGUIControlWeaponSkills.gui = self
	self._on_selected_weapon_skill_callback = params.on_selected_weapon_skill_callback
	self._on_unselected_weapon_skill_callback = params.on_unselected_weapon_skill_callback
end

function RaidGUIControlWeaponSkills:_create_items()
	self._rows = {}
	local row_params = {
		x = 0,
		y = RaidGUIControlWeaponSkills.FIRST_ROW_Y,
		h = RaidGUIControlWeaponSkills.ROW_HEIGHT,
		layer = self._object:layer() + 1,
		on_mouse_enter_callback = self._params.on_mouse_enter_callback,
		on_mouse_exit_callback = self._params.on_mouse_exit_callback,
		on_selected_weapon_skill_callback = callback(self, self, "on_selected_weapon_skill_callback"),
		on_unselected_weapon_skill_callback = callback(self, self, "on_unselected_weapon_skill_callback"),
		get_available_points_callback = callback(self, self, "get_available_points"),
		on_click_weapon_skill_callback = self._params.on_click_weapon_skill_callback,
		toggle_select_item_callback = callback(self, self, "toggle_select_item_callback")
	}

	for i_skill = 1, WeaponSkillsTweakData.MAX_SKILLS_IN_TIER do
		local row = self._object:create_custom_control(RaidGUIControlWeaponSkillRow, row_params)
		row_params.y = row_params.y + RaidGUIControlWeaponSkills.ROW_HEIGHT

		table.insert(self._rows, row)
	end
end

function RaidGUIControlWeaponSkills:_create_tier_labels()
	local tier_panel_params = {
		h = 30,
		name = "tier_label_panel"
	}
	self._tier_panel = self._object:panel(tier_panel_params)
	self._tier_labels = {}

	for i = 1, #RaidGUIControlWeaponSkills.ROMAN_NUMERALS do
		local text = self:translate("menu_weapons_stats_tier_abbreviation", true) .. RaidGUIControlWeaponSkills.ROMAN_NUMERALS[i]
		local tier_label_params = {
			align = "center",
			vertical = "bottom",
			name = "tier_" .. tostring(i) .. "_label",
			font = tweak_data.gui.fonts.din_compressed,
			font_size = tweak_data.gui.font_sizes.size_24,
			color = tweak_data.gui.colors.raid_white,
			alpha = RaidGUIControlWeaponSkills.TIER_LABEL_ACTIVE_ALPHA,
			text = text
		}
		local tier_label = self._tier_panel:text(tier_label_params)
		local _, _, w, h = tier_label:text_rect()

		tier_label:set_w(w)
		tier_label:set_h(h)
		tier_label:set_y(tier_label:y() - 5)
		tier_label:set_center_x(RaidGUIControlWeaponSkillRow.BUTTON_START_X + self._rows[1]:get_skill_buttons()[1]:w() / 2 + (i - 1) * RaidGUIControlWeaponSkillRow.BUTTON_SPACING)
		table.insert(self._tier_labels, tier_label)
	end
end

function RaidGUIControlWeaponSkills:get_rows()
	return self._rows
end

function RaidGUIControlWeaponSkills:get_temp_points()
	return self._temp_weapon_points
end

function RaidGUIControlWeaponSkills:set_temp_points(value)
	self._temp_weapon_points = value
end

function RaidGUIControlWeaponSkills:get_temp_skills()
	return self._temp_skills
end

function RaidGUIControlWeaponSkills:get_available_points()
	local available_points = managers.weapon_skills:get_available_weapon_skill_points() - self._temp_weapon_points

	return available_points
end

function RaidGUIControlWeaponSkills:set_weapon(weapon_category_id, weapon_id)
	local weapon_skills = managers.weapon_skills:get_weapon_skills(weapon_id)

	if not weapon_skills then
		return
	end

	self._weapon_id = weapon_id
	self._weapon_category_id = weapon_category_id
	self._temp_weapon_points = 0
	self._temp_skills = {}
	local num_tiers = #weapon_skills
	local num_skills = #weapon_skills[num_tiers]

	for i = 1, #self._tier_labels do
		if i <= num_tiers then
			local unlocked = managers.weapon_skills:is_weapon_tier_unlocked(weapon_id, i)

			self._tier_labels[i]:set_alpha(unlocked and RaidGUIControlWeaponSkills.TIER_LABEL_ACTIVE_ALPHA or RaidGUIControlWeaponSkills.TIER_LABEL_INACTIVE_ALPHA)
			self._tier_labels[i]:set_visible(true)
		else
			self._tier_labels[i]:set_visible(false)
		end
	end

	for i_skill, row in ipairs(self._rows) do
		if i_skill <= num_skills then
			row:show()
			row:set_weapon_skill(weapon_id, weapon_skills, i_skill)
		else
			row:hide()
		end
	end
end

function RaidGUIControlWeaponSkills:apply_selected_skills()
	for skill, _ in pairs(self._temp_skills) do
		managers.weapon_skills:activate_skill(skill, self._weapon_category_id)

		if skill.i_tier and skill.i_tier >= 4 then
			managers.statistics:tier_4_weapon_skill_bought(self._weapon_id)
		end
	end

	managers.weapon_skills:set_available_weapon_skill_points(self:get_available_points())
	managers.weapon_skills:update_weapon_skills(self._weapon_category_id, self._weapon_id, "activate")
	managers.player:_internal_load()
	managers.player:local_player():inventory():equip_selection(self._weapon_category_id, true)
	managers.savefile:save_game(Global.savefile_manager.save_progress_slot)
	self:set_weapon(self._weapon_category_id, self._weapon_id)
end

function RaidGUIControlWeaponSkills:mouse_moved(o, x, y)
end

function RaidGUIControlWeaponSkills:highlight_on()
end

function RaidGUIControlWeaponSkills:highlight_off()
end

function RaidGUIControlWeaponSkills:on_selected_weapon_skill_callback(button, data, skip_update_points)
	self._on_selected_weapon_skill_callback(button, data)
end

function RaidGUIControlWeaponSkills:on_unselected_weapon_skill_callback(button, data)
	self._on_unselected_weapon_skill_callback(button, data)
end

function RaidGUIControlWeaponSkills:unacquire_all_temp_skills(weapon_category_id)
	local weapon_category = ""

	if weapon_category_id == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		weapon_category = "primary_weapon"
	elseif weapon_category_id == WeaponInventoryManager.BM_CATEGORY_SECONDARY_ID then
		weapon_category = "secondary_weapon"
	end

	local upgrades_data = tweak_data.upgrades.values[weapon_category]

	for upgrade_name, data in pairs(upgrades_data) do
		local upgrade_level = managers.player:upgrade_level(weapon_category, upgrade_name, 0)

		if upgrade_level > 0 then
			managers.weapon_skills:update_weapon_skill_by_upgrade_name(weapon_category, upgrade_name, upgrade_level, WeaponSkillsManager.UPGRADE_ACTION_DEACTIVATE)
		end
	end

	for _, skill_row in ipairs(self._rows) do
		for _, skill_button in ipairs(skill_row:get_skill_buttons()) do
			if skill_button:get_state() == RaidGUIControlButtonWeaponSkill.STATE_SELECTED and skill_button:visible() then
				skill_button:set_state(RaidGUIControlButtonWeaponSkill.STATE_NORMAL)
			end
		end
	end

	for _, skill_row in ipairs(self._rows) do
		local upgrade_level = 0
		local upgrade_name = ""

		for _, skill_button in ipairs(skill_row:get_skill_buttons()) do
			if skill_button:get_state() == RaidGUIControlButtonWeaponSkill.STATE_ACTIVE and skill_button:visible() then
				local skill_button_data = skill_button:get_data()

				if upgrade_level < skill_button_data.value.value then
					upgrade_level = skill_button_data.value.value
					upgrade_name = skill_button_data.value.skill_name
				end
			end
		end

		if upgrade_level > 0 then
			local upgrade_name = managers.weapon_skills:get_upgrade_name_from_raid_stat_name(upgrade_name)

			managers.weapon_skills:update_weapon_skill_by_upgrade_name(weapon_category, upgrade_name, upgrade_level, WeaponSkillsManager.UPGRADE_ACTION_ACTIVATE)
		end
	end
end

function RaidGUIControlWeaponSkills:set_selected(value, dont_trigger_selected_callback)
	self._selected = value
	self._selected_row_idx = 1
	self._selected_button_idx = 1
	local current_skill_button = self:get_current_weapon_skill_button()

	current_skill_button:select_skill(dont_trigger_selected_callback)
end

function RaidGUIControlWeaponSkills:toggle_select_item_callback(select_flag, row_idx, button_idx)
	if select_flag then
		local current_skill_button = self:get_current_weapon_skill_button()
		local new_skill_button = self:get_weapon_skill_button(row_idx, button_idx)

		if current_skill_button ~= new_skill_button then
			current_skill_button:unselect_skill()
		end

		new_skill_button:select_skill()

		self._selected_row_idx = row_idx
		self._selected_button_idx = button_idx

		self:_consume_breadcrumb(button_idx, row_idx)
	elseif not select_flag then
		local unselect_skill_button = self:get_weapon_skill_button(row_idx, button_idx)

		if unselect_skill_button then
			unselect_skill_button:unselect_skill()
		end

		self._selected_row_idx = row_idx
		self._selected_button_idx = button_idx
	end
end

function RaidGUIControlWeaponSkills:_consume_breadcrumb(tier_index, skill_index)
	local weapon_category = managers.weapon_inventory:get_weapon_category_name_by_bm_category_id(self._weapon_category_id)

	managers.breadcrumb:remove_breadcrumb(BreadcrumbManager.CATEGORY_WEAPON_UPGRADE, {
		weapon_category,
		self._weapon_id,
		tier_index,
		skill_index
	})
end

function RaidGUIControlWeaponSkills:get_current_weapon_skill_button()
	return self:get_weapon_skill_button(self._selected_row_idx, self._selected_button_idx)
end

function RaidGUIControlWeaponSkills:get_weapon_skill_button(i_row, i_button)
	local skill_button = self._rows[i_row]:get_skill_buttons()[i_button]

	if skill_button and skill_button:visible() and self._rows[i_row]:visible() then
		return skill_button
	else
		return nil
	end
end

function RaidGUIControlWeaponSkills:_select_weapon_skill_button(weapon_skill_button)
	weapon_skill_button:select_skill()
end

function RaidGUIControlWeaponSkills:_unselect_weapon_skill_button(weapon_skill_button)
	weapon_skill_button:unselect_skill()
end

function RaidGUIControlWeaponSkills:move_up()
	self._move_controller_callback = callback(self, self, "_select_up_skill_button")

	return self:_move_controller()
end

function RaidGUIControlWeaponSkills:move_down()
	self._move_controller_callback = callback(self, self, "_select_down_skill_button")

	return self:_move_controller()
end

function RaidGUIControlWeaponSkills:move_left()
	self._move_controller_callback = callback(self, self, "_select_left_skill_button")

	return self:_move_controller()
end

function RaidGUIControlWeaponSkills:move_right()
	self._move_controller_callback = callback(self, self, "_select_right_skill_button")

	return self:_move_controller()
end

function RaidGUIControlWeaponSkills:_move_controller()
	if self._selected then
		local current_skill_button = self:get_current_weapon_skill_button()
		local new_skill_button = self._move_controller_callback()

		if current_skill_button and new_skill_button then
			if not new_skill_button:visible() then
				return
			end

			self:_unselect_weapon_skill_button(current_skill_button)
			self:_select_weapon_skill_button(new_skill_button)
		end

		return true
	end
end

function RaidGUIControlWeaponSkills:_select_up_skill_button()
	self._new_selected_row_idx = self._selected_row_idx - 1

	if self._new_selected_row_idx <= 0 then
		self._selected_row_idx = 1
	else
		self._selected_row_idx = self._new_selected_row_idx
	end

	local skill_button = nil

	for counter = self._selected_button_idx, #self._rows[self._selected_row_idx]:get_skill_buttons() do
		skill_button = self:get_weapon_skill_button(self._selected_row_idx, counter)

		if skill_button and skill_button:visible() then
			self._selected_button_idx = counter

			return skill_button
		end
	end

	return skill_button
end

function RaidGUIControlWeaponSkills:_select_down_skill_button()
	self._new_selected_row_idx = self._selected_row_idx + 1

	if self._new_selected_row_idx > #self._rows then
		self._selected_row_idx = #self._rows
	else
		self._selected_row_idx = self._new_selected_row_idx
	end

	local skill_button = nil

	for counter = self._selected_button_idx, #self._rows[self._selected_row_idx]:get_skill_buttons() do
		skill_button = self:get_weapon_skill_button(self._selected_row_idx, counter)

		if skill_button and skill_button:visible() then
			self._selected_button_idx = counter

			return skill_button
		end
	end

	if not skill_button then
		self._selected_row_idx = self._selected_row_idx - 1
	end

	return skill_button
end

function RaidGUIControlWeaponSkills:_select_left_skill_button()
	self._new_selected_button_idx = self._selected_button_idx - 1
	local skill_point = self:get_weapon_skill_button(self._selected_row_idx, self._new_selected_button_idx)

	if skill_point then
		self._selected_button_idx = self._new_selected_button_idx

		return skill_point
	else
		return self:get_weapon_skill_button(self._selected_row_idx, self._selected_button_idx)
	end
end

function RaidGUIControlWeaponSkills:_select_right_skill_button()
	self._new_selected_button_idx = self._selected_button_idx + 1

	if self._new_selected_button_idx > #self._rows[self._selected_row_idx]:get_skill_buttons() then
		self._selected_button_idx = #self._rows[self._selected_row_idx]:get_skill_buttons()
		self._new_selected_button_idx = self._selected_button_idx + 1
	elseif self:get_weapon_skill_button(self._selected_row_idx, self._new_selected_button_idx) then
		self._selected_button_idx = self._new_selected_button_idx
	end

	return self:get_weapon_skill_button(self._selected_row_idx, self._selected_button_idx)
end

function RaidGUIControlWeaponSkills:confirm_pressed()
	self._selected_skill_button = self:get_current_weapon_skill_button()

	self._selected_skill_button.on_mouse_released(self._selected_skill_button)
end
