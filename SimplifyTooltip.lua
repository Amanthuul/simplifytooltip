-- Inspired by the ItemTooltipCleaner addon by Akkorian & Phanx. Thanks!
local strmatch = strmatch

local function topattern(str)
  str = gsub(str, "%%%d?$?c", ".+")
  str = gsub(str, "%%%d?$?d", "%%d+")
  str = gsub(str, "%%%d?$?s", ".+")
  str = gsub(str, "([%(%)])", "%%%1")
  return "^" .. str
end


local STAT_CRIT_Classic = { "Equip: Improves your chance to get a critical strike with melee and ranged attacks and with spells by (%d+).", "Crit" }
local STAT_CRIT_Classic_set = { "Set: Improves your chance to get a critical strike with melee and ranged attacks and with spells by (%d+).", "Crit" }
local STAT_CRIT_Melee_Ranged_Classic = { "Equip: Improves your chance to get a critical strike by (%d+).", "Melee/Ranged Crit" }
local STAT_CRIT_Melee_Ranged_Classic_set = { "Set: Improves your chance to get a critical strike by (%d+).", "Melee/Ranged Crit" }
local STAT_CRIT_Spell_Classic = { "Equip: Improves your chance to get a critical strike with spells by (%d+).", "Spell Crit" }
local STAT_HIT_Classic_set = { "Set: Improves your chance to hit with spells and with melee and ranged attacks by (%d+).", "Hit" }
local STAT_HIT_Classic = { "Equip: Improves your chance to hit with spells and with melee and ranged attacks by (%d+).", "Hit" }
local STAT_HIT_Melee_Ranged_Classic = { "Equip: Improves your chance to hit by (%d+).", "Melee/Ranged Hit" }
local STAT_HIT_Melee_Ranged_Classic_set = { "Set: Improves your chance to hit by (%d+).", "Melee/Ranged Hit" }
local STAT_HIT_Spell_Classic = { "Equip: Improves your chance to hit with spells by (%d+).", "Spell Hit" }
local STAT_AP_Classic = { "Equip: %+(%d+) Attack Power.", "Attack Power" }
local STAT_Ranged_AP_Classic = { "Equip: %+(%d+) ranged Attack Power.", "Ranged Attack Power" }
local STAT_DEFENSE_Classic = { "Equip: Increased Defense %+(%d+).", "Defense" }
local STAT_DEFENSE_Classic_set = { "Set: Increased Defense %+(%d+).", "Defense" }
local STAT_DODGE_Classic = { "Equip: Increases your chance to dodge an attack by (%d+).", "Dodge" }
local STAT_PARRY_Classic = { "Equip: Increases your chance to parry an attack by (%d+).", "Parry" }
local STAT_BLOCK_CHANCE_Classic = { "Equip: Increases your chance to block attacks with a shield by (%d+).", "Block Chance" }
local STAT_SP_Classic = { "Equip: Increases damage and healing done by magical spells and effects by up to (%d+).", "Spell Power" }
local STAT_SP_Classic_set = { "Set: Increases damage and healing done by magical spells and effects by up to (%d+).", "Spell Power" }
local STAT_SPH_Classic = { "Equip: Increases healing done by spells and effects by up to (%d+).", "Healing Spells" }
local STAT_SPH_Classic_set = { "Set: Increases damage and healing done by magical spells and effects by up to (%d+).", "Healing Spells" }
local STAT_SPFire = { "Equip: Increases damage done by Fire spells and effects by up to (%d+).", "Fire Spell Damage" }
local STAT_SPShadow = { "Equip: Increases damage done by Shadow spells and effects by up to (%d+).", "Shadow Spell Damage" }
local STAT_SPHoly = { "Equip: Increases damage done by Holy spells and effects by up to (%d+).", "Holy Spell Damage" }
local STAT_SPFrost = { "Equip: Increases damage done by Frost spells and effects by up to (%d+).", "Frost Spell Damage" }
local STAT_SPArcane = { "Equip: Increases damage done by Arcane spells and effects by up to (%d+).", "Arcane Spell Damage" }
local STAT_SPNature = { "Equip: Increases damage done by Nature spells and effects by up to (%d+).", "Nature Spell Damage" }
local STAT_MP5 = { "Equip: Restores (%d+) mana per 5 sec.", "Mp5" }
local STAT_MP5_Classic_set = { "Set: Restores (%d+) Mp5.", "Mp5" }
local STAT_FERAL_AP_Classic = { "Equip: %+(%d+) Attack Power in Cat, Bear, and Dire Bear forms only.", "Feral AP" }
local STAT_FERAL_AP_Classic_set = { "Set: %+(%d+) Attack Power in Cat, Bear, and Dire Bear forms only.", "Feral AP" }

