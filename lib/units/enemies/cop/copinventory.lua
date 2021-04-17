CopInventory = CopInventory or class(PlayerInventory)

-- Lines 3-19
function CopInventory:init(unit)
	CopInventory.super.init(self, unit)

	self._unit = unit
	self._available_selections = {}
	self._equipped_selection = nil
	self._latest_addition = nil
	self._selected_primary = nil
	self._use_data_alias = "npc"
	self._align_places = {
		right_hand = {
			on_body = true,
			obj3d_name = Idstring("a_weapon_right_front")
		},
		back = {
			on_body = true,
			obj3d_name = Idstring("Hips")
		}
	}
	self._listener_id = "CopInventory" .. tostring(unit:key())
end

-- Lines 23-25
function CopInventory:_send_equipped_weapon()
	CopInventory.super._send_equipped_weapon(self, PlayerInventory.SEND_WEAPON_TYPE_TEAMAI_COPS)
end

-- Lines 29-45
function CopInventory:add_unit_by_name(new_unit_name, equip)
	local new_unit = World:spawn_unit(new_unit_name, Vector3(), Rotation())

	self:_chk_spawn_shield(new_unit)

	local setup_data = {
		user_unit = self._unit,
		ignore_units = {
			self._unit,
			new_unit,
			self._shield_unit
		},
		expend_ammo = false,
		hit_slotmask = managers.slot:get_mask("bullet_impact_targets"),
		hit_player = true,
		user_sound_variant = tweak_data.character[self._unit:base()._tweak_table].weapon_voice,
		alert_AI = true,
		alert_filter = self._unit:brain():SO_access()
	}

	new_unit:base():setup(setup_data)
	self:add_unit(new_unit, equip)
end

-- Lines 49-57
function CopInventory:_chk_spawn_shield(weapon_unit)
	if self._shield_unit_name and not alive(self._shield_unit) then
		local align_name = Idstring("a_weapon_left_front")
		local align_obj = self._unit:get_object(align_name)
		self._shield_unit = World:spawn_unit(Idstring(self._shield_unit_name), align_obj:position(), align_obj:rotation())

		self._unit:link(align_name, self._shield_unit, self._shield_unit:orientation_object():name())
		self._shield_unit:set_enabled(false)
	end
end

-- Lines 61-63
function CopInventory:add_unit(new_unit, equip)
	CopInventory.super.add_unit(self, new_unit, equip)
end

-- Lines 67-69
function CopInventory:get_sync_data(sync_data)
	MPPlayerInventory.get_sync_data(self, sync_data)
end

-- Lines 73-77
function CopInventory:get_weapon()
	local selection = self._available_selections[self._equipped_selection]
	local unit = selection and selection.unit

	return unit
end

-- Lines 81-91
function CopInventory:drop_weapon()
	local selection = self._available_selections[self._equipped_selection]
	local unit = selection and selection.unit

	if unit and unit:damage() then
		unit:unlink()
		unit:damage():run_sequence_simple("enable_body")
		self:_call_listeners("unequip")
		managers.game_play_central:weapon_dropped(unit)
	end
end

-- Lines 95-102
function CopInventory:drop_shield()
	if alive(self._shield_unit) then
		self._shield_unit:unlink()

		if self._shield_unit:damage() then
			self._shield_unit:damage():run_sequence_simple("enable_body")
		end
	end
end

-- Lines 106-121
function CopInventory:anim_clbk_weapon_attached(unit, state)
	print("[CopInventory:anim_clbk_weapon_attached]", state)

	if location == true then
		print("linking")

		local weap_unit = self._equipped_selection.unit
		local weap_align_data = selection.use_data.equip
		local align_place = self._align_places[weap_align_data.align_place]
		local parent_unit = self._unit
		local res = parent_unit:link(align_place.obj3d_name, weap_unit, weap_unit:orientation_object():name())
	else
		print("unlinking")
		self._equipped_selection.unit:unlink()
	end
end

-- Lines 125-131
function CopInventory:destroy_all_items()
	CopInventory.super.destroy_all_items(self)

	if alive(self._shield_unit) then
		self._shield_unit:set_slot(0)

		self._shield_unit = nil
	end
end

-- Lines 134-136
function CopInventory:anim_clbk_equip_enter(unit)
	self:show_equipped_unit()
end
