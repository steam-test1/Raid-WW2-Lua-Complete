core:import("CoreMissionScriptElement")

ElementAIArea = ElementAIArea or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 6-26
function ElementAIArea:on_executed(instigator)
	if not self._values.enabled or Network:is_client() or not managers.groupai:state():is_AI_enabled() or not self._values.nav_segs then
		return
	end

	if next(self._values.nav_segs) then
		local nav_segs = {}

		for _, segment_id in pairs(self._values.nav_segs) do
			local unique_id = managers.navigation:get_segment_unique_id(self._sync_id or 0, segment_id)

			table.insert(nav_segs, unique_id)
		end

		local area_id = managers.worldcollection:get_next_navstitcher_id()

		managers.groupai:state():add_area(area_id, nav_segs, self._values.position)
	end

	self._values.nav_segs = nil
	self._values.position = nil
	self._values = clone(self._values)

	ElementAIArea.super.on_executed(self, instigator)
end
