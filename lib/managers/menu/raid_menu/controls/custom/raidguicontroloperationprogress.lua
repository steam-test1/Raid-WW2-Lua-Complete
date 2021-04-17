RaidGUIControlOperationProgress = RaidGUIControlOperationProgress or class(RaidGUIControl)
RaidGUIControlOperationProgress.HEADING_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlOperationProgress.HEADING_FONT_SIZE = 22
RaidGUIControlOperationProgress.HEADING_COLOR = tweak_data.gui.colors.raid_light_red
RaidGUIControlOperationProgress.HEADING_PADDING_DOWN = 5
RaidGUIControlOperationProgress.PARAGRAPH_FONT = tweak_data.gui.fonts.lato
RaidGUIControlOperationProgress.PARAGRAPH_FONT_SIZE = 16
RaidGUIControlOperationProgress.PARAGRAPH_COLOR = tweak_data.gui.colors.raid_black
RaidGUIControlOperationProgress.PADDING_DOWN = 10
RaidGUIControlOperationProgress.SCROLL_ADVANCE = 20

-- Lines 14-28
function RaidGUIControlOperationProgress:init(parent, params)
	RaidGUIControlOperationProgress.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlOperationProgress:init] Parameters not specified for the peer details control " .. tostring(self._name))

		return
	end

	self._pointer_type = "arrow"
	self._operation = params.operation

	self:_create_panels()
end

-- Lines 30-42
function RaidGUIControlOperationProgress:_create_panels()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or RaidGUIControlOperationProgress.DEFAULT_W
	panel_params.h = self._params.h or RaidGUIControlOperationProgress.DEFAULT_H
	self._object = self._panel:panel(panel_params)
	self._inner_panel = self._object:panel(panel_params)
end

-- Lines 44-70
function RaidGUIControlOperationProgress:_create_progress_report(current_operation_stage)
	self._inner_panel:clear()
	self._inner_panel:set_h(self._object:h())

	self._scrollable = false
	local y = 0
	self._progress_parts = {}
	local i = 1

	for _, event_id in pairs(self._event_index) do
		if current_operation_stage == i then
			local event = tweak_data.operations.missions[self._operation].events[event_id]
			local current_part = self:_create_part(i, y, event.progress_title_id, event.progress_text_id)

			table.insert(self._progress_parts, current_part)

			y = y + current_part:h() + RaidGUIControlOperationProgress.PADDING_DOWN

			break
		end

		i = i + 1
	end

	self._inner_panel:set_h(y - RaidGUIControlOperationProgress.PADDING_DOWN)
	self:_check_scrollability()
end

-- Lines 72-113
function RaidGUIControlOperationProgress:_create_part(i, y, header_id, paragraph_id)
	local panel_params = {
		x = 0,
		name = "part_" .. tostring(i),
		y = y,
		w = self._inner_panel:w()
	}
	local part_panel = self._inner_panel:panel(panel_params)
	local header_params = {
		name = "header",
		y = 0,
		x = 0,
		font = RaidGUIControlOperationProgress.HEADING_FONT,
		font_size = RaidGUIControlOperationProgress.HEADING_FONT_SIZE,
		color = RaidGUIControlOperationProgress.HEADING_COLOR,
		text = self:translate(header_id, true)
	}
	local part_header = part_panel:text(header_params)
	local _, _, w, h = part_header:text_rect()

	part_header:set_w(w)
	part_header:set_h(h)
	part_header:set_center_y(16)

	local paragraph_params = {
		name = "paragraph",
		wrap = true,
		y = 32,
		x = 0,
		w = part_panel:w(),
		font = RaidGUIControlOperationProgress.PARAGRAPH_FONT,
		font_size = RaidGUIControlOperationProgress.PARAGRAPH_FONT_SIZE,
		color = RaidGUIControlOperationProgress.PARAGRAPH_COLOR,
		text = self:translate(paragraph_id)
	}
	local part_paragraph = part_panel:text(paragraph_params)
	local _, _, w, h = part_paragraph:text_rect()

	part_paragraph:set_w(w)
	part_paragraph:set_h(h)
	part_panel:set_h(part_paragraph:y() + part_paragraph:h())

	return part_panel
end

-- Lines 115-117
function RaidGUIControlOperationProgress:set_operation(operation)
	self._operation = operation
end

-- Lines 119-121
function RaidGUIControlOperationProgress:set_number_drawn(number)
	self:_create_progress_report(number)
end

-- Lines 123-125
function RaidGUIControlOperationProgress:set_event_index(event_index)
	self._event_index = event_index
end

-- Lines 127-133
function RaidGUIControlOperationProgress:_check_scrollability()
	if self._inner_panel:h() <= self._object:h() then
		return
	end

	self._scrollable = true
end

-- Lines 135-147
function RaidGUIControlOperationProgress:on_mouse_scroll_up()
	if not self._scrollable then
		return false
	end

	self._inner_panel:set_y(self._inner_panel:y() + RaidGUIControlOperationProgress.SCROLL_ADVANCE)

	if self._inner_panel:y() > 0 then
		self._inner_panel:set_y(0)
	end

	return true
end

-- Lines 149-161
function RaidGUIControlOperationProgress:on_mouse_scroll_down()
	if not self._scrollable then
		return false
	end

	self._inner_panel:set_y(self._inner_panel:y() - RaidGUIControlOperationProgress.SCROLL_ADVANCE)

	if self._inner_panel:y() < self._object:h() - self._inner_panel:h() then
		self._inner_panel:set_y(self._object:h() - self._inner_panel:h())
	end

	return true
end

-- Lines 164-165
function RaidGUIControlOperationProgress:close()
end
