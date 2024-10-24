HUDToastNotification = HUDToastNotification or class()
HUDToastNotification.W = 736
HUDToastNotification.H = 86
HUDToastNotification.BACKGROUND_IMAGE = "backgrounds_toast_mission_bg_002"
HUDToastNotification.ICON_PANEL_SIZE = 288
HUDToastNotification.ICON_SIZE = 112
HUDToastNotification.ICON_COLOR = tweak_data.gui.colors.raid_light_red
HUDToastNotification.BORDER_COLOR = tweak_data.gui.colors.toast_notification_border
HUDToastNotification.TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDToastNotification.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.medium
HUDToastNotification.TITLE_COLOR = tweak_data.gui.colors.raid_red
HUDToastNotification.TEXT_W = 600
HUDToastNotification.TEXT_FONT = tweak_data.gui.fonts.din_compressed
HUDToastNotification.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.large
HUDToastNotification.TEXT_COLOR = tweak_data.gui.colors.raid_grey
HUDToastNotification.TEXT_GLOW_COLOR = tweak_data.gui.colors.raid_dirty_white

function HUDToastNotification:init(hud)
	if hud.panel:child("toast_notification_panel") then
		hud.panel:remove(hud.panel:child("toast_notification_panel"))
	end

	self:_create_panel(hud)
	self:_create_background()
	self:_create_title()
	self:_create_text()
	self:_create_icon()
end

function HUDToastNotification:_create_panel(hud)
	self._object = hud.panel:panel({
		visible = false,
		layer = 20,
		h = nil,
		w = nil,
		name = "toast_notification_panel",
		w = HUDToastNotification.W,
		h = HUDToastNotification.H
	})
end

function HUDToastNotification:_create_background()
	self._background = self._object:bitmap({
		halign = "center",
		valign = "center",
		texture_rect = nil,
		texture = nil,
		h = nil,
		w = nil,
		name = "background",
		w = HUDToastNotification.W,
		h = HUDToastNotification.H,
		texture = tweak_data.gui.icons[HUDToastNotification.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDToastNotification.BACKGROUND_IMAGE].texture_rect
	})
end

function HUDToastNotification:_create_title()
	self._title = self._object:text({
		text = "OBJECTIVE ACTIVATED",
		align = "center",
		valign = "center",
		halign = "center",
		color = nil,
		font_size = nil,
		layer = nil,
		font = nil,
		vertical = "center",
		name = "text",
		font = tweak_data.gui:get_font_path(HUDToastNotification.TITLE_FONT, HUDToastNotification.TITLE_FONT_SIZE),
		font_size = HUDToastNotification.TITLE_FONT_SIZE,
		color = HUDToastNotification.TITLE_COLOR,
		layer = self._background:layer() + 1
	})

	self._title:set_h(self._object:h() / 2)
	self._title:set_center_x(self._object:w() / 2)
	self._title:set_y(3)
end

function HUDToastNotification:_create_text()
	self._text = self._object:text({
		text = "GET THE AMBER WAGON READY TO LIFT IT UP WITH THE CRANE!",
		w = nil,
		align = "center",
		valign = "center",
		halign = "center",
		color = nil,
		font_size = nil,
		layer = nil,
		font = nil,
		vertical = "center",
		name = "text",
		font = tweak_data.gui:get_font_path(HUDToastNotification.TEXT_FONT, HUDToastNotification.TEXT_FONT_SIZE),
		font_size = HUDToastNotification.TEXT_FONT_SIZE,
		color = HUDToastNotification.TEXT_COLOR,
		w = HUDToastNotification.TEXT_W,
		layer = self._background:layer() + 1
	})

	self._text:set_h(self._object:h() / 2)
	self._text:set_center_x(self._object:w() / 2)
	self._text:set_y(self._object:h() / 2 - 5)
end

function HUDToastNotification:_create_icon()
	self._icon_panel = self._object:panel({
		layer = nil,
		h = nil,
		w = nil,
		name = "toast_notification_panel",
		layer = self._background:layer() + 1,
		w = HUDToastNotification.ICON_PANEL_SIZE,
		h = HUDToastNotification.ICON_PANEL_SIZE
	})

	self._icon_panel:set_center(self._object:w() / 2, self._object:h() / 2)

	self._icon = self._icon_panel:bitmap({
		rotation = 360,
		color = nil,
		name = "icon",
		color = HUDToastNotification.ICON_COLOR
	})
	local blur = self._icon_panel:bitmap({
		render_template = "VertexColorTexturedBlur3D",
		texture = nil,
		texture_rect = nil,
		rotation = 360,
		layer = nil,
		h = nil,
		w = nil,
		name = "blur",
		layer = self._icon:layer() - 1,
		w = HUDToastNotification.ICON_PANEL_SIZE,
		h = HUDToastNotification.ICON_PANEL_SIZE,
		texture = tweak_data.gui.icons.presenter_blur.texture,
		texture_rect = tweak_data.gui.icons.presenter_blur.texture_rect
	})
	local icon_bg = self._icon_panel:bitmap({
		texture = nil,
		rotation = 360,
		texture_rect = nil,
		layer = nil,
		h = nil,
		w = nil,
		name = "icon_bg",
		layer = self._icon:layer() - 2,
		w = HUDToastNotification.ICON_PANEL_SIZE,
		h = HUDToastNotification.ICON_PANEL_SIZE,
		texture = tweak_data.gui.icons.presenter_background.texture,
		texture_rect = tweak_data.gui.icons.presenter_background.texture_rect
	})

	self:_set_icon()
