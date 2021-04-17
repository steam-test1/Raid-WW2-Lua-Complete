require("lib/states/GameState")

MenuTitlescreenState = MenuTitlescreenState or class(GameState)
MenuTitlescreenState.BACKGROUND_IMAGE = "ui/backgrounds/raid_main_bg_hud"
MenuTitlescreenState.FONT = tweak_data.gui.fonts.din_compressed
MenuTitlescreenState.TEXT_COLOR = Color.white
MenuTitlescreenState.LEGAL_TEXT_FONT = tweak_data.gui.fonts.lato
MenuTitlescreenState.LEGAL_TEXT_CENTER_Y = 0.9
MenuTitlescreenState.LEGAL_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_18
MenuTitlescreenState.PRESS_ANY_KEY_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_32
MenuTitlescreenState.GAME_LOGO_IMAGE = "raid_logo_big"
MenuTitlescreenState.GAME_LOGO_CENTER_Y = 640

function MenuTitlescreenState:init(game_state_machine, setup)
	GameState.init(self, "menu_titlescreen", game_state_machine)

	if setup then
		self:setup()
	end
end

local is_ps3 = SystemInfo:platform() == Idstring("PS3")
local is_ps4 = SystemInfo:platform() == Idstring("PS4")
local is_xb1 = SystemInfo:platform() == Idstring("XB1")
local is_x360 = SystemInfo:platform() == Idstring("X360")
local is_win32 = SystemInfo:platform() == Idstring("WIN32")

function MenuTitlescreenState:setup()
	local res = RenderSettings.resolution
	local gui = Overlay:gui()
	self._workspace = managers.gui_data:create_saferect_workspace()

	self._workspace:hide()
	managers.gui_data:layout_workspace(self._workspace)

	self._full_workspace = gui:create_screen_workspace()

	self._full_workspace:hide()

	local x_scale, y_scale = self:_resolution_scale()

	self._full_workspace:panel():rect({
		visible = false,
		color = Color.black
	})

	local background_params = {
		name = "title_screen_background_image",
		alpha = 0,
		layer = 1,
		texture = MenuTitlescreenState.BACKGROUND_IMAGE
	}
	self._background = self._full_workspace:panel():bitmap(background_params)
	local panel = self._full_workspace:panel()
	local screen_ratio = self:_real_aspect_ratio()
	local image_ratio = self._background:texture_width() / self._background:texture_height()

	if screen_ratio < image_ratio then
		self._background:set_h(panel:h())
		self._background:set_w(panel:w())
	else
		self._background:set_w(panel:w())
		self._background:set_h(panel:h())
	end

	self._background:set_center_x(self._full_workspace:panel():w() / 2)
	self._background:set_center_y(self._full_workspace:panel():h() / 2)

	local gradient_params = {
		valign = "grow",
		name = "text_background_gradient",
		h = 270,
		y = 0,
		orientation = "vertical",
		x = 0,
		w = self._full_workspace:panel():w(),
		gradient_points = {
			0,
			Color.black:with_alpha(0),
			0.2,
			Color.black:with_alpha(0.2),
			1,
			Color.black:with_alpha(1)
		},
		layer = self._background:layer() + 10
	}
	self._text_gradient = self._full_workspace:panel():gradient(gradient_params)

	self._text_gradient:set_bottom(self._full_workspace:panel():h())

	local logo_params = {
		name = "title_screen_game_logo",
		alpha = 0,
		texture = tweak_data.gui.icons[MenuTitlescreenState.GAME_LOGO_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[MenuTitlescreenState.GAME_LOGO_IMAGE].texture_rect,
		w = tweak_data.gui:icon_w(MenuTitlescreenState.GAME_LOGO_IMAGE) * y_scale,
		h = tweak_data.gui:icon_h(MenuTitlescreenState.GAME_LOGO_IMAGE) * y_scale,
		layer = self._text_gradient:layer() + 1
	}
	self._game_logo = self._full_workspace:panel():bitmap(logo_params)

	self._game_logo:set_center_x(self._game_logo:parent():w() / 2)
	self._game_logo:set_center_y(self:_recalculate_y_for_current_resolution(MenuTitlescreenState.GAME_LOGO_CENTER_Y))

	local legal_text_font_size = MenuTitlescreenState.LEGAL_TEXT_FONT_SIZE
	local legal_text_params = {
		vertical = "bottom",
		wrap = true,
		align = "center",
		name = "legal_text",
		alpha = 0,
		layer = 50,
		w = self._workspace:panel():w(),
		h = self._workspace:panel():h(),
		font = tweak_data.gui:get_font_path(MenuTitlescreenState.LEGAL_TEXT_FONT, legal_text_font_size),
		font_size = legal_text_font_size,
		color = MenuTitlescreenState.TEXT_COLOR,
		text = managers.localization:text("legal_text")
	}
	self._legal_text = self._workspace:panel():text(legal_text_params)
	local _, _, _, h = self._legal_text:text_rect()

	self._legal_text:set_h(h)
	self._legal_text:set_center_y(self._workspace:panel():h() * MenuTitlescreenState.LEGAL_TEXT_CENTER_Y)

	local press_any_key_font_size = MenuTitlescreenState.PRESS_ANY_KEY_TEXT_FONT_SIZE
	local press_any_key_prompt_params = {
		vertical = "bottom",
		wrap = true,
		align = "center",
		name = "press_any_key_text",
		alpha = 0,
		w = self._workspace:panel():w(),
		h = self._workspace:panel():h(),
		font = tweak_data.gui:get_font_path(MenuTitlescreenState.FONT, press_any_key_font_size),
		font_size = press_any_key_font_size,
		color = MenuTitlescreenState.TEXT_COLOR,
		text = utf8.to_upper(managers.localization:text("press_any_key")),
		layer = self._legal_text:layer()
	}
	self._press_any_key_text = self._workspace:panel():text(press_any_key_prompt_params)
	local _, _, _, h = self._press_any_key_text:text_rect()

	self._press_any_key_text:set_h(h)
	self._press_any_key_text:set_center_y(self._workspace:panel():h() * MenuTitlescreenState.LEGAL_TEXT_CENTER_Y)

	local text_id = (is_ps3 or is_x360 or is_ps4 or is_xb1) and "menu_press_start" or "menu_visit_forum3"
	local din_path = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_24)
	local text = self._workspace:panel():text({
		vertical = "bottom",
		align = "center",
		visible = false,
		layer = 2,
		text = managers.localization:text(text_id),
		font = din_path,
		font_size = tweak_data.gui.font_sizes.size_24,
		color = Color.white,
		w = self._workspace:panel():w(),
		h = self._workspace:panel():h()
	})

	text:set_bottom(self._workspace:panel():h() / 1.1)

	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		self._controller_list[index] = managers.controller:create_controller("title_" .. index, index, false)

		if is_win32 and self._controller_list[index]:get_type() == "xbox360" then
			self._controller_list[index]:add_connect_changed_callback(callback(self, self, "_update_pc_xbox_controller_connection", {
				text_gui = text,
				text_id = text_id
			}))
		end
	end

	if is_win32 then
		self:_update_pc_xbox_controller_connection({
			text_gui = text,
			text_id = text_id
		})
	end

	self:reset_attract_video()
