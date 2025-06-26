TimeSpeedEffectTweakData = TimeSpeedEffectTweakData or class()

function TimeSpeedEffectTweakData:init()
	self.buff_effect = {
		timer = "pausable",
		speed = 1,
		affect_timer = {
			"player",
			"pausable",
			"game_animation"
		}
	}
end
