UserManager = UserManager or {}
UserManager.PLATFORM_CLASS_MAP = {}

function UserManager:new(...)
	local key = PLATFORM:key()
	local manager_class = self.PLATFORM_CLASS_MAP[key] or GenericUserManager
	local manager = manager_class:new(...)

	return manager
end

GenericUserManager = GenericUserManager or class()
GenericUserManager.VERSION = 2
GenericUserManager.RESTRUCTURE_VERSION = 2
GenericUserManager.STORE_SETTINGS_ON_PROFILE = false
GenericUserManager.CAN_SELECT_USER = false
GenericUserManager.CAN_SELECT_STORAGE = false
GenericUserManager.NOT_SIGNED_IN_STATE = nil
GenericUserManager.CAN_CHANGE_STORAGE_ONLY_ONCE = true

function GenericUserManager:init()
	self._setting_changed_callback_handler_map = {}
	self._user_state_changed_callback_handler = CallbackEventHandler:new()
	self._active_user_state_changed_callback_handler = CallbackEventHandler:new()
	self._storage_changed_callback_handler = CallbackEventHandler:new()

	if not self:is_global_initialized() then
		Global.user_manager = {
			initializing = true,
			is_in_loading_sequence = nil,
			setting_map = {},
			user_map = {}
		}
		self._global = Global.user_manager

		self:setup_setting_map()

		Global.user_manager.initializing = nil
	end

	self._global = Global.user_manager
	self._key_rebind_skip_first_activate_key = true
	self._key_rebind_started = false
end

function GenericUserManager:get_key_rebind_skip_first_activate_key()
	return self._key_rebind_skip_first_activate_key
end

function GenericUserManager:set_key_rebind_skip_first_activate_key(flag)
	self._key_rebind_skip_first_activate_key = flag
end

function GenericUserManager:get_key_rebind_started()
	return self._key_rebind_started
end

function GenericUserManager:set_key_rebind_started(flag)
	self._key_rebind_started = flag
end

function GenericUserManager:init_finalize()
	self:update_all_users()
end

function GenericUserManager:is_global_initialized()
	return Global.user_manager and not Global.user_manager.initializing
end

function GenericUserManager:update(t, dt)
end

function GenericUserManager:paused_update(t, dt)
	self:update(t, dt)
end

