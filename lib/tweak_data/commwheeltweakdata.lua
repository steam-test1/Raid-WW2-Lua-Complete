CommWheelTweakData = CommWheelTweakData or class()

-- Lines 3-25
function CommWheelTweakData:init()
	self.test = {
		texture = "guis/textures/pd2/icon_detection",
		texture_rect = {
			0,
			0,
			256,
			256
		}
	}
	self.panel = {
		texture = "ui/ingame/textures/communication_wheel/comm_wheel_white",
		texture_rect = {
			0,
			0,
			128,
			64
		}
	}
	self.ball = {
		texture = "guis/textures/hud_icons",
		texture_rect = {
			240,
			191,
			32,
			32
		}
	}
	self.arrow = {
		texture = "guis/textures/menu_arrows",
		texture_rect = {
			0,
			0,
			16,
			26
		}
	}
end
