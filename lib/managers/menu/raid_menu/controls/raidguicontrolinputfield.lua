RaidGUIControlInputField = RaidGUIControlInputField or class(RaidGUIControl)
RaidGUIControlInputField.CORNER_WIDTH = 10
RaidGUIControlInputField.VERTICAL_PADDING = 20
RaidGUIControlInputField.ICON_LEFT = "if_left_base"
RaidGUIControlInputField.ICON_CENTER = "if_center_base"
RaidGUIControlInputField.ICON_RIGHT = "if_right_base"
RaidGUIControlInputField.ICON_ACTIVE_LEFT = "kb_left_base"
RaidGUIControlInputField.ICON_ACTIVE_CENTER = "kb_center_base"
RaidGUIControlInputField.ICON_ACTIVE_RIGHT = "kb_right_base"
RaidGUIControlInputField.INACTIVE_ALPHA = 0.3
RaidGUIControlInputField.ACTIVE_ALPHA = 0.5
RaidGUIControlInputField.CARET_Y = 11

-- Lines 17-122
function RaidGUIControlInputField:init(parent, params)
	RaidGUIControlInputField.super.init(self, parent, params)

	self._ws = params.ws
	local panel_params = {
		is_root_panel = true,
		name = "input_field_panel_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h
	}
	self._panel = RaidGUIPanel:new(parent, panel_params)
	self._object = self._panel
	local background_params = {
		name = "background_bar",
		y = 0,
		x = 0,
		w = self._params.w,
		h = self._params.h,
		left = RaidGUIControlInputField.ICON_LEFT,
		center = RaidGUIControlInputField.ICON_CENTER,
		right = RaidGUIControlInputField.ICON_RIGHT,
		color = Color.white:with_alpha(RaidGUIControlInputField.INACTIVE_ALPHA)
	}
	self._background = self._object:three_cut_bitmap(background_params)
	self._output_width = 256
	self._panel_width = 256
	self._character_name_frame = self._object:rect({
		y = 0,
		x = 0,
		name = "test_rect_input_field_" .. self._name,
		w = params.w,
		h = params.h,
		color = Color.red:with_alpha(0)
	})
	self._lines = {}
	self._esc_callback = callback(self, self, "esc_key_callback")
	self._enter_callback = callback(self, self, "enter_key_callback")
	self._typing_callback = 0
	self._on_text_changed_callback = params.text_changed_callback
	self._skip_first = false
	self._input_panel = self._panel:panel({
		alpha = 0,
		name = "input_panel",
		y = 0,
		x = 0,
		layer = 10,
		w = self._params.w,
		h = self._params.h
	})
	local text_value = ""

	if params and params.text then
		text_value = params.text
	end

	self._input_text = self._input_panel:text({
		name = "input_text",
		halign = "left",
		wrap = true,
		align = "left",
		hvertical = "center",
		vertical = "center",
		y = 0,
		word_wrap = false,
		x = 30,
		w = self._params.w - 60,
		text = text_value,
		font = params.font or tweak_data.gui.fonts.din_compressed,
		font_size = params.font_size or tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_white,
		selection_color = Color.white,
		layer = self._character_name_frame:layer() + 10
	})
	local caret = self._input_panel:rect({
		vertical = "center",
		name = "caret",
		w = 0,
		x = 0,
		y = RaidGUIControlInputField.CARET_Y,
		h = self._input_text:h(),
		color = Color(0.05, 1, 0.5, 1),
		layer = self._character_name_frame:layer() + 10
	})

	self._input_text:set_selection(0, utf8.len(self._input_text:text()))
end

-- Lines 124-126
function RaidGUIControlInputField:get_text()
	return self._input_text:text()
end

-- Lines 128-131
function RaidGUIControlInputField:mouse_released(o, button, x, y)
	self:on_mouse_released(button)
end

-- Lines 133-136
function RaidGUIControlInputField:on_mouse_released(button)
	self:on_click_rect()
end

-- Lines 138-141
function RaidGUIControlInputField:highlight_on()
	self:_set_background_state("active")
end

-- Lines 143-148
function RaidGUIControlInputField:highlight_off()
	if not self._focus then
		self:_set_background_state("normal")
	end
end

-- Lines 150-178
function RaidGUIControlInputField:_set_background_state(bg_state)
	if bg_state == "active" then
		self._background:set_color(Color.white:with_alpha(RaidGUIControlInputField.ACTIVE_ALPHA))
		self._input_text:set_color(tweak_data.gui.colors.raid_white)
	else
		self._background:set_color(Color.white:with_alpha(RaidGUIControlInputField.INACTIVE_ALPHA))
		self._input_text:set_color(tweak_data.gui.colors.raid_black)
	end
