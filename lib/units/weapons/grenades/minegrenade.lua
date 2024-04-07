MineGrenade = MineGrenade or class(FragGrenade)

function MineGrenade:update(unit, t, dt)
	if self._hand_held then
		return
	end

	if self._planted and self._detonation_delay then
		self._detonation_delay = self._detonation_delay - dt

		if self._detonation_delay <= 0 then
			self:_detonate()

			return
		end
	elseif self._timer then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self:_attempt_arm()

			return
		end
	end

	if Network:is_server() then
		if self._planted and not self._detonation_delay then
			self:_filtered_check_targets()
		else
			self:_dyn_update(dt)
		end
	end

	GrenadeBase.super.update(self, unit, t, dt)
end

function MineGrenade:_award_achievement_multi_kill(thrower_peer_id)
	local achievement_id = "landmines_kill_some"

	if thrower_peer_id == 1 then
		managers.achievment:award(achievement_id)
	else
		local thrower_peer = managers.network:session():peer(thrower_peer_id)

		managers.network:session():send_to_peer(thrower_peer, "sync_award_achievement", achievement_id)
	end
end

function MineGrenade:_dyn_update(dt)
	local body = self._unit:body("body_dynamic")

	if body and body:enabled() then
		local unit_vel = body:velocity()
		local lerp_str = math.clamp(self._timer or 0 / self._init_timer, 0, 1)

		if lerp_str < 1 then
			local old_rot = body:rotation()
			local rotation = Rotation(old_rot:yaw(), math.lerp(-unit_vel.y * dt, old_rot:pitch(), lerp_str / 2 + 0.5), math.lerp(-unit_vel.x * dt, old_rot:roll(), lerp_str / 2 + 0.5))

			body:set_rotation(rotation)

			unit_vel = Vector3(unit_vel.x * lerp_str, unit_vel.y * lerp_str, unit_vel.z)

			body:set_velocity(unit_vel)
		end
	end
end

function MineGrenade:_attempt_arm()
	local body = self._unit:body("body_dynamic")

	if body and body:enabled() then
		local unit_vel = body:velocity()

		if unit_vel.z < 0.5 then
			self._timer = nil

			local pos = self._unit:position()
			local rot = self._unit:rotation()

			self._ray_from_pos = Vector3(pos.x, pos.y, pos.z + 50)
			self._planted = true

			if self._unit:damage():has_sequence("set_static") then
				self._unit:damage():run_sequence("set_static")
			end

			if managers.network:session() then
				managers.network:session():send_to_peers_synched("sync_grenade_freeze", self._unit, pos, rot)
			end
		end
	end
end

function MineGrenade:_force_arm()
	local body = self._unit:body("body_dynamic")

	if body and body:enabled() then
		self._timer = nil

		local pos = self._unit:position()
		local rot = self._unit:rotation()

		self._ray_from_pos = Vector3(pos.x, pos.y, pos.z + 50)
		self._planted = true

		if self._unit:damage():has_sequence("set_static") then
			self._unit:damage():run_sequence("set_static")
		end
	end
end

function MineGrenade:sync_grenade_freeze(pos, rot)
	self:_force_arm()
	self._unit:set_rotation(rot)
	self._unit:set_position(pos)
end

function MineGrenade:_filtered_check_targets()
	local is_enemy_near = self.super._filtered_check_targets(self)

	if is_enemy_near then
		self:_launch()
	end

	return is_enemy_near
end

function MineGrenade:_launch()
	if self._unit:damage():has_sequence("set_dynamic") then
		self._unit:damage():run_sequence("set_dynamic")
	end

	self._detonation_delay = self._tweak_data.enemy_proximity_delay or 0.4

	local body = self._unit:body("body_dynamic")

	body:set_velocity(Vector3(0, 0, self._tweak_data.jumpmine_velocity or 500))
end
