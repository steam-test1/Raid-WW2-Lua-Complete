RaidGUIControlMeleeWeaponRewardDetails = RaidGUIControlMeleeWeaponRewardDetails or class(RaidGUIControl)
RaidGUIControlMeleeWeaponRewardDetails.DEFAULT_WIDTH = 400
RaidGUIControlMeleeWeaponRewardDetails.HEIGHT = 400
RaidGUIControlMeleeWeaponRewardDetails.LEFT_PANEL_W = 860
RaidGUIControlMeleeWeaponRewardDetails.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_Y = 690
RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_H = 50
RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlMeleeWeaponRewardDetails.TITLE_PADDING_TOP = -14
RaidGUIControlMeleeWeaponRewardDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlMeleeWeaponRewardDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlMeleeWeaponRewardDetails.REWARD_ICON_PANEL_Y = 144
RaidGUIControlMeleeWeaponRewardDetails.REWARD_ICON_PANEL_H = 560
RaidGUIControlMeleeWeaponRewardDetails.REWARD_ICON = "rwd_weapon_large"
RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_Y = 224
RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_H = 72
RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_Y = 304
RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_W = 416
RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlMeleeWeaponRewardDetails.REDEEM_DESCRIPTION_CENTER_Y_FROM_BOTTOM = 192
RaidGUIControlMeleeWeaponRewardDetails.REDEEM_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlMeleeWeaponRewardDetails.REDEEM_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlMeleeWeaponRewardDetails.REDEEM_VALUE_CENTER_Y_FROM_BOTTOM = 148
RaidGUIControlMeleeWeaponRewardDetails.REDEEM_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_56
RaidGUIControlMeleeWeaponRewardDetails.REDEEM_VALUE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlMeleeWeaponRewardDetails.REDEEM_BUTTON_CENTER_Y_FROM_BOTTOM = 92

-- Lines 45-65
function RaidGUIControlMeleeWeaponRewardDetails:init(parent, params)
	RaidGUIControlMeleeWeaponRewardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlMeleeWeaponRewardDetails:init] Parameters not specified for the melee weapon reward details")

		return
	end

	self._xp_redeem_value = tweak_data.weapon_skills.weapon_point_reedemed_xp

	self:_create_control_panel()
	self:_create_left_panel()
	self:_create_title()
	self:_create_reward_image()
	self:_create_right_panel()
	self:_create_description()
	self:_create_item_title()
end

-- Lines 67-76
function RaidGUIControlMeleeWeaponRewardDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlMeleeWeaponRewardDetails.DEFAULT_WIDTH
	control_params.h = control_params.h or RaidGUIControlMeleeWeaponRewardDetails.HEIGHT
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 78-85
function RaidGUIControlMeleeWeaponRewardDetails:_create_left_panel()
	local left_panel_params = {
		name = "left_panel",
		w = RaidGUIControlMeleeWeaponRewardDetails.LEFT_PANEL_W,
		h = self._object:h()
	}
	self._left_panel = self._object:panel(left_panel_params)
end

-- Lines 87-124
function RaidGUIControlMeleeWeaponRewardDetails:_create_title()
	local title_description_params = {
		name = "title_description",
		vertical = "center",
		alpha = 0,
		align = "left",
		layer = 10,
		y = RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_Y,
		h = RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_H,
		font = RaidGUIControlMeleeWeaponRewardDetails.FONT,
		font_size = RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlMeleeWeaponRewardDetails.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	}
	self._title_description = self._left_panel:text(title_description_params)
	local _, _, w, _ = self._title_description:text_rect()

	self._title_description:set_w(w)

	local title_params = {
		vertical = "top",
		name = "customization_name",
		alpha = 0,
		wrap = true,
		align = "left",
		layer = 10,
		y = self._title_description:y() + self._title_description:h() + RaidGUIControlMeleeWeaponRewardDetails.TITLE_PADDING_TOP,
		font = RaidGUIControlMeleeWeaponRewardDetails.FONT,
		font_size = RaidGUIControlMeleeWeaponRewardDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlMeleeWeaponRewardDetails.TITLE_COLOR,
		text = self:translate("menu_loot_screen_melee_weapon", true),
		w = self._left_panel:w() * 0.8
	}
	self._melee_weapon_name = self._left_panel:text(title_params)

	self:_layout_title()
end

-- Lines 126-134
function RaidGUIControlMeleeWeaponRewardDetails:_layout_title()
	local _, _, w, h = self._melee_weapon_name:text_rect()

	self._melee_weapon_name:set_h(h)
	self._melee_weapon_name:set_center_x(self._left_panel:w() / 2)
	self._title_description:set_x(self._melee_weapon_name:x())
end

