RaidGUIControlListItemCharacterSelect = RaidGUIControlListItemCharacterSelect or class(RaidGUIControl)
RaidGUIControlListItemCharacterSelect.SLOTS = {
	{
		x = 416,
		y = 0
	},
	{
		y = 0,
		x = 416 + CharacterSelectionGui.BUTTON_W
	},
	{
		x = 416,
		y = CharacterSelectionGui.BUTTON_H
	},
	{
		x = 416 + CharacterSelectionGui.BUTTON_W,
		y = CharacterSelectionGui.BUTTON_H
	}
}

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

function RaidGUIControlListItemCharacterSelect:_load_data()
	local profile_name = self:translate("character_selection_empty_slot", true)
	local character_nationality
	local character_name = "---"
	local character_flag

	if self._item_data.cache then
		profile_name = self._item_data.cache.PlayerManager.character_profile_name
		character_nationality = self._item_data.cache.PlayerManager.character_profile_nation
		character_name = self:translate("menu_" .. character_nationality, true)
		character_flag = tweak_data.criminals.character_nation_name[character_nationality].flag_name
		self._customize_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			name = "customize_button",
			y = 0,
			x = 420,
			w = CharacterSelectionGui.BUTTON_W,
			h = CharacterSelectionGui.BUTTON_H,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._customize_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CUSTOMIZE)
		table.insert(self._special_action_buttons, self._customize_button)

		self._rename_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			name = "rename_button",
			y = 47,
			x = 420,
			w = CharacterSelectionGui.BUTTON_W,
			h = CharacterSelectionGui.BUTTON_H,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._rename_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_RENAME)
		table.insert(self._special_action_buttons, self._rename_button)

		self._nationality_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			name = "nationality_button",
			y = 47,
			x = 420,
			w = CharacterSelectionGui.BUTTON_W,
			h = CharacterSelectionGui.BUTTON_H,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._nationality_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_NATION)
		table.insert(self._special_action_buttons, self._nationality_button)

		self._delete_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			name = "delete_button",
			y = 47,
			x = 420,
			w = CharacterSelectionGui.BUTTON_W,
			h = CharacterSelectionGui.BUTTON_H,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._delete_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_DELETE)
		table.insert(self._special_action_buttons, self._delete_button)
	else
		self._create_button = self._object:create_custom_control(RaidGUIControlListItemCharacterSelectButton, {
			visible = false,
			y = 0,
			x = 417,
			w = CharacterSelectionGui.BUTTON_W * 2,
			h = CharacterSelectionGui.BUTTON_H * 2,
			special_action_callback = self.special_action_callback,
			slot_index = self._character_slot
		})

		self._create_button:set_button(RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CREATE)
		table.insert(self._special_action_buttons, self._create_button)
	end

	self._profile_name_label:set_text(utf8.to_upper(profile_name))
	self._character_name_label:set_text(utf8.to_upper(character_name))

	if character_nationality then
		self:update_flag(character_nationality)
		self:_layout_breadcrumb(character_nationality)
	end
end

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

function RaidGUIControlListItemCharacterSelect:data()
	return self._item_data
end

function RaidGUIControlListItemCharacterSelect:inside(x, y)
	local is_object_ready = self._object and self._object:inside(x, y) and self._object:tree_visible() and self._background:inside(x, y)
	local is_inside_create = self._create_button and self._create_button:inside(x, y)
	local is_inside_delete = self._delete_button and self._delete_button:inside(x, y)
	local is_inside_customize = self._customize_button and self._customize_button:inside(x, y)
	local is_inside_rename = self._rename_button and self._rename_button:inside(x, y)
	local is_inside_nationality = self._nationality_button and self._nationality_button:inside(x, y)

	return is_object_ready or is_inside_create or is_inside_customize or is_inside_delete or is_inside_rename or is_inside_nationality
end

function RaidGUIControlListItemCharacterSelect:highlight_on()
	self._background:show()
end

function RaidGUIControlListItemCharacterSelect:highlight_off()
	if not self._selected and not self._active and self._background and self._red_selected_line and self._background and alive(self._background) then
		self._background:set_visible(false)
	end
end

function RaidGUIControlListItemCharacterSelect:activate_on()
	self._background:show()
	self._red_selected_line:show()
	self._profile_name_label:set_color(tweak_data.gui.colors.raid_red)
	self._character_name_label:set_color(tweak_data.gui.colors.raid_red)
end

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

function RaidGUIControlListItemCharacterSelect:update_flag(character_nationality)
	local character_flag = tweak_data.criminals.character_nation_name[character_nationality].flag_name

	if character_flag then
		self._nationality_flag:set_image(tweak_data.gui.icons[character_flag].texture)
		self._nationality_flag:set_texture_rect(tweak_data.gui.icons[character_flag].texture_rect)
	end

	if self._character_name_label and alive(self._character_name_label._object) then
		local character_name = self:translate("menu_" .. character_nationality, true)

		self._character_name_label:set_text(utf8.to_upper(character_name))
	end
end

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

function RaidGUIControlListItemCharacterSelect:on_mouse_released(button)
	if self._on_click_callback then
		self._on_click_callback(nil, self, self._character_slot, true)

		return true
	end
end

function RaidGUIControlListItemCharacterSelect:confirm_pressed()
	if not self._item_data or not self._item_data.cache then
		return self._create_button:on_mouse_released()
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._character_slot)

		return true
	end
end

function RaidGUIControlListItemCharacterSelect:mouse_double_click(o, button, x, y)
	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._character_slot)

		return true
	end
end

function RaidGUIControlListItemCharacterSelect:select(dont_trigger_selected_callback)
	self._selected = true

	self:highlight_on()

	if self._on_item_selected_callback and not dont_trigger_selected_callback then
		self._on_item_selected_callback(self, self._character_slot)
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

	if self._nationality_button and self._active then
		self._nationality_button:set_visible(true)
	end

	if self._rename_button and self._active then
		self._rename_button:set_visible(true)
	end

	if self._active then
		self:_set_button_slot(self._customize_button, 1)
		self:_set_button_slot(self._delete_button, 2)
		self:_set_button_slot(self._nationality_button, 3)
		self:_set_button_slot(self._rename_button, 4)
	elseif not self._item_data.cache then
		self:_set_button_slot(self._create_button, 1)
	else
		self:_set_button_slot(self._delete_button, 1)
		self:_set_button_slot(self._customize_button, 2)
		self:_set_button_slot(self._nationality_button, 3)
		self:_set_button_slot(self._rename_button, 4)
	end
end

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

	if self._nationality_button and alive(self._nationality_button._object._engine_panel) then
		self._nationality_button:set_visible(false)
	end

	if self._rename_button and alive(self._rename_button._object._engine_panel) then
		self._rename_button:set_visible(false)
	end
end

function RaidGUIControlListItemCharacterSelect:selected()
	return self._selected
end

function RaidGUIControlListItemCharacterSelect:activate()
	self._active = true

	self:activate_on()
	self:highlight_on()
end

function RaidGUIControlListItemCharacterSelect:deactivate()
	self._active = false

	self:activate_off()
end

function RaidGUIControlListItemCharacterSelect:activated()
	return self._active
end

function RaidGUIControlListItemCharacterSelect:empty()
	return not self._item_data or not self._item_data.cache
end

function RaidGUIControlListItemCharacterSelect:_set_button_slot(button_ref, slot_index)
	if button_ref then
		button_ref:set_x(RaidGUIControlListItemCharacterSelect.SLOTS[slot_index].x)
		button_ref:set_y(RaidGUIControlListItemCharacterSelect.SLOTS[slot_index].y)
	end
end
