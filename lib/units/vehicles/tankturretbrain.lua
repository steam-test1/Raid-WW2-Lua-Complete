TankTurretBrain = TankTurretBrain or class(SentryGunBrain)
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local tmp_vec1 = Vector3()

-- Lines 7-13
function TankTurretBrain:init(unit)
	TankTurretBrain.super.init(self, unit)

	self._locked_t = 0
	self._locked_on_attention = nil
	self._target_pos = Vector3()
	self._locked_phase = false
end

-- Lines 15-27
function TankTurretBrain:update(unit, t, dt)
	if self:is_locked() then
		self:_update_target_locked(t)
	else
		if Network:is_server() then
			self:_upd_detection(t)
			self:_select_focus_attention(t)
			self:_upd_flash_grenade(t)
			self:_upd_go_idle(t)
		end

		self:_upd_fire(t)
	end
end

-- Lines 29-36
function TankTurretBrain:_lock_on(attention)
	self._locked_phase = true
	local delta_t = self._tweak_data.turret.time_before_taking_shot
	self._locked_t = TimerManager:game():time() + delta_t
	self._locked_on_attention = attention
	self._locked_on_pos = attention.unit:position()

	self._unit:weapon():play_lock_on_sound()
end

-- Lines 38-40
function TankTurretBrain:is_locked(t)
	return not not self._locked_phase
end

-- Lines 42-46
function TankTurretBrain:_update_target_locked(t)
	if self._locked_t <= t then
		self:_fire_at_locked_position()
	end
end

-- Lines 48-55
function TankTurretBrain:_fire_at_locked_position()
	self._locked_phase = false

	if not alive(self._unit) then
		return
	end

	local expend_ammo = Network:is_server()

	self._unit:weapon():singleshot(false, expend_ammo, true, self._locked_on_pos)
end

-- Lines 58-119
function TankTurretBrain:_upd_fire(t)
	if not alive(self._unit) then
		return
	end

	if self._ext_movement:is_activating() or self._ext_movement:is_inactivating() or self._idle then
		if self._firing then
			self._unit:weapon():stop_autofire()

			self._firing = false
		end

		return
	end

	if not self._tweak_data then
		self._tweak_data = tweak_data.weapon[self._unit:base():get_name_id()]
	end

	local target_is_visible = self._ext_movement:is_target_visible()

	self:_upd_abandon_turret(t, target_is_visible)

	local attention = self._ext_movement:attention()

	if self._firing then
		Application:error("[TankTurretBrain:_upd_fire] Main tank turret marked as firing - shouldn't be possible since it uses singleshot and nor auto fire.")

		self._firing = false
	end

	if self._unit:weapon() and self._unit:weapon():out_of_ammo() then
		if self._unit:weapon():can_auto_reload() then
			self._firing = false

			if not self._ext_movement:rearming() then
				self._ext_movement:rearm()
			end
		end
	elseif self._ext_movement:rearming() then
		self._ext_movement:complete_rearming()
	elseif attention and attention.reaction and AIAttentionObject.REACT_SHOOT <= attention.reaction and not self._ext_movement:warming_up(t) then
		if attention.pos then
			mvec3_dir(tmp_vec1, self._ext_movement:m_head_pos(), attention.pos)
		elseif attention.unit:movement() then
			mvec3_dir(tmp_vec1, self._ext_movement:m_head_pos(), attention.unit:movement():m_head_pos())
		else
			mvec3_dir(tmp_vec1, self._ext_movement:m_head_pos(), attention.handler:get_detection_m_pos())
		end

		local max_dot = self._tweak_data.KEEP_FIRE_ANGLE
		max_dot = math.min(0.998, 1 - (1 - max_dot) * (self._shaprness_mul or 1))

		if target_is_visible and max_dot < mvec3_dot(tmp_vec1, self._ext_movement:m_head_fwd()) then
			self:_lock_on(attention)
		end
	end
end
