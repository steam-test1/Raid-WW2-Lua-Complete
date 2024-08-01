GroupAIStreetTweakData = GroupAIStreetTweakData or class(GroupAIRaidTweakData)

-- Lines 3-19
function GroupAIStreetTweakData:init(difficulty_index)
	Application:debug("[GroupAITweakData:init] Mode: Street, difficulty_index", difficulty_index)
	GroupAIStreetTweakData.super.init(self, difficulty_index)

	self.max_spawning_distance = 20000
	self.min_spawning_distance = 1600
	self.max_spawning_height_diff = 2560000
	self.max_distance_to_player = 100000000

	if difficulty_index <= TweakData.DIFFICULTY_1 then
		self.assault.delay = {
			25,
			22,
			18
		}
	elseif difficulty_index == TweakData.DIFFICULTY_2 then
		self.assault.delay = {
			22,
			18,
			15
		}
	elseif difficulty_index == TweakData.DIFFICULTY_3 then
		self.assault.delay = {
			18,
			15,
			13
		}
	elseif difficulty_index == TweakData.DIFFICULTY_4 then
		self.assault.delay = {
			15,
			13,
			10
		}
	end
end
