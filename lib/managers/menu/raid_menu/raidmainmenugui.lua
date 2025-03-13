RaidMainMenuGui = RaidMainMenuGui or class(RaidGuiBase)
RaidMainMenuGui.WIDGET_PANEL_Y = 256
RaidMainMenuGui.WIDGET_PANEL_W = 576
RaidMainMenuGui.WIDGET_PANEL_H = 256

function RaidMainMenuGui:init(ws, fullscreen_ws, node, component_name)
	RaidMainMenuGui.super.init(self, ws, fullscreen_ws, node, component_name)
	managers.menu:mark_main_menu(true)

	if RaidMenuCallbackHandler:is_in_main_menu() then
		managers.raid_menu:show_background_video()
	else
		managers.raid_menu:show_background()
	end

	self:_mod_overrides_warning()
	self._list_menu:show()
end

function RaidMainMenuGui:close()
	if self._closing then
		return
	end

	self._closing = true

	managers.system_event_listener:remove_listener("main_menu_drop_in")
	managers.system_event_listener:remove_listener("main_menu_drop_out")
	self._list_menu:set_selected(false)
	RaidMainMenuGui.super.close(self)
end

function RaidMainMenuGui:_mod_overrides_warning()
	if RaidMenuCallbackHandler:is_in_main_menu() and SystemFS:exists(Application:base_path() .. "assets/mod_overrides") then
		managers.menu:show_mod_overrides_warning_dialog({
			callback_yes = callback(self, self, "_mod_overrides_warning_callback_yes_function"),
			callback_no = callback(self, self, "_mod_overrides_warning_callback_no_function")
		})
	end
end

function RaidMainMenuGui:_mod_overrides_warning_callback_yes_function()
	SystemFS:view_mod_overrides_folder()
end

function RaidMainMenuGui:_mod_overrides_warning_callback_no_function()
end

function RaidMainMenuGui:_setup_properties()
	RaidMainMenuGui.super._setup_properties(self)

	self._background = "ui/backgrounds/raid_main_bg_hud"
end

function RaidMainMenuGui:_layout()
	self._display_invite_widget = not IS_PC

	RaidMainMenuGui.super._layout(self)
	self:_layout_title_logo()
	self:_layout_list_menu()
	self:_layout_version_id()

	local playing_tutorial = false

	if managers.raid_job and managers.raid_job:is_in_tutorial() then
		playing_tutorial = true
	end

	if not playing_tutorial and (managers.platform:rich_presence() == "MPPlaying" or managers.platform:rich_presence() == "MPLobby") then
		Application:trace("[RaidMainMenuGui:_layout] MPPlaying!!")
		self:_layout_kick_mute_widget()
		managers.system_event_listener:add_listener("main_menu_drop_in", {
			CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_DROP_IN
		}, callback(self, self, "_layout_kick_mute_widget"))
		managers.system_event_listener:add_listener("main_menu_drop_out", {
			CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_DROP_OUT
		}, callback(self, self, "_layout_kick_mute_widget"))
	end
end

