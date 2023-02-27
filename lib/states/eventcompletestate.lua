require("lib/states/GameState")

EventCompleteState = EventCompleteState or class(GameState)
EventCompleteState.SCREEN_ACTIVE_DEBRIEF_VIDEO = 1
EventCompleteState.SCREEN_ACTIVE_SPECIAL_HONORS = 2
EventCompleteState.SCREEN_ACTIVE_STEAM_LOOT = 3
EventCompleteState.SCREEN_ACTIVE_GREED_LOOT = 4
EventCompleteState.SCREEN_ACTIVE_LOOT = 5
EventCompleteState.SCREEN_ACTIVE_EXPERIENCE = 6
EventCompleteState.LOOT_DATA_READY_KEY = "loot_data_ready"
EventCompleteState.SUCCESS_VIDEOS = {
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_01_throws_himself_v007"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_02_chickens_out_v007"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_03_salutes_v006"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_04_shoots_and_miss_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_05_crunches_bones_v006"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_06_plays_with_tin_men_v006"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_07_cries_tannenbaum_v007"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_08_chess_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_09_is_having_a_reverie_v007"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_10_colours_a_map_v009"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_11_swears_v005"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_12_plays_with_tanks_v005"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_13_flips_a_table_v007"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_success/global/s_14_moustache_v006"
	}
}
EventCompleteState.FAILURE_VIDEOS = {
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_01_edelweiss_v007"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_02_sizzles_v007"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_03_toasts_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_04_misunderstands_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_05_hugs_the_world_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_06_tin_soldiers_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_07_told_you_so_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_08_pumps_his_fists_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_09_bras_dhonneur_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_10_executes_v008"
	},
	{
		chance = 1,
		path = "movies/vanilla/debrief_failure/global/f_11_sings_v007"
	}
}

function EventCompleteState:init(game_state_machine, setup)
	GameState.init(self, "event_complete_screen", game_state_machine)

	self._type = ""
	self._continue_cb = callback(self, self, "_continue")
	self._controller = nil
	self._continue_block_timer = 0
	self._awarded_rewards = {
		loot = false,
		xp = false,
		greed_gold = false
	}
end

function EventCompleteState:setup_controller()
	if not self._controller then
		self._controller = managers.controller:create_controller("victoryscreen", managers.controller:get_default_wrapper_index(), false)

		self._controller:set_enabled(true)
		managers.controller:add_hotswap_callback("event_complete_state", callback(self, self, "on_controller_hotswap"))
	end
end

function EventCompleteState:set_controller_enabled(enabled)
end

