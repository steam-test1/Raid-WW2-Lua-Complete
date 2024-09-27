HUDMultipleChoiceWheel = HUDMultipleChoiceWheel or class()
HUDMultipleChoiceWheel.W = 960
HUDMultipleChoiceWheel.H = 960
HUDMultipleChoiceWheel.BACKGROUND_IMAGE = "comm_wheel_bg"
HUDMultipleChoiceWheel.CIRCLE_IMAGE = "comm_wheel_circle"
HUDMultipleChoiceWheel.POINTER_IMAGE = "comm_wheel_triangle"
HUDMultipleChoiceWheel.LINE_IMAGE = "coom_wheel_line"
HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_COLOR = tweak_data.gui.colors.raid_grey
HUDMultipleChoiceWheel.SEPARATOR_LINE_SELECTED_COLOR = tweak_data.gui.colors.raid_gold
HUDMultipleChoiceWheel.WHEEL_RADIUS = 108
HUDMultipleChoiceWheel.LINE_LENGTH = 237
HUDMultipleChoiceWheel.ICON_DISTANCE_FROM_CIRCLE = 100
HUDMultipleChoiceWheel.ICON_UNSELECTED_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDMultipleChoiceWheel.ICON_SELECTED_COLOR = tweak_data.gui.colors.raid_gold
HUDMultipleChoiceWheel.TEXT_FONT = tweak_data.gui.fonts.din_compressed_outlined_32
HUDMultipleChoiceWheel.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.small
HUDMultipleChoiceWheel.TEXT_DISTANCE_FROM_CIRCLE = 155
HUDMultipleChoiceWheel.TEXT_UNSELECTED_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDMultipleChoiceWheel.TEXT_SELECTED_COLOR = tweak_data.gui.colors.raid_gold
HUDMultipleChoiceWheel.TEXT_GLOW_COLOR = Color("e4a13d")

function HUDMultipleChoiceWheel:init(ws, hud, params)
	self._ws = ws
	self._tweak_data = params
	self._is_active = false
	self._in_cooldown = false
	self._option_data = params.options and deep_clone(params.options) or {}
	self._options = {}
	self._option_ids = {}
	self._separators = {}
	self._center = {}
	self._center.x, self._center.y = managers.gui_data:safe_to_full(hud.panel:world_center())
	self._show_clbks = params and params.show_clbks or nil
	self._hide_clbks = params and params.hide_clbks or nil
	self._angle_offset = 0
	self._num_segments = 0

	self:_create_panel(hud)
	self:_create_background()
	self:_create_pointer()
	self:_setup_controller()
end

function HUDMultipleChoiceWheel:_create_panel(hud)
	local panel_params = {
		alpha = 0,
		name = "multiple_choice_wheel_panel",
		visible = false,
		halign = "center",
		layer = 1200,
		valign = "top",
		h = nil,
		w = nil,
		w = HUDMultipleChoiceWheel.W,
		h = HUDMultipleChoiceWheel.H
	}
	self._object = hud.panel:panel(panel_params)
end

