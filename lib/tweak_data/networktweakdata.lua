NetworkTweakData = NetworkTweakData or class()

function NetworkTweakData:init(tweak_data)
	self.camera = {
		network_angle_delta = 45,
		network_wait_delta_t = 0.2,
		network_sync_delta_t = 0.5
	}
	self.driving = {
		network_wait_delta_t = 0.05,
		network_wait_distance = 1
	}
	self.stealth_speed_boost = 1.025
end
