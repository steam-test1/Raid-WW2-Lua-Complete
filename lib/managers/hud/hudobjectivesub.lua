HUDObjectiveSub = HUDObjectiveSub or class(HUDObjectiveBase)
HUDObjectiveSub.H = 48
HUDObjectiveSub.PERCENTAGE_AMOUNT_THRESHOLD = 50
HUDObjectiveSub.OBJECTIVE_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_22
HUDObjectiveSub.OBJECTIVE_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDObjectiveSub.OBJECTIVE_TEXT_PADDING_RIGHT = 15
HUDObjectiveSub.AMOUNT_BACKGROUND_ICON = "objective_progress_bg"
HUDObjectiveSub.AMOUNT_FILL_ICON = "objective_progress_fill"
HUDObjectiveSub.AMOUNT_TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_20
HUDObjectiveSub.AMOUNT_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDObjectiveSub.CHECKBOX_UNCHECKED_ICON = "objective_unchecked"
HUDObjectiveSub.CHECKBOX_CHECKED_ICON = "objective_checked"

function HUDObjectiveSub:init(objectives_panel, active_objective)
	self._objective = active_objective
	self._id = active_objective.id

	self:_create_panel(objectives_panel)
	self:_create_objective_text()
	self:_create_checkbox()

	if active_objective.amount then
		self:_create_amount()
		self:set_total_amount(active_objective.amount)
		self:set_current_amount(active_objective.current_amount)

		if self._checkbox_panel then
			self._checkbox_panel:set_visible(false)
		end
	end

	self:set_hidden()
end

function HUDObjectiveSub:_create_panel(objectives_panel)
	local panel_params = {
		name = "sub_objective",
		halign = "scale",
		valign = "top",
		w = objectives_panel:w(),
		h = HUDObjectiveSub.H
	}
	self._object = objectives_panel:panel(panel_params)
end

function HUDObjectiveSub:_create_objective_text()
	local objective_text_params = {
		name = "objective_text",
		vertical = "center",
		halign = "right",
		align = "right",
		y = 0,
		x = 0,
		valign = "center",
		font = HUDObjectiveSub.OBJECTIVE_TEXT_FONT,
		font_size = HUDObjectiveSub.OBJECTIVE_TEXT_FONT_SIZE,
		text = utf8.to_upper(self._objective.text)
	}
	self._objective_text = self._object:text(objective_text_params)

	self._objective_text:set_center_y(self._object:h() / 2)
end

function HUDObjectiveSub:_create_amount()
	local amount_panel_params = {
		name = "amount_panel",
		halign = "right",
		valign = "center",
		w = self._object:h(),
		h = self._object:h()
	}
	self._amount_panel = self._object:panel(amount_panel_params)

	self._amount_panel:set_right(self._object:w())
	self._amount_panel:set_center_y(self._object:h() / 2)

	local amount_progress_background_params = {
		name = "amount_progress_background",
		texture = tweak_data.gui.icons[HUDObjectiveSub.AMOUNT_BACKGROUND_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDObjectiveSub.AMOUNT_BACKGROUND_ICON].texture_rect
	}
	local amount_progress_background = self._amount_panel:bitmap(amount_progress_background_params)

	amount_progress_background:set_center_x(self._amount_panel:w() / 2)
	amount_progress_background:set_center_y(self._amount_panel:h() / 2)

	local amount_progress_fill_params = {
		name = "amount_progress_fill",
		render_template = "VertexColorTexturedRadial",
		texture = tweak_data.gui.icons[HUDObjectiveSub.AMOUNT_FILL_ICON].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDObjectiveSub.AMOUNT_FILL_ICON),
			0,
			-tweak_data.gui:icon_w(HUDObjectiveSub.AMOUNT_FILL_ICON),
			tweak_data.gui:icon_h(HUDObjectiveSub.AMOUNT_FILL_ICON)
		},
		w = tweak_data.gui:icon_w(HUDObjectiveSub.AMOUNT_FILL_ICON),
		h = tweak_data.gui:icon_h(HUDObjectiveSub.AMOUNT_FILL_ICON),
		layer = amount_progress_background:layer() + 1
	}
	self._amount_progress_fill = self._amount_panel:bitmap(amount_progress_fill_params)

	self._amount_progress_fill:set_center_x(self._amount_panel:w() / 2)
	self._amount_progress_fill:set_center_y(self._amount_panel:h() / 2)

	local current_amount_text_params = {
		text = "00",
		vertical = "center",
		name = "current_amount_text",
		align = "center",
		font = HUDObjectiveSub.AMOUNT_TEXT_FONT,
		font_size = HUDObjectiveSub.AMOUNT_TEXT_FONT_SIZE
	}
	self._current_amount_text = self._amount_panel:text(current_amount_text_params)
	local _, _, w, h = self._current_amount_text:text_rect()

	self._current_amount_text:set_w(w)
	self._current_amount_text:set_h(h)
	self._current_amount_text:set_x(5)
	self._current_amount_text:set_center_y(self._amount_panel:h() / 2)

	local slash_params = {
		text = "/",
		vertical = "center",
		name = "slash",
		align = "center",
		font = HUDObjectiveSub.AMOUNT_TEXT_FONT,
		font_size = HUDObjectiveSub.AMOUNT_TEXT_FONT_SIZE
	}
	local slash = self._amount_panel:text(slash_params)
	local _, _, w, h = slash:text_rect()

	slash:set_w(2 * w)
	slash:set_h(h)
	slash:set_center_x(self._amount_panel:w() / 2)
	slash:set_center_y(self._amount_panel:h() / 2)

	local total_amount_text_params = {
		text = "00",
		vertical = "center",
		name = "total_amount_text",
		align = "center",
		font = HUDObjectiveSub.AMOUNT_TEXT_FONT,
		font_size = HUDObjectiveSub.AMOUNT_TEXT_FONT_SIZE
	}
	self._total_amount_text = self._amount_panel:text(total_amount_text_params)
	local _, _, w, h = self._total_amount_text:text_rect()

	self._total_amount_text:set_w(w)
	self._total_amount_text:set_h(h)
	self._total_amount_text:set_right(self._amount_panel:w() - 7)
	self._total_amount_text:set_center_y(self._amount_panel:h() / 2)

	local percentage_amount_text_params = {
		text = "00%",
		align = "center",
		vertical = "center",
		name = "percentage_amount_text",
		w = self._amount_panel:w(),
		h = self._amount_panel:h(),
		font = HUDObjectiveSub.AMOUNT_TEXT_FONT,
		font_size = HUDObjectiveSub.AMOUNT_TEXT_FONT_SIZE
	}
	self._percentage_amount_text = self._amount_panel:text(percentage_amount_text_params)