end

function MenuTitlescreenState:_resolution_scale()
	local screen_resolution = Application:screen_resolution()
	local base_gui_resolution = tweak_data.gui.base_resolution
	local x_scale = screen_resolution.x / base_gui_resolution.x
	local y_scale = screen_resolution.y / base_gui_resolution.y

	return x_scale, y_scale
end

function MenuTitlescreenState:_recalculate_y_for_current_resolution(y)
	local screen_resolution = Application:screen_resolution()
	local base_gui_resolution = tweak_data.gui.base_resolution

	return y / base_gui_resolution.y * screen_resolution.y
end

function MenuTitlescreenState:_real_aspect_ratio()
	if SystemInfo:platform() == Idstring("WIN32") then
		return RenderSettings.aspect_ratio
	else
		local screen_res = Application:screen_resolution()
		local screen_pixel_aspect = screen_res.x / screen_res.y

		return screen_pixel_aspect
	end
end

function MenuTitlescreenState:_update_pc_xbox_controller_connection(params)
	local text_string = managers.localization:to_upper_text(params.text_id)
	local added_text = nil

	for _, controller in pairs(self._controller_list) do
		if controller:get_type() == "xbox360" and controller:connected() then
			text_string = text_string .. "\n" .. managers.localization:to_upper_text("menu_or_press_any_xbox_button")

			break
		end
	end

	params.text_gui:set_text(text_string)
end

function MenuTitlescreenState:at_enter()
	if not self._controller_list then
		self:setup()
		Application:stack_dump_error("Shouldn't enter title more than once. Except when toggling freeflight.")
	end

	managers.menu:input_enabled(false)

	for index, controller in ipairs(self._controller_list) do
		controller:enable()
	end

	self._workspace:show()
	self._full_workspace:show()
	managers.user:set_index(nil)
	managers.controller:set_default_wrapper_index(nil)

	self._clbk_game_has_music_control_callback = callback(self, self, "clbk_game_has_music_control")

	managers.platform:add_event_callback("media_player_control", self._clbk_game_has_music_control_callback)
	self:reset_attract_video()
	self._background:stop()
	self._background:animate(callback(self, self, "_animate_screen_display"))
end

function MenuTitlescreenState:clbk_game_has_music_control(status)
	if alive(self._attract_video_gui) then
		self._attract_video_gui:set_volume_gain(status and 1 or 0)
	end
