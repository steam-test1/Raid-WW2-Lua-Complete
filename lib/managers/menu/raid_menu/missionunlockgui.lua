MissionUnlockGui = MissionUnlockGui or class(RaidGuiBase)
MissionUnlockGui.CONTENT_WIDTH = 1568
MissionUnlockGui.CONTENT_HEIGHT = 688
MissionUnlockGui.CONTENT_Y = 96
MissionUnlockGui.UNLOCK_BUTTON_CENTER_Y = 864

function MissionUnlockGui:init(ws, fullscreen_ws, node, component_name)
	self._selected_mission = nil

	MissionUnlockGui.super.init(self, ws, fullscreen_ws, node, component_name)

	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		local con = managers.controller:create_controller("boot_" .. index, index, false)

		con:enable()

		self._controller_list[index] = con
	end

	managers.controller:add_hotswap_callback("mission_unlock_gui", callback(self, self, "on_controller_hotswap"))
end

function MissionUnlockGui:_set_initial_data()
	self._node.components.raid_menu_header:set_screen_name("mission_unlock_screen_title")
end

function MissionUnlockGui:close()
	managers.controller:remove_hotswap_callback("mission_unlock_gui")
	Overlay:gui():destroy_workspace(self._fullscreen_ws)
	Overlay:gui():destroy_workspace(self._safe_rect_workspace)
	MissionUnlockGui.super.close(self)
end

function MissionUnlockGui:_layout()
	MissionUnlockGui.super._layout(self)
	self:_layout_contents_panel()
	self:_layout_offered_missions()
	self:_layout_unlock_button()
	self:_create_video_panels()
	self:_bind_controller_inputs()

	if managers.controller:is_using_controller() then
		self._offered_missions[1]:set_selected(true)

		self._selected_mission = self._offered_missions[1]:mission()

		self._unlock_button:hide()
	end
end

function MissionUnlockGui:_layout_contents_panel()
	local contents_panel_params = {
		halign = "scale",
		name = "contents_panel",
		valign = "scale"
	}
	self._contents_panel = self._root_panel:panel(contents_panel_params)
end

