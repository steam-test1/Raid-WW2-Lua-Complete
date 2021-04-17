HUDSuspicion = HUDSuspicion or class()

-- Lines 3-21
function HUDSuspicion:init(hud, sound_source)
	self._hud_panel = hud.panel
	self._sound_source = sound_source

	if self._hud_panel:child("suspicion_panel") then
		self._hud_panel:remove(self._hud_panel:child("suspicion_panel"))
	end

	self._suspicion_panel = self._hud_panel:panel({
		y = 0,
		name = "suspicion_panel",
		layer = 1,
		visible = false,
		valign = "center"
	})

	self._suspicion_panel:set_size(256, 256)
	self._suspicion_panel:set_center(self._suspicion_panel:parent():w() / 2, self._suspicion_panel:parent():h() / 2)

	local scale = 1
	local ring = self._suspicion_panel:bitmap({
		texture = "ui/ingame/textures/hud/hud_circle",
		name = "ring",
		h = 256,
		visible = true,
		alpha = 0.55,
		w = 256,
		blend_mode = "add",
		valign = "center"
	})

	ring:set_size(ring:w() * scale, ring:h() * scale)
	ring:set_center_x(self._suspicion_panel:w() / 2)
	ring:set_center_y(self._suspicion_panel:h() / 2)
end

-- Lines 24-26
function HUDSuspicion:show()
end

-- Lines 28-36
function HUDSuspicion:hide()
	self._suspicion_value = 0
	self._discovered = nil
	self._back_to_stealth = nil

	if alive(self._suspicion_panel) then
		self._suspicion_panel:set_visible(false)
	end
end

-- Lines 38-41
function HUDSuspicion:back_to_stealth()
	self._back_to_stealth = true

	self:hide()
end

-- Lines 43-45
function HUDSuspicion:discovered()
	self._discovered = true
end
