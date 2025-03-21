EscortWithSuitcaseActionWalk = EscortWithSuitcaseActionWalk or class(CopActionWalk)
EscortWithSuitcaseActionWalk._walk_anim_velocities = {
	stand = {
		hos = {
			walk = {
				bwd = 70,
				fwd = 138,
				r = 65,
				l = 93
			}
		}
	}
}
EscortWithSuitcaseActionWalk._walk_anim_lengths = {
	stand = {
		hos = {
			walk = {
				bwd = 32,
				fwd = 28,
				r = 39,
				l = 45
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
	stand = {
		ntl = {
			run = {
				bwd = 170,
				fwd = 329,
				r = 170,
				l = 170
			}
		}
	}
}
EscortPrisonerActionWalk._walk_anim_lengths = {
	stand = {
		ntl = {
			run = {
				bwd = 19,
				fwd = 22,
				r = 29,
				l = 25
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
