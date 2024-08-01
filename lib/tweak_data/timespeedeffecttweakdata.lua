TimeSpeedEffectTweakData = TimeSpeedEffectTweakData or class()

function TimeSpeedEffectTweakData:init()
	self.quickdraw = {
		sustain = 5,
		timer = "pausable",
		speed = 0.2,
		fade_out = 0.8,
		fade_in = 0.3,
		sync = true,
		fade_in_delay = 0.5
	}
	self.quickdraw_player = deep_clone(self.quickdraw)
	self.quickdraw_player.speed = 0.5
	self.quickdraw_player.affect_timer = "player"
end
