LevelLoadingScreenGuiScript = LevelLoadingScreenGuiScript or class()

-- Lines 4-85
function LevelLoadingScreenGuiScript:init(scene_gui, res, progress, base_layer)
	self._scene_gui = scene_gui
	self._res = res
	self._base_layer = base_layer
	self._level_tweak_data = arg.load_level_data.level_tweak_data
	self._gui_tweak_data = arg.load_level_data.gui_tweak_data
	self._menu_tweak_data = arg.load_level_data.menu_tweak_data
	self._scale_tweak_data = arg.load_level_data.scale_tweak_data
	self._coords = arg.load_level_data.controller_coords or false
	self._gui_data = arg.load_level_data.gui_data
	self._workspace_size = self._gui_data.workspace_size
	self._saferect_size = self._gui_data.saferect_size
	local challenges = arg.load_level_data.challenges
	local safe_rect_pixels = self._gui_data.safe_rect_pixels
	local safe_rect = self._gui_data.safe_rect
	local aspect_ratio = self._gui_data.aspect_ratio
	self._safe_rect_pixels = safe_rect_pixels
	self._safe_rect = safe_rect
	self._gui_data_manager = GuiDataManager:new(self._scene_gui, res, safe_rect_pixels, safe_rect, aspect_ratio)
	self._back_drop_gui = MenuBackdropGUI:new(nil, self._gui_data_manager, true)

	self._back_drop_gui:set_pattern("guis/textures/loading/loading_foreground", 1)

	local base_panel = self._back_drop_gui:get_new_base_layer()
	local level_image = base_panel:bitmap({
		layer = 0,
		texture = self._gui_data.bg_texture
	})

	level_image:set_alpha(0)
	print("self._gui_data.bg_texture", self._gui_data.bg_texture)
	level_image:set_size(level_image:parent():h() * level_image:texture_width() / level_image:texture_height(), level_image:parent():h())
	level_image:set_position(0, 0)

	local background_fullpanel = self._back_drop_gui:get_new_background_layer()
	local background_safepanel = self._back_drop_gui:get_new_background_layer()

	self._back_drop_gui:set_panel_to_saferect(background_safepanel)

	local text = string.upper(managers.localization:text("debug_loading_level"))
	self._level_title_text = background_safepanel:text({
		y = 0,
		vertical = "bottom",
		h = 36,
		font_size = 36,
		align = "left",
		font = "fonts/font_large_mf",
		halign = "left",
		layer = 0,
		text = text,
		color = Color.white
	})
	local _, _, w, h = self._level_title_text:text_rect()

	self._level_title_text:set_size(w, h)

	if self._coords then
		self._controller = background_safepanel:bitmap({
			texture = "guis/textures/controller",
			w = 512,
			h = 256,
			layer = 1
		})

		self._controller:set_center(background_safepanel:w() / 2, background_safepanel:h() / 2)

		for id, data in pairs(self._coords) do
			data.text = background_safepanel:text({
				font_size = 24,
				font = "fonts/font_medium_mf",
				halign = "center",
				valign = "center",
				name = data.id,
				text = data.string,
				align = data.align,
				vertical = data.vertical,
				color = data.color
			})
			local _, _, w, h = data.text:text_rect()

			data.text:set_size(w, h)

			if data.x then
				local x = self._controller:x() + data.x
				local y = self._controller:y() + data.y

				if data.align == "left" then
					data.text:set_left(x)
				elseif data.align == "right" then
					data.text:set_right(x)
				elseif data.align == "center" then
					data.text:set_center_x(x)
				end

				if data.vertical == "top" then
					data.text:set_top(y)
				elseif data.vertical == "bottom" then
					data.text:set_bottom(y)
				else
					data.text:set_center_y(y)
				end
			end
		end
	end
end

