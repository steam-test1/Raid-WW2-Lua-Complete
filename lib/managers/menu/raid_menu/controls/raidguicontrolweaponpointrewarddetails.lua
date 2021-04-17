RaidGUIControlWeaponPointRewardDetails = RaidGUIControlWeaponPointRewardDetails or class(RaidGUIControl)
RaidGUIControlWeaponPointRewardDetails.DEFAULT_WIDTH = 400
RaidGUIControlWeaponPointRewardDetails.HEIGHT = 400
RaidGUIControlWeaponPointRewardDetails.LEFT_PANEL_W = 860
RaidGUIControlWeaponPointRewardDetails.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlWeaponPointRewardDetails.TITLE_DESCRIPTION_H = 50
RaidGUIControlWeaponPointRewardDetails.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlWeaponPointRewardDetails.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlWeaponPointRewardDetails.TITLE_PADDING_TOP = -14
RaidGUIControlWeaponPointRewardDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlWeaponPointRewardDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlWeaponPointRewardDetails.REWARD_ICON_PANEL_Y = 144
RaidGUIControlWeaponPointRewardDetails.REWARD_ICON_PANEL_H = 560
RaidGUIControlWeaponPointRewardDetails.REWARD_ICON = "rwd_weapon_large"
RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_Y = 224
RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_H = 64
RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_Y = 304
RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_W = 352
RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlWeaponPointRewardDetails.REDEEM_DESCRIPTION_CENTER_Y_FROM_BOTTOM = 192
RaidGUIControlWeaponPointRewardDetails.REDEEM_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlWeaponPointRewardDetails.REDEEM_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlWeaponPointRewardDetails.REDEEM_VALUE_CENTER_Y_FROM_BOTTOM = 148
RaidGUIControlWeaponPointRewardDetails.REDEEM_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_56
RaidGUIControlWeaponPointRewardDetails.REDEEM_VALUE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlWeaponPointRewardDetails.REDEEM_BUTTON_CENTER_Y_FROM_BOTTOM = 92

-- Lines 44-64
function RaidGUIControlWeaponPointRewardDetails:init(parent, params)
	RaidGUIControlWeaponPointRewardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlWeaponPointRewardDetails:init] Parameters not specified for the XP reward details")

		return
	end

	self._xp_redeem_value = tweak_data.weapon_skills.weapon_point_reedemed_xp

	self:_create_control_panel()
	self:_create_left_panel()
	self:_create_title()
	self:_create_reward_image()
	self:_create_redeem_info()
	self:_create_right_panel()
	self:_create_item_type()
	self:_create_description()
end

-- Lines 67-76
function RaidGUIControlWeaponPointRewardDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlWeaponPointRewardDetails.DEFAULT_WIDTH
	control_params.h = control_params.h or RaidGUIControlWeaponPointRewardDetails.HEIGHT
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 78-85
function RaidGUIControlWeaponPointRewardDetails:_create_left_panel()
	local left_panel_params = {
		name = "left_panel",
		w = RaidGUIControlWeaponPointRewardDetails.LEFT_PANEL_W,
		h = self._object:h()
	}
	self._left_panel = self._object:panel(left_panel_params)
end

-- Lines 87-115
function RaidGUIControlWeaponPointRewardDetails:_create_title()
	local title_description_params = {
		align = "left",
		vertical = "center",
		name = "title_description",
		h = RaidGUIControlWeaponPointRewardDetails.TITLE_DESCRIPTION_H,
		font = RaidGUIControlWeaponPointRewardDetails.FONT,
		font_size = RaidGUIControlWeaponPointRewardDetails.TITLE_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlWeaponPointRewardDetails.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	}
	local title_description = self._left_panel:text(title_description_params)
	local _, _, w, _ = title_description:text_rect()

	title_description:set_w(w)

	local title_params = {
		align = "center",
		vertical = "top",
		name = "customization_name",
		y = title_description:y() + title_description:h() + RaidGUIControlWeaponPointRewardDetails.TITLE_PADDING_TOP,
		font = RaidGUIControlWeaponPointRewardDetails.FONT,
		font_size = RaidGUIControlWeaponPointRewardDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlWeaponPointRewardDetails.TITLE_COLOR,
		text = self:translate("menu_loot_screen_weapon_point", true)
	}
	self._customization_name = self._left_panel:text(title_params)

	self:_layout_title()
end

-- Lines 117-125
function RaidGUIControlWeaponPointRewardDetails:_layout_title()
	local _, _, w, h = self._customization_name:text_rect()

	self._customization_name:set_w(w)
	self._customization_name:set_h(h)
	self._customization_name:set_center_x(self._left_panel:w() / 2)

	local title_description = self._left_panel:child("title_description")

	title_description:set_x(self._customization_name:x())
end

