HuskCopInventory = HuskCopInventory or class(HuskPlayerInventory)

-- Lines 3-5
function HuskCopInventory:init(unit)
	CopInventory.init(self, unit)
end

-- Lines 9-11
function HuskCopInventory:set_visibility_state(state)
	CopInventory.set_visibility_state(self, state)
end

-- Lines 15-29
function HuskCopInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())

	CopInventory._chk_spawn_shield(self, new_unit)

	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit,
			self._shield_unit
		},
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets_no_AI"),
		hit_player = true,
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice
	}

	new_unit:base():setup(setup_data)
	CopInventory.add_unit(self, new_unit, equip)
end

-- Lines 33-35
function HuskCopInventory:get_weapon()
	CopInventory.get_weapon(self)
end

-- Lines 39-41
function HuskCopInventory:drop_weapon()
	CopInventory.drop_weapon(self)
end

-- Lines 45-47
function HuskCopInventory:drop_shield()
	CopInventory.drop_shield(self)
end

-- Lines 51-53
function HuskCopInventory:destroy_all_items()
	CopInventory.destroy_all_items(self)
end

-- Lines 57-59
function HuskCopInventory:add_unit(new_unit, equip)
	CopInventory.add_unit(self, new_unit, equip)
end

-- Lines 63-65
function HuskCopInventory:set_visibility_state(state)
	CopInventory.set_visibility_state(self, state)
end
