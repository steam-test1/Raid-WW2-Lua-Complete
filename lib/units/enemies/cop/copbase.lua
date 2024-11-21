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

function CopBase:post_init()
	self._ext_movement = self._unit:movement()
	self._ext_anim = self._unit:anim_data()

	self:set_anim_lod(1)

	self._lod_stage = 1

	self._ext_movement:post_init(true)
	self._unit:brain():post_init()
	managers.enemy:register_enemy(self._unit)

	self._allow_invisible = true

	self:_init_spawn_gear()
end

function CopBase:_init_spawn_gear()
	if not self._char_tweak or not self._tweak_table then
		Application:warn("[CopBase:_init_spawn_gear] Bad tweakdata", self._tweak_table, inspect(self._char_tweak))

		return
	end

	if self._gear_data and self._gear_data.spawned_gear then
		Application:warn("[CopBase:_init_spawn_gear] Gear already present", inspect(self._gear_data.spawned_gear))

		return
	end

	if not tweak_data.character.char_buff_gear then
		Application:warn("[CopBase:_init_spawn_gear] How did this happen? There's no char buff gear tweakdata!")

		return
	end

	self._gear_data = self._char_tweak.gear and deep_clone(self._char_tweak.gear) or {
		items = {},
		run_char_seqs = {}
	}
	self._gear_data.spawned_gear = {}

	for buff, char_gear_data in pairs(tweak_data.character.char_buff_gear) do
		if managers.buff_effect:is_effect_active(buff) and char_gear_data[self._tweak_table] then
			for bone, items in pairs(char_gear_data[self._tweak_table].items or {}) do
				for _, item in ipairs(items or {}) do
					if item then
						self._gear_data.items[bone] = self._gear_data.items[bone] or {}

						table.insert(self._gear_data.items[bone], item)
					end
				end
			end

			for _, v in ipairs(char_gear_data[self._tweak_table].run_char_seqs or {}) do
				table.insert(self._gear_data.run_char_seqs, v)
			end
		end
	end

	if self._gear_data.items then
		for align_key, bone_items in pairs(self._gear_data.items) do
			for _, path in ipairs(bone_items) do
				local sp_unit = safe_spawn_unit(path, Vector3(), Rotation())

				if sp_unit then
					local align_ids = Idstring(align_key)

					self._unit:link(align_ids, sp_unit, sp_unit:orientation_object():name())
					table.insert(self._gear_data.spawned_gear, {
						unit = sp_unit,
						align_key = align_key
					})
				end
			end
		end
	end

	if self._gear_data.run_char_seqs then
		for _, seq in ipairs(self._gear_data.run_char_seqs) do
			self._unit:damage():has_then_run_sequence_simple(seq)
		end
	end
end

function CopBase:set_gear_dead()
	if not self._gear_data or not self._gear_data.spawned_gear then
		return
	end

	for _, data in ipairs(self._gear_data.spawned_gear) do
		if alive(data.unit) then
			data.unit:damage():has_then_run_sequence_simple("on_dead")
		end
	end
end

function CopBase:set_spawn_gear_visibility_state(state, align_key)
	if not self._gear_data or not self._gear_data.spawned_gear then
		return
	end

	for _, data in ipairs(self._gear_data.spawned_gear) do
		if alive(data.unit) and (not align_key or align_key == data.align_key) then
			data.unit:damage():has_then_run_sequence_simple(state and "on_show" or "on_hide")
			data.unit:set_visible(state)
		end
	end
end

function CopBase:_clear_spawn_gear(align_key)
	if not self._gear_data or not self._gear_data.spawned_gear then
		return
	end

	for i = #self._gear_data.spawned_gear, 1, -1 do
		local data = self._gear_data.spawned_gear[i]

		if alive(data.unit) and (not align_key or align_key == data.align_key) then
			data.unit:damage():has_then_run_sequence_simple("on_destroy")
			data.unit:set_slot(0)
			table.remove(self._gear_data.spawned_gear, i)
		end
	end
end

function CopBase:get_spawned_gear()
	if not self._gear_data or not self._gear_data.spawned_gear then
		return nil
	end

	return self._gear_data.spawned_gear
end

function CopBase:default_weapon_name()
	local default_weapon_id = self._default_weapon_id
	local weap_ids = tweak_data.character.weap_ids

	for i_weap_id, weap_id in ipairs(weap_ids) do
		if default_weapon_id == weap_id then
			return tweak_data.character.weap_unit_names[i_weap_id]
		end
	end
end

function CopBase:is_special()
	return self._char_tweak.is_special
end

function CopBase:special_type()
	return self._char_tweak.special_type
end

function CopBase:visibility_state()
	return self._visibility_state
end

function CopBase:lod_stage()
	return self._lod_stage
end

function CopBase:set_allow_invisible(allow)
	self._allow_invisible = allow
end

function CopBase:set_visibility_state(stage)
	local state = stage and true

	if not state and not self._allow_invisible then
		state = true
		stage = 1
	end

	if self._lod_stage == stage then
		return
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

function CopBase:set_anim_lod(stage)
	self._unit:set_animation_lod(unpack(self._anim_lods[stage]))
end

function CopBase:on_death_exit()
	self._unit:set_animations_enabled(false)
end

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

function CopBase:anim_act_clbk(unit, anim_act, send_to_action)
	if send_to_action then
		unit:movement():on_anim_act_clbk(anim_act)
	elseif unit:unit_data().mission_element then
		unit:unit_data().mission_element:event(anim_act, unit)
	end
end

function CopBase:save(data)
	if self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_trade" then
		data.is_hostage_trade = true
	elseif self._unit:interaction() and self._unit:interaction().tweak_data == "hostage_convert" then
		data.is_hostage_convert = true
	end
end

function CopBase:load(data)
	if data.is_hostage_trade then
		CopLogicTrade.hostage_trade(self._unit, true, false)
	elseif data.is_hostage_convert then
		self._unit:interaction():set_tweak_data("hostage_convert")
	end
end

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

function CopBase:is_in_original_material()
	return self._is_in_original_material
end

function CopBase:set_material_state(original)
	if original and not self._is_in_original_material or not original and self._is_in_original_material then
		self:swap_material_config()
	end
end

function CopBase:char_tweak()
	return self._char_tweak
end

function CopBase:char_tweak_id()
	return self._tweak_table
end

function CopBase:melee_weapon()
	return self._melee_weapon_table or self._char_tweak.melee_weapon or "weapon"
end

function CopBase:pre_destroy(unit)
	if self._unit:movement() then
		self._unit:movement():anim_clbk_close_parachute()
	end

	self:_clear_spawn_gear()
	UnitBase.pre_destroy(self, unit)
end