function EventCompleteState:at_enter(old_state, params)
	Application:trace("[EventCompleteState:at_enter()]")
	managers.player:replenish_player()

	local player = managers.player:player_unit()

	if player then
		player:movement():current_state():interupt_all_actions()
		player:sound():stop()
		player:character_damage():stop_heartbeat()
		player:camera():set_shaker_parameter("headbob", "amplitude", 0)
		player:base():set_stats_screen_visible(false)
		player:camera():play_redirect(PlayerStandard.IDS_UNEQUIP)
		player:base():set_enabled(true)
		player:base():set_visible(false)
	end

	self._controller_list = {}

	for index = 1, managers.controller:get_wrapper_count() do
		local con = managers.controller:create_controller("boot_" .. index, index, false)

		con:enable()

		self._controller_list[index] = con
	end

	self.loot_data = {}
	self.is_at_last_event = managers.raid_job:is_at_last_event()
	self._success = managers.raid_job:stage_success()
	self.initial_xp = managers.experience:total()
	self.peers_loot_drops = {}

	managers.consumable_missions:on_mission_completed(self._success)
	managers.system_event_listener:add_listener("event_complete_state_top_stats_ready", {
		CoreSystemEventListenerManager.SystemEventListenerManager.TOP_STATS_READY
	}, callback(self, self, "on_top_stats_ready"))

	self._job_type = managers.raid_job:current_job_type()
	self._current_job_data = clone(managers.raid_job:current_job())
	self._active_challenge_card = managers.challenge_cards:get_active_card()

	if self._active_challenge_card ~= nil and self._active_challenge_card.key_name ~= nil and self._active_challenge_card.key_name ~= "empty" and self._active_challenge_card.loot_drop_group then
		managers.challenge_cards.forced_loot_card = self._active_challenge_card
	else
		managers.challenge_cards.forced_loot_card = nil
	end

	self:_calculate_card_xp_bonuses()
	self:check_complete_achievements()
	self:set_statistics_values()
	managers.statistics:stop_session({
		quit = false,
		type = "victory",
		success = self._success
	})
	managers.statistics:send_statistics()
	self:get_personal_stats()

	if self._success then
		managers.gold_economy:decrease_respec_reset()
	end

	if self.is_at_last_event and self:is_success() then
		managers.lootdrop:add_listener(LootScreenGui.EVENT_KEY_PEER_LOOT_RECEIVED, {
			LootDropManager.EVENT_PEER_LOOT_RECEIVED
		}, callback(self, self, "on_loot_dropped_for_peer"))
		self:on_loot_data_ready()

		if managers.raid_job:current_job() and not managers.raid_job:current_job().consumable then
			self:_calculate_extra_loot_secured()
		end
	end

	if Network:is_server() then
		managers.network:session():set_state("game_end")
	else
		managers.raid_job:on_mission_ended()
	end

	managers.platform:set_playing(false)
	managers.hud:remove_updator("point_of_no_return")
	managers.hud:hide_stats_screen()

	self._continue_block_timer = Application:time() + 1.5

	managers.dialog:quit_dialog()
	self:setup_controller()

	self._old_state = old_state

	if self.is_at_last_event then
		local is_operation = self._current_job_data.job_type == OperationsTweakData.JOB_TYPE_OPERATION

		if is_operation and self:is_success() or not is_operation then
			managers.challenge_cards:remove_active_challenge_card()
			managers.challenge_cards:clear_suggested_cards()

			if Network:is_server() then
				managers.network.matchmake:set_challenge_card_info()
				managers.network.matchmake:set_job_info_by_current_job()
			end
		end
	end

	managers.menu_component:post_event("menu_volume_set")
	managers.music:stop()
	managers.dialog:set_paused(true)

	local gui = Overlay:gui()
	self._full_workspace = gui:create_screen_workspace()
	self._safe_rect_workspace = gui:create_screen_workspace()
	self._safe_panel = self._safe_rect_workspace:panel()
	self._active_screen = EventCompleteState.SCREEN_ACTIVE_DEBRIEF_VIDEO

	if self.is_at_last_event or not self._success then
		self:_play_debrief_video()
	else
		self:_continue()
	end

	self._difficulty = Global.game_settings.difficulty
end

function EventCompleteState:_calculate_card_xp_bonuses()
	local card_bonus_xp = 0

	if self._active_challenge_card and self._active_challenge_card.status == ChallengeCardsManager.CARD_STATUS_SUCCESS then
		local card = tweak_data.challenge_cards.cards[self._active_challenge_card[ChallengeCardsTweakData.KEY_NAME_FIELD]]
		card_bonus_xp = card.bonus_xp or 0
	end

	local card_xp_multiplier = 1

	if self._active_challenge_card and self._active_challenge_card.status == ChallengeCardsManager.CARD_STATUS_SUCCESS then
		card_xp_multiplier = self._active_challenge_card.bonus_xp_multiplier or 1
	end

	self._card_bonus_xp = card_bonus_xp
	self._card_xp_multiplier = card_xp_multiplier
end

function EventCompleteState:card_bonus_xp()
	return self._card_bonus_xp
end

function EventCompleteState:card_xp_multiplier()
	return self._card_xp_multiplier
end

