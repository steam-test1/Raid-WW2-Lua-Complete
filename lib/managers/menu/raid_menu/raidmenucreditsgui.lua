RaidMenuCreditsGui = RaidMenuCreditsGui or class(RaidGuiBase)
RaidMenuCreditsGui.PATH = "gamedata/"
RaidMenuCreditsGui.FILE_EXTENSION = "credits"
RaidMenuCreditsGui.INTRO_VIDEO = "movies/vanilla/credits/05_credits_v003"

-- Lines 8-29
function RaidMenuCreditsGui:init(ws, fullscreen_ws, node, component_name)
	managers.music:stop()
	RaidMenuOptionsControls.super.init(self, ws, fullscreen_ws, node, component_name)
	self._node.components.raid_menu_header:set_screen_name("menu_credits")
	self._node.components.raid_menu_footer:hide_name_and_gold_panel()

	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		local con = managers.controller:create_controller("boot_" .. index, index, false)

		con:enable()

		self._controller_list[index] = con
	end

	self:_build_credits_panel(node._parameters.credits_file)
	self:_show_intro_video()
	self:bind_controller_inputs()
	managers.controller:add_hotswap_callback("event_complete_state", callback(self, self, "on_controller_hotswap"))
end

-- Lines 31-136
function RaidMenuCreditsGui:_build_credits_panel(file)
	local lang_key = SystemInfo:language():key()
	local files = {
		[Idstring("german"):key()] = "_german",
		[Idstring("french"):key()] = "_french",
		[Idstring("spanish"):key()] = "_spanish",
		[Idstring("italian"):key()] = "_italian"
	}

	if Application:region() == Idstring("eu") and file == "eula" then
		files[Idstring("english"):key()] = "_uk"
	end

	if (file == "eula" or file == "trial") and files[lang_key] then
		file = file .. files[lang_key] or file
	end

	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), (self.PATH .. file):id())
	local ypos = 0
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local res = RenderSettings.resolution
	local side_padding = 200
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._full_panel = self._fullscreen_ws:panel()
	self._safe_rect_workspace = Overlay:gui():create_screen_workspace()

	managers.gui_data:layout_workspace(self._safe_rect_workspace)

	self._safe_panel = self._safe_rect_workspace:panel()
	self._clipping_panel = self._fullscreen_ws:panel():panel({
		layer = 1
	})
	local text_offset = self._clipping_panel:height() - 50
	self._credits_panel = self._clipping_panel:panel({
		x = safe_rect_pixels.x + side_padding,
		y = text_offset,
		w = safe_rect_pixels.width - side_padding * 2,
		h = self._fullscreen_ws:panel():h()
	})

	self._credits_panel:set_center_x(self._credits_panel:parent():w() / 2)

	local text_width = self._credits_panel:width()
	self._commands = {}

	for _, data in ipairs(list) do
		if data._meta == "text" then
			local font_size, color = nil

			if data.type == "title" then
				font_size = tweak_data.gui.font_sizes.size_38
				color = tweak_data.gui.colors.raid_red
			elseif data.type == "name" then
				font_size = tweak_data.gui.font_sizes.small
				color = tweak_data.gui.colors.raid_dirty_white
			elseif data.type == "fill" then
				font_size = tweak_data.gui.font_sizes.small
				color = tweak_data.gui.colors.raid_red
			elseif data.type == "image-text" then
				font_size = tweak_data.gui.font_sizes.size_20
				color = tweak_data.gui.colors.raid_grey
			else
				Application:error("[RaidMenuCreditsGui][_build_credits_panel] Unknown text type")
			end

			local height = font_size + 5
			local text_field = self._credits_panel:text({
				vertical = "top",
				wrap = true,
				align = "center",
				word_wrap = true,
				halign = "left",
				x = 0,
				layer = 3,
				text = data.text,
				y = ypos,
				w = text_width,
				h = height,
				font_size = font_size,
				font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, font_size),
				color = color
			})
			ypos = ypos + height
		elseif data._meta == "image" then
			local bitmap = nil

			if data.src then
				bitmap = self._credits_panel:bitmap({
					x = 0,
					layer = 3,
					y = ypos,
					texture = data.src
				})
			elseif data.atlas_src then
				local icon_params = {
					texture = tweak_data.gui.icons[data.atlas_src].texture,
					texture_rect = tweak_data.gui.icons[data.atlas_src].texture_rect
				}
				bitmap = self._credits_panel:bitmap(icon_params)
			else
				Application:error("[RaidMenuCreditsGui][_build_credits_panel] Unknown image type")
			end

			local scale = data.scale or 1

			bitmap:set_width(bitmap:width() * scale)
			bitmap:set_height(bitmap:height() * scale)
			bitmap:set_center_x(self._credits_panel:width() / 2)

			ypos = ypos + bitmap:height()
		elseif data._meta == "br" then
			ypos = ypos + 32
		elseif data._meta == "command" then
			table.insert(self._commands, {
				pos = ypos - text_offset + (data.offset or 0) + self._clipping_panel:height() / 2,
				cmd = data.cmd,
				param = data.param
			})
		end
	end

	self._credits_panel:set_height(ypos + 50)
