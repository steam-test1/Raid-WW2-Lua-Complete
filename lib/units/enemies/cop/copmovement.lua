require("lib/units/enemies/cop/actions/lower_body/CopActionIdle")
require("lib/units/enemies/cop/actions/lower_body/CopActionWalk")
require("lib/units/enemies/cop/actions/full_body/CopActionAct")
require("lib/units/enemies/cop/actions/lower_body/CopActionTurn")
require("lib/units/enemies/cop/actions/full_body/CopActionHurt")
require("lib/units/enemies/cop/actions/lower_body/CopActionStand")
require("lib/units/enemies/cop/actions/lower_body/CopActionCrouch")
require("lib/units/enemies/cop/actions/upper_body/CopActionShoot")
require("lib/units/enemies/cop/actions/upper_body/CopActionReload")
require("lib/units/enemies/cop/actions/upper_body/CopActionTase")
require("lib/units/enemies/cop/actions/full_body/CopActionDodge")
require("lib/units/enemies/cop/actions/full_body/CopActionWarp")
require("lib/units/civilians/actions/lower_body/CivilianActionWalk")
require("lib/units/civilians/actions/lower_body/EscortWithSuitcaseActionWalk")
require("lib/units/enemies/tank/actions/lower_body/TankCopActionWalk")
require("lib/units/enemies/flamer/actions/lower_body/FlamerActionWalk")
require("lib/units/player_team/actions/lower_body/CriminalActionWalk")

local ids_movement = Idstring("movement")
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_lerp = mvector3.lerp
local mrot_set = mrotation.set_yaw_pitch_roll
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local stance_ctl_pts = {
	0,
	0,
	1,
	1
}
CopMovement = CopMovement or class()
CopMovement.set_friendly_fire = PlayerMovement.set_friendly_fire
CopMovement.friendly_fire = PlayerMovement.friendly_fire
CopMovement._gadgets = {
	aligns = {
		hand_l = Idstring("a_weapon_left_front"),
		hand_r = Idstring("a_weapon_right_front"),
		head = Idstring("Head")
	},
	needle = {
		Idstring("units/vanilla/props/props_syringe/props_syringe")
	}
}
local action_variants = {
	security = {
		idle = CopActionIdle,
		act = CopActionAct,
		walk = CopActionWalk,
		turn = CopActionTurn,
		hurt = CopActionHurt,
		stand = CopActionStand,
		crouch = CopActionCrouch,
		shoot = CopActionShoot,
		reload = CopActionReload,
		tase = CopActionTase,
		dodge = CopActionDodge,
		warp = CopActionWarp
	}
}
local security_variant = action_variants.security
action_variants.german_commander = security_variant
action_variants.german_og_commander = security_variant
action_variants.german_officer = security_variant
action_variants.german_grunt_light = security_variant
action_variants.german_grunt_light_mp38 = security_variant
action_variants.german_grunt_light_kar98 = security_variant
action_variants.german_grunt_light_shotgun = security_variant
action_variants.german_grunt_mid = security_variant
action_variants.german_grunt_mid_mp38 = security_variant
action_variants.german_grunt_mid_kar98 = security_variant
action_variants.german_grunt_mid_shotgun = security_variant
action_variants.german_grunt_heavy = security_variant
action_variants.german_grunt_heavy_mp38 = security_variant
action_variants.german_grunt_heavy_kar98 = security_variant
action_variants.german_grunt_heavy_shotgun = security_variant
action_variants.german_light = security_variant
action_variants.german_light_kar98 = security_variant
action_variants.german_light_shotgun = security_variant
action_variants.german_heavy = security_variant
action_variants.german_heavy_kar98 = security_variant
action_variants.german_heavy_shotgun = security_variant
action_variants.german_gasmask = security_variant
action_variants.german_gasmask_shotgun = security_variant
action_variants.german_gasmask_commander_backup = security_variant
action_variants.german_gasmask_commander_backup_shotgun = security_variant
action_variants.german_light_commander_backup = security_variant
action_variants.german_heavy_commander_backup = security_variant
action_variants.german_fallschirmjager_light = security_variant
action_variants.german_fallschirmjager_light_kar98 = security_variant
action_variants.german_fallschirmjager_light_shotgun = security_variant
action_variants.german_fallschirmjager_light_mp38 = security_variant
action_variants.german_fallschirmjager_heavy = security_variant
action_variants.german_fallschirmjager_heavy_kar98 = security_variant
action_variants.german_fallschirmjager_heavy_shotgun = security_variant
action_variants.german_fallschirmjager_heavy_mp38 = security_variant
action_variants.german_waffen_ss = security_variant
action_variants.german_waffen_ss_kar98 = security_variant
action_variants.german_waffen_ss_shotgun = security_variant
action_variants.german_gebirgsjager_light = security_variant
action_variants.german_gebirgsjager_light_kar98 = security_variant
action_variants.german_gebirgsjager_light_shotgun = security_variant
action_variants.german_gebirgsjager_light_mp38 = security_variant
action_variants.german_gebirgsjager_heavy = security_variant
action_variants.german_gebirgsjager_heavy_kar98 = security_variant
action_variants.german_gebirgsjager_heavy_shotgun = security_variant
action_variants.german_gebirgsjager_heavy_mp38 = security_variant
action_variants.german_flamer = clone(security_variant)
action_variants.german_flamer.walk = FlamerActionWalk
action_variants.german_sniper = security_variant
action_variants.german_spotter = security_variant
action_variants.soviet_nkvd_int_security_captain = security_variant
action_variants.soviet_nkvd_int_security_captain_b = security_variant
action_variants.gensec = security_variant
action_variants.cop = security_variant
action_variants.fbi = security_variant
action_variants.swat = security_variant
action_variants.heavy_swat = security_variant
action_variants.fbi_swat = security_variant
action_variants.fbi_heavy_swat = security_variant
action_variants.nathan = security_variant
action_variants.sniper = security_variant
action_variants.spotter = security_variant
action_variants.flamer = security_variant
action_variants.gangster = security_variant
action_variants.biker = security_variant
action_variants.mobster = security_variant
action_variants.mobster_boss = security_variant
action_variants.hector_boss = security_variant
action_variants.hector_boss_no_armor = security_variant
action_variants.dealer = security_variant
action_variants.biker_escape = security_variant
action_variants.city_swat = security_variant
action_variants.old_hoxton_mission = security_variant
action_variants.shield = clone(security_variant)
action_variants.shield.hurt = ShieldActionHurt
action_variants.phalanx_minion = clone(action_variants.shield)
action_variants.phalanx_vip = clone(action_variants.shield)
action_variants.tank = clone(security_variant)
action_variants.tank.walk = TankCopActionWalk
action_variants.tank_hw = action_variants.tank
action_variants.taser = security_variant
action_variants.inside_man = security_variant
action_variants.civilian = {
	idle = CopActionIdle,
	act = CopActionAct,
	walk = CivilianActionWalk,
	turn = CopActionTurn,
	hurt = CopActionHurt
}
action_variants.civilian_female = action_variants.civilian
action_variants.bank_manager = action_variants.civilian
action_variants.drunk_pilot = action_variants.civilian
action_variants.escort = action_variants.civilian
action_variants.escort.walk = EscortWithSuitcaseActionWalk
action_variants.escort_suitcase = clone(action_variants.civilian)
action_variants.escort_suitcase.walk = EscortWithSuitcaseActionWalk
action_variants.escort_prisoner = clone(action_variants.civilian)
action_variants.escort_prisoner.walk = EscortPrisonerActionWalk
action_variants.escort_cfo = action_variants.civilian
action_variants.escort_ralph = action_variants.civilian
action_variants.escort_undercover = clone(action_variants.civilian)
action_variants.escort_undercover.walk = EscortWithSuitcaseActionWalk
action_variants.team_ai = clone(security_variant)
action_variants.team_ai.walk = CriminalActionWalk
action_variants.german = action_variants.team_ai
action_variants.british = action_variants.team_ai
action_variants.american = action_variants.team_ai
action_variants.russian = action_variants.team_ai
security_variant = nil
CopMovement._action_variants = action_variants
action_variants = nil
CopMovement._stance = {
	names = {
		"ntl",
		"hos",
		"cbt",
		"wnd"
	},
	blend = {
		0.8,
		0.5,
		0.3,
		0.4
	}
}

function CopMovement:init(unit)
	self._unit = unit
	self._machine = self._unit:anim_state_machine()
	self._nav_tracker_id = self._unit:key()
	self._nav_tracker = nil
	self._root_blend_ref = 0
	self._m_pos = unit:position()
	self._m_stand_pos = mvector3.copy(self._m_pos)

	mvec3_set_z(self._m_stand_pos, self._m_pos.z + 160)

	self._m_com = math.lerp(self._m_pos, self._m_stand_pos, 0.5)
	self._obj_head = unit:get_object(Idstring("Head"))
	self._m_head_rot = self._obj_head:rotation()
	self._m_head_pos = self._obj_head:position()
	self._obj_spine = unit:get_object(Idstring("Spine1"))
	self._m_rot = unit:rotation()
	self._footstep_style = nil
	self._footstep_event = ""
	self._obj_com = unit:get_object(Idstring("Hips"))
	self._slotmask_gnd_ray = managers.slot:get_mask("AI_graph_obstacle_check")
	self._actions = self._action_variants[self._unit:movement()._action_variant or self._unit:base()._tweak_table]
	self._active_actions = {
		false,
		false,
		false,
		false
	}
	self._queued_actions = {}
	self._need_upd = true
	self._cool = true
	self._suppression = {
		value = 0
	}