function GenericUserManager:setup_setting_map()
	self:_setup_setting("last_selected_character_profile_slot", nil, 11)
	self:_setup_setting("invert_camera_x", "controls", false)
	self:_setup_setting("invert_camera_y", "controls", false)
	self:_setup_setting("camera_sensitivity_x", "controls", 1)
	self:_setup_setting("camera_sensitivity_y", "controls", 1)
	self:_setup_setting("camera_zoom_sensitivity_x", "controls", 1)
	self:_setup_setting("camera_zoom_sensitivity_y", "controls", 1)
	self:_setup_setting("camera_sensitivity_separate", "controls", false)
	self:_setup_setting("hold_to_steelsight", "controls", true)
	self:_setup_setting("hold_to_run", "controls", not IS_PC and true)
	self:_setup_setting("hold_to_duck", "controls", false)
	self:_setup_setting("hold_to_wheel", "controls", true)
	self:_setup_setting("weapon_autofire", "controls", false)
	self:_setup_setting("rumble", "controls", true)
	self:_setup_setting("aim_assist", "controls", true)
	self:_setup_setting("southpaw", "controls", false)
	self:_setup_setting("sticky_aim", "controls", IS_CONSOLE)
	self:_setup_setting("keyboard_keybinds", "keybinds", {})
	self:_setup_setting("controller_keybinds", "keybinds", {})
	self:_setup_setting("brightness", "video", 1)
	self:_setup_setting("effect_quality", "video", tweak_data.EFFECT_QUALITY)
	self:_setup_setting("use_headbob", "video", true)
	self:_setup_setting("use_camera_accel", "video", true)
	self:_setup_setting("camera_shake", "video", 1)
	self:_setup_setting("fov_standard", "video", 85)
	self:_setup_setting("fov_zoom", "video", 85)
	self:_setup_setting("fov_multiplier", "video", 1.5)
	self:_setup_setting("video_animation_lod", "video_advanced", 3)
	self:_setup_setting("dof_setting", "video_advanced", "standard")
	self:_setup_setting("fps_cap", "video_advanced", 60)
	self:_setup_setting("ssao_setting", "video_advanced", "standard")
	self:_setup_setting("AA_setting", "video_advanced", "SMAA")
	self:_setup_setting("motion_blur_setting", "video_advanced", "none")
	self:_setup_setting("vls_setting", "video_advanced", "standard")
	self:_setup_setting("detail_distance", "video_advanced", IS_PC and 1 or 0.6)
	self:_setup_setting("use_parallax", "video_advanced", true)
	self:_setup_setting("colorblind_setting", "video_advanced", "off")
	self:_setup_setting("corpse_limit", "video_advanced", IS_CONSOLE and 10 or 32)
	self:_setup_setting("subtitles", "interface", true)
	self:_setup_setting("objective_reminder", "interface", true)
	self:_setup_setting("warcry_ready_indicator", "interface", true)
	self:_setup_setting("skip_cinematics", "interface", false)
	self:_setup_setting("capitalize_names", "interface", false)
	self:_setup_setting("hud_special_weapon_panels", "interface", true)
	self:_setup_setting("hud_crosshairs", "interface", true)
	self:_setup_setting("hit_indicator", "interface", 3)
	self:_setup_setting("throwable_contours", "interface", false)
	self:_setup_setting("motion_dot", "interface", 1)
	self:_setup_setting("motion_dot_size", "interface", 2)
	self:_setup_setting("motion_dot_icon", "interface", 1)
	self:_setup_setting("motion_dot_offset", "interface", 3)
	self:_setup_setting("motion_dot_color", "interface", 1)
	self:_setup_setting("motion_dot_toggle_aim", "interface", false)
	self:_setup_setting("master_volume", "sound", 60)
	self:_setup_setting("sfx_volume", "sound", 75)
	self:_setup_setting("music_volume", "sound", 100)
	self:_setup_setting("voice_volume", "sound", 100)
	self:_setup_setting("voice_over_volume", "sound", 100)
	self:_setup_setting("voice_chat", "sound", true)
	self:_setup_setting("push_to_talk", "sound", true)
	self:_setup_setting("tinnitus_sound_enabled", "sound", true)
	self:_setup_setting("net_packet_throttling", "network", false)
	self:_setup_setting("net_use_compression", "network", true)
	self:_setup_setting("net_forwarding", "network", true)
	self:_setup_setting("server_filter_friends_only", "network", false)
	self:_setup_setting("server_filter_camp_only", "network", false)
	self:_setup_setting("server_filter_distance", "network", 2)
	self:_setup_setting("server_filter_difficulty", "network", 0)
end

function GenericUserManager:_setup_setting(name, category, default_value)
	assert(not self._global.setting_map[name], "[UserManager] Setting name \"" .. tostring(name) .. "\" already exists.")

	default_value = self:get_clone_value(default_value)
	local setting_data = {
		category = category,
		default_value = default_value,
		value = default_value
	}
	self._global.setting_map[name] = setting_data
end

function GenericUserManager:reset_setting_map(category)
	for name, data in pairs(self._global.setting_map) do
		if not category or category == data.category then
			self:set_setting(name, self:get_clone_value(data.default_value))
		end
	end
end

function GenericUserManager:get_clone_value(value)
	if type(value) == "table" then
		return deep_clone(value)
	else
		return value
	end
end

function GenericUserManager:get_setting(name)
	local setting_data = self._global.setting_map[name]

	assert(setting_data, "[UserManager] Tried to get non-existing setting \"" .. tostring(name) .. "\".")

	return setting_data.value
end

function GenericUserManager:get_default_setting(name)
	local setting_data = self._global.setting_map[name]

	assert(setting_data, "[UserManager] Tried to get non-existing default setting \"" .. tostring(name) .. "\".")

	return self:get_clone_value(setting_data.default_value)
end

function GenericUserManager:set_setting(name, value, force_change)
	local setting_data = self._global.setting_map[name]

	if not setting_data then
		Application:error("[UserManager] Tried to set non-existing default setting \"" .. tostring(name) .. "\".")

		return
	end

	local old_value = setting_data.value
	setting_data.value = value

	if self:has_setting_changed(old_value, value) or force_change then
		managers.savefile:setting_changed()

		local callback_handler = self._setting_changed_callback_handler_map[name]

		if callback_handler then
			callback_handler:dispatch(name, old_value, value)
		end
	end
