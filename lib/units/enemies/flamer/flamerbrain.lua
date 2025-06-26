FlamerBrain = FlamerBrain or class(CopBrain)
FlamerBrain.UPDATE_INTERVAL = 5
FlamerBrain.ATTACK_INTERVAL = 0.5

function FlamerBrain:stealth_action_allowed()
	return false
end

function FlamerBrain:init(unit)
	FlamerBrain.super.init(self, unit)

	self._ukey = "flamer_" .. tostring(self._unit:key())

	managers.queued_tasks:queue(self._ukey, self.queued_update, self, nil, 2)

	self.is_flamer = true
end

function FlamerBrain:add_pos_rsrv(rsrv_name, pos_rsrv)
	pos_rsrv.radius = pos_rsrv.radius * 2
	local pos_reservations = self._logic_data.pos_rsrv

	if pos_reservations[rsrv_name] then
		managers.navigation:unreserve_pos(pos_reservations[rsrv_name])
	end

	pos_rsrv.filter = self._logic_data.pos_rsrv_id

	managers.navigation:add_pos_reservation(pos_rsrv)

	pos_reservations[rsrv_name] = pos_rsrv

	if not pos_rsrv.id then
		debug_pause_unit(self._unit, "[CopBrain:add_pos_rsrv] missing id", inspect(pos_rsrv))

		return
	end
end

function FlamerBrain:queued_update()
	if not alive(self._unit) then
		return
	end

	if not self._physfix and self._unit:inventory() and self._unit:spawn_manager() then
		local weapon = self._unit:inventory():get_weapon()

		if alive(weapon) then
			for _, part_unit in pairs(self._unit:spawn_manager():get_spawned_units()) do
				weapon:base():add_ignore_unit(part_unit)

				self._physfix = true
			end
		end
	end

	self:_queued_update()
end

function FlamerBrain:_queued_update()
	if self._current_logic_name == "inactive" then
		return
	end

	local assault_target = nil
	local assault_candidates = {}
	local att_obj = self._logic_data.attention_obj

	if att_obj and att_obj.nav_tracker then
		local pos = att_obj.m_pos
		local nav_seg = att_obj.nav_tracker:nav_segment()
		local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)

		table.insert(assault_candidates, {
			area = area,
			nav_seg = nav_seg,
			pos = pos
		})
	else
		for criminal_key, criminal_data in pairs(managers.groupai:state():all_char_criminals()) do
			if not criminal_data.status then
				local pos = criminal_data.m_pos
				local nav_seg = criminal_data.tracker:nav_segment()
				local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)

				table.insert(assault_candidates, {
					area = area,
					nav_seg = nav_seg,
					pos = pos
				})
			end
		end
	end

	local should_aquire_new_pos = false

	if #assault_candidates > 0 then
		assault_target = assault_candidates[1]
		self._distance_to_target = mvector3.distance(assault_target.pos, self._unit:position())

		self._unit:network():send("sync_distance_to_target", self._distance_to_target)

		local HUNT_RANGE = 600
		local MIN_MOVE_DIST = 250

		if self._distance_to_target <= HUNT_RANGE and not self._pause_hunt then
			should_aquire_new_pos = true
			self._pause_hunt = true
		elseif HUNT_RANGE < self._distance_to_target then
			self._pause_hunt = false
			should_aquire_new_pos = true

			if self._old_assault_pos then
				local moved_dis = mvector3.distance(assault_target.pos, self._old_assault_pos)

				if moved_dis < MIN_MOVE_DIST then
					should_aquire_new_pos = false
				end
			end
		end
	end

	if should_aquire_new_pos then
		self._old_assault_pos = mvector3.copy(assault_target.pos)

		self:set_objective({
			type = "free",
			attitude = "engage"
		})
		managers.queued_tasks:queue(nil, self._hunt, self, assault_target, FlamerBrain.ATTACK_INTERVAL)
	end

	managers.queued_tasks:queue(self._ukey, self.queued_update, self, nil, FlamerBrain.UPDATE_INTERVAL)
end

function FlamerBrain:distance_to_target()
	return self._distance_to_target
end

function FlamerBrain:_hunt(assault_target)
	if self._current_logic_name == "inactive" then
		return
	end

	local DISTANCE_TOO_FAR = 800

	if DISTANCE_TOO_FAR < self:distance_to_target() then
		local objective = {
			attitude = "engage",
			type = "hunt",
			area = assault_target.area,
			nav_seg = assault_target.nav_seg,
			pos = mvector3.copy(assault_target.pos)
		}

		self:set_objective(objective)
	end
end

function FlamerBrain:pre_destroy(unit)
	managers.queued_tasks:unqueue_all(self._ukey, self)
	FlamerBrain.super.pre_destroy(self, unit)
end
