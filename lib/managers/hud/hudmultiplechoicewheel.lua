HUDMultipleChoiceWheel = HUDMultipleChoiceWheel or class()
HUDMultipleChoiceWheel.W = 1080
HUDMultipleChoiceWheel.H = 960
HUDMultipleChoiceWheel.BACKGROUND_IMAGE = "comm_wheel_bg"
HUDMultipleChoiceWheel.CIRCLE_IMAGE = "comm_wheel_circle"
HUDMultipleChoiceWheel.POINTER_IMAGE = "comm_wheel_triangle"
HUDMultipleChoiceWheel.LINE_IMAGE = "coom_wheel_line"
HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_ALPHA = 0.25
HUDMultipleChoiceWheel.SEPARATOR_LINE_SELECTED_ALPHA = 1
HUDMultipleChoiceWheel.WHEEL_RADIUS = 128
HUDMultipleChoiceWheel.LINE_LENGTH = 237
HUDMultipleChoiceWheel.ICON_DISTANCE_FROM_CIRCLE = 100
HUDMultipleChoiceWheel.ICON_UNSELECTED_ALPHA = 0.5
HUDMultipleChoiceWheel.ICON_SELECTED_ALPHA = 1
HUDMultipleChoiceWheel.TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDMultipleChoiceWheel.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDMultipleChoiceWheel.TEXT_DISTANCE_FROM_CIRCLE = 220
HUDMultipleChoiceWheel.TEXT_UNSELECTED_ALPHA = 0.75
HUDMultipleChoiceWheel.TEXT_SELECTED_ALPHA = 1

function HUDMultipleChoiceWheel:init(ws, hud, params)
	self._ws = ws
	self._tweak_data = params
	self._is_active = false
	self._in_cooldown = false
	self._option_data = deep_clone(params.options)
	self._options = {}
	self._separators = {}
	self._center = {}
	self._center.x, self._center.y = managers.gui_data:safe_to_full(hud.panel:world_center())
	self._show_clbks = params and params.show_clbks or nil
	self._hide_clbks = params and params.hide_clbks or nil

	self:_create_panel(hud)
	self:_create_background()
	self:_create_pointer()
	self:_setup_controller()
end

function HUDMultipleChoiceWheel:_create_panel(hud)
	local panel_params = {
		layer = 1200,
		name = "multiple_choice_wheel_panel",
		halign = "center",
		valign = "top",
		w = HUDMultipleChoiceWheel.W,
		h = HUDMultipleChoiceWheel.H
	}
	self._object = hud.panel:panel(panel_params)
end

function HUDMultipleChoiceWheel:_create_background()
	local background_params = {
		name = "background",
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.BACKGROUND_IMAGE].texture_rect
	}
	local background = self._object:bitmap(background_params)

	background:set_center_x(self._object:w() / 2)
	background:set_center_y(self._object:h() / 2)

	local background_circle_params = {
		name = "background_circle",
		layer = 10,
		alpha = 0.25,
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.CIRCLE_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.CIRCLE_IMAGE].texture_rect
	}
	local background_circle = self._object:bitmap(background_circle_params)

	background_circle:set_center_x(self._object:w() / 2)
	background_circle:set_center_y(self._object:h() / 2)

	local selection_arc_params = {
		name = "selection_arc",
		visible = false,
		render_template = "VertexColorTexturedRadial",
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.CIRCLE_IMAGE].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDMultipleChoiceWheel.CIRCLE_IMAGE),
			0,
			-tweak_data.gui:icon_w(HUDMultipleChoiceWheel.CIRCLE_IMAGE),
			tweak_data.gui:icon_h(HUDMultipleChoiceWheel.CIRCLE_IMAGE)
		},
		w = tweak_data.gui:icon_w(HUDMultipleChoiceWheel.CIRCLE_IMAGE),
		h = tweak_data.gui:icon_h(HUDMultipleChoiceWheel.CIRCLE_IMAGE),
		layer = background_circle:layer() + 1
	}
	self._selection_arc = self._object:bitmap(selection_arc_params)

	self._selection_arc:set_center_x(self._object:w() / 2)
	self._selection_arc:set_center_y(self._object:h() / 2)
end

function HUDMultipleChoiceWheel:_create_pointer()
	local pointer_params = {
		name = "pointer",
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.POINTER_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.POINTER_IMAGE].texture_rect
	}
	self._pointer = self._object:bitmap(pointer_params)

	self._pointer:set_center(self._object:w() / 2, self._object:h() / 2)
end

function HUDMultipleChoiceWheel:_setup_controller()
	self._controller = managers.controller:get_default_controller()

	self._ws:connect_controller(self._controller, true)
	self._object:axis_move(callback(self, self, "_axis_moved"))
end

function HUDMultipleChoiceWheel:destroy(unit)
	managers.queued_tasks:unqueue_all(nil, self)
