-- Wayfarer's Tales - Elements module: your character's body comfort.
-- Pure flavor: nothing here changes your stats.
--
-- Values from 0 to 100:
--   temp    50 = comfortable, lower = cold, higher = hot. Follows the AIR
--           temperature (see World.lua), plus being wet, swimming, fires, inns.
--   wet     0 = dry, 100 = soaked
--   thirst  100 = fine, 0 = parched        (drink to fill it)
--   hunger  100 = fed, 0 = starving        (eat to fill it)
--   energy  100 = rested, 0 = exhausted    (inns, sitting by a fire, dozing off)

local _, KT = ...
local L, D = KT.L, KT.Data
local E = {}
KT.Elements = E

local TICK = 5            -- seconds between updates
local TEMP_HALFLIFE = 240 -- seconds for your body to get halfway to what the air makes it feel

local state               -- this character's saved values
local swimStart
local lastEnv = {}
local tip                 -- the hover panel with bars (created on first hover)

local function Clamp(x) return math.max(0, math.min(100, x)) end
local function Round(x) return math.floor(x + 0.5) end

local function Say(poolKey, important, vars)
  KT.Narrate("elements", poolKey, vars, important)
end

local function Ready(key, seconds)
  local t = state.cd[key]
  return not t or time() - t >= seconds
end
local function Mark(key) state.cd[key] = time() end

---------------------------------------------------------------------------
-- States, with a small margin so they don't flicker at the borders
---------------------------------------------------------------------------

local TEMP_RANK = { freezing = -2, cold = -1, ok = 0, hot = 1, overheat = 2 }

local function TempState(t, prev)
  local r = TEMP_RANK[prev or "ok"] or 0
  if t < 20 + (r <= -2 and 3 or 0) then return "freezing" end
  if t < 35 + (r <= -1 and 3 or 0) then return "cold" end
  if t > 80 - (r >= 2 and 3 or 0) then return "overheat" end
  if t > 65 - (r >= 1 and 3 or 0) then return "hot" end
  return "ok"
end
E.TempState = function(t) return TempState(t) end

-- Needs: thirst, hunger, energy. Each has an ok / mild / serious state.
local NEEDS = {
  { key = "thirst", states = { "ok", "thirsty", "parched" },  relief = "drinkRelief", remind = 900 },
  { key = "hunger", states = { "ok", "hungry", "starving" },  relief = "eatRelief",   remind = 1200 },
  { key = "energy", states = { "ok", "tired", "exhausted" },  relief = "restRelief",  remind = 1500 },
}

local function NeedState(v, prev, s)
  local r = (prev == s[3] and 2) or (prev == s[2] and 1) or 0
  if v <= 15 + (r >= 2 and 5 or 0) then return s[3] end
  if v <= 40 + (r >= 1 and 5 or 0) then return s[2] end
  return s[1]
end
local function NeedRank(st, s) return (st == s[3] and 2) or (st == s[2] and 1) or 0 end

---------------------------------------------------------------------------
-- How warm does the place make your body feel?
---------------------------------------------------------------------------

function E.Target(env)
  local target = 50 + ((env.air or 15) - 16) * 2.2   -- 16°C feels just right
  if env.swimming then target = target - 10 end
  if state.wet > 30 then target = target - 15 * (state.wet / 100) end
  if env.indoors and env.resting then target = 50 + (target - 50) * 0.5 end -- inns are cosy
  if env.nearFire then target = math.max(target, 56) end -- a fire warms you to cosy, never scorches
  return Clamp(target)
end

---------------------------------------------------------------------------
-- Messages when things change
---------------------------------------------------------------------------

