HUDSuspicionDirection = HUDSuspicionDirection or class()
HUDSuspicionDirection.W = 362
HUDSuspicionDirection.H = 362
HUDSuspicionDirection.RADIUS = 195
HUDSuspicionDirection.ICON_FILL = "stealth_indicator_fill"
HUDSuspicionDirection.ICON_STROKE = "stealth_indicator_stroke"
HUDSuspicionDirection.PLAYER_ACTIVE_ALPHA = 1
HUDSuspicionDirection.TEAMMATE_ACTIVE_ALPHA = 0.6
HUDSuspicionDirection.USE_STATE_COLORS = true
HUDSuspicionDirection.STATE_COLORS = {
	heard_something = Color("ececec"),
	saw_something = Color("ececec"),
	investigating = Color("dd9a38"),
	alarmed = Color("b8392e"),
	calling = Color("b8392e")
}

-- Lines 23-35
function HUDSuspicionDirection:init(hud)
	self._hud_panel = hud.panel
	self._indicators = {}
	self._number_of_indicators = 0

	if self._hud_panel:child("suspicion_direction_panel") then
		self._hud_panel:remove(self._hud_panel:child("suspicion_direction_panel"))
	end

	self:_create_panel()
	managers.hud:add_updator("suspicion_direction_panel", callback(self, self, "update_suspicion_indicators"))
end

-- Lines 37-47
function HUDSuspicionDirection:_create_panel(hud)
	local panel_params = {
		layer = -5,
		name = "suspicion_direction_panel",
		halign = "center",
		valign = "center",
		w = HUDSuspicionDirection.W,
		h = HUDSuspicionDirection.H
	}
	self._suspicion_direction_panel = self._hud_panel:panel(panel_params)

	self._suspicion_direction_panel:set_center(self._suspicion_direction_panel:parent():w() / 2, self._suspicion_direction_panel:parent():h() / 2)
end

-- Lines 49-60
function HUDSuspicionDirection:create_suspicion_indicator(observer_key, observer_position, initial_state, suspect)
	if self._indicators[observer_key] then
		return
	end

	local indicator = self:_create_suspicion_indicator(observer_key)
	local indicator_active_alpha = HUDManager.DIFFERENT_SUSPICION_INDICATORS_FOR_TEAMMATES == true and suspect == "teammate" and HUDSuspicionDirection.TEAMMATE_ACTIVE_ALPHA or HUDSuspicionDirection.PLAYER_ACTIVE_ALPHA
	self._indicators[observer_key] = {
		state = "heard_something",
		need_to_init = true,
		indicator = indicator,
		position = observer_position,
		suspect = suspect,
		active_alpha = indicator_active_alpha
	}
	self._number_of_indicators = self._number_of_indicators + 1

	self:set_state(observer_key, initial_state)
end

-- Lines 62-86
function HUDSuspicionDirection:_create_suspicion_indicator(id)
	local indicator_panel_params = {
		alpha = 0,
		name = "indicator_panel_" .. tostring(id),
		w = tweak_data.gui:icon_w(HUDSuspicionDirection.ICON_FILL),
		h = tweak_data.gui:icon_h(HUDSuspicionDirection.ICON_FILL)
	}
	local indicator = self._suspicion_direction_panel:panel(indicator_panel_params)
	local indicator_fill_params = {
		name = "indicator_fill",
		texture = tweak_data.gui.icons[HUDSuspicionDirection.ICON_FILL].texture,
		texture_rect = tweak_data.gui.icons[HUDSuspicionDirection.ICON_FILL].texture_rect
	}
	local indicator_fill = indicator:bitmap(indicator_fill_params)
	local indicator_stroke_params = {
		name = "indicator_stroke",
		texture = tweak_data.gui.icons[HUDSuspicionDirection.ICON_STROKE].texture,
		texture_rect = tweak_data.gui.icons[HUDSuspicionDirection.ICON_STROKE].texture_rect
	}
	local indicator_stroke = indicator:bitmap(indicator_stroke_params)

	return indicator
