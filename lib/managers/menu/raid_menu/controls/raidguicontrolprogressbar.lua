RaidGUIControlProgressBar = RaidGUIControlProgressBar or class(RaidGUIControl)
RaidGUIControlProgressBar.SLIDER_STEP = 0.1

function RaidGUIControlProgressBar:init(parent, params)
	RaidGUIControlProgressBar.super.init(self, parent, params)

	if not self._params.color then
		Application:error("[RaidGUIControlProgressBar:init] Progress color not specified for the progress bar: ", self._params.name)

		return
	end

	self._bar_width = params.bar_width or params.w / 2
	self._params.font = self._params.font or tweak_data.menu.pd2_medium_font
	self._params.font_size = self._params.font_size or tweak_data.menu.pd2_medium_font_size
	self._object = self._panel:panel(self._params)
	self._bg_color = params.bar_background_color
	self._bg = self._object:rect({
		params.layer,
		y = 0,
		name = self._name .. "_bg",
		color = self._bg_color,
		x = self._object:w() - self._bar_width,
		w = self._bar_width,
		h = params.h,
		layer = self._params.layer + 1
	})
	self._description = self._object:text({
		align = "left",
		x = 0,
		w = self._object:w() / 5 * 4,
		text = utf8.to_upper(params.description),
		color = self._params.description_color or Color.white,
		font = self._params.font,
		font_size = self._params.font_size,
		layer = self._params.layer + 1
	})
	self._params.layer = self._params.layer + 2
	self._bar = self._object:rect(self._params)

	if params.border_width then
		self._bar:set_x(self._bg:x() + params.border_width)
		self._bar:set_y(self._bg:y() + params.border_width)
		self._bar:set_w(self._bg:w() - 2 * params.border_width)
		self._bar:set_h(self._bg:h() - 2 * params.border_width)

		self._width = self._bg:width() - 2 * params.border_width
	else
		self._width = self._bg:width()
	end

	self._draggable = self._params.dragable
	self._progress = 1
	self._on_value_change_callback = params.on_value_change_callback
end

function RaidGUIControlProgressBar:close()
	RaidGUIControlScrollbar.super.close()

	self._dragging = false
	self._draggable = false
end

function RaidGUIControlProgressBar:set_progress(progress)
	self._progress = math.clamp(progress, 0, 1)
	local width = self._progress * self._width

	self._bar:set_width(width)
end

function RaidGUIControlProgressBar:get_progress()
	return self._progress
end

function RaidGUIControlProgressBar:on_mouse_moved(o, x, y)
	if not self._draggable then
		return
	end

	RaidGUIControlProgressBar.super.on_mouse_moved(self, o, x, y)

	if not self._dragging then
		return
	end

	local new_width = x - self._bg:world_x() - (self._params.border_width or 0)
	local progress = math.clamp(new_width / self._width, 0, 1)

	self:set_progress(progress)

	if self._on_value_change_callback then
		self._on_value_change_callback()
	end

	return true, "grab"
end

function RaidGUIControlProgressBar:on_mouse_over(x, y)
	if not self._draggable then
		return
	end

	RaidGUIControlProgressBar.super.on_mouse_over(self, x, y)

	self._pointer_type = "hand"
end

function RaidGUIControlProgressBar:on_mouse_out(x, y)
	if not self._draggable then
		return
	end

	RaidGUIControlProgressBar.super.on_mouse_out(self, x, y)

	self._pointer_type = "hand"

	if self._dragging then
		if x - self._bg:world_x() < 0 then
			self:set_progress(0)
		elseif self._bg:w() < x - self._bg:world_x() then
			self:set_progress(1)
		end
	end

	self._dragging = false
end

function RaidGUIControlProgressBar:on_mouse_pressed()
	if not self._draggable then
		return
	end

	managers.raid_menu:set_active_control(self)

	self._pointer_type = "grab"
	self._dragging = true
	self._last_x = nil
end

function RaidGUIControlProgressBar:on_mouse_released()
	if not self._draggable then
		return
	end

	self._pointer_type = "hand"
	self._dragging = false

	if self._on_value_change_callback then
		self._on_value_change_callback()
	end
end

function RaidGUIControlProgressBar:show()
	self._object:show()
	self._bar:show()
	self._bg:show()
end

function RaidGUIControlProgressBar:hide()
	self._object:hide()
	self._bar:hide()
	self._bg:hide()
end

function RaidGUIControlProgressBar:set_selected(value)
	self._selected = value

	if self._selected then
		self:highlight_on()
	else
		self:highlight_off()
	end
end

function RaidGUIControlProgressBar:highlight_on()
	if self._params.no_highlight then
		return
	end

	self._object:highlight_on()
end

function RaidGUIControlProgressBar:highlight_off()
	if self._params.no_highlight or self._selected then
		return
	end

	self._object:highlight_off()
end

function RaidGUIControlProgressBar:confirm_pressed()
	if self._selected then
		self._selected_control = not self._selected_control

		self:_select_control(self._selected_control)

		return true
	end
end

function RaidGUIControlProgressBar:_select_control(value)
	local color = value and Color.white or self._bg_color

	self._bg:set_color(color)
end

function RaidGUIControlProgressBar:move_down()
	if self._selected then
		if self._selected_control then
			self._selected_control = false

			self:_select_control(false)
		end

		return self.super.move_down(self)
	end
end

function RaidGUIControlProgressBar:move_up()
	if self._selected then
		if self._selected_control then
			self._selected_control = false

			self:_select_control(false)
		end

		return self.super.move_up(self)
	end
end

function RaidGUIControlProgressBar:move_left()
	if self._selected then
		if self._selected_control then
			local current_progress = self:get_progress()

			self:set_progress(current_progress - RaidGUIControlProgressBar.SLIDER_STEP)

			if self._on_value_change_callback then
				self._on_value_change_callback()
			end

			return true
		else
			return self.super.move_left(self)
		end
	end
end

function RaidGUIControlProgressBar:move_right()
	if self._selected then
		if self._selected_control then
			local current_progress = self:get_progress()

			self:set_progress(current_progress + RaidGUIControlProgressBar.SLIDER_STEP)

			if self._on_value_change_callback then
				self._on_value_change_callback()
			end

			return true
		else
			return self.super.move_right(self)
		end
	end
end
