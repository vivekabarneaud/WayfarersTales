-- Wayfarer's Tales - World layer: what the environment around you is like.
-- Shared by the Elements (body comfort) and Senses (immersion) modules.
-- Only uses things the game reliably tells addons; the real weather will be
-- added here once we know what C_Weather returns in Forever.

local _, KT = ...
local D = KT.Data
local W = {}
KT.World = W

-- Zone climate by map ID (classic numbering, confirmed: Stormwind = 1453).
-- temp: -2 freezing ... 0 mild ... +2 scorching.  biome: for Senses later.
-- Zones not listed (new Forever places...) count as mild.
D.CLIMATE = {
  -- Eastern Kingdoms
  [1416] = { temp = -1, biome = "mountain" },  -- Alterac Mountains
  [1417] = { temp = 0,  biome = "plains" },    -- Arathi Highlands
  [1418] = { temp = 2,  biome = "badlands" },  -- Badlands
  [1419] = { temp = 1,  biome = "wasteland" }, -- Blasted Lands
  [1420] = { temp = 0,  biome = "gloom" },     -- Tirisfal Glades
  [1421] = { temp = 0,  biome = "gloom" },     -- Silverpine Forest: dark pines, grey skies, worgen
  [1422] = { temp = 0,  biome = "plague" },    -- Western Plaguelands
  [1423] = { temp = 0,  biome = "plague" },    -- Eastern Plaguelands
  [1424] = { temp = 0,  biome = "plains" },    -- Hillsbrad Foothills
  [1425] = { temp = 0,  biome = "forest" },    -- The Hinterlands
  [1426] = { temp = -2, biome = "snow" },      -- Dun Morogh
  [1427] = { temp = 2,  biome = "volcanic" },  -- Searing Gorge
  [1428] = { temp = 2,  biome = "volcanic" },  -- Burning Steppes
  [1429] = { temp = 0,  biome = "forest" },    -- Elwynn Forest
  [1430] = { temp = 0,  biome = "gloom" },     -- Deadwind Pass
  [1431] = { temp = 0,  biome = "gloom" },     -- Duskwood
  [1432] = { temp = 0,  biome = "hills" },     -- Loch Modan
  [1433] = { temp = 0,  biome = "hills" },     -- Redridge Mountains
  [1434] = { temp = 1,  biome = "jungle" },    -- Stranglethorn Vale
  [1435] = { temp = 1,  biome = "swamp" },     -- Swamp of Sorrows
  [1436] = { temp = 0,  biome = "farmland" },  -- Westfall: dry, dusty fields
  [1437] = { temp = 0,  biome = "marsh" },     -- Wetlands
  [1453] = { temp = 0,  biome = "city" },      -- Stormwind
  [1455] = { temp = 1,  biome = "forge" },     -- Ironforge
  [1458] = { temp = 0,  biome = "undercity" }, -- Undercity
  -- Kalimdor
  [1411] = { temp = 2,  biome = "desert" },    -- Durotar
  [1412] = { temp = 0,  biome = "plains" },    -- Mulgore
  [1413] = { temp = 2,  biome = "savanna" },   -- The Barrens
  [1438] = { temp = 0,  biome = "forest" },    -- Teldrassil
  [1439] = { temp = 0,  biome = "coast" },     -- Darkshore
  [1440] = { temp = 0,  biome = "forest" },    -- Ashenvale
  [1441] = { temp = 2,  biome = "canyon" },    -- Thousand Needles
  [1442] = { temp = 0,  biome = "mountain" },  -- Stonetalon Mountains
  [1443] = { temp = 1,  biome = "wasteland" }, -- Desolace
  [1444] = { temp = 1,  biome = "jungle" },    -- Feralas
  [1445] = { temp = 1,  biome = "swamp" },     -- Dustwallow Marsh
  [1446] = { temp = 2,  biome = "desert" },    -- Tanaris
  [1447] = { temp = 0,  biome = "coast" },     -- Azshara
  [1448] = { temp = 0,  biome = "corrupted" }, -- Felwood
  [1449] = { temp = 2,  biome = "jungle" },    -- Un'Goro Crater
  [1450] = { temp = 0,  biome = "forest" },    -- Moonglade
  [1451] = { temp = 2,  biome = "desert" },    -- Silithus
  [1452] = { temp = -2, biome = "snow" },      -- Winterspring
  [1454] = { temp = 1,  biome = "city" },      -- Orgrimmar
  [1456] = { temp = 0,  biome = "city" },      -- Thunder Bluff
  [1457] = { temp = 0,  biome = "city" },      -- Darnassus
}
D.CLIMATE_DEFAULT = { temp = 0, biome = "unknown" }


