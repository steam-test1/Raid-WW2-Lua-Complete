RaidGUIControlOperationProgress = RaidGUIControlOperationProgress or class(RaidGUIControl)
RaidGUIControlOperationProgress.HEADING_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlOperationProgress.HEADING_FONT_SIZE = 28
RaidGUIControlOperationProgress.HEADING_COLOR = tweak_data.gui.colors.raid_light_red
RaidGUIControlOperationProgress.HEADING_PADDING_DOWN = 5
RaidGUIControlOperationProgress.PARAGRAPH_FONT = tweak_data.gui.fonts.lato
RaidGUIControlOperationProgress.PARAGRAPH_FONT_SIZE = 16
RaidGUIControlOperationProgress.PARAGRAPH_COLOR = tweak_data.gui.colors.raid_black
RaidGUIControlOperationProgress.PADDING_DOWN = 10
RaidGUIControlOperationProgress.SCROLL_ADVANCE = 20

function RaidGUIControlOperationProgress:init(parent, params)
	RaidGUIControlOperationProgress.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlOperationProgress:init] Parameters not specified for the peer details control " .. tostring(self._name))

		return
	end

	self._pointer_type = "arrow"

	self:_layout()
end

function RaidGUIControlOperationProgress:_layout()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or self.DEFAULT_W
	panel_params.h = self._params.h or self.DEFAULT_H
	self._object = self._panel:panel(panel_params)
	self._inner_panel = self._object:panel(panel_params)
end

function RaidGUIControlOperationProgress:_layout_report(event_data)
	self._inner_panel:clear()
	self._inner_panel:set_h(self._object:h())

	self._scrollable = false
	local event_title = self:translate(event_data.progress_title_id or event_data.name_id, true)
	local event_paragraph = self:translate(event_data.progress_text_id or event_data.briefing_id)

	if event_data.stealth_description then
		event_paragraph = event_paragraph .. "\n\n" .. self:translate(event_data.stealth_description)
	end

	local current_part = self:_create_part(event_title, event_paragraph)
	local y = current_part:h() + self.PADDING_DOWN

	self._inner_panel:set_h(y - self.PADDING_DOWN)
	self:_check_scrollability()
end

function RaidGUIControlOperationProgress:_create_part(title_text, paragraph_text)
	local part_panel = self._inner_panel:panel({
		name = "part",
		w = self._inner_panel:w()
	})
	local part_header = part_panel:text({
		name = "header",
		font = self.HEADING_FONT,
		font_size = self.HEADING_FONT_SIZE,
		color = self.HEADING_COLOR,
		text = title_text
	})
	local _, _, w, h = part_header:text_rect()

	part_header:set_size(w, h)
	part_header:set_center_y(20)

	local part_paragraph = part_panel:text({
		name = "paragraph",
		y = 48,
		wrap = true,
		w = part_panel:w(),
		font = self.PARAGRAPH_FONT,
		font_size = self.PARAGRAPH_FONT_SIZE,
		color = self.PARAGRAPH_COLOR,
		text = paragraph_text
	})
	_, _, w, h = part_paragraph:text_rect()

	part_paragraph:set_size(w, h)
	part_panel:set_h(part_paragraph:y() + part_paragraph:h())

	return part_panel
end

function RaidGUIControlOperationProgress:set_event(event_data)
	if event_data then
		self:_layout_report(event_data)
	end
end

function RaidGUIControlOperationProgress:_check_scrollability()
	if self._inner_panel:h() <= self._object:h() then
		return
	end

	self._scrollable = true
end

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

function RaidGUIControlOperationProgress:close()
end
