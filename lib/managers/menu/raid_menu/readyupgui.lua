ReadyUpGui = ReadyUpGui or class(RaidGuiBase)

function ReadyUpGui:init(ws, fullscreen_ws, node, component_name)
	if Network:is_server() then
		managers.network:session():set_state("in_lobby")
		managers.network:session():chk_server_joinable_state()
	else
		self._synced_document_spawn_chance_to_host = false
	end

	self._continuing_mission = managers.raid_job:current_job() ~= nil

	ReadyUpGui.super.init(self, ws, fullscreen_ws, node, component_name)
	self:_disable_dof()
	managers.system_event_listener:add_listener("ready_up_gui_player_kicked", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KICKED
	}, callback(self, self, "_on_peer_kicked"))
	managers.system_event_listener:add_listener("ready_up_gui_player_left", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_LEFT
	}, callback(self, self, "_on_peer_left"))
	managers.system_event_listener:add_listener("ready_up_gui_inventory_processed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.EVENT_STEAM_INVENTORY_PROCESSED
	}, callback(self, self, "_players_inventory_processed"))
	managers.raid_menu:register_on_escape_callback(callback(self, self, "back_pressed"))

	self._callback_handler = RaidMenuCallbackHandler:new()

	managers.hud:hud_chat():unregister()
	managers.raid_menu:hide_background()

	self._local_player_selected = true
	Global.statistics_manager.playing_from_start = true
end

function ReadyUpGui:_setup_properties()
	ReadyUpGui.super._setup_properties(self)

	self._background = nil
	self._background_rect = nil
end

function _get_local_peer_index()
	for i, peer in pairs(managers.network:session():all_peers()) do
		if peer == managers.network:session():local_peer() then
			return i
		end
	end
end

function ReadyUpGui:_layout()
	self._is_host = Network:is_server()
	self._is_single_player = managers.network:session():count_all_peers() == 1
	self._local_peer_index = _get_local_peer_index()

	self:_layout_card_info()
	self:_layout_buttons()
	self:_layout_header()
	self:_layout_player_list()

	self._chat = HUDChat:new(self._ws, self._ws_panel, false)

	self._chat:set_bottom(self._root_panel:h() - HUDManager.CHAT_DISTANCE_FROM_BOTTOM)
	self._chat:_on_focus()
	self:_load_character_empty_skeleton()
	managers.challenge_cards:set_automatic_steam_inventory_refresh(true)
	managers.network.account:inventory_load()
end

