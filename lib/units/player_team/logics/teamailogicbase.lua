require("lib/units/enemies/cop/logics/CopLogicBase")

TeamAILogicBase = TeamAILogicBase or class(CopLogicBase)

-- Lines 5-6
function TeamAILogicBase.on_long_dis_interacted(data, other_unit)
end

-- Lines 10-11
function TeamAILogicBase.on_cop_neutralized(data, cop_key)
end

-- Lines 15-16
function TeamAILogicBase.on_recovered(data, reviving_unit)
end

-- Lines 20-21
function TeamAILogicBase.clbk_heat(data)
end

-- Lines 25-32
function TeamAILogicBase.on_objective_unit_destroyed(data, unit)
	if not data.objective then
		return
	end

	data.objective.destroy_clbk_key = nil
	data.objective.death_clbk_key = nil

	data.objective_failed_clbk(data.unit, data.objective)
end

-- Lines 36-42
function TeamAILogicBase._get_logic_state_from_reaction(data, reaction)
	if not reaction or reaction <= AIAttentionObject.REACT_SCARED then
		return "idle"
	else
		return "assault"
	end
end

-- Lines 46-69
function TeamAILogicBase._set_attention_obj(data, new_att_obj, new_reaction)
	local old_att_obj = data.attention_obj
	data.attention_obj = new_att_obj

	if new_att_obj then
		new_att_obj.reaction = new_reaction or new_att_obj.settings.reaction
	end

	if old_att_obj and new_att_obj and old_att_obj.u_key == new_att_obj.u_key then
		if new_att_obj.stare_expire_t and new_att_obj.stare_expire_t < data.t then
			if new_att_obj.settings.pause then
				new_att_obj.stare_expire_t = nil
				new_att_obj.pause_expire_t = data.t + math.lerp(new_att_obj.settings.pause[1], new_att_obj.settings.pause[2], math.random())

				print("[TeamAILogicBase._chk_focus_on_attention_object] pausing for", current_attention.pause_expire_t - data.t, "sec")
			end
		elseif new_att_obj.pause_expire_t and new_att_obj.pause_expire_t < data.t then
			new_att_obj.pause_expire_t = nil
			new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
		end
	elseif new_att_obj and new_att_obj.settings.duration then
		new_att_obj.stare_expire_t = data.t + math.lerp(new_att_obj.settings.duration[1], new_att_obj.settings.duration[2], math.random())
		new_att_obj.pause_expire_t = nil
	end
end

-- Lines 73-75
function TeamAILogicBase._chk_nearly_visible_chk_needed(data, attention_info, u_key)
	return not data.attention_obj or data.attention_obj.key == u_key
end

-- Lines 79-93
function TeamAILogicBase._chk_reaction_to_attention_object(data, attention_data, stationary)
	local att_unit = attention_data.unit

	if not attention_data.is_person or att_unit:character_damage() and att_unit:character_damage():dead() then
		return attention_data.settings.reaction
	end

	if data.cool then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_SURPRISED)
	elseif stationary then
		return math.min(attention_data.settings.reaction, AIAttentionObject.REACT_SHOOT)
	else
		return attention_data.settings.reaction
	end
end

-- Lines 97-99
function TeamAILogicBase.on_new_objective(data, old_objective)
	CopLogicBase.update_follow_unit(data, old_objective)
end

-- Lines 103-104
function TeamAILogicBase.on_intimidated(data, amount, aggressor_unit)
end
