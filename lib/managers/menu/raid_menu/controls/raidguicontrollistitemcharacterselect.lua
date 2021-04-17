RaidGUIControlListItemCharacterSelect = RaidGUIControlListItemCharacterSelect or class(RaidGUIControl)
RaidGUIControlListItemCharacterSelect.SLOTS = {
	{
		x = 417,
		y = 0
	},
	{
		x = 534,
		y = 0
	}
}

-- Lines 6-35
function RaidGUIControlListItemCharacterSelect:init(parent, params, item_data)
	RaidGUIControlListItemCharacterSelect.super.init(self, parent, params, item_data)

	self._character_slot = nil
	self._item_data = item_data
	self._on_click_callback = self._params.on_click_callback
	self._on_item_selected_callback = params.on_item_selected_callback
	self._on_double_click_callback = params.on_double_click_callback
	self.special_action_callback = self._params.special_action_callback

	if item_data and item_data.value then
		self._character_slot = item_data.value
		local slot_data = Global.savefile_manager.meta_data_list[item_data.value]

		if slot_data and slot_data.cache then
			self._item_data.cache = slot_data.cache
		end
	end

	self._object = self._panel:panel({
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	})
	self._special_action_buttons = {}

	self:_layout()
	self:_load_data()
end

-- Lines 37-51
function RaidGUIControlListItemCharacterSelect:_layout()
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
	self._profile_name_label = self._object:label({
		text = "",
		h = 28,
		y = 21,
		w = 272,
		x = 128,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.medium,
		color = tweak_data.gui.colors.raid_white
	})
	self._character_name_label = self._object:label({
		text = "",
		h = 22,
		y = 53,
		w = 272,
		x = 128,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_grey
	})
	self._nationality_flag = self._object:image({
		h = 64,
		y = 16,
		w = 95,
		x = 16,
		texture = tweak_data.gui.icons.ico_flag_empty.texture,
		texture_rect = tweak_data.gui.icons.ico_flag_empty.texture_rect
	})
end

-- Lines 53-92
function RaidGUIControlListItemCharacterSelect:_load_data()
	local profile_name = self:translate("character_selection_empty_slot", true)
	local character_nationality = nil
	local character_name = "---"
	local character_flag = nil

	if self._item_data.cache then
		profile_name = self._item_data.cache.PlayerManager.character_profile_name
		character_nationality = self._item_data.cache.PlayerManager.character_profile_nation
		character_name = self:translate("menu_" .. character_nationality, true)
		character_flag = tweak_data.criminals.character_nation_name[character_nationality].flag_name
		self._customize_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			h = 94,
			y = 0,
			w = 116,
			x = 534,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._customize_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CUSTOMIZE)
		table.insert(self._special_action_buttons, self._customize_button)

		self._delete_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			h = 94,
			y = 0,
			w = 116,
			x = 417,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._delete_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_DELETE)
		table.insert(self._special_action_buttons, self._delete_button)
	else
		self._create_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			h = 94,
			y = 0,
			w = 116,
			x = 417,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._create_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CREATE)
		table.insert(self._special_action_buttons, self._create_button)
	end

	self._profile_name_label:set_text(utf8.to_upper(profile_name))
	self._character_name_label:set_text(utf8.to_upper(character_name))

	if character_flag then
		self._nationality_flag:set_image(tweak_data.gui.icons[character_flag].texture)
		self._nationality_flag:set_texture_rect(tweak_data.gui.icons[character_flag].texture_rect)
	end

	if character_nationality then
		self:_layout_breadcrumb(character_nationality)
	end
end

-- Lines 94-102
function RaidGUIControlListItemCharacterSelect:_layout_breadcrumb(character_nationality)
	local breadcrumb_params = {
		category = BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION,
		identifiers = {
			character_nationality
		}
	}
	self._breadcrumb = self._object:breadcrumb(breadcrumb_params)

	self._breadcrumb:set_right(self._background:x() + self._background:w())
	self._breadcrumb:set_center_y(self._object:h() / 2)
end

-- Lines 106-108
function RaidGUIControlListItemCharacterSelect:data()
	return self._item_data
end

-- Lines 110-114
function RaidGUIControlListItemCharacterSelect:inside(x, y)
	return self._object and self._object:inside(x, y) and self._object:tree_visible() and self._background:inside(x, y) or self._create_button and self._create_button:inside(x, y) or self._delete_button and self._delete_button:inside(x, y) or self._customize_button and self._customize_button:inside(x, y)
end

