-- Wayfarer's Tales - Senses module: small immersion lines about the world around you.
-- Lines live in SensesData.lua. This file decides WHEN to show one, and WHICH.

local _, KT = ...
local L, D = KT.L, KT.Data
local S = {}
KT.Senses = S

local state                 -- this character's saved data: visited places, recent lines
local lastWeatherName
local chatter = {}          -- times other people spoke / emoted near you

-- Rhythm: chance per minute to show an ambient line, and minimum gap between two.
local RHYTHM = {
  [1] = { chance = 0.06, gap = 900 },  -- rare
  [2] = { chance = 0.12, gap = 480 },  -- normal
  [3] = { chance = 0.25, gap = 240 },  -- chatty
}
local RECENT_MAX = 15

---------------------------------------------------------------------------
-- Context: weather, crowd, everything about here and now
---------------------------------------------------------------------------

function S.Weather()
  if not (C_Weather and C_Weather.GetCurrentWeather) then return nil end
  local ok, w = pcall(C_Weather.GetCurrentWeather)
  if not ok or type(w) ~= "table" then return nil end
  local name = D.WEATHER_TYPES[w.type]
  return { type = w.type, intensity = w.intensity, name = name,
    confirmed = name ~= nil and D.WEATHER_CONFIRMED[name] == true }
end

-- How many people around: nearby player name plates + people talking near you.
-- Returns "quiet" / "lively" / "crowded", or nil when we can't tell.
function S.Crowd()
  local now = GetTime()
  for i = #chatter, 1, -1 do
    if now - chatter[i] > 180 then table.remove(chatter, i) end
  end
  local players = 0
  local platesOn = GetCVar and GetCVar("nameplateShowFriends") == "1"
  if C_NamePlate and C_NamePlate.GetNamePlates then
    local ok, plates = pcall(C_NamePlate.GetNamePlates)
    if ok and plates then
      for _, plate in ipairs(plates) do
        local unit = plate.namePlateUnitToken
        if unit and UnitIsPlayer(unit) then players = players + 1 end
      end
    end
  end
  local talk = #chatter
  if players >= 8 or talk >= 6 then return "crowded", players, talk end
  if players >= 3 or talk >= 2 then return "lively", players, talk end
  -- "quiet" only if we can actually see the people around (friendly name plates on)
  if platesOn and players == 0 and talk == 0 then return "quiet", players, talk end
  return nil, players, talk
end

function S.Context()
  local ctx = KT.World.Snapshot()
  ctx.weather = S.Weather()
  ctx.crowd, ctx.players, ctx.chatter = S.Crowd()
  ctx.subLower = (ctx.sub or ""):lower()
  return ctx
end

---------------------------------------------------------------------------
-- Conditions: can this line play here and now? (and if not, why)
---------------------------------------------------------------------------

local function Check(when, ctx)
  if not when then return true end
  if when.night ~= nil and when.night ~= ctx.night then return false, when.night and "night" or "day" end
  if when.indoors ~= nil and when.indoors ~= ctx.indoors then return false, when.indoors and "indoors" or "outdoors" end
  if when.resting and not ctx.resting then return false, "resting" end
  if when.swimming and not ctx.swimming then return false, "swimming" end
  if when.airBelow and not ((ctx.air or 15) < when.airBelow) then return false, "airBelow" end
  if when.airAbove and not ((ctx.air or 15) > when.airAbove) then return false, "airAbove" end
  if when.notBiomes and when.notBiomes[ctx.biome] then return false, "biome" end
  if when.subMatch then
    local found = false
    for _, s in ipairs(when.subMatch) do
      if ctx.subLower:find(s, 1, true) then found = true break end
    end
    if not found then return false, "sub" end
  end
  if when.weather then
    if not D.WEATHER_CONFIRMED[when.weather] then return false, "weatherWait" end
    if not ctx.weather or ctx.weather.name ~= when.weather then return false, "weather" end
  end
  if when.crowd then
    if not ctx.crowd then return false, "crowdUnknown" end
    local ok = false
    if type(when.crowd) == "table" then
      for _, c in ipairs(when.crowd) do if c == ctx.crowd then ok = true end end
    else
      ok = when.crowd == ctx.crowd
    end
    if not ok then return false, "crowd" end
  end
  return true
