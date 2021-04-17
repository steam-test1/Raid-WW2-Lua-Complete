HUDTeammateBase = HUDTeammateBase or class()

-- Lines 4-5
function HUDTeammateBase:init(i, teammates_panel)
end

-- Lines 7-9
function HUDTeammateBase:panel()
	return self._object
end

-- Lines 11-13
function HUDTeammateBase:w()
	return self._object:w()
end

-- Lines 15-17
function HUDTeammateBase:h()
	return self._object:h()
end

-- Lines 19-21
function HUDTeammateBase:padding_down()
	return 0
end

-- Lines 23-25
function HUDTeammateBase:set_x(x)
	self._object:set_x(x)
end

-- Lines 27-29
function HUDTeammateBase:set_y(y)
	self._object:set_y(y)
end

-- Lines 31-33
function HUDTeammateBase:show()
	self._object:set_visible(true)
end

-- Lines 35-40
function HUDTeammateBase:hide()
	self._object:set_visible(false)
	self:stop_timer()

	self._peer_id = nil
end

-- Lines 43-45
function HUDTeammateBase:peer_id()
	return self._peer_id
end

-- Lines 47-49
function HUDTeammateBase:set_peer_id(peer_id)
	self._peer_id = peer_id
end

-- Lines 51-53
function HUDTeammateBase:is_ai()
	return false
end

-- Lines 55-56
function HUDTeammateBase:set_health(data)
end

-- Lines 58-59
function HUDTeammateBase:set_stamina(value)
end

-- Lines 61-62
function HUDTeammateBase:set_max_stamina(value)
end

-- Lines 64-65
function HUDTeammateBase:set_warcry_meter_fill(data)
end

-- Lines 67-68
function HUDTeammateBase:activate_warcry(duration)
end

-- Lines 70-71
function HUDTeammateBase:deactivate_warcry()
end

-- Lines 73-74
function HUDTeammateBase:set_warcry_ready(value)
end

-- Lines 76-77
function HUDTeammateBase:set_name(name)
end

-- Lines 79-80
function HUDTeammateBase:set_nationality(nationality)
end

-- Lines 82-83
function HUDTeammateBase:set_cheater(state)
end

-- Lines 85-86
function HUDTeammateBase:start_interact(timer)
end

-- Lines 90-91
function HUDTeammateBase:set_carry_info(carry_id)
end

-- Lines 94-95
function HUDTeammateBase:remove_carry_info()
end

-- Lines 97-98
function HUDTeammateBase:show_turret_icon()
end

-- Lines 100-101
function HUDTeammateBase:hide_turret_icon()
end

-- Lines 103-104
function HUDTeammateBase:show_lockpick_icon()
end

-- Lines 106-107
function HUDTeammateBase:hide_lockpick_icon()
end

-- Lines 111-112
function HUDTeammateBase:add_special_equipment(data)
end

-- Lines 114-115
function HUDTeammateBase:remove_special_equipment(equipment)
end

-- Lines 117-118
function HUDTeammateBase:set_special_equipment_amount(equipment_id, amount)
end

-- Lines 120-121
function HUDTeammateBase:clear_special_equipment()
end

-- Lines 125-128
function HUDTeammateBase:go_into_bleedout()
	self:_clear_states()
	self:_add_active_state("downed")
end

-- Lines 130-134
function HUDTeammateBase:on_revived()
	self:_remove_active_state("downed")
	self:_remove_active_state("revived")
	self:stop_timer()
end

-- Lines 136-139
function HUDTeammateBase:on_died()
	self:_add_active_state("dead")
	self:_remove_active_state("downed")
end

-- Lines 141-145
function HUDTeammateBase:_clear_states()
	self._active_states = {}
	self._displayed_state = self._states[#self._states]

	self:_add_active_state(self._displayed_state.id)
end

-- Lines 147-148
function HUDTeammateBase:set_condition(icon_data, text)
end

-- Lines 150-152
function HUDTeammateBase:reset_state()
end

-- Lines 154-157
function HUDTeammateBase:_add_active_state(state_id)
	self._active_states[state_id] = true

	self:_check_state_change()
end

-- Lines 159-162
function HUDTeammateBase:_remove_active_state(state_id)
	self._active_states[state_id] = nil

	self:_check_state_change()
end

-- Lines 164-182
function HUDTeammateBase:_check_state_change()
	local new_state = nil

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

-- Lines 184-231
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
		self._status_panel:child(state.control):set_alpha(0)
	end

	self._status_panel:child(self._displayed_state.control):set_alpha(1)

	local fade_in_duration = 0.15
	t = 0

	while fade_in_duration > t do
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

-- Lines 235-241
function HUDTeammateBase:start_timer(time, current)
	self._timer_total = time
	self._timer_current = current or time
	self._is_timer_running = true

	self._timer_text:animate(callback(self, self, "_animate_timer_countdown"))
end

-- Lines 243-245
function HUDTeammateBase:set_pause_timer(pause)
	self._is_timer_running = not pause
end

-- Lines 247-249
function HUDTeammateBase:is_timer_running()
	return self._is_timer_running
end

-- Lines 251-256
function HUDTeammateBase:stop_timer()
	self._timer_total = nil
	self._is_timer_running = false

	self._timer_text:stop()
end

-- Lines 258-271
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

-- Lines 275-276
function HUDTeammateBase:_set_status_icon(new_status_icon)
end
