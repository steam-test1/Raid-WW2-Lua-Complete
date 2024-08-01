local UpgradeStats = require("lib/utils/UpgradeStats")
RaidGUIControlSkillDetails = RaidGUIControlSkillDetails or class(RaidGUIControl)
RaidGUIControlSkillDetails.DEFAULT_W = 740
RaidGUIControlSkillDetails.DEFAULT_H = RaidGUIControlBranchingBarSkilltreeNode.DEFAULT_H
RaidGUIControlSkillDetails.TITLE_FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkillDetails.TITLE_FONT_SIZE = 72
RaidGUIControlSkillDetails.TITLE_COLOR = tweak_data.gui.colors.raid_red
RaidGUIControlSkillDetails.TITLE_H = RaidGUIControlSkillDetails.TITLE_FONT_SIZE + 2
RaidGUIControlSkillDetails.FRAME_MARGIN_W = 40
RaidGUIControlSkillDetails.FRAME_MARGIN_H = 20
RaidGUIControlSkillDetails.DESCRIPTION_PADDING_X = 22
RaidGUIControlSkillDetails.DESCRIPTION_PADDING_Y = 15
RaidGUIControlSkillDetails.PROGRESSION_PADDING_X = 12
RaidGUIControlSkillDetails.PROGRESSION_PADDING_Y = 15
RaidGUIControlSkillDetails.DESCRIPTION_FONT = tweak_data.gui.fonts.lato
RaidGUIControlSkillDetails.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.size_18
RaidGUIControlSkillDetails.DESCRIPTION_COLOR = tweak_data.gui.colors.raid_grey_skills
RaidGUIControlSkillDetails.INFORMATION_COLOR = tweak_data.gui.colors.raid_dirty_white
RaidGUIControlSkillDetails.INACTIVE_LEVEL_COLOR = tweak_data.gui.colors.raid_dark_grey
RaidGUIControlSkillDetails.FLAVOR_FONT_SIZE = tweak_data.gui.font_sizes.size_20
RaidGUIControlSkillDetails.COLOR_MACRO_CHARACTER = "|"

-- Lines 47-66
function RaidGUIControlSkillDetails:init(parent, params)
	RaidGUIControlSkillDetails.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSkillDetails:init] Parameters not specified for the skill details " .. tostring(self._name))

		return
	end

	self:_create_control_panel()
	self:_create_control_panel_bg()
	self:_create_skill_title()
	self:_create_skill_progression()
	self:_create_skill_description()
	self:_create_skill_flavor()
	self._main:stop()
	self._main:animate(callback(self, self, "_animate_show"))
end

-- Lines 69-88
function RaidGUIControlSkillDetails:_create_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlSkillDetails.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlSkillDetails.DEFAULT_H
	self._object = self._panel:panel(control_params)
	self._main = self._object:panel({
		name = "main_frame",
		x = RaidGUIControlSkillDetails.FRAME_MARGIN_W,
		y = RaidGUIControlSkillDetails.FRAME_MARGIN_H,
		w = self._object:w() - RaidGUIControlSkillDetails.FRAME_MARGIN_W * 2,
		h = self._object:h() - RaidGUIControlSkillDetails.FRAME_MARGIN_H * 2,
		layer = self._object:layer() + 1
	})
end

-- Lines 90-100
function RaidGUIControlSkillDetails:_create_control_panel_bg()
	self._background = self._object:nine_cut_bitmap({
		name = "background",
		alpha = 0.8,
		icon = "dialog_rect",
		corner_size = 64,
		w = self._object:w(),
		h = self._object:h(),
		layer = self._object:layer() - 1
	})
end

