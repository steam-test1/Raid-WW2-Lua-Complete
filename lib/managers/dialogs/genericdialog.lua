core:module("SystemMenuManager")
require("lib/managers/dialogs/Dialog")

GenericDialog = GenericDialog or class(Dialog)
GenericDialog.FADE_IN_DURATION = 0.2
GenericDialog.FADE_OUT_DURATION = 0.2
GenericDialog.MOVE_AXIS_LIMIT = 0.4
GenericDialog.MOVE_AXIS_DELAY = 0.4

-- Lines 11-55
function GenericDialog:init(manager, data, is_title_outside)
	Dialog.init(self, manager, data)

	if not self._data.focus_button then
		if #self._button_text_list > 0 then
			self._data.focus_button = #self._button_text_list
		else
			self._data.focus_button = 1
		end
	else
		self._default_button = self._data.focus_button
	end

	self._ws = self._data.ws or manager:_get_ws()
	self._panel_script = _G.TextBoxGui:new(self._ws, self._data.title or "", self._data.text or "", self._data, {
		no_close_legend = true,
		type = self._data.type or "system_menu",
		is_title_outside = is_title_outside
	})

	self._panel_script:add_background()
	self._panel_script:set_layer(_G.tweak_data.gui.DIALOG_LAYER)
	self._panel_script:set_centered()
	self._panel_script:set_fade(0)

	self._controller = self._data.controller or manager:_get_controller()
	self._confirm_func = callback(self, self, "button_pressed_callback")
	self._cancel_func = callback(self, self, "dialog_cancel_callback")
	self._resolution_changed_callback = callback(self, self, "resolution_changed_callback")

	managers.viewport:add_resolution_changed_func(self._resolution_changed_callback)

	if data.counter then
		self._counter = data.counter
		self._counter_time = self._counter[1]
	end
end

-- Lines 57-59
function GenericDialog:set_text(text, no_upper)
	self._panel_script:set_text(text, no_upper)
end

-- Lines 61-63
function GenericDialog:set_title(text, no_upper)
	self._panel_script:set_title(text, no_upper)
end

-- Lines 65-89
function GenericDialog:mouse_moved(o, x, y)
	if not self._panel_script or not alive(self._panel_script._text_box_buttons_panel) then
		return false, "arrow"
	end

	local used, pointer = self._panel_script:moved_scroll_bar(x, y)

	if used then
		return used, pointer
	end

	local x, y = managers.mouse_pointer:convert_1280_mouse_pos(x, y)

	for i, button in ipairs(self._panel_script._buttons) do
		if button:inside(x, y) then
			self._panel_script:set_focus_button(i)
		elseif self._panel_script._text_box_focus_button == i then
			self._panel_script:unfocus_button(i)
		end
	end

	return false, "arrow"
end

-- Lines 91-105
function GenericDialog:mouse_pressed(o, button, x, y)
	if button == Idstring("0") then
		for i, gui_button in ipairs(self._panel_script._buttons) do
			if gui_button:inside(x, y) then
				gui_button:on_mouse_pressed(button)
			end
		end

		for i, control in ipairs(self._panel_script.controls) do
			if control:inside(x, y) then
				control:on_mouse_pressed(button)
			end
		end
	end
end

-- Lines 107-139
function GenericDialog:mouse_released(o, button, x, y)
	if button == Idstring("0") then
		local x, y = managers.mouse_pointer:convert_1280_mouse_pos(x, y)

		if self._panel_script:check_grab_scroll_bar(x, y) then
			return
		end

		if button == Idstring("0") then
			for i, gui_button in ipairs(self._panel_script._buttons) do
				if gui_button:inside(x, y) then
					gui_button:on_mouse_released(button)
					self:button_pressed_callback()

					return
				end
			end

			for i, control in ipairs(self._panel_script.controls) do
				if control:inside(x, y) then
					control:on_mouse_released(button)
				end
			end
		end
	else
		self._panel_script:release_scroll_bar()
	end
end

-- Lines 141-176
function GenericDialog:update(t, dt)
	if self._fade_in_time then
		local alpha = math.clamp((t - self._fade_in_time) / self.FADE_IN_DURATION, 0, 1)

		self._panel_script:set_fade(alpha)

		if alpha == 1 then
			self:set_input_enabled(true)

			self._fade_in_time = nil
		end
	end

	if self._fade_out_time then
		local alpha = math.clamp(1 - (t - self._fade_out_time) / self.FADE_OUT_DURATION, 0, 1)

		self._panel_script:set_fade(alpha)

		if alpha == 0 then
			self._fade_out_time = nil

			self:close()
		end
	end

	if self._input_enabled then
		self:update_input(t, dt)
	end

	if self._counter then
		self._counter_time = self._counter_time - dt

		if self._counter_time < 0 then
			self._counter_time = self._counter_time + self._counter[1]

			self._counter[2]()
		end
	end
end

-- Lines 178-218
function GenericDialog:update_input(t, dt)
	if self._data.no_buttons then
		return
	end

	local dir, move_time = nil
	local move = self._controller:get_input_axis("menu_move")

	if self._controller:get_input_bool("menu_right") or self.MOVE_AXIS_LIMIT < move.x then
		dir = 1
	elseif self._controller:get_input_bool("menu_left") or move.x < -self.MOVE_AXIS_LIMIT then
		dir = -1
	end

	if dir then
		if self._move_button_dir == dir and self._move_button_time and t < self._move_button_time + self.MOVE_AXIS_DELAY then
			move_time = self._move_button_time or t
		else
			self._panel_script:change_focus_button(dir)

			move_time = t
		end
	end

	self._move_button_dir = dir
	self._move_button_time = move_time
