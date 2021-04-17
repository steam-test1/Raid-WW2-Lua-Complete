TvGui = TvGui or class()

-- Lines 4-21
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

-- Lines 23-25
function TvGui:add_workspace(gui_object)
	self._ws = self._new_gui:create_object_workspace(0, 0, gui_object, Vector3(0, 0, 0))
end

-- Lines 27-31
function TvGui:setup()
	self._video_panel = self._ws:panel():video({
		loop = true,
		visible = true,
		layer = 10,
		video = self._video
	})

	self._video_panel:set_render_template(Idstring("gui:DIFFUSE_TEXTURE:FULLBRIGHT"))
end

-- Lines 33-36
function TvGui:set_visible(visible)
	self._video_panel:set_visible(visible)
	self._unit:set_visible(visible)
end

-- Lines 38-40
function TvGui:start()
	self._video_panel:play()
end

-- Lines 42-44
function TvGui:pause()
	self._video_panel:pause()
end

-- Lines 46-49
function TvGui:stop()
	self._video_panel:pause()
	self._video_panel:rewind()
end

-- Lines 51-59
function TvGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end

	managers.raid_menu:unregister_background_unit(self._unit)
end
