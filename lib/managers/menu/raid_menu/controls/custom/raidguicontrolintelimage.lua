RaidGUIControlIntelImage = RaidGUIControlIntelImage or class(RaidGUIControl)
RaidGUIControlIntelImage.DEFAULT_W = 236
RaidGUIControlIntelImage.DEFAULT_H = 175
RaidGUIControlIntelImage.BACKGROUND_SIZE_PERCENTAGE = 0.85
RaidGUIControlIntelImage.FOREGROUND_SIZE_PERCENTAGE = 0.92
RaidGUIControlIntelImage.SELECTOR_ICON = "ico_sel_rect_top_left"
RaidGUIControlIntelImage.PRESSED_SIZE = 0.95
RaidGUIControlIntelImage.HOVER_SIZE = 1.05
RaidGUIControlIntelImage.ACTIVE_SIZE = 0.97

-- Lines 13-24
function RaidGUIControlIntelImage:init(parent, params)
	RaidGUIControlIntelImage.super.init(self, parent, params)

	self._on_click_callback = params.on_click_callback
	self._static = params.static

	self:_create_panels()
	self:_create_image()

	self._center_x, self._center_y = self._object:center()
end

-- Lines 26-39
function RaidGUIControlIntelImage:_create_panels()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = panel_params.layer or self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or RaidGUIControlIntelImage.DEFAULT_W
	panel_params.h = self._params.h or RaidGUIControlIntelImage.DEFAULT_H
	panel_params.alpha = panel_params.alpha or 1
	self._object = self._panel:panel(panel_params)
end

-- Lines 41-98
function RaidGUIControlIntelImage:_create_image()
	local default_image = "ui/loading_screens/loading_trainyard"
	local default_rect = {
		256,
		0,
		1536,
		1024
	}
	local image_panel_params = {
		valign = "scale",
		name = "background_panel",
		halign = "scale",
		w = self._object:w() * RaidGUIControlIntelImage.BACKGROUND_SIZE_PERCENTAGE,
		h = self._object:h() * RaidGUIControlIntelImage.BACKGROUND_SIZE_PERCENTAGE,
		layer = self._object:layer() + 1
	}
	self._image_panel = self._object:panel(image_panel_params)

	self._image_panel:set_center_x(self._object:w() / 2)
	self._image_panel:set_center_y(self._object:h() / 2)

	local background_params = {
		texture = "ui/main_menu/textures/mission_paper_background",
		name = "background",
		halign = "scale",
		valign = "scale",
		y = 0,
		x = 0,
		w = self._image_panel:w(),
		h = self._image_panel:h(),
		texture_rect = {
			1063,
			5,
			882,
			613
		},
		layer = self._object:layer() + 1
	}
	self._background = self._image_panel:bitmap(background_params)
	local foreground_params = {
		name = "foreground",
		halign = "scale",
		valign = "scale",
		w = self._image_panel:w() * RaidGUIControlIntelImage.FOREGROUND_SIZE_PERCENTAGE,
		h = self._image_panel:h() * RaidGUIControlIntelImage.FOREGROUND_SIZE_PERCENTAGE,
		texture = self._params.photo and tweak_data.gui.mission_photos[self._params.photo].texture or default_image,
		texture_rect = self._params.photo and tweak_data.gui.mission_photos[self._params.photo].texture_rect or default_rect,
		layer = self._object:layer() + 2
	}
	self._foreground = self._image_panel:bitmap(foreground_params)

	self._foreground:set_center_x(self._image_panel:w() / 2)
	self._foreground:set_center_y(self._image_panel:h() / 2)

	local selector_params = {
		name = "selector",
		h = 24,
		w = 24,
		halign = "scale",
		valign = "scale",
		alpha = 0,
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[RaidGUIControlIntelImage.SELECTOR_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlIntelImage.SELECTOR_ICON].texture_rect,
		layer = self._object:layer() + 3
	}
	self._selector = self._image_panel:bitmap(selector_params)
	self._size_w = self._object:w()
	self._size_h = self._object:h()
end

-- Lines 100-107
function RaidGUIControlIntelImage:on_mouse_pressed(button)
	if self._static then
		return
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_press"))
end

-- Lines 109-127
function RaidGUIControlIntelImage:on_mouse_released(button)
	if self._static then
		return
	end

	if self._on_click_callback and not self._params.no_click then
		self._on_click_callback()
	end

	self:select()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_release"))

	return true
end

-- Lines 129-136
function RaidGUIControlIntelImage:highlight_on()
	if self._active or self._static then
		return
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_on"))
end

-- Lines 138-145
function RaidGUIControlIntelImage:highlight_off()
	if self._active or self._static then
		return
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_highlight_off"))
end

-- Lines 147-150
function RaidGUIControlIntelImage:set_left(left)
	self._object:set_left(left)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 152-155
function RaidGUIControlIntelImage:set_right(right)
	self._object:set_right(right)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 157-160
function RaidGUIControlIntelImage:set_top(top)
	self._object:set_top(top)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 162-165
function RaidGUIControlIntelImage:set_bottom(bottom)
	self._object:set_bottom(bottom)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 167-170
function RaidGUIControlIntelImage:set_center_x(center_x)
	self._object:set_center_x(center_x)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 172-175
