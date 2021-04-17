HUDToastNotification = HUDToastNotification or class()
HUDToastNotification.BACKGROUND_IMAGE = "backgrounds_toast_mission_bg_002"
HUDToastNotification.BORDER_H = 2
HUDToastNotification.BORDER_COLOR = tweak_data.gui.colors.toast_notification_border
HUDToastNotification.TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDToastNotification.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_24

-- Lines 10-18
function HUDToastNotification:init(hud)
	if hud.panel:child("present_panel") then
		hud.panel:remove(hud.panel:child("present_panel"))
	end

	self:_create_panel(hud)
	self:_create_background()
	self:_create_text()
end

-- Lines 20-28
function HUDToastNotification:_create_panel(hud)
	local panel_params = {
		name = "toast_notification_panel",
		visible = false,
		w = tweak_data.gui:icon_w(HUDToastNotification.BACKGROUND_IMAGE),
		h = tweak_data.gui:icon_h(HUDToastNotification.BACKGROUND_IMAGE)
	}
	self._object = hud.panel:panel(panel_params)
end

-- Lines 30-38
function HUDToastNotification:_create_background()
	local background_params = {
		name = "background",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[HUDToastNotification.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDToastNotification.BACKGROUND_IMAGE].texture_rect
	}
	self._background = self._object:bitmap(background_params)
end

-- Lines 40-58
function HUDToastNotification:_create_text()
	local text_params = {
		vertical = "center",
		name = "text",
		layer = 5,
		align = "center",
		text = "GET THE AMBER WAGON READY TO LIFT IT UP WITH THE CRANE!",
		halign = "center",
		valign = "center",
		font = HUDToastNotification.TEXT_FONT,
		font_size = HUDToastNotification.TEXT_FONT_SIZE
	}
	self._text = self._object:text(text_params)
	local _, _, w, h = self._text:text_rect()

	self._text:set_w(w)
	self._text:set_h(h)
	self._text:set_center_x(self._object:w() / 2)
	self._text:set_center_y(self._object:h() / 2)
end

-- Lines 61-72
function HUDToastNotification:present(params)
	self._present_queue = self._present_queue or {}

	if self._presenting then
		table.insert(self._present_queue, params)

		return
	end

	if params.present_mid_text then
		self:_present_information(params)
	end
end

-- Lines 74-76
function HUDToastNotification:cleanup()
	self._object:parent():remove(self._object)
end

-- Lines 78-93
function HUDToastNotification:_present_information(params)
	self:_set_text(params.text)
	self._object:set_visible(true)
	managers.hud:hide_objectives()

	if params.event then
		managers.hud._sound_source:post_event(params.event)
	end

	local present_time = params.time or 4

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_present"), present_time)

	self._presenting = true
end

-- Lines 95-104
function HUDToastNotification:_set_text(text)
	self._text:set_text(utf8.to_upper(text))

	local _, _, w, h = self._text:text_rect()

	self._text:set_w(w)
	self._text:set_h(h)
	self._text:set_center_x(self._object:w() / 2)
	self._text:set_center_y(self._object:h() / 2)
end

-- Lines 106-117
function HUDToastNotification:_present_done()
	self._object:set_visible(false)
	managers.hud:show_objectives()

	self._presenting = false
	local queued = table.remove(self._present_queue, 1)

	if queued and queued.present_mid_text then
		setup:add_end_frame_clbk(callback(self, self, "_present_information", queued))
	end
end

-- Lines 119-121
function HUDToastNotification:w()
	return self._object:w()
end

-- Lines 123-125
function HUDToastNotification:h()
	return self._object:h()
end

-- Lines 127-129
function HUDToastNotification:set_x(x)
	self._object:set_x(x)
end

-- Lines 131-133
function HUDToastNotification:set_y(y)
	self._object:set_y(y)
end

-- Lines 135-203
function HUDToastNotification:_animate_present(panel, duration)
	local x_travel = 60
	local fade_in_duration = duration * 0.1
	local sustain_duration = duration * 0.6
	local fade_out_duration = duration * 0.1
	local fade_in_distance = x_travel * 0.38
	local sustain_distance = x_travel * 0.24
	local fade_out_distance = x_travel * 0.38
	local t = 0

	self._background:set_alpha(0)
	self._text:set_alpha(0)
	self._object:set_center_x(self._object:parent():w() / 2 + x_travel / 2)
	self._text:set_center_x(self._object:w() / 2 - x_travel / 2)
	managers.hud._sound_source:post_event("objective_activated_in")

	while t < fade_in_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in_out(math.clamp(t - 0.2, 0, fade_in_duration * 0.8), 0, 1, fade_in_duration * 0.8)

		self._background:set_alpha(current_alpha)
		self._text:set_alpha(current_alpha)

		local current_offset = Easing.quartic_in_out(t, x_travel / 2, -fade_in_distance, fade_in_duration)

		self._object:set_center_x(self._object:parent():w() / 2 + current_offset)
		self._text:set_center_x(self._object:w() / 2 - x_travel / 2 - current_offset * 2)
	end

	self._background:set_alpha(1)
	self._text:set_alpha(1)

	t = 0

	while sustain_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.linear(t, x_travel / 2 - fade_in_distance, -sustain_distance, sustain_duration)

		self._object:set_center_x(self._object:parent():w() / 2 + current_offset)
		self._text:set_center_x(self._object:w() / 2 - x_travel / 2 - current_offset * 2)
	end

	managers.hud._sound_source:post_event("objective_activated_out")

	t = 0

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in_out(t, 1, -1, fade_out_duration * 0.8)

		self._background:set_alpha(current_alpha)
		self._text:set_alpha(current_alpha)

		local current_offset = Easing.quartic_in_out(t, x_travel / 2 - fade_in_distance - sustain_distance, -fade_out_distance, fade_out_duration)

		self._object:set_center_x(self._object:parent():w() / 2 + current_offset)
		self._text:set_center_x(self._object:w() / 2 - x_travel / 2 - current_offset * 2)
	end

	self._background:set_alpha(0)
	self._text:set_alpha(0)
	self._object:set_center_x(self._object:parent():w() / 2)
	self._text:set_center_x(self._object:w() / 2)
	self:_present_done()
end
