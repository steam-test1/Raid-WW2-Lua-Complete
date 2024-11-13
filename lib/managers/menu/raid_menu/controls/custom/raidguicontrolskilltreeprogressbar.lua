RaidGUIControlSkilltreeProgressBar = RaidGUIControlSkilltreeProgressBar or class(RaidGUIControl)
RaidGUIControlSkilltreeProgressBar.DEFAULT_H = 96
RaidGUIControlSkilltreeProgressBar.PROGRESS_BAR_H = 24
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_PANEL_H = 36
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE = tweak_data.gui.font_sizes.dialg_title
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR_GREY = tweak_data.gui.colors.progress_bar_dot
RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON = "slider_mid_dot"
RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE = 8
RaidGUIControlSkilltreeProgressBar.MARKS_PER_LEVEL = 10
RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_ICON = "slider_pin"
RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_Y = 36
RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_COLOR_INACTIVE = tweak_data.gui.colors.raid_grey
RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_COLOR = tweak_data.gui.colors.raid_red

function RaidGUIControlSkilltreeProgressBar:init(parent, params)
	params.horizontal_padding = params.horizontal_padding or 0

	RaidGUIControlSkilltreeProgressBar.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSkilltreeProgressBar:init] Parameters not specified for the customization details")

		return
	end

	self._bar_w = self._params.bar_w or self._params.w - self._params.horizontal_padding * 2
	self._horizontal_padding = self._params.horizontal_padding or 0

	self:_create_panels()
	self:_create_progress_bar()
	self:_create_background()
	self:_create_slider_pimples()
	self:_create_level_labels()
	self:_create_level_marks_on_progress_bar()

	self._progress = params.initial_progress or 0

	self:set_level(params.initial_level or 1)
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
end

function RaidGUIControlSkilltreeProgressBar:_create_progress_bar()
	local progress_bar_params = {
		x = 0,
		w = nil,
		name = "progress_bar",
		center = "slider_large_center",
		right = "slider_large_right",
		left = "slider_large_left",
		h = nil,
		y = 0,
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
		x = nil,
		w = nil,
		name = "background_panel",
		layer = nil,
		h = nil,
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
		right = nil,
		w = nil,
		center = nil,
		color = nil,
		left = nil,
		y = 0,
		x = 0,
		h = nil,
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
		x = nil,
		w = nil,
		texture_rect = nil,
		name = "progress_line",
		texture = nil,
		halign = "right",
		h = nil,
		y = nil,
		x = self._background_panel:w() - tweak_data.gui:icon_w(line_texture),
		y = self._background_panel:h() - tweak_data.gui:icon_h(line_texture),
		w = tweak_data.gui:icon_w(line_texture),
		h = tweak_data.gui:icon_h(line_texture),
		texture = tweak_data.gui.icons[line_texture].texture,
		texture_rect = tweak_data.gui.icons[line_texture].texture_rect
	}
	self._progress_line = self._background_panel:image(progress_line_params)

	self._background_panel:set_y(128)
end

function RaidGUIControlSkilltreeProgressBar:_create_slider_pimples()
	local icon = RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_ICON
	local icon_w = tweak_data.gui:icon_w(icon)
	local icon_h = tweak_data.gui:icon_h(icon)
	self._slider_pimples_panel = self._object:panel({
		x = 0,
		w = nil,
		name = "slider_pimples_panel",
		layer = nil,
		h = nil,
		y = nil,
		y = RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_Y,
		w = self._object:w(),
		h = icon_h,
		layer = self._progress_bar:layer() + 10
	})
	self._current_level_pimple = self._slider_pimples_panel:image({
		x = nil,
		name = "slider_pimple_current",
		texture_rect = nil,
		texture = nil,
		color = nil,
		x = self._params.horizontal_padding - icon_w / 2,
		color = RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_COLOR,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	})
	self._next_level_pimple = self._slider_pimples_panel:image({
		x = nil,
		name = "slider_pimple_next",
		texture_rect = nil,
		texture = nil,
		color = nil,
		x = self._progress_bar:w() - self._params.horizontal_padding - icon_w / 2,
		color = RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_COLOR_INACTIVE,
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	})
end