function HUDMultipleChoiceWheel:_create_background()
	local background_params = {
		texture_rect = nil,
		name = "background",
		texture = nil,
		h = nil,
		w = nil,
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.BACKGROUND_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.BACKGROUND_IMAGE].texture_rect,
		w = HUDMultipleChoiceWheel.W,
		h = HUDMultipleChoiceWheel.H
	}
	local background = self._object:bitmap(background_params)

	background:set_center_x(self._object:w() / 2)
	background:set_center_y(self._object:h() / 2)

	local background_circle_params = {
		texture_rect = nil,
		name = "background_circle",
		color = nil,
		texture = nil,
		layer = 10,
		h = nil,
		w = nil,
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.CIRCLE_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.CIRCLE_IMAGE].texture_rect,
		w = HUDMultipleChoiceWheel.WHEEL_RADIUS * 2,
		h = HUDMultipleChoiceWheel.WHEEL_RADIUS * 2,
		color = HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_COLOR
	}
	local background_circle = self._object:bitmap(background_circle_params)

	background_circle:set_center_x(self._object:w() / 2)
	background_circle:set_center_y(self._object:h() / 2)

	local selection_arc_params = {
		texture_rect = nil,
		name = "selection_arc",
		texture = nil,
		render_template = "VertexColorTexturedRadial",
		layer = nil,
		visible = false,
		color = nil,
		h = nil,
		w = nil,
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.CIRCLE_IMAGE].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDMultipleChoiceWheel.CIRCLE_IMAGE),
			0,
			-tweak_data.gui:icon_w(HUDMultipleChoiceWheel.CIRCLE_IMAGE),
			tweak_data.gui:icon_h(HUDMultipleChoiceWheel.CIRCLE_IMAGE)
		},
		w = HUDMultipleChoiceWheel.WHEEL_RADIUS * 2,
		h = HUDMultipleChoiceWheel.WHEEL_RADIUS * 2,
		color = HUDMultipleChoiceWheel.SEPARATOR_LINE_SELECTED_COLOR,
		layer = background_circle:layer() + 1
	}
	self._selection_arc = self._object:bitmap(selection_arc_params)

	self._selection_arc:set_center_x(self._object:w() / 2)
	self._selection_arc:set_center_y(self._object:h() / 2)
end

function HUDMultipleChoiceWheel:_create_pointer()
	local pointer_params = {
		texture_rect = nil,
		name = "pointer",
		layer = nil,
		texture = nil,
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.POINTER_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.POINTER_IMAGE].texture_rect,
		layer = self._selection_arc:layer() + 1
	}
	self._pointer = self._object:bitmap(pointer_params)

	self._pointer:set_center(self._object:w() / 2, self._object:h() / 2)
end

function HUDMultipleChoiceWheel:_setup_controller()
	self._controller = managers.controller:get_default_controller()

	self._object:axis_move(callback(self, self, "_axis_moved"))
end

function HUDMultipleChoiceWheel:destroy()
	if self._is_active then
		self:hide()
	end

	managers.queued_tasks:unqueue_all(nil, self)
	self:_destroy_options()
	self._object:parent():remove(self._object)
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
	self:_fade_in_options()
	self._ws:connect_controller(self._controller, true)
	self:_activate_pointer(false)
	self._object:set_center(self._object:parent():w() / 2, self._object:parent():h() / 2)
	self._pointer:set_center(self._object:w() / 2, self._object:h() / 2)

	if managers.queued_tasks:has_task("[HUDMultipleChoiceWheel]_destroy_options") then
		managers.queued_tasks:unqueue("[HUDMultipleChoiceWheel]_destroy_options")
	end
end

function HUDMultipleChoiceWheel:hide(quiet)
	self:_deactivate_pointer()
	self._ws:disconnect_controller(self._controller)

	self._starting_mouse = nil

	self:_fade_out_options()
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
	Application:debug("[HUDMultipleChoiceWheel:trigger_option] ID", id)

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

	if not option or not option.clbk then
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
	self._num_segments = 0

	for i = 1, #self._option_data do
		self._num_segments = self._num_segments + (self._option_data[i].multiplier or 1)
	end

	local single_option_angle = 360 / self._num_segments
	self._angle_offset = single_option_angle * (self._option_data[1].multiplier or 1) / 2
	local current_angle = -self._angle_offset

	for i = 1, #self._option_data do
		local multiplier = self._option_data[i].multiplier or 1
		local range = single_option_angle * multiplier

		self:_create_separator_line(i, current_angle)

		local panel, icon, text, dx, dy = self:_create_option(i, current_angle, range)
		local option = {
			text = nil,
			icon = nil,
			dy = nil,
			panel = nil,
			dx = nil,
			panel = panel,
			icon = icon,
			text = text,
			dx = dx,
			dy = dy
		}

		table.insert(self._options, option)

		for j = 1, multiplier do
			table.insert(self._option_ids, i)
		end

		current_angle = current_angle + range
	end

	self._selection_arc:set_position_z(1 / self._num_segments)
