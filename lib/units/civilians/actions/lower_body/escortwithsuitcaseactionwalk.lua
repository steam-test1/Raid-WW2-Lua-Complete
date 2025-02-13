EscortWithSuitcaseActionWalk = EscortWithSuitcaseActionWalk or class(CopActionWalk)
EscortWithSuitcaseActionWalk._walk_anim_velocities = {
	stand = {
		hos = {
			walk = {
				fwd = 138,
				r = 65,
				l = 93,
				bwd = 70
			}
		}
	}
}
EscortWithSuitcaseActionWalk._walk_anim_lengths = {
	stand = {
		hos = {
			walk = {
				fwd = 28,
				r = 39,
				l = 45,
				bwd = 32
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
				fwd = 329,
				r = 170,
				l = 170,
				bwd = 170
			}
		}
	}
}
EscortPrisonerActionWalk._walk_anim_lengths = {
	stand = {
		ntl = {
			run = {
				fwd = 22,
				r = 29,
				l = 25,
				bwd = 19
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
