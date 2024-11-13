RaidGUIControlRewardCardPack = RaidGUIControlRewardCardPack or class(RaidGUIControl)
RaidGUIControlRewardCardPack.DEFAULT_WIDTH = 400
RaidGUIControlRewardCardPack.HEIGHT = 400
RaidGUIControlRewardCardPack.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlRewardCardPack.LEFT_PANEL_W = 860
RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_Y = 690
RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_H = 50
RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlRewardCardPack.TITLE_PADDING_TOP = -14
RaidGUIControlRewardCardPack.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlRewardCardPack.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlRewardCardPack.CARD_PACK_Y_OFFSET = 60
RaidGUIControlRewardCardPack.DESCRIPTION_Y = 304
RaidGUIControlRewardCardPack.DESCRIPTION_W = 416
RaidGUIControlRewardCardPack.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlRewardCardPack.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlRewardCardPack.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlRewardCardPack.DESCRIPTION_PADDING_DOWN = 32
RaidGUIControlRewardCardPack.ITEM_TYPE_Y = 224
RaidGUIControlRewardCardPack.ITEM_TYPE_H = 64
RaidGUIControlRewardCardPack.ITEM_TYPE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlRewardCardPack.ITEM_TYPE_COLOR = tweak_data.gui.colors.raid_white

function RaidGUIControlRewardCardPack:init(parent, params)
	RaidGUIControlRewardCardPack.super.init(self, parent, params)
	self:_create_panel()
	self:_create_left_panel()
	self:_create_cards_control()
	self:_create_right_panel()
	self:_create_description()
	self:_create_item_description_name()
end

function RaidGUIControlRewardCardPack:_create_panel()
	local panel_params = {
		layer = nil,
		h = nil,
		w = nil,
		y = nil,
		x = nil,
		visible = false,
		name = "local_player_card_pack_reward_panel",
		x = self._params.x or 0,
		y = self._params.y or 0,
		w = self._params.w,
		h = self._params.h,
		layer = self._panel:layer() + 1
	}
	self._object = self._panel:panel(panel_params)
end

function RaidGUIControlRewardCardPack:_create_control_panel()
	local control_params = clone(self._params)
	control_params.x = control_params.x
	control_params.w = control_params.w or RaidGUIControlRewardCardPack.DEFAULT_WIDTH
	control_params.h = control_params.h or RaidGUIControlRewardCardPack.HEIGHT
	control_params.name = control_params.name .. "_card_pack_panel"
	control_params.layer = self._panel:layer() + 1
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlRewardCardPack:_create_left_panel()
	local left_panel_params = {
		h = nil,
		w = nil,
		name = "left_panel",
		w = RaidGUIControlRewardCardPack.LEFT_PANEL_W,
		h = self._object:h()
	}
	self._left_panel = self._object:panel(left_panel_params)
end

function RaidGUIControlRewardCardPack:_create_title()
	local title_description_params = {
		font = nil,
		h = nil,
		y = nil,
		alpha = 0,
		name = "title_description",
		text = nil,
		vertical = "center",
		align = "left",
		color = nil,
		font_size = nil,
		y = RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_Y,
		h = RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_H,
		font = RaidGUIControlRewardCardPack.FONT,
		font_size = RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlRewardCardPack.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	}
	self._title_description = self._left_panel:text(title_description_params)

	self._title_description:set_debug(true)

	local _, _, w, _ = self._title_description:text_rect()

	self._title_description:set_w(w)

	local title_params = {
		font = nil,
		y = nil,
		alpha = 0,
		name = "pack_title",
		text = nil,
		vertical = "top",
		align = "center",
		color = nil,
		font_size = nil,
		y = self._title_description:y() + self._title_description:h() + RaidGUIControlRewardCardPack.TITLE_PADDING_TOP,
		font = RaidGUIControlRewardCardPack.FONT,
		font_size = RaidGUIControlRewardCardPack.TITLE_FONT_SIZE,
		color = RaidGUIControlRewardCardPack.TITLE_COLOR,
		text = self:translate("menu_loot_screen_card_pack", true)
	}
	self._pack_title = self._left_panel:text(title_params)
	local _, _, w, h = self._pack_title:text_rect()

	self._pack_title:set_w(w)
	self._pack_title:set_h(h)
	self._pack_title:set_center_x(self._left_panel:w() / 2)
	self._title_description:set_x(self._pack_title:x())
end

function RaidGUIControlRewardCardPack:_create_cards_control()
	local cards_control_params = {
		item_params = nil,
		h = 900,
		w = 780,
		y = 0,
		x = 0,
		visible = false,
		name = "cards_control",
		item_params = {
			item_w = 256,
			wrapper_h = 600,
			item_h = 352
		}
	}
	self._cards_control = self._left_panel:create_custom_control(RaidGUIControlLootRewardCards, cards_control_params)

	self._cards_control:set_center_x(self._left_panel:w() / 2 + 38)
	self._cards_control:set_center_y(self._left_panel:h() / 2 + RaidGUIControlRewardCardPack.CARD_PACK_Y_OFFSET)
end