end

function CopMovement:post_init()
	local unit = self._unit
	self._ext_brain = unit:brain()
	self._ext_network = unit:network()
	self._ext_anim = unit:anim_data()
	self._ext_base = unit:base()
	self._ext_damage = unit:character_damage()
	self._ext_inventory = unit:inventory()
	self._tweak_data = tweak_data.character[self._ext_base._tweak_table]

	tweak_data:add_reload_callback(self, self.tweak_data_clbk_reload)

	self._machine = self._unit:anim_state_machine()

	self._machine:set_callback_object(self)

	self._stance = {
		name = "ntl",
		code = 1,
		values = {
			1,
			0,
			0,
			0
		}
	}

	if managers.navigation:is_data_ready() then
		self._nav_tracker = managers.navigation:create_nav_tracker(self._m_pos)
		self._pos_rsrv_id = managers.navigation:get_pos_reservation_id()
	else
		Application:error("[CopMovement:post_init] Spawned AI unit with incomplete navigation data.")
		self._unit:set_extension_update(ids_movement, false)
	end

	self._unit:kill_mover()
	self._unit:set_driving("script")

	self._unit:unit_data().has_alarm_pager = self._tweak_data.has_alarm_pager

	self._unit:character_damage():add_listener("movement", {
		"bleedout",
		"light_hurt",
		"heavy_hurt",
		"expl_hurt",
		"hurt",
		"hurt_sick",
		"shield_knock",
		"counter_tased",
		"taser_tased",
		"death",
		"fatal",
		"fire_hurt",
		"poison_hurt"
	}, callback(self, self, "damage_clbk"))
	self._unit:inventory():add_listener("movement", {
		"equip",
		"unequip"
	}, callback(self, self, "clbk_inventory"))

	local prim_weap_name = self._ext_base:default_weapon_name("primary")
	local sec_weap_name = self._ext_base:default_weapon_name("secondary")

	if prim_weap_name then
		self._unit:inventory():add_unit_by_name(prim_weap_name)
	end

	if sec_weap_name and sec_weap_name ~= prim_weap_name then
		self._unit:inventory():add_unit_by_name(sec_weap_name)
	end

	if self._unit:inventory():is_selection_available(2) then
		if managers.groupai:state():whisper_mode() or not self._unit:inventory():is_selection_available(1) then
			self._unit:inventory():equip_selection(2, true)
		else
			self._unit:inventory():equip_selection(1, true)
		end
	elseif self._unit:inventory():is_selection_available(1) then
		self._unit:inventory():equip_selection(1, true)
	end

	if self._ext_inventory:equipped_selection() == 1 and managers.groupai:state():whisper_mode() then
		self._ext_inventory:set_weapon_enabled(false)
	end

	local weap_name = self._ext_base:default_weapon_name(managers.groupai:state():enemy_weapons_hot() and "primary" or "secondary")
	local fwd = self._m_rot:y()
	self._action_common_data = {
		stance = self._stance,
		pos = self._m_pos,
		rot = self._m_rot,
		fwd = fwd,
		right = self._m_rot:x(),
		unit = unit,
		machine = self._machine,
		ext_movement = self,
		ext_brain = self._ext_brain,
		ext_anim = self._ext_anim,
		ext_inventory = self._ext_inventory,
		ext_base = self._ext_base,
		ext_network = self._ext_network,
		ext_damage = self._ext_damage,
		char_tweak = self._tweak_data,
		nav_tracker = self._nav_tracker,
		active_actions = self._active_actions,
		queued_actions = self._queued_actions,
		look_vec = mvector3.copy(fwd)
	}
	self._post_init_running = true

	self:upd_ground_ray()

	self._post_init_running = nil

	if self._gnd_ray then
		self:set_position(self._gnd_ray.position)
	end

	self:_post_init()
end

function CopMovement:_post_init()
	self:set_character_anim_variables()

	if Network:is_server() then
		if not managers.groupai:state():whisper_mode() then
			self:set_cool(false)
		else
			self:set_cool(true)
		end

		self._unit:brain():on_cool_state_changed(self._cool)
	end
end

function CopMovement:set_character_anim_variables()
	if self._anim_global then
		self._machine:set_global(self._anim_global, 1)
	end

	if self._tweak_data.female then
		self._machine:set_global("female", 1)
	end

	if self._tweak_data.allowed_stances and not self._tweak_data.allowed_stances.ntl then
		self:set_cool(false)

		if self._tweak_data.allowed_stances.hos then
			self:_change_stance(2)
		else
			self:_change_stance(3)
		end
	end

	if self._tweak_data.allowed_poses and not self._tweak_data.allowed_poses.stand then
		self:play_redirect("crouch")
	end
end

function CopMovement:nav_tracker()
	return self._nav_tracker
end

function CopMovement:warp_to(pos, rot)
	self._unit:warp_to(rot, pos)
end

function CopMovement:update(unit, t, dt)
	if not managers.navigation:is_streamed_data_ready() then
		return
	end

	if managers.network:session() and not managers.network:session():local_peer():loaded() and not Application:editor() then
		return
	end

	if self._wait_load then
		return
	end

	self._gnd_ray = nil
	local old_need_upd = self._need_upd
	self._need_upd = false

	self:_upd_actions(t)

	if self._need_upd ~= old_need_upd then
		unit:set_extension_update_enabled(ids_movement, self._need_upd)
	end

	if self._force_head_upd then
		self._force_head_upd = nil

		self:upd_m_head_pos()
	end
end

function CopMovement:_upd_actions(t)
	local a_actions = self._active_actions
	local has_no_action = true

	for i_action, action in ipairs(a_actions) do
		if action then
			if action.update then
				action:update(t)
			end

			if not self._need_upd and action.need_upd then
				self._need_upd = action:need_upd()
			end

			if action.expired and action:expired() then
				a_actions[i_action] = false

				if action.on_exit then
					action:on_exit()
				end

				self._ext_brain:on_action_completed(action)
				self._ext_base:chk_freeze_anims()

				for _, action in ipairs(a_actions) do
					if action then
						has_no_action = nil

						break
					end
				end
			else
				has_no_action = nil
			end
		end
	end

	if has_no_action and (not self._queued_actions or not next(self._queued_actions)) then
		self:action_request({
			body_part = 1,
			type = "idle"
		})
	end

	if not a_actions[1] and not a_actions[2] and (not self._queued_actions or not next(self._queued_actions)) and not self:chk_action_forbidden("action") then
		if a_actions[3] then
			self:action_request({
				body_part = 2,
				type = "idle"
			})
		else
			self:action_request({
				body_part = 1,
				type = "idle"
			})
		end
	end

	self:_upd_stance(t)

	if not self._need_upd and (self._ext_anim.base_need_upd or self._ext_anim.upper_need_upd or self._stance.transition or self._suppression.transition or self._ext_anim.panic) then
		self._need_upd = true
	end
end

function CopMovement:_upd_stance(t)
	if self._stance.transition then
		local stance = self._stance
		local transition = stance.transition

		if transition.next_upd_t < t then
			local values = stance.values
			local prog = (t - transition.start_t) / transition.duration

			if prog < 1 then
				local prog_smooth = math.clamp(math.bezier(stance_ctl_pts, prog), 0, 1)
				local v_start = transition.start_values
				local v_end = transition.end_values
				local mlerp = math.lerp

				for i, v in ipairs(v_start) do
					values[i] = mlerp(v, v_end[i], prog_smooth)
				end

				transition.next_upd_t = t + 0.033
			else
				for i, v in ipairs(transition.end_values) do
					values[i] = v
				end

				stance.transition = nil
			end

			local names = CopMovement._stance.names

			for i, v in ipairs(values) do
				self._machine:set_global(names[i], v)
			end
		end
	end

	if self._suppression.transition then
		local suppression = self._suppression
		local transition = suppression.transition

		if transition.next_upd_t < t then
			local prog = (t - transition.start_t) / transition.duration

			if prog < 1 then
				local prog_smooth = math.clamp(math.bezier(stance_ctl_pts, prog), 0, 1)
				local val = math.lerp(transition.start_val, transition.end_val, prog_smooth)
				suppression.value = val

				self._machine:set_global("sup", val)

				transition.next_upd_t = t + 0.033
			else
				self._machine:set_global("sup", transition.end_val)

				suppression.value = transition.end_val
				suppression.transition = nil
			end
		end
	end
