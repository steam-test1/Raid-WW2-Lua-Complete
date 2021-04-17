local mvec3_dot = mvector3.dot
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_l_sq = mvector3.length_sq
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
GroupAIStateBase = GroupAIStateBase or class()
GroupAIStateBase._nr_important_cops = 3
GroupAIStateBase.BLAME_SYNC = {
	"empty",
	"gunfire",
	"sys_explosion",
	"default"
}
GroupAIStateBase.EVENT_SYNC = {
	"police_called",
	"enemy_weapons_hot",
	"phalanx_spawned"
}

function GroupAIStateBase:init()
	self:_init_misc_data()
end

function GroupAIStateBase:clean_up()
end

function GroupAIStateBase:update(t, dt)
	self._t = t

	self:_upd_criminal_suspicion_progress()

	if self._draw_drama then
		self:_debug_draw_drama(t)
	end

	self:_upd_debug_draw_attentions()
end

function GroupAIStateBase:paused_update(t, dt)
	if self._draw_drama then
		self:_debug_draw_drama(self._t)
	end
end

function GroupAIStateBase:get_assault_mode()
	return self._assault_mode
end

function GroupAIStateBase:get_hunt_mode()
	return self._hunt_mode
end

function GroupAIStateBase:is_AI_enabled()
	return self._ai_enabled
end

function GroupAIStateBase:set_AI_enabled(state)
	self._ai_enabled = state
	self._forbid_drop_in = state

	if Network:is_server() then
		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			local is_active = u_data.unit:brain():is_active()

			if state and not is_active or not state and is_active then
				u_data.unit:brain():set_active(state)
			end
		end

		for u_key, u_data in pairs(self._criminals) do
			if u_data.ai then
				local is_active = u_data.unit:brain():is_active()

				if state and not is_active or not state and is_active then
					u_data.unit:brain():set_active(state)
				end
			end
		end

		for u_key, u_data in pairs(managers.enemy:all_civilians()) do
			local is_active = u_data.unit:brain():is_active()

			if state and not is_active or not state and is_active then
				u_data.unit:brain():set_active(state)
			end
		end
	end

	managers.enemy:dispose_all_corpses()

	if not state then
		for u_key, unit in pairs(self._security_cameras) do
			unit:base():set_detection_enabled(false)
		end

		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			Network:detach_unit(u_data.unit)
			World:delete_unit(u_data.unit)
		end

		for u_key, u_data in pairs(self._criminals) do
			if u_data.ai then
				Network:detach_unit(u_data.unit)
				World:delete_unit(u_data.unit)
			elseif u_data.is_deployable then
				World:delete_unit(u_data.unit)
			end
		end

		for u_key, u_data in pairs(managers.enemy:all_civilians()) do
			Network:detach_unit(u_data.unit)
			World:delete_unit(u_data.unit)
		end

		for _, char in ipairs(managers.criminals:characters()) do
			if char.ai == false and alive(char.unit) then
				Network:detach_unit(char.unit)
				unit:set_extension_update_enabled(Idstring("movement"), false)
			end
		end
	end

	if state then
		if Application:editor() then
			self._editor_sim_rem_units = {}
		end
	elseif self._editor_sim_rem_units then
		for u_key, unit in pairs(self._editor_sim_rem_units) do
			if alive(unit) then
				World:delete_unit(unit)
			end
		end

		self._editor_sim_rem_units = nil
	end

	if not state then
		local all_deployed_equipment = World:find_units_quick("all", 14, 25, 26)

		for _, unit in ipairs(all_deployed_equipment) do
			if alive(unit) then
				World:delete_unit(unit)
			end
		end
	end
end

function GroupAIStateBase:_init_misc_data(clean_up)
	self._t = TimerManager:game():time()

	self:_parse_teammate_comments()

	self._is_server = Network:is_server()
	self._player_weapons_hot = nil
	self._enemy_weapons_hot = nil
	self._police_called = nil
	self._police_call_clbk_id = nil
	self._spawn_points = {}
	self._spawn_groups = {}
	self._spawning_groups = {}
	self._groups = {}
	self._flee_points = {}
	self._hostage_data = {}
	self._special_objectives = {}
	self._recurring_SO_groups = {}
	self._SO_groups = {}
	self._occasional_events = {}
	self._attention_objects = {
		all = {}
	}
	self._nav_seg_to_area_map = {}
	self._security_cameras = {}
	self._ecm_jammers = {}
	self._suspicion_hud_data = {}
	self._nr_successful_alarm_pager_bluffs = 0
	self._enemy_loot_drop_points = {}
	self._usable_turret_units = {}
	self._turret_units = {}
	local drama_tweak = tweak_data.drama
	self._drama_data = {
		amount = 0,
		zone = "low",
		last_calculate_t = 0,
		decay_period = tweak_data.drama.decay_period,
		low_p = drama_tweak.low,
		high_p = drama_tweak.peak,
		actions = drama_tweak.drama_actions,
		max_dis = drama_tweak.max_dis,
		dis_mul = drama_tweak.max_dis_mul
	}
	self._ai_enabled = true
	self._downs_during_assault = 0
	self._hostage_headcount = 0
	self._police_hostage_headcount = 0

	self:sync_assault_mode(false)

	self._fake_assault_mode = false
	self._whisper_mode = false

	self:set_bain_state(true)

	self._allow_dropin = true
	self._police = managers.enemy:all_enemies()

	if not clean_up then
		self._converted_police = {}
		self._char_criminals = {}
		self._criminals = {}
		self._ai_criminals = {}
		self._player_criminals = {}
	end

	self._special_units = {}
	self._special_unit_types = CharacterTweakData.SPECIAL_UNIT_TYPES
	self._anticipated_police_force = 0
	self._police_force = table.size(self._police)
	self._fleeing_civilians = {}
	self._hostage_keys = {}
	self._enemy_chatter = {}
	self._teamAI_last_combat_chatter_t = 5

	self:set_difficulty(0)

	if Network:is_server() then
		self:_set_rescue_state(true)
	end

	self._criminal_AI_respawn_clbks = {}
	self._listener_holder = EventListenerHolder:new()

	self:set_drama_draw_state(Global.drama_draw_state)

	self._alert_listeners = {}

	self:_init_unit_type_filters()
	self:_init_team_tables()

	self._phalanx_data = {
		minions = {}
	}
end

function GroupAIStateBase:_init_team_tables()
	self._teams = tweak_data.levels:get_team_setup()

	if self._teams then
		for id, team in pairs(self._teams) do
			team.id = id
		end
	end

	self:_call_listeners("team_def")
end

function GroupAIStateBase:add_alert_listener(id, clbk, filter_num, types, m_pos)
	local listener_data = {
		clbk = clbk,
		filter = filter_num,
		types = types,
		m_pos = m_pos
	}
	local all_listeners = self._alert_listeners

	for alert_type, _ in pairs(types) do
		local listeners_by_type = all_listeners[alert_type]

		if not listeners_by_type then
			listeners_by_type = {}
			all_listeners[alert_type] = listeners_by_type
		end

		local filter_str = managers.navigation:convert_access_filter_to_string(filter_num)
		local listeners_by_type_and_filter = listeners_by_type[filter_str]

		if not listeners_by_type_and_filter then
			listeners_by_type_and_filter = {}
			listeners_by_type[filter_str] = listeners_by_type_and_filter
		end

		listeners_by_type_and_filter[id] = listener_data
	end
end

function GroupAIStateBase:remove_alert_listener(id)
	for alert_type, listeners_by_type in pairs(self._alert_listeners) do
		for filter, listeners_by_type_and_filter in pairs(listeners_by_type) do
			listeners_by_type_and_filter[id] = nil

			if not next(listeners_by_type_and_filter) then
				listeners_by_type[filter] = nil
			end
		end

		if not next(listeners_by_type) then
			self._alert_listeners[alert_type] = nil
		end
	end
end

function GroupAIStateBase:propagate_alert(alert_data)
	if managers.network:session() and Network and not Network:is_server() then
		managers.network:session():send_to_host("propagate_alert", alert_data[1], alert_data[2], alert_data[3], alert_data[4], alert_data[5], alert_data[6])

		return
	end

	local nav_manager = managers.navigation
	local access_func = nav_manager.check_access
	local alert_type = alert_data[1]
	local all_listeners = self._alert_listeners
	local listeners_by_type = all_listeners[alert_type]

	if listeners_by_type then
		local proximity_chk_func = nil
		local alert_epicenter = alert_data[2]

		if alert_epicenter then
			local alert_rad_sq = alert_data[3] * alert_data[3]

			function proximity_chk_func(listener_pos)
				return mvec3_dis_sq(alert_epicenter, listener_pos) < alert_rad_sq
			end
		else
			function proximity_chk_func()
				return true
			end
		end

		local alert_filter = alert_data[4]
		local clbks = nil

		for filter_str, listeners_by_type_and_filter in pairs(listeners_by_type) do
			local key, listener = next(listeners_by_type_and_filter, nil)
			local filter_num = listener.filter

			if access_func(nav_manager, filter_num, alert_filter, nil) then
				for id, listener in pairs(listeners_by_type_and_filter) do
					if proximity_chk_func(listener.m_pos) then
						clbks = clbks or {}

						table.insert(clbks, listener.clbk)
					end
				end
			end
		end

		if clbks then
			for _, clbk in ipairs(clbks) do
				clbk(alert_data)
			end
		end
	end
end

function GroupAIStateBase:set_drama_decay_period(period)
	self:_claculate_drama_value()

	self._drama_data.decay_period = period
	self._drama_data.last_calculate_t = self._t
end

function GroupAIStateBase:_claculate_drama_value()
	local drama_data = self._drama_data
	local dt = self._t - drama_data.last_calculate_t
	local adj = -dt / drama_data.decay_period
	drama_data.last_calculate_t = self._t

	self:_add_drama(adj)
end

function GroupAIStateBase:_add_drama(amount)
	local drama_data = self._drama_data
	local new_val = math.clamp(drama_data.amount + amount, 0, 1)
	drama_data.amount = new_val

	if drama_data.high_p < new_val then
		if drama_data.zone ~= "high" then
			drama_data.zone = "high"

			self:_on_drama_zone_change()
		end
	elseif new_val < drama_data.low_p then
		if drama_data.zone ~= "low" then
			drama_data.zone = "low"

			self:_on_drama_zone_change()
		end
	elseif drama_data.zone then
		drama_data.zone = nil

		self:_on_drama_zone_change()
	end
end

function GroupAIStateBase:_on_drama_zone_change()
end

function GroupAIStateBase:calm_ai()
	self._player_weapons_hot = false
	self._enemy_weapons_hot = false
	self._police_called = false

	if Network:is_server() then
		for crim_key, crim in pairs(self:all_AI_criminals()) do
			if not crim.unit:movement():cool() then
				if not crim.unit:anim_data().stand then
					crim.unit:movement():action_request({
						body_part = 4,
						type = "stand"
					})
				end

				if not crim.unit:anim_data().upper_body_empty then
					crim.unit:movement():action_request({
						sync = true,
						body_part = 3,
						type = "idle"
					})
				end

				crim.unit:movement():set_cool(true)
				crim.unit:movement():set_stance_by_code(1)
				crim.unit:brain():set_objective()

				for key, data in pairs(self._police) do
					data.unit:brain():on_criminal_neutralized(crim_key)
				end
			end
		end
	end
end

function GroupAIStateBase:on_player_weapons_hot()
	if not self._player_weapons_hot then
		self._player_weapons_hot = true

		self:_call_listeners("player_weapons_hot")
	end
end

function GroupAIStateBase:player_weapons_hot()
	return self._player_weapons_hot
end

function GroupAIStateBase:on_police_called(called_reason)
	if not self._ai_enabled then
		return
	end

	local was_called = self._police_called
	self._police_called = true

	managers.mission:call_global_event("police_called")
	self:_call_listeners("police_called")

	if was_called then
		return
	end

	if not self._police_call_clbk_id then
		self:set_reason_called(called_reason)
		managers.network:session():send_to_peers_synched("group_ai_event", self:get_sync_event_id("police_called"), self:get_sync_blame_id(self._called_reason))

		self._police_call_clbk_id = "on_enemy_weapons_hot"

		managers.enemy:add_delayed_clbk(self._police_call_clbk_id, callback(self, self, "on_enemy_weapons_hot", true), TimerManager:game():time() + 2)
	end

	managers.queued_tasks:queue("set_mountable_turrets", self.set_available_turrets_as_mountable, self, nil, 3)
end

function GroupAIStateBase:teleport_team_ai()
	local distance_treshold = tweak_data.criminals.loud_teleport_distance_treshold * tweak_data.criminals.loud_teleport_distance_treshold

	for _, char_data in pairs(managers.criminals:ai_criminals()) do
		local unit = char_data.unit
		local min_distance = -1
		local target_unit = nil

		if alive(unit) and not unit:movement():downed() then
			for _, peer in pairs(managers.network:session():all_peers()) do
				if alive(peer._unit) then
					local player_pos = peer._unit:position()
					local distance = mvector3.distance_sq(unit:position(), player_pos)

					if min_distance < 0 or distance < min_distance then
						min_distance = distance
						target_unit = peer._unit
					end
				end
			end

			if distance_treshold < min_distance then
				local cones_to_send = TeamAILogicTravel._unit_cones(managers.player:players(), 400)
				local follow_tracker = target_unit:movement():nav_tracker()
				local dest_nav_seg_id = follow_tracker:nav_segment()
				local dest_area = managers.groupai:state():get_area_from_nav_seg_id(dest_nav_seg_id)
				local follow_pos = follow_tracker:field_position()
				local cover = managers.navigation:find_cover_in_nav_seg_excluding_cones(dest_area.nav_segs, 400, follow_pos, nil, cones_to_send)
				local target_pos = cover and cover[NavigationManager.COVER_POSITION] or follow_tracker:field_position()

				Application:debug("[GroupAIStateBase:teleport_team_ai] Teleporting teamAI to pos", unit, target_pos, cover)

				local action_desc = {
					body_part = 1,
					type = "warp",
					position = target_pos
				}

				managers.queued_tasks:queue(nil, self._do_teleport_ai, self, {
					action_desc = action_desc,
					unit = unit
				}, math.rand(1))
			end
		end
	end
end

function GroupAIStateBase:_do_teleport_ai(params)
	local u = params.unit

	if alive(u) then
		if not u:movement()._active_actions[1] or u:movement()._active_actions[1]:type() ~= "hurt" or u:movement()._active_actions[1]:hurt_type() ~= "death" then
			u:movement():action_request(params.action_desc)
		end
	end
end

function GroupAIStateBase:set_available_turrets_as_mountable()
	for _, turret in pairs(self._usable_turret_units) do
		if turret:is_available() then
			turret:set_mountable()
		end
	end
end

function GroupAIStateBase:set_reason_called(called_reason)
	self._called_reason = self._called_reason or called_reason
end

function GroupAIStateBase:on_gangsters_called(called_reason)
	self:on_police_called(called_reason)
end

function GroupAIStateBase:on_enemy_weapons_hot(is_delayed_callback)
	Application:debug("[GroupAIStateBase:on_enemy_weapons_hot]", self._police_call_clbk_id, is_delayed_callback)

	if not self._ai_enabled then
		return
	end

	if not is_delayed_callback and self._police_call_clbk_id then
		managers.enemy:remove_delayed_clbk(self._police_call_clbk_id)
	end

	self._police_call_clbk_id = nil

	managers.enemy:set_corpse_disposal_enabled(true)

	if not self._enemy_weapons_hot then
		self._police_called = true
		self._enemy_weapons_hot = true
		local worlds = managers.groupai:state():get_last_world_ids_for_criminals()

		if #worlds == 0 then
			return
		end

		for _, world_id in ipairs(worlds) do
			managers.worldcollection:set_alarm_for_world_id(world_id, true)
		end

		managers.music:raid_music_state_change("control")

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("group_ai_event", self:get_sync_event_id("enemy_weapons_hot"), self:get_sync_blame_id(self._called_reason))
		else
			print("here it would crash before")
		end

		self._radio_clbk = callback(self, self, "_radio_chatter_clbk")

		managers.enemy:add_delayed_clbk("_radio_chatter_clbk", self._radio_clbk, Application:time() + 30)

		if not self._switch_to_not_cool_clbk_id then
			self._switch_to_not_cool_clbk_id = "GroupAI_delayed_not_cool"

			managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_not_cool"), self._t + 1)
		end

		if not self._hstg_hint_clbk then
			self._first_hostage_hint = true
			self._hstg_hint_clbk = callback(self, self, "_hostage_hint_clbk")

			managers.enemy:add_delayed_clbk("_hostage_hint_clbk", self._hstg_hint_clbk, Application:time() + 45)
		end

		managers.mission:call_global_event("police_weapons_hot")
		self:_call_listeners("enemy_weapons_hot")
		self:_clear_criminal_suspicion_data()
	end
end

function GroupAIStateBase:on_police_weapons_hot(called_reason)
	self:set_reason_called(called_reason)
	self:on_enemy_weapons_hot(false)
end

function GroupAIStateBase:on_gangster_weapons_hot(called_reason)
	self:on_police_weapons_hot(called_reason)
end

function GroupAIStateBase:is_police_called()
	return self._police_called
end

function GroupAIStateBase:enemy_weapons_hot()
	return self._enemy_weapons_hot
end

function GroupAIStateBase:_clbk_switch_enemies_to_not_cool()
	for u_key, unit_data in pairs(self._police) do
		local nav_seg = unit_data.tracker:nav_segment()
		local world_id = managers.navigation:get_world_for_nav_seg(nav_seg)
		local alarm = managers.worldcollection:get_alarm_for_world(world_id)

		if unit_data.unit:movement():cool() and alarm and unit_data.assigned_area then
			unit_data.unit:movement():set_cool(false)

			if unit_data.unit:brain():is_available_for_assignment() then
				local new_objective = {
					is_default = true,
					stance = "hos",
					attitude = "engage",
					type = "free"
				}

				unit_data.unit:brain():set_objective(new_objective)
			end

			managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_not_cool"), self._t + math.random() * 1)

			return
		end
	end

	self:propagate_alert({
		"vo_cbt",
		[4] = self._unit_type_filter.civilian
	})

	self._switch_to_not_cool_clbk_id = nil
end