function RaidGUIControlRewardCardPack:_create_right_panel()
	local right_panel_params = {
		h = nil,
		w = nil,
		name = "right_panel",
		w = self._object:w() - self._left_panel:w(),
		h = self._object:h()
	}
	self._right_panel = self._object:panel(right_panel_params)

	self._right_panel:set_right(self._object:w())
end

function RaidGUIControlRewardCardPack:_create_description()
	local description_params = {
		font = nil,
		w = nil,
		y = nil,
		alpha = 0,
		name = "description",
		text = nil,
		wrap = true,
		vertical = "top",
		align = "left",
		color = nil,
		font_size = nil,
		y = RaidGUIControlRewardCardPack.DESCRIPTION_Y,
		w = RaidGUIControlRewardCardPack.DESCRIPTION_W,
		font = RaidGUIControlRewardCardPack.DESCRIPTION_FONT,
		font_size = RaidGUIControlRewardCardPack.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlRewardCardPack.DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_card_pack_description")
	}
	self._description = self._right_panel:text(description_params)

	self._description:set_right(self._right_panel:w())
end

function RaidGUIControlRewardCardPack:_create_item_description_name()
	local item_type_params = {
		font = nil,
		h = nil,
		w = nil,
		y = nil,
		x = nil,
		alpha = 0,
		name = "item_type",
		text = nil,
		vertical = "center",
		align = "left",
		color = nil,
		font_size = nil,
		x = self._description:x(),
		y = RaidGUIControlRewardCardPack.ITEM_TYPE_Y,
		w = self._right_panel:w(),
		h = RaidGUIControlRewardCardPack.ITEM_TYPE_H,
		font = RaidGUIControlRewardCardPack.FONT,
		font_size = RaidGUIControlRewardCardPack.ITEM_TYPE_FONT_SIZE,
		color = RaidGUIControlRewardCardPack.ITEM_TYPE_COLOR,
		text = self:translate("menu_loot_screen_card_pack", true)
	}
	self._item_description_name = self._right_panel:text(item_type_params)
end

function RaidGUIControlRewardCardPack:show()
	RaidGUIControlRewardCardPack.super.show(self)

	local duration = 1.9
	local t = 0
	local image_duration = 0.1
	local image_duration_slowdown = 1.75
	local title_delay = 0
	local title_duration = 1
	local description_x = self._description:x()
	local description_offset = 30
	local item_description_name_x = self._item_description_name:x()
	local item_description_name_offset = 30

	self._cards_control:animate_show()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, image_duration)

		if title_delay < t then
			local current_title_alpha = Easing.quartic_out(t - title_delay, 0, 1, title_duration)

			self._description:set_alpha(current_title_alpha)
			self._item_description_name:set_alpha(current_title_alpha)

			local description_current_offset = Easing.quartic_out(t - title_delay, -description_offset, description_offset, title_duration)

			self._description:set_x(description_x + description_current_offset)

			local item_type_current_offset = Easing.quartic_out(t - title_delay, -item_description_name_offset, item_description_name_offset, title_duration)

			self._item_description_name:set_x(item_description_name_x + item_type_current_offset)
		end
	end

	self._description:set_alpha(1)
	self._description:set_x(description_x)
	self._item_description_name:set_alpha(1)
	self._item_description_name:set_x(item_description_name_x)
end

function RaidGUIControlRewardCardPack:set_cards(card_list)
	self._cards_control:set_cards(card_list)
end

function RaidGUIControlRewardCardPack:is_selected_card_revealed()
	return self._selected_item_idx ~= nil and self._cards_control:get_items()[self._selected_item_idx]:revealed() or false
end

function RaidGUIControlRewardCardPack:selected_item_idx()
	return self._selected_item_idx
end

function RaidGUIControlRewardCardPack:set_selected(flag)
	self._selected = flag
	self._selected_item_idx = 0

	if flag then
		self._cards_control:get_items()[1]:select()

		self._selected_item_idx = 1
	else
		for _, item in pairs(self._cards_control:get_items()) do
			item:unselect()
		end

		self._selected_item_idx = 0
	end
end

function RaidGUIControlRewardCardPack:move_left()
	if self._selected then
		local new_item_idx = self._selected_item_idx - 1

		if new_item_idx < 1 then
			self._selected_item_idx = 1
		else
			self._cards_control:get_items()[self._selected_item_idx]:unselect()

			self._selected_item_idx = new_item_idx

			self._cards_control:get_items()[self._selected_item_idx]:select()
		end

		return true
	end
end

function RaidGUIControlRewardCardPack:move_right()
	if self._selected then
		local new_item_idx = self._selected_item_idx + 1

		if RaidGUIControlLootRewardCards.CARD_COUNT < new_item_idx then
			self._selected_item_idx = RaidGUIControlLootRewardCards.CARD_COUNT
		else
			self._cards_control:get_items()[self._selected_item_idx]:unselect()

			self._selected_item_idx = new_item_idx

			self._cards_control:get_items()[self._selected_item_idx]:select()
		end

		return true
	end
end

function RaidGUIControlRewardCardPack:confirm_pressed()
	local selected_card_item = self._cards_control:get_items()[self._selected_item_idx]

	if selected_card_item then
		selected_card_item:confirm_pressed()

		return true
	end

	return false
end
