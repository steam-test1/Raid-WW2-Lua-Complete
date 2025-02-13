RaidGUIControlListItemWeapons = RaidGUIControlListItemWeapons or class(RaidGUIControlListItem)
RaidGUIControlListItemWeapons.TEXT_X_OFFSET = 164
RaidGUIControlListItemWeapons.LABEL_FONT = tweak_data.gui.fonts.lato
RaidGUIControlListItemWeapons.LABEL_FONT_SIZE = tweak_data.gui.font_sizes.size_24

function RaidGUIControlListItemWeapons:init(parent, params, data)
	RaidGUIControlListItemWeapons.super.init(self, parent, params, data)
	Application:debug("[RaidGUIControlListItemWeapons] ----- INIT ----")

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

	if self._data and self._data.value and self._data.value.weapon_id and tweak_data.weapon[self._data.value.weapon_id] and tweak_data.weapon[self._data.value.weapon_id] and tweak_data.weapon[self._data.value.weapon_id].hud and tweak_data.weapon[self._data.value.weapon_id].hud.icon then
		Application:debug("[RaidGUIControlListItemWeapons] is weapon", self._data.value.weapon_id)

		local ico_weapon_id = tweak_data.weapon[self._data.value.weapon_id].hud.icon
		local ico_weapon = tweak_data.gui.icons[ico_weapon_id]

		Application:debug("[RaidGUIControlListItemWeapons] wep icon tex", ico_weapon.texture)

		local text_rect = ico_weapon.texture_rect
		local weapon_icon_object = self._object:image({
			name = "weapon_icon",
			x = RaidGUIControlListItemWeapons.TEXT_X_OFFSET / 2 - text_rect[3] / 2,
			y = self._object:h() / 2 - text_rect[4] / 2,
			w = text_rect[3],
			h = text_rect[4],
			texture = ico_weapon.texture,
			texture_rect = text_rect,
			color = self._data.value.unlocked and tweak_data.gui.colors.raid_white or tweak_data.gui.colors.raid_dark_grey
		})
		local lock_icon = self._object:child("locker_icon")

		if lock_icon then
			lock_icon:set_center(weapon_icon_object:center())
			lock_icon:set_layer(weapon_icon_object:layer() + 1)
		end

		Application:debug("[RaidGUIControlListItemWeapons] moved text X", self._item_label)
		self._item_label:set_x(RaidGUIControlListItemWeapons.TEXT_X_OFFSET)
	end

	if self._data and self._data.value and not self._data.value.unlocked then
		if params and params.use_unlocked then
			self._on_click_callback = nil
			self._on_double_click_callback = nil

			self:disable(tweak_data.gui.colors.raid_dark_grey)
		else
			self._item_label:set_color(tweak_data.gui.colors.raid_dark_grey)
		end
	end
end

function RaidGUIControlListItemWeapons:on_mouse_released(button)
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

function RaidGUIControlListItemWeapons:mouse_double_click(o, button, x, y)
	if self._params.no_click then
		return
	end

	if self._on_double_click_callback then
		self._on_double_click_callback(nil, self, self._character_slot)

		return true
	end
end

function RaidGUIControlListItemWeapons:activate()
	if self._enabled then
		self._active = true

		self:activate_on()
		self:highlight_on()
	end
end

function RaidGUIControlListItemWeapons:deactivate()
	if self._enabled then
		self._active = false

		self:activate_off()
	end
end

function RaidGUIControlListItemWeapons:activated()
	return self._active
end

function RaidGUIControlListItemWeapons:activate_on()
	self._item_background:show()
	self._item_highlight_marker:show()
	self._item_label:set_color(tweak_data.gui.colors.raid_red)

	if self._object:child("weapon_icon") then
		self._object:child("weapon_icon"):set_color(tweak_data.gui.colors.raid_red)
	end
end

function RaidGUIControlListItemWeapons:activate_off()
	self:highlight_off()

	if self._item_highlight_marker and alive(self._item_highlight_marker) then
		self._item_highlight_marker:hide()
	end

	if self._item_label and alive(self._item_label._object) then
		self._item_label:set_color(tweak_data.gui.colors.raid_white)
	end

	if self._object:child("weapon_icon") then
		self._object:child("weapon_icon"):set_color(tweak_data.gui.colors.raid_white)
	end
end

function RaidGUIControlListItemWeapons:enable(active_texture_color)
	self._enabled = true

	self._item_label:set_color(active_texture_color)
	self:set_param_value("no_highlight", false)
	self:set_param_value("no_click", false)
end

function RaidGUIControlListItemWeapons:disable(inactive_texture_color)
	self._enabled = false

	self._item_label:set_color(inactive_texture_color)
	self:set_param_value("no_highlight", true)
	self:set_param_value("no_click", true)
end

function RaidGUIControlListItemWeapons:enabled()
	return self._enabled
end
