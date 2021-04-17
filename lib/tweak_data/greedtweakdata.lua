GreedTweakData = GreedTweakData or class()
GreedTweakData.HIGH_END_ITEM_VALUE = 80
GreedTweakData.MID_END_ITEM_VALUE = 55
GreedTweakData.LOW_END_ITEM_VALUE = 30

-- Lines 7-17
function GreedTweakData:init()
	self.points_needed_for_gold_bar = 1000
	self.points_spawned_on_level_default = 800
	self.difficulty_level_point_multipliers = {
		0.8,
		1,
		1.2,
		1.4
	}
	self.cache_base_spawn_chance = 0.25
	self.difficulty_cache_chance_multipliers = {
		0.8,
		1,
		1.2,
		1.4
	}

	self:_init_greed_items()
	self:_init_cache_items()
end

-- Lines 19-75
function GreedTweakData:_init_greed_items()
	self.greed_items = {
		egg_decoration = {}
	}
	self.greed_items.egg_decoration.value = GreedTweakData.HIGH_END_ITEM_VALUE
	self.greed_items.eagle_statue = {
		value = GreedTweakData.HIGH_END_ITEM_VALUE
	}
	self.greed_items.jewelry_box = {
		value = GreedTweakData.HIGH_END_ITEM_VALUE
	}
	self.greed_items.coin_collection = {
		value = GreedTweakData.HIGH_END_ITEM_VALUE
	}
	self.greed_items.chocolate_box = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.cigar_box = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.wine_box = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.golden_inkwell = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.golden_medal = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.book = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.vase = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.globe = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.lighter = {
		value = GreedTweakData.MID_END_ITEM_VALUE
	}
	self.greed_items.letter_opener = {
		value = GreedTweakData.LOW_END_ITEM_VALUE
	}
	self.greed_items.kaleidoscope = {
		value = GreedTweakData.LOW_END_ITEM_VALUE
	}
	self.greed_items.golden_compass = {
		value = GreedTweakData.LOW_END_ITEM_VALUE
	}
	self.greed_items.watch = {
		value = GreedTweakData.LOW_END_ITEM_VALUE
	}
end

-- Lines 77-104
function GreedTweakData:_init_cache_items()
	self.cache_items = {
		regular_cache_box = {}
	}
	self.cache_items.regular_cache_box.value = 1300
	self.cache_items.regular_cache_box.single_interaction_value = 100
	self.cache_items.regular_cache_box.interaction_timer = 0.8
	self.cache_items.regular_cache_box.lockpick = {
		number_of_circles = 3,
		circle_rotation_speed = {
			220,
			190,
			270
		},
		circle_rotation_direction = {
			1,
			-1,
			1
		},
		circle_difficulty = {
			0.9,
			0.93,
			0.96
		},
		sounds = {
			success = "success",
			failed = "lock_fail",
			circles = {
				{
					mechanics = "lock_mechanics_a",
					lock = "lock_a"
				},
				{
					mechanics = "lock_mechanics_b",
					lock = "lock_b"
				},
				{
					mechanics = "lock_mechanics_c",
					lock = "lock_c"
				}
			}
		}
	}
	self.cache_items.regular_cache_box.sequences = {
		{
			sequence = "chest_open_empty",
			max_value = 0
		},
		{
			sequence = "chest_open_half_full",
			max_value = 0.5
		},
		{
			sequence = "chest_open_full",
			max_value = 1
		}
	}
end
