QueuedTasksManager = QueuedTasksManager or class()

-- Lines 18-22
function QueuedTasksManager:_set_iterating(val)
end

-- Lines 25-29
function QueuedTasksManager:init()
	setup._t = 0
	self._t = 0
	self._queued_tasks = {}
end

-- Lines 34-53
function QueuedTasksManager:update(t, dt)
	self._t = t
	local tasks = self._queued_tasks
	local i_task = #tasks

	self:_set_iterating(true)

	while i_task > 0 do
		local task = tasks[i_task]

		if task.marked_for_removal then
			table.remove(tasks, i_task)
		elseif not task.execute_time or task.execute_time < t then
			table.remove(tasks, i_task)
			self:_execute_queued_task(task)
		end

		i_task = i_task - 1
	end

	self:_set_iterating(false)
end

-- Lines 56-59
function QueuedTasksManager:queue(id, callback, task_self, data, delay, verification_callback, persistant)
	local task = {
		id = id,
		callback = callback,
		task_self = task_self,
		data = data,
		execute_time = self._t + delay,
		verification_callback = verification_callback,
		persistant = persistant
	}

	table.insert(self._queued_tasks, task)
end

-- Lines 64-89
function QueuedTasksManager:unqueue(id)
	local tasks = self._queued_tasks
	local i_task = #tasks

	while i_task > 0 do
		if tasks[i_task].id == id then
			tasks[i_task].marked_for_removal = true

			return
		end

		i_task = i_task - 1
	end
end

-- Lines 91-115
function QueuedTasksManager:unqueue_all(id, task_self, skip_persistant_tasks)
	local tasks = self._queued_tasks
	local i_task = #tasks

	while i_task > 0 do
		local task = tasks[i_task]
		local matching = true
		matching = matching and (not id or id and task.id == id)
		matching = matching and (not task_self or task_self and task.task_self == task_self)

		if skip_persistant_tasks and task.persistant then
			matching = false
		end

		if matching then
			task.marked_for_removal = true
		end

		i_task = i_task - 1
	end
end

-- Lines 118-126
function QueuedTasksManager:has_task(id)
	for _, task in pairs(self._queued_tasks) do
		if task.id == id then
			return true
		end
	end

	return false
end

-- Lines 130-145
function QueuedTasksManager:when(id)
	local time_remaining = nil
	local tasks = self._queued_tasks
	local i_task = #tasks

	while i_task > 0 do
		if tasks[i_task].id == id and (time_remaining == nil or time_remaining > tasks[i_task].execute_time - self._t) then
			time_remaining = tasks[i_task].execute_time - self._t
		end

		i_task = i_task - 1
	end

	return time_remaining
end

-- Lines 148-159
function QueuedTasksManager:_execute_queued_task(task)
	if task.verification_callback then
		task.verification_callback(task.id)
	end

	if task.task_self.alive and alive(task.task_self) or not task.task_self.alive then
		task.callback(task.task_self, task.data)
	else
		Application:error("[QueuedTasksManager:_execute_queued_task] Tried to execute destroyed task:", task.id)
	end
end

-- Lines 161-163
function QueuedTasksManager:on_simulation_ended()
	self._queued_tasks = {}
end
