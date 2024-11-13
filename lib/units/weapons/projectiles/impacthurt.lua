ImpactHurt = ImpactHurt or class(ProjectileBase)
ImpactHurt._impact_units = {}
ImpactHurt.DEFUALT_SOUNDS = {
	impact = "arrow_impact_gen",
	flyby = "arrow_flyby",
	flyby_stop = "arrow_flyby_stop"
}
local ids_pickup = Idstring("pickup")
local mvec1 = Vector3()
local mrot1 = Rotation()
local tmp_vel = Vector3()
local tmp_vec1 = Vector3()

function ImpactHurt:_setup_from_tweak_data()
	local proj_entry = self.name_id or "cluster"
	self._tweak_data = tweak_data.projectiles[proj_entry]

	if not proj_entry or not self._tweak_data then
		debug_pause_unit(self._unit, "No projectile tweakdata entry for unit.", proj_entry, self._tweak_data)
	end

	self._range = self._tweak_data.range
	self._damage_class_string = tweak_data.projectiles[self.name_id].bullet_class or "InstantBulletBase"
	self._damage_class = CoreSerialize.string_to_classtable(self._damage_class_string)
	self._damage = self._tweak_data.damage or 1
	self._mass_look_up_modifier = self._tweak_data.mass_look_up_modifier
	self._slot_mask = managers.slot:get_mask("arrow_impact_targets")
end

function ImpactHurt:set_owner_peer_id(peer_id)
	if not peer_id then
		Application:warn("[ImpactHurt:set_owner_peer_id] Cannot set nil peer id", peer_id)

		return
	end

	self._owner_peer_id = peer_id
	ImpactHurt._impact_units[peer_id] = ImpactHurt._impact_units[peer_id] or {}
	ImpactHurt._impact_units[peer_id][self._unit:key()] = self._unit

	if not self._tweak_data.client_authoritative or self._tweak_data.client_authoritative and peer_id == managers.network:session():local_peer():id() then
		self._unit:add_body_activation_callback(callback(self, self, "clbk_body_activation"))
		self._unit:body("dynamic_body"):set_deactivate_tag(ids_pickup)
	end
end

function ImpactHurt:owner_peer_id()
	return self._owner_peer_id
end

function ImpactHurt:set_weapon_unit(weapon_unit)
	ImpactHurt.super.set_weapon_unit(self, weapon_unit)

	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
	self._weapon_charge_value = weapon_unit and weapon_unit:base().projectile_charge_value and weapon_unit:base():projectile_charge_value() or 1
	self._weapon_speed_mult = weapon_unit and weapon_unit:base().projectile_speed_multiplier and weapon_unit:base():projectile_speed_multiplier() or 1
	self._weapon_charge_fail = weapon_unit and weapon_unit:base():charge_fail() or false
end

function ImpactHurt:weapon_tweak_data()
	return tweak_data.projectiles[self.name_id]
end

function ImpactHurt:throw(...)
	self:_tweak_data_play_sound("flyby")

	self._requires_stop_flyby_sound = true

	ImpactHurt.super.throw(self, ...)

	local weapon_id = self:weapon_tweak_data().weapon_id

	if weapon_id then
		managers.statistics:shot_fired({
			name_id = nil,
			hit = false,
			name_id = weapon_id
		})
	end
end

function ImpactHurt:sync_throw_projectile(dir, projectile_type)
	Application:debug("[ImpactHurt:sync_throw_projectile]", projectile_type)
	self:throw({
		projectile_entry = nil,
		dir = nil,
		dir = dir,
		projectile_entry = projectile_type
	})
	self._unit:damage():add_body_collision_callback(callback(self._unit:base(), self._unit:base(), "clbk_impact"))
end

