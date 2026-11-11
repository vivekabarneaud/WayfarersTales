-- Wayfarer's Tales - Mascots (companion pets from the mascot codex): a bond with the
-- little creature that follows you, for every class. One bond per character and per
-- mascot. It grows with what you share: time, places discovered together, cuddles,
-- campfires, naps, the first rain. No requests, no food: just company.
-- Lines have a personality per kind of mascot (the rabbit first).

local _, KT = ...
local L, D = KT.L, KT.Data
local Ma = {}
KT.Mascot = Ma

---------------------------------------------------------------------------
-- Data
---------------------------------------------------------------------------

-- kind of mascot, from words in its name (EN / FR)
D.MASCOT_KINDS = {
  { "rabbit", { "lapin", "rabbit", "lièvre", "hare" } },
}
D.MASCOT_GAIN = {
  time     = { amount = 0.2, cap = 2 },   -- every 10 minutes together
  place    = { amount = 0.5, cap = 3 },   -- a new place discovered together
  cuddle   = { amount = 1,   cap = 3 },   -- /pet, /love... (every 15 minutes at most)
  campfire = { amount = 2,   cap = 2 },   -- sitting by a campfire together
  nap      = { amount = 1,   cap = 2 },   -- a nap together (/sleep)
  rain     = { amount = 1 },              -- the first rain together
}
D.MASCOT_IDLE_CD   = 600   -- an idle line at most every 10 minutes
D.MASCOT_CUDDLE_CD = 900
D.MASCOT_PLACE_CD  = 600   -- a line about a new place at most every 10 minutes
D.MASCOT_PLACE_MILESTONES = { [10] = true, [50] = true, [100] = true, [250] = true }

-- Lines: per kind, per moment. band: 1 low bond, 2 middle, 3 high (minBand/maxBand
-- limit a line); when: the usual Senses conditions.
local GRASS = { indoors = false, notBiomes = { city = true, desert = true, snow = true, undercity = true,
  forge = true, badlands = true, canyon = true, volcanic = true, wasteland = true, plague = true } }
local LINES = {
  rabbit = {
    idle = {
      { en = "{pet}'s nose twitches at full speed, investigating a smell you can't detect.",
        fr = "{pet} remue le nez à toute vitesse, en pleine enquête sur une odeur que vous ne sentez pas." },
      { en = "{pet} hops three times, stops dead, then looks at you as if nothing happened.",
        fr = "{pet} fait trois petits bonds, s'arrête net, puis vous regarde comme si de rien n'était." },
      { en = "{pet} stands up on its hind legs, ears straight up, alert to the slightest sound.",
        fr = "{pet} se dresse sur ses pattes arrière, les oreilles bien droites, à l'affût du moindre bruit." },
      { minBand = 3,
        en = "{pet} snuggles against your foot, as if it were the safest place in the world.",
        fr = "{pet} vient se blottir contre votre pied, comme si c'était l'endroit le plus sûr du monde." },
    },
    idleGrass = {
      { when = GRASS,
        en = "{pet} nibbles a blade of grass, looking very focused.",
        fr = "{pet} grignote un brin d'herbe, l'air très concentré." },
    },
    rain = {
      { en = "{pet} shakes its soaked ears and gives you a reproachful look.",
        fr = "{pet} secoue ses oreilles trempées et vous lance un regard plein de reproches." },
    },
    campfire = {
      { en = "{pet} curls up by the fire, and its eyelids slowly close.",
        fr = "{pet} s'installe près du feu, en boule, et ses paupières se ferment doucement." },
    },
    cuddle = {
      { maxBand = 2,
        en = "{pet} freezes under your hand... then relaxes, just a tiny bit.",
        fr = "{pet} se fige sous votre main... puis se détend, un tout petit peu." },
      { minBand = 3,
        en = "{pet} closes its eyes under your hand and lets out a tiny sigh of happiness.",
        fr = "{pet} ferme les yeux sous votre main et pousse un minuscule soupir de bonheur." },
    },
    newPlace = {
      { en = "{pet} discovers this new place by going round in circles, nose in the air.",
        fr = "{pet} découvre ce nouvel endroit en tournant en rond, le nez en l'air." },
    },
    nap = {
      { en = "{pet} curls up against you and falls asleep before you do.",
        fr = "{pet} se roule en boule tout contre vous et s'endort avant vous." },
    },
    danger = {
      { en = "At the slightest sound, {pet} thumps a foot and dashes to hide behind you.",
        fr = "Au moindre bruit, {pet} tape du pied par terre et file se cacher derrière vous." },
    },
  },
}
-- for any mascot (the bond growing)
local GENERIC = {
  tierUp = {
    { en = "Your bond with {pet} has grown: {tier}.", fr = "Votre lien avec {pet} a grandi : {tier}." },
  },
}