function RaidMainMenuGui:_layout_title_logo()
	self._title_label = self._root_panel:text({
		y = 0,
		x = 0,
		text = "",
		h = 64,
		w = self._root_panel:w(),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.size_56
	})
	self._title_icon = self._root_panel:bitmap({
		y = 0,
		x = 0,
		h = 64,
		w = 64,
		texture = tweak_data.gui.icons.missions_camp.texture,
		texture_rect = tweak_data.gui.icons.missions_camp.texture_rect
	})
	local logo_texture, logo_texture_rect = nil
	local event_data = managers.event_system:active_event_data()
	local is_freeweek = Steam:is_subscribed_from_free_weekend()

	if is_freeweek then
		logo_texture = tweak_data.gui.icons.raid_logo_small.texture
		logo_texture_rect = tweak_data.gui.icons.raid_logo_small.texture_rect
	elseif event_data and event_data.game_logo then
		logo_texture = event_data.game_logo.texture
		logo_texture_rect = event_data.game_logo.texture_rect
	elseif managers.dlc:is_dlc_unlocked(DLCTweakData.DLC_NAME_SPECIAL_EDITION) then
		logo_texture = tweak_data.gui.icons.raid_se_logo_small.texture
		logo_texture_rect = tweak_data.gui.icons.raid_se_logo_small.texture_rect
	else
		logo_texture = tweak_data.gui.icons.raid_logo_small.texture
		logo_texture_rect = tweak_data.gui.icons.raid_logo_small.texture_rect
	end

	self._raid_logo_small = self._root_panel:image({
		y = 0,
		x = 0,
		name = "raid_logo_small",
		texture = logo_texture,
		texture_rect = logo_texture_rect
	})

	self._raid_logo_small:set_right(self._root_panel:w())

	if RaidMenuCallbackHandler:is_in_main_menu() then
		self._title_icon:hide()
		self._title_label:set_x(0)
		self._title_label:set_text(self:translate("menu_main_title", true))
		self._title_label:set_color(tweak_data.gui.colors.raid_red)
		self._raid_logo_small:show()
	elseif RaidMenuCallbackHandler:is_in_camp() then
		self._title_icon:set_image(tweak_data.gui.icons.missions_camp.texture)
		self._title_icon:set_texture_rect(unpack(tweak_data.gui.icons.missions_camp.texture_rect))
		self._title_icon:show()
		self._title_label:set_x(90)
		self._title_label:set_text(self:translate(tweak_data.operations.missions.camp.name_id, true))
		self._title_label:set_color(tweak_data.gui.colors.raid_red)
		self._raid_logo_small:hide()
	elseif not RaidMenuCallbackHandler:is_in_main_menu() and not RaidMenuCallbackHandler:is_in_camp() then
		local current_job = managers.raid_job:current_job()

		if current_job and current_job.job_type == OperationsTweakData.JOB_TYPE_RAID then
			self._title_icon:set_image(tweak_data.gui.icons[current_job.icon_menu].texture)
			self._title_icon:set_texture_rect(unpack(tweak_data.gui.icons[current_job.icon_menu].texture_rect))
			self._title_icon:show()
			self._title_label:set_x(90)
			self._title_label:set_text(self:translate(current_job.name_id, true))
			self._title_label:set_color(tweak_data.gui.colors.raid_red)
		elseif current_job and current_job.job_type == OperationsTweakData.JOB_TYPE_OPERATION then
			self._title_icon:set_image(tweak_data.gui.icons[current_job.icon_menu].texture)
			self._title_icon:set_texture_rect(unpack(tweak_data.gui.icons[current_job.icon_menu].texture_rect))
			self._title_icon:show()

			local operation_name = self:translate(current_job.name_id, true)
			local operation_progress = current_job.current_event .. "/" .. #current_job.events_index
			local level_name = self:translate(current_job.events[current_job.events_index[current_job.current_event]].name_id, true)

			self._title_label:set_x(90)
			self._title_label:set_text(operation_name .. " " .. operation_progress .. ": " .. level_name, true)
			self._title_label:set_color(tweak_data.gui.colors.raid_red)
		end

		self._raid_logo_small:hide()
	end
end

function RaidMainMenuGui:_layout_logo()
end

function RaidMainMenuGui:_layout_list_menu()
	local list_menu_params = {
		selection_enabled = true,
		vertical_spacing = 2,
		h = 972,
		w = 480,
		y = 144,
		x = 0,
		name = "list_menu",
		loop_items = true,
		item_class = RaidGUIControlListItemMenu,
		on_item_clicked_callback = callback(self, self, "_on_list_menu_item_selected"),
		data_source_callback = callback(self, self, "_list_menu_data_source"),
		on_menu_move = {
			right = Network:multiplayer() and (IS_XB1 and "gamercard_button_1" or "mute_button_1")
		}
	}
	self._list_menu = self._root_panel:create_custom_control(RaidGUIControlSingleSelectList, list_menu_params)

	self._list_menu:set_selected(true)
end

function RaidMainMenuGui:_layout_version_id()
	local text = ""
	local debug_show_all = false
	local GAP = " | "

	if IS_STEAM then
		text = NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY or "Network Key Missing!"
	elseif IS_PC then
		text = NetworkMatchMaking._BUILD_SEARCH_INTEREST_KEY or "Network Key Missing!"
	end

	text = text .. GAP .. (Application:branch() or "unknown")

	if Application:is_modded() or debug_show_all then
		text = text .. GAP .. "modified"
	end

	local item_params = {
		vertical = "bottom",
		name = "version_id",
		alpha = 0.33,
		h = 100,
		w = 600,
		y = self._root_panel:h() - 100,
		text = text
	}
	self._version_id = self._root_panel:label(item_params)
end