-- Lines 102-133
function RaidGUIControlSkillDetails:_create_skill_title()
	self._title = self._main:label({
		name = "skill_title",
		align = "center",
		text = "DEFAULT DABBLER",
		y = 4,
		w = self._main:w(),
		h = RaidGUIControlSkillDetails.TITLE_H,
		font = RaidGUIControlSkillDetails.TITLE_FONT,
		font_size = RaidGUIControlSkillDetails.TITLE_FONT_SIZE,
		color = RaidGUIControlSkillDetails.TITLE_COLOR,
		layer = self._main:layer() + 1
	})
	self._seperator_title = self._main:gradient({
		name = "seperator_title",
		h = 4,
		orientation = "horizontal",
		layer = 2,
		y = self._title:top() - 4,
		w = self._main:w()
	})
	local col = tweak_data.gui.colors.raid_red

	self._seperator_title:set_gradient_points({
		0,
		col:with_alpha(0),
		0.2,
		col:with_alpha(1),
		0.8,
		col:with_alpha(1),
		1,
		col:with_alpha(0)
	})
end

-- Lines 135-144
function RaidGUIControlSkillDetails:_create_skill_progression()
	self._skill_progression = self._main:create_custom_control(RaidGUIControlSkillProgression, {
		name = "skill_progression",
		layer = 1,
		x = RaidGUIControlSkillDetails.PROGRESSION_PADDING_X
	})

	self._skill_progression:set_center_y(self._main:center_y() + RaidGUIControlSkillDetails.PROGRESSION_PADDING_Y)
end

-- Lines 182-254
function RaidGUIControlSkillDetails:_create_skill_description()
	local x = self._skill_progression:right() + RaidGUIControlSkillDetails.DESCRIPTION_PADDING_X
	local y = self._title:bottom() + RaidGUIControlSkillDetails.DESCRIPTION_PADDING_Y
	self._description_panel = self._main:panel({
		name = "description_panel",
		x = x,
		y = y,
		w = self._main:w() - x,
		h = self._main:h() - y
	})
	local padding = 2
	local tier_icon_size = 52
	local info_icon_size = 32
	local text = "Sunburn can occur in less than 15 minutes, and in seconds when exposed to non-shielded welding arcs or other sources of intense ultraviolet light."
	local template = {
		vertical = "center",
		h = 68,
		wrap = true,
		align = "left",
		word_wrap = true,
		y = 0,
		rotation = 360,
		x = tier_icon_size + padding,
		w = self._description_panel:w() - tier_icon_size - padding,
		font = RaidGUIControlSkillDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlSkillDetails.DESCRIPTION_FONT_SIZE,
		color = RaidGUIControlSkillDetails.INFORMATION_COLOR,
		layer = self._main:layer() + 2
	}
	self._descriptions = {}
	self._tier_icons = {}
	local tiers = 4

	for i = 1, tiers do
		template.name = "skill_description_tier_" .. i
		local description = self._description_panel:text(template)
		self._descriptions[i] = description
		local tier_icon_gui = tweak_data.gui.icons["skills_weapon_tier_" .. i]
		local tier_icon = self._description_panel:bitmap({
			name = "skill_icon_tier_" .. i,
			w = tier_icon_size,
			h = tier_icon_size,
			texture = tier_icon_gui.texture,
			texture_rect = tier_icon_gui.texture_rect,
			color = template.color
		})

		tier_icon:set_center_y(description:center_y())
		tier_icon:set_center_x(tier_icon_size / 2)

		self._tier_icons[i] = tier_icon
		template.y = template.y + template.h + 15
	end

	template.name = "skill_description_info"
	self._info_description = self._description_panel:text(template)
	local info_icon_gui = tweak_data.gui.icons.ico_info
	self._info_icon = self._description_panel:bitmap({
		name = "skill_icon_info",
		w = info_icon_size,
		h = info_icon_size,
		texture = info_icon_gui.texture,
		texture_rect = info_icon_gui.texture_rect
	})

	self._info_icon:set_center_y(self._info_description:center_y())
	self._info_icon:set_center_x(tier_icon_size / 2)
end

