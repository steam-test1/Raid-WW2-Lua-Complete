HUDSuspicionIndicator = HUDSuspicionIndicator or class()
HUDSuspicionIndicator.W = 72
HUDSuspicionIndicator.H = 72
HUDSuspicionIndicator.STATE_COLORS = {
	heard_something = Color("ececec"),
	saw_something = Color("ececec"),
	investigating = Color("dd9a38"),
	alarmed = Color("b8392e"),
	calling = Color("b8392e")
}
HUDSuspicionIndicator.EYE_BG_ICON = "stealth_eye_bg"
HUDSuspicionIndicator.EYE_OUTER_RING_ICON = "stealth_eye_out"
HUDSuspicionIndicator.EYE_FILL_ICON = "stealth_eye_fill"
HUDSuspicionIndicator.CALLING_INDICATOR_CENTER_ICON = "stealth_alarm_icon"
HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN = "stealth_alarm_in"
HUDSuspicionIndicator.CALLING_INDICATOR_ICON_OUT = "stealth_alarm_out"
HUDSuspicionIndicator.PLAYER_ACTIVE_ALPHA = 1
HUDSuspicionIndicator.TEAMMATE_ACTIVE_ALPHA = 0.6

function HUDSuspicionIndicator:init(hud, data)
	self._observer = data.unit
	self._suspect = data.suspect
	self._observer_position = data.position
	self._progress = 0
	self._onscreen = true
	self._active_alpha = HUDManager.DIFFERENT_SUSPICION_INDICATORS_FOR_TEAMMATES == true and (data.suspect == "teammate" or data.suspect == nil) and HUDSuspicionIndicator.TEAMMATE_ACTIVE_ALPHA or HUDSuspicionIndicator.PLAYER_ACTIVE_ALPHA

	self:_create_panel(hud)
	self:_create_eye_background()
	self:_create_eye_outside_ring()
	self:_create_eye_fill()
	self:_create_calling_indicator()
	self:_init_public_properties()
	self:set_state(data.state or "heard_something", true)
	self._object:animate(callback(self, self, "_animate_create"), 0.4)
end

function HUDSuspicionIndicator:_init_public_properties()
	self.in_timer = 1
	self.out_timer = 0
	self.current_position = Vector3()

	mvector3.set(self.current_position, self._observer_position)
end

function HUDSuspicionIndicator:_create_panel(hud)
	local panel_params = {
		alpha = 0,
		name = "suspicion_indicator",
		w = HUDSuspicionIndicator.W,
		h = HUDSuspicionIndicator.H
	}
	self._object = hud.panel:panel(panel_params)
end

function HUDSuspicionIndicator:_create_eye_background()
	local eye_panel_params = {
		halign = "scale",
		name = "eye_panel",
		valign = "scale"
	}
	self._eye_panel = self._object:panel(eye_panel_params)
	local eye_background_params = {
		name = "eye_background",
		texture = tweak_data.gui.icons[HUDSuspicionIndicator.EYE_BG_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDSuspicionIndicator.EYE_BG_ICON].texture_rect,
		layer = self._object:layer() + 1
	}
	self._eye_background = self._eye_panel:bitmap(eye_background_params)

	self._eye_background:set_center(self._eye_panel:w() / 2, self._eye_panel:h() / 2)
end

function HUDSuspicionIndicator:_create_eye_outside_ring()
	local eye_outside_ring_params = {
		name = "eye_outside_ring",
		texture = tweak_data.gui.icons[HUDSuspicionIndicator.EYE_OUTER_RING_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDSuspicionIndicator.EYE_OUTER_RING_ICON].texture_rect,
		layer = self._eye_background:layer() + 1
	}
	self._eye_outside_ring = self._eye_panel:bitmap(eye_outside_ring_params)

	self._eye_outside_ring:set_center(self._eye_background:center())
end

