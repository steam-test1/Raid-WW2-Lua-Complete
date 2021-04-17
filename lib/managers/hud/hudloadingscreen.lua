HUDLoadingScreen = HUDLoadingScreen or class()
HUDLoadingScreen.LOADING_TEXT_DEFAULT_Y = 832
HUDLoadingScreen.LOADING_TEXT_Y = 576
HUDLoadingScreen.LOADING_TEXT_W = 500
HUDLoadingScreen.LOADING_TEXT_H = 64
HUDLoadingScreen.LOADING_TEXT_FONT = tweak_data.gui.fonts.din_compressed
HUDLoadingScreen.LOADING_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.medium
HUDLoadingScreen.LOADING_TEXT_COLOR = tweak_data.gui.colors.raid_grey
HUDLoadingScreen.RAID_INFO_Y = 670
HUDLoadingScreen.RAID_INFO_W = 1184
HUDLoadingScreen.RAID_INFO_H = 264
HUDLoadingScreen.INFO_TITLE_Y = 0
HUDLoadingScreen.INFO_TITLE_H = 64
HUDLoadingScreen.INFO_TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDLoadingScreen.INFO_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_56
HUDLoadingScreen.INFO_TITLE_COLOR = tweak_data.gui.colors.raid_red
HUDLoadingScreen.RAID_INFO_TITLE_CENTER_Y = 48
HUDLoadingScreen.RAID_INFO_TEXT_Y = 160
HUDLoadingScreen.RAID_INFO_TEXT_FONT = tweak_data.gui.fonts.lato
HUDLoadingScreen.RAID_INFO_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.medium
HUDLoadingScreen.RAID_INFO_TEXT_COLOR = Color("878787")
HUDLoadingScreen.RAID_DIFFICULTY_CENTER_Y = 128
HUDLoadingScreen.RAID_COMPLETED_Y = 653
HUDLoadingScreen.RAID_COMPLETED_H = 328
HUDLoadingScreen.OPERATION_COMPLETED_Y = 245
HUDLoadingScreen.MISSION_COMPLETED_Y = 165
HUDLoadingScreen.MISSION_COMPLETED_H = 160
HUDLoadingScreen.MISSION_COMPLETED_FONT = tweak_data.gui.fonts.din_compressed
HUDLoadingScreen.MISSION_COMPLETED_FONT_SIZE = tweak_data.gui.font_sizes.size_84
HUDLoadingScreen.MISSION_COMPLETED_COLOR_SUCCESS = tweak_data.gui.colors.raid_grey
HUDLoadingScreen.MISSION_COMPLETED_COLOR_FAIL = tweak_data.gui.colors.raid_red
HUDLoadingScreen.MISSION_ICON_PADDING_RIGHT = 10
HUDLoadingScreen.OPERATION_INFO_Y = 576
HUDLoadingScreen.OPERATION_INFO_W = 1184
HUDLoadingScreen.OPERATION_INFO_H = 384
HUDLoadingScreen.OPERATION_EVENT_TITLE_Y = 80
HUDLoadingScreen.OPERATION_EVENT_TITLE_H = 64
HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDLoadingScreen.OPERATION_EVENT_TITLE_COLOR = Color("ececec")
HUDLoadingScreen.OPERATION_DIFFICULTY_CENTER_Y = 192
HUDLoadingScreen.OPERATION_INFO_TEXT_Y = 256
HUDLoadingScreen.OPERATION_INFO_TEXT_FONT = tweak_data.gui.fonts.lato
HUDLoadingScreen.OPERATION_INFO_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.medium
HUDLoadingScreen.OPERATION_INFO_TEXT_COLOR = Color("878787")
HUDLoadingScreen.OPERATION_PROGRESS_Y = 288
HUDLoadingScreen.OPERATION_PROGRESS_H = 32
HUDLoadingScreen.OPERATION_PROGRESS_FONT = tweak_data.gui.fonts.din_compressed
HUDLoadingScreen.OPERATION_PROGRESS_FONT_SIZE = tweak_data.gui.font_sizes.medium
HUDLoadingScreen.OPERATION_PROGRESS_COLOR = tweak_data.gui.colors.raid_grey
HUDLoadingScreen.DEFAULT_INFO_W = 1024
HUDLoadingScreen.DEFAULT_INFO_Y = 715
HUDLoadingScreen.DEFAULT_INFO_H = 320
HUDLoadingScreen.TIP_Y = 82
HUDLoadingScreen.TIP_H = 160
HUDLoadingScreen.TIP_TEXT_FONT = tweak_data.gui.fonts.lato
HUDLoadingScreen.TIP_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.medium
HUDLoadingScreen.TIP_TEXT_COLOR = Color("878787")
HUDLoadingScreen.LOADING_ICON_PANEL_H = 64
HUDLoadingScreen.LOADING_SCREEN_TIPS = {
	"tip_tactical_reload",
	"tip_weapon_effecienty",
	"tip_switch_to_sidearm",
	"tip_head_shot",
	"tip_help_bleed_out",
	"tip_steelsight",
	"tip_melee_attack",
	"tip_objectives",
	"tip_select_reward",
	"tip_shoot_in_bleed_out"
}

