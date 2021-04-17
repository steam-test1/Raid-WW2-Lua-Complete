TurretInteractionExt = TurretInteractionExt or class(UseInteractionExt)

-- Lines 3-5
function TurretInteractionExt:interact_distance(...)
	return TurretInteractionExt.super.interact_distance(self, ...)
end

-- Lines 7-17
function TurretInteractionExt:can_select(player)
	local super_condition = TurretInteractionExt.super.can_select(self, player)
	local taken = self._unit:weapon():player_on()
	local locked = self._unit:weapon():locked_fire()

	return super_condition and not taken and not locked
end

-- Lines 19-21
function TurretInteractionExt:check_interupt()
	return TurretInteractionExt.super.check_interupt(self)
end

-- Lines 23-29
function TurretInteractionExt:interact(player)
	TurretInteractionExt.super.super.interact(self, player)
	managers.player:use_turret(self._unit)
	managers.player:set_player_state("turret")
end

-- Lines 31-35
function TurretInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

-- Lines 37-39
function TurretInteractionExt:set_contour(color, opacity)
end
