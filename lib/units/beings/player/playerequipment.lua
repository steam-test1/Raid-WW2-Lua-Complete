PlayerEquipment = PlayerEquipment or class()

function PlayerEquipment:init(unit)
	self._unit = unit
end

function PlayerEquipment:on_deploy_interupted()
	if alive(self._dummy_unit) then
		World:delete_unit(self._dummy_unit)

		self._dummy_unit = nil
	end
end

function PlayerEquipment:valid_look_at_placement(equipment_data)
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * 200
	local ray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})

	if ray and equipment_data and equipment_data.dummy_unit then
		local pos = ray.position
		local rot = Rotation(ray.normal, math.UP)

		if not alive(self._dummy_unit) then
			self._dummy_unit = World:spawn_unit(Idstring(equipment_data.dummy_unit), pos, rot)

			self:_disable_contour(self._dummy_unit)
		end

		self._dummy_unit:set_position(pos)
		self._dummy_unit:set_rotation(rot)
	end

	if alive(self._dummy_unit) then
		self._dummy_unit:set_enabled(ray and true or false)
	end

	return ray
end

function PlayerEquipment:valid_placement(equipment_data)
	local valid = not self._unit:movement():current_state():in_air()
	local pos = self._unit:movement():m_pos()
	local rot = self._unit:movement():m_head_rot()
	rot = Rotation(rot:yaw(), 0, 0)

	if equipment_data and equipment_data.dummy_unit then
		if not alive(self._dummy_unit) then
			self._dummy_unit = World:spawn_unit(Idstring(equipment_data.dummy_unit), pos, rot)

			self:_disable_contour(self._dummy_unit)
		end

		self._dummy_unit:set_position(pos)
		self._dummy_unit:set_rotation(rot)

		if alive(self._dummy_unit) then
			self._dummy_unit:set_enabled(valid)
		end
	end

	return valid
end

local ids_contour_color = Idstring("contour_color")
local ids_contour_opacity = Idstring("contour_opacity")

function PlayerEquipment:_disable_contour(unit)
	local materials = unit:get_objects_by_type(IDS_MATERIAL)

	for _, m in ipairs(materials) do
		m:set_variable(ids_contour_opacity, 0)
	end
end

function PlayerEquipment:_spawn_dummy(dummy_name, pos, rot)
	if alive(self._dummy_unit) then
		return self._dummy_unit
	end

	self._dummy_unit = World:spawn_unit(Idstring(dummy_name), pos, rot)

	for i = 0, self._dummy_unit:num_bodies() - 1 do
		self._dummy_unit:body(i):set_enabled(false)
	end

	return self._dummy_unit
end

function PlayerEquipment:valid_shape_placement(equipment_id, equipment_data)
	local from = self._unit:movement():m_head_pos()
	local to = from + self._unit:movement():m_head_rot():y() * 220
	local ray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
	local valid = ray and true or false

	if ray then
		local pos = ray.position
		local rot = self._unit:movement():m_head_rot()
		rot = Rotation(rot:yaw(), 0, 0)

		if not alive(self._dummy_unit) then
			self._dummy_unit = World:spawn_unit(Idstring(equipment_data.dummy_unit), pos, rot)

			self:_disable_contour(self._dummy_unit)
		end

		self._dummy_unit:set_position(pos)
		self._dummy_unit:set_rotation(rot)

		valid = valid and math.dot(ray.normal, math.UP) > 0.25
		local find_start_pos, find_end_pos, find_radius = nil

		if equipment_id == "ammo_bag" then
			find_start_pos = pos + math.UP * 20
			find_end_pos = pos + math.UP * 21
			find_radius = 12
		elseif equipment_id == "doctor_bag" then
			find_start_pos = pos + math.UP * 22
			find_end_pos = pos + math.UP * 28
			find_radius = 15
		else
			find_start_pos = pos + math.UP * 30
			find_end_pos = pos + math.UP * 40
			find_radius = 17
		end

		local bodies = self._dummy_unit:find_bodies("intersect", "capsule", find_start_pos, find_end_pos, find_radius, managers.slot:get_mask("trip_mine_placeables") + 14 + 25)

		for _, body in ipairs(bodies) do
			if body:unit() ~= self._dummy_unit and body:has_ray_type(Idstring("body")) then
				valid = false

				break
			end
		end
	end

	if alive(self._dummy_unit) then
		self._dummy_unit:set_enabled(valid)
	end

	return valid and ray
end

function PlayerEquipment:throw_projectile()
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_data = tweak_data.projectiles[projectile_entry]
	local from = self._unit:movement():m_head_pos()
	local pos = from + self._unit:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
	local dir = self._unit:movement():m_head_rot():y()

	if projectile_data.throw_shout ~= false then
		local say_line = projectile_data.throw_shout or "player_throw_grenade"

		self._unit:sound():say(say_line, nil, true)
	end

	local projectile_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_entry)
	local cosmetic_id = managers.weapon_inventory:get_weapons_skin(equipped_grenade)

	if Network:is_server() or projectile_data.client_authoritative then
		local peer_id = managers.network:session():local_peer():id()

		ProjectileBase.throw_projectile(projectile_index, pos, dir, peer_id, nil, cosmetic_id)
		managers.player:verify_grenade(peer_id)
	else
		managers.network:session():send_to_host("request_throw_projectile", projectile_index, pos, dir, 0, cosmetic_id)
	end

	managers.player:on_throw_grenade()
end

function PlayerEquipment:throw_grenade()
	local equipped_grenade = managers.blackmarket:equipped_grenade()
	local projectile_data = tweak_data.projectiles[equipped_grenade]
	local from = self._unit:movement():m_head_pos()
	local pos = from + self._unit:movement():m_head_rot():y() * 30 + Vector3(0, 0, 0)
	local dir = self._unit:movement():m_head_rot():y()
	local weapon_data = tweak_data.weapon[equipped_grenade]

	if weapon_data.throw_shout ~= false then
		local say_line = weapon_data.throw_shout or "player_throw_grenade"

		self._unit:sound():say(say_line, nil, true)
	end

	local grenade_index = tweak_data.blackmarket:get_index_from_projectile_id(equipped_grenade)
	local cooking_t = self._cooking_start and Application:time() - self._cooking_start
	local cosmetic_id = managers.weapon_inventory:get_weapons_skin(equipped_grenade)

	if Network:is_server() or projectile_data.client_authoritative then
		local peer_id = managers.network:session():local_peer():id()

		ProjectileBase.throw_projectile(grenade_index, pos, dir, peer_id, cooking_t, nil, cosmetic_id)
		managers.player:verify_grenade(peer_id)
	else
		managers.network:session():send_to_host("request_throw_projectile", grenade_index, pos, dir, cooking_t, cosmetic_id)
	end

	self._cooking_start = nil

	managers.player:on_throw_grenade()
end

function PlayerEquipment:from_server_sentry_gun_place_result()
	self._sentrygun_placement_requested = nil
end

function PlayerEquipment:destroy()
	if alive(self._dummy_unit) then
		World:delete_unit(self._dummy_unit)

		self._dummy_unit = nil
	end
end
