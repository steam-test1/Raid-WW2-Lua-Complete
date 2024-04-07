CartInteractionExt = CartInteractionExt or class(UseInteractionExt)

function CartInteractionExt:interact_distance(...)
	return CartInteractionExt.super.interact_distance(self, ...)
end

function CartInteractionExt:can_select(player)
	return CartInteractionExt.super.can_select(self, player)
end

function CartInteractionExt:check_interupt()
	return CartInteractionExt.super.check_interupt(self)
end

function CartInteractionExt:interact(player)
	CartInteractionExt.super.super.interact(self, player)
	Application:trace("CartInteractionExt:interact: ", inspect(self._unit))
	managers.motion_path:push_cart(self._unit)
end

function CartInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

function CartInteractionExt:set_contour(color, opacity)
	return
end
