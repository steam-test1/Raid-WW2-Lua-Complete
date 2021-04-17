RaidGUIControlIntelImageDetails = RaidGUIControlIntelImageDetails or class(RaidGUIControl)
RaidGUIControlIntelImageDetails.DEFAULT_W = 444
RaidGUIControlIntelImageDetails.DEFAULT_H = 592
RaidGUIControlIntelImageDetails.BACKGROUND_SIZE_PERCENTAGE = 0.85
RaidGUIControlIntelImageDetails.FOREGROUND_SIZE_PERCENTAGE = 0.92
RaidGUIControlIntelImageDetails.SELECTOR_ICON = "ico_sel_rect_top_left"
RaidGUIControlIntelImageDetails.PRESSED_SIZE = 0.97

-- Lines 12-19
function RaidGUIControlIntelImageDetails:init(parent, params)
	RaidGUIControlIntelImageDetails.super.init(self, parent, params)

	self._on_click_callback = params.on_click_callback

	self:_create_panel()
	self:_create_details()
end

-- Lines 21-31
function RaidGUIControlIntelImageDetails:_create_panel()
	local panel_params = clone(self._params)
	panel_params.name = panel_params.name .. "_panel"
	panel_params.layer = panel_params.layer or self._panel:layer() + 1
	panel_params.x = self._params.x or 0
	panel_params.y = self._params.y or 0
	panel_params.w = self._params.w or RaidGUIControlIntelImageDetails.DEFAULT_W
	panel_params.h = self._params.h or RaidGUIControlIntelImageDetails.DEFAULT_H
	self._object = self._panel:panel(panel_params)
end

-- Lines 33-117
function RaidGUIControlIntelImageDetails:_create_details()
	local intel_image_panel_params = {
		name = "intel_image_panel",
		h = 309,
		y = 0,
		x = 0,
		w = self._object:w(),
		layer = self._object:layer() + 1
	}
	self._image_panel = self._object:panel(intel_image_panel_params)
	local intel_image_background_params = {
		texture = "ui/main_menu/textures/mission_paper_background",
		name = "intel_image_background",
		texture_rect = {
			1063,
			5,
			882,
			613
		},
		w = self._image_panel:w(),
		h = self._image_panel:h(),
		layer = self._image_panel:layer() + 1
	}
	self._intel_image_background = self._image_panel:bitmap(intel_image_background_params)

	self._intel_image_background:set_center(self._image_panel:w() / 2, self._image_panel:h() / 2)

	local intel_image_params = {
		texture = "ui/loading_screens/loading_trainyard",
		name = "intel_image",
		texture_rect = {
			256,
			0,
			1536,
			1024
		},
		w = self._intel_image_background:w() * RaidGUIControlIntelImageDetails.FOREGROUND_SIZE_PERCENTAGE,
		layer = self._image_panel:layer() + 2
	}
	self._intel_image = self._image_panel:bitmap(intel_image_params)

	self._intel_image:set_h(self._intel_image:w() * 2 / 3)
	self._intel_image:set_center(self._image_panel:w() / 2, self._image_panel:h() / 2)

	local intel_title_params = {
		text = "",
		name = "intel_title",
		x = 20,
		wrap = true,
		y = self._image_panel:y() + self._image_panel:h() + 32,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.large,
		color = tweak_data.gui.colors.raid_black
	}
	self._intel_title = self._object:text(intel_title_params)
	local _, _, w, h = self._intel_title:text_rect()

	self._intel_title:set_w(self._object:w() - self._intel_title:x() * 2)
	self._intel_title:set_h(h)

	local intel_subtitle_params = {
		text = "",
		name = "intel_subtitle",
		wrap = true,
		x = self._intel_title:x(),
		y = self._intel_title:y() + self._intel_title:h() + 12,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.paragraph,
		color = tweak_data.gui.colors.raid_black
	}
	self._intel_subtitle = self._object:text(intel_subtitle_params)
	local _, _, w, h = self._intel_subtitle:text_rect()

	self._intel_subtitle:set_w(self._object:w() - self._intel_subtitle:x() * 2)
	self._intel_subtitle:set_h(self._object:h() - self._intel_subtitle:y())
end

-- Lines 119-127
function RaidGUIControlIntelImageDetails:set_image(photo, title_id, description_id, skip_animation)
	if skip_animation then
		self:_set_image(photo, title_id, description_id)

		return
	end

	self._intel_image:stop()
	self._intel_image:animate(callback(self, self, "_animate_change_photo"), photo, title_id, description_id)
end

-- Lines 129-141
function RaidGUIControlIntelImageDetails:_set_image(photo, title_id, description_id)
	self._intel_image:set_image(tweak_data.gui.mission_photos[photo].texture)
	self._intel_image:set_texture_rect(unpack(tweak_data.gui.mission_photos[photo].texture_rect))
	self._intel_title:set_text(self:translate(title_id, true))

	local _, _, w, h = self._intel_title:text_rect()

	self._intel_title:set_w(self._object:w() - self._intel_title:x() * 2)
	self._intel_title:set_h(h)
	self._intel_subtitle:set_text(self:translate(description_id))
	self._intel_subtitle:set_y(self._intel_title:y() + self._intel_title:h() + 12)
	self._intel_subtitle:set_h(self._object:h() - self._intel_subtitle:y())
end

-- Lines 143-145
function RaidGUIControlIntelImageDetails:set_left(left)
	self._object:set_left(left)
end

-- Lines 147-149
function RaidGUIControlIntelImageDetails:set_right(right)
	self._object:set_right(right)
end

-- Lines 151-153
function RaidGUIControlIntelImageDetails:set_top(top)
	self._object:set_top(top)
end

-- Lines 155-157
function RaidGUIControlIntelImageDetails:set_bottom(bottom)
	self._object:set_bottom(bottom)
end

-- Lines 159-161
function RaidGUIControlIntelImageDetails:set_center_x(center_x)
	self._object:set_center_x(center_x)
end

-- Lines 163-165
function RaidGUIControlIntelImageDetails:set_center_y(center_y)
	self._object:set_center_y(center_y)
end

-- Lines 168-169
function RaidGUIControlIntelImageDetails:close()
end

-- Lines 175-203
function RaidGUIControlIntelImageDetails:_animate_change_photo(control, photo, title_id, description_id)
	local fade_out_duration = 0.05
	local fade_in_duration = 0.15
	local t = (1 - self._object:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_in(t, 1, -1, fade_out_duration)

		self._object:set_alpha(alpha)
	end

	self._object:set_alpha(0)
	self:_set_image(photo, title_id, description_id)

	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = Easing.quartic_out(t, 0, 1, fade_in_duration)

		self._object:set_alpha(alpha)
	end

	self._object:set_alpha(1)
end
