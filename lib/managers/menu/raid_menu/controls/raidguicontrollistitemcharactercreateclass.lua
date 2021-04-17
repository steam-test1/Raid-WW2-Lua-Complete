RaidGUIControlListItemCharacterCreateClass = RaidGUIControlListItemCharacterCreateClass or class(RaidGUIControl)

-- Lines 4-18
function RaidGUIControlListItemCharacterCreateClass:init(parent, params, item_data)
	RaidGUIControlListItemCharacterCreateClass.super.init(self, parent, params, item_data)

	self._class_name = item_data.value
	self._data = item_data
	self.on_click_callback = self._params.on_click_callback
	self._on_double_click_callback = self._params.on_double_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._object = self._panel:panel({
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	})

	self:_layout()
end

-- Lines 20-36
function RaidGUIControlListItemCharacterCreateClass:_layout()
	local class_icon_data = tweak_data.gui.icons["ico_class_" .. self._class_name] or tweak_data.gui.icons.ico_flag_empty
	self._background = self._object:rect({
		visible = false,
		y = 0,
		x = 0,
		w = self._params.w,
		h = self._params.h,
		color = tweak_data.gui.colors.raid_list_background
	})
	self._red_selected_line = self._object:rect({
		visible = false,
		y = 0,
		w = 2,
		x = 0,
		h = self._params.h,
		color = tweak_data.gui.colors.raid_red
	})
	self._class_name_label = self._object:label({
		vertical = "center",
		h = 28,
		w = 174,
		align = "left",
		y = 34,
		x = 96,
		text = self:translate(tweak_data.skilltree.classes[self._class_name].name_id, true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		color = tweak_data.gui.colors.raid_dirty_white
	})

	self._class_name_label:set_w(self._object:w() - self._class_name_label:x())

	self._class_icon = self._object:image({
		y = 20,
		x = 32,
		w = class_icon_data.texture_rect[3],
		h = class_icon_data.texture_rect[4],
		texture = class_icon_data.texture,
		texture_rect = class_icon_data.texture_rect
	})

	self._class_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
	self._class_icon:set_center_x(48)
	self._class_icon:set_center_y(self._object:h() / 2)
end

-- Lines 38-40
function RaidGUIControlListItemCharacterCreateClass:data()
	return self._data
end

-- Lines 42-45
function RaidGUIControlListItemCharacterCreateClass:highlight_on()
	self._background:show()
end

-- Lines 47-53
function RaidGUIControlListItemCharacterCreateClass:highlight_off()
	if not self._selected and not self._active and self._background and self._red_selected_line then
		self._background:hide()
		self._red_selected_line:hide()
	end
end

-- Lines 55-66
function RaidGUIControlListItemCharacterCreateClass:activate_on()
	self._background:show()
	self._red_selected_line:show()

	if self._selected then
		self._class_name_label:set_color(tweak_data.gui.colors.raid_red)
		self._class_icon:set_color(tweak_data.gui.colors.raid_red)
	else
		self._class_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
		self._class_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
	end
end

-- Lines 68-77
function RaidGUIControlListItemCharacterCreateClass:activate_off()
	self:highlight_off()

	if self._class_name_label and alive(self._class_name_label._object) then
		self._class_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
	end

	if self._class_icon and alive(self._class_icon._object) then
		self._class_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
	end
end

-- Lines 79-86
function RaidGUIControlListItemCharacterCreateClass:mouse_released(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_released(button)
	end
end

-- Lines 88-95
function RaidGUIControlListItemCharacterCreateClass:on_mouse_released(button)
	if self.on_click_callback then
		self.on_click_callback(button, self, self._data)

		return true
	end
end

-- Lines 97-107
function RaidGUIControlListItemCharacterCreateClass:select()
	self._selected = true

	self._class_name_label:set_color(tweak_data.gui.colors.raid_red)
	self._class_icon:set_color(tweak_data.gui.colors.raid_red)

	if self._on_item_selected_callback then
		self:_on_item_selected_callback(self._data)
	end
end

-- Lines 109-115
function RaidGUIControlListItemCharacterCreateClass:unselect()
	self._selected = false

	self._class_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
	self._class_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
end

-- Lines 117-119
function RaidGUIControlListItemCharacterCreateClass:selected()
	return self._selected
end

-- Lines 121-127
function RaidGUIControlListItemCharacterCreateClass:activate()
	self._active = true

	self:activate_on()
	self:highlight_on()
end

-- Lines 129-134
function RaidGUIControlListItemCharacterCreateClass:deactivate()
	self._active = false

	self:activate_off()
end

-- Lines 136-138
function RaidGUIControlListItemCharacterCreateClass:activated()
	return self._active
end

-- Lines 140-149
function RaidGUIControlListItemCharacterCreateClass:confirm_pressed()
	if not self._selected then
		return false
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

-- Lines 151-156
function RaidGUIControlListItemCharacterCreateClass:mouse_double_click(o, button, x, y)
	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end
