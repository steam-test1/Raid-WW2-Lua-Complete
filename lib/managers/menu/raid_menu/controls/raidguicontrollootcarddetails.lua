RaidGUIControlLootCardDetails = RaidGUIControlLootCardDetails or class(RaidGUIControl)

-- Lines 3-40
function RaidGUIControlLootCardDetails:init(parent, params, item_data)
	RaidGUIControlLootCardDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlLootCardDetails:init] Parameters not specified for the card details")

		return
	end

	self._item_data = item_data
	local object_params = clone(params)
	object_params.w = params.item_w
	object_params.h = params.wrapper_h
	object_params.layer = self._panel:layer() + 1
	self._object = self._panel:panel(object_params)
	self._params.panel = nil
	self._card_panel = self._object:panel({
		y = 10,
		x = 5,
		name = "card_panel_" .. self._name,
		w = params.item_w - 10,
		h = params.item_h - 20,
		layer = object_params.layer + 1
	})
	self._select_background_panel = self._object:panel({
		visible = false,
		y = 0,
		x = 0,
		layer = 1,
		w = params.item_w,
		h = params.item_h
	})
	self._select_background = self._select_background_panel:rect({
		layer = 2,
		color = tweak_data.gui.colors.raid_select_card_background
	})
	self._top_select_triangle = self._select_background_panel:image({
		layer = 15,
		y = 0,
		x = 0,
		w = RaidGUIControlCardWithSelector.SELECT_TRINGLE_SIZE,
		h = RaidGUIControlCardWithSelector.SELECT_TRINGLE_SIZE,
		texture = tweak_data.gui.icons.ico_sel_rect_top_left.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_top_left.texture_rect
	})
	self._bottom_select_triangle = self._select_background_panel:image({
		layer = 15,
		x = self._select_background_panel:w() - RaidGUIControlCardWithSelector.SELECT_TRINGLE_SIZE,
		y = self._select_background_panel:h() - RaidGUIControlCardWithSelector.SELECT_TRINGLE_SIZE,
		w = RaidGUIControlCardWithSelector.SELECT_TRINGLE_SIZE,
		h = RaidGUIControlCardWithSelector.SELECT_TRINGLE_SIZE,
		texture = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture_rect
	})

	self:_create_empty_card()

	self._sound_source = SoundDevice:create_source("challenge_card")
end

-- Lines 42-43
function RaidGUIControlLootCardDetails:close()
end

-- Lines 46-52
function RaidGUIControlLootCardDetails:_create_empty_card()
	local card_back_texture, card_back_texture_rect = managers.challenge_cards:get_cards_back_texture(self._item_data)
	self._card_empty = self._card_panel:image({
		name = "card_empty",
		y = 0,
		x = 0,
		layer = self._card_panel:layer() + 1,
		w = self._card_panel:w(),
		h = self._card_panel:h(),
		texture = card_back_texture,
		texture_rect = card_back_texture_rect
	})
	self._state = "card_empty"
end

-- Lines 54-109
function RaidGUIControlLootCardDetails:_create_card_details()
	local card_params = clone(self._params)
	card_params.x = 0
	card_params.y = 0
	card_params.w = self._params.item_w
	card_params.h = self._params.item_h
	card_params.card_image_params = {
		x = 0,
		y = 0,
		w = self._card_panel:w(),
		h = self._card_panel:h()
	}
	card_params.layer = self._card_panel:layer() + 1
	self._card_control = self._card_panel:create_custom_control(RaidGUIControlCardBase, card_params, self._item_data)

	self._card_control:set_card(self._item_data)

	self._bonus_image = self._object:image({
		h = 64,
		visible = false,
		w = 64,
		x = 0,
		name = "bonus_image_" .. self._name,
		layer = self._card_panel:layer(),
		y = self._card_panel:h() + 20,
		layer = self._card_control:layer(),
		texture = tweak_data.gui.icons.ico_bonus.texture,
		texture_rect = tweak_data.gui.icons.ico_bonus.texture_rect
	})
	self._malus_image = self._object:image({
		h = 64,
		visible = false,
		w = 64,
		x = 0,
		name = "malus_image_" .. self._name,
		y = self._bonus_image:y() + self._bonus_image:h() + 26,
		layer = self._card_control:layer(),
		texture = tweak_data.gui.icons.ico_malus.texture,
		texture_rect = tweak_data.gui.icons.ico_malus.texture_rect
	})
	self._bonus_label = self._object:label({
		vertical = "center",
		h = 64,
		wrap = true,
		align = "left",
		visible = false,
		text = "",
		name = "bonus_label_" .. self._name,
		layer = self._card_control:layer(),
		x = self._bonus_image:x() + self._bonus_image:w(),
		y = self._bonus_image:y(),
		w = self._card_control:w() - self._bonus_image:w() - 10,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_white
	})
	self._malus_label = self._object:label({
		vertical = "center",
		h = 64,
		wrap = true,
		align = "left",
		visible = false,
		text = "",
		name = "malus_label_" .. self._name,
		layer = self._card_control:layer(),
		x = self._malus_image:x() + self._malus_image:w(),
		y = self._malus_image:y(),
		w = self._bonus_label:w(),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_white
	})

	if self._item_data and self._item_data.effects then
		for _, effect_data in ipairs(self._item_data.effects) do
			if effect_data.type == ChallengeCardsTweakData.EFFECT_TYPE_POSITIVE then
				self._bonus_label:set_text(managers.localization:text(self._item_data.positive_description.desc_id, self._item_data.positive_description.desc_params))
				self._bonus_image:set_visible(true)
				self._bonus_label:set_visible(true)
			elseif effect_data.type == ChallengeCardsTweakData.EFFECT_TYPE_NEGATIVE then
				self._malus_label:set_text(managers.localization:text(self._item_data.negative_description.desc_id, self._item_data.negative_description.desc_params))
				self._malus_image:set_visible(true)
				self._malus_label:set_visible(true)
			end
		end
	end

	self._card_control:set_alpha(0)
	self._bonus_image:set_alpha(0)
	self._malus_image:set_alpha(0)
	self._bonus_label:set_alpha(0)
	self._malus_label:set_alpha(0)
