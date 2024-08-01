CopLogicTurret = class(CopLogicBase)

-- Lines 9-15
function CopLogicTurret.enter(data, new_logic_name, enter_params)
	local my_data = {
		unit = data.unit
	}

	CopLogicBase.enter(data, new_logic_name, enter_params, my_data)

	data.internal_data = my_data

	data.unit:inventory():set_weapon_enabled(false)
end

-- Lines 19-27
function CopLogicTurret.exit(data, new_logic_name, enter_params)
	Application:debug("*** CopLogicTurret.exit")

	local my_data = data.internal_data

	CopLogicBase.cancel_delayed_clbks(my_data)
	CopLogicBase.exit(data, new_logic_name, enter_params)
end

-- Lines 31-33
function CopLogicTurret.is_available_for_assignment(data)
	return false
end

-- Lines 37-40
function CopLogicTurret.on_enemy_weapons_hot(data)
	Application:debug("*** CopLogicTurret.on_enemy_weapons_hot")
end

-- Lines 44-47
function CopLogicTurret._register_attention(data, my_data)
	Application:debug("*** CopLogicTurret._register_attention")
end

-- Lines 51-53
function CopLogicTurret._set_interaction(data, my_data)
	Application:debug("*** CopLogicTurret._set_interaction")
end

-- Lines 57-59
function CopLogicTurret.queued_update(data)
	Application:debug("*** CopLogicTurret.queued_update")
end

-- Lines 63-65
function CopLogicTurret.on_intimidated(data, amount, aggressor_unit)
	Application:debug("*** CopLogicTurret.on_intimidated")
end

-- Lines 69-73
function CopLogicTurret.death_clbk(data, damage_info)
	if data.unit:unit_data().turret_weapon then
		data.unit:unit_data().turret_weapon:on_puppet_death(data, damage_info)
	end
end

-- Lines 77-81
function CopLogicTurret.damage_clbk(data, damage_info)
	if data.unit:unit_data().turret_weapon then
		data.unit:unit_data().turret_weapon:on_puppet_damaged(data, damage_info)
	end
end

-- Lines 85-87
function CopLogicTurret.on_suppressed_state(data)
	Application:debug("*** CopLogicTurret.on_suppressed_state")
end