---------------------------------------------------------------------------
-- Records: one per character and per mascot (db.mascots)
---------------------------------------------------------------------------

local cur, curGUID -- the mascot that's out (its record) and its ID
local function CharKey() return (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?") end
local function Today() return date("%Y-%m-%d") end
local function DB()
  local db = KT.GetDB()
  db.mascots = db.mascots or {}
  return db.mascots
end

local function Kind(name)
  local n = (name or ""):lower()
  for _, k in ipairs(D.MASCOT_KINDS) do
    for _, w in ipairs(k[2]) do
      if n:find(w, 1, true) then return k[1] end
    end
  end
  return nil
end

function Ma.TierIndex(aff)
  local idx = 1
  for i, min in ipairs(D.TIERS) do if (aff or 0) >= min then idx = i end end
  return idx
end
function Ma.Band(rec)
  local b = 1
  for i, min in ipairs(D.BANDS) do if (rec.affection or 0) >= min then b = i end end
  return b
end
function Ma.TierName(idx) return L.MASCOT_TIERS[idx] or "?" end
function Ma.TierDesc(idx) return L.MASCOT_TIER_DESC[idx] or "" end
function Ma.Name(rec) return rec and (rec.customName or rec.name) or "?" end
function Ma.Current() return cur end
-- this character's mascots (for the tab: the others)
function Ma.Records()
  local out, prefix = {}, CharKey() .. ":"
  for key, rec in pairs(DB()) do
    if key:sub(1, #prefix) == prefix then out[#out + 1] = rec end
  end
  table.sort(out, function(a, b) return (a.affection or 0) > (b.affection or 0) end)
  return out
end

local function Info(guid)
  if not (C_PetJournal and C_PetJournal.GetPetInfoByPetID) then return nil end
  local ok, speciesID, customName, level, _, _, displayID, _, name, icon, petType, creatureID =
    pcall(C_PetJournal.GetPetInfoByPetID, guid)
  if not ok or not name then return nil end
  return { speciesID = speciesID, customName = (customName ~= "" and customName) or nil, level = level,
    displayID = displayID, name = name, icon = icon, petType = petType, creatureID = creatureID }
end

local function Record(guid, info)
  local key = CharKey() .. ":" .. guid
  local db = DB()
  local rec = db[key]
  if not rec then
    rec = { key = key, guid = guid, created = time(), affection = 0, bestTier = 1, cd = {},
      daily = { date = Today(), gains = {} }, memories = {}, firsts = {},
      stats = { minutes = 0, outings = 0, places = 0, cuddles = 0, campfires = 0, naps = 0 } }
    db[key] = rec
  end
  rec.name, rec.customName, rec.speciesID = info.name, info.customName, info.speciesID
  rec.displayID, rec.creatureID, rec.level = info.displayID, info.creatureID, info.level
  rec.kind = Kind(info.name)
  return rec
end

local function Ready(rec, key, seconds) return time() - (rec.cd[key] or 0) >= (seconds or 0) end
local function Mark(rec, key) rec.cd[key] = time() end

local function AddMemory(rec, key, vars)
  rec.memories[#rec.memories + 1] = { t = time(), key = key, vars = vars or {} }
end
local function FirstMemory(rec, key, vars)
  if rec.firsts[key] then return end
  rec.firsts[key] = true
  AddMemory(rec, key, vars)
end

function Ma.MemoryText(m, rec)
  local text = L.MASCOT_MEMORY[m.key] or m.key
  local vars = {}
  for k, v in pairs(m.vars or {}) do vars[k] = v end
  vars.pet = vars.pet or Ma.Name(rec)
  if vars.tierIndex then vars.tier = Ma.TierName(vars.tierIndex) end
  return (KT.G(text):gsub("{(%w+)}", function(k) return vars[k] and tostring(vars[k]) or ("{" .. k .. "}") end))
end

---------------------------------------------------------------------------
-- Lines and the bond
---------------------------------------------------------------------------

local function Say(event, vars, important)
  if not cur or not KT.ModuleOn("mascot") then return false end
  local db = KT.GetDB()
  if not important and (db.settings.chatty or 2) == 0 then return false end
  local list = (cur.kind and LINES[cur.kind] and LINES[cur.kind][event]) or GENERIC[event]
  if not list then return false end
  local band = Ma.Band(cur)
  local ctx
  local fits = {}
  for _, line in ipairs(list) do
    if band >= (line.minBand or 1) and band <= (line.maxBand or 3) then
      local ok = true
      if line.when and KT.Senses and KT.Senses.Check then
        if not ctx then
          local okC, c = pcall(KT.Senses.Context)
          ctx = okC and c or {}
        end
        ok = KT.Senses.Check(line.when, ctx)
      end
      if ok then fits[#fits + 1] = line end
    end
  end
  if #fits == 0 then return false end
  local line = fits[math.random(#fits)]
  local fr = KT.CurrentLanguage and KT.CurrentLanguage() == "fr"
  vars = vars or {}
  vars.pet = Ma.Name(cur)
  KT.NarrateText("mascot", "mascot:" .. event, fr and line.fr or line.en, vars, important)
  return true
end

local function Gain(rec, src)
  local rule = D.MASCOT_GAIN[src] or {}
  local today = Today()
  if rec.daily.date ~= today then rec.daily = { date = today, gains = {} } end
  local room = rule.cap and (rule.cap - (rec.daily.gains[src] or 0)) or math.huge
  local amount = math.min(rule.amount or 0, room, 100 - rec.affection)
  if amount <= 0 then return 0 end
  rec.affection = rec.affection + amount
  rec.daily.gains[src] = (rec.daily.gains[src] or 0) + amount
  local idx = Ma.TierIndex(math.floor(rec.affection))
  if idx > (rec.bestTier or 1) then
    rec.bestTier = idx
    AddMemory(rec, "tier", { tierIndex = idx })
    Say("tierUp", { tier = Ma.TierName(idx) }, true)
  end
  if KT.RefreshPanel then KT.RefreshPanel() end
  return amount
end

---------------------------------------------------------------------------
-- What happens while your mascot is out
---------------------------------------------------------------------------

local lastPlaces, wasSeated, wasNapping, wasRain, minuteAcc, lastTick

local function PlaceCount()
  if not (KT.Discovery and KT.Discovery.Counts) then return nil end
  local ok, c = pcall(KT.Discovery.Counts)
  if not ok or not c then return nil end
  return (c.zones or 0) + (c.subzones or 0) + (c.spots or 0)
end

local function OnSummon(guid)
  local info = Info(guid)
  if not info then cur, curGUID = nil, nil return end
  cur, curGUID = Record(guid, info), guid
  cur.stats.outings = cur.stats.outings + 1
  cur.lastSeen = time()
  local zone = GetRealZoneText()
  FirstMemory(cur, "met", { zone = (zone and zone ~= "") and zone or "Azeroth" })
  lastPlaces = PlaceCount()
  wasSeated, wasNapping, wasRain = nil, nil, nil
  if KT.RefreshPanel then KT.RefreshPanel() end
end

local function Check()
  if not (C_PetJournal and C_PetJournal.GetSummonedPetGUID) then return end
  local ok, guid = pcall(C_PetJournal.GetSummonedPetGUID)
  guid = ok and guid or nil
  if guid ~= curGUID then
    if guid then OnSummon(guid) else cur, curGUID = nil, nil end
    if KT.RefreshPanel then KT.RefreshPanel() end
  end
end

local function Tick()
  Check()
  if not cur or not KT.ModuleOn("mascot") then return end
  local now = time()
  local dt = lastTick and math.min(now - lastTick, 30) or 0
  lastTick = now
  if UnitIsDeadOrGhost("player") or (UnitIsAFK and UnitIsAFK("player")) then return end

  -- time together: a minute at a time, a little bond every 10 minutes
  minuteAcc = (minuteAcc or 0) + dt
  while minuteAcc >= 60 do
    minuteAcc = minuteAcc - 60
    cur.stats.minutes = cur.stats.minutes + 1
    if cur.stats.minutes % 10 == 0 then Gain(cur, "time") end
  end
  cur.lastSeen = now

  local okE, env = pcall(KT.World.Snapshot)
  env = okE and env or {}

  -- a new place discovered together
  local places = PlaceCount()
  if places and lastPlaces and places > lastPlaces then
    cur.stats.places = cur.stats.places + (places - lastPlaces)
    Gain(cur, "place")
    if D.MASCOT_PLACE_MILESTONES[cur.stats.places] then AddMemory(cur, "places", { count = cur.stats.places }) end
    if Ready(cur, "place", D.MASCOT_PLACE_CD) and KT.LineGapOK() then
      if Say("newPlace") then Mark(cur, "place") end
    end
  end
  lastPlaces = places or lastPlaces

  -- sitting by a campfire together
  if env.seatedAtFire and not wasSeated then
    cur.stats.campfires = cur.stats.campfires + 1
    FirstMemory(cur, "firstCampfire")
    if Ready(cur, "campfire", 3000) then
      Mark(cur, "campfire")
      Gain(cur, "campfire")
      Say("campfire")
    end
  end
  wasSeated = env.seatedAtFire

  -- a nap together
  local napping = KT.Elements and KT.Elements.Napping and KT.Elements.Napping()
  if napping and not wasNapping then
    cur.stats.naps = cur.stats.naps + 1
    FirstMemory(cur, "firstNap")
    if Ready(cur, "nap", 3000) then
      Mark(cur, "nap")
      Gain(cur, "nap")
      Say("nap", nil, true)
    end
  end
  wasNapping = napping

  -- rain, outdoors
  local rain = env.rain and not env.indoors
  if rain and not wasRain then
    if not cur.firsts.firstRain then
      FirstMemory(cur, "firstRain")
      Gain(cur, "rain")
    end
    if Ready(cur, "rain", 1800) and KT.LineGapOK() then
      if Say("rain") then Mark(cur, "rain") end
    end
  end
  wasRain = rain

  -- now and then, a little something
  if not env.combat and Ready(cur, "idle", D.MASCOT_IDLE_CD) and KT.LineGapOK() and math.random() < 0.12 then
    local event = (not env.indoors and math.random() < 0.35) and "idleGrass" or "idle"
    if Say(event) or (event ~= "idle" and Say("idle")) then Mark(cur, "idle") end
  end
end

-- Cuddles: /pet, /love... aimed at your mascot (its name in the emote)
local function OnEmote(text, sender, guid)
  if not cur or not text or not (KT.IsMe and KT.IsMe(sender, guid)) then return end
  if not text:find(Ma.Name(cur), 1, true) then return end
  local lower = text:lower()
  local affection = false
  for _, w in ipairs(D.AFFECTION_WORDS) do
    if lower:find(w, 1, true) then affection = true break end
  end
  if not affection then return end
  cur.stats.cuddles = cur.stats.cuddles + 1
  FirstMemory(cur, "firstCuddle")
  if Ready(cur, "cuddle", D.MASCOT_CUDDLE_CD) then
    Mark(cur, "cuddle")
    Gain(cur, "cuddle")
    Say("cuddle", nil, true)
  end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "COMPANION_UPDATE", "PET_JOURNAL_LIST_UPDATE", "PLAYER_REGEN_DISABLED",
  "CHAT_MSG_TEXT_EMOTE" }) do
  pcall(f.RegisterEvent, f, ev)
end
f:SetScript("OnEvent", function(_, event, ...)
  local ok, err = pcall(function(...)
    if event == "PLAYER_LOGIN" then
      KT.GetDB().mascotProbe = nil -- (the first check's data, no longer needed)
      C_Timer.After(3, Check)
      C_Timer.NewTicker(5, function()
        local okT, errT = pcall(Tick)
        if not okT and KT.LogError then KT.LogError("Mascot tick", errT) end
      end)
    elseif event == "PLAYER_REGEN_DISABLED" then
      -- danger: your mascot reacts (not every fight)
      if cur and Ready(cur, "danger", 900) and math.random() < 0.5 then
        if Say("danger") then Mark(cur, "danger") end
      end
    elseif event == "CHAT_MSG_TEXT_EMOTE" then
      local text, sender = ...
      OnEmote(text, sender, (select(12, ...)))
    else
      C_Timer.After(0.5, Check)
    end
  end, ...)
  if not ok and KT.LogError then KT.LogError("Mascot " .. tostring(event), err) end
end)