end

-- Lines 220-222
function GenericDialog:set_controller(controller)
	self._controller = controller
end

-- Lines 224-246
function GenericDialog:controller_hotswap_triggered()
	self._controller:add_trigger("confirm", self._confirm_func)

	local is_pc_controller = not managers.controller:is_xbox_controller_present()

	if is_pc_controller then
		self._controller:add_trigger("toggle_menu", self._cancel_func)

		self._mouse_id = managers.mouse_pointer:get_id()
		self._removed_mouse = nil
		local data = {
			mouse_move = callback(self, self, "mouse_moved"),
			mouse_press = callback(self, self, "mouse_pressed"),
			mouse_release = callback(self, self, "mouse_released"),
			id = self._mouse_id
		}

		managers.mouse_pointer:use_mouse(data)
	else
		managers.mouse_pointer:remove_mouse(self._mouse_id)

		self._removed_mouse = true
		self._mouse_id = nil

		self._controller:add_trigger("cancel", self._cancel_func)
		managers.mouse_pointer:disable()
	end
end

-- Lines 248-285
function GenericDialog:set_input_enabled(enabled)
	if not self._input_enabled ~= not enabled then
		if enabled then
			self._controller:add_trigger("confirm", self._confirm_func)

			if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" then
				self._controller:add_trigger("toggle_menu", self._cancel_func)

				self._mouse_id = managers.mouse_pointer:get_id()
				self._removed_mouse = nil
				local data = {
					mouse_move = callback(self, self, "mouse_moved"),
					mouse_press = callback(self, self, "mouse_pressed"),
					mouse_release = callback(self, self, "mouse_released"),
					id = self._mouse_id
				}

				managers.mouse_pointer:use_mouse(data)
			else
				self._removed_mouse = nil

				self._controller:add_trigger("cancel", self._cancel_func)
				managers.mouse_pointer:disable()
			end
		else
			self._panel_script:release_scroll_bar()
			self._controller:remove_trigger("confirm", self._confirm_func)

			if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" then
				self._controller:remove_trigger("toggle_menu", self._cancel_func)
			else
				self._controller:remove_trigger("cancel", self._cancel_func)
			end

			self:remove_mouse()
		end

		self._input_enabled = enabled

		managers.controller:set_menu_mode_enabled(enabled)
	end
end

-- Lines 287-289
function GenericDialog:fade_in()
	self._fade_in_time = TimerManager:main():time()
end

-- Lines 291-295
function GenericDialog:fade_out_close()
	managers.menu:post_event("prompt_exit")
	self:fade_out()
end

-- Lines 297-303
function GenericDialog:fade_out()
	self._fade_out_time = TimerManager:main():time()

	if managers.menu:active_menu() then
		managers.menu:active_menu().renderer:disable_input(0.2)
	end

	self:set_input_enabled(false)
end

-- Lines 305-307
function GenericDialog:is_closing()
	return self._fade_out_time ~= nil
end

-- Lines 309-314
function GenericDialog:show()
	managers.menu:post_event("prompt_enter")
	self._manager:event_dialog_shown(self)

	return true
end

-- Lines 316-322
function GenericDialog:hide()
	self:set_input_enabled(false)

	self._fade_in_time = nil

	self._panel_script:set_fade(0)
	self._manager:event_dialog_hidden(self)
end

-- Lines 324-330
function GenericDialog:_close_generic()
	self:set_input_enabled(false)
	self._panel_script:close()
	managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback)
end

-- Lines 332-335
function GenericDialog:close()
	self:_close_generic()
	Dialog.close(self)
end

-- Lines 337-340
function GenericDialog:force_close()
	self:_close_generic()
	Dialog.force_close(self)
end

-- Lines 342-363
function GenericDialog:dialog_cancel_callback()
	if SystemInfo:platform() ~= Idstring("WIN32") then
		return
	end

	if self._data.no_buttons then
		return
	end

	if #self._data.button_list == 1 then
		self:remove_mouse()
		self:button_pressed(1)
	end

	for i, btn in ipairs(self._data.button_list) do
		if btn.cancel_button then
			self:remove_mouse()
			self:button_pressed(i)

			return
		end
	end
end

-- Lines 365-372
function GenericDialog:button_pressed_callback()
	if self._data.no_buttons then
		return
	end

	self:remove_mouse()
	self:button_pressed(self._panel_script:get_focus_button() or self._default_button)
end

-- Lines 374-397
function GenericDialog:button_pressed(button_index)
	cat_print("dialog_manager", "[SystemMenuManager] Button index pressed: " .. tostring(button_index))

	local button_list = self._data.button_list

	self:fade_out_close()

	local callback_data = self._panel_script:get_callback_data()

	if button_list then
		local button = button_list[button_index]

		if button and button.callback_func then
			button.callback_func(button_index, button, callback_data)
		end
	end

	local callback_func = self._data.callback_func

	if callback_func then
		callback_func(button_index, self._data)
	end
end

-- Lines 399-411
function GenericDialog:remove_mouse()
	if not self._removed_mouse then
		self._removed_mouse = true

		if managers.controller:get_default_wrapper_type() == "pc" or managers.controller:get_default_wrapper_type() == "steam" then
			managers.mouse_pointer:remove_mouse(self._mouse_id)
		else
			managers.mouse_pointer:enable()
		end

		self._mouse_id = nil
	end
end

-- Lines 413-415
function GenericDialog:resolution_changed_callback()
end
