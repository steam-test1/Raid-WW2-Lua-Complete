core:import("CoreMissionScriptElement")

ElementPointOfNoReturn = ElementPointOfNoReturn or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementPointOfNoReturn:init(...)
	ElementPointOfNoReturn.super.init(self, ...)
end

-- Lines 9-11
function ElementPointOfNoReturn:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 13-32
function ElementPointOfNoReturn:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	local diff = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY

	if diff == "difficulty_1" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_normal, self._sync_id, self._id)
	elseif diff == "difficulty_2" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_hard, self._sync_id, self._id)
	elseif diff == "difficulty_3" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_overkill, self._sync_id, self._id)
	elseif diff == "difficulty_4" then
		managers.groupai:state():set_point_of_no_return_timer(self._values.time_overkill_145, self._sync_id, self._id)
	end

	ElementPointOfNoReturn.super.on_executed(self, instigator)
end
