CoroutineManager = CoroutineManager or class()

function CoroutineManager:init()
	self._coroutines = {}
end

function CoroutineManager:update(t, dt)
	if self._buffer then
		self:_add()
	end

	for name, entry in pairs(self._coroutines) do
		if not entry.update_t or entry.update_t < t then
			local result, sleep_t = coroutine.resume(entry.thread)
			local status = coroutine.status(entry.thread)

			if status == "dead" then
				print("[CoroutineManager:update] ", name, " has ended")

				self._coroutines[name] = nil
			elseif sleep_t then
				entry.update_t = t + sleep_t
			end
		end
	end
end

function CoroutineManager:add_coroutine(name, func)
	self._buffer = self._buffer or {}

	if not self._coroutines[name] and not self._buffer[name] then
		self._buffer[name] = func
	end
end

function CoroutineManager:remove_coroutine(name)
	if self._coroutines[name] then
		self._coroutines[name] = nil
	elseif self._buffer and self._buffer[name] then
		self._buffer[name] = nil
	end
end

function CoroutineManager:is_running(name)
	if self._coroutines[name] or self._buffer and self._buffer[name] then
		return true
	end

	return false
end

function CoroutineManager:_add()
	for name, func in pairs(self._buffer) do
		local thread = coroutine.create(func)
		self._coroutines[name] = {
			thread = nil,
			thread = thread
		}
	end

	self._buffer = nil
end
