FlamerBrain = FlamerBrain or class(CopBrain)
FlamerBrain.UPDATE_INTERVAL = 2
FlamerBrain.ATTACK_INTERVAL = 0.5

-- Lines 6-8
function FlamerBrain:stealth_action_allowed()
	return false
end

-- Lines 10-20
function FlamerBrain:init(unit)
	FlamerBrain.super.init(self, unit)

	self._ukey = "flamer_" .. tostring(self._unit:key())

	managers.queued_tasks:queue(self._ukey, self.queued_update, self, nil, FlamerBrain.UPDATE_INTERVAL)

	self._old_t = Application:time()

	self._unit:sound_source():post_event("flamer_breathing_start")

	self.is_flamer = true
end

-- Lines 22-37
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

-- Lines 39-46
function FlamerBrain:queued_update()
	if not alive(self._unit) then
		return
	end

	local t = Application:time()
	local dt = t - self._old_t

	self:_queued_update(t, dt)
end

-- Lines 48-112
function FlamerBrain:_queued_update(t, dt)
	if self._current_logic_name == "inactive" then
		return
	end

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

	local assalut_target = nil
	local should_aquire_new_pos = false

	if #assault_candidates > 0 then
		assalut_target = assault_candidates[1]
		self._distance_to_target = mvector3.distance(assalut_target.pos, self._unit:position())

		self._unit:network():send("sync_distance_to_target", self._distance_to_target)

		if self._distance_to_target <= 600 and not self._pause_hunt then
			should_aquire_new_pos = true
			self._pause_hunt = true
		elseif self._distance_to_target > 600 then
			self._pause_hunt = false
			should_aquire_new_pos = true

			if self._old_assault_pos then
				local moved_dis = mvector3.distance(assalut_target.pos, self._old_assault_pos)

				if moved_dis < 250 then
					should_aquire_new_pos = false
				end
			end
		end
	end

	if should_aquire_new_pos then
		self._old_assault_pos = mvector3.copy(assalut_target.pos)
		local attack_objective = {
			type = "free",
			no_retreat = true,
			attitude = "engage"
		}

		self:set_objective(attack_objective)
		managers.queued_tasks:queue(nil, self._hunt, self, assalut_target, FlamerBrain.ATTACK_INTERVAL)
	end

	managers.queued_tasks:queue(self._ukey, self.queued_update, self, nil, FlamerBrain.UPDATE_INTERVAL)
end

-- Lines 114-116
function FlamerBrain:distance_to_target()
	return self._distance_to_target
end

-- Lines 118-134
function FlamerBrain:_hunt(assalut_target)
	if self._current_logic_name == "inactive" then
		return
	end

	if self._distance_to_target > 1200 then
		local objective = {
			type = "defend_area",
			area = assalut_target.area,
			nav_seg = assalut_target.nav_seg,
			pos = mvector3.copy(assalut_target.pos),
			no_retreat = true,
			attitude = "engage"
		}

		self:set_objective(objective)
	end
end

-- Lines 137-142
function FlamerBrain:clbk_death(my_unit, damage_info)
	FlamerBrain.super.clbk_death(self, my_unit, damage_info)
	self._unit:sound_source():post_event("flamer_breathing_break")
end

-- Lines 145-148
function FlamerBrain:pre_destroy(unit)
	managers.queued_tasks:unqueue_all(self._ukey, self)
	FlamerBrain.super.pre_destroy(self, unit)
end