function MissionUnlockGui:_layout_offered_missions()
	local offered_missions_panel_params = {
		name = "offered_missions_panel",
		y = MissionUnlockGui.CONTENT_Y,
		w = MissionUnlockGui.CONTENT_WIDTH,
		h = MissionUnlockGui.CONTENT_HEIGHT
	}
	self._offered_missions_panel = self._contents_panel:panel(offered_missions_panel_params)

	self._offered_missions_panel:set_center_x(self._contents_panel:w() / 2)

	local pending_missions = managers.progression:pending_missions_to_unlock()
	self._offered_missions = {}
	local w = 0

	for i = 1, #pending_missions do
		local left_move, right_move = nil

		if i - 1 > 0 then
			left_move = "offered_mission_" .. tostring(i - 1)
		end

		if i + 1 <= #pending_missions then
			right_move = "offered_mission_" .. tostring(i + 1)
		end

		local offered_mission_params = {
			name = "offered_mission_" .. tostring(i),
			mission = pending_missions[i],
			on_click_callback = callback(self, self, "on_mission_chosen"),
			on_menu_move = {
				left = left_move,
				right = right_move
			}
		}
		local mission = self._offered_missions_panel:create_custom_control(RaidGUIControlMissionUnlock, offered_mission_params)

		table.insert(self._offered_missions, mission)

		w = w + mission:w()
	end

	local space_left = self._offered_missions_panel:w() - w
	local mission_padding = space_left / (#self._offered_missions - 1)
	local x = 0

	for i = 1, #self._offered_missions do
		self._offered_missions[i]:set_x(x)

		x = x + self._offered_missions[i]:w() + mission_padding
	end
end

function MissionUnlockGui:_layout_unlock_button()
	local unlock_button_params = {
		name = "unlock_button",
		layer = 1,
		text = self:translate("mission_unlock_button_text", true),
		on_click_callback = callback(self, self, "show_unlock_confirmation_prompt")
	}
	self._unlock_button = self._contents_panel:short_primary_button(unlock_button_params)

	self._unlock_button:set_center_y(MissionUnlockGui.UNLOCK_BUTTON_CENTER_Y)
	self._unlock_button:disable()
end

function MissionUnlockGui:_create_video_panels()
	self._fullscreen_ws = managers.gui_data:create_fullscreen_16_9_workspace()
	self._full_panel = self._fullscreen_ws:panel()
	self._safe_rect_workspace = Overlay:gui():create_screen_workspace()

	managers.gui_data:layout_workspace(self._safe_rect_workspace)

	self._safe_panel = self._safe_rect_workspace:panel()
end

function MissionUnlockGui:_play_control_briefing_video(mission_id)
	local potential_videos = tweak_data.operations.missions[mission_id].control_brief_video
	local chosen_index = math.random(1, #potential_videos)
	local chosen_video = potential_videos[chosen_index]
	local chosen_video_unlock_id = tweak_data.intel:get_control_video_by_path(chosen_video)

	if chosen_video_unlock_id then
		managers.unlock:unlock({
			slot = UnlockManager.SLOT_PROFILE,
			identifier = UnlockManager.CATEGORY_CONTROL_ARCHIVE
		}, {
			chosen_video_unlock_id
		})
	end

	local video_panel_params = {
		is_root_panel = true,
		layer = 100
	}
	self._video_panel = RaidGUIPanel:new(self._full_panel, video_panel_params)
	local video_panel_background_params = {
		layer = 1,
		name = "video_background",
		halign = "scale",
		valign = "scale",
		color = Color.black
	}
	local video_panel_background = self._video_panel:rect(video_panel_background_params)
	local video_params = {
		layer = 2,
		layer = self._video_panel:layer() + 1,
		video = chosen_video,
		width = self._video_panel:w()
	}
	self._control_briefing_video = self._video_panel:video(video_params)

	self._control_briefing_video:set_h(self._video_panel:w() * self._control_briefing_video:video_height() / self._control_briefing_video:video_width())
	self._control_briefing_video:set_center_y(self._video_panel:h() / 2)

	self._playing_briefing_video = true

	self._contents_panel:set_visible(false)

	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"
	local press_any_key_params = {
		name = "press_any_key_prompt",
		alpha = 0,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_32),
		font_size = tweak_data.gui.font_sizes.size_32,
		text = utf8.to_upper(managers.localization:text(press_any_key_text)),
		color = tweak_data.gui.colors.raid_dirty_white,
		layer = self._control_briefing_video:layer() + 100
	}
	local press_any_key_prompt = self._safe_panel:text(press_any_key_params)
	local _, _, w, h = press_any_key_prompt:text_rect()

	press_any_key_prompt:set_w(w)
	press_any_key_prompt:set_h(h)
	press_any_key_prompt:set_right(self._safe_panel:w() - 50)
	press_any_key_prompt:set_bottom(self._safe_panel:h() - 50)
	press_any_key_prompt:animate(callback(self, self, "_animate_show_press_any_key_prompt"))
	managers.menu_component:post_event("menu_volume_set")
	managers.music:stop()
	managers.raid_menu:register_on_escape_callback(callback(self, self, "complete_video"))
end

function MissionUnlockGui:_animate_show_press_any_key_prompt(prompt)
	local duration = 0.7
	local t = 0

	wait(3)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.85, duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.85)
end

function MissionUnlockGui:_animate_change_press_any_key_prompt(prompt)
	local fade_out_duration = 0.25
	local t = (1 - prompt:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0.85, -0.85, fade_out_duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0)

	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"

	prompt:set_text(utf8.to_upper(managers.localization:text(press_any_key_text)))

	local _, _, w, h = prompt:text_rect()

	prompt:set_w(w)
	prompt:set_h(h)
	prompt:set_right(self._safe_panel:w() - 50)

	local fade_in_duration = 0.25
	t = 0

	while fade_in_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.85, fade_in_duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.85)
end

