core:import("CoreElementArea")
core:import("CoreClass")

ElementAreaTrigger = ElementAreaTrigger or class(CoreElementArea.ElementAreaTrigger)

-- Lines 6-8
function ElementAreaTrigger:init(...)
	ElementAreaTrigger.super.init(self, ...)
end

-- Lines 10-111
function ElementAreaTrigger:project_instigators()
	local instigators = {}

	if Network:is_client() then
		if self._values.instigator == "player" or self._values.instigator == "local_criminals" or self._values.instigator == "persons" then
			table.insert(instigators, managers.player:player_unit())
		end

		return instigators
	end

	if self._values.instigator == "player" then
		table.insert(instigators, managers.player:player_unit())
	elseif self._values.instigator == "player_not_in_vehicle" then
		table.insert(instigators, managers.player:player_unit())
	elseif self._values.instigator == "vehicle" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, v in pairs(vehicles) do
			if not v:npc_vehicle_driving() then
				table.insert(instigators, v)
			end
		end
	elseif self._values.instigator == "npc_vehicle" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, v in pairs(vehicles) do
			if v:npc_vehicle_driving() then
				table.insert(instigators, v)
			end
		end
	elseif self._values.instigator == "vehicle_with_players" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, v in pairs(vehicles) do
			table.insert(instigators, v)
		end
	elseif self._values.instigator == "enemies" then
		if managers.groupai:state():police_hostage_count() <= 0 then
			for _, data in pairs(managers.enemy:all_enemies()) do
				table.insert(instigators, data.unit)
			end
		else
			for _, data in pairs(managers.enemy:all_enemies()) do
				if not data.unit:anim_data().surrender then
					table.insert(instigators, data.unit)
				end
			end
		end
	elseif self._values.instigator == "civilians" then
		for _, data in pairs(managers.enemy:all_civilians()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "escorts" then
		for _, data in pairs(managers.enemy:all_civilians()) do
			if tweak_data.character[data.unit:base()._tweak_table].is_escort then
				table.insert(instigators, data.unit)
			end
		end
	elseif self._values.instigator == "criminals" then
		for _, data in pairs(managers.groupai:state():all_char_criminals()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "local_criminals" then
		table.insert(instigators, managers.player:player_unit())

		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "persons" then
		table.insert(instigators, managers.player:player_unit())

		for _, data in pairs(managers.groupai:state():all_char_criminals()) do
			table.insert(instigators, data.unit)
		end

		for _, data in pairs(managers.enemy:all_civilians()) do
			table.insert(instigators, data.unit)
		end

		for _, data in pairs(managers.enemy:all_enemies()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "ai_teammates" then
		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			table.insert(instigators, data.unit)
		end
	elseif self._values.instigator == "loot" or self._values.instigator == "unique_loot" then
		local all_found = World:find_units_quick("all", 14)

		for _, unit in ipairs(all_found) do
			local carry_data = unit:carry_data()

			if carry_data then
				local carry_id = carry_data:carry_id()

				if self._values.instigator == "loot" and tweak_data.carry[carry_id] ~= nil or self._values.instigator == "unique_loot" and tweak_data.carry[carry_id].is_unique_loot then
					table.insert(instigators, unit)
				end
			end
		end
	end

	return instigators
end

-- Lines 113-129
function ElementAreaTrigger:project_amount_all()
	if self._values.instigator == "criminals" or self._values.instigator == "local_criminals" then
		local i = 0

		for _, data in pairs(managers.groupai:state():all_char_criminals()) do
			i = i + 1
		end

		return i
	elseif self._values.instigator == "ai_teammates" then
		local i = 0

		for _, data in pairs(managers.groupai:state():all_AI_criminals()) do
			i = i + 1
		end

		return i
	end

	return managers.network:session():amount_of_alive_players()
end

-- Lines 131-154
function ElementAreaTrigger:project_amount_inside()
	local counter = #self._inside

	if self._values.instigator == "vehicle_with_players" then
		for _, instigator in pairs(self._inside) do
			local vehicle = instigator:vehicle_driving()

			if vehicle then
				counter = vehicle:num_players_inside()
			end
		end
	elseif self._values.instigator == "player_not_in_vehicle" then
		counter = 0
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, instigator in pairs(self._inside) do
			local in_vehicle = false

			for _, vehicle in pairs(vehicles) do
				in_vehicle = in_vehicle or vehicle:vehicle_driving():find_seat_for_player(instigator)
			end

			if not in_vehicle then
				counter = counter + 1
			end
		end
	end

	return counter
end

-- Lines 156-177
function ElementAreaTrigger:is_instigator_valid(unit)
	if self._values.instigator == "vehicle_with_players" and unit then
		local result = false
		local amount = self._values.amount == "all" and self:project_amount_all()
		amount = amount or tonumber(self._values.amount)
		local inside_vehicle = unit:vehicle_driving():num_players_inside()

		if unit:vehicle_driving() and inside_vehicle > 0 and amount <= inside_vehicle then
			result = true
		end

		return result
	elseif self._values.instigator == "player_not_in_vehicle" then
		local vehicles = managers.vehicle:get_all_vehicles()

		for _, instigator in pairs(self._inside) do
			for _, vehicle in pairs(vehicles) do
				if vehicle:vehicle_driving():find_seat_for_player(instigator) then
					return false
				end
			end
		end
	end

	return true
end

CoreClass.override_class(CoreElementArea.ElementAreaTrigger, ElementAreaTrigger)