end

function CopMovement:on_anim_freeze(state)
	self._frozen = state
end

function CopMovement:upd_m_head_pos()
	self._obj_head:m_position(self._m_head_pos)
	self._obj_spine:m_position(self._m_com)
end

function CopMovement:set_position(pos)
	mvec3_set(self._m_pos, pos)
	mvec3_set(self._m_stand_pos, pos)
	mvec3_set_z(self._m_stand_pos, pos.z + 160)
	self._obj_head:m_position(self._m_head_pos)
	self._obj_spine:m_position(self._m_com)
	self._nav_tracker:move(pos)
	self._unit:set_position(pos)
end

function CopMovement:set_m_pos(pos)
	mvec3_set(self._m_pos, pos)
	mvec3_set(self._m_stand_pos, pos)
	mvec3_set_z(self._m_stand_pos, pos.z + 160)
	self._obj_head:m_position(self._m_head_pos)
	self._nav_tracker:move(pos)
	self._obj_spine:m_position(self._m_com)
end

function CopMovement:set_m_rot(rot)
	mrot_set(self._m_rot, rot:yaw(), 0, 0)

	self._action_common_data.fwd = rot:y()
	self._action_common_data.right = rot:x()
end

function CopMovement:set_rotation(rot)
	mrot_set(self._m_rot, rot:yaw(), 0, 0)

	self._action_common_data.fwd = rot:y()
	self._action_common_data.right = rot:x()

	self._unit:set_rotation(rot)
end

function CopMovement:m_pos()
	return self._m_pos
end

function CopMovement:m_stand_pos()
	return self._m_stand_pos
end

function CopMovement:m_com()
	return self._m_com
end

function CopMovement:m_head_pos()
	return self._m_head_pos
end

function CopMovement:m_head_rot()
	return self._obj_head:rotation()
end

function CopMovement:m_fwd()
	return self._action_common_data.fwd
end

function CopMovement:m_rot()
	return self._m_rot
end

function CopMovement:get_object(object_name)
	if self._unit == nil then
		return nil
	end

	if not alive(self._unit) then
		return nil
	end

	return self._unit:get_object(object_name)
end

function CopMovement:set_m_host_stop_pos(pos)
	self._m_host_stop_pos = self._m_host_stop_pos or Vector3(0, 0, 0)

	if not pos then
		return
	end

	mvec3_set(self._m_host_stop_pos, pos)
end

function CopMovement:m_host_stop_pos()
	return self._m_host_stop_pos
end

function CopMovement:play_redirect(redirect_name, at_time)
	local result = self._unit:play_redirect(Idstring(redirect_name), at_time)

	return result ~= Idstring("") and result
end

function CopMovement:play_state(state_name, at_time)
	local result = self._unit:play_state(Idstring(state_name), at_time)

	return result ~= Idstring("") and result
end

function CopMovement:play_state_idstr(state_name, at_time)
	local result = self._unit:play_state(state_name, at_time)

	return result ~= Idstring("") and result
end

function CopMovement:set_root_blend(state)
	if state then
		if self._root_blend_ref == 1 then
			self._machine:set_root_blending(true)
		end

		self._root_blend_ref = self._root_blend_ref - 1
	else
		if self._root_blend_ref == 0 then
			self._machine:set_root_blending(false)
		end

		self._root_blend_ref = self._root_blend_ref + 1
	end
end

function CopMovement:chk_action_forbidden(action_type)
	if self:is_parachuting() and action_type ~= "death" then
		return true
	end

	local t = TimerManager:game():time()

	for i_action, action in ipairs(self._active_actions) do
		if action and action.chk_block and action:chk_block(action_type, t) then
			return true
		end
	end
end

function CopMovement:action_request(action_desc)
	if Network:is_server() and self._active_actions[1] and self._active_actions[1]:type() == "hurt" and self._active_actions[1]:hurt_type() == "death" then
		debug_pause_unit(self._unit, "[CopMovement:action_request] Dead man walking!!!", self._unit, inspect(action_desc))
	end

	self.has_no_action = nil
	local body_part = action_desc.body_part
	local active_actions = self._active_actions
	local interrupted_actions = nil

	local function _interrupt_action(body_part)
		local old_action = active_actions[body_part]

		if old_action then
			active_actions[body_part] = false

			if old_action.on_exit then
				old_action:on_exit()
			end

			interrupted_actions = interrupted_actions or {}
			interrupted_actions[body_part] = old_action
		end
	end

	_interrupt_action(body_part)

	if body_part == 1 then
		_interrupt_action(2)
		_interrupt_action(3)
	elseif body_part == 2 or body_part == 3 then
		_interrupt_action(1)
	end

	if not self._actions[action_desc.type] then
		debug_pause("[CopMovement:action_request] invalid action started", inspect(self._actions), inspect(action_desc))

		return
	end

	local action, success = self._actions[action_desc.type]:new(action_desc, self._action_common_data)

	if success and (not action.expired or not action:expired()) then
		active_actions[body_part] = action
	end

	if interrupted_actions then
		for body_part, interrupted_action in pairs(interrupted_actions) do
			self._ext_brain:on_action_completed(interrupted_action)
		end
	end

	self._ext_base:chk_freeze_anims()

	return success and action
end

function CopMovement:get_action(body_part)
	return self._active_actions[body_part]
end

function CopMovement:set_attention(attention)
	if not attention and not self._attention then
		return
	end

	if attention and self._attention then
		local different = nil

		for i, k in pairs(self._attention) do
			if attention[i] ~= k then
				different = true

				break
			end
		end

		if not different then
			for i, k in pairs(attention) do
				if self._attention[i] ~= k then
					different = true

					break
				end
			end
		end

		if not different then
			return
		end
	end

	self:_remove_attention_destroy_listener(self._attention)

	if attention then
		if self._unit:character_damage():dead() then
			debug_pause_unit(self._unit, "[CopMovement:set_attention] dead AI", self._unit, inspect(attention))
		end

		if attention.unit then
			local attention_unit = nil

			if attention.handler then
				local attention_unit = attention.handler:unit()

				if attention_unit:id() ~= -1 then
					self._ext_network:send("set_attention", attention_unit, attention.reaction)
				else
					self._ext_network:send("cop_set_attention_pos", mvector3.copy(attention.handler:get_attention_m_pos()))
				end
			else
				local attention_unit = attention.unit

				if attention_unit:id() ~= -1 then
					self._ext_network:send("set_attention", attention_unit, AIAttentionObject.REACT_IDLE)
				end
			end

			self:_add_attention_destroy_listener(attention)
		else
			self._ext_network:send("cop_set_attention_pos", attention.pos)
		end
	elseif self._attention and self._unit:id() ~= -1 then
		self._ext_network:send("set_attention", nil, AIAttentionObject.REACT_IDLE)
	end

	local old_attention = self._attention
	self._attention = attention
	self._action_common_data.attention = attention

	for _, action in ipairs(self._active_actions) do
		if action and action.on_attention then
			action:on_attention(attention, old_attention)
		end
	end
end

function CopMovement:set_stance(new_stance_name, instant, execute_queued)
	for i_stance, stance_name in ipairs(CopMovement._stance.names) do
		if stance_name == new_stance_name then
			self:set_stance_by_code(i_stance, instant, execute_queued)

			break
		end
	end
end

function CopMovement:set_stance_by_code(new_stance_code, instant, execute_queued)
	if self._stance.code ~= new_stance_code then
		if new_stance_code == 1 then
			Application:debug("CopMovement:set_stance_by_code", self._unit, new_stance_code)
		end

		self._ext_network:send("set_stance", new_stance_code, instant or false, execute_queued or false)
		self:_change_stance(new_stance_code, instant)
	end
end

function CopMovement:_change_stance(stance_code, instant)
	if self._tweak_data.allowed_stances then
		if stance_code == 1 and not self._tweak_data.allowed_stances.ntl then
			return
		elseif stance_code == 2 and not self._tweak_data.allowed_stances.hos then
			return
		elseif stance_code == 3 and not self._tweak_data.allowed_stances.cbt then
			return
		end
	end

	local stance = self._stance

	if instant then
		if stance.transition or stance.code ~= stance_code then
			stance.transition = nil
			stance.code = stance_code
			stance.name = CopMovement._stance.names[stance_code]

			for i = 1, 3 do
				stance.values[i] = 0
			end

			stance.values[stance_code] = 1

			for i, v in ipairs(stance.values) do
				self._machine:set_global(CopMovement._stance.names[i], v)
			end
		end
	else
		local end_values = {}

		if stance_code == 4 then
			if stance.transition then
				end_values = stance.transition.end_values
			else
				for i, value in ipairs(stance.values) do
					end_values[i] = value
				end
			end
		elseif stance.transition then
			end_values = {
				0,
				0,
				0,
				stance.transition.end_values[4]
			}
		else
			end_values = {
				0,
				0,
				0,
				stance.values[4]
			}
		end

		end_values[stance_code] = 1

		if stance_code ~= 4 then
			stance.code = stance_code
			stance.name = CopMovement._stance.names[stance_code]
		end

		local delay = nil
		local vis_state = self._ext_base:lod_stage()

		if vis_state then
			delay = CopMovement._stance.blend[stance_code]

			if vis_state > 2 then
				delay = delay * 0.5
			end
		else
			stance.transition = nil

			if stance_code ~= 1 then
				self:_chk_play_equip_weapon()
			end

			local names = CopMovement._stance.names

			for i, v in ipairs(end_values) do
				if v ~= stance.values[i] then
					stance.values[i] = v

					self._machine:set_global(names[i], v)
				end
			end

			return
		end

		local start_values = {}

		for _, value in ipairs(stance.values) do
			table.insert(start_values, value)
		end

		local t = TimerManager:game():time()
		local transition = {
			end_values = end_values,
			start_values = start_values,
			duration = delay,
			start_t = t,
			next_upd_t = t + 0.07
		}
		stance.transition = transition
	end

	if stance_code ~= 1 then
		self:_chk_play_equip_weapon()
	end

	self:enable_update()
