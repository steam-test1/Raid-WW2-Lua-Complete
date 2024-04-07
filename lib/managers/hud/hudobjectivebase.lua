HUDObjectiveBase = HUDObjectiveBase or class()
HUDObjectiveBase.OFFSET_WHILE_HIDDEN = 20

function HUDObjectiveBase:init()
	return
end

function HUDObjectiveBase:x()
	return self._object:x()
end

function HUDObjectiveBase:y()
	return self._object:y()
end

function HUDObjectiveBase:w()
	return self._object:w()
end

function HUDObjectiveBase:h()
	return self._object:h()
end

function HUDObjectiveBase:set_x(x)
	return self._object:set_x(x)
end

function HUDObjectiveBase:set_y(y)
	return self._object:set_y(y)
end

function HUDObjectiveBase:id()
	return self._id
end

function HUDObjectiveBase:complete()
	return
end

function HUDObjectiveBase:animate_show(delay)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show"), delay)
end

function HUDObjectiveBase:animate_hide(delay)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"), delay)
end

function HUDObjectiveBase:set_visible()
	self._object:set_visible(true)
	self._object:set_alpha(1)
	self._object:set_right(self._object:parent():w())
end

function HUDObjectiveBase:set_hidden()
	self._object:set_alpha(0)
	self._object:set_right(self._object:parent():w() - HUDObjectiveBase.OFFSET_WHILE_HIDDEN)
	self._object:set_visible(false)
end

function HUDObjectiveBase:_animate_show(panel, delay)
	local duration = 0.2
	local t = 0

	self._object:set_visible(true)
	self._object:set_alpha(0)
	self._object:set_right(self._object:parent():w() - HUDObjectiveBase.OFFSET_WHILE_HIDDEN)

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()

		t = t + dt

		local current_alpha = Easing.quartic_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)

		local current_offset = Easing.quartic_out(t, HUDObjectiveBase.OFFSET_WHILE_HIDDEN, -HUDObjectiveBase.OFFSET_WHILE_HIDDEN, duration)

		self._object:set_right(self._object:parent():w() - current_offset)
	end

	self._object:set_alpha(1)
	self._object:set_right(self._object:parent():w())
end

function HUDObjectiveBase:_animate_hide(panel, delay)
	local duration = 0.15
	local t = (1 - self._object:alpha()) * duration

	self._object:set_right(self._object:parent():w())

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()

		t = t + dt

		local current_alpha = Easing.quartic_in(t, 1, -1, duration)

		self._object:set_alpha(current_alpha)

		local current_offset = Easing.quartic_in(t, 0, HUDObjectiveBase.OFFSET_WHILE_HIDDEN, duration)

		self._object:set_right(self._object:parent():w() - current_offset)
	end

	self._object:set_alpha(0)
	self._object:set_right(self._object:parent():w() - HUDObjectiveBase.OFFSET_WHILE_HIDDEN)
	self._object:set_visible(false)
end
