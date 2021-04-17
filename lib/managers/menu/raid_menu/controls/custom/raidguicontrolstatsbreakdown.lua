RaidGUIControlStatsBreakdown = RaidGUIControlStatsBreakdown or class(RaidGUIControl)
RaidGUIControlStatsBreakdown.DEFAULT_W = 320
RaidGUIControlStatsBreakdown.DEFAULT_H = 250
RaidGUIControlStatsBreakdown.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlStatsBreakdown.STATS_LABEL_X = 0
RaidGUIControlStatsBreakdown.STATS_LABEL_Y = 0
RaidGUIControlStatsBreakdown.STATS_LABEL_H = 64
RaidGUIControlStatsBreakdown.LABEL_FONT_SIZE = tweak_data.gui.font_sizes.large
RaidGUIControlStatsBreakdown.LABEL_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlStatsBreakdown.LABEL_PADDING_DOWN = 0
RaidGUIControlStatsBreakdown.TABLE_X = 0
RaidGUIControlStatsBreakdown.TABLE_FONT_SIZE = tweak_data.gui.font_sizes.small
RaidGUIControlStatsBreakdown.TABLE_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlStatsBreakdown.TABLE_ROW_HEIGHT = 32
RaidGUIControlStatsBreakdown.TABLE_COLUMN_HEIGHT = 32
RaidGUIControlStatsBreakdown.TABLE_DESCRIPTION_W_PERCENT = 70
RaidGUIControlStatsBreakdown.TABLE_VALUE_W_PERCENT = 30

function RaidGUIControlStatsBreakdown:init(parent, params)
	RaidGUIControlStatsBreakdown.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlStatsBreakdown:init] Parameters not specified for the customization details")

		return
	end

	self._pointer_type = "arrow"

	self:highlight_off()
	self:_create_control_panel()
	self:_create_stats_label()
	self:_create_breakdown_table(params)

	if not params.h then
		self:_fit_panel()
	end
end

function RaidGUIControlStatsBreakdown:close()
end

function RaidGUIControlStatsBreakdown:_create_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlStatsBreakdown.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlStatsBreakdown.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlStatsBreakdown:_create_stats_label()
	local stats_label_params = {
		name = "stats_label",
		vertical = "center",
		x = RaidGUIControlStatsBreakdown.STATS_LABEL_X,
		y = RaidGUIControlStatsBreakdown.STATS_LABEL_Y,
		w = RaidGUIControlStatsBreakdown.DEFAULT_W,
		h = RaidGUIControlStatsBreakdown.STATS_LABEL_H,
		font = RaidGUIControlStatsBreakdown.FONT,
		font_size = RaidGUIControlStatsBreakdown.LABEL_FONT_SIZE,
		color = RaidGUIControlStatsBreakdown.LABEL_COLOR,
		text = self:translate("stats_label", true)
	}
	self._stats_label = self._object:text(stats_label_params)
end

function RaidGUIControlStatsBreakdown:_create_breakdown_table(params)
	local breakdown_table_params = {
		name = "breakdown_table",
		use_selector_mark = false,
		x = 0,
		y = self._stats_label:y() + self._stats_label:h() + RaidGUIControlStatsBreakdown.LABEL_PADDING_DOWN,
		w = RaidGUIControlStatsBreakdown.DEFAULT_W,
		table_params = {
			row_params = {
				height = RaidGUIControlStatsBreakdown.TABLE_ROW_HEIGHT,
				font_size = RaidGUIControlStatsBreakdown.TABLE_FONT_SIZE
			},
			data_source_callback = params.data_source_callback,
			columns = {
				{
					vertical = "center",
					align = "left",
					w = self._object:w() * RaidGUIControlStatsBreakdown.TABLE_DESCRIPTION_W_PERCENT / 100,
					h = RaidGUIControlStatsBreakdown.TABLE_COLUMN_HEIGHT,
					cell_class = RaidGUIControlTableCell,
					color = RaidGUIControlStatsBreakdown.TABLE_COLOR
				},
				{
					vertical = "center",
					align = "right",
					w = self._object:w() * RaidGUIControlStatsBreakdown.TABLE_VALUE_W_PERCENT / 100,
					h = RaidGUIControlStatsBreakdown.TABLE_COLUMN_HEIGHT,
					cell_class = RaidGUIControlTableCell,
					color = RaidGUIControlStatsBreakdown.TABLE_COLOR
				}
			}
		}
	}
	self._breakdown_table = self._control_panel:table(breakdown_table_params)
end

function RaidGUIControlStatsBreakdown:_fit_panel()
	self._object:set_h(self._breakdown_table:y() + self._breakdown_table:h())
end

function RaidGUIControlStatsBreakdown:hide()
	self._stats_label:set_alpha(0)
	self._breakdown_table._table_panel:set_alpha(0)

	local rows = self._breakdown_table:get_rows()

	for i = 1, #rows do
		local cells = rows[i]:get_cells()

		for j = 1, #cells do
			cells[j]:set_alpha(0)
		end
	end
end

function RaidGUIControlStatsBreakdown:fade_in()
	self._stats_label:animate(callback(self, self, "_animate_table_fade_in"))
end

function RaidGUIControlStatsBreakdown:_animate_table_fade_in()
	local t = 0
	local label_duration = 0.4
	local table_duration = 0.2
	local table_stats_duration = 0.2
	local initial_offset = 15
	local label_y = self._stats_label:y()

	self._stats_label:set_y(label_y + initial_offset)

	while t < label_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quintic_out(t, initial_offset, -initial_offset, label_duration)

		self._stats_label:set_y(label_y + current_offset)

		local current_alpha = Easing.quintic_out(t, 0, 1, label_duration)

		self._stats_label:set_alpha(current_alpha)
	end

	self._stats_label:set_y(label_y)
	self._stats_label:set_alpha(1)

	t = 0

	while table_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_out(t, 0, 1, table_duration)

		self._breakdown_table._table_panel:set_alpha(current_alpha)
	end

	self._breakdown_table._table_panel:set_alpha(1)

	t = 0
	local rows = self._breakdown_table:get_rows()

	for i = 1, #rows do
		self._stats_label:animate(callback(self, self, "_animate_table_row_fade_in"), rows[i], (i - 1) * 0.1)
	end

	wait(#rows * 0.1 + 0.1)
end

function RaidGUIControlStatsBreakdown:_animate_table_row_fade_in(label, row, delay)
	local t = 0
	local duration = 0.2
	local cells = row:get_cells()

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_out(t, 0, 1, duration)

		for i = 1, #cells do
			cells[i]:set_alpha(current_alpha)
		end
	end
end
