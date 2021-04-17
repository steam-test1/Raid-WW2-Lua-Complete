HUDBigPrompt = HUDBigPrompt or class()
HUDBigPrompt.W = 416
HUDBigPrompt.H = 96
HUDBigPrompt.TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDBigPrompt.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDBigPrompt.DEFAULT_TEXT_COLOR = tweak_data.gui.colors.light_grey
HUDBigPrompt.DEFAULT_BACKGROUND = "backgrounds_equipment_panel_msg"

-- Lines 12-16
function HUDBigPrompt:init(hud)
	self:_create_panel(hud)
	self:_create_background()
	self:_create_text()
end

-- Lines 18-26
function HUDBigPrompt:_create_panel(hud)
	local panel_params = {
		name = "big_prompt_panel",
		halign = "center",
		valign = "center",
		w = HUDBigPrompt.W,
		h = HUDBigPrompt.H
	}
	self._object = hud.panel:panel(panel_params)
end

-- Lines 28-39
function HUDBigPrompt:_create_background()
	local background_params = {
		name = "big_prompt_background",
		layer = 1,
		alpha = 0,
		texture = tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture,
		texture_rect = tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture_rect
	}
	self._background = self._object:bitmap(background_params)

	self._background:set_center_x(self._object:w() / 2)
	self._background:set_center_y(self._object:h() / 2)
end

-- Lines 41-55
function HUDBigPrompt:_create_text()
	local text_params = {
		vertical = "center",
		name = "big_prompt_text",
		align = "center",
		alpha = 0,
		text = "",
		halign = "scale",
		valign = "scale",
		w = self._object:w(),
		h = self._object:h(),
		font = HUDBigPrompt.TEXT_FONT,
		font_size = HUDBigPrompt.TEXT_FONT_SIZE,
		layer = self._background:layer() + 1
	}
	self._text = self._object:text(text_params)
end

-- Lines 57-73
function HUDBigPrompt:show_prompt(params)
	if self._active_id == params.id then
		if params.duration then
			managers.queued_tasks:unqueue("HUDBigPrompt:hide")
			managers.queued_tasks:queue("HUDBigPrompt:hide", self.hide_prompt, self, {
				params.id
			}, params.duration, nil, true)
		end

		return
	end

	self._text:stop()
	self._text:animate(callback(self, self, "_animate_change_prompt"), params.text, params.id, params.text_color, params.background)

	if params.duration then
		managers.queued_tasks:queue("HUDBigPrompt:hide", self.hide_prompt, self, {
			params.id
		}, params.duration, nil, true)
	end
end

-- Lines 75-85
function HUDBigPrompt:hide_prompt(id)
	self._text:stop()
	self._text:animate(callback(self, self, "_animate_hide"))

	self._active_id = nil
end

-- Lines 87-89
function HUDBigPrompt:set_x(x)
	self._object:set_x(x)
end

-- Lines 91-93
function HUDBigPrompt:set_y(y)
	self._object:set_y(y)
end

-- Lines 95-97
function HUDBigPrompt:w()
	return self._object:w()
end

-- Lines 99-101
function HUDBigPrompt:h()
	return self._object:h()
end

-- Lines 103-156
function HUDBigPrompt:_animate_change_prompt(text_control, text, id, text_color, background)
	local fade_out_duration = 0.2
	local fade_in_duration = 0.3
	local t = (1 - self._text:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._text:set_alpha(current_alpha)
		self._background:set_alpha(current_alpha)
	end

	self._text:set_alpha(0)
	self._background:set_alpha(0)

	if self._hidden_id == id then
		self._hidden_id = nil

		return
	end

	self._text:set_text(text)

	if text_color then
		self._text:set_color(text_color)
	else
		self._text:set_color(HUDBigPrompt.DEFAULT_TEXT_COLOR)
	end

	if background then
		self._background:set_image(tweak_data.gui.icons[background].texture)
		self._background:set_texture_rect(unpack(tweak_data.gui.icons[background].texture_rect))
	else
		self._background:set_image(tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture)
		self._background:set_texture_rect(unpack(tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture_rect))
	end

	self._background:set_center_x(self._object:w() / 2)
	self._background:set_center_y(self._object:h() / 2)

	self._active_id = id
	self._hidden_id = nil
	t = 0

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_out_duration)

		self._text:set_alpha(current_alpha)
		self._background:set_alpha(current_alpha)
	end

	self._text:set_alpha(1)
	self._background:set_alpha(1)
end

-- Lines 158-173
function HUDBigPrompt:_animate_hide()
	local fade_out_duration = 0.2
	local t = (1 - self._text:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._text:set_alpha(current_alpha)
		self._background:set_alpha(current_alpha)
	end

	self._text:set_alpha(0)
	self._background:set_alpha(0)
end