end

function HUDMultipleChoiceWheel:is_visible()
	return self._is_active
end

function HUDMultipleChoiceWheel:show()
	if self._show_clbks then
		for _, clbk in pairs(self._show_clbks) do
			clbk()
		end
	end

	self._is_active = true

	if #self._options > 0 then
		self:_destroy_options()

		self._is_active = true
	end

	self:_create_options()
	self:_activate_pointer(false)
	self:_setup_controller()
	self._ws:connect_controller(self._controller, true)
	self:_fade_in_options()
	self._object:set_center(self._object:parent():w() / 2, self._object:parent():h() / 2)
	self._pointer:set_center(self._object:w() / 2, self._object:h() / 2)

	if managers.queued_tasks:has_task("[HUDMultipleChoiceWheel]_destroy_options") then
		managers.queued_tasks:unqueue("[HUDMultipleChoiceWheel]_destroy_options")
	end

	self._object:set_visible(true)
end

function HUDMultipleChoiceWheel:hide(quiet)
	self:_deactivate_pointer()
	self._ws:disconnect_controller(self._controller)

	self._starting_mouse = nil

	self:_fade_out_options()
	self._object:set_visible(false)
	managers.queued_tasks:queue("[HUDMultipleChoiceWheel]_destroy_options", self._destroy_options, self, nil, 0.4, nil)

	self._is_active = false

	if self._hide_clbks then
		for _, clbk in pairs(self._hide_clbks) do
			clbk()
		end
	end

	if self._in_cooldown then
		return
	end

	if self._active_panel ~= nil and not quiet then
		local current = self._option_data[self._active_panel]

		self:trigger_option(current.id)
	end
end

function HUDMultipleChoiceWheel:trigger_option(id)
	if not id or self._in_cooldown then
		return
	end

	local option = nil

	for i = 1, #self._option_data do
		if self._option_data[i].id and self._option_data[i].id == id then
			option = self._option_data[i]

			break
		end
	end

	if not option then
		return
	end

	if option.clbk_data then
		option.clbk(unpack(option.clbk_data))
	else
		option.clbk(nil)
	end

	if self._tweak_data.cooldown then
		self._in_cooldown = true

		managers.queued_tasks:queue("multiple_choice_wheel_cooldown", self.stop_cooldown, self, nil, self._tweak_data.cooldown, nil)
	end
end

function HUDMultipleChoiceWheel:_call_clbk(function_name, function_data)
	if self._in_cooldown then
		return
	end

	local parts = string.split(function_name, ":")
	local method = parts[2]
	local target_parts = string.split(parts[1], "[.]")
	local target = nil

	for i = 1, #target_parts do
		if target == nil then
			target = _G[target_parts[i]]
		else
			target = target[target_parts[i]]
		end
	end

	target[method](target, unpack(function_data))

	if self._tweak_data.cooldown then
		self._in_cooldown = true

		managers.queued_tasks:queue("multiple_choice_wheel_cooldown", self.stop_cooldown, self, nil, self._tweak_data.cooldown, nil)
	end
end

function HUDMultipleChoiceWheel:stop_cooldown()
	self._in_cooldown = false
end

function HUDMultipleChoiceWheel:_create_options()
	local single_option_angle = 360 / #self._option_data

	for i = 1, #self._option_data do
		self:_create_separator_line(i)

		local icon = self:_create_icon(i)
		local text = self:_create_option_text(i)
		local option = {
			icon = icon,
			text = text
		}

		table.insert(self._options, option)
	end

	self._selection_arc:set_position_z(1 / #self._option_data)
end

function HUDMultipleChoiceWheel:_create_separator_line(index)
	local single_option_angle = 360 / #self._option_data
	local separator_line_params = {
		name = "separator_line_" .. tostring(index),
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.LINE_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.LINE_IMAGE].texture_rect,
		rotation = single_option_angle * (index - 1),
		alpha = HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_ALPHA
	}
	local separator_line = self._object:bitmap(separator_line_params)
	local dx = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.LINE_LENGTH / 2) * math.cos(single_option_angle * (index - 1) - 90)
	local dy = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.LINE_LENGTH / 2) * math.sin(single_option_angle * (index - 1) - 90)

	separator_line:set_center_x(self._object:w() / 2 + dx)
	separator_line:set_center_y(self._object:h() / 2 + dy)
	table.insert(self._separators, separator_line)
end

