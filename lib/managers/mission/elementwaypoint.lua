core:import("CoreMissionScriptElement")

ElementWaypoint = ElementWaypoint or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-15
function ElementWaypoint:init(...)
	ElementWaypoint.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/waypoint2" or self._values.icon == "guis/textures/waypoint" then
		self._values.icon = "wp_standard"
	end
end

-- Lines 17-21
function ElementWaypoint:_get_unique_id()
	local uid = self._sync_id .. self._id

	return uid
end

-- Lines 23-25
function ElementWaypoint:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 27-29
function ElementWaypoint:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 31-72
function ElementWaypoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local only_civ_player_is_civ = self._values.only_in_civilian and managers.player:current_state() == "civilian"

	if not only_civ_player_is_civ then
		local text = managers.localization:text(self._values.text_id)
		local wp_data = tweak_data.gui.icons[self._values.icon]
		wp_data = wp_data or tweak_data.gui.icons.wp_standard
		local wp_color = wp_data and wp_data.color or Color(1, 1, 1)

		managers.hud:add_waypoint(self:_get_unique_id(), {
			distance = true,
			state = "sneak_present",
			show_on_screen = true,
			waypoint_type = "objective",
			text = text,
			icon = self._values.icon,
			waypoint_display = self._values.map_display,
			waypoint_color = wp_color,
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

-- Lines 74-76
function ElementWaypoint:operation_remove()
	managers.hud:remove_waypoint(self:_get_unique_id())
end

-- Lines 78-81
function ElementWaypoint:pre_destroy()
	managers.hud:remove_waypoint(self:_get_unique_id())
end
