MeleeWeaponBase = MeleeWeaponBase or class(UnitBase)
MeleeWeaponBase.EVENT_IDS = {
	detonate = 1
}

local mvec1 = Vector3()
local mvec2 = Vector3()

function MeleeWeaponBase:setup(unit, t, dt)
	return
end

function MeleeWeaponBase:update(unit, t, dt)
	MeleeWeaponBase.super.update(self, unit, t, dt)
end

function MeleeWeaponBase:get_name_id()
	return self.name_id
end

function MeleeWeaponBase:is_melee_weapon()
	return true
end

function MeleeWeaponBase:get_use_data(character_setup)
	local use_data = {}

	use_data.equip = {
		align_place = "right_hand"
	}
	use_data.selection_index = self:selection_index()
	use_data.unequip = {
		align_place = "back"
	}

	return use_data
end

function MeleeWeaponBase:tweak_data_anim_play(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_play(animations[anim], ...)

		return true
	end

	return false
end

function MeleeWeaponBase:anim_play(anim, speed_multiplier)
	if anim then
		local length = self._unit:anim_length(Idstring(anim))

		speed_multiplier = speed_multiplier or 1

		self._unit:anim_stop(Idstring(anim))
		self._unit:anim_play_to(Idstring(anim), length, speed_multiplier)
	end
end

function MeleeWeaponBase:tweak_data_anim_stop(anim, ...)
	local animations = self:weapon_tweak_data().animations

	if animations and animations[anim] then
		self:anim_stop(self:weapon_tweak_data().animations[anim], ...)

		return true
	end

	return false
end

function MeleeWeaponBase:anim_stop(anim)
	self._unit:anim_stop(Idstring(anim))
end

function MeleeWeaponBase:ammo_info()
	return
end

function MeleeWeaponBase:add_ammo(ratio, add_amount_override, add_amount_multiplier)
	return false, 0
end

function MeleeWeaponBase:add_ammo_from_bag(available)
	return 0
end

function MeleeWeaponBase:on_equip()
	return
end

function MeleeWeaponBase:on_unequip()
	return
end

function MeleeWeaponBase:on_enabled()
	self._enabled = true
end

function MeleeWeaponBase:on_disabled()
	self._enabled = false
end

function MeleeWeaponBase:enabled()
	return self._enabled
end

function MeleeWeaponBase:get_stance_id()
	return self:weapon_tweak_data().stance
end

function MeleeWeaponBase:transition_duration()
	return self:weapon_tweak_data().transition_duration
end

function MeleeWeaponBase:enter_steelsight_speed_multiplier()
	return 1
end

function MeleeWeaponBase:exit_run_speed_multiplier()
	return self:weapon_tweak_data().exit_run_speed_multiplier
end

function MeleeWeaponBase:weapon_tweak_data()
	return tweak_data.blackmarket.melee_weapons[self.name_id]
end

function MeleeWeaponBase:weapon_hold()
	return self:weapon_tweak_data().weapon_hold
end

function MeleeWeaponBase:selection_index()
	return PlayerInventory.SLOT_4
end

function MeleeWeaponBase:has_range_distance_scope()
	return false
end

function MeleeWeaponBase:movement_penalty()
	return self:weapon_tweak_data().weapon_movement_penalty or 1
end

function MeleeWeaponBase:set_visibility_state(state)
	self._unit:set_visible(state)
end

function MeleeWeaponBase:start_shooting_allowed()
	return true
end

function MeleeWeaponBase:save(data)
	return
end

function MeleeWeaponBase:load(data)
	return
end

function MeleeWeaponBase:uses_ammo()
	return false
end

function MeleeWeaponBase:replenish()
	return
end

function MeleeWeaponBase:get_aim_assist()
	return
end
