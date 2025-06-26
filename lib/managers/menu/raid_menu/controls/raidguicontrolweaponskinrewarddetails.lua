RaidGUIControlWeaponSkinRewardDetails = RaidGUIControlWeaponSkinRewardDetails or class(RaidGUIControl)
RaidGUIControlWeaponSkinRewardDetails.DEFAULT_WIDTH = 400
RaidGUIControlWeaponSkinRewardDetails.HEIGHT = 400
RaidGUIControlWeaponSkinRewardDetails.LEFT_PANEL_W = 860
RaidGUIControlWeaponSkinRewardDetails.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlWeaponSkinRewardDetails.TITLE_DESCRIPTION_Y = 690
RaidGUIControlWeaponSkinRewardDetails.TITLE_DESCRIPTION_H = 50
RaidGUIControlWeaponSkinRewardDetails.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlWeaponSkinRewardDetails.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlWeaponSkinRewardDetails.TITLE_PADDING_TOP = -14
RaidGUIControlWeaponSkinRewardDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlWeaponSkinRewardDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlWeaponSkinRewardDetails.ITEM_TYPE_Y = 224
RaidGUIControlWeaponSkinRewardDetails.ITEM_TYPE_H = 72
RaidGUIControlWeaponSkinRewardDetails.ITEM_TYPE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlWeaponSkinRewardDetails.ITEM_TYPE_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlWeaponSkinRewardDetails.DESCRIPTION_Y = 304
RaidGUIControlWeaponSkinRewardDetails.DESCRIPTION_W = 416
RaidGUIControlWeaponSkinRewardDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlWeaponSkinRewardDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlWeaponSkinRewardDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlWeaponSkinRewardDetails.INFO_W = 128
RaidGUIControlWeaponSkinRewardDetails.INFO_H = 96
RaidGUIControlWeaponSkinRewardDetails.INFO_ICON_W = 128
RaidGUIControlWeaponSkinRewardDetails.INFO_ICON_H = 48
RaidGUIControlWeaponSkinRewardDetails.INFO_PADDING = 32
RaidGUIControlWeaponSkinRewardDetails.INFO_TEXT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlWeaponSkinRewardDetails.INFO_TEXT_COLOR = tweak_data.gui.colors.raid_grey_effects

function RaidGUIControlWeaponSkinRewardDetails:init(parent, params)
	RaidGUIControlWeaponSkinRewardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlWeaponSkinRewardDetails:init] Parameters not specified for the reward details")

		return
	end

	self:_layout_panel()
	self:_layout_left_panel()
	self:_layout_title()
	self:_layout_reward_image()
	self:_layout_right_panel()
	self:_layout_description()
	self:_layout_item_title()
	self:_layout_info()
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.w = control_params.w or self.DEFAULT_WIDTH
	control_params.h = control_params.h or self.HEIGHT
	control_params.layer = self._panel:layer() + 1
	self._object = self._panel:panel(control_params)
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_left_panel()
	self._left_panel = self._object:panel({
		name = "left_panel",
		w = self.LEFT_PANEL_W,
		h = self._object:h()
	})
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_title()
	self._title_description = self._left_panel:text({
		alpha = 0,
		layer = 10,
		vertical = "center",
		align = "left",
		name = "title_description",
		y = self.TITLE_DESCRIPTION_Y,
		h = self.TITLE_DESCRIPTION_H,
		font = self.FONT,
		font_size = self.TITLE_DESCRIPTION_FONT_SIZE,
		color = self.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	})
	local _, _, w = self._title_description:text_rect()

	self._title_description:set_w(w)

	self._title = self._left_panel:text({
		alpha = 0,
		wrap = true,
		layer = 10,
		vertical = "top",
		align = "left",
		name = "customization_name",
		y = self._title_description:y() + self._title_description:h() + self.TITLE_PADDING_TOP,
		w = self._left_panel:w() * 0.8,
		font = self.FONT,
		font_size = self.TITLE_FONT_SIZE,
		text = self._params.title,
		color = self.TITLE_COLOR
	})
	local _, _, _, h = self._title:text_rect()

	self._title:set_h(h)
	self._title:set_center_x(self._left_panel:w() / 2)
	self._title_description:set_x(self._title:x())
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_reward_image()
	self._reward_image_panel = self._left_panel:panel({
		layer = 10,
		name = "reward_image_panel",
		w = self._left_panel:w()
	})
	self._reward_image = self._reward_image_panel:bitmap({
		alpha = 0,
		name = "reward_image",
		texture = self._params.reward_image.texture,
		texture_rect = self._params.reward_image.texture_rect
	})

	self._reward_image:set_center_x(self._reward_image_panel:w() / 2)
	self._reward_image:set_center_y(self._reward_image_panel:h() / 2)
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_right_panel()
	self._right_panel = self._object:panel({
		name = "right_panel",
		w = self._object:w() - self._left_panel:w(),
		h = self._object:h()
	})

	self._right_panel:set_right(self._object:w())
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_description()
	self._description = self._right_panel:text({
		alpha = 0,
		wrap = true,
		layer = 10,
		vertical = "top",
		align = "left",
		name = "description",
		y = self.DESCRIPTION_Y,
		w = self.DESCRIPTION_W,
		font = self.DESCRIPTION_FONT,
		font_size = self.DESCRIPTION_FONT_SIZE,
		text = self._params.item_desc,
		color = self.DESCRIPTION_COLOR
	})

	self._description:set_right(self._right_panel:w())

	local _, _, _, h = self._description:text_rect()

	self._description:set_h(h)
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_item_title()
	self._item_title = self._right_panel:text({
		alpha = 0,
		vertical = "center",
		layer = 10,
		align = "left",
		name = "item_type",
		wrap = true,
		x = self._description:x(),
		y = self.ITEM_TYPE_Y,
		w = self.DESCRIPTION_W,
		h = self.ITEM_TYPE_H,
		font = self.FONT,
		font_size = self.ITEM_TYPE_FONT_SIZE,
		text = self._params.item_title,
		color = self.ITEM_TYPE_COLOR
	})
