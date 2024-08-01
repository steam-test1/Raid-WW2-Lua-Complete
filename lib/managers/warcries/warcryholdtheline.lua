WarcryHoldTheLine = WarcryHoldTheLine or class(Warcry)
local ids_layer1_animate_factor = Idstring("layer1_animate_factor")
local ids_blend_factor = Idstring("blend_factor")

-- Lines 7-17
function WarcryHoldTheLine:init()
	WarcryHoldTheLine.super.init(self)

	self._type = Warcry.HOLD_THE_LINE
	self._tweak_data = tweak_data.warcry[self._type]

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

-- Lines 20-42
function WarcryHoldTheLine:update(dt)
	local lerp = WarcryHoldTheLine.super.update(self, dt)
	local distortion_a = managers.environment_controller:get_default_lens_distortion_value()
	local distortion_b = self._tweak_data.lens_distortion_value
	local distortion = math.lerp(distortion_a, distortion_b, lerp)

	managers.environment_controller:set_lens_distortion_power(distortion)

	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, lerp)

		local f = self._tweak_data.overlay_pulse_freq
		local A = self._tweak_data.overlay_pulse_ampl
		local t = managers.warcry:duration() - managers.warcry:remaining()
		local animation_factor = 0.5 * A * (math.sin(360 * t * f) - 1) + 1

		material:set_variable(ids_layer1_animate_factor, animation_factor)
	end
end

-- Lines 46-67
function WarcryHoldTheLine:can_activate()
	local player_unit = managers.player:local_player()

	if not alive(player_unit) then
		return false
	end

	local slotmask_gnd_ray = managers.slot:get_mask("player_ground_check")
	local player_pos = player_unit:position()
	local down_offset_vec = math.DOWN * self._tweak_data.activation_height_limit
	local down_pos = Vector3()

	mvector3.set(down_pos, player_pos)
	mvector3.add(down_pos, down_offset_vec)

	local ray = World:raycast("ray", player_pos, down_pos, "slot_mask", slotmask_gnd_ray, "ray_type", "body mover", "sphere_cast_radius", 29, "report")

	if not ray then
		return false, WarcryManager.WARCRY_BLOCKED_AIR_TEXT
	end

	return true
end

-- Lines 70-73
function WarcryHoldTheLine:deactivate()
	WarcryHoldTheLine.super.deactivate(self)
	managers.environment_controller:reset_lens_distortion_value()
end

-- Lines 77-79
function WarcryHoldTheLine:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)
end

-- Lines 82-84
function WarcryHoldTheLine:cleanup()
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