function ImpactHurt:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	ImpactHurt.super.clbk_impact(self, tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	Application:debug("[ImpactHurt:clbk_impact] tag", tag)

	if self._collided then
		return
	end

	if not self._is_pickup and not self._sweep_data then
		self._collided = true

		self:_check_stop_flyby_sound()

		if tweak_data.projectiles[self.name_id].remove_on_impact then
			Application:debug("[ImpactHurt:clbk_impact] DESTROYING")
			self._unit:set_enabled(false)
			self._unit:set_slot(0)

			return
		end
	end

	if self._unit:damage() then
		self._unit:damage():has_then_run_sequence_simple("show_pickup")
	end
end

function ImpactHurt:clbk_body_activation(tag, unit, body, activated)
	Application:info("[ImpactHurt] clbk_body_activation", tag, unit, body, activated)

	if not activated and tag == ids_pickup then
		local pos = self._unit:position()

		self:_on_collision({
			hit_position = nil,
			velocity = nil,
			ray = nil,
			normal = nil,
			position = nil,
			distance = 0,
			position = pos,
			hit_position = pos,
			normal = math.UP,
			ray = -math.UP,
			velocity = Vector3()
		})
	end
end

function ImpactHurt:_on_collision(col_ray)
	Application:debug("[ImpactHurt:_on_collision]")

	local damage_mult = self._weapon_damage_mult or 1
	local loose_shoot = self._weapon_charge_fail
	local damage_result = nil

	if not loose_shoot and alive(col_ray.unit) then
		local client_damage = self._damage_class.is_explosive_bullet or alive(col_ray.unit) and col_ray.unit:id() ~= -1

		if Network:is_server() or client_damage then
			damage_result = self._damage_class:on_collision(col_ray, self._weapon_unit or self._unit, self._thrower_unit, self._damage * damage_mult, false, false)
		end
	end

	local proj_tweak_data = tweak_data.projectiles[self.name_id]

	if not loose_shoot and proj_tweak_data.remove_on_impact and not proj_tweak_data.attach_on_collision then
		Application:debug("[ImpactHurt:_on_collision] DESTROYING")
		self._unit:set_slot(0)

		return
	end

	local dynamic_body = self._unit:body("dynamic_body")

	dynamic_body:set_deactivate_tag(Idstring())

	self._col_ray = col_ray
	local instant_dynamic_pickup = proj_tweak_data.attach_on_collision and loose_shoot or true

	self:_attach_to_hit_unit(nil, instant_dynamic_pickup)

	local new_vel = math.UP * dynamic_body:velocity():length() / 4
	new_vel = new_vel:with_x(dynamic_body:velocity().x / 5):with_y(dynamic_body:velocity().y / 5)

	dynamic_body:set_velocity(new_vel)
end

function ImpactHurt:add_damage_result(unit, attacker, is_dead, damage_percent)
	Application:info("[ImpactHurt:add_damage_result]", unit, attacker, is_dead, damage_percent)

	local weapon_id = self:weapon_tweak_data().weapon_id

	if weapon_id and not self._recorded_hit then
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			name_id = nil,
			hit = true,
			name_id = weapon_id
		})

		self._recorded_hit = true
	end
end

function ImpactHurt:update(unit, t, dt)
	if self._drop_in_sync_data then
		self._drop_in_sync_data.f = self._drop_in_sync_data.f - 1

		if self._drop_in_sync_data.f < 0 then
			local parent_unit = self._drop_in_sync_data.parent_unit

			if alive(parent_unit) then
				local state = self._drop_in_sync_data.state
				local parent_body = parent_unit:body(state.sync_attach_data.parent_body_index)
				local parent_obj = parent_body:root_object()

				self:sync_attach_to_unit(false, parent_unit, parent_body, parent_obj, state.sync_attach_data.local_pos, state.sync_attach_data.dir, true)
			end

			self._drop_in_sync_data = nil
		end
	end

	ImpactHurt.super.update(self, unit, t, dt)
end

