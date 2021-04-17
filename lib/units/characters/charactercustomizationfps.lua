CharacterCustomizationFps = CharacterCustomizationFps or class(CharacterCustomization)

-- Lines 3-6
function CharacterCustomizationFps:init(unit)
	self._unit = unit
end

-- Lines 8-20
function CharacterCustomizationFps:attach_fps_hands(character_nationality_name, equiped_upper_name, customization_version)
	Application:trace("[CharacterCustomizationFps:attach_fps_hands] character_nationality_name, equiped_upper_name, customization_version ", character_nationality_name, equiped_upper_name, customization_version)

	local upper_name = managers.character_customization:check_part_key_name(CharacterCustomizationTweakData.PART_TYPE_UPPER, equiped_upper_name, character_nationality_name)
	local upper_data = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_UPPER)[upper_name]

	self:destroy_all_parts_on_character()

	self._attached_units = {}

	self:_attach_unit("fps_hands", upper_data.path_fps_hands)
end

-- Lines 22-29
function CharacterCustomizationFps:_attach_unit(slot, name)
	managers.dyn_resource:load(Idstring("unit"), Idstring(name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_part_loaded_callback", {
		name = name,
		slot = slot
	}))
end

-- Lines 31-59
function CharacterCustomizationFps:_part_loaded_callback(params)
	if not self._unit or not alive(self._unit) then
		return
	end

	local attached_unit = safe_spawn_unit(Idstring(params.name), self._unit:position())

	if attached_unit and alive(attached_unit) and alive(self._attached_units[params.slot]) and self._attached_units[params.slot] then
		self._attached_units[params.slot]:set_slot(0)

		self._attached_units[params.slot] = nil
	end

	self._unit:link(Idstring("Hips"), attached_unit, attached_unit:orientation_object():name())

	self._attached_units[params.slot] = attached_unit

	for _, bone_name in ipairs(CharacterCustomization.BONES) do
		local skin_object = attached_unit:get_object(Idstring(bone_name))
		local char_object = self._unit:get_object(Idstring(bone_name))

		skin_object:link(char_object)
		skin_object:set_position(char_object:position())
		skin_object:set_rotation(char_object:rotation())
	end
end
