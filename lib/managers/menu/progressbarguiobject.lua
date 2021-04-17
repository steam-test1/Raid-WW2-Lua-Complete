ProgressBarGuiObject = ProgressBarGuiObject or class()

-- Lines 3-24
function ProgressBarGuiObject:init(panel, config)
	self._panel = panel
	self._width = 288
	self._height = 8
	self._x = self._panel:w() / 2
	self._y = self._panel:h() / 2 + 191
	self._color_red = Color(0.7215686274509804, 0.2235294117647059, 0.1803921568627451)
	self._color_orange = Color(0.8666666666666667, 0.3607843137254902, 0.13725490196078433)
	self._color_yellow = Color(0.8666666666666667, 0.6039215686274509, 0.2196078431372549)
	self._color_green = Color(0.39215686274509803, 0.7372549019607844, 0.2980392156862745)
	self._is_being_animated = false
	self._progress_bar_bg = self._panel:bitmap({
		name = "progress_bar_bg",
		layer = 2,
		visible = false,
		x = self._x - self._width / 2,
		y = self._y - self._width / 2,
		texture = tweak_data.gui.icons.interaction_hold_meter_bg.texture,
		texture_rect = tweak_data.gui.icons.interaction_hold_meter_bg.texture_rect,
		w = self._width,
		h = self._height
	})
	self._progress_bar = self._panel:rect({
		blend_mode = "normal",
		name = "progress_bar",
		h = 0,
		w = 0,
		layer = 3,
		x = self._x - self._width / 2,
		y = self._y - self._height / 2,
		color = tweak_data.gui.colors.interaction_bar
	})

	if config ~= nil and config.description then
		self:_create_description(config.description)
	end
end

-- Lines 26-40
function ProgressBarGuiObject:_create_description(description)
	local description_params = {
		name = "progress_bar_description",
		h = 32,
		w = 256,
		align = "center",
		valign = "bottom",
		font = tweak_data.gui.fonts.din_compressed_outlined_24,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_white,
		text = description
	}
	self._description = self._panel:text(description_params)

	self._description:set_center_x(self._progress_bar_bg:center_x())
	self._description:set_bottom(self._y - 10)
end

-- Lines 42-49
function ProgressBarGuiObject:set_progress(current, total)
	if not self._progress_bar then
		return
	end

	local progress = current / total

	self._progress_bar:set_width(progress * self._width)
end

-- Lines 51-55
function ProgressBarGuiObject:show()
	self._progress_bar_bg:animate(callback(self, self, "_animate_interaction_start"), 0.25)
	self._progress_bar:animate(callback(self, self, "_animate_interaction_start"), 0.25)
end

-- Lines 57-87
function ProgressBarGuiObject:hide(complete)
	if complete then
		self._progress_bar_bg:animate(callback(self, self, "_animate_interaction_complete"))
		self._progress_bar:animate(callback(self, self, "_animate_interaction_complete"))
	else
		self._progress_bar_bg:animate(callback(self, self, "_animate_interaction_cancel"), 0.15)
		self._progress_bar:animate(callback(self, self, "_animate_interaction_cancel"), 0.15)
	end

	if self._description then
		self._panel:remove(self._description)

		self._description = nil
	end

	if self._progress_bar then
		self._progress_bar_bg:stop()
		self._progress_bar:stop()
		self._progress_bar_bg:set_h(0)
		self._progress_bar:set_w(0)
		self._progress_bar:set_h(0)
	end
end

-- Lines 92-94
function ProgressBarGuiObject:animate_progress(duration)
	self._auto_animation = self._progress_bar:animate(callback(self, self, "_animate_interaction_duration"), duration)
end

-- Lines 96-111
function ProgressBarGuiObject:set_position(x, y)
	if not self._progress_bar then
		return
	end

	self._progress_bar_bg:set_center(x, y)
	self._progress_bar:set_center(x, y)

	if self._description then
		self._description:set_center_x(self._progress_bar_bg:center_x())
		self._description:set_bottom(self._progress_bar_bg:y() - 10)
	end

	self._x = x
	self._y = y
end

-- Lines 113-127
function ProgressBarGuiObject:set_x(x)
	if not self._progress_bar then
		return
	end

	self._progress_bar_bg:set_x(x)
	self._progress_bar:set_x(x)

	if self._description then
		self._description:set_center_x(self._progress_bar_bg:center_x())
		self._description:set_bottom(self._progress_bar_bg:y() - 10)
	end

	self._x = x
