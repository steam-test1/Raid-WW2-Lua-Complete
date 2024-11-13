RaidGUIControlSkillsBreakdown = RaidGUIControlSkillsBreakdown or class(RaidGUIControl)
RaidGUIControlSkillsBreakdown.DEFAULT_W = 440
RaidGUIControlSkillsBreakdown.DEFAULT_H = 240
RaidGUIControlSkillsBreakdown.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlSkillsBreakdown.LABEL_X = 0
RaidGUIControlSkillsBreakdown.LABEL_Y = 0
RaidGUIControlSkillsBreakdown.LABEL_H = 64
RaidGUIControlSkillsBreakdown.LABEL_FONT_SIZE = tweak_data.gui.font_sizes.large
RaidGUIControlSkillsBreakdown.LABEL_COLOR = tweak_data.gui.colors.raid_white
RaidGUIControlSkillsBreakdown.LABEL_PADDING_DOWN = 2
RaidGUIControlSkillsBreakdown.ITEMS_SIZE = 80
RaidGUIControlSkillsBreakdown.ITEMS_PADDING = 8
RaidGUIControlSkillsBreakdown.ITEMS_PER_ROW = 5

function RaidGUIControlSkillsBreakdown:init(parent, params)
	RaidGUIControlSkillsBreakdown.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlSkillsBreakdown:init] Parameters not specified for the customization details")

		return
	end

	self._pointer_type = "arrow"

	self:_create_control_panel()
	self:_create_skills_label()
	self:_create_skills_panel()
	self:_create_skill_progressions(params)

	if not self._params.h then
		self:_fit_panel()
	end
end

function RaidGUIControlSkillsBreakdown:close()
end

function RaidGUIControlSkillsBreakdown:_create_control_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_customization_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlSkillsBreakdown.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlSkillsBreakdown.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlSkillsBreakdown:_create_skills_label()
	self._skills_label = self._object:text({
		text = nil,
		vertical = "center",
		x = nil,
		w = nil,
		name = "skills_label",
		color = nil,
		font_size = nil,
		font = nil,
		y = nil,
		h = nil,
		x = RaidGUIControlSkillsBreakdown.LABEL_X,
		y = RaidGUIControlSkillsBreakdown.LABEL_Y,
		w = RaidGUIControlSkillsBreakdown.DEFAULT_W,
		h = RaidGUIControlSkillsBreakdown.LABEL_H,
		font = RaidGUIControlSkillsBreakdown.FONT,
		font_size = RaidGUIControlSkillsBreakdown.LABEL_FONT_SIZE,
		color = RaidGUIControlSkillsBreakdown.LABEL_COLOR,
		text = self:translate("menu_skills", true)
	})
end

function RaidGUIControlSkillsBreakdown:_create_skills_panel()
	self._skills_panel = self._object:panel({
		y = nil,
		name = "skills_panel",
		h = nil,
		y = RaidGUIControlSkillsBreakdown.LABEL_H + RaidGUIControlSkillsBreakdown.LABEL_PADDING_DOWN,
		h = self._object:h() - RaidGUIControlSkillsBreakdown.LABEL_H - RaidGUIControlSkillsBreakdown.LABEL_PADDING_DOWN
	})
end

