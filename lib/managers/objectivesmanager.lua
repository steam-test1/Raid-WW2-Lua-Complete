ObjectivesManager = ObjectivesManager or class()
ObjectivesManager.PATH = "gamedata/objectives"
ObjectivesManager.FILE_EXTENSION = "objective"
ObjectivesManager.FULL_PATH = ObjectivesManager.PATH .. "." .. ObjectivesManager.FILE_EXTENSION
ObjectivesManager.REMINDER_INTERVAL = 240

function ObjectivesManager:init()
	self._objectives = {}
	self._active_objectives = {}
	self._remind_objectives = {}
	self._completed_objectives = {}
	self._completed_objectives_ordered = {}
	self._read_objectives = {}
	self._objectives_level_id = {}

	self:_parse_objectives()
end

function ObjectivesManager:_parse_objectives()
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())

	for _, data in ipairs(list) do
		if data._meta == "objective" then
			self:_parse_objective(data)
		else
			Application:error("Unknown node \"" .. tostring(data._meta) .. "\" in \"" .. self.FULL_PATH .. "\". Expected \"objective\" node.")
		end
	end

	self._parsed_objectives = deep_clone(self._objectives)
end

function ObjectivesManager:on_level_transition()
	self._objectives = deep_clone(self._parsed_objectives)
end

function ObjectivesManager:table_invert(t)
	local s = {}

	for k, v in pairs(t) do
		s[v] = k
	end

	return s
end

function ObjectivesManager:_get_difficulty_amount_from_objective_subobjective(data)
	local current_difficulty_name = Global.game_settings.difficulty
	local difficulty_amount = data.difficulty_amount
	local difficulty_amount_total = 0

	if current_difficulty_name and difficulty_amount then
		local difficulty_amount_table = string.split(difficulty_amount, ",")
		local current_difficulty_id = self:table_invert(tweak_data.difficulties)[current_difficulty_name]
		difficulty_amount_total = tonumber(difficulty_amount_table[current_difficulty_id])
	end

	return difficulty_amount_total
end

function ObjectivesManager:generate_dynamic_objective(data)
	self:_parse_objective(data)
	managers.objectives:remove_and_activate_objective(data.id, nil, {}, 1)
end

function ObjectivesManager:_parse_objective(data)
	local id = data.id
	local text = managers.localization:text(data.text)
	local description = managers.localization:text(data.description)
	local prio = data.prio
	local amount = data.amount
	local amount_text = data.amount_text and managers.localization:text(data.amount_text)
	local level_id = data.level_id
	local sub_objectives = {}

	if data.difficulty_amount then
		amount = self:_get_difficulty_amount_from_objective_subobjective(data)
	end

	self._objectives[id] = {
		text = text,
		description = description,
		prio = prio,
		id = id,
		amount = amount,
		current_amount = amount and 0 or nil,
		amount_text = amount_text,
		sub_objectives = {},
		level_id = level_id
	}

	for _, sub in ipairs(data) do
		local sub_text = managers.localization:text(sub.text)
		local sub_description = nil

		if sub.description then
			sub_description = managers.localization:text(sub.description)
		end

		self._objectives[id].sub_objectives[sub.id] = {
			id = sub.id,
			text = sub_text,
			description = sub_description,
			start_completed = sub.start_completed
		}

		if sub.difficulty_amount then
			self._objectives[id].sub_objectives[sub.id].amount = self:_get_difficulty_amount_from_objective_subobjective(sub)
			self._objectives[id].sub_objectives[sub.id].current_amount = 0
		end
	end

	if level_id then
		self._objectives_level_id[level_id] = self._objectives_level_id[level_id] or {}
	end
end

