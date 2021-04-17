RaidGUIControlLegend = RaidGUIControlLegend or class(RaidGUIControl)
RaidGUIControlLegend.X = 0
RaidGUIControlLegend.y = 0
RaidGUIControlLegend.W = 1200
RaidGUIControlLegend.H = 32
RaidGUIControlLegend.FONT = tweak_data.gui.fonts.din_compressed
RaidGUIControlLegend.FONT_SIZE = tweak_data.gui.font_sizes.large
RaidGUIControlLegend.COLOR = tweak_data.gui.colors.raid_grey
RaidGUIControlLegend.LABEL_PADDING = 15

-- Lines 12-26
function RaidGUIControlLegend:init(parent, params)
	params.x = params.x or RaidGUIControlLegend.X
	params.y = params.y or RaidGUIControlLegend.Y
	params.w = params.w or RaidGUIControlLegend.W
	params.h = params.h or RaidGUIControlLegend.H
	params.color = params.color or RaidGUIControlLegend.COLOR

	RaidGUIControlLegend.super.init(self, parent, params)

	self._object = self._panel:panel(params)

	managers.raid_menu:set_current_legend_control(self)
	managers.controller:add_hotswap_callback("menu_legend", callback(self, self, "controller_hotswap_triggered"))
end

-- Lines 28-31
function RaidGUIControlLegend:close()
	managers.raid_menu:set_current_legend_control(nil)
	RaidGUIControlLegend.super.close(self)
end

-- Lines 33-35
function RaidGUIControlLegend:controller_hotswap_triggered()
	self:_create_legend()
end

-- Lines 37-41
function RaidGUIControlLegend:set_labels(legend)
	self._legend = legend

	self:_create_legend()
end

-- Lines 43-63
function RaidGUIControlLegend:_create_legend()
	if not self._object or not alive(self._object._engine_panel) or not self._legend then
		return
	end

	self._object:clear()

	self._labels = {}

	if not managers.controller:is_xbox_controller_present() or managers.menu:is_pc_controller() then
		self:_create_pc_legend()
	else
		local label_params = {
			y = 0,
			w = 200,
			x = 0,
			h = RaidGUIControlLegend.H,
			font = self._params.font or RaidGUIControlLegend.FONT,
			font_size = self._params.font_size or RaidGUIControlLegend.FONT_SIZE,
			color = RaidGUIControlLegend.COLOR
		}

		self:_create_console_legend(label_params)
	end
end

-- Lines 65-92
function RaidGUIControlLegend:_create_console_legend(label_params)
	if not self._legend.controller then
		return
	end

	local x = 0

	for _, legend_item in ipairs(self._legend.controller) do
		label_params.x = x

		if legend_item.translated_text then
			label_params.text = legend_item.translated_text
		elseif legend_item.text then
			label_params.text = self:translate(legend_item.text, true, legend_item.macros)
		else
			label_params.text = self:translate(legend_item, true)
		end

		local label = self._object:label(label_params)
		local _, _, w, _ = label:text_rect()

		label:set_w(w)

		if legend_item.padding then
			x = x + w + legend_item.padding
		else
			x = x + w + RaidGUIControlLegend.LABEL_PADDING
		end

		table.insert(self._labels, label)
	end
end

-- Lines 94-119
function RaidGUIControlLegend:_create_pc_legend()
	if not self._legend.keyboard then
		return
	end

	local coord_x = 0
	local padding = 10

	for _, legend_item in ipairs(self._legend.keyboard) do
		local legend_pc_params = {
			icon_align = "right",
			h = 32,
			y = 0,
			name = "pc_legend_" .. legend_item.key,
			x = coord_x,
			icon = tweak_data.gui.icons.ico_nav_right_base,
			text = self:translate(legend_item.key, true),
			on_click_callback = legend_item.callback
		}

		if legend_item.key == "footer_back" then
			legend_pc_params.icon_align = "left"
			legend_pc_params.icon = tweak_data.gui.icons.ico_nav_back_base
		end

		local nav_button = self._object:navigation_button(legend_pc_params)

		table.insert(self._labels, nav_button)

		coord_x = coord_x + nav_button:w() + padding
	end
end
