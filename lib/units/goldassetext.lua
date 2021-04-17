GoldAssetExt = GoldAssetExt or class()
local idstr_gold_asset = Idstring("gold_asset")

-- Lines 5-12
function GoldAssetExt:init(unit)
	self._unit = unit
	self._tweak_data = tweak_data.camp_customization.camp_upgrades[self.tweak_data_name]

	self._unit:set_extension_update_enabled(idstr_gold_asset, false)

	for _, level in ipairs(self.upgrade_levels) do
		managers.gold_economy:register_camp_upgrade_unit(self.tweak_data_name, unit, tonumber(level))
	end
end

-- Lines 14-45
function GoldAssetExt:apply_upgrade_level(level)
	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_camp_asset", self._unit, level)
	end

	if level == 0 then
		if self._unit:damage() and self._unit:damage():has_sequence("disable_interaction") then
			self._unit:damage():run_sequence("disable_interaction")
		end

		self._unit:set_enabled(false)
	else
		Application:debug("[GoldAssetExt:apply_upgrade_level] Applying camp upgrade ", self.tweak_data_name, level)
		self._unit:set_enabled(true)

		if self._unit:damage() and self._unit:damage():has_sequence("enable_interaction") then
			self._unit:damage():run_sequence("enable_interaction")
		end

		local upgrade = self._tweak_data.levels[level]

		if not upgrade then
			debug_pause("[GoldAssetExt:apply_upgrade_level] Trying to apply non existant level for camp asset", self.tweak_data_name, level)

			return
		end

		if upgrade.sequence then
			self._unit:damage():run_sequence_simple(upgrade.sequence)
		end
	end
end

-- Lines 47-49
function GoldAssetExt:tweak_data()
	return self._tweak_data
end