function ImpactHurt:_calculate_autohit_direction()
	local enemies = managers.enemy:all_enemies()
	local pos = self._unit:position()
	local dir = self._unit:rotation():y()
	local closest_dis, closest_pos = nil

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit

		if enemy:base():lod_stage() == 1 and not enemy:in_slot(16) then
			local com = enemy:movement():m_head_pos()

			mvector3.direction(tmp_vec1, pos, com)

			local angle = mvector3.angle(dir, tmp_vec1)

			if angle < 30 then
				local dis = mvector3.distance_sq(pos, com)

				if not closest_dis or dis < closest_dis then
					closest_dis = dis
					closest_pos = com
				end
			end
		end
	end

	if closest_pos then
		mvector3.direction(tmp_vec1, pos, closest_pos)

		return tmp_vec1
	end
end

function ImpactHurt:switch_to_pickup_delayed(dynamic, delay, velocity)
	Application:debug("[ImpactHurt:switch_to_pickup_delayed] dynamic", dynamic)

	self._is_pickup = true
	self._is_pickup_dynamic = dynamic
	delay = delay or 1

	self:_remove_switch_to_pickup_clbk()

	local params = {
		dynamic = nil,
		velocity = nil,
		dynamic = dynamic,
		velocity = velocity
	}
	self._switch_to_pickup_clbk = "_switch_to_pickup " .. tostring(self._unit:key())

	managers.queued_tasks:queue(self._switch_to_pickup_clbk, self._switch_to_pickup_delay_cbk, self, params, delay)
end

function ImpactHurt:_switch_to_pickup_delay_cbk(params)
	self._switch_to_pickup_clbk = nil

	self:_switch_to_pickup(params.dynamic)

	if params.velocity then
		local dynamic_body = self._unit:body("dynamic_body")

		dynamic_body:set_velocity(params.velocity)
	end
end

function ImpactHurt:_switch_to_pickup(dynamic)
	self._is_pickup = true
	self._is_pickup_dynamic = dynamic

	self:_remove_switch_to_pickup_clbk()

	if dynamic then
		self._unit:unlink()
	end

	self._unit:set_slot(20)
	self._unit:set_enabled(true)
	self:_set_body_enabled(dynamic)
end

function ImpactHurt:_check_stop_flyby_sound(skip_impact)
	if self._requires_stop_flyby_sound then
		self._requires_stop_flyby_sound = nil

		self:_tweak_data_play_sound("flyby_stop")
	end

	if not skip_impact then
		self:_tweak_data_play_sound("impact")
	end
end

