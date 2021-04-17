RaidGUIControlCardWithSelector = RaidGUIControlCardWithSelector or class(RaidGUIControlCardBase)
RaidGUIControlCardWithSelector.SELECT_TRINGLE_SIZE = 30

-- Lines 5-31
function RaidGUIControlCardWithSelector:init(parent, params, item_data, grid_params)
	RaidGUIControlCardWithSelector.super.init(self, parent, params, item_data, grid_params)

	self._params.selected_marker_w = params.selected_marker_w or params.item_w or self._panel:w()
	self._params.selected_marker_h = params.selected_marker_h or params.item_h or self._panel:h()
	self._params.item_w = params.item_w or self._panel:w()
	self._params.item_h = params.item_h or self._panel:h()
	self._select_background_panel = self._object:panel({
		visible = false,
		y = 0,
		x = 0,
		layer = 1,
		w = self._params.selected_marker_w,
		h = self._params.selected_marker_h
	})
	self._select_background = self._select_background_panel:rect({
		y = 0,
		x = 0,
		layer = 2,
		w = self._params.selected_marker_w,
		h = self._params.selected_marker_h,
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

	self._xp_bonus:set_y(self._card_image:y() + self._card_image:h() * RaidGUIControlCardBase.XP_BONUS_Y + (self._params.selected_marker_h - self._params.item_h) / 2)

	self._sound_source = SoundDevice:create_source("challenge_card")
end

-- Lines 33-76
function RaidGUIControlCardWithSelector:set_card(card_data)
	RaidGUIControlCardWithSelector.super.set_card(self, card_data)

	if self._item_data then
		self._card_panel:set_w(self._params.selected_marker_w)
		self._card_panel:set_h(self._params.selected_marker_h)
		self._select_background_panel:hide()

		local image_coord_x = math.floor((self._params.selected_marker_w - self._params.item_w) / 2)
		local image_coord_y = math.floor((self._params.selected_marker_h - self._params.item_h) / 2)

		self._card_image:set_x(image_coord_x)
		self._card_image:set_y(image_coord_y)
		self._card_image:set_w(self._params.item_w)
		self._card_image:set_h(self._params.item_h)
		self._card_stackable_image:set_x(image_coord_x)
		self._card_stackable_image:set_y(image_coord_y)
		self._card_stackable_image:set_w(self._params.item_w)
		self._card_stackable_image:set_h(self._params.item_h)
		self._card_title:set_center_x(self._params.selected_marker_w / 2)
		self._card_title:set_y(self._card_title:y() + (self._params.selected_marker_h - self._params.item_h) / 2)
		self._card_description:hide()
		self._card_rarity_icon:set_x(138)
		self._card_rarity_icon:set_y(27)
		self._card_rarity_icon:set_w(22)
		self._card_rarity_icon:set_h(22)
		self._card_type_icon:set_x(31)
		self._card_type_icon:set_y(27)
		self._card_type_icon:set_w(22)
		self._card_type_icon:set_h(22)
		self._xp_bonus:set_center_x(self._params.selected_marker_w / 2)
	end
end

-- Lines 78-87
function RaidGUIControlCardWithSelector:select(dont_fire_selected_callback)
	RaidGUIControlCardWithSelector.super.select(self)
	self._select_background_panel:show()

	if self._on_selected_callback and not dont_fire_selected_callback then
		self._on_selected_callback(self._params.item_idx, self._item_data)
	end
end

-- Lines 89-94
function RaidGUIControlCardWithSelector:unselect()
	RaidGUIControlCardWithSelector.super.unselect(self)
	self._select_background_panel:hide()
end

-- Lines 96-101
function RaidGUIControlCardWithSelector:on_mouse_over(x, y)
	RaidGUIControlCardWithSelector.super.on_mouse_over(self, x, y)
	self._sound_source:post_event("card_mouse_over")
end

-- Lines 103-110
function RaidGUIControlCardWithSelector:on_mouse_released(button, x, y)
	if self._on_click_callback then
		self._on_click_callback(self._item_data, self._params.key_value_field)
	end
end
