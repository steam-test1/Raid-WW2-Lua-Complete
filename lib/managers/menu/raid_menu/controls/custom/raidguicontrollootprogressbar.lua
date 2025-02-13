RaidGUIControlLootProgressBar = RaidGUIControlLootProgressBar or class(RaidGUIControl)
RaidGUIControlLootProgressBar.DEFAULT_W = 1600
RaidGUIControlLootProgressBar.DEFAULT_H = 384
RaidGUIControlLootProgressBar.PROGRESS_BAR_H = 32

function RaidGUIControlLootProgressBar:init(parent, params)
	RaidGUIControlLootProgressBar.super.init(self, parent, params)

	if not params then
		Application:error("[RaidGUIControlLootProgressBar:init] Parameters not specified for the loot progress bar " .. tostring(self._name))

		return
	end

	self._total_points = params.total_points

	self:_create_panel()
	self:_create_progress_bar()
	self:_create_brackets()

	self._progress = params.initial_progress or 0

	self:set_progress(self._progress)
end

function RaidGUIControlLootProgressBar:close()
end

function RaidGUIControlLootProgressBar:_create_panel()
	local control_params = clone(self._params)
	control_params.name = control_params.name .. "_panel"
	control_params.layer = self._panel:layer() + 1
	control_params.w = self._params.w or RaidGUIControlLootProgressBar.DEFAULT_W
	control_params.h = self._params.h or RaidGUIControlLootProgressBar.DEFAULT_H
	self._control_panel = self._panel:panel(control_params)
	self._object = self._control_panel
end

function RaidGUIControlLootProgressBar:_create_progress_bar()
	local progress_bar_params = {
		name = "progress_bar",
		y = 0,
		x = RaidGUIControlLootBracket.DEFAULT_W / 2,
		w = self._object:w() - RaidGUIControlLootBracket.DEFAULT_W,
		h = RaidGUIControlLootProgressBar.PROGRESS_BAR_H,
		layer = self._object:layer() + 1
	}
	self._progress_bar = self._object:progress_bar_simple(progress_bar_params)

	self._progress_bar:set_y(self._object:h() - self._progress_bar:h())
end

function RaidGUIControlLootProgressBar:_create_brackets()
	self._brackets = {}
	local brackets = self._params.brackets

	for index, bracket in pairs(brackets) do
		local bracket_params = {
			y = 0,
			x = 0,
			bracket = RaidGUIControlLootBracket[utf8.to_upper(bracket.tier)],
			h = self._object:h(),
			layer = self._object:layer() + 50
		}
		local bracket_control = self._object:create_custom_control(RaidGUIControlLootBracket, bracket_params)
		local bracket_progress = math.clamp(bracket.points_needed / self._total_points, 0, 1)

		bracket_control:set_center_x(self._progress_bar:x() + self._progress_bar:w() * bracket_progress)

		local new_bracket = {
			active = false,
			control = bracket_control,
			progress = bracket_progress
		}

		table.insert(self._brackets, new_bracket)
	end
end

function RaidGUIControlLootProgressBar:set_progress(progress)
	self._progress_bar:set_progress(progress)

	for index, bracket in pairs(self._brackets) do
		if bracket.progress <= progress and not bracket.active then
			bracket.control:activate()

			bracket.active = true

			if index > 1 then
				self._brackets[index - 1].control:deactivate()
			end
		end
	end
end

function RaidGUIControlLootProgressBar:hide()
	self._object:set_alpha(0)
end

function RaidGUIControlLootProgressBar:fade_in()
	self._object:get_engine_panel():animate(callback(self, self, "_animate_fade_in"))
end

function RaidGUIControlLootProgressBar:_animate_fade_in()
	local duration = 0.3
	local t = self._object:alpha() * duration

	while duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)
	end

	self._object:set_alpha(1)
end
