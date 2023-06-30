TurretInteractionExt = TurretInteractionExt or class(UseInteractionExt)

-- Lines 3-5
function TurretInteractionExt:interact_distance(...)
	return TurretInteractionExt.super.interact_distance(self, ...)
end

-- Lines 7-20
function TurretInteractionExt:can_select(player)
	local super_condition = TurretInteractionExt.super.can_select(self, player)

	if not player then
		return false
	end

	local sprinting = player:movement() and player:movement():running() or false
	local taken = self._unit:weapon():player_on()
	local locked = self._unit:weapon():locked_fire()

	return super_condition and not taken and not locked and not sprinting
end

-- Lines 22-24
function TurretInteractionExt:check_interupt()
	return TurretInteractionExt.super.check_interupt(self)
end

-- Lines 26-32
function TurretInteractionExt:interact(player)
	TurretInteractionExt.super.super.interact(self, player)
	managers.player:use_turret(self._unit)
	managers.player:set_player_state("turret")
end

-- Lines 34-38
function TurretInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

-- Lines 40-42
function TurretInteractionExt:set_contour(color, opacity)
end
