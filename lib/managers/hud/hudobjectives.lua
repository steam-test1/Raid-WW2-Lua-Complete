HUDObjectives = HUDObjectives or class()
HUDObjectives.W = 672
HUDObjectives.H = 366
HUDObjectives.OBJECTIVES_PADDING = 16
HUDObjectives.OBJECTIVE_DESCRIPTION_PADDING = 10

-- Lines 10-14
function HUDObjectives:init(panel)
	self:_create_panel(panel)
	self:_clear_objectives()
end

-- Lines 16-24
function HUDObjectives:_create_panel(panel)
	local panel_params = {
		name = "objectives",
		halign = "right",
		valign = "top",
		w = HUDObjectives.W,
		h = HUDObjectives.H
	}
	self._object = panel:panel(panel_params)
end

-- Lines 26-28
function HUDObjectives:set_x(x)
	self._object:set_x(x)
end

-- Lines 30-32
function HUDObjectives:set_y(y)
	self._object:set_y(y)
end

-- Lines 34-36
function HUDObjectives:w()
	return self._object:w()
end

-- Lines 38-40
function HUDObjectives:h()
	return self._object:h()
end

-- Lines 42-46
function HUDObjectives:show()
	self:_animate_show()
end

-- Lines 48-52
function HUDObjectives:hide()
end

-- Lines 54-101
function HUDObjectives:render_objective()
	local active_objective = managers.objectives:get_objective(self._active_objective_id)

	if not active_objective then
		Application:error("No active objective")

		return
	end

	self:_clear_objectives()

	self._main_objective = HUDObjectiveMain:new(self._object, active_objective)
	local y = self._main_objective:y() + self._main_objective:h()

	if self._show_objective_descriptions and active_objective.description then
		y = y + HUDObjectives.OBJECTIVE_DESCRIPTION_PADDING
		self._main_objective_description = HUDObjectiveDescription:new(self._object, active_objective)

		self._main_objective_description:set_x(self._object:w() - self._main_objective_description:w())
		self._main_objective_description:set_y(y)

		y = y + self._main_objective_description:h() + HUDObjectives.OBJECTIVE_DESCRIPTION_PADDING
	end

	if active_objective.sub_objectives then
		local y = y + HUDObjectives.OBJECTIVES_PADDING

		for index, sub_objective in pairs(active_objective.sub_objectives) do
			local single_sub_objective = HUDObjectiveSub:new(self._object, sub_objective)

			single_sub_objective:set_y(y)
			table.insert(self._sub_objectives, single_sub_objective)

			y = y + single_sub_objective:h()

			if self._show_objective_descriptions and sub_objective.description then
				y = y + HUDObjectives.OBJECTIVE_DESCRIPTION_PADDING
				local sub_objective_description = HUDObjectiveDescription:new(self._object, sub_objective)

				sub_objective_description:set_x(self._object:w() - sub_objective_description:w())
				sub_objective_description:set_y(y)
				table.insert(self._objective_descriptions, sub_objective_description)

				y = y + sub_objective_description:h() + HUDObjectives.OBJECTIVE_DESCRIPTION_PADDING
			end

			y = y + HUDObjectives.OBJECTIVES_PADDING
		end
	end
end

-- Lines 103-104
function HUDObjectives:update_objectives()
end

-- Lines 106-110
function HUDObjectives:activate_objective(data)
	self._active_objective_id = data.id

	self:render_objective()
end

-- Lines 112-114
function HUDObjectives:remind_objective(id)
	self:_animate_hide()
end

-- Lines 116-117
function HUDObjectives:remind_sub_objective(id)
end

-- Lines 119-121
function HUDObjectives:complete_objective(data)
	self:_animate_hide()
end

-- Lines 123-129
function HUDObjectives:complete_sub_objective(data)
	for i = 1, #self._sub_objectives do
		if self._sub_objectives[i]:id() == data.sub_id then
			self._sub_objectives[i]:complete()
		end
	end
end

-- Lines 131-135
function HUDObjectives:update_amount_objective(data)
	if self._main_objective:id() == data.id then
		self._main_objective:set_current_amount(data.current_amount)
	end
end

-- Lines 137-143
function HUDObjectives:update_amount_sub_objective(data)
	for i = 1, #self._sub_objectives do
		if self._sub_objectives[i]:id() == data.sub_id then
			self._sub_objectives[i]:set_current_amount(data.current_amount)
		end
	end
end

-- Lines 145-146
function HUDObjectives:open_right_done(uses_amount)
end

-- Lines 148-150
function HUDObjectives:show_timer()
	self._main_objective:show_timer()
end

-- Lines 152-154
function HUDObjectives:hide_timer()
	self._main_objective:hide_timer()
end

-- Lines 156-158
function HUDObjectives:set_timer_value(current, total)
	self._main_objective:set_timer_value(current, total)
end

-- Lines 160-167
function HUDObjectives:_clear_objectives()
	self._object:clear()

	self._main_objective = nil
	self._main_objective_description = nil
	self._sub_objectives = {}
	self._objective_descriptions = {}
end

-- Lines 169-175
function HUDObjectives:clean_up()
	self._active_objective_id = nil

	if managers.queued_tasks:has_task("[HUDObjectives:render_objective]") then
		managers.queued_tasks:unqueue("[HUDObjectives:render_objective]")
	end
end

-- Lines 177-200
function HUDObjectives:_animate_show()
	local delay = 0
	local delay_step = 0.1

	if self._main_objective then
		self._main_objective:animate_show(delay)

		if self._main_objective_description then
			self._main_objective_description:animate_show(delay)
		end

		delay = delay + delay_step
	end

	for index, sub_objective in pairs(self._sub_objectives) do
		sub_objective:animate_show(delay)

		if self._objective_descriptions[index] then
			self._objective_descriptions[index]:animate_show(delay)
		end

		delay = delay + delay_step
	end
end

-- Lines 202-223
function HUDObjectives:_animate_hide()
	local delay = 0
	local delay_step = 0.1

	for i = #self._sub_objectives, 1, -1 do
		self._sub_objectives[i]:animate_hide(delay)

		if self._objective_descriptions[i] then
			self._objective_descriptions[i]:animate_hide(delay)
		end

		delay = delay + delay_step
	end

	if self._main_objective then
		self._main_objective:animate_hide(delay)
	end

	if self._main_objective_description then
		self._main_objective_description:animate_hide(delay)
	end
end