end

function MenuTitlescreenState:update(t, dt)
	if self._waiting_for_loaded_savegames then
		if not managers.savefile:is_in_loading_sequence() and not self._user_has_changed and not self._any_key_pressed then
			self:_load_savegames_done()
		end

		return
	end

	self:check_confirm_pressed()

	if managers.system_menu:is_active() then
		self:reset_attract_video()
	else
		if Global.exe_argument_level then
			self._controller_index = 1
		else
			self._controller_index = self:get_start_pressed_controller_index()
		end

		if self._controller_index then
			managers.controller:set_default_wrapper_index(self._controller_index)
			managers.user:set_index(self._controller_index)
			managers.user:check_user(callback(self, self, "check_user_callback"), true)

			if managers.dlc:has_corrupt_data() and not Global.corrupt_dlc_msg_shown then
				Global.corrupt_dlc_msg_shown = true

				print("[MenuTitlescreenState:update] showing corrupt_DLC")
				managers.menu:show_corrupt_dlc()
			end
		elseif not self:check_attract_video() and self:is_attract_video_delay_done() then
			self:play_attract_video()
		end
	end
end

function MenuTitlescreenState:get_start_pressed_controller_index()
	for index, controller in ipairs(self._controller_list) do
		if is_ps4 or is_xb1 then
			if controller:get_input_pressed("confirm") then
				return index
			end
		elseif is_ps3 or is_x360 then
			if controller:get_input_pressed("start") then
				return index
			end
		else
			if controller:get_any_input_pressed() then
				return index
			end

			if controller._default_controller_id == "keyboard" and (#Input:keyboard():pressed_list() > 0 or #Input:mouse():pressed_list() > 0) then
				return index
			end
		end
	end

	return nil
end

function MenuTitlescreenState:check_confirm_pressed()
	for index, controller in ipairs(self._controller_list) do
		if controller:get_input_pressed("confirm") then
			print("check_confirm_pressed")

			local active, dialog = managers.system_menu:is_active_by_id("invite_join_message")

			if active then
				print("close")
				dialog:button_pressed_callback()
			end

			local active, dialog = managers.system_menu:is_active_by_id("user_changed")

			if active then
				print("close user_changed")
				dialog:button_pressed_callback()
			end

			local active, dialog = managers.system_menu:is_active_by_id("inactive_user_accepted_invite")

			if active then
				print("close inactive_user_accepted_invite")
				dialog:button_pressed_callback()
			end
		end
	end
end

function MenuTitlescreenState:check_user_callback(success)
	managers.dlc:on_signin_complete()

	if success then
		managers.user:check_storage(callback(self, self, "check_storage_callback"), true)
	else
		local dialog_data = {
			title = managers.localization:text("dialog_warning_title"),
			text = managers.localization:text("dialog_skip_signin_warning")
		}
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = callback(self, self, "continue_without_saving_yes_callback")
		}
		local no_button = {
			text = managers.localization:text("dialog_no"),
			callback_func = callback(self, self, "continue_without_saving_no_callback"),
			class = RaidGUIControlButtonShortSecondary
		}
		dialog_data.button_list = {
			yes_button,
			no_button
		}

		managers.system_menu:show(dialog_data)
	end
end

function MenuTitlescreenState:check_storage_callback(success)
	if success then
		self._waiting_for_loaded_savegames = true
	else
		local dialog_data = {
			title = managers.localization:text("dialog_warning_title"),
			text = managers.localization:text("dialog_skip_storage_warning")
		}
		local yes_button = {
			text = managers.localization:text("dialog_yes"),
			callback_func = callback(self, self, "continue_without_saving_yes_callback")
		}
		local no_button = {
			text = managers.localization:text("dialog_no"),
			callback_func = callback(self, self, "continue_without_saving_no_callback"),
			class = RaidGUIControlButtonShortSecondary
		}
		dialog_data.button_list = {
			yes_button,
			no_button
		}

		managers.system_menu:show(dialog_data)
	end
end

function MenuTitlescreenState:_load_savegames_done()
	self._background:stop()
	self._background:animate(callback(self, self, "_animate_any_key_pressed"))
end

function MenuTitlescreenState:continue_without_saving_yes_callback()
	self._background:stop()
	self._background:animate(callback(self, self, "_animate_any_key_pressed"))
end

function MenuTitlescreenState:continue_without_saving_no_callback()
	managers.user:set_index(nil)
	managers.controller:set_default_wrapper_index(nil)
end

function MenuTitlescreenState:check_attract_video()
	if alive(self._attract_video_gui) then
		if self._attract_video_gui:loop_count() > 0 or self:is_any_input_pressed() then
			self:reset_attract_video()
		else
			return true
		end
	elseif self:is_any_input_pressed() then
		self:reset_attract_video()
	end

	return false
end