-- Lines 136-154
function RaidGUIControlMeleeWeaponRewardDetails:_create_reward_image()
	local reward_image_panel_params = {
		name = "reward_image_panel",
		layer = 10,
		w = self._left_panel:w()
	}
	self._reward_image_panel = self._left_panel:panel(reward_image_panel_params)
	local reward_image_params = {
		name = "reward_image",
		alpha = 0,
		texture = tweak_data.gui.icons[RaidGUIControlMeleeWeaponRewardDetails.REWARD_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlMeleeWeaponRewardDetails.REWARD_ICON].texture_rect
	}
	self._reward_image = self._reward_image_panel:bitmap(reward_image_params)

	self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
	self._reward_image:set_center_y(self._reward_image_panel:h() / 2)
end

-- Lines 156-191
function RaidGUIControlMeleeWeaponRewardDetails:_create_redeem_info()
	local redeem_description_params = {
		name = "redeem_description",
		layer = 10,
		font = RaidGUIControlMeleeWeaponRewardDetails.FONT,
		font_size = RaidGUIControlMeleeWeaponRewardDetails.REDEEM_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlMeleeWeaponRewardDetails.REDEEM_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_redeem_worth_title", true)
	}
	local redeem_description = self._left_panel:text(redeem_description_params)
	local redeem_value_params = {
		name = "redeem_value",
		layer = 10,
		font = RaidGUIControlMeleeWeaponRewardDetails.FONT,
		font_size = RaidGUIControlMeleeWeaponRewardDetails.REDEEM_VALUE_FONT_SIZE,
		color = RaidGUIControlMeleeWeaponRewardDetails.REDEEM_VALUE_COLOR,
		text = self._xp_redeem_value .. " " .. self:translate("menu_label_xp", true)
	}
	self._xp_redeem_value_text = self._left_panel:text(redeem_value_params)

	self:_layout_redeem_info()

	local redeem_xp_button_params = {
		name = "redeem_xp_button",
		x = 0,
		y = self._left_panel:h() - RaidGUIControlMeleeWeaponRewardDetails.REDEEM_BUTTON_CENTER_Y_FROM_BOTTOM,
		text = self:translate("menu_loot_screen_redeem_xp", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_redeem")
	}
	self._redeem_button = self._left_panel:short_tertiary_button(redeem_xp_button_params)

	self._redeem_button:set_center_x(self._left_panel:w() / 2)
end

-- Lines 193-206
function RaidGUIControlMeleeWeaponRewardDetails:_layout_redeem_info()
	local redeem_description = self._left_panel:child("redeem_description")
	local _, _, w, h = redeem_description:text_rect()

	redeem_description:set_w(w)
	redeem_description:set_h(h)
	redeem_description:set_center_x(self._left_panel:w() / 2)
	redeem_description:set_center_y(self._left_panel:h() - RaidGUIControlMeleeWeaponRewardDetails.REDEEM_DESCRIPTION_CENTER_Y_FROM_BOTTOM)

	local _, _, w, h = self._xp_redeem_value_text:text_rect()

	self._xp_redeem_value_text:set_w(w)
	self._xp_redeem_value_text:set_h(h)
	self._xp_redeem_value_text:set_center_x(self._left_panel:w() / 2)
	self._xp_redeem_value_text:set_center_y(self._left_panel:h() - RaidGUIControlMeleeWeaponRewardDetails.REDEEM_VALUE_CENTER_Y_FROM_BOTTOM)
end

-- Lines 210-218
function RaidGUIControlMeleeWeaponRewardDetails:_create_right_panel()
	local right_panel_params = {
		name = "right_panel",
		w = self._object:w() - self._left_panel:w(),
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)

	self._right_panel:set_right(self._object:w())
end

-- Lines 220-236
function RaidGUIControlMeleeWeaponRewardDetails:_create_description()
	local description_params = {
		vertical = "top",
		name = "description",
		wrap = true,
		align = "left",
		alpha = 0,
		text = "",
		layer = 10,
		y = RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_Y,
		w = RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_W,
		font = RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_COLOR
	}
	self._description = self._right_panel:text(description_params)

	self._description:set_right(self._right_panel:w())
end

-- Lines 238-255
function RaidGUIControlMeleeWeaponRewardDetails:_create_item_title()
	local item_type_params = {
		name = "item_type",
		wrap = true,
		align = "left",
		alpha = 0,
		vertical = "center",
		text = "",
		layer = 10,
		x = self._description:x(),
		y = RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_Y,
		w = RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_W,
		h = RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_H,
		font = RaidGUIControlMeleeWeaponRewardDetails.FONT,
		font_size = RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_FONT_SIZE,
		color = RaidGUIControlMeleeWeaponRewardDetails.ITEM_TYPE_COLOR
	}
	self._item_title = self._right_panel:text(item_type_params)
end

-- Lines 257-335
function RaidGUIControlMeleeWeaponRewardDetails:show()
	RaidGUIControlMeleeWeaponRewardDetails.super.show(self)

	local duration = 1.9
	local t = 0
	local original_image_w, original_image_h = self._reward_image:size()
	local image_duration = 0.1
	local image_duration_slowdown = 1.75
	local title_description_y = self._title_description:y()
	local title_description_offset = 35
	local customization_name_y = self._melee_weapon_name:y()
	local customization_name_offset = 20
	local title_delay = 0
	local title_duration = 1
	local description_x = self._description:x()
	local description_offset = 30
	local item_type_x = self._item_title:x()
	local item_type_offset = 30

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, image_duration)

		self._reward_image:set_alpha(current_alpha)

		if t < image_duration then
			local current_scale = Easing.linear(t, 1.4, -0.35, image_duration)

			self._reward_image:set_size(original_image_w * current_scale, original_image_h * current_scale)
		elseif image_duration < t and t < image_duration + image_duration_slowdown then
			local current_scale = Easing.quartic_out(t - image_duration, 1.05, -0.05, image_duration_slowdown)

			self._reward_image:set_size(original_image_w * current_scale, original_image_h * current_scale)
		elseif t > image_duration + image_duration_slowdown then
			self._reward_image:set_size(original_image_w, original_image_h)
		end

		self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
		self._reward_image:set_center_y(self._reward_image_panel:h() / 2)

		if title_delay < t then
			local current_title_alpha = Easing.quartic_out(t - title_delay, 0, 1, title_duration)

			self._title_description:set_alpha(current_title_alpha)
			self._melee_weapon_name:set_alpha(current_title_alpha)
			self._description:set_alpha(current_title_alpha)
			self._item_title:set_alpha(current_title_alpha)

			local title_description_current_offset = Easing.quartic_out(t - title_delay, title_description_offset, -title_description_offset, title_duration)

			self._title_description:set_y(title_description_y - title_description_current_offset)

			local customization_name_current_offset = Easing.quartic_out(t - title_delay, customization_name_offset, -customization_name_offset, title_duration)

			self._melee_weapon_name:set_y(customization_name_y - customization_name_current_offset)

			local description_current_offset = Easing.quartic_out(t - title_delay, -description_offset, description_offset, title_duration)

			self._description:set_x(description_x + description_current_offset)

			local item_type_current_offset = Easing.quartic_out(t - title_delay, -item_type_offset, item_type_offset, title_duration)

			self._item_title:set_x(item_type_x + item_type_current_offset)
		end
	end

	self._reward_image:set_alpha(1)
	self._reward_image:set_size(original_image_w, original_image_h)
	self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
	self._reward_image:set_center_y(self._reward_image_panel:h() / 2)
	self._title_description:set_alpha(1)
	self._title_description:set_y(title_description_y)
	self._melee_weapon_name:set_alpha(1)
	self._melee_weapon_name:set_y(customization_name_y)
	self._description:set_alpha(1)
	self._description:set_x(description_x)
	self._item_title:set_alpha(1)
	self._item_title:set_x(item_type_x)
