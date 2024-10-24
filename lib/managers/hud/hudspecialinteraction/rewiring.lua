HUDSpecialInteractionRewiring = HUDSpecialInteractionRewiring or class(HUDSpecialInteraction)
HUDSpecialInteractionRewiring.GAME_WIDTH = 512
HUDSpecialInteractionRewiring.GAME_HEIGHT = 512
HUDSpecialInteractionRewiring.PADDING_Y = 64
HUDSpecialInteractionRewiring.PADDING_X = 64
HUDSpecialInteractionRewiring._DEFAULT_NODE_COUNT = 3
HUDSpecialInteractionRewiring._GUI_REFS = {
	b_u_l = "interact_rewire_node_bend_up_left",
	trap = "interact_rewire_node_trap",
	b_d_r = "interact_rewire_node_bend_down_right",
	dead = "interact_rewire_node_dead",
	b_d_l = "interact_rewire_node_bend_down_left",
	line = "interact_rewire_node_line",
	b_u_r = "interact_rewire_node_bend_up_right"
}
HUDSpecialInteractionRewiring._DEBUGGERY = false

function HUDSpecialInteractionRewiring:init(hud, params)
	HUDSpecialInteractionRewiring.super.init(self, hud, params)

	self._current_step = 1
	self._final_step_index = self:get_tweak_value("node_count_y", HUDSpecialInteractionRewiring._DEFAULT_NODE_COUNT)
	self._starting_direction = self:get_tweak_value("starting_direction", math.rand_bool())

	self:_setup_slot_queue()

	local size_inside_x = HUDSpecialInteractionRewiring.GAME_WIDTH - HUDSpecialInteractionRewiring.PADDING_X * 2
	local size_inside_y = HUDSpecialInteractionRewiring.GAME_HEIGHT - HUDSpecialInteractionRewiring.PADDING_Y * 2
	self._interact_rewire_inside_panel = self._object:panel({
		layer = 5,
		h = nil,
		w = nil,
		name = "_interact_rewire_inside_panel",
		w = size_inside_x,
		h = size_inside_y
	})

	self._interact_rewire_inside_panel:set_center(self._object:center())
	self:_create_interact_rewire_bg()
	self:_create_interact_rewire_fg()
	self:_layout_nodes()
	self:_update_colors()
	self:_update_all_slot_art()
end

function HUDSpecialInteractionRewiring:_create_interact_rewire_bg()
	self._interact_rewire_bg = self._object:bitmap({
		layer = 1,
		texture_rect = nil,
		texture = nil,
		name = "_interact_rewire_bg",
		texture = tweak_data.gui.icons.interact_rewire_bg.texture,
		texture_rect = tweak_data.gui.icons.interact_rewire_bg.texture_rect
	})

	self._interact_rewire_bg:set_center(self._object:center())
end

function HUDSpecialInteractionRewiring:_create_interact_rewire_fg()
	self._interact_rewire_fg = self._object:bitmap({
		layer = 10,
		texture_rect = nil,
		texture = nil,
		name = "_interact_rewire_fg",
		texture = tweak_data.gui.icons.interact_rewire_fg.texture,
		texture_rect = tweak_data.gui.icons.interact_rewire_fg.texture_rect
	})

	self._interact_rewire_fg:set_center(self._object:center())
end

function HUDSpecialInteractionRewiring:_setup_slot_queue()
	local node_types = self:get_tweak_value("node_types", {
		line = 1
	})
	local min_slot_nodes_needed = self:get_tweak_value("node_count_y", HUDSpecialInteractionRewiring._DEFAULT_NODE_COUNT) * self:get_tweak_value("node_count_x", HUDSpecialInteractionRewiring._DEFAULT_NODE_COUNT)
	self._slot_node_queue_index = 1
	self._slot_node_queue = {}

	while min_slot_nodes_needed >= #self._slot_node_queue do
		for node_key, node_amount in pairs(node_types) do
			table.fill_with_item(self._slot_node_queue, node_key, node_amount)
		end
	end

	self._slot_node_queue = table.shuffled(self._slot_node_queue)

	if HUDSpecialInteractionRewiring._DEBUGGERY then
		self._debuggery_queue = self._object:text({
			w = 2000,
			y = 100,
			x = 160,
			layer = 99,
			font_size = nil,
			font = nil,
			color = nil,
			h = 75,
			text = "WABBUBUBU 1",
			name = "_debuggery_queue",
			color = Color(0.937, 0.4, 0.1),
			font = HUDSpecialInteraction.LEGEND_FONT,
			font_size = HUDSpecialInteraction.LEGEND_FONT_SIZE
		})
		local txt = ""

		for i, v in ipairs(self._slot_node_queue) do
			txt = txt .. tostring(v)

			if i == 5 then
				break
			end

			txt = txt .. ", "
		end

		self._debuggery_queue:set_text(txt)
	end
