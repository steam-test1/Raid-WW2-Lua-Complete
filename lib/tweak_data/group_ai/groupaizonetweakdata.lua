GroupAIZoneTweakData = GroupAIZoneTweakData or class(GroupAIRaidTweakData)

function GroupAIZoneTweakData:init(difficulty_index)
	Application:debug("[GroupAITweakData:init] Mode: Zone, difficulty_index", difficulty_index)
	GroupAIZoneTweakData.super.init(self, difficulty_index)

	self.max_spawning_distance = 20000
	self.min_spawning_distance = 1600
	self.max_spawning_height_diff = 2560000
	self.max_distance_to_player = 225000000
	self.max_important_distance = 16000000

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
