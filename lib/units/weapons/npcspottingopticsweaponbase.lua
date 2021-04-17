NPCSpottingOpticsWeaponBase = NPCSpottingOpticsWeaponBase or class(NPCRaycastWeaponBase)

-- Lines 3-5
function NPCSpottingOpticsWeaponBase:init(...)
	NPCSpottingOpticsWeaponBase.super.init(self, ...)
end

-- Lines 9-12
function NPCSpottingOpticsWeaponBase:setup(setup_data)
	NPCSpottingOpticsWeaponBase.super.setup(self, setup_data)
	managers.barrage:register_spotter(setup_data.user_unit)
end

-- Lines 16-18
function NPCSpottingOpticsWeaponBase:ejects_shells()
	return false
end

-- Lines 22-24
function NPCSpottingOpticsWeaponBase:fire_blank(direction, impact)
end

-- Lines 28-66
function NPCSpottingOpticsWeaponBase:singleshot(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	return

	if not Network:is_server() then
		return
	end

	if not target_unit then
		return
	end

	if managers.barrage:is_barrage_running() then
		return false
	end

	local nav_seg = nil

	if target_unit:vehicle_driving() then
		nav_seg = managers.navigation:get_nav_seg_from_pos(target_unit:position())

		Application:trace("[NPCSpottingOpticsWeaponBase:singleshot] shooting a vehicle", target_unit, nav_seg)
	else
		nav_seg = managers.navigation:get_nav_seg(target_unit:movement():nav_tracker():nav_segment())

		Application:trace("[NPCSpottingOpticsWeaponBase:singleshot] shooting a player", target_unit, nav_seg)
	end

	if not nav_seg or not nav_seg.barrage_allowed then
		return
	end

	local fired = self:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if fired then
		-- Nothing
	end

	return false
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local mvec1 = Vector3()

-- Lines 74-101
function NPCSpottingOpticsWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	return

	local result = {}
	local hit_unit = nil
	local ray_distance = self._weapon_range or 20000

	mvector3.set(mvec_to, target_unit:position())

	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

	if col_ray then
		result.hit_enemy = col_ray.hit_unit
	end

	if self._alert_events then
		result.rays = {
			col_ray
		}

		if col_ray then
			result.hit_pos = col_ray.position

			Application:debug("hit pos ", result.hit_pos)
		end
	end

	return result
end

-- Lines 105-106
function NPCSpottingOpticsWeaponBase:_spawn_muzzle_effect()
end
