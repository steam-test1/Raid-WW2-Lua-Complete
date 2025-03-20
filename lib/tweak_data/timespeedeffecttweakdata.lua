TimeSpeedEffectTweakData = TimeSpeedEffectTweakData or class()

function TimeSpeedEffectTweakData:init()
	self.quickdraw = {
		timer = "pausable",
		fade_out = 0.8,
		sustain = 5,
		fade_in = 0.3,
		fade_in_delay = 0.5,
		speed = 0.2,
		sync = true
	}
	self.quickdraw_player = deep_clone(self.quickdraw)
	self.quickdraw_player.speed = 0.5
	self.quickdraw_player.affect_timer = "player"
end
