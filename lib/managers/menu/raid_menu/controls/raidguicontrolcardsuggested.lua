RaidGUIControlCardSuggested = RaidGUIControlCardSuggested or class(RaidGUIControlCardBase)

-- Lines 3-56
function RaidGUIControlCardSuggested:init(parent, params, item_data, grid_params)
	local card_image_params = {
		x = 16,
		y = 16,
		w = params.item_w - 32,
		h = params.item_h - 16
	}
	params.card_image_params = card_image_params

	RaidGUIControlCardSuggested.super.init(self, parent, params, item_data, grid_params)

	if self._grid_params and self._grid_params.on_remove_callback then
		self._on_remove_callback = self._grid_params.on_remove_callback
	end

	if self._grid_params and self._grid_params.on_lock_callback then
		self._on_lock_callback = self._grid_params.on_lock_callback
	end

	if self._on_remove_callback and self._grid_params and self._grid_params.remove_texture and params.peer_id == managers.network:session():local_peer():id() then
		self._remove_card_button = self._card_panel:image({
			name = "remove_card_button",
			h = 36,
			y = 0,
			w = 36,
			x = self._card_panel:w() - 38,
			texture = tweak_data.gui.icons.btn_circ_x.texture,
			texture_rect = tweak_data.gui.icons.btn_circ_x.texture_rect,
			layer = self._card_image:layer() + 1
		})
	end

	if self._on_lock_callback and self._grid_params and self._grid_params.lock_texture and params.peer_id == managers.network:session():local_peer():id() then
		self._lock_card_button = self._card_panel:image({
			name = "lock_card_button",
			h = 36,
			y = 0,
			w = 36,
			x = 4,
			texture = tweak_data.gui.icons.btn_circ_lock.texture,
			texture_rect = tweak_data.gui.icons.btn_circ_lock.texture_rect,
			layer = self._card_image:layer() + 1
		})
	end

	if self._grid_params and self._grid_params.lock_texture then
		self._lock_card_image = self._card_panel:image({
			name = "lock_card_image",
			h = 48,
			w = 48,
			x = self._card_panel:w() / 2 - 18,
			y = self._card_panel:h() / 4,
			texture = tweak_data.gui.icons.btn_circ_lock.texture,
			texture_rect = tweak_data.gui.icons.btn_circ_lock.texture_rect,
			layer = self._card_image:layer() + 1
		})
	end

	self._card_rarity_icon:set_x(self._card_image:w() * 0.9)
	self._card_rarity_icon:set_y(self._card_image:h() * 0.11)
	self._card_type_icon:set_x(self._card_image:w() * 0.18)
	self._card_type_icon:set_y(self._card_image:h() * 0.11)

	if self._params.peer_name ~= "" then
		self:_show_controls_for_empty_cardback()
	end

	self._sound_source = SoundDevice:create_source("challenge_card")
end

