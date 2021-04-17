RaidGUIControlLootBreakdownItem = RaidGUIControlLootBreakdownItem or class(RaidGUIControl)
RaidGUIControlLootBreakdownItem.W = 320
RaidGUIControlLootBreakdownItem.TOP_PART_H = 124
RaidGUIControlLootBreakdownItem.ICON_LAYOUT_W = 96
RaidGUIControlLootBreakdownItem.HORIZONTAL_PADDING = 32
RaidGUIControlLootBreakdownItem.FONT = "din_compressed"
RaidGUIControlLootBreakdownItem.COUNTER_H = 64
RaidGUIControlLootBreakdownItem.COUNTER_FONT_SIZE = tweak_data.gui.font_sizes.size_56
RaidGUIControlLootBreakdownItem.COUNTER_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlLootBreakdownItem.TITLE_H = 32
RaidGUIControlLootBreakdownItem.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_32
RaidGUIControlLootBreakdownItem.TITLE_COLOR = tweak_data.gui.colors.raid_grey_effects
RaidGUIControlLootBreakdownItem.TEXT_PANEL_H = 96
RaidGUIControlLootBreakdownItem.COLOR_EMPTY = tweak_data.gui.colors.raid_red

-- Lines 21-40
function RaidGUIControlLootBreakdownItem:init(parent, params)
	RaidGUIControlLootBreakdownItem.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlLootBreakdownItem:init] Parameters not specified for the card details")

		return
	end

	self._acquired = params.acquired
	self._current = 0

	self:_create_panel()
	self:_create_icon()
	self:_create_text_panel()
	self:_create_counter()
	self:_create_title()
	self:_refresh_layout()
end

-- Lines 42-44
function RaidGUIControlLootBreakdownItem:acquired()
	return self._acquired
end

-- Lines 46-49
function RaidGUIControlLootBreakdownItem:add_points(amount)
	self._current = self._current + amount

	self:_refresh_counter()
end

-- Lines 51-57
function RaidGUIControlLootBreakdownItem:add_point(duration)
	self._icon:animate(callback(self, self, "_add_point"), duration)

	self._current = self._current + 1

	self:_refresh_counter()
end

-- Lines 59-88
function RaidGUIControlLootBreakdownItem:_add_point(main_icon, duration)
	local t = 0
	local y_move = 160
	local fade_out_distance = 40
	local icon_params = {
		name = "icon_clone",
		texture = tweak_data.gui.icons[self._params.icon].texture,
		texture_rect = tweak_data.gui.icons[self._params.icon].texture_rect,
		layer = self._icon:layer() + 1
	}
	local icon = self._object:bitmap(icon_params)

	icon:set_center_y(self._icon:center_y())
	icon:set_center_x(self._icon:center_x())

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_y_offset = Easing.linear(t, 0, y_move, duration)

		icon:set_center_y(RaidGUIControlLootBreakdownItem.TOP_PART_H / 2 + current_y_offset)

		if current_y_offset > y_move - fade_out_distance then
			local current_alpha = (y_move - current_y_offset) / (y_move - fade_out_distance)

			icon:set_alpha(current_alpha)
		end
	end

	self._object:remove(icon)
end

-- Lines 90-97
function RaidGUIControlLootBreakdownItem:_create_panel()
	local panel_params = {
		name = "loot_breakdown_item",
		alpha = 0,
		w = RaidGUIControlLootBreakdownItem.W
	}
	self._object = self._panel:panel(panel_params)
end

-- Lines 99-107
function RaidGUIControlLootBreakdownItem:_create_icon()
	local icon_params = {
		name = "loot_item_icon",
		texture = tweak_data.gui.icons[self._params.icon].texture,
		texture_rect = tweak_data.gui.icons[self._params.icon].texture_rect
	}
	self._icon = self._object:bitmap(icon_params)

	self._icon:set_center_y(RaidGUIControlLootBreakdownItem.TOP_PART_H / 2)
end

-- Lines 109-116
function RaidGUIControlLootBreakdownItem:_create_text_panel()
	local text_panel_params = {
		name = "text_panel",
		h = RaidGUIControlLootBreakdownItem.TEXT_PANEL_H
	}
	self._text_panel = self._object:panel(text_panel_params)

	self._text_panel:set_center_y(RaidGUIControlLootBreakdownItem.TOP_PART_H / 2)
end

-- Lines 118-131
function RaidGUIControlLootBreakdownItem:_create_counter()
	local counter_params = {
		vertical = "center",
		name = "counter",
		align = "center",
		text = "",
		halign = "scale",
		valign = "top",
		h = RaidGUIControlLootBreakdownItem.COUNTER_H,
		font = RaidGUIControlLootBreakdownItem.FONT,
		font_size = RaidGUIControlLootBreakdownItem.COUNTER_FONT_SIZE,
		color = RaidGUIControlLootBreakdownItem.COUNTER_COLOR
	}
	self._counter = self._text_panel:text(counter_params)

	self:_refresh_counter()