function RaidGUIControlIntelImage:set_center_y(center_y)
	self._object:set_center_y(center_y)

	self._center_x, self._center_y = self._object:center()
end

-- Lines 177-190
function RaidGUIControlIntelImage:select(skip_animation)
	if self._static then
		return
	end

	self._active = true

	if skip_animation then
		self._selector:set_alpha(1)
	else
		self._selector:stop()
		self._selector:animate(callback(self, self, "_animate_selected"))
	end
end

-- Lines 192-200
function RaidGUIControlIntelImage:unselect()
	if self._static then
		return
	end

	self._active = false

	self._selector:stop()
	self._selector:animate(callback(self, self, "_animate_unselected"))
end

-- Lines 202-216
function RaidGUIControlIntelImage:set_selected(value)
	if self._static then
		return
	end

	self._selected = value

	if self._selected then
		self:on_mouse_released(Idstring("0"))
		self:highlight_on()
	else
		self:unselect()
		self:highlight_off()
	end
end

-- Lines 218-229
function RaidGUIControlIntelImage:confirm_pressed()
	if self._static then
		return
	end

	if self._selected then
		self:select()

		return true
	end

	return false
end

-- Lines 232-233
function RaidGUIControlIntelImage:close()
end

-- Lines 239-254
function RaidGUIControlIntelImage:_animate_selected()
	local starting_alpha = self._selector:alpha()
	local duration = 0.2
	local t = duration - (1 - starting_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 0, 1, duration)

		self._selector:set_alpha(alpha)
	end

	self._selector:set_alpha(1)
end

-- Lines 256-278
function RaidGUIControlIntelImage:_animate_unselected()
	local starting_alpha = self._selector:alpha()
	local duration = 0.2
	local t = duration - starting_alpha * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 1, -1, duration)

		self._selector:set_alpha(alpha)

		local scale = Easing.quartic_out(t, RaidGUIControlIntelImage.ACTIVE_SIZE, 1 - RaidGUIControlIntelImage.ACTIVE_SIZE, duration)

		self._object:set_size(self._size_w * scale, self._size_h * scale)
		self._object:set_center(self._center_x, self._center_y)
	end

	self._selector:set_alpha(0)
	self._object:set_size(self._size_w, self._size_h)
	self._object:set_center(self._center_x, self._center_y)
end

-- Lines 280-296
function RaidGUIControlIntelImage:_animate_highlight_on()
	local t = 0
	local duration = 0.05

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_in(t, 1, RaidGUIControlIntelImage.HOVER_SIZE - 1, duration)

		self._object:set_size(self._size_w * scale, self._size_h * scale)
		self._object:set_center(self._center_x, self._center_y)
	end

	self._object:set_size(self._size_w * RaidGUIControlIntelImage.HOVER_SIZE, self._size_h * RaidGUIControlIntelImage.HOVER_SIZE)
	self._object:set_center(self._center_x, self._center_y)
end

-- Lines 298-317
function RaidGUIControlIntelImage:_animate_highlight_off()
	local t = 0
	local duration = 0.25

	self._object:set_size(self._size_w * RaidGUIControlIntelImage.HOVER_SIZE, self._size_h * RaidGUIControlIntelImage.HOVER_SIZE)
	self._object:set_center(self._center_x, self._center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, RaidGUIControlIntelImage.HOVER_SIZE, 1 - RaidGUIControlIntelImage.HOVER_SIZE, duration)

		self._object:set_size(self._size_w * scale, self._size_h * scale)
		self._object:set_center(self._center_x, self._center_y)
	end

	self._object:set_size(self._size_w, self._size_h)
	self._object:set_center(self._center_x, self._center_y)
end

-- Lines 319-337
function RaidGUIControlIntelImage:_animate_press()
	local t = 0
	local duration = 0.05
	local initial_size = self._object:w() / self._size_w

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_in(t, initial_size, -(initial_size - RaidGUIControlIntelImage.PRESSED_SIZE), duration)

		self._object:set_size(self._size_w * scale, self._size_h * scale)
		self._object:set_center(self._center_x, self._center_y)
	end

	self._object:set_size(self._size_w * RaidGUIControlIntelImage.PRESSED_SIZE, self._size_h * RaidGUIControlIntelImage.PRESSED_SIZE)
	self._object:set_center(self._center_x, self._center_y)
end

-- Lines 339-358
function RaidGUIControlIntelImage:_animate_release()
	local t = 0
	local duration = 0.25

	self._object:set_size(self._size_w * RaidGUIControlIntelImage.PRESSED_SIZE, self._size_h * RaidGUIControlIntelImage.PRESSED_SIZE)
	self._object:set_center(self._center_x, self._center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, RaidGUIControlIntelImage.PRESSED_SIZE, RaidGUIControlIntelImage.ACTIVE_SIZE - RaidGUIControlIntelImage.PRESSED_SIZE, duration)

		self._object:set_size(self._size_w * scale, self._size_h * scale)
		self._object:set_center(self._center_x, self._center_y)
	end

	self._object:set_size(self._size_w * RaidGUIControlIntelImage.ACTIVE_SIZE, self._size_h * RaidGUIControlIntelImage.ACTIVE_SIZE)
	self._object:set_center(self._center_x, self._center_y)
end
