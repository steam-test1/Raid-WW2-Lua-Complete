EscortWithSuitcaseActionWalk = EscortWithSuitcaseActionWalk or class(CopActionWalk)
EscortWithSuitcaseActionWalk._walk_anim_velocities = {
	stand = nil,
	stand = {
		hos = nil,
		hos = {
			walk = nil,
			walk = {
				l = 93,
				bwd = 70,
				fwd = 138,
				r = 65
			}
		}
	}
}
EscortWithSuitcaseActionWalk._walk_anim_lengths = {
	stand = nil,
	stand = {
		hos = nil,
		hos = {
			walk = nil,
			walk = {
				l = 45,
				bwd = 32,
				fwd = 28,
				r = 39
			}
		}
	}
}

for pose, stances in pairs(EscortWithSuitcaseActionWalk._walk_anim_lengths) do
	for stance, speeds in pairs(stances) do
		for speed, sides in pairs(speeds) do
			for side, speed in pairs(sides) do
				sides[side] = speed * 0.03333
			end
		end
	end
end

EscortPrisonerActionWalk = EscortPrisonerActionWalk or class(CopActionWalk)
EscortPrisonerActionWalk._walk_anim_velocities = {
	stand = nil,
	stand = {
		ntl = nil,
		ntl = {
			run = nil,
			run = {
				l = 170,
				bwd = 170,
				fwd = 329,
				r = 170
			}
		}
	}
}
EscortPrisonerActionWalk._walk_anim_lengths = {
	stand = nil,
	stand = {
		ntl = nil,
		ntl = {
			run = nil,
			run = {
				l = 25,
				bwd = 19,
				fwd = 22,
				r = 29
			}
		}
	}
}

for pose, stances in pairs(EscortPrisonerActionWalk._walk_anim_lengths) do
	for stance, speeds in pairs(stances) do
		for speed, sides in pairs(speeds) do
			for side, speed in pairs(sides) do
				sides[side] = speed * 0.03333
			end
		end
	end
end
