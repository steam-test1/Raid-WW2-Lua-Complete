RaidGUIControlListItemCharacterCreateNation = RaidGUIControlListItemCharacterCreateNation or class(RaidGUIControl)

-- Lines 4-18
function RaidGUIControlListItemCharacterCreateNation:init(parent, params, item_data)
	RaidGUIControlListItemCharacterCreateNation.super.init(self, parent, params, item_data)

	self._nation_name = item_data.value
	self._data = item_data
	self._character_name = item_data.text
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
function RaidGUIControlListItemCharacterCreateNation:_layout()
	self._background = self._object:rect({
		visible = false,
		y = 0,
		w = 416,
		x = 0,
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
	local nationality_text = self:translate("character_profile_creation_" .. self._nation_name, true)
	self._nation_name_label = self._object:label({
		h = 32,
		y = 32,
		w = 272,
		x = 96,
		text = nationality_text,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_32,
		color = tweak_data.gui.colors.raid_dirty_white
	})

	self._nation_name_label:set_w(self._object:w() - self._nation_name_label:x())

	local nation_icon_data = tweak_data.gui.icons["character_creation_nationality_" .. self._nation_name] or tweak_data.gui.icons.ico_flag_empty
	local tex_rect = nation_icon_data.texture_rect
	self._nationality_icon = self._object:image({
		y = 24,
		x = 22,
		w = tex_rect[3],
		h = tex_rect[4],
		texture = nation_icon_data.texture,
		texture_rect = tex_rect
	})

	self._nationality_icon:set_center_x(48)
	self._nationality_icon:set_center_y(self._object:h() / 2)
end

-- Lines 38-40
function RaidGUIControlListItemCharacterCreateNation:data()
	return self._data
end

-- Lines 42-45
function RaidGUIControlListItemCharacterCreateNation:highlight_on()
	self._background:show()
end

-- Lines 47-53
function RaidGUIControlListItemCharacterCreateNation:highlight_off()
	if not self._selected and not self._active and self._background and self._red_selected_line then
		self._background:hide()
		self._red_selected_line:hide()
	end
end

-- Lines 55-65
function RaidGUIControlListItemCharacterCreateNation:activate_on()
	self._background:show()
	self._red_selected_line:show()

	if self._selected then
		self._nation_name_label:set_color(tweak_data.gui.colors.raid_red)
		self._nationality_icon:set_color(tweak_data.gui.colors.raid_red)
	else
		self._nation_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
		self._nationality_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
	end
end

-- Lines 67-74
function RaidGUIControlListItemCharacterCreateNation:activate_off()
	self:highlight_off()

	if self._nation_name_label and alive(self._nation_name_label._object) then
		self._nation_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
		self._nationality_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
	end
end

-- Lines 76-83
function RaidGUIControlListItemCharacterCreateNation:mouse_released(o, button, x, y)
	if self:inside(x, y) then
		return self:on_mouse_released(button)
	end
end

-- Lines 85-92
function RaidGUIControlListItemCharacterCreateNation:on_mouse_released(button)
	if self.on_click_callback then
		self.on_click_callback(button, self, self._data)

		return true
	end
end

-- Lines 94-103
function RaidGUIControlListItemCharacterCreateNation:select()
	self._selected = true

	self._nation_name_label:set_color(tweak_data.gui.colors.raid_red)
	self._nationality_icon:set_color(tweak_data.gui.colors.raid_red)

	if self._on_item_selected_callback then
		self:_on_item_selected_callback(self._data)
	end
end

-- Lines 105-110
function RaidGUIControlListItemCharacterCreateNation:unselect()
	self._selected = false

	self._nation_name_label:set_color(tweak_data.gui.colors.raid_dirty_white)
	self._nationality_icon:set_color(tweak_data.gui.colors.raid_dirty_white)
end

-- Lines 112-114
function RaidGUIControlListItemCharacterCreateNation:selected()
	return self._selected
end

-- Lines 116-121
function RaidGUIControlListItemCharacterCreateNation:activate()
	self._active = true

	self:activate_on()
	self:highlight_on()
end

-- Lines 123-127
function RaidGUIControlListItemCharacterCreateNation:deactivate()
	self._active = false

	self:activate_off()
end

-- Lines 129-131
function RaidGUIControlListItemCharacterCreateNation:activated()
	return self._active
end

-- Lines 133-142
function RaidGUIControlListItemCharacterCreateNation:confirm_pressed()
	if not self._selected then
		return false
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end

-- Lines 144-149
function RaidGUIControlListItemCharacterCreateNation:mouse_double_click(o, button, x, y)
	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._data)

		return true
	end
end
