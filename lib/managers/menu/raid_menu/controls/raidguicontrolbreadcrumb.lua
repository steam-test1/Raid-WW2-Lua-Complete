RaidGUIControlBreadcrumb = RaidGUIControlBreadcrumb or class(RaidGUIControl)
RaidGUIControlBreadcrumb.IMAGE = "breadcumb_indicator"
RaidGUIControlBreadcrumb.PADDING = 42
RaidGUIControlBreadcrumb.ATTRACT_Y_OFFSET = 3
RaidGUIControlBreadcrumb.ATTRACT_MAX_ANGLE = 6
RaidGUIControlBreadcrumb.HIDE_ANIMATION_ROTATION = 30
RaidGUIControlBreadcrumb.HIDE_ANIMATION_INITIAL_SCALE = 0.8
RaidGUIControlBreadcrumb.HIDE_ANIMATION_FINAL_SCALE = 1.6

-- Lines 13-31
function RaidGUIControlBreadcrumb:init(parent, params)
	RaidGUIControlBreadcrumb.super.init(self, parent, params or {})

	self._id = managers.breadcrumb:get_unique_breadcrumb_id()
	self._visible = false
	self._padding = params and params.padding or RaidGUIControlBreadcrumb.PADDING

	self:_create_panel()
	self:_create_breadcrumb_icon()

	if self._params.delay then
		managers.queued_tasks:queue("breadcrumb_" .. tostring(self._id) .. "_presence_check", self.check_presence, self, nil, self._params.delay)
	else
		self:check_presence()
	end

	self:_subscribe_to_relevant_events()
end

-- Lines 33-42
function RaidGUIControlBreadcrumb:_create_panel()
	local panel_params = {
		name = "breadcrumb_panel",
		halign = "right",
		valign = "center",
		w = tweak_data.gui:icon_w(RaidGUIControlBreadcrumb.IMAGE) + 2 * self._padding,
		h = tweak_data.gui:icon_h(RaidGUIControlBreadcrumb.IMAGE) + 2 * self._padding,
		layer = self._params and self._params.layer or 1
	}
	self._object = self._panel:panel(panel_params, true)
end

-- Lines 44-55
function RaidGUIControlBreadcrumb:_create_breadcrumb_icon()
	local icon_params = {
		name = "breadcrumb_icon",
		valign = "center",
		halign = "center",
		alpha = 0,
		texture = tweak_data.gui.icons[RaidGUIControlBreadcrumb.IMAGE].texture,
		texture_rect = tweak_data.gui.icons[RaidGUIControlBreadcrumb.IMAGE].texture_rect
	}
	self._icon = self._object:bitmap(icon_params)

	self._icon:set_center_x(self._object:w() / 2)
	self._icon:set_center_y(self._object:h() / 2)
end

-- Lines 57-61
function RaidGUIControlBreadcrumb:_subscribe_to_relevant_events()
	if self._params.category or self._params.identifiers then
		managers.breadcrumb:register_breadcrumb_change_listener("breadcrumb_" .. tostring(self._id) .. "_event_listener", self._params.category, self._params.identifiers, callback(self, self, "check_presence"))
	end
end

-- Lines 64-87
function RaidGUIControlBreadcrumb:check_presence()
	if not self._params then
		return
	end

	local should_be_visible = false

	if self._params.category or self._params.identifiers then
		should_be_visible = should_be_visible or managers.breadcrumb:category_has_breadcrumbs(self._params.category, self._params.identifiers)
	end

	if self._params.check_callback then
		local callback_result = self._params.check_callback()
		should_be_visible = should_be_visible or callback_result
	end

	if should_be_visible and not self._visible then
		self._visible = true

		self._icon:stop()
		self._icon:animate(callback(self, self, "_animate_show"), math.random(0, 0.7))
	elseif not should_be_visible and self._visible then
		self:consume()
	end
end

-- Lines 89-100
function RaidGUIControlBreadcrumb:consume()
	if self._consumed then
		return
	end

	self._consumed = true
	self._visible = false

	if alive(self._icon) then
		self._icon:stop()
		self._icon:animate(callback(self, self, "_animate_hide"))
	end
end

