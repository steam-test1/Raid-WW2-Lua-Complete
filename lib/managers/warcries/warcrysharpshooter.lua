WarcrySharpshooter = WarcrySharpshooter or class(Warcry)
local ids_layer1_animate_factor = Idstring("layer1_animate_factor")
local ids_blend_factor = Idstring("blend_factor")
local ids_contour_post_processor = Idstring("contour_post_processor")
local ids_contour = Idstring("contour")
local ids_empty = Idstring("empty")
local ids_contour_color = Idstring("contour_color")

function WarcrySharpshooter:init()
	WarcrySharpshooter.super.init(self)

	self._type = Warcry.SHARPSHOOTER
	self._tweak_data = tweak_data.warcry[self._type]

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

function WarcrySharpshooter:update(dt)
	local FADE_TIME = 0.2
	local FADE_TIME_CHEAT = 0.05
	local lerp = WarcrySharpshooter.super.update(self, dt)
	local remain = managers.warcry:remaining()
	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, lerp)

		local f = self._tweak_data.overlay_pulse_freq
		local A = self._tweak_data.overlay_pulse_ampl
		local t = managers.warcry:duration() - managers.warcry:remaining()
		local animation_factor = 0.5 * A * (math.sin(360 * t * f) - 1) + 1

		material:set_variable(ids_layer1_animate_factor, animation_factor)
	end

	if alive(self._local_player) then
		local enemy = self._local_player:camera():camera_unit():base():locked_unit()

		if alive(enemy) and enemy:contour() then
			if remain < FADE_TIME_CHEAT then
				enemy:contour():remove("mark_enemy_sharpshooter", false)
			else
				enemy:contour():add("mark_enemy_sharpshooter")
			end
		end
	end
end

function WarcrySharpshooter:activate()
	WarcrySharpshooter.super.activate(self)

	local material = managers.warcry:warcry_post_material()

	material:set_variable(ids_contour_color, tweak_data.contour.character.sharpshooter_warcry)

	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_empty)
	end
end

function WarcrySharpshooter:deactivate()
	WarcrySharpshooter.super.deactivate(self)

	if not alive(self._local_player) then
		return
	end

	managers.player:get_current_state():reset_aim_assist_look_multiplier()

	self._local_player = nil
	local vp = managers.viewport:first_active_viewport()

	if vp then
		vp:vp():set_post_processor_effect("World", ids_contour_post_processor, ids_contour)
	end

	managers.enemy:unmark_dead_enemies()
end

function WarcrySharpshooter:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)

	if self:is_active() and params.damage_type and params.damage_type == "bullet" then
		local kill_wpn = tweak_data.weapon[params.weapon_used:base():get_name_id()]
		local kill_wpn_cat = kill_wpn and kill_wpn.category

		if kill_wpn and kill_wpn_cat and managers.player:upgrade_value("player", "warcry_health_regen_on_kill", false) then
			local health_regen_amount = managers.player:upgrade_value("player", "warcry_health_regen_amount", false)

			if health_regen_amount then
				health_regen_amount = math.ceil(health_regen_amount * WeaponTweakData.get_weapon_class_regen_multiplier(kill_wpn_cat))

				if alive(self._local_player) and self._local_player:character_damage() then
					self._local_player:character_damage():restore_health(health_regen_amount, true)
				end

				if managers.hud then
					managers.hud:post_event(self._tweak_data.health_boost_sound or "recon_warcry_enemy_hit")
				end
			end
		end
	end
end

function WarcrySharpshooter:cleanup()
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
