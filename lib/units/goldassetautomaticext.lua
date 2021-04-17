GoldAssetAutomaticExt = GoldAssetAutomaticExt or class(GoldAssetExt)
local idstr_gold_asset = Idstring("gold_asset")

-- Lines 7-15
function GoldAssetAutomaticExt:init(unit)
	self._unit = unit
	self._tweak_data = tweak_data.camp_customization.camp_upgrades_automatic[self.tweak_data_name]

	self._unit:set_extension_update_enabled(idstr_gold_asset, false)

	if self._tweak_data.gold then
		managers.gold_economy:register_automatic_camp_upgrade_unit(self.tweak_data_name, unit)
	end
end

-- Lines 17-24
function GoldAssetAutomaticExt:apply_upgrade_level(level)
	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_automatic_camp_asset", self._unit, level)
		self:_apply_upgrade_level(level)
	end
end

-- Lines 26-40
function GoldAssetAutomaticExt:_apply_upgrade_level(level)
	self._unit:set_enabled(true)

	if self._unit:damage() and self._unit:damage():has_sequence("reset") then
		self._unit:damage():run_sequence("reset")
	end

	if level > 0 then
		for counter = 1, level do
			self._unit:damage():run_sequence_simple("level_" .. string.format("%02d", counter))
		end
	end
end
