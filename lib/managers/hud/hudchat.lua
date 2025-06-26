HUDChat = HUDChat or class()
HUDChat.W = 384
HUDChat.H = 432
HUDChat.BACKGROUND_IMAGE = "backgrounds_chat_bg"
HUDChat.BORDER_H = 2
HUDChat.BORDER_COLOR = tweak_data.gui.colors.chat_border
HUDChat.ANIMATION_MOVE_X_DISTANCE = 50
HUDChat.NAME_FONT = tweak_data.gui.fonts.din_compressed
HUDChat.NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDChat.MESSAGE_FONT = tweak_data.gui.fonts.lato_outlined_18
HUDChat.MESSAGE_FONT_SIZE = tweak_data.gui.font_sizes.size_18
HUDChat.PLAYER_MESSAGE_COLOR = tweak_data.gui.colors.chat_player_message
HUDChat.PEER_MESSAGE_COLOR = tweak_data.gui.colors.chat_peer_message
HUDChat.CHAT_BOX_PADDING = 32
HUDChat.INPUT_PANEL_H = 96
HUDChat.INPUT_TEXT_PANEL_H = 48
HUDChat.INPUT_TEXT_BACKGROUND = "chat_input_rounded_rect"
HUDChat.INPUT_TEXT_X = 12
HUDChat.INPUT_TEXT_PADDING_RIGHT = 6
HUDChat.CARET_W = 2
HUDChat.CARET_H = 18
HUDChat.MESSAGES_KEPT = 10
HUDChat.MESSAGE_PADDING_DOWN = 15
HUDChat.MESSAGE_MAX_SIZE = 150
HUDChat.MESSAGE_MAX_SHOWTIME = 8
HUDChat.line_height = 21

function HUDChat:init(ws, panel, background)
	self._messages = {}
	self._recieved_messages = {}
	self._skip_first = false

	self:_setup_callbacks()
	self:_create_panel(panel)

	if background then
		self:_create_background()
	end

	self:_create_input()
	self:_create_message_panel()

	self._ws = ws
	self._hud_panel = panel
	self._channel_id = ChatManager.GAME

	self:set_channel_id()
end

function HUDChat:_setup_callbacks()
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._enter_callback = callback(self, self, "enter_key_callback")
	self._typing_callback = 0
end

function HUDChat:_create_panel(panel)
	local panel_params = {
		halign = "left",
		visible = false,
		valign = "bottom",
		name = "chat_panel",
		w = HUDChat.W,
		h = HUDChat.H
	}
	self._object = panel:panel(panel_params)
end

function HUDChat:_create_background()
	local background = self._object:bitmap({
		name = "background",
		texture = tweak_data.gui.icons[HUDChat.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDChat.BACKGROUND_IMAGE].texture_rect
	})
end

function HUDChat:_create_input()
	local input_panel_params = {
		halign = "scale",
		name = "input_panel",
		valign = "bottom",
		alpha = 0.3,
		w = self._object:w(),
		h = HUDChat.INPUT_PANEL_H
	}
	self._input_panel = self._object:panel(input_panel_params)

	self._input_panel:set_bottom(self._object:h())

	local input_text_panel_params = {
		halign = "scale",
		valign = "bottom",
		name = "input_text_panel",
		x = HUDChat.CHAT_BOX_PADDING,
		w = self._input_panel:w() - HUDChat.CHAT_BOX_PADDING * 2,
		h = HUDChat.INPUT_TEXT_PANEL_H
	}
	self._input_text_panel = self._input_panel:panel(input_text_panel_params)

	self._input_text_panel:set_bottom(self._input_panel:h() - HUDChat.CHAT_BOX_PADDING)

	local input_text_background_params = {
		halign = "center",
		valign = "center",
		layer = 2,
		name = "input_text_background",
		texture = tweak_data.gui.icons[HUDChat.INPUT_TEXT_BACKGROUND].texture,
		texture_rect = tweak_data.gui.icons[HUDChat.INPUT_TEXT_BACKGROUND].texture_rect
	}
	local background = self._input_text_panel:bitmap(input_text_background_params)

	background:set_center_x(self._input_text_panel:w() / 2)
	background:set_center_y(self._input_text_panel:h() / 2)

	local input_text_params = {
		text = "",
		vertical = "center",
		align = "left",
		halign = "scale",
		valign = "center",
		name = "input_text",
		layer = 5,
		x = HUDChat.INPUT_TEXT_X,
		w = self._input_text_panel:w() - HUDChat.INPUT_TEXT_X - HUDChat.INPUT_TEXT_PADDING_RIGHT,
		font = HUDChat.MESSAGE_FONT,
		font_size = HUDChat.MESSAGE_FONT_SIZE,
		color = HUDChat.PLAYER_MESSAGE_COLOR
	}
	self._input_text = self._input_text_panel:text(input_text_params)
	local caret_params = {
		visible = false,
		layer = 10,
		name = "caret",
		x = HUDChat.INPUT_TEXT_X,
		w = HUDChat.CARET_W,
		h = HUDChat.CARET_H,
		color = HUDChat.PLAYER_MESSAGE_COLOR
	}
	self._caret = self._input_text_panel:rect(caret_params)

	self._caret:set_center_y(self._input_text_panel:h() / 2)