function ObjectivesManager:update(t, dt)
	for id, data in pairs(self._remind_objectives) do
		if data.next_t < t then
			self:_remind_objetive(id)
		end
	end

	if self._delayed_presentation then
		self._delayed_presentation.t = self._delayed_presentation.t - dt

		if self._delayed_presentation.t <= 0 then
			managers.hud:activate_objective(self._delayed_presentation.activate_params)

			if self._delayed_presentation.mid_text_params then
				managers.hud:present_mid_text(self._delayed_presentation.mid_text_params)
			end

			self._delayed_presentation = nil
		end
	end
end

function ObjectivesManager:_remind_objetive(id, title_id)
	if not Application:editor() and managers.platform:presence() ~= "Playing" then
		return
	end

	if self._remind_objectives[id] then
		self._remind_objectives[id].next_t = Application:time() + self.REMINDER_INTERVAL
	end

	if managers.user:get_setting("objective_reminder") then
		local objective = self._objectives[id]

		if not objective then
			return
		end

		title_id = title_id or "hud_objective_reminder"
		local title_message = managers.localization:text(title_id)
		local text = objective.text

		managers.hud:remind_objective(id)
		managers.hud:present_mid_text({
			active = nil,
			time = 4,
			text = text,
			title = title_message
		})
	end
end

function ObjectivesManager:_remind_sub_objective(id, title_id)
	managers.hud:remind_sub_objective(id)
end

function ObjectivesManager:update_objective(id, load_data)
	self:activate_objective(id, load_data, {
		title_message = managers.localization:text("mission_objective_updated")
	})
end

function ObjectivesManager:complete_and_activate_objective(id, load_data, data, world_id)
	local delay_presentation = next(self._active_objectives) and true or nil

	for name, data in pairs(clone(self._active_objectives)) do
		self:complete_objective(name)
	end

	data = data or {}
	data.delay_presentation = delay_presentation or nil

	self:activate_objective(id, nil, data, world_id)
end

function ObjectivesManager:remove_and_activate_objective(id, load_data, data, world_id)
	local delay_presentation = next(self._active_objectives) and true or nil

	for name, data in pairs(clone(self._active_objectives)) do
		self:remove_objective(name)
	end

	data = data or {}
	data.delay_presentation = delay_presentation or nil

	self:activate_objective(id, nil, data, world_id)
end

function ObjectivesManager:activate_objective(id, load_data, data, world_id, skip_toast)
	if not id or not self._objectives[id] then
		Application:stack_dump_error("Bad id to activate objective, " .. tostring(id) .. ".")

		return
	end

	local objective = self._objectives[id]

	for k, sub_objective in pairs(objective.sub_objectives) do
		sub_objective.completed = false

		if sub_objective.amount and sub_objective.amount == sub_objective.current_amount or sub_objective.start_completed then
			self:check_and_set_subobjective_finished(objective, sub_objective)

			sub_objective.start_completed = true
		end
	end

	objective.completed = false
	objective.current_amount = objective.current_amount or load_data and load_data.current_amount or data and data.amount and 0 or 0
	objective.amount = load_data and load_data.amount or data and data.amount or objective.amount
	objective.world_id = world_id
	local activate_params = {
		id = id,
		text = objective.text,
		sub_objectives = objective.sub_objectives,
		amount = objective.amount,
		current_amount = objective.current_amount,
		amount_text = objective.amount_text
	}
	self._delayed_presentation = nil

	if data and data.delay_presentation then
		self._delayed_presentation = {
			t = 1,
			activate_params = activate_params
		}
	else
		managers.hud:activate_objective(activate_params)
	end

	local title_message = data and data.title_message or managers.localization:text("mission_objective_activated")
	local text = objective.text

	if not skip_toast then
		managers.hud:present_mid_text({
			state = nil,
			time = 4.5,
			text = text,
			title = title_message
		})
	end

	self._active_objectives[id] = objective
	self._remind_objectives[id] = {
		next_t = Application:time() + self.REMINDER_INTERVAL,
		objective = objective
	}
end