local STAT_AXES = { "Equip: Increased Axes %+(%d+).", "Axes" }
local STAT_AXES_2H = { "Equip: Increased Two%-handed Axes %+(%d+).", "Two-handed Axes" }
local STAT_DAGGERS = { "Equip: Increased Daggers %+(%d+).", "Daggers" }
local STAT_SWORDS = { "Equip: Increased Swords %+(%d+).", "Swords" }
local STAT_SWORDS_2H = { "Equip: Increased Two%-handed Swords %+(%d+).", "Two-handed Swords" }
local STAT_MACES = { "Equip: Increased Maces %+(%d+).", "Maces" }
local STAT_MACES_2H = { "Equip: Increased Two%-handed Maces %+(%d+).", "Two-handed Maces" }
local STAT_FIST = { "Equip: Increased Fist Weapons %+(%d+).", "Fist Weapons" }
local STAT_BOWS = { "Equip: Increased Bows %+(%d+).", "Bows" }
local STAT_CROSSBOWS = { "Equip: Increased Crossbows %+(%d+).", "Crossbows" }
local STAT_GUNS = { "Equip: Increased Guns %+(%d+).", "Guns" }
local STAT_STAVES = { "Equip: Increased Staves %+(%d+).", "Staves" }
local STAT_AXES_set = { "Set: Increased Axes %+(%d+).", "Axes" }
local STAT_AXES_2H_set = { "Set: Increased Two%-handed Axes %+(%d+).", "Two-handed Axes" }
local STAT_DAGGERS_set = { "Set: Increased Daggers %+(%d+).", "Daggers" }
local STAT_SWORDS_set = { "Set: Increased Swords %+(%d+).", "Swords" }
local STAT_SWORDS_2H_set = { "Set: Increased Two%-handed Swords %+(%d+).", "Two-handed Swords" }
local STAT_MACES_set = { "Set: Increased Maces %+(%d+).", "Maces" }
local STAT_MACES_2H_set = { "Set: Increased Two%-handed Maces %+(%d+).", "Two-handed Maces" }
local STAT_FIST_set = { "Set: Increased Fist Weapons %+(%d+).", "Fist Weapons" }
local STAT_BOWS_set = { "Set: Increased Bows %+(%d+).", "Bows" }
local STAT_CROSSBOWS_set = { "Set: Increased Crossbows %+(%d+).", "Crossbows" }
local STAT_GUNS_set = { "Set: Increased Guns %+(%d+).", "Guns" }
local STAT_STAVES_set = { "Set: Increased Staves %+(%d+).", "Staves" }
local STAT_AP_Classic_set = {"placeholder","placeholder"}
local STAT_FERAL_AP_Classic_2 = {"placeholder","placeholder"}
local STAT_FERAL_AP_Classic_set_2 = {"placeholder","placeholder"}

local STAT_AP_BEAST = { "Equip: %+(%d+) Attack Power when fighting Beasts.", "Attack Power vs Beasts" }
local STAT_AP_DEMON = { "Equip: %+(%d+) Attack Power when fighting Demons.", "Attack Power vs Demons" }
local STAT_AP_DRAGON = { "Equip: %+(%d+) Attack Power when fighting Dragonkin.", "Attack Power vs Dragons" }
local STAT_AP_ELEMENTAL = { "Equip: %+(%d+) Attack Power when fighting Elementals.", "Attack Power vs Elementals" }
local STAT_AP_MECH = { "Equip: %+(%d+)  Attack Power when fighting Mechanical units.", "Attack Power vs Mechanical" }
local STAT_AP_UNDEAD = { "Equip: %+(%d+) Attack Power when fighting Undead.", "Attack Power vs Undead" }