end

function HUDSpecialInteractionRewiring:_get_next_slot_queued()
	self._slot_node_queue_index = self._slot_node_queue_index + 1

	if self._slot_node_queue_index > #self._slot_node_queue then
		self._slot_node_queue = table.shuffled(self._slot_node_queue)
		self._slot_node_queue_index = 1
	end

	return self._slot_node_queue[self._slot_node_queue_index]
end

function HUDSpecialInteractionRewiring:_layout_nodes()
	self._interact_node_panels = {}
	self._interact_nodes = {}
	self._interact_node_row_data = {}
	local node_count_x = self:get_tweak_value("node_count_x", 3)
	local node_count_y = self:get_tweak_value("node_count_y", 3)
	local size_x = self._interact_rewire_inside_panel:w() / node_count_x
	local size_y = self._interact_rewire_inside_panel:h() / node_count_x

	for y = 1, node_count_y do
		self._interact_nodes[y] = self._interact_nodes[y] or {}
		self._interact_node_row_data[y] = self._interact_node_row_data[y] or {
			row_x_id = nil,
			row_nodes = nil,
			row_x_id = {},
			row_nodes = {}
		}
		local node_panel = self._interact_rewire_inside_panel:panel({
			w = nil,
			y = nil,
			x = 0,
			name = nil,
			h = nil,
			visible = true,
			name = "_interact_node_panel_" .. tostring(y),
			y = (y - 1) * size_y,
			w = (node_count_x + 1) * size_x,
			h = size_y
		})

		table.insert(self._interact_node_panels, node_panel)

		if HUDSpecialInteractionRewiring._DEBUGGERY then
			local node_panel_debuggery = self._object:text({
				w = 600,
				y = nil,
				x = 100,
				layer = 99,
				font_size = nil,
				font = nil,
				color = nil,
				h = 80,
				text = "WABBUBUBU",
				name = nil,
				name = "_debuggery_" .. tostring(y),
				color = Color(0.937, 0.6, 0.2),
				font = HUDSpecialInteraction.LEGEND_FONT,
				font_size = HUDSpecialInteraction.LEGEND_FONT_SIZE * 0.7,
				y = 200 + y * 80
			})
			self._interact_node_panels_DEBUGGERY = self._interact_node_panels_DEBUGGERY or {}

			table.insert(self._interact_node_panels_DEBUGGERY, node_panel_debuggery)
		end

		for x = 1, node_count_x + 1 do
			table.insert(self._interact_node_row_data[y].row_x_id, x)

			local gui_id = math.rand_bool() and "interact_rewire_node_dead" or "interact_rewire_node_line"
			local bitmap_data = {
				color = nil,
				texture_rect = nil,
				x = nil,
				name = nil,
				h = nil,
				w = nil,
				texture = nil,
				name = "_interact_node_" .. tostring(y) .. "_" .. tostring(x),
				texture = tweak_data.gui.icons[gui_id].texture,
				texture_rect = tweak_data.gui.icons[gui_id].texture_rect,
				x = (x - 1) * size_x,
				w = size_x,
				h = size_y,
				color = HUDSpecialInteractionLockPick.CIRCLE_COLOR
			}
			local node = node_panel:bitmap(bitmap_data)

			table.insert(self._interact_nodes[y], node)

			local row_data = self._interact_node_row_data[y]
			local next_slot_queue = nil

			if self._prev_bend_slot then
				next_slot_queue = "b_" .. (not self._prev_bend_slot_was_up and "u" or "d") .. (self._starting_direction and "_r" or "_l")
				row_data.row_nodes[x] = next_slot_queue
				self._prev_bend_slot = false
			else
				next_slot_queue = self:_get_next_slot_queued()

				if next_slot_queue == "bend" then
					self._prev_bend_slot = true
					self._prev_bend_slot_was_up = math.rand_bool()
					next_slot_queue = "b_" .. (self._prev_bend_slot_was_up and "u" or "d") .. (not self._starting_direction and "_r" or "_l")
				end

				row_data.row_nodes[x] = next_slot_queue
			end

			table.insert(self._interact_node_row_data[y].row_nodes, next_slot_queue)

			local txt = HUDSpecialInteractionRewiring._DEBUGGERY and node_panel:text({
				w = 80,
				y = 4,
				x = nil,
				layer = 99,
				font_size = nil,
				font = nil,
				color = nil,
				h = 80,
				text = nil,
				name = nil,
				name = "_debuggery_txtid_" .. tostring(y),
				text = "X" .. tostring(x) .. "\nY" .. tostring(y),
				color = Color(1, 0.1, 1),
				font = HUDSpecialInteraction.LEGEND_FONT,
				font_size = HUDSpecialInteraction.LEGEND_FONT_SIZE,
				x = bitmap_data.x + 8
			})
		end
	end