function HUDMultipleChoiceWheel:_create_icon(index)
	local single_option_angle = 360 / #self._option_data
	local icon_params = {
		name = "icon_" .. tostring(self._option_data[index].id),
		texture = tweak_data.gui.icons[self._option_data[index].icon].texture,
		texture_rect = tweak_data.gui.icons[self._option_data[index].icon].texture_rect,
		alpha = HUDMultipleChoiceWheel.ICON_UNSELECTED_ALPHA
	}
	local icon = self._object:bitmap(icon_params)
	local dx = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.ICON_DISTANCE_FROM_CIRCLE) * math.cos(single_option_angle * (index - 1) + single_option_angle / 2 - 90)
	local dy = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.ICON_DISTANCE_FROM_CIRCLE) * math.sin(single_option_angle * (index - 1) + single_option_angle / 2 - 90)

	icon:set_center_x(self._object:w() / 2 + dx)
	icon:set_center_y(self._object:h() / 2 + dy)

	return icon
end

function HUDMultipleChoiceWheel:_create_option_text(index)
	local single_option_angle = 360 / #self._option_data
	local option_text_params = {
		vertical = "center",
		align = "center",
		halign = "center",
		valign = "center",
		name = "text_" .. tostring(self._option_data[index].id),
		font = HUDMultipleChoiceWheel.TEXT_FONT,
		font_size = HUDMultipleChoiceWheel.TEXT_FONT_SIZE,
		text = utf8.to_upper(managers.localization:text(self._option_data[index].text_id)),
		alpha = HUDMultipleChoiceWheel.TEXT_UNSELECTED_ALPHA
	}
	local text = self._object:text(option_text_params)
	local _, _, w, h = text:text_rect()

	text:set_w(w + 10)
	text:set_h(h)

	local dx = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.TEXT_DISTANCE_FROM_CIRCLE) * math.cos(single_option_angle * (index - 1) + single_option_angle / 2 - 90)
	local dy = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.TEXT_DISTANCE_FROM_CIRCLE) * math.sin(single_option_angle * (index - 1) + single_option_angle / 2 - 90)

	text:set_center_x(self._object:w() / 2 + dx)
	text:set_center_y(self._object:h() / 2 + dy)

	return text
end

function HUDMultipleChoiceWheel:_recreate_options()
	self:_destroy_options()
	self:_deactivate_pointer()
	self:_create_options()
	self:_activate_pointer(false)
end

function HUDMultipleChoiceWheel:set_options(options)
	self._option_data = options
end

function HUDMultipleChoiceWheel:add_option(option, index)
	for i = 1, #self._option_data do
		if self._option_data[i].id == option.id then
			return
		end
	end

	index = index or #self._option_data + 1

	table.insert(self._option_data, index, option)
end

function HUDMultipleChoiceWheel:remove_option(option_id)
	for i = 1, #self._option_data do
		if self._option_data[i].id == option_id then
			table.remove(self._option_data, i)

			break
		end
	end
end

function HUDMultipleChoiceWheel:_fade_in_options()
	for i = 1, #self._options do
	end
end

function HUDMultipleChoiceWheel:_fade_out_options()
	for i = 1, #self._options do
		if self._active_panel ~= nil and self._active_panel == i then
			-- Nothing
		end
	end

	if self._pointer ~= nil then
		-- Nothing
	end
end

function HUDMultipleChoiceWheel:_destroy_options()
	if self._is_active then
		for _, option in pairs(self._options) do
			self._object:remove(option.icon)
			self._object:remove(option.text)
		end

		self._options = {}
		self._is_active = false

		for _, separator in pairs(self._separators) do
			self._object:remove(separator)
		end

		self._separators = {}
	end
end

function HUDMultipleChoiceWheel:_activate_pointer(controller_activated)
	self._last_mouse_pos = {
		x = 0,
		y = 0
	}
	self._last_mouse_dist = 0

	if not controller_activated and managers.controller:get_default_wrapper_type() ~= "pc" then
		return
	end

	self._mouse_active = true
	self._mouse_id = managers.mouse_pointer:get_id()
	local data = {
		mouse_move = callback(self, self, "_mouse_moved"),
		mouse_click = callback(self, self, "_mouse_clicked"),
		id = self._mouse_id
	}

	managers.mouse_pointer:use_mouse(data)

	local base_resolution = tweak_data.gui.base_resolution

	managers.mouse_pointer:set_mouse_world_position(base_resolution.x / 2, base_resolution.y / 2)
	managers.mouse_pointer:set_pointer_image("none")
end

function HUDMultipleChoiceWheel:_deactivate_pointer()
	if not self._mouse_active then
		return
	end

	self._mouse_active = false

	managers.mouse_pointer:remove_mouse(self._mouse_id)
	managers.mouse_pointer:release_mouse_pointer()
end

function HUDMultipleChoiceWheel:_get_pointer_angle(x, y)
	local vec1 = {
		x = x,
		y = y
	}
	local vec2 = {
		x = 0,
		y = -3
	}
	local angle = math.atan2(vec1.y, vec1.x) - math.atan2(vec2.y, vec2.x)

	if angle < 0 then
		angle = 360 + angle
	end

	return angle