function ObjectivesManager:remove_objective(id, load_data)
	if not load_data then
		if not id or not self._objectives[id] then
			Application:stack_dump_error("Bad id to remove objective, " .. tostring(id) .. ".")

			return
		end

		if not self._active_objectives[id] then
			return
		end
	end

	local objective = self._objectives[id]

	managers.hud:complete_objective({
		remove = true,
		id = id,
		text = objective.text
	})

	self._active_objectives[id] = nil
	self._remind_objectives[id] = nil

	if self._delayed_presentation and self._delayed_presentation.activate_params.id == id then
		self._delayed_presentation = nil
	end
end

function ObjectivesManager:remove_objective_for_world(world_id)
	for id, objective in pairs(self._active_objectives) do
		if objective.world_id == world_id then
			managers.hud:complete_objective({
				remove = true,
				id = id,
				text = objective.text
			})

			self._active_objectives[id] = nil

			if self._delayed_presentation and self._delayed_presentation.activate_params.id == id then
				self._delayed_presentation = nil
			end
		end
	end

	for id, data in pairs(self._remind_objectives) do
		if data.objective.world_id == world_id then
			self._remind_objectives[id] = nil
		end
	end

	managers.hud:clear_objectives()
end

function ObjectivesManager:complete_objective(id, load_data)
	if not load_data then
		if not id or not self._objectives[id] then
			Application:stack_dump_error("Bad id to complete objective, " .. tostring(id) .. ".")

			return
		end

		if not self._active_objectives[id] then
			if not self._completed_objectives[id] then
				self._completed_objectives[id] = self._objectives[id]

				table.insert(self._completed_objectives_ordered, 1, id)
			end

			Application:warn("Tried to complete objective " .. tostring(id) .. ". This objective has never been given to the player.")

			return
		end
	end

	local objective = self._objectives[id]

	if objective.amount then
		objective.current_amount = objective.current_amount + 1

		managers.hud:update_amount_objective({
			id = id,
			text = objective.text,
			amount_text = objective.amount_text,
			amount = objective.amount,
			current_amount = objective.current_amount
		})

		if objective.current_amount < objective.amount then
			return
		end

		objective.current_amount = 0
	end

	managers.hud:complete_objective({
		id = id,
		text = objective.text
	})
	managers.statistics:objective_completed()

	self._completed_objectives[id] = objective

	table.insert(self._completed_objectives_ordered, 1, id)

	self._active_objectives[id] = nil
	self._remind_objectives[id] = nil

	if self._delayed_presentation and self._delayed_presentation.activate_params.id == id then
		self._delayed_presentation = nil
	end
end

function ObjectivesManager:complete_sub_objective(id, sub_id, load_data)
	local objective = self._objectives[id]

	if not objective then
		Application:warn("[ObjectivesManager:complete_sub_objective] No objectives for", id, inspect(self._objectives))

		return
	end

	local sub_objective = objective.sub_objectives[sub_id]

	if not sub_objective then
		Application:error("No sub objective " .. tostring(sub_id) .. ". For objective " .. tostring(id) .. "")

		return
	end

	if sub_objective.completed then
		Application:error("Sub objective " .. tostring(sub_id) .. " " .. tostring(sub_objective.text) .. " " .. " already completed v1 ")

		return
	end

	if sub_objective.amount then
		if sub_objective.amount <= sub_objective.current_amount then
			Application:error("Sub objective " .. tostring(sub_id) .. " " .. tostring(sub_objective.text) .. " " .. " already completed v2 ")

			return
		end

		sub_objective.current_amount = sub_objective.current_amount + 1

		managers.hud:update_amount_sub_objective({
			id = id,
			sub_id = sub_id,
			text = sub_objective.text,
			amount_text = sub_objective.amount_text,
			amount = sub_objective.amount,
			current_amount = sub_objective.current_amount
		})

		if self._remind_objectives[id] then
			self._remind_objectives[id].next_t = Application:time() + self.REMINDER_INTERVAL
		end

		if sub_objective.current_amount < sub_objective.amount then
			self:_remind_sub_objective(id, "mission_sub_objective_updated")

			return
		end
	end

	self:check_and_set_subobjective_finished(objective, sub_objective)
