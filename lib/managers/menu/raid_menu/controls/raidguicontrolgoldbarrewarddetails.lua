RaidGUIControlGoldBarRewardDetails = RaidGUIControlGoldBarRewardDetails or class(RaidGUIControl)
RaidGUIControlGoldBarRewardDetails.DEFAULT_WIDTH = 400
RaidGUIControlGoldBarRewardDetails.HEIGHT = 400
RaidGUIControlGoldBarRewardDetails.LEFT_PANEL_W = 860
RaidGUIControlGoldBarRewardDetails.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_Y = 690
RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_H = 50
RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlGoldBarRewardDetails.TITLE_PADDING_TOP = -14
RaidGUIControlGoldBarRewardDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlGoldBarRewardDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlGoldBarRewardDetails.REWARD_ICON_PANEL_Y = 44
RaidGUIControlGoldBarRewardDetails.REWARD_ICON_PANEL_H = 660
RaidGUIControlGoldBarRewardDetails.REWARD_QUANTITY_FEW = 3
RaidGUIControlGoldBarRewardDetails.REWARD_QUANTITY_MANY = 10
RaidGUIControlGoldBarRewardDetails.REWARD_ICON_SINGLE = "gold_bar_single"
RaidGUIControlGoldBarRewardDetails.REWARD_ICON_FEW = "gold_bar_3"
RaidGUIControlGoldBarRewardDetails.REWARD_ICON_MANY = "gold_bar_box"
RaidGUIControlGoldBarRewardDetails.DESCRIPTION_Y = 304
RaidGUIControlGoldBarRewardDetails.DESCRIPTION_W = 416
RaidGUIControlGoldBarRewardDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlGoldBarRewardDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlGoldBarRewardDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlGoldBarRewardDetails.XP_VALUE_CENTER_Y_FROM_BOTTOM = 188
RaidGUIControlGoldBarRewardDetails.XP_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlGoldBarRewardDetails.XP_VALUE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_Y = 224
RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_H = 64
RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_COLOR = tweak_data.gui.colors.raid_white

-- Lines 46-64
function RaidGUIControlGoldBarRewardDetails:init(parent, params)
	RaidGUIControlGoldBarRewardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlGoldBarRewardDetails:init] Parameters not specified for the gold bar reward details")

		return
	end

	self:_create_control_panel()
	self:_create_left_panel()
	self:_create_gold_bar_value()
	self:_create_reward_image()
	self:_create_right_panel()
	self:_create_description()
	self:_create_item_type()
end

-- Lines 67-76
function RaidGUIControlGoldBarRewardDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlGoldBarRewardDetails.DEFAULT_WIDTH
	control_params.h = control_params.h or RaidGUIControlGoldBarRewardDetails.HEIGHT
	control_params.name = control_params.name .. "_gold_bars_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 78-85
function RaidGUIControlGoldBarRewardDetails:_create_left_panel()
	local left_panel_params = {
		name = "left_panel",
		w = RaidGUIControlGoldBarRewardDetails.LEFT_PANEL_W,
		h = self._object:h()
	}
	self._left_panel = self._object:panel(left_panel_params)
end

-- Lines 87-118
function RaidGUIControlGoldBarRewardDetails:_create_gold_bar_value()
	local title_description_params = {
		name = "title_description",
		vertical = "center",
		alpha = 0,
		align = "left",
		y = RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_Y,
		h = RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_H,
		font = RaidGUIControlGoldBarRewardDetails.FONT,
		font_size = RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlGoldBarRewardDetails.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	}
	self._title_description = self._left_panel:text(title_description_params)
	local _, _, w, _ = self._title_description:text_rect()

	self._title_description:set_w(w)

	local title_params = {
		vertical = "top",
		name = "gold_bars_name",
		alpha = 0,
		align = "center",
		text = "",
		y = self._title_description:y() + self._title_description:h() + RaidGUIControlGoldBarRewardDetails.TITLE_PADDING_TOP,
		font = RaidGUIControlGoldBarRewardDetails.FONT,
		font_size = RaidGUIControlGoldBarRewardDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlGoldBarRewardDetails.TITLE_COLOR
	}
	self._gold_bar_value = self._left_panel:text(title_params)

	self:_layout_gold_bar_value()
end

-- Lines 120-127
function RaidGUIControlGoldBarRewardDetails:_layout_gold_bar_value()
	local _, _, w, h = self._gold_bar_value:text_rect()

	self._gold_bar_value:set_w(w)
	self._gold_bar_value:set_h(h)
	self._gold_bar_value:set_center_x(self._left_panel:w() / 2)
	self._title_description:set_x(self._gold_bar_value:x())
end

-- Lines 129-147
function RaidGUIControlGoldBarRewardDetails:_create_reward_image()
	local reward_image_panel_params = {
		name = "reward_image_panel",
		y = RaidGUIControlGoldBarRewardDetails.REWARD_ICON_PANEL_Y,
		w = self._left_panel:w(),
		h = RaidGUIControlGoldBarRewardDetails.REWARD_ICON_PANEL_H
	}
	self._reward_image_panel = self._left_panel:panel(reward_image_panel_params)
	local reward_image_params = {
		name = "reward_image",
		alpha = 0,
		texture = tweak_data.gui.icons[RaidGUIControlGoldBarRewardDetails.REWARD_ICON_SINGLE].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlGoldBarRewardDetails.REWARD_ICON_SINGLE].texture_rect
	}
	self._reward_image = self._reward_image_panel:bitmap(reward_image_params)

	self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
	self._reward_image:set_center_y(self._reward_image_panel:h() / 2)
