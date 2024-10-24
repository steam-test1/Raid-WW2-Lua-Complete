ProjectileBase = ProjectileBase or class(UnitBase)
ProjectileBase.time_cheat = {}
local mvec1 = Vector3()
local mvec2 = Vector3()
local mrot1 = Rotation()

function ProjectileBase:init(unit)
	ProjectileBase.super.init(self, unit, true)

	self._unit = unit
	self._damage_results = {}
	self._spawn_position = self._unit:position()
	self._simulated = true
	self._orient_to_vel = true

	if self._setup_from_tweak_data then
		self:_setup_from_tweak_data()
	end

	if self._setup_server_data and Network:is_server() then
		self:_setup_server_data()
	end
end

function ProjectileBase:set_thrower_unit_by_peer_id(peer_id)
	if not peer_id then
		return
	end

	if managers.network:session() then
		local peer = managers.network:session():peer(peer_id)
		local thrower_unit = peer and peer:unit()

		if alive(thrower_unit) then
			self:set_thrower_unit(thrower_unit)
			self:set_thrower_peer_id(peer_id)
		end
	end
end

function ProjectileBase:set_thrower_unit(unit)
	self._thrower_unit = unit
end

function ProjectileBase:thrower_unit()
	return alive(self._thrower_unit) and self._thrower_unit or nil
end

function ProjectileBase:set_thrower_peer_id(peer_id)
	self._thrower_peer_id = peer_id
end

function ProjectileBase:get_thrower_peer_id()
	return self._thrower_peer_id or nil
end

function ProjectileBase:set_parent_projectile_id(parent_projectile_id)
	self._parent_projectile_id = parent_projectile_id
end

function ProjectileBase:get_parent_projectile_id()
	return self._parent_projectile_id or nil
end

function ProjectileBase:get_aim_assist()
end

function ProjectileBase:set_weapon_unit(weapon_unit)
	self._weapon_unit = weapon_unit
	self._weapon_id = weapon_unit and weapon_unit:base():get_name_id()
	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
end

function ProjectileBase:weapon_unit()
	return alive(self._weapon_unit) and self._weapon_unit or nil
end

function ProjectileBase:set_projectile_entry(projectile_entry)
	self._projectile_entry = projectile_entry
end

function ProjectileBase:projectile_entry()
	return self._projectile_entry or tweak_data.blackmarket:get_projectile_name_from_index(1)
end

function ProjectileBase:get_name_id()
	return alive(self._weapon_unit) and self._weapon_unit:base():get_name_id() or self._projectile_entry or self.name_id
end

function ProjectileBase:set_active(active)
	self._active = active

	self._unit:set_extension_update_enabled(Idstring("base"), self._active)
end

function ProjectileBase:active()
	return self._active
end

function ProjectileBase:create_sweep_data()
	self._sweep_data = {
		slot_mask = self._slot_mask,
		current_pos = self._unit:position()
	}
	self._sweep_data.last_pos = mvector3.copy(self._sweep_data.current_pos)
end

function ProjectileBase:throw(params)
	self._owner = params.owner
	local velocity = params.dir
	local adjust_z = 50
	local launch_speed = 250
	local push_at_body_index = nil
	local tweak_entry = params.projectile_entry and tweak_data.projectiles[type(params.projectile_entry) == "number" and tweak_data.blackmarket:get_projectile_name_from_index(params.projectile_entry) or params.projectile_entry]

	if tweak_entry then
		adjust_z = tweak_entry.adjust_z or adjust_z

		if tweak_entry.adjust_z_range then
			local adjust_z_range = tweak_entry.adjust_z_range
			adjust_z = math.rand(adjust_z_range[1], adjust_z_range[2])
		end

		local context_adjust_z = tweak_entry.context_adjust_z or 0
		adjust_z = adjust_z + context_adjust_z
		launch_speed = tweak_entry.launch_speed or launch_speed
		push_at_body_index = tweak_entry.push_at_body_index
	end

	velocity = velocity * launch_speed
	velocity = Vector3(velocity.x, velocity.y, velocity.z + adjust_z)
	local mass_look_up_modifier = self._mass_look_up_modifier or 2
	local mass = math.max(mass_look_up_modifier * (1 + math.min(0, params.dir.z)), 1)

	if self._simulated then
		if push_at_body_index then
			self._unit:push_at(mass, velocity, self._unit:body(push_at_body_index):center_of_mass())
		else
			self._unit:push_at(mass, velocity, self._unit:position())
		end
	else
		self._velocity = velocity
	end

	if tweak_entry then
		local physic_effect = tweak_entry.physic_effect

		if physic_effect then
			World:play_physic_effect(physic_effect, self._unit)
		end

		local unit_name = tweak_entry.sprint_unit

		if unit_name then
			local sprint = World:spawn_unit(Idstring(unit_name), self._unit:position(), self._unit:rotation())
			local rot = Rotation(params.dir, math.UP)

			mrotation.x(rot, mvec1)
			mvector3.multiply(mvec1, 0.25)
			mvector3.add(mvec1, params.dir)
			mvector3.add(mvec1, math.UP / 2)
			mvector3.multiply(mvec1, 100)
			sprint:push_at(mass, mvec1, sprint:position())
			self.modify_thrown_projectile(sprint)
		end

		self:set_projectile_entry(params.projectile_entry)
	end