function ReadyUpGui:_layout_buttons()
	local button_y = 848
	self._ready_up_button = self._root_panel:short_primary_button({
		name = "ready_up_button",
		visible = false,
		x = 0,
		y = button_y,
		text = self:translate("menu_ready_button", true),
		on_click_callback = callback(self, self, "_on_ready_up_button")
	})

	self._ready_up_button:disable()

	self._suggest_card_button = self._root_panel:short_secondary_button({
		name = "suggest_card_button",
		visible = false,
		x = 1000,
		y = button_y,
		text = self:translate("menu_suggest_card_button", true),
		on_click_callback = callback(self, self, "_on_select_card_button")
	})

	self._suggest_card_button:set_right(self._root_panel:right())
	self._suggest_card_button:disable()
	self._suggest_card_button:hide()

	self._no_cards_warning_label = self._root_panel:label({
		visible = false,
		name = "no_cards_warning_label",
		align = "right",
		x = 1000,
		y = button_y,
		text = self:translate("menu_card_dont_own", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.raid_red
	})
	local x1, y1, w1, h1 = self._no_cards_warning_label:text_rect()

	self._no_cards_warning_label:set_w(w1)
	self._no_cards_warning_label:set_h(h1)
	self._no_cards_warning_label:set_right(self._root_panel:right())
	self._no_cards_warning_label:set_center_y(self._suggest_card_button:center_y())

	if self._is_host then
		self._kick_button = self._root_panel:short_secondary_button({
			name = "kick_button",
			x = 1000,
			y = button_y,
			text = self:translate("menu_kick_button", true),
			on_click_callback = callback(self, self, "_on_kick_button")
		})

		self._kick_button:set_right(self._root_panel:right())
		self._kick_button:hide()
	end

	local _leave_lobby_button_params = {
		visible = false,
		name = "leave_lobby_button",
		x = self._ready_up_button:right() + 64,
		y = button_y
	}

	if Network:is_server() then
		_leave_lobby_button_params.text = self:translate("menu_leave_ready_up_button", true)
		_leave_lobby_button_params.on_click_callback = callback(self, self, "_on_leave_ready_up_button")

		managers.network:session():set_state("in_game")
		managers.network:session():chk_server_joinable_state()
	else
		_leave_lobby_button_params.text = self:translate("menu_leave_lobby_button", true)
		_leave_lobby_button_params.on_click_callback = callback(self, self, "_on_leave_lobby_button")
	end

	self._leave_lobby_button = self._root_panel:short_tertiary_button(_leave_lobby_button_params)

	self._leave_lobby_button:disable()
	self._leave_lobby_button:hide()

	if self._is_single_player then
		self._suggest_card_button:set_text(self:translate("menu_select_card_button", true))
		self._ready_up_button:set_text(self:translate("menu_start_button_title", true))
	end
end

function ReadyUpGui:_layout_header()
	local selected_job = managers.raid_job:selected_job()
	local current_job = managers.raid_job:current_job()
	local selected_level_data = selected_job or current_job
	local mission_data = tweak_data.operations:mission_data(selected_level_data.job_id)
	local item_icon_name = mission_data.icon_menu
	local item_icon = {
		texture = tweak_data.gui.icons[item_icon_name].texture,
		tex_rect = tweak_data.gui.icons[item_icon_name].texture_rect,
		color = tweak_data.gui.colors.dirty_white
	}

	self._node.components.raid_menu_header:set_header_icon(item_icon)

	local mission_name = nil

	if current_job then
		local name_id = current_job.name_id
		local total_events = #current_job.events_index
		local current_event = math.clamp(current_job.current_event, 1, total_events)
		local mission_progress_fraction = " " .. current_event .. "/" .. total_events .. ": "
		local event_name = self:translate(current_job.current_event_data.name_id, true)
		local title_text = self:translate(name_id, true) .. mission_progress_fraction .. event_name
		mission_name = title_text
	else
		mission_name = utf8.to_upper(managers.localization:text(tweak_data.operations.missions[selected_job.job_id].name_id))
	end

	local mission_info_x = tweak_data.gui:icon_w(item_icon_name) + 16
	local mission_name_params = {
		vertical = "center",
		name = "mission_name",
		h = 32,
		align = "left",
		y = 0,
		x = mission_info_x,
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.small,
		color = tweak_data.gui.colors.raid_red,
		text = mission_name
	}
	local mission_name = self._root_panel:label(mission_name_params)
	local difficulty_params = {
		name = "mission_difficulty",
		amount = tweak_data:number_of_difficulties()
	}
	self._difficulty_indicator = RaidGuiControlDifficultyStars:new(self._root_panel, difficulty_params)

	self._difficulty_indicator:set_x(mission_name:x())
	self._difficulty_indicator:set_center_y(45)

	local current_difficulty = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	self._difficulty_indicator:set_active_difficulty(current_difficulty)
	self._node.components.raid_menu_header:set_screen_name_raw("")
end

function ReadyUpGui:_get_list_index(peer_index)
	local wanted_local_peer_list_index = 2

	if self._is_single_player then
		wanted_local_peer_list_index = 1
	end

	if peer_index == self._local_peer_index then
		return wanted_local_peer_list_index
	elseif peer_index == wanted_local_peer_list_index then
		return self._local_peer_index
	end

	return peer_index
end

function ReadyUpGui:_layout_player_list()
	self._player_control_list = {}
	self._current_peer = nil
	self._current_peer_index = nil
	local width = 432

	for peer_index, peer in pairs(managers.network:session():all_peers()) do
		local list_index = self:_get_list_index(peer_index)
		local current_player = peer == managers.network:session():local_peer()
		local player_control = self._root_panel:create_custom_control(RaidGUIControlReadyUpPlayerDescription, {
			h = 112,
			y = 96,
			x = (list_index - 1) * width,
			w = width,
			on_click_callback = callback(self, self, "_on_player_click_callback"),
			is_current_player = current_player,
			peer = peer,
			peer_index = peer_index,
			list_index = list_index
		})
		local outfit = peer:blackmarket_outfit()
		local player_data = {
			player_name = peer:name(),
			player_level = peer:level() or managers.experience:current_level(),
			player_class = outfit.skills,
			is_host = peer:is_host()
		}

		player_control:set_data(player_data)

		if current_player then
			player_control:on_mouse_clicked()
		end

		self._player_control_list[peer] = player_control
	end
end

function ReadyUpGui:_layout_card_info()
	local card_w = 160
	local card_params = {
		name = "player_loot_card",
		y = 384,
		item_h = 224,
		x = self._root_panel:w() - 160,
		item_w = card_w
	}
	self._card_control = self._root_panel:create_custom_control(RaidGUIControlCardBase, card_params)

	self._card_control:set_visible(false)

	local empty_slot_texture = tweak_data.gui.icons.cc_empty_slot_small
	self._empty_card_slot = self._root_panel:bitmap({
		name = "cc_empty_slot",
		y = 384,
		x = self._root_panel:w() - 160,
		w = empty_slot_texture.texture_rect[3],
		h = empty_slot_texture.texture_rect[4],
		texture = empty_slot_texture.texture,
		texture_rect = empty_slot_texture.texture_rect
	})
	self._card_not_selected_label = self._root_panel:label({
		name = "card_not_selected_label",
		h = 128,
		wrap = true,
		align = "center",
		x = self._root_panel:w() - 160,
		y = self._card_control:top() + 90,
		w = self._empty_card_slot:w() - 10,
		text = self:translate("menu_card_not_selected", true),
		font = tweak_data.gui.fonts.din_compressed,
		font_size = tweak_data.gui.font_sizes.extra_small,
		color = tweak_data.gui.colors.dirty_white
	})

	self._card_not_selected_label:set_center_x(self._empty_card_slot:center_x())
	self._card_not_selected_label:set_visible(true)

	self._positive_card_effect_label = self._root_panel:label({
		name = "positive_card_effect",
		h = 128,
		wrap = true,
		w = 352,
		align = "left",
		x = 0,
		y = self._card_control:bottom() + 32,
		text = self:translate("hud_no_challenge_card_text", false),
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_18,
		color = tweak_data.gui.colors.raid_grey
	})

	self._positive_card_effect_label:set_right(self._root_panel:right())

	self._negative_card_effect_label = self._root_panel:label({
		name = "negative_card_effect",
		h = 64,
		wrap = true,
		w = 352,
		align = "left",
		text = "",
		x = 0,
		y = self._card_control:bottom() + 96,
		font = tweak_data.gui.fonts.lato,
		font_size = tweak_data.gui.font_sizes.size_18,
		color = tweak_data.gui.colors.raid_grey
	})

	self._negative_card_effect_label:set_right(self._root_panel:right())
	self._negative_card_effect_label:set_visible(false)
end

function ReadyUpGui:_get_character_spawn_locations()
	local units = World:find_units_quick("all", managers.slot:get_mask("env_effect"))
	local ids_ready_up_scene_name = Idstring("units/vanilla/characters/scenes/ready_up_scene")
	self._character_spawn_locations = {}

	if units then
		for _, unit in pairs(units) do
			if unit:name() == ids_ready_up_scene_name then
				for i = 1, 4 do
					table.insert(self._character_spawn_locations, unit:get_object(Idstring("loc_player_0" .. i)))
				end
			end
		end
	end
end

function ReadyUpGui:_spawn_weapon(params)
	local right_hand_locator = params.character_unit:get_object(Idstring("a_weapon_right_front"))
	local weapon_unit = safe_spawn_unit(params.unit_path, right_hand_locator:position(), Rotation(0, 0, 0))

	params.character_unit:link(Idstring("a_weapon_right_front"), weapon_unit, weapon_unit:orientation_object():name())

	local weapon_blueprint = params.peer:blackmarket_outfit().primary.blueprint

	managers.weapon_factory:assemble_from_blueprint(params.weapon_factory_id, weapon_unit, weapon_blueprint, true, callback(self, self, "_assemble_completed", {
		peer = params.peer
	}), true)
end

function ReadyUpGui:_assemble_completed(params, parts, blueprint)
	self._spawned_weapon_parts = self._spawned_weapon_parts or {}
	self._spawned_weapon_parts[params.peer] = {}

	for _, part in pairs(parts) do
		table.insert(self._spawned_weapon_parts[params.peer], part.unit)
	end

	self._weapon_assembled[params.peer] = true
end

function ReadyUpGui:_load_character_empty_skeleton()
	managers.dyn_resource:load(Idstring("unit"), Idstring(CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_spawn_character_units"))
end

function ReadyUpGui:_get_character_spawn_index(control_list_index)
	if self._is_single_player then
		return 1
	end

	if control_list_index == 1 then
		return 2
	elseif control_list_index == 2 then
		return 1
	end

	return control_list_index
end

function ReadyUpGui:_spawn_character_units()
	self:_get_character_spawn_locations()

	self._spawned_character_units = {}
	self._weapon_assembled = {}
	self._spawned_weapon_parts = {}
	local ids_unit_name = Idstring(CharacterCustomizationTweakData.CRIMINAL_MENU_SELECT_UNIT)

	for peer, control in pairs(self._player_control_list) do
		local locator_index = self:_get_character_spawn_index(control:params().list_index)
		local position = self._character_spawn_locations[locator_index]:position() or Vector3(0, 0, 0)
		local rotation = Rotation(0, 0, 0)
		local spawned_unit = World:spawn_unit(ids_unit_name, position, rotation)
		self._spawned_character_units[peer] = spawned_unit

		spawned_unit:customization():set_visible(false)

		local outfit = peer:blackmarket_outfit()

		spawned_unit:customization():attach_all_parts_to_character_by_parts_for_husk(outfit.character_customization_nationality, outfit.character_customization_head, outfit.character_customization_upper, outfit.character_customization_lower, peer)

		local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id)
		local weapon_factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)
		local unit_path = Idstring(tweak_data.weapon.factory[weapon_factory_id].unit)
		self._weapon_assembled[peer] = false

		managers.dyn_resource:load(Idstring("unit"), unit_path, DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_spawn_weapon", {
			weapon_factory_id = weapon_factory_id,
			unit_path = unit_path,
			weapon_id = weapon_id,
			character_unit = spawned_unit,
			peer = peer
		}))

		local anim_state_name = "hos_idle_loop_" .. weapon_id
		local at_time = math.random() * 10
		local state = spawned_unit:play_redirect(Idstring(anim_state_name), at_time)
	end
