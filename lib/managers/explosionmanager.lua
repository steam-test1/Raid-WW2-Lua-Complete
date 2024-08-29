ExplosionManager = ExplosionManager or class()
ExplosionManager.SPLINTER_VECTOR_TABLE = {
	Vector3(1, 0, 0):normalized(),
	Vector3(-1, 0, 0):normalized(),
	Vector3(0, 1, 0):normalized(),
	Vector3(0, -1, 0):normalized(),
	Vector3(0, 0, 1):normalized(),
	Vector3(0, 0, -1):normalized()
}
local empty_idstr = Idstring("")
local idstr_explosion_std = Idstring("explosion_std")
local tmp_vec3 = Vector3()

function ExplosionManager:init()
	self._sustain_effects = {}
end

function ExplosionManager:update(t, dt)
	for i, effect in ipairs(self._sustain_effects) do
		if effect.expire_t < t then
			World:effect_manager():fade_kill(effect.id)
			table.remove(self._sustain_effects, i)
		end
	end
end

function ExplosionManager:add_sustain_effect(effect_id, sustain_time)
	table.insert(self._sustain_effects, {
		id = effect_id,
		expire_t = Application:time() + sustain_time
	})
end

function ExplosionManager:give_local_player_dmg(pos, range, damage, ignite_character)
	local player = managers.player:player_unit()

	if not player then
		return
	end

	local player_pos = player:oobb():center()
	local dist_sq = mvector3.distance_sq(player_pos, pos)

	if dist_sq > range * range then
		return
	end

	local explosion_block_slot_mask = managers.slot:get_mask("area_damage_blocker")
	local path_blocked = World:raycast("ray", pos, player_pos, "slot_mask", explosion_block_slot_mask, "ignore_unit", {
		player
	})

	if not path_blocked then
		Application:debug("[ExplosionManager] Damage player")
		player:character_damage():damage_explosion({
			variant = "explosion",
			position = pos,
			range = range,
			damage = damage,
			ignite_character = ignite_character
		})
	end
end

