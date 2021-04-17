RaidGUIControlReadyUpPlayerDescription = RaidGUIControlReadyUpPlayerDescription or class(RaidGUIControl)

-- Lines 4-13
function RaidGUIControlReadyUpPlayerDescription:init(parent, params)
	RaidGUIControlReadyUpPlayerDescription.super.init(self, parent, params)

	self._params = params
	self._object = self._panel:panel(params)
	self._on_click_callback = params.on_click_callback

	self:_layout()
end

-- Lines 15-46
function RaidGUIControlReadyUpPlayerDescription:_layout()
	local class_icon = tweak_data.gui.icons.ico_class_assault
	self._class_icon = self._object:bitmap({
		name = "class_icon",
		y = 32,
		x = 32,
		texture = class_icon.texture,
		texture_rect = class_icon.texture_rect
	})
	self._player_name = self._object:label({
		name = "player_name",
		vertical = "center",
		h = 26,
		w = 256,
		align = "left",
		text = "PLAYER NAME 1",
		x = self._class_icon:right() + 8,
		y = self._class_icon:top(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._status_label = self._object:label({
		name = "player_status",
		vertical = "center",
		h = 22,
		w = 256,
		align = "left",
		x = self._player_name:left(),
		y = self._player_name:bottom() + 6,
		text = self:translate("menu_not_ready", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_grey_effects
	})
	self._selected_card_icon = self._object:bitmap({
		name = "selected_card_icon",
		x = 352,
		y = self._player_name:top(),
		texture = tweak_data.gui.icons.ready_up_card_not_selected.texture,
		texture_rect = tweak_data.gui.icons.ready_up_card_not_selected.texture_rect
	})
	self._player_level = self._object:label({
		name = "player_level",
		vertical = "center",
		h = 24,
		w = 64,
		align = "left",
		text = "17",
		x = self._selected_card_icon:right() + 16,
		y = self._player_name:top(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._select_marker_rect = self._object:rect({
		name = "select_marker_rect",
		y = 0,
		x = 0,
		w = self._object:w(),
		h = self._object:h(),
		color = tweak_data.gui.colors.raid_select_card_background
	})

	self._select_marker_rect:hide()

	self._top_select_triangle = self._object:image({
		y = 0,
		x = 0,
		w = RaidGUIControlCardSuggestedLarge.SELECT_TRINGLE_SIZE,
		h = RaidGUIControlCardSuggestedLarge.SELECT_TRINGLE_SIZE,
		texture = tweak_data.gui.icons.ico_sel_rect_top_left.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_top_left.texture_rect
	})

	self._top_select_triangle:hide()

	self._bottom_select_triangle = self._object:image({
		x = self._object:w() - RaidGUIControlCardSuggestedLarge.SELECT_TRINGLE_SIZE,
		y = self._object:h() - RaidGUIControlCardSuggestedLarge.SELECT_TRINGLE_SIZE,
		w = RaidGUIControlCardSuggestedLarge.SELECT_TRINGLE_SIZE,
		h = RaidGUIControlCardSuggestedLarge.SELECT_TRINGLE_SIZE,
		texture = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture,
		texture_rect = tweak_data.gui.icons.ico_sel_rect_bottom_right.texture_rect
	})

	self._bottom_select_triangle:hide()
end

-- Lines 48-75
function RaidGUIControlReadyUpPlayerDescription:set_data(data)
	if not data then
		return
	end

	if data.player_class then
		local class_icon = tweak_data.gui.icons["ico_class_" .. data.player_class]

		self._class_icon:set_image(class_icon.texture, unpack(class_icon.texture_rect))
	end

	if data.player_name then
		self._player_name:set_text(utf8.to_upper(data.player_name))
	end

	if data.player_status then
		self._status_label:set_text(self:translate("menu_" .. data.player_status, true))
	end

	if data.player_level then
		self._player_level:set_text(data.player_level)
	end

	if data.is_host then
		self._object:bitmap({
			name = "host_icon",
			x = self._class_icon:left() + 28,
			y = self._class_icon:top() + 28,
			texture = tweak_data.gui.icons.player_panel_host_indicator.texture,
			texture_rect = tweak_data.gui.icons.player_panel_host_indicator.texture_rect
		})
	end
end

-- Lines 77-79
function RaidGUIControlReadyUpPlayerDescription:params()
	return self._params
end

-- Lines 81-92
function RaidGUIControlReadyUpPlayerDescription:highlight_on()
	if not self._enabled then
		return
	end

	self._select_marker_rect:show()

	if self._play_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._play_mouse_over_sound = false
	end
end

-- Lines 94-101
function RaidGUIControlReadyUpPlayerDescription:highlight_off()
	if self._selected then
		return
	end

	self._select_marker_rect:hide()

	self._play_mouse_over_sound = true
end

-- Lines 103-113
function RaidGUIControlReadyUpPlayerDescription:on_mouse_clicked()
	if not self._enabled then
		return
	end

	if self._on_click_callback then
		self:_on_click_callback(self._params)
	end

	self:select_on()
end

-- Lines 115-119
function RaidGUIControlReadyUpPlayerDescription:select_on()
	self:set_selected(true)
	self._top_select_triangle:show()
	self._bottom_select_triangle:show()
end

-- Lines 121-125
function RaidGUIControlReadyUpPlayerDescription:select_off()
	self:set_selected(false)
	self._top_select_triangle:hide()
	self._bottom_select_triangle:hide()
end

-- Lines 127-156
function RaidGUIControlReadyUpPlayerDescription:set_state(state)
	if state == "ready" then
		self._status_label:set_text(self:translate("menu_ready", true))
		self._status_label:set_color(tweak_data.gui.colors.raid_red)

		self._params.ready = true
	elseif state == "kicked" then
		self._status_label:set_text(self:translate("menu_kicked", true))
		self._class_icon:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._player_name:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._status_label:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._selected_card_icon:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._player_level:set_color(tweak_data.gui.colors.raid_grey_effects)
		self:set_selected(false)

		self._enabled = false
	elseif state == "left" then
		self._status_label:set_text(self:translate("menu_left", true))
		self._class_icon:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._player_name:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._status_label:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._selected_card_icon:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._player_level:set_color(tweak_data.gui.colors.raid_grey_effects)
		self:set_selected(false)

		self._enabled = false
	end
end

-- Lines 159-165
function RaidGUIControlReadyUpPlayerDescription:set_challenge_card_selected(selected)
	if selected then
		self._selected_card_icon:set_image(tweak_data.gui.icons.ready_up_card_selected_active.texture, unpack(tweak_data.gui.icons.ready_up_card_selected_active.texture_rect))
	else
		self._selected_card_icon:set_image(tweak_data.gui.icons.ready_up_card_not_selected.texture, unpack(tweak_data.gui.icons.ready_up_card_not_selected.texture_rect))
	end
end
