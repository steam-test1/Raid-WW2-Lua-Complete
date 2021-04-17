core:import("CoreMissionScriptElement")

ElementWaypoint = ElementWaypoint or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-12
function ElementWaypoint:init(...)
	ElementWaypoint.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/waypoint2" or self._values.icon == "guis/textures/waypoint" then
		self._values.icon = "wp_standard"
	end
end

-- Lines 14-18
function ElementWaypoint:_get_unique_id()
	local uid = self._sync_id .. self._id

	return uid
end

-- Lines 20-22
function ElementWaypoint:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 24-26
function ElementWaypoint:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 28-40
function ElementWaypoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self._values.only_in_civilian or managers.player:current_state() == "civilian" then
		local text = managers.localization:text(self._values.text_id)

		managers.hud:add_waypoint(self:_get_unique_id(), {
			distance = true,
			state = "sneak_present",
			present_timer = 0,
			show_on_screen = true,
			waypoint_type = "objective",
			text = text,
			icon = self._values.icon,
			waypoint_display = self._values.map_display,
			waypoint_color = self._values.color and Color(self._values.color.r, self._values.color.g, self._values.color.b) or Color(1, 0, 0.64),
			waypoint_width = self._values.width,
			waypoint_depth = self._values.depth,
			waypoint_radius = self._values.radius,
			position = self._values.position
		})
	elseif managers.hud:get_waypoint_data(self:_get_unique_id()) then
		managers.hud:remove_waypoint(self:_get_unique_id())
	end

	ElementWaypoint.super.on_executed(self, instigator)
end

-- Lines 42-44
function ElementWaypoint:operation_remove()
	managers.hud:remove_waypoint(self:_get_unique_id())
end

-- Lines 46-49
function ElementWaypoint:pre_destroy()
	managers.hud:remove_waypoint(self:_get_unique_id())
end
