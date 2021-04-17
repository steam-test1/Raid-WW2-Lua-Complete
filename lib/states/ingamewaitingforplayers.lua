core:import("CoreUnit")
require("lib/states/GameState")

IngameWaitingForPlayersState = IngameWaitingForPlayersState or class(GameState)

function IngameWaitingForPlayersState:init(game_state_machine)
	GameState.init(self, "ingame_waiting_for_players", game_state_machine)

	self._intro_source = SoundDevice:create_source("intro_source")
	self._start_cb = callback(self, self, "_start")
	self._skip_cb = callback(self, self, "_skip")
	self._controller = nil
end

function IngameWaitingForPlayersState:setup_controller()
	if not self._controller then
		self._controller = managers.controller:create_controller("waiting_for_players", managers.controller:get_default_wrapper_index(), false)
	end

	self._controller:set_enabled(true)

	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		local con = managers.controller:create_controller("boot_" .. index, index, false)

		con:enable()

		self._controller_list[index] = con
	end
end

function IngameWaitingForPlayersState:set_controller_enabled(enabled)
	if self._controller then
		-- Nothing
	end
end

function IngameWaitingForPlayersState:_skip()
	if not Network:is_server() then
		return
	end

	if not self._audio_started then
		return
	end

	if self._skipped then
		return
	end

	self:sync_skip()
	managers.network:session():send_to_peers_synched("sync_waiting_for_player_skip")
end

function IngameWaitingForPlayersState:sync_skip()
	self._skipped = true

	managers.briefing:stop_event(true)
	self:_start_delay()
end

function IngameWaitingForPlayersState:_start()
	if not Network:is_server() then
		return
	end

	local variant = managers.groupai:state():blackscreen_variant() or 0

	self:sync_start(variant)
	managers.network:session():send_to_peers_synched("sync_waiting_for_player_start", variant, Global.music_manager.current_track)
end

function IngameWaitingForPlayersState:sync_start(variant, soundtrack)
	self._briefing_start_t = nil

	managers.briefing:stop_event()

	self._blackscreen_started = true

	if self._intro_event then
		self._delay_audio_t = Application:time() + 1
	else
		self:_start_delay()
	end
end

function IngameWaitingForPlayersState:blackscreen_started()
	return self._blackscreen_started or false
end

function IngameWaitingForPlayersState:_start_audio()
	self._intro_cue_index = 1
	self._audio_started = true
	local event_started = managers.briefing:post_event(self._intro_event, {
		show_subtitle = true,
		listener = {
			end_of_event = true,
			clbk = callback(self, self, "_audio_done")
		}
	})

	if not event_started then
		print("failed to start audio, or played safehouse before")

		if Network:is_server() then
			self:_start_delay()
		end
	end
end

function IngameWaitingForPlayersState:_start_delay()
	if self._delay_start_t then
		return
	end

	self._delay_start_t = Application:time() + 1
end

function IngameWaitingForPlayersState:_audio_done(event_type, label, cookie)
	self:_create_blackscreen_loading_icon()

	if Network:is_server() then
		self:_start_delay()
	end
end

function IngameWaitingForPlayersState:_briefing_callback(event_type, label, cookie)
	print("[IngameWaitingForPlayersState]", "event_type", event_type, "label", label, "cookie", cookie)
end

function IngameWaitingForPlayersState:update(t, dt)
	if not managers.network:session() then
		return
	end

	if self:intro_video_playing() and self:is_skipped() or self:intro_video_playing() and self:intro_video_done() then
		self._intro_video:destroy()
		self._panel:remove(self._intro_video)
		self._panel:remove_background()

		self._intro_video = nil
		self._panel = nil
		self.intro_video_shown = true

		self._safe_panel:child("press_any_key_prompt"):stop()
		self._safe_panel:remove(self._safe_panel:child("press_any_key_prompt"))
		managers.raid_job:do_external_end_mission()
	end

	if self._briefing_start_t and self._briefing_start_t < t then
		self._briefing_start_t = nil
	end

	if self._delay_audio_t and self._delay_audio_t < t then
		self._delay_audio_t = nil

		self:_start_audio()
	end

	if self._delay_start_t then
		if self._file_streamer_max_workload or Network:is_server() and not managers.network:session():are_peers_done_streaming() or not managers.network:session():are_all_peer_assets_loaded() then
			self._delay_start_t = Application:time() + 1
		elseif self._delay_start_t < t then
			self._delay_start_t = nil

			if Network:is_server() then
				self._delay_spawn_t = Application:time() + 1
			end
		end
	end

	if self._delay_spawn_t and self._delay_spawn_t < t then
		self._delay_spawn_t = nil

		managers.network:session():spawn_players()
	end

	self:_chk_show_skip_prompt()

	if self._skip_promt_shown and Network:is_server() then
		if Global.exe_argument_auto_enter_level then
			self:_skip()
		elseif self._audio_started and not self._skipped then
			if self._controller then
				local btn_skip_press = self._controller:get_input_bool("confirm")

				if btn_skip_press and not self._skip_data then
					self._skip_data = {
						total = 1,
						current = 0
					}
				elseif not btn_skip_press and self._skip_data then
					self._skip_data = nil
				end
			end

			if self._skip_data then
				self._skip_data.current = self._skip_data.current + dt

				if self._skip_data.total < self._skip_data.current then
					self:_skip()
				end
			end
		end
	elseif self._skip_data then
		self._skip_data = nil
	end