end

function GenericUserManager:add_setting_changed_callback(setting_name, callback_func, trigger_changed_from_default_now)
	assert(self._global.setting_map[setting_name], "[UserManager] Tried to add setting changed callback for non-existing setting \"" .. tostring(setting_name) .. "\".")

	local callback_handler = self._setting_changed_callback_handler_map[setting_name] or CallbackEventHandler:new()
	self._setting_changed_callback_handler_map[setting_name] = callback_handler

	callback_handler:add(callback_func)

	if trigger_changed_from_default_now then
		local value = self:get_setting(setting_name)
		local default_value = self:get_default_setting(setting_name)

		if self:has_setting_changed(default_value, value) then
			callback_func(setting_name, default_value, value)
		end
	end
end

function GenericUserManager:remove_setting_changed_callback(setting_name, callback_func)
	local callback_handler = self._setting_changed_callback_handler_map[setting_name]

	assert(self._global.setting_map[setting_name], "[UserManager] Tried to remove setting changed callback for non-existing setting \"" .. tostring(setting_name) .. "\".")
	assert(callback_handler, "[UserManager] Tried to remove non-existing setting changed callback for setting \"" .. tostring(setting_name) .. "\".")
	callback_handler:remove(callback_func)
end

function GenericUserManager:has_setting_changed(old_value, new_value)
	if type(old_value) ~= "table" or type(new_value) ~= "table" then
		return old_value ~= new_value
	end

	for k, old_sub_value in pairs(old_value) do
		if self:has_setting_changed(new_value[k], old_sub_value) then
			return true
		end
	end

	for k, new_sub_value in pairs(new_value) do
		if self:has_setting_changed(new_sub_value, old_value[k]) then
			return true
		end
	end

	return false
end

function GenericUserManager:is_online_menu()
	return false
end

function GenericUserManager:update_all_users()
end

function GenericUserManager:update_user(user_index, ignore_username_change)
end

function GenericUserManager:add_user_state_changed_callback(callback_func)
	self._user_state_changed_callback_handler:add(callback_func)
end

function GenericUserManager:remove_user_state_changed_callback(callback_func)
	self._user_state_changed_callback_handler:remove(callback_func)
end

function GenericUserManager:add_active_user_state_changed_callback(callback_func)
	self._active_user_state_changed_callback_handler:add(callback_func)
end

function GenericUserManager:remove_active_user_state_changed_callback(callback_func)
	self._active_user_state_changed_callback_handler:remove(callback_func)
end

function GenericUserManager:add_storage_changed_callback(callback_func)
	self._storage_changed_callback_handler:add(callback_func)
end

function GenericUserManager:remove_storage_changed_callback(callback_func)
	self._storage_changed_callback_handler:remove(callback_func)
end

function GenericUserManager:set_user_soft(user_index, platform_id, storage_id, username, signin_state, ignore_username_change)
	local user_data = {
		user_index = user_index,
		platform_id = platform_id,
		storage_id = storage_id,
		username = username,
		signin_state = signin_state
	}
	self._global.user_map[user_index] = user_data
end

function GenericUserManager:set_user(user_index, platform_id, storage_id, username, signin_state, ignore_username_change)
	local old_user_data = self:_get_user_data(user_index)
	local user_data = {
		user_index = user_index,
		platform_id = platform_id,
		storage_id = storage_id,
		username = username,
		signin_state = signin_state
	}
	self._global.user_map[user_index] = user_data

	self:check_user_state_change(old_user_data, user_data, ignore_username_change)
end