-- Lines 87-178
function LevelLoadingScreenGuiScript:setup(res, progress)
	self._saferect_bottom_y = self._saferect_panel:h() - self._gui_tweak_data.upper_saferect_border

	self._level_title_text:set_shape(0, 0, self._safe_rect_pixels.width, self._gui_tweak_data.upper_saferect_border - self._gui_tweak_data.border_pad)

	local _, _, w, _ = self._level_title_text:text_rect()

	self._level_title_text:set_w(w)
	self._bg_gui:set_size(self._bg_gui:parent():h() * self._bg_gui:texture_width() / self._bg_gui:texture_height(), self._bg_gui:parent():h())
	self._bg_gui:set_center(self._bg_gui:parent():center())

	if self._briefing_text then
		if self._res and self._res.y <= 601 then
			self._briefing_text:set_w(self._briefing_text:parent():w())

			local _, _, w, h = self._briefing_text:text_rect()

			self._briefing_text:set_size(w, h)
			self._briefing_text:set_lefttop(0, self._briefing_text:parent():h() / 2)
		else
			self._briefing_text:set_w(self._briefing_text:parent():w() * 0.5)

			local _, _, w, h = self._briefing_text:text_rect()

			self._briefing_text:set_size(w, h)
			self._briefing_text:set_rightbottom(self._briefing_text:parent():w(), self._saferect_bottom_y - self._gui_tweak_data.border_pad)
		end
	end

	local border_size = 2
	local bar_size = 2

	self._stonecold_small_logo:set_righttop(self._stonecold_small_logo:parent():righttop())
	self._stonecold_small_logo:set_bottom(self._gui_tweak_data.upper_saferect_border - self._gui_tweak_data.border_pad)

	self._top_y = self._safe_rect_pixels.y + self._gui_tweak_data.upper_saferect_border
	self._bottom_y = self._safe_rect_pixels.y + self._saferect_panel:h() - self._gui_tweak_data.upper_saferect_border

	self._upper_frame_rect:set_h(self._screen_y + self._gui_tweak_data.upper_saferect_border)
	self._lower_frame_rect:set_h(self._upper_frame_rect:h())
	self._lower_frame_rect:set_bottom(self._lower_frame_rect:parent():h())

	local tip_top = self._gui_tweak_data.upper_saferect_border + self._gui_tweak_data.border_pad + 14
	local _, _, w, h = self._tips_head_line:text_rect()

	self._tips_head_line:set_size(w, h)
	self._tips_head_line:set_top(tip_top)

	local offset = 20

	self._tips_text:set_w(self._saferect_panel:w() - self._tips_head_line:w() - offset)
	self._tips_text:set_top(tip_top)
	self._tips_text:set_left(self._tips_head_line:right() + offset)

	if progress > 0 then
		self._init_progress = progress
	end

	for i, challenge in ipairs(self._challenges) do
		local h = challenge.panel:h()

		challenge.panel:set_bottom(self._saferect_bottom_y - (h + 2) * (#self._challenges - i))
		challenge.text:set_left(challenge.panel:right() + 8 * self._scale_tweak_data.loading_challenge_bar_scale)
		challenge.text:set_center_y(challenge.panel:center_y())
	end

	self._challenges_topic:set_visible(self._challenges[1] and true or false)

	if self._challenges[1] then
		self._challenges_topic:set_bottom(self._challenges[1].panel:top() - 4)
	end

	if self._coords then
		self._controller:set_center(self._saferect_panel:w() / 2, self._saferect_panel:h() / 2)

		for id, data in pairs(self._coords) do
			local _, _, w, h = data.text:text_rect()

			data.text:set_size(w, h)

			if data.x then
				local x = self._controller:x() + data.x
				local y = self._controller:y() + data.y

				if data.align == "left" then
					data.text:set_left(x)
				elseif data.align == "right" then
					data.text:set_right(x)
				elseif data.align == "center" then
					data.text:set_center_x(x)
				end

				if data.vertical == "top" then
					data.text:set_top(y)
				elseif data.vertical == "bottom" then
					data.text:set_bottom(y)
				else
					data.text:set_center_y(y)
				end
			end
		end
	end
end

-- Lines 180-181
function LevelLoadingScreenGuiScript:update(progress, t, dt)
end

-- Lines 183-185
function LevelLoadingScreenGuiScript:get_loading_text(dot_count)
	return self._init_text .. string.rep(".", math.floor(dot_count))
end

-- Lines 187-190
function LevelLoadingScreenGuiScript:set_text(text)
	self._text_gui:set_text(text)

	self._init_text = text
end

-- Lines 192-211
function LevelLoadingScreenGuiScript:destroy()
	if alive(self._saferect) then
		self._scene_gui:destroy_workspace(self._saferect)

		self._saferect = nil
	end

	if alive(self._fullrect) then
		self._scene_gui:destroy_workspace(self._fullrect)

		self._fullrect = nil
	end

	if alive(self._ws) then
		self._scene_gui:destroy_workspace(self._ws)

		self._ws = nil
	end

	if self._back_drop_gui then
		self._back_drop_gui:destroy()

		self._back_drop_gui = nil
	end
end

-- Lines 213-215
function LevelLoadingScreenGuiScript:visible()
	return self._ws:visible()
end

-- Lines 217-223
function LevelLoadingScreenGuiScript:set_visible(visible)
	if visible then
		self._ws:show()
	else
		self._ws:hide()
	end
end