end

function HUDMultipleChoiceWheel:_create_separator_line(index, angle)
	local separator_line_params = {
		color = nil,
		name = nil,
		texture_rect = nil,
		texture = nil,
		rotation = nil,
		name = "separator_line_" .. tostring(index),
		texture = tweak_data.gui.icons[HUDMultipleChoiceWheel.LINE_IMAGE].texture,
		texture_rect = tweak_data.gui.icons[HUDMultipleChoiceWheel.LINE_IMAGE].texture_rect,
		color = HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_COLOR,
		rotation = angle
	}
	local separator_line = self._object:bitmap(separator_line_params)
	local dx = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.LINE_LENGTH / 2) * math.cos(angle - 90)
	local dy = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.LINE_LENGTH / 2) * math.sin(angle - 90)

	separator_line:set_center_x(self._object:w() / 2 + dx)
	separator_line:set_center_y(self._object:h() / 2 + dy)
	table.insert(self._separators, separator_line)
end

function HUDMultipleChoiceWheel:_create_option(index, angle, range)
	local panel = self._object:panel({
		alpha = 0,
		name = nil,
		halign = "center",
		valign = "top",
		layer = nil,
		name = "panel_params_" .. tostring(index),
		layer = self._selection_arc:layer() + 1
	})
	local icon = self:_create_icon(index, panel)
	local text = self:_create_option_text(index, panel)

	if text:w() < icon:w() then
		text:set_center_x(icon:center_x())
		panel:set_w(icon:right())
	else
		icon:set_center_x(text:center_x())
		panel:set_w(text:right())
	end

	if text:text() == "" then
		panel:set_h(icon:bottom())
	else
		text:set_y(icon:h() + 5)
		panel:set_h(text:bottom())
	end

	local dx = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.ICON_DISTANCE_FROM_CIRCLE) * math.cos(angle + range / 2 - 90)
	local dy = (HUDMultipleChoiceWheel.WHEEL_RADIUS + HUDMultipleChoiceWheel.ICON_DISTANCE_FROM_CIRCLE) * math.sin(angle + range / 2 - 90)

	panel:set_center_x(self._object:w() / 2 + dx)
	panel:set_center_y(self._object:h() / 2 + dy)

	return panel, icon, text, dx, dy
end

function HUDMultipleChoiceWheel:_create_icon(index, parent)
	local icon_params = {
		texture_rect = nil,
		name = nil,
		color = nil,
		texture = nil,
		name = "icon_" .. tostring(self._option_data[index].id),
		texture = tweak_data.gui.icons[self._option_data[index].icon].texture,
		texture_rect = tweak_data.gui.icons[self._option_data[index].icon].texture_rect,
		color = HUDMultipleChoiceWheel.ICON_UNSELECTED_COLOR
	}
	local icon = parent:bitmap(icon_params)

	return icon
end

function HUDMultipleChoiceWheel:_create_option_text(index, parent)
	local option_text_params = {
		font = nil,
		name = nil,
		color = nil,
		vertical = "center",
		align = "center",
		layer = 5,
		text = nil,
		font_size = nil,
		halign = "left",
		valign = "top",
		name = "text_" .. tostring(self._option_data[index].id),
		font = HUDMultipleChoiceWheel.TEXT_FONT,
		font_size = HUDMultipleChoiceWheel.TEXT_FONT_SIZE,
		text = utf8.to_upper(managers.localization:text(self._option_data[index].text_id)),
		color = HUDMultipleChoiceWheel.TEXT_UNSELECTED_COLOR
	}
	local text = parent:text(option_text_params)
	local _, _, w, h = text:text_rect()

	text:set_w(w + 10)
	text:set_h(h)

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
	self._in_cooldown = false
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
	local base_delay = 0.03

	for i = 1, #self._options do
		self._options[i].panel:stop()
		self._options[i].panel:animate(callback(self, self, "_animate_show_option"), i, i % 4 * base_delay)
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show"))
end

