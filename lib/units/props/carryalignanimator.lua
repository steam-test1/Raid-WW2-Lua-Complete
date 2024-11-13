CarryAlignAnimator = CarryAlignAnimator or class()
CarryAlignAnimator.MIN_SPEED = 0.1
CarryAlignAnimator.SNAP_CAP = 0.98
CarryAlignAnimator.SPEED_DISTANCE = 0.0065
CarryAlignAnimator.DEFAULT_ALIGN = "align_bag_"

function CarryAlignAnimator:init(unit)
	self._unit = unit
	self._loot_align_table = {}

	if self.loot_align_table then
		for _, value in ipairs(self.loot_align_table) do
			local values = string.split(value, ";")

			if values and #values == 2 then
				self._loot_align_table[values[1]] = values[2]
			else
				Application:warn("[CarryAlignAnimator:init()] Bad loot align table value:", value)
			end
		end
	end

	self._animating_loots = {}
	self._loot_props = {}

	self:set_update_enabled_state(false)
end

function CarryAlignAnimator:update(unit, t, dt)
	self:_update_loot_animations(t)

	if table.empty(self._animating_loots) then
		self:set_update_enabled_state(false)
	end
end

function CarryAlignAnimator:trigger_store_carry(instigator)
	Application:warn("[CarryAlignAnimator:trigger_store_carry] THIS IS NOT COMPLETELY TESTED!! Instigator:", instigator)

	local carry_data = managers.player:get_my_carry_data()[1]

	if not carry_data then
		Application:warn("[CarryAlignAnimator:trigger_store_carry()] Attempted to store unit that has no carry data!")

		return
	else
		Application:debug("[CarryAlignAnimator:trigger_store_carry()] carry_id:", carry_data.carry_id)
	end

	local player = managers.player:player_unit()

	if player then
		local carry_tweak = tweak_data.carry[carry_data.carry_id]

		if carry_tweak and carry_tweak.throw_sound then
			player:sound():play(carry_tweak.throw_sound, nil, false)
		end
	end

	local position, rotation = managers.player:carry_align_throw()

	self:client_store_carry({
		position = nil,
		rotation = nil,
		position = position,
		rotation = rotation
	}, carry_data.carry_id)
end

function CarryAlignAnimator:server_remove_carry(carry_id)
	if Network:is_server() then
		Application:debug("[CarryAlignAnimator:server_remove_carry] Is server: carry_id:", carry_id)
		managers.network:session():send_to_peers_synched("sync_pile_remove_carry", carry_id)
		self:client_remove_carry(carry_id)
	end
end

function CarryAlignAnimator:client_remove_carry(carry_id)
	Application:debug("[CarryAlignAnimator:client_remove_carry] carry_id:", carry_id)

	local unit = self:get_slot_unit(carry_id, nil, true)

	if alive(unit) then
		unit:set_slot(0)
	else
		Application:warn("[CarryAlignAnimator:client_remove_carry] Server attempted to remove unit that was not alive!", unit, carry_id)
	end
end

function CarryAlignAnimator:server_store_carry(carry_unit)
	if Network:is_server() and alive(carry_unit) then
		local carry_id = self._get_carry_unit_carry_id(carry_unit)

		self:client_store_carry(carry_unit, carry_id)
	else
		Application:warn("[CarryAlignAnimator:server_store_carry] Server attempted to store carry unit that was not alive!", carry_unit)
	end
end