function RaidMainMenuGui:_layout_kick_mute_widget()
	if self._widget_panel then
		self._widget_panel:clear()
	else
		local widget_panel_params = {
			valign = "top",
			name = "widget_panel",
			halign = "right",
			y = RaidMainMenuGui.WIDGET_PANEL_Y,
			w = RaidMainMenuGui.WIDGET_PANEL_W,
			h = RaidMainMenuGui.WIDGET_PANEL_H
		}
		self._widget_panel = self._root_panel:panel(widget_panel_params)

		self._widget_panel:set_right(self._root_panel:w())
	end

	if not alive(self._widget_label_panel) then
		local label_panel_params = {
			halign = "scale",
			visible = false,
			h = 64,
			name = "widget_label_panel"
		}
		self._widget_label_panel = self._widget_panel:get_engine_panel():panel(label_panel_params)

		self._widget_label_panel:set_right(self._widget_panel:w())
	end

	local widget_title_params = {
		vertical = "center",
		halign = "left",
		h = 64,
		x = 32,
		name = "widget_title",
		align = "left",
		w = self._widget_panel:w() - 32,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.menu_list),
		font_size = tweak_data.gui.font_sizes.menu_list,
		color = tweak_data.gui.colors.raid_dirty_white,
		text = self:translate("menu_kick_mute_widget_title", true)
	}
	local widget_title = self._widget_label_panel:text(widget_title_params)
	local widget_action_title_params = {
		vertical = "center",
		halign = "right",
		h = 64,
		w = 150,
		text = "",
		name = "widget_action_title",
		align = "right",
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.extra_small),
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_grey_effects
	}
	self._widget_action_title = self._widget_label_panel:text(widget_action_title_params)

	self._widget_action_title:set_right(self._widget_label_panel:w())
	self._widget_action_title:set_center_y(widget_title:center_y())

	if managers.network:session() then
		local peers = managers.network:session():peers()
		self._widgets = {}

		for i = 1, 3 do
			local widget_params = {
				index = i,
				name = "kick_mute_widget_" .. tostring(i),
				y = i * 64,
				menu_move = {
					left = "list_menu"
				},
				on_button_selected_callback = callback(self, self, "on_widget_button_selected"),
				on_button_unselected_callback = callback(self, self, "on_widget_button_unselected")
			}
			local widget = self._widget_panel:create_custom_control(RaidGUIControlKickMuteWidget, widget_params)

			widget:hide()
			table.insert(self._widgets, widget)
		end

		managers.menu_component:gather_controls_for_component(self._name)

		local widget_index = 1
		local invite_widget_shown = false
		local largest_w = 0

		for index, peer in pairs(peers) do
			self._widgets[widget_index]:set_peer(peer, true, Network:is_server())
			self._widgets[widget_index]:set_visible(true)
			self._widgets[widget_index]:_refresh_vote_kick_button()
			self._widget_label_panel:set_visible(true)

			local w = self._widgets[widget_index]:calculate_width()

			if largest_w < w then
				largest_w = w
			end

			widget_index = widget_index + 1
		end

		if widget_index < 4 and self._display_invite_widget then
			self._widgets[widget_index]:set_invite_widget()
			self._widgets[widget_index]:set_visible(true)
			self._widget_label_panel:set_visible(true)

			invite_widget_shown = true
			local w = self._widgets[widget_index]:calculate_width()

			if largest_w < w then
				largest_w = w
			end
		else
			widget_index = widget_index - 1
		end

		for i = 1, #self._widgets do
			local w = self._widgets[i]:calculate_width()

			if largest_w < w then
				largest_w = w
			end

			if self._widgets[i]:visible() then
				self._widgets[i]:set_move_controls(widget_index, invite_widget_shown)
			end
		end

		if not self._widget_label_panel:visible() then
			self._list_menu:set_selected(true)
		else
			self._widget_panel:set_w(largest_w)
			self._widget_panel:set_right(self._root_panel:w())

			for i = 1, #self._widgets do
				self._widgets[i]:set_w(largest_w)
			end
		end

		for id, widget_data in pairs(self._widgets) do
			widget_data:set_selected(false)
		end

		self._list_menu:set_selected(true)

		local menu_move = {}

		if self._widget_label_panel:visible() then
			if widget_index > 1 then
				if IS_XB1 then
					menu_move.right = "gamercard_button_1"
				else
					menu_move.right = "mute_button_1"
				end
			elseif self._display_invite_widget then
				menu_move.right = "invite_button_1"
			end
		end

		self._list_menu:set_menu_move_controls(menu_move)
	end
end

