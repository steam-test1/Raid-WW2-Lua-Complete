TeamAISound = TeamAISound or class(PlayerSound)

function TeamAISound:init(unit)
	self._unit = unit

	unit:base():post_init()

	local ss = unit:sound_source()

	ss:set_switch("hero_switch", tweak_data.character[unit:base()._tweak_table].speech_prefix)
	ss:set_switch("actor_switch", "third")

	self._sound_callback = callback(self, self, "sound_callback")
end

function TeamAISound:set_voice(voice)
	local ss = self._unit:sound_source()

	ss:set_switch("hero_switch", voice)
	ss:set_switch("actor_switch", "third")
end
