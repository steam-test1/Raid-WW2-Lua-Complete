WarcrySentry = WarcrySentry or class(Warcry)
local ids_layer1_animate_factor = Idstring("layer1_animate_factor")
local ids_blend_factor = Idstring("blend_factor")

-- Lines 7-17
function WarcrySentry:init()
	WarcrySentry.super.init(self)

	self._type = Warcry.SENTRY
	self._tweak_data = tweak_data.warcry[self._type]

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

-- Lines 20-46
function WarcrySentry:update(dt)
	local lerp = WarcrySentry.super.update(self, dt)
	local distortion_a = managers.environment_controller:get_default_lens_distortion_value()
	local distortion_b = self._tweak_data.lens_distortion_value
	local distortion = math.lerp(distortion_a, distortion_b, lerp)

	managers.environment_controller:set_lens_distortion_power(distortion)

	self._shooting = managers.player:has_activate_temporary_upgrade("temporary", "warcry_sentry_shooting")
	self._target_mat_opacity = self._shooting and 1 or 0.35
	self._mat_opacity = math.step(self._mat_opacity, self._target_mat_opacity, dt)
	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, lerp * self._mat_opacity)

		local f = self._tweak_data.overlay_pulse_freq
		local A = self._tweak_data.overlay_pulse_ampl
		local t = managers.warcry:duration() - managers.warcry:remaining()
		local animation_factor = 0.5 * A * (math.sin(360 * t * f) - 1) + 1

		material:set_variable(ids_layer1_animate_factor, animation_factor)
	end
end

-- Lines 49-88
function WarcrySentry:activate()
	WarcrySentry.super.activate(self)

	self._mat_opacity = 0
	self._target_mat_opacity = 0

	if not alive(self._local_player) or not self._local_player:inventory() then
		return
	end

	managers.player:get_current_state():set_weapon_selection_wanted(PlayerInventory.SLOT_2)

	local primary_weapon = self._local_player:inventory():unit_by_selection(PlayerInventory.SLOT_2)

	if alive(primary_weapon) then
		local weap_base = primary_weapon:base()
		local ammo_clip_multiplier = managers.player:upgrade_value("player", "warcry_magazine_size_multiplier", 1)
		local ammo_max_per_clip = weap_base:get_ammo_max_per_clip()
		local new_max_per_clip = math.round(ammo_max_per_clip * ammo_clip_multiplier)

		weap_base:set_ammo_max_per_clip(new_max_per_clip)
		weap_base:on_reload()
		managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())
		managers.hud:hide_prompt("hud_reload_prompt")
	end

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_fired_weapon", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_FIRED_WEAPON
	}, callback(self, self, "_on_fired_weapon"))
end

-- Lines 91-124
function WarcrySentry:deactivate()
	WarcryBerserk.super.deactivate(self)
	managers.environment_controller:reset_lens_distortion_value()

	self._mat_opacity = nil
	self._target_mat_opacity = nil

	if not alive(self._local_player) or not self._local_player:inventory() then
		return
	end

	local primary_weapon = self._local_player:inventory():unit_by_selection(PlayerInventory.SLOT_2)

	if alive(primary_weapon) then
		local weap_base = primary_weapon:base()
		local ammo_max_per_clip, ammo_remaining_in_clip = weap_base:ammo_info()
		local ammo_ratio = math.clamp(ammo_remaining_in_clip / ammo_max_per_clip, 0, 1)
		ammo_max_per_clip = weap_base:calculate_ammo_max_per_clip()
		local new_remaining_in_clip = math.round(ammo_max_per_clip * ammo_ratio)

		weap_base:set_ammo_remaining_in_clip(new_remaining_in_clip)
		weap_base:set_ammo_max_per_clip(ammo_max_per_clip)
		managers.hud:set_ammo_amount(weap_base:selection_index(), weap_base:ammo_info())
	end

	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_fired_weapon")

	self._local_player = nil
end

-- Lines 128-134
function WarcrySentry:drain_rate()
	if managers.player:has_activate_temporary_upgrade("temporary", "warcry_sentry_shooting") then
		return managers.player:upgrade_value("player", "warcry_shooting_drain_reduction", 1)
	end

	return WarcrySentry.super.drain_rate()
end

-- Lines 138-148
function WarcrySentry:_on_fired_weapon(params)
	if managers.player:has_activate_temporary_upgrade("temporary", "warcry_sentry_shooting") then
		return
	end

	local weapon_tweak = tweak_data.weapon[params.weapon]

	if weapon_tweak and weapon_tweak.use_data.selection_index == WeaponInventoryManager.BM_CATEGORY_PRIMARY_ID then
		managers.player:activate_temporary_upgrade("temporary", "warcry_sentry_shooting")

		self._shooting = true
	end
end

-- Lines 152-154
function WarcrySentry:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)
end

-- Lines 157-159
function WarcrySentry:cleanup()
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