end

function ReadyUpGui:_set_card_selection_controls()
	self._raid_card_count, self._operation_card_count = managers.challenge_cards:get_cards_count_per_type(managers.challenge_cards:get_readyup_card_cache())

	if not managers.raid_menu:is_pc_controller() then
		self:bind_controller_inputs(self._current_peer == managers.network:session():local_peer(), true)
	elseif managers.raid_menu:is_offline_mode() then
		self._suggest_card_button:hide()
		self._suggest_card_button:disable()
		self._no_cards_warning_label:hide()
		self._card_not_selected_label:set_text(self:translate("menu_no_cards_in_offline_mode", true))
		self._card_not_selected_label:show()
		self._card_not_selected_label:set_center_x(self._empty_card_slot:center_x())
		self._card_not_selected_label:set_center_y(self._empty_card_slot:center_y())

		local x1, y1, w1, h1 = self._card_not_selected_label:text_rect()

		self._card_not_selected_label:set_h(h1)

		if not self._local_player_selected then
			self._card_not_selected_label:hide()
		end

		self._positive_card_effect_label:hide()
	elseif managers.raid_job:selected_job() and managers.raid_job:selected_job().job_type == OperationsTweakData.JOB_TYPE_RAID and self._raid_card_count > 0 or managers.raid_job:selected_job() and managers.raid_job:selected_job().job_type == OperationsTweakData.JOB_TYPE_OPERATION and self._operation_card_count > 0 then
		self._suggest_card_button:show()
		self._suggest_card_button:enable()
		self._no_cards_warning_label:hide()
		self._card_not_selected_label:hide()

		if not self._local_player_selected then
			self._suggest_card_button:hide()
			self._suggest_card_button:disable()
		end
	else
		self._suggest_card_button:hide()
		self._suggest_card_button:disable()
		self._no_cards_warning_label:show()
		self._card_not_selected_label:show()

		if not self._local_player_selected then
			self._card_not_selected_label:hide()
		end
	end
