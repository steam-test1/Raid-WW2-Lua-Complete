NetworkTweakData = NetworkTweakData or class()

function NetworkTweakData:init(tweak_data)
	self.camera = {
		network_wait_delta_t = 0.2,
		network_sync_delta_t = 0.5,
		network_angle_delta = 45
	}
	self.driving = {
		network_wait_delta_t = 0.05
	}
	self.stealth_speed_boost = 1.025
end
