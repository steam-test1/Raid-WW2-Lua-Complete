HUDTabScreen = HUDTabScreen or class()
HUDTabScreen.X_PADDING = 10
HUDTabScreen.Y_PADDING = 10
HUDTabScreen.BACKGROUND_IMAGE = "secondary_menu"
HUDTabScreen.PROFILE_INFO_W = 384
HUDTabScreen.PROFILE_INFO_H = 160
HUDTabScreen.PROFILE_INFO_BOTTOM_OFFSET = 64
HUDTabScreen.PROFILE_NAME_FONT = tweak_data.gui.fonts.din_compressed
HUDTabScreen.PROFILE_NAME_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDTabScreen.PROFILE_LEVEL_FONT_SIZE = tweak_data.gui.font_sizes.menu_list
HUDTabScreen.PROFILE_LEVEL_RIGHT_OFFSET = 22
HUDTabScreen.TIMER_W = 512
HUDTabScreen.TIMER_H = 64
HUDTabScreen.TIMER_FONT = tweak_data.gui.fonts.din_compressed
HUDTabScreen.TIMER_FONT_SIZE = tweak_data.gui.font_sizes.size_56
HUDTabScreen.TIMER_Y = 0
HUDTabScreen.TIMER_ICON = "ico_time"
HUDTabScreen.TIMER_ICON_TEXT_DISTANCE = 25
HUDTabScreen.TIMER_PADDING_LEFT = 32
HUDTabScreen.DIFFICULTY_H = 64
HUDTabScreen.DIFFICULTY_FONT = tweak_data.gui.fonts.din_compressed
HUDTabScreen.DIFFICULTY_FONT_SIZE = tweak_data.gui.font_sizes.size_56
HUDTabScreen.DIFFICULTY_Y = 0
HUDTabScreen.DIFFICULTY_ICON_TEXT_DISTANCE = 10
HUDTabScreen.MISSION_INFO_Y = 0
HUDTabScreen.MISSION_INFO_W = 640
HUDTabScreen.MISSION_INFO_H = 64
HUDTabScreen.MISSION_INFO_TEXT_X = 74
HUDTabScreen.MISSION_INFO_TEXT_Y = -2
HUDTabScreen.MISSION_INFO_TEXT_FONT = tweak_data.gui.fonts.din_compressed
HUDTabScreen.MISSION_INFO_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_56
HUDTabScreen.MISSION_INFO_TEXT_COLOR = tweak_data.gui.colors.raid_red
HUDTabScreen.LOOT_INFO_W = 416
HUDTabScreen.LOOT_INFO_H = 96
HUDTabScreen.LOOT_INFO_BOTTOM_OFFSET = 134
HUDTabScreen.LOOT_INFO_FONT = tweak_data.gui.fonts.din_compressed
HUDTabScreen.LOOT_INFO_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.extra_small
HUDTabScreen.LOOT_INFO_TITLE_COLOR = tweak_data.gui.colors.raid_grey_effects
HUDTabScreen.LOOT_INFO_VALUE_FONT_SIZE = tweak_data.gui.font_sizes.size_32
HUDTabScreen.LOOT_INFO_VALUE_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDTabScreen.LOOT_INFO_RIBBON_Y = 768
HUDTabScreen.LOOT_INFO_RIBBON_ICON = "rwd_stats_bg"
HUDTabScreen.LOOT_INFO_RIBBON_ICON_CENTER_FROM_RIGHT = 320
HUDTabScreen.LOOT_INFO_RIBBON_CENTER_Y = 800
HUDTabScreen.CARD_INFO_X = 0
HUDTabScreen.CARD_INFO_Y = 128
HUDTabScreen.CARD_INFO_W = 384
HUDTabScreen.CARD_INFO_H = 608
HUDTabScreen.CARD_INFO_TITLE_FONT = tweak_data.gui.fonts.din_compressed
HUDTabScreen.CARD_INFO_TITLE_FONT_SIZE = tweak_data.gui.font_sizes.size_24
HUDTabScreen.CARD_INFO_TITLE_COLOR = tweak_data.gui.colors.raid_dirty_white
HUDTabScreen.CARD_INFO_FAILED_TITLE_COLOR = tweak_data.gui.colors.raid_red
HUDTabScreen.NO_CARD_ICON = "card_pass"
HUDTabScreen.NO_CARD_TEXT_Y = 272
HUDTabScreen.NO_CARD_TEXT_FONT = tweak_data.gui.fonts.lato
HUDTabScreen.NO_CARD_TEXT_FONT_SIZE = tweak_data.gui.font_sizes.size_20
HUDTabScreen.CARD_Y = 48
HUDTabScreen.CARD_W = 168
HUDTabScreen.OBJECTIVES_INFO_Y = 96
HUDTabScreen.NEXT_CHALLENGE_QUEUE_ID = "tab_screen_show_next_challenge"
HUDTabScreen.NEXT_CHALLENGE_DELAY = 4

-- Lines 87-107
function HUDTabScreen:init(fullscreen_hud, hud)
	self:_create_background(fullscreen_hud)
	self:_create_map(fullscreen_hud)
	self:_create_panel(hud)
	self:_create_mission_info()
	self:_create_timer()
	self:_create_progression_timer()
	self:_create_card_info()
	self:_create_profile_info()
	self:_create_weapon_challenge_info()
	self:_create_loot_info()
	self:_create_greed_bar()
	self:_create_objectives_info(hud)
	self:set_current_greed_amount(managers.greed:current_loot_counter())
end

