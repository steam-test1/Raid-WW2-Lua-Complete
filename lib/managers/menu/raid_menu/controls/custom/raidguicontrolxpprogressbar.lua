RaidGUIControlXPProgressBar = RaidGUIControlXPProgressBar or class(RaidGUIControl)
RaidGUIControlXPProgressBar.DEFAULT_H = 177
RaidGUIControlXPProgressBar.INNER_PANEL_H = 177
RaidGUIControlXPProgressBar.PROGRESS_BAR_H = 32
RaidGUIControlXPProgressBar.LEVEL_LABELS_PANEL_H = 64
RaidGUIControlXPProgressBar.LEVEL_LABELS_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlXPProgressBar.LEVEL_LABELS_FONT_SIZE = tweak_data.gui.font_sizes.size_46
RaidGUIControlXPProgressBar.LEVEL_LABELS_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlXPProgressBar.LEVEL_LABELS_W = 100
RaidGUIControlXPProgressBar.WEAPON_UNLOCK_ICONS_PANEL_H = 32
RaidGUIControlXPProgressBar.WEAPON_UNLOCK_ICON = "icon_weapon_unlocked"
RaidGUIControlXPProgressBar.WEAPON_UNLOCK_ICON_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlXPProgressBar.WEAPON_UNLOCK_TEXT_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlXPProgressBar.WEAPON_UNLOCK_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_18
RaidGUIControlXPProgressBar.WEAPON_UNLOCK_TEXT_PADDING_RIGHT = 6
RaidGUIControlXPProgressBar.LEVEL_MARK_ICON = "slider_mid_dot"
RaidGUIControlXPProgressBar.LEVEL_MARK_ICON_SIZE = 8
RaidGUIControlXPProgressBar.MARKS_PER_LEVEL = 5
RaidGUIControlXPProgressBar.SLIDER_PIMPLE_ICON = "slider_pimple"
RaidGUIControlXPProgressBar.SLIDER_PIMPLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlXPProgressBar.SLIDER_PIN_ICON = "slider_pin"
RaidGUIControlXPProgressBar.SLIDER_PIN_Y = 55
RaidGUIControlXPProgressBar.SLIDER_PIN_COLOR_INACTIVE = Color("787878")
RaidGUIControlXPProgressBar.SLIDER_PIN_COLOR_ACTIVE = tweak_data.gui.colors.raid_red
RaidGUIControlXPProgressBar.NEW_XP_W = 256
RaidGUIControlXPProgressBar.NEW_XP_H = 64
RaidGUIControlXPProgressBar.NEW_XP_TEXT_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlXPProgressBar.NEW_XP_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlXPProgressBar.NEW_XP_TEXT_COLOR = tweak_data.gui.colors.raid_white

function RaidGUIControlXPProgressBar:init(parent, params)
	params.horizontal_padding = params.horizontal_padding or 0

	RaidGUIControlXPProgressBar.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlXPProgressBar:init] Parameters not specified for the customization details")

		return
	end

	self:_create_panels()

	self._bar_w = self._inner_panel:w() - self._params.horizontal_padding * 2
	self._current_level = params.initial_level or 1
	self._horizontal_padding = self._params.horizontal_padding or 0

	self:_create_progress_bar()
	self:_create_slider_pimples()
	self:_create_level_marks_on_progress_bar()
	self:_create_level_and_weapons_info()
	self:_create_new_xp_label()

	self._progress = params.initial_progress or 0

	self:set_progress(self._progress, 0)
end

function RaidGUIControlXPProgressBar:close()
end

function RaidGUIControlXPProgressBar:_create_panels()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w
	control_params.h = self._params.h or RaidGUIControlXPProgressBar.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
	control_params.x = 0
	control_params.y = 0
	control_params.w = self._params.bar_w or control_params.w
	control_params.h = RaidGUIControlXPProgressBar.INNER_PANEL_H
	self._inner_panel = self._object:panel(control_params)
