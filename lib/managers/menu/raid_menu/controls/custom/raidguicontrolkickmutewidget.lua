RaidGUIControlKickMuteWidget = RaidGUIControlKickMuteWidget or class(RaidGUIControl)
RaidGUIControlKickMuteWidget.HEIGHT = 64
RaidGUIControlKickMuteWidget.HIGHLIGHT_LINE_X = 13
RaidGUIControlKickMuteWidget.HIGHLIGHT_LINE_W = 3
RaidGUIControlKickMuteWidget.HIGHLIGHT_LINE_H = 32
RaidGUIControlKickMuteWidget.NAME_X = 32
RaidGUIControlKickMuteWidget.NAME_H = 64
RaidGUIControlKickMuteWidget.NAME_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlKickMuteWidget.NAME_FONT_SIZE = tweak_data.gui.font_sizes.small
RaidGUIControlKickMuteWidget.NAME_FONT_COLOR_INACTIVE = tweak_data.gui.colors.raid_grey
RaidGUIControlKickMuteWidget.NAME_FONT_COLOR_ACTIVE = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlKickMuteWidget.BUTTON_PADDING = 96

function RaidGUIControlKickMuteWidget:init(parent, params)
	self._params = clone(params)
	self._index = params.index
	self._name = params.name

	self:_create_panel(parent, params)
	self:_create_highlight_line()
	self:_create_name_text()

	self._buttons = {}

	self:_create_kick_button()
	self:_create_mute_button()

	if SystemInfo:platform() == Idstring("XB1") then
		self:_create_gamercard_button()
	end

	self:_create_invite_button()
end

function RaidGUIControlKickMuteWidget:_create_panel(parent, params)
	local parent_params = {
		halign = "scale",
		name = "kick_mute_widget_panel",
		visible = false,
		valign = "top",
		y = params.y,
		h = RaidGUIControlKickMuteWidget.HEIGHT
	}
	self._object = parent:panel(parent_params)
end

function RaidGUIControlKickMuteWidget:_create_highlight_line()
	local highlight_params = {
		name = "highlight_line",
		halign = "left",
		alpha = 0,
		x = RaidGUIControlKickMuteWidget.HIGHLIGHT_LINE_X,
		w = RaidGUIControlKickMuteWidget.HIGHLIGHT_LINE_W,
		h = RaidGUIControlKickMuteWidget.HIGHLIGHT_LINE_H,
		color = tweak_data.gui.colors.raid_red
	}
	self._highlight_line = self._object:rect(highlight_params)

	self._highlight_line:set_center_y(self._object:h() / 2)
end

function RaidGUIControlKickMuteWidget:_create_name_text()
	local name_params = {
		name = "name",
		vertical = "center",
		align = "left",
		text = "WWWWWWWWWWWWWWWW",
		halign = "left",
		x = RaidGUIControlKickMuteWidget.NAME_X,
		w = self._object:w() - RaidGUIControlKickMuteWidget.NAME_X,
		h = RaidGUIControlKickMuteWidget.NAME_H,
		font = RaidGUIControlKickMuteWidget.NAME_FONT,
		font_size = RaidGUIControlKickMuteWidget.NAME_FONT_SIZE,
		color = RaidGUIControlKickMuteWidget.NAME_FONT_COLOR_INACTIVE
	}
	self._name = self._object:text(name_params)
end

function RaidGUIControlKickMuteWidget:_create_kick_button()
	local move_up_index = self._index > 1 and self._index - 1 or 3
	local move_down_index = self._index % 3 + 1
	local kick_button_params = {
		inactive_icon = "players_icon_kick",
		name = "kick_button_" .. tostring(self._index),
		on_click_callback = callback(self, self, "on_kick_pressed"),
		on_menu_move = {
			left = "mute_button_" .. tostring(self._index)
		},
		on_selected_callback = callback(self, self, "on_button_selected", "kick"),
		on_unselected_callback = callback(self, self, "on_button_unselected", "kick")
	}
	self._kick_button = self._object:create_custom_control(RaidGUIControlButtonToggleSmall, kick_button_params)

	if self._params.rightmost_center then
		self._kick_button:set_center_x(self._object:w() - self._params.rightmost_center)
	else
		self._kick_button:set_right(self._object:w())
	end

	self._kick_button:set_center_y(self._object:h() / 2)
	table.insert(self._buttons, self._kick_button)