function GroupAIStateBase:_clbk_switch_enemies_to_cool()
	for u_key, unit_data in pairs(self._police) do
		if not unit_data.unit:movement():cool() then
			unit_data.unit:movement():set_cool(true)

			if unit_data.unit:brain():is_available_for_assignment() then
				local new_objective = {
					is_default = true,
					stance = "ntl",
					attitude = "engage",
					type = "free"
				}

				Application:debug("[GroupAIStateBase:_clbk_switch_enemies_to_cool]", u_key)
				unit_data.unit:brain():set_objective(new_objective)
			end

			managers.enemy:add_delayed_clbk(self._switch_to_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_cool"), self._t + math.random() * 1)

			return
		end
	end

	self._switch_to_cool_clbk_id = nil
end

function GroupAIStateBase:_hostage_hint_clbk()
	if not self._ai_enabled then
		return
	end

	if not self._first_hostage_hint then
		self._hstg_hint_clbk = nil
	end

	if self._hostage_headcount == 0 then
		if self._first_hostage_hint then
			self._first_hostage_hint = nil

			managers.enemy:add_delayed_clbk("_hostage_hint_clbk", self._hstg_hint_clbk, Application:time() + 120)
		end
	else
		self._hstg_hint_clbk = nil
	end
end

function GroupAIStateBase:_radio_chatter_clbk()
	if self._ai_enabled and not self:get_assault_mode() then
		local optimal_dist = 500
		local best_dist, best_cop, radio_msg = nil

		for _, c_record in pairs(self._player_criminals) do
			for i, e_key in ipairs(c_record.important_enemies) do
				local cop = self._police[e_key]
				local use_radio = cop.char_tweak.use_radio

				if use_radio then
					local dist = math.abs(mvector3.distance(cop.m_pos, c_record.m_pos))

					if not best_dist or dist < best_dist then
						best_dist = dist
						best_cop = cop
						radio_msg = use_radio
					end
				end
			end
		end

		if best_cop then
			best_cop.unit:sound():play(radio_msg, nil, true)
		end
	end

	self._radio_clbk = callback(self, self, "_radio_chatter_clbk")

	managers.enemy:add_delayed_clbk("_radio_chatter_clbk", self._radio_clbk, Application:time() + 30 + math.random(0, 20))
end

function GroupAIStateBase:police_hostage_count()
	return self._police_hostage_headcount
end

function GroupAIStateBase:hostage_count()
	return self._hostage_headcount
end

function GroupAIStateBase:has_room_for_police_hostage()
	local nr_hostages_allowed = 0

	for u_key, u_data in pairs(self._player_criminals) do
		if u_data.unit:base().is_local_player then
			if managers.player:has_category_upgrade("player", "intimidate_enemies") then
				nr_hostages_allowed = nr_hostages_allowed + 1
			end
		elseif u_data.unit:base():upgrade_value("player", "intimidate_enemies") then
			nr_hostages_allowed = nr_hostages_allowed + 1
		end
	end

	return nr_hostages_allowed > self._police_hostage_headcount + table.size(self._converted_police)
end

GroupAIStateBase.PATH = "gamedata/comments"
GroupAIStateBase.FILE_EXTENSION = "comment"
GroupAIStateBase.FULL_PATH = GroupAIStateBase.PATH .. "." .. GroupAIStateBase.FILE_EXTENSION

function GroupAIStateBase:_parse_teammate_comments()
	local list = PackageManager:script_data(self.FILE_EXTENSION:id(), self.PATH:id())
	self.teammate_comments = {}
	self.teammate_comment_names = {}

	for _, data in ipairs(list) do
		if data._meta == "comment" then
			self:_parse_teammate_comment(data)
		else
			Application:error("Unknown node \"" .. tostring(data._meta) .. "\" in \"" .. self.FULL_PATH .. "\". Expected \"comment\" node.")
		end
	end
end

function GroupAIStateBase:_parse_teammate_comment(data)
	local event = data.event
	local allow = data.allow_first_person or false

	table.insert(self.teammate_comments, {
		event = event,
		allow_first_person = allow
	})
	table.insert(self.teammate_comment_names, event)
end

function GroupAIStateBase:teammate_comment(trigger_unit, message, pos, pos_based, radius, sync)
	if radius == 0 then
		radius = nil
	end

	local message_id = nil

	for index, sound in ipairs(self.teammate_comment_names) do
		if sound == message then
			message_id = index

			break
		end
	end

	if not message_id then
		Application:error("[GroupAIStateBase:teammate_comment] " .. message .. " cannot be found")

		return
	end

	local allow_first_person = self.teammate_comments[message_id].allow_first_person
	local close_pos = pos_based and pos or managers.player:player_unit() and managers.player:player_unit():position() or Vector3()
	local close_criminal, close_criminal_d = nil

	if trigger_unit and alive(trigger_unit) then
		radius = nil
		close_criminal = trigger_unit
	else
		for u_key, u_data in pairs(self._criminals) do
			if not u_data.is_deployable and (allow_first_person or not u_data.unit:base().is_local_player) and alive(u_data.unit) and not u_data.unit:movement():downed() and not u_data.unit:sound():speaking() then
				local d = mvector3.distance_sq(close_pos, u_data.m_pos)
				local ed = radius and (pos_based and d or mvector3.distance_sq(pos, u_data.m_pos))

				if (not radius or ed < radius * radius) and (not close_criminal_d or d < close_criminal_d) then
					close_criminal = u_data.unit
					close_criminal_d = d
				end
			end
		end
	end

	if close_criminal then
		close_criminal:sound():say(message, false)
	end

	if sync then
		if trigger_unit and alive(trigger_unit) then
			managers.network:session():send_to_peers_synched("sync_teammate_comment_instigator", trigger_unit, message_id)
		else
			managers.network:session():send_to_peers_synched("sync_teammate_comment", message_id, pos or Vector3(0, 0, 0), pos_based, radius or 0)
		end
	end
end

function GroupAIStateBase:sync_teammate_comment(message, pos, pos_based, radius)
	self:teammate_comment(nil, self.teammate_comment_names[message], pos, pos_based, radius, false)
end

function GroupAIStateBase:sync_teammate_comment_instigator(unit, message)
	self:teammate_comment(unit, self.teammate_comment_names[message], nil, false, nil, false)
end

function GroupAIStateBase:on_hostage_state(state, key, police, skip_announcement)
	local d = state and 1 or -1

	if state then
		for i, h_key in ipairs(self._hostage_keys) do
			if key == h_key then
				debug_pause("double-registered hostage")

				return
			end
		end

		table.insert(self._hostage_keys, key)
	else
		local found = false

		for i, h_key in ipairs(self._hostage_keys) do
			if key == h_key then
				table.remove(self._hostage_keys, i)

				found = true

				break
			end
		end

		if not found then
			return
		end
	end

	self._hostage_headcount = self._hostage_headcount + d

	self:sync_hostage_headcount()

	if state and not skip_announcement and self._hostage_headcount == 1 and self._task_data.assault.disabled then
		-- Nothing
	end

	if police then
		self._police_hostage_headcount = self._police_hostage_headcount + d
	end

	if state and self._hstg_hint_clbk then
		managers.enemy:remove_delayed_clbk("_hostage_hint_clbk")

		self._hstg_hint_clbk = nil
	end

	if self._hostage_headcount ~= #self._hostage_keys then
		debug_pause("[GroupAIStateBase:on_hostage_state] Headcount mismatch", self._hostage_headcount, #self._hostage_keys, key, inspect(self._hostage_keys))
	end
end

function GroupAIStateBase:_police_announce_retreat()
end

function GroupAIStateBase:set_difficulty(value)
	self._difficulty_value = math.clamp(value, 0, 1)

	self:_calculate_difficulty_ratio()
end

function GroupAIStateBase:get_difficulty()
	return self._difficulty_value
end

function GroupAIStateBase:set_debug_draw_state(b)
	if b and not self._draw_enabled then
		local ws = Overlay:newgui():create_screen_workspace()
		local panel = ws:panel()
		self._AI_draw_data = {
			brush_area = Draw:brush(Color(0.33, 1, 1, 1)),
			brush_guard = Draw:brush(Color(0.5, 0, 0, 1)),
			brush_investigate = Draw:brush(Color(0.5, 0, 1, 0)),
			brush_defend = Draw:brush(Color(0.5, 0, 0.3, 0)),
			brush_free = Draw:brush(Color(0.5, 0.6, 0.3, 0)),
			brush_act = Draw:brush(Color(0.5, 1, 0.8, 0.8)),
			brush_misc = Draw:brush(Color(0.5, 1, 1, 1)),
			brush_suppressed = Draw:brush(Color(0.3, 0.85, 0.9, 0.2)),
			brush_detection = Draw:brush(Color(0.6, 1, 1, 1)),
			brush_ai_vision_c1 = Draw:brush(Color(0.4, 0.2, 0.2, 1)),
			brush_ai_vision_c2 = Draw:brush(Color(0.4, 0.2, 0.8, 0.8)),
			brush_ai_vision_c3 = Draw:brush(Color(0.4, 0.8, 0.8, 0.2)),
			pen_focus_enemy = Draw:pen(Color(0.5, 1, 0.2, 0)),
			brush_focus_player = Draw:brush(Color(0.5, 1, 0, 0)),
			pen_group = Draw:pen(Color(1, 0.1, 0.4, 0.8)),
			workspace = ws,
			panel = panel,
			logic_name_texts = {},
			unit_type_texts = {},
			unit_health_bars = {},
			unit_health_bars_bg = {},
			unit_health_bar_vals = {},
			rect_bgs = {},
			group_id_color = Color(1, 0.7, 0.1, 0),
			group_id_texts = {}
		}
	elseif not b and self._draw_enabled then
		Overlay:newgui():destroy_workspace(self._AI_draw_data.workspace)

		self._AI_draw_data = nil
	end

	self._draw_enabled = b
end

function GroupAIStateBase:on_unit_detection_updated(unit)
	if self._draw_enabled then
		local draw_pos = unit:movement():m_head_pos()

		self._AI_draw_data.brush_detection:cone(draw_pos, draw_pos + math.UP * 40, 30)
	end
end

function GroupAIStateBase:_calculate_difficulty_ratio()
	local ramp = tweak_data.group_ai.difficulty_curve_points
	local diff = math.clamp(self._difficulty_value, self._difficulty_value, 1)
	local i = 1

	while ramp[i] and ramp[i] < diff do
		i = i + 1
	end

	self._difficulty_point_index = i
	self._difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
end

function GroupAIStateBase:get_difficulty_dependent_value(tweak_values)
	return math.lerp(tweak_values[self._difficulty_point_index], tweak_values[self._difficulty_point_index + 1], self._difficulty_ramp)
end

function GroupAIStateBase:criminal_spotted(unit)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]
	local prev_seg = u_sighting.seg
	local prev_area = u_sighting.area
	local seg = u_sighting.tracker:nav_segment()

	if u_sighting.undetected then
		u_sighting.undetected = nil
	end

	u_sighting.seg = seg

	u_sighting.tracker:m_position(u_sighting.pos)

	u_sighting.det_t = self._t
	local area = nil

	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end

	if not area then
		debug_pause("[GroupAIStateBase] area not found for seg id  ", seg)

		return
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end

	if area.is_safe then
		area.is_safe = nil

		self:_on_area_safety_status(area, {
			reason = "criminal",
			record = u_sighting
		})
	end

	if self._whisper_mode then
		managers.mission:call_global_event("criminal_detected")
	end
end

function GroupAIStateBase:get_last_world_ids_for_criminals()
	local worlds = {}

	for key, data in pairs(self._criminals) do
		if data._last_world_id then
			table.insert(worlds, data._last_world_id)
		end
	end

	return worlds
end

function GroupAIStateBase:on_criminal_nav_seg_change(unit, nav_seg_id)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]

	if not u_sighting then
		return
	end

	local player_world_id = managers.navigation:get_world_for_nav_seg(nav_seg_id)

	if player_world_id and managers.worldcollection:worlddefinition_by_id(player_world_id) then
		u_sighting._last_world_id = player_world_id
	end

	local prev_seg = u_sighting.seg
	local prev_area = u_sighting.area

	if u_sighting.undetected then
		u_sighting.undetected = nil
	end

	u_sighting.seg = nav_seg_id

	u_sighting.tracker:m_position(u_sighting.pos)

	u_sighting.det_t = self._t
	local area = nil

	if prev_area and prev_area.nav_segs[nav_seg_id] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(nav_seg_id)
	end

	if not area then
		return
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end

	if area.is_safe then
		area.is_safe = nil

		self:_on_area_safety_status(area, {
			reason = "criminal",
			record = u_sighting
		})
	end
end

function GroupAIStateBase:criminal_record(u_key)
	return self._criminals[u_key]
end

function GroupAIStateBase:on_enemy_engaging(unit, other_u_key)
	local u_key = unit:key()
	local e_data = self._police[u_key]

	if not e_data then
		debug_pause_unit(unit, "[GroupAIStateBase:on_enemy_engaging] non-enemy", unit)

		return
	end

	local sighting = self._criminals[other_u_key]
	local force = sighting.engaged_force + 1
	sighting.engaged_force = force
	sighting.engaged[u_key] = e_data
end

function GroupAIStateBase:on_enemy_disengaging(unit, other_u_key)
	local u_key = unit:key()
	local sighting = self._criminals[other_u_key]

	if not sighting then
		return
	end

	local force = sighting.engaged_force - 1
	sighting.engaged_force = force
	sighting.engaged[u_key] = nil
end

function GroupAIStateBase:on_tase_start(cop_key, criminal_key)
	self._criminals[criminal_key].being_tased = cop_key
end

function GroupAIStateBase:on_tase_end(criminal_key)
	local record = self._criminals[criminal_key]

	if record then
		self._criminals[criminal_key].being_tased = nil
	end
end

function GroupAIStateBase:on_arrest_start(enemy_key, criminal_key)
	local sighting = self._criminals[criminal_key]
	local arrest = sighting.being_arrested

	if arrest then
		sighting.being_arrested[enemy_key] = true
	else
		sighting.being_arrested = {
			[enemy_key] = true
		}
	end
end

function GroupAIStateBase:on_arrest_end(enemy_key, criminal_key)
	local sighting = self._criminals[criminal_key]

	if sighting.being_arrested then
		sighting.being_arrested[enemy_key] = nil

		if not next(sighting.being_arrested) then
			sighting.being_arrested = nil
		end
	end
end

function GroupAIStateBase:on_simulation_started()
	self:set_AI_enabled(true)

	self._t = TimerManager:game():time()
	self._spawn_points = {}
	self._spawn_groups = {}
	self._spawning_groups = {}
	self._groups = {}
	self._hostage_data = {}
	self._enemy_loot_drop_points = {}
	local drama_tweak = tweak_data.drama
	self._drama_data = {
		amount = 0,
		zone = "low",
		last_calculate_t = 0,
		decay_period = tweak_data.drama.decay_period,
		low_p = drama_tweak.low,
		high_p = drama_tweak.peak,
		actions = drama_tweak.drama_actions,
		max_dis = drama_tweak.max_dis,
		dis_mul = drama_tweak.max_dis_mul
	}
	self._ai_enabled = true
	self._hostage_headcount = 0
	self._police = managers.enemy:all_enemies()
	self._police_force = table.size(self._police)
	self._converted_police = {}

	self:set_difficulty(0)

	self._criminals = {}
	self._ai_criminals = {}
	self._player_criminals = {}
	self._special_unit_types = CharacterTweakData.SPECIAL_UNIT_TYPES
	self._listener_holder = EventListenerHolder:new()

	self:set_drama_draw_state(Global.drama_draw_state)
	self:_init_team_tables()
end

function GroupAIStateBase:on_simulation_ended()
	self:set_AI_enabled(false)
	self:set_debug_draw_state(false)

	self._t = TimerManager:game():time()
	self._player_weapons_hot = nil
	self._enemy_weapons_hot = nil
	self._police_called = nil
	self._spawn_points = {}
	self._spawn_groups = {}
	self._spawning_groups = {}
	self._groups = {}
	self._flee_points = {}
	self._hostage_data = {}
	self._special_objectives = {}
	self._recurring_SO_groups = {}
	self._SO_groups = {}
	self._occasional_events = {}
	self._attention_objects = {
		all = {}
	}
	self._nav_seg_to_area_map = {}
	self._security_cameras = {}
	self._alert_listeners = {}
	self._ecm_jammers = {}
	self._enemy_loot_drop_points = {}
	self._hostage_headcount = 0
	self._enemy_chatter = {}
	self._nr_successful_alarm_pager_bluffs = 0
	self._forbid_drop_in = nil
	self._whisper_mode = false

	if self._police_call_clbk_id then
		managers.enemy:remove_delayed_clbk(self._police_call_clbk_id)

		self._police_call_clbk_id = nil
	end

	if self._gameover_clbk then
		managers.enemy:remove_delayed_clbk("_gameover_clbk")

		self._gameover_clbk = nil
	end

	local drama_tweak = tweak_data.drama
	self._drama_data = {
		amount = 0,
		zone = "low",
		last_calculate_t = 0,
		decay_period = tweak_data.drama.decay_period,
		low_p = drama_tweak.low,
		high_p = drama_tweak.peak,
		actions = drama_tweak.drama_actions,
		max_dis = drama_tweak.max_dis,
		dis_mul = drama_tweak.max_dis_mul
	}
	self._police = managers.enemy:all_enemies()
	self._converted_police = {}

	for char_name, id in pairs(self._criminal_AI_respawn_clbks) do
		managers.enemy:remove_delayed_clbk(id)
	end

	self._criminal_AI_respawn_clbks = {}

	self:set_drama_draw_state(false)
	self:_init_unit_type_filters()

	for _, turret in ipairs(self._usable_turret_units) do
		if turret then
			turret:_sound_autofire_end()
		end
	end
end

