require("lib/units/enemies/cop/logics/CopLogicBase")
require("lib/units/enemies/cop/logics/CopLogicInactive")
require("lib/units/enemies/cop/logics/CopLogicIdle")
require("lib/units/enemies/cop/logics/CopLogicAttack")
require("lib/units/enemies/cop/logics/CopLogicIntimidated")
require("lib/units/enemies/cop/logics/CopLogicTravel")
require("lib/units/enemies/cop/logics/CopLogicFlee")
require("lib/units/enemies/cop/logics/CopLogicSniper")
require("lib/units/enemies/cop/logics/CopLogicSpotter")
require("lib/units/enemies/cop/logics/CopLogicTrade")
require("lib/units/enemies/cop/logics/CopLogicPhalanxMinion")
require("lib/units/enemies/cop/logics/CopLogicPhalanxVip")
require("lib/units/enemies/cop/logics/CopLogicTurret")
require("lib/units/enemies/cop/logics/CopLogicAlarm")
require("lib/units/enemies/tank/logics/TankCopLogicAttack")
require("lib/units/enemies/shield/logics/ShieldLogicAttack")
require("lib/units/enemies/flamer/logics/FlamerLogicAttack")

CopBrain = CopBrain or class()
local logic_variants = {
	security = {
		idle = CopLogicIdle,
		attack = CopLogicAttack,
		travel = CopLogicTravel,
		inactive = CopLogicInactive,
		intimidated = CopLogicIntimidated,
		flee = CopLogicFlee,
		sniper = CopLogicSniper,
		spotter = CopLogicSpotter,
		trade = CopLogicTrade,
		phalanx = CopLogicPhalanxMinion,
		turret = CopLogicTurret,
		alarm = CopLogicAlarm
	}
}
local security_variant = logic_variants.security
logic_variants.gensec = security_variant
logic_variants.cop = security_variant
logic_variants.fbi = security_variant
logic_variants.swat = security_variant
logic_variants.heavy_swat = security_variant
logic_variants.fbi_swat = security_variant
logic_variants.fbi_heavy_swat = security_variant
logic_variants.nathan = security_variant
logic_variants.sniper = security_variant
logic_variants.spotter = security_variant
logic_variants.gangster = security_variant
logic_variants.biker = security_variant
logic_variants.mobster = security_variant
logic_variants.mobster_boss = security_variant
logic_variants.hector_boss = security_variant
logic_variants.hector_boss_no_armor = security_variant
logic_variants.dealer = security_variant
logic_variants.biker_escape = security_variant
logic_variants.city_swat = security_variant
logic_variants.old_hoxton_mission = security_variant
logic_variants.inside_man = security_variant
logic_variants.german_officer = security_variant
logic_variants.german_grunt_light = security_variant
logic_variants.german_grunt_light_mp38 = security_variant
logic_variants.german_grunt_light_kar98 = security_variant
logic_variants.german_grunt_light_shotgun = security_variant
logic_variants.german_grunt_mid = security_variant
logic_variants.german_grunt_mid_mp38 = security_variant
logic_variants.german_grunt_mid_kar98 = security_variant
logic_variants.german_grunt_mid_shotgun = security_variant
logic_variants.german_grunt_heavy = security_variant
logic_variants.german_grunt_heavy_mp38 = security_variant
logic_variants.german_grunt_heavy_kar98 = security_variant
logic_variants.german_grunt_heavy_shotgun = security_variant
logic_variants.german_light = security_variant
logic_variants.german_light_kar98 = security_variant
logic_variants.german_light_shotgun = security_variant
logic_variants.german_heavy = security_variant
logic_variants.german_heavy_kar98 = security_variant
logic_variants.german_heavy_shotgun = security_variant
logic_variants.german_gasmask = security_variant
logic_variants.german_gasmask_shotgun = security_variant
logic_variants.german_gasmask_commander_backup = security_variant
logic_variants.german_gasmask_commander_backup_shotgun = security_variant
logic_variants.german_light_commander_backup = security_variant
logic_variants.german_light_commander_backup_kar98 = security_variant
logic_variants.german_light_commander_backup_shotgun = security_variant
logic_variants.german_heavy_commander_backup = security_variant
logic_variants.german_heavy_commander_backup_kar98 = security_variant
logic_variants.german_heavy_commander_backup_shotgun = security_variant
logic_variants.german_fallschirmjager_light = security_variant
logic_variants.german_fallschirmjager_light_kar98 = security_variant
logic_variants.german_fallschirmjager_light_shotgun = security_variant
logic_variants.german_fallschirmjager_light_mp38 = security_variant
logic_variants.german_fallschirmjager_heavy = security_variant
logic_variants.german_fallschirmjager_heavy_kar98 = security_variant
logic_variants.german_fallschirmjager_heavy_shotgun = security_variant
logic_variants.german_fallschirmjager_heavy_mp38 = security_variant
logic_variants.german_waffen_ss = security_variant
logic_variants.german_waffen_ss_kar98 = security_variant
logic_variants.german_waffen_ss_shotgun = security_variant
logic_variants.german_gebirgsjager_light = security_variant
logic_variants.german_gebirgsjager_light_kar98 = security_variant
logic_variants.german_gebirgsjager_light_shotgun = security_variant
logic_variants.german_gebirgsjager_light_mp38 = security_variant
logic_variants.german_gebirgsjager_heavy = security_variant
logic_variants.german_gebirgsjager_heavy_kar98 = security_variant
logic_variants.german_gebirgsjager_heavy_shotgun = security_variant
logic_variants.german_gebirgsjager_heavy_mp38 = security_variant
logic_variants.german_sniper = security_variant
logic_variants.german_spotter = security_variant
logic_variants.soviet_nkvd_int_security_captain = security_variant
logic_variants.soviet_nkvd_int_security_captain_b = security_variant

