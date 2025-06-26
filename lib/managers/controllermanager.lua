core:module("ControllerManager")
core:import("CoreControllerManager")
core:import("CoreClass")

ControllerManager = ControllerManager or class(CoreControllerManager.ControllerManager)

function ControllerManager:init(path, default_settings_path)
	default_settings_path = "settings/controller_settings"
	path = default_settings_path
	self._menu_mode_enabled = 0

	ControllerManager.super.init(self, path, default_settings_path)
	self:_initial_connected_devices()
end

function ControllerManager:init_finalize()
	self._keybind_changed_callback = callback(self, self, "controller_mod_changed")

	self:controller_mod_changed()
	self:_check_dialog()
end

function ControllerManager:update(t, dt)
	ControllerManager.super.update(self, t, dt)
	self:_poll_reconnected_controller()

	if self:is_using_controller() and managers.hud and managers.raid_menu and not managers.raid_menu:is_any_menu_open() then
		local toggle_chat_key = Idstring(self:get_settings("pc"):get_connection("toggle_chat"):get_input_name_list()[1])

		if Input:keyboard():pressed(toggle_chat_key) then
			managers.hud:toggle_chatinput()
		end
	end
end

function ControllerManager:is_using_controller()
	return self:is_controller_present() and not managers.menu:is_pc_controller()
end

function ControllerManager:is_controller_present()
	return self._num_connected_controllers > 0
end

function ControllerManager:_initial_connected_devices()
	local default_wrapper_index = self:get_default_wrapper_index()
	self._connected_devices = self:_collect_connected_devices()
	self._hotswap_controllers = {}
	self._num_connected_controllers = 0

	for index, connected in pairs(self._connected_devices) do
		if connected then
			local wrapper_index = self._controller_to_wrapper_list[index]
			self._hotswap_controllers[wrapper_index] = self:create_controller("hotswap_" .. wrapper_index, wrapper_index, false)

			if index ~= default_wrapper_index then
				self._hotswap_controllers[wrapper_index]:enable()
			end

			local controller_type = self._wrapper_class_map[wrapper_index].TYPE

			if controller_type == "ps4" or controller_type == "xb1" then
				self._num_connected_controllers = self._num_connected_controllers + 1
			end
		end
	end
end

function ControllerManager:_collect_connected_devices()
	local controllers_list = {}

	if IS_PC then
		local nr_controllers = Input:num_real_controllers()

		for i_controller = 0, nr_controllers - 1 do
			local controller = Input:controller(i_controller)
			controllers_list[i_controller] = controller:connected()
		end
	end

	return controllers_list
end

function ControllerManager:_handle_controller_keyboard_hotswap()
	local current_controllers_connection_state = self:_collect_connected_devices()
	local trigger_hotswap = false
	local default_wrapper_index_old = self:get_default_wrapper_index()

	for index, connected in ipairs(current_controllers_connection_state) do
		local wrapper_index = self._controller_to_wrapper_list[index]

		if current_controllers_connection_state[index] ~= self._connected_devices[index] then
			if connected then
				self._hotswap_controllers[wrapper_index] = self:create_controller("hotswap_" .. wrapper_index, wrapper_index, false)

				if index ~= default_wrapper_index then
					self._hotswap_controllers[wrapper_index]:enable()
				end
			elseif self._hotswap_controllers[wrapper_index] then
				self._hotswap_controllers[wrapper_index]:destroy()

				self._hotswap_controllers[wrapper_index] = nil
			end

			local controller_type = self._wrapper_class_map[wrapper_index].TYPE

			if controller_type == "ps4" or controller_type == "xb1" then
				local increment = connected and 1 or -1
				self._num_connected_controllers = self._num_connected_controllers + increment
			end
		end

		local hotwap_controller = self._hotswap_controllers[wrapper_index]

		if hotwap_controller and hotwap_controller:get_any_input_pressed() then
			self:set_default_wrapper_index(wrapper_index)
			managers.user:set_index(index)
			hotwap_controller:disable()

			trigger_hotswap = true

			break
		end
	end

	self._connected_devices = current_controllers_connection_state

	if trigger_hotswap then
		self:controller_mod_changed()

		if self._hotswap_controllers[default_wrapper_index_old] then
			self._hotswap_controllers[default_wrapper_index_old]:enable()
		end

		self:dispatch_hotswap_callbacks()
	end
end

function ControllerManager:_poll_reconnected_controller()
	self:_handle_controller_keyboard_hotswap()

	if IS_XB1 and self._global.connect_controller_dialog_visible then
		local active_xuid = XboxLive:current_user()
		local nr_controllers = Input:num_controllers()

		for i_controller = 0, nr_controllers - 1 do
			local controller = Input:controller(i_controller)

			if controller:type() == "xb1_controller" and (controller:down(12) or controller:pressed(12)) and controller:user_xuid() == active_xuid then
				self:_close_controller_changed_dialog()
				self:replace_active_controller(i_controller, controller)
			end
		end
	end
end

function ControllerManager:controller_mod_changed()
	local default_wrapper = self:get_default_wrapper_type()
	local keybind_setting = default_wrapper == "pc" and "keyboard_keybinds" or "controller_keybinds"

	if self._keybind_setting and self._keybind_setting ~= keybind_setting then
		managers.user:remove_setting_changed_callback(self._keybind_setting, self._keybind_changed_callback)
	end

	managers.user:add_setting_changed_callback(keybind_setting, self._keybind_changed_callback)

	self._global.user_mod = managers.user:get_setting(keybind_setting)

	self:load_user_mod()

	self._keybind_setting = keybind_setting
