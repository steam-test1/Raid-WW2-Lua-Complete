RaidGUIControlImageButton = RaidGUIControlImageButton or class(RaidGUIControlImage)
RaidGUIControlImageButton.DISABLED_COLOR = tweak_data.gui.colors.raid_dark_grey

-- Lines 5-33
function RaidGUIControlImageButton:init(parent, params)
	RaidGUIControlImageButton.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlImageButton:init] On click callback not specified for image button: ", params.name)
	end

	self._data = {
		value = params.value
	}
	self._pointer_type = "link"
	self._on_click_callback = params.on_click_callback
	self._color = params.color or Color.red
	self._highlight_color = params.highlight_color or Color.red
	self._disabled_color = params.disabled_color or RaidGUIControlImageButton.DISABLED_COLOR

	self:_create_highlight_image()

	self._highlight_texture = params.highlight_texture
	self._highlight_texture_rect = params.highlight_texture_rect
	self._w = self._object:w()
	self._h = self._object:h()

	self:highlight_off()
	self._object:set_color(self._color)
end

-- Lines 35-49
function RaidGUIControlImageButton:_create_highlight_image()
	self._highlight_texture = self._params.highlight_texture
	self._highlight_texture_rect = self._params.highlight_texture_rect

	if not self._highlight_texture then
		return
	end

	self._highlight_image_params = clone(self.params)
	self._highlight_image_params.texture = self._highlight_texture
	self._highlight_image_params.texture_rect = self._highlight_texture_rect
	self._highlight_image_params.color = self._highlight_color or Color.red
	self._highlight_image = self._panel:bitmap(params)
end

-- Lines 51-72
function RaidGUIControlImageButton:highlight_on()
	if self._params.no_highlight then
		return
	end

	self._highlighted = true

	if not self._enabled then
		return
	end

	if self._highlight_image then
		self._object:hide()
		self._highlight_image:show()
	else
		self._object:stop()

		if self._highlight_color ~= self._color then
			self._object:animate(callback(self, self, "_animate_highlight_on"))
		end
	end
end

-- Lines 75-92
function RaidGUIControlImageButton:highlight_off()
	self._highlighted = false

	if not self._enabled then
		return
	end

	if self._highlight_image then
		self._object:show()
		self._highlight_image:hide()
	else
		self._object:stop()

		if self._highlight_color ~= self._color then
			self._object:animate(callback(self, self, "_animate_highlight_off"))
		end
	end
end

-- Lines 94-107
function RaidGUIControlImageButton:on_mouse_pressed(button)
	if not self._enabled then
		return
	end

	if self._active_click_animation then
		self._object:stop(self._active_click_animation)
	end

	if self._active_click_animation then
		self._object:stop(self._active_click_animation)
	end

	self._active_click_animation = self._object:animate(callback(self, self, "_animate_press"))
end

-- Lines 109-120
function RaidGUIControlImageButton:mouse_released(o, button, x, y)
	if not self._enabled then
		return
	end

	if self._active_click_animation then
		self._object:stop(self._active_click_animation)
	end

	self:on_mouse_released(button)

	return true
end

-- Lines 122-130
function RaidGUIControlImageButton:on_mouse_released(button)
	if self._active_click_animation then
		self._object:stop(self._active_click_animation)
	end

	self._active_click_animation = self._object:animate(callback(self, self, "_animate_release"))

	self._on_click_callback(button, self, self._data)
end

-- Lines 132-144
function RaidGUIControlImageButton:set_enabled(enabled)
	RaidGUIControlImageButton.super.set_enabled(self, enabled)

	if enabled then
		if self._highlighted then
			self._object:set_color(self._highlight_color)
		else
			self._object:set_color(self._color)
		end
	else
		self._object:set_color(self._disabled_color)
	end
end

-- Lines 150-173
function RaidGUIControlImageButton:_animate_highlight_on()
	self._highlight_animation_t = self._highlight_animation_t or 0
	local duration = 0.2
	local t = self._highlight_animation_t * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local border_r = Easing.quartic_out(t, self._color.r, self._highlight_color.r - self._color.r, duration)
		local border_g = Easing.quartic_out(t, self._color.g, self._highlight_color.g - self._color.g, duration)
		local border_b = Easing.quartic_out(t, self._color.b, self._highlight_color.b - self._color.b, duration)

		self._object:set_color(Color(border_r, border_g, border_b))

		self._highlight_animation_t = t / duration
	end

	self._object:set_color(self._highlight_color)

	self._highlight_animation_t = 1
end

-- Lines 175-198
function RaidGUIControlImageButton:_animate_highlight_off()
	self._highlight_animation_t = self._highlight_animation_t or 0
	local duration = 0.2
	local t = (1 - self._highlight_animation_t) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local border_r = Easing.quartic_out(t, self._highlight_color.r, self._color.r - self._highlight_color.r, duration)
		local border_g = Easing.quartic_out(t, self._highlight_color.g, self._color.g - self._highlight_color.g, duration)
		local border_b = Easing.quartic_out(t, self._highlight_color.b, self._color.b - self._highlight_color.b, duration)

		self._object:set_color(Color(border_r, border_g, border_b))

		self._highlight_animation_t = 1 - t / duration
	end

	self._object:set_color(self._color)

	self._highlight_animation_t = 0
end

-- Lines 200-222
function RaidGUIControlImageButton:_animate_press()
	local t = 0
	local original_w = self._w
	local original_h = self._h
	local starting_scale = self._object:w() / original_w
	local duration = 0.25 * (starting_scale - 0.9) / 0.1
	local center_x, center_y = self._object:center()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, starting_scale, 0.9 - starting_scale, duration)

		self._object:set_w(original_w * scale)
		self._object:set_h(original_h * scale)
		self._object:set_center(center_x, center_y)
	end

	self._object:set_w(original_w * 0.9)
	self._object:set_h(original_h * 0.9)
	self._object:set_center(center_x, center_y)
end

-- Lines 224-249
function RaidGUIControlImageButton:_animate_release()
	local t = 0
	local duration = 0.25
	local target_w = self._w
	local target_h = self._h
	local center_x, center_y = self._object:center()

	self._object:set_w(target_w * 0.9)
	self._object:set_h(target_h * 0.9)
	self._object:set_center(center_x, center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, 0.9, 0.1, duration)

		self._object:set_w(target_w * scale)
		self._object:set_h(target_h * scale)
		self._object:set_center(center_x, center_y)
	end

	self._object:set_w(target_w)
	self._object:set_h(target_h)
	self._object:set_center(center_x, center_y)
end