end

function RaidGUIControlKickMuteWidget:_create_mute_button()
	local move_up_index = self._index > 1 and self._index - 1 or 3
	local move_down_index = self._index % 3 + 1
	local mute_button_params = {
		active_icon = "players_icon_unmute",
		inactive_icon = "players_icon_mute",
		name = "mute_button_" .. tostring(self._index),
		on_click_callback = callback(self, self, "on_mute_pressed"),
		on_menu_move = {
			right = "kick_button_" .. tostring(self._index)
		},
		on_selected_callback = callback(self, self, "on_mute_selected"),
		on_unselected_callback = callback(self, self, "on_button_unselected", "mute")
	}

	if SystemInfo:platform() == Idstring("XB1") then
		mute_button_params.on_menu_move.left = "gamercard_button_" .. tostring(self._index)
	else
		mute_button_params.on_menu_move.left = "list_menu"
	end

	self._mute_button = self._object:create_custom_control(RaidGUIControlButtonToggleSmall, mute_button_params)

	self._mute_button:set_center_x(self._kick_button:center_x() - RaidGUIControlKickMuteWidget.BUTTON_PADDING)
	self._mute_button:set_center_y(self._object:h() / 2)
	table.insert(self._buttons, self._mute_button)
end

function RaidGUIControlKickMuteWidget:_create_gamercard_button()
	local move_up_index = self._index > 1 and self._index - 1 or 3
	local move_down_index = self._index % 3 + 1
	local gamercard_button_params = {
		inactive_icon = "players_icon_gamecard",
		name = "gamercard_button_" .. tostring(self._index),
		on_click_callback = callback(self, self, "show_gamercard"),
		on_menu_move = {
			left = "list_menu",
			right = "mute_button_" .. tostring(self._index),
			up = "gamercard_button_" .. move_up_index,
			down = "gamercard_button_" .. move_down_index
		},
		on_selected_callback = callback(self, self, "on_button_selected", "gamercard"),
		on_unselected_callback = callback(self, self, "on_button_unselected", "gamercard")
	}
	self._gamercard_button = self._object:create_custom_control(RaidGUIControlButtonToggleSmall, gamercard_button_params)

	self._gamercard_button:set_center_x(self._mute_button:center_x() - RaidGUIControlKickMuteWidget.BUTTON_PADDING)
	self._gamercard_button:set_center_y(self._object:h() / 2)
	table.insert(self._buttons, self._gamercard_button)
end

function RaidGUIControlKickMuteWidget:_create_invite_button()
	local move_up_index = self._index > 1 and self._index - 1 or 3
	local move_down_index = self._index % 3 + 1
	local invite_button_params = {
		active_icon = "players_icon_xbox_invite",
		visible = false,
		inactive_icon = "players_icon_xbox_invite",
		name = "invite_button_" .. tostring(self._index),
		on_click_callback = callback(self, self, "on_invite_pressed"),
		on_menu_move = {
			left = "list_menu",
			up = "kick_button_" .. move_up_index,
			down = "kick_button_" .. move_down_index
		},
		on_selected_callback = callback(self, self, "on_button_selected", "invite"),
		on_unselected_callback = callback(self, self, "on_button_unselected", "invite")
	}
	self._invite_button = self._object:create_custom_control(RaidGUIControlButtonToggleSmall, invite_button_params)

	self._invite_button:set_right(self._object:w())
	self._invite_button:set_center_y(self._object:h() / 2)
	table.insert(self._buttons, self._invite_button)
end

function RaidGUIControlKickMuteWidget:_refresh_mute_button()
	self._mute_button:set_value(self._peer:is_muted())
end

