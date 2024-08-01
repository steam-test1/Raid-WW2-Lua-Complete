require("lib/managers/group_ai_states/GroupAIStateBase")
require("lib/managers/group_ai_states/GroupAIStateEmpty")
require("lib/managers/group_ai_states/GroupAIStateBesiege")
require("lib/managers/group_ai_states/GroupAIStateRaid")
require("lib/managers/group_ai_states/GroupAIStateStreet")
require("lib/managers/group_ai_states/GroupAIStateZone")

GroupAIManager = GroupAIManager or class()

-- Lines 11-13
function GroupAIManager:init()
	self:set_state("empty")
end

-- Lines 17-21
function GroupAIManager:update(t, dt)
	if managers.navigation:is_streamed_data_ready() then
		self._state:update(t, dt)
	end
end

-- Lines 25-27
function GroupAIManager:paused_update(t, dt)
	self._state:paused_update(t, dt)
end

-- Lines 31-47
function GroupAIManager:set_state(name, world_id)
	if world_id and world_id > 0 then
		self._state:merge_world_data(world_id)
		self:set_current_state(name, world_id)
	else
		if name == "empty" then
			self._state = GroupAIStateEmpty:new()
		elseif name == "street" then
			self._state = GroupAIStateStreet:new()
		elseif name == "besiege" then
			self._state = GroupAIStateBesiege:new()
		elseif name == "raid" then
			self._state = GroupAIStateRaid:new()
		elseif name == "zone" then
			self._state = GroupAIStateZone:new()
		else
			Application:error("[GroupAIManager:set_state] state doesn't exist", name)

			return
		end

		self._state_name = name
	end
end

-- Lines 54-77
function GroupAIManager:set_current_state(name, world_id)
	Application:debug("[GroupAIManager:set_current_state] group state: " .. (name or "nil") .. ", for WorldID:" .. tostring(world_id))

	local new_state = nil

	if name == "empty" then
		new_state = GroupAIStateEmpty
	elseif name == "street" then
		new_state = GroupAIStateStreet
	elseif name == "besiege" then
		new_state = GroupAIStateBesiege
	elseif name == "raid" then
		new_state = GroupAIStateRaid
	elseif name == "zone" then
		new_state = GroupAIStateZone
	else
		Application:error("[GroupAIManager:set_current_state] state doesn't exist", name)

		return
	end

	for k, v in pairs(new_state) do
		if not string.begins(k, "__") and not table.contains({
			"new",
			"super",
			"init"
		}, k) then
			self._state[k] = v
		end
	end

	self._state_name = name

	self._state:_queue_police_upd_task()
end

-- Lines 81-83
function GroupAIManager:unload_nav_data(world_id, all_nav_segs)
	self._state:unload_world_nav_data(world_id, all_nav_segs)
end

-- Lines 87-89
function GroupAIManager:state()
	return self._state
end

-- Lines 93-95
function GroupAIManager:state_name()
	return self._state_name
end

-- Lines 99-101
function GroupAIManager:state_names()
	return {
		"empty",
		"besiege",
		"street",
		"raid",
		"zone"
	}
end

-- Lines 105-107
function GroupAIManager:on_simulation_started()
	self._state:on_simulation_started()
end

-- Lines 111-113
function GroupAIManager:on_simulation_ended()
	self._state:on_simulation_ended()
end

-- Lines 117-119
function GroupAIManager:visualization_enabled()
	return self._state._draw_enabled
end

-- Lines 123-125
function GroupAIManager:get_difficulty_dependent_value(tweak_values)
	return self._state:get_difficulty_dependent_value(tweak_values)
end

-- Lines 129-153
function GroupAIManager:kill_all_AI()
	Application:debug("[GroupAIManager:kill_all_AI()]")

	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		u_data.unit:base():set_slot(u_data.unit, 0)
		managers.enemy:on_enemy_unregistered(u_data.unit)
	end

	for u_key, u_data in pairs(managers.enemy:all_enemies()) do
		u_data.unit:base():set_slot(u_data.unit, 0)
		managers.enemy:on_enemy_unregistered(u_data.unit)
	end

	for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
		if data and alive(data.unit) then
			data.unit:character_damage():clbk_exit_to_dead(true)
		end
	end

	managers.enemy:unqueue_all_tasks()
	managers.enemy:remove_delayed_clbks()

	managers.enemy._enemy_data.nr_units = 0
end

-- Lines 156-162
function GroupAIManager:kill_all_team_ai()
	for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
		if data and alive(data.unit) then
			data.unit:character_damage():force_bleedout()
		end
	end
end
