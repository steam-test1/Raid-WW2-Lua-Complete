NPCSniperRifleBase = NPCSniperRifleBase or class(NPCRaycastWeaponBase)
NPCSniperRifleBase.TRAIL_EFFECT = Idstring("effects/vanilla/weapons/wpn_sniper_trail_001")
NPCSniperRifleBase.GLOW_EFFECTT = "enable_sniper_effect"
local idstr_trail = Idstring("trail")
local idstr_simulator_length = Idstring("simulator_length")
local idstr_size = Idstring("size")

-- Lines 9-12
function NPCSniperRifleBase:init(unit)
	NPCSniperRifleBase.super.init(self, unit)

	self._trail_length = World:effect_manager():get_initial_simulator_var_vector2(self.TRAIL_EFFECT, idstr_trail, idstr_simulator_length, idstr_size)
end

-- Lines 16-32
function NPCSniperRifleBase:set_laser_enabled(enabled)
	Application:trace("[NPCSniperRifleBase:show_sniper_flare] **************************", self._unit, self._unit:damage())

	if not self._unit:damage() then
		return
	end

	if enabled and self._unit:damage():has_sequence("enable_sniper_effect") then
		self._unit:damage():run_sequence_simple("enable_sniper_effect")
		Application:trace("[NPCSniperRifleBase:show_sniper_flare]  unit:damage():run_sequence_simple( enable_sniper_effect )")
	elseif not enabled and self._unit:damage():has_sequence("disable_sniper_effect") then
		self._unit:damage():run_sequence_simple("disable_sniper_effect")
		Application:trace("[NPCSniperRifleBase:show_sniper_flare]  unit:damage():run_sequence_simple( disable_sniper_effect )")
	end

	NPCSniperRifleBase.unit = self._unit
end

-- Lines 36-44
function NPCSniperRifleBase:_spawn_trail_effect(direction, col_ray)
	self._obj_fire:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		mvector3.set_y(self._trail_length, col_ray.distance)
		World:effect_manager():set_simulator_var_vector2(trail, idstr_trail, idstr_simulator_length, idstr_size, self._trail_length)
	end
end
