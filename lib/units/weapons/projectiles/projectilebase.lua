ProjectileBase = ProjectileBase or class(UnitBase)
ProjectileBase.time_cheat = {}
local mvec1 = Vector3()
local mvec2 = Vector3()
local mrot1 = Rotation()

-- Lines 10-30
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

-- Lines 34-53
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

-- Lines 57-59
function ProjectileBase:set_thrower_unit(unit)
	self._thrower_unit = unit
end

-- Lines 61-63
function ProjectileBase:thrower_unit()
	return alive(self._thrower_unit) and self._thrower_unit or nil
end

-- Lines 67-69
function ProjectileBase:set_thrower_peer_id(peer_id)
	self._thrower_peer_id = peer_id
end

-- Lines 71-73
function ProjectileBase:get_thrower_peer_id()
	return self._thrower_peer_id or nil
end

-- Lines 75-77
function ProjectileBase:set_parent_projectile_id(parent_projectile_id)
	self._parent_projectile_id = parent_projectile_id
end

-- Lines 79-81
function ProjectileBase:get_parent_projectile_id()
	return self._parent_projectile_id or nil
end

-- Lines 83-84
function ProjectileBase:get_aim_assist()
end

-- Lines 88-92
function ProjectileBase:set_weapon_unit(weapon_unit)
	self._weapon_unit = weapon_unit
	self._weapon_id = weapon_unit and weapon_unit:base():get_name_id()
	self._weapon_damage_mult = weapon_unit and weapon_unit:base().projectile_damage_multiplier and weapon_unit:base():projectile_damage_multiplier() or 1
end

-- Lines 94-96
function ProjectileBase:weapon_unit()
	return alive(self._weapon_unit) and self._weapon_unit or nil
end

-- Lines 100-102
function ProjectileBase:set_projectile_entry(projectile_entry)
	self._projectile_entry = projectile_entry
end

-- Lines 104-106
function ProjectileBase:projectile_entry()
	return self._projectile_entry or tweak_data.blackmarket:get_projectile_name_from_index(1)
end

-- Lines 108-110
function ProjectileBase:get_name_id()
	return alive(self._weapon_unit) and self._weapon_unit:base():get_name_id() or self._projectile_entry or self.name_id
end

-- Lines 114-117
function ProjectileBase:set_active(active)
	self._active = active

	self._unit:set_extension_update_enabled(Idstring("base"), self._active)
end

-- Lines 119-121
function ProjectileBase:active()
	return self._active
end

-- Lines 126-131
function ProjectileBase:create_sweep_data()
	self._sweep_data = {
		slot_mask = self._slot_mask,
		current_pos = self._unit:position()
	}
	self._sweep_data.last_pos = mvector3.copy(self._sweep_data.current_pos)
end

-- Lines 135-196
function ProjectileBase:throw(params)
	self._owner = params.owner
	local velocity = params.dir
	local adjust_z = 50
	local launch_speed = 250
	local push_at_body_index = nil

	if params.projectile_entry and tweak_data.projectiles[params.projectile_entry] then
		adjust_z = tweak_data.projectiles[params.projectile_entry].adjust_z or adjust_z
		local _adjust_z = tweak_data.projectiles[params.projectile_entry]._adjust_z or 0
		adjust_z = adjust_z + _adjust_z
		launch_speed = tweak_data.projectiles[params.projectile_entry].launch_speed or launch_speed
		push_at_body_index = tweak_data.projectiles[params.projectile_entry].push_at_body_index
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

	if params.projectile_entry and tweak_data.projectiles[params.projectile_entry] then
		local tweak_entry = tweak_data.projectiles[params.projectile_entry]
		local physic_effect = tweak_entry.physic_effect

		if physic_effect then
			World:play_physic_effect(physic_effect, self._unit)
		end

		if tweak_entry.throwable and tweak_entry.add_trail_effect then
			self:add_trail_effect(tweak_entry.add_trail_effect)
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

-- Lines 200-203
function ProjectileBase:sync_throw_projectile(dir, projectile_type)
	local projectile_entry = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type)

	self:throw({
		dir = dir,
		projectile_entry = projectile_entry
	})