end

-- Lines 133-141
function RaidGUIControlLootBreakdownItem:_refresh_counter()
	local counter_text = tostring(self._current)

	if self._params.total then
		counter_text = counter_text .. " / " .. tostring(self._params.total)
	end

	self._counter:set_text(counter_text)
end

-- Lines 143-156
function RaidGUIControlLootBreakdownItem:_create_title()
	local title_params = {
		name = "counter",
		vertical = "center",
		align = "center",
		halign = "scale",
		valign = "top",
		y = self._counter:y() + self._counter:h(),
		h = RaidGUIControlLootBreakdownItem.TITLE_H,
		font = RaidGUIControlLootBreakdownItem.FONT,
		font_size = RaidGUIControlLootBreakdownItem.TITLE_FONT_SIZE,
		color = RaidGUIControlLootBreakdownItem.TITLE_COLOR,
		text = self:translate(self._params.title, true)
	}
	self._title = self._text_panel:text(title_params)
end

-- Lines 158-176
function RaidGUIControlLootBreakdownItem:_refresh_layout()
	local _, _, counter_w, _ = self._counter:text_rect()
	local _, _, title_w, _ = self._title:text_rect()
	local text_w = title_w < counter_w and counter_w or title_w
	text_w = 32 * math.ceil((text_w + 33) / 32)

	self._text_panel:set_w(math.ceil(text_w))
	self._counter:set_w(math.ceil(text_w))
	self._title:set_w(math.ceil(text_w))

	if self._object:w() < self._text_panel:w() + RaidGUIControlLootBreakdownItem.ICON_LAYOUT_W + 2 * RaidGUIControlLootBreakdownItem.HORIZONTAL_PADDING then
		self._object:set_w(math.ceil(self._text_panel:w() + RaidGUIControlLootBreakdownItem.ICON_LAYOUT_W + 2 * RaidGUIControlLootBreakdownItem.HORIZONTAL_PADDING))
	end

	local icon_center_x = (self._object:w() - text_w - RaidGUIControlLootBreakdownItem.ICON_LAYOUT_W) / 2 + RaidGUIControlLootBreakdownItem.ICON_LAYOUT_W / 2

	self._icon:set_center_x(math.floor(icon_center_x))
	self._text_panel:set_x(math.floor(self._icon:center_x() + RaidGUIControlLootBreakdownItem.ICON_LAYOUT_W / 2))
end

-- Lines 178-179
function RaidGUIControlLootBreakdownItem:close()
end

-- Lines 181-186
function RaidGUIControlLootBreakdownItem:animate_icon()
	self._animating_icon = true

	self._icon:stop()
	self._icon:animate(callback(self, self, "_animate_icon"))
end

-- Lines 189-210
function RaidGUIControlLootBreakdownItem:animate_show()
	local duration = 0.7
	local y_offset = 50
	local t = 0

	self._object:set_alpha(0)
	self._object:set_y(y_offset)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)

		local current_y_offset = Easing.quartic_out(t, y_offset, -y_offset, duration)

		self._object:set_y(current_y_offset)
	end

	self._object:set_alpha(1)
	self._object:set_y(0)
end

-- Lines 213-252
function RaidGUIControlLootBreakdownItem:animate_empty()
	local duration = 0.7
	local t = 0
	local played_sound = false
	local initial_icon_color = self._icon:color()
	local initial_counter_color = self._counter:color()
	local initial_title_color = self._title:color()

	wait(0.3)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_icon_r = Easing.quartic_out(t, initial_icon_color.r, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.r - initial_icon_color.r, duration)
		local current_icon_g = Easing.quartic_out(t, initial_icon_color.g, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.g - initial_icon_color.g, duration)
		local current_icon_b = Easing.quartic_out(t, initial_icon_color.b, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.b - initial_icon_color.b, duration)

		self._icon:set_color(Color(current_icon_r, current_icon_g, current_icon_b))

		local current_counter_r = Easing.quartic_out(t, initial_counter_color.r, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.r - initial_counter_color.r, duration)
		local current_counter_g = Easing.quartic_out(t, initial_counter_color.g, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.g - initial_counter_color.g, duration)
		local current_counter_b = Easing.quartic_out(t, initial_counter_color.b, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.b - initial_counter_color.b, duration)

		self._counter:set_color(Color(current_counter_r, current_counter_g, current_counter_b))

		local current_title_r = Easing.quartic_out(t, initial_title_color.r, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.r - initial_title_color.r, duration)
		local current_title_g = Easing.quartic_out(t, initial_title_color.g, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.g - initial_title_color.g, duration)
		local current_title_b = Easing.quartic_out(t, initial_title_color.b, RaidGUIControlLootBreakdownItem.COLOR_EMPTY.b - initial_title_color.b, duration)

		self._title:set_color(Color(current_title_r, current_title_g, current_title_b))

		if t > 0 and not played_sound then
			managers.menu_component:post_event(LootScreenGui.EMPTY_LOOT_ITEM_SOUND_EFFECT)

			played_sound = true
		end
	end

	self._icon:set_color(RaidGUIControlLootBreakdownItem.COLOR_EMPTY)
	self._counter:set_color(RaidGUIControlLootBreakdownItem.COLOR_EMPTY)
	self._title:set_color(RaidGUIControlLootBreakdownItem.COLOR_EMPTY)
