HUDMapWaypointBase = HUDMapWaypointBase or class()

-- Lines 3-13
function HUDMapWaypointBase.create(panel, waypoint_data)
	if waypoint_data.map_icon then
		return HUDMapWaypointIcon:new(panel, waypoint_data)
	elseif waypoint_data.waypoint_type == "objective" and waypoint_data.waypoint_display == "point" then
		return HUDMapWaypointPoint:new(panel, waypoint_data)
	elseif waypoint_data.waypoint_type == "objective" and waypoint_data.waypoint_display == "circle" then
		return HUDMapWaypointCircle:new(panel, waypoint_data)
	end

	return nil
end

-- Lines 15-17
function HUDMapWaypointBase:init(waypoint_data)
	self._id = waypoint_data.id_string
end

-- Lines 19-21
function HUDMapWaypointBase:set_center_x(x)
	self._object:set_center_x(x)
end

-- Lines 23-25
function HUDMapWaypointBase:set_center_y(y)
	self._object:set_center_y(y)
end

-- Lines 27-30
function HUDMapWaypointBase:set_position(x, y)
	self:set_center_x(x)
	self:set_center_y(y)
end

-- Lines 32-33
function HUDMapWaypointBase:set_data(waypoint_data)
end

-- Lines 35-37
function HUDMapWaypointBase:id()
	return self._id
end

-- Lines 39-41
function HUDMapWaypointBase:show()
	self._object:set_visible(true)
end

-- Lines 43-45
function HUDMapWaypointBase:hide()
	self._object:set_visible(false)
end

-- Lines 47-51
function HUDMapWaypointBase:destroy()
	self._id = nil

	self._object:clear()
	self._object:parent():remove(self._object)
end

HUDMapWaypointCircle = HUDMapWaypointCircle or class(HUDMapWaypointBase)
HUDMapWaypointCircle.RADAR_ICON = "map_unknown_location"

-- Lines 73-78
function HUDMapWaypointCircle:init(panel, waypoint_data)
	HUDMapWaypointCircle.super.init(self, waypoint_data)
	self:_create_panel(panel, waypoint_data)
	self:_create_radar_icon(waypoint_data)
end

-- Lines 80-91
function HUDMapWaypointCircle:_create_panel(panel, waypoint_data)
	local radius = waypoint_data.waypoint_radius
	local panel_params = {
		visible = false,
		is_root_panel = true,
		name = "map_waypoint_circle_" .. tostring(self._id),
		w = radius * 2,
		h = radius * 2
	}
	self._object = RaidGUIPanel:new(panel, panel_params)
end

-- Lines 93-108
function HUDMapWaypointCircle:_create_radar_icon(waypoint_data)
	local radius = waypoint_data.waypoint_radius
	local radar_icon_params = {
		name = "radar_icon",
		x = radius - 3,
		w = radius - 3,
		h = radius,
		texture = tweak_data.gui.icons[HUDMapWaypointCircle.RADAR_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDMapWaypointCircle.RADAR_ICON].texture_rect
	}
	self._radar_icon = self._object:bitmap(radar_icon_params)

	self._object:set_rotation(math.random(0, 359))
	self._radar_icon:animate(callback(self, self, "_animate_rotate_radar"))
end

-- Lines 110-114
function HUDMapWaypointCircle:set_data(waypoint_data)
	if not self._object:visible() then
		self._object:set_visible(true)
	end
end

-- Lines 116-161
function HUDMapWaypointCircle:_animate_rotate_radar()
	while true do
		local low_speed = 0.6
		local high_speed = 1.7
		local speedup_duration = 1.2
		local high_speed_sustain_duration = 0.6
		local slowdown_duration = 3
		local low_speed_sustain_duration = 0.4
		local t = 0

		while speedup_duration > t do
			local dt = coroutine.yield()
			t = t + dt
			local current_speed = Easing.quartic_in_out(t, low_speed, high_speed - low_speed, speedup_duration)

			self._object:set_rotation(self._object:rotation() + current_speed)
		end

		t = 0

		while high_speed_sustain_duration > t do
			local dt = coroutine.yield()
			t = t + dt

			self._object:set_rotation(self._object:rotation() + high_speed)
		end

		t = 0

		while slowdown_duration > t do
			local dt = coroutine.yield()
			t = t + dt
			local current_speed = Easing.quintic_in_out(t, high_speed, low_speed - high_speed, slowdown_duration)

			self._object:set_rotation(self._object:rotation() + current_speed)
		end

		t = 0

		while low_speed_sustain_duration > t do
			local dt = coroutine.yield()
			t = t + dt

			self._object:set_rotation(self._object:rotation() + low_speed)
		end
	end
end

-- Lines 163-167
function HUDMapWaypointCircle:destroy()
	self._radar_icon:stop()
	HUDMapWaypointCircle.super.destroy(self)
end

HUDMapWaypointPoint = HUDMapWaypointPoint or class(HUDMapWaypointBase)
HUDMapWaypointPoint.W = 96
HUDMapWaypointPoint.H = 96
HUDMapWaypointPoint.ICON = "map_waypoint_pov_in"
HUDMapWaypointPoint.ICON_LAYER = 3
HUDMapWaypointPoint.ICON_BACKGROUND = "map_waypoint_pov_in"
HUDMapWaypointPoint.ICON_BACKGROUND_LAYER = 1
HUDMapWaypointPoint.DISTANCE_H = 32
HUDMapWaypointPoint.DISTANCE_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDMapWaypointPoint.DISTANCE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDMapWaypointPoint.DISTANCE_LAYER = 2

