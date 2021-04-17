RaidGUIControlCharacterCustomizationDetails = RaidGUIControlCharacterCustomizationDetails or class(RaidGUIControl)
RaidGUIControlCharacterCustomizationDetails.DEFAULT_WIDTH = 128
RaidGUIControlCharacterCustomizationDetails.HEIGHT = 96
RaidGUIControlCharacterCustomizationDetails.LEFT_PANEL_W = 860
RaidGUIControlCharacterCustomizationDetails.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_Y = 690
RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_H = 50
RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlCharacterCustomizationDetails.TITLE_PADDING_TOP = -14
RaidGUIControlCharacterCustomizationDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlCharacterCustomizationDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlCharacterCustomizationDetails.CUSTOMIZATION_IMAGE_PANEL_Y = 144
RaidGUIControlCharacterCustomizationDetails.CUSTOMIZATION_IMAGE_PANEL_H = 560
RaidGUIControlCharacterCustomizationDetails.CUSTOMIZATION_IMAGE_LOWER_PART_SCALE_FACTOR = 1.1
RaidGUIControlCharacterCustomizationDetails.DEFAULT_ICON_UPPER = "rwd_upper_body_large"
RaidGUIControlCharacterCustomizationDetails.DEFAULT_ICON_LOWER = "rwd_lower_body_large"
RaidGUIControlCharacterCustomizationDetails.REDEEM_DESCRIPTION_CENTER_Y_FROM_BOTTOM = 192
RaidGUIControlCharacterCustomizationDetails.REDEEM_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlCharacterCustomizationDetails.REDEEM_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlCharacterCustomizationDetails.REDEEM_VALUE_CENTER_Y_FROM_BOTTOM = 148
RaidGUIControlCharacterCustomizationDetails.REDEEM_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_56
RaidGUIControlCharacterCustomizationDetails.REDEEM_VALUE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlCharacterCustomizationDetails.REDEEM_BUTTON_CENTER_Y_FROM_BOTTOM = 92
RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_Y = 224
RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_H = 72
RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_Y = 304
RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_W = 416
RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_PADDING_DOWN = 32
RaidGUIControlCharacterCustomizationDetails.RARITY_W = 96
RaidGUIControlCharacterCustomizationDetails.RARITY_H = 96
RaidGUIControlCharacterCustomizationDetails.NATIONALITY_W = 128
RaidGUIControlCharacterCustomizationDetails.NATIONALITY_H = 96
RaidGUIControlCharacterCustomizationDetails.NATIONALITY_ICON_H = 64
RaidGUIControlCharacterCustomizationDetails.NATIONALITY_PADDING_RIGHT = 32

-- Lines 57-76
function RaidGUIControlCharacterCustomizationDetails:init(parent, params)
	RaidGUIControlCharacterCustomizationDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlCharacterCustomizationDetails:init] Parameters not specified for the customization details")

		return
	end

	self:_create_control_panel()
	self:_create_left_panel()
	self:_create_title()
	self:_create_customization_image()
	self:_create_right_panel()
	self:_create_description()
	self:_create_item_description_name()
	self:_create_customization_info()
end

-- Lines 79-80
function RaidGUIControlCharacterCustomizationDetails:close()
end

-- Lines 83-93
function RaidGUIControlCharacterCustomizationDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlCharacterCustomizationDetails.DEFAULT_WIDTH
	control_params.h = control_params.h or RaidGUIControlCharacterCustomizationDetails.HEIGHT
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 95-102
function RaidGUIControlCharacterCustomizationDetails:_create_left_panel()
	local left_panel_params = {
		name = "left_panel",
		w = RaidGUIControlCharacterCustomizationDetails.LEFT_PANEL_W,
		h = self._object:h()
	}
	self._left_panel = self._object:panel(left_panel_params)
end