end

function RaidGUIControlXPProgressBar:_create_progress_bar()
	local progress_bar_params = {
		left = "slider_large_left",
		name = "progress_bar",
		y = 0,
		center = "slider_large_center",
		x = 0,
		right = "slider_large_right",
		w = self._bar_w + self._horizontal_padding * 2,
		h = self._params.progress_bar_h or RaidGUIControlXPProgressBar.PROGRESS_BAR_H
	}
	self._progress_bar = self._inner_panel:progress_bar_simple(progress_bar_params)

	self._progress_bar:set_bottom(96)

	self._progress_padding = self._horizontal_padding / self._progress_bar:w()
	self._progress_multiplier = self._bar_w / self._progress_bar:w()
end

function RaidGUIControlXPProgressBar:_create_slider_pimples()
	local icon = RaidGUIControlXPProgressBar.SLIDER_PIMPLE_ICON
	local icon_w = tweak_data.gui:icon_w(icon)
	local icon_h = tweak_data.gui:icon_h(icon)
	local pin_icon = RaidGUIControlXPProgressBar.SLIDER_PIN_ICON
	local slider_pimples_panel_params = {
		name = "slider_pimples_panel",
		x = 0,
		y = self._progress_bar:y() - icon_h,
		w = self._inner_panel:w(),
		h = icon_h,
		layer = self._progress_bar:layer() + 5
	}
	self._slider_pimples_panel = self._inner_panel:panel(slider_pimples_panel_params)
	local current_level = 1
	local level_cap = managers.experience:level_cap()
	local character_class = managers.skilltree:get_character_profile_class()
	local weapon_unlock_progression = tweak_data.skilltree.automatic_unlock_progressions[character_class]
	self._level_pins = {}

	while current_level <= level_cap do
		local level_mark_params = {
			y = 0,
			name = "slider_pimple_" .. current_level,
			x = self._params.horizontal_padding + (current_level - 1) * self._bar_w / (level_cap - 1) - icon_w / 2,
			w = icon_w,
			h = icon_h,
			color = RaidGUIControlXPProgressBar.SLIDER_PIMPLE_COLOR,
			texture = tweak_data.gui.icons[icon].texture,
			texture_rect = tweak_data.gui.icons[icon].texture_rect
		}
		local level_mark = self._slider_pimples_panel:image(level_mark_params)
		local level_pin_params = {
			layer = 200,
			name = "slider_pin_" .. current_level,
			x = self._params.horizontal_padding + (current_level - 1) * self._bar_w / (level_cap - 1) - tweak_data.gui:icon_w(pin_icon) / 2,
			y = RaidGUIControlXPProgressBar.SLIDER_PIN_Y,
			texture = tweak_data.gui.icons[pin_icon].texture,
			texture_rect = tweak_data.gui.icons[pin_icon].texture_rect,
			color = current_level == 1 and RaidGUIControlXPProgressBar.SLIDER_PIN_COLOR_ACTIVE or RaidGUIControlXPProgressBar.SLIDER_PIN_COLOR_INACTIVE
		}
		local level_pin = self._inner_panel:bitmap(level_pin_params)

		table.insert(self._level_pins, level_pin)

		current_level = current_level + 1
	end
end

