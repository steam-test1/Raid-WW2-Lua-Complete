RaidGuiControlDifficultyStars = RaidGuiControlDifficultyStars or class(RaidGUIControl)
RaidGuiControlDifficultyStars.STAR_FILLED_ICON = "star_rating"
RaidGuiControlDifficultyStars.STAR_FILLED_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGuiControlDifficultyStars.STAR_EMPTY_ICON = "star_rating_empty"
RaidGuiControlDifficultyStars.STAR_EMPTY_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGuiControlDifficultyStars.STAR_UNAVAILABLE_ICON = "star_rating_empty"
RaidGuiControlDifficultyStars.STAR_UNAVAILABLE_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGuiControlDifficultyStars.STARS_DISTANCE = 24
RaidGuiControlDifficultyStars.FIRST_STAR_CENTER_X = 9

-- Lines 15-25
function RaidGuiControlDifficultyStars:init(parent, params)
	RaidGuiControlDifficultyStars.super.init(self, parent, params)

	self._filled_color = params.fill_color or RaidGuiControlDifficultyStars.STAR_FILLED_COLOR
	self._empty_color = params.empty_color or params.fill_color or RaidGuiControlDifficultyStars.STAR_EMPTY_COLOR
	self._unavailable_color = params.unavailable_color or RaidGuiControlDifficultyStars.STAR_UNAVAILABLE_COLOR
	self._number_of_stars = params.amount

	self:_create_panel()
	self:_create_stars()
end

-- Lines 27-36
function RaidGuiControlDifficultyStars:_create_panel()
	local panel_params = {
		name = self._params.name or "difficulty_stars_panel",
		x = self._params.x or 0,
		y = self._params.y or 0,
		w = (self._number_of_stars - 1) * RaidGuiControlDifficultyStars.STARS_DISTANCE + RaidGuiControlDifficultyStars.FIRST_STAR_CENTER_X * 2,
		h = tweak_data.gui:icon_h(RaidGuiControlDifficultyStars.STAR_FILLED_ICON)
	}
	self._object = self._panel:panel(panel_params)
end

-- Lines 38-55
function RaidGuiControlDifficultyStars:_create_stars()
	self._stars = {}
	local center_x = RaidGuiControlDifficultyStars.FIRST_STAR_CENTER_X

	for i = 1, self._number_of_stars do
		local star_params = {
			name = "difficulty_star_" .. tostring(i),
			texture = tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_UNAVAILABLE_ICON].texture,
			texture_rect = tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_UNAVAILABLE_ICON].texture_rect,
			color = self._unavailable_color
		}
		local star = self._object:bitmap(star_params)

		star:set_center_x(center_x)
		table.insert(self._stars, star)

		center_x = center_x + RaidGuiControlDifficultyStars.STARS_DISTANCE
	end
end

-- Lines 57-78
function RaidGuiControlDifficultyStars:set_progress(available, completed)
	for i = 1, #self._stars do
		self._stars[i]:set_image(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_EMPTY_ICON].texture)
		self._stars[i]:set_texture_rect(unpack(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_EMPTY_ICON].texture_rect))
		self._stars[i]:set_color(self._unavailable_color)
		self._stars[i]:set_visible(true)
	end

	for i = 1, completed do
		self._stars[i]:set_image(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_FILLED_ICON].texture)
		self._stars[i]:set_texture_rect(unpack(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_FILLED_ICON].texture_rect))
		self._stars[i]:set_color(self._filled_color)
		self._stars[i]:set_visible(true)
	end

	for i = completed + 1, available do
		self._stars[i]:set_image(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_EMPTY_ICON].texture)
		self._stars[i]:set_texture_rect(unpack(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_EMPTY_ICON].texture_rect))
		self._stars[i]:set_color(self._empty_color)
		self._stars[i]:set_visible(true)
	end
end

-- Lines 80-94
function RaidGuiControlDifficultyStars:set_active_difficulty(difficulty)
	for i = 1, #self._stars do
		self._stars[i]:set_image(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_EMPTY_ICON].texture)
		self._stars[i]:set_texture_rect(unpack(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_EMPTY_ICON].texture_rect))
		self._stars[i]:set_color(self._unavailable_color)
	end

	for i = 1, difficulty do
		self._stars[i]:set_image(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_FILLED_ICON].texture)
		self._stars[i]:set_texture_rect(unpack(tweak_data.gui.icons[RaidGuiControlDifficultyStars.STAR_FILLED_ICON].texture_rect))
		self._stars[i]:set_color(self._filled_color)
		self._stars[i]:set_visible(true)
	end
end
