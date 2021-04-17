HUDTurret = HUDTurret or class()
HUDTurret.W = 380
HUDTurret.H = 288
HUDTurret.BACKGROUND_IMAGE = "backgrounds_machine_gun_empty"
HUDTurret.FOREGROUND_IMAGE = "machine_gun_full"
HUDTurret.HEAT_INDICATOR_W = 380
HUDTurret.HEAT_INDICATOR_H = 84
HUDTurret.HEAT_INDICATOR_COLORS = tweak_data.gui.colors.turret_heat_colors
HUDTurret.HEAT_INDICATOR_OVERHEAT_COLOR = tweak_data.gui.colors.turret_overheat
HUDTurret.DISMOUNT_PROMPT_H = 64
HUDTurret.DISMOUNT_PROMPT_TEXT = "hud_action_exit_turret"
HUDTurret.DISMOUNT_PROMPT_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDTurret.DISMOUNT_PROMPT_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDTurret.DISMOUNT_PROMPT_INITIAL_DELAY = 1
HUDTurret.DISMOUNT_PROMPT_HOLD_TIME = 4
HUDTurret.DISMOUNT_PROMPT_DELAY = 8
HUDTurret.DEFAULT_RETICLE = "weapons_reticles_ass_carbine"
HUDTurret.SHELL_POSITION_CENTER_X = 770

-- Lines 25-38
function HUDTurret:init(hud)
	self._hud_panel = hud.panel

	if self._hud_panel:child("turret_panel") then
		self._hud_panel:remove(self._hud_panel:child("turret_panel"))
	end

	self:_create_panel(hud)
	self:_create_heat_indicator()
	self:_create_dismount_prompt()
	self:_create_reticle()
	self:_create_shell()

	self._is_flak = false
end

-- Lines 40-47
function HUDTurret:_create_panel(hud)
	local panel_params = {
		alpha = 0,
		name = "turret_panel",
		halign = "center",
		valign = "center"
	}
	self._object = hud.panel:panel(panel_params)
end

-- Lines 49-84
function HUDTurret:_create_heat_indicator()
	local heat_indicator_panel_params = {
		name = "heat_indicator_panel",
		halign = "center",
		valign = "bottom",
		w = HUDTurret.HEAT_INDICATOR_W,
		h = HUDTurret.HEAT_INDICATOR_H
	}
	self._heat_indicator_panel = self._object:panel(heat_indicator_panel_params)

	self._heat_indicator_panel:set_center_x(self._object:w() / 2)
	self._heat_indicator_panel:set_bottom(self._object:h())

	local heat_indicator_background_params = {
		name = "background",
		texture = tweak_data.gui.icons[HUDTurret.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDTurret.BACKGROUND_IMAGE].texture_rect
	}
	self._heat_indicator_background = self._heat_indicator_panel:bitmap(heat_indicator_background_params)
	local heat_indicator_foreground_panel_params = {
		halign = "scale",
		name = "heat_indicator_foreground_panel",
		y = 0,
		x = 0,
		valign = "scale",
		w = self._heat_indicator_panel:w(),
		h = self._heat_indicator_panel:h(),
		layer = self._heat_indicator_background:layer() + 1
	}
	self._heat_indicator_foreground_panel = self._heat_indicator_panel:panel(heat_indicator_foreground_panel_params)
	local heat_indicator_foreground_params = {
		name = "heat_indicator_foreground",
		texture = tweak_data.gui.icons[HUDTurret.FOREGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDTurret.FOREGROUND_IMAGE].texture_rect
	}
	self._heat_indicator_foreground = self._heat_indicator_foreground_panel:bitmap(heat_indicator_foreground_params)
end

-- Lines 86-116
function HUDTurret:_create_dismount_prompt()
	local dismount_prompt_panel_params = {
		alpha = 0,
		name = "dismount_prompt_panel",
		halign = "scale",
		valign = "top",
		w = self._object:w(),
		h = HUDTurret.DISMOUNT_PROMPT_H
	}
	self._dismount_prompt_panel = self._object:panel(dismount_prompt_panel_params)

	self._dismount_prompt_panel:set_y(self._heat_indicator_panel:y() - 200)

	local dismount_prompt_text_params = {
		layer = 5,
		vertical = "center",
		name = "text",
		align = "center",
		halign = "center",
		valign = "center",
		font = HUDTurret.DISMOUNT_PROMPT_TEXT_FONT,
		font_size = HUDTurret.DISMOUNT_PROMPT_TEXT_FONT_SIZE,
		text = utf8.to_upper(managers.localization:text(HUDTurret.DISMOUNT_PROMPT_TEXT, {
			BTN_INTERACT = managers.localization:btn_macro("interact")
		}))
	}
	self._dismount_prompt_text = self._dismount_prompt_panel:text(dismount_prompt_text_params)
	local _, _, w, h = self._dismount_prompt_text:text_rect()

	self._dismount_prompt_text:set_w(w)
	self._dismount_prompt_text:set_h(h)
	self._dismount_prompt_text:set_center_x(self._dismount_prompt_panel:w() / 2)
	self._dismount_prompt_text:set_center_y(self._dismount_prompt_panel:h() / 2)
