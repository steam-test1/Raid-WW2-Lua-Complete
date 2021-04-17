RaidGUIControlButtonToggleSmall = RaidGUIControlButtonToggleSmall or class(RaidGUIControl)
RaidGUIControlButtonToggleSmall.BORDER_ICON = "players_icon_outline"
RaidGUIControlButtonToggleSmall.BORDER_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR = tweak_data.gui.colors.raid_red

-- Lines 8-28
function RaidGUIControlButtonToggleSmall:init(parent, params)
	RaidGUIControlButtonToggleSmall.super.init(self, parent, params)
	self:_create_panel()
	self:_create_image_panel()
	self:_create_border()
	self:_create_active_icon()
	self:_create_inactive_icon()

	self._value = self._params.value or false
	self._play_mouse_over_sound = true
	self._on_selected_callback = params.on_selected_callback
	self._on_unselected_callback = params.on_unselected_callback
	self._on_click_callback = params.on_click_callback
	self._visible = self._params.visible
	self._highlight_animation_t = 0

	self:_render_images()
end

-- Lines 30-37
function RaidGUIControlButtonToggleSmall:_create_panel()
	local panel_params = {
		name = "button_toggle_small_" .. tostring(self._name),
		w = tweak_data.gui:icon_w(RaidGUIControlButtonToggleSmall.BORDER_ICON),
		h = tweak_data.gui:icon_h(RaidGUIControlButtonToggleSmall.BORDER_ICON)
	}
	self._object = self._panel:panel(panel_params)
end

-- Lines 39-44
function RaidGUIControlButtonToggleSmall:_create_image_panel()
	local image_panel_params = {
		name = "image_panel"
	}
	self._image_panel = self._object:panel(image_panel_params)
end

-- Lines 46-54
function RaidGUIControlButtonToggleSmall:_create_border()
	local checkbox_border_params = {
		valign = "scale",
		halign = "scale",
		texture = tweak_data.gui.icons[RaidGUIControlButtonToggleSmall.BORDER_ICON].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlButtonToggleSmall.BORDER_ICON].texture_rect,
		color = RaidGUIControlButtonToggleSmall.BORDER_COLOR
	}
	self._border = self._image_panel:bitmap(checkbox_border_params)
end

-- Lines 56-65
function RaidGUIControlButtonToggleSmall:_create_active_icon()
	local active_icon = self._params.active_icon ~= nil and self._params.active_icon or self._params.inactive_icon
	local active_icon_params = {
		valign = "scale",
		halign = "scale",
		texture = tweak_data.gui.icons[active_icon].texture,
		texture_rect = tweak_data.gui.icons[active_icon].texture_rect
	}
	self._active_icon = self._image_panel:bitmap(active_icon_params)

	self._active_icon:set_center(self._image_panel:w() / 2, self._image_panel:h() / 2)
end

-- Lines 67-76
function RaidGUIControlButtonToggleSmall:_create_inactive_icon()
	local inactive_icon = self._params.inactive_icon ~= nil and self._params.inactive_icon or self._params.active_icon
	local inactive_icon_params = {
		valign = "scale",
		halign = "scale",
		texture = tweak_data.gui.icons[inactive_icon].texture,
		texture_rect = tweak_data.gui.icons[inactive_icon].texture_rect
	}
	self._inactive_icon = self._image_panel:bitmap(inactive_icon_params)

	self._inactive_icon:set_center(self._image_panel:w() / 2, self._image_panel:h() / 2)
end

-- Lines 78-92
function RaidGUIControlButtonToggleSmall:highlight_on()
	if self._object and alive(self._object._engine_panel) then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_highlight_on"))

		if self._play_mouse_over_sound then
			managers.menu_component:post_event("highlight")

			self._play_mouse_over_sound = false
		end

		if self._on_selected_callback then
			self._on_selected_callback()
		end
	end
end

-- Lines 95-106
function RaidGUIControlButtonToggleSmall:highlight_off()
	if self._object and alive(self._object._engine_panel) then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_highlight_off"))

		self._play_mouse_over_sound = true

		if self._on_unselected_callback then
			self._on_unselected_callback()
		end
	end
end

-- Lines 108-113
function RaidGUIControlButtonToggleSmall:mouse_pressed(o, button, x, y)
	if self:inside(x, y) then
		self._image_panel:stop()
		self._image_panel:animate(callback(self, self, "_animate_press"))
	end
end

-- Lines 115-134
function RaidGUIControlButtonToggleSmall:mouse_released(o, button, x, y)
	if self:inside(x, y) then
		if self._value then
			self._value = false
		else
			self._value = true
		end

		self._image_panel:stop()
		self._image_panel:animate(callback(self, self, "_animate_release"))
		self:_render_images()

		if self._on_click_callback then
			self._on_click_callback(button, self, self._value)
		end

		return true
	else
		return false
	end
end

-- Lines 136-138
function RaidGUIControlButtonToggleSmall:set_value(value)
	self._value = value
end

-- Lines 140-142
function RaidGUIControlButtonToggleSmall:get_value()
	return self._value
end

