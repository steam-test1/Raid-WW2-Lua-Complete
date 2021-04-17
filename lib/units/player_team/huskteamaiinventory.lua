HuskTeamAIInventory = HuskTeamAIInventory or class(HuskCopInventory)

-- Lines 3-14
function HuskTeamAIInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())
	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit
		},
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets_no_AI"),
		hit_player = false,
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice
	}

	new_unit:base():setup(setup_data)
	CopInventory.add_unit(self, new_unit, equip)
end

-- Lines 16-18
function HuskTeamAIInventory:pre_destroy()
	HuskTeamAIInventory.super.pre_destroy(self)
end