function RaidGUIControlXPProgressBar:_create_level_marks_on_progress_bar()
	local level_marks_panel_params = {
		name = "level_marks_panel",
		y = 0,
		x = 0,
		w = self._inner_panel:w(),
		h = self._progress_bar:h()
	}
	self._level_marks_panel = self._inner_panel:panel(level_marks_panel_params)

	self._level_marks_panel:set_center_y(self._progress_bar:center_y())

	local current_level = 1
	local level_cap = managers.experience:level_cap()
	self._level_marks = {}
	local icon = RaidGUIControlXPProgressBar.LEVEL_MARK_ICON
	local level_w = self._bar_w / (level_cap - 1)

	while current_level <= level_cap do
		for i = 2, RaidGUIControlXPProgressBar.MARKS_PER_LEVEL do
			local level_mark_params = {
				name = "level_label_" .. current_level .. "_" .. tostring(i),
				x = self._params.horizontal_padding + (current_level - 1) * level_w - RaidGUIControlXPProgressBar.LEVEL_MARK_ICON_SIZE / 2 + (i - 1) * level_w / RaidGUIControlXPProgressBar.MARKS_PER_LEVEL,
				y = self._level_marks_panel:h() / 2 - RaidGUIControlXPProgressBar.LEVEL_MARK_ICON_SIZE / 2,
				w = RaidGUIControlXPProgressBar.LEVEL_MARK_ICON_SIZE,
				h = RaidGUIControlXPProgressBar.LEVEL_MARK_ICON_SIZE,
				color = tweak_data.gui.colors.progress_bar_dot,
				texture = tweak_data.gui.icons[icon].texture,
				texture_rect = tweak_data.gui.icons[icon].texture_rect
			}
			local level_mark = self._level_marks_panel:image(level_mark_params)

			table.insert(self._level_marks, level_mark)
		end

		current_level = current_level + 1
	end
end

function RaidGUIControlXPProgressBar:_create_level_and_weapons_info()
	local level_labels_panel_params = {
		name = "level_labels_panel",
		y = 0,
		x = 0,
		w = self._inner_panel:w(),
		h = RaidGUIControlXPProgressBar.LEVEL_LABELS_PANEL_H - self._slider_pimples_panel:h()
	}
	self._level_labels_panel = self._inner_panel:panel(level_labels_panel_params)

	self._level_labels_panel:set_bottom(self._slider_pimples_panel:y())

	self._level_labels = {}
	self._weapon_unlock_icons = {}
	local character_class = managers.skilltree:get_character_profile_class()
	local weapon_unlock_progression = tweak_data.skilltree.automatic_unlock_progressions[character_class]
	local level_cap = managers.experience:level_cap()
	local current_level = 1

	while level_cap >= current_level do
		local draw_label = current_level == 1 or current_level % 1 == 0
		local number_of_weapon_unlocks = weapon_unlock_progression[current_level] and weapon_unlock_progression[current_level].weapons and #weapon_unlock_progression[current_level].weapons or 0

		if draw_label or number_of_weapon_unlocks then
			local level_label = self:_create_label_for_level(current_level, draw_label, number_of_weapon_unlocks)

			level_label:set_center_x(self._horizontal_padding + (current_level - 1) * self._bar_w / (level_cap - 1))
			table.insert(self._level_labels, level_label)
		end

		current_level = current_level + 1
	end
end

function RaidGUIControlXPProgressBar:_create_new_xp_label()
	local new_xp_params = {
		vertical = "center",
		name = "new_xp_text",
		align = "center",
		alpha = 0,
		text = "",
		w = RaidGUIControlXPProgressBar.NEW_XP_W,
		h = RaidGUIControlXPProgressBar.NEW_XP_H,
		font = RaidGUIControlXPProgressBar.NEW_XP_TEXT_FONT,
		font_size = RaidGUIControlXPProgressBar.NEW_XP_TEXT_FONT_SIZE,
		color = RaidGUIControlXPProgressBar.NEW_XP_TEXT_COLOR
	}
	self._new_xp_text = self._inner_panel:text(new_xp_params)

	self._new_xp_text:set_bottom(self._inner_panel:h())
end

