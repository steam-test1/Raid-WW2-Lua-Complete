TipsTweakData = TipsTweakData or class()

function TipsTweakData:init()
	table.insert(self, {
		string_id = "tip_select_reward"
	})
	table.insert(self, {
		string_id = "tip_objectives"
	})
	table.insert(self, {
		string_id = "tip_help_bleed_out"
	})
	table.insert(self, {
		string_id = "tip_shoot_in_bleed_out"
	})
	table.insert(self, {
		string_id = "tip_supply_crates"
	})
	table.insert(self, {
		string_id = "tip_first_aid_loot_drop"
	})
	table.insert(self, {
		string_id = "tip_grenade_loot_drop"
	})
	table.insert(self, {
		string_id = "tip_automatic_pickups"
	})
	table.insert(self, {
		string_id = "tip_detection_1"
	})
	table.insert(self, {
		string_id = "tip_detection_2"
	})
	table.insert(self, {
		string_id = "tip_weapon_spread"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_melee_attack"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_tactical_reload"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_weapon_effecienty"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_switch_to_sidearm"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_head_shot"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_steelsight"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_crowbar"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_grenade_using"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_bag_sprinting"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_flamers"
	})
	table.insert(self, {
		unlock_lvl = 8,
		string_id = "tip_commanders"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_new_objective_bonuses"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_new_grenade_throw_hold"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_new_grenade_throw_alt"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_new_weapon_parts"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_new_consumable_missions"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_outlaw_rewards"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_challenge_cards_1"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_challenge_cards_2"
	})
	table.insert(self, {
		unlock_lvl = 16,
		string_id = "tip_silent_headshots"
	})
	table.insert(self, {
		unlock_lvl = 30,
		string_id = "tip_new_honk_honk"
	})
	table.insert(self, {
		unlock_lvl = 40,
		string_id = "tip_new_level_fourty"
	})
end

function TipsTweakData:get_a_tip()
	local tips = self:get_tips_string_ids()

	return tips[math.random(#tips)]
end

function TipsTweakData:get_tips_string_ids()
	local lvl = managers.experience:current_level()
	local ids = {}

	for _, tip in ipairs(self) do
		if not tip.unlock_lvl or tip.unlock_lvl < lvl then
			table.insert(ids, tip.string_id)
		end
	end

	return ids
end