-- Lines 109-121
function HUDTabScreen:_create_background(fullscreen_hud)
	local background_params = {
		y = 0,
		name = "tab_screen_background",
		halign = "scale",
		alpha = 0.9,
		visible = false,
		x = 0,
		valign = "scale",
		w = fullscreen_hud.panel:w(),
		h = fullscreen_hud.panel:h(),
		color = tweak_data.gui.colors.raid_black,
		layer = tweak_data.gui.TAB_SCREEN_LAYER
	}
	self._background = fullscreen_hud.panel:rect(background_params)
end

-- Lines 123-161
function HUDTabScreen:_create_background_image()
	if self._background_image then
		self._background_image:parent():remove(self._background_image)

		self._background_image = nil
	end

	local background_image = nil

	if managers.raid_job:is_camp_loaded() then
		background_image = tweak_data.operations.missions.camp.tab_background_image
	else
		local current_job = managers.raid_job:current_job()

		if current_job then
			if current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
				background_image = tweak_data.operations.missions[current_job.job_id].tab_background_image
			else
				local current_event = current_job.events_index[current_job.current_event]
				local event_data = tweak_data.operations.missions[current_job.job_id].events[current_event]
				background_image = event_data.tab_background_image
			end
		end
	end

	if not background_image then
		return
	end

	local fullscreen_panel = self._background:parent()
	local background_image_params = {
		name = "tab_screen_background_image",
		halign = "scale",
		valign = "scale",
		texture = background_image,
		layer = self._background:layer() + 1
	}
	self._background_image = fullscreen_panel:bitmap(background_image_params)

	self._background_image:set_center_x(fullscreen_panel:w() / 2)
	self._background_image:set_center_y(fullscreen_panel:h() / 2)
end

-- Lines 204-210
function HUDTabScreen:_create_map(fullscreen_hud)
	local map_params = {
		name = "tab_map",
		layer = self._background:layer() + 1
	}
	self._map = HUDMapTab:new(fullscreen_hud.panel, map_params)
end

-- Lines 212-222
function HUDTabScreen:_create_panel(hud)
	local panel_params = {
		y = 0,
		name = "tab_screen",
		halign = "scale",
		visible = false,
		x = 0,
		valign = "scale",
		w = hud.panel:w(),
		h = hud.panel:h(),
		layer = tweak_data.gui.TAB_SCREEN_LAYER + 5
	}
	self._object = hud.panel:panel(panel_params)
end

-- Lines 224-316
function HUDTabScreen:_create_card_info()
	local card_info_panel_params = {
		halign = "left",
		name = "card_info_panel",
		valign = "top",
		x = HUDTabScreen.CARD_INFO_X,
		y = HUDTabScreen.CARD_INFO_Y,
		w = HUDTabScreen.CARD_INFO_W,
		h = HUDTabScreen.CARD_INFO_H
	}
	self._card_info_panel = self._object:panel(card_info_panel_params)
	local empty_card_panel_params = {
		halign = "scale",
		name = "empty_card_panel",
		y = 0,
		x = 0,
		valign = "scale",
		w = self._card_info_panel:w(),
		h = self._card_info_panel:h()
	}
	self._empty_card_panel = self._card_info_panel:panel(empty_card_panel_params)
	local empty_card_title_params = {
		name = "empty_card_title",
		h = 32,
		vertical = "center",
		align = "left",
		y = 0,
		x = 0,
		w = self._empty_card_panel:w(),
		font = tweak_data.gui:get_font_path(HUDTabScreen.CARD_INFO_TITLE_FONT, HUDTabScreen.CARD_INFO_TITLE_FONT_SIZE),
		font_size = HUDTabScreen.CARD_INFO_TITLE_FONT_SIZE,
		text = utf8.to_upper(managers.localization:text("hud_empty_challenge_card_title")),
		color = HUDTabScreen.CARD_INFO_TITLE_COLOR
	}
	local empty_card_title = self._empty_card_panel:text(empty_card_title_params)
	local empty_slot_texture = tweak_data.gui.icons.cc_empty_slot_small
	local empty_card_image_params = {
		name = "empty_card_image",
		x = 0,
		y = HUDTabScreen.CARD_Y,
		w = HUDTabScreen.CARD_W,
		h = tweak_data.gui:icon_h(HUDTabScreen.NO_CARD_ICON) / tweak_data.gui:icon_w(HUDTabScreen.NO_CARD_ICON) * HUDTabScreen.CARD_W,
		texture = empty_slot_texture.texture,
		texture_rect = empty_slot_texture.texture_rect
	}
	local empty_card_image = self._empty_card_panel:bitmap(empty_card_image_params)
	local empty_card_text_params = {
		name = "empty_card_text",
		wrap = true,
		align = "left",
		halign = "scale",
		vertical = "top",
		valign = "scale",
		x = empty_card_image:x() + 5,
		y = HUDTabScreen.NO_CARD_TEXT_Y + HUDTabScreen.CARD_Y,
		w = self._empty_card_panel:w(),
		h = self._empty_card_panel:h() - HUDTabScreen.NO_CARD_TEXT_Y - HUDTabScreen.CARD_Y,
		font = tweak_data.gui:get_font_path(HUDTabScreen.NO_CARD_TEXT_FONT, HUDTabScreen.NO_CARD_TEXT_FONT_SIZE),
		font_size = HUDTabScreen.NO_CARD_TEXT_FONT_SIZE,
		color = HUDTabScreen.CARD_INFO_TITLE_COLOR,
		text = managers.localization:text("hud_no_challenge_card_text")
	}
	local empty_card_text = self._empty_card_panel:text(empty_card_text_params)
	local active_card_panel_params = {
		halign = "scale",
		name = "active_card_panel",
		y = 0,
		x = 0,
		valign = "scale",
		w = self._card_info_panel:w(),
		h = self._card_info_panel:h()
	}
	self._active_card_panel = self._card_info_panel:panel(active_card_panel_params)
	local active_card_title_params = {
		name = "active_card_title",
		h = 32,
		vertical = "center",
		align = "left",
		y = 0,
		x = 0,
		w = self._active_card_panel:w(),
		font = tweak_data.gui:get_font_path(HUDTabScreen.CARD_INFO_TITLE_FONT, HUDTabScreen.CARD_INFO_TITLE_FONT_SIZE),
		font_size = HUDTabScreen.CARD_INFO_TITLE_FONT_SIZE,
		text = utf8.to_upper(managers.localization:text("hud_active_challenge_card_title")),
		color = HUDTabScreen.CARD_INFO_TITLE_COLOR
	}
	local active_card_title = self._active_card_panel:text(active_card_title_params)
	local active_card_params = {
		name = "active_card_details",
		x = 0,
		y = HUDTabScreen.CARD_Y,
		w = self._active_card_panel:w(),
		h = self._active_card_panel:h() - HUDTabScreen.CARD_Y,
		card_image_params = {
			w = HUDTabScreen.CARD_W,
			h = tweak_data.gui:icon_h(HUDTabScreen.NO_CARD_ICON) / tweak_data.gui:icon_w(HUDTabScreen.NO_CARD_ICON) * HUDTabScreen.CARD_W
		}
	}
	self._active_card = HUDCardDetails:new(self._active_card_panel, active_card_params)
