HUDSaveIcon = HUDSaveIcon or class()
HUDSaveIcon.BACKGROUND = "saving_background"
HUDSaveIcon.DEFAULT_W = 250
HUDSaveIcon.DEFAULT_H = RaidGuiBase.PADDING
HUDSaveIcon.ICON_PADDING = 10
HUDSaveIcon.FONT = tweak_data.gui.fonts.din_compressed_outlined_32
HUDSaveIcon.FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDSaveIcon.COLOR = Color("878787")
HUDSaveIcon.BULLET_ICON = "loading_revolver_circle"
HUDSaveIcon.BULLET_COLOR = Color("787878")
HUDSaveIcon.NUMBER_OF_BULLETS = 8
HUDSaveIcon.RADIUS = 13
HUDSaveIcon.ONE_CIRCLE_DURATION = 1
HUDSaveIcon.DEFAULT_TEXT = "savefile_saving"

function HUDSaveIcon:init(workspace)
	self._ws = workspace
	self._workspace_panel = self._ws:panel()

	if self._workspace_panel:child("save_icon_panel") then
		self._workspace_panel:remove(self._workspace_panel:child("save_icon_panel"))
	end

	self:_create_panel()
	self:_create_text()
	self:_create_bullets()
end

function HUDSaveIcon:_create_panel()
	local panel_params = {
		name = "save_icon_panel",
		alpha = 0,
		w = HUDSaveIcon.DEFAULT_W,
		h = HUDSaveIcon.DEFAULT_H,
		layer = tweak_data.gui.SAVEFILE_LAYER
	}
	self._panel = self._workspace_panel:panel(panel_params)

	self._panel:set_bottom(self._workspace_panel:h())
	self._panel:set_center_x(self._workspace_panel:w() / 2)
end

function HUDSaveIcon:_create_background()
	local background_params = {
		name = "background",
		texture = tweak_data.gui.icons[HUDSaveIcon.BACKGROUND].texture,
		texture_rect = tweak_data.gui.icons[HUDSaveIcon.BACKGROUND].texture_rect
	}
	self._background = self._panel:bitmap(background_params)

	self._background:set_center_x(self._panel:w() / 2)
	self._background:set_center_y(self._panel:h() / 2)
end

function HUDSaveIcon:_create_text()
	local text_params = {
		name = "save_icon_text",
		vertical = "center",
		text = "",
		y = 0,
		x = 0,
		h = self._panel:h(),
		font = HUDSaveIcon.FONT,
		font_size = HUDSaveIcon.FONT_SIZE,
		color = HUDSaveIcon.COLOR
	}
	self._text = self._panel:text(text_params)
end

function HUDSaveIcon:_create_bullets()
	local bullet_panel_params = {
		halign = "left",
		name = "bullet_panel",
		y = 0,
		w = 32,
		x = 0,
		valign = "center",
		h = self._panel:h()
	}
	self._bullet_panel = self._panel:panel(bullet_panel_params)
	local single_bullet_angle = 360 / HUDSaveIcon.NUMBER_OF_BULLETS
	self._bullets = {}

	for i = 1, HUDSaveIcon.NUMBER_OF_BULLETS do
		local dx = HUDSaveIcon.RADIUS * math.cos(single_bullet_angle * (i - 1) - 90)
		local dy = HUDSaveIcon.RADIUS * math.sin(single_bullet_angle * (i - 1) - 90)
		local bullet_params = {
			name = "bullet_" .. tostring(i),
			texture = tweak_data.gui.icons[HUDSaveIcon.BULLET_ICON].texture,
			texture_rect = tweak_data.gui.icons[HUDSaveIcon.BULLET_ICON].texture_rect,
			color = HUDSaveIcon.BULLET_COLOR
		}
		local bullet = self._bullet_panel:bitmap(bullet_params)

		bullet:set_center_x(self._bullet_panel:w() / 2 + dx)
		bullet:set_center_y(self._bullet_panel:h() / 2 + dy)
		table.insert(self._bullets, bullet)
	end
end