if (GetLocale() == "ruRU") then
 STAT_CRIT_Classic = { "Если на персонаже: Повышает вероятность нанести критический удар атаками ближнего и дальнего боя, а также заклинаниями на (%d+).", "критического удара" }
 STAT_CRIT_Classic_set = { "Комплект.+: Повышает вероятность нанести критический удар атаками ближнего и дальнего боя, а также заклинаниями на (%d+).", "критического удара" }
 STAT_CRIT_Melee_Ranged_Classic = { "Если на персонаже: Увеличение вероятности нанесения критического урона на (%d+).", "критического удара ближнего и дальнего боя" }
 STAT_CRIT_Melee_Ranged_Classic_set = { "Комплект.+: Увеличение вероятности нанесения критического урона на (%d+).", "критического удара ближнего и дальнего боя" }
 STAT_CRIT_Spell_Classic = { "Если на персонаже: Увеличение рейтинга критического эффекта заклинаний на (%d+).", "критического удара заклинаниями" }
 STAT_HIT_Classic_set = { "Комплект.+: Повышает вероятность попадания заклинаниями и атаками в ближнем и дальнем бою на (%d+).", "меткости" }
 STAT_HIT_Classic = { "Если на персонаже: Повышает вероятность попадания заклинаниями и атаками в ближнем и дальнем бою на (%d+).", "меткости" }
 STAT_HIT_Melee_Ranged_Classic = { "Если на персонаже: Вероятность нанесения удара увеличена на (%d+).", "меткости ближнего/дальнего боя" }
 STAT_HIT_Melee_Ranged_Classic_set = { "Комплект.+: Вероятность нанесения удара увеличена на (%d+).", "меткости ближнего/дальнего боя" }
 STAT_HIT_Spell_Classic = { "Если на персонаже: Повышение на (%d+)%% рейтинга меткости заклинаний.", "меткости заклинаний" }
 STAT_AP_Classic = { "Если на персонаже: Увеличивает силу атаки на (%d+).", "силы атаки" }
 STAT_AP_Classic_set = { "Комплект.+: Увеличивает силу атаки на (%d+).", "силы атаки"}
 STAT_Ranged_AP_Classic = { "Если на персонаже: Увеличение силы атаки в дальнем бою на (%d+) ед.", "силы атаки дальнего боя" }
 STAT_DEFENSE_Classic = { "Если на персонаже: Увеличение рейтинга защиты на (%d+) ед.", "защиты" }
 STAT_DEFENSE_Classic_set = { "Комплект.+: Увеличение рейтинга защиты на (%d+) ед.", "защиты" }
 STAT_DODGE_Classic = { "Если на персонаже: Увеличение рейтинга уклонения на (%d+).", "уклонения" }
 STAT_PARRY_Classic = { "Если на персонаже: Увеличение рейтинга парирования атак на (%d+).", "парирования" }
 STAT_BLOCK_CHANCE_Classic = { "Если на персонаже: Повышает вероятность блокирования атаки щитом на (%d+).", "шанса блокирования" }
 STAT_SP_Classic = { "Если на персонаже: Увеличение урона и целительного действия магических заклинаний и эффектов не более чем на (%d+).", "силы заклинаний" }
 STAT_SP_Classic_set = { "Комплект.+: Увеличение урона и целительного действия магических заклинаний и эффектов не более чем на (%d+).", "силы заклинаний" }
 STAT_SPH_Classic = { "Если на персонаже: Усиливает исцеление от заклинаний и эффектов максимум на (%d+).", "к исцеляющим заклинаниям" }
 STAT_SPH_Classic_set = { "Комплект.+: Усиливает исцеление от заклинаний и эффектов максимум на (%d+).", "к исцеляющим заклинаниям" }
 STAT_SPFire = { "Если на персонаже: Увеличение наносимого урона от заклинаний и эффектов огня не более чем на (%d+).", "к урону от огня" }
 STAT_SPShadow = { "Если на персонаже: Увеличение урона, наносимого заклинаниями и эффектами темной магии, на (%d+).", "к урону от заклинаний темной магии" }
 STAT_SPHoly = { "Если на персонаже: Увеличение урона, наносимого заклинаниями и эффектами светлой магии, на (%d+).", "к урону от заклинаний светлой магии" }
 STAT_SPFrost = { "Если на персонаже: Увеличение урона, наносимого заклинаниями и эффектами льда, на (%d+).", "к урону от заклинаний магии льда" }
 STAT_SPArcane = { "Если на персонаже: Увеличение урона, наносимого заклинаниями и эффектами тайной магии, на (%d+).", "к урону от заклинаний тайной магии" }
 STAT_SPNature = { "Если на персонаже: Увеличение урона, наносимого заклинаниями и эффектами сил природы, на (%d+).", "к урону от сил природы" }
 STAT_MP5 = { "Если на персонаже: Восполнение (%d+) ед. маны раз в 5 сек.", "к МП5" }
 STAT_MP5_Classic_set = { "Комплект.+: Восполнение (%d+) ед. маны раз в 5 сек.", "к МП5" }
 STAT_FERAL_AP_Classic = { "Если на персонаже: %+(%d+) к силе атаки в облике кошки, медведя и лютого медведя.", "к силе атаки (ферал)" }
 STAT_FERAL_AP_Classic_2 = { "Если на персонаже: Увеличивает силу атаки на (%d+) ед. в облике кошки, медведя и лютого медведя.", "к силе атаки (ферал)" }
 STAT_FERAL_AP_Classic_set = { "Комплект.+: %+(%d+) к силе атаки в облике кошки, медведя и лютого медведя.", "к силе атаки (ферал)" }
 STAT_FERAL_AP_Classic_set_2 = { "Комплект.+: Увеличивает силу атаки на (%d+) ед. в облике кошки, медведя и лютого медведя.", "к силе атаки (ферал)" }

 STAT_AXES = { "Если на персонаже: Повышение навыка использования топоров на (%d+).", "Топоры" }
 STAT_AXES_2H = { "Если на персонаже: Двуручные топоры %+(%d+).", "Двуручные топоры" }
 STAT_DAGGERS = { "Если на персонаже: Улучшение владения кинжалом на %+(%d+).", "Кинжалы" }
 STAT_SWORDS = { "Если на персонаже: Повышение навыка владения мечом на %+(%d+).", "Мечи" }
 STAT_SWORDS_2H = { "Если на персонаже: Двуручные мечи %+(%d+).", "Двуручные мечи" }
 STAT_MACES = { "Если на персонаже: Повышение навыка владения палицей на %+(%d+).", "Дробящее оружие" }
 STAT_MACES_2H = { "Если на персонаже: Двуручное ударное оружие %+ (%d+).", "Двуручное дробящее оружие" }
 STAT_FIST = { "Если на персонаже: Повышение навыка владения кистевым оружием на (%d+) ед.", "Кистевое оружие" }
 STAT_BOWS = { "Если на персонаже: Повышение навыка владения луком на %+(%d+).", "Луки" }
 STAT_CROSSBOWS = { "Если на персонаже: Увеличение рейтинга навыка владения арбалетом на (%d+).", "Арбалеты" }
 STAT_GUNS = { "Если на персонаже: Повышение навыка использования огнестрельного оружия на (%d+) ед.", "Огнестрельное оружие" }
 STAT_STAVES = { "Если на персонаже: Повышение навыка использования посохов на (%d+) ед.", "Посохи" }
 STAT_AXES_set = { "Комплект.+: Повышение навыка использования топоров на (%d+).", "Топоры" }
 STAT_AXES_2H_set = { "Комплект.+: Двуручные топоры %+(%d+).", "Двуручные топоры" }
 STAT_DAGGERS_set = { "Комплект.+: Улучшение владения кинжалом на %+(%d+).", "Кинжалы" }
 STAT_SWORDS_set = { "Комплект.+: Повышение навыка владения мечом на %+(%d+).", "Мечи" }
 STAT_SWORDS_2H_set = { "Комплект.+: Двуручные мечи %+(%d+).", "Двуручные мечи" }
 STAT_MACES_set = { "Комплект.+: Повышение навыка владения палицей на %+(%d+).", "Дробящее оружие" }
 STAT_MACES_2H_set = { "Комплект.+: Двуручное ударное оружие %+ (%d+).", "Двуручное дробящее оружие" }
 STAT_FIST_set = { "Комплект.+: Повышение навыка владения кистевым оружием на (%d+) ед.", "Кистевое оружие" }
 STAT_BOWS_set = { "Комплект.+: Повышение навыка владения луком на %+(%d+).", "Луки" }
 STAT_CROSSBOWS_set = { "Комплект.+: Увеличение рейтинга навыка владения арбалетом на (%d+).", "Арбалеты" }
 STAT_GUNS_set = { "Комплект.+: Повышение навыка использования огнестрельного оружия на (%d+) ед.", "Огнестрельное оружие" }
 STAT_STAVES_set = { "Комплект.+: Повышение навыка использования посохов на (%d+) ед.", "Посохи" }
 STAT_AP_BEAST = { "Если на персонаже: Увеличение на (%d+) ед. силы атаки в бою с животными.", "силы атаки против животных" }
 STAT_AP_DEMON = { "Если на персонаже: Повышение силы атаки на (%d+) ед. в бою с демонами.", "силы атаки против демонов" }
 STAT_AP_DRAGON = { "Если на персонаже: Увеличивает силу атаки на (%d+) ед. в битве с драконами.", "силы атаки против драконов" }
 STAT_AP_ELEMENTAL = { "Если на персонаже: Увеличение силы атаки на (%d+) ед. в битве с элементалями.", "силы атаки против элементалей" }
 STAT_AP_MECH = { "Если на персонаже: Увеличивает силу атаки на (%d+) ед. в бою с механизмами.", "силы атаки против механизмов" }
 STAT_AP_UNDEAD = { "Если на персонаже: Увеличение силы атаки на (%d+) ед. в бою с нежитью.", "силы атаки против нежити" }
