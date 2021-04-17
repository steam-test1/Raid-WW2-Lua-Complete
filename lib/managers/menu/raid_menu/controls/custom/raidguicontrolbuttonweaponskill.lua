RaidGUIControlButtonWeaponSkill = RaidGUIControlButtonWeaponSkill or class(RaidGUIControlButton)
RaidGUIControlButtonWeaponSkill.STATE_NORMAL = "state_normal"
RaidGUIControlButtonWeaponSkill.STATE_CHALLENGE_ACTIVE = "state_challenge_active"
RaidGUIControlButtonWeaponSkill.STATE_SELECTED = "state_selected"
RaidGUIControlButtonWeaponSkill.STATE_ACTIVE = "state_active"
RaidGUIControlButtonWeaponSkill.STATE_BLOCKED = "state_blocked"
RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE = "state_unavailable"
RaidGUIControlButtonWeaponSkill.STATE_HOVER = "state_hover"
RaidGUIControlButtonWeaponSkill.TIER_MARKER_X = 33
RaidGUIControlButtonWeaponSkill.TIER_MARKER_Y = 46
RaidGUIControlButtonWeaponSkill.ICON = "wpn_skill_blank"
RaidGUIControlButtonWeaponSkill.ICON_LOCKED = "wpn_skill_locked"
RaidGUIControlButtonWeaponSkill.ROMAN_NUMERALS = {
	" I",
	" II",
	" III",
	" IV"
}
RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_W = 16
RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_H = 16
RaidGUIControlButtonWeaponSkill.SELECTOR_SIZE_EXTENSION = 10

-- Lines 23-71
function RaidGUIControlButtonWeaponSkill:init(parent, params, tier_number, line_object, left_button)
	self:_init_state_data()

	self._state = params.state or RaidGUIControlButtonWeaponSkill.STATE_NORMAL
	self._line_object = line_object
	local tier_marker_params = clone(params)
	tier_marker_params.x = params.x + RaidGUIControlButtonWeaponSkill.TIER_MARKER_X
	tier_marker_params.y = params.y + RaidGUIControlButtonWeaponSkill.TIER_MARKER_Y
	tier_marker_params.font = tweak_data.gui.fonts.din_compressed
	tier_marker_params.font_size = tweak_data.gui.font_sizes.size_16
	tier_marker_params.text = self:translate("menu_weapons_stats_tier_abbreviation", true) .. RaidGUIControlButtonWeaponSkill.ROMAN_NUMERALS[tier_number]
	local icon = RaidGUIControlButtonWeaponSkill.ICON_LOCKED
	params.texture = tweak_data.gui.icons[icon].texture
	params.texture_rect = tweak_data.gui.icons[icon].texture_rect
	self._on_selected_weapon_skill_callback = params.on_selected_weapon_skill_callback
	self._on_unselected_weapon_skill_callback = params.on_unselected_weapon_skill_callback
	self._get_available_points_callback = params.get_available_points_callback
	self._on_click_weapon_skill_callback = params.on_click_weapon_skill_callback
	self._toggle_select_item_callback = params.toggle_select_item_callback
	local new_params = clone(params)
	new_params.w = new_params.w + 2 * RaidGUIControlButtonWeaponSkill.SELECTOR_SIZE_EXTENSION
	new_params.h = new_params.h + 2 * RaidGUIControlButtonWeaponSkill.SELECTOR_SIZE_EXTENSION

	RaidGUIControlButtonWeaponSkill.super.init(self, parent, new_params)

	if left_button then
		left_button:set_right_button(self)
	end

	self._object_image:set_x(RaidGUIControlButtonWeaponSkill.SELECTOR_SIZE_EXTENSION)
	self._object_image:set_y(RaidGUIControlButtonWeaponSkill.SELECTOR_SIZE_EXTENSION)
	self._object_image:set_w(params.w)
	self._object_image:set_h(params.h)
	self:_create_selector()
end

-- Lines 73-119
function RaidGUIControlButtonWeaponSkill:_create_selector()
	local selector_panel_params = {
		halign = "scale",
		name = "selector_panel",
		y = 0,
		alpha = 0,
		x = 0,
		valign = "scale",
		w = self._object:w(),
		h = self._object:h()
	}
	self._selector_panel = self._object:panel(selector_panel_params)
	local selector_background_params = {
		halign = "scale",
		name = "selector_background",
		alpha = 0,
		y = 0,
		x = 0,
		valign = "scale",
		w = self._selector_panel:w(),
		h = self._selector_panel:h(),
		color = tweak_data.gui.colors.raid_select_card_background
	}
	self._selector_rect = self._selector_panel:rect(selector_background_params)
	local selector_triangle_up_params = {
		name = "selector_triangle_up",
		y = 0,
		alpha = 0,
		halign = "left",
		x = 0,
		valign = "top",
		w = RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_W,
		h = RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_H,
		texture = tweak_data.gui.icons.ico_sel_rect_top_left.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_top_left.texture_rect
	}
	self._selector_triangle_up = self._selector_panel:image(selector_triangle_up_params)
	local selector_triangle_down_params = {
		name = "selector_triangle_down",
		alpha = 0,
		halign = "right",
		valign = "bottom",
		x = self._selector_panel:w() - RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_W,
		y = self._selector_panel:h() - RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_H,
		w = RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_W,
		h = RaidGUIControlButtonWeaponSkill.SELECTOR_TRIANGLE_H,
		texture = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture_rect
	}
	self._selector_triangle_down = self._selector_panel:image(selector_triangle_down_params)