end

-- Lines 318-433
function HUDTabScreen:_create_profile_info()
	local profile_info_panel_params = {
		halign = "left",
		name = "profile_info_panel",
		visible = false,
		valign = "bottom",
		y = self._object:h() - HUDTabScreen.PROFILE_INFO_BOTTOM_OFFSET - HUDTabScreen.PROFILE_INFO_H,
		w = HUDTabScreen.PROFILE_INFO_W,
		h = HUDTabScreen.PROFILE_INFO_H
	}
	self._profile_info_panel = self._object:panel(profile_info_panel_params)
	local profile_name_params = {
		name = "profile_name",
		h = 32,
		vertical = "bottom",
		align = "left",
		text = "",
		y = 0,
		x = 0,
		w = self._profile_info_panel:w(),
		font = tweak_data.gui:get_font_path(HUDTabScreen.PROFILE_NAME_FONT, HUDTabScreen.PROFILE_NAME_FONT_SIZE),
		font_size = HUDTabScreen.PROFILE_NAME_FONT_SIZE
	}
	local profile_name = self._profile_info_panel:text(profile_name_params)
	local details_panel_params = {
		is_root_panel = true,
		name = "profile_details_panel",
		y = 64,
		h = self._profile_info_panel:h() - 64
	}
	local profile_details_panel = RaidGUIPanel:new(self._profile_info_panel, details_panel_params)
	local class_info_icon_params = {
		name = "class_icon",
		w = 96,
		icon = "player_panel_class_assault",
		h = profile_details_panel:h(),
		icon_color = Color.white,
		icon_h = tweak_data.gui:icon_h("player_panel_class_assault"),
		top_offset_y = (64 - tweak_data.gui:icon_h("player_panel_class_assault")) / 2,
		text = utf8.to_upper(managers.localization:text("skill_class_assault_name")),
		text_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey
	}
	self._class_icon = profile_details_panel:info_icon(class_info_icon_params)
	local placeholder_nationality = "british"
	local nationality_info_icon_params = {
		name = "nationality_icon",
		w = 96,
		h = profile_details_panel:h(),
		icon = "ico_flag_" .. placeholder_nationality,
		icon_color = Color.white,
		icon_h = tweak_data.gui:icon_h("ico_flag_" .. placeholder_nationality),
		text = utf8.to_upper(managers.localization:text("nationality_" .. placeholder_nationality)),
		text_size = tweak_data.gui.font_sizes.size_24,
		color = tweak_data.gui.colors.raid_grey
	}
	self._nationality_icon = profile_details_panel:info_icon(nationality_info_icon_params)

	self._nationality_icon:set_center_x(profile_details_panel:w() / 2)

	local level_info_icon_params = {
		name = "level_text",
		w = 96,
		title = "6",
		title_h = 64,
		y = 7,
		h = profile_details_panel:h() - 7,
		title_size = HUDTabScreen.PROFILE_LEVEL_FONT_SIZE,
		title_color = tweak_data.gui.colors.raid_white,
		text = utf8.to_upper(managers.localization:text("hud_level")),
		text_size = tweak_data.gui.font_sizes.size_24,
		text_color = tweak_data.gui.colors.raid_grey
	}
	self._level_text = profile_details_panel:info_icon(level_info_icon_params)

	self._level_text:set_center_x(320)

	local class_icon_params = {
		name = "class_icon",
		visible = false,
		texture = tweak_data.gui.icons.player_panel_class_assault.texture,
		texture_rect = tweak_data.gui.icons.player_panel_class_assault.texture_rect
	}
	local class_icon = self._profile_info_panel:bitmap(class_icon_params)

	class_icon:set_bottom(self._profile_info_panel:h() + 3)

	local initial_nationality_icon = "player_panel_nationality_british"
	local nationality_icon_params = {
		name = "nationality_icon",
		visible = false,
		texture = tweak_data.gui.icons[initial_nationality_icon].texture,
		texture_rect = tweak_data.gui.icons[initial_nationality_icon].texture_rect
	}
	local nationality_icon = self._profile_info_panel:bitmap(nationality_icon_params)

	nationality_icon:set_bottom(self._profile_info_panel:h() + 3)
	nationality_icon:set_center_x(self._profile_info_panel:w() / 2 + 3)

	local level_text_params = {
		vertical = "bottom",
		name = "level_text",
		h = 40,
		w = 40,
		align = "center",
		text = "6",
		visible = false,
		font = tweak_data.gui:get_font_path(HUDTabScreen.PROFILE_NAME_FONT, HUDTabScreen.PROFILE_LEVEL_FONT_SIZE),
		font_size = HUDTabScreen.PROFILE_LEVEL_FONT_SIZE
	}
	local level_text = self._profile_info_panel:text(level_text_params)

	level_text:set_bottom(self._profile_info_panel:h() - 3)
	level_text:set_center_x(self._profile_info_panel:w() - HUDTabScreen.PROFILE_LEVEL_RIGHT_OFFSET)
