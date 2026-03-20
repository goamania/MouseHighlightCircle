local CURRENT_SETTINGS_LAYOUT_VERSION = 1

local _type = type
local _assert = assert
local _tostring = tostring
local _tonumber = tonumber

local _strsub = string.sub
local _strgsub = string.gsub
local _strfind = string.find
local _strupper = string.upper
local _strlower = string.lower

local _unpack = unpack
local _tableremove = table.remove

local function _strmatch(input, patternString, ...)
    local variadicsArray = arg

    _assert(patternString ~= nil, "patternString must not be nil")

    if patternString == "" then
        return nil
    end

    local results = { _strfind(input, patternString, _unpack(variadicsArray)) }

    local startIndex = results[1]
    if startIndex == nil then -- no match
        return nil
    end

    local match01 = results[3]
    if match01 == nil then
        local endIndex = results[2]
        return _strsub(input, startIndex, endIndex) -- matched but without using captures   ("Foo 11 bar   ping pong"):match("Foo %d+ bar")
    end

    _tableremove(results, 1) -- pop startIndex
    _tableremove(results, 1) -- pop endIndex

    return _unpack(results) -- matched with captures  ("Foo 11 bar   ping pong"):match("Foo (%d+) bar")
end

local _isAddonLoaded = false

local function _strtrim(input)
    return _strmatch(input or "", '^%s*(.*%S)') or ''
end

