RaidGUIControlIntelImageGrid = RaidGUIControlIntelImageGrid or class(RaidGUIControl)
RaidGUIControlIntelImageGrid.DEFAULT_W = 474
RaidGUIControlIntelImageGrid.DEFAULT_H = 528
RaidGUIControlIntelImageGrid.SCROLL_ADVANCE = 20

-- Lines 7-21
function RaidGUIControlIntelImageGrid:init(parent, params)
	RaidGUIControlIntelImageGrid.super.init(self, parent, params)

	if not params.on_click_callback then
		Application:error("[RaidGUIControlIntelImageGrid:init] Callback not specified for the intel image grid control " .. tostring(self._name))

		return
	end

	self._mission = params.mission or "flakturm"
	self._on_click_callback = params.on_click_callback

	self:_create_panels()
	self:_create_photos()
end

-- Lines 23-35
function RaidGUIControlIntelImageGrid:_create_panels()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = self._params.layer or self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or RaidGUIControlIntelImageGrid.DEFAULT_W
	panel_params.h = self._params.h or RaidGUIControlIntelImageGrid.DEFAULT_H
	self._object = self._panel:panel(panel_params)
	self._inner_panel = self._object:panel(panel_params)
end

-- Lines 37-71
function RaidGUIControlIntelImageGrid:_create_photos(only_first_n_events)
	self._inner_panel:clear()
	self._inner_panel:set_y(0)
	self._inner_panel:set_h(self._object:h())

	self._scrollable = false
	self._mission_photos = self:_get_mission_photos(only_first_n_events)
	local y = 0
	local h = 0
	self._photos = {}

	for i = 1, #self._mission_photos do
		local photo_params = {
			x = 0,
			layer = 1,
			y = y,
			photo = self._mission_photos[i].photo,
			on_click_callback = callback(self, self, "_on_photo_clicked", i)
		}
		local photo = self._inner_panel:create_custom_control(RaidGUIControlIntelImage, photo_params)

		table.insert(self._photos, photo)

		if i % 2 == 0 then
			photo:set_right(self._inner_panel:w())

			y = y + photo:h()
		else
			h = h + photo:h()
		end
	end

	self._inner_panel:set_h(h)
	self:_check_scrollability()
end

-- Lines 74-103
function RaidGUIControlIntelImageGrid:_on_photo_clicked(photo_index)
	if self._selected_index == photo_index then
		return
	end

	if self._selected_index then
		self._photos[self._selected_index]:unselect()
	end

	self._selected_index = photo_index

	self._on_click_callback(photo_index, self._mission_photos[photo_index])

	if self._scrollable then
		if self._photos[self._selected_index]:y() < -self._inner_panel:y() then
			self._inner_panel:set_y(-self._photos[self._selected_index]:y())

			if self._inner_panel:y() > 0 then
				self._inner_panel:set_y(0)
			end
		end

		if self._object:h() < self._photos[self._selected_index]:y() + self._photos[self._selected_index]:h() + self._inner_panel:y() then
			self._inner_panel:set_y(-self._photos[self._selected_index]:y())

			if self._inner_panel:y() < self._object:h() - self._inner_panel:h() then
				self._inner_panel:set_y(self._object:h() - self._inner_panel:h())
			end
		end
	end
end

-- Lines 105-122
function RaidGUIControlIntelImageGrid:set_data(data)
	self._mission = data.mission

	if data.image_selected then
		self._selected_index = data.image_selected

		self._photos[self._selected_index]:select(true)
		self._on_click_callback(data.image_selected, self._mission_photos[data.image_selected])
	end

	if data.save_data then
		self._save_data = deep_clone(data.save_data)
	end

	self:_create_photos(data.only_first_n_events)

	self._selected_index = nil

	self:select(1)
end

-- Lines 124-128
function RaidGUIControlIntelImageGrid:select(index)
	if self._mission_photos[index] then
		self:_on_photo_clicked(index)
	end
end

-- Lines 130-132
function RaidGUIControlIntelImageGrid:clear_selection()
	self._selected_index = nil
end

-- Lines 134-150
function RaidGUIControlIntelImageGrid:set_selected(value, dont_trigger_selected_callback)
	self._selected = value

	if self._selected_index then
		self._photos[self._selected_index]:set_selected(false)
	end

	if self._selected then
		local photo_to_select = nil

		if #self._photos % 2 == 0 then
			photo_to_select = #self._photos - 1
		else
			photo_to_select = #self._photos
		end

		self._photos[photo_to_select]:set_selected(true)
	end