end

-- Lines 435-438
function HUDTabScreen:_create_weapon_challenge_info()
	self._weapon_challenge_info = HUDTabWeaponChallenge:new(self._object)

	self._weapon_challenge_info:set_bottom(926)
end

-- Lines 441-475
function HUDTabScreen:_create_timer()
	local timer_panel_params = {
		halign = "right",
		name = "timer_panel",
		valign = "top",
		h = HUDTabScreen.TIMER_H
	}
	self._timer_panel = self._object:panel(timer_panel_params)

	self._timer_panel:set_right(self._object:w())

	local timer_params = {
		name = "timer",
		vertical = "top",
		align = "right",
		text = "00:00",
		y = HUDTabScreen.TIMER_Y,
		w = HUDTabScreen.TIMER_W,
		h = HUDTabScreen.TIMER_H,
		font = tweak_data.gui:get_font_path(HUDTabScreen.TIMER_FONT, HUDTabScreen.TIMER_FONT_SIZE),
		font_size = HUDTabScreen.TIMER_FONT_SIZE,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	self._timer = self._timer_panel:text(timer_params)

	self._timer:set_right(self._timer_panel:w())

	local timer_icon_params = {
		name = "timer_icon",
		valign = "center",
		halign = "left",
		texture = tweak_data.gui.icons[HUDTabScreen.TIMER_ICON].texture,
		texture_rect = tweak_data.gui.icons[HUDTabScreen.TIMER_ICON].texture_rect
	}
	local timer_icon = self._timer_panel:bitmap(timer_icon_params)

	timer_icon:set_center_y(self._timer_panel:h() / 2)

	self._last_set_time = 0

	self:set_time(0)
end

-- Lines 477-550
function HUDTabScreen:_create_progression_timer()
	local progression_timer_panel_params = {
		halign = "right",
		name = "progression_timer_panel",
		h = 64,
		valign = "top"
	}
	self._progression_timer_panel = self._object:panel(progression_timer_panel_params)

	self._progression_timer_panel:set_right(self._timer_panel:x())

	local separator_params = {
		w = 2,
		h = 52,
		halign = "right",
		valign = "center",
		color = tweak_data.gui.colors.raid_dark_grey
	}
	local separator = self._progression_timer_panel:rect(separator_params)

	separator:set_center_x(self._progression_timer_panel:w() - 48)
	separator:set_center_y(self._progression_timer_panel:h() / 2)

	local content_panel_params = {
		halign = "left",
		name = "progression_timer_content_panel",
		x = 30,
		valign = "center"
	}
	self._progression_timer_content_panel = self._progression_timer_panel:panel(content_panel_params)
	local progression_timer_icon_params = {
		name = "progression_timer_icon",
		valign = "center",
		halign = "left",
		texture = tweak_data.gui.icons.missions_raids_category_menu.texture,
		texture_rect = tweak_data.gui.icons.missions_raids_category_menu.texture_rect,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	local progression_timer_icon = self._progression_timer_content_panel:bitmap(progression_timer_icon_params)

	progression_timer_icon:set_center_y(self._progression_timer_content_panel:h() / 2)

	local is_final_unlock_cycle = managers.progression:at_final_unlock_cycle()
	local timer_title_params = {
		name = "progression_timer_title",
		vertical = "center",
		h = 32,
		halign = "left",
		x = 70,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.small),
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white,
		text = utf8.to_upper(managers.localization:text(is_final_unlock_cycle and "raid_final_raids_in_title" or "raid_next_raid_in_title"))
	}
	local timer_title = self._progression_timer_content_panel:text(timer_title_params)
	local timer_description_params = {
		name = "progression_timer_description",
		vertical = "center",
		h = 32,
		halign = "left",
		x = 70,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_20),
		font_size = tweak_data.gui.font_sizes.size_20,
		color = tweak_data.gui.colors.raid_grey_effects,
		text = utf8.to_upper(managers.localization:text(is_final_unlock_cycle and "raid_final_raids_in_description" or "raid_next_raid_in_description"))
	}
	local timer_description = self._progression_timer_content_panel:text(timer_description_params)

	timer_description:set_bottom(self._progression_timer_content_panel:h())

	local timer_params = {
		name = "progression_timer_timer",
		vertical = "center",
		h = 32,
		text = "",
		horizontal = "right",
		halign = "right",
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.small),
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_dirty_white
	}
	local timer = self._progression_timer_content_panel:text(timer_params)
end

