HUDSpecialInteraction = HUDSpecialInteraction or class()
HUDSpecialInteraction.PANEL_LAYER = 2000
HUDSpecialInteraction.BACKGROUND_IMAGE = "secondary_menu"
HUDSpecialInteraction.BACKGROUND_ALPHA = 0.35
HUDSpecialInteraction.LEGEND_FONT = tweak_data.gui.fonts.din_compressed_outlined_32
HUDSpecialInteraction.LEGEND_FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDSpecialInteraction.LEGEND_FONT_COLOR = Color.white
HUDSpecialInteraction.LEGEND_FONT_DISABLED_COLOR = tweak_data.gui.colors.raid_grey
HUDSpecialInteraction.LEGEND_X_OFFSET = 350
HUDSpecialInteraction.INTERACT_TEXT_ID = "hud_legend_lockpicking_interact"
HUDSpecialInteraction.EXIT_TEXT_ID = "hud_legend_lockpicking_exit"

function HUDSpecialInteraction:init(hud, params)
	self._hud_panel = hud.panel
	self._cooldown = 0.1
	self._tweak_data = params
	self._is_active = false

	self:_create_panel(hud)
	self:_create_background()
	self:_create_legend()
end

function HUDSpecialInteraction:_create_panel(hud)
	if hud.panel:child("special_interaction_panel") then
		hud.panel:remove(hud.panel:child("special_interaction_panel"))
	end

	self._object = hud.panel:panel({
		layer = nil,
		halign = "center",
		valign = "center",
		name = "special_interaction_panel",
		visible = false,
		layer = HUDSpecialInteraction.PANEL_LAYER
	})
end

function HUDSpecialInteraction:_create_background()
	self._workspace = managers.gui_data:create_fullscreen_workspace()
	self._bg_panel = self._workspace:panel()
	self._background = self._bg_panel:bitmap({
		layer = nil,
		halign = "center",
		valign = "center",
		alpha = nil,
		texture_rext = nil,
		name = "special_interaction_background",
		texture = nil,
		texture = tweak_data.gui.backgrounds[HUDSpecialInteraction.BACKGROUND_IMAGE].texture,
		texture_rext = tweak_data.gui.backgrounds[HUDSpecialInteraction.BACKGROUND_IMAGE].texture_rext,
		alpha = HUDSpecialInteraction.BACKGROUND_ALPHA,
		layer = HUDSpecialInteraction.PANEL_LAYER - 1
	})

	self._background:set_size(self._bg_panel:size())
end

function HUDSpecialInteraction:_create_legend()
	self._legend_interact_text = self._object:text({
		vertical = "center",
		align = "center",
		color = nil,
		font_size = nil,
		font = nil,
		name = "legend_interact_text",
		valign = "bottom",
		text = "[F] LOCKPICK",
		font = HUDSpecialInteraction.LEGEND_FONT,
		font_size = HUDSpecialInteraction.LEGEND_FONT_SIZE,
		color = HUDSpecialInteraction.LEGEND_FONT_COLOR
	})

	self._legend_interact_text:set_center_x(self._object:center_x() - HUDSpecialInteraction.LEGEND_X_OFFSET)
	self._legend_interact_text:set_center_y(self._object:center_y())

	self._legend_exit_text = self._object:text({
		vertical = "center",
		align = "center",
		color = nil,
		font_size = nil,
		font = nil,
		name = "legend_exit_text",
		valign = "bottom",
		text = "[SPACE] CANCEL",
		font = HUDSpecialInteraction.LEGEND_FONT,
		font_size = HUDSpecialInteraction.LEGEND_FONT_SIZE,
		color = HUDSpecialInteraction.LEGEND_FONT_COLOR
	})

	self._legend_exit_text:set_center_x(self._object:center_x() + HUDSpecialInteraction.LEGEND_X_OFFSET)
	self._legend_exit_text:set_center_y(self._object:center_y())
end

