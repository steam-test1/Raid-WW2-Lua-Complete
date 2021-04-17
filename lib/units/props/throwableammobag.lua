ThrowableAmmoBag = ThrowableAmmoBag or class()
ThrowableAmmoBag.LEVEL = {
	1.2,
	1.4,
	1.6
}
local ammo_bag_ids = Idstring("units/vanilla/equipment/equip_throwable_ammo_bag/equip_throwable_ammo_bag")

function ThrowableAmmoBag.spawn(pos, dir, level_idx, user_unit)
	if Network:is_server() then
		local ammo_bag_unit = World:spawn_unit(ammo_bag_ids, pos, Rotation())

		ammo_bag_unit:base():set_user_unit(user_unit or managers.player:player_unit())
		ammo_bag_unit:base():register_collision_callbacks()
		ThrowableAmmoBag.set_level(ammo_bag_unit, level_idx)
		ThrowableAmmoBag.throw_bag(ammo_bag_unit, dir)
		managers.network:session():send_to_peers_synched("sync_throw_ammo_bag", ammo_bag_unit, dir)
		managers.network:session():send_to_peers_synched("sync_ammo_bag_level", ammo_bag_unit, level_idx)
	else
		managers.network:session():send_to_peers_synched("sync_spawn_ammo_bag", pos, dir, level_idx)
	end
end

function ThrowableAmmoBag.throw_bag(unit, dir)
	managers.player:switch_carry_to_ragdoll(unit)
	unit:push(100, dir * 800)
end

function ThrowableAmmoBag.set_level(unit, level_idx)
	unit:pickup():set_multiplier(ThrowableAmmoBag.LEVEL[level_idx])
end

function ThrowableAmmoBag.interact_pickup(unit, player_unit, owner_peer_id)
	if unit.interaction and player_unit.inventory and player_unit:inventory():need_ammo() then
		unit:interaction():interact(player_unit)

		local peer = managers.network:session():peer(owner_peer_id)

		if peer then
			-- Nothing
		end

		return true
	end

	return false
end

function ThrowableAmmoBag:init(unit)
	self._unit = unit
	self._slotmask_criminals = managers.slot:get_mask("all_criminals_no_player")
end

function ThrowableAmmoBag:set_user_unit(user_unit)
	self._user_unit = user_unit
	self._peer_id = managers.network:session():peer_by_unit(user_unit):id()
end

function ThrowableAmmoBag:update(unit, t, dt)
	if Network:is_server() and not self._waiting_for_response then
		local player_unit = managers.player:player_unit()
		local num_bodies = self._unit:num_bodies() - 1

		for i = 1, num_bodies do
			local body = self._unit:body(i)
			local overlapping = body:get_overlapping_bodies("slot_mask", self._slotmask_criminals)

			if overlapping then
				for _, b in pairs(overlapping) do
					local overlapping_unit = b:unit()

					if overlapping_unit ~= self._user_unit then
						if overlapping_unit == player_unit then
							if self.interact_pickup(self._unit, player_unit, self._peer_id) then
								self:_clear()

								return
							end
						else
							local peer = managers.network:session():peer_by_unit(overlapping_unit)

							managers.network:session():send_to_peer(peer, "sync_ammo_bag_hit_player", overlapping_unit, self._unit, self._peer_id)

							self._waiting_for_response = true

							return
						end
					end
				end
			end
		end
	end
end

function ThrowableAmmoBag:register_collision_callbacks()
	self._unit:set_body_collision_callback(callback(self, self, "_collision_callback"))

	for i = 0, self._unit:num_bodies() - 1 do
		local body = self._unit:body(i)

		body:set_collision_script_tag(Idstring("throw"))
		body:set_collision_script_filter(1)
		body:set_collision_script_quiet_time(1)
	end
end

function ThrowableAmmoBag:from_client_response(picked_up)
	if picked_up then
		self:_clear()
	else
		self._waiting_for_response = nil
	end
end

function ThrowableAmmoBag:_collision_callback(tag, unit, body, other_unit, other_body, position, normal, velocity, ...)
	self:_clear()
end

function ThrowableAmmoBag:destroy()
	self._unit:clear_body_collision_callbacks()
end

function ThrowableAmmoBag:_clear()
	if self._unit and alive(self._unit) then
		self._unit:set_extension_update_enabled(Idstring("base"), false)
		self._unit:clear_body_collision_callbacks()
	end
end