function GenericUserManager:check_user_state_change(old_user_data, user_data, ignore_username_change)
	local username = user_data and user_data.username
	local signin_state = user_data and user_data.signin_state or self.NOT_SIGNED_IN_STATE
	local old_signin_state = old_user_data and old_user_data.signin_state or self.NOT_SIGNED_IN_STATE
	local old_username = old_user_data and old_user_data.username
	local old_user_has_signed_out = old_user_data and old_user_data.has_signed_out
	local user_changed, active_user_changed = nil
	local was_signed_in = old_signin_state ~= self.NOT_SIGNED_IN_STATE
	local is_signed_in = signin_state ~= self.NOT_SIGNED_IN_STATE
	local user_index = user_data and user_data.user_index or old_user_data and old_user_data.user_index

	if was_signed_in ~= is_signed_in or not ignore_username_change and old_username ~= username or old_user_has_signed_out then
		if user_index == self:get_index() then
			active_user_changed = true
		end

		if Global.category_print.user_manager then
			if active_user_changed then
				cat_print("user_manager", "[UserManager] Active user changed.")
			else
				cat_print("user_manager", "[UserManager] User index changed.")
			end

			cat_print("user_manager", "[UserManager] Old user: " .. self:get_user_data_string(old_user_data) .. ".")
			cat_print("user_manager", "[UserManager] New user: " .. self:get_user_data_string(user_data) .. ".")
		end

		user_changed = true
	end

	if user_changed then
		if active_user_changed then
			self:active_user_change_state(old_user_data, user_data)
		end

		self._user_state_changed_callback_handler:dispatch(old_user_data, user_data)
	end

	local storage_id = user_data and user_data.storage_id
	local old_storage_id = old_user_data and old_user_data.storage_id
	local ignore_storage_change = self.CAN_CHANGE_STORAGE_ONLY_ONCE and self._global.storage_changed

	if not ignore_storage_change and (active_user_changed or user_index == self:get_index() and storage_id ~= old_storage_id) then
		self:storage_changed(old_user_data, user_data)

		self._global.storage_changed = true
	end
end

function GenericUserManager:active_user_change_state(old_user_data, user_data)
	if self:get_active_user_state_change_quit() then
		print("-- Cause loading", self:get_active_user_state_change_quit(), managers.savefile:is_in_loading_sequence())
		managers.system_menu:add_init_show({
			id = "user_changed",
			title = managers.localization:text("dialog_signin_change_title"),
			text = managers.localization:text("dialog_signin_change"),
			button_list = {
				{
					text = managers.localization:text("dialog_ok")
				}
			}
		})
		self:perform_load_start_menu()
	end

	self._active_user_state_changed_callback_handler:dispatch(old_user_data, user_data)
end

function GenericUserManager:perform_load_start_menu()
	managers.system_menu:force_close_all()
	self:set_index(nil)
	managers.menu:on_user_sign_out()

	if managers.groupai then
		managers.groupai:state():set_AI_enabled(false)
	end

	setup:load_start_menu()
	game_state_machine:set_boot_from_sign_out(true)
	self:set_active_user_state_change_quit(false)
	self:set_index(nil)
end

function GenericUserManager:storage_changed(old_user_data, user_data)
	managers.savefile:storage_changed()
	self._storage_changed_callback_handler:dispatch(old_user_data, user_data)
end

function GenericUserManager:load_platform_setting_map(callback_func)
	if callback_func then
		callback_func(nil)
	end
end

function GenericUserManager:get_user_string(user_index)
	local user_data = self:_get_user_data(user_index)

	return self:get_user_data_string(user_data)
end

function GenericUserManager:get_user_data_string(user_data)
	if not user_data then
		return "nil"
	end

	local user_index = tostring(user_data.user_index)
	local signin_state = tostring(user_data.signin_state)
	local username = tostring(user_data.username)
	local platform_id = tostring(user_data.platform_id)
	local storage_id = tostring(user_data.storage_id)
	local data_string = string.format("User index: %s, Platform id: %s, Storage id: %s, Signin state: %s, Username: %s", user_index, platform_id, storage_id, signin_state, username)

	return data_string
end

function GenericUserManager:set_index(user_index)
	if self._global.user_index == user_index then
		return
	end

	local old_user_index = self._global.user_index

	cat_print("user_manager", "[UserManager] Changed user index from " .. tostring(old_user_index) .. " to " .. tostring(user_index) .. ".")

	self._global.user_index = user_index
	local old_user_data = old_user_index and self:_get_user_data(old_user_index)

	if not user_index and old_user_data and not IS_XB1 then
		old_user_data.storage_id = nil
	end

	if not user_index and not IS_XB1 then
		for _, data in pairs(self._global.user_map) do
			data.storage_id = nil
		end
	end

	local user_data = self:_get_user_data(user_index)

	self:check_user_state_change(old_user_data, user_data, false)
end

function GenericUserManager:get_index()
	return self._global.user_index
end

function GenericUserManager:get_active_user_state_change_quit()
	return self._global.active_user_state_change_quit
end