function W.MapID()
  if not (C_Map and C_Map.GetBestMapForUnit) then return nil end
  local ok, id = pcall(C_Map.GetBestMapForUnit, "player")
  return ok and id or nil
end

-- Climate of where you are. Caves and small sub-maps inherit from their parent zone.
function W.Climate()
  local id = W.MapID()
  for _ = 1, 5 do
    if not id then break end
    if D.CLIMATE[id] then return D.CLIMATE[id], id end
    local ok, info = pcall(C_Map.GetMapInfo, id)
    id = ok and info and info.parentMapID or nil
  end
  return D.CLIMATE_DEFAULT, nil
end

local function SpellName(id)
  local ok, n = pcall(C_Spell.GetSpellName, id)
  return ok and n or nil
end

-- Is there a buff on you with this spell ID (or the same name, for spells with ranks)?
function W.HasAura(spellID, byName)
  local name = byName and SpellName(spellID)
  for i = 1, 40 do
    local ok, data = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
    if not ok or not data then break end
    if data.spellId == spellID or (name and data.name == name) then return true end
  end
  return false
end

-- Is there a debuff on you with this spell ID (or the same name)? E.g. resurrection sickness.
function W.HasDebuff(spellID)
  local name = SpellName(spellID)
  for i = 1, 40 do
    local ok, data = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HARMFUL")
    if not ok or not data then break end
    if data.spellId == spellID or (name and data.name == name) then return true end
  end
  return false
end

function W.IsNight()
  local h = GetGameTime()
  return h ~= nil and (h >= 21 or h < 6)
end

-- Air temperature in °C, for the thermometer and for how your body feels.
-- Climate of the zone + time of day + a small variation that changes each day
-- (but stays the same all day for a given zone) + indoors / fire.
-- The real weather (snow, rain...) will be added here once we know its format.
local BASE_C = { [-2] = -8, [-1] = 3, [0] = 14, [1] = 25, [2] = 35 }
-- sub-zones hotter than the rest of their zone: degrees added, and at least as hot as a
-- scorching zone (35°C). By the sub-zone's name, French and English.
local HOT_SPOTS = { ["La Grande Forge"] = 8, ["The Great Forge"] = 8,
  ["Fonderie des gobelins"] = 15, ["Goblin Foundry"] = 15, ["The Goblin Foundry"] = 15 } -- the Deadmines' furnaces

-- Places colder than their zone that have no sub-zone name: an area of the map (in % like the
-- coordinates under the minimap) and the degrees added, air and water.
local COLD_AREAS = {
  { map = 1426, x1 = 58, x2 = 72, y1 = 2, y2 = 17, deg = -8 }, -- Dun Morogh: the peaks north of Ironforge
}
local function ColdArea(env)
  if not (env.x and env.rawMapID) then return nil end
  for _, a in ipairs(COLD_AREAS) do
    if a.map == env.rawMapID and env.x >= a.x1 and env.x <= a.x2 and env.y >= a.y1 and env.y <= a.y2 then
      return a.deg
    end
  end
end