function MenuTitlescreenState:is_any_input_pressed()
	for _, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			return true
		end
	end

	return false
end

function MenuTitlescreenState:reset_attract_video()
	self._attract_video_time = TimerManager:main():time()

	if alive(self._attract_video_gui) then
		self._attract_video_gui:stop()
		self._full_workspace:panel():remove(self._attract_video_gui)
		self._full_workspace:panel():remove(self._attract_video_background)

		self._attract_video_gui = nil
		self._attract_video_background = nil
	end
end

function MenuTitlescreenState:is_attract_video_delay_done()
	return TimerManager:main():time() > self._attract_video_time + _G.tweak_data.states.title.ATTRACT_VIDEO_DELAY
end

function MenuTitlescreenState:play_attract_video()
	self:reset_attract_video()

	local res = RenderSettings.resolution
	local src_width = 1920
	local src_height = 1080
	local dest_width, dest_height = nil

	if src_width / src_height > res.x / res.y then
		dest_width = res.x
		dest_height = src_height * dest_width / src_width
	else
		dest_height = res.y
		dest_width = src_width * dest_height / src_height
	end

	local x = (res.x - dest_width) / 2
	local y = (res.y - dest_height) / 2
	self._attract_video_background = self._full_workspace:panel():rect({
		color = Color.black,
		layer = tweak_data.gui.ATTRACT_SCREEN_LAYER - 1
	})
	self._attract_video_gui = self._full_workspace:panel():video({
		video = "movies/vanilla/attract_video",
		x = x,
		y = y,
		width = dest_width,
		height = dest_height,
		layer = tweak_data.gui.ATTRACT_SCREEN_LAYER
	})

	self._attract_video_gui:set_h(self._full_workspace:panel():w() * self._attract_video_gui:video_height() / self._attract_video_gui:video_width())
	self._attract_video_gui:set_center_y(self._full_workspace:panel():h() / 2)
	self._attract_video_gui:play()
	self._attract_video_gui:set_volume_gain(managers.music:has_music_control() and 1 or 0)
end

function MenuTitlescreenState:at_exit()
	managers.platform:remove_event_callback("media_player_control", self._clbk_game_has_music_control_callback)

	if alive(self._workspace) then
		Overlay:gui():destroy_workspace(self._workspace)

		self._workspace = nil
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

	managers.menu:input_enabled(true)
	managers.user:set_active_user_state_change_quit(true)
	managers.system_menu:init_finalize()
end

function MenuTitlescreenState:on_user_changed(old_user_data, user_data)
	print("MenuTitlescreenState:on_user_changed")

	if old_user_data and old_user_data.signin_state ~= "not_signed_in" and self._waiting_for_loaded_savegames then
		self._user_has_changed = true
	end
end

function MenuTitlescreenState:on_storage_changed(old_user_data, user_data)
	print("MenuTitlescreenState:on_storage_changed")

	if self._waiting_for_loaded_savegames then
		self._waiting_for_loaded_savegames = nil
	end
end

function MenuTitlescreenState:_animate_screen_display(background)
	local t = 0
	local fade_in_duration = 1

	self._background:set_alpha(0)
	self._game_logo:set_alpha(0)
	self._legal_text:set_alpha(0)
	self._press_any_key_text:set_alpha(0)

	while t < fade_in_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in_out(t, 0, 1, fade_in_duration)

		self._background:set_alpha(current_alpha)
		self._game_logo:set_alpha(current_alpha)
		self._legal_text:set_alpha(current_alpha)
	end

	self._background:set_alpha(1)
	self._game_logo:set_alpha(1)
	self._legal_text:set_alpha(1)
	wait(4)

	local legal_text_fade_out_duration = 0.3
	t = 0

	while legal_text_fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in_out(t, 1, -1, legal_text_fade_out_duration)

		self._legal_text:set_alpha(current_alpha)
	end

	self._legal_text:set_alpha(0)
	wait(0.1)

	local press_any_key_fade_in_duration = 0.3
	t = 0

	while press_any_key_fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in_out(t, 0, 1, press_any_key_fade_in_duration)

		self._press_any_key_text:set_alpha(current_alpha)
	end

	self._press_any_key_text:set_alpha(1)
end

function MenuTitlescreenState:_animate_any_key_pressed(background)
	local t = 0
	local fade_out_duration = 0.4
	self._any_key_pressed = true

	while t < fade_out_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in_out(t, 1, -1, fade_out_duration)

		self._workspace:panel():set_alpha(current_alpha)
		self._full_workspace:panel():set_alpha(current_alpha)
	end

	self._workspace:panel():set_alpha(0)
	self._full_workspace:panel():set_alpha(0)

	local sound_source = SoundDevice:create_source("MenuTitleScreen")

	sound_source:post_event("menu_enter")
	self:gsm():change_state_by_name("menu_main")
end