function RaidMainMenuGui:on_widget_button_selected(button)
	local widget_action = nil

	if button == "kick" then
		widget_action = "menu_kick_widget_label"
	elseif button == "mute" then
		widget_action = "menu_mute_widget_label"
	elseif button == "unmute" then
		widget_action = "menu_unmute_widget_label"
	elseif button == "gamercard" then
		widget_action = "menu_gamercard_widget_label"
	elseif button == "invite" then
		widget_action = "menu_widget_label_action_invite_player"
	end

	self._widget_action_title:set_text(self:translate(widget_action, true))
end

function RaidMainMenuGui:on_widget_button_unselected(button)
	self._widget_action_title:set_text("")
end

function RaidMainMenuGui:_list_menu_data_source()
	local vertical_spacing = 36
	local list_items = {
		{
			item_font_size = 60,
			callback = "raid_play_tutorial",
			icon = "menu_item_tutorial",
			item_h = 72,
			text = managers.localization:to_upper_text("menu_tutorial_hl"),
			vertical_spacing = vertical_spacing,
			availability_flags = {
				RaidGUIItemAvailabilityFlag.SHOULD_SHOW_TUTORIAL
			}
		},
		{
			item_font_size = 60,
			callback = "raid_play_online",
			icon = "menu_item_online",
			item_h = 72,
			text = managers.localization:to_upper_text("menu_play"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_MAIN_MENU,
				RaidGUIItemAvailabilityFlag.SHOULD_NOT_SHOW_TUTORIAL
			}
		},
		{
			callback = "raid_play_offline",
			icon = "menu_item_offline",
			text = managers.localization:to_upper_text("menu_play_offline"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_MAIN_MENU,
				RaidGUIItemAvailabilityFlag.SHOULD_NOT_SHOW_TUTORIAL
			}
		},
		{
			callback = "resume_game_raid",
			icon = "menu_item_resume",
			text = managers.localization:to_upper_text("menu_resume_game"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_MAIN_MENU,
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_CAMP
			}
		},
		{
			callback = "raid_skip_tutorial",
			icon = "menu_item_camp",
			text = managers.localization:to_upper_text("menu_tutorial_skip_hl"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_MAIN_MENU,
				RaidGUIItemAvailabilityFlag.SHOULD_SHOW_TUTORIAL_SKIP
			}
		},
		{
			callback = "singleplayer_restart_mission",
			icon = "menu_item_restart",
			text = managers.localization:to_upper_text("menu_restart_mission"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.SINGLEPLAYER_RESTART
			}
		},
		{
			callback = "restart_mission",
			icon = "menu_item_restart",
			text = managers.localization:to_upper_text("menu_restart_mission"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.RESTART_LEVEL_VISIBLE,
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_CAMP
			}
		},
		{
			callback = "restart_vote",
			icon = "menu_item_restart",
			text = managers.localization:to_upper_text("menu_restart_vote"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.RESTART_VOTE_VISIBLE,
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_CAMP
			}
		},
		{
			callback = "singleplayer_restart_game_to_camp",
			icon = "menu_item_camp",
			text = managers.localization:to_upper_text("menu_restart_to_camp"),
			vertical_spacing = vertical_spacing,
			availability_flags = {
				RaidGUIItemAvailabilityFlag.SINGLEPLAYER_RESTART
			}
		},
		{
			callback = "restart_to_camp",
			icon = "menu_item_camp",
			text = managers.localization:to_upper_text("menu_restart_to_camp"),
			vertical_spacing = vertical_spacing,
			availability_flags = {
				RaidGUIItemAvailabilityFlag.RESTART_LEVEL_VISIBLE
			}
		},
		{
			callback = "restart_to_camp_client",
			icon = "menu_item_camp",
			text = managers.localization:to_upper_text("menu_restart_to_camp"),
			vertical_spacing = vertical_spacing,
			availability_flags = {
				RaidGUIItemAvailabilityFlag.RESTART_LEVEL_VISIBLE_CLIENT,
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_CAMP
			}
		},
		{
			callback = "on_mission_selection_clicked",
			icon = "menu_item_missions",
			text = managers.localization:to_upper_text("menu_mission_selection"),
			breadcrumb = {
				delay = 0.2,
				category = BreadcrumbManager.CATEGORY_MISSIONS
			},
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP
			}
		},
		{
			callback = "on_select_character_profile_clicked",
			icon = "menu_item_characters",
			text = managers.localization:to_upper_text("menu_character_setup"),
			breadcrumb = {
				delay = 0.2,
				category = BreadcrumbManager.CATEGORY_CHARACTER_CUSTOMIZATION
			},
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP
			}
		},
		{
			callback = "on_weapon_select_clicked",
			icon = "menu_item_weapons",
			text = managers.localization:to_upper_text("menu_header_weapons_screen_name"),
			breadcrumb = {
				delay = 0.2,
				check_callback = callback(managers.weapon_skills, managers.weapon_skills, "has_weapon_breadcrumbs")
			},
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP
			}
		},
		{
			callback = "on_select_character_skills_clicked",
			icon = "menu_item_skills",
			text = managers.localization:to_upper_text("menu_skills"),
			vertical_spacing = vertical_spacing,
			breadcrumb = {
				delay = 0.2,
				category = BreadcrumbManager.CATEGORY_RANK_REWARD
			},
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP,
				RaidGUIItemAvailabilityFlag.IS_SINGLEPLAYER
			}
		},
		{
			callback = "on_select_character_skills_clicked",
			icon = "menu_item_skills",
			text = managers.localization:to_upper_text("menu_skills"),
			breadcrumb = {
				delay = 0.2,
				category = BreadcrumbManager.CATEGORY_RANK_REWARD
			},
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP,
				RaidGUIItemAvailabilityFlag.IS_MULTIPLAYER
			}
		},
		{
			callback = "on_select_challenge_cards_view_clicked",
			icon = "menu_item_cards",
			text = managers.localization:to_upper_text("menu_challenge_cards"),
			vertical_spacing = vertical_spacing,
			breadcrumb = {
				delay = 0.2,
				category = BreadcrumbManager.CATEGORY_CARD
			},
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP,
				RaidGUIItemAvailabilityFlag.IS_MULTIPLAYER
			}
		},
		{
			callback = "restart_to_camp_client",
			icon = "menu_item_camp",
			text = managers.localization:to_upper_text("menu_restart_to_camp"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP,
				RaidGUIItemAvailabilityFlag.RESTART_LEVEL_VISIBLE_CLIENT
			}
		},
		{
			callback = "on_multiplayer_clicked",
			icon = "menu_item_servers",
			text = managers.localization:to_upper_text("menu_servers"),
			vertical_spacing = vertical_spacing,
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_MAIN_MENU,
				RaidGUIItemAvailabilityFlag.SHOULD_NOT_SHOW_TUTORIAL
			}
		},
		{
			callback = "on_multiplayer_clicked",
			icon = "menu_item_servers",
			text = managers.localization:to_upper_text("menu_servers"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP,
				RaidGUIItemAvailabilityFlag.IS_MULTIPLAYER
			}
		},
		{
			callback = "on_options_clicked",
			icon = "menu_item_options",
			text = managers.localization:to_upper_text("menu_options")
		},
		{
			callback = "show_credits",
			icon = "menu_item_credits",
			text = managers.localization:to_upper_text("menu_credits"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_IN_MAIN_MENU
			}
		},
		{
			callback = "quit_game",
			icon = "menu_item_quit",
			text = managers.localization:to_upper_text("menu_quit"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_NOT_EDITOR,
				RaidGUIItemAvailabilityFlag.IS_IN_MAIN_MENU
			}
		},
		{
			callback = "end_game",
			icon = "menu_item_quit",
			text = managers.localization:to_upper_text("menu_quit_ingame"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_NOT_EDITOR,
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_MAIN_MENU,
				RaidGUIItemAvailabilityFlag.IS_IN_CAMP
			}
		},
		{
			callback = "end_game_mission",
			icon = "menu_item_quit",
			text = managers.localization:to_upper_text("menu_quit_ingame"),
			availability_flags = {
				RaidGUIItemAvailabilityFlag.IS_NOT_EDITOR,
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_MAIN_MENU,
				RaidGUIItemAvailabilityFlag.IS_NOT_IN_CAMP
			}
		}
	}

	return list_items
end

function RaidMainMenuGui:_on_list_menu_item_selected(data)
	if not data.callback then
		return
	end

	self._callback_handler = self._callback_handler or RaidMenuCallbackHandler:new()
	local on_click_callback = callback(self._callback_handler, self._callback_handler, data.callback)

	if on_click_callback then
		on_click_callback()
	end
end

function RaidMainMenuGui:refresh_kick_mute_widgets()
	if self._widgets then
		for index, widget in pairs(self._widgets) do
			if widget and widget:visible() then
				widget:_refresh_vote_kick_button()
			end
		end
	end
end

function RaidMainMenuGui:_animate_close()
	local duration = 0.22
	local t = 0

	self._list_menu:animate_hide()

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quadratic_in(t, 1, -1, duration)

		self._ws_panel:set_alpha(current_alpha)
	end

	self:_close()
end