-- Painted regions (tools/map, generated into RegionsData.lua): areas of a zone map with their
-- own lines, temperature and flags. Each region's area is a 200 x 200 grid over the zone map,
-- stored as runs of cells (base 36, separated by "."), off and on in turn, starting with off.
local GRID = 200
local runStarts = {} -- region -> where each run starts (cell index), and the total at the end
local function Runs(r)
  local b = runStarts[r]
  if b then return b end
  b = {}
  local pos = 0
  for t in (r.cells or ""):gmatch("[^%.]+") do
    b[#b + 1] = pos
    pos = pos + (tonumber(t, 36) or 0)
  end
  b[#b + 1] = pos
  runStarts[r] = b
  return b
end
local function Contains(r, idx)
  local b = Runs(r)
  if #b < 2 or idx >= b[#b] then return false end
  local lo, hi = 1, #b - 1 -- the run k with b[k] <= idx < b[k + 1]
  while lo < hi do
    local mid = math.floor((lo + hi + 1) / 2)
    if b[mid] <= idx then lo = mid else hi = mid - 1 end
  end
  return lo % 2 == 0 -- runs 2, 4, 6... are the painted ones
end

-- The regions you're standing in (none in dungeons, caves with their own map, or without a position)
function W.RegionsAt(env)
  local out = {}
  local list = env.x and env.rawMapID and D.REGIONS and D.REGIONS[env.rawMapID]
  if not list then return out end
  local i, j = math.floor(env.x / 100 * GRID), math.floor(env.y / 100 * GRID)
  if i < 0 or j < 0 or i >= GRID or j >= GRID then return out end
  for _, r in ipairs(list) do
    if Contains(r, j * GRID + i) then out[#out + 1] = r end
  end
  return out
end

-- The zone's temperature for the day: its climate, -3..+3 that changes each day (but stays
-- the same all day for a given zone), and the cold areas.
local function DayBase(env)
  local c = BASE_C[env.temp or 0] or 14
  local day = tonumber(date("%j")) or 1
  c = c + ((day * 31 + (env.mapID or 0) * 7) % 7) - 3
  return c + (env.coldArea or 0)
end

-- Water follows the season, not the hour: no day/night swing, rain doesn't cool it. Seas and
-- lakes stay a little cooler than the air; never below 1°C (that would be ice), at most 30°C.
function W.WaterTemp(env)
  return math.max(1, math.min(30, DayBase(env) - 4 + (env.regionWater or 0))) -- (a cold river...)
end

function W.AirTemp(env)
  local c = DayBase(env)
  local h, m = GetGameTime()
  local hour = (h or 12) + (m or 0) / 60
  c = c + 4 * math.cos((hour - 15) / 24 * 2 * math.pi)       -- warmest ~15h, coolest ~3h
  if env.rain and not env.indoors then c = c - (1 + 3 * env.rain) end -- rain cools the air (up to -4°C)
  -- snow only falls in the cold: at most 2°C, down to -2°C when it snows hard (not under a roof)
  if env.snow and not env.indoors then c = math.min(c, 2 - 4 * env.snow) end
  if env.indoors then c = c + (18 - c) * 0.6 end             -- roofs soften everything
  -- places hotter than their zone (the Great Forge's lava and furnaces), whatever the hour
  local hot = env.sub and HOT_SPOTS[env.sub]
  if hot then c = math.max(c + hot, BASE_C[2]) end
  env.hotSpot = hot and true or nil
  -- painted regions warmer or colder than their zone (a camp full of torches...), outdoors
  if env.regionAir and not env.indoors then c = c + env.regionAir end
  -- standing at a fire: much warmer, mild even in the snow; walking past it (or just stepped
  -- away): warmer; a player's campfire somewhere around (the wide "Campfire nearby" aura):
  -- only a little smoke and warmth in the air
  if env.atFire then c = math.max(c + 6, 18)
  elseif env.fireClose then c = c + 4
  elseif env.nearFire then c = c + 2 end
  return c
end

-- A fire within cooking reach (about 10 steps): any campfire (the world's or a player's), a
-- brazier, an inn's hearth... The game says whether a recipe's "Cooking Fire" requirement is
-- met, even for a recipe you don't know and with the cooking window closed (tested in Forever
-- on 2026-11-26). It doesn't say where the fire is: only "in reach" or not.
-- Returns true / false, or nil if this client can't tell.
local FIRE_RECIPES = { 2795, 2548 } -- Beer Basted Boar Ribs, Savory Herb Pork Ribs: both need a fire
function W.FireInRange()
  local C = C_TradeSkillUI
  if not (C and C.GetRecipeRequirements) then return nil end
  for _, id in ipairs(FIRE_RECIPES) do
    local ok, met = pcall(function()
      local reqs = C.GetRecipeRequirements(id)
      if type(reqs) ~= "table" or #reqs == 0 then return nil end
      for _, q in ipairs(reqs) do if q.met == true then return true end end
      return false
    end)
    if ok and met ~= nil then return met end
  end
  return nil
end

-- Asked at most once a second (the snapshot is taken by several modules)
local fireCheckedAt, fireNow, fireSeenAt = -10, nil, nil
local function FireNow()
  local now = GetTime()
  if now - fireCheckedAt >= 1 then
    fireCheckedAt, fireNow = now, W.FireInRange()
    if fireNow then fireSeenAt = now end
  end
  return fireNow, fireSeenAt
end

-- At the fire = a fire in reach and you're standing still. Walking within reach, or for a few
-- seconds after stepping away (its warmth lingers on you): fireClose.
local FIRE_LINGER = 10
local atFire, wasSeated = false, false
function W.AtFire(env)
  local inReach, seenAt = FireNow()
  if inReach ~= nil then
    env.fireClose = inReach or (seenAt ~= nil and GetTime() - seenAt < FIRE_LINGER)
    return inReach and not KT.Moving()
  end
  -- (a client without that check: sitting down by a campfire, the one-minute "stay seated"
  -- buff, as before; "Campfire nearby" alone reaches too far to mean "at the fire")
  if env.seatedAtFire and not wasSeated then atFire = true
  elseif KT.Moving() or not env.nearFire then atFire = false end
  wasSeated = env.seatedAtFire
  return atFire
end

-- Everything about "here and now" in one table.
function W.Snapshot()
  local climate, mapID = W.Climate()
  local env = {
    mapID = mapID or W.MapID(),
    temp = climate.temp,
    biome = climate.biome,
    indoors = IsIndoors and IsIndoors() or false,
    night = W.IsNight(),
    resting = IsResting() and true or false,
    swimming = IsSwimming() and true or false,
    nearFire = W.HasAura(D.AURA_CAMP_NEAR), -- a fire somewhere around (wide range): see atFire
    combat = UnitAffectingCombat("player") and true or false,
    zone = GetRealZoneText(),
    sub = GetSubZoneText(),
    afk = KT.IsAFK(),
    seatedAtFire = W.HasAura(D.AURA_CAMP_WELCOME), -- the 60s "stay seated" campfire buff
    resSick = W.HasDebuff(D.AURA_RES_SICKNESS), -- resurrection sickness (after the spirit healer)
    eating = W.HasAura(D.SPELL_FOOD_AURA, true),
    drinking = W.HasAura(D.SPELL_DRINK_AURA, true),
  }
  -- rain and snow (only once their weather type is confirmed): 0 to 1
  local wok, w = pcall(function() return KT.Senses and KT.Senses.Weather and KT.Senses.Weather() end)
  if wok and w and w.confirmed and w.name == "rain" then env.rain = tonumber(w.intensity) or 0.5 end
  if wok and w and w.confirmed and w.name == "snow" then env.snow = tonumber(w.intensity) or 0.5 end
  env.atFire = W.AtFire(env)
  -- your position on the zone map, in % like the coordinates under the minimap
  local raw = W.MapID()
  env.rawMapID = raw
  if raw and C_Map.GetPlayerMapPosition then
    local ok, pos = pcall(C_Map.GetPlayerMapPosition, raw, "player")
    if ok and pos and pos.GetXY then
      local x, y = pos:GetXY()
      if x and x > 0 then env.x, env.y = x * 100, y * 100 end
    end
  end
  env.coldArea = ColdArea(env)
  env.mounted = IsMounted and IsMounted() and true or false
  env.regions = W.RegionsAt(env)
  for _, r in ipairs(env.regions) do
    if r.air then env.regionAir = (env.regionAir or 0) + r.air end
    if r.water then env.regionWater = (env.regionWater or 0) + r.water end
    if r.abandoned then env.abandoned = true end -- nobody lives here any more (Raven Hill...)
  end
  env.air = W.AirTemp(env)
  env.water = W.WaterTemp(env)
  return env
end
