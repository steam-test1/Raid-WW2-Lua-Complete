HUDMapTab = HUDMapTab or class(HUDMapBase)
HUDMapTab.BACKGROUND_LAYER = 1
HUDMapTab.INNER_PANEL_LAYER = 2
HUDMapTab.WAYPOINT_PANEL_LAYER = 3
HUDMapTab.PLAYER_PINS_LAYER = 5
HUDMapTab.PIN_PANEL_PADDING = 50

-- Lines 9-18
function HUDMapTab:init(panel, params)
	HUDMapTab.super.init(self, params)
	self:_create_panel(panel, params)
	self:_create_inner_panel()
	self:_create_pin_panel()
	self:_create_waypoint_panel()

	self._waypoints = {}
end

-- Lines 20-27
function HUDMapTab:_create_panel(panel, params)
	local panel_params = {
		halign = "scale",
		name = "map_panel",
		valign = "scale",
		layer = params.layer or panel:layer()
	}
	self._object = panel:panel(panel_params)
end

-- Lines 29-36
function HUDMapTab:_create_inner_panel()
	local inner_panel_params = {
		halign = "center",
		name = "inner_panel",
		valign = "center",
		layer = HUDMapTab.INNER_PANEL_LAYER
	}
	self._inner_panel = self._object:panel(inner_panel_params)
end

-- Lines 38-50
function HUDMapTab:_create_pin_panel()
	if self._object:child("player_pins_panel") then
		self._object:child("player_pins_panel"):clear()
		self._object:remove(self._object:child("player_pins_panel"))
	end

	local player_pins_panel_params = {
		halign = "scale",
		name = "player_pins_panel",
		valign = "scale",
		layer = HUDMapTab.PLAYER_PINS_LAYER
	}
	local player_pins_panel = self._inner_panel:panel(player_pins_panel_params)
end

-- Lines 52-64
function HUDMapTab:_create_waypoint_panel()
	if self._object:child("waypoint_panel") then
		self._object:child("waypoint_panel"):clear()
		self._object:remove(self._object:child("waypoint_panel"))
	end

	local waypoint_panel_params = {
		halign = "scale",
		name = "waypoint_panel",
		valign = "scale",
		layer = HUDMapTab.WAYPOINT_PANEL_LAYER
	}
	local waypoint_panel = self._inner_panel:panel(waypoint_panel_params)
end

-- Lines 66-76
function HUDMapTab:_fit_inner_panel()
	local panel_shape = tweak_data.levels[self._current_level].map.panel_shape
	local background_panel = self._object:child("map_background_panel")
	local x = background_panel:x() + panel_shape.x - HUDMapTab.PIN_PANEL_PADDING
	local y = background_panel:y() + panel_shape.y - HUDMapTab.PIN_PANEL_PADDING
	local w = panel_shape.w + HUDMapTab.PIN_PANEL_PADDING * 2
	local h = panel_shape.h + HUDMapTab.PIN_PANEL_PADDING * 2

	self._inner_panel:set_shape(x, y, w, h)
end

-- Lines 78-85
function HUDMapTab:_create_player_pins()
	local pin_panel = self._inner_panel:child("player_pins_panel")

	pin_panel:clear()

	self._player_pins = {}

	self:_create_peer_pins(pin_panel)
	self:_create_ai_pins(pin_panel)
end

-- Lines 88-104
function HUDMapTab:_create_peer_pins(panel)
	local peers = managers.network:session():all_peers()

	for index, peer in pairs(peers) do
		local peer_pin_params = {
			id = index,
			nationality = peer:character()
		}
		local peer_pin = HUDMapPlayerPin:new(panel, peer_pin_params)

		if peer == managers.network:session():local_peer() then
			self._local_player_pin = peer_pin
		end

		table.insert(self._player_pins, peer_pin)
	end
end

-- Lines 107-121
function HUDMapTab:_create_ai_pins(panel)
	local ai_characters = managers.criminals:ai_criminals()
	local peer_pins_number = #self._player_pins

	for index, ai_character in pairs(ai_characters) do
		local peer_pin_params = {
			ai = true,
			id = peer_pins_number + index,
			nationality = ai_character.name
		}
		local peer_pin = HUDMapPlayerPin:new(panel, peer_pin_params)

		table.insert(self._player_pins, peer_pin)
	end
end

-- Lines 123-130
function HUDMapTab:_setup_level(level)
	self:_set_level(level)
	self:_create_map_background()
	self:_fit_inner_panel()
	self:_create_base_icon()
	self:_create_player_pins()
	self:_create_waypoints()
end

-- Lines 132-155
function HUDMapTab:_create_map_background()
	if self._object:child("map_background_panel") then
		self._object:remove(self._object:child("map_background_panel"))
	end

	local map_texture = tweak_data.levels[self._current_level].map.texture
	local background_panel_params = {
		name = "map_background_panel",
		halign = "center",
		valign = "center",
		w = tweak_data.gui:icon_w(map_texture),
		h = tweak_data.gui:icon_h(map_texture),
		layer = HUDMapTab.BACKGROUND_LAYER
	}
	local background_panel = self._object:panel(background_panel_params)

	background_panel:set_center_x(self._object:w() / 2)
	background_panel:set_center_y(self._object:h() / 2)

	local background_image_params = {
		name = "background_image",
		texture = tweak_data.gui.icons[map_texture].texture,
		texture_rect = tweak_data.gui.icons[map_texture].texture_rect
	}
	local background_image = background_panel:bitmap(background_image_params)
end