function HUDSaveIcon:show(params)
	local text = params.text or HUDSaveIcon.DEFAULT_TEXT

	self._text:set_text(utf8.to_upper(managers.localization:text(text)))

	local _, _, w, _ = self._text:text_rect()

	self._text:set_w(w)

	local content_w = self._bullet_panel:w() + HUDSaveIcon.ICON_PADDING + w

	self._bullet_panel:set_x(self._panel:w() / 2 - content_w / 2)
	self._text:set_x(self._bullet_panel:right() + HUDSaveIcon.ICON_PADDING)

	if not self._shown then
		self._panel:stop()
		self._panel:animate(callback(self, self, "_animate_show"))

		self._shown = true
	end

	if not self._animating then
		self._active_bullet = 8

		self._bullet_panel:animate(callback(self, self, "_animate_bullets"))

		self._animating = true
	end
end

function HUDSaveIcon:hide()
	self._panel:stop()
	self._panel:animate(callback(self, self, "_animate_hide"))

	self._shown = false
end

function HUDSaveIcon:_animate_bullets()
	while true do
		local shoot_duration = 0.1
		local t = 0
		local center_x = self._bullets[self._active_bullet]:center_x()
		local center_y = self._bullets[self._active_bullet]:center_y()

		while t < shoot_duration do
			local dt = coroutine.yield()
			t = t + dt
			local current_size = Easing.linear(t, 1, -1, shoot_duration)

			self._bullets[self._active_bullet]:set_w(current_size * tweak_data.gui:icon_w(HUDSaveIcon.BULLET_ICON))
			self._bullets[self._active_bullet]:set_h(current_size * tweak_data.gui:icon_h(HUDSaveIcon.BULLET_ICON))
			self._bullets[self._active_bullet]:set_center_x(center_x)
			self._bullets[self._active_bullet]:set_center_y(center_y)
		end

		self._bullets[self._active_bullet]:set_alpha(0)
		self._bullets[self._active_bullet]:set_w(tweak_data.gui:icon_w(HUDSaveIcon.BULLET_ICON))
		self._bullets[self._active_bullet]:set_h(tweak_data.gui:icon_h(HUDSaveIcon.BULLET_ICON))
		self._bullets[self._active_bullet]:set_center_x(center_x)
		self._bullets[self._active_bullet]:set_center_y(center_y)

		local rotation_duration = 0.5
		t = 0
		local single_bullet_angle = 360 / #self._bullets
		local initial_rotations = {}

		for i = 1, #self._bullets do
			table.insert(initial_rotations, self._bullets[i]:rotation())
		end

		while t < rotation_duration do
			local dt = coroutine.yield()
			t = t + dt
			local current_rotation_offset = Easing.quartic_in_out(t, 0, single_bullet_angle, rotation_duration)

			for i = 1, #self._bullets do
				local dx = HUDSaveIcon.RADIUS * math.cos(single_bullet_angle * (i - 1) + current_rotation_offset - 90)
				local dy = HUDSaveIcon.RADIUS * math.sin(single_bullet_angle * (i - 1) + current_rotation_offset - 90)

				self._bullets[i]:set_center_x(self._bullet_panel:w() / 2 + dx)
				self._bullets[i]:set_center_y(self._bullet_panel:h() / 2 + dy)
			end
		end

		wait(0.15)

		local reload_duration = 0.2
		t = 0
		center_y = self._bullets[self._active_bullet]:center_y()

		while t < reload_duration do
			local dt = coroutine.yield()
			t = t + dt
			local current_position_offset = Easing.linear(t, 10, -10, reload_duration)

			self._bullets[self._active_bullet]:set_center_y(center_y - current_position_offset)

			local current_alpha = Easing.linear(t, 0, 1, reload_duration * 0.9)

			self._bullets[self._active_bullet]:set_alpha(current_alpha)
		end

		for i = 1, #self._bullets do
			local dx = HUDSaveIcon.RADIUS * math.cos(single_bullet_angle * (i - 1) - 90)
			local dy = HUDSaveIcon.RADIUS * math.sin(single_bullet_angle * (i - 1) - 90)

			self._bullets[i]:set_center_x(self._bullet_panel:w() / 2 + dx)
			self._bullets[i]:set_center_y(self._bullet_panel:h() / 2 + dy)
		end

		wait(0.3)
	end
end

function HUDSaveIcon:_animate_show()
	local duration = 0.2
	local t = self._panel:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, duration)

		self._panel:set_alpha(current_alpha)
	end

	self._panel:set_alpha(1)
end

function HUDSaveIcon:_animate_hide()
	local duration = 0.4
	local t = (1 - self._panel:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in(t, 1, -1, duration)

		self._panel:set_alpha(current_alpha)
	end

	self._panel:set_alpha(0)
	self._ws:hide()
end