-- Lines 104-135
function RaidGUIControlCharacterCustomizationDetails:_create_title()
	local title_description_params = {
		name = "title_description",
		vertical = "center",
		alpha = 0,
		align = "left",
		y = RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_Y,
		h = RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_H,
		font = RaidGUIControlCharacterCustomizationDetails.FONT,
		font_size = RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlCharacterCustomizationDetails.TITLE_DESCRIPTION_COLOR,
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
		text = "customization_name",
		y = self._title_description:y() + self._title_description:h() + RaidGUIControlCharacterCustomizationDetails.TITLE_PADDING_TOP,
		font = RaidGUIControlCharacterCustomizationDetails.FONT,
		font_size = RaidGUIControlCharacterCustomizationDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlCharacterCustomizationDetails.TITLE_COLOR,
		w = self._left_panel:w() * 0.8
	}
	self._customization_name = self._left_panel:text(title_params)
end

-- Lines 137-143
function RaidGUIControlCharacterCustomizationDetails:_layout_title()
	local _, _, w, h = self._customization_name:text_rect()

	self._customization_name:set_h(h)
	self._customization_name:set_center_x(self._left_panel:w() / 2)
	self._title_description:set_x(self._customization_name:x())
end

-- Lines 145-155
function RaidGUIControlCharacterCustomizationDetails:_create_customization_image()
	local customization_image_panel_params = {
		name = "customization_image_panel",
		y = RaidGUIControlCharacterCustomizationDetails.CUSTOMIZATION_IMAGE_PANEL_Y,
		w = self._left_panel:w(),
		h = RaidGUIControlCharacterCustomizationDetails.CUSTOMIZATION_IMAGE_PANEL_H
	}
	local customization_image_panel = self._left_panel:panel(customization_image_panel_params)

	self:_set_customization_image(RaidGUIControlCharacterCustomizationDetails.DEFAULT_ICON_UPPER)
end

-- Lines 174-190
function RaidGUIControlCharacterCustomizationDetails:_set_customization_image(texture, texture_rect)
	local customization_image_panel = self._left_panel:child("customization_image_panel")

	if self._customization_image then
		customization_image_panel:remove(self._customization_image)

		self._customization_image = nil
	end

	local customization_image_params = {
		name = "customization_image",
		alpha = 0,
		texture = texture,
		texture_rect = texture_rect
	}
	self._customization_image = customization_image_panel:bitmap(customization_image_params)

	self._customization_image:set_center_x(customization_image_panel:w() / 2)
	self._customization_image:set_center_y(customization_image_panel:h() / 2)
end

-- Lines 192-228
function RaidGUIControlCharacterCustomizationDetails:_create_redeem_info()
	local redeem_description_params = {
		name = "redeem_description",
		alpha = 0,
		font = RaidGUIControlCharacterCustomizationDetails.FONT,
		font_size = RaidGUIControlCharacterCustomizationDetails.REDEEM_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlCharacterCustomizationDetails.REDEEM_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_redeem_worth_title", true)
	}
	local redeem_description = self._left_panel:text(redeem_description_params)
	local redeem_value_params = {
		text = "456 XP",
		name = "redeem_value",
		alpha = 0,
		font = RaidGUIControlCharacterCustomizationDetails.FONT,
		font_size = RaidGUIControlCharacterCustomizationDetails.REDEEM_VALUE_FONT_SIZE,
		color = RaidGUIControlCharacterCustomizationDetails.REDEEM_VALUE_COLOR
	}
	self._xp_redeem_value_text = self._left_panel:text(redeem_value_params)

	self:_layout_redeem_info()

	local redeem_xp_button_params = {
		name = "redeem_xp_button",
		alpha = 0,
		x = 0,
		y = self._left_panel:h() - RaidGUIControlCharacterCustomizationDetails.REDEEM_BUTTON_CENTER_Y_FROM_BOTTOM,
		text = self:translate("menu_loot_screen_redeem_xp", true),
		layer = RaidGuiBase.FOREGROUND_LAYER,
		on_click_callback = callback(self, self, "_on_click_redeem")
	}
	self.redeem_xp_button = self._left_panel:short_tertiary_button(redeem_xp_button_params)

	self.redeem_xp_button:set_center_x(self._left_panel:w() / 2)