-- Lines 196-203
function HUDMapWaypointPoint:init(panel, waypoint_data)
	HUDMapWaypointPoint.super.init(self, waypoint_data)
	self:_create_panel(panel)
	self:_create_icon()
	self:_create_background_icon()
	self:_create_distance()
end

-- Lines 206-215
function HUDMapWaypointPoint:_create_panel(panel)
	local panel_params = {
		visible = false,
		halign = "center",
		valign = "center",
		name = "map_waypoint_point_" .. tostring(self._id),
		w = HUDMapWaypointPoint.W,
		h = HUDMapWaypointPoint.H
	}
	self._object = panel:panel(panel_params)
end

-- Lines 217-226
function HUDMapWaypointPoint:_create_icon()
	local icon_params = {
		name = "icon",
		texture = tweak_data.gui.icons[HUDMapWaypointPoint.ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDMapWaypointPoint.ICON].texture_rect
	}
	self._icon = self._object:bitmap(icon_params)

	self._icon:set_center_x(self._object:w() / 2)
	self._icon:set_center_y(self._object:h() / 2)
end

-- Lines 229-240
function HUDMapWaypointPoint:_create_background_icon()
	local background_icon_params = {
		name = "background_icon",
		texture = tweak_data.gui.icons[HUDMapWaypointPoint.ICON_BACKGROUND].texture,
		texture_rect = tweak_data.gui.icons[HUDMapWaypointPoint.ICON_BACKGROUND].texture_rect
	}
	self._background_icon = self._object:bitmap(background_icon_params)

	self._background_icon:set_center_x(self._object:w() / 2)
	self._background_icon:set_center_y(self._object:h() / 2)
	self._background_icon:animate(callback(self, self, "_animate_background_icon"))
end

-- Lines 242-255
function HUDMapWaypointPoint:_create_distance()
	local distance_text_params = {
		vertical = "center",
		name = "distance_text",
		align = "center",
		text = "",
		w = self._object:w(),
		h = HUDMapWaypointPoint.DISTANCE_H,
		font = HUDMapWaypointPoint.DISTANCE_FONT,
		font_size = HUDMapWaypointPoint.DISTANCE_FONT_SIZE,
		layer = HUDMapWaypointPoint.DISTANCE_LAYER
	}
	self._distance = self._object:text(distance_text_params)

	self._distance:set_bottom(self._object:h())
end

-- Lines 257-270
function HUDMapWaypointPoint:set_data(waypoint_data)
	if not managers.player:player_unit() then
		self._distance:set_visible(false)
	end

	self._distance:set_visible(true)
	self._object:set_visible(true)

	local waypoint_distance = Vector3()

	mvector3.set(waypoint_distance, waypoint_data.position)
	mvector3.subtract(waypoint_distance, managers.viewport:get_current_camera_position())
	self._distance:set_text(string.format("%.0f", waypoint_distance:length() / 100) .. "m")
end

-- Lines 272-301
function HUDMapWaypointPoint:_animate_background_icon()
	while true do
		local enhance_factor = 2
		local blink_duration = 2
		local t = 0

		while blink_duration > t do
			local dt = coroutine.yield()
			t = t + dt
			local current_size = Easing.quartic_out(t, 1, 1, blink_duration)

			self._background_icon:set_w(self._icon:w() * current_size)
			self._background_icon:set_h(self._icon:h() * current_size)
			self._background_icon:set_center_x(self._object:w() / 2)
			self._background_icon:set_center_y(self._object:h() / 2)

			local current_alpha = Easing.quartic_out(t, 0.6, -0.6, blink_duration)

			self._background_icon:set_alpha(current_alpha)
		end

		self._background_icon:set_w(self._icon:w())
		self._background_icon:set_h(self._icon:h())
		self._background_icon:set_center_x(self._object:w() / 2)
		self._background_icon:set_center_y(self._object:h() / 2)
		self._background_icon:set_alpha(0)
		wait(0.3)
	end
end

-- Lines 303-307
function HUDMapWaypointPoint:destroy()
	self._background_icon:stop()
	HUDMapWaypointPoint.super.destroy(self)
end

HUDMapWaypointIcon = HUDMapWaypointIcon or class(HUDMapWaypointBase)

-- Lines 319-324
function HUDMapWaypointIcon:init(panel, waypoint_data)
	HUDMapWaypointIcon.super.init(self, waypoint_data)
	self:_create_panel(panel, waypoint_data)
	self:_create_icon(waypoint_data)
end

-- Lines 326-335
function HUDMapWaypointIcon:_create_panel(panel, waypoint_data)
	local icon = waypoint_data.map_icon
	local panel_params = {
		halign = "center",
		valign = "center",
		name = "map_waypoint_icon_" .. tostring(self._id),
		w = tweak_data.gui:icon_w(icon),
		h = tweak_data.gui:icon_h(icon)
	}
	self._object = panel:panel(panel_params)
end

-- Lines 337-345
function HUDMapWaypointIcon:_create_icon(waypoint_data)
	local icon = waypoint_data.map_icon
	local icon_params = {
		name = "icon",
		texture = tweak_data.gui.icons[icon].texture,
		texture_rect = tweak_data.gui.icons[icon].texture_rect
	}
	self._icon = self._object:bitmap(icon_params)
end

-- Lines 347-349
function HUDMapWaypointIcon:set_data(waypoint_data)
	self:set_rotation(-waypoint_data.rotation:yaw())
end

-- Lines 351-353
function HUDMapWaypointIcon:set_rotation(rotation)
	self._icon:set_rotation(rotation)
end
