SoundTweakData = SoundTweakData or class()

-- Lines 3-42
function SoundTweakData:init()
	self.acoustics = {
		acoustics_forest = {}
	}
	self.acoustics.acoustics_forest.states = {
		acoustic_flag = "acoustic_forest"
	}
	self.acoustics.acoustics_flat = {
		states = {
			acoustic_flag = "acoustic_flat"
		}
	}
	self.acoustics.acoustics_indoor_small = {
		states = {
			acoustic_flag = "acoustic_indoors_small"
		}
	}
	self.acoustics.acoustics_indoor_medium = {
		states = {
			acoustic_flag = "acoustic_indoors_medium"
		}
	}
	self.acoustics.acoustics_indoor_large = {
		states = {
			acoustic_flag = "acoustic_indoors_large"
		}
	}
	self.acoustics.acoustics_indoor_huge = {
		states = {
			acoustic_flag = "acoustic_indoors_huge"
		}
	}
	self.acoustics.acoustics_outdoor_small = {
		states = {
			acoustic_flag = "acoustic_outdoors_small"
		}
	}
	self.acoustics.acoustics_outdoor_medium = {
		states = {
			acoustic_flag = "acoustic_outdoors_medium"
		}
	}
	self.acoustics.acoustics_outdoor_large = {
		states = {
			acoustic_flag = "acoustic_outdoors_large"
		}
	}
	self.acoustics.acoustics_tunnel_small = {
		states = {
			acoustic_flag = "acoustic_tunnel_small"
		}
	}
	self.acoustics.acoustics_tunnel_medium = {
		states = {
			acoustic_flag = "acoustic_tunnel_medium"
		}
	}
end
