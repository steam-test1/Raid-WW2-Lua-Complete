PlayerBase = PlayerBase or class(UnitBase)
PlayerBase.PLAYER_CUSTODY_HUD = Idstring("guis/spectator_mode_saferect")
PlayerBase.INGAME_HUD_SAFERECT = Idstring("guis/ingame_hud_saferect")
PlayerBase.INGAME_HUD_FULLSCREEN = Idstring("guis/ingame_hud_fullscreen")
PlayerBase.USE_GRENADES = true

function PlayerBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self:_setup_suspicion_and_detection_data()

	self._id = managers.player:player_id(self._unit)
	self._rumble_pos_callback = callback(self, self, "get_rumble_position")

	self:_setup_controller()
	self._unit:set_extension_update_enabled(Idstring("base"), false)

	self._stats_screen_visible = false

	managers.game_play_central:restart_portal_effects()
end

function PlayerBase:post_init()
	self._unit:movement():post_init()
	self:_equip_default_weapon()

	if self._unit:movement():nav_tracker() then
		managers.groupai:state():register_criminal(self._unit)
	else
		self._unregistered = true
	end

	self._unit:character_damage():post_init()

	local con_mul, index = managers.blackmarket:get_concealment_of_peer(managers.network:session():local_peer())

	self:set_suspicion_multiplier("equipment", 1 / con_mul)
	self:set_detection_multiplier("equipment", 1 / con_mul)
end

function PlayerBase:update(unit, t, dt)
	if self._wanted_controller_enabled_t then
		if self._wanted_controller_enabled_t <= 0 then
			if self._wanted_controller_enabled then
				self._controller:set_enabled(true)

				self._wanted_controller_enabled = nil
				self._wanted_controller_enabled_t = nil
			end

			self._unit:set_extension_update_enabled(Idstring("base"), false)
		else
			self._wanted_controller_enabled_t = self._wanted_controller_enabled_t - 1
		end
	end
end

function PlayerBase:_setup_suspicion_and_detection_data()
	self._suspicion_settings = deep_clone(tweak_data.player.suspicion)
	self._suspicion_settings.multipliers = {}
	self._suspicion_settings.init_buildup_mul = self._suspicion_settings.buildup_mul
	self._suspicion_settings.init_range_mul = self._suspicion_settings.range_mul

	self:setup_hud_offset()

	self._detection_settings = {}
	self._detection_settings.multipliers = {}
	self._detection_settings.init_delay_mul = 1
	self._detection_settings.init_range_mul = 1
end