function HUDSpecialInteraction:show()
	self._object:set_visible(true)
	self._bg_panel:set_visible(true)

	local interact_text_id = self._tweak_data.legend_interact_text_id or HUDSpecialInteraction.INTERACT_TEXT_ID

	self._legend_interact_text:set_text(managers.localization:to_upper_text(interact_text_id, {
		BTN_INTERACT = nil,
		BTN_INTERACT = managers.localization:btn_macro("interact")
	}))

	local exit_text_id = self._tweak_data.legend_exit_text_id or HUDSpecialInteraction.EXIT_TEXT_ID

	self._legend_exit_text:set_text(managers.localization:to_upper_text(exit_text_id, {
		BTN_CANCEL = nil,
		BTN_CANCEL = managers.localization:btn_macro("jump") or utf8.char(57344)
	}))
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_show"))

	self._is_active = true
end

function HUDSpecialInteraction:hide(complete)
	self._object:stop()
	self._object:animate(callback(self, self, "_animate_hide"))

	self._is_active = false
end

function HUDSpecialInteraction:destroy()
	if alive(self._object) then
		self._object:parent():remove(self._object)
	end

	if alive(self._workspace) then
		Overlay:gui():destroy_workspace(self._workspace)
	end
end

function HUDSpecialInteraction:_play_sound(event, no_stop)
	Application:debug("[HUDSpecialInteraction:_play_sound] Playing event:", event, no_stop)

	local snd = self._tweak_data.sound_source

	if snd and event then
		if not no_stop then
			snd:stop()
		end

		snd:post_event(event)
	end
end

function HUDSpecialInteraction:_animate_show()
	local duration = 0.24
	local t = 0

	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 0, 1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress)
		managers.environment_controller:set_vignette(progress)

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)
	end

	self._object:set_alpha(1)
	self._bg_panel:set_alpha(1)
	managers.environment_controller:set_vignette(1)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x() + self.LEGEND_X_OFFSET)
	self._legend_interact_text:set_center_x(self._hud_panel:center_x() - self.LEGEND_X_OFFSET)
end

function HUDSpecialInteraction:_animate_hide()
	local duration = 0.24
	local t = 0

	self._object:set_alpha(1)
	self._bg_panel:set_alpha(1)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local progress = Easing.quadratic_out(t, 1, -1, duration)

		self._object:set_alpha(progress)
		self._bg_panel:set_alpha(progress)
		managers.environment_controller:set_vignette(progress)

		local cur_legend_delta = progress * self.LEGEND_X_OFFSET

		self._legend_exit_text:set_center_x(self._hud_panel:center_x() + cur_legend_delta)
		self._legend_interact_text:set_center_x(self._hud_panel:center_x() - cur_legend_delta)
		self._legend_exit_text:set_alpha(progress)
		self._legend_interact_text:set_alpha(progress)
	end

	self._object:set_visible(false)
	self._bg_panel:set_visible(false)
	self._object:set_alpha(0)
	self._bg_panel:set_alpha(0)
	managers.environment_controller:set_vignette(0)
	self._legend_exit_text:set_center_x(self._hud_panel:center_x())
	self._legend_interact_text:set_center_x(self._hud_panel:center_x())
end

function HUDSpecialInteraction:update(t, dt)
end

function HUDSpecialInteraction:get_type()
	return ""
end

function HUDSpecialInteraction:get_update_sound(t, dt)
	return nil
end

function HUDSpecialInteraction:check_interact()
	return true
end

function HUDSpecialInteraction:on_leave()
	return true
end

function HUDSpecialInteraction:get_interaction_data()
	return {}
end

function HUDSpecialInteraction:cooldown()
	return self._cooldown > 0
end

function HUDSpecialInteraction:check_all_complete()
	return true
end

function HUDSpecialInteraction:is_visible()
	return self._is_active
end

function HUDSpecialInteraction:get_tweak_value(key, default)
	return self._tweak_data[key] or default
end

function HUDSpecialInteraction:set_tweak_data(data)
	Application:debug("[HUDSpecialInteraction:set_tweak_data]", inspect(data))

	self._tweak_data = data
end
