HUDBigPrompt = HUDBigPrompt or class()
HUDBigPrompt.W = 450
HUDBigPrompt.H = 148
HUDBigPrompt.TEXT_FONT = tweak_data.gui.fonts.din_compressed
HUDBigPrompt.TEXT_FONT_SIZE = tweak_data.gui.font_sizes.medium
HUDBigPrompt.DESCRIPTION_FONT = tweak_data.gui.fonts.din_compressed_outlined_24
HUDBigPrompt.DESCRIPTION_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDBigPrompt.DEFAULT_TEXT_COLOR = tweak_data.gui.colors.light_grey
HUDBigPrompt.DEFAULT_BACKGROUND = "backgrounds_equipment_panel_msg"
HUDBigPrompt.BACKGROUND_H = 50
HUDBigPrompt.ICON_OFFSET = 10
HUDBigPrompt.FLARES_SIZE = 128

function HUDBigPrompt:init(hud)
	if hud.panel:child("big_prompt_panel") then
		hud.panel:remove(hud.panel:child("big_prompt_panel"))
	end

	self:_create_panel(hud)
	self:_create_background()
	self:_create_title()
	self:_create_description()
	self:_create_icon()
end

function HUDBigPrompt:_create_panel(hud)
	self._object = hud.panel:panel({
		valign = "center",
		alpha = 0,
		name = "big_prompt_panel",
		halign = "center",
		w = HUDBigPrompt.W,
		h = HUDBigPrompt.H
	})
end

function HUDBigPrompt:_create_background()
	self._background = self._object:bitmap({
		layer = 1,
		name = "big_prompt_background",
		w = HUDBigPrompt.W,
		h = HUDBigPrompt.BACKGROUND_H,
		texture = tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture,
		texture_rect = tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture_rect
	})

	self._background:set_center_x(self._object:w() / 2)
	self._background:set_y(70)
end

function HUDBigPrompt:_create_title()
	self._title = self._object:text({
		valign = "scale",
		name = "big_prompt_text",
		vertical = "center",
		align = "center",
		text = "TITLE",
		halign = "scale",
		layer = self._background:layer() + 1,
		h = HUDBigPrompt.BACKGROUND_H,
		font = tweak_data.gui:get_font_path(HUDBigPrompt.TEXT_FONT, HUDBigPrompt.TEXT_FONT_SIZE),
		font_size = HUDBigPrompt.TEXT_FONT_SIZE
	})

	self._title:set_y(70)
end

function HUDBigPrompt:_create_description()
	self._description = self._object:text({
		valign = "scale",
		name = "big_prompt_description",
		vertical = "bottom",
		align = "center",
		text = "DESCRIPTION",
		halign = "scale",
		layer = self._background:layer() + 1,
		w = self._object:w(),
		h = self._object:h(),
		color = HUDBigPrompt.DEFAULT_TEXT_COLOR,
		font = HUDBigPrompt.DESCRIPTION_FONT,
		font_size = HUDBigPrompt.DESCRIPTION_FONT_SIZE
	})
end

function HUDBigPrompt:_create_icon()
	self._icon = self._object:bitmap({
		valign = "scale",
		name = "big_prompt_icon",
		halign = "scale",
		layer = self._background:layer(),
		w = HUDBigPrompt.ICON_SIZE,
		h = HUDBigPrompt.ICON_SIZE
	})

	self._icon:set_center_x(self._object:w() / 2)
	self._icon:set_bottom(self._background:y() - HUDBigPrompt.ICON_OFFSET)
end