function ExplosionManager:detect_and_give_dmg(params)
	local hit_pos = params.hit_pos
	local slotmask = params.collision_slotmask
	local user_unit = params.user
	local dmg = params.damage
	local player_dmg = params.player_damage or dmg
	local range = params.range
	local ignore_unit = params.ignore_unit
	local curve_pow = params.curve_pow
	local col_ray = params.col_ray
	local alert_filter = params.alert_filter or managers.groupai:state():get_unit_type_filter("civilians_enemies")
	local owner = params.owner
	local push_units = params.push_units or true
	local results = {}
	local alert_radius = params.alert_radius or 10000
	local armor_piercing = params.armor_piercing
	local killzone_range = params.killzone_range

	mvector3.add(hit_pos, Vector3(0, 0, 5))

	local player = managers.player:player_unit()

	if alive(player) and player_dmg ~= 0 then
		player:character_damage():damage_explosion({
			variant = "explosion",
			position = hit_pos,
			range = range,
			damage = player_dmg,
			ignite_character = params.ignite_character
		})
	end

	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, slotmask)
	local alert_unit = user_unit

	if alert_unit and alert_unit:base() and alert_unit:base().thrower_unit then
		alert_unit = alert_unit:base():thrower_unit()
	end

	managers.groupai:state():propagate_alert({
		"explosion",
		hit_pos,
		alert_radius,
		alert_filter,
		alert_unit
	})

	local splinters = {
		mvector3.copy(hit_pos)
	}
	local splinter_pos = Vector3()

	for _, dir in ipairs(ExplosionManager.SPLINTER_VECTOR_TABLE) do
		mvector3.set(splinter_pos, dir)
		mvector3.multiply(splinter_pos, range)
		mvector3.add(splinter_pos, hit_pos)

		local splinter_ray = nil

		if ignore_unit then
			splinter_ray = World:raycast("ray", hit_pos, splinter_pos, "ignore_unit", ignore_unit, "slot_mask", slotmask)
		else
			splinter_ray = World:raycast("ray", hit_pos, splinter_pos, "slot_mask", slotmask)
		end

		splinter_pos = (splinter_ray and splinter_ray.position or splinter_pos) - dir * math.min(splinter_ray and splinter_ray.distance or 0, 10)
		local near_splinter = false

		for _, s_pos in ipairs(splinters) do
			if mvector3.distance_sq(splinter_pos, s_pos) < 900 then
				near_splinter = true

				break
			end
		end

		if not near_splinter then
			table.insert(splinters, mvector3.copy(splinter_pos))
		end
	end

	local count_cops = 0
	local count_gangsters = 0
	local count_civilians = 0
	local count_cop_kills = 0
	local count_gangster_kills = 0
	local count_civilian_kills = 0
	local characters_hit = {}
	local units_to_push = {}
	local hit_units = {}
	local type = nil

	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		local ignore_unit_list = {
			hit_body:unit()
		}

		if hit_unit:spawn_manager() then
			for _, unit in ipairs(hit_unit:spawn_manager():get_spawned_units()) do
				table.insert(ignore_unit_list, unit)
			end
		end

		if hit_unit:slot() ~= 14 then
			units_to_push[hit_unit:key()] = hit_unit
		end

		local character = hit_unit:character_damage() and hit_unit:character_damage().damage_explosion and not hit_unit:character_damage():dead()
		local apply_dmg = hit_body:extension() and hit_body:extension().damage
		local dir, len, damage, ray_hit, damage_character = nil

		if character and not characters_hit[hit_unit:key()] then
			if params.no_raycast_check_characters then
				ray_hit = true
				damage_character = true
				characters_hit[hit_unit:key()] = true
			else
				local body_pos = hit_unit:oobb():center()
				local explosion_source_pos = hit_pos
				local explosion_block_slot_mask = managers.slot:get_mask("area_damage_blocker")
				local path_blocked = World:raycast("ray", explosion_source_pos, body_pos, "slot_mask", explosion_block_slot_mask, "ignore_unit", {
					hit_unit,
					owner
				})

				if not path_blocked then
					for i_splinter, s_pos in ipairs(splinters) do
						local destination_pos = body_pos
						ray_hit = not World:raycast("ray", s_pos, destination_pos, "slot_mask", slotmask, "ignore_unit", ignore_unit_list, "report")

						if ray_hit then
							characters_hit[hit_unit:key()] = true
							damage_character = true

							break
						end
					end
				end
			end

			if ray_hit then
				local hit_unit = hit_unit

				if hit_unit:base() and hit_unit:base()._tweak_table and not hit_unit:character_damage():dead() then
					type = hit_unit:base()._tweak_table

					if CopDamage.is_civilian(type) then
						count_civilians = count_civilians + 1
					elseif CopDamage.is_gangster(type) then
						count_gangsters = count_gangsters + 1
					else
						count_cops = count_cops + 1
					end
				end
			end
		elseif apply_dmg or hit_body:dynamic() then
			ray_hit = true
		end

		if ignore_unit and hit_unit == ignore_unit then
			ray_hit = false
		end

		if ray_hit then
			dir = hit_body:center_of_mass()
			len = mvector3.direction(dir, hit_pos, dir)

			if armor_piercing then
				damage = dmg
			elseif killzone_range and killzone_range > len / range then
				damage = dmg
			else
				damage = dmg * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow)
			end

			if apply_dmg then
				self:_apply_body_damage(true, hit_body, user_unit, dir, damage, armor_piercing)
			end

			damage = math.max(damage, 1)
			local hit_unit = hit_unit
			hit_units[hit_unit:key()] = hit_unit

			if character and damage_character then
				local dead_before = hit_unit:character_damage():dead()
				local action_data = {
					variant = "explosion",
					damage = damage,
					attacker_unit = user_unit,
					weapon_unit = owner,
					col_ray = self._col_ray or {
						position = hit_body:position(),
						ray = dir,
						body = hit_body
					},
					ignite_character = params.ignite_character
				}

				hit_unit:character_damage():damage_explosion(action_data)

				if not dead_before and hit_unit:base() and hit_unit:base()._tweak_table and hit_unit:character_damage():dead() then
					type = hit_unit:base()._tweak_table

					if CopDamage.is_civilian(type) then
						count_civilian_kills = count_civilian_kills + 1
					elseif CopDamage.is_gangster(type) then
						count_gangster_kills = count_gangster_kills + 1
					else
						count_cop_kills = count_cop_kills + 1
					end
				end
			end
		end
	end

	if push_units then
		managers.explosion:units_to_push(units_to_push, hit_pos, range)
	end

	if owner then
		results.count_cops = count_cops
		results.count_gangsters = count_gangsters
		results.count_civilians = count_civilians
		results.count_cop_kills = count_cop_kills
		results.count_gangster_kills = count_gangster_kills
		results.count_civilian_kills = count_civilian_kills
	end

	return hit_units, splinters, results
end