end

function HUDSpecialInteractionRewiring:_current_step_forward()
	local panel = self._interact_node_panels[self._current_step]
	local node_w = self._interact_nodes[self._current_step][1]:w()

	panel:animate(callback(self, self, "_animate_snap_align"), math.round(panel:x(), node_w))
	Application:debug("[MiniGame:Rewire] -- STEP FORWARD --", self._current_step)

	self._current_step = self._current_step + 1

	self:_update_colors()
	self:_play_sound(self._tweak_data.sounds.apply)

	if self._final_step_index < self._current_step then
		local connections_list = {}

		for y, panel in ipairs(self._interact_node_panels) do
			local idx = panel:x() < 0 and 1 or 0
			idx = idx + math.floor(#self._interact_nodes[y] / 2)

			table.insert(connections_list, self._interact_nodes[y][idx])
		end

		self._object:animate(callback(self, self, "_animate_connections_finished"), connections_list)
		Application:debug("[MiniGame:Rewire] -- ENDED --")

		return
	end
end

function HUDSpecialInteractionRewiring:_current_step_back()
	Application:debug("[MiniGame:Rewire] -- STEP BACKWARD --", self._current_step)

	self._current_step = self._current_step - 1

	self:_update_colors()
end

function HUDSpecialInteractionRewiring:_update_colors()
	for y, nodes in ipairs(self._interact_nodes) do
		local color = nil

		if self._current_step == y then
			color = Color(1, 1, 1)
		elseif y < self._current_step then
			color = Color(0.5, 1, 0.5)
		else
			color = Color(0.5, 0.5, 0.5)
		end

		for i_x, node in ipairs(nodes) do
			node:set_color(color)
		end
	end
end

function HUDSpecialInteractionRewiring:_update_all_slot_art()
	if not self._interact_nodes or #self._interact_nodes == 0 then
		Application:error("[MiniGame:Rewire] _update_all_slot_art self._interact_nodes doesnt exist!")

		return
	end

	if not table.empty(self._interact_nodes) then
		for y = 1, #self._interact_nodes do
			self:_update_row_slot_art(y)
		end
	end
end

function HUDSpecialInteractionRewiring:_update_row_slot_art(y)
	local data = self._interact_nodes[y]

	if not data then
		Application:error("[MiniGame:Rewire] _update_row_slot_art Data doesnt exist for Y", y)

		return
	end

	if not table.empty(data) then
		for x = 1, #data do
			self:_update_slot_art(y, x)
		end
	end
end

function HUDSpecialInteractionRewiring:_update_slot_art(y, x)
	local node = self._interact_nodes[y][x]

	if not node then
		Application:error("[MiniGame:Rewire] _update_slot_art Node doesnt exist! ", x, y)

		return
	end

	local data = self._interact_node_row_data[y]
	local x_id = data.row_x_id[x]
	local ref = HUDSpecialInteractionRewiring._GUI_REFS[data.row_nodes[x_id]]
	local tweak_data_gui = tweak_data.gui.icons[ref]

	if tweak_data_gui then
		node:set_image(tweak_data_gui.texture, unpack(tweak_data_gui.texture_rect))
	end
end

function HUDSpecialInteractionRewiring:show()
	HUDSpecialInteractionRewiring.super.show(self)
end

function HUDSpecialInteractionRewiring:hide(complete)
	HUDSpecialInteractionRewiring.super.hide(self, complete)
end

function HUDSpecialInteractionRewiring:check_interact()
	print("check_interact")
	self:_current_step_forward()

	local successful_path = self:_verify_maze()

	return successful_path
end

function HUDSpecialInteractionRewiring:_verify_maze()
	return false
end

function HUDSpecialInteractionRewiring:destroy()
	HUDSpecialInteractionRewiring.super.destroy(self)
end

function HUDSpecialInteractionRewiring:update(t, dt)
	if self:cooldown() then
		print("ON COOLDOWN", self._cooldown)

		self._cooldown = self._cooldown - dt

		if self._cooldown <= 0 then
			self._cooldown = 0
			local sound = self:get_update_sound(t, dt)

			if sound then
				self:_play_sound(sound)
			end
		end
	end

	self:_update_animation(t, dt)
end

function HUDSpecialInteractionRewiring:get_update_sound(t, dt)
	return self._tweak_data.sounds.tick
end

function HUDSpecialInteractionRewiring:_update_animation(t, dt)
	local tweak_speed_table = self:get_tweak_value("speed", {
		4
	})

	if not tweak_speed_table or #tweak_speed_table == 0 then
		Application:error("[MiniGame:Rewire] Speed is an empty table, cant use this")

		tweak_speed_table = {
			4
		}
	end

	local node_count_x = self:get_tweak_value("node_count_x", 3)
	local speed_step_decrease = self:get_tweak_value("speed_step_decrease", 0.5)
	local direction = self._starting_direction

	for y, panel in ipairs(self._interact_node_panels) do
		local update_row_x_idx = nil
		local node_w = self._interact_nodes[y][1]:w()
		local row_data = self._interact_node_row_data[y]

		if y == self._current_step then
			local speed = tweak_speed_table[1 + y % #tweak_speed_table] * dt
			local pos_x = node_w * (direction and speed or -speed)

			if panel:x() < -node_w then
				pos_x = pos_x + node_w

				for x, v in ipairs(row_data.row_x_id) do
					if v >= #row_data.row_x_id then
						row_data.row_x_id[x] = 1
					else
						row_data.row_x_id[x] = v + 1
					end
				end

				update_row_x_idx = row_data.row_x_id[#row_data.row_x_id]
			elseif panel:x() > 0 then
				pos_x = pos_x - node_w

				for x, v in ipairs(row_data.row_x_id) do
					if v <= 1 then
						row_data.row_x_id[x] = #row_data.row_x_id
					else
						row_data.row_x_id[x] = v - 1
					end
				end

				update_row_x_idx = row_data.row_x_id[1]
			end

			panel:set_x(panel:x() + pos_x)
		end

		if update_row_x_idx then
			local next_slot_queue = nil

			if self._prev_bend_slot then
				next_slot_queue = "b_" .. (not self._prev_bend_slot_was_up and "u" or "d") .. (direction and "_r" or "_l")
				row_data.row_nodes[update_row_x_idx] = next_slot_queue
				self._prev_bend_slot = false
			else
				next_slot_queue = self:_get_next_slot_queued()

				if next_slot_queue == "bend" then
					self._prev_bend_slot = true
					self._prev_bend_slot_was_up = math.rand_bool()
					next_slot_queue = "b_" .. (self._prev_bend_slot_was_up and "u" or "d") .. (not direction and "_r" or "_l")
				end

				row_data.row_nodes[update_row_x_idx] = next_slot_queue
			end

			self:_update_row_slot_art(y)
		end

		direction = not direction
	end

	if HUDSpecialInteractionRewiring._DEBUGGERY then
		for y, text in ipairs(self._interact_node_panels_DEBUGGERY) do
			local txt1 = ""
			local txt2 = ""
			local row_data = self._interact_node_row_data[y]
			txt1 = "[X" .. tostring(math.round(self._interact_node_panels[y]:x())) .. "]"

			for i, v in ipairs(row_data.row_x_id) do
				txt1 = txt1 .. "   " .. tostring(v)
			end

			for i, v in ipairs(row_data.row_nodes) do
				txt2 = txt2 .. " | " .. tostring(v)
			end

			text:set_text(tostring(y) .. ": " .. txt1 .. "\n > " .. txt2)
		end
	end
end

function HUDSpecialInteractionRewiring:get_type()
	return "rewire"
end

function HUDSpecialInteractionRewiring:check_all_complete()
	if self._final_step_index < self._current_step then
		return true
	end

	return false
end

function HUDSpecialInteractionRewiring:_animate_snap_align(panel, to_x)
	local duration = 0.4
	local t = 0
	local from_x = panel:x()
	local tgt_x = from_x - to_x

	while t < duration do
		local dt = coroutine.yield()
		t = t + dt
		local cur_delta_x = Easing.quintic_in(t, 0, tgt_x, duration)

		panel:set_x(from_x - cur_delta_x)
	end

	panel:set_x(to_x)
end

function HUDSpecialInteractionRewiring:_animate_connections_finished(panel, connections_list)
	local duration_per = 0.05

	for i, node in ipairs(connections_list) do
		node:set_color(Color(1, 0, 0))
		wait(duration_per)
	end
end