function RaidGUIControlSkillsBreakdown:_create_skill_progressions(params)
	local data = params.data_source_callback()

	if not data or #data == 0 then
		Application:error("[RaidGUIControlSkillsBreakdown:_create_skill_progressions] No items for skills breakdown panel: ", self._params.name)

		return
	end

	Application:trace("[RaidGUIControlSkillsBreakdown:_create_skill_progressions] skill items: ", inspect(data))

	local num_items = #data
	local row_count = num_items / RaidGUIControlSkillsBreakdown.ITEMS_PER_ROW
	local item_offset = RaidGUIControlSkillsBreakdown.ITEMS_SIZE + RaidGUIControlSkillsBreakdown.ITEMS_PER_ROW
	self._skills_data = {}
	self._skill_items = {}
	local i_horizontal = 1
	local i_vertical = 1

	for _, skill_data in ipairs(data) do
		if not skill_data.at_max_tier then
			local id = skill_data.id
			local icon = tweak_data.skilltree:get_skill_icon_tiered(id)
			local item = self._skills_panel:create_custom_control(RaidGUIControlSkillProgression, {
				y = nil,
				name = nil,
				h = nil,
				w = nil,
				x = nil,
				name = "skill_progression_" .. id,
				x = item_offset * (i_horizontal - 1),
				y = item_offset * (i_vertical - 1),
				w = RaidGUIControlSkillsBreakdown.ITEMS_SIZE,
				h = RaidGUIControlSkillsBreakdown.ITEMS_SIZE
			})

			item:set_progress(skill_data.progress)
			item:set_skill_icon(tweak_data.gui:get_full_gui_data(icon))
			item:set_progress_color(skill_data.tag_color)
			item:set_alpha(0)
			table.insert(self._skill_items, item)

			self._skills_data[id] = skill_data
			self._skills_data[id].item = item
			i_horizontal = i_horizontal + 1

			if RaidGUIControlSkillsBreakdown.ITEMS_PER_ROW < i_horizontal then
				i_horizontal = 1
				i_vertical = i_vertical + 1
			end
		end
	end
end

function RaidGUIControlSkillsBreakdown:_fit_panel()
	if not self._skill_items or #self._skill_items == 0 then
		return
	end

	local last_item = self._skill_items[#self._skill_items]

	self._skills_panel:set_h(last_item:bottom())
	self._object:set_h(self._skills_panel:bottom())
end

function RaidGUIControlSkillsBreakdown:hide()
	self._skills_label:set_alpha(0)
	self._skills_panel:set_alpha(0)
end

function RaidGUIControlSkillsBreakdown:progress_skills(progress_data)
	for _, skill_data in ipairs(progress_data) do
		local id = skill_data.id

		if self._skills_data[id] then
			local item = self._skills_data[id].item

			if item then
				local params = {
					previous_tier = nil,
					max_tier = nil,
					current_tier = nil,
					previous_tier = self._skills_data[id].tier or 1,
					current_tier = skill_data.tier or 1,
					max_tier = skill_data.max_tier
				}

				item:set_earned_xp(skill_data.progress, params)
			end

			self._skills_data[id].tier = skill_data.tier
			self._skills_data[id].progress = skill_data.progress
		end
	end
end

function RaidGUIControlSkillsBreakdown:fade_in()
	if self._skills_data then
		self._skills_label:animate(callback(self, self, "_animate_skills_fade_in"))
	end
end

function RaidGUIControlSkillsBreakdown:_animate_skills_fade_in()
	local t = 0
	local label_duration = 0.4
	local skill_duration = 0.25
	local initial_offset = 15
	local label_y = self._skills_label:y()

	self._skills_label:set_y(label_y + initial_offset)
	wait(0.3)

	while t < label_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_offset = Easing.quintic_out(t, initial_offset, -initial_offset, label_duration)

		self._skills_label:set_y(label_y + current_offset)

		local current_alpha = Easing.quintic_out(t, 0, 1, label_duration)

		self._skills_label:set_alpha(current_alpha)
		self._skills_panel:set_alpha(current_alpha)
	end

	self._skills_label:set_y(label_y)
	self._skills_label:set_alpha(1)
	self._skills_panel:set_alpha(1)
	wait(0.15)

	if self._skill_items then
		for i, skill_item in ipairs(self._skill_items) do
			t = 0

			while skill_duration > t do
				local dt = coroutine.yield()
				t = t + dt
				local current_alpha = Easing.quintic_out(t, 0, 1, skill_duration)

				skill_item:set_alpha(current_alpha)
			end

			skill_item:set_alpha(1)
		end
	end
end

function RaidGUIControlSkillsBreakdown:set_debug(value)
	self._control_border:set_debug(value)
end
