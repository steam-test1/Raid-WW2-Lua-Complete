RaidGUIControlButtonSkillProfiles = RaidGUIControlButtonSkillProfiles or class(RaidGUIControlButton)
RaidGUIControlButtonSkillProfiles.BACKGROUND_ICON = "grid_item_fg"
RaidGUIControlButtonSkillProfiles.BACKGROUND_COLOR = tweak_data.gui.colors.grid_item_grey
RaidGUIControlButtonSkillProfiles.ICON = "arrow_down"
RaidGUIControlButtonSkillProfiles.ICON_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlButtonSkillProfiles.ICON_SELECTED_SCALE = 0.82
RaidGUIControlButtonSkillProfiles.ICON_UNSELECTED_SCALE = 0.6
RaidGUIControlButtonSkillProfiles.CONTROLLER_BUTTON = utf8.char(57347)
RaidGUIControlButtonSkillProfiles.CONTROLLER_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
RaidGUIControlButtonSkillProfiles.CONTROLLER_FONT_SIZE = tweak_data.gui.font_sizes.size_24
RaidGUIControlButtonSkillProfiles.CONTROLLER_ICON_OFFSET = 8
RaidGUIControlButtonSkillProfiles.HOTSWAP_ID = "gui_skill_profiles_button"

function RaidGUIControlButtonSkillProfiles:init(parent, params)
	params.text = params.text or ""

	RaidGUIControlButtonSkillProfiles.super.init(self, parent, params)
	self:_layout(params)
	managers.controller:add_hotswap_callback(self.HOTSWAP_ID, callback(self, self, "_on_controller_hotswap"))
end

function RaidGUIControlButtonSkillProfiles:close()
	managers.controller:remove_hotswap_callback(self.HOTSWAP_ID)
end

function RaidGUIControlButtonSkillProfiles:_layout(params)
	local on_controller = managers.controller:is_using_controller()
	local icon_offset = on_controller and self.CONTROLLER_ICON_OFFSET or 0
	local background_data = tweak_data.gui:get_full_gui_data(self.BACKGROUND_ICON)
	self._background = self._object:bitmap({
		name = "background",
		color = nil,
		texture_rect = nil,
		texture = nil,
		h = nil,
		w = nil,
		w = params.w,
		h = params.h,
		texture = background_data.texture,
		texture_rect = background_data.texture_rect,
		color = self.BACKGROUND_COLOR
	})
	local icon_data = tweak_data.gui:get_full_gui_data(self.ICON)
	self._icon = self._object:bitmap({
		name = "arrow_icon",
		layer = nil,
		color = nil,
		texture_rect = nil,
		texture = nil,
		h = nil,
		w = nil,
		w = params.w * self.ICON_UNSELECTED_SCALE,
		h = params.w * self.ICON_UNSELECTED_SCALE,
		texture = icon_data.texture,
		texture_rect = icon_data.texture_rect,
		color = self.ICON_COLOR,
		layer = self._background:layer() + 1
	})

	self._icon:set_center(self._background:center_x(), self._background:center_y() - icon_offset)

	self._controller_button = self._object:label({
		visible = nil,
		vertical = "bottom",
		color = nil,
		align = "center",
		font_size = nil,
		font = nil,
		x = 2,
		name = "controller_switch_button",
		text = nil,
		layer = nil,
		text = self.CONTROLLER_BUTTON,
		font = self.CONTROLLER_FONT,
		font_size = self.CONTROLLER_FONT_SIZE,
		color = self.ICON_COLOR,
		layer = self._background:layer() + 1,
		visible = managers.controller:is_using_controller()
	})
	self._selected_icon_size = params.w * self.ICON_SELECTED_SCALE
	self._unselected_icon_size = params.w * self.ICON_UNSELECTED_SCALE
end

function RaidGUIControlButtonSkillProfiles:_on_controller_hotswap()
	local on_controller = managers.controller:is_using_controller()
	local icon_offset = on_controller and self.CONTROLLER_ICON_OFFSET or 0

	self._controller_button:set_visible(managers.controller:is_using_controller())
	self._icon:set_center_y(self._background:center_y() - icon_offset)
end

function RaidGUIControlButtonSkillProfiles:set_open_state(open_state)
	self._icon:stop()
	self._icon:animate(callback(self, self, "_animate_spin", open_state))
end

function RaidGUIControlButtonSkillProfiles:highlight_on()
	if not self._highlighted then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_highlight", true))

		self._highlighted = true

		RaidGUIControlButtonSkillProfiles.super.highlight_on(self)
	end
end

function RaidGUIControlButtonSkillProfiles:highlight_off()
	if self._highlighted then
		self._object:stop()
		self._object:animate(callback(self, self, "_animate_highlight", false))

		self._highlighted = nil

		RaidGUIControlButtonSkillProfiles.super.highlight_off(self)
	end
end

function RaidGUIControlButtonSkillProfiles:_animate_press()
end

function RaidGUIControlButtonSkillProfiles:_animate_release()
end

function RaidGUIControlButtonSkillProfiles:_animate_spin(open_state)
	local t = 0
	local duration = 0.18
	local start_rotation = self._icon:rotation()
	local end_rotation = open_state and 180 or 0
	local change = end_rotation - start_rotation

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_rotation = Easing.quadratic_out(t, start_rotation, change, duration)

		self._icon:set_rotation(current_rotation)
	end

	self._icon:set_rotation(end_rotation)
end

function RaidGUIControlButtonSkillProfiles:_animate_highlight(highlighted)
	local t = 0
	local duration = 0.15
	local progress_start = highlighted and 0 or 1
	local progress_end = highlighted and 1 or -1
	local center_x, center_y = self._background:center()
	local on_controller = managers.controller:is_using_controller()
	local icon_offset = on_controller and self.CONTROLLER_ICON_OFFSET or 0

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_in_out(t, progress_start, progress_end, duration)
		local current_size = math.lerp(self._unselected_icon_size, self._selected_icon_size, progress)

		self._icon:set_size(current_size, current_size)
		self._icon:set_center(center_x, center_y - icon_offset)
	end
end
