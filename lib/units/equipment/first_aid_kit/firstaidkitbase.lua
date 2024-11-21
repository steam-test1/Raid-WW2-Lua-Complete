FirstAidKitBase = FirstAidKitBase or class(UnitBase)

function FirstAidKitBase.spawn(pos, rot, upgrade_lvl, peer_id)
	local unit_name = "units/pd2_dlc_old_hoxton/equipment/gen_equipment_first_aid_kit/gen_equipment_first_aid_kit"
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, upgrade_lvl, peer_id or 0)
	unit:base():setup(upgrade_lvl)

	return unit
end

function FirstAidKitBase:set_server_information(peer_id)
	self._server_information = {
		owner_peer_id = peer_id
	}

	managers.network:session():peer(peer_id):set_used_deployable(true)
end

function FirstAidKitBase:server_information()
	return self._server_information
end

function FirstAidKitBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self._unit:sound_source():post_event("ammo_bag_drop")

	if Network:is_client() then
		self._validate_clbk_id = "first_aid_kit_validate" .. tostring(unit:key())

		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end
end

function FirstAidKitBase:_clbk_validate()
	self._validate_clbk_id = nil

	if not self._was_dropin then
		local peer = managers.network:session():server_peer()

		peer:mark_cheater(VoteManager.REASON.many_assets)
	end
end

function FirstAidKitBase:sync_setup(upgrade_lvl, peer_id)
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	managers.player:verify_equipment(peer_id, "first_aid_kit")
	self:setup(upgrade_lvl)
end

function FirstAidKitBase:setup(upgrade_lvl)
	self._damage_reduction_upgrade = upgrade_lvl == 1

	if Network:is_server() then
		local from_pos = self._unit:position() + self._unit:rotation():z() * 10
		local to_pos = self._unit:position() + self._unit:rotation():z() * -10
		local ray = self._unit:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("world_geometry"))

		if ray then
			self._attached_data = {
				body = ray.body,
				position = ray.body:position(),
				rotation = ray.body:rotation(),
				index = 1,
				max_index = 3
			}

			self._unit:set_extension_update_enabled(Idstring("base"), true)
		end
	end
end

function FirstAidKitBase:update(unit, t, dt)
	self:_check_body()
end

function FirstAidKitBase:_check_body()
	if self._is_dynamic then
		return
	end

	if not alive(self._attached_data.body) then
		self:server_set_dynamic()

		return
	end

	if self._attached_data.index == 1 then
		if not self._attached_data.body:enabled() then
			self:server_set_dynamic()
		end
	elseif self._attached_data.index == 2 then
		if not mrotation.equal(self._attached_data.rotation, self._attached_data.body:rotation()) then
			self:server_set_dynamic()
		end
	elseif self._attached_data.index == 3 and mvector3.not_equal(self._attached_data.position, self._attached_data.body:position()) then
		self:server_set_dynamic()
	end

	self._attached_data.index = (self._attached_data.index < self._attached_data.max_index and self._attached_data.index or 0) + 1
end

function FirstAidKitBase:server_set_dynamic()
	self:_set_dynamic()

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 1)
	end
end

function FirstAidKitBase:sync_net_event(event_id)
	if event_id == 1 then
		self:_set_dynamic()
	elseif event_id == 2 then
		self:_set_empty()
	end
end

function FirstAidKitBase:_set_dynamic()
	self._is_dynamic = true

	self._unit:body("dynamic"):set_enabled(true)
end

function FirstAidKitBase:take(unit)
	if self._empty then
		return
	end

	unit:character_damage():band_aid_health()

	if self._damage_reduction_upgrade then
		managers.player:activate_temporary_upgrade("temporary", "first_aid_damage_reduction")
	end

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 2)
	end

	self:_set_empty()
end

function FirstAidKitBase:_set_empty()
	self._empty = true

	self._unit:set_slot(0)
end

function FirstAidKitBase:save(data)
	local state = {
		is_dynamic = self._is_dynamic
	}
	data.FirstAidKitBase = state
end

function FirstAidKitBase:load(data)
	local state = data.FirstAidKitBase

	if state.is_dynamic then
		self:_set_dynamic()
	end

	self._was_dropin = true
end

function FirstAidKitBase:destroy()
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end
end
