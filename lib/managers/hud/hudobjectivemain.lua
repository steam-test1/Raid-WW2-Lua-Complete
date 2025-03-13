HUDObjectiveMain = HUDObjectiveMain or class(HUDObjectiveSub)
HUDObjectiveMain.H = 48
HUDObjectiveMain.OBJECTIVE_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_22
HUDObjectiveMain.OBJECTIVE_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDObjectiveMain.OBJECTIVE_TEXT_PADDING_RIGHT = 15
HUDObjectiveMain.AMOUNT_BACKGROUND_ICON = "objective_progress_bg"
HUDObjectiveMain.AMOUNT_FILL_ICON = "objective_progress_fill"
HUDObjectiveMain.AMOUNT_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_20
HUDObjectiveMain.AMOUNT_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDObjectiveMain.TIMER_BACKGROUND_ICON = "player_panel_ai_downed_and_objective_countdown_bg"
HUDObjectiveMain.TIMER_FILL_ICON = "teammate_circle_fill_small"
HUDObjectiveMain.TIMER_SECONDS_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDObjectiveMain.TIMER_SECONDS_FONT_SIZE = tweak_data.gui.font_sizes.size_24

function HUDObjectiveMain:init(objectives_panel, active_objective)
	HUDObjectiveMain.super.init(self, objectives_panel, active_objective)
	self._objective_text:set_center_y(self._object:h() / 2)
	self:_create_timer()
	self:hide_timer()
	self:set_hidden()
end

function HUDObjectiveMain:_create_panel(objectives_panel)
	local panel_params = {
		valign = "top",
		name = "main_objective",
		halign = "scale",
		w = objectives_panel:w(),
		h = HUDObjectiveMain.H
	}
	self._object = objectives_panel:panel(panel_params)
end

function HUDObjectiveMain:_create_timer()
	local timer_panel_params = {
		valign = "center",
		name = "timer_panel",
		halign = "right",
		w = self._object:h(),
		h = self._object:h()
	}
	self._timer_panel = self._object:panel(timer_panel_params)

	self._timer_panel:set_x(self._object:w() + HUDObjectiveSub.OBJECTIVE_TEXT_PADDING_RIGHT)

	local timer_background_params = {
		name = "timer_background",
		texture = tweak_data.gui.icons[HUDObjectiveMain.TIMER_BACKGROUND_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDObjectiveMain.TIMER_BACKGROUND_ICON].texture_rect
	}
	local timer_background = self._timer_panel:bitmap(timer_background_params)

	timer_background:set_center_x(self._timer_panel:w() / 2)
	timer_background:set_center_y(self._timer_panel:h() / 2)

	local timer_static_fill_params = {
		alpha = 0,
		name = "timer_static_fill",
		texture = tweak_data.gui.icons[HUDObjectiveMain.TIMER_FILL_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDObjectiveMain.TIMER_FILL_ICON].texture_rect,
		layer = timer_background:layer() + 1
	}
	self._timer_static_fill = self._timer_panel:bitmap(timer_static_fill_params)

	self._timer_static_fill:set_center_x(self._timer_panel:w() / 2)
	self._timer_static_fill:set_center_y(self._timer_panel:h() / 2)

	local timer_fill_params = {
		name = "timer_fill",
		render_template = "VertexColorTexturedRadial",
		visible = false,
		texture = tweak_data.gui.icons[HUDObjectiveMain.TIMER_FILL_ICON].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDObjectiveMain.TIMER_FILL_ICON),
			0,
			-tweak_data.gui:icon_w(HUDObjectiveMain.TIMER_FILL_ICON),
			tweak_data.gui:icon_h(HUDObjectiveMain.TIMER_FILL_ICON)
		},
		w = tweak_data.gui:icon_w(HUDObjectiveMain.TIMER_FILL_ICON),
		h = tweak_data.gui:icon_h(HUDObjectiveMain.TIMER_FILL_ICON),
		layer = self._timer_static_fill:layer() + 1
	}
	self._timer_fill = self._timer_panel:bitmap(timer_fill_params)

	self._timer_fill:set_center_x(self._timer_panel:w() / 2)
	self._timer_fill:set_center_y(self._timer_panel:h() / 2)

	local timer_minutes_text_params = {
		valign = "center",
		visible = false,
		name = "minute_text",
		text = "00:00",
		vertical = "center",
		align = "center",
		halign = "center",
		font = HUDObjectiveMain.AMOUNT_TEXT_FONT,
		font_size = HUDObjectiveMain.AMOUNT_TEXT_FONT_SIZE,
		layer = self._timer_fill:layer() + 1
	}
	self._timer_text_minutes = self._timer_panel:text(timer_minutes_text_params)
	local _, _, w, h = self._timer_text_minutes:text_rect()

	self._timer_text_minutes:set_w(w + 10)
	self._timer_text_minutes:set_h(h)
	self._timer_text_minutes:set_center_x(self._timer_panel:w() / 2)
	self._timer_text_minutes:set_center_y(self._timer_panel:h() / 2)

	local timer_seconds_text_params = {
		valign = "center",
		visible = false,
		name = "seconds_text",
		text = "00",
		vertical = "center",
		align = "center",
		halign = "center",
		font = HUDObjectiveMain.TIMER_SECONDS_FONT,
		font_size = HUDObjectiveMain.TIMER_SECONDS_FONT_SIZE,
		layer = self._timer_fill:layer() + 1
	}
	self._timer_text_seconds = self._timer_panel:text(timer_seconds_text_params)
	local _, _, w, h = self._timer_text_seconds:text_rect()

	self._timer_text_seconds:set_w(w + 10)
	self._timer_text_seconds:set_h(h)
	self._timer_text_seconds:set_center_x(self._timer_panel:w() / 2)
	self._timer_text_seconds:set_center_y(self._timer_panel:h() / 2)
