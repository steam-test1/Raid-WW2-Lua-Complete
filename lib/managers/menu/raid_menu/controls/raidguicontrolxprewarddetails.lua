RaidGUIControlXPRewardDetails = RaidGUIControlXPRewardDetails or class(RaidGUIControl)
RaidGUIControlXPRewardDetails.DEFAULT_WIDTH = 400
RaidGUIControlXPRewardDetails.HEIGHT = 400
RaidGUIControlXPRewardDetails.LEFT_PANEL_W = 860
RaidGUIControlXPRewardDetails.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_Y = 690
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_H = 50
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlXPRewardDetails.TITLE_PADDING_TOP = -14
RaidGUIControlXPRewardDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlXPRewardDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlXPRewardDetails.REWARD_ICON_PANEL_Y = 144
RaidGUIControlXPRewardDetails.REWARD_ICON_PANEL_H = 560
RaidGUIControlXPRewardDetails.REWARD_ICON = "rwd_xp_large"
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_Y = 224
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_H = 72
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlXPRewardDetails.DESCRIPTION_Y = 304
RaidGUIControlXPRewardDetails.DESCRIPTION_W = 416
RaidGUIControlXPRewardDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlXPRewardDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlXPRewardDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlXPRewardDetails.XP_VALUE_CENTER_Y_FROM_BOTTOM = 60
RaidGUIControlXPRewardDetails.XP_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_56
RaidGUIControlXPRewardDetails.XP_VALUE_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlXPRewardDetails.XP_VALUE_DESCRIPTION_PADDING = 20
RaidGUIControlXPRewardDetails.XP_VALUE_LABEL_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlXPRewardDetails.XP_VALUE_LABEL_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlXPRewardDetails.XP_VALUE_LABEL_VALUE_PADDING = 0

-- Lines 45-66
function RaidGUIControlXPRewardDetails:init(parent, params)
	RaidGUIControlXPRewardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlXPRewardDetails:init] Parameters not specified for the XP reward details")

		return
	end

	self:_create_control_panel()
	self:_create_left_panel()
	self:_create_title()
	self:_create_reward_image()
	self:_create_right_panel()
	self:_create_description()
	self:_create_xp_value()

	RaidGUIControlXPRewardDetails.gui = self
end

-- Lines 69-78
function RaidGUIControlXPRewardDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlXPRewardDetails.DEFAULT_WIDTH
	control_params.h = control_params.h or RaidGUIControlXPRewardDetails.HEIGHT
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 80-87
function RaidGUIControlXPRewardDetails:_create_left_panel()
	local left_panel_params = {
		name = "left_panel",
		w = RaidGUIControlXPRewardDetails.LEFT_PANEL_W,
		h = self._object:h()
	}
	self._left_panel = self._object:panel(left_panel_params)
end

-- Lines 89-122
function RaidGUIControlXPRewardDetails:_create_title()
	local title_description_params = {
		name = "title_description",
		vertical = "center",
		alpha = 0,
		align = "left",
		y = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_Y,
		h = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_H,
		font = RaidGUIControlXPRewardDetails.FONT,
		font_size = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	}
	self._title_description = self._left_panel:text(title_description_params)
	local _, _, w, _ = self._title_description:text_rect()

	self._title_description:set_w(w)

	local title_params = {
		vertical = "top",
		name = "customization_name",
		alpha = 0,
		align = "center",
		y = self._title_description:y() + self._title_description:h() + RaidGUIControlXPRewardDetails.TITLE_PADDING_TOP,
		font = RaidGUIControlXPRewardDetails.FONT,
		font_size = RaidGUIControlXPRewardDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlXPRewardDetails.TITLE_COLOR,
		text = self:translate("menu_loot_screen_experience_bonus_title", true)
	}
	self._customization_name = self._left_panel:text(title_params)

	self:_layout_title()
end

