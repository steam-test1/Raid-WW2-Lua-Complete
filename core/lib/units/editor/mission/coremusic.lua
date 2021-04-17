CoreMusicUnitElement = CoreMusicUnitElement or class(MissionElement)
MusicUnitElement = MusicUnitElement or class(CoreMusicUnitElement)

-- Lines 5-7
function MusicUnitElement:init(...)
	CoreMusicUnitElement.init(self, ...)
end

-- Lines 9-14
function CoreMusicUnitElement:init(unit)
	MissionElement.init(self, unit)

	self._hed.music_event = "_LEVEL_DEFAULT"

	table.insert(self._save_values, "music_event")
end

-- Lines 16-21
function CoreMusicUnitElement:test_element()
	if self._hed.music_event then
		managers.editor:set_wanted_mute(false)
		managers.music:post_event(self._hed.music_event)
	end
end

-- Lines 23-26
function CoreMusicUnitElement:stop_test_element()
	managers.editor:set_wanted_mute(true)
	managers.music:stop()
end

-- Lines 29-43
function CoreMusicUnitElement:_build_panel(panel, panel_sizer)
	self:_create_panel()

	panel = panel or self._panel
	panel_sizer = panel_sizer or self._panel_sizer
	local events = deep_clone(managers.music:music_events_list())

	table.insert(events, "_LEVEL_DEFAULT")
	table.insert(events, "_RANDOM")
	table.insert(events, "music_camp")
	table.sort(events)
	self:_build_value_combobox(panel, panel_sizer, "music_event", events, "Music events:")
end