-- Lines 552-612
function HUDTabScreen:_create_mission_info()
	local mission_info_panel_params = {
		name = "mission_info_panel",
		y = HUDTabScreen.MISSION_INFO_Y,
		w = HUDTabScreen.MISSION_INFO_W,
		h = HUDTabScreen.MISSION_INFO_H
	}
	self._mission_info_panel = self._object:panel(mission_info_panel_params)
	local temp_mission = "clear_skies"
	local temp_mission_icon = tweak_data.operations:mission_data(temp_mission).icon_menu
	local temp_mission_name = tweak_data.operations:mission_data(temp_mission).name_id
	local mission_icon_params = {
		name = "mission_icon",
		y = 0,
		x = 0,
		texture = tweak_data.gui.icons[temp_mission_icon].texture,
		texture_rect = tweak_data.gui.icons[temp_mission_icon].texture_rect
	}
	local mission_icon = self._mission_info_panel:bitmap(mission_icon_params)

	mission_icon:set_center_y(self._mission_info_panel:h() / 2)

	local mission_name_params = {
		name = "mission_name",
		vertical = "center",
		align = "left",
		x = HUDTabScreen.MISSION_INFO_TEXT_X,
		y = HUDTabScreen.MISSION_INFO_TEXT_Y,
		w = self._mission_info_panel:w() - HUDTabScreen.MISSION_INFO_TEXT_X,
		h = self._mission_info_panel:h(),
		font = tweak_data.gui:get_font_path(HUDTabScreen.MISSION_INFO_TEXT_FONT, HUDTabScreen.MISSION_INFO_TEXT_FONT_SIZE),
		font_size = HUDTabScreen.MISSION_INFO_TEXT_FONT_SIZE,
		color = HUDTabScreen.MISSION_INFO_TEXT_COLOR,
		text = utf8.to_upper(managers.localization:text(temp_mission_name))
	}
	local mission_name_text = self._mission_info_panel:text(mission_name_params)
	local mission_name_small_params = {
		name = "mission_name_small",
		h = 32,
		vertical = "center",
		align = "left",
		visible = false,
		y = 0,
		x = HUDTabScreen.MISSION_INFO_TEXT_X,
		w = self._mission_info_panel:w() - HUDTabScreen.MISSION_INFO_TEXT_X,
		font = tweak_data.gui:get_font_path(HUDTabScreen.MISSION_INFO_TEXT_FONT, tweak_data.gui.font_sizes.small),
		font_size = tweak_data.gui.font_sizes.small,
		color = HUDTabScreen.MISSION_INFO_TEXT_COLOR,
		text = utf8.to_upper(managers.localization:text(temp_mission_name))
	}
	local mission_name_small_text = self._mission_info_panel:text(mission_name_small_params)
	local difficulty_params = {
		name = "mission_difficulty",
		amount = tweak_data:number_of_difficulties()
	}
	self._difficulty_indicator = RaidGuiControlDifficultyStars:new(self._mission_info_panel, difficulty_params)

	self._difficulty_indicator:set_x(mission_name_small_text:x())
	self._difficulty_indicator:set_center_y(48)

	local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	self._difficulty_indicator:set_active_difficulty(current_difficulty)
end

-- Lines 614-754
function HUDTabScreen:_create_loot_info()
	local loot_panel_params = {
		valing = "bottom",
		name = "loot_info_panel",
		h = 96,
		halign = "right",
		w = 416,
		visible = false,
		layer = tweak_data.gui.TAB_SCREEN_LAYER + 10
	}
	self._loot_info_panel = self._object:panel(loot_panel_params)

	self._loot_info_panel:set_right(self._object:w())
	self._loot_info_panel:set_bottom(self._object:h())

	local dog_tag_panel_params = {
		visible = false,
		name = "dog_tag_panel",
		h = 96,
		halign = "left",
		w = 224,
		valign = "bottom"
	}
	self._dog_tag_panel = self._loot_info_panel:panel(dog_tag_panel_params)
	local dog_tag_icon_params = {
		name = "dog_tag_icon",
		texture = tweak_data.gui.icons.rewards_dog_tags_small.texture,
		texture_rect = tweak_data.gui.icons.rewards_dog_tags_small.texture_rect
	}
	local dog_tag_icon = self._dog_tag_panel:bitmap(dog_tag_icon_params)

	dog_tag_icon:set_center_x(48)
	dog_tag_icon:set_center_y(self._dog_tag_panel:h() / 2)

	local dog_tag_amount_params = {
		vertical = "center",
		h = 64,
		name = "dog_tag_amount",
		w = 160,
		align = "center",
		text = "0 / 0",
		font = tweak_data.gui:get_font_path(HUDTabScreen.LOOT_INFO_FONT, HUDTabScreen.LOOT_INFO_VALUE_FONT_SIZE),
		font_size = HUDTabScreen.LOOT_INFO_VALUE_FONT_SIZE,
		color = HUDTabScreen.LOOT_INFO_VALUE_COLOR
	}
	self._dog_tag_amount = self._dog_tag_panel:text(dog_tag_amount_params)

	self._dog_tag_amount:set_center_x(144)
	self._dog_tag_amount:set_center_y(32)

	local dog_tag_title_params = {
		vertical = "center",
		h = 32,
		name = "dog_tag_title",
		w = 128,
		align = "center",
		font = tweak_data.gui:get_font_path(HUDTabScreen.LOOT_INFO_FONT, HUDTabScreen.LOOT_INFO_TITLE_FONT_SIZE),
		font_size = HUDTabScreen.LOOT_INFO_TITLE_FONT_SIZE,
		color = HUDTabScreen.LOOT_INFO_TITLE_COLOR,
		text = utf8.to_upper(managers.localization:text("hud_dog_tags"))
	}
	local dog_tag_title = self._dog_tag_panel:text(dog_tag_title_params)

	dog_tag_title:set_center_x(144)
	dog_tag_title:set_center_y(64)

	self._loot_picked_up = 0
	self._loot_total = 0

	self:_refresh_loot_info()
end

