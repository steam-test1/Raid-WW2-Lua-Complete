core:import("CoreMissionScriptElement")

ElementObjective = ElementObjective or class(CoreMissionScriptElement.MissionScriptElement)

function ElementObjective:init(...)
	ElementObjective.super.init(self, ...)
end

function ElementObjective:on_script_activated()
	self._mission_script:add_save_state_cb(self._id)
end

function ElementObjective:client_on_executed(...)
	self:on_executed(...)
end

function ElementObjective:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local objective = self:value("objective")
	local amount = self:value("amount")
	amount = amount and amount > 0 and amount or nil

	if self._values.elements and #self._values.elements > 0 then
		local element = self:get_mission_element(self._values.elements[1])
		local counter_amount = tonumber(element._values.counter_target)

		if counter_amount > 0 then
			amount = counter_amount
		end
	end

	local worlddef = self._mission_script:worlddefinition()

	if objective ~= "none" then
		if self._values.state == "activate" then
			managers.objectives:activate_objective(objective, nil, {
				amount = amount
			}, worlddef._world_id)
		elseif self._values.state == "complete_and_activate" then
			managers.objectives:complete_and_activate_objective(objective, nil, {
				amount = amount
			}, worlddef._world_id)
		elseif self._values.state == "complete" then
			if self._values.sub_objective and self._values.sub_objective ~= "none" then
				managers.objectives:complete_sub_objective(objective, self._values.sub_objective)
			else
				managers.objectives:complete_objective(objective)
			end
		elseif self._values.state == "update" then
			managers.objectives:update_objective(objective)
		elseif self._values.state == "remove" then
			managers.objectives:remove_objective(objective)
		elseif self._values.state == "remove_and_activate" then
			managers.objectives:remove_and_activate_objective(objective, nil, {
				amount = amount
			}, worlddef._world_id)
		elseif self._values.state == "set_objective_current_amount" then
			managers.objectives:set_objective_current_amount(objective, amount)
		elseif self._values.state == "set_sub_objective_amount" then
			managers.objectives:set_sub_objective_amount(objective, self._values.sub_objective, amount)
		elseif self._values.state == "set_sub_objective_current_amount" then
			managers.objectives:set_sub_objective_current_amount(objective, self._values.sub_objective, amount)
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant operate on objective " .. objective .. " in element " .. self._editor_name .. ".")
	end

	ElementObjective.super.on_executed(self, instigator)
end

function ElementObjective:apply_job_value(amount)
	local type = CoreClass.type_name(amount)

	if type ~= "number" then
		Application:error("[ElementObjective:apply_job_value] " .. self._id .. "(" .. self._editor_name .. ") Can't apply job value of type " .. type)

		return
	end

	self._values.amount = amount
end

function ElementObjective:save(data)
	data.enabled = self._values.enabled
	data.amount = self._values.amount
end

function ElementObjective:load(data)
	self._values.enabled = data.enabled
	self._values.amount = data.amount
end
