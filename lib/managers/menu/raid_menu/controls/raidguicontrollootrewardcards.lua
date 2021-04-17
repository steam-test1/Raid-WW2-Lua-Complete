RaidGUIControlLootRewardCards = RaidGUIControlLootRewardCards or class(RaidGUIControl)
RaidGUIControlLootRewardCards.CARD_COUNT = 3
RaidGUIControlLootRewardCards.INITIAL_CARD_Y = 150
RaidGUIControlLootRewardCards.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_Y = 609
RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_H = 50
RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlLootRewardCards.TITLE_PADDING_TOP = -14
RaidGUIControlLootRewardCards.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_76
RaidGUIControlLootRewardCards.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlLootRewardCards.CARD_DETAILS_Y = 533

function RaidGUIControlLootRewardCards:init(parent, params)
	RaidGUIControlLootRewardCards.super.init(self, parent, params)

	RaidGUIControlLootRewardCards.control = self
	self._item_params = self._params.item_params
	self._items = {}

	self:layout()
end

function RaidGUIControlLootRewardCards:layout()
	self._object = self._panel:panel({
		name = "loot_rewards_cards_panel",
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	})

	if self._params.loot_list then
		self:_create_items()
	end

	self:_create_title()
	self:_create_card_details()
end

function RaidGUIControlLootRewardCards:_create_items()
	local horizontal_spacing = 0

	if RaidGUIControlLootRewardCards.CARD_COUNT > 1 then
		horizontal_spacing = math.floor((self._object:w() - RaidGUIControlLootRewardCards.CARD_COUNT * self._item_params.item_w) / (RaidGUIControlLootRewardCards.CARD_COUNT - 1))
	end

	horizontal_spacing = 0

	for i = 1, RaidGUIControlLootRewardCards.CARD_COUNT do
		local item_params = {
			x = (self._item_params.item_w + horizontal_spacing) * (i - 1),
			y = RaidGUIControlLootRewardCards.INITIAL_CARD_Y,
			item_w = self._item_params.item_w,
			item_h = self._item_params.item_h,
			wrapper_h = self._item_params.wrapper_h,
			name = "loot_reward_card_" .. i,
			item_idx = i,
			hide_card_details = true,
			click_callback = callback(self, self, "on_card_click"),
			hover_callback = callback(self, self, "on_card_hover")
		}
		local card_key_name = self._params.loot_list[i].entry
		local card_data = tweak_data.challenge_cards:get_card_by_key_name(card_key_name)
		local item = self._object:create_custom_control(RaidGUIControlLootCardDetails, item_params, card_data)
		self._items[i] = item
	end
end

function RaidGUIControlLootRewardCards:_create_title()
	local title_panel_params = {
		name = "title_panel"
	}
	self._title_panel = self._object:panel(title_panel_params)
	local title_description_params = {
		name = "title_description",
		vertical = "center",
		alpha = 0,
		align = "left",
		y = RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_Y,
		h = RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_H,
		font = RaidGUIControlLootRewardCards.FONT,
		font_size = RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlLootRewardCards.TITLE_DESCRIPTION_COLOR,
		text = self:translate("menu_loot_screen_bracket_unlocked_title", true)
	}
	self._title_description = self._title_panel:text(title_description_params)
	local _, _, w, _ = self._title_description:text_rect()

	self._title_description:set_w(w)

	local title_params = {
		vertical = "top",
		name = "pack_title",
		alpha = 0,
		align = "center",
		y = self._title_description:y() + self._title_description:h() + RaidGUIControlLootRewardCards.TITLE_PADDING_TOP,
		font = RaidGUIControlLootRewardCards.FONT,
		font_size = RaidGUIControlLootRewardCards.TITLE_FONT_SIZE,
		color = RaidGUIControlLootRewardCards.TITLE_COLOR,
		text = self:translate("menu_loot_screen_card_pack", true)
	}
	self._pack_title = self._title_panel:text(title_params)
	local _, _, w, h = self._pack_title:text_rect()

	self._pack_title:set_w(w)
	self._pack_title:set_h(h)
	self._pack_title:set_center_x(self._title_panel:w() / 2)
	self._title_description:set_x(self._pack_title:x())