function ExplosionManager:units_to_push(units_to_push, hit_pos, range)
	for u_key, unit in pairs(units_to_push) do
		if alive(unit) then
			local is_character = unit:character_damage() and unit:character_damage().damage_explosion

			if not is_character or unit:character_damage():dead() then
				if is_character and unit:movement() and unit:movement()._active_actions and unit:movement()._active_actions[1] and unit:movement()._active_actions[1]:type() == "hurt" then
					unit:movement()._active_actions[1]:force_ragdoll()
				end

				local nr_u_bodies = unit:num_bodies()
				local rot_acc = Vector3(1 - math.rand(2), 1 - math.rand(2), 1 - math.rand(2)) * 10
				local i_u_body = 0

				while nr_u_bodies > i_u_body do
					local u_body = unit:body(i_u_body)

					if u_body:enabled() and u_body:dynamic() then
						local body_mass = u_body:mass()
						local len = mvector3.direction(tmp_vec3, hit_pos, u_body:center_of_mass())
						local body_vel = u_body:velocity()
						local vel_dot = mvector3.dot(body_vel, tmp_vec3)
						local max_vel = 800

						if vel_dot < max_vel then
							mvector3.set_z(tmp_vec3, mvector3.z(tmp_vec3) + 0.75)

							local push_vel = (1 - len / range) * (max_vel - math.max(vel_dot, 0))

							mvector3.multiply(tmp_vec3, push_vel)
							World:play_physic_effect(tweak_data.physics_effects.body_explosion, u_body, tmp_vec3, body_mass / math.random(2), u_body:position(), rot_acc, 1)
						end
					end

					i_u_body = i_u_body + 1
				end
			end
		end
	end
end

function ExplosionManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage, armor_piercing)
	local hit_unit = hit_body:unit()
	local local_damage = is_server or hit_unit:id() == -1
	local sync_damage = is_server and hit_unit:id() ~= -1

	if not local_damage and not sync_damage then
		print("_apply_body_damage skipped")

		return
	end

	local normal = dir
	local prop_damage = math.min(damage, 200)

	if prop_damage < 0.25 then
		prop_damage = math.round(prop_damage, 0.25)
	end

	if prop_damage == 0 then
		-- Nothing
	end

	if prop_damage > 0 then
		local local_damage = is_server or hit_unit:id() == -1
		local sync_damage = is_server and hit_unit:id() ~= -1
		local network_damage = math.ceil(prop_damage * 163.84)
		prop_damage = network_damage / 163.84

		if local_damage then
			hit_body:extension().damage:damage_explosion(user_unit, normal, hit_body:position(), dir, prop_damage, armor_piercing)
			hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
		end

		if sync_damage and managers.network:session() then
			if hit_body:position():length() > 90000 then
				debug_pause("[ExplosionManager][_apply_body_damage] Position of the hit body is outside of alowed range and wouldn't be transportable through the network: ", inspect(hit_body), hit_body:position())

				return
			end

			if alive(user_unit) then
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion", hit_body, user_unit, normal, hit_body:position(), dir, math.min(32768, network_damage), armor_piercing)
			else
				managers.network:session():send_to_peers_synched("sync_body_damage_explosion_no_attacker", hit_body, normal, hit_body:position(), dir, math.min(32768, network_damage), armor_piercing)
			end
		end
	end
end

function ExplosionManager:explode_on_client(position, normal, user_unit, dmg, range, curve_pow, custom_params)
	self:play_sound_and_effects(position, normal, range, custom_params)
	self:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
end

function ExplosionManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow, armor_piercing)
	local bodies = World:find_bodies("intersect", "sphere", position, range, managers.slot:get_mask("bullet_impact_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		local hit_unit = hit_body:unit()
		units_to_push[hit_body:unit():key()] = hit_unit
		local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_unit:id() == -1
		local dir, len, damage = nil

		if apply_dmg then
			dir = hit_body:center_of_mass()
			len = mvector3.direction(dir, position, dir)
			damage = dmg * math.pow(math.clamp(1 - len / range, 0, 1), curve_pow)

			self:_apply_body_damage(false, hit_body, user_unit, dir, damage, armor_piercing)
		end
	end

	self:units_to_push(units_to_push, position, range)
end

function ExplosionManager:play_sound_and_effects(position, normal, range, custom_params, molotov_damage_effect_table)
	self:player_feedback(position, normal, range, custom_params)
	self:spawn_sound_and_effects(position, normal, range, custom_params and custom_params.effect, custom_params and custom_params.sound_event, custom_params and custom_params.on_unit, custom_params and custom_params.idstr_decal, custom_params and custom_params.idstr_effect, molotov_damage_effect_table)
end

function ExplosionManager:player_feedback(position, normal, range, custom_params)
	local player = managers.player:player_unit()

	if not player then
		return
	end

	local range = custom_params and custom_params.feedback_range or range
	local feedback = managers.feedback:create("mission_triggered")
	local player_position = player:position()
	local distance = mvector3.distance_sq(position, player_position)
	local mul = math.clamp(1 - distance / (range * range), 0, 1)
	local camera_shake_mul = custom_params and custom_params.camera_shake_mul or mul * (custom_params and custom_params.camera_shake_max_mul or 1)

	if player:movement():in_steelsight() then
		local weapon = player:inventory():equipped_unit()
		camera_shake_mul = camera_shake_mul * managers.player:upgrade_value(weapon:base():category(), "steelsight_hit_flinch_reduction", 1)
	end

	feedback:set_unit(player)
	feedback:set_enabled("camera_shake", true)
	feedback:set_enabled("rumble", true)
	feedback:set_enabled("above_camera_effect", false)

	local params = {
		"camera_shake",
		"multiplier",
		camera_shake_mul,
		"camera_shake",
		"amplitude",
		0.5,
		"camera_shake",
		"attack",
		0.05,
		"camera_shake",
		"sustain",
		0.15,
		"camera_shake",
		"decay",
		0.5,
		"rumble",
		"multiplier_data",
		mul,
		"rumble",
		"peak",
		0.5,
		"rumble",
		"attack",
		0.05,
		"rumble",
		"sustain",
		0.15,
		"rumble",
		"release",
		0.5
	}

	feedback:play(unpack(params))

	if custom_params and custom_params.sound_muffle_effect then
		local sound_eff_range = range / 4
		local sound_eff_mul = math.clamp(1 - distance / (sound_eff_range * sound_eff_range), 0, 1)

		if sound_eff_mul >= 0.3 then
			player:character_damage():on_flashbanged(sound_eff_mul)
		end
	end
end

local decal_ray_from = Vector3()
local decal_ray_to = Vector3()

function ExplosionManager:spawn_sound_and_effects(position, normal, range, effect_name, sound_event, on_unit, idstr_decal, idstr_effect, molotov_damage_effect_table)
	effect_name = effect_name or "effects/vanilla/explosions/exp_projectile_001"
	local effect_id = nil
	local effect_idstring = Idstring(effect_name)

	if effect_name ~= "none" then
		effect_id = World:effect_manager():spawn({
			effect = effect_idstring,
			position = position,
			normal = normal
		})
	end

	if molotov_damage_effect_table ~= nil then
		table.insert(molotov_damage_effect_table, {
			effect_id = effect_id,
			detonation_position = position,
			detonation_normal = normal
		})
	end

	local slotmask_world_geometry = managers.slot:get_mask("world_geometry")

	if on_unit then
		mvector3.set(decal_ray_from, position)
		mvector3.set(decal_ray_to, normal)
		mvector3.multiply(decal_ray_to, 100)
		mvector3.add(decal_ray_from, decal_ray_to)
		mvector3.multiply(decal_ray_to, -2)
		mvector3.add(decal_ray_to, decal_ray_from)
	else
		mvector3.set(decal_ray_from, position)
		mvector3.set(decal_ray_to, math.UP)
		mvector3.multiply(decal_ray_to, -100)
		mvector3.add(decal_ray_to, decal_ray_from)
	end

	local ray = World:raycast("ray", decal_ray_from, decal_ray_to, "slot_mask", slotmask_world_geometry)
	local sound_switch_name = nil

	if ray then
		local material_name, _, _ = World:pick_decal_material(ray.unit, decal_ray_from, decal_ray_to, slotmask_world_geometry)
		sound_switch_name = material_name ~= empty_idstr and material_name
	end

	if effect_idstring == tweak_data.common_effects.fire_molotov_grenade and molotov_damage_effect_table ~= nil and #molotov_damage_effect_table <= 1 or effect_idstring ~= tweak_data.common_effects.fire_molotov_grenade then
		sound_event = sound_event or "trip_mine_explode"

		if sound_event ~= "no_sound" then
			local sound_source = SoundDevice:create_source("ExplosionManager")

			sound_source:set_position(position)

			if sound_switch_name then
				sound_source:set_switch("materials", managers.game_play_central:material_name(sound_switch_name))
			end

			sound_source:post_event(sound_event)
			managers.enemy:add_delayed_clbk("ExplosionManager", callback(ProjectileBase, ProjectileBase, "_dispose_of_sound", {
				sound_source = sound_source
			}), TimerManager:game():time() + 4)
		end
	end

	self:project_decal(ray, decal_ray_from, decal_ray_to, on_unit and ray and ray.unit, idstr_decal, idstr_effect)
end

function ExplosionManager:project_decal(ray, from, to, on_unit, idstr_decal, idstr_effect)
	local slotmask_world_geometry = managers.slot:get_mask("world_geometry")

	if ray then
		local units = on_unit or World:find_units("intersect", "cylinder", from, to, 100, slotmask_world_geometry)
		local redir_name = World:project_decal(idstr_decal or idstr_explosion_std, ray.position, ray.ray, on_unit or units, nil, ray.normal)

		if redir_name ~= empty_idstr then
			World:effect_manager():spawn({
				effect = redir_name,
				position = ray.position,
				normal = ray.normal
			})
		end

		if idstr_effect and idstr_effect ~= empty_idstr then
			local id = World:effect_manager():spawn({
				effect = idstr_effect,
				position = ray.position,
				normal = ray.normal
			})

			self:add_sustain_effect(id, 2 + math.rand(3))
		end
	end
end