for _, tweak_table_name in pairs({
	"shield",
	"tank",
	"taser",
	"german_flamer",
	"german_commander",
	"german_og_commander"
}) do
	logic_variants[tweak_table_name] = clone(security_variant)
end

logic_variants.german_commander.intimidated = nil
logic_variants.german_commander.flee = nil
logic_variants.german_og_commander.intimidated = nil
logic_variants.german_og_commander.flee = nil
logic_variants.shield.attack = ShieldLogicAttack
logic_variants.shield.intimidated = nil
logic_variants.shield.flee = nil
logic_variants.german_flamer.attack = FlamerLogicAttack
logic_variants.german_flamer.intimidated = nil
logic_variants.german_flamer.flee = nil
logic_variants.phalanx_minion = clone(logic_variants.shield)
logic_variants.phalanx_vip = clone(logic_variants.shield)
logic_variants.phalanx_vip.phalanx = CopLogicPhalanxVip
logic_variants.tank.attack = TankCopLogicAttack
logic_variants.tank_hw = logic_variants.tank
logic_variants.fb_german_commander_boss = security_variant
logic_variants.fb_german_commander_boss.intimidated = nil
logic_variants.fb_german_commander_boss.flee = nil
logic_variants.fb_german_commander = security_variant
logic_variants.fb_german_commander.intimidated = nil
logic_variants.fb_german_commander.flee = nil
security_variant = nil
CopBrain._logic_variants = logic_variants
logic_varaints = nil
local reload = nil

if CopBrain._reload_clbks then
	reload = true
else
	CopBrain._reload_clbks = {}
end

function CopBrain:init(unit)
	self._unit = unit
	self._timer = TimerManager:game()

	self:set_update_enabled_state(false)

	self._current_logic = nil
	self._current_logic_name = nil
	self._active = true
	local tweak_table = unit:base()._tweak_table
	local access = tweak_data.character[tweak_table].access
	self._SO_access = managers.navigation:convert_access_flag(access)
	self._slotmask_enemies = managers.slot:get_mask("criminals")
	self._reload_clbks[unit:key()] = callback(self, self, "on_reload")
	self.random_travel_applied = false
end

function CopBrain:post_init()
	self._logics = CopBrain._logic_variants[self._unit:base()._tweak_table]

	self:_reset_logic_data()

	local my_key = tostring(self._unit:key())

	self._unit:character_damage():add_listener("CopBrain_hurt" .. my_key, {
		"dmg_rcv",
		"hurt",
		"light_hurt",
		"heavy_hurt",
		"hurt_sick",
		"shield_knock",
		"counter_tased",
		"taser_tased"
	}, callback(self, self, "clbk_damage"))
	self._unit:character_damage():add_listener("CopBrain_death" .. my_key, {
		"death"
	}, callback(self, self, "clbk_death"))
	self:_setup_attention_handler()

	if not self._current_logic then
		self:set_init_logic("idle")
	end

	if Network:is_server() then
		self:add_pos_rsrv("stand", {
			radius = 30,
			position = mvector3.copy(self._unit:movement():m_pos())
		})

		if not managers.groupai:state():enemy_weapons_hot() then
			self._enemy_weapons_hot_listen_id = "CopBrain" .. my_key

			managers.groupai:state():add_listener(self._enemy_weapons_hot_listen_id, {
				"enemy_weapons_hot"
			}, callback(self, self, "clbk_enemy_weapons_hot"))
		end
	end

	if not self._unit:contour() then
		debug_pause_unit(self._unit, "[CopBrain:post_init] character missing contour extension", self._unit)
	end
end

function CopBrain:set_logic_queued(data)
	if alive(self._unit) and not self._unit:brain().dead then
		self:set_logic(data.state_name, data.params)
	end

	self.logic_queued_key = nil
end

function CopBrain:update(unit, t, dt)
	if managers.network:session() and (managers.network:session():local_peer():loading() or managers.network:session():closing()) then
		return
	end

	if managers.game_play_central:is_restarting() then
		return
	end

	local logic = self._current_logic

	if logic.update then
		local l_data = self._logic_data
		l_data.t = t
		l_data.dt = dt

		logic.update(l_data)
	end
end

function CopBrain:set_update_enabled_state(state)
	self._unit:set_extension_update_enabled(Idstring("brain"), state)
end