function HUDSuspicionIndicator:_create_eye_fill()
	local eye_fill_params = {
		position_z = 0,
		render_template = "VertexColorTexturedRadial",
		name = "eye_fill",
		texture = tweak_data.gui.icons[HUDSuspicionIndicator.EYE_FILL_ICON].texture,
		texture_rect = {
			tweak_data.gui:icon_w(HUDSuspicionIndicator.EYE_FILL_ICON),
			0,
			-tweak_data.gui:icon_w(HUDSuspicionIndicator.EYE_FILL_ICON),
			tweak_data.gui:icon_h(HUDSuspicionIndicator.EYE_FILL_ICON)
		},
		w = tweak_data.gui:icon_w(HUDSuspicionIndicator.EYE_FILL_ICON),
		h = tweak_data.gui:icon_h(HUDSuspicionIndicator.EYE_FILL_ICON),
		layer = self._eye_background:layer() + 1
	}
	self._eye_fill = self._eye_panel:bitmap(eye_fill_params)

	self._eye_fill:set_center(self._eye_background:center())
end

function HUDSuspicionIndicator:_create_calling_indicator()
	local calling_indicator_panel_params = {
		halign = "scale",
		name = "calling_indicator_panel",
		valign = "scale"
	}
	self._calling_indicator_panel = self._object:panel(calling_indicator_panel_params)
	self._calling_indicators = {}
	local phone_icon_params = {
		name = "calling_indicator_phone",
		alpha = 0,
		texture = tweak_data.gui.icons[HUDSuspicionIndicator.CALLING_INDICATOR_CENTER_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDSuspicionIndicator.CALLING_INDICATOR_CENTER_ICON].texture_rect
	}
	local phone_icon = self._calling_indicator_panel:bitmap(phone_icon_params)

	phone_icon:set_center_x(self._calling_indicator_panel:w() / 2)
	phone_icon:set_center_y(self._calling_indicator_panel:h() / 2)

	local calling_icon_in_params = {
		name = "calling_indicator_in",
		alpha = 0,
		texture = tweak_data.gui.icons[HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN].texture,
		texture_rect = tweak_data.gui.icons[HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN].texture_rect
	}
	local calling_icon_in = self._calling_indicator_panel:bitmap(calling_icon_in_params)

	calling_icon_in:set_center_x(self._calling_indicator_panel:w() / 2)
	calling_icon_in:set_center_y(self._calling_indicator_panel:h() / 2)

	local calling_icon_out_params = {
		name = "calling_indicator_out",
		alpha = 0,
		texture = tweak_data.gui.icons[HUDSuspicionIndicator.CALLING_INDICATOR_ICON_OUT].texture,
		texture_rect = tweak_data.gui.icons[HUDSuspicionIndicator.CALLING_INDICATOR_ICON_OUT].texture_rect
	}
	local calling_icon_out = self._calling_indicator_panel:bitmap(calling_icon_out_params)

	calling_icon_out:set_center_x(self._calling_indicator_panel:w() / 2)
	calling_icon_out:set_center_y(self._calling_indicator_panel:h() / 2)
	table.insert(self._calling_indicators, phone_icon)
	table.insert(self._calling_indicators, calling_icon_in)
	table.insert(self._calling_indicators, calling_icon_out)
end

function HUDSuspicionIndicator:observer_position()
	return self._observer_position
end

function HUDSuspicionIndicator:suspect()
	return self._suspect
end

function HUDSuspicionIndicator:set_progress(progress)
	if progress == self._progress then
		return
	end

	if self._old_progress and progress < self._old_progress then
		if self._current_progress then
			if self._current_progress >= progress then
				-- Nothing
			end
		end
	else
		self._old_progress = self._progress
		self._cdt = 0
	end

	self._progress = math.clamp(progress, 0, 1)
end

function HUDSuspicionIndicator:update_progress(t, dt)
	if self._progress and self._progress == 1 then
		self._eye_fill:set_position_z(1)

		return
	end

	if not self._old_progress or self._old_progress == 0 then
		self._eye_fill:set_position_z(0)

		return
	end

	self._current_progress = math.lerp(self._old_progress, self._progress, self._cdt)

	self._eye_fill:set_position_z(self._current_progress)

	self._cdt = self._cdt + dt
end

function HUDSuspicionIndicator:active_alpha()
	return self._active_alpha
end

function HUDSuspicionIndicator:state()
	return self._state
end