end

function ObjectivesManager:check_and_set_subobjective_finished(objective, sub_objective)
	sub_objective.completed = true

	managers.hud:complete_sub_objective({
		text = sub_objective.text,
		sub_id = sub_objective.id
	})

	local completed = true

	for _, sub_objective in pairs(objective.sub_objectives) do
		if not sub_objective.completed then
			completed = false

			break
		end
	end

	if completed then
		managers.queued_tasks:queue("complete_objective", self.complete_objective, self, objective.id, 2, nil)
	end
end

function ObjectivesManager:set_objective_current_amount(objective_id, current_amount)
	local objective = self._objectives[objective_id]

	if not objective then
		Application:error("[ObjectivesManager:set_objective_current_amount] Tried to set an amount of an objective that doesnt exist!", objective_id)

		return
	end

	if objective.amount then
		objective.current_amount = current_amount

		if self._remind_objectives[objective_id] then
			self._remind_objectives[objective_id].next_t = Application:time() + self.REMINDER_INTERVAL
		end
	end
end

function ObjectivesManager:set_sub_objective_amount(objective_id, sub_id, amount)
	local objective = self._objectives[objective_id]

	if not objective then
		Application:error("[ObjectivesManager:set_sub_objective_amount] Tried to set an amount of an objective that doesnt exist!", objective_id)

		return
	end

	local sub_objective = objective.sub_objectives[sub_id]

	if not sub_objective then
		Application:error("No sub objective " .. tostring(sub_id) .. ". For objective " .. tostring(objective_id) .. "")

		return
	end

	sub_objective.amount = amount or 0

	if not sub_objective.current_amount then
		sub_objective.current_amount = 0
	end

	managers.hud:render_objective()
end

function ObjectivesManager:set_sub_objective_current_amount(objective_id, sub_id, current_amount)
	local objective = self._objectives[objective_id]

	if not objective then
		Application:error("[ObjectivesManager:set_sub_objective_current_amount] Tried to set an amount of an objective that doesnt exist!", objective_id)

		return
	end

	local sub_objective = objective.sub_objectives[sub_id]

	if not sub_objective then
		Application:error("No sub objective " .. tostring(sub_id) .. ". For objective " .. tostring(objective_id) .. "")

		return
	end

	if not sub_objective.amount then
		sub_objective.amount = 0
	end

	sub_objective.current_amount = current_amount or 0

	if sub_objective.amount and sub_objective.amount == sub_objective.current_amount then
		self:check_and_set_subobjective_finished(objective, sub_objective)
	end

	if self._remind_objectives[objective_id] then
		self._remind_objectives[objective_id].next_t = Application:time() + self.REMINDER_INTERVAL
	end

	managers.hud:render_objective()
end

function ObjectivesManager:objective_is_active(id)
	return self._active_objectives[id]
end

function ObjectivesManager:objective_is_completed(id)
	return self._completed_objectives[id]
end

function ObjectivesManager:get_objective(id)
	return self._objectives[id]
end

function ObjectivesManager:get_all_objectives()
	local res = {}

	mix(res, self._active_objectives, self._completed_objectives)

	return res
end

function ObjectivesManager:get_active_objectives()
	return self._active_objectives
end

function ObjectivesManager:get_completed_objectives()
	return self._completed_objectives
end

function ObjectivesManager:get_completed_objectives_ordered()
	return self._completed_objectives_ordered
end

function ObjectivesManager:objectives_by_name()
	local t = {}
	local level_id = managers.editor:layer("Level Settings"):get_setting("simulation_level_id")

	Application:info("[ObjectivesManager:objectives_by_name] level_id", level_id)

	if level_id then
		for name, data in pairs(self._objectives) do
			if data.level_id and data.level_id == level_id then
				table.insert(t, name)
			end
		end
	else
		for name, _ in pairs(self._objectives) do
			table.insert(t, name)
		end
	end

	return t
