core:import("CoreWorldDefinition")

WorldDefinition = WorldDefinition or class(CoreWorldDefinition.WorldDefinition)

-- Lines 5-7
function WorldDefinition:init(...)
	WorldDefinition.super.init(self, ...)
end

CoreClass.override_class(CoreWorldDefinition.WorldDefinition, WorldDefinition)