-- Lines 756-759
function HUDTabScreen:_create_greed_bar()
	self._greed_bar = HUDTabGreedBar:new(self._loot_info_panel, {})

	self._greed_bar:set_right(self._loot_info_panel:w())
end

-- Lines 761-763
function HUDTabScreen:on_greed_loot_picked_up(old_progress, new_progress)
	self._greed_bar:change_progress(old_progress, new_progress)
end

-- Lines 765-767
function HUDTabScreen:set_current_greed_amount(amount)
	self._greed_bar:set_current_greed_amount(amount)
end

-- Lines 769-771
function HUDTabScreen:reset_greed_indicator()
	self._greed_bar:reset_state()
end

-- Lines 773-777
function HUDTabScreen:_create_objectives_info(hud)
	self._objectives = HUDObjectivesTab:new(self._object)

	self._objectives:set_x(self._object:w() - self._objectives:w())
	self._objectives:set_y(HUDTabScreen.OBJECTIVES_INFO_Y)
end

-- Lines 779-781
function HUDTabScreen:get_objectives_control()
	return self._objectives
end

-- Lines 783-840
function HUDTabScreen:_refresh_mission_info()
	local mission_icon, mission_name = nil
	local control_mission_name = self._mission_info_panel:child("mission_name")
	local control_mission_name_small = self._mission_info_panel:child("mission_name_small")

	if managers.raid_job:is_camp_loaded() then
		mission_icon = tweak_data.operations.missions.camp.icon_hud
		mission_name = tweak_data.operations.missions.camp.name_id

		control_mission_name_small:set_text(utf8.to_upper(managers.localization:text(mission_name)))

		local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

		self._difficulty_indicator:set_active_difficulty(current_difficulty)

		self._current_difficulty = current_difficulty

		control_mission_name:set_visible(false)
		control_mission_name_small:set_visible(true)
		self._difficulty_indicator:set_visible(true)
	else
		local current_job = managers.raid_job:current_job()

		if not current_job then
			self._mission_info_panel:set_visible(false)

			return
		end

		local job_id = current_job.job_id

		if current_job.job_type == OperationsTweakData.JOB_TYPE_RAID or current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION and managers.raid_job:is_camp_loaded() then
			mission_icon = current_job.icon_menu
			mission_name = utf8.to_upper(managers.localization:text(current_job.name_id))
		elseif current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION and not managers.raid_job:is_camp_loaded() then
			local current_event_id = current_job.events_index[current_job.current_event]
			local current_event_data = current_job.events[current_event_id]
			mission_icon = current_event_data.icon_menu
			mission_name = utf8.to_upper(managers.localization:text(current_job.name_id)) .. " " .. tostring(current_job.current_event) .. "/" .. tostring(#current_job.events_index) .. ": " .. utf8.to_upper(managers.localization:text(current_event_data.name_id))
		end

		control_mission_name_small:set_text(mission_name)

		local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

		self._difficulty_indicator:set_active_difficulty(current_difficulty)

		self._current_difficulty = current_difficulty

		control_mission_name:set_visible(false)
		control_mission_name_small:set_visible(true)
		self._difficulty_indicator:set_visible(true)
	end

	self._mission_info_panel:set_visible(true)
	self._mission_info_panel:child("mission_icon"):set_image(tweak_data.gui.icons[mission_icon].texture)
	self._mission_info_panel:child("mission_icon"):set_texture_rect(unpack(tweak_data.gui.icons[mission_icon].texture_rect))
end

-- Lines 842-858
function HUDTabScreen:_refresh_profile_info()
	local profile_name = managers.network:session():local_peer():name()

	self._profile_info_panel:child("profile_name"):set_text(utf8.to_upper(profile_name))

	local class = managers.skilltree:get_character_profile_class()

	self._class_icon:set_icon("player_panel_class_" .. tostring(class))
	self._class_icon:set_text("skill_class_" .. class .. "_name", {
		color = tweak_data.gui.colors.raid_grey
	})

	local nationality = managers.player:get_character_profile_nation()

	self._nationality_icon:set_icon("ico_flag_" .. nationality, {
		icon_h = tweak_data.gui:icon_h("ico_flag_" .. nationality)
	})
	self._nationality_icon:set_text("nationality_" .. nationality, {
		color = tweak_data.gui.colors.raid_grey
	})

	local player_level = managers.experience:current_level()

	self._level_text:set_title(tostring(player_level), {
		font_size = HUDTabScreen.PROFILE_LEVEL_FONT_SIZE,
		color = tweak_data.gui.colors.raid_white
	})
end

-- Lines 860-883
function HUDTabScreen:_refresh_loot_info()
	local current_job = managers.raid_job:current_job()

	self._loot_info_panel:set_visible(true)

	if not current_job then
		self._dog_tag_panel:set_visible(false)

		return
	end

	self._loot_picked_up = managers.lootdrop:picked_up_current_leg()
	self._loot_total = managers.lootdrop:loot_spawned_current_leg()

	self._dog_tag_amount:set_text(tostring(self._loot_picked_up) .. " / " .. tostring(self._loot_total))

	if self._shown == true then
		self._dog_tag_panel:set_visible(true)
	end
end

-- Lines 939-942
function HUDTabScreen:set_loot_picked_up(amount)
	self._loot_picked_up = amount

	self:_refresh_loot_info()
end

-- Lines 944-947
function HUDTabScreen:set_loot_total(amount)
	self._loot_total = amount

	self:_refresh_loot_info()
end

-- Lines 949-972
function HUDTabScreen:set_time(time)
	if math.floor(time) < self._last_set_time then
		return
	end

	self._last_set_time = time
	time = math.floor(time)
	local hours = math.floor(time / 3600)
	time = time - hours * 3600
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)
	local text = hours > 0 and string.format("%02d", hours) .. ":" or ""
	local text = text .. string.format("%02d", minutes) .. ":" .. string.format("%02d", seconds)

	self._timer:set_text(text)

	local _, _, w, _ = self._timer:text_rect()

	self._timer_panel:set_w(w + HUDTabScreen.TIMER_ICON_TEXT_DISTANCE + self._timer_panel:child("timer_icon"):w())
	self._timer_panel:set_right(self._object:w())
	self._timer:set_w(w)
	self._timer:set_right(self._timer_panel:w())
