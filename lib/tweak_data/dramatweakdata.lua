DramaTweakData = DramaTweakData or class()

function DramaTweakData:init()
	Application:debug("[DramaTweakData] Drama tweakdata init!")

	self.drama_actions = {
		criminal_hurt = 0.236,
		criminal_dead = 0.28,
		criminal_disabled = 0.28
	}
	self.decay_period = 80
	self.max_dis = 7000
	self.max_dis_mul = 0.75
	self.low = 0.15
	self.peak = 0.95
	self.assault_fade_end = 0.25
	self.commander_decay_multi = 0.25
end