end

-- Lines 230-243
function RaidGUIControlCharacterCustomizationDetails:_layout_redeem_info()
	local redeem_description = self._left_panel:child("redeem_description")
	local _, _, w, h = redeem_description:text_rect()

	redeem_description:set_w(w)
	redeem_description:set_h(h)
	redeem_description:set_center_x(self._left_panel:w() / 2)
	redeem_description:set_center_y(self._left_panel:h() - RaidGUIControlCharacterCustomizationDetails.REDEEM_DESCRIPTION_CENTER_Y_FROM_BOTTOM)

	local _, _, w, h = self._xp_redeem_value_text:text_rect()

	self._xp_redeem_value_text:set_w(w)
	self._xp_redeem_value_text:set_h(h)
	self._xp_redeem_value_text:set_center_x(self._left_panel:w() / 2)
	self._xp_redeem_value_text:set_center_y(self._left_panel:h() - RaidGUIControlCharacterCustomizationDetails.REDEEM_VALUE_CENTER_Y_FROM_BOTTOM)
end

-- Lines 245-253
function RaidGUIControlCharacterCustomizationDetails:_create_right_panel()
	local right_panel_params = {
		name = "right_panel",
		w = self._object:w() - self._left_panel:w(),
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)

	self._right_panel:set_right(self._object:w())
end

-- Lines 255-269
function RaidGUIControlCharacterCustomizationDetails:_create_description()
	local description_params = {
		vertical = "top",
		name = "description",
		wrap = true,
		align = "left",
		alpha = 0,
		text = "",
		y = RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_Y,
		w = RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_W,
		font = RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_COLOR
	}
	self._description = self._right_panel:text(description_params)

	self._description:set_right(self._right_panel:w())
end

-- Lines 271-287
function RaidGUIControlCharacterCustomizationDetails:_create_item_description_name()
	local item_type_params = {
		name = "item_type",
		wrap = true,
		align = "left",
		alpha = 0,
		vertical = "center",
		x = self._description:x(),
		y = RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_Y,
		w = RaidGUIControlMeleeWeaponRewardDetails.DESCRIPTION_W,
		h = RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_H,
		font = RaidGUIControlCharacterCustomizationDetails.FONT,
		font_size = RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_FONT_SIZE,
		color = RaidGUIControlCharacterCustomizationDetails.ITEM_TYPE_COLOR,
		text = self:translate("menu_loot_screen_character_customization", true)
	}
	self._item_description_name = self._right_panel:text(item_type_params)
end

-- Lines 289-323
function RaidGUIControlCharacterCustomizationDetails:_create_customization_info()
	local rarity_info_params = {
		top_offset_y = 15,
		name = "rarity_info",
		alpha = 0,
		text = "",
		w = RaidGUIControlCharacterCustomizationDetails.RARITY_W,
		h = RaidGUIControlCharacterCustomizationDetails.RARITY_H,
		icon = LootDropTweakData.RARITY_RARE,
		icon_color = Color.white,
		text_size = tweak_data.gui.font_sizes.size_24,
		text_color = tweak_data.gui.colors.raid_grey_effects
	}
	self._rarity_info = self._right_panel:info_icon(rarity_info_params)

	self._rarity_info:set_x(self._description:x())

	local nationality_info_params = {
		top_offset_y = 6,
		name = "nationality_info",
		alpha = 0,
		text = "",
		icon = "ico_flag_american",
		w = RaidGUIControlCharacterCustomizationDetails.NATIONALITY_W,
		h = RaidGUIControlCharacterCustomizationDetails.NATIONALITY_H,
		icon_color = Color.white,
		icon_h = RaidGUIControlCharacterCustomizationDetails.NATIONALITY_ICON_H,
		text_size = tweak_data.gui.font_sizes.size_24,
		text_color = tweak_data.gui.colors.raid_grey_effects
	}
	self._nationality_info = self._right_panel:info_icon(nationality_info_params)

	self._nationality_info:set_x(self._rarity_info:x() + self._rarity_info:w() + RaidGUIControlCharacterCustomizationDetails.NATIONALITY_PADDING_RIGHT)