end

function ProjectileBase:sync_throw_projectile(dir, projectile_type)
	local projectile_entry = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type)

	self:throw({
		projectile_entry = nil,
		dir = nil,
		dir = dir,
		projectile_entry = projectile_entry
	})
end

function ProjectileBase:update(unit, t, dt)
	if not self._simulated and not self._collided then
		self._unit:m_position(mvec1)
		mvector3.set(mvec2, self._velocity * dt)
		mvector3.add(mvec1, mvec2)
		self._unit:set_position(mvec1)

		if self._orient_to_vel then
			mrotation.set_look_at(mrot1, mvec2, math.UP)
			self._unit:set_rotation(mrot1)
		end

		self._velocity = Vector3(self._velocity.x, self._velocity.y, self._velocity.z - 980 * dt)
	end

	if self._sweep_data and not self._collided then
		self._unit:m_position(self._sweep_data.current_pos)

		local col_ray = World:raycast("ray", self._sweep_data.last_pos, self._sweep_data.current_pos, "slot_mask", self._sweep_data.slot_mask)

		if self._draw_debug_trail then
			Draw:brush(Color(1, 0, 0, 1), nil, 3):line(self._sweep_data.last_pos, self._sweep_data.current_pos)
		end

		if col_ray and col_ray.unit then
			mvector3.direction(mvec1, self._sweep_data.last_pos, self._sweep_data.current_pos)
			mvector3.add(mvec1, col_ray.position)
			self._unit:set_position(mvec1)
			self._unit:set_position(mvec1)

			col_ray.velocity = self._unit:velocity()
			self._collided = true

			self:_on_collision(col_ray)
		end

		self._unit:m_position(self._sweep_data.last_pos)
	end
end

function ProjectileBase:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._sweep_data and not self._collided then
		mvector3.set(mvec2, position)
		mvector3.subtract(mvec2, self._sweep_data.last_pos)
		mvector3.multiply(mvec2, 2)
		mvector3.add(mvec2, self._sweep_data.last_pos)

		local col_ray = World:raycast("ray", self._sweep_data.last_pos, mvec2, "slot_mask", self._sweep_data.slot_mask)

		if col_ray and col_ray.unit then
			mvector3.direction(mvec1, self._sweep_data.last_pos, col_ray.position)
			mvector3.add(mvec1, col_ray.position)
			self._unit:set_position(mvec1)
			self._unit:set_position(mvec1)

			col_ray.velocity = velocity
			self._collided = true

			self:_on_collision(col_ray)
		end
	end
end

function ProjectileBase:_on_collision(col_ray)
	print("_on_collision", inspect(col_ray))
end

function ProjectileBase:_bounce(...)
	print("_bounce", ...)
end

function ProjectileBase:save(data)
	local state = {
		timer = self._timer
	}
	data.ProjectileBase = state
end

function ProjectileBase:load(data)
	local state = data.ProjectileBase
	self._timer = state.timer
end

function ProjectileBase:destroy()
end

local ids_object3d = Idstring("object3d")

