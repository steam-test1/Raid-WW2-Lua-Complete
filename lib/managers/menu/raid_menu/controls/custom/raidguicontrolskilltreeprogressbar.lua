RaidGUIControlSkilltreeProgressBar = RaidGUIControlSkilltreeProgressBar or class(RaidGUIControl)
RaidGUIControlSkilltreeProgressBar.DEFAULT_H = 96
RaidGUIControlSkilltreeProgressBar.PROGRESS_BAR_H = 32
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_PANEL_H = 64
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE = tweak_data.gui.font_sizes.size_46
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_W = 100
RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICONS_PANEL_H = 32
RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON = "icon_weapon_unlocked"
RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_TEXT_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_18
RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_TEXT_PADDING_RIGHT = 6
RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON = "slider_mid_dot"
RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE = 8
RaidGUIControlSkilltreeProgressBar.SLIDER_PIMPLE_ICON = "slider_pimple"
RaidGUIControlSkilltreeProgressBar.SLIDER_PIMPLE_COLOR = tweak_data.gui.colors.raid_red

function RaidGUIControlSkilltreeProgressBar:init(parent, params)
	params.horizontal_padding = params.horizontal_padding or 0

	RaidGUIControlSkilltreeProgressBar.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSkilltreeProgressBar:init] Parameters not specified for the customization details")

		return
	end

	self:_create_panels()

	self._bar_w = self._inner_panel:w()
	self._current_level = params.initial_level or 1
	self._horizontal_padding = self._params.horizontal_padding or 0

	self:_create_progress_bar()
	self:_create_background()
	self:_create_slider_pimples()
	self:_create_level_marks_on_progress_bar()
	self:_create_level_and_weapons_info()

	self._progress = params.initial_progress or 0

	self:set_progress(self._progress)
end

function RaidGUIControlSkilltreeProgressBar:close()
end

function RaidGUIControlSkilltreeProgressBar:_create_panels()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w
	control_params.h = self._params.h or RaidGUIControlSkilltreeProgressBar.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
	control_params.x = self._params.horizontal_padding
	control_params.y = 0
	control_params.w = self._params.bar_w or control_params.w - self._params.horizontal_padding * 2
	control_params.h = self._object:h()
	self._inner_panel = self._object:panel(control_params)
end

function RaidGUIControlSkilltreeProgressBar:_create_progress_bar()
	local progress_bar_params = {
		left = "slider_large_left",
		name = "progress_bar",
		y = 0,
		center = "slider_large_center",
		x = 0,
		right = "slider_large_right",
		w = self._bar_w + self._horizontal_padding * 2,
		h = self._params.progress_bar_h or RaidGUIControlSkilltreeProgressBar.PROGRESS_BAR_H
	}
	self._progress_bar = self._object:progress_bar_simple(progress_bar_params)

	self._progress_bar:set_bottom(self._object:h())

	self._progress_padding = self._horizontal_padding / self._progress_bar:w()
	self._progress_multiplier = self._bar_w / self._progress_bar:w()
end

function RaidGUIControlSkilltreeProgressBar:_create_background()
	local background_panel_params = {
		name = "background_panel",
		y = 0,
		x = self._progress_bar:x(),
		w = self._progress_bar:w(),
		h = self._object:h() - self._progress_bar:h(),
		layer = self._progress_bar:layer() - 5
	}
	self._background_panel = self._object:panel(background_panel_params)
	local texture_center = "skl_level_bg"
	local texture_left = "skl_level_bg_left"
	local texture_right = "skl_level_bg_right"
	local background_params = {
		name = "background",
		y = 0,
		x = 0,
		w = self._background_panel:w(),
		h = tweak_data.gui:icon_h(texture_center),
		left = texture_left,
		center = texture_center,
		right = texture_right,
		color = Color.white
	}
	self._background = self._background_panel:three_cut_bitmap(background_params)
	local line_texture = "skl_bg_vline"
	local progress_line_params = {
		name = "progress_line",
		halign = "right",
		x = self._background_panel:w() - tweak_data.gui:icon_w(line_texture),
		y = self._background_panel:h() - tweak_data.gui:icon_h(line_texture),
		w = tweak_data.gui:icon_w(line_texture),
		h = tweak_data.gui:icon_h(line_texture),
		texture = tweak_data.gui.icons[line_texture].texture,
		texture_rect = tweak_data.gui.icons[line_texture].texture_rect
	}
	self._progress_line = self._background_panel:image(progress_line_params)
