TankCopActionWalk = TankCopActionWalk or class(CopActionWalk)
TankCopActionWalk._walk_anim_velocities = {
	stand = {
		cbt = {
			walk = {
				l = 118.53,
				bwd = 112.85,
				fwd = 144,
				r = 122.48
			},
			run = {
				l = 287.43,
				bwd = 357.23,
				fwd = 361.5,
				r = 318.33
			}
		}
	}
}
TankCopActionWalk._walk_anim_velocities.stand.ntl = TankCopActionWalk._walk_anim_velocities.stand.cbt
TankCopActionWalk._walk_anim_velocities.stand.hos = TankCopActionWalk._walk_anim_velocities.stand.cbt
TankCopActionWalk._walk_anim_velocities.stand.wnd = TankCopActionWalk._walk_anim_velocities.stand.cbt
TankCopActionWalk._walk_anim_velocities.crouch = TankCopActionWalk._walk_anim_velocities.stand
TankCopActionWalk._walk_anim_lengths = {
	stand = {
		cbt = {
			walk = {
				l = 40,
				bwd = 40,
				fwd = 34,
				r = 38
			},
			run = {
				l = 20,
				bwd = 21,
				fwd = 20,
				r = 21
			}
		}
	}
}

for pose, stances in pairs(TankCopActionWalk._walk_anim_lengths) do
	for stance, speeds in pairs(stances) do
		for speed, sides in pairs(speeds) do
			for side, speed in pairs(sides) do
				sides[side] = speed * 0.03333
			end
		end
	end
end

TankCopActionWalk._walk_anim_lengths.stand.ntl = TankCopActionWalk._walk_anim_lengths.stand.cbt
TankCopActionWalk._walk_anim_lengths.stand.hos = TankCopActionWalk._walk_anim_lengths.stand.cbt
TankCopActionWalk._walk_anim_lengths.stand.wnd = TankCopActionWalk._walk_anim_lengths.stand.cbt
TankCopActionWalk._walk_anim_lengths.crouch = TankCopActionWalk._walk_anim_lengths.stand