end

function HUDObjectiveMain:_create_checkbox()
end

function HUDObjectiveMain:show_timer()
	self._timer_panel:set_right(self._object:w())
	self._objective_text:set_right(self._object:w() - self._timer_panel:w() - HUDObjectiveSub.OBJECTIVE_TEXT_PADDING_RIGHT)
end

function HUDObjectiveMain:hide_timer()
	self._timer_panel:set_x(self._object:w() + HUDObjectiveSub.OBJECTIVE_TEXT_PADDING_RIGHT)

	if not self._amount_panel then
		self._objective_text:set_right(self._object:w())
	else
		self._objective_text:set_right(self._object:w() - self._timer_panel:w() - HUDObjectiveSub.OBJECTIVE_TEXT_PADDING_RIGHT)
	end
end

function HUDObjectiveMain:set_timer_value(current, total)
	local remaining = total - current
	local minutes_text = string.format("%02d", remaining / 60) .. ":" .. string.format("%02d", remaining % 60)

	self._timer_text_minutes:set_text(minutes_text)

	local seconds_text = string.format("%02d", remaining % 60)

	self._timer_text_seconds:set_text(seconds_text)

	local timer_current = current
	local timer_total = total

	if timer_total > 60 then
		timer_current = current - (total - 60)
		timer_total = 60
	end

	self._timer_fill:set_position_z(1 - timer_current / timer_total)

	if remaining < 61 and remaining > 60 then
		local current_alpha = Easing.quartic_out(61 - remaining, 0, 1, 1)

		if current_alpha < 0.05 then
			current_alpha = 0
		end

		self._timer_static_fill:set_alpha(current_alpha)
	end

	if remaining > 60 and not self._timer_text_minutes:visible() then
		self._timer_text_seconds:set_visible(false)
		self._timer_fill:set_visible(false)
		self._timer_text_minutes:set_visible(true)
	elseif remaining < 60 and not self._timer_text_seconds:visible() then
		self._timer_text_seconds:set_visible(true)
		self._timer_fill:set_visible(true)
		self._timer_text_minutes:set_visible(false)
		self._timer_static_fill:set_alpha(0)
	end
end