-- Lines 84-97
function HUDLoadingScreen:init(hud)
	self._workspace = managers.gui_data:create_fullscreen_workspace()
	self._hud_panel = self._workspace:panel()
	self._state = "hidden"
	self._panel = self._hud_panel:panel({
		valign = "scale",
		name = "black_screen_panel",
		y = 0,
		halign = "scale",
		x = 0,
		layer = 65000,
		w = self._hud_panel:w(),
		h = self._hud_panel:h()
	})
	self._black = self._panel:rect({
		name = "loading_screen_black_rect",
		halign = "scale",
		alpha = 0,
		y = 0,
		x = 0,
		valign = "scale",
		w = self._panel:w(),
		h = self._panel:h(),
		color = Color.black
	})

	self:_create_loading_icon()

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func(callback(self, self, "on_resolution_changed"))
end

-- Lines 140-150
function HUDLoadingScreen:_create_loading_icon()
	local saferect_data = managers.gui_data:safe_scaled_size()
	local saferect_y = (self._panel:h() - saferect_data.h) / 2
	local loading_icon_panel_params = {
		name = "loading_icon_panel",
		x = 0,
		y = saferect_y + saferect_data.h - HUDLoadingScreen.LOADING_ICON_PANEL_H,
		w = self._panel:w(),
		h = HUDLoadingScreen.LOADING_ICON_PANEL_H
	}
	self._loading_icon_panel = self._panel:panel(loading_icon_panel_params)
	self._loading_icon = HUDSaveIcon:new(self._loading_icon_panel)
end

-- Lines 152-198
function HUDLoadingScreen:setup(data)
	self._data = data

	if self._panel then
		self:clean_up()
	end

	self._bg = self._panel:bitmap({
		name = "loading_Screen_background",
		y = 0,
		alpha = 0,
		x = 0,
		texture = "ui/loading_screens/" .. data.background,
		layer = self._black:layer() + 1
	})
	local screen_ratio = self:_real_aspect_ratio()
	local image_ratio = self._bg:texture_width() / self._bg:texture_height()

	if screen_ratio < image_ratio then
		self._bg:set_h(self._hud_panel:h())
		self._bg:set_w(self._bg:h() * image_ratio)

		if self._panel:w() < self._bg:w() then
			self._bg:set_x(-(self._bg:w() - self._panel:w()) / 2)
		end
	else
		self._bg:set_w(self._hud_panel:w())
		self._bg:set_h(self._bg:w() / image_ratio)

		if self._panel:h() < self._bg:h() then
			self._bg:set_y(-(self._bg:h() - self._panel:h()) / 2)
		end
	end

	local current_job = data.mission

	if current_job and data.success ~= nil then
		if current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
			self:_layout_raid_finished(current_job, data.success)
		else
			self:_layout_operation_finished(current_job, data.success)
		end
	elseif current_job and current_job.level_id == tweak_data.operations:mission_data(RaidJobManager.CAMP_ID).level_id then
		self:_layout_camp()
	elseif current_job then
		if current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
			self:_layout_raid(current_job)
		elseif current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
			self:_layout_operation(current_job)
		end
	else
		self:_layout_default()
	end
end