function ImpactHurt:_attach_to_hit_unit(is_remote, dynamic_pickup_wanted)
	self._attached_to_unit = true

	self._unit:set_enabled(true)
	self:_set_body_enabled(dynamic_pickup_wanted)
	self:_check_stop_flyby_sound(dynamic_pickup_wanted)
	mrotation.set_look_at(mrot1, self._col_ray.velocity, math.UP)
	self._unit:set_rotation(mrot1)

	local hit_unit = self._col_ray.unit
	local switch_to_pickup = true
	local switch_to_dynamic_pickup = dynamic_pickup_wanted or not alive(hit_unit)
	local local_pos = nil
	local global_pos = self._col_ray.position
	local parent_obj, child_obj, parent_body = nil

	if switch_to_dynamic_pickup then
		self._unit:set_position(global_pos)
		self._unit:set_position(global_pos)

		if alive(hit_unit) and hit_unit:character_damage() then
			self:_set_body_enabled(false)
		end

		self:_set_body_enabled(true)
	elseif alive(hit_unit) then
		local damage_ext = hit_unit:character_damage()

		if damage_ext and damage_ext.can_attach_projectiles and not damage_ext:can_attach_projectiles() then
			switch_to_dynamic_pickup = true
		elseif damage_ext and damage_ext.get_impact_segment then
			parent_obj, child_obj = damage_ext:get_impact_segment(self._col_ray.position)

			if parent_obj then
				if not child_obj then
					hit_unit:link(parent_obj:name(), self._unit, self._unit:orientation_object():name())
				else
					local parent_pos = parent_obj:position()
					local child_pos = child_obj:position()
					local segment_dir = Vector3()
					local segment_dist = mvector3.direction(segment_dir, parent_pos, child_pos)
					local collision_to_parent = Vector3()

					mvector3.set(collision_to_parent, global_pos)
					mvector3.subtract(collision_to_parent, parent_pos)

					local projected_dist = mvector3.dot(collision_to_parent, segment_dir)
					projected_dist = math.clamp(projected_dist, 0, segment_dist)
					local projected_pos = parent_pos + projected_dist * segment_dir
					local max_dist_from_segment = 10
					local dir_from_segment = Vector3()
					local dist_from_segment = mvector3.direction(dir_from_segment, projected_pos, global_pos)

					if max_dist_from_segment < dist_from_segment then
						global_pos = projected_pos + max_dist_from_segment * dir_from_segment
					end

					local_pos = (global_pos - parent_pos):rotate_with(parent_obj:rotation():inverse())
				end
			end

			if not hit_unit:character_damage():dead() then
				switch_to_pickup = false
			end
		elseif not alive(self._col_ray.body) or not self._col_ray.body:enabled() then
			local_pos = (global_pos - hit_unit:position()):rotate_with(hit_unit:rotation():inverse())
			switch_to_dynamic_pickup = true
		else
			parent_body = self._col_ray.body
			parent_obj = self._col_ray.body:root_object()
			local_pos = (global_pos - parent_obj:position()):rotate_with(parent_obj:rotation():inverse())
		end

		if damage_ext and not damage_ext:dead() and damage_ext.add_listener and not self._death_listener_id then
			self._death_listener_id = "ImpactHurt_death" .. tostring(self._unit:key())

			damage_ext:add_listener(self._death_listener_id, {
				"death"
			}, callback(self, self, "clbk_hit_unit_death"))
		end

		local has_destroy_listener = nil
		local hit_base = hit_unit:base()
		local listener_class = hit_base

		if listener_class and listener_class.add_destroy_listener then
			has_destroy_listener = true
		else
			listener_class = hit_unit:unit_data()

			if listener_class and listener_class.add_destroy_listener then
				has_destroy_listener = true
			end
		end

		if has_destroy_listener then
			self._destroy_listener_id = "ImpactHurt_destroy" .. tostring(self._unit:key())

			listener_class:add_destroy_listener(self._destroy_listener_id, callback(self, self, "clbk_hit_unit_destroyed"))
		end
	end

	self._unit:set_position(global_pos)
	self._unit:set_position(global_pos)

	if parent_obj then
		hit_unit:link(parent_obj:name(), self._unit)
	else
		Application:debug("[ImpactHurt]", "ImpactHurt:_attach_to_hit_unit(): No parent object!!")
	end

	if not switch_to_dynamic_pickup then
		local vip_unit = hit_unit and hit_unit:parent() or hit_unit

		if vip_unit and vip_unit:base() and vip_unit:base()._tweak_table == "phalanx_vip" then
			switch_to_pickup = true
			switch_to_dynamic_pickup = true
		end
	end

	if switch_to_pickup then
		if switch_to_dynamic_pickup then
			self:_set_body_enabled(true)
		end

		self:switch_to_pickup_delayed(switch_to_dynamic_pickup)
	end

	if alive(hit_unit) and parent_body then
		self._attached_body_disabled_cbk_data = {
			unit = nil,
			body = nil,
			cbk = nil,
			cbk = callback(self, self, "_cbk_attached_body_disabled"),
			unit = hit_unit,
			body = parent_body
		}

		hit_unit:add_body_enabled_callback(self._attached_body_disabled_cbk_data.cbk)
	end

	if not is_remote then
		local dir = self._col_ray.velocity

		mvector3.normalize(dir)

		if managers.network:session() then
			local unit = alive(hit_unit) and hit_unit:id() ~= -1 and hit_unit
			local params = {
				cosmetic_id = nil,
				dir = nil,
				parent_unit = nil,
				peer_id = nil,
				projectile_type_index = nil,
				parent_object = nil,
				instant_dynamic_pickup = nil,
				unit = nil,
				local_pos = nil,
				parent_body = nil,
				unit = self._unit:id() ~= -1 and self._unit or nil,
				instant_dynamic_pickup = dynamic_pickup_wanted or false,
				parent_unit = unit or nil,
				parent_body = unit and parent_body or nil,
				parent_object = unit and parent_obj or nil,
				local_pos = unit and local_pos or self._unit:position(),
				dir = dir,
				projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id(self.name_id),
				peer_id = managers.network:session():local_peer():id(),
				cosmetic_id = self._cosmetics_id
			}

			managers.queued_tasks:queue("delay_sync_attach" .. tostring(self._unit:key()), self._delay_sync_attach, self, params, 0.35)
		end
	end

	if alive(hit_unit) then
		local dir = self._col_ray.velocity

		mvector3.normalize(dir)

		if parent_body then
			local id = hit_unit:editor_id()

			if id ~= -1 then
				self._sync_attach_data = {
					parent_unit = nil,
					local_pos = nil,
					dir = nil,
					parent_unit_id = nil,
					parent_body = nil,
					parent_unit = hit_unit,
					parent_unit_id = id,
					parent_body = parent_body,
					local_pos = local_pos or self._unit:position(),
					dir = dir
				}
			end
		else
			local id = hit_unit:id()

			if id ~= -1 then
				local unit_alive = hit_unit:id() ~= -1
				self._sync_attach_data = {
					local_pos = nil,
					parent_unit = nil,
					character = true,
					dir = nil,
					parent_obj = nil,
					parent_body = nil,
					parent_unit = unit_alive and hit_unit or nil,
					parent_obj = unit_alive and parent_obj or nil,
					parent_body = unit_alive and parent_body or nil,
					local_pos = unit_alive and local_pos or self._unit:position(),
					dir = dir
				}
			end
		end
	end

	if self._unit:damage() and (is_remote or Network:is_server()) then
		self._unit:damage():has_then_run_sequence_simple("show_pickup")
	end