-- Lines 116-130
function RaidGUIControlListItemCharacterSelect:highlight_on()
	self._background:show()
end

-- Lines 132-153
function RaidGUIControlListItemCharacterSelect:highlight_off()
	if not self._selected and not self._active and self._background and self._red_selected_line and self._background and alive(self._background) then
		self._background:set_visible(false)
	end
end

-- Lines 155-161
function RaidGUIControlListItemCharacterSelect:activate_on()
	self._background:show()
	self._red_selected_line:show()
	self._profile_name_label:set_color(tweak_data.gui.colors.raid_red)
	self._character_name_label:set_color(tweak_data.gui.colors.raid_red)
end

-- Lines 163-175
function RaidGUIControlListItemCharacterSelect:activate_off()
	self:highlight_off()

	if self._red_selected_line and alive(self._red_selected_line) then
		self._red_selected_line:hide()
	end

	if self._profile_name_label and alive(self._profile_name_label._object) then
		self._profile_name_label:set_color(tweak_data.gui.colors.raid_white)
	end

	if self._character_name_label and alive(self._character_name_label._object) then
		self._character_name_label:set_color(tweak_data.gui.colors.raid_grey)
	end
end

-- Lines 177-193
function RaidGUIControlListItemCharacterSelect:mouse_released(o, button, x, y)
	if self._special_action_buttons then
		for _, special_button in ipairs(self._special_action_buttons) do
			if special_button:inside(x, y) then
				special_button:mouse_released(o, button, x, y)
			end
		end
	end

	if self:inside(x, y) then
		return self:on_mouse_released(button)
	end
end

-- Lines 195-205
function RaidGUIControlListItemCharacterSelect:on_mouse_released(button)
	if self._on_click_callback then
		self._on_click_callback(nil, self, self._character_slot, true)

		return true
	end
end

-- Lines 207-218
function RaidGUIControlListItemCharacterSelect:confirm_pressed()
	if not self._item_data or not self._item_data.cache then
		return self._create_button:on_mouse_released()
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._character_slot)

		return true
	end
end

-- Lines 220-230
function RaidGUIControlListItemCharacterSelect:mouse_double_click(o, button, x, y)
	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._character_slot)

		return true
	end
end

-- Lines 232-264
function RaidGUIControlListItemCharacterSelect:select(dont_trigger_selected_callback)
	self._selected = true

	self:highlight_on()

	if self._on_item_selected_callback and not dont_trigger_selected_callback then
		self:_on_item_selected_callback(self._character_slot)
	end

	if self._customize_button and self._active then
		self._customize_button:set_visible(true)
	end

	if self._delete_button then
		self._delete_button:set_visible(true)
	end

	if self._create_button then
		self._create_button:set_visible(true)
	end

	if self._active then
		self:_set_button_slot(self._customize_button, 1)
		self:_set_button_slot(self._delete_button, 2)
	elseif not self._item_data.cache then
		self:_set_button_slot(self._create_button, 1)
	else
		self:_set_button_slot(self._customize_button, 2)
		self:_set_button_slot(self._delete_button, 1)
	end
end

-- Lines 266-282
function RaidGUIControlListItemCharacterSelect:unselect()
	self._selected = false

	self:highlight_off()

	if self._delete_button and alive(self._delete_button._object._engine_panel) then
		self._delete_button:set_visible(false)
	end

	if self._create_button and alive(self._create_button._object._engine_panel) then
		self._create_button:set_visible(false)
	end

	if self._customize_button and alive(self._customize_button._object._engine_panel) then
		self._customize_button:set_visible(false)
	end
end

-- Lines 284-286
function RaidGUIControlListItemCharacterSelect:selected()
	return self._selected
end

-- Lines 288-293
function RaidGUIControlListItemCharacterSelect:activate()
	self._active = true

	self:activate_on()
	self:highlight_on()
end

-- Lines 295-299
function RaidGUIControlListItemCharacterSelect:deactivate()
	self._active = false

	self:activate_off()
end

-- Lines 301-303
function RaidGUIControlListItemCharacterSelect:activated()
	return self._active
end

-- Lines 305-307
function RaidGUIControlListItemCharacterSelect:empty()
	return not self._item_data or not self._item_data.cache
end

-- Lines 309-312
function RaidGUIControlListItemCharacterSelect:_set_button_slot(button_ref, slot_index)
	button_ref:set_x(RaidGUIControlListItemCharacterSelect.SLOTS[slot_index].x)
	button_ref:set_y(RaidGUIControlListItemCharacterSelect.SLOTS[slot_index].y)
end
