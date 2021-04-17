MoveObjectInteractionExt = MoveObjectInteractionExt or class(UseInteractionExt)

-- Lines 3-5
function MoveObjectInteractionExt:interact_distance(...)
	return MoveObjectInteractionExt.super.interact_distance(self, ...)
end

-- Lines 7-9
function MoveObjectInteractionExt:can_select(player)
	return MoveObjectInteractionExt.super.can_select(self, player)
end

-- Lines 11-13
function MoveObjectInteractionExt:check_interupt()
	return MoveObjectInteractionExt.super.check_interupt(self)
end

-- Lines 15-22
function MoveObjectInteractionExt:interact(player)
	MoveObjectInteractionExt.super.super.interact(self, player)
	Application:trace("MoveObjectInteractionExt:interact: ", inspect(self._unit))
	managers.player:set_player_state("move_object", {
		moving_unit = self._unit
	})
end

-- Lines 24-28
function MoveObjectInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

-- Lines 30-32
function MoveObjectInteractionExt:set_contour(color, opacity)
end
