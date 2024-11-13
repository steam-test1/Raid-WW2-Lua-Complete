RaidGUIControlVideo = RaidGUIControlVideo or class(RaidGUIControl)

function RaidGUIControlVideo:init(parent, params)
	RaidGUIControlVideo.super.init(self, parent, params)

	self._object = self._panel:get_engine_panel():video(self._params)

	managers.video:add_video(self._object)
	managers.video:add_updator(self._params.video, callback(self, self, "_update"))

	self._safe_rect_workspace = Overlay:gui():create_screen_workspace()

	managers.gui_data:layout_workspace(self._safe_rect_workspace)

	local safe_panel = self._safe_rect_workspace:panel()

	safe_panel:set_layer(self._panel:layer() + 10)

	local font_size = tweak_data.gui.font_sizes.size_24
	self._subtitle = safe_panel:text({
		text = "",
		font = nil,
		font_size = nil,
		layer = nil,
		color = nil,
		wrap = true,
		align = "center",
		vertical = "center",
		h = 64,
		w = 736,
		y = 778,
		x = 510,
		color = tweak_data.gui.colors.light_grey,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed_outlined_24, font_size),
		font_size = font_size,
		layer = safe_panel:layer() + 1
	})
end

function RaidGUIControlVideo:_update(t, dt)
	if not alive(self._object) then
		self:destroy()

		return
	end

	if not managers.user:get_setting("subtitle") then
		self._subtitle:set_text("")

		return
	end

	local video_t = self._object:time()
	local subtitle = tweak_data.subtitles:get_subtitle(self._params.video, video_t)

	self._subtitle:set_text(subtitle)
end

function RaidGUIControlVideo:destroy()
	managers.video:remove_video(self._object)
	managers.video:remove_updator(self._params.video)
	Overlay:gui():destroy_workspace(self._safe_rect_workspace)
end

function RaidGUIControlVideo:loop_count()
	return self._object:loop_count()
end

function RaidGUIControlVideo:pause()
	return self._object:pause()
end

function RaidGUIControlVideo:play()
	return self._object:play()
end

function RaidGUIControlVideo:video_height()
	return self._object:video_height()
end

function RaidGUIControlVideo:video_width()
	return self._object:video_width()
end

function RaidGUIControlVideo:alive()
	return self._object and self._object:alive()
end