function PlayerBase:setup_hud_offset(peer)
	if not self._suspicion_settings then
		return
	end

	self._suspicion_settings.hud_offset = managers.blackmarket:get_suspicion_offset_of_peer(peer or managers.network:session():local_peer(), tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
end

function PlayerBase:stats_screen_visible()
	return self._stats_screen_visible
end

function PlayerBase:set_stats_screen_visible(visible)
	return
end

function PlayerBase:set_enabled(enabled)
	self._unit:set_extension_update_enabled(Idstring("movement"), enabled)
end

function PlayerBase:set_visible(visible)
	self._unit:set_visible(visible)
	self._unit:camera():camera_unit():set_visible(visible)

	if visible then
		self._unit:inventory():show_equipped_unit()
	else
		self._unit:inventory():hide_equipped_unit()
	end
end

function PlayerBase:_equip_default_weapon()
	return
end

function PlayerBase:_setup_controller()
	self._controller = managers.controller:create_controller("player_" .. tostring(self._id), nil, false)

	managers.rumble:register_controller(self._controller, self._rumble_pos_callback)
	managers.controller:set_ingame_mode("main")
	managers.controller:add_hotswap_callback("player_base", callback(self, self, "controller_hotswap_triggered"))
end

function PlayerBase:controller_hotswap_triggered()
	self._controller = managers.controller:create_controller("player_" .. tostring(self._id), nil, false)

	managers.rumble:register_controller(self._controller, self._rumble_pos_callback)
	managers.controller:set_ingame_mode("main")

	if managers.raid_menu:is_any_menu_open() then
		self:set_controller_enabled(false)
	else
		self:set_controller_enabled(true)
	end
end

function PlayerBase:id()
	return self._id
end

function PlayerBase:nick_name()
	return managers.network:session():local_peer():name()
end

function PlayerBase:set_controller_enabled(enabled)
	if not self._controller then
		return
	end

	if not enabled then
		self._controller:set_enabled(false)
	end

	self._wanted_controller_enabled = enabled

	if self._wanted_controller_enabled then
		self._wanted_controller_enabled_t = 1

		self._unit:set_extension_update_enabled(Idstring("base"), true)
	end
end

function PlayerBase:controller()
	return self._controller
end

local on_ladder_footstep_material = Idstring("metal")

function PlayerBase:anim_data_clbk_footstep(foot)
	local obj = self._unit:orientation_object()
	local proj_dir = math.UP
	local proj_from = obj:position()
	local proj_to = proj_from - proj_dir * 30
	local material_name, pos, norm

	if self._unit:movement():on_ladder() then
		material_name = on_ladder_footstep_material
	else
		material_name, pos, norm = World:pick_decal_material(proj_from, proj_to, managers.slot:get_mask("surface_move"))
	end

	self._unit:sound():play_footstep(foot, material_name)
end

function PlayerBase:get_rumble_position()
	return self._unit:position() + math.UP * 100
end

function PlayerBase:replenish()
	for id, weapon in pairs(self._unit:inventory():available_selections()) do
		if alive(weapon.unit) then
			weapon.unit:base():replenish()
			managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
		end
	end

	self._unit:character_damage():replenish()
end

function PlayerBase:suspicion_settings()
	return self._suspicion_settings
end

function PlayerBase:detection_settings()
	return self._detection_settings
end

function PlayerBase:set_suspicion_multiplier(reason, multiplier)
	self._suspicion_settings.multipliers[reason] = multiplier

	local buildup_mul = self._suspicion_settings.init_buildup_mul
	local range_mul = self._suspicion_settings.init_range_mul

	for reason, mul in pairs(self._suspicion_settings.multipliers) do
		buildup_mul = buildup_mul * mul

		if mul > 1 then
			range_mul = range_mul * math.sqrt(mul)
		end
	end

	self._suspicion_settings.buildup_mul = buildup_mul
	self._suspicion_settings.range_mul = range_mul
end

function PlayerBase:set_detection_multiplier(reason, multiplier)
	self._detection_settings.multipliers[reason] = multiplier

	local delay_mul = self._detection_settings.init_delay_mul
	local range_mul = self._detection_settings.init_range_mul

	for reason, mul in pairs(self._detection_settings.multipliers) do
		delay_mul = delay_mul * 1 / mul
		range_mul = range_mul * math.sqrt(mul)
	end

	self._detection_settings.delay_mul = delay_mul
	self._detection_settings.range_mul = range_mul
end

function PlayerBase:arrest_settings()
	return tweak_data.player.arrest
end

function PlayerBase:_unregister()
	if not self._unregistered then
		self._unit:movement():attention_handler():set_attention(nil)
		managers.groupai:state():unregister_criminal(self._unit)

		self._unregistered = true
	end
end

function PlayerBase:pre_destroy(unit)
	self:_unregister()
	UnitBase.pre_destroy(self, unit)
	managers.player:player_destroyed(self._id)

	if self._controller then
		managers.rumble:unregister_controller(self._controller, self._rumble_pos_callback)
		managers.controller:remove_hotswap_callback("player_base")
		self._controller:destroy()

		self._controller = nil
	end

	managers.hud:clear_weapons()
	self:set_stats_screen_visible(false)

	if managers.network:session() then
		local peer = managers.network:session():local_peer()

		if peer then
			peer:set_unit(nil)
		end
	end
end
