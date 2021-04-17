RaidGUIControlBackgroundImage = RaidGUIControlBackgroundImage or class()

-- Lines 7-21
function RaidGUIControlBackgroundImage:init()
	self._workspace = managers.gui_data:create_fullscreen_workspace()
	self._panel = self._workspace:panel()
	self._base_resolution = tweak_data.gui.base_resolution
	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "resolution_changed"))
	local video_params = {
		loop = true,
		video = "movies/vanilla/raid_anim_bg"
	}
	self._object = self._panel:video(video_params)

	managers.video:add_video(self._object)
end

-- Lines 24-32
function RaidGUIControlBackgroundImage:_real_aspect_ratio()
	if SystemInfo:platform() == Idstring("WIN32") then
		return RenderSettings.aspect_ratio
	else
		local screen_res = Application:screen_resolution()
		local screen_pixel_aspect = screen_res.x / screen_res.y

		return screen_pixel_aspect
	end
end

-- Lines 34-42
function RaidGUIControlBackgroundImage:set_visible(visible)
	if visible then
		self._object:play()
	else
		self._object:pause()
	end

	self._object:set_visible(visible)
end

-- Lines 44-55
function RaidGUIControlBackgroundImage:destroy()
	Application:debug("[RaidGUIControlBackgroundImage:destroy]")

	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	end

	managers.video:remove_video(self._object)
	self._panel:clear()
	managers.gui_data:destroy_workspace(self._workspace)
end

-- Lines 58-66
function RaidGUIControlBackgroundImage:resolution_changed()
	managers.gui_data:layout_fullscreen_workspace(self._workspace)

	local x = (self._panel:w() - self._base_resolution.x) / 2
	local y = (self._panel:h() - self._base_resolution.y) / 2

	self._object:set_x(x)
	self._object:set_y(y)
end
