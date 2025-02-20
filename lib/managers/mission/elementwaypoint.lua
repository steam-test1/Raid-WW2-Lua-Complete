core:import("CoreMissionScriptElement")

ElementWaypoint = ElementWaypoint or class(CoreMissionScriptElement.MissionScriptElement)

function ElementWaypoint:init(...)
	ElementWaypoint.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/waypoint2" or self._values.icon == "guis/textures/waypoint" then
		self._values.icon = "wp_standard"
	end
end

function ElementWaypoint:_get_unique_id()
	local uid = self._sync_id .. self._id

	return uid
end

function ElementWaypoint:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementWaypoint:client_on_executed(...)
	self:on_executed(...)
end

function ElementWaypoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	Application:debug("[ElementWaypoint] self._values.icon", inspect(self._values))

	local text = managers.localization:text(self._values.text_id)
	local map_icon = self._values.map_display == "icon" and self._values.icon or nil
	local wp_data = tweak_data.gui.icons[self._values.icon] or tweak_data.gui.icons.wp_standard
	local wp_color = wp_data and wp_data.color or Color(1, 1, 1)

	managers.hud:add_waypoint(self:_get_unique_id(), {
		waypoint_type = "objective",
		state = "sneak_present",
		distance = true,
		show_on_screen = true,
		text = text,
		icon = self._values.icon,
		waypoint_display = self._values.map_display,
		waypoint_color = wp_color,
		waypoint_width = self._values.width,
		waypoint_depth = self._values.depth,
		waypoint_radius = self._values.radius,
		range_max = self._values.range_max,
		range_min = self._values.range_min,
		map_icon = map_icon,
		position = self._values.position
	})
	ElementWaypoint.super.on_executed(self, instigator)
end

function ElementWaypoint:operation_remove()
	managers.hud:remove_waypoint(self:_get_unique_id())
end

function ElementWaypoint:pre_destroy()
	managers.hud:remove_waypoint(self:_get_unique_id())
end
