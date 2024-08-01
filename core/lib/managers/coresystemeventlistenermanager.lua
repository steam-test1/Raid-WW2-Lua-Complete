core:module("CoreSystemEventListenerManager")
core:import("CoreSystemEventListenerHolder")

SystemEventListenerManager = SystemEventListenerManager or class()
SystemEventListenerManager.EVENT_DROP_IN = "BaseNetworkSession:add_peer"
SystemEventListenerManager.EVENT_DROP_OUT = "BaseNetworkSession:remove_peer"
SystemEventListenerManager.CHALLENGE_CARDS_SUGGESTED_CARDS_CHANGED = "ChallengeCardsManager:suggestions"
SystemEventListenerManager.CHALLENGE_CARDS_PLAYER_INVENTORY_CHANGED = "ChallengeCardsManager:player_inventory"
SystemEventListenerManager.TOP_STATS_READY = "StatisticsManager:calculate_top_stats"
SystemEventListenerManager.CAMP_PRESENCE_CHANGED = "PlayerManager:set_local_player_in_camp"
SystemEventListenerManager.PLAYER_KILLED_ENEMY = "CopDamage:die"
SystemEventListenerManager.PLAYER_DAMAGED_ENEMY = "CopDamage:damage_bullet"
SystemEventListenerManager.PLAYER_DAMAGED_ENEMY_MELEE = "CopDamage:damage_melee"
SystemEventListenerManager.PLAYER_PICKED_UP_AMMO = "RaycastWeaponBase:add_ammo"
SystemEventListenerManager.PLAYER_FIRED_WEAPON = "RaycastWeaponBase:fire"
SystemEventListenerManager.PLAYER_DAMAGE_TAKEN = "PlayerDamage:damage_health"
SystemEventListenerManager.PLAYER_CHECK_BLEEDOUT = "PlayerDamage:_check_bleed_out"
SystemEventListenerManager.PLAYER_ENTER_BLEEDOUT = "PlayerDamage:on_downed"
SystemEventListenerManager.PLAYER_REVIVED = "PlayerDamage:revive"
SystemEventListenerManager.PLAYER_SET_HEALTH_EFFECTS = "PlayerDamage:set_health_effects_blocked"
SystemEventListenerManager.EVENT_STEAM_INVENTORY_LOADED = "ChallengeCardsManager:_clbk_inventory_load"
SystemEventListenerManager.EVENT_STEAM_INVENTORY_PROCESSED = "ChallengeCardsManager:_process_fresh_steam_inventory"
SystemEventListenerManager.EVENT_STEAM_LOOT_DROPPED = "ChallengeCardsManager:_clbk_inventory_reward"
SystemEventListenerManager.PLAYER_KICKED = "ReadyUpGui:_on_peer_kicked"
SystemEventListenerManager.PLAYER_LEFT = "ReadyUpGui:_on_peer_left"
SystemEventListenerManager.PEER_LEVEL_UP = "UnitNetworkHandler:sync_character_level"
SystemEventListenerManager.PUMPKIN_DESTROYED = "RevivePumpkinExt:destroy"

function SystemEventListenerManager:init()
	self._listener_holder = CoreSystemEventListenerHolder.SystemEventListenerHolder:new()
end

function SystemEventListenerManager:call_listeners(event, params)
	self._listener_holder:call(event, params)
end

function SystemEventListenerManager:add_listener(key, events, clbk)
	self._listener_holder:add(key, events, clbk)
end

function SystemEventListenerManager:remove_listener(key)
	self._listener_holder:remove(key)
end