end
local STAT_LINES_TO_SHORTEN = {
  STAT_FERAL_AP_Classic,
  STAT_FERAL_AP_Classic_2,
  STAT_AP_BEAST,
  STAT_AP_DEMON,
  STAT_AP_DRAGON,
  STAT_AP_ELEMENTAL,
  STAT_AP_MECH,
  STAT_AP_UNDEAD,

  STAT_DEFENSE_Classic,
  STAT_SP_Classic,
  STAT_SPH_Classic,
  STAT_SPFire,
  STAT_SPShadow,
  STAT_SPHoly,
  STAT_SPFrost,
  STAT_SPArcane,
  STAT_SPNature,
  STAT_MP5,
  STAT_AXES,
  STAT_AXES_2H,
  STAT_DAGGERS,
  STAT_SWORDS,
  STAT_SWORDS_2H,
  STAT_MACES,
  STAT_MACES_2H,
  STAT_FIST,
  STAT_BOWS,
  STAT_CROSSBOWS,
  STAT_GUNS,
  STAT_STAVES,  
  STAT_AP_Classic,
  STAT_Ranged_AP_Classic,
}
local STAT_LINES_TO_SHORTEN_Percent = {
  STAT_CRIT_Classic,
  STAT_CRIT_Melee_Ranged_Classic,
  STAT_CRIT_Spell_Classic,
  STAT_HIT_Classic,
  STAT_HIT_Melee_Ranged_Classic,
  STAT_HIT_Spell_Classic,
  STAT_DODGE_Classic,
  STAT_PARRY_Classic,
  STAT_BLOCK_CHANCE_Classic,
}
local STAT_LINES_TO_SHORTEN_SET = {
  STAT_FERAL_AP_Classic_set,
  STAT_FERAL_AP_Classic_set_2,
  STAT_SP_Classic_set,
  STAT_SPH_Classic_set,
  STAT_MP5_Classic_set,
  STAT_DEFENSE_Classic_set,
  STAT_AXES_set,
  STAT_AXES_2H_set,
  STAT_DAGGERS_set,
  STAT_SWORDS_set,
  STAT_SWORDS_2H_set,
  STAT_MACES_set,
  STAT_MACES_2H_set,
  STAT_FIST_set,
  STAT_BOWS_set,
  STAT_CROSSBOWS_set,
  STAT_GUNS_set,
  STAT_STAVES_set,
  STAT_AP_Classic_set,
}
local STAT_LINES_TO_SHORTEN_SET_Percent = {
  STAT_HIT_Classic_set,
  STAT_CRIT_Classic_set,
  STAT_CRIT_Melee_Ranged_Classic_set,
  STAT_HIT_Melee_Ranged_Classic_set,
}