end

-- Lines 254-257
function RaidGUIControlLootBreakdownItem:hide(delay)
	self._title:stop()
	self._title:animate(callback(self, self, "_animate_hide"), delay)
end

-- Lines 259-265
function RaidGUIControlLootBreakdownItem:finalize()
	self._object:set_alpha(1)
	self._object:set_y(0)

	self._current = self._params.acquired

	self:_refresh_counter()
end

-- Lines 267-270
function RaidGUIControlLootBreakdownItem:fade()
	self._object:set_alpha(0.5)
	self._icon:set_alpha(0.7)
end

-- Lines 272-278
function RaidGUIControlLootBreakdownItem:check_state()
	if self._acquired == 0 then
		self._icon:set_color(RaidGUIControlLootBreakdownItem.COLOR_EMPTY)
		self._counter:set_color(RaidGUIControlLootBreakdownItem.COLOR_EMPTY)
		self._title:set_color(RaidGUIControlLootBreakdownItem.COLOR_EMPTY)
	end
end

-- Lines 280-299
function RaidGUIControlLootBreakdownItem:_animate_hide(panel, delay)
	local duration = 0.3
	local t = 0
	local initial_alpha = self._object:alpha()

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, initial_alpha, -initial_alpha, duration)

		self._object:set_alpha(current_alpha)
	end

	self._object:set_alpha(0)
end

-- Lines 301-304
function RaidGUIControlLootBreakdownItem:animate_move_right(offset)
	self._counter:stop()
	self._counter:animate(callback(self, self, "_animate_move_right"), offset)
end

-- Lines 306-331
function RaidGUIControlLootBreakdownItem:_animate_move_right(panel, offset)
	local duration = 0.8
	local t = 0
	local initial_x_position = self._object:x()
	local initial_alpha = self._object:alpha()
	local initial_icon_alpha = self._icon:alpha()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, initial_alpha, 0.5 - initial_alpha, duration)

		self._object:set_alpha(current_alpha)

		local current_icon_alpha = Easing.quartic_in_out(t, initial_icon_alpha, 0.7 - initial_icon_alpha, duration)

		self._icon:set_alpha(current_icon_alpha)

		local current_x_offset = Easing.quartic_in_out(t, 0, offset, duration)

		self._object:set_x(initial_x_position + current_x_offset)
	end

	self._object:set_alpha(0.5)
	self._icon:set_alpha(0.7)
	self._object:set_x(initial_x_position + offset)
end

-- Lines 333-335
function RaidGUIControlLootBreakdownItem:stop_animating_icon()
	self._animating_icon = false
end

-- Lines 337-375
function RaidGUIControlLootBreakdownItem:_animate_icon(icon)
	local y_move = 160
	local t = 0
	local cycle_duration = 0.35
	local wait_time = 0.1
	local first_cycle = true
	local fade_out_distance = 30

	while self._animating_icon == true do
		self._icon:set_center_y(RaidGUIControlLootBreakdownItem.TOP_PART_H / 2)
		self._icon:set_alpha(1)

		while t < cycle_duration do
			local dt = coroutine.yield()
			t = t + dt
			local current_y_offset = nil

			if first_cycle then
				current_y_offset = Easing.quartic_in(t, 0, y_move, cycle_duration)
			else
				current_y_offset = Easing.linear(t, 0, y_move, cycle_duration)
			end

			self._icon:set_center_y(RaidGUIControlLootBreakdownItem.TOP_PART_H / 2 + current_y_offset)

			if current_y_offset > y_move - fade_out_distance then
				local current_alpha = (y_move - current_y_offset) / (y_move - fade_out_distance)

				self._icon:set_alpha(current_alpha)
			end
		end

		first_cycle = false
		t = 0

		wait(wait_time)
	end

	self._icon:set_center_y(RaidGUIControlLootBreakdownItem.TOP_PART_H / 2)
	self._icon:set_alpha(1)
end