end

-- Lines 111-113
function RaidGUIControlLootCardDetails:_switch_card()
end

-- Lines 115-117
function RaidGUIControlLootCardDetails:set_debug(value)
	self._object:set_debug(value)
end

-- Lines 119-121
function RaidGUIControlLootCardDetails:revealed()
	return self._state == "card_details"
end

-- Lines 123-132
function RaidGUIControlLootCardDetails:_reveal_card()
	if self._state == "card_empty" then
		self._state = "card_details"

		self._card_panel._engine_panel:stop()
		self._card_panel._engine_panel:animate(callback(self, self, "_animate_show_card"))
		self:_create_card_details()
	end
end

-- Lines 134-141
function RaidGUIControlLootCardDetails:on_mouse_released()
	if self._params.click_callback then
		self._params.click_callback(self._item_data, self._state == "card_details")
	end

	self:_reveal_card()
end

-- Lines 144-146
function RaidGUIControlLootCardDetails:confirm_pressed()
	self:on_mouse_released()
end

-- Lines 148-157
function RaidGUIControlLootCardDetails:on_mouse_over(x, y)
	RaidGUIControlLootCardDetails.super.on_mouse_over(self, x, y)

	if self._params.hover_callback then
		self._params.hover_callback(self._item_data, self._state == "card_details")
	end

	self._sound_source:post_event("card_mouse_over")
	self:_highlight_on()
end

-- Lines 159-164
function RaidGUIControlLootCardDetails:on_mouse_out(x, y)
	RaidGUIControlLootCardDetails.super.on_mouse_out(self, x, y)
	self:_highlight_off()
end

-- Lines 166-168
function RaidGUIControlLootCardDetails:_highlight_on()
	self._select_background_panel:set_visible(true)
end

-- Lines 170-174
function RaidGUIControlLootCardDetails:_highlight_off()
	if self._select_background_panel and self._select_background_panel._engine_panel and alive(self._select_background_panel._engine_panel) then
		self._select_background_panel:set_visible(false)
	end
end

-- Lines 176-186
function RaidGUIControlLootCardDetails:select()
	self._selected = true

	if self._params.hover_callback then
		self._params.hover_callback(self._item_data, self._state == "card_details")
	end

	self._sound_source:post_event("card_mouse_over")
	self:_highlight_on()
end

-- Lines 188-192
function RaidGUIControlLootCardDetails:unselect()
	self._selected = false

	self:_highlight_off()
end

-- Lines 196-233
function RaidGUIControlLootCardDetails:_animate_reveal_card()
	self._sound_source:post_event("reward_reveal_card")

	local close_duration = 0.25
	local t = 0
	local initial_card_empty_w = self._card_empty:w()
	local card_center_x = self._card_empty:center_x()

	while t < close_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_scale = Easing.quartic_in(t, 1, -1, close_duration)

		self._card_empty:set_w(initial_card_empty_w * current_scale)
		self._card_empty:set_center_x(card_center_x)
	end

	self._card_empty:set_w(0)
	self._card_empty:set_center_x(card_center_x)
	self._card_control:set_w(0)
	self._card_control:set_alpha(1)

	local open_duration = 0.25
	t = 0

	while open_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_scale = Easing.quartic_out(t, 0, 1, open_duration)

		self._card_control:set_w(initial_card_empty_w * current_scale)
		self._card_control:set_center_x(card_center_x)
	end

	self._card_control:set_w(initial_card_empty_w)
	self._card_control:set_center_x(card_center_x)
end

-- Lines 235-274
function RaidGUIControlLootCardDetails:_animate_show_card()
	self._sound_source:post_event("reward_reveal_card")

	self._animation_t = 0
	local duration = 0.45
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt

		self._card_empty:set_alpha(1 - self._animation_t)
		self._card_control:set_alpha(self._animation_t)

		if not self._params.hide_card_details then
			self._bonus_image:set_alpha(self._animation_t)
			self._malus_image:set_alpha(self._animation_t)
			self._bonus_label:set_alpha(self._animation_t)
			self._malus_label:set_alpha(self._animation_t)
		end

		self._animation_t = t / duration
	end

	self._animation_t = 1

	self._card_panel:remove(self._card_empty)
	self._card_control:set_alpha(self._animation_t)

	if not self._params.hide_card_details then
		self._bonus_image:set_alpha(self._animation_t)
		self._malus_image:set_alpha(self._animation_t)
		self._bonus_label:set_alpha(self._animation_t)
		self._malus_label:set_alpha(self._animation_t)
	end
end