function HUDMultipleChoiceWheel:_fade_out_options()
	if self._active_panel then
		self._options[self._active_panel].text:stop()
	end

	for i = 1, #self._options do
		self._options[i].panel:stop()

		if i ~= self._active_panel then
			self._options[i].panel:animate(callback(self, self, "_animate_hide_option"), i)
		end
	end

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))
end

function HUDMultipleChoiceWheel:_animate_show()
	local duration = 0.1
	local t = self._object:alpha() * duration

	self._object:set_visible(true)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)
	end

	self._object:set_alpha(1)
end

function HUDMultipleChoiceWheel:_animate_hide()
	local duration = 0.12
	local t = (1 - self._object:alpha()) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in(t, 1, -1, duration)

		self._object:set_alpha(current_alpha)
	end

	self._object:set_alpha(0)
	self._object:set_visible(false)
	self._selection_arc:set_visible(false)
end

function HUDMultipleChoiceWheel:_animate_show_option(panel, id, delay)
	local start_mul = 0.8
	local change_mul = 0.2
	local duration = 0.08
	local t = panel:alpha() * duration
	local dx = self._options[id].dx
	local dy = self._options[id].dy
	local start_x = dx * start_mul
	local change_x = dx * change_mul
	local start_y = dy * start_mul
	local change_y = dy * change_mul

	wait(delay)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_out(t, 0, 1, duration)

		panel:set_alpha(current_alpha)

		local current_x = Easing.quadratic_in_out(t, start_x, change_x, duration)
		local current_y = Easing.quadratic_in_out(t, start_y, change_y, duration)

		panel:set_center(self._object:w() / 2 + current_x, self._object:h() / 2 + current_y)
	end

	panel:set_alpha(1)
end

function HUDMultipleChoiceWheel:_animate_hide_option(panel, id)
	local change_mul = 0.8
	local duration = 0.12
	local t = (1 - panel:alpha()) * duration
	local dx = self._options[id].dx
	local dy = self._options[id].dy
	local change_x = -dx * change_mul
	local change_y = -dy * change_mul

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, duration)

		panel:set_alpha(current_alpha)

		local current_x = Easing.quadratic_in_out(t, dx, change_x, duration)
		local current_y = Easing.quadratic_in_out(t, dy, change_y, duration)

		panel:set_center(self._object:w() / 2 + current_x, self._object:h() / 2 + current_y)
	end

	panel:set_alpha(0)
end

function HUDMultipleChoiceWheel:_destroy_options()
	if self._is_active then
		self._active_panel = nil

		for _, option in pairs(self._options) do
			option.panel:stop()
			self._object:remove(option.panel)
		end

		self._options = {}
		self._option_ids = {}
		self._is_active = false

		for _, separator in pairs(self._separators) do
			self._object:remove(separator)
		end

		self._separators = {}
	end
end

function HUDMultipleChoiceWheel:_activate_pointer(controller_activated)
	self._last_mouse_pos = {
		y = 0,
		x = 0
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
		y = nil,
		x = nil,
		x = x,
		y = y
	}
	local vec2 = {
		y = -3,
		x = 0
	}
	local angle = math.atan2(vec1.y, vec1.x) - math.atan2(vec2.y, vec2.x)
	angle = angle + self._angle_offset

	if angle < 0 then
		angle = 360 + angle
	end

	return angle
end

function HUDMultipleChoiceWheel:_get_option_angle(id)
	local single_option_angle = math.ceil(360 / self._num_segments)
	local angle = -self._angle_offset

	for i = 1, #self._option_data do
		local multiplier = self._option_data[i].multiplier or 1
		angle = angle + single_option_angle * multiplier

		if i == id then
			break
		end
	end

	return angle
end

