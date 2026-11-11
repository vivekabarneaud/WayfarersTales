-- Wayfarer's Tales - Moments: little lines when something happens to you
-- (a hard fight, a meal, gathering, a hearthstone, dawn, the bank...).
-- Part of the Senses module (same on/off switch, same rhythm option).
-- Lines and timers live in MomentsData.lua.

local _, KT = ...
local D, W = KT.Data, KT.World
local S = KT.Senses
local Mo = {}
KT.Moments = Mo



local function SpellName(id)
  if not (C_Spell and C_Spell.GetSpellName) then return nil end
  local ok, n = pcall(C_Spell.GetSpellName, id)
  return ok and n or nil
end

-- run a function, and save its error (if any) to the error log
local function Safe(fn, name)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then KT.LogError("Moments " .. name, err) end
  end
end

local function After(sec, fn, name) C_Timer.After(sec, Safe(fn, name or "timer")) end

---------------------------------------------------------------------------
-- Playing a moment
---------------------------------------------------------------------------

-- Rhythm: Rare makes every moment's cooldown longer, Often shorter. Moments tied to
-- something you just did play every time their cooldown allows; only very frequent
-- ones (gathering, recipes...) keep a chance below 1, so they don't fire every time.
local RHYTHM_CD = { [1] = 1.5, [2] = 1, [3] = 0.6 }

local ticking = false -- true while Tick runs (moments on a timer, not reactions)

-- Can moment `key` play now? (its own timer, the gap since the last line, its chance)
local function Ready(key)
  local state = S.State()
  if not state or not S.CanSpeak() then return nil end
  local rule = D.MOMENT_RULES[key]
  if not rule then return nil end
  state.moments = state.moments or {}
  local now = time()
  local cd = (rule.cd or 0) * (RHYTHM_CD[S.Rhythm()] or 1)
  if now - (state.moments[rule.shares or key] or 0) < cd then return nil end
  if now - (state.lastLine or 0) < (rule.gap or 60) then return nil end
  if ticking and not KT.LineGapOK() then return nil end -- timed moments wait after any line
  if (rule.chance or 1) < 1 and math.random() >= rule.chance then return nil end
  return rule, state
end

local function Commit(key, rule, state)
  state.moments[rule.shares or key] = time()
end