-- Lines 200-268
function HUDLoadingScreen:_layout_raid(current_job)
	local info_panel_params = {
		alpha = 0,
		name = "info_panel",
		x = self._panel:w() / 2 - HUDLoadingScreen.RAID_INFO_W / 2,
		y = HUDLoadingScreen.RAID_INFO_Y,
		w = HUDLoadingScreen.RAID_INFO_W,
		h = HUDLoadingScreen.RAID_INFO_H,
		layer = self._bg:layer() + 1
	}
	self._info_panel = self._panel:panel(info_panel_params)
	local raid_title_panel_params = {
		name = "raid_title_panel",
		h = HUDLoadingScreen.INFO_TITLE_H,
		layer = self._info_panel:layer() + 1
	}
	local raid_title_panel = self._info_panel:panel(raid_title_panel_params)

	raid_title_panel:set_center_y(HUDLoadingScreen.RAID_INFO_TITLE_CENTER_Y)

	local raid_icon_params = {
		name = "raid_icon",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[current_job.icon_menu].texture,
		texture_rect = tweak_data.gui.icons[current_job.icon_menu].texture_rect
	}
	local raid_icon = raid_title_panel:bitmap(raid_icon_params)

	raid_icon:set_center_y(raid_title_panel:h() / 2)

	local raid_title_params = {
		name = "raid_title",
		vertical = "center",
		align = "center",
		x = raid_icon:w() + HUDLoadingScreen.MISSION_ICON_PADDING_RIGHT,
		h = raid_title_panel:h(),
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.INFO_TITLE_FONT, HUDLoadingScreen.INFO_TITLE_FONT_SIZE),
		font_size = HUDLoadingScreen.INFO_TITLE_FONT_SIZE,
		color = HUDLoadingScreen.INFO_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(current_job.name_id))
	}
	local title = raid_title_panel:text(raid_title_params)
	local _, _, w, _ = title:text_rect()

	title:set_w(w)
	raid_title_panel:set_w(title:x() + title:w())
	raid_title_panel:set_center_x(self._info_panel:w() / 2)

	local difficulty_params = {
		amount = tweak_data:number_of_difficulties()
	}
	local difficulty_indicator = RaidGuiControlDifficultyStars:new(self._info_panel, difficulty_params)

	difficulty_indicator:set_center_x(self._info_panel:w() / 2)
	difficulty_indicator:set_center_y(HUDLoadingScreen.RAID_DIFFICULTY_CENTER_Y)

	local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	difficulty_indicator:set_active_difficulty(current_difficulty)

	local raid_description_params = {
		name = "raid_description",
		vertical = "center",
		wrap = true,
		align = "center",
		y = HUDLoadingScreen.RAID_INFO_TEXT_Y,
		h = self._info_panel:h() - HUDLoadingScreen.RAID_INFO_TEXT_Y,
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.RAID_INFO_TEXT_FONT, HUDLoadingScreen.RAID_INFO_TEXT_FONT_SIZE),
		font_size = HUDLoadingScreen.RAID_INFO_TEXT_FONT_SIZE,
		color = HUDLoadingScreen.RAID_INFO_TEXT_COLOR,
		text = managers.localization:text(current_job.loading.text)
	}
	local description = self._info_panel:text(raid_description_params)
end

-- Lines 270-343
function HUDLoadingScreen:_layout_raid_finished(current_job, success)
	local info_panel_params = {
		alpha = 0,
		name = "info_panel",
		x = self._panel:w() / 2 - HUDLoadingScreen.RAID_INFO_W / 2,
		y = HUDLoadingScreen.RAID_COMPLETED_Y,
		w = HUDLoadingScreen.RAID_INFO_W,
		h = HUDLoadingScreen.RAID_COMPLETED_H,
		layer = self._bg:layer() + 1
	}
	self._info_panel = self._panel:panel(info_panel_params)
	local raid_title_panel_params = {
		name = "raid_title_panel",
		y = HUDLoadingScreen.INFO_TITLE_Y,
		h = HUDLoadingScreen.INFO_TITLE_H,
		layer = self._info_panel:layer() + 1
	}
	local raid_title_panel = self._info_panel:panel(raid_title_panel_params)
	local raid_icon_params = {
		name = "raid_icon",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[current_job.icon_menu].texture,
		texture_rect = tweak_data.gui.icons[current_job.icon_menu].texture_rect
	}
	local raid_icon = raid_title_panel:bitmap(raid_icon_params)

	raid_icon:set_center_y(raid_title_panel:h() / 2)

	local raid_title_params = {
		name = "raid_title",
		vertical = "center",
		align = "center",
		x = raid_icon:w() + HUDLoadingScreen.MISSION_ICON_PADDING_RIGHT,
		h = raid_title_panel:h(),
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.INFO_TITLE_FONT, HUDLoadingScreen.INFO_TITLE_FONT_SIZE),
		font_size = HUDLoadingScreen.INFO_TITLE_FONT_SIZE,
		color = HUDLoadingScreen.INFO_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(current_job.name_id))
	}
	local title = raid_title_panel:text(raid_title_params)
	local _, _, w, _ = title:text_rect()

	title:set_w(w)
	raid_title_panel:set_w(title:x() + title:w())
	raid_title_panel:set_center_x(self._info_panel:w() / 2)

	local difficulty_params = {
		amount = tweak_data:number_of_difficulties()
	}
	local difficulty_indicator = RaidGuiControlDifficultyStars:new(self._info_panel, difficulty_params)

	difficulty_indicator:set_center_x(self._info_panel:w() / 2)
	difficulty_indicator:set_center_y(HUDLoadingScreen.RAID_DIFFICULTY_CENTER_Y - 16)

	local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	difficulty_indicator:set_active_difficulty(current_difficulty)

	local mission_status_panel_params = {
		name = "mission_status_panel",
		y = HUDLoadingScreen.MISSION_COMPLETED_Y,
		h = HUDLoadingScreen.MISSION_COMPLETED_H
	}
	local mission_status_panel = self._info_panel:panel(mission_status_panel_params)

	mission_status_panel:set_center_x(self._info_panel:w() / 2)

	local mission_status_params = {
		wrap = true,
		align = "center",
		vertical = "top",
		name = "mission_status",
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.MISSION_COMPLETED_FONT, HUDLoadingScreen.MISSION_COMPLETED_FONT_SIZE),
		font_size = HUDLoadingScreen.MISSION_COMPLETED_FONT_SIZE,
		color = success and HUDLoadingScreen.MISSION_COMPLETED_COLOR_SUCCESS or HUDLoadingScreen.MISSION_COMPLETED_COLOR_FAIL,
		text = utf8.to_upper(managers.localization:text(success and "loading_mission_completed" or "loading_mission_failed"))
	}
	local mission_status = mission_status_panel:text(mission_status_params)