end

-- Lines 325-331
function RaidGUIControlCharacterCustomizationDetails:_layout_description()
	local _, _, _, h = self._description:text_rect()

	self._description:set_h(h)
	self._rarity_info:set_y(self._description:y() + self._description:h() + RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_PADDING_DOWN)
	self._nationality_info:set_y(self._description:y() + self._description:h() + RaidGUIControlCharacterCustomizationDetails.DESCRIPTION_PADDING_DOWN)
end

-- Lines 333-416
function RaidGUIControlCharacterCustomizationDetails:show()
	RaidGUIControlCharacterCustomizationDetails.super.show(self)

	local duration = 1.9
	local t = 0
	local customization_image_panel = self._left_panel:child("customization_image_panel")
	local original_image_w, original_image_h = self._customization_image:size()
	local image_duration = 0.1
	local image_duration_slowdown = 1.75
	local title_description_y = self._title_description:y()
	local title_description_offset = 35
	local customization_name_y = self._customization_name:y()
	local customization_name_offset = 20
	local title_delay = 0
	local title_duration = 1
	local description_x = self._description:x()
	local description_offset = 30
	local item_type_x = self._item_description_name:x()
	local item_type_offset = 30

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, image_duration)

		self._customization_image:set_alpha(current_alpha)

		if t < image_duration then
			local current_scale = Easing.linear(t, 1.4, -0.35, image_duration)

			self._customization_image:set_size(original_image_w * current_scale, original_image_h * current_scale)
		elseif image_duration < t and t < image_duration + image_duration_slowdown then
			local current_scale = Easing.quartic_out(t - image_duration, 1.05, -0.05, image_duration_slowdown)

			self._customization_image:set_size(original_image_w * current_scale, original_image_h * current_scale)
		elseif t > image_duration + image_duration_slowdown then
			self._customization_image:set_size(original_image_w, original_image_h)
		end

		self._customization_image:set_center_x(customization_image_panel:w() / 2)
		self._customization_image:set_center_y(customization_image_panel:h() / 2)

		if title_delay < t then
			local current_title_alpha = Easing.quartic_out(t - title_delay, 0, 1, title_duration)

			self._title_description:set_alpha(current_title_alpha)
			self._customization_name:set_alpha(current_title_alpha)
			self._description:set_alpha(current_title_alpha)
			self._item_description_name:set_alpha(current_title_alpha)
			self._rarity_info:set_alpha(current_title_alpha)
			self._nationality_info:set_alpha(current_title_alpha)

			local title_description_current_offset = Easing.quartic_out(t - title_delay, title_description_offset, -title_description_offset, title_duration)

			self._title_description:set_y(title_description_y - title_description_current_offset)

			local customization_name_current_offset = Easing.quartic_out(t - title_delay, customization_name_offset, -customization_name_offset, title_duration)

			self._customization_name:set_y(customization_name_y - customization_name_current_offset)

			local description_current_offset = Easing.quartic_out(t - title_delay, -description_offset, description_offset, title_duration)

			self._description:set_x(description_x + description_current_offset)
			self._rarity_info:set_x(self._description:x())
			self._nationality_info:set_x(self._rarity_info:x() + self._rarity_info:w() + RaidGUIControlCharacterCustomizationDetails.NATIONALITY_PADDING_RIGHT)

			local item_type_current_offset = Easing.quartic_out(t - title_delay, -item_type_offset, item_type_offset, title_duration)

			self._item_description_name:set_x(item_type_x + item_type_current_offset)
		end
	end

	self._customization_image:set_alpha(1)
	self._customization_image:set_size(original_image_w, original_image_h)
	self._customization_image:set_center_x(customization_image_panel:w() / 2)
	self._customization_image:set_center_y(customization_image_panel:h() / 2)
	self._title_description:set_alpha(1)
	self._title_description:set_y(title_description_y)
	self._customization_name:set_alpha(1)
	self._customization_name:set_y(customization_name_y)
	self._description:set_alpha(1)
	self._description:set_x(description_x)
	self._item_description_name:set_alpha(1)
	self._item_description_name:set_x(item_type_x)
	self._rarity_info:set_alpha(1)
	self._rarity_info:set_x(self._description:x())
	self._nationality_info:set_alpha(1)
	self._nationality_info:set_x(self._rarity_info:x() + self._rarity_info:w() + RaidGUIControlCharacterCustomizationDetails.NATIONALITY_PADDING_RIGHT)