-- Pick one of the moment's lines that fits here and now (not the same as last time)
local function PickLine(key, state, ctx)
  local lines = D.MOMENTS[key]
  if not lines then return nil end
  local fits = {}
  for i, line in ipairs(lines) do
    if (not line.draft or S.Testing()) and S.Check(line.when, ctx) then fits[#fits + 1] = i end
  end
  state.momentLine = state.momentLine or {}
  local last = state.momentLine[key]
  if #fits > 1 and last then
    for j = #fits, 1, -1 do if fits[j] == last then table.remove(fits, j) end end
  end
  if #fits == 0 then return nil end
  local i = fits[math.random(#fits)]
  state.momentLine[key] = i
  return lines[i], i
end

-- extra = more facts for the conditions (e.g. the NPC you're dealing with)
function Mo.Play(key, vars, extra)
  local rule, state = Ready(key)
  if not rule then return false end
  local ctx = S.Context()
  for k, v in pairs(extra or {}) do ctx[k] = v end
  local line, i = PickLine(key, state, ctx)
  if not line then return false end
  Commit(key, rule, state)
  -- your gear, for lines that mention it ({cloak}, {boots}, {gloves})
  vars = vars or {}
  vars.cloak, vars.boots, vars.gloves = vars.cloak or ctx.cloak, vars.boots or ctx.boots, vars.gloves or ctx.gloves
  S.Show({ line = line, id = "moment:" .. key .. ":" .. i, src = "moment", kind = "moment" }, false, nil, vars)
  return true
end
local Play = Mo.Play

-- Standing still for a while: "You stop for a moment..." + a line about this place
-- (long lines favoured, like on a first visit).
local function Quiet()
  local ctx = S.Context()
  if ctx.eating or ctx.drinking or ctx.afk then return end
  local rule, state = Ready("quiet")
  if not rule then return end
  local list = {}
  for _, c in ipairs(S.Candidates(ctx, "ambient")) do
    c.kind = "quiet"
    list[#list + 1] = c
  end
  local c = S.PickFrom(list, ctx)
  if not c then return end
  local lead = PickLine("quiet", state, ctx)
  if not lead then return end
  Commit("quiet", rule, state)
  S.Show(c, false, nil, nil, S.LineText(lead))
end

-- Arrived with the hearthstone: the magic, then the place you land in
-- (most precise first: this spot, this sub-zone... then a generic line).
local function Hearth()
  local rule, state = Ready("hearth")
  if not rule then return end
  local ctx = S.Context()
  local lead, i = PickLine("hearth", state, ctx)
  local place = S.PickFrom(S.Candidates(ctx, "hearth"), ctx)
  if not lead and not place then return end
  Commit("hearth", rule, state)
  if place then
    S.Show(place, false, nil, nil, lead and S.LineText(lead))
  else
    S.Show({ line = lead, id = "moment:hearth:" .. i, src = "moment", kind = "moment" })
  end
end

---------------------------------------------------------------------------
-- What happens to you
---------------------------------------------------------------------------

local function HasDebuff(spellID)
  local name = SpellName(spellID)
  for i = 1, 40 do
    local ok, data = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HARMFUL")
    if not ok or not data then break end
    if data.spellId == spellID or (name and data.name == name) then return true end
  end
  return false
end

local function Revive()
  Play(HasDebuff(D.AURA_RES_SICKNESS) and "reviveSick" or "revive")
end

-- Fights: how long it lasted, and how much health you have left once it's over.
-- (During combat the game hides health numbers from addons - "secret values" -
-- so we only look once the fight is over. nil = can't tell.)
local fightStart
local function HealthPct()
  local ok, pct = pcall(function()
    local cur, max = UnitHealth("player"), UnitHealthMax("player")
    if issecretvalue and (issecretvalue(cur) or issecretvalue(max)) then return nil end
    if not cur or not max or max <= 0 then return nil end
    return cur / max
  end)
  return ok and pct or nil
end

local function FightEnded()
  if not fightStart then return end
  local duration = GetTime() - fightStart
  fightStart = nil
  After(2.5, function()
    if UnitIsDeadOrGhost("player") or UnitAffectingCombat("player") then return end
    local left = HealthPct()
    if left and left < D.CLOSE_FIGHT_HEALTH then
      Play("afterFightClose")
    elseif (left and left < D.HARD_FIGHT_HEALTH) or duration >= D.HARD_FIGHT_TIME then
      Play("afterFight")
    end
  end, "fight")
end

-- Falls: when you start falling, note your health; when you land, compare.
-- (Health is hidden from addons in combat: then nothing happens.)
local fallStart, fallHealth
local fallWatch = CreateFrame("Frame")
local fallAcc = 0
fallWatch:SetScript("OnUpdate", function(_, elapsed)
  fallAcc = fallAcc + elapsed
  if fallAcc < 0.1 then return end
  fallAcc = 0
  local ok, err = pcall(function()
    local falling = IsFalling and IsFalling() and true or false
    if falling and not fallStart then
      fallStart, fallHealth = GetTime(), HealthPct()
    elseif not falling and fallStart then
      local duration, before = GetTime() - fallStart, fallHealth
      fallStart, fallHealth = nil, nil
      if before and duration > 0.4 then
        After(0.4, function()
          if UnitIsDeadOrGhost("player") then return end
          local now = HealthPct()
          if not now then return end
          local lost = before - now
          if lost >= D.FALL_HARD then Play("fallHard")
          elseif lost >= D.FALL_MIN then Play("fall") end
        end, "fall")
      end
    end
  end)
  if not ok then fallStart, fallHealth = nil, nil end
end)

-- Eating and drinking

-- What kind of drink is it? (water, milk, juice... from words in its name)
local function DrinkKind(link)
  local name = link and link:match("%[(.-)%]")
  if not name then return nil end
  name = name:lower()
  for _, group in ipairs(D.DRINK_WORDS) do
    for _, word in ipairs(group[2]) do
      if name:find(word, 1, true) then return group[1] end
    end
  end
end

-- The item leaves the bags around the same moment as the buff shows up (Kindred
-- watches the bags): look a little later, and once more if it isn't known yet.
-- Your food diary: how many times this character has eaten / drunk each item.
-- Returns the new count.
local function CountMeal(itemID)
  local state = S.State()
  if not state or not itemID then return nil end
  state.diary = state.diary or {}
  local n = (state.diary[itemID] or 0) + 1
  state.diary[itemID] = n
  return n
end

-- A diary line if this food/drink is new, an old favourite or a milestone.
-- Returns true if a line was shown.
local function DiaryLine(drink, itemID, link, n)
  if not n then return false end
  local vars = { item = link, count = n }
  if n == 1 then
    local kind
    if drink then kind = DrinkKind(link) else kind = KT.FoodKind and KT.FoodKind(itemID, link) end
    local base = drink and "firstSip" or "firstTaste"
    local key = kind and D.MOMENTS[base .. "_" .. kind] and (base .. "_" .. kind) or base
    return Play(key, vars)
  end
  if D.MEAL_MILESTONES[n] then
    return Play(drink and "drinkMilestone" or "foodMilestone", vars)
  end
  if n >= D.MEAL_FAMILIAR and math.random() < D.MEAL_FAMILIAR_CHANCE then
    return Play(drink and "familiarDrink" or "familiarFood", vars)
  end
  return false
end

local function MealLine(drink, tries)
  local itemID, link = KT.LastFood and KT.LastFood(6)
  if not link and tries < 2 then
    After(1.5, function() MealLine(drink, tries + 1) end, "meal")
    return
  end
  if link and DiaryLine(drink, itemID, link, CountMeal(itemID)) then return end
  if not drink then
    if link then Play("eatItem", { item = link }) else Play("eat") end
    return
  end
  local kind = DrinkKind(link)
  if kind and D.MOMENTS["drink" .. kind] then
    Play("drink" .. kind, { item = link })
  elseif link then
    Play("drinkItem", { item = link })
  else
    Play("drink")
  end
end

local wasEating, wasDrinking, wasCampSit, wasCampBuff, campSitAt
local function CheckMeal()
  local eating = W.HasAura(D.SPELL_FOOD_AURA, true)
  local drinking = W.HasAura(D.SPELL_DRINK_AURA, true)
  if eating and not wasEating then
    After(1, function() MealLine(false, 1) end, "eat")
  elseif drinking and not wasDrinking and not eating then
    After(1, function() MealLine(true, 1) end, "drink")
  end
  wasEating, wasDrinking = eating, drinking

  -- campfires: sitting down by one (the 60 s "stay seated" buff), then its rested buff
  local campSit = W.HasAura(D.AURA_CAMP_WELCOME)
  if campSit and not wasCampSit then
    campSitAt = GetTime()
    After(1, function() Play("campSit") end, "camp")
  end
  local campBuff = W.HasAura(D.AURA_CAMP_BENEFITS)
  if campBuff and not wasCampBuff and campSitAt and GetTime() - campSitAt < 180 then
    After(1, function() Play("campRested") end, "camp")
  end
  wasCampSit, wasCampBuff = campSit, campBuff
end

-- Spells you cast: gathering and the hearthstone (found by name, for all ranks)
local SPELL_MOMENTS = { [2366] = "herb", [2575] = "mine", [8613] = "skin", [8690] = "hearth" }
local spellByName = {}
local hearthAt
local herbAt -- when you last gathered an herb (waiting for its loot message)
local fishingSince, fishEndAt -- your line is in the water since... / it just came out (for the catch)
local lastFishEnd, movedSinceFish -- for "settling in" lines: first cast in a while, or after moving
local fishingName -- "Fishing" in your language
local function IsFishing(spellID)
  fishingName = fishingName or SpellName(7620)
  if spellID == 7620 then return true end
  local n = spellID and SpellName(spellID)
  return n ~= nil and n == fishingName
end
local function OnSpell(spellID)
  local key = SPELL_MOMENTS[spellID]
  if not key then
    local name = SpellName(spellID)
    if not name then return end
    if not next(spellByName) or not spellByName._complete then
      local n = 0
      for id, k in pairs(SPELL_MOMENTS) do
        local sn = SpellName(id)
        if sn then spellByName[sn] = k; n = n + 1 end
      end
      spellByName._complete = (n == 4) or nil
    end
    key = spellByName[name]
  end
  if not key then return end
  if key == "hearth" then
    hearthAt = GetTime() -- the line comes once you've arrived
  elseif key == "herb" then
    -- wait for the loot message to know which herb it was (see OnLootMessage);
    -- if none comes, a general herb line
    local t = GetTime()
    herbAt = t
    After(D.HERB_LOOT_WAIT, function()
      if herbAt == t then herbAt = nil; Play("herb") end
    end, "gather")
  else
    After(1, function() Play(key) end, "gather")
  end
end

-- Professions and recipes, from the game's own system messages ("You have learned
-- a new spell: [Engineering]", "You have learned how to create a new item: ...").
-- The game's message formats are turned into patterns, so it works in any language.
-- Something that goes boom? (D.BOOM_WORDS in the item or recipe name)
local function IsBoom(text)
  local name = type(text) == "string" and (text:match("%[(.-)%]") or text):lower() or ""
  for _, w in ipairs(D.BOOM_WORDS or {}) do
    if name:find(w, 1, true) then return true end
  end
  return false
end

local function ToPattern(fmt)
  if type(fmt) ~= "string" then return nil end
  local p = fmt:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
  p = p:gsub("%%%%s", "(.+)")
  p = p:gsub("%%%%d", "%%d+")
  return "^" .. p .. "$"
end

-- Profession names in your language, from their spells (all ranks share the name).
-- Spell ID -> key of the profession's own lines in MomentsData.lua (learn_<key>, rank_<key>).
local PROFESSION_KEYS = {
  [2259] = "alchemy", [2018] = "blacksmithing", [7411] = "enchanting", [4036] = "engineering",
  [2366] = "herbalism", [2108] = "leatherworking", [2575] = "mining", [8613] = "skinning",
  [3908] = "tailoring", [2550] = "cooking", [3273] = "firstaid", [7620] = "fishing",
}
local professionNames -- lowercase name -> key
-- The profession's key if this name is a profession, else nil
local function ProfessionKey(name)
  if not professionNames then
    professionNames = { herbalism = "herbalism", herboristerie = "herbalism" }
    for id, key in pairs(PROFESSION_KEYS) do
      local n = SpellName(id)
      if n then professionNames[n:lower()] = key end
    end
  end
  return name and professionNames[name:lower()] or nil
end
local function IsProfession(name) return ProfessionKey(name) ~= nil end

-- Professions this character already had (so a new rank isn't taken for a new craft)
local function KnownProfessions(state)
  if state.professions then return state.professions end
  local found = {}
  local lines = GetNumSkillLines and GetSkillLineInfo and GetNumSkillLines() or 0
  for i = 1, lines do
    local ok, name = pcall(GetSkillLineInfo, i)
    if ok and name and IsProfession(name) then found[name:lower()] = true end
  end
  if lines > 0 then state.professions = found end -- skills not loaded yet: try again later
  return found
end

local professionAt = 0
local function OnSystemMessage(msg)
  if type(msg) ~= "string" then return end
  local state = S.State()
  if not state then return end

  local spell = ToPattern(ERR_LEARN_SPELL_S) and msg:match(ToPattern(ERR_LEARN_SPELL_S))
  if spell then
    local name = spell:match("%[(.-)%]") or spell
    local pkey = ProfessionKey(name)
    if not pkey then return end
    local known = KnownProfessions(state)
    local key = name:lower()
    professionAt = GetTime() -- the recipes that come with it don't get their own line
    -- the profession's own lines if it has some, else the general ones
    local general = known[key] and "craftRankUp" or "learnProfession"
    local own = (known[key] and "rank_" or "learn_") .. pkey
    known[key] = true
    Play(D.MOMENTS[own] and own or general, { skill = name })
    return
  end

  local recipe = ToPattern(ERR_LEARN_RECIPE_S) and msg:match(ToPattern(ERR_LEARN_RECIPE_S))
  if recipe and GetTime() - professionAt > 10 then
    Play(IsBoom(recipe) and "learnRecipe_boom" or "learnRecipe", { item = recipe })
  end
end

-- Loot and crafting, from the game's own loot messages ("You receive loot: ...",
-- "You receive item: ..." for quest rewards, "You create: ...").
local LOOT_FORMATS = { "LOOT_ITEM_SELF", "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE" }
local CREATE_FORMATS = { "LOOT_ITEM_CREATED_SELF", "LOOT_ITEM_CREATED_SELF_MULTIPLE" }
local patternCache = {}
local function MatchAny(msg, names)
  for _, n in ipairs(names) do
    local p = patternCache[n]
    if p == nil then p = ToPattern(_G[n]) or false; patternCache[n] = p end
    if p then
      local item = msg:match(p)
      if item then return item end
    end
  end
end

-- Item quality (3 = rare, 4 = epic, 5 = legendary) and ID, from a link
local QUALITY_COLORS = { ff0070dd = 3, ffa335ee = 4, ffff8000 = 5 }
local function Quality(link)
  local id = tonumber(link:match("item:(%d+)"))
  if id and C_Item and C_Item.GetItemQualityByID then
    local ok, q = pcall(C_Item.GetItemQualityByID, id)
    if ok and type(q) == "number" then return q, id end
  end
  local color = link:match("|c(%x%x%x%x%x%x%x%x)")
  return color and QUALITY_COLORS[color:lower()] or nil, id
end

local function OnLootMessage(msg)
  if type(msg) ~= "string" then return end
  local created = MatchAny(msg, CREATE_FORMATS)
  if created then
    local q, id = Quality(created)
    local state = S.State()
    local n
    if state and id then
      state.crafted = state.crafted or {}
      n = (state.crafted[id] or 0) + 1
      state.crafted[id] = n
    end
    if q and q >= 4 then Play("craftEpic", { item = created })
    elseif q == 3 then Play("craftRare", { item = created })
    elseif n == 1 then Play(IsBoom(created) and "craftFirst_boom" or "craftFirst", { item = created }) end
    return
  end
  local looted = MatchAny(msg, LOOT_FORMATS)
  if not looted then return end
  -- what you just pulled out of the water: a fish (the first of its kind?) or something else
  if fishEndAt and GetTime() - fishEndAt < 6 then
    fishEndAt = nil
    local id = tonumber(looted:match("item:(%d+)"))
    local isFish = id and KT.FoodKind and KT.FoodKind(id, looted) == "fish"
    local state = S.State()
    if isFish and state then
      state.fishCaught = state.fishCaught or {}
      local first = not state.fishCaught[id]
      state.fishCaught[id] = (state.fishCaught[id] or 0) + 1
      if first and Play("fishFirst", { item = looted }) then return end
      Play("fishCatch", { item = looted })
      return
    end
    local q = Quality(looted)
    if not q or q < 3 then Play("fishJunk", { item = looted }) return end
    -- a rare find from the water: the rare loot lines below
  end
  -- the herb you just gathered: its own lines if it has some
  if herbAt and GetTime() - herbAt < D.HERB_LOOT_WAIT then
    local herb = D.HERBS[tonumber(looted:match("item:(%d+)"))]
    if herb then
      herbAt = nil
      local key = D.MOMENTS["herb_" .. herb] and ("herb_" .. herb) or "herb"
      Play(key, { item = looted })
      return
    end
  end
  local q = Quality(looted)
  if not q or q < 3 then return end
  Play((q >= 5 and "lootLegendary") or (q == 4 and "lootEpic") or "lootRare", { item = looted })
end

-- A brand new character: where you open your eyes (race) and what you feel (class).
-- Only once per character, only at level 1 with no experience yet. Characters
-- that already existed are marked silently the first time.
local function Birth()
  local state = S.State()
  if not state or state.born then return end
  state.born = time()
  if (UnitLevel("player") or 0) > 1 or (UnitXP("player") or 0) > 0 then return end
  if not KT.ModuleOn("senses") then return end
  local _, race = UnitRace("player")
  local _, class = UnitClass("player")
  local r = D.BIRTH_RACE[race] or D.BIRTH_RACE.default
  local c = D.BIRTH_CLASS[class]
  local text = S.LineText(r) .. (c and (" " .. S.LineText(c)) or "")
  state.lastLine = time()
  KT.NarrateText("senses", "birth", text, nil, true)
end

-- after the intro cinematic, if there is one
local waitingBirth = false
local function CheckBirth()
  if InCinematic and InCinematic() then
    waitingBirth = true
  else
    After(3, Birth, "birth")
  end
end

---------------------------------------------------------------------------
-- Every few seconds: flights, dawn and dusk, stepping in and out, standing still
---------------------------------------------------------------------------

local stillSince, quietDone, taxiSince, lastNight, lastIndoors, wasDead

local function Tick()
  if not S.State() then return end
  local now = GetTime()

  -- back to life?
  local dead = UnitIsDeadOrGhost("player") and true or false
  if wasDead and not dead then
    lastIndoors, stillSince, quietDone = nil, nil, nil
    wasDead = false
    After(2, Revive, "revive")
    return
  end
  wasDead = dead
  if dead then stillSince = nil return end

  -- landing after a long flight
  local onTaxi = UnitOnTaxi and UnitOnTaxi("player") or false
  if onTaxi then
    taxiSince = taxiSince or now
  elseif taxiSince then
    local duration = now - taxiSince
    taxiSince = nil
    if duration >= D.LONG_FLIGHT then After(2, function() Play("landing") end, "landing") end
  end

  -- arrived with the hearthstone
  if hearthAt and now - hearthAt > 3 then
    if now - hearthAt < 120 then Hearth() end
    hearthAt = nil
  end

  -- dawn and dusk (outdoors, not in a dungeon)
  local night = W.IsNight()
  local indoors = IsIndoors and IsIndoors() or false
  if lastNight ~= nil and night ~= lastNight and not indoors and not IsInInstance() then
    Play(night and "dusk" or "dawn")
  end
  lastNight = night

  -- stepping in or out
  if lastIndoors ~= nil and indoors ~= lastIndoors and not onTaxi then
    Play(indoors and "goIn" or "goOut")
  end
  lastIndoors = indoors

  -- your hunter pet reacts to the rain now and then (the line checks the sky and the rain)
  if KT.ModuleOn("kindred") and UnitExists("pet") and not UnitIsDead("pet") and UnitCreatureFamily
    and UnitCreatureFamily("pet") and not onTaxi then
    local w = S.Weather()
    if w and w.confirmed and w.name == "rain" then Play("petRain", { pet = UnitName("pet") }) end
  end

  -- standing still for a while (not AFK, not fighting, not swimming)
  -- fishing: no "you stop to look around" (you're busy), a fishing line instead after a while
  if fishingSince and now - fishingSince > 12 then Play("fishWait") end
  if not fishingSince and S.Moving() then movedSinceFish = true end
  local busy = onTaxi or UnitAffectingCombat("player") or UnitIsAFK("player") or IsSwimming() or fishingSince
  if busy or S.Moving() then
    stillSince, quietDone = nil, nil
  else
    stillSince = stillSince or now
    if not quietDone and now - stillSince >= D.QUIET_AFTER then
      quietDone = true -- once per stop: move again to get another one
      Quiet()
    end
  end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local ERRANDS = { BANKFRAME_OPENED = "bank", MAIL_SHOW = "mail", AUCTION_HOUSE_SHOW = "auction", TRAINER_SHOW = "trainer" }

-- NPC log: every NPC you deal with is noted (id, name, sex, zone, and the race if the
-- game gives it), so we can later write lines for specific NPCs or their people.
-- Saved in db.npcs, listed in the report.
local NPC_EVENTS = { BANKFRAME_OPENED = "bank", MERCHANT_SHOW = "vendor", TRAINER_SHOW = "trainer",
  GOSSIP_SHOW = "talk", AUCTION_HOUSE_SHOW = "auction", TAXIMAP_OPENED = "flight" }

local function LogNPC(kind)
  local db = KT.GetDB()
  if not db then return end
  local ok, guid = pcall(UnitGUID, "npc")
  if not ok or type(guid) ~= "string" then return end
  local unitType, _, _, _, _, npcID = strsplit("-", guid)
  if unitType ~= "Creature" or not npcID then return end
  -- testers save it (for the report); for players it only serves the NPC lines
  local e = (db.npcs and db.npcs[npcID]) or { first = time() }
  local okN, name = pcall(UnitName, "npc")
  if okN and type(name) == "string" then e.name = name end
  local okS, sex = pcall(UnitSex, "npc")
  if okS and type(sex) == "number" then e.sex = sex end -- 2 = male, 3 = female
  local okR, race = pcall(UnitRace, "npc")
  if okR and type(race) == "string" then e.race = race end
  local okT, ctype = pcall(UnitCreatureType, "npc")
  if okT and type(ctype) == "string" then e.ctype = ctype end
  e.zone, e.sub = GetRealZoneText(), GetSubZoneText()
  e.kinds = e.kinds or {}
  e.kinds[kind] = true
  e.n, e.last = (e.n or 0) + 1, time()
  if KT.IsTester() then
    db.npcs = db.npcs or {}
    db.npcs[npcID] = e
  end
  return { id = tonumber(npcID), name = e.name, sex = e.sex }
end

-- A line about the NPC you're dealing with, if we know their race and role (D.NPCS).
-- Returns true if a line was shown.
local function NPCLine(info)
  local known = info and info.id and D.NPCS[info.id]
  local state = S.State()
  if not known or not state then return false end
  state.npcLine = state.npcLine or {}
  if time() - (state.npcLine[info.id] or 0) < D.NPC_LINE_CD then return false end
  if Play("npc", { npc = info.name }, { npcRace = known.race, npcRole = known.role, npcSex = info.sex, npcID = info.id }) then
    state.npcLine[info.id] = time()
    return true
  end
  return false
end

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "CHAT_MSG_SYSTEM", "CHAT_MSG_LOOT", "CINEMATIC_STOP",
  "BANKFRAME_OPENED", "MAIL_SHOW", "AUCTION_HOUSE_SHOW", "TRAINER_SHOW", "MERCHANT_SHOW", "GOSSIP_SHOW", "TAXIMAP_OPENED",
  "QUEST_ACCEPTED" }) do
  pcall(f.RegisterEvent, f, ev)
end
-- only about you (not every unit around)
for _, ev in ipairs({ "UNIT_AURA", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP" }) do
  if not (f.RegisterUnitEvent and pcall(f.RegisterUnitEvent, f, ev, "player")) then
    pcall(f.RegisterEvent, f, ev)
  end
end

f:SetScript("OnEvent", function(_, event, ...)
  local ok, err = pcall(function(...)
    local npcInfo
    if NPC_EVENTS[event] then
      local okL, info = pcall(LogNPC, NPC_EVENTS[event])
      if okL then npcInfo = info end
    end
    if event == "PLAYER_LOGIN" then
      C_Timer.NewTicker(5, Safe(function()
        ticking = true
        local ok, err = pcall(Tick)
        ticking = false
        if not ok then error(err, 0) end
      end, "tick"))
      After(3, CheckBirth, "birth") -- a brand new character?
      -- remember the professions you already have (skills may load a bit later)
      After(5, function() if S.State() then KnownProfessions(S.State()) end end, "professions")
      wasEating = W.HasAura(D.SPELL_FOOD_AURA, true)
      wasDrinking = W.HasAura(D.SPELL_DRINK_AURA, true)
    elseif event == "PLAYER_REGEN_DISABLED" then
      fightStart = GetTime()
    elseif event == "PLAYER_REGEN_ENABLED" then
      FightEnded()
    elseif event == "CINEMATIC_STOP" then
      if waitingBirth then
        waitingBirth = false
        After(2, Birth, "birth")
      end
    elseif event == "CHAT_MSG_LOOT" then
      local msg = ...
      After(0.5, function() OnLootMessage(msg) end, "loot") -- after the game's own message
    elseif event == "CHAT_MSG_SYSTEM" then
      local msg = ...
      After(0.5, function() OnSystemMessage(msg) end, "learn") -- after the game's own message
    elseif ERRANDS[event] then
      -- the NPC's own line if we know them, else the errand's line (bank, mail...)
      local key = ERRANDS[event]
      After(0.3, function()
        if NPCLine(npcInfo) then return end
        -- the mailbox only has something to say when there's mail waiting
        if key == "mail" and not (HasNewMail and HasNewMail()) then return end
        Play(key)
      end, "errand")
    elseif NPC_EVENTS[event] then
      After(0.3, function() NPCLine(npcInfo) end, "npc")
    elseif event == "QUEST_ACCEPTED" then
      -- (questLogIndex, questID) in some clients, (questID) in others
      local a, b = ...
      local id = b or a
      local key = id and ("questAccept_" .. tostring(id))
      if key and D.MOMENTS[key] then After(1, function() Play(key) end, "quest") end
    else
      local unit = ...
      if unit ~= "player" then return end
      if event == "UNIT_AURA" then
        CheckMeal()
      elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        if IsFishing(select(3, ...)) then
          fishingSince = GetTime()
          local fresh = not lastFishEnd or GetTime() - lastFishEnd > D.FISH_FRESH or movedSinceFish
          movedSinceFish = false
          After(1, function() Play("fishCast", nil, { fishFresh = fresh }) end, "fish")
        end
      elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        if fishingSince then fishingSince, fishEndAt, lastFishEnd = nil, GetTime(), GetTime() end
      elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        OnSpell(select(3, ...))
      end
    end
  end, ...)
  if not ok then KT.LogError("Moments " .. tostring(event), err) end
end)
