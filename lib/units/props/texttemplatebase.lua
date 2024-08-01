TextTemplateBase = TextTemplateBase or class(UnitBase)

-- Lines 3-7
function TextTemplateBase:init(unit)
	TextTemplateBase.super.init(self, unit, false)
	self:_apply_template()
end

-- Lines 9-15
function TextTemplateBase:_apply_template()
	if self.TEMPLATE == "stocks" then
		self:_stock_ticker()
	elseif self.TEMPLATE == "big_bank_welcome" then
		self:_big_bank_welcome()
	end
end

-- Lines 17-20
function TextTemplateBase:set_template(template)
	self.TEMPLATE = template

	self:_apply_template()
end

-- Lines 22-61
function TextTemplateBase:_stock_ticker()
	for i = 1, self._unit:text_gui().ROWS do
		self._unit:text_gui():set_row_gap(i, 20)
		self._unit:text_gui():clear_row_and_guis(i)
		self._unit:text_gui():set_row_speed(i, i * 100 + 40 + 120 * math.rand(1))
	end

	local companies = {
		"Blammo Co.",
		"Kurgan-Paintings",
		"Riveting Baldcappers",
		"Wolfgang Copy n Co."
	}

	if not TextTemplateBase.STOCK_PERCENT then
		TextTemplateBase.STOCK_PERCENT = {}
		local bankruptcy_chance = math.rand(0.01)
		local bad_chance = math.rand(0.1)
		local good_chance = math.rand(0.1)
		local joker_chance = math.rand(0.01)
		local srand = nil

		for i, company in ipairs(companies) do
			srand = 0

			if math.rand(1) < bankruptcy_chance then
				srand = math.rand(-99, -45)
			elseif math.rand(1) < bad_chance then
				srand = math.rand(-55, -5)
			elseif math.rand(1) < good_chance then
				srand = math.rand(0, 40)
			elseif math.rand(1) < joker_chance then
				srand = math.rand(-100, 250)
			else
				srand = math.rand(-10, 10)
			end

			TextTemplateBase.STOCK_PERCENT[i] = srand
		end
	end

	for i, company in ipairs(companies) do
		local j = TextTemplateBase.STOCK_PERCENT[i]
		local row = math.mod(i, self._unit:text_gui().ROWS) + 1

		self._unit:text_gui():add_text(row, company, "white")
		self._unit:text_gui():add_text(row, "" .. (j < 0 and "" or "+") .. string.format("%.2f", j) .. "%", j < 0 and "light_red" or "light_green", self._unit:text_gui().FONT_SIZE / 1.5, "bottom", nil)
		self._unit:text_gui():add_text(row, "  ", "white")
	end
end

-- Lines 63-81
function TextTemplateBase:_big_bank_welcome()
	self._unit:text_gui():set_row_speed(1, 100)
	self._unit:text_gui():set_row_speed(2, 240 + 120 * math.rand(1))
	self._unit:text_gui():set_row_gap(1, 320)

	for i = 1, self._unit:text_gui().ROWS do
		self._unit:text_gui():clear_row_and_guis(i)
	end

	local texts = {
		"What is a sign like this doing in WW2?",
		" - ",
		"Must be from some silly timetraveling bank robbers...",
		" - "
	}
	local texts2 = {
		"Sterling",
		"Wolfgang",
		"Rivet",
		"Kurgan"
	}

	for i, text in ipairs(texts) do
		self._unit:text_gui():add_text(1, text, "green")
	end

	for i, text in ipairs(texts2) do
		self._unit:text_gui():add_text(2, text, "light_green")
		self._unit:text_gui():add_text(2, " - ", "light_green")
	end
end

-- Lines 83-85
function TextTemplateBase:destroy()
end

-- Lines 87-93
function TextTemplateBase:save(data)
	local state = {
		template = self.TEMPLATE
	}
	data.TextTemplateBase = state
end

-- Lines 95-101
function TextTemplateBase:load(data)
	local state = data.TextTemplateBase

	if state.template and state.TEMPLATE ~= self.TEMPLATE then
		self:set_template(state.template)
	end
end
