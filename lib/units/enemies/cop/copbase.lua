local ids_lod = Idstring("lod")
local ids_lod1 = Idstring("lod1")
local ids_ik_aim = Idstring("ik_aim")
CopBase = CopBase or class(UnitBase)
CopBase._anim_lods = {
	{
		2,
		500,
		100,
		5000
	},
	{
		2,
		0,
		100,
		1
	},
	{
		3,
		0,
		100,
		1
	}
}
CopBase._material_translation_map = {}
local character_path = ""
local bodybag_path = ""
local char_map = tweak_data.character.character_map()

for _, data in pairs(char_map) do
	for _, character in ipairs(data.list) do
		bodybag_path = data.path .. character
		character_path = bodybag_path .. "/" .. character
		local key = tostring(Idstring(character_path):key())
		CopBase._material_translation_map[key] = Idstring(character_path .. "_contour")
		CopBase._material_translation_map[tostring(Idstring(character_path .. "_contour"):key())] = Idstring(character_path)
	end
end

Application:debug("[CopBase] translation maps ready!")

-- Lines 43-57
function CopBase:init(unit)
	UnitBase.init(self, unit, false)

	self._char_tweak = tweak_data.character[self._tweak_table]
	self._unit = unit
	self._visibility_state = true
	self._foot_obj_map = {
		right = self._unit:get_object(Idstring("RightToeBase")),
		left = self._unit:get_object(Idstring("LeftToeBase"))
	}
	self._is_in_original_material = true
end

-- Lines 61-76
function CopBase:post_init()
	self._ext_movement = self._unit:movement()
	self._ext_anim = self._unit:anim_data()

	self:set_anim_lod(1)

	self._lod_stage = 1

	self._ext_movement:post_init(true)
	self._unit:brain():post_init()
	managers.enemy:register_enemy(self._unit)

	self._allow_invisible = true

	self:_chk_spawn_gear()
end

-- Lines 80-83
function CopBase:_chk_spawn_gear()
end

-- Lines 87-95
function CopBase:default_weapon_name()
	local default_weapon_id = self._default_weapon_id
	local weap_ids = tweak_data.character.weap_ids

	for i_weap_id, weap_id in ipairs(weap_ids) do
		if default_weapon_id == weap_id then
			return tweak_data.character.weap_unit_names[i_weap_id]
		end
	end
end

-- Lines 99-101
function CopBase:is_special()
	return self._char_tweak.is_special
end

-- Lines 103-105
function CopBase:special_type()
	return self._char_tweak.special_type
end

-- Lines 109-111
function CopBase:visibility_state()
	return self._visibility_state
end

-- Lines 115-117
function CopBase:lod_stage()
	return self._lod_stage
end

-- Lines 121-123
function CopBase:set_allow_invisible(allow)
	self._allow_invisible = allow
end

-- Lines 127-175
function CopBase:set_visibility_state(stage)
	local state = stage and true

	if not state and not self._allow_invisible then
		state = true
		stage = 1
	end

	if self._lod_stage == stage then
		return
	end

	local inventory = self._unit:inventory()
	local weapon = inventory and inventory.get_weapon and inventory:get_weapon()

	if weapon then
		weapon:base():set_flashlight_light_lod_enabled(stage ~= 2 and not not stage)
	end

	if self._visibility_state ~= state then
		local unit = self._unit

		if inventory then
			inventory:set_visibility_state(state)
		end

		unit:set_visible(state)

		if self._headwear_unit then
			self._headwear_unit:set_visible(state)
		end

		if state or self._ext_anim.can_freeze and (not self._ext_anim.upper_body_active or self._ext_anim.upper_body_empty) then
			unit:set_animatable_enabled(ids_lod, state)
			unit:set_animatable_enabled(ids_ik_aim, state)
		end

		self._visibility_state = state
	end

	if state then
		self:set_anim_lod(stage)
		self._unit:movement():enable_update(true)

		if stage == 1 then
			self._unit:set_animatable_enabled(ids_lod1, true)
		elseif self._lod_stage == 1 then
			self._unit:set_animatable_enabled(ids_lod1, false)
		end
	end

	self._lod_stage = stage

	self:chk_freeze_anims()
end

-- Lines 179-181
function CopBase:set_anim_lod(stage)
	self._unit:set_animation_lod(unpack(self._anim_lods[stage]))
end

-- Lines 185-187
function CopBase:on_death_exit()
	self._unit:set_animations_enabled(false)
end

-- Lines 191-203
function CopBase:chk_freeze_anims()
	if (not self._lod_stage or self._lod_stage > 1) and self._ext_anim.can_freeze and (not self._ext_anim.upper_body_active or self._ext_anim.upper_body_empty) then
		if not self._anims_frozen then
			self._anims_frozen = true

			self._unit:set_animations_enabled(false)
			self._ext_movement:on_anim_freeze(true)
		end
	elseif self._anims_frozen then
		self._anims_frozen = nil

		self._unit:set_animations_enabled(true)
		self._ext_movement:on_anim_freeze(false)
	end
end

-- Lines 208-216
function CopBase:anim_act_clbk(unit, anim_act, send_to_action)
	if send_to_action then
		unit:movement():on_anim_act_clbk(anim_act)
	elseif unit:unit_data().mission_element then
		unit:unit_data().mission_element:event(anim_act, unit)
	end
end

-- Lines 220-226
function CopBase:save(data)
	if self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_trade" then
		data.is_hostage_trade = true
	elseif self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_convert" then
		data.is_hostage_convert = true
	end
end

-- Lines 230-236
function CopBase:load(data)
	if data.is_hostage_trade then
		CopLogicTrade.hostage_trade(self._unit, true, false)
	elseif data.is_hostage_convert then
		self._unit:interaction():set_tweak_data("hostage_convert")
	end
end

-- Lines 240-254
function CopBase:swap_material_config(material_applied_clbk)
	local new_material = self._material_translation_map[self._loading_material_key or tostring(self._unit:material_config():key())]

	if new_material then
		self._loading_material_key = new_material:key()
		self._is_in_original_material = not self._is_in_original_material

		self._unit:set_material_config(new_material, true, material_applied_clbk and callback(self, self, "on_material_applied", material_applied_clbk), 100)

		if not material_applied_clbk then
			self:on_material_applied()
		end
	else
		Application:error("[CopBase:swap_material_config] fail", self._unit:material_config(), self._unit)
		Application:stack_dump()
	end
end

-- Lines 258-272
function CopBase:on_material_applied(material_applied_clbk)
	if not alive(self._unit) then
		return
	end

	self._loading_material_key = nil

	if self._unit:interaction() then
		self._unit:interaction():refresh_material()
	end

	if material_applied_clbk then
		material_applied_clbk()
	end
end

-- Lines 276-278
function CopBase:is_in_original_material()
	return self._is_in_original_material
end

-- Lines 282-286
function CopBase:set_material_state(original)
	if original and not self._is_in_original_material or not original and self._is_in_original_material then
		self:swap_material_config()
	end
end

-- Lines 290-292
function CopBase:char_tweak()
	return self._char_tweak
end

-- Lines 296-298
function CopBase:char_tweak_id()
	return self._tweak_table
end

-- Lines 302-305
function CopBase:melee_weapon()
	return self._melee_weapon_table or self._char_tweak.melee_weapon or "weapon"
end

-- Lines 309-318
function CopBase:pre_destroy(unit)
	if self._unit:movement() then
		self._unit:movement():anim_clbk_close_parachute()
	end

	if alive(self._headwear_unit) then
		self._headwear_unit:set_slot(0)
	end

	UnitBase.pre_destroy(self, unit)
end
