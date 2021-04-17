ElementExecLuaOperator = ElementExecLuaOperator or class(CoreMissionScriptElement.MissionScriptElement)

-- Lines 3-5
function ElementExecLuaOperator:init(...)
	ElementExecLuaOperator.super.init(self, ...)
end

-- Lines 7-10
function ElementExecLuaOperator:client_on_executed(...)
	Application:debug("[ElementExecLuaOperator:client_on_executed]", ...)
	self:on_executed(...)
end

-- Lines 12-36
function ElementExecLuaOperator:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	Application:debug("[ElementExecLuaOperator:executed] Executing LUA (instigator, LUA):", inspect(instigator), self._values.lua_string)

	local lua_string = self._values.lua_string
	local skip_lua_exec = false

	if self._values.local_only and instigator ~= managers.player:local_player() then
		Application:debug("[ElementExecLuaOperator:executed] Skipping execution because not insitgator")

		skip_lua_exec = true
	end

	local func, err = loadstring(lua_string)

	if func then
		if not skip_lua_exec then
			func()
		end

		ElementExecLuaOperator.super.on_executed(self, instigator)
	else
		Application:error("[ElementExecLuaOperator:on_executed] Error in provided script:", self._editor_name, ";cause: ", err)
	end
end