end

-- Lines 152-165
function RaidGUIControlIntelImageGrid:move_up()
	if self._selected and self._selected_index and self._photos[self._selected_index - 2] then
		self._photos[self._selected_index]:set_selected(false)
		self._photos[self._selected_index - 2]:set_selected(true)

		return true
	end

	local screen_move = RaidGUIControlIntelImageGrid.super.move_up(self)

	if screen_move then
		self._photos[self._selected_index]:highlight_off()

		return true
	end

	return false
end

-- Lines 167-180
function RaidGUIControlIntelImageGrid:move_down()
	if self._selected and self._selected_index and self._photos[self._selected_index + 2] then
		self._photos[self._selected_index]:set_selected(false)
		self._photos[self._selected_index + 2]:set_selected(true)

		return true
	end

	local screen_move = RaidGUIControlIntelImageGrid.super.move_down(self)

	if screen_move then
		self._photos[self._selected_index]:highlight_off()

		return true
	end

	return false
end

-- Lines 182-195
function RaidGUIControlIntelImageGrid:move_right()
	if self._selected and self._selected_index and self._selected_index % 2 ~= 0 and self._photos[self._selected_index + 1] then
		self._photos[self._selected_index]:set_selected(false)
		self._photos[self._selected_index + 1]:set_selected(true)

		return true
	end

	local screen_move = RaidGUIControlIntelImageGrid.super.move_right(self)

	if screen_move then
		self._photos[self._selected_index]:highlight_off()

		return true
	end

	return false
end

-- Lines 197-210
function RaidGUIControlIntelImageGrid:move_left()
	if self._selected and self._selected_index and self._selected_index % 2 == 0 and self._photos[self._selected_index - 1] then
		self._photos[self._selected_index]:set_selected(false)
		self._photos[self._selected_index - 1]:set_selected(true)

		return true
	end

	local screen_move = RaidGUIControlIntelImageGrid.super.move_left(self)

	if screen_move then
		self._photos[self._selected_index]:highlight_off()

		return true
	end

	return false
end

-- Lines 212-253
function RaidGUIControlIntelImageGrid:_get_mission_photos(only_first_n_events)
	local mission_tweak_data = tweak_data.operations.missions[self._mission]
	local photos = {}

	if self._save_data then
		mission_tweak_data.events_index = self._save_data.events_index
	end

	if mission_tweak_data.photos then
		for _, photo in pairs(mission_tweak_data.photos) do
			table.insert(photos, photo)
		end
	end

	if mission_tweak_data.job_type == OperationsTweakData.JOB_TYPE_OPERATION and only_first_n_events ~= 1 then
		local events = 1
		local operation_event_index = mission_tweak_data.events_index

		for _, event in pairs(operation_event_index) do
			local event_tweak_data = mission_tweak_data.events[event]

			if event_tweak_data.photos then
				for _, photo in pairs(event_tweak_data.photos) do
					table.insert(photos, photo)
				end
			end

			if only_first_n_events and events == only_first_n_events then
				break
			end

			events = events + 1
		end
	end

	if self._save_data then
		mission_tweak_data.events_index = nil
		self._save_data = nil
	end

	return photos
end

-- Lines 255-261
function RaidGUIControlIntelImageGrid:_check_scrollability()
	if self._inner_panel:h() <= self._object:h() then
		return
	end

	self._scrollable = true
end

-- Lines 263-275
function RaidGUIControlIntelImageGrid:on_mouse_scroll_up()
	if not self._scrollable then
		return false
	end

	self._inner_panel:set_y(self._inner_panel:y() + RaidGUIControlIntelImageGrid.SCROLL_ADVANCE)

	if self._inner_panel:y() > 0 then
		self._inner_panel:set_y(0)
	end

	return true
end

-- Lines 277-289
function RaidGUIControlIntelImageGrid:on_mouse_scroll_down()
	if not self._scrollable then
		return false
	end

	self._inner_panel:set_y(self._inner_panel:y() - RaidGUIControlIntelImageGrid.SCROLL_ADVANCE)

	if self._inner_panel:y() < self._object:h() - self._inner_panel:h() then
		self._inner_panel:set_y(self._object:h() - self._inner_panel:h())
	end

	return true
end

-- Lines 291-292
function RaidGUIControlIntelImageGrid:close()
end