end

-- Lines 149-157
function RaidGUIControlGoldBarRewardDetails:_create_right_panel()
	local right_panel_params = {
		name = "right_panel",
		w = self._object:w() - self._left_panel:w(),
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)

	self._right_panel:set_right(self._object:w())
end

-- Lines 159-174
function RaidGUIControlGoldBarRewardDetails:_create_description()
	local description_params = {
		vertical = "top",
		name = "description",
		wrap = true,
		align = "left",
		alpha = 0,
		y = RaidGUIControlGoldBarRewardDetails.DESCRIPTION_Y,
		w = RaidGUIControlGoldBarRewardDetails.DESCRIPTION_W,
		font = RaidGUIControlGoldBarRewardDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlGoldBarRewardDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlGoldBarRewardDetails.DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_gold_bars_description")
	}
	self._description = self._right_panel:text(description_params)

	self._description:set_right(self._right_panel:w())
end

-- Lines 176-191
function RaidGUIControlGoldBarRewardDetails:_create_item_type()
	local item_type_params = {
		name = "item_type",
		vertical = "center",
		align = "left",
		alpha = 0,
		x = self._description:x(),
		y = RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_Y,
		w = self._right_panel:w(),
		h = RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_H,
		font = RaidGUIControlGoldBarRewardDetails.FONT,
		font_size = RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_FONT_SIZE,
		color = RaidGUIControlGoldBarRewardDetails.ITEM_TYPE_COLOR,
		text = self:translate("menu_loot_screen_gold_bars_type", true)
	}
	self._item_type = self._right_panel:text(item_type_params)
end

-- Lines 193-271
function RaidGUIControlGoldBarRewardDetails:show()
	RaidGUIControlGoldBarRewardDetails.super.show(self)

	local duration = 1.9
	local t = 0
	local original_image_w, original_image_h = self._reward_image:size()
	local image_duration = 0.1
	local image_duration_slowdown = 1.75
	local title_description_y = self._title_description:y()
	local title_description_offset = 35
	local gold_bar_value_y = self._gold_bar_value:y()
	local gold_bar_value_offset = 20
	local title_delay = 0
	local title_duration = 1
	local description_x = self._description:x()
	local description_offset = 30
	local item_type_x = self._item_type:x()
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
			self._gold_bar_value:set_alpha(current_title_alpha)
			self._description:set_alpha(current_title_alpha)
			self._item_type:set_alpha(current_title_alpha)

			local title_description_current_offset = Easing.quartic_out(t - title_delay, title_description_offset, -title_description_offset, title_duration)

			self._title_description:set_y(title_description_y - title_description_current_offset)

			local customization_name_current_offset = Easing.quartic_out(t - title_delay, gold_bar_value_offset, -gold_bar_value_offset, title_duration)

			self._gold_bar_value:set_y(gold_bar_value_y - customization_name_current_offset)

			local description_current_offset = Easing.quartic_out(t - title_delay, -description_offset, description_offset, title_duration)

			self._description:set_x(description_x + description_current_offset)

			local item_type_current_offset = Easing.quartic_out(t - title_delay, -item_type_offset, item_type_offset, title_duration)

			self._item_type:set_x(item_type_x + item_type_current_offset)
		end
	end

	self._reward_image:set_alpha(1)
	self._reward_image:set_size(original_image_w, original_image_h)
	self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
	self._reward_image:set_center_y(self._reward_image_panel:h() / 2)
	self._title_description:set_alpha(1)
	self._title_description:set_y(title_description_y)
	self._gold_bar_value:set_alpha(1)
	self._gold_bar_value:set_y(gold_bar_value_y)
	self._description:set_alpha(1)
	self._description:set_x(description_x)
	self._item_type:set_alpha(1)
	self._item_type:set_x(item_type_x)
end

-- Lines 273-292
function RaidGUIControlGoldBarRewardDetails:set_gold_bar_reward(amount)
	local text = ""

	if amount == 1 then
		text = self:translate("menu_loot_screen_gold_bars_single", true)
	else
		text = (amount or 0) .. " " .. self:translate("menu_loot_screen_gold_bars", true)
	end

	self._gold_bar_value:set_text(text)
	self:_layout_gold_bar_value()

	local icon = RaidGUIControlGoldBarRewardDetails.REWARD_ICON_SINGLE

	if amount and RaidGUIControlGoldBarRewardDetails.REWARD_QUANTITY_MANY <= amount then
		icon = RaidGUIControlGoldBarRewardDetails.REWARD_ICON_MANY
	elseif amount and RaidGUIControlGoldBarRewardDetails.REWARD_QUANTITY_FEW <= amount then
		icon = RaidGUIControlGoldBarRewardDetails.REWARD_ICON_FEW
	end

	self._reward_image:set_image(tweak_data.gui.icons[icon].texture)
	self._reward_image:set_texture_rect(unpack(tweak_data.gui.icons[icon].texture_rect))
end