function MissionUnlockGui:on_controller_hotswap()
	if self._playing_briefing_video then
		local press_any_key_prompt = self._safe_panel:child("press_any_key_prompt")

		if press_any_key_prompt then
			press_any_key_prompt:stop()
			press_any_key_prompt:animate(callback(self, self, "_animate_change_press_any_key_prompt"))
		end
	elseif managers.controller:is_using_controller() then
		self._unlock_button:animate_hide()
	else
		self._unlock_button:animate_show()
	end
end

function MissionUnlockGui:update(t, dt)
	if self._playing_briefing_video and (self:is_playing() and self:is_skipped() or not self:is_playing()) then
		self:complete_video()
	end
end

function MissionUnlockGui:complete_video()
	self._control_briefing_video:destroy()

	if self._video_panel:engine_panel_alive() then
		self._video_panel:remove(self._control_briefing_video)
		self._video_panel:remove_background()
		self._video_panel:remove(self._video_panel:child("video_background"))
		self._video_panel:remove(self._video_panel:child("disclaimer"))
	end

	self._control_briefing_video = nil
	self._video_panel = nil
	self._playing_briefing_video = false

	if alive(self._safe_panel) then
		self._safe_panel:child("press_any_key_prompt"):stop()
		self._safe_panel:remove(self._safe_panel:child("press_any_key_prompt"))
	end

	self:_finish_video()

	return true
end

function MissionUnlockGui:is_playing()
	if alive(self._control_briefing_video) then
		return self._control_briefing_video:loop_count() < 1
	else
		return false
	end
end

function MissionUnlockGui:is_skipped()
	for _, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			return true
		end
	end

	return false
end

function MissionUnlockGui:_finish_video()
	managers.menu_component:post_event("menu_volume_reset")
	managers.music:stop()
	managers.music:post_event("music_camp", true)
	self:_complete_mission_unlock_process()
	managers.raid_menu:register_on_escape_callback(nil)
end

function MissionUnlockGui:on_mission_chosen(control, mission, active)
	if active then
		self._selected_mission = mission

		self._unlock_button:enable()
		control:set_active(true)

		if self._selected_control then
			self._selected_control:set_active(false)
		end

		self._selected_control = control
	else
		self._selected_mission = nil

		self._unlock_button:disable()
		control:set_active(false)

		self._selected_control = nil
	end
end

function MissionUnlockGui:on_mission_double_click(mission)
	self._selected_mission = mission

	self:show_unlock_confirmation_prompt()
end

function MissionUnlockGui:show_unlock_confirmation_prompt()
	if not self._selected_mission then
		return
	end

	local confirmation_dialog_params = {
		yes_func = callback(self, self, "on_unlock_confirmed"),
		mission_title = self:translate(tweak_data.operations.missions[self._selected_mission].name_id)
	}

	managers.menu:show_unlock_mission_confirm_dialog(confirmation_dialog_params)
end

function MissionUnlockGui:on_unlock_confirmed()
	managers.progression:choose_offered_mission(self._selected_mission)
	managers.menu_component:post_event("new_raid_unlocked")

	if tweak_data.operations.missions[self._selected_mission] and tweak_data.operations.missions[self._selected_mission].control_brief_video then
		if managers.controller:is_using_controller() then
			managers.queued_tasks:queue("play_unlocked_raid_control_video", self._play_control_briefing_video, self, self._selected_mission, 0.1, nil)
		else
			self:_play_control_briefing_video(self._selected_mission)
		end
	else
		self:_complete_mission_unlock_process()
	end
end

function MissionUnlockGui:_complete_mission_unlock_process()
	managers.raid_menu:remove_menu_name_from_stack("mission_unlock_menu")
	managers.raid_menu:open_menu("mission_selection_menu", false)
end

function MissionUnlockGui:_bind_controller_inputs()
	local bindings = {
		{
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "show_unlock_confirmation_prompt")
		}
	}

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = {
			"menu_legend_back"
		},
		keyboard = {
			{
				key = "footer_back",
				callback = callback(self, self, "_on_legend_pc_back", nil)
			}
		}
	}
	local translated_text = managers.localization:get_default_macros().BTN_A
	translated_text = translated_text .. " " .. utf8.to_upper(self:translate("mission_unlock_button_text", true))

	table.insert(legend.controller, {
		translated_text = translated_text
	})
	self:set_legend(legend)
end