local function CheckStates(env)
  -- Temperature
  local prev = state.tempState or "ok"
  local ts = TempState(state.temp, prev)
  if ts ~= prev then
    local r, pr = TEMP_RANK[ts], TEMP_RANK[prev]
    if r ~= 0 and math.abs(r) > math.abs(pr) and r * pr >= 0 then
      Say(ts .. "Enter", true)
      Mark("tempRemind")
    elseif ts == "ok" then
      Say(pr < 0 and "warmBack" or "coolBack", true)
    end
    state.tempState = ts
  elseif ts ~= "ok" and Ready("tempRemind", 600) and KT.Chance(0.8) then
    Mark("tempRemind")
    Say(ts .. "Remind")
  end

  -- Thirst, hunger, energy
  for _, n in ipairs(NEEDS) do
    local sk = n.key .. "State"
    local p = state[sk] or "ok"
    local s = NeedState(state[n.key], p, n.states)
    if s ~= p then
      if NeedRank(s, n.states) > NeedRank(p, n.states) then
        Say("body_" .. s, true)
        Mark(n.key .. "Remind")
      elseif s == "ok" then
        Say(n.relief, true)
      end
      state[sk] = s
    elseif s ~= "ok" and Ready(n.key .. "Remind", n.remind) and KT.Chance(0.8) then
      Mark(n.key .. "Remind")
      Say("body_" .. s)
    end
  end

  -- Little moments
  if env.nearFire and not lastEnv.nearFire and state.temp < 40 and Ready("fireWarm", 1200) then
    Mark("fireWarm")
    Say("fireWarm")
  end
  if env.indoors and not lastEnv.indoors and state.temp < 35 and Ready("indoorsWarm", 1200) then
    Mark("indoorsWarm")
    Say("indoorsWarm")
  end
end

---------------------------------------------------------------------------
-- Update every few seconds
---------------------------------------------------------------------------

function E.Tick()
  if not state or not KT.ModuleOn("elements") then return end
  if UnitIsDeadOrGhost("player") then return end
  local env = KT.World.Snapshot()
  local dt = TICK

  -- Back after a long time away: warmed up, dried off, fed, rested.
  if state.needsReset then
    state.needsReset = nil
    state.wet = 0 -- dry first, so the warmth below isn't computed with old wetness
    state.temp = E.Target(env)
    state.thirst = math.max(state.thirst, 80)
    state.hunger = math.max(state.hunger, 80)
    state.energy = 100
    state.tempState = TempState(state.temp)
    for _, n in ipairs(NEEDS) do state[n.key .. "State"] = NeedState(state[n.key], nil, n.states) end
  end

  local heat = math.max(0, (env.air or 15) - 20) -- degrees above 20°C
  local before = { temp = state.temp, wet = state.wet, thirst = state.thirst, hunger = state.hunger, energy = state.energy }

  -- Wetness
  if env.swimming then
    swimStart = swimStart or GetTime()
    state.wet = 100
  else
    if swimStart then
      if GetTime() - swimStart >= 5 then
        state.soaked = true
        Say("soaked")
      end
      swimStart = nil
    end
    local dry = 0.15 + 0.012 * heat
    if env.indoors then dry = dry + 0.1 end
    if env.nearFire then dry = dry + 0.8 end
    state.wet = Clamp(state.wet - dry * dt)
    if state.soaked and state.wet <= 5 then
      state.soaked = nil
      Say("dry")
    end
  end

  -- Temperature drifts toward what the air makes you feel
  local target = E.Target(env)
  state.temp = state.temp + (target - state.temp) * (1 - math.exp(-dt / TEMP_HALFLIFE))

  -- Thirst: ~1h30 from full to empty in mild air, faster in the heat and in combat
  if env.drinking then
    state.thirst = Clamp(state.thirst + 2 * dt)
  else
    local rate = 100 / 5400 * (1 + 0.04 * heat)
    if env.combat then rate = rate * 1.3 end
    state.thirst = Clamp(state.thirst - rate * dt)
  end

  -- Hunger: ~2h from full to empty, faster in combat and when you're cold
  if env.eating then
    state.hunger = Clamp(state.hunger + 2 * dt)
  else
    local rate = 100 / 7200
    if env.combat then rate = rate * 1.3 end
    if state.temp < 35 then rate = rate * 1.2 end
    state.hunger = Clamp(state.hunger - rate * dt)
  end

  -- Energy: ~3h30 of adventuring from rested to exhausted.
  -- You recover at an inn or in a city, sitting by a campfire, eating or drinking, or dozing off.
  local recover = 0
  if env.seatedAtFire then recover = math.max(recover, 0.15) end
  if env.afk then recover = math.max(recover, 0.1) end
  if env.eating or env.drinking then recover = math.max(recover, 0.08) end
  if env.resting then recover = math.max(recover, 0.05) end
  if recover > 0 then
    state.energy = Clamp(state.energy + recover * dt)
  else
    local rate = 100 / 12600
    if env.combat or env.swimming then rate = rate * 1.5 end
    if state.temp < 20 then rate = rate * 1.2 end
    state.energy = Clamp(state.energy - rate * dt)
  end

  -- Which gauges are moving right now, and the colour of their glow:
  --   needs (thirst, hunger, energy): green when filling, red when dropping faster
  --     than their normal slow pace (so red means "watch out", not "always on")
  --   wetness: green when drying, red when getting wetter
  --   temperature: green when heading back to comfortable (50), orange when above 50
  --     and still rising, blue when below 50 and still falling
  local GREEN, RED, ORANGE, BLUE = { 0.3, 1, 0.3 }, { 1, 0.25, 0.2 }, { 1, 0.6, 0.15 }, { 0.3, 0.6, 1 }
  local function need(key)
    local d = state[key] - before[key]
    if d > 0.05 then return GREEN end
    if d < -0.15 then return RED end
  end
  local dt, dw = state.temp - before.temp, state.wet - before.wet
  E.trend = {
    temp = (dt > 0.05 and (state.temp > 50 and ORANGE or GREEN))
      or (dt < -0.05 and (state.temp < 50 and BLUE or GREEN)) or nil,
    wet = (dw < -0.05 and GREEN) or (dw > 0.05 and RED) or nil,
    thirst = need("thirst"), hunger = need("hunger"), energy = need("energy"),
  }

  CheckStates(env)
  lastEnv = env
  state.last = time()
  E.target = target
  E.env = env
  E.UpdateIcons()
  E.UpdateThermo()
  if tip and tip:IsShown() then E.FillTip() end
  if KT.RefreshPanel then KT.RefreshPanel() end
