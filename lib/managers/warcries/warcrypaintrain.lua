WarcryPainTrain = WarcryPainTrain or class(Warcry)
WarcryPainTrain.WARCRY_BLOCKED_COLLISION_TEXT = "hud_warcry_blocked_pain_train"
WarcryPainTrain.CONE_OFFSET = 15
WarcryPainTrain.CONE_ANGLE = 70

function WarcryPainTrain:init()
	WarcryPainTrain.super.init(self)

	self._type = Warcry.PAIN_TRAIN
	self._tweak_data = tweak_data.warcry[self._type]
	self._slotmask_enemies = managers.slot:get_mask("enemies")

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

function WarcryPainTrain:update(dt)
	local lerp = WarcryPainTrain.super.update(self, dt)
	local distortion_a = managers.environment_controller:get_default_lens_distortion_value()
	local distortion_b = self._tweak_data.lens_distortion_value
	local distortion = math.lerp(distortion_a, distortion_b, lerp)

	managers.environment_controller:set_lens_distortion_power(distortion)
	self:_update_knockdown(dt)
end

function WarcryPainTrain:_update_knockdown(dt)
	if not alive(self._local_player) then
		return
	end

	local interrupt = false
	local enemies = self:_find_knockdown_enemies()

	for _, enemy in ipairs(enemies) do
		if not self._knockdown_units[enemy:key()] then
			local ignore_knockdown = self:_knockdown_unit(enemy)
			interrupt = interrupt or ignore_knockdown
		end
	end

	if interrupt then
		local remaining = managers.warcry:remaining()

		managers.warcry:add_remaining(-remaining)
		self:_play_hit_impact()
	end
end

function WarcryPainTrain:_find_knockdown_enemies()
	local player_camera = self._local_player:camera()
	local player_normal = player_camera:forward():normalized()
	local cone_radius = self._tweak_data.knockdown_distance * math.tan(self._knockdown_fov)
	local cone_tip = player_camera:position() - player_normal * self.CONE_OFFSET
	local cone_base = cone_tip + player_normal * self._tweak_data.knockdown_distance
	cone_base = cone_base + math.DOWN * WarcryPainTrain.CONE_ANGLE
	local enemies_in_cone = World:find_units_quick("cone", cone_tip, cone_base, cone_radius, self._slotmask_enemies)
	local enemies = {}

	for _, enemy in ipairs(enemies_in_cone) do
		local enemy_alive = alive(enemy) and enemy:character_damage() and not enemy:character_damage():dead()

		if enemy_alive then
			table.insert(enemies, enemy)
		end
	end

	return enemies
end

local knockback_normal = Vector3()

function WarcryPainTrain:_knockdown_unit(unit)
	local character_damage = unit:character_damage()
	local ignore_knockdown = character_damage.ignore_knockdown and character_damage:ignore_knockdown() or false
	local can_knockdown = not ignore_knockdown or self._knockdown_flamer

	if not can_knockdown then
		return ignore_knockdown
	end

	local from = unit:movement():m_head_pos()
	local to = self._local_player:movement():m_head_pos()
	local ray = World:raycast("ray", from, to, "target_unit", unit, "slot_mask", self._slotmask_enemies)

	if ray and CopDamage.skill_action_knockdown(unit, ray.position, ray.normal, "expl_hurt") then
		self._knockdown_units[unit:key()] = true

		managers.network:session():send_to_peers_synched("skill_action_knockdown", unit, ray.position, ray.normal, "expl_hurt")
		managers.warcry:add_remaining(-self._tweak_data.knockdown_fill_penalty)
		self:_play_hit_impact()

		local t = managers.player:player_timer():time()

		managers.player:get_current_state():knockdown_melee(t, ray)
	end

	return ignore_knockdown
end

function WarcryPainTrain:_play_hit_impact()
	local player_camera = self._local_player:camera()

	player_camera:play_shaker("player_land", 2 + math.random())
	self._local_player:sound():play("melee_hit_body")
	managers.rumble:play("melee_hit")
end

function WarcryPainTrain:activate()
	WarcryPainTrain.super.activate(self)
	managers.environment_effects:use("speed_lines")

	self._knockdown_units = {}
	self._knockdown_fov = managers.player:upgrade_value("player", "warcry_charge_knockdown_fov", 25)
	self._knockdown_flamer = managers.player:upgrade_value("player", "warcry_charge_knockdown_flamer", false)

	managers.player:set_player_state("charging")
end

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

function WarcryPainTrain:can_activate()
	local player_unit = managers.player:local_player()

	if not alive(player_unit) then
		return false
	end

	local current_state = managers.player:current_state()

	if current_state ~= "standard" and current_state ~= "carry" then
		return false
	end

	local slotmask_gnd_ray = managers.slot:get_mask("player_ground_check")
	local player_pos = player_unit:position()
	local down_offset_vec = math.DOWN * 250
	local down_pos = tmp_vec1

	mvector3.set(down_pos, player_pos)
	mvector3.add(down_pos, down_offset_vec)

	local ray = World:raycast("ray", player_pos, down_pos, "slot_mask", slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29, "report")

	if not ray then
		return false, WarcryManager.WARCRY_BLOCKED_AIR_TEXT
	end

	local hips_pos = tmp_vec1
	local fwd_pos = tmp_vec2
	local up_offset_vec = math.UP * 50
	local fwd_offset = 140

	mvector3.set(hips_pos, player_pos)
	mvector3.add(hips_pos, up_offset_vec)

	local cam_fwd = player_unit:camera():forward()

	mvector3.set(fwd_pos, cam_fwd)
	mvector3.set_z(fwd_pos, 0)
	mvector3.normalize(fwd_pos)

	local target_pos = hips_pos + fwd_pos * fwd_offset

	mvector3.add(target_pos, up_offset_vec)

	local ray = World:raycast("ray", hips_pos, target_pos, "slot_mask", slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29)

	if ray and alive(ray.body) and ray.body:collides_with_mover() then
		return false, self.WARCRY_BLOCKED_COLLISION_TEXT
	end

	return true
end

function WarcryPainTrain:activation_threshold()
	return managers.player:upgrade_value("player", "warcry_charge_activation_threshold", false)
end

function WarcryPainTrain:deactivate()
	WarcryPainTrain.super.deactivate(self)
	managers.environment_controller:reset_lens_distortion_value()
	managers.environment_effects:stop("speed_lines")

	if managers.player:current_state() == "charging" then
		managers.player:set_player_state("standard")
	end

	self._knockdown_fov = nil
	self._knockdown_flamer = nil
	self._local_player = nil
	self._knockdown_units = nil
end

function WarcryPainTrain:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)
end

function WarcryPainTrain:cleanup()
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