function HUDSuspicionIndicator:set_state(state, dont_animate)
	if self._state == state then
		return
	end

	if state == "heard_something" then
		-- Nothing
	elseif state == "saw_something" then
		self:set_state_saw_something()
	elseif state == "investigating" then
		self:set_state_investigating()
	elseif state == "alarmed" then
		self:set_state_alarmed()
	elseif state == "calling" then
		self:set_state_calling()
	end

	local color_change_occured = HUDSuspicionIndicator.STATE_COLORS[state] and (not HUDSuspicionIndicator.STATE_COLORS[self._state] or HUDSuspicionIndicator.STATE_COLORS[self._state] ~= HUDSuspicionIndicator.STATE_COLORS[state])

	if color_change_occured then
		if dont_animate then
			self._eye_fill:set_color(HUDSuspicionIndicator.STATE_COLORS[state])
			self._eye_outside_ring:set_color(HUDSuspicionIndicator.STATE_COLORS[state])
		else
			self:_rotate_eye_ring()
			self:_change_color(HUDSuspicionIndicator.STATE_COLORS[state])
		end
	end

	self._state = state

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("set_hud_suspicion_state", self._observer:id(), state)
	end
end

function HUDSuspicionIndicator:_rotate_eye_ring()
	if self._rotating_ring then
		return
	end

	self._eye_background:stop()
	self._eye_background:animate(callback(self, self, "_animate_ring_rotate"))
end

function HUDSuspicionIndicator:_change_color(new_color)
	self._eye_fill:stop()
	self._eye_fill:animate(callback(self, self, "_animate_color_change"), new_color)
end

function HUDSuspicionIndicator:set_state_saw_something()
end

function HUDSuspicionIndicator:set_state_investigating()
end

function HUDSuspicionIndicator:set_state_alarmed()
end

function HUDSuspicionIndicator:set_state_calling()
	self._eye_panel:animate(callback(self, self, "_animate_hide_suspicion"))
	self._calling_indicators[1]:stop()
	self._calling_indicators[1]:animate(callback(self, self, "_animate_create"), 0.5, 0.2, 1)
	self._calling_indicators[2]:stop()
	self._calling_indicators[2]:animate(callback(self, self, "_animate_indicator_calling"), 0.4)
	self._calling_indicators[3]:stop()
	self._calling_indicators[3]:animate(callback(self, self, "_animate_indicator_calling"), 0.8)
end

function HUDSuspicionIndicator:set_center(x, y)
	self._object:set_center(x, y)
end

function HUDSuspicionIndicator:destroy()
	if alive(self._object) then
		self._object:stop()
		self:_destroy()
	end
end

function HUDSuspicionIndicator:set_alpha(alpha)
	self._object:set_alpha(alpha)
end

function HUDSuspicionIndicator:alpha()
	return self._object:alpha()
end

function HUDSuspicionIndicator:go_offscreen()
	self._onscreen = false
end

function HUDSuspicionIndicator:go_onscreen()
	self._onscreen = true
end

function HUDSuspicionIndicator:onscreen()
	return self._onscreen
end

function HUDSuspicionIndicator:parent()
	return self._object:parent()
end

function HUDSuspicionIndicator:_destroy()
	self._eye_panel:stop()
	self._calling_indicators[1]:stop()
	self._calling_indicators[2]:stop()
	self._calling_indicators[3]:stop()
	self._object:clear()
	self._object:parent():remove(self._object)

	self._data = nil
	self._state = nil
	self._progress = nil
	self._onscreen = nil
end

function HUDSuspicionIndicator:_get_color_for_percentage(color_table, percentage)
	for i = #color_table, 1, -1 do
		if color_table[i].start_percentage < percentage then
			return color_table[i].color
		end
	end

	return color_table[1].color
end

function HUDSuspicionIndicator:_animate_ring_rotate(background)
	local t = 0
	local rotation_duration = 0.8
	self._rotating_ring = true
	local starting_rotation = self._eye_background:rotation()
	local wanted_rotation = (math.ceil(starting_rotation / 180) - 1) * 180

	while t < rotation_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_rotation = Easing.quartic_in_out(t, starting_rotation, wanted_rotation - starting_rotation, rotation_duration)

		self._eye_background:set_rotation(current_rotation)
		self._eye_outside_ring:set_rotation(current_rotation)
	end

	self._eye_background:set_rotation(wanted_rotation)
	self._eye_outside_ring:set_rotation(wanted_rotation)

	self._rotating_ring = false
end

