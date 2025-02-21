WaypointExt = WaypointExt or class()

function WaypointExt:init(unit)
	self._unit = unit
	WaypointExt.debug_ext = self
	self._is_active = false

	if self._startup_waypoint then
		self:add_waypoint(self._startup_waypoint, self._startup_waypoint_z, nil, nil, nil)
	end
end

function WaypointExt:add_waypoint(icon_name, pos_z_offset, pos_locator, map_icon, show_on_hud)
	self:add_waypoint_external({
		distance = true,
		icon_name = icon_name,
		pos_z_offset = pos_z_offset,
		pos_locator = pos_locator,
		map_icon = map_icon,
		show_on_hud = show_on_hud
	})
end

function WaypointExt:add_waypoint_external(data)
	if self:active() then
		self:remove_waypoint()
	end

	Application:debug("[WaypointExt:add_waypoint_external] data", inspect(data))

	self._icon_name = data.icon_name or "map_waypoint_pov_in"
	self._map_icon = data.map_icon
	self._pos_z_offset = Vector3(0, 0, data.pos_z_offset or 0)
	self._pos_locator = data.pos_locator
	self._show_on_hud = data.show_on_hud
	local rotation = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):rotation() or self._unit:rotation()
	local position = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):position() or self._unit:position()
	position = position + self._pos_z_offset
	self._icon_pos = position
	self._icon_rot = rotation
	self._waypoint_data = {
		waypoint_origin = "waypoint_extension",
		radius = 200,
		no_sync = false,
		waypoint_type = "unit_waypoint",
		icon = self._icon_name,
		map_icon = self._map_icon,
		unit = self._unit,
		position = position,
		rotation = rotation,
		distance = data.distance,
		range_min = data.range_min,
		range_max = data.range_max,
		present_timer = data.present_timer,
		lifetime = data.lifetime,
		color = data.color or Color(1, 1, 1),
		waypoint_color = data.waypoint_color or Color(1, 1, 1),
		show_on_screen = self._show_on_hud or self._show_on_hud == nil and true
	}
	self._icon_id = tostring(self._unit:key())

	managers.hud:add_waypoint(self._icon_id, self._waypoint_data)
	self._unit:set_extension_update_enabled(Idstring("waypoint"), true)

	self._is_active = true
end

function WaypointExt:remove_waypoint()
	if self._icon_id then
		managers.hud:remove_waypoint(self._icon_id)

		self._icon_id = nil
		self._icon_pos = nil
		self._waypoint_data = nil
	end

	self._unit:set_extension_update_enabled(Idstring("waypoint"), false)

	self._is_active = false
end

function WaypointExt:update(t, dt)
	if self._icon_pos then
		local position = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):position() or self._unit:position()
		position = position + self._pos_z_offset

		mvector3.set(self._icon_pos, position)

		local rotation = self._pos_locator and self._unit:get_object(Idstring(self._pos_locator)):rotation() or self._unit:rotation()

		mrotation.set_yaw_pitch_roll(self._icon_rot, rotation:yaw(), rotation:pitch(), rotation:roll())
	end
end

function WaypointExt:save(save_data)
	save_data.Waypoint = {
		active = self:active(),
		icon_name = self._icon_name,
		pos_z_offset = self._pos_z_offset and self._pos_z_offset.z,
		pos_locator = self._pos_locator,
		map_icon = self._map_icon,
		show_on_hud = self._show_on_hud
	}
end

function WaypointExt:load(save_data)
	if save_data.Waypoint then
		if save_data.Waypoint.active and not self._is_active then
			local icon_name = save_data.Waypoint.icon_name
			local pos_z_offset = save_data.Waypoint.pos_z_offset
			local pos_locator = save_data.Waypoint.pos_locator
			local map_icon = save_data.Waypoint.map_icon
			local show_on_hud = save_data.Waypoint.show_on_hud

			self:add_waypoint(icon_name, pos_z_offset, pos_locator, map_icon, show_on_hud)
		elseif not save_data.Waypoint.active and self:active() then
			self:remove_waypoint()
		end
	end
end

function WaypointExt:active()
	return self._is_active
end

function WaypointExt:destroy()
	if self:active() then
		self:remove_waypoint()
	end
end
