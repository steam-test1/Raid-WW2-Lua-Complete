CharacterCustomization = CharacterCustomization or class()
CharacterCustomization.BONES = {
	"Hips",
	"Spine",
	"Spine1",
	"Spine2",
	"Neck",
	"Head",
	"LeftShoulder",
	"LeftArm",
	"LeftForeArm",
	"LeftForeArmRoll",
	"LeftHand",
	"LeftHandThumb1",
	"LeftHandThumb2",
	"LeftHandThumb3",
	"LeftHandIndex1",
	"LeftHandIndex2",
	"LeftHandIndex3",
	"LeftHandMiddle1",
	"LeftHandMiddle2",
	"LeftHandMiddle3",
	"LeftHandRing1",
	"LeftHandRing2",
	"LeftHandRing3",
	"LeftHandPinky1",
	"LeftHandPinky2",
	"LeftHandPinky3",
	"RightShoulder",
	"RightArm",
	"RightForeArm",
	"RightForeArmRoll",
	"RightHand",
	"RightHandThumb1",
	"RightHandThumb2",
	"RightHandThumb3",
	"RightHandIndex1",
	"RightHandIndex2",
	"RightHandIndex3",
	"RightHandMiddle1",
	"RightHandMiddle2",
	"RightHandMiddle3",
	"RightHandRing1",
	"RightHandRing2",
	"RightHandRing3",
	"RightHandPinky1",
	"RightHandPinky2",
	"RightHandPinky3",
	"LeftUpLeg",
	"LeftLeg",
	"LeftFoot",
	"RightUpLeg",
	"RightLeg",
	"RightFoot"
}

-- Lines 58-67
function CharacterCustomization:init(unit)
	self._unit = unit
	self._visible = true
	self._loading_units = {}
end

-- Lines 70-80
function CharacterCustomization:set_visible(visible)
	self._visible = visible

	if not self._attached_units then
		return
	end

	for _, attached_unit in pairs(self._attached_units) do
		attached_unit:set_visible(visible)
	end
end

-- Lines 82-84
function CharacterCustomization:visible()
	return self._visible
end

-- Lines 86-91
function CharacterCustomization:set_unit(slot, name)
	if self._attached_units[slot] and alive(self._attached_units[slot]) then
		self:_attach_unit(slot, name)
	end
end

