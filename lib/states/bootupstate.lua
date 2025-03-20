require("lib/states/GameState")

BootupState = BootupState or class(GameState)
BootupState.MAX_WAIT_TIME = 25
BootupState.NUM_SPLASH_SCREENS = 3

function BootupState:init(game_state_machine, setup)
	GameState.init(self, "bootup", game_state_machine)

	if setup then
		self:setup()
	end

	Global.controller_index = 1
end

function BootupState:setup()
	local res = RenderSettings.resolution
	local safe_rect_pixels = managers.gui_data:scaled_size()
	local gui = Overlay:gui()
	local is_win32 = IS_PC
	local show_esrb = false
	self._full_workspace = gui:create_screen_workspace()
	self._workspace = managers.gui_data:create_saferect_workspace()

	self._workspace:hide()
	self._full_workspace:hide()
	managers.gui_data:layout_workspace(self._workspace)

	local image_w = safe_rect_pixels.width
	local image_h = safe_rect_pixels.height
	local can_skip = true
	local has_full_game = managers.dlc:has_full_game()
	local legal_text = managers.localization:text("legal_text")
	local item_layer = 10
	local fade_time = 0.85
	self._play_data_list = {}

	if not is_win32 then
		table.insert(self._play_data_list, {
			can_skip = false,
			height = 200,
			width = 600,
			duration = 6,
			gui = Idstring("guis/autosave_warning"),
			layer = item_layer,
			fade_in = fade_time,
			fade_out = fade_time
		})
	end

	table.insert(self._play_data_list, {
		duration = 4.5,
		can_skip = has_full_game,
		texture = tweak_data.gui.icons.bootup_logo_sb.texture,
		texture_rect = tweak_data.gui.icons.bootup_logo_sb.texture_rect,
		layer = item_layer,
		width = image_h,
		height = image_h,
		fade_in = fade_time,
		fade_out = fade_time
	})
	table.insert(self._play_data_list, {
		duration = 4.5,
		auto_skip = true,
		can_skip = has_full_game,
		texture = tweak_data.gui.icons.bootup_logo_lgl.texture,
		texture_rect = tweak_data.gui.icons.bootup_logo_lgl.texture_rect,
		layer = item_layer,
		width = image_h,
		height = image_h,
		fade_in = fade_time,
		fade_out = fade_time
	})
	table.insert(self._play_data_list, {
		duration = 5,
		auto_skip = true,
		can_skip = has_full_game,
		texture = tweak_data.gui.icons.bootup_logo_third_parties.texture,
		texture_rect = tweak_data.gui.icons.bootup_logo_third_parties.texture_rect,
		layer = item_layer,
		width = image_w,
		height = image_w / 2,
		fade_in = fade_time,
		fade_out = fade_time
	})

	local lato_path = tweak_data.gui:get_font_path(tweak_data.gui.fonts.lato, tweak_data.gui.font_sizes.size_16)
	self._full_panel = self._full_workspace:panel()
	self._panel = self._workspace:panel()

	self._full_panel:rect({
		layer = 0,
		visible = false,
		color = Color.red
	})

	local press_any_key_font_size = tweak_data.gui.font_sizes.medium
	local press_any_key_prompt_params = {
		layer = 3,
		alpha = 0,
		name = "press_any_key_text",
		wrap = true,
		vertical = "bottom",
		align = "center",
		w = self._full_panel:w(),
		h = press_any_key_font_size,
		font = tweak_data.gui:get_font_path(MenuTitlescreenState.FONT, press_any_key_font_size),
		font_size = press_any_key_font_size,
		color = MenuTitlescreenState.TEXT_COLOR,
		text = utf8.to_upper(managers.localization:text(IS_PC and "press_any_key" or "press_any_key_to_skip_controller"))
	}
	self._press_any_key_text = self._full_panel:text(press_any_key_prompt_params)
	local _, _, _, h = self._press_any_key_text:text_rect()

	self._press_any_key_text:set_h(h)
	self._press_any_key_text:set_center_y(self._full_panel:h() - MenuTitlescreenState.LEGAL_TEXT_CENTER_Y)
	self._press_any_key_text:set_alpha(0)

	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		local con = managers.controller:create_controller("boot_" .. index, index, false)

		con:enable()

		self._controller_list[index] = con
	end

	self._bootup_t = Application:time()