end

function RaidGUIControlLootRewardCards:_create_card_details()
	local details_panel_params = {
		alpha = 0,
		name = "details_panel",
		y = RaidGUIControlLootRewardCards.CARD_DETAILS_Y
	}
	self._details_panel = self._object:panel(details_panel_params)
	local bonus_image_params = {
		name = "bonus_image_" .. self._name,
		texture = tweak_data.gui.icons.ico_bonus.texture,
		texture_rect = tweak_data.gui.icons.ico_bonus.texture_rect
	}
	self._bonus_image = self._details_panel:bitmap(bonus_image_params)
	local malus_image_params = {
		name = "malus_image_" .. self._name,
		y = self._bonus_image:y() + self._bonus_image:h() + 32,
		texture = tweak_data.gui.icons.ico_malus.texture,
		texture_rect = tweak_data.gui.icons.ico_malus.texture_rect
	}
	self._malus_image = self._details_panel:bitmap(malus_image_params)
	local bonus_label_params = {
		vertical = "center",
		h = 64,
		wrap = true,
		w = 390,
		align = "left",
		text = "",
		name = "bonus_label_" .. self._name,
		x = self._bonus_image:x() + self._bonus_image:w() + 16,
		y = self._bonus_image:y(),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	}
	self._bonus_label = self._details_panel:label(bonus_label_params)
	local malus_label_params = {
		vertical = "center",
		h = 64,
		wrap = true,
		w = 390,
		align = "left",
		text = "",
		name = "malus_label_" .. self._name,
		x = self._malus_image:x() + self._malus_image:w() + 16,
		y = self._malus_image:y(),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey
	}
	self._malus_label = self._details_panel:label(malus_label_params)
end

function RaidGUIControlLootRewardCards:get_items()
	return self._items
end

function RaidGUIControlLootRewardCards:set_cards(loot_list)
	self._params.loot_list = loot_list

	self:_create_items()
end

function RaidGUIControlLootRewardCards:mouse_released(o, button, x, y)
	return false
end

function RaidGUIControlLootRewardCards:on_card_click(item_data, revealed)
	if not revealed then
		self:show_card_details(item_data.key_name, item_data.positive_description, item_data.negative_description)
	end
end

function RaidGUIControlLootRewardCards:on_card_hover(item_data, revealed)
	if revealed and item_data.key_name ~= self._shown_card_key then
		self:show_card_details(item_data.key_name, item_data.positive_description, item_data.negative_description)
	end
end

function RaidGUIControlLootRewardCards:show_card_details(key_name, positive_description, negative_description)
	self._pack_title:stop()
	self._pack_title:animate(callback(self, self, "_animate_show_card_details"), key_name, positive_description, negative_description)
end