end

function ReadyUpGui:_players_inventory_processed(params)
	self:_set_card_selection_controls()
end

function ReadyUpGui:_on_player_click_callback(control, params)
	Application:trace("[ReadyUpGui:_on_player_click_callback]")

	for _, player_control in pairs(self._player_control_list) do
		player_control:select_off()
	end

	self._current_peer = params.peer

	if not managers.raid_menu:is_pc_controller() then
		self:bind_controller_inputs(self._current_peer == managers.network:session():local_peer(), true)

		if self._kick_button then
			self._kick_button:hide()
		end

		self._suggest_card_button:hide()
		self._leave_lobby_button:hide()
	else
		if self._is_host then
			if not params.is_current_player then
				self._kick_button:show()
			else
				self._kick_button:hide()
			end
		end

		if params.is_current_player then
			if not self._ready and self._suggest_card_button:enabled() then
				self._suggest_card_button:show()
			end

			if self._leave_lobby_button:enabled() and not managers.challenge_cards:did_everyone_locked_sugested_card() then
				self._leave_lobby_button:show()
			end

			self._ready_up_button:show()

			if self._ready then
				self._ready_up_button:disable()
			end

			self._local_player_selected = true
		else
			self._suggest_card_button:hide()

			if self._leave_lobby_button:enabled() and not managers.challenge_cards:did_everyone_locked_sugested_card() then
				self._leave_lobby_button:show()
			end

			self._ready_up_button:show()

			if self._ready then
				self._ready_up_button:disable()
			end

			self._local_player_selected = false
		end
	end

	self._current_peer_index = params.peer_index
	self._current_list_index = params.list_index