local _namedColors = { --@formatter:off
    RED              = { 1.00, 0.000, 0.000 }, -- Pure red (#FF0000)
    BLUE             = { 0.00, 0.000, 1.000 }, -- Pure blue (#0000FF)
    GOLD             = { 1.00, 0.820, 0.000 }, -- WoW NORMAL_FONT_COLOR (#FFD100)
    GRAY             = { 0.50, 0.500, 0.500 }, -- Medium gray (#808080)
    CYAN             = { 0.00, 1.000, 1.000 }, -- Pure cyan (#00FFFF)
    LIME             = { 0.75, 1.000, 0.000 }, -- Bright lime green (#BFFF00)
    PINK             = { 1.00, 0.753, 0.796 }, -- Soft pink (#FFC0CB)
    TEAL             = { 0.00, 0.502, 0.502 }, -- Teal, blue-green mix (#008080)
    NAVY             = { 0.00, 0.000, 0.500 }, -- Deep navy blue (#000080)
    OLIVE            = { 0.50, 0.500, 0.000 }, -- Olive green (#808000)
    GREEN            = { 0.00, 1.000, 0.000 }, -- Pure green (#00FF00)
    WHITE            = { 1.00, 1.000, 1.000 }, -- Pure white (#FFFFFF)
    BLACK            = { 0.00, 0.000, 0.000 }, -- Pure black (#000000)
    VIOLET           = { 0.93, 0.510, 0.933 }, -- Vibrant violet (#EE82EE)
    ORANGE           = { 1.00, 0.498, 0.243 }, -- WoW orange font approximation (#FF7F3F)
    PURPLE           = { 0.50, 0.000, 1.000 }, -- Bright purple (#8000FF)
    SILVER           = { 0.75, 0.753, 0.753 }, -- Light silver (#C0C0C0)
    YELLOW           = { 1.00, 1.000, 0.000 }, -- Pure yellow (#FFFF00)
    MAROON           = { 0.50, 0.000, 0.000 }, -- Deep red (#800000)
    MAGENTA          = { 1.00, 0.000, 1.000 }, -- Pure magenta (#FF00FF)
    CRIMSON          = { 0.86, 0.078, 0.235 }, -- Rich red (#DC143C)
    TOMATO           = { 1.00, 0.388, 0.278 }, -- Bright tomato red (#FF6347)
    DARK_GRAY        = { 0.25, 0.250, 0.250 }, -- Darker gray (#404040)
    DARK_GOLD        = { 0.80, 0.600, 0.000 }, -- Darker gold, rich tone (#CC9900)
    DARK_CYAN        = { 0.00, 0.545, 0.545 }, -- Dark cyan (#008B8B)
    FIREBRICK        = { 0.70, 0.133, 0.133 }, -- Deep brick red (#B22222)
    SLATE_BLUE       = { 0.42, 0.353, 0.804 }, -- Slate blue (#6A5ACD)
    SLATE_GRAY       = { 0.44, 0.500, 0.565 }, -- Slate gray (#708090)
    STEEL_BLUE       = { 0.27, 0.509, 0.706 }, -- Steel blue (#4682B4)
    CHARTREUSE       = { 0.50, 1.000, 0.000 }, -- Bright chartreuse (#7FFF00)
    LIGHT_BLUE       = { 0.68, 0.847, 0.902 }, -- Light blue, sky-like (#ADD8E6)
    LIGHT_GOLD       = { 1.00, 0.930, 0.400 }, -- Lighter gold, soft glow (#FFED66)
    DARK_GREEN       = { 0.00, 0.392, 0.000 }, -- Dark green (#006400)
    LIGHT_CYAN       = { 0.88, 1.000, 1.000 }, -- Pale cyan (#E0FFFF)
    ROYAL_BLUE       = { 0.25, 0.411, 0.882 }, -- Rich blue (#4169E1)
    CORNFLOWER       = { 0.39, 0.584, 0.929 }, -- Cornflower blue (#6495ED)
    DARK_OLIVE       = { 0.33, 0.420, 0.184 }, -- Dark olive green (#556B2F)
    DARK_ORANGE      = { 1.00, 0.300, 0.000 }, -- Darker orange, warning style (#FF4C00)
    PALE_ORANGE      = { 1.00, 0.800, 0.600 }, -- Pale orange, subtle shade (#FFCC99)
    DARK_VIOLET      = { 0.58, 0.000, 0.827 }, -- Deep violet (#9400D3)
    LIGHT_GREEN      = { 0.56, 0.933, 0.565 }, -- Light green (#90EE90)
    LIGHT_ORANGE     = { 1.00, 0.650, 0.300 }, -- Lighter orange, softer tone (#FFA64C)
    HUNTER_GREEN     = { 0.67, 0.830, 0.450 }, -- WoW Hunter class color (#ABD473)
    DRUID_ORANGE     = { 1.00, 0.490, 0.040 }, -- WoW Druid class color (#FF7C0A)
    DARK_MAGENTA     = { 0.55, 0.000, 0.550 }, -- Dark magenta (#8B008B)
    SADDLE_BROWN     = { 0.55, 0.271, 0.075 }, -- Dark brown (#8B4513)
    FOREST_GREEN     = { 0.13, 0.545, 0.133 }, -- Deep forest green (#228B22)
    SPRING_GREEN     = { 0.00, 1.000, 0.498 }, -- Vibrant spring green (#00FF7F)
    DEEP_SKY_BLUE    = { 0.00, 0.749, 1.000 }, -- Bright sky blue (#00BFFF)
    MEDIUM_VIOLET    = { 0.73, 0.333, 0.827 }, -- Medium violet (#BB33D3)
    DARK_SLATE_GRAY  = { 0.18, 0.310, 0.310 }, -- Dark slate gray (#2F4F4F)
    VERY_DARK_ORANGE = { 0.80, 0.200, 0.000 }, -- Very dark orange, deep tone (#CC3300)
} --@formatter:on

local function _print(msg, r, g, b, id)
    -- must be declared after _namedColors!
    DEFAULT_CHAT_FRAME:AddMessage(
            "[|cff33ff99MHC|r] " .. msg,
            r ~= nil and r or _namedColors.LIGHT_GREEN[1],
            g ~= nil and g or _namedColors.LIGHT_GREEN[2],
            b ~= nil and b or _namedColors.LIGHT_GREEN[3],
            id
    )
end

local function _cloneColorRgbArray(colorRgbArray)
    _ = _type(colorRgbArray) ~= "table" and _assert(false, "Invalid argument to _cloneColorRgbArray() - must be a table")

    return {
        colorRgbArray[1],
        colorRgbArray[2],
        colorRgbArray[3],
    }
end

local function _copySettingsFromTo(from, to)
    _ = _type(from) ~= "table" or _type(to) ~= "table" and _assert(false, "Invalid arguments to _copySettingsFromTo() - both must be tables")

    to._SettingsVersion_ = from._SettingsVersion_

    to.Reticle = to.Reticle or {} -- order    
    
    to.Reticle.Shown = from.Reticle.Shown    
    to.Reticle.Color = _cloneColorRgbArray(from.Reticle.Color)    
    to.Reticle.Alpha = from.Reticle.Alpha
    to.Reticle.Strata = from.Reticle.Strata
    to.Reticle.Diameter = from.Reticle.Diameter
    to.Reticle.ImagePath = from.Reticle.ImagePath
    
    return to
end

local _failsafeSettings = {
    _SettingsVersion_ = CURRENT_SETTINGS_LAYOUT_VERSION,

    Reticle = {
        Shown = true,
        Color = _namedColors.GOLD,
        Alpha = 0.7,
        Strata = "TOOLTIP",
        Diameter = 32,
        ImagePath = "Interface\\AddOns\\MouseHighlightCircle\\pixelring.tga",
    },
}

-- the _activeSettings are ephemeral and only exist in memory while the addon is loaded
-- the user must call '/mhc save' explicitly to persist any changes to MouseHighlightCircleSettingsDB
local _activeSettings

local _rootFrame = CreateFrame("Frame", "MouseHighlightCircleFrame", UIParent)
_rootFrame:Hide() -- will be shown at the end of the initialization if the loaded settings say so

local _mouseReticle = _rootFrame:CreateTexture(nil, "OVERLAY")
_mouseReticle:Hide() -- will be shown at the end of the initialization if the loaded settings say so

local _abs = abs -- snapshot
local _uiParent = UIParent -- snapshot
local _getCursorPosition = GetCursorPosition -- snapshot

local function _getEffectiveUIScaleSafely()
    local uiScale = _uiParent:GetEffectiveScale()
    if uiScale == nil or uiScale <= 0 then
        uiScale = 1 -- failsafe
        _print("[WARNING] GetEffectiveScale() returned unusable value '" .. _tostring(uiScale or "nil") .. "' - assuming ui-scale=1 and hoping for the best but please report this incident and what you did to cause it.")
    end
    
    return uiScale
end

local _lastX, _lastY, _uiScale, _x, _y, _global = -999999, -999999, nil, nil, nil, (_G or getfenv(0))

local _interval, _elapsedTimeSinceLastFiring = 0.025, 0.0 -- update the cursor circle every 25ms basically
_rootFrame:SetScript("OnUpdate", function() -- track mouse movements
    _elapsedTimeSinceLastFiring = _elapsedTimeSinceLastFiring + _global.arg1 --00
    if _elapsedTimeSinceLastFiring < _interval then
        return
    end

    repeat
        _elapsedTimeSinceLastFiring = _elapsedTimeSinceLastFiring - _interval --10
    until _elapsedTimeSinceLastFiring < _interval
    
    _x, _y = _getCursorPosition()
    if _x == nil or _y == nil or (_abs(_x - _lastX) <= 1 and _abs(_y - _lastY) <= 1) then
        return -- mouse hasnt moved that much   do nothing
    end

    if _uiScale == nil then
        _uiScale = _getEffectiveUIScaleSafely() -- snipe once
    end

    _lastX, _lastY = _x, _y -- order

    -- _mouseReticle:ClearAllPoints() -- doesnt seem to be truly necessary in this particular case

    _mouseReticle:SetPoint("CENTER", _uiParent, "BOTTOMLEFT", _x / _uiScale, _y / _uiScale) -- place the ring around the mouse cursor

    -- 00  arg1 is the elapsed time since the previous callback invocation   there is no other way to get this value
    --     other than grabbing it from the global environment like we do here   very strange but true
    --
    -- 10  _elapsedTimeSinceLastFiring >= _interval   its important to trim down the excess time as much as it is
    --     necessary to ensure it goes beneath the interval threshold
end)

local function _init()
    if not MouseHighlightCircleSettingsDB or _type(MouseHighlightCircleSettingsDB._SettingsVersion_) ~= "number" then

        if not MouseHighlightCircleSettingsDB then
            _print("First time initialization detected - creating default addon-settings")
        elseif _type(MouseHighlightCircleSettingsDB._SettingsVersion_) ~= "number" then
            _print("Corrupted settings on disk - resetting settings to failsafe values")
        end

        MouseHighlightCircleSettingsDB = _copySettingsFromTo(_failsafeSettings, {})

    elseif MouseHighlightCircleSettingsDB._SettingsVersion_ < CURRENT_SETTINGS_LAYOUT_VERSION then

        local tempCopyOfOldSettings = _copySettingsFromTo(MouseHighlightCircleSettingsDB, {})

        -- if we get here it means that the addon was updated to a newer version with a different/enhanced settings layout
        -- so we must enrich the existing settings with any new properties that might have been added in the meantime
        --
        -- ... ... make necessary upgrades here ... ...

        tempCopyOfOldSettings._SettingsVersion_ = CURRENT_SETTINGS_LAYOUT_VERSION

        MouseHighlightCircleSettingsDB = tempCopyOfOldSettings -- keep this dead last

    elseif MouseHighlightCircleSettingsDB._SettingsVersion_ > CURRENT_SETTINGS_LAYOUT_VERSION then
        _print("[Warning] Settings version on disk is newer than what this addon-version supports (did you upgrade the addon and then re-downgrade it?)")
    end

    _activeSettings = _copySettingsFromTo(MouseHighlightCircleSettingsDB, {}) -- load the settings from disk into the active settings

    --- INITIALIZE USING THE SAVED SETTINGS WE JUST LOADED FROM DISK ---

    _rootFrame:SetFrameStrata(_activeSettings.Reticle.Strata)
    _mouseReticle:SetTexture(_activeSettings.Reticle.ImagePath)

    -- if the texture is not found _print an error and use a placeholder texture
    if not _mouseReticle:GetTexture() then
        _print("[ERROR] Mouse-overlay image '" .. _activeSettings.Reticle.ImagePath .. "' was not found on disk - reverting to the failsafe image")

        _activeSettings.Reticle.ImagePath = _failsafeSettings.Reticle.ImagePath -- update the current settings

        _mouseReticle:SetTexture(_failsafeSettings.Reticle.ImagePath)
        if not _mouseReticle:GetTexture() then
            _print("[CRITICAL ERROR] Failsafe image '" .. _failsafeSettings.Reticle.ImagePath .. "' was not found on disk either - using a plain white square as a last resort")
            _mouseReticle:SetTexture(1.0, 1.0, 1.0, 1.0) -- plain white square
        end
    end

    -- adjust texture dimensions and position
    _mouseReticle:SetWidth(_activeSettings.Reticle.Diameter)
    _mouseReticle:SetHeight(_activeSettings.Reticle.Diameter)
    _mouseReticle:SetVertexColor(_activeSettings.Reticle.Color[1], _activeSettings.Reticle.Color[2], _activeSettings.Reticle.Color[3], _activeSettings.Reticle.Alpha)

    if _activeSettings.Reticle.Shown then
        _rootFrame:Show()
        _mouseReticle:Show()
    else
        _rootFrame:Hide()
        _mouseReticle:Hide()
    end

    _isAddonLoaded = true

    _print("Addon loaded - type |cff33ff99/mhc|r for a list of supported commands.")
end

local function _processPossibleCommandFor_ShowOrHide(msgLowercased)
    if msgLowercased == "hide" or msgLowercased == "off" then
        
        _rootFrame:Hide()
        _mouseReticle:Hide()        
        if not _activeSettings.Reticle.Shown then
            -- _print("mouse-reticle is already off")
            return true
        end
        
        _activeSettings.Reticle.Shown = false
        _print("mouse-reticle turned off")
        return true
    end

    if msgLowercased == "show" or msgLowercased == "on" then

        _rootFrame:Show()
        _mouseReticle:Show()
        if _activeSettings.Reticle.Shown then
            -- _print("mouse-reticle is already on")
            return true
        end
        
        _activeSettings.Reticle.Shown = true
        _print("mouse-reticle turned on")
        return true
    end

    return false
end

local function _processPossibleCommandFor_SetSize(msgLowercased)
    local desiredReticleDiameterInPixelsStringified, isSetSizeCommand = _strgsub(msgLowercased, "^%s*size%s+(%S*)%s*$", "%1")
    if isSetSizeCommand == nil or isSetSizeCommand == 0 then
        return false
    end

    local newReticleDiameter = _tonumber(desiredReticleDiameterInPixelsStringified)
    if newReticleDiameter == nil or newReticleDiameter <= 0 then
        _print("Invalid size value '" .. _tostring(desiredReticleDiameterInPixelsStringified or "nil") .. "' - please provide a positive number.")
        return true
    end

    _mouseReticle:SetWidth(newReticleDiameter)
    _mouseReticle:SetHeight(newReticleDiameter)
    _print("mouse-reticle size set to '" .. _tostring(newReticleDiameter) .. "' pixels")
    return true
end

local function _processPossibleCommandFor_SetStrata(msgLowercased)
    local desiredStrata, isSetStrataCommand = _strgsub(msgLowercased, "^%s*strata%s+(%S*)%s*$", "%1")
    if isSetStrataCommand == nil or isSetStrataCommand == 0 then
        return false
    end

    desiredStrata = _strupper(_strtrim(desiredStrata or ""))
    if          desiredStrata ~= "BACKGROUND" --@formatter:off   lowest
            and desiredStrata ~= "LOW"
            and desiredStrata ~= "MEDIUM"
            and desiredStrata ~= "HIGH"
            and desiredStrata ~= "DIALOG"
            and desiredStrata ~= "FULLSCREEN"
            and desiredStrata ~= "FULLSCREEN_DIALOG"
            and desiredStrata ~= "TOOLTIP" --@formatter:on       highest
    then        
        _print("Invalid strata value '" .. _tostring(desiredStrata or "nil") .. "' - must be one of: background, low, medium, high, dialog, fullscreen, fullscreen_dialog, tooltip")
        return true
    end

    _rootFrame:SetFrameStrata(desiredStrata) --         attempt to set the new strata
    _activeSettings.Reticle.Strata = desiredStrata --   and then update the current settings
    
    _print("mouse-reticle strata set to '" .. _tostring(desiredStrata) .. "'")
    return true
end

local function _processPossibleCommandFor_Toggle(msgLowercased)
    if msgLowercased ~= "toggle" then
        return false
    end

    if _activeSettings.Reticle.Shown then -- todo   consolidate this away to remove duplicate code blocks
        _rootFrame:Hide()
        _mouseReticle:Hide()
        _activeSettings.Reticle.Shown = false
        _print("mouse-reticle turned off")
    else
        _rootFrame:Show()
        _mouseReticle:Show()
        _activeSettings.Reticle.Shown = true
        _print("mouse-reticle turned on")
    end

    return true
end

local function _processPossibleCommandFor_SetImagePath(msgLowercased)
    local desiredImagePath, isSetImagePathCommand = _strgsub(msgLowercased, "^%s*[Ii][Mm][Aa][Gg][Ee]%s+(.*)$", "%1") -- the file path can contain spaces in fact so we capture everything after the command
    if isSetImagePathCommand == nil or isSetImagePathCommand == 0 then
        return false
    end

    desiredImagePath = _strtrim(desiredImagePath or "")
    if desiredImagePath == "" then
        _print("you must provide an image-path")
        return true
    end

    _mouseReticle:SetTexture(nil) --              order   clear the texture of the reticle-frame first to force a reload from disk
    _mouseReticle:SetTexture(desiredImagePath) -- order   now attempt to set the new image path

    if not _mouseReticle:GetTexture() then --                              check if the new image was found on disk
        _mouseReticle:SetTexture(_activeSettings.Reticle.ImagePath) --     well we must revert back to the previous image path
        
        _print("[ERROR] mouse-overlay image was not found on disk - make sure the file '" .. desiredImagePath .. "' exists in the filesystem.")
        return true
    end

    _activeSettings.Reticle.ImagePath = desiredImagePath -- update the current settings

    _print("mouse-reticle image path set to '" .. _tostring(desiredImagePath) .. "'")
    return true
end

local function _processPossibleCommandFor_SetColor(msgLowercased)
    local desiredNamedColor, isSetColorCommand = _strgsub(msgLowercased, "^%s*color%s*(%S*).*$", "%1")
    if isSetColorCommand == nil or isSetColorCommand == 0 then
        return false
    end

    local colorRgbArray = _namedColors[_strupper(_strtrim(desiredNamedColor or ""))]
    if colorRgbArray == nil then
        _print("Unsupported named-color '" .. _tostring(desiredNamedColor or "nil") .. "' - must be one of the supported color names")
        return true
    end

    local desiredColorAlpha
    local desiredColorAlphaString, hasColorAlpha = _strgsub(msgLowercased, "^%s*color%s+(%S+)%s+(%S+)%s*$", "%2")

    if hasColorAlpha ~= nil and hasColorAlpha > 0 then
        -- optional alpha value
        desiredColorAlpha = _tonumber(_strtrim(desiredColorAlphaString or ""))
        if desiredColorAlpha == nil or desiredColorAlpha < 0 or desiredColorAlpha > 100 then
            _print("Invalid alpha value '" .. _tostring(desiredColorAlpha or "nil") .. "' - must be between [0, 100]")
            return true
        end

        desiredColorAlpha = desiredColorAlpha / 100 -- convert to [0.0, 1.0] range
    else
        desiredColorAlpha = _activeSettings.Reticle.Alpha -- use the existing alpha value from the current settings
    end

    _mouseReticle:SetVertexColor(colorRgbArray[1], colorRgbArray[2], colorRgbArray[3], desiredColorAlpha) -- attempt to set the new color

    _activeSettings.Reticle.Alpha = desiredColorAlpha --                    update the current settings
    _activeSettings.Reticle.Color = _cloneColorRgbArray(colorRgbArray) --   update the current settings

    _print("mouse-reticle color set to '" .. _tostring(desiredNamedColor) .. "'" .. (hasColorAlpha ~= nil and hasColorAlpha > 0 and (" with alpha " .. _tostring(desiredColorAlpha)) or ""))
    return true
end

local function _processPossibleCommandFor_ResetOrWipeout(msgLowercased)
    if msgLowercased ~= "reset" and msgLowercased ~= "wipeout" then
        return false
    end

    if msgLowercased == "wipeout" then
        MouseHighlightCircleSettingsDB = _copySettingsFromTo(_failsafeSettings, {}) -- reset the saved settings on disk to the failsafe defaults
    end
    
    _copySettingsFromTo(MouseHighlightCircleSettingsDB, _activeSettings) -- reload the settings from disk into the active settings

    --- RE-INITIALIZE USING THE SAVED SETTINGS WE JUST LOADED FROM DISK ---

    _rootFrame:SetFrameStrata(_activeSettings.Reticle.Strata) -- todo   consolidate away this duplicate code-blocks with the ones in the _init() function
    _mouseReticle:SetTexture(_activeSettings.Reticle.ImagePath)

    -- if the texture is not found _print an error and use a placeholder texture
    if not _mouseReticle:GetTexture() then
        _print("[ERROR] Mouse-overlay image '" .. _activeSettings.Reticle.ImagePath .. "' was not found on disk - reverting to the failsafe image")

        _activeSettings.Reticle.ImagePath = _failsafeSettings.Reticle.ImagePath -- update the current settings

        _mouseReticle:SetTexture(_failsafeSettings.Reticle.ImagePath)
        if not _mouseReticle:GetTexture() then
            _print("[CRITICAL ERROR] Failsafe image '" .. _failsafeSettings.Reticle.ImagePath .. "' was not found on disk either - using a plain white square as a last resort")
            _mouseReticle:SetTexture(1.0, 1.0, 1.0, 1.0) -- plain white square
        end
    end

    -- adjust texture dimensions and position
    _mouseReticle:SetWidth(_activeSettings.Reticle.Diameter)
    _mouseReticle:SetHeight(_activeSettings.Reticle.Diameter)
    _mouseReticle:SetVertexColor(_activeSettings.Reticle.Color[1], _activeSettings.Reticle.Color[2], _activeSettings.Reticle.Color[3], _activeSettings.Reticle.Alpha)

    if _activeSettings.Reticle.Shown then
        _rootFrame:Show()
        _mouseReticle:Show()
    else
        _rootFrame:Hide()
        _mouseReticle:Hide()
    end

    _print("Settings reset to " .. (msgLowercased == "wipeout" and "failsafe defaults" or "most recently saved settings from disk"))

    return true
end

local function _processPossibleCommandFor_SetAlpha(msgLowercased)
    local desiredColorAlphaString, isSetAlphaCommand = _strgsub(msgLowercased, "^%s*alpha%s*(%S*)%s*$", "%1")
    if isSetAlphaCommand == nil or isSetAlphaCommand == 0 then
        -- optional alpha value
        return false
    end

    local desiredColorAlpha = _tonumber(_strtrim(desiredColorAlphaString or ""))
    if desiredColorAlpha == nil or desiredColorAlpha < 0 or desiredColorAlpha > 100 then
        _print("Invalid alpha value '" .. _tostring(desiredColorAlpha or "nil") .. "' - must be between [0, 100]")
        return true
    end

    desiredColorAlpha = desiredColorAlpha / 100 -- order         convert to [0.0, 1.0] range
    _activeSettings.Reticle.Alpha = desiredColorAlpha -- order   update the current settings

    _mouseReticle:SetAlpha(desiredColorAlpha)

    _print("mouse-reticle alpha set to '" .. _tostring(desiredColorAlpha) .. "'")
    return true
end

local function _processPossibleCommandFor_SaveCurrentSettings(msgLowercased)
    if msgLowercased ~= "save" then
        return false
    end

    MouseHighlightCircleSettingsDB = _copySettingsFromTo(_activeSettings, {})

    _print("Settings saved")

    return true
end

local function _processPossibleCommandFor_PrintSettings(msg)
    function printImpl_(title, settings_)
        _print(title)
        _print("   ")
        _print("  - shown:      " .. _tostring(settings_.Reticle.Shown))
        _print("  - color:      " .. "rgb(" .. _tostring((settings_.Reticle or {}).Color[1] or "<nil>") .. ", " .. _tostring((settings_.Reticle or {}).Color[2] or "<nil>") .. ", " .. _tostring((settings_.Reticle or {}).Color[3] or "<nil>") .. ")")
        _print("  - alpha:      " .. _tostring(settings_.Reticle.Alpha or "<nil>"))
        _print("  - strata:     " .. _tostring(settings_.Reticle.Strata or "<nil>"))
        _print("  - diameter:   " .. _tostring(settings_.Reticle.Diameter or "<nil>"))
        _print("  - image path: " .. _tostring(settings_.Reticle.ImagePath or "<nil>"))
        _print("   ")    
    end
    
    if msg ~= "print" then
        return false
    end

    printImpl_("Saved settings:", MouseHighlightCircleSettingsDB)
    printImpl_("Current settings:", _activeSettings)

    return true
end

local function _processPossibleCommandFor_PrintUsageMessage(msg)
    if msg ~= "" then
        _print("Unknown command '" .. msg .. "'.")
        _print("Available commands:")
    end

    _print("  /mhc on        Show the reticle")
    _print("  /mhc show      Same as 'on'")

    _print("  /mhc off       Hide the reticle")
    _print("  /mhc hide      Same as 'off'")

    _print("  /mhc toggle    Toggle the reticle on and off")

    _print("  /mhc size      <pixels>    Set the diameter of the reticle")
    _print("  /mhc image     <path>      Set the reticle-image-file")
    _print("  /mhc strata    <strata>    Set the frame strata of the reticle (background, low, medium, high, dialog, fullscreen, fullscreen_dialog, tooltip)")

    _print("  /mhc alpha     <alpha>             Set just the alpha transparency of the reticle (0-100)")
    _print("  /mhc color     <color> [<alpha>]   Set the color of the reticle (e.g. red, blue, dark_gold, etc) with an optional alpha value (0-100)")

    _print("  /mhc save      Save the current MHC settings to disk (will persist across sessions)")
    _print("  /mhc print     Print the current MHC settings to chat")
    _print("  /mhc reset     Reset to the most recently saved-settings from disk (discarding any unsaved changes)")
    _print("  /mhc wipeout   Wipe all settings and revert to failsafe defaults")

    return false -- meaning that no command was successfully processed
end

-- register slash commands
local function _slashCommandHandler(msg)
    if not _isAddonLoaded then
        _print("Addon still loading - please wait a moment and try again")
        return false
    end
    
    local msgLowercased = _strlower(_strtrim(msg or "")) --          @formatter:off
    return _processPossibleCommandFor_SetColor(msgLowercased) --                           most spammed command first
            or _processPossibleCommandFor_ResetOrWipeout(msgLowercased)
            or _processPossibleCommandFor_SetAlpha(msgLowercased)
            or _processPossibleCommandFor_SetSize(msgLowercased)
            or _processPossibleCommandFor_SetImagePath(msg) -- dont pass the lowercased here   paths are case-sensitive
            or _processPossibleCommandFor_Toggle(msgLowercased)
            or _processPossibleCommandFor_ShowOrHide(msgLowercased)
            or _processPossibleCommandFor_SetStrata(msgLowercased)
            or _processPossibleCommandFor_SaveCurrentSettings(msgLowercased)
            or _processPossibleCommandFor_PrintSettings(msgLowercased) --                  least spammed command last
            or _processPossibleCommandFor_PrintUsageMessage(msg) --      @formatter:on     for invalid or empty commands
end

SLASH_MHC1 = "/mhc"
SLASH_MOUSE_HIGHLIGHT_CIRCLE1 = "/mouse_highlight_circle"

SlashCmdList["MHC"] = _slashCommandHandler
SlashCmdList["MOUSE_HIGHLIGHT_CIRCLE"] = _slashCommandHandler -- alias for those who prefer longer commands for the sake of clarity

_rootFrame:SetScript("OnEvent", function() -- must be dead last to detect when the addon has been loaded along with its saved-variables
    local eventSnapshot = event
    local addonThatJustGotLoaded = arg1

    if eventSnapshot == "ADDON_LOADED" and addonThatJustGotLoaded == "MouseHighlightCircle" then
        _init()
        return
    end
end)
_rootFrame:RegisterEvent("ADDON_LOADED")
