RaidGUIControlSkillDetails = RaidGUIControlSkillDetails or class(RaidGUIControl)
RaidGUIControlSkillDetails.DEFAULT_W = 740
RaidGUIControlSkillDetails.DEFAULT_H = RaidGUIControlBranchingBarSkilltreeNode.DEFAULT_H
RaidGUIControlSkillDetails.DEFAULT_TEXT_X = 12
RaidGUIControlSkillDetails.TITLE_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkillDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlSkillDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSkillDetails.TITLE_H = RaidGUIControlSkillDetails.TITLE_FONT_SIZE + 2
RaidGUIControlSkillDetails.DESCRIPTION_Y = RaidGUIControlBranchingBarSkilltreeNode.DEFAULT_H
RaidGUIControlSkillDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlSkillDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_18
RaidGUIControlSkillDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlSkillDetails.INFORMATION_COLOR = Color.white
RaidGUIControlSkillDetails.FLAVOR_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlSkillDetails.ACTIVE_LEVEL_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlSkillDetails.PENDING_LEVEL_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSkillDetails.INACTIVE_LEVEL_COLOR = tweak_data.gui.colors.raid_dark_grey

function RaidGUIControlSkillDetails:init(parent, params)
	RaidGUIControlSkillDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSkillDetails:init] Parameters not specified for the skill details " .. tostring(self._name))

		return
	end

	self:_create_control_panel()
	self:_create_control_panel_bg()
	self:_create_skill_title()
	self:_create_skill_description()
end

function RaidGUIControlSkillDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 50
	control_params.w = self._params.w or RaidGUIControlSkillDetails.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlSkillDetails.DEFAULT_H
	self._object = self._panel:panel(control_params)
end

function RaidGUIControlSkillDetails:_create_control_panel_bg()
	local bggui = self:_rand_bg()
	local background_params = {
		name = "background",
		alpha = 1,
		y = 0,
		x = 0,
		w = self._object:w(),
		h = self._object:h(),
		texture = bggui.texture,
		texture_rect = bggui.texture_rect,
		layer = self._object:layer() - 1
	}
	self._background = self._object:bitmap(background_params)
end

function RaidGUIControlSkillDetails:_rand_bg()
	local num = math.random(8)

	return tweak_data.gui.icons["backgrounds_skill_desc_" .. tostring(num)]
end

function RaidGUIControlSkillDetails:_create_skill_title()
	local skill_title_params = {
		name = "skill_title",
		wrap = true,
		align = "left",
		text = "",
		x = RaidGUIControlSkillDetails.DEFAULT_TEXT_X,
		w = self._object:w(),
		h = RaidGUIControlSkillDetails.TITLE_H,
		font = RaidGUIControlSkillDetails.TITLE_FONT,
		font_size = RaidGUIControlSkillDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlSkillDetails.TITLE_COLOR,
		layer = self._object:layer() + 1
	}
	self._title = self._object:label(skill_title_params)
end

function RaidGUIControlSkillDetails:_create_skill_description()
	local flavortext_text_params = {
		name = "skill_description",
		wrap = true,
		align = "left",
		text = "flavortext dummy",
		x = RaidGUIControlSkillDetails.DEFAULT_TEXT_X,
		y = self._title:y() + self._title:h(),
		w = self._object:w(),
		h = RaidGUIControlSkillDetails.FLAVOR_FONT_SIZE + 8,
		font = RaidGUIControlSkillDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlSkillDetails.FLAVOR_FONT_SIZE,
		color = RaidGUIControlSkillDetails.DESCRIPTION_COLOR,
		layer = self._object:layer() + 2
	}
	self._flavortext = self._object:label(flavortext_text_params)
	local description_text_params = {
		name = "skill_description",
		h = 1,
		wrap = true,
		word_wrap = true,
		align = "left",
		text = "skill_description dummy",
		x = RaidGUIControlSkillDetails.DEFAULT_TEXT_X,
		y = self._flavortext:y() + self._flavortext:h(),
		w = self._object:w() - 30,
		font = RaidGUIControlSkillDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlSkillDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlSkillDetails.INFORMATION_COLOR,
		layer = self._object:layer() + 2
	}
	self._description = self._object:text(description_text_params)