function EventCompleteState:_calculate_extra_loot_secured()
	local extra_loot_value = 0
	local extra_loot_count = 0
	local loot_secured = managers.loot:get_secured()

	while loot_secured do
		local loot_tweak_data = tweak_data.carry[loot_secured.carry_id]

		if loot_tweak_data and loot_tweak_data.loot_value then
			extra_loot_value = extra_loot_value + loot_tweak_data.loot_value
			extra_loot_count = extra_loot_count + 1
		end

		loot_secured = managers.loot:get_secured()
	end

	if extra_loot_value > 0 then
		local extra_loot_loot_data = {
			title = "menu_loot_screen_bonus_loot",
			total_value = 0,
			icon = "rewards_extra_loot",
			acquired = extra_loot_count,
			acquired_value = extra_loot_value
		}
		self.loot_data[LootScreenGui.LOOT_ITEM_EXTRA_LOOT] = extra_loot_loot_data
	end
end

function EventCompleteState:on_loot_data_ready()
	self.loot_acquired = managers.raid_job:loot_acquired_in_job()
	self.loot_spawned = managers.raid_job:loot_spawned_in_job()

	if self.loot_spawned == 0 then
		managers.system_event_listener:add_listener("event_complete_state_loot_data_ready", {
			EventCompleteState.LOOT_DATA_READY_KEY
		}, callback(self, self, "on_loot_data_ready"))

		return
	end

	self.peers_loot_drops = managers.lootdrop:get_loot_for_peers()
	local dog_tag_loot_data = {
		title = "menu_loot_screen_dog_tags",
		icon = "rewards_dog_tags",
		acquired = self.loot_acquired,
		total = self.loot_spawned,
		acquired_value = self.loot_acquired * tweak_data.lootdrop.dog_tag.loot_value,
		total_value = self.loot_spawned * tweak_data.lootdrop.dog_tag.loot_value
	}
	self.loot_data[LootScreenGui.LOOT_ITEM_DOG_TAGS] = dog_tag_loot_data

	if self.loot_spawned == self.loot_acquired and self._success then
		managers.achievment:check_achievement_group_bring_them_home(self._current_job_data)
	end
end

function EventCompleteState:drop_loot_for_player()
	Application:trace("[EventCompleteState:drop_loot_for_player()]")

	local acquired_loot_value = 0
	local total_loot_value = 0

	for id, loot_item in pairs(self.loot_data) do
		acquired_loot_value = acquired_loot_value + loot_item.acquired_value
		total_loot_value = total_loot_value + loot_item.total_value
	end

	local loot_percentage = 0

	if total_loot_value ~= 0 then
		loot_percentage = acquired_loot_value / total_loot_value
	end

	local loot_percentage = math.clamp(loot_percentage, 0, 1)
	local forced_loot_group = nil

	if self._active_challenge_card ~= nil and self._active_challenge_card.key_name ~= nil and self._active_challenge_card.key_name ~= "empty" then
		forced_loot_group = managers.challenge_cards:get_loot_drop_group(self._active_challenge_card.key_name)
	end

	managers.lootdrop:give_loot_to_player(loot_percentage, false, forced_loot_group)

	self._awarded_rewards.loot = true
end

function EventCompleteState:on_loot_dropped_for_player()
	Application:trace("[EventCompleteState:on_loot_dropped_for_player()]")

	self.local_player_loot_drop = managers.lootdrop:get_dropped_loot()
end

function EventCompleteState:on_loot_dropped_for_peer()
	Application:trace("[EventCompleteState:on_loot_dropped_for_peer()]")

	self.peers_loot_drops = managers.lootdrop:get_loot_for_peers()

	if self._active_screen == EventCompleteState.SCREEN_ACTIVE_LOOT and managers.menu_component._raid_menu_loot_gui and managers.menu_component._raid_menu_loot_gui.peer_loot_shown then
		managers.menu_component._raid_menu_loot_gui:refresh_peers_loot_display()
	end