end

function RaidGUIControlWeaponSkinRewardDetails:_layout_info()
	self._info_panel = self._right_panel:panel({
		alpha = 0,
		visible = true,
		name = "info_panel",
		x = self._description:x(),
		y = self._description:bottom() + self.INFO_PADDING,
		h = self.INFO_H
	})

	if self._params.rarity then
		self._rarity = self._info_panel:info_icon({
			name = "rarity_info",
			top_offset_y = 15,
			w = self.INFO_H,
			h = self.INFO_H,
			icon = self._params.rarity or LootDropTweakData.RARITY_RARE,
			icon_color = Color.white,
			text = self._params.rarity,
			text_size = self.INFO_TEXT_SIZE,
			color = self.INFO_TEXT_COLOR
		})
	end

	if self._params.extra_info then
		local x = self._rarity and self._rarity:right() + self.INFO_PADDING or 0
		self._extra_info = self._info_panel:info_icon({
			name = "extra_info",
			top_offset_y = 6,
			x = x,
			w = self.INFO_W,
			h = self.INFO_H,
			icon = self._params.extra_info.icon,
			icon_w = self.INFO_ICON_W,
			icon_h = self.INFO_ICON_H,
			icon_color = Color.white,
			text = self._params.extra_info.text,
			text_size = self.INFO_TEXT_SIZE,
			color = self.INFO_TEXT_COLOR
		})
	end
end

function RaidGUIControlWeaponSkinRewardDetails:show()
	RaidGUIControlWeaponSkinRewardDetails.super.show(self)

	local duration = 1.9
	local t = 0
	local original_image_w, original_image_h = self._reward_image:size()
	local image_duration = 0.1
	local image_duration_slowdown = 1.75
	local title_description_y = self._title_description:y()
	local title_description_offset = 35
	local customization_name_y = self._title:y()
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
			self._title:set_alpha(current_title_alpha)
			self._description:set_alpha(current_title_alpha)
			self._item_title:set_alpha(current_title_alpha)
			self._info_panel:set_alpha(current_title_alpha)

			local title_description_current_offset = Easing.quartic_out(t - title_delay, title_description_offset, -title_description_offset, title_duration)

			self._title_description:set_y(title_description_y - title_description_current_offset)

			local customization_name_current_offset = Easing.quartic_out(t - title_delay, customization_name_offset, -customization_name_offset, title_duration)

			self._title:set_y(customization_name_y - customization_name_current_offset)

			local description_current_offset = Easing.quartic_out(t - title_delay, -description_offset, description_offset, title_duration)

			self._description:set_x(description_x + description_current_offset)
			self._info_panel:set_x(description_x + description_current_offset)

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
	self._title:set_alpha(1)
	self._title:set_y(customization_name_y)
	self._description:set_alpha(1)
	self._description:set_x(description_x)
	self._info_panel:set_alpha(1)
	self._info_panel:set_x(description_x)
	self._item_title:set_alpha(1)
	self._item_title:set_x(item_type_x)
end
