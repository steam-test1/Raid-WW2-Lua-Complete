CorpseCarryData = CorpseCarryData or class(CarryData)

-- Lines 4-13
function CorpseCarryData:init(...)
	CorpseCarryData.super.init(self, ...)

	if managers.buff_effect:is_effect_active(BuffEffectManager.EFFECT_ATTACK_ONLY_IN_AIR) and self._unit:damage() then
		self._unit:damage():has_then_run_sequence_simple("halloween_2017")
	end
end

-- Lines 17-22
function CarryData:on_pickup()
	if self._dismembered_parts then
		managers.player:set_carry_temporary_data(self:carry_id(), self._dismembered_parts)
	end
end

-- Lines 26-40
function CorpseCarryData:on_thrown()
	self._dismembered_parts = self._dismembered_parts or managers.player:carry_temporary_data(self:carry_id())

	for _, dismember_part in ipairs(self._dismembered_parts or {}) do
		if self:_dismember(dismember_part .. "_no_blood", dismember_part) then
			self:_dismember(dismember_part)
		end
	end

	managers.player:clear_carry_temporary_data(self:carry_id())
	self:_switch_to_ragdoll()
end

local blank_idstr = Idstring("")
local rootfollow_idstr = Idstring("root_follow")

-- Lines 47-71
function CorpseCarryData:_switch_to_ragdoll()
	if not self._unit:damage() or not self._unit:damage():has_sequence("switch_to_ragdoll") then
		return
	end

	self._unit:set_driving("orientation_object")
	self._unit:set_animations_enabled(false)
	self._unit:damage():run_sequence_simple("switch_to_ragdoll")

	self._root_act_tags = {}
	local hips_body = self._unit:body("rag_Hips")
	local tag = hips_body:activate_tag()

	if tag == blank_idstr then
		tag = rootfollow_idstr

		hips_body:set_activate_tag(tag)
	end

	tag = hips_body:deactivate_tag()

	if tag == blank_idstr then
		tag = rootfollow_idstr

		hips_body:set_deactivate_tag(tag)
	end
end

-- Lines 76-94
function CorpseCarryData:_dismember(part_name, decal_name)
	if not self._unit:damage():has_sequence(part_name) then
		return false
	end

	self._unit:damage():run_sequence_simple(part_name)

	local decal_data = tweak_data.character.dismemberment_data.blood_decal_data[decal_name or part_name]

	if decal_data then
		local materials = self._unit:materials()

		for i, material in ipairs(materials) do
			material:set_variable(Idstring("gradient_uv_offset"), Vector3(decal_data[1], decal_data[2], 0))
			material:set_variable(Idstring("gradient_power"), decal_data[3])
		end
	end
end
