core:import("CoreMissionScriptElement")

ElementNavLink = ElementNavLink or class(CoreMissionScriptElement.MissionScriptElement)
ElementNavLink._AI_GROUPS = {
	"enemies",
	"friendlies",
	"civilians",
	"bank_manager_old_man",
	"escort_guy_1",
	"escort_guy_2",
	"escort_guy_3",
	"escort_guy_4",
	"escort_guy_5",
	"chavez"
}
ElementNavLink._PATHING_STYLES = {
	"destination",
	"precise",
	"coarse",
	"warp"
}
ElementNavLink._ATTITUDES = {
	"avoid",
	"engage"
}
ElementNavLink._TRIGGER_ON = {
	"interact"
}
ElementNavLink._INTERACTION_VOICES = {
	"default",
	"cuff_cop",
	"down_cop",
	"stop_cop",
	"escort_keep",
	"escort_go",
	"escort",
	"stop",
	"down_stay",
	"down",
	"bridge_codeword",
	"bridge_chair",
	"undercover_interrogate"
}
ElementNavLink._STANCES = {
	"ntl",
	"hos",
	"cbt"
}
ElementNavLink._POSES = {
	"crouch",
	"stand"
}
ElementNavLink._HASTES = {
	"walk",
	"run"
}
ElementNavLink._DEFAULT_VALUES = {
	base_chance = 1,
	chance_inc = 0,
	ai_group = 1,
	interval = 3,
	interaction_voice = 1,
	path_style = 1
}

-- Lines 22-28
function ElementNavLink:init(...)
	ElementNavLink.super.init(self, ...)
	self:_finalize_values(self._values)

	self._values = clone(self._values)
end

-- Lines 32-106
function ElementNavLink:_finalize_values(values)
	values.so_action = self:value("so_action")

	-- Lines 34-37
	local function _index_or_nil(table_in, name_in)
		local found_index = table.index_of(table_in, values[name_in])
		values[name_in] = found_index ~= -1 and found_index or nil
	end

	-- Lines 39-43
	local function _nil_if_default(name_in)
		if values[name_in] == self._DEFAULT_VALUES[name_in] then
			values[name_in] = nil
		end
	end

	-- Lines 45-49
	local function _nil_if_none(name_in)
		if values[name_in] == "none" then
			values[name_in] = nil
		end
	end

	-- Lines 51-53
	local function _save_boolean(name_in)
		values[name_in] = values[name_in] or nil
	end

	values.ai_group = table.index_of(self._AI_GROUPS, values.ai_group)

	_nil_if_default("ai_group")
	_nil_if_default("interval")
	_save_boolean("is_navigation_link")

	if values.align_position then
		_save_boolean("align_position")
		_save_boolean("align_rotation")
		_save_boolean("needs_pos_rsrv")
		_index_or_nil(ElementNavLink._PATHING_STYLES, "path_style")
		_index_or_nil(ElementNavLink._HASTES, "path_haste")
		_nil_if_none("patrol_path")
	else
		values.align_position = nil
		values.align_rotation = nil
		values.needs_pos_rsrv = nil
		values.path_style = nil
		values.path_haste = nil
		values.patrol_path = nil
	end

	values.rotation = mrotation.yaw(values.rotation)

	_nil_if_default("base_chance")

	if values.base_chance then
		_nil_if_default("chance_inc")
	else
		values.chance_inc = nil
	end

	_index_or_nil(ElementNavLink._TRIGGER_ON, "trigger_on")
	_index_or_nil(ElementNavLink._INTERACTION_VOICES, "interaction_voice")
	_save_boolean("repeatable")
	_save_boolean("forced")
	_save_boolean("no_arrest")
	_save_boolean("scan")
	_save_boolean("allow_followup_self")
	_index_or_nil(ElementNavLink._STANCES, "path_stance")
	_index_or_nil(ElementNavLink._POSES, "pose")
	_nil_if_none("so_action")
	_index_or_nil(ElementNavLink._ATTITUDES, "attitude")

	if values.followup_elements and not next(values.followup_elements) then
		values.followup_elements = nil
	end

	values.SO_access = managers.navigation:convert_access_filter_to_number(values.SO_access)