end

-- Lines 337-341
function RaidGUIControlMeleeWeaponRewardDetails:_on_click_redeem()
	local params = {
		callback = callback(self, self, "redeem"),
		xp = self._xp_redeem_value
	}

	managers.menu:show_redeem_weapon_point_dialog(params)
end

-- Lines 343-354
function RaidGUIControlMeleeWeaponRewardDetails:redeem()
	managers.lootdrop:redeem_dropped_loot_for_xp()
	game_state_machine:current_state():recalculate_xp()
end

-- Lines 356-366
function RaidGUIControlMeleeWeaponRewardDetails:set_melee_weapon(weapon_id)
	local melee_weapon = managers.weapon_inventory:get_weapon_data(WeaponInventoryManager.CATEGORY_NAME_MELEE, weapon_id)
	local bm_tweak_data = tweak_data.blackmarket.melee_weapons[weapon_id]

	self._item_title:set_text(self:translate(bm_tweak_data.name_id, true))
	self._melee_weapon_name:set_text(self:translate(bm_tweak_data.name_id, true))
	self:_layout_title()
	self._description:set_text(self:translate(bm_tweak_data.desc_id, false))
	self._reward_image:set_image(bm_tweak_data.reward_image)
end

-- Lines 368-372
function RaidGUIControlMeleeWeaponRewardDetails:close()
	RaidGUIControlMeleeWeaponRewardDetails.super.close(self)
end