-- Lines 124-131
function RaidGUIControlXPRewardDetails:_layout_title()
	local _, _, w, h = self._customization_name:text_rect()

	self._customization_name:set_w(w)
	self._customization_name:set_h(h)
	self._customization_name:set_center_x(self._left_panel:w() / 2)
	self._title_description:set_x(self._customization_name:x())
end

-- Lines 133-151
function RaidGUIControlXPRewardDetails:_create_reward_image()
	local reward_image_panel_params = {
		name = "reward_image_panel",
		y = RaidGUIControlXPRewardDetails.REWARD_ICON_PANEL_Y,
		w = self._left_panel:w(),
		h = RaidGUIControlXPRewardDetails.REWARD_ICON_PANEL_H
	}
	self._reward_image_panel = self._left_panel:panel(reward_image_panel_params)
	local reward_image_params = {
		name = "reward_image",
		alpha = 0,
		texture = tweak_data.gui.icons[RaidGUIControlXPRewardDetails.REWARD_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlXPRewardDetails.REWARD_ICON].texture_rect
	}
	self._reward_image = self._reward_image_panel:bitmap(reward_image_params)

	self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
	self._reward_image:set_center_y(self._reward_image_panel:h() / 2)
end

-- Lines 153-176
function RaidGUIControlXPRewardDetails:_create_xp_value()
	local xp_value_params = {
		text = "456 XP",
		name = "xp_value",
		alpha = 0,
		font = RaidGUIControlXPRewardDetails.FONT,
		font_size = RaidGUIControlXPRewardDetails.XP_VALUE_FONT_SIZE,
		color = RaidGUIControlXPRewardDetails.XP_VALUE_COLOR
	}
	self._xp_value_text = self._right_panel:text(xp_value_params)
	local xp_value_label_params = {
		name = "xp_value_label",
		alpha = 0,
		font = RaidGUIControlXPRewardDetails.FONT,
		font_size = RaidGUIControlXPRewardDetails.XP_VALUE_LABEL_FONT_SIZE,
		color = RaidGUIControlXPRewardDetails.XP_VALUE_LABEL_COLOR,
		text = self:translate("xp_label", true)
	}
	self._xp_value_label = self._right_panel:text(xp_value_label_params)

	self:_layout_xp_value()
end

-- Lines 178-190
function RaidGUIControlXPRewardDetails:_layout_xp_value()
	local _, _, w, h = self._xp_value_text:text_rect()

	self._xp_value_text:set_w(w)
	self._xp_value_text:set_h(h)
	self._xp_value_text:set_x(self._description:x())
	self._xp_value_text:set_y(self._description:y() + self._description:h() + RaidGUIControlXPRewardDetails.XP_VALUE_DESCRIPTION_PADDING)

	local x1, y1, w1, h1 = self._xp_value_label:text_rect()

	self._xp_value_label:set_w(w1)
	self._xp_value_label:set_h(h1)
	self._xp_value_label:set_x(self._xp_value_text:x())
	self._xp_value_label:set_y(self._xp_value_text:y() + self._xp_value_text:h() + RaidGUIControlXPRewardDetails.XP_VALUE_LABEL_VALUE_PADDING)
end