end

function IngameWaitingForPlayersState:intro_video_playing()
	return alive(self._intro_video)
end

function IngameWaitingForPlayersState:intro_video_done()
	return self._intro_video:loop_count() >= 1
end

function IngameWaitingForPlayersState:is_skipped()
	for _, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			return true
		end
	end

	return false
end

function IngameWaitingForPlayersState:at_enter()
	self._started_from_beginning = true

	print("[IngameWaitingForPlayersState:at_enter()]")

	Global.statistics_manager.playing_from_start = true
	self.intro_video_shown = false
	self._full_workspace = Overlay:gui():create_screen_workspace()

	managers.gui_data:layout_fullscreen_workspace(self._full_workspace)

	self._full_panel = self._full_workspace:panel()
	self._safe_rect_workspace = Overlay:gui():create_screen_workspace()

	managers.gui_data:layout_workspace(self._safe_rect_workspace)

	self._safe_panel = self._safe_rect_workspace:panel()

	self:setup_controller()

	self._sound_listener = SoundDevice:create_listener("lobby_menu")

	self._sound_listener:set_position(Vector3(0, -50000, 0))
	self._sound_listener:activate(true)
	managers.menu:close_menu()
	managers.network:session():local_peer():set_waiting_for_player_ready(true)
	managers.network:session():chk_send_local_player_ready()
	managers.network:session():on_set_member_ready(managers.network:session():local_peer():id(), true, true, false)

	Global.exe_argument_level = false
	self._camera_data = {
		index = 0
	}
	self._briefing_start_t = Application:time() + 2

	if managers.network:session():is_client() and managers.network:session():server_peer() then
		local local_peer = managers.network:session():local_peer()

		local_peer:sync_lobby_data(managers.network:session():server_peer())
		local_peer:sync_data(managers.network:session():server_peer())
	end

	if managers.dyn_resource:is_file_streamer_idle() then
		managers.network:session():send_to_peers_loaded("set_member_ready", managers.network:session():local_peer():id(), 100, 2, "")
	else
		self._last_sent_streaming_status = 0
		self._file_streamer_max_workload = 0

		managers.network:session():send_to_peers_loaded("set_member_ready", managers.network:session():local_peer():id(), 0, 2, "")
		managers.dyn_resource:add_listener(self, {
			DynamicResourceManager.listener_events.file_streamer_workload
		}, callback(self, self, "clbk_file_streamer_status"))
	end

	if Global.game_settings.single_player then
		local rich_presence = "SPPlaying"

		managers.platform:set_rich_presence(rich_presence)
	end

	if Global.exe_argument_auto_enter_level then
		game_state_machine:current_state():start_game_intro()
	end
end