function CopBrain:set_spawn_ai(spawn_ai)
	self._spawn_ai = spawn_ai

	self:set_update_enabled_state(true)

	if spawn_ai.init_state then
		self:set_logic(spawn_ai.init_state, spawn_ai.params)
	end

	if spawn_ai.stance then
		self._unit:movement():set_stance(spawn_ai.stance)
	end

	if spawn_ai.objective then
		self:set_objective(spawn_ai.objective)
	end
end

function CopBrain:set_spawn_entry(spawn_entry, tactics_map)
	self._logic_data.tactics = tactics_map
	self._logic_data.rank = spawn_entry.rank
end

function CopBrain:set_tactic(new_tactic_info)
	local old_tactic = self._logic_data.tactic
	self._logic_data.tactic = new_tactic_info

	if self._current_logic.on_new_tactic then
		self._current_logic.on_new_tactic(self._logic_data, old_tactic)
	end
end

function CopBrain:set_objective(new_objective)
	local old_objective = self._logic_data.objective
	self._logic_data.objective = new_objective

	if new_objective and new_objective.followup_objective and new_objective.followup_objective.interaction_voice then
		self._unit:network():send("set_interaction_voice", new_objective.followup_objective.interaction_voice)
	elseif old_objective and old_objective.followup_objective and old_objective.followup_objective.interaction_voice then
		self._unit:network():send("set_interaction_voice", "")
	end

	self._current_logic.on_new_objective(self._logic_data, old_objective)
end

function CopBrain:set_followup_objective(followup_objective)
	local old_followup = self._logic_data.objective.followup_objective
	self._logic_data.objective.followup_objective = followup_objective

	if followup_objective and followup_objective.interaction_voice then
		self._unit:network():send("set_interaction_voice", followup_objective.interaction_voice)
	elseif old_followup and old_followup.interaction_voice then
		self._unit:network():send("set_interaction_voice", "")
	end
end

function CopBrain:save(save_data)
	local my_save_data = {}

	if self._logic_data.objective and self._logic_data.objective.followup_objective and self._logic_data.objective.followup_objective.interaction_voice then
		my_save_data.interaction_voice = self._logic_data.objective.followup_objective.interaction_voice
	else
		my_save_data.interaction_voice = nil
	end

	if self._logic_data.internal_data.weapon_laser_on then
		my_save_data.weapon_laser_on = true
	end

	if self._logic_data.internal_data.weapon_laser_on then
		my_save_data.weapon_laser_on = true
	end

	if self._logic_data.name == "trade" and self._logic_data.internal_data.fleeing then
		my_save_data.trade_flee_contour = true
	end

	my_save_data.team_id = self._logic_data.team.id
	save_data.brain = my_save_data
end

function CopBrain:objective()
	return self._logic_data.objective
end

function CopBrain:is_hostage()
	return self._logic_data.internal_data and self._logic_data.internal_data.is_hostage
end

function CopBrain:is_available_for_assignment(objective)
	return self._current_logic.is_available_for_assignment(self._logic_data, objective)
end

function CopBrain:_reset_logic_data()
	self._logic_data = {
		unit = self._unit,
		brain = self,
		active_searches = {},
		m_pos = self._unit:movement():m_pos(),
		char_tweak = tweak_data.character[self._unit:base()._tweak_table],
		key = self._unit:key(),
		pos_rsrv = {},
		pos_rsrv_id = self._unit:movement():pos_rsrv_id(),
		SO_access = self._SO_access,
		SO_access_str = tweak_data.character[self._unit:base()._tweak_table].access,
		detected_attention_objects = {},
		attention_handler = self._attention_handler,
		visibility_slotmask = managers.slot:get_mask("AI_visibility"),
		enemy_slotmask = self._slotmask_enemies,
		cool = self._unit:movement():cool(),
		objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_objective_complete"),
		objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_objective_failed")
	}

	if Application:production_build() then
		self._logic_data.debug_name = self._unit:name()
	end
end

function CopBrain:set_init_logic(name, enter_params)
	local logic = self._logics[name]
	local l_data = self._logic_data
	l_data.t = self._timer:time()
	l_data.dt = self._timer:delta_time()
	l_data.name = name
	l_data.logic = logic
	self._current_logic = logic
	self._current_logic_name = name

	logic.enter(l_data, name, enter_params)
end

function CopBrain:set_logic(name, enter_params)
	local logic = self._logics[name]
	local l_data = self._logic_data
	l_data.t = self._timer:time()
	l_data.dt = self._timer:delta_time()

	self._current_logic.exit(l_data, name, enter_params)

	l_data.name = name
	l_data.logic = logic
	self._current_logic = logic
	self._current_logic_name = name

	logic.enter(l_data, name, enter_params)
end

function CopBrain:get_logic_by_name(name)
	return self._logics[name]
end

