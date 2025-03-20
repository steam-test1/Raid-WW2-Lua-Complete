RaidGUIControlListItemMenu = RaidGUIControlListItemMenu or class(RaidGUIControl)
RaidGUIControlListItemMenu.BACKGROUND_ICON = "menu_item_background"
RaidGUIControlListItemMenu.BACKGROUND_COLOR = tweak_data.gui.colors.grid_item_grey
RaidGUIControlListItemMenu.FOREGROUND_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlListItemMenu.ICON_SIZE = 28
RaidGUIControlListItemMenu.ICON_UNSELECTED_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlListItemMenu.ICON_SELECTED_COLOR = tweak_data.gui.colors.raid_black
RaidGUIControlListItemMenu.LABEL_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlListItemMenu.LABEL_FONT_SIZE = tweak_data.gui.font_sizes.menu_list
RaidGUIControlListItemMenu.LABEL_UNSELECTED_LEFT = 10
RaidGUIControlListItemMenu.LABEL_SELECTED_LEFT = 18
RaidGUIControlListItemMenu.UNSELECTED_LEFT = 0
RaidGUIControlListItemMenu.UNSELECTED_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlListItemMenu.SELECTED_LEFT = 4
RaidGUIControlListItemMenu.SELECTED_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlListItemMenu.GLOW_COLOR = Color.white
RaidGUIControlListItemMenu.MARKER_PADDING = 8
RaidGUIControlListItemMenu.OFFSET_WHILE_HIDDEN = 100

function RaidGUIControlListItemMenu:init(parent, params, data)
	RaidGUIControlListItemMenu.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemMenu:init] On click callback not specified for list item: ", params.name)
	end

	self._on_click_callback = params.on_click_callback
	self._on_double_click_callback = params.on_double_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._data = data

	self:_layout_panel(params)
	self:_layout(params, data)

	if self._data.breadcrumb then
		self:_layout_breadcrumb()
	end

	self._mouse_over_sound = params.on_mouse_over_sound_event or "highlight"
	self._click_sound = params.on_mouse_click_sound_event
	self._selected_color = params.color or self.SELECTED_COLOR
	self._glow_color = data.glow_color or self.GLOW_COLOR
	self._selectable = self._data.selectable
	self._selected = false

	self:highlight_off()
end

function RaidGUIControlListItemMenu:_layout_panel(params)
	self._object = self._panel:panel({
		name = "list_item_object_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h
	})
end

function RaidGUIControlListItemMenu:_layout(params, data)
	local fg_color = params.color or self.FOREGROUND_COLOR
	self._selection_panel = self._object:panel({
		alpha = 0,
		name = "selection_panel",
		visible = false
	})
	local background_data = tweak_data.gui:get_full_gui_data(self.BACKGROUND_ICON)
	self._background = self._selection_panel:bitmap({
		w = self._object:w(),
		h = self._object:h(),
		texture = background_data.texture,
		texture_rect = background_data.texture_rect,
		color = self.BACKGROUND_COLOR
	})
	local gradient_points = {
		0,
		fg_color,
		0.6,
		fg_color,
		1,
		fg_color:with_alpha(0)
	}
	local top_line = self._selection_panel:gradient({
		h = 1,
		w = self._object:w() * 0.9,
		gradient_points = gradient_points,
		layer = self._background:layer() + 1
	})
	local bottom_line = self._selection_panel:gradient({
		h = 1,
		y = self._object:h() - 1,
		w = self._object:w(),
		gradient_points = gradient_points,
		layer = self._background:layer() + 1
	})
	self._highlight_marker = self._selection_panel:rect({
		w = 0,
		h = self._object:h(),
		color = fg_color,
		layer = self._background:layer() + 1
	})
	self._data_panel = self._object:panel({
		name = "selection_panel"
	})
	local icon_data = tweak_data.gui:get_full_gui_data(data.icon)
	self._item_icon = self._data_panel:bitmap({
		name = "list_item_label_" .. self._name,
		w = self.ICON_SIZE,
		h = self.ICON_SIZE,
		texture = icon_data.texture,
		texture_rect = icon_data.texture_rect,
		color = params.color or self.UNSELECTED_COLOR,
		layer = self._background:layer() + 5
	})

	self._item_icon:set_center_y(self._data_panel:h() / 2)

	if not data.icon then
		self._item_icon:set_w(0)
		self._item_icon:hide()
	end

	local font = self._params.item_font or self.LABEL_FONT
	local font_size = self._params.item_font_size or self.LABEL_FONT_SIZE
	self._item_label = self._data_panel:text({
		vertical = "center",
		name = "list_item_label_" .. self._name,
		x = self._item_icon:right() + self.LABEL_UNSELECTED_LEFT,
		text = data.text,
		font = tweak_data.gui:get_font_path(font, font_size),
		font_size = font_size,
		color = params.color or self.UNSELECTED_COLOR,
		layer = self._background:layer() + 5
	})
end

function RaidGUIControlListItemMenu:_layout_breadcrumb()
	self._breadcrumb = self._object:breadcrumb(self._data.breadcrumb)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

function RaidGUIControlListItemMenu:on_mouse_released(button)
	if self._on_click_callback then
		self._on_click_callback(button, self, self._data)
	end

	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end
end

function RaidGUIControlListItemMenu:selected()
	return self._selected
end

function RaidGUIControlListItemMenu:select(dont_trigger_selected_callback)
	if not self._selected then
		self._selected = true

		self:highlight_on()

		if self._on_item_selected_callback and not dont_trigger_selected_callback then
			self:_on_item_selected_callback(self._data)
		end

		if self._data.breadcrumb then
			managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
		end
	end
