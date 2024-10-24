local UpgradeStats = {
	MACRO_MULTIPLIER = "PERCENTAGE",
	MACRO_AMOUNT = "AMOUNT",
	MACRO_TEMPORARY = "SECONDS",
	MACRO_WARCRY = "DURATION",
	COLOR_CHARACTER = "|"
}

function UpgradeStats.get_display_data(skill_name)
	local display_data = {
		tiers = nil,
		tiers = {
			descriptions = nil,
			color_ranges = nil,
			descriptions = {},
			color_ranges = {}
		}
	}
	local skill_data = tweak_data.skilltree.skills[skill_name]

	if not skill_data or not skill_data.upgrades or not skill_data.upgrades_desc then
		Application:error("[UpgradeStats.construct_skill]", "Skill doesn't exist, or missing info: " .. tostring(skill_name))

		return display_data
	end

	local is_warcry = skill_data.upgrades_type == SkillTreeTweakData.TYPE_WARCRY
	local is_boost = skill_data.upgrades_type == SkillTreeTweakData.TYPE_BOOSTS
	display_data.tiers = UpgradeStats.get_tier_display_data(skill_data, is_warcry, is_boost)

	if skill_data.info_id then
		display_data.info = UpgradeStats.get_info_display_data(skill_data.info_id)
	end

	if is_warcry then
		local warcry = tweak_data.warcry[skill_data.warcry_id]
		display_data.info = UpgradeStats.get_warcry_display_data(warcry, display_data.info)
	end

	return display_data
end

function UpgradeStats.get_tier_display_data(skill_data, is_warcry, is_boost)
	local tier_data = {
		descriptions = nil,
		color_ranges = nil,
		descriptions = {},
		color_ranges = {}
	}

	for i, desc_id in ipairs(skill_data.upgrades_desc) do
		local macros = {}
		local index_offset = 0

		if is_warcry then
			local buffs = tweak_data.warcry[skill_data.warcry_id].buffs

			if buffs and buffs[i] then
				index_offset = #buffs[i]

				UpgradeStats.get_tier_macros(buffs[i], macros, 0)
			end
		elseif is_boost then
			local buffs = skill_data.upgrades_team_buff

			if buffs and buffs[i] then
				index_offset = #buffs[i]

				UpgradeStats.get_tier_macros(buffs[i], macros, 0)
			end
		end

		if skill_data.upgrades[i] then
			UpgradeStats.get_tier_macros(skill_data.upgrades[i], macros, index_offset)
		end

		local desc, desc_colors = UpgradeStats.get_formatted_description(desc_id, macros)

		table.insert(tier_data.descriptions, desc)
		table.insert(tier_data.color_ranges, desc_colors)
	end

	return tier_data
end

function UpgradeStats.get_warcry_display_data(warcry, info_data)
	local macros = {}
	local desc_id = "skill_warcry_duration_desc"
	local base_duration = warcry.base_duration
	local duration_multiplier = managers.warcry:duration_multiplier()
	macros[UpgradeStats.MACRO_WARCRY] = string.format("%g", base_duration)

	if duration_multiplier ~= 1 then
		local macro_name = UpgradeStats.MACRO_WARCRY .. "2"
		macros[macro_name] = string.format("%g", base_duration * duration_multiplier)
		desc_id = "skill_warcry_duration_upgraded_desc"
	end

	local data_pre_existed = info_data and true
	local desc, desc_colors = UpgradeStats.get_formatted_description(desc_id, macros)
	info_data = info_data or {}

	if data_pre_existed then
		local description_len = utf8.len(info_data.description) + 1
		info_data.description = info_data.description .. "\n" .. desc

		for _, range in ipairs(desc_colors) do
			range.start_index = range.start_index + description_len
			range.end_index = range.end_index + description_len
		end

		info_data.color_ranges = table.list_union(info_data.color_ranges, desc_colors)
	else
		info_data.description = desc
		info_data.color_ranges = desc_colors
	end

	return info_data
end

