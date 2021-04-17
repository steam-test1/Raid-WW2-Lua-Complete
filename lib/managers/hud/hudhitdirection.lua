HUDHitDirection = HUDHitDirection or class()
HUDHitDirection.W = 512
HUDHitDirection.H = 512
HUDHitDirection.UNIT_TYPE_HIT_PLAYER = 1
HUDHitDirection.UNIT_TYPE_HIT_VEHICLE = 2
HUDHitDirection.DAMAGE_INDICATOR_BASE = "damage_indicator_"
HUDHitDirection.DEFAULT_DAMAGE_INDICATOR = 1
HUDHitDirection.DAMAGE_INDICATOR_DURATION = 1
HUDHitDirection.INDICATOR_FADE_IN_DURATION = 0.2
HUDHitDirection.INDICATOR_FADE_OUT_DURATION = 0.25
HUDHitDirection.SEVERITY_THRESHOLDS = {
	0,
	3,
	6,
	9
}

-- Lines 18-24
function HUDHitDirection:init(hud)
	self:_create_panel(hud)
	self:_create_directional_indicators()

	self._indicators = {}

	managers.hud:add_updator("hit_direction_indicators", callback(self, self, "update"))
end

-- Lines 26-41
function HUDHitDirection:_create_panel(hud)
	if hud.panel:child("hit_direction_panel") then
		hud.panel:remove(hud.panel:child("hit_direction_panel"))
	end

	local panel_params = {
		layer = -5,
		name = "hit_direction_panel",
		halign = "center",
		visible = true,
		valign = "center",
		w = HUDHitDirection.W,
		h = HUDHitDirection.H
	}
	self._object = hud.panel:panel(panel_params)

	self._object:set_center(hud.panel:w() / 2, hud.panel:h() / 2)
end

-- Lines 43-59
function HUDHitDirection:_create_directional_indicators()
	local left = self:_create_indicator("left", -90, "left", "center")

	left:set_left(0)
	left:set_center_y(self._object:h() / 2)

	local right = self:_create_indicator("right", 90, "right", "center")

	right:set_right(self._object:w())
	right:set_center_y(self._object:h() / 2)

	local up = self:_create_indicator("up", 0, "center", "top")

	up:set_top(0)
	up:set_center_x(self._object:w() / 2)

	local down = self:_create_indicator("down", 180, "center", "bottom")

	down:set_bottom(self._object:h())
	down:set_center_x(self._object:w() / 2)
end

-- Lines 61-73
function HUDHitDirection:_create_indicator(name, rotation, halign, valign)
	local indicator_params = {
		alpha = 0,
		visible = true,
		name = name,
		texture = tweak_data.gui.icons[HUDHitDirection.DAMAGE_INDICATOR_BASE .. HUDHitDirection.DEFAULT_DAMAGE_INDICATOR].texture,
		texture_rect = tweak_data.gui.icons[HUDHitDirection.DAMAGE_INDICATOR_BASE .. HUDHitDirection.DEFAULT_DAMAGE_INDICATOR].texture_rect,
		rotation = rotation,
		halign = halign,
		valign = valign
	}
	local indicator = self._object:bitmap(indicator_params)

	return indicator
end

-- Lines 76-81
function HUDHitDirection:on_hit_direction(direction, unit_type_hit)
	local direction = self._object:child(direction)

	direction:stop()
	direction:animate(callback(self, self, "_animate_hit_direction"))
end

-- Lines 83-97
function HUDHitDirection:_animate_hit_direction(direction)
	local duration = 0.6
	local t = duration

	direction:set_alpha(1)

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		direction:set_alpha(t / duration)
	end

	direction:set_alpha(0)
end