end

-- Lines 974-994
function HUDTabScreen:_refresh_card_info()
	local active_card = managers.challenge_cards:get_active_card()

	if not active_card then
		self._empty_card_panel:set_visible(true)
		self._active_card_panel:set_visible(false)
	else
		self._empty_card_panel:set_visible(false)
		self._active_card_panel:set_visible(true)
		self._active_card:set_card(active_card)

		local active_card_title = self._active_card_panel:child("active_card_title")

		if active_card.status == ChallengeCardsManager.CARD_STATUS_FAILED then
			active_card_title:set_text(utf8.to_upper(managers.localization:text("hud_active_challenge_card_failed_title")))
			active_card_title:set_color(HUDTabScreen.CARD_INFO_FAILED_TITLE_COLOR)
		else
			active_card_title:set_text(utf8.to_upper(managers.localization:text("hud_active_challenge_card_title")))
			active_card_title:set_color(HUDTabScreen.CARD_INFO_TITLE_COLOR)
		end
	end
end

-- Lines 996-1023
function HUDTabScreen:_refresh_weapon_challenge_info()
	if not managers.player:player_unit() then
		self._weapon_challenge_info:hide()
		self._profile_info_panel:set_visible(true)

		return
	end

	local equipped_weapon_slot = managers.player:player_unit():inventory():equipped_selection()

	if equipped_weapon_slot == PlayerInventory.SLOT_1 or equipped_weapon_slot == PlayerInventory.SLOT_2 then
		local equipped_weapon = managers.player:player_unit():inventory():equipped_unit():base():get_name_id()
		self._active_weapon_challenges = managers.weapon_skills:get_active_weapon_challenges_for_weapon(equipped_weapon)

		if self._active_weapon_challenges then
			self._weapon_challenge_info:set_challenges(self._active_weapon_challenges)

			self._currently_displayed_weapon_challenge = math.floor(Application:time() / HUDTabScreen.NEXT_CHALLENGE_DELAY) % #self._active_weapon_challenges
			local time_until_next_challenge = HUDTabScreen.NEXT_CHALLENGE_DELAY - (Application:time() - math.floor(Application:time() / HUDTabScreen.NEXT_CHALLENGE_DELAY) * HUDTabScreen.NEXT_CHALLENGE_DELAY)

			self:show_next_weapon_challenge(true, time_until_next_challenge)
			self._weapon_challenge_info:show()
			self._profile_info_panel:set_visible(false)

			return
		end
	end

	self._weapon_challenge_info:hide()
	self._profile_info_panel:set_visible(true)
end

-- Lines 1025-1033
function HUDTabScreen:show_next_weapon_challenge(dont_animate, next_delay)
	self._currently_displayed_weapon_challenge = self._currently_displayed_weapon_challenge % #self._active_weapon_challenges + 1

	self._weapon_challenge_info:set_challenge(self._currently_displayed_weapon_challenge, not dont_animate)

	if #self._active_weapon_challenges > 1 then
		managers.queued_tasks:queue(HUDTabScreen.NEXT_CHALLENGE_QUEUE_ID, self.show_next_weapon_challenge, self, nil, next_delay or HUDTabScreen.NEXT_CHALLENGE_DELAY, nil)
	end
end

-- Lines 1035-1065
function HUDTabScreen:show()
	self._progression_timer_shown = not managers.progression:mission_progression_completed() and managers.raid_job:played_tutorial()

	self._progression_timer_panel:set_visible(self._progression_timer_shown)

	if self._progression_timer_shown and not self._animating_cycle_completed then
		self:_layout_progression()
	end

	managers.hud:add_updator("tab", callback(self, self, "update"))

	self._shown = true

	self:_refresh_profile_info()
	self:_refresh_mission_info()
	self:_refresh_loot_info()
	self:_refresh_card_info()
	self:_refresh_weapon_challenge_info()

	local current_level = self:_get_current_player_level()

	if self:_current_level_has_map() then
		self._map:show()
	end

	self._background:set_visible(true)
	self._object:set_visible(true)

	if self._grid_panel then
		self._grid_panel:set_visible(true)
	end
end