end

-- Lines 118-129
function HUDTurret:_create_reticle()
	local reticle_params = {
		name = "turret_reticle",
		halign = "center",
		alpha = 0,
		valign = "center",
		texture = tweak_data.gui.icons[HUDTurret.DEFAULT_RETICLE].texture,
		texture_rect = tweak_data.gui.icons[HUDTurret.DEFAULT_RETICLE].texture_rect
	}
	self._reticle = self._object:bitmap(reticle_params)

	self._reticle:set_center_x(self._object:w() / 2)
	self._reticle:set_center_y(self._object:h() / 2)
end

-- Lines 131-167
function HUDTurret:_create_shell()
	local params_bg = {
		name = "shell_bg",
		halign = "center",
		alpha = 0,
		layer = 1,
		valign = "center",
		texture = tweak_data.gui.icons.aa_gun_bg.texture,
		texture_rect = tweak_data.gui.icons.aa_gun_bg.texture_rect
	}
	self._shell_bg = self._object:bitmap(params_bg)

	self._shell_bg:set_center_x(self._object:w() / 2)
	self._shell_bg:set_bottom(self._object:h() - 32)

	local params_fade = {
		name = "shell_fade",
		halign = "center",
		alpha = 0,
		layer = 2,
		valign = "center",
		texture = tweak_data.gui.icons.aa_gun_flak.texture,
		texture_rect = tweak_data.gui.icons.aa_gun_flak.texture_rect
	}
	self._shell_fade = self._object:bitmap(params_fade)

	self._shell_fade:set_center_y(self._shell_bg:center_y())
	self._shell_fade:set_x(self._shell_bg:x() + 2)

	local params_shell = {
		name = "shell",
		halign = "center",
		alpha = 0,
		layer = 3,
		valign = "center",
		texture = tweak_data.gui.icons.aa_gun_flak.texture,
		texture_rect = tweak_data.gui.icons.aa_gun_flak.texture_rect
	}
	self._shell = self._object:bitmap(params_shell)

	self._shell:set_x(self._shell_bg:x() + 2)
	self._shell:set_center_y(self._shell_bg:center_y())
end

-- Lines 169-178
function HUDTurret:set_reticle(reticle)
	self._reticle:set_image(tweak_data.gui.icons[reticle].texture)
	self._reticle:set_texture_rect(unpack(tweak_data.gui.icons[reticle].texture_rect))
	self._reticle:set_center_x(self._object:w() / 2)
	self._reticle:set_center_y(self._object:h() / 2)
	self._reticle:stop()
	self._reticle:animate(callback(self, self, "_animate_show"), 0.15)
end

-- Lines 180-201
function HUDTurret:show(turret_unit, bullet_type)
	self._dismount_prompt_panel:set_alpha(0)
	self._object:stop()

	if bullet_type ~= nil and bullet_type == "shell" then
		self._object:animate(callback(self, self, "_animate_flak_show"))

		self._is_flak = true
	else
		self._object:animate(callback(self, self, "_animate_normal_show"))

		self._is_flak = false
	end

	managers.hud:unselect_all_weapons()
	managers.queued_tasks:queue("hud_turret_prompt", self.show_prompt, self, nil, HUDTurret.DISMOUNT_PROMPT_INITIAL_DELAY, nil)

	local turret_unit = managers.player:get_turret_unit()
	local turret_tweak_data = turret_unit:weapon():weapon_tweak_data()

	if turret_tweak_data.hud and turret_tweak_data.hud.reticle then
		self:set_reticle(turret_tweak_data.hud.reticle)
	end
end

-- Lines 203-210
function HUDTurret:hide()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
	managers.queued_tasks:unqueue("hud_turret_prompt")
	self._reticle:stop()
	self._reticle:animate(callback(self, self, "_animate_hide"), 0.15)
end

-- Lines 212-224
function HUDTurret:show_prompt()
	self._dismount_prompt_panel:stop()
	self._dismount_prompt_text:set_text(utf8.to_upper(managers.localization:text(HUDTurret.DISMOUNT_PROMPT_TEXT, {
		BTN_INTERACT = managers.localization:btn_macro("interact")
	})))
	self._dismount_prompt_panel:animate(callback(self, self, "_animate_show"))
	managers.queued_tasks:queue("hud_turret_prompt", self.hide_prompt, self, nil, HUDTurret.DISMOUNT_PROMPT_HOLD_TIME, nil)
end

-- Lines 226-230
function HUDTurret:hide_prompt()
	self._dismount_prompt_panel:stop()
	self._dismount_prompt_panel:animate(callback(self, self, "_animate_hide"))
	managers.queued_tasks:queue("hud_turret_prompt", self.show_prompt, self, nil, HUDTurret.DISMOUNT_PROMPT_DELAY, nil)
end

