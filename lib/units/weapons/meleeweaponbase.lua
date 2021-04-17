MeleeWeaponBase = MeleeWeaponBase or class(UnitBase)
MeleeWeaponBase.EVENT_IDS = {
	detonate = 1
}
local mvec1 = Vector3()
local mvec2 = Vector3()

-- Lines 7-8
function MeleeWeaponBase:setup(unit, t, dt)
end

-- Lines 10-12
function MeleeWeaponBase:update(unit, t, dt)
	MeleeWeaponBase.super.update(self, unit, t, dt)
end

-- Lines 14-16
function MeleeWeaponBase:get_name_id()
	return self.name_id
end

-- Lines 18-20
function MeleeWeaponBase:is_melee_weapon()
	return true
end

-- Lines 22-28
function MeleeWeaponBase:get_use_data(character_setup)
	local use_data = {
		equip = {
			align_place = "right_hand"
		},
		selection_index = self:selection_index(),
		unequip = {
			align_place = "back"
		}
	}

	return use_data
end

-- Lines 30-37
function MeleeWeaponBase:tweak_data_anim_play(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_play(animations[anim], ...)

		return true
	end

	return false
end

-- Lines 39-46
function MeleeWeaponBase:anim_play(anim, speed_multiplier)
	if anim then
		local length = self._unit:anim_length(Idstring(anim))
		speed_multiplier = speed_multiplier or 1

		self._unit:anim_stop(Idstring(anim))
		self._unit:anim_play_to(Idstring(anim), length, speed_multiplier)
	end
end

-- Lines 48-55
function MeleeWeaponBase:tweak_data_anim_stop(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_stop(self:weapon_tweak_data().animations[anim], ...)

		return true
	end

	return false
end

-- Lines 57-59
function MeleeWeaponBase:anim_stop(anim)
	self._unit:anim_stop(Idstring(anim))
end

-- Lines 61-62
function MeleeWeaponBase:ammo_info()
end

-- Lines 64-67
function MeleeWeaponBase:add_ammo(ratio, add_amount_override, add_amount_multiplier)
	return false, 0
end

-- Lines 70-72
function MeleeWeaponBase:add_ammo_from_bag(available)
	return 0
end

-- Lines 74-75
function MeleeWeaponBase:on_equip()
end

-- Lines 77-78
function MeleeWeaponBase:on_unequip()
end

-- Lines 80-82
function MeleeWeaponBase:on_enabled()
	self._enabled = true
end

-- Lines 84-86
function MeleeWeaponBase:on_disabled()
	self._enabled = false
end

-- Lines 88-90
function MeleeWeaponBase:enabled()
	return self._enabled
end

-- Lines 92-94
function MeleeWeaponBase:get_stance_id()
	return self:weapon_tweak_data().stance
end

-- Lines 96-98
function MeleeWeaponBase:transition_duration()
	return self:weapon_tweak_data().transition_duration
end

-- Lines 101-103
function MeleeWeaponBase:enter_steelsight_speed_multiplier()
	return 1
end

-- Lines 105-107
function MeleeWeaponBase:exit_run_speed_multiplier()
	return self:weapon_tweak_data().exit_run_speed_multiplier
end

-- Lines 109-111
function MeleeWeaponBase:weapon_tweak_data()
	return tweak_data.blackmarket.melee_weapons[self.name_id]
end

-- Lines 113-115
function MeleeWeaponBase:weapon_hold()
	return self:weapon_tweak_data().weapon_hold
end

-- Lines 117-119
function MeleeWeaponBase:selection_index()
	return PlayerInventory.SLOT_4
end

-- Lines 121-123
function MeleeWeaponBase:has_range_distance_scope()
	return false
end

-- Lines 124-126
function MeleeWeaponBase:movement_penalty()
	return self:weapon_tweak_data().weapon_movement_penalty or 1
end

-- Lines 128-130
function MeleeWeaponBase:set_visibility_state(state)
	self._unit:set_visible(state)
end

-- Lines 132-134
function MeleeWeaponBase:start_shooting_allowed()
	return true
end

-- Lines 136-137
function MeleeWeaponBase:save(data)
end

-- Lines 139-140
function MeleeWeaponBase:load(data)
end

-- Lines 143-145
function MeleeWeaponBase:uses_ammo()
	return false
end

-- Lines 148-150
function MeleeWeaponBase:replenish()
end

-- Lines 152-153
function MeleeWeaponBase:get_aim_assist()
end