-- Lines 256-291
function RaidGUIControlSkillDetails:_create_skill_flavor()
	local text = "Cuba is the largest island in the Caribbean, it is the second-most populous after Hispaniola!"
	local h = RaidGUIControlSkillDetails.FLAVOR_FONT_SIZE * 2
	self._flavor = self._main:label({
		name = "skill_flavor",
		vertical = "center",
		align = "center",
		text = text,
		y = self._main:h() - h,
		w = self._main:w(),
		h = h,
		font = RaidGUIControlSkillDetails.DESCRIPTION_FONT,
		font_size = RaidGUIControlSkillDetails.FLAVOR_FONT_SIZE,
		color = RaidGUIControlSkillDetails.DESCRIPTION_COLOR,
		layer = self._main:layer() + 2
	})
	local padding = 50
	self._seperator_flavor = self._main:gradient({
		name = "seperator_flavor",
		h = 2,
		orientation = "horizontal",
		layer = 2,
		x = padding,
		y = self._flavor:top() - 4,
		w = self._main:w() - padding * 2
	})
	local col = tweak_data.gui.colors.raid_dark_grey

	self._seperator_flavor:set_gradient_points({
		0,
		col:with_alpha(0),
		0.2,
		col:with_alpha(1),
		0.8,
		col:with_alpha(1),
		1,
		col:with_alpha(0)
	})
end