end

function EventCompleteState:_get_debrief_video(success)
	local video_list = nil

	if success then
		video_list = EventCompleteState.SUCCESS_VIDEOS
	else
		video_list = EventCompleteState.FAILURE_VIDEOS
	end

	local total = 0

	for _, video in ipairs(video_list) do
		total = total + video.chance
	end

	local chosen_video = nil
	local value = math.rand(total)

	for _, video in ipairs(video_list) do
		value = value - video.chance

		if value <= 0 then
			chosen_video = video.path

			break
		end
	end

	return chosen_video
end

function EventCompleteState:_play_debrief_video()
	Application:trace("[EventCompleteState:_play_debrief_video()]")

	local full_panel = self._full_workspace:panel()
	local params_root_panel = {
		name = "event_complete_video_root_panel",
		is_root_panel = true,
		x = full_panel:x(),
		y = full_panel:y(),
		h = full_panel:h(),
		w = full_panel:w(),
		layer = tweak_data.gui.DEBRIEF_VIDEO_LAYER,
		background_color = Color.black
	}
	self._panel = RaidGUIPanel:new(full_panel, params_root_panel)
	local video = self:_get_debrief_video(self:is_success())
	local debrief_video_params = {
		name = "event_complete_debrief_video",
		layer = self._panel:layer() + 1,
		video = video,
		width = self._panel:w()
	}
	self._debrief_video = self._panel:video(debrief_video_params)

	self._debrief_video:set_h(self._panel:w() * self._debrief_video:video_height() / self._debrief_video:video_width())
	self._debrief_video:set_center_y(self._panel:h() / 2)

	local disclaimer_label_params = {
		w = 600,
		name = "event_complete_disclaimer",
		h = 600,
		wrap = true,
		visible = false,
		text = "HITLER VIDEOS HERE WHEN THEY'RE DONE",
		y = 400,
		x = 200,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_76),
		font_size = tweak_data.gui.font_sizes.size_76,
		color = tweak_data.gui.colors.raid_red,
		layer = self._debrief_video:layer() + 1
	}
	local disclaimer = self._panel:text(disclaimer_label_params)

	managers.gui_data:layout_workspace(self._safe_rect_workspace)

	local press_any_key_text = managers.controller:is_using_controller() and "press_any_key_to_skip_controller" or "press_any_key_to_skip"
	local press_any_key_params = {
		name = "press_any_key_prompt",
		alpha = 0,
		font = tweak_data.gui:get_font_path(tweak_data.gui.fonts.din_compressed, tweak_data.gui.font_sizes.size_32),
		font_size = tweak_data.gui.font_sizes.size_32,
		text = utf8.to_upper(managers.localization:text(press_any_key_text)),
		color = tweak_data.gui.colors.raid_dirty_white,
		layer = self._debrief_video:layer() + 1
	}
	local press_any_key_prompt = self._safe_panel:text(press_any_key_params)
	local _, _, w, h = press_any_key_prompt:text_rect()

	press_any_key_prompt:set_w(w)
	press_any_key_prompt:set_h(h)
	press_any_key_prompt:set_right(self._safe_panel:w() - 50)
	press_any_key_prompt:set_bottom(self._safe_panel:h() - 50)
	press_any_key_prompt:animate(callback(self, self, "_animate_show_press_any_key_prompt"))
end

function EventCompleteState:_animate_show_press_any_key_prompt(prompt)
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

function EventCompleteState:_animate_change_press_any_key_prompt(prompt)
	local fade_out_duration = 0.25
	local t = (1 - prompt:alpha()) * fade_out_duration

	while fade_out_duration > t do
		local dt = coroutine.yield()
		t = t + dt
		local current_alpha = Easing.quartic_in_out(t, 0.75, -0.75, fade_out_duration)

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
		local current_alpha = Easing.quartic_in_out(t, 0, 0.75, fade_in_duration)

		prompt:set_alpha(current_alpha)
	end

	prompt:set_alpha(0.75)
