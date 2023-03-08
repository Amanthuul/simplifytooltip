-- Inspired by the ItemTooltipCleaner addon by Akkorian & Phanx. Thanks!
local strmatch = strmatch

local function topattern(str)
  str = gsub(str, "%%%d?$?c", ".+")
  str = gsub(str, "%%%d?$?d", "%%d+")
  str = gsub(str, "%%%d?$?s", ".+")
  str = gsub(str, "([%(%)])", "%%%1")
  return "^" .. str
end

-- Secondary stats
local STAT_CRIT = { "Equip: Improves critical strike rating by (%d+).", "Crit" }
local STAT_CRIT2 = { "Equip: Increases your critical strike rating by (%d+).", "Crit" }
local STAT_HASTE = { "Equip: Improves haste rating by (%d+).", "Haste" }
local STAT_HIT = { "Equip: Improves hit rating by (%d+).", "Hit" }
local STAT_HIT2 = { "Equip: Increases your hit rating by (%d+).", "Hit" }
local STAT_AP = { "Equip: Increases attack power by (%d+).", "Attack Power" }
local STAT_EXPERTISE = { "Equip: Increases your expertise rating by (%d+).", "Expertise" }
local STAT_DEFENSE = { "Equip: Increases defense rating by (%d+).", "Defense" }
local STAT_DODGE = { "Equip: Increases your dodge rating by (%d+).", "Dodge" }
local STAT_PARRY = { "Equip: Increases your parry rating by (%d+).", "Parry" }
local STAT_BLOCK_RATING = { "Equip: Increases your shield block rating by (%d+).", "Block Rating" }
local STAT_BLOCK_RATING2 = { "Equip: Increases your block rating by (%d+).", "Block Rating" }
local STAT_BLOCK_VALUE = { "Equip: Increases the block value of your shield by (%d+).", "Block Value" }
local STAT_RESIL = { "Equip: Improves your resilience rating by (%d+).", "Resilience" }
local STAT_SP = { "Equip: Increases spell power by (%d+).", "Spell Power" }
local STAT_MP5 = { "Equip: Restores (%d+) mana per 5 sec.", "Mp5" }
local STAT_ARP = { "Equip: Increases armor penetration rating by (%d+).", "ArP" }
local STAT_ARP2 = { "Equip: Increases your armor penetration by (%d+).", "ArP" }
local STAT_EXPERIENCE = { "Equip: Experience gained from killing monsters and completing quests increased by (%d+%%)",
  "XP" }
local STAT_FERAL_AP = { "Increases attack power by (%d+) in Cat, Bear, Dire Bear, and Moonkin forms only.", "Feral AP" }
local STAT_SPELL_PEN = { "Equip: Increases your spell penetration by (%d+).", "Spell Penetration" }
local STAT_RAP = { "Equip: Increases ranged attack power by (%d+).", "Ranged Attack Power" }

local STAT_LINES_TO_SHORTEN = {
  STAT_CRIT,
  STAT_CRIT2,
  STAT_HASTE,
  STAT_HIT,
  STAT_HIT2,
  STAT_AP,
  STAT_EXPERTISE,
  STAT_DEFENSE,
  STAT_DODGE,
  STAT_PARRY,
  STAT_BLOCK_RATING,
  STAT_BLOCK_RATING2,
  STAT_BLOCK_VALUE,
  STAT_RESIL,
  STAT_SP,
  STAT_MP5,
  STAT_ARP,
  STAT_ARP2,
  STAT_EXPERIENCE,
  STAT_FERAL_AP,
  STAT_SPELL_PEN,
  STAT_RAP
}

local CREATED_BY = topattern(ITEM_CREATED_BY)
local RACES = topattern(ITEM_RACES_ALLOWED)
local REQ_CLASS = topattern(ITEM_CLASSES_ALLOWED)
local REQ_LEVEL = topattern(ITEM_MIN_LEVEL)
local DURABILITY = "Durability %d+ / %d+"
local EQUIPMENT_SETS = "Equipment Sets: .+"

