TipsTweakData = TipsTweakData or class()

-- Lines 3-20
function TipsTweakData:init()
	table.insert(self, {
		string_id = "tip_tactical_reload"
	})
	table.insert(self, {
		string_id = "tip_weapon_effecienty"
	})
	table.insert(self, {
		string_id = "tip_switch_to_sidearm"
	})
	table.insert(self, {
		string_id = "tip_head_shot"
	})
	table.insert(self, {
		string_id = "tip_help_bleed_out"
	})
	table.insert(self, {
		string_id = "tip_steelsight"
	})
	table.insert(self, {
		string_id = "tip_melee_attack"
	})
	table.insert(self, {
		string_id = "tip_objectives"
	})
	table.insert(self, {
		string_id = "tip_select_reward"
	})
	table.insert(self, {
		string_id = "tip_shoot_in_bleed_out"
	})
	table.insert(self, {
		string_id = "tip_crowbar"
	})
	table.insert(self, {
		string_id = "tip_supply_crates"
	})
end

-- Lines 23-33
function TipsTweakData:get_a_tip()
	local lvl = managers.experience:current_level()
	local ids = {}

	for _, tip in ipairs(self) do
		if not tip.unlock_lvl or tip.unlock_lvl < lvl then
			table.insert(ids, tip.string_id)
		end
	end

	return ids[math.random(#ids)]
end
