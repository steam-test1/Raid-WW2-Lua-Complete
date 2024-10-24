CopLogicTrade = class(CopLogicBase)
CopLogicTrade.butchers_traded = 0

function CopLogicTrade.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = nil,
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	data.internal_data = my_data

	data.unit:movement():set_allow_fire(false)
	CopLogicBase._reset_attention(data)

	my_data._trade_enabled = true

	data.unit:network():send("hostage_trade", true, false)
	CopLogicTrade.hostage_trade(data.unit, true, false)
	data.unit:brain():set_update_enabled_state(true)
	managers.groupai:state():on_hostage_state(true, data.key, managers.enemy:all_enemies()[data.key] and true or false)
	data.unit:brain():set_attention_settings({
		peaceful = true
	})
end

function CopLogicTrade.hostage_trade(unit, enable, trade_success)
	local wp_id = "wp_hostage_trade"

	print("[CopLogicTrade.hostage_trade]", unit, enable, trade_success)

	if enable then
		local text = managers.localization:text("debug_trade_hostage")

		managers.hud:add_waypoint(wp_id, {
			distance = nil,
			position = nil,
			text = nil,
			waypoint_type = "hostage_trade",
			icon = "wp_trade",
			text = text,
			position = unit:movement():m_pos(),
			distance = IS_PC
		})

		if managers.network:session() and not managers.trade:is_peer_in_custody(managers.network:session():local_peer():id()) then
			-- Nothing
		end

		if Network:is_server() and managers.enemy:all_civilians()[unit:key()] and unit:anim_data().stand and unit:brain():is_tied() then
			unit:brain():on_hostage_move_interaction(nil, "stay")
		end

		unit:character_damage():set_invulnerable(true)

		if Network:is_server() then
			unit:interaction():set_tweak_data("hostage_trade")
			unit:interaction():set_active(true, true)
		end

		if Network:is_server() and not unit:anim_data().hands_tied and not unit:anim_data().tied then
			local action_data = nil

			if managers.enemy:all_civilians()[unit:key()] then
				if not unit:brain():is_tied() then
					action_data = {
						type = "act",
						blocks = nil,
						clamp_to_graph = true,
						variant = "tied",
						body_part = 1,
						blocks = {
							walk = -1,
							heavy_hurt = -1,
							hurt = -1,
							light_hurt = -1
						}
					}
				end
			else
				action_data = {
					type = "act",
					blocks = nil,
					clamp_to_graph = true,
					variant = "tied_all_in_one",
					body_part = 1,
					blocks = {
						walk = -1,
						heavy_hurt = -1,
						hurt = -1,
						light_hurt = -1
					}
				}
			end

			if action_data then
				unit:brain():action_request(action_data)
			end
		end
	else
		managers.hud:remove_waypoint(wp_id)

		if trade_success then
			unit:interaction():set_active(false, false)
		else
			unit:interaction():set_active(false, false)

			if managers.enemy:all_civilians()[unit:key()] then
				unit:interaction():set_tweak_data("hostage_move")
			else
				unit:interaction():set_tweak_data("intimidate")
			end

			unit:interaction():set_active(false, false)
		end
	end
end

function CopLogicTrade.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	if my_data._trade_enabled then
		my_data._trade_enabled = false

		data.unit:network():send("hostage_trade", false, false)
		CopLogicTrade.hostage_trade(data.unit, false, false)
		managers.groupai:state():on_hostage_state(false, data.key)
	end

	data.unit:character_damage():set_invulnerable(false)
	data.unit:network():send("set_unit_invulnerable", false)
end

function CopLogicTrade.on_trade(data, trading_unit)
	if not data.internal_data._trade_enabled then
		return
	end
end

function CopLogicTrade.update(data)
	local my_data = data.internal_data

	CopLogicTrade._process_pathing_results(data, my_data)

	if my_data.pathing_to_flee_pos then
		-- Nothing
	elseif my_data.flee_path then
		if not data.unit:movement():chk_action_forbidden("walk") and data.unit:anim_data().idle_full_blend then
			data.unit:brain()._current_logic._chk_request_action_walk_to_flee_pos(data, my_data)
		end
	elseif my_data.flee_pos then
		local to_pos = my_data.flee_pos
		my_data.flee_pos = nil
		my_data.pathing_to_flee_pos = true
		my_data.flee_path_search_id = tostring(data.unit:key()) .. "flee"

		data.unit:brain():search_for_path(my_data.flee_path_search_id, to_pos)
	end
end

function CopLogicTrade.on_intimidated(data, amount, aggressor_unit)
end

function CopLogicTrade._process_pathing_results(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		local path = pathing_results[my_data.flee_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.flee_path = path
			else
				data.unit:set_slot(0)
			end

			my_data.pathing_to_flee_pos = nil
			my_data.flee_path_search_id = nil
		end
	end
end

function CopLogicTrade._chk_request_action_walk_to_flee_pos(data, my_data, end_rot)
	local new_action_data = {
		type = "walk",
		nav_path = my_data.flee_path,
		variant = "run",
		body_part = 2
	}
	my_data.flee_path = nil
	my_data.walking_to_flee_pos = data.unit:brain():action_request(new_action_data)
end

function CopLogicTrade.on_action_completed(data, action)
	local my_data = data.internal_data
	local action_type = action:type()

	if action_type == "walk" and my_data.walking_to_flee_pos then
		my_data.walking_to_flee_pos = nil

		data.unit:set_slot(0)
	end
end

function CopLogicTrade.can_activate()
	return false
end

function CopLogicTrade.is_available_for_assignment(data)
	return false
end

function CopLogicTrade.on_new_objective(data, old_objective)
	CopLogicBase.update_follow_unit(data, old_objective)
end

function CopLogicTrade._get_all_paths(data)
	return {
		flee_path = nil,
		flee_path = data.internal_data.flee_path
	}
end

function CopLogicTrade._set_verified_paths(data, verified_paths)
	data.internal_data.flee_path = verified_paths.flee_path
end

function CopLogicTrade.pre_destroy(data)
end
