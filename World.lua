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

function W.IsNight()
  local h = GetGameTime()
  return h ~= nil and (h >= 21 or h < 6)
end

-- Air temperature in °C, for the thermometer and for how your body feels.
-- Climate of the zone + time of day + a small variation that changes each day
-- (but stays the same all day for a given zone) + indoors / fire.
-- The real weather (snow, rain...) will be added here once we know its format.
local BASE_C = { [-2] = -8, [-1] = 3, [0] = 14, [1] = 25, [2] = 35 }

function W.AirTemp(env)
  local c = BASE_C[env.temp or 0] or 14
  local day = tonumber(date("%j")) or 1
  c = c + ((day * 31 + (env.mapID or 0) * 7) % 7) - 3       -- -3..+3, stable for the day
  local h, m = GetGameTime()
  local hour = (h or 12) + (m or 0) / 60
  c = c + 4 * math.cos((hour - 15) / 24 * 2 * math.pi)       -- warmest ~15h, coolest ~3h
  if env.rain and not env.indoors then c = c - (1 + 3 * env.rain) end -- rain cools the air (up to -4°C)
  if env.indoors then c = c + (18 - c) * 0.6 end             -- roofs soften everything
  -- right at a fire: much warmer, mild even in the snow; a fire somewhere around
  -- (the wide "Campfire nearby" aura): only a little smoke and warmth in the air
  if env.atFire then c = math.max(c + 6, 18)
  elseif env.nearFire then c = c + 2 end
  return c
end

-- At the fire: from the moment you get the one-minute "stay seated" buff (the game only
-- gives it right next to a fire), and as long as you don't move. Walking away loses it,
-- even if that buff is still on you (only a new one, sitting by a fire again, counts).
-- ("Campfire nearby" alone reaches far: it only means a fire somewhere around.)
local atFire, wasSeated = false, false
function W.AtFire(env)
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
    afk = UnitIsAFK("player") and true or false,
    seatedAtFire = W.HasAura(D.AURA_CAMP_WELCOME), -- the 60s "stay seated" campfire buff
    eating = W.HasAura(D.SPELL_FOOD_AURA, true),
    drinking = W.HasAura(D.SPELL_DRINK_AURA, true),
  }
  -- rain (only once its weather type is confirmed): 0 to 1
  local wok, w = pcall(function() return KT.Senses and KT.Senses.Weather and KT.Senses.Weather() end)
  if wok and w and w.confirmed and w.name == "rain" then env.rain = tonumber(w.intensity) or 0.5 end
  env.atFire = W.AtFire(env)
  env.air = W.AirTemp(env)
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
  return env
end
