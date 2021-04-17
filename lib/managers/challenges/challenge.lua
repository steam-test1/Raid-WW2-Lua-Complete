Challenge = Challenge or class()
Challenge.STATE_INACTIVE = "inactive"
Challenge.STATE_ACTIVE = "active"
Challenge.STATE_COMPLETED = "completed"
Challenge.STATE_FAILED = "failed"

function Challenge.create()
end

function Challenge:init(challenge_category, challenge_id, tasks, completion_callback, challenge_data)
	self._category = challenge_category
	self._id = challenge_id
	self._state = Challenge.STATE_INACTIVE
	self._completion_callback = completion_callback
	self._data = challenge_data
	self._tasks = {}

	for index, task in pairs(tasks) do
		local task = ChallengeTask.create(task.type, challenge_category, challenge_id, task)

		table.insert(self._tasks, task)
	end
end

function Challenge:setup()
	for index, task in pairs(self._tasks) do
		setmetatable(task, ChallengeTask.get_metatable(task._type))
		task:setup()
	end

	self:deactivate()
end

function Challenge:category()
	return self._category
end

function Challenge:id()
	return self._id
end

function Challenge:activate()
	if self._state ~= Challenge.STATE_INACTIVE then
		return
	end

	self._state = Challenge.STATE_ACTIVE

	for id, task in pairs(self._tasks) do
		task:activate()
	end
end

function Challenge:deactivate()
	if self._state ~= Challenge.STATE_ACTIVE then
		return
	end

	self._state = Challenge.STATE_INACTIVE

	for id, task in pairs(self._tasks) do
		task:deactivate()
	end
end

function Challenge:reset()
	if self._state == Challenge.STATE_COMPLETED or self._state == Challenge.STATE_FAILED then
		self._state = Challenge.STATE_INACTIVE
	end

	for id, task in pairs(self._tasks) do
		task:reset()
	end
end

function Challenge:tasks()
	return self._tasks
end

function Challenge:data()
	return self._data
end

function Challenge:completed()
	return self._state == Challenge.STATE_COMPLETED and true or false
end

function Challenge:on_task_completed()
	local challenge_completed = true

	for id, task in pairs(self._tasks) do
		if not task:completed() then
			challenge_completed = false

			return
		end
	end

	self:_on_completed()
end

function Challenge:_on_completed()
	self._state = Challenge.STATE_COMPLETED

	if self._completion_callback then
		local target_string = self._completion_callback.target
		local method = self._completion_callback.method
		local params = self._completion_callback.params
		local target = nil
		local target_parts = string.split(target_string, "[.]")

		for i = 1, #target_parts do
			if target == nil then
				target = _G[target_parts[i]]
			else
				target = target[target_parts[i]]
			end
		end

		if params then
			target[method](target, unpack(params))
		else
			target[method](target)
		end
	end
end

function Challenge:force_complete()
	if self:completed() then
		return
	end

	self._state = Challenge.STATE_COMPLETED

	for id, task in pairs(self._tasks) do
		task:force_complete()
	end
end