function RaidGUIControlSkilltreeProgressBar:_create_level_marks_on_progress_bar()
	self._level_marks_panel = self._object:panel({
		x = 0,
		w = nil,
		name = "level_marks_panel",
		h = nil,
		y = 0,
		w = self._object:w(),
		h = self._progress_bar:h()
	})

	self._level_marks_panel:set_center_y(self._progress_bar:center_y())

	local icon = RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON

	for i = 2, RaidGUIControlSkilltreeProgressBar.MARKS_PER_LEVEL do
		local level_mark_params = {
			x = nil,
			w = nil,
			texture_rect = nil,
			color = nil,
			texture = nil,
			name = nil,
			h = nil,
			y = nil,
			name = "level_label_" .. tostring(i),
			x = self._params.horizontal_padding + (i - 1) * self._bar_w / RaidGUIControlSkilltreeProgressBar.MARKS_PER_LEVEL - RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE / 2,
			y = self._level_marks_panel:h() / 2 - RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE / 2,
			w = RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE,
			h = RaidGUIControlSkilltreeProgressBar.LEVEL_MARK_ICON_SIZE,
			color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR_GREY,
			texture = tweak_data.gui.icons[icon].texture,
			texture_rect = tweak_data.gui.icons[icon].texture_rect
		}

		self._level_marks_panel:image(level_mark_params)
	end
end

function RaidGUIControlSkilltreeProgressBar:_create_level_labels()
	self._level_labels_panel = self._object:panel({
		w = nil,
		name = "level_labels_panel",
		h = nil,
		w = self._object:w(),
		h = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_PANEL_H
	})
	self._current_level_label = self._level_labels_panel:text({
		font = nil,
		name = "level_label_curent",
		color = nil,
		text = "1",
		h = nil,
		font_size = nil,
		h = self._level_labels_panel:h(),
		font = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT,
		font_size = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE,
		color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR
	})
	self._next_level_label = self._level_labels_panel:text({
		font = nil,
		name = "level_label_next",
		color = nil,
		text = "2",
		h = nil,
		font_size = nil,
		h = self._level_labels_panel:h(),
		font = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT,
		font_size = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE,
		color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR
	})
	self._experience_label = self._level_labels_panel:text({
		align = "center",
		name = "level_label_xp",
		font = nil,
		text = "100 XP UNTIL NEXT LEVEL",
		color = nil,
		h = nil,
		font_size = nil,
		h = self._level_labels_panel:h(),
		font = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT,
		font_size = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_FONT_SIZE,
		color = RaidGUIControlSkilltreeProgressBar.LEVEL_LABELS_COLOR
	})
end

function RaidGUIControlSkilltreeProgressBar:update_progress(level)
	local level_cap = managers.experience:level_cap()
	local current_level = managers.experience:current_level()
	local xp_progress = 1.2
	local xp_string = utf8.to_upper(managers.localization:text("menu_skills_max_level"))

	if current_level < level_cap then
		local next_level_data = managers.experience:next_level_data()
		local xp_formatted = managers.experience:experience_string(next_level_data.points - next_level_data.current_points)
		xp_progress = next_level_data.current_points / next_level_data.points
		xp_string = utf8.to_upper(managers.localization:text("menu_skills_next_level", {
			XP = nil,
			XP = tostring(xp_formatted)
		}))
	end

	self:set_text(xp_string)
	self:set_level(current_level)
	self:set_progress(xp_progress)
end

function RaidGUIControlSkilltreeProgressBar:set_text(text)
	self._experience_label:set_text(text)
end

function RaidGUIControlSkilltreeProgressBar:set_progress(progress)
	self._progress_bar:set_foreground_progress(self._progress_padding + progress * self._progress_multiplier)
end

function RaidGUIControlSkilltreeProgressBar:set_level(level)
	self._current_level = level
	local level_cap = managers.experience:level_cap()
	local current_level = math.min(self._current_level, level_cap - 1)
	local next_level = math.min(current_level + 1, level_cap)

	self._current_level_label:set_text(current_level)

	local w = select(3, self._current_level_label:text_rect())

	self._current_level_label:set_w(w)
	self._current_level_label:set_center_x(self._params.horizontal_padding)
	self._next_level_label:set_text(next_level)

	w = select(3, self._next_level_label:text_rect())

	self._next_level_label:set_w(w)
	self._next_level_label:set_center_x(self._progress_bar:w() - self._params.horizontal_padding)

	local pimple_color = level == level_cap and RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_COLOR or RaidGUIControlSkilltreeProgressBar.SLIDER_PIN_COLOR_INACTIVE

	self._next_level_pimple:set_color(pimple_color)
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
