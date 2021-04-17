ElementSoundSwitch = ElementSoundSwitch or class(CoreMissionScriptElement.MissionScriptElement)
ElementSoundSwitch.SWITCHES = {
	"daytime_set_day",
	"daytime_set_night"
}
ElementSoundSwitch.SWITCH_VALUES = {
	daytime_set_day = {
		value = "day",
		name = "daytime_switch",
		type = "ambience"
	},
	daytime_set_night = {
		value = "night",
		name = "daytime_switch",
		type = "ambience"
	}
}

-- Lines 9-12
function ElementSoundSwitch:init(...)
	self._has_executed = false

	ElementSoundSwitch.super.init(self, ...)
end

-- Lines 14-16
function ElementSoundSwitch:stop_simulation(...)
	ElementSoundSwitch.super.destroy(self, ...)
end

-- Lines 18-20
function ElementSoundSwitch:save(data)
	data.has_executed = self._has_executed
end

-- Lines 22-27
function ElementSoundSwitch:load(data)
	self._has_executed = data.has_executed

	if self._has_executed == true then
		self:_apply_switch()
	end
end

-- Lines 29-31
function ElementSoundSwitch:client_on_executed(...)
	self:on_executed(...)
end

-- Lines 33-41
function ElementSoundSwitch:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	self._has_executed = true

	self:_apply_switch()
	ElementSoundSwitch.super.on_executed(self, instigator)
end

-- Lines 43-54
function ElementSoundSwitch:_apply_switch()
	local switch = ElementSoundSwitch.SWITCH_VALUES[self._values.switch]

	if not switch then
		Application:error("[ElementSoundSwitch:_apply_switch]  attempting to set an unknown switch: ", self._values.switch)

		return
	end

	if switch.type == "ambience" then
		Application:trace("[ElementSoundSwitch:_apply_switch]  ", inspect(self._values.switch))
		managers.sound_environment:apply_ambience_switch(switch.name, switch.value)
	end
end