-- Lines 295-457
function RaidGUIControlSkillDetails:set_skill(item_data)
	local bought = item_data.bought
	local locked = not bought and item_data.level_required and managers.experience:current_level() < item_data.level_required
	local exp_progression = item_data.exp_progression or 0
	local current_tier = item_data.exp_tier or 1
	local exp_requirement_tier = item_data.exp_requirements[math.min(#item_data.exp_requirements, current_tier)]
	local max_tier = current_tier == #item_data.exp_requirements

	self._skill_progression:set_progress(max_tier and 1 or exp_progression / exp_requirement_tier)

	local icon = tweak_data.skilltree:get_skill_icon_tiered(item_data.key_name, true)

	self._skill_progression:set_skill_icon(tweak_data.gui:get_full_gui_data(icon))

	local status = RaidGUIControlSkillProgression.STATUS_PURCHASABLE
	local title = managers.localization:to_upper_text(item_data.name_id)
	local progress_title = tostring(item_data.gold_requirements)

	if max_tier then
		status = RaidGUIControlSkillProgression.STATUS_MAX_TIER
		title = title .. " " .. RaidGUIControlGridItemSkill.ROMAN_NUMBERS[current_tier]
		progress_title = self:translate("menu_skills_progress_title_maxed", true)
	elseif bought then
		local exp_string = managers.experience:experience_string(exp_requirement_tier - exp_progression)
		status = RaidGUIControlSkillProgression.STATUS_OWNED_OR_PURCHASED
		title = title .. " " .. RaidGUIControlGridItemSkill.ROMAN_NUMBERS[current_tier]
		progress_title = utf8.to_upper(managers.localization:text("menu_skills_progress_title_xp", {
			XP = exp_string
		}))
	elseif locked then
		status = RaidGUIControlSkillProgression.STATUS_LOCKED
		progress_title = utf8.to_upper(managers.localization:text("menu_skills_progress_title_level", {
			LEVEL = item_data.level_required
		}))
	end

	local accent_color = item_data.tag_color or RaidGUIControlSkillDetails.TITLE_COLOR

	self._seperator_title:set_gradient_points({
		0,
		accent_color:with_alpha(0),
		0.2,
		accent_color:with_alpha(1),
		0.8,
		accent_color:with_alpha(1),
		1,
		accent_color:with_alpha(0)
	})
	self._skill_progression:set_progress_color(accent_color)
	self._skill_progression:set_status(status, progress_title)
	self._title:set_font_size(RaidGUIControlSkillDetails.TITLE_FONT_SIZE)
	self._title:set_text(title)
	self._title:set_alpha(1)
	self._title:set_color(accent_color)

	local w = select(3, self._title:text_rect())

	if self._main:w() < w then
		local corrected_size = RaidGUIControlSkillDetails.TITLE_FONT_SIZE * self._main:w() / w

		self._title:set_font_size(corrected_size)
	end

	local flavor = managers.localization:text(item_data.description_id)

	self._flavor:set_text(flavor)
	self._flavor:set_alpha(1)
	self._flavor:set_color(RaidGUIControlSkillDetails.DESCRIPTION_COLOR)

	local display_data = UpgradeStats.get_display_data(item_data.key_name)
	local tier_data = display_data.tiers
	local info_data = display_data.info
	local description_panel_h = RaidGUIControlSkillDetails.DESCRIPTION_PADDING_Y

	for i, description_text in ipairs(self._descriptions or {}) do
		local tier_unlocked = bought and i <= current_tier
		local color = tier_unlocked and RaidGUIControlSkillDetails.DESCRIPTION_COLOR or RaidGUIControlSkillDetails.INACTIVE_LEVEL_COLOR
		local description = tier_data.descriptions[i]
		local tier_icon = self._tier_icons[i]

		if description then
			description_text:show()
			description_text:set_text(description)
			description_text:set_color(color)
			description_text:clear_range_color(1, utf8.len(description))
			description_text:set_alpha(1)
			tier_icon:show()
			tier_icon:set_color(color)
			tier_icon:set_alpha(1)

			if tier_unlocked and tier_data.color_ranges[i] then
				for index, color_change in ipairs(tier_data.color_ranges[i]) do
					description_text:set_range_color(color_change.start_index, color_change.end_index, accent_color)
				end
			end

			description_panel_h = description_text:bottom()
		else
			description_text:hide()
			tier_icon:hide()
		end
	end

	if info_data then
		local description = info_data.description
		local color = bought and RaidGUIControlSkillDetails.DESCRIPTION_COLOR or RaidGUIControlSkillDetails.INACTIVE_LEVEL_COLOR

		self._info_description:show()
		self._info_description:set_text(description)
		self._info_description:set_color(color)
		self._info_description:clear_range_color(1, utf8.len(description))
		self._info_icon:show()
		self._info_icon:set_color(color)

		if bought then
			for index, color_change in ipairs(info_data.color_ranges) do
				self._info_description:set_range_color(color_change.start_index, color_change.end_index, accent_color)
			end
		end

		description_panel_h = self._info_description:bottom()
	else
		self._info_description:hide()
		self._info_icon:hide()
	end

	self._description_panel:set_h(description_panel_h)
	self._description_panel:set_center_y(self._main:h() / 2 + RaidGUIControlSkillDetails.DESCRIPTION_PADDING_Y)
end

-- Lines 459-464
function RaidGUIControlSkillDetails:skill_purchased(item_data)
	self:set_skill(item_data)
	self._main:stop()
	self._main:animate(callback(self, self, "_animate_unlock"))
end

-- Lines 468-495
function RaidGUIControlSkillDetails:_animate_show()
	local title_y = 4
	local title_distance = 22
	local desc_x = self._skill_progression:right() + RaidGUIControlSkillDetails.DESCRIPTION_PADDING_X
	local desc_distance = 65
	local t = 0
	local duration = 0.28

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, duration)

		self._main:set_alpha(current_alpha)

		local current_y = Easing.quartic_out(t, title_y + title_distance, -title_distance, duration)

		self._title:set_y(current_y)

		local current_x = Easing.quartic_out(t, desc_x - desc_distance, desc_distance, duration)

		self._description_panel:set_x(current_x)
	end

	self._main:set_alpha(1)
	self._title:set_y(title_y)
	self._description_panel:set_x(desc_x)
end

-- Lines 497-513
function RaidGUIControlSkillDetails:_animate_unlock()
	local desc_x = self._skill_progression:right() + RaidGUIControlSkillDetails.DESCRIPTION_PADDING_X
	local desc_distance = 65
	local t = 0
	local duration = 0.45

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_x = Easing.quartic_out(t, desc_x + desc_distance, -desc_distance, duration)

		self._description_panel:set_x(current_x)
	end

	self._description_panel:set_x(desc_x)
end