local WHAT_TO_HIDE = { RACES, CREATED_BY, REQ_LEVEL, DURABILITY, ITEM_SOCKETABLE, EQUIPMENT_SETS }

local directTextReplacements = {}
directTextReplacements["Use: Increases your haste rating by 340 for 12 sec. (1 Min Cooldown)"] = "Use: +340 Haste for 12s (1m CD)"

local freeTextToShorten = {}
freeTextToShorten["Defense Rating"] = "Defense"
freeTextToShorten["Socket Bonus"] = "Bonus"
freeTextToShorten["Armor Penetration Rating"] = "ArP"
freeTextToShorten["Critical Strike Rating"] = "Crit"
freeTextToShorten["Critical strike rating"] = "Crit"
freeTextToShorten["3%% Increased Critical Damage"] = "+3%% Crit Damage"
freeTextToShorten["Hit Rating"] = "Hit"
freeTextToShorten["mana per 5 seconds"] = "Mp5"
freeTextToShorten["Mana every 5 seconds"] = "Mp5"
freeTextToShorten["Mana per 5 sec"] = "Mp5"

local function ReformatLine(line, text)
  if not line then return end

  local directReplace = directTextReplacements[text]
  if directReplace then
    line:SetText(directReplace)
    return
  end

  for _, value in pairs(STAT_LINES_TO_SHORTEN) do
    local match = strmatch(text, value[1])
    if match then
      line:SetText(string.format("|cff00ff00+%s " .. value[2] .. "|r", match))
      return
    end
  end

  for _, value in pairs(WHAT_TO_HIDE) do
    if strmatch(text, value) then
      line:SetText("")
      return
    end
  end

  for key, value in pairs(freeTextToShorten) do
    text = string.gsub(text, key, value)
  end

  line:SetText(text)

end

local function ReformatLines(tooltip)
  local tooltipName = tooltip:GetName()

  local textLeft = tooltip.textLeft
  if not textLeft then
    textLeft = setmetatable({}, { __index = function(t, i)
      local line = _G[tooltipName .. "TextLeft" .. i]
      t[i] = line
      return line
    end })
    tooltip.textLeft = textLeft
  end

  local textRight = tooltip.textRight
  if not textRight then
    textRight = setmetatable({}, { __index = function(t, i)
      local line = _G[tooltipName .. "TextRight" .. i]
      t[i] = line
      return line
    end })
    tooltip.textRight = textRight
  end

  for i = 2, tooltip:NumLines() do
    local line = textLeft[i]
    local text = line:GetText()
    if text then
      ReformatLine(line, text)
    end
  end
end

local function ReformatItemTooltip(tooltip)

  -- only reformat item tooltips
  local _, link = tooltip:GetItem()
  if link ~= nil then
    ReformatLines(tooltip)
    local _, _, _, itemLevel, _, itemType = GetItemInfo(link)

    local shouldDisplay = itemType == "Weapon" or itemType == "Armor"
    if shouldDisplay then
      tooltip:AddDoubleLine("ilvl " .. itemLevel, "")
    end
  end

  tooltip:Show()
end

local itemTooltips = {
  -- Default UI
  "GameTooltip",
  "ItemRefTooltip",
  "ItemRefShoppingTooltip1",
  "ItemRefShoppingTooltip2",
  "ItemRefShoppingTooltip3",
  "ShoppingTooltip1",
  "ShoppingTooltip2",
  "ShoppingTooltip3",
}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self, event, arg)

  -- Hook tooltips:
  for i, tooltip in pairs(itemTooltips) do
    tooltip = _G[tooltip]
    if tooltip then
      -- Hooks for removing text:
      tooltip:HookScript("OnTooltipSetItem", ReformatItemTooltip)
      -- Hooks for fixing line spacing:
      -- Done with this tooltip.
      itemTooltips[i] = nil
    end
  end
  if not next(itemTooltips) then
    self:UnregisterEvent(event)
    self:SetScript("OnEvent", nil)
  end
end)