end

function EventCompleteState:on_controller_hotswap()
	local press_any_key_prompt = self._safe_panel:child("press_any_key_prompt")

	if press_any_key_prompt then
		press_any_key_prompt:stop()
		press_any_key_prompt:animate(callback(self, self, "_animate_change_press_any_key_prompt"))
	end
end

function EventCompleteState:job_data()
	return self._current_job_data
end

function EventCompleteState:on_server_left(message)
	local dialog_data = {
		title = managers.localization:text("dialog_returning_to_main_menu"),
		text = managers.localization:text("dialog_server_left")
	}

	if not self._awarded_rewards.loot and managers.raid_job:is_at_last_event() and self:is_success() then
		managers.lootdrop._cards_already_rejected = true

		self:drop_loot_for_player()

		local dropped_loot = managers.lootdrop._dropped_loot

		if not dropped_loot.reward_type == LootDropTweakData.REWARD_XP then
			dialog_data.text = dialog_data.text .. "\n"
		end

		if dropped_loot.reward_type == LootDropTweakData.REWARD_CUSTOMIZATION then
			dialog_data.text = dialog_data.text .. managers.localization:text("menu_server_left_loot_outfit", {
				OUTFIT = tostring(managers.localization:text(dropped_loot.character_customization.name))
			})
		elseif dropped_loot.reward_type == LootDropTweakData.REWARD_GOLD_BARS then
			dialog_data.text = dialog_data.text .. managers.localization:text("menu_server_left_loot_gold", {
				GOLD = tostring(dropped_loot.awarded_gold_bars)
			})
		elseif dropped_loot.reward_type == LootDropTweakData.REWARD_MELEE_WEAPON then
			dialog_data.text = dialog_data.text .. managers.localization:text("menu_server_left_loot_melee", {
				MELEE = tostring(managers.localization:text(tweak_data.blackmarket.melee_weapons[dropped_loot.weapon_id].name_id))
			})
		end
	end

	if not self._awarded_rewards.xp then
		local base_xp = self:calculate_xp()

		self:award_xp(base_xp)

		dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("menu_server_left_loot_xp", {
			XP = tostring(self._awarded_xp)
		})
	end

	if not self._awarded_rewards.greed_gold and managers.greed:acquired_gold_in_mission() and self:is_success() then
		dialog_data.text = dialog_data.text .. "\n" .. managers.localization:text("menu_server_left_loot_greed_gold", {
			GOLD = tostring(managers.greed._gold_awarded_in_mission)
		})

		managers.greed:award_gold_picked_up_in_mission()
	end

	managers.worldcollection:on_server_left()

	if managers.game_play_central then
		managers.game_play_central:stop_the_game()
	end

	local ok_button = {
		text = managers.localization:text("dialog_ok"),
		callback_func = MenuCallbackHandler._dialog_end_game_yes
	}
	dialog_data.button_list = {
		ok_button
	}

	managers.system_menu:show(dialog_data)

	Global.on_remove_peer_message = nil
end

