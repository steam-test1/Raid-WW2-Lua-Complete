ContourExt = ContourExt or class()
local idstr_contour = Idstring("contour")
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")
local idstr_contour_distance = Idstring("contour_distance")
ContourExt.UNSET_CONTOUR_DISTANCE = 200000
ContourExt._types = {
	teammate = {
		priority = 5,
		ray_check = true,
		persistence = 0.1
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
	friendly = {
		priority = 3,
		color = tweak_data.contour.character.friendly_color
	},
	mark_unit = {
		fadeout = 4.5,
		priority = 4,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous = {
		fadeout = 9,
		priority = 4,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_friendly = {
		fadeout = 9,
		priority = 3,
		color = tweak_data.contour.character.friendly_color
	},
	mark_enemy = {
		fadeout = 4.5,
		priority = 5,
		fadeout_silent = 13.5,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_enemy_damage_bonus = {
		fadeout = 16,
		priority = 4,
		color = tweak_data.contour.character.more_dangerous_color
	},
	mark_enemy_turret = {
		fadeout = 4.5,
		priority = 5,
		fadeout_silent = 13.5,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_enemy_ghost = {
		distance = 3200,
		priority = 6,
		fadeout = 0,
		persistence = 0.1,
		color = tweak_data.contour.character.ghost_warcry
	},
	mark_enemy_sharpshooter = {
		fadeout = 0,
		priority = 3,
		persistence = 0.1,
		color = tweak_data.contour.character.sharpshooter_warcry
	},
	mark_enemy_silver_bullet = {
		distance = 3000,
		priority = 6,
		fadeout = 0,
		persistence = 0.1,
		color = tweak_data.contour.character.silver_bullet_warcry
	},
	highlight = {
		priority = 4,
		color = tweak_data.contour.interactable.standard_color
	},
	highlight_character = {
		priority = 6,
		color = tweak_data.contour.interactable.standard_color
	},
	generic_interactable = {
		priority = 2,
		color = tweak_data.contour.character_interactable.standard_color
	},
	generic_interactable_selected = {
		priority = 1,
		color = tweak_data.contour.character_interactable.selected_color
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

table.sort(ContourExt.indexed_types)

if #ContourExt.indexed_types > 32 then
	Application:error("[ContourExt] max # contour presets exceeded!")
end

ContourExt._MAX_ID = 100000
ContourExt._next_id = 1

function ContourExt:init(unit)
	self._unit = unit
	self._enabled = 1

	self._unit:set_extension_update_enabled(idstr_contour, false)

	ContourExt._slotmask_world_geometry = ContourExt._slotmask_world_geometry or managers.slot:get_mask("world_geometry")

	if self.init_contour then
		self:add(self.init_contour, nil, nil)
	end
end

function ContourExt:add(type, sync, multiplier, damage_multiplier)
	if Global.debug_contour_enabled then
		return
	end

	local data = self._types[type]
	local fadeout = data.fadeout_silent or data.fadeout

	if multiplier and multiplier > 1 then
		fadeout = fadeout * multiplier
	end

	self:_upd_distance(data.distance or ContourExt.UNSET_CONTOUR_DISTANCE)

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

	if damage_multiplier and self._unit:character_damage().on_marked_state then
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

function ContourExt:change_color(type, color)
	if not self._contour_list then
		return
	end

	for i, setup in ipairs(self._contour_list) do
		if setup.type == type then
			setup.color = color

			self:_upd_color()
			self:_material_applied()

			break
		end
	end
end

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

function ContourExt:disable()
	self._materials = self:_get_materials()
	self._enabled = 0

	for _, material in pairs(self._materials) do
		if alive(material) then
			material:set_variable(idstr_contour_color, Vector3(0, 0, 0))
			material:set_variable(idstr_contour_opacity, 0)
			material:set_variable(idstr_contour_distance, 0)
		end
	end
end

function ContourExt:update_materials()
	if self._contour_list and next(self._contour_list) then
		self._materials = nil
		self._last_color = nil
		self._last_opacity = nil
		self._last_distance = nil
		self._target_color = nil
		self._target_opacity = nil
		self._target_distance = nil

		self:_material_applied()
	end
end

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

function ContourExt:enabled()
	return self._enabled > 0
end

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

function ContourExt:update(unit, t, dt)
	local index = 1

	while self._contour_list and index <= #self._contour_list do
		local setup = self._contour_list[index]
		local data = self._types[setup.type]
		local is_current = index == 1

		if data.ray_check and is_current then
			self:_upd_ray_check(t, dt, data, setup)
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

function ContourExt:_upd_ray_check(t, dt, data, setup)
	if not alive(self._unit) or not self._unit:movement() then
		return
	end

	local turn_on = nil
	local cam_pos = managers.viewport:get_current_camera_position()

	if cam_pos then
		turn_on = mvector3.distance_sq(cam_pos, self._unit:movement():m_com()) > 16000000
		turn_on = turn_on or self._unit:raycast("ray", self._unit:movement():m_com(), cam_pos, "slot_mask", self._slotmask_world_geometry, "report")
	end

	if setup.turned_on ~= turn_on then
		if turn_on then
			setup.turned_on = turn_on
			setup.turn_off_t = nil
			self._target_color = setup.color
			self._target_opacity = 1
			self._target_distance = ContourExt.UNSET_CONTOUR_DISTANCE
		elseif data.persistence and not setup.turn_off_t then
			setup.turn_off_t = t + data.persistence
		elseif not data.persistence or setup.turn_off_t <= t then
			setup.turned_on = turn_on
			setup.turn_off_t = nil
			self._target_color = data.off_color
			self._target_opacity = data.off_opacity or 0
			self._target_distance = ContourExt.UNSET_CONTOUR_DISTANCE
		end
	end

	if self._target_color and self._last_color ~= self._target_color then
		local color = math.step(self._last_color or setup.color, self._target_color, 5 * dt)

		self:_upd_color(color)
	end

	if self._target_opacity and self._last_opacity ~= self._target_opacity then
		local opacity = math.step(self._last_opacity or 0, self._target_opacity, 5 * dt)

		self:_upd_opacity(opacity)
	end

	if self._target_distance and self._last_distance ~= self._target_distance then
		local distance = self._target_distance

		self:_upd_distance(distance)
	end
end

function ContourExt:_upd_color(color, is_retry)
	color = color or self._types[self._contour_list[1].type].color or self._contour_list[1].color

	if not color or color == self._last_color then
		return
	end

	self._last_color = color
	self._materials = self:_get_materials()

	for _, material in ipairs(self._materials) do
		if not alive(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_color(color, true)
			end

			return
		end

		material:set_variable(idstr_contour_color, color * self._enabled)
	end
end

function ContourExt:_upd_opacity(opacity, is_retry)
	if opacity == self._last_opacity then
		return
	end

	if Global.debug_contour_enabled and opacity == 1 then
		return
	end

	self._last_opacity = opacity
	self._materials = self:_get_materials()

	for _, material in ipairs(self._materials) do
		if not alive(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_opacity(opacity, true)
			end

			return
		end

		material:set_variable(idstr_contour_opacity, opacity * self._enabled)
	end
end

function ContourExt:_upd_distance(distance, is_retry)
	if distance == self._last_distance then
		return
	end

	self._last_distance = distance
	self._materials = self:_get_materials()

	for _, material in ipairs(self._materials) do
		if not alive(material) then
			self:update_materials()

			if not is_retry then
				self:_upd_distance(distance, true)
			end

			return
		end

		material:set_variable(idstr_contour_distance, distance * self._enabled)
	end
end

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
				if alive(material) then
					material:set_variable(idstr_contour_opacity, 0)
				else
					Application:error("[function ContourExt:_remove] Tried setting vars on a dead material", material)
				end
			end
		end

		if self._damage_bonus then
			self._unit:character_damage():on_marked_state(false)

			self._damage_bonus = nil
		end
	end

	self._last_color = nil
	self._last_opacity = nil
	self._last_distance = nil
	self._target_color = nil
	self._target_opacity = nil
	self._target_distance = nil

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

function ContourExt:_get_materials()
	if self._materials then
		return self._materials
	end

	local check_units = {}
	local materials = {}
	local customization = self._unit:customization()

	if customization and customization:has_attached_units() then
		table.map_append(check_units, customization:attached_units())
	else
		table.insert(check_units, self._unit)
	end

	local spawned_gear = self._unit:base().get_spawned_gear and self._unit:base():get_spawned_gear()

	if spawned_gear then
		for _, gear in ipairs(spawned_gear) do
			if alive(gear.unit) and gear.unit:acc_gear() then
				table.insert(check_units, gear.unit)
			end
		end
	end

	local inventory = self._unit:inventory()
	local weapon = inventory and inventory.get_weapon and inventory:get_weapon()

	if weapon then
		table.insert(check_units, weapon)
	end

	if check_units then
		for _, u in pairs(check_units) do
			if alive(u) then
				for _, m in ipairs(u:materials()) do
					if m:variable_exists(idstr_contour_color) then
						table.insert(materials, m)
					end
				end
			end
		end
	end

	return materials
end

function ContourExt:_apply_top_preset()
	local setup = self._contour_list[1]
	local data = self._types[setup.type]
	self._last_color = nil
	self._last_opacity = nil
	self._last_distance = nil
	self._target_color = nil
	self._target_opacity = nil
	self._target_distance = nil

	if data.material_swap_required then
		self._materials = nil

		if self._unit:base():is_in_original_material() then
			self._unit:base():swap_material_config(callback(self, ContourExt, "_material_applied", true))
		else
			self:_material_applied()
		end
	else
		managers.occlusion:remove_occlusion(self._unit)
		self:_material_applied()
	end
end

function ContourExt:_material_applied()
	if not self._contour_list then
		return
	end

	local setup = self._contour_list[1]
	local data = self._types[setup.type]
	self._materials = nil

	if data.ray_check then
		setup.turned_on = nil

		self:_upd_color(data.off_color)
		self:_upd_opacity(data.off_opacity or 0)
		self:_upd_distance(data.off_distance or 0)
	else
		self:_upd_color()
		self:_upd_opacity(1)
		self:_upd_distance(ContourExt.UNSET_CONTOUR_DISTANCE)
	end
end

function ContourExt:_clear()
	self._contour_list = nil
	self._materials = nil
end

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

function ContourExt:load(data)
	if data and data.highlight_character then
		self:add(data.highlight_character.type)
	end
end