end

-- Lines 138-183
function RaidMenuCreditsGui:_show_intro_video()
	local video_panel_params = {
		is_root_panel = true,
		layer = 100
	}
	self._video_panel = RaidGUIPanel:new(self._full_panel, video_panel_params)
	local video_panel_background_params = {
		name = "video_background",
		layer = 1,
		color = Color.black
	}
	local video_panel_background = self._video_panel:rect(video_panel_background_params)
	local video_params = {
		layer = 2,
		layer = self._video_panel:layer() + 1,
		video = RaidMenuCreditsGui.INTRO_VIDEO,
		width = self._video_panel:w()
	}
	self._credits_intro_video = self._video_panel:video(video_params)

	self._credits_intro_video:set_h(self._video_panel:w() * self._credits_intro_video:video_height() / self._credits_intro_video:video_width())
	self._credits_intro_video:set_center_y(self._video_panel:h() / 2)

	self._playing_intro_video = true
	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"
	local press_any_key_params = {
		name = "press_any_key_prompt",
		alpha = 0,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_32),
		font_size = tweak_data.gui.font_sizes.size_32,
		text = utf8.to_upper(managers.localization:text(press_any_key_text)),
		color = tweak_data.gui.colors.raid_dirty_white,
		layer = self._credits_intro_video:layer() + 100
	}
	local press_any_key_prompt = self._safe_panel:text(press_any_key_params)
	local _, _, w, h = press_any_key_prompt:text_rect()

	press_any_key_prompt:set_w(w)
	press_any_key_prompt:set_h(h)
	press_any_key_prompt:set_right(self._safe_panel:w() - 50)
	press_any_key_prompt:set_bottom(self._safe_panel:h() - 50)
	press_any_key_prompt:animate(callback(self, self, "_animate_show_press_any_key_prompt"))
end

-- Lines 185-200
function RaidMenuCreditsGui:_animate_show_press_any_key_prompt(prompt)
	local duration = 0.7
	local t = 0

	wait(3)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.85, duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.85)
end

-- Lines 202-235
function RaidMenuCreditsGui:_animate_change_press_any_key_prompt(prompt)
	local fade_out_duration = 0.25
	local t = (1 - prompt:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0.85, -0.85, fade_out_duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0)

	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"

	prompt:set_text(utf8.to_upper(managers.localization:text(press_any_key_text)))

	local _, _, w, h = prompt:text_rect()

	prompt:set_w(w)
	prompt:set_h(h)
	prompt:set_right(self._safe_panel:w() - 50)

	local fade_in_duration = 0.25
	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.85, fade_in_duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.85)
end

-- Lines 237-244
function RaidMenuCreditsGui:on_controller_hotswap()
	local press_any_key_prompt = self._safe_panel:child("press_any_key_prompt")

	if press_any_key_prompt then
		press_any_key_prompt:stop()
		press_any_key_prompt:animate(callback(self, self, "_animate_change_press_any_key_prompt"))
	end
end

-- Lines 246-264
function RaidMenuCreditsGui:update(t, dt)
	if self._playing_intro_video and (self:is_playing() and self:is_skipped() or not self:is_playing()) then
		self._credits_intro_video:destroy()

		if self._video_panel:engine_panel_alive() then
			self._video_panel:remove(self._credits_intro_video)
			self._video_panel:remove_background()
			self._video_panel:remove(self._video_panel:child("video_background"))
			self._video_panel:remove(self._video_panel:child("disclaimer"))
		end

		self._credits_intro_video = nil
		self._video_panel = nil
		self._playing_intro_video = false

		if alive(self._safe_panel) then
			self._safe_panel:child("press_any_key_prompt"):stop()
			self._safe_panel:remove(self._safe_panel:child("press_any_key_prompt"))
		end

		self:_skip_video()
	end
