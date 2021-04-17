core:module("CoreGameStateMachine")
core:import("CoreInitState")

GameStateMachine = GameStateMachine or class()

-- Lines 12-24
function GameStateMachine:init(start_state)
	self._states = {}
	self._transitions = {}
	local init = CoreInitState._InitState:new(self)
	self._states[init:name()] = init
	self._transitions[init] = self._transitions[init] or {}
	self._transitions[init][start_state] = init.default_transition
	self._current_state = init
	self._queued_transitions = {
		{
			start_state
		}
	}

	self:_do_state_change()
end

-- Lines 26-33
function GameStateMachine:destroy()
	for _, state in pairs(self._states) do
		state:destroy()
	end

	self._states = {}
	self._transitions = {}
end

-- Lines 35-40
function GameStateMachine:add_transition(from, to, trans_func)
	self._states[from:name()] = from
	self._states[to:name()] = to
	self._transitions[from] = self._transitions[from] or {}
	self._transitions[from][to] = trans_func
end

-- Lines 42-44
function GameStateMachine:current_state()
	return self._current_state
end

-- Lines 46-50
function GameStateMachine:can_change_state(state)
	local state_from = self._queued_transitions and self._queued_transitions[#self._queued_transitions][1] or self._current_state
	local valid_transitions = self._transitions[state_from]

	return valid_transitions and valid_transitions[state] ~= nil
end

-- Lines 52-77
function GameStateMachine:change_state(state, params)
	Application:trace("[GameStateMachine][change_state]", tostring(state:name()))
	Application:debug("[GameStateMachine][change_state]", debug.traceback())

	if self._doing_state_change then
		Application:error("[GameStateMachine][change_state] State change during transition!")
		Application:stack_dump()
	end

	local transition_debug_string = string.format("'%s' --> '%s'", tostring(self:last_queued_state_name()), tostring(state:name()))

	Application:info("[GameStateMachine][change_state] Requested state change ", transition_debug_string)

	if self:can_change_state(state) then
		self._queued_transitions = self._queued_transitions or {}

		table.insert(self._queued_transitions, {
			state,
			params
		})
	end
end

-- Lines 79-81
function GameStateMachine:current_state_name()
	return self._current_state:name()
end

-- Lines 83-86
function GameStateMachine:can_change_state_by_name(state_name)
	local state = assert(self._states[state_name], "[GameStateMachine] Name '" .. tostring(state_name) .. "' does not correspond to a valid state.")

	return self:can_change_state(state)
end

-- Lines 88-91
function GameStateMachine:change_state_by_name(state_name, params)
	local state = assert(self._states[state_name], "[GameStateMachine] Name '" .. tostring(state_name) .. "' does not correspond to a valid state.")

	self:change_state(state, params)
end

-- Lines 93-97
function GameStateMachine:update(t, dt)
	if self._current_state.update then
		self._current_state:update(t, dt)
	end
end

-- Lines 99-103
function GameStateMachine:paused_update(t, dt)
	if self._current_state.paused_update then
		self._current_state:paused_update(t, dt)
	end
end

-- Lines 105-109
function GameStateMachine:end_update(t, dt)
	if self._queued_transitions then
		self:_do_state_change()
	end
end

-- Lines 112-143
function GameStateMachine:_do_state_change()
	if not self._queued_transitions then
		return
	end

	self._doing_state_change = true

	for i_transition, transition in ipairs(self._queued_transitions) do
		local new_state = transition[1]
		local params = transition[2]
		local old_state = self._current_state
		local trans_func = self._transitions[old_state][new_state]

		cat_print("game_state_machine", "[GameStateMachine] Executing state change '" .. tostring(old_state:name()) .. "' --> '" .. tostring(new_state:name()) .. "'")

		self._current_state = new_state

		if trans_func then
			trans_func(old_state, new_state, params)
		else
			Application:error("[GameStateMachine]  trying to execute a state change that has not been allowed. From: ", old_state:name(), "  to: ", new_state:name())
		end
	end

	self._queued_transitions = nil
	self._doing_state_change = false

	if Network:is_server() and managers.network and managers.network:session() then
		managers.network:session():chk_server_joinable_state()
	end
end

-- Lines 145-151
function GameStateMachine:last_queued_state_name()
	if self._queued_transitions then
		return self._queued_transitions[#self._queued_transitions][1]:name()
	else
		return self:current_state_name()
	end
end
