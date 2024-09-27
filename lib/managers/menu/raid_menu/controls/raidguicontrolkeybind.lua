RaidGuiControlKeyBind = RaidGuiControlKeyBind or class(RaidGUIControl)
RaidGuiControlKeyBind.WIDTH_SHORT = 32
RaidGuiControlKeyBind.WIDTH_MEDIUM = 112
RaidGuiControlKeyBind.WIDTH_LONG = 172
RaidGuiControlKeyBind.WIDTH_VERY_LONG = 236
RaidGuiControlKeyBind.HEIGHT = 32
RaidGuiControlKeyBind.PADDING = 16
RaidGuiControlKeyBind.TEXT_COLOR_NORMAL = tweak_data.gui.colors.raid_grey
RaidGuiControlKeyBind.TEXT_COLOR_ACTIVE = tweak_data.gui.colors.raid_white
RaidGuiControlKeyBind.ACTIVE_LINE_COLOR = tweak_data.gui.colors.raid_red
RaidGuiControlKeyBind.ICON_LEFT = "kb_left_base"
RaidGuiControlKeyBind.ICON_CENTER = "kb_center_base"
RaidGuiControlKeyBind.ICON_RIGHT = "kb_right_base"
RaidGuiControlKeyBind.CORNER_WIDTH = 10

function RaidGuiControlKeyBind:init(parent, params)
	RaidGuiControlKeyBind.super.init(self, parent, params)

	if not self._params.text_id and not self._params.text then
		Application:error("[RaidGUIControlLabel:init] Text not specified for the label control: ", params.name)

		return
	end

	self._keybind_params = self._params.keybind_params
	self._params.layer = self._params.layer + 2
	self._object = self._panel:panel(self._params)

	self:_create_keybind_layout()

	self._active_line = self._object:rect({
		w = 3,
		y = 0,
		x = 0,
		visible = false,
		color = nil,
		h = 32,
		color = RaidGuiControlKeyBind.ACTIVE_LINE_COLOR
	})
	self._params.layer = self._params.layer - 1
	self._ws = self._params.ws
	self._listening_to_input = false
end

function RaidGuiControlKeyBind:is_listening_to_input()
	return self._listening_to_input
end

function RaidGuiControlKeyBind:highlight_on()
	self._description:set_color(RaidGuiControlKeyBind.TEXT_COLOR_ACTIVE)
	self._keybind:set_color(RaidGuiControlKeyBind.TEXT_COLOR_ACTIVE)
	self:_set_background_state("active")
	self._active_line:show()

	if self._play_mouse_over_sound then
		managers.menu_component:post_event("highlight")

		self._play_mouse_over_sound = false
	end
end

function RaidGuiControlKeyBind:highlight_off()
	if not self._listening_to_input then
		self._description:set_color(RaidGuiControlKeyBind.TEXT_COLOR_NORMAL)
		self._keybind:set_color(RaidGuiControlKeyBind.TEXT_COLOR_NORMAL)
		self:_set_background_state("normal")
		self._active_line:hide()
	end

	self._play_mouse_over_sound = true
end

function RaidGuiControlKeyBind:_set_background_state(bg_state)
	if bg_state == "active" then
		self._background_left:hide()
		self._background_left_active:show()
		self._background_mid:hide()
		self._background_mid_active:show()
		self._background_right:hide()
		self._background_right_active:show()
	else
		self._background_left:show()
		self._background_left_active:hide()
		self._background_mid:show()
		self._background_mid_active:hide()
		self._background_right:show()
		self._background_right_active:hide()
	end
end

function RaidGuiControlKeyBind:on_mouse_released(button)
	if managers.user:get_key_rebind_started() and not self._listening_to_input then
		return
	end

	self:activate_customize_controller()
end

function RaidGuiControlKeyBind:activate_customize_controller()
	self._ws:connect_keyboard(Input:keyboard())
	self._ws:connect_mouse(Input:mouse())

	self._listening_to_input = true

	local function f(o, key)
		self:_key_press(o, key, "keyboard", nil)
	end

	self._keybind:set_text("_")
	self._keybind:key_release(f)

	local function f(o, key)
		self:_key_press(o, key, "mouse", nil)
	end

	self._keybind:mouse_click(f)

	local function f(index, key)
		self:_key_press(self._keybind, key, "mouse", true)
	end

	self._mouse_wheel_up_trigger = Input:mouse():add_trigger(Input:mouse():button_index(Idstring("mouse wheel up")), f)
	self._mouse_wheel_down_trigger = Input:mouse():add_trigger(Input:mouse():button_index(Idstring("mouse wheel down")), f)
end