end

---------------------------------------------------------------------------
-- Which lines exist for this place (most precise first)
---------------------------------------------------------------------------

local subIndex -- lowercase sub-zone name -> entry
local function FindSubzone(nameLower)
  if not subIndex then
    subIndex = {}
    for _, e in ipairs(D.SENSES.subzones or {}) do
      for _, n in ipairs(e.names) do subIndex[n] = e end
    end
  end
  return subIndex[nameLower]
end

-- Spots you're standing in right now (map coordinates + the spot's own conditions)
function S.SpotsHere(ctx)
  local out = {}
  if not ctx.x then return out end
  for _, sp in ipairs(D.SENSES.spots or {}) do
    if sp.map == ctx.rawMapID then
      local dx, dy = ctx.x - sp.x, ctx.y - sp.y
      if dx * dx + dy * dy <= sp.r * sp.r and Check(sp.when, ctx) then out[#out + 1] = sp end
    end
  end
  return out
end

function S.SpotName(sp)
  local n = sp.names or {}
  return (KT.CurrentLanguage() == "fr" and n.fr) or n.en or sp.id
end

function S.Candidates(ctx, kind)
  local list = {}
  local function add(src, lines, weight, prefix)
    if not lines then return end
    for i, line in ipairs(lines) do
      list[#list + 1] = { line = line, weight = weight, id = prefix .. ":" .. i, src = src, kind = kind, biome = ctx.biome }
    end
  end
  for _, sp in ipairs(S.SpotsHere(ctx)) do
    add("spot", sp[kind], 4, "spot:" .. sp.id .. ":" .. kind)
  end
  local sz = FindSubzone(ctx.subLower)
  if sz then add("subzone", sz[kind], 3, "sub:" .. sz.id .. ":" .. kind) end
  local z = ctx.mapID and D.SENSES.zones[ctx.mapID]
  if z then add("zone", z[kind], 2, "zone:" .. ctx.mapID .. ":" .. kind) end
  local b = D.SENSES.biomes[ctx.biome]
  if b then add("biome", b[kind], 1, "biome:" .. tostring(ctx.biome) .. ":" .. kind) end
  if kind == "ambient" then
    add("weather", D.SENSES.weather, 1.5, "weather")
    add("generic", D.SENSES.generic, 0.5, "generic")
  else
    add("generic", D.SENSES.genericArrive, 1, "genericArrive") -- e.g. walking into an inn
  end
  return list
end

-- Arrival lines for a new sub-zone only: that sub-zone's own + generic ones (inns...)
local function SubzoneArrivals(ctx)
  local list = {}
  local sz = FindSubzone(ctx.subLower)
  if sz and sz.arrive then
    for i, line in ipairs(sz.arrive) do
      list[#list + 1] = { line = line, weight = 3, id = "sub:" .. sz.id .. ":arrive:" .. i, src = "subzone", kind = "arrive" }
    end
  end
  for i, line in ipairs(D.SENSES.genericArrive or {}) do
    list[#list + 1] = { line = line, weight = 1, id = "genericArrive:" .. i, src = "generic", kind = "arrive" }
  end
  return list
end

local function IsRecent(id)
  for _, r in ipairs(state.recent) do if r == id then return true end end
  return false
end

local function Remember(id)
  table.insert(state.recent, id)
  while #state.recent > RECENT_MAX do table.remove(state.recent, 1) end
end

-- Seconds left before a line that already played can play again (nil = ready)
local function Cooldown(c)
  local t = state.lineSeen[c.id]
  if not t then return nil end
  local rest = (D.SENSES_COOLDOWN[c.src or "generic"] or 3600) - (time() - t)
  if rest > 0 then return rest end
  return nil
end

function S.LineText(line)
  if KT.CurrentLanguage() == "fr" and line.fr then return line.fr end
  return line.en
end

-- Long lines (two senses, a little scene): favoured for first visits, now and
-- then otherwise. The "style" option decides how often.
local function StyleFactor(c)
  if not c.line.long then return 1 end
  local style = KT.GetDB().settings.sensesStyle or "mixed"
  if style == "short" then return 0 end
  if c.kind == "arrive" then return style == "rich" and 6 or 4 end
  return style == "rich" and 1.5 or 0.35
end

-- Pick a fitting line, most specific first: this exact place, then this zone,
-- then the weather, then the landscape, then generic lines. The most precise level
-- that still has a line available wins; lines played recently are skipped, so once
-- a place's own lines have played, the next level takes over until they come back.
local TIER = { spot = 0, subzone = 1, zone = 2, weather = 3, biome = 4, generic = 5 }

function S.PickFrom(list, ctx)
  local pool, total, best = {}, 0, 99
  for _, c in ipairs(list) do
    local w = c.weight * StyleFactor(c)
    if w > 0 and Check(c.line.when, ctx) and not IsRecent(c.id) and not Cooldown(c) then
      local tier = TIER[c.src] or 5
      if tier < best then
        -- a more precise level has something: start over with only that level
        best, pool, total = tier, {}, 0
      end
      if tier == best then
        c.w = w
        pool[#pool + 1] = c
        total = total + w
      end
    end
  end
  if total <= 0 then return nil end
  local r = math.random() * total
  for _, c in ipairs(pool) do
    r = r - c.w
    if r <= 0 then return c end
  end
  return pool[#pool]
end

function S.Pick(ctx, kind)
  return S.PickFrom(S.Candidates(ctx, kind), ctx)
end

-- preview = from the dev panel's ">" button: shown, but not "consumed"
-- extra = a text added after the line (e.g. a danger feeling on a first visit)
function S.Show(c, preview, extra)
  if not c then return end
  if not preview then
    Remember(c.id)
    state.lineSeen[c.id] = time()
    state.lastLine = time()
  end
  local text = S.LineText(c.line)
  if extra then text = text .. " " .. extra end
  KT.NarrateText("senses", c.id, text, nil, true)
end

-- An arrival line, with the danger feeling added to it if this place is risky
local function ShowArrival(c, ctx)
  local level = S.DueDanger and S.DueDanger(ctx)
  S.Show(c, false, level and KT.PoolText("danger" .. level))
  if level then KT.PetSenseDanger(level) end
end

-- For the dev panel: little tags explaining where and when a line can play,
-- e.g. "[landscape: forest] [outdoors] [day]". Conditions are green when they are
-- met right here, right now, and red when they are not.
local NEUTRAL, GOOD, BAD = "|cff8a8a8a", "|cff5fd35f", "|cffe05050"

function S.Tags(c, ctx)
  ctx = ctx or S.Context()
  local T = L.SN_TAGS
  local tags = {}
  local function add(s, ok)
    local color = (ok == nil and NEUTRAL) or (ok and GOOD) or BAD
    tags[#tags + 1] = color .. "[" .. s .. "]|r"
  end
  -- where the line comes from (neutral: always true for lines listed here)
  if c.src == "spot" then add(T.spot)
  elseif c.src == "subzone" then add(T.subzone)
  elseif c.src == "zone" then add(T.zone)
  elseif c.src == "biome" then add(string.format(T.biome, L.SN_BIOMES[c.biome] or tostring(c.biome)))
  else add(T.generic) end
  if c.kind == "arrive" then add((L.SN_ARRIVE_TAG:gsub("[()]", ""))) end
  if c.line and c.line.long then add(T.long) end

  local w = c.line and c.line.when
  if w then
    if w.night ~= nil then add(w.night and T.night or T.day, w.night == ctx.night) end
    if w.indoors ~= nil then add(w.indoors and T.indoors or T.outdoors, w.indoors == ctx.indoors) end
    if w.resting then add(T.resting, ctx.resting) end
    if w.swimming then add(T.swimming, ctx.swimming) end
    if w.subMatch then
      local found = false
      for _, s in ipairs(w.subMatch) do
        if ctx.subLower:find(s, 1, true) then found = true end
      end
      add(string.format(T.place, table.concat(w.subMatch, "/")), found)
    end
    if w.weather then
      local ok = D.WEATHER_CONFIRMED[w.weather] and ctx.weather and ctx.weather.name == w.weather
      add(string.format(T.weather, L.SN_WEATHERS[w.weather] or w.weather), ok and true or false)
    end
    if w.crowd then
      local names, ok = {}, false
      for _, cr in ipairs(type(w.crowd) == "table" and w.crowd or { w.crowd }) do
        names[#names + 1] = L.SN_CROWDS[cr] or cr
        if cr == ctx.crowd then ok = true end
      end
      add(string.format(T.crowd, table.concat(names, "/")), ok)
    end
    local fmt = KT.Elements and KT.Elements.FormatAir or tostring
    if w.airBelow then add(string.format(T.airBelow, fmt(w.airBelow)), (ctx.air or 15) < w.airBelow) end
    if w.airAbove then add(string.format(T.airAbove, fmt(w.airAbove)), (ctx.air or 15) > w.airAbove) end
    if w.notBiomes then
      local names = {}
      for b in pairs(w.notBiomes) do names[#names + 1] = L.SN_BIOMES[b] or b end
      table.sort(names)
      add(string.format(T.notBiomes, table.concat(names, ", ")), not w.notBiomes[ctx.biome])
    end
  end
  return table.concat(tags, " ")
end

-- A line proposed by the player for the place they're in, saved with its context.
function S.Propose(text)
  local db = KT.GetDB()
  db.proposals = db.proposals or {}
  local ctx = S.Context()
  db.proposals[#db.proposals + 1] = {
    t = time(), text = text, zone = ctx.zone, sub = ctx.sub, mapID = ctx.mapID, biome = ctx.biome,
    indoors = ctx.indoors, night = ctx.night, weather = ctx.weather and ctx.weather.name,
    air = math.floor((ctx.air or 15) + 0.5), lang = KT.CurrentLanguage(),
    x = ctx.x and math.floor(ctx.x * 10 + 0.5) / 10, y = ctx.y and math.floor(ctx.y * 10 + 0.5) / 10,
    resting = ctx.resting,
  }
end

-- For the dev panel: every line for this place, playable or not, with the reason.
function S.LinesHere()
  local ctx = S.Context()
  local out = {}
  for _, kind in ipairs({ "arrive", "ambient" }) do
    for _, c in ipairs(S.Candidates(ctx, kind)) do
      local ok, reason = Check(c.line.when, ctx)
      if ok then
        local rest = Cooldown(c)
        if rest then ok, reason, c.remaining = false, "cooldown", rest end
      end
      c.ok, c.reason = ok, reason
      out[#out + 1] = c
    end
  end
  table.sort(out, function(a, b)
    if a.ok ~= b.ok then return a.ok end
    local ta, tb = TIER[a.src] or 5, TIER[b.src] or 5
    if ta ~= tb then return ta < tb end -- same order as the choice: most precise first
    return a.id < b.id
  end)
  return out, ctx
end

---------------------------------------------------------------------------
-- When lines play
---------------------------------------------------------------------------

local function Rhythm() return KT.GetDB().settings.sensesRhythm or 2 end

local function CanSpeak()
  if not state or not KT.ModuleOn("senses") or Rhythm() == 0 then return false end
  if UnitIsDeadOrGhost("player") or UnitAffectingCombat("player") then return false end
  if UnitOnTaxi and UnitOnTaxi("player") then return false end
  return true
end

-- Now and then, an ambient line
local function AmbientTick()
  if not CanSpeak() then return end
  local r = RHYTHM[Rhythm()]
  if not r or time() - (state.lastLine or 0) < r.gap then return end
  if math.random() >= r.chance then return end
  S.Show(S.Pick(S.Context(), "ambient"))
end

-- Flying over a place doesn't count as visiting it (the game doesn't explore
-- the map from a flight path either). We check again once you land.
function S.InFlight()
  return (UnitOnTaxi and UnitOnTaxi("player")) or (IsFlying and IsFlying()) or false
end

-- First time in a zone or sub-zone: an arrival line (if there is one)
local function CheckArrival()
  if not CanSpeak() or S.InFlight() then return end
  local ctx = S.Context()
  local subKey = ctx.subLower ~= "" and ("subname:" .. ctx.subLower) or nil

  -- a new zone: its arrival line (long ones favoured), and its sub-zone counts as visited
  if ctx.mapID and not state.visited[ctx.mapID] then
    state.visited[ctx.mapID] = time()
    if subKey then state.visited[subKey] = time() end
    local c = S.Pick(ctx, "arrive")
    if c then ShowArrival(c, ctx) end
    return
  end

  -- a spot you've never stood in (e.g. the inn at Sentinel Hill)
  for _, sp in ipairs(S.SpotsHere(ctx)) do
    local key = "spot:" .. sp.id
    if not state.visited[key] then
      state.visited[key] = time()
      if sp.arrive then
        local list = {}
        for i, line in ipairs(sp.arrive) do
          list[#list + 1] = { line = line, weight = 4, id = "spot:" .. sp.id .. ":arrive:" .. i, src = "spot", kind = "arrive" }
        end
        local c = S.PickFrom(list, ctx)
        if c then ShowArrival(c, ctx) return end
      end
    end
  end

  -- a new sub-zone (by name): only if it has lines of its own, or e.g. it's an inn
  if subKey and not state.visited[subKey] then
    state.visited[subKey] = time()
    local c = S.PickFrom(SubzoneArrivals(ctx), ctx)
    if c then ShowArrival(c, ctx) end
  end
end

-- Recommended levels of a zone: from the game if it knows, else the classic table.
function S.ZoneLevels(mapID)
  if not mapID then return nil end
  if C_Map and C_Map.GetMapLevels then
    local ok, minL, maxL = pcall(C_Map.GetMapLevels, mapID)
    if ok and minL and maxL and minL > 0 and maxL > 0 then return minL, maxL, "game" end
  end
  local r = D.ZONE_LEVELS[mapID]
  if r then return r[1], r[2], "classic" end
  return nil
end

-- Levels of the place you're in: a spot's or sub-zone's own levels if set,
-- else the zone's. Returns min, max, source, placeKey.
function S.LevelsHere(ctx)
  for _, sp in ipairs(S.SpotsHere(ctx)) do
    if sp.levels then return sp.levels[1], sp.levels[2], "spot", "spot:" .. sp.id end
  end
  local sl = ctx.subLower ~= "" and D.SUBZONE_LEVELS[ctx.subLower]
  if sl then return sl[1], sl[2], "subzone", "sub:" .. ctx.subLower end
  local minL, maxL, src = S.ZoneLevels(ctx.mapID)
  return minL, maxL, src, tostring(ctx.mapID)
end

-- Is there a danger feeling due here? Returns its level ("High"/"Mid"/"None")
-- and marks it as felt (it comes back after a while), or nil.
local function DueDanger(ctx)
  local minL, maxL, _, place = S.LevelsHere(ctx)
  if not minL then return nil end
  local lvl = UnitLevel("player") or 1
  local level, rest
  if lvl <= minL - 10 then level, rest = "High", 2 * 3600
  elseif lvl <= minL - 4 then level, rest = "Mid", 2 * 3600
  elseif lvl >= maxL + 5 then level, rest = "None", 24 * 3600
  end
  if not level then return nil end
  state.dangerSeen = state.dangerSeen or {}
  local key = place .. ":" .. level
  local t = state.dangerSeen[key]
  if t and time() - t < rest then return nil end
  state.dangerSeen[key] = time()
  return level
end
S.DueDanger = DueDanger

-- Danger feeling on its own (not on a first visit): a touch of the landscape + the feeling.
local function CheckDanger()
  if not CanSpeak() or S.InFlight() then return end
  local ctx = S.Context()
  local level = DueDanger(ctx)
  if not level then return end
  local parts = {}
  local flavor = (level ~= "None") and D.DANGER_FLAVOR[ctx.biome]
  if flavor then parts[#parts + 1] = KT.PoolText("dangerFlavor_" .. flavor) end
  parts[#parts + 1] = KT.PoolText("danger" .. level)
  KT.NarrateText("senses", "danger" .. level, table.concat(parts, " "), nil, true)
  KT.PetSenseDanger(level)
end

-- A hostile creature far above your level shows up nearby: you feel it.
local function CheckCreature(unit)
  if not unit or not UnitExists(unit) or not CanSpeak() then return end
  if UnitIsPlayer(unit) or UnitIsDead(unit) or not UnitCanAttack("player", unit) then return end
  local lvl, mine = UnitLevel(unit), UnitLevel("player") or 1
  if not (lvl == -1 or (lvl and lvl >= mine + 10)) then return end -- -1 = "??" skull
  if time() - (state.dangerNear or 0) < 600 then return end
  state.dangerNear = time()
  KT.Narrate("senses", "dangerNear", nil, true)
  KT.PetSenseDanger("Near")
end

-- Weather changes (outdoors, confirmed weather types only)
local function OnWeatherChanged()
  local w = S.Weather()
  local name = w and w.confirmed and w.name or nil
  local prev = lastWeatherName
  lastWeatherName = name
  if not prev or not name or name == prev or not CanSpeak() then return end
  if IsIndoors and IsIndoors() then return end
  local key = (name ~= "clear" and (name .. "Start")) or (prev .. "Stop")
  local lines = D.SENSES.weatherChange[key]
  if lines and lines[1] then
    local i = math.random(#lines)
    S.Show({ line = lines[i], id = "weatherChange:" .. key .. ":" .. i })
  end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS",
  "PLAYER_CONTROL_GAINED", -- e.g. landing after a flight path
  "PLAYER_UPDATE_RESTING", -- stepping into an inn's rest area
  "NAME_PLATE_UNIT_ADDED", "PLAYER_TARGET_CHANGED", -- dangerous creatures nearby
  "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_TEXT_EMOTE", "CHAT_MSG_EMOTE" }) do
  pcall(f.RegisterEvent, f, ev)
end
pcall(f.RegisterEvent, f, "WEATHER_CHANGED")

-- run a function, and save its error (if any) to the error log
local function Safe(fn, name)
  return function()
    local ok, err = pcall(fn)
    if not ok then KT.LogError("Senses " .. name, err) end
  end
end

f:SetScript("OnEvent", function(_, event, ...)
  local ok, err = pcall(function(...)
    if event == "PLAYER_LOGIN" then
      local db = KT.GetDB()
      db.senses = db.senses or {}
      local key = KT.CharKey()
      state = db.senses[key] or { visited = {}, recent = {} }
      db.senses[key] = state
      state.visited = state.visited or {}
      state.recent = state.recent or {}
      state.lineSeen = state.lineSeen or {}
      -- forget lines that played more than 3 days ago (keeps the save file small)
      for id, t in pairs(state.lineSeen) do
        if time() - t > 3 * 86400 then state.lineSeen[id] = nil end
      end
      local w = S.Weather()
      lastWeatherName = w and w.confirmed and w.name or nil
      C_Timer.NewTicker(60, Safe(AmbientTick, "ambient"))
      -- walking into a spot doesn't change the zone name: check every few seconds
      C_Timer.NewTicker(5, Safe(CheckArrival, "arrival"))
      C_Timer.After(8, Safe(CheckArrival, "arrival"))
    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS"
      or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_UPDATE_RESTING" then
      C_Timer.After(3, Safe(CheckArrival, "arrival"))
      if event ~= "PLAYER_UPDATE_RESTING" then
        C_Timer.After(6, Safe(CheckDanger, "danger")) -- after any arrival line
      end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
      CheckCreature(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
      CheckCreature("target")
    elseif event == "WEATHER_CHANGED" then
      OnWeatherChanged()
    else
      -- someone else talking or emoting near you: the place is lively
      local sender = select(2, ...)
      if sender and not KT.IsMe(sender) then
        chatter[#chatter + 1] = GetTime()
      end
    end
  end, ...)
  if not ok then KT.LogError("Senses " .. tostring(event), err) end
end)