function CopBrain:search_for_path_to_unit(search_id, other_unit, access_neg)
	local enemy_tracker = other_unit:movement():nav_tracker()
	local pos_to = enemy_tracker:field_position()
	local params = {
		tracker_from = self._unit:movement():nav_tracker(),
		tracker_to = enemy_tracker,
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		access_pos = self._SO_access,
		access_neg = access_neg
	}
	self._logic_data.active_searches[search_id] = true

	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_path(search_id, to_pos, prio, access_neg, nav_segs)
	local params = {
		tracker_from = self._unit:movement():nav_tracker(),
		pos_to = to_pos,
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		prio = prio,
		access_pos = self._SO_access,
		access_neg = access_neg,
		nav_segs = nav_segs
	}
	self._logic_data.active_searches[search_id] = true

	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_path_from_pos(search_id, from_pos, to_pos, prio, access_neg, nav_segs)
	local params = {
		pos_from = from_pos,
		pos_to = to_pos,
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		prio = prio,
		access_pos = self._SO_access,
		access_neg = access_neg,
		nav_segs = nav_segs
	}
	self._logic_data.active_searches[search_id] = true

	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_path_to_cover(search_id, cover, offset_pos, access_neg)
	local params = {
		tracker_from = self._unit:movement():nav_tracker(),
		tracker_to = cover[NavigationManager.COVER_TRACKER],
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		access_pos = self._SO_access,
		access_neg = access_neg
	}
	self._logic_data.active_searches[search_id] = true

	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_coarse_path(search_id, to_seg, verify_clbk, access_neg)
	local params = {
		from_tracker = self._unit:movement():nav_tracker(),
		to_seg = to_seg,
		access = {
			"walk"
		},
		id = search_id,
		results_clbk = callback(self, self, "clbk_coarse_pathing_results", search_id),
		verify_clbk = verify_clbk,
		access_pos = self._logic_data.char_tweak.access,
		access_neg = access_neg
	}
	self._logic_data.active_searches[search_id] = 2

	managers.navigation:search_coarse(params)

	return true
end

function CopBrain:action_request(new_action_data)
	return self._unit:movement():action_request(new_action_data)
end

function CopBrain:on_action_completed(action)
	self._current_logic.on_action_completed(self._logic_data, action)
end

function CopBrain:clbk_coarse_pathing_results(search_id, path)
	self:_add_pathing_result(search_id, path)
end

function CopBrain:clbk_pathing_results(search_id, path)
	self:_add_pathing_result(search_id, path)

	if path then
		local t = nil

		for i, nav_point in ipairs(path) do
			if not nav_point.x and nav_point:script_data().element:nav_link_delay() > 0 then
				t = t or TimerManager:game():time()

				nav_point:set_delay_time(t + nav_point:script_data().element:nav_link_delay())
			end
		end
	end
end

function CopBrain:_add_pathing_result(search_id, path)
	self._logic_data.active_searches[search_id] = nil
	self._logic_data.pathing_results = self._logic_data.pathing_results or {}
	self._logic_data.pathing_results[search_id] = path or "failed"
end

function CopBrain:cancel_all_pathing_searches()
	for search_id, search_type in pairs(self._logic_data.active_searches) do
		if search_type == 2 then
			managers.navigation:cancel_coarse_search(search_id)
		else
			managers.navigation:cancel_pathing_search(search_id)
		end
	end

	self._logic_data.active_searches = {}
	self._logic_data.pathing_results = nil
end

function CopBrain:abort_detailed_pathing(search_id)
	if self._logic_data.active_searches[search_id] then
		self._logic_data.active_searches[search_id] = nil

		managers.navigation:cancel_pathing_search(search_id)
	end
end

function CopBrain:clbk_damage(my_unit, damage_info)
	if damage_info.attacker_unit and damage_info.attacker_unit:in_slot(self._slotmask_enemies) then
		self._current_logic.damage_clbk(self._logic_data, damage_info)
	end
end

function CopBrain:clbk_death(my_unit, damage_info)
	self._current_logic.death_clbk(self._logic_data, damage_info)

	self.dead = true

	if self.logic_queued_key then
		self.logic_queued_key = nil

		managers.queued_tasks:unqueue(self.logic_queued_key)
	end

	self:set_active(false)

	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)

		self._alert_listen_key = nil
	end

	self:_chk_enable_bodybag_interaction()

	if self._following_hostage_contour_id then
		self._unit:contour():remove_by_id(self._following_hostage_contour_id, true)

		self._following_hostage_contour_id = nil
	end
end

function CopBrain:is_active()
	return self._active
end

function CopBrain:set_active(state)
	self._active = state

	if state then
		self:set_logic("idle")
	elseif self._current_logic_name ~= "inactive" then
		if self._logic_data.is_converted then
			self._attention_handler:override_attention("enemy_team_cbt", nil)
		end

		self:set_logic("inactive")
	end
end

function CopBrain:cancel_trade()
	if not self._active then
		return
	end

	if self._logic_data.is_converted then
		local action_data = {
			body_part = 4,
			type = "stand"
		}

		self:action_request(action_data)
		self:set_objective(nil)
		self:set_logic("idle")
	else
		self:set_logic("intimidated")
	end
end

function CopBrain:interaction_voice()
	if self._logic_data.objective and self._logic_data.objective.followup_objective and self._logic_data.objective.followup_objective.trigger_on == "interact" and (not self._logic_data.objective or not self._logic_data.objective.nav_seg or not not self._logic_data.objective.in_place) and not self._unit:anim_data().unintimidateable then
		return self._logic_data.objective.followup_objective.interaction_voice
	end
end

