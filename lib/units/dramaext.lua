core:import("CoreSubtitlePresenter")

DramaExt = DramaExt or class()

-- Lines 5-8
function DramaExt:init(unit)
	self._unit = unit
	self._cue = nil
end

-- Lines 10-12
function DramaExt:name()
	return self.character_name
end

-- Lines 14-26
function DramaExt:play_sound(sound, sound_source)
	self._cue = self._cue or {}
	self._cue.sound = sound
	self._cue.sound_source = sound_source
	local playing = self._unit:sound_source(sound_source):post_event(sound, self.sound_callback, self._unit, "marker", "end_of_event")

	if not playing then
		Application:error("[DramaExt:play_sound] Wasn't able to play sound event " .. sound)
		Application:stack_dump()
		self:sound_callback(nil, "end_of_event", self._unit, sound_source, nil, nil, nil)
	end
end

-- Lines 28-42
function DramaExt:play_subtitle(string_id, duration, color, nationality_icon)
	self._cue = self._cue or {}
	self._cue.string_id = string_id

	managers.subtitle:set_visible(false)

	if not duration or duration == 0 then
		managers.subtitle:show_subtitle(string_id, 100000, nil, color, nationality_icon)
	else
		managers.subtitle:show_subtitle(string_id, duration, nil, color, nationality_icon)
	end

	managers.queued_tasks:queue(nil, self._do_show_subtitle, self, nil, 0.1, nil)
end

-- Lines 44-47
function DramaExt:_do_show_subtitle()
	managers.subtitle:set_visible(true)
	managers.subtitle:set_enabled(true)
end

-- Lines 49-68
function DramaExt:stop_cue()
	if self._cue then
		if self._cue.string_id then
			managers.subtitle:clear_subtitle()
			managers.subtitle:set_visible(false)
			managers.subtitle:set_enabled(false)
		end

		if self._cue.sound then
			self._unit:sound_source(self._cue.sound_source):stop()
		end

		self._cue = nil
	end
end

-- Lines 70-91
function DramaExt:sound_callback(instance, event_type, unit, sound_source, label, identifier, position)
	if event_type == "end_of_event" then
		managers.subtitle:clear_subtitle()
		managers.subtitle:set_visible(false)
		managers.subtitle:set_enabled(false)
		managers.queued_tasks:queue(nil, managers.dialog.finished, managers.dialog, nil, 0.1, nil)
	elseif event_type == "marker" and sound_source then
		managers.subtitle:set_visible(true)
		managers.subtitle:set_enabled(true)
		managers.subtitle:show_subtitle(sound_source, DramaExt._subtitle_len(DramaExt, sound_source))
	end
end

-- Lines 93-100
function DramaExt:_subtitle_len(id)
	local text = managers.localization:text(id)
	local duration = text:len() * tweak_data.dialog.DURATION_PER_CHAR

	if duration < tweak_data.dialog.MINIMUM_DURATION then
		duration = tweak_data.dialog.MINIMUM_DURATION
	end

	return duration
end

-- Lines 102-106
function DramaExt:set_voice(voice)
	local ss = self._unit:sound_source()

	ss:set_switch("hero_switch", voice)
	ss:set_switch("int_ext", "third")
end