end

-- Lines 121-123
function RaidGUIControlButtonWeaponSkill:set_right_button(button)
	self._right_button = button
end

-- Lines 125-188
function RaidGUIControlButtonWeaponSkill:set_skill(weapon_id, skill, skill_data, left_skill, unlocked, i_tier, i_skill)
	self._unlocked = unlocked

	if not skill then
		self:hide()

		if self._line_object then
			self._line_object:hide()
		end

		return
	else
		self:show()

		if self._line_object then
			self._line_object:show()
		end

		self._name = "weapon_skill_button_" .. skill.skill_name .. "_" .. i_tier .. "_" .. i_skill
	end

	if self._line_object then
		if not left_skill then
			self._line_object:hide()
		else
			self._line_object:show()
		end
	end

	local is_pending_challenge_active = (left_skill and left_skill.active or not left_skill) and skill.challenge_unlocked and not managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, skill.challenge_id):completed()
	local icon = skill_data.icon or RaidGUIControlButtonWeaponSkill.ICON

	if not self._unlocked or left_skill and not left_skill.active then
		icon = RaidGUIControlButtonWeaponSkill.ICON_LOCKED
	end

	local texture = tweak_data.gui.icons[icon]

	self._object_image:set_image(texture.texture)
	self._object_image:set_texture_rect(unpack(texture.texture_rect))

	if skill.active then
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_ACTIVE)
	elseif self._unlocked and left_skill and (managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, left_skill.challenge_id):completed() == false or managers.challenge:get_challenge(ChallengeManager.CATEGORY_WEAPON_UPGRADE, left_skill.challenge_id):completed() == true and not left_skill.active) then
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_BLOCKED)
	elseif not self._unlocked or left_skill and not left_skill.active then
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE)
	elseif is_pending_challenge_active then
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_CHALLENGE_ACTIVE)
	else
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_NORMAL)
	end

	self._data = {
		value = skill,
		i_tier = i_tier,
		i_skill = i_skill
	}

	self:highlight_off()
	self:_layout_breadcrumb(weapon_id, i_tier, i_skill)
end