function CopBrain:on_intimidated(amount, aggressor_unit)
	local interaction_voice = self:interaction_voice()

	if interaction_voice then
		self:set_objective(self._logic_data.objective.followup_objective)

		return interaction_voice
	else
		self._current_logic.on_intimidated(self._logic_data, amount, aggressor_unit)
	end
end

function CopBrain:on_tied(aggressor_unit, not_tied)
	return self._current_logic.on_tied(self._logic_data, aggressor_unit, not_tied)
end

function CopBrain:on_trade(aggressor_unit)
	return self._current_logic.on_trade(self._logic_data, aggressor_unit)
end

function CopBrain:on_detected_enemy_destroyed(destroyed_unit)
	self._current_logic.on_detected_enemy_destroyed(self._logic_data, destroyed_unit)
end

function CopBrain:on_detected_attention_obj_modified(modified_u_key)
	self._current_logic.on_detected_attention_obj_modified(self._logic_data, modified_u_key)
end

function CopBrain:on_criminal_neutralized(criminal_key)
	self._current_logic.on_criminal_neutralized(self._logic_data, criminal_key)
end

function CopBrain:on_alert(alert_data)
	if alert_data[5] == self._unit then
		return
	end

	self._current_logic.on_alert(self._logic_data, alert_data)
end

function CopBrain:filter_area_unsafe(nav_seg)
	return not managers.groupai:state():is_nav_seg_safe(nav_seg)
end

function CopBrain:on_area_safety(...)
	self._current_logic.on_area_safety(self._logic_data, ...)
end

function CopBrain:draw_reserved_positions()
	self._current_logic.draw_reserved_positions(self._logic_data)
end

function CopBrain:draw_reserved_covers()
	self._current_logic.draw_reserved_covers(self._logic_data)
end

function CopBrain:set_important(state)
	self._important = state
	self._logic_data.important = state

	self._current_logic.on_importance(self._logic_data)
end

function CopBrain:is_important()
	return self._important
end

function CopBrain:on_reload()
	self._logic_data.char_tweak = tweak_data.character[self._unit:base()._tweak_table]
	self._logics = CopBrain._logic_variants[self._unit:base()._tweak_table]
	self._current_logic = self._logics[self._current_logic_name]
	self._logic_data.char_tweak = tweak_data.character[self._unit:base()._tweak_table]
end

function CopBrain:on_rescue_allowed_state(state)
	if self._current_logic.on_rescue_allowed_state then
		self._current_logic.on_rescue_allowed_state(self._logic_data, state)
	end
end

function CopBrain:on_objective_unit_destroyed(unit)
	return self._current_logic.on_objective_unit_destroyed(self._logic_data, unit)
end

function CopBrain:on_objective_unit_damaged(unit, damage_info)
	if unit:character_damage().dead and unit:character_damage():dead() then
		return self._current_logic.on_objective_unit_damaged(self._logic_data, unit, damage_info.attacker_unit)
	end
end

function CopBrain:is_advancing()
	return self._current_logic.is_advancing(self._logic_data)
end

function CopBrain:anim_clbk(unit, ...)
	self._current_logic.anim_clbk(self._logic_data, ...)
end

function CopBrain:anim_clbk_dodge_cover_grenade(unit)
	self:_chk_use_cover_grenade(unit)
end

function CopBrain:_chk_use_cover_grenade(unit)
	if not Network:is_server() or not self._logic_data.char_tweak.dodge_with_grenade or not self._logic_data.attention_obj then
		return
	end

	local check_f = self._logic_data.char_tweak.dodge_with_grenade.check
	local t = TimerManager:game():time()

	if check_f and (not self._flashbang_cover_expire_t or self._next_cover_grenade_chk_t < t) then
		local result, next_t = check_f(t, self._nr_flashbang_covers_used or 0)
		self._next_cover_grenade_chk_t = next_t

		if not result then
			return
		end
	end

	local grenade_was_used = nil

	if self._logic_data.attention_obj.dis > 1000 or not self._logic_data.char_tweak.dodge_with_grenade.flash then
		if self._logic_data.char_tweak.dodge_with_grenade.smoke and not managers.groupai:state():is_smoke_grenade_active() then
			local duration = self._logic_data.char_tweak.dodge_with_grenade.smoke.duration

			managers.groupai:state():detonate_smoke_grenade(self._logic_data.m_pos + math.UP * 10, self._unit:movement():m_head_pos(), math.lerp(duration[1], duration[2], math.random()), false)

			grenade_was_used = true
		end
	elseif self._logic_data.char_tweak.dodge_with_grenade.flash then
		local duration = self._logic_data.char_tweak.dodge_with_grenade.flash.duration

		managers.groupai:state():detonate_smoke_grenade(self._logic_data.m_pos + math.UP * 10, self._unit:movement():m_head_pos(), math.lerp(duration[1], duration[2], math.random()), true)

		grenade_was_used = true
	end

	if grenade_was_used then
		self._nr_flashbang_covers_used = (self._nr_flashbang_covers_used or 0) + 1
	end
end