end

function CopMovement:sync_stance(i_stance, instant, execute_queued)
	if execute_queued and (self._active_actions[1] and self._active_actions[1]:type() ~= "idle" or self._active_actions[2] and self._active_actions[2]:type() ~= "idle") then
		table.insert(self._queued_actions, {
			block_type = "walk",
			type = "stance",
			code = i_stance,
			instant = instant
		})

		return
	end

	self:_change_stance(i_stance, instant)

	if i_stance == 1 then
		self:set_cool(true)
	else
		self:set_cool(false)
	end
end

function CopMovement:stance_name()
	return self._stance.name
end

function CopMovement:stance_code()
	return self._stance.code
end

function CopMovement:_chk_play_equip_weapon()
	if self._stance.values[1] == 1 and not self._ext_anim.equip and not self._tweak_data.no_equip_anim and not self:chk_action_forbidden("action") then
		local redir_res = self:play_redirect("equip")

		if redir_res then
			local weapon_unit = self._ext_inventory:equipped_unit()

			if weapon_unit then
				local weap_tweak = weapon_unit:base():weapon_tweak_data()
				local weapon_hold = weap_tweak.hold

				self._machine:set_parameter(redir_res, "to_" .. weapon_hold, 1)
			end
		end
	end

	self._ext_inventory:set_weapon_enabled(true)
end

function CopMovement:set_cool(state, giveaway)
	state = state and true or false

	if not state and not managers.groupai:state():enemy_weapons_hot() then
		self._coolness_giveaway = managers.groupai:state():fetch_highest_giveaway(self._coolness_giveaway, giveaway)
	end

	if state == self._cool then
		return
	end

	local old_state = self._cool
	self._cool = state
	self._action_common_data.is_cool = state

	if not state and old_state then
		self._not_cool_t = TimerManager:game():time()

		if Network:is_server() and self._stance.name == "ntl" then
			if not self._tweak_data.allowed_stances or self._tweak_data.allowed_stances.hos then
				self:set_stance("hos", nil, nil)
			elseif self._tweak_data.allowed_stances.cbt then
				self:set_stance("cbt", nil, nil)
			end
		end

		if self._unit:unit_data().mission_element and not self._unit:unit_data().alerted_event_called then
			self._unit:unit_data().alerted_event_called = true

			self._unit:unit_data().mission_element:event("alerted", self._unit)
		end

		if Network:is_server() and not managers.groupai:state():all_criminals()[self._unit:key()] then
			managers.groupai:state():on_criminal_suspicion_progress(nil, self._unit, true)
		end
	end

	self._unit:brain():on_cool_state_changed(state)

	if not state and old_state and self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("weapons_hot", self._unit)
	end
end

function CopMovement:cool()
	return self._cool
end

function CopMovement:coolness_giveaway()
	return self._coolness_giveaway
end

function CopMovement:set_giveaway(giveaway)
	self._coolness_giveaway = giveaway
end

function CopMovement:remove_giveaway()
	self._coolness_giveaway = false
end

function CopMovement:not_cool_t()
	return self._not_cool_t
end

function CopMovement:synch_attention(attention)
	if attention and self._unit:character_damage():dead() then
		debug_pause_unit(self._unit, "[CopMovement:synch_attention] dead AI", self._unit, inspect(attention))
	end

	self:_remove_attention_destroy_listener(self._attention)
	self:_add_attention_destroy_listener(attention)

	if attention and attention.unit and not attention.destroy_listener_key then
		debug_pause_unit(attention.unit, "[CopMovement:synch_attention] problematic attention unit", attention.unit)
		self:synch_attention(nil)

		return
	end

	self._attention = attention
	self._action_common_data.attention = attention

	for _, action in ipairs(self._active_actions) do
		if action and action.on_attention then
			action:on_attention(attention)
		end
	end
end

function CopMovement:_add_attention_destroy_listener(attention)
	if attention and attention.unit then
		local listener_class = attention.unit:base() and attention.unit:base().add_destroy_listener and attention.unit:base() or attention.unit:unit_data() and attention.unit:unit_data().add_destroy_listener and attention.unit:unit_data()

		if not listener_class then
			return
		end

		local listener_key = "CopMovement" .. tostring(self._unit:key())
		attention.destroy_listener_key = listener_key

		listener_class:add_destroy_listener(listener_key, callback(self, self, "attention_unit_destroy_clbk"))

		attention.debug_unit_name = attention.unit:name()
	end
end

function CopMovement:_remove_attention_destroy_listener(attention)
	if attention and attention.destroy_listener_key then
		if not alive(attention.unit) then
			debug_pause_unit(self._unit, "[CopDamage:_on_damage_received] dead AI", self._unit, inspect(attention))

			attention.destroy_listener_key = nil

			return
		end

		local listener_class = attention.unit:base() and attention.unit:base().remove_destroy_listener and attention.unit:base() or attention.unit:unit_data() and attention.unit:unit_data().remove_destroy_listener and attention.unit:unit_data()

		listener_class:remove_destroy_listener(attention.destroy_listener_key)

		attention.destroy_listener_key = nil
	end
end

function CopMovement:attention()
	return self._attention
end

function CopMovement:attention_unit_destroy_clbk(unit)
	if Network:is_server() then
		self:set_attention()
	else
		self:synch_attention()
	end
end

function CopMovement:set_allow_fire_on_client(state, unit)
	if Network:is_server() then
		unit:network():send_to_unit({
			"set_allow_fire",
			self._unit,
			state
		})
	end
end

function CopMovement:set_allow_fire(state)
	if self._allow_fire == state then
		return
	end

	self:synch_allow_fire(state)

	if Network:is_server() then
		self._ext_network:send("set_allow_fire", state)
	end

	self:enable_update()
end

function CopMovement:synch_allow_fire(state)
	for _, action in pairs(self._active_actions) do
		if action and action.allow_fire_clbk then
			action:allow_fire_clbk(state)
		end
	end

	self._allow_fire = state
	self._action_common_data.allow_fire = state
end

function CopMovement:linked(state, physical, parent_unit)
	if state then
		self._link_data = {
			physical = physical,
			parent = parent_unit
		}

		parent_unit:base():add_destroy_listener("CopMovement" .. tostring(self._unit:key()), callback(self, self, "parent_clbk_unit_destroyed"))
	else
		parent_unit:base():remove_destroy_listener("CopMovement" .. tostring(self._unit:key()))

		self._link_data = nil
	end
end

function CopMovement:parent_clbk_unit_destroyed(parent_unit, key)
	self._link_data = nil

	parent_unit:base():remove_destroy_listener("CopMovement" .. tostring(self._unit:key()))
end

function CopMovement:is_physically_linked()
	return self._link_data and self._link_data.physical
end

function CopMovement:move_vec()
	return self._move_dir
end

