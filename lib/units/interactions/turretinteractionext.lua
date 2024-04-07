TurretInteractionExt = TurretInteractionExt or class(UseInteractionExt)

function TurretInteractionExt:interact_distance(...)
	return TurretInteractionExt.super.interact_distance(self, ...)
end

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

function TurretInteractionExt:check_interupt()
	return TurretInteractionExt.super.check_interupt(self)
end

function TurretInteractionExt:interact(player)
	TurretInteractionExt.super.super.interact(self, player)
	managers.player:use_turret(self._unit)
	managers.player:set_player_state("turret")
end

function TurretInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

function TurretInteractionExt:set_contour(color, opacity)
	return
end
