-- BubbleFont: adjusts the font size of chat bubbles (NPC speech and player /say bubbles),
-- which all draw with Blizzard's ChatBubbleFont font object. Bubbles size themselves to
-- their text when they appear, so a change applies to every bubble shown afterward.

local addonName, ns = ...

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

-- Options page (Options > AddOns > BubbleFont), drawn in Blizzard's settings style by SettingsKit
local Kit = ns.SettingsKit

local function formatSize(size)
    if size == defaultSize then
        return size .. " pt (default)"
    end
    return size .. " pt"
end

local page = Kit.NewPage("BubbleFont", { onDefaults = function() setSize(nil) end })
page:Header("Chat Bubbles")
page:Slider("Font Size", MIN_SIZE, MAX_SIZE, 1, getSize, setSize, formatSize,
    "Font size of chat bubbles, including NPC speech and players' /say and /yell. Applies to bubbles shown after the change.")
Kit.Register(page)

refreshPanel = function() page:Refresh() end

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
        Kit.Open(page)
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