function RaidGUIControlXPProgressBar:_create_label_for_level(level, draw_level_label, number_of_weapon_unlocks)
	local level_label_panel_params = {
		y = 0,
		x = 0,
		name = "level_" .. tostring(level) .. "_label_panel",
		w = RaidGUIControlXPProgressBar.LEVEL_LABELS_W,
		h = self._level_labels_panel:h()
	}
	local level_label_panel = self._level_labels_panel:panel(level_label_panel_params)
	local level_label = nil

	if draw_level_label then
		local level_label_text_params = {
			vertical = "center",
			name = "level_label_text",
			align = "center",
			y = 0,
			x = 0,
			w = level_label_panel:w(),
			h = level_label_panel:h(),
			font = RaidGUIControlXPProgressBar.LEVEL_LABELS_FONT,
			font_size = RaidGUIControlXPProgressBar.LEVEL_LABELS_FONT_SIZE,
			text = tostring(level),
			color = RaidGUIControlXPProgressBar.LEVEL_LABELS_COLOR
		}
		level_label = level_label_panel:text(level_label_text_params)
		local _, _, w, _ = level_label:text_rect()

		level_label:set_w(w)
		level_label:set_center_x(level_label_panel:w() / 2)
	end

	local weapon_unlock = nil

	if number_of_weapon_unlocks > 0 then
		local weapon_unlock_panel_params = {
			name = "weapon_unlock_panel",
			y = 0,
			x = 0,
			w = level_label_panel:w(),
			h = level_label_panel:h()
		}
		weapon_unlock = level_label_panel:panel(weapon_unlock_panel_params)
		local weapon_icon = RaidGUIControlXPProgressBar.WEAPON_UNLOCK_ICON
		local icon_w = tweak_data.gui:icon_w(weapon_icon)
		local icon_h = tweak_data.gui:icon_h(weapon_icon)
		local icon_params = {
			y = 0,
			x = 0,
			name = "weapon_unlock_icon_" .. tostring(level),
			w = icon_w,
			h = icon_h,
			texture = tweak_data.gui.icons[weapon_icon].texture,
			texture_rect = tweak_data.gui.icons[weapon_icon].texture_rect,
			color = RaidGUIControlXPProgressBar.WEAPON_UNLOCK_ICON_COLOR
		}
		local icon = weapon_unlock:bitmap(icon_params)
		local panel_w = icon_w
		local panel_h = icon_h

		if number_of_weapon_unlocks > 1 then
			local weapon_unlock_amount_text_params = {
				name = "weapon_unlock_number_text",
				y = 0,
				x = 0,
				font = RaidGUIControlXPProgressBar.WEAPON_UNLOCK_TEXT_FONT,
				font_size = RaidGUIControlXPProgressBar.WEAPON_UNLOCK_TEXT_FONT_SIZE,
				text = tostring(number_of_weapon_unlocks) .. "X",
				color = RaidGUIControlXPProgressBar.WEAPON_UNLOCK_ICON_COLOR
			}
			local weapon_unlock_amount = weapon_unlock:text(weapon_unlock_amount_text_params)
			local _, _, w, h = weapon_unlock_amount:text_rect()

			weapon_unlock_amount:set_w(w)
			weapon_unlock_amount:set_h(h)
			weapon_unlock_amount:set_right(icon:right())

			panel_h = panel_h + h

			icon:set_center_y(panel_h / 2)
			weapon_unlock_amount:set_center_y(icon:bottom())
		end

		weapon_unlock:set_w(panel_w)
		weapon_unlock:set_h(panel_h)
		weapon_unlock:set_center_x(level_label_panel:w() / 2)
		weapon_unlock:set_center_y(level_label_panel:h() / 2)

		local unlocked = false

		if level <= self._current_level then
			weapon_unlock:set_alpha(1)

			unlocked = true
		end

		local weapon_unlock_icon = {
			icon = weapon_unlock,
			unlocked = unlocked
		}
		self._weapon_unlock_icons[level] = weapon_unlock_icon
	end

	if level_label ~= nil and weapon_unlock ~= nil then
		local label_x = (level_label_panel:w() - (level_label:w() + weapon_unlock:w() + RaidGUIControlXPProgressBar.WEAPON_UNLOCK_TEXT_PADDING_RIGHT)) / 2

		level_label:set_x(label_x)
		weapon_unlock:set_x(level_label:right() + RaidGUIControlXPProgressBar.WEAPON_UNLOCK_TEXT_PADDING_RIGHT)
	end

	return level_label_panel