-- Lines 157-173
function HUDMapTab:_create_base_icon()
	local background_panel = self._object:child("map_background_panel")

	if self._inner_panel:child("base_icon") then
		self._inner_panel:remove(self._inner_panel:child("base_icon"))
	end

	local base_x, base_y = self:_get_map_position(tweak_data.levels[self._current_level].map.base_location.x, tweak_data.levels[self._current_level].map.base_location.y)
	local base_icon_texture = tweak_data.levels[self._current_level].map.base_icon or "map_camp"
	local base_icon_params = {
		name = "base_icon",
		texture = tweak_data.gui.icons[base_icon_texture].texture,
		texture_rect = tweak_data.gui.icons[base_icon_texture].texture_rect
	}
	local base_icon = self._inner_panel:bitmap(base_icon_params)

	base_icon:set_center_x(base_x)
	base_icon:set_center_y(base_y)
end

-- Lines 175-185
function HUDMapTab:_create_waypoints()
	local waypoint_panel = self._inner_panel:child("waypoint_panel")
	local waypoints = managers.hud:get_all_waypoints()

	waypoint_panel:clear()

	self._waypoints = {}

	for index, waypoint_data in pairs(waypoints) do
		self:_create_waypoint(waypoint_data)
	end
end

-- Lines 187-207
function HUDMapTab:_create_waypoint(waypoint_data)
	local waypoint_panel = self._inner_panel:child("waypoint_panel")

	if self._waypoints[waypoint_data.id_string] then
		self:remove_waypoint(waypoint_data.id_string)
	end

	if waypoint_data.waypoint_radius then
		waypoint_data.waypoint_radius = waypoint_data.waypoint_radius * self:_get_map_size_factor()
	end

	local waypoint = HUDMapWaypointBase.create(waypoint_panel, waypoint_data)

	if waypoint then
		self._waypoints[waypoint_data.id_string] = waypoint
	end
end

-- Lines 209-222
function HUDMapTab:show()
	if not self:_current_level_has_map() then
		return
	end

	local current_level = self:_get_current_player_level()

	if current_level ~= self._current_level then
		self:_setup_level(current_level)
	end

	self._object:set_visible(true)
	HUDMapTab.super.show(self)
end

-- Lines 224-227
function HUDMapTab:hide()
	self._object:set_visible(false)
	HUDMapTab.super.hide(self)
end

-- Lines 229-235
function HUDMapTab:refresh_peers()
	if not self:_current_level_has_map() then
		return
	end

	self:_create_player_pins()
end

-- Lines 237-239
function HUDMapTab:add_waypoint(data)
	self:_create_waypoint(data)
end

-- Lines 241-248
function HUDMapTab:remove_waypoint(id)
	local waypoint_panel = self._inner_panel:child("waypoint_panel")

	if self._waypoints[id] then
		self._waypoints[id]:destroy()

		self._waypoints[id] = nil
	end
end

-- Lines 250-261
function HUDMapTab:peer_enter_vehicle(peer_id)
	if not self._player_pins then
		return
	end
end

-- Lines 263-274
function HUDMapTab:peer_exit_vehicle(peer_id)
	if not self._player_pins then
		return
	end
end

-- Lines 276-280
function HUDMapTab:update()
	self:_update_peer_positions()
	self:_update_ai_positions()
	self:_update_waypoints()
end

-- Lines 282-297
function HUDMapTab:_update_peer_positions()
	local peers = managers.network:session():all_peers()

	for index, peer in pairs(peers) do
		local unit = peer:unit()

		if alive(unit) then
			local map_x, map_y = self:_get_map_position(unit:position().x, unit:position().y)

			self._player_pins[index]:show()
			self._player_pins[index]:set_position(map_x, map_y)
		else
			self._player_pins[index]:hide()
		end
	end
end

-- Lines 299-317
function HUDMapTab:_update_ai_positions()
	local ai_characters = managers.criminals:ai_criminals()
	local peer_pins_number = managers.network:session():count_all_peers()

	for index, ai_character in pairs(ai_characters) do
		if self._player_pins[peer_pins_number + index] then
			local unit = ai_character.unit

			if alive(unit) then
				local map_x, map_y = self:_get_map_position(unit:position().x, unit:position().y)

				self._player_pins[peer_pins_number + index]:show()
				self._player_pins[peer_pins_number + index]:set_position(map_x, map_y)
			else
				self._player_pins[peer_pins_number + index]:hide()
			end
		end
	end
end

-- Lines 319-329
function HUDMapTab:_update_waypoints()
	local all_waypoints = managers.hud:get_all_waypoints()

	for index, waypoint_data in pairs(all_waypoints) do
		if self._waypoints[index] then
			local map_x, map_y = self:_get_map_position(waypoint_data.position.x, waypoint_data.position.y)

			self._waypoints[index]:set_position(map_x, map_y)
			self._waypoints[index]:set_data(waypoint_data)
		end
	end
end

-- Lines 331-336
function HUDMapTab:_get_map_position(world_x, world_y)
	local map_x = HUDMapTab.PIN_PANEL_PADDING + (world_x - self._world_borders.left) / math.abs(self._world_borders.right - self._world_borders.left) * (self._inner_panel:w() - HUDMapTab.PIN_PANEL_PADDING * 2)
	local map_y = HUDMapTab.PIN_PANEL_PADDING + math.abs(world_y - self._world_borders.up) / math.abs(self._world_borders.down - self._world_borders.up) * (self._inner_panel:h() - HUDMapTab.PIN_PANEL_PADDING * 2)

	return map_x, map_y
end

-- Lines 339-348
function HUDMapTab:_get_map_size_factor()
	if not self._world_borders then
		return 1
	end

	local world_w = self._world_borders.right - self._world_borders.left
	local map_w = self._inner_panel:w()

	return map_w / world_w
end