-- Lines 192-277
function RaidGUIControlXPRewardDetails:show()
	RaidGUIControlXPRewardDetails.super.show(self)

	local duration = 1.9
	local t = 0
	local original_image_w, original_image_h = self._reward_image:size()
	local image_duration = 0.1
	local image_duration_slowdown = 1.75
	local title_description_y = self._title_description:y()
	local title_description_offset = 40
	local customization_name_y = self._customization_name:y()
	local customization_name_offset = 30
	local xp_value_offset = 20
	local title_delay = 0
	local title_duration = 1
	local description_x = self._description:x()
	local description_offset = 30
	local title_description_right_x = self._title_description_right:x()
	local title_description_right_offset = 30
	local xp_value_text_y = self._xp_value_text:y()
	local xp_value_label_y = self._xp_value_label:y()

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
			self._customization_name:set_alpha(current_title_alpha)
			self._xp_value_text:set_alpha(current_title_alpha)
			self._xp_value_label:set_alpha(current_title_alpha)
			self._description:set_alpha(current_title_alpha)
			self._title_description_right:set_alpha(current_title_alpha)

			local title_description_current_offset = Easing.quartic_out(t - title_delay, title_description_offset, -title_description_offset, title_duration)

			self._title_description:set_y(title_description_y - title_description_current_offset)

			local customization_name_current_offset = Easing.quartic_out(t - title_delay, customization_name_offset, -customization_name_offset, title_duration)

			self._customization_name:set_y(customization_name_y - customization_name_current_offset)

			local xp_value_current_offset = Easing.quartic_out(t - title_delay, xp_value_offset, -xp_value_offset, title_duration)

			self._xp_value_text:set_y(xp_value_text_y - xp_value_current_offset)

			local xp_value_label_current_offset = Easing.quartic_out(t - title_delay, xp_value_offset, -xp_value_offset, title_duration)

			self._xp_value_label:set_y(xp_value_label_y - xp_value_label_current_offset)

			local description_current_offset = Easing.quartic_out(t - title_delay, -description_offset, description_offset, title_duration)

			self._description:set_x(description_x + description_current_offset)

			local title_description_right_current_offset = Easing.quartic_out(t - title_delay, -title_description_right_offset, title_description_right_offset, title_duration)

			self._title_description_right:set_x(title_description_right_x + title_description_right_current_offset)
		end
	end

	self._reward_image:set_alpha(1)
	self._reward_image:set_size(original_image_w, original_image_h)
	self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
	self._reward_image:set_center_y(self._reward_image_panel:h() / 2)
	self._title_description:set_alpha(1)
	self._title_description:set_y(title_description_y)
	self._customization_name:set_alpha(1)
	self._customization_name:set_y(customization_name_y)
	self._description:set_alpha(1)
	self._description:set_x(description_x)
	self._title_description_right:set_alpha(1)
	self._title_description_right:set_x(title_description_right_x)
end

-- Lines 282-290
function RaidGUIControlXPRewardDetails:_create_right_panel()
	local right_panel_params = {
		name = "right_panel",
		w = self._object:w() - self._left_panel:w(),
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)

	self._right_panel:set_right(self._object:w())
end

-- Lines 292-326
function RaidGUIControlXPRewardDetails:_create_description()
	local description_params = {
		vertical = "top",
		name = "description",
		wrap = true,
		align = "left",
		alpha = 0,
		y = RaidGUIControlXPRewardDetails.DESCRIPTION_Y,
		w = RaidGUIControlXPRewardDetails.DESCRIPTION_W,
		font = RaidGUIControlXPRewardDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlXPRewardDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlXPRewardDetails.DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_experience_bonus_description")
	}
	self._description = self._right_panel:text(description_params)

	self._description:set_right(self._right_panel:w())

	local title_description_right_params = {
		name = "title_description_right",
		wrap = true,
		align = "left",
		alpha = 0,
		vertical = "center",
		x = self._description:x(),
		y = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_Y,
		w = RaidGUIControlXPRewardDetails.DESCRIPTION_W,
		h = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_H,
		font = RaidGUIControlXPRewardDetails.FONT,
		font_size = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_FONT_SIZE,
		color = RaidGUIControlXPRewardDetails.TITLE_DESCRIPTION_RIGHT_COLOR,
		text = self:translate("menu_loot_screen_bonus_xp_points", true)
	}
	self._title_description_right = self._right_panel:text(title_description_right_params)

	self:_layout_description()
end

-- Lines 328-332
function RaidGUIControlXPRewardDetails:_layout_description()
	local x, y, w, h = self._description:text_rect()

	self._description:set_w(w)
	self._description:set_h(h)
end

-- Lines 334-338
function RaidGUIControlXPRewardDetails:set_xp_reward(xp_reward)
	self._xp_value_text:set_text("+" .. xp_reward)
	self:_layout_xp_value()
end
