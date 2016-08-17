local addon, ns = ...
local cfg = ns.cfg
local core = ns.core
local cast = ns.cast


local create = function(self)
	self.unitType = "target"
	self:SetSize(cfg.unitframeWidth * cfg.unitframeScale, 50 * cfg.unitframeScale)
	self:SetPoint("TOPLEFT", UIParent, "BOTTOM", cfg.targetX, cfg.targetY)
	self:RegisterForClicks('AnyUp')

	-- Health
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(self:GetHeight() * 0.68)
		s:SetWidth(self:GetWidth())
		s:SetPoint("TOP", 0, 0)
		s:SetStatusBarTexture(cfg.statusbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)

		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT",4,-4)
		core.createBackdrop(h, 0)

		local b = s:CreateTexture(nil, "BACKGROUND")
		b:SetTexture([[Interface\ChatFrame\ChatFrameBackground]])
		b:SetAllPoints(s)

		self.Health = s
		self.Health.bg = b

		self.Health.frequentUpdates = true
		self.Health.colorSmooth = true
		self.Health.bg.multiplier = 0.3
		self.Health.Smooth = true
	end
	-- Tag Texts
	do
		local name = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "NONE")
		name:SetPoint("LEFT", self.Health, "TOPLEFT", 5, -10)
		name:SetJustifyH("LEFT")
		name.frequentUpdates = true
		local hpval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "NONE")
		hpval:SetPoint("RIGHT", self.Health, "TOPRIGHT", -3, -10)
		hpval.frequentUpdates = true
		local powerval = core.createFontString(self.Health, cfg.font, cfg.fontsize.unitframe, "THINOUTLINE")
		powerval:SetPoint("RIGHT", self.Health, "BOTTOMRIGHT", 3, -16)

		name:SetPoint("RIGHT", hpval, "LEFT", -2, 0)
		self:Tag(name, "[drk:level] [drk:color][name][drk:afkdnd]")
		self:Tag(powerval, "[drk:power]")
		self:Tag(hpval, "[drk:hp]")
	end
	-- Power
	do
		local s = CreateFrame("StatusBar", nil, self)
		s:SetFrameLevel(1)
		s:SetHeight(self:GetHeight() * 0.26)
		s:SetWidth(self:GetWidth())
	    s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(true)
		s:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
		s.frequentUpdates = true

		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -4, 4)
		h:SetPoint("BOTTOMRIGHT", 4, -4)
		core.createBackdrop(h, 0)

	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.powerbar_texture)
	    b:SetAllPoints(s)

		self.Power = s
	    self.Power.bg = b
	    self.Power.colorTapping = true
		self.Power.colorDisconnected = true
		self.Power.colorClass = true
		self.Power.colorReaction = true
		self.Power.bg.multiplier = 0.5
		self.Power.Smooth = true
	end
	-- Highlight
	core.addHighlight(self)
	-- Portrait
	if cfg.showPortraits then
	    local p = CreateFrame("PlayerModel", nil, self)
	    p:SetFrameLevel(4)
	    p:SetHeight(19.8)
	    p:SetWidth(self:GetWidth()-17.55)
	    p:SetPoint("BOTTOM", self, "BOTTOM", 0, 8)
	    --helper
	    local h = CreateFrame("Frame", nil, p)
	    h:SetFrameLevel(3)
	    h:SetPoint("TOPLEFT", -4, 4)
	    h:SetPoint("BOTTOMRIGHT", 5, -5)
	    core.createBackdrop(h, 0)

	    self.Portrait = p
	    -- TODO does this do anything?
	    local hl = self.Portrait:CreateTexture(nil, "OVERLAY")
	    hl:SetAllPoints(self.Portrait)
	    hl:SetTexture(cfg.portrait_texture)
	    hl:SetVertexColor(.5, .5, .5, .8)
	    hl:SetBlendMode("ALPHAKEY")
	    hl:Hide()
	end
	-- Castbars
	if cfg.Castbars then
	    local s = CreateFrame("StatusBar", "oUF_DrkCastbar"..self.unitType, self)
		if cfg.targetCastBarOnUnitframe and cfg.showPortraits then
			s:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 21, 0.5)
			s:SetHeight(self.Portrait:GetHeight()+1.5)
			s:SetWidth(self:GetWidth()-37.45)
		else
			s:SetPoint("BOTTOM", UIParent, "BOTTOM", cfg.targetCastBarX, cfg.targetCastBarY)
			s:SetHeight(cfg.targetCastBarHeight)
			s:SetWidth(cfg.targetCastBarWidth)
		end
	    s:SetStatusBarTexture(cfg.statusbar_texture)
	    s:SetStatusBarColor(0.5, 0.5, 1, 1)
	    s:SetFrameLevel(9)
	    --color
	    s.CastingColor = {0.5, 0.5, 1}
	    s.CompleteColor = {0.5, 1, 0}
	    s.FailColor = {1.0, 0.05, 0}
	    s.ChannelingColor = {0.5, 0.5, 1}
	    --helper
	    local h = CreateFrame("Frame", nil, s)
	    h:SetFrameLevel(0)
	    h:SetPoint("TOPLEFT", -4, 4)
	    h:SetPoint("BOTTOMRIGHT", 4, -4)
	    core.createBackdrop(h, 0)
	    --backdrop
	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.statusbar_texture)
	    b:SetAllPoints(s)
	    b:SetVertexColor(0.1, 0.1, 0.2, 0.7)
	    --spark
	    local sp = s:CreateTexture(nil, "OVERLAY")
	    sp:SetBlendMode("ADD")
	    sp:SetAlpha(0.5)
	    sp:SetHeight(s:GetHeight()*2.5)
	    --spell text
	    local txt = core.createFontString(s, cfg.font, cfg.fontsize.castbar, "NONE")
	    txt:SetPoint("LEFT", 4, 0)
	    txt:SetJustifyH("LEFT")
	    --time
	    local t = core.createFontString(s, cfg.font, cfg.fontsize.castbar, "NONE")
	    t:SetPoint("RIGHT", -2, 0)
	    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
	    --icon
	    local i = s:CreateTexture(nil, "ARTWORK")

		if cfg.playerCastBarOnUnitframe then
			i:SetPoint("RIGHT", s, "LEFT", 1, 0)
			i:SetSize(s:GetHeight(),s:GetHeight())
		else
			i:SetPoint("RIGHT", s, "LEFT", -5, 0)
			i:SetSize(s:GetHeight()-1, s:GetHeight()-1)
		end
	    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	    --helper2 for icon
	    local h2 = CreateFrame("Frame", nil, s)
	    h2:SetFrameLevel(0)
	    h2:SetPoint("TOPLEFT", i, "TOPLEFT", -4, 4)
	    h2:SetPoint("BOTTOMRIGHT", i,"BOTTOMRIGHT", 4, -4)
	    core.createBackdrop(h2, 0)

	    s.OnUpdate = cast.OnCastbarUpdate
	    s.PostCastStart = cast.PostCastStart
	    s.PostChannelStart = cast.PostCastStart
	    s.PostCastStop = cast.PostCastStop
	    s.PostChannelStop = cast.PostChannelStop
	    s.PostCastFailed = cast.PostCastFailed
	    s.PostCastInterrupted = cast.PostCastFailed

	    self.Castbar = s
	    self.Castbar.Text = txt
	    self.Castbar.Time = t
	    self.Castbar.Icon = i
	    self.Castbar.Spark = sp
	end
	-- Info Icons
	do
		local h = CreateFrame("Frame", nil, self)
	    h:SetAllPoints(self)
	    h:SetFrameLevel(10)
	    --Combat Icon
		local combat = CreateFrame("Frame", nil, h)
        combat:SetSize(15, 15)
        combat:SetPoint("BOTTOMRIGHT", 7, -7)
        self.CombatIcon = combat

        local combaticon = combat:CreateTexture(nil, "ARTWORK")
        combaticon:SetAllPoints(true)
        combaticon:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
        combaticon:SetTexCoord(0.58, 0.9, 0.08, 0.41)
        combat.icon = combaticon

        combat.__owner = self
        combat:SetScript("OnUpdate", function(self)
            local unit = self.__owner.unit
            if unit and UnitAffectingCombat(unit) then
                self.icon:Show()
            else
                self.icon:Hide()
            end
        end)
		-- PvP Icon
		local PvP = h:CreateTexture(nil, "OVERLAY")
		local faction = PvPCheck
		if faction == "Horde" then
			PvP:SetTexCoord(0.08, 0.58, 0.045, 0.545)
		elseif faction == "Alliance" then
			PvP:SetTexCoord(0.07, 0.58, 0.06, 0.57)
		else
			PvP:SetTexCoord(0.05, 0.605, 0.015, 0.57)
		end
		PvP:SetHeight(12)
		PvP:SetWidth(12)
		PvP:SetPoint("TOPRIGHT", 6, 6)
		self.PvP = PvP
	    --LFDRole icon
		local LFDRole = h:CreateTexture(nil, "OVERLAY")
		LFDRole:SetSize(15, 15)
		LFDRole:SetAlpha(0.9)
		LFDRole:SetPoint("BOTTOMLEFT", -6, -8)
	    self.LFDRole = LFDRole
		-- Leader, Assist, Master Looter Icon
		local li = h:CreateTexture(nil, "OVERLAY")
		li:SetPoint("TOPLEFT", self, 0, 8)
		li:SetSize(12,12)
		self.Leader = li
		local ai = h:CreateTexture(nil, "OVERLAY")
		ai:SetPoint("TOPLEFT", self, 0, 8)
		ai:SetSize(12,12)
		self.Assistant = ai
		local ml = h:CreateTexture(nil, 'OVERLAY')
		ml:SetSize(10,10)
		ml:SetPoint('LEFT', self.Leader, 'RIGHT')
		self.MasterLooter = ml
		-- Phase Icon
		local picon = h:CreateTexture(nil, 'OVERLAY')
		picon:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 8, 8)
		picon:SetSize(16, 16)
		self.PhaseIcon = picon
		-- Raid Marks
		local ri = h:CreateTexture(nil, "OVERLAY")
		ri:SetPoint("RIGHT", self, "LEFT", 5, 6)
		ri:SetSize(20, 20)
		self.RaidIcon = ri
	end
	-- Buffs & Debuffs
	if cfg.targetBuffs then core.addBuffs(self) end
	if cfg.targetDebuffs then core.addDebuffs(self) end
	-- Heal Prediction
	if cfg.showIncHeals then
		local health = self.Health

		local healing = CreateFrame('StatusBar', nil, health)
		healing:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT')
		healing:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT')
		healing:SetWidth(self:GetWidth())
		healing:SetStatusBarTexture(cfg.statusbar_texture)
		healing:SetStatusBarColor(0.25, 1, 0.25, 0.5)
		healing:SetFrameLevel(1)

		local absorbs = CreateFrame('StatusBar', nil, health)
		absorbs:SetPoint('TOPLEFT', healing:GetStatusBarTexture(), 'TOPRIGHT')
		absorbs:SetPoint('BOTTOMLEFT', healing:GetStatusBarTexture(), 'BOTTOMRIGHT')
		absorbs:SetWidth(self:GetWidth())
		absorbs:SetStatusBarTexture(cfg.statusbar_texture)
		absorbs:SetStatusBarColor(0.25, 0.8, 1, 0.5)
		absorbs:SetFrameLevel(1)

		self.HealPrediction = {
			healingBar = healing,
			absorbsBar = absorbs,
			Override = core.HealPrediction_Override
		}
	end
	-- AltPowerBar
	if cfg.AltPowerBarPlayer then
		local s = CreateFrame("StatusBar", nil, self.Power) -- TODO attach to health
		s:SetFrameLevel(1)
		s:SetSize(3, self:GetHeight()+0.5)
		s:SetOrientation("VERTICAL")
		s:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -3, 0)
		s:SetStatusBarTexture(cfg.powerbar_texture)
		s:GetStatusBarTexture():SetHorizTile(false)
		s:SetStatusBarColor(235/255, 235/255, 235/255)

		local h = CreateFrame("Frame", nil, s)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT", -3, 3)
		h:SetPoint("BOTTOMRIGHT", 3, -3)
		core.createBackdrop(h, 1)

	    local b = s:CreateTexture(nil, "BACKGROUND")
	    b:SetTexture(cfg.powerbar_texture)
	    b:SetAllPoints(s)
		b:SetVertexColor(45/255, 45/255, 45/255)

		self.AltPowerBar = s
	    self.AltPowerBar.bg = b
	end
	-- AltPowerBar Text
	do
		local altpphelpframe = CreateFrame("Frame", nil, self)
		altpphelpframe:SetPoint("RIGHT", self.AltPowerBar, "BOTTOMRIGHT", 1, 4)
		altpphelpframe:SetFrameLevel(7)
		altpphelpframe:SetSize(30, 10)
		local altppbartext = core.createFontString(altpphelpframe, cfg.font, cfg.fontsize.smalltext, "OUTLINE")
		altppbartext:SetPoint("RIGHT", altpphelpframe, "RIGHT", 0, 0)
		altppbartext:SetJustifyH("RIGHT")

		self:Tag(altppbartext, "[drk:altpowerbar]")
	end
end

oUF:RegisterStyle("drk:target", create)
oUF:SetActiveStyle("drk:target")
oUF:Spawn("target", "oUF_DrkTargetFrame")
