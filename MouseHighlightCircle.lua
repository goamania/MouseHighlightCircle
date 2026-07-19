local MHC = {}

MHC.defaults = {
    size = 32,
    r = 1.0,
    g = 1.0,
    b = 1.0,
    alpha = 0.7,
    combatOnly = false,
    hideOnRightClick = false,
    hideOnMount = false,
}

if not MouseHighlightCircleDB then MouseHighlightCircleDB = {} end
MHC.db = MouseHighlightCircleDB
for k, v in pairs(MHC.defaults) do
    if MHC.db[k] == nil then MHC.db[k] = v end
end

local frame = CreateFrame("Frame", "MouseHighlightCircleFrame", UIParent)

MHC.ringPieces = {}

local TWO_PI = 6.2832

local function CreateTile(size)
    local t = frame:CreateTexture(nil, "OVERLAY")
    t:SetTexture("Interface\\Buttons\\WHITE8x8")
    t:SetWidth(size)
    t:SetHeight(size)
    t:SetVertexColor(1, 1, 1, 1)
    return t
end

function MHC:RebuildRing()
    for _, t in ipairs(self.ringPieces) do t:Hide() t:SetTexture(nil) end
    self.ringPieces = {}

    local s = self.db.size
    local thickness = math.max(2, math.floor(s / 6))
    local outerR = s / 2
    local innerR = outerR - thickness
    local midR = (outerR + innerR) / 2
    local numTiles = math.max(8, math.floor(s * 1.5))

    for i = 1, numTiles do
        local theta = (i - 1) * TWO_PI / numTiles
        local tile = CreateTile(thickness)
        tile:SetPoint("CENTER", frame, "CENTER", midR * math.cos(theta), -midR * math.sin(theta))
        tinsert(self.ringPieces, tile)
    end

    frame:SetWidth(s)
    frame:SetHeight(s)

    self:ApplyColor()
end

function MHC:SetRingColor(r, g, b, a)
    for _, t in ipairs(self.ringPieces) do
        t:SetVertexColor(r, g, b, a)
    end
end

function MHC:ShowRing()
    for _, t in ipairs(self.ringPieces) do t:Show() end
end

function MHC:HideRing()
    for _, t in ipairs(self.ringPieces) do t:Hide() end
end

MHC.shown = true
MHC.rightDown = false
MHC.mounted = false

function MHC:Apply()
    self:RebuildRing()
end

function MHC:ApplyColor()
    self:SetRingColor(self.db.r, self.db.g, self.db.b, self.db.alpha)
end

MHC.mountTooltip = CreateFrame("GameTooltip", "MHCMountCheck", nil, "GameTooltipTemplate")

function MHC:IsMounted()
    for i = 1, 32 do
        local name = UnitBuff("player", i)
        if not name then break end
        self.mountTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        self.mountTooltip:SetBuff(i)
        local text = getglobal("MHCMountCheckTextLeft2"):GetText() or ""
        if text and (strfind(text, "Riding") or strfind(text, "Mount") or strfind(text, "Slow and steady")) then
            self.mountTooltip:Hide()
            return true
        end
        self.mountTooltip:Hide()
    end
    return false
end

function MHC:Refresh()
    if not self.shown then
        self:HideRing()
    elseif self.db.combatOnly and not UnitAffectingCombat("player") then
        self:HideRing()
    elseif self.db.hideOnRightClick and self.rightDown then
        self:HideRing()
    elseif self.db.hideOnMount and self.mounted then
        self:HideRing()
    else
        self:ShowRing()
    end
end

frame:SetScript("OnUpdate", function()
    if MHC.db.hideOnRightClick then
        local down = IsRightMouseButtonDown()
        if down ~= MHC.rightDown then
            MHC.rightDown = down
            MHC:Refresh()
        end
    end
    if MHC.ringPieces[1] and MHC.ringPieces[1]:IsShown() then
        local x, y = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / scale, y / scale)
    end
end)

frame:RegisterEvent("PLAYER_ENTER_COMBAT")
frame:RegisterEvent("PLAYER_LEAVE_COMBAT")
frame:RegisterEvent("PLAYER_AURAS_CHANGED")
frame:SetScript("OnEvent", function()
    if MHC.db.combatOnly then MHC:Refresh() end
    if MHC.db.hideOnMount then
        MHC.mounted = MHC:IsMounted()
        MHC:Refresh()
    end
end)

MHC:Apply()
MHC:Refresh()

local function Split(msg)
    local args = {}
    for arg in string.gmatch(msg or "", "%S+") do
        tinsert(args, string.lower(arg))
    end
    return args
