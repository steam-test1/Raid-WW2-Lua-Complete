HuskTeamAIInventory = HuskTeamAIInventory or class(HuskCopInventory)

function HuskTeamAIInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())

	new_unit:base():setup({
		hit_player = false,
		expend_ammo = false,
		user_unit = self._unit,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets_no_AI"),
		ignore_units = {
			self._unit,
			new_unit,
			self._shield_unit
		}
	})
	CopInventory.add_unit(self, new_unit, equip)
end

function HuskTeamAIInventory:pre_destroy()
	HuskTeamAIInventory.super.pre_destroy(self)
end
