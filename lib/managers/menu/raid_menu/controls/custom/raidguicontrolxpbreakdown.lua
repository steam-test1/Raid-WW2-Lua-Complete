RaidGUIControlXPBreakdown = RaidGUIControlXPBreakdown or class(RaidGUIControl)
RaidGUIControlXPBreakdown.DEFAULT_W = 320
RaidGUIControlXPBreakdown.DEFAULT_H = 448
RaidGUIControlXPBreakdown.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlXPBreakdown.EXPERIENCE_LABEL_X = 0
RaidGUIControlXPBreakdown.EXPERIENCE_LABEL_Y = 0
RaidGUIControlXPBreakdown.EXPERIENCE_LABEL_H = 64
RaidGUIControlXPBreakdown.LABEL_FONT_SIZE = tweak_data.gui.font_sizes.large
RaidGUIControlXPBreakdown.LABEL_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlXPBreakdown.LABEL_PADDING_DOWN = 0
RaidGUIControlXPBreakdown.TABLE_X = 0
RaidGUIControlXPBreakdown.TABLE_FONT_SIZE = tweak_data.gui.font_sizes.small
RaidGUIControlXPBreakdown.TABLE_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlXPBreakdown.TABLE_ROW_HEIGHT = 32
RaidGUIControlXPBreakdown.TABLE_COLUMN_HEIGHT = 32
RaidGUIControlXPBreakdown.TABLE_DESCRIPTION_W_PERCENT = 80
RaidGUIControlXPBreakdown.TABLE_VALUE_W_PERCENT = 20

-- Lines 31-49
function RaidGUIControlXPBreakdown:init(parent, params)
	RaidGUIControlXPBreakdown.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlXPBreakdown:init] Parameters not specified for the customization details")

		return
	end

	self._pointer_type = "arrow"

	self:_create_control_panel()
	self:_create_experience_label()
	self:_create_breakdown_table(params)
	self:_create_total()

	if not self._params.h then
		self:_fit_panel()
	end
end

-- Lines 52-53
function RaidGUIControlXPBreakdown:close()
end

-- Lines 56-64
function RaidGUIControlXPBreakdown:_create_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlXPBreakdown.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlXPBreakdown.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 66-77
function RaidGUIControlXPBreakdown:_create_experience_label()
	local experience_label_params = {
		name = "experience_label",
		vertical = "center",
		x = RaidGUIControlStatsBreakdown.EXPERIENCE_LABEL_X,
		y = RaidGUIControlStatsBreakdown.EXPERIENCE_LABEL_Y,
		w = RaidGUIControlStatsBreakdown.DEFAULT_W,
		h = RaidGUIControlXPBreakdown.EXPERIENCE_LABEL_H,
		font = RaidGUIControlStatsBreakdown.FONT,
		font_size = RaidGUIControlStatsBreakdown.LABEL_FONT_SIZE,
		color = RaidGUIControlStatsBreakdown.LABEL_COLOR,
		text = self:translate("xp_label", true)
	}
	self._experience_label = self._object:text(experience_label_params)
end

-- Lines 79-99
function RaidGUIControlXPBreakdown:_create_breakdown_table(params)
	local breakdown_table_params = {
		name = "breakdown_table",
		x = 0,
		y = self._experience_label:y() + self._experience_label:h() + RaidGUIControlXPBreakdown.LABEL_PADDING_DOWN,
		w = RaidGUIControlXPBreakdown.DEFAULT_W,
		table_params = {
			row_params = {
				height = RaidGUIControlXPBreakdown.TABLE_ROW_HEIGHT,
				font_size = RaidGUIControlXPBreakdown.TABLE_FONT_SIZE
			},
			data_source_callback = params.data_source_callback,
			columns = {
				{
					vertical = "center",
					align = "left",
					w = self._object:w() * RaidGUIControlXPBreakdown.TABLE_DESCRIPTION_W_PERCENT / 100,
					h = RaidGUIControlXPBreakdown.TABLE_COLUMN_HEIGHT,
					cell_class = RaidGUIControlXPCell,
					color = RaidGUIControlXPBreakdown.TABLE_COLOR
				},
				{
					vertical = "center",
					align = "right",
					w = self._object:w() * RaidGUIControlXPBreakdown.TABLE_VALUE_W_PERCENT / 100,
					h = RaidGUIControlXPBreakdown.TABLE_COLUMN_HEIGHT,
					cell_class = RaidGUIControlXPCell,
					color = RaidGUIControlXPBreakdown.TABLE_COLOR
				}
			}
		}
	}
	self._breakdown_table = self._control_panel:table(breakdown_table_params)
end

-- Lines 101-118
function RaidGUIControlXPBreakdown:_create_total()
end

-- Lines 121-123
function RaidGUIControlXPBreakdown:_fit_panel()
	self._object:set_h(self._breakdown_table:y() + self._breakdown_table:h())
end

-- Lines 125-129
function RaidGUIControlXPBreakdown:fade_in_total(duration)
end

-- Lines 131-145
function RaidGUIControlXPBreakdown:animate_fade_in_total(label, duration)
	local t = 0
	local anim_duration = duration or 0.15

	while t < anim_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, anim_duration)

		label:set_alpha(current_alpha)
	end

	label:set_alpha(1)
end

-- Lines 147-156
function RaidGUIControlXPBreakdown:set_total(total, animate)
end

-- Lines 158-163
function RaidGUIControlXPBreakdown:hide()
	self._breakdown_table._table_panel:set_alpha(0)
	self._experience_label:set_alpha(0)
end

-- Lines 165-167
function RaidGUIControlXPBreakdown:fade_in()
	self._experience_label:animate(callback(self, self, "_animate_table_fade_in"))
end

-- Lines 169-204
function RaidGUIControlXPBreakdown:_animate_table_fade_in()
	local t = 0
	local label_duration = 0.4
	local table_duration = 0.2
	local initial_offset = 15
	local label_y = self._experience_label:y()

	self._experience_label:set_y(label_y + initial_offset)

	while t < label_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quintic_out(t, initial_offset, -initial_offset, label_duration)

		self._experience_label:set_y(label_y + current_offset)

		local current_alpha = Easing.quintic_out(t, 0, 1, label_duration)

		self._experience_label:set_alpha(current_alpha)
	end

	self._experience_label:set_y(label_y)
	self._experience_label:set_alpha(1)

	t = 0

	while table_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_out(t, 0, 1, table_duration)

		self._breakdown_table._table_panel:set_alpha(current_alpha)
	end

	self._breakdown_table._table_panel:set_alpha(1)
end

-- Lines 234-236
function RaidGUIControlXPBreakdown:set_debug(value)
	self._control_border:set_debug(value)
end