-- Lines 93-101
function CharacterCustomization:_attach_unit(slot, name, current_version, loading_entire_outfit)
	self._loading_units[name] = true

	managers.dyn_resource:load(Idstring("unit"), Idstring(name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, callback(self, self, "_part_loaded_callback", {
		name = name,
		slot = slot,
		loading_entire_outfit = loading_entire_outfit,
		name = name,
		current_version = current_version or 1
	}))
end

-- Lines 103-149
function CharacterCustomization:_part_loaded_callback(params)
	self._loading_units[params.name] = nil

	if params.current_version < (managers.character_customization:get_current_version_to_attach() or 0) then
		return false
	end

	if not self._unit or not alive(self._unit) then
		return
	end

	local attached_unit = safe_spawn_unit(Idstring(params.name), self._unit:position())

	if params.loading_entire_outfit then
		attached_unit:set_visible(false)
	end

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

	local head_unit = self._attached_units[CharacterCustomizationTweakData.PART_TYPE_HEAD]
	local upper_unit = self._attached_units[CharacterCustomizationTweakData.PART_TYPE_UPPER]
	local lower_unit = self._attached_units[CharacterCustomizationTweakData.PART_TYPE_LOWER]

	if head_unit and upper_unit and lower_unit and params.loading_entire_outfit then
		head_unit:set_visible(self._visible)
		upper_unit:set_visible(self._visible)
		lower_unit:set_visible(self._visible)
	end
end

-- Lines 151-178
function CharacterCustomization:attach_all_parts_to_character(slot_index, current_version)
	local slot_cache_data = Global.savefile_manager.meta_data_list[slot_index].cache

	if slot_cache_data then
		self:destroy_all_parts_on_character()

		local player_manager_data = slot_cache_data.PlayerManager
		local character_nationality_name = player_manager_data.character_profile_nation
		local owned_heads = managers.character_customization:get_owned_customizations_indexed(CharacterCustomizationTweakData.PART_TYPE_HEAD, character_nationality_name)
		local equiped_head_name = managers.character_customization:get_equiped_part_from_character_save_slot(slot_index, CharacterCustomizationTweakData.PART_TYPE_HEAD)
		local equiped_head_object = owned_heads[managers.character_customization:get_equiped_part_index(character_nationality_name, CharacterCustomizationTweakData.PART_TYPE_HEAD, equiped_head_name)]
		local owned_uppers = managers.character_customization:get_owned_customizations_indexed(CharacterCustomizationTweakData.PART_TYPE_UPPER, character_nationality_name)
		local equiped_upper_name = managers.character_customization:get_equiped_part_from_character_save_slot(slot_index, CharacterCustomizationTweakData.PART_TYPE_UPPER)
		local equiped_upper_object = owned_uppers[managers.character_customization:get_equiped_part_index(character_nationality_name, CharacterCustomizationTweakData.PART_TYPE_UPPER, equiped_upper_name)]
		local owned_lowers = managers.character_customization:get_owned_customizations_indexed(CharacterCustomizationTweakData.PART_TYPE_LOWER, character_nationality_name)
		local equiped_lower_name = managers.character_customization:get_equiped_part_from_character_save_slot(slot_index, CharacterCustomizationTweakData.PART_TYPE_LOWER)
		local equiped_lower_object = owned_lowers[managers.character_customization:get_equiped_part_index(character_nationality_name, CharacterCustomizationTweakData.PART_TYPE_LOWER, equiped_lower_name)]

		self:_attach_unit_parts(equiped_head_object, equiped_upper_object, equiped_lower_object, current_version)
	end
end

-- Lines 180-193
function CharacterCustomization:attach_all_parts_to_character_by_parts(character_nationality_name, equiped_head_name, equiped_upper_name, equiped_lower_name)
	local owned_heads = managers.character_customization:get_owned_customizations_indexed(CharacterCustomizationTweakData.PART_TYPE_HEAD, character_nationality_name)
	local equiped_head_object = owned_heads[managers.character_customization:get_equiped_part_index(character_nationality_name, CharacterCustomizationTweakData.PART_TYPE_HEAD, equiped_head_name)]
	local owned_uppers = managers.character_customization:get_owned_customizations_indexed(CharacterCustomizationTweakData.PART_TYPE_UPPER, character_nationality_name)
	local equiped_upper_object = owned_uppers[managers.character_customization:get_equiped_part_index(character_nationality_name, CharacterCustomizationTweakData.PART_TYPE_UPPER, equiped_upper_name)]
	local owned_lowers = managers.character_customization:get_owned_customizations_indexed(CharacterCustomizationTweakData.PART_TYPE_LOWER, character_nationality_name)
	local equiped_lower_object = owned_lowers[managers.character_customization:get_equiped_part_index(character_nationality_name, CharacterCustomizationTweakData.PART_TYPE_LOWER, equiped_lower_name)]

	self:_attach_unit_parts(equiped_head_object, equiped_upper_object, equiped_lower_object, managers.character_customization:get_current_version_to_attach())
end

-- Lines 195-218
function CharacterCustomization:attach_all_parts_to_character_by_parts_for_husk(character_nationality_name, equiped_head_name, equiped_upper_name, equiped_lower_name, peer)
	local head_name = managers.character_customization:get_default_part_key_name(peer:character(), CharacterCustomizationTweakData.PART_TYPE_HEAD)
	local equiped_head_name = managers.character_customization:check_part_key_name(CharacterCustomizationTweakData.PART_TYPE_HEAD, head_name, peer:character())
	local all_heads = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_HEAD)
	local equiped_head_object = all_heads[equiped_head_name]
	local equiped_upper_name = managers.character_customization:check_part_key_name(CharacterCustomizationTweakData.PART_TYPE_UPPER, equiped_upper_name, character_nationality_name)
	local all_uppers = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_UPPER)
	local equiped_upper_object = all_uppers[equiped_upper_name]
	local equiped_lower_name = managers.character_customization:check_part_key_name(CharacterCustomizationTweakData.PART_TYPE_LOWER, equiped_lower_name, character_nationality_name)
	local all_lowers = managers.character_customization:get_all_parts(CharacterCustomizationTweakData.PART_TYPE_LOWER)
	local equiped_lower_object = all_lowers[equiped_lower_name]

	self:destroy_all_parts_on_character()
	self:_attach_unit_parts(equiped_head_object, equiped_upper_object, equiped_lower_object, managers.character_customization:get_current_version_to_attach())
end

-- Lines 220-233
function CharacterCustomization:_attach_unit_parts(equiped_head_object, equiped_upper_object, equiped_lower_object, current_version)
	local lower_path = equiped_upper_object.length == CharacterCustomizationTweakData.PART_LENGTH_SHORT and equiped_lower_object.path_long or equiped_lower_object.path_short
	self._attached_units = {}

	self:_attach_unit(CharacterCustomizationTweakData.PART_TYPE_HEAD, equiped_head_object.path, current_version, true)
	self:_attach_unit(CharacterCustomizationTweakData.PART_TYPE_UPPER, equiped_upper_object.path, current_version, true)
	self:_attach_unit(CharacterCustomizationTweakData.PART_TYPE_LOWER, lower_path, current_version, true)

	if self._unit:contour() then
		self._unit:contour():update_materials()
	end
end

-- Lines 235-250
function CharacterCustomization:attach_head_for_husk(head_path)
	local head_unit = self._attached_units[CharacterCustomizationTweakData.PART_TYPE_HEAD]

	if head_unit then
		head_unit:set_slot(0)

		head_unit = nil
	end

	self:_attach_unit(CharacterCustomizationTweakData.PART_TYPE_HEAD, head_path, managers.character_customization:get_current_version_to_attach())

	if self._unit:contour() then
		self._unit:contour():update_materials()
	end
end

-- Lines 252-274
function CharacterCustomization:destroy_all_parts_on_character()
	if self._loading_units then
		for unit_name, _ in pairs(self._loading_units) do
			Application:trace("[CharacterCustomization][destroy_all_parts_on_character] unloading unit ", unit_name)
			managers.dyn_resource:unload(Idstring("unit"), Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)
		end
	end

	self._loading_units = {}

	if self._attached_units then
		for _, part in pairs(self._attached_units) do
			if part and alive(part) then
				part:set_slot(0)
			end

			part = nil
		end
	end
end

-- Lines 276-279
function CharacterCustomization:destroy()
	Application:trace("[CharacterCustomization][destroy]")
	self:destroy_all_parts_on_character()
end