-- Lines 59-90
function RaidGUIControlCardSuggested:_show_controls_for_empty_cardback()
	local empty_slot_texture = tweak_data.gui.icons.cc_empty_slot_small

	self._card_image:set_image(empty_slot_texture.texture)
	self._card_image:set_texture_rect(unpack(empty_slot_texture.texture_rect))

	self._card_not_selected_label = self._card_panel:label({
		name = "card_not_selected_label",
		h = 128,
		wrap = true,
		align = "center",
		x = self._card_image:x() + 5,
		y = self._card_image:top() + 90,
		w = self._card_image:w() - 10,
		text = self:translate("menu_card_not_selected", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.dirty_white
	})

	self._card_not_selected_label:set_visible(true)
	self._card_panel:show()
	self._card_image:show()
	self._card_title:hide()
	self._xp_bonus:hide()
	self._card_rarity_icon:hide()
	self._card_type_icon:hide()
	self._card_amount_background:hide()
	self._card_amount_label:hide()

	if self._remove_card_button then
		self._remove_card_button:hide()
	end

	if self._lock_card_button then
		self._lock_card_button:hide()
	end

	if self._lock_card_image then
		self._lock_card_image:hide()
	end
end

-- Lines 93-124
function RaidGUIControlCardSuggested:_show_controls_for_empty_suggestion()
	local empty_slot_texture = tweak_data.gui.icons.cc_empty_slot_small

	self._card_image:set_image(empty_slot_texture.texture)
	self._card_image:set_texture_rect(unpack(empty_slot_texture.texture_rect))

	self._card_not_selected_label = self._card_panel:label({
		name = "card_not_selected_label",
		h = 128,
		wrap = true,
		align = "center",
		x = self._card_image:x() + 5,
		y = self._card_image:top() + 90,
		w = self._card_image:w() - 10,
		text = self:translate("menu_card_not_selected", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.dirty_white
	})

	self._card_not_selected_label:set_visible(true)
	self._card_panel:show()
	self._card_image:show()
	self._card_title:hide()
	self._xp_bonus:hide()
	self._card_rarity_icon:hide()
	self._card_type_icon:hide()
	self._card_amount_background:hide()
	self._card_amount_label:hide()

	if self._remove_card_button then
		self._remove_card_button:show()
	end

	if self._lock_card_button then
		self._lock_card_button:show()
	end
end

-- Lines 127-152
function RaidGUIControlCardSuggested:_show_controls_for_suggestion()
	self._card_not_selected_label:set_visible(false)
	self._card_panel:show()
	self._card_image:show()
	self._card_title:show()
	self._xp_bonus:show()
	self._card_rarity_icon:show()
	self._card_type_icon:show()
	self._card_amount_background:hide()
	self._card_amount_label:hide()

	if self._remove_card_button then
		self._remove_card_button:show()
	end

	if self._lock_card_button then
		self._lock_card_button:show()
	end
end

-- Lines 154-166
function RaidGUIControlCardSuggested:set_visible(flag)
	RaidGUIControlCardSuggested.super.set_visible(self, flag)

	if self._remove_card_button then
		self._remove_card_button:set_visible(flag)
	end

	if self._lock_card_button then
		self._lock_card_button:set_visible(flag)
	end
end

-- Lines 168-193
function RaidGUIControlCardSuggested:set_card(card_data)
	RaidGUIControlCardSuggested.super.set_card(self, card_data)
	self:set_visible(true)

	self._item_data.peer_id = self._params.peer_id

	if self._lock_card_image then
		if self._item_data and self._item_data.locked_suggestion then
			self._lock_card_image:show()
		else
			self._lock_card_image:hide()
		end

		if self._item_data.locked_suggestion and self._remove_card_button then
			self._remove_card_button:hide()
		end
	end

	if card_data and card_data.key_name and card_data.key_name == ChallengeCardsManager.CARD_PASS_KEY_NAME then
		self:_show_controls_for_empty_suggestion()
	elseif card_data and card_data.key_name and card_data.key_name ~= ChallengeCardsManager.CARD_PASS_KEY_NAME then
		self:_show_controls_for_suggestion()
	end
end

-- Lines 195-199
function RaidGUIControlCardSuggested:mouse_released(o, button, x, y)
	self:on_mouse_released(button, x, y)

	return true
end

-- Lines 201-212
function RaidGUIControlCardSuggested:on_mouse_released(button, x, y)
	if self._remove_card_button and self._remove_card_button:inside(x, y) and self._on_remove_callback and not self._item_data.locked_suggestion then
		self._on_remove_callback(button, self, self._item_data)
		self._sound_source:post_event("sugg_card_remove")
	elseif self._lock_card_button and self._lock_card_button:inside(x, y) and self._on_lock_callback and not self._item_data.locked_suggestion then
		self._on_lock_callback(button, self, self._item_data)
		self._sound_source:post_event("sugg_card_lock")
	elseif self._on_click_callback then
		self._on_click_callback(button, self, self._item_data)
	end
end

-- Lines 214-219
function RaidGUIControlCardSuggested:on_mouse_over(x, y)
	RaidGUIControlCardSuggested.super.on_mouse_over(self, x, y)
	self._sound_source:post_event("card_mouse_over")
end
