NetworkTweakData = NetworkTweakData or class()

function NetworkTweakData:init(tweak_data)
	self.camera = {
		wait_delta_t = 0.2,
		sync_delta_t = 0.5,
		angle_delta = 45
	}
	self.driving = {
		wait_distance = 1,
		wait_delta_t = 0.05
	}
	self.team_ai = {
		wait_delta_t = 0.5
	}
	self.stealth_speed_boost = 1.025
end
