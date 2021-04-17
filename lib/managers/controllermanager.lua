core:module("ControllerManager")
core:import("CoreControllerManager")
core:import("CoreClass")

ControllerManager = ControllerManager or class(CoreControllerManager.ControllerManager)

function ControllerManager:init(path, default_settings_path)
	default_settings_path = "settings/controller_settings"
	path = default_settings_path
	self._menu_mode_enabled = 0

	ControllerManager.super.init(self, path, default_settings_path)

	self._connected_xbox_controllers = {}

	self:_initial_connected_xbox_controllers()
end

function ControllerManager:update(t, dt)
	ControllerManager.super.update(self, t, dt)
	self:_poll_reconnected_controller()
end

function ControllerManager:is_using_controller()
	return managers.controller:is_xbox_controller_present() and not managers.menu:is_pc_controller()
end

function ControllerManager:is_xbox_controller_present()
	if not self._connected_xbox_controllers then
		return false
	end

	for _, connected in pairs(self._connected_xbox_controllers) do
		if connected then
			return true
		end
	end

	return false
end

function ControllerManager:_initial_connected_xbox_controllers()
	self._connected_xbox_controllers = self:_collect_connected_xbox_controllers()
end

function ControllerManager:_collect_connected_xbox_controllers()
	local controllers_list = {}

	if SystemInfo:platform() == Idstring("WIN32") then
		local nr_controllers = Input:num_controllers()

		for i_controller = 0, nr_controllers - 1 do
			local controller = Input:controller(i_controller)

			if controller:type() == "xbox_controller" then
				controllers_list[i_controller] = controller:connected()
			end
		end
	end

	return controllers_list
end

function ControllerManager:_handle_xbox_keyboard_hotswap()
	local current_controllers_connection_state = self:_collect_connected_xbox_controllers()
	local trigger_hotswap = false
	local default_wrapper_old = self:get_default_wrapper_type()
	local is_controller_present_old = self:is_xbox_controller_present()

	for idx, connected in pairs(current_controllers_connection_state) do
		if current_controllers_connection_state[idx] ~= self._connected_xbox_controllers[idx] then
			local wrapper_index = 1

			if connected then
				wrapper_index = self._controller_to_wrapper_list[idx]
			end

			self:set_default_wrapper_index(wrapper_index)
			managers.user:set_index(idx)

			trigger_hotswap = true
		end
	end

	self._connected_xbox_controllers = current_controllers_connection_state
	local default_wrapper = self:get_default_wrapper_type()
	local is_controller_present = self:is_xbox_controller_present()

	if trigger_hotswap and (default_wrapper ~= default_wrapper_old or is_controller_present == is_controller_present_old) then
		self:dispatch_hotswap_callbacks()
	end
end

function ControllerManager:_poll_reconnected_controller()
	self:_handle_xbox_keyboard_hotswap()

	if SystemInfo:platform() == Idstring("XB1") and Global.controller_manager.connect_controller_dialog_visible then
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
	if not Global.controller_manager.user_mod then
		Global.controller_manager.user_mod = managers.user:get_setting("controller_mod")

		self:load_user_mod()
	end
end

function ControllerManager:set_user_mod(connection_name, params)
	Global.controller_manager.user_mod = Global.controller_manager.user_mod or {}

	if params.axis then
		Global.controller_manager.user_mod[connection_name] = Global.controller_manager.user_mod[connection_name] or {
			axis = params.axis
		}
		Global.controller_manager.user_mod[connection_name][params.button] = params
	else
		Global.controller_manager.user_mod[connection_name] = params
	end

	managers.user:set_setting("controller_mod_type", managers.controller:get_default_wrapper_type())
	managers.user:set_setting("controller_mod", Global.controller_manager.user_mod, true)
end

function ControllerManager:clear_user_mod(category, CONTROLS_INFO)
	Global.controller_manager.user_mod = Global.controller_manager.user_mod or {}
	local names = table.map_keys(Global.controller_manager.user_mod)

	for _, name in ipairs(names) do
		if CONTROLS_INFO[name] and (CONTROLS_INFO[name].category == category or category == "all") then
			Global.controller_manager.user_mod[name] = nil
		end
	end

	managers.user:set_setting("controller_mod_type", managers.controller:get_default_wrapper_type())
	managers.user:set_setting("controller_mod", Global.controller_manager.user_mod, true)
	self:load_user_mod()
end

function ControllerManager:load_user_mod()
	if Global.controller_manager.user_mod then
		local connections = managers.controller:get_settings(managers.user:get_setting("controller_mod_type")):get_connection_map()

		for connection_name, params in pairs(Global.controller_manager.user_mod) do
			if params.axis and connections[params.axis] then
				for button, button_params in pairs(params) do
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

function ControllerManager:init_finalize()
	managers.user:add_setting_changed_callback("controller_mod", callback(self, self, "controller_mod_changed"), true)

	if Global.controller_manager.user_mod then
		self:load_user_mod()
	end

	self:_check_dialog()
end

function ControllerManager:default_controller_connect_change(connected)
	ControllerManager.super.default_controller_connect_change(self, connected)

	if Global.controller_manager.default_wrapper_index and not connected and not self:_controller_changed_dialog_active() then
		self:_show_controller_changed_dialog()
	end
end

function ControllerManager:_check_dialog()
	if Global.controller_manager.connect_controller_dialog_visible and not self:_controller_changed_dialog_active() then
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

	Global.controller_manager.connect_controller_dialog_visible = true
	local data = {
		callback_func = callback(self, self, "connect_controller_dialog_callback"),
		title = managers.localization:text("dialog_connect_controller_title"),
		text = managers.localization:text("dialog_connect_controller_text", {
			NR = Global.controller_manager.default_wrapper_index or 1
		})
	}

	if SystemInfo:platform() == Idstring("XB1") then
		data.no_buttons = true
	else
		data.button_list = {
			{
				text = managers.localization:text("dialog_ok")
			}
		}
	end

	data.id = "connect_controller_dialog"
	data.force = true

	managers.system_menu:show(data)
end

function ControllerManager:_change_mode(mode)
	self:change_default_wrapper_mode(mode)
end

function ControllerManager:set_menu_mode_enabled(enabled)
	if SystemInfo:platform() == Idstring("WIN32") then
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
	if SystemInfo:platform() == Idstring("WIN32") then
		if mode then
			self._ingame_mode = mode
		end

		if not self:get_menu_mode_enabled() then
			self:_change_mode(self._ingame_mode)
		end
	end
end

function ControllerManager:_close_controller_changed_dialog(hard)
	if Global.controller_manager.connect_controller_dialog_visible or self:_controller_changed_dialog_active() then
		print("[ControllerManager:_close_controller_changed_dialog] closing")
		managers.system_menu:close("connect_controller_dialog", hard)
		self:connect_controller_dialog_callback()
	end
end

function ControllerManager:connect_controller_dialog_callback()
	Global.controller_manager.connect_controller_dialog_visible = nil
end

function ControllerManager:get_mouse_controller()
	local index = Global.controller_manager.default_wrapper_index or self:get_preferred_default_wrapper_index()
	local wrapper_class = self._wrapper_class_map and self._wrapper_class_map[index]

	if wrapper_class and wrapper_class.TYPE == "steam" then
		local controller_index = self._wrapper_to_controller_list[index][1]
		local controller = Input:controller(controller_index)
		local index = Global.controller_manager.default_wrapper_index or self:get_preferred_default_wrapper_index()
		local wrapper_class = self._wrapper_class_map[index]

		return controller
	end

	return Input:mouse()
end

CoreClass.override_class(CoreControllerManager.ControllerManager, ControllerManager)
