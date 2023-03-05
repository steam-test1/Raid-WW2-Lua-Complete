NetworkTweakData = NetworkTweakData or class()

function NetworkTweakData:init(tweak_data)
	self.camera = {
		network_angle_delta = 45,
		network_sync_delta_t = 1
	}
	self.stealth_speed_boost = 1.25
end
