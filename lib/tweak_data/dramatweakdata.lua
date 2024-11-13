DramaTweakData = DramaTweakData or class()

function DramaTweakData:init()
	Application:debug("[DramaTweakData] Drama tweakdata init!")

	self.drama_actions = {
		criminal_hurt = 0.34,
		criminal_disabled = 0.3,
		criminal_dead = 0.35,
		criminal_hurt_minimum = 0.02
	}
	self.decay_period = 60
	self.max_dis = 12000
	self.max_dis_mul = 0.8
	self.low = 0.15
	self.peak = 0.95
	self.assault_fade_end = 0.25
	self.commander_decay_multi = 0.35
end