function HUDSuspicionIndicator:_animate_color_change(eye_fill, new_color)
	local t = 0
	local color_change_duration = 0.8
	local starting_color = self._eye_fill:color()

	while t < color_change_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.quadratic_in_out(t, starting_color.r, new_color.r - starting_color.r, color_change_duration)
		local current_g = Easing.quadratic_in_out(t, starting_color.g, new_color.g - starting_color.g, color_change_duration)
		local current_b = Easing.quadratic_in_out(t, starting_color.b, new_color.b - starting_color.b, color_change_duration)

		self._eye_fill:set_color(Color(current_r, current_g, current_b))
		self._eye_outside_ring:set_color(Color(current_r, current_g, current_b))
	end

	self._eye_fill:set_color(new_color)
	self._eye_outside_ring:set_color(new_color)
end

function HUDSuspicionIndicator:_animate_hide_suspicion()
	local duration = 0.25
	local t = 0

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, self._active_alpha, -self._active_alpha, duration)

		self._eye_panel:set_alpha(current_alpha)
	end

	self._eye_panel:set_alpha(0)
end

function HUDSuspicionIndicator:_animate_indicator_calling(indicator, delay)
	while true do
		local final_size_multiplier = 1.3
		local fade_in_duration = 0.4
		local visible_sustain = indicator:alpha() * fade_in_duration
		local fade_out_duration = 0.4
		local invisible_sustain = 0.5
		local total_duration = fade_in_duration + visible_sustain + fade_out_duration
		local t = 0
		local total_t = 0

		if delay then
			wait(delay)

			total_duration = total_duration + delay
			total_t = total_t + delay
		end

		indicator:set_w(tweak_data.gui:icon_w(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN))
		indicator:set_h(tweak_data.gui:icon_h(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN))
		indicator:set_center_x(self._calling_indicator_panel:w() / 2)
		indicator:set_center_y(self._calling_indicator_panel:h() / 2)

		while t < fade_in_duration do
			local dt = coroutine.yield()
			t = t + dt
			total_t = total_t + dt
			local current_alpha = Easing.quadratic_in_out(t, 0, 1, fade_in_duration)

			indicator:set_alpha(current_alpha)

			local current_size = Easing.quadratic_in(total_t, 1, final_size_multiplier - 1, total_duration)

			indicator:set_w(tweak_data.gui:icon_w(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN) * current_size)
			indicator:set_h(tweak_data.gui:icon_h(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN) * current_size)
			indicator:set_center_x(self._calling_indicator_panel:w() / 2)
			indicator:set_center_y(self._calling_indicator_panel:h() / 2)
		end

		indicator:set_alpha(1)

		t = 0

		while visible_sustain > t do
			local dt = coroutine.yield()
			t = t + dt
			total_t = total_t + dt
			local current_size = Easing.quadratic_in(total_t, 1, final_size_multiplier - 1, total_duration)

			indicator:set_w(tweak_data.gui:icon_w(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN) * current_size)
			indicator:set_h(tweak_data.gui:icon_h(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN) * current_size)
			indicator:set_center_x(self._calling_indicator_panel:w() / 2)
			indicator:set_center_y(self._calling_indicator_panel:h() / 2)
		end

		t = 0

		while fade_out_duration > t do
			local dt = coroutine.yield()
			t = t + dt
			total_t = total_t + dt
			local current_alpha = Easing.quadratic_in_out(t, 1, -1, fade_out_duration)

			indicator:set_alpha(current_alpha)

			local current_size = Easing.quadratic_in(total_t, 1, final_size_multiplier - 1, total_duration)

			indicator:set_w(tweak_data.gui:icon_w(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN) * current_size)
			indicator:set_h(tweak_data.gui:icon_h(HUDSuspicionIndicator.CALLING_INDICATOR_ICON_IN) * current_size)
			indicator:set_center_x(self._calling_indicator_panel:w() / 2)
			indicator:set_center_y(self._calling_indicator_panel:h() / 2)
		end

		indicator:set_alpha(0)
		wait(invisible_sustain)
	end
end

function HUDSuspicionIndicator:_animate_destroy()
	local duration = 0.3
	local t = (1 - self._object:alpha() / self._active_alpha) * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, self._active_alpha, -self._active_alpha, duration)

		self._object:set_alpha(current_alpha)
	end

	self._object:set_alpha(0)
	self:_destroy()
end

function HUDSuspicionIndicator:_animate_create(object, fade_in_duration, delay, new_alpha)
	local duration = fade_in_duration or 0.15
	local t = 0

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, new_alpha or self._active_alpha, duration)

		object:set_alpha(current_alpha)
	end

	object:set_alpha(new_alpha or self._active_alpha)
end