function EventCompleteState:on_top_stats_ready()
	Application:trace("[EventCompleteState:on_top_stats_ready()]")

	if Network:is_server() then
		managers.raid_job:complete_current_event()
	end

	self.player_top_stats = managers.statistics:get_top_stats_for_player()
	local acquired_value = 0
	local total_value = 0

	if self:is_success() then
		self.special_honors = managers.statistics:get_top_stats()

		if managers.network:session():amount_of_players() ~= 1 then
			for index, stat in pairs(self.special_honors) do
				if stat.peer_id == managers.network:session():local_peer():id() then
					acquired_value = acquired_value + tweak_data.statistics.top_stats[stat.id].loot_value
				end

				total_value = total_value + tweak_data.statistics.top_stats[stat.id].loot_value
			end

			local top_stats_loot_data = {
				title = "menu_loot_screen_top_stats",
				icon = "rewards_top_stats",
				acquired = #self.player_top_stats,
				total = #self.special_honors,
				acquired_value = acquired_value,
				total_value = total_value
			}
			self.loot_data[LootScreenGui.LOOT_ITEM_TOP_STATS] = top_stats_loot_data
		end
	else
		self.special_honors = managers.statistics:get_bottom_stats()
	end

	for index, stat in pairs(self.player_top_stats) do
		acquired_value = acquired_value + tweak_data.statistics.top_stats[stat.id].loot_value
	end

	local is_in_operation = managers.raid_job:current_job().job_type == OperationsTweakData.JOB_TYPE_OPERATION
	self.stats_ready = true

	if self._active_screen == EventCompleteState.SCREEN_ACTIVE_SPECIAL_HONORS and managers.menu_component._raid_menu_special_honors_gui then
		managers.menu_component._raid_menu_special_honors_gui:show_honors()
	end

	if self.is_at_last_event and self._success and is_in_operation then
		local operation_save_data = managers.raid_job:get_save_slots()[managers.raid_job:get_current_save_slot()]

		if not operation_save_data then
			return
		end

		managers.achievment:check_achievement_operation_clear_sky_no_bleedout(operation_save_data)
		managers.achievment:check_achievement_operation_clear_sky_hardest(operation_save_data)
		managers.achievment:check_achievement_operation_burn_no_bleedout(operation_save_data)
		managers.achievment:check_achievement_operation_burn_hardest(operation_save_data)
	end
end

function EventCompleteState:update(t, dt)
	if self._active_screen == EventCompleteState.SCREEN_ACTIVE_DEBRIEF_VIDEO and (self:is_playing() and self:is_skipped() or not self:is_playing()) then
		self._debrief_video:destroy()
		self._panel:remove(self._debrief_video)
		self._panel:remove_background()
		self._panel:remove(self._panel:child("disclaimer"))

		self._debrief_video = nil
		self._panel = nil

		self._safe_panel:child("press_any_key_prompt"):stop()
		self._safe_panel:remove(self._safe_panel:child("press_any_key_prompt"))
		self:_continue()
	end
end

function EventCompleteState:is_playing()
	return self._debrief_video:loop_count() < 1
end

function EventCompleteState:is_skipped()
	for _, controller in ipairs(self._controller_list) do
		if controller:get_any_input_pressed() then
			return true
		end
	end

	return false
end

function EventCompleteState:get_personal_stats()
	local personal_stats = {
		session_killed = managers.statistics:session_killed().total.count or 0,
		session_accuracy = managers.statistics:session_hit_accuracy() or 0,
		session_headshots = managers.statistics:session_total_head_shots() or 0,
		session_headshot_percentage = 0
	}

	if personal_stats.session_killed > 0 then
		personal_stats.session_headshot_percentage = personal_stats.session_headshots / personal_stats.session_killed * 100
	end

	personal_stats.session_special_kills = managers.statistics:session_total_specials_kills() or 0
	personal_stats.session_revives_data = managers.statistics:session_teammates_revived() or 0
	personal_stats.session_teammates_revived = 0

	for i, count in pairs(personal_stats.session_revives_data) do
		personal_stats.session_teammates_revived = personal_stats.session_teammates_revived + count
	end

	personal_stats.session_bleedouts = managers.statistics:session_downed()
	self.personal_stats = personal_stats
end

function EventCompleteState:get_base_xp_breakdown()
	local is_in_operation = self._current_job_data.job_type == OperationsTweakData.JOB_TYPE_OPERATION
	local current_operation = is_in_operation and self._current_job_data.job_id or nil
	local current_event = nil

	if is_in_operation then
		current_event = self._current_job_data.events_index[self._current_job_data.current_event]
	else
		current_event = self._current_job_data.job_id
	end

	self.xp_breakdown = managers.experience:calculate_exp_brakedown(current_event, current_operation, true)

	if not self:is_success() then
		for i = 1, #self.xp_breakdown.additive do
			self.xp_breakdown.additive[i].amount = self.xp_breakdown.additive[i].amount * RaidJobManager.XP_MULTIPLIER_ON_FAIL
		end
	end