function HUDBigPrompt:_create_flares(color)
	color = color or HUDBigPrompt.DEFAULT_TEXT_COLOR:with_alpha(0.65)
	self._flare_panel = self._object:panel({
		name = "big_prompt_flare_panel",
		layer = self._icon:layer() - 1,
		w = HUDBigPrompt.FLARES_SIZE,
		h = HUDBigPrompt.FLARES_SIZE
	})

	self._flare_panel:set_center(self._icon:center())

	self._lens_glint = self._flare_panel:bitmap({
		blend_mode = "add",
		alpha = 0.65,
		name = "big_prompt_glint",
		rotation = 360,
		color = color,
		w = self._flare_panel:w(),
		h = self._flare_panel:h(),
		texture = tweak_data.gui.icons.lens_glint.texture,
		texture_rect = tweak_data.gui.icons.lens_glint.texture_rect
	})
	self._lens_orbs = self._flare_panel:bitmap({
		rotation = 360,
		blend_mode = "add",
		name = "loot_screen_orbs",
		color = color,
		w = self._flare_panel:w(),
		h = self._flare_panel:h(),
		texture = tweak_data.gui.icons.lens_orbs.texture,
		texture_rect = tweak_data.gui.icons.lens_orbs.texture_rect
	})
	self._lens_shimmer = self._flare_panel:bitmap({
		rotation = 360,
		blend_mode = "add",
		name = "big_prompt_iris",
		color = color,
		w = self._flare_panel:w(),
		h = self._flare_panel:h(),
		texture = tweak_data.gui.icons.lens_shimmer.texture,
		texture_rect = tweak_data.gui.icons.lens_shimmer.texture_rect
	})
	self._lens_spike_ball = self._flare_panel:bitmap({
		rotation = 360,
		blend_mode = "add",
		name = "big_prompt_spike_ball",
		color = color,
		w = self._flare_panel:w(),
		h = self._flare_panel:h(),
		texture = tweak_data.gui.icons.lens_spike_ball.texture,
		texture_rect = tweak_data.gui.icons.lens_spike_ball.texture_rect
	})
	local center_x = self._flare_panel:w() / 2
	local center_y = self._flare_panel:h() / 2

	self._lens_glint:set_center(center_x, center_y)
	self._lens_orbs:set_center(center_x, center_y)
	self._lens_shimmer:set_center(center_x, center_y)
	self._lens_spike_ball:set_center(center_x, center_y)
end

function HUDBigPrompt:_remove_flares()
	if self._flare_panel then
		self._flare_panel:stop()
		self._object:remove(self._flare_panel)

		self._flare_panel = nil
	end
end

function HUDBigPrompt:show_prompt(params)
	if not params or not params.id then
		Application:error("[HUDBigPrompt:show_prompt] Attempted to show prompt without params or id")

		return
	end

	if self._active_id == params.id then
		if params.duration then
			managers.queued_tasks:unqueue("HUDBigPrompt:hide")
			managers.queued_tasks:queue("HUDBigPrompt:hide", self.hide_prompt, self, params.id, params.duration, nil, true)
		end

		return
	end

	self._prompt_queue = self._prompt_queue or {}

	if self._active_id then
		if params.priority then
			table.insert(self._prompt_queue, 1, params)
			self:hide_prompt(self._active_id)
		else
			table.insert(self._prompt_queue, params)
		end

		return
	end

	self:_show_prompt(params)
end

function HUDBigPrompt:_show_prompt(params)
	self._active_id = params.id

	self:_layout_prompt(params)
	self._title:stop()
	self._title:animate(callback(self, self, "_animate_show"))

	if params.duration then
		managers.queued_tasks:queue("HUDBigPrompt:hide", self.hide_prompt, self, params.id, params.duration, nil, true)
	end
end

function HUDBigPrompt:hide_prompt(id)
	if self._active_id ~= id then
		return
	end

	local index = 1

	while self._prompt_queue and index <= #self._prompt_queue do
		if self._prompt_queue[index].id == id then
			table.remove(self._prompt_queue, index)

			return
		else
			index = index + 1
		end
	end

	if managers.queued_tasks:has_task("HUDBigPrompt:hide") then
		managers.queued_tasks:unqueue("HUDBigPrompt:hide")
	end

	self._title:stop()
	self._title:animate(callback(self, self, "_animate_hide"))
end

function HUDBigPrompt:_prompt_done()
	self._active_id = nil
	local queued = table.remove(self._prompt_queue, 1)

	if queued then
		setup:add_end_frame_clbk(callback(self, self, "show_prompt", queued))
	end
end

function HUDBigPrompt:cleanup()
	self._object:set_visible(false)
	self._object:set_alpha(0)
	self._title:stop()
	self:_remove_flares()

	self._prompt_queue = {}
	self._active_id = nil
end

function HUDBigPrompt:set_x(x)
	self._object:set_x(x)
end

function HUDBigPrompt:set_y(y)
	self._object:set_y(y)