end

function ImpactHurt:sync_attach_to_unit(instant_dynamic_pickup, parent_unit, parent_body, parent_obj, local_pos, dir, drop_in)
	Application:debug("[ImpactHurt:sync_attach_to_unit] instant_dynamic_pickup", instant_dynamic_pickup)

	if parent_body then
		parent_obj = parent_body:root_object()
	end

	local world_position = nil

	if drop_in then
		world_position = self._unit:position()
		dir = self._unit:rotation():y()
	elseif parent_obj then
		world_position = local_pos:rotate_with(parent_obj:rotation()) + parent_obj:position()
	elseif alive(parent_unit) and parent_body then
		world_position = local_pos:rotate_with(parent_unit:rotation()) + parent_unit:position()
	else
		world_position = local_pos
	end

	self._col_ray = {
		body = nil,
		unit = nil,
		position = nil,
		velocity = nil,
		position = world_position,
		unit = parent_unit,
		body = parent_body,
		velocity = dir
	}

	if not parent_obj and not instant_dynamic_pickup then
		local col_ray = World:raycast("ray", world_position - 10 * dir, world_position + 10 * dir, "slot_mask", self._slot_mask, "ignore_unit", self._unit)

		if col_ray and col_ray.unit then
			self._col_ray = col_ray
			self._col_ray.velocity = dir

			if not drop_in and not self._damage_class.is_explosive_bullet and col_ray.unit:in_slot(managers.slot:get_mask("bullet_blank_impact_targets")) then
				self._damage_class:on_collision(col_ray, self:weapon_unit() or self._unit, self:thrower_unit(), self._damage, true)
			end
		end
	end

	self:_attach_to_hit_unit(true, instant_dynamic_pickup)
end