end

-- Lines 110-116
function ElementNavLink:event(name, unit)
	if self._events and self._events[name] then
		for _, callback in ipairs(self._events[name]) do
			callback(unit)
		end
	end
end

-- Lines 120-122
function ElementNavLink:clbk_objective_action_start(unit)
	self:event("anim_start", unit)
end

-- Lines 126-145
function ElementNavLink:clbk_objective_administered(unit)
	if self._values.needs_pos_rsrv then
		self._pos_rsrv = self._pos_rsrv or {}
		local unit_rsrv = self._pos_rsrv[unit:key()]

		if unit_rsrv then
			managers.navigation:unreserve_pos(unit_rsrv)
		else
			unit_rsrv = {
				radius = 30,
				position = self._values.align_position and self._values.position or unit:position()
			}
			self._pos_rsrv[unit:key()] = unit_rsrv
		end

		unit_rsrv.filter = unit:movement():pos_rsrv_id()

		managers.navigation:add_pos_reservation(unit_rsrv)
	end

	self._receiver_units = self._receiver_units or {}
	self._receiver_units[unit:key()] = unit

	self:event("administered", unit)
end

-- Lines 149-166
function ElementNavLink:clbk_objective_complete(unit)
	if self._pos_rsrv then
		local unit_rsrv = self._pos_rsrv[unit:key()]

		if unit_rsrv then
			managers.navigation:unreserve_pos(unit_rsrv)

			self._pos_rsrv[unit:key()] = nil
		end
	end

	if self._receiver_units then
		self._receiver_units[unit:key()] = nil

		if not next(self._receiver_units) then
			self._receiver_units = nil
		end
	end

	self:event("complete", unit)
end

-- Lines 170-190
function ElementNavLink:clbk_objective_failed(unit)
	if self._pos_rsrv then
		local unit_rsrv = self._pos_rsrv[unit:key()]

		if unit_rsrv then
			managers.navigation:unreserve_pos(unit_rsrv)

			self._pos_rsrv[unit:key()] = nil
		end
	end

	if self._receiver_units then
		self._receiver_units[unit:key()] = nil

		if not next(self._receiver_units) then
			self._receiver_units = nil
		end
	end

	if managers.editor and managers.editor._stopping_simulation then
		return
	end

	self:event("fail", unit)
end

-- Lines 194-207
function ElementNavLink:clbk_verify_administration(unit)
	if self._values.needs_pos_rsrv then
		self._tmp_pos_rsrv = self._tmp_pos_rsrv or {
			radius = 30,
			position = self._values.position
		}
		local pos_rsrv = self._tmp_pos_rsrv
		pos_rsrv.filter = unit:movement():pos_rsrv_id()

		if managers.navigation:is_pos_free(pos_rsrv) then
			return true
		else
			return false
		end
	end

	return true
end

-- Lines 211-215
function ElementNavLink:add_event_callback(name, callback)
	self._events = self._events or {}
	self._events[name] = self._events[name] or {}

	table.insert(self._events[name], callback)
end

-- Lines 219-244
function ElementNavLink:on_executed(instigator)
	if not self._values.enabled or Network:is_client() then
		return
	end

	if self._values.so_action then
		managers.navigation:register_anim_nav_link(self)
	else
		Application:error("[ElementNavLink:on_executed] Nav link without animation specified. Element id:", self._id)
	end

	ElementNavLink.super.on_executed(self, nil)
end

-- Lines 248-263
function ElementNavLink:operation_remove()
	if self._nav_link then
		managers.navigation:unregister_anim_nav_link(self)
	else
		managers.groupai:state():remove_special_objective(self:_unique_string_id())

		if self._receiver_units then
			local cpy = clone(self._receiver_units)

			for u_key, unit in pairs(cpy) do
				if self._receiver_units[u_key] and unit:brain():is_available_for_assignment() then
					unit:brain():set_objective(nil)
				end
			end
		end
	end