end

function RaidGUIControlSkillDetails:set_flipped(flipped)
	self._is_flipped = flipped
	local bggui = self:_rand_bg()

	self._background:set_x(flipped and self._object:w() or 0)
	self._background:set_w(flipped and -self._object:w() or self._object:w())
	self._background:set_texture_rect(unpack(bggui.texture_rect))
	self._title:set_align(flipped and "right" or "left")
	self._title:set_x(flipped and -RaidGUIControlSkillDetails.DEFAULT_TEXT_X or RaidGUIControlSkillDetails.DEFAULT_TEXT_X)
	self._flavortext:set_align(flipped and "right" or "left")
	self._flavortext:set_x(flipped and -RaidGUIControlSkillDetails.DEFAULT_TEXT_X or RaidGUIControlSkillDetails.DEFAULT_TEXT_X)
	self._description:set_align(flipped and "right" or "left")
end

function RaidGUIControlSkillDetails:set_skill(skill, title, flavor, description, color_changes, shape)
	self._object:get_engine_panel():stop()

	if shape then
		self:set_flipped(shape.x + self._panel:x() > 950)

		if shape.x then
			if self._is_flipped then
				local offx, _ = RaidGUIControlBranchingBarSkilltreeNode:get_skill_node_size()

				self._object:set_x(shape.x - self._object:w() - offx)
			else
				self._object:set_x(shape.x)
			end
		end

		if shape.y then
			self._object:set_y(shape.y)
		end
	end

	self._title:set_text(title)
	self._title:set_alpha(1)
	self._flavortext:set_text(flavor)
	self._flavortext:set_alpha(1)
	self._flavortext:set_color(RaidGUIControlSkillDetails.DESCRIPTION_COLOR)
	self._description:set_text(description)
	self._description:set_alpha(1)

	if color_changes then
		for index, color_change in pairs(color_changes) do
			local color = RaidGUIControlSkillDetails.DESCRIPTION_COLOR

			if color_change.state == ExperienceGui.STAT_LEVEL_ACTIVE then
				color = RaidGUIControlSkillDetails.ACTIVE_LEVEL_COLOR
			elseif color_change.state == ExperienceGui.STAT_LEVEL_INACTIVE then
				color = RaidGUIControlSkillDetails.INACTIVE_LEVEL_COLOR
			elseif color_change.state == ExperienceGui.STAT_LEVEL_PENDING then
				color = RaidGUIControlSkillDetails.PENDING_LEVEL_COLOR
			end

			self._description:set_range_color(color_change.start_index, color_change.end_index, color)
		end
	end

	self._object:fit_content_height()

	local _, y, _, h = self._description:text_rect()

	self._description:set_h(h)

	local _, skill_y = RaidGUIControlBranchingBarSkilltreeNode:get_skill_node_size()

	self._object:set_h(math.max(skill_y, self._object:h() + h))
	self._background:set_h(self._object:h())

	local bggui = self:_rand_bg()

	self._background:set_texture_rect(unpack(bggui.texture_rect))
	self._background:set_alpha(1)

	self._panel_invisible = false
end

function RaidGUIControlSkillDetails:fade_away()
	self._object:get_engine_panel():stop()
	self._object:get_engine_panel():animate(callback(self, self, "_animate_skill_hide"))
end

function RaidGUIControlSkillDetails:_animate_skill_hide()
	if not self._panel_invisible then
		self._panel_invisible = true
		local t = 0
		local starting_alpha = self._title._object:alpha()
		local fade_out_duration = starting_alpha * 0.35

		while t < fade_out_duration and self._panel_invisible == true do
			local dt = coroutine.yield()
			t = t + dt
			local current_alpha = Easing.quintic_in(t, starting_alpha, -starting_alpha, fade_out_duration)

			self._title._object:set_alpha(current_alpha)
			self._flavortext:set_alpha(current_alpha)
			self._description:set_alpha(current_alpha)
			self._background:set_alpha(current_alpha)
		end

		if self._panel_invisible then
			self._title._object:set_alpha(0)
			self._flavortext:set_alpha(0)
			self._description:set_alpha(0)
			self._background:set_alpha(0)
		end
	end
end
