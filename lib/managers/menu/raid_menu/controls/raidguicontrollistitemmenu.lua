RaidGUIControlListItemMenu = RaidGUIControlListItemMenu or class(RaidGUIControl)

-- Lines 4-78
function RaidGUIControlListItemMenu:init(parent, params, data)
	RaidGUIControlListItemMenu.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlListItemMenu:init] On click callback not specified for list item: ", params.name)
	end

	self._on_click_callback = params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._on_double_click_callback = params.on_double_click_callback
	self._data = data
	local font, font_size = self:_get_font_desc()
	self._object = self._panel:panel({
		name = "list_item_object_" .. self._name,
		x = params.x,
		y = params.y,
		w = params.w,
		h = params.h
	})
	self._item_label = self._object:label({
		vertical = "center",
		y = 0,
		x = 32,
		name = "list_item_label_" .. self._name,
		w = params.w,
		h = params.h,
		text = data.text,
		font = font,
		font_size = font_size,
		color = self._data.value.unlocked and tweak_data.gui.colors.raid_white or tweak_data.gui.colors.raid_dark_grey
	})
	self._item_background = self._object:rect({
		y = 1,
		visible = false,
		x = 0,
		name = "list_item_back_" .. self._name,
		w = params.w,
		h = params.h - 2,
		color = tweak_data.gui.colors.raid_list_background,
		layer = self._item_label:layer() - 1
	})
	self._item_highlight_marker = self._object:rect({
		y = 1,
		w = 3,
		visible = false,
		x = 0,
		name = "list_item_highlight_" .. self._name,
		h = params.h - 2,
		color = tweak_data.gui.colors.raid_red
	})

	if self._data and self._data.value and not self._data.value.unlocked then
		local ico_locker = tweak_data.gui.icons.ico_locker
		local text_rect = ico_locker.texture_rect

		self._object:image({
			name = "locker_icon",
			x = self._object:right() - 74,
			y = self._object:h() / 2 - text_rect[4] / 2,
			w = text_rect[3],
			h = text_rect[4],
			texture = ico_locker.texture,
			texture_rect = text_rect
		})
	end

	self._enabled = true

	if params and params.use_unlocked and self._data and self._data.value and not self._data.value.unlocked then
		self._on_click_callback = nil

		self:disable(tweak_data.gui.colors.raid_dark_grey)
	end

	if self._data.breadcrumb then
		self:_layout_breadcrumb()
	end

	self._selectable = self._data.selectable
	self._selected = false

	self:highlight_off()
end

-- Lines 80-84
function RaidGUIControlListItemMenu:_layout_breadcrumb()
	self._breadcrumb = self._object:breadcrumb(self._data.breadcrumb)

	self._breadcrumb:set_right(self._object:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

-- Lines 86-88
function RaidGUIControlListItemMenu:_get_font_desc()
	return tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.menu_list
end

-- Lines 90-109
function RaidGUIControlListItemMenu:on_mouse_released(button)
	if self._on_click_callback then
		self._on_click_callback(button, self, self._data)
	end

	if self._params.on_mouse_click_sound_event then
		managers.menu_component:post_event(self._params.on_mouse_click_sound_event)
	end

	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end

	return true
end

-- Lines 111-122
function RaidGUIControlListItemMenu:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._character_slot)

		return true
	end
end

-- Lines 124-126
function RaidGUIControlListItemMenu:selected()
	return self._selected
end

-- Lines 128-145
function RaidGUIControlListItemMenu:select(dont_trigger_selected_callback)
	if self._params.no_click then
		return
	end

	self._selected = true

	self:highlight_on()

	if self._on_item_selected_callback and not dont_trigger_selected_callback then
		self:_on_item_selected_callback(self._data)
	end

	if self._data.breadcrumb then
		managers.breadcrumb:remove_breadcrumb(self._data.breadcrumb.category, self._data.breadcrumb.identifiers)
	end
end

-- Lines 147-152
function RaidGUIControlListItemMenu:unselect()
	self._selected = false

	self:highlight_off()
end

-- Lines 154-156
function RaidGUIControlListItemMenu:data()
	return self._data
end

-- Lines 158-170
function RaidGUIControlListItemMenu:highlight_on()
	if self._params.no_highlight then
		return
	end

	if self._params.on_mouse_over_sound_event then
		managers.menu_component:post_event(self._params.on_mouse_over_sound_event)
	end

	self._item_background:show()
end

-- Lines 172-178
function RaidGUIControlListItemMenu:highlight_off()
	if not self._selected and not self._active and self._item_background and alive(self._item_background) and self._item_highlight_marker then
		self._item_background:hide()
	end
end

-- Lines 180-185
function RaidGUIControlListItemMenu:enable(active_texture_color)
	self._enabled = true

	self._item_label:set_color(active_texture_color)
	self:set_param_value("no_highlight", false)
	self:set_param_value("no_click", false)
end

-- Lines 187-192
function RaidGUIControlListItemMenu:disable(inactive_texture_color)
	self._enabled = false

	self._item_label:set_color(inactive_texture_color)
	self:set_param_value("no_highlight", true)
	self:set_param_value("no_click", true)
end

-- Lines 194-196
function RaidGUIControlListItemMenu:enabled()
	return self._enabled
end

-- Lines 201-206
function RaidGUIControlListItemMenu:activate_on()
	self._item_background:show()
	self._item_highlight_marker:show()
	self._item_label:set_color(tweak_data.gui.colors.raid_red)
end

-- Lines 208-217
function RaidGUIControlListItemMenu:activate_off()
	self:highlight_off()

	if self._item_highlight_marker and alive(self._item_highlight_marker) then
		self._item_highlight_marker:hide()
	end

	if self._item_label and alive(self._item_label._object) then
		self._item_label:set_color(tweak_data.gui.colors.raid_white)
	end
end

-- Lines 219-224
function RaidGUIControlListItemMenu:activate()
	self._active = true

	self:activate_on()
	self:highlight_on()
end

-- Lines 226-230
function RaidGUIControlListItemMenu:deactivate()
	self._active = false

	self:activate_off()
end

-- Lines 232-234
function RaidGUIControlListItemMenu:activated()
	return self._active
end