end

-- Lines 418-469
function RaidGUIControlCharacterCustomizationDetails:set_customization(customization)
	self._customization = customization

	self._customization_name:set_text(self:translate(customization.name, true))
	self._item_description_name:set_text(self:translate(customization.name, true))
	self:_layout_title()

	if customization.path_icon_large then
		self:_set_customization_image(customization.path_icon_large)

		if customization.part_type == CharacterCustomizationTweakData.PART_TYPE_LOWER then
			local w = self._customization_image:w()
			local h = self._customization_image:h()

			self._customization_image:set_w(w * RaidGUIControlCharacterCustomizationDetails.CUSTOMIZATION_IMAGE_LOWER_PART_SCALE_FACTOR)
			self._customization_image:set_h(h * RaidGUIControlCharacterCustomizationDetails.CUSTOMIZATION_IMAGE_LOWER_PART_SCALE_FACTOR)
			self._customization_image:set_center_x(self._customization_image:parent():w() / 2)
			self._customization_image:set_center_y(self._customization_image:parent():h() / 2)
		end
	else
		local icon = nil

		if customization.part_type == CharacterCustomizationTweakData.PART_TYPE_UPPER then
			icon = RaidGUIControlCharacterCustomizationDetails.DEFAULT_ICON_UPPER
		else
			icon = RaidGUIControlCharacterCustomizationDetails.DEFAULT_ICON_LOWER
		end

		self:_set_customization_image(tweak_data.gui.icons[icon].texture, tweak_data.gui.icons[icon].texture_rect)
	end

	self._rarity_info:set_icon(customization.rarity)
	self._rarity_info:set_text(customization.rarity, {
		color = tweak_data.gui.colors.raid_grey
	})

	local nationality = customization.nationalities[1]

	self._nationality_info:set_icon("character_creation_nationality_" .. tostring(nationality), {
		icon_h = RaidGUIControlCharacterCustomizationDetails.NATIONALITY_ICON_H
	})
	self._nationality_info:set_text("nationality_" .. tostring(nationality), {
		color = tweak_data.gui.colors.raid_grey
	})

	if customization.description then
		self._description:set_text(self:translate(customization.description))
	else
		self._description:set_text("")
	end

	self:_layout_description()
end

-- Lines 471-475
function RaidGUIControlCharacterCustomizationDetails:_on_click_redeem()
	local params = {
		callback = callback(self, self, "redeem"),
		xp = self._xp_redeem_value
	}

	managers.menu:show_redeem_character_customization_dialog(params)
end

-- Lines 477-488
function RaidGUIControlCharacterCustomizationDetails:redeem()
	managers.lootdrop:redeem_dropped_loot_for_xp()
	game_state_machine:current_state():recalculate_xp()
end

-- Lines 490-498
function RaidGUIControlCharacterCustomizationDetails:set_duplicate()
end
