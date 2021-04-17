HUDWeaponGrenade = HUDWeaponGrenade or class(HUDWeaponBase)
HUDWeaponGrenade.W = 108
HUDWeaponGrenade.H = 84
HUDWeaponGrenade.AMOUNT_FONT = tweak_data.gui.fonts.din_compressed_outlined_32
HUDWeaponGrenade.AMOUNT_FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDWeaponGrenade.AMOUNT_TEXT_COLOR = Color.white
HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_SELECTED = 1
HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_UNSELECTED = 0.7

-- Lines 13-20
function HUDWeaponGrenade:init(index, weapons_panel, tweak_data)
	HUDWeaponGrenade.super.init(self, index, weapons_panel, tweak_data)

	self._index = index

	self:_create_panel(weapons_panel)
	self:_create_icon(tweak_data.hud.icon)
	self:_create_amount_text(weapons_panel)
end

-- Lines 22-30
function HUDWeaponGrenade:_create_panel(weapons_panel)
	local panel_params = {
		halign = "right",
		valign = "bottom",
		name = "grenade_" .. tostring(self._index),
		w = HUDWeaponGrenade.W,
		h = HUDWeaponGrenade.H
	}
	self._object = weapons_panel:panel(panel_params)
end

-- Lines 32-51
function HUDWeaponGrenade:_create_icon(icon)
	local icon_panel_params = {
		halign = "center",
		name = "icon_panel",
		y = 0,
		x = 0,
		valign = "top",
		w = self._object:w(),
		h = self._object:h() / 2
	}
	self._icon_panel = self._object:panel(icon_panel_params)
	local icon_params = {
		name = "weapon_icon",
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect,
		alpha = HUDWeaponBase.ALPHA_WHEN_UNSELECTED
	}
	self._icon = self._icon_panel:bitmap(icon_params)

	self._icon:set_center_x(self._icon_panel:w() / 2)
	self._icon:set_center_y(self._icon_panel:h() / 2)
end

-- Lines 53-64
function HUDWeaponGrenade:_create_amount_text()
	local amount_text_params = {
		text = "",
		name = "amount_text",
		font = HUDWeaponGrenade.AMOUNT_FONT,
		font_size = HUDWeaponGrenade.AMOUNT_FONT_SIZE,
		color = HUDWeaponGrenade.AMOUNT_TEXT_COLOR,
		alpha = HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_UNSELECTED
	}
	self._amount_text = self._object:text(amount_text_params)

	self:set_amount(0)
end

-- Lines 66-81
function HUDWeaponGrenade:set_amount(amount)
	self._amount_text:set_text(string.format("%03d", amount))

	local _, _, w, h = self._amount_text:text_rect()

	self._amount_text:set_w(w)
	self._amount_text:set_h(h)
	self._amount_text:set_center_x(self._object:w() / 2 - 4)
	self._amount_text:set_bottom(self._object:h() - 4)

	if amount == 0 then
		self._amount_text:set_color(tweak_data.gui.colors.progress_red)
	else
		self._amount_text:set_color(Color.white)
	end
end

-- Lines 83-103
function HUDWeaponGrenade:_animate_alpha(root_panel, new_alpha)
	local start_alpha = new_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponBase.ALPHA_WHEN_UNSELECTED or HUDWeaponBase.ALPHA_WHEN_SELECTED
	local start_amount_text_alpha = start_alpha == HUDWeaponBase.ALPHA_WHEN_SELECTED and HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_SELECTED or HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_UNSELECTED
	local new_amount_text_alpha = start_amount_text_alpha == HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_SELECTED and HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_UNSELECTED or HUDWeaponGrenade.AMOUNT_TEXT_ALPHA_WHEN_SELECTED
	local duration = 0.2
	local t = (self._icon:alpha() - start_alpha) / (new_alpha - start_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, start_alpha, new_alpha - start_alpha, duration)

		self._icon:set_alpha(current_alpha)

		local amount_text_alpha = Easing.quartic_in_out(t, start_amount_text_alpha, new_amount_text_alpha - start_amount_text_alpha, duration)

		self._amount_text:set_alpha(amount_text_alpha)
	end

	self._icon:set_alpha(new_alpha)
	self._amount_text:set_alpha(new_amount_text_alpha)
end
