HuskCopInventory = HuskCopInventory or class(HuskPlayerInventory)

-- Lines 3-5
function HuskCopInventory:init(unit)
	CopInventory.init(self, unit)
end

-- Lines 9-11
function HuskCopInventory:set_visibility_state(state)
	CopInventory.set_visibility_state(self, state)
end

-- Lines 15-31
function HuskCopInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())

	CopInventory._chk_spawn_shield(self, new_unit)

	local setup_data = {
		user_unit = self._unit,
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets_no_AI"),
		hit_player = true,
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice,
		ignore_units = {
			self._unit,
			new_unit,
			self._shield_unit
		}
	}

	new_unit:base():setup(setup_data)
	CopInventory.add_unit(self, new_unit, equip)
end

-- Lines 35-37
function HuskCopInventory:get_weapon()
	CopInventory.get_weapon(self)
end

-- Lines 41-43
function HuskCopInventory:drop_weapon()
	CopInventory.drop_weapon(self)
end

-- Lines 47-49
function HuskCopInventory:drop_shield()
	CopInventory.drop_shield(self)
end

-- Lines 53-55
function HuskCopInventory:destroy_all_items()
	CopInventory.destroy_all_items(self)
end

-- Lines 59-61
function HuskCopInventory:add_unit(new_unit, equip)
	CopInventory.add_unit(self, new_unit, equip)
end

-- Lines 65-67
function HuskCopInventory:set_visibility_state(state)
	CopInventory.set_visibility_state(self, state)
end
