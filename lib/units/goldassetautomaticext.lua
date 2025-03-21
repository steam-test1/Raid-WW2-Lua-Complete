GoldAssetAutomaticExt = GoldAssetAutomaticExt or class(GoldAssetExt)

function GoldAssetAutomaticExt:init(unit)
	self._unit = unit
	self._tweak_data = tweak_data.camp_customization.camp_upgrades_automatic[self.tweak_data_name]

	if self._tweak_data.gold then
		managers.gold_economy:register_automatic_camp_upgrade_unit(self.tweak_data_name, unit)
	end
end

function GoldAssetAutomaticExt:apply_upgrade_level(level)
	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_automatic_camp_asset", self._unit, level)
		self:local_apply_upgrade_level(level)
	end
end

function GoldAssetAutomaticExt:local_apply_upgrade_level(level)
	self._unit:set_enabled(true)

	if self._unit:damage() and self._unit:damage():has_sequence("reset") then
		self._unit:damage():run_sequence("reset")
	end

	if level > 0 then
		for counter = 1, level do
			local seq = "level_" .. string.format("%02d", counter)

			if self._unit:damage():has_sequence(seq) then
				self._unit:damage():run_sequence(seq)
			else
				Application:warn("[GoldAssetAutomaticExt:_apply_upgrade_level] Cant apply missing sequence", seq, "for level", level)

				break
			end
		end
	end
end
