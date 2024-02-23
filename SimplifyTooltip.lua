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
local STAT_CRIT = { "Если на персонаже: Повышает рейтинг критического удара на (%d+).", "к критическому удару" }
local STAT_HASTE = { "Если на персонаже: Повышает рейтинг скорости боя на (%d+).", "к скорости" }
local STAT_HIT = { "Если на персонаже: Повышает рейтинг меткости на (%d+).", "к меткости" }
local STAT_AP = { "Если на персонаже: Увеличивает силу атаки на (%d+).", "к силе атаки" }
local STAT_AP2 = { "Если на персонаже: Повышает силу атаки на (%d+).", "к силе атаки" }
local STAT_EXPERTISE = { "Если на персонаже: Повышает рейтинг мастерства на (%d+).", "к мастерству" }
local STAT_DEFENSE = { "Если на персонаже: Повышает рейтинг защиты на (%d+).", "к защите" }
local STAT_DODGE = { "Если на персонаже: Повышает рейтинг уклонения на (%d+).", "к уклонению" }
local STAT_PARRY = { "Если на персонаже: Повышает рейтинг парирования на (%d+).", "к парированию" }
local STAT_BLOCK_RATING = { "Если на персонаже: Увеличивает рейтинг блокирования щитом на (%d+).", "к рейтингу блокирования" }
local STAT_BLOCK_VALUE = { "Если на персонаже: Увеличивает показатель блокирования щита на (%d+).", "к блокированию" }
local STAT_BLOCK_VALUE2 = { "Если на персонаже: Увеличивает показатель блокирования вашего щита на (%d+).", "к блокированию" }
local STAT_BLOCK_VALUE3 = { "Если на персонаже: Повышает показатель блокирования вашего щита на (%d+) ед.", "к блокированию" }
local STAT_RESIL = { "Если на персонаже: Повышает рейтинг устойчивости на (%d+).", "к устойчивости" }
local STAT_SP = { "Если на персонаже: Увеличивает силу заклинаний на (%d+).", "к силе заклинаний" }
local STAT_MP5 = { "Если на персонаже: Восполнение (%d+) ед. маны в 5 секунд.", "к МП5" }
local STAT_MP52 = { "Если на персонаже: Восполнение (%d+) ед. маны раз в 5 секунд.", "к МП5" }
local STAT_MP53 = { "Если на персонаже: Восполнение (%d+) ед. маны за 5 сек.", "к МП5" }
local STAT_ARP = { "Если на персонаже: Снижает эффективность брони противника против ваших атак на (%d+).", "к АРП" }
local STAT_ARP2 = { "Если на персонаже: Увеличивает рейтинг пробивания брони на (%d+).", "к АРП" }
local STAT_EXPERIENCE = { "Если на персонаже: Повышает опыт, получаемый за убийство монстров и выполнение заданий, на (%d+%%)", "опыта" }
local STAT_FERAL_AP = { "Увеличивает силу атаки на (%d+) ед. в облике кошки, медведя, лютого медведя или лунного совуха.", "к силе атаки (ферал)" }
local STAT_SPELL_PEN = { "Если на персонаже: Увеличивает проникающую способность заклинаний на (%d+).", "к проникающей способности заклинаний" }
local STAT_RAP = { "Если на персонаже: Увеличивает силу атак дальнего боя на (%d+).", "к силе атаки дальнего боя" }

local STAT_LINES_TO_SHORTEN = {
  STAT_CRIT,
  STAT_HASTE,
  STAT_HIT,
  STAT_AP,
  STAT_AP2,
  STAT_EXPERTISE,
  STAT_DEFENSE,
  STAT_DODGE,
  STAT_PARRY,
  STAT_BLOCK_RATING,
  STAT_BLOCK_VALUE,
  STAT_BLOCK_VALUE2,
  STAT_BLOCK_VALUE3,
  STAT_RESIL,
  STAT_SP,
  STAT_MP5,
  STAT_MP52,
  STAT_MP53,
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
local DURABILITY = "Прочность: %d+ / %d+"
local EQUIPMENT_SETS = "Комплекты экипировки: .+"

--Сюда можно вписать строчки сверху чтобы скрыть соответствующие строки.
local WHAT_TO_HIDE = { RACES, CREATED_BY, ITEM_SOCKETABLE, EQUIPMENT_SETS, DURABILITY}

local directTextReplacements = {}
directTextReplacements["Использование: Повышает рейтинг скорости на 340 на 12 sec. (1 Мин Восстановление)"] = "Использование: +340 скорости на 12с. (1 Мин Восстановление)"

local freeTextToShorten = {}
freeTextToShorten["к рейтингу защиты"] = "к защите"
freeTextToShorten["При соответствии цвета:"] = "Бонус:"
freeTextToShorten["к рейтингу пробивания брони"] = "к АРП"
freeTextToShorten["к рейтингу парирования"] = "к парированию"
freeTextToShorten["к рейтингу уклонения"] = "к уклонению"
freeTextToShorten["к рейтингу устойчивости"] = "к устойчивости"
freeTextToShorten["к рейтингу критического удара"] = "к критическому удару"
freeTextToShorten["к рейтингу скорости"] = "к скорости"
freeTextToShorten["к рейтингу мастерства"] = "к мастерству"
freeTextToShorten["к рейтингу меткости"] = "к меткости"
freeTextToShorten["ед. маны каждые 5 секунд"] = "к МП5"
freeTextToShorten["к мане каждые 5 секунд"] = "к МП5"
freeTextToShorten["Если на персонаже:"] = "Эффект:"


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


local function ReformatLines(...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText()
			if text then
				ReformatLine(region, text)
			end
        end
    end
end


local function ReformatItemTooltip(tooltip)

  -- only reformat item tooltips
  local _, link = tooltip:GetItem()
  if link ~= nil then
    ReformatLines(tooltip:GetRegions())
    local _, _, _, itemLevel, _, itemType = GetItemInfo(link)

   local shouldDisplay = itemType == "Оружие" or itemType == "Доспехи"
 --   if shouldDisplay then
  --    tooltip:AddDoubleLine("iLvl: " .. itemLevel, "")
 --   end
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