end

function RaidGUIControlXPProgressBar:set_progress(progress, points_added_total)
	self._progress_bar:set_foreground_progress(self._progress_padding + progress * self._progress_multiplier)
	self._slider_pimples_panel:set_w((self._progress_padding + progress * self._progress_multiplier) * self._progress_bar:w())

	local right_edge_x = self._inner_panel:w() * progress

	self._new_xp_text:set_text("+" .. string.format("%d", points_added_total) .. self:translate("menu_label_xp", true))

	if self._new_xp_text:alpha() == 0 and points_added_total > 0 then
		self._new_xp_text:animate(callback(self, self, "_animate_fade_in_object"))
	end

	local _, _, w, _ = self._new_xp_text:text_rect()

	self._new_xp_text:set_w(w)
	self._new_xp_text:set_center_x(self._slider_pimples_panel:right())

	if self._inner_panel:w() < self._new_xp_text:right() then
		self._new_xp_text:set_right(self._inner_panel:w())
	end
end

function RaidGUIControlXPProgressBar:unlock_level(level)
	for i = self._current_level, level do
		if self._weapon_unlock_icons[i] then
			self._weapon_unlock_icons[i].icon:set_alpha(1)

			self._weapon_unlock_icons[i].unlocked = true
		end

		if self._level_pins[i] then
			self._level_pins[i]:set_color(RaidGUIControlXPProgressBar.SLIDER_PIN_COLOR_ACTIVE)
		end
	end

	self._current_level = level
	local level_cap = managers.experience:level_cap()

	if level == level_cap then
		return
	end

	local inner_x = -((self._bar_w - 2 * self._progress_padding) / (level_cap - 1)) * (level - 1)

	self._inner_panel:get_engine_panel():stop()
	self._inner_panel:get_engine_panel():animate(callback(self, self, "_animate_inner_panel_position"), inner_x)
end

function RaidGUIControlXPProgressBar:set_level(level)
	for i = 1, level do
		if self._weapon_unlock_icons[i] then
			self._weapon_unlock_icons[i].icon:set_alpha(1)

			self._weapon_unlock_icons[i].unlocked = true
		end

		if self._level_pins[i] then
			self._level_pins[i]:set_color(RaidGUIControlXPProgressBar.SLIDER_PIN_COLOR_ACTIVE)
		end
	end

	self._current_level = level
	local level_cap = managers.experience:level_cap()

	if level == level_cap then
		level = level - 1
	end

	local inner_x = -((self._bar_w - 2 * self._progress_padding) / (level_cap - 1)) * (level - 1)

	self._inner_panel:set_x(inner_x)
end

function RaidGUIControlXPProgressBar:hide()
	self._object:set_alpha(0)
end

function RaidGUIControlXPProgressBar:fade_in()
	self._object:get_engine_panel():animate(callback(self, self, "_animate_fade_in"))
end

function RaidGUIControlXPProgressBar:_animate_fade_in()
	local duration = 0.3
	local t = self._object:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)
	end

	self._object:set_alpha(1)
end

function RaidGUIControlXPProgressBar:_animate_fade_in_object(object)
	local duration = 0.3
	local t = object:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, duration)

		object:set_alpha(current_alpha)
	end

	object:set_alpha(1)
end

function RaidGUIControlXPProgressBar:_animate_inner_panel_position(panel, new_x)
	local duration = 0.7
	local t = 0
	local initial_position = panel:x()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_position = Easing.quartic_in_out(t, initial_position, new_x - initial_position, duration)

		panel:set_x(current_position)
	end

	panel:set_x(new_x)
end