end

-- Lines 345-457
function HUDLoadingScreen:_layout_operation(current_job)
	local info_panel_params = {
		alpha = 0,
		name = "info_panel",
		x = self._panel:w() / 2 - HUDLoadingScreen.OPERATION_INFO_W / 2,
		y = HUDLoadingScreen.OPERATION_INFO_Y,
		w = HUDLoadingScreen.OPERATION_INFO_W,
		h = HUDLoadingScreen.OPERATION_INFO_H,
		layer = self._bg:layer() + 1
	}
	self._info_panel = self._panel:panel(info_panel_params)
	local operation_title_panel_params = {
		name = "raid_title_panel",
		y = HUDLoadingScreen.INFO_TITLE_Y,
		h = HUDLoadingScreen.INFO_TITLE_H,
		layer = self._info_panel:layer() + 1
	}
	local operation_title_panel = self._info_panel:panel(operation_title_panel_params)
	local operation_icon_params = {
		name = "operation_icon",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[current_job.operation_icon].texture,
		texture_rect = tweak_data.gui.icons[current_job.operation_icon].texture_rect
	}
	local operation_icon = operation_title_panel:bitmap(operation_icon_params)

	operation_icon:set_center_y(operation_title_panel:h() / 2)

	local operation_title_params = {
		name = "operation_title",
		vertical = "center",
		align = "center",
		x = operation_icon:w() + HUDLoadingScreen.MISSION_ICON_PADDING_RIGHT,
		h = operation_title_panel:h(),
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.INFO_TITLE_FONT, HUDLoadingScreen.INFO_TITLE_FONT_SIZE),
		font_size = HUDLoadingScreen.INFO_TITLE_FONT_SIZE,
		color = HUDLoadingScreen.INFO_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(current_job.operation_name_id) .. " " .. tostring(current_job.current_event) .. "/" .. tostring(current_job.number_of_events))
	}
	local title = operation_title_panel:text(operation_title_params)
	local _, _, w, _ = title:text_rect()

	title:set_w(w)
	operation_title_panel:set_w(title:x() + title:w())
	operation_title_panel:set_center_x(self._info_panel:w() / 2)

	local event_title_params = {
		name = "current_event_title",
		vertical = "center",
		align = "center",
		y = HUDLoadingScreen.OPERATION_EVENT_TITLE_Y,
		h = HUDLoadingScreen.OPERATION_EVENT_TITLE_H,
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT, HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT_SIZE),
		font_size = HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT_SIZE,
		color = HUDLoadingScreen.OPERATION_EVENT_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(current_job.progress_title_id))
	}
	local title = self._info_panel:text(event_title_params)
	local _, _, w, _ = title:text_rect()

	title:set_w(w)
	title:set_center_x(self._info_panel:w() / 2)

	local difficulty_params = {
		amount = tweak_data:number_of_difficulties()
	}
	local difficulty_indicator = RaidGuiControlDifficultyStars:new(self._info_panel, difficulty_params)

	difficulty_indicator:set_center_x(self._info_panel:w() / 2)
	difficulty_indicator:set_center_y(HUDLoadingScreen.OPERATION_DIFFICULTY_CENTER_Y)

	local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	difficulty_indicator:set_active_difficulty(current_difficulty)

	local event_description_params = {
		name = "raid_description",
		vertical = "top",
		wrap = true,
		align = "center",
		y = HUDLoadingScreen.OPERATION_INFO_TEXT_Y,
		h = self._info_panel:h() - HUDLoadingScreen.OPERATION_INFO_TEXT_Y,
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.OPERATION_INFO_TEXT_FONT, HUDLoadingScreen.OPERATION_INFO_TEXT_FONT_SIZE),
		font_size = HUDLoadingScreen.OPERATION_INFO_TEXT_FONT_SIZE,
		color = HUDLoadingScreen.OPERATION_INFO_TEXT_COLOR,
		text = managers.localization:text(current_job.loading.text)
	}
	local description = self._info_panel:text(event_description_params)
end

