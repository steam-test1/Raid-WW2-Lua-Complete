TeamAIInventory = TeamAIInventory or class(CopInventory)

function TeamAIInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())

	new_unit:base():setup({
		alert_AI = true,
		hit_player = false,
		expend_ammo = false,
		user_unit = self._unit,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets"),
		alert_filter = self._unit:brain():SO_access(),
		ignore_units = {
			self._unit,
			new_unit,
			self._shield_unit
		}
	})
	self:add_unit(new_unit, equip)
end

function TeamAIInventory:pre_destroy(unit)
	TeamAIInventory.super.pre_destroy(self, unit)
end
