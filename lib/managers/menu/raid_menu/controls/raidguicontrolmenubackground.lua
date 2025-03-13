RaidGUIControlMenuBackground = RaidGUIControlMenuBackground or class()
RaidGUIControlMenuBackground.NOISE_PADDING = 165

function RaidGUIControlMenuBackground:init()
	self._workspace = managers.gui_data:create_fullscreen_workspace()
	self._hud_panel = self._workspace:panel()
	self._object = self._hud_panel:panel({
		name = "menu_background_panel",
		visible = false,
		alpha = 0
	})
	self._base_resolution = tweak_data.gui.base_resolution
	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
	self._visible = false

	self:_layout_background()
end

function RaidGUIControlMenuBackground:destroy()
	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	end

	if self._background_video then
		managers.video:remove_video(self._background_video)
	end

	self._hud_panel:clear()
	managers.gui_data:destroy_workspace(self._workspace)
end

function RaidGUIControlMenuBackground:_layout_background()
	local blur = self._object:bitmap({
		name = "blur",
		render_template = "VertexColorTexturedBlur3D",
		texture = "ui/icons/white_df",
		halign = "scale",
		alpha = 0.65,
		valign = "scale",
		w = self._object:w(),
		h = self._object:h()
	})
	local tint = self._object:bitmap({
		name = "color_tint",
		render_template = "VertexColorTexturedGrayscale3D",
		texture = "ui/icons/white_df",
		halign = "scale",
		valign = "scale",
		alpha = 0.92,
		w = self._object:w(),
		h = self._object:h(),
		color = Color(0.9, 0.82, 0.6),
		layer = blur:layer() - 1
	})
	local background_gui = tweak_data.gui.backgrounds.secondary_menu
	local background = self._object:bitmap({
		name = "fullscreen_background",
		halign = "scale",
		valign = "scale",
		alpha = 0.75,
		w = self._object:w(),
		h = self._object:h(),
		texture = background_gui.texture,
		texture_rect = background_gui.texture_rect,
		layer = blur:layer() + 1
	})
	self._vignette = self._object:bitmap({
		name = "vignette",
		texture = "core/textures/vignette",
		halign = "scale",
		valign = "scale",
		w = self._object:w(),
		h = self._object:h(),
		layer = blur:layer() + 4
	})
	local noise_w = self._object:w() + RaidGUIControlMenuBackground.NOISE_PADDING
	local noise_h = self._object:h() + RaidGUIControlMenuBackground.NOISE_PADDING
	self._grain = self._object:bitmap({
		name = "film_grain",
		texture = "core/textures/noise",
		halign = "scale",
		valign = "scale",
		wrap_mode = "wrap",
		blend_mode = "add",
		w = noise_w,
		h = noise_h,
		texture_rect = {
			0,
			0,
			noise_w / 2,
			noise_h / 2
		},
		color = Color(0.18, 0.2, 0.2, 0.2),
		layer = blur:layer() + 2
	})
end

function RaidGUIControlMenuBackground:_layout_video()
	self._background_video = self._hud_panel:video({
		loop = true,
		visible = false,
		video = "movies/vanilla/raid_anim_bg"
	})

	managers.video:add_video(self._background_video)
end

function RaidGUIControlMenuBackground:set_visible(visible)
	if self._visible == visible then
		return
	end

	self._visible = visible

	if not visible and self._background_video then
		self:set_video_visible(false)
	end

	self._object:stop()
	self._object:animate(callback(self, self, visible and "_animate_show" or "_animate_hide"))
end

function RaidGUIControlMenuBackground:set_right(right)
	right = right or self._hud_panel:w()

	self._object:set_right(right)
end

function RaidGUIControlMenuBackground:set_video_visible(visible)
	if not self._background_video then
		self:_layout_video()
	end

	if visible then
		self._background_video:play()
		self._object:stop()
		self._object:set_visible(false)
	else
		self._background_video:pause()
	end

	self._background_video:set_visible(visible)
end

function RaidGUIControlMenuBackground:resolution_changed()
	if alive(self._workspace) then
		managers.gui_data:layout_fullscreen_workspace(self._workspace)
		self._object:set_size(self._hud_panel:size())
	end
end

function RaidGUIControlMenuBackground:_animate_show()
	local duration = 0.18
	local t = self._object:alpha() * duration

	self._object:set_visible(true)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)
		self._grain:set_alpha(current_alpha)
		self._vignette:set_alpha(current_alpha * 0.7)
	end

	self._object:set_alpha(1)
	self._grain:set_alpha(1)
	self._vignette:set_alpha(0.7)
	self:_animate_grain()
end

function RaidGUIControlMenuBackground:_animate_hide()
	local duration = 0.18
	local t = (1 - self._object:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in(t, 1, -1, duration)

		self._object:set_alpha(current_alpha)
		self._grain:set_alpha(current_alpha)
	end

	self._object:set_alpha(0)
	self._grain:set_alpha(0)
	self._object:set_visible(false)
end

function RaidGUIControlMenuBackground:_animate_grain()
	local t = 0

	while true do
		local dt = coroutine.yield()
		t = t + dt

		self._grain:set_x(math.random(0, -RaidGUIControlMenuBackground.NOISE_PADDING))
		self._grain:set_y(math.random(0, -RaidGUIControlMenuBackground.NOISE_PADDING))

		local current_alpha = math.abs(math.cos(t * 140) * 0.3)

		self._vignette:set_alpha(1 - current_alpha)
		wait(0.04)
	end
end