-- Lines 102-113
function RaidGUIControlBreadcrumb:close()
	managers.breadcrumb:unregister_breadcrumb_change_listener("breadcrumb_" .. tostring(self._id) .. "_event_listener")
	managers.breadcrumb:clear_unique_breadcrumb_id(self._id)
	self._icon:stop()

	if managers.queued_tasks:has_task("breadcrumb_" .. tostring(self._id) .. "_presence_check") then
		managers.queued_tasks:unqueue("breadcrumb_" .. tostring(self._id) .. "_presence_check")
	end

	self._object:clear()
end

-- Lines 115-131
function RaidGUIControlBreadcrumb:_animate_show(icon, delay)
	local t = 0
	local duration = 0.25

	self._icon:set_alpha(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, duration)

		self._icon:set_alpha(current_alpha)
	end

	self._icon:set_alpha(1)
	self:_animate_attract(icon, delay)
end

-- Lines 133-165
function RaidGUIControlBreadcrumb:_animate_attract(icon, delay)
	while true do
		local t = 0
		local duration = 0.8

		self._icon:set_rotation(0)
		self._icon:set_center_x(self._object:w() / 2)
		self._icon:set_center_y(self._object:h() / 2)

		if delay then
			wait(delay)
		end

		while t < duration do
			local dt = coroutine.yield()
			t = t + dt
			local current_y_offset = Easing.sine_pulse(t, duration) * RaidGUIControlBreadcrumb.ATTRACT_Y_OFFSET

			self._icon:set_center_y(self._object:h() / 2 - current_y_offset)
		end

		self._icon:set_rotation(0)
		self._icon:set_center_x(self._object:w() / 2)
		self._icon:set_center_y(self._object:h() / 2)
		wait(1 + math.random() * 0.5)

		delay = nil
	end
end

-- Lines 167-169
function RaidGUIControlBreadcrumb:_get_sine_wave_interpolation(amplitude, t, duration)
	return amplitude * math.sin(math.deg(math.pi) * t / duration) * math.sin(math.deg(17 * math.pi) * t / duration)
end

-- Lines 171-206
function RaidGUIControlBreadcrumb:_animate_hide(icon)
	local t = 0
	local duration = 0.4

	self._icon:set_w(tweak_data.gui:icon_w(RaidGUIControlBreadcrumb.IMAGE) * RaidGUIControlBreadcrumb.HIDE_ANIMATION_INITIAL_SCALE)
	self._icon:set_h(tweak_data.gui:icon_h(RaidGUIControlBreadcrumb.IMAGE) * RaidGUIControlBreadcrumb.HIDE_ANIMATION_INITIAL_SCALE)
	self._icon:set_center_x(self._object:w() / 2)
	self._icon:set_center_y(self._object:h() / 2)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_rotation = Easing.quartic_in(t, 0, RaidGUIControlBreadcrumb.HIDE_ANIMATION_ROTATION, duration)

		self._icon:set_rotation(current_rotation)

		local current_scale = Easing.quartic_in(t, RaidGUIControlBreadcrumb.HIDE_ANIMATION_INITIAL_SCALE, RaidGUIControlBreadcrumb.HIDE_ANIMATION_FINAL_SCALE - RaidGUIControlBreadcrumb.HIDE_ANIMATION_INITIAL_SCALE, duration)

		self._icon:set_w(tweak_data.gui:icon_w(RaidGUIControlBreadcrumb.IMAGE) * current_scale)
		self._icon:set_h(tweak_data.gui:icon_h(RaidGUIControlBreadcrumb.IMAGE) * current_scale)
		self._icon:set_center_x(self._object:w() / 2)
		self._icon:set_center_y(self._object:h() / 2)

		local current_alpha = Easing.quartic_in(t, 1, -1, duration - 0.05)

		self._icon:set_alpha(current_alpha)
	end

	self._icon:set_rotation(RaidGUIControlBreadcrumb.HIDE_ANIMATION_ROTATION)
	self._icon:set_w(tweak_data.gui:icon_w(RaidGUIControlBreadcrumb.IMAGE) * RaidGUIControlBreadcrumb.HIDE_ANIMATION_FINAL_SCALE)
	self._icon:set_h(tweak_data.gui:icon_h(RaidGUIControlBreadcrumb.IMAGE) * RaidGUIControlBreadcrumb.HIDE_ANIMATION_FINAL_SCALE)
	self._icon:set_center_x(self._object:w() / 2)
	self._icon:set_center_y(self._object:h() / 2)
	self._icon:set_alpha(0)
end