-- Lines 459-550
function HUDLoadingScreen:_layout_operation_finished(current_job, success)
	local info_panel_params = {
		alpha = 0,
		name = "info_panel",
		x = self._panel:w() / 2 - HUDLoadingScreen.OPERATION_INFO_W / 2,
		y = HUDLoadingScreen.OPERATION_INFO_Y,
		w = HUDLoadingScreen.OPERATION_INFO_W,
		h = HUDLoadingScreen.OPERATION_INFO_H,
		layer = self._bg:layer() + 1
	}
	self._info_panel = self._panel:panel(info_panel_params)
	local current_event = managers.raid_job:current_job().current_event
	local operation_tweak_data = tweak_data.operations.missions[managers.raid_job:current_job().job_id]
	local current_event_tweak_data = operation_tweak_data.events[managers.raid_job:current_job().events_index[current_event]]
	local operation_title_panel_params = {
		name = "raid_title_panel",
		y = HUDLoadingScreen.INFO_TITLE_Y,
		h = HUDLoadingScreen.INFO_TITLE_H,
		layer = self._info_panel:layer() + 1
	}
	local operation_title_panel = self._info_panel:panel(operation_title_panel_params)
	local operation_icon_params = {
		name = "operation_icon",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[current_job.icon_menu].texture,
		texture_rect = tweak_data.gui.icons[current_job.icon_menu].texture_rect
	}
	local operation_icon = operation_title_panel:bitmap(operation_icon_params)

	operation_icon:set_center_y(operation_title_panel:h() / 2)

	local operation_title_params = {
		name = "operation_title",
		vertical = "center",
		align = "center",
		x = operation_icon:w() + HUDLoadingScreen.MISSION_ICON_PADDING_RIGHT,
		h = operation_title_panel:h(),
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.INFO_TITLE_FONT, HUDLoadingScreen.INFO_TITLE_FONT_SIZE),
		font_size = HUDLoadingScreen.INFO_TITLE_FONT_SIZE,
		color = HUDLoadingScreen.INFO_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(operation_tweak_data.name_id) .. " " .. tostring(current_event) .. "/" .. tostring(#operation_tweak_data.events_index_template))
	}
	local title = operation_title_panel:text(operation_title_params)
	local _, _, w, _ = title:text_rect()

	title:set_w(w)
	operation_title_panel:set_w(title:x() + title:w())
	operation_title_panel:set_center_x(self._info_panel:w() / 2)

	local event_title_params = {
		name = "current_event_title",
		vertical = "center",
		align = "center",
		y = HUDLoadingScreen.OPERATION_EVENT_TITLE_Y,
		h = HUDLoadingScreen.OPERATION_EVENT_TITLE_H,
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT, HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT_SIZE),
		font_size = HUDLoadingScreen.OPERATION_EVENT_TITLE_FONT_SIZE,
		color = HUDLoadingScreen.OPERATION_EVENT_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(current_event_tweak_data.progress_title_id))
	}
	local title = self._info_panel:text(event_title_params)
	local _, _, w, _ = title:text_rect()

	title:set_w(w)
	title:set_center_x(self._info_panel:w() / 2)

	local difficulty_params = {
		amount = tweak_data:number_of_difficulties()
	}
	local difficulty_indicator = RaidGuiControlDifficultyStars:new(self._info_panel, difficulty_params)

	difficulty_indicator:set_center_x(self._info_panel:w() / 2)
	difficulty_indicator:set_center_y(HUDLoadingScreen.OPERATION_DIFFICULTY_CENTER_Y)

	local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	difficulty_indicator:set_active_difficulty(current_difficulty)

	local mission_status_panel_params = {
		name = "mission_status_panel",
		y = HUDLoadingScreen.OPERATION_COMPLETED_Y,
		h = HUDLoadingScreen.MISSION_COMPLETED_H
	}
	local mission_status_panel = self._info_panel:panel(mission_status_panel_params)

	mission_status_panel:set_center_x(self._info_panel:w() / 2)

	local mission_status_params = {
		wrap = true,
		align = "center",
		vertical = "top",
		name = "mission_status",
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.MISSION_COMPLETED_FONT, HUDLoadingScreen.MISSION_COMPLETED_FONT_SIZE),
		font_size = HUDLoadingScreen.MISSION_COMPLETED_FONT_SIZE,
		color = success and HUDLoadingScreen.MISSION_COMPLETED_COLOR_SUCCESS or HUDLoadingScreen.MISSION_COMPLETED_COLOR_FAIL,
		text = utf8.to_upper(managers.localization:text(success and "loading_mission_completed" or "loading_mission_failed"))
	}
	local mission_status = mission_status_panel:text(mission_status_params)
end