end

function ReadyUpGui:_show_characters()
	if not self._spawned_character_units then
		return
	end

	local should_allow_ready_up = true

	for _, unit in pairs(self._spawned_character_units) do
		local unit_customization = unit:customization()
		local is_visible = unit_customization:visible()

		if not is_visible and unit:anim_data().ready_up_idle_started then
			unit_customization:set_visible(true)

			should_allow_ready_up = false
		end
	end

	for _, assembled in pairs(self._weapon_assembled) do
		if not assembled then
			should_allow_ready_up = false

			break
		end
	end

	if should_allow_ready_up and not self._ready then
		self._ready_up_button:enable()
		self._suggest_card_button:enable()
		self._leave_lobby_button:enable()

		if self._player_control_list[self._current_peer]:params().is_current_player and managers.menu:is_pc_controller() then
			self._leave_lobby_button:show()
			self._suggest_card_button:show()
		end

		self:_set_card_selection_controls()
	end
end

function ReadyUpGui:_show_player_challenge_card_info()
	local challenge_cards = managers.challenge_cards:get_suggested_cards()

	if challenge_cards and challenge_cards[self._current_peer_index] and challenge_cards[self._current_peer_index].key_name ~= ChallengeCardsManager.CARD_PASS_KEY_NAME then
		local card = challenge_cards[self._current_peer_index]

		self._card_control:set_card(card)

		local bonus_description, malus_description = managers.challenge_cards:get_card_description(card.key_name)

		self._positive_card_effect_label:set_text("+ " .. bonus_description)

		local _, _, _, h = self._positive_card_effect_label:text_rect()

		self._positive_card_effect_label:set_h(h)

		if malus_description ~= "" then
			self._negative_card_effect_label:set_text("- " .. malus_description)

			local _, _, _, h = self._negative_card_effect_label:text_rect()

			self._negative_card_effect_label:set_h(h)
			self._negative_card_effect_label:set_y(self._positive_card_effect_label:bottom() + 15)
		end

		self._card_control:set_visible(true)
		self._empty_card_slot:set_visible(false)
		self._card_not_selected_label:set_visible(false)
		self._negative_card_effect_label:set_visible(true)
	else
		self._card_control:set_card(nil)
		self._positive_card_effect_label:set_text(self:translate("hud_no_challenge_card_text", false))

		local _, _, _, h = self._positive_card_effect_label:text_rect()

		self._positive_card_effect_label:set_h(h)
		self._negative_card_effect_label:set_text("")
		self._card_control:set_visible(false)
		self._empty_card_slot:set_visible(true)
		self._card_not_selected_label:set_visible(true)
		self._negative_card_effect_label:set_visible(false)
	end
end

function ReadyUpGui:_update_challenge_card_selected_icon()
	local challenge_cards = managers.challenge_cards:get_suggested_cards()

	for _, control in pairs(self._player_control_list) do
		control:set_challenge_card_selected(challenge_cards[control:params().peer_index] ~= nil and challenge_cards[control:params().peer_index].key_name ~= ChallengeCardsManager.CARD_PASS_KEY_NAME)
	end
end