function CopBrain:on_nav_link_unregistered(element_id)
	if self._logic_data.pathing_results then
		local failed_search_ids = nil

		for path_name, path in pairs(self._logic_data.pathing_results) do
			if type(path) == "table" and path[1] and type(path[1]) ~= "table" then
				for i, nav_point in ipairs(path) do
					if not nav_point.x and nav_point:script_data().element._id == element_id then
						failed_search_ids = failed_search_ids or {}
						failed_search_ids[path_name] = true

						break
					end
				end
			end
		end

		if failed_search_ids then
			for search_id, _ in pairs(failed_search_ids) do
				self._logic_data.pathing_results[search_id] = "failed"
			end
		end
	end

	local paths = self._current_logic._get_all_paths and self._current_logic._get_all_paths(self._logic_data)

	if not paths then
		return
	end

	local verified_paths = {}

	for path_name, path in pairs(paths) do
		local path_is_ok = true

		for i, nav_point in ipairs(path) do
			if not nav_point.x and nav_point:script_data().element._id == element_id then
				path_is_ok = false

				break
			end
		end

		if path_is_ok then
			verified_paths[path_name] = path
		end
	end

	self._current_logic._set_verified_paths(self._logic_data, verified_paths)
end

function CopBrain:SO_access()
	return self._SO_access
end

function CopBrain:_setup_attention_handler()
	self._attention_handler = CharacterAttentionObject:new(self._unit)
end

function CopBrain:attention_handler()
	return self._attention_handler
end

function CopBrain:set_attention_settings(params)
	local att_settings = nil

	if params then
		if params.peaceful then
			att_settings = {
				"enemy_team_idle"
			}
		elseif params.cbt then
			if managers.groupai:state():enemy_weapons_hot() then
				att_settings = {
					"enemy_team_cbt"
				}
			else
				att_settings = {
					"enemy_team_cbt",
					"enemy_enemy_cbt",
					"enemy_civ_cbt"
				}
			end
		elseif params.corpse_cbt then
			att_settings = {
				"enemy_combatant_corpse_cbt"
			}

			Application:debug("[CopBrain:set_attention_settings] CORPSE'D: corpse_cbt mode")
		elseif params.corpse_sneak then
			att_settings = {
				"enemy_law_corpse_sneak",
				"enemy_team_corpse_sneak",
				"enemy_civ_cbt"
			}

			Application:debug("[CopBrain:set_attention_settings] CORPSE'D: corpse_sneak mode")
		end
	end

	PlayerMovement.set_attention_settings(self, att_settings)
end

function CopBrain:_create_attention_setting_from_descriptor(setting_desc, setting_name)
	return PlayerMovement._create_attention_setting_from_descriptor(self, setting_desc, setting_name)
end

function CopBrain:clbk_attention_notice_corpse(observer_unit, status)
end

function CopBrain:on_cool_state_changed(state)
	if self._logic_data then
		self._logic_data.cool = state
	end

	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)
	else
		self._alert_listen_key = "CopBrain" .. tostring(self._unit:key())
	end

	local alert_listen_filter, alert_types = nil

	if state then
		alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminals_enemies_civilians")
		alert_types = {
			vo_distress = true,
			vo_intimidate = true,
			vo_cbt = true,
			bullet = true,
			footstep = true,
			fire = true,
			explosion = true,
			aggression = true
		}

		if self._logic_data and self._logic_data.internal_data.vision_cool then
			self._logic_data.internal_data.vision = self._logic_data.internal_data.vision_cool
		end

		self:_chk_enable_pickpocket_interaction()
	else
		alert_listen_filter = managers.groupai:state():get_unit_type_filter("criminal")
		alert_types = {
			aggression = true,
			fire = true,
			explosion = true,
			bullet = true
		}

		if self._logic_data then
			self:terminate_all_suspicion()

			if self._logic_data.internal_data.vision_not_cool then
				self._logic_data.internal_data.vision = self._logic_data.internal_data.vision_not_cool
			end
		end

		self:_chk_disable_pickpocket_interaction()
	end

	managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, alert_types, self._unit:movement():m_head_pos())
end

function CopBrain:on_suppressed(state)
	self._logic_data.is_suppressed = state or nil

	if self._current_logic.on_suppressed_state then
		self._current_logic.on_suppressed_state(self._logic_data)

		if state and self._logic_data.char_tweak.chatter.suppress and not self._unit:sound():speaking() then
			self._unit:sound():say("help", true)
		end
	end
end

function CopBrain:attention_objects()
	if self._logic_data.attention_obj then
		-- Nothing
	end

	for u_key, attention_data in pairs(self._logic_data.detected_attention_objects) do
		if self._logic_data.attention_obj ~= attention_data then
			-- Nothing
		end
	end
end

function CopBrain:clbk_enemy_weapons_hot()
	managers.groupai:state():remove_listener(self._enemy_weapons_hot_listen_id)

	self._enemy_weapons_hot_listen_id = nil

	if self._logic_data.logic.on_enemy_weapons_hot then
		self._logic_data.logic.on_enemy_weapons_hot(self._logic_data)
	end
end

function CopBrain:set_group(group)
	self._logic_data.group = group
end

function CopBrain:on_team_set(team_data)
	self._logic_data.team = team_data

	self._attention_handler:set_team(team_data)
end

function CopBrain:on_new_group_objective(objective)
	if self._current_logic.on_new_group_objective then
		self._current_logic.on_new_group_objective(self._logic_data, objective)
	end