-- Lines 552-618
function HUDLoadingScreen:_layout_camp()
	local current_job = tweak_data.operations.missions.camp
	local info_panel_params = {
		alpha = 0,
		name = "info_panel",
		x = self._panel:w() / 2 - HUDLoadingScreen.DEFAULT_INFO_W / 2,
		y = HUDLoadingScreen.DEFAULT_INFO_Y,
		w = HUDLoadingScreen.DEFAULT_INFO_W,
		h = HUDLoadingScreen.DEFAULT_INFO_H,
		layer = self._bg:layer() + 1
	}
	self._info_panel = self._panel:panel(info_panel_params)
	local title_panel_params = {
		name = "raid_title_panel",
		y = HUDLoadingScreen.INFO_TITLE_Y,
		h = HUDLoadingScreen.INFO_TITLE_H,
		layer = self._info_panel:layer() + 1
	}
	local title_panel = self._info_panel:panel(title_panel_params)
	local icon_params = {
		name = "icon",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[current_job.icon_hud].texture,
		texture_rect = tweak_data.gui.icons[current_job.icon_hud].texture_rect
	}
	local icon = title_panel:bitmap(icon_params)

	icon:set_center_y(title_panel:h() / 2)

	local title_params = {
		name = "title",
		vertical = "center",
		align = "center",
		x = icon:w() + HUDLoadingScreen.MISSION_ICON_PADDING_RIGHT,
		h = title_panel:h(),
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.INFO_TITLE_FONT, HUDLoadingScreen.INFO_TITLE_FONT_SIZE),
		font_size = HUDLoadingScreen.INFO_TITLE_FONT_SIZE,
		color = HUDLoadingScreen.INFO_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text(current_job.name_id))
	}
	local title = title_panel:text(title_params)
	local _, _, w, _ = title:text_rect()

	title:set_w(w)
	title_panel:set_w(title:x() + title:w())
	title_panel:set_center_x(self._info_panel:w() / 2)

	local tip_panel_params = {
		name = "tip_panel",
		y = HUDLoadingScreen.TIP_Y,
		h = HUDLoadingScreen.TIP_H
	}
	local tip_panel = self._info_panel:panel(tip_panel_params)

	tip_panel:set_center_x(self._info_panel:w() / 2)

	local tip_params = {
		wrap = true,
		align = "center",
		vertical = "top",
		name = "tip",
		font = tweak_data.gui:get_font_path(HUDLoadingScreen.TIP_TEXT_FONT, HUDLoadingScreen.TIP_TEXT_FONT_SIZE),
		font_size = HUDLoadingScreen.TIP_TEXT_FONT_SIZE,
		color = HUDLoadingScreen.TIP_TEXT_COLOR,
		text = self:_get_random_tip()
	}
	local tip = tip_panel:text(tip_params)
end

-- Lines 620-621
function HUDLoadingScreen:_layout_default()
end

-- Lines 623-628
function HUDLoadingScreen:_get_random_tip()
	local number_of_tips = #HUDLoadingScreen.LOADING_SCREEN_TIPS
	local chosen_tip = math.random(1, number_of_tips)

	return utf8.to_upper(managers.localization:text("tip_tips")) .. " " .. managers.localization:text(HUDLoadingScreen.LOADING_SCREEN_TIPS[chosen_tip])
end

-- Lines 630-636
function HUDLoadingScreen:_fit_panel_to_screen()
	self._hud_panel:set_x(0)
	self._hud_panel:set_y(0)
	self._hud_panel:set_w(self._workspace:width())
	self._hud_panel:set_h(self._workspace:height())
	self._black:set_w(self._workspace:width())
end

-- Lines 638-640
function HUDLoadingScreen:on_resolution_changed()
	managers.gui_data:layout_fullscreen_16_9_workspace(self._workspace)
end

-- Lines 642-690
function HUDLoadingScreen:show(data, clbk)
	if self._state == "shown" then
		if clbk then
			clbk(self)
		end

		return
	end

	self:setup(data)

	if managers.queued_tasks then
		managers.queued_tasks:queue("menu_background_destruction", managers.raid_menu.clean_up_background, managers.raid_menu, nil, 0.5, nil, true)
	end

	if self._state == "hidden" then
		if data.instant then
			self._black:set_alpha(0)
			self._bg:set_alpha(1)
			self._loading_icon_panel:show()
			self._loading_icon:show({
				text = "generic_loading"
			})

			if self._info_panel then
				self._info_panel:set_alpha(1)
			end
		else
			self._black:animate(callback(self, self, "_animate_alpha"), 1, 0.5, 0, callback(self, self, "_on_faded_to_black"))
			self._bg:animate(callback(self, self, "_animate_alpha"), 1, 0.6, 0.45, clbk)

			if self._info_panel then
				self._info_panel:animate(callback(self, self, "_animate_alpha"), 1, 0.45, 0.5)
			end
		end
	elseif self._state == "black" then
		self._loading_icon_panel:show()
		self._loading_icon:show({
			text = "generic_loading"
		})
		self._bg:animate(callback(self, self, "_animate_alpha"), 1, 0.6)

		if self._info_panel then
			self._info_panel:animate(callback(self, self, "_animate_alpha"), 1, 0.45, 0.5)
		end
	end

	self._state = "shown"
end

-- Lines 692-710
function HUDLoadingScreen:hide()
	if self._state == "shown" then
		if self._info_panel then
			self._info_panel:animate(callback(self, self, "_animate_alpha"), 0, 0.6, 0)
		end

		self._bg:animate(callback(self, self, "_animate_alpha"), 0, 0.8, 0.2)
		self._black:animate(callback(self, self, "_animate_alpha"), 0, 0.6, 0.7, self.clean_up)
	elseif self._state == "black" then
		self._black:animate(callback(self, self, "_animate_alpha"), 0, 0.6, 0, self.clean_up)
	end

	self._loading_icon:hide()

	self._state = "hidden"