end

function RaidGUIControlListItemMenu:unfocus()
	self:unselect(true)
end

function RaidGUIControlListItemMenu:unselect(force)
	if self._selected then
		self:highlight_off()

		self._selected = false
	end
end

function RaidGUIControlListItemMenu:data()
	return self._data
end

function RaidGUIControlListItemMenu:highlight_on()
	if self._selection_panel then
		self._selection_panel:stop()
		self._selection_panel:animate(callback(self, self, "_animate_selected"))
	end

	if not self._played_mouse_over_sound then
		managers.menu_component:post_event(self._mouse_over_sound)

		self._played_mouse_over_sound = true
	end
end

function RaidGUIControlListItemMenu:highlight_off(force)
	if (self._selected or force) and self._selection_panel then
		self._selection_panel:stop()
		self._selection_panel:animate(callback(self, self, "_animate_unselected"))
	end

	self._played_mouse_over_sound = nil
end

function RaidGUIControlListItemMenu:animate_show(delay)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show", delay))
end

function RaidGUIControlListItemMenu:animate_hide(delay)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide", delay))
end

function RaidGUIControlListItemMenu:_animate_show(delay, panel)
	local duration = 0.15
	local t = 0

	panel:set_visible(true)
	panel:set_alpha(0)
	panel:set_x(-self.OFFSET_WHILE_HIDDEN)

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, duration)

		panel:set_alpha(current_alpha)

		local current_offset = Easing.quartic_out(t, self.OFFSET_WHILE_HIDDEN, -self.OFFSET_WHILE_HIDDEN, duration)

		panel:set_x(current_offset)
	end

	panel:set_alpha(1)
	panel:set_x(0)
end

function RaidGUIControlListItemMenu:_animate_hide(delay, panel)
	local duration = 0.15
	local t = (1 - panel:alpha()) * duration

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in(t, 1, -1, duration)

		panel:set_alpha(current_alpha)

		local current_offset = Easing.quartic_in(t, 0, self.OFFSET_WHILE_HIDDEN, duration)

		panel:set_x(current_offset)
	end

	panel:set_alpha(0)
	panel:set_x(self.OFFSET_WHILE_HIDDEN)
	panel:set_visible(false)
end

function RaidGUIControlListItemMenu:_animate_selected()
	local duration = 0.12
	local t = self._selection_panel:alpha() * duration
	local marker_w = self._item_icon:w() + self.MARKER_PADDING
	local label_start_x = self._item_icon:w() + self.LABEL_UNSELECTED_LEFT
	local label_end_x = self._item_icon:w() + self.LABEL_SELECTED_LEFT

	self._selection_panel:show()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)

		self._selection_panel:set_alpha(progress)
		self._highlight_marker:set_w(math.lerp(0, marker_w, progress))
		self._data_panel:set_x(math.lerp(self.UNSELECTED_LEFT, self.SELECTED_LEFT, progress))
		self._item_icon:set_color(math.lerp(self.ICON_UNSELECTED_COLOR, self.ICON_SELECTED_COLOR, progress))
		self._item_label:set_x(math.lerp(label_start_x, label_end_x, progress))
		self._item_label:set_color(math.lerp(self.UNSELECTED_COLOR, self._selected_color, progress))
	end

	self._selection_panel:set_alpha(1)
	self._highlight_marker:set_w(marker_w)
	self._data_panel:set_x(self.SELECTED_LEFT)
	self._item_icon:set_color(self.ICON_SELECTED_COLOR)
	self._item_label:set_color(self._selected_color)
	self._item_label:set_x(label_end_x)
	self._item_label:stop()
	self._item_label:animate(UIAnimation.animate_text_glow, self._glow_color, 0.72, 0.076, 1.2, 0.2)
end

function RaidGUIControlListItemMenu:_animate_unselected()
	local duration = 0.12
	local t = (1 - self._selection_panel:alpha()) * duration
	local marker_w = self._item_icon:w() + self.MARKER_PADDING
	local label_start_x = self._item_icon:w() + self.LABEL_UNSELECTED_LEFT
	local label_end_x = self._item_icon:w() + self.LABEL_SELECTED_LEFT

	self._item_label:stop()
	self._item_label:clear_range_color(0, string.len(self._item_label:text()))

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 1, -1, duration)

		self._selection_panel:set_alpha(progress)
		self._highlight_marker:set_w(math.lerp(0, marker_w, progress))
		self._data_panel:set_x(math.lerp(self.UNSELECTED_LEFT, self.SELECTED_LEFT, progress))
		self._item_icon:set_color(math.lerp(self.ICON_UNSELECTED_COLOR, self.ICON_SELECTED_COLOR, progress))
		self._item_label:set_x(math.lerp(label_start_x, label_end_x, progress))
		self._item_label:set_color(math.lerp(self.UNSELECTED_COLOR, self._selected_color, progress))
	end

	self._selection_panel:set_alpha(0)
	self._selection_panel:hide(0)
	self._highlight_marker:set_w(marker_w)
	self._data_panel:set_x(self.UNSELECTED_LEFT)
	self._item_icon:set_color(self.ICON_UNSELECTED_COLOR)
	self._item_label:set_color(self.UNSELECTED_COLOR)
	self._item_label:set_x(label_start_x)
end

function RaidGUIControlListItemMenu:confirm_pressed(button)
	if self._selected then
		if self._on_click_callback then
			self:unselect()
			self._on_click_callback(button, self, self._data, true)

			return true
		end

		if self._params.list_item_selected_callback then
			self:unselect()
			self._params.list_item_selected_callback(self._name)

			return true
		end
	end
end