-- Lines 1067-1120
function HUDTabScreen:_layout_progression()
	local is_final_unlock_cycle = managers.progression:at_final_unlock_cycle()
	local cycle_completed = managers.progression:have_pending_missions_to_unlock()
	local progression_completion_pending = managers.progression:mission_progression_completion_pending()
	local timer_control = self._progression_timer_content_panel:child("progression_timer_timer")
	local title_color = tweak_data.gui.colors.raid_dirty_white

	if not cycle_completed and not progression_completion_pending then
		self:_set_progress_timer_value()
		timer_control:set_visible(true)
	else
		timer_control:set_w(0)
		timer_control:set_visible(false)

		title_color = HUDTabScreen.MISSION_INFO_TEXT_COLOR
	end

	local title_text = "raid_next_raid_in_title"
	local description_text = "raid_next_raid_in_description"
	local timer_title = self._progression_timer_content_panel:child("progression_timer_title")
	local timer_description = self._progression_timer_content_panel:child("progression_timer_description")

	if is_final_unlock_cycle then
		if progression_completion_pending then
			title_text = "raid_final_unlocked_title"
			description_text = "raid_next_unlocked_description"
		else
			title_text = "raid_final_raids_in_title"
			description_text = "raid_final_raids_in_description"
		end
	elseif cycle_completed then
		title_text = "raid_next_unlocked_title"
		description_text = "raid_next_unlocked_description"
	end

	timer_title:set_text(utf8.to_upper(managers.localization:text(title_text)))
	timer_title:set_color(title_color)

	local _, _, w, _ = timer_title:text_rect()

	timer_title:set_w(w)
	timer_description:set_text(utf8.to_upper(managers.localization:text(description_text)))

	local _, _, w, _ = timer_description:text_rect()

	timer_description:set_w(w)

	local content_panel_w = timer_title:x() + math.max(timer_title:w() + timer_control:w() + 64, timer_description:w())

	self._progression_timer_content_panel:set_w(content_panel_w)
	self._progression_timer_panel:set_w(self._progression_timer_content_panel:w() + 126)

	if is_final_unlock_cycle or cycle_completed then
		self._progression_timer_panel:set_right(self._timer_panel:x())
	end
end

-- Lines 1122-1142
function HUDTabScreen:_set_progress_timer_value()
	local timer_control = self._progression_timer_content_panel:child("progression_timer_timer")
	local remaining_time = math.floor(managers.progression:time_until_next_unlock())
	local hours = math.floor(remaining_time / 3600)
	remaining_time = remaining_time - hours * 3600
	local minutes = math.floor(remaining_time / 60)
	remaining_time = remaining_time - minutes * 60
	local seconds = math.round(remaining_time)
	local text = hours > 0 and string.format("%02d", hours) .. ":" or ""
	local text = text .. string.format("%02d", minutes) .. ":" .. string.format("%02d", seconds)

	timer_control:set_text(text)

	local _, _, w, _ = timer_control:text_rect()

	timer_control:set_w(w)
	timer_control:set_right(self._progression_timer_content_panel:w())
	self._progression_timer_panel:set_right(self._timer_panel:x())
end

-- Lines 1144-1150
function HUDTabScreen:update()
	self._loot_info_panel:set_bottom(self._background:parent():h() - HUDTabScreen.LOOT_INFO_BOTTOM_OFFSET)

	if self._progression_timer_shown and not managers.progression:have_pending_missions_to_unlock() then
		self:_set_progress_timer_value()
	end
end

-- Lines 1152-1170
function HUDTabScreen:hide()
	managers.hud:remove_updator("tab")

	self._shown = false

	self._background:set_visible(false)
	self._loot_info_panel:set_visible(false)
	self._object:set_visible(false)
	self._map:hide()
	managers.queued_tasks:unqueue(HUDTabScreen.NEXT_CHALLENGE_QUEUE_ID)

	if self._grid_panel then
		self._grid_panel:set_visible(false)
	end
end

-- Lines 1172-1174
function HUDTabScreen:refresh_peers()
	self._map:refresh_peers()
end

-- Lines 1176-1178
function HUDTabScreen:add_waypoint(waypoint_data)
	self._map:add_waypoint(waypoint_data)
end

-- Lines 1180-1182
function HUDTabScreen:remove_waypoint(id)
	self._map:remove_waypoint(id)
end

-- Lines 1184-1186
function HUDTabScreen:peer_enter_vehicle(peer_id)
	self._map:peer_enter_vehicle(peer_id)
end

-- Lines 1188-1190
function HUDTabScreen:peer_exit_vehicle(peer_id)
	self._map:peer_exit_vehicle(peer_id)
end

-- Lines 1193-1195
function HUDTabScreen:is_shown()
	return self._object:visible()
end

-- Lines 1197-1205
function HUDTabScreen:_current_level_has_map()
	local player_world = self:_get_current_player_level()

	if player_world and tweak_data.levels[player_world].map then
		return true
	end

	return false
end

-- Lines 1207-1230
function HUDTabScreen:_get_current_player_level()
	local current_job = managers.raid_job:current_job()

	if not current_job or managers.raid_job:is_camp_loaded() then
		return nil
	end

	if current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
		local current_event_id = current_job.events_index[current_job.current_event]
		local current_event = current_job.events[current_event_id]

		return current_event.level_id
	elseif current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
		return current_job.level_id
	end

	return nil
end

-- Lines 1233-1236
function HUDTabScreen:on_progression_cycle_completed()
	self._progression_timer_content_panel:stop()
	self._progression_timer_content_panel:animate(callback(self, self, "animate_progression_cycle_completed"))
end

-- Lines 1238-1275
function HUDTabScreen:animate_progression_cycle_completed()
	self._animating_cycle_completed = true
	local fade_out_duration = 0.35
	local t = (1 - self._progression_timer_content_panel:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in(t, 1, -1, fade_out_duration)

		self._progression_timer_content_panel:set_alpha(current_alpha)

		local current_x = Easing.quartic_in(t, 30, -30, fade_out_duration)

		self._progression_timer_content_panel:set_x(current_x)
	end

	self._progression_timer_content_panel:set_alpha(0)
	self._progression_timer_content_panel:set_x(0)
	self:_layout_progression()

	local fade_in_duration = 0.35
	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_out(t, 0, 1, fade_in_duration)

		self._progression_timer_content_panel:set_alpha(current_alpha)

		local current_x = Easing.quartic_out(t, 0, 30, fade_in_duration)

		self._progression_timer_content_panel:set_x(current_x)
	end

	self._progression_timer_content_panel:set_alpha(1)
	self._progression_timer_content_panel:set_x(30)

	self._animating_cycle_completed = false
end