end

-- Lines 88-94
function HUDSuspicionDirection:need_to_init(observer_key)
	if self._indicators[observer_key] ~= nil then
		return self._indicators[observer_key].need_to_init
	end

	return false
end

-- Lines 96-101
function HUDSuspicionDirection:initialize(observer_key, alpha)
	if alpha == 1 then
		self._indicators[observer_key].indicator:animate(callback(self, self, "_animate_alpha"), self._indicators[observer_key].active_alpha, 0.5)
	end

	self._indicators[observer_key].need_to_init = false
end

-- Lines 103-114
function HUDSuspicionDirection:set_state(observer_key, state)
	if not self._indicators[observer_key] then
		return
	end

	self._indicators[observer_key].state = state

	if HUDSuspicionDirection.STATE_COLORS[state] and HUDSuspicionDirection.USE_STATE_COLORS then
		self._indicators[observer_key].indicator:child("indicator_fill"):stop()
		self._indicators[observer_key].indicator:child("indicator_fill"):animate(callback(self, self, "_animate_color"), HUDSuspicionDirection.STATE_COLORS[state])
	end
end

-- Lines 116-117
function HUDSuspicionDirection:set_suspicion_indicator_progress(observer_key, progress)
end

-- Lines 119-124
function HUDSuspicionDirection:show_suspicion_indicator(observer_key)
	if self._indicators[observer_key] ~= nil then
		self._indicators[observer_key].indicator:stop()
		self._indicators[observer_key].indicator:animate(callback(self, self, "_animate_alpha"), self._indicators[observer_key].active_alpha, 0.2)
	end
end

-- Lines 126-131
function HUDSuspicionDirection:hide_suspicion_indicator(observer_key)
	if self._indicators[observer_key] ~= nil then
		self._indicators[observer_key].indicator:stop()
		self._indicators[observer_key].indicator:animate(callback(self, self, "_animate_alpha"), 0, 0.2)
	end
end

-- Lines 133-137
function HUDSuspicionDirection:remove_suspicion_indicator(observer_key)
	if self._indicators[observer_key] ~= nil and alive(self._indicators[observer_key].indicator) then
		self._indicators[observer_key].indicator:animate(callback(self, self, "_animate_alpha"), 0, 0.5, self._remove_suspicion_indicator, {
			observer_key
		})
	end
end

-- Lines 139-148
function HUDSuspicionDirection:_remove_suspicion_indicator(observer_key)
	self._indicators[observer_key].indicator:clear()
	self._suspicion_direction_panel:remove(self._indicators[observer_key].indicator)

	self._indicators[observer_key] = nil
	self._number_of_indicators = self._number_of_indicators - 1

	if self._number_of_indicators < 0 then
		debug_pause("TRYING TO REMOVE MORE SUSPICION INDICATORS THAN AVAILABLE!")
	end
end

-- Lines 150-177
function HUDSuspicionDirection:update_suspicion_indicators()
	if self._number_of_indicators == 0 or self._number_of_indicators == nil or managers.player:player_unit() == nil then
		return
	end

	local player_pos = managers.player:player_unit():movement():m_pos()
	local cam_fwd = managers.player:player_unit():camera():forward()

	for index, indicator in pairs(self._indicators) do
		local angle = (indicator.position - player_pos):normalized():angle(cam_fwd)
		local cross_prod = (indicator.position - player_pos):normalized():cross(cam_fwd)
		local orientation = cross_prod:dot(math.UP)

		if orientation < 0 then
			angle = -angle
		end

		local dx = self._suspicion_direction_panel:w() / 2 * math.cos(angle - 90)
		local dy = self._suspicion_direction_panel:h() / 2 * math.sin(angle - 90)

		indicator.indicator:child("indicator_fill"):set_rotation(angle)
		indicator.indicator:child("indicator_stroke"):set_rotation(angle)
		indicator.indicator:set_x(self._suspicion_direction_panel:w() / 2 - indicator.indicator:w() / 2 + dx)
		indicator.indicator:set_y(self._suspicion_direction_panel:h() / 2 - indicator.indicator:h() / 2 + dy)
	end
