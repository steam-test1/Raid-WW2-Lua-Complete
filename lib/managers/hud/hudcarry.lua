HUDCarry = HUDCarry or class()
HUDCarry.H = 64
HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN = 32
HUDCarry.ICON_PADDING_RIGHT = 16
HUDCarry.PROMPT_W = 192
HUDCarry.PROMPT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDCarry.PROMPT_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDCarry.PROMPT_TEXT_ID = "hud_carry_throw_prompt"
HUDCarry.GENERIC_THROW_ID = "carry_item_generic"

-- Lines 14-18
function HUDCarry:init(hud)
	self:_create_panel(hud)
	self:_create_icon()
	self:_create_prompt()
end

-- Lines 20-28
function HUDCarry:_create_panel(hud)
	local panel_params = {
		name = "carry_panel",
		halign = "center",
		alpha = 0,
		valign = "bottom",
		h = HUDCarry.H
	}
	self._object = hud.panel:panel(panel_params)
end

-- Lines 30-40
function HUDCarry:_create_icon()
	local placeholder_icon = "carry_planks"
	local icon_params = {
		name = "icon",
		valign = "center",
		halign = "left",
		texture = tweak_data.gui.icons[placeholder_icon].texture,
		texture_rect = tweak_data.gui.icons[placeholder_icon].texture_rect
	}
	self._icon = self._object:bitmap(icon_params)
end

-- Lines 42-55
function HUDCarry:_create_prompt()
	local prompt_params = {
		vertical = "top",
		wrap = true,
		align = "center",
		name = "prompt",
		text = "",
		halign = "left",
		valign = "top",
		w = HUDCarry.PROMPT_W,
		h = self._object:h(),
		font = HUDCarry.PROMPT_FONT,
		font_size = HUDCarry.PROMPT_FONT_SIZE
	}
	self._prompt = self._object:text(prompt_params)
end

-- Lines 57-70
function HUDCarry:_size_panel()
	self._icon:set_x(0)
	self._icon:set_center_y(self._object:h() / 2)

	local _, _, w, h = self._prompt:text_rect()

	self._prompt:set_w(w)
	self._prompt:set_h(h)
	self._prompt:set_x(self._icon:x() + self._icon:w() + HUDCarry.ICON_PADDING_RIGHT)
	self._prompt:set_center_y(self._object:h() / 2 - 3)

	local center_x = self._object:center_x()

	self._object:set_w(self._prompt:x() + self._prompt:w())
	self._object:set_center_x(center_x)
end

-- Lines 72-91
function HUDCarry:show_carry_item(carry_id)
	local carry_data = tweak_data.carry[carry_id]
	local item_icon = carry_data.hud_icon or "carry_planks"

	self._icon:set_image(tweak_data.gui.icons[item_icon].texture)
	self._icon:set_texture_rect(unpack(tweak_data.gui.icons[item_icon].texture_rect))

	local prompt_text_id = carry_data.prompt_text or HUDCarry.PROMPT_TEXT_ID
	local carry_item_id = carry_data.carry_item_id or HUDCarry.GENERIC_THROW_ID

	self._prompt:set_text(utf8.to_upper(managers.localization:text(prompt_text_id, {
		BTN_USE_ITEM = managers.localization:btn_macro("use_item"),
		CARRY_ITEM = managers.localization:text(carry_item_id)
	})))
	self:_size_panel()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show_carry"))
end

-- Lines 93-96
function HUDCarry:hide_carry_item()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide_carry"))
end

-- Lines 98-100
function HUDCarry:w()
	return self._object:w()
end

-- Lines 102-104
function HUDCarry:h()
	return self._object:h()
end

-- Lines 106-108
function HUDCarry:set_x(x)
	self._object:set_x(x)
end

-- Lines 110-112
function HUDCarry:set_y(y)
	self._object:set_y(y)
end

-- Lines 114-131
function HUDCarry:_animate_show_carry()
	local duration = 0.5
	local t = self._object:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)

		local current_bottom_distance = Easing.quartic_out(t, HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN, -HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

		self._object:set_bottom(self._object:parent():h() - current_bottom_distance)
	end

	self._object:set_alpha(1)
	self._object:set_bottom(self._object:parent():h())
end

-- Lines 133-150
function HUDCarry:_animate_hide_carry()
	local duration = 0.25
	local t = (1 - self._object:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 1, -1, duration)

		self._object:set_alpha(current_alpha)

		local current_bottom_distance = Easing.quartic_out(t, 0, HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN, duration)

		self._object:set_bottom(self._object:parent():h() - current_bottom_distance)
	end

	self._object:set_alpha(0)
	self._object:set_bottom(self._object:parent():h() - HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN)
end