end

function HUDObjectiveSub:_create_checkbox()
	local checkbox_panel_params = {
		name = "checkbox_panel",
		halign = "right",
		valign = "center",
		w = self._object:h(),
		h = self._object:h()
	}
	self._checkbox_panel = self._object:panel(checkbox_panel_params)

	self._checkbox_panel:set_right(self._object:w())
	self._checkbox_panel:set_center_y(self._object:h() / 2)

	local checkbox_unchecked_params = {
		name = "checkbox_unchecked",
		texture = tweak_data.gui.icons[HUDObjectiveSub.CHECKBOX_UNCHECKED_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDObjectiveSub.CHECKBOX_UNCHECKED_ICON].texture_rect
	}
	local checkbox_unchecked = self._checkbox_panel:bitmap(checkbox_unchecked_params)

	checkbox_unchecked:set_center_x(self._checkbox_panel:w() / 2)
	checkbox_unchecked:set_center_y(self._checkbox_panel:h() / 2)

	local checkbox_checked_params = {
		name = "checkbox_checked",
		visible = false,
		texture = tweak_data.gui.icons[HUDObjectiveSub.CHECKBOX_CHECKED_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDObjectiveSub.CHECKBOX_CHECKED_ICON].texture_rect
	}
	local checkbox_checked = self._checkbox_panel:bitmap(checkbox_checked_params)

	checkbox_checked:set_center_x(self._checkbox_panel:w() / 2)
	checkbox_checked:set_center_y(self._checkbox_panel:h() / 2)
	self._objective_text:set_right(self._object:w() - self._checkbox_panel:w() - HUDObjectiveSub.OBJECTIVE_TEXT_PADDING_RIGHT)
end

function HUDObjectiveSub:set_current_amount(current_amount)
	self._current_amount = current_amount
	local amount_string = tostring(current_amount)

	if self._total_amount >= 10 then
		amount_string = string.format("%02d", current_amount)
	elseif self._total_amount == 0 then
		Application:error("[HUDObjectiveSub:set_current_amount] Divison by zero! self._total_amount=0")

		return
	end

	local amount_percentage = self._current_amount / self._total_amount * 100

	self._percentage_amount_text:set_text(string.format("%.0f%%", amount_percentage))
	self._current_amount_text:set_text(amount_string)
	self._amount_progress_fill:set_position_z(self._current_amount / self._total_amount)
end

function HUDObjectiveSub:set_total_amount(total_amount)
	self._total_amount = total_amount

	if HUDObjectiveSub.PERCENTAGE_AMOUNT_THRESHOLD <= self._total_amount then
		self._current_amount_text:set_visible(false)
		self._amount_panel:child("slash"):set_visible(false)
		self._total_amount_text:set_visible(false)
		self._percentage_amount_text:set_visible(true)
	else
		self._current_amount_text:set_visible(true)
		self._amount_panel:child("slash"):set_visible(true)
		self._total_amount_text:set_visible(true)
		self._percentage_amount_text:set_visible(false)
	end

	self._total_amount_text:set_text(tostring(total_amount))
	self:set_current_amount(self._current_amount or 0)
end

function HUDObjectiveSub:set_objective_text(text)
	self._objective_text:set_text(utf8.to_upper(text))
end

function HUDObjectiveSub:complete()
	self._objective_text:set_right(self._object:w() - self._checkbox_panel:w() - HUDObjectiveSub.OBJECTIVE_TEXT_PADDING_RIGHT)
	self._checkbox_panel:child("checkbox_unchecked"):set_visible(false)
	self._checkbox_panel:child("checkbox_checked"):set_visible(true)
	self._checkbox_panel:set_visible(true)

	if self._amount_panel then
		self._amount_panel:set_visible(false)
	end
end