-- Lines 144-147
function RaidGUIControlButtonToggleSmall:set_value_and_render(value)
	self:set_value(value)
	self:_render_images()
end

-- Lines 149-163
function RaidGUIControlButtonToggleSmall:_render_images()
	if self._visible == false then
		self:hide()

		return
	else
		if self._value then
			self._active_icon:set_visible(true)
			self._inactive_icon:set_visible(false)
		else
			self._active_icon:set_visible(false)
			self._inactive_icon:set_visible(true)
		end

		self:show()
	end
end

-- Lines 165-167
function RaidGUIControlButtonToggleSmall:show()
	self._object:show()
end

-- Lines 169-171
function RaidGUIControlButtonToggleSmall:hide()
	self._object:hide()
end

-- Lines 173-176
function RaidGUIControlButtonToggleSmall:set_visible(flag)
	self._visible = flag

	self:_render_images()
end

-- Lines 178-193
function RaidGUIControlButtonToggleSmall:confirm_pressed()
	if self._selected then
		if self._value then
			self._value = false
		else
			self._value = true
		end

		self:_render_images()

		if self._on_click_callback then
			self:_on_click_callback(self, self._value)
		end

		return true
	end

	return false
end

-- Lines 201-219
function RaidGUIControlButtonToggleSmall:_animate_highlight_on()
	local duration = 0.2
	local t = duration - (1 - self._highlight_animation_t) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		self._highlight_animation_t = t / duration
		local border_r = Easing.quartic_out(t, RaidGUIControlButtonToggleSmall.BORDER_COLOR.r, RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.r - RaidGUIControlButtonToggleSmall.BORDER_COLOR.r, duration)
		local border_g = Easing.quartic_out(t, RaidGUIControlButtonToggleSmall.BORDER_COLOR.g, RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.g - RaidGUIControlButtonToggleSmall.BORDER_COLOR.g, duration)
		local border_b = Easing.quartic_out(t, RaidGUIControlButtonToggleSmall.BORDER_COLOR.b, RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.b - RaidGUIControlButtonToggleSmall.BORDER_COLOR.b, duration)

		self._border:set_color(Color(border_r, border_g, border_b))
	end

	self._highlight_animation_t = 1

	self._border:set_color(RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR)
end

-- Lines 221-239
function RaidGUIControlButtonToggleSmall:_animate_highlight_off()
	local duration = 0.2
	local t = duration - self._highlight_animation_t * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		self._highlight_animation_t = 1 - t / duration
		local border_r = Easing.quartic_out(t, RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.r, RaidGUIControlButtonToggleSmall.BORDER_COLOR.r - RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.r, duration)
		local border_g = Easing.quartic_out(t, RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.g, RaidGUIControlButtonToggleSmall.BORDER_COLOR.g - RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.g, duration)
		local border_b = Easing.quartic_out(t, RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.b, RaidGUIControlButtonToggleSmall.BORDER_COLOR.b - RaidGUIControlButtonToggleSmall.BORDER_HOVER_COLOR.b, duration)

		self._border:set_color(Color(border_r, border_g, border_b))
	end

	self._highlight_animation_t = 0

	self._border:set_color(RaidGUIControlButtonToggleSmall.BORDER_COLOR)
end

-- Lines 241-263
function RaidGUIControlButtonToggleSmall:_animate_press()
	local t = 0
	local original_w = tweak_data.gui:icon_w(RaidGUIControlButtonToggleSmall.BORDER_ICON)
	local original_h = tweak_data.gui:icon_h(RaidGUIControlButtonToggleSmall.BORDER_ICON)
	local starting_scale = self._image_panel:w() / original_w
	local duration = 0.25 * (starting_scale - 0.9) / 0.1
	local center_x, center_y = self._image_panel:center()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, starting_scale, 0.9 - starting_scale, duration)

		self._image_panel:set_w(original_w * scale)
		self._image_panel:set_h(original_h * scale)
		self._image_panel:set_center(center_x, center_y)
	end

	self._image_panel:set_w(original_w * 0.9)
	self._image_panel:set_h(original_h * 0.9)
	self._image_panel:set_center(center_x, center_y)
end

-- Lines 265-290
function RaidGUIControlButtonToggleSmall:_animate_release()
	local t = 0
	local duration = 0.25
	local target_w = tweak_data.gui:icon_w(RaidGUIControlButtonToggleSmall.BORDER_ICON)
	local target_h = tweak_data.gui:icon_h(RaidGUIControlButtonToggleSmall.BORDER_ICON)
	local center_x, center_y = self._image_panel:center()

	self._image_panel:set_w(target_w * 0.9)
	self._image_panel:set_h(target_h * 0.9)
	self._image_panel:set_center(center_x, center_y)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local scale = Easing.quartic_out(t, 0.9, 0.1, duration)

		self._image_panel:set_w(target_w * scale)
		self._image_panel:set_h(target_h * scale)
		self._image_panel:set_center(center_x, center_y)
	end

	self._image_panel:set_w(target_w)
	self._image_panel:set_h(target_h)
	self._image_panel:set_center(center_x, center_y)
end
