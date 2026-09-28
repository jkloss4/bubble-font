-- BubbleFont: adjusts the font size of chat bubbles (NPC speech and player /say bubbles),
-- which all draw with Blizzard's ChatBubbleFont font object. Bubbles size themselves to
-- their text when they appear, so a change applies to every bubble shown afterward.

local addonName = ...

local MIN_SIZE = 6
local MAX_SIZE = 24

-- The game's own bubble font size, captured before we change anything, used for "reset".
local defaultPath, defaultSize, defaultFlags = ChatBubbleFont:GetFont()
defaultPath = defaultPath or STANDARD_TEXT_FONT
defaultSize = math.floor((defaultSize or 13) + 0.5)
defaultFlags = defaultFlags or ""

local refreshPanel = function() end

--- Apply the saved size (or the game's default when none is saved) to ChatBubbleFont.
local function applySize()
    local size = BubbleFontDB.size or defaultSize
    ChatBubbleFont:SetFont(defaultPath, size, defaultFlags)
end

--- Set and save the bubble font size. nil resets it to the game's default.
--- @param size number|nil
local function setSize(size)
    if size then
        size = math.max(MIN_SIZE, math.min(MAX_SIZE, math.floor(size + 0.5)))
        if size == defaultSize then size = nil end
    end
    BubbleFontDB.size = size
    applySize()
    refreshPanel()
end

local function getSize()
    return BubbleFontDB.size or defaultSize
end

-- Options panel. Built only from this addon's own frames (a canvas category) rather than
-- Blizzard's pooled Settings controls, so it can't taint Blizzard's own settings pages.
local panel = CreateFrame("Frame")
panel:Hide() -- start hidden so OnShow fires when the Settings panel first displays it

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("BubbleFont")

local intro = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
intro:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
intro:SetText("Font size of chat bubbles, including NPC speech. Applies to new bubbles.")

local sizeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
sizeLabel:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -24)
sizeLabel:SetText("Font size")

-- Blizzard's own options-page slider (as used by ForeverQuestMark): a slider with built-in arrow
-- steppers at each end, which disable themselves at the minimum and maximum.
local slider = CreateFrame("Frame", nil, panel, "MinimalSliderWithSteppersTemplate")
slider:SetSize(250, 20)
slider:SetPoint("LEFT", sizeLabel, "RIGHT", 12, 0)

local valueText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
valueText:SetPoint("LEFT", slider, "RIGHT", 8, 0)

local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetButton:SetSize(140, 22)
resetButton:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 0, -20)
resetButton:SetText("Reset to default")
resetButton:SetScript("OnClick", function() setSize(nil) end)

local function formatSize(size)
    if size == defaultSize then
        return size .. " pt (default)"
    end
    return size .. " pt"
end

-- The template's value-changed callback also fires when the value is set from code, so
-- `syncing` marks those refreshes to avoid saving them back as if the user had moved it.
local syncing = false
slider:Init(defaultSize, MIN_SIZE, MAX_SIZE, MAX_SIZE - MIN_SIZE, {})
slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
    value = math.floor(value + 0.5)
    valueText:SetText(formatSize(value))
    if not syncing then
        setSize(value)
    end
end, panel)

refreshPanel = function()
    syncing = true
    slider:SetValue(getSize())
    syncing = false
    valueText:SetText(formatSize(getSize()))
end
panel:SetScript("OnShow", refreshPanel)

local category = Settings.RegisterCanvasLayoutCategory(panel, "BubbleFont")
Settings.RegisterAddOnCategory(category)

-- Slash command: /bubblefont <size>, /bubblefont reset, or /bubblefont to open the options.
SLASH_BUBBLEFONT1 = "/bubblefont"
SlashCmdList["BUBBLEFONT"] = function(msg)
    msg = strtrim(msg or ""):lower()
    local size = tonumber(msg)
    if size then
        setSize(size)
        print(("BubbleFont: chat bubble font size set to %d pt."):format(getSize()))
    elseif msg == "reset" then
        setSize(nil)
        print(("BubbleFont: chat bubble font size reset to the default (%d pt)."):format(defaultSize))
    else
        Settings.OpenToCategory(category:GetID())
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    BubbleFontDB = BubbleFontDB or {}
    applySize()
    refreshPanel()
end)