end

-- Lines 712-726
function HUDLoadingScreen:fade_to_black()
	if self._state == "hidden" then
		self._black:animate(callback(self, self, "_animate_alpha"), 1, 0.5, 0, self.black_alpha_full, callback(self, self, "_on_faded_to_black"))
	elseif self._state == "shown" then
		if self._info_panel then
			self._info_panel:animate(callback(self, self, "_animate_alpha"), 0, 0.6, 0)
		end

		self._bg:animate(callback(self, self, "_animate_alpha"), 0, 0.8, 0.2)
	end

	self._state = "black"
end

-- Lines 728-739
function HUDLoadingScreen:_on_faded_to_black()
	if managers.hud then
		managers.hud:on_loading_screen_faded_to_black()
	end

	if managers.warcry then
		managers.warcry:deactivate_warcry()
	end

	self._loading_icon_panel:show()
	self._loading_icon:show({
		text = "generic_loading"
	})
end

-- Lines 741-780
function HUDLoadingScreen:clean_up()
	if self._prompt then
		self._prompt:parent():remove(self._prompt)

		self._prompt = nil
	end

	if self._info_panel then
		self._info_panel:clear()
		self._info_panel:parent():remove(self._info_panel)

		self._info_panel = nil
	end

	if self._summary_background then
		self._summary_border_up:parent():remove(self._summary_border_up)

		self._summary_border_up = nil

		self._summary_border_dn:parent():remove(self._summary_border_dn)

		self._summary_border_dn = nil

		self._summary_border_lt:parent():remove(self._summary_border_lt)

		self._summary_border_lt = nil

		self._summary_border_rt:parent():remove(self._summary_border_rt)

		self._summary_border_rt = nil

		self._summary_background:parent():remove(self._summary_background)

		self._summary_background = nil
	end

	if self._bg then
		self._bg:parent():remove(self._bg)

		self._bg = nil
	end

	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func(self._resolution_changed_callback_id)
	end
end

-- Lines 782-790
function HUDLoadingScreen:_real_aspect_ratio()
	if SystemInfo:platform() == Idstring("WIN32") then
		return RenderSettings.aspect_ratio
	else
		local screen_res = Application:screen_resolution()
		local screen_pixel_aspect = screen_res.x / screen_res.y

		return screen_pixel_aspect
	end
end

-- Lines 792-851
function HUDLoadingScreen:_animate_show_summary(summary_panel, delay)
	summary_panel:set_visible(true)
	summary_panel:set_alpha(1)
	self._summary_background:set_alpha(0)
	self._summary_background:stop()
	self._summary_background:set_visible(true)

	if delay then
		wait(delay)
	end

	local t = 0
	local borders_set = false

	while t < 0.95 do
		local dt = coroutine.yield()
		t = t + dt

		if t < 0.75 then
			local w = self:_ease_out_quint(t, 0, self._summary_background:w(), 0.75)

			self._summary_border_up:set_w(w)
			self._summary_border_up:set_center_x(self._summary_background:center_x())
			self._summary_border_dn:set_w(w)
			self._summary_border_dn:set_center_x(self._summary_background:center_x())

			local h = self:_ease_out_quint(t, 0, self._summary_background:h(), 0.75)

			self._summary_border_lt:set_h(h)
			self._summary_border_lt:set_center_y(self._summary_background:center_y())
			self._summary_border_rt:set_h(h)
			self._summary_border_rt:set_center_y(self._summary_background:center_y())
		end

		if t >= 0.75 and not borders_set then
			self._summary_border_up:set_w(self._summary_background:w())
			self._summary_border_up:set_center_x(self._summary_background:center_x())
			self._summary_border_dn:set_w(self._summary_background:w())
			self._summary_border_dn:set_center_x(self._summary_background:center_x())
			self._summary_border_lt:set_h(self._summary_background:h())
			self._summary_border_lt:set_center_y(self._summary_background:center_y())
			self._summary_border_rt:set_h(self._summary_background:h())
			self._summary_border_rt:set_center_y(self._summary_background:center_y())

			borders_set = true
		end

		if t >= 0.3 and t < 0.8 then
			local curr_alpha = self:_ease_in_out_quart(t - 0.3, 0, 0.7, 0.5)

			self._summary_background:set_alpha(curr_alpha)
		end
	end

	self._summary_border_up:set_w(self._summary_background:w())
	self._summary_border_dn:set_w(self._summary_background:w())
	self._summary_border_lt:set_h(self._summary_background:h())
	self._summary_border_rt:set_h(self._summary_background:h())
	self._summary_background:set_alpha(0.7)
end

