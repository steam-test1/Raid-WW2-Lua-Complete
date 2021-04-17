GroupAIStateZone = GroupAIStateZone or class(GroupAIStateRaid)
GroupAIStateZone.MAX_DISTANCE_TO_PLAYER = 64000000

-- Lines 4-6
function GroupAIStateZone:init()
	GroupAIStateZone.super.init(self)
end

-- Lines 8-10
function GroupAIStateZone:nav_ready_listener_key()
	return "GroupAIStateZone"
end

-- Lines 12-32
function GroupAIStateZone:_upd_assault_spawning(task_data, primary_target_area)
	GroupAIStateZone.super._upd_assault_spawning(self, task_data, primary_target_area)

	for group_id, group in pairs(self._groups) do
		if group.has_spawned and group.objective.type ~= "retire" then
			local closest_dis_sq = nil

			for u_key, u_data in pairs(self:all_player_criminals()) do
				local my_dis_sq = mvector3.distance_sq(u_data.m_pos, group.objective.area.pos)

				if not closest_dis_sq or my_dis_sq < closest_dis_sq then
					closest_dis_sq = my_dis_sq
				end
			end

			if closest_dis_sq and GroupAIStateZone.MAX_DISTANCE_TO_PLAYER < closest_dis_sq then
				self:_assign_group_to_retire(group)
			end
		end
	end
end
