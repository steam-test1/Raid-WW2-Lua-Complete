HUDStatusEffects = HUDStatusEffects or class()
HUDStatusEffects.LEFT = 400
HUDStatusEffects.BOTTOM = 80
HUDStatusEffects.WIDTH = 800
HUDStatusEffects.HEIGHT = 48
HUDStatusEffects.BACKGROUND_IMAGE = "candy_buff_background"
HUDStatusEffects.PANEL_W = 48
HUDStatusEffects.PANEL_H = 48
HUDStatusEffects.ICON_SIZE = 32
HUDStatusEffects.ICON_PADDING = 4

function HUDStatusEffects:init(hud)
	Application:debug("[HUDStatusEffects:init]")

	self._hud_panel = hud.panel
	self._icons = {}
	self._object = self._hud_panel:panel({
		x = nil,
		h = nil,
		name = "status_effects_panel",
		w = nil,
		x = self.LEFT,
		w = self.WIDTH,
		h = self.HEIGHT
	})

	self._object:set_y(self._hud_panel:h() - self.BOTTOM)
	self:_realign_status()
end

function HUDStatusEffects:clear_all_status()
	Application:debug("[HUDStatusEffects] clear_all_status")

	for i, status_data in ipairs(self._icons) do
		self:remove_status(status_data.id)
	end

	self._icons = {}

	self._object:clear()
	self:_realign_status()
end

function HUDStatusEffects:remove_status(status_key, sync)
	local status_data, status_index = self:get_status(status_key)

	if status_data then
		status_data._stack = status_data._stack - 1

		Application:debug("[HUDStatusEffects] REMOVE status_key stack size!", status_key, status_data._stack)

		if status_data._stack <= 0 then
			status_data._panel:stop()
			self._object:remove(status_data._panel)
			table.remove(self._icons, status_index)
			self:_realign_status()
		end
	else
		Application:error("[HUDStatusEffects] REMOVE status_key did not match an existing icon!", status_key, inspect(self._icons))
	end

	if sync and managers.network and managers.network:session() then
		Application:debug("[HUDStatusEffects] Tell others to remove status!", status_key)
		managers.network:session():send_to_peers("sync_warcry_team_buff_status_effect_remove", status_key)
	end
end

function HUDStatusEffects:add_status(status_data)
	if not status_data or not status_data.id then
		Application:error("[HUDStatusEffects] ADD status_data needs to exist and have an 'id'!", status_data.id, status_data.tier)

		return
	end

	status_data.tier = status_data.tier or 0
	status_data.color = status_data.color or tweak_data.gui.colors.light_grey
	status_data.icon = status_data.icon or "status_effect_health_regen"
	local status = self:get_status(status_data.id)

	if status then
		status._stack = status._stack + 1

		self:_update_status(status, status_data)

		status_data._panel = status._panel
	else
		status_data._stack = 1
		status_data._panel = self:_make_status_box(status_data)

		table.insert(self._icons, status_data)
		self:_realign_status()
	end

	if status_data.lifetime then
		local panel = status_data._panel

		panel:stop()
		panel:animate(callback(self, self, "_animate_timer"), status_data.lifetime)
		managers.queued_tasks:queue(status_data.id, self.remove_status, self, status_data.id, status_data.lifetime, nil)
	end

	if status_data.sync_to_team and managers.network and managers.network:session() then
		status_data.sync_to_team = nil

		managers.network:session():send_to_peers("sync_warcry_team_buff_status_effect_add", status_data.id, status_data.tier or 0)
	end
end

function HUDStatusEffects:_update_status(cur_status_data, new_status_data)
	if cur_status_data.tier and new_status_data.tier and cur_status_data.tier < new_status_data.tier then
		cur_status_data.tier = new_status_data.tier
	end
end

function HUDStatusEffects:get_status(id)
	for index, status in ipairs(self._icons) do
		if status.id == id then
			return status, index
		end
	end
end

function HUDStatusEffects:_make_status_box(status_data)
	local status_key = status_data.id
	local status_color = status_data.color
	local status_icon = tweak_data.gui:get_full_gui_data(status_data.icon)
	local background_icon = tweak_data.gui:get_full_gui_data(self.BACKGROUND_IMAGE)
	local index = #self._icons
	local padding = self.PANEL_W + self.ICON_PADDING
	local status_effect_panel = self._object:panel({
		x = nil,
		h = nil,
		name = "status_effects_panel",
		w = nil,
		x = (index - 1) * padding,
		w = self.PANEL_W,
		h = self.PANEL_H
	})
	local background = status_effect_panel:bitmap({
		texture = nil,
		color = nil,
		h = nil,
		w = nil,
		layer = 1,
		name = "status_background",
		texture_rect = nil,
		w = status_effect_panel:w(),
		h = status_effect_panel:h(),
		texture = background_icon.texture,
		texture_rect = background_icon.texture_rect,
		color = status_color
	})
	local icon = status_effect_panel:bitmap({
		color = nil,
		halign = "center",
		valign = "center",
		layer = 3,
		texture_rect = nil,
		texture = nil,
		h = nil,
		w = nil,
		name = "icon",
		w = self.ICON_SIZE,
		h = self.ICON_SIZE,
		texture = status_icon.texture,
		texture_rect = status_icon.texture_rect,
		color = Color.black
	})

	icon:set_center(status_effect_panel:w() / 2, status_effect_panel:h() / 2)

	return status_effect_panel
end

function HUDStatusEffects:_realign_status()
	local data = {}
	local to_x = 0
	local padding = self.PANEL_W + self.ICON_PADDING

	for i, status_data in ipairs(self._icons) do
		local status_effect_panel = status_data._panel
		to_x = (i - 1) * padding
		local panel_data = {
			start_x = nil,
			panel = nil,
			end_x = nil,
			panel = status_effect_panel,
			start_x = status_effect_panel:x(),
			end_x = to_x
		}

		table.insert(data, panel_data)
	end

	to_x = to_x + padding

	self._object:stop()
	self._object:animate(callback(self, self, "_animate_realign"), data, to_x)
end

function HUDStatusEffects:_animate_timer(object, duration)
	wait(duration - 1)

	local t = 0
	local blink_duration = 0.7

	while t < blink_duration do
		local dt = coroutine.yield()
		t = t + dt
		local alpha = math.abs(math.sin(4 * t * 120)) / 2

		object:set_alpha(alpha + 0.2)
	end

	t = 0
	local fade_duration = 0.3

	while t < fade_duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_out(t, 1, -1, fade_duration)

		object:set_alpha(current_alpha)
	end

	object:set_alpha(0)
end

function HUDStatusEffects:_animate_realign(object, panel_align_data, end_width)
	local t = 0
	local duration = 0.32
	local start_width = object:w()

	if start_width < end_width then
		object:set_w(end_width)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current = Easing.quadratic_out(t, 0, 1, duration)

		for _, data in ipairs(panel_align_data) do
			data.panel:set_x(math.lerp(data.start_x, data.end_x, current))
		end
	end

	for _, data in ipairs(panel_align_data) do
		data.panel:set_x(data.end_x)
	end

	if end_width < start_width then
		object:set_w(end_width)
	end
end
