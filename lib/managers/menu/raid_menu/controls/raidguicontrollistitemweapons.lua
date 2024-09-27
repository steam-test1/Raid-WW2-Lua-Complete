RaidGUIControlListItemWeapons = RaidGUIControlListItemWeapons or class(RaidGUIControlListItemMenu)
RaidGUIControlListItemWeapons.TEXT_X_OFFSET = 164

function RaidGUIControlListItemWeapons:_get_font_desc()
	return tweak_data.gui.fonts.lato, tweak_data.gui.font_sizes.size_24
end

function RaidGUIControlListItemWeapons:init(parent, params, data)
	RaidGUIControlListItemWeapons.super.init(self, parent, params, data)
	Application:debug("[RaidGUIControlListItemWeapons] ----- INIT ----")

	if self._data and self._data.value and self._data.value.weapon_id and tweak_data.weapon[self._data.value.weapon_id] and tweak_data.weapon[self._data.value.weapon_id] and tweak_data.weapon[self._data.value.weapon_id].hud and tweak_data.weapon[self._data.value.weapon_id].hud.icon then
		Application:debug("[RaidGUIControlListItemWeapons] is weapon", self._data.value.weapon_id)

		local ico_weapon_id = tweak_data.weapon[self._data.value.weapon_id].hud.icon
		local ico_weapon = tweak_data.gui.icons[ico_weapon_id]

		Application:debug("[RaidGUIControlListItemWeapons] wep icon tex", ico_weapon.texture)

		local text_rect = ico_weapon.texture_rect
		local weapon_icon_object = self._object:image({
			color = nil,
			w = nil,
			h = nil,
			y = nil,
			x = nil,
			texture_rect = nil,
			name = "weapon_icon",
			texture = nil,
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
end

function RaidGUIControlListItemWeapons:activate_on()
	RaidGUIControlListItemWeapons.super.activate_on(self)

	if self._object:child("weapon_icon") then
		self._object:child("weapon_icon"):set_color(tweak_data.gui.colors.raid_red)
	end
end

function RaidGUIControlListItemWeapons:activate_off()
	RaidGUIControlListItemWeapons.super.activate_off(self)

	if self._object:child("weapon_icon") then
		self._object:child("weapon_icon"):set_color(tweak_data.gui.colors.raid_white)
	end
end