-- Lines 853-897
function HUDLoadingScreen:_animate_hide_summary(summary_panel, delay)
	summary_panel:set_visible(true)
	summary_panel:set_alpha(1)
	self._summary_background:set_alpha(1)
	self._summary_background:stop()
	self._summary_background:set_visible(true)

	if delay then
		wait(delay)
	end

	local t = 0

	while t < 0.95 do
		local dt = coroutine.yield()
		t = t + dt

		if t < 0.75 then
			local w = self:_ease_out_quint(t, self._summary_background:w() - 2, -(self._summary_background:w() - 2), 0.75)

			self._summary_border_up:set_w(w)
			self._summary_border_up:set_center_x(self._summary_background:center_x())
			self._summary_border_dn:set_w(w)
			self._summary_border_dn:set_center_x(self._summary_background:center_x())

			local h = self:_ease_out_quint(t, self._summary_background:h() + 2, -(self._summary_background:h() + 2), 0.75)

			self._summary_border_lt:set_h(h)
			self._summary_border_lt:set_center_y(self._summary_background:center_y())
			self._summary_border_rt:set_h(h)
			self._summary_border_rt:set_center_y(self._summary_background:center_y())
		end

		if t >= 0.15 and t < 0.45 then
			local curr_alpha = self:_ease_in_out_quart(t - 0.15, 0.7, -0.7, 0.3)

			self._summary_background:set_alpha(curr_alpha)
		end
	end

	self._summary_border_up:set_w(0)
	self._summary_border_dn:set_w(0)
	self._summary_border_lt:set_h(0)
	self._summary_border_rt:set_h(0)
	self._summary_background:set_alpha(0)
end

-- Lines 899-922
function HUDLoadingScreen:_animate_alpha(o, new_alpha, duration, delay, callback)
	local t = 0
	local starting_alpha = o:alpha()
	local change = new_alpha - starting_alpha

	if delay then
		wait(delay)
	end

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local curr_alpha = self:_ease_in_out_quart(t, starting_alpha, change, duration)

		o:set_alpha(curr_alpha)
	end

	o:set_alpha(starting_alpha + change)

	if callback then
		callback(self)
	end
end

-- Lines 924-939
function HUDLoadingScreen:_animate_move_background_horizontal(background)
	local t = 0
	local starting_x = 0
	local change_x = self._panel:w() - background:w()
	local duration = 20

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local curr_x = self:_linear(t, starting_x, change_x, duration)

		background:set_x(curr_x)
	end
end

-- Lines 941-943
function HUDLoadingScreen:_linear(t, starting_value, change, duration)
	return change * t / duration + starting_value
end

-- Lines 945-953
function HUDLoadingScreen:_ease_in_out_quart(t, starting_value, change, duration)
	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * t * t * t * t + starting_value
	end

	t = t - 2

	return -change / 2 * (t * t * t * t - 2) + starting_value
end

-- Lines 955-963
function HUDLoadingScreen:_ease_in_out_quadratic(t, starting_value, change, duration)
	t = t / (duration / 2)

	if t < 1 then
		return change / 2 * t * t + starting_value
	end

	t = t - 1

	return -change / 2 * (t * (t - 2) - 1) + starting_value
end

-- Lines 965-969
function HUDLoadingScreen:_ease_out_quint(t, starting_value, change, duration)
	t = t / duration
	t = t - 1

	return change * (t * t * t * t * t + 1) + starting_value
end

-- Lines 972-976
function HUDLoadingScreen:set_mid_text(text)
	local mid_text = self._blackscreen_panel:child("mid_text")

	mid_text:set_alpha(0)
	mid_text:set_text(utf8.to_upper(text))
end

-- Lines 978-980
function HUDLoadingScreen:fade_in_mid_text()
	self._blackscreen_panel:child("mid_text"):animate(callback(self, self, "_animate_fade_in"))
end

-- Lines 982-984
function HUDLoadingScreen:fade_out_mid_text()
	self._blackscreen_panel:child("mid_text"):animate(callback(self, self, "_animate_fade_out"))
end

-- Lines 986-1006
function HUDLoadingScreen:_animate_fade_in(mid_text)
	local job_panel = self._blackscreen_panel:child("job_panel")
	local t = 1
	local d = t

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local a = (d - t) / d

		mid_text:set_alpha(a)

		if job_panel then
			job_panel:set_alpha(a)
		end

		self._blackscreen_panel:set_alpha(a)
	end

	mid_text:set_alpha(1)

	if job_panel then
		job_panel:set_alpha(1)
	end

	self._blackscreen_panel:set_alpha(1)
	self:_on_faded_to_black()
end

-- Lines 1008-1027
function HUDLoadingScreen:_animate_fade_out(mid_text)
	local job_panel = self._blackscreen_panel:child("job_panel")
	local t = 1
	local d = t

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local a = t / d

		mid_text:set_alpha(a)

		if job_panel then
			job_panel:set_alpha(a)
		end

		self._blackscreen_panel:set_alpha(a)
	end

	mid_text:set_alpha(0)

	if job_panel then
		job_panel:set_alpha(0)
	end

	self._blackscreen_panel:set_alpha(0)
end