function ProjectileBase.throw_projectile(projectile_type, pos, dir, owner_peer_id, cooking_t, parent_projectile_id)
	if not projectile_type then
		Application:error("[ProjectileBase.throw_projectile] Trying to spawn an unknown projectile type: ", self._values.grenade_type, debug.traceback())

		return
	end

	local projectile_entry = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type)

	if not ProjectileBase.check_time_cheat(projectile_type, owner_peer_id) then
		return
	end

	local tweak_entry = tweak_data.projectiles[projectile_entry]
	local unit_name = Idstring(Network:is_server() and tweak_entry.unit or tweak_entry.local_unit)
	local rot_dir = tweak_entry.context_rot_dir or math.UP

	if not managers.dyn_resource:is_resource_ready(IDS_UNIT, unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		managers.dyn_resource:load(IDS_UNIT, unit_name, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
	end

	local unit = World:spawn_unit(unit_name, pos, Rotation(dir, rot_dir))

	managers.game_play_central:add_spawned_projectiles(unit)

	for _, o in ipairs(unit:get_objects_by_type(ids_object3d)) do
		if o.set_skip_detail_distance_culling then
			o:set_skip_detail_distance_culling(true)
		end
	end

	if cooking_t and unit:base()._timer then
		unit:base()._timer = unit:base()._timer - cooking_t

		if cooking_t == -1 then
			unit:base()._timer = 0.001
		elseif unit:base()._timer < 0.3 then
			unit:base()._timer = 0.3
		end
	end

	if owner_peer_id and managers.network:session() then
		local peer = managers.network:session():peer(owner_peer_id)
		local thrower_unit = peer and peer:unit()

		if alive(thrower_unit) then
			unit:base():set_thrower_unit(thrower_unit)
			unit:base():set_thrower_peer_id(owner_peer_id)

			if not tweak_entry.throwable and thrower_unit:movement() and thrower_unit:movement():current_state() then
				unit:base():set_weapon_unit(thrower_unit:movement():current_state()._equipped_unit)
			end
		end
	end

	if parent_projectile_id then
		unit:base():set_parent_projectile_id(parent_projectile_id)
	end

	unit:base():throw({
		projectile_entry = nil,
		dir = nil,
		dir = dir,
		projectile_entry = projectile_entry
	})

	if unit:base().set_owner_peer_id then
		unit:base():set_owner_peer_id(owner_peer_id)
	end

	managers.network:session():send_to_peers_synched("sync_throw_projectile", unit:id() ~= -1 and unit or nil, pos, dir, projectile_type, owner_peer_id or 0, unit:base():get_parent_projectile_id())

	if tweak_data.projectiles[projectile_entry].impact_detonation then
		Application:debug("[ProjectileBase.throw_projectile] Has impact detonation")
		unit:damage():add_body_collision_callback(callback(unit:base(), unit:base(), "clbk_impact"))
		unit:base():create_sweep_data()
	end

	return unit
end

function ProjectileBase.check_time_cheat(projectile_type, owner_peer_id)
	if not owner_peer_id then
		return true
	end

	local projectile_entry = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type)

	if tweak_data.projectiles[projectile_entry].time_cheat then
		ProjectileBase.time_cheat[projectile_type] = ProjectileBase.time_cheat[projectile_type] or {}

		if ProjectileBase.time_cheat[projectile_type][owner_peer_id] and Application:time() < ProjectileBase.time_cheat[projectile_type][owner_peer_id] then
			return false
		end

		ProjectileBase.time_cheat[projectile_type][owner_peer_id] = Application:time() + tweak_data.projectiles[projectile_entry].time_cheat
	end

	return true
end

function ProjectileBase.spawn(unit_name, pos, rot)
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	return unit
end

function ProjectileBase._dispose_of_sound(...)
end

function ProjectileBase:_detect_and_give_dmg(hit_pos)
	local params = {
		hit_pos = hit_pos,
		collision_slotmask = self._collision_slotmask,
		user = self._user,
		damage = self._damage,
		player_damage = self._player_damage or self._damage,
		range = self._range,
		ignore_unit = self._ignore_unit,
		curve_pow = self._curve_pow,
		col_ray = self._col_ray,
		alert_filter = self._alert_filter,
		owner = self._owner
	}
	local hit_units, splinters = managers.explosion:detect_and_give_dmg(params)

	return hit_units, splinters
end

function ProjectileBase._explode_on_client(position, normal, user_unit, dmg, range, curve_pow, custom_params)
	managers.explosion:play_sound_and_effects(position, normal, range, custom_params)
	managers.explosion:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
end

function ProjectileBase._play_sound_and_effects(position, normal, range, custom_params)
	managers.explosion:play_sound_and_effects(position, normal, range, custom_params)
end
