HUDCarry = HUDCarry or class()
HUDCarry.H = 114
HUDCarry.BOTTOM_DISTANCE_WHILE_HIDDEN = 32
HUDCarry.ICON_SIZE = 82
HUDCarry.WEIGHT_ICON = "carry_weight_indicator_bg"
HUDCarry.WEIGHT_FILL_ICON = "carry_weight_indicator_fill"
HUDCarry.WEIGHT_FILL_COLOR = tweak_data.gui.colors.raid_gold
HUDCarry.PROMPT_W = 224
HUDCarry.PROMPT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDCarry.PROMPT_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDCarry.PROMPT_TEXT_ID = "hud_carry_throw_prompt"
HUDCarry.GENERIC_THROW_ID = "carry_item_generic"

function HUDCarry:init(hud)
	self:_create_panel(hud)
	self:_create_icon()
	self:_create_prompt()
end

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

function HUDCarry:_create_icon()
	self._icon_panel = self._object:panel({
		name = "icon_panel",
		halign = "center",
		valign = "top",
		w = HUDCarry.ICON_SIZE,
		h = HUDCarry.ICON_SIZE
	})
	self._icon = self._icon_panel:bitmap({
		name = "icon",
		halign = "center",
		valign = "center",
		texture = tweak_data.gui.icons[HUDCarry.WEIGHT_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDCarry.WEIGHT_ICON].texture_rect,
		w = HUDCarry.ICON_SIZE,
		h = HUDCarry.ICON_SIZE
	})
	self._icon_fill_left = self._icon_panel:bitmap({
		name = "icon_fill_left",
		valign = "center",
		halign = "left",
		render_template = "VertexColorTexturedRadial",
		texture = tweak_data.gui.icons[HUDCarry.WEIGHT_FILL_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDCarry.WEIGHT_FILL_ICON].texture_rect,
		x = HUDCarry.ICON_SIZE,
		y = HUDCarry.ICON_SIZE,
		w = -HUDCarry.ICON_SIZE,
		h = -HUDCarry.ICON_SIZE,
		color = HUDCarry.WEIGHT_FILL_COLOR,
		layer = self._icon:layer() + 1
	})
	self._icon_fill_right = self._icon_panel:bitmap({
		name = "icon_fill_right",
		x = 0,
		valign = "center",
		halign = "right",
		render_template = "VertexColorTexturedRadial",
		texture = tweak_data.gui.icons[HUDCarry.WEIGHT_FILL_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDCarry.WEIGHT_FILL_ICON].texture_rect,
		y = HUDCarry.ICON_SIZE,
		w = HUDCarry.ICON_SIZE,
		h = -HUDCarry.ICON_SIZE,
		color = HUDCarry.WEIGHT_FILL_COLOR,
		layer = self._icon:layer() + 2
	})
end

function HUDCarry:_create_prompt()
	local prompt_params = {
		vertical = "top",
		name = "prompt",
		align = "center",
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

function HUDCarry:_size_panel()
	local _, _, w, h = self._prompt:text_rect()

	self._object:set_w(w + 4)
	self._object:set_center_x(self._object:parent():w() / 2)
	self._prompt:set_w(w + 4)
	self._prompt:set_h(h)
	self._prompt:set_center_x(self._object:w() / 2)
	self._prompt:set_bottom(self._object:h())
	self._icon_panel:set_center_x(self._object:w() / 2 - 1)
	self._icon_panel:set_bottom(self._prompt:y() - 3)
end

function HUDCarry:show_carry_item(carry_id)
	local carry_data = tweak_data.carry[carry_id]

	if carry_data then
		self._icon_fill_left:set_visible(not carry_data.cannot_stack)
		self._icon_fill_right:set_visible(not carry_data.cannot_stack)
	end

	local item_icon = carry_data.cannot_stack and carry_data.hud_icon
	item_icon = item_icon or HUDCarry.WEIGHT_ICON

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

function HUDCarry:set_carry_weight(weight, over_weight)
	self._icon:stop()
	self._icon:animate(callback(self, self, "_animate_set_carry_weight"), weight)
	self:set_overweight_indication(over_weight)
end

function HUDCarry:shake_carry_icon()
	if not self._shaking then
		self._shaking = true

		self._icon_panel:stop()
		self._icon_panel:animate(callback(self, self, "_animate_shake_icon"))
	end

	managers.hud:post_event("generic_fail_sound")
end

function HUDCarry:set_carry_fill(weight)
	local fill = math.min(weight / 2, 0.5)

	self._icon_fill_right:set_position_z(fill)
	self._icon_fill_left:set_position_z(fill)
end

function HUDCarry:set_overweight_indication(state)
	local color = state and tweak_data.gui.colors.progress_red or tweak_data.gui.colors.raid_gold

	self._icon_fill_left:set_color(color)
	self._icon_fill_right:set_color(color)
end

function HUDCarry:hide_carry_item()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide_carry"))
end

function HUDCarry:w()
	return self._object:w()
end

function HUDCarry:h()
	return self._object:h()
end

function HUDCarry:set_x(x)
	self._object:set_x(x)
end

function HUDCarry:set_y(y)
	self._object:set_y(y)
end

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

function HUDCarry:_animate_set_carry_weight(panel, weight)
	weight = weight or 1
	local start_weight = self._icon_fill_right:position_z() * 2
	local duration = 0.45
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_weight = Easing.quadratic_out(t, start_weight, weight - start_weight, duration)

		self:set_carry_fill(current_weight)
	end

	self:set_carry_fill(weight)
end

function HUDCarry:_animate_shake_icon()
	local duration = 1
	local t = 0
	local freq = 1120
	local amp = 8

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = math.sin(t * freq) * amp * (duration - t)

		self._icon_panel:set_center_x(self._object:w() / 2 - current_offset - 1)
	end

	self._shaking = nil

	self._icon_panel:set_center_x(self._object:w() / 2 - 1)
end