-- Lines 127-144
function RaidGUIControlWeaponPointRewardDetails:_create_reward_image()
	local reward_image_panel_params = {
		name = "reward_image_panel",
		y = RaidGUIControlWeaponPointRewardDetails.REWARD_ICON_PANEL_Y,
		w = self._left_panel:w(),
		h = RaidGUIControlWeaponPointRewardDetails.REWARD_ICON_PANEL_H
	}
	local reward_image_panel = self._left_panel:panel(reward_image_panel_params)
	local reward_image_params = {
		name = "reward_image",
		texture = tweak_data.gui.icons[RaidGUIControlWeaponPointRewardDetails.REWARD_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlWeaponPointRewardDetails.REWARD_ICON].texture_rect
	}
	self._reward_image = reward_image_panel:bitmap(reward_image_params)

	self._reward_image:set_center_x(reward_image_panel:w() / 2)
	self._reward_image:set_center_y(reward_image_panel:h() / 2)
end

-- Lines 146-179
function RaidGUIControlWeaponPointRewardDetails:_create_redeem_info()
	local redeem_description_params = {
		name = "redeem_description",
		font = RaidGUIControlWeaponPointRewardDetails.FONT,
		font_size = RaidGUIControlWeaponPointRewardDetails.REDEEM_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlWeaponPointRewardDetails.REDEEM_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_redeem_worth_title", true)
	}
	local redeem_description = self._left_panel:text(redeem_description_params)
	local redeem_value_params = {
		name = "redeem_value",
		font = RaidGUIControlWeaponPointRewardDetails.FONT,
		font_size = RaidGUIControlWeaponPointRewardDetails.REDEEM_VALUE_FONT_SIZE,
		color = RaidGUIControlWeaponPointRewardDetails.REDEEM_VALUE_COLOR,
		text = self._xp_redeem_value .. " " .. self:translate("menu_label_xp", true)
	}
	self._xp_redeem_value_text = self._left_panel:text(redeem_value_params)

	self:_layout_redeem_info()

	local redeem_xp_button_params = {
		name = "redeem_xp_button",
		x = 0,
		y = self._left_panel:h() - RaidGUIControlWeaponPointRewardDetails.REDEEM_BUTTON_CENTER_Y_FROM_BOTTOM,
		text = self:translate("menu_loot_screen_redeem_xp", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_redeem")
	}
	self._redeem_button = self._left_panel:short_tertiary_button(redeem_xp_button_params)

	self._redeem_button:set_center_x(self._left_panel:w() / 2)
end

-- Lines 181-194
function RaidGUIControlWeaponPointRewardDetails:_layout_redeem_info()
	local redeem_description = self._left_panel:child("redeem_description")
	local _, _, w, h = redeem_description:text_rect()

	redeem_description:set_w(w)
	redeem_description:set_h(h)
	redeem_description:set_center_x(self._left_panel:w() / 2)
	redeem_description:set_center_y(self._left_panel:h() - RaidGUIControlWeaponPointRewardDetails.REDEEM_DESCRIPTION_CENTER_Y_FROM_BOTTOM)

	local _, _, w, h = self._xp_redeem_value_text:text_rect()

	self._xp_redeem_value_text:set_w(w)
	self._xp_redeem_value_text:set_h(h)
	self._xp_redeem_value_text:set_center_x(self._left_panel:w() / 2)
	self._xp_redeem_value_text:set_center_y(self._left_panel:h() - RaidGUIControlWeaponPointRewardDetails.REDEEM_VALUE_CENTER_Y_FROM_BOTTOM)
end

-- Lines 198-206
function RaidGUIControlWeaponPointRewardDetails:_create_right_panel()
	local right_panel_params = {
		name = "right_panel",
		w = self._object:w() - self._left_panel:w(),
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)

	self._right_panel:set_right(self._object:w())
end

-- Lines 208-221
function RaidGUIControlWeaponPointRewardDetails:_create_item_type()
	local item_type_params = {
		vertical = "center",
		name = "item_type",
		align = "right",
		y = RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_Y,
		w = self._right_panel:w(),
		h = RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_H,
		font = RaidGUIControlWeaponPointRewardDetails.FONT,
		font_size = RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_FONT_SIZE,
		color = RaidGUIControlWeaponPointRewardDetails.ITEM_TYPE_COLOR,
		text = self:translate("menu_loot_screen_weapon_point_title_text", true)
	}
	self._item_type = self._right_panel:text(item_type_params)
end

-- Lines 223-237
function RaidGUIControlWeaponPointRewardDetails:_create_description()
	local description_params = {
		vertical = "top",
		name = "description",
		wrap = true,
		align = "left",
		y = RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_Y,
		w = RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_W,
		font = RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlWeaponPointRewardDetails.DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_weapon_point_description")
	}
	self._description = self._right_panel:text(description_params)

	self._description:set_right(self._right_panel:w())
end

-- Lines 239-243
function RaidGUIControlWeaponPointRewardDetails:_on_click_redeem()
	local params = {
		callback = callback(self, self, "redeem"),
		xp = self._xp_redeem_value
	}

	managers.menu:show_redeem_weapon_point_dialog(params)
end

-- Lines 245-256
function RaidGUIControlWeaponPointRewardDetails:redeem()
	managers.lootdrop:redeem_dropped_loot_for_xp()
	game_state_machine:current_state():recalculate_xp()
	self._redeem_button:hide()
end
