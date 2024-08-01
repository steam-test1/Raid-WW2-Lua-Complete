WarcryClustertruck = WarcryClustertruck or class(Warcry)
local ids_time = Idstring("time")
local ids_blend_factor = Idstring("blend_factor")
local ids_base_color_intensity = Idstring("base_color_intensity")

function WarcryClustertruck:init()
	WarcryClustertruck.super.init(self)

	self._type = Warcry.CLUSTERTRUCK
	self._tweak_data = tweak_data.warcry[self._type]
	self._killstreak_list = {}

	managers.system_event_listener:add_listener("warcry_" .. self:get_type() .. "_enemy_killed", {
		CoreSystemEventListenerManager.SystemEventListenerManager.PLAYER_KILLED_ENEMY
	}, callback(self, self, "_on_enemy_killed"))
end

function WarcryClustertruck:update(dt)
	local lerp = WarcryClustertruck.super.update(self, dt)
	local material = managers.warcry:warcry_post_material()

	if material then
		material:set_variable(ids_blend_factor, math.min(lerp, self._tweak_data.fire_opacity))
		material:set_variable(ids_time, managers.warcry:remaining())
	end
end

function WarcryClustertruck:activate()
	WarcryClustertruck.super.activate(self)

	local material = managers.warcry:warcry_post_material()

	material:set_variable(ids_base_color_intensity, self._tweak_data.fire_intensity)

	local grenade_refills = managers.player:upgrade_value("player", "warcry_grenade_refill_amounts", 1)

	managers.player:refill_grenades(grenade_refills)
	managers.player:get_current_state():set_weapon_selection_wanted(PlayerInventory.SLOT_3)

	self._killstreak_list = {}
end

function WarcryClustertruck:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)
end

function WarcryClustertruck:cleanup()
	WarcryClustertruck.super.cleanup(self)
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