end

function HUDChat:_create_message_panel()
	local message_panel_layer = self._object:child("background") and self._object:child("background"):layer() + 1 or 20
	local message_panel_params = {
		halign = "center",
		valign = "scale",
		name = "message_panel",
		y = 0,
		x = HUDChat.CHAT_BOX_PADDING,
		w = self._object:w() - HUDChat.CHAT_BOX_PADDING * 2,
		h = self._object:h() - self._input_panel:h(),
		layer = message_panel_layer
	}
	self._message_panel = self._object:panel(message_panel_params)
end

function HUDChat:set_layer(layer)
	self._object:set_layer(layer)
end

function HUDChat:layer()
	return self._object:layer()
end

function HUDChat:set_bottom(y)
	self._object:set_bottom(y)
end

function HUDChat:channel_id()
	return self._channel_id
end

function HUDChat:register()
	managers.chat:register_receiver(self._channel_id, self)
end

function HUDChat:unregister()
	managers.chat:unregister_receiver(self._channel_id, self)
end

function HUDChat:set_channel_id()
	self:unregister()

	self._channel_id = ChatManager.GAME

	self:register()
end

function HUDChat:esc_key_callback()
	managers.hud:set_chat_focus(false)
end

function HUDChat:enter_key_callback()
	local message = self._input_text:text()

	if string.len(message) > 0 then
		local u_name = managers.network.account:username()

		managers.chat:send_message(self._channel_id, u_name or "Offline", message)
	end

	self._input_text:set_text("")
	self._input_text:set_selection(0, 0)
	managers.hud:set_chat_focus(false)
end

function HUDChat:_create_input_panel()
	self._input_panel = self._panel:panel({
		x = 0,
		alpha = 0,
		layer = 1,
		h = 24,
		name = "input_panel",
		w = self._panel_width
	})

	self._input_panel:rect({
		name = "focus_indicator",
		visible = false,
		layer = 0,
		color = Color.white:with_alpha(0.2)
	})

	local say = self._input_panel:text({
		halign = "left",
		vertical = "center",
		align = "left",
		name = "say",
		y = 0,
		x = 0,
		layer = 1,
		blend_mode = "normal",
		hvertical = "center",
		text = utf8.to_upper(managers.localization:text("menu_chat_say")),
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white
	})
	local _, _, w, h = say:text_rect()

	say:set_size(w, self._input_panel:h())

	local input_text = self._input_panel:text({
		halign = "left",
		text = "",
		vertical = "center",
		align = "left",
		name = "input_text",
		y = 0,
		word_wrap = false,
		wrap = true,
		x = 0,
		layer = 1,
		blend_mode = "normal",
		hvertical = "center",
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = Color.white
	})
	local caret = self._input_panel:rect({
		x = 0,
		h = 0,
		layer = 2,
		w = 0,
		name = "caret",
		y = 0,
		color = Color(0.05, 1, 1, 1)
	})

	self._input_panel:gradient({
		blend_mode = "sub",
		valign = "grow",
		layer = -1,
		name = "input_bg",
		gradient_points = {
			0,
			Color.white:with_alpha(0),
			0.2,
			Color.white:with_alpha(0.25),
			1,
			Color.white:with_alpha(0)
		},
		h = self._input_panel:h()
	})
end