end

-- Lines 182-186
function RaidGUIControlInputField:on_click_rect()
	self:input_focus()
	self:_on_focus()
end

-- Lines 188-194
function RaidGUIControlInputField:set_chat_focus(focus)
	if focus then
		self:_on_focus()
	else
		self:_loose_focus()
	end
end

-- Lines 196-198
function RaidGUIControlInputField:set_layer(layer)
	self._panel:set_layer(layer)
end

-- Lines 200-204
function RaidGUIControlInputField:set_channel_id(channel_id)
end

-- Lines 206-211
function RaidGUIControlInputField:esc_key_callback()
	self:set_chat_focus(false)
end

-- Lines 214-230
function RaidGUIControlInputField:enter_key_callback()
	local text = self._input_panel:child("input_text")
	local message = text:text()

	return true
end

-- Lines 256-262
function RaidGUIControlInputField:input_focus()
	return self._focus
end

-- Lines 264-266
function RaidGUIControlInputField:set_skip_first(skip_first)
	self._skip_first = skip_first
end

-- Lines 268-308
function RaidGUIControlInputField:_on_focus()
	if self._focus then
		return
	end

	self._input_panel:stop()
	self._input_panel:animate(callback(self, self, "_animate_show_component"))

	self._focus = true

	self._ws:connect_keyboard(Input:keyboard())
	self._input_panel:key_press(callback(self, self, "key_press"))
	self._input_panel:key_release(callback(self, self, "key_release"))

	self._enter_text_set = false

	self:update_caret()
end

-- Lines 310-340
function RaidGUIControlInputField:_loose_focus()
	if not self._focus then
		return
	end

	self._focus = false

	self._ws:disconnect_keyboard()
	self._input_panel:key_press(nil)
	self._input_panel:enter_text(nil)
	self._input_panel:key_release(nil)
	self._input_panel:stop()

	local text = self._input_panel:child("input_text")

	text:stop()
	self:highlight_off()
	self:update_caret()
end

-- Lines 342-349
function RaidGUIControlInputField:clear()
	local text = self._input_panel:child("input_text")

	text:set_text("")
	text:set_selection(0, 0)
	self:_loose_focus()
	self:set_chat_focus(false)
end

-- Lines 351-354
function RaidGUIControlInputField:_shift()
	local k = Input:keyboard()

	return k:down("left shift") or k:down("right shift") or k:has_button("shift") and k:down("shift")
end

-- Lines 357-364
function RaidGUIControlInputField.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.3)
		o:set_color(Color.white)
		wait(0.3)
	end
end

-- Lines 366-373
function RaidGUIControlInputField:set_blinking(b)
	local caret = self._input_panel:child("caret")

	if b == self._blinking then
		return
	end

	if b then
		caret:animate(self.blink)
	else
		caret:stop()
	end

	self._blinking = b

	if not self._blinking then
		caret:set_color(tweak_data.gui.colors.raid_red:with_alpha(0.3))
	end
end

-- Lines 375-416
function RaidGUIControlInputField:update_caret()
	local text = self._input_panel:child("input_text")
	local caret = self._input_panel:child("caret")
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()

	if s == 0 and e == 0 then
		if text:align() == "center" then
			x = text:world_x() + text:w() / 2
		else
			x = text:world_x()
		end

		y = text:world_y()
	end

	h = text:h()

	if w < 3 then
		w = 3
	end

	if not self._focus then
		w = 0
		h = 0
	end

	y = RaidGUIControlInputField.CARET_Y

	caret:set_world_shape(x, y, w, tweak_data.gui.font_sizes.small)
	caret:set_y(y)
	self:set_blinking(s == e and self._focus)

	if self._on_text_changed_callback then
		self._on_text_changed_callback()
	end
end

-- Lines 419-454
function RaidGUIControlInputField:enter_text(o, s)
	s = utf8.to_upper(s)

	if self._skip_first then
		self._skip_first = false

		return
	end

	local text = self._input_panel:child("input_text")

	if type(self._typing_callback) ~= "number" then
		self._typing_callback()
	end

	text:replace_text(s)

	local lbs = text:line_breaks()

	if #lbs > 1 then
		local s = lbs[2]
		local e = utf8.len(text:text())

		text:set_selection(s, e)
		text:replace_text("")
	end

	self:update_caret()
end