end

local function Clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

local function PrintHelp()
    print("MouseHighlightCircle commands:")
    print("  /mhc show / hide")
    print("  /mhc toggle")
    print("  /mhc size N (8-128)")
    print("  /mhc color R G B (0-1)")
    print("  /mhc alpha N (0-1)")
    print("  /mhc combat - toggle combat-only")
    print("  /mhc rightclick - toggle hide on right-click")
    print("  /mhc mount - toggle auto-hide while mounted")
    print("  /mhc status")
end

SLASH_MHC1 = "/mhc"
SlashCmdList["MHC"] = function(msg)
    local args = Split(msg)
    if #args == 0 then PrintHelp(); return end

    local cmd = args[1]

    if cmd == "show" then
        MHC.shown = true
        MHC:Refresh()
        print("MouseHighlightCircle: shown")
    elseif cmd == "hide" then
        MHC.shown = false
        MHC:HideRing()
        print("MouseHighlightCircle: hidden")
    elseif cmd == "toggle" then
        if MHC.shown then
            MHC.shown = false
            MHC:HideRing()
            print("MouseHighlightCircle: hidden")
        else
            MHC.shown = true
            MHC:Refresh()
            print("MouseHighlightCircle: shown")
        end
    elseif cmd == "size" then
        local n = tonumber(args[2])
        if n and n >= 8 and n <= 128 then
            MHC.db.size = n
            MHC:Apply()
            print("MouseHighlightCircle: size set to " .. n)
        else
            print("Usage: /mhc size N (8-128)")
        end
    elseif cmd == "color" then
        local r, g, b = tonumber(args[2]), tonumber(args[3]), tonumber(args[4])
        if r and g and b then
            MHC.db.r = Clamp(r, 0, 1)
            MHC.db.g = Clamp(g, 0, 1)
            MHC.db.b = Clamp(b, 0, 1)
            MHC:Apply()
            print(string.format("MouseHighlightCircle: color set to %.2f %.2f %.2f", MHC.db.r, MHC.db.g, MHC.db.b))
        else
            print("Usage: /mhc color R G B (0-1)")
        end
    elseif cmd == "alpha" then
        local a = tonumber(args[2])
        if a then
            MHC.db.alpha = Clamp(a, 0, 1)
            MHC:Apply()
            print("MouseHighlightCircle: alpha set to " .. MHC.db.alpha)
        else
            print("Usage: /mhc alpha N (0-1)")
        end
    elseif cmd == "combat" then
        MHC.db.combatOnly = not MHC.db.combatOnly
        MHC:Refresh()
        print("MouseHighlightCircle: combat-only " .. (MHC.db.combatOnly and "enabled" or "disabled"))
    elseif cmd == "rightclick" then
        MHC.db.hideOnRightClick = not MHC.db.hideOnRightClick
        if not MHC.db.hideOnRightClick then MHC.rightDown = false end
        MHC:Refresh()
        print("MouseHighlightCircle: hide on right-click " .. (MHC.db.hideOnRightClick and "enabled" or "disabled"))
    elseif cmd == "mount" then
        MHC.db.hideOnMount = not MHC.db.hideOnMount
        if MHC.db.hideOnMount then
            MHC.mounted = MHC:IsMounted()
        else
            MHC.mounted = false
        end
        MHC:Refresh()
        print("MouseHighlightCircle: auto-hide while mounted " .. (MHC.db.hideOnMount and "enabled" or "disabled"))
    elseif cmd == "status" then
        print("MouseHighlightCircle settings:")
        print("  Size: " .. MHC.db.size)
        print(string.format("  Color: %.2f %.2f %.2f", MHC.db.r, MHC.db.g, MHC.db.b))
        print("  Alpha: " .. MHC.db.alpha)
        print("  Combat-only: " .. (MHC.db.combatOnly and "Yes" or "No"))
        print("  Hide on right-click: " .. (MHC.db.hideOnRightClick and "Yes" or "No"))
        print("  Auto-hide on mount: " .. (MHC.db.hideOnMount and "Yes" or "No"))
    else
        print("Unknown command. Type /mhc for help.")
    end
end

BINDING_HEADER_MHC = "MouseHighlightCircle"
BINDING_NAME_MHC_TOGGLE = "Toggle Circle"

function MHC_TOGGLE()
    if MHC.shown then
        MHC.shown = false
        MHC:HideRing()
        print("MouseHighlightCircle: hidden")
    else
        MHC.shown = true
        MHC:Refresh()
        print("MouseHighlightCircle: shown")
    end
end