function HUDChat:_layout_output_panel()
	local output_panel = self._panel:child("output_panel")

	output_panel:set_w(self._output_width)

	local line_height = HUDChat.line_height
	local lines = 0

	for i = #self._lines, 1, -1 do
		local line = self._lines[i][1]
		local icon = self._lines[i][2]

		line:set_w(output_panel:w() - line:left())

		local _, _, w, h = line:text_rect()

		line:set_h(h)

		lines = lines + line:number_of_lines()
	end

	output_panel:set_h(line_height * math.min(10, lines))

	local y = 0

	for i = #self._lines, 1, -1 do
		local line = self._lines[i][1]
		local icon = self._lines[i][2]
		local _, _, w, h = line:text_rect()

		line:set_bottom(output_panel:h() - y)

		if icon then
			icon:set_top(line:top() + 1)
		end

		y = y + h
	end

	output_panel:set_bottom(self._input_panel:top())
end

function HUDChat:_layout_input_panel()
	self._input_panel:set_w(self._panel_width)

	local say = self._input_panel:child("say")
	local input_text = self._input_panel:child("input_text")

	input_text:set_left(say:right() + 4)
	input_text:set_w(self._input_panel:w() - input_text:left())

	local focus_indicator = self._input_panel:child("focus_indicator")

	focus_indicator:set_shape(input_text:shape())
	self._input_panel:set_y(self._input_panel:parent():h() - self._input_panel:h())
end

function HUDChat:input_focus()
	return self._focus
end

function HUDChat:set_skip_first(skip_first)
	self._skip_first = skip_first
end

function HUDChat:show()
	self._shown = true

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show"))
	managers.queued_tasks:unqueue("hide_chat")
end

function HUDChat:hide()
	self._shown = false

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDChat:shown()
	return self._shown
end

function HUDChat:_on_focus()
	if self._focus then
		return
	end

	self:show()

	self._focus = true

	self._ws:connect_keyboard(Input:keyboard())
	self._input_panel:key_press(callback(self, self, "key_press"))
	self._input_panel:key_release(callback(self, self, "key_release"))

	self._enter_text_set = false

	self._input_panel:set_alpha(1)
	self:set_layer(1100)
	self:_layout_message_panel()
	self:update_caret()
end

function HUDChat:_loose_focus()
	if not self._focus then
		return
	end

	if not managers.queued_tasks:has_task("hide_chat") then
		managers.queued_tasks:queue("hide_chat", self.hide, self, nil, HUDChat.MESSAGE_MAX_SHOWTIME, nil)
	end

	self._focus = false

	self._ws:disconnect_keyboard()
	self._input_panel:key_press(nil)
	self._input_panel:enter_text(nil)
	self._input_panel:key_release(nil)
	self._input_panel:set_alpha(0.3)
	self:update_caret()
end

function HUDChat:clear()
	self._input_text:set_text("")
	self._input_text:set_selection(0, 0)
	self:_loose_focus()
	managers.hud:set_chat_focus(false)
end

function HUDChat:_shift()
	local k = Input:keyboard()

	return k:down("left shift") or k:down("right shift") or k:has_button("shift") and k:down("shift")
end

function HUDChat.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.8)
		o:set_color(HUDChat.PLAYER_MESSAGE_COLOR)
		wait(0.5)
	end
end

function HUDChat:set_blinking(b)
	if b == self._blinking then
		return
	end

	if b then
		self._caret:animate(self.blink)
	else
		self._caret:stop()
	end

	self._blinking = b

	if not self._blinking then
		self._caret:set_color(HUDChat.PLAYER_MESSAGE_COLOR)
	end
end

function HUDChat:update_caret()
	local s, e = self._input_text:selection()
	local x, y, w, h = self._input_text:selection_rect()

	if s == 0 and e == 0 then
		if self._input_text:align() == "center" then
			x = self._input_text:world_x() + self._input_text:w() / 2
		else
			x = self._input_text:world_x()
		end

		y = self._input_text:world_y()
	end

	h = self._input_text:h()

	if w < 3 then
		w = 3
	end

	if not self._focus then
		w = 0
		h = 0
	end

	if not y or y == 0 then
		y = self._input_text_panel:h() / 2 - HUDChat.CARET_H / 2
	end

	self._caret:set_world_shape(x + 2, self._caret:world_y(), HUDChat.CARET_W, HUDChat.CARET_H)
	self:set_blinking(s == e and self._focus)
	self._caret:set_visible(self._focus)
end