end

function RaidGUIControlSkilltreeProgressBar:_create_slider_pimples()
	local icon = RaidGUIControlSkilltreeProgressBar.SLIDER_PIMPLE_ICON
	local icon_w = tweak_data.gui:icon_w(icon)
	local icon_h = tweak_data.gui:icon_h(icon)
	local slider_pimples_panel_params = {
		name = "slider_pimples_panel",
		x = 0,
		y = self._progress_bar:y() - icon_h,
		w = self._object:w(),
		h = icon_h,
		layer = self._progress_bar:layer() + 5
	}
	self._slider_pimples_panel = self._object:panel(slider_pimples_panel_params)
	local current_level = 1
	local level_cap = managers.experience:level_cap()
	local character_class = managers.skilltree:get_character_profile_class()
	local weapon_unlock_progression = tweak_data.skilltree.automatic_unlock_progressions[character_class]

	while current_level <= level_cap do
		if current_level == 1 or current_level % 5 == 0 or weapon_unlock_progression[current_level] then
			local level_mark_params = {
				y = 0,
				name = "slider_pimple_" .. current_level,
				x = self._params.horizontal_padding + (current_level - 1) * self._bar_w / (level_cap - 1) - icon_w / 2,
				w = icon_w,
				h = icon_h,
				color = RaidGUIControlSkilltreeProgressBar.SLIDER_PIMPLE_COLOR,
				texture = tweak_data.gui.icons[icon].texture,
				texture_rect = tweak_data.gui.icons[icon].texture_rect
			}
			local level_mark = self._slider_pimples_panel:image(level_mark_params)
		end

		current_level = current_level + 1
	end
end

function RaidGUIControlSkilltreeProgressBar:_create_level_marks_on_progress_bar()
	local level_marks_panel_params = {
		name = "level_marks_panel",
		y = 0,
		x = 0,
		w = self._object:w(),
		h = self._progress_bar:h()
	}
	self._level_marks_panel = self._object:panel(level_marks_panel_params)

	self._level_marks_panel:set_center_y(self._progress_bar:center_y())

	local current_level = 1
	local level_cap = managers.experience:level_cap()
	self._level_marks = {}
	local icon = RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON

	while current_level <= level_cap do
		local level_mark_params = {
			name = "level_label_" .. current_level,
			x = self._params.horizontal_padding + (current_level - 1) * self._bar_w / (level_cap - 1) - RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE / 2,
			y = self._level_marks_panel:h() / 2 - RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE / 2,
			w = RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE,
			h = RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE,
			color = tweak_data.gui.colors.progress_bar_dot,
			texture = tweak_data.gui.icons[icon].texture,
			texture_rect = tweak_data.gui.icons[icon].texture_rect
		}
		local level_mark = self._level_marks_panel:image(level_mark_params)

		table.insert(self._level_marks, level_mark)

		current_level = current_level + 1
	end
end