end

-- Lines 266-272
function RaidMenuCreditsGui:is_playing()
	if alive(self._credits_intro_video) then
		return self._credits_intro_video:loop_count() < 1
	else
		return false
	end
end

-- Lines 274-282
function RaidMenuCreditsGui:is_skipped()
	for _, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			return true
		end
	end

	return false
end

-- Lines 284-313
function RaidMenuCreditsGui:_skip_video()
	managers.music:post_event(MusicManager.CREDITS_MUSIC)

	-- Lines 287-308
	local function scroll_func(o)
		local y = o:top()
		local speed = 50

		while true do
			y = y - coroutine.yield() * speed

			o:set_top(math.round(y))

			if self._commands[1] and y < -self._commands[1].pos then
				local cmd = table.remove(self._commands, 1)

				if cmd.cmd == "speed" then
					speed = cmd.param
				elseif cmd.cmd == "close" then
					managers.menu:back()

					return
				elseif cmd.cmd == "stop" then
					return
				end
			end
		end
	end

	if alive(self._credits_panel) then
		self._credits_panel_thread = self._credits_panel:animate(scroll_func)
	end
end

-- Lines 316-318
function RaidMenuCreditsGui:_setup_panels(node)
	RaidMenuCreditsGui.super._setup_panels(self, node)
end

-- Lines 320-322
function RaidMenuCreditsGui:_create_menu_item(row_item)
	RaidMenuCreditsGui.super._create_menu_item(self, row_item)
end

-- Lines 324-326
function RaidMenuCreditsGui:_setup_item_panel_parent(safe_rect)
	RaidMenuCreditsGui.super._setup_item_panel_parent(self, safe_rect)
end

-- Lines 328-330
function RaidMenuCreditsGui:_setup_item_panel(safe_rect, res)
	RaidMenuCreditsGui.super._setup_item_panel(self, safe_rect, res)
end

-- Lines 332-334
function RaidMenuCreditsGui:resolution_changed()
	RaidMenuCreditsGui.super.resolution_changed(self)
end

-- Lines 336-343
function RaidMenuCreditsGui:set_visible(visible)
	RaidMenuCreditsGui.super.set_visible(self, visible)

	if visible then
		self._fullscreen_ws:show()
	else
		self._fullscreen_ws:hide()
	end
end

-- Lines 345-354
function RaidMenuCreditsGui:close(...)
	managers.controller:remove_hotswap_callback("event_complete_state")
	self._credits_panel:stop(self._credits_panel_thread)
	Overlay:gui():destroy_workspace(self._fullscreen_ws)
	Overlay:gui():destroy_workspace(self._safe_rect_workspace)
	RaidMenuCreditsGui.super.close(self, ...)
	managers.music:post_event(MusicManager.MENU_MUSIC)
end

-- Lines 356-358
function RaidMenuCreditsGui:mouse_moved(o, x, y)
	return false
end

-- Lines 360-362
function RaidMenuCreditsGui:mouse_released(o, button, x, y)
	return false
end

-- Lines 364-366
function RaidMenuCreditsGui:mouse_pressed(button, x, y)
	return false
end

-- Lines 368-370
function RaidMenuCreditsGui:mouse_clicked(button, x, y)
	return false
end

-- Lines 372-374
function RaidMenuCreditsGui:mouse_double_click(o, button, x, y)
	return true
end

-- Lines 376-378
function RaidMenuCreditsGui:confirm_pressed()
	return true
end

-- Lines 380-383
function RaidMenuCreditsGui:back_pressed()
	managers.raid_menu:on_escape()

	return true
end

-- Lines 385-387
function RaidMenuCreditsGui:move_up()
	return true
end

-- Lines 389-391
function RaidMenuCreditsGui:move_down()
	return true
end

-- Lines 393-395
function RaidMenuCreditsGui:move_left()
	return true
end

-- Lines 397-399
function RaidMenuCreditsGui:move_right()
	return true
end

-- Lines 403-413
function RaidMenuCreditsGui:bind_controller_inputs()
	local legend = {
		controller = {
			"menu_legend_back"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "back_pressed", nil)
			}
		}
	}

	self:set_legend(legend)
end
