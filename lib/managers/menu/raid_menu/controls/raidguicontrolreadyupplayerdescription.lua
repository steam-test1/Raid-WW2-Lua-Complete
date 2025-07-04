RaidGUIControlReadyUpPlayerDescription = RaidGUIControlReadyUpPlayerDescription or class(RaidGUIControl)
RaidGUIControlReadyUpPlayerDescription.CHAT_ICON_SPEAKING = "voice_chat_talking_icon"
RaidGUIControlReadyUpPlayerDescription.CHAT_ICON_MUTED = "voice_chat_muted_icon"
RaidGUIControlReadyUpPlayerDescription.CHAT_PANEL_SIZE = 60
RaidGUIControlReadyUpPlayerDescription.STATE_READY = "ready"
RaidGUIControlReadyUpPlayerDescription.STATE_NOT_READY = "not_ready"
RaidGUIControlReadyUpPlayerDescription.STATE_KICKED = "kicked"
RaidGUIControlReadyUpPlayerDescription.STATE_LEFT = "left"

function RaidGUIControlReadyUpPlayerDescription:init(parent, params)
	RaidGUIControlReadyUpPlayerDescription.super.init(self, parent, params)

	self._params = params
	self._object = self._panel:panel(params)
	self._on_click_callback = params.on_click_callback

	self:_layout()
	self:_create_voice_chat_indicator()
end

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
		vertical = "center",
		align = "left",
		h = 26,
		w = 256,
		name = "player_name",
		text = "PLAYER NAME 1",
		x = self._class_icon:right() + 8,
		y = self._class_icon:top(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._status_label = self._object:label({
		vertical = "center",
		align = "left",
		h = 22,
		w = 256,
		name = "player_status",
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
		vertical = "center",
		align = "left",
		h = 24,
		w = 64,
		name = "player_level",
		text = "00",
		x = self._selected_card_icon:right() + 16,
		y = self._player_name:top(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_dirty_white
	})
	self._select_marker_rect = self._object:rect({
		y = 0,
		name = "select_marker_rect",
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

function RaidGUIControlReadyUpPlayerDescription:_create_voice_chat_indicator()
	local chat_indicator_params_speaking = {
		name = "chat_indicator_speaking",
		alpha = 0,
		layer = 30,
		texture = tweak_data.gui.icons[RaidGUIControlReadyUpPlayerDescription.CHAT_ICON_SPEAKING].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlReadyUpPlayerDescription.CHAT_ICON_SPEAKING].texture_rect
	}
	self._chat_indicator_speaking = self._object:bitmap(chat_indicator_params_speaking)
	local _, _, w, _ = self._status_label:text_rect()
	local x = self._status_label:left() + w + RaidGUIControlReadyUpPlayerDescription.CHAT_PANEL_SIZE / 2
	local y = self._player_name:bottom() + 19

	self._chat_indicator_speaking:set_center_x(x)
	self._chat_indicator_speaking:set_center_y(y)

	local chat_indicator_params_muted = {
		name = "chat_indicator_muted",
		alpha = 0,
		layer = 30,
		texture = tweak_data.gui.icons[RaidGUIControlReadyUpPlayerDescription.CHAT_ICON_MUTED].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlReadyUpPlayerDescription.CHAT_ICON_MUTED].texture_rect
	}
	self._chat_indicator_muted = self._object:bitmap(chat_indicator_params_muted)

	self._chat_indicator_muted:set_center_x(x)
	self._chat_indicator_muted:set_center_y(y)
end

function RaidGUIControlReadyUpPlayerDescription:show_chat_indicator(chat_indicator_name)
	local chat_indicator = nil

	if chat_indicator_name == "chat_indicator_speaking" then
		chat_indicator = self._chat_indicator_speaking
	elseif chat_indicator_name == "chat_indicator_muted" then
		chat_indicator = self._chat_indicator_muted
	end

	if chat_indicator then
		chat_indicator:set_alpha(1)
	end
end

function RaidGUIControlReadyUpPlayerDescription:hide_chat_indicator(chat_indicator_name)
	local chat_indicator = nil

	if chat_indicator_name == "chat_indicator_speaking" then
		chat_indicator = self._chat_indicator_speaking
	elseif chat_indicator_name == "chat_indicator_muted" then
		chat_indicator = self._chat_indicator_muted
	end

	if chat_indicator then
		chat_indicator:set_alpha(0)
	end
end

function RaidGUIControlReadyUpPlayerDescription:set_data(data)
	if not data then
		return
	end

	if data.player_class then
		local class_icon = tweak_data.gui.icons["ico_class_" .. data.player_class]

		self._class_icon:set_image(class_icon.texture, unpack(class_icon.texture_rect))
	end

	if data.player_name then
		local name = data.player_name

		if managers.user:get_setting("capitalize_names") then
			name = utf8.to_upper(name)
		end

		self._player_name:set_text(name)
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

function RaidGUIControlReadyUpPlayerDescription:params()
	return self._params
end

function RaidGUIControlReadyUpPlayerDescription:is_ready()
	return self._params.ready
end

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

function RaidGUIControlReadyUpPlayerDescription:highlight_off()
	if self._selected then
		return
	end

	self._select_marker_rect:hide()

	self._play_mouse_over_sound = true
end

function RaidGUIControlReadyUpPlayerDescription:on_mouse_clicked()
	if not self._enabled then
		return
	end

	if self._on_click_callback then
		self:_on_click_callback(self._params)
	end

	self:select_on()
end

function RaidGUIControlReadyUpPlayerDescription:select_on()
	self:set_selected(true)
	self._top_select_triangle:show()
	self._bottom_select_triangle:show()
end

function RaidGUIControlReadyUpPlayerDescription:select_off()
	self:set_selected(false)
	self._top_select_triangle:hide()
	self._bottom_select_triangle:hide()
end

function RaidGUIControlReadyUpPlayerDescription:set_state(state)
	Application:debug("[RaidGUIControlReadyUpPlayerDescription:set_state] State: " .. tostring(state))

	if state == RaidGUIControlReadyUpPlayerDescription.STATE_READY then
		self._status_label:set_text(self:translate("menu_ready", true))
		self._status_label:set_color(tweak_data.gui.colors.raid_red)

		self._params.ready = true
	elseif state == RaidGUIControlReadyUpPlayerDescription.STATE_NOT_READY then
		self._status_label:set_text(self:translate("menu_not_ready", true))
		self._status_label:set_color(tweak_data.gui.colors.raid_grey_effects)

		self._params.ready = false
	elseif state == RaidGUIControlReadyUpPlayerDescription.STATE_KICKED then
		self._status_label:set_text(self:translate("menu_kicked", true))
		self._class_icon:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._player_name:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._status_label:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._selected_card_icon:set_color(tweak_data.gui.colors.raid_grey_effects)
		self._player_level:set_color(tweak_data.gui.colors.raid_grey_effects)
		self:set_selected(false)

		self._enabled = false
	elseif state == RaidGUIControlReadyUpPlayerDescription.STATE_LEFT then
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

function RaidGUIControlReadyUpPlayerDescription:set_challenge_card_selected(selected)
	local gui_data = tweak_data.gui.icons[selected and "ready_up_card_selected_active" or "ready_up_card_not_selected"]

	self._selected_card_icon:set_image(gui_data.texture, unpack(gui_data.texture_rect))
end
