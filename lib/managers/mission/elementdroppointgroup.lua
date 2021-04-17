core:import("CoreMissionScriptElement")

ElementDropPointGroup = ElementDropPointGroup or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-12
function ElementDropPointGroup:init(...)
	ElementDropPointGroup.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/waypoint2" or self._values.icon == "guis/textures/waypoint" then
		self._values.icon = "wp_standard"
	end
end

-- Lines 14-16
function ElementDropPointGroup:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

-- Lines 18-20
function ElementDropPointGroup:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 22-33
function ElementDropPointGroup:get_random_drop_point()
	local eligible_points = {}

	for _, params in ipairs(self._values.on_executed) do
		local element = self:get_mission_element(params.id)

		if element then
			table.insert(eligible_points, element:values().position)
		end
	end

	return eligible_points[math.random(#eligible_points)]
end

-- Lines 35-48
function ElementDropPointGroup:on_executed(instigator)
	return

	if not self._values.enabled then
		return
	end

	managers.airdrop:register_drop_point_group(self)
	ElementDropPointGroup.super.on_executed(self, instigator)
end

-- Lines 50-51
function ElementDropPointGroup:operation_remove()
end