function CopMovement:upd_ground_ray(from_pos)
	local ground_z = self._nav_tracker:field_z()
	local safe_pos = temp_vec1

	mvec3_set(temp_vec1, from_pos or self._m_pos)
	mvec3_set_z(temp_vec1, ground_z + 100)

	local down_pos = temp_vec2

	mvec3_set(temp_vec2, safe_pos)
	mvec3_set_z(temp_vec2, ground_z - tweak_data.player.PLAYER_EYE_HEIGHT)

	local old_pos = self._m_pos
	local new_pos = from_pos or self._m_pos
	local hit_ray = nil

	if old_pos.z == new_pos.z then
		local gnd_ray_1 = World:raycast("ray", temp_vec1, temp_vec2, "slot_mask", self._slotmask_gnd_ray, "ray_type", "walk")

		if gnd_ray_1 then
			ground_z = math.lerp(gnd_ray_1.position.z, self._m_pos.z, 0.5)
			hit_ray = gnd_ray_1
		elseif self._post_init_running then
			ground_z = new_pos.z
		end
	else
		local gnd_ray_1 = World:raycast("ray", temp_vec1, temp_vec2, "slot_mask", self._slotmask_gnd_ray, "ray_type", "walk")
		local move_vec = temp_vec3

		mvec3_set(move_vec, new_pos)
		mvector3.subtract(move_vec, old_pos)
		mvec3_set_z(move_vec, 0)

		local move_vec_len = mvector3.normalize(move_vec)

		mvector3.multiply(move_vec, math.min(move_vec_len, 20))
		mvector3.add(temp_vec1, move_vec)
		mvector3.add(temp_vec2, move_vec)

		if gnd_ray_1 then
			hit_ray = gnd_ray_1
			local gnd_ray_2 = World:raycast("ray", temp_vec1, temp_vec2, "slot_mask", self._slotmask_gnd_ray, "ray_type", "walk")

			if gnd_ray_2 then
				ground_z = math.lerp(gnd_ray_1.position.z, gnd_ray_2.position.z, 0.5)
			else
				ground_z = math.lerp(gnd_ray_1.position.z, self._m_pos.z, 0.5)
			end
		else
			local gnd_ray_2 = World:raycast("ray", temp_vec1, temp_vec2, "slot_mask", self._slotmask_gnd_ray, "ray_type", "walk")

			if gnd_ray_2 then
				hit_ray = gnd_ray_2
				ground_z = math.lerp(gnd_ray_2.position.z, self._m_pos.z, 0.5)
			end
		end
	end

	local fake_ray = {
		position = new_pos:with_z(ground_z),
		ray = math.DOWN,
		unit = hit_ray and hit_ray.unit
	}
	self._action_common_data.gnd_ray = fake_ray
	self._gnd_ray = fake_ray
end

function CopMovement:on_suppressed(state)
	local suppression = self._suppression
	local end_value = state and 1 or 0
	local vis_state = self._ext_base:lod_stage()

	if vis_state and end_value ~= suppression.value then
		local t = TimerManager:game():time()
		local duration = 0.5 * math.abs(end_value - suppression.value)
		suppression.transition = {
			end_val = end_value,
			start_val = suppression.value,
			duration = duration,
			start_t = t,
			next_upd_t = t + 0.07
		}
	else
		suppression.transition = nil
		suppression.value = end_value

		self._machine:set_global("sup", end_value)
	end

	self._action_common_data.is_suppressed = state and true or nil

	if Network:is_server() and state and (not self._tweak_data.allowed_poses or self._tweak_data.allowed_poses.crouch) and (not self._tweak_data.allowed_poses or self._tweak_data.allowed_poses.stand) and not self:chk_action_forbidden("walk") then
		if state == "panic" and not self:chk_action_forbidden("act") then
			local action_desc = {
				clamp_to_graph = true,
				type = "act",
				body_part = 1,
				variant = self._ext_anim.run and self._ext_anim.move_fwd and "e_so_sup_fumble_run_fwd" or "e_so_sup_fumble_inplace",
				blocks = {
					action = -1,
					walk = -1
				}
			}

			self:action_request(action_desc)
		elseif self._ext_anim.idle and (not self._active_actions[2] or self._active_actions[2]:type() == "idle") then
			local action_desc = {
				clamp_to_graph = true,
				type = "act",
				body_part = 1,
				variant = "suppressed_reaction",
				blocks = {
					walk = -1
				}
			}

			self:action_request(action_desc)
		elseif not self._ext_anim.crouch and self._tweak_data.crouch_move and (not self._tweak_data.allowed_poses or self._tweak_data.allowed_poses.crouch) then
			local action_desc = {
				body_part = 4,
				type = "crouch"
			}

			self:action_request(action_desc)
		end
	end

	self:enable_update()

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("suppressed_state", self._unit, state and true or false)
	end
end

