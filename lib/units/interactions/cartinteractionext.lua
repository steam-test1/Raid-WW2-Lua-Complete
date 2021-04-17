CartInteractionExt = CartInteractionExt or class(UseInteractionExt)

-- Lines 3-5
function CartInteractionExt:interact_distance(...)
	return CartInteractionExt.super.interact_distance(self, ...)
end

-- Lines 7-9
function CartInteractionExt:can_select(player)
	return CartInteractionExt.super.can_select(self, player)
end

-- Lines 11-13
function CartInteractionExt:check_interupt()
	return CartInteractionExt.super.check_interupt(self)
end

-- Lines 15-24
function CartInteractionExt:interact(player)
	CartInteractionExt.super.super.interact(self, player)
	Application:trace("CartInteractionExt:interact: ", inspect(self._unit))
	managers.motion_path:push_cart(self._unit)
end

-- Lines 26-30
function CartInteractionExt:sync_interacted(peer, player, status, skip_alive_check)
	if not self._active then
		return
	end
end

-- Lines 32-34
function CartInteractionExt:set_contour(color, opacity)
end
