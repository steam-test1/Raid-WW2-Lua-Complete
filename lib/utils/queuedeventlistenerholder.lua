QueuedEventListenerHolder = QueuedEventListenerHolder or class(EventListenerHolder)

function QueuedEventListenerHolder:init()
	self._queue = {}
end

function QueuedEventListenerHolder:add(key, event_types, clbk)
	QueuedEventListenerHolder.super.add(self, key, event_types, clbk)

	for _, event in ipairs(event_types) do
		self._queue[event] = self._queue[event] or {}

		if not table.contains(self._queue[event], key) then
			table.insert(self._queue[event], key)
		end
	end
end

function QueuedEventListenerHolder:remove(key)
	QueuedEventListenerHolder.super.remove(self, key)

	for _, event in ipairs(self._queue) do
		local index

		for i, value in ipairs(self._queue[event]) do
			if key == value then
				index = i
			end
		end

		if index then
			table.remove(self._queue[event], index)
		end
	end
end

function QueuedEventListenerHolder:call(event, ...)
	if self._queue[event] then
		for _, queue_key in ipairs(self._queue[event]) do
			if self._listeners and self._listeners[event] then
				local event_listeners = self._listeners[event]

				for key, clbk in pairs(event_listeners) do
					if queue_key == key and self:_not_trash(key) then
						clbk(...)
					end
				end
			end
		end
	end
end