local CREATED_BY = topattern(ITEM_CREATED_BY)
local RACES = topattern(ITEM_RACES_ALLOWED)
local REQ_CLASS = topattern(ITEM_CLASSES_ALLOWED)
local REQ_LEVEL = topattern(ITEM_MIN_LEVEL)
local DURABILITY = "Durability %d+ / %d+"
local EQUIPMENT_SETS = "Equipment Sets: .+"
if (GetLocale() == "ruRU") then
local DURABILITY = "Прочность: %d+ / %d+"
local EQUIPMENT_SETS = "Комплекты экипировки: .+"
end

local WHAT_TO_HIDE = { RACES, CREATED_BY, DURABILITY, ITEM_SOCKETABLE, EQUIPMENT_SETS }

local directTextReplacements = {}
directTextReplacements["Use: Increases your haste rating by 340 for 12 sec. (1 Min Cooldown)"] = "Use: +340 Haste for 12s (1m CD)"
if (GetLocale() == "ruRU") then
directTextReplacements["Использование: Повышает рейтинг скорости на 340 на 12 sec. (1 Мин Восстановление)"] = "Использование: +340 скорости на 12с. (1 Мин Восстановление)"
end

local freeTextToShorten = {}
freeTextToShorten["mana per 5 seconds"] = "Mp5"
freeTextToShorten["Mana every 5 seconds"] = "Mp5"
freeTextToShorten["Mana per 5 sec"] = "Mp5"
freeTextToShorten["mana per 5 sec"] = "Mp5"
freeTextToShorten["Equip:"] = "Effect:"
if (GetLocale() == "ruRU") then
freeTextToShorten["ед. маны каждые 5 секунд"] = "к МП5"
freeTextToShorten["к мане каждые 5 секунд"] = "к МП5"
freeTextToShorten["Если на персонаже:"] = "Эффект:"
end

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
  
  for _, value in pairs(STAT_LINES_TO_SHORTEN_Percent) do
    local match = strmatch(text, value[1])
    if match then
      line:SetText(string.format("|cff00ff00+%s%% " .. value[2] .. "|r", match))
      return
    end
  end
  
  if (GetLocale() == "ruRU") then
   for _, value in pairs(STAT_LINES_TO_SHORTEN_SET) do
    local match = strmatch(text, value[1])
    if match then