end

function CopBrain:clbk_group_member_attention_identified(member_unit, attention_u_key)
	self._current_logic.identify_attention_obj_instant(self._logic_data, attention_u_key)
end

function CopBrain:convert_to_criminal(mastermind_criminal)
	self._logic_data.is_converted = true
	self._logic_data.group = nil
	local mover_col_body = self._unit:movement():get_mover_blocker()

	if mover_col_body then
		mover_col_body:set_enabled(false)
	end

	local attention_preset = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data.attention.settings.team_enemy_cbt, "team_enemy_cbt")

	self._attention_handler:override_attention("enemy_team_cbt", attention_preset)

	local health_multiplier = 1
	local damage_multiplier = 1

	if alive(mastermind_criminal) then
		health_multiplier = health_multiplier * (mastermind_criminal:base():upgrade_value("player", "convert_enemies_health_multiplier") or 1)
		health_multiplier = health_multiplier * (mastermind_criminal:base():upgrade_value("player", "passive_convert_enemies_health_multiplier") or 1)
		damage_multiplier = damage_multiplier * (mastermind_criminal:base():upgrade_value("player", "convert_enemies_damage_multiplier") or 1)
		damage_multiplier = damage_multiplier * (mastermind_criminal:base():upgrade_value("player", "passive_convert_enemies_damage_multiplier") or 1)
	else
		health_multiplier = health_multiplier * managers.player:upgrade_value("player", "convert_enemies_health_multiplier", 1)
		health_multiplier = health_multiplier * managers.player:upgrade_value("player", "passive_convert_enemies_health_multiplier", 1)
		damage_multiplier = damage_multiplier * managers.player:upgrade_value("player", "convert_enemies_damage_multiplier", 1)
		damage_multiplier = damage_multiplier * managers.player:upgrade_value("player", "passive_convert_enemies_damage_multiplier", 1)
	end

	self._unit:character_damage():convert_to_criminal(health_multiplier)

	self._logic_data.attention_obj = nil

	CopLogicBase._destroy_all_detected_attention_object_data(self._logic_data)

	self._SO_access = managers.navigation:convert_access_flag(tweak_data.character.russian.access)
	self._logic_data.SO_access = self._SO_access
	self._logic_data.SO_access_str = tweak_data.character.russian.access
	self._slotmask_enemies = managers.slot:get_mask("enemies")
	self._logic_data.enemy_slotmask = self._slotmask_enemies
	local equipped_w_selection = self._unit:inventory():equipped_selection()

	if equipped_w_selection then
		self._unit:inventory():remove_selection(equipped_w_selection, true)
	end

	local weap_name = self._unit:base():default_weapon_name()

	TeamAIInventory.add_unit_by_name(self._unit:inventory(), weap_name, true)

	local weapon_unit = self._unit:inventory():equipped_unit()

	weapon_unit:base():add_damage_multiplier(damage_multiplier)
	self:set_objective(nil)
	self:set_logic("idle", nil)

	self._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
	self._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")

	managers.groupai:state():on_criminal_jobless(self._unit)
	self._unit:base():set_slot(self._unit, 16)
	self._unit:movement():set_stance("hos")

	local action_data = {
		clamp_to_graph = true,
		body_part = 1,
		type = "act",
		variant = "attached_collar_enter",
		blocks = {
			walk = -1,
			action = -1,
			heavy_hurt = -1,
			light_hurt = -1,
			hurt = -1
		}
	}

	self._unit:brain():action_request(action_data)
	self._unit:sound():say("cn1", true, nil)
end

function CopBrain:on_surrender_chance()
	local t = TimerManager:game():time()

	if self._logic_data.surrender_window then
		self._logic_data.surrender_window.expire_t = t + self._logic_data.surrender_window.timeout_duration

		managers.enemy:reschedule_delayed_clbk(self._logic_data.surrender_window.expire_clbk_id, self._logic_data.surrender_window.expire_t)

		self._logic_data.surrender_window.chance_mul = math.pow(self._logic_data.surrender_window.chance_mul, 0.93)

		return
	end

	local window_duration = 5 + 4 * math.random()
	local timeout_duration = 5 + 5 * math.random()
	self._logic_data.surrender_window = {
		chance_mul = 0.04975,
		expire_clbk_id = "CopBrain_sur_op" .. tostring(self._unit:key()),
		window_expire_t = t + window_duration,
		expire_t = t + window_duration + timeout_duration,
		window_duration = window_duration,
		timeout_duration = timeout_duration
	}

	managers.enemy:add_delayed_clbk(self._logic_data.surrender_window.expire_clbk_id, callback(self, self, "clbk_surrender_chance_expired"), self._logic_data.surrender_window.expire_t)
end

function CopBrain:terminate_all_suspicion()
	for u_key, u_data in pairs(self._logic_data.detected_attention_objects) do
		if u_data.uncover_progress then
			u_data.uncover_progress = nil
			u_data.last_suspicion_t = nil

			u_data.unit:movement():on_suspicion(self._unit, false)
		end
	end
end

function CopBrain:clbk_surrender_chance_expired()
	self._logic_data.surrender_window = nil
end