function IngameWaitingForPlayersState:show_intro_video()
	local params_root_panel = {
		is_root_panel = true,
		x = self._full_panel:x(),
		y = self._full_panel:y(),
		h = self._full_panel:h(),
		w = self._full_panel:w(),
		layer = tweak_data.gui.DEBRIEF_VIDEO_LAYER,
		background_color = Color.black
	}
	self._panel = RaidGUIPanel:new(self._full_panel, params_root_panel)
	local video = "movies/vanilla/intro/global/01_intro_v014"
	local intro_video_params = {
		layer = self._panel:layer() + 1,
		video = video,
		width = self._panel:w()
	}
	self._intro_video = self._panel:video(intro_video_params)

	self._intro_video:set_h(self._panel:w() * self._intro_video:video_height() / self._intro_video:video_width())
	self._intro_video:set_center_y(self._panel:h() / 2)

	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"
	local press_any_key_params = {
		name = "press_any_key_prompt",
		alpha = 0,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_32),
		font_size = tweak_data.gui.font_sizes.size_32,
		text = utf8.to_upper(managers.localization:text(press_any_key_text)),
		color = tweak_data.gui.colors.raid_dirty_white,
		layer = self._intro_video:layer() + 1
	}
	local press_any_key_prompt = self._safe_panel:text(press_any_key_params)
	local _, _, w, h = press_any_key_prompt:text_rect()

	press_any_key_prompt:set_w(w)
	press_any_key_prompt:set_h(h)
	press_any_key_prompt:set_right(self._safe_panel:w() - 50)
	press_any_key_prompt:set_bottom(self._safe_panel:h() - 50)
	press_any_key_prompt:animate(callback(self, self, "_animate_show_press_any_key_prompt"))
end

function IngameWaitingForPlayersState:_animate_show_press_any_key_prompt(prompt)
	local duration = 0.7
	local t = 0

	wait(6)

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0, 0.75, duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.75)
end

function IngameWaitingForPlayersState:clbk_file_streamer_status(workload)
	if not managers.network:session() then
		self._file_streamer_max_workload = nil

		managers.dyn_resource:remove_listener(self)

		return
	end

	self._file_streamer_max_workload = math.max(self._file_streamer_max_workload, workload)
	local progress = self._file_streamer_max_workload > 0 and 1 - workload / self._file_streamer_max_workload or 1
	progress = math.ceil(progress * 100)
	local local_peer = managers.network:session():local_peer()

	local_peer:set_streaming_status(progress)
	managers.network:session():on_streaming_progress_received(local_peer, progress)

	if self._last_sent_streaming_status ~= progress then
		managers.network:session():send_to_peers_loaded("set_member_ready", managers.network:session():local_peer():id(), progress, 2, "")

		self._last_sent_streaming_status = progress
	end

	if workload == 0 then
		self._file_streamer_max_workload = nil

		managers.dyn_resource:remove_listener(self)
	end
end

function IngameWaitingForPlayersState:_chk_show_skip_prompt()
	if not self._skip_promt_shown and not self._file_streamer_max_workload and not managers.menu:active_menu() and managers.network:session() and managers.network:session():are_peers_done_streaming() then
		self._skip_promt_shown = true
	end
end

function IngameWaitingForPlayersState:start_game_intro()
	if self._starting_game_intro then
		return
	end

	self._starting_game_intro = true

	self:_start()
end

function IngameWaitingForPlayersState:set_dropin(char_name)
	self._started_from_beginning = false
	Global.statistics_manager.playing_from_start = nil

	print("Joining as " .. char_name)
end

function IngameWaitingForPlayersState:check_is_dropin()
	return not self._started_from_beginning
end

function IngameWaitingForPlayersState:at_exit()
	Application:debug("[IngameWaitingForPlayersState:at_exit()]")

	if self._file_streamer_max_workload then
		self._file_streamer_max_workload = nil

		managers.dyn_resource:remove_listener(self)
	end

	managers.briefing:stop_event(true)
	managers.menu:close_menu("kit_menu")

	if self._sound_listener then
		self._sound_listener:delete()

		self._sound_listener = nil
	end

	local rich_presence = nil

	if Global.game_settings.single_player then
		rich_presence = "SPPlaying"
	else
		rich_presence = "MPPlaying"
	end

	managers.platform:set_presence("Playing")
	managers.platform:set_rich_presence(rich_presence)
	managers.platform:set_playing(true)
	managers.game_play_central:start_heist_timer()

	if not Network:is_server() and managers.network:session() and managers.network:session():server_peer() then
		managers.network:session():server_peer():verify_job(managers.raid_job:current_job_id())
		managers.network:session():server_peer():verify_character()
	end

	if self._fadeout_loading_icon then
		Application:debug("[IngameWaitingForPlayersState:at_exit()] self._fadeout_loading_icon")
		self._fadeout_loading_icon:fade_out(tweak_data.overlay_effects.level_fade_in.fade_out)

		self._fadeout_loading_icon = nil
	end

	Overlay:gui():destroy_workspace(self._full_workspace)
	Overlay:gui():destroy_workspace(self._safe_rect_workspace)
end

function IngameWaitingForPlayersState:is_joinable()
	return false
end
