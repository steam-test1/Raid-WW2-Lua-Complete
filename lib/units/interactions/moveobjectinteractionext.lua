MoveObjectInteractionExt = MoveObjectInteractionExt or class(UseInteractionExt)

function MoveObjectInteractionExt:interact_distance(...)
	return MoveObjectInteractionExt.super.interact_distance(self, ...)
end

function MoveObjectInteractionExt:can_select(player)
	return MoveObjectInteractionExt.super.can_select(self, player)
end

function MoveObjectInteractionExt:check_interupt()
	return MoveObjectInteractionExt.super.check_interupt(self)
end

function MoveObjectInteractionExt:interact(player)
	MoveObjectInteractionExt.super.super.interact(self, player)
	Application:trace("MoveObjectInteractionExt:interact: ", inspect(self._unit))
	managers.player:set_player_state("move_object", {
		moving_unit = self._unit
	})
end

function MoveObjectInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

function MoveObjectInteractionExt:set_contour(color, opacity)
end