end

---------------------------------------------------------------------------
-- Display helpers
---------------------------------------------------------------------------

E.TEMP_COLORS = { freezing = { 0.4, 0.6, 1 }, cold = { 0.55, 0.75, 1 }, ok = { 0.4, 0.85, 0.4 },
  hot = { 1, 0.65, 0.25 }, overheat = { 1, 0.35, 0.2 } }
E.BAR_COLORS = { wet = { 0.3, 0.55, 1 }, thirst = { 0.35, 0.75, 0.95 }, hunger = { 0.9, 0.6, 0.25 }, energy = { 0.7, 0.55, 0.95 } }

function E.Unit()
  local u = KT.GetDB().settings.tempUnit
  if u then return u end
  return GetLocale() == "enUS" and "F" or "C"
end

function E.FormatAir(c)
  if E.Unit() == "F" then return Round(c * 9 / 5 + 32) .. "°F" end
  return Round(c) .. "°C"
end

-- One row per gauge: { label, value 0-100, r, g, b }
function E.Rows()
  if not state then return {} end
  local ts = TempState(state.temp, state.tempState)
  local trend = E.trend or {}
  local rows = {
    { string.format(L.EL_TEMP, L.EL_TEMP_STATES[ts] or ts), state.temp, unpack(E.TEMP_COLORS[ts]) },
    { string.format(L.EL_WET, Round(state.wet)), state.wet, unpack(E.BAR_COLORS.wet) },
  }
  rows[1].glow, rows[2].glow = trend.temp, trend.wet
  for _, n in ipairs(NEEDS) do
    local s = NeedState(state[n.key], state[n.key .. "State"], n.states)
    local row = { string.format(L["EL_" .. n.key:upper()], KT.G(L.EL_NEED_STATES[s] or s)), state[n.key],
      unpack(E.BAR_COLORS[n.key]) }
    row.glow = trend[n.key]
    rows[#rows + 1] = row
  end
  return rows
end

-- Bars that glide to their new value (instead of jumping every 5 seconds)
-- and glow softly while they move. The glow is a few thin layers that get
-- fainter outward, so it fades into the background instead of a hard edge.
local GLOW_LAYERS = { 0.45, 0.28, 0.16, 0.08, 0.04 }

local function SetupBar(bar)
  if bar.smooth then return end
  bar.smooth = true
  bar.glows = {}
  for i, a in ipairs(GLOW_LAYERS) do
    if i > (bar.glowLayers or #GLOW_LAYERS) then break end -- thin bars get a thinner glow
    local t = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    t:SetPoint("TOPLEFT", -i, i)
    t:SetPoint("BOTTOMRIGHT", i, -i)
    t:SetColorTexture(1, 1, 1, 1)
    t:SetBlendMode("ADD")
    t.base = a
    t:Hide()
    bar.glows[i] = t
  end
  bar.pulse = 0
  bar:SetScript("OnUpdate", function(self, elapsed)
    if self.target and self.shown ~= self.target then
      local step = (self.speed or 10) * elapsed
      if math.abs(self.target - self.shown) <= step then
        self.shown = self.target
      elseif self.target > self.shown then
        self.shown = self.shown + step
      else
        self.shown = self.shown - step
      end
      self:SetValue(self.shown)
    end
    if self.glowOn then
      self.pulse = self.pulse + elapsed
      local f = 0.65 + 0.35 * math.sin(self.pulse * 2.5) -- gentle breathing
      for _, t in ipairs(self.glows) do t:SetAlpha(t.base * f) end
    end
  end)
end

function E.ApplyBar(bar, row)
  SetupBar(bar)
  local value = row[2]
  if not bar.shown then
    bar.shown = value
    bar:SetValue(value)
  end
  bar.target = value
  -- reach the new value in about one update period, at a steady pace
  bar.speed = math.max(math.abs(value - bar.shown) / (TICK - 0.5), 0.5)
  bar:SetStatusBarColor(row[3], row[4], row[5])
  local c = row.glow
  bar.glowOn = c ~= nil
  for _, t in ipairs(bar.glows) do
    if c then
      t:SetVertexColor(c[1], c[2], c[3])
      t:Show()
    else
      t:Hide()
    end
  end
end

-- "Here: 14°C, mild climate, indoors, night..."
function E.HereText()
  local env = E.env
  if not env then return "" end
  local parts = { E.FormatAir(env.air or 15), L.EL_CLIMATE[env.temp or 0] or "?" }
  if env.indoors then parts[#parts + 1] = L.EL_INDOORS end
  if env.night then parts[#parts + 1] = L.EL_NIGHT end
  if env.nearFire then parts[#parts + 1] = L.EL_FIRE end
  if env.swimming then parts[#parts + 1] = L.EL_SWIMMING end
  return string.format(L.EL_HERE, table.concat(parts, ", "))
end

---------------------------------------------------------------------------
-- Hover panel with bars (used by the body icons)
---------------------------------------------------------------------------

local function ShowBarsTip(owner)
  if not tip then
    tip = CreateFrame("Frame", "WayfarersTalesBodyTip", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    tip:SetSize(240, 200)
    tip:SetFrameStrata("TOOLTIP")
    if tip.SetBackdrop then
      tip:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 } })
      tip:SetBackdropColor(0, 0, 0, 0.9)
    end
    tip.title = tip:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tip.title:SetPoint("TOPLEFT", 10, -8)
    tip.rows = {}
    for i = 1, 5 do
      local label = tip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
      label:SetPoint("TOPLEFT", 10, -28 - (i - 1) * 27)
      local bar = CreateFrame("StatusBar", nil, tip)
      bar:SetPoint("TOPLEFT", 10, -41 - (i - 1) * 27)
      bar:SetSize(220, 8)
      bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
      bar:SetMinMaxValues(0, 100)
      local bg = bar:CreateTexture(nil, "BACKGROUND")
      bg:SetAllPoints()
      bg:SetColorTexture(1, 1, 1, 0.1)
      bar.label = label
      tip.rows[i] = bar
    end
    tip.here = tip:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tip.here:SetPoint("BOTTOMLEFT", 10, 22)
    tip.here:SetWidth(220)
    tip.here:SetJustifyH("LEFT")
    tip.hint = tip:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    tip.hint:SetPoint("BOTTOMLEFT", 10, 8)
  end
  -- when the panel opens, bars start at their current value (no catching up
  -- from the last time it was open); they glide only while it stays open
  for _, bar in ipairs(tip.rows) do bar.shown = nil end
  E.FillTip()
  tip:ClearAllPoints()
  tip:SetPoint("TOPLEFT", owner, "BOTTOMRIGHT", 4, -4)
  tip:Show()
end

-- (Re)write the panel's contents: also called every update while it's open,
-- so the bars move live (e.g. while you drink).
function E.FillTip()
  if not tip then return end
  tip.title:SetText(L.EL_TITLE)
  local rows = E.Rows()
  for i, bar in ipairs(tip.rows) do
    local r = rows[i]
    if r then
      bar.label:SetText(r[1])
      E.ApplyBar(bar, r)
      bar:Show()
      bar.label:Show()
    else
      bar:Hide()
      bar.label:Hide()
    end
  end
  tip.here:SetText(E.HereText())
  tip.hint:SetText(L.EL_MOVE_HINT)
end
local function HideBarsTip() if tip then tip:Hide() end end

---------------------------------------------------------------------------
-- Icons under your character frame: always one icon (how you feel overall),
-- plus one per thing that's off.
---------------------------------------------------------------------------

local strip
local ICONS = {
  fine   = "Interface\\Icons\\Spell_Nature_Rejuvenation",
  cold   = "Interface\\Icons\\Spell_Frost_FrostArmor",
  hot    = "Interface\\Icons\\Spell_Fire_Fire",
  wet    = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
  thirst = "Interface\\Icons\\INV_Drink_07",
  hunger = "Interface\\Icons\\INV_Misc_Food_14",
  energy = "Interface\\Icons\\Spell_Nature_Sleep",
}

local function CreateStrip()
  if strip or not PlayerFrame then return end
  strip = CreateFrame("Frame", "WayfarersTalesBody", PlayerFrame)
  strip:SetSize(24, 24)
  local pos = KT.GetDB().settings.bodyPos4
  if pos then
    strip:SetPoint("CENTER", PlayerFrame, "CENTER", pos[1], pos[2])
  else
    -- to the right of your frame, centred on it, like the pet's heart next to its happiness icon
    strip:SetPoint("LEFT", PlayerFrame, "RIGHT", -16, 0)
  end
  strip:EnableMouse(true)
  strip:SetMovable(true)
  strip:RegisterForDrag("LeftButton")
  strip:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
  strip:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local px, py = PlayerFrame:GetCenter()
    if x and px then KT.GetDB().settings.bodyPos4 = { x - px, y - py } end
  end)
  strip:SetScript("OnEnter", function(self) ShowBarsTip(self) end)
  strip:SetScript("OnLeave", HideBarsTip)
  strip:SetScript("OnMouseUp", function(_, button)
    if button == "LeftButton" and not IsShiftKeyDown() and KT.TogglePanel then KT.TogglePanel("body") end
  end)
  -- "bars" style: five slim bars, each with a small icon, always visible
  strip.miniRows = {}
  for i = 1, 5 do
    local row = CreateFrame("Frame", nil, strip)
    row:SetSize(104, 12)
    row:SetPoint("TOPLEFT", strip, "TOPLEFT", 0, -(i - 1) * 13)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(12, 12)
    row.icon:SetPoint("LEFT")
    row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local bar = CreateFrame("StatusBar", nil, row)
    bar:SetSize(86, 6)
    bar:SetPoint("LEFT", row.icon, "RIGHT", 5, 0)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetMinMaxValues(0, 100)
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", -1, 1)
    bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetColorTexture(0, 0, 0, 0.7)
    bar.glowLayers = 3
    row.bar = bar
    row:Hide()
    strip.miniRows[i] = row
  end

  -- "icons" style: one square, gold-framed slot per icon
  strip.icons = {}
  for i = 1, 6 do
    local slot = CreateFrame("Frame", nil, strip)
    slot:SetPoint("LEFT", strip, "LEFT", (i - 1) * 28, 0)
    slot.icon = KT.SquareIcon(slot, 24)
    slot:EnableMouse(false) -- hovering goes to the whole strip
    slot:Hide()
    strip.icons[i] = slot
  end
end

function E.UpdateIcons()
  if not strip then return end
  local bodyStyle = KT.GetDB().settings.bodyStyle or "none"
  -- "none" (default): your body only speaks through the chat
  if not state or not KT.ModuleOn("elements") or KT.GetDB().settings.showBody == false or bodyStyle == "none" then
    strip:Hide()
    return
  end

  -- "bars" style: always the five gauges
  if bodyStyle == "bars" then
    for _, slot in ipairs(strip.icons) do slot:Hide() end
    local rows = E.Rows()
    local keys = { "temp", "wet", "thirst", "hunger", "energy" }
    for i, mini in ipairs(strip.miniRows) do
      local r, key = rows[i], keys[i]
      if r then
        local tex = ICONS[key]
        if key == "temp" then
          local ts = state.tempState or "ok"
          tex = (ts == "cold" or ts == "freezing") and ICONS.cold
            or (ts == "hot" or ts == "overheat") and ICONS.hot or ICONS.fine
        end
        mini.icon:SetTexture(tex)
        E.ApplyBar(mini.bar, r)
        mini:Show()
      else
        mini:Hide()
      end
    end
    strip:SetSize(104, 5 * 13 - 1)
    strip:Show()
    return
  end
  for _, mini in ipairs(strip.miniRows) do mini:Hide() end

  local show = {}
  local ts = state.tempState or "ok"
  if ts == "cold" or ts == "freezing" then show[#show + 1] = { ICONS.cold, ts == "freezing" } end
  if ts == "hot" or ts == "overheat" then show[#show + 1] = { ICONS.hot, ts == "overheat" } end
  if state.wet > 30 then show[#show + 1] = { ICONS.wet, state.wet > 80 } end
  for _, n in ipairs(NEEDS) do
    local s = state[n.key .. "State"] or "ok"
    if s ~= "ok" then show[#show + 1] = { ICONS[n.key], s == n.states[3] } end
  end
  if #show == 0 then show[1] = { ICONS.fine, false } end -- all good: one calm icon
  for i, slot in ipairs(strip.icons) do
    local s = show[i]
    if s then
      slot.icon:SetTexture(s[1])
      slot.icon:SetAlpha(s[2] and 1 or 0.75)
      slot:Show()
    else
      slot:Hide()
    end
  end
  strip:SetSize(#show * 28 - 4, 24) -- the whole strip is hoverable
  strip:Show()
end

---------------------------------------------------------------------------
-- Thermometer by the minimap: the air temperature where you are
---------------------------------------------------------------------------

local thermo

local function PositionThermo()
  local angle = math.rad(KT.GetDB().settings.thermoAngle or 15)
  local r = Minimap:GetWidth() / 2 + 5
  thermo:ClearAllPoints()
  thermo:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
end

function E.UpdateThermo()
  if not thermo then return end
  local s = KT.GetDB().settings
  if not KT.ModuleOn("elements") or s.showThermo == false or not E.env then
    thermo:Hide()
    return
  end
  local c = E.env.air or 15
  local text = E.FormatAir(c):gsub("[CF]$", "") -- "14°" fits in the button
  thermo.text:SetText(text)
  if c < 5 then thermo.text:SetTextColor(0.55, 0.75, 1)
  elseif c > 27 then thermo.text:SetTextColor(1, 0.6, 0.25)
  else thermo.text:SetTextColor(1, 1, 1) end
  thermo:Show()
end

local function CreateThermo()
  if thermo or not Minimap then return end
  thermo = CreateFrame("Button", "WayfarersTalesThermo", Minimap)
  thermo:SetSize(31, 31)
  thermo:SetFrameStrata("MEDIUM")
  thermo:SetFrameLevel(8)
  thermo:RegisterForClicks("AnyUp")
  thermo:RegisterForDrag("LeftButton")
  thermo:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  local bg = thermo:CreateTexture(nil, "BACKGROUND")
  bg:SetSize(20, 20)
  bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  bg:SetPoint("TOPLEFT", 7, -5)
  local border = thermo:CreateTexture(nil, "OVERLAY")
  border:SetSize(53, 53)
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetPoint("TOPLEFT")
  thermo.text = thermo:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  thermo.text:SetPoint("CENTER", thermo, "TOPLEFT", 17, -15)

  thermo:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
      local s = KT.GetDB().settings
      s.tempUnit = E.Unit() == "C" and "F" or "C"
      E.UpdateThermo()
    elseif KT.TogglePanel then
      KT.TogglePanel("body")
    end
  end)
  thermo:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L.EL_THERMO_TITLE, 0.6, 0.85, 1)
    if E.env then
      GameTooltip:AddLine(string.format(L.EL_AIR, E.FormatAir(E.env.air or 15)), 1, 1, 1)
      GameTooltip:AddLine(E.HereText(), 0.8, 0.8, 0.8, true)
    end
    if state then
      local ts = TempState(state.temp, state.tempState)
      GameTooltip:AddLine(string.format(L.EL_YOU_FEEL, L.EL_TEMP_STATES[ts] or ts), 1, 0.82, 0)
    end
    GameTooltip:AddLine(L.EL_THERMO_HINT, 0.5, 0.5, 0.5, true)
    GameTooltip:Show()
  end)
  thermo:SetScript("OnLeave", function() GameTooltip:Hide() end)
  thermo:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
      local mx, my = Minimap:GetCenter()
      local px, py = GetCursorPosition()
      local scale = Minimap:GetEffectiveScale()
      px, py = px / scale, py / scale
      KT.GetDB().settings.thermoAngle = math.deg(math.atan2(py - my, px - mx))
      PositionThermo()
    end)
  end)
  thermo:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
  PositionThermo()
  thermo:Hide()
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")
f:SetScript("OnEvent", function(_, event)
  local ok, err = pcall(function()
    if event == "PLAYER_LOGIN" then
      local db = KT.GetDB()
      db.elements = db.elements or {}
      local key = KT.CharKey()
      state = db.elements[key]
      if not state then
        state = { temp = 50, wet = 0, thirst = 100, cd = {} }
        db.elements[key] = state
      end
      state.cd = state.cd or {}
      state.hunger = state.hunger or 100
      state.energy = state.energy or 100
      if not state.last or time() - state.last > 7200 then state.needsReset = true end
      CreateStrip()
      CreateThermo()
      local function SafeTick()
        local ok2, err2 = pcall(E.Tick)
        if not ok2 then KT.LogError("Elements tick", err2) end
      end
      C_Timer.NewTicker(TICK, SafeTick)
      C_Timer.After(3, SafeTick)
    elseif event == "PLAYER_LOGOUT" and state then
      state.last = time()
    end
  end)
  if not ok then KT.LogError("Elements " .. tostring(event), err) end
end)

function E.GetState() return state end