end

-- Lines 129-143
function ProgressBarGuiObject:set_top(y)
	if not self._progress_bar then
		return
	end

	self._progress_bar_bg:set_top(y)
	self._progress_bar:set_top(y)

	if self._description then
		self._description:set_center_x(self._progress_bar_bg:center_x())
		self._description:set_bottom(self._progress_bar_bg:y() - 10)
	end

	self._y = y + self._height / 2
end

-- Lines 145-159
function ProgressBarGuiObject:set_bottom(y)
	if not self._progress_bar then
		return
	end

	self._progress_bar_bg:set_bottom(y)
	self._progress_bar:set_bottom(y)

	if self._description then
		self._description:set_center_x(self._progress_bar_bg:center_x())
		self._description:set_bottom(self._progress_bar_bg:y() - 10)
	end

	self._y = y - self._height / 2
end

-- Lines 161-175
function ProgressBarGuiObject:set_center_y(y)
	if not self._progress_bar then
		return
	end

	self._progress_bar_bg:set_center_y(y)
	self._progress_bar:set_center_y(y)

	if self._description then
		self._description:set_center_x(self._progress_bar_bg:center_x())
		self._description:set_bottom(self._progress_bar_bg:y() - 10)
	end

	self._y = y
end

-- Lines 178-185
function ProgressBarGuiObject:set_layer(layer)
	if not self._progress_bar then
		return
	end

	self._progress_bar_bg:set_layer(layer)
	self._progress_bar:set_layer(layer + 1)
end

-- Lines 187-189
function ProgressBarGuiObject:width()
	return self._width
end

-- Lines 191-193
function ProgressBarGuiObject:height()
	return self._height
end

-- Lines 195-197
function ProgressBarGuiObject:layer()
	return self._progress_bar_bg:layer()
end

-- Lines 199-211
function ProgressBarGuiObject:remove()
	if not self._progress_bar then
		return
	end

	self._panel:remove(self._progress_bar_bg)
	self._panel:remove(self._progress_bar)

	if self._description then
		self._panel:remove(self._description)

		self._description = nil
	end
end

-- Lines 218-235
function ProgressBarGuiObject:_animate_interaction_start(progress_bar, duration)
	local t = 0

	progress_bar:set_visible(true)

	self._is_being_animated = true

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_height = self:_ease_out_quint(t, 0, self._height, duration)

		progress_bar:set_height(current_height)
		progress_bar:set_y(self._y - current_height / 2)
	end

	progress_bar:set_height(self._height)

	self._is_being_animated = false
end

-- Lines 237-253
function ProgressBarGuiObject:_animate_interaction_cancel(progress_bar, duration)
	local t = 0
	local start_height = progress_bar:h()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_height = self:_ease_in_quint(t, start_height, -start_height, duration)

		progress_bar:set_height(current_height)
		progress_bar:set_y(self._y - current_height / 2)
	end

	progress_bar:set_height(0)
	progress_bar:set_visible(false)
end

-- Lines 255-272
function ProgressBarGuiObject:_animate_interaction_complete(progress_bar)
	local duration = 0.3
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_width = self:_ease_out_quint(t, self._width, -self._width, duration)

		progress_bar:set_width(current_width)
		progress_bar:set_right(self._x + self._width / 2)
	end

	progress_bar:set_width(0)
	progress_bar:set_visible(false)
end

-- Lines 274-299
function ProgressBarGuiObject:_animate_interaction_duration(progress_bar, duration)
	local t = 0
	self._is_being_animated = true

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = t / duration

		progress_bar:set_width(progress * self._width)
		progress_bar:set_left(self._x - self._width / 2)
	end

	progress_bar:set_width(self._width)

	self._is_being_animated = false
end

-- Lines 301-304
function ProgressBarGuiObject:_ease_in_quint(t, starting_value, change, duration)
	t = t / duration

	return change * t * t * t * t * t + starting_value
end

-- Lines 307-311
function ProgressBarGuiObject:_ease_out_quint(t, starting_value, change, duration)
	t = t / duration
	t = t - 1

	return change * (t * t * t * t * t + 1) + starting_value
end