function CopMovement:damage_clbk(my_unit, damage_info)
	if damage_info.join_game then
		return
	end

	if my_unit:unit_data().turret_weapon and damage_info.result.type ~= "death" then
		return
	end

	local hurt_type = damage_info.result.type
	local block_type = hurt_type

	if hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	end

	if hurt_type == "death" and self._queued_actions then
		self._queued_actions = {}
	end

	if not hurt_type or Network:is_server() and self:chk_action_forbidden(block_type) then
		if hurt_type == "death" then
			debug_pause_unit(self._unit, "[CopMovement:damage_clbk] Death action skipped!!!", self._unit)
			Application:draw_cylinder(self._m_pos, self._m_pos + math.UP * 5000, 30, 1, 0, 0)
			print("active_actions")

			for body_part, action in ipairs(self._active_actions) do
				if action then
					print(body_part, action:type(), inspect(action._blocks))
				end
			end
		end

		return
	end

	if hurt_type == "death" then
		if self._rope then
			self._rope:base():retract()

			self._rope = nil
		end

		if Network:is_server() then
			self:set_attention()
		else
			self:synch_attention()
		end
	end

	local attack_dir = damage_info.col_ray and damage_info.col_ray.ray or damage_info.attack_dir
	local hit_pos = damage_info.col_ray and damage_info.col_ray.position or damage_info.pos
	local lgt_hurt = hurt_type == "light_hurt"
	local body_part = lgt_hurt and 4 or 1
	local blocks = nil

	if not lgt_hurt then
		blocks = {
			act = -1,
			aim = -1,
			action = -1,
			tase = -1,
			walk = -1
		}

		if hurt_type == "bleedout" then
			blocks.bleedout = -1
			blocks.hurt = -1
			blocks.heavy_hurt = -1
			blocks.hurt_sick = -1
		end
	end

	if damage_info.variant == "tase" then
		block_type = "bleedout"
	elseif hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	else
		block_type = hurt_type
	end

	local client_interrupt = nil

	if Network:is_client() and (hurt_type == "light_hurt" or hurt_type == "hurt" and damage_info.variant ~= "tase" or hurt_type == "heavy_hurt" or hurt_type == "expl_hurt" or hurt_type == "shield_knock" or hurt_type == "counter_tased" or hurt_type == "taser_tased" or hurt_type == "death" or hurt_type == "hurt_sick" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt") then
		client_interrupt = true
	end

	local tweak = self._tweak_data
	local action_data = {
		type = "hurt",
		block_type = block_type,
		hurt_type = hurt_type,
		variant = damage_info.variant,
		direction_vec = attack_dir,
		hit_pos = hit_pos,
		body_part = body_part,
		blocks = blocks,
		client_interrupt = client_interrupt,
		attacker_unit = damage_info.attacker_unit,
		death_type = tweak.damage.death_severity and (tweak.damage.death_severity < damage_info.damage / tweak.HEALTH_INIT and "heavy" or "normal") or "normal",
		ignite_character = damage_info.ignite_character,
		start_dot_damage_roll = damage_info.start_dot_damage_roll,
		is_fire_dot_damage = damage_info.is_fire_dot_damage,
		fire_dot_data = damage_info.fire_dot_data
	}

	if Network:is_server() or not self:chk_action_forbidden(action_data) then
		self:action_request(action_data)

		if hurt_type == "death" and self._queued_actions then
			self._queued_actions = {}
		end
	end
end

function CopMovement:anim_clbk_spawn_effect(unit, effect_name, object_name)
	World:effect_manager():spawn({
		effect = Idstring(effect_name),
		parent = self._unit:get_object(Idstring(object_name))
	})
end

function CopMovement:anim_clbk_footstep(unit)
	managers.game_play_central:request_play_footstep(unit, self._m_pos)
end

function CopMovement:get_footstep_event()
	local event_name = nil

	if self._footstep_style and self._unit:anim_data()[self._footstep_style] then
		event_name = self._footstep_event
	else
		self._footstep_style = self._unit:anim_data().run and "_run" or ""
		event_name = "footsteps_npc" .. self._footstep_style
		self._footstep_event = event_name
	end

	return event_name
end

function CopMovement:get_walk_to_pos()
	local leg_action = self._active_actions[1] or self._active_actions[2]

	if leg_action and leg_action.get_walk_to_pos then
		return leg_action:get_walk_to_pos()
	end
end

function CopMovement:anim_clbk_death_drop(...)
	for _, action in ipairs(self._active_actions) do
		if action and action.on_death_drop then
			action:on_death_drop(...)
		end
	end
end

function CopMovement:on_death_exit()
	for _, action in ipairs(self._active_actions) do
		if action and action.on_death_exit then
			action:on_death_exit()
		end
	end
end

function CopMovement:anim_clbk_reload_exit()
	if self._ext_inventory:equipped_unit() then
		self._ext_inventory:equipped_unit():base():on_reload()
	end
end

function CopMovement:anim_clbk_force_ragdoll()
	for _, action in ipairs(self._active_actions) do
		if action and action.force_ragdoll then
			action:force_ragdoll()
		end
	end
end

function CopMovement:anim_clbk_rope(unit, state)
	if state == "on" then
		if self._rope then
			self._rope:base():retract()
		end

		local hips_obj = self._unit:get_object(Idstring("Hips"))
		self._rope = World:spawn_unit(Idstring("units/vanilla/dev/enemy_spawn_rope/enemy_spawn_rope"), hips_obj:position(), Rotation())

		self._rope:base():setup(hips_obj)
	elseif self._rope then
		self._rope:base():retract()

		self._rope = nil
	end
end

function CopMovement:rope_unit()
	return self._rope
end

function CopMovement:pos_rsrv_id()
	return self._pos_rsrv_id
end

function CopMovement:anim_clbk_melee_strike(unit)
	for body_part, action in pairs(self._active_actions) do
		if action and action.anim_clbk_melee_strike then
			action:anim_clbk_melee_strike()
		end
	end
end

function CopMovement:anim_clbk_set_visibility(unit, state)
	state = state == true and true or false

	self._unit:set_visible(state)
end

function CopMovement:anim_clbk_wanted_item(unit, item_type, align_place, droppable)
	self._wanted_items = self._wanted_items or {}

	table.insert(self._wanted_items, {
		item_type,
		align_place,
		droppable
	})
end

function CopMovement:anim_clbk_block_info(unit, preset_name, block_state)
	local state_bool = block_state == "true" and true or false

	for body_part, action in pairs(self._active_actions) do
		if action and action.set_blocks then
			action:set_blocks(preset_name, state_bool)
		end
	end
end

function CopMovement:anim_clbk_ik_change(unit)
	local preset_name = self._ext_anim.base_aim_ik

	for body_part, action in pairs(self._active_actions) do
		if action and action.set_ik_preset then
			action:set_ik_preset(preset_name)
		end
	end
end

function CopMovement:anim_clbk_enter_vehicle(unit)
	if self.vehicle_unit and self.vehicle_seat then
		self.vehicle_unit:vehicle_driving():on_team_ai_enter(self._unit)
	else
		Application:debug("[CopMovement:anim_clbk_enter_vehicle] No seat present!", self._unit, self.vehicle_unit)
	end
end

function CopMovement:anim_clbk_police_called(unit)
	if Network:is_server() then
		if not managers.groupai:state():is_ecm_jammer_active("call") then
			local group_state = managers.groupai:state()
			local cop_type = tostring(group_state.blame_triggers[self._ext_base._tweak_table])

			managers.groupai:state():on_criminal_suspicion_progress(nil, self._unit, "called")

			if cop_type == "civ" then
				group_state:on_police_called(self:coolness_giveaway())
			else
				group_state:on_police_called(self:coolness_giveaway())
			end
		else
			managers.groupai:state():on_criminal_suspicion_progress(nil, self._unit, "call_interrupted")
		end
	end
end

function CopMovement:anim_clbk_stance(unit, stance_name, instant)
	self:set_stance(stance_name, instant)
end

function CopMovement:spawn_wanted_items()
	if self._wanted_items then
		for _, spawn_info in ipairs(self._wanted_items) do
			self:_equip_item(unpack(spawn_info))
		end

		self._wanted_items = nil
	end
end

function CopMovement:_equip_item(item_type, align_place, droppable)
	local align_name = self._gadgets.aligns[align_place]

	if not align_name then
		print("[CopMovement:anim_clbk_equip_item] non existent align place:", align_place)

		return
	end

	local align_obj = self._unit:get_object(align_name)
	local available_items = self._gadgets[item_type]

	if not available_items then
		print("[CopMovement:anim_clbk_equip_item] non existent item_type:", item_type)

		return
	end

	local item_name = available_items[math.random(available_items)]

	print("[CopMovement:_equip_item]", item_name)

	local item_unit = World:spawn_unit(item_name, align_obj:position(), align_obj:rotation())

	self._unit:link(align_name, item_unit, item_unit:orientation_object():name())

	self._equipped_gadgets = self._equipped_gadgets or {}
	self._equipped_gadgets[align_place] = self._equipped_gadgets[align_place] or {}

	table.insert(self._equipped_gadgets[align_place], item_unit)

	if droppable then
		self._droppable_gadgets = self._droppable_gadgets or {}

		table.insert(self._droppable_gadgets, item_unit)
	end
end

function CopMovement:anim_clbk_drop_held_items()
	self:drop_held_items()
end

function CopMovement:anim_clbk_flush_wanted_items()
	self._wanted_items = nil
end

function CopMovement:drop_held_items()
	if not self._droppable_gadgets then
		return
	end

	for _, drop_item_unit in ipairs(self._droppable_gadgets) do
		local wanted_item_key = drop_item_unit:key()

		if alive(drop_item_unit) then
			for align_place, item_list in pairs(self._equipped_gadgets) do
				if wanted_item_key then
					for i_item, item_unit in ipairs(item_list) do
						if item_unit:key() == wanted_item_key then
							table.remove(item_list, i_item)

							wanted_item_key = nil

							break
						end
					end
				else
					break
				end
			end

			drop_item_unit:unlink()
			drop_item_unit:set_slot(0)
		else
			for align_place, item_list in pairs(self._equipped_gadgets) do
				if wanted_item_key then
					for i_item, item_unit in ipairs(item_list) do
						if not alive(item_unit) then
							table.remove(item_list, i_item)
						end
					end
				end
			end
		end
	end

	self._droppable_gadgets = nil
end

function CopMovement:_destroy_gadgets()
	if not self._equipped_gadgets then
		return
	end

	for align_place, item_list in pairs(self._equipped_gadgets) do
		for _, item_unit in ipairs(item_list) do
			if alive(item_unit) then
				item_unit:set_slot(0)
			end
		end
	end

	self._equipped_gadgets = nil
	self._droppable_gadgets = nil
end

function CopMovement:anim_clbk_enemy_spawn_melee_item()
	if alive(self._melee_item_unit) then
		return
	end

	local align_obj_l_name = CopMovement._gadgets.aligns.hand_l
	local align_obj_r_name = CopMovement._gadgets.aligns.hand_r
	local align_obj_l = self._unit:get_object(align_obj_l_name)
	local align_obj_r = self._unit:get_object(align_obj_r_name)
	local melee_weapon = self._unit:base():melee_weapon()
	local unit_name = melee_weapon and tweak_data.weapon.npc_melee[melee_weapon].unit_name or nil

	if unit_name then
		self._melee_item_unit = World:spawn_unit(unit_name, align_obj_l:position(), align_obj_l:rotation())

		self._unit:link(align_obj_l:name(), self._melee_item_unit, self._melee_item_unit:orientation_object():name())
	end
end

function CopMovement:anim_clbk_enemy_unspawn_melee_item()
	if alive(self._melee_item_unit) then
		self._melee_item_unit:unlink()
		World:delete_unit(self._melee_item_unit)

		self._melee_item_unit = nil
	end
end

function CopMovement:clbk_inventory(unit, event)
	local weapon = self._ext_inventory:equipped_unit()

	if weapon then
		if self._weapon_hold then
			self._machine:set_global(self._weapon_hold, 0)
		end

		if self._weapon_anim_global then
			self._machine:set_global(self._weapon_anim_global, 0)
		end

		local weap_tweak = weapon:base():weapon_tweak_data()
		local weapon_hold = weap_tweak.hold

		self._machine:set_global(weapon_hold, 1)

		self._weapon_hold = weapon_hold
		local weapon_usage = weap_tweak.usage_anim

		self._machine:set_global(weapon_usage, 1)

		self._weapon_anim_global = weapon_usage
	end

	for _, action in ipairs(self._active_actions) do
		if action and action.on_inventory_event then
			action:on_inventory_event(event)
		end
	end
end

function CopMovement:sync_shot_blank(impact)
	local equipped_weapon = self._ext_inventory:equipped_unit()

	if equipped_weapon and equipped_weapon:base().fire_blank then
		local fire_dir = nil

		if self._attention then
			if self._attention.unit then
				fire_dir = self._attention.unit:movement():m_head_pos() - self:m_head_pos()

				mvector3.normalize(fire_dir)
			else
				fire_dir = self._attention.pos - self:m_head_pos()

				mvector3.normalize(fire_dir)
			end
		else
			fire_dir = self._action_common_data.fwd
		end

		equipped_weapon:base():fire_blank(fire_dir, impact)
	end
end

function CopMovement:sync_taser_fire()
	local tase_action = self._active_actions[3]

	if tase_action and tase_action:type() == "tase" and not tase_action:expired() then
		tase_action:fire_taser()
	end
end

function CopMovement:save(save_data)
	local ext_damage = self._unit:character_damage()
	local my_save_data = {
		dead = ext_damage:dead()
	}

	if self._stance.code ~= 1 then
		my_save_data.stance_code = self._stance.code
	end

	if self._stance.transition then
		if self._stance.transition.end_values[4] ~= 0 then
			my_save_data.stance_wnd = true
		end
	elseif self._stance.values[4] ~= 0 then
		my_save_data.stance_wnd = true
	end

	for _, action in ipairs(self._active_actions) do
		if action and action.save then
			local action_save_data = {}

			action:save(action_save_data)

			if next(action_save_data) then
				my_save_data.actions = my_save_data.actions or {}

				table.insert(my_save_data.actions, action_save_data)
			end
		end
	end

	if not ext_damage:dead() and self._attention then
		if self._attention.pos then
			my_save_data.attention = self._attention
		elseif self._attention.unit:id() == -1 then
			local attention_pos = self._attention.handler and self._attention.handler:get_detection_m_pos() or self._attention.unit:movement() and self._attention.unit:movement():m_com() or self._unit:position()
			my_save_data.attention = {
				pos = attention_pos
			}
		else
			managers.enemy:add_delayed_clbk("clbk_sync_attention" .. tostring(self._unit:key()), callback(self, self, "clbk_sync_attention", self._attention), TimerManager:game():time() + 0.1)
		end
	end

	if self._allow_fire then
		my_save_data.allow_fire = true
	end

	my_save_data.team_id = self._team.id

	if self._equipped_gadgets then
		local equipped_items = {}
		my_save_data.equipped_gadgets = equipped_items

		local function _get_item_type_from_unit(item_unit)
			local wanted_item_name = item_unit:name()

			for item_type, item_unit_names in pairs(self._gadgets) do
				for i_item_unit_name, item_unit_name in ipairs(item_unit_names) do
					if item_unit_name == wanted_item_name then
						return item_type
					end
				end
			end
		end

		local function _is_item_droppable(item_unit)
			if not self._droppable_gadgets then
				return
			end

			local wanted_item_key = item_unit:key()

			for _, droppable_unit in ipairs(self._droppable_gadgets) do
				if droppable_unit:key() == wanted_item_key then
					return true
				end
			end
		end

		for align_place, item_list in pairs(self._equipped_gadgets) do
			for i_item, item_unit in ipairs(item_list) do
				if alive(item_unit) then
					table.insert(equipped_items, {
						_get_item_type_from_unit(item_unit),
						align_place,
						_is_item_droppable(item_unit)
					})
				end
			end
		end
	end

	if self.vehicle_unit then
		my_save_data.vehicle_unit_id = self.vehicle_unit:unit_data().unit_id
	end

	if next(my_save_data) then
		save_data.movement = my_save_data
	end
end

function CopMovement:load(load_data)
	self._load_data = load_data

	if managers.navigation:is_data_ready() then
		self:_do_load()
	else
		Application:debug("[CopMovement:load] queueng cop movement load until navigation is ready")

		self._nav_ready_listener_key = "CopMovement" .. tostring(self._unit:key())

		managers.navigation:add_listener(self._nav_ready_listener_key, {
			"navigation_ready"
		}, callback(self, self, "_do_load"))

		self._wait_load = true
	end
end

function CopMovement:_do_load()
	local load_data = self._load_data
	self._wait_load = false
	local my_load_data = load_data.movement

	if not my_load_data then
		return
	end

	local res = self:play_redirect("idle")

	if not res then
		debug_pause_unit(self._unit, "[CopMovement:load] failed idle redirect in ", self._machine:segment_state(Idstring("base")), self._unit)
	end

	self._allow_fire = my_load_data.allow_fire
	self._action_common_data.allow_fire = my_load_data.allow_fire
	self._attention = my_load_data.attention

	if my_load_data.stance_code then
		self:_change_stance(my_load_data.stance_code)

		if my_load_data.stance_code == 1 then
			self:set_cool(true)
		else
			self:set_cool(false)
		end
	end

	if my_load_data.stance_wnd then
		self:_change_stance(4)
	end

	if not my_load_data.dead then
		self._team = managers.groupai:state():team_data(my_load_data.team_id)

		managers.groupai:state():add_listener("CopMovement_team_def_" .. tostring(self._unit:key()), {
			"team_def"
		}, callback(self, self, "clbk_team_def"))
	end

	if my_load_data.actions then
		for _, action_load_data in ipairs(my_load_data.actions) do
			self:action_request(action_load_data)
		end
	end

	if my_load_data.equipped_gadgets then
		for _, item_desc in ipairs(my_load_data.equipped_gadgets) do
			self:_equip_item(unpack(item_desc))
		end
	end

	if self._nav_ready_listener_key then
		managers.navigation:remove_listener(self._nav_ready_listener_key)
	end

	if my_load_data.vehicle_unit_id then
		local worlddefinition = managers.worldcollection and managers.worldcollection:get_worlddefinition_by_unit_id(my_load_data.vehicle_unit_id) or managers.worlddefinition
		local original_unit_id = worlddefinition:get_original_unit_id(my_load_data.vehicle_unit_id)

		self:set_vehicle_unit(worlddefinition:get_unit_on_load(original_unit_id, callback(self, self, "set_vehicle_unit")))
	end
end

function CopMovement:set_vehicle_unit(unit)
	self.vehicle_unit = unit
end

function CopMovement:clbk_team_def()
	self._team = managers.groupai:state():team_data(self._team.id)

	managers.groupai:state():remove_listener("CopMovement_team_def_" .. tostring(self._unit:key()))
end

function CopMovement:tweak_data_clbk_reload()
	self._tweak_data = tweak_data.character[self._ext_base._tweak_table]
	self._action_common_data.char_tweak = self._tweak_data
end

function CopMovement:_chk_start_queued_action()
	local queued_actions = self._queued_actions

	while next(queued_actions) do
		local action_desc = queued_actions[1]

		if self:chk_action_forbidden(action_desc) then
			self._need_upd = true

			break
		else
			if action_desc.type == "stance" then
				if queued_actions[2] and not self:chk_action_forbidden(queued_actions[2]) or (not self._active_actions[1] or self._active_actions[1]:type() == "idle") and (not self._active_actions[2] or self._active_actions[2]:type() == "idle") then
					table.remove(queued_actions, 1)
					self:_change_stance(action_desc.code, action_desc.instant)

					if action_desc.code == 1 then
						self:set_cool(true)
					else
						self:set_cool(false)
					end

					self:_chk_start_queued_action()
				end

				return
			end

			table.remove(queued_actions, 1)
			CopMovement.action_request(self, action_desc)
		end
	end
end

function CopMovement:_push_back_queued_action(action_desc)
	table.insert(self._queued_actions, action_desc)
end

function CopMovement:_push_front_queued_action(action_desc)
	table.insert(self._queued_actions, 1, action_desc)
end

function CopMovement:_cancel_latest_action(search_type, explicit)
	for i = #self._queued_actions, 1, -1 do
		if self._queued_actions[i].type == search_type then
			table.remove(self._queued_actions, i)

			return
		end
	end

	for body_part, action in ipairs(self._active_actions) do
		if action and action:type() == search_type then
			self._active_actions[body_part] = false

			if action.on_exit then
				action:on_exit()
			end

			self:_chk_start_queued_action()
			self._ext_brain:on_action_completed(action)

			return
		end
	end

	if explicit then
		debug_pause_unit(self._unit, "[CopMovement:_cancel_latest_action] no queued or ongoing ", search_type, "action", self._unit, inspect(self._queued_actions), inspect(self._active_actions))
	end
end

function CopMovement:_get_latest_walk_action()
	for i = #self._queued_actions, 1, -1 do
		if self._queued_actions[i].type == "walk" and self._queued_actions[i].persistent then
			return self._queued_actions[i], true
		end
	end

	if self._active_actions[2] and self._active_actions[2]:type() == "walk" then
		return self._active_actions[2]
	end

	print(self._unit, "[CopMovement:_get_latest_walk_action] no queued or ongoing walk action", self._unit, inspect(self._queued_actions), inspect(self._active_actions))
end

function CopMovement:_get_latest_act_action()
	for i = #self._queued_actions, 1, -1 do
		if self._queued_actions[i].type == "act" and not self._queued_actions[i].host_expired then
			return self._queued_actions[i], true
		end
	end

	if self._active_actions[1] and self._active_actions[1]:type() == "act" then
		return self._active_actions[1]
	end
end

function CopMovement:sync_action_walk_nav_point(pos)
	local walk_action, is_queued = self:_get_latest_walk_action()

	if is_queued then
		table.insert(walk_action.nav_path, pos)
	elseif walk_action then
		walk_action:append_nav_point(pos)
	else
		print(self._unit, "[CopMovement:sync_action_walk_nav_point] no walk action!!!", self._unit, pos)
	end
end

function CopMovement:sync_action_walk_nav_link(pos, rot, anim_index, from_idle)
	local nav_link = self._actions.walk.synthesize_nav_link(pos, rot, self._actions.act:_get_act_name_from_index(anim_index), from_idle)
	local walk_action, is_queued = self:_get_latest_walk_action()

	if is_queued then
		function nav_link.element.value(element, name)
			return element[name]
		end

		nav_link.element.nav_link_wants_align_pos = nav_link.element.nav_link_wants_align_pos or function (element)
			Application:debug("[CopActionWalk:sync_action_walk_nav_link()] Appending something that is not nav_link", inspect(self))

			return true
		end

		table.insert(walk_action.nav_path, nav_link)
	elseif walk_action then
		walk_action:append_nav_point(nav_link)
	else
		print(self._unit, "[CopMovement:sync_action_walk_nav_link] no walk action!!!", self._unit, pos, rot, anim_index)
	end
end

function CopMovement:sync_action_walk_stop()
	local walk_action, is_queued = self:_get_latest_walk_action()

	if is_queued then
		table.insert(walk_action.nav_path, CopActionWalk._nav_point_pos(walk_action.nav_path[#walk_action.nav_path]))

		walk_action.persistent = nil
	elseif walk_action then
		walk_action:stop()
	else
		print("[CopMovement:sync_action_walk_stop] no walk action!!!", self._unit)
	end
end

function CopMovement:sync_action_tase_end()
	self:_cancel_latest_action("tase", true)
end

function CopMovement:sync_pose(pose_code)
	if self._ext_damage:dead() then
		return
	end

	local pose = pose_code == 1 and "stand" or "crouch"
	local new_action_data = {
		body_part = 4,
		type = pose
	}

	self:action_request(new_action_data)
end

function CopMovement:sync_action_act_start(index, blocks_hurt, clamp_to_graph, needs_full_blend, start_rot, start_pos)
	if self._ext_damage:dead() then
		return
	end

	local redir_name = self._actions.act:_get_act_name_from_index(index)
	local action_data = {
		type = "act",
		body_part = 1,
		variant = redir_name,
		blocks = {
			act = -1,
			idle = -1,
			action = -1,
			walk = -1
		},
		start_rot = start_rot,
		start_pos = start_pos,
		clamp_to_graph = clamp_to_graph,
		needs_full_blend = needs_full_blend
	}

	if blocks_hurt then
		action_data.blocks.light_hurt = -1
		action_data.blocks.hurt = -1
		action_data.blocks.heavy_hurt = -1
		action_data.blocks.expl_hurt = -1
		action_data.blocks.fire_hurt = -1
	end

	self:action_request(action_data)
end

function CopMovement:sync_action_act_end()
	local act_action, queued = self:_get_latest_act_action()

	if queued then
		act_action.host_expired = true
	elseif act_action then
		self._active_actions[1] = false

		if act_action.on_exit then
			act_action:on_exit()
		end

		self:_chk_start_queued_action()
		self._ext_brain:on_action_completed(act_action)
	end
end

function CopMovement:sync_action_dodge_start(body_part, var, side, rot, speed, shoot_acc)
	if self._ext_damage:dead() then
		return
	end

	local action_data = {
		type = "dodge",
		body_part = body_part,
		variation = CopActionDodge.get_variation_name(var),
		direction = Rotation(rot):y(),
		side = CopActionDodge.get_side_name(side),
		speed = speed,
		shoot_accuracy = shoot_acc
	}

	self:action_request(action_data)
end

function CopMovement:sync_action_dodge_end()
	self:_cancel_latest_action("dodge")
end

function CopMovement:sync_action_aim_end()
	self:_cancel_latest_action("shoot", true)
end

function CopMovement:sync_action_hurt_end()
	for i = #self._queued_actions, 1, -1 do
		if self._queued_actions[i].type == "hurt" then
			table.remove(self._queued_actions, i)

			return
		end
	end

	local action = self._active_actions[1]

	if action and action:type() == "hurt" then
		self._active_actions[1] = false

		if action.on_exit then
			action:on_exit()
		end

		local hurt_type = action:hurt_type()

		if hurt_type == "bleedout" or hurt_type == "fatal" then
			local action_data = {
				client_interrupt = true,
				type = "act",
				body_part = 1,
				variant = "stand",
				blocks = {
					heavy_hurt = -1,
					hurt = -1,
					action = -1,
					stand = -1,
					light_hurt = -1,
					aim = -1,
					crouch = -1,
					walk = -1
				}
			}
			local res = CopMovement.action_request(self, action_data)
		else
			self:_chk_start_queued_action()
			self._ext_brain:on_action_completed(action)
		end

		return
	end

	debug_pause("[CopMovement:sync_action_hurt_end] no queued or ongoing hurt action", self._unit, inspect(self._queued_actions), inspect(self._active_actions))
end

function CopMovement:enable_update(force_head_upd)
	if not self._need_upd then
		self._unit:set_extension_update_enabled(ids_movement, true)

		self._need_upd = true
		self._force_head_upd = force_head_upd
	end
end

function CopMovement:ground_ray()
	return self._gnd_ray
end

function CopMovement:on_nav_link_unregistered(element_id)
	for body_part, action in pairs(self._active_actions) do
		if action and action.on_nav_link_unregistered then
			action:on_nav_link_unregistered(element_id)
		end
	end
end

function CopMovement:pre_destroy()
	tweak_data:remove_reload_callback(self)

	if alive(self._rope) then
		self._rope:base():retract()

		self._rope = nil
	end

	if self._nav_tracker then
		managers.navigation:destroy_nav_tracker(self._nav_tracker)

		self._nav_tracker = nil
	end

	if self._pos_rsrv_id then
		managers.navigation:release_pos_reservation_id(self._pos_rsrv_id)

		self._pos_rsrv_id = nil
	end

	if self._link_data then
		self._link_data.parent:base():remove_destroy_listener("CopMovement" .. tostring(unit:key()))
	end

	self:_destroy_gadgets()

	for i_action, action in ipairs(self._active_actions) do
		if action and action.on_destroy then
			action:on_destroy()
		end
	end

	self:_remove_attention_destroy_listener(self._attention)
end

function CopMovement:on_anim_act_clbk(anim_act)
	for body_part, action in ipairs(self._active_actions) do
		if action and action.anim_act_clbk then
			action:anim_act_clbk(anim_act)
		end
	end
end

function CopMovement:clbk_sync_attention(attention)
	if not alive(self._unit) or self._unit:id() == -1 then
		return
	end

	if self._attention ~= attention then
		return
	end

	if attention.handler then
		if attention.handler:unit():id() ~= -1 then
			self._ext_network:send("set_attention", attention.handler:unit(), attention.reaction)
		else
			self._ext_network:send("cop_set_attention_pos", mvector3.copy(attention.handler:get_attention_m_pos()))
		end
	elseif self._attention.unit and attention.unit:id() ~= -1 then
		self._ext_network:send("set_attention", self._attention.unit, AIAttentionObject.REACT_IDLE)
	end
end

function CopMovement:set_team(team_data)
	self._team = team_data

	self._ext_brain:on_team_set(team_data)

	if Network:is_server() and self._unit:id() ~= -1 then
		local team_index = tweak_data.levels:get_team_index(team_data.id)

		if team_index <= 256 then
			self._ext_network:send("sync_char_team", team_index)
		else
			debug_pause_unit(self._unit, "[CopMovement:set_team] team limit reached!", team_data.id)
		end
	end
end

function CopMovement:team()
	return self._team
end

function CopMovement:anim_clbk_open_parachute(unit)
	Application:debug("[CopMovement:anim_clbk_open_parachute]", unit)

	self._parachute_unit = safe_spawn_unit(Idstring("units/vanilla/props/props_parachute/props_parachute"), self._unit:position() + Vector3(0, 0, 100), self._unit:rotation())

	self._unit:link(Idstring("a_weapon_left_front"), self._parachute_unit, Idstring("rp_props_parachute"))
	self._parachute_unit:damage():run_sequence_simple("animation_unfold")
	managers.worldcollection:register_spawned_unit_on_last_world(self._parachute_unit)
end

function CopMovement:is_parachuting()
	return alive(self._parachute_unit) and not self._parachute_unit:unit_data().closed
end

function CopMovement:anim_clbk_close_parachute(unit)
	if managers.worldcollection.level_transition_in_progress then
		return
	end

	if alive(self._parachute_unit) and not self._parachute_unit:unit_data().closed then
		self._parachute_unit:unit_data().closed = true
		local position = self._parachute_unit:position()
		local rotation = self._parachute_unit:rotation()

		self._parachute_unit:unlink()

		if not unit then
			self._parachute_unit:damage():run_sequence_simple("make_dynamic_death")
		else
			self._parachute_unit:damage():run_sequence_simple("make_dynamic")
		end
	end
end

function CopMovement:enter_turret_animation(anim_name, callback)
	if not anim_name then
		if callback then
			callback()
		end
	else
		self._unit:set_driving("animation")
		self:play_redirect(anim_name)

		self._turret_enter_anim_callback = callback
	end
end

function CopMovement:on_anim_turret_enter_finished(unit, param1)
	self._active_actions = {
		false,
		false,
		false,
		false
	}

	self:set_attention()

	if self._turret_enter_anim_callback then
		self._turret_enter_anim_callback()
	end
end

function CopMovement:on_anim_turret_mg34_exit_finished(unit, param1)
	self._unit:inventory():show_equipped_unit()
end

function CopMovement:on_anim_turret_flakvierling_exit_finished(unit, param1)
	self._unit:inventory():show_equipped_unit()
end
