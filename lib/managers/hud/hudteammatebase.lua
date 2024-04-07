HUDTeammateBase = HUDTeammateBase or class()

function HUDTeammateBase:init(i, teammates_panel)
	return
end

function HUDTeammateBase:panel()
	return self._object
end

function HUDTeammateBase:w()
	return self._object:w()
end

function HUDTeammateBase:h()
	return self._object:h()
end

function HUDTeammateBase:padding_down()
	return 0
end

function HUDTeammateBase:set_x(x)
	self._object:set_x(x)
end

function HUDTeammateBase:set_y(y)
	self._object:set_y(y)
end

function HUDTeammateBase:show()
	self._object:set_visible(true)
end

function HUDTeammateBase:hide()
	self._object:set_visible(false)
	self:stop_timer()

	self._peer_id = nil
end

function HUDTeammateBase:peer_id()
	return self._peer_id
end

function HUDTeammateBase:set_peer_id(peer_id)
	self._peer_id = peer_id
end

function HUDTeammateBase:is_ai()
	return false
end

function HUDTeammateBase:set_health(data)
	return
end

function HUDTeammateBase:set_stamina(value)
	return
end

function HUDTeammateBase:set_max_stamina(value)
	return
end

function HUDTeammateBase:set_warcry_meter_fill(data)
	return
end

function HUDTeammateBase:activate_warcry(duration)
	return
end

function HUDTeammateBase:deactivate_warcry()
	return
end

function HUDTeammateBase:set_warcry_ready(value)
	return
end

function HUDTeammateBase:set_name(name)
	return
end

function HUDTeammateBase:set_nationality(nationality)
	return
end

function HUDTeammateBase:set_cheater(state)
	return
end

function HUDTeammateBase:start_interact(timer)
	return
end

function HUDTeammateBase:set_carry_info(carry_id)
	return
end

function HUDTeammateBase:remove_carry_info()
	return
end

function HUDTeammateBase:show_turret_icon()
	return
end

function HUDTeammateBase:hide_turret_icon()
	return
end

function HUDTeammateBase:show_lockpick_icon()
	return
end

function HUDTeammateBase:hide_lockpick_icon()
	return
end

function HUDTeammateBase:add_special_equipment(data)
	return
end

function HUDTeammateBase:remove_special_equipment(equipment)
	return
end

function HUDTeammateBase:set_special_equipment_amount(equipment_id, amount)
	return
end

function HUDTeammateBase:clear_special_equipment()
	return
end

function HUDTeammateBase:go_into_bleedout()
	self:_clear_states()
	self:_add_active_state("downed")
end

function HUDTeammateBase:on_revived()
	self:_remove_active_state("downed")
	self:_remove_active_state("revived")
	self:stop_timer()
end

function HUDTeammateBase:on_died()
	self:_add_active_state("dead")
	self:_remove_active_state("downed")
end

function HUDTeammateBase:_clear_states()
	self._active_states = {}
	self._displayed_state = self._states[#self._states]

	self:_add_active_state(self._displayed_state.id)
end

function HUDTeammateBase:set_condition(icon_data, text)
	return
end

function HUDTeammateBase:reset_state()
	return
end

function HUDTeammateBase:_add_active_state(state_id)
	self._active_states[state_id] = true

	self:_check_state_change()
end

function HUDTeammateBase:_remove_active_state(state_id)
	self._active_states[state_id] = nil

	self:_check_state_change()
end

function HUDTeammateBase:_check_state_change()
	local new_state

	for i = 1, #self._states do
		if self._active_states[self._states[i].id] then
			if self._states[i].id == self._displayed_state.id then
				return
			end

			new_state = self._states[i]

			break
		end
	end

	if new_state then
		self._status_panel:stop()
		self._status_panel:animate(callback(self, self, "_animate_state_change"), new_state)
	end
end

function HUDTeammateBase:_animate_state_change(status_panel, new_state)
	local old_state = self._displayed_state
	local fade_out_duration = 0.15
	local t = (1 - self._status_panel:alpha()) * fade_out_duration

	self._displayed_state = new_state

	while t < fade_out_duration do
		local dt = coroutine.yield()

		t = t + dt

		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._status_panel:set_alpha(current_alpha)

		if new_state.hidden then
			for index, control_id in pairs(new_state.hidden) do
				local control = self._left_panel:child(control_id)

				control:set_alpha(current_alpha)
			end
		end
	end

	for index, state in pairs(self._states) do
		local c = state.control and self._status_panel:child(state.control)

		if c then
			c:set_alpha(0)
		else
			Application:warn("[HUDTeammateBase:_animate_state_change] no state control (index, state)", index, state)
		end
	end

	self._status_panel:child(self._displayed_state.control):set_alpha(1)

	local fade_in_duration = 0.15

	t = 0

	while t < fade_in_duration do
		local dt = coroutine.yield()

		t = t + dt

		local current_alpha = Easing.quartic_in_out(t, 0, 1, fade_in_duration)

		self._status_panel:set_alpha(current_alpha)

		if old_state.hidden then
			for index, control_id in pairs(old_state.hidden) do
				local control = self._left_panel:child(control_id)

				control:set_alpha(current_alpha)
			end
		end
	end

	self._status_panel:set_alpha(1)
end

function HUDTeammateBase:start_timer(time, current)
	self._timer_total = time
	self._timer_current = current or time
	self._is_timer_running = true

	self._timer_text:animate(callback(self, self, "_animate_timer_countdown"))
end

function HUDTeammateBase:set_pause_timer(pause)
	self._is_timer_running = not pause
end

function HUDTeammateBase:is_timer_running()
	return self._is_timer_running
end

function HUDTeammateBase:stop_timer()
	self._timer_total = nil
	self._is_timer_running = false

	self._timer_text:stop()
end

function HUDTeammateBase:_animate_timer_countdown()
	while self._timer_current > 0 and self._timer_total and self._timer_total > 0 do
		local dt = coroutine.yield()

		if self._is_timer_running and self._timer_total and self._timer_total > 0 then
			self._timer_current = self._timer_current - dt

			self._timer_bar:set_position_z(self._timer_current / self._timer_total)

			local time_text = math.round(self._timer_current) < 10 and "0" .. math.round(self._timer_current) or math.round(self._timer_current)

			self._timer_text:set_text(time_text)
		end
	end
end

function HUDTeammateBase:_set_status_icon(new_status_icon)
	return
end
