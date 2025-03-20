RaidGUIControlListItemContextButton = RaidGUIControlListItemContextButton or class(RaidGUIControl)
RaidGUIControlListItemContextButton.BACKGROUND_ICON = "list_btn_context_bg"
RaidGUIControlListItemContextButton.BACKGROUND_SELECTED_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlListItemContextButton.FOREGROUND_ICON = "list_btn_context_fg"
RaidGUIControlListItemContextButton.ICON_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlListItemContextButton.ICON_SELECTED_COLOR = tweak_data.gui.colors.raid_black

function RaidGUIControlListItemContextButton:init(parent, params)
	RaidGUIControlListItemContextButton.super.init(self, parent, params)

	self._on_click_callback = params.on_click_callback
	self._selected_icon_size = params.icon_size_on or params.w * 0.65
	self._unselected_icon_size = params.icon_size_off or params.h * 0.45

	self:_layout(params)
end

function RaidGUIControlListItemContextButton:_layout(params)
	self._object = self._panel:panel(params)
	local background_data = tweak_data.gui:get_full_gui_data(self.BACKGROUND_ICON)
	self._background = self._object:bitmap({
		name = "context_background",
		w = self._object:w(),
		h = self._object:h(),
		color = self.ICON_COLOR,
		texture = background_data.texture,
		texture_rect = background_data.texture_rect
	})
	local foreground_data = tweak_data.gui:get_full_gui_data(self.FOREGROUND_ICON)
	self._foreground = self._object:bitmap({
		alpha = 0,
		name = "context_foreground",
		w = self._object:w(),
		h = self._object:h(),
		color = self.BACKGROUND_SELECTED_COLOR,
		texture = foreground_data.texture,
		texture_rect = foreground_data.texture_rect
	})

	if params.texture then
		self._icon = self._object:bitmap({
			name = "context_icon",
			w = self._unselected_icon_size,
			h = self._unselected_icon_size,
			texture = params.texture,
			texture_rect = params.texture_rect,
			color = self.ICON_COLOR,
			layer = self._background:layer() + 1
		})

		self._icon:set_center(self._background:center())
	end
end

function RaidGUIControlListItemContextButton:highlight_on()
	if not self._highlighted then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_select"))

		self._highlighted = true
	end

	if not self._played_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._played_mouse_over_sound = true
	end
end

function RaidGUIControlListItemContextButton:highlight_off()
	if self._highlighted then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_unselect"))

		self._highlighted = nil
	end

	self._played_mouse_over_sound = nil
end

function RaidGUIControlListItemContextButton:_animate_select()
	local duration = 0.12
	local t = self._foreground:alpha() * duration

	self._foreground:show()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_out(t, 0, 1, duration)
		local current_color = math.lerp(self.ICON_COLOR, self.BACKGROUND_SELECTED_COLOR, current_alpha)

		self._foreground:set_alpha(current_alpha)
		self._background:set_color(current_color)

		if self._icon then
			local current_size = math.lerp(self._unselected_icon_size, self._selected_icon_size, current_alpha)
			local current_color = math.lerp(self.ICON_COLOR, self.ICON_SELECTED_COLOR, current_alpha)

			self._icon:set_color(current_color)
			self._icon:set_size(current_size, current_size)
			self._icon:set_center(self._background:center())
		end
	end

	self._foreground:set_alpha(1)
	self._icon:set_color(self.ICON_SELECTED_COLOR)
end

function RaidGUIControlListItemContextButton:_animate_unselect()
	local duration = 0.12
	local t = (1 - self._foreground:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in_out(t, 1, -1, duration)
		local current_color = math.lerp(self.ICON_COLOR, self.BACKGROUND_SELECTED_COLOR, current_alpha)

		self._foreground:set_alpha(current_alpha)
		self._background:set_color(current_color)

		if self._icon then
			local current_size = math.lerp(self._unselected_icon_size, self._selected_icon_size, current_alpha)
			local current_color = math.lerp(self.ICON_COLOR, self.ICON_SELECTED_COLOR, current_alpha)

			self._icon:set_color(current_color)
			self._icon:set_size(current_size, current_size)
			self._icon:set_center(self._background:center())
		end
	end

	self._foreground:hide()
	self._foreground:set_alpha(0)
	self._icon:set_color(self.ICON_COLOR)
end

function RaidGUIControlListItemContextButton:mouse_released(o, button, x, y)
	return self:on_mouse_released()
end

function RaidGUIControlListItemContextButton:on_mouse_released(button)
	if self._on_click_callback then
		self._on_click_callback(self._params.callback_value)

		return true
	end
end

function RaidGUIControlListItemContextButton:set_right(right)
	self._object:set_right(right)
end

function RaidGUIControlListItemContextButton:set_alpha(alpha)
	self._object:set_alpha(alpha)
end