end

function BootupState:at_enter()
	managers.menu:input_enabled(false)

	if not self._controller_list then
		self:setup()
		Application:stack_dump_error("Shouldn't enter boot state more than once. Except when toggling freeflight.")
	end

	self._sound_listener = SoundDevice:create_listener("main_menu")

	self._sound_listener:activate(true)
	self._workspace:show()
	self._full_workspace:show()

	self._clbk_game_has_music_control_callback = callback(self, self, "clbk_game_has_music_control")

	managers.platform:add_event_callback("media_player_control", self._clbk_game_has_music_control_callback)
	self:play_next()

	if Global.exe_argument_level then
		self:gsm():change_state_by_name("menu_titlescreen")
	end
end

function BootupState:clbk_game_has_music_control(status)
	if self._play_data and self._play_data.video then
		self._gui_obj:set_volume_gain(status and 1 or 0)
	end
end

function BootupState:update(t, dt)
	local now = Application:time()
	self.next_message_t = self.next_message_t or now + 1

	if self.next_message_t < now and not PackageManager:all_packages_loaded() then
		Application:debug("[BootupState:update] Waiting for packages to load...")

		self.next_message_t = now + 1
	end

	if not IS_PC and PackageManager:all_packages_loaded() and self._play_index == 2 and self._press_any_key_text:alpha() == 0 then
		self._full_panel:animate(callback(self, self, "_animate_press_any_key"))
	end

	self:check_confirm_pressed()

	local is_skipped = self:is_skipped()

	if not self:is_playing() or (self._play_data.can_skip or Global.override_bootup_can_skip) and is_skipped then
		self:play_next(is_skipped)
	else
		self:update_fades()
	end
end

function BootupState:check_confirm_pressed()
	for index, controller in ipairs(self._controller_list) do
		if controller:get_input_pressed("confirm") then
			print("check_confirm_pressed")

			local active, dialog = managers.system_menu:is_active_by_id("invite_join_message")

			if active then
				print("close")
				dialog:button_pressed_callback()
			end
		end
	end
end

function BootupState:update_fades()
	local time, duration = nil

	if self._play_data.video then
		duration = self._gui_obj:length()
		local frames = self._gui_obj:frames()

		if frames > 0 then
			time = self._gui_obj:frame_num() / frames * duration
		else
			time = 0
		end
	else
		time = TimerManager:game():time() - self._play_time
		duration = self._play_data.duration
	end

	local old_fade = self._fade

	if self._play_data.fade_in and time < self._play_data.fade_in then
		if self._play_data.fade_in > 0 then
			self._fade = time / self._play_data.fade_in
		else
			self._fade = 1
		end
	elseif self._play_data.fade_in and duration - time < self._play_data.fade_out then
		if self._play_data.fade_out > 0 then
			self._fade = (duration - time) / self._play_data.fade_out
		else
			self._fade = 0
		end
	else
		self._fade = 1
	end

	if self._fade ~= old_fade then
		self:apply_fade()
	end
end

function BootupState:apply_fade()
	if self._play_data.gui then
		local script = self._gui_obj.script and self._gui_obj:script()

		if script.set_fade then
			script:set_fade(self._fade)
		else
			Application:error("GUI \"" .. tostring(self._play_data.gui) .. "\" lacks a function set_fade( o, fade ).")
		end
	else
		self._gui_obj:set_color(self._gui_obj:color():with_alpha(self._fade))
	end
end

function BootupState:is_skipped()
	if not IS_PC and not PackageManager:all_packages_loaded() and self._play_index > 1 and Application:time() < self._bootup_t + BootupState.MAX_WAIT_TIME then
		return false
	end

	for index, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			Global.controller_index = index

			return true
		end
	end

	return false
end

function BootupState:is_playing()
	if alive(self._gui_obj) then
		if self._gui_obj.loop_count then
			return self._gui_obj:loop_count() < 1
		else
			return TimerManager:game():time() < self._play_time + self._play_data.duration
		end
	else
		return false
	end
end

function BootupState:_animate_press_any_key()
	local press_any_key_fade_in_duration = 0.3
	local t = 0

	while press_any_key_fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in_out(t, 0, 0.8, press_any_key_fade_in_duration)

		self._press_any_key_text:set_alpha(current_alpha)
	end

	self._press_any_key_text:set_alpha(0.8)