end

function EventCompleteState:calculate_xp()
	self:get_base_xp_breakdown()

	local additive = 0

	for i = 1, #self.xp_breakdown.additive do
		additive = additive + self.xp_breakdown.additive[i].amount
	end

	local multiplicative = 1

	for i = 1, #self.xp_breakdown.multiplicative do
		multiplicative = multiplicative + self.xp_breakdown.multiplicative[i].amount
	end

	self.total_xp = additive * multiplicative

	return self.total_xp
end

function EventCompleteState:recalculate_xp()
	local total_xp = self:calculate_xp()

	if total_xp ~= self._awarded_xp then
		self:award_xp(total_xp - self._awarded_xp)
	end
end

function EventCompleteState:award_xp(value)
	Application:trace("[EventCompleteState:award_xp()] value: " .. tostring(value))
	managers.experience:add_points(value, false)

	if not self._awarded_xp then
		self._awarded_xp = 0
	end

	self._awarded_xp = self._awarded_xp + value
	self._awarded_rewards.xp = true
end

function EventCompleteState:is_success()
	return self._success
end

function EventCompleteState:at_exit(next_state)
	Application:trace("[EventCompleteState:at_exit()]")
	managers.briefing:stop_event(true)
	self:_clear_controller()
	managers.experience:clear_loot_redeemed_xp()
	managers.loot:clear()
	managers.greed:clear_cache()

	self.initial_xp = nil
	self.xp_breakdown = nil
	self.total_xp = nil
	self.stats_ready = nil
	self.local_player_loot_drop = nil
	self._awarded_xp = 0
	self.loot_acquired = 0
	self.loot_spawned = 0
	self.loot_data = {}

	managers.statistics:clear_peer_statistics()
	managers.savefile:save_game(SavefileManager.SETTING_SLOT)

	local player = managers.player:player_unit()

	if player then
		player:base():set_enabled(true)
		player:base():set_visible(true)
		player:camera():play_redirect(PlayerStandard.IDS_EQUIP)
	end

	if Network:is_server() then
		managers.raid_job:start_next_event()
		managers.network:session():set_state("in_game")
		managers.network.matchmake:set_job_info_by_current_job()
	end

	managers.system_event_listener:remove_listener("event_complete_state_top_stats_ready")
	managers.system_event_listener:remove_listener("event_complete_state_loot_data_ready")
	managers.lootdrop:remove_listener(LootScreenGui.EVENT_KEY_PEER_LOOT_RECEIVED)
	managers.music:stop()
	managers.music:post_event(MusicManager.CAMP_MUSIC, true)
	managers.menu_component:post_event("menu_volume_reset")
	managers.dialog:set_paused(false)
	Overlay:gui():destroy_workspace(self._full_workspace)
	Overlay:gui():destroy_workspace(self._safe_rect_workspace)
end

function EventCompleteState:_shut_down_network()
	Network:set_multiplayer(false)
	managers.network:queue_stop_network()
	managers.network.matchmake:destroy_game()
	managers.network.voice_chat:destroy_voice()
end

function EventCompleteState:_continue_blocked()
	local in_focus = managers.menu:active_menu() == self._mission_end_menu

	if not in_focus then
		return true
	end

	if managers.hud:showing_stats_screen() then
		return true
	end

	if managers.system_menu:is_active() then
		return true
	end

	if managers.menu_component:input_focus() == 1 then
		return true
	end

	if self._continue_block_timer and Application:time() < self._continue_block_timer then
		return true
	end

	return false