function ImpactHurt:_cbk_attached_body_disabled(unit, body)
	if not self._attached_body_disabled_cbk_data then
		Application:debug("[ImpactHurt]", "Got callback but didn't have data!")

		return
	end

	if self._attached_body_disabled_cbk_data.body ~= body then
		return
	end

	if not body:enabled() then
		self:_remove_attached_body_disabled_cbk()

		if not self._is_dynamic_pickup then
			self:_switch_to_pickup(true)
		end
	end
end

function ImpactHurt:_remove_attached_body_disabled_cbk()
	if self._attached_body_disabled_cbk_data and alive(self._attached_body_disabled_cbk_data.unit) then
		self._attached_body_disabled_cbk_data.unit:remove_body_enabled_callback(self._attached_body_disabled_cbk_data.cbk)
	end

	self._attached_body_disabled_cbk_data = nil
end

function ImpactHurt:_set_body_enabled(enabled)
	self._unit:body("dynamic_body"):set_enabled(enabled)

	if enabled then
		self._unit:body("dynamic_body"):set_dynamic()
	else
		self._unit:body("dynamic_body"):set_keyframed()
	end
end

function ImpactHurt:clbk_hit_unit_death()
	Application:debug("[ImpactHurt]", "ImpactHurt:clbk_hit_unit_death()")

	self._death_listener_id = nil

	self:_switch_to_pickup()
end

function ImpactHurt:clbk_hit_unit_destroyed()
	Application:debug("[ImpactHurt]", "ImpactHurt:clbk_hit_unit_destroyed()")

	self._destroy_listener_id = nil

	self:_switch_to_pickup(true)
end

function ImpactHurt:_tweak_data_play_sound(entry)
	Application:warn("[ImpactHurt:_tweak_data_play_sound] DISABLED")

	return

	local sounds = tweak_data.projectiles[self.name_id].sounds
	local event = sounds and sounds[entry] or ImpactHurt.DEFUALT_SOUNDS[entry]

	self._unit:sound_source(Idstring("snd")):post_event(event)
end

function ImpactHurt:outside_worlds_bounding_box()
	if Network:is_server() or self._unit:id() == -1 then
		Application:debug("[ImpactHurt:outside_worlds_bounding_box] DESTROYING")
		self._unit:set_slot(0)
	end
end

function ImpactHurt:_delay_load_attach(peer)
	Application:debug("[ImpactHurt:_delay_load_attach] peer", peer)

	if not managers.network:session() then
		return
	end

	if not peer then
		return
	end

	if not alive(self._sync_attach_data.parent_unit) then
		return
	end

	peer:send_queued_sync("sync_attach_projectile", self._unit:id() ~= -1 and self._unit or nil, false, self._sync_attach_data.parent_unit, nil, self._sync_attach_data.parent_obj, self._sync_attach_data.local_pos, self._sync_attach_data.dir, tweak_data.blackmarket:get_index_from_projectile_id(self.name_id), managers.network:session():local_peer():id(), self._cosmetics_id)
end

function ImpactHurt:_delay_sync_attach(params)
	if not managers.network:session() then
		return
	end

	Application:debug("[ImpactHurt:_delay_sync_attach] peer", params)
	managers.network:session():send_to_peers_synched("sync_attach_projectile", params.unit, params.instant_dynamic_pickup, params.parent_unit, params.parent_body, params.parent_object, params.local_pos, params.dir, params.projectile_type_index, params.peer_id, params.cosmetic_id)
end

function ImpactHurt:_remove_switch_to_pickup_clbk()
	if self._switch_to_pickup_clbk then
		managers.queued_tasks:unqueue(self._switch_to_pickup_clbk)

		self._switch_to_pickup_clbk = nil
	end
end

function ImpactHurt.find_nearest_impact_projectile(peer_id, position)
	local closest_unit, closest_dist_sq = nil

	if not ImpactHurt._impact_units or not ImpactHurt._impact_units[peer_id] then
		Application:debug("[ImpactHurt]", "ImpactHurt.find_nearest_impact_projectile - arrow not found!")
		Application:debug("[ImpactHurt]", inspect(ImpactHurt._impact_units))

		return
	end

	for key, unit in pairs(ImpactHurt._impact_units[peer_id]) do
		if unit:id() == -1 then
			unit:m_position(mvec1)

			local dist_sq = mvector3.distance_sq(position, mvec1)

			if not closest_unit or dist_sq < closest_dist_sq then
				closest_unit = unit
				closest_dist_sq = dist_sq
			end
		end
	end

	return closest_unit