-- Lines 457-503
function RaidGUIControlInputField:update_key_down(o, k)
	wait(0.6)

	local text = self._input_panel:child("input_text")

	while self._key_pressed == k do
		local s, e = text:selection()
		local n = utf8.len(text:text())
		local d = math.abs(e - s)

		if self._key_pressed == Idstring("backspace") then
			if s == e and s > 0 then
				text:set_selection(s - 1, e)
			end

			text:replace_text("")

			if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
				-- Nothing
			end
		elseif self._key_pressed == Idstring("delete") then
			if s == e and s < n then
				text:set_selection(s, e + 1)
			end

			text:replace_text("")

			if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
				-- Nothing
			end
		elseif self._key_pressed == Idstring("left") then
			if s < e then
				text:set_selection(s, s)
			elseif s > 0 then
				text:set_selection(s - 1, s - 1)
			end
		elseif self._key_pressed == Idstring("right") then
			if s < e then
				text:set_selection(e, e)
			elseif s < n then
				text:set_selection(s + 1, s + 1)
			end
		else
			self._key_pressed = false
		end

		self:update_caret()
		wait(0.03)
	end
end

-- Lines 505-509
function RaidGUIControlInputField:key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = false
	end
end

-- Lines 512-588
function RaidGUIControlInputField:key_press(o, k)
	if self._skip_first then
		self._skip_first = false

		return
	end

	if not self._enter_text_set then
		self._input_panel:enter_text(callback(self, self, "enter_text"))

		self._enter_text_set = true
	end

	local text = self._input_panel:child("input_text")
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)
	self._key_pressed = k

	text:stop()
	text:animate(callback(self, self, "update_key_down"), k)

	if k == Idstring("backspace") then
		if s == e and s > 0 then
			text:set_selection(s - 1, e)
		end

		text:replace_text("")

		if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
			-- Nothing
		end
	elseif k == Idstring("delete") then
		if s == e and s < n then
			text:set_selection(s, e + 1)
		end

		text:replace_text("")

		if utf8.len(text:text()) < 1 and type(self._esc_callback) ~= "number" then
			-- Nothing
		end
	elseif k == Idstring("left") then
		if s < e then
			text:set_selection(s, s)
		elseif s > 0 then
			text:set_selection(s - 1, s - 1)
		end
	elseif k == Idstring("right") then
		if s < e then
			text:set_selection(e, e)
		elseif s < n then
			text:set_selection(s + 1, s + 1)
		end
	elseif self._key_pressed == Idstring("end") then
		text:set_selection(n, n)
	elseif self._key_pressed == Idstring("home") then
		text:set_selection(0, 0)
	elseif k == Idstring("enter") then
		if type(self._enter_callback) ~= "number" then
			self._enter_callback()
		end
	elseif k == Idstring("esc") and type(self._esc_callback) ~= "number" then
		text:set_text("")
		text:set_selection(0, 0)
		self._esc_callback()
	end

	self:update_caret()

	return true
end

-- Lines 590-605
function RaidGUIControlInputField:_animate_fade_output()
	local wait_t = 10
	local fade_t = 1
	local t = 0

	while wait_t > t do
		local dt = coroutine.yield()
		t = t + dt
	end

	local t = 0

	while fade_t > t do
		local dt = coroutine.yield()
		t = t + dt

		self:set_output_alpha(1 - t / fade_t)
	end

	self:set_output_alpha(0)
end

-- Lines 607-618
function RaidGUIControlInputField:_animate_show_component(input_panel, start_alpha)
	local TOTAL_T = 0.25
	local t = 0
	start_alpha = start_alpha or 0

	while t < TOTAL_T do
		local dt = coroutine.yield()
		t = t + dt

		input_panel:set_alpha(start_alpha + t / TOTAL_T * (1 - start_alpha))
	end

	input_panel:set_alpha(1)
end

-- Lines 620-630
function RaidGUIControlInputField:_animate_hide_input(input_panel)
	local TOTAL_T = 0.25
	local t = 0

	while TOTAL_T > t do
		local dt = coroutine.yield()
		t = t + dt

		input_panel:set_alpha(1 - t / TOTAL_T)
	end

	input_panel:set_alpha(0)
end

-- Lines 643-645
function RaidGUIControlInputField:set_output_alpha(alpha)
end

-- Lines 647-652
function RaidGUIControlInputField:remove()
	self._input_panel:stop()
	self._hud_panel:remove(self._panel)
	managers.chat:unregister_receiver(self._channel_id, self)
end

-- Lines 654-656
function RaidGUIControlInputField:confirm_pressed()
	return true
end