function ReadyUpGui:_update_status()
	if self._backed_out then
		self._backed_out = false

		return
	end

	local challenge_cards = managers.challenge_cards:get_suggested_cards()

	for peer, control in pairs(self._player_control_list) do
		local card = challenge_cards[control:params().peer_index]

		if card and card.locked_suggestion then
			local was_ready = control:is_ready()

			control:set_state("ready")

			if control:is_ready() and not was_ready then
				local outfit = peer:blackmarket_outfit()
				local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(outfit.primary.factory_id)
				local anim_state_name = "hos_to_cbt_" .. weapon_id
				local state = self._spawned_character_units[peer]:play_redirect(Idstring(anim_state_name))

				managers.menu_component:post_event("ready_up_" .. peer:character())
			end
		end
	end

	local all_ready = true

	for peer, control in pairs(self._player_control_list) do
		if not control:is_ready() then
			all_ready = false

			break
		end
	end

	if all_ready then
		if not managers.raid_menu:is_pc_controller() then
			self:bind_controller_inputs(true, false)
		else
			self._leave_lobby_button:hide()
		end
	end
end

function ReadyUpGui:_reset_ready_ups()
	Application:debug("[ReadyUpGui:_reset_ready_ups] RESET")

	self._ready = false

	if self._player_control_list then
		for i, control in ipairs(self._player_control_list) do
			control:set_state("not_ready")
		end
	end
end

function ReadyUpGui:_on_select_card_button()
	if not self._suggest_card_button:enabled() then
		return
	end

	managers.raid_menu:open_menu("challenge_cards_menu")
end

function ReadyUpGui:_on_ready_up_button()
	if not self._ready_up_button:enabled() then
		return
	end

	local local_peer = managers.network:session():local_peer()
	local local_peer_control = self._player_control_list[local_peer]

	self._ready_up_button:disable()
	self._suggest_card_button:disable()
	self._suggest_card_button:hide()

	if self._is_host then
		self._kick_button:disable()
		self._kick_button:hide()
	end

	local challenge_cards = managers.challenge_cards:get_suggested_cards()

	if challenge_cards and not challenge_cards[local_peer_control:params().peer_index] then
		managers.challenge_cards:suggest_challenge_card(ChallengeCardsManager.CARD_PASS_KEY_NAME, nil)
	end

	managers.challenge_cards:toggle_lock_suggested_challenge_card()

	self._ready = true

	self:bind_controller_inputs(true, true)
end

function ReadyUpGui:_on_kick_button()
	local params = {
		yes_callback = callback(self, self, "_on_kick_confirmed"),
		player_name = self._current_peer:name()
	}

	managers.menu:show_kick_peer_dialog(params)
end

function ReadyUpGui:_on_kick_confirmed()
	managers.vote:host_kick(self._current_peer)
end

function ReadyUpGui:_on_peer_kicked(params)
	self:_peer_no_longer_in_lobby(params.peer, "kicked")
end

function ReadyUpGui:_on_peer_left(params)
	self:_peer_no_longer_in_lobby(params.peer, "left")
end

function ReadyUpGui:_peer_no_longer_in_lobby(peer, state)
	local peer_control = self._player_control_list[peer]

	peer_control:set_state(state)

	if peer == self._current_peer then
		peer_control:select_off()

		self._current_peer = nil
		local local_peer = managers.network:session():local_peer()

		if peer ~= local_peer then
			self._player_control_list[local_peer]:on_mouse_clicked()
		end
	end

	for _, part in ipairs(self._spawned_weapon_parts[peer]) do
		part:set_slot(0)

		part = nil
	end

	self._spawned_weapon_parts[peer] = nil

	self._spawned_character_units[peer]:set_slot(0)

	self._spawned_character_units[peer] = nil
end

function ReadyUpGui:_on_leave_lobby_button()
	if not self._leave_lobby_button:enabled() then
		return
	end

	self._callback_handler:end_game()
end

function ReadyUpGui:_on_leave_ready_up_button()
	if not self._leave_lobby_button:enabled() then
		return
	end

	self._backed_out = true

	self._callback_handler:leave_ready_up()
	self:_reset_ready_ups()
end