end

function ImpactHurt:save(data)
	ImpactHurt.super.save(self, data)

	local state = {
		is_pickup = nil,
		owner_peer_id = nil,
		is_pickup_dynamic = nil,
		is_pickup = self._is_pickup,
		is_pickup_dynamic = self._is_pickup_dynamic,
		owner_peer_id = self._owner_peer_id
	}

	if not self._sync_attach_data then
		state.is_pickup = true
		state.is_pickup_dynamic = true
	end

	if not state.is_pickup_dynamic and self._sync_attach_data then
		if self._sync_attach_data.character then
			local peer = managers.network:session():dropin_peer()

			managers.queued_tasks:queue("delay_load_attach" .. tostring(self._unit:key()), self._delay_load_attach, self, peer, 0.1)
		else
			state.sync_attach_data = {
				parent_unit_id = nil,
				parent_unit_id = self._sync_attach_data.parent_unit_id
			}

			if self._sync_attach_data.parent_body then
				state.sync_attach_data.parent_body_index = self._sync_attach_data.parent_unit:get_body_index(self._sync_attach_data.parent_body:name())
			else
				Application:warn("[ImpactHurt] no parent body", self._sync_attach_data.parent_unit)
			end

			state.sync_attach_data.local_pos = self._sync_attach_data.local_pos
			state.sync_attach_data.dir = self._sync_attach_data.dir
		end
	end

	data.ImpactHurt = state
end

function ImpactHurt:load(data)
	ImpactHurt.super.load(self, data)

	local state = data.ImpactHurt

	self:set_owner_peer_id(state.owner_peer_id)

	if state.is_pickup then
		self:_switch_to_pickup(state.is_pickup_dynamic)
	end

	if not state.is_pickup_dynamic then
		Application:debug("[ImpactHurt]", inspect(state.sync_attach_data))

		if state.sync_attach_data then
			local function _dropin_attach(parent_unit)
				local parent_body = parent_unit:body(state.sync_attach_data.parent_body_index)
				local parent_obj = parent_body:root_object()
				self._drop_in_sync_data = {
					state = nil,
					parent_unit = nil,
					f = 2,
					parent_unit = parent_unit,
					state = state
				}
			end

			local parent_unit = managers.worlddefinition:get_unit_on_load(state.sync_attach_data.parent_unit_id, _dropin_attach)

			if alive(parent_unit) then
				_dropin_attach(parent_unit)
			end
		end
	end
end

function ImpactHurt:destroy(unit)
	self:_check_stop_flyby_sound(true)

	if self._owner_peer_id and ImpactHurt._impact_units[self._owner_peer_id] then
		ImpactHurt._impact_units[self._owner_peer_id][self._unit:key()] = nil
	end

	if self._death_listener_id and alive(self._col_ray.unit) then
		self._col_ray.unit:character_damage():remove_listener(self._death_listener_id)
	end

	self._death_listener_id = nil

	if self._destroy_listener_id and alive(self._col_ray.unit) then
		local has_listener = false
		local listener_class = self._col_ray.unit:base()

		if listener_class and listener_class.remove_destroy_listener then
			has_listener = true
		else
			listener_class = self._col_ray.unit:unit_data()

			if listener_class and listener_class.remove_destroy_listener then
				has_listener = true
			end
		end

		if has_listener then
			listener_class:remove_destroy_listener(self._destroy_listener_id)
		end
	end

	self._destroy_listener_id = nil

	self:_remove_switch_to_pickup_clbk()
	self:_remove_attached_body_disabled_cbk()
	ImpactHurt.super.destroy(self, unit)
end
