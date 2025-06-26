GroupAIStateEmpty = GroupAIStateEmpty or class(GroupAIStateBase)

function GroupAIStateEmpty:assign_enemy_to_group_ai(unit)
end

function GroupAIStateEmpty:flee_point(start_nav_seg)
end

function GroupAIStateEmpty:set_area_min_police_force(id, force, pos)
end

function GroupAIStateEmpty:set_wave_mode(flag)
end

function GroupAIStateEmpty:add_preferred_spawn_points(id, spawn_points)
end

function GroupAIStateEmpty:remove_preferred_spawn_points(id)
end

function GroupAIStateEmpty:is_area_safe()
	return true
end

function GroupAIStateEmpty:is_nav_seg_safe()
	return true
end

function GroupAIStateEmpty:on_defend_travel_end(unit, objective)
end

function GroupAIStateEmpty:on_cop_jobless(unit)
end

function GroupAIStateEmpty:on_nav_segment_state_change(changed_seg, state)
end

function GroupAIStateEmpty:register_criminal(criminal_unit)
end

function GroupAIStateEmpty:unregister_criminal(criminal_unit)
end

function GroupAIStateEmpty:on_criminal_recovered(criminal_unit)
end

function GroupAIStateEmpty:on_criminal_disabled(criminal_unit)
end

function GroupAIStateEmpty:on_criminal_neutralized(criminal_unit)
end

function GroupAIStateEmpty:fill_criminal_team()
end

function GroupAIStateEmpty:spawn_one_criminal_ai()
end

function GroupAIStateEmpty:remove_one_criminal_ai()
end

function GroupAIStateEmpty:is_detection_persistent()
	return false
end

function GroupAIStateEmpty:set_importance_weight(cop_unit, dis_report)
end

function GroupAIStateEmpty:add_special_objective(id, objective_data)
end

function GroupAIStateEmpty:remove_special_objective(id)
end

function GroupAIStateEmpty:on_nav_link_unregistered()
end

function GroupAIStateEmpty:save(save_data)
end

function GroupAIStateEmpty:load(load_data)
end
