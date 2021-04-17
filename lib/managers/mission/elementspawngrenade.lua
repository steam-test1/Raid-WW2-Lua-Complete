core:import("CoreMissionScriptElement")

ElementSpawnGrenade = ElementSpawnGrenade or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementSpawnGrenade:init(...)
	ElementSpawnGrenade.super.init(self, ...)
end

-- Lines 9-11
function ElementSpawnGrenade:client_on_executed(...)
end

-- Lines 13-26
function ElementSpawnGrenade:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local index = tweak_data.blackmarket:get_index_from_projectile_id(self._values.grenade_type)

	if not index then
		Application:error("Trying to spawn an unknown projectile type: ", self._values.grenade_type)

		return
	end

	ProjectileBase.throw_projectile(index, self._values.position, self._values.spawn_dir * self._values.strength)
	ElementSpawnGrenade.super.on_executed(self, instigator)
end
