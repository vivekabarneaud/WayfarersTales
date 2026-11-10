-- Wayfarer's Tales - Discoveries: a score for everything this character has
-- discovered (places, tastes, know-how, travels), shown in the "Carnet" tab.
-- Most of it is already recorded by Senses and Moments; this file also records
-- dungeons, flight destinations and inns, and counts it all.

local _, KT = ...
local L, D = KT.L, KT.Data
local S = KT.Senses
local Di = {}
KT.Discovery = Di

local function Safe(fn, name)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then KT.LogError("Discovery " .. name, err) end
  end
end

local function Count(t)
  local n = 0
  for _ in pairs(t or {}) do n = n + 1 end
  return n
end

---------------------------------------------------------------------------
-- Counting
---------------------------------------------------------------------------

-- Number of discoveries in each category, from this character's saved data
function Di.Counts()
  local st = S.State()
  local c = { zones = 0, subzones = 0, spots = 0, dungeons = 0, tastes = 0,
    professions = 0, crafts = 0, flights = 0, inns = 0 }
  if not st then return c end
  for key in pairs(st.visited or {}) do
    if type(key) == "number" then c.zones = c.zones + 1
    elseif key:sub(1, 8) == "subname:" then c.subzones = c.subzones + 1
    elseif key:sub(1, 5) == "spot:" then c.spots = c.spots + 1 end
  end
  c.dungeons = Count(st.dungeons)
  c.tastes = Count(st.diary)
  c.professions = Count(st.professions)
  c.crafts = Count(st.crafted)
  c.flights = Count(st.flights)
  c.inns = Count(st.inns)
  return c
end

function Di.Score(c)
  c = c or Di.Counts()
  local total = 0
  for k, n in pairs(c) do total = total + n * (D.DISCOVERY_POINTS[k] or 0) end
  return total
end

---------------------------------------------------------------------------
-- New things to record: dungeons, flight destinations, inns
---------------------------------------------------------------------------

local function CheckInstance()
  local st = S.State()
  if not st or not IsInInstance then return end
  local inside, kind = IsInInstance()
  if not inside or (kind ~= "party" and kind ~= "raid") then return end
  local name, _, _, _, _, _, _, instanceID = GetInstanceInfo()
  if not name then return end
  st.dungeons = st.dungeons or {}
  st.dungeons[instanceID or name] = name
end

local function CheckInn()
  local st = S.State()
  if not st or not GetBindLocation then return end
  local inn = GetBindLocation()
  if inn and inn ~= "" then
    st.inns = st.inns or {}
    st.inns[inn] = true
  end
end

-- Where a flight landed: zone + place, e.g. "Westfall / Sentinel Hill"
local taxiSince
local function CheckFlight()
  local st = S.State()
  if not st then return end
  local onTaxi = UnitOnTaxi and UnitOnTaxi("player")
  if onTaxi then
    taxiSince = taxiSince or GetTime()
  elseif taxiSince then
    taxiSince = nil
    C_Timer.After(3, Safe(function()
      local zone, sub = GetRealZoneText() or "", GetSubZoneText() or ""
      if zone == "" then return end
      st.flights = st.flights or {}
      local key = sub ~= "" and (zone .. " / " .. sub) or zone
      st.flights[key] = st.flights[key] or time()
    end, "flight"))
  end
end

-- A line in the chat when the total crosses a milestone. Milestones already
-- passed when this feature first runs are taken silently.
local function CheckMilestone()
  local st = S.State()
  if not st then return end
  local score = Di.Score()
  local reached = 0
  for _, m in ipairs(D.DISCOVERY_MILESTONES) do
    if score >= m then reached = m end
  end
  if st.discoveryMilestone == nil then
    st.discoveryMilestone = reached
    return
  end
  if reached > st.discoveryMilestone then
    if KT.Moments and KT.Moments.Play("discoveryMilestone") then
      st.discoveryMilestone = reached
    end
  end
end

local function Tick()
  CheckFlight()
  CheckInn()
  CheckMilestone()
end

---------------------------------------------------------------------------
-- The "Carnet" page
---------------------------------------------------------------------------

local function Head(t) return "|cffffd100" .. t .. "|r" end
local function Grey(t) return "|cffaaaaaa" .. t .. "|r" end
local function Pink(t) return "|cffff8fb1" .. t .. "|r" end

local function ItemName(id)
  local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id)
  if not name and C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, id) end
  return name or ("#" .. id)
end

function Di.PageText()
  local st = S.State()
  local c = Di.Counts()
  local P = D.DISCOVERY_POINTS
  local lines = {}
  local function add(s) lines[#lines + 1] = s or "" end
  local function pts(...)
    local n = 0
    for _, k in ipairs({ ... }) do n = n + c[k] * P[k] end
    return Grey(" (" .. n .. ")")
  end
  local T = L.DISC

  add(Head(string.format(T.title, UnitName("player") or "")))
  add("|cffffd100" .. string.format(T.total, Di.Score(c)) .. "|r")
  add(Grey(T.intro))
  add("")
  add(Pink(T.places) .. pts("zones", "subzones", "spots", "dungeons"))
  add("   " .. string.format(T.placesLine, c.zones, c.subzones, c.spots, c.dungeons))
  add(Pink(T.tastes) .. pts("tastes"))
  add("   " .. string.format(T.tastesLine, c.tastes))
  add(Pink(T.crafts) .. pts("professions", "crafts"))
  add("   " .. string.format(T.craftsLine, c.professions, c.crafts))
  add(Pink(T.travels) .. pts("flights", "inns"))
  add("   " .. string.format(T.travelsLine, c.flights, c.inns))

  if not st then return table.concat(lines, "\n") end

  -- Your favourite tastes (most eaten / drunk first)
  local tastes = {}
  for id, n in pairs(st.diary or {}) do tastes[#tastes + 1] = { id = id, n = n } end
  table.sort(tastes, function(a, b) return a.n > b.n end)
  add("")
  add(Head(T.favTastes))
  if #tastes == 0 then add(Grey(T.none)) end
  for i = 1, math.min(10, #tastes) do
    add("   " .. ItemName(tastes[i].id) .. Grey("  x" .. tastes[i].n))
  end

  local function list(title, t, valueIsName)
    local names = {}
    for k, v in pairs(t or {}) do names[#names + 1] = valueIsName and tostring(v) or tostring(k) end
    table.sort(names)
    add("")
    add(Head(title))
    if #names == 0 then add(Grey(T.none)) end
    for _, n in ipairs(names) do add("   " .. n) end
  end
  list(T.dungeonList, st.dungeons, true)
  list(T.flightList, st.flights)
  list(T.innList, st.inns)
  return table.concat(lines, "\n")
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
for _, ev in ipairs({ "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA" }) do
  pcall(f.RegisterEvent, f, ev)
end
f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    C_Timer.NewTicker(5, Safe(Tick, "tick"))
  else
    C_Timer.After(2, Safe(CheckInstance, "instance"))
  end
end)