function RaidGUIControlKickMuteWidget:set_peer(peer, mute_button, kick_button)
	self._peer = peer

	self._name:set_text(utf8.to_upper(peer:name()))

	local _, _, w, _ = self._name:text_rect()

	self._name:set_w(w)
	self:_refresh_mute_button()
	self._mute_button:set_visible(mute_button)
	self._kick_button:set_visible(kick_button)
	self._object:set_visible(true)
end

function RaidGUIControlKickMuteWidget:calculate_width()
	local w = 0
	local leftmost_button_x = self._object:w()

	for i = 1, #self._buttons do
		if self._buttons[i]:x() < leftmost_button_x then
			leftmost_button_x = self._buttons[i]:x()
		end
	end

	w = w + self._object:w() - leftmost_button_x
	w = w + RaidGUIControlKickMuteWidget.BUTTON_PADDING
	local _, _, name_w, _ = self._name:text_rect()
	w = w + name_w + RaidGUIControlKickMuteWidget.NAME_X

	return w
end

function RaidGUIControlKickMuteWidget:set_w(w)
	RaidGUIControlKickMuteWidget.super.set_w(self, w)
	self:_fit_size()
end

function RaidGUIControlKickMuteWidget:_fit_size()
	local _, _, w, _ = self._name:text_rect()

	self._name:set_w(w)

	if self._params.rightmost_center then
		self._kick_button:set_center_x(self._object:w() - self._params.rightmost_center)
	else
		self._kick_button:set_right(self._object:w())
	end

	if self._kick_button:visible() then
		self._mute_button:set_center_x(self._kick_button:center_x() - RaidGUIControlKickMuteWidget.BUTTON_PADDING)
	else
		self._mute_button:set_right(self._object:w())
	end

	local button_panel_left = nil

	if SystemInfo:platform() == Idstring("XB1") then
		self._gamercard_button:set_center_x(self._mute_button:center_x() - RaidGUIControlKickMuteWidget.BUTTON_PADDING)

		button_panel_left = self._gamercard_button:x()
	else
		button_panel_left = self._mute_button:x()
	end

	self._invite_button:set_right(self._object:w())
	self._highlight_line:set_x(RaidGUIControlKickMuteWidget.HIGHLIGHT_LINE_X)
	self._name:set_x(RaidGUIControlKickMuteWidget.NAME_X)
end

function RaidGUIControlKickMuteWidget:on_mute_selected()
	if self._params.on_button_selected_callback then
		self._params.on_button_selected_callback(self._mute_button:get_value() and "unmute" or "mute")
	end
end

function RaidGUIControlKickMuteWidget:on_mute_pressed()
	if not self._peer then
		return
	end

	self:on_mute_selected()
	self._peer:set_muted(not self._peer:is_muted())
	self:_refresh_mute_button()
end

function RaidGUIControlKickMuteWidget:on_kick_pressed()
	if not self._peer then
		return
	end

	local params = {
		yes_callback = callback(self, self, "on_kick_confirmed"),
		player_name = self._peer:name()
	}

	managers.menu:show_kick_peer_dialog(params)
end

function RaidGUIControlKickMuteWidget:on_invite_pressed()
	RaidMenuCallbackHandler.invite_friend()
end

function RaidGUIControlKickMuteWidget:set_invite_widget()
	for index, button in pairs(self._buttons) do
		button:set_visible(false)
	end

	self._invite_button:set_visible(true)
	self._object:set_visible(true)
	self._name:set_text(self:translate("menu_widget_label_invite_player", true))
end