end

-- Lines 207-245
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

			if self._draw_debug_impact then
				Draw:brush(Color(0.5, 0, 0, 1), nil, 10):sphere(col_ray.position, 4)
				Draw:brush(Color(0.5, 1, 0, 0), nil, 10):sphere(self._unit:position(), 3)
			end

			col_ray.velocity = self._unit:velocity()
			self._collided = true

			self:_on_collision(col_ray)
		end

		self._unit:m_position(self._sweep_data.last_pos)
	end
end

-- Lines 250-278
function ProjectileBase:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	if self._sweep_data and not self._collided then
		mvector3.set(mvec2, position)
		mvector3.subtract(mvec2, self._sweep_data.last_pos)
		mvector3.multiply(mvec2, 2)
		mvector3.add(mvec2, self._sweep_data.last_pos)

		local col_ray = World:raycast("ray", self._sweep_data.last_pos, mvec2, "slot_mask", self._sweep_data.slot_mask)

		if col_ray and col_ray.unit then
			if self._draw_debug_impact then
				Draw:brush(Color(0.5, 0, 0, 1), nil, 10):sphere(col_ray.position, 4)
				Draw:brush(Color(0.5, 1, 0, 0), nil, 10):sphere(self._unit:position(), 3)
			end

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

-- Lines 282-284
function ProjectileBase:_on_collision(col_ray)
	print("_on_collision", inspect(col_ray))
end

-- Lines 288-290
function ProjectileBase:_bounce(...)
	print("_bounce", ...)
end

-- Lines 294-299
function ProjectileBase:save(data)
	local state = {
		timer = self._timer
	}
	data.ProjectileBase = state
end

-- Lines 303-306
function ProjectileBase:load(data)
	local state = data.ProjectileBase
	self._timer = state.timer
end

-- Lines 310-311
function ProjectileBase:destroy()
end

local ids_object3d = Idstring("object3d")

-- Lines 318-379
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
	local unit_name = Idstring(not Network:is_server() and tweak_entry.local_unit or tweak_entry.unit)
	local rot_dir = tweak_entry._rot_dir or math.UP
	local unit = World:spawn_unit(unit_name, pos, Rotation(dir, rot_dir))

	for _, o in ipairs(unit:get_objects_by_type(ids_object3d)) do
		if o.set_skip_detail_distance_culling then
			o:set_skip_detail_distance_culling(true)
		end
	end

	if cooking_t and unit:base()._timer then
		unit:base()._timer = unit:base()._timer - cooking_t

		if unit:base()._timer < 0.3 then
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
		dir = dir,
		projectile_entry = projectile_entry
	})

	if unit:base().set_owner_peer_id then
		unit:base():set_owner_peer_id(owner_peer_id)
	end

	managers.network:session():send_to_peers_synched("sync_throw_projectile", unit:id() ~= -1 and unit or nil, pos, dir, projectile_type, owner_peer_id or 0, unit:base():get_parent_projectile_id())

	if tweak_data.projectiles[projectile_entry].impact_detonation then
		unit:damage():add_body_collision_callback(callback(unit:base(), unit:base(), "clbk_impact"))
		unit:base():create_sweep_data()
	end

	return unit
end

-- Lines 383-384
function ProjectileBase:add_trail_effect()
end

-- Lines 388-405
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

-- Lines 409-420
function ProjectileBase.spawn(unit_name, pos, rot)
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	return unit
end

-- Lines 424-425
function ProjectileBase._dispose_of_sound(...)
end

-- Lines 430-446
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

-- Lines 483-486
function ProjectileBase._explode_on_client(position, normal, user_unit, dmg, range, curve_pow, custom_params)
	managers.explosion:play_sound_and_effects(position, normal, range, custom_params)
	managers.explosion:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
end

-- Lines 514-516
function ProjectileBase._play_sound_and_effects(position, normal, range, custom_params)
	managers.explosion:play_sound_and_effects(position, normal, range, custom_params)
end