end

-- Lines 179-188
function HUDSuspicionDirection:clean_up()
	for u_key, u_data in pairs(self._indicators) do
		u_data.indicator:stop()
		u_data.indicator:clear()
		self._suspicion_direction_panel:remove(u_data.indicator)
	end

	self._indicators = {}
	self._number_of_indicators = 0
end

-- Lines 190-216
function HUDSuspicionDirection:_animate_alpha(indicator, new_alpha, duration, clbk, clbk_data)
	local t = 0
	local dt = nil
	local starting_alpha = indicator:alpha()
	local change = new_alpha - starting_alpha

	while t < duration do
		local curr_alpha = Easing.quartic_in_out(t, starting_alpha, change, duration)

		indicator:set_alpha(curr_alpha)

		dt = coroutine.yield()
		t = t + dt

		if duration <= t then
			indicator:set_alpha(starting_alpha + change)
		end
	end

	indicator:set_alpha(new_alpha)

	if clbk ~= nil then
		clbk(self, unpack(clbk_data))
	end
end

-- Lines 218-234
function HUDSuspicionDirection:_animate_color(indicator, new_color)
	local duration = 0.2
	local t = 0
	local initial_color = indicator:color()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_r = Easing.cubic_in_out(t, initial_color.r, new_color.r - initial_color.r, duration)
		local current_g = Easing.cubic_in_out(t, initial_color.g, new_color.g - initial_color.g, duration)
		local current_b = Easing.cubic_in_out(t, initial_color.b, new_color.b - initial_color.b, duration)

		indicator:set_color(Color(current_r, current_g, current_b))
	end

	indicator:set_color(new_color)
end

-- Lines 243-246
function HUDSuspicionDirection:_remove_indicator(id)
	self._suspicion_direction_panel:remove(self._indicators[id].indicator)

	self._indicators[id] = nil
end

-- Lines 248-301
function HUDSuspicionDirection:_animate_suspicion(id)
	local indicator_show_duration = tweak_data.player.damage_indicator_duration
	local t = indicator_show_duration
	local st_fade_in_t = 0.2
	local fade_in_t = st_fade_in_t
	local st_fade_out_t = 0.25
	local fade_out_t = 0
	local indicator = self._indicators[id]

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		fade_in_t = math.clamp(fade_in_t - dt, 0, 1)

		if t - st_fade_out_t <= 0 then
			fade_out_t = math.clamp(fade_out_t + dt, 0, 1)
		end

		indicator.indicator:set_alpha(1 - fade_in_t / st_fade_in_t - fade_out_t / st_fade_out_t)

		local player_pos = managers.player:player_unit():movement():m_pos()
		local enemy_pos = self._indicators[id].position:with_z(player_pos.z)
		local cam_fwd = managers.player:player_unit():camera():forward()
		local angle = (enemy_pos - player_pos):normalized():angle(cam_fwd)
		local cross_prod = (enemy_pos - player_pos):normalized():cross(cam_fwd)
		local orientation = cross_prod:dot(math.UP)

		if orientation < 0 then
			angle = -angle
		end

		local dx = 100 * math.cos(angle - 90)
		local dy = 100 * math.sin(angle - 90)

		indicator.indicator:child("indicator_fill"):set_rotation(angle)
		indicator.indicator:child("indicator_stroke"):set_rotation(angle)
		indicator.indicator:set_x(self._suspicion_direction_panel:w() / 2 - indicator:w() / 2 + dx)
		indicator.indicator:set_y(self._suspicion_direction_panel:h() / 2 - indicator:h() / 2 + dy)

		if indicator.need_to_extend == true then
			t = indicator_show_duration
			fade_out_t = 0
			indicator.need_to_extend = false
		end
	end

	self:_remove_indicator(id)
end