end

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

function HUDToastNotification:cleanup()
	self._object:parent():remove(self._object)
end

function HUDToastNotification:_present_information(params)
	self:_set_title(params.title)
	self:_set_text(params.text)
	self:_set_icon(params.icon)
	self._object:set_visible(true)

	if params.event then
		managers.hud:post_event(params.event)
	end

	local present_time = params.time or 4

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_present"), present_time)

	self._presenting = true
end

function HUDToastNotification:_set_title(title)
	title = title or ""

	self._title:set_text(utf8.to_upper(title))
	self._title:set_color(HUDToastNotification.TITLE_COLOR)

	local w = select(3, self._title:text_rect())

	self._title:set_w(w)
	self._title:set_h(self._object:h() / 2)
	self._title:set_center_x(self._object:w() / 2)
	self._title:set_y(3)
end

function HUDToastNotification:_set_text(text)
	text = text or ""

	self._text:set_text(utf8.to_upper(text))
	managers.hud:fit_text(self._text, HUDToastNotification.TEXT_FONT_SIZE)
	self._text:set_center_x(self._object:w() / 2)
	self._text:set_y(self._object:h() / 2 - 5)
end

function HUDToastNotification:_set_icon(icon)
	icon = icon or "presenter_objective"

	self._icon:set_image(tweak_data.gui.icons[icon].texture)
	self._icon:set_texture_rect(unpack(tweak_data.gui.icons[icon].texture_rect))
	self._icon:set_size(HUDToastNotification.ICON_SIZE, HUDToastNotification.ICON_SIZE)
	self._icon:set_center(self._icon_panel:w() / 2, self._icon_panel:h() / 2)
end

function HUDToastNotification:_present_done()
	self._object:set_visible(false)
	managers.hud:show_objectives()

	self._presenting = false
	local queued = table.remove(self._present_queue, 1)

	if queued and queued.present_mid_text then
		setup:add_end_frame_clbk(callback(self, self, "_present_information", queued))
	end
end

function HUDToastNotification:w()
	return self._object:w()
end

function HUDToastNotification:h()
	return self._object:h()
end

function HUDToastNotification:set_x(x)
	self._object:set_x(x)
end

function HUDToastNotification:set_y(y)
	self._object:set_y(y)
end

function HUDToastNotification:_animate_present(panel, duration)
	local x_travel = 60
	local blink_duration = 0.62
	local fade_in_duration = 0.38
	local fade_out_duration = 0.36
	local sustain_duration = duration - blink_duration
	local t = 0

	self._object:set_alpha(1)
	self._title:set_alpha(0)
	self._text:set_alpha(0)
	self._icon:set_alpha(0)
	self._icon_panel:set_alpha(0)
	self._background:set_w(0)
	self._object:set_center_x(self._object:parent():w() / 2)
	self._background:set_center_x(self._object:w() / 2)
	managers.hud:post_event("objective_activated_in")

	while t < blink_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = 0.3 + math.abs(math.sin(t * 680)) * 0.7

		self._icon:set_alpha(current_alpha)

		current_alpha = Easing.quintic_out(t, 0, 1, blink_duration * 0.35)

		self._icon_panel:set_alpha(current_alpha)

		local current_icon_size = HUDToastNotification.ICON_SIZE * current_alpha

		self._icon:set_size(current_icon_size, current_icon_size)
		self._icon:set_center(self._icon_panel:w() / 2, self._icon_panel:h() / 2)
	end

	self._icon:set_alpha(1)
	self._icon_panel:set_alpha(1)

	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, fade_in_duration * 0.75)

		self._icon_panel:set_alpha(1 - current_alpha)
		self._title:set_alpha(current_alpha)
		self._text:set_alpha(current_alpha)

		local current_kern = -(1 - current_alpha) * 10

		self._title:set_kern(current_kern)
		self._text:set_kern(current_kern)

		local current_width = Easing.quintic_out(t, 0, HUDToastNotification.W, fade_in_duration)

		self._background:set_w(current_width)
		self._background:set_center_x(self._object:w() / 2)

		local current_icon_size = HUDToastNotification.ICON_SIZE + current_width * 0.33

		self._icon:set_size(current_icon_size, current_icon_size)
		self._icon:set_center(self._icon_panel:w() / 2, self._icon_panel:h() / 2)
	end

	self._object:set_alpha(1)
	self._title:set_alpha(1)
	self._text:set_alpha(1)
	self._text:set_kern(0)
	self._icon_panel:set_alpha(0)
	self._background:set_w(HUDToastNotification.W)
	self._background:set_center_x(self._object:w() / 2)
	self._text:stop()
	self._text:animate(UIAnimation.animate_text_glow, HUDToastNotification.TEXT_GLOW_COLOR, 0.48, 0.042, 0.8)
	wait(sustain_duration)
	managers.hud:post_event("objective_activated_out")

	t = 0

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._object:set_alpha(current_alpha)

		local current_offset = math.lerp(0, x_travel, 1 - current_alpha)

		self._object:set_center_x(self._object:parent():w() / 2 + current_offset)
		self._text:set_center_x(self._object:w() / 2 + current_offset * 1.4)
	end

	self._object:set_alpha(0)
	self._object:set_center_x(self._object:parent():w() / 2)
	self._text:stop()
	self._text:set_text("")
	self:_present_done()
end
