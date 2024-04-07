RaidGUIControlXPCell = RaidGUIControlXPCell or class(RaidGUIControlTableCell)
RaidGUIControlXPCell.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlXPCell.FONT_SIZE = tweak_data.gui.font_sizes.small

function RaidGUIControlXPCell:init(parent, params)
	params.font = RaidGUIControlXPCell.FONT
	params.font_size = RaidGUIControlXPCell.FONT_SIZE

	RaidGUIControlXPCell.super.init(self, parent, params)

	self._starting_x = self._object:x()
	self._initial_color = self._object:color()
	self._bottom = self._object:bottom()
	self._center_x = self._object:center_x()
	self._initial_font_size = self._object:font_size()
end

function RaidGUIControlXPCell:set_text(text, animate)
	if text ~= self._object:text() then
		self._object:set_text(text)

		if animate then
			self._object:stop()

			self._text_change_animation_thread = self._object:animate(callback(self, self, "animate_change_text"))
		end
	end
end

function RaidGUIControlXPCell:set_visible(flag)
	local alpha = flag and 1 or 0

	self._object:set_alpha(alpha)
end

function RaidGUIControlXPCell:fade_in(duration)
	if self._fade_in_animation_thread then
		self._panel:get_engine_panel():stop(self._fade_in_animation_thread)
	end

	self._fade_in_animation_thread = self._panel:get_engine_panel():animate(callback(self, self, "animate_fade_in"), duration)
end

function RaidGUIControlXPCell:animate_fade_in(panel, duration)
	local t = 0
	local anim_duration = duration or 0.15

	while t < anim_duration do
		local dt = coroutine.yield()

		t = t + dt

		local current_alpha = Easing.quartic_out(t, 0, 1, anim_duration)

		self._object:set_alpha(current_alpha)
	end

	self._object:set_alpha(1)
end

function RaidGUIControlXPCell:animate_change_text(panel)
	local starting_color = tweak_data.gui.colors.xp_breakdown_active_column
	local offset = 15
	local t = 0

	self._object:set_x(self._starting_x - offset)

	while t < 0.5 do
		local dt = coroutine.yield()

		t = t + dt

		local current_position = Easing.quartic_in(t, self._starting_x - offset, offset, 0.5)

		self._object:set_x(current_position)

		local new_r = Easing.quartic_in(t, starting_color.r, self._initial_color.r, 0.5)
		local new_g = Easing.quartic_in(t, starting_color.g, self._initial_color.g, 0.5)
		local new_b = Easing.quartic_in(t, starting_color.b, self._initial_color.b, 0.5)

		self._object:set_color(Color(new_r, new_g, new_b))
	end

	self._object:set_x(self._starting_x)
	self._object:set_color(self._initial_color)
end

function RaidGUIControlXPCell:highlight_on()
	return
end

function RaidGUIControlXPCell:highlight_off()
	return
end

function RaidGUIControlXPCell:select_on()
	return
end

function RaidGUIControlXPCell:select_off()
	return
end

function RaidGUIControlXPCell:on_double_click(button)
	return
end
