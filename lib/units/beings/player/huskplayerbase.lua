require("lib/units/enemies/cop/CopBase")

HuskPlayerBase = HuskPlayerBase or class(PlayerBase)
HuskPlayerBase.set_anim_lod = CopBase.set_anim_lod
HuskPlayerBase.set_visibility_state = CopBase.set_visibility_state
HuskPlayerBase._anim_lods = CopBase._anim_lods

-- Lines 9-25
function HuskPlayerBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._upgrades = {}
	self._upgrade_levels = {}

	self:_setup_suspicion_and_detection_data()

	local player_unit = managers.player:player_unit()

	if player_unit and player_unit:base() then
		managers.player:need_send_player_status()
	end
end

-- Lines 29-47
function HuskPlayerBase:post_init()
	self._ext_anim = self._unit:anim_data()

	managers.occlusion:remove_occlusion(self._unit)
	self:set_anim_lod(1)

	self._lod_stage = 1
	self._allow_invisible = true

	if managers.navigation:is_data_ready() then
		self:_do_post_init()
	else
		Application:debug("[HuskPlayerBase:post_init()] Navigation not ready! Queue player post_init method.")

		self._nav_ready_listener_key = "HuskPlayerBase" .. tostring(self._unit:key())

		managers.navigation:add_listener(self._nav_ready_listener_key, {
			"navigation_ready"
		}, callback(self, self, "_do_post_init"))
	end
end

-- Lines 49-57
function HuskPlayerBase:_do_post_init()
	self._unit:movement():post_init()
	managers.groupai:state():register_criminal(self._unit)

	local spawn_state = self._spawn_state or "std/stand/still/idle/look"

	self._unit:movement():play_state(spawn_state)

	if self._nav_ready_listener_key then
		managers.navigation:remove_listener(self._nav_ready_listener_key)
	end
end

-- Lines 61-81
function HuskPlayerBase:set_upgrade_value(category, upgrade, level)
	if category == UpgradesTweakData.CLEAR_UPGRADES_FLAG then
		self._upgrades = {}

		return
	end

	self._upgrades[category] = self._upgrades[category] or {}
	self._upgrade_levels[category] = self._upgrade_levels[category] or {}
	local value = managers.player:upgrade_value_by_level(category, upgrade, level)
	self._upgrades[category][upgrade] = value
	self._upgrade_levels[category][upgrade] = level

	if upgrade == "passive_concealment_modifier" then
		local con_mul, index = managers.blackmarket:get_concealment_of_peer(managers.network:session():peer_by_unit(self._unit))

		self:set_suspicion_multiplier("equipment", 1 / con_mul)
		self:set_detection_multiplier("equipment", 1 / con_mul)
	elseif upgrade == "suspicion_multiplier" then
		self:set_suspicion_multiplier(upgrade, value)
	end
end

-- Lines 85-87
function HuskPlayerBase:upgrade_value(category, upgrade)
	return self._upgrades[category] and self._upgrades[category][upgrade]
end

-- Lines 89-91
function HuskPlayerBase:upgrade_level(category, upgrade)
	return self._upgrade_levels[category] and self._upgrade_levels[category][upgrade]
end

-- Lines 95-105
function HuskPlayerBase:pre_destroy(unit)
	managers.groupai:state():unregister_criminal(self._unit)

	if managers.network:session() then
		local peer = managers.network:session():peer_by_unit(self._unit)

		if peer then
			peer:set_unit(nil)
		end
	end

	UnitBase.pre_destroy(self, unit)
end

-- Lines 109-112
function HuskPlayerBase:nick_name()
	local peer = managers.network:session():peer_by_unit(self._unit)

	return peer and peer:name() or ""
end

-- Lines 116-118
function HuskPlayerBase:on_death_exit()
end

-- Lines 122-123
function HuskPlayerBase:chk_freeze_anims()
end
