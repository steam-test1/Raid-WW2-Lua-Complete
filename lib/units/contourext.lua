ContourExt = ContourExt or class()
local idstr_contour = Idstring("contour")
local idstr_material = Idstring("material")
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")
ContourExt._types = {
	teammate = {
		priority = 5,
		ray_check = true,
		off_opacity = 1,
		persistence = 0.3,
		off_color = Vector3(0, 0, 0)
	},
	teammate_downed = {
		priority = 4,
		color = tweak_data.contour.character.downed_color
	},
	teammate_downed_selected = {
		priority = 3,
		color = tweak_data.contour.character_interactable.selected_color
	},
	teammate_dead = {
		priority = 4,
		color = tweak_data.contour.character.dead_color
	},
	teammate_cuffed = {
		priority = 4,
		color = tweak_data.contour.character.downed_color
	},
	friendly = {
		priority = 3,
		material_swap_required = true,
		color = tweak_data.contour.character.friendly_color
	},
	drunk_pilot = {
		priority = 5
	},
	boris = {
		priority = 5
	},
	taxman = {
		priority = 5,
		color = tweak_data.contour.character_interactable.standard_color
	},
	mark_unit = {
		priority = 4,
		fadeout = 4.5,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous = {
		priority = 4,
		fadeout = 9,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_friendly = {
		priority = 3,
		fadeout = 9,
		color = tweak_data.contour.character.friendly_color
	},
	mark_enemy = {
		fadeout = 4.5,
		priority = 5,
		material_swap_required = true,
		fadeout_silent = 13.5,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_enemy_ghost = {
		fadeout = 0,
		priority = 2,
		material_swap_required = true,
		persistence = 0,
		color = tweak_data.contour.character.ghost_warcry
	},
	mark_enemy_sharpshooter = {
		fadeout = 0,
		priority = 0,
		material_swap_required = true,
		persistence = 0,
		color = tweak_data.contour.character.sharpshooter_warcry
	},
	mark_enemy_damage_bonus = {
		fadeout = 4.5,
		priority = 4,
		material_swap_required = true,
		damage_bonus = true,
		fadeout_silent = 13.5,
		color = tweak_data.contour.character.more_dangerous_color
	},
	highlight = {
		priority = 4,
		color = tweak_data.contour.interactable.standard_color
	},
	highlight_character = {
		priority = 6,
		material_swap_required = true,
		color = tweak_data.contour.interactable.standard_color
	},
	generic_interactable = {
		priority = 2,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.standard_color
	},
	generic_interactable_selected = {
		priority = 1,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.selected_color
	},
	hostage_trade = {
		priority = 1,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.standard_color
	},
	deployable_selected = {
		priority = 1,
		unique = true,
		color = tweak_data.contour.deployable.selected_color
	},
	deployable_disabled = {
		priority = 2,
		unique = true,
		color = tweak_data.contour.deployable.disabled_color
	},
	deployable_active = {
		priority = 3,
		unique = true,
		color = tweak_data.contour.deployable.active_color
	},
	deployable_interactable = {
		priority = 4,
		unique = true,
		color = tweak_data.contour.deployable.interact_color
	}
}
ContourExt.indexed_types = {}

for name, preset in pairs(ContourExt._types) do
	table.insert(ContourExt.indexed_types, name)
end

if #ContourExt.indexed_types > 32 then
	Application:error("[ContourExt] max # contour presets exceeded!")
end

ContourExt._MAX_ID = 100000
ContourExt._next_id = 1

-- Lines 159-171
function ContourExt:init(unit)
	self._unit = unit
	self._enabled = 1

	self._unit:set_extension_update_enabled(idstr_contour, false)

	ContourExt._slotmask_world_geometry = ContourExt._slotmask_world_geometry or managers.slot:get_mask("world_geometry")

	if self.init_contour then
		self:add(self.init_contour, nil, nil)
	end
end

-- Lines 173-175
function ContourExt:enabled()
	return self._enabled > 0
end

-- Lines 177-245
function ContourExt:add(type, sync, multiplier, damage_multiplier)
	if Global.debug_contour_enabled then
		return
	end

	local data = self._types[type]
	local fadeout = data.fadeout

	if data.fadeout_silent and self._unit:base():char_tweak().silent_priority_shout then
		fadeout = data.fadeout_silent
	end

	if multiplier and multiplier > 1 then
		fadeout = fadeout * multiplier
	end

	self._contour_list = self._contour_list or {}

	if sync then
		local u_id = self._unit:id()

		managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, u_id, table.index_of(ContourExt.indexed_types, type), true, multiplier or 1, damage_multiplier or 1)
	end

	for _, setup in ipairs(self._contour_list) do
		if setup.type == type then
			if fadeout then
				setup.fadeout_t = TimerManager:game():time() + fadeout
			elseif not self._types[setup.type].unique then
				setup.ref_c = (setup.ref_c or 0) + 1
			end

			return setup
		end
	end

	if damage_multiplier and damage_multiplier > 1 then
		self._unit:character_damage():on_marked_state(true, damage_multiplier)

		self._damage_bonus = true
	end

	local setup = {
		ref_c = 1,
		type = type,
		fadeout_t = fadeout and TimerManager:game():time() + fadeout or nil,
		sync = sync
	}
	local old_preset_type = self._contour_list[1] and self._contour_list[1].type
	local i = 1

	while self._contour_list[i] and self._types[self._contour_list[i].type].priority <= data.priority do
		i = i + 1
	end

	table.insert(self._contour_list, i, setup)

	if old_preset_type ~= setup.type then
		self:_apply_top_preset()
	end

	if not self._update_enabled then
		self:_chk_update_state()
	end

	return setup
end

-- Lines 247-259
function ContourExt:change_color(type, color)
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.type == type then
			setup.color = color

			self:_upd_color()

			break
		end
	end
end

-- Lines 262-278
function ContourExt:_set_color(type, color)
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.type == type then
			self._materials = self:_get_materials()

			for _, material in ipairs(self._materials) do
				if alive(material) then
					material:set_variable(idstr_contour_color, color * self._enabled)
				end
			end
		end

		return
	end
end

-- Lines 280-294
function ContourExt:flash(type_or_id, frequency)
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.type == type_or_id or setup == type_or_id then
			setup.flash_frequency = frequency and frequency > 0 and frequency or nil
			setup.flash_t = setup.flash_frequency and TimerManager:game():time() + setup.flash_frequency or nil
			setup.flash_on = nil

			self:_chk_update_state()

			break
		end
	end
end

-- Lines 296-306
function ContourExt:is_flashing()
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.flash_frequency then
			return true
		end
	end
end

-- Lines 308-319
function ContourExt:disable()
	self._materials = self:_get_materials()
	self._enabled = 0

	for _, material in pairs(self._materials) do
		if alive(material) then
			material:set_variable(idstr_contour_opacity, 0)
			material:set_variable(idstr_contour_color, Vector3(0, 0, 0))
			material:set_variable(Idstring("contour_distance"), 0)
		end
	end
end

-- Lines 321-337
function ContourExt:remove(type, sync)
	if not self._contour_list then
		return
	end

	local contour_list = clone(self._contour_list)

	for i, setup in ipairs(contour_list) do
		if setup.type == type then
			self:_remove(i, sync)

			if self._update_enabled then
				self:_chk_update_state()
			end

			return
		end
	end
end

-- Lines 339-354
function ContourExt:remove_by_id(id, sync)
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup == id then
			self:_remove(i, sync)

			if self._update_enabled then
				self:_chk_update_state()
			end

			return
		end
	end
end

-- Lines 356-359
function ContourExt:_clear()
	self._contour_list = nil
	self._materials = nil
end

-- Lines 361-410
function ContourExt:_remove(index, sync)
	local setup = self._contour_list[index]

	if not setup then
		return
	end

	local contour_type = setup.type
	local data = self._types[setup.type]

	if setup.ref_c and setup.ref_c > 1 then
		setup.ref_c = setup.ref_c - 1

		return
	end

	if #self._contour_list == 1 then
		managers.occlusion:add_occlusion(self._unit)

		if data.material_swap_required then
			self._unit:base():set_material_state(true)
			self._unit:base():set_allow_invisible(true)
		else
			for _, material in ipairs(self._materials) do
				material:set_variable(idstr_contour_opacity, 0)
			end
		end

		if self._damage_bonus then
			self._unit:character_damage():on_marked_state(false)

			self._damage_bonus = nil
		end
	end

	self._last_opacity = nil

	table.remove(self._contour_list, index)

	if #self._contour_list == 0 then
		self:_clear()
	elseif index == 1 then
		self:_apply_top_preset()
	end

	if sync then
		local u_id = self._unit:id()

		managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, u_id, table.index_of(ContourExt.indexed_types, contour_type), false, 1, 1)
	end
end

-- Lines 412-468
function ContourExt:update(unit, t, dt)
	local index = 1

	while self._contour_list and index <= #self._contour_list do
		local setup = self._contour_list[index]
		local data = self._types[setup.type]
		local is_current = index == 1

		if data.ray_check then
			local turn_on = nil

			if is_current then
				local cam_pos = managers.viewport:get_current_camera_position()

				if cam_pos then
					turn_on = mvector3.distance_sq(cam_pos, unit:movement():m_com()) > 16000000
					turn_on = turn_on or unit:raycast("ray", unit:movement():m_com(), cam_pos, "slot_mask", self._slotmask_world_geometry, "report")
				end
			end

			if turn_on then
				self:_upd_color()
				self:_upd_opacity(1)

				setup.last_turned_on_t = t
			elseif not setup.last_turned_on_t or data.persistence < t - setup.last_turned_on_t then
				local color = data.off_color or setup.color

				self:_set_color(setup.type, color)

				if is_current then
					local op = data.off_opacity or 0

					self:_upd_opacity(op)
				end

				setup.last_turned_on_t = nil
			end
		end

		if setup.flash_t and setup.flash_t < t then
			setup.flash_t = t + setup.flash_frequency
			setup.flash_on = not setup.flash_on

			self:_upd_opacity(setup.flash_on and 1 or 0)
		end

		if setup.fadeout_t and setup.fadeout_t < t then
			self:_remove(index)
			self:_chk_update_state()
		else
			index = index + 1
		end
	end
end

-- Lines 471-488
function ContourExt:_get_materials()
	local customization = self._unit:customization()

	if customization and customization._attached_units then
		local materials = {}

		for _, attached_unit in pairs(customization._attached_units) do
			if alive(attached_unit) then
				for _, material in ipairs(attached_unit:materials()) do
					table.insert(materials, material)
				end
			end
		end

		return materials
	else
		return self._materials or self._unit:get_objects_by_type(idstr_material)
	end
end

-- Lines 491-513
function ContourExt:_upd_opacity(opacity, is_retry)
	if opacity == self._last_opacity then
		return
	end

	if Global.debug_contour_enabled and opacity == 1 then
		return
	end

	self._materials = self:_get_materials()

	for _, material in ipairs(self._materials) do
		if not alive(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_opacity(opacity, true)

				self._last_opacity = opacity
			end

			return
		end

		material:set_variable(idstr_contour_opacity, opacity * self._enabled)
	end
end

-- Lines 515-532
function ContourExt:_upd_color(is_retry)
	local color = self._types[self._contour_list[1].type].color or self._contour_list[1].color

	if not color then
		return
	end

	self._materials = self:_get_materials()

	for _, material in ipairs(self._materials) do
		if not alive(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_color(true)
			end

			return
		end

		material:set_variable(idstr_contour_color, color * self._enabled)
	end
end

-- Lines 534-553
function ContourExt:_apply_top_preset()
	local setup = self._contour_list[1]
	local data = self._types[setup.type]
	self._last_opacity = nil

	if data.material_swap_required then
		self._materials = nil
		self._last_opacity = nil

		if self._unit:base():is_in_original_material() then
			self._unit:base():swap_material_config(callback(self, ContourExt, "material_applied", true))
		else
			self:material_applied()
		end
	else
		managers.occlusion:remove_occlusion(self._unit)
		self:material_applied()
	end
end

-- Lines 555-568
function ContourExt:material_applied()
	if not self._contour_list then
		return
	end

	local setup = self._contour_list[1]
	local data = self._types[setup.type]
	self._materials = nil

	self:_upd_color()

	if not data.ray_check then
		self:_upd_opacity(1)
	end
end

-- Lines 570-586
function ContourExt:_chk_update_state()
	local needs_update = nil

	if self._contour_list and next(self._contour_list) then
		for i, setup in ipairs(self._contour_list) do
			if setup.fadeout_t or self._types[setup.type].ray_check or setup.flash_t then
				needs_update = true

				break
			end
		end
	end

	if self._update_enabled ~= needs_update then
		self._update_enabled = needs_update

		self._unit:set_extension_update_enabled(idstr_contour, needs_update and true or false)
	end
end

-- Lines 588-596
function ContourExt:update_materials()
	if self._contour_list and next(self._contour_list) then
		self._materials = nil

		self:_upd_color()

		self._last_opacity = nil

		self:_upd_opacity(1)
	end
end

-- Lines 598-607
function ContourExt:save(data)
	if self._contour_list then
		for _, setup in ipairs(self._contour_list) do
			if setup.type == "highlight_character" and setup.sync then
				data.highlight_character = setup

				return
			end
		end
	end
end

-- Lines 609-613
function ContourExt:load(data)
	if data and data.highlight_character then
		self:add(data.highlight_character.type)
	end
end