end

-- Lines 265-277
function ElementNavLink:destroy()
	ElementNavLink.super.destroy(self)
	managers.navigation:unregister_anim_nav_link(self)

	if self._pos_rsrv then
		for _, unit_rsrv in pairs(self._pos_rsrv) do
			managers.navigation:unreserve_pos(unit_rsrv)
		end

		self._pos_rsrv = nil
	end
end

-- Lines 281-346
function ElementNavLink:get_objective(instigator)
	local is_AI_SO = self._is_AI_SO or string.begins(self._values.so_action, "AI")
	local pose, stance, attitude, path_style, pos, rot, interrupt_dis, interrupt_health, haste, trigger_on, interaction_voice = self:_get_misc_SO_params()
	local objective = {
		type = "act",
		element = self,
		pos = pos,
		rot = rot,
		path_style = path_style,
		attitude = attitude,
		stance = stance,
		pose = pose,
		haste = haste,
		interrupt_dis = interrupt_dis,
		interrupt_health = interrupt_health,
		no_retreat = not interrupt_dis and not interrupt_health,
		trigger_on = trigger_on,
		interaction_voice = interaction_voice,
		followup_SO = self._values.followup_elements and self or nil,
		action_start_clbk = callback(self, self, "clbk_objective_action_start"),
		fail_clbk = callback(self, self, "clbk_objective_failed"),
		complete_clbk = callback(self, self, "clbk_objective_complete"),
		verification_clbk = callback(self, self, "clbk_verify_administration"),
		scan = self._values.scan,
		forced = self._values.forced,
		no_arrest = self._values.no_arrest
	}
	local action = nil

	if self._values.so_action then
		action = {
			align_sync = true,
			needs_full_blend = true,
			type = "act",
			body_part = 1,
			variant = self._values.so_action,
			blocks = {
				light_hurt = -1,
				hurt = -1,
				action = -1,
				heavy_hurt = -1,
				walk = -1
			}
		}
		objective.type = "act"
	else
		objective.type = "free"
	end

	objective.action = action

	if self._values.align_position then
		objective.nav_seg = managers.navigation:get_nav_seg_from_pos(self._values.position)

		if path_style == "destination" then
			local path_data = managers.ai_data:destination_path(self._values.position, Rotation(self._values.rotation or 0, 0, 0))
			objective.path_data = path_data
		else
			local path_name = self._values.patrol_path
			local path_data = managers.ai_data:patrol_path(path_name)
			objective.path_data = path_data
		end
	end

	return objective
end

-- Lines 350-367
function ElementNavLink:_get_misc_SO_params()
	local pose, stance, attitude, path_style, pos, rot, interrupt_dis, interrupt_health, haste, trigger_on, interaction_voice = nil
	local values = self._values
	pos = values.align_position and values.position or nil
	rot = values.align_position and values.align_rotation and Rotation(values.rotation, 0, 0) or nil
	path_style = values.align_position and self._PATHING_STYLES[self:_get_default_value_if_nil("path_style")] or nil
	attitude = self._ATTITUDES[values.attitude]
	stance = self._STANCES[values.path_stance]
	pose = self._POSES[values.pose]
	interrupt_health = 1
	haste = self._HASTES[values.path_haste]
	trigger_on = self._TRIGGER_ON[values.trigger_on] or nil
	interaction_voice = values.interaction_voice and self._INTERACTION_VOICES[values.interaction_voice]

	return pose, stance, attitude, path_style, pos, rot, -1, interrupt_health, haste, trigger_on, interaction_voice
end

-- Lines 371-373
function ElementNavLink:nav_link_end_pos()
	return self._values.search_position
end