end

function BootupState:play_next(is_skipped)
	self._play_time = TimerManager:game():time()
	self._play_index = (self._play_index or 0) + 1
	self._play_data = self._play_data_list[self._play_index]

	if self._play_index == 1 then
		managers.dyn_resource:set_file_streaming_profile(self._file_streaming_profile())
		Application:debug("[BootupState:play_next] file streamer started")
	end

	if is_skipped then
		while self._play_data and self._play_data.auto_skip do
			self._play_index = self._play_index + 1
			self._play_data = self._play_data_list[self._play_index]
		end
	end

	if self._play_data then
		self._fade = self._play_data.fade_in and 0 or 1

		if alive(self._gui_obj) then
			self._panel:remove(self._gui_obj)

			if alive(self._gui_obj) then
				self._full_panel:remove(self._gui_obj)
			end

			self._gui_obj = nil
		end

		local res = RenderSettings.resolution
		local width, height = nil
		local padding = self._play_data.padding or 0

		if self._play_data.gui then
			if self._play_data.width / self._play_data.height > res.x / res.y then
				width = res.x - padding * 2
				height = self._play_data.height * width / self._play_data.width
			else
				height = self._play_data.height
				width = self._play_data.width
			end
		else
			height = self._play_data.height
			width = self._play_data.width
		end

		local x = (self._panel:w() - width) / 2
		local y = (self._panel:h() - height) / 2
		local gui_config = {
			x = x,
			y = y,
			width = width,
			height = height,
			layer = tweak_data.gui.BOOT_SCREEN_LAYER
		}

		if self._play_data.video then
			gui_config.video = self._play_data.video
			gui_config.layer = self._play_data.layer or gui_config.layer
			self._gui_obj = self._full_panel:video(gui_config)

			if managers.music:has_music_control() then
				self._gui_obj:set_volume_gain(0.75)
			else
				self._gui_obj:set_volume_gain(0)
			end

			local w = self._gui_obj:video_width()
			local h = self._gui_obj:video_height()
			local m = h / w

			self._gui_obj:set_size(res.x, res.x * m)
			self._gui_obj:set_center(res.x / 2, res.y / 2)
			self._gui_obj:play()
		elseif self._play_data.texture then
			gui_config.texture = self._play_data.texture
			gui_config.texture_rect = self._play_data.texture_rect
			gui_config.layer = self._play_data.layer or gui_config.layer
			self._gui_obj = self._panel:bitmap(gui_config)
		elseif self._play_data.text then
			gui_config.text = self._play_data.text
			gui_config.font = self._play_data.font
			gui_config.font_size = self._play_data.font_size
			gui_config.wrap = self._play_data.wrap
			gui_config.word_wrap = self._play_data.word_wrap
			gui_config.y = 850
			self._gui_obj = self._panel:text(gui_config)
		elseif self._play_data.gui then
			self._gui_obj = self._panel:gui(self._play_data.gui)

			self._gui_obj:set_shape(x, y, width, height)

			local script = self._gui_obj:script()

			if script.setup then
				script:setup(self._workspace)
			end
		end

		self:apply_fade()
	else
		self:gsm():change_state_by_name("menu_titlescreen")
	end
end

function BootupState:at_exit()
	Application:debug("[BootupState] at_exit")
	managers.platform:remove_event_callback("media_player_control", self._clbk_game_has_music_control_callback)

	if alive(self._workspace) then
		Overlay:gui():destroy_workspace(self._workspace)

		self._workspace = nil
		self._gui_obj = nil
	end

	if alive(self._full_workspace) then
		Overlay:gui():destroy_workspace(self._full_workspace)

		self._full_workspace = nil
	end

	if self._controller_list then
		for _, controller in ipairs(self._controller_list) do
			controller:destroy()
		end

		self._controller_list = nil
	end

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end

	self._play_data_list = nil
	self._play_index = nil
	self._play_data = nil

	managers.menu:input_enabled(true)
end

function BootupState:is_joinable()
	return false
end

function BootupState._file_streaming_profile()
	return DynamicResourceManager.STREAMING_PROFILE_LOADING
end