-- Lines 101-125
function HUDHitDirection:on_hit_unit(attack_data, unit_type_hit)
	local attacker_id = tostring(attack_data.attacker_unit:key())

	if not self._indicators[attacker_id] then
		local indicator = self:_create_indicator("damage_indicator_unit_" .. attacker_id, 0, "center", "center")
		local enemy_position = attack_data.attacker_unit:position()
		self._indicators[attacker_id] = {
			severity = 1,
			need_to_extend = false,
			fade_out_t = 0,
			indicator = indicator,
			position = enemy_position,
			damage = attack_data.damage,
			t = HUDHitDirection.DAMAGE_INDICATOR_DURATION,
			fade_in_t = HUDHitDirection.INDICATOR_FADE_IN_DURATION
		}
	else
		self._indicators[attacker_id].need_to_extend = true
		self._indicators[attacker_id].position = attack_data.attacker_unit:position()
		self._indicators[attacker_id].damage = self._indicators[attacker_id].damage + attack_data.damage

		self:_set_proper_severity(attacker_id)
	end
end

-- Lines 127-137
function HUDHitDirection:_set_proper_severity(id)
	if self._indicators[id].severity == #HUDHitDirection.SEVERITY_THRESHOLDS then
		return
	end

	if HUDHitDirection.SEVERITY_THRESHOLDS[self._indicators[id].severity + 1] < self._indicators[id].damage then
		self._indicators[id].severity = self._indicators[id].severity + 1

		self._indicators[id].indicator:set_texture_rect(unpack(tweak_data.gui.icons[HUDHitDirection.DAMAGE_INDICATOR_BASE .. self._indicators[id].severity].texture_rect))
	end
end

-- Lines 139-184
function HUDHitDirection:update(t, dt)
	if not managers.player:player_unit() or not managers.player:player_unit():movement() then
		return
	end

	local player_pos = managers.player:player_unit():movement():m_pos()
	local cam_fwd = managers.player:player_unit():camera():forward()

	for id, indicator_data in pairs(self._indicators) do
		indicator_data.t = indicator_data.t - dt
		indicator_data.fade_in_t = math.clamp(indicator_data.fade_in_t - dt, 0, 1)

		if indicator_data.t - HUDHitDirection.INDICATOR_FADE_OUT_DURATION <= 0 then
			indicator_data.fade_out_t = math.clamp(indicator_data.fade_out_t + dt, 0, 1)
		end

		indicator_data.indicator:set_alpha(1 - indicator_data.fade_in_t / HUDHitDirection.INDICATOR_FADE_IN_DURATION - indicator_data.fade_out_t / HUDHitDirection.INDICATOR_FADE_OUT_DURATION)

		local enemy_pos = self._indicators[id].position:with_z(player_pos.z)
		local angle = (enemy_pos - player_pos):normalized():angle(cam_fwd)
		local cross_prod = (enemy_pos - player_pos):normalized():cross(cam_fwd)
		local orientation = cross_prod:dot(math.UP)

		if orientation < 0 then
			angle = -angle
		end

		local dx = (self._object:w() / 2 - indicator_data.indicator:h() / 2) * math.cos(angle - 90)
		local dy = (self._object:h() / 2 - indicator_data.indicator:h() / 2) * math.sin(angle - 90)

		indicator_data.indicator:set_rotation(angle)
		indicator_data.indicator:set_x(self._object:w() / 2 - indicator_data.indicator:w() / 2 + dx)
		indicator_data.indicator:set_y(self._object:h() / 2 - indicator_data.indicator:h() / 2 + dy)

		if indicator_data.need_to_extend == true then
			indicator_data.t = HUDHitDirection.DAMAGE_INDICATOR_DURATION
			indicator_data.fade_out_t = 0
			indicator_data.need_to_extend = false
		end

		if indicator_data.t <= 0 then
			self:_remove_indicator(id)
		end
	end
end

-- Lines 186-189
function HUDHitDirection:_remove_indicator(id)
	self._object:remove(self._indicators[id].indicator)

	self._indicators[id] = nil
end

-- Lines 191-198
function HUDHitDirection:clean_up()
	for index, indicator_data in pairs(self._indicators) do
		indicator_data.indicator:stop()
		self._object:remove(indicator_data.indicator)
	end

	self._indicators = {}
end