end

function HUDBigPrompt:w()
	return self._object:w()
end

function HUDBigPrompt:h()
	return self._object:h()
end

function HUDBigPrompt:_layout_prompt(params)
	self:_remove_flares()
	self._title:set_text(params.title or params.text or "")
	self._description:set_text(params.description or "")

	local w = select(3, self._title:text_rect())

	self._title:set_w(w)

	if params.text_color then
		self._title:set_color(params.text_color)
		self._icon:set_color(params.text_color)
	else
		self._title:set_color(HUDBigPrompt.DEFAULT_TEXT_COLOR)
		self._icon:set_color(HUDBigPrompt.DEFAULT_TEXT_COLOR)
	end

	if params.background then
		self._background:set_image(tweak_data.gui.icons[params.background].texture)
		self._background:set_texture_rect(unpack(tweak_data.gui.icons[params.background].texture_rect))
	else
		self._background:set_image(tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture)
		self._background:set_texture_rect(unpack(tweak_data.gui.icons[HUDBigPrompt.DEFAULT_BACKGROUND].texture_rect))
	end

	self._background:set_center_x(self._object:w() / 2)
	self._background:set_y(70)

	if params.icon then
		local full_gui = tweak_data.gui:get_full_gui_data(params.icon)

		self._icon:set_image(full_gui.texture)
		self._icon:set_texture_rect(unpack(full_gui.texture_rect))
		self._icon:set_w(tweak_data.gui:icon_w(params.icon))
		self._icon:set_h(tweak_data.gui:icon_h(params.icon))
		self._icon:set_color(full_gui.color or params.text_color or HUDBigPrompt.DEFAULT_TEXT_COLOR)

		if params.flares then
			self._icon:set_center_x(self._object:w() / 2)
			self._icon:set_bottom(self._background:y() - HUDBigPrompt.ICON_OFFSET)
		else
			self._icon:set_center_x(self._title:x() - self._icon:w() / 2 - 4)
			self._icon:set_center_y(self._title:center_y())
		end
	end

	self._icon:set_visible(params.icon)

	self._title_center = params.icon and not params.flares and self._object:w() / 2 + self._icon:w() / 2 or self._object:w() / 2

	if params.flares then
		self:_create_flares(params.text_color)
		self._flare_panel:stop()
		self._flare_panel:animate(callback(self, self, "_animate_lens_flares"))
	end
end

function HUDBigPrompt:_animate_lens_flares()
	local t = 0

	while true do
		local dt = coroutine.yield()
		t = t + dt

		self._lens_glint:rotate(math.random() * 0.06 + 0.1)
		self._lens_shimmer:rotate(math.random() * -0.08 - 0.13)
		self._lens_spike_ball:rotate(math.random() * 0.11 + 0.06)
	end
end

function HUDBigPrompt:_animate_show(text_control)
	local duration = 0.2
	local t = 0

	self._object:set_visible(true)
	self._object:set_alpha(0)
	self._title:set_center_x(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 1, duration)

		self._object:set_alpha(current_alpha)
		self._title:set_center_x(math.lerp(0, self._title_center, current_alpha))

		if not self._flare_panel then
			self._icon:set_center_x(self._title:x() - self._icon:w() / 2 - 4)
		end
	end

	self._object:set_alpha(1)
	self._title:set_center_x(self._title_center)

	if not self._flare_panel then
		self._icon:set_center_x(self._title:x() - self._icon:w() / 2 - 4)
	end
end

function HUDBigPrompt:_animate_hide()
	local fade_out_duration = 0.3
	local t = (1 - self._object:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 1, -1, fade_out_duration)

		self._object:set_alpha(current_alpha)
		self._title:set_center_x(math.lerp(self._title_center, self._object:w(), 1 - current_alpha))

		if not self._flare_panel then
			self._icon:set_center_x(self._title:x() - self._icon:w() / 2 - 4)
		end
	end

	self._object:set_visible(false)
	self._object:set_alpha(0)
	self._title:set_center_x(self._object:w())

	if not self._flare_panel then
		self._icon:set_center_x(self._title:x() - self._icon:w() / 2 - 4)
	end

	self:_remove_flares()
	self:_prompt_done()
end