function HUDChat:enter_text(o, s)
	if managers.hud and managers.hud:showing_stats_screen() then
		return
	end

	if HUDChat.MESSAGE_MAX_SIZE < utf8.len(self._input_text:text()) + utf8.len(s) then
		return
	end

	if self._skip_first then
		self._skip_first = false

		return
	end

	if type(self._typing_callback) ~= "number" then
		self._typing_callback()
	end

	self._input_text:replace_text(s)

	local lbs = self._input_text:line_breaks()

	if #lbs > 1 then
		local s = lbs[2]
		local e = utf8.len(self._input_text:text())

		self._input_text:set_selection(s, e)
		self._input_text:replace_text("")
	end

	self:_layout_input_text()
	self:update_caret()
end

function HUDChat:update_key_down(o, k)
	wait(0.6)

	while self._key_pressed == k do
		local s, e = self._input_text:selection()
		local n = utf8.len(self._input_text:text())
		local d = math.abs(e - s)

		if self._key_pressed == Idstring("backspace") then
			if s == e and s > 0 then
				self._input_text:set_selection(s - 1, e)
			end

			self._input_text:replace_text("")

			if utf8.len(self._input_text:text()) < 1 and type(self._esc_callback) ~= "number" then
				-- Nothing
			end
		elseif self._key_pressed == Idstring("delete") then
			if s == e and s < n then
				self._input_text:set_selection(s, e + 1)
			end

			self._input_text:replace_text("")

			if utf8.len(self._input_text:text()) < 1 and type(self._esc_callback) ~= "number" then
				-- Nothing
			end
		elseif self._key_pressed == Idstring("left") then
			if s < e then
				self._input_text:set_selection(s, s)
			elseif s > 0 then
				self._input_text:set_selection(s - 1, s - 1)
			end
		elseif self._key_pressed == Idstring("right") then
			if s < e then
				self._input_text:set_selection(e, e)
			elseif s < n then
				self._input_text:set_selection(s + 1, s + 1)
			end
		else
			self._key_pressed = false
		end

		self:_layout_input_text()
		self:update_caret()
		wait(0.03)
	end
end

function HUDChat:key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false
	end
end

function HUDChat:key_press(o, k)
	if self._skip_first then
		self._skip_first = false

		return
	end

	if not self._enter_text_set then
		self._input_panel:enter_text(callback(self, self, "enter_text"))

		self._enter_text_set = true
	end

	local s, e = self._input_text:selection()
	local n = utf8.len(self._input_text:text())
	local d = math.abs(e - s)
	self._key_pressed = k

	self._input_text:stop()
	self._input_text:animate(callback(self, self, "update_key_down"), k)

	if k == Idstring("backspace") then
		if s == e and s > 0 then
			self._input_text:set_selection(s - 1, e)
		end

		self._input_text:replace_text("")

		if utf8.len(self._input_text:text()) < 1 and type(self._esc_callback) ~= "number" then
			-- Nothing
		end
	elseif k == Idstring("delete") then
		if s == e and s < n then
			self._input_text:set_selection(s, e + 1)
		end

		self._input_text:replace_text("")

		if utf8.len(self._input_text:text()) < 1 and type(self._esc_callback) ~= "number" then
			-- Nothing
		end
	elseif k == Idstring("left") then
		if s < e then
			self._input_text:set_selection(s, s)
		elseif s > 0 then
			self._input_text:set_selection(s - 1, s - 1)
		end
	elseif k == Idstring("right") then
		if s < e then
			self._input_text:set_selection(e, e)
		elseif s < n then
			self._input_text:set_selection(s + 1, s + 1)
		end
	elseif self._key_pressed == Idstring("end") then
		self._input_text:set_selection(n, n)
	elseif self._key_pressed == Idstring("home") then
		self._input_text:set_selection(0, 0)
	elseif k == Idstring("enter") then
		if type(self._enter_callback) ~= "number" then
			self._enter_callback()
		end
	elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
		self._input_text:set_text("")
		self._input_text:set_selection(0, 0)
		self._esc_callback()
	end

	self:_layout_input_text()
	self:update_caret()
end

function HUDChat:_animate_show(panel)
	local duration = 0.2
	local t = panel:alpha() * duration

	panel:set_visible(true)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = Easing.quintic_in_out(t, 0, 1, duration)

		panel:set_alpha(curr_alpha)

		local current_x_offset = (1 - curr_alpha) * HUDChat.ANIMATION_MOVE_X_DISTANCE

		panel:set_left(current_x_offset)
	end

	panel:set_alpha(1)
	panel:set_left(0)