end

function ObjectivesManager:sub_objectives_by_name(id)
	local t = {}
	local objective = self._objectives[id]

	if objective then
		for name, _ in pairs(objective.sub_objectives) do
			table.insert(t, name)
		end
	end

	table.sort(t)

	return t
end

function ObjectivesManager:save(data)
	local state = {}
	local objective_map = {}
	state.completed_objectives_ordered = self._completed_objectives_ordered

	for name, objective in pairs(self._objectives) do
		local save_data = {}
		local sub_objectives = objective.sub_objectives

		if (next(objective.sub_objectives) or objective.current_amount and objective.current_amount > 0) and not self._active_objectives[name] then
			save_data.active = false
			save_data.world_id = self.world_id
			save_data.current_amount = objective.current_amount
			save_data.amount = objective.amount
			save_data.sub_objective = {}

			for sub_id, sub_objective in pairs(objective.sub_objectives) do
				save_data.sub_objective[sub_id] = sub_objective
			end
		elseif self._active_objectives[name] then
			save_data.active = true
			save_data.world_id = self.world_id
			save_data.current_amount = self._active_objectives[name].current_amount
			save_data.amount = self._active_objectives[name].amount
			save_data.sub_objective = {}

			for sub_id, sub_objective in pairs(self._active_objectives[name].sub_objectives) do
				save_data.sub_objective[sub_id] = sub_objective
			end
		end

		if self._completed_objectives[name] then
			save_data.complete = true
		end

		if self._read_objectives[name] then
			save_data.read = true
		end

		if next(save_data) then
			objective_map[name] = save_data
		end
	end

	state.objective_map = objective_map
	data.ObjectivesManager = state

	return true
end

function ObjectivesManager:load(data)
	local state = data.ObjectivesManager

	if state then
		self._completed_objectives_ordered = state.completed_objectives_ordered

		for name, save_data in pairs(state.objective_map) do
			local objective_data = self._objectives[name]

			if save_data and not objective_data then
				Application:error("[ObjectivesManager:load]", name, save_data.id)

				objective_data = save_data
			end

			objective_data.world_id = save_data.world_id
			objective_data.current_amount = save_data.current_amount
			objective_data.amount = save_data.amount
			save_data.sub_objective = save_data.sub_objective or {}

			for sub_id, sub_objective in pairs(save_data.sub_objective) do
				if sub_objective.amount then
					self:set_sub_objective_amount(objective_data.id, sub_id, sub_objective.amount)
				end

				if sub_objective.current_amount then
					self:set_sub_objective_current_amount(objective_data.id, sub_id, sub_objective.current_amount)
				end
			end

			if save_data.active then
				self:activate_objective(name, {
					current_amount = save_data.current_amount,
					amount = save_data.amount
				}, nil, objective_data.world_id, true)
				managers.hud:show_objectives()

				for sub_id, sub_objective in pairs(save_data.sub_objective) do
					if sub_objective.completed then
						objective_data.sub_objectives[sub_id].completed = true

						managers.hud:complete_sub_objective({
							text = sub_objective.text,
							sub_id = sub_id
						})
					end
				end
			end

			if save_data.complete then
				self._completed_objectives[name] = objective_data
			end

			if save_data.read then
				self._read_objectives[name] = true
			end
		end
	end
end

function ObjectivesManager:reset()
	self._active_objectives = {}
	self._completed_objectives = {}
	self._completed_objectives_ordered = {}
	self._read_objectives = {}
	self._remind_objectives = {}

	self:_parse_objectives()
end

function ObjectivesManager:on_mission_start_callback()
	self:reset()

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_objectives_manager_mission_start")
	end
end

function ObjectivesManager:set_read(id, is_read)
	self._read_objectives[id] = is_read
end

function ObjectivesManager:is_read(id)
	return self._read_objectives[id]
end
