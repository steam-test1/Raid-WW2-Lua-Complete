RaidGUIControlListItemCharacterSelectButton = RaidGUIControlListItemCharacterSelectButton or class(RaidGUIControl)
RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CUSTOMIZE = "button_customize"
RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_DELETE = "button_delete"
RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CREATE = "button_create"

-- Lines 8-22
function RaidGUIControlListItemCharacterSelectButton:init(parent, params)
	RaidGUIControlListItemCharacterSelectButton.super.init(self, parent, params)

	self._object = self._panel:panel({
		visible = false,
		x = self._params.x,
		y = self._params.y,
		w = self._params.w,
		h = self._params.h
	})
	self._special_action_callback = self._params.special_action_callback
	self._background = self._object:image({
		h = 94,
		y = 0,
		w = 116,
		x = 0,
		texture = tweak_data.gui.icons.btn_list_rect.texture,
		texture_rect = tweak_data.gui.icons.btn_list_rect.texture_rect,
		layer = self._object:layer()
	})
	self._icon = self._object:image({
		h = 32,
		y = 16,
		w = 32,
		x = 43,
		texture = tweak_data.gui.icons.list_btn_ico_plus.texture,
		texture_rect = tweak_data.gui.icons.list_btn_ico_plus.texture_rect,
		layer = self._background:layer() + 1
	})
	self._label = self._object:label({
		vertical = "center",
		h = 25,
		w = 116,
		align = "center",
		text = "",
		y = 60,
		x = 0,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.keybinding,
		color = tweak_data.gui.colors.raid_black
	})
end

-- Lines 24-48
function RaidGUIControlListItemCharacterSelectButton:set_button(button_type)
	if button_type == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CUSTOMIZE then
		self._icon:set_image(tweak_data.gui.icons.list_btn_ico_customize.texture)
		self._icon:set_texture_rect(tweak_data.gui.icons.list_btn_ico_customize.texture_rect)
		self._label:set_text(self:translate("character_selection_button_customize", true))

		self._button_type = RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CUSTOMIZE
	elseif button_type == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_DELETE then
		self._icon:set_image(tweak_data.gui.icons.list_btn_ico_x.texture)
		self._icon:set_texture_rect(tweak_data.gui.icons.list_btn_ico_x.texture_rect)
		self._label:set_text(self:translate("character_selection_button_delete", true))

		self._button_type = RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_DELETE
	elseif button_type == RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CREATE then
		self._icon:set_image(tweak_data.gui.icons.list_btn_ico_plus.texture)
		self._icon:set_texture_rect(tweak_data.gui.icons.list_btn_ico_plus.texture_rect)
		self._label:set_text(self:translate("character_selection_button_create", true))

		self._button_type = RaidGUIControlListItemCharacterSelectButton.BUTTON_TYPE_CREATE
	end
end

-- Lines 50-53
function RaidGUIControlListItemCharacterSelectButton:highlight_on()
	self._background:set_image(tweak_data.gui.icons.btn_list_rect_hover.texture)
	self._background:set_texture_rect(tweak_data.gui.icons.btn_list_rect_hover.texture_rect)
end

-- Lines 55-58
function RaidGUIControlListItemCharacterSelectButton:highlight_off()
	self._background:set_image(tweak_data.gui.icons.btn_list_rect.texture)
	self._background:set_texture_rect(tweak_data.gui.icons.btn_list_rect.texture_rect)
end

-- Lines 60-63
function RaidGUIControlListItemCharacterSelectButton:mouse_released(o, button, x, y)
	return self:on_mouse_released()
end

-- Lines 65-72
function RaidGUIControlListItemCharacterSelectButton:on_mouse_released()
	if self._special_action_callback then
		self._special_action_callback(self._params.slot_index, self._button_type)

		return true
	end
end
