-- Wayfarer's Tales - core logic and the Kindred module (pet companionship).
-- Only watches the game: it never casts, feeds or clicks anything for you.

local ADDON, KT = ...
local L, M, D = KT.L, KT.Messages, KT.Data

local db        -- WayfarersTalesDB (SavedVariables)
local pet       -- record of the hunter pet currently out, or nil
local diet      -- set of food types the current pet eats (nil = unknown)

local lastEmote = { token = nil, t = 0 } -- last emote command typed
local manualAfkAt = 0                    -- when you last typed /afk yourself

local state = {
  feedPendingAt = nil,   -- GetTime() of the last successful Feed Pet cast
  lastFoodDrop  = nil,   -- { id, link, t } last food item that left the bags
  lastFishingAt = 0,
  meal          = nil,   -- active meal request { itemID, link, expires }
  petDead       = false,
  revivedAt     = nil,
  lastFlavorAt  = 0,
  killsThisFight = 0,
  petCommand    = nil,
  waitSince     = nil,
}

---------------------------------------------------------------------------
-- Small helpers
---------------------------------------------------------------------------

local MSG_COLOR = "|cffffd0a0"

local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage(L.PREFIX .. msg)
end

local function Debug(...)
  if db and db.settings.debug then
    local t = {}
    for i = 1, select("#", ...) do t[#t + 1] = tostring((select(i, ...))) end
    DEFAULT_CHAT_FRAME:AddMessage("|cff8888ff[KT debug]|r " .. table.concat(t, " "))
  end
end

local function After(sec, fn) C_Timer.After(sec, fn) end

-- Is this chat sender you? Best: the sender's unique ID (chat events give it),
-- which works whatever the name looks like (Forever has surnames: "Kitty Sweetpea").
-- Fallback: the first word of the name ("Ann" must not match "Annabelle").
function KT.IsMe(sender, guid)
  if guid and guid ~= "" then return guid == UnitGUID("player") end
  if not sender then return false end
  local first = tostring(sender):match("^([^%-%s]+)")
  return first ~= nil and first == UnitName("player")
end
local function Today() return date("%Y-%m-%d") end
local function InCombat() return UnitAffectingCombat("player") end
local function Pick(pool) return pool[math.random(#pool)] end

-- Random number 1..n that also mixes in the clocks: the game's dice can start at
-- the same place after each launch, which made login lines always the same.
local function Rand(n)
  return ((math.random(1, 1000000) + math.floor(GetTime() * 1000) + time()) % n) + 1
end

-- Pick a line, never the same one as last time for that pool (remembered across sessions).
local function PickLine(key, pool)
  local n = #pool
  if n <= 1 then return pool[1] end
  db.lastPick = db.lastPick or {}
  local idx = Rand(n)
  if idx == db.lastPick[key] then idx = (idx % n) + 1 end
  db.lastPick[key] = idx
  return pool[idx]
end

-- Your character's grammatical gender (for French): "m", "f" or "n" (neutral).
-- "auto" uses the character's sex in the game.
function KT.Gender()
  local g = db and db.settings.gender or "auto"
  if g == "auto" then return UnitSex("player") == 3 and "f" or "m" end
  return g
end

-- "{reposé|reposée|reposé·e}" -> the form that matches: masculine | feminine | neutral.
-- If a text only has two forms, the neutral option uses the masculine one.
function KT.G(text)
  return (text:gsub("{([^{}]*|[^{}]*)}", function(inner)
    local parts = {}
    for p in (inner .. "|"):gmatch("([^|]*)|") do parts[#parts + 1] = p end
    local g = KT.Gender()
    if g == "f" then return parts[2] or parts[1] end
    if g == "n" then return parts[3] or parts[1] end
    return parts[1]
  end))
end

-- The pet's nose in a line ({snout}): "museau" / "nose", or the family's own word
-- (a boar has a "groin" / "snout": D.SNOUT)
local function SnoutWord()
  local fr = KT.CurrentLanguage and KT.CurrentLanguage() == "fr"
  local w = pet and pet.family and D.SNOUT and D.SNOUT[pet.family]
  if w then return fr and w.fr or w.en end
  return fr and "museau" or "nose"
end

local function Fill(text, vars)
  text = KT.G(text)
  return (text:gsub("{(%w+)}", function(k)
    if k == "snout" and not vars.snout then return SnoutWord() end
    return vars[k] and tostring(vars[k]) or ("{" .. k .. "}")
  end))
end

local function FormatNumber(n)
  n = math.floor(n * 10 + 0.5) / 10
  if n == math.floor(n) then return tostring(math.floor(n)) end
  return string.format("%.1f", n)
end

local function FormatDuration(minutes)
  if minutes < 60 then return minutes .. "m" end
  return math.floor(minutes / 60) .. "h " .. (minutes % 60) .. "m"
end

local function SpellName(id)
  local ok, n = pcall(C_Spell.GetSpellName, id)
  return ok and n or nil
end

local function ItemClass(id)
  local fn = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
  if not fn or not id then return nil end
  local ok, _, _, _, _, _, classID, subclassID = pcall(fn, id)
  if ok then return classID, subclassID end
end

local function IsFoodItem(id)
  local c, s = ItemClass(id)
  return c == 0 and s == 5
end

local function IsDrink(id)
  if D.DRINKS[id] then return true end
  if C_Item and C_Item.GetItemSpell then
    local ok, name, spellID = pcall(C_Item.GetItemSpell, id)
    if ok and (spellID == D.SPELL_DRINK_AURA or (name and name == SpellName(D.SPELL_DRINK_AURA))) then return true end
  end
  return false
end

local function PetAlive()
  return pet and UnitExists("pet") and not UnitIsDead("pet")
end

---------------------------------------------------------------------------
-- Messages
---------------------------------------------------------------------------

local function Chance(base)
  return math.random() < base * (D.CHATTY_MULT[db.settings.chatty] or 1)
end

-- 1 = shy, 2 = friendly, 3 = devoted
local function Band()
  local b = 1
  for i, min in ipairs(D.BANDS) do
    if pet and pet.affection >= min then b = i end
  end
  return b
end

-- Mood of the day multiplier for a kind of reaction (1 = unchanged)
local function MoodMult(kind)
  local m = pet and pet.mood and D.MOOD_MULT[pet.mood.key]
  return (m and m[kind]) or 1
end

local function GainText(n)
  if not n or n == 0 then return "" end
  if n > 0 then return " |cffff8fb1(+" .. FormatNumber(n) .. ")|r" end
  return " |cffb0b0b0(" .. FormatNumber(n) .. ")|r"
end

-- Pet lines look like game emotes: emote color (from your chat settings),
-- no label, shown in every chat tab that displays emotes.

local function EmoteColor()
  local info = ChatTypeInfo and ChatTypeInfo["EMOTE"]
  if info and info.r then
    return string.format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255)
  end
  return "|cffff8040"
end

local function EmoteFrames()
  local frames = {}
  local contains = ChatFrame_ContainsMessageGroup or (ChatFrameUtil and ChatFrameUtil.ContainsMessageGroup)
  if contains then
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
      local cf = _G["ChatFrame" .. i]
      if cf then
        local ok, has = pcall(contains, cf, "EMOTE")
        if ok and has then frames[#frames + 1] = cf end
      end
    end
  end
  if #frames == 0 then frames[1] = DEFAULT_CHAT_FRAME end
  return frames
end

local function PetLine(text)
  if db.settings.label then
    Print(text)
  else
    for _, cf in ipairs(EmoteFrames()) do cf:AddMessage(text) end
  end
end

-- Sounds: the pet's own creature sounds, or a chime for big moments.
local lastSoundAt = 0
local function PlaySoundKind(kind)
  if not kind or not db.settings.sound then return end
  -- chimes for big moments always play; animal sounds keep a small gap
  if kind:sub(1, 3) ~= "ui:" and GetTime() - lastSoundAt < D.SOUND_GAP then return end
  local id = D.CUSTOM_SOUNDS[kind]
  if not id then
    if kind:sub(1, 3) == "ui:" then
      id = D.UI_SOUNDS[kind:sub(4)]
    else
      local set = pet and pet.soundSet and D.SOUND_SETS[pet.soundSet]
      local list = set and set[kind]
      id = list and list[math.random(#list)]
    end
  end
  if not id then return end
  lastSoundAt = GetTime()
  local ok, willPlay = pcall(PlaySoundFile, id, "SFX")
  Debug("sound", kind, id, ok and willPlay and "played" or "FAILED")
end

-- Journal: every line shown is kept with where/when it happened, so players can
-- reread their story and flag lines that felt wrong (see the Journal tab).
local MAX_JOURNAL = 500
local lastShownAt = 0
-- Lines on a timer wait D.LINE_GAP seconds after any line (from any module),
-- so two of them never show up at the same moment.
function KT.LineGapOK() return time() - lastShownAt >= D.LINE_GAP end

local function AddJournal(module, key, text, delta)
  lastShownAt = time()
  local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local h, m = GetGameTime()
  local j = db.journal
  j[#j + 1] = {
    t = time(), module = module, key = key, text = text, delta = delta,
    mapID = mapID, zone = GetRealZoneText(), sub = GetSubZoneText(),
    indoors = IsIndoors and IsIndoors() or false, gametime = string.format("%02d:%02d", h or 0, m or 0),
    lang = KT.CurrentLanguage and KT.CurrentLanguage() or "en",
  }
  while #j > MAX_JOURNAL do table.remove(j, 1) end
  if KT.RefreshPanel then KT.RefreshPanel() end
  if KT.Homework then KT.Homework.Refresh() end
end

-- Flag the latest line as wrong or odd (/wt nope, or the Homework window), with an
-- optional comment. Returns the journal entry, or nil if there's none.
function KT.FlagLastLine(note)
  local last = db and db.journal[#db.journal]
  if not last then return nil end
  last.flagged = true
  if note and note ~= "" then last.flagNote = note end
  if KT.RefreshPanel then KT.RefreshPanel() end
  if KT.Homework then KT.Homework.Refresh() end
  return last
end

-- The latest line shown (for the Homework window)
function KT.LastLine()
  return db and db.journal[#db.journal]
end

function KT.ModuleOn(name)
  return db and db.modules and db.modules[name] ~= false
end

-- Modes: players (default) get no dev windows and nothing extra saved.
-- Testers (/wt tester): Homework window, flags, report, NPC / quest / error logs.
-- Dev (us): only when Dev.lua is there (the repo); release zips leave it out.
function KT.IsDev() return KT.DEV == true end
function KT.IsTester() return KT.DEV == true or (db and db.settings.tester) == true end
-- New lines not yet confirmed (drafts, rewrite proposals): they play for everyone while
-- D.DRAFTS_LIVE is on (the beta: players hear them and flag what feels wrong), else in dev only.
function KT.DraftsOn() return KT.DEV == true or D.DRAFTS_LIVE == true end

-- What testers save, erased when they go back to player mode
local TESTER_DATA = { "npcs", "questsDone", "errors", "fieldNotes", "proposals", "roofs", "weatherLog", "weatherApi" }
local function HasTesterData()
  for _, k in ipairs(TESTER_DATA) do
    if type(db[k]) == "table" and next(db[k]) then return true end
  end
  return false
end
local function EraseTesterData()
  for _, k in ipairs(TESTER_DATA) do db[k] = nil end
  for _, e in ipairs(db.journal or {}) do e.flagged, e.flagNote = nil, nil end
  db.settings.homework = nil
end

StaticPopupDialogs["WAYFARERSTALES_LEAVE_TESTER"] = {
  text = "%s", button1 = YES, button2 = NO,
  OnAccept = function()
    EraseTesterData()
    db.settings.tester = false
    if KT.Homework then KT.Homework.Toggle(false) end
    Print(L.CMD_TESTER_OFF)
    if KT.RefreshPanel then KT.RefreshPanel() end
  end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

-- Welcome, once per account (players who had the addon before see it once too):
-- it's a beta, feedback and ideas are welcome on Discord.
StaticPopupDialogs["WAYFARERSTALES_WELCOME"] = {
  text = "%s", button1 = OKAY,
  hasEditBox = true, editBoxWidth = 220,
  OnShow = function(self)
    local eb = self.editBox or self.EditBox or (self.GetName and _G[(self:GetName() or "") .. "EditBox"])
    if eb then eb:SetText(D.DISCORD); eb:HighlightText(); eb:SetFocus() end
  end,
  EditBoxOnTextChanged = function(self)
    if self:GetText() ~= D.DISCORD then self:SetText(D.DISCORD); self:HighlightText() end
  end,
  EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
  EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}
local function Welcome()
  if db.welcomed then return end
  db.welcomed = true
  StaticPopup_Show("WAYFARERSTALES_WELCOME", L.WELCOME)
end

local function ToggleTester()
  if KT.IsDev() then Print(L.CMD_TESTER_DEV) return end
  if not db.settings.tester then
    db.settings.tester = true
    Print(L.CMD_TESTER_ON)
  elseif HasTesterData() then
    StaticPopup_Show("WAYFARERSTALES_LEAVE_TESTER", L.TESTER_LEAVE_CONFIRM)
    return
  else
    db.settings.tester = false
    if KT.Homework then KT.Homework.Toggle(false) end
    Print(L.CMD_TESTER_OFF)
  end
  if KT.RefreshPanel then KT.RefreshPanel() end
end

-- important = shown even when chattiness is 0
-- Draft lines for message pools (More.lua: D.POOL_DRAFTS = { key = { { en, fr }, ... } }),
-- added to the pool in dev mode (S.Testing). Not for banded pools.
local function WithDrafts(key, pool)
  local drafts = D.POOL_DRAFTS and D.POOL_DRAFTS[key]
  if not drafts or not (KT.Senses and KT.Senses.Testing and KT.Senses.Testing()) then return pool end
  if pool and type(pool[1]) == "table" then return pool end
  local fr = KT.CurrentLanguage and KT.CurrentLanguage() == "fr"
  local out = {}
  for _, l in ipairs(pool or {}) do out[#out + 1] = l end
  for _, d in ipairs(drafts) do out[#out + 1] = fr and d.fr or d.en end
  return out
end

local function Say(poolKey, vars, delta, important)
  if not KT.ModuleOn("kindred") then return end
  if not important and db.settings.chatty == 0 then return end
  -- body-type version of the pool if there is one (birds, scaly, chitin)
  local key = (pet and pet.archetype and M[poolKey .. "_" .. pet.archetype]) and (poolKey .. "_" .. pet.archetype) or poolKey
  -- a demon only says what was written for it (never a hunter pet's line)
  if pet and pet.demon and key == poolKey then return end
  local pool = WithDrafts(key, M[key])
  if not pool then return end
  if type(pool[1]) == "table" then pool = pool[Band()] or pool[1] end -- banded pool
  vars = vars or {}
  vars.pet = vars.pet or (pet and pet.name) or "?"
  local color = db.settings.label and MSG_COLOR or EmoteColor()
  local text = Fill(PickLine(poolKey, pool), vars)
  AddJournal("kindred", poolKey, text, delta)
  -- item links and highlights end with |r: switch back to our color after them
  text = text:gsub("|r", "|r" .. color)
  local line = color .. text .. "|r" .. GainText(delta)
  -- small delay so the reaction shows up after the game's own message (emote, loot...)
  local sound = D.POOL_SOUND[poolKey]
  After(0.25, function()
    PetLine(line)
    PlaySoundKind(sound)
  end)
end

-- Random flavor message, rate limited globally so the chat never floods.
local function Flavor(poolKey, base, vars)
  if GetTime() - state.lastFlavorAt < D.FLAVOR_COOLDOWN then return false end
  if not Chance(base) then return false end
  state.lastFlavorAt = GetTime()
  Say(poolKey, vars)
  return true
end

---------------------------------------------------------------------------
-- Affection, cooldowns, daily caps, memories
---------------------------------------------------------------------------

local function TierIndex(score)
  local idx = 1
  for i, min in ipairs(D.TIERS) do if score >= min then idx = i end end
  return idx
end

local function Ready(key, seconds)
  local t = pet.cd[key]
  return not t or time() - t >= seconds
end

local function Mark(key) pet.cd[key] = time() end

local function DailyRoom(src, cap)
  if pet.daily.date ~= Today() then pet.daily = { date = Today(), gains = {}, total = 0 } end
  if not cap then return math.huge end
  return cap - (pet.daily.gains[src] or 0)
end

local function AddMemory(key, vars)
  vars = vars or {}
  pet.memories[#pet.memories + 1] = { t = time(), key = key, vars = vars }
end

local function FirstMemory(key, vars)
  if pet.firsts[key] then return end
  pet.firsts[key] = true
  AddMemory(key, vars)
end

local function IndexOf(list, value)
  for i, v in ipairs(list or {}) do if v == value then return i end end
end
local function KeyOf(map, value)
  for k, v in pairs(map or {}) do if v == value then return k end end
end

-- Memories store neutral keys (tier number, food type) so they show up in the
-- current language. Older memories saved a word: find which one it was.
local function MemoryText(m, rec)
  local vars = {}
  for k, v in pairs(m.vars or {}) do vars[k] = v end
  vars.pet = vars.pet or (rec or pet).name
  if not vars.tierIndex and vars.tier then
    vars.tierIndex = IndexOf(KT.EN.L.TIERS, vars.tier) or (KT.FR and IndexOf(KT.FR.L.TIERS, vars.tier))
  end
  if vars.tierIndex then
    local r = rec or pet
    vars.tier = (r and r.demon and L.DEMON_TIERS[vars.tierIndex]) or L.TIERS[vars.tierIndex]
  end
  if not vars.foodKind and vars.food then
    vars.foodKind = KeyOf(KT.EN.L.FOOD_KINDS, vars.food) or (KT.FR and KeyOf(KT.FR.L.FOOD_KINDS, vars.food))
  end
  if vars.foodKind then vars.food = L.FOOD_KINDS[vars.foodKind] end
  local key = m.key
  -- "1 jours": one day has its own text
  if key == "reunion" and tonumber(vars.days) == 1 then key = "reunionOne" end
  -- very old saves noted the first meeting without its place
  if key == "met" and (not vars.zone or tostring(vars.zone):find("^[%[{]")) then key = "metNoZone" end
  return Fill(L.MEMORY[key] or L.MEMORY[m.key] or m.key, vars)
end

local UpdateHeart -- forward

-- Bond stage names: a demon's respect has its own (Mépris... Loyauté troublante)
local function TierName(idx, rec)
  rec = rec or pet
  return (rec and rec.demon and L.DEMON_TIERS[idx]) or L.TIERS[idx]
end
local function TierDesc(idx, rec)
  rec = rec or pet
  return (rec and rec.demon and L.DEMON_TIER_DESC[idx]) or L.TIER_DESC[idx]
end

local function CheckTier()
  local idx = TierIndex(math.floor(pet.affection))
  if idx > pet.bestTier then
    pet.bestTier = idx
    Say("tierUp", { tier = TierName(idx) }, nil, true)
    AddMemory("tier", { tierIndex = idx })
  end
end

-- Returns the amount actually gained.
local function Gain(src, amount)
  if not pet or not KT.ModuleOn("kindred") then return 0 end
  -- a demon's respect only grows the demon's way (fights, Health Funnel, time...)
  if pet.demon and not D.DEMON_GAINS[src] then return 0 end
  local rule = D.GAIN[src] or {}
  amount = amount or rule.amount or 0
  local room = DailyRoom(src, rule.cap)
  if room <= 0 then Debug("daily cap reached for", src) return 0 end
  amount = math.min(amount, room, 100 - pet.affection)
  if amount <= 0 then return 0 end
  pet.affection = pet.affection + amount
  pet.daily.gains[src] = (pet.daily.gains[src] or 0) + amount
  pet.daily.total = (pet.daily.total or 0) + amount
  Debug("gain", src, amount, "->", pet.affection)
  CheckTier()
  UpdateHeart()
  return amount
end

-- Gentle losses: never below the floor of the best stage reached.
local function Lose(src, amount)
  if not pet then return 0 end
  local floor = D.TIERS[pet.bestTier]
  local before = pet.affection
  pet.affection = math.max(floor, pet.affection - amount)
  Debug("loss", src, before - pet.affection, "->", pet.affection)
  UpdateHeart()
  return pet.affection - before
end

---------------------------------------------------------------------------
-- Pet identity (permanent petNumber from the stable API)
---------------------------------------------------------------------------

local function CharKey()
  return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
end

local function GetActiveEntry()
  if not (C_StableInfo and C_StableInfo.GetActivePetList) then return nil end
  local ok, list = pcall(C_StableInfo.GetActivePetList)
  if not ok or type(list) ~= "table" then return nil end
  local name, family = UnitName("pet"), UnitCreatureFamily("pet")
  local best
  for _, e in ipairs(list) do
    if e.name == name and (not best or e.familyName == family) then best = e end
  end
  if not best and #list == 1 then best = list[1] end
  return best
end

local function ReadDiet(entry)
  if not (entry and entry.slotID and C_StableInfo.GetStablePetFoodTypes) then return nil end
  local ok, types = pcall(C_StableInfo.GetStablePetFoodTypes, entry.slotID)
  if not ok or type(types) ~= "table" or #types == 0 then return nil end
  local set = { count = #types }
  for _, name in ipairs(types) do
    local key = D.FOOD_TYPE_NAMES[name]
    if key then set[key] = true end
  end
  return set
end

-- Food type of an item: known list first, then words in its name.
local foodKindCache = {}
local function FoodKind(itemID, link)
  if not itemID then return nil end
  if D.FOOD[itemID] then return D.FOOD[itemID] end
  if foodKindCache[itemID] ~= nil then return foodKindCache[itemID] or nil end
  local name = link and link:match("%[(.-)%]")
  if not name and C_Item and C_Item.GetItemNameByID then
    local ok, n = pcall(C_Item.GetItemNameByID, itemID)
    if ok then name = n end
  end
  if not name then return nil end -- not loaded yet: try again next time
  name = name:lower()
  local found = false
  for _, group in ipairs(D.FOOD_WORDS) do
    for _, word in ipairs(group[2]) do
      if name:find(word, 1, true) then found = group[1] break end
    end
    if found then break end
  end
  foodKindCache[itemID] = found
  Debug("food type of", name, "->", found or "unknown")
  return found or nil
end

KT.FoodKind = FoodKind -- also used by Moments (first taste of a food)

local function PetCanEat(itemID, link)
  if not itemID then return false end
  if pet.foods[itemID] then return true end
  if not diet or diet.count >= 6 then return true end
  local kind = FoodKind(itemID, link)
  return kind and diet[kind] or false
end

local function NewRecord(key, entry, name, family)
  local loyalty = entry and entry.loyaltyLevel
  local start = loyalty and math.min(25, math.max(0, (loyalty - 1) * 5)) or 0
  return {
    key = key, petNumber = entry and entry.petNumber, name = name, family = family,
    created = time(), affection = start, bestTier = TierIndex(start),
    loyalty = loyalty, loyaltyName = entry and entry.loyaltyName, happiness = entry and entry.happinessLevel,
    cd = {}, daily = { date = Today(), gains = {}, total = 0 },
    stats = { kills = 0, minutes = 0, feeds = 0, emotes = 0, meals = 0, campfires = 0, deaths = 0 },
    foods = {}, memories = {}, firsts = {}, lastSeen = time(),
  }
end

local function CleanLoyaltyName(s)
  if type(s) ~= "string" then return s end
  return (s:gsub("^%b()%s*", ""))
end

-- Called every minute and when the pet appears: loyalty and happiness.
local function RefreshEntry(entry, silent)
  entry = entry or GetActiveEntry()
  if not entry or not pet then return end
  local lv = entry.loyaltyLevel
  if lv and pet.loyalty and lv > pet.loyalty and not silent then
    local name = CleanLoyaltyName(entry.loyaltyName) or tostring(lv)
    local got = Gain("loyalty")
    Say("loyaltyUp", { loyalty = name }, got, true)
    AddMemory("loyalty", { loyalty = name })
  end
  if lv then pet.loyalty = lv; pet.loyaltyName = entry.loyaltyName end

  local h = entry.happinessLevel
  if h and pet.happiness and h < pet.happiness and h == 1 and not silent and Ready("hungry", 1800) then
    Mark("hungry")
    Say("petHungry")
  end
  if h then pet.happiness = h end
end

local auraSets, auraBaseline = { player = {}, pet = {} }, { player = true, pet = true }
local ScanAuras -- defined further down

local function CurrentZone()
  local z = GetRealZoneText()
  if not z or z == "" then z = GetZoneText() end
  if not z or z == "" then return nil end
  return z
end

-- First visit of a zone together -> message + memory.
local function CheckZone()
  if not KT.ModuleOn("kindred") then return end
  if not pet or not UnitExists("pet") or UnitIsDead("pet") then return end
  -- flying over a zone isn't visiting it; we check again after landing
  if (UnitOnTaxi and UnitOnTaxi("player")) or (IsFlying and IsFlying()) then return end
  local zone = CurrentZone()
  if not zone then return end
  pet.zones = pet.zones or {}
  local silent = next(pet.zones) == nil -- pets from before this feature: start counting quietly
  if pet.zones[zone] then return end
  pet.zones[zone] = time()
  if silent then return end
  AddMemory("zone", { zone = zone })
  Say("newZone", { zone = zone }, nil, true)
end

local function GreetingPool()
  local h = tonumber(date("%H")) or 12
  if h >= 5 and h < 12 then return "greetMorning" end
  if h >= 12 and h < 18 then return "greetAfternoon" end
  if h >= 18 and h < 23 then return "greetEvening" end
  return "greetNight"
end

-- Secret favorite and disliked food types, picked once per pet from its diet.
local function EnsureTastes()
  if pet.tastes then return end
  local options = {}
  for _, k in ipairs(D.FOOD_KINDS) do
    if not diet or diet.count >= 6 or diet[k] then options[#options + 1] = k end
  end
  if #options == 0 then return end
  local fav = table.remove(options, math.random(#options))
  local dislike = #options >= 2 and options[math.random(#options)] or nil
  pet.tastes = { favorite = fav, dislike = dislike }
  Debug("tastes picked (secret!)", fav, dislike)
end

-- New mood every real day. Returns true when a new mood was just picked.
local function EnsureMood()
  if pet.mood and pet.mood.date == Today() then return false end
  pet.mood = { date = Today(), key = D.MOODS[math.random(#D.MOODS)] }
  return true
end

local function CheckMilestones()
  local days = math.floor((time() - (pet.created or time())) / 86400)
  local years = math.floor(days / 365)
  if years >= 1 and not pet.firsts["year" .. years] then
    pet.firsts["year" .. years] = true
    AddMemory("anniversary", { years = years })
    Say("anniversary", { years = years }, Gain("anniversary"), true)
    return
  end
  -- only celebrate the biggest milestone reached, once
  local newest
  for _, n in ipairs(D.DAY_MILESTONES) do
    if days >= n and not pet.firsts["days" .. n] then
      pet.firsts["days" .. n] = true
      newest = n
    end
  end
  if newest then
    AddMemory("days", { days = newest })
    Say("daysTogether", { days = newest }, nil, true)
  end
end

-- A warlock's demon: its type ("imp", "voidwalker"...) from the family the game gives
local function DemonType()
  if select(2, UnitClass("player")) ~= "WARLOCK" then return nil end
  local fam = UnitCreatureFamily("pet")
  return (fam and D.DEMON_FAMILY[fam]) or "demon"
end

local function OnPetAppear()
  local _, isHunterPet = HasPetUI()
  local demon = UnitExists("pet") and not isHunterPet and DemonType() or nil
  if not UnitExists("pet") or not (isHunterPet or demon) then
    pet, diet = nil, nil
    UpdateHeart()
    return
  end

  local name, family = UnitName("pet"), UnitCreatureFamily("pet")
  local entry = not demon and GetActiveEntry() or nil
  local key = (demon and (CharKey() .. ":demon:" .. demon))
    or (entry and entry.petNumber and (CharKey() .. ":" .. entry.petNumber))
    or (CharKey() .. ":name:" .. tostring(name) .. ":" .. tostring(family))
  local rec = db.pets[key]
  local wasSame = pet == rec and rec ~= nil
  local isNew = rec == nil

  if isNew then
    rec = NewRecord(key, entry, name, family)
    db.pets[key] = rec
  end
  pet = rec
  diet = ReadDiet(entry)
  state.petDead = UnitIsDead("pet") and true or false
  auraBaseline.pet = true
  auraSets.pet = {}
  ScanAuras("pet") -- baseline: buffs already on the pet don't count as new
  Debug("pet", name, "family", family, "body", D.FAMILY_TYPE[family or ""] or "furry",
    "key", key, "affection", pet.affection, "diet", diet and diet.count or "?")

  pet.family = family
  pet.archetype = D.FAMILY_TYPE[family or ""] -- nil = furry (default messages)
  pet.soundSet = D.FAMILY_SOUND[family or ""]  -- nil = no creature sounds known

  -- A demon: respect instead of affection, its own lines (pools "<key>_imp"...), no
  -- meals, moods or stable. A line when it's summoned, a mocking one if you just died.
  if demon then
    pet.demon, pet.archetype, pet.soundSet = true, demon, nil
    if isNew then AddMemory("met", { zone = CurrentZone() or "Azeroth" }) end
    if not wasSame then
      if state.playerDiedAt and time() - state.playerDiedAt < D.DEMON_DEATH_WINDOW then
        state.playerDiedAt = nil
        Say("summonDeath", nil, nil, true)
      elseif Ready("summonMsg", D.DEMON_SUMMON_CD) then
        Mark("summonMsg")
        Say("summon")
      end
    end
    local lvl = UnitLevel("pet")
    if lvl and lvl > 0 then pet.level = lvl end
    pet.lastSeen = time()
    UpdateHeart()
    return
  end
  local spoke = false

  if isNew then
    spoke = true
    AddMemory("met", { zone = CurrentZone() or "Azeroth" })
    if pet.affection > 0 then
      Say("newPetHistory", { tier = L.TIERS[pet.bestTier] }, nil, true)
    else
      Say("newPet", nil, nil, true)
    end
  elseif pet.name ~= name then
    spoke = true
    local old = pet.name
    pet.name = name
    Say("rename", { old = old }, nil, true)
    AddMemory("rename", { old = old })
  end

  if not isNew and not wasSame then
    spoke = true -- the branches below may stay quiet; reset if none applies
    if pet.stabledAt then
      local days = ((pet.leftStableAt or time()) - pet.stabledAt) / 86400
      pet.stabledAt, pet.leftStableAt = nil, nil
      if days >= 1 / 24 then
        local delta = 0
        local weeks = math.floor(days / 7)
        if weeks > 0 then
          delta = Lose("stable", math.min(weeks * D.LOSS.stableWeek.amount, D.LOSS.stableWeek.max))
        end
        if days >= 1 and Ready("reunion", D.GAIN.reunion.cooldown) then
          Mark("reunion")
          delta = delta + Gain("reunion")
          AddMemory("reunion", { days = math.floor(days) })
        end
        Say("stableReunion", nil, delta, true)
        if weeks > 0 then Say("stableMissed", nil, nil, true) end
      else
        spoke = false
      end
    elseif pet.lastSeen and time() - pet.lastSeen >= 86400 then
      local days = math.floor((time() - pet.lastSeen) / 86400)
      local got = 0
      if Ready("reunion", D.GAIN.reunion.cooldown) then
        Mark("reunion")
        got = Gain("reunion")
        AddMemory("reunion", { days = days })
      end
      Say("reunion", nil, got, true)
    else
      spoke = false
    end
  end

  -- Hello after logging in (unless something more important was just said)
  -- (not after a /reload, and at most once an hour for the same pet)
  if not state.greeted then
    state.greeted = true
    if not spoke and not wasSame and not state.reloaded and GetTime() - (state.loginAt or 0) < 600
      and time() - (pet.lastGreet or 0) > 3600 then
      pet.lastGreet = time()
      Say(GreetingPool(), nil, nil, true)
      spoke = true
    end
  end
  if not spoke and not isNew and not wasSame and Ready("summonMsg", 1800) and Flavor("summon", 0.35) then
    Mark("summonMsg")
  end

  EnsureTastes()
  if EnsureMood() and db.settings.chatty > 0 then
    Say("mood_" .. pet.mood.key)
  end
  if not wasSame then CheckMilestones() end

  local lvl = UnitLevel("pet")
  if lvl and lvl > 0 then pet.level = lvl end
  pet.lastSeen = time()
  RefreshEntry(entry, isNew)
  CheckZone()
  UpdateHeart()
end

local appearPending = false
local function QueuePetAppear()
  if appearPending then return end
  appearPending = true
  After(0.5, function()
    appearPending = false
    if not UnitExists("pet") then
      if pet then pet.lastSeen = time() end
      pet, diet = nil, nil
      state.meal = nil
      UpdateHeart()
    else
      OnPetAppear()
    end
  end)
end

-- At the stable master: remember which pets went into / came out of the stable.
local function ScanStable()
  if not C_StableInfo then return end
  local cKey = CharKey()
  local ok, stabled = pcall(C_StableInfo.GetStabledPetList)
  if ok and type(stabled) == "table" then
    for _, e in ipairs(stabled) do
      local rec = e.petNumber and db.pets[cKey .. ":" .. e.petNumber]
      if rec and not rec.stabledAt then
        rec.stabledAt = time()
        rec.leftStableAt = nil
        Debug("stabled", rec.name)
      end
    end
  end
  local ok2, active = pcall(C_StableInfo.GetActivePetList)
  if ok2 and type(active) == "table" then
    for _, e in ipairs(active) do
      local rec = e.petNumber and db.pets[cKey .. ":" .. e.petNumber]
      if rec and rec.stabledAt and not rec.leftStableAt then
        rec.leftStableAt = time()
        Debug("left stable", rec.name)
      end
    end
  end
end

---------------------------------------------------------------------------
-- Interactions
---------------------------------------------------------------------------

local function TryComfort()
  if state.revivedAt and time() - state.revivedAt <= D.COMFORT_WINDOW then
    state.revivedAt = nil
    local got = Gain("comfort")
    Say("comfort", nil, got)
    return true
  end
  return false
end

local function TryAttention()
  local a = state.attention
  if a and GetTime() <= a.expires then
    state.attention = nil
    Say("attentionAnswered", nil, Gain("attention"), true)
    return true
  end
  return false
end

-- Reaction to one of your emotes. kind comes from D.EMOTES (nil = unknown emote).
local function OnEmote(kind, targeted, token)
  -- cheering right after a pet level-up
  local c = state.celebrate
  if token and D.CELEBRATE[token] and c and GetTime() <= c.expires then
    state.celebrate = nil
    Say("celebrated", nil, Gain("celebrate"), true)
    return
  end
  if kind == "affection" then
    if not targeted then return end
    -- a demon doesn't want your cuddles (it grows more tolerant with respect): no gain
    if pet.demon then
      if Ready("demonPet", 60) then Mark("demonPet"); Say("affection", nil, nil, true) end
      return
    end
    pet.stats.emotes = pet.stats.emotes + 1
    FirstMemory("firstCuddle")
    if TryComfort() or TryAttention() then return end
    if Ready("emote", D.GAIN.emote.cooldown) then
      local got = Gain("emote")
      if got > 0 then Mark("emote") end
      Say("affection", nil, got)
    else
      Say("affection")
    end
  elseif kind == "playful" or kind == "chicken" or kind == "roar" or kind == "sad" then
    if not targeted and not Chance(0.5 * (kind == "sad" and 1 or MoodMult("playful"))) then return end
    -- a shy pet doesn't play along (and gives nothing back) yet
    local rule = kind == "sad" and "sad" or "play"
    local got = 0
    if Band() >= 2 and Ready(rule, D.GAIN[rule].cooldown) then
      got = Gain(rule)
      if got > 0 then Mark(rule) end
    end
    Say(kind, nil, got)
  elseif kind == "rude" then
    if not targeted then return end
    pet.stats.rude = (pet.stats.rude or 0) + 1
    state.rudeAt = time()
    local delta = 0
    if Ready("rude", D.LOSS.rude.cooldown) then
      Mark("rude")
      delta = Lose("rude", D.LOSS.rude.amount)
    end
    Say("rude", nil, delta, true)
  elseif kind == "sorry" then
    if state.rudeAt and time() - state.rudeAt <= D.SORRY_WINDOW then
      state.rudeAt = nil
      Say("sorryForgive", nil, Gain("sorry"), true)
    elseif targeted then
      Say("sorryNothing")
    end
  elseif kind == "rest" or kind == "greet" or kind == "hungry" then
    if not targeted and not Chance(0.5) then return end
    Say(kind)
  elseif targeted and Chance(0.5) then
    Say("otherEmote")
  end
end

-- Pet asks for cuddles now and then; answer with /pet in time for a bonus.
local function MaybeAskAttention()
  if state.attention or state.meal or InCombat() or db.settings.chatty == 0 then return false end
  if pet and pet.demon then return false end -- (a demon never asks for a cuddle)
  if not KT.LineGapOK() then return false end
  if not Ready("attention", D.ATTENTION_COOLDOWN) or not Chance(0.05 * MoodMult("attention")) then return false end
  Mark("attention")
  local a = { expires = GetTime() + D.ATTENTION_WINDOW }
  state.attention = a
  Say("attentionRequest")
  After(D.ATTENTION_WINDOW + 1, function()
    if state.attention == a then
      state.attention = nil
      if pet and Chance(0.5) then Say("attentionExpired") end
    end
  end)
  return true
end

-- A random item from your bags (a demon likes to taunt you with your things)
local function RandomBagItem()
  local links = {}
  local numSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
  local itemLink = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
  if not (numSlots and itemLink) then return nil end
  for bag = 0, 4 do
    local okN, n = pcall(numSlots, bag)
    for slot = 1, (okN and n or 0) do
      local okL, link = pcall(itemLink, bag, slot)
      if okL and link then links[#links + 1] = link end
    end
  end
  return #links > 0 and links[math.random(#links)] or nil
end

local function IdleMoment()
  if InCombat() or not Ready("idle", D.IDLE_COOLDOWN) then return end
  -- a demon: its own idle lines, and now and then (low respect) a taunt with your things
  if pet.demon then
    local item = Band() < 3 and math.random() < 0.3 and RandomBagItem()
    local pool = item and "taunt" or "idle"
    if Flavor(pool, 0.08, item and { item = item } or nil) then Mark("idle") end
    return
  end
  local pool = "idle"
  local hour = GetGameTime()
  if IsSwimming() then
    pool = "idleSwimming"
  elseif IsResting() and math.random() < 0.5 then
    pool = "idleResting"
  elseif not pet.archetype and IsPlayerMoving and IsPlayerMoving() and math.random() < 0.5 then
    pool = "idleWalking" -- lines about walking only while you walk
  elseif not pet.archetype and not IsIndoors() and not IsResting() and not (IsPlayerMoving and IsPlayerMoving())
    and math.random() < 0.3 then
    pool = "idleFind" -- something found outside: a stick, a pebble, a feather...
  elseif hour and (hour >= 21 or hour < 6) and not IsIndoors() and math.random() < 0.4 then
    pool = "idleNight" -- (one looks up at the stars: not indoors)
  elseif pet.mood and math.random() < 0.4 then
    pool = "idleMood_" .. pet.mood.key
  end
  if Flavor(pool, 0.08 * MoodMult("idle")) then
    Mark("idle")
    -- it brought you something: a thank-you (/thank) in the next minute makes it proud
    if pool == "idleFind" and (M.thanked or KT.DraftsOn()) then state.found = { expires = GetTime() + D.FOUND_WINDOW } end
  end
end

local function ResolveFeed(itemID, link)
  Debug("feed resolved: item", itemID or "unknown", "pet record", pet and pet.name or "NONE",
    "meal", state.meal and "yes" or "no", "feed cooldown ready", pet and Ready("feed", D.GAIN.feed.cooldown))
  if not pet then return end
  pet.stats.feeds = pet.stats.feeds + 1
  if itemID then pet.foods[itemID] = (pet.foods[itemID] or 0) + 1 end
  FirstMemory("firstFeed")
  local item = link or "food"

  local meal = state.meal
  if meal and GetTime() <= meal.expires then
    state.meal = nil
    pet.stats.meals = pet.stats.meals + 1
    FirstMemory("firstMeal")
    if itemID == meal.itemID then
      Say("mealShared", { item = item }, Gain("meal"), true)
    else
      Say("mealOther", { item = meal.link or "food" }, Gain("mealAlt"), true)
    end
    -- a shared meal can reveal the favorite too
    local k, t = FoodKind(itemID, link), pet.tastes
    if k and t and k == t.favorite and not t.favoriteKnown then
      t.favoriteKnown = true
      AddMemory("favorite", { foodKind = k })
      Say("favoriteRevealed", { food = L.FOOD_KINDS[k] }, nil, true)
    end
    return
  end

  if TryComfort() then return end

  -- secret favorite / disliked food type
  local kind = FoodKind(itemID, link)
  local tastes = pet.tastes or {}
  local isFavorite = kind and kind == tastes.favorite
  local isDisliked = kind and kind == tastes.dislike
  local vars = { item = item, food = kind and L.FOOD_KINDS[kind] }

  -- the food it noticed in your loot a moment ago?
  local treat = state.treat
  local isTreat = treat and GetTime() <= treat.expires and itemID == treat.itemID
  if isTreat then state.treat = nil end

  local got = 0
  if Ready("feed", D.GAIN.feed.cooldown) and not isDisliked then
    got = Gain(isFavorite and "favorite" or "feed")
    if got > 0 then Mark("feed") end
  end
  if isTreat then got = got + Gain("treat") end

  if isFavorite then
    if not tastes.favoriteKnown then
      tastes.favoriteKnown = true
      AddMemory("favorite", { foodKind = kind })
      Say("feedFavoriteFirst", vars, got, true)
    else
      Say("feedFavorite", vars, got)
    end
  elseif isDisliked then
    if not tastes.dislikeKnown then
      tastes.dislikeKnown = true
      AddMemory("dislike", { foodKind = kind })
      Say("feedDislikeFirst", vars, nil, true)
    else
      Say("feedDislike", vars)
    end
  elseif isTreat then
    Say("treatGiven", vars, got, true)
  else
    Say("feed", vars, got)
  end
end

-- Sure the pet won't touch this food? (its diet is known, the food type too, and it
-- has never eaten this item) - or it's the food it dislikes.
local function PetRefuses(itemID, link)
  if not itemID or pet.foods[itemID] then return false end
  local k = FoodKind(itemID, link)
  if not k then return false end
  if pet.tastes and k == pet.tastes.dislike then return true end
  return diet ~= nil and diet.count < 6 and not diet[k]
end

local function OnPlayerEat(itemID, link)
  if not PetAlive() or InCombat() or state.meal or pet.demon then return end -- (demons don't eat)
  if db.settings.chatty == 0 then return end
  -- food it won't eat: a sniff and a face, now and then
  if PetRefuses(itemID, link) then
    if Ready("mealSniff", D.MEAL_SNIFF_COOLDOWN) and Chance(0.5) then
      Mark("mealSniff")
      Say("mealSniff", { item = link })
    end
    return
  end
  if not Ready("mealRequest", D.MEAL_COOLDOWN) then return end
  if not PetCanEat(itemID, link) then Debug("pet probably doesn't eat", itemID) return end
  if not Chance(0.6 * MoodMult("meal")) then return end
  Mark("mealRequest")
  state.meal = { itemID = itemID, link = link, expires = GetTime() + D.MEAL_WINDOW }
  Say("mealRequest", { item = link })
  local thisMeal = state.meal
  After(D.MEAL_WINDOW + 1, function()
    if state.meal == thisMeal then
      state.meal = nil
      -- lying down only if you're not walking away
      local walking = KT.Senses and KT.Senses.Moving and KT.Senses.Moving()
      if pet and Chance(0.5) then Say(walking and "mealExpiredMoving" or "mealExpired") end
    end
  end)
end

-- Loot messages: only react to our own loot.
local selfLootPrefixes
local function IsSelfLoot(msg)
  if not selfLootPrefixes then
    selfLootPrefixes = {}
    for _, g in ipairs({ "LOOT_ITEM_SELF", "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF",
      "LOOT_ITEM_PUSHED_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF", "LOOT_ITEM_CREATED_SELF_MULTIPLE" }) do
      local fmt = _G[g]
      if type(fmt) == "string" then
        local prefix = fmt:match("^(.-)%%")
        if prefix and prefix ~= "" then selfLootPrefixes[#selfLootPrefixes + 1] = { prefix, g:find("CREATED") ~= nil } end
      end
    end
  end
  for _, p in ipairs(selfLootPrefixes) do
    if msg:sub(1, #p[1]) == p[1] then return true, p[2] end
  end
  return false
end

local function OnLoot(msg)
  if not PetAlive() or InCombat() then return end
  local mine, created = IsSelfLoot(msg)
  if not mine then return end
  local id = tonumber(msg:match("|Hitem:(%d+)"))
  local link = msg:match("(|c.-|h|r)")
  if not id or not link then return end
  local classID, sub = ItemClass(id)
  local isFood = classID == 0 and sub == 5 and not IsDrink(id)
  local isIngredient = classID == 7 and sub == 8

  if created then
    if isFood and Ready("cookReact", 300) and Flavor("cooking", 0.35, { item = link }) then Mark("cookReact") end
    return
  end
  if not Ready("lootReact", 240) then return end

  local mult = MoodMult("loot")
  local fishing = GetTime() - state.lastFishingAt < D.FISHING_WINDOW
  local tastes = pet.tastes or {}
  local kind = FoodKind(id, link)
  if kind and kind == tastes.dislike then return end -- not interested at all

  local pool, base
  if kind and kind == tastes.favorite and tastes.favoriteKnown then
    pool, base = "lootFavorite", 0.7 -- a known favorite gets noticed much more often
  elseif fishing and (isFood or isIngredient) and (not diet or diet.count >= 6 or diet.fish) then
    pool, base = "fishing", 0.45
  elseif (isFood or (isIngredient and kind)) and PetCanEat(id, link) then
    pool, base = "lootFood", 0.35
  end
  if not pool then return end

  -- edible right away (not a raw ingredient)? then the pet asks for it as a treat,
  -- and the line itself says so (no hint in chat, the guide explains it)
  local treat = isFood and not state.treat and not state.meal and not state.attention
  if treat then pool = (pool == "lootFavorite") and "treatAskFavorite" or "treatAsk" end
  if not Flavor(pool, base * mult, { item = link }) then return end
  Mark("lootReact")

  if treat then
    local t = { itemID = id, link = link, expires = GetTime() + D.TREAT_WINDOW }
    state.treat = t
    After(D.TREAT_WINDOW + 1, function()
      if state.treat == t then state.treat = nil end
    end)
  end
end

local function OnAuraGained(unit, spellID, name)
  if unit == "player" then
    if spellID == D.SPELL_FOOD_AURA or (name and name == SpellName(D.SPELL_FOOD_AURA)) then
      -- the food item leaves the bag around the same moment; look shortly after
      -- (a bit after the Senses eating line, so you sit down before your pet begs)
      After(1.3, function()
        local f = state.lastFoodDrop
        if f and GetTime() - f.t < 4 then OnPlayerEat(f.id, f.link) end
      end)
    elseif spellID == D.AURA_CAMP_WELCOME then
      -- you sat down at the fire (the 60-second "stay seated" buff): resting together
      state.seatedAt = GetTime()
      if PetAlive() and not InCombat() and Ready("campRest", D.GAIN.campfire.cooldown) then
        Mark("campRest")
        pet.stats.campfires = pet.stats.campfires + 1
        FirstMemory("firstCampfire")
        Say("campfireRest", nil, Gain("campfire"), true)
      end
    elseif spellID == D.AURA_CAMP_BENEFITS then
      -- the real camp buff: no bonus, just a happy pet ready to go. Only right after
      -- actually sitting at the fire (the buff can also come back in other ways).
      local justRested = state.seatedAt and GetTime() - state.seatedAt < 180
      if justRested and PetAlive() and not InCombat() and Ready("campEnergized", D.GAIN.campfire.cooldown) then
        Mark("campEnergized")
        Say("campfireEnergized")
      end
    end
    return
  end
  -- pet auras
  if not PetAlive() then return end
  if spellID == D.AURA_CAMP_NEAR then
    if Ready("campNear", 1800) and Flavor("campfireNear", 0.6) then Mark("campNear") end
  end
end

ScanAuras = function(unit)
  local set = {}
  if UnitExists(unit) then
    for i = 1, 40 do
      local ok, data = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, "HELPFUL")
      if not ok or not data then break end
      if data.spellId then set[data.spellId] = data.name or true end
    end
  end
  local old = auraSets[unit]
  auraSets[unit] = set
  if auraBaseline[unit] then auraBaseline[unit] = false return end
  for id, name in pairs(set) do
    if not old[id] then OnAuraGained(unit, id, type(name) == "string" and name or nil) end
  end
end

local function OnPetDied()
  pet.stats.deaths = pet.stats.deaths + 1
  state.meal = nil
  local delta = 0
  if Ready("death", D.LOSS.death.cooldown) then
    Mark("death")
    delta = Lose("death", D.LOSS.death.amount)
  end
  Say("death", nil, delta, true)
end

local function OnKill()
  pet.stats.kills = pet.stats.kills + 1
  state.killsThisFight = state.killsThisFight + 1
  Gain("kill")
  local k = pet.stats.kills
  if k == 10 or k == 100 or k == 500 or k == 1000 or k == 5000 then
    AddMemory("kills", { count = k })
  end
end

-- Pet commands: Stay -> Follow after a while gets a happy reaction.
local function ScanPetCommands()
  if not GetPetActionInfo or not pet then return end
  local active = {}
  for i = 1, 10 do
    local ok, name, _, isToken, isActive = pcall(GetPetActionInfo, i)
    if ok and name and isActive then active[#active + 1] = isToken and name or ("spell:" .. name) end
  end
  local cmd, mode
  for _, a in ipairs(active) do
    if a == "PET_ACTION_WAIT" or a == "PET_ACTION_FOLLOW" or a == "PET_ACTION_MOVE_TO" then cmd = a end
    if D.PET_MODES[a] then mode = D.PET_MODES[a] end
  end
  if mode and mode ~= state.petMode then
    -- no message for the first reading after summoning, only for real switches
    if state.petMode and PetAlive() and Ready("modeMsg", 120) and Flavor("mode" .. mode, 0.7) then
      Mark("modeMsg")
    end
    Debug("pet mode", mode)
    state.petMode = mode
  end
  if cmd and cmd ~= state.petCommand then
    Debug("pet command", cmd, "active:", table.concat(active, ", "))
    if cmd == "PET_ACTION_WAIT" then
      state.waitSince = GetTime()
    elseif cmd == "PET_ACTION_FOLLOW" and state.petCommand == "PET_ACTION_WAIT"
      and state.waitSince and GetTime() - state.waitSince >= 30 and PetAlive() then
      Flavor("followAfterStay", 0.6)
    end
    state.petCommand = cmd
  end
end

---------------------------------------------------------------------------
-- Bags: figure out which item was fed or eaten
---------------------------------------------------------------------------

local bagCounts, bagLinks, bagReady, bagPending = {}, {}, false, false

local function SnapshotBags()
  local counts, links = {}, {}
  for bag = 0, (NUM_BAG_SLOTS or 4) do
    for slot = 1, C_Container.GetContainerNumSlots(bag) or 0 do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info and info.itemID then
        counts[info.itemID] = (counts[info.itemID] or 0) + (info.stackCount or 1)
        links[info.itemID] = info.hyperlink
      end
    end
  end
  return counts, links
end

local function OnItemDecreased(id, link)
  Debug("item left the bags:", id, "feed pending", state.feedPendingAt and "yes" or "no")
  if state.feedPendingAt and GetTime() - state.feedPendingAt < 3 then
    local c = ItemClass(id)
    if c == 0 or c == 7 then
      state.feedPendingAt = nil
      ResolveFeed(id, link)
      return
    end
  end
  -- (a drink isn't a meal to share: eating and drinking together, the drink must not count)
  if IsFoodItem(id) and not IsDrink(id) then state.lastFoodDrop = { id = id, link = link, t = GetTime() } end
  if ItemClass(id) == 0 then state.lastConsumableDrop = { id = id, link = link, t = GetTime() } end
  if IsDrink(id) then state.lastDrinkDrop = { id = id, link = link, t = GetTime() } end
end

-- The food or drink that just left your bags (for the Senses eating line), or nil.
-- Only known while Kindred is on (it's the one watching the bags).
function KT.LastFood(maxAge)
  local f = state.lastFoodDrop
  if f and GetTime() - f.t <= (maxAge or 5) then return f.id, f.link end
end

-- The last consumable you used (alcohol: no Drink buff, Moments hears the "tipsy" message)
-- The last drink that left your bags (drink lines must not pick up the food you eat with it)
function KT.LastDrink(maxAge)
  local f = state.lastDrinkDrop
  if f and GetTime() - f.t <= (maxAge or 5) then return f.id, f.link end
end
function KT.LastConsumable(maxAge)
  local f = state.lastConsumableDrop
  if f and GetTime() - f.t <= (maxAge or 5) then return f.id, f.link end
end
KT.IsDrink = function(id) return IsDrink(id) end

local function DiffBags()
  bagPending = false
  local counts, links = SnapshotBags()
  if bagReady then
    for id, n in pairs(counts) do
      if n < (bagCounts[id] or 0) then OnItemDecreased(id, links[id]) end
    end
    for id in pairs(bagCounts) do
      if not counts[id] then OnItemDecreased(id, bagLinks[id]) end
    end
  end
  bagCounts, bagLinks = counts, links
end

---------------------------------------------------------------------------
-- The heart next to the happiness icon
---------------------------------------------------------------------------

local heart

local function ShowTooltip(self)
  if not pet then return end
  -- Just the essentials; everything else is in the window (click the heart).
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  local idx = TierIndex(math.floor(pet.affection))
  GameTooltip:AddLine(pet.name, 1, 0.56, 0.69)
  GameTooltip:AddLine(TierName(idx), 1, 0.82, 0)
  GameTooltip:AddLine(TierDesc(idx), 1, 1, 1, true)
  if pet.mood and pet.mood.date == Today() then
    GameTooltip:AddLine(string.format(L.TT_MOOD, L.MOODS[pet.mood.key] or pet.mood.key), 0.8, 0.8, 1)
  end
  -- a request waiting for an answer
  if state.meal and GetTime() <= state.meal.expires then
    GameTooltip:AddLine(string.format(L.TT_MEAL, pet.name), 0.4, 1, 0.4, true)
  end
  GameTooltip:AddLine(L.TT_HINT, 0.5, 0.5, 0.5)
  GameTooltip:Show()
end

-- A square icon in a thin golden frame (the game's tooltip border, tinted gold),
-- close to the look of the pet happiness icon. Returns the icon texture.
function KT.SquareIcon(frame, size)
  frame:SetSize(size, size)
  local bg = frame:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.8)
  local icon = frame:CreateTexture(nil, "ARTWORK")
  icon:SetPoint("TOPLEFT", 2, -2)
  icon:SetPoint("BOTTOMRIGHT", -2, 2)
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  local border = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
  border:SetPoint("TOPLEFT", -2, 2)
  border:SetPoint("BOTTOMRIGHT", 2, -2)
  border:SetFrameLevel(frame:GetFrameLevel() + 2)
  if border.SetBackdrop then
    border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 9 })
    border:SetBackdropBorderColor(1, 0.8, 0.25)
  end
  return icon
end

local function CreateHeart()
  if heart or not PetFrame then return end
  heart = CreateFrame("Frame", "WayfarersTalesHeart", PetFrame)
  if PetFrameHappiness then
    heart:SetPoint("LEFT", PetFrameHappiness, "RIGHT", 3, 0)
  else
    heart:SetPoint("LEFT", PetFrame, "RIGHT", -10, 0)
  end
  heart.icon = KT.SquareIcon(heart, 21)
  heart.icon:SetTexture(D.CUSTOM_ICON or "Interface\\Icons\\INV_ValentinesCandy")
  heart:EnableMouse(true)
  heart:SetScript("OnEnter", ShowTooltip)
  heart:SetScript("OnLeave", function() GameTooltip:Hide() end)
  heart:SetScript("OnMouseUp", function() if KT.TogglePanel then KT.TogglePanel("companion") end end)
  heart:Hide()
end

UpdateHeart = function()
  if KT.RefreshPanel then KT.RefreshPanel() end -- keep the window up to date
  if not heart then return end
  if not pet or db.settings.showHeart == false or not KT.ModuleOn("kindred") then heart:Hide() return end
  heart:Show()
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
local H = {}

function H.ADDON_LOADED(name)
  if name ~= ADDON then return end
  WayfarersTalesDB = WayfarersTalesDB or {}
  db = WayfarersTalesDB
  db.journal = db.journal or {}
  db.modules = db.modules or {}
  if db.modules.kindred == nil then db.modules.kindred = true end
  db.pets = db.pets or {}
  db.settings = db.settings or {}
  local s = db.settings
  -- every setting starts from its default (D.DEFAULTS in Data.lua)
  for key, value in pairs(D.DEFAULTS) do
    if s[key] == nil then s[key] = value end
  end
  -- settings and data from older versions, no longer used
  s.drops, s.showBody, s.bodyPos, s.bodyPos2, s.bodyPos3 = nil, nil, nil, nil, nil
  -- 0.32: the heart is now off by default; turn it off once for older saves too
  if not s.heartOffOnce then s.showHeart, s.heartOffOnce = false, true end
  -- 0.55: the new window drops these options: back to their defaults once
  if not s.panel055 then s.label, s.showHeart, s.sensesStyle, s.panel055 = false, false, "mixed", true end
  s.iconTry = nil -- (the icon picker is gone)
  db.probes = nil
  -- 0.54: modes. Saves that already hold tester data (our testers) start in tester mode.
  if s.tester == nil then s.tester = HasTesterData() end
  s.testDrafts = nil -- drafts now play in dev mode only
  if not KT.IsDev() then s.debug = nil; db.weatherLog, db.weatherApi = nil, nil end
  KT.ApplyLanguage()
  if not db.welcomed then
    db.welcomed = true
    After(5, function() Print(L.LOADED_FIRST) end)
  end
end

---------------------------------------------------------------------------
-- Weather recorder: writes to the saved file what C_Weather says, but only for
-- weather types not identified yet (see D.WEATHER_CONFIRMED in SensesData.lua),
-- so we can learn which numbers mean rain, snow or sandstorm.
---------------------------------------------------------------------------

local function Serialize(v, depth)
  if type(v) ~= "table" then return tostring(v) end
  if depth > 2 then return "{...}" end
  local t = {}
  for k, x in pairs(v) do t[#t + 1] = tostring(k) .. "=" .. Serialize(x, depth + 1) end
  return "{" .. table.concat(t, ", ") .. "}"
end

local function Pack(...) return { n = select("#", ...), ... } end

local lastWeather
local function RecordWeather(reason, extra)
  if not KT.IsDev() then return end -- weather log: dev only
  if not (C_Weather and C_Weather.GetCurrentWeather) then return end
  local r = Pack(pcall(C_Weather.GetCurrentWeather))
  local parts = {}
  if not r[1] then
    parts[1] = "ERROR " .. tostring(r[2])
  else
    for i = 2, r.n do parts[#parts + 1] = Serialize(r[i], 0) end
    if #parts == 0 then parts[1] = "(no value)" end
  end
  local value = table.concat(parts, ", ")
  if value == lastWeather and not extra then return end
  lastWeather = value
  -- only weather types we haven't identified yet are worth writing down
  local w = r[1] and r[2]
  if type(w) == "table" and D.WEATHER_TYPES and D.WEATHER_CONFIRMED
    and D.WEATHER_CONFIRMED[D.WEATHER_TYPES[w.type] or ""] then
    return
  end
  local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local h, m = GetGameTime()
  db.weatherLog = db.weatherLog or {}
  table.insert(db.weatherLog, string.format("%s [%s] %s%s | mapID=%s zone=%s sub=%s indoors=%s gametime=%02d:%02d",
    date("%Y-%m-%d %H:%M:%S"), reason, value, extra and (" event-args: " .. extra) or "",
    tostring(mapID), tostring(GetRealZoneText()), tostring(GetSubZoneText()),
    tostring(IsIndoors and IsIndoors()), h or 0, m or 0))
  while #db.weatherLog > 300 do table.remove(db.weatherLog, 1) end
  Debug("weather", value)
end

function KT.StartWeatherRecorder()
  if not C_Weather then return end
  local keys = {}
  for k in pairs(C_Weather) do keys[#keys + 1] = tostring(k) end
  table.sort(keys)
  db.weatherApi = keys
  -- event names are a guess: any that exists will be recorded with its values
  local wf = CreateFrame("Frame")
  for _, ev in ipairs({ "WEATHER_UPDATE", "WEATHER_CHANGED", "CURRENT_WEATHER_CHANGED",
    "WEATHER_STATE_CHANGED", "UPDATE_WEATHER", "ZONE_WEATHER_CHANGED", "WEATHER_TYPE_CHANGED" }) do
    if pcall(wf.RegisterEvent, wf, ev) then Debug("weather event registered:", ev) end
  end
  wf:SetScript("OnEvent", function(_, ev, ...)
    local args = {}
    for i = 1, select("#", ...) do args[#args + 1] = Serialize((select(i, ...)), 0) end
    pcall(RecordWeather, ev, table.concat(args, ", "))
  end)
  After(3, function() pcall(RecordWeather, "login") end)
  C_Timer.NewTicker(30, function() pcall(RecordWeather, "check") end)
end

function H.PLAYER_LOGIN()
  state.loginAt = GetTime()
  CreateHeart()
  if KT.CreateMinimapButton then KT.CreateMinimapButton() end
  if KT.IsDev() then KT.StartWeatherRecorder() end
  C_Timer.After(3, function() pcall(Welcome) end) -- once the loading screen is gone
  C_Timer.NewTicker(60, function()
    if not KT.ModuleOn("kindred") or not PetAlive() then return end
    pet.lastSeen = time()
    if UnitIsAFK("player") then return end
    pet.stats.minutes = pet.stats.minutes + 1
    if pet.stats.minutes % 10 == 0 then Gain("time") end
    RefreshEntry()
    if EnsureMood() and db.settings.chatty > 0 then Say("mood_" .. pet.mood.key) end -- new day while playing
    if not MaybeAskAttention() then IdleMoment() end
  end)

  -- See which emote command you used (/pet, /dance...), so the pet can react to
  -- the right thing in any language. Read-only hooks.
  local function OnEmoteCommand(token)
    if type(token) == "string" then
      lastEmote.token = token:upper()
      lastEmote.t = GetTime()
    end
  end
  if C_ChatInfo and C_ChatInfo.PerformEmote then hooksecurefunc(C_ChatInfo, "PerformEmote", OnEmoteCommand) end
  if DoEmote then hooksecurefunc("DoEmote", OnEmoteCommand) end

  -- Notice when you type /afk yourself, to tell it apart from auto-AFK.
  local function OnChatSend(_, chatType)
    if type(chatType) == "string" and chatType:upper() == "AFK" then manualAfkAt = GetTime() end
  end
  if C_ChatInfo and C_ChatInfo.SendChatMessage then hooksecurefunc(C_ChatInfo, "SendChatMessage", OnChatSend) end
  if SendChatMessage then hooksecurefunc("SendChatMessage", OnChatSend) end
end

-- Start fresh: remember what's in the bags and on you right now (no "changes" yet).
-- Also used when the pet module is turned back on mid-session.
local function Rebaseline()
  bagReady = false
  DiffBags()
  bagReady = true
  auraBaseline.player = true
  ScanAuras("player")
end

function H.PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
  if isReloadingUi then state.reloaded = true end -- a /reload isn't a new arrival
  if not KT.ModuleOn("kindred") then return end
  After(2, QueuePetAppear)
  After(3, Rebaseline)
end

function H.PLAYER_LOGOUT()
  if pet then pet.lastSeen = time() end
end

function H.UNIT_PET(unit)
  if unit == "player" then QueuePetAppear() end
end

function H.UNIT_HEALTH(unit)
  if unit ~= "pet" or not pet then return end
  local dead = UnitIsDead("pet") and true or false
  if dead and not state.petDead then OnPetDied() end
  state.petDead = dead
end

function H.UNIT_AURA(unit)
  if unit == "player" or (unit == "pet" and pet) then ScanAuras(unit) end
end

function H.UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
  if unit ~= "player" then return end
  -- a spell while an enemy is targeted: you're taking part in the fight
  if UnitExists("target") and UnitCanAttack("player", "target") then state.actedAt = GetTime() end
  -- Health Funnel: your life into your demon (respect grows, now and then a line)
  if pet and pet.demon and SpellName(spellID) and SpellName(spellID) == SpellName(D.SPELL_HEALTH_FUNNEL) then
    if Ready("funnel", D.DEMON_FUNNEL_CD) then
      Mark("funnel")
      Say("funnel", nil, Gain("funnel"))
    end
  end
  if spellID == D.SPELL_FEED_PET then
    Debug("Feed Pet cast succeeded, waiting for the food to leave the bags")
    state.feedPendingAt = GetTime()
    local t = state.feedPendingAt
    After(3, function()
      if state.feedPendingAt == t then
        state.feedPendingAt = nil
        ResolveFeed(nil, nil)
      end
    end)
  elseif spellID == D.SPELL_REVIVE_PET then
    state.revivedAt = time()
    After(1.5, function() if pet then Say("revive", nil, nil, true) end end)
  elseif D.SPELL_FISHING[spellID] then
    state.lastFishingAt = GetTime()
  end
end

function H.BAG_UPDATE()
  if bagPending then return end
  bagPending = true
  After(0.3, DiffBags)
end

function H.CHAT_MSG_TEXT_EMOTE(text, sender, ...)
  local guid = select(10, ...) -- 12th argument of chat events: the sender's ID
  if not PetAlive() or not text or not KT.IsMe(sender, guid) then return end
  local targeted = text:find(pet.name, 1, true) ~= nil
  local token = (GetTime() - lastEmote.t < 3) and lastEmote.token or nil
  lastEmote.token = nil
  local kind
  if token then
    kind = D.EMOTES[token]
  elseif targeted then
    -- couldn't see the command: fall back on words in the emote text
    local lower = text:lower()
    for _, w in ipairs(D.AFFECTION_WORDS) do
      if lower:find(w, 1, true) then kind = "affection" break end
    end
  else
    return
  end
  -- thanking your pet right after it brought you something (no need to target it)
  local found = state.found
  if token and D.THANK[token] and found and GetTime() <= found.expires then
    state.found = nil
    Say("thanked", nil, Gain("thanked"), true)
    return
  end
  if not targeted and not D.EMOTE_UNTARGETED[kind or ""] then return end
  Debug("emote", token or "?", kind or "other", targeted and "(at pet)" or "(not at pet)")
  OnEmote(kind, targeted, token)
end

function H.CHAT_MSG_LOOT(msg)
  if msg then OnLoot(msg) end
end

-- Your pet won a fight without you: the pet was fighting (its combat flag) and its
-- target died (or you got the kill's experience), while you didn't attack, shoot or
-- cast at an enemy since the fight began (you were mining, turning in a quest,
-- away...). Draft lines for now: only in dev mode until they're approved.
local function CheckSoloWin()
  if not (M.petSolo or KT.DraftsOn()) or not PetAlive() then return end
  local start = state.petFightAt
  if not start or state.meleeOn or state.shooting then return end
  if state.actedAt and state.actedAt >= start - 2 then return end
  if not Ready("petSolo", D.PET_SOLO_COOLDOWN) then return end
  Mark("petSolo")
  local afk = UnitIsAFK("player") and true or false
  local got = Gain("petSolo")
  FirstMemory("petSolo")
  After(1, function() if pet then Say(afk and "petSoloAfk" or "petSolo", nil, got) end end)
end

function H.CHAT_MSG_COMBAT_XP_GAIN()
  if PetAlive() then
    OnKill()
    CheckSoloWin()
  end
end

function H.UNIT_FLAGS(unit)
  if unit ~= "pet" or not pet then return end
  if UnitAffectingCombat("pet") then
    state.petFightAt = state.petFightAt or GetTime()
    -- watch the pet's target during the fight: grey enemies give no experience,
    -- so a dead target is how we know the pet won
    if not state.petWatch then
      state.petWatch = C_Timer.NewTicker(0.5, function()
        local ok, dead = pcall(function() return UnitExists("pettarget") and UnitIsDead("pettarget") and true or false end)
        if ok and dead == true then state.petKilledAt = GetTime() end
        local okC, fighting = pcall(UnitAffectingCombat, "pet")
        if not okC or not fighting then
          if state.petWatch then state.petWatch:Cancel(); state.petWatch = nil end
          if state.petKilledAt and GetTime() - state.petKilledAt < 5 then
            state.petKilledAt = nil
            local okW, err = pcall(CheckSoloWin)
            if not okW then KT.LogError("Kindred petSolo", err) end
          end
        end
      end)
    end
  elseif state.petFightAt then
    -- the kill's experience can arrive just after the fight: forget it a little later
    local t = state.petFightAt
    After(3, function()
      if state.petFightAt == t and not UnitAffectingCombat("pet") then state.petFightAt = nil end
    end)
  end
end
-- what you do in a fight (melee swings, auto shot)
function H.PLAYER_ENTER_COMBAT() state.meleeOn = true; state.actedAt = GetTime() end

-- Demons: your death (re-summoned soon after, it mocks you) and the attack order
function H.PLAYER_DEAD() state.playerDiedAt = time() end
function H.PET_ATTACK_START()
  if pet and pet.demon and PetAlive() and Ready("demonAttack", D.DEMON_ATTACK_CD) and Chance(0.5) then
    Mark("demonAttack")
    Say("attack")
  end
end
function H.PLAYER_LEAVE_COMBAT() state.meleeOn = false end
function H.START_AUTOREPEAT_SPELL() state.shooting = true; state.actedAt = GetTime() end
function H.STOP_AUTOREPEAT_SPELL() state.shooting = false; state.actedAt = GetTime() end

function H.PLAYER_REGEN_DISABLED()
  state.killsThisFight = 0
end

function H.PLAYER_REGEN_ENABLED()
  if PetAlive() and state.killsThisFight > 0 and Ready("killReact", 1200) and Flavor("kill", 0.06) then
    Mark("killReact")
  end
  state.killsThisFight = 0
end

function H.PLAYER_CONTROL_GAINED() -- e.g. landing after a flight path
  After(2, CheckZone)
end

function H.ZONE_CHANGED_NEW_AREA()
  After(1, CheckZone)
  After(3, function() pcall(RecordWeather, "zone") end)
  -- remember every zone visited (map ID + name): data for future climate features
  After(2, function()
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local zone = GetRealZoneText()
    if mapID and zone and zone ~= "" then
      db.zonesSeen = db.zonesSeen or {}
      db.zonesSeen[mapID] = zone
    end
  end)
end

function H.PLAYER_LEVEL_UP(level)
  if not PetAlive() then return end
  Say("playerLevel", { level = level }, Gain("level"), true)
  if level and level % 10 == 0 then AddMemory("playerLevel", { level = level }) end
end

function H.UNIT_LEVEL(unit)
  if unit ~= "pet" or not pet or not UnitExists("pet") then return end
  local lvl = UnitLevel("pet")
  if lvl and pet.level and lvl > pet.level then
    -- the level-up line itself invites the player to cheer
    Say("petLevel", { level = lvl }, nil, true)
    if lvl % 10 == 0 then AddMemory("petLevel", { level = lvl }) end
    local c = { expires = GetTime() + D.CELEBRATE_WINDOW }
    state.celebrate = c
    After(D.CELEBRATE_WINDOW + 1, function()
      if state.celebrate == c then state.celebrate = nil end
    end)
  end
  if lvl and lvl > 0 then pet.level = lvl end
end

-- Auto-AFK (idle character sits down) vs typing /afk yourself.
function H.PLAYER_FLAGS_CHANGED(unit)
  if unit ~= "player" then return end
  local afk = UnitIsAFK("player") and true or false
  if afk and not state.afk then
    state.afk, state.afkSince = true, GetTime()
    state.afkAuto = GetTime() - manualAfkAt > 3
    Debug("afk", state.afkAuto and "auto" or "manual")
    if state.afkAuto and PetAlive() and not InCombat() then Say("afkDoze") end
  elseif not afk and state.afk then
    state.afk = false
    if state.afkAuto and PetAlive() then
      Say((GetTime() - state.afkSince) >= 900 and "afkBackLong" or "afkBack")
    end
  end
end

function H.PET_BAR_UPDATE() ScanPetCommands() end
function H.PET_STABLE_UPDATE() ScanStable() end
function H.PET_STABLE_CLOSED() ScanStable() end

-- Events every module needs; all the others belong to the Kindred (pet) module.
local SHARED_EVENTS = { ADDON_LOADED = true, PLAYER_LOGIN = true, PLAYER_LOGOUT = true,
  ZONE_CHANGED_NEW_AREA = true, PLAYER_ENTERING_WORLD = true }

f:SetScript("OnEvent", function(_, event, ...)
  local h = H[event]
  if not h then return end
  if not SHARED_EVENTS[event] and not KT.ModuleOn("kindred") then return end
  local ok, err = pcall(h, ...)
  if not ok then KT.LogError("Kindred " .. event, err) end
end)

for event in pairs(H) do pcall(f.RegisterEvent, f, event) end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------

SLASH_WAYFARERSTALES1 = "/wt"
SLASH_WAYFARERSTALES2 = "/kt" -- old Kindred Tales command, still works
-- (not "/wayfarer": another addon, Wayfarer, already uses it)
SlashCmdList.WAYFARERSTALES = function(msg)
  local cmd, arg = (msg or ""):lower():match("^(%S*)%s*(.-)$")
  local testerCmds = { nope = true, devoirs = true, homework = true, toit = true, roof = true }
  local devCmds = { debug = true, resetvisits = true }
  if (testerCmds[cmd] and not KT.IsTester()) or (devCmds[cmd] and not KT.IsDev()) then
    Print(L.CMD_TESTER_ONLY)
    return
  end
  if cmd == "tester" then
    ToggleTester()
  elseif cmd == "nope" then
    -- flag the latest journal line as wrong/odd, with an optional comment (/wt nope too long)
    local note = (msg or ""):match("^%S*%s*(.-)%s*$")
    local last = KT.FlagLastLine(note)
    if not last then Print(L.CMD_NOPE_NONE) return end
    Print(string.format(L.CMD_NOPE, last.text or "?"))
    if KT.RefreshPanel then KT.RefreshPanel() end
  elseif cmd == "help" then
    for _, line in ipairs(L.CMD_HELP) do Print(line) end
    if KT.IsTester() then for _, line in ipairs(L.CMD_HELP_TESTER) do Print(line) end end
    if KT.IsDev() then for _, line in ipairs(L.CMD_HELP_DEV) do Print(line) end end
  elseif cmd == "memories" then
    if not pet then Print(L.CMD_NO_PET) return end
    if #pet.memories == 0 then Print(L.CMD_NO_MEMORY) return end
    for _, m in ipairs(pet.memories) do
      Print("|cff999999" .. date("%Y-%m-%d", m.t) .. "|r " .. MemoryText(m))
    end
  elseif cmd == "chatty" then
    local n = tonumber(arg)
    if n and n >= 0 and n <= 3 then
      db.settings.chatty = math.floor(n)
      Print(string.format(L.CMD_CHATTY, db.settings.chatty))
    else
      Print(L.CMD_HELP[4])
    end
  elseif cmd == "debug" then
    db.settings.debug = not db.settings.debug
    Print(string.format(L.CMD_DEBUG, db.settings.debug and "ON" or "OFF"))
    if db.settings.debug and pet then
      Debug("key", pet.key, "affection", pet.affection, "bestTier", pet.bestTier,
        "diet", diet and diet.count or "unknown", "chatty", db.settings.chatty)
    end
  elseif cmd == "sound" then
    -- plays each of your pet's sounds, 2 seconds apart, and says if it worked
    if not pet then Print(L.CMD_NO_PET) return end
    local set = pet.soundSet and D.SOUND_SETS[pet.soundSet]
    Print(string.format(L.CMD_SOUND_TEST, pet.family or "?", pet.soundSet or "-"))
    local queue = {}
    if set then
      for _, k in ipairs({ "happy", "excited", "hurt" }) do
        if set[k] then queue[#queue + 1] = { k, set[k][1] } end
      end
    end
    queue[#queue + 1] = { "chime", D.UI_SOUNDS.big }
    for i, q in ipairs(queue) do
      After((i - 1) * 2, function()
        local ok, willPlay = pcall(PlaySoundFile, q[2], "SFX")
        Print(q[1] .. " (" .. q[2] .. "): " .. ((ok and willPlay) and "OK" or "|cffff4040not found|r"))
      end)
    end
  elseif cmd == "devoirs" or cmd == "homework" then
    if KT.Homework then KT.Homework.Toggle() end
  elseif cmd == "toit" or cmd == "roof" then
    -- this spot has a roof even though the game says "outdoors": no open-sky lines here
    local res = KT.Senses and KT.Senses.ToggleRoof() or "nopos"
    Print(L.CMD_ROOF[res] or res)
  elseif cmd == "resetvisits" then
    -- testing: forget the places visited, so first-visit lines play again
    local s = db.senses and db.senses[CharKey()]
    if s then
      s.visited = {}
      wipe(s.lineSeen or {}) -- line cooldowns too (wipe keeps the same table)
      wipe(s.recent or {})
    end
    Print(L.CMD_RESET_VISITS)
  elseif cmd == "guide" or cmd == "options" or cmd == "journal" then
    if KT.TogglePanel then KT.TogglePanel(cmd) end
  elseif cmd == "" and KT.TogglePanel then
    KT.TogglePanel()
  else -- "status" (or the window isn't available)
    if not pet then Print(L.CMD_NO_PET); Print(L.CMD_HELP[1]) return end
    local idx = TierIndex(math.floor(pet.affection))
    Print(string.format("|cffffd100%s|r (%s): %s - %d/100", pet.name, pet.family or "?", TierName(idx), math.floor(pet.affection)))
    Print(TierDesc(idx))
    if pet.mood and pet.mood.date == Today() then Print(string.format(L.TT_MOOD, L.MOODS[pet.mood.key] or "?")) end
    if pet.tastes then
      Print(string.format(L.TT_FAVORITE, pet.tastes.favoriteKnown and L.FOOD_KINDS[pet.tastes.favorite] or L.TT_SECRET))
    end
    local s = pet.stats
    Print(string.format(L.TT_TOGETHER, FormatDuration(s.minutes)) .. " - " .. string.format(L.TT_STATS, s.kills, s.meals, s.campfires))
    Print(L.CMD_STATUS_HINT)
  end
end

-- Language: English texts are the base, the chosen translation is laid on top.
-- L and M are changed in place, so every file sees the new texts right away.
function KT.CurrentLanguage()
  local s = db and db.settings.language or "auto"
  if s == "auto" then return GetLocale() == "frFR" and "fr" or "en" end
  return s
end

function KT.ApplyLanguage()
  for k in pairs(L) do L[k] = nil end
  for k, v in pairs(KT.EN.L) do L[k] = v end
  for k in pairs(M) do M[k] = nil end
  for k, v in pairs(KT.EN.M) do M[k] = v end
  local lang = KT.CurrentLanguage()
  local t = lang == "fr" and KT.FR
  if t then
    for k, v in pairs(t.L) do L[k] = v end
    for k, v in pairs(t.M) do M[k] = v end
  end
end

-- Shared tools for the other modules (Elements, Senses...)
-- Narrate: show a line from a message pool, like the pet's lines (emote style,
-- journal, never the same line twice in a row). important = shown even at chattiness 0.
-- NarrateText: same, with a ready-made text (Senses brings its own lines).
-- Both take their arguments in the same order: (module, what, vars, important).
function KT.NarrateText(module, key, text, vars, important)
  if not KT.ModuleOn(module) then return end
  if not important and db.settings.chatty == 0 then return end
  text = Fill(text, vars or {})
  text = text:gsub("^%l", string.upper) -- ("l'aubergiste Allison vous..." starts a line)
  AddJournal(module, key, text)
  local color = db.settings.label and MSG_COLOR or EmoteColor()
  text = text:gsub("|r", "|r" .. color)
  local line = color .. text .. "|r"
  After(0.25, function() PetLine(line) end)
end

function KT.Narrate(module, poolKey, vars, important)
  local pool = WithDrafts(poolKey, M[poolKey])
  if not pool then Debug("missing pool", poolKey) return end
  if not KT.ModuleOn(module) then return end
  KT.NarrateText(module, poolKey, PickLine(poolKey, pool), vars, important)
end
-- Errors: saved (once each) so they can be read later or sent in the report,
-- and mentioned once per session in the chat.
local errorsShown = false
function KT.LogError(where, err)
  if not db then return end
  local msg = tostring(where) .. ": " .. tostring(err)
  if not KT.IsTester() then -- players: one short message, nothing saved
    Debug("error:", msg)
    if not errorsShown then errorsShown = true; Print(L.ERROR_PLAYER) end
    return
  end
  db.errors = db.errors or {}
  for _, e in ipairs(db.errors) do
    if e.msg == msg then e.count = (e.count or 1) + 1; e.last = time(); return end
  end
  table.insert(db.errors, { msg = msg, first = time(), last = time(), count = 1,
    version = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(ADDON, "Version") or "?" })
  while #db.errors > 50 do table.remove(db.errors, 1) end
  Debug("error:", msg)
  if not errorsShown then
    errorsShown = true
    Print(string.format(L.ERROR, msg))
  end
end

-- A line from a message pool, as text (to combine it with another line)
function KT.PoolText(poolKey)
  local pool = WithDrafts(poolKey, M[poolKey])
  if not pool then return nil end
  return Fill(PickLine(poolKey, pool), {})
end

-- The pet senses danger too (level = "High", "Mid", "None" or "Near")
function KT.PetSenseDanger(level)
  if not KT.ModuleOn("kindred") or not PetAlive() then return end
  After(2.5, function()
    if PetAlive() then Say("petDanger" .. level, nil, nil, true) end
  end)
end

KT.GetDB = function() return db end
KT.Debug = function(...) Debug(...) end
KT.Chance = function(base) return Chance(base) end
KT.CharKey = function() return CharKey() end

-- What the window (UI.lua) is allowed to read and call.
KT.api = {
  GetPet = function() return pet end,
  GetDB = function() return db end,
  TierIndex = TierIndex, TierName = TierName, TierDesc = TierDesc,
  MemoryText = MemoryText,
  Today = Today,
  CharKey = CharKey,
  CleanLoyaltyName = CleanLoyaltyName,
  FormatDuration = FormatDuration,
  UpdateHeart = function() UpdateHeart() end,
  Print = Print,
  Rescan = function() Rebaseline(); QueuePetAppear() end, -- module turned back on
}