function RaidGUIControlSkilltreeProgressBar:_create_level_and_weapons_info()
	local level_labels_panel_params = {
		name = "level_labels_panel",
		y = 0,
		x = 0,
		w = self._object:w(),
		h = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_PANEL_H - self._slider_pimples_panel:h()
	}
	self._level_labels_panel = self._object:panel(level_labels_panel_params)

	self._level_labels_panel:set_bottom(self._slider_pimples_panel:y())

	self._level_labels = {}
	self._weapon_unlock_icons = {}
	local character_class = managers.skilltree:get_character_profile_class()
	local weapon_unlock_progression = tweak_data.skilltree.automatic_unlock_progressions[character_class]
	local level_cap = managers.experience:level_cap()
	local current_level = 1

	while level_cap >= current_level do
		local draw_label = current_level == 1 or current_level % 5 == 0
		local number_of_weapon_unlocks = weapon_unlock_progression[current_level] and weapon_unlock_progression[current_level].weapons and #weapon_unlock_progression[current_level].weapons or 0

		if draw_label or number_of_weapon_unlocks then
			local level_label = self:_create_label_for_level(current_level, draw_label, number_of_weapon_unlocks)

			level_label:set_center_x(self._horizontal_padding + (current_level - 1) * self._bar_w / (level_cap - 1))
			table.insert(self._level_labels, level_label)
		end

		current_level = current_level + 1
	end
end

