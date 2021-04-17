RaidGUIControlProgressBarSimple = RaidGUIControlProgressBarSimple or class(RaidGUIControl)
RaidGUIControlProgressBarSimple.DEFAULT_HEIGHT = 20
RaidGUIControlProgressBarSimple.DEFAULT_BACKGROUND_COLOR = Color.white:with_alpha(0.2)
RaidGUIControlProgressBarSimple.DEFAULT_FOREGROUND_COLOR = tweak_data.gui.colors.raid_red

-- Lines 8-21
function RaidGUIControlProgressBarSimple:init(parent, params)
	RaidGUIControlProgressBarSimple.super.init(self, parent, params)
	self:_create_panel()
	self:_create_background_bar()
	self:_create_foreground_bar()

	local initial_progress = params.initial_progress or 0

	self:set_progress(initial_progress)
end

-- Lines 23-31
function RaidGUIControlProgressBarSimple:_create_panel()
	local progress_bar_params = clone(self._params)
	progress_bar_params.name = progress_bar_params.name
	progress_bar_params.layer = self._panel:layer() + 1
	progress_bar_params.w = self._params.w or self._parent_panel:w()
	progress_bar_params.h = self._params.h or RaidGUIControlProgressBarSimple.DEFAULT_HEIGHT
	self._slider_panel = self._panel:panel(progress_bar_params)
	self._object = self._slider_panel
end

-- Lines 33-45
function RaidGUIControlProgressBarSimple:_create_background_bar(...)
	local background_bar_params = {
		name = "background_bar",
		y = 0,
		x = 0,
		w = self._params.bar_w,
		h = self._object:h(),
		left = self._params.left or "if_left_base",
		center = self._params.center or "if_center_base",
		right = self._params.right or "if_right_base",
		color = self._params.background_color or RaidGUIControlProgressBarSimple.DEFAULT_BACKGROUND_COLOR,
		layer = self._object:layer() + 1
	}
	self._background = self._object:three_cut_bitmap(background_bar_params)
end

-- Lines 47-66
function RaidGUIControlProgressBarSimple:_create_foreground_bar()
	local foreground_panel_params = {
		name = "foreground_panel",
		y = 0,
		x = 0,
		w = self._background:w(),
		h = self._object:h(),
		layer = self._object:layer() + 10
	}
	self._foreground = self._object:panel(foreground_panel_params)
	local foreground_image_params = {
		name = "foreground_bar",
		y = 0,
		x = 0,
		w = self._foreground:w(),
		h = self._foreground:h(),
		left = self._params.left or "if_left_base",
		center = self._params.center or "if_center_base",
		right = self._params.right or "if_right_base",
		color = self._params.foreground_color or RaidGUIControlProgressBarSimple.DEFAULT_FOREGROUND_COLOR
	}
	self._foreground_image = self._foreground:three_cut_bitmap(foreground_image_params)
end

-- Lines 68-72
function RaidGUIControlProgressBarSimple:set_progress(progress)
	self._progress = progress

	self._foreground:set_w(self._background:w() * progress)
	self._foreground_image:set_w(self._foreground:w())
end

-- Lines 74-78
function RaidGUIControlProgressBarSimple:set_foreground_progress(progress)
	self._progress = progress

	self._foreground:set_w(self._background:w() * progress)
	self._foreground_image:set_w(self._background:w())
end

-- Lines 80-82
function RaidGUIControlProgressBarSimple:get_progress()
	return self._progress
end

-- Lines 86-88
function RaidGUIControlProgressBarSimple:show()
	self._object:set_alpha(1)
end

-- Lines 90-92
function RaidGUIControlProgressBarSimple:hide()
	self._object:set_alpha(0)
end