function CarryAlignAnimator:client_store_carry(carry_unit, carry_id)
	Application:debug("[CarryAlignAnimator:client_store_carry] Attempting to store '" .. (carry_id or "NIL") .. "' item...")

	if type(carry_unit) == "userdata" and not alive(carry_unit) and type(carry_unit) == "table" and table.empty(carry_unit) then
		Application:error("[CarryAlignAnimator:client_store_carry] Attempted to store unit that was not valid!", carry_unit)

		return
	end

	if not carry_id then
		Application:error("[CarryAlignAnimator:client_store_carry] Attempted to store a carry item without carry id")

		return
	end

	local tweak_align = self._loot_align_table and self._loot_align_table[carry_id] or CarryAlignAnimator.DEFAULT_ALIGN

	if not tweak_align then
		Application:error("[CarryAlignAnimator:client_store_carry] No tweak_align data for '" .. carry_id .. "'!")

		return
	end

	local slot_index = self:get_slot_index(carry_id) + 1
	local align_idstr = Idstring(tweak_align .. tostring(slot_index))
	local align_object = self._unit:get_object(align_idstr)

	if align_object then
		local prop_unit = nil

		if Network:is_server() then
			local unit_static_path = self._get_carry_unit_static(carry_id)

			Application:debug("[CarryAlignAnimator:client_store_carry] Host is creating '" .. carry_id .. "' prop unit.")

			local pos, rot = nil

			if type(carry_unit) == "table" then
				rot = carry_unit.rotation or Rotation(0, 0, 0)
				pos = carry_unit.position or Vector3(0, 0, 0)
			else
				rot = carry_unit:rotation()
				pos = carry_unit:position()
			end

			prop_unit = safe_spawn_unit(Idstring(unit_static_path), pos, rot)

			managers.network:session():send_to_peers_synched("sync_pile_store_carry", self._unit, prop_unit, carry_id)
		else
			Application:debug("[CarryAlignAnimator:client_store_carry] Loading '" .. carry_id .. "' prop unit from hosts given unit.", carry_unit)

			prop_unit = carry_unit
		end

		if prop_unit.damage and prop_unit:damage():has_sequence("freeze") then
			prop_unit:damage():run_sequence_simple("freeze")
		end

		Application:debug("[CarryAlignAnimator:client_store_carry] Aligning to '" .. tostring(align_idstr) .. "'.")
		self:add_slot_unit(carry_id, prop_unit)

		local distance = mvector3.distance(prop_unit:position(), self._unit:get_object(align_idstr):position())
		local duration = CarryAlignAnimator.SPEED_DISTANCE * distance

		table.insert(self._animating_loots, {
			slot_index = nil,
			duration = nil,
			unit = nil,
			align_idstr = nil,
			carry_id = nil,
			slot_index = slot_index,
			unit = prop_unit,
			align_idstr = align_idstr,
			carry_id = carry_id,
			duration = duration
		})
		self:set_update_enabled_state(true)
	else
		Application:warn("[CarryAlignAnimator:client_store_carry] No alignment for '" .. tostring(align_idstr) .. "'.")
	end

	Application:debug("[CarryAlignAnimator:client_store_carry] Animation setup success for '" .. carry_id .. "'!")
end

function CarryAlignAnimator._get_carry_unit_static(carry_id)
	return carry_id and tweak_data.carry[carry_id].unit_static
end

function CarryAlignAnimator._get_carry_unit_carry_id(carry_unit)
	return carry_unit and carry_unit:carry_data():carry_id()
end

local completed_anims = {}

function CarryAlignAnimator:_update_loot_animations(t)
	for i = #self._animating_loots, 1, -1 do
		local data = self._animating_loots[i]
		local unit = data.unit
		local slot_index = data.slot_index

		if alive(unit) then
			local duration = data.duration

			if not data.start_time then
				data.start_time = t
			end

			local real_timer = t - data.start_time
			local lerp_timer = real_timer / duration
			local lerp_time = math.clamp(lerp_timer, CarryAlignAnimator.MIN_SPEED, 1)

			if CarryAlignAnimator.SNAP_CAP <= lerp_time then
				table.remove(self._animating_loots, i)
				table.insert(completed_anims, {
					unit,
					data.align_idstr,
					data.carry_id,
					slot_index
				})
			else
				local align = self._unit:get_object(data.align_idstr)

				if align then
					unit:set_position(math.lerp(unit:position(), align:position(), lerp_time * lerp_time))
					unit:set_rotation(math.rotation_lerp(unit:rotation(), align:rotation(), lerp_time))
				end
			end
		else
			table.insert(completed_anims, {
				data.unit,
				data.align_point,
				data.carry_id,
				slot_index
			})
			table.remove(self._animating_loots, i)
		end
	end

	for _, data in ipairs(completed_anims) do
		self:_done_store_carry(unpack(data))
	end

	completed_anims = {}
