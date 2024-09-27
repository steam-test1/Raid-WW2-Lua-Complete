CopLogicTurret = class(CopLogicBase)

function CopLogicTurret.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = nil,
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)

	data.internal_data = my_data

	data.unit:inventory():set_weapon_enabled(false)
end

function CopLogicTurret.exit(data, new_logic_name, enter_params)
	Application:debug("*** CopLogicTurret.exit")

	local my_data = data.internal_data

	CopLogicBase.cancel_delayed_clbks(my_data)
	CopLogicBase.exit(data, new_logic_name, enter_params)
end

function CopLogicTurret.is_available_for_assignment(data)
	return false
end

function CopLogicTurret.on_enemy_weapons_hot(data)
	Application:debug("*** CopLogicTurret.on_enemy_weapons_hot")
end

function CopLogicTurret._register_attention(data, my_data)
	Application:debug("*** CopLogicTurret._register_attention")
end

function CopLogicTurret._set_interaction(data, my_data)
	Application:debug("*** CopLogicTurret._set_interaction")
end

function CopLogicTurret.queued_update(data)
	Application:debug("*** CopLogicTurret.queued_update")
end

function CopLogicTurret.on_intimidated(data, amount, aggressor_unit)
	Application:debug("*** CopLogicTurret.on_intimidated")
end

function CopLogicTurret.death_clbk(data, damage_info)
	if data.unit:unit_data().turret_weapon then
		data.unit:unit_data().turret_weapon:on_puppet_death(data, damage_info)
	end
end

function CopLogicTurret.damage_clbk(data, damage_info)
	if data.unit:unit_data().turret_weapon then
		data.unit:unit_data().turret_weapon:on_puppet_damaged(data, damage_info)
	end
end

function CopLogicTurret.on_suppressed_state(data)
	Application:debug("*** CopLogicTurret.on_suppressed_state")
end