function ReadyUpGui:close()
	managers.challenge_cards:set_automatic_steam_inventory_refresh(false)
	self:_enable_dof()
	managers.system_event_listener:remove_listener("ready_up_gui_player_kicked")
	managers.system_event_listener:remove_listener("ready_up_gui_player_left")
	managers.system_event_listener:remove_listener("ready_up_gui_inventory_processed")
	self._chat:unregister()
	managers.hud:hud_chat():register()

	if self._spawned_character_units then
		for _, unit in pairs(self._spawned_character_units) do
			unit:set_slot(0)

			unit = nil
		end

		self._spawned_character_units = nil
	end

	if self._spawned_weapon_parts then
		for _, parts in pairs(self._spawned_weapon_parts) do
			for _, part in ipairs(parts) do
				part:set_slot(0)

				part = nil
			end
		end

		self._spawned_weapon_parts = nil
	end

	managers.lootdrop:clear_dropped_loot()
	ReadyUpGui.super.close(self)
end

function ReadyUpGui:_update_controls_contining_mission()
	if self._continuing_mission then
		self._suggest_card_button:hide()
		self._suggest_card_button:disable()
		self._no_cards_warning_label:hide()

		local active_card = managers.challenge_cards:get_active_card()
		local is_card_active = active_card and active_card.description ~= "PASS"

		if is_card_active then
			self._card_not_selected_label:hide()
			self._empty_card_slot:hide()
			self._card_control:set_visible(true)
			self._card_control:set_card(active_card)

			local bonus_description, malus_description = managers.challenge_cards:get_card_description(active_card.key_name)

			self._positive_card_effect_label:set_text("+ " .. bonus_description)

			if malus_description ~= "" then
				self._negative_card_effect_label:show()
				self._negative_card_effect_label:set_text("- " .. malus_description)
			end
		else
			self._card_not_selected_label:show()
			self._card_not_selected_label:set_text(self:translate("menu_card_not_selected", true))
			self._empty_card_slot:show()
			self._card_control:set_visible(false)
			self._positive_card_effect_label:set_text(self:translate("menu_cards_continue_operation", false))
			self._negative_card_effect_label:hide()
		end
	end
end

function ReadyUpGui:_update_peers()
	for control_peer, control in pairs(self._player_control_list) do
		local peer_present = false

		for _, peer in pairs(managers.network:session():all_peers()) do
			if peer == control_peer then
				peer_present = true
			end
		end

		local control_enabled = control:enabled()

		if not peer_present ~= not control_enabled then
			self._peer_no_longer_in_lobby(control_peer, "left")
		end
	end
end

function ReadyUpGui:update(t, dt)
	self:_show_characters()
	self:_show_player_challenge_card_info()
	self:_update_challenge_card_selected_icon()
	self:_update_status()
	self:_update_controls_contining_mission()
	self:_update_peers()

	if managers.challenge_cards:did_everyone_locked_sugested_card() then
		if not self._stinger_played then
			if managers.challenge_cards:get_suggested_cards() and managers.challenge_cards:get_suggested_cards()[1] and managers.challenge_cards:get_suggested_cards()[1].selected_sound then
				managers.menu_component:post_event(managers.challenge_cards:get_suggested_cards()[1].selected_sound)
			else
				managers.menu_component:post_event("ready_up_stinger")
			end

			self._stinger_played = true
		end

		for _, unit in pairs(self._spawned_character_units) do
			if not unit:anim_data().ready_transition_anim_finished then
				return
			end
		end

		if Network:is_server() then
			managers.network:session():set_state("in_game")
		elseif not self._synced_document_spawn_chance_to_host then
			managers.consumable_missions:sync_document_spawn_chance()

			self._synced_document_spawn_chance_to_host = true
		end

		if self._continuing_mission then
			managers.global_state:fire_event(GlobalStateManager.EVENT_START_RAID)
		elseif self._is_single_player then
			managers.challenge_cards:select_challenge_card(self._current_peer_index)
			managers.global_state:fire_event(GlobalStateManager.EVENT_START_RAID)
		else
			local challenge_cards = managers.challenge_cards:get_suggested_cards()
			local immidiate_start = true

			for _, card in pairs(challenge_cards) do
				if card.key_name ~= ChallengeCardsManager.CARD_PASS_KEY_NAME then
					immidiate_start = false

					break
				end
			end

			if immidiate_start then
				managers.global_state:fire_event(GlobalStateManager.EVENT_START_RAID)
			else
				ChallengeCardsGui.PHASE = 2

				managers.raid_menu:open_menu("challenge_cards_menu")
			end
		end
	end
end

function ReadyUpGui:_ct_players()
	local ct_players = 0

	for _, _ in pairs(self._player_control_list) do
		ct_players = ct_players + 1
	end

	return ct_players
