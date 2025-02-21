RaidGUIControlListItemCharacterCreateClass = RaidGUIControlListItemCharacterCreateClass or class(RaidGUIControl)

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

function RaidGUIControlListItemCharacterCreateClass:_layout()
	local class_icon_data = tweak_data.gui.icons["ico_class_" .. self._class_name] or tweak_data.gui.icons.ico_flag_empty
	self._background = self._object:rect({
		y = 0,
		x = 0,
		visible = false,
		w = self._params.w,
		h = self._params.h,
		color = tweak_data.gui.colors.raid_list_background
	})
	self._red_selected_line = self._object:rect({
		w = 2,
		y = 0,
		x = 0,
		visible = false,
		h = self._params.h,
		color = tweak_data.gui.colors.raid_red
	})
	self._class_name_label = self._object:label({
		align = "left",
		h = 28,
		w = 174,
		y = 34,
		x = 96,
		vertical = "center",
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

function RaidGUIControlListItemCharacterCreateClass:data()
	return self._data
end

function RaidGUIControlListItemCharacterCreateClass:highlight_on()
	self._background:show()
end

function RaidGUIControlListItemCharacterCreateClass:highlight_off()
	if not self._selected and not self._active and self._background and self._red_selected_line then
		self._background:hide()
		self._red_selected_line:hide()
	end
end

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

function RaidGUIControlListItemCharacterCreateClass:activate_off()
	self:highlight_off()

	if self._class_name_label and alive(self._class_name_label._object) then
		self._class_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
	end

	if self._class_icon and alive(self._class_icon._object) then
		self._class_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
	end
end

function RaidGUIControlListItemCharacterCreateClass:mouse_released(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_released(button)
	end
end

function RaidGUIControlListItemCharacterCreateClass:on_mouse_released(button)
	if self.on_click_callback then
		self.on_click_callback(button, self, self._data)

		return true
	end
end

function RaidGUIControlListItemCharacterCreateClass:select()
	self._selected = true

	self._class_name_label:set_color(tweak_data.gui.colors.raid_red)
	self._class_icon:set_color(tweak_data.gui.colors.raid_red)

	if self._on_item_selected_callback then
		self:_on_item_selected_callback(self._data)
	end
end

function RaidGUIControlListItemCharacterCreateClass:unselect()
	self._selected = false

	self._class_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
	self._class_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
end

function RaidGUIControlListItemCharacterCreateClass:selected()
	return self._selected
end

function RaidGUIControlListItemCharacterCreateClass:activate()
	self._active = true

	self:activate_on()
	self:highlight_on()
end

function RaidGUIControlListItemCharacterCreateClass:deactivate()
	self._active = false

	self:activate_off()
end

function RaidGUIControlListItemCharacterCreateClass:activated()
	return self._active
end

function RaidGUIControlListItemCharacterCreateClass:confirm_pressed()
	if not self._selected then
		return false
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

function RaidGUIControlListItemCharacterCreateClass:mouse_double_click(o, button, x, y)
	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end
