core:import("CoreMissionScriptElement")

ElementFilter = ElementFilter or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 5-7
function ElementFilter:init(...)
	ElementFilter.super.init(self, ...)
end

-- Lines 9-11
function ElementFilter:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 13-39
function ElementFilter:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self:_check_platform() then
		return
	end

	if not self:_check_difficulty() then
		return
	end

	if not self:_check_players() then
		return
	end

	if not self:_check_mode() then
		return
	end

	if not self:_check_alarm() then
		return
	end

	ElementFilter.super.on_executed(self, instigator)
end

local win32 = Idstring("WIN32")
local ps3 = Idstring("PS3")
local x360 = Idstring("X360")
local ps4 = Idstring("PS4")
local xb1 = Idstring("XB1")

-- Lines 46-56
function ElementFilter:_check_platform()
	local platform = Global.running_simulation and Idstring(managers.editor:mission_platform())
	platform = platform or SystemInfo:platform()

	if self._values.platform_win32 and (platform == win32 or platform == ps4 or platform == xb1) then
		return true
	end

	if self._values.platform_ps3 and (platform == ps3 or platform == x360) then
		return true
	end

	return false
end

-- Lines 58-73
function ElementFilter:_check_difficulty()
	local diff = Global.game_settings and Global.game_settings.difficulty or Global.DEFAULT_DIFFICULTY

	if self._values.difficulty_normal and diff == "difficulty_1" then
		return true
	end

	if self._values.difficulty_hard and diff == "difficulty_2" then
		return true
	end

	if self._values.difficulty_overkill and diff == "difficulty_3" then
		return true
	end

	if self._values.difficulty_overkill_145 and diff == "difficulty_4" then
		return true
	end

	return false
end

-- Lines 75-94
function ElementFilter:_check_players()
	local players = Global.running_simulation and managers.editor:mission_player()
	players = players or managers.network:session() and managers.network:session():amount_of_players()

	if not players then
		return false
	end

	if self._values.player_1 and players == 1 then
		return true
	end

	if self._values.player_2 and players == 2 then
		return true
	end

	if self._values.player_3 and players == 3 then
		return true
	end

	if self._values.player_4 and players == 4 then
		return true
	end

	return false
end

-- Lines 97-111
function ElementFilter:_check_mode()
	if self._values.mode_control == nil or self._values.mode_assault == nil then
		return true
	end

	if managers.groupai:state():get_assault_mode() and self._values.mode_assault then
		return true
	end

	if not managers.groupai:state():get_assault_mode() and self._values.mode_control then
		return true
	end

	return false
end

-- Lines 113-130
function ElementFilter:_check_alarm()
	local alarm = managers.worldcollection:get_alarm_for_world(self._sync_id)

	if self._values.alarm_on == nil or self._values.alarm_off == nil then
		return true
	end

	if alarm and self._values.alarm_on then
		return true
	end

	if not alarm and self._values.alarm_off then
		return true
	end
end
