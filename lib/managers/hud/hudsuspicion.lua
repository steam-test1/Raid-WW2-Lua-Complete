HUDSuspicion = HUDSuspicion or class()

function HUDSuspicion:init(hud, sound_source)
	self._hud_panel = hud.panel
	self._sound_source = sound_source

	if self._hud_panel:child("suspicion_panel") then
		self._hud_panel:remove(self._hud_panel:child("suspicion_panel"))
	end

	self._suspicion_panel = self._hud_panel:panel({
		name = "suspicion_panel",
		visible = false,
		layer = 1,
		valign = "center",
		y = 0
	})

	self._suspicion_panel:set_size(256, 256)
	self._suspicion_panel:set_center(self._suspicion_panel:parent():w() / 2, self._suspicion_panel:parent():h() / 2)

	local scale = 1
	local ring = self._suspicion_panel:bitmap({
		name = "ring",
		alpha = 0.55,
		visible = true,
		texture = "ui/icons/hud_circle",
		w = 256,
		blend_mode = "add",
		valign = "center",
		h = 256
	})

	ring:set_size(ring:w() * scale, ring:h() * scale)
	ring:set_center_x(self._suspicion_panel:w() / 2)
	ring:set_center_y(self._suspicion_panel:h() / 2)
end

function HUDSuspicion:show()
end

function HUDSuspicion:hide()
	self._suspicion_value = 0
	self._discovered = nil
	self._back_to_stealth = nil

	if alive(self._suspicion_panel) then
		self._suspicion_panel:set_visible(false)
	end
end

function HUDSuspicion:back_to_stealth()
	self._back_to_stealth = true

	self:hide()
end

function HUDSuspicion:discovered()
	self._discovered = true
end
