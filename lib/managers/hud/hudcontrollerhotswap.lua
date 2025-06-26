HUDControllerHotswap = HUDControllerHotswap or class()
HUDControllerHotswap.HOTSWAP_HUD_ID = "controller_hotswap"
HUDControllerHotswap.HOTSWAP_CLBK_ID = "raid_gui_control_controller"
HUDControllerHotswap.ANIMATION_MOVE_X_DISTANCE = 30
HUDControllerHotswap.W = 250
HUDControllerHotswap.H = 40
HUDControllerHotswap.BACKGROUND_IMAGE = "backgrounds_chat_bg"
HUDControllerHotswap.TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_22
HUDControllerHotswap.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDControllerHotswap.DEVICE_KEYBOARD = "device_keyboard"
HUDControllerHotswap.DEVICE_CONTROLLER_PS4 = "device_controller_ps4"
HUDControllerHotswap.DEVICE_CONTROLLER_XB1 = "device_controller_xb1"

function HUDControllerHotswap:init(hud)
	if hud.panel:child(HUDControllerHotswap.HOTSWAP_HUD_ID) then
		hud.panel:remove(hud.panel:child(HUDControllerHotswap.HOTSWAP_HUD_ID))
	end

	self:_create_panel(hud)
	managers.controller:add_hotswap_callback(HUDControllerHotswap.HOTSWAP_CLBK_ID, callback(self, self, "clbk_hotswap"))
end

function HUDControllerHotswap.get_icon()
	local p = managers.controller:is_using_controller() and HUDControllerHotswap.DEVICE_CONTROLLER_XB1 or HUDControllerHotswap.DEVICE_KEYBOARD

	return tweak_data.gui.icons["hotswap_" .. (p or "device_unknown")]
end

function HUDControllerHotswap:_create_panel(hud)
	self._object = hud.panel:panel({
		halign = "center",
		valign = "center",
		visible = false,
		name = HUDControllerHotswap.HOTSWAP_HUD_ID,
		w = HUDControllerHotswap.W,
		h = HUDControllerHotswap.H
	})
	local gui_data = tweak_data.gui:get_full_gui_data(HUDControllerHotswap.BACKGROUND_IMAGE)
	self._background = self._object:bitmap({
		w = HUDControllerHotswap.W,
		h = HUDControllerHotswap.H,
		texture = gui_data.texture,
		texture_rect = gui_data.texture_rect
	})
	local thickness = 4
	self._timer_bar = self._object:rect({
		y = self._object:h() - thickness,
		w = self._object:w(),
		h = thickness,
		color = tweak_data.gui.colors.raid_gold,
		layer = self._background:layer() + 1
	})
end

function HUDControllerHotswap:update_input_device()
	local gui = HUDControllerHotswap.get_icon()

	if self._icon then
		self._icon:set_image(gui.texture)
		self._icon:set_texture_rect(unpack(gui.texture_rect))
	else
		self._icon = self._object:bitmap({
			y = 4,
			x = 4,
			w = HUDControllerHotswap.H - 8,
			h = HUDControllerHotswap.H - 8,
			texture = gui.texture,
			texture_rect = gui.texture_rect,
			layer = self._background:layer() + 1
		})
	end

	self._icon:set_center_y(self._object:h() / 2)

	if not self._text then
		self._text = self._object:text({
			vertical = "center",
			align = "center",
			x = self._icon:w() / 2,
			font = self.TEXT_FONT,
			font_size = self.TEXT_FONT_SIZE,
			layer = self._background:layer() + 1
		})
	end

	local text = managers.localization:to_upper_text(managers.controller:is_using_controller() and "hud_hotswap_controller" or "hud_hotswap_keyboard")

	self._text:set_text(text)
end

function HUDControllerHotswap:clbk_hotswap()
	self:update_input_device()
	self._object:show()
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hotswap"))
end

function HUDControllerHotswap:_animate_hotswap()
	self._object:set_alpha(0)
	self._timer_bar:set_w(self._object:w())

	local t = 0
	local duration = 0.2

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = Easing.quintic_in_out(t, 0, 1, duration)

		self._object:set_alpha(curr_alpha)

		local current_x_offset = (1 - curr_alpha) * HUDControllerHotswap.ANIMATION_MOVE_X_DISTANCE

		self._object:set_x(current_x_offset)
	end

	t = 0
	duration = 2.5

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local l = t / duration

		self._timer_bar:set_w(self._object:w() * (1 - l))
	end

	self._timer_bar:set_w(0)

	t = 0
	duration = 0.2

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = Easing.quintic_in_out(t, 1, -1, duration)

		self._object:set_alpha(curr_alpha)

		local current_x_offset = (1 - curr_alpha) * HUDControllerHotswap.ANIMATION_MOVE_X_DISTANCE

		self._object:set_x(current_x_offset)
	end

	self._object:hide()
end

function HUDControllerHotswap:set_x(x)
	self._object:set_x(x)
end

function HUDControllerHotswap:set_y(y)
	self._object:set_y(y)
end

function HUDControllerHotswap:w()
	return self._object:w()
end

function HUDControllerHotswap:h()
	return self._object:h()
end
