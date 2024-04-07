core:import("CoreMissionScriptElement")

ElementDropPointGroup = ElementDropPointGroup or class(CoreMissionScriptElement.MissionScriptElement)

function ElementDropPointGroup:init(...)
	ElementDropPointGroup.super.init(self, ...)

	self._network_execute = true

	if self._values.icon == "guis/textures/waypoint2" or self._values.icon == "guis/textures/waypoint" then
		self._values.icon = "wp_standard"
	end
end

function ElementDropPointGroup:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementDropPointGroup:client_on_executed(...)
	self:on_executed(...)
end

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

function ElementDropPointGroup:on_executed(instigator)
	do return end

	if not self._values.enabled then
		return
	end

	managers.airdrop:register_drop_point_group(self)
	ElementDropPointGroup.super.on_executed(self, instigator)
end

function ElementDropPointGroup:operation_remove()
	return
end
