core:module("CoreSystemEventListenerHolder")

SystemEventListenerHolder = SystemEventListenerHolder or class()

-- Lines 7-13
function SystemEventListenerHolder:add(key, event_types, clbk)
	if self._calling then
		self:_set_new(key, event_types, clbk)
	else
		self:_add(key, event_types, clbk)
	end
end

-- Lines 18-24
function SystemEventListenerHolder:remove(key)
	if self._calling then
		self:_set_trash(key)
	else
		self:_remove(key)
	end
end

-- Lines 28-46
function SystemEventListenerHolder:call(event, ...)
	if self._listeners then
		local event_listeners = self._listeners[event]

		if event_listeners then
			self._calling = true

			for key, clbk in pairs(event_listeners) do
				if self:_not_trash(key) then
					clbk(...)
				end
			end

			self._calling = nil

			self:_append_new_additions()
			self:_dispose_trash()
		end
	end
end

-- Lines 50-68
function SystemEventListenerHolder:_remove(key)
	local listeners = self._listeners

	if not self._listener_keys then
		return
	end

	local listeners_keys = self._listener_keys[key]

	if listeners_keys then
		for _, event in pairs(listeners_keys) do
			listeners[event][key] = nil

			if not next(listeners[event]) then
				listeners[event] = nil
			end
		end

		if next(listeners) then
			self._listener_keys[key] = nil
		else
			self._listeners = nil
			self._listener_keys = nil
		end
	end
end

-- Lines 72-78
function SystemEventListenerHolder:listener_exists(key)
	if self._listener_keys and self._listener_keys[key] then
		return true
	end

	return false
end

-- Lines 82-101
function SystemEventListenerHolder:_add(key, event_types, clbk)
	if self._listener_keys and self._listener_keys[key] then
		_G.debug_pause("[SystemEventListenerHolder:_add] duplicate", key, inspect(event_types), clbk)

		return
	end

	local listeners = self._listeners

	if not listeners then
		self._listeners = {}
		self._listener_keys = {}
		listeners = self._listeners
	end

	for _, event in pairs(event_types) do
		listeners[event] = listeners[event] or {}
		listeners[event][key] = clbk
	end

	self._listener_keys[key] = event_types
end

-- Lines 105-111
function SystemEventListenerHolder:_set_trash(key)
	self._trash = self._trash or {}
	self._trash[key] = true

	if self._additions then
		self._additions[key] = nil
	end
end

-- Lines 115-125
function SystemEventListenerHolder:_set_new(key, event_types, clbk)
	if self._additions and self._additions[key] then
		_G.debug_pause("[SystemEventListenerHolder:_set_new] duplicate", key, inspect(event_types), clbk)

		return
	end

	self._additions = self._additions or {}
	self._additions[key] = {
		clbk,
		event_types
	}

	if self._trash then
		self._trash[key] = nil
	end
end

-- Lines 129-146
function SystemEventListenerHolder:_append_new_additions()
	if self._additions then
		local listeners = self._listeners

		if not listeners then
			self._listeners = {}
			self._listener_keys = {}
			listeners = self._listeners
		end

		for key, new_entry in pairs(self._additions) do
			for _, event in ipairs(new_entry[2]) do
				listeners[event] = listeners[event] or {}
				listeners[event][key] = new_entry[1]
			end

			self._listener_keys[key] = new_entry[2]
		end

		self._additions = nil
	end
end

-- Lines 150-157
function SystemEventListenerHolder:_dispose_trash()
	if self._trash then
		for key, _ in pairs(self._trash) do
			self:_remove(key)
		end

		self._trash = nil
	end
end

-- Lines 161-163
function SystemEventListenerHolder:_not_trash(key)
	return not self._trash or not self._trash[key]
end

-- Lines 167-169
function SystemEventListenerHolder:has_listeners_for_event(event)
	return self._listeners and self._listeners[event]
end
