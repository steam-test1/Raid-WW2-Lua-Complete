RaidGUIControlButton = RaidGUIControlButton or class(RaidGUIControl)
RaidGUIControlButton.PRESSED_SIZE = 0.95

-- Lines 5-86
function RaidGUIControlButton:init(parent, params)
	RaidGUIControlButton.super.init(self, parent, params)

	self._object = self._panel:panel(self._params)
	self._controls = {}
	local text_params = clone(self._params)
	text_params.x = 0
	text_params.y = 0
	text_params.font = text_params.font or tweak_data.gui.fonts.din_compressed
	text_params.font_size = text_params.font_size or tweak_data.gui.font_sizes.medium
	text_params.text = text_params.text or managers.localization:text(text_params.text_id)
	text_params.text_id = nil
	text_params.background_color = params.item_background_color
	text_params.vertical = params.vertical
	text_params.layer = text_params.layer + 2

	if text_params.text_padding then
		text_params.x = text_params.x + text_params.text_padding
	end

	if text_params.background_color then
		local background_params = clone(text_params)
		background_params.color = text_params.background_color
		self._background = self._panel:rect(background_params)
	end

	self._object_text = self._object:text(text_params)

	table.insert(self._controls, self._object_text)

	if text_params.text_padding then
		text_params.x = text_params.x - text_params.text_padding

		self._object_text:set_w(self._object_text:w() - text_params.text_padding * 2)
	end

	local image_params = clone(self._params)

	if image_params.texture then
		image_params.x = 0
		image_params.y = 0
		self._object_image = self._object:bitmap(image_params)

		table.insert(self._controls, self._object_image)
		self._object_image:set_color(image_params.texture_color or Color.white)

		if image_params.texture_image_y_add then
			self._object_image:set_y(self._object_image:y() + self._params.texture_image_y_add)
		end

		if self._params.highlight_texture then
			local params_highlight = clone(self._params)
			params_highlight.x = 0
			params_highlight.y = 0
			params_highlight.texture = image_params.highlight_texture
			params_highlight.texture_rect = image_params.highlight_texture_rect
			self._object_image_highlight = self._object:bitmap(params_highlight)

			table.insert(self._controls, self._object_image_highlight)
			self._object_image_highlight:set_color(image_params.texture_highlight_color or Color.white)
		end
	end

	if not params.on_click_callback then
		-- Nothing
	end

	self._data = {
		value = params.value
	}
	self._pointer_type = "link"
	self._on_click_callback = params.on_click_callback
	self.on_double_click_callback = params.on_double_click_callback
	self._on_menu_move = params.on_menu_move

	self:highlight_off()

	self._play_mouse_over_sound = true
	self._center_x, self._center_y = self._object:center()
	self._size_w, self._size_h = self._object:size()
	self._font_size = self._object_text:font_size()
	self._enabled = true
end

-- Lines 88-90
function RaidGUIControlButton:close()
	self._object:stop()
end

-- Lines 92-94
function RaidGUIControlButton:set_param_value(param_name, param_value)
	self._params[param_name] = param_value
end

-- Lines 96-119
function RaidGUIControlButton:highlight_on()
	if self._params.no_highlight then
		return
	end

	if self._object_image then
		self._object_image:set_color(self._params.texture_highlight_color or Color.white)
	end

	if self._object_text then
		self._object_text:set_color(self._params.highlight_color or Color.white)
	end

	if self._object_image_highlight then
		self._object_image_highlight:show()
		self._object_image:hide()
	end

	if self._play_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._play_mouse_over_sound = false
	end
end

-- Lines 122-143
function RaidGUIControlButton:highlight_off()
	if self._params.no_highlight or self._selected then
		return
	end

	if alive(self._object_image) then
		self._object_image:set_color(self._params.texture_color or Color.white)
	end

	if self._object_text and alive(self._object_text) then
		self._object_text:set_color(self._params.color or Color.black)
	end

	if self._object_image_highlight then
		self._object_image_highlight:hide()
		self._object_image:show()
	end

	self._play_mouse_over_sound = true
end

-- Lines 145-152
function RaidGUIControlButton:mouse_released(o, button, x, y)
	if self._params.no_click then
		return true
	end

	self:on_mouse_released(button)

	return true
end

-- Lines 154-162
function RaidGUIControlButton:on_mouse_pressed(button)
	if self._params.no_click then
		return true
	end

	self._center_x, self._center_y = self._object:center()

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_press"))
end

-- Lines 164-178
function RaidGUIControlButton:on_mouse_released(button)
	if self._params.no_click then
		return true
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_release"))

	if self._on_click_callback and not self._params.no_click then
		self._on_click_callback(button, self, self._data)
	end

	if self._params.on_click_sound then
		managers.menu_component:post_event(self._params.on_click_sound)
	end
end

-- Lines 180-184
function RaidGUIControlButton:on_double_click(button)
	if self.on_double_click_callback then
		self.on_double_click_callback(button, self, self._data)
	end
end

-- Lines 186-200
function RaidGUIControlButton:set_x(x)
	self._object:set_x(x)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 202-216
function RaidGUIControlButton:set_y(y)
	self._object:set_y(y)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 218-232
function RaidGUIControlButton:set_bottom(bottom)
	self._object:set_bottom(bottom)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 234-250
function RaidGUIControlButton:bottom()
	local bottom = 0
	bottom = self._object:bottom()

	return bottom
end

-- Lines 268-270
function RaidGUIControlButton:set_shape(x, y, w, h)
	self._object:set_shape(x, y, w, h)
end