function HUDMultipleChoiceWheel:_enter_panel(id)
	self._options[id].text:set_color(HUDMultipleChoiceWheel.TEXT_SELECTED_COLOR)
	self._options[id].icon:set_color(HUDMultipleChoiceWheel.ICON_SELECTED_COLOR)
	self._options[id].text:stop()
	self._options[id].text:animate(UIAnimation.animate_text_glow, HUDMultipleChoiceWheel.TEXT_GLOW_COLOR, 0.52, 0.04, 0.8)
	self._separators[id]:set_color(HUDMultipleChoiceWheel.SEPARATOR_LINE_SELECTED_COLOR)
	self._separators[id % #self._option_data + 1]:set_color(HUDMultipleChoiceWheel.SEPARATOR_LINE_SELECTED_COLOR)
	self._pointer:set_color(HUDMultipleChoiceWheel.ICON_SELECTED_COLOR)
	self._pointer:stop()

	local option_angle = self:_get_option_angle(id)
	local option_multiplier = self._option_data[id].multiplier or 1

	self._selection_arc:set_position_z(option_multiplier / self._num_segments)
	self._selection_arc:set_rotation(option_angle)
	self._selection_arc:set_visible(true)
end

function HUDMultipleChoiceWheel:_exit_panel(id)
	local len = string.len(self._options[id].text:text())

	self._options[id].text:stop()
	self._options[id].text:set_range_color(0, len, HUDMultipleChoiceWheel.TEXT_UNSELECTED_COLOR)
	self._options[id].icon:set_color(HUDMultipleChoiceWheel.ICON_UNSELECTED_COLOR)
	self._separators[id]:set_color(HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_COLOR)
	self._separators[id % #self._option_data + 1]:set_color(HUDMultipleChoiceWheel.SEPARATOR_LINE_UNSELECTED_COLOR)
	self._pointer:set_color(HUDMultipleChoiceWheel.ICON_UNSELECTED_COLOR)
	self._selection_arc:set_visible(false)
end

function HUDMultipleChoiceWheel:_select_panel(x, y, distance_from_center)
	local single_option_angle = 360 / self._num_segments
	local angle = self:_get_pointer_angle(x - self._center.x, y - self._center.y)
	local quadrant = math.floor(angle / single_option_angle) + 1
	quadrant = self._option_ids[quadrant]

	if distance_from_center > 50 and not self._option_data[quadrant].disabled then
		local active_changed = self._active_panel == nil or self._active_panel ~= quadrant

		if self._active_panel and active_changed then
			self:_exit_panel(self._active_panel)
		end

		if not self._active_panel or active_changed then
			self:_enter_panel(quadrant)

			self._active_panel = quadrant
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

local ids_right = Idstring("right")

function HUDMultipleChoiceWheel:_axis_moved(o, axis, value, c)
	if not self._is_active then
		return
	end

	if axis == ids_right then
		self:set_pointer_position(value.x * 100, -value.y * 100)
	end
end

function HUDMultipleChoiceWheel:set_pointer_position(x, y)
	self._pointer:set_center_x(self._object:w() / 2 + x)
	self._pointer:set_center_y(self._object:h() / 2 + y)

	local angle = self:_get_pointer_angle(x, y)
	local angle = angle - self._angle_offset

	self._pointer:set_rotation(angle)

	local distance_from_center = math.sqrt(math.pow(x, 2) + math.pow(y, 2))
	local center_x = self._starting_mouse and self._starting_mouse.x or self._center.x
	local center_y = self._starting_mouse and self._starting_mouse.y or self._center.y

	self:_select_panel(self._center.x + x, self._center.y + y, distance_from_center)
end

function HUDMultipleChoiceWheel:_mouse_moved(o, x, y, mouse_ws)
	if not self._mouse_active then
		return
	end

	if self._starting_mouse == nil then
		self._starting_mouse = {
			x = x,
			y = y
		}
	end

	local distance_from_center = math.sqrt(math.pow(x - self._starting_mouse.x, 2) + math.pow(y - self._starting_mouse.y, 2))
	local angle = self:_get_pointer_angle(x - self._starting_mouse.x, y - self._starting_mouse.y)
	local angle = angle - self._angle_offset
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
