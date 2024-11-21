core:import("CoreMissionScriptElement")

ElementEscort = ElementEscort or class(CoreMissionScriptElement.MissionScriptElement)

function ElementEscort:_get_next_point(mission, next_points)
	local valid_next_elements = {}

	for _, next_point in ipairs(next_points) do
		local next_element = mission:get_element_by_id(next_point)

		if next_element and next_element:enabled() and next_element:can_be_used() then
			table.insert(valid_next_elements, next_element)
		end
	end

	return table.random(valid_next_elements)
end

function ElementEscort:increment_usage()
	if self:value("usage_times") == 0 then
		return
	end

	self._used_times = (self._used_times or 0) + 1
end

function ElementEscort:can_be_used()
	if self:value("usage_times") == 0 then
		return true
	end

	return not self._used_times or self._used_times < self:value("usage_times")
end

function ElementEscort:start_escort_path(unit)
	if alive(unit) and unit:brain() then
		local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission
		local next_element = self:value("next_points") and self:_get_next_point(mission, self:value("next_points"))

		if next_element then
			local points = {
				{
					position = self:value("position")
				}
			}
			local last_element = nil

			while next_element do
				table.insert(points, {
					position = next_element:value("position")
				})
				next_element:increment_usage()

				if next_element:value("break_point") then
					break
				end

				last_element = next_element
				next_element = next_element:value("next_points") and self:_get_next_point(mission, next_element:value("next_points"))
			end

			local break_so = next_element and next_element:value("break_so")

			if break_so == "none" then
				break_so = nil
			end

			unit:brain():set_objective({
				path_style = "coarse",
				type = "escort",
				haste = "walk",
				path_data = {
					points = points
				},
				next_escort_point = next_element or last_element,
				break_so = break_so,
				end_rot = (next_element or last_element) and (next_element or last_element):value("rotation")
			})

			if unit:escort() then
				unit:escort():set_active(true)
			end
		else
			unit:brain():set_objective({
				type = "escort"
			})

			if unit:escort() then
				unit:escort():set_active(false)
			end
		end
	end
end

function ElementEscort:on_executed(instigator)
	if not self:enabled() or Network:is_client() then
		return
	end

	local spawn_elements = self:value("spawn_elements")

	if spawn_elements and #spawn_elements > 0 then
		for _, spawn_id in ipairs(spawn_elements) do
			local spawn_element = self:get_mission_element(spawn_id)

			for _, unit in ipairs(spawn_element:units()) do
				self:start_escort_path(unit)
			end
		end
	else
		self:start_escort_path(instigator)
	end

	ElementEscort.super.on_executed(self, instigator)
end