end

function ControllerManager:set_user_mod(connection_name, params)
	self._global.user_mod = self._global.user_mod or {}

	if params.axis then
		self._global.user_mod[connection_name] = self._global.user_mod[connection_name] or {
			axis = params.axis
		}
		self._global.user_mod[connection_name][params.button] = params
	else
		self._global.user_mod[connection_name] = params
	end

	managers.user:set_setting(self._keybind_setting, self._global.user_mod, true)
end

function ControllerManager:clear_user_mod(category, CONTROLS_INFO)
	self._global.user_mod = self._global.user_mod or {}
	local names = table.map_keys(self._global.user_mod)

	for _, name in ipairs(names) do
		if CONTROLS_INFO[name] and (CONTROLS_INFO[name].category == category or category == "all") then
			self._global.user_mod[name] = nil
		end
	end

	managers.user:set_setting(self._keybind_setting, self._global.user_mod, true)
	self:load_user_mod()
end

function ControllerManager:load_user_mod()
	if self._global.user_mod then
		local wrapper_type = self:get_default_wrapper_type()
		local settings = self:get_settings(wrapper_type)
		local connections = settings:get_connection_map()

		for _, params in pairs(self._global.user_mod) do
			if params.axis and connections[params.axis] then
				for _, button_params in pairs(params) do
					if type(button_params) == "table" and button_params.button and connections[params.axis]._btn_connections[button_params.button] then
						connections[params.axis]._btn_connections[button_params.button].name = button_params.connection
					end
				end
			elseif params.button and connections[params.button] then
				connections[params.button]:set_controller_id(params.controller_id)
				connections[params.button]:set_input_name_list({
					params.connection
				})
			end
		end

		self:rebind_connections()
	end
end

function ControllerManager:default_controller_connect_change(connected)
	ControllerManager.super.default_controller_connect_change(self, connected)

	if self._global.default_wrapper_index and not connected and not self:_controller_changed_dialog_active() then
		self:_show_controller_changed_dialog()
	end
end

function ControllerManager:_check_dialog()
	if self._global.connect_controller_dialog_visible and not self:_controller_changed_dialog_active() then
		self:_show_controller_changed_dialog()
	end
end

function ControllerManager:_controller_changed_dialog_active()
	return managers.system_menu:is_active_by_id("connect_controller_dialog") and true or false
end

function ControllerManager:_show_controller_changed_dialog()
	if self:_controller_changed_dialog_active() then
		return
	end

	Application:trace("ControllerManager:_show_controller_changed_dialog")
	print(debug.traceback())

	self._global.connect_controller_dialog_visible = true

	if IS_PS4 and not Global._attemptShowControllerDCAfterLoad then
		Global._attemptShowControllerDCAfterLoad = managers.menu._loading_screen:visible()
	end

	if not Global._attemptShowControllerDCAfterLoad then
		local data = {
			callback_func = callback(self, self, "connect_controller_dialog_callback"),
			title = managers.localization:text("dialog_connect_controller_title"),
			text = managers.localization:text("dialog_connect_controller_text", {
				NR = self._global.default_wrapper_index or 1
			}),
			button_list = {
				{
					text = managers.localization:text("dialog_ok")
				}
			},
			id = "connect_controller_dialog",
			force = true
		}

		managers.system_menu:show(data)
	end
end

function ControllerManager:_change_mode(mode)
	self:change_default_wrapper_mode(mode)
end

function ControllerManager:set_menu_mode_enabled(enabled)
	if IS_PC then
		self._menu_mode_enabled = self._menu_mode_enabled or 0
		self._menu_mode_enabled = self._menu_mode_enabled + (enabled and 1 or -1)

		if self:get_menu_mode_enabled() then
			self:_change_mode("menu")
		else
			self:set_ingame_mode()
		end

		if self._menu_mode_enabled < 0 then
			-- Nothing
		end
	end
end

function ControllerManager:get_menu_mode_enabled()
	return self._menu_mode_enabled and self._menu_mode_enabled > 0
end

function ControllerManager:set_ingame_mode(mode)
	if IS_PC then
		if mode then
			self._ingame_mode = mode
		end

		if not self:get_menu_mode_enabled() then
			self:_change_mode(self._ingame_mode)
		end
	end
end

function ControllerManager:_close_controller_changed_dialog(hard)
	if self._global.connect_controller_dialog_visible or self:_controller_changed_dialog_active() then
		print("[ControllerManager:_close_controller_changed_dialog] closing")
		managers.system_menu:close("connect_controller_dialog", hard)
		self:connect_controller_dialog_callback()
	end
end

function ControllerManager:connect_controller_dialog_callback()
	self._global.connect_controller_dialog_visible = nil
end

function ControllerManager:get_mouse_controller()
	return Input:mouse()
end

function ControllerManager:on_level_transition_ended()
	if Global._attemptShowControllerDCAfterLoad then
		local data = {
			callback_func = callback(self, self, "connect_controller_dialog_callback"),
			title = managers.localization:text("dialog_connect_controller_title"),
			text = managers.localization:text("dialog_connect_controller_text", {
				NR = self._global.default_wrapper_index or 1
			}),
			button_list = {
				{
					text = managers.localization:text("dialog_ok")
				}
			},
			id = "connectcontroller_dialog",
			force = true
		}

		managers.system_menu:show(data)

		Global._attemptShowControllerDCAfterLoad = false
	end
end

CoreClass.override_class(CoreControllerManager.ControllerManager, ControllerManager)