end

function ReadyUpGui:_on_tab_right()
	local ct_players = self:_ct_players()
	local next_list_idx = (self._current_list_index + 1) % (ct_players + 1)

	if next_list_idx == 0 then
		next_list_idx = 1
	end

	for _, control in pairs(self._player_control_list) do
		if control:params().list_index == next_list_idx then
			control:on_mouse_clicked()

			return
		end
	end
end

function ReadyUpGui:_on_tab_left()
	local next_list_idx = self._current_list_index - 1

	if self._current_list_index == 1 then
		next_list_idx = self:_ct_players()
	end

	for _, control in pairs(self._player_control_list) do
		if control:params().list_index == next_list_idx then
			control:on_mouse_clicked()

			return
		end
	end
end

function ReadyUpGui:show_gamercard()
	Application:trace("[ReadyUpGui:show_gamercard] showing gamercard for peer " .. tostring(self._current_peer:name()))
	Application:debug("[ReadyUpGui:show_gamercard]", inspect(self._current_peer))
	self._callback_handler:view_gamer_card(self._current_peer:xuid())
end

function ReadyUpGui:bind_controller_inputs(is_current_player, can_leave)
	if managers.menu:is_pc_controller() then
		if is_current_player and not self._ready then
			local bindings = {
				{
					key = Idstring("menu_controller_face_bottom"),
					callback = callback(self, self, "_on_ready_up_button")
				}
			}

			self:set_controller_bindings(bindings, true)
		else
			self:set_controller_bindings({}, true)
		end

		local legend = {
			controller = {},
			keyboard = {}
		}

		self:set_legend(legend)

		return
	end

	local bindings = {
		{
			key = Idstring("menu_controller_shoulder_left"),
			callback = callback(self, self, "_on_tab_left")
		},
		{
			key = Idstring("menu_controller_shoulder_right"),
			callback = callback(self, self, "_on_tab_right")
		},
		{
			key = Idstring("menu_controller_face_right"),
			callback = callback(self, self, "back_pressed")
		}
	}
	local controler_legend = {}

	if not self._is_single_player then
		table.insert(controler_legend, "menu_legend_ready_up_tab")
	end

	if self._is_host and not is_current_player and not self._is_single_player then
		table.insert(bindings, {
			key = Idstring("menu_controller_face_right"),
			callback = callback(self, self, "_on_kick_button")
		})
		table.insert(controler_legend, "menu_legend_ready_up_kick")
	end

	if not self._ready and is_current_player and (managers.raid_job:selected_job() and managers.raid_job:selected_job().job_type == OperationsTweakData.JOB_TYPE_RAID and self._raid_card_count and self._raid_card_count > 0 or managers.raid_job:selected_job() and managers.raid_job:selected_job().job_type == OperationsTweakData.JOB_TYPE_OPERATION and self._operation_card_count and self._operation_card_count > 0) then
		table.insert(bindings, {
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "_on_select_card_button")
		})

		if not self._continuing_mission then
			if self._is_single_player then
				table.insert(controler_legend, "menu_legend_ready_up_select_card")
			else
				table.insert(controler_legend, "menu_legend_ready_up_suggest_card")
			end
		end
	end

	if can_leave then
		table.insert(bindings, {
			key = Idstring("menu_controller_face_left"),
			callback = callback(self, self, "_on_leave_lobby_button")
		})
		table.insert(controler_legend, "menu_legend_ready_up_leave")
	end

	if not self._ready then
		table.insert(bindings, {
			key = Idstring("menu_controller_face_bottom"),
			callback = callback(self, self, "_on_ready_up_button")
		})

		if self._is_single_player then
			table.insert(controler_legend, "menu_legend_ready_up_start")
		else
			table.insert(controler_legend, "menu_legend_ready_up_ready")
		end
	end

	if not is_current_player and _G.IS_XB1 then
		local gamercard_key = {
			key = Idstring("menu_controller_face_top"),
			callback = callback(self, self, "show_gamercard")
		}

		table.insert(bindings, gamercard_key)
		table.insert(controler_legend, "menu_legend_ready_up_gamercard")
	end

	self:set_controller_bindings(bindings, true)

	local legend = {
		controller = controler_legend,
		keyboard = {}
	}

	self:set_legend(legend)
end

function ReadyUpGui:back_pressed()
	return true
end