-- Lines 377-379
function ElementNavLink:nav_link_access()
	return tonumber(self._values.SO_access)
end

-- Lines 383-385
function ElementNavLink:chance()
	return self:_get_default_value_if_nil("base_chance")
end

-- Lines 389-391
function ElementNavLink:nav_link_delay()
	return self:_get_default_value_if_nil("interval")
end

-- Lines 395-397
function ElementNavLink:nav_link()
	return self._nav_link
end

-- Lines 401-403
function ElementNavLink:id()
	return self._id
end

-- Lines 407-409
function ElementNavLink:_is_nav_link()
	return true
end

-- Lines 413-415
function ElementNavLink:set_nav_link(nav_link)
	self._nav_link = nav_link
end

-- Lines 419-421
function ElementNavLink:nav_link_wants_align_pos()
	return self._values.align_position
end

-- Lines 425-427
function ElementNavLink:get_objective_trigger()
	return self._values.trigger_on
end

-- Lines 431-465
function ElementNavLink:_administer_objective(unit, objective)
	if objective.type == "phalanx" then
		GroupAIStateBase:register_phalanx_unit(unit)
	end

	if objective.trigger_on == "interact" then
		if not unit:brain():objective() then
			local idle_objective = {
				type = "free",
				followup_objective = objective
			}

			unit:brain():set_objective(idle_objective)
		end

		unit:brain():set_followup_objective(objective)

		return
	end

	if self._values.forced or unit:brain():is_available_for_assignment(objective) or not unit:brain():objective() then
		if objective.area then
			local u_key = unit:key()
			local u_data = managers.enemy:all_enemies()[u_key]

			if u_data and u_data.assigned_area then
				managers.groupai:state():set_enemy_assigned(objective.area, u_key)
			end
		end

		unit:brain():set_objective(objective)
		self:clbk_objective_administered(unit)
	else
		unit:brain():set_followup_objective(objective)
	end
end

-- Lines 470-526
function ElementNavLink:choose_followup_SO(unit, skip_element_ids)
	if not self._values.followup_elements then
		return
	end

	if skip_element_ids == nil then
		if self._values.allow_followup_self and self:enabled() then
			skip_element_ids = {}
		else
			skip_element_ids = {
				[self._id] = true
			}
		end
	end

	if self._values.SO_access and unit and not managers.navigation:check_access(self._values.SO_access, unit:brain():SO_access(), 0) then
		return
	end

	local total_weight = 0
	local pool = {}
	local mission = self._sync_id ~= 0 and managers.worldcollection:mission_by_id(self._sync_id) or managers.mission

	for _, followup_element_id in ipairs(self._values.followup_elements) do
		local weight = nil
		local followup_element = mission:get_element_by_id(followup_element_id)

		if followup_element:enabled() then
			followup_element, weight = followup_element:get_as_followup(unit, skip_element_ids)

			if followup_element and followup_element:enabled() and weight > 0 then
				table.insert(pool, {
					element = followup_element,
					weight = weight
				})

				total_weight = total_weight + weight
			end
		end
	end

	if not next(pool) or total_weight <= 0 then
		return
	end

	local lucky_w = math.random() * total_weight
	local accumulated_w = 0

	for i, followup_data in ipairs(pool) do
		accumulated_w = accumulated_w + followup_data.weight

		if lucky_w <= accumulated_w then
			return pool[i].element
		end
	end
end

-- Lines 530-537
function ElementNavLink:get_as_followup(unit, skip_element_ids)
	if (not unit or managers.navigation:check_access(self._values.SO_access, unit:brain():SO_access(), 0) and self:clbk_verify_administration(unit)) and not skip_element_ids[self._id] then
		return self, self:_get_default_value_if_nil("base_chance")
	end

	self:event("admin_fail", unit)
end

-- Lines 541-543
function ElementNavLink:_get_default_value_if_nil(name_in)
	return self._values[name_in] or self._DEFAULT_VALUES[name_in]
end
