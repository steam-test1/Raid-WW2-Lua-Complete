HUDMapBase = HUDMapBase or class()

-- Lines 3-5
function HUDMapBase:init(params)
	self._name = params.name or self:_get_fallback_name()
end

-- Lines 7-9
function HUDMapBase:show()
	managers.hud:add_updator(self._name, callback(self, self, "update"))
end

-- Lines 11-13
function HUDMapBase:hide()
	managers.hud:remove_updator(self._name)
end

-- Lines 15-16
function HUDMapBase:update()
end

-- Lines 18-20
function HUDMapBase:set_x(x)
	self._object:set_x(x)
end

-- Lines 22-24
function HUDMapBase:set_y(y)
	self._object:set_y(y)
end

-- Lines 26-28
function HUDMapBase:w()
	return self._object:w()
end

-- Lines 30-32
function HUDMapBase:h()
	return self._object:h()
end

-- Lines 34-36
function HUDMapBase:_get_fallback_name()
	return "map_" .. string.format("%05d", math.random(99999))
end

-- Lines 38-46
function HUDMapBase:_current_level_has_map()
	local player_world = self:_get_current_player_level()

	if player_world and tweak_data.levels[player_world] and tweak_data.levels[player_world].map then
		return true
	end

	return false
end

-- Lines 48-51
function HUDMapBase:_set_level(level)
	self._current_level = level
	self._world_borders = deep_clone(tweak_data.levels[level].map.world_borders)
end

-- Lines 53-76
function HUDMapBase:_get_current_player_level()
	local current_job = managers.raid_job:current_job()

	if not current_job or managers.raid_job:is_camp_loaded() then
		return nil
	end

	if current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		local current_event_id = current_job.events_index[current_job.current_event]
		local current_event = current_job.events[current_event_id]

		return current_event.level_id
	elseif current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
		return current_job.level_id
	end

	return nil
end
