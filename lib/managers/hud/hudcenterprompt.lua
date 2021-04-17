HUDCenterPrompt = HUDCenterPrompt or class()
HUDCenterPrompt.W = 320
HUDCenterPrompt.H = 96
HUDCenterPrompt.TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDCenterPrompt.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_24

-- Lines 9-12
function HUDCenterPrompt:init(hud)
	self:_create_panel(hud)
	self:_create_text()
end

-- Lines 14-22
function HUDCenterPrompt:_create_panel(hud)
	local panel_params = {
		name = "center_prompt_panel",
		halign = "center",
		valign = "center",
		w = HUDCenterPrompt.W,
		h = HUDCenterPrompt.H
	}
	self._object = hud.panel:panel(panel_params)
end

-- Lines 24-37
function HUDCenterPrompt:_create_text()
	local text_params = {
		vertical = "center",
		name = "center_prompt_text",
		align = "center",
		alpha = 0,
		text = "",
		halign = "scale",
		valign = "scale",
		w = self._object:w(),
		h = self._object:h(),
		font = HUDCenterPrompt.TEXT_FONT,
		font_size = HUDCenterPrompt.TEXT_FONT_SIZE
	}
	self._text = self._object:text(text_params)
end

-- Lines 39-55
function HUDCenterPrompt:show_prompt(id, text, duration)
	if self._active_id == id then
		if duration then
			managers.queued_tasks:unqueue("HUDCenterPrompt:hide")
			managers.queued_tasks:queue("HUDCenterPrompt:hide", self.hide_prompt, self, {
				id
			}, duration, nil)
		end

		return
	end

	self._text:stop()
	self._text:animate(callback(self, self, "_animate_change_prompt"), text, id)

	if duration then
		managers.queued_tasks:queue("HUDCenterPrompt:hide", self.hide_prompt, self, {
			id
		}, duration, nil)
	end
end

-- Lines 57-67
function HUDCenterPrompt:hide_prompt(id)
	self._text:stop()
	self._text:animate(callback(self, self, "_animate_hide"))

	self._active_id = nil
end

-- Lines 69-71
function HUDCenterPrompt:set_x(x)
	self._object:set_x(x)
end

-- Lines 73-75
function HUDCenterPrompt:set_y(y)
	self._object:set_y(y)
end

-- Lines 77-79
function HUDCenterPrompt:w()
	return self._object:w()
end

-- Lines 81-83
function HUDCenterPrompt:h()
	return self._object:h()
end

-- Lines 85-119
function HUDCenterPrompt:_animate_change_prompt(text_control, text, id)
	local fade_out_duration = 0.2
	local fade_in_duration = 0.3
	local t = (1 - self._text:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._text:set_alpha(current_alpha)
	end

	self._text:set_alpha(0)

	if self._hidden_id == id then
		self._hidden_id = nil

		return
	end

	self._text:set_text(text)

	self._active_id = id
	self._hidden_id = nil
	t = 0

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_out_duration)

		self._text:set_alpha(current_alpha)
	end

	self._text:set_alpha(1)
end

-- Lines 121-134
function HUDCenterPrompt:_animate_hide()
	local fade_out_duration = 0.2
	local t = (1 - self._text:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._text:set_alpha(current_alpha)
	end

	self._text:set_alpha(0)
end
