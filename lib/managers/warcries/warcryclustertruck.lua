WarcryClustertruck = WarcryClustertruck or class(Warcry)
local ids_time = Idstring("time")
local ids_blend_factor = Idstring("blend_factor")
local ids_base_color_intensity = Idstring("base_color_intensity")

function WarcryClustertruck:init(type)
	WarcryClustertruck.super.init(self, type)

	self._type = type
	self._tweak_data = tweak_data.warcry[self._type]

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

	if not alive(self._local_player) or not self._local_player:inventory() then
		return
	end

	self._previous_selection = self._local_player:inventory():equipped_selection()
	local movement_state = managers.player:get_current_state()

	movement_state:interupt_all_actions()
	movement_state:force_change_weapon_slot(PlayerInventory.SLOT_3, true)
end

function WarcryClustertruck:deactivate()
	WarcryBerserk.super.deactivate(self)

	if not alive(self._local_player) or not self._local_player:movement() then
		return
	end

	local movement_state = self._local_player:movement():current_state()

	if self._local_player:inventory():equipped_selection() == PlayerInventory.SLOT_3 then
		movement_state:interupt_all_actions()
		movement_state:force_change_weapon_slot(self._previous_selection, true)
	end

	self._local_player = nil
	self._previous_selection = nil
end

function WarcryClustertruck:_on_enemy_killed(params)
	self:_fill_charge_on_enemy_killed(params)
end

function WarcryClustertruck:cleanup()
	WarcryClustertruck.super.cleanup(self)
	managers.system_event_listener:remove_listener("warcry_" .. self:get_type() .. "_enemy_killed")
end