function RaidGUIControlSkilltreeProgressBar:_create_label_for_level(level, draw_level_label, number_of_weapon_unlocks)
	local level_label_panel_params = {
		y = 0,
		x = 0,
		name = "level_" .. tostring(level) .. "_label_panel",
		w = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_W,
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
			font = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT,
			font_size = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE,
			text = tostring(level),
			color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR
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
		local weapon_icon = RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON
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
			color = RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON_COLOR
		}
		local icon = weapon_unlock:bitmap(icon_params)
		local panel_w = icon_w
		local panel_h = icon_h

		if number_of_weapon_unlocks > 1 then
			local weapon_unlock_amount_text_params = {
				name = "weapon_unlock_number_text",
				y = 0,
				x = 0,
				font = RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_TEXT_FONT,
				font_size = RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_TEXT_FONT_SIZE,
				text = tostring(number_of_weapon_unlocks) .. "X",
				color = RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON_COLOR
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
		local label_x = (level_label_panel:w() - (level_label:w() + weapon_unlock:w() + RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_TEXT_PADDING_RIGHT)) / 2

		level_label:set_x(label_x)
		weapon_unlock:set_x(level_label:right() + RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_TEXT_PADDING_RIGHT)
	end

	return level_label_panel
end

function RaidGUIControlSkilltreeProgressBar:_create_level_labels()
	local level_labels_panel_params = {
		name = "level_labels_panel",
		y = 0,
		x = 0,
		w = self._bar_w,
		h = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_PANEL_H
	}
	self._level_labels_panel = self._inner_panel:panel(level_labels_panel_params)
	self._level_labels = {}
	local level_label_params = {
		vertical = "center",
		name = "level_label_1",
		align = "left",
		y = 0,
		x = 0,
		w = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_W,
		h = self._level_labels_panel:h(),
		font = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT,
		font_size = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE,
		text = self:translate("menu_level_label_shorthand", true) .. " 1",
		color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR
	}
	local level_label = self._level_labels_panel:text(level_label_params)

	table.insert(self._level_labels, level_label)

	local level_cap = managers.experience:level_cap()
	local current_level = 5

	while level_cap > current_level do
		level_label_params = {
			vertical = "center",
			align = "center",
			y = 0,
			name = "level_label_" .. current_level,
			x = (current_level - 1) * self._bar_w / (level_cap - 1) - RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_W / 2,
			w = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_W,
			h = self._level_labels_panel:h(),
			font = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT,
			font_size = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE,
			text = tostring(current_level),
			color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR
		}
		level_label = self._level_labels_panel:text(level_label_params)

		table.insert(self._level_labels, level_label)

		current_level = current_level + 5
	end

	level_label_params = {
		vertical = "center",
		align = "right",
		y = 0,
		name = "level_label_" .. tostring(level_cap),
		x = self._bar_w - RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_W,
		w = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_W,
		h = self._level_labels_panel:h(),
		font = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT,
		font_size = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE,
		text = self:translate("menu_level_label_shorthand", true) .. " " .. tostring(level_cap),
		color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR
	}
	level_label = self._level_labels_panel:text(level_label_params)

	table.insert(self._level_labels, level_label)
end

function RaidGUIControlSkilltreeProgressBar:_create_weapon_unlock_icons()
	local weapon_unlock_icons_panel_params = {
		name = "weapon_unlock_icons_panel",
		x = 0,
		y = self._object:h() - RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICONS_PANEL_H,
		w = self._bar_w,
		h = RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICONS_PANEL_H
	}
	self._weapon_unlock_icons_panel = self._inner_panel:panel(weapon_unlock_icons_panel_params)
	local weapon_icon = tweak_data.gui.icons[RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON]
	local icon_h = self._weapon_unlock_icons_panel:h()
	local icon_w = icon_h * tweak_data.gui:icon_w(RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON) / tweak_data.gui:icon_h(RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON)
	self._weapon_unlock_icons = {}
	local character_class = managers.skilltree:get_character_profile_class()
	local weapon_unlock_progression = tweak_data.skilltree.automatic_unlock_progressions[character_class]
	local level_cap = managers.experience:level_cap()

	for level, weapons in pairs(weapon_unlock_progression) do
		local icon_x = (level - 1) * self._bar_w / (level_cap - 1) - icon_w / 2

		if icon_x < 0 then
			icon_x = 0
		elseif self._bar_w < icon_x + icon_w then
			icon_x = self._bar_w - icon_w
		end

		local icon_params = {
			alpha = 0.4,
			y = 0,
			name = "weapon_unlock_icon_" .. tostring(level),
			x = icon_x,
			w = icon_w,
			h = icon_h,
			texture = tweak_data.gui.icons[RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON].texture,
			texture_rect = tweak_data.gui.icons[RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON].texture_rect,
			color = RaidGUIControlSkilltreeProgressBar.WEAPON_UNLOCK_ICON_COLOR
		}
		local icon = self._weapon_unlock_icons_panel:bitmap(icon_params)
		local unlocked = false

		if level <= self._current_level then
			icon:set_alpha(1)

			unlocked = true
		end

		local weapon_unlock_icon = {
			icon = icon,
			unlocked = unlocked
		}
		self._weapon_unlock_icons[level] = weapon_unlock_icon
	end
end

function RaidGUIControlSkilltreeProgressBar:set_progress(progress)
	self._progress_bar:set_foreground_progress(self._progress_padding + progress * self._progress_multiplier)
	self._slider_pimples_panel:set_w((self._progress_padding + progress * self._progress_multiplier) * self._progress_bar:w())
	self._background_panel:set_w((self._progress_padding + progress * self._progress_multiplier) * self._progress_bar:w())

	local right_edge_x = self._inner_panel:w() * progress

	if self._object:w() < self._inner_panel:w() and right_edge_x > self._object:w() * 0.7 then
		local x = -(right_edge_x - self._object:w() * 0.7)

		if x < -(self._inner_panel:w() - self._object:w()) then
			x = -(self._inner_panel:w() - self._object:w())
		end

		self._inner_panel:set_x(x)
	end
end

function RaidGUIControlSkilltreeProgressBar:unlock_level(level)
	for i = self._current_level, level do
		if self._weapon_unlock_icons[i] then
			self._weapon_unlock_icons[i].icon:set_alpha(1)

			self._weapon_unlock_icons[i].unlocked = true
		end
	end

	self._current_level = level
end

function RaidGUIControlSkilltreeProgressBar:set_level(level)
	for i = 1, level do
		if self._weapon_unlock_icons[i] then
			self._weapon_unlock_icons[i].icon:set_alpha(1)

			self._weapon_unlock_icons[i].unlocked = true
		end
	end

	self._current_level = level
end

function RaidGUIControlSkilltreeProgressBar:hide()
	self._object:set_alpha(0)
end

function RaidGUIControlSkilltreeProgressBar:fade_in()
	self._object:get_engine_panel():animate(callback(self, self, "_animate_fade_in"))
end

function RaidGUIControlSkilltreeProgressBar:_animate_fade_in()
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