function RaidGUIControlLootRewardCards:_animate_show_card_details(object, key_name, positive_description, negative_description)
	local fade_out_duration = 0.2
	local fade_out_object = nil

	if self._pack_title:alpha() > 0 then
		fade_out_object = self._title_panel
	else
		fade_out_object = self._details_panel
	end

	local t = (1 - fade_out_object:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		fade_out_object:set_alpha(current_alpha)
	end

	self._title_panel:set_alpha(0)
	self._details_panel:set_alpha(0)
	self._bonus_label:set_text(managers.localization:text(positive_description.desc_id, positive_description.desc_params))

	local bonus_label_center_y = self._bonus_label:center_y()
	local _, _, _, h = self._bonus_label:text_rect()

	self._bonus_label:set_h(h)
	self._bonus_label:set_center_y(self._bonus_image:center_y())

	if self._bonus_label:y() < self._bonus_image:y() then
		self._bonus_label:set_y(self._bonus_image:y())
	end

	if negative_description ~= nil then
		self._malus_label:set_text(managers.localization:text(negative_description.desc_id, negative_description.desc_params))

		local malus_image_y = math.max(self._bonus_image:y() + self._bonus_image:h() + 32, self._bonus_label:y() + self._bonus_label:h() + 32)

		self._malus_image:set_y(malus_image_y)
		self._malus_label:set_y(malus_image_y)

		local malus_label_center_y = self._malus_label:center_y()
		local _, _, _, h = self._malus_label:text_rect()

		self._malus_label:set_h(h)
		self._malus_label:set_center_y(self._malus_image:center_y())

		if self._malus_label:y() < self._malus_image:y() then
			self._malus_label:set_y(self._malus_image:y())
		end

		self._malus_image:set_visible(true)
		self._malus_label:set_visible(true)
	else
		self._malus_image:set_visible(false)
		self._malus_label:set_visible(false)
	end

	self._shown_card_key = key_name
	local fade_in_duration = 0.25
	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_in_duration)

		self._details_panel:set_alpha(current_alpha)
	end

	self._details_panel:set_alpha(1)
end

function RaidGUIControlLootRewardCards:animate_show()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show"))
end

function RaidGUIControlLootRewardCards:_animate_show(panel)
	local initial_offset = {}
	local timings = {}

	for i = 1, RaidGUIControlLootRewardCards.CARD_COUNT do
		local offset = math.random(50, 150)

		table.insert(initial_offset, offset)

		local timing = math.random() * 0.4 + 0.9

		table.insert(timings, timing)
	end

	local duration = 1.9
	local t = 0
	local card_duration_fast_time_percentage = 0.25
	local card_duration_slow_time_percentage = 0.75
	local card_fast_move_percentage = 0.8
	local title_description_y = self._title_description:y()
	local title_description_offset = 35
	local pack_title_y = self._pack_title:y()
	local pack_title_offset = 20
	local title_delay = 0
	local title_duration = 1

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_title_alpha = Easing.quartic_out(t - title_delay, 0, 1, title_duration)

		self._title_description:set_alpha(current_title_alpha)
		self._pack_title:set_alpha(current_title_alpha)

		local title_description_current_offset = Easing.quartic_out(t - title_delay, title_description_offset, -title_description_offset, title_duration)

		self._title_description:set_y(title_description_y - title_description_current_offset)

		local customization_name_current_offset = Easing.quartic_out(t - title_delay, pack_title_offset, -pack_title_offset, title_duration)

		self._pack_title:set_y(pack_title_y - customization_name_current_offset)

		for i = 1, RaidGUIControlLootRewardCards.CARD_COUNT do
			local current_alpha = Easing.quartic_out(t, 0, 1, duration)

			self._items[i]:set_alpha(current_alpha)

			local current_offset = nil

			if t < timings[i] * card_duration_fast_time_percentage then
				current_offset = Easing.linear(t, initial_offset[i], -initial_offset[i] * card_fast_move_percentage, timings[i] * card_duration_fast_time_percentage)
			else
				current_offset = Easing.quartic_out(t - timings[i] * card_duration_fast_time_percentage, initial_offset[i] * (1 - card_fast_move_percentage), -initial_offset[i] * (1 - card_fast_move_percentage), timings[i] * card_duration_slow_time_percentage)
			end

			self._items[i]:set_y(RaidGUIControlLootRewardCards.INITIAL_CARD_Y - current_offset)
		end
	end

	self._title_description:set_alpha(1)
	self._title_description:set_y(title_description_y)
	self._pack_title:set_alpha(1)
	self._pack_title:set_y(pack_title_y)

	for i = 1, RaidGUIControlLootRewardCards.CARD_COUNT do
		self._items[i]:set_alpha(1)
		self._items[i]:set_y(RaidGUIControlLootRewardCards.INITIAL_CARD_Y)
	end
end