function GroupAIStateBase:on_enemy_registered(unit)
	if self._anticipated_police_force > 0 then
		self._anticipated_police_force = self._anticipated_police_force - 1
	else
		self._police_force = self._police_force + 1
	end

	local unit_type = unit:base()._tweak_table
	local tweak_table = tweak_data.character[unit_type]
	local special_type = tweak_table and tweak_table.special_type

	if special_type and self._special_unit_types[special_type] then
		self:register_special_unit(unit:key(), special_type)
	end

	if Network:is_client() then
		unit:movement():set_team(self._teams[tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end

function GroupAIStateBase:is_enemy_special(unit)
	local category_name = unit:base()._tweak_table
	local category = self._special_units[category_name]

	if not category then
		return false
	end

	return category[unit:key()]
end

function GroupAIStateBase:criminal_hurt_drama(unit, attacker, dmg_percent)
	local drama_data = self._drama_data
	local drama_amount = drama_data.actions.criminal_hurt * dmg_percent

	if alive(attacker) then
		local max_dis = drama_data.max_dis
		local dis_lerp = math.min(1, mvector3.distance(attacker:movement():m_pos(), unit:movement():m_pos()) / drama_data.max_dis)
		dis_lerp = math.lerp(1, drama_data.dis_mul, dis_lerp)
		drama_amount = drama_amount * dis_lerp
	end

	self:_add_drama(drama_amount)
end

function GroupAIStateBase:on_enemy_unregistered(unit)
	if self:is_unit_in_phalanx_minion_data(unit:key()) then
		self:unregister_phalanx_minion(unit:key())
		CopLogicPhalanxMinion:chk_should_breakup()
		CopLogicPhalanxMinion:chk_should_reposition()
	end

	self._police_force = self._police_force - 1
	local u_key = unit:key()

	self:_clear_character_criminal_suspicion_data(u_key)

	if not Network:is_server() then
		return
	end

	local e_data = self._police[u_key]

	if e_data and e_data.importance > 0 then
		for c_key, c_data in pairs(self._player_criminals) do
			local imp_keys = c_data.important_enemies

			for i, test_e_key in ipairs(imp_keys) do
				if test_e_key == u_key then
					table.remove(imp_keys, i)
					table.remove(c_data.important_dis, i)

					break
				end
			end
		end
	end

	for crim_key, record in pairs(self._ai_criminals) do
		record.unit:brain():on_cop_neutralized(u_key)
	end

	local unit_type = unit:base()._tweak_table
	local tweak_table = tweak_data.character[unit_type]
	local special_type = tweak_table and tweak_table.special_type

	if special_type and self._special_unit_types[special_type] then
		self:unregister_special_unit(unit:key(), special_type)
	end

	local dead = unit:character_damage():dead()

	if e_data and e_data.group then
		self:_remove_group_member(e_data.group, u_key, dead)
	end

	if e_data and e_data.assigned_area and dead then
		local spawn_point = unit:unit_data().mission_element

		if spawn_point then
			local spawn_pos = spawn_point:value("position")
			local u_pos = e_data.m_pos

			if mvector3.distance(spawn_pos, u_pos) < 700 and math.abs(spawn_pos.z - u_pos.z) < 300 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								sp_data.delay_t = math.max(sp_data.delay_t, self._t + math.random(30, 60))

								break
							end
						end

						if found then
							break
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:on_civilian_unregistered(unit)
	local u_key = unit:key()

	self:_clear_character_criminal_suspicion_data(u_key)

	local u_data = managers.enemy:all_civilians()[u_key]

	if u_data and u_data.hostage_following then
		self:on_hostage_follow(u_data.hostage_following, unit, false)
	end
end

function GroupAIStateBase:report_aggression(unit)
	self._criminals[unit:key()].assault_t = self._t
end

function GroupAIStateBase:register_fleeing_civilian(u_key, unit)
	self._fleeing_civilians[u_key] = unit
end

function GroupAIStateBase:unregister_fleeing_civilian(u_key)
	self._fleeing_civilians[u_key] = nil
end

function GroupAIStateBase:register_special_unit(u_key, category_name)
	local category = self._special_units[category_name]

	if not category then
		category = {}
		self._special_units[category_name] = category
	end

	category[u_key] = true
end

function GroupAIStateBase:unregister_special_unit(u_key, category_name)
	local category = self._special_units[category_name]

	if category then
		category[u_key] = nil

		if not next(category) then
			self._special_units[category_name] = nil
		end
	end
end

function GroupAIStateBase:register_criminal(unit)
	local u_key = unit:key()
	local ext_mv = unit:movement()
	local tracker = ext_mv:nav_tracker()
	local world_id = 0
	local seg = nil

	if tracker then
		seg = tracker:nav_segment()
		world_id = managers.navigation:get_world_for_nav_seg(seg)
	end

	local is_AI = nil

	if unit:base()._tweak_table then
		is_AI = true
	end

	local is_deployable = unit:base().sentry_gun
	local u_sighting = {
		arrest_timeout = -100,
		engaged_force = 0,
		dispatch_t = 0,
		undetected = true,
		unit = unit,
		ai = is_AI,
		tracker = tracker,
		seg = seg,
		area = self:get_area_from_nav_seg_id(seg),
		pos = mvector3.copy(ext_mv:m_pos()),
		m_pos = ext_mv:m_pos(),
		m_det_pos = ext_mv:m_detect_pos(),
		det_t = self._t,
		engaged = {},
		important_enemies = not is_AI and {} or nil,
		important_dis = not is_AI and {} or nil,
		is_deployable = is_deployable,
		_last_world_id = world_id
	}
	self._criminals[u_key] = u_sighting

	if is_AI then
		self._ai_criminals[u_key] = u_sighting
		u_sighting.so_access = managers.navigation:convert_access_flag(tweak_data.character[unit:base()._tweak_table].access)
	elseif not is_deployable then
		self._player_criminals[u_key] = u_sighting
	end

	if not is_deployable then
		self._char_criminals[u_key] = u_sighting
	end

	if not unit:base().is_local_player then
		managers.enemy:on_criminal_registered(unit)
	end

	if is_AI then
		unit:movement():set_team(self._teams[tweak_data.levels:get_default_team_ID("player")])
	end
end

function GroupAIStateBase:unregister_criminal(unit)
	local u_key = unit:key()
	local record = self._criminals[u_key]
	local is_server = self._is_server

	if is_server and record.status ~= "dead" then
		record.status = "dead"

		for key, data in pairs(self._police) do
			data.unit:brain():on_criminal_neutralized(u_key)
		end
	end

	if is_server and record.minions then
		local minions = clone(record.minions)

		for u_key, u_data in pairs(minions) do
			u_data.unit:character_damage():damage_mission({
				damage = u_data.unit:character_damage()._HEALTH_INIT + 1
			})
		end

		record.minions = nil
	end

	if record.ai then
		self._ai_criminals[u_key] = nil

		if is_server and not managers.worldcollection.level_transition_in_progress then
			local objective = unit:brain():objective()

			if objective and objective.fail_clbk then
				local fail_clbk = objective.fail_clbk
				objective.fail_clbk = nil

				fail_clbk(unit)
			end
		end
	else
		if Network:is_server() and not managers.worldcollection.level_transition_in_progress then
			for i, e_key in ipairs(record.important_enemies) do
				self:_adjust_cop_importance(e_key, -1)
			end
		end

		self._player_criminals[u_key] = nil
	end

	self._char_criminals[u_key] = nil
	self._criminals[u_key] = nil

	managers.hud:remove_hud_info_by_unit(unit)

	if not unit:base().is_local_player then
		managers.enemy:on_criminal_unregistered(u_key)
	end

	PlayerMovement.check_players_in_foxhole()
	self:check_gameover_conditions()
end

function GroupAIStateBase:is_ai_trade_possible()
	if managers.groupai:state():whisper_mode() then
		return false
	end

	if next(self._player_criminals) then
		return false
	end

	local ai_disabled = true

	for u_key, u_data in pairs(self._ai_criminals) do
		if u_data.status ~= "dead" and u_data.status ~= "disabled" then
			ai_disabled = false

			break
		end
	end

	return not ai_disabled and (self._hostage_headcount > 0 or next(self._converted_police) or managers.trade:is_trading())
end

function GroupAIStateBase:check_gameover_conditions()
	if not Network:is_server() or managers.platform:presence() ~= "Playing" or setup:has_queued_exec() then
		return false
	end

	if game_state_machine:current_state().game_ended and game_state_machine:current_state():game_ended() then
		return false
	end

	if Global.load_start_menu or Application:editor() then
		return false
	end

	local plrs_alive = false
	local plrs_disabled = true

	for u_key, u_data in pairs(self._player_criminals) do
		plrs_alive = true

		if u_data.status ~= "dead" and u_data.status ~= "disabled" then
			plrs_disabled = false

			break
		end
	end

	local ai_alive = false
	local ai_disabled = true

	for u_key, u_data in pairs(self._ai_criminals) do
		ai_alive = true

		if u_data.status ~= "dead" and u_data.status ~= "disabled" then
			ai_disabled = false

			break
		end
	end

	local gameover = false

	if not plrs_alive and not self:is_ai_trade_possible() then
		gameover = true
	elseif plrs_disabled and not ai_alive then
		gameover = true
	elseif plrs_disabled and ai_disabled then
		gameover = true
	end

	if gameover then
		if not self._gameover_clbk then
			self._gameover_clbk = callback(self, self, "_gameover_clbk_func")

			managers.enemy:add_delayed_clbk("_gameover_clbk", self._gameover_clbk, Application:time() + 7)
		end
	elseif self._gameover_clbk then
		managers.enemy:remove_delayed_clbk("_gameover_clbk")

		self._gameover_clbk = nil
	end

	return gameover
end

function GroupAIStateBase:_gameover_clbk_func()
	self._gameover_clbk = nil
	local govr = self:check_gameover_conditions()

	if govr then
		managers.network:session():send_to_peers_synched("begin_gameover_fadeout")
		self:begin_gameover_fadeout()
	end
end

function GroupAIStateBase:begin_gameover_fadeout()
	managers.system_menu:force_close_all()
	managers.menu:close_all_menus()

	if Network:is_server() and not managers.vote:is_restarting() and not managers.game_play_central:is_restarting() then
		managers.raid_job:external_end_mission(false, true)
	end
end

function GroupAIStateBase:report_criminal_downed(unit)
	if not self:bain_state() then
		return
	end

	local character_code = managers.criminals:character_static_data_by_unit(unit).ssuffix
	local bain_line = "ban_q01" .. character_code

	if unit ~= managers.player:player_unit() then
		-- Nothing
	end

	managers.network:session():send_to_peers_synched("bain_comment", bain_line)
end

function GroupAIStateBase:on_criminal_disabled(unit, custom_status)
	print("GroupAIStateBase:on_criminal_disabled", "custom_status", custom_status)

	local criminal_key = unit:key()
	local record = self._criminals[criminal_key]
	record.disabled_t = self._t
	record.status = custom_status or "disabled"

	if Network:is_server() then
		self._downs_during_assault = self._downs_during_assault + 1

		for key, data in pairs(self._police) do
			data.unit:brain():on_criminal_neutralized(criminal_key)
		end

		self:_add_drama(self._drama_data.actions.criminal_disabled)
		self:check_gameover_conditions()
	end
end

function GroupAIStateBase:on_criminal_neutralized(unit)
	local criminal_key = unit:key()
	local record = self._criminals[criminal_key]

	if not record then
		return
	end

	record.status = "dead"
	record.arrest_timeout = 0

	if Network:is_server() then
		self._downs_during_assault = self._downs_during_assault + 1

		for key, data in pairs(self._police) do
			data.unit:brain():on_criminal_neutralized(criminal_key)
		end

		self:_add_drama(self._drama_data.actions.criminal_dead)
		self:check_gameover_conditions()
	end
end

function GroupAIStateBase:on_criminal_recovered(criminal_unit)
	local record = self._criminals[criminal_unit:key()]

	if record.status then
		record.status = nil

		if Network:is_server() then
			self:check_gameover_conditions()
		end
	end
end

function GroupAIStateBase:on_civilian_try_freed()
	if not self._warned_about_deploy_this_control then
		self._warned_about_deploy_this_control = true

		if not self._warned_about_deploy then
			self:sync_warn_about_civilian_free(1)
			managers.network:session():send_to_peers_synched("warn_about_civilian_free", 1)

			self._warned_about_deploy = true
		else
			self:sync_warn_about_civilian_free(2)
			managers.network:session():send_to_peers_synched("warn_about_civilian_free", 2)
		end
	end
end

function GroupAIStateBase:on_civilian_freed()
	if not self._warned_about_freed_this_control then
		self._warned_about_freed_this_control = true

		if not self._warned_about_freed then
			self:sync_warn_about_civilian_free(3)
			managers.network:session():send_to_peers_synched("warn_about_civilian_free", 3)

			self._warned_about_freed = true
		else
			self:sync_warn_about_civilian_free(4)
			managers.network:session():send_to_peers_synched("warn_about_civilian_free", 4)
		end
	end
end

function GroupAIStateBase:sync_warn_about_civilian_free(i)
	if not self:bain_state() then
		return
	end

	if i == 1 then
		managers.dialog:queue_dialog("ban_r01", {})
	elseif i == 2 then
		managers.dialog:queue_dialog("ban_r02", {})
	elseif i == 3 then
		managers.dialog:queue_dialog("ban_r03", {})
	elseif i == 4 then
		managers.dialog:queue_dialog("ban_r04", {})
	end
end

function GroupAIStateBase:on_enemy_tied(u_key)
end

function GroupAIStateBase:on_enemy_untied(u_key)
end

function GroupAIStateBase:on_civilian_tied(u_key)
end

function GroupAIStateBase:_debug_draw_drama(t)
	local draw_data = self._draw_drama
	local drama_data = self._drama_data

	draw_data.background_brush:quad(draw_data.bg_bottom_l, draw_data.bg_bottom_r, draw_data.bg_top_r, draw_data.bg_top_l)
	draw_data.low_zone_pen:line(draw_data.low_zone_l, draw_data.low_zone_r)
	draw_data.high_zone_pen:line(draw_data.high_zone_l, draw_data.high_zone_r)

	if t - self._drama_data.last_calculate_t > 1 then
		self:_claculate_drama_value()
	end

	local t_span = draw_data.t_span
	local drama_hist = draw_data.drama_hist

	if drama_hist[#drama_hist][2] < t then
		if #drama_hist == 1 then
			table.insert(drama_hist, {
				drama_data.amount,
				t
			})
		else
			local tan1 = (drama_data.amount - drama_hist[#drama_hist][1]) / (t - drama_hist[#drama_hist][2])
			local tan2 = (drama_hist[#drama_hist][1] - drama_hist[#drama_hist - 1][1]) / (drama_hist[#drama_hist][2] - drama_hist[#drama_hist - 1][2])

			if #drama_hist > 1 and math.abs(tan1 - tan2) < 0.5 then
				drama_hist[#drama_hist][2] = t
			else
				table.insert(drama_hist, {
					drama_data.amount,
					t
				})
			end
		end
	end

	while drama_hist[2] and t_span < t - drama_hist[2][2] do
		table.remove(drama_hist, 1)
	end

	local mvec3_set_st = mvector3.set_static
	local mvec3_set = mvector3.set
	local height = draw_data.height
	local width = draw_data.width
	local right_limit = draw_data.offset_x + width
	local bottom_limit = draw_data.offset_y
	local prev_pos = Vector3()
	local new_pos = Vector3()
	local drama_pen = draw_data.drama_pen

	for i, entry in ipairs(drama_hist) do
		local new_x = right_limit - width * (t - entry[2]) / t_span
		local new_y = bottom_limit + entry[1] * height

		mvec3_set_st(new_pos, new_x, new_y, 90)

		if i > 1 then
			drama_pen:line(prev_pos, new_pos)
		end

		mvec3_set(prev_pos, new_pos)
	end

	local pop_hist = draw_data.pop_hist
	local pop_hist_size = #pop_hist
	local last_entry = pop_hist[pop_hist_size]

	if last_entry[2] < t then
		local police_force = self._police_force

		if pop_hist_size > 1 and last_entry[1] == police_force and pop_hist[pop_hist_size - 1][1] == police_force then
			last_entry[2] = t
		else
			table.insert(pop_hist, {
				police_force,
				t
			})
		end
	end

	while pop_hist[2] and t_span < t - pop_hist[2][2] do
		table.remove(pop_hist, 1)
	end

	local max_force = 25
	local pop_pen = draw_data.population_pen

	for i, entry in ipairs(pop_hist) do
		local new_x = right_limit - width * (t - entry[2]) / t_span
		local new_y = bottom_limit + entry[1] * height / max_force

		mvec3_set_st(new_pos, new_x, new_y, 80)

		if i > 1 then
			pop_pen:line(prev_pos, new_pos)
		end

		mvec3_set(prev_pos, new_pos)
	end

	local mvec3_setx = mvector3.set_x
	local top_l = Vector3(0, draw_data.bg_top_l.y, 90)
	local bottom_l = Vector3(0, draw_data.bg_bottom_l.y, 90)
	local top_r = Vector3(0, draw_data.bg_top_l.y, 90)
	local bottom_r = Vector3(0, draw_data.bg_bottom_l.y, 90)

	local function _draw_events(event_brush, event_list)
		while event_list[1] and event_list[1][2] and t_span < t - event_list[1][2] do
			table.remove(event_list, 1)
		end

		for i, entry in ipairs(event_list) do
			local new_x = right_limit - width * (t - entry[1]) / t_span

			mvec3_setx(top_l, new_x)
			mvec3_setx(bottom_l, new_x)

			if entry[2] then
				local new_x = right_limit - width * (t - entry[2]) / t_span

				mvec3_setx(top_r, new_x)
				mvec3_setx(bottom_r, new_x)
			else
				mvec3_setx(top_r, right_limit)
				mvec3_setx(bottom_r, right_limit)
			end

			event_brush:quad(top_l, top_r, bottom_r, bottom_l)
		end
	end

	_draw_events(draw_data.assault_brush, draw_data.assault_hist)
	_draw_events(draw_data.regroup_brush, draw_data.regroup_hist)
end

function GroupAIStateBase:toggle_drama_draw_state()
	Global.drama_draw_state = not Global.drama_draw_state

	self:set_drama_draw_state(Global.drama_draw_state)
end

function GroupAIStateBase:set_drama_draw_state(state)
	if state then
		local depth = 100
		local offset = Vector3(-0.98, -0.98)
		local width = 1
		local height = 0.3
		local low_zone_color = Color(1, 0.2, 0.2, 0.7)
		local high_zone_color = Color(1, 0.7, 0.2, 0.2)
		local background_color = Color(0.2, 0.2, 0.2, 0.2)
		local assault_color = Color(0.1, 0.5, 0, 0)
		local regroup_color = Color(0.1, 0, 0.1, 0.5)
		local zone = self._drama_data.zone
		local drama_line_color = Color(0.3, 1, 1, 1)
		local population_line_color = Color(0.3, 0.6, 0.4, 0.15)
		local bg_bottom_l = offset + Vector3(0, 0, depth)
		local bg_bottom_r = offset + Vector3(width, 0, depth)
		local bg_top_l = offset + Vector3(0, height, depth)
		local bg_top_r = offset + Vector3(width, height, depth)
		local low_zone_l = bg_bottom_l:with_y(bg_bottom_l.y + self._drama_data.low_p * height)
		local low_zone_r = low_zone_l:with_x(bg_bottom_r.x)
		local high_zone_l = bg_bottom_l:with_y(bg_bottom_l.y + self._drama_data.high_p * height)
		local high_zone_r = high_zone_l:with_x(bg_bottom_r.x)
		self._draw_drama = {
			t_span = 180,
			background_brush = Draw:brush(background_color),
			assault_brush = Draw:brush(assault_color),
			regroup_brush = Draw:brush(regroup_color),
			drama_pen = Draw:pen("screen", drama_line_color),
			population_pen = Draw:pen("screen", population_line_color),
			low_zone_pen = Draw:pen("screen", low_zone_color),
			high_zone_pen = Draw:pen("screen", high_zone_color),
			bg_bottom_l = bg_bottom_l,
			bg_bottom_r = bg_bottom_r,
			bg_top_l = bg_top_l,
			bg_top_r = bg_top_r,
			low_zone_l = low_zone_l,
			low_zone_r = low_zone_r,
			high_zone_l = high_zone_l,
			high_zone_r = high_zone_r,
			width = width,
			height = height,
			offset_x = offset.x,
			offset_y = offset.y,
			start_t = self._t,
			drama_hist = {
				{
					self._drama_data.amount,
					self._t
				}
			},
			pop_hist = {
				{
					self._police_force,
					self._t
				}
			},
			assault_hist = {},
			regroup_hist = {}
		}

		self._draw_drama.background_brush:set_screen(true)
		self._draw_drama.assault_brush:set_screen(true)
		self._draw_drama.regroup_brush:set_screen(true)

		if self._task_data then
			for _, task_type in ipairs({
				"assault",
				"blockade"
			}) do
				if self._task_data[task_type] and self._task_data[task_type].active then
					table.insert(self._draw_drama.assault_hist, {
						self._task_data[task_type].start_t
					})

					break
				end
			end

			if self._task_data.regroup and self._task_data.regroup.active then
				table.insert(self._draw_drama.regroup_hist, {
					self._task_data.regroup.start_t
				})
			end
		end
	else
		self._draw_drama = nil
	end
end

function GroupAIStateBase:task_names()
	return {
		"any",
		"assault",
		"blockade",
		"recon",
		"reenforce",
		"rescue"
	}
end

function GroupAIStateBase:on_objective_failed(unit, objective)
	if not unit:brain() then
		debug_pause_unit(unit, "[GroupAIStateBase:on_objective_failed] error in extension order", unit)

		local fail_clbk = objective.fail_clbk
		objective.fail_clbk = nil

		unit:brain():set_objective(nil)

		if fail_clbk then
			fail_clbk(unit)
		end

		return
	end

	local new_objective = nil

	if unit:brain():objective() == objective then
		local u_key = unit:key()
		local u_data = self._police[u_key]

		if u_data and unit:brain():is_active() and not unit:character_damage():dead() then
			new_objective = {
				is_default = true,
				scan = true,
				type = "free",
				attitude = objective.attitude
			}

			if u_data.assigned_area then
				local seg = unit:movement():nav_tracker():nav_segment()

				self:set_enemy_assigned(self:get_area_from_nav_seg_id(seg), u_key)
			end
		end
	end

	local fail_clbk = objective.fail_clbk
	objective.fail_clbk = nil

	if new_objective then
		unit:brain():set_objective(new_objective)
	end

	if fail_clbk then
		fail_clbk(unit)
	end
end

function GroupAIStateBase:add_special_objective(id, objective_data)
	if objective_data.objective.type == "phalanx" then
		self._phalanx_center_pos = objective_data.objective.pos
	end

	if self._special_objectives[id] then
		self:remove_special_objective(id)
	end

	local chance = objective_data.base_chance
	local so = {
		delay_t = 0,
		data = objective_data,
		chance = chance,
		chance_inc = objective_data.chance_inc,
		interval = objective_data.interval,
		remaining_usage = objective_data.usage_amount,
		non_repeatable = not objective_data.repeatable,
		administered = not objective_data.repeatable and {}
	}

	if not objective_data.access then
		objective_data.access = managers.navigation:convert_SO_AI_group_to_access(objective_data.AI_group)
	end

	self._special_objectives[id] = so

	if objective_data.objective and objective_data.objective.nav_seg then
		local nav_seg = objective_data.objective.nav_seg
		local area_data = self:get_area_from_nav_seg_id(nav_seg)
	end
end

function GroupAIStateBase:_execute_so(so_data, so_rooms, so_administered)
	local max_dis = so_data.search_dis_sq
	local pos = so_data.search_pos
	local ai_group = so_data.AI_group
	local so_access = so_data.access
	local mvec3_dis_sq = mvector3.distance_sq
	local closest_u_data, closest_dis = nil
	local so_objective = so_data.objective
	local nav_manager = managers.navigation
	local access_f = nav_manager.check_access

	if ai_group == "enemies" then
		for e_key, enemy_unit_data in pairs(self._police) do
			if (not so_administered or not so_administered[e_key]) and (so_objective.forced or enemy_unit_data.unit:brain():is_available_for_assignment(so_objective)) and (not so_data.verification_clbk or so_data.verification_clbk(enemy_unit_data.unit)) and access_f(nav_manager, so_access, enemy_unit_data.so_access, 0) then
				local dis = max_dis and mvec3_dis_sq(enemy_unit_data.m_pos, pos)

				if (not closest_dis or dis < closest_dis) and (not max_dis or dis < max_dis) then
					closest_u_data = enemy_unit_data
					closest_dis = dis
				end
			end
		end
	elseif ai_group == "friendlies" then
		for u_key, u_unit_data in pairs(self._ai_criminals) do
			if (not so_administered or not so_administered[u_key]) and (so_objective.forced or u_unit_data.unit:brain():is_available_for_assignment(so_objective)) and (not so_data.verification_clbk or so_data.verification_clbk(u_unit_data.unit)) and access_f(nav_manager, so_access, u_unit_data.so_access, 0) then
				local dis = mvec3_dis_sq(u_unit_data.m_pos, pos)

				if (not closest_dis or dis < closest_dis) and (not max_dis or dis < max_dis) then
					closest_u_data = u_unit_data
					closest_dis = dis
				end
			end
		end
	elseif ai_group == "civilians" then
		for u_key, u_unit_data in pairs(managers.enemy:all_civilians()) do
			if (not so_administered or not so_administered[u_key]) and (so_objective.forced or u_unit_data.unit:brain():is_available_for_assignment(so_objective)) and (not so_data.verification_clbk or so_data.verification_clbk(u_unit_data.unit)) and access_f(nav_manager, so_access, u_unit_data.so_access, 0) then
				local dis = mvec3_dis_sq(u_unit_data.m_pos, pos)

				if (not closest_dis or dis < closest_dis) and (not max_dis or dis < max_dis) then
					closest_u_data = u_unit_data
					closest_dis = dis
				end
			end
		end
	else
		for u_key, civ_unit_data in pairs(managers.enemy:all_civilians()) do
			if access_f(nav_manager, so_access, civ_unit_data.so_access, 0) then
				closest_u_data = civ_unit_data

				break
			end
		end
	end

	if closest_u_data then
		local objective_copy = self.clone_objective(so_objective)
		local distance_to_so = mvector3.distance(so_data.search_pos, closest_u_data.unit:position())

		if distance_to_so > tweak_data.vehicle.AI_TELEPORT_DISTANCE * 100 and objective_copy.objective_type == VehicleDrivingExt.SPECIAL_OBJECTIVE_TYPE_DRIVING and managers.groupai:state():is_police_called() then
			objective_copy.pos = closest_u_data.unit:position()
		end

		closest_u_data.unit:brain():set_objective(objective_copy)

		if so_data.admin_clbk then
			so_data.admin_clbk(closest_u_data.unit, so_data)
		end
	end

	return closest_u_data
end

function GroupAIStateBase:remove_special_objective(id)
	local so = self._special_objectives[id]

	if not so then
		return
	end

	local nav_seg = so.data.objective and so.data.objective.nav_seg
	self._special_objectives[id] = nil

	if not nav_seg then
		return
	end
end

function GroupAIStateBase:add_SO_group(id, element)
	self:remove_SO_group(id)

	self._SO_groups[id] = element
end

function GroupAIStateBase:remove_SO_group(id)
	self._SO_groups[id] = nil
end

function GroupAIStateBase:_upd_SO_groups()
	for so_group_id, element in pairs(self._SO_groups) do
		self:_process_SO_group(so_group_id, element)
	end

	self._SO_groups = {}

	if next(self._spawning_groups) then
		return
	end

	for recurring_id, data in pairs(self._recurring_SO_groups) do
		if self:_process_recurring_SO_groups(recurring_id, data) then
			break
		end
	end
end

function GroupAIStateBase:_process_SO_group(so_group_id, element)
	local mode = element:value("mode")

	if mode == "forced_spawn" then
		return
	end

	if not self._recurring_SO_groups[mode] then
		self._recurring_SO_groups[mode] = {
			delay_t = 0,
			elements = {},
			interval = tweak_data.group_ai.besiege.recurring_group_SO[mode].interval
		}
	end

	table.insert(self._recurring_SO_groups[mode].elements, element)
end

function GroupAIStateBase:_process_recurring_SO_groups(recurring_id, data)
	if data.groups then
		local junk_groups = nil

		for group_id, group in pairs(data.groups) do
			if group.has_spawned then
				local is_junk = nil

				if not self._groups[group_id] or self._groups[group_id] ~= group then
					is_junk = true
				end

				if not is_junk then
					is_junk = true

					for u_key, unit_data in pairs(group.units) do
						local objective = unit_data.unit:brain():objective()

						if objective and objective.grp_objective == group.objective then
							is_junk = nil

							break
						end
					end

					if is_junk then
						if group.objective.fail_t then
							if self._t - group.objective.fail_t < tweak_data.group_ai.besiege.recurring_group_SO[recurring_id].retire_delay then
								is_junk = nil
							end
						else
							group.objective.fail_t = self._t
							is_junk = nil
						end
					end
				end

				if is_junk then
					junk_groups = junk_groups or {}

					table.insert(junk_groups, group_id)
				end
			end
		end

		if junk_groups then
			for _, group_id in ipairs(junk_groups) do
				local group = data.groups[group_id]

				if next(group.units) then
					self:_assign_group_to_retire(group)
				end

				data.groups[group_id] = nil
			end

			if not next(data.groups) then
				data.groups = nil
			end

			data.delay_t = math.max(data.delay_t, self._t + math.lerp(data.interval[1], data.interval[2], math.random()))

			return
		end
	end

	if self._t < data.delay_t then
		return
	end

	local total_w = 0

	for i, element in ipairs(data.elements) do
		total_w = total_w + element:value("base_chance")
	end

	local rand_w = total_w * math.random()
	local element = nil

	for i, test_element in ipairs(data.elements) do
		rand_w = rand_w - test_element:value("base_chance")

		if rand_w <= 0 then
			element = test_element

			break
		end
	end

	local grp_objective = element:get_grp_objective()
	local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(grp_objective.area, tweak_data.group_ai.besiege.cloaker.groups, element:value("position"), nil, nil)

	if not spawn_group then
		return
	end

	local new_group = self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, nil)

	if new_group then
		data.groups = data.groups or {}
		data.groups[new_group.id] = new_group
	end

	data.delay_t = self._t + 5

	return new_group and true
end

function GroupAIStateBase:save(save_data)
	local my_save_data = {}
	save_data.group_ai = my_save_data
	my_save_data.control_value = self._control_value
	my_save_data._assault_mode = self._assault_mode
	my_save_data._hunt_mode = self._hunt_mode
	my_save_data._fake_assault_mode = self._fake_assault_mode
	my_save_data._whisper_mode = self._whisper_mode
	my_save_data._bain_state = self._bain_state
	my_save_data._point_of_no_return_timer = self._point_of_no_return_timer
	my_save_data._point_of_no_return_mission_id = self._point_of_no_return_mission_id
	my_save_data._point_of_no_return_id = self._point_of_no_return_id
	my_save_data._police_called = self._police_called
	my_save_data._enemy_weapons_hot = self._enemy_weapons_hot

	if self._hostage_headcount > 0 then
		my_save_data.hostage_headcount = self._hostage_headcount
	end

	my_save_data.teams = self._teams
	my_save_data.endscreen_variant = self._endscreen_variant
end

function GroupAIStateBase:load(load_data)
	local my_load_data = load_data.group_ai
	self._control_value = my_load_data.control_value

	self:_calculate_difficulty_ratio()

	self._hunt_mode = my_load_data._hunt_mode

	self:sync_assault_mode(my_load_data._assault_mode)
	self:set_fake_assault_mode(my_load_data._fake_assault_mode)
	self:set_whisper_mode(my_load_data._whisper_mode)
	self:set_bain_state(my_load_data._bain_state)
	self:set_point_of_no_return_timer(my_load_data._point_of_no_return_timer, my_load_data._point_of_no_return_mission_id, my_load_data._point_of_no_return_id)

	if my_load_data.hostage_headcount then
		self:sync_hostage_headcount(my_load_data.hostage_headcount)
	end

	self._police_called = my_load_data._police_called
	self._enemy_weapons_hot = my_load_data._enemy_weapons_hot

	if self._enemy_weapons_hot then
		managers.enemy:set_corpse_disposal_enabled(true)
	end

	self._teams = my_load_data.teams
	self._endscreen_variant = my_load_data.endscreen_variant

	self:_call_listeners("team_def")
	self:set_damage_reduction_buff_hud()
end

function GroupAIStateBase:set_point_of_no_return_timer(time, point_of_no_return_mission_id, point_of_no_return_id)
	if time == nil or setup:has_queued_exec() then
		return
	end

	self._forbid_drop_in = true

	debug_pause("[GroupAIStateBase][set_point_of_no_return_timer] trying to use managers.network.matchmake:set_server_joinable( false ) ")

	if not self._peers_inside_point_of_no_return then
		self._peers_inside_point_of_no_return = {}
	end

	self._point_of_no_return_timer = time
	self._point_of_no_return_mission_id = point_of_no_return_mission_id
	self._point_of_no_return_id = point_of_no_return_id
	self._point_of_no_return_areas = nil

	managers.hud:show_point_of_no_return_timer()
	managers.hud:add_updator("point_of_no_return", callback(self, self, "_update_point_of_no_return"))
end

function GroupAIStateBase:set_is_inside_point_of_no_return(peer_id, is_inside)
	self._peers_inside_point_of_no_return[peer_id] = is_inside
end

function GroupAIStateBase:_update_point_of_no_return(t, dt)
	if setup:has_queued_exec() then
		managers.hud:hide_point_of_no_return_timer()
		managers.hud:remove_updator("point_of_no_return")

		return
	end

	local prev_time = self._point_of_no_return_timer
	self._point_of_no_return_timer = self._point_of_no_return_timer - dt
	local sec = math.floor(self._point_of_no_return_timer)

	if sec < math.floor(prev_time) then
		managers.hud:flash_point_of_no_return_timer(sec <= 10)
	end

	local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._point_of_no_return_mission_id) or managers.mission

	if not self._point_of_no_return_areas then
		self._point_of_no_return_areas = {}
		local element = mission:get_element_by_id(self._point_of_no_return_id)

		for _, id in ipairs(element._values.elements) do
			local area = mission:get_element_by_id(id)

			if area then
				table.insert(self._point_of_no_return_areas, area)
			end
		end
	end

	local is_inside = false
	local plr_unit = managers.criminals:character_unit_by_name(managers.criminals:local_character_name())

	if plr_unit and alive(plr_unit) then
		for _, area in ipairs(self._point_of_no_return_areas) do
			if area._shape:is_inside(plr_unit:movement():m_pos()) then
				is_inside = true

				break
			end
		end
	end

	if is_inside ~= self._is_inside_point_of_no_return then
		self._is_inside_point_of_no_return = is_inside

		if managers.network:session() then
			if not Network:is_server() then
				managers.network:session():send_to_host("is_inside_point_of_no_return", is_inside)
			else
				self:set_is_inside_point_of_no_return(managers.network:session():local_peer():id(), is_inside)
			end
		end
	end

	if self._point_of_no_return_timer <= 0 then
		managers.hud:remove_updator("point_of_no_return")

		if not is_inside then
			self._failed_point_of_no_return = true
		end

		if Network:is_server() then
			if managers.platform:presence() == "Playing" then
				local num_is_inside = 0

				for _, peer_inside in pairs(self._peers_inside_point_of_no_return) do
					num_is_inside = num_is_inside + (peer_inside and 1 or 0)
				end

				if num_is_inside > 0 then
					local num_winners = num_is_inside + self:amount_of_winning_ai_criminals()

					managers.network:session():send_to_peers("mission_ended", true, num_winners)
					game_state_machine:change_state_by_name("victoryscreen", {
						num_winners = num_winners,
						personal_win = is_inside
					})
				else
					managers.network:session():send_to_peers("mission_ended", false, 0)
					game_state_machine:change_state_by_name("gameoverscreen")
				end
			end

			local element = mission:get_element_by_id(self._point_of_no_return_id)

			for _, id in ipairs(element._values.elements) do
				local area = get_mission_script_element(id)

				if area then
					area:execute_on_executed(nil)
				end
			end
		end

		managers.hud:feed_point_of_no_return_timer(0, is_inside)
	else
		managers.hud:feed_point_of_no_return_timer(self._point_of_no_return_timer, is_inside)
	end
end

function GroupAIStateBase:spawn_one_teamAI(is_drop_in, char_name, spawn_on_unit, transition)
	if not managers.groupai:state():team_ai_enabled() or not self._ai_enabled or not managers.criminals:character_taken_by_name(char_name) and managers.criminals.MAX_NR_TEAM_AI <= managers.criminals:nr_AI_criminals() then
		return
	end

	local objective = self:_determine_spawn_objective_for_criminal_AI()

	if objective and objective.type == "follow" then
		local player = spawn_on_unit or objective.follow_unit
		local player_pos = mvector3.copy(player:movement():m_pos())
		local tracker = player:movement():nav_tracker()
		local spawn_pos, spawn_rot = nil

		if false then
			player_pos = mvector3.copy(managers.player:local_player():movement():m_pos())
			local spawn_fwd = managers.player:local_player():movement():m_head_rot():y()
			local offset_id = managers.criminals:nr_taken_criminals() - 1
			spawn_pos = self:get_spawn_position(player_pos, player:movement():m_head_rot(), offset_id)
			spawn_rot = Rotation(spawn_fwd, math.UP)

			Application:debug("[GroupAIStateBase:spawn_one_teamA] Transitioning AI", spawn_pos, spawn_rot, offset_id)
		elseif (is_drop_in or spawn_on_unit) and not self:whisper_mode() then
			local spawn_fwd = player:movement():m_head_rot():y()

			mvector3.set_z(spawn_fwd, 0)
			mvector3.normalize(spawn_fwd)

			spawn_rot = Rotation(spawn_fwd, math.UP)
			spawn_pos = player_pos

			if not tracker:lost() then
				local search_pos = player_pos - spawn_fwd * 200
				local ray_params = {
					allow_entry = false,
					trace = true,
					tracker_from = tracker,
					pos_to = search_pos
				}
				local ray_hit = managers.navigation:raycast(ray_params)

				if ray_hit then
					spawn_pos = ray_params.trace[1]
				else
					spawn_pos = search_pos
				end
			end
		else
			local spawn_point = managers.network:session():get_next_spawn_point()
			spawn_pos = spawn_point.pos_rot[1]
			spawn_rot = spawn_point.pos_rot[2]
			objective.in_place = true
		end

		local character_name = char_name or managers.criminals:get_free_character_name()
		local lvl_tweak_data = Global.level_data and Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
		local unit_folder = lvl_tweak_data and lvl_tweak_data.unit_suit or "suit"
		local ai_character_id = managers.criminals:character_static_data_by_name(character_name).ai_character_id
		local unit_name = Idstring(tweak_data.blackmarket.characters[ai_character_id].npc_unit)
		local unit = World:spawn_unit(unit_name, spawn_pos, spawn_rot)

		managers.network:session():send_to_peers_synched("set_unit", unit, character_name, "", 0, 0, tweak_data.levels:get_default_team_ID("player"))

		if char_name and not is_drop_in then
			managers.criminals:set_unit(character_name, unit)
		else
			managers.criminals:add_character(character_name, unit, nil, true)
		end

		unit:movement():set_character_anim_variables()
		unit:brain():set_spawn_ai({
			init_state = "idle",
			params = {
				scan = true
			},
			objective = objective
		})

		return unit
	end
end

function GroupAIStateBase:get_spawn_position(pos, rot, offset_id)
	local ai_position = pos
	local x = rot:x() * 100
	local y = rot:y() * 100
	ai_position = ai_position - y - x
	ai_position = ai_position + x * offset_id

	return ai_position
end

function GroupAIStateBase:remove_one_teamAI(name_to_remove, replace_with_player)
	local u_key, u_data = nil

	if name_to_remove then
		if not managers.criminals:character_taken_by_name(name_to_remove) and CriminalsManager.MAX_NR_CRIMINALS <= managers.criminals:nr_taken_criminals() then
			return self:remove_one_teamAI(nil, replace_with_player)
		end

		for uk, ud in pairs(self._ai_criminals) do
			if managers.criminals:character_name_by_unit(ud.unit) == name_to_remove then
				u_data = ud
				u_key = uk

				break
			end
		end
	else
		u_key, u_data = next(self._ai_criminals)
	end

	local name, unit = nil

	if u_key then
		name = managers.criminals:character_name_by_unit(u_data.unit)
		u_data.status = "removed"

		for key, data in pairs(self._police) do
			data.unit:brain():on_criminal_neutralized(u_key)
		end

		unit = u_data.unit
	elseif not name_to_remove then
		local unit = nil

		for id, data in pairs(managers.criminals._characters) do
			if data.taken and data.data.ai and (not name_to_remove or data.name == name_to_remove) then
				unit = data.unit
				name = data.name
			end
		end

		if not unit then
			return
		end
	else
		name = name_to_remove
	end

	local trade_entry = self:sync_remove_one_teamAI(name, replace_with_player)

	managers.network:session():send_to_peers_synched("sync_remove_one_teamAI", name, replace_with_player)

	if alive(unit) then
		unit:brain():set_active(false)
		unit:base():set_slot(unit, 0)
		unit:base():unregister()
	end

	return trade_entry, unit
end

function GroupAIStateBase:sync_remove_one_teamAI(name, replace_with_player)
	managers.criminals:remove_character_by_name(name)

	if replace_with_player then
		return managers.trade:replace_ai_with_player(name, name)
	else
		managers.trade:remove_from_trade(name)

		return true
	end
end

function GroupAIStateBase:fill_criminal_team_with_AI(transition)
	if managers.navigation:is_data_ready() and self._ai_enabled and managers.groupai:state():team_ai_enabled() then
		while managers.criminals:nr_taken_criminals() < CriminalsManager.MAX_NR_CRIMINALS and managers.criminals:nr_AI_criminals() < managers.criminals.MAX_NR_TEAM_AI do
			if not self:spawn_one_teamAI(nil, nil, nil, transition) then
				break
			end
		end
	end
end

function GroupAIStateBase:team_ai_enabled()
	local res = nil

	if tweak_data.levels[Global.game_settings.level_id] then
		res = Global.game_settings.team_ai and not tweak_data.levels[Global.game_settings.level_id].team_ai_off
	else
		res = Global.game_settings.team_ai
	end

	return not managers.worldcollection.team_ai_transition and res
end

function GroupAIStateBase:on_civilian_objective_complete(unit, objective)
	if objective.type == "escort" then
		if objective.break_so then
			if objective.end_rot then
				unit:movement():set_rotation(objective.end_rot)
			end

			local action = {
				clamp_to_graph = true,
				align_sync = true,
				type = "act",
				body_part = 1,
				variant = objective.break_so
			}

			unit:movement():action_request(action)
		end

		if objective.next_escort_point then
			objective.next_escort_point:on_executed(unit)

			return
		end
	end

	local new_objective, so_element = nil

	if objective.followup_objective then
		if not objective.followup_objective.trigger_on then
			new_objective = objective.followup_objective
		else
			new_objective = {
				type = "free",
				followup_objective = objective.followup_objective,
				interrupt_dis = objective.interrupt_dis,
				interrupt_health = objective.interrupt_health
			}
		end
	elseif objective.followup_SO then
		local current_SO_element = objective.followup_SO
		so_element = current_SO_element:choose_followup_SO(unit)
		new_objective = so_element and so_element:get_objective(unit)
	else
		new_objective = {
			is_default = true,
			type = "free"
		}
	end

	objective.fail_clbk = nil

	unit:brain():set_objective(new_objective)

	if objective.complete_clbk then
		objective.complete_clbk(unit)
	end

	if so_element then
		so_element:clbk_objective_administered(unit)
	end
end

function GroupAIStateBase:on_civilian_objective_failed(unit, objective)
	if alive(unit) and objective == unit:brain():objective() then
		if unit:brain():is_tied() then
			unit:brain():on_hostage_move_interaction(nil, "stay")

			local fail_clbk = objective.fail_clbk
			objective.fail_clbk = nil

			if fail_clbk then
				fail_clbk(unit)
			end
		else
			unit:brain():set_objective({
				is_default = true,
				type = "free"
			})
		end
	end
end

function GroupAIStateBase:on_criminal_objective_complete(unit, objective)
	local new_objective, so_element = nil

	if objective.followup_objective then
		if not objective.followup_objective.trigger_on then
			new_objective = objective.followup_objective
		else
			new_objective = self:_determine_objective_for_criminal_AI(unit)

			if new_objective then
				new_objective.followup_objective = objective.followup_objective
			end
		end
	elseif objective.followup_SO then
		local current_SO_element = objective.followup_SO
		so_element = current_SO_element:choose_followup_SO(unit)
		new_objective = so_element and so_element:get_objective(unit)
	else
		new_objective = self:_determine_objective_for_criminal_AI(unit)
	end

	objective.fail_clbk = nil

	unit:brain():set_objective(new_objective)

	if objective.complete_clbk then
		objective.complete_clbk(unit)
	end

	if so_element then
		so_element:clbk_objective_administered(unit)
	end
end

function GroupAIStateBase:on_criminal_objective_failed(unit, objective, no_new_objective)
	local fail_clbk = objective.fail_clbk
	objective.fail_clbk = nil

	if fail_clbk then
		fail_clbk(unit)
	end

	if not no_new_objective then
		unit:brain():set_objective(nil)
	end
end

function GroupAIStateBase:on_criminal_jobless(unit)
	local new_objective = self:_determine_objective_for_criminal_AI(unit)

	if new_objective then
		unit:brain():set_objective(new_objective)
	end
end

function GroupAIStateBase:_determine_spawn_objective_for_criminal_AI()
	local new_objective = nil
	local valid_criminals = {}

	for pl_key, pl_record in pairs(self._player_criminals) do
		if pl_record.status ~= "dead" then
			table.insert(valid_criminals, pl_key)
		end
	end

	if #valid_criminals > 0 then
		local follow_unit = self._player_criminals[valid_criminals[math.random(#valid_criminals)]].unit
		new_objective = {
			scan = true,
			is_default = true,
			type = "follow",
			follow_unit = follow_unit
		}
	end

	return new_objective
end

function GroupAIStateBase:_determine_objective_for_criminal_AI(unit)
	local objective, closest_dis, closest_record = nil
	local ai_pos = (self._ai_criminals[unit:key()] or self._police[unit:key()]).m_pos
	local ai_unit = self._ai_criminals[unit:key()] or self._police[unit:key()]

	for pl_key, pl_record in pairs(self._player_criminals) do
		if pl_record.status ~= "dead" then
			local my_dis = mvector3.distance(ai_pos, pl_record.m_pos)

			if not closest_dis or my_dis < closest_dis then
				closest_dis = my_dis
				closest_record = pl_record
			end
		end
	end

	local player_pos, player_rot = nil

	if closest_record then
		objective = {
			scan = true,
			is_default = true,
			type = "follow",
			follow_unit = closest_record.unit
		}
		player_pos = closest_record.unit:position()
		player_rot = closest_record.unit:rotation()
	end

	local ai_pos = (self._ai_criminals[unit:key()] or self._police[unit:key()]).m_pos
	local skip_hostage_trade_time_reset = nil

	if not objective and self:is_ai_trade_possible() then
		local guard_time = managers.trade:get_guard_hostage_time()

		if guard_time > 6 then
			local hostage = managers.trade:get_best_hostage(ai_pos)
			skip_hostage_trade_time_reset = hostage

			if hostage and mvector3.distance(ai_pos, hostage.m_pos) > 1500 then
				self._guard_hostage_trade_time_map = self._guard_hostage_trade_time_map or {}
				local time = Application:time()
				local unit_key = unit:key()
				local last_time = self._guard_hostage_trade_time_map[unit_key]

				if not last_time or time > last_time + 7 then
					self._guard_hostage_trade_time_map[unit_key] = time

					return {
						scan = true,
						type = "free",
						interrupt_dis = 300,
						stance = "hos",
						nav_seg = hostage.tracker:nav_segment()
					}
				end
			end
		end
	end

	if not skip_hostage_trade_time_reset then
		self._guard_hostage_trade_time_map = nil
	end

	return objective
end

function GroupAIStateBase:_verifiy_nav_exists_and_teleport_team_ai(ai_unit, player_pos, player_rot)
	if not self._nav_seg_to_area_map[ai_unit.seg] then
		Application:debug("[GroupAIStateBase:_verifiy_nav_exists_and_teleport_team_ai] Teleporting AI to player", inspect(ai_unit))
		ai_unit.unit:movement():set_position(player_pos)
	end
end

function GroupAIStateBase:_coach_last_man_clbk()
	if table.size(self:all_char_criminals()) == 1 and self:bain_state() then
		local _, crim = next(self:all_char_criminals())
		local standing_name = managers.criminals:character_name_by_unit(crim.unit)

		if standing_name == managers.criminals:local_character_name() then
			local ssuffix = managers.criminals:character_static_data_by_name(standing_name).ssuffix

			if self:hostage_count() <= 0 then
				managers.dialog:queue_dialog("ban_h40" .. ssuffix, {})
			else
				managers.dialog:queue_dialog("ban_h42" .. ssuffix, {})
			end
		end
	end
end

function GroupAIStateBase:set_assault_mode(enabled)
	if self._assault_mode ~= enabled then
		self._assault_mode = enabled
		local state_event = self:get_ambience_flag()

		managers.music:raid_music_state_change(state_event)
		managers.network:session():send_to_peers_synched("sync_assault_mode", enabled)

		if not enabled then
			self._warned_about_deploy_this_control = nil
			self._warned_about_freed_this_control = nil

			if not Global.game_settings.single_player and table.size(self:all_char_criminals()) == 1 then
				self._coach_clbk = callback(self, self, "_coach_last_man_clbk")

				managers.enemy:add_delayed_clbk("_coach_last_man_clbk", self._coach_clbk, Application:time() + 15)
			end
		end
	end

	if SystemInfo:platform() == Idstring("WIN32") and managers.network.account:has_alienware() then
		if self._assault_mode then
			LightFX:set_lamps(255, 0, 0, 255)
		else
			LightFX:set_lamps(0, 255, 0, 255)
		end
	end
end

function GroupAIStateBase:sync_assault_mode(enabled)
	if self._assault_mode ~= enabled then
		self._assault_mode = enabled
		local state_event = self:get_ambience_flag()

		managers.music:raid_music_state_change(state_event)
	end

	if SystemInfo:platform() == Idstring("WIN32") and managers.network and managers.network.account:has_alienware() then
		if self._assault_mode then
			LightFX:set_lamps(255, 0, 0, 255)
		else
			LightFX:set_lamps(0, 255, 0, 255)
		end
	end
end

function GroupAIStateBase:set_fake_assault_mode(enabled)
	if self._fake_assault_mode ~= enabled then
		self._fake_assault_mode = enabled

		if self._assault_mode ~= enabled or not self._assault_mode then
			local state_event = self:get_ambience_flag()

			managers.music:raid_music_state_change(state_event)
		end
	end
end

function GroupAIStateBase:whisper_mode()
	return self._whisper_mode
end

function GroupAIStateBase:whisper_mode_change_t()
	return self._whisper_mode_change_t
end

function GroupAIStateBase:get_ambience_flag()
	local res = nil

	if self._whisper_mode then
		res = "stealth"
	elseif self._assault_mode or self._fake_assault_mode then
		res = "assault"
	else
		res = "control"
	end

	return res
end

function GroupAIStateBase:set_whisper_mode(enabled)
	enabled = enabled and true or false

	if enabled == self._whisper_mode then
		return
	end

	self._whisper_mode = enabled
	self._whisper_mode_change_t = TimerManager:game():time()
	local state_event = self:get_ambience_flag()

	managers.music:raid_music_state_change(state_event)

	if Network:is_server() then
		if not enabled and not self._switch_to_not_cool_clbk_id then
			self._switch_to_not_cool_clbk_id = "GroupAI_delayed_not_cool"

			managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_not_cool"), self._t + 1)
		end

		if enabled then
			managers.groupai._state:calm_ai()
			managers.hud:end_assault(false)
		end
	end

	self:_call_listeners("whisper_mode", enabled)

	if not enabled then
		self:_clear_criminal_suspicion_data()
	end
end

function GroupAIStateBase:set_blackscreen_variant(variant)
	self._blackscreen_variant = variant
end

function GroupAIStateBase:blackscreen_variant(variant)
	return self._blackscreen_variant
end

function GroupAIStateBase:set_endscreen_variant(variant)
	self._endscreen_variant = variant
end

function GroupAIStateBase:endscreen_variant(variant)
	return self._endscreen_variant
end

function GroupAIStateBase:bain_state()
	return self._bain_state
end

function GroupAIStateBase:set_bain_state(enabled)
	self._bain_state = enabled
end

function GroupAIStateBase:set_allow_dropin(enabled)
	self._allow_dropin = enabled

	if Network:is_server() then
		managers.network:session():chk_server_joinable_state()
	end
end

function GroupAIStateBase:sync_hostage_killed_warning(warning)
	if not self:bain_state() then
		return
	end

	if warning == 1 then
		return
	elseif warning == 2 then
		return
	elseif warning == 3 then
		return
	end
end

function GroupAIStateBase:hostage_killed(killer_unit)
	if not alive(killer_unit) then
		return
	end

	if killer_unit:base() and killer_unit:base().thrower_unit then
		killer_unit = killer_unit:base():thrower_unit()

		if not alive(killer_unit) then
			return
		end
	end

	local key = killer_unit:key()
	local criminal = self._criminals[key]

	if not criminal then
		return
	end

	self._hostages_killed = (self._hostages_killed or 0) + 1

	if not self._hunt_mode then
		if self._hostages_killed >= 1 and not self._hostage_killed_warning_lines then
			if self:sync_hostage_killed_warning(1) then
				managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 1)

				self._hostage_killed_warning_lines = 1
			end
		elseif self._hostages_killed >= 3 and self._hostage_killed_warning_lines == 1 then
			if self:sync_hostage_killed_warning(2) then
				managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 2)

				self._hostage_killed_warning_lines = 2
			end
		elseif self._hostages_killed >= 7 and self._hostage_killed_warning_lines == 2 and self:sync_hostage_killed_warning(3) then
			managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 3)

			self._hostage_killed_warning_lines = 3
		end
	end

	if not criminal.is_deployable then
		local tweak = nil

		if killer_unit:base().is_local_player or killer_unit:base().is_husk_player then
			tweak = tweak_data.player.damage
		else
			tweak = tweak_data.character[killer_unit:base()._tweak_table].damage
		end

		local respawn_penalty = criminal.respawn_penalty or tweak.base_respawn_time_penalty
		criminal.respawn_penalty = respawn_penalty + tweak.respawn_time_penalty
		criminal.hostages_killed = (criminal.hostages_killed or 0) + 1
	end
end

function GroupAIStateBase:set_dropin_hostages_killed(criminal_unit, hostages_killed, respawn_penalty)
	if not alive(criminal_unit) then
		return
	end

	local key = criminal_unit:key()
	local criminal = self._criminals[key]

	if not criminal then
		return
	end

	if not criminal.is_deployable then
		criminal.hostages_killed = hostages_killed or criminal.hostages_killed
		criminal.respawn_penalty = respawn_penalty or criminal.respawn_penalty
	end
end

function GroupAIStateBase:on_AI_criminal_death(criminal_name, unit)
	if not Network:is_server() then
		return
	end

	local respawn_penalty = self._criminals[unit:key()].respawn_penalty or tweak_data.character[unit:base()._tweak_table].damage.base_respawn_time_penalty

	managers.trade:on_AI_criminal_death(criminal_name, respawn_penalty, self._criminals[unit:key()].hostages_killed or 0)
end

function GroupAIStateBase:on_player_criminal_death(peer_id)
	managers.player:transfer_special_equipment(peer_id)

	local unit = managers.network:session():peer(peer_id):unit()

	if not unit then
		return
	end

	local my_peer_id = managers.network:session():local_peer():id()

	if my_peer_id ~= peer_id then
		managers.notification:add_notification({
			duration = 3,
			shelf_life = 5,
			id = "hint_teammate_dead",
			text = managers.localization:text("hint_teammate_dead", {
				TEAMMATE = unit:base():nick_name()
			})
		})
		managers.hud:on_teammate_died(managers.network:session():all_peers()[peer_id]:teammate_panel_id(), managers.network:session():all_peers()[peer_id]:unit():unit_data().name_label_id)
	end

	if not Network:is_server() then
		return
	end

	local criminal_name = managers.criminals:character_name_by_peer_id(peer_id)
	local respawn_penalty = self._criminals[unit:key()].respawn_penalty or tweak_data.player.damage.base_respawn_time_penalty

	managers.trade:on_player_criminal_death(criminal_name, respawn_penalty, self._criminals[unit:key()].hostages_killed or 0)
	managers.criminals:on_last_valid_player_spawn_point_updated(unit)
end

function GroupAIStateBase:all_AI_criminals()
	return self._ai_criminals
end

function GroupAIStateBase:all_player_criminals()
	return self._player_criminals
end

function GroupAIStateBase:all_criminals()
	return self._criminals
end

function GroupAIStateBase:all_char_criminals()
	return self._char_criminals
end

function GroupAIStateBase:amount_of_ai_criminals()
	return table.size(self._ai_criminals)
end

function GroupAIStateBase:amount_of_winning_ai_criminals()
	local amount = 0

	for _, u_data in pairs(self._ai_criminals) do
		if alive(u_data.unit) and not u_data.unit:character_damage():bleed_out() and not u_data.unit:character_damage():fatal() and not u_data.unit:character_damage():arrested() and not u_data.unit:character_damage():dead() then
			amount = amount + 1
		end
	end

	return amount
end

function GroupAIStateBase:fleeing_civilians()
	return self._fleeing_civilians
end

function GroupAIStateBase:all_hostages()
	return self._hostage_keys
end

function GroupAIStateBase:is_a_hostage_within(mvec_pos, radius)
	local units = World:find_units_quick("sphere", mvec_pos, radius, 22)

	return units and #units > 0
end

function GroupAIStateBase:on_criminal_team_AI_enabled_state_changed(transition)
	if Network:is_client() then
		return
	end

	if managers.groupai:state():team_ai_enabled() then
		self:fill_criminal_team_with_AI(transition)
	else
		for i = 1, 3 do
			self:remove_one_teamAI()
		end
	end
end

function GroupAIStateBase:_draw_enemy_importancies()
	for e_key, e_data in pairs(self._police) do
		local imp = e_data.importance

		while imp > 0 do
			Application:draw_sphere(e_data.m_pos, 50 * imp, 1, 1, 1)

			imp = imp - 1
		end

		if e_data.unit:brain()._important then
			Application:draw_cylinder(e_data.m_pos, e_data.m_pos + math.UP * 300, 35, 0, 1, 0)
		end
	end

	for c_key, c_data in pairs(self._player_criminals) do
		local imp_enemies = c_data.important_enemies

		for imp, e_key in ipairs(imp_enemies) do
			local tint = math.clamp(1 - imp / self._nr_important_cops, 0, 1)

			Application:draw_cylinder(self._police[e_key].m_pos, c_data.m_pos, 10, tint, 0, 0, 1 - tint)
		end
	end
end

function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	if #wgt_report == 0 then
		return
	end

	local t_rem = table.remove
	local t_ins = table.insert
	local max_nr_imp = self._nr_important_cops
	local imp_adj = 0
	local criminals = self._player_criminals
	local cops = self._police

	for i_dis_rep = #wgt_report - 1, 1, -2 do
		local c_key = wgt_report[i_dis_rep]
		local c_dis = wgt_report[i_dis_rep + 1]
		local c_record = criminals[c_key]
		local imp_enemies = c_record.important_enemies
		local imp_dis = c_record.important_dis
		local was_imp = nil

		for i_imp = #imp_enemies, 1, -1 do
			if imp_enemies[i_imp] == u_key then
				table.remove(imp_enemies, i_imp)
				table.remove(imp_dis, i_imp)

				was_imp = true

				break
			end
		end

		local i_imp = #imp_dis

		while i_imp > 0 do
			if imp_dis[i_imp] <= c_dis then
				break
			end

			i_imp = i_imp - 1
		end

		if i_imp < max_nr_imp then
			i_imp = i_imp + 1

			while max_nr_imp <= #imp_enemies do
				local dump_e_key = imp_enemies[#imp_enemies]

				self:_adjust_cop_importance(dump_e_key, -1)
				t_rem(imp_enemies)
				t_rem(imp_dis)
			end

			t_ins(imp_enemies, i_imp, u_key)
			t_ins(imp_dis, i_imp, c_dis)

			if not was_imp then
				imp_adj = imp_adj + 1
			end
		elseif was_imp then
			imp_adj = imp_adj - 1
		end
	end

	if imp_adj ~= 0 then
		self:_adjust_cop_importance(u_key, imp_adj)
	end
end

function GroupAIStateBase:_adjust_cop_importance(e_key, imp_adj)
	local e_data = self._police[e_key]
	local old_imp = e_data.importance
	e_data.importance = old_imp + imp_adj

	if old_imp == 0 or e_data.importance == 0 then
		e_data.unit:brain():set_important(old_imp == 0)
	end
end

function GroupAIStateBase:sync_smoke_grenade(detonate_pos, shooter_pos, duration, flashbang)
	local smoke_duration = duration == 0 and 15 or duration

	if flashbang then
		local flash_grenade = World:spawn_unit(Idstring("units/dev_tools/deleted_unit/deleted_unit"), detonate_pos, Rotation())

		flash_grenade:base():activate(shooter_pos or detonate_pos, duration)
	else
		self._smoke_grenade = World:spawn_unit(Idstring("units/dev_tools/deleted_unit/deleted_unit"), detonate_pos, Rotation())

		self._smoke_grenade:base():activate(shooter_pos or detonate_pos, smoke_duration)
		managers.groupai:state():teammate_comment(nil, "g40x_any", detonate_pos, true, 2000, false)
	end

	self._smoke_end_t = Application:time() + smoke_duration
	self._smoke_grenade_ignore_control = nil
end

function GroupAIStateBase:sync_smoke_grenade_kill()
	if alive(self._smoke_grenade) then
		self._smoke_grenade:base():preemptive_kill()

		self._smoke_grenade = nil
	end

	self._smoke_end_t = nil
end

function GroupAIStateBase:sync_cs_grenade(detonate_pos, shooter_pos, duration)
	local cs_duration = duration == 0 and 15 or duration
	self._cs_grenade = World:spawn_unit(Idstring("units/dev_tools/deleted_unit/deleted_unit"), detonate_pos, Rotation())

	self._cs_grenade:base():activate(shooter_pos or detonate_pos, cs_duration)

	self._cs_end_t = Application:time() + cs_duration
	self._cs_grenade_ignore_control = nil
end

function GroupAIStateBase:sync_cs_grenade_kill()
	if alive(self._cs_grenade) then
		self._cs_grenade:base():preemptive_kill()

		self._cs_grenade = nil
	end

	self._cs_end_t = nil
end

function GroupAIStateBase:_call_listeners(event, params)
	self._listener_holder:call(event, params)
end

function GroupAIStateBase:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function GroupAIStateBase:remove_listener(key)
	self._listener_holder:remove(key)
end

function GroupAIStateBase:sync_hostage_headcount(nr_hostages)
	if nr_hostages then
		self._hostage_headcount = nr_hostages
	elseif Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_hostage_headcount", math.min(self._hostage_headcount, 63))
	end

	managers.hud:set_control_info({
		nr_hostages = self._hostage_headcount
	})
	managers.player:update_hostage_skills()
	self:check_gameover_conditions()
end

function GroupAIStateBase:_set_rescue_state(state)
	self._rescue_allowed = state
	local all_civilians = managers.enemy:all_civilians()

	for u_key, civ_data in pairs(all_civilians) do
		civ_data.unit:brain():on_rescue_allowed_state(state)
	end

	for u_key, e_data in pairs(self._police) do
		e_data.unit:brain():on_rescue_allowed_state(state)
	end
end

function GroupAIStateBase:rescue_state()
	return true
end

function GroupAIStateBase:chk_area_leads_to_enemy(start_nav_seg_id, test_nav_seg_id, enemy_is_criminal)
	local enemy_areas = {}

	for c_key, c_data in pairs(enemy_is_criminal and self._criminals or self._police) do
		enemy_areas[c_data.tracker:nav_segment()] = true
	end

	local all_nav_segs = managers.navigation._nav_segments
	local found_nav_segs = {
		[start_nav_seg_id] = true,
		[test_nav_seg_id] = true
	}
	local to_search_nav_segs = {
		test_nav_seg_id
	}

	repeat
		local chk_nav_seg_id = table.remove(to_search_nav_segs)
		local chk_nav_seg = all_nav_segs[chk_nav_seg_id]

		if enemy_areas[chk_nav_seg_id] then
			return true
		end

		local neighbours = chk_nav_seg.neighbours

		for neighbour_seg_id, door_list in pairs(neighbours) do
			if not all_nav_segs[neighbour_seg_id].disabled and not found_nav_segs[neighbour_seg_id] then
				found_nav_segs[neighbour_seg_id] = true

				table.insert(to_search_nav_segs, neighbour_seg_id)
			end
		end
	until #to_search_nav_segs == 0
end

function GroupAIStateBase:occasional_event_info(event_type)
	return self._occasional_events[event_type]
end

function GroupAIStateBase:on_occasional_event(event_type)
	local event_data = self._occasional_events[event_type]

	if not event_data then
		event_data = {}
		self._occasional_events[event_type] = event_data
	end

	event_data.count = (event_data.count or 0) + 1
	event_data.last_occurence_t = TimerManager:game():time()
end

function GroupAIStateBase:on_player_spawn_state_set(state_name)
	self:on_player_weapons_hot()
end

function GroupAIStateBase:chk_say_enemy_chatter(unit, unit_pos, chatter_type)
	if unit:sound():speaking(self._t) then
		return
	end

	local chatter_tweak = tweak_data.group_ai.enemy_chatter[chatter_type]
	local chatter_type_hist = self._enemy_chatter[chatter_type]

	if not chatter_type_hist then
		chatter_type_hist = {
			cooldown_t = 0,
			events = {}
		}
		self._enemy_chatter[chatter_type] = chatter_type_hist
	end

	local t = self._t

	if t < chatter_type_hist.cooldown_t then
		return
	end

	local nr_events_in_area = 0

	for i_event, event_data in pairs(chatter_type_hist.events) do
		if event_data.expire_t < t then
			chatter_type_hist[i_event] = nil
		elseif mvector3.distance(unit_pos, event_data.epicenter) < chatter_tweak.radius then
			if nr_events_in_area == chatter_tweak.max_nr - 1 then
				return
			else
				nr_events_in_area = nr_events_in_area + 1
			end
		end
	end

	local group_requirement = chatter_tweak.group_min

	if group_requirement and group_requirement > 1 then
		local u_data = self._police[unit:key()]
		local nr_in_group = 1

		if u_data.group then
			nr_in_group = u_data.group.size
		end

		if nr_in_group < group_requirement then
			return
		end
	end

	chatter_type_hist.cooldown_t = t + math.lerp(chatter_tweak.interval[1], chatter_tweak.interval[2], math.random())
	local new_event = {
		epicenter = mvector3.copy(unit_pos),
		expire_t = t + math.lerp(chatter_tweak.duration[1], chatter_tweak.duration[2], math.random())
	}

	table.insert(chatter_type_hist.events, new_event)
	unit:sound():say(chatter_tweak.queue, true)

	return true
end

function GroupAIStateBase:chk_say_teamAI_combat_chatter(unit)
	if not self:is_detection_persistent() then
		return
	end

	local drama_amount = self._drama_data.amount
	local frequency_lerp = drama_amount
	local delay = math.lerp(2, 0.5, frequency_lerp)
	local delay_t = self._teamAI_last_combat_chatter_t + delay

	if self._t < delay_t then
		return
	end

	local frequency_lerp_clamp = math.clamp(frequency_lerp^2, 0, 1)
	local chance = math.lerp(0.01, 0.1, frequency_lerp_clamp)

	if chance < math.random() then
		return
	end

	managers.dialog:queue_dialog("player_gen_battle_celebration", {
		skip_idle_check = true
	})
end

function GroupAIStateBase:_mark_hostage_areas_as_unsafe()
	local all_areas = self._area_data

	for u_key, u_data in pairs(managers.enemy:all_civilians()) do
		if u_data.char_tweak.flee_type == "escape" then
			local area = self:get_area_from_nav_seg_id(u_data.tracker:nav_segment())
			area.is_safe = nil
		end
	end
end

function GroupAIStateBase:on_nav_link_unregistered(element_id)
	local all_ai = {
		self._police,
		self._ai_criminals,
		managers.enemy:all_civilians()
	}

	for _, ai_group in pairs(all_ai) do
		for u_key, u_data in pairs(ai_group) do
			u_data.unit:movement():on_nav_link_unregistered(element_id)
			u_data.unit:brain():on_nav_link_unregistered(element_id)
		end
	end
end

function GroupAIStateBase:chk_allow_drop_in()
	if self._forbid_drop_in or not self._allow_dropin then
		return false
	end

	return true
end

function GroupAIStateBase:_get_anticipation_duration(anticipation_duration_table, is_first)
	local anticipation_duration = anticipation_duration_table[1][1]

	if not is_first then
		local rand = math.random()
		local accumulated_chance = 0

		for i, setting in pairs(anticipation_duration_table) do
			accumulated_chance = accumulated_chance + setting[2]

			if rand <= accumulated_chance then
				anticipation_duration = setting[1]

				break
			end
		end
	end

	return anticipation_duration
end

function GroupAIStateBase:add_preferred_spawn_points(id, spawn_points)
	self:_map_spawn_points_to_respective_areas(id, spawn_points)

	self._spawn_points[id] = spawn_points
end

function GroupAIStateBase:add_preferred_spawn_groups(id, spawn_groups)
	self:_map_spawn_groups_to_respective_areas(id, spawn_groups)

	self._spawn_groups[id] = spawn_groups
end

function GroupAIStateBase:_map_spawn_points_to_respective_areas(id, spawn_points)
	local nav_manager = managers.navigation

	for _, new_spawn_point in ipairs(spawn_points) do
		local pos = new_spawn_point:value("position")
		local interval = new_spawn_point:value("interval")
		local amount = new_spawn_point:get_random_table_value(new_spawn_point:value("amount"))
		local nav_seg = nav_manager:get_nav_seg_from_pos(pos, true)
		local area = self:get_area_from_nav_seg_id(nav_seg)
		local accessibility = new_spawn_point:accessibility()
		local new_spawn_point_data = {
			delay_t = -1,
			id = id,
			pos = pos,
			nav_seg = nav_seg,
			area = area,
			spawn_point = new_spawn_point,
			amount = amount > 0 and amount,
			interval = interval,
			accessibility = accessibility ~= "any" and accessibility
		}
		local area_spawn_points = area.spawn_points

		if area_spawn_points then
			table.insert(area_spawn_points, new_spawn_point_data)
		else
			area_spawn_points = {
				new_spawn_point_data
			}
			area.spawn_points = area_spawn_points
		end
	end
end

function GroupAIStateBase:_map_spawn_groups_to_respective_areas(id, spawn_groups)
	for _, spawn_grp_element in ipairs(spawn_groups) do
		local spawn_points = spawn_grp_element:spawn_points()
		local spawn_group_names = spawn_grp_element:spawn_groups()

		if spawn_points and next(spawn_points) and spawn_group_names and next(spawn_group_names) then
			local new_spawn_group_data, area = self:create_spawn_group(id, spawn_grp_element, spawn_points)
			local area_spawn_groups = area.spawn_groups

			if area_spawn_groups then
				table.insert(area_spawn_groups, new_spawn_group_data)
			else
				area_spawn_groups = {
					new_spawn_group_data
				}
				area.spawn_groups = area_spawn_groups
			end
		end
	end
end

function GroupAIStateBase:create_spawn_group(id, spawn_group, spawn_points)
	local pos = spawn_points[1]:value("position")
	local nav_seg = managers.navigation:get_nav_seg_from_pos(spawn_points[1]:value("position"), true)
	local area = self:get_area_from_nav_seg_id(nav_seg)
	local interval = spawn_group:value("interval")
	local amount = spawn_group:get_random_table_value(spawn_group:value("amount"))

	if amount <= 0 then
		amount = nil
	end

	local new_spawn_group_data = {
		delay_t = -1,
		id = id,
		pos = Vector3(),
		nav_seg = nav_seg,
		area = area,
		mission_element = spawn_group,
		amount = amount,
		interval = interval,
		spawn_pts = {},
		team_id = spawn_group:value("team")
	}
	local nr_elements = 0

	for _, spawn_pt_element in ipairs(spawn_points) do
		local interval = spawn_pt_element:value("interval")
		local amount = spawn_pt_element:get_random_table_value(spawn_pt_element:value("amount"))

		if amount <= 0 then
			amount = nil
		end

		local accessibility = spawn_pt_element:accessibility()
		local sp_data = {
			delay_t = -1,
			pos = spawn_pt_element:value("position"),
			interval = interval,
			amount = amount,
			accessibility = accessibility,
			mission_element = spawn_pt_element
		}

		table.insert(new_spawn_group_data.spawn_pts, sp_data)
		mvector3.add(new_spawn_group_data.pos, spawn_pt_element:value("position"))

		nr_elements = nr_elements + 1
	end

	mvector3.divide(new_spawn_group_data.pos, nr_elements)

	return new_spawn_group_data, area
end

function GroupAIStateBase:_remove_preferred_spawn_point_from_area(area, sp_data)
	if not area.spawn_points then
		return
	end

	for i, sp_data_ in ipairs(area.spawn_points) do
		if sp_data_ == sp_data then
			area.spawn_points[i] = area.spawn_points[#area.spawn_points]

			table.remove(area.spawn_points)

			if not next(area.spawn_points) then
				area.spawn_points = nil
			end

			break
		end
	end
end

function GroupAIStateBase:_remove_preferred_spawn_group_from_area(area, sp_data)
	if not area.spawn_groups then
		return
	end

	for i, sp_data_ in ipairs(area.spawn_groups) do
		if sp_data_ == sp_data then
			area.spawn_groups[i] = area.spawn_groups[#area.spawn_groups]

			table.remove(area.spawn_groups)

			if not next(area.spawn_groups) then
				area.spawn_groups = nil
			end

			break
		end
	end
end

function GroupAIStateBase:remove_preferred_spawn_points(id)
	if self._spawn_points[id] then
		for nav_seg, area_data in pairs(self._area_data) do
			local area_spawn_points = area_data.spawn_points

			if area_spawn_points then
				local i_sp = #area_spawn_points

				while i_sp > 0 do
					local sp_data = area_spawn_points[i_sp]

					if sp_data.id == id then
						area_spawn_points[i_sp] = area_spawn_points[#area_spawn_points]

						table.remove(area_spawn_points)
					end

					i_sp = i_sp - 1
				end

				if not next(area_spawn_points) then
					area_data.spawn_points = nil
				end
			end
		end

		self._spawn_points[id] = nil
	elseif self._spawn_groups[id] then
		for nav_seg, area_data in pairs(self._area_data) do
			local area_spawn_points = area_data.spawn_groups

			if area_spawn_points then
				local i_sp = #area_spawn_points

				while i_sp > 0 do
					local sp_data = area_spawn_points[i_sp]

					if sp_data.id == id then
						area_spawn_points[i_sp] = area_spawn_points[#area_spawn_points]

						table.remove(area_spawn_points)
					end

					i_sp = i_sp - 1
				end

				if not next(area_spawn_points) then
					area_data.spawn_groups = nil
				end
			end
		end

		self._spawn_groups[id] = nil
	end
end

function GroupAIStateBase:register_AI_attention_object(unit, handler, nav_tracker, team, SO_access)
	self._attention_objects.all[unit:key()] = {
		unit = unit,
		handler = handler,
		nav_tracker = nav_tracker,
		team = team,
		SO_access = SO_access
	}

	self:on_AI_attention_changed(unit:key())
end

function GroupAIStateBase:on_AI_attention_changed(unit_key)
	local att_info = self._attention_objects.all[unit_key]

	for cat_filter, list in pairs(self._attention_objects) do
		if cat_filter ~= "all" then
			local cat_filter_num = managers.navigation:convert_access_filter_to_number({
				cat_filter
			})

			if not att_info or att_info.handler:get_attention(cat_filter_num, nil, nil, nil) then
				list[unit_key] = att_info
			else
				list[unit_key] = nil
			end
		end
	end
end

function GroupAIStateBase:unregister_AI_attention_object(unit_key)
	for cat_filter, list in pairs(self._attention_objects) do
		list[unit_key] = nil
	end
end

function GroupAIStateBase:get_all_AI_attention_objects()
	return self._attention_objects.all
end

function GroupAIStateBase:get_AI_attention_objects_by_filter(filter)
	if not self._attention_objects[filter] then
		local filter_num = managers.navigation:convert_access_filter_to_number({
			filter
		})
		local new_attention_set = {}

		for u_key, attention_info in pairs(self._attention_objects.all) do
			if attention_info.handler:get_attention(filter_num, nil, nil, nil) then
				new_attention_set[u_key] = attention_info
			end
		end

		self._attention_objects[filter] = new_attention_set
	end

	return self._attention_objects[filter]
end

function GroupAIStateBase:_get_new_group_id(group_type)
	local all_groups = self._groups
	local i = 1
	local id = nil

	repeat
		id = group_type .. tostring(i)
		i = i + 1
	until not all_groups[id]

	return id
end

function GroupAIStateBase:_create_group(group_desc)
	local id = self:_get_new_group_id(group_desc.type)
	local all_groups = self._groups
	local group = {
		size = 0,
		casualties = 0,
		has_spawned = false,
		id = id,
		type = group_desc.type,
		units = {},
		initial_size = group_desc.size
	}
	all_groups[id] = group

	return group
end

function GroupAIStateBase:_remove_group_member(group, u_key, is_casualty)
	if group.size <= 1 and group.has_spawned then
		self._groups[group.id] = nil

		return true
	end

	group.size = group.size - 1

	if is_casualty then
		group.casualties = group.casualties + 1
	end

	if group.leader_key == u_key then
		u_data.leader_key = nil
	end

	group.units[u_key] = nil
end

function GroupAIStateBase:unit_leave_group(unit, is_casualty)
	if alive(unit) then
		local brain = unit:brain()
		local group = brain._logic_data.group

		self:_remove_group_member(group, unit:key(), is_casualty)
		brain:set_group(nil)
	end
end

function GroupAIStateBase:_add_group_member(group, u_key)
	group.size = group.size + 1
	local u_data = self._police[u_key]
	u_data.group = group
	group.units[u_key] = u_data

	if not group.leader_key and u_data.char_tweak.leader then
		u_data.leader_key = u_key
	end

	u_data.unit:movement():set_team(group.team)
	u_data.unit:brain():set_group(group)
end

function GroupAIStateBase:add_area(area_id, nav_segs, area_pos)
	local all_areas = self._area_data

	if all_areas[area_id] then
		return
	end

	local new_area = self:_empty_area_data()
	new_area.id = area_id
	new_area.pos = area_pos
	new_area.pos_nav_seg = managers.navigation:get_nav_seg_from_pos(area_pos, true)

	for _, seg_id in ipairs(nav_segs) do
		new_area.nav_segs[seg_id] = true
	end

	for _, seg_id in ipairs(nav_segs) do
		self._nav_seg_to_area_map[seg_id] = new_area
	end

	for _, seg_id in ipairs(nav_segs) do
		if all_areas[seg_id] then
			local neighbours = all_areas[seg_id].neighbours
			all_areas[seg_id] = nil

			for neighbour_area_id, neighbour_area in pairs(neighbours) do
				neighbour_area.neighbours[seg_id] = nil
			end
		end
	end

	local all_nav_segs = managers.navigation._nav_segments

	for _, seg_id in ipairs(nav_segs) do
		local nav_seg = all_nav_segs[seg_id]

		if nav_seg then
			if not nav_seg.disabled then
				for neighbour_seg_id, door_list in pairs(nav_seg.neighbours) do
					local neighbour_nav_seg = all_nav_segs[neighbour_seg_id]

					if not neighbour_nav_seg.disabled then
						for other_area_id, other_area in pairs(all_areas) do
							if other_area.nav_segs[neighbour_seg_id] then
								new_area.neighbours[other_area_id] = other_area

								if neighbour_nav_seg.neighbours[seg_id] then
									other_area.neighbours[new_area.id] = new_area
								end
							end
						end
					end
				end
			end
		else
			debug_pause("[GroupAIStateBase:add_area] area", area_id, "includes removed nav_segment", seg_id)
		end
	end

	all_areas[area_id] = new_area
end

function GroupAIStateBase:_empty_area_data()
	return {
		police = {
			units = {}
		},
		criminal = {
			units = {}
		},
		factors = {},
		neighbours = {},
		nav_segs = {}
	}
end

function GroupAIStateBase:unload_world_nav_data(world_id, all_nav_segs)
	local all_area_ids = {}

	if not self._loaded_world_navs or not self._loaded_world_navs[world_id] then
		return
	end

	for seg_id, nav_seg in pairs(all_nav_segs) do
		local area_id = self._nav_seg_to_area_map[seg_id].id
		self._area_data[area_id] = nil
		self._nav_seg_to_area_map[seg_id] = nil

		table.insert(all_area_ids, area_id)
	end

	for _, data in pairs(self._area_data) do
		for area_id, neighbour in pairs(data.neighbours) do
			if table.contains(all_area_ids, area_id) then
				data.neighbours[area_id] = nil
			end
		end
	end

	self._loaded_world_navs[world_id] = false
end

function GroupAIStateBase:merge_world_data(world_id)
	self:_create_area_data(world_id)
end

function GroupAIStateBase:_create_area_data(world_id)
	local all_areas, nav_seg_to_area_map = nil
	local all_nav_segs = managers.navigation._nav_segments
	local world_nav_segs = nil

	if world_id and world_id > 0 then
		self._loaded_world_navs = self._loaded_world_navs or {}

		if not self._loaded_world_navs[world_id] then
			all_areas = self._area_data
			nav_seg_to_area_map = self._nav_seg_to_area_map
			world_nav_segs = managers.navigation:get_nav_seg_for_world(world_id)
			self._loaded_world_navs[world_id] = true
		else
			return
		end
	else
		all_areas = {}
		nav_seg_to_area_map = {}
		self._nav_seg_to_area_map = nav_seg_to_area_map
		self._area_data = all_areas
		world_nav_segs = all_nav_segs
	end

	for seg_id, nav_seg in pairs(world_nav_segs) do
		local new_area = self:_empty_area_data()
		new_area.nav_segs[seg_id] = true
		new_area.id = seg_id
		new_area.pos = nav_seg.pos
		new_area.pos_nav_seg = seg_id

		if not nav_seg.disabled then
			local seg_neighbours = nav_seg.neighbours
			local area_neighbours = new_area.neighbours

			for other_nav_seg_id, door_list in pairs(seg_neighbours) do
				local other_nav_seg = all_nav_segs[other_nav_seg_id]

				if not other_nav_seg.disabled then
					for other_area_id, other_area in pairs(all_areas) do
						if other_area.nav_segs[other_nav_seg_id] then
							new_area.neighbours[other_area_id] = other_area

							if other_nav_seg.neighbours[seg_id] then
								other_area.neighbours[new_area.id] = new_area
							end
						end
					end
				end
			end
		end

		nav_seg_to_area_map[seg_id] = new_area
		all_areas[seg_id] = new_area
	end
end

function GroupAIStateBase:get_area_from_nav_seg_id(nav_seg_id)
	if self._nav_seg_to_area_map[nav_seg_id] then
		return self._nav_seg_to_area_map[nav_seg_id]
	else
		Application:error("[GroupAIStateBase:get_area_from_nav_seg_id] area not found: ", nav_seg_id, debug.traceback())
	end
end

function GroupAIStateBase:get_areas_from_nav_seg_id(nav_seg_id)
	local areas = {}

	for area_id, area in pairs(self._area_data) do
		if area.nav_segs[nav_seg_id] then
			table.insert(areas, area)
		end
	end

	return areas
end

function GroupAIStateBase.get_nav_seg_id_from_area(area)
	for nav_seg_id, _ in pairs(area.nav_segs) do
		if not managers.navigation._nav_segments[nav_seg_id].disabled then
			return nav_seg_id
		end
	end

	debug_pause("[GroupAIStateBase:get_nav_seg_id_from_area] area\n", inspect(area))

	return table.random_key(area.nav_segs)
end

function GroupAIStateBase:is_area_safe(area)
	for u_key, u_data in pairs(self._criminals) do
		if area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end

	return true
end

function GroupAIStateBase:is_area_safe_assault(area)
	for u_key, u_data in pairs(self._criminals) do
		if not u_data.is_deployable and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end

	return true
end

function GroupAIStateBase:is_nav_seg_safe(nav_seg)
	local area = self:get_area_from_nav_seg_id(nav_seg)

	return self:is_area_safe(area)
end

function GroupAIStateBase:_on_area_safety_status(area, event)
	local safe = area.is_safe
	local unit_data = self._police

	for u_key, _ in pairs(area.police.units) do
		local unit = unit_data[u_key].unit

		unit:brain():on_area_safety(area, safe, event)
	end

	for other_area_id, other_area in pairs(area.neighbours) do
		for u_key, _ in pairs(other_area.police.units) do
			local unit = unit_data[u_key].unit

			unit:brain():on_area_safety(self.get_nav_seg_id_from_area(area), safe, event)
		end
	end
end

function GroupAIStateBase:on_nav_segment_state_change(changed_seg_id, state)
	local all_nav_segs = managers.navigation._nav_segments
	local changed_seg = all_nav_segs[changed_seg_id]
	local changed_seg_neighbours = changed_seg.neighbours

	for area_id, area in pairs(self._area_data) do
		if area.nav_segs[changed_seg_id] then
			if state then
				for neighbour_seg_id, door_list in pairs(changed_seg_neighbours) do
					local neighbour_nav_seg = all_nav_segs[neighbour_seg_id]

					if not neighbour_nav_seg.disabled then
						for other_area_id, other_area in pairs(self._area_data) do
							if other_area_id ~= area_id and other_area.nav_segs[neighbour_seg_id] then
								area.neighbours[other_area_id] = other_area

								if neighbour_nav_seg.neighbours[changed_seg_id] then
									other_area.neighbours[area_id] = area
								end
							end
						end
					end
				end
			else
				for other_area_id, other_area in pairs(area.neighbours) do
					other_area.neighbours[area_id] = nil
				end

				area.neighbours = {}

				for seg_id, _ in pairs(area.nav_segs) do
					if not all_nav_segs[seg_id].disabled then
						local nav_seg_neighbours = all_nav_segs[seg_id].neighbours

						for other_nav_seg_id, door_list in pairs(nav_seg_neighbours) do
							local other_nav_seg = all_nav_segs[other_nav_seg_id]

							if not other_nav_seg.disabled then
								for other_area_id, other_area in pairs(self._area_data) do
									if other_area_id ~= area_id and other_area.nav_segs[other_nav_seg_id] then
										area.neighbours[other_area_id] = other_area

										if other_nav_seg.neighbours[seg_id] then
											other_area.neighbours[area_id] = area
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:on_nav_seg_neighbour_state(start_seg_id, end_seg_id, state)
	local all_nav_segs = managers.navigation._nav_segments

	for area_id, area in pairs(self._area_data) do
		if area.nav_segs[start_seg_id] then
			for other_area_id, other_area in pairs(area.neighbours) do
				other_area.neighbours[area_id] = nil
			end

			area.neighbours = {}

			for seg_id, _ in pairs(area.nav_segs) do
				if not all_nav_segs[seg_id].disabled then
					local nav_seg_neighbours = all_nav_segs[seg_id].neighbours

					for other_nav_seg_id, door_list in pairs(nav_seg_neighbours) do
						local other_nav_seg = all_nav_segs[other_nav_seg_id]

						if not other_nav_seg then
							Application:debug("[GroupAIStateBase:on_nav_seg_neighbour_state] non existing segment!!!! ", other_nav_seg_id)
						end

						if not other_nav_seg.disabled then
							for other_area_id, other_area in pairs(self._area_data) do
								if other_area_id ~= area_id and other_area.nav_segs[other_nav_seg_id] then
									area.neighbours[other_area_id] = other_area

									if other_nav_seg.neighbours[seg_id] then
										other_area.neighbours[area_id] = area
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:set_enemy_assigned(area, unit_key)
	local u_data = self._police[unit_key]

	if not u_data then
		return
	end

	if u_data.assigned_area then
		u_data.assigned_area.police.units[unit_key] = nil
	end

	if area then
		area.police.units[unit_key] = u_data
		u_data.assigned_area = area
	else
		u_data.assigned_area = nil
	end
end

function GroupAIStateBase.clone_objective(objective)
	local cmpl_clbk = objective.complete_clbk
	local fail_clbk = objective.fail_clbk
	local act_start_clbk = objective.action_start_clbk
	local ver_clbk = objective.verification_clbk
	local area = objective.area
	local followup_SO = objective.followup_SO
	local grp_objective = objective.grp_objective
	local followup_objective = objective.followup_objective
	local element = objective.element
	objective.complete_clbk = nil
	objective.fail_clbk = nil
	objective.action_start_clbk = nil
	objective.verification_clbk = nil
	objective.area = nil
	objective.followup_SO = nil
	objective.grp_objective = nil
	objective.followup_objective = nil
	objective.element = nil
	local new_objective = deep_clone(objective)
	objective.complete_clbk = cmpl_clbk
	objective.fail_clbk = fail_clbk
	objective.action_start_clbk = act_start_clbk
	objective.verification_clbk = ver_clbk
	objective.area = area
	objective.followup_SO = followup_SO
	objective.grp_objective = grp_objective
	objective.followup_objective = followup_objective
	objective.element = element
	new_objective.complete_clbk = cmpl_clbk
	new_objective.fail_clbk = fail_clbk
	new_objective.action_start_clbk = act_start_clbk
	new_objective.verification_clbk = ver_clbk
	new_objective.area = area
	new_objective.followup_SO = followup_SO
	new_objective.grp_objective = grp_objective
	new_objective.followup_objective = followup_objective
	new_objective.element = element

	return new_objective
end

function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit)
	local player_unit = peer_unit or managers.player:player_unit()

	if not alive(player_unit) or not self._criminals[player_unit:key()] then
		return
	end

	if not alive(unit) then
		return
	end

	local u_key = unit:key()
	local u_data = self._police[u_key]

	if not u_data then
		return
	end

	local minions = self._criminals[player_unit:key()].minions or {}
	self._criminals[player_unit:key()].minions = minions
	local max_minions = 0

	if peer_unit then
		max_minions = peer_unit:base():upgrade_value("player", "convert_enemies_max_minions") or 0
	else
		max_minions = managers.player:upgrade_value("player", "convert_enemies_max_minions", 0)
	end

	Application:debug("GroupAIStateBase:convert_hostage_to_criminal", "Player", player_unit, "Minions: ", table.size(minions) .. "/" .. max_minions)

	if alive(self._converted_police[u_key]) or max_minions <= table.size(minions) then
		return
	end

	local group = u_data.group
	u_data.group = nil

	if group then
		self:_remove_group_member(group, u_key, nil)
	end

	self:set_enemy_assigned(nil, u_key)

	u_data.is_converted = true

	unit:brain():convert_to_criminal(peer_unit)

	local clbk_key = "Converted" .. tostring(player_unit:key())
	u_data.minion_death_clbk_key = clbk_key
	u_data.minion_destroyed_clbk_key = clbk_key

	unit:character_damage():add_listener(clbk_key, {
		"death"
	}, callback(self, self, "clbk_minion_dies", player_unit:key()))
	unit:base():add_destroy_listener(clbk_key, callback(self, self, "clbk_minion_destroyed", player_unit:key()))

	if not unit:contour() then
		debug_pause_unit(unit, "[GroupAIStateBase:convert_hostage_to_criminal]: Unit doesn't have Contour Extension")
	end

	unit:contour():add("friendly")

	u_data.so_access = unit:brain():SO_access()

	self:_set_converted_police(u_key, unit)

	minions[u_key] = u_data

	unit:movement():set_team(self._teams.converted_enemy)

	local convert_enemies_health_multiplier_level = 0
	local passive_convert_enemies_health_multiplier_level = 0

	if alive(peer_unit) then
		convert_enemies_health_multiplier_level = peer_unit:base():upgrade_level("player", "convert_enemies_health_multiplier") or 0
		passive_convert_enemies_health_multiplier_level = peer_unit:base():upgrade_level("player", "passive_convert_enemies_health_multiplier") or 0
	else
		convert_enemies_health_multiplier_level = managers.player:upgrade_level("player", "convert_enemies_health_multiplier")
		passive_convert_enemies_health_multiplier_level = managers.player:upgrade_level("player", "passive_convert_enemies_health_multiplier")
	end

	local owner_peer_id = managers.network:session():peer_by_unit(player_unit):id()

	managers.network:session():send_to_peers_synched("mark_minion", unit, owner_peer_id, convert_enemies_health_multiplier_level, passive_convert_enemies_health_multiplier_level)

	if not peer_unit then
		managers.player:count_up_player_minions()
	end
end

function GroupAIStateBase:clbk_minion_destroyed(player_key, minion_unit)
	local minion_key = minion_unit:key()
	local owner_data = self._player_criminals[player_key]

	if not owner_data then
		return
	end

	local minion_data = owner_data.minions[minion_key]
	minion_data.minion_destroyed_clbk_key = nil

	self:remove_minion(minion_key, player_key)
end

function GroupAIStateBase:clbk_minion_dies(player_key, minion_unit, damage_info)
	if not self._criminals[player_key] then
		Application:error("GroupAIStateBase:clbk_minion_dies", "Minion dies, but master do not exist", player_key, minion_unit:key(), inspect(damage_info))

		return
	end

	if not self._criminals[player_key].minions then
		Application:error("GroupAIStateBase:clbk_minion_dies", "Master of minion do not have any minions", player_key, minion_unit:key(), inspect(damage_info))

		return
	end

	if not self._criminals[player_key].minions[minion_unit:key()] then
		Application:error("GroupAIStateBase:clbk_minion_dies", "Master does not have this minion", player_key, minion_unit:key(), inspect(damage_info))

		return
	end

	local minion_key = minion_unit:key()
	local owner_data = self._player_criminals[player_key]
	local minion_data = owner_data.minions[minion_key]
	minion_data.minion_death_clbk_key = nil

	self:remove_minion(minion_key, player_key)
end

function GroupAIStateBase:remove_minion(minion_key, player_key)
	local minion_unit = self._converted_police[minion_key]

	if not minion_unit then
		return
	end

	if not player_key then
		for u_key, u_data in pairs(self._player_criminals) do
			if u_data.minions and u_data.minions[minion_key] then
				player_key = u_key

				break
			end
		end

		if not player_key then
			debug_pause_unit(minion_unit, "[GroupAIStateBase:remove_minion] could not find minion owner", minion_unit)
		end
	end

	local owner_data = self._player_criminals[player_key]
	local minion_data = owner_data.minions[minion_key]

	if minion_data.minion_death_clbk_key then
		minion_unit:character_damage():remove_listener(minion_data.minion_death_clbk_key)

		minion_data.minion_death_clbk_key = nil
	end

	if minion_data.minion_destroyed_clbk_key then
		minion_unit:base():remove_destroy_listener(minion_data.minion_destroyed_clbk_key)

		minion_data.minion_destroyed_clbk_key = nil
	end

	self:_set_converted_police(minion_key, nil)

	self._criminals[player_key].minions[minion_key] = nil

	if not next(self._criminals[player_key].minions) then
		self._criminals[player_key].minions = nil
	end

	local peer = managers.network:session():peer_by_unit_key(player_key)

	if peer then
		if peer:id() == managers.network:session():local_peer():id() then
			managers.player:count_down_player_minions()
		else
			managers.network:session():send_to_peer(peer, "count_down_player_minions")
		end
	end
end

function GroupAIStateBase:_set_converted_police(u_key, unit)
	self._converted_police[u_key] = unit

	if not unit then
		self:check_gameover_conditions()
	end
end

function GroupAIStateBase:sync_converted_enemy(converted_enemy)
	local u_data = self._police[converted_enemy:key()]

	if not u_data then
		return
	end

	self:_set_converted_police(converted_enemy:key(), converted_enemy)

	u_data.is_converted = true
end

function GroupAIStateBase:chk_enemy_calling_in_area(area, except_key)
	local area_nav_segs = area.nav_segs

	for u_key, u_data in pairs(self._police) do
		if except_key ~= u_key and area_nav_segs[u_data.tracker:nav_segment()] and u_data.unit:brain()._current_logic_name == "arrest" then
			return true
		end
	end
end

function GroupAIStateBase:register_security_camera(unit, state)
	self._security_cameras[unit:key()] = state and unit or nil
end

function GroupAIStateBase:register_ecm_jammer(unit, jam_settings)
	local was_jammer_active = next(self._ecm_jammers) and true or false
	self._ecm_jammers[unit:key()] = jam_settings and {
		unit = unit,
		settings = jam_settings
	} or nil
	local is_jammer_active = next(self._ecm_jammers) and true or false

	if was_jammer_active then
		if not is_jammer_active then
			managers.mission:call_global_event("ecm_jammer_off", unit)
		end
	elseif is_jammer_active then
		managers.mission:call_global_event("ecm_jammer_on", unit)
	end
end

function GroupAIStateBase:is_ecm_jammer_active(medium)
	for u_key, data in pairs(self._ecm_jammers) do
		if data.settings[medium] then
			return true
		end
	end
end

function GroupAIStateBase:_init_unit_type_filters()
	local nav_manager = managers.navigation

	if not nav_manager:is_data_ready() then
		return
	end

	local convert_f = nav_manager.convert_access_filter_to_number
	local civ_filter = {
		"civ_male",
		"civ_female"
	}
	civ_filter = convert_f(nav_manager, civ_filter)
	local law_enforcer_filter = {
		"security",
		"cop",
		"fbi",
		"swat",
		"murky",
		"sniper",
		"shield",
		"tank"
	}
	law_enforcer_filter = convert_f(nav_manager, law_enforcer_filter)
	local gangster_filter = {
		"gangster"
	}
	gangster_filter = convert_f(nav_manager, gangster_filter)
	local all_enemy_filter = {
		"gangster",
		"security",
		"cop",
		"fbi",
		"swat",
		"murky",
		"sniper",
		"shield",
		"tank"
	}
	all_enemy_filter = convert_f(nav_manager, all_enemy_filter)
	local criminal_filter = {
		"teamAI1",
		"teamAI2",
		"teamAI3",
		"teamAI4"
	}
	criminal_filter = convert_f(nav_manager, criminal_filter)
	local criminals_and_enemies_filter = {
		"gangster",
		"security",
		"cop",
		"fbi",
		"swat",
		"murky",
		"sniper",
		"shield",
		"tank",
		"teamAI1",
		"teamAI2",
		"teamAI3",
		"teamAI4"
	}
	criminals_and_enemies_filter = convert_f(nav_manager, criminals_and_enemies_filter)
	local criminals_enemies_civilians_filter = {
		"civ_male",
		"civ_female",
		"gangster",
		"security",
		"cop",
		"fbi",
		"swat",
		"murky",
		"sniper",
		"shield",
		"tank",
		"teamAI1",
		"teamAI2",
		"teamAI3",
		"teamAI4"
	}
	criminals_enemies_civilians_filter = convert_f(nav_manager, criminals_enemies_civilians_filter)
	local civilians_enemies_filter = {
		"civ_male",
		"civ_female",
		"gangster",
		"security",
		"cop",
		"fbi",
		"swat",
		"murky",
		"sniper",
		"shield",
		"tank"
	}
	civilians_enemies_filter = convert_f(nav_manager, civilians_enemies_filter)
	local combatant_filter = {
		"gangster",
		"security",
		"cop",
		"fbi",
		"swat",
		"murky",
		"sniper",
		"shield",
		"tank",
		"teamAI1",
		"teamAI2",
		"teamAI3",
		"teamAI4"
	}
	combatant_filter = convert_f(nav_manager, combatant_filter)
	local non_combatant_filter = {
		"civ_male",
		"civ_female"
	}
	non_combatant_filter = convert_f(nav_manager, non_combatant_filter)
	local murderer_filter = {
		"gangster"
	}
	murderer_filter = convert_f(nav_manager, murderer_filter)
	local non_special_enemies_filter = {
		"cop",
		"security_patrol",
		"shield",
		"security",
		"gangster",
		"swat",
		"fbi",
		"murky"
	}
	non_special_enemies_filter = convert_f(nav_manager, non_special_enemies_filter)
	local all_filter = convert_f(nav_manager, managers.navigation.ACCESS_FLAGS)
	self._unit_type_filter = {
		none = 0,
		all = all_filter,
		civilian = civ_filter,
		law_enforcer = law_enforcer_filter,
		gangster = gangster_filter,
		all_enemy = all_enemy_filter,
		criminal = criminal_filter,
		criminals_and_enemies = criminals_and_enemies_filter,
		civilians_enemies = civilians_enemies_filter,
		criminals_enemies_civilians = criminals_enemies_civilians_filter,
		combatant = combatant_filter,
		non_combatant = non_combatant_filter,
		murderer = murderer_filter,
		non_special_enemies = non_special_enemies_filter
	}
end

function GroupAIStateBase:get_unit_type_filter(filter_name)
	if self._unit_type_filter then
		return self._unit_type_filter[filter_name]
	end
end

function GroupAIStateBase:sync_event(event_id, blame_id)
	local event_name = self.EVENT_SYNC[event_id]
	local blame_name = self.BLAME_SYNC[blame_id]

	if event_name == "police_called" then
		self._police_called = true

		self:_call_listeners("police_called")
	elseif event_name == "enemy_weapons_hot" then
		self._police_called = true
		self._enemy_weapons_hot = true

		managers.music:raid_music_state_change("control")
		self:_call_listeners("enemy_weapons_hot")
		managers.enemy:set_corpse_disposal_enabled(true)
	elseif event_name == "phalanx_spawned" then
		managers.game_play_central:announcer_say("cpa_a02_01")
	end
end

GroupAIStateBase.blame_triggers = {
	sniper = "cop",
	civilian_female = "civ",
	german_grunt_heavy = "cop",
	german_light = "cop",
	patrol = "cop",
	german_officer = "cop",
	german_fallschirmjager_heavy = "cop",
	civilian = "civ",
	german_gebirgsjager_light = "cop",
	german_commander = "cop",
	german_flamer = "cop",
	german_grunt_mid = "cop",
	german_spotter = "cop",
	german_gasmask_commander_backup_shotgun = "cop",
	german_gasmask = "cop",
	german_gasmask_commander_backup = "cop",
	german_grunt_light = "cop",
	escort = "civ",
	german_heavy = "cop",
	german_fallschirmjager_light = "cop",
	german_og_commander = "cop"
}

function GroupAIStateBase:fetch_highest_giveaway(...)
	local giveaways = {
		...
	}
	local highest_giveaway_id = #self.BLAME_SYNC
	local highest_giveaway = self.BLAME_SYNC[highest_giveaway_id]

	for _, giveaway in pairs(giveaways) do
		if giveaway then
			local index = self:get_sync_blame_id(giveaway)

			if index < highest_giveaway_id then
				highest_giveaway_id = index
				highest_giveaway = giveaway
			end
		end
	end

	return highest_giveaway
end

function GroupAIStateBase.analyse_giveaway(trigger_string, giveaway_unit, additional_info)
	if managers.groupai:state():enemy_weapons_hot() then
		return nil
	end

	if trigger_string == "empty" then
		return trigger_string
	end

	if not giveaway_unit or type(giveaway_unit) ~= "userdata" or not alive(giveaway_unit) then
		if additional_info[1] == "explosion" then
			return "sys_explosion"
		end

		return nil
	end

	local giveaway_prefix = GroupAIStateBase.investigate_trigger(trigger_string)
	local giveaway_string = GroupAIStateBase.investigate_unit(giveaway_unit, additional_info)

	if giveaway_string then
		if giveaway_prefix then
			return tostring(giveaway_prefix) .. "_" .. tostring(giveaway_string)
		else
			return tostring(giveaway_string)
		end
	end

	Application:error("GroupAIStateBase.analyse_giveaway: Investigation Failed!", "trigger_string", trigger_string, "giveaway_prefix", giveaway_prefix, "giveaway_unit", giveaway_unit, "giveaway_string", giveaway_string)
	Application:stack_dump()

	return false
end

function GroupAIStateBase.investigate_trigger(trigger_string)
	local trigger_prefix = GroupAIStateBase.blame_triggers[trigger_string]

	return trigger_prefix
end

function GroupAIStateBase.investigate_unit(giveaway_unit, additional_info)
	local investigate_coolness = false
	local investigate_criminals = true
	local investigate_base = true
	local investigate_attention = true
	local investigate_damage = true
	local investigate_data = true
	local investigate_brain = true
	local investigate_further = true

	if investigate_further and additional_info then
		local alert_type = additional_info[1]

		if alert_type == "vo_cbt" or alert_type == "vo_distress" then
			investigate_coolness = true
		elseif alert_type == "bullet" then
			return "gunfire"
		elseif alert_type ~= "aggression" and alert_type == "explosion" then
			-- Nothing
		end
	end

	if investigate_coolness then
		local unit_movement = giveaway_unit:movement()

		if unit_movement and unit_movement.coolness_giveaway then
			local coolness_giveaway = unit_movement:coolness_giveaway()

			if coolness_giveaway then
				if coolness_giveaway == "default" or coolness_giveaway == "empty" then
					return coolness_giveaway
				end

				return string.sub(coolness_giveaway, 5)
			end
		end
	end

	if investigate_damage then
		local unit_damage = giveaway_unit:character_damage()

		if unit_damage and unit_damage:dead() then
			return "dead_body"
		end
	end

	if investigate_brain then
		local unit_brain = giveaway_unit:brain()

		if unit_brain and unit_brain.is_hostage and unit_brain:is_hostage() then
			return "hostage"
		end
	end

	if investigate_criminals then
		local criminal_color_id = managers.criminals:character_color_id_by_unit(giveaway_unit)

		if criminal_color_id then
			return "criminal"
		end
	end

	if investigate_base then
		local unit_base = giveaway_unit:base()

		if unit_base then
			if unit_base.is_drill then
				return "drill"
			elseif unit_base.is_saw then
				return "saw"
			elseif unit_base.sentry_gun then
				return "sentry_gun"
			elseif unit_base.is_ecmjammer then
				return "ecm_jammer"
			elseif unit_base.c4 then
				return "c4"
			end
		end
	end

	if investigate_attention then
		local unit_attention = giveaway_unit:attention()

		if unit_attention and unit_attention._attention_data then
			for preset, data in pairs(unit_attention._attention_data) do
				if data.giveaway then
					return data.giveaway
				end
			end
		end
	end

	if investigate_data then
		local unit_data = giveaway_unit:unit_data()

		if unit_data and unit_data.blame_giveaway then
			return unit_data.blame_giveaway
		end
	end

	return "distress"
end

function GroupAIStateBase:get_sync_event_id(event_name)
	for i, test_event_name in ipairs(self.EVENT_SYNC) do
		if event_name == test_event_name then
			return i
		end
	end
end

function GroupAIStateBase:get_sync_blame_id(blame_name)
	for i, test_blame_name in ipairs(self.BLAME_SYNC) do
		if blame_name == test_blame_name then
			return i
		end
	end

	return #self.BLAME_SYNC
end

function GroupAIStateBase:_count_police_force(task_name)
	local amount = 0

	if task_name == "recon" or task_name == "assault" then
		for group_id, group in pairs(self._groups) do
			if group.objective.type == "assault_area" or group.objective.type == "recon_area" or group.objective.type == "defend_area" then
				amount = amount + (group.has_spawned and group.size or group.initial_size)
			end
		end
	elseif task_name == "reenforce" then
		for group_id, group in pairs(self._groups) do
			if group.objective.type == "reenforce_area" then
				amount = amount + (group.has_spawned and group.size or group.initial_size)
			end
		end
	end

	return amount
end

function GroupAIStateBase:_merge_coarse_path_by_area(coarse_path)
	local i_nav_seg = #coarse_path
	local last_area = nil

	while i_nav_seg > 0 do
		local nav_seg = coarse_path[i_nav_seg][1]
		local area = self:get_area_from_nav_seg_id(nav_seg)

		if last_area and last_area == area and #coarse_path > 2 then
			table.remove(coarse_path, i_nav_seg)
		end

		i_nav_seg = i_nav_seg - 1
	end
end

function GroupAIStateBase:on_nav_seg_neighbours_state(changed_seg_id, neighbours, state)
	local all_nav_segs = managers.navigation._nav_segments
	local changed_seg = all_nav_segs[changed_seg_id]
	local changed_seg_neighbours = changed_seg.neighbours

	for area_id, area in pairs(self._area_data) do
		if area.nav_segs[changed_seg_id] then
			if state then
				for neighbour_seg_id, door_list in pairs(changed_seg_neighbours) do
					local neighbour_nav_seg = all_nav_segs[neighbour_seg_id]

					if not neighbour_nav_seg.disabled then
						for other_area_id, other_area in pairs(self._area_data) do
							if other_area_id ~= area_id and other_area.nav_segs[neighbour_seg_id] then
								area.neighbours[other_area_id] = other_area

								if neighbour_nav_seg.neighbours[changed_seg_id] then
									other_area.neighbours[area_id] = area
								end
							end
						end
					end
				end
			else
				for other_area_id, other_area in pairs(area.neighbours) do
					other_area.neighbours[area_id] = nil
				end

				area.neighbours = {}

				for seg_id, _ in pairs(area.nav_segs) do
					if not all_nav_segs[seg_id].disabled then
						local nav_seg_neighbours = all_nav_segs[seg_id].neighbours

						for other_nav_seg_id, door_list in pairs(nav_seg_neighbours) do
							local other_nav_seg = all_nav_segs[other_nav_seg_id]

							if not other_nav_seg.disabled then
								for other_area_id, other_area in pairs(self._area_data) do
									if other_area_id ~= area_id and other_area.nav_segs[other_nav_seg_id] then
										area.neighbours[other_area_id] = other_area

										if other_nav_seg.neighbours[seg_id] then
											other_area.neighbours[area_id] = area
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:register_loot(loot_unit, pickup_area)
	local loot_u_key = loot_unit:key()

	for area_id, area in pairs(self._area_data) do
		if area.loot and area.loot[loot_u_key] then
			debug_pause_unit(loot_unit, "[GroupAIStateBase:register_loot] loot registered twice")
		end
	end

	if not pickup_area.loot then
		pickup_area.loot = {}
	end

	pickup_area.loot[loot_u_key] = loot_unit
end

function GroupAIStateBase:unregister_loot(loot_u_key)
	for area_id, area in pairs(self._area_data) do
		if area.loot and area.loot[loot_u_key] then
			area.loot[loot_u_key] = nil

			if not next(area.loot) then
				area.loot = nil
			end

			break
		end
	end
end

function GroupAIStateBase:register_rescueable_hostage(unit, rescue_area)
	local u_key = unit:key()
	local rescue_area = rescue_area or self:get_area_from_nav_seg_id(unit:movement():nav_tracker():nav_segment())

	for area_id, area in pairs(self._area_data) do
		if area.hostages and area.hostages[u_key] then
			debug_pause_unit(unit, "[GroupAIStateBase:register_rescueable_hostage] hostage registered twice")
		end
	end

	if not rescue_area.hostages then
		rescue_area.hostages = {}
	end

	rescue_area.hostages[u_key] = unit
end

function GroupAIStateBase:unregister_rescueable_hostage(u_key)
	for area_id, area in pairs(self._area_data) do
		if area.hostages and area.hostages[u_key] then
			area.hostages[u_key] = nil

			if not next(area.hostages) then
				area.hostages = nil
			end

			break
		end
	end
end

function GroupAIStateBase._create_hud_suspicion_icon(obs_key, u_observer, u_suspect, icon_name, color, icon_id, initial_state)
	local icon_pos = mvector3.copy(math.UP)

	mvector3.multiply(icon_pos, 28)
	mvector3.add(icon_pos, u_observer:movement() and u_observer:movement():m_head_pos() or u_observer:position())

	local suspect, timer = nil

	if u_suspect == managers.player:player_unit() then
		suspect = "player"
		timer = 2
	elseif u_suspect == nil then
		suspect = "teammate"
		timer = 0
	end

	managers.hud:show_suspicion()

	local suspicion_indicator_params = {
		unit = u_observer,
		suspect = suspect,
		position = icon_pos,
		state = initial_state
	}

	managers.hud:add_suspicion_indicator(obs_key, suspicion_indicator_params)

	return icon_pos
end

function GroupAIStateBase._create_hud_spotter_icon(obs_key, u_observer, u_suspect, icon_name, color, icon_id)
	local icon_pos = mvector3.copy(math.UP)

	mvector3.multiply(icon_pos, 28)
	mvector3.add(icon_pos, u_observer:movement() and u_observer:movement():m_head_pos() or u_observer:position())

	local suspect, timer = nil

	if u_suspect == managers.player:player_unit() or u_suspect == nil then
		suspect = "player"
		timer = 2
	else
		suspect = "teammate"
		timer = 0
	end

	local icon = managers.hud:add_waypoint(icon_id, {
		present_timer = 0,
		radius = 146,
		distance = false,
		state = "sneak_present",
		blend_mode = "add",
		no_sync = true,
		waypoint_type = "spotter",
		icon = icon_name,
		unit = u_observer,
		suspect = suspect,
		position = icon_pos,
		color = color
	})

	return icon_pos
end

function GroupAIStateBase:_sync_status(sync_status_code, u_suspect, u_observer)
	if Network:is_server() and managers.network:session() then
		managers.network:session():send_to_peers_synched("suspicion_hud", u_suspect, u_observer, sync_status_code, alive(u_suspect) and u_suspect:id() or 0)
	end
end

function GroupAIStateBase:_sync_spotter_detection(sync_status_code, u_suspect, u_observer)
	if Network:is_server() and managers.network:session() then
		managers.network:session():send_to_peers_synched("spotter_hud", u_suspect, u_observer, sync_status_code)
	end
end

function GroupAIStateBase:on_criminal_suspicion_progress(u_suspect, u_observer, status)
	local id = alive(u_suspect) and u_suspect:id()

	if not self._ai_enabled or not self._whisper_mode then
		return
	end

	if u_observer:brain() and u_observer:brain()._ignore_suspicion then
		return
	end

	local obs_key = u_observer:key()

	if managers.groupai:state():all_AI_criminals()[obs_key] then
		return
	end

	local susp_data = self._suspicion_hud_data
	local susp_key = u_suspect and u_suspect:key()
	local obs_susp_data = susp_data[obs_key]

	if status == "called" then
		self:_sync_status(4, u_suspect, u_observer)

		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			u_observer:unit_data().suspicion_icon_id = u_observer:id()
			local icon_pos = self._create_hud_suspicion_icon(u_observer:id(), u_observer, u_suspect, "wp_calling_in", tweak_data.hud.suspicion_color, icon_id, "calling")

			managers.hud:set_suspicion_indicator_state(u_observer:id(), "calling")

			obs_susp_data = {
				u_observer = u_observer,
				observer_id = u_observer:id(),
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:set_suspicion_indicator_state(obs_susp_data.u_observer:id(), "calling")
		managers.hud:hide_suspicion()

		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)

			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = "called"
		obs_susp_data.alerted = true
		obs_susp_data.expire_t = self._t + 6
		obs_susp_data.persistent = true
	elseif status == "calling" then
		self:_sync_status(3, u_suspect, u_observer)

		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			u_observer:unit_data().suspicion_icon_id = u_observer:id()
			local icon_pos = self._create_hud_suspicion_icon(u_observer:id(), u_observer, u_suspect, "wp_calling_in", tweak_data.hud.detected_color, icon_id, "calling")

			managers.hud:set_suspicion_indicator_state(u_observer:id(), "calling")

			obs_susp_data = {
				u_observer = u_observer,
				observer_id = u_observer:id(),
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:set_suspicion_indicator_state(obs_susp_data.u_observer:id(), "calling")

		obs_susp_data.status = "calling"
		obs_susp_data.alerted = true
	elseif status == true or status == "call_interrupted" then
		self:_sync_status(1, u_suspect, u_observer)
		self:_sync_status(2, u_suspect, u_observer)

		if obs_susp_data then
			if obs_susp_data.status == status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring(obs_key)
			u_observer:unit_data().suspicion_icon_id = u_observer:id()
			local icon_pos = self._create_hud_suspicion_icon(u_observer:id(), u_observer, u_suspect, "wp_detected", tweak_data.hud.detected_color, icon_id, "alarmed")
			obs_susp_data = {
				u_observer = u_observer,
				observer_id = u_observer:id(),
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		local s_id = alive(u_suspect) and u_suspect:id() or 0

		managers.hud:set_stealth_meter(u_observer:id(), s_id, 1)
		managers.hud:set_suspicion_indicator_progress(u_observer:id(), s_id, 1)

		obs_susp_data.status = status
		obs_susp_data.alerted = true
	elseif not status then
		self:_sync_status(0, u_suspect, u_observer)

		if obs_susp_data then
			local s_id = alive(u_suspect) and u_suspect:id() or 0

			managers.hud:set_stealth_meter(obs_susp_data.u_observer:id(), s_id, 0)

			if obs_susp_data.suspects and susp_key then
				obs_susp_data.suspects[susp_key] = nil

				if not next(obs_susp_data.suspects) then
					obs_susp_data.suspects = nil
				end
			end

			if not obs_susp_data.expire_t then
				obs_susp_data.expire_t = self._t + 3
			end

			if not susp_key or not obs_susp_data.alerted and (not obs_susp_data.suspects or not next(obs_susp_data.suspects)) then
				obs_susp_data.u_suspect = u_suspect
				obs_susp_data.u_observer = u_observer

				self:hide_aiming_icon(u_observer)
			end
		end
	else
		status = math.clamp(status, 0, 1)

		self:_sync_status(status, u_suspect, u_observer)

		if obs_susp_data then
			local s_id = alive(u_suspect) and u_suspect:id() or 0

			managers.hud:set_stealth_meter(obs_susp_data.u_observer:id(), s_id, status)
			managers.hud:set_suspicion_indicator_progress(obs_susp_data.u_observer:id(), s_id, status)

			obs_susp_data.expire_t = nil

			if obs_susp_data.alerted then
				Application:debug("[GroupAIStateBase:on_criminal_suspicion_progress] Already aleretd!")
			end
		elseif not obs_susp_data then
			local icon_id = "susp1" .. tostring(obs_key)
			u_observer:unit_data().suspicion_icon_id = u_observer:id()
			local icon_pos = self._create_hud_suspicion_icon(u_observer:id(), u_observer, u_suspect, "wp_suspicious", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				observer_id = u_observer:id(),
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		if susp_key then
			obs_susp_data.suspects = obs_susp_data.suspects or {}

			if obs_susp_data.suspects[susp_key] then
				obs_susp_data.suspects[susp_key].status = status
			else
				obs_susp_data.suspects[susp_key] = {
					status = status,
					u_suspect = u_suspect
				}
			end
		end
	end
end

function GroupAIStateBase:on_spotter_detection_progress(u_suspect, u_observer, status)
	return

	if false then
		self:_clear_character_criminal_suspicion_data(u_observer:key())

		return
	end

	local obs_key = u_observer:key()

	if managers.groupai:state():all_AI_criminals()[obs_key] then
		return
	end

	local susp_data = self._suspicion_hud_data
	local susp_key = u_suspect and u_suspect:key()
	local obs_susp_data = susp_data[obs_key]

	if status == "barrage" then
		if obs_susp_data and obs_susp_data.icon_id2 then
			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		local icon_id = "spotter1" .. tostring(obs_key)
		local icon_pos = self._create_hud_spotter_icon(obs_key, u_observer, u_suspect, "wp_spotter_barrage", tweak_data.hud.detected_color, icon_id)
		obs_susp_data = {
			u_observer = u_observer,
			observer_id = u_observer:id(),
			icon_id = icon_id,
			icon_pos = icon_pos
		}
		susp_data[obs_key] = obs_susp_data
		obs_susp_data.status = status
		obs_susp_data.alerted = true
		obs_susp_data.spotter = true

		self:_sync_spotter_detection(2, u_suspect, u_observer)
	elseif status == "empty" then
		if obs_susp_data then
			if obs_susp_data.status == status or obs_susp_data.status == "barrage" then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "spotter1" .. tostring(obs_key)
			local icon_pos = self._create_hud_spotter_icon(obs_key, u_observer, u_suspect, "wp_spotter_progress", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				observer_id = u_observer:id(),
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		if obs_susp_data.icon_id2 then
			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = status
		obs_susp_data.spotter = true

		self:show_aiming_icon(u_observer)
		self:_sync_spotter_detection(3, u_suspect, u_observer)
	elseif status == "remove" then
		self:_clear_character_criminal_suspicion_data(u_observer:key())
	else
		if obs_susp_data then
			if obs_susp_data.alerted then
				return
			end

			obs_susp_data.expire_t = nil

			self:_sync_spotter_detection(status, u_suspect, u_observer)
		elseif not obs_susp_data then
			local icon_id = "spotter1" .. tostring(obs_key)
			local icon_pos = self._create_hud_spotter_icon(obs_key, u_observer, u_suspect, "wp_spotter_progress", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				observer_id = u_observer:id(),
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data

			self:show_aiming_icon(u_observer)

			if obs_susp_data.icon_id2 then
				obs_susp_data.icon_id2 = nil
				obs_susp_data.icon_pos2 = nil
			end

			self:_sync_spotter_detection(status, u_suspect, u_observer)
		end

		obs_susp_data.spotter = true

		if susp_key then
			obs_susp_data.suspects = obs_susp_data.suspects or {}

			if obs_susp_data.suspects[susp_key] then
				obs_susp_data.suspects[susp_key].status = status
			else
				obs_susp_data.suspects[susp_key] = {
					status = status,
					u_suspect = u_suspect
				}
			end
		end
	end
end

function GroupAIStateBase:_upd_criminal_suspicion_progress()
	local susp_data = self._suspicion_hud_data

	if not next(susp_data) or not self._ai_enabled then
		return
	end

	for obs_key, obs_susp_data in pairs(susp_data) do
		if not alive(obs_susp_data.u_observer) then
			self:_clear_character_criminal_suspicion_data(obs_key)
		else
			if obs_susp_data.u_observer:movement() then
				mvector3.set(obs_susp_data.icon_pos, math.UP)
				mvector3.multiply(obs_susp_data.icon_pos, 28)
				mvector3.add(obs_susp_data.icon_pos, obs_susp_data.u_observer:movement():m_head_pos())

				if obs_susp_data.icon_pos2 then
					mvector3.set(obs_susp_data.icon_pos2, obs_susp_data.icon_pos)
				end
			end

			if obs_susp_data.status == "calling" and obs_susp_data.icon_pos2 then
				-- Nothing
			elseif obs_susp_data.expire_t and obs_susp_data.expire_t < self._t and not obs_susp_data.investigate then
				self:_clear_character_criminal_suspicion_data(obs_key)
			end
		end
	end
end

function GroupAIStateBase:_clear_criminal_suspicion_data()
	for obs_key, obs_susp_data in pairs(self._suspicion_hud_data) do
		if not obs_susp_data.persistent then
			managers.hud:remove_suspicion_indicator(obs_susp_data.observer_id)

			self._suspicion_hud_data[obs_key] = nil
		end
	end
end

function GroupAIStateBase:_clear_character_criminal_suspicion_data(obs_key)
	local obs_susp_data = self._suspicion_hud_data[obs_key]

	if not obs_susp_data then
		return
	end

	managers.hud:remove_suspicion_indicator(obs_susp_data.observer_id)

	self._suspicion_hud_data[obs_key] = nil

	if obs_susp_data.u_suspect then
		self:_sync_status(6, obs_susp_data.u_suspect, obs_susp_data.u_observer)
	end

	if obs_susp_data.spotter then
		self:_sync_spotter_detection(6, obs_susp_data.u_suspect, obs_susp_data.u_observer)
	end
end

function GroupAIStateBase:get_nr_successful_alarm_pager_bluffs()
	return self._nr_successful_alarm_pager_bluffs
end

function GroupAIStateBase:on_successful_alarm_pager_bluff()
	self._nr_successful_alarm_pager_bluffs = self._nr_successful_alarm_pager_bluffs + 1
end

function GroupAIStateBase:trim_coarse_path_to_areas(coarse_path)
	local all_areas = self._area_data
	local i = 1

	while #coarse_path >= 3 and i < #coarse_path do
		local node = coarse_path[i]
		local nav_seg = node[1]
		local area = self:get_area_from_nav_seg_id(nav_seg)
		local next_node = coarse_path[i + 1]
		local next_nav_seg = next_node[1]

		if area.nav_segs[next_nav_seg] then
			table.remove(coarse_path, i + 1)
		elseif i == #coarse_path - 1 then
			break
		else
			i = i + 1
		end
	end
end

function GroupAIStateBase:on_editor_sim_unit_spawned(unit)
	self._editor_sim_rem_units = self._editor_sim_rem_units or {}
	self._editor_sim_rem_units[unit:key()] = unit
end

function GroupAIStateBase:_get_balancing_multiplier(balance_multipliers)
	local nr_players = 0

	for u_key, u_data in pairs(self:all_player_criminals()) do
		if not u_data.status then
			nr_players = nr_players + 1
		end
	end

	nr_players = math.clamp(nr_players, 1, 4)

	return balance_multipliers[nr_players]
end

function GroupAIStateBase:draw_attention_objects_by_preset_name(wanted_preset_name)
	if wanted_preset_name then
		self._attention_debug_draw_data = {
			brush = Draw:brush(Color(0.5, 1, 0, 1), 0),
			wanted_preset_name = wanted_preset_name
		}
	else
		self._attention_debug_draw_data = nil
	end
end

function GroupAIStateBase:_upd_debug_draw_attentions()
	if not self._attention_debug_draw_data then
		return
	end

	for u_key, att_info in pairs(self._attention_objects.all) do
		local preset_data = att_info.handler._attention_data
		local wanted_data = preset_data and preset_data[self._attention_debug_draw_data.wanted_preset_name]

		if wanted_data then
			self._attention_debug_draw_data.brush:sphere(att_info.handler:get_attention_m_pos(), 30)
		end
	end

	self:_draw_enemy_importancies()
end

function GroupAIStateBase:show_aiming_icon(unit)
	return

	local obs_key = unit:key()
	local susp_data = self._suspicion_hud_data[obs_key]

	Application:debug("[GroupAIStateBase:show_aiming_icon]", susp_data)

	if susp_data then
		managers.hud:set_aiming_icon(susp_data.icon_id, true)
	end
end

function GroupAIStateBase:hide_aiming_icon(unit)
	return

	local obs_key = unit:key()
	local susp_data = self._suspicion_hud_data[obs_key]

	Application:debug("[GroupAIStateBase:hide_aiming_icon]", susp_data)

	if susp_data then
		managers.hud:set_aiming_icon(susp_data.icon_id, false)
		managers.dialog:queue_dialog("player_gen_not_spotted_sentry", {
			skip_idle_check = true,
			instigator = managers.player:local_player()
		})
	end
end

function GroupAIStateBase:show_investigate_icon(u_observer)
	return

	Application:debug("[GroupAIStateBase:show_investigate_icon]")

	local obs_key = u_observer:key()
	local obs_susp_data = self._suspicion_hud_data[obs_key]

	if not obs_susp_data then
		local icon_id = "susp1" .. tostring(obs_key)
		u_observer:unit_data().suspicion_icon_id = u_observer:id()
		local icon_pos = self._create_hud_suspicion_icon(u_observer:id(), u_observer, nil, "wp_suspicious", tweak_data.hud.suspicion_color, icon_id, "investigating")
		obs_susp_data = {
			u_observer = u_observer,
			observer_id = u_observer:id(),
			icon_id = icon_id,
			icon_pos = icon_pos
		}
		self._suspicion_hud_data[obs_key] = obs_susp_data

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_suspicious")
	end

	obs_susp_data.investigate = true

	managers.hud:set_investigate_icon(obs_susp_data.icon_id, true)
end

function GroupAIStateBase:hide_investigate_icon(unit)
	return

	Application:debug("[GroupAIStateBase:hide_investigate_icon]")

	local obs_key = unit:key()
	local obs_susp_data = self._suspicion_hud_data[obs_key]

	if obs_susp_data then
		obs_susp_data.investigate = false
		obs_susp_data.expire_t = self._t + 3

		managers.hud:set_investigate_icon(obs_susp_data.icon_id, false)
	end
end

function GroupAIStateBase:is_enemy_converted_to_criminal(unit)
	return self._converted_police[unit:key()]
end

function GroupAIStateBase:get_amount_enemies_converted_to_criminals()
	return self._converted_police and table.size(self._converted_police)
end

function GroupAIStateBase:all_converted_enemies()
	return self._converted_police
end

function GroupAIStateBase._get_group_acces_mask(group)
	local quadfield = managers.navigation._quad_field
	local union_mask = quadfield:convert_access_filter_to_number("0")

	for u_key, u_data in pairs(group.units) do
		local access_num = u_data.so_access
		union_mask = quadfield:access_filter_union(access_num, union_mask)
	end

	return union_mask
end

function GroupAIStateBase:on_hostage_follow(owner, follower, state)
	if state then
		local owner_data = self:criminal_record(owner:key())
		owner_data.following_hostages = owner_data.following_hostages or {}
		owner_data.following_hostages[follower:key()] = follower
		local follower_data = managers.enemy:all_civilians()[follower:key()]

		if follower_data then
			follower_data.hostage_following = owner
		end

		if Network:is_server() then
			local peer = managers.network:session():peer_by_unit(owner)

			if peer and peer:id() ~= managers.network:session():local_peer():id() then
				peer:send_queued_sync("sync_unit_event_id_16", follower, "base", 1)
			end
		end
	else
		local follower_data = managers.enemy:all_civilians()[follower:key()]
		owner = owner or follower_data and follower_data.hostage_following
		local owner_data = owner and self:criminal_record(owner:key())

		if owner_data and owner_data.following_hostages then
			owner_data.following_hostages[follower:key()] = nil

			if not next(owner_data.following_hostages) then
				owner_data.following_hostages = nil
			end
		end

		if follower_data then
			follower_data.hostage_following = nil
		end

		if owner and follower and Network:is_server() then
			local peer = managers.network:session():peer_by_unit(owner)

			if peer and peer:id() ~= managers.network:session():local_peer():id() then
				peer:send_queued_sync("sync_unit_event_id_16", follower, "base", 2)
			end
		end
	end
end

function GroupAIStateBase:get_following_hostages(owner)
	local owner_data = self:criminal_record(owner:key())

	if not owner_data then
		return
	end

	return owner_data.following_hostages
end

function GroupAIStateBase:register_usable_turret(unit)
	self._usable_turret_units = self._usable_turret_units or {}

	table.insert(self._usable_turret_units, unit)
end

function GroupAIStateBase:get_usable_turrets()
	return self._usable_turret_units
end

function GroupAIStateBase:register_turret(unit)
	self._turret_units = self._turret_units or {}

	table.insert(self._turret_units, unit)
end

function GroupAIStateBase:unregister_turret(unit)
	if not self._turret_units then
		return
	end

	for id, turret_unit in pairs(self._turret_units) do
		if turret_unit:key() == unit:key() then
			self._turret_units[id] = nil

			return
		end
	end
end

function GroupAIStateBase:turrets()
	return self._turret_units
end

function GroupAIStateBase:phalanx_minions()
	return self._phalanx_data.minions
end

function GroupAIStateBase:phalanx_vip()
	return self._phalanx_data.vip
end

function GroupAIStateBase:get_phalanx_minion_count()
	return table.size(self._phalanx_data.minions or {})
end

function GroupAIStateBase:register_phalanx_minion(unit)
	self._phalanx_data.minions[unit:key()] = unit
end

function GroupAIStateBase:register_phalanx_vip(unit)
	self._phalanx_data.vip = unit
end

function GroupAIStateBase:unregister_phalanx_minion(unit_key)
	self._phalanx_data.minions[unit_key] = nil
end

function GroupAIStateBase:unregister_phalanx_vip()
	self._phalanx_data.vip = nil
end

function GroupAIStateBase:is_unit_in_phalanx_minion_data(unit_key)
	return self._phalanx_data and self._phalanx_data.minions and self._phalanx_data.minions[unit_key] and true
end