function RaidGUIControlKickMuteWidget:set_move_controls(number_of_widgets_shown, invite_widget_shown)
	if number_of_widgets_shown < 2 then
		local invite_button_move = {
			left = "list_menu"
		}

		self._invite_button:set_menu_move_controls(invite_button_move)

		return
	end

	local move_up_index = self._index > 1 and self._index - 1 or number_of_widgets_shown
	local move_down_index = self._index % number_of_widgets_shown + 1
	local is_invite_up = invite_widget_shown and self._index == 1
	local is_invite_down = invite_widget_shown and self._index == number_of_widgets_shown - 1
	local on_menu_move = nil

	if SystemInfo:platform() == Idstring("XB1") then
		on_menu_move = {
			left = "list_menu",
			right = "mute_button_" .. tostring(self._index),
			up = is_invite_up and "invite_button_" .. tostring(move_up_index) or "gamercard_button_" .. tostring(move_up_index),
			down = is_invite_down and "invite_button_" .. tostring(move_down_index) or "gamercard_button_" .. tostring(move_down_index)
		}

		self._gamercard_button:set_menu_move_controls(on_menu_move)
	end

	on_menu_move = {
		left = SystemInfo:platform() == Idstring("XB1") and "gamercard_button_" .. tostring(self._index) or "list_menu",
		right = Network:is_server() and "kick_button_" .. tostring(self._index),
		up = is_invite_up and "invite_button_" .. tostring(move_up_index) or "mute_button_" .. tostring(move_up_index),
		down = is_invite_down and "invite_button_" .. tostring(move_down_index) or "mute_button_" .. tostring(move_down_index)
	}

	self._mute_button:set_menu_move_controls(on_menu_move)

	on_menu_move = {
		left = "mute_button_" .. tostring(self._index),
		up = is_invite_up and "invite_button_" .. tostring(move_up_index) or "kick_button_" .. tostring(move_up_index),
		down = is_invite_down and "invite_button_" .. tostring(move_down_index) or "kick_button_" .. tostring(move_down_index)
	}

	self._kick_button:set_menu_move_controls(on_menu_move)

	on_menu_move = {
		left = "list_menu",
		up = Network:is_server() and "kick_button_" .. tostring(move_up_index) or "mute_button_" .. tostring(move_up_index),
		down = Network:is_server() and "kick_button_" .. tostring(move_down_index) or "mute_button_" .. tostring(move_down_index)
	}

	self._invite_button:set_menu_move_controls(on_menu_move)
end

function RaidGUIControlKickMuteWidget:show_gamercard()
	Application:trace("[RaidGUIControlKickMuteWidget:show_gamercard] showing gamercard for peer " .. tostring(self._peer:name()))
	Application:debug("[RaidGUIControlKickMuteWidget:show_gamercard]", inspect(self._peer))
	self._callback_handler:view_gamer_card(self._peer:xuid())
end

function RaidGUIControlKickMuteWidget:on_kick_confirmed()
	managers.vote:host_kick(self._peer)
	managers.menu_component:post_event("kick_player")
end

function RaidGUIControlKickMuteWidget:highlight_on()
	self._highlight_line:stop()
	self._highlight_line:animate(callback(self, self, "_animate_highlight_on"))
end

function RaidGUIControlKickMuteWidget:highlight_off()
	self._highlight_line:stop()
	self._highlight_line:animate(callback(self, self, "_animate_highlight_off"))
end

function RaidGUIControlKickMuteWidget:set_selected(selected)
	self._selected = selected

	if selected then
		self._kick_button:set_selected(true)
		self._mute_button:set_selected(false)
	else
		self._kick_button:set_selected(false)
		self._mute_button:set_selected(false)
	end
end

function RaidGUIControlKickMuteWidget:on_button_selected(button)
	if self._params.on_button_selected_callback then
		self._params.on_button_selected_callback(button)
	end
end

function RaidGUIControlKickMuteWidget:on_button_unselected(button)
	if self._params.on_button_unselected_callback then
		self._params.on_button_unselected_callback(button)
	end
end

function RaidGUIControlKickMuteWidget:_animate_highlight_on()
	local duration = 0.2
	local t = self._highlight_line:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in_out(t, 0, 1, duration)

		self._highlight_line:set_alpha(current_alpha)
	end

	self._highlight_line:set_alpha(1)
end

function RaidGUIControlKickMuteWidget:_animate_highlight_off()
	local duration = 0.2
	local t = (1 - self._highlight_line:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in_out(t, 1, -1, duration)

		self._highlight_line:set_alpha(current_alpha)
	end

	self._highlight_line:set_alpha(0)
end