function UpgradeStats.get_info_display_data(info_id)
	local desc, desc_colors = UpgradeStats.get_formatted_description(info_id)
	local info_data = {
		color_ranges = nil,
		description = nil,
		description = desc,
		color_ranges = desc_colors
	}

	return info_data
end

function UpgradeStats.get_formatted_description(desc_id, macros)
	local desc = managers.localization:text(desc_id, macros)
	local desc_colors = {}
	local range = {}
	local search_index = 0
	local found = 0

	while true do
		local start_index = utf8.find_char(desc, UpgradeStats.COLOR_CHARACTER, search_index)

		if not start_index then
			break
		end

		local end_index = start_index + 1
		found = found + 1

		if not range.start_index then
			range.start_index = start_index - found
		else
			range.end_index = end_index - found

			table.insert(desc_colors, range)

			range = {}
		end

		search_index = end_index
	end

	desc = desc:gsub(UpgradeStats.COLOR_CHARACTER, "")

	return desc, desc_colors
end

function UpgradeStats.get_tier_macros(upgrades, macros, index_offset)
	for uindex, uid in ipairs(upgrades) do
		uindex = uindex + index_offset

		if type(uid) == "table" then
			uid = uid[1]
		end

		local upgrade_tweak = tweak_data.upgrades.definitions[uid]
		local macro_index = uindex > 1 and tostring(uindex) or ""

		if upgrade_tweak and upgrade_tweak.description_data then
			local upgrade_type = upgrade_tweak.description_data.upgrade_type

			if UpgradeStats[upgrade_type] then
				local category = nil

				if upgrade_tweak.category == UpgradesTweakData.DEF_CAT_TEAM then
					category = tweak_data.upgrades.values[upgrade_tweak.category][upgrade_tweak.upgrade.category]
				else
					category = tweak_data.upgrades.values[upgrade_tweak.upgrade.category]
				end

				local upgrade_values = category[upgrade_tweak.upgrade.upgrade]
				local value = upgrade_values[upgrade_tweak.upgrade.value or 1] or 0

				UpgradeStats[upgrade_type](value, macro_index, macros)
			end
		end
	end
end

function UpgradeStats.stat_type_multiplier(value, macro_index, macros)
	local macro_name = UpgradeStats.MACRO_MULTIPLIER .. macro_index
	macros[macro_name] = string.format("%g%%", (value - 1) * 100)
end

function UpgradeStats.stat_type_reductive_multiplier(value, macro_index, macros)
	local macro_name = UpgradeStats.MACRO_MULTIPLIER .. macro_index
	macros[macro_name] = string.format("%g%%", (1 - value) * 100)
end

function UpgradeStats.stat_type_multiplier_inverse_string(value, macro_index, macros)
	local macro_name = UpgradeStats.MACRO_MULTIPLIER .. macro_index
	macros[macro_name] = string.format("%g%%", math.abs(1 - value) * 100)
end

function UpgradeStats.stat_type_raw_value_amount(value, macro_index, macros)
	local macro_name = UpgradeStats.MACRO_AMOUNT .. macro_index
	macros[macro_name] = string.format("%g", value)
end

function UpgradeStats.stat_type_temporary_raw_value_amount(value, macro_index, macros)
	UpgradeStats.stat_type_raw_value_amount(value[1], macro_index, macros)

	local macro_name = UpgradeStats.MACRO_TEMPORARY .. macro_index
	macros[macro_name] = string.format("%g", value[2])
end

function UpgradeStats.stat_type_temporary_multiplier(value, macro_index, macros)
	UpgradeStats.stat_type_multiplier(value[1], macro_index, macros)

	local macro_name = UpgradeStats.MACRO_TEMPORARY .. macro_index
	macros[macro_name] = string.format("%g", value[2])
end

function UpgradeStats.stat_type_temporary_reduction(value, macro_index, macros)
	UpgradeStats.stat_type_reductive_multiplier(value[1], macro_index, macros)

	local macro_name = UpgradeStats.MACRO_TEMPORARY .. macro_index
	macros[macro_name] = string.format("%g", value[2])
end

return UpgradeStats