local set = text:sub(19, 20)
	set = tonumber(set)
	if type(set) == "number" then
	if set < 5 then
      line:SetText(string.format("Комплект (".. set .." предмета): +%s " .. value[2] .. ".|r", match))
	  else
	  line:SetText(string.format("Комплект (".. set .." предметов): +%s " .. value[2] .. ".|r", match))
	  end
	  else
	  line:SetText(string.format("Комплект: +%s " .. value[2] .. ".|r", match))
	end
      return
    end
  end
  
  for _, value in pairs(STAT_LINES_TO_SHORTEN_SET_Percent) do
    local match = strmatch(text, value[1])
    if match then
	local set = text:sub(19, 20)
	set = tonumber(set)
	if type(set) == "number" then
	if set < 5 then
      line:SetText(string.format("Комплект (".. set .." предмета): +%s%% " .. value[2] .. ".|r", match))
	  else
	  line:SetText(string.format("Комплект (".. set .." предметов): +%s%% " .. value[2] .. ".|r", match))
	  end
	  else
	  line:SetText(string.format("Комплект: +%s%% " .. value[2] .. ".|r", match))
	end
      return
    end
  end
  end
  
  for _, value in pairs(STAT_LINES_TO_SHORTEN_SET) do
    local match = strmatch(text, value[1])
    if match then
	local set = text:sub(1, 3)
	if set ~= "Set" then
      line:SetText(string.format(set .. " Set: +%s " .. value[2] .. ".|r", match))
	  else
	  line:SetText(string.format("Set: +%s " .. value[2] .. ".|r", match))
	end
      return
    end
  end
  
  for _, value in pairs(STAT_LINES_TO_SHORTEN_SET_Percent) do
    local match = strmatch(text, value[1])
    if match then
	local set = text:sub(1, 3)
	if set ~= "Set" then
      line:SetText(string.format(set .. " Set: +%s%% " .. value[2] .. ".|r", match))
	  else
	  line:SetText(string.format("Set: +%s%% " .. value[2] .. ".|r", match))
	end
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
	local weapon_locale = "Weapon"
	local armor_locale = "Armor"
	if (GetLocale() == "ruRU") then
		weapon_locale = "Оружие"
		armor_locale = "Доспехи"
	end
    local shouldDisplay = itemType == weapon_locale or itemType == armor_locale
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