function GenericUserManager:set_active_user_state_change_quit(active_user_state_change_quit)
	if not self._global.active_user_state_change_quit ~= not active_user_state_change_quit then
		cat_print("user_manager", "[UserManager] User state change quits to title screen: " .. tostring(not not active_user_state_change_quit))

		self._global.active_user_state_change_quit = active_user_state_change_quit
	end
end

function GenericUserManager:get_platform_id(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.platform_id
end

function GenericUserManager:is_signed_in(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.signin_state ~= self.NOT_SIGNED_IN_STATE
end

function GenericUserManager:signed_in_state(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.signin_state
end

function GenericUserManager:get_storage_id(user_index)
	local user_data = self:_get_user_data(user_index)

	return user_data and user_data.storage_id
end

function GenericUserManager:is_storage_selected(user_index)
	if not self.CAN_SELECT_STORAGE then
		return true
	end

	local user_data = self:_get_user_data(user_index)

	return user_data and not not user_data.storage_id
end

function GenericUserManager:_get_user_data(user_index)
	user_index = user_index or self:get_index()

	return user_index and self._global.user_map[user_index]
end

function GenericUserManager:check_user(callback_func, show_select_user_question_dialog)
	if not self.CAN_SELECT_USER or self:is_signed_in(nil) then
		if callback_func then
			callback_func(true)
		end

		return
	end

	local confirm_callback = callback(self, self, "confirm_select_user_callback", callback_func)

	if not show_select_user_question_dialog then
		confirm_callback(true)

		return
	end

	self._active_check_user_callback_func = callback_func

	managers.system_menu:show({
		focus_button = 1,
		id = "show_select_user_question_dialog",
		title = managers.localization:text("dialog_signin_title"),
		text = managers.localization:text("dialog_signin_question"),
		button_list = {
			{
				text = managers.localization:text("dialog_yes"),
				callback_func = callback(self, self, "_success_callback", confirm_callback)
			},
			{
				text = managers.localization:text("dialog_no"),
				class = RaidGUIControlButtonShortSecondary,
				callback_func = callback(self, self, "_fail_callback", confirm_callback)
			}
		}
	})
end

function GenericUserManager:_success_callback(callback_func)
	if callback_func then
		callback_func(true)
	end
end

function GenericUserManager:_fail_callback(callback_func)
	if callback_func then
		callback_func(false)
	end
end

function GenericUserManager:confirm_select_user_callback(callback_func, success)
	self._active_check_user_callback_func = nil

	if success then
		managers.system_menu:show_select_user({
			count = 1,
			callback_func = callback(self, self, "select_user_callback", callback_func)
		})
	elseif callback_func then
		callback_func(false)
	end
end

function GenericUserManager:select_user_callback(callback_func)
	if not self._account_picker_user_selected then
		if callback_func then
			self._active_check_user_callback_func = nil

			callback_func("dismissed")
		end

		return
	end

	self:update_all_users()

	if callback_func then
		self._active_check_user_callback_func = nil

		callback_func(self:is_signed_in(nil))
	end
end

function GenericUserManager:check_storage(callback_func, auto_select)
	if not self.CAN_SELECT_STORAGE or self:get_storage_id(nil) then
		if callback_func then
			callback_func(true)
		end

		return
	end

	local function wrapped_callback_func(success, result, ...)
		if success then
			self:update_all_users()
		end

		if callback_func then
			callback_func(success, result, ...)
		end
	end

	managers.system_menu:show_select_storage({
		count = 1,
		min_bytes = managers.savefile.RESERVED_BYTES,
		callback_func = wrapped_callback_func,
		auto_select = auto_select
	})
end

function GenericUserManager:save_setting_map(setting_map, callback_func)
	if callback_func then
		Appliction:error("[UserManager] Setting map cannot be saved on this platform.")
		callback_func(false)
	end
end

function GenericUserManager:save(data)
	local setting_map = self:get_setting_map()
	data.UserManager = {
		version = self.VERSION,
		setting_map = setting_map
	}

	if Global.DEBUG_MENU_ON then
		data.debug_post_effects_enabled = Global.debug_post_effects_enabled
	end
end

function GenericUserManager:get_setting_map()
	local save_map = {}

	for name, data in pairs(self._global.setting_map) do
		save_map[name] = data.value
	end

	return save_map
end

function GenericUserManager:load(data, cache_version)
	local state = cache_version == 0 and data or data.UserManager

	if not state.version or state.version < self.RESTRUCTURE_VERSION then
		local save_converter = require("lib/utils/save_converters/SaveConverterUser")
		state.setting_map = save_converter.to_version_2(state)
	end

	self:_set_setting_map(state.setting_map)

	if Global.DEBUG_MENU_ON then
		Global.debug_post_effects_enabled = data.debug_post_effects_enabled ~= false
	else
		Global.debug_post_effects_enabled = true
	end

	self:_apply_loaded_user_settings()
end

function GenericUserManager:_set_setting_map(setting_map)
	for name, value in pairs(setting_map) do
		if self._global.setting_map[name] then
			local default_value = self:get_default_setting(name)

			if default_value and type(value) ~= type(default_value) then
				Application:warn("[UserManager] type did not line up with the default value, resetting " .. name .. " to default!")

				value = default_value
			end

			self:set_setting(name, value)
		end
	end
end

function GenericUserManager:_apply_loaded_user_settings()
	SoundDevice:set_rtpc("option_master_volume", math.clamp(self:get_setting("master_volume"), 0, 100))
	SoundDevice:set_rtpc("option_sfx_volume", math.clamp(self:get_setting("sfx_volume"), 0, 100))
	SoundDevice:set_rtpc("option_music_volume", math.clamp(self:get_setting("music_volume"), 0, 100))
	SoundDevice:set_rtpc("option_vo_volume", math.clamp(self:get_setting("voice_over_volume"), 0, 100))
end

PS4UserManager = PS4UserManager or class(GenericUserManager)
UserManager.PLATFORM_CLASS_MAP[Idstring("PS4"):key()] = PS4UserManager

function PS4UserManager:init()
	self._init_finalize_index = not self:is_global_initialized()

	GenericUserManager.init(self)
	managers.platform:add_event_callback("disconnect", callback(self, self, "disconnect_callback"))
end

function PS4UserManager:disconnect_callback()
	if Global.game_settings.single_player then
		return
	end

	if managers.network:session() and managers.network:session():_local_peer_in_lobby() then
		managers.menu:psn_disconnected()
	elseif managers.network:session() then
		managers.network:session():psn_disconnected()
	end

	if Global.dropin_loading_screen then
		managers.menu:hide_loading_screen()

		Global.dropin_loading_screen = nil
	end
end

function PS4UserManager:init_finalize()
	GenericUserManager.init_finalize(self)

	if self._init_finalize_index then
		self:set_user(1, nil, true, nil, true, false)

		self._init_finalize_index = nil
	end
end

function PS4UserManager:set_index(user_index)
	if user_index then
		self:set_user_soft(user_index, nil, true, nil, true, false)
	end

	GenericUserManager.set_index(self, user_index)
end

WinUserManager = WinUserManager or class(GenericUserManager)
UserManager.PLATFORM_CLASS_MAP[Idstring("WIN32"):key()] = WinUserManager

function WinUserManager:init()
	self._init_finalize_index = not self:is_global_initialized()

	GenericUserManager.init(self)
end

function WinUserManager:init_finalize()
	GenericUserManager.init_finalize(self)

	if self._init_finalize_index then
		if Application:editor() then
			self:set_index(1)
		else
			self:set_user(1, nil, true, nil, true, false)
		end

		self._init_finalize_index = nil
	end
end

function WinUserManager:set_index(user_index)
	if user_index then
		self:set_user_soft(user_index, nil, true, nil, true, false)
	end

	GenericUserManager.set_index(self, user_index)
end

XB1UserManager = XB1UserManager or class(GenericUserManager)
XB1UserManager.NOT_SIGNED_IN_STATE = "not_signed_in"
XB1UserManager.CAN_SELECT_USER = true
XB1UserManager.CAN_SELECT_STORAGE = true
XB1UserManager.CUSTOM_PROFILE_VARIABLE_COUNT = 3
XB1UserManager.CUSTOM_PROFILE_VARIABLE_CHAR_COUNT = 999
XB1UserManager.CAN_CHANGE_STORAGE_ONLY_ONCE = false
UserManager.PLATFORM_CLASS_MAP[Idstring("XB1"):key()] = XB1UserManager

function XB1UserManager:init()
	self._platform_setting_conversion_func_map = {
		gamer_control_sensitivity = callback(self, self, "convert_gamer_control_sensitivity")
	}

	GenericUserManager.init(self)
	managers.platform:add_event_callback("signin_changed", callback(self, self, "signin_changed_callback"))
	managers.platform:add_event_callback("profile_setting_changed", callback(self, self, "profile_setting_changed_callback"))
	managers.platform:add_event_callback("storage_devices_changed", callback(self, self, "storage_devices_changed_callback"))
	managers.platform:add_event_callback("disconnect", callback(self, self, "disconnect_callback"))
	managers.platform:add_event_callback("connect", callback(self, self, "connect_callback"))

	self._setting_map_save_counter = 0
end

function XB1UserManager:update(t, dt)
	XB1UserManager.super.update(self, t, dt)

	if not self._disconnected and (self._in_online_menu or not Global.game_settings.single_player and not rawget(_G, "setup").IS_START_MENU) and not rawget(_G, "setup"):has_queued_exec() then
		local wall_time = TimerManager:wall():time()

		if not self._privilege_check_enabled then
			self._privilege_check_enabled = true
			self._next_privilege_check_time = wall_time + 2
		elseif self._next_privilege_check_time and self._next_privilege_check_time < wall_time then
			self._next_privilege_check_time = nil
			local result = self:check_privilege(nil, "multiplayer_sessions", callback(self, self, "_check_privilege_callback"))

			if not result then
				self:_check_privilege_callback(true)
			end
		end
	elseif self._privilege_check_enabled then
		self._privilege_check_enabled = nil
		self._next_privilege_check_time = nil
		self._privilege_check_fail_count = nil
	end
end

function XB1UserManager:_check_privilege_callback(is_success)
	if not self._privilege_check_enabled then
		return
	end

	self._privilege_check_enabled = false

	if not is_success and (self._in_online_menu or not Global.game_settings.single_player and not rawget(_G, "setup").IS_START_MENU) and not rawget(_G, "setup"):has_queued_exec() then
		self._privilege_check_fail_count = (self._privilege_check_fail_count or 0) + 1

		if self._privilege_check_fail_count > 1 then
			print("[XB1UserManager] Lost privileges.")

			local user_data = self:_get_user_data(nil)

			self:active_user_change_state(user_data, user_data)
		end
	else
		self._privilege_check_fail_count = nil
	end
end

function XB1UserManager:disconnect_callback(reason)
	print("  XB1UserManager:disconnect_callback", reason)

	if Global.game_settings.single_player then
		return
	end

	if self._disconnected then
		print("[XB1UserManager:disconnect_callback] Already disconnected. No action taken.")

		return
	end

	self._disconnected = true

	if managers.network:session() and managers.network:session():_local_peer_in_lobby() then
		managers.menu:xbox_disconnected()
	elseif self._in_online_menu then
		managers.menu:xbox_disconnected()
	elseif managers.network:session() then
		managers.network:session():xbox_disconnected()
	end
end

function XB1UserManager:connect_callback()
end

function XB1UserManager:on_entered_online_menus()
	self._disconnected = nil
	self._in_online_menu = true
end

function XB1UserManager:on_exit_online_menus()
	self._in_online_menu = false
end

function XB1UserManager:is_online_menu()
	return self._in_online_menu
end

function XB1UserManager:convert_gamer_control_sensitivity(value)
	if value == "low" then
		return 0.5
	elseif value == "medium" then
		return 1
	else
		return 1.5
	end
end

function XB1UserManager:active_user_change_state(old_user_data, user_data)
	self._global.platform_setting_map = nil

	managers.savefile:active_user_changed()
	GenericUserManager.active_user_change_state(self, old_user_data, user_data)
end

function XB1UserManager:load_platform_setting_map(callback_func)
	cat_print("user_manager", "[UserManager] Loading platform setting map.")
	XboxLive:read_profile_settings(self:get_platform_id(nil), callback(self, self, "_load_platform_setting_map_callback", callback_func))
end

function XB1UserManager:_load_platform_setting_map_callback(callback_func, platform_setting_map)
	cat_print("user_manager", "[UserManager] Done loading platform setting map. Success: " .. tostring(not not platform_setting_map))

	self._global.platform_setting_map = platform_setting_map

	self:reset_setting_map()

	if callback_func then
		callback_func(platform_setting_map)
	end
end

function XB1UserManager:save_platform_setting(setting_name, setting_value, callback_func)
	cat_print("user_manager", "[UserManager] Saving platform setting \"" .. tostring(setting_name) .. "\": " .. tostring(setting_value))
	XboxLive:write_profile_setting(self:get_platform_id(nil), setting_name, setting_value, callback(self, self, "_save_platform_setting_callback", callback_func))
end

function XB1UserManager:_save_platform_setting_callback(callback_func, success)
	cat_print("user_manager", "[UserManager] Done saving platform setting \"" .. tostring("Dont get setting name in callback") .. "\". Success: " .. tostring(success))

	if callback_func then
		callback_func(success)
	end
end

function XB1UserManager:signin_changed_callback(selected_xuid)
	print("[XB1UserManager:signin_changed_callback] selected_xuid", selected_xuid)

	local selected_user_index = selected_xuid and tostring(selected_xuid)
	self._account_picker_user_selected = selected_xuid
	local old_user_index = self:get_index()

	for user_index, user_data in pairs(self._global.user_map) do
		local was_signed_in = user_data.signin_state ~= self.NOT_SIGNED_IN_STATE
		local is_signed_in = XboxLive:signin_state(user_data.platform_id) ~= "not_signed_in"
		user_data.has_signed_out = was_signed_in and not is_signed_in
	end

	if selected_user_index and self._active_check_user_callback_func then
		print("[XB1UserManager:signin_changed_callback] executing _active_check_user_callback_func")
		managers.system_menu:close("show_select_user_question_dialog")
		self._active_check_user_callback_func(true)

		self._active_check_user_callback_func = nil
	end

	self:update_all_users()

	if selected_xuid then
		self:set_index(selected_xuid)
	end
end

function XB1UserManager:profile_setting_changed_callback(...)
end

function XB1UserManager:update_all_users()
	local old_user_indexes = {}

	for user_index, user_data in pairs(self._global.user_map) do
		table.insert(old_user_indexes, user_index)
	end

	local xuids = XboxLive:all_user_XUIDs()

	for _, xuid in pairs(xuids) do
		self:update_user(xuid, false)
	end

	for _, user_index in ipairs(old_user_indexes) do
		local found = nil

		for _, xuid in pairs(xuids) do
			if user_index == tostring(xuid) then
				found = true

				break
			end
		end

		if not found then
			self:update_user(self._global.user_map[user_index].platform_id, false)

			self._global.user_map[user_index] = nil
		end
	end
end

function XB1UserManager:update_user(xuid, ignore_username_change)
	if type(xuid) == "string" then
		xuid = Xuid.from_string(xuid)
	end

	local signin_state = XboxLive:signin_state(xuid)
	local is_signed_in = signin_state ~= self.NOT_SIGNED_IN_STATE
	local storage_id, username = nil

	print("[XB1UserManager:update_user] xuid", xuid, "signin_state", signin_state, "is_signed_in", is_signed_in)

	if is_signed_in then
		username = XboxLive:name(xuid)
		storage_id = Application:current_storage_device_id(xuid)

		print(" username", username, "storage_id", storage_id)

		if storage_id == 0 then
			storage_id = nil
		end
	end

	local user_index = tostring(xuid)

	self:set_user(user_index, xuid, storage_id, username, signin_state, ignore_username_change)
end

function XB1UserManager:storage_devices_changed_callback()
	self:update_all_users()
end

function XB1UserManager:check_privilege(user_index, privilege, callback_func)
	local platform_id = self:get_platform_id(user_index)

	return XboxLive:check_privilege(platform_id, privilege, callback_func)
end

function XB1UserManager:check_privilege_sync(user_index, privilege)
	local platform_id = self:get_platform_id(user_index)

	return XboxLive:check_privilege_sync(platform_id, privilege)
end

function XB1UserManager:get_xuid(user_index)
	local platform_id = self:get_platform_id(user_index)

	return platform_id
end

function XB1UserManager:invite_accepted_by_inactive_user()
end

function XB1UserManager:set_index(user_index)
	local old_user_index = self._global.user_index

	print("[XB1UserManager:set_index]", user_index, "old_user_index", old_user_index)
	Application:stack_dump()

	local user_index_str = user_index and tostring(user_index) or nil

	if old_user_index ~= user_index_str then
		XboxLive:set_current_user(user_index)

		if user_index then
			self:update_user(user_index, false)
		end
	end

	XB1UserManager.super.set_index(self, user_index_str)
end
