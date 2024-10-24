BuffCandyPickup = BuffCandyPickup or class(Pickup)
BuffCandyPickup.get_health_recovery = HealthPackPickup.get_health_recovery
BuffCandyPickup.get_restores_down = HealthPackPickup.get_restores_down
BuffCandyPickup.EVENT_IDS = {
	despawn = 1
}
BuffCandyPickup.EFFECT_PARAMS = {
	sound_event = "candy_vanish",
	idstr_decal = nil,
	effect = "units/upd_candy/effects/candy_drop_vanish",
	idstr_effect = nil,
	idstr_decal = Idstring("explosion_round"),
	idstr_effect = Idstring("")
}

function BuffCandyPickup:init(unit)
	BuffCandyPickup.super.init(self, unit)

	self._stack_size = 1
end

function BuffCandyPickup:get_pickup_type()
	return "candy"
end

function BuffCandyPickup:despawn_item()
	if not self._picked_up then
		local pos = self._unit:position()
		local range = 0

		managers.explosion:play_sound_and_effects(pos, math.UP, range, self.EFFECT_PARAMS)

		if Network:is_server() then
			managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "pickup", self.EVENT_IDS.despawn)
		end
	end

	self.super.despawn_item(self)
end

function BuffCandyPickup:sync_net_event(event_id)
	if event_id == self.EVENT_IDS.despawn then
		self:despawn_item()
	end
end

function BuffCandyPickup:interaction_detail()
	return tweak_data.drop_loot[self.tweak_data].interaction_detail
end

function BuffCandyPickup:_pickup(unit)
	if self._picked_up then
		return
	end

	if not managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_TRICK_OR_TREAT) then
		return
	end

	local upgrade_id = tweak_data.drop_loot[self.tweak_data].upgrade

	if upgrade_id then
		managers.player:activate_temporary_upgrade("temporary", upgrade_id)
	else
		local pickup = probability({
			20,
			40,
			40
		}, {
			GrenadePickupNew,
			AmmoClip,
			HealthPackPickup
		})

		pickup._pickup(self, unit)
	end

	if not self._picked_up then
		unit:sound():play(self._pickup_event or "pickup_health", nil, false)

		if Network:is_client() then
			managers.network:session():send_to_host("sync_pickup", self._unit)
		end

		self:consume()
	end

	return true
end

function BuffCandyPickup:consume()
	self._picked_up = true

	self.super.consume(self)
	managers.system_event_listener:call_listeners(BuffEffectCandy.EVENT_CANDY_CONSUMED, self.tweak_data)
end