function CopBrain:add_pos_rsrv(rsrv_name, pos_rsrv)
	local pos_reservations = self._logic_data.pos_rsrv

	if pos_reservations[rsrv_name] then
		managers.navigation:unreserve_pos(pos_reservations[rsrv_name])
	end

	pos_rsrv.filter = self._logic_data.pos_rsrv_id

	managers.navigation:add_pos_reservation(pos_rsrv)

	pos_reservations[rsrv_name] = pos_rsrv

	if not pos_rsrv.id then
		debug_pause_unit(self._unit, "[CopBrain:add_pos_rsrv] missing id", inspect(pos_rsrv))

		return
	end
end

function CopBrain:set_pos_rsrv(rsrv_name, pos_rsrv)
	local pos_reservations = self._logic_data.pos_rsrv

	if pos_reservations[rsrv_name] == pos_rsrv then
		return
	end

	if pos_reservations[rsrv_name] then
		managers.navigation:unreserve_pos(pos_reservations[rsrv_name])
	end

	if not pos_rsrv.id then
		debug_pause_unit(self._unit, "[CopBrain:set_pos_rsrv] missing id", inspect(pos_rsrv))

		return
	end

	pos_reservations[rsrv_name] = pos_rsrv
end

function CopBrain:rem_pos_rsrv(rsrv_name)
	local pos_reservations = self._logic_data.pos_rsrv

	if not pos_reservations[rsrv_name] then
		return
	end

	if not pos_reservations[rsrv_name].id then
		debug_pause_unit(self._unit, "[CopBrain:rem_pos_rsrv] missing id", inspect(pos_reservations[rsrv_name]))

		return
	end

	managers.navigation:unreserve_pos(pos_reservations[rsrv_name])

	pos_reservations[rsrv_name] = nil
end

function CopBrain:get_pos_rsrv(rsrv_name)
	return self._logic_data.pos_rsrv[rsrv_name]
end

function CopBrain:rem_all_pos_rsrv()
	for rsrv_name, pos_rsrv in pairs(self._logic_data.pos_rsrv) do
		managers.navigation:unreserve_pos(pos_rsrv)
	end

	self._logic_data.pos_rsrv = {}
end

function CopBrain:_chk_enable_pickpocket_interaction()
	if self._unit:character_damage():dead() or not self._unit:movement():cool() then
		return
	end

	if self._pickpocketed then
		return
	end

	self._unit:interaction():set_tweak_data("pickpocket_steal")
	self._unit:interaction():set_active(true, true)

	return true
end

function CopBrain:_chk_disable_pickpocket_interaction()
	if self._unit:character_damage():dead() or self._unit:movement():cool() then
		return
	end

	self._unit:interaction():set_active(false, true)

	return true
end

function CopBrain:on_pickpocket_interaction(player)
	if not alive(player) or self._unit:character_damage():dead() or not self._unit:movement():cool() then
		return
	end

	local has_upgrade = nil

	if player:base().is_local_player then
		has_upgrade = managers.player:has_category_upgrade("interaction", "pickpocket_greed_steal")
	else
		has_upgrade = player:base():upgrade_value("interaction", "pickpocket_greed_steal")
	end

	if has_upgrade then
		self._pickpocketed = true
		local tweak_table_name, tweak_table = managers.greed:on_loot_pickpocketed()
		local value_line = tweak_data.greed:value_line_id(tweak_table and tweak_table.value)

		managers.dialog:queue_dialog("player_gen_loot_" .. value_line, {
			skip_idle_check = true,
			instigator = player
		})

		return tweak_table_name
	end
end

function CopBrain:_chk_enable_bodybag_interaction()
	self._unit:interaction():set_tweak_data("corpse_dispose")
	self._unit:interaction():set_active(true, true)

	return true
end

function CopBrain:on_police_call_success(unit)
	if self._logic_data.logic.on_police_call_success then
		self._logic_data.logic.on_police_call_success(self._logic_data)
	end
end

function CopBrain:stealth_action_allowed()
	return not self._flagged_looking and not self._SO_id
end

function CopBrain:_switch_to_cbt()
	self._switch_to_cbt_called = false

	if alive(self._unit) then
		self._unit:movement():set_stance("cbt", false, false)
	end
end

function CopBrain:pre_destroy(unit)
	self:set_active(false)
	self:cancel_all_pathing_searches()

	self._reload_clbks[unit:key()] = nil

	self._attention_handler:set_attention(nil)
	self._unit:movement():set_attention(nil)
	self:rem_all_pos_rsrv()

	if self._current_logic.pre_destroy then
		self._current_logic.pre_destroy(self._logic_data)
	end

	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)

		self._alert_listen_key = nil
	end

	if self._enemy_weapons_hot_listen_id then
		managers.groupai:state():remove_listener(self._enemy_weapons_hot_listen_id)

		self._enemy_weapons_hot_listen_id = nil
	end

	if self._logic_data.surrender_window then
		managers.enemy:remove_delayed_clbk(self._logic_data.surrender_window.expire_clbk_id)

		self._logic_data.surrender_window = nil
	end
end

if reload then
	for k, clbk in pairs(CopBrain._reload_clbks) do
		clbk()
	end
end
