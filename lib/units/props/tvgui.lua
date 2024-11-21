TvGui = TvGui or class()

function TvGui:init(unit)
	self._unit = unit

	managers.raid_menu:register_background_unit(self._unit)

	self._gui_object = self._gui_object or "gui_name"
	self._new_gui = World:newgui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
	self._unit:set_extension_update_enabled(Idstring("tv_gui"), false)
	self:set_visible(Application:editor())
	self:pause()
end

function TvGui:add_workspace(gui_object)
	self._ws = self._new_gui:create_object_workspace(0, 0, gui_object, Vector3(0, 0, 0))
end

function TvGui:setup()
	self._video_panel = self._ws:panel():video({
		loop = true,
		visible = true,
		layer = 10,
		video = self._video
	})

	self._video_panel:set_render_template(Idstring("gui:DIFFUSE_TEXTURE:FULLBRIGHT"))
end

function TvGui:set_visible(visible)
	self._video_panel:set_visible(visible)
	self._unit:set_visible(visible)
end

function TvGui:start()
	self._video_panel:play()
end

function TvGui:pause()
	self._video_panel:pause()
end

function TvGui:stop()
	self._video_panel:pause()
	self._video_panel:rewind()
end

function TvGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end

	managers.raid_menu:unregister_background_unit(self._unit)
end