end

function EventCompleteState:continue()
	self:_continue()
end

function EventCompleteState:_continue()
	Application:trace("[EventCompleteState:_continue()]")

	if self._active_screen == EventCompleteState.SCREEN_ACTIVE_DEBRIEF_VIDEO then
		if self:is_success() then
			managers.music:post_event("music_mission_success", true)
		else
			managers.music:post_event("music_mission_fail", true)
		end

		self._active_screen = EventCompleteState.SCREEN_ACTIVE_SPECIAL_HONORS

		if managers.network:session():amount_of_players() == 1 then
			self:_continue()

			return
		end

		managers.raid_menu:open_menu("raid_menu_special_honors", false)
	elseif self._active_screen == EventCompleteState.SCREEN_ACTIVE_SPECIAL_HONORS then
		if self.is_at_last_event and self:is_success() then
			local success = managers.raid_menu:open_menu("raid_menu_loot_screen", false)

			if success then
				self._active_screen = EventCompleteState.SCREEN_ACTIVE_LOOT
			end
		else
			local base_xp = self:calculate_xp()

			self:award_xp(base_xp)

			local success = managers.raid_menu:open_menu("raid_menu_post_game_breakdown", false)

			if success then
				self._active_screen = EventCompleteState.SCREEN_ACTIVE_EXPERIENCE
			end
		end

		managers.hud:post_event("prize_set_volume_continue")
		managers.hud:post_event("next_page_woosh")
	elseif self._active_screen == EventCompleteState.SCREEN_ACTIVE_LOOT then
		self._active_screen = EventCompleteState.SCREEN_ACTIVE_GREED_LOOT

		if self:is_success() and managers.greed:acquired_gold_in_mission() then
			local success = managers.raid_menu:open_menu("raid_menu_greed_loot_screen", false)

			managers.greed:award_gold_picked_up_in_mission()

			self._awarded_rewards.greed_gold = true
		else
			self:_continue()

			return
		end
	elseif self._active_screen == EventCompleteState.SCREEN_ACTIVE_GREED_LOOT then
		local base_xp = self:calculate_xp()

		self:award_xp(base_xp)

		local success = managers.raid_menu:open_menu("raid_menu_post_game_breakdown", false)

		if success then
			self._active_screen = EventCompleteState.SCREEN_ACTIVE_EXPERIENCE
		else
			self._active_screen = nil

			game_state_machine:change_state(self._old_state)
		end

		managers.hud:post_event("prize_set_volume_continue")
		managers.hud:post_event("next_page_woosh")
	else
		self._active_screen = nil

		managers.raid_menu:close_all_menus()
		game_state_machine:change_state(self._old_state)
	end
end

function EventCompleteState:_clear_controller()
	managers.controller:remove_hotswap_callback("event_complete_state")

	if not self._controller then
		return
	end

	self._controller:set_enabled(false)
	self._controller:destroy()

	self._controller = nil
end

function EventCompleteState:game_ended()
	return true
end

function EventCompleteState:check_complete_achievements()
	if self:is_success() then
		managers.achievment:check_achievement_complete_raid_with_4_different_classes()
		managers.achievment:check_achievement_complete_raid_with_no_kills()
		managers.achievment:check_achievement_kill_30_enemies_with_vehicle_on_bank_level()
	end
end

function EventCompleteState:set_statistics_values()
	local usingChallengeCard = false

	if self._active_challenge_card ~= nil and self._active_challenge_card.key_name ~= nil and self._active_challenge_card.key_name ~= "empty" and self._active_challenge_card.card_category == ChallengeCardsTweakData.CARD_CATEGORY_CHALLENGE_CARD then
		usingChallengeCard = true
	end

	if self:is_success() and usingChallengeCard then
		managers.statistics:complete_job_with_challenge_card(self._job_type, self._active_challenge_card)
	end
end

function EventCompleteState:is_joinable()
	return false
end