end

function HUDChat:_animate_hide(panel)
	local duration = 0.2
	local t = (1 - panel:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = Easing.quintic_in_out(t, 1, -1, duration)

		panel:set_alpha(curr_alpha)

		local current_x_offset = (1 - curr_alpha) * HUDChat.ANIMATION_MOVE_X_DISTANCE

		panel:set_left(current_x_offset)
	end

	panel:set_alpha(0)
	panel:set_left(HUDChat.ANIMATION_MOVE_X_DISTANCE)
	panel:set_visible(false)
end

function HUDChat:_layout_input_text()
	local _, _, w, _ = self._input_text:text_rect()
	local default_w = self._input_text_panel:w() - HUDChat.INPUT_TEXT_X - HUDChat.INPUT_TEXT_PADDING_RIGHT

	if w > default_w then
		self._input_text:set_w(w)
		self._input_text:set_right(self._input_text_panel:w() - HUDChat.INPUT_TEXT_PADDING_RIGHT)
	elseif w <= default_w then
		self._input_text:set_w(default_w)
		self._input_text:set_x(HUDChat.INPUT_TEXT_X)
	end
end

function HUDChat:send_message(name, message)
end

function HUDChat:_message_in_same_thread(peer_id, system_message)
	if #self._messages == 0 then
		return false
	end

	if self._messages[#self._messages]:peer_id() == peer_id or system_message and self._messages[#self._messages]:system_message() then
		return true
	end

	return false
end

function HUDChat:receive_message(name, peer_id, message, color, icon, system_message)
	if peer_id then
		local peer = managers.network:session():peer(peer_id)

		if not peer or peer:is_muted() then
			return
		end
	end

	local localized_message = message
	local message_data = string.split(message, "~")

	if message_data[1] then
		if message_data[2] then
			localized_message = managers.localization:text(message_data[1], {
				TARGET = message_data[2]
			})
		else
			local com_data = string.split(message_data[1], "_")

			if com_data[1] == "com" then
				localized_message = managers.localization:text(message_data[1])
			end
		end

		message = localized_message
	end

	Application:debug("[HUDChat:receive_message] localized message:", message)
	table.insert(self._recieved_messages, message)

	if ChatManager.MESSAGE_BUFFER_SIZE < #self._recieved_messages then
		table.remove(self._recieved_messages, 1)
	end

	local message_type = HUDChatMessagePeer

	if name == managers.network.account:username() then
		message_type = HUDChatMessagePlayer
	elseif system_message then
		message_type = HUDChatMessageSystem
	end

	if self:_message_in_same_thread(peer_id, system_message) then
		self._messages[#self._messages]:add_message(localized_message)
	else
		local message = message_type:new(self._message_panel, name, localized_message, peer_id)

		if #self._messages == HUDChat.MESSAGES_KEPT then
			self._messages[1]:destroy()
			table.remove(self._messages, 1)
		end

		table.insert(self._messages, message)
	end

	self:_layout_message_panel()

	if not self:shown() then
		self:show()
	else
		managers.queued_tasks:unqueue("hide_chat")
	end

	if not self._focus then
		managers.queued_tasks:queue("hide_chat", self.hide, self, nil, HUDChat.MESSAGE_MAX_SHOWTIME, nil)
	end
end

function HUDChat:ct_cached_messages()
	return #self._recieved_messages
end

function HUDChat:_layout_message_panel()
	local h = 0
	local bottom = self._message_panel:h()

	for i = #self._messages, 1, -1 do
		self._messages[i]:set_bottom(bottom)

		local message_h = self._messages[i]:h()
		h = h + message_h + HUDChat.MESSAGE_PADDING_DOWN
		bottom = bottom - message_h - HUDChat.MESSAGE_PADDING_DOWN
	end

	self._message_panel:set_bottom(self._object:h() - self._input_panel:h())
end

function HUDChat:set_output_alpha(alpha)
	self._panel:child("output_panel"):set_alpha(alpha)
end

function HUDChat:remove()
	self._panel:child("output_panel"):stop()
	self._input_panel:stop()
	self._hud_panel:remove(self._panel)
	managers.chat:unregister_receiver(self._channel_id, self)
end