-- Lines 190-209
function RaidGUIControlButtonWeaponSkill:_layout_breadcrumb(weapon_id, i_tier, i_skill)
	if self._breadcrumb then
		self._breadcrumb:close()
		self._object:remove(self._breadcrumb)

		self._breadcrumb = nil
	end

	local weapon_selection_index = tweak_data.weapon[weapon_id].use_data.selection_index
	local weapon_category = managers.weapon_inventory:get_weapon_category_name_by_bm_category_id(weapon_selection_index)
	local breadcrumb_params = {
		padding = 3,
		category = BreadcrumbManager.CATEGORY_WEAPON_UPGRADE,
		identifiers = {
			weapon_category,
			weapon_id,
			i_tier,
			i_skill
		},
		layer = self._object_image:layer() + 1
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_y(0)
end

-- Lines 211-219
function RaidGUIControlButtonWeaponSkill:select_skill(dont_trigger_selected_callback)
	self._mouse_inside = true

	self:highlight_on()

	if not dont_trigger_selected_callback then
		self:_on_selected_weapon_skill_callback(self._data)
	end
end

-- Lines 221-226
function RaidGUIControlButtonWeaponSkill:unselect_skill()
	self._mouse_inside = false

	self:highlight_off()
	self:_on_unselected_weapon_skill_callback(self._data)
end

-- Lines 228-253
function RaidGUIControlButtonWeaponSkill:set_state(state)
	if not self._unlocked and state ~= RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE then
		return
	end

	self._state = state
	local color = self._state_data[self._state].highlight_off

	self:set_param_value("color", color)
	self:set_param_value("texture_color", color)

	local highlight_color = self._state_data[self._state].highlight_on

	self:set_param_value("highlight_color", highlight_color)
	self:set_param_value("texture_highlight_color", highlight_color)
	self:highlight_off()
	self._selector_panel:set_alpha(self._state_data[state].show_selector_panel_alpha)
	self._selector_rect:set_alpha(0)
	self._selector_triangle_up:set_alpha(self._state_data[state].show_selector_triangles_alpha)
	self._selector_triangle_down:set_alpha(self._state_data[state].show_selector_triangles_alpha)
end

-- Lines 255-293
function RaidGUIControlButtonWeaponSkill:_init_state_data()
	self._state_data = {
		[RaidGUIControlButtonWeaponSkill.STATE_NORMAL] = {
			show_selector_triangles_alpha = 0,
			show_selector_panel_alpha = 1,
			highlight_off = tweak_data.gui.colors.raid_white,
			highlight_on = tweak_data.gui.colors.raid_white
		},
		[RaidGUIControlButtonWeaponSkill.STATE_CHALLENGE_ACTIVE] = {
			show_selector_triangles_alpha = 0,
			show_selector_panel_alpha = 1,
			highlight_off = tweak_data.gui.colors.raid_white,
			highlight_on = tweak_data.gui.colors.raid_white
		},
		[RaidGUIControlButtonWeaponSkill.STATE_BLOCKED] = {
			show_selector_triangles_alpha = 0,
			show_selector_panel_alpha = 1,
			highlight_off = tweak_data.gui.colors.raid_white,
			highlight_on = tweak_data.gui.colors.raid_white
		},
		[RaidGUIControlButtonWeaponSkill.STATE_SELECTED] = {
			show_selector_triangles_alpha = 1,
			show_selector_panel_alpha = 1,
			highlight_off = tweak_data.gui.colors.raid_white,
			highlight_on = tweak_data.gui.colors.raid_white
		},
		[RaidGUIControlButtonWeaponSkill.STATE_ACTIVE] = {
			show_selector_triangles_alpha = 0,
			show_selector_panel_alpha = 1,
			highlight_off = tweak_data.gui.colors.raid_red,
			highlight_on = tweak_data.gui.colors.raid_red
		},
		[RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE] = {
			show_selector_triangles_alpha = 0,
			show_selector_panel_alpha = 0,
			highlight_off = tweak_data.gui.colors.raid_dark_grey,
			highlight_on = tweak_data.gui.colors.raid_dark_grey
		}
	}
end

-- Lines 295-297
function RaidGUIControlButtonWeaponSkill:get_state()
	return self._state
end

-- Lines 299-301
function RaidGUIControlButtonWeaponSkill:get_data()
	return self._data
end

-- Lines 303-316
function RaidGUIControlButtonWeaponSkill:highlight_on()
	local color = self._state_data[self._state].highlight_on

	self._object_image:set_color(color)

	if self._line_object then
		self._line_object:set_color(color)
	end

	managers.menu_component:post_event("weapon_increase")
	self:show_hover_selector()
end

-- Lines 318-329
function RaidGUIControlButtonWeaponSkill:highlight_off()
	local color = self._state_data[self._state].highlight_off

	self._object_image:set_color(color)

	if self._line_object then
		self._line_object:set_color(color)
	end

	self:hide_hover_selector()
end

-- Lines 331-336
function RaidGUIControlButtonWeaponSkill:show_hover_selector()
	if self._selector_panel then
		self._selector_panel:set_alpha(1)
		self._selector_rect:set_alpha(1)
	end
end

-- Lines 338-343
function RaidGUIControlButtonWeaponSkill:hide_hover_selector()
	if self._selector_panel then
		self._selector_rect:set_alpha(0)
	end
end

-- Lines 345-399
function RaidGUIControlButtonWeaponSkill:on_mouse_released(button)
	if self._state == RaidGUIControlButtonWeaponSkill.STATE_ACTIVE and self._data.value.active then
		return
	elseif self._state == RaidGUIControlButtonWeaponSkill.STATE_SELECTED then
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_NORMAL)
		managers.menu_component:post_event("weapon_upgrade_deselect")
	elseif self._state == RaidGUIControlButtonWeaponSkill.STATE_NORMAL then
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_SELECTED)
		managers.menu_component:post_event("weapon_upgrade_select")
	elseif self._state == RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE then
		return
	end

	if self._on_click_weapon_skill_callback then
		self:_on_click_weapon_skill_callback(self._data)
	end

	self:show_hover_selector()
end

-- Lines 401-403
function RaidGUIControlButtonWeaponSkill:on_mouse_pressed(button)
end

-- Lines 405-419
function RaidGUIControlButtonWeaponSkill:mouse_moved(o, x, y)
	if self:inside(x, y) then
		if not self._mouse_inside then
			self:on_mouse_over(x, y)
		end

		self:on_mouse_moved(o, x, y)

		return true, self._pointer_type
	end

	if self._mouse_inside then
		self:on_mouse_out(x, y)
	end

	return false
end

-- Lines 421-439
function RaidGUIControlButtonWeaponSkill:propagating_skill_deallocating()
	if self._state == RaidGUIControlButtonWeaponSkill.STATE_SELECTED then
		self:set_state(RaidGUIControlButtonWeaponSkill.STATE_NORMAL)
		self:_on_click_weapon_skill_callback(self._data)
	end

	self:set_state(RaidGUIControlButtonWeaponSkill.STATE_UNAVAILABLE)

	if self._right_button then
		self._right_button:propagating_skill_deallocating()
	end

	self:_get_available_points_callback()
end

-- Lines 441-448
function RaidGUIControlButtonWeaponSkill:on_mouse_over(x, y)
	self._mouse_inside = true

	self._toggle_select_item_callback(true, self._data.i_skill, self._data.i_tier)
end

-- Lines 450-458
function RaidGUIControlButtonWeaponSkill:on_mouse_out(x, y)
	self._mouse_inside = false

	managers.menu_component:post_event("weapon_decrease")
	self._toggle_select_item_callback(false, self._data.i_skill, self._data.i_tier)
end
