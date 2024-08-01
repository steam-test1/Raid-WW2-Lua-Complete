WarcryBerserk = WarcryBerserk or class(Warcry)
local ids_layer1_animate_factor = Idstring("layer1_animate_factor")
local ids_blend_factor = Idstring("blend_factor")

-- Lines 7-17
function WarcryBerserk:init()
	WarcryBerserk.super.init(self)

	self._type = Warcry.BERSERK
	self._tweak_data = tweak_data.warcry[self._type]

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

-- Lines 20-42
function WarcryBerserk:update(dt)
	local lerp = WarcryBerserk.super.update(self, dt)
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

-- Lines 45-53
function WarcryBerserk:activate()
	WarcryBerserk.super.activate(self)

	self._ammo_consumption_counter = managers.player:upgrade_value("player", "warcry_ammo_consumption", 1)

	if not alive(self._local_player) or not self._local_player:character_damage() then
		return
	end
end

-- Lines 56-67
function WarcryBerserk:deactivate()
	WarcryBerserk.super.deactivate(self)
	managers.environment_controller:reset_lens_distortion_value()

	self._ammo_consumption_counter = nil

	if not alive(self._local_player) or not self._local_player:character_damage() then
		return
	end

	self._local_player = nil
end

-- Lines 70-79
function WarcryBerserk:check_ammo_consumption()
	self._ammo_consumption_counter = self._ammo_consumption_counter - 1

	if self._ammo_consumption_counter == 0 then
		self._ammo_consumption_counter = managers.player:upgrade_value("player", "warcry_ammo_consumption", 1)

		return true
	end

	return false
end

-- Lines 84-109
function WarcryBerserk:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)

	if self:is_active() and params.damage_type and params.damage_type == "bullet" then
		if not alive(self._local_player) or not self._local_player:character_damage() then
			return
		end

		local health_regen_amount = managers.player:upgrade_value("player", "warcry_kill_heal_bonus", 1) - 1
		local kill_wpn = tweak_data.weapon[params.weapon_used:base():get_name_id()]
		local kill_wpn_cat = kill_wpn and kill_wpn.category

		if kill_wpn and kill_wpn_cat then
			health_regen_amount = health_regen_amount * WeaponTweakData.get_weapon_class_regen_multiplier(kill_wpn_cat)
		end

		self._local_player:character_damage():restore_health(health_regen_amount)

		if managers.hud then
			managers.hud:post_event(self._tweak_data.health_boost_sound or "recon_warcry_enemy_hit")
		end
	end
end

-- Lines 112-114
function WarcryBerserk:cleanup()
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
