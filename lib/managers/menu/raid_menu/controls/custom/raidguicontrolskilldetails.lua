RaidGUIControlSkillDetails = RaidGUIControlSkillDetails or class(RaidGUIControl)
RaidGUIControlSkillDetails.DEFAULT_W = 736
RaidGUIControlSkillDetails.DEFAULT_H = 240
RaidGUIControlSkillDetails.TITLE_H = 64
RaidGUIControlSkillDetails.TITLE_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkillDetails.TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_38
RaidGUIControlSkillDetails.TITLE_COLOR = Color.white
RaidGUIControlSkillDetails.DESCRIPTION_W = 576
RaidGUIControlSkillDetails.DESCRIPTION_Y = 80
RaidGUIControlSkillDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlSkillDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlSkillDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlSkillDetails.ACTIVE_LEVEL_COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlSkillDetails.PENDING_LEVEL_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSkillDetails.INACTIVE_LEVEL_COLOR = tweak_data.gui.colors.raid_dark_grey

-- Lines 24-35
function RaidGUIControlSkillDetails:init(parent, params)
	RaidGUIControlSkillDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSkillDetails:init] Parameters not specified for the skill details " .. tostring(self._name))

		return
	end

	self:_create_control_panel()
	self:_create_skill_title()
	self:_create_skill_description()
end

-- Lines 38-46
function RaidGUIControlSkillDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlSkillDetails.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlSkillDetails.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

-- Lines 48-63
function RaidGUIControlSkillDetails:_create_skill_title()
	local skill_title_params = {
		vertical = "center",
		name = "skill_title",
		wrap = false,
		align = "left",
		text = "",
		y = 0,
		x = 0,
		w = self._object:w(),
		h = RaidGUIControlSkillDetails.TITLE_H,
		font = RaidGUIControlSkillDetails.TITLE_FONT,
		font_size = RaidGUIControlSkillDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlSkillDetails.TITLE_COLOR
	}
	self._title = self._object:label(skill_title_params)
end

-- Lines 65-79
function RaidGUIControlSkillDetails:_create_skill_description()
	local description_text_params = {
		name = "skill_description",
		wrap = true,
		word_wrap = true,
		text = "",
		x = 0,
		y = RaidGUIControlSkillDetails.DESCRIPTION_Y,
		w = RaidGUIControlSkillDetails.DESCRIPTION_W,
		h = self._object:h() - self._title:h(),
		font = RaidGUIControlSkillDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlSkillDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlSkillDetails.DESCRIPTION_COLOR
	}
	self._description = self._object:text(description_text_params)
end

-- Lines 81-86
function RaidGUIControlSkillDetails:set_skill(skill, title, description, color_changes)
	if self._title:text() ~= title or self._description:text() ~= description then
		self._object:get_engine_panel():stop()
		self._object:get_engine_panel():animate(callback(self, self, "_animate_skill_change"), title, description, color_changes)
	end
end

-- Lines 88-140
function RaidGUIControlSkillDetails:_animate_skill_change(skill_title_label, new_title, new_description, color_changes)
	local t = 0
	local starting_alpha = self._title._object:alpha()
	local fade_out_duration = starting_alpha * 0.1
	local fade_in_duration = 0.18

	while t < fade_out_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quintic_in(t, starting_alpha, -starting_alpha, fade_out_duration)

		self._title._object:set_alpha(current_alpha)
		self._description:set_alpha(current_alpha)
	end

	self._title._object:set_alpha(0)
	self._description:set_alpha(0)
	self._title:set_text(new_title)
	self._description:set_text(new_description)
	self._description:set_color(RaidGUIControlSkillDetails.DESCRIPTION_COLOR)

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

	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_name_alpha = Easing.quintic_out(t, 0, 1, fade_in_duration * 0.8)

		self._title._object:set_alpha(current_name_alpha)

		local current_description_alpha = Easing.quintic_out(t, 0, 1, fade_in_duration)

		self._description:set_alpha(current_description_alpha)
	end

	self._title._object:set_alpha(1)
	self._description:set_alpha(1)
end