-- Lines 232-244
function HUDTurret:update_heat_indicator(current)
	if self._is_flak then
		return
	end

	self._heat_indicator_foreground_panel:set_w(current * self._heat_indicator_panel:w())

	if not self._overheating then
		self._heat_indicator_foreground:set_color(self:_get_color_for_percentage(HUDTurret.HEAT_INDICATOR_COLORS, current))
	else
		self._heat_indicator_foreground:set_color(HUDTurret.HEAT_INDICATOR_OVERHEAT_COLOR)
	end
end

-- Lines 246-248
function HUDTurret:set_overheating(value)
	self._overheating = value
end

-- Lines 250-259
function HUDTurret:overheat(turret_unit)
	local turret_tweak_data = turret_unit:weapon():weapon_tweak_data()

	if turret_tweak_data.name == "turret_flak_88" then
		self._shell:animate(callback(self, self, "_animate_shell_fire"))
	else
		self._overheating = true

		self._heat_indicator_foreground:set_color(HUDTurret.HEAT_INDICATOR_OVERHEAT_COLOR)
	end
end

-- Lines 261-263
function HUDTurret:cooldown()
	self._overheating = false
end

-- Lines 265-267
function HUDTurret:w()
	return self._object:w()
end

-- Lines 269-271
function HUDTurret:h()
	return self._object:h()
end

-- Lines 273-275
function HUDTurret:set_x(x)
	self._object:set_x(x)
end

-- Lines 277-279
function HUDTurret:set_y(y)
	self._object:set_y(y)
end

-- Lines 281-289
function HUDTurret:_get_color_for_percentage(color_table, percentage)
	for i = #color_table, 1, -1 do
		if color_table[i].start_percentage < percentage then
			return color_table[i].color
		end
	end

	return color_table[1].color
end

-- Lines 291-304
function HUDTurret:_animate_show(object, animation_duration)
	local duration = animation_duration or 0.4
	local t = object:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, duration)

		object:set_alpha(current_alpha)
	end

	object:set_alpha(1)
end

-- Lines 307-329
function HUDTurret:_animate_normal_show(object, animation_duration)
	local duration = animation_duration or 0.4
	local t = 0

	self._object:set_alpha(1)
	self._heat_indicator_background:set_alpha(0)
	self._heat_indicator_foreground:set_alpha(1)
	self._shell:set_alpha(0)
	self._shell_fade:set_alpha(0)
	self._shell_bg:set_alpha(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = t / duration

		self._heat_indicator_background:set_alpha(current_alpha)
	end

	self._heat_indicator_background:set_alpha(1)
end

-- Lines 331-365
function HUDTurret:_animate_flak_show(object, animation_duration)
	local duration = animation_duration or 0.4
	local t = 0

	self._object:set_alpha(1)
	self._heat_indicator_background:set_alpha(0)
	self._heat_indicator_foreground:set_alpha(0)

	local show_shell = false

	if self._shell:alpha() == 1 then
		show_shell = true
	end

	self._shell_bg:set_alpha(0)
	self._shell_fade:set_alpha(0)
	self._shell:set_alpha(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = t / duration

		self._shell_bg:set_alpha(current_alpha)
		self._shell_fade:set_alpha(0.1 * current_alpha)

		if show_shell then
			self._shell:set_alpha(current_alpha)
		end
	end

	self._shell_bg:set_alpha(1)
	self._shell_fade:set_alpha(0.1)

	if show_shell then
		self._shell:set_alpha(1)
	end
end

-- Lines 367-380
function HUDTurret:_animate_hide(object, animation_duration)
	local duration = animation_duration or 0.4
	local t = (1 - object:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, duration)

		object:set_alpha(current_alpha)
	end

	object:set_alpha(0)
end

-- Lines 383-385
function HUDTurret:flak_fire()
	self._shell:animate(callback(self, self, "_animate_shell_fire"))
end

-- Lines 387-391
function HUDTurret:flak_insert()
	if self._is_flak then
		self._shell:animate(callback(self, self, "_animate_shell_insert"))
	end
end

-- Lines 394-406
function HUDTurret:_animate_shell_insert()
	local duration = 0.7
	local t = 0

	self._shell:set_alpha(0)
	self._shell:set_x(self._shell_bg:x() + 1)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quadratic_in(t, 0, 1, duration)

		self._shell:set_alpha(alpha)
	end

	self._shell:set_alpha(1)
end

-- Lines 409-432
function HUDTurret:_animate_shell_fire()
	local duration = 0.2
	local t = 0
	local delta_move = tweak_data.gui.icons.aa_gun_bg.texture_rect[3]
	local shell_width = tweak_data.gui.icons.aa_gun_flak.texture_rect[3]

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local pos_alpha = t / duration
		local pos_delta = pos_alpha * tweak_data.gui.icons.aa_gun_bg.texture_rect[3]
		local new_pos = self._shell_bg:x() + pos_delta

		self._shell:set_x(new_pos)

		if new_pos > self._shell_bg:x() + shell_width then
			local alpha_alpha = Easing.quadratic_in(t, 0, 1, duration)

			self._shell:set_alpha(1 - alpha_alpha)
		end
	end

	self._shell:set_x(self._shell_bg:x())
	self._shell:set_alpha(0)
end