function RaidGuiControlKeyBind:_key_press(o, key, input_id, no_add)
	if managers.system_menu:is_active() then
		return
	end

	if not self._listening_to_input then
		return
	end

	if managers.user:get_key_rebind_skip_first_activate_key() then
		managers.user:set_key_rebind_skip_first_activate_key(false)

		if input_id == "mouse" then
			if key == Idstring("0") or key == Idstring("mouse wheel up") or key == Idstring("mouse wheel down") then
				return
			end
		elseif input_id == "keyboard" and key == Idstring("enter") then
			return
		end
	end

	if key == Idstring("esc") then
		self:_end_customize_controller(o)

		return
	end

	local key_name = "" .. (input_id == "mouse" and Input:mouse():button_name_str(key) or Input:keyboard():button_name_str(key))

	if not no_add and input_id == "mouse" then
		key_name = "mouse " .. key_name or key_name
	end

	local forbidden_btns = {
		"esc",
		"tab",
		"num abnt c1",
		"num abnt c2",
		"@",
		"ax",
		"convert",
		"kana",
		"kanji",
		"no convert",
		"oem 102",
		"stop",
		"unlabeled",
		"yen",
		"mouse 8",
		"mouse 9",
		""
	}

	for _, btn in ipairs(forbidden_btns) do
		if Idstring(btn) == key then
			managers.menu:show_key_binding_forbidden({
				KEY = nil,
				KEY = key_name
			})
			self:_end_customize_controller(o)

			return
		end
	end

	local button_category = MenuCustomizeControllerCreator.CONTROLS_INFO[self._keybind_params.button].category
	local connections = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()

	for _, name in ipairs(MenuCustomizeControllerCreator.controls_info_by_category(button_category)) do
		local connection = connections[name]

		if connection._btn_connections then
			for name, btn_connection in pairs(connection._btn_connections) do
				if btn_connection.name == key_name and self._keybind_params.binding ~= btn_connection.name then
					managers.menu:show_key_binding_collision({
						MAPPED = nil,
						KEY = nil,
						KEY = key_name,
						MAPPED = managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, true)

					return
				end
			end
		else
			for _, b_name in ipairs(connection:get_input_name_list()) do
				if tostring(b_name) == key_name and self._keybind_params.binding ~= b_name then
					managers.menu:show_key_binding_collision({
						MAPPED = nil,
						KEY = nil,
						KEY = key_name,
						MAPPED = managers.localization:text(MenuCustomizeControllerCreator.CONTROLS_INFO[name].text_id)
					})
					self:_end_customize_controller(o, true)

					return
				end
			end
		end
	end

	if self._keybind_params.axis then
		connections[self._keybind_params.axis]._btn_connections[self._keybind_params.button].name = key_name

		managers.controller:set_user_mod(self._keybind_params.connection_name, {
			axis = nil,
			button = nil,
			connection = nil,
			axis = self._keybind_params.axis,
			button = self._keybind_params.button,
			connection = key_name
		})

		self._keybind_params.binding = key_name
	else
		connections[self._keybind_params.button]:set_controller_id(input_id)
		connections[self._keybind_params.button]:set_input_name_list({
			key_name
		})
		managers.controller:set_user_mod(self._keybind_params.connection_name, {
			button = nil,
			connection = nil,
			controller_id = nil,
			button = self._keybind_params.button,
			connection = key_name,
			controller_id = input_id
		})

		self._keybind_params.binding = key_name
	end

	managers.controller:rebind_connections()
	self:_end_customize_controller(o)
end

function RaidGuiControlKeyBind:_end_customize_controller(o, skip_next_key_press)
	if not alive(o) then
		return
	end

	self._ws:disconnect_keyboard()
	self._ws:disconnect_mouse()
	o:key_press(nil)
	o:key_release(nil)
	o:mouse_click(nil)
	o:mouse_release(nil)
	Input:mouse():remove_trigger(self._mouse_wheel_up_trigger)
	Input:mouse():remove_trigger(self._mouse_wheel_down_trigger)
	setup:add_end_frame_clbk(function ()
		self._listening_to_input = false

		self:highlight_off()
		self:reload()
	end)
	managers.user:set_key_rebind_started(false)
	managers.user:set_key_rebind_skip_first_activate_key(true)

	if skip_next_key_press then
		managers.user:set_key_rebind_skip_first_activate_key(true)
	end
end

function RaidGuiControlKeyBind:reload()
	self._object:clear()
	self:_create_keybind_layout()
end

function RaidGuiControlKeyBind:confirm_pressed()
	if self._selected then
		self:on_mouse_released(self)

		return true
	end
end

function RaidGuiControlKeyBind:_create_keybind_layout()
	local translated_keybind = managers.localization:check_keybind_translation(self._keybind_params.binding)
	self._keybind = self._object:text({
		y = 0,
		text = nil,
		font_size = nil,
		color = nil,
		h = nil,
		font = nil,
		vertical = "center",
		x = nil,
		align = "center",
		x = RaidGuiControlKeyBind.PADDING,
		h = RaidGuiControlKeyBind.HEIGHT,
		text = translated_keybind,
		color = RaidGuiControlKeyBind.TEXT_COLOR_NORMAL,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_24
	})

	self._keybind:set_text(utf8.to_upper(translated_keybind))

	self._description = self._object:text({
		text = nil,
		w = nil,
		font_size = nil,
		color = nil,
		h = nil,
		font = nil,
		y = 0,
		x = nil,
		align = "right",
		x = self._params.keybind_w,
		w = self._params.w - self._params.keybind_w,
		h = RaidGuiControlKeyBind.HEIGHT,
		text = self._keybind_params.text_id,
		color = RaidGuiControlKeyBind.TEXT_COLOR_NORMAL,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small
	})
	local x1, y1, keybind_width, h1 = self._keybind:text_rect()

	if keybind_width < RaidGuiControlKeyBind.WIDTH_SHORT then
		keybind_width = RaidGuiControlKeyBind.WIDTH_SHORT
	elseif keybind_width < RaidGuiControlKeyBind.WIDTH_MEDIUM then
		keybind_width = RaidGuiControlKeyBind.WIDTH_MEDIUM
	elseif keybind_width < RaidGuiControlKeyBind.WIDTH_LONG then
		keybind_width = RaidGuiControlKeyBind.WIDTH_LONG
	else
		keybind_width = RaidGuiControlKeyBind.WIDTH_VERY_LONG
	end

	self._background_left = self._object:bitmap({
		texture = nil,
		y = 0,
		x = nil,
		texture_rect = nil,
		h = nil,
		x = RaidGuiControlKeyBind.PADDING,
		h = self._params.h,
		texture = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_LEFT].texture,
		texture_rect = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_LEFT].texture_rect
	})
	local center_texture_rect = {
		tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_CENTER].texture_rect[1] + 1,
		tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_CENTER].texture_rect[2],
		tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_CENTER].texture_rect[3] - 2,
		tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_CENTER].texture_rect[4]
	}
	self._background_mid = self._object:bitmap({
		w = nil,
		y = 0,
		x = nil,
		texture = nil,
		texture_rect = nil,
		h = nil,
		x = self._background_left:x() + RaidGuiControlKeyBind.CORNER_WIDTH,
		w = keybind_width - 2 * RaidGuiControlKeyBind.CORNER_WIDTH,
		h = self._params.h,
		texture = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_CENTER].texture,
		texture_rect = center_texture_rect
	})
	self._background_right = self._object:bitmap({
		texture = nil,
		y = 0,
		x = nil,
		texture_rect = nil,
		h = nil,
		x = self._background_left:x() + keybind_width - RaidGuiControlKeyBind.CORNER_WIDTH,
		h = self._params.h,
		texture = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_RIGHT].texture,
		texture_rect = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_RIGHT].texture_rect
	})
	self._background_left_active = self._object:bitmap({
		texture = nil,
		y = 0,
		x = nil,
		texture_rect = nil,
		visible = false,
		h = nil,
		x = RaidGuiControlKeyBind.PADDING,
		h = self._params.h,
		texture = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_LEFT].texture,
		texture_rect = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_LEFT].texture_rect
	})
	self._background_mid_active = self._object:bitmap({
		w = nil,
		y = 0,
		x = nil,
		texture = nil,
		texture_rect = nil,
		visible = false,
		h = nil,
		x = self._background_left_active:x() + RaidGuiControlKeyBind.CORNER_WIDTH,
		w = keybind_width - 2 * RaidGuiControlKeyBind.CORNER_WIDTH,
		h = self._params.h,
		texture = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_CENTER].texture,
		texture_rect = center_texture_rect
	})
	self._background_right_active = self._object:bitmap({
		texture = nil,
		y = 0,
		x = nil,
		texture_rect = nil,
		visible = false,
		h = nil,
		x = self._background_left_active:x() + keybind_width - RaidGuiControlKeyBind.CORNER_WIDTH,
		h = self._params.h,
		texture = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_RIGHT].texture,
		texture_rect = tweak_data.gui.icons[RaidGuiControlKeyBind.ICON_RIGHT].texture_rect
	})

	self._keybind:set_w(keybind_width)

	self._active_line = self._object:rect({
		w = 3,
		y = 0,
		x = 0,
		visible = false,
		color = nil,
		h = 32,
		color = RaidGuiControlKeyBind.ACTIVE_LINE_COLOR
	})

	self:_set_background_state("normal")
end