end

function CarryAlignAnimator:_done_store_carry(unit, align_idstr, carry_id, slot_index)
	if alive(unit) then
		Application:debug("[CarryAlignAnimator:_done_store_carry()]", slot_index, carry_id, align_idstr, unit)

		if align_idstr then
			local align_object = self._unit:get_object(align_idstr)

			if not align_object then
				Application:warn("[CarryAlignAnimator:_done_store_carry()] Unit doesnt have object for '" .. align_idstr .. "' align_idstr.")

				return
			end

			self._unit:link(align_idstr, unit, unit:orientation_object():name(), true)

			if unit.damage and unit:damage():has_sequence("make_static") then
				unit:damage():run_sequence_simple("make_static")
			end
		end
	else
		Application:warn("[CarryAlignAnimator:_done_store_carry] Cannot handle dead unit", unit, align_idstr, carry_id, slot_index)
	end
end

function CarryAlignAnimator:add_slot_unit(carry_id, prop_unit)
	local list = self._loot_props[carry_id]

	self:set_slot_unit(carry_id, list and #list + 1 or 1, prop_unit)
end

function CarryAlignAnimator:set_slot_unit(carry_id, slot, prop_unit)
	if not self._loot_props[carry_id] then
		self._loot_props[carry_id] = {}
	end

	local list = self._loot_props[carry_id]

	if prop_unit and alive(prop_unit) then
		if list[slot] then
			list[slot]:set_slot(0)
			Application:warn("[CarryAlignAnimator:set_slot_prop_unit()] Tried to set slot '" .. slot .. "' that already had a prop_unit for '" .. carry_id .. "'!")
		end

		list[slot] = prop_unit
	else
		list[slot] = nil
	end

	Application:debug("[CarryAlignAnimator:set_slot_unit()]", carry_id, slot, inspect(self._loot_props[carry_id]))
end

function CarryAlignAnimator:get_slot_unit(carry_id, slot, consume)
	local list = self._loot_props[carry_id]

	if list then
		slot = slot or #list
		local unit = list and list[slot]

		if consume then
			table.remove(self._loot_props[carry_id], slot)
		end

		return unit
	end

	return nil
end

function CarryAlignAnimator:get_slot_index(carry_id)
	local list = self._loot_props[carry_id]

	return list and #list or 0
end

function CarryAlignAnimator:get_units_slot_index(carry_id, unit)
	local list = self._loot_props[carry_id] or {}

	for i, data in ipairs(list) do
		if unit:id() == data:id() then
			return i
		end
	end

	Application:debug("[CarryAlignAnimator:set_slot_unit()] Fallback to 0 empty list", carry_id)

	return 0
end

function CarryAlignAnimator:set_update_enabled_state(state)
	self._unit:set_extension_update_enabled(Idstring("carry_align"), state)
end

function CarryAlignAnimator:destroy()
	self:clear_all_visual_props()
end

function CarryAlignAnimator:clear_all_visual_props()
	for _, data in pairs(self._loot_props) do
		for _, unit in ipairs(data) do
			if alive(unit) then
				Application:debug("[CarryAlignAnimator:clear_all_visual_props()] unit alive, destroying", unit)
				unit:set_slot(0)
			end
		end
	end
end

function CarryAlignAnimator:save(data)
	local state = {}
	data.CarryAlignAnimator = state

	if self._loot_props then
		state.loot_props = {}

		for carry_id, data in pairs(self._loot_props) do
			state.loot_props[carry_id] = state.loot_props[carry_id] or {}

			for _, unit in ipairs(data) do
				if alive(unit) then
					table.insert(state.loot_props[carry_id], unit:id())
				end
			end
		end
	end
end

function CarryAlignAnimator:load(data)
	local state = data.CarryAlignAnimator

	if state.loot_props then
		for carry_id, prop_units in pairs(state.loot_props) do
			for _, prop_unit_id in ipairs(prop_units) do
				local prop_unit = managers.worldcollection:__get_unit_with_real_id(prop_unit_id)

				if alive(prop_unit) then
					self:client_store_carry(prop_unit, carry_id)
				end
			end
		end
	end
end