end

function HUDMultipleChoiceWheel:_enter_panel(id)
	self._options[id].text:set_alpha(HUDMultipleChoiceWheel.TEXT_SELECTED_ALPHA)
	self._options[id].icon:set_alpha(HUDMultipleChoiceWheel.ICON_SELECTED_ALPHA)
	self._separators[id]:set_alpha(HUDMultipleChoiceWheel.SEPARATOR_LINE_SELECTED_ALPHA)
	self._separators[id % #self._option_data + 1]:set_alpha(HUDMultipleChoiceWheel.SEPARATOR_LINE_SELECTED_ALPHA)
	self._pointer:stop()

	local single_option_angle = math.ceil(360 / #self._option_data)

	self._selection_arc:set_rotation(single_option_angle * id)
	self._selection_arc:set_visible(true)
end

function HUDMultipleChoiceWheel:_exit_panel(id)
	self._options[id].text:set_alpha(HUDMultipleChoiceWheel.TEXT_UNSELECTED_ALPHA)
	self._options[id].icon:set_alpha(HUDMultipleChoiceWheel.ICON_UNSELECTED_ALPHA)
	self._separators[id]:set_alpha(HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_ALPHA)
	self._separators[id % #self._option_data + 1]:set_alpha(HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_ALPHA)
	self._selection_arc:set_visible(false)
end

function HUDMultipleChoiceWheel:_select_panel(x, y, distance_from_center)
	local angle = self:_get_pointer_angle(x - self._center.x, y - self._center.y)
	local quadrant = math.floor(angle / (360 / #self._options)) + 1

	if distance_from_center > 50 then
		if self._active_panel ~= nil then
			if self._active_panel ~= quadrant then
				self:_exit_panel(self._active_panel)
				self:_enter_panel(quadrant)
			end
		else
			self:_enter_panel(quadrant)
		end

		for i = 1, #self._options do
			if i == quadrant then
				self._active_panel = i
			end
		end
	else
		self:_exit_panel(quadrant)

		if self._active_panel ~= nil then
			self:_exit_panel(self._active_panel)

			self._active_panel = nil

			self._pointer:stop()
		end
	end
end

function HUDMultipleChoiceWheel:_axis_moved(o, axis, value, c)
	if axis == Idstring("right") then
		self:set_pointer_position(value.x * 100, -value.y * 100)
	end
end

function HUDMultipleChoiceWheel:set_pointer_position(x, y)
	self._pointer:set_center_x(self._object:w() / 2 + x)
	self._pointer:set_center_y(self._object:h() / 2 + y)

	local angle = self:_get_pointer_angle(x, y)

	self._pointer:set_rotation(angle)

	local distance_from_center = math.sqrt(math.pow(x, 2) + math.pow(y, 2))
	local center_x = self._starting_mouse and self._starting_mouse.x or self._center.x
	local center_y = self._starting_mouse and self._starting_mouse.y or self._center.y

	self:_select_panel(self._center.x + x, self._center.y + y, distance_from_center)
end

function HUDMultipleChoiceWheel:_mouse_moved(o, x, y, mouse_ws)
	if self._starting_mouse == nil then
		self._starting_mouse = {
			x = x,
			y = y
		}
	end

	local distance_from_center = math.sqrt(math.pow(x - self._starting_mouse.x, 2) + math.pow(y - self._starting_mouse.y, 2))
	local angle = self:_get_pointer_angle(x - self._starting_mouse.x, y - self._starting_mouse.y)
	local dx = 100 * math.cos(angle - 91)
	local dy = 100 * math.sin(angle - 91)

	if distance_from_center < 100 then
		self:set_pointer_position(x - self._starting_mouse.x, y - self._starting_mouse.y)

		local mx, my = managers.mouse_pointer:world_position()
		self._last_mouse_pos.x = mx
		self._last_mouse_pos.y = my
	else
		self:set_pointer_position(dx, dy)

		local curr_mouse_dist = Vector3(x - self._object:center_x(), y - self._object:center_y(), 0)

		if self._last_mouse_dist < curr_mouse_dist:length() then
			self._last_mouse_dist = curr_mouse_dist:length()
		else
			managers.mouse_pointer:set_mouse_world_position(self._starting_mouse.x + dx, self._starting_mouse.y + dy)

			self._last_mouse_dist = 0
		end
	end
end

function HUDMultipleChoiceWheel:_mouse_clicked(o, button, x, y)
end

function HUDMultipleChoiceWheel:w()
	return self._object:w()
end

function HUDMultipleChoiceWheel:h()
	return self._object:h()
end

function HUDMultipleChoiceWheel:set_x(x)
	self._object:set_x(x)
end

function HUDMultipleChoiceWheel:set_y(y)
	self._object:set_y(y)
end