-- Lines 272-274
function RaidGUIControlButton:set_alpha(alpha)
	self._panel:set_alpha(alpha)
end

-- Lines 276-282
function RaidGUIControlButton:get_text_rect_shape()
	if self._object_text then
		return self._object_text:text_rect()
	else
		return nil
	end
end

-- Lines 284-288
function RaidGUIControlButton:set_text(text)
	if self._object_text then
		self._object_text:set_text(text)
	end
end

-- Lines 290-294
function RaidGUIControlButton:set_text_color(color)
	if self._object_text then
		self._object_text:set_color(color)
	end
end

-- Lines 296-304
function RaidGUIControlButton:set_selected(value)
	self._selected = value

	if self._selected then
		self:highlight_on()
	else
		self:highlight_off()
	end
end

-- Lines 306-308
function RaidGUIControlButton:selected()
	return self._selected
end

-- Lines 310-329
function RaidGUIControlButton:show()
	if self._object and alive(self._object._engine_panel) then
		self._object:show()
		self._object:set_alpha(1)

		if self._object_text then
			self._object_text:set_visible(true)
		end
	end
end

-- Lines 331-349
function RaidGUIControlButton:hide()
	self._object:hide()
	self._object:set_alpha(0)

	if self._object_text then
		self._object_text:set_visible(false)
	end
end

-- Lines 355-358
function RaidGUIControlButton:animate_show()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show"))
end

-- Lines 360-363
function RaidGUIControlButton:animate_hide()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

-- Lines 365-375
function RaidGUIControlButton:enable(active_texture_color)
	if self._object_image and active_texture_color then
		self._object_image:set_color(active_texture_color)
	end

	if self._object_text and active_texture_color then
		self._object_text:set_color(active_texture_color)
	end

	self:set_param_value("no_highlight", false)
	self:set_param_value("no_click", false)

	self._enabled = true
end

-- Lines 377-387
function RaidGUIControlButton:disable(inactive_texture_color)
	if self._object_image and inactive_texture_color then
		self._object_image:set_color(inactive_texture_color)
	end

	if self._object_text and inactive_texture_color then
		self._object_text:set_color(inactive_texture_color)
	end

	self:set_param_value("no_highlight", true)
	self:set_param_value("no_click", true)

	self._enabled = false
end

-- Lines 389-391
function RaidGUIControlButton:enabled()
	return self._enabled
end

-- Lines 393-403
function RaidGUIControlButton:confirm_pressed()
	if self._selected and self._on_click_callback then
		self:_on_click_callback()

		if self._on_menu_move and self._on_menu_move.confirm then
			self:_menu_move_to(self._on_menu_move.confirm)
		end

		return true
	end
end

-- Lines 405-411
function RaidGUIControlButton:set_size(set_w, set_h)
	self._object:set_size(set_w, set_h)

	for _, control in ipairs(self._controls) do
		control:set_size(set_w, set_h)
	end
end

-- Lines 413-419
function RaidGUIControlButton:set_center(set_x, set_y)
	self._object:set_center(set_x, set_y)

	for _, control in ipairs(self._controls) do
		control:set_center(self._object:w() / 2, self._object:h() / 2)
	end
end

-- Lines 422-449
function RaidGUIControlButton:_animate_press()
	local t = 0
	local duration = 0.05

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_in(t, 1, -(1 - RaidGUIControlButton.PRESSED_SIZE), duration)

		self:set_size(self._size_w * scale, self._size_h * scale)
		self:set_center(self._center_x, self._center_y)
		self._object_text:set_center(self._object:w() / 2, self._object:h() / 2)
		self._object_text:set_font_size(self._font_size * scale)
	end

	self:set_size(self._size_w * RaidGUIControlButton.PRESSED_SIZE, self._size_h * RaidGUIControlButton.PRESSED_SIZE)
	self:set_center(self._center_x, self._center_y)
	self._object_text:set_center(self._object:w() / 2, self._object:h() / 2)
	self._object_text:set_font_size(self._font_size * RaidGUIControlButton.PRESSED_SIZE)
end

-- Lines 451-480
function RaidGUIControlButton:_animate_release()
	local t = 0
	local duration = 0.25

	self._object:set_size(self._size_w * RaidGUIControlButton.PRESSED_SIZE, self._size_h * RaidGUIControlButton.PRESSED_SIZE)
	self._object:set_center(self._center_x, self._center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, RaidGUIControlButton.PRESSED_SIZE, 1 - RaidGUIControlButton.PRESSED_SIZE, duration)

		self:set_size(self._size_w * scale, self._size_h * scale)
		self:set_center(self._center_x, self._center_y)
		self._object_text:set_center(self._object:w() / 2, self._object:h() / 2)
		self._object_text:set_font_size(self._font_size * scale)
	end

	self:set_size(self._size_w, self._size_h)
	self:set_center(self._center_x, self._center_y)
	self._object_text:set_center(self._object:w() / 2, self._object:h() / 2)
	self._object_text:set_font_size(self._font_size)
end

-- Lines 482-499
function RaidGUIControlButton:_animate_show()
	local duration = 0.25
	local t = self._object:alpha() * duration

	self._object:set_visible(true)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_in_out(t, 0, 1, duration)

		self._object:set_alpha(alpha)
	end

	self._object:set_alpha(1)
	self:show()
end

-- Lines 501-518
function RaidGUIControlButton:_animate_hide()
	local duration = 0.25
	local t = (1 - self._object:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_in_out(t, 1, -1, duration)

		self._object:set_alpha(alpha)
	end

	self._object:set_visible(false)
	self._object:set_alpha(0)
	self:hide()
end
